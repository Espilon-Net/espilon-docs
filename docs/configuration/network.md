# Network Configuration

Detailed guide for configuring Espilon's WiFi and GPRS connectivity.

## WiFi Configuration

### Basic Settings

Configure via `idf.py menuconfig`:

```
Espilon Bot Configuration → Network → WiFi Settings
```

| Setting | Description | Example |
|---------|-------------|---------|
| **SSID** | Network name | "MyWiFi" |
| **Password** | WPA/WPA2 key | "MyPassword123" |

### Supported Security

- WPA-PSK
- WPA2-PSK
- WPA3-SAE (ESP-IDF v5.0+)
- Open (no password)

**Not supported**: WPA-Enterprise, captive portals

### WiFi Range

Typical range:
- **Indoor**: 50-100m
- **Outdoor**: 300m+
- **With external antenna**: 500m+

## GPRS Configuration

### Requirements

- LilyGO T-Call board
- Active SIM card (2G data plan)
- GSM antenna connected
- PIN code disabled

### APN Configuration

Configure via `idf.py menuconfig`:

```
Espilon Bot Configuration → Network → GPRS Settings → APN
```

Common APNs:

| Carrier | Country | APN |
|---------|---------|-----|
| SFR | France | `sl2sfr` |
| Orange | France | `orange.fr` |
| Bouygues | France | `mmsbouygtel.com` |
| Free Mobile | France | `free` |
| AT&T | USA | `phone` |
| T-Mobile | USA | `fast.t-mobile.com` |
| Verizon | USA | `vzwinternet` |
| Vodafone | UK | `pp.vodafone.co.uk` |

### Network Registration

After power-on, SIM800 will:

1. Initialize modem (~5s)
2. Search for networks (~10s)
3. Register on carrier (~15s)
4. Activate GPRS (~5s)

Total time: ~30-40 seconds

### Public IP Requirement

GPRS mode requires **public IP** for C2 server:

- ✅ Public static IP
- ✅ Dynamic DNS service
- ✅ VPN with port forwarding
- ❌ Local IP (192.168.x.x)
- ❌ Carrier-grade NAT only

## Server Configuration

### C2 Server Settings

```
Espilon Bot Configuration → Server
├─ Server IP: IP address of C2
└─ Server Port: 2626 (default)
```

**WiFi Mode**: Use local or public IP
**GPRS Mode**: Must use public IP

### Port Selection

Default: `2626`

Alternative ports:
- Avoid: 80, 443, 22, 21 (common filtered ports)
- Safe: 2626, 8080, 4444, 31337

### Firewall Configuration

Ensure C2 server allows incoming connections:

```bash
# Linux (ufw)
sudo ufw allow 2626/tcp

# Linux (iptables)
sudo iptables -A INPUT -p tcp --dport 2626 -j ACCEPT

# Check if listening
netstat -tln | grep 2626
```

## Connection Process

### WiFi Mode

1. ESP32 starts WiFi
2. Scans for SSID
3. Connects with password
4. Obtains IP via DHCP
5. Connects to C2 server (TCP)
6. Performs ChaCha20 handshake

### GPRS Mode

1. ESP32 powers SIM800
2. SIM800 registers on network
3. Activates GPRS connection
4. Establishes TCP connection to C2
5. Performs ChaCha20 handshake

## Troubleshooting

### WiFi Won't Connect

**Problem**: Can't find or connect to network

**Checks**:
- SSID correct (case-sensitive)
- Password correct
- 2.4GHz network (ESP32 doesn't support 5GHz)
- Router not MAC-filtered

### GPRS Registration Failed

**Problem**: Stuck at "Registering on network"

**Checks**:
- SIM card inserted correctly
- Data plan active
- PIN code disabled
- Antenna connected
- 2G coverage available

### C2 Connection Timeout

**Problem**: Can't reach C2 server

**Checks**:
- Server IP correct
- Server running and listening
- Firewall allows port 2626
- Network connectivity (ping test)

---

**Previous**: [Menuconfig](menuconfig.md) | **Next**: [Tools](../tools/flasher.md)
