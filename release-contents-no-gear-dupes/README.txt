Frostfall - No Gear Display Dupes
Version 1.0.0, a small script fix for Campfire (works with Frostfall 2026 and with the original Frostfall)

THE PROBLEM
-----------
When you rest in a Campfire tent, Campfire lays a second, real copy of your gear (weapons, armour, backpack, and your followers'
weapons) next to the bedroll as a display. The copy is only blocked from being activated, so a pickup mod (auto-loot, "take all
nearby" and the like) can take it and you end up with a duplicate of the item.

THE FIX
-------
This replaces Campfire's _camp_tentsystem script. Your gear is still unequipped and re-equipped when you rest, but no display copy
is made. Nothing else about tents changes.

If Go To Bed (Gotobed.esp) is installed, the sleep menu is opened with Go To Bed's own menu, the same call "Gotobed-se-patches" makes,
because otherwise this script would undo that patch. Without Go To Bed the bedroll is activated as in Campfire.

PRIORITY
--------
Other mods also ship their own _camp_tentsystem.pex ("Gotobed-se-patches" and "Campfire - Script Optimization" among them). This one
must win over all of them: in MO2's left pane put it below them (the lower mod wins file conflicts). In the Conflicts tab it must be
the winner for scripts/_camp_tentsystem.pex. Script Optimization's other scripts are not affected; only its changes to this one script
are replaced (these are log-spam fixes for plugins that are not installed).

REQUIREMENTS
------------
Campfire (Nexus 667). No plugin; scripts only.

CREDITS
-------
Chesko (Campfire, MIT licence; this is his script with two small changes; the source is included in scripts/source).
