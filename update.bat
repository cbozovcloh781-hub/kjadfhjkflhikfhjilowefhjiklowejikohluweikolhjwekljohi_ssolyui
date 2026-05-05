@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo   Auto-Update GitHub with Version Bump
echo ========================================
echo.

cd /d "e:\folders\codes\roblox\games\yba\ssoly"

:: Check for changes
git status --short > temp_status.txt
for %%A in (temp_status.txt) do set size=%%~zA

if %size% EQU 0 (
    del temp_status.txt
    echo [INFO] No changes to commit
    echo.
    pause
    exit /b
)

echo [INFO] Changes detected:
type temp_status.txt
del temp_status.txt
echo.

:: Read current version
set /p current_version=<version.txt
echo [INFO] Current version: %current_version%

:: Parse version (format: X.Y.Z)
for /f "tokens=1,2,3 delims=." %%a in ("%current_version%") do (
    set major=%%a
    set minor=%%b
    set patch=%%c
)

:: Increment patch version
set /a patch+=1

:: Create new version
set new_version=%major%.%minor%.%patch%
echo [INFO] New version: %new_version%
echo.

:: Write new version
echo %new_version%> version.txt

:: Add all changes
echo [GIT] Adding files...
git add .

:: Commit with version message
echo [GIT] Creating commit...
git commit -m "Update to v%new_version%"

:: Push to GitHub
echo [GIT] Pushing to GitHub...
git push origin main

if %errorlevel% EQU 0 (
    echo.
    echo ========================================
    echo   Successfully updated to v%new_version%!
    echo ========================================
) else (
    echo.
    echo [ERROR] Failed to push to GitHub!
)

echo.
pause
