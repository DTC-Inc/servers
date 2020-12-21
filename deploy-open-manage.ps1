# Download
wget https://s3.us-west-002.backblazeb2.com/public-dtc/repo/vendors/dell/open-manage/latest/ism.zip -outFile $env:windir\temp\ism.zip
wget https://s3.us-west-002.backblazeb2.com/public-dtc/repo/vendors/dell/open-manage/latest/systems-management-x64.zip -outFile $env:windir\temp\systems-management-x64.zip
wget https://s3.us-west-002.backblazeb2.com/public-dtc/repo/vendors/dell/open-manage/latest/PreReqChecker.zip -outFile $env:windir\temp\pre-req-checker.zip

# Extract
Expand-Archive -path "$env:windir\temp\ism.zip" -destinationPath "$env:systemdrive\dtc\packages\ism" -force
Expand-Archive -path "$env:windir\temp\systems-management-x64.zip" -destinationPath "$env:systemdrive\dtc\packages\systems-management-x64" -force
Expand-Archive -path "$env:windir\temp\pre-req-checker.zip" -destinationPath "$env:systemdrive\dtc\packages\pre-req-checker" -force

# Install
Start-Process -FilePath "$env:systemdrive\dtc\packages\pre-req-checker\PreReqChecker\RunPreReqChecks.exe" -Args "/s"
Start-Process -FilePath "msiexec.exe" -Args"/i $env:systemdrive\dtc\packages\ism\windows\iDRACSvcMod.msi" /quiet /norestart"
Start-Process -FilePath "msiexec.exe" -Args "/i $env:systemdrive\dtc\packages\systems-management-x64\SystemsManagementx64\SysMgmtx64.msi /quiet /norestart"
