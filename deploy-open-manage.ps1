# Download
wget https://s3.us-west-002.backblazeb2.com/public-dtc/repo/vendors/dell/open-manage/latest/ism.zip -fileout $env:windir\temp\ism.zip
wget https://s3.us-west-002.backblazeb2.com/public-dtc/repo/vendors/dell/open-manage/latest/systems-management-x64.zip -fileout $env:windir\temp\systems-management-x64.zip

# Extract
Expand-Archive -path "$env:windir\temp\ism.zip" -destinationPath "$env:systemdrive\dtc\packages" -force
Expand-Archive -path "$env:windir\temp\systems-management-x64.zip" -destinationPath "$env:systemdrive\dtc\packages" -force
