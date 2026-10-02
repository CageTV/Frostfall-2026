"""Draw Frostfall.dll's HUD icons: white glyphs on transparent 64x64 PNGs (supersampled 8x for smooth edges).

Usage: python tools/make_icons.py  -> assets/icons/*.png and assets/icons/preview.png
"""
import math
import os

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(HERE, "assets", "icons")
S = 64
K = 8
N = S * K
W = (255, 255, 255, 255)


def canvas():
    im = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def finish(im, name):
    im = im.resize((S, S), Image.LANCZOS)
    im.save(os.path.join(OUT, name))
    return im


def line(d, a, b, w):
    d.line([a, b], fill=W, width=w)
    r = w / 2
    for p in (a, b):
        d.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=W)


def snowflake():
    im, d = canvas()
    c = N / 2
    R = N * 0.44
    w = int(N * 0.075)
    for i in range(6):
        a = math.radians(90 + i * 60)
        ux, uy = math.cos(a), -math.sin(a)
        tip = (c + ux * R, c + uy * R)
        line(d, (c, c), tip, w)
        for f, blen in ((0.55, 0.26), (0.8, 0.16)):
            base = (c + ux * R * f, c + uy * R * f)
            for s in (-1, 1):
                b = a + s * math.radians(45)
                bx, by = math.cos(b), -math.sin(b)
                line(d, base, (base[0] + bx * R * blen, base[1] + by * R * blen), int(w * 0.85))
    return finish(im, "exposure.png")


def droplet():
    im, d = canvas()
    cx, cy, r = N / 2, N * 0.62, N * 0.27
    top = (cx, N * 0.08)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=W)
    # tangent points from the tip to the circle
    dist = cy - top[1]
    t = math.asin(r / dist)
    p1 = (cx - r * math.cos(t), cy - r * math.sin(t))
    p2 = (cx + r * math.cos(t), cy - r * math.sin(t))
    d.polygon([top, p1, p2], fill=W)
    return finish(im, "wetness.png")


def thermometer():
    im, d = canvas()
    cx = N * 0.46
    tw = N * 0.2          # tube outer width
    top, bottom = N * 0.08, N * 0.62
    br = N * 0.19         # bulb radius
    by = N * 0.74
    o = int(N * 0.06)     # outline thickness
    # outer shape
    d.rounded_rectangle([cx - tw / 2, top, cx + tw / 2, by], radius=tw / 2, fill=W)
    d.ellipse([cx - br, by - br, cx + br, by + br], fill=W)
    # hollow the tube
    iw = tw - 2 * o
    d.rounded_rectangle([cx - iw / 2, top + o, cx + iw / 2, by], radius=iw / 2, fill=(0, 0, 0, 0))
    # mercury column + bulb
    mw = iw * 0.5
    d.rounded_rectangle([cx - mw / 2, N * 0.34, cx + mw / 2, by], radius=mw / 2, fill=W)
    d.ellipse([cx - br + o, by - br + o, cx + br - o, by + br - o], fill=W)
    # scale ticks
    for y in (0.2, 0.32, 0.44):
        d.rectangle([cx + tw / 2 + N * 0.05, N * y - N * 0.02, cx + tw / 2 + N * 0.2, N * y + N * 0.02], fill=W)
    return finish(im, "temperature.png")


def tunic():
    im, d = canvas()
    x = lambda f: N * f
    body = [(x(0.30), x(0.12)), (x(0.42), x(0.12)), (x(0.50), x(0.24)), (x(0.58), x(0.12)), (x(0.70), x(0.12)),
            (x(0.95), x(0.30)), (x(0.84), x(0.46)), (x(0.74), x(0.40)), (x(0.74), x(0.90)), (x(0.26), x(0.90)),
            (x(0.26), x(0.40)), (x(0.16), x(0.46)), (x(0.05), x(0.30))]
    d.polygon(body, fill=W)
    # belt
    d.rectangle([x(0.26), x(0.60), x(0.74), x(0.66)], fill=(0, 0, 0, 0))
    return finish(im, "warmth.png")


def main():
    os.makedirs(OUT, exist_ok=True)
    icons = [snowflake(), droplet(), thermometer(), tunic()]
    pv = Image.new("RGBA", (S * 4 * 3 + 40, S * 3 + 20), (110, 118, 128, 255))
    for i, ic in enumerate(icons):
        big = ic.resize((S * 3, S * 3), Image.LANCZOS)
        pv.alpha_composite(big, (10 + i * (S * 3 + 10), 10))
    pv.save(os.path.join(OUT, "preview.png"))
    small = Image.new("RGBA", (200, 40), (110, 118, 128, 255))
    for i, ic in enumerate(icons):
        small.alpha_composite(ic.resize((18, 18), Image.LANCZOS), (10 + i * 45, 11))
    small = small.resize((800, 160), Image.NEAREST)
    small.save(os.path.join(OUT, "preview_ingame_size.png"))
    print("wrote", OUT)


if __name__ == "__main__":
    main()
