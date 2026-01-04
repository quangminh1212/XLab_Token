@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║              🔮 TokenSage - AI Usage Tracker                  ║
echo ║              Track your AI token usage and costs              ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

:: Check Node.js
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js not found! Please install Node.js 18+
    echo         Download: https://nodejs.org/
    pause
    exit /b 1
)

:: Check if built
if not exist "dist\proxy.js" (
    echo [INFO] Building project...
    call npm run build
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Build failed!
        pause
        exit /b 1
    )
)

:: Set environment
set PROXY_PORT=4000
set DASHBOARD_PORT=4001

echo.
echo ───────────────────────────────────────────────────────────────
echo   Dashboard:  http://localhost:%DASHBOARD_PORT%
echo   Proxy:      http://localhost:%PROXY_PORT%
echo   Stats API:  http://localhost:%PROXY_PORT%/stats
echo ───────────────────────────────────────────────────────────────
echo.
echo   Configure your AI IDE to use the proxy:
echo.
echo   • Cursor: Settings ^> Models ^> Override OpenAI Base URL
echo     Enter: http://localhost:%PROXY_PORT%/v1
echo.
echo   • Windsurf: Settings ^> API Configuration ^> Base URL
echo     Enter: http://localhost:%PROXY_PORT%/v1
echo.
echo   • Kiro/Other: Set environment variable
echo     OPENAI_BASE_URL=http://localhost:%PROXY_PORT%/v1
echo ───────────────────────────────────────────────────────────────
echo.
echo   Press Ctrl+C to stop
echo.

:: Open dashboard in browser
start "" "http://localhost:%DASHBOARD_PORT%"

:: Start server
node dist/proxy.js
