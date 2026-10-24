"""Определения поз упражнений. Единственный источник правды для анимаций."""
from anim_core import *

MOTIONS = []


def add_motion(m):
    MOTIONS.append(m)
    return m


STAND = Pose(an1=8, an2=12, af1=-4, af2=4)   # расслабленная стойка, руки вдоль тела


def K(pose, seconds, caption=""):
    return Key(pose, seconds, caption)


# =============== Кардио, стоя ===============

# Джампинг джек (спереди)
add_motion(Motion("jumping-jacks", "front", "none", [
    K(Pose(an1=14, an2=10, af1=-14, af2=-10, ln1=3, ln2=3, lf1=-3, lf2=-3), 0.4, "Прыжок: ноги и руки в стороны"),
    K(Pose(an1=148, an2=162, af1=-148, af2=-162, ln1=20, ln2=20, lf1=-20, lf2=-20, air=0.05), 0.4, "Прыжок: возвращаемся"),
]))

# Шаги в стороны с махом рук (спереди)
closed = Pose(an1=14, an2=10, af1=-14, af2=-10, ln1=3, ln2=3, lf1=-3, lf2=-3)
add_motion(Motion("step-jack", "front", "none", [
    K(closed, 0.5, "Шаг вправо, руки вверх"),
    K(Pose(an1=148, an2=162, af1=-148, af2=-162, ln1=24, ln2=24, lf1=-3, lf2=-3, x=0.03), 0.5, "Приставляем ногу, руки вниз"),
    K(closed, 0.5, "Шаг влево, руки вверх"),
    K(Pose(an1=148, an2=162, af1=-148, af2=-162, ln1=3, ln2=3, lf1=-24, lf2=-24, x=-0.03), 0.5, "Приставляем ногу, руки вниз"),
]))

# Бег с высокими коленями (сбоку)
def run_pose(knee_near, air=0.0):
    if knee_near:
        return Pose(torso=6, head=-4, an1=-45, an2=40, af1=55, af2=140,
                    ln1=100, ln2=5, lf1=0, lf2=0, air=air)
    return Pose(torso=6, head=-4, an1=55, an2=140, af1=-45, af2=40,
                ln1=0, ln2=0, lf1=100, lf2=5, air=air)

add_motion(Motion("high-knees", "side", "none", [
    K(run_pose(True, 0.025), 0.22, "Колено выше таза"),
    K(run_pose(True).set(ln1=20, ln2=-10, lf1=20, lf2=-10, an1=10, an2=60, af1=10, af2=60), 0.12, ""),
    K(run_pose(False, 0.025), 0.22, "Меняем ногу, руки работают"),
    K(run_pose(False).set(ln1=20, ln2=-10, lf1=20, lf2=-10, an1=10, an2=60, af1=10, af2=60), 0.12, ""),
]))

# Конькобежец (спереди)
def skater(side):
    # side=+1: стоим на ближней (правой) ноге, дальняя уходит за неё
    if side > 0:
        return Pose(torso=14, an1=-40, an2=-20, af1=35, af2=70, ln1=8, ln2=14, lf1=-30, lf2=-12, x=0.16)
    return Pose(torso=-14, an1=-35, an2=-70, af1=40, af2=20, ln1=30, ln2=12, lf1=-8, lf2=-14, x=-0.16)

SKATER_AIR = Pose(torso=0, an1=20, an2=20, af1=-20, af2=-20, ln1=10, ln2=18, lf1=-14, lf2=-20, air=0.07)
add_motion(Motion("skater-jump", "front", "none", [
    K(skater(+1), 0.22, "Прыжок в сторону"),
    K(SKATER_AIR, 0.22, "Мягко приземляемся на другую ногу"),
    K(skater(-1), 0.22, "Прыжок обратно"),
    K(SKATER_AIR, 0.22, "Мягко приземляемся"),
]))

# Бой с тенью (сбоку)
guard = Pose(torso=10, head=-6, an1=40, an2=150, af1=55, af2=150,
             ln1=18, ln2=6, lf1=-22, lf2=-8, fn=90, ff=90)
add_motion(Motion("shadow-boxing", "side", "none", [
    K(guard, 0.25, "Стойка, руки у лица"),
    K(guard.set(torso=22, an1=88, an2=92, af1=65, af2=160, x=0.03), 0.18, "Прямой удар"),
    K(guard, 0.25, "Возвращаем руку"),
    K(guard.set(torso=22, af1=88, af2=92, an1=55, an2=160, x=0.03), 0.18, "Удар другой рукой"),
]))

# =============== Ноги ===============

def squat_pose(h, dx, lean, arms=90):
    a1, a2 = leg(dx, h, bend=1)
    return Pose(torso=lean, head=-lean * 0.6, an1=arms, an2=arms, af1=arms, af2=arms,
                ln1=a1, ln2=a2, lf1=a1, lf2=a2)

SQUAT_BOTTOM = squat_pose(0.23, 0.16, 36, 90)
add_motion(Motion("air-squat", "side", "footN", [
    K(STAND.set(an1=20, an2=30, af1=20, af2=30), 0.9, "Таз назад и вниз"),
    K(SQUAT_BOTTOM, 0.9, "Встаём, толкаясь всей стопой"),
]))

# Прыжки из приседа
add_motion(Motion("squat-jump", "side", "none", [
    K(SQUAT_BOTTOM.set(an1=-30, an2=-20, af1=-30, af2=-20), 0.5, "Мощный прыжок вверх"),
    K(Pose(torso=-4, head=2, an1=165, an2=175, af1=165, af2=175, ln1=4, ln2=4, lf1=4, lf2=4,
           fn=40, ff=40, air=0.16), 0.35, "Мягко приземляемся в присед"),
]))


def plant_legs(p, dx, bend=1, rear_dx=None, rear_lift=0.0, rear_foot=None):
    """Ставит ноги на пол: нижняя точка верхней части тела задаёт высоту лодыжек.
    dx — вынос ближней лодыжки вперёд от таза; rear_dx — для дальней ноги (если другая)."""
    s = build_skeleton(p, "side")
    pts = [(q[0], q[1] + LIMB_W / 2) for q in (s.arm_n + s.arm_f)]
    pts += [(q[0], q[1] + TORSO_W / 2) for q in (s.hip, s.mid, s.neck)]
    pts += [(s.head[0], s.head[1] + HEAD_R)]
    floor = max(y for _, y in pts)
    ankle_y = floor - LIMB_W / 2
    a1, a2 = leg(dx, ankle_y, bend)
    q = p.set(ln1=a1, ln2=a2)
    if rear_dx is None:
        return q.set(lf1=a1, lf2=a2)
    b1, b2 = leg(rear_dx, ankle_y - rear_lift, bend)
    return q.set(lf1=b1, lf2=b2)


# =============== Выпады ===============

LUNGE_ARMS = dict(an1=25, an2=75, af1=25, af2=75)

def lunge_pose(front_is_near=True, torso=4):
    base = Pose(torso=torso, head=-2, ff=-12, **LUNGE_ARMS)
    # передняя нога: колено 90°, дальняя: колено у пола, носок на полу
    f1, f2 = leg(0.17, 0.25, bend=1)
    r1, r2 = leg(-0.30, 0.25 - 0.06, bend=1)
    if front_is_near:
        return base.set(ln1=f1, ln2=f2, lf1=r1, lf2=r2, fn=90, ff=-12)
    return base.set(lf1=f1, lf2=f2, ln1=r1, ln2=r2, ff=90, fn=-12)

add_motion(Motion("reverse-lunge", "side", "footN", [
    K(STAND.set(an1=25, an2=75, af1=25, af2=75), 0.8, "Шаг назад, колено к полу"),
    K(lunge_pose(True), 0.8, "Отталкиваемся передней ногой"),
]))

apex = Pose(torso=-3, head=2, an1=60, an2=130, af1=60, af2=130, ln1=18, ln2=-8, lf1=-18, lf2=-40, fn=60, ff=30, air=0.14)
apex_b = Pose(torso=-3, head=2, an1=60, an2=130, af1=60, af2=130, lf1=18, lf2=-8, ln1=-18, ln2=-40, ff=60, fn=30, air=0.14)
add_motion(Motion("jump-lunge", "side", "none", [
    K(lunge_pose(True), 0.3, "Выпрыгиваем вверх"),
    K(apex, 0.3, "Меняем ноги в воздухе"),
    K(lunge_pose(False), 0.3, "Выпрыгиваем вверх"),
    K(apex_b, 0.3, "Меняем ноги в воздухе"),
]))

# =============== Лёжа ===============

def supine(**kw):
    base = Pose(torso=-90, head=0, an1=75, an2=80, af1=75, af2=80)
    return base.set(**kw)

# Ягодичный мост
bridge_down = plant_legs(supine(), 0.23, bend=1)
bridge_up_base = supine(torso=-135, head=45, an1=60, an2=75, af1=60, af2=75)
bridge_up = plant_legs(bridge_up_base, 0.17, bend=1)
add_motion(Motion("glute-bridge", "side", "footN", [
    K(bridge_down, 0.9, "Поднимаем таз, сжимаем ягодицы"),
    K(bridge_up, 0.9, "Плавно опускаемся"),
]))

# Велосипед
def bicycle(near_in):
    base = supine(torso=-72, head=10, an1=-100, an2=100, af1=-95, af2=105)
    tucked = (190, 100)
    out = (100, 100)
    if near_in:
        return base.set(ln1=tucked[0], ln2=tucked[1], lf1=out[0], lf2=out[1])
    return base.set(lf1=tucked[0], lf2=tucked[1], ln1=out[0], ln2=out[1])

add_motion(Motion("bicycle-crunch", "side", "none", [
    K(bicycle(True), 0.55, "Локоть к противоположному колену"),
    K(bicycle(False), 0.55, "Меняем стороны, как педали"),
]))

# Мёртвый жук
tabletop = supine(an1=180, an2=180, af1=180, af2=180, ln1=180, ln2=90, lf1=180, lf2=90)
add_motion(Motion("dead-bug", "side", "none", [
    K(tabletop, 0.5, "Опускаем руку и противоположную ногу"),
    K(tabletop.set(ln1=100, ln2=100, af1=-95, af2=-100), 0.7, "Возвращаемся в «столик»"),
    K(tabletop, 0.5, "Теперь другая рука и нога"),
    K(tabletop.set(lf1=100, lf2=100, an1=-95, an2=-100), 0.7, "Возвращаемся в «столик»"),
]))

# Суперман
prone = Pose(torso=90, head=0, an1=90, an2=90, af1=90, af2=90, ln1=-90, ln2=-90, lf1=-90, lf2=-90, fn=-90, ff=-90)
super_up = Pose(torso=76, head=-8, an1=112, an2=112, af1=112, af2=112, ln1=-108, ln2=-108, lf1=-108, lf2=-108, fn=-90, ff=-90)
add_motion(Motion("superman", "side", "none", [
    K(prone, 0.9, "Поднимаем руки, грудь и ноги"),
    K(super_up, 0.9, "Плавно опускаемся"),
]))


# =============== Упор лёжа: отжимания, планка, скалолаз ===============

def shoulder_height(t):
    p = Pose(torso=t, head=-6, an1=180, an2=180, af1=180, af2=180,
             ln1=-t, ln2=-t, lf1=-t, lf2=-t, fn=0, ff=0)
    s = place(p, "side", "footN")
    return -s.neck[1] - LIMB_W / 2


def torso_for_height(h):
    lo, hi = 30.0, 89.9
    for _ in range(60):
        mid = (lo + hi) / 2
        if shoulder_height(mid) > h:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


def plank_pose(h, hand_dx=0.0, bend=-1):
    t = torso_for_height(h)
    p = Pose(torso=t, head=-6, ln1=-t, ln2=-t, lf1=-t, lf2=-t, fn=0, ff=0)
    return floor_arms(p, "side", "footN", hand_dx, bend)


TOP = 0.287
BOTTOM = 0.115

add_motion(Motion("push-up", "side", "footN", [
    K(plank_pose(TOP), 0.9, "Опускаемся, локти под 45°"),
    K(plank_pose(BOTTOM), 0.9, "Выжимаем вверх"),
]))
add_motion(Motion("diamond-push-up", "side", "footN", [
    K(plank_pose(TOP), 1.0, "Ладони ромбом, локти у корпуса"),
    K(plank_pose(BOTTOM + 0.01), 1.0, "Выжимаем вверх"),
]))

# Планка на предплечьях
def forearm_plank(h=0.15):
    t = torso_for_height(h)
    return Pose(torso=t, head=-6, an1=0, an2=90, af1=0, af2=90,
                ln1=-t, ln2=-t, lf1=-t, lf2=-t, fn=0, ff=0)

add_motion(Motion("plank", "side", "footN", [
    K(forearm_plank(0.15), 1.4, "Тело — прямая линия, пресс напряжён"),
    K(forearm_plank(0.157), 1.4, "Дышим, не прогибаем поясницу"),
]))

# Скалолаз
def climber(near_in):
    base = plank_pose(TOP)
    t = base.torso
    # поднятая нога: лодыжка у груди
    k1, k2 = leg(0.10, THIGH + SHANK - 0.46 * 0 + 0.0 - 0.34, bend=1)
    flex = (k1, k2)
    if near_in:
        return base.set(ln1=flex[0], ln2=flex[1])
    return base.set(lf1=flex[0], lf2=flex[1])

add_motion(Motion("mountain-climbers", "side", "handN", [
    K(climber(True), 0.3, "Колено к груди, затем меняем ногу"),
    K(climber(False), 0.3, "Бежим в планке, таз не поднимаем"),
]))

# Отжимания «горкой»
def pike(shoulder_h, hand_world_x):
    # таз высоко: ноги прямые, торс идёт вниз к рукам
    leg_a = -32
    best = None
    for t in range(100, 176):
        p = Pose(torso=t, head=0, an1=180, an2=180, af1=180, af2=180,
                 ln1=leg_a, ln2=leg_a, lf1=leg_a, lf2=leg_a, fn=20, ff=20)
        s = place(p, "side", "footN")
        h = -s.neck[1] - LIMB_W / 2
        if best is None or abs(h - shoulder_h) < best[0]:
            best = (abs(h - shoulder_h), p, s)
    _, p, s = best
    dx = hand_world_x - s.neck[0]
    return floor_arms(p.set(head=25), "side", "footN", dx, -1)

_probe = pike(0.30, 0.34)
add_motion(Motion("pike-push-up", "side", "footN", [
    K(pike(0.30, 0.34), 0.9, "Опускаем голову между рук"),
    K(pike(0.14, 0.34), 0.9, "Выжимаем таз вверх и назад"),
]))

# Боковая планка (спереди)
def side_plank(torso_adjust=0.0):
    best = None
    for t10 in range(300, 890):
        t = t10 / 10
        p = Pose(torso=t, head=-t + 90 - 90 + 0, an1=0, an2=90, af1=172, af2=172,
                 ln1=-t, ln2=-t, lf1=-t, lf2=-t)
        s = build_skeleton(p, "front")
        elbow_y = s.arm_n[1][1] + LIMB_W / 2
        hand_y = s.arm_n[2][1] + LIMB_W / 2
        ankle_y = max(s.leg_n[2][1], s.leg_f[2][1]) + LIMB_W / 2
        err = abs(max(elbow_y, hand_y) - ankle_y)
        if best is None or err < best[0]:
            best = (err, p)
    return best[1].set(torso=best[1].torso + torso_adjust)

add_motion(Motion("side-plank", "front", "none", [
    K(side_plank().set(af1=35, af2=15), 1.2, "Тянемся рукой вверх, тело — прямая линия"),
    K(side_plank(), 1.2, "Опускаем руку, держим линию"),
]))


# =============== Гусеница ===============

def fold_pose(hand_dx=0.04):
    p = Pose(torso=168, head=-15, ln1=0, ln2=0, lf1=0, lf2=0, fn=90, ff=90)
    return floor_arms(p, "side", "footN", hand_dx, bend=-1)

add_motion(Motion("inchworm", "side", "footN", [
    K(STAND, 0.7, "Наклоняемся, ладони к полу"),
    K(fold_pose(), 0.9, "Шагаем руками вперёд до планки"),
    K(plank_pose(TOP), 0.9, "Подтягиваем ноги к рукам"),
    K(fold_pose(), 0.8, "Выпрямляемся"),
]))

# =============== Бёрпи ===============

HAND_X = 0.36

def crouch_hands():
    leg1, leg2 = leg(0.13, 0.30, bend=1)
    p = Pose(torso=100, head=-20, ln1=leg1, ln2=leg2, lf1=leg1, lf2=leg2)
    p = floor_arms(p, "side", "footN", 0.10, bend=-1)
    return x_for(p, "side", "handN", HAND_X)

def burpee_plank():
    return x_for(plank_pose(TOP), "side", "handN", HAND_X)

JUMP_UP = Pose(torso=-2, head=2, an1=170, an2=175, af1=170, af2=175,
               ln1=4, ln2=4, lf1=4, lf2=4, fn=45, ff=45, air=0.15, x=0.10)
add_motion(Motion("burpee", "side", "none", [
    K(STAND.set(x=0.10), 0.5, "Присед, ладони на пол"),
    K(crouch_hands(), 0.35, "Прыжком уходим в планку"),
    K(burpee_plank(), 0.35, "Прыжком возвращаемся в присед"),
    K(crouch_hands(), 0.3, "Выпрыгиваем вверх"),
    K(JUMP_UP, 0.4, "Мягко приземляемся"),
]))

# =============== Кошка-корова ===============

def quadruped(spine, head):
    return Pose(torso=78, head=head, spine=spine, an1=0, an2=0, af1=0, af2=0,
                ln1=0, ln2=-90, lf1=0, lf2=-90, fn=-90, ff=-90)

add_motion(Motion("cat-cow", "side", "none", [
    K(quadruped(-24, -30), 1.6, "Выдох: округляем спину, подбородок к груди"),
    K(quadruped(34, 38), 1.6, "Вдох: прогибаемся, взгляд вверх"),
]))

# =============== Глубокий выпад с поворотом ===============

def lunge_reach(rotate):
    base = lunge_pose(True, torso=4)
    if not rotate:
        p = base.set(torso=62, head=-18)
        return floor_arms(p, "side", "footN", 0.12, bend=-1)
    return base.set(torso=18, head=0, an1=172, an2=178, af1=40, af2=20)

add_motion(Motion("hip-opener", "side", "footN", [
    K(lunge_reach(False), 1.4, "Поворот: рука к потолку, взгляд за рукой"),
    K(lunge_reach(True), 1.4, "Возвращаем ладонь на пол"),
]))
