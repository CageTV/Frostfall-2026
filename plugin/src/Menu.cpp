/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#include "PCH.h"
#include "Menu.h"
#include "Game.h"
#include "ItemCard.h"
#include "Hud.h"
#include "NativeMcm.h"
#include "Settings.h"

#include "SKSEMenuFramework.h"

namespace Menu
{
	namespace
	{
		using namespace ImGuiMCP;

		constexpr const char* kLogoPath = "Data\\Interface\\frostfall\\frostfall_logo.png";

		void Logo()
		{
			static ImTextureID tex = SKSEMenuFramework::LoadTexture(kLogoPath);
			if (!tex) {
				return;
			}
			const float avail = GetContentRegionAvail().x;
			const float w = std::min(avail, 460.0f);
			SetCursorPosX(GetCursorPosX() + (avail - w) * 0.5f);
			Image(tex, ImVec2(w, w * 100.0f / 460.0f), ImVec2(0, 0), ImVec2(1, 1), ImVec4(0.80f, 0.86f, 0.95f, 1.0f));
			Spacing();
		}

		bool Changed(bool a_changed)
		{
			if (a_changed) {
				Hud::MarkSettingsDirty();
			}
			return a_changed;
		}

		template <class F>
		bool Changed(bool a_changed, F&& a_after)
		{
			if (Changed(a_changed)) {
				a_after();
			}
			return a_changed;
		}

		void __stdcall RenderOverview()
		{
			auto& s = Settings::Get();
			Logo();

			if (!Game::Ready()) {
				TextColored(ImVec4(1.0f, 0.45f, 0.4f, 1.0f), "Frostfall.esp is not loaded.");
				return;
			}

			const bool running = Game::IsRunning();
			if (running) {
				TextColored(ImVec4(0.55f, 0.85f, 1.0f, 1.0f), "Frostfall is running.");
			} else {
				TextColored(ImVec4(0.75f, 0.75f, 0.75f, 1.0f), "Frostfall is not running.");
			}
			SameLine();
			if (Button(running ? "Stop Frostfall" : "Start Frostfall")) {
				OpenPopup("Frostfall##confirm");
			}
			if (BeginPopupModal("Frostfall##confirm", nullptr, ImGuiWindowFlags_AlwaysAutoResize)) {
				Text(running ? "Stop Frostfall? Exposure, wetness and all survival effects will be turned off." :
				               "Start Frostfall now?");
				if (Button("Yes", ImVec2(120, 0))) {
					running ? Game::StopFrostfall() : Game::StartFrostfall();
					CloseCurrentPopup();
				}
				SameLine();
				if (Button("Cancel", ImVec2(120, 0))) {
					CloseCurrentPopup();
				}
				EndPopup();
			}

			Spacing();
			Changed(Checkbox("Start automatically on new games", &s.autoStart));
			TextWrapped("Frostfall starts the first time you step outside, after character creation and any intro. "
			            "It never restarts a game where Frostfall was stopped on purpose.");

			Spacing();
			Separator();
			Text("Right now");
			const auto& g = Game::G();
			Text("Exposure     %.0f / %.0f", Game::Value(g.exposure), Game::Value(g.exposureMax, 100.0f));
			Text("Wetness      %.0f / %.0f", Game::Value(g.wetness), Game::Value(g.wetnessMax, 750.0f));
			Text("Temperature  %.0f / %.0f", Game::Value(g.tempLevel), Game::Value(g.tempLevelMax, 10.0f));
			Text("Warmth       %.0f", Game::Value(g.warmth));
			Text("Coverage     %.0f", Game::Value(g.coverage));

			Spacing();
			Separator();
			TextWrapped("Frostfall's settings are on the pages in this section: Gameplay, Interface, HUD, Advanced and Profiles. "
			            "Only the Equipment page (the per-armor warmth and coverage editor) is still in the SkyUI Mod Configuration Menu.");
		}

		void __stdcall RenderGameplay() { NativeMcm::DrawPage(0); }
		void __stdcall RenderInterface() { NativeMcm::DrawPage(1); }

		void __stdcall RenderAdvanced()
		{
			NativeMcm::DrawPage(2);
			NativeMcm::DrawAdvancedExtras();
		}

		void __stdcall RenderProfiles() { NativeMcm::DrawProfiles(); }

		// Drawn every frame whether or not the menu is open: flushes profile writes a moment after the last change, then draws the bars.
		void __stdcall Frame()
		{
			NativeMcm::Tick(std::clamp(GetIO()->DeltaTime, 0.0f, 0.1f));
			Hud::Render();
		}

		void __stdcall RenderHud()
		{
			auto& s = Settings::Get();
			Hud::MarkPreviewFrame();  // keep the bars visible while this page is open
			if ((s.layout == 2 && Hud::EditTarget() == 4) || (s.layout != 2 && Hud::EditTarget() >= 0 && Hud::EditTarget() < 4)) {
				Hud::EditTarget() = -1;  // the layout changed under an unlocked bar
			}

			Changed(Checkbox("Show Frostfall bars", &s.hudEnabled), [] { Game::RefreshOldMeters(); });
			TextWrapped("While on, these replace Frostfall's SkyUI meters. Turning them off brings the SkyUI meters back.");
			Changed(Checkbox("Show warmth and coverage on the item card", &s.itemCardValues));
			Spacing();

			BeginDisabled(!s.hudEnabled);
			static const char* displayModes[] = { "Always", "Contextual (fade out while comfortable)" };
			Changed(Combo("Display", &s.displayMode, displayModes, 2));
			if (s.displayMode == 1) {
				Changed(SliderFloat("Stay visible after a change (s)", &s.contextualSeconds, 1.0f, 30.0f, "%.0f"));
				Changed(SliderFloat("A change counts after (% of the bar)", &s.changePercent, 0.1f, 20.0f, "%.1f"));
				if (IsItemHovered()) {
					SetTooltip("A bar only counts as changed once it has moved this far. Raise it if the bars never fade because a value creeps a little all the time.");
				}
				Changed(SliderFloat("Stay visible while exposure is above (%)", &s.stayExposurePercent, 0.0f, 100.0f, "%.0f"));
				Changed(SliderFloat("Stay visible while wetness is above (%)", &s.stayWetnessPercent, 0.0f, 100.0f, "%.0f"));
				if (IsItemHovered()) {
					SetTooltip("100 means the bars never stay up because of this. Set both to 100 and the bars show only when something changes.");
				}
			}
			static const char* layouts[] = { "2 x 2 grid", "Single row", "Free (place every bar yourself)" };
			Changed(Combo("Layout", &s.layout, layouts, 3));

			Spacing();
			Separator();
			Text("Position and size");
			if (s.layout != 2) {
				static const char* orientations[] = { "Standing bars", "Bars lying flat" };
				Changed(Combo("Direction", &s.orientation, orientations, 2));
				Changed(Checkbox("Flip: fill from the other end", &s.flipFill));
				if (IsItemHovered()) {
					SetTooltip("Standing bars fill from the top instead of the bottom, flat bars from the right instead of the left. The icons move to that end.");
				}
				Changed(SliderFloat("Horizontal (right edge)", &s.posX, 0.0f, 1.0f, "%.3f"));
				Changed(SliderFloat("Vertical (centre)", &s.posY, 0.0f, 1.0f, "%.3f"));
				if (Hud::EditTarget() == 4) {
					if (Button("Lock the group")) {
						Hud::EditTarget() = -1;
					}
					SameLine();
					TextDisabled("Unlocked: click the bars on the screen and drag the whole group.");
				} else if (Button("Unlock to move the group with the mouse")) {
					Hud::EditTarget() = 4;
				}
			}
			Changed(SliderFloat("Scale", &s.scale, 0.5f, 3.0f, "%.2f"));
			Changed(SliderFloat("Bar length", &s.barLength, 30.0f, 400.0f, "%.0f"));
			Changed(SliderFloat("Bar thickness", &s.barThickness, 3.0f, 30.0f, "%.0f"));
			Changed(SliderFloat("Spacing", &s.spacing, 2.0f, 40.0f, "%.0f"));
			Changed(SliderFloat("Opacity", &s.opacity, 0.1f, 1.0f, "%.2f"));

			if (s.layout == 2) {
				Spacing();
				Separator();
				Text("Each bar");
				TextWrapped("Unlock one bar at a time, then click it on the screen and drag it where you want it. The sliders do the same, to the pixel.");
				static const char* names[Settings::kBars] = { "Exposure", "Wetness", "Temperature", "Warmth and coverage" };
				static const char* orients[] = { "Standing", "Lying flat" };
				for (int n = 0; n < Settings::kBars; ++n) {
					auto& fb = s.freeBar[n];
					PushID(n);
					Separator();
					Text("%s", names[n]);
					if (Hud::EditTarget() == n) {
						if (Button("Lock")) {
							Hud::EditTarget() = -1;
						}
						SameLine();
						TextDisabled("Unlocked: drag it on the screen.");
					} else if (Button("Unlock to move with the mouse")) {
						Hud::EditTarget() = n;
					}
					Changed(SliderFloat("Horizontal", &fb.x, 0.0f, 1.0f, "%.3f"));
					Changed(SliderFloat("Vertical", &fb.y, 0.0f, 1.0f, "%.3f"));
					Changed(Combo("Direction", &fb.orient, orients, 2));
					Changed(Checkbox("Flip: fill from the other end", &fb.flip));
					float length = fb.length > 0.0f ? fb.length : s.barLength;
					if (Changed(SliderFloat("Length", &length, 30.0f, 400.0f, "%.0f"))) {
						fb.length = length;
					}
					float thickness = fb.thickness > 0.0f ? fb.thickness : s.barThickness;
					if (Changed(SliderFloat("Thickness", &thickness, 3.0f, 30.0f, "%.0f"))) {
						fb.thickness = thickness;
					}
					PopID();
				}
			}

			Spacing();
			Separator();
			Text("Bars");
			Changed(Checkbox("Exposure (cold)", &s.showExposure));
			Changed(Checkbox("Wetness", &s.showWetness));
			Changed(Checkbox("Temperature", &s.showTemperature));
			Changed(Checkbox("Warmth and coverage", &s.showWarmth));
			Changed(Checkbox("Icons under the bars", &s.showIcons));
			EndDisabled();

			Spacing();
			if (Button("Reset position and size")) {
				s.ResetHudLayout();
				Hud::MarkSettingsDirty();
			}

			Spacing();
			Separator();
			Text("Item cards");
			TextWrapped("Switched on or off at the top of this page. Hover armor or clothing in the inventory or a container: Frostfall's own warmth and coverage numbers for it appear on a line below the item card, "
						"on the right. While this page is open a sample line shows, so you can place it without opening the inventory. "
						"Not drawn when Frostfall's SkyUI item-card package is installed.");
			BeginDisabled(!s.itemCardValues);
			Changed(SliderFloat("Line position: horizontal (centre)", &s.cardX, 0.0f, 1.0f, "%.3f"));
			Changed(SliderFloat("Line position: vertical", &s.cardY, 0.0f, 1.0f, "%.3f"));
			Changed(SliderFloat("Text size", &s.cardSize, 10.0f, 80.0f, "%.0f"));
			if (ItemCard::GridInventoryFound()) {
				TextWrapped("Grid Inventory is installed. It does not say which item the cursor is on, so with it the line shows what you are wearing (Frostfall's totals), at the lower left:");
				Changed(SliderFloat("Grid Inventory: horizontal (centre)", &s.cardGridX, 0.0f, 1.0f, "%.3f"));
				Changed(SliderFloat("Grid Inventory: vertical", &s.cardGridY, 0.0f, 1.0f, "%.3f"));
			}
			if (Button("Reset line positions and size")) {
				const Settings d;
				s.cardX = d.cardX;
				s.cardY = d.cardY;
				s.cardSize = d.cardSize;
				s.cardGridX = d.cardGridX;
				s.cardGridY = d.cardGridY;
				Hud::MarkSettingsDirty();
			}
			EndDisabled();
		}
	}

	namespace
	{
		std::atomic<bool> registered{ false };
	}

	bool Registered() { return registered; }

	void Register()
	{
		if (!SKSEMenuFramework::IsInstalled()) {
			SKSE::log::warn("SKSE Menu Framework not found: no HUD bars, logo or settings page (Frostfall falls back to its SkyUI meters and messages)");
			return;
		}
		SKSEMenuFramework::SetSection("Frostfall");
		SKSEMenuFramework::AddSectionItem("Overview", RenderOverview);
		SKSEMenuFramework::AddSectionItem("Gameplay", RenderGameplay);
		SKSEMenuFramework::AddSectionItem("Interface", RenderInterface);
		SKSEMenuFramework::AddSectionItem("HUD", RenderHud);
		SKSEMenuFramework::AddSectionItem("Advanced", RenderAdvanced);
		SKSEMenuFramework::AddSectionItem("Profiles", RenderProfiles);
		SKSEMenuFramework::AddHudElement(Frame);
		registered = true;
		SKSE::log::info("Registered with SKSE Menu Framework {}", SKSEMenuFramework::GetMenuFrameworkVersion());
	}
}
