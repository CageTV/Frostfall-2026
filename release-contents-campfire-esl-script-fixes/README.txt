Campfire ESL - Script Fixes
Version 1.0.0, for "CAMPFIRE ESL UPDATED" (Nexus 193472) and Campfire 1.12.1

THE PROBLEM
-----------
"CAMPFIRE ESL UPDATED" flags Campfire.esm as ESL (light) and renumbers its records so it takes no regular plugin slot. It leaves
Campfire's scripts as they were, and a number of them look records up by hard-coded FormID, for example the bedroll furniture and the
conjured-shelter pieces of every tent. With the renumbered records those lookups find nothing (or the wrong record), so tents,
bedrolls and the perk system misbehave.

THE FIX
-------
The 12 Campfire scripts that do this, with each hard-coded FormID changed to the matching record of the ESL Campfire (matched by
EditorID; every pair was checked against the ESL plugin). Nothing else in them changed: they are Chesko's Campfire 1.12.1
scripts (the source is included in scripts/source, MIT). Loose scripts override the ones in Campfire.bsa.

USE
---
Only together with "CAMPFIRE ESL UPDATED". With the original Campfire.esm do NOT install it: the ids would be wrong. Put it
after (below) Campfire and "CAMPFIRE ESL UPDATED" in MO2's left pane. It is also required by "Frostfall 2026 (ESL)".

CREDITS
-------
Chesko (Campfire, MIT). The ESL conversion of Campfire.esm is the work of the author of "CAMPFIRE ESL UPDATED".
