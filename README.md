# HAProxy-SNI-Forwarder

HAProxy-SNI-Forwarder is a simple bash-based tool to automatically generate an HAProxy TCP mode configuration that forwards incoming HTTPS connections based on the SNI (Server Name Indication) in the TLS handshake. This allows you to route multiple HTTPS domains on a single IP address to different backend servers without terminating SSL on the proxy.

---

## Features

- Automatic generation of frontend `use_backend` rules for each domain.
- Dynamic backend section creation with IP and port.
- Works in TCP mode, inspecting TLS SNI for routing HTTPS traffic.
- Scalable to dozens or hundreds of domains via a simple CSV file.
- Configuration syntax check after generation.
- Lightweight and easy to use.

---

## Use Case

This project is useful when you need to serve many HTTPS domains on one public IP and forward traffic transparently to their respective backend servers. HAProxy operates at TCP layer 4 and uses the SNI field to differentiate the domains.

---

## Installation & Usage

1. Prepare a CSV file named `domains.csv` in the same directory with content like:

```
domain1.com,10.2.0.1:443
domain2.net,27.60.70.20:443
```

Lines starting with `#` are considered comments and ignored.

2. Place the `HAProxy-SNI-Forwarder.sh` bash script (provided) in the same directory.

3. Run the script to generate the HAProxy configuration:

```bash
bash HAProxy-SNI-Forwarder.sh
