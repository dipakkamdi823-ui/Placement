@echo off
set "PATH=%LOCALAPPDATA%\Programs\Git\cmd;%PATH%"
cd /d "%~dp0"
echo =========================================================
echo  Pushing Placement Codebase to GitHub (dipakkamdi823-ui)
echo =========================================================
echo.
git remote remove origin 2>nul
git remote add origin https://github.com/dipakkamdi823-ui/Placement.git
git branch -M main
echo.
echo Pushing branch 'main' to https://github.com/dipakkamdi823-ui/Placement.git ...
echo (If a GitHub sign-in window appears, click "Sign in with your browser")
echo.
git push -u origin main
echo.
if %ERRORLEVEL% EQU 0 (
    echo =========================================================
    echo  SUCCESS! Code pushed successfully to GitHub!
    echo =========================================================
) else (
    echo [ERROR] Push failed. Please verify your GitHub login or token.
)
echo.
pause
