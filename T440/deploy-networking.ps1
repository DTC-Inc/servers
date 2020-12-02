# Remove all existing teams
Get-NetlbfoTeam | Remove-NetlbfoTeam -Confirm:$false

# Create team & disable IPv6
$toTeam = Get-NetAdapter | Where-Object -Property InterfaceDescription -like "Intel*" | Select-Object -ExpandProperty Name
New-NetlbfoTeam -Name TEAM0 -TeamMembers $toTeam -LoadBalancingAlgorithm Dynamic -TeamingMode SwitchIndependent -Confirm:$false
ping 8.8.8.8 -n 30
$toDisableIPv6 = Get-NetAdapter | Where-Object -Property Name -like "TEAM*" | Select-Object -ExpandProperty Name
Disable-NetAdapterBinding -Name $toDisableIPv6 -ComponentID ms_tcpip6
