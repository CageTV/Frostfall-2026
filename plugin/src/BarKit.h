/*
 * Copyright (c) 2026 CageTV
 *
 * Released under the MIT License; see LICENSE.txt.
 */
#pragma once

// The bars of Frostfall 2026, Last Seed 2026 and Stress and Fear 2026 share this one drawing and layout code (each repository carries an identical
// copy), so all three offer the same controls: standing or lying flat, filling from either end, a grid / row group or every bar placed by itself, and
// dragging a bar with the mouse. Include it after SKSEMenuFramework.h.
namespace BarKit
{
	using namespace ImGuiMCP;

	inline ImU32 Col(float r, float g, float b, float a)
	{
		return IM_COL32(static_cast<int>(std::clamp(r, 0.0f, 255.0f)), static_cast<int>(std::clamp(g, 0.0f, 255.0f)),
			static_cast<int>(std::clamp(b, 0.0f, 255.0f)), static_cast<int>(std::clamp(a, 0.0f, 1.0f) * 255.0f));
	}

	struct Rgb { float r, g, b; };
	inline Rgb Lerp(Rgb a, Rgb b, float t) { return { a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t }; }

	// Where a bar is: its top-left corner and size on screen (the size already follows the orientation), whether it lies flat, and which end it
	// fills from (standing: the bottom, or the top when flipped; flat: the left, or the right when flipped).
	struct Bar
	{
		float x = 0, y = 0, w = 0, h = 0;
		bool  horizontal = false;
		bool  flip = false;
	};

	// One flat bar: dark track, fill from its origin end, slightly lighter at the far end of the fill. No border.
	inline void DrawBar(ImDrawList* a_dl, const Bar& a_b, float a_fill, Rgb a_color, float a_alpha)
	{
		const float thin = a_b.horizontal ? a_b.h : a_b.w;
		const float rounding = std::min(thin * 0.35f, 4.0f);
		ImDrawListManager::AddRectFilled(a_dl, ImVec2(a_b.x, a_b.y), ImVec2(a_b.x + a_b.w, a_b.y + a_b.h), Col(10, 12, 16, 0.55f * a_alpha), rounding, 0);
		const float length = a_b.horizontal ? a_b.w : a_b.h;
		const float fl = length * std::clamp(a_fill, 0.0f, 1.0f);
		if (fl < 0.5f) {
			return;
		}
		const ImU32 cFar = Col(a_color.r + 35, a_color.g + 35, a_color.b + 35, 0.95f * a_alpha);
		const ImU32 cNear = Col(a_color.r * 0.8f, a_color.g * 0.8f, a_color.b * 0.8f, 0.95f * a_alpha);
		if (!a_b.horizontal) {
			if (!a_b.flip) {  // from the bottom, lighter at the top
				ImDrawListManager::AddRectFilledMultiColor(a_dl, ImVec2(a_b.x, a_b.y + a_b.h - fl), ImVec2(a_b.x + a_b.w, a_b.y + a_b.h), cFar, cFar, cNear, cNear);
			} else {  // from the top, lighter at the bottom
				ImDrawListManager::AddRectFilledMultiColor(a_dl, ImVec2(a_b.x, a_b.y), ImVec2(a_b.x + a_b.w, a_b.y + fl), cNear, cNear, cFar, cFar);
			}
		} else {
			if (!a_b.flip) {  // from the left, lighter at the right end of the fill
				ImDrawListManager::AddRectFilledMultiColor(a_dl, ImVec2(a_b.x, a_b.y), ImVec2(a_b.x + fl, a_b.y + a_b.h), cNear, cFar, cFar, cNear);
			} else {  // from the right, lighter at its left end
				ImDrawListManager::AddRectFilledMultiColor(a_dl, ImVec2(a_b.x + a_b.w - fl, a_b.y), ImVec2(a_b.x + a_b.w, a_b.y + a_b.h), cFar, cNear, cNear, cFar);
			}
		}
	}

	// A white glyph (transparent PNG) with a soft shadow, tinted here. a_x, a_y: the icon's top-left corner.
	inline void DrawIcon(ImDrawList* a_dl, ImTextureID a_tex, float a_x, float a_y, float a_size, float a_alpha)
	{
		if (!a_tex) {
			return;
		}
		ImDrawListManager::AddImage(a_dl, a_tex, ImVec2(a_x + 1.0f, a_y + 1.0f), ImVec2(a_x + a_size + 1.0f, a_y + a_size + 1.0f), ImVec2(0, 0), ImVec2(1, 1),
			Col(0, 0, 0, 0.55f * a_alpha));
		ImDrawListManager::AddImage(a_dl, a_tex, ImVec2(a_x, a_y), ImVec2(a_x + a_size, a_y + a_size), ImVec2(0, 0), ImVec2(1, 1), Col(225, 232, 240, 0.9f * a_alpha));
	}

	// The icon sits at the end the bar fills from: under a standing bar (above it when flipped), left of a flat one (right of it when flipped).
	inline void DrawIconFor(ImDrawList* a_dl, ImTextureID a_tex, const Bar& a_b, float a_k, float a_alpha)
	{
		const float size = 14.0f * a_k;
		const float pad = 5.0f * a_k;
		if (!a_b.horizontal) {
			DrawIcon(a_dl, a_tex, a_b.x + a_b.w * 0.5f - size * 0.5f, a_b.flip ? a_b.y - pad - size : a_b.y + a_b.h + pad, size, a_alpha);
		} else {
			DrawIcon(a_dl, a_tex, a_b.flip ? a_b.x + a_b.w + pad : a_b.x - pad - size, a_b.y + a_b.h * 0.5f - size * 0.5f, size, a_alpha);
		}
	}

	// The smallest rectangle holding all the given bars (and their icons, when a_icons), as one Bar.
	inline Bar Bounds(const Bar* a_bars, int a_count, float a_pad)
	{
		float x0 = 1e9f, y0 = 1e9f, x1 = -1e9f, y1 = -1e9f;
		for (int i = 0; i < a_count; ++i) {
			x0 = std::min(x0, a_bars[i].x - a_pad);
			y0 = std::min(y0, a_bars[i].y - a_pad);
			x1 = std::max(x1, a_bars[i].x + a_bars[i].w + a_pad);
			y1 = std::max(y1, a_bars[i].y + a_bars[i].h + a_pad);
		}
		return { x0, y0, x1 - x0, y1 - y0, false, false };
	}

	// What a grouped layout needs. posX is the group's right edge, posY its vertical centre (fractions of the screen); k is the pixel scale
	// (screen height / 1080 * scale); the sizes are in 1080p pixels before k.
	struct Group
	{
		int   layout = 0;         // 0 = 2 x 2 grid, 1 = single row (a single column when the bars lie flat)
		int   orientation = 0;    // 0 = standing, 1 = lying flat
		bool  flip = false;
		bool  icons = true;
		float thickness = 8.0f;
		float length = 96.0f;
		float spacing = 10.0f;
		float posX = 0.975f;
		float posY = 0.5f;
	};

	// The four slots of a grouped layout, left to right then top to bottom. The group hangs from its right edge and is centred on posY; the icons
	// (when shown) are on the fill-origin side. When a_top / a_bottom are given they get the group's top and bottom edge, icons included.
	inline void GroupedSlots(const Group& s, float W, float H, float k, Bar (&out)[4], float* a_top = nullptr, float* a_bottom = nullptr)
	{
		const float t = s.thickness * k;
		const float L = s.length * k;
		const float gap = s.spacing * k;
		const float g = gap * 1.6f;
		const bool  horiz = s.orientation == 1;
		const float right = s.posX * W;
		const float centerY = s.posY * H;
		const float iconSize = 14.0f * k;
		float       top = 0.0f, bottom = 0.0f;

		if (!horiz) {
			const float icon = s.icons ? 16.0f * k : 0.0f;
			const float iconSpace = s.icons ? icon + 6.0f * k : 0.0f;
			const float rowGap = gap + iconSpace;
			const float flipShift = s.flip ? iconSpace : 0.0f;  // a flipped bar has its icon above it
			if (s.layout == 0) {
				const float groupW = 2 * t + g;
				const float groupH = 2 * L + rowGap;
				const float x0 = right - groupW;
				const float y0 = centerY - groupH * 0.5f + flipShift * 0.5f;
				for (int i = 0; i < 4; ++i) {
					out[i] = { x0 + (i % 2) * (t + g), y0 + (i / 2) * (L + rowGap), t, L, false, s.flip };
				}
				top = y0 - flipShift;
				bottom = y0 + L + rowGap + L + (s.flip ? 0.0f : iconSpace);
			} else {
				const float step = t + g;
				const float x0 = right - (4 * t + 3 * g);
				const float y0 = centerY - (L + iconSpace) * 0.5f + flipShift;
				for (int i = 0; i < 4; ++i) {
					out[i] = { x0 + i * step, y0, t, L, false, s.flip };
				}
				top = y0 - flipShift;
				bottom = y0 + L + (s.flip ? 0.0f : iconSpace);
			}
		} else {
			// lying flat: the icon is at the fill-origin side, the bar is L long and t thick
			const float iconW = s.icons ? iconSize + 6.0f * k : 0.0f;
			const float rowH = std::max(t, s.icons ? iconSize : 0.0f);
			const float colStep = iconW + L + g;
			const float rowStep = rowH + g;
			const float barOff = s.flip ? 0.0f : iconW;
			const float yOff = (rowH - t) * 0.5f;
			if (s.layout == 0) {
				const float groupW = 2 * colStep - g;
				const float groupH = 2 * rowStep - g;
				const float x0 = right - groupW;
				const float y0 = centerY - groupH * 0.5f;
				for (int i = 0; i < 4; ++i) {
					out[i] = { x0 + (i % 2) * colStep + barOff, y0 + (i / 2) * rowStep + yOff, L, t, true, s.flip };
				}
				top = y0;
				bottom = y0 + groupH;
			} else {
				const float groupW = colStep - g;
				const float groupH = 4 * rowStep - g;
				const float x0 = right - groupW;
				const float y0 = centerY - groupH * 0.5f;
				for (int i = 0; i < 4; ++i) {
					out[i] = { x0 + barOff, y0 + i * rowStep + yOff, L, t, true, s.flip };
				}
				top = y0;
				bottom = y0 + groupH;
			}
		}
		if (a_top) {
			*a_top = top;
		}
		if (a_bottom) {
			*a_bottom = bottom;
		}
	}

	// One bar placed on its own: its centre (fractions of the screen), orientation and fill end.
	struct Placed
	{
		float x = 0.5f;
		float y = 0.5f;
		int   orient = 0;  // 0 = standing, 1 = lying flat
		bool  flip = false;
		float length = 0.0f;     // 0 = the shared length
		float thickness = 0.0f;  // 0 = the shared thickness
	};

	template <std::size_t N>
	inline void FreeSlots(const Placed (&a_placed)[N], float a_thickness, float a_length, float W, float H, float k, Bar (&out)[N])
	{
		for (std::size_t i = 0; i < N; ++i) {
			const float t = (a_placed[i].thickness > 0.0f ? a_placed[i].thickness : a_thickness) * k;
			const float L = (a_placed[i].length > 0.0f ? a_placed[i].length : a_length) * k;
			const bool  horiz = a_placed[i].orient == 1;
			const float w = horiz ? L : t;
			const float h = horiz ? t : L;
			out[i] = { a_placed[i].x * W - w * 0.5f, a_placed[i].y * H - h * 0.5f, w, h, horiz, a_placed[i].flip };
		}
	}

	// Drag bars with the mouse. a_drag keeps the bar being dragged between frames (-1 = none). Returns the index of the bar that moved this frame
	// (-1 = none) and its move as fractions of the screen in a_dx / a_dy. Draws a frame around every bar.
	// a_only >= 0: only that bar can be picked up and framed (the rest stay locked).
	inline int HandleDrag(ImDrawList* a_dl, const Bar* a_bars, int a_count, int& a_drag, float W, float H, float& a_dx, float& a_dy, int a_only = -1)
	{
		auto*        io = GetIO();
		const ImVec2 m = io->MousePos;
		auto         inside = [&](const Bar& b) {
            const float pad = 8.0f;
            return m.x >= b.x - pad && m.x <= b.x + b.w + pad && m.y >= b.y - pad && m.y <= b.y + b.h + pad;
		};
		int moved = -1;
		a_dx = a_dy = 0.0f;
		if (a_drag < 0 && IsMouseClicked(0) && !io->WantCaptureMouse) {
			for (int i = 0; i < a_count; ++i) {
				if ((a_only < 0 || i == a_only) && inside(a_bars[i])) {
					a_drag = i;
					break;
				}
			}
		}
		if (a_drag >= 0) {
			if (IsMouseDown(0)) {
				a_dx = io->MouseDelta.x / W;
				a_dy = io->MouseDelta.y / H;
				moved = a_drag;
			} else {
				a_drag = -1;
			}
		}
		for (int i = 0; i < a_count; ++i) {
			if (a_only >= 0 && i != a_only) {
				continue;
			}
			const Bar& b = a_bars[i];
			const bool active = i == a_drag || (a_drag < 0 && inside(b));
			ImDrawListManager::AddRect(a_dl, ImVec2(b.x - 5, b.y - 5), ImVec2(b.x + b.w + 5, b.y + b.h + 5), active ? Col(255, 220, 110, 0.95f) : Col(255, 255, 255, 0.45f), 3.0f, 0,
				1.5f);
		}
		return moved;
	}
}
