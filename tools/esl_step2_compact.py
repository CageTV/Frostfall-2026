"""ESL build, step 2: compact Frostfall.esp's own FormIDs into the ESL range and flag it Small.
Works on esl-work/out (the output of step 1). Frostfall.esp's own records get 000800, 000801, ... in order of their old FormID;
every NNNNNN:Frostfall.esp reference in the YAML (Frostfall + the Leather Tent add-on) and every GetFormFromFile(0x..., "Frostfall.esp")
in the scripts is remapped. File and folder names that carry the old id are renamed; interior-cell block folders are recomputed
from the (new) cell ids. Writes esl-work/map_frostfall.json.  Usage: python tools/esl_step2_compact.py"""
import json, os, re, shutil, sys
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(HERE, "esl-work", "out")
FF = os.path.join(OUT, "Frostfall"); AD = os.path.join(OUT, "LeatherTent", "Frostfall 2026 - Leather Tent.esp"); SC = os.path.join(OUT, "scripts")
defn = re.compile(r"^\s*(?:- )?FormKey: ([0-9A-F]{6}):Frostfall\.esp\s*$", re.M)
ref = re.compile(r"\b([0-9A-F]{6}):Frostfall\.esp")
own = set()
for dp, _, fs in os.walk(FF):
    for fn in fs:
        if fn.endswith(".yaml"):
            own.update(defn.findall(open(os.path.join(dp, fn), encoding="utf-8", errors="replace").read()))
ids = sorted(own, key=lambda x: int(x, 16))
if len(ids) > 0x800: sys.exit(f"too many records for ESL: {len(ids)}")
mp = {old: f"{0x800 + i:06X}" for i, old in enumerate(ids)}
json.dump(mp, open(os.path.join(HERE, "esl-work", "map_frostfall.json"), "w"))
print("records:", len(ids), "->", mp[ids[0]], "..", mp[ids[-1]])
bad = set()
def sub(t):
    def f(m):
        if m.group(1) not in mp: bad.add(m.group(1)); return m.group(0)
        return mp[m.group(1)] + ":Frostfall.esp"
    return ref.sub(f, t)
nchg = 0
for root in (FF, AD):
    for dp, _, fs in os.walk(root):
        for fn in fs:
            if fn.endswith(".yaml"):
                p = os.path.join(dp, fn); t = open(p, encoding="utf-8", newline="").read(); t2 = sub(t)
                if t2 != t: nchg += 1; open(p, "w", encoding="utf-8", newline="").write(t2)
print("yaml files changed:", nchg)
# rename files/folders that carry an old id:  "Name - OLDID_Frostfall.esp[.yaml]"
nm = re.compile(r"^(.* - )([0-9A-F]{6})(_Frostfall\.esp(?:\.yaml)?)$")
for dp, dns, fs in os.walk(FF, topdown=False):
    for n in fs + dns:
        m = nm.match(n)
        if m and m.group(2) in mp:
            os.rename(os.path.join(dp, n), os.path.join(dp, m.group(1) + mp[m.group(2)] + m.group(3)))
# Frostfall's overrides of Campfire records also carry the old Campfire id in their names
cmap = json.load(open(os.path.join(HERE, "esl-work", "map_full.json")))
cm = re.compile(r"^(.* - )([0-9A-F]{6})(_Campfire\.esm(?:\.yaml)?)$")
for dp, dns, fs in os.walk(FF, topdown=False):
    for n in fs + dns:
        m = cm.match(n)
        if m and m.group(2) in cmap:
            os.rename(os.path.join(dp, n), os.path.join(dp, m.group(1) + cmap[m.group(2)] + m.group(3)))
# ESL flag
rd = os.path.join(FF, "RecordData.yaml"); t = open(rd, encoding="utf-8", newline="").read()
if "- Small" not in t:
    nl = "\r\n" if "\r\n" in t else "\n"
    assert "ModHeader:" + nl in t, "ModHeader not found"
    t = t.replace("ModHeader:" + nl, "ModHeader:" + nl + "  Flags:" + nl + "  - Small" + nl, 1)
    open(rd, "w", encoding="utf-8", newline="").write(t)
# scripts
look = re.compile(r"(GetFormFromFile\(\s*)(0x[0-9A-Fa-f]+|\d+)(\s*,\s*\"Frostfall\.esp\"\s*\))", re.I)
base = os.path.join(HERE, "src", "scripts"); ns = 0; seen = set()
for fn in os.listdir(base):
    if not fn.lower().endswith(".psc"): continue
    src = os.path.join(SC, fn) if os.path.exists(os.path.join(SC, fn)) else os.path.join(base, fn)
    t = open(src, encoding="utf-8", errors="replace", newline="").read()
    def g(m):
        key = f"{int(m.group(2), 0) & 0xFFFFFF:06X}"
        if key not in mp: bad.add(fn + ":" + key); return m.group(0)
        seen.add(fn); return m.group(1) + "0x" + mp[key] + m.group(3)
    t2 = look.sub(g, t)
    if t2 != t:
        os.makedirs(SC, exist_ok=True); open(os.path.join(SC, fn), "w", encoding="utf-8", newline="").write(t2); ns += 1
print("scripts remapped for Frostfall.esp ids:", ns, sorted(seen))
# interior cell block folders from the cell ids
cells = os.path.join(FF, "Cells"); tmpl = {}
for b in os.listdir(cells):
    bp = os.path.join(cells, b)
    if os.path.isdir(bp):
        tmpl["block"] = open(os.path.join(bp, "GroupRecordData.yaml"), encoding="utf-8").read()
        for s in os.listdir(bp):
            if os.path.isdir(os.path.join(bp, s)): tmpl["sub"] = open(os.path.join(bp, s, "GroupRecordData.yaml"), encoding="utf-8").read()
moves = []
for b in os.listdir(cells):
    bp = os.path.join(cells, b)
    if not os.path.isdir(bp): continue
    for s in os.listdir(bp):
        sp = os.path.join(bp, s)
        if not os.path.isdir(sp): continue
        for c in os.listdir(sp):
            cp = os.path.join(sp, c)
            if os.path.isdir(cp):
                fid = int(re.match(r"FormKey: ([0-9A-F]{6}):", open(os.path.join(cp, "RecordData.yaml"), encoding="utf-8").readline()).group(1), 16)
                nb, ns_ = str(fid % 10), str((fid // 10) % 10)
                if (nb, ns_) != (b, s): moves.append((cp, nb, ns_, c))
for cp, nb, ns_, c in moves:
    dst = os.path.join(cells, nb, ns_); os.makedirs(dst, exist_ok=True)
    gb = os.path.join(cells, nb, "GroupRecordData.yaml")
    if not os.path.exists(gb): open(gb, "w", encoding="utf-8", newline="").write(re.sub(r"BlockNumber: \d+", f"BlockNumber: {nb}", tmpl["block"]))
    gs = os.path.join(dst, "GroupRecordData.yaml")
    if not os.path.exists(gs): open(gs, "w", encoding="utf-8", newline="").write(re.sub(r"BlockNumber: \d+", f"BlockNumber: {ns_}", tmpl["sub"]))
    shutil.move(cp, os.path.join(dst, c)); print("cell moved ->", f"Cells/{nb}/{ns_}/{c}")
# drop block folders that became empty of cells
for b in os.listdir(cells):
    bp = os.path.join(cells, b)
    if os.path.isdir(bp):
        for s in os.listdir(bp):
            sp = os.path.join(bp, s)
            if os.path.isdir(sp) and not [x for x in os.listdir(sp) if os.path.isdir(os.path.join(sp, x))]: shutil.rmtree(sp)
        if not [x for x in os.listdir(bp) if os.path.isdir(os.path.join(bp, x))]: shutil.rmtree(bp)
if bad: print("UNMAPPED:", sorted(bad)); sys.exit(1)
print("done")
