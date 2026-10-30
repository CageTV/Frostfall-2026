scriptname FrostfallItemCard hidden
{Frostfall 2026: Frostfall.dll asks this script for the warmth and coverage of the armor under the cursor in the inventory, to draw them over
the item card. It holds no FormIDs, so the same script serves the regular and the ESL build.}

; Result, packed into one int so the plugin needs no array handling:
;   warmth * 4096 + coverage   (both 0..4095)
;   -1 = no warmth or coverage for this item (not armor Frostfall counts, or Frostfall is not ready)
;   -2 = Frostfall's SkyUI item-card package is installed and shows the numbers itself
int function ItemProtection(Armor akArmor) global
	if !akArmor
		return -1
	endif
	_Frost_Compatibility compat = FrostUtil.GetCompatibilitySystem()
	if compat && compat.isUIPackageInstalled
		return -2
	endif
	_Frost_ArmorProtectionDatastoreHandler handler = FrostUtil.GetClothingDatastoreHandler()
	if !handler
		return -1
	endif
	int[] values = handler.GetTotalArmorProtectionValues(akArmor)
	if values.Length < 2 || values[0] == -99 || (values[0] == 0 && values[1] == 0)
		return -1
	endif
	int warmth = values[0]
	int coverage = values[1]
	if warmth < 0
		warmth = 0
	elseif warmth > 4095
		warmth = 4095
	endif
	if coverage < 0
		coverage = 0
	elseif coverage > 4095
		coverage = 4095
	endif
	return warmth * 4096 + coverage
endFunction
