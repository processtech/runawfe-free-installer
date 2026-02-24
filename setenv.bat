set WFE_APPNAME=RunaWFE_test
set WFE_EDITION=Free
set WFE_VERSION=4.6.0
set INSTALLER_EXE=%WFE_APPNAME%-%WFE_EDITION%-%WFE_VERSION%.exe
set COMPILER_PATH="C:\Program Files\IzPack\bin\compile.bat"
set XML_FILE=RunaWFE_installer.xml
set IZPACK_OPTS=-Dfile.encoding=UTF-8
set BUILD_ROOT=C:\runawfe-free-autobuild\build\source\projects\installer\windows\target\NSIS7\src
set SVCNAME=JBAS50SVC
set STATISTIC_REPORT_URL=https://usagereport.runawfe.org
set STATISTIC_REPORT_DAYS_AFTER_ERROR=11
set LAUNCHER_JRE=%~dp0resources\launch_jre
set WFE_JRE=C:\Users\plete\.jdks\jdk-11.0.29+7-jre