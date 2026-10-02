"""ESL build, step 7: INI / JSON files that point into Campfire.esm by FormID.
  - FormList Manipulator lines:  FormList = 0x28F02~Campfire.esm|...   -> the id of the matching record in the ESL Campfire
  - MFO (marth Follower Overhaul) items:  "plugin": "campfire.esm", "id": "0x0415D7"
Library used by esl_step5_package.py for the shipped Frostfall_Embers_FLM.ini (remap_file / remap_text).
"""
import json, os, re, sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MC = json.load(open(os.path.join(HERE, "esl-work", "map_full.json")))
FLM = re.compile(r"0x([0-9A-Fa-f]+)~(Campfire\.esm)", re.I)
MFO = re.compile(r'("plugin"\s*:\s*"campfire\.esm"\s*,\s*"id"\s*:\s*")0x([0-9A-Fa-f]+)(")', re.I)
unmapped = []


def new_id(old):
    key = f"{int(old, 16) & 0xFFFFFF:06X}"
    if key not in MC:
        unmapped.append(old)
        return None
    return MC[key]


def remap_text(t):
    def f(m):
        n = new_id(m.group(1))
        return m.group(0) if n is None else f"0x{n}~{m.group(2)}"

    def g(m):
        n = new_id(m.group(2))
        return m.group(0) if n is None else f"{m.group(1)}0x{n}{m.group(3)}"
    return MFO.sub(g, FLM.sub(f, t))


def remap_file(src, dst=None):
    t = open(src, encoding="utf-8", newline="").read()
    t2 = remap_text(t)
    if unmapped:
        sys.exit(f"UNMAPPED ids in {src}: {unmapped}")
    open(dst or src, "w", encoding="utf-8", newline="").write(t2)
    return sum(1 for a, b in zip(t.splitlines(), t2.splitlines()) if a != b)
