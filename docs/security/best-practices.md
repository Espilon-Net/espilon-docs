# Security Best Practices

Guidelines for secure Espilon deployments.

## Key Management

1. **Generate unique keys** for each deployment
2. **Never commit keys** to version control
3. **Rotate keys** periodically
4. **Use strong random** keys (openssl rand)

## Network Security

1. **Use VPN** for remote C2 access
2. **Firewall** C2 server (allow only necessary ports)
3. **Change default port** 2626 if needed
4. **Monitor** C2 server logs

## Physical Security

1. **Label devices** discreetly
2. **Secure batteries** (prevent disconnection)
3. **Document** deployment locations
4. **Recovery plan** for lost devices

## Operational Security

1. **Obtain authorization** before deployment
2. **Document scope** of testing
3. **Notify stakeholders** as required
4. **Secure data** collected during testing
5. **Destroy sensitive data** after use

## Legal Compliance

- Follow local laws and regulations
- Obtain written authorization
- Respect privacy and data protection laws
- Report findings responsibly

---

**Previous**: [Security](index.md) | **Next**: [License](../about/license.md)
