# Self elevate
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
     $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
     Exit
    }
}


# Update to latest master
Remove-Item -path $env:windir\temp\servers.zip -force -confirm:$false
wget "https://codeload.github.com/DTC-Inc/servers/zip/main" -outFile $env:windir\temp\servers.zip
Expand-Archive -path "$env:windir\temp\servers.zip" -destinationPath "$env:systemdrive\dtc" -force

& "$psScriptRoot\deploy.ps1"


