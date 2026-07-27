# Scenario 01 — SSH Authentication Failures

## Objective

Generate exactly 12 controlled SSH authentication failures and investigate
the resulting events in Wazuh.

## Preconditions

- Kali: `10.77.0.10/24`
- Target: `10.77.0.20/24`
- Wazuh: `10.77.0.30/24`
- No default route on any guest
- Wazuh agent `soc-target` is active
- A baseline snapshot exists before testing

## Execution

Run the following command on Kali:

```bash
/home/kali/simulate-ssh-failures.sh
```

The script validates the source address, destination address, and routing
state. It always stops after 12 attempts.

## Wazuh Queries

```text
agent.name: "soc-target" AND rule.id: "5763"
agent.name: "soc-target" AND rule.id: "5551"
agent.name: "soc-target" AND rule.id: "5760"
```

## Cleanup

After the test, lock the `soc-test` account, preserve the evidence, and shut
down the virtual machines cleanly.
