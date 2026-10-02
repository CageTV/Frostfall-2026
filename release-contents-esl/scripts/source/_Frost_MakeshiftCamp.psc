scriptname _Frost_MakeshiftCamp hidden
{Frostfall 3.5: the "Make Camp" option of Campfire's campfire menu. Wearing a Creation Club "Adventurer's Backpacks"
backpack with a bedroll, the player can turn 4 Branches and 2 Linen Wraps into a one-time makeshift camp (a bedroll
under a simple shelter) next to the fire. The camp is placed with Campfire's own placement indicator and leaves nothing
behind when packed up. The backpacks are optional Creation Club content, so they are looked up at run time instead of
being a master of Frostfall.esp.}

; The 8 "with Bedroll" backpacks of ccfsvsse001-backpacks.esl are its even FormIDs 0x802..0x810.
; The camp's shelter is the Creation Club Camping lean-to mesh (ccqdrsse002-firewood.esl's archive), referenced by path:
; Frostfall ships no copy of it. Without that CC there is no mesh to show, so the camp is not offered.
; The optional add-on plugin (ESL-flagged) that holds the leather camp: its ACT is 000801, its menu 000802.
string function GetLeatherPlugin() global
	return "Frostfall 2026 - Leather Tent.esp"
endFunction

Message function GetLeatherMenu() global
	if !Game.IsPluginInstalled(GetLeatherPlugin())
		return none
	endif
	return Game.GetFormFromFile(0x000802, GetLeatherPlugin()) as Message
endFunction

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
	MiscObject branches = Game.GetFormFromFile(0x00083D, "Campfire.esm") as MiscObject
	MiscObject linen = Game.GetFormFromFile(0x034CD6, "Skyrim.esm") as MiscObject
	Message menu = Game.GetFormFromFile(0x000C52, "Frostfall.esp") as Message
	if !branches || !linen || !menu
		return false
	endif
	int have_branches = player.GetItemCount(branches)
	int have_linen = player.GetItemCount(linen)
	bool basic = have_branches >= 4 && have_linen >= 2

	; With the optional "Frostfall 2026 - Leather Tent" add-on, a better camp is offered as well.
	Message leather_menu = GetLeatherMenu()
	MiscObject leather_item = Game.GetFormFromFile(0x0DB5D2, "Skyrim.esm") as MiscObject
	bool leather = leather_menu && leather_item && have_branches >= 4 && have_linen >= 1 && player.GetItemCount(leather_item) >= 2

	if !basic && !leather
		return false
	endif
	if leather
		int j = leather_menu.Show()
		if j == 0
			MakeCamp(akCampfire)
		elseif j == 1
			MakeLeatherCamp(akCampfire)
		elseif j == 2
			return false
		endif
		return true
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
	MiscObject branches = Game.GetFormFromFile(0x00083D, "Campfire.esm") as MiscObject
	MiscObject linen = Game.GetFormFromFile(0x034CD6, "Skyrim.esm") as MiscObject
	MiscObject kit = Game.GetFormFromFile(0x000C4E, "Frostfall.esp") as MiscObject
	Activator indicator = Game.GetFormFromFile(0x000C4F, "Frostfall.esp") as Activator
	Activator camp = Game.GetFormFromFile(0x000C50, "Frostfall.esp") as Activator
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
	if !akCampfire
		return
	endif
	Form camp = Game.GetFormFromFile(0x000C50, "Frostfall.esp")
	ObjectReference found = None
	if camp
		found = Game.FindClosestReferenceOfType(camp, akCampfire.GetPositionX(), akCampfire.GetPositionY(), akCampfire.GetPositionZ(), 500.0)
	endif
	if !found && Game.IsPluginInstalled(GetLeatherPlugin())
		Form leather_camp = Game.GetFormFromFile(0x000801, GetLeatherPlugin())
		if leather_camp
			found = Game.FindClosestReferenceOfType(leather_camp, akCampfire.GetPositionX(), akCampfire.GetPositionY(), akCampfire.GetPositionZ(), 500.0)
		endif
	endif
	if found
		(found as _Frost_MakeshiftCampTent).DestroyMyself()
	endif
endFunction

; The leather camp (add-on): 4 Branches, 1 Linen Wrap and 2 Leather. It is only ever placed automatically, at the same
; spot as the basic camp; on ground too uneven for that nothing is used up.
function MakeLeatherCamp(ObjectReference akCampfire) global
	Actor player = Game.GetPlayer()
	MiscObject branches = Game.GetFormFromFile(0x00083D, "Campfire.esm") as MiscObject
	MiscObject linen = Game.GetFormFromFile(0x034CD6, "Skyrim.esm") as MiscObject
	MiscObject leather_item = Game.GetFormFromFile(0x0DB5D2, "Skyrim.esm") as MiscObject
	Activator camp = Game.GetFormFromFile(0x000801, GetLeatherPlugin()) as Activator
	if !branches || !linen || !leather_item || !camp || !akCampfire || !FrostfallNative.IsInstalled()
		return
	endif
	if player.GetItemCount(branches) < 4 || player.GetItemCount(linen) < 1 || player.GetItemCount(leather_item) < 2
		Debug.Notification("The leather camp needs 4 Branches, 1 Linen Wrap and 2 Leather.")
		return
	endif
	; This tent's mesh has its open side at the other end from the Creation Club one, so no 180 degree turn here.
	float[] spot = FrostfallNative.GetCampSpot(akCampfire, 220.0, 0.0)
	if !spot || spot.Length != 5 || spot[4] > 96.0
		Debug.Notification("The ground here is too uneven for the leather camp.")
		return
	endif
	player.RemoveItem(branches, 4)
	player.RemoveItem(linen, 1)
	player.RemoveItem(leather_item, 2)

	Form marker_base = Game.GetFormFromFile(0x000034, "Skyrim.esm")		; XMarkerHeading
	ObjectReference marker = akCampfire.PlaceAtMe(marker_base)
	marker.SetPosition(spot[0], spot[1], spot[2])
	marker.SetAngle(0.0, 0.0, spot[3])
	ObjectReference ref = marker.PlaceAtMe(camp, abForcePersist = true)
	marker.Disable()
	marker.Delete()
	CampUtil.SendEvent_OnObjectPlaced(ref)
endFunction
