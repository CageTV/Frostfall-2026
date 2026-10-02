"""ESL build, step 0: the FormID map from the original Campfire.esm to the ESL Campfire.esm ("CAMPFIRE ESL UPDATED", Nexus 193472).
The ESL mod renumbered Campfire's records; every record keeps its EditorID, so the two plugins are paired by EditorID.
Export both plugins with Spriggit first (the ESL mod is someone else's work: keep its export local, do not publish it):
    spriggit serialize --InputPath <original>/Campfire.esm --OutputPath esl-work/campfire-orig --GameRelease SkyrimSE --PackageName Spriggit.Yaml --PackageVersion <version>
    spriggit serialize --InputPath <ESL mod>/Campfire.esm  --OutputPath esl-work/campfire-esl  --GameRelease SkyrimSE --PackageName Spriggit.Yaml --PackageVersion <version>
Writes esl-work/map_full.json  {"OLDID": "NEWID", ...}  (6 hex digits, upper case). Fails on any record that cannot be paired uniquely.
Usage: python tools/esl_step0_map.py"""
import collections, json, os, re, sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W = os.path.join(HERE, "esl-work")
FK = re.compile(r"^\s*(?:- )?FormKey: ([0-9A-F]{6}):Campfire\.esm\s*$")
ED = re.compile(r"^\s*EditorID: (.+?)\s*$")


def scan(root):
    by_editor = collections.defaultdict(list)
    anonymous = 0
    for dp, _, fs in os.walk(root):
        for fn in fs:
            if not fn.endswith(".yaml"):
                continue
            lines = open(os.path.join(dp, fn), encoding="utf-8", errors="replace").read().splitlines()
            for i, line in enumerate(lines):
                m = FK.match(line)
                if not m:
                    continue
                editor = None
                for j in range(i + 1, min(i + 8, len(lines))):
                    if FK.match(lines[j]):
                        break
                    em = ED.match(lines[j])
                    if em:
                        editor = em.group(1)
                        break
                if editor:
                    by_editor[editor].append(m.group(1))
                else:
                    anonymous += 1
    return by_editor, anonymous


orig, orig_anon = scan(os.path.join(W, "campfire-orig"))
esl, esl_anon = scan(os.path.join(W, "campfire-esl"))
mapping, bad = {}, []
for editor, ids in orig.items():
    if len(ids) == 1 and editor in esl and len(esl[editor]) == 1:
        mapping[ids[0]] = esl[editor][0]
    else:
        bad.append(editor)
if bad or set(orig) != set(esl):
    sys.exit(f"cannot pair uniquely: {bad[:10]} (only in one plugin: {sorted(set(orig) ^ set(esl))[:10]})")
json.dump(mapping, open(os.path.join(W, "map_full.json"), "w"))
print(f"mapped {len(mapping)} records by EditorID; records without an EditorID (not mapped): original {orig_anon}, ESL {esl_anon}")
