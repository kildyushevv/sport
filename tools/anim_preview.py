"""Рендер превью поз в PNG (для проверки глазами)."""
from PIL import Image, ImageDraw, ImageFont
from anim_core import *

LIME = (198, 255, 0)
LIME_FAR = (96, 122, 8)
WHITE = (236, 236, 236)
BG = (18, 18, 18)
FLOOR = (70, 70, 70)
SS = 2  # суперсэмплинг

FONT = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 13)
FONT_B = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 14)


def draw_skeleton(d, s, tf, scale, camera):
    def pt(p):
        x, y = tf(p)
        return (x * SS, y * SS)

    def seg(a, b, color, w):
        d.line([pt(a), pt(b)], fill=color, width=max(1, int(w * scale * SS)))
        r = w * scale * SS / 2
        for q in (a, b):
            x, y = pt(q)
            d.ellipse([x - r, y - r, x + r, y + r], fill=color)

    # дальние конечности
    for chain, color in ((s.arm_f, LIME_FAR), (s.leg_f, LIME_FAR)):
        for a, b in zip(chain, chain[1:]):
            seg(a, b, color, LIMB_W)
    # торс
    seg(s.hip, s.mid, WHITE, TORSO_W)
    seg(s.mid, s.neck, WHITE, TORSO_W)
    # голова
    x, y = pt(s.head)
    r = HEAD_R * scale * SS
    d.ellipse([x - r, y - r, x + r, y + r], fill=WHITE)
    # ближние конечности
    for chain in (s.leg_n, s.arm_n):
        for a, b in zip(chain, chain[1:]):
            seg(a, b, LIME, LIMB_W)


def render_pose(p, motion, size=(220, 190), bounds=None):
    w, h = size
    b = bounds or motion.bounds()
    x0, x1, y0, y1 = b
    pad = 14
    scale = min((w - 2 * pad) / (x1 - x0), (h - 2 * pad - 14) / (y1 - y0))
    cx = (x0 + x1) / 2
    base_y = h - pad - 4

    def tf(pnt):
        return (w / 2 + (pnt[0] - cx) * scale, base_y + pnt[1] * scale)

    img = Image.new("RGB", (w * SS, h * SS), BG)
    d = ImageDraw.Draw(img)
    fy = base_y * SS
    d.line([(10 * SS, fy), ((w - 10) * SS, fy)], fill=FLOOR, width=2 * SS)
    s = place(p, motion.camera, motion.anchor)
    # тень
    draw_skeleton(d, s, tf, scale, motion.camera)
    return img.resize((w, h), Image.LANCZOS)


def sheet(motions, path, frames_per_row=None, size=(220, 190)):
    """По строке на упражнение: ключевые кадры + подпись."""
    rows = []
    for m in motions:
        b = m.bounds()
        imgs = []
        for k in m.keys:
            im = render_pose(k.pose, m, size, b)
            dr = ImageDraw.Draw(im)
            dr.text((8, 6), k.caption[:26], fill=(200, 200, 200), font=FONT)
            imgs.append(im)
        row = Image.new("RGB", (size[0] * max(1, len(imgs)) + 150, size[1]), BG)
        dr = ImageDraw.Draw(row)
        dr.text((8, 8), m.id, fill=LIME, font=FONT_B)
        dr.text((8, 28), f"{m.camera}/{m.anchor}", fill=(150, 150, 150), font=FONT)
        dr.text((8, 46), f"{m.period():.1f} c", fill=(150, 150, 150), font=FONT)
        for i, im in enumerate(imgs):
            row.paste(im, (150 + i * size[0], 0))
        rows.append(row)
    W = max(r.width for r in rows)
    H = sum(r.height for r in rows)
    out = Image.new("RGB", (W, H), BG)
    y = 0
    for r in rows:
        out.paste(r, (0, y))
        y += r.height
    out.save(path)
    return path
