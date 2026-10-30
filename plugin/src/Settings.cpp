/*
 * Frostfall 2026
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#include "PCH.h"
#include "Settings.h"

namespace
{
	const std::filesystem::path kPath = "Data/SKSE/Plugins/Frostfall.ini";

	std::string Trim(std::string_view a_s)
	{
		const auto b = a_s.find_first_not_of(" \t\r\n");
		if (b == std::string_view::npos) {
			return {};
		}
		const auto e = a_s.find_last_not_of(" \t\r\n");
		return std::string(a_s.substr(b, e - b + 1));
	}

	std::string Lower(std::string a_s)
	{
		std::transform(a_s.begin(), a_s.end(), a_s.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
		return a_s;
	}
}

Settings& Settings::Get()
{
	static Settings instance;
	return instance;
}

void Settings::Load()
{
	std::ifstream in(kPath);
	if (!in) {
		SKSE::log::info("{} not found; using defaults", kPath.string());
		return;
	}
	std::unordered_map<std::string, std::string> kv;
	std::string line;
	while (std::getline(in, line)) {
		const auto t = Trim(line);
		if (t.empty() || t[0] == ';' || t[0] == '#' || t[0] == '[') {
			continue;
		}
		const auto eq = t.find('=');
		if (eq != std::string::npos) {
			kv[Lower(Trim(std::string_view(t).substr(0, eq)))] = Trim(std::string_view(t).substr(eq + 1));
		}
	}
	auto b = [&](const char* k, bool& v) { if (auto it = kv.find(k); it != kv.end()) v = it->second == "1" || Lower(it->second) == "true"; };
	auto i = [&](const char* k, int& v) { if (auto it = kv.find(k); it != kv.end()) try { v = std::stoi(it->second); } catch (...) {} };
	auto f = [&](const char* k, float& v) { if (auto it = kv.find(k); it != kv.end()) try { v = std::stof(it->second); } catch (...) {} };

	b("bautostart", autoStart);
	b("bhudenabled", hudEnabled);
	i("idisplaymode", displayMode);
	i("ilayout", layout);
	i("iorientation", orientation);
	b("bflipfill", flipFill);
	for (int n = 0; n < kBars; ++n) {
		const std::string p = "free" + std::to_string(n);
		f((p + "x").c_str(), freeBar[n].x);
		f((p + "y").c_str(), freeBar[n].y);
		i((p + "orient").c_str(), freeBar[n].orient);
		b((p + "flip").c_str(), freeBar[n].flip);
		f((p + "length").c_str(), freeBar[n].length);
		f((p + "thickness").c_str(), freeBar[n].thickness);
	}
	f("fposx", posX);
	f("fposy", posY);
	f("fscale", scale);
	f("fopacity", opacity);
	f("fbarlength", barLength);
	f("fbarthickness", barThickness);
	f("fspacing", spacing);
	f("fcontextualseconds", contextualSeconds);
	f("fchangepercent", changePercent);
	f("fstayexposurepercent", stayExposurePercent);
	f("fstaywetnesspercent", stayWetnessPercent);
	b("bshowexposure", showExposure);
	b("bshowwetness", showWetness);
	b("bshowtemperature", showTemperature);
	b("bshowwarmth", showWarmth);
	b("bshowicons", showIcons);
	i("isavedmetermode", savedMeterMode);
	b("bitemcardvalues", itemCardValues);
	f("fcardx", cardX);
	f("fcardy", cardY);
	f("fcardsize", cardSize);
	f("fcardgridx", cardGridX);
	f("fcardgridy", cardGridY);
	cardGridX = std::clamp(cardGridX, 0.0f, 1.0f);
	cardGridY = std::clamp(cardGridY, 0.0f, 1.0f);
	cardX = std::clamp(cardX, 0.0f, 1.0f);
	cardY = std::clamp(cardY, 0.0f, 1.0f);
	cardSize = std::clamp(cardSize, 10.0f, 80.0f);
	int version = 1;
	i("iversion", version);

	displayMode = std::clamp(displayMode, 0, 1);
	layout = std::clamp(layout, 0, 2);
	orientation = std::clamp(orientation, 0, 1);
	for (auto& fb : freeBar) {
		fb.x = std::clamp(fb.x, 0.0f, 1.0f);
		fb.y = std::clamp(fb.y, 0.0f, 1.0f);
		fb.orient = std::clamp(fb.orient, 0, 1);
		fb.length = fb.length <= 0.0f ? 0.0f : std::clamp(fb.length, 30.0f, 400.0f);
		fb.thickness = fb.thickness <= 0.0f ? 0.0f : std::clamp(fb.thickness, 3.0f, 30.0f);
	}
	posX = std::clamp(posX, 0.0f, 1.0f);
	posY = std::clamp(posY, 0.0f, 1.0f);
	scale = std::clamp(scale, 0.5f, 3.0f);
	opacity = std::clamp(opacity, 0.1f, 1.0f);
	barLength = std::clamp(barLength, 30.0f, 400.0f);
	barThickness = std::clamp(barThickness, 3.0f, 30.0f);
	spacing = std::clamp(spacing, 2.0f, 40.0f);
	contextualSeconds = std::clamp(contextualSeconds, 1.0f, 60.0f);
	changePercent = std::clamp(changePercent, 0.1f, 20.0f);
	stayExposurePercent = std::clamp(stayExposurePercent, 0.0f, 100.0f);
	stayWetnessPercent = std::clamp(stayWetnessPercent, 0.0f, 100.0f);
	SKSE::log::info("Loaded {}", kPath.string());

	if (version < kVersion) {
		displayMode = 1;  // 3.5.0 test builds defaulted to "always"; the bars now fade out while nothing changes
		SKSE::log::info("Settings from an older Frostfall.dll: HUD display set to contextual");
		Save();
	}
}

void Settings::Save() const
{
	std::ostringstream out;  // built in memory and written in one go (see the end of this function)
	out << "; Frostfall.dll settings. Edit them in game from the SKSE Menu Framework page (Frostfall).\n\n";
	out << "[General]\n";
	out << "iVersion=" << kVersion << "\n";
	out << "bAutoStart=" << (autoStart ? 1 : 0) << "\n\n";
	out << "[HUD]\n";
	out << "bHudEnabled=" << (hudEnabled ? 1 : 0) << "\n";
	out << "iDisplayMode=" << displayMode << "\n";
	out << "iLayout=" << layout << "\n";
	out << "iOrientation=" << orientation << "\n";
	out << "bFlipFill=" << (flipFill ? 1 : 0) << "\n";
	for (int n = 0; n < kBars; ++n) {
		out << std::format("fFree{0}X={1:.4f}\nfFree{0}Y={2:.4f}\niFree{0}Orient={3}\nbFree{0}Flip={4}\nfFree{0}Length={5:.1f}\nfFree{0}Thickness={6:.1f}\n", n, freeBar[n].x,
			freeBar[n].y, freeBar[n].orient, freeBar[n].flip ? 1 : 0, freeBar[n].length, freeBar[n].thickness);
	}
	out << std::format("fPosX={:.4f}\nfPosY={:.4f}\nfScale={:.3f}\nfOpacity={:.3f}\n", posX, posY, scale, opacity);
	out << std::format("fBarLength={:.1f}\nfBarThickness={:.1f}\nfSpacing={:.1f}\nfContextualSeconds={:.1f}\n", barLength, barThickness, spacing, contextualSeconds);
	out << std::format("fChangePercent={:.1f}\nfStayExposurePercent={:.0f}\nfStayWetnessPercent={:.0f}\n", changePercent, stayExposurePercent, stayWetnessPercent);
	out << "bShowExposure=" << (showExposure ? 1 : 0) << "\n";
	out << "bShowWetness=" << (showWetness ? 1 : 0) << "\n";
	out << "bShowTemperature=" << (showTemperature ? 1 : 0) << "\n";
	out << "bShowWarmth=" << (showWarmth ? 1 : 0) << "\n";
	out << "bShowIcons=" << (showIcons ? 1 : 0) << "\n";
	out << "iSavedMeterMode=" << savedMeterMode << "\n";
	out << "bItemCardValues=" << (itemCardValues ? 1 : 0) << "\n";
	out << std::format("fCardX={:.3f}\nfCardY={:.3f}\nfCardSize={:.0f}\nfCardGridX={:.3f}\nfCardGridY={:.3f}\n", cardX, cardY, cardSize, cardGridX, cardGridY);

	// Written to a temporary file and moved over the INI, so a crash or a full disk in the middle of the write can never leave a half-written
	// or empty Frostfall.ini behind (which the next start would read as "all defaults": bar positions back to where they began).
	const std::string text = out.str();
	std::error_code   ec;
	const auto        absolute = std::filesystem::absolute(kPath, ec);
	auto              tmp = kPath;
	tmp += ".tmp";
	{
		std::ofstream file(tmp, std::ios::trunc | std::ios::binary);
		file << text;
		file.flush();
		if (!file) {
			SKSE::log::error("Could not write {} (is the folder read-only?); the HUD settings are NOT saved", tmp.string());
			return;
		}
	}
	std::filesystem::rename(tmp, kPath, ec);
	if (ec) {
		SKSE::log::warn("Could not replace {} by moving ({}); writing it directly", kPath.string(), ec.message());
		std::ofstream direct(kPath, std::ios::trunc | std::ios::binary);
		direct << text;
		direct.flush();
		if (!direct) {
			SKSE::log::error("Could not write {}; the HUD settings are NOT saved", kPath.string());
			return;
		}
	}
	std::filesystem::remove(tmp, ec);
	SKSE::log::info("Saved {} ({} bytes)", absolute.string(), text.size());
}

void Settings::ResetHudLayout()
{
	const Settings d;
	displayMode = d.displayMode;
	layout = d.layout;
	orientation = d.orientation;
	flipFill = d.flipFill;
	for (int n = 0; n < kBars; ++n) {
		freeBar[n] = d.freeBar[n];
	}
	posX = d.posX;
	posY = d.posY;
	scale = d.scale;
	opacity = d.opacity;
	barLength = d.barLength;
	barThickness = d.barThickness;
	spacing = d.spacing;
	contextualSeconds = d.contextualSeconds;
	showExposure = showWetness = showTemperature = showWarmth = showIcons = true;
}
