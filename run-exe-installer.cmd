@echo off
call setenv.bat
call prepare_for_target_os.cmd windows
start "" "dist\%INSTALLER_EXE%"