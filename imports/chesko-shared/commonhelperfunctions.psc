; COMPILE-TIME IMPORT ONLY (never shipped). Decompiled from the shipped script; defaults restored from source/evidence.
ScriptName CommonHelperFunctions hidden

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event onBeginState()
{ Event received when this state is switched to }
  ; Empty function
EndEvent

Event onEndState()
{ Event received when this state is switched away from }
  ; Empty function
EndEvent

Bool Function IsEven(int aiValue) Global
  Return aiValue % 2 == 0 ; #DEBUG_LINE_NO:4
EndFunction

Float Function GetDistance2D(ObjectReference akReference, ObjectReference akOther) Global
  Float x1 = akReference.x ; #DEBUG_LINE_NO:8
  Float y1 = akReference.y ; #DEBUG_LINE_NO:9
  Float x2 = akOther.x ; #DEBUG_LINE_NO:10
  Float y2 = akOther.y ; #DEBUG_LINE_NO:11
  Float dx = x2 - x1 ; #DEBUG_LINE_NO:13
  Float dy = y2 - y1 ; #DEBUG_LINE_NO:14
  Return Math.sqrt(dx * dx + dy * dy) ; #DEBUG_LINE_NO:16
EndFunction

Float Function GetDistance2DCoords(float afOriginX, float afOriginY, float afNewX, float afNewY) Global
  Float dx = afNewX - afOriginX ; #DEBUG_LINE_NO:20
  Float dy = afNewY - afOriginY ; #DEBUG_LINE_NO:21
  Return Math.sqrt(dx * dx + dy * dy) ; #DEBUG_LINE_NO:23
EndFunction
