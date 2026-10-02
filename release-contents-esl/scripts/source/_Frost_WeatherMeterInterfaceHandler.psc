scriptname _Frost_WeatherMeterInterfaceHandler extends CommonMeterInterfaceHandler

import CampUtil

function RegisterForEvents()
	if !GetSKSELoaded()
		return
	endif
	
	RegisterForModEvent("Frostfall_ForceWeathersenseMeterDisplay", "ForceMeterDisplay")
	RegisterForModEvent("Frostfall_RemoveWeathersenseMeter", "RemoveMeter")
	RegisterForModEvent("Frostfall_UpdateWeathersenseMeter", "UpdateMeterDelegate")
	RegisterForModEvent("Frostfall_CheckMeterRequirements", "CheckMeterRequirements")
endFunction

; Frostfall 3.5: while Frostfall.dll's HUD bars are on, this SkyUI meter stays hidden whatever the meter settings say.
; @overrides CommonMeterInterfaceHandler
function UpdateMeter(bool abForceDisplayIfEnabled = false)
	if FrostfallNative.OldMetersHidden()
		RemoveMeter()
		return
	endif
	parent.UpdateMeter(abForceDisplayIfEnabled)
endFunction

; @overrides CommonMeterInterfaceHandler
function ForceMeterDisplay(bool flash = false)
	if FrostfallNative.OldMetersHidden()
		RemoveMeter()
		return
	endif
	parent.ForceMeterDisplay(flash)
endFunction
