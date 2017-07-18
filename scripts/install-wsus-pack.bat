@echo off

if not exist C:\wsus mkdir C:\wsus
cd /D C:\wsus

: For some reason the OpenSSH server doesn't properly forward environment variables.
: Since it works powershell scripts, I used a PS script to write the value to a text file which we read here.
set WIN_NAME=%1
set /P PACKER_HTTP_ADDR= < \packer_server.txt

echo ==^> Fetching tools...
: The file provisioner tends to hang which seems to be the SSH's server fault (it causes high CPU load
: but doesn't write anything to disk). It doesn't happen every time, only sometimes. To avoid that annoyance,
: I simply download the files from packer's HTTP server. I need it for the big pack, anyway. (That file is usually several GB.)

powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%PACKER_HTTP_ADDR%/wsusoffline/bin/wget.exe', 'wget.exe')" <NUL
wget -q "%PACKER_HTTP_ADDR%/wsusoffline/bin/unzip.exe"

echo ==^> Fetching update pack...
wget -Opack.zip --progres=dot:giga "%PACKER_HTTP_ADDR%/wsusoffline/wsus-pack-%WIN_NAME%.zip"
if errorlevel 1 goto :pack_missing

echo ==^> Extracting...
unzip pack.zip
del pack.zip

wget -q -Ocmd/custom/FinalizationHook.cmd "%PACKER_HTTP_ADDR%/scripts/wsus-pack-finish.cmd"

echo ==^> Disabling SSH and WinRM service to pause provisions...
sc config OpenSSHd start= disabled
sc config winrm start= disabled

net stop OpenSSHd
net stop winrm

goto :eof

:pack_missing
echo.
echo   ERROR: The WSUS pack for %1 is missing! Please run ^"./wsusoffline.sh %WIN_NAME%^" before running Packer.
exit /b 1
