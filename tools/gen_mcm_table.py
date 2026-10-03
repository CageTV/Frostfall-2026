"""Writes plugin/src/McmTable.h: the settings of Frostfall's SkyUI menu as data for Frostfall.dll's SKSE Menu Framework pages.

Inputs, all from Chesko's MIT-licensed Frostfall (as rebuilt in this repo): the plugin (src/plugin/Frostfall, Spriggit YAML) for each setting's global
FormID, the English strings (Frostfall_ENGLISH.txt) for labels and hover text, and the menu script (src/scripts/_Frost_SkyUIConfigPanelScript.psc)
for which hover text belongs to which option and for the profile keys. The layout below is transcribed from that script's PageReset_Gameplay,
PageReset_Interface and PageReset_Advanced; every profile key is checked against the script so a typo cannot slip through.
The ESL build (FROSTFALL_ESL) uses the new FormIDs of esl/map_frostfall.json; both ids are written next to each other.

Usage: python tools/gen_mcm_table.py
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ESP = os.path.join(HERE, "src", "plugin", "Frostfall")
PSC = os.path.join(HERE, "src", "scripts", "_Frost_SkyUIConfigPanelScript.psc")
STR = r"E:\WorkSpace\Frostfall-Modernized\upstream-chesko\Interface\Translations\Frostfall_ENGLISH.txt"
ESLMAP = os.path.join(HERE, "esl", "map_frostfall.json")
OUT = os.path.join(HERE, "plugin", "src", "McmTable.h")

strings = {}
for line in open(STR, encoding="utf-16").read().splitlines():
    if line.startswith("$") and "\t" in line:
        k, v = line.split("\t", 1)
        strings[k] = v.strip()


def s(key):
    if key not in strings:
        sys.exit(f"missing string {key}")
    return strings[key]


psc = open(PSC, encoding="utf-8", errors="replace").read()
tips = {}
for m in re.finditer(r"option == (\w+)\s*\n\s*SetInfoText\(\"(\$\w+)\"\)", psc):
    tips[m.group(1)] = m.group(2)

eslmap = json.load(open(ESLMAP))
globs = {}
for fn in os.listdir(os.path.join(ESP, "Globals")):
    m = re.match(r"(.+) - ([0-9A-F]{6})_Frostfall\.esp\.yaml$", fn)
    if m:
        globs[m.group(1)] = m.group(2)
quest = re.match(r".+ - ([0-9A-F]{6})_Frostfall\.esp\.yaml$", "_Frost_SkyUIConfigPanel - 06DCF8_Frostfall.esp.yaml").group(1)
assert os.path.exists(os.path.join(ESP, "Quests", "_Frost_SkyUIConfigPanel - 06DCF8_Frostfall.esp.yaml"))


def gid(eid):
    """C++ expression for the global's local FormID: regular id, or the ESL one in the ESL build."""
    if eid not in globs:
        sys.exit(f"no global named {eid} in the plugin")
    old = globs[eid]
    if old not in eslmap:
        sys.exit(f"{eid} ({old}) is not in the ESL map")
    return f"FF_ID(0x{old}, 0x{eslmap[old]})"


T, H, C, S, M, K = "Toggle", "Header", "Column", "Slider", "Menu", "Key"
G = "_Frost_Setting_"
# Toggle: (T, oid, label, global, profile key, gate global or None, special)
# Key:    (K, oid, label, global, profile key, hotkey slot)
# Slider: (S, oid, label, global, profile key, min, max, step, format, float profile value)
# Menu:   (M, oid, label, global, profile key, [option labels], base)
# special: 1 = shown ticked and greyed while "no waiting" is on, 2 = hidden when the optional SkyUI interface package shows these itself
pages = [
    ("Gameplay", [
        (H, None, "$FrostfallGameplayHeaderPlayer"),
        (S, "Gameplay_ExposureRate_OID", "$FrostfallGameplaySettingExposureRate", G + "ExposureRate", "exposure_rate", 0.0, 3.0, 0.1, "%.1fx", 1),
        (M, "Gameplay_MaxExposureMode_OID", "$FrostfallGameplaySettingPlayerExposureMode", G + "MaxExposureMode", "max_exposure_mode",
         ["$FrostfallMaxExposureNothing", "$FrostfallMaxExposureRescue", "$FrostfallMaxExposureDeath"], 1),
        (T, "Gameplay_FrigidWater_OID", "$FrostfallGameplaySettingExposureWaterLethality", G + "FrigidWaterIsLethal", "frigid_water_is_lethal", None, 0),
        (T, "Gameplay_ExposurePauseDialogue_OID", "$FrostfallGameplaySettingExposureDialoguePause", G + "ExposurePauseDialogue", "exposure_pause_dialogue", None, 0),
        (T, "Gameplay_ExposurePauseCombat_OID", "$FrostfallGameplaySettingExposureCombatPause", G + "ExposurePauseCombat", "exposure_pause_combat", None, 0),
        (T, "Gameplay_MovementPenalty_OID", "$FrostfallGameplaySettingPlayerMovement", G + "MovementPenalty", "movement_penalty", None, 0),
        (M, "Gameplay_VampirismMode_OID", "$FrostfallGameplaySettingPlayerVampirism", G + "VampireMode", "vampire_mode",
         ["$FrostfallVampirismHuman", "$FrostfallVampirismSuperhuman", "$FrostfallVampirismImmortal"], 0),
        (H, None, "$FrostfallGameplayHeaderFastTravel"),
        (T, "Gameplay_DisableFT_OID", "$FrostfallGameplaySettingFTToggle", G + "NoFastTravel", "no_fast_travel", G + "NoWaiting", 1),
        (T, "Gameplay_DisableWaiting_OID", "$FrostfallGameplaySettingFTWaiting", G + "NoWaiting", "no_waiting", None, 0),
        (H, None, "$FrostfallGameplayHeaderHotkeys"),
        (K, "Gameplay_WeathersenseHotkey_OID", "$FrostfallHotkeyWeathersense", "_Frost_HotkeyWeathersense", "hotkey_weathersense", 0),
    ]),
    ("Interface", [
        (H, None, "$FrostfallInterfaceHeaderEffects"),
        (T, "Interface_FrostShaderOn_OID", "$FrostfallInterfaceSettingFrostShader", G + "FrostShaderOn", "frost_shader_on", None, 0),
        (T, "Interface_WetShaderOn_OID", "$FrostfallInterfaceSettingWetShader", G + "WetShaderOn", "wet_shader_on", None, 0),
        (T, "Interface_SoundEffects_OID", "$FrostfallInterfaceSettingSoundEffects", G + "SoundEffects", "sound_effects", None, 0),
        (T, "Interface_FullScreenEffects_OID", "$FrostfallInterfaceSettingImagespaceModifiers", G + "FullScreenEffects", "full_screen_effects", None, 0),
        (T, "Interface_ForceFeedback_OID", "$FrostfallInterfaceSettingForceFeedback", G + "ForceFeedback", "force_feedback", None, 0),
        (M, "Interface_Animation_OID", "$FrostfallInterfaceSettingAnimation", G + "Animation", "animation",
         ["$FrostfallOff", "$FrostfallAnimationAuto", "$FrostfallAnimationPrompt"], 1),
        (T, "Interface_FollowerAnimation_OID", "$FrostfallInterfaceSettingFollowerAnimation", G + "FollowerAnimation", "follower_animation", None, 0),
        (H, None, "$FrostfallInterfaceHeaderNotifications"),
        (T, "Interface_ConditionMessages_OID", "$FrostfallInterfaceSettingCondition", G + "ConditionMessages", "condition_messages", None, 0),
        (T, "Interface_WeatherMessages_OID", "$FrostfallInterfaceSettingWeather", G + "WeatherMessages", "weather_messages", None, 0),
        (M, "Interface_WeathersenseDisplayMode_OID", "$FrostfallInterfaceSettingWeathersenseDisplayMode", G + "WeathersenseDisplayMode", "weathersense_display_mode",
         ["$FrostfallWeathersenseDisplayMessageOnly", "$FrostfallWeathersenseDisplayMetersOnly", "$FrostfallWeathersenseDisplayMessageMeters"], 0),
        (T, "Interface_DisplayAttributesInWeathersense_OID", "$FrostfallInterfaceSettingWeathersense", G + "DisplayAttributesInWeathersense", "display_attributes_in_weathersense", None, 0),
        (T, "Interface_DisplayAttributeValuesInWeathersense_OID", "$FrostfallInterfaceSettingWeathersenseDetail", G + "DisplayAttributeValuesInWeathersense", "display_attribute_values_in_weathersense",
         G + "DisplayAttributesInWeathersense", 0),
        (T, "Interface_Notifications_EquipmentValues_OID", "$FrostfallInterfaceSettingEquipmentValues", G + "Notifications_EquipmentValues", "notification_equipmentvalues", None, 2),
        (T, "Interface_Notifications_EquipmentSummary_OID", "$FrostfallInterfaceSettingEquipmentSummary", G + "Notifications_EquipmentSummary", "notification_equipmentsummary", None, 2),
    ]),
    ("Advanced", [
        (H, None, "$FrostfallAdvancedHeaderTutorials"),
        (T, "Advanced_TutorialsToggle_OID", "$FrostfallAdvancedSettingTutorialsShow", G + "DisplayTutorials", "display_tutorials", None, 0),
    ]),
]


def q(t):
    t = t.replace('\\n', chr(10))  # the strings file spells a line break as backslash-n
    return '"' + t.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n") + '"'


lists, rows, errors = {}, [], []
BLANK = '0, 0, 0, 0, "", nullptr, 0, 0, 0, 0, ""'
for title, entries in pages:
    out = []
    for e in entries:
        kind = e[0]
        if kind == H:
            out.append(f'{{ Kind::Header, {q(s(e[2]))}, 0, "", {BLANK} }}')
            continue
        if kind == C:
            out.append(f'{{ Kind::Column, "", 0, "", {BLANK} }}')
            continue
        oid, label, g, key = e[1], e[2], e[3], e[4]
        if f'"{key}"' not in psc:
            errors.append(f"profile key {key} not found in the menu script")
        tip = s(tips[oid]) if oid in tips else ""
        if not tip and oid != "Advanced_TutorialsToggle_OID":  # the original has no hover text for it either
            errors.append(f"no hover text for {oid}")
        lab = q(s(label))
        # Entry: kind, label, formId, profileKey, min, max, step, isFloat, format, options, optionCount, menuBase, gate, special, tip
        if kind == T:
            gate, special = e[5], e[6]
            gate_id = gid(gate) if gate else "0"
            out.append(f'{{ Kind::Toggle, {lab}, {gid(g)}, "{key}", 0, 0, 0, 0, "", nullptr, 0, 0, {gate_id}, {special}, {q(tip)} }}')
        elif kind == S:
            out.append(f'{{ Kind::Slider, {lab}, {gid(g)}, "{key}", {e[5]}f, {e[6]}f, {e[7]}f, {e[9]}, {q(e[8])}, nullptr, 0, 0, 0, 0, {q(tip)} }}')
        elif kind == M:
            name = f"kList_{oid}"
            lists[name] = [s(x) for x in e[5]]
            out.append(f'{{ Kind::Menu, {lab}, {gid(g)}, "{key}", 0, 0, 0, 0, "", {name}, {len(e[5])}, {e[6]}, 0, 0, {q(tip)} }}')
        elif kind == K:
            out.append(f'{{ Kind::Key, {lab}, {gid(g)}, "{key}", {e[5]}, 0, 0, 0, "", nullptr, 0, 0, 0, 0, {q(tip)} }}')
    rows.append((title, out))
if errors:
    sys.exit("\n".join(errors))

extra = {n: gid(n) for n in ("_Frost_Setting_AutoSaveLoad", "_Frost_Setting_CurrentProfile", "EndurancePerkPointsTotal", "_Frost_HelpDone_Exposure",
                              "_Frost_HelpDone_Wet", "_Frost_HelpDone_Cold", "_Frost_DatastoreInitialized")} if "_Frost_DatastoreInitialized" in globs else None
if extra is None:
    sys.exit("no global named _Frost_DatastoreInitialized")
q_new = eslmap[quest]

with open(OUT, "w", encoding="utf-8", newline="\n") as f:
    f.write("// GENERATED by tools/gen_mcm_table.py from Frostfall's own MCM script, Frostfall.esp and English strings. Do not edit by hand.\n")
    f.write("// Frostfall is by Chesko; its scripts and plugin are MIT licensed (the meshes and textures are not part of this).\n#pragma once\n\n#include <iterator>\n\n")
    f.write("// The local FormID of a record in Frostfall.esp: the first value in the regular build, the second (compacted) one in the ESL build.\n")
    f.write("#ifdef FROSTFALL_ESL\n#define FF_ID(regular, esl) esl\n#else\n#define FF_ID(regular, esl) regular\n#endif\n\n")
    f.write("namespace mcm\n{\n\tenum class Kind { Header, Column, Toggle, Slider, Menu, Key };\n\n")
    f.write("\t// One row of a page. formId is the local FormID of the setting's global (0 for headers and column breaks).\n")
    f.write("\t// Toggles hold 1 (off) or 2 (on). A menu stores its list position plus menuBase. Slider: min, max, step; isFloat = saved to the profile as a\n")
    f.write("\t// float. Key: min holds the hotkey slot. gate: the row is greyed out unless this global is 2. special: 1 = shown ticked and greyed while\n")
    f.write("\t// \"no waiting\" is on, 2 = hidden when the optional SkyUI interface package shows these notifications itself.\n")
    f.write("\tstruct Entry\n\t{\n\t\tKind        kind;\n\t\tconst char* label;\n\t\tunsigned    formId;\n\t\tconst char* profileKey;\n\t\tfloat       min, max, step;\n\t\tint         isFloat;\n\t\tconst char* format;\n")
    f.write("\t\tconst char* const* options;\n\t\tint         optionCount;\n\t\tint         menuBase;\n\t\tunsigned    gate;\n\t\tint         special;\n\t\tconst char* tip;\n\t};\n\n")
    f.write("\tstruct Page\n\t{\n\t\tconst char*  title;\n\t\tconst Entry* entries;\n\t\tint          count;\n\t};\n\n")
    f.write("\tinline constexpr unsigned kMcmQuest = FF_ID(0x%s, 0x%s);\n" % (quest, q_new))
    for n, expr in extra.items():
        f.write(f"\tinline constexpr unsigned k{n.lstrip('_').replace('_', '')} = {expr};\n")
    f.write("\n")
    for name, opts in lists.items():
        f.write(f"\tinline constexpr const char* {name}[] = {{ " + ", ".join(q(o) for o in opts) + " };\n")
    f.write("\n")
    for i, (title, out) in enumerate(rows):
        f.write(f"\tinline constexpr Entry kPage{i}[] = {{\n")
        for line in out:
            f.write(f"\t\t{line},\n")
        f.write("\t};\n")
    f.write("\n\tinline constexpr Page kPages[] = {\n")
    for i, (title, out) in enumerate(rows):
        f.write(f'\t\t{{ "{title}", kPage{i}, static_cast<int>(std::size(kPage{i})) }},\n')
    f.write("\t};\n}\n")
print(f"wrote {OUT}: " + ", ".join(f"{t} {len(o)} rows" for t, o in rows))
