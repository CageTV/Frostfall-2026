/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#include "PCH.h"
#include "Game.h"
#include "SpellMonitor.h"

namespace
{
	// Skyrim.esm keywords, used only to recognise fire and frost damage effects (the same two the Papyrus script filtered on).
	constexpr RE::FormID kMagicDamageFire = 0x01CEAD;
	constexpr RE::FormID kMagicDamageFrost = 0x01CEAE;

	class Sink final : public RE::BSTEventSink<RE::TESMagicEffectApplyEvent>
	{
	public:
		static Sink* Get()
		{
			static Sink instance;
			return std::addressof(instance);
		}

		RE::BSEventNotifyControl ProcessEvent(const RE::TESMagicEffectApplyEvent* a_event, RE::BSTEventSource<RE::TESMagicEffectApplyEvent>*) override
		{
			// Runs for every effect applied to every actor in the game: the cheapest test goes first.
			if (!a_event || !a_event->target || a_event->target.get() != RE::PlayerCharacter::GetSingleton()) {
				return RE::BSEventNotifyControl::kContinue;
			}
			if (!Game::IsRunning()) {  // Frostfall is not started or has been stopped: nothing to monitor
				return RE::BSEventNotifyControl::kContinue;
			}
			const auto* effect = RE::TESForm::LookupByID<RE::EffectSetting>(a_event->magicEffect);
			if (!effect) {
				return RE::BSEventNotifyControl::kContinue;
			}
			float flags = 0.0f;
			if (effect->HasKeywordID(kMagicDamageFire)) {
				flags += 1.0f;
			}
			if (effect->HasKeywordID(kMagicDamageFrost)) {
				flags += 2.0f;
			}
			if (flags > 0.0f) {
				SKSE::ModCallbackEvent event{ "Frostfall_PlayerMagicDamage", "", flags, nullptr };
				SKSE::GetModCallbackEventSource()->SendEvent(&event);
			}
			return RE::BSEventNotifyControl::kContinue;
		}
	};
}

namespace SpellMonitor
{
	void Register()
	{
		auto* holder = RE::ScriptEventSourceHolder::GetSingleton();
		if (!holder) {
			SKSE::log::error("Spell monitor: script event source not available, fire and frost damage will not be noticed");
			return;
		}
		holder->AddEventSink<RE::TESMagicEffectApplyEvent>(Sink::Get());
		SKSE::log::info("Spell monitor: listening for fire and frost effects applied to the player");
	}
}
