@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║     🔮 TokenSage - Full Intercept Mode (mitmproxy)            ║
echo ║     Track ALL AI requests automatically                       ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

:: Check mitmproxy
where mitmdump >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] mitmproxy not found!
    echo.
    echo Please install mitmproxy:
    echo   pip install mitmproxy
    echo   or
    echo   choco install mitmproxy
    echo.
    pause
    exit /b 1
)

:: Check if TokenSage is running
curl -s http://localhost:4000/health >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Starting TokenSage server...
    start /b cmd /c "node dist/proxy.js"
    timeout /t 2 /nobreak >nul
)

echo [INFO] Starting mitmproxy intercept...
echo.
echo ───────────────────────────────────────────────────────────────
echo   Proxy:      http://localhost:8080
echo   Dashboard:  http://localhost:4001
echo ───────────────────────────────────────────────────────────────
echo.
echo   IMPORTANT: Configure Windows proxy or app to use localhost:8080
echo.
echo   For system-wide proxy:
echo   Settings ^> Network ^> Proxy ^> Manual proxy
echo   Address: 127.0.0.1  Port: 8080
echo.
echo   First time? Install certificate:
echo   1. Visit http://mitm.it in browser (while proxy is on)
echo   2. Download and install Windows certificate
echo ───────────────────────────────────────────────────────────────
echo.
echo   Press Ctrl+C to stop
echo.

:: Open dashboard
start "" "http://localhost:4001"

:: Start mitmproxy with addon
mitmdump -s addon.py --set block_global=false
