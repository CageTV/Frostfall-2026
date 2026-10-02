FROSTFALL 2026 — Hypothermia, Camping, Survival
Version 4.0.0 (pre-release), an update layer for Chesko's Frostfall
Updated for Skyrim Special Edition / Anniversary Edition (1.6.x)
==================================================================

Frostfall by Chesko, rebuilt from Chesko's own MIT-licensed source with the fixes the community has been installing as
separate add-ons for years, plus bugs that were never fixed anywhere.

THIS IS AN UPDATE LAYER, NOT A FULL MOD. It contains only the plugin, scripts, SKSE plugin, interface files, a few
sounds. It deliberately contains no meshes and no
model or world textures: those belong to Chesko and to the artists credited on the original Frostfall page, so you get
them from the original download, which stays installed.

The plugin is still Frostfall.esp and every record keeps its FormID, so saves and patches made for Frostfall keep working.


REQUIREMENTS
------------
- Frostfall - Hypothermia Camping Survival 3.4.1 SE (Nexus 671) — the ORIGINAL release. KEEP IT INSTALLED: it supplies
  every mesh and texture. This layer goes on top of it.
- Campfire - Complete Camping System 1.12.1 (Nexus 667) — the ORIGINAL release.
- Creation Club: Camping (ccqdrsse002-firewood.esl, part of the Anniversary Edition bundle) — the "Make Camp" shelter is its
  lean-to mesh, used by reference. Without it the Make Camp option is simply not offered.
- Skyrim Script Extender (SKSE64) and Address Library for SKSE Plugins
- PapyrusUtil SE (Nexus 13048)
- powerofthree's Papyrus Extender (Nexus 22854)
- SKSE Menu Framework 3 (Nexus 120352) — for the new HUD bars, the start-up logo, the settings page and auto-start.
  Without it, Frostfall falls back to its SkyUI meters, start-up messages and manual start.
- SkyUI SE (for Frostfall's remaining settings in the Mod Configuration Menu)
- Recommended: CC Camping - Comfy Sleeping (Nexus 58840, by Missile) — gives the lean-to a raised hay platform with a
  bedroll. Optional; it overrides the CC mesh, so Make Camp picks it up automatically (the bedroll, lamp and the spot
  you lie down in are set to match its platform). Without it you get the plain Creation Club lean-to.
- Recommended: Restarter's Basic Mesh Fixes (Nexus 148788) — corrected flags and collision filters for the Campfire
  meshes. Not included here; it is its own mod with its own author.
- Recommended: FormList Manipulator (Nexus 74037) with Frostfall FLM Patches (Nexus 191669, by PeaceAndSparrow) —
  climate compatibility for 24 mods' worldspaces. Not included here.
- Optional: FormList Manipulator also activates Frostfall_Embers_FLM.ini from this layer (Embers XD fire warmth).

Frostfall does not bundle PapyrusUtil or any other DLL. Install those from their own pages and keep them updated.


INSTALL
-------
1. Install the original Frostfall 3.4.1 and Campfire, then this layer, with your mod manager.
2. This layer must WIN file conflicts over the original Frostfall (in Mod Organizer 2: place it below the original in the
   left pane). Its Frostfall.esp and its scripts replace the original's.
3. DISABLE these, because this layer replaces what they fix:
     - Campfire and Frostfall - Unofficial SSE Update
     - Frostfall Spell Monitor Optimized
     - Frostfall Vampire Fix (its plugin and scripts)
     - Frostfall - Bound Cloak Bugfix
   Keep Campfire itself installed and enabled.
4. LOAD ORDER with "Campfire - Script Optimization": if you use it, place this layer BELOW it in the left pane (so
   this layer wins). Script Optimization replaces the same Campfire script (CampCampfire) that this layer extends; if it
   wins, "Destroy" on a campfire will not take a makeshift camp down with it.

New game recommended. This is a pre-release: carrying an existing save over from Frostfall 3.4.1 has not been tested
enough to promise it works. On an existing save where Frostfall is already running: go somewhere quiet (an interior), save,
switch to this version, load, and let Frostfall finish its start-up messages.


WHAT'S NEW
----------
- Starts on its own: on a new game, Frostfall starts the first time you step outside (after character creation and
  any intro). A game where you stopped Frostfall on purpose is never restarted. Can be turned off.
- The Frostfall logo fades in and out when Frostfall starts, instead of message boxes and a quest banner.
- New HUD: four flat vertical bars on the right of the screen — exposure (cold), wetness, temperature, and warmth +
  coverage — replacing the old SkyUI meters. Always on or contextual (fades while you're comfortable), 2 x 2 grid or a
  single row, and movable / resizable in game.
- Settings page in SKSE Menu Framework (Frostfall > Overview / HUD): status, start / stop, auto-start, bar layout.
  The rest of Frostfall's settings are still in the Mod Configuration Menu for now.


WHAT'S FIXED
------------
- SKSE features on Special Edition. Frostfall shipped for SE before SKSE64 existed, so it skipped its SKSE check and
  ran in "no SKSE" mode (message-box menu, no meters). It now detects SKSE64 properly.
- Vampire Mode never worked. The exposure system's vampire flag was declared false and never set, so Supernatural and
  Immortal modes never granted frostbite immunity or protection from freezing to death — even for vanilla vampires.
  Fixed, and vampire overhauls (Sacrosanct, Better Vampires, ...) are now recognised through the vanilla
  PlayerIsVampire global.
- Bound cloaks were dispelled the instant they were cast. Any momentary unequip (other gear taking the slot, outfit or
  weather mods, re-casting) ended the spell. The cloak now lasts its full duration; it still can't be dropped or moved
  into a container, and it is still removed when the spell ends.
- Throat of the World cold outside Skyrim. The high-altitude summit check applied in every worldspace, so mod
  worldspaces (Falskaar, Bruma, Wyrmstooth, ...) whose coordinates fell in that area froze you for no reason. Limited to
  Tamriel. (Chesko's own 2017 fix, never released before.)
- Script load. The spell monitor used to run for every magic effect applied to the player; it now only wakes up for
  fire and frost effects (Papyrus Extender's filtered event). Saves made with the old script are upgraded on load.
- Chesko's post-release script fixes (previously only available through the Unofficial SSE Update) are included.
- Embers XD fires now warm you and your followers (Frostfall_Embers_FLM.ini, via FormList Manipulator).


SKYUI ITEM-CARD DISPLAY (NOT INCLUDED)
--------------------------------------
Older setups replaced SkyUI's inventory, barter, container and crafting menus to show warmth and coverage on item cards.
Those are modified copies of SkyUI's own menus: they conflict with other UI mods and are not Frostfall's to redistribute.
Without them, Frostfall shows warmth and coverage in its equip notifications instead.


MAKE CAMP SHELTER
-----------------
The "Make Camp" makeshift shelter uses the Creation Club Camping lean-to mesh by reference; no mesh is included in this
layer. It needs the Creation Club Camping content (ccqdrsse002-firewood.esl). With CC Camping - Comfy Sleeping installed
the lean-to gets a raised hay platform and bedroll, and the camp's bedroll, lamp and lie-down spot line up with it.


CREDITS
-------
- Chesko — Frostfall, Campfire and CheskoPapyrusShared. The parts that are Chesko's own work are MIT-licensed
  (github.com/chesko256/Campfire). The meshes, textures and other assets credited on Frostfall's Nexus page are NOT
  included in this layer: Isoku and OpticShooter (water drip shaders), Gerauld and Yuril (snowberry bottle), Tumbajamba
  (small hide tent mesh), Lorelai (fur cloaks), Hypno88 (stone arrows), Foster Xbl (bound equipment shaders and
  textures), Doccdr (Survivor's Guide texture), DanielCoffey (Survivor's Guide mesh). Thank you to all of them.
- Bethesda — the Creation Club Camping lean-to used by Make Camp; Missile — Comfy Camping (optional)
- SkyUI team — SkyUI and its SDK, which the HUD widgets build on
- Sthaagg Memnochs — Campfire and Frostfall - Unofficial SSE Update, which kept Frostfall usable on SE for years
- The Chronic Restarter — Restarter's Basic Mesh Fixes (Campfire meshes; separate download)
- PeaceAndSparrow — Frostfall FLM Patches (separate download)
- Squidtacular — Frostfall - Bound Cloak Bugfix, and Sthaagg Memnochs — Frostfall Vampire Fix, for identifying the
  problems fixed here (reimplemented at the source)
- Nightfallstorm — Frostfall Spell Monitor Optimized, for identifying the spell-monitor cost (reimplemented independently)
- powerofthree — Papyrus Extender
- Update and maintenance: CageTV
