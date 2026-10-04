/*
 * Frostfall 2026
 * Copyright (C) 2026 CageTV
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or (at your option) any later version. It is distributed WITHOUT ANY
 * WARRANTY; see LICENSE.txt for the full text.
 */
#include "PCH.h"
#include "Game.h"
#include "GameIds.h"
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
		g.running = Lookup(ids::FrostfallRunning, "FrostfallRunning");
		g.exposure = Lookup(ids::Frost_AttributeExposureMeter, "_Frost_AttributeExposureMeter");
		g.exposureMax = Lookup(ids::Frost_AttributeExposureMax, "_Frost_AttributeExposureMax");
		g.wetness = Lookup(ids::Frost_AttributeWetness, "_Frost_AttributeWetness");
		g.wetnessMax = Lookup(ids::Frost_AttributeWetnessMax, "_Frost_AttributeWetnessMax");
		g.tempLevel = Lookup(ids::Frost_AttributeMeterTempLevel, "_Frost_AttributeMeterTempLevel");
		g.tempLevelMax = Lookup(ids::Frost_AttributeMeterTempLevelMax, "_Frost_AttributeMeterTempLevelMax");
		g.warmth = Lookup(ids::Frost_AttributeWarmth, "_Frost_AttributeWarmth");
		g.warmthMax = Lookup(ids::Frost_Calc_MaxWarmth, "_Frost_Calc_MaxWarmth");
		g.coverage = Lookup(ids::Frost_AttributeCoverage, "_Frost_AttributeCoverage");
		g.coverageMax = Lookup(ids::Frost_Calc_MaxCoverage, "_Frost_Calc_MaxCoverage");
		g.meterMode = Lookup(ids::Frost_Setting_MeterDisplayMode, "_Frost_Setting_MeterDisplayMode");
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
