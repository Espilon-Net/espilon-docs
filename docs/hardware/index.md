# Hardware Overview

Espilon supports a wide range of ESP32-based development boards. Choose the right board for your deployment scenario.

## Recommended Boards

### LilyGO T-Call (GPRS Mode)

**Official Espilon board for cellular deployments**

- Integrated SIM800 2G modem
- No external wiring required
- Built-in power management
- Battery support via JST connector

[Full LilyGO T-Call Guide](lilygo-tcall.md)

**Best For**: Remote deployments, mobile operations, areas without WiFi

### ESP32-DevKit (WiFi Mode)

**Budget-friendly option for WiFi deployments**

- Standard ESP32-WROOM-32
- Available from many vendors
- USB-C or Micro-USB variants
- Easy to source worldwide

[Supported Boards List](boards.md)

**Best For**: Labs, buildings with WiFi, development/testing

## Quick Comparison

| Feature | LilyGO T-Call | ESP32-DevKit |
|---------|---------------|--------------|
| **Price** | ~$18 USD | ~$5-8 USD |
| **Network** | WiFi + GPRS (2G) | WiFi only |
| **Range** | Nationwide cellular | 50-100m WiFi |
| **Wiring** | None (integrated) | None (USB) |
| **Battery** | JST connector | External required |
| **Setup** | Moderate | Simple |
| **Best For** | Remote/mobile | Labs/buildings |

## Minimum Requirements

All ESP32 boards for Espilon must have:

- **ESP32 chip** (ESP32-WROOM, ESP32-WROVER, or variant)
- **4MB Flash** minimum (8MB recommended)
- **USB-to-UART** converter (for flashing)
- **WiFi** support (built-in to all ESP32)

## Optional Features

Enhance functionality with:

- **PSRAM**: 4MB+ for camera or large buffers
- **Camera**: ESP32-CAM for reconnaissance
- **External Antenna**: Better WiFi/cellular range
- **Battery Connector**: Portable operation
- **GPIOs**: Exposed pins for custom sensors

## Connectivity Options

### WiFi Mode

Standard 802.11 b/g/n connectivity:

- **Frequency**: 2.4 GHz
- **Range**: 50-100m (indoor), 300m+ (outdoor)
- **Speed**: Up to 150 Mbps
- **Security**: WPA/WPA2/WPA3
- **Cost**: Free (existing infrastructure)

**Required**: ESP32 with WiFi (all models)

### GPRS Mode

2G cellular connectivity via SIM800:

- **Frequency**: 850/900/1800/1900 MHz (quad-band)
- **Range**: Nationwide (cell tower coverage)
- **Speed**: ~50 Kbps (GPRS Class 10)
- **Cost**: SIM card + data plan ($5-15/month)

**Required**: LilyGO T-Call or external SIM800 module

## Power Requirements

### USB-Powered

- **Voltage**: 5V
- **Current**: 500mA - 1A
- **Connector**: USB-C or Micro-USB
- **Best For**: Development, testing, fixed installations

### Battery-Powered

- **Type**: Li-Po 3.7V
- **Capacity**: 1000-2000mAh recommended
- **Runtime**: 5-14 hours (depending on activity)
- **Best For**: Mobile deployments, covert operations

## GPIO Availability

Most ESP32 boards expose 20-30 GPIOs for custom use:

- **Digital I/O**: 34 pins
- **ADC**: 18 channels
- **DAC**: 2 channels
- **PWM**: All pins
- **UART**: 3 ports
- **SPI**: 4 ports
- **I2C**: 2 ports

Reserved pins (varies by board):
- Flash: GPIOs 6-11
- UART0 (USB): GPIOs 1, 3
- Strapping: GPIOs 0, 2, 5, 12, 15

## Antenna Considerations

### Built-in PCB Antenna

Most ESP32 boards include a PCB trace antenna:

- **Range**: Adequate for labs and buildings
- **Cost**: Free (included)
- **Limitation**: Fixed position, limited gain

### External Antenna

For better range and performance:

- **WiFi**: 2.4 GHz antenna with U.FL/IPEX connector
- **GPRS**: GSM quad-band antenna (included with T-Call)
- **Gain**: 2-9 dBi depending on model
- **Range**: 2-5x improvement

!!! tip "Antenna Requirement"
    LilyGO T-Call **requires** external GSM antenna. Never power on without antenna connected.

## Purchasing Guide

### Official Sources

- **Espressif**: [espressif.com](https://www.espressif.com/)
- **LilyGO**: [lilygo.cc](https://lilygo.cc/)

### Distributors

- **Mouser**: Global, reliable shipping
- **DigiKey**: Large stock, fast shipping
- **AliExpress**: Budget option, slower shipping
- **Amazon**: Fast shipping, higher prices

### Verification

Always buy from:
- Official stores
- Authorized distributors
- Verified sellers with reviews

Avoid:
- Suspiciously cheap "clones"
- Unknown sellers
- Boards without documentation

## Next Steps

1. [LilyGO T-Call Setup](lilygo-tcall.md) - For GPRS deployments
2. [Supported Boards](boards.md) - Full compatibility list
3. [Configuration Guide](../configuration/menuconfig.md) - Configure your board

---

**Previous**: [Installation](../getting-started/installation.md) | **Next**: [LilyGO T-Call](lilygo-tcall.md)
