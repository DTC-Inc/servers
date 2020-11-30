# Init errorCatch variable
$errorCatch = $true

# Start automation scripts
while ($errorCatch -eq $true ) {

    #Read input of user on what type of server we're configuring
    $input = Read-Host -prompt "What type of server are we configuring? (T140, T340, T440)"
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

# Deploy OpenSSH
Write-Host "Deploying OpenSSH"
& "$psScriptRoot\deploy-openssh.ps1"
