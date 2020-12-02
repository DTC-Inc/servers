# Remove all existing teams
Get-NetlbfoTeam | Remove-NetlbfoTeam -confirm:$false

# Create team & disable IPv6
$toTeam = Get-NetAdapter | Where -property interfaceDescription -like "Broadcom*" | Select-Object -expandProperty name
New-NetlbfoTeam -name TEAM0 -teamMembers $toTeam -loadBalancingAlgorithm Dynamic -teamingMode switchIndependent -confirm:$false
ping 8.8.8.8 -n 30
$toDisableIPv6 = Get-NetAdapter | Where -property Name -like "TEAM*" | Select-Object -expandProperty name
Disable-NetAdapterBinding -name $toDisableIPv6 -componentID ms_tcpip6
