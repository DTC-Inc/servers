# Self elevate
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
    $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    exit
  }
}

Set-ExecutionPolicy Bypass

# Update to latest master
Remove-Item -Path $env:windir\temp\servers.zip -Force -confirm:$false
wget "https://codeload.github.com/DTC-Inc/servers/zip/main" -OutFile $env:windir\temp\servers.zip
Expand-Archive -Path "$env:windir\temp\servers.zip" -DestinationPath "$env:systemdrive\dtc" -Force

& "$psScriptRoot\deploy.ps1"


