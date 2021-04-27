Set-ExecutionPolicy Bypass -Force

$errorCatch = $true

while ($errorCatch -eq $true) {
    Write-Host "Warning!! This will cause data loss if this is run!"
    $killScript = Read-Host "Do you want to kill this script? (y or n)"
    
    if ($killScript -eq "y" -or $killScript -eq "n") {
        $errorCatch =  $false

    }else {
        Write-Host "Wrong answer. Try again."
    
    }

}

if ($killScript -eq "y") {
    exit

}

# Setup IE
Write-Host "IE is going to open. Please go initial setup selecting all defaults."
pause

Start-Process -filePath "$env:programfiles\Internet Explorer\iexplore.exe" -wait

$isDc = $null
$isHyperV = $null
$isRds = $null
$inputServer = $null
$deployDc = $null
$deployHyperV = $null
$deployRds = $false
$inputVendor = $null

# Vendor selection
$errorCatch = $true

while ($errorCatch -eq $true) {
    # Read input of user on what type of server we're configuring
    $inputVendor = Read-Host  "Who made this server? (dell, hpe, lenovo, vm)"

    if ($inputVendor -eq "lenovo" -or $inputVendor -eq "dell" -or $inputVendor -eq "hpe" -or $inputVendor -eq "vm"){
        Write-Host "You selected $inputVendor."
        $errorCatch = $false

    }else {
        Write-Host "Input not accepted. Try again."

    }

}



# Server selection
$errorCatch = $true

while ($errorCatch -eq $true) {
    # Read input of user on what type of server we're configuring
    $inputServer = Read-Host  "What type of server are we configuring? (T140, T340, T440, vm)"

    if ($inputServer -eq "T140" -or $inputServer -eq "T340" -or $inputServer -eq "T440" -or $inputServer -eq "vm"){
        Write-Host "You selected $inputServer."
        $errorCatch = $false

    }else {
        Write-Host "Input not accepted. Try again."

    }

}

# Disk formatting selection
$errorCatch = $true

if ($inputServer -eq "vm"){
    $errorCatch = $false
}

while ($errorCatch -eq $true) {
    $inputBoot = Read-Host "Does this server have a dedicated boot disk? (y or n)"
    Write-Host "You chose $inputBoot."

    if ($inputBoot -eq "y" -or $inputBoot -eq "n" ) {         
        if ($inputBoot -eq "y"){
            # Expand OS partition
            $maxSize = (Get-PartitionSupportedSize -driveLetter C).sizeMax
            Resize-Partition -driveLetter C -size $maxSize
            
            # Create data1 partition
            $dataDisk = Get-Disk | Where -property isBoot -ne $true | Select -expandProperty number
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
        $errorCatch = $false

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
            $deployDc = $false

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
   schtasks.exe /create /f /tn deploy-networking-hyperv /ru Administrator /sc ONLOGON /rl HIGHEST /tr "powershell.exe -executionPolicy bypass -file $scriptLocation"
   Write-Host "$scriptLocation is scheduled to run once after reboot."

}

if ($inputServer -eq "T440" -and $deployHyperV -eq $true) {
   $scriptLocation = "$psScriptRoot\T440\deploy-networking-hyperv.ps1"
   schtasks.exe /create /f /tn deploy-networking-hyperv /ru Administrator /sc ONLOGON /rl HIGHEST /tr "powershell.exe -executionPolicy bypass -file $scriptLocation"
   Write-Host "$scriptLocation is scheduled to run once after reboot."

}

if ($inputServer -eq "T140") {
    & "$psScriptRoot\T140\deploy-networking.ps1"

}

if ($inputServer -eq "T340" -and $deployHyperV -eq $false) {
    & "$psScriptRoot\T340\deploy-networking.ps1"

}

if ($inputServer -eq "T440" -and $deployHyperV -eq $false) {
    & "$psScriptRoot\T440\deploy-networking.ps1"

}

# Deploy Hyper-V and DC
if ($deployHyperV -eq $true -and $deployDc -eq $true) {
    Install-WindowsFeature -name AD-Domain-Services,DNS,DHCP,NPAS,Hyper-V,RSAT-Feature-Tools-Bitlocker,RSAT-Feature-Tools-Bitlocker-RemoteAdminTool,RSAT-Feature-Tools-BitLocker-BdeAducExt,BitLocker -includeManagementTools

}

# Deploy Hyper-V Only
if ($deployHyperV -eq $true -and $deployDc -eq $false) {
    Install-WindowsFeature -name Hyper-V,RSAT-Feature-Tools-Bitlocker,RSAT-Feature-Tools-Bitlocker-RemoteAdminTool,RSAT-Feature-Tools-BitLocker-BdeAducExt,BitLocker -includeManagementTools
    
}

# Deploy DC Only
if ($deployHyperV -eq $false -and $deployDc -eq $true) {
    Install-WindowsFeature -name AD-Domain-Services,DNS,DHCP,NPAS,RSAT-Feature-Tools-Bitlocker,RSAT-Feature-Tools-Bitlocker-RemoteAdminTool,RSAT-Feature-Tools-BitLocker-BdeAducExt,BitLocker -includeManagementTools    

}

# Set Machine Inactivity Timeout to 900s if not a domain controller or remote desktop server
if ($deployDc -eq $false -and $deployRds -eq $false) {
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\" -Name "InactivityTimeoutSecs" -Value 0x00000384 -PropertyType "DWord"
    
}

# Deploy Visual C++
& "$psScriptRoot\deploy-visual-c.ps1"

# Deploy OpenManage
if ($inputVendor -eq "dell") {
    Write-Host "Deploying Dell OpenManage."
    & "$psScriptRoot\deploy-open-manage.ps1"
}



# Deploy OpenSSH
Write-Host "Deploying OpenSSH"
$scriptLocation = "$psScriptRoot\deploy-openssh.ps1"
schtasks.exe /create /f /tn deploy-openssh /ru SYSTEM /sc ONLOGON /tr "powershell.exe -executionPolicy bypass -file $scriptLocation"
Write-Host "$scriptLocation is scheduled to run once after reboot."

# Deploy apps
Write-Host "Deploying essential apps."
Start-Process -filePath "$env:systemdrive\dtc\servers-main\dep\ninite.exe" -wait

# Rename host to HV0 or HV1 etc.. Please check Automate if the name is available in the client
$newName = Read-Host "Input the server name (HV0, HV1, SERVER, AD0, etc. Null value doesn't set name. Set a name if joining a domain.)"

# Domain Join
$domainJoin = Read-Host "Please enter a domain name to join. Null value doesn't join a domain."


if ($newName -and $domainJoin) {
    $credential = Get-Credential
    Add-Computer -domainName $domainJoin -newName $newName -credential $credential
}

if ($newName -and !$domainJoin) {
    Rename-Computer -newName $newName
}

# Insert Product Key
$productKey = Read-Host "What is the product key? (with dashes)"
if ($productKey) {
    slmgr /ipk $productKey
}

# Success check
$successful = Read-Host "Did everything complete successfully? (y or n)"

if ( $successful -ne "y" ){
    Write-Host "Please run this script until all issues are resolved. Once it is successful, it will remove the Provision Desktop shortcut."

}

if ( $successful -eq "y" ){
    Remove-Item -path "$env:public\Desktop\Provision.lnk" -force
    Write-Host "Please remember to enable and document Bitlocker. (Not required for virtual machines)"
    pause

}

Set-ExecutionPolicy RemoteSigned -Force

# Reboot
$reboot = Read-Host "Do you want to reboot? (y or n)"

if ($reboot -eq "y"){
    shutdown -r -t 00 -f

}

