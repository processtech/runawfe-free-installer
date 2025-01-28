!ifndef INSTALL_SEQUENCES_NSH
!define INSTALL_SEQUENCES_NSH

!include "languages.nsh"
!include x64.nsh
!include "JDKInstallSupport.nsh"
!include "nsisxml.nsh"

var WFEServerAddress
var WFEServerPort
var installDesktopLinks
var newSimulationDatabase
var newWorkspace
var simulationWebLinks
var allowStatisticReport
var rtnAutorunAtSystemStartup
var cleanAllOldData ; Remove all artifacts from old installation if exists

#=======================================Macros for creating shortcuts and URLs (support create desktop icons)=======================================
!macro createMenuShortcut ShortcutName ShortcutTarget ShortcutParameters ShortcutDir ShortcutIcon ShortcutDesc
  !insertmacro Runa_SetOutPath "$SMPROGRAMS\${AppName}"
  SetOutPath "$SMPROGRAMS\${AppName}"
  CreateShortCut "$SMPROGRAMS\${AppName}\${ShortcutName}" "${ShortcutTarget}" "${ShortcutParameters}" "${ShortcutIcon}" 0 "" "" "${ShortcutDesc}"
  ${ifnot} "$installDesktopLinks" == "0"
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
  ${ifnot} "$installDesktopLinks" == "0"
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
  FileWrite $0 "if not exist $\"%APPDATA%\runawfe\jboss\wfe.data-sources$\" ($\r$\n"
  FileWrite $0 "    xcopy ..\standalone\wfe.data-sources $\"%APPDATA%\runawfe\jboss\wfe.data-sources$\" /D /I /S /Y /R$\r$\n"
  FileWrite $0 ")$\r$\n"
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
  call "RemoveComponent_${sectionLangName}"
  !insertmacro SaveSectionStatus ${sectionLangName} 0
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
  File /r "${BuildRoot}\gpd\64\gpd-${AppVersion}\*"
  !insertmacro CreateRunGPDBatchFile
  !insertmacro createMenuShortcut "Developer Studio.lnk" "$INSTDIR\gpd\run.bat" "" "$INSTDIR\gpd" "$INSTDIR\Icons\e_20x20_256.ico" "$(ShortcutDesc_GPD)"
!macroend

!macro installRTNSeq
  SetShellVarContext all
  !insertmacro Runa_SetOutPath "$INSTDIR\Icons"
  File "${BuildRoot}\Icons\t_20x20_256.ico"
  !insertmacro Runa_SetOutPath "$INSTDIR\rtn"
      File /r "${BuildRoot}\rtn-${AppVersion}\64\*"


  !insertmacro createMenuShortcut "Task notifier.lnk" "$INSTDIR\rtn\run.bat" "" "$INSTDIR\rtn" "$INSTDIR\Icons\t_20x20_256.ico" "$(ShortcutDesc_RTN)"
  ${if} "$rtnAutorunAtSystemStartup" == "1"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "RunaWfeTaskNotifier" '"$INSTDIR\rtn\run.bat" -s'
  ${endif}
!macroend

!macro installWebSeq
  SetShellVarContext all
  !insertmacro Runa_SetOutPath "$INSTDIR\Icons"
  File "${BuildRoot}\Icons\C_20x20_256.ico"
  Call CreateWebLink
  !macroend

!macro setupWfeStatisticReportConfiguration _installationPropsPath _systemPropsPath
	FileOpen $0 "${_installationPropsPath}" w
    FileWrite $0 "installation.uuid=$INSTALLATION_UUID$\r$\n"
    FileWrite $0 "installation.date=$INSTALLATION_DATE$\r$\n"
    FileWrite $0 "$INSTALLATION_REFERRER_URL$\r$\n"
    ${if} "${StatisticReportUrl}" != ""
      FileWrite $0 "statistic.report.url=${StatisticReportUrl}$\r$\n"
    ${endif}
    FileWrite $0 "statistic.report.days.after.error=${StatisticReportDaysAfterError}$\r$\n"
    FileClose $0

    ${if} "$allowStatisticReport" == "1"
      FileOpen $0 "${_systemPropsPath}" w
      FileWrite $0 "statistic.report.enabled=true$\r$\n"
      FileClose $0
    ${endif}
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
  File ${BuildRoot}\Icons\Si_20x20_256.ico
  File ${BuildRoot}\Icons\Cs_20x20_256.ico
  !insertmacro createMenuShortcut "Start Simulation.lnk" "$INSTDIR\Simulation\bin\runSimulation.bat" " " "$INSTDIR\Simulation\bin" "$INSTDIR\Icons\Si_20x20_256.ico" "$(ShortcutDesc_StartSim)"
  !insertmacro createMenuShortcut "Stop Simulation.lnk" "$INSTDIR\Simulation\bin\jboss-cli.bat" "$\"--commands=connect,:shutdown$\"" "$INSTDIR\Simulation\bin" "$INSTDIR\Icons\Si_20x20_256.ico" "$(ShortcutDesc_StopSim)"

  !insertmacro Runa_SetOutPath "$INSTDIR\Simulation\standalone\wfe.custom"
  ${if} "$simulationWebLinks" == "1"
    ; Login links must be available
  ${else}
    File "${BuildRoot}\simulation.properties"
  ${endif}

  !insertmacro setupWfeStatisticReportConfiguration "$INSTDIR\Simulation\standalone\wfe.custom\wfe.custom.installation.properties" "$INSTDIR\Simulation\standalone\wfe.custom\wfe.custom.system.properties"

!macroend

!macro installServerSeq
  SetShellVarContext all
  !insertmacro Runa_SetOutPath "$INSTDIR\WFEServer"
  !insertmacro installJbossSeq WFEServer
  !insertmacro Runa_SetOutPath_INSIDE_CURRENTLOG "$INSTDIR\WFEServer\standalone"
  File /r "${BuildRoot}\wfe-server-config\standalone\deployments" # TODO
  File /r "${BuildRoot}\wildfly\app-server\standalone\wfe.data-sources"

  Push "8080"                               #text to be replaced
  Push $WFEServerPort                       #replace with
  Push "$INSTDIR\WFEServer\standalone\configuration\standalone.xml"   #file to replace in
  Call AdvReplaceInFile                     #call find and replace function
  Push "8080"                               #text to be replaced
  Push $WFEServerPort                       #replace with
  Push "$INSTDIR\Simulation\standalone\configuration\standalone.xml"   #file to replace in
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
      FileWrite $0 "hibernate.dialect = ru.runa.wfe.commons.hibernate.SqlServerUnicodeDialect$\r$\n"
      FileWrite $0 "hibernate.connection.datasource = java:/mssqlds$\r$\n"
StrCpy $1 '<datasource jndi-name="java:/mssqlds" pool-name="java:/mssqlds_Pool" enabled="true" use-java-context="true">\
 <connection-url>jdbc:sqlserver://$DB_Host:$DB_Port;DatabaseName=$DB_Name</connection-url>\
 <driver>sqlserver</driver>\
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
<driver name="sqlserver" module="com.microsoft.sqlserver">\
 <driver-class>com.microsoft.sqlserver.jdbc.SQLServerDriver</driver-class>\
 <xa-datasource-class>com.microsoft.sqlserver.jdbc.SQLServerXADataSource</xa-datasource-class>\
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
    ${Switch} "$DB_Type"
      ${Case} "$(DB_POSTGRESQL)"
        ${nsisXML->SetElementAttr} "/server/profile/subsystem/default-bindings" "datasource" "java:jboss/datasources/PostgreDS"
        ${Break}
      ${Case} "$(DB_MSSQL)"
        ${nsisXML->SetElementAttr} "/server/profile/subsystem/default-bindings" "datasource" "java:/mssqlds"
        ${Break}
      ${Case} "$(DB_ORACLE)"
        ${nsisXML->SetElementAttr} "/server/profile/subsystem/default-bindings" "datasource" "java:jboss/datasources/OracleDS"
        ${Break}
    ${EndSwitch}
    ${nsisXML->CloseXML}
    Push "SERVER_PROFILE_SUBSYSTEM_DATASOURCES"                                 #text to be replaced
    Push '$1'                                 #replace with
    Push "$INSTDIR\WFEServer\standalone\configuration\standalone.xml"   #file to replace in
    Call AdvReplaceInFile                     #call find and replace function
  ${endif}

  !insertmacro setupWfeStatisticReportConfiguration "$INSTDIR\WFEServer\standalone\wfe.custom\wfe.custom.installation.properties" "$INSTDIR\WFEServer\standalone\wfe.custom\wfe.custom.system.properties"

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
!macroend

#======================================= uninstall macros =======================================
!macro uninstallSimSeq
  SetShellVarContext all
  RMDir /r "$INSTDIR\Simulation\server\default\tmp"
  RMDir /r "$INSTDIR\Simulation\server\default\work"
  RMDir /r "$INSTDIR\Simulation\server\default\log"
  RMDir "$INSTDIR\Simulation\server\default"
  RMDir "$INSTDIR\Simulation\server"
  Delete "$INSTDIR\Simulation\bin\runSimulation.bat"
  RMDir "$INSTDIR\Simulation\bin"
  Delete "$INSTDIR\Simulation\standalone\wfe.custom\bot\docx-template.docx"
  RMDir "$INSTDIR\Simulation\standalone\wfe.custom\bot"
  RMDir "$INSTDIR\Simulation\standalone\wfe.custom"
  RMDir "$INSTDIR\Simulation\standalone"
  RMDir "$INSTDIR\Simulation"
  ClearErrors
!macroend

!macro uninstallGPDSeq
  SetShellVarContext all
  Delete "$INSTDIR\gpd\run.bat"
  RMDir "$INSTDIR\gpd"
  ClearErrors
!macroend

!macro uninstallWebSeq
  SetShellVarContext all
  RMDir "$INSTDIR\web"
  ClearErrors
!macroend

!macro uninstallRtnSeq
  SetShellVarContext all
  RMDir "$INSTDIR\rtn"
  ClearErrors
!macroend

!macro uninstallServerSeq
  SetShellVarContext all
  nsExec::ExecToLog 'taskkill /F /IM jbosssvc.exe'
  nsExec::ExecToLog 'taskkill /F /IM java.exe'
  ExecShell open "$INSTDIR\WFEServer\bin\shutdown.bat -s jnp://localhost:10099" -S SW_HIDE
  Sleep 5000
  ExecShell open "$INSTDIR\WFEServer\bin\service.bat" uninstall SW_HIDE
  Sleep 20000
  RMDir /r "$INSTDIR\WFEServer"
  ClearErrors
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

# Создание html файла открытия Web-интерфейса Runa и ссылки на него на рабочем столе.
Function CreateWebLink
    !insertmacro Runa_SetOutPath "$INSTDIR\web"
  Delete "$INSTDIR\web\runawfe.html"
  FileOpen $0 "$INSTDIR\web\runawfe.html" w
  FileWrite $0 "<!DOCTYPE HTML PUBLIC $\"-//W3C//DTD XHTML 1.0 Transitional//EN$\" $\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd$\">$\r$\n"
  FileWrite $0 "<html>$\r$\n"
  FileWrite $0 "<head>$\r$\n"
  FileWrite $0 "<meta http-equiv=$\"content-type$\" content=$\"text/html; charset=utf-8$\" />$\r$\n"
  FileWrite $0 "<title>Сервер-симулятор Runa WFE</title>$\r$\n"
  FileWrite $0 "$\r$\n"
  FileWrite $0 "<script type=$\"text/javascript$\">$\r$\n"
  FileWrite $0 "$\r$\n"
  FileWrite $0 "window.onload = (event) => {$\r$\n"
  FileWrite $0 "window.location.href = $\"http://$WFEServerAddress:$WFEServerPort/wfe/$\";$\r$\n"
  FileWrite $0 "};$\r$\n"
  FileWrite $0 "$\r$\n"
  FileWrite $0 "</script>$\r$\n"
  FileWrite $0 "</head>$\r$\n"
  FileWrite $0 "<body>$\r$\n"
  FileWrite $0 "</body>$\r$\n"
  FileWrite $0 "</html>$\r$\n"
  FileWrite $0 "$\r$\n"
   FileClose $0
     !insertmacro createURL "Web interface RunaWFE.URL" "$INSTDIR\web\runawfe.html" "$INSTDIR\Icons\C_20x20_256.ico"

FunctionEnd ; CreateWebLink
