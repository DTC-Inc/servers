# Download
$progressPreference = 'SilentlyContinue'
wget https://s3.us-west-002.backblazeb2.com/public-dtc/repo/vendors/dell/open-manage/latest/ism.zip -OutFile $env:windir\temp\ism.zip
wget https://s3.us-west-002.backblazeb2.com/public-dtc/repo/vendors/dell/open-manage/latest/systems-management-x64.zip -OutFile $env:windir\temp\systems-management-x64.zip
wget https://s3.us-west-002.backblazeb2.com/public-dtc/repo/vendors/dell/open-manage/latest/pre-req-checker.zip -OutFile $env:windir\temp\pre-req-checker.zip

# Extract
Expand-Archive -Path "$env:windir\temp\ism.zip" -DestinationPath "$env:systemdrive\dtc\packages\ism" -Force
Expand-Archive -Path "$env:windir\temp\systems-management-x64.zip" -DestinationPath "$env:systemdrive\dtc\packages\systems-management-x64" -Force
Expand-Archive -Path "$env:windir\temp\pre-req-checker.zip" -DestinationPath "$env:systemdrive\dtc\packages\pre-req-checker" -Force

# Install
Start-Process -FilePath "$env:systemdrive\dtc\packages\pre-req-checker\PreReqChecker\RunPreReqChecks.exe" -args "/s" -Wait
Start-Process -FilePath "msiexec.exe" -args "/i $env:systemdrive\dtc\packages\ism\windows\iDRACSvcMod.msi /quiet /norestart" -Wait
Start-Process -FilePath "msiexec.exe" -args "/i $env:systemdrive\dtc\packages\systems-management-x64\SystemsManagementx64\SysMgmtx64.msi /quiet /norestart" -Wait
