# Remove all existing teams
Get-NetlbfoTeam | Remove-NetlbfoTeam -Confirm:$false

# Rename host to HV0 or HV1 etc.. Please check Automate if the name is available in the client
$newName = Read-Host -prompt "Input the server name (HV0, HV1, etc...)"
Rename-Computer -newName $newName

# Create team & disable IPv6
$toTeam = Get-NetAdapter | Where-Object -Property InterfaceDescription -like "Broadcom NetXtreme Gigabit Ethernet*" | Select-Object -ExpandProperty Name
New-NetlbfoTeam -Name TEAM0 -TeamMembers $toTeam -LoadBalancingAlgorithm Dynamic -TeamingMode SwitchIndependent -Confirm:$false
ping 8.8.8.8 -n 30
$toDisableIPv6 = Get-NetAdapter | Where-Object -Property Name -like "TEAM*" | Select-Object -ExpandProperty Name
Disable-NetAdapterBinding -Name $toDisableIPv6 -ComponentID ms_tcpip6
