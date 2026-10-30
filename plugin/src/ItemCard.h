/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#pragma once

// Warmth and coverage of the armor under the cursor, drawn over the item card of the inventory and container lists. Frostfall's own
// numbers: asked from Frostfall's armor datastore (FrostfallItemCard.ItemProtection) so they match what the HUD bars add up. Skipped when
// Frostfall's SkyUI item-card package is installed (it already shows them). Drawn with SKSE Menu Framework's draw list.
#include "SKSEMenuFramework.h"

namespace ItemCard
{
	// Render thread, once per frame, inside SKSE Menu Framework's HUD callback. a_dl is the foreground draw list.
	// Once from plugin load: listens for Grid Inventory announcing itself.
	void Register();

	// Grid Inventory is installed (it has announced itself): the line then shows what the player wears, at the lower left.
	bool GridInventoryFound();

	// a_preview: the settings page is open, draw a sample line so it can be placed.
	void Draw(ImGuiMCP::ImDrawList* a_dl, float a_displayW, float a_displayH, bool a_preview);
}
