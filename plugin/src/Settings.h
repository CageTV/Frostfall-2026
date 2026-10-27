/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#pragma once

// Frostfall.dll settings, stored in Data/SKSE/Plugins/Frostfall.ini (edited from the SKSE Menu Framework page).
struct Settings
{
	// [General]
	bool autoStart = true;  // start Frostfall the first time the player steps outside on a new game

	// [HUD]
	bool  hudEnabled = true;
	int   displayMode = 1;           // 0 = always, 1 = contextual (fade out while comfortable and unchanged)
	int   layout = 0;                // 0 = 2 x 2 grid, 1 = single row (one column when the bars lie flat), 2 = free: every bar placed on its own
	int   orientation = 0;           // grouped layouts: 0 = standing bars, 1 = bars lying flat
	bool  flipFill = false;          // grouped layouts: fill from the other end (top / right)
	float posX = 0.975f;             // right edge of the bar group, fraction of screen width
	float posY = 0.50f;              // vertical centre of the bar group, fraction of screen height
	float scale = 1.0f;
	float opacity = 0.90f;
	float barLength = 96.0f;         // pixels at 1080p, before scale
	float barThickness = 8.0f;
	float spacing = 10.0f;
	float contextualSeconds = 6.0f;
	float changePercent = 2.0f;      // contextual: a bar counts as changed only after it has moved by this share of its range (%)
	float stayExposurePercent = 40.0f;  // contextual: stay visible while exposure is above this (%); 100 = never because of exposure
	float stayWetnessPercent = 10.0f;   // contextual: stay visible while wetness is above this (%); 100 = never because of wetness
	bool  showExposure = true;
	bool  showWetness = true;
	bool  showTemperature = true;
	bool  showWarmth = true;         // the 4th slot: warmth and coverage side by side
	bool  showIcons = true;

	// Free layout (layout 2): where each bar sits (its centre, fractions of the screen), whether it lies flat, and which end it fills from.
	// Order: exposure, wetness, temperature, warmth + coverage.
	static constexpr int kBars = 4;
	struct FreeBar
	{
		float x = 0.975f;
		float y = 0.5f;
		int   orient = 0;  // 0 = standing, 1 = lying flat
		bool  flip = false;
	};
	FreeBar freeBar[kBars] = { { 0.975f, 0.40f, 0, false }, { 0.945f, 0.40f, 0, false }, { 0.975f, 0.60f, 0, false }, { 0.945f, 0.60f, 0, false } };

	// Frostfall's own SkyUI meter display mode, remembered while the HUD bars replace those meters (-1 = none saved)
	int savedMeterMode = -1;

	// INI layout version. 2: contextual display became the default (older INIs are moved to it once).
	static constexpr int kVersion = 2;

	static Settings& Get();
	void Load();
	void Save() const;
	void ResetHudLayout();
};
