#!/usr/bin/env python3
"""Импорт GIF-анимаций упражнений из hasaneyldrm/exercises-dataset.

Использование (из корня репозитория):
    python3 tools/import_gifs.py [путь/к/exercises-dataset]

Копирует выбранные GIF в Sport/Resources/ExerciseGIFs/<id упражнения>.gif и генерирует
Sport/Data/ExerciseGifs.swift (таблица источников).

ВАЖНО: GIF в датасете — © Gym visual (https://gymvisual.com/). Код и тексты датасета под MIT,
а медиа — нет: нужно сохранять подпись «© Gym visual — https://gymvisual.com/», а для публикации
приложения получить лицензию у Gym visual (см. THIRD_PARTY_NOTICES.md).
"""
import json
import os
import re
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_DATASET = "/home/user/hasaneyldrm/exercises-dataset"
DEMO_DATA = os.path.join(ROOT, "Sport", "Data", "DemoData.swift")
GIF_DIR = os.path.join(ROOT, "Sport", "Resources", "ExerciseGIFs")
OUTPUT = os.path.join(ROOT, "Sport", "Data", "ExerciseGifs.swift")
ATTRIBUTION = "© Gym visual — https://gymvisual.com/"

# наш id упражнения -> (id записи в датасете, ожидаемое название)
MAPPING = {
    "jumping-jacks": ("3220", "astride jumps (male)"),
    "high-knees": ("3221", "half knee bends (male)"),
    "skater-jump": ("3361", "skater hops"),
    "shadow-boxing": ("2271", "left hook. boxing"),
    "squat-jump": ("0514", "jump squat"),
    "jump-lunge": ("3582", "lunge with jump"),
    "glute-bridge": ("3013", "low glute bridge on floor"),
    "bicycle-crunch": ("0003", "air bike"),
    "dead-bug": ("0276", "dead bug"),
    "push-up": ("0662", "push-up"),
    "diamond-push-up": ("0283", "diamond push-up"),
    "mountain-climbers": ("0630", "mountain climber"),
    "inchworm": ("1471", "inchworm"),
    "burpee": ("1160", "burpee"),
    "hip-opener": ("1604", "world greatest stretch"),
    "side-plank": ("0705", "side bridge v. 2"),
}


def our_exercise_ids():
    text = open(DEMO_DATA, encoding="utf-8").read()
    return set(re.findall(r'^\s+exercise\("([^"]+)",', text, re.M))


def main():
    dataset = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_DATASET
    records_path = os.path.join(dataset, "data", "exercises.json")
    if not os.path.exists(records_path):
        raise SystemExit(f"Не найден {records_path}. Клонируйте https://github.com/hasaneyldrm/exercises-dataset")

    records = {r["id"]: r for r in json.load(open(records_path, encoding="utf-8"))}
    ours = our_exercise_ids()
    os.makedirs(GIF_DIR, exist_ok=True)

    rows = []
    for exercise_id, (dataset_id, expected_name) in sorted(MAPPING.items()):
        if exercise_id not in ours:
            raise SystemExit(f"Нет упражнения {exercise_id} в DemoData.swift")
        record = records.get(dataset_id)
        if record is None:
            raise SystemExit(f"Нет записи {dataset_id} в датасете")
        if record["name"] != expected_name:
            raise SystemExit(f"{dataset_id}: ожидалось «{expected_name}», в датасете «{record['name']}»")
        source = os.path.join(dataset, record["gif_url"])
        shutil.copyfile(source, os.path.join(GIF_DIR, f"{exercise_id}.gif"))
        rows.append((exercise_id, dataset_id, record["name"]))

    # убрать GIF, которых больше нет в маппинге
    for name in os.listdir(GIF_DIR):
        if name.endswith(".gif") and name[:-4] not in MAPPING:
            os.remove(os.path.join(GIF_DIR, name))

    lines = [
        "// Сгенерировано tools/import_gifs.py — не редактируйте вручную.",
        "// GIF — © Gym visual (https://gymvisual.com/), источник: github.com/hasaneyldrm/exercises-dataset.",
        "// Условия использования: THIRD_PARTY_NOTICES.md.",
        "",
        "enum ExerciseGifs {",
        f'    static let attribution = "{ATTRIBUTION}"',
        "",
        "    /// Наш id упражнения → запись в датасете. Файл лежит в бандле как <id>.gif.",
        "    static let sources: [String: GifSource] = [",
    ]
    for exercise_id, dataset_id, name in rows:
        lines.append(f'        "{exercise_id}": GifSource(datasetID: "{dataset_id}", name: "{name}"),')
    lines += ["    ]", "}"]
    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

    total = sum(os.path.getsize(os.path.join(GIF_DIR, f"{i}.gif")) for i, _, _ in rows)
    print(f"Импортировано {len(rows)} GIF ({total // 1024} КБ) в {os.path.relpath(GIF_DIR, ROOT)}")


if __name__ == "__main__":
    main()
