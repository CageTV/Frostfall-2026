/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#pragma once

// Frostfall's page in SKSE Menu Framework: status, start / stop, auto-start, and the HUD bar options.
namespace Menu
{
	void Register();    // after all SKSE plugins are loaded (kPostLoad)
	bool Registered();  // true once the page and the HUD element are registered with SKSE Menu Framework
}
