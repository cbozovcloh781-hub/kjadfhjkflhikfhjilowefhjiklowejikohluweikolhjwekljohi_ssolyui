@echo off
echo ========================================
echo Ssoly UI - GitHub Upload Script
echo ========================================
echo.

cd /d "e:\folders\codes\roblox\games\yba\ssoly"

echo Initializing Git repository...
git init

echo Adding all files...
git add .

echo Creating commit...
git commit -m "Initial commit - Ssoly UI v1.0"

echo.
echo ========================================
echo IMPORTANT: Enter your GitHub repo URL
echo Example: https://github.com/USERNAME/ssoly-ui.git
echo ========================================
set /p REPO_URL="Enter GitHub repo URL: "

echo.
echo Adding remote origin...
git remote add origin %REPO_URL%

echo.
echo Pushing to GitHub...
git branch -M main
git push -u origin main

echo.
echo ========================================
echo Upload complete!
echo Your UI is now available at:
echo https://raw.githubusercontent.com/USERNAME/ssoly-ui/main/init.lua
echo ========================================
pause
