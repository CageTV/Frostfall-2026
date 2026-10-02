"""Compile single scripts with the same imports as build_scripts.py (with a timeout, to find a compiler hang).
Usage: python tools/compile_one.py Name.psc [Name2.psc ...]"""
import os, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_scripts as b
out = os.path.join(b.HERE, "build", "scripts-one"); os.makedirs(out, exist_ok=True)
for name in sys.argv[1:]:
    cmd = [b.COMPILER, name, f"-f={b.FLAGS}", "-i=" + ";".join(b.IMPORTS), f"-o={out}"]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=90, cwd=os.path.join(b.HERE, "src", "scripts"))
        tail = [l for l in (r.stdout + r.stderr).splitlines() if l.strip()][-3:]
        print(name, "exit", r.returncode, "|", " / ".join(tail))
    except subprocess.TimeoutExpired:
        print(name, "TIMEOUT (compiler hang)")
        subprocess.run(["taskkill", "/F", "/IM", "PapyrusCompiler.exe"], capture_output=True)
