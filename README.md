# Frostfall 2026

An update layer for Chesko's **Frostfall – Hypothermia, Camping, Survival 3.4.1 SE** (Skyrim Special Edition / Anniversary
Edition 1.6.x). Version **4.1.0 (pre-release)**. The plugin file keeps its original name, `Frostfall.esp`.

It goes **on top of** the original Frostfall (Nexus 671) and Campfire (Nexus 667), which still supply every mesh and
texture. It is not a replacement and it does not contain anyone else's meshes, textures or shaders.

What it adds: Frostfall starts on its own on a new game, with a logo fade-in; a new HUD (four bars) and all of Frostfall's settings (gameplay, interface, advanced, profiles) in
SKSE Menu Framework (only the per-armor Equipment page stays in SkyUI); the community's script fixes folded in; Embers XD fires warm you; and a "Make Camp" makeshift
shelter that uses the Creation Club Camping lean-to by reference. Full details, requirements and install steps are in
[`release-contents/README.txt`](release-contents/README.txt).

**Pre-release.** A new game is recommended. Carrying an existing save over from Frostfall 3.4.1 has not been tested.

## Download

Get **Frostfall 2026** from the [Releases](../../releases) page. It is one FOMOD installer that first asks **Regular or ESL**, and installs
the matching plugin, scripts and `Frostfall.dll`. Install it with your mod manager *after* the original Frostfall and Campfire.
Install order: Campfire (original), [Campfire 2026](https://github.com/CageTV/Campfire-2026), Frostfall (original), Frostfall 2026, then
Last Seed 2026. Frostfall 2026 deliberately overrides one Campfire script (`CampCampfire.pex`, the same script plus the Make Camp offer).

Two more mods live in this repository, each with its own release:

- **Frostfall 2026 - Leather Tent** (optional add-on, one FOMOD with Regular or ESL): adds a leather camp to the Make Camp menu (4 Branches,
  1 Linen Wrap, 2 Leather) that shelters better than the simple camp. An ESL-flagged plugin with one mesh, the small hide tent mesh by
  Tumbajamba (modified, used with permission), so it is kept out of the main download. Install it after Frostfall 2026 and pick the same build.
- **Frostfall - No Gear Display Dupes**: a one-script fix for Campfire. Campfire lays a real copy of your gear next to the
  bedroll when you rest in a tent, and pickup mods can take it, duplicating the item; this stops the copy being made.
  Scripts only; works with or without Frostfall 2026. Optional: install it after Gotobed (Go To Bed) if you use that mod.

## ESL build (Frostfall.esp and Campfire.esm both as light plugins)

For a load order short of plugin slots, pick **ESL** in the installer. Use it with the ESL option of
[Campfire 2026](https://github.com/CageTV/Campfire-2026) so that Frostfall and Campfire together take no regular plugin slot. It is a separate
build, not an add-on to the normal one:

- **Frostfall 2026, ESL option**: Frostfall.esp flagged ESL (its 1110 records renumbered to 000800 upward) and its own `Frostfall.dll`.
- **Frostfall 2026 - Leather Tent, ESL option**: the leather camp add-on for the ESL pair.
- **Campfire ESL - Script Fixes** (an older separate release here) is no longer needed: Campfire 2026's ESL option replaces it.

Use it for a **new game**: because the FormIDs changed, saves from the normal build do not carry over, and patches that point into
Frostfall.esp's records do not work with it. Anything you generated against the normal build (Synthesis, PGPatcher and the like) must be
regenerated.

## Layout of this repository

| Path | What it is |
|---|---|
| `release-contents/` | Exactly what is in the Frostfall 2026 release zip (the files players install) |
| `release-contents-leather-tent/` | Exactly what is in the Leather Tent add-on zip |
| `addon-leather/` | The add-on's plugin as Spriggit YAML, and its mesh |
| `release-contents-esl/`, `release-contents-leather-tent-esl/`, `release-contents-campfire-esl-script-fixes/` | Exactly what is in the three ESL zips |
| `esl/` | The Campfire and Frostfall FormID maps the ESL build uses (old id -> new id) |
| `release-contents-no-gear-dupes/` | Exactly what is in the No Gear Display Dupes zip (script, its source, README, licence) |
| `nodupe/` | Compile-only stub for Go To Bed's `GTB_UIUtil` (see `tools/build_nodupes.py`) |
| `src/scripts/` | Papyrus sources of the scripts this layer changes or adds |
| `src/plugin/Frostfall/` | The plugin as Spriggit YAML (deserialize to rebuild `Frostfall.esp`) |
| `plugin/` | The SKSE plugin (`Frostfall.dll`) C++ source |
| `tools/`, `imports/` | Build helpers and compile-only script stubs |
| `assets/` | Logo and HUD icon sources |

To build it yourself, see [`BUILDING.md`](BUILDING.md).

## Credits and licence

Based on Chesko's MIT-licensed source (github.com/chesko256/Campfire); thanks to Chesko and to everyone credited in
`release-contents/README.txt`. See [`LICENSE.txt`](LICENSE.txt) for what the licence covers (Chesko's own work and these
changes; third-party assets credited on the original Nexus page are not included and stay with their authors).
