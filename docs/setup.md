# Lab Setup

## Host System

- Windows 11
- 16 GB RAM
- Oracle VirtualBox 7.2.6
- Hyper-V and VBS disabled to provide native VT-x access

Baseline virtual machine resources:

| VM | vCPU | RAM |
| --- | ---: | ---: |
| Wazuh | 4 | 8192 MB |
| Target | 2 | 2048 MB |
| Kali | 2 | 2048 MB |

Because the host has 16 GB of RAM, only two virtual machines are normally
started at the same time. For the complete scenario, a temporary
`7168 + 1536 + 1536 MB` profile was used while available host memory was
monitored before each VM was started.

## Network Isolation

Each virtual machine uses the following VirtualBox configuration:

```text
Adapter 1: Internal Network
Name: soc-lab
Adapter 2: disabled
```

No default gateway or DNS server is configured in the guests. The output of
`ip route` must not contain a `default` route.

## Ubuntu Target

Ubuntu Server 26.04 was installed from an ISO image with the following
configuration:

- Static address `10.77.0.20/24`
- OpenSSH Server enabled
- Root login disabled with `PermitRootLogin no`
- UFW permits TCP/22 only from `10.77.0.0/24`
- Wazuh agent 4.14.6 connected to manager `10.77.0.30`

The Netplan file is available at
[`guest-config/target/01-netplan.yaml`](../guest-config/target/01-netplan.yaml).

## Wazuh Server

The Wazuh 4.14.6 official OVA was used. The appliance was assigned
`10.77.0.30/24` and provides the Wazuh manager, indexer, dashboard, and
Filebeat services.

Its network configuration is stored in
[`guest-config/wazuh/20-eth0.network`](../guest-config/wazuh/20-eth0.network).

## Kali Linux

Kali uses the static address `10.77.0.10/24` and has no default route. The
controlled test script is stored at:

```text
guest-config/kali/simulate-ssh-failures.sh
```

The script validates the exact source and destination, generates 12 attempts,
and exits automatically.
