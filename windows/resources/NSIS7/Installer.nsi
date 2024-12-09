!define AppName "RunaWFE"
!define AppVersion "%VERSION%"
!define ShortName "RunaWFE"
!define Vendor "Runa"
!define Edition "%EDITION%"
!define BuildHash "%BUILD_HASH%"

!define BuildRoot "%BUILD_ROOT%"
!define StatisticReportUrl "%STATISTIC_REPORT_URL%"
!define StatisticReportDaysAfterError "%STATISTIC_REPORT_DAYS_AFTER_ERROR%"
!define MUI_ICON "${BuildRoot}\icons\wf_48x128.ico"
!define MUI_UNICON "${BuildRoot}\icons\wf_48x128.ico"
!define MUI_ABORTWARNING
!define MUI_UNINSTALLER

Var INSTALLATION_UUID
Var INSTALLATION_DATE
Var INSTALLATION_REFERRER_URL

;Following two definitions required. Uninstall log will use these definitions.
;You may use these definitions also, when you want to set up the InstallDirRagKey,
;store the language selection, store Start Menu folder etc.
;Enter the windows uninstall reg sub key to add uninstall information to Add/Remove Programs also.
!define ALL_USERS
!ifndef WriteEnvStr_RegKey
  !ifdef ALL_USERS
    !define WriteEnvStr_RegKey "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    !define WriteEnvStr_RegRoot HKLM
  !else
    !define WriteEnvStr_RegKey "Environment"
    !define WriteEnvStr_RegRoot HKCU
  !endif
!endif
!define INSTDIR_REG_ROOT "HKLM"
!define INSTDIR_REG_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${ShortName}"

!include "FileFunc.nsh"
!include "MUI.nsh"
!include "Sections.nsh"
!include "LogicLib.nsh"

!include "languages.nsh"
!include "RunaSectionMacros.nsh"
!include "installSequences.nsh"
!include "databaseSettings.nsh"
!include x64.nsh

Name "${AppName}"
OutFile "setup.exe"
InstallDir "$PROGRAMFILES64\${SHORTNAME}"
InstallDirRegKey HKLM "SOFTWARE\${Vendor}\${ShortName}" ""

ReserveFile "InstallationType.ini"
ReserveFile "ServerAddressPage.ini"
ReserveFile "ServerDesktopLinks.ini"
ReserveFile "SetJavaHomePage.ini"
ReserveFile "InstallJDKPage.ini"
ReserveFile "DesktopLinks.ini"
ReserveFile "WelcomePage.ini"
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

CRCCheck off
BrandingText "RunaWFE %VERSION%"
AddBrandingImage left -10

LicenseData "license.rtf"
Page custom welcomePageInit welcomePageLeave
page license                                                   ;Show license and set runawfe branding images at installer headers
Page custom checkRunaVersion checkRunaVersionLeave             ;Check for RunaWFE version and notify on old RunaWFE installed
Page custom selectInstallationType selectInstallationTypeLeave ;Let user choose installation type - server or client applications
Page components selectComponents selectComponentsLeave         ;Let user choose components to install
Page directory                                                 ;Let user choose directory to install
Page custom installDesktopLinks installDesktopLinksLeave
Page custom installServerDesktopLinks installServerDesktopLinksLeave
Page custom databaseSettings databaseSettingsLeave
Page custom getHostAndPort getHostAndPortLeave                 ;Main wfe server port and host if selected rtn, web (and installing client components)
Page custom checkJDKinit_My checkAndInstallJDK                 ;Check for java and install java
Page custom setJavaHomeInit_My setJavaHomeleave                ;Check for java_home and install java_home to jdk if necessary
Page instfiles cleanAllDataFunc "" rebootIfNeeded              ;Install files

UninstPage uninstconfirm un.installBrandingImage
UninstPage instFiles

!macro AllSectionFunctionCall PREFIX SUFFIX
  call ${PREFIX}ComponentRTN${SUFFIX}
  call ${PREFIX}ComponentWEB${SUFFIX}
  call ${PREFIX}ComponentGPD${SUFFIX}
  call ${PREFIX}ComponentSIM${SUFFIX}
  call ${PREFIX}ComponentSRV${SUFFIX}
!macroend
!macro AllSectionMacroCall MacroName
  !insertmacro "${MacroName}" "ComponentRTN"
  !insertmacro "${MacroName}" "ComponentWEB"
  !insertmacro "${MacroName}" "ComponentGPD"
  !insertmacro "${MacroName}" "ComponentSIM"
  !insertmacro "${MacroName}" "ComponentSRV"
!macroend
!macro _CreateGUID _RetVar
    Call CreateGUID
    !if ${_RetVar} != s
        Pop ${_RetVar}
    !endif
!macroend
!macro _GetReferrerUrl _RetVar
    Call GetReferrerUrl
    !if ${_RetVar} != s
        Pop ${_RetVar}
    !endif
!macroend
!macro _GetCurrentDate _RetVar
    Call GetCurrentDate
    !if ${_RetVar} != s
        Pop ${_RetVar}
    !endif
!macroend

Section -FinishComponents
  call removeUnselected
  System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'
SectionEnd

!insertmacro generateSection ComponentGPD installGPDSeq defaultUninstallSeq uninstallGPDSeq GpdCustomizableMacro ${RUNA_CLIENT}
!insertmacro generateSection ComponentSIM installSimSeq defaultUninstallSeq uninstallSimSeq SimCustomizableMacro ${RUNA_CLIENT}
!insertmacro generateOptionalSection ComponentRTN installRTNSeq defaultUninstallSeq uninstallRtnSeq RtnWebBotCustomizableMacro ${RUNA_CLIENT}
!insertmacro generateOptionalSection ComponentWEB installWebSeq defaultUninstallSeq uninstallWebSeq RtnWebBotCustomizableMacro ${RUNA_CLIENT}

!insertmacro generateSection ComponentSRV installServerSeq defaultUninstallSeq uninstallServerSeq RtnWebBotCustomizableMacro ${RUNA_SERVER}

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT "${${ID_PREFIX}ComponentGPD}" $(ComponentGPD_Desc)
  !insertmacro MUI_DESCRIPTION_TEXT "${${ID_PREFIX}ComponentRTN}" $(ComponentRTN_Desc)
  !insertmacro MUI_DESCRIPTION_TEXT "${${ID_PREFIX}ComponentWEB}" $(ComponentWEB_Desc)
  !insertmacro MUI_DESCRIPTION_TEXT "${${ID_PREFIX}ComponentSIM}" $(ComponentSIM_Desc)
  !insertmacro MUI_DESCRIPTION_TEXT "${${ID_PREFIX}ComponentSRV}" $(ComponentSRV_Desc)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section "-Installation of ${AppName}" SecAppFiles
  SetShellVarContext all
  CreateDirectory "$INSTDIR"
  DeleteRegValue HKLM "${INSTDIR_REG_KEY}" "Version"
  DeleteRegValue HKLM "${INSTDIR_REG_KEY}" "Edition"
  DeleteRegValue HKLM "${INSTDIR_REG_KEY}" "BuildHash"
  ClearErrors
  WriteRegStr HKLM "SOFTWARE\${Vendor}\${ShortName}" "" $INSTDIR

  WriteRegStr HKLM "${INSTDIR_REG_KEY}" "DisplayName" "${AppName}"
  WriteRegStr HKLM "${INSTDIR_REG_KEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "${INSTDIR_REG_KEY}" "NoModify" "1"
  WriteRegDWORD HKLM "${INSTDIR_REG_KEY}" "NoRepair" "1"

  WriteUninstaller "$INSTDIR\Uninstall.exe"

  CreateDirectory "$SMPROGRAMS\${AppName}"
  CreateShortCut "$SMPROGRAMS\${AppName}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0

  FileOpen $0 "$INSTDIR\version" w
  FileWrite $0 "%VERSION%"
  FileClose $0

  WriteRegStr HKLM ${INSTDIR_REG_KEY} "DisplayName" "RunaWFE %VERSION%"
  WriteRegStr HKLM ${INSTDIR_REG_KEY} "Version" "%VERSION%"
  WriteRegStr HKLM ${INSTDIR_REG_KEY} "Edition" "%EDITION%"
  WriteRegStr HKLM ${INSTDIR_REG_KEY} "BuildHash" "%BUILD_HASH%"
  WriteRegStr HKLM ${INSTDIR_REG_KEY} "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM ${INSTDIR_REG_KEY} "UninstallString" "$\"$INSTDIR\uninstall.exe$\""

SectionEnd

Section "Uninstall"
  SetShellVarContext all
  ;First removes all optional components
  ;!insertmacro SectionList "RemoveSection"
  !insertmacro AllSectionFunctionCall "un.removeComponent_" ""

  ; remove registry keys
  DeleteRegKey HKLM "${INSTDIR_REG_KEY}"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "RunaWfeTaskNotifier"
  DeleteRegKey HKLM  "SOFTWARE\${Vendor}\${AppName}"
  ; remove shortcuts, if any.
  RMDir /r "$SMPROGRAMS\${AppName}"
  ; remove files
  Delete "$INSTDIR\uninstall.exe"
  IfFileExists "$INSTDIR\Java\*" 0 +2
    RMDir /r "$INSTDIR\Java"
  ReadEnvStr $0 "JAVA_HOME"
  ${un.StrStr} $1 $0 "$INSTDIR\Java"
  ${If} $1 == ""
    ;Java is not in RunaWfe folder
  ${Else}
    ReadRegStr $2 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "JAVA_HOME"
    DeleteRegValue HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "JAVA_HOME"
    DeleteRegValue HKCU "Environment" "JAVA_HOME"
    ReadRegStr $1 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path"
    ${un.StrRep} $0 $1 "$2\bin;" ""
    WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path" $0
    SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0 "STR:Environment"
    System::Call 'Kernel32::SendMessageTimeout(i 0xFFFF, i ${WM_SETTINGCHANGE}, i 0, t "Environment", i 0x0, i 1000, *i .r0)'
  ${EndIf}
  RMDir "$INSTDIR\Icons"
  Delete "$INSTDIR\version"
  RMDir "$INSTDIR"
  DeleteRegKey HKLM ${INSTDIR_REG_KEY}
SectionEnd

Function removeUnselected
  ;Removes unselected components and writes component status to registry
  !insertmacro AllSectionMacroCall "RemoveUncheckedComponents"
FunctionEnd

  MiscButtonText "" "" "" $(CloseBtn)

Function .onInit
  SetShellVarContext all

  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "RunaWfeTaskNotifier"

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "InstallationType.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ServerAddressPage.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ServerDesktopLinks.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "InstallJDKPage.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "SetJavaHomePage.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "DesktopLinks.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "WelcomePage.ini"
  !insertmacro _CreateGUID $INSTALLATION_UUID
  !insertmacro _GetCurrentDate $INSTALLATION_DATE
  !insertmacro _GetReferrerUrl $INSTALLATION_REFERRER_URL
FunctionEnd

!insertmacro generateOnSelChange

!macro generateInstallBrandingImage UNINSTALLER
Function ${UNINSTALLER}installBrandingImage
  File "/oname=$TEMP\runawfe_logo.bmp" "${BuildRoot}\icons\big_logo.bmp"
  SetFileAttributes runawfe_logo.bmp temporary
  SetBrandingImage  "$TEMP\runawfe_logo.bmp"
FunctionEnd
!macroend
!insertmacro generateInstallBrandingImage ""
!insertmacro generateInstallBrandingImage un.

Function databaseSettings
  ${if} $installationType == ${RUNA_CLIENT}
    Abort
  ${endif}
  !insertmacro isSectionSelected ${${ID_PREFIX}ComponentSRV} toShowDatabaseSettings 0
  Abort
  toShowDatabaseSettings:
  call showDatabaseSettings
FunctionEnd

Function welcomePageInit
  call installBrandingImage
  File "/oname=$TEMP\logo_runa_ru.bmp" "${BuildRoot}\icons\logo_runa_ru.bmp"
  File "/oname=$TEMP\logo_runa_en.bmp" "${BuildRoot}\icons\logo_runa_en.bmp"
  SetFileAttributes runawfe_splash.bmp temporary
  !insertmacro MUI_INSTALLOPTIONS_WRITE "WelcomePage.ini" "Field 1" "Text" $(TEXT_PROJECT_SITE)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "WelcomePage.ini" "Field 1" "State" $(LINK_PROJECT_SITE)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "WelcomePage.ini" "Settings" "NextButtonText" "$(TEXT_BEGIN_INSTALLATION)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "WelcomePage.ini" "Field 2" "Text" $(TEXT_ANNOTATION_INSTALLATION)
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "WelcomePage.ini"
FunctionEnd

Function welcomePageLeave
FunctionEnd

Function checkRunaVersion
  ClearErrors
  ReadRegStr $R0 HKLM "SOFTWARE\${Vendor}\${ShortName}" ""
  IfErrors "checkRunaVersionEnd"
  ClearErrors
  StrCpy $R1 $R0

  ReadRegStr $R0 HKLM "${INSTDIR_REG_KEY}" "BuildHash"
  IfErrors "buildHashesCompared"
  StrCmp $R0 "${BuildHash}" 0 buildHashesCompared
  MessageBox MB_YESNO "$(RunaWFE_VersionInstalled) $(RunaWFE_Path) $R1 $(RunaWFE_Continue)" IDYES buildHashesCompared IDNO 0
  Quit
  buildHashesCompared:
  ClearErrors

  ReadRegStr $R0 HKLM "${INSTDIR_REG_KEY}" "Edition"
  IfErrors +1 +2
  StrCpy $R0 "Free"
  ClearErrors

  ${If} "%EDITION%" == "Free"
    ${If} $R0 == "Industrial"
      ${OrIf} $R0 == "Professional"
      MessageBox MB_OK "$(RunaWFE_CurrentlyInstalledEdition) $R0 $(RunaWFE_EditionIncompatible)"
      Quit
    ${Endif}
  ${Else}
    ${If} $R0 == "Free"
      MessageBox MB_OK "$(RunaWFE_EditionInstalling) %EDITION% $(RunaWFE_FreeIsIncompatible)"
    ${Endif}
  ${Endif}

  ReadRegStr $R0 HKLM "${INSTDIR_REG_KEY}" "Version"
  IfErrors +1
  StrCmp $R0 "${AppVersion}" checkRunaVersionEnd 0
  ClearErrors
  MessageBox MB_YESNO "$(RunaWFE_VersionDiffer)"  IDYES checkRunaVersionEnd IDNO 0
  Quit
  checkRunaVersionEnd:
  ClearErrors
FunctionEnd

Function checkRunaVersionLeave
FunctionEnd

Function selectInstallationType
  !insertmacro MUI_INSTALLOPTIONS_WRITE "InstallationType.ini" "Field 1" "Text" $(ClientDistr_Desc)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "InstallationType.ini" "Field 2" "Text" $(ServerDistr_Desc)
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "InstallationType.ini"
FunctionEnd

Function selectInstallationTypeLeave
  push $R0
  !insertmacro MUI_INSTALLOPTIONS_READ $R0 "InstallationType.ini" "Field 1" "State"
  ${if} $R0 = 0
    StrCpy $installationType ${RUNA_SERVER}
  ${else}
    StrCpy $installationType ${RUNA_CLIENT}
  ${endif}
  !insertmacro AllSectionFunctionCall "showHideSection_" ""
  pop $R0
FunctionEnd

Function selectComponents
  ${if} $installationType == ${RUNA_SERVER}
    !insertmacro setSectionChecked "${${ID_PREFIX}ComponentSRV}"
    Abort
  ${endif}
FunctionEnd

Function selectComponentsLeave
FunctionEnd

Function checkJDKinit_My
  ${IfNot} ${RunningX64}
  MessageBox MB_OK "������������� ������ 64-������ ����������� ��. ���������� ��������� ����������."
  Quit
  ${endif}
  !insertmacro isSectionSelected "${${ID_PREFIX}ComponentSIM}" installJava 0
  !insertmacro isSectionSelected "${${ID_PREFIX}ComponentSRV}" installJava 0
  !insertmacro isSectionSelected "${${ID_PREFIX}ComponentRTN}" installJava 0
  !insertmacro isSectionSelected "${${ID_PREFIX}ComponentGPD}" installJava 0
  Abort
  installJava:
  call checkJDKinit
FunctionEnd

Function setJavaHomeInit_My
  !insertmacro isSectionSelected "${${ID_PREFIX}ComponentSIM}" installJAVAPATH 0
  !insertmacro isSectionSelected "${${ID_PREFIX}ComponentSRV}" installJAVAPATH 0
  !insertmacro isSectionSelected "${${ID_PREFIX}ComponentRTN}" installJAVAPATH 0
  !insertmacro isSectionSelected "${${ID_PREFIX}ComponentGPD}" installJAVAPATH 0
  Abort
  installJAVAPATH:
  call setJavaHomeInit
FunctionEnd

Function getHostAndPort
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerAddressPage.ini" "Field 2" "Text" $(TEXT_SERVERINFO_HOST)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerAddressPage.ini" "Field 4" "Text" $(TEXT_SERVERINFO_PORT)
  ${if} $installationType == ${RUNA_CLIENT}
    Push $R0
    !insertmacro isSectionSelected ${${ID_PREFIX}ComponentWEB} show 0
    !insertmacro isSectionSelected ${${ID_PREFIX}ComponentRTN} show 0
    pop $R0
    Abort
    show:
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerAddressPage.ini" "Field 1" "Text" $(TEXT_SERVERINFO)
    ReadRegStr $R0 HKLM "${INSTDIR_REG_KEY}" "RemoteAddress"
    ${if} $R0 != ""
      !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerAddressPage.ini" "Field 3" "State" $R0
    ${endif}
    ReadRegStr $R0 HKLM "${INSTDIR_REG_KEY}" "RemotePort"
    StrCmp $R0 "" 0 +2
    StrCpy $R0 "8080"
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerAddressPage.ini" "Field 5" "State" $R0
    !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "ServerAddressPage.ini"
    pop $R0
  ${else}
    Push $R0
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerAddressPage.ini" "Field 1" "Text" $(TEXT_SERVERINFO_SERVER)
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerAddressPage.ini" "Field 3" "State" "localhost"
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerAddressPage.ini" "Field 3" "Flags" "DISABLED"
    !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "ServerAddressPage.ini"
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerAddressPage.ini" "Field 3" "State" ""
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerAddressPage.ini" "Field 5" "Flags" ""
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerAddressPage.ini" "Field 3" "Flags" ""
    pop $R0
  ${endif}
FunctionEnd

Function getHostAndPortLeave
  !insertmacro INSTALLOPTIONS_READ $WFEServerAddress "ServerAddressPage.ini" "Field 3" "State"
  !insertmacro INSTALLOPTIONS_READ $WFEServerPort "ServerAddressPage.ini" "Field 5" "State"
  ${if} "$WFEServerAddress" == ""
    MessageBox MB_OK $(TEXT_SERVERINFO_HOSTEMPTY)
    Abort
  ${endif}
  WriteRegStr HKLM "${INSTDIR_REG_KEY}" "RemoteAddress" "$WFEServerAddress"
  WriteRegStr HKLM "${INSTDIR_REG_KEY}" "RemotePort" "$WFEServerPort"
FunctionEnd

Function installDesktopLinks
  ${if} $installationType == ${RUNA_SERVER}
    StrCpy $installDesktopLinks "0"
    Abort
  ${endif}
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 1" "Text" $(DesktopLinks)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 2" "Text" $(installNewDatabase)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 3" "Text" $(installNewWorkspace)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 4" "Text" $(installSimulationLoginLinks)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 5" "Text" $(installCleanAllOldData)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 6" "Text" $(installAllowStatisticReport)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 7" "Text" $(installRtnAutorunAtSystemStartup)
  !insertmacro isSectionSelected "${${ID_PREFIX}ComponentSIM}" +4 0
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 4" "Flags" "DISABLED"
  goto +3
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 2" "Flags" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 4" "Flags" ""
  !insertmacro isSectionSelected "${${ID_PREFIX}ComponentGPD}" +3 0
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 3" "Flags" "DISABLED"
  goto +2
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 3" "Flags" ""
  !insertmacro isSectionSelected "${${ID_PREFIX}ComponentRTN}" +3 0
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 7" "Flags" "DISABLED"
  goto +2
  !insertmacro MUI_INSTALLOPTIONS_WRITE "DesktopLinks.ini" "Field 7" "Flags" ""
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "DesktopLinks.ini"
FunctionEnd
Function installDesktopLinksLeave
  !insertmacro MUI_INSTALLOPTIONS_READ $installDesktopLinks "DesktopLinks.ini" "Field 1" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $newSimulationDatabase "DesktopLinks.ini" "Field 2" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $newWorkspace "DesktopLinks.ini" "Field 3" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $simulationWebLinks "DesktopLinks.ini" "Field 4" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $cleanAllOldData "DesktopLinks.ini" "Field 5" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $allowStatisticReport "DesktopLinks.ini" "Field 6" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $rtnAutorunAtSystemStartup "DesktopLinks.ini" "Field 7" "State"
FunctionEnd

Function installServerDesktopLinks
  ${if} $installationType == ${RUNA_CLIENT}
    Abort
  ${endif}
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ServerDesktopLinks.ini" "Field 1" "Text" $(installAllowStatisticReport)
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "ServerDesktopLinks.ini"
FunctionEnd

Function installServerDesktopLinksLeave
  !insertmacro MUI_INSTALLOPTIONS_READ $allowStatisticReport "ServerDesktopLinks.ini" "Field 1" "State"
FunctionEnd

Function cleanAllDataFunc
  ${if} "$cleanAllOldData" == "1"
   StrCpy $0 "$INSTDIR"
         StrCpy $1 "Java"
         FindFirst $R0 $R1 "$0\*"

         loop:
           StrCmp $R1 "." skip
           StrCmp $R1 ".." skip
           StrCmp $R1 $1 skip

           IfFileExists "$0\$R1\*.*" IsFolder
           Delete "$0\$R1"
           Goto skip

           IsFolder:
           RMDir /r "$0\$R1"

           skip:
           FindNext $R0 $R1
           IfErrors done
           Goto loop

         done:
         FindClose $R0
  ${endif}
FunctionEnd

Function rebootIfNeeded
  ${if} $installationType == ${RUNA_SERVER}
    IfRebootFlag 0 noreboot
    MessageBox MB_YESNO "$(rebootIsRequired)" IDNO noreboot
    Reboot
    noreboot:
  ${endif}
FunctionEnd

;https://xkln.net/blog/identifying-the-source-of-downloaded-files/
Function GetReferrerUrl
  nsExec::ExecToStack "powershell (Get-Content '$EXEDIR\$EXEFILE' -Stream Zone.Identifier -ErrorAction SilentlyContinue)[2]"
  Pop $0
  Pop $1
  ${If} $0 != "0"
    StrCpy $1 "ReferrerUrl="
  ${EndIf}
  Push $1
FunctionEnd


Function GetCurrentDate
   pop $R0
   !insertmacro GetTime
   ${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
   StrCpy $R0 "$2-$1-$0 $4:$5"
   push $R0
FunctionEnd

Function CreateGUID
  ; GUID has 128 bit = 16 byte = 32 hex characters
  Push $R0
  Push $R1
  Push $R2
  Push $R3
  Push $R4
  ;allocate space for character array
  System::Alloc 16
  ;get pointer to new space
  Pop $R1
  StrCpy $R0 "" ; init
  ;call the CoCreateGuid api in the ole32.dll
  System::Call 'ole32::CoCreateGuid(i R1) i .R2'
  ;if 0 then continue
  IntCmp $R2 0 continue
  ; set error flag
  SetErrors
  goto done
continue:
  ;byte counter = 0
  StrCpy $R3 0
loop:
    System::Call "*$R1(&v$R3, &i1 .R2)"
    ;now $R2 is byte at offset $R3
    ;convert to hex
    IntFmt $R4 "%X" $R2
    StrCpy $R4 "00$R4"
    StrLen $R2 $R4
    IntOp $R2 $R2 - 2
    StrCpy $R4 $R4 2 $R2
    ;append to result
    StrCpy $R0 "$R0$R4"
    ;increment byte counter
    IntOp $R3 $R3 + 1
    ;if less than 16 then continue
    IntCmp $R3 16 0 loop
done:
  ;cleanup
   System::Free $R1
  ; BEGIN format GUID
  StrCpy $R1 "$R0"
  StrCpy $R0 ""
  StrCpy $R2 $R1 8
  StrCpy $R0 "$R0$R2-"
  StrCpy $R2 $R1 4 8
  StrCpy $R0 "$R0$R2-"
  StrCpy $R2 $R1 4 12
  StrCpy $R0 "$R0$R2-"
  StrCpy $R2 $R1 4 16
  StrCpy $R0 "$R0$R2-"
  StrCpy $R2 $R1 12 20
  StrCpy $R0 "$R0$R2"
  ; END format GUID
  Pop $R4
  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd