#include "PCH.h"
#include <map>
#include <regex>
#include "NativeMcm.h"
#include "Game.h"
#include "Hotkeys.h"
#include "McmTable.h"

#include "SKSEMenuFramework.h"

namespace NativeMcm
{
	namespace
	{
		using namespace ImGuiMCP;

		constexpr const char* kScript = "_Frost_SkyUIConfigPanelScript";
		constexpr const char* kConfigPath = "../FrostfallData/";  // where the MCM keeps its profiles (JsonUtil path)
		constexpr float       kProfileWriteDelay = 0.6f;          // profile writes wait for the last change, like dragging a slider

		std::map<std::string, int>   pendingInts;    // profile key -> value, written after a short delay
		std::map<std::string, float> pendingFloats;
		float                        profileTimer = -1.0f;

		RE::TESGlobal* Global(unsigned int a_localId)
		{
			auto* dh = RE::TESDataHandler::GetSingleton();
			return dh ? dh->LookupForm<RE::TESGlobal>(a_localId, "Frostfall.esp") : nullptr;
		}

		// Writes the pending keys to the current profile with PapyrusUtil's JsonUtil, as the MCM's SaveSettingToCurrentProfile does.
		void FlushProfile()
		{
			if (pendingInts.empty() && pendingFloats.empty()) {
				return;
			}
			auto ints = std::move(pendingInts);
			auto floats = std::move(pendingFloats);
			pendingInts.clear();
			pendingFloats.clear();
			SKSE::GetTaskInterface()->AddTask([ints = std::move(ints), floats = std::move(floats)]() {
				auto* autoSave = Global(mcm::kFrostSettingAutoSaveLoad);
				auto* profile = Global(mcm::kFrostSettingCurrentProfile);
				auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton();
				if (!vm || !autoSave || !profile || static_cast<int>(autoSave->value) != 2) {
					return;  // automatic profile saving is off: nothing to write
				}
				const std::string path = std::string(kConfigPath) + "profile" + std::to_string(static_cast<int>(profile->value));
				RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback;
				for (const auto& [key, value] : ints) {
					vm->DispatchStaticCall("JsonUtil", "SetIntValue", RE::MakeFunctionArguments(std::string(path), std::string(key), static_cast<std::int32_t>(value)), callback);
				}
				for (const auto& [key, value] : floats) {
					vm->DispatchStaticCall("JsonUtil", "SetFloatValue", RE::MakeFunctionArguments(std::string(path), std::string(key), static_cast<float>(value)), callback);
				}
				vm->DispatchStaticCall("JsonUtil", "Save", RE::MakeFunctionArguments(std::string(path), false), callback);
			});
		}

		void QueueProfile(const char* a_key, float a_value, bool a_float)
		{
			if (a_key && a_key[0]) {
				if (a_float) {
					pendingFloats[a_key] = a_value;
				} else {
					pendingInts[a_key] = static_cast<int>(a_value);
				}
				profileTimer = kProfileWriteDelay;
			}
		}

		// Calls a method of the menu script (on quest _Frost_SkyUIConfigPanel) on the game thread.
		template <class... Args>
		void CallMenuScript(const char* a_method, Args... a_args)
		{
			SKSE::GetTaskInterface()->AddTask([=]() mutable {
				auto* dh = RE::TESDataHandler::GetSingleton();
				auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton();
				auto* quest = dh ? dh->LookupForm<RE::TESQuest>(mcm::kMcmQuest, "Frostfall.esp") : nullptr;
				if (!vm || !quest) {
					SKSE::log::warn("Frostfall settings: cannot call {}.{} (quest or VM missing)", kScript, a_method);
					return;
				}
				const auto handle = vm->GetObjectHandlePolicy()->GetHandleForObject(RE::TESQuest::FORMTYPE, quest);
				RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback;
				const bool ok = vm->DispatchMethodCall2(handle, kScript, a_method, RE::MakeFunctionArguments(std::move(a_args)...), callback);
				SKSE::log::info("Frostfall settings: {}.{}() -> {}", kScript, a_method, ok ? "dispatched" : "FAILED");
			});
		}

		void JsonSetInt(std::string a_path, std::string a_key, int a_value)
		{
			SKSE::GetTaskInterface()->AddTask([a_path, a_key, a_value]() {
				auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton();
				RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback;
				if (vm) {
					vm->DispatchStaticCall("JsonUtil", "SetIntValue", RE::MakeFunctionArguments(std::string(a_path), std::string(a_key), static_cast<std::int32_t>(a_value)), callback);
				}
			});
		}

		void JsonSetString(std::string a_path, std::string a_key, std::string a_value)
		{
			SKSE::GetTaskInterface()->AddTask([a_path, a_key, a_value]() {
				auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton();
				RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback;
				if (vm) {
					vm->DispatchStaticCall("JsonUtil", "SetStringValue", RE::MakeFunctionArguments(std::string(a_path), std::string(a_key), std::string(a_value)), callback);
				}
			});
		}

		void JsonSave(std::string a_path)
		{
			SKSE::GetTaskInterface()->AddTask([a_path]() {
				auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton();
				RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback;
				if (vm) {
					vm->DispatchStaticCall("JsonUtil", "Save", RE::MakeFunctionArguments(std::string(a_path), false), callback);
				}
			});
		}

		std::string ReadFile(const std::string& a_path)
		{
			std::ifstream in(a_path);
			return in ? std::string((std::istreambuf_iterator<char>(in)), std::istreambuf_iterator<char>()) : std::string();
		}

		// The name stored in a profile's file (Data/SKSE/Plugins/FrostfallData/profileN.json), or "Profile N".
		std::string ProfileName(int a_index)
		{
			const std::string text = ReadFile("Data/SKSE/Plugins/FrostfallData/profile" + std::to_string(a_index) + ".json");
			static const std::regex re("\"profile_name\"\\s*:\\s*\"([^\"]*)\"");
			std::smatch m;
			if (std::regex_search(text, m, re) && !m[1].str().empty()) {
				return m[1].str();
			}
			return "Profile " + std::to_string(a_index);
		}

		// The optional SkyUI interface package (version 6) shows the equipment notifications itself; Frostfall then hides these two options.
		bool InterfacePackageInstalled()
		{
			static float timer = 0.0f;
			static bool  installed = false;
			timer -= GetIO()->DeltaTime;
			if (timer <= 0.0f) {
				timer = 2.0f;
				const std::string text = ReadFile("Data/SKSE/Plugins/FrostfallData/interface_package_version.json");
				static const std::regex re("\"installed_package_version\"\\s*:\\s*6\\b");
				installed = std::regex_search(text, re);
			}
			return installed;
		}

		void Changed(const mcm::Entry& a_e, RE::TESGlobal* a_g, float a_value)
		{
			a_g->value = a_value;
			QueueProfile(a_e.profileKey, a_value, a_e.isFloat != 0);
		}

		void Tip(const mcm::Entry& a_e)
		{
			if (a_e.tip && a_e.tip[0] && IsItemHovered()) {
				BeginTooltip();
				PushTextWrapPos(420.0f);
				TextUnformatted(a_e.tip);
				PopTextWrapPos();
				EndTooltip();
			}
		}

		void DrawEntry(const mcm::Entry& a_e, int a_id)
		{
			PushID(a_id);
			bool disabled = false;
			if (a_e.gate != 0 && a_e.special != 1) {
				auto* gate = Global(a_e.gate);
				disabled = !gate || static_cast<int>(gate->value) != 2;
			}
			if (disabled) {
				BeginDisabled();
			}
			switch (a_e.kind) {
			case mcm::Kind::Header:
				Spacing();
				SeparatorText(a_e.label);
				break;
			case mcm::Kind::Column:
				Spacing();
				Separator();
				break;
			case mcm::Kind::Toggle:
				if (auto* g = Global(a_e.formId)) {
					if (a_e.special == 2 && InterfacePackageInstalled()) {
						break;
					}
					bool on = static_cast<int>(g->value) == 2;
					bool forced = false;
					if (a_e.special == 1) {  // "no fast travel" is on, and cannot be changed, while "no waiting" is on
						auto* gate = Global(a_e.gate);
						forced = gate && static_cast<int>(gate->value) == 2;
						if (forced) {
							on = true;
							BeginDisabled();
						}
					}
					if (Checkbox(a_e.label, &on) && !forced) {
						Changed(a_e, g, on ? 2.0f : 1.0f);
					}
					if (forced) {
						EndDisabled();
					}
					Tip(a_e);
				}
				break;
			case mcm::Kind::Slider:
				if (auto* g = Global(a_e.formId)) {
					float v = g->value;
					if (SliderFloat(a_e.label, &v, a_e.min, a_e.max, a_e.format)) {
						if (a_e.step > 0.0f) {
							v = a_e.min + std::round((v - a_e.min) / a_e.step) * a_e.step;
						}
						v = std::clamp(v, a_e.min, a_e.max);
						Changed(a_e, g, v);
					}
					Tip(a_e);
				}
				break;
			case mcm::Kind::Key:
				if (auto* g = Global(a_e.formId)) {
					const int slot = static_cast<int>(a_e.min);
					int       picked = 0;
					if (Hotkeys::CapturingSlot() == slot && Hotkeys::TakeCaptured(slot, picked)) {
						// the menu script re-registers the key, sets the global and swaps the hotkey's spell in or out, as its own menu does
						CallMenuScript("NativeSetHotkey", static_cast<std::int32_t>(picked));
						g->value = static_cast<float>(picked);
						QueueProfile(a_e.profileKey, static_cast<float>(picked), false);
					}
					if (Hotkeys::CapturingSlot() == slot) {
						if (Button("Press a key...  (Esc cancels, Delete clears)")) {
							Hotkeys::CancelCapture();
						}
					} else {
						const std::string text = std::string(Hotkeys::KeyName(static_cast<int>(g->value))) + "##key";
						if (Button(text.c_str(), ImVec2(180.0f, 0.0f))) {
							Hotkeys::BeginCapture(slot);
						}
					}
					SameLine();
					Text("%s", a_e.label);
					Tip(a_e);
				}
				break;
			case mcm::Kind::Menu:
				if (auto* g = Global(a_e.formId)) {
					int index = std::clamp(static_cast<int>(g->value) - a_e.menuBase, 0, std::max(0, a_e.optionCount - 1));
					if (Combo(a_e.label, &index, a_e.options, a_e.optionCount)) {
						Changed(a_e, g, static_cast<float>(index + a_e.menuBase));
					}
					Tip(a_e);
				}
				break;
			}
			if (disabled) {
				EndDisabled();
			}
			PopID();
		}

		// The pages only make sense while Frostfall runs, as in the SkyUI menu ("Enable Frostfall to view this page").
		bool UsablePage()
		{
			if (!Game::Ready() || !Global(mcm::kFrostSettingAutoSaveLoad)) {
				TextDisabled("Frostfall.esp is not loaded.");
				return false;
			}
			if (!Game::IsRunning()) {
				TextDisabled("Frostfall is not running. Start it on the Overview page to change these settings.");
				return false;
			}
			auto* init = Global(mcm::kFrostDatastoreInitialized);
			if (init && static_cast<int>(init->value) != 2) {
				TextDisabled("Frostfall is still starting up. Close the menu and wait a moment.");
				return false;
			}
			return true;
		}
	}

	void DrawPage(int a_page)
	{
		if (a_page < 0 || a_page >= static_cast<int>(std::size(mcm::kPages)) || !UsablePage()) {
			return;
		}
		const auto& page = mcm::kPages[a_page];
		for (int i = 0; i < page.count; ++i) {
			DrawEntry(page.entries[i], i);
		}
		if (std::string_view(page.title) == "Gameplay") {
			Spacing();
			TextWrapped("Click the hotkey button, then press the key. Escape cancels, Delete clears it (the Weathersense power is then back in your spell list).");
		}
	}

	void DrawAdvancedExtras()
	{
		if (!UsablePage()) {
			return;
		}
		static int   confirm = 0;  // 1 = respec asked, 2 = restore asked, 3 = tutorial reset asked
		static float restore = 0.0f;
		static float confirmTimer = 0.0f;
		confirmTimer -= GetIO()->DeltaTime;
		if (confirmTimer <= 0.0f) {
			confirm = 0;
		}
		Spacing();
		SeparatorText("Endurance Skill");
		if (confirm == 1) {
			TextWrapped("Are you sure you want to refund all earned Endurance skill points so you can reallocate them?");
			if (Button("Yes, respec my perks")) {
				CallMenuScript("RefundEnduranceSkillPoints");
				confirm = 0;
			}
			SameLine();
			if (Button("Cancel##respec")) {
				confirm = 0;
			}
		} else if (Button("Respec Perks")) {
			confirm = 1;
			confirmTimer = 10.0f;
		}
		float total = 0.0f;
		if (auto* g = Global(mcm::kEndurancePerkPointsTotal)) {
			total = g->value;
		}
		TextWrapped("Restore Perk Progress: reclaim Endurance skill progress lost to a clean save or a mod uninstall. This replaces your current progress.");
		restore = std::clamp(restore, 0.0f, std::max(total, 0.0f));
		SliderFloat("Perks to restore", &restore, 0.0f, std::max(total, 1.0f), "%.0f");
		if (confirm == 2) {
			if (Button("Yes, restore these perk points")) {
				CallMenuScript("NativeRestoreSkillPoints", static_cast<std::int32_t>(restore));
				confirm = 0;
			}
			SameLine();
			if (Button("Cancel##restore")) {
				confirm = 0;
			}
		} else if (Button("Restore perk progress")) {
			confirm = 2;
			confirmTimer = 10.0f;
		}

		Spacing();
		SeparatorText("Tutorials");
		if (confirm == 3) {
			TextWrapped("Reset all tutorials?");
			if (Button("Yes, reset them")) {
				for (auto id : { mcm::kFrostHelpDoneExposure, mcm::kFrostHelpDoneWet, mcm::kFrostHelpDoneCold }) {
					if (auto* g = Global(id)) {
						g->value = 1.0f;
					}
				}
				confirm = 0;
			}
			SameLine();
			if (Button("Cancel##tutorials")) {
				confirm = 0;
			}
		} else if (Button("Reset Tutorials")) {
			confirm = 3;
			confirmTimer = 10.0f;
		}
	}

	void DrawProfiles()
	{
		if (!UsablePage()) {
			return;
		}
		auto* current = Global(mcm::kFrostSettingCurrentProfile);
		auto* autoSave = Global(mcm::kFrostSettingAutoSaveLoad);
		static int         pendingSwitch = 0;   // profile asked for, waiting for the confirmation
		static bool        askDefault = false;  // "reset the current profile" waiting for the confirmation
		static float       confirmTimer = 0.0f;
		static float       namesTimer = 0.0f;
		static std::string names[10];
		static char        renameBuffer[64] = "";
		confirmTimer -= GetIO()->DeltaTime;
		if (confirmTimer <= 0.0f) {
			pendingSwitch = 0;
			askDefault = false;
		}
		namesTimer -= GetIO()->DeltaTime;
		if (namesTimer <= 0.0f) {
			namesTimer = 1.0f;
			for (int i = 0; i < 10; ++i) {
				names[i] = ProfileName(i + 1);
			}
		}
		const char* items[10];
		for (int i = 0; i < 10; ++i) {
			items[i] = names[i].c_str();
		}

		SeparatorText("Settings Profiles");
		const int activeIndex = std::clamp(static_cast<int>(current->value), 1, 10) - 1;
		int       choice = activeIndex;
		if (Combo("Current profile", &choice, items, 10) && choice != activeIndex) {
			pendingSwitch = choice + 1;
			confirmTimer = 10.0f;
		}
		if (pendingSwitch > 0) {
			TextWrapped("Load the selected profile? Your current settings are replaced by that profile's.");
			if (Button("Yes, load it")) {
				FlushProfile();
				CallMenuScript("SwitchToProfile", static_cast<std::int32_t>(pendingSwitch));
				pendingSwitch = 0;
			}
			SameLine();
			if (Button("Cancel##switch")) {
				pendingSwitch = 0;
			}
		}

		Spacing();
		bool automatic = static_cast<int>(autoSave->value) == 2;
		if (Checkbox("Automatic profile save / load", &automatic)) {
			autoSave->value = automatic ? 2.0f : 1.0f;
			JsonSetInt(std::string(kConfigPath) + "common", "auto_load", automatic ? 2 : 1);
			JsonSave(std::string(kConfigPath) + "common");
			if (automatic) {
				CallMenuScript("SaveAllSettings", static_cast<std::int32_t>(current->value));  // write every setting to the profile now
			}
		}
		TextWrapped(
			"A profile stores all of Frostfall's settings in a file. With automatic save / load on, each change is saved to the current profile, and "
			"loading a game, switching characters or starting a new game picks the profile up again. There are 10 profile slots. The files are in "
			"Data/SKSE/Plugins/FrostfallData/ (common.json and profile*.json); with Mod Organizer 2 they end up in your Overwrite folder. "
			"The HUD bars' position and size (the HUD page) are saved separately, in Frostfall.dll's own settings, not in profiles.");

		if (automatic) {
			Spacing();
			SeparatorText("This profile");
			InputText("##rename", renameBuffer, sizeof(renameBuffer));
			SameLine();
			if (Button("Rename profile")) {
				if (renameBuffer[0] != '\0') {
					const std::string path = std::string(kConfigPath) + "profile" + std::to_string(static_cast<int>(current->value));
					JsonSetString(path, "profile_name", renameBuffer);
					JsonSave(path);
					renameBuffer[0] = '\0';
					namesTimer = 0.5f;  // re-read the names once the file has been written
				}
			}
			if (askDefault) {
				TextWrapped("Are you sure you want to restore all settings on your current profile to their default values?");
				if (Button("Yes, restore the defaults")) {
					const auto profile = static_cast<std::int32_t>(current->value);
					pendingInts.clear();
					pendingFloats.clear();
					CallMenuScript("GenerateDefaultProfile", profile);
					CallMenuScript("SwitchToProfile", profile);
					askDefault = false;
				}
				SameLine();
				if (Button("Cancel##default")) {
					askDefault = false;
				}
			} else if (Button("Default current profile")) {
				askDefault = true;
				confirmTimer = 10.0f;
			}
		}
	}

	void Tick(float a_dt)
	{
		if (profileTimer >= 0.0f) {
			profileTimer -= a_dt;
			if (profileTimer < 0.0f) {
				FlushProfile();
			}
		}
	}
}
