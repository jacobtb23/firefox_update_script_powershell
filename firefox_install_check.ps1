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
        if( Test-Path -Path $uninstallFirefoxPath ) {
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
            if( Test-Path -Path $uninstallFirefoxPath ) {
                Write-Host "Firefox was not sucessfully uninstalled."
                exit(1)
            }
            else {
                Write-Host "Firefox has been uninstalled."
                if (Get-Command winget -ErrorAction SilentlyContinue) {
                    # winget is installed, perform action A
                    Write-Host "winget is installed."
                    
                    if (Test-Path -Path $firefoxPath ) {
                        Write-Host "Updated version of firefox is installed."
                    }
                } else {
                    # winget is not installed, perform action B
                    Write-Host "winget is not installed. Cannot install Mozilla Firefox w/o winget."
                    exit(1)
                }
            }
        }
    }
}
else {
    Write-Host "$appName is not installed. (At least not at the filepath $firefoxPath)"
    exit 0
}