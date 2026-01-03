# C2 Communication Protocol Specification

This document provides a complete technical specification of the Espilon C2 (Command & Control) communication protocol.

---

## Table of Contents

- [Overview](#overview)
- [Protocol Stack](#protocol-stack)
- [Message Format](#message-format)
- [Cryptography](#cryptography)
- [Protocol Buffers Schema](#protocol-buffers-schema)
- [Message Flow](#message-flow)
- [Connection Management](#connection-management)
- [Device Identification](#device-identification)
- [Request Correlation](#request-correlation)
- [Error Handling](#error-handling)
- [Implementation Notes](#implementation-notes)
- [Protocol Evolution](#protocol-evolution)

---

## Overview

The Espilon C2 protocol is a custom lightweight protocol designed specifically for constrained IoT devices (ESP32) with the following goals:

- **Minimal overhead**: Optimized for low RAM and bandwidth
- **Secure communication**: ChaCha20 encryption
- **Bidirectional**: Commands (C2 → ESP32) and responses (ESP32 → C2)
- **Asynchronous**: Non-blocking command execution
- **Streaming support**: Large data transfer (images, logs)
- **Simple implementation**: Easy to port to new platforms

### Design Constraints

The protocol is designed around ESP32 limitations:

- **RAM**: ~200KB free heap (after WiFi/LWIP)
- **Stack**: 3-4KB per task
- **Network**: LWIP TCP stack (no TLS by default)
- **CPU**: 160-240 MHz dual-core
- **Flash**: 4MB (binary size matters)

---

## Protocol Stack

The complete protocol stack from application to wire:

```
┌─────────────────────────────────────────────┐
│  Application Layer (Commands/Responses)     │
├─────────────────────────────────────────────┤
│  Serialization Layer (Protocol Buffers)     │
├─────────────────────────────────────────────┤
│  Encryption Layer (ChaCha20)                │
├─────────────────────────────────────────────┤
│  Encoding Layer (Base64)                    │
├─────────────────────────────────────────────┤
│  Framing Layer (Newline-delimited)          │
├─────────────────────────────────────────────┤
│  Transport Layer (TCP)                      │
├─────────────────────────────────────────────┤
│  Network Layer (IPv4)                       │
├─────────────────────────────────────────────┤
│  Link Layer (WiFi 802.11 or GPRS)          │
└─────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Purpose | Implementation |
|-------|---------|----------------|
| **Application** | Command execution, response generation | C (ESP32), Python (C2) |
| **Serialization** | Type-safe message encoding | Protocol Buffers (nanoPB) |
| **Encryption** | Confidentiality | ChaCha20 stream cipher |
| **Encoding** | Binary → ASCII | Base64 |
| **Framing** | Message delimitation | Newline (`\n`) |
| **Transport** | Reliable delivery | TCP (LWIP on ESP32) |
| **Network** | Routing | IPv4 |
| **Link** | Physical transmission | WiFi or GPRS |

---

## Message Format

### Wire Format

Messages on the wire (after all layers applied):

```
[Base64(Encrypt(Serialize(Message)))]\n
```

Example:
```
YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXpBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWjAxMjM0NTY3ODkrLw==\n
```

**Characteristics**:
- **ASCII-safe**: Base64 encoding (printable characters only)
- **Newline-delimited**: Each message ends with `\n` (0x0A)
- **Variable length**: Depends on payload size
- **Typical size**: 200-600 bytes (command), 300-800 bytes (response)

### Message Processing Pipeline

#### Sending (ESP32 → C2 or C2 → ESP32)

```c
// 1. Create message struct
c2_AgentMessage msg;
strncpy(msg.device_id, "ce4f626b", sizeof(msg.device_id));
msg.type = c2_AgentMsgType_AGENT_INFO;
strncpy(msg.source, "system", sizeof(msg.source));
// ... fill other fields

// 2. Serialize with Protocol Buffers
uint8_t pb_buffer[c2_AgentMessage_size];
pb_ostream_t stream = pb_ostream_from_buffer(pb_buffer, sizeof(pb_buffer));
pb_encode(&stream, c2_AgentMessage_fields, &msg);
size_t pb_len = stream.bytes_written;

// 3. Encrypt with ChaCha20
char *ciphertext = chacha_cd(pb_buffer, pb_len);

// 4. Base64 encode
char *b64 = base64_encode(ciphertext, pb_len);

// 5. Add newline and send
send(sock, b64, strlen(b64), 0);
send(sock, "\n", 1, 0);
```

#### Receiving

```c
// 1. Read until newline
char line_buffer[2048];
int len = read_until_newline(sock, line_buffer, sizeof(line_buffer));

// 2. Base64 decode
size_t ct_len;
char *ciphertext = base64_decode(line_buffer, &ct_len);

// 3. ChaCha20 decrypt
char *plaintext = chacha_cd(ciphertext, ct_len);

// 4. Deserialize Protocol Buffers
c2_Command cmd = c2_Command_init_zero;
pb_istream_t stream = pb_istream_from_buffer(plaintext, ct_len);
pb_decode(&stream, c2_Command_fields, &cmd);

// 5. Process command
process_command(&cmd);
```

---

## Cryptography

### ChaCha20 Stream Cipher

**Algorithm**: ChaCha20 (RFC 8439)
**Implementation**: mbedTLS library

**Parameters**:
- **Key**: 256 bits (32 bytes)
- **Nonce**: 96 bits (12 bytes)
- **Counter**: 32 bits (implicit, starts at 0)

**Configuration** (from menuconfig):
```c
#define CONFIG_CRYPTO_KEY "testde32chars0000000000000000000"  // 32 bytes
#define CONFIG_CRYPTO_NONCE "noncenonceno"  // 12 bytes
```

### Encryption Implementation

```c
char *chacha_cd(const unsigned char *data, size_t data_size)
{
    // Initialize ChaCha20 context
    mbedtls_chacha20_context ctx;
    mbedtls_chacha20_init(&ctx);

    // Set key and nonce
    unsigned char key[32] = CONFIG_CRYPTO_KEY;
    unsigned char nonce[12] = CONFIG_CRYPTO_NONCE;
    mbedtls_chacha20_setkey(&ctx, key);

    // Allocate output buffer
    char *output = malloc(data_size);

    // Encrypt/Decrypt (stream cipher is symmetric)
    mbedtls_chacha20_crypt(&ctx, nonce, 0, data_size, data, output);

    // Cleanup
    mbedtls_chacha20_free(&ctx);
    return output;
}
```

### Security Properties

**Provided**:
- Confidentiality (encryption)
- Symmetric key (same key for encrypt/decrypt)
- Stream cipher (can process any length)

**NOT Provided**:
- Authentication (no MAC)
- Integrity protection (no tamper detection)
- Forward secrecy (static key)
- Nonce uniqueness (same nonce reused)

**Security Limitations**:

See [SECURITY.md](SECURITY.md) for detailed security analysis and recommendations.

Critical issues:
1. **Static nonce** violates ChaCha20 security model
2. **No authentication** (vulnerable to tampering)
3. **Hardcoded defaults** in source code

**Recommended**:
- Upgrade to ChaCha20-Poly1305 AEAD
- Implement unique nonce per message
- Use TLS/DTLS for transport security

### Base64 Encoding

**Purpose**: Convert binary ciphertext to ASCII for reliable transmission

**Alphabet**: Standard Base64 (RFC 4648)
```
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/
```

**Padding**: `=` character (standard)

**Overhead**: 33% size increase (3 bytes → 4 characters)

**Example**:
```
Binary:  0x48 0x65 0x6C 0x6C 0x6F (Hello)
Base64:  SGVsbG8=
```

---

## Protocol Buffers Schema

Espilon uses Protocol Buffers (protobuf) for message serialization with nanoPB implementation (optimized for embedded systems).

### Schema Definition

**File**: `c2.proto`

```protobuf
syntax = "proto3";
package c2;

// Message types
enum AgentMsgType {
    AGENT_INFO = 0;        // Informational message
    AGENT_ERROR = 1;       // Error report
    AGENT_DATA = 2;        // Binary data (streaming)
    AGENT_LOG = 3;         // Log message
    AGENT_CMD_RESULT = 4;  // Command execution result
}

// Command from C2 to ESP32
message Command {
    string device_id = 1;      // Target device ID (8 hex chars)
    string command_name = 2;   // Command to execute
    repeated string argv = 3;  // Command arguments (max 8)
    string request_id = 4;     // Request correlation ID
}

// Response from ESP32 to C2
message AgentMessage {
    string device_id = 1;      // Source device ID
    AgentMsgType type = 2;     // Message type
    string source = 3;         // Source module (e.g., "system", "camera")
    string request_id = 4;     // Request correlation ID
    bytes payload = 5;         // Message payload (max 256 bytes)
    bool eof = 6;              // End-of-stream flag (for chunked data)
}
```

### nanoPB Configuration

**Limits** (configured in `c2.options`):
```
c2.Command.device_id max_size:64
c2.Command.command_name max_size:32
c2.Command.argv max_count:8 max_size:64
c2.Command.request_id max_size:64

c2.AgentMessage.device_id max_size:64
c2.AgentMessage.source max_size:32
c2.AgentMessage.request_id max_size:64
c2.AgentMessage.payload max_size:256
```

**Generated C Structures**:

```c
// Command structure
typedef struct _c2_Command {
    char device_id[64];          // Target device
    char command_name[32];       // Command name
    pb_size_t argv_count;        // Number of arguments
    char argv[8][64];            // Arguments array
    char request_id[64];         // Correlation ID
} c2_Command;

// Agent message structure
typedef struct _c2_AgentMessage {
    char device_id[64];          // Source device
    c2_AgentMsgType type;        // Message type enum
    char source[32];             // Source module
    char request_id[64];         // Correlation ID
    c2_AgentMessage_payload_t payload;  // Byte array (max 256)
    bool eof;                    // End-of-stream
} c2_AgentMessage;
```

**Size Limits**:
- **Command**: Max 683 bytes (encoded)
- **AgentMessage**: Max 426 bytes (encoded)

---

## Message Flow

### Command Execution Flow

```
┌─────┐                                      ┌─────────┐
│ C2  │                                      │  ESP32  │
└──┬──┘                                      └────┬────┘
   │                                              │
   │ 1. Send Command                              │
   │  device_id: "ce4f626b"                       │
   │  command: "system_mem"                       │
   │  request_id: "req123"                        │
   ├─────────────────────────────────────────────>│
   │                                              │
   │                                              │ 2. Decrypt & Parse
   │                                              │ 3. Execute command
   │                                              │ 4. Collect results
   │                                              │
   │ 5. Send Response                             │
   │  type: AGENT_CMD_RESULT                      │
   │  source: "system"                            │
   │  request_id: "req123"                        │
   │  payload: "Free heap: 245678"                │
   │<─────────────────────────────────────────────┤
   │                                              │
   │ 6. Display result to user                    │
   │                                              │
```

### Streaming Data Flow

For large data (e.g., camera images):

```
┌─────┐                                      ┌─────────┐
│ C2  │                                      │  ESP32  │
└──┬──┘                                      └────┬────┘
   │                                              │
   │ 1. Send Command "capture"                    │
   ├─────────────────────────────────────────────>│
   │                                              │
   │                                              │ 2. Capture image
   │                                              │ 3. Split into chunks
   │                                              │
   │ 4. Chunk 1 (eof=false)                       │
   │<─────────────────────────────────────────────┤
   │                                              │
   │ 5. Chunk 2 (eof=false)                       │
   │<─────────────────────────────────────────────┤
   │                                              │
   │ ... more chunks ...                          │
   │                                              │
   │ N. Final chunk (eof=true)                    │
   │<─────────────────────────────────────────────┤
   │                                              │
   │ Reassemble image                             │
   │                                              │
```

**Chunking**:
- Max payload per message: 256 bytes
- `eof=false` for intermediate chunks
- `eof=true` for final chunk
- Same `request_id` for all chunks

---

## Connection Management

### Connection Lifecycle

```
┌──────────────────────────────────────────────────┐
│ ESP32 Boot                                       │
└────────┬─────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────┐
│ 1. Initialize WiFi/GPRS                          │
└────────┬─────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────┐
│ 2. Obtain IP Address                             │
│    - DHCP (WiFi)                                 │
│    - PPP (GPRS)                                  │
└────────┬─────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────┐
│ 3. Connect to C2 (TCP)                           │
│    - Resolve C2 IP                               │
│    - TCP 3-way handshake                         │
└────────┬─────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────┐
│ 4. Send Initial Hello (optional)                 │
│    - Device ID                                   │
│    - Capabilities                                │
└────────┬─────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────┐
│ 5. Maintain Persistent Connection                │
│    - Send keepalive (periodic info messages)     │
│    - Receive commands                            │
│    - Send responses                              │
└────────┬─────────────────────────────────────────┘
         │
         │ (if disconnected)
         ▼
┌──────────────────────────────────────────────────┐
│ 6. Auto-Reconnect                                │
│    - Wait 5 seconds                              │
│    - Retry connection                            │
│    - Loop until success                          │
└────────┬─────────────────────────────────────────┘
         │
         └──────> Back to step 3
```

### TCP Connection Parameters

**C2 Server**:
- **Default Port**: 2626
- **Listen Address**: 0.0.0.0 (all interfaces)
- **Max Connections**: Unlimited (Python asyncio handles concurrency)

**ESP32 Client**:
- **Connection Timeout**: 10 seconds
- **Retry Interval**: 5 seconds (on failure)
- **Keepalive**: TCP keepalive enabled (OS default: 2 hours)
- **SO_REUSEADDR**: Enabled

**Socket Options** (ESP32):
```c
int keepalive = 1;
setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, &keepalive, sizeof(int));

struct timeval timeout;
timeout.tv_sec = 10;
timeout.tv_usec = 0;
setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
```

### Reconnection Logic

```c
void tcp_client_task(void *pvParameters)
{
    while (1) {
        // Attempt connection
        sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

        struct sockaddr_in dest_addr;
        dest_addr.sin_addr.s_addr = inet_addr(CONFIG_SERVER_IP);
        dest_addr.sin_family = AF_INET;
        dest_addr.sin_port = htons(CONFIG_SERVER_PORT);

        int err = connect(sock, (struct sockaddr *)&dest_addr, sizeof(dest_addr));

        if (err != 0) {
            ESP_LOGE(TAG, "Connection failed, retrying in 5s...");
            close(sock);
            vTaskDelay(pdMS_TO_TICKS(5000));
            continue;
        }

        ESP_LOGI(TAG, "Connected to C2");

        // Main communication loop
        while (1) {
            // Receive and process commands
            if (recv_and_process() < 0) {
                ESP_LOGW(TAG, "Connection lost");
                break;  // Reconnect
            }
        }

        close(sock);
    }
}
```

---

## Device Identification

### Device ID Format

Each ESP32 has a unique identifier:

**Format**: 8 hexadecimal characters (32-bit)
**Example**: `ce4f626b`, `a91dd021`

**Generation**:
```c
// Option 1: From MAC address (CRC32)
uint8_t mac[6];
esp_read_mac(mac, ESP_MAC_WIFI_STA);
uint32_t crc = crc32_le(0, mac, 6);
snprintf(device_id, 9, "%08x", crc);

// Option 2: Manual configuration
#define CONFIG_DEVICE_ID "ce4f626b"
```

**Properties**:
- **Unique**: Based on MAC address or manual assignment
- **Persistent**: Does not change across reboots
- **Short**: 8 characters for readability
- **URL-safe**: Hexadecimal characters only

### Device Registry (C2 Side)

The C2 server maintains a registry of connected devices:

```python
# Python C2 implementation
class DeviceRegistry:
    def __init__(self):
        self.devices = {}  # device_id -> Device object

    def add_device(self, device_id, connection):
        self.devices[device_id] = Device(
            id=device_id,
            connection=connection,
            connected_at=time.time(),
            last_seen=time.time(),
            ip_address=connection.getpeername()[0]
        )

    def get_device(self, device_id):
        return self.devices.get(device_id)

    def list_devices(self):
        return list(self.devices.values())
```

**Device Attributes**:
- `id`: Unique device identifier
- `connection`: TCP socket object
- `connected_at`: Connection timestamp
- `last_seen`: Last message received timestamp
- `ip_address`: Client IP address
- `metadata`: Optional (firmware version, capabilities, etc.)

---

## Request Correlation

### Request ID

The `request_id` field enables correlation between commands and responses.

**Format**: Arbitrary string (max 64 bytes)
**Common Patterns**:
- UUID: `550e8400-e29b-41d4-a716-446655440000`
- Timestamp: `1640995200000`
- Sequential: `req_0001`, `req_0002`
- Composite: `ce4f626b_1640995200_001`

### Usage Pattern

**C2 sends command**:
```python
cmd = Command(
    device_id="ce4f626b",
    command_name="ping",
    argv=["8.8.8.8", "4"],
    request_id="req_12345"  # Generated by C2
)
send_command(cmd)
```

**ESP32 processes and responds**:
```c
void handle_ping(const c2_Command *cmd)
{
    const char *request_id = cmd->request_id;

    // Execute ping...

    // Send each result with same request_id
    msg_info("network", "Reply from 8.8.8.8: time=23ms", request_id);
    msg_info("network", "Reply from 8.8.8.8: time=24ms", request_id);
    msg_info("network", "Ping complete", request_id);
}
```

**C2 receives responses**:
```python
def handle_response(msg):
    request_id = msg.request_id

    # Look up original command
    original_cmd = pending_requests.get(request_id)

    # Display response
    print(f"Response to {original_cmd}: {msg.payload}")

    # If eof=true, remove from pending
    if msg.eof:
        pending_requests.pop(request_id)
```

### Benefits

- **Async commands**: Multiple concurrent commands to different devices
- **Out-of-order responses**: Responses may arrive in any order
- **Timeout tracking**: Detect commands that never return
- **User experience**: Show which command a response belongs to

---

## Error Handling

### Error Message Format

Errors are sent as `AgentMessage` with `type=AGENT_ERROR`:

```c
msg_error("module_name", "Error description", request_id);
```

**Example**:
```c
c2_AgentMessage error_msg;
strncpy(error_msg.device_id, CONFIG_DEVICE_ID, sizeof(error_msg.device_id));
error_msg.type = c2_AgentMsgType_AGENT_ERROR;
strncpy(error_msg.source, "camera", sizeof(error_msg.source));
strncpy(error_msg.request_id, request_id, sizeof(error_msg.request_id));
strncpy(error_msg.payload.bytes, "Camera init failed", 256);
error_msg.payload.size = strlen("Camera init failed");
error_msg.eof = true;

agent_send_message(&error_msg);
```

### Common Error Scenarios

#### 1. Command Not Found

```
[ERROR] Unknown command: invalid_cmd
```

**Cause**: Command not registered in command registry
**Response**: `AGENT_ERROR` message

#### 2. Invalid Arguments

```
[ERROR] ping: Missing argument <target_ip>
```

**Cause**: Insufficient or invalid arguments
**Response**: `AGENT_ERROR` message with usage info

#### 3. Execution Failure

```
[ERROR] capture: Camera init failed
```

**Cause**: Hardware or resource error during execution
**Response**: `AGENT_ERROR` message with diagnostic info

#### 4. Decryption Failure

```
[ERROR] Failed to decrypt message
```

**Cause**: Wrong encryption key or corrupted data
**Action**: C2 logs error, no response to ESP32 (can't decrypt to get device_id)

#### 5. Connection Loss

```
[WARN] Connection lost, reconnecting...
```

**Cause**: Network interruption or C2 server restart
**Action**: ESP32 auto-reconnects after 5 seconds

### Error Codes (Optional Future Enhancement)

Currently errors are free-text strings. Future enhancement could add error codes:

```protobuf
enum ErrorCode {
    ERROR_UNKNOWN = 0;
    ERROR_INVALID_COMMAND = 1;
    ERROR_INVALID_ARGS = 2;
    ERROR_EXECUTION_FAILED = 3;
    ERROR_TIMEOUT = 4;
    ERROR_NOT_SUPPORTED = 5;
}

message AgentMessage {
    // ... existing fields ...
    ErrorCode error_code = 7;  // Optional error code
}
```

---

## Implementation Notes

### ESP32 Constraints

**Memory**:
- Protocol Buffers: ~700 bytes max per message
- Base64: +33% overhead (managed via malloc)
- ChaCha20: Minimal overhead (stream cipher)
- Total buffer: ~2KB per message (acceptable)

**Performance**:
- Protobuf encode/decode: <1ms
- ChaCha20 encrypt/decrypt: <1ms (for typical message)
- Base64 encode/decode: <1ms
- Total overhead: <5ms per message

**Concurrency**:
- Main loop: Receives commands on Core 0
- Async executor: Processes commands on Core 1 (dedicated FreeRTOS task)
- Thread-safe: Mutex-protected socket access

### C2 Server (Python)

**Architecture**:
```python
# Single-threaded async I/O
async def handle_device(reader, writer):
    while True:
        # Read line
        line = await reader.readline()

        # Decrypt and deserialize
        msg = decrypt_and_parse(line)

        # Process message
        await process_message(msg)

# Main server loop
async def main():
    server = await asyncio.start_server(handle_device, '0.0.0.0', 2626)
    await server.serve_forever()

asyncio.run(main())
```

**Benefits**:
- **Concurrent**: Handles multiple devices simultaneously
- **Non-blocking**: Async I/O prevents blocking
- **Scalable**: Can handle hundreds of devices (tested: 50+ concurrent)

### Wire Format Examples

**Command Example** (decrypted, before Base64):

```
0a 08 63 65 34 66 36 32 36 62  |  device_id: "ce4f626b"
12 0a 73 79 73 74 65 6d 5f 6d  |  command_name: "system_m"
65 6d                          |  "em"
22 07 72 65 71 31 32 33 34 35  |  request_id: "req12345"
```

**Response Example** (decrypted, before Base64):

```
0a 08 63 65 34 66 36 32 36 62  |  device_id: "ce4f626b"
10 04                          |  type: AGENT_CMD_RESULT (4)
1a 06 73 79 73 74 65 6d        |  source: "system"
22 07 72 65 71 31 32 33 34 35  |  request_id: "req12345"
2a 0f 46 72 65 65 20 68 65 61  |  payload: "Free hea"
70 3a 20 32 34 35 36 37 38     |  "p: 245678"
30 01                          |  eof: true
```

---

## Protocol Evolution

### Version 1.0 (Current)

**Features**:
- ChaCha20 encryption
- Protocol Buffers serialization
- Newline-delimited framing
- Request correlation
- Streaming support

**Limitations**:
- No authentication (implicit via encryption)
- Static nonce (security issue)
- No version negotiation
- No compression

### Planned Improvements (Version 2.0)

**Security**:
- [ ] ChaCha20-Poly1305 AEAD (authenticated encryption)
- [ ] Unique nonce per message (counter-based)
- [ ] TLS/DTLS transport layer
- [ ] Device certificate system (PKI)
- [ ] Key rotation protocol

**Features**:
- [ ] Protocol version negotiation
- [ ] Compression (zlib, for large payloads)
- [ ] Multiplexing (multiple streams per connection)
- [ ] Bidirectional streaming (real-time data)
- [ ] QoS levels (fire-and-forget, acknowledged, confirmed)

**Performance**:
- [ ] Binary framing (instead of Base64 overhead)
- [ ] Zero-copy operations
- [ ] Connection pooling (C2 side)
- [ ] Batch commands (multiple commands per message)

### Migration Strategy

**Backward Compatibility**:
- Version field in protobuf schema
- C2 and ESP32 negotiate highest common version
- Fallback to v1.0 if incompatible

**Phased Rollout**:
1. Add version field (optional in v1, required in v2)
2. Deploy v2-capable C2 (supports both v1 and v2)
3. Gradually upgrade ESP32 devices
4. Deprecate v1 after full migration

---

## Appendix: Quick Reference

### Message Types

| Type | Value | Description | Direction |
|------|-------|-------------|-----------|
| `AGENT_INFO` | 0 | Informational message | ESP32 → C2 |
| `AGENT_ERROR` | 1 | Error report | ESP32 → C2 |
| `AGENT_DATA` | 2 | Binary data (streaming) | ESP32 → C2 |
| `AGENT_LOG` | 3 | Log message | ESP32 → C2 |
| `AGENT_CMD_RESULT` | 4 | Command result | ESP32 → C2 |

### Field Limits

| Field | Max Size | Notes |
|-------|----------|-------|
| `device_id` | 64 bytes | Typically 8 hex chars |
| `command_name` | 32 bytes | e.g., "system_mem" |
| `argv` (array) | 8 items | Max 8 arguments |
| `argv` (each) | 64 bytes | Per argument |
| `request_id` | 64 bytes | UUID or custom |
| `source` | 32 bytes | Module name |
| `payload` | 256 bytes | Binary or text |

### Default Configuration

| Parameter | Default Value |
|-----------|---------------|
| C2 Port | 2626 |
| Crypto Key | `testde32chars0000000000000000000` |
| Crypto Nonce | `noncenonceno` |
| Device ID | Auto (CRC32 of MAC) |
| Reconnect Interval | 5 seconds |
| Socket Timeout | 10 seconds |

---

## References

- [Protocol Buffers](https://protobuf.dev/)
- [nanoPB](https://jpa.kapsi.fi/nanopb/)
- [ChaCha20 (RFC 8439)](https://tools.ietf.org/html/rfc8439)
- [Base64 (RFC 4648)](https://tools.ietf.org/html/rfc4648)
- [ESP-IDF LWIP](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/lwip.html)

---

**Last Updated**: 2025-12-26
**Protocol Version**: 1.0
