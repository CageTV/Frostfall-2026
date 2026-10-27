"""Builds the REGULAR Frostfall.esp: src/plugin/Frostfall plus the leather camp overlay (src/plugin-tent), via the Spriggit wrapper.

  python tools/build_regular_plugin.py [--no-tent]    -> build/regular/Frostfall.esp

--no-tent builds the plain plugin, to check that the build reproduces release-contents/Frostfall.esp. The ESL plugin is built by the
tools/esl_step*.py chain from src/plugin/Frostfall only and never contains the overlay.
"""
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLKIT = r"E:\Tabula Rasa\mods\Skyrim-Claude Code Modder's Toolkit"
WRAPPER = TOOLKIT.replace("\\", "/") + "/tools/spriggit-cli.sh"
tent = "--no-tent" not in sys.argv
stage = os.path.join(HERE, "build", "regular-src")
out_dir = os.path.join(HERE, "build", "regular")
if os.path.exists(stage):
    shutil.rmtree(stage)
shutil.copytree(os.path.join(HERE, "src", "plugin", "Frostfall"), os.path.join(stage, "Frostfall.esp"))
if tent:
    shutil.copytree(os.path.join(HERE, "src", "plugin-tent"), os.path.join(stage, "Frostfall.esp"), dirs_exist_ok=True)
os.makedirs(out_dir, exist_ok=True)
esp = os.path.join(out_dir, "Frostfall.esp")
if os.path.exists(esp):
    os.remove(esp)
cmd = ["bash", WRAPPER, "deserialize", "--InputPath", os.path.join(stage, "Frostfall.esp").replace("\\", "/"), "--OutputPath", esp.replace("\\", "/")]
r = subprocess.run(cmd, capture_output=True, text=True)
print((r.stdout or "")[-600:], (r.stderr or "")[-600:])
print("built" if os.path.exists(esp) else "FAILED", esp, os.path.getsize(esp) if os.path.exists(esp) else "")
sys.exit(0 if os.path.exists(esp) else 1)
