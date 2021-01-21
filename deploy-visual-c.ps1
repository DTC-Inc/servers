
# Download
$progressPreference = 'SilentlyContinue'
wget https://s3.us-west-002.backblazeb2.com/public-dtc/repo/vendors/msft/visutal-c-runtimes/visual-c-runtimes-all-in-one-aug-2020.zip -outFile $env:windir\temp\visual-c-runtimes-all-in-one-aug-2020.zip

# Extract
Expand-Archive -path "$env:windir\temp\visual-c-runtimes-all-in-one-aug-2020.zip" -destinationPath "$env:systemdrive\dtc\packages\visual-c-runtimes-all-in-one-aug-2020" -force

# Install
& "$env:systemdrive\dtc\packages\visual-c-runtimes-all-in-one-aug-2020\install_all.bat"
