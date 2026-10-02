Scriptname _Frost_BoundCloakRemoveScript extends ObjectReference

import FrostUtil
import _CampInternal

Actor property PlayerRef auto
Armor property BoundCloak auto
Sound Property sndDeactivate Auto
Spell property CloakSpell auto
Message property _Frost_BoundCloakRemovedMsg auto

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
	if !akNewContainer
		self.Delete()
	else
		if akNewContainer != PlayerRef
			int cloak_count = akNewContainer.GetItemCount(BoundCloak)
			if cloak_count > 0
				akNewContainer.RemoveItem(BoundCloak, cloak_count, true)
			endif
		endif
	endif
EndEvent

; Frostfall 3.5: unequipping the conjured cloak no longer dispels the spell. Anything that briefly unequips cloak-slot
; gear (another item taking the slot, outfit or weather mods, re-casting) used to trigger this and end the spell the
; moment it was cast. The spell now simply runs its duration: _Frost_BoundCloakScript.OnEffectFinish still removes the
; cloak when it ends, and OnContainerChanged above still stops the cloak from being dropped or moved into a container.
Event OnUnequipped(Actor akActor)
EndEvent

function SendEvent_DispelBoundCloaks()
	FallbackEventEmitter emitter = GetEventEmitter_DispelBoundCloaks()
	int handle = emitter.Create("Frost_DispelBoundCloaks")
	if handle
		emitter.Send(handle)
	endif
endFunction