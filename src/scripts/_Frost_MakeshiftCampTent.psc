scriptname _Frost_MakeshiftCampTent extends CampTent
{Frostfall 3.5: a makeshift camp is used once. Campfire's tent system hands a tent's inventory item back when it is
packed up and then takes the tent down; this takes that item away again, so nothing is left behind. A makeshift camp
also falls apart by itself a game week after it was set up.}

float property DECAY_HOURS = 168.0 autoReadOnly	; one game week
float property RETRY_HOURS = 1.0 autoReadOnly	; try again later while the player is at the camp

; @overrides _Camp_PlaceableObjectBase
function Initialize()
	parent.Initialize()
	MoveOntoBedding()
	; Campfire's tents put a spouse's bedroll beside the player's; a makeshift camp is for one, so hide it.
	if mySpouseLayDownMarker
		mySpouseLayDownMarker.Disable()
	endif
	RegisterForSingleUpdateGameTime(DECAY_HOURS)
endFunction

; The camp activator is the origin everything else is placed from, so it ends up at ground level inside the lean-to's
; platform. Once Campfire has finished placing the camp (Initialize is synchronous), move it onto the lean-to's own
; bedroll so that is the bedroll the player can activate: same spot, same facing, 1 unit below the visible mesh.
; BED_X / BED_Y: that bedroll's centre in the lean-to mesh's own frame (the mesh is turned 180 degrees from the
; activator, hence + 180 below).
float property BED_X = 25.0 autoReadOnly
float property BED_Y = 12.0 autoReadOnly
float property BED_Z = 15.0 autoReadOnly
bool moved_onto_bedding = false

function MoveOntoBedding()
	if moved_onto_bedding
		return
	endif
	moved_onto_bedding = true
	float a = GetAngleZ() + 180.0
	float dx = BED_X * Math.Cos(a) + BED_Y * Math.Sin(a)
	float dy = -BED_X * Math.Sin(a) + BED_Y * Math.Cos(a)
	SetPosition(GetPositionX() + dx, GetPositionY() + dy, GetPositionZ() + BED_Z)
	SetAngle(GetAngleX(), GetAngleY(), a)
endFunction

; The base script's update takes a conjured object down; for the camp it is the week running out.
Event OnUpdateGameTime()
	if Game.GetPlayer().GetDistance(self) < 600.0
		; Not while the player is using or standing at the camp.
		RegisterForSingleUpdateGameTime(RETRY_HOURS)
		return
	endif
	DestroyMyself()
endEvent

; @overrides CampTent
function TakeDown()
	Actor player = Game.GetPlayer()
	if Required_InventoryItem && player.GetItemCount(Required_InventoryItem) > 0
		player.RemoveItem(Required_InventoryItem, 1, true)
	endif
	parent.TakeDown()
endFunction
