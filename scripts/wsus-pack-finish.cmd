@echo off

reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v WSUSOfflineUpdate >nul 2>&1
if not errorlevel 1 goto :skip

echo Creating clean up hook...
pushd C:\wsus

echo @echo off > clean.bat
echo sc config OpenSSHd start= auto >> clean.bat
echo sc config winrm start= auto >> clean.bat
echo net start OpenSSHd >> clean.bat
echo net start winrm >> clean.bat
echo start cmd /C rd /S /Q C:\wsus >> clean.bat

popd

reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v DeleteWSUSDir /t REG_SZ /d "cmd /c C:\wsus\clean.bat" /f >nul 2>&1

: WSUS Offline overwrites and later restores most keys under HKLM\...\Winlogon, 
: However, it doesn't restore the DefaultPassword key which is why we manually restore it here.
reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d "vagrant" /f >nul 2>&1
goto :eof

:skip
echo WSUS Offline is not yet done.
echo.
echo ---- The VM will now restart. Packer will wait until all updates are installed.
echo ---- That means that it will be stuck on "Waiting for machine to restart..." for a while (up to 2 hours).
echo ---- If you still want to see progress, look at the VM's screen.
echo.
