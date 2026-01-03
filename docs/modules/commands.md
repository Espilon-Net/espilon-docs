# Command Reference

List of available commands by module.

## System Commands

| Command | Description |
|---------|-------------|
| `info` | Device information |
| `stats` | System statistics |
| `reboot` | Reboot device |
| `sleep` | Enter deep sleep |

## Network Commands

Requires: `CONFIG_MODULE_NETWORK=y`

| Command | Description |
|---------|-------------|
| `ping <ip>` | Ping host |
| `arp_scan` | Scan local network |
| `port_scan <ip>` | Scan ports |

## Recon Commands

Requires: `CONFIG_MODULE_RECON=y`

| Command | Description |
|---------|-------------|
| `wifi_scan` | Scan WiFi networks |
| `wifi_monitor` | Monitor WiFi traffic |
| `ble_scan` | Scan BLE devices |

## FakeAP Commands

Requires: `CONFIG_MODULE_FAKEAP=y`

| Command | Description |
|---------|-------------|
| `fakeap_start` | Start rogue AP |
| `fakeap_stop` | Stop rogue AP |
| `deauth <mac>` | Deauth client |

---

**Previous**: [Modules](index.md) | **Next**: [Security](../security/index.md)
