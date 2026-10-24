#!/usr/bin/env python3
"""Генератор анимаций упражнений.

Использование (из корня репозитория):
    python3 tools/make_animations.py                 # перегенерировать Sport/Data/ExerciseAnimations.swift
    python3 tools/make_animations.py --preview out.png [id ...]   # контактный лист поз

Позы описаны в tools/anim_defs.py, кинематика — в tools/anim_core.py (зеркально повторена
в Sport/Models/Motion.swift). Генератор падает, если у домашнего упражнения из
Sport/Data/DemoData.swift нет анимации.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)

from anim_core import Pose  # noqa: E402
from anim_defs import MOTIONS  # noqa: E402

DEMO_DATA = os.path.join(ROOT, "Sport", "Data", "DemoData.swift")
OUTPUT = os.path.join(ROOT, "Sport", "Data", "ExerciseAnimations.swift")

DEFAULTS = Pose()


def home_friendly_ids():
    text = open(DEMO_DATA, encoding="utf-8").read()
    found = re.findall(
        r'^\s+exercise\("([^"]+)",\s*"[^"]+",\s*\.\w+,\s*\n\s+secondary: "[^"]*", equipment: "([^"]+)"',
        text, re.M)
    return [i for i, eq in found if eq in ("Свой вес", "Коврик")]


def num(v):
    r = round(v, 3)
    if r == 0:
        r = 0.0
    text = f"{r:.3f}".rstrip("0").rstrip(".")
    return text if "." in text else text + ".0"


def swift_pose(p):
    parts = []
    for f in Pose.FIELDS:
        v = getattr(p, f)
        if abs(v - getattr(DEFAULTS, f)) > 1e-9:
            parts.append(f"{f}: {num(v)}")
    return "Pose(" + ", ".join(parts) + ")"


def swift_string(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def generate():
    ids = [m.id for m in MOTIONS]
    if len(set(ids)) != len(ids):
        raise SystemExit("Повторяющиеся id анимаций")
    needed = home_friendly_ids()
    missing = [i for i in needed if i not in ids]
    extra = [i for i in ids if i not in needed]
    if missing:
        raise SystemExit(f"Нет анимации для: {', '.join(missing)}")
    if extra:
        raise SystemExit(f"Анимации для неизвестных/неподходящих упражнений: {', '.join(extra)}")

    lines = [
        "// Сгенерировано tools/make_animations.py — не редактируйте вручную.",
        "// Позы описаны в tools/anim_defs.py.",
        "",
        "enum ExerciseAnimations {",
        "    static let motions: [String: ExerciseMotion] = [",
    ]
    for m in sorted(MOTIONS, key=lambda m: m.id):
        x0, x1, y0, y1 = m.bounds()
        lines.append(f'        "{m.id}": ExerciseMotion(')
        lines.append(f"            camera: .{m.camera}, anchor: .{m.anchor},")
        lines.append(f"            bounds: MotionBounds(minX: {num(x0)}, maxX: {num(x1)}, minY: {num(y0)}, maxY: {num(y1)}),")
        lines.append("            keys: [")
        for k in m.keys:
            lines.append(
                f"                MotionKey({swift_pose(k.pose)}, seconds: {num(k.seconds)}, caption: {swift_string(k.caption)}),")
        lines.append("            ]")
        lines.append("        ),")
    lines.append("    ]")
    lines.append("}")
    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(f"Записано {len(MOTIONS)} анимаций в {os.path.relpath(OUTPUT, ROOT)}")


def preview(path, only):
    from anim_preview import sheet
    ms = [m for m in MOTIONS if not only or m.id in only]
    print(sheet(ms, path))


if __name__ == "__main__":
    args = sys.argv[1:]
    if args and args[0] == "--preview":
        preview(args[1], args[2:])
    else:
        generate()
