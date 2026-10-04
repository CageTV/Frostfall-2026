/*
 * Frostfall 2026
 * Copyright (C) 2026 CageTV
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or (at your option) any later version. It is distributed WITHOUT ANY
 * WARRANTY; see LICENSE.txt for the full text.
 */
#pragma once

// Frostfall's game data as the plugin sees it: the globals behind the bars, and the Papyrus entry points.
namespace Game
{
	struct Globals
	{
		RE::TESGlobal* running = nullptr;       // FrostfallRunning (2 = running)
		RE::TESGlobal* exposure = nullptr;      // _Frost_AttributeExposureMeter
		RE::TESGlobal* exposureMax = nullptr;   // _Frost_AttributeExposureMax
		RE::TESGlobal* wetness = nullptr;       // _Frost_AttributeWetness
		RE::TESGlobal* wetnessMax = nullptr;    // _Frost_AttributeWetnessMax
		RE::TESGlobal* tempLevel = nullptr;     // _Frost_AttributeMeterTempLevel (higher = warmer)
		RE::TESGlobal* tempLevelMax = nullptr;  // _Frost_AttributeMeterTempLevelMax
		RE::TESGlobal* warmth = nullptr;        // _Frost_AttributeWarmth
		RE::TESGlobal* warmthMax = nullptr;     // _Frost_Calc_MaxWarmth
		RE::TESGlobal* coverage = nullptr;      // _Frost_AttributeCoverage
		RE::TESGlobal* coverageMax = nullptr;   // _Frost_Calc_MaxCoverage
		RE::TESGlobal* meterMode = nullptr;     // _Frost_Setting_MeterDisplayMode (0 off, 1 always, 2 contextual)
	};

	bool           Init();  // after data is loaded
	const Globals& G();
	bool           Ready();
	bool           IsRunning();
	float          Value(const RE::TESGlobal* a_global, float a_fallback = 0.0f);

	// Queue on the game's main thread
	void StartFrostfall();
	void StopFrostfall();
	void RefreshOldMeters();  // the HUD bars were switched on or off: hide Frostfall's SkyUI meters, or bring them back
	void RestoreMeterMode();  // put back the meter display mode an older Frostfall.dll switched off (once)
}
