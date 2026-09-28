@echo off
set "PATH=%PATH%;C:\Users\khana\AppData\Local\GitHubDesktop\app-3.6.4\resources\app\git\cmd"
echo ========================================================
echo   Siya Bill POS - Push to GitHub
echo   Target: https://github.com/siyabill/restaurantpos.git
echo ========================================================
echo.
echo Pushing committed code to GitHub...
echo If prompted, please sign into your GitHub account (siyabill) in the browser.
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
