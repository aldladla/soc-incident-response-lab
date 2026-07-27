# Scenario 01 — SSH authentication failures

Cel: wygenerować 12 kontrolowanych, nieudanych logowań SSH i znaleźć je w Wazuh.

## Warunki

- Kali: `10.77.0.10/24`;
- Target: `10.77.0.20/24`;
- Wazuh: `10.77.0.30/24`;
- brak trasy domyślnej;
- aktywny agent `soc-target`;
- snapshot przed testem.

## Uruchomienie

Na Kali:

```bash
/home/kali/simulate-ssh-failures.sh
```

Skrypt ma zabezpieczenia źródła, celu i routingu oraz zawsze kończy się po
12 próbach.

## Wyszukiwanie w Wazuh

```text
agent.name: "soc-target" AND rule.id: "5763"
agent.name: "soc-target" AND rule.id: "5551"
agent.name: "soc-target" AND rule.id: "5760"
```

Po teście należy zablokować konto `soc-test`, zachować dowody i czysto wyłączyć
maszyny.
