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

; Frostfall 3.5: the vanilla OnMagicEffectApply event fired for EVERY magic effect applied to the player (potions,
; enchantments, abilities, other mods' cloaks...), and each one ran this script only to be ignored. With a large load
; order that is a steady stream of wasted script work. Papyrus Extender's filtered event is only raised for effects
; carrying the two keywords this monitor cares about. Registrations are refreshed on every load, which also upgrades
; saves made with the old script.

Event OnInit()
	RegisterDamageFilters()
EndEvent

Event OnPlayerLoadGame()
	RegisterDamageFilters()
EndEvent

function RegisterDamageFilters()
	UnregisterForAllMagicEffectApplyEx(self)
	RegisterForMagicEffectApplyEx(self, MagicDamageFire, true)
	RegisterForMagicEffectApplyEx(self, MagicDamageFrost, true)
endFunction

Event OnMagicEffectApplyEx(ObjectReference akCaster, MagicEffect akEffect, Form akSource, bool abApplied)
	if !fire_damage_lock && akEffect.HasKeyword(MagicDamageFire)
		DecreaseExposureWetnessFireDamage()
	elseif !frost_damage_lock && akEffect.HasKeyword(MagicDamageFrost)
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
