# Remove all existing vNICs and vSwitches
Get-VMNetworkadapter -managementOS  | Where-Object -property "name" -notlike "Container NIC*" | Remove-VMNetworkAdapter
Get-VMSwitch | Where-Object -property name -notlike "Default Switch" | Remove-VMSwitch -force

# Create SET team SET1 and Management vNIC. Also sets load balancing algorithm to dynamic
$toTeam = Get-NetAdapter | Where-Object -property interfaceDescription -like "Broadcom*" | Select-Object -expandProperty name
New-VMSwitch -name SET1-HOST -netAdapterName $toTeam -enableEmbeddedTeaming $true
Rename-VMNetworkAdapter -name SET1-HOST -newName vNIC1 -managementOS
Set-VMSwitchTeam -name SET1-HOST -loadBalancingAlgorithm dynamic 
ping 8.8.8.8 -n 30

#Create SET team SET2 w/ no vNIC for Management OS. Also sets load balancing algorithm to dynamic
$toTeam = Get-NetAdapter | Where-Object -property interfaceDescription -like "Intel*" | Select-Object -expandProperty name
New-VMSwitch -name SET2-VM -netAdapterName $toTeam -enableEmbeddedTeaming $true -allowManagementOs $false
Set-VMSwitchTeam -name SET2-VM -loadBalancingAlgorithm dynamic

# Change default Hyper-V Storage location
Set-VMHost -virtualHardDiskPath "D:\Virtual Hard Disks"
Set-VMHost -virtualMachinePath "D:\"

# Delete scheduled task
Write-EventLog -messasge "deploy-networking-hyperv: hi I ran on reboot" -LogName System -Source EventLog -EventId 333
schtasks.exe /delete /f /tn deploy-networking-hyperv
