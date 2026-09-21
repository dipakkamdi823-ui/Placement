@echo off
title Create Clean Project Zip for Sharing
color 0E
echo ================================================================
echo   PACKAGING PROJECT FOR SHARING (EXCLUDING NODE_MODULES / VENV)
echo ================================================================
echo.

python "%~dp0bundle_project.py"

if %errorlevel% neq 0 (
    color 0C
    echo [ERROR] Failed to create zip file!
    pause
    exit /b 1
)

color 0A
echo You can now send "SAIOTAF_Project_Clean.zip" to the other person!
echo.
pause
