@echo off
for /d %%D in ("%LOCALAPPDATA%\GitHubDesktop\app-*") do (
    if exist "%%D\resources\app\git\cmd\git.exe" set "PATH=%PATH%;%%D\resources\app\git\cmd"
)
echo ========================================================
echo   Siya Bill POS - Push to GitHub
echo   Target: https://github.com/siyabill/restaurantpos.git
echo ========================================================
echo.
echo Pushing committed code to GitHub...
echo.
git push -u origin main
echo.
if %ERRORLEVEL% EQU 0 (
    echo ========================================================
    echo   SUCCESS! All code has been pushed to GitHub.
    echo ========================================================
) else (
    echo ========================================================
    echo   Push failed. Please check your credentials or access rights.
    echo ========================================================
)
echo.
pause
