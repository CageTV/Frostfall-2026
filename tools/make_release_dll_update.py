"""Builds the Frostfall 2026 DLL update: only Frostfall.dll, in the four builds (new / older x regular / ESL), for installing over Frostfall 2026 4.1.x.

  python tools/make_release_dll_update.py 4.2.0   -> release/Frostfall 2026 4.2.0.zip

The installer asks Regular or ESL (the same as the installed Frostfall.esp), then which Frostfall.dll (new: Skyrim 1.6.1170 and newer; older: Skyrim VR or
1.6.1130 and older). Needs the four DLLs: ng-build/build/release/out/Frostfall{Regular,ESL}/Frostfall.dll and plugin/build/release{,-esl}/Frostfall.dll.
"""
import os
import sys
import xml.dom.minidom
import zipfile

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
version = sys.argv[1]
NEW_VER = "1.6.1170.0"
DLL_NAME = "SKSE/Plugins/Frostfall.dll"
DLLS = {("new", "regular"): os.path.join(HERE, "..", "ng-build", "build", "release", "out", "FrostfallRegular", "Frostfall.dll"),
        ("new", "esl"): os.path.join(HERE, "..", "ng-build", "build", "release", "out", "FrostfallESL", "Frostfall.dll"),
        ("older", "regular"): os.path.join(HERE, "plugin", "build", "release", "Frostfall.dll"),
        ("older", "esl"): os.path.join(HERE, "plugin", "build", "release-esl", "Frostfall.dll")}
for k, d in DLLS.items():
    assert os.path.isfile(d), f"missing {k} DLL: {d}"

readme = open(os.path.join(HERE, "docs", "DLL_UPDATE_README.txt"), encoding="utf-8").read().replace("@VERSION@", version)

patterns = "".join(
    f'      <pattern><dependencies operator="And"><flagDependency flag="build" value="{b}"/><flagDependency flag="dll" value="{d}"/></dependencies>'
    f'<files><folder source="dll-{d}-{b}" destination=""/></files></pattern>\n'
    for d in ("new", "older") for b in ("regular", "esl"))
config = f"""<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://qconsulting.ca/fo3/ModConfig5.0.xsd">
  <moduleName>Frostfall 2026 {version}</moduleName>
  <requiredInstallFiles>
    <file source="README.txt" destination="Frostfall 2026 {version} README.txt"/>
    <file source="LICENSE.txt" destination="Frostfall 2026 {version} LICENSE.txt"/>
  </requiredInstallFiles>
  <installSteps order="Explicit">
    <installStep name="Build">
      <optionalFileGroups>
        <group name="Which build of Frostfall 2026 do you have?" type="SelectExactlyOne">
          <plugins order="Explicit">
            <plugin name="Regular">
              <description>The normal build: Frostfall.esp as a regular plugin.</description>
              <conditionFlags><flag name="build">regular</flag></conditionFlags>
              <typeDescriptor><type name="Recommended"/></typeDescriptor>
            </plugin>
            <plugin name="ESL">
              <description>The ESL build: Frostfall.esp as a light plugin with renumbered records. Pick the same as the one you installed.</description>
              <conditionFlags><flag name="build">esl</flag></conditionFlags>
              <typeDescriptor><type name="Optional"/></typeDescriptor>
            </plugin>
          </plugins>
        </group>
      </optionalFileGroups>
    </installStep>
    <installStep name="Game version">
      <optionalFileGroups order="Explicit">
        <group name="Which Frostfall.dll do you want?" type="SelectExactlyOne">
          <plugins order="Explicit">
            <plugin name="Skyrim 1.6.1170 and newer (SE / AE)">
              <description>The new build. Works on Skyrim SE/AE 1.6.1170 and on every later version, including 1.7.x.</description>
              <conditionFlags><flag name="dll">new</flag></conditionFlags>
              <typeDescriptor><dependencyType><defaultType name="Optional"/><patterns>
                <pattern><dependencies><gameDependency version="{NEW_VER}"/></dependencies><type name="Recommended"/></pattern>
              </patterns></dependencyType></typeDescriptor>
            </plugin>
            <plugin name="Skyrim VR, or 1.6.1130 and older">
              <description>The older build, for Skyrim VR and for SE/AE 1.6.1130 and older. On 1.6.1170 either build works.</description>
              <conditionFlags><flag name="dll">older</flag></conditionFlags>
              <typeDescriptor><dependencyType><defaultType name="Recommended"/><patterns>
                <pattern><dependencies><gameDependency version="{NEW_VER}"/></dependencies><type name="Optional"/></pattern>
              </patterns></dependencyType></typeDescriptor>
            </plugin>
          </plugins>
        </group>
      </optionalFileGroups>
    </installStep>
  </installSteps>
  <conditionalFileInstalls>
    <patterns>
{patterns}    </patterns>
  </conditionalFileInstalls>
</config>
"""
info = (f"<fomod><Name>Frostfall 2026 {version}</Name><Author>CageTV (Frostfall by Chesko)</Author><Version>{version}</Version>"
        "<Website>https://github.com/CageTV/Frostfall-2026</Website><Description>Frostfall.dll update for Frostfall 2026 4.1.x: choose Regular or ESL, and the DLL for your game version.</Description></fomod>")
xml.dom.minidom.parseString(config)
xml.dom.minidom.parseString(info)

out = os.path.join(HERE, "release", f"Frostfall 2026 {version}.zip")
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("fomod/info.xml", info)
    z.writestr("fomod/ModuleConfig.xml", config)
    z.writestr("README.txt", readme)
    z.write(os.path.join(HERE, "LICENSE.txt"), "LICENSE.txt")
    for (d, b), path in DLLS.items():
        z.write(path, f"dll-{d}-{b}/{DLL_NAME}")
print(out, os.path.getsize(out) // 1024, "KB")
