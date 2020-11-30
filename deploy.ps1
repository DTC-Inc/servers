# Init errorCatch variable
$errorCatch = $true

# Start automation scripts
# Expand OS partition
$maxSize = (Get-PartitionSupportedSize -driveLetter C).sizeMax
Resize-Partition -driveLetter C -size $maxSize

# Create data1 partition
$dataDisk = Get-Disk | Where -property partitionStyle -eq RAW | Select -expandProperty number
Initialze-Disk -partitionStyle GPT -number $dataDisk
New-Partition -DiskNumber $dataDisk -useMaximumSize -driveLetter D
Format-Volume -fileSystem NTFS -driveLetter D
Get-Volume | Where -property driveLetter -eq D | Set-Volume -newFileSystemLabel data1



while ($errorCatch -eq $true ) {

    #Read input of user on what type of server we're configuring
    $inputServer = Read-Host -prompt "What type of server are we configuring? (T140, T340, T440)"
    Write-Host "You chose $input."

    if ( $inputServer -eq "T140" -or $input -eq "T340" ){
        Write-Host "You selected $inputServer."
        $errorCatch = $false
        
    }else {
        Write-Host "Input not accepted. Try again."

    }
}

# Init errorCatch variable
$errorCatch = $true

# Start automation scripts
while ($errorCatch -eq $true ) {

    #Read input of user on what type of server we're configuring
    $input = Read-Host -prompt "Will this server be a Hyper-V host? (y or n)"
    echo "You chose $input"
    if ( $inputServer -eq "T140" ) {
        Write-Host "T140's cannot have Hyper-V role installed."
        $input = n
    }
    
    if ( $input -ne "y" or $input -ne "n" ){
    
        if ( $input -eq "y" ){
            & "$psScriptRoot\deploy-hyperv.ps1"
            
            if ( $inputServer -eq "T340" ) {
                & "$psScriptRoot\T340\deploy-networking-hyperv.ps1"
            }
            
            if ( $inputServer -eq "T440" ) {
                & "$psScriptRoot\T440\deploy-networking-hyperv.ps1"
                
            }
            
            $errorCatch = $false
        }
        
        if ( $input -eq "n" ){
            Write-Host "Not deploying Hyper-V."
            
            if ( $inputServer -eq "T340" ) {
                & "$psScriptRoot\T340\deploy-networking.ps1"
            }
            
            if ( $inputServer -eq "T440" ) {
                & "$psScriptRoot\T440\deploy-networking.ps1"
                
            }
            
            if ( $inputServer -eq "T140" ) {
                & "$psScriptRoot\T140\deploy-networking.ps1"
            }
            
            $errorCatch = $false
        }    
    }else {
        echo "Input not accepted. Try again"

    }
}

# Deploy OpenSSH
Write-Host "Deploying OpenSSH"
& "$psScriptRoot\deploy-openssh.ps1"
