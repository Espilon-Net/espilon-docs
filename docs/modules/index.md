# Modules Overview

Espilon uses a modular architecture where functionality is organized into modules.

## Available Modules

### System Module (Built-in)

Always included, provides:
- Device information
- System stats
- File operations
- Reboot/sleep

### Network Module

Enable in menuconfig: `CONFIG_MODULE_NETWORK=y`

Features:
- ping
- arp_scan
- port_scan
- Basic network operations

### Recon Module

Enable in menuconfig: `CONFIG_MODULE_RECON=y`

Features:
- WiFi monitoring
- BLE tracking (with `CONFIG_RECON_MODE_BLE_TRILAT`)
- Camera capture (with `CONFIG_RECON_MODE_CAMERA`)

### FakeAP Module

Enable in menuconfig: `CONFIG_MODULE_FAKEAP=y`

Features:
- Rogue access points
- Captive portals
- WiFi deauth

## Selecting Modules

Configure via `idf.py menuconfig`:

```
Espilon Bot Configuration → Modules
├─ [X] Network Commands
├─ [ ] Recon Commands
└─ [ ] Fake Access Point Commands
```

---

**Previous**: [C2 Server](../tools/c2-server.md) | **Next**: [Commands](commands.md)
