@echo off

"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
set "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

choco install -y rsync
