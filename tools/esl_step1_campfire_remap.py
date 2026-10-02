"""ESL build, step 1: point Frostfall (and the add-on) at the ESL Campfire.esm.
Reads esl-work/map_full.json (old Campfire FormID -> ESL Campfire FormID, matched by EditorID) and writes remapped copies:
  esl-work/out/Frostfall/          <- src/plugin/Frostfall           (YAML, every NNNNNN:Campfire.esm reference remapped)
  esl-work/out/LeatherTent/        <- addon-leather/src/plugin/...   (same)
  esl-work/out/scripts/            <- src/scripts                    (GetFormFromFile(0x..., "Campfire.esm") remapped)
Any Campfire reference that is not in the map is an error. Usage: python tools/esl_step1_campfire_remap.py"""
import json, os, re, shutil, sys
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W = os.path.join(HERE, "esl-work"); OUT = os.path.join(W, "out")
mp = json.load(open(os.path.join(W, "map_full.json")))
ref = re.compile(r"\b([0-9A-Fa-f]{6}):Campfire\.esm")
look = re.compile(r"(GetFormFromFile\(\s*)(0x[0-9A-Fa-f]+|\d+)(\s*,\s*\"Campfire\.esm\"\s*\))", re.I)
bad = []
def sub_yaml(t, where):
    def f(m):
        old = m.group(1).upper()
        if old not in mp:
            bad.append((where, old)); return m.group(0)
        return mp[old] + ":Campfire.esm"
    return ref.sub(f, t)
def copy_tree(src, dst):
    if os.path.exists(dst): shutil.rmtree(dst)
    n = 0
    for dp, _, fs in os.walk(src):
        for fn in fs:
            s = os.path.join(dp, fn); d = os.path.join(dst, os.path.relpath(s, src)); os.makedirs(os.path.dirname(d), exist_ok=True)
            if fn.endswith(".yaml"):
                t = open(s, encoding="utf-8", newline="").read(); t2 = sub_yaml(t, s)
                n += (t != t2); open(d, "w", encoding="utf-8", newline="").write(t2)
            else: shutil.copyfile(s, d)
    return n
n1 = copy_tree(os.path.join(HERE, "src", "plugin", "Frostfall"), os.path.join(OUT, "Frostfall"))
addon = os.path.join(HERE, "addon-leather", "src", "plugin", "Frostfall 2026 - Leather Tent.esp")
n2 = copy_tree(addon, os.path.join(OUT, "LeatherTent", "Frostfall 2026 - Leather Tent.esp"))
# scripts
sd = os.path.join(OUT, "scripts")
if os.path.exists(sd): shutil.rmtree(sd)
os.makedirs(sd); ns = 0; sl = []
for fn in os.listdir(os.path.join(HERE, "src", "scripts")):
    if not fn.lower().endswith(".psc"): continue
    t = open(os.path.join(HERE, "src", "scripts", fn), encoding="utf-8", errors="replace", newline="").read()
    def g(m):
        v = int(m.group(2), 0); low = v & 0xFFFFFF; key = f"{low:06X}"
        if key not in mp: bad.append((fn, key)); return m.group(0)
        return m.group(1) + "0x" + mp[key] + m.group(3)
    t2 = look.sub(g, t)
    if t2 != t: ns += 1; open(os.path.join(sd, fn), "w", encoding="utf-8", newline="").write(t2)
print(f"yaml files changed: Frostfall {n1}, LeatherTent {n2}; scripts changed: {ns}")
for s in sl: print("skipped:", s)
if bad: print("UNMAPPED:", bad); sys.exit(1)
print("all Campfire references mapped")
