#include "PCH.h"
#include "Game.h"
#include "Settings.h"

namespace Game
{
	namespace
	{
		Globals g;
		bool    ready = false;

		RE::TESGlobal* Lookup(RE::FormID a_localID, const char* a_name)
		{
			auto* dh = RE::TESDataHandler::GetSingleton();
			auto* form = dh ? dh->LookupForm<RE::TESGlobal>(a_localID, "Frostfall.esp") : nullptr;
			if (!form) {
				SKSE::log::error("Frostfall.esp global {} ({:06X}) not found", a_name, a_localID);
			}
			return form;
		}

		void DispatchStatic(const char* a_function)
		{
			SKSE::GetTaskInterface()->AddTask([a_function]() {
				auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton();
				if (!vm) {
					return;
				}
				RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback;
				auto* args = RE::MakeFunctionArguments();
				vm->DispatchStaticCall("FrostfallNative", a_function, args, callback);
				delete args;
				SKSE::log::info("Called FrostfallNative.{}()", a_function);
			});
		}

	}

	bool Init()
	{
		g.running = Lookup(0x06DCFB, "FrostfallRunning");
		g.exposure = Lookup(0x08827A, "_Frost_AttributeExposureMeter");
		g.exposureMax = Lookup(0x07CAA4, "_Frost_AttributeExposureMax");
		g.wetness = Lookup(0x06458C, "_Frost_AttributeWetness");
		g.wetnessMax = Lookup(0x07CAA5, "_Frost_AttributeWetnessMax");
		g.tempLevel = Lookup(0x07CAA7, "_Frost_AttributeMeterTempLevel");
		g.tempLevelMax = Lookup(0x07CAA8, "_Frost_AttributeMeterTempLevelMax");
		g.warmth = Lookup(0x067B8F, "_Frost_AttributeWarmth");
		g.warmthMax = Lookup(0x068110, "_Frost_Calc_MaxWarmth");
		g.coverage = Lookup(0x067B91, "_Frost_AttributeCoverage");
		g.coverageMax = Lookup(0x068111, "_Frost_Calc_MaxCoverage");
		g.meterMode = Lookup(0x05CE05, "_Frost_Setting_MeterDisplayMode");
		ready = g.running && g.exposure && g.wetness && g.tempLevel && g.warmth && g.coverage;
		SKSE::log::info("Frostfall globals {}", ready ? "found" : "MISSING - is Frostfall.esp enabled?");
		return ready;
	}

	const Globals& G() { return g; }
	bool           Ready() { return ready; }

	float Value(const RE::TESGlobal* a_global, float a_fallback)
	{
		return a_global ? a_global->value : a_fallback;
	}

	bool IsRunning()
	{
		return ready && static_cast<int>(Value(g.running)) == 2;
	}

	void StartFrostfall() { DispatchStatic("StartFromMenu"); }
	void StopFrostfall() { DispatchStatic("StopFromMenu"); }

	// Frostfall's SkyUI meters are hidden by its own meter scripts while the bars are on (FrostfallNative.OldMetersHidden),
	// so the meter display setting is never touched; this just refreshes them right away after the switch.
	void RefreshOldMeters() { DispatchStatic("RefreshOldMeters"); }

	void RestoreMeterMode()
	{
		auto& s = Settings::Get();
		if (s.savedMeterMode < 0) {
			return;
		}
		SKSE::GetTaskInterface()->AddTask([]() {
			auto& s = Settings::Get();
			if (!ready || !g.meterMode || !IsRunning() || s.savedMeterMode < 0) {
				return;
			}
			if (static_cast<int>(g.meterMode->value) == 0) {
				g.meterMode->value = static_cast<float>(s.savedMeterMode);
				SKSE::log::info("Restored Frostfall's SkyUI meter display mode {} (switched off by an older Frostfall.dll)", s.savedMeterMode);
			}
			s.savedMeterMode = -1;
			s.Save();
		});
	}
}
