/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#include "PCH.h"
#include "Hud.h"
#include "Game.h"
#include "Settings.h"

#include "SKSEMenuFramework.h"

namespace Hud
{
	namespace
	{
		using namespace ImGuiMCP;

		constexpr const char* kLogoPath = "Data\\Interface\\frostfall\\frostfall_logo.png";
		constexpr float       kLogoAspect = 100.0f / 460.0f;
		constexpr float       kLogoFadeIn = 0.8f;
		constexpr float       kLogoHold = 2.6f;
		constexpr float       kLogoFadeOut = 1.2f;

		std::atomic<bool> logoRequested{ false };
		float             logoTime = -1.0f;  // seconds since the logo started, -1 = not showing
		int               previewFrames = 0;
		float             saveTimer = -1.0f;
		bool              meterModeChecked = false;
		float             groupAlpha = 1.0f;

		struct Tracked
		{
			float shown = -1.0f;      // animated fill (0..1)
			float last = -1.0f;       // last raw value, to detect change
			float sinceChange = 1e6f; // seconds since the raw value last changed
		};
		Tracked exposureT, wetnessT, tempT, warmthT, coverageT;

		float Frac(const RE::TESGlobal* a_value, const RE::TESGlobal* a_max, float a_defaultMax)
		{
			const float max = std::max(Game::Value(a_max, a_defaultMax), 1.0f);
			return std::clamp(Game::Value(a_value) / max, 0.0f, 1.0f);
		}

		void Track(Tracked& a_t, float a_frac, float a_dt)
		{
			if (a_t.shown < 0.0f) {
				a_t.shown = a_frac;
				a_t.last = a_frac;
			}
			if (std::abs(a_frac - a_t.last) > 0.001f) {
				a_t.sinceChange = 0.0f;
				a_t.last = a_frac;
			} else {
				a_t.sinceChange += a_dt;
			}
			a_t.shown += (a_frac - a_t.shown) * std::min(1.0f, a_dt * 6.0f);  // smooth fill movement
		}

		ImU32 Col(float r, float g, float b, float a)
		{
			return IM_COL32(static_cast<int>(std::clamp(r, 0.0f, 255.0f)), static_cast<int>(std::clamp(g, 0.0f, 255.0f)),
				static_cast<int>(std::clamp(b, 0.0f, 255.0f)), static_cast<int>(std::clamp(a, 0.0f, 1.0f) * 255.0f));
		}

		struct Rgb { float r, g, b; };
		Rgb Lerp(Rgb a, Rgb b, float t) { return { a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t }; }

		// One flat vertical bar: dark track, fill from the bottom, slightly lighter at the top of the fill. No border.
		void DrawBar(ImDrawList* a_dl, float a_x, float a_y, float a_w, float a_h, float a_fill, Rgb a_color, float a_alpha)
		{
			const float rounding = std::min(a_w * 0.35f, 4.0f);
			ImDrawListManager::AddRectFilled(a_dl, ImVec2(a_x, a_y), ImVec2(a_x + a_w, a_y + a_h), Col(10, 12, 16, 0.55f * a_alpha), rounding, 0);
			const float fh = a_h * std::clamp(a_fill, 0.0f, 1.0f);
			if (fh < 0.5f) {
				return;
			}
			const float top = a_y + a_h - fh;
			const ImU32 cTop = Col(a_color.r + 35, a_color.g + 35, a_color.b + 35, 0.95f * a_alpha);
			const ImU32 cBot = Col(a_color.r * 0.8f, a_color.g * 0.8f, a_color.b * 0.8f, 0.95f * a_alpha);
			ImDrawListManager::AddRectFilledMultiColor(a_dl, ImVec2(a_x, top), ImVec2(a_x + a_w, a_y + a_h), cTop, cTop, cBot, cBot);
		}

		// White glyphs on transparent PNGs (Interface/frostfall/icons, drawn by tools/make_icons.py), tinted here.
		// SKSE Menu Framework's icon font lacks these glyphs and drew "?" instead.
		enum Icon { kExposure, kWetness, kTemperature, kWarmth, kIconCount };

		ImTextureID IconTexture(Icon a_icon)
		{
			static constexpr const char* paths[kIconCount] = {
				"Data\\Interface\\frostfall\\icons\\exposure.png",
				"Data\\Interface\\frostfall\\icons\\wetness.png",
				"Data\\Interface\\frostfall\\icons\\temperature.png",
				"Data\\Interface\\frostfall\\icons\\warmth.png",
			};
			static ImTextureID textures[kIconCount] = {};
			static bool        loaded = false;
			if (!loaded) {
				loaded = true;
				for (int i = 0; i < kIconCount; ++i) {
					textures[i] = SKSEMenuFramework::LoadTexture(paths[i]);
					if (!textures[i]) {
						SKSE::log::warn("HUD icon not found: {}", paths[i]);
					}
				}
			}
			return textures[a_icon];
		}

		void DrawIcon(ImDrawList* a_dl, Icon a_icon, float a_cx, float a_top, float a_size, float a_alpha)
		{
			auto* tex = IconTexture(a_icon);
			if (!tex) {
				return;
			}
			const float x = a_cx - a_size * 0.5f;
			ImDrawListManager::AddImage(a_dl, tex, ImVec2(x + 1.0f, a_top + 1.0f), ImVec2(x + a_size + 1.0f, a_top + a_size + 1.0f),
				ImVec2(0, 0), ImVec2(1, 1), Col(0, 0, 0, 0.55f * a_alpha));
			ImDrawListManager::AddImage(a_dl, tex, ImVec2(x, a_top), ImVec2(x + a_size, a_top + a_size),
				ImVec2(0, 0), ImVec2(1, 1), Col(225, 232, 240, 0.9f * a_alpha));
		}

		bool HudHiddenByGame()
		{
			auto* ui = RE::UI::GetSingleton();
			if (!ui) {
				return true;
			}
			if (ui->GameIsPaused() || ui->IsMenuOpen(RE::LoadingMenu::MENU_NAME) || ui->IsMenuOpen(RE::MainMenu::MENU_NAME)) {
				return true;
			}
			return !ui->IsShowingMenus();  // the HUD was toggled off (tm)
		}

		void DrawBars(ImDrawList* a_dl, float a_dt, bool a_preview)
		{
			auto&       s = Settings::Get();
			const auto& g = Game::G();
			const auto* io = GetIO();
			const float W = io->DisplaySize.x;
			const float H = io->DisplaySize.y;
			const float k = (H / 1080.0f) * s.scale;

			const float fExposure = Frac(g.exposure, g.exposureMax, 100.0f);
			const float fWet = Frac(g.wetness, g.wetnessMax, 750.0f);
			const float fTemp = Frac(g.tempLevel, g.tempLevelMax, 10.0f);
			const float fWarmth = Frac(g.warmth, g.warmthMax, 550.0f);
			const float fCoverage = Frac(g.coverage, g.coverageMax, 360.0f);
			Track(exposureT, fExposure, a_dt);
			Track(wetnessT, fWet, a_dt);
			Track(tempT, fTemp, a_dt);
			Track(warmthT, fWarmth, a_dt);
			Track(coverageT, fCoverage, a_dt);

			// Contextual: stay visible while something changed recently or the player is not comfortable
			float target = 1.0f;
			if (s.displayMode == 1 && !a_preview) {
				const float recent = std::min({ exposureT.sinceChange, wetnessT.sinceChange, tempT.sinceChange, warmthT.sinceChange, coverageT.sinceChange });
				const bool  uncomfortable = fExposure > 0.20f || fWet > 0.01f;
				target = (recent < s.contextualSeconds || uncomfortable) ? 1.0f : 0.0f;
			}
			groupAlpha += (target - groupAlpha) * std::min(1.0f, a_dt * 3.0f);
			const float alpha = groupAlpha * s.opacity;
			if (alpha < 0.01f) {
				return;
			}

			const float t = s.barThickness * k;
			const float L = s.barLength * k;
			const float gap = s.spacing * k;
			const float icon = s.showIcons ? 16.0f * k : 0.0f;
			const float rowGap = gap + icon + (s.showIcons ? 6.0f * k : 0.0f);
			const float right = s.posX * W;
			const float centerY = s.posY * H;

			// Slot positions: grid = 2 columns x 2 rows; row = 4 across
			struct Slot { float x, y; };
			Slot slots[4];
			if (s.layout == 0) {
				const float groupW = 2 * t + gap * 1.6f;
				const float groupH = 2 * L + rowGap;
				const float x0 = right - groupW;
				const float y0 = centerY - groupH * 0.5f;
				slots[0] = { x0, y0 };
				slots[1] = { x0 + t + gap * 1.6f, y0 };
				slots[2] = { x0, y0 + L + rowGap };
				slots[3] = { x0 + t + gap * 1.6f, y0 + L + rowGap };
			} else {
				const float step = t + gap * 1.6f;
				const float x0 = right - (4 * t + 3 * gap * 1.6f);
				const float y0 = centerY - (L + icon) * 0.5f;
				for (int i = 0; i < 4; ++i) {
					slots[i] = { x0 + i * step, y0 };
				}
			}

			const Rgb iceLight{ 175, 215, 255 }, iceDeep{ 70, 135, 255 };
			const Rgb cold{ 105, 160, 255 }, warm{ 255, 175, 85 };
			const float pulse = fExposure >= 0.8f ? 0.75f + 0.25f * std::sin(static_cast<float>(ImGuiMCP::GetTime()) * 5.0f) : 1.0f;

			auto iconAt = [&](int a_slot, Icon a_icon) {
				if (s.showIcons) {
					DrawIcon(a_dl, a_icon, slots[a_slot].x + t * 0.5f, slots[a_slot].y + L + 5.0f * k, 14.0f * k, alpha);
				}
			};

			if (s.showExposure) {
				DrawBar(a_dl, slots[0].x, slots[0].y, t, L, exposureT.shown, Lerp(iceLight, iceDeep, fExposure), alpha * pulse);
				iconAt(0, kExposure);
			}
			if (s.showWetness) {
				DrawBar(a_dl, slots[1].x, slots[1].y, t, L, wetnessT.shown, { 80, 190, 210 }, alpha);
				iconAt(1, kWetness);
			}
			if (s.showTemperature) {
				DrawBar(a_dl, slots[2].x, slots[2].y, t, L, tempT.shown, Lerp(cold, warm, fTemp), alpha);
				iconAt(2, kTemperature);
			}
			if (s.showWarmth) {  // warmth (left half) and coverage (right half) share the 4th slot
				const float half = std::max(1.0f, (t - 2.0f * k) * 0.5f);
				DrawBar(a_dl, slots[3].x, slots[3].y, half, L, warmthT.shown, { 235, 155, 75 }, alpha);
				DrawBar(a_dl, slots[3].x + t - half, slots[3].y, half, L, coverageT.shown, { 165, 185, 205 }, alpha);
				iconAt(3, kWarmth);
			}
		}

		void DrawLogo(ImDrawList* a_dl, float a_dt)
		{
			if (logoRequested.exchange(false)) {
				logoTime = 0.0f;
			}
			if (logoTime < 0.0f) {
				return;
			}
			logoTime += a_dt;
			const float total = kLogoFadeIn + kLogoHold + kLogoFadeOut;
			if (logoTime >= total) {
				logoTime = -1.0f;
				return;
			}
			float a = 1.0f;
			if (logoTime < kLogoFadeIn) {
				a = logoTime / kLogoFadeIn;
			} else if (logoTime > kLogoFadeIn + kLogoHold) {
				a = 1.0f - (logoTime - kLogoFadeIn - kLogoHold) / kLogoFadeOut;
			}
			a = a * a * (3.0f - 2.0f * a);  // smoothstep

			static ImTextureID tex = SKSEMenuFramework::LoadTexture(kLogoPath);
			if (!tex) {
				return;
			}
			const auto* io = GetIO();
			const float w = std::min(io->DisplaySize.x * 0.34f, 900.0f);
			const float h = w * kLogoAspect;
			const float x = (io->DisplaySize.x - w) * 0.5f;
			const float y = io->DisplaySize.y * 0.24f;
			const float drift = (1.0f - a) * 6.0f;  // settles upward slightly as it fades in
			ImDrawListManager::AddImage(a_dl, tex, ImVec2(x + 2, y + 3 + drift), ImVec2(x + w + 2, y + h + 3 + drift), ImVec2(0, 0), ImVec2(1, 1), Col(0, 0, 0, 0.65f * a));
			ImDrawListManager::AddImage(a_dl, tex, ImVec2(x, y + drift), ImVec2(x + w, y + h + drift), ImVec2(0, 0), ImVec2(1, 1), Col(200, 218, 240, a));
		}
	}

	void ShowStartupLogo()
	{
		logoRequested = true;
		SKSE::log::info("Start-up logo requested");
	}

	void MarkPreviewFrame() { previewFrames = 2; }

	void MarkSettingsDirty() { saveTimer = 0.6f; }

	void __stdcall Render()
	{
		const float dt = std::clamp(GetIO()->DeltaTime, 0.0f, 0.1f);

		if (saveTimer >= 0.0f) {
			saveTimer -= dt;
			if (saveTimer < 0.0f) {
				Settings::Get().Save();
			}
		}

		const bool preview = previewFrames > 0;
		if (previewFrames > 0) {
			--previewFrames;
		}

		auto* dl = GetForegroundDrawList();
		if (!preview && (SKSEMenuFramework::IsAnyBlockingWindowOpened() || HudHiddenByGame())) {
			return;
		}

		DrawLogo(dl, dt);

		auto& s = Settings::Get();
		if (!Game::IsRunning()) {
			return;
		}
		if (!meterModeChecked) {
			meterModeChecked = true;
			Game::RestoreMeterMode();
		}
		if (s.hudEnabled) {
			DrawBars(dl, dt, preview);
		}
	}
}
