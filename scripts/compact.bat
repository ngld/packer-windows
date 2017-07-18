@echo off

cd /D C:\Windows\Temp

echo ==^> Installing tools...

choco install -y 7zip wget
choco install -y ultradefrag --params="'/NoShellExtension /DisableUsageTracking /NoBootInterface'"

if exist sdelete.exe goto :skip_sd_extract
if exist SDelete.zip goto :skip_sd_dl

wget -q -Osdelete.zip https://dev.tproxy.de/mirror/sdelete_1.6.zip

:skip_sd_dl
7z x sdelete.zip

:skip_sd_extract

echo ==^> Deleting downloaded updates...
net stop wuauserv
rmdir /S /Q C:\Windows\SoftwareDistribution\Download
mkdir C:\Windows\SoftwareDistribution\Download
net start wuauserv

del \packer_server.txt

echo ==^> Defragmenting hard drive...
udefrag --optimize --repeat C:

echo ==^> Uninstalling used tools...
choco uninstall -y wget ultradefrag 7zip

echo ==^> Zeroing unused sectors (for a smaller disk image)...
reg ADD HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f
sdelete.exe -q -z C:

echo ==^> Deleting temporary files...
start cmd /C del /S /Q C:\Windows\Temp
