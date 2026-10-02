"""ESL build, step 3: scripts (replaces the script handling of steps 1-2).
Every Papyrus script that hard-codes a Campfire.esm / Frostfall.esp FormID is rewritten for the ESL pair and compiled:
  - sources: our src/scripts where we have the script, otherwise Chesko's MIT source in upstream-chesko (NEVER any other mod's copy);
  - forms handled:  f(0x0205DE6D, "Campfire.esm")  f(260764, "Campfire.esm", ...)  "260764___Campfire.esm"  (hex or decimal ids, with or
    without the 0x02 high byte that GetFormFromFile ignores);
  - _Frost_ArmorProtectionDatastoreHandler.GetDatastoreKeyFromID is made light-plugin aware (an ESL FormID FEaaabbb is plugin aaa, local id
    bbb), otherwise the armor datastore keys of ESL armors (Campfire's cloaks, Frostfall's own) would be wrong.
Output: esl-work/scripts-esl-src/{frostfall,campfire}/*.psc and esl-work/pex-esl/{frostfall,campfire}/*.pex.
Usage: python tools/esl_step3_scripts.py"""
import json, os, re, shutil, subprocess, sys
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(HERE, "tools"))
import build_scripts as b
W = os.path.join(HERE, "esl-work"); UP = os.path.join(HERE, "upstream-chesko", "Scripts", "Source"); OURS = os.path.join(HERE, "src", "scripts")
assert "Script Optimization" not in UP
maps = {"campfire.esm": json.load(open(os.path.join(W, "map_full.json"))), "frostfall.esp": json.load(open(os.path.join(W, "map_frostfall.json")))}
R1 = re.compile(r'(\(\s*)(0x[0-9A-Fa-f]+|\d+)(\s*,\s*")(Campfire\.esm|Frostfall\.esp)(")', re.I)
R2 = re.compile(r'"(\d+)___(Campfire\.esm|Frostfall\.esp)"', re.I)
bad = []; count = {}
def remap_id(token, plugin, fn):
    hexed = token.lower().startswith("0x"); v = int(token, 16) & 0xFFFFFF if hexed else int(token)
    new = maps[plugin.lower()].get(f"{v:06X}")
    if new is None: bad.append((fn, plugin, token)); return token
    count[fn] = count.get(fn, 0) + 1
    return ("0x" + new) if hexed else str(int(new, 16))
def rewrite(t, fn):
    t = R1.sub(lambda m: m.group(1) + remap_id(m.group(2), m.group(4), fn) + m.group(3) + m.group(4) + m.group(5), t)
    t = R2.sub(lambda m: '"' + remap_id(m.group(1), m.group(2), fn) + "___" + m.group(2) + '"', t)
    return t
OLD_KEY = '''	int mod_index = GetModIndex(aiFormID)
	int base_form_id = GetBaseFormID(aiFormID)
	string ds_key = base_form_id + "___" + Game.GetModName(mod_index)
	return ds_key'''
NEW_KEY = '''	int mod_index = GetModIndex(aiFormID)
	if mod_index == 254
		; Frostfall 2026 (ESL build): a light plugin's FormID is FEaaabbb: plugin aaa, local id bbb
		int light_index = LogicalAnd(aiFormID, 0x00FFF000) / 4096
		return LogicalAnd(aiFormID, 0x00000FFF) + "___" + Game.GetLightModName(light_index)
	endif
	int base_form_id = GetBaseFormID(aiFormID)
	string ds_key = base_form_id + "___" + Game.GetModName(mod_index)
	return ds_key'''
names = {}
for d, tag in ((UP, "campfire"), (OURS, "frostfall")):
    for fn in os.listdir(d):
        if fn.lower().endswith(".psc") and not fn.lower().endswith("_test.psc"):   # unit-test scripts are not game scripts
            if tag == "campfire" and os.path.exists(os.path.join(OURS, fn)): continue
            names[fn] = (os.path.join(d, fn), tag)
out_src = os.path.join(W, "scripts-esl-src")
if os.path.exists(out_src): shutil.rmtree(out_src)
changed = {"frostfall": [], "campfire": []}
for fn, (p, tag) in sorted(names.items()):
    t = open(p, encoding="utf-8", errors="replace", newline="").read(); t2 = rewrite(t, fn)
    if fn == "_Frost_ArmorProtectionDatastoreHandler.psc":
        nl = "\r\n" if "\r\n" in t2 else "\n"; old = OLD_KEY.replace("\n", nl); assert old in t2, "datastore key function not found"
        t2 = t2.replace(old, NEW_KEY.replace("\n", nl)); count[fn] = count.get(fn, 0) + 1
    if t2 != t:
        os.makedirs(os.path.join(out_src, tag), exist_ok=True)
        open(os.path.join(out_src, tag, fn), "w", encoding="utf-8", newline="").write(t2); changed[tag].append(fn)
for tag in changed: print(tag, len(changed[tag]), "scripts:", ", ".join(f"{f}({count.get(f)})" for f in changed[tag]))
print("total rewrites:", sum(count.values()))
if bad: print("UNMAPPED:", bad); sys.exit(1)
def compile_dir(srcdir, outdir):
    if os.path.exists(outdir): shutil.rmtree(outdir)
    os.makedirs(outdir); ok = True
    for fn in sorted(os.listdir(srcdir)):
        cmd = [b.COMPILER, fn, f"-f={b.FLAGS}", "-i=" + ";".join([os.path.join(out_src, "frostfall"), os.path.join(out_src, "campfire")] + b.IMPORTS), f"-o={outdir}"]
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=180, cwd=srcdir)
        if r.returncode: print("  FAILED", fn, (r.stdout + r.stderr)[-600:]); ok = False
    print("  compiled", len(os.listdir(outdir)), "of", len(os.listdir(srcdir)), "->", outdir)
    return ok
ok = True
for tag in ("frostfall", "campfire"):
    if os.path.isdir(os.path.join(out_src, tag)): ok &= compile_dir(os.path.join(out_src, tag), os.path.join(W, "pex-esl", tag))
sys.exit(0 if ok else 1)
