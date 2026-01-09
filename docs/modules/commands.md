# Command Reference

Complete reference for all Espilon commands organized by module.

!!! tip "Interactive Help"
    Type `help` in the C2 console to see available commands for connected devices.

## System Commands

Core system commands available on all devices.

### `info`

Get detailed device information.

**Usage:**
```
> device ce4f626b
> info
```

**Response:**
```json
{
  "device_id": "ce4f626b",
  "chip": "ESP32",
  "model": "ESP32-D0WDQ6",
  "cores": 2,
  "revision": 1,
  "features": ["WiFi", "BT", "BLE"],
  "flash_size": "4MB",
  "free_heap": 245760,
  "uptime": 3600
}
```

**Fields:**
- `device_id` - Unique device identifier
- `chip` - Chip model
- `cores` - Number of CPU cores
- `flash_size` - Flash memory size
- `free_heap` - Available heap memory (bytes)
- `uptime` - Uptime in seconds

---

### `stats`

Get real-time system statistics.

**Usage:**
```
> stats
```

**Response:**
```json
{
  "cpu_usage": 23,
  "mem_used": 187432,
  "mem_free": 245760,
  "tasks": 12,
  "wifi_rssi": -45,
  "network_tx": 1248576,
  "network_rx": 8372645
}
```

**Use Cases:**
- Monitor device health
- Detect memory leaks
- Check network connectivity quality

---

### `reboot`

Reboot the device.

**Usage:**
```
> reboot
```

**Response:**
```
Device rebooting...
```

!!! warning "Connection Lost"
    Device will disconnect and reconnect after ~30 seconds.

---

### `sleep <duration>`

Enter deep sleep mode to save power.

**Parameters:**
- `duration` - Sleep time in seconds (max: 3600)

**Usage:**
```
> sleep 300
```

**Response:**
```
Entering deep sleep for 300 seconds
```

**Power Consumption:**
- Active: ~160mA
- Light sleep: ~20mA
- Deep sleep: ~10µA

**Use Cases:**
- Battery-powered deployments
- Periodic surveillance
- Energy-efficient operations

---

## Network Commands

Network reconnaissance and scanning capabilities.

!!! info "Configuration Required"
    Enable in menuconfig: `Component config → Espilon Bot Configuration → Modules → Network Commands`

### `ping <target>`

ICMP ping to check host availability.

**Parameters:**
- `target` - IP address or hostname

**Usage:**
```
> ping 192.168.1.1
> ping google.com
```

**Response:**
```json
{
  "target": "192.168.1.1",
  "sent": 4,
  "received": 4,
  "loss": 0,
  "min_time": 2,
  "max_time": 5,
  "avg_time": 3
}
```

**Use Cases:**
- Network connectivity testing
- Gateway verification
- Latency measurement

---

### `arp_scan`

Scan local network via ARP requests.

**Usage:**
```
> arp_scan
```

**Response:**
```json
{
  "network": "192.168.1.0/24",
  "hosts_found": 12,
  "scan_time": 8.2,
  "hosts": [
    {
      "ip": "192.168.1.1",
      "mac": "aa:bb:cc:dd:ee:ff",
      "vendor": "Cisco Systems"
    },
    {
      "ip": "192.168.1.10",
      "mac": "11:22:33:44:55:66",
      "vendor": "Apple Inc"
    }
  ]
}
```

**Performance:**
- Scan time: ~5-10 seconds for /24 network
- Memory usage: ~2KB per host

**Use Cases:**
- Network discovery
- Active host enumeration
- Device inventory

---

### `port_scan <target> [ports]`

TCP port scanner.

**Parameters:**
- `target` - Target IP address
- `ports` - Port range (optional, default: common ports)

**Usage:**
```
> port_scan 192.168.1.1
> port_scan 192.168.1.1 1-1000
> port_scan 192.168.1.1 22,80,443,8080
```

**Response:**
```json
{
  "target": "192.168.1.1",
  "ports_scanned": 100,
  "open_ports": [
    {"port": 22, "service": "SSH"},
    {"port": 80, "service": "HTTP"},
    {"port": 443, "service": "HTTPS"}
  ],
  "scan_time": 12.4
}
```

!!! warning "Scan Speed"
    Port scanning is relatively slow on ESP32 (~100 ports/sec). Use targeted port ranges.

**Use Cases:**
- Service discovery
- Security assessment
- Network profiling

---

### `tcp_proxy <local_port> <remote_host> <remote_port>`

Create a TCP proxy tunnel.

**Parameters:**
- `local_port` - Local listening port
- `remote_host` - Remote target host
- `remote_port` - Remote target port

**Usage:**
```
> tcp_proxy 8080 10.0.0.50 80
```

**Response:**
```
TCP proxy started: 0.0.0.0:8080 -> 10.0.0.50:80
```

**Use Cases:**
- Pivot through compromised network
- Bypass firewall rules
- Network redirection

---

### `sniffer start [filter]`

Start packet sniffer in promiscuous mode.

**Parameters:**
- `filter` - Optional packet filter (tcp, udp, icmp, arp)

**Usage:**
```
> sniffer start
> sniffer start tcp
```

**Response:**
```
Packet sniffer started (filter: tcp)
Capturing on channel 6
```

**Capture Packets:**
```json
{
  "type": "TCP",
  "src": "192.168.1.10:54321",
  "dst": "93.184.216.34:443",
  "len": 1420,
  "flags": ["ACK", "PSH"]
}
```

**Stop Sniffer:**
```
> sniffer stop
```

!!! danger "Legal Warning"
    Packet sniffing may capture sensitive data. Only use in authorized environments.

---

## Recon Commands

Wireless reconnaissance and surveillance.

!!! info "Configuration Required"
    Enable in menuconfig: `Espilon Bot Configuration → Modules → Recon Commands`

### `wifi_scan`

Scan for WiFi networks.

**Usage:**
```
> wifi_scan
```

**Response:**
```json
{
  "networks_found": 18,
  "scan_time": 3.2,
  "networks": [
    {
      "ssid": "HomeNetwork",
      "bssid": "aa:bb:cc:dd:ee:ff",
      "channel": 6,
      "rssi": -42,
      "auth": "WPA2-PSK",
      "cipher": "CCMP"
    },
    {
      "ssid": "CoffeeShop_Guest",
      "bssid": "11:22:33:44:55:66",
      "channel": 11,
      "rssi": -67,
      "auth": "OPEN",
      "cipher": "NONE"
    }
  ]
}
```

**Use Cases:**
- Site survey
- WiFi mapping
- Security assessment

---

### `wifi_monitor start [channel]`

Monitor WiFi traffic (management frames).

**Parameters:**
- `channel` - WiFi channel (1-14, optional)

**Usage:**
```
> wifi_monitor start 6
```

**Captured Frames:**
```json
{
  "type": "PROBE_REQ",
  "client": "aa:bb:cc:dd:ee:ff",
  "ssid": "MyHomeWifi",
  "rssi": -56,
  "timestamp": 1234567890
}
```

**Frame Types:**
- `BEACON` - AP advertisement
- `PROBE_REQ` - Client scanning
- `PROBE_RESP` - AP response
- `ASSOC_REQ` - Connection request
- `DEAUTH` - Disconnection

**Stop Monitoring:**
```
> wifi_monitor stop
```

---

### `ble_scan [duration]`

Scan for Bluetooth Low Energy devices.

**Parameters:**
- `duration` - Scan duration in seconds (default: 10)

**Usage:**
```
> ble_scan 15
```

**Response:**
```json
{
  "devices_found": 8,
  "scan_time": 15.0,
  "devices": [
    {
      "address": "aa:bb:cc:dd:ee:ff",
      "name": "Fitness Tracker",
      "rssi": -45,
      "type": "BLE",
      "services": ["180D", "180F"]
    },
    {
      "address": "11:22:33:44:55:66",
      "name": "Smart Lock",
      "rssi": -72,
      "type": "BLE",
      "services": ["1800", "1801"]
    }
  ]
}
```

**Use Cases:**
- IoT device discovery
- Bluetooth tracking
- Device fingerprinting

---

### `cam_capture`

Capture image from ESP32-CAM module.

!!! warning "Hardware Required"
    Requires ESP32-CAM board with camera module.

**Usage:**
```
> cam_capture
```

**Response:**
```json
{
  "status": "ok",
  "resolution": "800x600",
  "size": 24576,
  "format": "JPEG",
  "url": "/download/capture_1234567890.jpg"
}
```

**Configuration:**
- Resolution: 160x120 to 1600x1200
- Format: JPEG, BMP
- Quality: 10-63 (JPEG)

---

## FakeAP Commands

Rogue access point and deauthentication.

!!! danger "Legal Warning"
    Creating rogue access points and deauthentication attacks may be illegal. Only use in authorized testing environments.

!!! info "Configuration Required"
    Enable in menuconfig: `Espilon Bot Configuration → Modules → Fake Access Point Commands`

### `fakeap start <ssid> [password]`

Start rogue access point.

**Parameters:**
- `ssid` - Network name
- `password` - WPA2 password (optional, open if not provided)

**Usage:**
```
> fakeap start FreeWiFi
> fakeap start CorpWiFi SecurePass123
```

**Response:**
```json
{
  "status": "running",
  "ssid": "FreeWiFi",
  "auth": "OPEN",
  "channel": 6,
  "ip": "192.168.4.1"
}
```

**Captive Portal:**
Clients connecting will be redirected to a captive portal page.

---

### `fakeap stop`

Stop rogue access point.

**Usage:**
```
> fakeap stop
```

---

### `fakeap_clients`

List connected clients.

**Usage:**
```
> fakeap_clients
```

**Response:**
```json
{
  "clients_count": 3,
  "clients": [
    {
      "mac": "aa:bb:cc:dd:ee:ff",
      "ip": "192.168.4.2",
      "hostname": "iPhone-John",
      "connected_time": 120
    }
  ]
}
```

---

### `deauth <target> [count]`

Send deauthentication frames.

**Parameters:**
- `target` - Target MAC address or "broadcast"
- `count` - Number of frames (default: 10)

**Usage:**
```
> deauth aa:bb:cc:dd:ee:ff 20
> deauth broadcast 5
```

**Response:**
```json
{
  "target": "aa:bb:cc:dd:ee:ff",
  "frames_sent": 20,
  "success": true
}
```

!!! danger "Legal Notice"
    Deauthentication attacks disrupt network services and may violate laws. Use only in authorized penetration testing.

---

## Group Commands

Execute commands on multiple devices simultaneously.

### `group create <name>`

Create a device group.

**Usage:**
```
> group create scanners
```

---

### `group add <name> <device_id>`

Add device to group.

**Usage:**
```
> group add scanners ce4f626b
> group add scanners a1b2c3d4
```

---

### `group exec <name> <command>`

Execute command on all devices in group.

**Usage:**
```
> group exec scanners arp_scan
> group exec scanners wifi_scan
```

**Response:**
```
Executing on 2 devices...
[ce4f626b] Command sent
[a1b2c3d4] Command sent
```

---

## Best Practices

### Command Timing

- **Scanning**: Allow 5-10 seconds between large scans
- **Monitoring**: Avoid running multiple monitors simultaneously
- **Memory**: Check `stats` regularly to monitor heap usage

### Error Handling

Commands may fail with these errors:

| Error Code | Meaning | Solution |
|------------|---------|----------|
| `TIMEOUT` | Command took too long | Reduce scan range |
| `NO_MEMORY` | Out of heap | Reboot device |
| `INVALID_PARAM` | Wrong parameters | Check command syntax |
| `NOT_SUPPORTED` | Module not enabled | Enable in menuconfig |

### Performance Tips

1. **Batch Operations** - Use groups for multiple devices
2. **Targeted Scans** - Scan specific ranges, not entire networks
3. **Memory Management** - Monitor heap, reboot if needed
4. **Network Efficiency** - Avoid flooding network with scans

---

**Previous**: [Modules](index.md) | **Next**: [Security](../security/index.md)
