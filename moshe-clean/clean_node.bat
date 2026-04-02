@echo off
setlocal

REM Get directory from first argument
set target=%~1

if "%target%"=="" (
    echo ERROR: No directory provided.
    echo Usage: clean_env.bat "D:\path\to\folder"
    exit /b 1
)

echo Preparing %target% ...

REM If exists, remove it
if exist "%target%" (
    echo Removing existing directory...
    rmdir /s /q "%target%"
)

REM Create directory (always runs)
echo Creating directory...
mkdir "%target%" 2>nul

REM Verify creation
if exist "%target%" (
    echo Ready: %target%
) else (
    echo ERROR: Failed to create %target%
    exit /b 1
)

endlocal