# Building Frostfall 2026

The release is three things built separately and then laid out as in `release-contents/`.

## 1. Scripts (`src/scripts/*.psc` -> `scripts/*.pex`)
Compile with Bethesda's Papyrus compiler (`PapyrusCompiler.exe`, from the Creation Kit). `tools/build_scripts.py` shows the
import order that works (edit the paths at its top for your install):

1. `src/scripts` (these sources win)
2. Campfire's sources: clone <https://github.com/chesko256/Campfire> (MIT) and use its `Scripts/Source`
3. `imports/chesko-shared` (CheskoPapyrusShared, MIT) and `imports/stubs` (compile-only stubs)
4. The SkyUI SDK, SKSE, PapyrusUtil SE and powerofthree's Papyrus Extender script sources (get them from their own pages)
5. Vanilla Skyrim sources

`tools/compile_one.py Name.psc` compiles a single script the same way.

## 2. Plugin (`src/plugin/Frostfall` -> `Frostfall.esp`)
`src/plugin/Frostfall` is a [Spriggit](https://github.com/Mutagen-Modding/Spriggit) YAML export (package `Spriggit.Yaml.Skyrim`,
version in `src/plugin/Frostfall/spriggit-meta.json`). Deserialize it with the Spriggit CLI:

    spriggit deserialize --InputPath src/plugin/Frostfall --OutputPath Frostfall.esp

## 3. SKSE plugin (`plugin/` -> `SKSE/Plugins/Frostfall.dll`)
CommonLibSSE-NG plugin built with CMake + Ninja + MSVC and vcpkg (manifest in `plugin/build-local`). Set `VCPKG_ROOT`, then
run `plugin/build.cmd` (edit the Visual Studio path in it for your install). Output: `plugin/build/release/Frostfall.dll`.
Uses [SKSE Menu Framework 3](https://www.nexusmods.com/skyrimspecialedition/mods/120352) at runtime.

## 4. Leather Tent add-on (`addon-leather/` -> `Frostfall 2026 - Leather Tent.esp`)
`addon-leather/src/plugin/Frostfall 2026 - Leather Tent.esp` is a Spriggit YAML export (ESL-flagged, masters Skyrim.esm,
Campfire.esm, Frostfall.esp). Deserialize it with the Spriggit CLI as above, then `tools/build_release_addon.py` lays the plugin,
`addon-leather/meshes/` and the add-on's README/LICENSE out as in `release-contents-leather-tent/`. Its scripts are part of the
main layer (`_Frost_MakeshiftCamp`, `_Frost_MakeshiftCampTent`); the add-on has none of its own.

## 5. No Gear Display Dupes (`tools/build_nodupes.py`)
Builds `_camp_tentsystem.pex` from Campfire's own `_Camp_TentSystem.psc` (Chesko's MIT repo, cloned as in step 1): it turns the 26 gear
display copies into `None` and opens Go To Bed's sleep menu when Gotobed.esp is installed. `tools/build_release_nodupes.py` lays the
result out as in `release-contents-no-gear-dupes/`. The compile-only stub for Go To Bed's script is in `nodupe/stubs`.

## Logo and icons
`assets/frostfall_logo.png` is the in-game start-up logo (920x200); `assets/frostfall_logo_master.png` is the full-size
version. `tools/make_icons.py` redraws the HUD icons.

## Layout
Put the three outputs into the folder layout of `release-contents/` (plugin and scripts at the root, the DLL under
`SKSE/Plugins/`, plus `Interface/`, `sound/` and the compatibility `.ini` as shipped) and zip it with the files at the
zip's root.
