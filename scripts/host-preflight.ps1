# Purpose: perform read-only host capacity checks before starting the SOC lab.
# Note: this helper does not install software or change host configuration.
$ErrorActionPreference = 'Stop'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class SocLabMemory {
  [StructLayout(LayoutKind.Sequential)]
  public class MEMORYSTATUSEX {
    public uint dwLength = (uint)Marshal.SizeOf(typeof(MEMORYSTATUSEX));
    public uint dwMemoryLoad;
    public ulong ullTotalPhys;
    public ulong ullAvailPhys;
    public ulong ullTotalPageFile;
    public ulong ullAvailPageFile;
    public ulong ullTotalVirtual;
    public ulong ullAvailVirtual;
    public ulong ullAvailExtendedVirtual;
  }
  [DllImport("kernel32.dll", SetLastError=true)]
  public static extern bool GlobalMemoryStatusEx([In, Out] MEMORYSTATUSEX value);
}
'@

$memory = New-Object SocLabMemory+MEMORYSTATUSEX
[void][SocLabMemory]::GlobalMemoryStatusEx($memory)
$projectRoot = Split-Path -Parent $PSScriptRoot
$projectDrive = [System.IO.Path]::GetPathRoot($projectRoot)
$drive = [System.IO.DriveInfo]::new($projectDrive)
$vbox = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'

$result = [pscustomobject]@{
  TotalRAM_GB     = [math]::Round($memory.ullTotalPhys / 1GB, 1)
  AvailableRAM_GB = [math]::Round($memory.ullAvailPhys / 1GB, 1)
  ProjectDrive    = $projectDrive
  FreeDisk_GB     = [math]::Round($drive.AvailableFreeSpace / 1GB, 1)
  VirtualBox      = Test-Path -LiteralPath $vbox
}
$result | Format-List

$ready = ($memory.ullAvailPhys -ge 11GB) -and
         ($drive.AvailableFreeSpace -ge 90GB) -and
         (Test-Path -LiteralPath $vbox)

if (-not $ready) {
  Write-Error 'PRE-FLIGHT FAILED: require VirtualBox, 11 GB available RAM, and 90 GB free disk.'
}

Write-Host 'PRE-FLIGHT PASSED'
