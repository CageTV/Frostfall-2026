# Frostfall 2026

An update layer for Chesko's **Frostfall – Hypothermia, Camping, Survival 3.4.1 SE** (Skyrim Special Edition / Anniversary
Edition 1.6.x). Version **4.0.0 (pre-release)**. The plugin file keeps its original name, `Frostfall.esp`.

It goes **on top of** the original Frostfall (Nexus 671) and Campfire (Nexus 667), which still supply every mesh and
texture. It is not a replacement and it does not contain anyone else's meshes, textures or shaders.

What it adds: Frostfall starts on its own on a new game, with a logo fade-in; a new HUD (four bars) and a settings page in
SKSE Menu Framework; the community's script fixes folded in; Embers XD fires warm you; and a "Make Camp" makeshift
shelter that uses the Creation Club Camping lean-to by reference. Full details, requirements and install steps are in
[`release-contents/README.txt`](release-contents/README.txt).

**Pre-release.** A new game is recommended. Carrying an existing save over from Frostfall 3.4.1 has not been tested.

## Download

Get `Frostfall 2026 4.0.0.zip` from the [Releases](../../releases) page and install it with your mod manager *after* the
original Frostfall and Campfire.

Two more mods live in this repository, each with its own release:

- **Frostfall 2026 - Leather Tent** (optional add-on): adds a leather camp to the Make Camp menu (4 Branches, 1 Linen Wrap,
  2 Leather) that shelters better than the simple camp. An ESL-flagged plugin with one mesh, the small hide tent mesh by
  Tumbajamba (modified, used with permission), so it is kept out of the main download. Install it after Frostfall 2026.
- **Frostfall - No Gear Display Dupes**: a one-script fix for Campfire. Campfire lays a real copy of your gear next to the
  bedroll when you rest in a tent, and pickup mods can take it, duplicating the item; this stops the copy being made.
  Scripts only; works with or without Frostfall 2026.

## Layout of this repository

| Path | What it is |
|---|---|
| `release-contents/` | Exactly what is in the Frostfall 2026 release zip (the files players install) |
| `release-contents-leather-tent/` | Exactly what is in the Leather Tent add-on zip |
| `addon-leather/` | The add-on's plugin as Spriggit YAML, and its mesh |
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
