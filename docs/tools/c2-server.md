# C2 Server (C3PO)

The Espilon C2 (Command & Control) server manages communication with deployed ESP32 agents.

## Overview

**C3PO** is the primary C2 server for Espilon, providing:

- Asynchronous device management (Python asyncio)
- Interactive CLI interface
- Group-based organization
- ChaCha20 encrypted communications
- Command dispatch to devices

## Installation

```bash
cd ~/epsilon/tools/c2
pip3 install -r requirements.txt
```

## Configuration

Edit `config.json`:

```json
{
  "server": {
    "host": "0.0.0.0",
    "port": 2626
  },
  "crypto": {
    "key": "testde32chars00000000000000000000",
    "nonce": "noncenonceno"
  }
}
```

## Running C2

```bash
python3 c3po.py --port 2626
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `help` | Show available commands |
| `list` | List connected devices |
| `select <id>` | Select device |
| `cmd <command>` | Execute command on selected device |
| `group` | Manage device groups |

See [tools/c2/README.md](../../tools/c2/README.md) for complete documentation.

---

**Previous**: [Flasher](flasher.md) | **Next**: [Modules](../modules/index.md)
