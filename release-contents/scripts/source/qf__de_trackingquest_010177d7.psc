;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname QF__DE_TrackingQuest_010177D7 Extends Quest Hidden

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
SetObjectiveDisplayed(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
SetObjectiveDisplayed(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
; Frostfall 3.5: stage 20 no longer completes the quest by itself (Frostfall.esp). With Frostfall.dll the start-up logo
; replaces the "COMPLETED: FROSTFALL" banner, so the quest is stopped quietly; without it, it completes as before.
if FrostfallNative.IsInstalled()
	SetObjectiveDisplayed(10, false)
	Stop()
else
	SetObjectiveCompleted(10)
	CompleteQuest()
endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
