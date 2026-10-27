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
#include "BarKit.h"

namespace Hud
{
	namespace
	{
		using namespace ImGuiMCP;
		using namespace BarKit;

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
		int               editTarget = -1;  // see Hud::EditTarget
		int               dragBar = -1;

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

		// a_threshold: how far the value must move from the last reference to count as a change (fraction of its range). Slow steady drift, such as
		// exposure creeping up a little every second, then stops resetting the contextual timer; a step or a bigger move still does.
		void Track(Tracked& a_t, float a_frac, float a_dt, float a_threshold)
		{
			if (a_t.shown < 0.0f) {
				a_t.shown = a_frac;
				a_t.last = a_frac;
			}
			if (std::abs(a_frac - a_t.last) > a_threshold) {
				a_t.sinceChange = 0.0f;
				a_t.last = a_frac;
			} else {
				a_t.sinceChange += a_dt;
			}
			a_t.shown += (a_frac - a_t.shown) * std::min(1.0f, a_dt * 6.0f);  // smooth fill movement
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

		void IconFor(ImDrawList* a_dl, Icon a_icon, const Bar& a_b, float a_k, float a_alpha) { DrawIconFor(a_dl, IconTexture(a_icon), a_b, a_k, a_alpha); }

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

		Group GroupOf(const Settings& s)
		{
			Group g;
			g.layout = s.layout;
			g.orientation = s.orientation;
			g.flip = s.flipFill;
			g.icons = s.showIcons;
			g.thickness = s.barThickness;
			g.length = s.barLength;
			g.spacing = s.spacing;
			g.posX = s.posX;
			g.posY = s.posY;
			return g;
		}

		void DrawBars(ImDrawList* a_dl, float a_dt, bool a_preview, bool a_demo)
		{
			auto&       s = Settings::Get();
			const auto& g = Game::G();
			const auto* io = GetIO();
			const float W = io->DisplaySize.x;
			const float H = io->DisplaySize.y;
			const float k = (H / 1080.0f) * s.scale;

			// While the settings page is open before Frostfall is running, sample values stand in so the bars can still be placed.
			const float fExposure = a_demo ? 0.55f : Frac(g.exposure, g.exposureMax, 100.0f);
			const float fWet = a_demo ? 0.35f : Frac(g.wetness, g.wetnessMax, 750.0f);
			const float fTemp = a_demo ? 0.62f : Frac(g.tempLevel, g.tempLevelMax, 10.0f);
			const float fWarmth = a_demo ? 0.70f : Frac(g.warmth, g.warmthMax, 550.0f);
			const float fCoverage = a_demo ? 0.50f : Frac(g.coverage, g.coverageMax, 360.0f);
			const float thr = std::max(0.001f, s.changePercent / 100.0f);
			Track(exposureT, fExposure, a_dt, thr);
			Track(wetnessT, fWet, a_dt, thr);
			Track(tempT, fTemp, a_dt, thr);
			Track(warmthT, fWarmth, a_dt, thr);
			Track(coverageT, fCoverage, a_dt, thr);

			// Contextual: stay visible while something changed recently or the player is not comfortable
			float target = 1.0f;
			if (s.displayMode == 1 && !a_preview) {
				const float recent = std::min({ exposureT.sinceChange, wetnessT.sinceChange, tempT.sinceChange, warmthT.sinceChange, coverageT.sinceChange });
				const bool  uncomfortable = fExposure * 100.0f > s.stayExposurePercent || fWet * 100.0f > s.stayWetnessPercent;
				target = (recent < s.contextualSeconds || uncomfortable) ? 1.0f : 0.0f;
			}
			groupAlpha += (target - groupAlpha) * std::min(1.0f, a_dt * 3.0f);
			const float alpha = groupAlpha * s.opacity;
			if (alpha < 0.01f) {
				return;
			}

			Bar slots[4];
			if (s.layout == 2) {
				Placed placed[4];
				for (int i = 0; i < 4; ++i) {
					placed[i] = { s.freeBar[i].x, s.freeBar[i].y, s.freeBar[i].orient, s.freeBar[i].flip, s.freeBar[i].length, s.freeBar[i].thickness };
				}
				FreeSlots(placed, s.barThickness, s.barLength, W, H, k, slots);
			} else {
				GroupedSlots(GroupOf(s), W, H, k, slots);
			}

			const Rgb iceLight{ 175, 215, 255 }, iceDeep{ 70, 135, 255 };
			const Rgb cold{ 105, 160, 255 }, warm{ 255, 175, 85 };
			const float pulse = fExposure >= 0.8f ? 0.75f + 0.25f * std::sin(static_cast<float>(ImGuiMCP::GetTime()) * 5.0f) : 1.0f;

			auto iconAt = [&](int a_slot, Icon a_icon) {
				if (s.showIcons) {
					IconFor(a_dl, a_icon, slots[a_slot], k, alpha);
				}
			};

			if (s.showExposure) {
				DrawBar(a_dl, slots[0], exposureT.shown, Lerp(iceLight, iceDeep, fExposure), alpha * pulse);
				iconAt(0, kExposure);
			}
			if (s.showWetness) {
				DrawBar(a_dl, slots[1], wetnessT.shown, { 80, 190, 210 }, alpha);
				iconAt(1, kWetness);
			}
			if (s.showTemperature) {
				DrawBar(a_dl, slots[2], tempT.shown, Lerp(cold, warm, fTemp), alpha);
				iconAt(2, kTemperature);
			}
			if (s.showWarmth) {  // warmth and coverage share the 4th slot: side by side when standing, one above the other when flat
				const Bar& sl = slots[3];
				Bar        a = sl, c = sl;
				if (!sl.horizontal) {
					const float half = std::max(1.0f, (sl.w - 2.0f * k) * 0.5f);
					a.w = c.w = half;
					c.x = sl.x + sl.w - half;
				} else {
					const float half = std::max(1.0f, (sl.h - 2.0f * k) * 0.5f);
					a.h = c.h = half;
					c.y = sl.y + sl.h - half;
				}
				DrawBar(a_dl, a, warmthT.shown, { 235, 155, 75 }, alpha);
				DrawBar(a_dl, c, coverageT.shown, { 165, 185, 205 }, alpha);
				iconAt(3, kWarmth);
			}

			if (a_preview && editTarget >= 0) {
				float dx = 0, dy = 0;
				if (s.layout == 2 && editTarget < 4) {  // one unlocked bar
					const int moved = HandleDrag(a_dl, slots, 4, dragBar, W, H, dx, dy, editTarget);
					if (moved >= 0) {
						auto& fb = s.freeBar[moved];
						fb.x = std::clamp(fb.x + dx, 0.0f, 1.0f);
						fb.y = std::clamp(fb.y + dy, 0.0f, 1.0f);
						MarkSettingsDirty();
					}
				} else if (s.layout != 2 && editTarget == 4) {  // the whole group
					const Bar bounds = Bounds(slots, 4, 14.0f * k);
					const int moved = HandleDrag(a_dl, &bounds, 1, dragBar, W, H, dx, dy);
					if (moved >= 0) {
						s.posX = std::clamp(s.posX + dx, 0.0f, 1.0f);
						s.posY = std::clamp(s.posY + dy, 0.0f, 1.0f);
						MarkSettingsDirty();
					}
				} else {
					dragBar = -1;
				}
			} else {
				dragBar = -1;
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

	int& EditTarget() { return editTarget; }

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

		auto&      s = Settings::Get();
		const bool running = Game::IsRunning();
		if (!running && !preview) {
			return;
		}
		if (running && !meterModeChecked) {
			meterModeChecked = true;
			Game::RestoreMeterMode();
		}
		if (s.hudEnabled) {
			DrawBars(dl, dt, preview, !running);
		}
	}
}
