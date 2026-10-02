; COMPILE-TIME IMPORT ONLY (never shipped). Decompiled from the shipped script; defaults restored from source/evidence.
ScriptName Common_SKI_MeterWidget Extends SKI_WidgetBase

;-- Variables ---------------------------------------
String _fillDirection = "both"
Int _flashColor = -1
Float _height = 25.200000763
Float _percent = 0.0
Int _primaryColor = 16711680
Int _secondaryColor = -1
Float _width = 292.799987793

;-- Properties --------------------------------------
String Property FillDirection
{ The position at which the meter fills from, ["left", "center", "right"] . Default: center }
  String Function Get()
    Return _fillDirection ; #DEBUG_LINE_NO:86
  EndFunction
  Function Set(String a_val)
    _fillDirection = a_val ; #DEBUG_LINE_NO:90
    If Self.Ready ; #DEBUG_LINE_NO:91
      ui.InvokeString(Self.HUD_MENU, Self.WidgetRoot + ".setFillDirection", _fillDirection) ; #DEBUG_LINE_NO:92
    EndIf
  EndFunction
EndProperty
Int Property FlashColor
{ Color of the meter warning flash, -1 = automatic. RRGGBB [0x000000, 0xFFFFFF]. Default: -1. Convert to decimal when editing this in the CK }
  Int Function Get()
    Return _flashColor ; #DEBUG_LINE_NO:72
  EndFunction
  Function Set(Int a_val)
    _flashColor = a_val ; #DEBUG_LINE_NO:76
    If Self.Ready ; #DEBUG_LINE_NO:77
      ui.InvokeInt(Self.HUD_MENU, Self.WidgetRoot + ".setFlashColor", _flashColor) ; #DEBUG_LINE_NO:78
    EndIf
  EndFunction
EndProperty
Float Property Height
{ Height of the meter in pixels at a resolution of 1280x720. Default: 25.2 }
  Float Function Get()
    Return _height ; #DEBUG_LINE_NO:33
  EndFunction
  Function Set(Float a_val)
    _height = a_val ; #DEBUG_LINE_NO:37
    If Self.Ready ; #DEBUG_LINE_NO:38
      ui.InvokeFloat(Self.HUD_MENU, Self.WidgetRoot + ".setHeight", _height) ; #DEBUG_LINE_NO:39
    EndIf
  EndFunction
EndProperty
Float Property Percent
{ Percent of the meter [0.0, 1.0]. Default: 0.0 }
  Float Function Get()
    Return _percent ; #DEBUG_LINE_NO:100
  EndFunction
  Function Set(Float a_val)
    _percent = a_val ; #DEBUG_LINE_NO:104
    If Self.Ready ; #DEBUG_LINE_NO:105
      ui.InvokeFloat(Self.HUD_MENU, Self.WidgetRoot + ".setPercent", _percent) ; #DEBUG_LINE_NO:106
    EndIf
  EndFunction
EndProperty
Int Property PrimaryColor
{ Primary color of the meter gradient RRGGBB [0x000000, 0xFFFFFF]. Default: 0xFF0000. Convert to decimal when editing this in the CK }
  Int Function Get()
    Return _primaryColor ; #DEBUG_LINE_NO:47
  EndFunction
  Function Set(Int a_val)
    _primaryColor = a_val ; #DEBUG_LINE_NO:51
    If Self.Ready ; #DEBUG_LINE_NO:52
      ui.InvokeInt(Self.HUD_MENU, Self.WidgetRoot + ".setColor", _primaryColor) ; #DEBUG_LINE_NO:53
    EndIf
  EndFunction
EndProperty
Int Property SecondaryColor
{ Secondary color of the meter gradient, -1 = automatic. RRGGBB [0x000000, 0xFFFFFF]. Default: -1. Convert to decimal when editing this in the CK }
  Int Function Get()
    Return _secondaryColor ; #DEBUG_LINE_NO:61
  EndFunction
  Function Set(Int a_val)
    Self.SetColors(_primaryColor, a_val, _flashColor) ; #DEBUG_LINE_NO:65
  EndFunction
EndProperty
Float Property Width
{ Width of the meter in pixels at a resolution of 1280x720. Default: 292.8 }
  Float Function Get()
    Return _width ; #DEBUG_LINE_NO:19
  EndFunction
  Function Set(Float a_val)
    _width = a_val ; #DEBUG_LINE_NO:23
    If Self.Ready ; #DEBUG_LINE_NO:24
      ui.InvokeFloat(Self.HUD_MENU, Self.WidgetRoot + ".setWidth", _width) ; #DEBUG_LINE_NO:25
    EndIf
  EndFunction
EndProperty

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Function OnWidgetReset()
  Parent.OnWidgetReset() ; #DEBUG_LINE_NO:116
  Float[] numberArgs = new Float[6] ; #DEBUG_LINE_NO:119
  numberArgs[0] = _width ; #DEBUG_LINE_NO:120
  numberArgs[1] = _height ; #DEBUG_LINE_NO:121
  numberArgs[2] = _primaryColor as Float ; #DEBUG_LINE_NO:122
  numberArgs[3] = _secondaryColor as Float ; #DEBUG_LINE_NO:123
  numberArgs[4] = _flashColor as Float ; #DEBUG_LINE_NO:124
  numberArgs[5] = _percent ; #DEBUG_LINE_NO:125
  ui.InvokeFloatA(Self.HUD_MENU, Self.WidgetRoot + ".initNumbers", numberArgs) ; #DEBUG_LINE_NO:126
  String[] stringArgs = new String[1] ; #DEBUG_LINE_NO:129
  stringArgs[0] = _fillDirection ; #DEBUG_LINE_NO:130
  ui.InvokeStringA(Self.HUD_MENU, Self.WidgetRoot + ".initStrings", stringArgs) ; #DEBUG_LINE_NO:131
  ui.Invoke(Self.HUD_MENU, Self.WidgetRoot + ".initCommit") ; #DEBUG_LINE_NO:134
EndFunction

String Function GetWidgetSource()
  Return "skyui/meter.swf" ; #DEBUG_LINE_NO:142
EndFunction

String Function GetWidgetType()
  Return "_DE_SKI_MeterWidget" ; #DEBUG_LINE_NO:147
EndFunction

Function SetPercent(float a_percent, bool a_force = false)
{ Sets the meter percent, a_force sets the meter percent without animation }
  _percent = a_percent ; #DEBUG_LINE_NO:152
  If Self.Ready ; #DEBUG_LINE_NO:153
    Float[] args = new Float[2] ; #DEBUG_LINE_NO:154
    args[0] = a_percent ; #DEBUG_LINE_NO:155
    args[1] = a_force as Float ; #DEBUG_LINE_NO:156
    ui.InvokeFloatA(Self.HUD_MENU, Self.WidgetRoot + ".setPercent", args) ; #DEBUG_LINE_NO:157
  EndIf
EndFunction

Function ForcePercent(float a_percent)
{ Convenience function for SetPercent(a_percent, true) }
  Self.SetPercent(a_percent, True) ; #DEBUG_LINE_NO:163
EndFunction

Function StartFlash(bool a_force = false)
{ Starts meter flashing. a_force starts the meter flashing if it's already animating }
  If Self.Ready ; #DEBUG_LINE_NO:169
    ui.InvokeBool(Self.HUD_MENU, Self.WidgetRoot + ".startFlash", a_force) ; #DEBUG_LINE_NO:170
  EndIf
EndFunction

Function ForceFlash()
{ Convenience function for StartFlash(true) }
  Self.StartFlash(True) ; #DEBUG_LINE_NO:177
EndFunction

Function SetColors(int a_primaryColor, int a_secondaryColor = -1, int a_flashColor = -1)
{ Sets the meter percent, a_force sets the meter percent without animation }
  _primaryColor = a_primaryColor ; #DEBUG_LINE_NO:182
  _secondaryColor = a_secondaryColor ; #DEBUG_LINE_NO:183
  _flashColor = a_flashColor ; #DEBUG_LINE_NO:184
  If Self.Ready ; #DEBUG_LINE_NO:186
    Int[] args = new Int[3] ; #DEBUG_LINE_NO:187
    args[0] = a_primaryColor ; #DEBUG_LINE_NO:188
    args[1] = a_secondaryColor ; #DEBUG_LINE_NO:189
    args[2] = a_flashColor ; #DEBUG_LINE_NO:190
    ui.InvokeIntA(Self.HUD_MENU, Self.WidgetRoot + ".setColors", args) ; #DEBUG_LINE_NO:191
  EndIf
EndFunction

Function TransitionColors(int a_primaryColor, int a_secondaryColor = -1, int a_flashColor = -1, int a_duration = 1000)
{ Sets the meter percent, a_force sets the meter percent without animation }
  _primaryColor = a_primaryColor ; #DEBUG_LINE_NO:197
  _secondaryColor = a_secondaryColor ; #DEBUG_LINE_NO:198
  _flashColor = a_flashColor ; #DEBUG_LINE_NO:199
  If Self.Ready ; #DEBUG_LINE_NO:201
    Int[] args = new Int[4] ; #DEBUG_LINE_NO:202
    args[0] = a_primaryColor ; #DEBUG_LINE_NO:203
    args[1] = a_secondaryColor ; #DEBUG_LINE_NO:204
    args[2] = a_flashColor ; #DEBUG_LINE_NO:205
    args[3] = a_duration ; #DEBUG_LINE_NO:206
    ui.InvokeIntA(Self.HUD_MENU, Self.WidgetRoot + ".transitionColors", args) ; #DEBUG_LINE_NO:207
  EndIf
EndFunction
