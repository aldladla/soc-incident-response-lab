# Helper Scripts

These PowerShell scripts support the host-side setup of the lab. They are
included to document repeatable configuration steps, not to provide a fully
automated installer.

## Available Scripts

### `host-preflight.ps1`

Checks whether the host meets the minimum conditions used for this lab:

- Oracle VirtualBox is installed in the standard location.
- At least 11 GB of RAM is currently available.
- At least 90 GB of free space is available on the project drive.

The script performs read-only checks and does not modify the host.

### `configure-vms.ps1`

Applies the approved VirtualBox network and resource settings to the three
existing virtual machines. It does not create, import, start, or delete VMs.

Before running it:

1. Confirm that `SOC-Kali`, `SOC-Target`, and `SOC-Wazuh` already exist.
2. Shut down all three virtual machines.
3. Review the VM names, memory values, and internal network name in the script.
4. After execution, verify the configuration in the VirtualBox interface
   before starting any VM.

## Usage Note

Run the scripts from a PowerShell session with access to VirtualBox. Review
their contents before execution and use them only for this isolated lab. The
scripts intentionally avoid bridged networking and configure only the
VirtualBox Internal Network named `soc-lab`.
