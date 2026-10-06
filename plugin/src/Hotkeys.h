/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
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
