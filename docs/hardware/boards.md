# Supported Boards

Espilon is compatible with most ESP32 development boards. This page lists tested and recommended boards.

## Officially Tested

### LilyGO T-Call v1.4

**Status**: ✅ Fully Supported (Official GPRS Board)

- **Chip**: ESP32
- **Flash**: 4MB or 8MB
- **PSRAM**: 8MB
- **Modem**: SIM800 (2G GPRS)
- **USB**: CH9102 (Type-C)
- **Power**: IP5306 with battery support
- **Price**: ~$18 USD

**Modes**: WiFi, GPRS

[Full Setup Guide](lilygo-tcall.md)

---

### ESP32-DevKitC V4

**Status**: ✅ Fully Supported

- **Chip**: ESP32-WROOM-32
- **Flash**: 4MB
- **PSRAM**: None
- **USB**: CP2102 (Micro-USB or Type-C)
- **Power**: USB only (5V)
- **Price**: ~$5-8 USD

**Modes**: WiFi only

**GPIO**: 30 pins exposed

---

### ESP32-WROVER-KIT

**Status**: ✅ Fully Supported

- **Chip**: ESP32-WROVER-B
- **Flash**: 4MB
- **PSRAM**: 8MB
- **USB**: FTDI (Micro-USB)
- **Power**: USB + LiPo connector
- **Extras**: JTAG debugger, camera connector
- **Price**: ~$15 USD

**Modes**: WiFi only

**GPIO**: 34 pins exposed

---

### ESP32-CAM

**Status**: ⚠️ Supported (Camera Feature Experimental)

- **Chip**: ESP32-S
- **Flash**: 4MB
- **PSRAM**: 4MB
- **Camera**: OV2640 2MP
- **USB**: None (requires FTDI adapter)
- **Power**: 5V external or battery
- **Price**: ~$8-10 USD

**Modes**: WiFi only

**Note**: Limited GPIOs due to camera usage

---

## Community Tested

These boards are reported working by community members but not officially tested:

### ESP32-S2

**Status**: ⚠️ Community Tested

- Single-core ESP32-S2
- USB-OTG native support
- WiFi only (no Bluetooth)

**Note**: Requires ESP-IDF configuration changes

---

### ESP32-C3

**Status**: ⚠️ Community Tested

- RISC-V core
- WiFi + Bluetooth 5 (LE)
- Lower power consumption

**Note**: Requires ESP-IDF v4.4+

---

### ESP32-S3

**Status**: ⚠️ Community Tested

- Dual-core LX7
- WiFi + Bluetooth 5 (LE)
- Better AI/ML support

**Note**: Newer chip, limited testing

---

## Not Recommended

### ESP8266

**Status**: ❌ Not Supported

- Older chip (pre-ESP32)
- Limited RAM and Flash
- ESP-IDF not compatible

**Alternative**: Use ESP32-based boards

---

### Arduino Nano ESP32

**Status**: ⚠️ Partial Support

- ESP32-S3 based
- Arduino ecosystem
- May require custom configuration

---

## Board Selection Guide

### For WiFi Mode

**Budget**: ESP32-DevKitC (~$5)
- Simple, cheap, widely available
- Perfect for labs and development

**Advanced**: ESP32-WROVER-KIT (~$15)
- Extra PSRAM for camera or buffers
- JTAG debugger included
- Battery connector

### For GPRS Mode

**Only Option**: LilyGO T-Call (~$18)
- Integrated SIM800 modem
- No external wiring
- Battery support included

### For Camera Features

**Best Choice**: ESP32-CAM (~$8)
- Built-in 2MP camera
- 4MB PSRAM
- Very affordable

**Alternative**: ESP32-WROVER + OV2640 module
- More GPIOs available
- Better flexibility

## Pinout Considerations

### Reserved Pins (All Boards)

These pins are typically reserved and should not be used:

| GPIOs | Function | Notes |
|-------|----------|-------|
| 6-11 | Flash SPI | Do not use |
| 1, 3 | UART0 (USB) | Serial console |
| 0 | Boot Mode | Pull-up required |
| 2 | LED | Often has LED |

### LilyGO T-Call Reserved Pins

| GPIOs | Function | Notes |
|-------|----------|-------|
| 26, 27 | SIM800 UART | Do not change |
| 4 | SIM800 Power Key | Required |
| 23 | SIM800 Power Enable | Required |
| 5 | SIM800 Reset | Required |
| 13 | Status LED | Optional |

### Available for Custom Use

Most boards have these GPIOs available:

```
12, 14, 15, 16, 17, 18, 19, 21, 22, 25, 32, 33, 34, 35, 36, 39
```

Input-only: 34, 35, 36, 39

## USB-to-UART Chips

Different boards use different USB chips:

| Chip | Compatibility | Driver |
|------|---------------|--------|
| **CP2102** | Excellent | Usually built-in |
| **CH340** | Good | May need driver |
| **CH9102** | Excellent | Usually built-in |
| **FTDI** | Excellent | Built-in (expensive) |

### Driver Installation

=== "Linux"
    Usually no driver needed. If required:
    ```bash
    sudo apt-get install ch341-ser
    ```

=== "macOS"
    Download from manufacturer or use:
    ```bash
    brew install ch340g-ch34g-ch34x-mac-os-x-driver
    ```

=== "Windows"
    Download from:
    - CP2102: [Silicon Labs](https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers)
    - CH340: [WCH](http://www.wch-ic.com/downloads/CH341SER_EXE.html)

## Purchase Recommendations

### Trusted Vendors

**Official**:
- [Espressif Store](https://www.espressif.com/en/products/devkits)
- [LilyGO Official](https://lilygo.cc/)

**Authorized Distributors**:
- Mouser Electronics
- DigiKey
- Newark

**Community Favorites**:
- AliExpress (official stores)
- Amazon (verified sellers)
- Adafruit (US)
- Pimoroni (UK)

### What to Look For

✅ **Good Signs**:
- Detailed specifications
- High-resolution photos
- Many positive reviews
- Official store badges
- Reasonable prices ($5-20)

❌ **Red Flags**:
- Too cheap (<$3 for ESP32)
- No specifications
- Poor/fake reviews
- Unknown sellers
- Suspiciously high specs

## Troubleshooting Board Issues

### Board Not Detected

1. Check USB cable (must be data cable, not charge-only)
2. Install USB-to-UART drivers
3. Try different USB port
4. Check for physical damage

### Flashing Fails

1. Hold BOOT button while connecting
2. Check baud rate (460800 or 115200)
3. Try different USB cable
4. Verify ESP-IDF version (v5.3.2)

### Won't Boot After Flash

1. Press RESET button
2. Check power supply (5V, 1A minimum)
3. Verify firmware built correctly
4. Check for GPIO conflicts

## Contributing

Tested a board not listed here? [Submit a report](https://github.com/yourusername/epsilon/issues) with:

- Board name and vendor
- Flash/PSRAM specs
- USB chip model
- Test results (WiFi/GPRS)
- Photos (optional)

---

**Previous**: [Hardware Overview](index.md) | **Next**: [LilyGO T-Call](lilygo-tcall.md)
