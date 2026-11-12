/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#pragma once

// Frostfall's fire and frost damage monitor, native.
//
// _Frost_PlayerSpellMonitor only cares about effects that carry the vanilla MagicDamageFire or MagicDamageFrost keyword
// and are applied to the player. The vanilla OnMagicEffectApply event raises a script call for EVERY effect applied to the
// player (potions, abilities, enchantments, other mods' cloaks); Papyrus Extender's filtered event avoided that but made
// Papyrus Extender a requirement. This plugin listens to the game's effect-applied event itself, checks target and keyword
// in native code, and raises the SKSE mod event "Frostfall_PlayerMagicDamage" only for a match. numArg: 1 = fire,
// 2 = frost, 3 = both keywords. The script keeps all the gameplay logic (wetness, exposure, the 4 second locks).
namespace SpellMonitor
{
	void Register();  // after data is loaded and Game::Init() has run
}
