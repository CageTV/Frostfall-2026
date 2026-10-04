/*
 * Frostfall 2026
 * Copyright (C) 2026 CageTV
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or (at your option) any later version. It is distributed WITHOUT ANY
 * WARRANTY; see LICENSE.txt for the full text.
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

	// Mark settings as changed; they are written to the INI shortly after the last change.
	void MarkSettingsDirty();
}
