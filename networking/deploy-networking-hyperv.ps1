Write-Host "Net adapters will be teamed fully between amount of NICs per embedded & Slot 1, Slot 2, Slot 3, & Slot 4."
Write-Host "***WARNING*** This script supports a maxmium of 1 embedded NI (all interfaces) & 4 NIC card slots."

Get-NetLbfoTeam | Remove-NetLbfoTeam -confirm:$false
Get-VMNetworkAdapter -managementOS | Where-Object -Property "name" -NotLike "Container NIC*" | Remove-VMNetworkAdapter
Get-VMSwitch | Where-Object -Property name -NotLike "Default Switch" | Remove-VMSwitch -Force

$nicList = Get-NetAdapter | Where-Object { ($_.Name -like "Embedded*") -or ($_.Name -like "Slot 1**") } | Select-Object -ExpandProperty Name
$nicCount = $nicList | Measure-Object | Select-Object -ExpandProperty Count

if ($nicList -like "Embedded*" -and $nicList -like "Slot 1*") {
  $firstNicList = Get-NetAdapter | Where-Object -Property Name -Like "Embedded*" | Select-Object -ExpandProperty Name
  $secondNicList = Get-NetAdapter | Where-Object -Property Name -Like "Slot 1*" | Select-Object -ExpandProperty Name


} else {
  $firstNicList = Get-NetAdapter | Where-Object { $_.Name -like "Embedded*" } | Select-Object -Last $memberCount | Select-Object -ExpandProperty Name
  $secondNicList = Get-NetAdapter | Where-Object { $_.Name -like "Embedded*" } | Select-Object -First $memberCount | Select-Object -ExpandProperty Name


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