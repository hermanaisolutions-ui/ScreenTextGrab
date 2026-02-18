@echo off
echo ============================================
echo   ScreenTextGrab - Build ^& Package
echo ============================================
echo.

:: Step 1: Clean
echo [1/4] Cleaning previous build...
if exist publish rmdir /s /q publish
if exist installer-output rmdir /s /q installer-output

:: Step 2: Publish self-contained single file
echo [2/4] Building self-contained EXE...
dotnet publish src\ScreenTextGrab\ScreenTextGrab.csproj ^
  -c Release ^
  -r win-x64 ^
  --self-contained true ^
  -p:PublishSingleFile=true ^
  -p:IncludeNativeLibrariesForSelfExtract=true ^
  -p:EnableCompressionInSingleFile=true ^
  -o publish

if errorlevel 1 (
    echo.
    echo ERROR: Build failed! Make sure .NET 8 SDK is installed.
    echo Download: https://dotnet.microsoft.com/download/dotnet/8.0
    pause
    exit /b 1
)

echo.
echo [3/4] Build successful!
echo.

:: Check file size
for %%I in (publish\ScreenTextGrab.exe) do (
    set SIZE=%%~zI
    echo   EXE size: %%~zI bytes
)
echo   Location: publish\ScreenTextGrab.exe
echo.

:: Step 3: Create installer (if Inno Setup is installed)
where iscc >nul 2>nul
if %errorlevel% equ 0 (
    echo [4/4] Creating installer with Inno Setup...
    mkdir installer-output 2>nul
    iscc installer.iss
    echo.
    echo   Installer: installer-output\ScreenTextGrab-Setup-0.1.0.exe
) else (
    echo [4/4] Inno Setup not found - skipping installer creation.
    echo   To create an installer, download Inno Setup from:
    echo   https://jrsoftware.org/isdl.php
    echo.
    echo   Alternative: Share the publish\ folder as ZIP.
)

echo.
echo ============================================
echo   Done! Distribution options:
echo.
echo   Option A: Share publish\ScreenTextGrab.exe
echo             (single file, ~60-80 MB, just works)
echo.
echo   Option B: Run installer.iss with Inno Setup
echo             (professional installer with autostart)
echo ============================================
pause
