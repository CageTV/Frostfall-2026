scriptname FrostfallNative hidden
{Frostfall 3.5: bridge to Frostfall.dll, the SKSE plugin behind the HUD bars, the start-up logo and the
SKSE Menu Framework settings page. Every native call is guarded by IsInstalled(), so Frostfall runs exactly as
before (message boxes, SkyUI meters, MCM) when the plugin is not installed.}

bool function IsInstalled() global
	return SKSE.GetPluginVersion("Frostfall") > 0
endFunction

; Implemented by Frostfall.dll
bool function AutoStartEnabled() global native
function ShowStartupLogo() global native
bool function HudBarsActive() global native
float function GetPlayerWaterDepth() global native
float[] function GetCampSpot(ObjectReference akFire, float afDistance, float afAngleOffset) global native

; How deep the water is at the player's feet (game units; 0 = dry ground, or Frostfall.dll not installed).
float function WaterDepthAtPlayer() global
	if IsInstalled()
		return GetPlayerWaterDepth()
	endif
	return 0.0
endFunction

; True while Frostfall.dll's HUD bars replace Frostfall's SkyUI meters (the meters then stay hidden).
bool function OldMetersHidden() global
	return IsInstalled() && HudBarsActive()
endFunction

; Called by Frostfall.dll when its HUD bars are switched on or off: hide the SkyUI meters, or bring them back.
function RefreshOldMeters() global
	GlobalVariable running = Game.GetFormFromFile(0x000A9A, "Frostfall.esp") as GlobalVariable
	if !running || running.GetValueInt() != 2
		return
	endif
	if OldMetersHidden()
		SendMeterEvent("Frostfall_RemoveExposureMeter")
		SendMeterEvent("Frostfall_RemoveWetnessMeter")
		SendMeterEvent("Frostfall_RemoveWeathersenseMeter")
	else
		SendMeterEvent("Frostfall_ForceExposureMeterDisplay", true)
		SendMeterEvent("Frostfall_ForceWetnessMeterDisplay", true)
	endif
endFunction

function SendMeterEvent(string asEvent, bool abWithFlag = false) global
	int handle = ModEvent.Create(asEvent)
	if handle
		if abWithFlag
			ModEvent.PushBool(handle, false)
		endif
		ModEvent.Send(handle)
	endif
endFunction

; Called by Frostfall.dll's menu buttons. Same steps as the MCM's Start / Stop Frostfall option.
function StartFromMenu() global
	_Frost_Main main = Game.GetFormFromFile(0x000A08, "Frostfall.esp") as _Frost_Main
	if main
		main.StartFromMenu()
	endif
endFunction

function StopFromMenu() global
	_Frost_Main main = Game.GetFormFromFile(0x000A08, "Frostfall.esp") as _Frost_Main
	if main
		main.StopFromMenu()
	endif
endFunction
