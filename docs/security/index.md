# Security Overview

Security considerations for Espilon deployments.

## Encryption

Espilon uses **ChaCha20** stream cipher for C2 communications:

- 256-bit key
- 96-bit nonce
- Authenticated encryption

## Default Keys

!!! danger "Change Default Keys"
    Default keys are for testing only:
    ```
    Key: testde32chars00000000000000000000
    Nonce: noncenonceno
    ```

## Generating Keys

```bash
# 32-byte key (64 hex chars)
openssl rand -hex 32

# 12-byte nonce (24 hex chars)
openssl rand -hex 12
```

Configure in menuconfig or devices.json.

## Responsible Use

!!! warning "Legal Notice"
    Espilon is for authorized security testing and research only. Unauthorized use may violate laws. Always obtain proper authorization.

---

**Previous**: [Commands](../modules/commands.md) | **Next**: [Best Practices](best-practices.md)
