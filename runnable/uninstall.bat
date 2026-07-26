@echo off
set "TEMP_DIR=%TEMP%\RunaWFE_uninstall_java_%RANDOM%"
xcopy "$java.path\*.*" "%TEMP_DIR%\java\" /E /I /Y /Q >nul 2>&1
set "VBS=%TEMP_DIR%\uninstall_helper.vbs"

echo Set WshShell = CreateObject("WScript.Shell") > "%VBS%"
echo Set fso = CreateObject("Scripting.FileSystemObject") >> "%VBS%"
echo Set args = WScript.Arguments >> "%VBS%"
echo quote = chr(34) >> "%VBS%"
echo javaPath = quote ^& args(0) ^& quote >> "%VBS%"
echo jarPath = quote ^& args(1) ^& quote >> "%VBS%"
echo jvmArgs = "-Dfile.encoding=UTF-8 -Dconsole.encoding=UTF-8" >> "%VBS%"
echo cmdLine = javaPath ^& " " ^& jvmArgs ^& " -jar " ^& jarPath >> "%VBS%"
echo WshShell.Run cmdLine, 0, True >> "%VBS%"
echo WScript.Sleep 40000 >> "%VBS%"
echo On Error Resume Next >> "%VBS%"
echo fso.DeleteFolder "%TEMP_DIR%", True >> "%VBS%"

if exist "$INSTALL_PATH\$server.subpath\remove_server_service.bat" (
    call "$INSTALL_PATH\$server.subpath\remove_server_service.bat" >nul 2>&1
)

start "" /b wscript.exe //B "%VBS%" "%TEMP_DIR%\java\bin\javaw.exe" "$INSTALL_PATH\Uninstaller\uninstaller.jar"
exit /b 0
