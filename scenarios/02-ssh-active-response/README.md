# Scenario 02 - SSH Active Response

## Objective

Extend the existing SSH brute-force detection with an automated and temporary
containment action. When Wazuh rule `5763` triggers, the Ubuntu target blocks
the source IP for 180 seconds and then removes the block automatically.

## Environment

| System | Role | Address |
| --- | --- | --- |
| `SOC-Kali` | Controlled event source | `10.77.0.10` |
| `SOC-Target` | Monitored SSH endpoint | `10.77.0.20` |
| `SOC-Wazuh` | Detection and response manager | `10.77.0.30` |

All systems must use only the VirtualBox Internal Network `soc-lab`. No guest
may have a default route, NAT adapter, or bridged adapter.

## Preconditions

- A recovery snapshot exists.
- The `soc-target` Wazuh agent is active.
- `/var/ossec/active-response/bin/firewall-drop` exists on the target.
- `iptables` is available on the target.
- Console access to both the target and Wazuh server is available.
- Baseline ICMP and SSH connectivity has been verified.

## Wazuh Manager Configuration

The following block was added to `/var/ossec/etc/ossec.conf`:

```xml
<ossec_config>
  <active-response>
    <disabled>no</disabled>
    <command>firewall-drop</command>
    <location>local</location>
    <rules_id>5763</rules_id>
    <timeout>180</timeout>
  </active-response>
</ossec_config>
```

The existing `firewall-drop` command has `timeout_allowed` enabled. Before the
change, the manager configuration was backed up to
`/root/ossec.conf.bak`. The Active Response configuration was tested with:

```bash
sudo /var/ossec/bin/wazuh-execd -t
```

The manager was restarted only after the command returned exit status `0`.

## Controlled Execution

Run the bounded scenario once on Kali:

```bash
bash /home/kali/simulate-ssh-failures.sh
```

The script validates the source, destination, routing state, and maximum
attempt count before generating authentication failures.

## Validation

### Before containment

```bash
ping -c 4 10.77.0.20
nc -vz -w 3 10.77.0.20 22
```

Expected result: zero packet loss and SSH/22 open.

### During containment

Expected result: 100% packet loss and an SSH connection timeout.

### After 180 seconds

Repeat the baseline commands. Expected result: zero packet loss and SSH/22
open again.

## Wazuh Query

```text
agent.name: "soc-target" AND (rule.id: "5763" OR rule.id: "651" OR rule.id: "652")
```

Expected events:

| Rule | Description |
| ---: | --- |
| `5763` | SSH brute-force activity detected |
| `651` | Host blocked by firewall-drop Active Response |
| `652` | Host unblocked by firewall-drop Active Response |

## Safety Notes

- Run this scenario only in the isolated lab.
- Do not remove the script's source, destination, or routing safeguards.
- Keep direct console access available in case a legitimate address is blocked.
- Use a short timeout to limit the impact of false positives.
- Never configure the response with `location` set to `all`.
- Do not run the event-generation script more than once per test.

## Rollback

To restore the manager configuration:

```bash
sudo cp /root/ossec.conf.bak /var/ossec/etc/ossec.conf
sudo systemctl restart wazuh-manager
```
