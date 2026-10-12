@echo off
setlocal enabledelayedexpansion

REM =========================================================================
REM SKOPOS - Safe Server Termination Script (Windows)
REM Safely stops ONLY the SKOPOS Backend (Port 8000) and Frontend (Port 3000).
REM No other processes on the machine will be affected.
REM =========================================================================

title SKOPOS Server Stopper
chcp 65001 >nul

echo =========================================================================
echo                    SKOPOS - STOPPING SERVERS
echo =========================================================================
echo.

set "KILLED_ANY=0"

REM 1. Terminate process listening on Port 8000 (Backend)
set "STOPPED_BACKEND=0"
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8000" ^| findstr "LISTENING"') do (
    set "PID=%%a"
    if not "!PID!"=="0" if not "!PID!"=="4" (
        echo [INFO] Stopping SKOPOS Backend Server [PID: !PID!]...
        taskkill /F /T /PID !PID! >nul 2>&1
        set "STOPPED_BACKEND=1"
        set "KILLED_ANY=1"
    )
)

if "!STOPPED_BACKEND!"=="1" (
    echo [SUCCESS] Backend server [Port 8000] terminated.
) else (
    echo [INFO] No active SKOPOS backend server found on port 8000.
)

REM 2. Terminate process listening on Port 3000 (Frontend)
set "STOPPED_FRONTEND=0"
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000" ^| findstr "LISTENING"') do (
    set "PID=%%a"
    if not "!PID!"=="0" if not "!PID!"=="4" (
        echo [INFO] Stopping SKOPOS Frontend Server [PID: !PID!]...
        taskkill /F /T /PID !PID! >nul 2>&1
        set "STOPPED_FRONTEND=1"
        set "KILLED_ANY=1"
    )
)

if "!STOPPED_FRONTEND!"=="1" (
    echo [SUCCESS] Frontend server [Port 3000] terminated.
) else (
    echo [INFO] No active SKOPOS frontend server found on port 3000.
)

REM 3. Cleanly close any terminal windows created specifically for SKOPOS
taskkill /F /FI "WINDOWTITLE eq SKOPOS_BACKEND_SERVER*" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq SKOPOS_FRONTEND_SERVER*" >nul 2>&1

echo.
echo =========================================================================
if "!KILLED_ANY!"=="1" (
    echo [DONE] SKOPOS servers stopped safely. No other processes were touched.
) else (
    echo [DONE] No running SKOPOS servers were detected.
)
echo =========================================================================
echo.
ping 127.0.0.1 -n 3 >nul
