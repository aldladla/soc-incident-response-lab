# Setup

## Host

- Windows 11;
- 16 GB RAM;
- Oracle VirtualBox 7.2.6;
- Hyper-V/VBS wyłączone dla natywnego VT-x.

Bazowe ustawienia VM:

| VM | vCPU | RAM |
| --- | ---: | ---: |
| Wazuh | 4 | 8192 MB |
| Target | 2 | 2048 MB |
| Kali | 2 | 2048 MB |

Na hoście 16 GB uruchamiam zwykle tylko dwie maszyny naraz. Podczas pełnego
scenariusza tymczasowo użyłem profilu `7168 + 1536 + 1536 MB` i kontrolowałem
wolny RAM przed startem kolejnej VM.

## Sieć

Każda maszyna ma:

```text
Adapter 1: Internal Network
Name: soc-lab
Adapter 2: disabled
```

W gościach nie ma bramy ani DNS. `ip route` nie może pokazywać trasy `default`.

## Target

Ubuntu Server 26.04 został zainstalowany z ISO. Konfiguracja:

- `10.77.0.20/24`;
- OpenSSH Server;
- `PermitRootLogin no`;
- UFW wpuszcza TCP/22 tylko z `10.77.0.0/24`;
- agent Wazuh 4.14.6 wskazuje manager `10.77.0.30`.

Netplan znajduje się w
[`guest-config/target/01-netplan.yaml`](../guest-config/target/01-netplan.yaml).

## Wazuh

Użyłem oficjalnej OVA Wazuh 4.14.6. Appliance otrzymał adres
`10.77.0.30/24`. Działają usługi manager, indexer, dashboard i filebeat.

Konfiguracja sieci:
[`guest-config/wazuh/20-eth0.network`](../guest-config/wazuh/20-eth0.network).

## Kali

Kali ma adres `10.77.0.10/24` i nie ma trasy domyślnej. Skrypt ćwiczenia:

```text
guest-config/kali/simulate-ssh-failures.sh
```

Skrypt wymaga dokładnego źródła i celu, wykonuje 12 prób i kończy pracę.
