set DIRNAME=.\
if "%OS%" == "Windows_NT" set DIRNAME=%~dp0%
cd /D "%DIRNAME%"
start "tn" "$java.path\bin\javaw.exe" -Drtn.log.dir="$appdata.install.path" -jar rtn.jar
