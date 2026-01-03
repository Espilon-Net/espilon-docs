# Hardware Guide

This document provides detailed hardware information for Espilon, including supported boards, pinouts, wiring diagrams, and hardware-specific configurations.

---

## Table of Contents

- [Supported Hardware](#supported-hardware)
- [Basic WiFi Setup](#basic-wifi-setup)
- [GPRS Module Setup](#gprs-module-setup)
- [ESP32-CAM Setup](#esp32-cam-setup)
- [Power Requirements](#power-requirements)
- [Antenna Considerations](#antenna-considerations)
- [Troubleshooting Hardware Issues](#troubleshooting-hardware-issues)

---

## Supported Hardware

### ESP32 Variants

Espilon is compatible with all ESP32 variants supported by ESP-IDF v5.3.2:

| Variant | WiFi | Bluetooth | PSRAM | Flash | Status |
|---------|------|-----------|-------|-------|--------|
| **ESP32** | 2.4GHz | Classic + BLE | Optional | 4-16MB | Fully Supported |
| **ESP32-S2** | 2.4GHz | No | Optional | 4-16MB | Supported (no BLE features) |
| **ESP32-S3** | 2.4GHz | BLE 5.0 | Optional | 4-32MB | Fully Supported |
| **ESP32-C3** | 2.4GHz | BLE 5.0 | No | 4-8MB | Supported |
| **ESP32-C6** | 2.4GHz + 802.15.4 | BLE 5.0 | No | 4-8MB | Experimental |

### Recommended Development Boards

#### For Basic WiFi Mode

**ESP32 DevKit V1** (Most Common)
- Price: ~$5-8
- 30 GPIO pins
- Built-in USB-to-Serial (CP2102 or CH340)
- Micro USB port
- Reset and BOOT buttons
- Onboard LED (GPIO2)

**NodeMCU-32S**
- Similar to DevKit V1
- Slightly different pin layout
- Good compatibility

**ESP32-WROOM-32** (Module)
- Barebone module (requires additional components)
- Smaller form factor
- For custom PCB designs

#### For GPRS Mode

**LilyGO T-Call** (RECOMMENDED)
- Price: ~$15-20
- **Integrated SIM800L module** (no external wiring needed)
- ESP32-WROVER-B (4MB PSRAM)
- Micro SIM card slot
- IP5306 power management IC
- 18650 battery holder
- Built-in USB-to-Serial (CP2104)
- Perfect for portable GPRS deployments
- **Official Espilon GPRS board**

**ESP32 DevKit V1** + **External SIM800L/SIM808 Module**
- Standard ESP32 development board
- External GPRS module via UART
- Requires manual wiring
- See [GPRS Module Setup](#gprs-module-setup)

#### For Camera/Vision

**ESP32-CAM (AI-Thinker)**
- Price: ~$8-12
- 2MP OV2640 camera
- MicroSD card slot
- 4MB PSRAM (required)
- External antenna connector
- **No built-in USB** (requires FTDI/USB-to-Serial adapter for programming)

**Alternative**: ESP32-S3 DevKit + OV2640 module
- More GPIO flexibility
- Built-in USB programming

---

## Basic WiFi Setup

### Minimal Configuration

For basic WiFi operation, you only need:

1. **ESP32 Development Board**
2. **USB Cable** (data-capable)
3. **Power Supply** (USB 5V provides sufficient power)

### Pin Usage

When using default WiFi mode, the following pins are utilized by the ESP32 internally:

**WiFi Radio (Internal - No External Connections Needed)**

These pins are used internally by the ESP32 and should **NOT** be connected to anything:

- GPIO 6-11: Flash memory (SPI)
- Internal: WiFi RF circuits

**Available GPIOs for Modules**

All other GPIOs are available for modules:

```
GPIO 0  - Boot mode (has pull-up, can be used but avoid during boot)
GPIO 2  - Onboard LED (most boards)
GPIO 4  - Free
GPIO 5  - Free
GPIO 12 - Free (bootstrap pin, avoid if using PSRAM)
GPIO 13 - Free
GPIO 14 - Free
GPIO 15 - Free (bootstrap pin, avoid if using PSRAM)
GPIO 16 - Free
GPIO 17 - Free
GPIO 18 - Free
GPIO 19 - Free
GPIO 21 - Free
GPIO 22 - Free
GPIO 23 - Free
GPIO 25 - DAC1
GPIO 26 - DAC2
GPIO 27 - Free
GPIO 32 - Free
GPIO 33 - Free
GPIO 34 - Input only (no pull-up/down)
GPIO 35 - Input only (no pull-up/down)
GPIO 36 (VP) - Input only (no pull-up/down)
GPIO 39 (VN) - Input only (no pull-up/down)
```

**Reserved/Avoid**:
- GPIO 1 (TX0) - Serial console
- GPIO 3 (RX0) - Serial console
- GPIO 6-11 - Connected to flash (DO NOT USE)

### Antenna

**Internal PCB Antenna**:
- Most DevKit boards have built-in PCB antenna
- Range: ~50-100m indoor, ~300m outdoor (depends on environment)
- No external antenna needed for basic use

**External Antenna** (optional):
- Some boards have U.FL/IPEX connector
- Improves range significantly
- 2.4GHz WiFi antenna (50Ω impedance)
- Recommended for FakeAP mode to maximize coverage

---

## GPRS Module Setup

### LilyGO T-Call (Recommended)

**LilyGO T-Call** is the recommended board for Espilon GPRS mode. It integrates the SIM800L module directly on the PCB, eliminating the need for external wiring and power management.

#### Specifications

- **MCU**: ESP32-WROVER-B
- **PSRAM**: 4MB
- **Flash**: 4MB
- **GPRS**: SIM800L (integrated)
- **Power Management**: IP5306
- **Battery**: 18650 Li-Ion holder
- **USB**: CP2104 USB-to-UART
- **SIM**: Micro SIM card slot

#### Pinout (LilyGO T-Call)

```
LilyGO T-Call
┌──────────────────────────────────────┐
│  [ESP32-WROVER-B]    [SIM800L]      │
│                                      │
│  GPIO 27 ──────────→ SIM800 RXD     │
│  GPIO 26 ──────────← SIM800 TXD     │
│  GPIO 4  ──────────→ SIM800 PWR_KEY │
│  GPIO 23 ──────────→ SIM800 PWR_EN  │
│  GPIO 5  ──────────→ SIM800 RESET   │
│  GPIO 13 ──────────→ LED (optional) │
│                                      │
│  [Micro SIM Slot]                   │
│  [18650 Battery Holder]             │
│  [USB-C Port]                       │
└──────────────────────────────────────┘
```

#### Advantages

- **No external wiring required** - All connections are on the PCB
- **Integrated power management** - IP5306 handles battery charging and 5V boost
- **Portable** - 18650 battery for standalone operation
- **Reliable** - Industrial-grade design
- **Cost-effective** - All-in-one solution (~$15-20)

#### Setup for LilyGO T-Call

1. **Insert SIM card** (Micro SIM, disable PIN code)
2. **Configure in menuconfig**:
   ```
   Espilon Configuration
     → Network Backend Selection
       → [X] GPRS
     → GPRS Configuration
       → APN: "your-operator-apn"
   ```
3. **Connect USB-C cable** for programming and power
4. **Optional**: Insert 18650 battery for portable operation

#### Power Options for T-Call

- **USB-C**: 5V via USB port (for development)
- **18650 Battery**: 3.7V Li-Ion (for deployment)
- **Both**: Battery charges while USB connected

---

### External SIM800L Module (Alternative)

If not using LilyGO T-Call, you can use an external SIM800L module with any ESP32 board.

#### Required Hardware

1. **ESP32 DevKit Board** (any variant)
2. **SIM800L or SIM808 Module**
3. **SIM Card** (with data plan and no PIN code)
4. **External 5V Power Supply** (SIM800 draws up to 2A during transmission)
5. **Jumper Wires**
6. **Optional**: Logic level converter (if SIM800 is not 3.3V compatible)

### SIM800L Module Overview

**Specifications**:
- Quad-band GSM/GPRS (850/900/1800/1900 MHz)
- UART communication (9600 baud default)
- Supply voltage: **3.7-4.2V** (NOT 5V! Can damage module)
- Peak current: 2A during transmission
- Dimensions: ~25mm x 25mm

### Pinout

#### ESP32 Side

```
ESP32 DevKit
┌─────────────────┐
│                 │
│  GPIO 27 (TXD) ─┼──→ SIM800 RXD
│  GPIO 26 (RXD) ─┼──← SIM800 TXD
│  GPIO 4  (KEY) ─┼──→ SIM800 PWR_KEY
│  GPIO 23 (EN)  ─┼──→ SIM800 VCC Enable
│  GPIO 5  (RST) ─┼──→ SIM800 RESET
│  GPIO 13 (LED) ─┼──→ Status LED (optional)
│  GND           ─┼──→ SIM800 GND
│                 │
└─────────────────┘
```

#### SIM800L Module

```
SIM800L Module
┌──────────────────────┐
│  ┌────────┐          │
│  │ SIM800 │   Antenna│──→ GSM Antenna
│  └────────┘          │
│                      │
│ VCC ← 3.7-4.2V Power │
│ GND ← Ground         │
│ TXD ← ESP32 GPIO 27  │
│ RXD ← ESP32 GPIO 26  │
│ RST ← ESP32 GPIO 5   │
│ KEY ← ESP32 GPIO 4   │
│                      │
└──────────────────────┘
```

### Wiring Diagram

```
┌──────────────────┐          ┌──────────────────┐
│   ESP32 DevKit   │          │    SIM800L       │
│                  │          │                  │
│  3.3V  ────────┐ │          │                  │
│  GND   ────┐   │ │          │                  │
│  GPIO27 ───┼───┼─┼──────────┼→ RXD             │
│  GPIO26 ───┼───┼─┼──────────┼← TXD             │
│  GPIO4  ───┼───┼─┼──────────┼→ PWR_KEY         │
│  GPIO23 ───┼───┼─┼──────────┼→ (VCC control)   │
│  GPIO5  ───┼───┼─┼──────────┼→ RESET           │
└────────────┼───┼─┘          └──────────────────┘
             │   │                      │   │
             │   │            ┌─────────┼───┼─┐
             │   │            │  Power Supply  │
             │   │            │  (3.7-4.2V)    │
             │   │            │  (2A capable)  │
             │   └────────────┼─ GND           │
             │                │  +V            │
             └────────────────┼─ GND           │
                              └────────────────┘
```

### Power Supply Considerations

**CRITICAL**: SIM800L requires stable power supply

**DO NOT** power SIM800L from ESP32's 3.3V regulator!
- SIM800 draws up to 2A in burst (transmission)
- ESP32 regulator typically provides only 500-800mA
- Insufficient power causes:
  - Module resets during transmission
  - Failed network registration
  - Unstable UART communication

**Recommended Power Solutions**:

1. **Dedicated 18650 Li-Ion Battery** (3.7V nominal)
   - Capacity: 2000mAh minimum
   - Can handle 2A burst current
   - Most reliable option

2. **3.7V LiPo Battery**
   - 1000mAh minimum
   - With battery management (charging circuit)

3. **5V to 4V Buck Converter**
   - Input: 5V USB or power supply
   - Output: 4V regulated
   - Current: 2A minimum

4. **Dual Power Supply**
   - ESP32: Powered via USB (5V)
   - SIM800: Separate 3.7-4.2V supply
   - Common ground between both

### Antenna

SIM800L **requires** external GSM antenna:
- **Type**: GSM quad-band antenna (850/900/1800/1900 MHz)
- **Connector**: U.FL/IPEX (depends on module)
- **Impedance**: 50Ω
- **Gain**: 2-5 dBi recommended

**Without proper antenna**:
- Module will not register on network
- Very weak signal or no signal

### SIM Card Requirements

- **Active SIM card** with data plan
- **PIN code disabled** (module cannot handle PIN entry automatically)
- **APN configured** in menuconfig (operator-specific)

**Disable PIN**:
1. Insert SIM in phone
2. Settings → Security → SIM PIN → Disable
3. Insert in SIM800L

**Common APNs**:
- SFR (France): `sl2sfr`
- Orange (France): `orange.fr` or `orange`
- Bouygues (France): `mmsbouygtel.com`
- AT&T (USA): `phone`
- T-Mobile (USA): `fast.t-mobile.com`
- Vodafone (UK): `pp.vodafone.co.uk`

### Configuration in Menuconfig

```bash
idf.py menuconfig

# Navigate to:
Espilon Configuration
  → Network Backend Selection
    → [X] GPRS (select this)
  → GPRS Configuration
    → APN: "your-operator-apn"
    → UART TXD GPIO: 27
    → UART RXD GPIO: 26
    → PWR_KEY GPIO: 4
    → PWR_EN GPIO: 23
    → RESET GPIO: 5
    → LED GPIO: 13 (optional)
```

### Testing GPRS Connection

After flashing:

```bash
idf.py monitor

# Expected output:
I (123) GPRS: Initializing modem...
I (456) GPRS: Modem powered on
I (789) GPRS: Registering on network...
I (2000) GPRS: Network registered (SFR)
I (3000) GPRS: Activating GPRS...
I (4000) GPRS: GPRS active
I (5000) GPRS: Connecting to C2...
I (6000) GPRS: TCP connected
```

---

## ESP32-CAM Setup

### Module Overview

**ESP32-CAM (AI-Thinker)**:
- ESP32-S chip
- OV2640 camera (2MP, 1600x1200 max)
- 4MB PSRAM (required for camera buffering)
- MicroSD card slot
- Onboard flash LED
- External antenna connector (U.FL)

### Pinout

```
ESP32-CAM AI-Thinker Pinout
┌────────────────────────────────┐
│         [CAMERA OV2640]        │
│                                │
│  5V   GND   IO12  IO13         │
│  GND  IO15  IO14  IO2          │
│  IO4  IO16  GND   VCC          │
│  U0R  U0T   IO0   GND          │
│                                │
│      [MicroSD Slot]            │
│                                │
│  ANT ──○ (External Antenna)    │
└────────────────────────────────┘
```

**Detailed Pin Mapping**:

```
Power:
  5V    - Power input (5V)
  GND   - Ground
  3.3V  - 3.3V output (for external sensors)

Serial (Programming):
  U0T   - UART0 TX (GPIO1)
  U0R   - UART0 RX (GPIO3)
  IO0   - BOOT mode (pull LOW during power-on for flashing)

Camera Interface (Fixed):
  PWDN  - GPIO32
  RESET - Not connected (-1)
  XCLK  - GPIO0
  SIOD  - GPIO26 (I2C SDA)
  SIOC  - GPIO27 (I2C SCL)
  D7    - GPIO35
  D6    - GPIO34
  D5    - GPIO39
  D4    - GPIO36
  D3    - GPIO21
  D2    - GPIO19
  D1    - GPIO18
  D0    - GPIO5
  VSYNC - GPIO25
  HREF  - GPIO23
  PCLK  - GPIO22

Flash LED:
  GPIO4 - High-power LED (for illumination)

MicroSD Card:
  CMD   - GPIO15
  CLK   - GPIO14
  DATA0 - GPIO2
  DATA1 - GPIO4 (conflicts with LED)
  DATA2 - GPIO12
  DATA3 - GPIO13

Available GPIOs (not used by camera):
  GPIO12, GPIO13, GPIO15, GPIO14, GPIO2, GPIO4, GPIO16
  Note: Some shared with SD card
```

### Programming ESP32-CAM

**ESP32-CAM has NO built-in USB programmer!**

You need an external **FTDI adapter** or **USB-to-Serial adapter** (3.3V logic level).

#### Wiring for Programming

```
FTDI/USB-to-Serial          ESP32-CAM
┌──────────────┐          ┌──────────┐
│              │          │          │
│  5V    ──────┼──────────┼→ 5V      │
│  GND   ──────┼──────────┼→ GND     │
│  TX    ──────┼──────────┼→ U0R     │
│  RX    ──────┼──────────┼→ U0T     │
│              │          │          │
└──────────────┘          └──────────┘
                               │
                          GPIO0 ─┐
                                 │
                              ┌──┴──┐
                              │ GND │  (Connect for flashing)
                              └─────┘
```

**Flashing Procedure**:

1. **Connect wiring** as above
2. **Connect GPIO0 to GND** (pull BOOT pin LOW)
3. **Power on** ESP32-CAM (or press RESET if already powered)
4. **Flash firmware**:
   ```bash
   idf.py -p /dev/ttyUSB0 flash
   ```
5. **Disconnect GPIO0 from GND**
6. **Press RESET** button or power cycle

**After successful flash**:
- Disconnect GPIO0 from GND
- ESP32-CAM will boot normally
- You can keep FTDI connected for serial monitoring

#### Using ESP32-CAM-MB Programmer Board

Some kits include a programmer board (ESP32-CAM-MB):
- ESP32-CAM slots into the board
- Built-in USB-to-Serial (CH340)
- Automatic boot mode (no need to jumper GPIO0)
- Easier flashing

Simply:
```bash
idf.py -p /dev/ttyUSB0 flash monitor
```

### Camera Configuration

The camera pins are **hardcoded** in Espilon for AI-Thinker board:

```c
// From mod_cam.c
#define CAM_PIN_PWDN    32
#define CAM_PIN_RESET   -1
#define CAM_PIN_XCLK    0
#define CAM_PIN_SIOD    26
#define CAM_PIN_SIOC    27
#define CAM_PIN_D7      35
#define CAM_PIN_D6      34
#define CAM_PIN_D5      39
#define CAM_PIN_D4      36
#define CAM_PIN_D3      21
#define CAM_PIN_D2      19
#define CAM_PIN_D1      18
#define CAM_PIN_D0      5
#define CAM_PIN_VSYNC   25
#define CAM_PIN_HREF    23
#define CAM_PIN_PCLK    22
```

If using a different ESP32-CAM board, you may need to modify these pins in [mod_cam.c](../espilon_bot/components/mod_recon/mod_cam.c).

### Camera Settings

Configured in code (can be made configurable):
- **Frame Size**: QQVGA (160x120) - optimized for low bandwidth
- **JPEG Quality**: 20 (adjustable 0-63, lower = higher quality)
- **Pixel Format**: JPEG
- **Frame Buffers**: 2 (double buffering)
- **PSRAM**: Required (FB_IN_PSRAM)

### Enabling Camera Module

```bash
idf.py menuconfig

# Navigate to:
Espilon Configuration
  → Module Selection
    → [*] Recon Module
      → Recon Mode Selection
        → [*] Camera Mode (ESP32-CAM)
```

### Testing Camera

After flashing:

```bash
# From C2 server
c3po> send <device-id> capture

# Should receive JPEG image data
# Or test streaming:
c3po> send <device-id> stream_start <udp-target-ip> <port>
```

---

## Power Requirements

### ESP32 Power Consumption

**Typical Current Draw**:

| Mode | Current | Notes |
|------|---------|-------|
| Deep Sleep | 10-150 μA | RTC + ULP running |
| Light Sleep | 0.8 mA | CPU paused, WiFi off |
| Modem Sleep | 15-20 mA | WiFi periodic wake |
| **Active WiFi TX** | **160-260 mA** | Peak during transmission |
| **Active WiFi RX** | **95-100 mA** | Receiving data |
| BLE Active | 40-100 mA | Depends on activity |

**For Espilon (Active C2 Communication)**:
- Average: **100-150 mA**
- Peak: **200-300 mA** (WiFi transmission + processing)

### Power Supply Options

#### 1. USB Power (5V)

**Via Development Board USB**:
- Input: 5V USB
- Onboard regulator: 3.3V output (500-800mA typically)
- Sufficient for: Basic WiFi mode
- **NOT sufficient for**: SIM800 GPRS mode

**Recommended**: Use quality USB cable and power adapter (2A capable)

#### 2. Battery Power

**Li-Ion 18650 Battery**:
- Voltage: 3.7V nominal (3.0-4.2V range)
- Capacity: 2000-3000mAh
- Runtime: ~10-20 hours (depends on activity)
- Use battery holder + voltage regulator (3.3V)

**LiPo Battery**:
- Voltage: 3.7V nominal
- Capacity: 1000mAh+ recommended
- Requires charging circuit (TP4056 or similar)
- Compact form factor

**Wiring**:
```
Battery (+) ──→ LDO 3.3V Regulator ──→ ESP32 3.3V pin
Battery (-) ──→ GND ────────────────→ ESP32 GND
```

**Recommended Regulator**: AMS1117-3.3V (800mA) or similar

#### 3. External Power Supply

**For permanent installations**:
- 5V wall adapter (2A minimum)
- Connected to ESP32 5V/VIN pin
- Onboard regulator converts to 3.3V

### Power Optimization Tips

**Reduce power consumption**:

1. **Lower TX power** (WiFi):
   ```c
   esp_wifi_set_max_tx_power(8);  // Reduce from 20 dBm to 8 dBm
   ```

2. **Reduce CPU frequency**:
   ```bash
   idf.py menuconfig
   # → Component config → ESP System → CPU frequency
   # Select 160 MHz instead of 240 MHz
   ```

3. **Disable unused peripherals**:
   - Turn off Bluetooth if not using BLE features
   - Disable camera when not capturing
   - Use light sleep between C2 polls (future feature)

---

## Antenna Considerations

### WiFi Antenna

**Internal PCB Antenna** (most DevKit boards):
- Range: 50-100m indoor, 300m outdoor (line of sight)
- No modifications needed
- Adequate for most uses

**External WiFi Antenna**:
- Connector: U.FL/IPEX (if board supports)
- Type: 2.4GHz WiFi antenna
- Gain: 3-9 dBi
- Range: Up to 1km+ outdoor (high-gain directional)

**When to use external antenna**:
- FakeAP mode (maximize client coverage)
- Long-range deployment
- Indoor environments with interference
- Metal enclosures (attenuates internal antenna)

### GSM/GPRS Antenna (SIM800)

**Required** for GPRS mode:
- Frequency: GSM quad-band (850/900/1800/1900 MHz)
- Connector: U.FL/IPEX or SMA (depends on module)
- Type: Omnidirectional
- Gain: 2-5 dBi
- Placement: External to enclosure, vertical orientation preferred

**Testing antenna**:
```bash
# AT command to check signal strength
AT+CSQ

# Response: +CSQ: <rssi>,<ber>
# RSSI:
#   0      = -113 dBm or less (no signal)
#   1      = -111 dBm
#   2-30   = -109 to -53 dBm (usable)
#   31     = -51 dBm or greater (excellent)
#   99     = Not known or detectable
```

Good signal: RSSI ≥ 10 (approximately -93 dBm)

---

## Enclosures and Mechanical

### Enclosure Considerations

**Material**:
- **Plastic**: Best for WiFi/GPRS (RF transparent)
- **Metal**: Attenuates signals significantly (requires external antennas)
- **3D Printed**: Works well (PLA, ABS)

**Design**:
- Ventilation slots (ESP32 can get warm)
- Access to USB port (for programming/power)
- Antenna placement (external or clear window)
- Status LED visibility
- Reset button access

### Mounting ESP32 Boards

**Common mounting holes**:
- Most DevKit boards: No mounting holes (use standoffs or adhesive)
- ESP32-CAM: 4x M2 mounting holes at corners

**3D Printable Cases**:
- Search Thingiverse/Printables for "ESP32 DevKit case"
- Custom designs for specific modules

### Heat Dissipation

**ESP32 operating temperature**:
- Range: -40°C to +125°C
- Typical operation: 40-60°C

**For continuous operation**:
- Ensure airflow in enclosure
- Heatsink optional (adhesive aluminum heatsinks available)
- Avoid enclosing in sealed plastic without ventilation

---

## Troubleshooting Hardware Issues

### WiFi Issues

**Problem**: Cannot connect to WiFi

**Checks**:
1. **2.4GHz network**: ESP32 does NOT support 5GHz
2. **SSID visible**: Hidden SSIDs require additional config
3. **Antenna connected**: If using external antenna
4. **TX power**: Try increasing in code

**Problem**: Short WiFi range

**Solutions**:
- Use external antenna
- Increase TX power (up to 20 dBm)
- Reduce interference (change WiFi channel)
- Position ESP32 away from metal objects

### GPRS Issues

**Problem**: Module not responding

**Checks**:
1. **Power supply**: 3.7-4.2V, 2A capable
2. **Antenna connected**: Essential for registration
3. **UART wiring**: TX → RX, RX → TX (crossover)
4. **Baud rate**: 9600 (default for SIM800)

**Test UART manually**:
```bash
# Send AT commands via serial
idf.py monitor

# Type (if you modified code to echo):
AT
# Should respond: OK
```

**Problem**: Network registration fails

**Checks**:
- SIM card active and data-enabled
- PIN code disabled
- Antenna properly connected
- Signal strength (AT+CSQ should return > 10)
- APN configured correctly for operator

### Camera Issues

**Problem**: Camera init failed

**Checks**:
1. **PSRAM enabled**:
   ```bash
   idf.py menuconfig
   # → Component config → ESP PSRAM → [*] Support for external PSRAM
   ```
2. **Correct board**: AI-Thinker pinout (default in code)
3. **Camera module seated**: Ribbon cable properly connected
4. **Power sufficient**: 5V supply

**Problem**: Poor image quality

**Adjustments**:
- Increase JPEG quality (lower number = better quality)
- Improve lighting (use flash LED on GPIO4)
- Clean lens
- Adjust exposure/gain settings in camera driver

### Power Issues

**Problem**: ESP32 resets randomly

**Causes**:
- Insufficient power supply
- Voltage drop during WiFi TX
- Bad USB cable (high resistance)

**Solutions**:
- Use quality power supply (2A minimum)
- Short, thick USB cable
- Add capacitor (100-470μF) across VCC/GND near ESP32
- Battery power for stable operation

**Problem**: SIM800 resets during use

**Cause**: Power supply cannot handle 2A burst

**Solution**: Use dedicated battery or buck converter (not ESP32 regulator)

---

## Appendix: GPIO Quick Reference

### ESP32 (Standard Variant)

```
Strapping Pins (affect boot mode):
  GPIO 0  - Boot mode (LOW = flash mode, HIGH = normal boot)
  GPIO 2  - Boot mode selection
  GPIO 5  - SDIO timing (with PSRAM)
  GPIO 12 - Flash voltage (with PSRAM, must be LOW)
  GPIO 15 - SDIO timing (with PSRAM)

Input Only (no internal pull-up/pull-down):
  GPIO 34, 35, 36, 39

ADC1 (can use while WiFi active):
  GPIO 32, 33, 34, 35, 36, 39

ADC2 (conflicts with WiFi):
  GPIO 0, 2, 4, 12, 13, 14, 15, 25, 26, 27

DAC (Digital-to-Analog):
  GPIO 25, 26

Touch Sensor:
  GPIO 0, 2, 4, 12, 13, 14, 15, 27, 32, 33

Do NOT use (connected to flash):
  GPIO 6, 7, 8, 9, 10, 11
```

### Pin Selection Best Practices

**For digital I/O**: Use GPIO 4, 5, 16, 17, 18, 19, 21, 22, 23

**For analog input**: Use ADC1 channels (32, 33, 34, 35, 36, 39) if WiFi is active

**Avoid during development**:
- GPIO 0 (used for flashing)
- GPIO 1, 3 (UART console)
- GPIO 2 (often connected to onboard LED)

---

## Resources

- [ESP32 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32_datasheet_en.pdf)
- [ESP32-CAM Datasheet](https://github.com/SeeedDocument/forum_doc/raw/master/reg/ESP32_CAM_V1.6.pdf)
- [SIM800L Datasheet](https://www.simcom.com/product/SIM800.html)
- [ESP-IDF GPIO Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/peripherals/gpio.html)

---

**Last Updated**: 2025-12-26
