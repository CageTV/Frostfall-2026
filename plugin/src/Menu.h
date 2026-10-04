/*
 * Frostfall 2026
 * Copyright (C) 2026 CageTV
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or (at your option) any later version. It is distributed WITHOUT ANY
 * WARRANTY; see LICENSE.txt for the full text.
 */
#pragma once

// Frostfall's page in SKSE Menu Framework: status, start / stop, auto-start, and the HUD bar options.
namespace Menu
{
	void Register();    // after all SKSE plugins are loaded (kPostLoad)
	bool Registered();  // true once the page and the HUD element are registered with SKSE Menu Framework
}
