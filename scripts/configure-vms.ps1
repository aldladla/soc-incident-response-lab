# Purpose: apply the documented network and resource profile to existing VMs.
# Note: all VMs must be powered off. Verify the result in VirtualBox before use.
$ErrorActionPreference = 'Stop'
$vbox = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'
if (-not (Test-Path -LiteralPath $vbox)) {
  throw 'VirtualBox is not installed in the standard location.'
}

$names = @('SOC-Kali', 'SOC-Target', 'SOC-Wazuh')
$existing = & $vbox list vms

foreach ($name in $names) {
  if ($existing -notmatch [regex]::Escape('"' + $name + '"')) {
    throw "Missing VM: $name. No changes were made to that VM."
  }
}

foreach ($name in $names) {
  & $vbox modifyvm $name `
    --nic1 intnet --intnet1 'soc-lab' --cable-connected1 on `
    --nic-promisc1 deny --nic2 none
}

& $vbox modifyvm 'SOC-Kali' --cpus 2 --memory 2048 --graphicscontroller vmsvga
& $vbox modifyvm 'SOC-Target' --cpus 2 --memory 2048 --graphicscontroller vmsvga
& $vbox modifyvm 'SOC-Wazuh' --cpus 4 --memory 8192 --graphicscontroller vmsvga

Write-Host 'VM adapters and resources configured. Verify in the VirtualBox UI before boot.'
