# Architecture Documentation

This document provides a comprehensive overview of Espilon's architecture, design decisions, and internal workings.

---

## Table of Contents

- [System Overview](#system-overview)
- [Firmware Architecture](#firmware-architecture)
- [C2 Server Architecture](#c2-server-architecture)
- [Component Design](#component-design)
- [Data Flow](#data-flow)
- [Concurrency Model](#concurrency-model)
- [Memory Management](#memory-management)
- [Network Stack](#network-stack)
- [Design Patterns](#design-patterns)
- [Performance Considerations](#performance-considerations)
- [Future Architecture](#future-architecture)

---

## System Overview

### High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      Cloud / Internet                        │
└───────────────────────────┬──────────────────────────────────┘
                            │
                            │ TCP (encrypted)
                            │
┌───────────────────────────▼──────────────────────────────────┐
│                    C2 Server (Python)                        │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  CLI Interface (Interactive)                           │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │  Device Registry │ Group Manager │ Command Router     │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │  Crypto (ChaCha20) │ Protobuf │ Base64               │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │  TCP Server (asyncio)                                  │  │
│  └────────────────────────────────────────────────────────┘  │
└───────────────────────────┬──────────────────────────────────┘
                            │
                            │ WiFi / GPRS
                            │
         ┌──────────────────┼──────────────────┐
         │                  │                  │
    ┌────▼─────┐       ┌───▼──────┐      ┌───▼──────┐
    │  ESP32   │       │  ESP32   │      │  ESP32   │
    │ Device 1 │       │ Device 2 │      │ Device N │
    └──────────┘       └──────────┘      └──────────┘
```

### Component Breakdown

**C2 Server (Python)**:
- **Role**: Command & Control server
- **Language**: Python 3.8+
- **Framework**: asyncio (async I/O)
- **Responsibilities**:
  - Accept TCP connections from ESP32 devices
  - Maintain device registry
  - Route commands to appropriate devices
  - Manage device groups
  - Provide CLI interface for operators

**ESP32 Agents (C/ESP-IDF)**:
- **Role**: Embedded agents
- **Language**: C
- **Framework**: ESP-IDF 5.3.2 + FreeRTOS
- **Responsibilities**:
  - Connect to C2 server (WiFi or GPRS)
  - Execute commands locally
  - Send responses and data back to C2
  - Manage local modules (network, fakeap, recon, etc.)

---

## Firmware Architecture

### Layered Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                        │
│  ┌─────────────┐  ┌────────────┐  ┌──────────────────────┐ │
│  │  mod_system │  │ mod_network│  │ mod_fakeAP / recon   │ │
│  └─────────────┘  └────────────┘  └──────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                     Command Layer                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Command Registry │ Command Dispatcher │ Async Exec │  │
│  └──────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                       Core Layer                            │
│  ┌──────────┐ ┌────────────┐ ┌─────────┐ ┌──────────────┐ │
│  │  COM     │ │  Crypto    │ │ Messages│ │  Process     │ │
│  │ (WiFi/   │ │ (ChaCha20) │ │ (Protob)│ │  (Dispatch)  │ │
│  │  GPRS)   │ │            │ │         │ │              │ │
│  └──────────┘ └────────────┘ └─────────┘ └──────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                   ESP-IDF Components                        │
│  ┌───────┐ ┌─────────┐ ┌──────────┐ ┌────────────────────┐ │
│  │ LWIP  │ │ mbedTLS │ │ FreeRTOS │ │ ESP WiFi / UART    │ │
│  └───────┘ └─────────┘ └──────────┘ └────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                      Hardware (ESP32)                       │
│  WiFi Radio │ CPU (Dual-Core) │ RAM │ Flash │ Peripherals  │
└─────────────────────────────────────────────────────────────┘
```

### Main Components

#### 1. Core Component

**Location**: `espilon_bot/components/core/`

**Files**:
- `com.c` - Communication abstraction layer
- `WiFi.c` - WiFi backend implementation
- `gprs.c` - GPRS backend implementation
- `crypto.c` - ChaCha20 encryption/decryption
- `messages.c` - Message helper functions
- `process.c` - Command processing and dispatch
- `utils.h` - Shared utilities and headers

**Responsibilities**:
- Network connection management (WiFi or GPRS)
- Persistent TCP connection to C2
- Encryption/decryption (ChaCha20 + Base64)
- Protocol Buffers serialization/deserialization
- Command parsing and dispatching
- Response generation and sending

**Key Functions**:
```c
// Communication initialization
bool com_init(void);

// Crypto operations
char *chacha_cd(const unsigned char *data, size_t data_size);
char *base64_encode(const unsigned char *input, size_t input_len);
char *base64_decode(const char *input, size_t *output_len);

// Message sending
bool agent_send(c2_AgentMsgType type, const char *source,
                const char *request_id, const void *data,
                size_t len, bool eof);

// Convenience wrappers
bool msg_info(const char *src, const char *msg, const char *req);
bool msg_error(const char *src, const char *msg, const char *req);
bool msg_data(const char *src, const void *data, size_t len,
              bool eof, const char *req);

// Command processing
void process_command(const c2_Command *cmd);
```

#### 2. Command Component

**Location**: `espilon_bot/components/command/`

**Files**:
- `command.c` - Command registry and dispatcher
- `command_async.c` - Asynchronous command execution
- `command.h` - Public API

**Responsibilities**:
- Command registration (during module init)
- Command lookup by name
- Argument validation
- Synchronous vs asynchronous dispatch
- Async task management (FreeRTOS)

**Command Registration**:
```c
// Command handler signature
typedef int (*command_handler_t)(int argc, char **argv,
                                  const char *request_id,
                                  void *ctx);

// Command structure
typedef struct {
    const char *name;              // Command name
    int min_args;                  // Minimum arguments
    int max_args;                  // Maximum arguments
    command_handler_t handler;     // Handler function
    void *ctx;                     // Optional context
    bool async;                    // Async execution flag
} command_t;

// Register command
void command_register(const char *name, int min_args, int max_args,
                      command_handler_t handler, void *ctx, bool async);

// Process command (called from core)
void command_process_pb(const c2_Command *cmd_pb);
```

**Registry Design**:
- Static array of 32 command slots
- Linear search (acceptable for small number of commands)
- Registered during module initialization
- Thread-safe (commands registered before multi-threading starts)

**Async Execution**:
```c
// Async worker task (runs on Core 1)
void command_async_task(void *pvParameters)
{
    async_cmd_t cmd;
    while (1) {
        // Wait for command in queue
        if (xQueueReceive(async_queue, &cmd, portMAX_DELAY)) {
            // Execute handler
            cmd.handler(cmd.argc, cmd.argv, cmd.request_id, cmd.ctx);

            // Free resources
            command_async_free(&cmd);
        }
    }
}
```

**Queue Design**:
- FreeRTOS queue (max 10 pending commands)
- FIFO order
- Dedicated task on Core 1 for execution
- Core 0 handles network I/O, Core 1 handles command execution

#### 3. Module Components

**System Module** (`mod_system`):
- Basic diagnostics (reboot, memory, uptime)
- Always enabled
- Synchronous execution

**Network Module** (`mod_network`):
- ICMP ping (raw sockets)
- ARP scanner (LWIP etharp)
- TCP proxy (socket forwarding)
- Traffic generation (testing)
- Asynchronous execution

**FakeAP Module** (`mod_fakeAP`):
- Rogue access point (AP+STA mode)
- Captive portal (DNS hijack + HTTP server)
- Packet sniffer (monitor mode)
- Client tracking
- Asynchronous execution

**Recon Module** (`mod_recon`):
- ESP32-CAM support (capture, streaming)
- BLE trilateration (WIP)
- Asynchronous execution

---

## C2 Server Architecture

### Architecture Pattern

**Pattern**: Asynchronous I/O with event loop (asyncio)

```
┌────────────────────────────────────────────────┐
│             Main Event Loop (asyncio)          │
│  ┌──────────────────────────────────────────┐  │
│  │  TCP Server (port 2626)                  │  │
│  └───┬──────────────────────────────────────┘  │
│      │                                          │
│      │  (For each connection)                   │
│      ▼                                          │
│  ┌──────────────────────────────────────────┐  │
│  │  Device Handler (coroutine)              │  │
│  │  ┌────────────────────────────────────┐  │  │
│  │  │ 1. Accept connection               │  │  │
│  │  │ 2. Read line (await readline())    │  │  │
│  │  │ 3. Decrypt & parse                 │  │  │
│  │  │ 4. Process message                 │  │  │
│  │  │ 5. Update registry                 │  │  │
│  │  │ 6. Loop                            │  │  │
│  │  └────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │  CLI Interface (user input)              │  │
│  │  ┌────────────────────────────────────┐  │  │
│  │  │ 1. Read command                    │  │  │
│  │  │ 2. Parse (tab completion)          │  │  │
│  │  │ 3. Execute (send, list, etc.)      │  │  │
│  │  │ 4. Display result                  │  │  │
│  │  └────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────┘  │
└────────────────────────────────────────────────┘
```

### Directory Structure

```
tools/c2/
├── c3po.py                  # Main entry point
├── core/                    # Core modules
│   ├── __init__.py
│   ├── device.py            # Device data model
│   ├── registry.py          # Device registry
│   ├── crypto.py            # Encryption (ChaCha20)
│   ├── transport.py         # TCP socket handling
│   └── groups.py            # Device group management
├── commands/                # Command plugins
│   ├── __init__.py
│   ├── base.py              # Command base class
│   ├── registry.py          # Command registry
│   └── reboot.py            # Example command plugin
├── cli/                     # CLI interface
│   ├── __init__.py
│   ├── cli.py               # Interactive CLI
│   └── help.py              # Help system
├── proto/                   # Protocol Buffers
│   ├── __init__.py
│   └── c2_pb2.py            # Generated protobuf
└── requirements.txt         # Python dependencies
```

### Key Components

#### Device Registry

```python
class DeviceRegistry:
    """Central registry of connected devices."""

    def __init__(self):
        self._devices: Dict[str, Device] = {}
        self._lock = asyncio.Lock()

    async def add_device(self, device: Device):
        async with self._lock:
            self._devices[device.id] = device
            logging.info(f"Device connected: {device.id}")

    async def remove_device(self, device_id: str):
        async with self._lock:
            if device_id in self._devices:
                del self._devices[device_id]
                logging.info(f"Device disconnected: {device_id}")

    async def get_device(self, device_id: str) -> Optional[Device]:
        async with self._lock:
            return self._devices.get(device_id)

    async def list_devices(self) -> List[Device]:
        async with self._lock:
            return list(self._devices.values())
```

**Thread Safety**: Uses asyncio.Lock for concurrent access

#### Command Plugin System

```python
class CommandBase:
    """Base class for C2 commands."""

    name: str               # Command name
    help_text: str          # Help description
    usage: str              # Usage syntax

    async def execute(self, args: List[str]) -> None:
        """Execute the command."""
        raise NotImplementedError

# Example plugin
class RebootCommand(CommandBase):
    name = "reboot"
    help_text = "Reboot a device"
    usage = "reboot <device_id>"

    async def execute(self, args: List[str]) -> None:
        if len(args) < 1:
            print(f"Usage: {self.usage}")
            return

        device_id = args[0]
        device = await registry.get_device(device_id)
        if not device:
            print(f"Device not found: {device_id}")
            return

        # Send reboot command
        cmd = create_command(device_id, "system_reboot", [])
        await device.send_command(cmd)
        print(f"Reboot command sent to {device_id}")
```

**Auto-registration**: Commands auto-register on import

#### CLI Interface

```python
class CLI:
    """Interactive command-line interface."""

    def __init__(self, registry: DeviceRegistry):
        self.registry = registry
        self.completer = CommandCompleter()  # Tab completion

    async def run(self):
        """Main CLI loop."""
        while True:
            try:
                # Read command (with completion)
                line = await aioconsole.ainput("c3po> ")

                # Parse and execute
                await self.execute_line(line)

            except (EOFError, KeyboardInterrupt):
                print("\nExiting...")
                break

    async def execute_line(self, line: str):
        """Parse and execute command line."""
        parts = line.strip().split()
        if not parts:
            return

        cmd_name = parts[0]
        args = parts[1:]

        # Look up command
        command = command_registry.get(cmd_name)
        if not command:
            print(f"Unknown command: {cmd_name}")
            return

        # Execute
        await command.execute(args)
```

---

## Component Design

### Communication Abstraction Layer

**Purpose**: Abstract WiFi vs GPRS backend

```c
// com.c - Abstraction layer
bool com_init(void)
{
#ifdef CONFIG_NETWORK_WIFI
    wifi_init();
    return true;
#elif defined(CONFIG_NETWORK_GPRS)
    setup_uart();
    setup_modem();
    return true;
#else
    #error "No network backend selected"
#endif
}
```

**Benefits**:
- Single API for all network backends
- Easy to add new backends (LoRa, BLE mesh, etc.)
- Isolates network-specific code

### Plugin Architecture (Modules)

**Design**: Each module is self-contained ESP-IDF component

```
Module Structure:
espilon_bot/components/mod_yourmodule/
├── CMakeLists.txt           # Build configuration
├── Kconfig                  # Configuration options
├── cmd_yourmodule.c         # Commands implementation
└── mod_yourmodule.h         # Public interface
```

**Registration**:
```c
// Module init function (called during boot)
void mod_yourmodule_init(void)
{
    // Register commands
    command_register("your_cmd1", 0, 2, cmd1_handler, NULL, false);
    command_register("your_cmd2", 1, 5, cmd2_handler, NULL, true);

    ESP_LOGI(TAG, "Module initialized");
}
```

**Benefits**:
- Modular: Enable/disable at compile time
- Isolated: Independent dependencies
- Extensible: Easy to add new modules
- Maintainable: Clear separation of concerns

---

## Data Flow

### Command Execution Flow

```
User (C2 CLI)
    │
    │ "send ce4f626b ping 8.8.8.8"
    ▼
C2: Parse command
    │
    ▼
C2: Create Protobuf
    │ Command {
    │   device_id: "ce4f626b"
    │   command_name: "ping"
    │   argv: ["8.8.8.8"]
    │   request_id: "req_001"
    │ }
    ▼
C2: Serialize (Protobuf)
    │ Binary: [0x0a 0x08 0x63 0x65 ...]
    ▼
C2: Encrypt (ChaCha20)
    │ Ciphertext: [0x9f 0x3a 0x7c ...]
    ▼
C2: Encode (Base64)
    │ ASCII: "nzp8xYz..."
    ▼
C2: Send over TCP
    │ "nzp8xYz...\n"
    ▼
ESP32: Receive (read until \n)
    │
    ▼
ESP32: Decode (Base64)
    │ Ciphertext: [0x9f 0x3a 0x7c ...]
    ▼
ESP32: Decrypt (ChaCha20)
    │ Binary: [0x0a 0x08 0x63 0x65 ...]
    ▼
ESP32: Deserialize (Protobuf)
    │ Command struct restored
    ▼
ESP32: Validate device_id
    │ if (matches CONFIG_DEVICE_ID) proceed
    ▼
ESP32: Lookup command in registry
    │ find "ping" → mod_network:ping_handler
    ▼
ESP32: Validate arguments
    │ argc=1, min=1, max=3 → OK
    ▼
ESP32: Execute (async or sync)
    │ if (async) → queue to async_task
    │ else → execute immediately
    ▼
Handler: Execute ping
    │ Send ICMP packets
    │ Collect results
    ▼
Handler: Send responses
    │ msg_info("network", "Reply from 8.8.8.8: time=23ms", "req_001")
    │ msg_info("network", "Reply from 8.8.8.8: time=24ms", "req_001")
    │ msg_info("network", "Ping complete", "req_001")
    ▼
ESP32: For each response:
    ├─> Create AgentMessage (Protobuf)
    ├─> Serialize (Protobuf)
    ├─> Encrypt (ChaCha20)
    ├─> Encode (Base64)
    └─> Send over TCP
    │
    ▼
C2: Receive responses
    │
    ▼
C2: For each response:
    ├─> Decode (Base64)
    ├─> Decrypt (ChaCha20)
    ├─> Deserialize (Protobuf)
    └─> Display to user
    │
    ▼
User sees results
```

### Streaming Data Flow (Camera)

```
Large Data (e.g., JPEG image 20 KB)
    │
    ▼
ESP32: Split into chunks (max 256 bytes each)
    │ Chunk 1: [bytes 0-255]      eof=false
    │ Chunk 2: [bytes 256-511]    eof=false
    │ ...
    │ Chunk N: [bytes 19712-19999] eof=true
    ▼
For each chunk:
    │ Create AgentMessage with payload=chunk, eof=flag
    │ Same request_id for all chunks
    ▼
Send all chunks sequentially
    │
    ▼
C2: Receive chunks
    │
    ▼
C2: Reassemble
    │ Buffer chunks with same request_id
    │ When eof=true → reassemble complete
    ▼
C2: Process complete data (save image, display, etc.)
```

---

## Concurrency Model

### ESP32 (FreeRTOS)

**Tasks**:

| Task | Core | Priority | Stack | Purpose |
|------|------|----------|-------|---------|
| `main_task` | 0 | Normal | 4KB | Boot, initialization |
| `tcp_client_task` | 0 | Normal | 4KB | TCP I/O, receive commands |
| `async_cmd_task` | 1 | Normal | 8KB | Async command execution |
| `wifi_task` | 0 | High | 3KB | WiFi management (internal) |

**Synchronization**:
- **Mutex**: Socket access (prevents concurrent send)
- **Queue**: Async command queue (FreeRTOS xQueue)
- **Semaphore**: Not currently used (future: resource pools)

**Core Allocation**:
- **Core 0**: Network I/O, WiFi stack, LWIP
- **Core 1**: Command execution, CPU-intensive work

**Example**:
```c
// Main task (Core 0)
void app_main(void)
{
    // Initialization
    nvs_flash_init();
    com_init();  // WiFi/GPRS

    // Create async command task (Core 1)
    xTaskCreatePinnedToCore(
        command_async_task,      // Function
        "async_cmd",             // Name
        8192,                    // Stack size
        NULL,                    // Parameters
        5,                       // Priority
        NULL,                    // Handle
        1                        // Core 1
    );

    // Create TCP client task (Core 0)
    xTaskCreatePinnedToCore(
        tcp_client_task,
        "tcp_client",
        4096,
        NULL,
        5,
        NULL,
        0                        // Core 0
    );
}
```

### C2 Server (asyncio)

**Event Loop**: Single-threaded async I/O

**Concurrency**:
- Multiple device connections (each a coroutine)
- Non-blocking I/O (await on socket operations)
- Concurrent command execution (multiple devices)

**Example**:
```python
async def handle_device(reader, writer):
    """Handle single device connection."""
    device_id = None

    try:
        while True:
            # Non-blocking read
            line = await reader.readline()
            if not line:
                break  # Connection closed

            # Process message (non-blocking)
            msg = await process_message(line)

            # Update registry
            if not device_id:
                device_id = msg.device_id
                await registry.add_device(Device(device_id, writer))

    except Exception as e:
        logging.error(f"Error: {e}")

    finally:
        # Cleanup
        if device_id:
            await registry.remove_device(device_id)
        writer.close()
        await writer.wait_closed()

# Main server
async def main():
    server = await asyncio.start_server(
        handle_device,
        '0.0.0.0',
        2626
    )

    async with server:
        await server.serve_forever()

asyncio.run(main())
```

**Benefits**:
- Handles 100+ concurrent device connections
- Low overhead (no threads)
- Simple to reason about (no locks needed)

---

## Memory Management

### ESP32 Heap Management

**Available Heap**:
- Total: ~300 KB (varies by variant)
- After WiFi init: ~200 KB free
- After LWIP: ~180 KB free
- Runtime: ~150-200 KB free (depends on activity)

**Allocation Strategy**:
- **Static**: Config, command registry, task stacks
- **Dynamic**: Message buffers, crypto buffers, temporary data
- **PSRAM**: Camera frame buffers (ESP32-CAM only)

**Memory Hotspots**:

```c
// Crypto buffers (malloc/free on each message)
char *chacha_cd(const unsigned char *data, size_t data_size)
{
    char *output = malloc(data_size);  // Freed by caller
    // ... encrypt ...
    return output;
}

// Base64 buffers (malloc/free)
char *base64_encode(const unsigned char *input, size_t input_len)
{
    size_t output_len = ((input_len + 2) / 3) * 4 + 1;
    char *output = malloc(output_len);  // Freed by caller
    // ... encode ...
    return output;
}
```

**Memory Leak Prevention**:
- Always free malloc'd buffers
- Use valgrind/leak detector in tests
- Monitor `heap_caps_get_free_size()` over time

**Optimization Techniques**:
- Reuse buffers where possible
- Pool allocation (future: pre-allocated buffer pool)
- Avoid fragmentation (allocate similar sizes together)

### C2 Server (Python)

**Memory Management**: Automatic (garbage collection)

**Considerations**:
- Keep device count reasonable (<1000 for 8GB RAM server)
- Limit buffered messages (prevent memory bloat)
- Use generators for large datasets

---

## Network Stack

### WiFi Stack (ESP32)

```
Application
    │
    ▼
LWIP (Lightweight IP)
    ├─ TCP/IP stack
    ├─ Socket API (BSD-style)
    ├─ DHCP client
    └─ DNS resolver
    │
    ▼
ESP WiFi Driver
    ├─ 802.11 MAC
    ├─ STA mode (client)
    ├─ AP mode (access point)
    └─ AP+STA mode (concurrent)
    │
    ▼
Hardware (WiFi Radio)
```

**Features Used**:
- **STA Mode**: Connect to real AP
- **AP Mode**: Host fake AP
- **AP+STA Mode**: Both simultaneously (FakeAP module)
- **NAPT**: Network Address Port Translation (IP forwarding)
- **Raw Sockets**: For ICMP ping, ARP scan

### GPRS Stack (SIM800)

```
Application
    │
    ▼
AT Command Interface (UART)
    ├─ AT+... commands
    ├─ Response parsing
    └─ State machine
    │
    ▼
SIM800 Module (External)
    ├─ GSM modem
    ├─ TCP/IP stack (internal)
    ├─ PPP (Point-to-Point Protocol)
    └─ GPRS data connection
    │
    ▼
Cellular Network (2G/3G)
```

**AT Commands**:
- `AT+CIPSTART`: Open TCP connection
- `AT+CIPSEND`: Send data
- `AT+CIPCLOSE`: Close connection
- `AT+CREG`: Network registration status

---

## Design Patterns

### Registry Pattern

**Used in**: Command registry, device registry

```c
// Command registry (static array + linear search)
static command_t commands[MAX_COMMANDS];
static size_t command_count = 0;

void command_register(const char *name, /* ... */)
{
    if (command_count >= MAX_COMMANDS) {
        ESP_LOGE(TAG, "Command registry full");
        return;
    }

    commands[command_count++] = (command_t) {
        .name = name,
        // ... other fields
    };
}

command_t *command_find(const char *name)
{
    for (size_t i = 0; i < command_count; i++) {
        if (strcmp(commands[i].name, name) == 0) {
            return &commands[i];
        }
    }
    return NULL;
}
```

### Factory Pattern

**Used in**: Message creation

```c
// Helper factory functions
bool msg_info(const char *src, const char *msg, const char *req)
{
    return agent_send(c2_AgentMsgType_AGENT_INFO, src, req,
                      msg, strlen(msg), true);
}

bool msg_error(const char *src, const char *msg, const char *req)
{
    return agent_send(c2_AgentMsgType_AGENT_ERROR, src, req,
                      msg, strlen(msg), true);
}
```

### Plugin Pattern

**Used in**: Module system, C2 commands

```python
# C2 command plugin
class CommandBase:
    """Plugin interface."""
    name: str
    async def execute(self, args: List[str]) -> None:
        raise NotImplementedError

# Auto-registration (metaclass or decorator)
class CommandRegistry:
    _commands = {}

    @classmethod
    def register(cls, command: CommandBase):
        cls._commands[command.name] = command
```

### Observer Pattern

**Potential use**: Event notifications (future enhancement)

```c
// Future: Event system
typedef void (*event_callback_t)(const char *event, void *data);

void event_subscribe(const char *event_name, event_callback_t callback);
void event_publish(const char *event_name, void *data);

// Example: Device connection event
event_publish("device.connected", device_id);
```

---

## Performance Considerations

### Bottlenecks

1. **Network Latency**: WiFi/GPRS latency dominates (10-500ms)
2. **Crypto Overhead**: ChaCha20 is fast (<1ms), Base64 adds 33% size
3. **Protobuf**: Small overhead (~1ms encode/decode)
4. **Command Execution**: Varies by command (ping: 1s, arp_scan: 30s)

### Optimization Strategies

**Firmware**:
- Use async execution for long commands
- Minimize malloc/free (reuse buffers)
- Stream large data (don't buffer entire file)
- Use Core 1 for CPU-intensive work

**C2 Server**:
- Async I/O (non-blocking)
- Connection pooling (reuse sockets)
- Batch operations where possible

**Protocol**:
- Binary framing (future: remove Base64 overhead)
- Compression (future: for large payloads)

### Scalability

**ESP32 Device**:
- Single C2 connection (intentional simplicity)
- ~10-20 commands/sec max throughput
- Limited by network, not CPU

**C2 Server**:
- Tested: 50+ concurrent devices on modest hardware (4GB RAM, 2 CPU)
- Theoretical: 1000+ devices (limited by file descriptors, RAM)
- Horizontal scaling: Multiple C2 servers + load balancer (future)

---

## Future Architecture

### Planned Enhancements

1. **Mesh Networking**:
   - Bot-to-bot communication (WiFi or BLE)
   - Distributed routing
   - Extended range via relay

2. **Microservices C2**:
   - Separate auth service
   - Separate command dispatcher
   - Message queue (Redis/RabbitMQ)
   - Web dashboard (React/Vue)

3. **TLS/DTLS**:
   - Transport security layer
   - Certificate-based authentication
   - Replace custom crypto

4. **gRPC Protocol**:
   - Replace custom protobuf over TCP
   - Bidirectional streaming
   - Better tooling

5. **Multi-tenancy**:
   - Multiple operators
   - Role-based access control
   - Device ownership

---

## References

- [ESP-IDF Architecture](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/general-notes.html)
- [FreeRTOS Documentation](https://www.freertos.org/Documentation/RTOS_book.html)
- [LWIP Documentation](https://www.nongnu.org/lwip/2_1_x/index.html)
- [asyncio (Python)](https://docs.python.org/3/library/asyncio.html)
- [Protocol Buffers](https://protobuf.dev/)

---

**Last Updated**: 2025-12-26
**Architecture Version**: 1.0
