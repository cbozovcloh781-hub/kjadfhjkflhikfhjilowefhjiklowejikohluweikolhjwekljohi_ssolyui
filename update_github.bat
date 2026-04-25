@echo off
echo ========================================
echo Ssoly UI - GitHub Update Script
echo ========================================
echo.

cd /d "e:\folders\codes\roblox\games\yba\ssoly"

echo Adding all changes...
git add .

echo.
set /p COMMIT_MSG="Enter commit message (or press Enter for default): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=Update UI fixes

echo.
echo Creating commit...
git commit -m "%COMMIT_MSG%"

echo.
echo Pushing to GitHub...
git push

echo.
echo ========================================
echo Update complete!
echo Changes are now live on GitHub
echo ========================================
pause
