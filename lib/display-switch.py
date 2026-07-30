#!/usr/bin/env python3
"""Switch the Mutter monitor layout to a single output, and restore it.

Usage:
    display-switch.py activate [--defaults FILE] <output> [width] [height] [refresh]
    display-switch.py restore  [--defaults FILE]

`activate` snapshots the current logical-monitor layout to a file under
$XDG_RUNTIME_DIR, then enables only <output> at the requested mode (turning every
other monitor off). `restore` re-applies that snapshot (and deletes it); with no
snapshot it falls back to re-enabling every monitor side by side.

All changes use ApplyMonitorsConfig method 1 (temporary): applied in-memory, never
written to ~/.config/monitors.xml, and not self-reverted for a direct D-Bus call.
"""

import argparse
import json
import os
import sys

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib  # noqa: E402

BUS_NAME = "org.gnome.Mutter.DisplayConfig"
OBJECT_PATH = "/org/gnome/Mutter/DisplayConfig"
METHOD_TEMPORARY = 1


def snapshot_path():
    runtime = os.environ.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}"
    return os.path.join(runtime, "mx-virtual-display-restore.json")


def proxy():
    return Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SESSION,
        Gio.DBusProxyFlags.NONE,
        None,
        BUS_NAME,
        OBJECT_PATH,
        BUS_NAME,
        None,
    )


def get_state(p):
    result = p.call_sync("GetCurrentState", None, Gio.DBusCallFlags.NONE, -1, None)
    return result.unpack()


def parse_state(state):
    """-> (serial, logical_monitors, current_mode, preferred_mode, modes_by_conn)."""
    serial, monitors, logical_monitors, _props = state
    current_mode = {}  # connector -> mode_id
    preferred_mode = {}  # connector -> mode_id
    modes_by_conn = {}  # connector -> [(mode_id, w, h, refresh)]
    for mon in monitors:
        connector = mon[0][0]
        modes_by_conn.setdefault(connector, [])
        for mode in mon[1]:
            mode_id, w, h, refresh, _pscale, _scales, mprops = mode
            modes_by_conn[connector].append((mode_id, w, h, refresh))
            if mprops.get("is-current"):
                current_mode[connector] = mode_id
            if mprops.get("is-preferred"):
                preferred_mode[connector] = mode_id
    return serial, logical_monitors, current_mode, preferred_mode, modes_by_conn


def build_params(serial, method, entries):
    """entries: [(x, y, scale, transform, primary, [(connector, mode_id), ...]), ...]."""
    logical_monitors = [
        (
            int(x),
            int(y),
            float(scale),
            int(transform),
            bool(primary),
            [(str(connector), str(mode_id), {}) for connector, mode_id in mons],
        )
        for (x, y, scale, transform, primary, mons) in entries
    ]
    return GLib.Variant(
        "(uua(iiduba(ssa{sv}))a{sv})",
        (int(serial), int(method), logical_monitors, {}),
    )


def apply_config(p, serial, method, entries):
    p.call_sync(
        "ApplyMonitorsConfig",
        build_params(serial, method, entries),
        Gio.DBusCallFlags.NONE,
        -1,
        None,
    )


def snapshot_entries(logical_monitors, current_mode):
    entries = []
    for lm in logical_monitors:
        x, y, scale, transform, primary, mons, _props = lm
        conn_modes = [(m[0], current_mode[m[0]]) for m in mons if m[0] in current_mode]
        if conn_modes:
            entries.append([x, y, scale, transform, primary, conn_modes])
    return entries


def load_defaults(path):
    if not path or not os.path.exists(path):
        return {}
    with open(path) as f:
        return {d["output"]: d for d in json.load(f)}


def env_num(name, cast):
    v = os.environ.get(name)
    if not v:
        return None
    try:
        return cast(v)
    except ValueError:
        return None


def pick_mode(modes, width, height, refresh):
    matching = [m for m in modes if m[1] == width and m[2] == height]
    if not matching:
        return None
    if refresh is None:
        return matching[0][0]
    return min(matching, key=lambda m: abs(m[3] - refresh))[0]


def cmd_activate(args):
    defaults = load_defaults(args.defaults).get(args.output, {})

    width = (
        args.width
        if args.width is not None
        else env_num("SUNSHINE_CLIENT_WIDTH", int) or defaults.get("width")
    )
    height = (
        args.height
        if args.height is not None
        else env_num("SUNSHINE_CLIENT_HEIGHT", int) or defaults.get("height")
    )
    refresh = (
        args.refresh
        if args.refresh is not None
        else env_num("SUNSHINE_CLIENT_FPS", float) or defaults.get("refresh")
    )

    if width is None or height is None:
        sys.exit(
            f"error: no resolution given for '{args.output}' and none configured as default"
        )

    p = proxy()
    serial, logical_monitors, current_mode, _pref, modes_by_conn = parse_state(
        get_state(p)
    )

    if args.output not in modes_by_conn:
        outputs = ", ".join(sorted(modes_by_conn)) or "(none connected)"
        sys.exit(f"error: output '{args.output}' not found. Available: {outputs}")

    mode_id = pick_mode(modes_by_conn[args.output], width, height, refresh)
    if mode_id is None:
        print(
            f"error: no {width}x{height} mode for '{args.output}'. Available modes:",
            file=sys.stderr,
        )
        for mid, w, h, r in modes_by_conn[args.output]:
            print(f"  {w}x{h}@{r:.3f}  ({mid})", file=sys.stderr)
        sys.exit(1)

    with open(snapshot_path(), "w") as f:
        json.dump(snapshot_entries(logical_monitors, current_mode), f)

    apply_config(
        p, serial, METHOD_TEMPORARY, [[0, 0, 1.0, 0, True, [(args.output, mode_id)]]]
    )
    print(f"activated {args.output} at {width}x{height} ({mode_id})")


def cmd_restore(args):
    path = snapshot_path()
    p = proxy()

    if os.path.exists(path):
        with open(path) as f:
            entries = json.load(f)
        serial = parse_state(get_state(p))[0]
        apply_config(p, serial, METHOD_TEMPORARY, entries)
        os.remove(path)
        print("restored saved layout")
        return

    serial, _lm, current_mode, preferred_mode, modes_by_conn = parse_state(get_state(p))
    entries = []
    x = 0
    for i, connector in enumerate(modes_by_conn):
        mode_id = preferred_mode.get(connector) or current_mode.get(connector)
        if mode_id is None:
            if not modes_by_conn[connector]:
                continue
            mode_id = modes_by_conn[connector][0][0]
        width = next((m[1] for m in modes_by_conn[connector] if m[0] == mode_id), 0)
        entries.append([x, 0, 1.0, 0, i == 0, [(connector, mode_id)]])
        x += width
    if not entries:
        sys.exit("error: no monitors available to restore")
    apply_config(p, serial, METHOD_TEMPORARY, entries)
    print("no snapshot found; re-enabled all connected monitors")


def main():
    parser = argparse.ArgumentParser(prog="display-switch")
    sub = parser.add_subparsers(dest="cmd", required=True)

    a = sub.add_parser("activate", help="enable only <output>, disable the rest")
    a.add_argument("--defaults", help="JSON file of per-output default modes")
    a.add_argument("output")
    a.add_argument("width", nargs="?", type=int)
    a.add_argument("height", nargs="?", type=int)
    a.add_argument("refresh", nargs="?", type=float)
    a.set_defaults(func=cmd_activate)

    r = sub.add_parser("restore", help="restore the layout saved by activate")
    r.add_argument("--defaults", help=argparse.SUPPRESS)  # accepted, ignored
    r.set_defaults(func=cmd_restore)

    args = parser.parse_args()
    try:
        args.func(args)
    except GLib.Error as e:
        sys.exit(f"D-Bus error: {e.message}")


if __name__ == "__main__":
    main()
