"""Builds Frostfall.esp from Spriggit YAML with the Spriggit wrapper of the modding toolkit.

  python tools/build_plugin.py regular   src/plugin/Frostfall      -> build/regular/Frostfall.esp
  python tools/build_plugin.py esl       esl-work/out/Frostfall    -> build/esl/Frostfall.esp   (the output of tools/esl_step1 and esl_step2: renumbered, flagged ESL)

Both builds carry the Leather Tent records (_FrostLeather_*, 095020 - 095022 in the regular numbering).
"""
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLKIT = r"E:\Tabula Rasa\mods\Skyrim-Claude Code Modder's Toolkit"
WRAPPER = TOOLKIT.replace("\\", "/") + "/tools/spriggit-cli.sh"
kind = sys.argv[1] if len(sys.argv) > 1 else "regular"
src = {"regular": os.path.join(HERE, "src", "plugin", "Frostfall"), "esl": os.path.join(HERE, "esl-work", "out", "Frostfall")}[kind]
stage = os.path.join(HERE, "build", kind + "-src")
out_dir = os.path.join(HERE, "build", kind)
if os.path.exists(stage):
    shutil.rmtree(stage)
shutil.copytree(src, os.path.join(stage, "Frostfall.esp"))
os.makedirs(out_dir, exist_ok=True)
esp = os.path.join(out_dir, "Frostfall.esp")
if os.path.exists(esp):
    os.remove(esp)
cmd = ["bash", WRAPPER, "deserialize", "--InputPath", os.path.join(stage, "Frostfall.esp").replace("\\", "/"), "--OutputPath", esp.replace("\\", "/")]
r = subprocess.run(cmd, capture_output=True, text=True)
print((r.stdout or "")[-400:], (r.stderr or "")[-400:])
print("built" if os.path.exists(esp) else "FAILED", esp, os.path.getsize(esp) if os.path.exists(esp) else "")
sys.exit(0 if os.path.exists(esp) else 1)
