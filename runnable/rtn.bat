set DIRNAME=.\
if "%OS%" == "Windows_NT" set DIRNAME=%~dp0%
cd /D "%DIRNAME%"
start "tn" "$java.executable" -Drtn.log.dir="$appdata.install.path" -jar rtn.jar
