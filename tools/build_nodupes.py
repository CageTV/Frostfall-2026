"""Build "Frostfall - No Gear Display Dupes" from Chesko's MIT Campfire source (upstream-chesko): no one else's script is used.
Two changes to _Camp_TentSystem.psc:
  1. the 26 gear display copies (PlaceAndWaitFor3DLoaded(...) into myDisplay*) become None, so Campfire spawns no real copy of the
     player's or followers' gear that a pickup mod could take;
  2. with Go To Bed (Gotobed.esp) installed the sleep menu is opened with its GTB_UIUtil.ShowSleepWaitMenu(true), as "Gotobed-se-patches"
     does; without it the bedroll is activated as before (compile-only stub in nodupe/stubs).
Usage: python tools/build_nodupes.py   -> nodupe-public/src/_Camp_TentSystem.psc and nodupe-public/build/_camp_tentsystem.pex
"""
import os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_scripts as b
HERE = b.HERE
SRC = os.path.join(HERE, "upstream-chesko", "Scripts", "Source", "_Camp_TentSystem.psc")
OUTSRC = os.path.join(HERE, "nodupe-public", "src")
OUTPEX = os.path.join(HERE, "nodupe-public", "build")
text = open(SRC, encoding="utf-8", errors="replace").read()

pat = re.compile(r"^(\s*)((?:TentObject|akTentObject)\.myDisplay\w+)\s*=\s*PlaceAndWaitFor3DLoaded\(.*\)\s*$", re.M)
text, n = pat.subn(lambda m: m.group(1) + m.group(2) + " = None ; no display copy of the gear (a pickup mod could take it, duplicating the item)", text)
act = "akTentObject.myBedRoll.Activate(PlayerRef);  //Spawns sleep menu"
assert text.count(act) == 1, "sleep menu line not found"
new = ('if Game.IsPluginInstalled("Gotobed.esp")\n\t\tGTB_UIUtil.ShowSleepWaitMenu(true) ; Go To Bed\'s sleep menu (as Gotobed-se-patches does)\n\telse\n'
       '\t\t' + act + '\n\tendif')
text = text.replace(act, new)
print("display copies removed:", n)
assert n == 26, n
os.makedirs(OUTSRC, exist_ok=True); os.makedirs(OUTPEX, exist_ok=True)
dst = os.path.join(OUTSRC, "_Camp_TentSystem.psc")
open(dst, "w", encoding="utf-8", newline="\n").write(text)

imports = [OUTSRC, os.path.join(HERE, "nodupe", "stubs")] + b.IMPORTS[1:]
cmd = [b.COMPILER, "_Camp_TentSystem.psc", f"-f={b.FLAGS}", "-i=" + ";".join(imports), f"-o={OUTPEX}"]
r = subprocess.run(cmd, capture_output=True, text=True, cwd=OUTSRC)
print((r.stdout + r.stderr).strip().splitlines()[-3:])
sys.exit(r.returncode)
