; COMPILE-TIME IMPORT ONLY (never shipped). Decompiled from the shipped script; defaults restored from source/evidence.
ScriptName FallbackEventEmitter Extends ReferenceAlias
{ Allows registration and emitting of mod event using SKSE or in SKSE-less
fallback mode. }

;-- Variables ---------------------------------------
Int VERSION = 1
Form[] handles
Bool isSKSELoaded = False
ActiveMagicEffect[] registeredActiveMagicEffects
Alias[] registeredAliases
Form[] registeredForms

;-- Properties --------------------------------------
Activator Property FallbackEventHandleMarker Auto
{ Link to your event handler marker object. See the CheskoPapyrusShared readme
for more info. }
Actor Property PlayerRef Auto
{ Link to the Player actor reference. }
Int Property SKSE_MIN_VERSION = 10700 Auto hidden
Bool Property UseSKSEModEvents = True Auto
{ Default: true. If false, events from this emitter will only be registered /
sent via Fallback Events. }
Bool Property UseStaticEventHandler = False Auto
{ Default: false. If true, the emitter will spawn a single event handler and keep
it loaded in the engine. Good for routine, periodic events where constantly
creating and destroying event handlers is less desirable. }

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event OnInit()
  registeredForms = new Form[128] ; #DEBUG_LINE_NO:34
  registeredAliases = new Alias[128] ; #DEBUG_LINE_NO:35
  registeredActiveMagicEffects = new ActiveMagicEffect[128] ; #DEBUG_LINE_NO:36
  handles = new Form[128] ; #DEBUG_LINE_NO:37
  isSKSELoaded = Self.CheckSKSELoaded() ; #DEBUG_LINE_NO:38
EndEvent

Event OnPlayerLoadGame()
  isSKSELoaded = Self.CheckSKSELoaded() ; #DEBUG_LINE_NO:42
EndEvent

Int Function GetVersion()
  Return VERSION ; #DEBUG_LINE_NO:46
EndFunction

Int Function Create(string asEventName)
  If isSKSELoaded ; #DEBUG_LINE_NO:50
    Return modevent.Create(asEventName) ; #DEBUG_LINE_NO:51
  ElseIf UseStaticEventHandler
    If !handles[0] ; #DEBUG_LINE_NO:55
      ObjectReference handle = PlayerRef.PlaceAtMe(FallbackEventHandleMarker as Form, 1, False, False) ; #DEBUG_LINE_NO:56
      (handle as fallbackeventhandler).sender = Self ; #DEBUG_LINE_NO:58
      (handle as fallbackeventhandler).isStaticHandler = True ; #DEBUG_LINE_NO:59
      (handle as fallbackeventhandler).eventName = asEventName ; #DEBUG_LINE_NO:60
      handles[0] = handle as Form ; #DEBUG_LINE_NO:61
    EndIf
    Return 1 ; #DEBUG_LINE_NO:64
  Else
    ObjectReference handle = PlayerRef.PlaceAtMe(FallbackEventHandleMarker as Form, 1, False, False) ; #DEBUG_LINE_NO:66
    (handle as fallbackeventhandler).sender = Self ; #DEBUG_LINE_NO:68
    (handle as fallbackeventhandler).eventName = asEventName ; #DEBUG_LINE_NO:69
    commonarrayhelper.ArrayAddForm(handles, handle as Form) ; #DEBUG_LINE_NO:70
    Int handleID = handles.find(handle as Form, 0) + 1 ; #DEBUG_LINE_NO:71
    (handle as fallbackeventhandler).handleID = handleID ; #DEBUG_LINE_NO:72
    Return handleID ; #DEBUG_LINE_NO:74
  EndIf
EndFunction

Bool Function Send(int handle)
  If isSKSELoaded ; #DEBUG_LINE_NO:80
    Return modevent.Send(handle) ; #DEBUG_LINE_NO:82
  ElseIf UseStaticEventHandler
    If handles[0] ; #DEBUG_LINE_NO:86
      Bool sent = (handles[0] as fallbackeventhandler).Send(registeredForms, registeredAliases, registeredActiveMagicEffects) ; #DEBUG_LINE_NO:87
      Return sent ; #DEBUG_LINE_NO:89
    Else
      Return False ; #DEBUG_LINE_NO:92
    EndIf
  Else
    Bool sent = (handles[handle - 1] as fallbackeventhandler).Send(registeredForms, registeredAliases, registeredActiveMagicEffects) ; #DEBUG_LINE_NO:95
    Return sent ; #DEBUG_LINE_NO:97
  EndIf
EndFunction

Function Release(int handle)
  If isSKSELoaded ; #DEBUG_LINE_NO:103
    modevent.Release(handle) ; #DEBUG_LINE_NO:104
  Else
    commonarrayhelper.ArrayRemoveForm(handles, handles[handle - 1], True) ; #DEBUG_LINE_NO:107
  EndIf
EndFunction

Function RegisterFormForModEventWithFallback(string asEventName, string asCallbackName, Form akReceiver)
  If isSKSELoaded ; #DEBUG_LINE_NO:113
    akReceiver.RegisterForModEvent(asEventName, asCallbackName) ; #DEBUG_LINE_NO:114
  Else
    fallbackeventreceiverform receiver = akReceiver as fallbackeventreceiverform ; #DEBUG_LINE_NO:116
    If receiver ; #DEBUG_LINE_NO:117
      Int idx = registeredForms.find(akReceiver, 0) ; #DEBUG_LINE_NO:118
      If idx == -1 ; #DEBUG_LINE_NO:119
        commonarrayhelper.ArrayAddForm(registeredForms, akReceiver) ; #DEBUG_LINE_NO:120
        commonarrayhelper.ArraySortForm(registeredForms, 0) ; #DEBUG_LINE_NO:121
      EndIf
    EndIf
  EndIf
EndFunction

Function UnregisterFormForModEventWithFallback(string asEventName, Form akReceiver)
  If isSKSELoaded ; #DEBUG_LINE_NO:128
    akReceiver.UnregisterForModEvent(asEventName) ; #DEBUG_LINE_NO:129
  Else
    fallbackeventreceiverform receiver = akReceiver as fallbackeventreceiverform ; #DEBUG_LINE_NO:131
    If receiver ; #DEBUG_LINE_NO:132
      commonarrayhelper.ArrayRemoveForm(registeredForms, akReceiver, True) ; #DEBUG_LINE_NO:133
    EndIf
  EndIf
EndFunction

Function RegisterAliasForModEventWithFallback(string asEventName, string asCallbackName, Alias akReceiver)
  If isSKSELoaded ; #DEBUG_LINE_NO:139
    akReceiver.RegisterForModEvent(asEventName, asCallbackName) ; #DEBUG_LINE_NO:140
  Else
    fallbackeventreceiveralias receiver = akReceiver as fallbackeventreceiveralias ; #DEBUG_LINE_NO:142
    If receiver ; #DEBUG_LINE_NO:143
      Int idx = registeredAliases.find(akReceiver, 0) ; #DEBUG_LINE_NO:144
      If idx == -1 ; #DEBUG_LINE_NO:145
        commonarrayhelper.ArrayAddAlias(registeredAliases, akReceiver) ; #DEBUG_LINE_NO:146
        commonarrayhelper.ArraySortAlias(registeredAliases, 0) ; #DEBUG_LINE_NO:147
      EndIf
    EndIf
  EndIf
EndFunction

Function UnregisterAliasForModEventWithFallback(string asEventName, Alias akReceiver)
  If isSKSELoaded ; #DEBUG_LINE_NO:154
    akReceiver.UnregisterForModEvent(asEventName) ; #DEBUG_LINE_NO:155
  Else
    fallbackeventreceiveralias receiver = akReceiver as fallbackeventreceiveralias ; #DEBUG_LINE_NO:157
    If receiver ; #DEBUG_LINE_NO:158
      commonarrayhelper.ArrayRemoveAlias(registeredAliases, akReceiver, True) ; #DEBUG_LINE_NO:159
    EndIf
  EndIf
EndFunction

Function RegisterActiveMagicEffectForModEventWithFallback(string asEventName, string asCallbackname, ActiveMagicEffect akReceiver)
  If isSKSELoaded ; #DEBUG_LINE_NO:165
    akReceiver.RegisterForModEvent(asEventName, asCallbackName) ; #DEBUG_LINE_NO:166
  Else
    fallbackeventreceiveractivemagiceffect receiver = akReceiver as fallbackeventreceiveractivemagiceffect ; #DEBUG_LINE_NO:168
    If receiver ; #DEBUG_LINE_NO:169
      Int idx = registeredActiveMagicEffects.find(akReceiver, 0) ; #DEBUG_LINE_NO:170
      If idx == -1 ; #DEBUG_LINE_NO:171
        commonarrayhelper.ArrayAddActiveMagicEffect(registeredActiveMagicEffects, akReceiver) ; #DEBUG_LINE_NO:172
        commonarrayhelper.ArraySortActiveMagicEffect(registeredActiveMagicEffects, 0) ; #DEBUG_LINE_NO:173
      EndIf
    EndIf
  EndIf
EndFunction

Function UnregisterActiveMagicEffectForModEventWithFallback(string asEventName, ActiveMagicEffect akReceiver)
  If isSKSELoaded ; #DEBUG_LINE_NO:180
    akReceiver.UnregisterForModEvent(asEventName) ; #DEBUG_LINE_NO:181
  Else
    fallbackeventreceiveractivemagiceffect receiver = akReceiver as fallbackeventreceiveractivemagiceffect ; #DEBUG_LINE_NO:183
    If receiver ; #DEBUG_LINE_NO:184
      commonarrayhelper.ArrayRemoveActiveMagicEffect(registeredActiveMagicEffects, akReceiver, True) ; #DEBUG_LINE_NO:185
    EndIf
  EndIf
EndFunction

Function PushBool(int handle, bool value)
  If isSKSELoaded ; #DEBUG_LINE_NO:191
    modevent.PushBool(handle, value) ; #DEBUG_LINE_NO:192
  Else
    fallbackeventhandler handleref = handles[handle - 1] as fallbackeventhandler ; #DEBUG_LINE_NO:194
    If handleref ; #DEBUG_LINE_NO:195
      Int i = 0 ; #DEBUG_LINE_NO:196
      While i < 10 && !handleref.IsInitialized() ; #DEBUG_LINE_NO:197
        Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:198
        i += 1 ; #DEBUG_LINE_NO:199
      EndWhile
      handleref.PushBool(value) ; #DEBUG_LINE_NO:201
    EndIf
  EndIf
EndFunction

Function PushInt(int handle, int value)
  If isSKSELoaded ; #DEBUG_LINE_NO:207
    modevent.PushInt(handle, value) ; #DEBUG_LINE_NO:208
  Else
    fallbackeventhandler handleref = handles[handle - 1] as fallbackeventhandler ; #DEBUG_LINE_NO:210
    If handleref ; #DEBUG_LINE_NO:211
      Int i = 0 ; #DEBUG_LINE_NO:212
      While i < 10 && !handleref.IsInitialized() ; #DEBUG_LINE_NO:213
        Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:214
        i += 1 ; #DEBUG_LINE_NO:215
      EndWhile
      handleref.PushInt(value) ; #DEBUG_LINE_NO:217
    EndIf
  EndIf
EndFunction

Function PushFloat(int handle, float value)
  If isSKSELoaded ; #DEBUG_LINE_NO:223
    modevent.PushFloat(handle, value) ; #DEBUG_LINE_NO:224
  Else
    fallbackeventhandler handleref = handles[handle - 1] as fallbackeventhandler ; #DEBUG_LINE_NO:226
    If handleref ; #DEBUG_LINE_NO:227
      Int i = 0 ; #DEBUG_LINE_NO:228
      While i < 10 && !handleref.IsInitialized() ; #DEBUG_LINE_NO:229
        Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:230
        i += 1 ; #DEBUG_LINE_NO:231
      EndWhile
      handleref.PushFloat(value) ; #DEBUG_LINE_NO:233
    EndIf
  EndIf
EndFunction

Function PushString(int handle, string value)
  If isSKSELoaded ; #DEBUG_LINE_NO:239
    modevent.PushString(handle, value) ; #DEBUG_LINE_NO:240
  Else
    fallbackeventhandler handleref = handles[handle - 1] as fallbackeventhandler ; #DEBUG_LINE_NO:242
    If handleref ; #DEBUG_LINE_NO:243
      Int i = 0 ; #DEBUG_LINE_NO:244
      While i < 10 && !handleref.IsInitialized() ; #DEBUG_LINE_NO:245
        Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:246
        i += 1 ; #DEBUG_LINE_NO:247
      EndWhile
      handleref.PushString(value) ; #DEBUG_LINE_NO:249
    EndIf
  EndIf
EndFunction

Function PushForm(int handle, form value)
  If isSKSELoaded ; #DEBUG_LINE_NO:255
    modevent.PushForm(handle, value) ; #DEBUG_LINE_NO:256
  Else
    fallbackeventhandler handleref = handles[handle - 1] as fallbackeventhandler ; #DEBUG_LINE_NO:258
    If handleref ; #DEBUG_LINE_NO:259
      Int i = 0 ; #DEBUG_LINE_NO:260
      While i < 10 && !handleref.IsInitialized() ; #DEBUG_LINE_NO:261
        Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:262
        i += 1 ; #DEBUG_LINE_NO:263
      EndWhile
      handleref.PushForm(value) ; #DEBUG_LINE_NO:265
    EndIf
  EndIf
EndFunction

Bool Function CheckSKSELoaded()
  If !UseSKSEModEvents ; #DEBUG_LINE_NO:271
    Return False ; #DEBUG_LINE_NO:272
  EndIf
  Bool skse_loaded = skse.GetVersion() as Bool ; #DEBUG_LINE_NO:275
  If skse_loaded ; #DEBUG_LINE_NO:276
    Int skse_version = skse.GetVersion() * 10000 + skse.GetVersionMinor() * 100 + skse.GetVersionBeta() ; #DEBUG_LINE_NO:277
    If skse_version >= SKSE_MIN_VERSION ; #DEBUG_LINE_NO:278
      Return True ; #DEBUG_LINE_NO:279
    Else
      Return False ; #DEBUG_LINE_NO:281
    EndIf
  Else
    Return False ; #DEBUG_LINE_NO:284
  EndIf
EndFunction
