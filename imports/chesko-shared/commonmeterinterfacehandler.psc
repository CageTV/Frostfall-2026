; COMPILE-TIME IMPORT ONLY (never shipped). Decompiled from the shipped script; defaults restored from source/evidence.
ScriptName CommonMeterInterfaceHandler Extends Quest

;-- Variables ---------------------------------------
Int display_iterations_remaining = 0
Float last_attribute_value = 0.0
Bool meter_displayed = False
Bool should_update = False

;-- Properties --------------------------------------
GlobalVariable Property AttributeMax Auto
{ The global that contains the maximum value for this attribute. }
GlobalVariable Property AttributeValue Auto
{ The global that contains the attribute for this meter. }
GlobalVariable Property AuxPrimaryColor Auto
{ Setting global for aux (inversion) color. }
GlobalVariable Property AuxSecondaryColor Auto
{ Setting global for aux (inversion) color. }
GlobalVariable Property DebugGlobal Auto
{ The debug global. 0 = Debug, 1 = Info, 2 = Warning, 3 = Error. }
GlobalVariable Property DisplayMode Auto
{ The display mode global. 0 = Off. 1 = Always On. 2 = Contextual. }
GlobalVariable Property DisplayTime Auto
{ The display time global. }
GlobalVariable Property MainPrimaryColor Auto
{ Setting global for primary color. }
GlobalVariable Property MainSecondaryColor Auto
{ Setting global for primary color. }
common_ski_meterwidget Property Meter Auto
GlobalVariable Property Opacity Auto
{ The global that contains the maximum opacity value for this meter. }
Actor Property PlayerRef Auto
GlobalVariable Property RequiredSettingGlobal Auto
{ A global that must be set to 2 for this meter to display. }
FormList Property RequiredWornFormList Auto
{ A formlist of armor objects that the player must have equipped for this meter to display. }
Float[] Property contextual_display_thresholds Auto
Float Property improvement_display_delta_threshold = -1.0 Auto
{ If the player's attribute improves, we should force the display of the meter, but only if it exceeds this absolute value. }
Bool Property lower_is_better = False Auto
{ By default, contextual mode displays the meter when decreasing below thresholds and always when increasing. Setting this to "true" makes the system display the meter when increasing above thresholds and always when decreasing. }
Float Property meter_inversion_value = -1.0 Auto
{ If set, this will cause the meter to fill back up / go back down when this value is reached, usually with an accompanying alternate color. Useful for portraying a "bonus range". }
Bool[] Property threshold_should_flash Auto
Bool[] Property threshold_should_stay_on Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event OnUpdate()
  Self.UpdateMeter(False) ; #DEBUG_LINE_NO:48
  If should_update ; #DEBUG_LINE_NO:49
    Self.RegisterForSingleUpdate(2 as Float) ; #DEBUG_LINE_NO:50
    should_update = False ; #DEBUG_LINE_NO:51
  EndIf
EndEvent

Function UpdateMeterDelegate()
  Self.UpdateMeter(False) ; #DEBUG_LINE_NO:57
EndFunction

Function UpdateMeter(bool abForceDisplayIfEnabled = false)
  If RequiredWornFormList as Bool && !PlayerRef.IsEquipped(RequiredWornFormList as Form) ; #DEBUG_LINE_NO:61
    Self.MeterDebug(0, "UpdateMeter failed RequiredWornFormList check.") ; #DEBUG_LINE_NO:62
    Return  ; #DEBUG_LINE_NO:63
  EndIf
  If RequiredSettingGlobal as Bool && RequiredSettingGlobal.GetValue() != 2.0 ; #DEBUG_LINE_NO:65
    Self.MeterDebug(0, "UpdateMeter failed RequiredSettingGlobal check.") ; #DEBUG_LINE_NO:66
    Return  ; #DEBUG_LINE_NO:67
  EndIf
  Self.HandleMeterUpdate(abForceDisplayIfEnabled) ; #DEBUG_LINE_NO:70
  If display_iterations_remaining > 0 ; #DEBUG_LINE_NO:71
    display_iterations_remaining -= 1 ; #DEBUG_LINE_NO:72
  EndIf
  If display_iterations_remaining != 0 ; #DEBUG_LINE_NO:75
    If !should_update ; #DEBUG_LINE_NO:76
      should_update = True ; #DEBUG_LINE_NO:77
    EndIf
  ElseIf DisplayMode.GetValueInt() == 2 && meter_displayed ; #DEBUG_LINE_NO:80
    Meter.FadeTo(0.0, 3.0) ; #DEBUG_LINE_NO:81
    meter_displayed = False ; #DEBUG_LINE_NO:82
  EndIf
  Self.MeterDebug(0, (("DisplayMode " + DisplayMode.GetValueInt() as String) + " abForceDisplayIfEnabled " + abForceDisplayIfEnabled as String) + " display_iterations_remaining " + display_iterations_remaining as String) ; #DEBUG_LINE_NO:85
EndFunction

Function HandleMeterUpdate(bool abForceDisplayIfEnabled = false)
  Float bonus_range
  Int primary_color
  Bool inverted = False ; #DEBUG_LINE_NO:89
  Float attribute_value = AttributeValue.GetValue() ; #DEBUG_LINE_NO:90
  If meter_inversion_value != -1.0 ; #DEBUG_LINE_NO:92
    If lower_is_better && attribute_value < meter_inversion_value ; #DEBUG_LINE_NO:93
      inverted = True ; #DEBUG_LINE_NO:94
    ElseIf !lower_is_better && attribute_value > meter_inversion_value ; #DEBUG_LINE_NO:95
      inverted = True ; #DEBUG_LINE_NO:96
    EndIf
  EndIf
  If DisplayMode.GetValueInt() == 1 ; #DEBUG_LINE_NO:100
    Meter.Alpha = Opacity.GetValue() ; #DEBUG_LINE_NO:101
  ElseIf DisplayMode.GetValueInt() == 2 || abForceDisplayIfEnabled ; #DEBUG_LINE_NO:102
    If inverted ; #DEBUG_LINE_NO:103
      Self.ContextualDisplay(attribute_value, False) ; #DEBUG_LINE_NO:104
    Else
      Self.ContextualDisplay(attribute_value, abForceDisplayIfEnabled) ; #DEBUG_LINE_NO:106
    EndIf
  ElseIf DisplayMode.GetValueInt() == 0 && display_iterations_remaining == 0 ; #DEBUG_LINE_NO:108
    Meter.Alpha = 0.0 ; #DEBUG_LINE_NO:109
    Return  ; #DEBUG_LINE_NO:110
  EndIf
  Int secondary_color = -1 ; #DEBUG_LINE_NO:114
  If inverted ; #DEBUG_LINE_NO:115
    primary_color = AuxPrimaryColor.GetValueInt() ; #DEBUG_LINE_NO:116
    If AuxSecondaryColor ; #DEBUG_LINE_NO:117
      secondary_color = AuxSecondaryColor.GetValueInt() ; #DEBUG_LINE_NO:118
    EndIf
    If lower_is_better ; #DEBUG_LINE_NO:120
      Meter.SetPercent(1.0 - attribute_value / meter_inversion_value, False) ; #DEBUG_LINE_NO:121
    Else
      Meter.SetPercent(1.0 - (attribute_value - meter_inversion_value) / (AttributeMax.GetValue() - meter_inversion_value), False) ; #DEBUG_LINE_NO:123
    EndIf
    Self.SetMeterColors(primary_color, secondary_color) ; #DEBUG_LINE_NO:125
  Else
    primary_color = MainPrimaryColor.GetValueInt() ; #DEBUG_LINE_NO:127
    If MainSecondaryColor ; #DEBUG_LINE_NO:128
      secondary_color = MainSecondaryColor.GetValueInt() ; #DEBUG_LINE_NO:129
    EndIf
    If meter_inversion_value == -1.0 ; #DEBUG_LINE_NO:132
      Meter.SetPercent(attribute_value / AttributeMax.GetValue(), False) ; #DEBUG_LINE_NO:133
    ElseIf lower_is_better
      Meter.SetPercent((attribute_value - meter_inversion_value) / (AttributeMax.GetValue() - meter_inversion_value), False) ; #DEBUG_LINE_NO:136
    Else
      Meter.SetPercent(attribute_value / meter_inversion_value, False) ; #DEBUG_LINE_NO:138
    EndIf
    Self.SetMeterColors(primary_color, secondary_color) ; #DEBUG_LINE_NO:141
  EndIf
  last_attribute_value = attribute_value ; #DEBUG_LINE_NO:144
EndFunction

Function ContextualDisplay(float attribute_value, bool abForceDisplayIfEnabled = false)
  If abForceDisplayIfEnabled ; #DEBUG_LINE_NO:148
    display_iterations_remaining = DisplayTime.GetValueInt() ; #DEBUG_LINE_NO:149
    Self.MeterDebug(0, "abForceDisplayIfEnabled, returning early from ContextualDisplay.") ; #DEBUG_LINE_NO:150
    Return  ; #DEBUG_LINE_NO:151
  EndIf
  Bool increasing = last_attribute_value < attribute_value ; #DEBUG_LINE_NO:154
  Int i = contextual_display_thresholds.Length - 1 ; #DEBUG_LINE_NO:156
  Int current_zone = -1 ; #DEBUG_LINE_NO:157
  While i >= 0 ; #DEBUG_LINE_NO:158
    Float threshold_value = contextual_display_thresholds[i] ; #DEBUG_LINE_NO:159
    Float next_threshold_value = 0.0 ; #DEBUG_LINE_NO:160
    If i - 1 >= 0 ; #DEBUG_LINE_NO:161
      next_threshold_value = contextual_display_thresholds[i - 1] ; #DEBUG_LINE_NO:162
    EndIf
    If attribute_value <= threshold_value && (attribute_value > next_threshold_value || attribute_value == 0.0 && next_threshold_value == 0.0) ; #DEBUG_LINE_NO:164
      current_zone = i ; #DEBUG_LINE_NO:165
      i = -1 ; #DEBUG_LINE_NO:166
    Else
      i -= 1 ; #DEBUG_LINE_NO:168
    EndIf
  EndWhile
  If current_zone == -1 ; #DEBUG_LINE_NO:172
    Self.MeterDebug(0, ("Couldn't determine the current attribute value zone. (Value: " + attribute_value as String) + "). This is bad.") ; #DEBUG_LINE_NO:174
    Return  ; #DEBUG_LINE_NO:175
  EndIf
  Self.MeterDebug(0, "current_zone " + current_zone as String) ; #DEBUG_LINE_NO:178
  Float upper_bound = contextual_display_thresholds[current_zone] ; #DEBUG_LINE_NO:180
  Float lower_bound = 0.0 ; #DEBUG_LINE_NO:181
  If current_zone > 0 ; #DEBUG_LINE_NO:182
    lower_bound = contextual_display_thresholds[current_zone - 1] ; #DEBUG_LINE_NO:183
  EndIf
  Bool should_flash = threshold_should_flash[current_zone] ; #DEBUG_LINE_NO:185
  Bool should_stay_on = threshold_should_stay_on[current_zone] ; #DEBUG_LINE_NO:186
  If lower_is_better ; #DEBUG_LINE_NO:188
    If increasing && last_attribute_value <= lower_bound && attribute_value > lower_bound ; #DEBUG_LINE_NO:189
      If should_stay_on ; #DEBUG_LINE_NO:190
        Self.MeterFadeUp(-1, should_flash) ; #DEBUG_LINE_NO:191
        Self.MeterDebug(0, "Contextual Display - Case A") ; #DEBUG_LINE_NO:192
      Else
        Self.MeterFadeUp(DisplayTime.GetValueInt(), should_flash) ; #DEBUG_LINE_NO:194
        Self.MeterDebug(0, "Contextual Display - Case B") ; #DEBUG_LINE_NO:195
      EndIf
    ElseIf !increasing && last_attribute_value - attribute_value >= Math.Abs(improvement_display_delta_threshold) ; #DEBUG_LINE_NO:197
      Self.MeterFadeUp(-1, False) ; #DEBUG_LINE_NO:198
      Self.MeterDebug(0, "Contextual Display - Case H") ; #DEBUG_LINE_NO:199
    ElseIf !should_stay_on ; #DEBUG_LINE_NO:200
      If display_iterations_remaining == -1 ; #DEBUG_LINE_NO:201
        display_iterations_remaining = DisplayTime.GetValueInt() ; #DEBUG_LINE_NO:202
        Self.MeterDebug(0, "Contextual Display - Case C") ; #DEBUG_LINE_NO:203
      EndIf
    EndIf
  ElseIf !increasing && last_attribute_value > upper_bound && attribute_value <= upper_bound ; #DEBUG_LINE_NO:207
    If should_stay_on ; #DEBUG_LINE_NO:208
      Self.MeterFadeUp(-1, should_flash) ; #DEBUG_LINE_NO:209
      Self.MeterDebug(0, "Contextual Display - Case D") ; #DEBUG_LINE_NO:210
    Else
      Self.MeterFadeUp(DisplayTime.GetValueInt(), should_flash) ; #DEBUG_LINE_NO:212
      Self.MeterDebug(0, "Contextual Display - Case E") ; #DEBUG_LINE_NO:213
    EndIf
  ElseIf increasing && attribute_value - last_attribute_value >= Math.Abs(improvement_display_delta_threshold) ; #DEBUG_LINE_NO:215
    Self.MeterFadeUp(-1, False) ; #DEBUG_LINE_NO:216
    Self.MeterDebug(0, "Contextual Display - Case F") ; #DEBUG_LINE_NO:217
  ElseIf !should_stay_on ; #DEBUG_LINE_NO:218
    If display_iterations_remaining == -1 ; #DEBUG_LINE_NO:219
      display_iterations_remaining = DisplayTime.GetValueInt() ; #DEBUG_LINE_NO:220
      Self.MeterDebug(0, "Contextual Display - Case G") ; #DEBUG_LINE_NO:221
    EndIf
  EndIf
EndFunction

Function MeterFadeUp(int iterations_remaining, bool flash = false)
  If DisplayMode.GetValueInt() == 0 ; #DEBUG_LINE_NO:228
    Return  ; #DEBUG_LINE_NO:229
  EndIf
  meter_displayed = True ; #DEBUG_LINE_NO:231
  Meter.FadeTo(Opacity.GetValue(), 2.0) ; #DEBUG_LINE_NO:232
  If flash ; #DEBUG_LINE_NO:233
    Utility.Wait(1.0) ; #DEBUG_LINE_NO:234
    Meter.StartFlash(False) ; #DEBUG_LINE_NO:235
  EndIf
  display_iterations_remaining = iterations_remaining ; #DEBUG_LINE_NO:237
  Self.RegisterForSingleUpdate(2 as Float) ; #DEBUG_LINE_NO:238
EndFunction

Function SetMeterColors(int aiPrimaryColor, int aiSecondaryColor)
  If Meter.PrimaryColor != aiPrimaryColor ; #DEBUG_LINE_NO:242
    If aiSecondaryColor == -1 ; #DEBUG_LINE_NO:243
      Meter.SetColors(aiPrimaryColor, colorcomponent.SetValue(aiPrimaryColor, 0.850000024), -1) ; #DEBUG_LINE_NO:244
    Else
      Meter.SetColors(aiPrimaryColor, aiSecondaryColor, -1) ; #DEBUG_LINE_NO:246
    EndIf
  EndIf
EndFunction

Function ForceMeterDisplay(bool flash = false)
  If RequiredWornFormList as Bool && !PlayerRef.IsEquipped(RequiredWornFormList as Form) ; #DEBUG_LINE_NO:252
    Self.MeterDebug(0, "ForceMeterDisplay failed RequiredWornFormList check.") ; #DEBUG_LINE_NO:253
    Return  ; #DEBUG_LINE_NO:254
  EndIf
  If RequiredSettingGlobal as Bool && RequiredSettingGlobal.GetValue() != 2.0 ; #DEBUG_LINE_NO:256
    Self.MeterDebug(0, "ForceMeterDisplay failed RequiredSettingGlobal check.") ; #DEBUG_LINE_NO:257
    Return  ; #DEBUG_LINE_NO:258
  EndIf
  Self.MeterFadeUp(DisplayTime.GetValueInt(), flash) ; #DEBUG_LINE_NO:260
  Self.UpdateMeter(True) ; #DEBUG_LINE_NO:261
EndFunction

Function RemoveMeter()
  Meter.Alpha = 0.0 ; #DEBUG_LINE_NO:265
EndFunction

Function CheckMeterRequirements()
  If RequiredWornFormList as Bool && !PlayerRef.IsEquipped(RequiredWornFormList as Form) ; #DEBUG_LINE_NO:269
    Self.MeterDebug(0, "CheckMeterRequirements failed RequiredWornFormList check.") ; #DEBUG_LINE_NO:270
    Self.RemoveMeter() ; #DEBUG_LINE_NO:271
  EndIf
  If RequiredSettingGlobal as Bool && RequiredSettingGlobal.GetValue() != 2.0 ; #DEBUG_LINE_NO:273
    Self.MeterDebug(0, "CheckMeterRequirements failed RequiredSettingGlobal check.") ; #DEBUG_LINE_NO:274
    Self.RemoveMeter() ; #DEBUG_LINE_NO:275
  EndIf
EndFunction

Function MeterDebug(int aiSeverity, string asLogMessage)
  Int LOG_LEVEL = DebugGlobal.GetValueInt() ; #DEBUG_LINE_NO:280
  If LOG_LEVEL <= aiSeverity ; #DEBUG_LINE_NO:281
    If aiSeverity == 0 ; #DEBUG_LINE_NO:282
      Debug.trace(("[" + Self as String) + "][Debug] " + asLogMessage, 0) ; #DEBUG_LINE_NO:283
    ElseIf aiSeverity == 1 ; #DEBUG_LINE_NO:284
      Debug.trace(("[" + Self as String) + "][Info] " + asLogMessage, 0) ; #DEBUG_LINE_NO:285
    ElseIf aiSeverity == 2 ; #DEBUG_LINE_NO:286
      Debug.trace(("[" + Self as String) + "][Warning] " + asLogMessage, 0) ; #DEBUG_LINE_NO:287
    ElseIf aiSeverity == 3 ; #DEBUG_LINE_NO:288
      Debug.trace(("[" + Self as String) + "][ERROR] " + asLogMessage, 0) ; #DEBUG_LINE_NO:289
    EndIf
  EndIf
EndFunction
