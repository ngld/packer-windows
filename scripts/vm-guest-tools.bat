@echo off

set /P PACKER_BUILDER_TYPE= < C:\packer_build.txt
choco install -y 7zip wget

if "%PACKER_BUILDER_TYPE%" equ "vmware-iso" goto :vmware
if "%PACKER_BUILDER_TYPE%" equ "virtualbox-iso" goto :virtualbox
if "%PACKER_BUILDER_TYPE%" equ "parallels-iso" goto :parallels

echo ### WARNING! Unsupported builder "%PACKER_BUILDER_TYPE%" detected. VM tools will not be installed!
goto :done

:vmware

cd C:\Windows\Temp
if exist "C:\Users\vagrant\windows.iso" (
    move /Y C:\Users\vagrant\windows.iso .
)

if not exist "windows.iso" (
    wget -Ovmware-tools.tar "http://softwareupdate.vmware.com/cds/vmw-desktop/ws/12.0.0/2985596/windows/packages/tools-windows.tar"
    7z x C:\Windows\Temp\vmware-tools.tar
    FOR /r . %%a in (VMware-tools-windows-*.iso) DO REN "%%~a" "windows.iso"
    rd /S /Q "C:\Program Files (x86)\VMWare"
)

7z x -oVMWare windows.iso
.\VMWare\setup.exe /S /v"/qn REBOOT=R\"

goto :done

:virtualbox

cd C:\Windows\Temp
move /Y C:\Users\vagrant\VBoxGuestAdditions.iso .
7z x -ovirtualbox VBoxGuestAdditions.iso

:: There needs to be Oracle CA (Certificate Authority) certificates installed in order
:: to prevent user intervention popups which will undermine a silent installation.
cd virtualbox\cert
VBoxCertUtil add-trusted-publisher vbox-sha1.cer --root vbox-sha1.cer
VBoxCertUtil add-trusted-publisher vbox-sha256.cer --root vbox-sha256.cer
VBoxCertUtil add-trusted-publisher vbox-sha256-r3.cer --root vbox-sha256-r3.cer

cd ..
VBoxWindowsAdditions.exe /S
cd ..
rd /S /Q virtualbox
goto :done

:parallels
if exist "C:\Users\vagrant\prl-tools-win.iso" (
	move /Y C:\Users\vagrant\prl-tools-win.iso C:\Windows\Temp
	7z x -oC:\Windows\Temp\parallels C:\Windows\Temp\prl-tools-win.iso
	C:\Windows\Temp\parallels\PTAgent.exe /install_silent
	rd /S /Q "c:\Windows\Temp\parallels"
)

:done
