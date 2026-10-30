/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#pragma once

// Frostfall's HUD, drawn through SKSE Menu Framework's HUD API: four flat vertical bars (exposure, wetness,
// temperature, warmth + coverage) and the start-up logo that fades in and out when Frostfall starts.
namespace Hud
{
	void __stdcall Render();

	void ShowStartupLogo();

	// The settings page calls this every frame it is visible, so the bars stay drawn (as a live preview) while
	// SKSE Menu Framework's window is open.
	void MarkPreviewFrame();

	// What the mouse can move while the settings page is open (not saved): -1 = nothing is unlocked, 0..3 = that one bar (free layout),
	// 4 = the whole group (grid / row layouts).
	int& EditTarget();

	// Mark settings as changed; they are written to the INI shortly after the last change.
	void MarkSettingsDirty();

	// Write any setting change that is still waiting for its short delay (called when the game is saved, so nothing is lost on a quick exit).
	void FlushSettings();
}
