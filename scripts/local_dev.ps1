<#
Local dev helper for Divine Life App (Windows PowerShell)
What it does:
 - Verifies PHP, Flutter, and adb are available
 - Starts Laravel dev server on port 8000 (background)
 - Builds Flutter APK (release)
 - If adb is available and a device is connected, installs the APK

Usage (PowerShell/pwsh):
  cd C:\Users\EDRICK\Desktop\divine_life_app
  .\scripts\local_dev.ps1

Notes:
 - Ensure composer vendor files are present in divine_life_api (run `composer install` inside divine_life_api if needed).
 - This script will start `php artisan serve` in a background process and will not stop it automatically.
 - If you prefer debug build, change the Build-Apk step accordingly.
#>

Set-StrictMode -Version Latest
$root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
Write-Host "Workspace root: $root"

function Check-Command($cmd) {
    $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
}

if (-not (Check-Command php)) {
    Write-Host "php is not found in PATH. Please install PHP and ensure it's on PATH." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "$root\divine_life_api\artisan")) {
    Write-Host "Could not find artisan at $root\divine_life_api\artisan. Make sure the Laravel API is present." -ForegroundColor Red
    exit 1
}

# Start Laravel server
Write-Host "Starting Laravel dev server on http://127.0.0.1:8000 ..."
$phpProc = Start-Process php -ArgumentList @("artisan","serve","--port=8000") -NoNewWindow -PassThru
Start-Sleep -Seconds 2
Write-Host "Laravel server started (PID: $($phpProc.Id))."

# Build Flutter apk
if (-not (Check-Command flutter)) {
    Write-Host "flutter is not found in PATH. Please install Flutter SDK and add flutter to PATH." -ForegroundColor Red
    Write-Host "Laravel server is still running. Stop it manually if you don't need it: Stop-Process -Id $($phpProc.Id)"
    exit 1
}

Write-Host "Running: flutter clean"
Push-Location $root
flutter clean
Write-Host "Running: flutter pub get"
flutter pub get

Write-Host "Building APK (release). This may take a while..."
$buildExit = flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "flutter build failed. See output above." -ForegroundColor Red
    Write-Host "Laravel server is still running (PID: $($phpProc.Id)). Stop it manually if needed."
    Pop-Location
    exit $LASTEXITCODE
}

# Determine APK path
$apkRel = "build\app\outputs\flutter-apk\app-release.apk"
$apkPath = Join-Path $root $apkRel
if (-not (Test-Path $apkPath)) {
    # fallback to debug apk
    $apkRel = "build\app\outputs\flutter-apk\app-debug.apk"
    $apkPath = Join-Path $root $apkRel
    if (-not (Test-Path $apkPath)) {
        Write-Host "Couldn't find an APK at the expected locations." -ForegroundColor Yellow
        Write-Host "Check build output under build/app/outputs/flutter-apk/"
        Pop-Location
        exit 1
    }
}

Write-Host "Built APK: $apkPath"

# Install via adb if available
if (Check-Command adb) {
    Write-Host "adb found. Checking connected devices..."
    $devices = adb devices | Select-String -Pattern "\tdevice$" -AllMatches
    if ($devices.Matches.Count -eq 0) {
        Write-Host "No devices/emulators detected. Run 'adb devices' to see status." -ForegroundColor Yellow
        Write-Host "You can install manually: adb install -r `"$apkPath`""
    } else {
        Write-Host "Installing APK to connected device(s)..."
        adb install -r "$apkPath"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "APK installed successfully." -ForegroundColor Green
        } else {
            Write-Host "adb install failed. See output above." -ForegroundColor Red
        }
    }
} else {
    Write-Host "adb not found in PATH. APK is available at: $apkPath" -ForegroundColor Yellow
    Write-Host "Add Android SDK platform-tools to PATH to enable automatic install, or run the command below yourself:" -ForegroundColor Gray
    Write-Host "adb install -r `"$apkPath`""
}

Pop-Location
Write-Host "Done. Laravel server is still running in background (PID: $($phpProc.Id)). Stop it manually when finished: Stop-Process -Id $($phpProc.Id)" -ForegroundColor Cyan

exit 0
