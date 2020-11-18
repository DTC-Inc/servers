#Remove all existing vNICs and vSwitches
Get-VMNetworkadapter -managementOS  | Where-Object -property "name" -notlike "Container NIC*" | Remove-VMNetworkAdapter
Get-VMSwitch | Where-Object -property name -notlike "Default Switch" | Remove-VMSwitch -force

#Rename host to HV0 or HV1 etc.. Please check Automate if the name is available in the client
$newName = Read-Host -prompt "Input the DTCBSURE Appliance Name (HV0, HV1, etc...): "
Rename-Computer -newName $newName

#Create SET team SET1 and Management vNIC. Also sets load balancing algorithm to dynamic
$toTeam = Get-NetAdapter | Where-Object -property interfaceDescription -like "Broadcom*" | Select-Object -expandProperty name
New-VMSwitch -name SET1 -netAdapterName $toTeam -enableEmbeddedTeaming $true
Rename-VMNetworkAdapter -name SET1 -newName vNIC1 -managementOS
Set-VMSwitchTeam -name SET1 -loadBalancingAlgorithm dynamic 
ping 8.8.8.8 -n 30