# Multi-Device Flasher

Automated tool for building and flashing multiple ESP32 devices with custom configurations.

## Overview

The flasher tool (`tools/flasher/flash.py`) automates the process of:

1. Generating custom `sdkconfig.defaults` per device
2. Building firmware with ESP-IDF
3. Flashing ESP32 boards via USB
4. Managing multiple devices from a single config file

## Quick Start

```bash
cd tools/flasher

# Edit devices.json with your configurations
nano devices.json

# Flash all devices
python3 flash.py --config devices.json
```

## Configuration File

`devices.json` structure:

```json
{
  "project": "/home/user/epsilon/espilon_bot",
  "devices": [
    {
      "device_id": "ce4f626b",
      "port": "/dev/ttyUSB0",
      "srv_ip": "192.168.1.13",
      "srv_port": 2626,
      "network_mode": "wifi",
      "wifi_ssid": "MyWiFi",
      "wifi_pass": "MyPassword"
    }
  ]
}
```

## Usage Examples

### Flash All Devices

```bash
python3 flash.py --config devices.json
```

### Build Only (No Flash)

```bash
python3 flash.py --config devices.json --build-only
```

### Flash Only (Pre-built)

```bash
python3 flash.py --config devices.json --flash-only
```

### Manual Single Device

```bash
python3 flash.py --manual \
  --project /home/user/epsilon/espilon_bot \
  --device-id abc12345 \
  --port /dev/ttyUSB0 \
  --srv-ip 192.168.1.100 \
  --wifi-ssid MyWiFi \
  --wifi-pass MyPassword
```

## Configuration Options

| Field | Required | Description |
|-------|----------|-------------|
| `device_id` | Yes | Unique 8-char hex ID |
| `port` | Yes | Serial port |
| `srv_ip` | Yes | C2 server IP |
| `network_mode` | No | "wifi" or "gprs" |
| `wifi_ssid` | WiFi mode | WiFi SSID |
| `wifi_pass` | WiFi mode | WiFi password |
| `gprs_apn` | GPRS mode | APN (default: sl2sfr) |
| `module_network` | No | Enable network module |
| `module_recon` | No | Enable recon module |
| `module_fakeap` | No | Enable fake AP module |

See [tools/flasher/README.md](../../tools/flasher/README.md) for complete documentation.

---

**Previous**: [Configuration](../configuration/network.md) | **Next**: [C2 Server](c2-server.md)
