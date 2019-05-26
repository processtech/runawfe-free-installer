!ifndef RUNA_SECTION_MACROS_NSH
!define RUNA_SECTION_MACROS_NSH

!define RUNA_UNINSTALL_LOG "$INSTDIR\uninstall"

!define ID_PREFIX "genid_"

!define RUNA_CLIENT "client"
!define RUNA_SERVER "server"

!include "LogicLib.nsh"

!include "InstalledSectionsSupport.nsh"
!include "RemoveInstalledOnlySupport.nsh"

var installationType
var reinstallCustomizable

!macro Runa_SetOutPath path
  !ifdef Runa_LoggingActive
    !insertmacro UNINSTALL.LOG_CLOSE_INSTALL
    !undef Runa_LoggingActive
  !endif
  SetOutPath "${path}"
  !insertmacro UNINSTALL.LOG_OPEN_INSTALL
  !define Runa_LoggingActive ""
  CreateDirectory "${path}"
!macroend

!macro Runa_SetOutPath_INSIDE_CURRENTLOG path
  SetOutPath "${path}"
  CreateDirectory "${path}"
!macroend

!macro generateOnSelChange
Function .onSelChange
  GetDlgItem $0 $HWNDPARENT 1
  ${if} $installationType == ${RUNA_CLIENT}
    !insertmacro isSectionSelected "${${ID_PREFIX}ComponentGPD}" clientNextWndEnable 0
    !insertmacro isSectionSelected "${${ID_PREFIX}ComponentRTN}" clientNextWndEnable 0
    !insertmacro isSectionSelected "${${ID_PREFIX}ComponentSIM}" clientNextWndEnable 0
    !insertmacro isSectionSelected "${${ID_PREFIX}ComponentWEB}" clientNextWndEnable 0
    EnableWindow $0 0
    return
clientNextWndEnable:
    EnableWindow $0 1
    return
  ${endif}
FunctionEnd
!macroend

!macro generateShowHideFunction sectionLangName sectionType isSectionDefault
  Function showHideSection_${sectionLangName}
    ${ifnot} "${sectionType}" == "$installationType"
      SectionSetText "${${ID_PREFIX}${sectionLangName}}" ""                                         ;This will hide section from components page
    ${else}
      SectionSetText "${${ID_PREFIX}${sectionLangName}}" "$(${sectionLangName}_Name)"                 ;This will show section with name in current language
    ${endif}
    ;Now check session flag if it is neccessary. (If first install and section is default and if reinstall and section already installed)
    !insertmacro isSectionRemoved "${ID_PREFIX}${sectionLangName}" 0 "isSectionChecked_${sectionLangName}"
    return
    "isSectionChecked_${sectionLangName}:"
    !insertmacro isSectionInstalled "${ID_PREFIX}${sectionLangName}" "checkSection_${sectionLangName}" 0
    ${if} "${isSectionDefault}" == "0"
      return
    ${endif}
    ${ifnot} "${sectionType}" == "$installationType"
      return
    ${endif}
    "checkSection_${sectionLangName}:"
    !insertmacro setSectionChecked "${${ID_PREFIX}${sectionLangName}}"
  FunctionEnd
!macroend

!macro generateInstallComponent sectionLangName sectionInstallMacro customizableMacro
    !insertmacro ${customizableMacro} ${sectionLangName}
    !insertmacro isSectionInstalled "${ID_PREFIX}${sectionLangName}" "checkMustCleanReinstall_${sectionLangName}" "doInstall_${sectionLangName}"
    "checkMustCleanReinstall_${sectionLangName}:"
    ${if} "$cleanAllOldData" == "1"
      goto "doInstall_${sectionLangName}"
    ${else}
      goto "installationComplette_${sectionLangName}"
    ${endif}
    "doInstall_${sectionLangName}:"
    StrCpy $UNINST_DAT "${RUNA_UNINSTALL_LOG}_${sectionLangName}.dat"
    !insertmacro UNINSTALL.LOG_PREPARE_INSTALL "${RUNA_UNINSTALL_LOG}_${sectionLangName}.dat"
    !insertmacro ${sectionInstallMacro}
    !ifdef Runa_LoggingActive
      !insertmacro UNINSTALL.LOG_CLOSE_INSTALL
      !undef Runa_LoggingActive
    !endif
    !insertmacro UNINSTALL.LOG_UPDATE_INSTALL "${RUNA_UNINSTALL_LOG}_${sectionLangName}.dat"
    !insertmacro InstallSection ${sectionLangName}
    "installationComplette_${sectionLangName}:"
!macroend

!macro generateRemoveComponentFunctionBody sectionLangName sectionPreRemoveMacro sectionPostRemoveMacro
  !insertmacro isSectionInstalled  "${ID_PREFIX}${sectionLangName}" 0 "removeComplette_${sectionLangName}"
  !insertmacro ${sectionPreRemoveMacro}
  !insertmacro UNINSTALL.LOG_UNINSTALL "${RUNA_UNINSTALL_LOG}_${sectionLangName}.dat"
  !insertmacro ${sectionPostRemoveMacro}
  Delete "${RUNA_UNINSTALL_LOG}_${sectionLangName}.dat"
  "removeComplette_${sectionLangName}:"
!macroend

!macro generateRemoveComponentFunction sectionLangName sectionPreRemoveMacro sectionPostRemoveMacro
  Function removeComponent_${sectionLangName}
    !insertmacro generateRemoveComponentFunctionBody ${sectionLangName} ${sectionPreRemoveMacro} ${sectionPostRemoveMacro}
  FunctionEnd

  Function un.removeComponent_${sectionLangName}
    !insertmacro generateRemoveComponentFunctionBody ${sectionLangName} ${sectionPreRemoveMacro} ${sectionPostRemoveMacro}
  FunctionEnd
!macroend

!macro generateSection sectionLangName sectionInstallMacro sectionPreRemoveMacro sectionPostRemoveMacro customizableMacro sectionType
  Section /o "" "${ID_PREFIX}${sectionLangName}"
    !insertmacro generateInstallComponent ${sectionLangName} ${sectionInstallMacro} ${customizableMacro}
  SectionEnd
  !insertmacro generateShowHideFunction ${sectionLangName} ${sectionType} 1
  !insertmacro generateRemoveComponentFunction ${sectionLangName} ${sectionPreRemoveMacro} ${sectionPostRemoveMacro}
!macroend
!macro generateOptionalSection sectionLangName sectionInstallMacro sectionPreRemoveMacro sectionPostRemoveMacro customizableMacro sectionType
  Section /o "" "${ID_PREFIX}${sectionLangName}"
    !insertmacro generateInstallComponent ${sectionLangName} ${sectionInstallMacro} ${customizableMacro}
  SectionEnd
  !insertmacro generateShowHideFunction ${sectionLangName} ${sectionType} 0
  !insertmacro generateRemoveComponentFunction ${sectionLangName} ${sectionPreRemoveMacro} ${sectionPostRemoveMacro}
!macroend

!macro defaultUninstallSeq
!macroend

!endif