; COMPILE-TIME IMPORT ONLY (never shipped). Decompiled from the shipped script; defaults restored from source/evidence.
ScriptName FallbackEventHandler Extends ObjectReference

;-- Variables ---------------------------------------
Int MAX_COUNT = 32
Bool initialized = False
Int pushedBoolCount = 0
Bool[] pushedBools
Int pushedFloatCount = 0
Float[] pushedFloats
Int pushedFormCount = 0
Form[] pushedForms
Int pushedIntCount = 0
Int[] pushedInts
Int pushedStringCount = 0
String[] pushedStrings
Alias[] receiverAliases
ActiveMagicEffect[] receiverEffects
Form[] receiverForms

;-- Properties --------------------------------------
String Property eventName Auto hidden
Int Property handleID Auto hidden
Bool Property isStaticHandler Auto hidden
fallbackeventemitter Property sender Auto hidden

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event OnInit()
  pushedBools = new Bool[32] ; #DEBUG_LINE_NO:28
  pushedInts = new Int[32] ; #DEBUG_LINE_NO:29
  pushedFloats = new Float[32] ; #DEBUG_LINE_NO:30
  pushedStrings = new String[32] ; #DEBUG_LINE_NO:31
  pushedForms = new Form[32] ; #DEBUG_LINE_NO:32
  initialized = True ; #DEBUG_LINE_NO:33
EndEvent

Bool Function IsInitialized()
  If initialized ; #DEBUG_LINE_NO:37
    Return True ; #DEBUG_LINE_NO:38
  Else
    Return False ; #DEBUG_LINE_NO:40
  EndIf
EndFunction

Function PushBool(bool value)
  Self.WaitForInitialization() ; #DEBUG_LINE_NO:45
  If pushedBoolCount < MAX_COUNT ; #DEBUG_LINE_NO:46
    pushedBools[pushedBoolCount] = value ; #DEBUG_LINE_NO:47
    pushedBoolCount += 1 ; #DEBUG_LINE_NO:48
  EndIf
EndFunction

Function PushInt(int value)
  Self.WaitForInitialization() ; #DEBUG_LINE_NO:53
  If pushedIntCount < MAX_COUNT ; #DEBUG_LINE_NO:54
    pushedInts[pushedIntCount] = value ; #DEBUG_LINE_NO:55
    pushedIntCount += 1 ; #DEBUG_LINE_NO:56
  EndIf
EndFunction

Function PushFloat(float value)
  Self.WaitForInitialization() ; #DEBUG_LINE_NO:61
  If pushedFloatCount < MAX_COUNT ; #DEBUG_LINE_NO:62
    pushedFloats[pushedFloatCount] = value ; #DEBUG_LINE_NO:63
    pushedFloatCount += 1 ; #DEBUG_LINE_NO:64
  EndIf
EndFunction

Function PushString(string value)
  Self.WaitForInitialization() ; #DEBUG_LINE_NO:69
  If pushedStringCount < MAX_COUNT ; #DEBUG_LINE_NO:70
    pushedStrings[pushedStringCount] = value ; #DEBUG_LINE_NO:71
    pushedStringCount += 1 ; #DEBUG_LINE_NO:72
  EndIf
EndFunction

Function PushForm(form value)
  Self.WaitForInitialization() ; #DEBUG_LINE_NO:77
  If pushedFormCount < MAX_COUNT ; #DEBUG_LINE_NO:78
    pushedForms[pushedFormCount] = value ; #DEBUG_LINE_NO:79
    pushedFormCount += 1 ; #DEBUG_LINE_NO:80
  EndIf
EndFunction

Bool Function Send(Form[] afRegisteredForms, Alias[] afRegisteredAliases, ActiveMagicEffect[] afRegisteredActiveMagicEffects)
  receiverForms = afRegisteredForms ; #DEBUG_LINE_NO:85
  receiverAliases = afRegisteredAliases ; #DEBUG_LINE_NO:86
  receiverEffects = afRegisteredActiveMagicEffects ; #DEBUG_LINE_NO:87
  Self.RegisterForSingleUpdate(0.01) ; #DEBUG_LINE_NO:88
  Return True ; #DEBUG_LINE_NO:89
EndFunction

Event OnUpdate()
  Int i = 0 ; #DEBUG_LINE_NO:93
  Bool forms_need_sort = False ; #DEBUG_LINE_NO:94
  Bool aliases_need_sort = False ; #DEBUG_LINE_NO:95
  Bool effects_need_sort = False ; #DEBUG_LINE_NO:96
  Int registered_form_count = commonarrayhelper.ArrayCountForm(receiverForms) ; #DEBUG_LINE_NO:98
  While i < registered_form_count ; #DEBUG_LINE_NO:99
    If receiverForms[i] as fallbackeventreceiverform == None ; #DEBUG_LINE_NO:100
      receiverForms[i] = None ; #DEBUG_LINE_NO:101
      forms_need_sort = True ; #DEBUG_LINE_NO:102
    Else
      (receiverForms[i] as fallbackeventreceiverform).RaiseEvent(eventName, pushedBools, pushedInts, pushedFloats, pushedForms, pushedStrings) ; #DEBUG_LINE_NO:105
    EndIf
    i += 1 ; #DEBUG_LINE_NO:107
  EndWhile
  i = 0 ; #DEBUG_LINE_NO:110
  Int registered_alias_count = commonarrayhelper.ArrayCountAlias(receiverAliases) ; #DEBUG_LINE_NO:111
  While i < registered_alias_count ; #DEBUG_LINE_NO:112
    If receiverAliases[i] as fallbackeventreceiveralias == None ; #DEBUG_LINE_NO:113
      receiverAliases[i] = None ; #DEBUG_LINE_NO:114
      aliases_need_sort = True ; #DEBUG_LINE_NO:115
    Else
      (receiverAliases[i] as fallbackeventreceiveralias).RaiseEvent(eventName, pushedBools, pushedInts, pushedFloats, pushedForms, pushedStrings) ; #DEBUG_LINE_NO:118
    EndIf
    i += 1 ; #DEBUG_LINE_NO:120
  EndWhile
  i = 0 ; #DEBUG_LINE_NO:123
  Int registered_effect_count = commonarrayhelper.ArrayCountActiveMagicEffect(receiverEffects) ; #DEBUG_LINE_NO:124
  While i < registered_effect_count ; #DEBUG_LINE_NO:125
    If receiverEffects[i] as fallbackeventreceiveractivemagiceffect == None ; #DEBUG_LINE_NO:126
      receiverEffects[i] = None ; #DEBUG_LINE_NO:127
      effects_need_sort = True ; #DEBUG_LINE_NO:128
    Else
      (receiverEffects[i] as fallbackeventreceiveractivemagiceffect).RaiseEvent(eventName, pushedBools, pushedInts, pushedFloats, pushedForms, pushedStrings) ; #DEBUG_LINE_NO:131
    EndIf
    i += 1 ; #DEBUG_LINE_NO:133
  EndWhile
  If forms_need_sort ; #DEBUG_LINE_NO:136
    commonarrayhelper.ArraySortForm(receiverForms, 0) ; #DEBUG_LINE_NO:137
  EndIf
  If aliases_need_sort ; #DEBUG_LINE_NO:140
    commonarrayhelper.ArraySortAlias(receiverAliases, 0) ; #DEBUG_LINE_NO:141
  EndIf
  If effects_need_sort ; #DEBUG_LINE_NO:144
    commonarrayhelper.ArraySortActiveMagicEffect(receiverEffects, 0) ; #DEBUG_LINE_NO:145
  EndIf
  Self.Dispose() ; #DEBUG_LINE_NO:148
EndEvent

Function Dispose()
  pushedBools = new Bool[32] ; #DEBUG_LINE_NO:152
  pushedInts = new Int[32] ; #DEBUG_LINE_NO:153
  pushedFloats = new Float[32] ; #DEBUG_LINE_NO:154
  pushedStrings = new String[32] ; #DEBUG_LINE_NO:155
  pushedForms = new Form[32] ; #DEBUG_LINE_NO:156
  If !isStaticHandler ; #DEBUG_LINE_NO:157
    sender.Release(handleID) ; #DEBUG_LINE_NO:158
    receiverForms = new Form[128] ; #DEBUG_LINE_NO:159
    receiverAliases = new Alias[128] ; #DEBUG_LINE_NO:160
    receiverEffects = new ActiveMagicEffect[128] ; #DEBUG_LINE_NO:161
    sender = None ; #DEBUG_LINE_NO:162
    eventName = "" ; #DEBUG_LINE_NO:163
    Self.Disable(False) ; #DEBUG_LINE_NO:164
    Self.Delete() ; #DEBUG_LINE_NO:165
  EndIf
EndFunction

Function WaitForInitialization()
  Int i = 0 ; #DEBUG_LINE_NO:170
  While i < 20 && !initialized ; #DEBUG_LINE_NO:171
    Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:172
    i += 1 ; #DEBUG_LINE_NO:173
  EndWhile
EndFunction
