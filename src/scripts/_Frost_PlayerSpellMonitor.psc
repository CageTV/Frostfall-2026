scriptname _Frost_PlayerSpellMonitor extends ReferenceAlias

import FrostUtil
import CampUtil
import PO3_Events_Alias

GlobalVariable property _Frost_WetLevel auto
GlobalVariable property _Frost_PerkRank_FrostWarding auto
Keyword property MagicDamageFire auto
Keyword property MagicDamageFrost auto
Keyword property _Frost_WetStateKeyword auto
Actor property PlayerRef auto
EffectShader property SteamFXShader auto

bool fire_damage_lock = false
bool frost_damage_lock = false

; Frostfall 4.5: the vanilla OnMagicEffectApply event fired for EVERY magic effect applied to the player (potions,
; enchantments, abilities, other mods' cloaks...), and each one ran this script only to be ignored. Frostfall.dll now
; listens to the game's effect-applied event itself, checks the target and the vanilla fire / frost damage keywords in
; native code, and raises the mod event below only for a match (afNumArg: 1 = fire, 2 = frost, 3 = both). This script keeps
; the gameplay (wetness, exposure, the 4 second locks). Papyrus Extender is no longer needed.
; (Frostfall 3.5 to 4.4 registered Papyrus Extender's filtered event instead. Saves made then still hold that registration:
; it is removed once, only when Papyrus Extender is installed.)
;
; MagicDamageFire / MagicDamageFrost are no longer read here; the properties stay declared so existing saves and the plugin's
; property list stay valid.

Event OnInit()
	RegisterMonitorEvent()
EndEvent

Event OnPlayerLoadGame()
	RegisterMonitorEvent()
EndEvent

function RegisterMonitorEvent()
	RemoveLegacyFilters()
	RegisterForModEvent("Frostfall_PlayerMagicDamage", "OnPlayerMagicDamage")
endFunction

function RemoveLegacyFilters()
	if SKSE.GetPluginVersion("powerofthree's Papyrus Extender") > 0
		UnregisterForAllMagicEffectApplyEx(self)
	endif
endFunction

Event OnPlayerMagicDamage(string asEventName, string asStrArg, float afNumArg, Form akSender)
	; Same order as before: fire first (when not locked), otherwise frost (when not locked).
	bool isFire = afNumArg == 1.0 || afNumArg == 3.0
	bool isFrost = afNumArg == 2.0 || afNumArg == 3.0
	if !fire_damage_lock && isFire
		DecreaseExposureWetnessFireDamage()
	elseif !frost_damage_lock && isFrost
		IncreaseExposureFrostDamage()
	endif
EndEvent

function DispelWetness()
	_Frost_WetnessSystem wet = GetWetnessSystem()
	wet.ModAttributeWetness(-wet.MAX_WETNESS, wet.MIN_WETNESS)
	if _Frost_WetLevel.GetValueInt() > 0
		SteamFXShader.Play(PlayerRef, 1.5)
		wet.UpdateWetLevel()
	endif
endFunction

function DecreaseExposureWetnessFireDamage()
	fire_damage_lock = true
	if !PlayerRef.IsSwimming()
		DispelWetness()
	endif
	SendEvent_ForceExposureMeterDisplay()
	ModPlayerExposure(-5.0, 50.0)
	Utility.Wait(4.0)
	fire_damage_lock = false
endFunction

function IncreaseExposureFrostDamage()
	frost_damage_lock = true
	float frost_ward_rank = _Frost_PerkRank_FrostWarding.GetValue()
	float exposure_increase = 5.0 * (1 - (0.25 * frost_ward_rank))
	SendEvent_ForceExposureMeterDisplay()
	ModPlayerExposure(exposure_increase, 90.0)
	Utility.Wait(4.0)
	frost_damage_lock = false
endFunction

;@NOFALLBACK
function SendEvent_ForceExposureMeterDisplay()
	if GetSKSELoaded()
		int handle = ModEvent.Create("Frost_ForceExposureMeterDisplay")
		if handle
			ModEvent.PushBool(handle, false)
			ModEvent.Send(handle)
		endif
	endif
endFunction
