/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#include "PCH.h"
#include "ItemCard.h"
#include "Game.h"
#include "Settings.h"

#include "SKSEMenuFramework.h"
#include "GridInventoryAPI.h"  // vendored verbatim from Grid Inventory (GPL-3.0 with its modding exception), as the header asks

#include <unordered_set>

namespace ItemCard
{
	namespace
	{
		using namespace ImGuiMCP;

		constexpr int kNone = -1;  // no warmth / coverage for this item; -2 = Frostfall's SkyUI item-card package is installed and draws the numbers itself

		struct Hover
		{
			bool                                  valid = false;
			int                                   warmth = 0;
			int                                   coverage = 0;
			std::chrono::steady_clock::time_point at{};
		};

		// Grid Inventory replaces the inventory with its own grid and tells other mods nothing about the item under the cursor, so with it the
		// line shows what the player is wearing instead, at the lower left. Only its "is the grid open" service is used.
		std::atomic<const GridInvAPI::HostServices*> gridInv{ nullptr };
		std::atomic<bool>                            gridOpen{ false };

		std::mutex                          lock;
		Hover                               hover;
		std::atomic<bool>                   pending{ false };
		std::mutex                          cacheLock;
		std::unordered_map<RE::FormID, int> cache;  // armor -> packed result of FrostfallItemCard.ItemProtection
		std::unordered_set<RE::FormID>      asked;

		// The answer of FrostfallItemCard.ItemProtection (runs in Papyrus, so it arrives a moment after the question).
		class Reply : public RE::BSScript::IStackCallbackFunctor
		{
		public:
			explicit Reply(RE::FormID a_id) :
				id(a_id) {}

			void operator()(RE::BSScript::Variable a_result) override
			{
				const int v = a_result.IsInt() ? a_result.GetSInt() : kNone;
				std::scoped_lock l(cacheLock);
				cache[id] = v;
			}

			void SetObject(const RE::BSTSmartPointer<RE::BSScript::Object>&) override {}

		private:
			RE::FormID id;
		};

		void Ask(RE::TESObjectARMO* a_armor)
		{
			auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton();
			if (!vm || !a_armor) {
				return;
			}
			{
				std::scoped_lock l(cacheLock);
				if (!asked.insert(a_armor->GetFormID()).second) {
					return;
				}
			}
			RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback(new Reply(a_armor->GetFormID()));
			auto*                                                    args = RE::MakeFunctionArguments(static_cast<RE::TESObjectARMO*>(a_armor));
			vm->DispatchStaticCall("FrostfallItemCard", "ItemProtection", args, callback);
		}

		// Game thread: which armor is under the cursor, and what does Frostfall say about it.
		void Update()
		{
			if (const auto* gi = gridInv.load(); gi && gi->IsMenuOpen) {
				gridOpen = gi->IsMenuOpen();
			}
			Hover next;
			if (auto* ui = RE::UI::GetSingleton()) {
				RE::ItemList* list = nullptr;
				if (ui->IsMenuOpen(RE::InventoryMenu::MENU_NAME)) {
					if (auto menu = ui->GetMenu<RE::InventoryMenu>()) {
						list = menu->GetRuntimeData().itemList;
					}
				} else if (ui->IsMenuOpen(RE::ContainerMenu::MENU_NAME)) {
					if (auto menu = ui->GetMenu<RE::ContainerMenu>()) {
						list = menu->GetRuntimeData().itemList;
					}
				}
				auto* item = list ? list->GetSelectedItem() : nullptr;
				auto* armor = (item && item->data.objDesc && item->data.objDesc->object) ? item->data.objDesc->object->As<RE::TESObjectARMO>() : nullptr;
				if (armor) {
					int result = -3;  // not asked yet / no answer yet
					{
						std::scoped_lock l(cacheLock);
						if (auto it = cache.find(armor->GetFormID()); it != cache.end()) {
							result = it->second;
						}
					}
					if (result == -3) {
						Ask(armor);
					} else if (result >= 0) {
						next.valid = true;
						next.warmth = result >> 12;
						next.coverage = result & 0xFFF;
					}
				}
			}
			next.at = std::chrono::steady_clock::now();
			{
				std::scoped_lock l(lock);
				hover = next;
			}
			pending = false;
		}

		bool CardMenuOpen()
		{
			auto* ui = RE::UI::GetSingleton();
			return ui && (ui->IsMenuOpen(RE::InventoryMenu::MENU_NAME) || ui->IsMenuOpen(RE::ContainerMenu::MENU_NAME));
		}

		ImU32 Col(float a_r, float a_g, float a_b, float a_a)
		{
			return IM_COL32(static_cast<int>(a_r), static_cast<int>(a_g), static_cast<int>(a_b), static_cast<int>(std::clamp(a_a, 0.0f, 1.0f) * 255.0f));
		}

		// Not filtered by sender, so only Grid Inventory's own message type may be acted on.
		void OnApiMessage(SKSE::MessagingInterface::Message* a_msg)
		{
			if (!a_msg || a_msg->type != GridInvAPI::kMsgHostReady || !a_msg->data || a_msg->dataLen < sizeof(GridInvAPI::HostReady)) {
				return;
			}
			const auto* ready = static_cast<const GridInvAPI::HostReady*>(a_msg->data);
			if (ready->abiVersion != GridInvAPI::kABIVersion || !ready->services) {
				SKSE::log::warn("Grid Inventory announced extension ABI {} (this build speaks {}); the item card line stays on the vanilla card", ready->abiVersion, GridInvAPI::kABIVersion);
				return;
			}
			gridInv = ready->services;
			SKSE::log::info("Grid Inventory found: the warmth and coverage line shows what you wear, at the lower left");
		}

		// Draws one piece of the line and returns where the next one starts.
		float Piece(ImDrawList* a_dl, ImFont* a_font, float a_size, float a_scale, float a_x, float a_y, ImU32 a_col, const char* a_text)
		{
			ImDrawListManager::AddText(a_dl, a_font, a_size, ImVec2(a_x + 1.5f, a_y + 1.5f), Col(0, 0, 0, 0.8f), a_text);  // soft shadow: readable on any background
			ImDrawListManager::AddText(a_dl, a_font, a_size, ImVec2(a_x, a_y), a_col, a_text);
			return a_x + CalcTextSize(a_text).x * a_scale;
		}
	}

	void Register()
	{
		SKSE::GetMessagingInterface()->RegisterListener(nullptr, OnApiMessage);
	}

	bool GridInventoryFound() { return gridInv.load() != nullptr; }

	namespace
	{
		// "Warmth 30   Coverage 29": gold labels (the card's own colour), white numbers, centred on a_cx, top at a_y (fractions of the screen).
		void DrawLine(ImDrawList* a_dl, float a_displayW, float a_displayH, float a_cx, float a_y, int a_warmth, int a_coverage)
		{
			const auto& s = Settings::Get();
			char        warmth[16], coverage[16];
			std::snprintf(warmth, sizeof(warmth), "%d", a_warmth);
			std::snprintf(coverage, sizeof(coverage), "%d", a_coverage);
			const char* labelW = "Warmth ";
			const char* labelC = "Coverage ";
			const char* gap = "     ";
			const float size = std::max(10.0f, s.cardSize * a_displayH / 1080.0f);
			const float scale = size / GetFontSize();
			const float width = (CalcTextSize(labelW).x + CalcTextSize(warmth).x + CalcTextSize(gap).x + CalcTextSize(labelC).x + CalcTextSize(coverage).x) * scale;
			float       x = a_displayW * a_cx - width * 0.5f;
			const float y = a_displayH * a_y;
			auto*       font = GetFont();
			const ImU32 gold = Col(214, 178, 96, 1.0f);
			const ImU32 white = Col(240, 240, 240, 1.0f);
			x = Piece(a_dl, font, size, scale, x, y, gold, labelW);
			x = Piece(a_dl, font, size, scale, x, y, white, warmth);
			x = Piece(a_dl, font, size, scale, x, y, gold, gap);
			x = Piece(a_dl, font, size, scale, x, y, gold, labelC);
			Piece(a_dl, font, size, scale, x, y, white, coverage);
		}
	}

	void Draw(ImDrawList* a_dl, float a_displayW, float a_displayH, bool a_preview)
	{
		const auto& s = Settings::Get();
		if (!s.itemCardValues || (!a_preview && !Game::IsRunning())) {
			return;
		}
		if (a_preview) {  // the settings page is open: sample lines, so they can be placed without opening the inventory
			DrawLine(a_dl, a_displayW, a_displayH, s.cardX, s.cardY, 30, 29);
			if (GridInventoryFound()) {
				DrawLine(a_dl, a_displayW, a_displayH, s.cardGridX, s.cardGridY, 108, 70);
			}
			return;
		}
		const bool cardOpen = CardMenuOpen();
		if (!cardOpen && !GridInventoryFound()) {
			std::scoped_lock l(cacheLock);  // a fresh question each time the menu opens, so changed armor data shows up
			if (!cache.empty() || !asked.empty()) {
				cache.clear();
				asked.clear();
			}
			return;
		}
		if (!pending.exchange(true)) {
			SKSE::GetTaskInterface()->AddTask(Update);
		}
		if (gridOpen) {
			// Grid Inventory: what the player wears (Frostfall's own totals), at the lower left under its stats panel
			const auto& g = Game::G();
			if (g.warmth && g.coverage) {
				DrawLine(a_dl, a_displayW, a_displayH, s.cardGridX, s.cardGridY, static_cast<int>(Game::Value(g.warmth) + 0.5f), static_cast<int>(Game::Value(g.coverage) + 0.5f));
			}
			return;
		}
		if (!cardOpen) {
			return;
		}
		Hover h;
		{
			std::scoped_lock l(lock);
			h = hover;
		}
		if (!h.valid || std::chrono::steady_clock::now() - h.at > std::chrono::milliseconds(400)) {
			return;
		}
		DrawLine(a_dl, a_displayW, a_displayH, s.cardX, s.cardY, h.warmth, h.coverage);
	}
}
