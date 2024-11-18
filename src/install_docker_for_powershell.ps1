##############################################################################
#       Copyright (C) 2024 Sebastian Oehms <seb.oehms@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  http://www.gnu.org/licenses/
##############################################################################

# -----------------------------------------------------------------------------------------------------------------
# This code follows https://github.com/sagemath/sage-binder-env/blob/master/.github/workflows/create-wsl-image.yml
# authored by Kwankyu Lee <ekwankyu@gmail.com>
# -----------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------
# Copy and paste all lines into a Windows PowerShell
# ----------------------------------------------------

$env:WSL_UTF8 = 1
$name = "DockerForPowershell"
$version = "0.1"
$name_code = "docker_for_powershell"
$name_vers = "${name}-${version}"
$name_code_vers = "${name_code}-${version}"
$data_path = "$HOME\AppData\Local\${name}"
$journal = "$data_path\journal-$version.log"

function journal_message($text) {
    $today = Get-Date -Format "dddd MM\/dd\/yyyy HH:mm:ss K"
    $disk_space = @(foreach ($d  in Get-WmiObject -Class Win32_LogicalDisk) {if ($d.DeviceID -eq "C:") {$d.Size, $d.FreeSpace}})
    $disk_size = $disk_space[0] / 1GB | % {$_.ToString("####.##")}
    $disk_free = $disk_space[1] / 1GB | % {$_.ToString("####.##")}
    if (-Not (Test-Path $journal)) {
        "-------------------------------------------------" > $journal
        "Journal file of install_docker_for_powershell.ps1" >> $journal
        "-------------------------------------------------" >> $journal
    }
    "${today}: Size of drive C: ${disk_size} GB, free: ${disk_free} GB ($text)" >> $journal
}

function check_reboot($wsl_response) {
    $name = $global:name
    $ask_reboot = $false
    if ($wsl_response -eq $null) {
        Write-Host "It seems that the Windows Subsystem for Linux (WSL) is still not active!"
        $ask_reboot = $true
    }
    $wsl_str = $wsl_response -join ' ' | Out-String
    if ($wsl_str.Contains('WSL_E_WSL_OPTIONAL_COMPONENT_REQUIRED')) {
        Write-Host "It seems that the Windows Subsystem for Linux (WSL) is not working, yet!"
        $ask_reboot = $true
    }
    if ($wsl_str.Contains('enablevirtualization') -or $wsl_str.Contains('WSL_E_DEFAULT_DISTRO_NOT_FOUND')) {
        Write-Host "It seems that virtualization is not enabled in your BIOS settings!  ${name} does not run without it!"
        Write-Host "For help have a look at https://support.microsoft.com/en-us/windows/enable-virtualization-on-windows-c5578302-6e43-4b4b-a449-8ced115f58e1"
        $ask_reboot = $true
    }
    if ($ask_reboot) {
        Write-Host "Your computer must be rebooted to continue the installation of ${name}"
        $response = Read-Host "Reboot now? (y/n)"
        if ($response -eq "y") {
            journal_message "before Restart-Computer"
            Restart-Computer
            journal_message "after Restart-Computer"
        }
        else {
            Read-Host "OK. Press any key to exit"
        }
        exit
    }
}

# create folder if not done before and init journal file
if (-Not (Test-Path $data_path)) {
    New-Item -Path $data_path -ItemType Directory > $null
    journal_message "Create folder"
}

# Check if WSL must be installed
$test_wsl = wsl --status
if ($test_wsl -eq $null) {
    Write-Host "The Windows Subsystem for Linux (WSL) is not installed, but needed for ${name}."
    Write-Host "After installation you have to reboot your computer an start the installer again!"
    $response = Read-Host "Do you agree to install it now? (y/n)"
    if ($response -eq "y") {
        journal_message "before wsl --install"
        wsl --install --no-distribution
        journal_message "after wsl --install"
    }
    else {
        Read-Host "OK. Press any key to exit"; exit
    }
}

# Check if reboot is necessary
check_reboot $test_wsl

# Check if DockerForPowershell already exists in WSL
if ((wsl -l -q) -contains $name_vers) {
    # Ask user if they want to reinstall
    $response = Read-Host "${name_vers} is already installed. Do you want to reinstall it? (y/n)"
    if ($response -eq "y") {
        Write-Host "Uninstalling ${name_vers}."
        # Unregister the existing DockerForPowershell WSL distribution
        journal_message "before wsl --unregister"
        wsl --unregister $name_vers
        journal_message "after wsl --unregister"
    }
    else {
        Read-Host "OK. Press any key to exit"; exit
    }
}

# Download and extract the tar-file
$zip_url = "https://github.com/soehms/${name_code}/releases/download/${version}/${name_code_vers}.zip"
$zip_local = "$PWD\${name_code}.zip"
$tar_file = "$data_path\${name_code_vers}.tar"
# Ensure the path exists
# Skip downloading and extracting if the tar file already exists
if (-Not (Test-Path $tar_file)) {
    Write-Host "Downloading $name_vers..."
    journal_message "before download"
    Start-BitsTransfer -Source $zip_url -Destination $zip_local
    Write-Host "Extracting..."
    journal_message "before extracting"
    Expand-Archive -Path $zip_local -DestinationPath $data_path -Force
    journal_message "after extracting"
    if (Test-Path $tar_file) { Remove-Item $zip_local }
    journal_message "after removing zip"
}
else {
    Write-Host "$name_vers was already downloaded."
}

# Import the WSL image
Write-Host "Start importing..."
journal_message "before importing"
$wsl_response = wsl --import $name_vers $data_path/$version $tar_file
journal_message "after importing"
# Check if importing succeeded
if (-Not ((wsl -l -q) -contains $name_vers)) {
    Write-Host "Importing $name_vers into WSL failed."
    check_reboot $wsl_response
}
else
{
    Write-Host "Importing $name_vers into WSL successfully finished."
    Remove-Item $tar_file
    journal_message "after removing tar"
}
