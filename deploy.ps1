while ($killScript -ne "y" or $killScript -ne "n") {
    Write-Host "Warning!! This will cause data loss if this is run!"
    $killScript = Read-Host "Do you want to kill this script? (y or n)"
    
    if ($killScript -ne "y" or $killScript -ne "n") {
        Write-Host "Wrong answer. Try again."
    }
}

if ($killScript -eq "y") {
    exit
}

$isDc = $null
$isHyperV = $null
$isRds = $null
$inputServer = $null
$deployDc = $null
$deployHyperV = $null
$deployRds = $false

Set-ExecutionPolicy remoteSigned -force

# Server selection
$errorCatch = $true

while ($errorCatch -eq $true) {

    # Read input of user on what type of server we're configuring
    $inputServer = Read-Host  "What type of server are we configuring? (T140, T340, T440)"

    if ($inputServer -eq "T140" -or $inputServer -eq "T340"){
        Write-Host "You selected $inputServer."
        $errorCatch = $false
        
    }else {
        Write-Host "Input not accepted. Try again."

    }
}

# Disk formatting selection
$errorCatch = $true

while ($errorCatch -eq $true) {
    $inputBoot = Read-Host "Does this server have a dedicated boot disk? (y or n)"
    Write-Host "You chose $inputBoot."

    if ($inputBoot -eq "y" -or $inputBoot -eq "n" ) { 
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
            Resize-Partition -driveLetter C -size 120GB
            
            # Create data1 partition
            New-Partition -DiskNumber 0 -useMaximumSize -driveLetter D
            Format-Volume -fileSystem NTFS -driveLetter D
            Get-Volume | Where -property driveLetter -eq D | Set-Volume -newFileSystemLabel data1
  
        }
        
    }else {
        Write-Host "Input not accepted. Try again."

    }
}

# Domain Controller
$errorCatch = $true

while ($errorCatch -eq $true) {
    $isDc = Read-Host "Is this server going to be a Domain Controller? (y or n)"
    
    if ($isDc -eq "y" -or $isDc -eq "n") {        
        if ($isDc -eq "n") {
            Write-Host "Not deploying ADDS, DHCP, DNS and NPAS"
            $deployDc = false
        }
        
        if ($isDc -eq "y") {
            Write-Host "Deploying ADDS, DHCP, DNS and NPAS."
            $deployDc = $true
        }
        
        $errorCatch = $false
        
    }else {
        Write-Host "Wrong answer. Try again."
        
    }
}

# Hyper-V
$errorCatch = $true
while ($errorCatch -eq $true) {
    $isHyperV = Read-Host "Is this server going to be a Hyper-V Host? (y or n)"

    if ($isHyperV -eq "y" -or $isHyperV -eq "n") {
        if ($isHyperV -eq "n") {
            Write-Host "Not deploying Hyper-V"
            $deployHyperV = $false
        }
        
        if ($inputServer -eq "T140") {
            Write-Host "T140's cannot be Hyper-V Hosts"
            $deployHyperV = $false
        }
        
        if ($isHyperV -eq "y") {
            Write-Host "Deploying Hyper-V"
            $deployHyperV = $true
        }
        
        $errorCatch = $false
        
    }else {
        Write-Host "Wrong answer. Try again."
        
    }
}     


# Deploy Networking
if ($inputServer -eq "T340" -and $deployHyperV -eq $true) {
   $scriptLocation = "$psScriptRoot\T340\deploy-networking-hyperv.ps1"
   schtasks.exe /create /f /tn deploy-networking-hyperv /ru SYSTEM /sc ONSTART /tr "powershell.exe -executionPolicy bypass -file $scriptlocation"
   Write-Host "`$scriptlocation`" is scheduled to run once after reboot."

}

if ($inputServer -eq "T440" -and $deployHyperV -eq $true) {
   $scriptLocation = "$psScriptRoot\T440\deploy-networking-hyperv.ps1"
   schtasks.exe /create /f /tn deploy-networking-hyperv /ru SYSTEM /sc ONSTART /tr "powershell.exe -executionPolicy bypass -file $scriptlocation"
   Write-Host "`$scriptlocation`" is scheduled to run once after reboot."

}

if ($inputerServer -eq "T140") {
    & "$psScriptRoot\T140\deploy-networking.ps1"
}

if ($inputServer -eq "T340" -and $deployHyperV -eq $false) {
    & "$psScriptRoot\T340\deploy-networking.ps1"
}

if ($inputServer -eq "T440" -and $deployHyperV -eq $false) {
    & "$psScriptRoot\T440\deploy-networking.ps1"
}

# Deploy Windows Features
if ($deployHyperV -eq $true -and $deployDc -eq $true) {
    Install-WindowsFeature -name AD-Domain-Services,DNS,DHCP,NPAS,Hyper-V,RSAT-Feature-Tools-Bitlocker,RSAT-Feature-Tools-Bitlocker-RemoteAdminTool,RSAT-Feature-Tools-BitLocker-BdeAducExt,BitLocker -includeManagementTools

}

if ($deployHyperV -eq $true -and $deployDc -eq $false) {
    Install-WindowsFeature -name Hyper-V,RSAT-Feature-Tools-Bitlocker,RSAT-Feature-Tools-Bitlocker-RemoteAdminTool,RSAT-Feature-Tools-BitLocker-BdeAducExt,BitLocker -includeManagementTools
    
}

if ($deployHyperV -eq $false -and $deployDc -eq $true {
    Install-WindowsFeature -name AD-Domain-Services,DNS,DHCP,NPAS,RSAT-Feature-Tools-Bitlocker,RSAT-Feature-Tools-Bitlocker-RemoteAdminTool,RSAT-Feature-Tools-BitLocker-BdeAducExt,BitLocker -includeManagementTools    

}

if ($deployDc = $false -and $deployRds = $false) {
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\" -Name "InactivityTimeoutSecs" -Value 0x00000384 -PropertyType "DWord"
    
}

# Deploy OpenSSH
Write-Host "Deploying OpenSSH"
& "$psScriptRoot\deploy-openssh.ps1"


# Rename host to HV0 or HV1 etc.. Please check Automate if the name is available in the client
$newName = Read-Host "Input the server name (HV0, HV1, SERVER, AD0, etc...)"
Rename-Computer -newName $newName


# Insert Product Key
$productKey = Read-Host "What is the product key? (with dashes)"
slmgr /ipk $productKey


# Success check
$successful = Read-Host "Did everything complete successfully? (y or n)"

if ( $successful -ne "y" ){
    Write-Host "Please run this script until all issues are resolved. Once it is successful, it will remove the Provision Desktop shortcut."
}

if ( $successful -eq "y" ){
    Remove-Item -path "$env:public\Desktop\Provision.lnk" -force -confirm $false
    Read-Host "Please remember to enable and document Bitlocker. Press enter to continue."
}


# Reboot
$reboot = Read-Host "Do you want to reboot? (y or n)"

if ($reboot -eq "y"){
    shutdown -r -t 00 -f
}

