#!/usr/bin/env bash
set -euo pipefail

readonly TARGET="10.77.0.20"
readonly USERNAME="soc-test"
readonly ATTEMPTS=12

if [[ "$TARGET" != "10.77.0.20" ]]; then
  echo "Safety stop: destination is outside the approved lab target." >&2
  exit 2
fi

if ! ip -4 addr show | grep -q "10\\.77\\.0\\.10/24"; then
  echo "Safety stop: this host is not the designated Kali VM." >&2
  exit 3
fi

if ip route | grep -q '^default '; then
  echo "Safety stop: remove the default route/NAT before simulation." >&2
  exit 4
fi

if ! command -v expect >/dev/null 2>&1; then
  echo "Safety stop: the bounded password prompt driver 'expect' is missing." >&2
  exit 5
fi

echo "Generating $ATTEMPTS bounded SSH authentication failures against $TARGET."
for i in $(seq 1 "$ATTEMPTS"); do
  LAB_TARGET="$TARGET" LAB_USERNAME="$USERNAME" expect <<'EOF' >/dev/null 2>&1 || true
set timeout 4
set target $env(LAB_TARGET)
set username $env(LAB_USERNAME)
spawn ssh -o PreferredAuthentications=password \
          -o PubkeyAuthentication=no \
          -o NumberOfPasswordPrompts=1 \
          -o ConnectTimeout=3 \
          -o StrictHostKeyChecking=accept-new \
          "${username}@${target}" true
expect {
  "*assword:" {
    send "definitely-wrong-lab-password\r"
    exp_continue
  }
  eof
  timeout
}
EOF
  sleep 1
done
echo "Finished. Investigate the corresponding events in Wazuh."
