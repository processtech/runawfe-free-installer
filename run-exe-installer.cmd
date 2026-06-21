@echo off
call setenv.bat
call prepare_for_target_os.cmd win7-vm
start "" "dist\%INSTALLER_EXE%"