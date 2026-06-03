#!/usr/bin/env python3
"""
JK-BMS Bluetooth test reader for Smart JK-BMS Node-RED add-on.

But: this first file is a bridge/scaffold. It validates BLE visibility and gives
Node-RED a stable JSON contract. The actual JK frame decoder can then be added
without touching the RS485 flow.

Install dependencies in the add-on image:
  pip3 install bleak

Usage:
  python3 /config/jkbms_ble_reader.py --scan
  python3 /config/jkbms_ble_reader.py --once --bms 1 --mac C8:47:8C:XX:XX:XX
"""
import argparse
import asyncio
import json
import sys
from datetime import datetime, timezone

try:
    from bleak import BleakScanner, BleakClient
except Exception as exc:
    print(json.dumps({"ok": False, "error": "missing_bleak", "detail": str(exc)}))
    sys.exit(2)

JK_NAMES = ("JK", "JKBMS", "JK-BMS", "JK_", "BMS")


def now_iso():
    return datetime.now(timezone.utc).isoformat()


async def scan(timeout: float):
    devices = await BleakScanner.discover(timeout=timeout)
    out = []
    for d in devices:
        name = d.name or ""
        if any(k.lower() in name.lower() for k in JK_NAMES):
            out.append({"address": d.address, "name": name, "rssi": getattr(d, "rssi", None)})
    print(json.dumps({"ok": True, "mode": "scan", "timestamp": now_iso(), "devices": out}, ensure_ascii=False))


async def read_once(mac: str, bms: int, timeout: float):
    # Première étape: valider que l'add-on arrive à se connecter au BMS.
    # Étape suivante: ajouter ici les UUID JK et le décodage complet des trames BLE.
    result = {
        "ok": False,
        "mode": "read_once",
        "timestamp": now_iso(),
        "bms_id": bms,
        "address": mac,
        "connected": False,
        "data": {},
        "alarms": {},
        "warning": "bridge_only_no_jk_decoder_yet"
    }
    try:
        async with BleakClient(mac, timeout=timeout) as client:
            result["connected"] = bool(client.is_connected)
            result["ok"] = bool(client.is_connected)
            # On liste les services pour confirmer que la couche BLE fonctionne.
            services = await client.get_services()
            result["services"] = [str(s.uuid) for s in services]
    except Exception as exc:
        result["error"] = type(exc).__name__
        result["detail"] = str(exc)
    print(json.dumps(result, ensure_ascii=False))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--scan", action="store_true")
    parser.add_argument("--once", action="store_true")
    parser.add_argument("--mac", default="")
    parser.add_argument("--bms", type=int, default=1)
    parser.add_argument("--timeout", type=float, default=10.0)
    args = parser.parse_args()

    if args.scan:
        asyncio.run(scan(args.timeout))
        return
    if args.once and args.mac:
        asyncio.run(read_once(args.mac, args.bms, args.timeout))
        return
    print(json.dumps({"ok": False, "error": "bad_arguments"}))
    sys.exit(1)


if __name__ == "__main__":
    main()
