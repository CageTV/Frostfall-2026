/*
 * Frostfall 2026
 * Copyright (C) 2026 CageTV
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or (at your option) any later version. It is distributed WITHOUT ANY
 * WARRANTY; see LICENSE.txt for the full text.
 */
#pragma once

// Key capture for the hotkey rows of the settings pages: the next key pressed is reported by TakeCaptured. Frostfall's key itself is still
// handled by its own script (OnKeyDown in _Frost_SkyUIConfigPanelScript), which Frostfall.dll tells about each change.
namespace Hotkeys
{
	void BeginCapture(int a_slot);
	void CancelCapture();
	int  CapturingSlot();                           // -1 when not capturing
	// True once, when the key for that slot has been chosen. a_keyCode is the DirectInput scan code, or 0 when the key was cleared
	// (Delete / Backspace). Escape cancels without a result.
	bool TakeCaptured(int a_slot, int& a_keyCode);

	const char* KeyName(int a_keyCode);  // "F", "Left Shift", ... or "None"
}
