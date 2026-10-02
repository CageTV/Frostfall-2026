"""Compile every Frostfall script in src/scripts with the official Papyrus compiler.

Import order matters: our sources first (so they win), then Campfire's sources (Chesko's MIT repo), then SDK/framework
sources (SkyUI, SKSE, PapyrusUtil, Papyrus Extender, FISSES), then vanilla. Nothing is written outside build/.
Usage: python tools/build_scripts.py [out_dir]
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GAME = r"E:\Tabula Rasa\Stock Game"
MODS = r"E:\Tabula Rasa\mods"

COMPILER = os.path.join(GAME, "Papyrus Compiler", "PapyrusCompiler.exe")
FLAGS = os.path.join(GAME, "Data", "Source", "Scripts", "TESV_Papyrus_Flags.flg")
IMPORTS = [
    os.path.join(HERE, "src", "scripts"),
    os.path.join(HERE, "upstream-chesko", "Scripts", "Source"),          # Campfire (+ Chesko's shared code)
    os.path.join(HERE, "imports", "skyui"),                              # SkyUI SDK (compile-time only)
    os.path.join(HERE, "imports", "chesko-shared"),                      # CheskoPapyrusShared (MIT) - FallbackEvent*, Common*
    os.path.join(HERE, "imports", "stubs"),                              # compile-only stubs for optional third-party types
    os.path.join(MODS, "Skyrim Script Extender (SKSE64)", "Scripts", "Source"),
    os.path.join(MODS, "PapyrusUtil SE - Modders Scripting Utility Functions", "Scripts", "Source"),
    os.path.join(MODS, "powerofthree's Papyrus Extender", "Source", "scripts"),
    os.path.join(MODS, "FileAccess Interface for Skyrim SE Scripts - FISSES", "scripts", "source"),
    os.path.join(GAME, "Data", "Source", "Scripts"),                     # vanilla
]


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "build", "scripts")
    os.makedirs(out, exist_ok=True)
    for p in [COMPILER, FLAGS] + IMPORTS:
        if not os.path.exists(p):
            raise SystemExit(f"missing: {p}")
    # One compiler run per script: the compiler's own batch mode (-all) deadlocked on this source set (2026-09-30),
    # while every script compiled on its own. A per-file timeout turns any future hang into a named failure.
    src_dir = os.path.join(HERE, "src", "scripts")
    log, rc = "", 0
    for name in sorted(n for n in os.listdir(src_dir) if n.lower().endswith(".psc")):
        cmd = [COMPILER, name, f"-f={FLAGS}", "-i=" + ";".join(IMPORTS), f"-o={out}"]
        try:
            r = subprocess.run(cmd, capture_output=True, text=True, cwd=src_dir, timeout=120)
            log += (r.stdout or "") + (r.stderr or "")
            rc = rc or r.returncode
        except subprocess.TimeoutExpired:
            subprocess.run(["taskkill", "/F", "/IM", "PapyrusCompiler.exe"], capture_output=True)
            log += f"{name}: compilation failed (compiler hang, killed after 120 s)\n"
            rc = 1
    r = type("R", (), {"returncode": rc})()
    with open(os.path.join(HERE, "build", "compile.log"), "w", encoding="utf-8") as f:
        f.write(log)
    srcs = [n for n in os.listdir(os.path.join(HERE, "src", "scripts")) if n.lower().endswith(".psc")]
    pexs = [n for n in os.listdir(out) if n.lower().endswith(".pex")]
    errors = [l for l in log.splitlines() if ".psc(" in l or "compilation failed" in l.lower()]
    print(f"compiler exit {r.returncode}: {len(pexs)} .pex from {len(srcs)} .psc; {len(errors)} error lines (full log: build/compile.log)")
    for l in errors[:25]:
        print("  " + l)
    sys.exit(0 if r.returncode == 0 and not errors else 1)


if __name__ == "__main__":
    main()
