Write-Host "If Net adapters are vendor mixed, member count is always split between vendor."
Write-Host "Only two seperate Teams will be created. The total NIC count will always be split in half between teams."
$memberCount = Read-Host "Enter NICs Per Team (2 most common and default)"

if (!$memberCount) {
  $memberCount = 2

}

Get-NetLbfoTeam | Remove-NetLbfoTeam -confirm:$false
Get-VMNetworkAdapter -managementOS | Where-Object -Property "name" -NotLike "Container NIC*" | Remove-VMNetworkAdapter
Get-VMSwitch | Where-Object -Property name -NotLike "Default Switch" | Remove-VMSwitch -Force

$nicList = Get-NetAdapter | Where-Object { ($_.InterfaceDescription -like "Intel*") -or ($_.InterfaceDescription -like "*Broadcom*") } | Select-Object -ExpandProperty InterfaceDescription
$nicCount = $nicList | Measure-Object | Select-Object -ExpandProperty Count

if ($nicList -like "Intel*" -and $nicList -like "Broadcom*") {
  $firstNicList = Get-NetAdapter | Where-Object -Property interfaceDescription -Like "Broadcom*" | Select-Object -ExpandProperty Name
  $secondNicList = Get-NetAdapter | Where-Object -Property interfaceDescription -Like "Intel*" | Select-Object -ExpandProperty Name


} elseif ($nicList -like "Broadcom*" -and $nicList -notlike "Intel*") {
  $firstNicList = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like "Broadcom*" } | Select-Object -Last $memberCount | Select-Object -ExpandProperty Name
  $secondNicList = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like "Broadcom*" } | Select-Object -First $memberCount | Select-Object -ExpandProperty Name


} else {
  $firstNicList = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like "Intel*" } | Select-Object -Last $memberCount | Select-Object -ExpandProperty Name
  $secondNicList = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like "Intel*" } | Select-Object -First $memberCount | Select-Object -ExpandProperty Name

}

if ($nicCount -eq $memberCount) {
  $secondNicList = $null

}

# Create SET team SET1 and Management vNIC. Also sets load balancing algorithm to dynamic
New-VMSwitch -Name SET1 -netAdapterName $firstNicList -enableEmbeddedTeaming $true
Rename-VMNetworkAdapter -Name SET1 -NewName vNIC1 -managementOS
Set-VMSwitchTeam -Name SET1 -loadBalancingAlgorithm dynamic
ping 8.8.8.8 -n 30

# Create SET team SET2 w/ no vNIC for Management OS. Also sets load balancing algorithm to dynamic
if ($secondNicList) {
  New-VMSwitch -Name SET2 -netAdapterName $secondNicList -enableEmbeddedTeaming $true -allowManagementOs $false
  Set-VMSwitchTeam -Name SET2 -loadBalancingAlgorithm dynamic

}

# Change default Hyper-V Storage location
Set-VMHost -virtualHardDiskPath "D:\Virtual Hard Disks"
Set-VMHost -virtualMachinePath "D:\"

# Delete scheduled task
Write-EventLog -messasge "deploy-networking-hyperv: hi I ran on reboot" -LogName System -Source EventLog -EventId 333
schtasks.exe /delete /f /tn deploy-networking-hyperv
