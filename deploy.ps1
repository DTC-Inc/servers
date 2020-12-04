# Init errorCatch variable
Write-Host "Warning!! This will cause data loss if this is run!"
$killScript = Read-Host "Do you want to kill this script? (y or n)"



if ($killScript -eq "y") {
    exit
}

# Server selection
$errorCatch = $true
while ($errorCatch -eq $true) {

    # Read input of user on what type of server we're configuring
    $inputServer = Read-Host  "What type of server are we configuring? (T140, T340, T440)"

    if (($inputServer) -eq "T140" -or ($inputServer -eq "T340")){
        Write-Host "You selected $inputServer."
        $errorCatch = $false
        
    }else {
        Write-Host "Input not accepted. Try again."

    }
}

# Disk formatting selection
$errorCatch = $true
while ($errorCatch -eq $true) {

    #Read input of user on what type of server we're configuring
    $inputBoot = Read-Host "Does this server have a dedicated boot disk? (y or n)"
    Write-Host "You chose $inputBoot."

    if (($inputBoot -eq "y") -or ($inputBoot -eq "n" )){
        $errorCatch = $false
        
        if ($inputBoot -eq "y"){
            # Expand OS partition
            $maxSize = (Get-PartitionSupportedSize -driveLetter C).sizeMax
            Resize-Partition -driveLetter C -size $maxSize
            
            # Create data1 partition
            $dataDisk = Get-Disk | Where -property partitionStyle -eq RAW | Select -expandProperty number
            Initialize-Disk -partitionStyle GPT -number $dataDisk
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
while ($errorCatch -eq $true){
    #Read input of user on what type of server we're configuring
    $inputHyperv = Read-Host "Will this server be a Hyper-V host? (y or n)"
    Write-Host "You chose $inputHyperv"
    if ($inputServer -eq "T140"){
        Write-Host "T140's cannot have Hyper-V role installed."
        $inputHyperv = n
    }
    
    if (($inputHyperv -eq "y") -or ($inputHyperv -eq "n")){
    
        if ($inputHyperv -eq "y"){
            & "$psScriptRoot\deploy-hyperv.ps1"
            
            if ($inputServer -eq "T340"){
                   $scriptLocation = "$psScriptRoot\T340\deploy-networking-hyperv.ps1"
                   schtasks.exe /create /f /tn deploy-networking-hyperv /ru SYSTEM /sc ONSTART /tr "powershell.exe -executionPolicy bypass -file $scriptlocation"
                   Write-Host "`$scriptlocation`" is scheduled to run once after reboot."

            }
            
            if ($inputServer -eq "T440"){
                   $scriptLocation = "$psScriptRoot\T340\deploy-networking-hyperv.ps1"
                   schtasks.exe /create /f /tn deploy-networking-hyperv /ru SYSTEM /sc ONSTART /tr "powershell.exe -executionPolicy bypass -file $scriptlocation"
                   Write-Host "`$scriptlocation`" is scheduled to run once after reboot."
            }
            
            $errorCatch = $false
        }
        
        if ($inputHyperv -eq "n"){
            Write-Host "Not deploying Hyper-V."
            Write-Host "Deploying ADDS, DHCP, DNS, and NPAS."
            Install-WindowsFeature -name AD-Domain-Services,DNS,DHCP,NPAS,RSAT-Feature-Tools-Bitlocker,RSAT-Feature-Tools-Bitlocker-RemoteAdminTool,RSAT-Feature-Tools-BitLocker-BdeAducExt,BitLocker -includeManagementTools                
           
            if ($inputServer -eq "T340"){
                & "$psScriptRoot\T340\deploy-networking.ps1"
            }
            
            if ($inputServer -eq "T440"){
                & "$psScriptRoot\T440\deploy-networking.ps1"
                
            }
            
            if ($inputServer -eq "T140"){
                & "$psScriptRoot\T140\deploy-networking.ps1"
            }
            
            $errorCatch = $false 
        }
          
    }else {
        Write-Host "Input not accepted. Try again"

    }
}

# Deploy OpenSSH
Write-Host "Deploying OpenSSH"
& "$psScriptRoot\deploy-openssh.ps1"

# Rename host to HV0 or HV1 etc.. Please check Automate if the name is available in the client
$newName = Read-Host "Input the server name (HV0 HV1 etc...)"
Rename-Computer -newName $newName

# Insert Product Key
$productKey = Read-Host "What is the product key? (with dashes)"
slmgr /ipk $productKey

# Remove Provision shortcut
Remove-Item -path "$env:public\Desktop\Provision.lnk" -force -confirm $false


# Reboot
$reboot = Read-Host "Do you want to reboot? (y or n)"

if ($reboot -eq "y"){
    shutdown -r -t 00 -f
}

