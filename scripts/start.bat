@echo off
setlocal enabledelayedexpansion

REM =========================================================================
REM SKOPOS - Server Startup Script (Windows)
REM Starts Backend (FastAPI on Port 8000) and Frontend (HTML MVP on Port 3000)
REM in dedicated terminal windows.
REM =========================================================================

title SKOPOS Server Launcher
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "PROJECT_ROOT=%%~fI"

echo =========================================================================
echo                    SKOPOS - AI WRITING ENGINE
echo                   Starting Development Servers
echo =========================================================================
echo.
echo [INFO] Project Root: %PROJECT_ROOT%
echo.

REM 1. Verify virtual environment exists
if not exist "%PROJECT_ROOT%\backend\.venv\Scripts\python.exe" (
    echo [ERROR] Python virtual environment not found at:
    echo         %PROJECT_ROOT%\backend\.venv
    echo.
    echo Please set up the virtual environment first:
    echo   cd /d "%PROJECT_ROOT%\backend"
    echo   python -m venv .venv
    echo   .\.venv\Scripts\pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

REM 2. Check if Backend port 8000 is already in use
set "BACKEND_RUNNING=0"
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8000" ^| findstr "LISTENING"') do (
    set "BACKEND_RUNNING=1"
    set "BACKEND_PID=%%a"
)

if "!BACKEND_RUNNING!"=="1" (
    echo [WARNING] Backend port 8000 is already in use by PID: !BACKEND_PID!
    echo           Skipping backend launch. Use stop.bat first to reset.
) else (
    echo [INFO] Launching SKOPOS Backend Server [Port 8000]...
    start "SKOPOS_BACKEND_SERVER" /D "%PROJECT_ROOT%\backend" cmd /k "title SKOPOS_BACKEND_SERVER & call .venv\Scripts\activate.bat & uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"
)

REM 3. Check if Frontend port 3000 is already in use
set "FRONTEND_RUNNING=0"
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000" ^| findstr "LISTENING"') do (
    set "FRONTEND_RUNNING=1"
    set "FRONTEND_PID=%%a"
)

if "!FRONTEND_RUNNING!"=="1" (
    echo [WARNING] Frontend port 3000 is already in use by PID: !FRONTEND_PID!
    echo           Skipping frontend launch. Use stop.bat first to reset.
) else (
    echo [INFO] Launching SKOPOS Frontend Web Client [Port 3000]...
    start "SKOPOS_FRONTEND_SERVER" /D "%PROJECT_ROOT%\frontend\html-mvp" cmd /k "title SKOPOS_FRONTEND_SERVER & ..\..\backend\.venv\Scripts\python.exe -m http.server 3000"
)

echo.
echo =========================================================================
echo                  SKOPOS SERVERS INITIALIZED
echo =========================================================================
echo.
echo   - Frontend Interface:  http://localhost:3000
echo   - Backend Health:      http://localhost:8000/api/v1/health
echo   - Interactive API:     http://localhost:8000/docs
echo.
echo   Dedicated terminal windows have been opened for each service.
echo   To safely stop only these project servers, run:
echo     %SCRIPT_DIR%stop.bat
echo =========================================================================
echo.
ping 127.0.0.1 -n 4 >nul
