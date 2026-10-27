"""Turns the Leather Tent add-on's three records into an overlay for the REGULAR Frostfall.esp.

  python tools/make_tent_overlay.py     addon-leather/src/plugin -> src/plugin-tent/

From 4.2.0 the leather camp is part of the regular (non-ESL) Frostfall.esp instead of a separate plugin. The ESL build does not get it
(its steps read src/plugin/Frostfall only, which stays untouched), so the records live in this overlay and are laid over a copy of
src/plugin/Frostfall by tools/build_regular_plugin.py.

  000800 _FrostLeather_LeanToStatic -> 095020
  000801 _FrostLeather_Camp_ACT     -> 095021   (read by _Frost_MakeshiftCamp.GetLeatherCamp)
  000802 _FrostLeather_Camp_Menu    -> 095022   (read by _Frost_MakeshiftCamp.GetLeatherMenu)
"""
import os
import re
import shutil

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(HERE, "addon-leather", "src", "plugin", "Frostfall 2026 - Leather Tent.esp")
OUT = os.path.join(HERE, "src", "plugin-tent")
OLD_PLUGIN = "Frostfall 2026 - Leather Tent.esp"
IDS = {"000800": "095020", "000801": "095021", "000802": "095022"}

if os.path.exists(OUT):
    shutil.rmtree(OUT)
n = 0
for sub in ("Activators", "Messages", "Statics"):
    for name in os.listdir(os.path.join(SRC, sub)):
        text = open(os.path.join(SRC, sub, name), encoding="utf-8", newline="").read()
        for old, new in IDS.items():
            text = text.replace(f"{old}:{OLD_PLUGIN}", f"{new}:Frostfall.esp")
        assert OLD_PLUGIN not in text, name
        old_id = re.search(r" - ([0-9A-F]{6})_Frostfall 2026", name).group(1)
        new_name = name.replace(f" - {old_id}_{OLD_PLUGIN}.yaml", f" - {IDS[old_id]}_Frostfall.esp.yaml")
        assert new_name != name
        os.makedirs(os.path.join(OUT, sub), exist_ok=True)
        open(os.path.join(OUT, sub, new_name), "w", encoding="utf-8", newline="").write(text)
        n += 1
print("overlay records:", n, "->", OUT)
