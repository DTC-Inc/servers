# Init errorCatch variable
Write-Host "Warning!! This will cause data loss if this is run!"
$killScript = Read-Host "Do you want to kill this script? (y)"



if ( $killScript -eq "y" ) {
    exit
}

# Server selection
$errorCatch = $true
while ($errorCatch -eq $true ) {

    # Read input of user on what type of server we're configuring
    $inputServer = Read-Host -prompt "What type of server are we configuring? (T140, T340, T440)"

    if ( $inputServer -eq "T140" -or $inputServer -eq "T340" ){
        Write-Host "You selected $inputServer."
        $errorCatch = $false
        
    }else {
        Write-Host "Input not accepted. Try again."

    }
}

# Disk formatting selection
$errorCatch = $true
while ($errorCatch -eq $true ) {

    #Read input of user on what type of server we're configuring
    $inputBoot = Read-Host -prompt "Does this server have a dedicated boot disk? (y or n)"
    Write-Host "You chose $inputBoot."

    if ( $inputBoot -eq "y" -or $inputBoot -eq "n" ){
        Write-Host "You selected $inputBoot."
        $errorCatch = $false
        
        if ( $inputBoot -eq "y" ){
            # Expand OS partition
            $maxSize = (Get-PartitionSupportedSize -driveLetter C).sizeMax
            Resize-Partition -driveLetter C -size $maxSize
            
            # Create data1 partition
            $dataDisk = Get-Disk | Where -property partitionStyle -eq RAW | Select -expandProperty number
            Initialze-Disk -partitionStyle GPT -number $dataDisk
            New-Partition -DiskNumber $dataDisk -useMaximumSize -driveLetter D
            Format-Volume -fileSystem NTFS -driveLetter D
            Get-Volume | Where -property driveLetter -eq D | Set-Volume -newFileSystemLabel data1
            
        }else {
            # Expand OS partition
            Resize-Partition -driveLetter C -size 80GB
            
            # Create data1 partition
            New-Partition -DiskNumber 0 -useMaximumSize -driveLetter D
            Format-Volume -fileSystem NTFS -driveLetter D
            Get-Volume | Where -property driveLetter -eq D | Set-Volume -newFileSystemLabel data1
  
        }
        
    }else {
        Write-Host "Input not accepted. Try again."

    }
}

# Init errorCatch variable
$errorCatch = $true

# Start automation scripts
while ($errorCatch -eq $true ) {

    #Read input of user on what type of server we're configuring
    $inputHyperv = Read-Host -prompt "Will this server be a Hyper-V host? (y or n)"
    echo "You chose $inputHyperv"
    if ( $inputServer -eq "T140" ) {
        Write-Host "T140's cannot have Hyper-V role installed."
        $input = n
    }
    
    if ( $inputHyperv -eq "y" -or $inputHyperv -eq "n" ){
    
        if ( $inputHyperv -eq "y" ){
            & "$psScriptRoot\deploy-hyperv.ps1"
            
            if ( $inputServer -eq "T340" ) {
                Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -name '!deploy-networking-hyperv' -value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionPolicy bypass -file 'C:\dtc\servers-main\T340\deploy-networking-hyperv.ps1'"
            }
            
            if ( $inputServer -eq "T440" ) {
                Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -name '!deploy-networking-hyperv' -value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionPolicy bypass -file 'C:\dtc\servers-main\T440\deploy-networking-hyperv.ps1'"
                
            }
            
            $errorCatch = $false
        }
        
        if ( $inputHyperv -eq "n" ){
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
