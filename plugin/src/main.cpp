#include "PCH.h"
#include "Game.h"
#include "Hud.h"
#include "Menu.h"
#include "Settings.h"

namespace
{
	void SetupLog()
	{
		const auto dir = SKSE::log::log_directory();
		if (!dir) {
			return;
		}
		auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>((*dir / "Frostfall.log").string(), true);
		auto log = std::make_shared<spdlog::logger>("Frostfall", std::move(sink));
		log->set_level(spdlog::level::info);
		log->flush_on(spdlog::level::info);
		log->set_pattern("[%Y-%m-%d %H:%M:%S.%e] [%l] %v");
		spdlog::set_default_logger(std::move(log));
	}

	// ---------- Papyrus: FrostfallNative ----------
	bool AutoStartEnabled(RE::StaticFunctionTag*)
	{
		return Settings::Get().autoStart;
	}

	void ShowStartupLogo(RE::StaticFunctionTag*)
	{
		Hud::ShowStartupLogo();
	}

	bool HudBarsActive(RE::StaticFunctionTag*)
	{
		return Menu::Registered() && Settings::Get().hudEnabled;
	}

	// Where Frostfall's makeshift camp goes next to a campfire: a_distance units from the fire toward the player, at
	// terrain height (exteriors), turned so the lean-to's open side (mesh -X) faces the fire.
	// Returns [x, y, z, zAngleDegrees, heightDifferenceFromFire], or an empty array if there is no fire.
	std::vector<float> GetCampSpot(RE::StaticFunctionTag*, RE::TESObjectREFR* a_fire, float a_distance, float a_angleOffset)
	{
		auto* player = RE::PlayerCharacter::GetSingleton();
		if (!a_fire || !player) {
			return {};
		}
		const auto fire = a_fire->GetPosition();
		const auto me = player->GetPosition();
		float dx = me.x - fire.x;
		float dy = me.y - fire.y;
		float len = std::sqrt(dx * dx + dy * dy);
		if (len < 1.0f) {  // standing on the fire: use the player's heading
			const float h = player->GetAngleZ();
			dx = -std::sin(h);
			dy = -std::cos(h);
			len = 1.0f;
		}
		const float ux = dx / len;
		const float uy = dy / len;
		// The camp goes on the far side of the fire from the player, so the fire sits between them (on the player's
		// side it ended up behind a player standing closer than a_distance - seen in game 2026-10-01).
		const float x = fire.x - ux * a_distance;
		const float y = fire.y - uy * a_distance;
		float z = fire.z;
		auto* cell = player->GetParentCell();
		if (cell && !cell->IsInteriorCell()) {
			float land = 0.0f;
			if (auto* tes = RE::TES::GetSingleton(); tes && tes->GetLandHeight(RE::NiPoint3(x, y, fire.z + 2000.0f), land)) {
				z = land;
			}
		}
		// Skyrim's Z angle runs clockwise from north; local +X then points to (cos a, -sin a). This is the camp
		// ACTIVATOR's angle, and Campfire's tent system places the shelter static rotated 180 degrees from it
		// (measured in game 2026-10-01: activator 76.1, shelter 256.1). So the activator's +X points at the fire,
		// along (ux, uy); the shelter's +X then points away from it and its open side (-X) faces the fire.
		float angle = std::atan2(-uy, ux) * 180.0f / 3.14159265f + a_angleOffset;
		angle = std::fmod(angle + 720.0f, 360.0f);
		return { x, y, z, angle, std::abs(z - fire.z) };
	}

	// How deep the water is at the player's feet, in game units (0 = not standing in water). Uses the engine's own
	// water height for the player (the value behind IsInWater), so it covers rivers, lakes, the sea and cell water.
	float GetPlayerWaterDepth(RE::StaticFunctionTag*)
	{
		auto* player = RE::PlayerCharacter::GetSingleton();
		if (!player || !player->Is3DLoaded()) {
			return 0.0f;
		}
		const float depth = player->GetWaterHeight() - player->GetPositionZ();
		return (depth > 0.0f && depth < 1000.0f) ? depth : 0.0f;
	}

	bool RegisterPapyrus(RE::BSScript::IVirtualMachine* a_vm)
	{
		a_vm->RegisterFunction("AutoStartEnabled", "FrostfallNative", AutoStartEnabled);
		a_vm->RegisterFunction("ShowStartupLogo", "FrostfallNative", ShowStartupLogo);
		a_vm->RegisterFunction("HudBarsActive", "FrostfallNative", HudBarsActive);
		a_vm->RegisterFunction("GetPlayerWaterDepth", "FrostfallNative", GetPlayerWaterDepth);
		a_vm->RegisterFunction("GetCampSpot", "FrostfallNative", GetCampSpot);
		return true;
	}

	void OnMessage(SKSE::MessagingInterface::Message* a_msg)
	{
		switch (a_msg->type) {
		case SKSE::MessagingInterface::kPostLoad:
			Menu::Register();  // SKSE Menu Framework loads after us alphabetically, so register once everything is loaded
			break;
		case SKSE::MessagingInterface::kDataLoaded:
			Game::Init();
			break;
		default:
			break;
		}
	}
}

SKSEPluginLoad(const SKSE::LoadInterface* a_skse)
{
	SKSE::Init(a_skse);
	SetupLog();
	SKSE::log::info("Frostfall.dll 4.0.0, game {}", REL::Module::get().version().string());
	Settings::Get().Load();
	SKSE::GetPapyrusInterface()->Register(RegisterPapyrus);
	SKSE::GetMessagingInterface()->RegisterListener(OnMessage);
	return true;
}
