Install-WindowsFeature -name Hyper-V,RSAT-Feature-Tools-Bitlocker,RSAT-Feature-Tools-Bitlocker-RemoteAdminTool,RSAT-Feature-Tools-BitLocker-BdeAducExt,BitLocker -includemanagementTools
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\" -Name "InactivityTimeoutSecs" -Value 0x00000384 -PropertyType "DWord"
