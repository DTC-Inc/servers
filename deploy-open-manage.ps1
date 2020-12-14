# Download
wget https://s3.us-west-002.backblazeb2.com/public-dtc/repo/vendors/dell/open-manage/latest/ism.zip -outFile $env:windir\temp\ism.zip
wget https://s3.us-west-002.backblazeb2.com/public-dtc/repo/vendors/dell/open-manage/latest/systems-management-x64.zip -outFile $env:windir\temp\systems-management-x64.zip

# Extract
Expand-Archive -path "$env:windir\temp\ism.zip" -destinationPath "$env:systemdrive\dtc\packages\ism" -force
Expand-Archive -path "$env:windir\temp\systems-management-x64.zip" -destinationPath "$env:systemdrive\dtc\packages\systems-management-x64" -force

# Install
msiexec.exe /i "$env:systemdrive\dtc\packages\ism\windows\iDRACSvcMod.msi" /quiet /norestart
msiexec.exe /i "$env:systemdrive\dtc\packages\systems-management-x64\windows\iDRACSvcMod.msi" /quiet /norestart
