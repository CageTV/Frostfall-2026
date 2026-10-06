/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#pragma once

// Frostfall's settings pages, drawn through SKSE Menu Framework instead of the SkyUI MCM. They are built from McmTable.h (generated from
// Frostfall's own MCM script) and do what the MCM does: write the setting's global, write the active profile file (through PapyrusUtil's
// JsonUtil, exactly like the MCM), and for the few settings with side effects (the hotkey, the Endurance skill) call the menu script's helpers.
// Only the Equipment page (a per-armor editor) is left in the SkyUI menu.
namespace NativeMcm
{
	// One page of McmTable.h (an index into mcm::kPages). Shows a note instead while Frostfall is not running.
	void DrawPage(int a_page);

	// The Endurance skill's respec and restore options, and the tutorial reset (the rest of the Advanced page).
	void DrawAdvancedExtras();

	// Frostfall's settings profiles: pick, rename, reset, and switch automatic saving on or off.
	void DrawProfiles();

	// Once per frame: writes pending profile changes a moment after the last edit (like dragging a slider).
	void Tick(float a_dt);
}
