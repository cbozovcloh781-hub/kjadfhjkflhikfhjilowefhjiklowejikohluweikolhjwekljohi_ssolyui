@echo off
echo ========================================
echo   Ssoly UI Library - GitHub Updater
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] Checking changes...
git status

echo.
echo [2/4] Adding all files...
git add .

echo.
set /p commit_msg="Enter commit message (or press Enter for auto): "
if "%commit_msg%"=="" set commit_msg=Update library files

echo.
echo [3/4] Creating commit: %commit_msg%
git commit -m "%commit_msg%"

echo.
echo [4/4] Pushing to GitHub...
git push origin main

echo.
echo ========================================
echo   Update completed!
echo ========================================
echo.
pause
