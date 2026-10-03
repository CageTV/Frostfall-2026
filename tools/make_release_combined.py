"""Builds ONE FOMOD installer per Frostfall 2026 download that covers the regular and the ESL build:
  Frostfall 2026 <ver>.zip              (main)
  Frostfall 2026 - Leather Tent <ver>.zip (add-on)
Files identical in both builds are installed always (common/); the ones that differ (plugin, DLL, rebuilt scripts) sit in regular/ and esl/.
Everything is taken from the published regular and ESL zips (release-src/), so each choice installs byte-identical content to them.
Usage: python tools/make_release_combined.py <main version> <leather tent version>
"""
import hashlib
import os
import sys
import xml.dom.minidom
import zipfile
from xml.sax.saxutils import escape

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(HERE, "release-src")
OUT = os.path.join(HERE, "release")
os.makedirs(OUT, exist_ok=True)
md5 = lambda z, n: hashlib.md5(z.read(n)).hexdigest()
files = lambda z: {n for n in z.namelist() if not n.endswith("/")}


def text(z, n):
    b = z.read(n)
    try:
        return b.decode("utf-8")
    except UnicodeDecodeError:
        return b.decode("cp1252")


def build(title, reg_zip, esl_zip, version, reg_desc, esl_desc, readme_intro, esl_fix=lambda s: s):
    reg, esl = zipfile.ZipFile(os.path.join(SRC, reg_zip)), zipfile.ZipFile(os.path.join(SRC, esl_zip))
    A, B = files(reg), files(esl)
    assert A == B, (sorted(A ^ B))
    A.discard("README.txt")
    same = sorted(n for n in A if md5(reg, n) == md5(esl, n))
    diff = sorted(n for n in A if md5(reg, n) != md5(esl, n))
    config = f"""<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://qconsulting.ca/fo3/ModConfig5.0.xsd">
  <moduleName>{escape(title)}</moduleName>
  <requiredInstallFiles>
    <folder source="common" destination=""/>
    <file source="README.txt" destination="{escape(title)} README.txt"/>
  </requiredInstallFiles>
  <installSteps order="Explicit">
    <installStep name="Build">
      <optionalFileGroups>
        <group name="Which build do you want?" type="SelectExactlyOne">
          <plugins order="Explicit">
            <plugin name="Regular">
              <description>{escape(reg_desc)}</description>
              <conditionFlags><flag name="build">regular</flag></conditionFlags>
              <typeDescriptor><type name="Recommended"/></typeDescriptor>
            </plugin>
            <plugin name="ESL">
              <description>{escape(esl_desc)}</description>
              <conditionFlags><flag name="build">esl</flag></conditionFlags>
              <typeDescriptor><type name="Optional"/></typeDescriptor>
            </plugin>
          </plugins>
        </group>
      </optionalFileGroups>
    </installStep>
  </installSteps>
  <conditionalFileInstalls>
    <patterns>
      <pattern><dependencies><flagDependency flag="build" value="regular"/></dependencies><files><folder source="regular" destination=""/></files></pattern>
      <pattern><dependencies><flagDependency flag="build" value="esl"/></dependencies><files><folder source="esl" destination=""/></files></pattern>
    </patterns>
  </conditionalFileInstalls>
</config>
"""
    info = (f"<fomod><Name>{escape(title)}</Name><Author>CageTV (Frostfall by Chesko)</Author><Version>{version}</Version>"
            "<Website>https://github.com/CageTV/Frostfall-2026</Website>"
            f"<Description>{escape(title)}, regular and ESL, in one installer.</Description></fomod>\n")
    xml.dom.minidom.parseString(config)
    xml.dom.minidom.parseString(info)
    rr, er = text(reg, "README.txt"), esl_fix(text(esl, "README.txt"))
    readme = f"{title} {version}\n\n{readme_intro}\n\n=== REGULAR BUILD ===\n\n{rr.strip()}\n\n\n=== ESL BUILD ===\n\n{er.strip()}\n"
    out = os.path.join(OUT, f"{title} {version}.zip")
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("fomod/info.xml", info)
        z.writestr("fomod/ModuleConfig.xml", config)
        z.writestr("README.txt", readme.encode("utf-8"))
        for n in same:
            z.writestr("common/" + n, reg.read(n))
        for n in diff:
            z.writestr("regular/" + n, reg.read(n))
            z.writestr("esl/" + n, esl.read(n))
    chk = zipfile.ZipFile(out)
    for name, src in (("regular", reg), ("esl", esl)):
        got = {n[7:]: chk.read(n) for n in chk.namelist() if n.startswith("common/")}
        got.update({n[len(name) + 1:]: chk.read(n) for n in chk.namelist() if n.startswith(name + "/")})
        assert got == {n: src.read(n) for n in A}, name
    print(f"{out}: {len(same)} shared + {len(diff)} per-build; both builds byte-identical to the published zips; {os.path.getsize(out) // 1024} KB")


def esl_main_fix(t):
    old = ('- Campfire - Complete Camping System 1.12.1 (Nexus 667) — the ORIGINAL release (it supplies the archive, meshes and textures),\n'
           '  with "CAMPFIRE ESL UPDATED" (Nexus 193472) on top of it (its Campfire.esm replaces the original, ESL-flagged), and\n'
           '  "Campfire ESL - Script Fixes" (a separate download, below them in the mod list\'s priority): Campfire\'s own scripts still\n'
           '  look records up by their old FormIDs, which the ESL Campfire changed.')
    new = ('- Campfire - Complete Camping System 1.12.1 (Nexus 667) — the ORIGINAL release (it supplies the archive, meshes and textures),\n'
           '  with Campfire 2026 on top of it, installed with its ESL option (its Campfire.esm is ESL-flagged and its rebuilt scripts look records\n'
           '  up by the new FormIDs). "CAMPFIRE ESL UPDATED" and "Campfire ESL - Script Fixes" are no longer needed: Campfire 2026 replaces both.\n'
           '  Install order: Campfire, Campfire 2026, then Frostfall 2026 (below it), then Last Seed 2026. Frostfall 2026 overrides CampCampfire.pex on purpose.')
    assert old in t, "ESL requirement text not found"
    return t.replace(old, new)


mv, tv = sys.argv[1], sys.argv[2]
build("Frostfall 2026", "Frostfall.2026.4.1.0.zip", "Frostfall.2026.4.1.0.ESL.zip", mv,
      "The normal build: Frostfall.esp as a regular plugin with the original FormIDs. Works with existing saves and with patches made for Frostfall.",
      "Frostfall.esp as a light (ESL) plugin with renumbered records. New game only, and only with the ESL build of Campfire 2026. Never mix it with the regular build.",
      "One installer for both builds: it asks Regular or ESL. The README below has both builds' texts; read the one you pick.", esl_main_fix)
build("Frostfall 2026 - Leather Tent", "Frostfall.2026.-.Leather.Tent.1.0.0.zip", "Frostfall.2026.-.Leather.Tent.1.0.0.ESL.zip", tv,
      "For the regular Frostfall 2026. Its plugin is already light-flagged and takes no regular slot.",
      "For Frostfall 2026 (ESL), the new-game build. Pick the same build as your Frostfall 2026.",
      "One installer for both builds: it asks Regular or ESL (pick the same as your Frostfall 2026).")
