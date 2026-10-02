"""ESL build, step 5: lay out and zip the ESL set (originals untouched):
  release-esl/Frostfall 2026 (ESL)/                = the standard layer + ESL Frostfall.esp, ESL Frostfall.dll, the rewritten scripts, ESL README
  release-esl/Frostfall 2026 - Leather Tent (ESL)/ = the add-on rebuilt for the ESL pair
  release-esl/Campfire ESL - Script Fixes/         = Campfire's own scripts with their hard-coded FormIDs fixed for the ESL Campfire.esm
Needs: esl-work/esp/*.esp (steps 1-2), esl-work/pex-esl + scripts-esl-src (step 3), plugin/build/release-esl/Frostfall.dll (step 4).
Usage: python tools/esl_step5_package.py"""
import os, shutil, sys, zipfile

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W = os.path.join(HERE, "esl-work")
R = os.path.join(HERE, "release-esl")
WS = os.path.dirname(HERE)
if os.path.exists(R):
    shutil.rmtree(R)
os.makedirs(R)


def put(src, dst):
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copyfile(src, dst)


def text(path):
    return open(path, encoding="utf-8").read()


def write(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w", encoding="utf-8", newline="\n").write(content)


# ---- Frostfall 2026 (ESL)
FF = os.path.join(R, "Frostfall 2026 (ESL)")
shutil.copytree(os.path.join(HERE, "release-layer", "Frostfall 2026"), FF)
put(os.path.join(W, "esp", "Frostfall.esp"), os.path.join(FF, "Frostfall.esp"))
# the Embers XD FormList Manipulator lines point at Campfire formlists by id: use the ESL Campfire's ids
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import esl_step7_inis
print("Embers FLM ini: lines changed", esl_step7_inis.remap_file(os.path.join(FF, "Frostfall_Embers_FLM.ini")))
dll = os.path.join(HERE, "plugin", "build", "release-esl", "Frostfall.dll")
if not os.path.exists(dll):
    sys.exit("ESL DLL not built: " + dll)
put(dll, os.path.join(FF, "SKSE", "Plugins", "Frostfall.dll"))
n = 0
for fn in os.listdir(os.path.join(W, "pex-esl", "frostfall")):
    put(os.path.join(W, "pex-esl", "frostfall", fn), os.path.join(FF, "scripts", fn.lower()))
    n += 1
for fn in os.listdir(os.path.join(W, "scripts-esl-src", "frostfall")):
    put(os.path.join(W, "scripts-esl-src", "frostfall", fn), os.path.join(FF, "scripts", "source", fn))
print("Frostfall ESL: rewritten scripts", n)

rd = text(os.path.join(HERE, "docs-layer", "README.txt"))
rd = rd.replace("Version 4.0.0 (pre-release), an update layer for Chesko's Frostfall",
                "Version 4.0.0 (pre-release), ESL BUILD, an update layer for Chesko's Frostfall", 1)
old = "The plugin is still Frostfall.esp and every record keeps its FormID, so saves and patches made for Frostfall keep working."
assert old in rd
rd = rd.replace(old, """THIS IS THE ESL BUILD. Frostfall.esp is flagged ESL (light) and its records were renumbered to fit, so it takes no regular
plugin slot. It is made to run with the ESL Campfire (see below) and ONLY with it. Because the FormIDs changed, saves made with
the normal Frostfall / Frostfall 2026, and patches that point into Frostfall.esp's records, do not work with this build: start a
new game, and use the normal Frostfall 2026 download if you want to keep an existing save or such patches.

Plugins you generated or patched against the normal Frostfall / Campfire (Synthesis, PGPatcher and the like, and any patch or INI that
points at their records by FormID) must be regenerated or remapped for the ESL pair. Their old ids are cut down to the light range by
the game and can land on the wrong records or leave ghost records. After switching, re-run those tools and check the load order for
references that no plugin defines (houseCARL, xEdit's "Check for Errors").""", 1)
old2 = "- Campfire - Complete Camping System 1.12.1 (Nexus 667) — the ORIGINAL release."
assert old2 in rd, "campfire requirement line not found"
rd = rd.replace(old2, """- Campfire - Complete Camping System 1.12.1 (Nexus 667) — the ORIGINAL release (it supplies the archive, meshes and textures),
  with "CAMPFIRE ESL UPDATED" (Nexus 193472) on top of it (its Campfire.esm replaces the original, ESL-flagged), and
  "Campfire ESL - Script Fixes" (a separate download, below them in the mod list's priority): Campfire's own scripts still
  look records up by their old FormIDs, which the ESL Campfire changed.""", 1)
write(os.path.join(FF, "README.txt"), rd)

# ---- Leather Tent (ESL)
AD = os.path.join(R, "Frostfall 2026 - Leather Tent (ESL)")
put(os.path.join(W, "esp", "Frostfall 2026 - Leather Tent.esp"), os.path.join(AD, "Frostfall 2026 - Leather Tent.esp"))
put(os.path.join(HERE, "addon-leather", "meshes", "frostfall", "_frostleather_leanto.nif"),
    os.path.join(AD, "meshes", "frostfall", "_frostleather_leanto.nif"))
put(os.path.join(HERE, "docs-addon", "LICENSE.txt"), os.path.join(AD, "LICENSE.txt"))
ar = text(os.path.join(HERE, "docs-addon", "README.txt"))
ar = ar.replace("Version 1.0.0, an optional add-on for Frostfall 2026",
                "Version 1.0.0, ESL BUILD, an optional add-on for Frostfall 2026 (ESL)", 1)
ar = ar.replace("- Frostfall 2026 4.0.0 (this add-on only adds to its Make Camp menu) and everything that needs.",
                "- Frostfall 2026 4.0.0 (ESL) (this add-on only adds to its Make Camp menu) and everything that needs, including the ESL\n"
                "  Campfire. It does not work with the normal Frostfall 2026: the records it points at have other FormIDs there.", 1)
write(os.path.join(AD, "README.txt"), ar)

# ---- Campfire ESL - Script Fixes (only scripts that exist in the shipped Campfire; LastSeed's are left out)
CF = os.path.join(R, "Campfire ESL - Script Fixes")
shipped = {f.lower() for f in os.listdir(os.path.join(HERE, "reference", "shipped-campfire-1.12.1", "scripts", "source"))}
k = 0
for fn in sorted(os.listdir(os.path.join(W, "scripts-esl-src", "campfire"))):
    if fn.lower() not in shipped:
        continue
    put(os.path.join(W, "scripts-esl-src", "campfire", fn), os.path.join(CF, "scripts", "source", fn))
    put(os.path.join(W, "pex-esl", "campfire", fn[:-4] + ".pex"), os.path.join(CF, "scripts", fn[:-4].lower() + ".pex"))
    k += 1
print("Campfire fixes: scripts", k)
write(os.path.join(CF, "README.txt"), """Campfire ESL - Script Fixes
Version 1.0.0, for "CAMPFIRE ESL UPDATED" (Nexus 193472) and Campfire 1.12.1

THE PROBLEM
-----------
"CAMPFIRE ESL UPDATED" flags Campfire.esm as ESL (light) and renumbers its records so it takes no regular plugin slot. It leaves
Campfire's scripts as they were, and a number of them look records up by hard-coded FormID, for example the bedroll furniture and the
conjured-shelter pieces of every tent. With the renumbered records those lookups find nothing (or the wrong record), so tents,
bedrolls and the perk system misbehave.

THE FIX
-------
The %d Campfire scripts that do this, with each hard-coded FormID changed to the matching record of the ESL Campfire (matched by
EditorID; every pair was checked against the ESL plugin). Nothing else in them changed: they are Chesko's Campfire 1.12.1
scripts (the source is included in scripts/source, MIT). Loose scripts override the ones in Campfire.bsa.

USE
---
Only together with "CAMPFIRE ESL UPDATED". With the original Campfire.esm do NOT install it: the ids would be wrong. Put it
after (below) Campfire and "CAMPFIRE ESL UPDATED" in MO2's left pane. It is also required by "Frostfall 2026 (ESL)".

CREDITS
-------
Chesko (Campfire, MIT). The ESL conversion of Campfire.esm is the work of the author of "CAMPFIRE ESL UPDATED".
""" % k)
lic = text(os.path.join(HERE, "docs-nodupes", "LICENSE.txt"))
lic = lic.replace("Frostfall - No Gear Display Dupes, version 1.0.0", "Campfire ESL - Script Fixes, version 1.0.0", 1)
start = lic.index("This is Chesko's")
end = lic.index("The MIT License (MIT)")
lic = lic[:start] + ("These are Chesko's scripts from Campfire (https://github.com/chesko256/Campfire) with hard-coded FormIDs changed for the\n"
                     "ESL Campfire.esm. They are released under the same MIT License as the original.\n\n") + lic[end:]
write(os.path.join(CF, "LICENSE.txt"), lic)


# ---- zips (files at the zip root)
def zipdir(src, out):
    if os.path.exists(out):
        os.remove(out)
    c = 0
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for dp, _, fs in os.walk(src):
            for f in sorted(fs):
                p = os.path.join(dp, f)
                z.write(p, os.path.relpath(p, src).replace("\\", "/"))
                c += 1
    return c


for d, name in ((FF, "Frostfall 2026 4.0.0 ESL.zip"), (AD, "Frostfall 2026 - Leather Tent 1.0.0 ESL.zip"),
                (CF, "Campfire ESL - Script Fixes 1.0.0.zip")):
    print(name, zipdir(d, os.path.join(WS, name)), "files")
