set PROJECT_ROOT=%~dp0
set WFE_APPNAME=RunaWFE_test
set WFE_EDITION=Free
set WFE_VERSION=4.6.0
set INSTALLER_EXE=%WFE_APPNAME%-%WFE_EDITION%-%WFE_VERSION%.exe
set COMPILER_PATH="C:\Program Files\IzPack\bin\compile.bat"
set XML_FILE=RunaWFE_installer.xml
set IZPACK_OPTS=-Dfile.encoding=UTF-8
set BUILD_ROOT=C:\runawfe-professional-autobuild\build\source\projects\installer\windows\target\NSIS7\src
set SVCNAME=JBAS50SVC
set STATISTIC_REPORT_URL=https://usagereport.runawfe.org
set STATISTIC_REPORT_DAYS_AFTER_ERROR=11
set LAUNCHER_JRE=%~dp0resources\launch_jre
set RCEDIT=%PROJECT_ROOT%tools\rcedit\rcedit-x64.exe
set IZPACK_WRAPPER=C:\Program Files\IzPack\utils\wrappers\izpack2exe
set INSTALL_JAR=%PROJECT_ROOT%\install.jar
set INSTALLER_ICON=resources\images\wf_48x128.ico