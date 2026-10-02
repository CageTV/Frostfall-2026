#pragma once

// Frostfall.dll settings, stored in Data/SKSE/Plugins/Frostfall.ini (edited from the SKSE Menu Framework page).
struct Settings
{
	// [General]
	bool autoStart = true;  // start Frostfall the first time the player steps outside on a new game

	// [HUD]
	bool  hudEnabled = true;
	int   displayMode = 1;           // 0 = always, 1 = contextual (fade out while comfortable and unchanged)
	int   layout = 0;                // 0 = 2 x 2 grid, 1 = single row
	float posX = 0.975f;             // right edge of the bar group, fraction of screen width
	float posY = 0.50f;              // vertical centre of the bar group, fraction of screen height
	float scale = 1.0f;
	float opacity = 0.90f;
	float barLength = 96.0f;         // pixels at 1080p, before scale
	float barThickness = 8.0f;
	float spacing = 10.0f;
	float contextualSeconds = 6.0f;
	bool  showExposure = true;
	bool  showWetness = true;
	bool  showTemperature = true;
	bool  showWarmth = true;         // the 4th slot: warmth and coverage side by side
	bool  showIcons = true;

	// Frostfall's own SkyUI meter display mode, remembered while the HUD bars replace those meters (-1 = none saved)
	int savedMeterMode = -1;

	// INI layout version. 2: contextual display became the default (older INIs are moved to it once).
	static constexpr int kVersion = 2;

	static Settings& Get();
	void Load();
	void Save() const;
	void ResetHudLayout();
};
