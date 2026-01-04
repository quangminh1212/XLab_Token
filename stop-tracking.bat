@echo off
echo Stopping TokenSage and disabling proxy...

:: Disable Windows system proxy
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul

:: Kill processes
taskkill /f /im mitmdump.exe >nul 2>&1
taskkill /f /im node.exe >nul 2>&1

echo Done. System proxy disabled.
pause
