# Architecture Overview

This page explains the Espilon architecture and how components interact.

## System Architecture

```mermaid
graph TB
    subgraph "ESP32 Device"
        FW[Firmware]
        MOD[Modules]
        NET[Network Layer]
        ENC[Encryption]
    end

    subgraph "Communication"
        TCP[TCP Connection]
        PROTO[Protocol Buffers]
    end

    subgraph "C2 Server"
        CLI[CLI Interface]
        MGR[Device Manager]
        DB[(Device Registry)]
    end

    FW --> MOD
    MOD --> NET
    NET --> ENC
    ENC <-->|ChaCha20| TCP
    TCP <-->|Protobuf| PROTO
    PROTO <--> CLI
    CLI --> MGR
    MGR --> DB

    style "ESP32 Device" fill:#7c3aed,color:#fff
    style "C2 Server" fill:#059669,color:#fff
    style "Communication" fill:#3b82f6,color:#fff
```

## Module System

```mermaid
graph LR
    CORE[Core Layer]
    REG[Command Registry]

    subgraph "Modules"
        NET[Network Module]
        FAKE[FakeAP Module]
        RECON[Recon Module]
        SYS[System Module]
    end

    NET --> REG
    FAKE --> REG
    RECON --> REG
    SYS --> REG

    REG --> CORE
    CORE -->|Execute| NET
    CORE -->|Execute| FAKE
    CORE -->|Execute| RECON
    CORE -->|Execute| SYS

    style CORE fill:#7c3aed,color:#fff
    style REG fill:#a78bfa,color:#fff
```

## Communication Flow

```mermaid
sequenceDiagram
    participant C2 as C2 Server
    participant TCP as TCP Layer
    participant ESP as ESP32 Agent
    participant MOD as Module

    C2->>TCP: Send Command (Encrypted)
    TCP->>ESP: Decrypt & Parse
    ESP->>MOD: Execute Command
    MOD->>MOD: Process
    MOD->>ESP: Return Result
    ESP->>TCP: Encrypt Response
    TCP->>C2: Send Response

    Note over C2,MOD: All communication uses ChaCha20 encryption
```

## Network Topology

```mermaid
graph TB
    C2[C2 Server<br/>Central Control]

    subgraph "WiFi Network"
        ESP1[ESP32 Agent 1]
        ESP2[ESP32 Agent 2]
        AP[Access Point]
    end

    subgraph "GPRS Network"
        ESP3[LilyGO T-Call]
        TOWER[Cell Tower]
    end

    ESP1 --> AP
    ESP2 --> AP
    AP --> C2

    ESP3 --> TOWER
    TOWER --> C2

    style C2 fill:#059669,color:#fff
    style ESP1 fill:#7c3aed,color:#fff
    style ESP2 fill:#7c3aed,color:#fff
    style ESP3 fill:#7c3aed,color:#fff
```

## Deployment Scenarios

### Scenario 1: WiFi Penetration Testing

```mermaid
graph LR
    TESTER[Pentester<br/>Laptop]
    C2[C2 Server]
    ESP[ESP32 WiFi<br/>Agent]
    TARGET[Target<br/>Network]

    TESTER -->|Control| C2
    C2 <-->|Commands| ESP
    ESP -.->|Monitor| TARGET

    style TESTER fill:#3b82f6,color:#fff
    style C2 fill:#059669,color:#fff
    style ESP fill:#7c3aed,color:#fff
    style TARGET fill:#ef4444,color:#fff
```

### Scenario 2: IoT Security Research

```mermaid
graph TB
    LAB[Research Lab]
    C2[C2 Server]

    subgraph "Test Environment"
        ESP1[Agent 1<br/>Scanner]
        ESP2[Agent 2<br/>FakeAP]
        ESP3[Agent 3<br/>Monitor]
        IOT[IoT Devices]
    end

    LAB --> C2
    C2 --> ESP1
    C2 --> ESP2
    C2 --> ESP3

    ESP1 -.-> IOT
    ESP2 -.-> IOT
    ESP3 -.-> IOT

    style LAB fill:#3b82f6,color:#fff
    style C2 fill:#059669,color:#fff
    style ESP1 fill:#7c3aed,color:#fff
    style ESP2 fill:#7c3aed,color:#fff
    style ESP3 fill:#7c3aed,color:#fff
```

## Component Responsibilities

| Component | Responsibility | Technology |
|-----------|---------------|------------|
| **Firmware** | Device logic, module execution | C/ESP-IDF |
| **Modules** | Specific capabilities (scanning, recon, etc.) | C/ESP-IDF |
| **Network Layer** | WiFi/GPRS connectivity | ESP-IDF WiFi/SIM800 |
| **Encryption** | Secure communication | ChaCha20 |
| **Protocol** | Message serialization | Protocol Buffers |
| **C2 Server** | Command & control interface | Python 3 |
| **Device Manager** | Fleet management | Python 3 |

## Security Layers

```mermaid
graph TD
    APP[Application Layer<br/>Commands & Responses]
    ENC[Encryption Layer<br/>ChaCha20]
    PROTO[Protocol Layer<br/>Protobuf]
    TRANS[Transport Layer<br/>TCP]
    NET[Network Layer<br/>WiFi/GPRS]

    APP --> ENC
    ENC --> PROTO
    PROTO --> TRANS
    TRANS --> NET

    style ENC fill:#ef4444,color:#fff
    style APP fill:#7c3aed,color:#fff
```

## Next Steps

- [Installation Guide](installation.md) - Set up your development environment
- [Hardware Guide](../hardware/index.md) - Choose your ESP32 board
- [Module Reference](../modules/index.md) - Learn about available modules
