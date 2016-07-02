!ifndef INSTALL_SEQUENCES_NSH
!define INSTALL_SEQUENCES_NSH

!include "languages.nsh"
!include x64.nsh
!include "JDKInstallSupport.nsh"
!include "nsisxml.nsh"

var WFEServerAddress
var WFEServerPort
var installDesctopLinks
var newSimulationDatabase
var newWorkspace
var simulationWebLinks
var cleanAllOldData ; Remove all artifacts from old installation if exists

#=======================================Macros for creating shortcuts and URLs (support create desktop icons)=======================================
!macro createMenuShortcut ShortcutName ShortcutTarget ShortcutParameters ShortcutDir ShortcutIcon ShortcutDesc
  !insertmacro Runa_SetOutPath "$SMPROGRAMS\${AppName}"
  SetOutPath "$SMPROGRAMS\${AppName}"
  CreateShortCut "$SMPROGRAMS\${AppName}\${ShortcutName}" "${ShortcutTarget}" "${ShortcutParameters}" "${ShortcutIcon}" 0 "" "" "${ShortcutDesc}"
  ${ifnot} "$installDesctopLinks" == "0"
    !insertmacro Runa_SetOutPath "$Desktop"
    SetOutPath "$Desktop"  #${ShortcutDir}
    CreateShortCut "$Desktop\${ShortcutName}" "${ShortcutTarget}" "${ShortcutParameters}" "${ShortcutIcon}" 0 "" "" "${ShortcutDesc}"
    System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'
  ${endif}
!macroend
!macro createURL URLName URLTarget URLIcon
  !insertmacro Runa_SetOutPath "$SMPROGRAMS\${AppName}"
  WriteIniStr "$SMPROGRAMS\${AppName}\${URLName}" "InternetShortcut" "URL" "${URLTarget}"
  WriteIniStr "$SMPROGRAMS\${AppName}\${URLName}" "InternetShortcut" "IconIndex" "0"
  WriteIniStr "$SMPROGRAMS\${AppName}\${URLName}" "InternetShortcut" "IconFile" "${URLIcon}"
  ${ifnot} "$installDesctopLinks" == "0"
    !insertmacro Runa_SetOutPath "$Desktop"
    WriteIniStr "$Desktop\${URLName}" "InternetShortcut" "URL" "${URLTarget}"
    WriteIniStr "$Desktop\${URLName}" "InternetShortcut" "IconIndex" "0"
    WriteIniStr "$Desktop\${URLName}" "InternetShortcut" "IconFile" "${URLIcon}"
    System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'
  ${endif}
!macroend
#=======================================Macros for customize customizing components=======================================
!macro CreateRunSimulationBatchFile
  GetTempFileName $0
  GetFileTime $0 $1 $2
  Delete $0

  SetShellVarContext all
  Delete "$INSTDIR\Simulation\bin\runSimulation.bat"
  FileOpen $0 "$INSTDIR\Simulation\bin\runSimulation.bat" w
  FileWrite $0 "@echo off$\r$\n"
  FileWrite $0 "set DIRNAME=.\$\r$\n"
  FileWrite $0 "if $\"%OS%$\" == $\"Windows_NT$\" set DIRNAME=$\"%~dp0%$\"$\r$\n"
  FileWrite $0 "cd /D $\"%DIRNAME%$\"$\r$\n"
  FileWrite $0 "mkdir $\"%TEMP%\runawfe/jboss$\"$\r$\n"
  FileWrite $0 "mkdir $\"%APPDATA%\runawfe/jboss$\"$\r$\n"
  ${if} "$cleanAllOldData" == "1"
    FileWrite $0 "if not exist $\"%APPDATA%\runawfe\jboss\runawfe-clean-ver-$2$\" ($\r$\n"
    FileWrite $0 "  del /F /S /Q $\"%APPDATA%\runawfe\jboss$\"$\r$\n"
    FileWrite $0 "  rd /S /Q $\"%APPDATA%\runawfe\jboss$\"$\r$\n"
    FileWrite $0 "  mkdir $\"%APPDATA%\runawfe\jboss$\"$\r$\n"
    FileWrite $0 "  del /S /Q $\"%APPDATA%\runawfe\jboss\runawfe-clean-ver-*$\" $\r$\n"
    FileWrite $0 "  time /T >$\"%APPDATA%\runawfe\jboss\runawfe-clean-ver-$2$\" $\r$\n"
    FileWrite $0 ")$\r$\n"
  ${endif}
  FileWrite $0 "del /F /S /Q $\"%APPDATA%\runawfe\jboss\configuration$\"$\r$\n"
  FileWrite $0 "del /F /S /Q $\"%APPDATA%\runawfe\jboss\deployments$\"$\r$\n"
  FileWrite $0 "del /F /S /Q $\"%APPDATA%\runawfe\jboss\wfe.custom$\"$\r$\n"
  FileWrite $0 "xcopy ..\standalone\configuration $\"%APPDATA%\runawfe\jboss\configuration$\" /D /I /S /Y /R$\r$\n"
  FileWrite $0 "xcopy ..\standalone\deployments $\"%APPDATA%\runawfe\jboss\deployments$\" /D /I /S /Y /R$\r$\n"
  FileWrite $0 "xcopy ..\standalone\wfe.custom $\"%APPDATA%\runawfe\jboss\wfe.custom$\" /D /I /S /Y /R$\r$\n"
  ${if} "$newSimulationDatabase" == "1"
    FileWrite $0 "if not exist $\"%APPDATA%\runawfe\jboss\runawfe-ver-$2$\" ($\r$\n"
    FileWrite $0 "  del /F /S /Q $\"%APPDATA%\runawfe\jboss\data$\"$\r$\n"
    FileWrite $0 "  del /S /Q $\"%APPDATA%\runawfe\jboss\runawfe-ver-*$\" $\r$\n"
    FileWrite $0 "  time /T >$\"%APPDATA%\runawfe\jboss\runawfe-ver-$2$\" $\r$\n"
    FileWrite $0 "  xcopy ..\standalone\data\demo-db $\"%APPDATA%\runawfe\jboss\data\h2$\" /D /I /S /Y /R$\r$\n"
    FileWrite $0 ") else ($\r$\n"
    FileWrite $0 "  if not exist $\"%APPDATA%\runawfe\jboss\data$\" ($\r$\n"
    FileWrite $0 "    xcopy ..\standalone\data\demo-db $\"%APPDATA%\runawfe\jboss\data\h2$\" /D /I /S /Y /R$\r$\n"
    FileWrite $0 "  )$\r$\n"
    FileWrite $0 ")$\r$\n"
  ${else}
    FileWrite $0 "if not exist $\"%APPDATA%\runawfe\jboss\data$\" ($\r$\n"
    FileWrite $0 "  xcopy ..\standalone\data\demo-db $\"%APPDATA%\runawfe\jboss\data\h2$\" /D /I /S /Y /R$\r$\n"
    FileWrite $0 ")$\r$\n"
  ${endif}
  FileWrite $0 "del /F /S /Q %TEMP%\runawfe$\r$\n"
  FileWrite $0 "rd /S /Q %TEMP%\runawfe$\r$\n"
  FileWrite $0 "SET JBOSS_LOG_DIR=$\"%TEMP%\runawfe\jboss\log$\"$\r$\n"
  FileWrite $0 "call standalone.bat $\"-Djboss.server.log.dir=%TEMP%\runawfe\jboss\log$\" $\"-Djboss.server.temp.dir=%TEMP%\runawfe\jboss\tmp$\" $\"-Djboss.server.base.dir=%APPDATA%\runawfe\jboss$\"$\r$\n"
  FileClose $0
!macroend
!macro CreateRunGPDBatchFile
  SetShellVarContext all
  GetTempFileName $0
  GetFileTime $0 $1 $2
  Delete $0

  FileOpen $0 "$INSTDIR\gpd\run.bat" w
  FileWrite $0 "@echo off$\r$\n"
  FileWrite $0 "set DIRNAME=.\$\r$\n"
  FileWrite $0 "if $\"%OS%$\" == $\"Windows_NT$\" set DIRNAME=%~dp0%$\r$\n"
  FileWrite $0 "cd /D $\"%DIRNAME%$\"$\r$\n"
  FileWrite $0 "mkdir $\"%APPDATA%\runawfe\gpd$\"$\r$\n"
  ${if} "$cleanAllOldData" == "1"
    FileWrite $0 "if not exist $\"%APPDATA%\runawfe\gpd\runawfe-clean-ver-$2$\" ($\r$\n"
    FileWrite $0 "  del /F /S /Q $\"%APPDATA%\runawfe\gpd$\"$\r$\n"
    FileWrite $0 "  rd /S /Q $\"%APPDATA%\runawfe\gpd$\"$\r$\n"
    FileWrite $0 "  mkdir $\"%APPDATA%\runawfe\gpd$\"$\r$\n"
    FileWrite $0 "  del /S /Q $\"%APPDATA%\runawfe\gpd\runawfe-clean-ver-*$\" $\r$\n"
    FileWrite $0 "  time /T >$\"%APPDATA%\runawfe\gpd\runawfe-clean-ver-$2$\" $\r$\n"
    FileWrite $0 ")$\r$\n"
  ${endif}
  ${if} "$newWorkspace" == "1"
    FileWrite $0 "if not exist $\"%APPDATA%\runawfe\gpd\runawfe-ver-$2$\" ($\r$\n"
    FileWrite $0 "  del /S /Q $\"%APPDATA%\runawfe\gpd\runawfe-ver-*$\" $\r$\n"
    FileWrite $0 "  time /T >$\"%APPDATA%\runawfe\gpd\runawfe-ver-$2$\" $\r$\n"
    FileWrite $0 "  del /S /Q $\"%APPDATA%\runawfe\gpd\workspace\.metadata$\" $\r$\n"
    FileWrite $0 "  xcopy demo-workspace $\"%APPDATA%\runawfe\gpd\workspace$\" /I /S /E /Y /R$\r$\n"
    FileWrite $0 ") else ($\r$\n"
    FileWrite $0 "  if not exist $\"%APPDATA%\runawfe\gpd\workspace$\" ($\r$\n"
    FileWrite $0 "    xcopy demo-workspace $\"%APPDATA%\runawfe\gpd\workspace$\" /I /S /E /Y /R$\r$\n"
    FileWrite $0 "  )$\r$\n"
    FileWrite $0 ")$\r$\n"
  ${else}
    FileWrite $0 "if not exist $\"%APPDATA%\runawfe\gpd\workspace$\" ($\r$\n"
    FileWrite $0 "    xcopy demo-workspace $\"%APPDATA%\runawfe\gpd\workspace$\" /I /S /E /Y /R$\r$\n"
    FileWrite $0 ")$\r$\n"
  ${endif}
  FileWrite $0 "start /B /D$\"%DIRNAME%$\" runa-gpd.exe -data $\"%APPDATA%\runawfe\gpd\workspace$\"$\r$\n"
  FileClose $0
!macroend
!macro RtnWebBotCustomizableMacro sectionLangName
  SetShellVarContext all
  ${if} "$reinstallCustomizable" == "1"
    call "RemoveComponent_${sectionLangName}"
    !insertmacro SaveSectionStatus ${sectionLangName} 0
  ${endif}
!macroend
!macro DefaultCustomizableMacro sectionLangName
!macroend
!macro SimCustomizableMacro sectionLangName
  !insertmacro Runa_SetOutPath "$INSTDIR\Simulation\bin"
  !insertmacro CreateRunSimulationBatchFile
!macroend
!macro GpdCustomizableMacro sectionLangName
  !insertmacro Runa_SetOutPath "$INSTDIR\gpd"
  !insertmacro CreateRunGPDBatchFile
!macroend
#=======================================Installation macros=======================================
!macro installGPDSeq
  SetShellVarContext all
  RMDir /r "$PROFILE\.eclipse"
  !insertmacro Runa_SetOutPath "$INSTDIR\Icons"
  File "${BuildRoot}\Icons\e_20x20_256.ico"
  RMDir /r "$INSTDIR\gpd\configuration"
  !insertmacro Runa_SetOutPath "$INSTDIR\gpd"
  Call DetectJava64
  ${if} ${RunningX64} 
    ${if} "$JdkArch" == "64"
      File /r "${BuildRoot}\gpd\64\gpd-${AppVersion}\*"
    ${else}
      File /r "${BuildRoot}\gpd\32\gpd-${AppVersion}\*"
    ${endif}
  ${else}
    File /r "${BuildRoot}\gpd\32\gpd-${AppVersion}\*"
  ${endif}
  !insertmacro CreateRunGPDBatchFile
  !insertmacro createMenuShortcut "Process designer.lnk" "$INSTDIR\gpd\run.bat" "" "$INSTDIR\gpd" "$INSTDIR\Icons\E_20x20_256.ico" "$(ShortcutDesc_GPD)"
!macroend

!macro installRTNSeq
  SetShellVarContext all
  !insertmacro Runa_SetOutPath "$INSTDIR\Icons"
  File "${BuildRoot}\Icons\T_20x20_256.ico"
  !insertmacro Runa_SetOutPath "$INSTDIR\rtn"
  ${if} ${RunningX64} 
    ${if} "$JdkArch" == "64"
      File /r "${BuildRoot}\rtn-${AppVersion}\64\*"
    ${else}
      File /r "${BuildRoot}\rtn-${AppVersion}\32\*"
    ${endif}
  ${else}
    File /r "${BuildRoot}\rtn-${AppVersion}\32\*"
  ${endif}

  Push "wfe_server"                            #text to be replaced
  Push $WFEServerAddress                       #replace with
  Push "$INSTDIR\rtn\af_delegate.properties"   #file to replace in
  Call AdvReplaceInFile                        #call find and replace function

  Push "wfe_server"                            #text to be replaced
  Push $WFEServerAddress                       #replace with
  Push "$INSTDIR\rtn\application.properties"   #file to replace in
  Call AdvReplaceInFile                        #call find and replace function

  Push "port"                                  #text to be replaced
  Push $WFEServerPort                          #replace with
  Push "$INSTDIR\rtn\application.properties"   #file to replace in
  Call AdvReplaceInFile                        #call find and replace function

  Push "8080"                                  #text to be replaced
  Push $WFEServerPort                          #replace with
  Push "$INSTDIR\rtn\application.properties"   #file to replace in
  Call AdvReplaceInFile                        #call find and replace function

  Push "wfe_server"                            #text to be replaced
  Push $WFEServerAddress                       #replace with
  Push "$INSTDIR\rtn\application_ru.properties" #file to replace in
  Call AdvReplaceInFile                        #call find and replace function

  Push "port"                                  #text to be replaced
  Push $WFEServerPort                          #replace with
  Push "$INSTDIR\rtn\application_ru.properties" #file to replace in
  Call AdvReplaceInFile                        #call find and replace function

  Push "8080"                                  #text to be replaced
  Push $WFEServerPort                          #replace with
  Push "$INSTDIR\rtn\application_ru.properties" #file to replace in
  Call AdvReplaceInFile                        #call find and replace function

;  Call DetectJava64
;  Push "swt-win32.jar"                         #text to be replaced
;  ${if} ${RunningX64} 
;    ${if} "$JdkArch" == "64"
;      Push "swt-win64.jar"                     #replace with
;    ${else}
;      Push "swt-win32.jar"                     #replace with
;    ${endif}
;  ${else}
;    Push "swt-win32.jar"                       #replace with
;  ${endif}
;  Push "$INSTDIR\rtn\run.bat"                  #file to replace in
;  Call AdvReplaceInFile                        #call find and replace function

  !insertmacro createMenuShortcut "Task notifier.lnk" "$INSTDIR\rtn\run.bat" "" "$INSTDIR\rtn" "$INSTDIR\Icons\T_20x20_256.ico" "$(ShortcutDesc_RTN)"
!macroend

!macro installWebSeq
  SetShellVarContext all
  !insertmacro Runa_SetOutPath "$INSTDIR\Icons"
  File "${BuildRoot}\Icons\C_20x20_256.ico"
  !insertmacro createURL "Web interface RunaWFE.URL" "http://$WFEServerAddress:$WFEServerPort/wfe" "$INSTDIR\Icons\C_20x20_256.ico"
!macroend

!macro installDocSeq
  SetShellVarContext all
  !insertmacro Runa_SetOutPath "$INSTDIR\Icons"
  File ${BuildRoot}\Icons\D_20x20_256.ico
  !insertmacro Runa_SetOutPath "$INSTDIR\Documentation"
  File /r ${BuildRoot}\Documentation\*
  !insertmacro createMenuShortcut "Documentation.lnk" "$INSTDIR\Documentation" "" "$INSTDIR\Documentation" "$INSTDIR\Icons\D_20x20_256.ico" "$(ShortcutDesc_DOC)"
!macroend

!macro installSimSeq
  SetShellVarContext all
  !insertmacro Runa_SetOutPath "$INSTDIR\Simulation"
  File /r ${BuildRoot}\wfe-simulator\*
  FileOpen $0 "$INSTDIR\Simulation\bin\runBatch.bat" w
  FileWrite $0 "@echo off$\r$\n"
  FileWrite $0 "set DIRNAME=.\$\r$\n"
  FileWrite $0 "if $\"%OS%$\" == $\"Windows_NT$\" set DIRNAME=%~dp0%$\r$\n"
  FileWrite $0 "cd /D $\"%DIRNAME%$\"$\r$\n"
  FileWrite $0 "set NOPAUSE=yes$\r$\n"
  FileWrite $0 "call %1 %2 %3 %4 %5 %6 %7$\r$\n"
  FileWrite $0 "exit$\r$\n"
  FileClose $0
  !insertmacro CreateRunSimulationBatchFile

  !insertmacro installJbossSeq Simulation
  !insertmacro Runa_SetOutPath "$INSTDIR\Icons"
  File ${BuildRoot}\Icons\SI_20x20_256.ico
  File ${BuildRoot}\Icons\CS_20x20_256.ico
  !insertmacro createURL "Simulation web interface.URL" "http://localhost:8080/wfe" "$INSTDIR\Icons\Si_20x20_256.ico"
  !insertmacro createMenuShortcut "Start Simulation.lnk" "$INSTDIR\Simulation\bin\runSimulation.bat" " " "$INSTDIR\Simulation\bin" "$INSTDIR\Icons\SI_20x20_256.ico" "$(ShortcutDesc_StartSim)"
  !insertmacro createMenuShortcut "Stop Simulation.lnk" "$INSTDIR\Simulation\bin\nircmd.exe" "exec hide $\"$INSTDIR\Simulation\bin\jboss-cli.bat$\" --commands=connect,:shutdown" "$INSTDIR\Simulation\bin" "$INSTDIR\Icons\SI_20x20_256.ico" "$(ShortcutDesc_StopSim)"
  !insertmacro Runa_SetOutPath "$INSTDIR\Simulation\standalone\wfe.custom"
  ${if} "$simulationWebLinks" == "1"
    ; Login links must be available
  ${else}
    File "${BuildRoot}\simulation.properties"
  ${endif}
!macroend

!macro installBotstationSeq
  SetShellVarContext all
  !insertmacro Runa_SetOutPath "$INSTDIR\WFEServer"
  !insertmacro installJbossSeq WFEServer
  !insertmacro Runa_SetOutPath_INSIDE_CURRENTLOG "$INSTDIR\WFEServer\standalone\deployments"
  File /r "${BuildRoot}\wfe-botstation-config\standalone\deployments\runawfe.ear"
  !insertmacro Runa_SetOutPath_INSIDE_CURRENTLOG "$INSTDIR\WFEServer\standalone\wfe.custom"
  Push "wfe_server"                            #text to be replaced
  Push $WFEServerAddress                       #replace with
  Push "$INSTDIR\WFEServer\standalone\deployments\runawfe.ear\af_delegate.properties"   #file to replace in
  Call AdvReplaceInFile                        #call find and replace function
  !insertmacro Runa_SetOutPath_INSIDE_CURRENTLOG "$INSTDIR\WFEServer\bin"
  ExecShell open "$INSTDIR\WFEServer\bin\service.bat" install SW_HIDE
  Sleep 3000
  SetRebootFlag true
!macroend

!macro installServerSeq
  SetShellVarContext all
  !insertmacro Runa_SetOutPath "$INSTDIR\WFEServer"
  !insertmacro installJbossSeq WFEServer
  !insertmacro Runa_SetOutPath_INSIDE_CURRENTLOG "$INSTDIR\WFEServer\standalone\deployments"
  File /r "${BuildRoot}\wfe-server-config\standalone\deployments" # TODO

  Push "8080"                               #text to be replaced
  Push $WFEServerPort                       #replace with
  Push "$INSTDIR\WFEServer\standalone\configuration\standalone.xml"   #file to replace in
  Call AdvReplaceInFile                     #call find and replace function

  CreateDirectory "$INSTDIR\WFEServer\standalone\wfe.custom"
${if} "$DB_Type" != "$(DB_H2_DEFAULT)"
  DetailPrint "Write database settings: $DB_Type ; Host $DB_Host:$DB_Port ; Auth $DB_Login/$DB_Password ; Database $DB_Name"
  Var /GLOBAL database_properties
  StrCpy $database_properties "$INSTDIR\WFEServer\standalone\wfe.custom\wfe.custom.database.properties"
  FileOpen $0 "$database_properties" w
  ${Switch} "$DB_Type"
    ${Case} "$(DB_POSTGRESQL)"
      FileWrite $0 "hibernate.dialect = org.hibernate.dialect.PostgreSQLDialect$\r$\n"
      FileWrite $0 "hibernate.connection.datasource = jboss/datasources/PostgreDS$\r$\n"
StrCpy $1 '<datasource jndi-name="java:jboss/datasources/PostgreDS" pool-name="PostgreDS">\
 <connection-url>jdbc:postgresql://$DB_Host:$DB_Port/$DB_Name</connection-url>\
 <driver>postgresql</driver>\
 <transaction-isolation>TRANSACTION_READ_COMMITTED</transaction-isolation>\
 <pool>\
  <min-pool-size>10</min-pool-size>\
  <max-pool-size>100</max-pool-size>\
  <prefill>true</prefill>\
 </pool>\
 <security>\
  <user-name>$DB_Login</user-name>\
  <password>$DB_Password</password>\
 </security>\
 <statement>\
  <prepared-statement-cache-size>32</prepared-statement-cache-size>\
  <share-prepared-statements>true</share-prepared-statements>\
 </statement>\
</datasource>\
<drivers>\
 <driver name="postgresql" module="org.postgresql">\
  <xa-datasource-class>org.postgresql.xa.PGXADataSource</xa-datasource-class>\
 </driver>\
</drivers>'
      ${Break}
    ${Case} "$(DB_MSSQL)"
      FileWrite $0 "hibernate.dialect = org.hibernate.dialect.SQLServerDialect$\r$\n"
      FileWrite $0 "hibernate.connection.datasource = java:/mssqlds$\r$\n"
StrCpy $1 '<datasource jndi-name="java:/mssqlds" pool-name="java:/mssqlds_Pool" enabled="true" use-java-context="true">\
 <connection-url>jdbc:jtds:sqlserver://$DB_Host:$DB_Port;DatabaseName=$DB_Name</connection-url>\
 <driver>mssql</driver>\
 <transaction-isolation>TRANSACTION_READ_COMMITTED</transaction-isolation>\
 <pool>\
  <min-pool-size>5</min-pool-size>\
  <max-pool-size>30</max-pool-size>\
 </pool>\
 <security>\
  <user-name>$DB_Login</user-name>\
  <password>$DB_Password</password>\
 </security>\
</datasource>\
<driver name="mssql" module="net.sourceforge.jtds">\
 <driver-class>net.sourceforge.jtds.jdbc.Driver</driver-class>\
 <xa-datasource-class>net.sourceforge.jtds.jdbcx.JtdsDataSource</xa-datasource-class>\
</driver>'
      ${Break}
    ${Case} "$(DB_ORACLE)"
      FileWrite $0 "hibernate.dialect = org.hibernate.dialect.OracleDialect$\r$\n"
      FileWrite $0 "hibernate.connection.datasource = jboss/datasources/OracleDS$\r$\n"
StrCpy $1 '<datasource jndi-name="java:jboss/datasources/OracleDS" pool-name="OracleDS">\
 <connection-url>jdbc:oracle:thin:@$DB_Host:$DB_Port:$DB_Name</connection-url>\
 <driver>oracle</driver>\
 <transaction-isolation>TRANSACTION_READ_COMMITTED</transaction-isolation>\
 <pool>\
  <min-pool-size>10</min-pool-size>\
  <max-pool-size>100</max-pool-size>\
  <prefill>true</prefill>\
 </pool>\
 <security>\
  <user-name>$DB_Login</user-name>\
  <password>$DB_Password</password>\
 </security>\
 <statement>\
  <prepared-statement-cache-size>32</prepared-statement-cache-size>\
  <share-prepared-statements>true</share-prepared-statements>\
 </statement>\
 <validation>\
  <exception-sorter class-name="org.jboss.resource.adapter.jdbc.vendor.OracleExceptionSorter"/>\
 </validation>\
 <timeout>\
  <blocking-timeout-millis>5000</blocking-timeout-millis>\
  <idle-timeout-minutes>5</idle-timeout-minutes>\
 </timeout>\
</datasource>\
<drivers>\
 <driver name="oracle" module="com.oraclejdbc">\
   <xa-datasource-class>oracle.jdbc.driver.OracleDriver</xa-datasource-class>\
 </driver>\
</drivers>'
      ${Break}
  ${EndSwitch}
    FileClose $0
    ${nsisXML->OpenXML} "$INSTDIR\WFEServer\standalone\configuration\standalone.xml"
    ${nsisXML->SetElementText} "/server/profile/subsystem/datasources" "SERVER_PROFILE_SUBSYSTEM_DATASOURCES"
    ${nsisXML->CloseXML}
    Push "SERVER_PROFILE_SUBSYSTEM_DATASOURCES"                                 #text to be replaced
    Push '$1'                                 #replace with
    Push "$INSTDIR\WFEServer\standalone\configuration\standalone.xml"   #file to replace in
    Call AdvReplaceInFile                     #call find and replace function
    
  ${endif}

  !insertmacro Runa_SetOutPath_INSIDE_CURRENTLOG "$INSTDIR\WFEServer\bin"
  ExecShell open "$INSTDIR\WFEServer\bin\service.bat" install SW_HIDE
  Sleep 3000
  SetRebootFlag true
!macroend

!macro installJbossSeq rootDir
  SetShellVarContext all
  !insertmacro Runa_SetOutPath_INSIDE_CURRENTLOG "$INSTDIR\${rootDir}"
  File /r "${BuildRoot}\wfe-server-jboss\*"
  !insertmacro Runa_SetOutPath_INSIDE_CURRENTLOG "$INSTDIR\${rootDir}\bin"
  File /r "${BuildRoot}\jboss-native\*"
  ${if} ${RunningX64} 
    ${if} "$JdkArch" == "64"
      CopyFiles /SILENT "$INSTDIR\${rootDir}\bin\64\*" "$INSTDIR\${rootDir}\bin"
    ${endif}
  ${endif}
!macroend

#======================================= uninstall macros =======================================
!macro uninstallSimSeq
  SetShellVarContext all
  RMDir /r "$INSTDIR\Simulation\server\default\tmp"
  RMDir /r "$INSTDIR\Simulation\server\default\work"
  RMDir /r "$INSTDIR\Simulation\server\default\log"
  RMDir "$INSTDIR\Simulation\server\default"
  RMDir "$INSTDIR\Simulation\server"
  RMDir "$INSTDIR\Simulation"
  ClearErrors
!macroend

!macro uninstallServerSeq
  SetShellVarContext all
  ExecShell open "$INSTDIR\WFEServer\bin\shutdown.bat -s jnp://localhost:10099" -S SW_HIDE
  Sleep 5000
  ExecShell open "$INSTDIR\WFEServer\bin\service.bat" uninstall SW_HIDE
  Sleep 20000
!macroend

#======================================= function to replace in file =======================================
Function AdvReplaceInFile

         ; call stack frame:
         ;   0 (Top Of Stack) file to replace in
         ;   1 replace with
         ;   2 to replace

         ; save work registers and retrieve function parameters
         Exch $0 ;file to replace in
         Exch 2
         Exch $4 ;to replace
         Exch
         Exch $3 ;replace with
         Exch
         Push $5 ;minus count
         Push $6 ;universal
         Push $7 ;end string
         Push $8 ;left string
         Push $9 ;right string
         Push $R0 ;file1
         Push $R1 ;file2
         Push $R2 ;read
         Push $R3 ;universal
         Push $R4 ;count (onwards)
         Push $R5 ;count (after)
         Push $R6 ;temp file name
         GetTempFileName $R6
         FileOpen $R1 $0 r ;file to search in
         FileOpen $R0 $R6 w ;temp file
                  StrLen $R3 $4
                  StrCpy $R4 -1
                  StrCpy $R5 -1
        loop_read:
         ClearErrors
         FileRead $R1 $R2 ;read line
         IfErrors exit
         StrCpy $5 0
         StrCpy $7 $R2

        loop_filter:
         IntOp $5 $5 - 1
         StrCpy $6 $7 $R3 $5 ;search
         StrCmp $6 "" file_write2
         StrCmp $6 $4 0 loop_filter

         StrCpy $8 $7 $5 ;left part
         IntOp $6 $5 + $R3
         StrCpy $9 $7 "" $6 ;right part
         StrCpy $7 $8$3$9 ;re-join

         IntOp $R4 $R4 + 1
         FileWrite $R0 $7 ;write modified line
         Goto loop_read

        file_write2:
         FileWrite $R0 $R2 ;write unmodified line
         Goto loop_read

        exit:
         FileClose $R0
         FileClose $R1

         SetDetailsPrint none
         Delete $0
         Rename $R6 $0
         Delete $R6
         AccessControl::GrantOnFile "$0" "BUILTIN\USERS" "GenericRead + GenericExecute + ReadData + Execute + ReadControl"
         SetDetailsPrint both

         Pop $R6
         Pop $R5
         Pop $R4
         Pop $R3
         Pop $R2
         Pop $R1
         Pop $R0
         Pop $9
         Pop $8
         Pop $7
         Pop $6
         Pop $5
         Pop $4
         Pop $3
         Pop $0
FunctionEnd

!endif
