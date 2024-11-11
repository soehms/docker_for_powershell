# ----------------------------------------------------
# Copy and paste all lines into the Windows PowerShell
# ----------------------------------------------------

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$name = "DockerForPowershell"
$name_code = "docker_for_powershell"
$version = "0.1"
$name_vers = "${name}-${version}"
$name_code_vers = "${name_code}-${version}"

# Check if WSL must be installed
if ((wsl --status) -eq $null) {
    Write-Host "The Windows Subsystem for Linux (WSL) is not installed, but needed for ${name}."
    Write-Host "After installation you have to reboot your computer an start the installer again!"
    $response = Read-Host "Do you agree to install it now? (y/n)"
    if ($response -eq "y") {
        wsl --install --no-distribution
    }
    else {
        Read-Host "OK. Press any key to exit"; exit
    }
}

$env:WSL_UTF8 = 1
$test = wsl --status
if ($test -eq $null -or ($test -join ' ' | Out-String).Contains('WSL_E_WSL_OPTIONAL_COMPONENT_REQUIRED')) {
    Write-Host "Your computer must be rebooted to continue the installation of $name"
    $response = Read-Host "Reboot now? (y/n)"
    if ($response -eq "y") {
        Restart-Computer
    }
    else {
        Read-Host "OK. Press any key to exit"
    }
    exit
}

# Check if DockerForPowershell already exists in WSL
if ((wsl -l -q) -contains $name_vers) {
    # Ask user if they want to reinstall
    $response = Read-Host "${name_vers} is already installed. Do you want to reinstall it? (y/n)"
    if ($response -eq "y") {
        Write-Host "Uninstalling ${name_vers}."
        # Unregister the existing DockerForPowershell WSL distribution
        wsl --unregister $name_vers
    }
    else {
        Read-Host "OK. Press any key to exit"; exit
    }
}

# Download and extract the tar-file
$zip_url = "https://github.com/soehms/${name_code}/releases/download/${version}/${name_code_vers}.zip"
$zip_local = "$PWD\${name_code}.zip"
$data_path = "$HOME\AppData\Local\${name}"
$tar_file = "$data_path\${name_code_vers}.tar"
# Ensure the path exists
if (-Not (Test-Path $data_path)) { New-Item -Path $data_path -ItemType Directory > $null }
# Skip downloading and extracting if the tar file already exists
if (-Not (Test-Path $tar_file)) {
    Write-Host "Downloading $name_vers..."
    Start-BitsTransfer -Source $zip_url -Destination $zip_local
    Write-Host "Extracting..."
    Expand-Archive -Path $zip_local -DestinationPath $data_path -Force
    if (Test-Path $tar_file) { Remove-Item $zip_local }
}
else {
    Write-Host "$name_vers was already downloaded."
}
# Import the WSL image
Write-Host "Start importing..."
wsl --import $name_vers $data_path/$version $tar_file
# Check if importing succeeded
if (-Not ((wsl -l -q) -contains $name_vers)) {
    Write-Host "Importing $name_vers into WSL failed."
}
else
{
    Write-Host "Importing $name_vers into WSL successfully finished."
    Remove-Item $tar_file
}
