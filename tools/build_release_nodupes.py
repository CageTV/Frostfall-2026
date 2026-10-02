"""Lay out the "Frostfall - No Gear Display Dupes" package (release-nodupes/Frostfall - No Gear Display Dupes/) from the output of
tools/build_nodupes.py. Usage: python tools/build_release_nodupes.py"""
import os, shutil
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(HERE, "release-nodupes", "Frostfall - No Gear Display Dupes")
if os.path.exists(OUT):
    shutil.rmtree(OUT)
os.makedirs(os.path.join(OUT, "scripts", "source"))
shutil.copyfile(os.path.join(HERE, "nodupe-public", "build", "_Camp_TentSystem.pex"), os.path.join(OUT, "scripts", "_camp_tentsystem.pex"))
shutil.copyfile(os.path.join(HERE, "nodupe-public", "src", "_Camp_TentSystem.psc"), os.path.join(OUT, "scripts", "source", "_Camp_TentSystem.psc"))
for f in ("README.txt", "LICENSE.txt"):
    shutil.copyfile(os.path.join(HERE, "docs-nodupes", f), os.path.join(OUT, f))
print("no-dupes:", sum(len(fs) for _, _, fs in os.walk(OUT)), "files ->", OUT)
