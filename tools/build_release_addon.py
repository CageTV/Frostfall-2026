"""Build the Frostfall 2026 - Leather Tent add-on package (release-addon/Frostfall 2026 - Leather Tent/).
The ESP comes from addon-leather/build (deserialized from addon-leather/src/plugin), the mesh from addon-leather/meshes.
Usage: python tools/build_release_addon.py
"""
import os, shutil, sys
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
A = os.path.join(HERE, "addon-leather")
OUT = os.path.join(HERE, "release-addon", "Frostfall 2026 - Leather Tent")
if os.path.exists(OUT):
    shutil.rmtree(OUT)
os.makedirs(os.path.join(OUT, "meshes", "frostfall"))
shutil.copyfile(os.path.join(A, "build", "Frostfall 2026 - Leather Tent.esp"), os.path.join(OUT, "Frostfall 2026 - Leather Tent.esp"))
shutil.copyfile(os.path.join(A, "meshes", "frostfall", "_frostleather_leanto.nif"), os.path.join(OUT, "meshes", "frostfall", "_frostleather_leanto.nif"))
for f in ("README.txt", "LICENSE.txt"):
    shutil.copyfile(os.path.join(HERE, "docs-addon", f), os.path.join(OUT, f))
print("add-on:", sum(len(fs) for _, _, fs in os.walk(OUT)), "files ->", OUT)
