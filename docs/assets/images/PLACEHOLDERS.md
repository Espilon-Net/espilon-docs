# Image Placeholders Guide

This document lists all the images you should add to complete the documentation.

## Required Images

### Logo and Branding

#### `logo.png`
- **Size**: 512x512px (PNG with transparency)
- **Description**: Espilon main logo - the purple 'E' you have
- **Usage**: Homepage, navigation header
- **Location**: `docs/assets/images/logo.png`

#### `logo-text.png` (optional)
- **Size**: 800x200px
- **Description**: Logo with "Espilon" text
- **Usage**: Hero section, documentation header

---

## Screenshots Needed

### C2 Server Interface

#### `c2-startup.png`
**What to capture**: Terminal showing C2 server starting
```
Screenshot showing:
- C3PO banner
- "Server listening on 0.0.0.0:2626" message
- "Waiting for agents..." text
```
**Usage**: Installation guide, C2 server docs

#### `c2-device-connected.png`
**What to capture**: C2 showing connected device
```
Screenshot showing:
- "[+] New device connected: ce4f626b"
- Device list with IP addresses
- Active command prompt
```
**Usage**: Quick start guide, C2 server docs

#### `c2-command-execution.png`
**What to capture**: Executing commands on device
```
Screenshot showing:
- Command: arp_scan
- JSON response with hosts found
- Multiple commands and responses
```
**Usage**: Command reference, tutorials

#### `c2-multiple-devices.png`
**What to capture**: Managing multiple agents
```
Screenshot showing:
- 3+ devices connected
- Group management commands
- Group execution
```
**Usage**: Advanced usage, scaling docs

---

### ESP32 Hardware

#### `esp32-devkit.jpg`
**What to photograph**:
- ESP32 DevKit board
- USB cable connected
- Clear view of pinout
**Usage**: Hardware guide, getting started

#### `lilygo-tcall.jpg`
**What to photograph**:
- LilyGO T-Call board
- SIM card slot visible
- Antenna connected
**Usage**: Hardware guide, GPRS setup

#### `esp32-cam.jpg`
**What to photograph**:
- ESP32-CAM board
- Camera module visible
- Pinout labels
**Usage**: Hardware guide, camera module docs

#### `hardware-comparison.jpg`
**What to photograph**:
- All 3 boards side by side
- Size comparison
- Clear labeling
**Usage**: Hardware overview

---

### Setup Process

#### `menuconfig-main.png`
**What to capture**: ESP-IDF menuconfig main screen
```
Screenshot showing:
- "Espilon Bot Configuration" menu item
- Other ESP-IDF menu options
- Navigation instructions at bottom
```
**Usage**: Configuration guide, quick start

#### `menuconfig-device-id.png`
**What to capture**: Device ID configuration
```
Screenshot showing:
- Device Identity submenu
- Device ID field with example
- Current value displayed
```
**Usage**: Configuration guide

#### `menuconfig-network.png`
**What to capture**: Network configuration screen
```
Screenshot showing:
- Connection Mode selection
- WiFi SSID and Password fields
- GPRS APN options
```
**Usage**: Network configuration docs

#### `menuconfig-modules.png`
**What to capture**: Module selection screen
```
Screenshot showing:
- [X] Network Commands
- [ ] Recon Commands
- [ ] Fake AP Commands
- Checkboxes and descriptions
```
**Usage**: Module configuration

---

### Build and Flash Process

#### `build-progress.png`
**What to capture**: Build in progress
```
Screenshot showing:
- "Building ESP-IDF project..."
- Progress bars
- Compilation output
```
**Usage**: Installation guide

#### `build-success.png`
**What to capture**: Successful build
```
Screenshot showing:
- "[100%] Built target espilon_bot.elf"
- Binary size information
- "Project built successfully"
```
**Usage**: Installation guide, troubleshooting

#### `flash-process.png`
**What to capture**: Flashing to ESP32
```
Screenshot showing:
- "Connecting........_____"
- "Chip is ESP32-D0WDQ6"
- Flash progress percentage
```
**Usage**: Quick start, flashing guide

#### `serial-monitor.png`
**What to capture**: Device boot logs
```
Screenshot showing:
- Boot messages
- WiFi connection
- C2 connection
- "Agent ready" message
```
**Usage**: Quick start, troubleshooting

---

### Command Examples

#### `command-arp-scan.png`
**What to capture**: ARP scan results
```
Screenshot showing:
- arp_scan command
- JSON output with discovered hosts
- MAC addresses and vendors
```
**Usage**: Command reference, network module

#### `command-wifi-scan.png`
**What to capture**: WiFi scan results
```
Screenshot showing:
- wifi_scan command
- List of networks with RSSI
- Security types (WPA2, OPEN, etc.)
```
**Usage**: Command reference, recon module

#### `command-port-scan.png`
**What to capture**: Port scan in action
```
Screenshot showing:
- port_scan command with target
- Progress indicator
- Open ports discovered
```
**Usage**: Command reference, network module

---

### Flasher Tool

#### `flasher-gui.png`
**What to capture**: Multi-device flasher interface
```
Screenshot showing:
- Device list with ports
- Configuration per device
- Flash buttons
```
**Usage**: Flasher documentation

#### `flasher-progress.png`
**What to capture**: Flashing multiple devices
```
Screenshot showing:
- Multiple devices flashing in parallel
- Progress bars
- Success/failure indicators
```
**Usage**: Flasher documentation, scaling

---

## Diagrams to Create

### Architecture Diagrams

#### `architecture-overview.svg` or `.png`
**Create using**: Draw.io, Figma, or Mermaid
**Content**:
- ESP32 boxes (purple)
- C2 Server (green)
- Network connections
- Encryption layer
- Protocol buffers
**Usage**: Architecture page (already has Mermaid, but you can add a custom one)

#### `network-topology.svg`
**Create using**: Draw.io, Lucidchart
**Content**:
- Internet cloud
- Router/Gateway
- Multiple ESP32 agents
- C2 Server
- Traffic flows with arrows
**Usage**: Network configuration, deployment scenarios

#### `module-architecture.svg`
**Create using**: Draw.io
**Content**:
- Core layer (center)
- Modules around it (Network, Recon, FakeAP, System)
- Command registry
- Data flow arrows
**Usage**: Module documentation

---

### Wiring Diagrams

#### `lilygo-tcall-pinout.png`
**Create using**: Fritzing, KiCad, or hand-draw and scan
**Content**:
- LilyGO T-Call board layout
- Pin labels
- Power pins highlighted
- SIM card slot indicated
- Antenna connection
**Usage**: Hardware guide

#### `esp32-cam-wiring.png`
**Create using**: Fritzing
**Content**:
- ESP32-CAM connections
- FTDI programmer wiring
- GPIO0 for flash mode
- Power supply notes
**Usage**: Hardware guide, camera setup

---

### Use Case Diagrams

#### `usecase-pentest.png`
**Create using**: Draw.io, PowerPoint
**Content**:
- Pentester (laptop)
- Target network (cloud)
- ESP32 agent (deployed)
- C2 server connection
- Scan results flow
**Usage**: Use cases page, security research

#### `usecase-iot-research.png`
**Create using**: Draw.io
**Content**:
- Research lab environment
- Multiple IoT devices
- ESP32 agents monitoring
- Data collection to C2
**Usage**: Use cases page, educational content

---

## How to Add Images

### Step 1: Place Image Files

```bash
# Copy your images to
docs/assets/images/

# Example structure:
docs/assets/images/
├── logo.png
├── c2-startup.png
├── c2-device-connected.png
├── esp32-devkit.jpg
└── ...
```

### Step 2: Reference in Markdown

```markdown
# Simple image
![ESP32 DevKit](../assets/images/esp32-devkit.jpg)

# Image with caption
<figure markdown>
  ![C2 Server Startup](../assets/images/c2-startup.png)
  <figcaption>C2 Server ready and listening for agents</figcaption>
</figure>

# Sized image
![Logo](../assets/images/logo.png){ width="200" }

# Image with link
[![Click to enlarge](../assets/images/diagram.png)](../assets/images/diagram.png)
```

### Step 3: Rebuild Documentation

```bash
docker-compose -f docker-compose.docs.yml build
docker-compose -f docker-compose.docs.yml up -d
```

---

## Screenshot Tips

### Terminal Screenshots

- **Tool**: Use a terminal with good color support
- **Font**: Use a clear monospace font (Fira Code, Cascadia Code)
- **Size**: 1920x1080 or 1280x720
- **Format**: PNG for crisp text
- **Crop**: Remove unnecessary whitespace

### Hardware Photos

- **Lighting**: Use good lighting, avoid shadows
- **Background**: Plain white or black background
- **Focus**: Clear focus on the board
- **Angle**: Slight top-down angle
- **Format**: JPEG (quality 85-90%)

### Diagram Creation

- **Colors**: Use Espilon purple theme (#7c3aed)
- **Style**: Clean, modern, professional
- **Labels**: Clear, readable text
- **Export**: SVG preferred (scales), PNG as fallback
- **Size**: At least 1920px wide for diagrams

---

## Quick Reference

| Image Type | Format | Max Size | Where Used |
|------------|--------|----------|------------|
| Logo | PNG | 512x512 | Navigation, hero |
| Screenshots | PNG | 1920x1080 | All guides |
| Photos | JPG | 2048x1536 | Hardware guide |
| Diagrams | SVG/PNG | 1920x1080 | Architecture |
| Icons | PNG | 128x128 | Various |

---

## Priority List

**High Priority** (add these first):
1. ✅ `logo.png` - Your purple E logo
2. ✅ `c2-startup.png` - C2 server starting
3. ✅ `c2-device-connected.png` - Agent connection
4. ✅ `esp32-devkit.jpg` - Main hardware photo
5. ✅ `menuconfig-main.png` - Configuration screen

**Medium Priority**:
6. `command-arp-scan.png`
7. `serial-monitor.png`
8. `lilygo-tcall.jpg`
9. `flasher-gui.png`

**Low Priority** (nice to have):
10. Wiring diagrams
11. Use case diagrams
12. Additional command screenshots

---

Once you add images, I'll update the documentation to reference them!
