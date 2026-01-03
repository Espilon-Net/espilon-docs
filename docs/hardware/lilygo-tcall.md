# LilyGO T-Call

The **LilyGO T-Call** is the officially recommended board for Espilon GPRS mode.

## Overview

LilyGO T-Call integrates the SIM800L GPRS module directly on the PCB, eliminating the need for external wiring and complex power management. This makes it the ideal choice for portable Espilon deployments.

!!! success "Official Espilon GPRS Board"
    The LilyGO T-Call is officially supported and recommended for all GPRS-based Espilon deployments.

## Specifications

| Component | Specification |
|-----------|---------------|
| **MCU** | ESP32 (240MHz dual-core) |
| **Flash** | 4MB or 8MB |
| **PSRAM** | 8MB |
| **Modem** | SIM800 (2G GSM/GPRS) |
| **Power Management** | IP5306 charging IC |
| **Battery** | JST PH 2pin 2.0mm connector |
| **USB** | CH9102 USB-to-UART (Type-C) |
| **SIM** | Nano SIM slot |
| **Antenna** | External GSM antenna (~7cm included) |
| **Price** | ~$15-20 USD |

## Pinout

```
LilyGO T-Call v1.4 Board Layout
┌──────────────────────────────────────────────┐
│  [ESP32]                   [SIM800]         │
│                                              │
│  GPIO 27 ──────────────→ SIM800 RXD         │
│  GPIO 26 ──────────────← SIM800 TXD         │
│  GPIO 4  ──────────────→ SIM800 PWR_KEY     │
│  GPIO 23 ──────────────→ SIM800 PWR_EN      │
│  GPIO 5  ──────────────→ SIM800 RESET       │
│  GPIO 13 ──────────────→ Status LED         │
│                                              │
│  ┌─────────────┐         ┌─────────────┐   │
│  │  Nano SIM   │         │  IP5306 PMU │   │
│  │    Slot     │         │             │   │
│  └─────────────┘         └─────────────┘   │
│                                              │
│  ┌─────────────────────────────────────┐   │
│  │   JST PH 2.0mm Battery Connector    │   │
│  └─────────────────────────────────────┘   │
│                                              │
│  [USB-C] ──────────── [Antenna Connector]  │
└──────────────────────────────────────────────┘
```

### GPIO Mapping

| GPIO | Function | Direction | Description |
|------|----------|-----------|-------------|
| 27 | UART TX | Output | ESP32 → SIM800L RX |
| 26 | UART RX | Input | SIM800L TX → ESP32 |
| 4 | PWR_KEY | Output | Power key control |
| 23 | PWR_EN | Output | Power enable |
| 5 | RESET | Output | Module reset |
| 13 | LED | Output | Status indicator (optional) |

### Available GPIOs

The following GPIOs are available for custom use:

```
Available: 0, 2, 12, 14, 15, 16, 17, 18, 19, 21, 22, 25, 32, 33, 34, 35, 36, 39
Reserved: 1, 3 (UART0), 6-11 (Flash), 26, 27 (UART1/SIM800)
```

## Advantages

### No External Wiring

All connections between ESP32 and SIM800L are on the PCB. No jumper wires or breadboards needed.

### Integrated Power Management

The IP5306 power management IC handles:

- 5V USB input
- 18650 battery charging
- 5V boost conversion
- Power path management
- Automatic source switching

### Portable

The 18650 battery holder allows for completely standalone operation:

- Runtime: 6-12 hours (typical)
- Hot-swappable (with USB power)
- Standard battery format
- Easy to source

### Reliable

Industrial-grade design:

- Professional PCB layout
- Proper impedance matching
- RF shielding
- Stable power delivery

### Cost-Effective

All-in-one solution eliminates:

- External SIM800 module ($8-12)
- Power supply components ($5-10)
- Wiring and connectors ($3-5)

**Total cost**: ~$15-20 vs ~$25-35 DIY solution

## Setup Guide

### 1. Hardware Preparation

#### Insert SIM Card

1. Open the Nano SIM slot
2. Insert Nano SIM card (disable PIN code first)
3. Close the slot securely

!!! warning "Disable PIN Code"
    The SIM800 cannot handle PIN entry. Disable the PIN using a phone before installation.

#### Connect Antenna

1. Connect GSM antenna to U.FL/IPEX connector
2. Ensure secure connection
3. Position antenna away from metal objects

!!! danger "Required Antenna"
    The SIM800 will not work without an antenna. Never power on without antenna connected.

#### Power Options

=== "USB Power"
    - Connect USB-C cable to computer or wall adapter
    - Suitable for development and testing
    - No battery required

=== "Battery Power"
    - Connect Li-Po battery via JST PH 2.0mm connector
    - Press power button to turn on
    - LED indicator shows power status
    - Suitable for deployment

=== "USB + Battery"
    - Connect both USB and battery
    - Battery charges while USB connected
    - Automatic fallback to battery
    - Best for continuous operation

### 2. ESP-IDF Configuration

```bash
cd espilon_bot
idf.py menuconfig
```

Navigate to configuration:

```
Espilon Configuration
  ├─ Network Backend Selection
  │   └─ [X] GPRS (select GPRS mode)
  │
  ├─ GPRS Configuration
  │   ├─ APN: "your-operator-apn"
  │   ├─ UART TXD GPIO: 27 (default, do not change)
  │   ├─ UART RXD GPIO: 26 (default, do not change)
  │   ├─ PWR_KEY GPIO: 4 (default)
  │   ├─ PWR_EN GPIO: 23 (default)
  │   └─ RESET GPIO: 5 (default)
  │
  └─ C2 Server Configuration
      ├─ Server IP: "your.server.ip"
      └─ Server Port: 2626
```

### 3. Common APNs

| Operator | Country | APN |
|----------|---------|-----|
| SFR | France | `sl2sfr` |
| Orange | France | `orange.fr` |
| Bouygues | France | `mmsbouygtel.com` |
| AT&T | USA | `phone` |
| T-Mobile | USA | `fast.t-mobile.com` |
| Vodafone | UK | `pp.vodafone.co.uk` |
| Telstra | Australia | `telstra.internet` |

### 4. Build and Flash

```bash
# Build firmware
idf.py build

# Flash to T-Call
idf.py -p /dev/ttyUSB0 flash

# Monitor output
idf.py monitor
```

### 5. Verification

Expected boot sequence:

```
I (123) boot: ESP-IDF v5.3.2
I (234) GPRS: Initializing modem...
I (456) GPRS: Modem powered on
I (789) GPRS: AT command test: OK
I (1234) GPRS: Registering on network...
I (5678) GPRS: Network registered (Operator: SFR)
I (6789) GPRS: Activating GPRS...
I (8901) GPRS: GPRS active
I (9012) GPRS: Connecting to C2: 192.168.1.100:2626
I (10234) GPRS: TCP connected
I (10456) epsilon: Device ce4f626b ready
```

## Power Management

### IP5306 Features

The IP5306 provides intelligent power management:

- **Input**: 5V USB-C
- **Battery**: Single cell Li-Ion (3.7V)
- **Output**: 5V @ 2A (boost)
- **Charging**: 1A max
- **Protection**: Overcharge, over-discharge, short circuit

### Battery Specifications

**Recommended**: Li-Po 3.7V 1000-2000mAh with JST PH 2.0mm connector

| Parameter | Min | Typical | Max |
|-----------|-----|---------|-----|
| Voltage | 3.0V | 3.7V | 4.2V |
| Capacity | 1000mAh | 1500mAh | 2000mAh |
| Discharge | - | 1C | 2C |

!!! warning "Battery Safety"
    - Use protected Li-Po cells with JST PH 2.0mm connector
    - Do not exceed 4.2V charging voltage
    - Do not discharge below 3.0V
    - Use quality batteries from known brands

### Runtime Estimation

| Mode | Current Draw | Runtime (1500mAh) |
|------|--------------|-------------------|
| Idle (connected) | ~100mA | ~14 hours |
| Active (commands) | ~150mA | ~9 hours |
| GPRS TX burst | ~300mA | ~5 hours |
| Deep sleep | ~10mA | ~140 hours |

## Troubleshooting

### SIM800 Not Responding

**Symptoms**: No AT responses, no network registration

**Checks**:

1. Antenna connected?
2. SIM card inserted correctly?
3. Battery/USB power adequate?
4. Power button pressed (if battery only)?

**Solutions**:

```bash
# Test AT communication
idf.py monitor
# Should see "AT -> OK" responses
```

### Network Registration Failed

**Symptoms**: Stuck at "Registering on network"

**Checks**:

1. SIM card active and not expired?
2. Data plan enabled?
3. Good signal strength (antenna placement)?
4. PIN code disabled?

**Solutions**:

```c
// Check signal strength in logs
AT+CSQ
// Response: +CSQ: <rssi>,<ber>
// RSSI should be 10-31 (usable)
```

### Power Issues

**Symptoms**: Random resets, unstable operation

**Checks**:

1. Battery charged (>3.3V)?
2. USB cable quality (data cable, not charging only)?
3. Battery installed correctly (polarity)?

**Solutions**:

- Use USB power for stable operation
- Replace weak battery
- Try different USB port/cable

## Advanced Configuration

### Custom GPIO

If you need to use GPIOs 26/27 for other purposes:

!!! danger "Hardware Modification Required"
    Changing UART pins requires cutting PCB traces and soldering new connections. Not recommended for beginners.

Alternative: Use software serial or I2C peripherals on available GPIOs.

### External Power

For permanent installations:

```
5V Power Supply (2A) → USB-C Port
    or
3.7V Battery Pack → Battery Terminals
```

### Antenna Upgrades

For better range:

- **Standard**: 2dBi GSM antenna (included)
- **Upgrade**: 5dBi external antenna
- **Professional**: 9dBi directional antenna

## Comparison

### LilyGO T-Call vs DIY SIM800L

| Feature | LilyGO T-Call | DIY SIM800L |
|---------|---------------|-------------|
| Wiring | None (integrated) | 8+ wires |
| Power Management | Integrated IP5306 | External required |
| Battery Support | Built-in holder | DIY solution |
| Reliability | Industrial PCB | Breadboard risks |
| Price | ~$18 | ~$25-35 total |
| Setup Time | 5 minutes | 30+ minutes |
| **Recommended** | ✅ Yes | Only if T-Call unavailable |

## Purchase Links

- [LilyGO Official Store](http://www.lilygo.cn/)
- AliExpress: Search "LilyGO T-Call"
- Amazon: Available in some regions

!!! tip "Verify Authenticity"
    Purchase from official LilyGO stores or authorized resellers to ensure genuine products.

## Resources

- [LilyGO GitHub](https://github.com/Xinyuan-LilyGO/LilyGO-T-Call-SIM800)
- [SIM800L Datasheet](https://simcom.ee/documents/SIM800L/SIM800L_Hardware%20Design_V1.00.pdf)
- [IP5306 Datasheet](https://datasheet.lcsc.com/szlcsc/1811151337_INJOINIC-IP5306_C181692.pdf)

---

**Next**: [ESP32-CAM Setup](esp32-cam.md) | [Back to Hardware](index.md)
