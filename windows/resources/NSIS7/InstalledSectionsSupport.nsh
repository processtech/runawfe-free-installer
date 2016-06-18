!ifndef INSTALLED_SECTIONS_SUPPORT_NSH
!define INSTALLED_SECTIONS_SUPPORT_NSH

!macro isSectionSelected sectionId selectedGoTo notSelectedGoTo
  SectionGetFlags ${sectionId} $R0
  IntOp $R0 $R0 & ${SF_SELECTED}
  IntCmp $R0 ${SF_SELECTED} ${selectedGoTo} ${notSelectedGoTo}
!macroend
!macro setSectionChecked sectionId
  SectionGetFlags ${sectionId} $R0
  IntOp $R0 $R0 | ${SF_SELECTED}
  SectionSetFlags ${sectionId} $R0
!macroend
!macro setSectionUnChecked sectionId
  SectionGetFlags ${sectionId} $R0
  IntOp $R0 $R0 & !${SF_SELECTED}
  SectionSetFlags ${sectionId} $R0
!macroend
!macro isSectionInstalled SecIdName installedGoto notInstalledGoto
  ClearErrors
  ReadRegDWORD $R0 HKLM "${INSTDIR_REG_KEY}\Components\${SecIdName}" "Installed"
  IfErrors "${notInstalledGoto}"
  StrCmp $R0 1 "${installedGoto}" "${notInstalledGoto}"
!macroend
!macro isSectionRemoved SecIdName removedGoto notRemovedGoto
  ClearErrors
  ReadRegDWORD $R0 HKLM "${INSTDIR_REG_KEY}\Components\${SecIdName}" "Installed"
  IfErrors "${notRemovedGoto}"
  StrCmp $R0 0 "${removedGoto}" "${notRemovedGoto}"
!macroend

!macro SaveSectionStatus SecIdName Value
  WriteRegDWORD HKLM "${INSTDIR_REG_KEY}\Components\${ID_PREFIX}${SecIdName}" "Installed" ${Value}
  ClearErrors
!macroend

!macro RemoveUncheckedComponents SecIdName
  ;  This macro reads section flag set by user and removes the section
  ;if it is not selected.
  ;Then it writes component installed flag to registry
  ;Input: section index constant name specified in Section command.
  !insertmacro isSectionSelected ${${ID_PREFIX}${SecIdName}} 0 "rmDoJob_${SecIdName}"
  ; check for RunaWFE version
  ClearErrors
  ReadRegStr $R0 HKLM "${INSTDIR_REG_KEY}" "Version"
  IfErrors "rmDoJob_${SecIdName}"
  StrCmp $R0 "${AppVersion}" "rmExit_${SecIdName}" 0
  "rmDoJob_${SecIdName}:"
  call "RemoveComponent_${SecIdName}"
  !insertmacro SaveSectionStatus ${SecIdName} 0
  "rmExit_${SecIdName}:"
  ClearErrors
!macroend

!macro InstallSection SecIdName
  ;  This macro reads section flag set by user and removes the section
  ;if it is not selected.
  ;Then it writes component installed flag to registry
  ;Input: section index constant name specified in Section command.
  !insertmacro isSectionSelected ${${ID_PREFIX}${SecIdName}} 0 "exit_${SecIdName}"
  !insertmacro SaveSectionStatus ${SecIdName} 1
  "exit_${SecIdName}:"
  ClearErrors
!macroend

!macro RemoveSection SecIdName
  call "un.RemoveComponent_${SecIdName}"
!macroend
!endif