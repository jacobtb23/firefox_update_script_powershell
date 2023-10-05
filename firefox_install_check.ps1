$firefoxPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
$uninstallFirefoxPath = "C:\Program Files\Mozilla Firefox\"
$appName = "Mozilla Firefox"

# Check for Firefox install. If it does exis, check if it is the latest version and update if needed.
if (Test-Path -Path $firefoxPath) {
    $installedVersionNumber = (Get-Item $firefoxPath).VersionInfo.FileVersion
    Write-Host "$appName is installed at '$firefoxPath' with the version number $installedVersionNumber."
    # Get the current firefox version number.
    $res = Invoke-RestMethod -Uri "https://product-details.mozilla.org/1.0/firefox_versions.json"
    $latestVersionNumber = $res.LATEST_FIREFOX_VERSION
    Write-Host "Latest Firefox version:" $latestVersionNumber
    Write-Host "Current installed version number:" $installedVersionNumber
    $installedVersionNumber = "14.0.1"
    if ($installedVersionNumber -eq $latestVersionNumber) {
        Write-Host "Firefox is up to date at version number" $installedVersionNumber
    }
    else {
        Write-Host "Firefox is out of date at version $installedVersionNumber. Updating..."
        # Uninstall current version of Firefox.
        if ( Test-Path -Path $uninstallFirefoxPath ) {
            Write-Host "Uninstalling Firefox..."
            # Find and stop the firefox.exe process
            $processes = Get-Process | Where-Object { $_.ProcessName -eq "firefox" -or $_.ProcessName -eq "firefox.exe" }
            foreach ($process in $processes) {
                Stop-Process -Id $process.Id -Force
            }
            Get-ChildItem -Path $uninstallFirefoxPath -File -Recurse | ForEach-Object {
                Remove-Item -Path $_.FullName -Force
            }
            Remove-Item -Path $uninstallFirefoxPath -Recurse -Force
            if ( Test-Path -Path $uninstallFirefoxPath ) {
                Write-Host "Firefox was not sucessfully uninstalled."
                exit(1)
            }
            else {
                Write-Host "Firefox has been uninstalled."
                # Need to install up to date version of Mozilla Firefox. (TODO)
                $workdir = "c:\installer\"
                if (Test-Path -Path $workdir -PathType Container) {
                    Write-Host "$workdir already exists" -ForegroundColor Red
                }
                else { 
                    New-Item -Path $workdir  -ItemType directory 
                }
                $source = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
                $destination = "$workdir\firefox.exe"
                if (Get-Command 'Invoke-Webrequest') {
                    Invoke-WebRequest $source -OutFile $destination
                }
                else {
                    $WebClient = New-Object System.Net.WebClient
                    $webclient.DownloadFile($source, $destination)
                }
                Start-Process -FilePath "$workdir\firefox.exe" -ArgumentList "/S"
                Start-Sleep -s 35
                Remove-Item -Force $workdir/firefox*
                if (Test-Path -Path $firefoxPath ) {
                    Write-Host "Updated version of firefox is installed."
                }
            }
        }
    }
}
else {
    Write-Host "$appName is not installed. (At least not at the filepath $firefoxPath)"
    exit 0
}