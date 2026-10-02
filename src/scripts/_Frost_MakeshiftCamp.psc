scriptname _Frost_MakeshiftCamp hidden
{Frostfall 3.5: the "Make Camp" option of Campfire's campfire menu. Wearing a Creation Club "Adventurer's Backpacks"
backpack with a bedroll, the player can turn 4 Branches and 2 Linen Wraps into a one-time makeshift camp (a bedroll
under a simple shelter) next to the fire. The camp is placed with Campfire's own placement indicator and leaves nothing
behind when packed up. The backpacks are optional Creation Club content, so they are looked up at run time instead of
being a master of Frostfall.esp.}

; The 8 "with Bedroll" backpacks of ccfsvsse001-backpacks.esl are its even FormIDs 0x802..0x810.
; The camp's shelter is the Creation Club Camping lean-to mesh (ccqdrsse002-firewood.esl's archive), referenced by path:
; Frostfall ships no copy of it. Without that CC there is no mesh to show, so the camp is not offered.
bool function HasCampingCC() global
	return Game.IsPluginInstalled("ccqdrsse002-firewood.esl")
endFunction

bool function IsWearingBedrollBackpack() global
	if !Game.IsPluginInstalled("ccfsvsse001-backpacks.esl")
		return false
	endif
	Actor player = Game.GetPlayer()
	int id = 0x802
	while id <= 0x810
		Armor backpack = Game.GetFormFromFile(id, "ccfsvsse001-backpacks.esl") as Armor
		if backpack && player.IsEquipped(backpack)
			return true
		endif
		id += 2
	endWhile
	return false
endFunction

; Called by CampCampfire before its own menu. With a bedroll backpack worn and the materials carried, Frostfall's
; small menu offers the camp; returns true when that handled the activation (camp made, or cancelled), false to go on
; to Campfire's menu.
bool function OfferCamp(ObjectReference akCampfire) global
	if !HasCampingCC() || !IsWearingBedrollBackpack()
		return false
	endif
	Actor player = Game.GetPlayer()
	MiscObject branches = Game.GetFormFromFile(0x02564C, "Campfire.esm") as MiscObject
	MiscObject linen = Game.GetFormFromFile(0x034CD6, "Skyrim.esm") as MiscObject
	Message menu = Game.GetFormFromFile(0x095005, "Frostfall.esp") as Message
	if !branches || !linen || !menu || player.GetItemCount(branches) < 4 || player.GetItemCount(linen) < 2
		return false
	endif
	int i = menu.Show()
	if i == 0
		MakeCamp(akCampfire)
		return true
	elseif i == 1
		return false
	endif
	return true
endFunction

; Called by CampCampfire when "Make Camp" is picked. The camp is set up like the little camp in Rigmor of Bruma:
; about 220 units from the fire, open side facing it, on the player's side of the fire. Where that spot is much
; higher or lower than the fire (steep ground), or without Frostfall.dll, the player places it with Campfire's
; placement indicator instead.
function MakeCamp(ObjectReference akCampfire) global
	Actor player = Game.GetPlayer()
	MiscObject branches = Game.GetFormFromFile(0x02564C, "Campfire.esm") as MiscObject
	MiscObject linen = Game.GetFormFromFile(0x034CD6, "Skyrim.esm") as MiscObject
	MiscObject kit = Game.GetFormFromFile(0x095001, "Frostfall.esp") as MiscObject
	Activator indicator = Game.GetFormFromFile(0x095002, "Frostfall.esp") as Activator
	Activator camp = Game.GetFormFromFile(0x095003, "Frostfall.esp") as Activator
	if !branches || !linen || !kit || !indicator || !camp
		return
	endif

	int have_branches = player.GetItemCount(branches)
	int have_linen = player.GetItemCount(linen)
	if have_branches < 4 || have_linen < 2
		Debug.Notification("To make camp you need 4 Branches (" + have_branches + ") and 2 Linen Wraps (" + have_linen + ").")
		return
	endif
	player.RemoveItem(branches, 4)
	player.RemoveItem(linen, 2)

	float[] spot
	if akCampfire && FrostfallNative.IsInstalled()
		spot = FrostfallNative.GetCampSpot(akCampfire, 220.0, 180.0)
	endif
	if spot && spot.Length == 5 && spot[4] <= 96.0
		Form marker_base = Game.GetFormFromFile(0x000034, "Skyrim.esm")		; XMarkerHeading
		ObjectReference marker = akCampfire.PlaceAtMe(marker_base)
		marker.SetPosition(spot[0], spot[1], spot[2])
		marker.SetAngle(0.0, 0.0, spot[3])
		ObjectReference ref = marker.PlaceAtMe(camp, abForcePersist = true)
		Debug.Trace("[Frostfall 2026] makeshift camp: fire (" + akCampfire.GetPositionX() + ", " + akCampfire.GetPositionY() + ") camp (" + spot[0] + ", " + spot[1] + ") activator angle " + spot[3])
		marker.Disable()
		marker.Delete()
		CampUtil.SendEvent_OnObjectPlaced(ref)
		return
	endif

	; Same call Campfire makes when a tent item is used from the inventory. If the player cancels the placement,
	; the makeshift camp stays in the inventory and can be placed later from there.
	player.AddItem(kit, 1, true)
	CampUtil.GetPlacementSystem().PlaceableObjectUsed(kit, indicator, none, none, 0, none, none, none, none)
endFunction

; Called by CampCampfire when the player picks "Destroy" on a campfire: a makeshift camp set up at that fire goes with
; it. The camp stands about 220 units from the fire, so anything within 500 units counts as this fire's camp.
function DestroyCampNear(ObjectReference akCampfire) global
	Form camp = Game.GetFormFromFile(0x095003, "Frostfall.esp")
	if !camp || !akCampfire
		return
	endif
	ObjectReference found = Game.FindClosestReferenceOfType(camp, akCampfire.GetPositionX(), akCampfire.GetPositionY(), akCampfire.GetPositionZ(), 500.0)
	if found
		(found as _Frost_MakeshiftCampTent).DestroyMyself()
	endif
endFunction
