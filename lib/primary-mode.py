#!/usr/bin/env python3
"""Print the current mode ("WxH@R") of the primary monitor, via Mutter.

Uses org.gnome.Mutter.DisplayConfig.GetCurrentState: the logical monitor flagged
primary (falling back to the first one) gives the connector, and that connector's
mode flagged "is-current" gives both the size in physical pixels and the refresh
rate — which is what gamescope -W/-H/-r expects, even with fractional scaling.

Exits 1 without printing anything when no GNOME session / Mutter is reachable.
"""

import sys
from typing import Any

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio

BUS_NAME = "org.gnome.Mutter.DisplayConfig"
OBJECT_PATH = "/org/gnome/Mutter/DisplayConfig"


def get_state() -> tuple[Any, ...]:
    proxy = Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SESSION,
        Gio.DBusProxyFlags.NONE,
        None,
        BUS_NAME,
        OBJECT_PATH,
        BUS_NAME,
        None,
    )
    return proxy.call_sync(
        "GetCurrentState", None, Gio.DBusCallFlags.NONE, -1, None
    ).unpack()


def current_modes(monitors: Any) -> dict[str, tuple[int, int, float]]:
    """connector -> (width, height, refresh) of the mode flagged is-current."""
    modes: dict[str, tuple[int, int, float]] = {}
    for mon in monitors:
        connector = mon[0][0]
        for mode in mon[1]:
            _mode_id, w, h, refresh, _pscale, _scales, mprops = mode
            if mprops.get("is-current"):
                modes[connector] = (w, h, refresh)
    return modes


def primary_connectors(logical_monitors: Any) -> list[str]:
    """Connectors of the primary logical monitor first, then all the others."""
    primary: list[str] = []
    others: list[str] = []
    for lm in logical_monitors:
        _x, _y, _scale, _transform, is_primary, mons, _props = lm
        connectors = [m[0] for m in mons]
        (primary if is_primary else others).extend(connectors)
    return primary + others


def main() -> int:
    try:
        _serial, monitors, logical_monitors, _props = get_state()
    except Exception as exc:
        print(f"mx-primary-mode: {exc}", file=sys.stderr)
        return 1

    modes = current_modes(monitors)
    for connector in primary_connectors(logical_monitors):
        if connector in modes:
            width, height, refresh = modes[connector]
            print(f"{width}x{height}@{refresh:.3f}")
            return 0

    print("mx-primary-mode: no active monitor found", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
