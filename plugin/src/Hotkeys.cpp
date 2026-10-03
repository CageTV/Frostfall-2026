#include "PCH.h"
#include "Hotkeys.h"

namespace Hotkeys
{
	namespace
	{
		std::atomic<int> capturing{ -1 };
		bool             previousDown[256]{};  // key state when capture began, so the click that started it is not taken as the key

		// While SKSE Menu Framework's window is open it consumes the game's own input events, so the key is read from the keyboard state
		// instead. Returns the DirectInput scan code of a newly pressed key, -1 for Delete/Backspace, -3 for Escape, or -2 for none.
		int PollKeyboard()
		{
			DWORD pid = 0;
			GetWindowThreadProcessId(GetForegroundWindow(), &pid);
			if (pid != GetCurrentProcessId()) {
				return -2;  // the game is not the active window
			}
			for (int vk = 8; vk < 255; ++vk) {
				if (vk == VK_LBUTTON || vk == VK_RBUTTON || vk == VK_MBUTTON || vk == VK_XBUTTON1 || vk == VK_XBUTTON2 || vk == VK_RETURN) {
					continue;  // mouse buttons; Enter is how menus are activated
				}
				const bool down = (GetAsyncKeyState(vk) & 0x8000) != 0;
				if (down && !previousDown[vk]) {
					previousDown[vk] = true;
					if (vk == VK_ESCAPE) {
						return -3;
					}
					if (vk == VK_BACK || vk == VK_DELETE) {
						return -1;
					}
					const UINT sc = MapVirtualKeyW(static_cast<UINT>(vk), MAPVK_VK_TO_VSC_EX);
					if (sc == 0) {
						continue;
					}
					return ((sc & 0xFF00) == 0xE000) ? static_cast<int>((sc & 0xFF) | 0x80) : static_cast<int>(sc & 0xFF);
				}
				previousDown[vk] = down;
			}
			return -2;
		}
	}

	void BeginCapture(int a_slot)
	{
		for (int vk = 0; vk < 256; ++vk) {
			previousDown[vk] = (GetAsyncKeyState(vk) & 0x8000) != 0;
		}
		capturing = a_slot;
	}

	void CancelCapture()
	{
		capturing = -1;
	}

	int CapturingSlot() { return capturing.load(); }

	bool TakeCaptured(int a_slot, int& a_keyCode)
	{
		if (capturing.load() != a_slot) {
			return false;
		}
		const int c = PollKeyboard();
		if (c == -2) {
			return false;  // nothing pressed yet
		}
		capturing = -1;
		if (c == -3) {
			return false;  // cancelled
		}
		a_keyCode = (c == -1) ? 0 : c;
		return true;
	}

	const char* KeyName(int a_keyCode)
	{
		static thread_local char buffer[64];
		if (a_keyCode <= 0) {
			return "None";
		}
		// DirectInput scan codes: the high bit marks the extended keys
		const LONG ext = (a_keyCode & 0x80) ? 1 : 0;
		const LONG lparam = ((a_keyCode & 0x7F) << 16) | (ext << 24);
		wchar_t    wide[48]{};
		if (GetKeyNameTextW(lparam, wide, 48) > 0) {
			WideCharToMultiByte(CP_UTF8, 0, wide, -1, buffer, sizeof(buffer), nullptr, nullptr);
			return buffer;
		}
		std::snprintf(buffer, sizeof(buffer), "Key %d", a_keyCode);
		return buffer;
	}
}
