# Module API Documentation

This document provides complete API documentation for all Espilon modules, including command syntax, parameters, return values, and usage examples.

---

## Table of Contents

- [Module Overview](#module-overview)
- [System Module](#system-module)
- [Network Module](#network-module)
- [FakeAP Module](#fakeap-module)
- [Recon Module](#recon-module)
- [Creating Custom Modules](#creating-custom-modules)

---

## Module Overview

### Architecture

Espilon uses a modular command system where each module registers commands during initialization:

```c
// Module initialization
void module_init(void) {
    command_register("command_name", min_args, max_args, handler_function, context, async);
}
```

### Command Execution Flow

```
C2 sends command → ESP32 receives → Decrypt → Parse protobuf →
Command dispatcher → Lookup in registry → Execute handler →
Send response → Encrypt → C2 receives
```

### Enabling Modules

Modules are enabled/disabled at compile time via `menuconfig`:

```bash
idf.py menuconfig
# → Espilon Configuration → Module Selection
```

---

## System Module

**Component**: `mod_system`
**Files**: `espilon_bot/components/mod_system/cmd_system.c`
**Dependencies**: Core, FreeRTOS
**Async**: No (synchronous execution)

Basic device management and diagnostics.

### Commands

#### `system_reboot`

Reboots the ESP32 device.

**Syntax**:
```
system_reboot
```

**Parameters**: None

**Example**:
```bash
# From C2
c3po> send ce4f626b system_reboot

# Response
[*] Device ce4f626b rebooting...
[+] Device ce4f626b reconnected (uptime: 0s)
```

**Return**: Device disconnects and reconnects after ~3-5 seconds

**Use Cases**:
- Apply configuration changes
- Reset device state
- Recover from errors

---

#### `system_mem`

Reports heap memory statistics.

**Syntax**:
```
system_mem
```

**Parameters**: None

**Response Format**:
```json
{
  "free_heap": 245678,
  "min_free_heap": 201234,
  "largest_free_block": 113792
}
```

**Example**:
```bash
c3po> send ce4f626b system_mem

# Response
[<] ce4f626b:
    Free heap: 245678 bytes
    Min free heap ever: 201234 bytes
    Largest free block: 113792 bytes
```

**Fields**:
- `free_heap`: Current available heap memory (bytes)
- `min_free_heap`: Minimum heap since boot (detect memory leaks)
- `largest_free_block`: Largest contiguous block (fragmentation indicator)

**Use Cases**:
- Monitor memory usage
- Detect memory leaks
- Diagnose crashes (out of memory)

---

#### `system_uptime`

Reports device uptime since last boot.

**Syntax**:
```
system_uptime
```

**Parameters**: None

**Response Format**:
```
Uptime: XXh XXm XXs
```

**Example**:
```bash
c3po> send ce4f626b system_uptime

# Response
[<] ce4f626b: Uptime: 2h 34m 12s
```

**Use Cases**:
- Verify device stability
- Track reboots
- Correlation with logs

---

## Network Module

**Component**: `mod_network`
**Files**:
- `cmd_network.c` (main commands)
- `mod_ping.c` (ICMP ping)
- `mod_arp.c` (ARP scanner)
- `mod_proxy.c` (TCP proxy)
- `mod_dos.c` (traffic generation)

**Dependencies**: Core, LWIP, ESP WiFi
**Async**: Yes (most commands run asynchronously)

Advanced network reconnaissance and manipulation tools.

### Commands

#### `ping`

Sends ICMP echo requests to a target IP address.

**Syntax**:
```
ping <target_ip> [count] [interval_ms]
```

**Parameters**:
- `target_ip` (required): Destination IP address (e.g., "8.8.8.8")
- `count` (optional): Number of pings (default: 4, max: 100)
- `interval_ms` (optional): Delay between pings in milliseconds (default: 1000)

**Response Format**:
```
Reply from <ip>: icmp_seq=<n> ttl=<ttl> time=<ms>ms
```

**Example**:
```bash
# Basic ping
c3po> send ce4f626b ping 8.8.8.8

# Response
[<] ce4f626b:
    Reply from 8.8.8.8: icmp_seq=1 ttl=57 time=23ms
    Reply from 8.8.8.8: icmp_seq=2 ttl=57 time=24ms
    Reply from 8.8.8.8: icmp_seq=3 ttl=57 time=22ms
    Reply from 8.8.8.8: icmp_seq=4 ttl=57 time=23ms
    --- 8.8.8.8 ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss

# Custom count and interval
c3po> send ce4f626b ping 192.168.1.1 10 500
```

**Use Cases**:
- Test network connectivity
- Measure latency
- Detect packet loss
- Network path verification

**Implementation**: Uses LWIP raw sockets (IPPROTO_ICMP)

---

#### `arp_scan`

Scans local network for active hosts using ARP requests.

**Syntax**:
```
arp_scan <network_cidr>
```

**Parameters**:
- `network_cidr` (required): Network in CIDR notation (e.g., "192.168.1.0/24")

**Response Format** (JSON stream):
```json
{"ip": "192.168.1.1", "mac": "aa:bb:cc:dd:ee:ff", "vendor": "Unknown"}
{"ip": "192.168.1.42", "mac": "11:22:33:44:55:66", "vendor": "Unknown"}
...
{"eof": true, "total": 15}
```

**Example**:
```bash
c3po> send ce4f626b arp_scan 192.168.1.0/24

# Response (streamed)
[<] ce4f626b:
    {"ip": "192.168.1.1", "mac": "00:11:22:33:44:55"}
    {"ip": "192.168.1.5", "mac": "aa:bb:cc:dd:ee:ff"}
    {"ip": "192.168.1.42", "mac": "12:34:56:78:9a:bc"}
    ...
    {"eof": true, "total": 15}
```

**Parameters**:
- Batch size: 5 IPs at a time (to avoid flooding)
- Timeout: 100ms per IP
- Max scan: /24 subnet (254 hosts)

**Use Cases**:
- Network discovery
- Identify active devices
- Detect new devices joining network
- Network mapping

**Performance**:
- /24 scan: ~30-60 seconds
- Results streamed in real-time

**Implementation**: Uses LWIP etharp layer directly

---

#### `proxy_start`

Starts a TCP reverse proxy/forwarder.

**Syntax**:
```
proxy_start <listen_port> <target_ip> <target_port>
```

**Parameters**:
- `listen_port` (required): Local port to listen on (1024-65535)
- `target_ip` (required): Destination IP to forward to
- `target_port` (required): Destination port

**Example**:
```bash
# Forward local port 8080 to remote server
c3po> send ce4f626b proxy_start 8080 192.168.1.100 80

# Response
[<] ce4f626b: Proxy started: 0.0.0.0:8080 → 192.168.1.100:80

# Now any connection to ESP32:8080 forwards to 192.168.1.100:80
```

**Use Cases**:
- Traffic tunneling
- Port forwarding through firewall
- Protocol analysis (man-in-the-middle testing in authorized environments)
- Access internal services

**Limitations**:
- Single concurrent connection (lightweight implementation)
- TCP only (no UDP)
- No encryption (plaintext forwarding)

**Security Note**: For authorized testing only. Ensure you have permission for any MITM scenarios.

---

#### `proxy_stop`

Stops the running proxy server.

**Syntax**:
```
proxy_stop
```

**Parameters**: None

**Example**:
```bash
c3po> send ce4f626b proxy_stop

# Response
[<] ce4f626b: Proxy stopped
```

---

#### `dos_tcp`

Generates TCP traffic for controlled testing scenarios.

**Syntax**:
```
dos_tcp <target_ip> <target_port> <packet_count>
```

**Parameters**:
- `target_ip` (required): Target IP address
- `target_port` (required): Target port
- `packet_count` (required): Number of packets to send (max: 10000)

**Example**:
```bash
# Send 100 TCP packets for testing
c3po> send ce4f626b dos_tcp 192.168.1.100 80 100

# Response
[<] ce4f626b: Sent 100 packets to 192.168.1.100:80
```

**Use Cases**:
- **Authorized stress testing only**
- Load testing of own servers
- Network resilience testing
- QoS testing

**WARNING**:
- For authorized testing only
- Ensure you have explicit permission
- Unauthorized use is illegal
- Not intended for malicious DoS attacks

**Rate Limiting**: Intentionally throttled to prevent abuse

---

## FakeAP Module

**Component**: `mod_fakeAP`
**Files**:
- `cmd_fakeAP.c` (main commands)
- `mod_fakeAP.c` (AP logic)
- `mod_web_server.c` (HTTP server)
- `mod_netsniff.c` (packet sniffer)

**Dependencies**: Core, ESP WiFi, LWIP, ESP HTTP Server
**Async**: Yes

Wireless manipulation capabilities for authorized security testing.

### Commands

#### `fakeap_start`

Creates a fake wireless access point.

**Syntax**:
```
fakeap_start <ssid> [password] [channel]
```

**Parameters**:
- `ssid` (required): Network name (1-32 characters)
- `password` (optional): WPA2 password (8-63 characters, or omit for open network)
- `channel` (optional): WiFi channel 1-13 (default: 6)

**Example**:
```bash
# Open network (no password)
c3po> send ce4f626b fakeap_start "Free WiFi"

# WPA2 secured
c3po> send ce4f626b fakeap_start "Corporate WiFi" "SecurePass123" 11

# Response
[<] ce4f626b: FakeAP started
    SSID: Free WiFi
    Password: [open]
    Channel: 6
    IP: 192.168.4.1
    Mode: AP+STA (NAPT enabled)
```

**Network Configuration**:
- **AP IP**: 192.168.4.1 (default)
- **DHCP Range**: 192.168.4.2 - 192.168.4.254
- **Subnet Mask**: 255.255.255.0
- **Gateway**: 192.168.4.1 (ESP32)
- **DNS**: 192.168.4.1 (hijacked if using portal)

**Features**:
- **AP+STA Mode**: ESP32 maintains connection to real network while hosting fake AP
- **NAPT Routing**: Clients can access internet through ESP32
- **Client Tracking**: Monitors connected devices (max 10)
- **Session Management**: Tracks authenticated vs unauthenticated clients

**Use Cases** (authorized testing only):
- WiFi security awareness training
- Rogue AP detection testing
- Client behavior analysis
- Security research

**WARNING**:
- For authorized security testing only
- Creating rogue APs without permission is illegal
- Ensure compliance with local regulations

---

#### `portal_start`

Starts a captive portal with DNS hijacking.

**Syntax**:
```
portal_start [html_content]
```

**Parameters**:
- `html_content` (optional): Custom HTML for landing page (max 2048 bytes)
  - If omitted, uses default template

**Example**:
```bash
# Start with default portal page
c3po> send ce4f626b portal_start

# Custom HTML (simple example)
c3po> send ce4f626b portal_start "<h1>WiFi Login</h1><p>Please enter credentials...</p>"

# Response
[<] ce4f626b: Captive portal started
    Portal IP: 192.168.4.1
    DNS: All queries → 192.168.4.1
    HTTP Server: :80
```

**How It Works**:

1. **DNS Hijacking**: All DNS queries return 192.168.4.1
2. **HTTP Redirect**: All HTTP requests show portal page
3. **HTTPS Note**: HTTPS sites will show certificate error (expected)
4. **Client Capture**: Logs all connection attempts

**Default Portal Page Includes**:
- Network SSID
- Connection instructions
- Login form (credentials logged)
- Device information collection

**Captured Data**:
- Client MAC addresses
- User-Agent strings
- Form submissions
- Connection timestamps

**Example Output**:
```
[<] ce4f626b: Client connected
    MAC: aa:bb:cc:dd:ee:ff
    User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 15_0...)
    Requested: www.apple.com/library/test/success.html
```

**Use Cases** (authorized testing only):
- Security awareness training
- Credential phishing simulations (for training)
- Client behavior research
- Captive portal bypass testing

**WARNING**:
- Extremely sensitive functionality
- For authorized educational/research purposes only
- Capturing credentials without permission is illegal
- Ensure explicit authorization and informed consent

---

#### `sniffer_start`

Starts 802.11 packet capture in monitor mode.

**Syntax**:
```
sniffer_start [channel] [duration_sec]
```

**Parameters**:
- `channel` (optional): WiFi channel to monitor (1-13, default: current channel)
- `duration_sec` (optional): Capture duration in seconds (default: 60, max: 3600)

**Example**:
```bash
# Sniff current channel for 60 seconds
c3po> send ce4f626b sniffer_start

# Sniff channel 6 for 120 seconds
c3po> send ce4f626b sniffer_start 6 120

# Response (streamed packet data)
[<] ce4f626b: Sniffer started on channel 6
[<] Beacon: SSID="MyNetwork" BSSID=aa:bb:cc:dd:ee:ff RSSI=-45
[<] Probe Req: Device=11:22:33:44:55:66 for "Home WiFi"
[<] Data: aa:bb:cc:dd:ee:ff → 11:22:33:44:55:66 (encrypted)
...
```

**Captured Packet Types**:
- **Beacon Frames**: AP advertisements
- **Probe Requests**: Client network searches
- **Probe Responses**: AP responses
- **Association Requests/Responses**
- **Data Frames** (metadata only, payload encrypted)
- **Deauthentication Frames**

**Output Format** (JSON):
```json
{
  "type": "beacon",
  "ssid": "NetworkName",
  "bssid": "aa:bb:cc:dd:ee:ff",
  "channel": 6,
  "rssi": -45,
  "timestamp": 1234567890
}
```

**Use Cases** (authorized testing only):
- Network discovery
- Channel analysis
- Client tracking
- Security audit of own network
- 802.11 protocol research

**Limitations**:
- Cannot decrypt WPA2 traffic without keys
- Monitor mode disables normal WiFi operation
- Captures metadata only (MAC addresses, SSIDs, frame types)

**Performance**:
- Buffer size: 1024 bytes per packet
- Max capture rate: ~100 packets/sec
- Data streamed to C2 in real-time

**WARNING**:
- For authorized testing only
- Passive sniffing may still be subject to legal restrictions
- Ensure compliance with local wiretapping laws

---

#### `fakeap_stop`

Stops FakeAP, captive portal, and sniffer. Restores normal STA mode.

**Syntax**:
```
fakeap_stop
```

**Parameters**: None

**Example**:
```bash
c3po> send ce4f626b fakeap_stop

# Response
[<] ce4f626b: FakeAP stopped
    Disconnected clients: 3
    Restored STA mode
    Reconnected to: RealNetwork (192.168.1.42)
```

**Cleanup Actions**:
- Disconnects all AP clients
- Stops DNS hijacking
- Stops HTTP server
- Disables monitor mode (if active)
- Restores normal WiFi STA connection

---

## Recon Module

**Component**: `mod_recon`
**Files**:
- `mod_cam.c` (ESP32-CAM)
- `mod_trilat.c` (BLE trilateration - WIP)

**Dependencies**: Core, ESP32-Camera, ESP HTTP Client
**Async**: Yes

Reconnaissance and data collection capabilities.

### Camera Mode

Requires **ESP32-CAM** hardware with PSRAM.

#### `capture`

Captures a single JPEG image.

**Syntax**:
```
capture [quality]
```

**Parameters**:
- `quality` (optional): JPEG quality 0-63 (lower = better, default: 20)

**Example**:
```bash
c3po> send ce4f626b capture

# Response (binary JPEG data streamed)
[<] ce4f626b: Capturing image...
[<] ce4f626b: Image size: 15234 bytes
[<] [JPEG binary data in chunks...]
[<] ce4f626b: Capture complete
```

**Image Specifications**:
- **Resolution**: QQVGA (160x120) default
- **Format**: JPEG
- **Quality**: Configurable (0-63, lower = larger file/better quality)
- **Max Size**: ~20-50 KB (depends on scene complexity and quality)

**Data Transfer**:
- Chunked streaming (256 bytes per message)
- Base64 encoded
- ChaCha20 encrypted

**Use Cases**:
- Visual reconnaissance
- Remote monitoring
- Facial recognition (with post-processing)
- Situational awareness

**Performance**:
- Capture time: ~200-500ms
- Transfer time: ~2-5 seconds (depends on network)

---

#### `stream_start`

Starts UDP video streaming.

**Syntax**:
```
stream_start <target_ip> <target_port> [fps]
```

**Parameters**:
- `target_ip` (required): Destination IP for UDP stream
- `target_port` (required): Destination port
- `fps` (optional): Frames per second (default: 10, max: 30)

**Example**:
```bash
# Stream to C2 server at 10 FPS
c3po> send ce4f626b stream_start 192.168.1.100 5000 10

# Response
[<] ce4f626b: Streaming started
    Target: 192.168.1.100:5000
    FPS: 10
    Resolution: 160x120
    Format: JPEG

# UDP packets sent to target:5000 continuously
```

**Stream Format**:
```
Packet structure:
  [4 bytes: token "Sup3rS3cretT0k3n"]
  [4 bytes: sequence number]
  [4 bytes: total chunks]
  [2 bytes: chunk index]
  [N bytes: JPEG data chunk]
```

**Packet Size**: Max 2034 bytes per UDP packet

**Receiving Stream** (Python example):
```python
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(('0.0.0.0', 5000))

while True:
    data, addr = sock.recvfrom(2048)
    # Parse and reassemble JPEG chunks
    # Display frames...
```

**Use Cases**:
- Live video surveillance
- Remote monitoring
- Motion detection
- Event recording

**Performance**:
- Bandwidth: ~50-100 Kbps (10 FPS at QQVGA)
- Latency: ~200-500ms
- Packet loss: Affects frame quality (no retransmission)

**Limitations**:
- UDP only (no TCP)
- No encryption on stream (only authentication token)
- Low resolution (QQVGA for bandwidth constraints)

---

#### `stream_stop`

Stops video streaming.

**Syntax**:
```
stream_stop
```

**Parameters**: None

**Example**:
```bash
c3po> send ce4f626b stream_stop

# Response
[<] ce4f626b: Streaming stopped
    Total frames sent: 1234
    Duration: 123s
    Average FPS: 10.0
```

---

### BLE Trilateration Mode

**Status**: Work in Progress (disabled in current build)

**Purpose**: Position estimation using Bluetooth Low Energy RSSI measurements from multiple ESP32 nodes.

**Planned Commands**:

#### `trilat_scan` (WIP)

Scan for BLE devices and measure RSSI.

**Syntax** (planned):
```
trilat_scan <duration_sec>
```

**Output** (planned):
```json
{
  "device": "aa:bb:cc:dd:ee:ff",
  "rssi": -67,
  "timestamp": 1234567890
}
```

#### `trilat_locate` (WIP)

Estimate position using collaborative data from multiple ESP32 agents.

**Requirements**:
- At least 3 ESP32 nodes at known positions
- Simultaneous RSSI measurements
- Centralized trilateration algorithm

---

## Creating Custom Modules

### Module Structure

Each module follows this structure:

```
espilon_bot/components/
└── mod_yourmodule/
    ├── CMakeLists.txt
    ├── Kconfig
    ├── cmd_yourmodule.c
    └── mod_yourmodule.h
```

### Step 1: Create CMakeLists.txt

```cmake
idf_component_register(
    SRCS "cmd_yourmodule.c"
    INCLUDE_DIRS "."
    REQUIRES core command esp_timer
)
```

### Step 2: Create Kconfig

```kconfig
menu "Your Module Configuration"
    depends on MODULE_YOURMODULE

    config YOURMODULE_SETTING
        int "Your setting"
        default 100
        help
            Description of your setting.

endmenu
```

### Step 3: Implement Commands

```c
#include "command.h"
#include "utils.h"
#include "esp_log.h"

#define TAG "YOURMODULE"

// Command handler
static int your_command_handler(int argc, char **argv, const char *request_id, void *ctx)
{
    // Validate arguments
    if (argc < 1) {
        msg_error(TAG, "Missing argument", request_id);
        return -1;
    }

    // Your logic here
    const char *param = argv[0];
    ESP_LOGI(TAG, "Processing: %s", param);

    // Send response
    msg_info(TAG, "Command completed successfully", request_id);
    return 0;
}

// Module initialization
void yourmodule_init(void)
{
    // Register commands
    command_register(
        "your_command",     // Command name
        1,                  // Min arguments
        5,                  // Max arguments
        your_command_handler,
        NULL,               // Optional context
        false               // Async = false (sync execution)
    );

    ESP_LOGI(TAG, "Module initialized");
}
```

### Step 4: Register Module

**In `espilon_bot/main/CMakeLists.txt`**:
```cmake
set(components
    core
    command
    mod_system
    mod_yourmodule  # Add your module
)
```

**In `espilon_bot/main/bot-lwip.c`**:
```c
#ifdef CONFIG_MODULE_YOURMODULE
extern void yourmodule_init(void);
#endif

void app_main(void)
{
    // ... existing init code ...

    #ifdef CONFIG_MODULE_YOURMODULE
    yourmodule_init();
    #endif

    // ... rest of code ...
}
```

### Step 5: Add to Menuconfig

**In `espilon_bot/main/Kconfig`**:
```kconfig
menu "Module Selection"

    config MODULE_YOURMODULE
        bool "Enable Your Module"
        default n
        help
            Enable your custom module.

endmenu
```

### Async Command Example

For long-running operations:

```c
static int async_task_handler(int argc, char **argv, const char *request_id, void *ctx)
{
    msg_info(TAG, "Starting long task...", request_id);

    // Long operation
    for (int i = 0; i < 100; i++) {
        // Do work
        vTaskDelay(pdMS_TO_TICKS(100));

        // Send progress updates
        char progress[64];
        snprintf(progress, sizeof(progress), "Progress: %d%%", i);
        msg_info(TAG, progress, request_id);
    }

    msg_info(TAG, "Task completed", request_id);
    return 0;
}

void yourmodule_init(void)
{
    command_register(
        "long_task",
        0,
        0,
        async_task_handler,
        NULL,
        true  // Async = true (runs in dedicated task)
    );
}
```

### Best Practices

1. **Validate Input**: Always check argc and argv
2. **Use request_id**: Pass it to all msg_* functions for correlation
3. **Error Handling**: Use msg_error() for failures
4. **Memory Management**: Free allocated memory
5. **Thread Safety**: Use mutexes for shared state
6. **Logging**: Use ESP_LOG* macros
7. **Async for Heavy Work**: Use async=true for operations > 100ms

---

## Appendix: Command Quick Reference

### System Module
| Command | Args | Async | Description |
|---------|------|-------|-------------|
| `system_reboot` | 0 | No | Reboot device |
| `system_mem` | 0 | No | Memory statistics |
| `system_uptime` | 0 | No | Device uptime |

### Network Module
| Command | Args | Async | Description |
|---------|------|-------|-------------|
| `ping` | 1-3 | Yes | ICMP ping |
| `arp_scan` | 1 | Yes | ARP network scan |
| `proxy_start` | 3 | Yes | Start TCP proxy |
| `proxy_stop` | 0 | Yes | Stop proxy |
| `dos_tcp` | 3 | Yes | TCP traffic generation |

### FakeAP Module
| Command | Args | Async | Description |
|---------|------|-------|-------------|
| `fakeap_start` | 1-3 | Yes | Start rogue AP |
| `portal_start` | 0-1 | Yes | Start captive portal |
| `sniffer_start` | 0-2 | Yes | Start packet sniffer |
| `fakeap_stop` | 0 | Yes | Stop all AP functions |

### Recon Module (Camera)
| Command | Args | Async | Description |
|---------|------|-------|-------------|
| `capture` | 0-1 | Yes | Capture JPEG image |
| `stream_start` | 2-3 | Yes | Start UDP video stream |
| `stream_stop` | 0 | Yes | Stop streaming |

---

**Last Updated**: 2025-12-26
