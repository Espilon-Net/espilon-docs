# Menuconfig Guide

ESP-IDF's `menuconfig` is the primary tool for configuring Espilon firmware before building.

## Launching Menuconfig

```bash
cd espilon_bot
. ~/esp/esp-idf/export.sh  # or: get_idf
idf.py menuconfig
```

This opens an ncurses-based configuration menu.

## Navigation

- **Arrow Keys**: Move up/down
- **Enter**: Select submenu or toggle option
- **Space**: Toggle checkbox options
- **Y**: Enable option
- **N**: Disable option
- **/**: Search for option
- **?**: Help for selected option
- **S**: Save configuration
- **Q**: Quit (prompts to save)

## Espilon Configuration

Navigate to: `Espilon Bot Configuration`

### Device Settings

```
├─ Device ID: "ce4f626b"
```

**Purpose**: Unique identifier for this device
**Format**: 8 hexadecimal characters
**Example**: `"a1b2c3d4"`

!!! tip "Generate Random ID"
    ```bash
    openssl rand -hex 4
    ```

### Network Mode

```
├─ Network
│   ├─ Connection Mode
│   │   ├─ ( ) WiFi
│   │   └─ ( ) GPRS
```

**WiFi Mode** (default):
- For ESP32-DevKit and most boards
- Requires WiFi SSID and password
- 802.11 b/g/n support

**GPRS Mode**:
- For LilyGO T-Call only
- Requires SIM card and APN
- 2G cellular connectivity

### WiFi Settings

```
│   ├─ WiFi Settings (depends on WiFi mode)
│   │   ├─ WiFi SSID: "YourNetwork"
│   │   └─ WiFi Password: "YourPassword"
```

**SSID**: Name of WiFi network
**Password**: WPA/WPA2 password (leave empty for open networks)

### GPRS Settings

```
│   ├─ GPRS Settings (depends on GPRS mode)
│   │   └─ APN: "sl2sfr"
```

**APN**: Access Point Name from your carrier

Common APNs:
- SFR (France): `sl2sfr`
- Orange (France): `orange.fr`
- AT&T (USA): `phone`
- T-Mobile (USA): `fast.t-mobile.com`

### Server Configuration

```
├─ Server
│   ├─ Server IP: "192.168.1.100"
│   └─ Server Port: 2626
```

**Server IP**: IP address of your C2 server
**Server Port**: TCP port (default 2626)

!!! warning "Public IP for GPRS"
    GPRS mode requires a public IP or VPN. Local IPs (192.168.x.x) won't work.

### Module Selection

```
├─ Modules
│   ├─ [X] Network Commands
│   ├─ [ ] Recon Commands
│   └─ [ ] Fake Access Point Commands
```

**Network Module** (recommended):
- ping, arp_scan, port_scan
- Basic network operations
- ~40KB flash

**Recon Module** (advanced):
- WiFi monitoring
- BLE tracking
- Requires extra flash/RAM

**FakeAP Module** (advanced):
- Rogue access points
- Captive portals
- Requires WiFi mode

### Recon Module Settings

```
├─ Recon Settings (depends on Recon Module)
│   ├─ [ ] Enable Camera Reconnaissance
│   └─ [ ] Enable BLE Trilateration Reconnaissance
```

**Camera**: Requires ESP32-CAM board
**BLE**: Bluetooth Low Energy tracking

### Security Settings

```
├─ Security
│   ├─ ChaCha20 Key (32 bytes): "testde32chars..."
│   └─ ChaCha20 Nonce (12 bytes): "noncenonceno"
```

!!! danger "Change Default Keys"
    Default keys are for testing only. Generate new keys for production:
    ```bash
    # 32-byte key
    openssl rand -hex 32

    # 12-byte nonce
    openssl rand -hex 12
    ```

## Important ESP-IDF Settings

### Flash Size

Navigate to: `Serial flasher config → Flash size`

Set according to your board:
- Most boards: **4MB**
- Some boards: **8MB** or **16MB**

### Partition Table

Navigate to: `Partition Table → Partition Table`

Recommended: **Single factory app, no OTA**

For OTA updates: **Factory app, two OTA definitions**

### Log Level

Navigate to: `Component config → Log output → Default log verbosity`

Development: **Info** or **Debug**
Production: **Warning** or **Error**

### WiFi Configuration

Navigate to: `Component config → Wi-Fi`

Recommended settings:
- **WiFi Task Core ID**: Core 0
- **Max Number of Connections**: 4
- **WiFi NVS Flash**: Enabled

### FreeRTOS

Navigate to: `Component config → FreeRTOS`

Default settings work for most cases.

For memory-constrained boards:
- **Tick rate (Hz)**: 100 (default 1000)
- **Minimum task stack size**: 1024 (default 1536)

## Configuration File

Configuration is saved to:
```
espilon_bot/sdkconfig
```

This file is auto-generated from `sdkconfig.defaults`.

### Using sdkconfig.defaults

Create `sdkconfig.defaults` for version control:

```ini
# Device
CONFIG_DEVICE_ID="ce4f626b"

# Network
CONFIG_NETWORK_WIFI=y
CONFIG_WIFI_SSID="MyNetwork"
CONFIG_WIFI_PASS="MyPassword"

# Server
CONFIG_SERVER_IP="192.168.1.100"
CONFIG_SERVER_PORT=2626

# Modules
CONFIG_MODULE_NETWORK=y
CONFIG_MODULE_RECON=n
CONFIG_MODULE_FAKEAP=n

# Security
CONFIG_CRYPTO_KEY="testde32chars00000000000000000000"
CONFIG_CRYPTO_NONCE="noncenonceno"
```

Then:
```bash
rm sdkconfig  # Force regeneration
idf.py -D SDKCONFIG_DEFAULTS=sdkconfig.defaults reconfigure
idf.py build
```

## Common Configurations

### WiFi Development Board

```
Network Mode: WiFi
WiFi SSID: "YourLab"
WiFi Pass: "LabPassword"
Server IP: "192.168.1.100"
Modules: Network only
```

### LilyGO T-Call GPRS

```
Network Mode: GPRS
GPRS APN: "sl2sfr"
Server IP: "203.0.113.10" (public IP)
Modules: Network only
```

### ESP32-CAM Recon

```
Network Mode: WiFi
WiFi SSID: "YourNetwork"
Modules: Network + Recon
Recon Camera: Enabled
```

## Troubleshooting

### Configuration Not Saved

**Problem**: Changes revert after rebuild

**Solution**: Press `S` to save before quitting

### Module Option Missing

**Problem**: Can't find Espilon configuration

**Solution**: Ensure you're in `espilon_bot` directory, not root

### Build Fails After Config Change

**Problem**: Compilation errors after enabling module

**Solution**: Clean and rebuild:
```bash
idf.py fullclean
idf.py build
```

### Default Values Wrong

**Problem**: menuconfig shows old defaults

**Solution**: Delete sdkconfig and regenerate:
```bash
rm sdkconfig
idf.py menuconfig
```

## Next Steps

- [Network Settings Details](network.md) - WiFi and GPRS configuration
- [Module Selection Guide](../modules/index.md) - Choose the right modules
- [Security Best Practices](../security/best-practices.md) - Secure your deployment

---

**Previous**: [Hardware](../hardware/index.md) | **Next**: [Network Configuration](network.md)
