"""Кинематика и рендер превью для анимаций упражнений.

Математика здесь зеркально повторена в Sport/Models/Motion.swift. Углы в градусах:
для конечностей 0 — вниз, +90 — вперёд (вправо), для торса 0 — вверх, +90 — вправо.
Координаты: x вправо, y вниз, единица — рост фигуры (около 0.9).
"""
import math
from dataclasses import dataclass, field, replace

TORSO = 0.30
HEAD_DIST = 0.085
HEAD_R = 0.055
UPPER_ARM = 0.15
FOREARM = 0.14
THIGH = 0.23
SHANK = 0.23
FOOT = 0.07
SHOULDER_HALF = 0.09   # вид спереди
HIP_HALF = 0.05        # вид спереди
LIMB_W = 0.044         # толщина конечности
TORSO_W = 0.085


def rad(a):
    return math.radians(a)


def limb_dir(a):
    return (math.sin(rad(a)), math.cos(rad(a)))


def torso_dir(a):
    return (math.sin(rad(a)), -math.cos(rad(a)))


@dataclass(frozen=True)
class Pose:
    torso: float = 0
    head: float = 0
    spine: float = 0
    an1: float = 0
    an2: float = 0
    af1: float = 0
    af2: float = 0
    ln1: float = 0
    ln2: float = 0
    lf1: float = 0
    lf2: float = 0
    fn: float = 90
    ff: float = 90
    air: float = 0
    x: float = 0

    FIELDS = ("torso", "head", "spine", "an1", "an2", "af1", "af2", "ln1", "ln2",
              "lf1", "lf2", "fn", "ff", "air", "x")

    def values(self):
        return [getattr(self, f) for f in Pose.FIELDS]

    def set(self, **kw):
        return replace(self, **kw)


def lerp_pose(a, b, t):
    return Pose(**{f: getattr(a, f) + (getattr(b, f) - getattr(a, f)) * t for f in Pose.FIELDS})


def smooth(t):
    return t * t * (3 - 2 * t)


# ---- IK-помощники (только для авторинга; в Swift уходят готовые углы) ----

def ik2(l1, l2, tx, ty, bend=1):
    """Абсолютные углы двух звеньев, чтобы конец достал до (tx, ty). bend=+1 — сустав вперёд (+x для вниз смотрящей конечности)."""
    d = math.hypot(tx, ty)
    d = min(max(d, abs(l1 - l2) + 1e-6), l1 + l2 - 1e-6)
    base = math.degrees(math.atan2(tx, ty))
    cos_a = (l1 * l1 + d * d - l2 * l2) / (2 * l1 * d)
    alpha = math.degrees(math.acos(max(-1, min(1, cos_a))))
    a1 = base + bend * alpha
    kx, ky = l1 * math.sin(rad(a1)), l1 * math.cos(rad(a1))
    # если цель была недостижима, тянемся к ней по прямой
    a2 = math.degrees(math.atan2(tx * d / math.hypot(tx, ty) - kx, ty * d / math.hypot(tx, ty) - ky))
    return a1, a2


def leg(dx, h, bend=1):
    """Углы ноги: лодыжка в (dx, h) относительно таза."""
    return ik2(THIGH, SHANK, dx, h, bend)


def arm(tx, ty, bend=-1):
    """Углы руки: кисть в (tx, ty) относительно плеча."""
    return ik2(UPPER_ARM, FOREARM, tx, ty, bend)


# ---- Скелет ----

@dataclass
class Skeleton:
    hip: tuple
    mid: tuple
    neck: tuple
    head: tuple
    # (плечо, локоть, кисть) / (таз, колено, лодыжка, носок)
    arm_n: tuple
    arm_f: tuple
    leg_n: tuple
    leg_f: tuple

    def points(self):
        pts = [self.hip, self.mid, self.neck, (self.head[0], self.head[1] + HEAD_R), (self.head[0], self.head[1] - HEAD_R)]
        for chain in (self.arm_n, self.arm_f, self.leg_n, self.leg_f):
            pts.extend(chain)
        return pts


def add(p, q, k=1.0):
    return (p[0] + q[0] * k, p[1] + q[1] * k)


def build_skeleton(p, camera):
    hip = (0.0, 0.0)
    mid = add(hip, torso_dir(p.torso - p.spine / 2), TORSO / 2)
    neck = add(mid, torso_dir(p.torso + p.spine / 2), TORSO / 2)
    hd = torso_dir(p.torso + p.head)
    head = add(neck, hd, HEAD_DIST)

    if camera == "front":
        perp = (math.cos(rad(p.torso)), math.sin(rad(p.torso)))
        sh_n, sh_f = add(neck, perp, SHOULDER_HALF), add(neck, perp, -SHOULDER_HALF)
        hp_n, hp_f = add(hip, perp, HIP_HALF), add(hip, perp, -HIP_HALF)
    else:
        sh_n = sh_f = neck
        hp_n = hp_f = hip

    def arm_chain(sh, a1, a2):
        elbow = add(sh, limb_dir(a1), UPPER_ARM)
        hand = add(elbow, limb_dir(a2), FOREARM)
        return (sh, elbow, hand)

    def leg_chain(hp, a1, a2, foot_angle):
        knee = add(hp, limb_dir(a1), THIGH)
        ankle = add(knee, limb_dir(a2), SHANK)
        toe = add(ankle, limb_dir(foot_angle), FOOT) if camera == "side" else ankle
        return (hp, knee, ankle, toe)

    return Skeleton(
        hip, mid, neck, head,
        arm_chain(sh_n, p.an1, p.an2), arm_chain(sh_f, p.af1, p.af2),
        leg_chain(hp_n, p.ln1, p.ln2, p.fn), leg_chain(hp_f, p.lf1, p.lf2, p.ff),
    )


def place(p, camera, anchor):
    """Скелет в мировых координатах: пол y=0, вверх — отрицательные y, якорь по x в 0 (+ p.x)."""
    s = build_skeleton(p, camera)
    pts = s.points()
    limb_low = max(y for _, y in pts) + LIMB_W / 2
    torso_low = max(s.hip[1], s.mid[1], s.neck[1]) + TORSO_W / 2
    low = max(limb_low, torso_low)
    if anchor == "footN":
        ax = s.leg_n[3][0]
    elif anchor == "footF":
        ax = s.leg_f[3][0]
    elif anchor == "handN":
        ax = s.arm_n[2][0]
    else:
        ax = 0.0
    dx = -ax + p.x
    dy = -low - p.air

    def mv(pt):
        return (pt[0] + dx, pt[1] + dy)

    def mvc(chain):
        return tuple(mv(q) for q in chain)

    return Skeleton(mv(s.hip), mv(s.mid), mv(s.neck), mv(s.head), mvc(s.arm_n), mvc(s.arm_f), mvc(s.leg_n), mvc(s.leg_f))


# ---- Анимации ----

@dataclass
class Key:
    pose: Pose
    seconds: float
    caption: str = ""


@dataclass
class Motion:
    id: str
    camera: str          # "side" | "front"
    anchor: str          # "none" | "footN" | "footF" | "handN"
    keys: list = field(default_factory=list)

    def period(self):
        return sum(k.seconds for k in self.keys)

    def pose_at(self, t):
        period = self.period()
        t = t % period
        for i, k in enumerate(self.keys):
            if t < k.seconds or i == len(self.keys) - 1:
                nxt = self.keys[(i + 1) % len(self.keys)]
                u = min(1.0, max(0.0, t / k.seconds))
                return lerp_pose(k.pose, nxt.pose, smooth(u)), i
            t -= k.seconds
        return self.keys[0].pose, 0

    def bounds(self, samples=120):
        xs, ys = [], []
        for i in range(samples):
            p, _ = self.pose_at(self.period() * i / samples)
            s = place(p, self.camera, self.anchor)
            for x, y in s.points():
                xs.append(x)
                ys.append(y)
        pad = LIMB_W
        return (min(xs) - pad, max(xs) + pad, min(ys) - pad, LIMB_W / 2)


# ---- Авторские помощники поверх place() ----

def floor_arms(p, camera="side", anchor="footN", hand_dx=0.0, bend=-1, far=True):
    """Руки достают до пола: кисти на y=пол, по x смещены от плеча на hand_dx."""
    # плечо измеряем с руками вверх, чтобы висящие руки не влияли на высоту пола
    s = place(p.set(an1=180, an2=180, af1=180, af2=180), camera, anchor)
    sh = s.arm_n[0]
    ty = -LIMB_W / 2 - sh[1]
    a1, a2 = arm(hand_dx, ty, bend)
    q = p.set(an1=a1, an2=a2)
    if far:
        q = q.set(af1=a1, af2=a2)
    return q


def x_for(p, camera, point_name, world_x):
    """Сдвиг pose.x так, чтобы указанная точка оказалась в мировом x (якорь none)."""
    s = place(p.set(x=0), camera, "none")
    attr, idx = {"handN": ("arm_n", 2), "footN": ("leg_n", 3), "footF": ("leg_f", 3),
                 "ankleN": ("leg_n", 2), "hip": ("hip", None)}[point_name]
    pt = getattr(s, attr) if idx is None else getattr(s, attr)[idx]
    return p.set(x=world_x - pt[0])
