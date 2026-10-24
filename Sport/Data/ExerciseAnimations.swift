// Сгенерировано tools/make_animations.py — не редактируйте вручную.
// Позы описаны в tools/anim_defs.py.

enum ExerciseAnimations {
    static let motions: [String: ExerciseMotion] = [
        "air-squat": ExerciseMotion(
            camera: .side, anchor: .footN,
            bounds: MotionBounds(minX: -0.276, maxX: 0.28, minY: -0.966, maxY: 0.022),
            keys: [
                MotionKey(Pose(an1: 20.0, an2: 30.0, af1: 20.0, af2: 30.0), seconds: 0.9, caption: "Таз назад и вниз"),
                MotionKey(Pose(torso: 36.0, head: -21.6, an1: 90.0, an2: 90.0, af1: 90.0, af2: 90.0, ln1: 87.301, ln2: -17.652, lf1: 87.301, lf2: -17.652), seconds: 0.9, caption: "Встаём, толкаясь всей стопой"),
            ]
        ),
        "bicycle-crunch": ExerciseMotion(
            camera: .side, anchor: .none,
            bounds: MotionBounds(minX: -0.479, maxX: 0.567, minY: -0.356, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: -72.0, head: 10.0, an1: -100.0, an2: 100.0, af1: -95.0, af2: 105.0, ln1: 190.0, ln2: 100.0, lf1: 100.0, lf2: 100.0), seconds: 0.55, caption: "Локоть к противоположному колену"),
                MotionKey(Pose(torso: -72.0, head: 10.0, an1: -100.0, an2: 100.0, af1: -95.0, af2: 105.0, ln1: 100.0, ln2: 100.0, lf1: 190.0, lf2: 100.0), seconds: 0.55, caption: "Меняем стороны, как педали"),
            ]
        ),
        "burpee": ExerciseMotion(
            camera: .side, anchor: .none,
            bounds: MotionBounds(minX: -0.412, maxX: 0.598, minY: -1.311, maxY: 0.022),
            keys: [
                MotionKey(Pose(an1: 8.0, an2: 12.0, af1: -4.0, af2: 4.0, x: 0.1), seconds: 0.5, caption: "Присед, ладони на пол"),
                MotionKey(Pose(torso: 100.0, head: -20.0, an1: -0.028, an2: 45.627, af1: -0.028, af2: 45.627, ln1: 68.131, ln2: -21.273, lf1: 68.131, lf2: -21.273, x: -0.035), seconds: 0.35, caption: "Прыжком уходим в планку"),
                MotionKey(Pose(torso: 73.41, head: -6.0, an1: -7.967, an2: 8.54, af1: -7.967, af2: 8.54, ln1: -73.41, ln2: -73.41, lf1: -73.41, lf2: -73.41, fn: 0.0, ff: 0.0, x: 0.072), seconds: 0.35, caption: "Прыжком возвращаемся в присед"),
                MotionKey(Pose(torso: 100.0, head: -20.0, an1: -0.028, an2: 45.627, af1: -0.028, af2: 45.627, ln1: 68.131, ln2: -21.273, lf1: 68.131, lf2: -21.273, x: -0.035), seconds: 0.3, caption: "Выпрыгиваем вверх"),
                MotionKey(Pose(torso: -2.0, head: 2.0, an1: 170.0, an2: 175.0, af1: 170.0, af2: 175.0, ln1: 4.0, ln2: 4.0, lf1: 4.0, lf2: 4.0, fn: 45.0, ff: 45.0, air: 0.15, x: 0.1), seconds: 0.4, caption: "Мягко приземляемся"),
            ]
        ),
        "cat-cow": ExerciseMotion(
            camera: .side, anchor: .none,
            bounds: MotionBounds(minX: -0.344, maxX: 0.421, minY: -0.469, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 78.0, head: -30.0, spine: -24.0, ln2: -90.0, lf2: -90.0, fn: -90.0, ff: -90.0), seconds: 1.6, caption: "Выдох: округляем спину, подбородок к груди"),
                MotionKey(Pose(torso: 78.0, head: 38.0, spine: 34.0, ln2: -90.0, lf2: -90.0, fn: -90.0, ff: -90.0), seconds: 1.6, caption: "Вдох: прогибаемся, взгляд вверх"),
            ]
        ),
        "dead-bug": ExerciseMotion(
            camera: .side, anchor: .none,
            bounds: MotionBounds(minX: -0.634, maxX: 0.567, minY: -0.646, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: -90.0, an1: 180.0, an2: 180.0, af1: 180.0, af2: 180.0, ln1: 180.0, ln2: 90.0, lf1: 180.0, lf2: 90.0), seconds: 0.5, caption: "Опускаем руку и противоположную ногу"),
                MotionKey(Pose(torso: -90.0, an1: 180.0, an2: 180.0, af1: -95.0, af2: -100.0, ln1: 100.0, ln2: 100.0, lf1: 180.0, lf2: 90.0), seconds: 0.7, caption: "Возвращаемся в «столик»"),
                MotionKey(Pose(torso: -90.0, an1: 180.0, an2: 180.0, af1: 180.0, af2: 180.0, ln1: 180.0, ln2: 90.0, lf1: 180.0, lf2: 90.0), seconds: 0.5, caption: "Теперь другая рука и нога"),
                MotionKey(Pose(torso: -90.0, an1: -95.0, an2: -100.0, af1: 180.0, af2: 180.0, ln1: 180.0, ln2: 90.0, lf1: 100.0, lf2: 100.0), seconds: 0.7, caption: "Возвращаемся в «столик»"),
            ]
        ),
        "diamond-push-up": ExerciseMotion(
            camera: .side, anchor: .footN,
            bounds: MotionBounds(minX: -0.044, maxX: 0.886, minY: -0.441, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 73.41, head: -6.0, an1: -7.967, an2: 8.54, af1: -7.967, af2: 8.54, ln1: -73.41, ln2: -73.41, lf1: -73.41, lf2: -73.41, fn: 0.0, ff: 0.0), seconds: 1.0, caption: "Ладони ромбом, локти у корпуса"),
                MotionKey(Pose(torso: 85.85, head: -6.0, an1: -60.396, an2: 68.68, af1: -60.396, af2: 68.68, ln1: -85.85, ln2: -85.85, lf1: -85.85, lf2: -85.85, fn: 0.0, ff: 0.0), seconds: 1.0, caption: "Выжимаем вверх"),
            ]
        ),
        "glute-bridge": ExerciseMotion(
            camera: .side, anchor: .footN,
            bounds: MotionBounds(minX: -0.738, maxX: 0.044, minY: -0.389, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: -90.0, an1: 75.0, an2: 80.0, af1: 75.0, af2: 80.0, ln1: 133.419, ln2: 15.882, lf1: 133.419, lf2: 15.882), seconds: 0.9, caption: "Поднимаем таз, сжимаем ягодицы"),
                MotionKey(Pose(torso: -135.0, head: 45.0, an1: 60.0, an2: 75.0, af1: 60.0, af2: 75.0, ln1: 65.152, ln2: -9.689, lf1: 65.152, lf2: -9.689), seconds: 0.9, caption: "Плавно опускаемся"),
            ]
        ),
        "high-knees": ExerciseMotion(
            camera: .side, anchor: .none,
            bounds: MotionBounds(minX: -0.119, maxX: 0.361, minY: -0.989, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 6.0, head: -4.0, an1: -45.0, an2: 40.0, af1: 55.0, af2: 140.0, ln1: 100.0, ln2: 5.0, air: 0.025), seconds: 0.22, caption: "Колено выше таза"),
                MotionKey(Pose(torso: 6.0, head: -4.0, an1: 10.0, an2: 60.0, af1: 10.0, af2: 60.0, ln1: 20.0, ln2: -10.0, lf1: 20.0, lf2: -10.0), seconds: 0.12, caption: ""),
                MotionKey(Pose(torso: 6.0, head: -4.0, an1: 55.0, an2: 140.0, af1: -45.0, af2: 40.0, lf1: 100.0, lf2: 5.0, air: 0.025), seconds: 0.22, caption: "Меняем ногу, руки работают"),
                MotionKey(Pose(torso: 6.0, head: -4.0, an1: 10.0, an2: 60.0, af1: 10.0, af2: 60.0, ln1: 20.0, ln2: -10.0, lf1: 20.0, lf2: -10.0), seconds: 0.12, caption: ""),
            ]
        ),
        "hip-opener": ExerciseMotion(
            camera: .side, anchor: .footN,
            bounds: MotionBounds(minX: -0.599, maxX: 0.299, minY: -0.898, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 62.0, head: -18.0, an1: 16.581, an2: 16.882, af1: 16.581, af2: 16.882, ln1: 83.127, ln2: -14.696, lf1: -18.184, lf2: -97.122, ff: -12.0), seconds: 1.4, caption: "Поворот: рука к потолку, взгляд за рукой"),
                MotionKey(Pose(torso: 18.0, an1: 172.0, an2: 178.0, af1: 40.0, af2: 20.0, ln1: 83.127, ln2: -14.696, lf1: -18.184, lf2: -97.122, ff: -12.0), seconds: 1.4, caption: "Возвращаем ладонь на пол"),
            ]
        ),
        "inchworm": ExerciseMotion(
            camera: .side, anchor: .footN,
            bounds: MotionBounds(minX: -0.143, maxX: 0.851, minY: -0.966, maxY: 0.022),
            keys: [
                MotionKey(Pose(an1: 8.0, an2: 12.0, af1: -4.0, af2: 4.0), seconds: 0.7, caption: "Наклоняемся, ладони к полу"),
                MotionKey(Pose(torso: 168.0, head: -15.0, an1: -37.637, an2: 70.049, af1: -37.637, af2: 70.049), seconds: 0.9, caption: "Шагаем руками вперёд до планки"),
                MotionKey(Pose(torso: 73.41, head: -6.0, an1: -7.967, an2: 8.54, af1: -7.967, af2: 8.54, ln1: -73.41, ln2: -73.41, lf1: -73.41, lf2: -73.41, fn: 0.0, ff: 0.0), seconds: 0.9, caption: "Подтягиваем ноги к рукам"),
                MotionKey(Pose(torso: 168.0, head: -15.0, an1: -37.637, an2: 70.049, af1: -37.637, af2: 70.049), seconds: 0.8, caption: "Выпрямляемся"),
            ]
        ),
        "jump-lunge": ExerciseMotion(
            camera: .side, anchor: .none,
            bounds: MotionBounds(minX: -0.359, maxX: 0.285, minY: -1.127, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 4.0, head: -2.0, an1: 25.0, an2: 75.0, af1: 25.0, af2: 75.0, ln1: 83.127, ln2: -14.696, lf1: -18.184, lf2: -97.122, ff: -12.0), seconds: 0.3, caption: "Выпрыгиваем вверх"),
                MotionKey(Pose(torso: -3.0, head: 2.0, an1: 60.0, an2: 130.0, af1: 60.0, af2: 130.0, ln1: 18.0, ln2: -8.0, lf1: -18.0, lf2: -40.0, fn: 60.0, ff: 30.0, air: 0.14), seconds: 0.3, caption: "Меняем ноги в воздухе"),
                MotionKey(Pose(torso: 4.0, head: -2.0, an1: 25.0, an2: 75.0, af1: 25.0, af2: 75.0, ln1: -18.184, ln2: -97.122, lf1: 83.127, lf2: -14.696, fn: -12.0), seconds: 0.3, caption: "Выпрыгиваем вверх"),
                MotionKey(Pose(torso: -3.0, head: 2.0, an1: 60.0, an2: 130.0, af1: 60.0, af2: 130.0, ln1: -18.0, ln2: -40.0, lf1: 18.0, lf2: -8.0, fn: 30.0, ff: 60.0, air: 0.14), seconds: 0.3, caption: "Меняем ноги в воздухе"),
            ]
        ),
        "jumping-jacks": ExerciseMotion(
            camera: .front, anchor: .none,
            bounds: MotionBounds(minX: -0.424, maxX: 0.424, minY: -1.109, maxY: 0.022),
            keys: [
                MotionKey(Pose(an1: 14.0, an2: 10.0, af1: -14.0, af2: -10.0, ln1: 3.0, ln2: 3.0, lf1: -3.0, lf2: -3.0), seconds: 0.4, caption: "Прыжок: ноги и руки в стороны"),
                MotionKey(Pose(an1: 148.0, an2: 162.0, af1: -148.0, af2: -162.0, ln1: 20.0, ln2: 20.0, lf1: -20.0, lf2: -20.0, air: 0.05), seconds: 0.4, caption: "Прыжок: возвращаемся"),
            ]
        ),
        "mountain-climbers": ExerciseMotion(
            camera: .side, anchor: .handN,
            bounds: MotionBounds(minX: -0.772, maxX: 0.122, minY: -0.672, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 73.41, head: -6.0, an1: -7.967, an2: 8.54, af1: -7.967, af2: 8.54, ln1: 109.955, ln2: -30.343, lf1: -73.41, lf2: -73.41, fn: 0.0, ff: 0.0), seconds: 0.3, caption: "Колено к груди, затем меняем ногу"),
                MotionKey(Pose(torso: 73.41, head: -6.0, an1: -7.967, an2: 8.54, af1: -7.967, af2: 8.54, ln1: -73.41, ln2: -73.41, lf1: 109.955, lf2: -30.343, fn: 0.0, ff: 0.0), seconds: 0.3, caption: "Бежим в планке, таз не поднимаем"),
            ]
        ),
        "pike-push-up": ExerciseMotion(
            camera: .side, anchor: .footN,
            bounds: MotionBounds(minX: -0.068, maxX: 0.569, minY: -0.582, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 121.0, head: 25.0, an1: -24.587, an2: -24.286, af1: -24.587, af2: -24.286, ln1: -32.0, ln2: -32.0, lf1: -32.0, lf2: -32.0, fn: 20.0, ff: 20.0), seconds: 0.9, caption: "Опускаем голову между рук"),
                MotionKey(Pose(torso: 175.0, head: 25.0, an1: -17.564, an2: 84.255, af1: -17.564, af2: 84.255, ln1: -32.0, ln2: -32.0, lf1: -32.0, lf2: -32.0, fn: 20.0, ff: 20.0), seconds: 0.9, caption: "Выжимаем таз вверх и назад"),
            ]
        ),
        "plank": ExerciseMotion(
            camera: .side, anchor: .footN,
            bounds: MotionBounds(minX: -0.044, maxX: 0.94, minY: -0.297, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 83.958, head: -6.0, an2: 90.0, af2: 90.0, ln1: -83.958, ln2: -83.958, lf1: -83.958, lf2: -83.958, fn: 0.0, ff: 0.0), seconds: 1.4, caption: "Тело — прямая линия, пресс напряжён"),
                MotionKey(Pose(torso: 83.427, head: -6.0, an2: 90.0, af2: 90.0, ln1: -83.427, ln2: -83.427, lf1: -83.427, lf2: -83.427, fn: 0.0, ff: 0.0), seconds: 1.4, caption: "Дышим, не прогибаем поясницу"),
            ]
        ),
        "push-up": ExerciseMotion(
            camera: .side, anchor: .footN,
            bounds: MotionBounds(minX: -0.044, maxX: 0.887, minY: -0.441, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 73.41, head: -6.0, an1: -7.967, an2: 8.54, af1: -7.967, af2: 8.54, ln1: -73.41, ln2: -73.41, lf1: -73.41, lf2: -73.41, fn: 0.0, ff: 0.0), seconds: 0.9, caption: "Опускаемся, локти под 45°"),
                MotionKey(Pose(torso: 86.606, head: -6.0, an1: -62.135, an2: 71.298, af1: -62.135, af2: 71.298, ln1: -86.606, ln2: -86.606, lf1: -86.606, lf2: -86.606, fn: 0.0, ff: 0.0), seconds: 0.9, caption: "Выжимаем вверх"),
            ]
        ),
        "reverse-lunge": ExerciseMotion(
            camera: .side, anchor: .footN,
            bounds: MotionBounds(minX: -0.599, maxX: 0.173, minY: -0.977, maxY: 0.022),
            keys: [
                MotionKey(Pose(an1: 25.0, an2: 75.0, af1: 25.0, af2: 75.0), seconds: 0.8, caption: "Шаг назад, колено к полу"),
                MotionKey(Pose(torso: 4.0, head: -2.0, an1: 25.0, an2: 75.0, af1: 25.0, af2: 75.0, ln1: 83.127, ln2: -14.696, lf1: -18.184, lf2: -97.122, ff: -12.0), seconds: 0.8, caption: "Отталкиваемся передней ногой"),
            ]
        ),
        "shadow-boxing": ExerciseMotion(
            camera: .side, anchor: .none,
            bounds: MotionBounds(minX: -0.162, maxX: 0.476, minY: -0.949, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 10.0, head: -6.0, an1: 40.0, an2: 150.0, af1: 55.0, af2: 150.0, ln1: 18.0, ln2: 6.0, lf1: -22.0, lf2: -8.0), seconds: 0.25, caption: "Стойка, руки у лица"),
                MotionKey(Pose(torso: 22.0, head: -6.0, an1: 88.0, an2: 92.0, af1: 65.0, af2: 160.0, ln1: 18.0, ln2: 6.0, lf1: -22.0, lf2: -8.0, x: 0.03), seconds: 0.18, caption: "Прямой удар"),
                MotionKey(Pose(torso: 10.0, head: -6.0, an1: 40.0, an2: 150.0, af1: 55.0, af2: 150.0, ln1: 18.0, ln2: 6.0, lf1: -22.0, lf2: -8.0), seconds: 0.25, caption: "Возвращаем руку"),
                MotionKey(Pose(torso: 22.0, head: -6.0, an1: 55.0, an2: 160.0, af1: 88.0, af2: 92.0, ln1: 18.0, ln2: 6.0, lf1: -22.0, lf2: -8.0, x: 0.03), seconds: 0.18, caption: "Удар другой рукой"),
            ]
        ),
        "side-plank": ExerciseMotion(
            camera: .front, anchor: .none,
            bounds: MotionBounds(minX: -0.502, maxX: 0.601, minY: -0.678, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 75.6, head: -75.6, an2: 90.0, af1: 35.0, af2: 15.0, ln1: -75.6, ln2: -75.6, lf1: -75.6, lf2: -75.6), seconds: 1.2, caption: "Тянемся рукой вверх, тело — прямая линия"),
                MotionKey(Pose(torso: 75.6, head: -75.6, an2: 90.0, af1: 172.0, af2: 172.0, ln1: -75.6, ln2: -75.6, lf1: -75.6, lf2: -75.6), seconds: 1.2, caption: "Опускаем руку, держим линию"),
            ]
        ),
        "skater-jump": ExerciseMotion(
            camera: .front, anchor: .none,
            bounds: MotionBounds(minX: -0.407, maxX: 0.407, minY: -1.021, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 14.0, an1: -40.0, an2: -20.0, af1: 35.0, af2: 70.0, ln1: 8.0, ln2: 14.0, lf1: -30.0, lf2: -12.0, x: 0.16), seconds: 0.22, caption: "Прыжок в сторону"),
                MotionKey(Pose(an1: 20.0, an2: 20.0, af1: -20.0, af2: -20.0, ln1: 10.0, ln2: 18.0, lf1: -14.0, lf2: -20.0, air: 0.07), seconds: 0.22, caption: "Мягко приземляемся на другую ногу"),
                MotionKey(Pose(torso: -14.0, an1: -35.0, an2: -70.0, af1: 40.0, af2: 20.0, ln1: 30.0, ln2: 12.0, lf1: -8.0, lf2: -14.0, x: -0.16), seconds: 0.22, caption: "Прыжок обратно"),
                MotionKey(Pose(an1: 20.0, an2: 20.0, af1: -20.0, af2: -20.0, ln1: 10.0, ln2: 18.0, lf1: -14.0, lf2: -20.0, air: 0.07), seconds: 0.22, caption: "Мягко приземляемся"),
            ]
        ),
        "squat-jump": ExerciseMotion(
            camera: .side, anchor: .none,
            bounds: MotionBounds(minX: -0.068, maxX: 0.403, minY: -1.322, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 36.0, head: -21.6, an1: -30.0, an2: -20.0, af1: -30.0, af2: -20.0, ln1: 87.301, ln2: -17.652, lf1: 87.301, lf2: -17.652), seconds: 0.5, caption: "Мощный прыжок вверх"),
                MotionKey(Pose(torso: -4.0, head: 2.0, an1: 165.0, an2: 175.0, af1: 165.0, af2: 175.0, ln1: 4.0, ln2: 4.0, lf1: 4.0, lf2: 4.0, fn: 40.0, ff: 40.0, air: 0.16), seconds: 0.35, caption: "Мягко приземляемся в присед"),
            ]
        ),
        "step-jack": ExerciseMotion(
            camera: .front, anchor: .none,
            bounds: MotionBounds(minX: -0.44, maxX: 0.44, minY: -1.086, maxY: 0.022),
            keys: [
                MotionKey(Pose(an1: 14.0, an2: 10.0, af1: -14.0, af2: -10.0, ln1: 3.0, ln2: 3.0, lf1: -3.0, lf2: -3.0), seconds: 0.5, caption: "Шаг вправо, руки вверх"),
                MotionKey(Pose(an1: 148.0, an2: 162.0, af1: -148.0, af2: -162.0, ln1: 24.0, ln2: 24.0, lf1: -3.0, lf2: -3.0, x: 0.03), seconds: 0.5, caption: "Приставляем ногу, руки вниз"),
                MotionKey(Pose(an1: 14.0, an2: 10.0, af1: -14.0, af2: -10.0, ln1: 3.0, ln2: 3.0, lf1: -3.0, lf2: -3.0), seconds: 0.5, caption: "Шаг влево, руки вверх"),
                MotionKey(Pose(an1: 148.0, an2: 162.0, af1: -148.0, af2: -162.0, ln1: 3.0, ln2: 3.0, lf1: -24.0, lf2: -24.0, x: -0.03), seconds: 0.5, caption: "Приставляем ногу, руки вниз"),
            ]
        ),
        "superman": ExerciseMotion(
            camera: .side, anchor: .none,
            bounds: MotionBounds(minX: -0.574, maxX: 0.634, minY: -0.268, maxY: 0.022),
            keys: [
                MotionKey(Pose(torso: 90.0, an1: 90.0, an2: 90.0, af1: 90.0, af2: 90.0, ln1: -90.0, ln2: -90.0, lf1: -90.0, lf2: -90.0, fn: -90.0, ff: -90.0), seconds: 0.9, caption: "Поднимаем руки, грудь и ноги"),
                MotionKey(Pose(torso: 76.0, head: -8.0, an1: 112.0, an2: 112.0, af1: 112.0, af2: 112.0, ln1: -108.0, ln2: -108.0, lf1: -108.0, lf2: -108.0, fn: -90.0, ff: -90.0), seconds: 0.9, caption: "Плавно опускаемся"),
            ]
        ),
    ]
}
