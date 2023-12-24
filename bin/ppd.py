#!/usr/bin/env python3
# Pixels per degree calculator
#
import re
import math
import argparse
from typing import *


def diag_to_dims(diag: float, aspect_w: int, aspect_h: int) -> Tuple[float, float]:
    aspect_sq_sum = aspect_w**2 + aspect_h**2
    x = math.sqrt(diag**2 / aspect_sq_sum)

    return aspect_w * x, aspect_h * x


def inch2cm(inch: float) -> float:
    return inch * 2.54


def deg2rad(deg: float) -> float:
    return deg * math.pi / 180


def rad2deg(rad: float) -> float:
    return rad * 180 / math.pi


def ppd_min(info: dict) -> float:
    """
    Computes the ppd exactly 1deg off from the center

    This results in a lower bound on the PPD. All distance measures are in cm
    """
    lw, lh = diag_to_dims(info.diag, info.asc_w, info.asc_h)

    screen_dist = math.tan(deg2rad(1)) * info.eye_dist
    print(screen_dist)

    return screen_dist * info.res_w / lw


def ppd_avg(info: dict) -> float:
    """
    Computes the ppd using the entire width of the screen

    This results in an average of the PPD. All distance measures are in cm
    """
    lw, lh = diag_to_dims(info.diag, info.asc_w, info.asc_h)

    angle = 2 * rad2deg(math.atan((lw/2) / info.eye_dist))

    print(f"FOV: {angle}")

    return info.res_w / angle


def ppd_max(info: dict) -> float:
    lw, _ = diag_to_dims(info.diag, info.asc_w, info.asc_h)

    h = math.sqrt((lw/2)**2 + info.eye_dist**2)

    a = h - info.eye_dist
    o = info.eye_dist * math.tan(deg2rad(1))
    print(h)

    h_s = math.sqrt(a**2 + o**2) * (info.res_w / lw)

    return h_s

    h = math.sqrt(info.eye_dist**2 + (lw/2)**2)
    #print(h)
    #print(info.eye_dist)
    interior_adj = h - info.eye_dist
    interior_opp = info.eye_dist * math.tan(deg2rad(1))
    print(interior_adj)
    print(interior_opp)

    print(lw)
    return math.sqrt(interior_adj**2 + interior_opp**2) * info.res_w / lw

    interior_obtuse = 90.0 - rad2deg(math.atan((lw/2) / info.eye_dist))
    #interior_obtuse = 180.0 - 1.0 - interior_acute

    interior_angle = deg2rad(89.0 + rad2deg(math.atan((lw/2) / info.eye_dist)))
    interior_adj = h - info.eye_dist

    screen_length = interior_adj / math.cos(interior_angle)

    return screen_length * info.res_w


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="PPD calculator v1.0.0",
        description="Calculate the pixels per degree on a flat screen"
    );

    parser.add_argument(
        "diag", type=float,
        help="Diagonal meansure of screen in inches"
    );

    parser.add_argument(
        "res_w", type=int,
        help="Horizontal resolution of screen"
    );

    parser.add_argument(
        "res_h", type=int,
        help="Vertical resolution of screen"
    );

    parser.add_argument(
        "asc_w", type=int,
        help="Horizontal aspect ratio"
    );

    parser.add_argument(
        "asc_h", type=int,
        help="Vertical aspect ratio"
    );

    parser.add_argument(
        "eye_dist", type=int,
        help="Distance of your eyes from the screen in centimeters"
    );

    args = parser.parse_args();
    args.diag = inch2cm(args.diag)

    print(f"Pixels per degree (min): {ppd_min(args)}")
    print(f"Pixels per degree (avg): {ppd_avg(args)}")
    print(f"Pixels per degree (max): {ppd_max(args)}")
