# Wait for the ready!

$ready = "n"
while ($ready -ne "r") {
	$ready = Read-Host "Please patch in NICs to team. Type 'r' when ready:"
	if ($ready -eq "r") {
			Write-Host "YEEET!"
	} else {
			Write-Host "Guess you're not ready. Hurry and patch in that first team!"
	}
}

$finished = "n"

# Remove all existing teaming.
Get-NetLbfoTeam | Remove-NetLbfoTeam -confirm:$false
Get-VMNetworkAdapter -managementOS | Where-Object -Property "name" -NotLike "Container NIC*" | Remove-VMNetworkAdapter
Get-VMSwitch | Where-Object -Property name -NotLike "Default Switch" | Remove-VMSwitch -Force
Start-Sleep -Seconds 10

# Create NIC team(s) based off of link-state. Cables must be patched in for each loop.
$count = 0
while ( $finished -eq "n" ) {
	$count = $count + 1
	$nicList = Get-NetAdapter | Where -Property DriverFileName -notlike "usb*"| Where -Property Status -eq 'Up' | Select -ExpandProperty Name
	if ($count -eq 1) { 
		New-VMSwitch -Name SET$count -netAdapterName $nicList -enableEmbeddedTeaming $true
		Rename-VmNetworkAdapter -Name SET$count -NewName vNIC1 -ManagementOs
	} else {
		New-VMSwitch -Name SET$count -netAdapterName $nicList -enableEmbeddedTeaming $true -AllowManagementOs $False
	}
	$finished = Read-Host "Are you finished? y/n:"
	
}
