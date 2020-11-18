#Self elevate
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
     $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
     Exit
    }
}


#Update to latest master
Remove-Item -path $env:windir\temp\servers.zip -force -confirm:$false
wget "https://codeload.github.com/DTC-Inc/servers/zip/main" -outFile $env:windir\temp\servers.zip
Expand-Archive -path "$env:windir\temp\servers.zip" -destinationPath "$env:systemdrive\dtc" -force

#Init $errorCatch variable
$errorCatch = $true

#Start automation scripts
while ($errorCatch -eq $true ) {

    #Read input of user on what type of server we're configuring
    $input = Read-Host -prompt "What type of server are we configuring? (T140, T340, T440): "
    echo "You chose $input"

    if ( $input -eq "T140" -or $input -eq "T340" ){
    
        if ( $input -eq "T140" ){
            & "$psScriptRoot\T140\deploy-networking.ps1"
            $errorCatch = $false
        }
        if ( $input -eq "T340" ){
            & "$psScriptRoot\T340\deploy-networking.ps1"
            $errorCatch = $false
        }    
    }else {
        echo "Input not accepted. Try again"

    }
}
