!ifndef JDK_INSTALL_SUPPORT_NSH
!define JDK_INSTALL_SUPPORT_NSH

!include "AddToPathEnvironment.nsh"
!include x64.nsh
!include WinVer.nsh
!include SetCursor.nsh
!include "StrFunc.nsh"
  !include "LogicLib.nsh"
  !include "strExplode.nsh"

!define JAVA_VERSION "11.0.3"

Var InstallJava
Var JavaPath
Var JavaType ; "Java Runtime Environment" or "Java Development Kit"

Var JdkInstaller

ReserveFile "InstallJDKPage.ini"

Function checkJDKinit
  call CheckInstalledJava64
  StrCmp $InstallJava "yes" +2
  Abort

  !insertmacro MUI_INSTALLOPTIONS_WRITE "InstallJDKPage.ini" "Field 1" "Text" $(JDK_INSTALLREASON)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "InstallJDKPage.ini" "Field 2" "Text" "$(JDK_INSTALL_LABEL)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "InstallJDKPage.ini" "Field 3" "Text" $(JDK_EXIT_LABEL)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "InstallJDKPage.ini" "Settings" "NextButtonText" "$(JDK_INSTALL_LABEL)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "InstallJDKPage.ini" "Settings" "CancelButtonText" $(JDK_EXIT_LABEL)
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "InstallJDKPage.ini"
FunctionEnd

Function checkAndInstallJDK
  Push $0
  Push $1
  !insertmacro MUI_INSTALLOPTIONS_READ $0 "InstallJDKPage.ini" "Settings" "State"
  ${if} $0 == "3"
    GetDlgItem $0 $HWNDPARENT 1
    EnableWindow $0 0
    Abort
  ${elseif} $0 == "2"
    GetDlgItem $0 $HWNDPARENT 1
    EnableWindow $0 1
    Abort
  ${endif}
  File "/oname=$TEMP\jdk.zip" jdk.zip
  call CheckInstalledJava64
  Strcmp $InstallJava "no" JavaPathStorage
  StrCpy $JdkInstaller "$TEMP\jdk.zip"


  ; Unzip JDK
    ${SetSystemCursor} OCR_WAIT
  nsisunz::Unzip $JdkInstaller "$INSTDIR\Java"
  Pop $0								; Always check result on stack
  ${SetSystemCursor} OCR_NORMAL
; This check don't work on my VM Windows7/64. Why?
;  StrCmp $0 "success" UnzipEnd
;  Push $0
;  Goto InstallJavaError
;UnzipEnd:

  ; Check java path
  ClearErrors
  FindFirst $0 $1 "$INSTDIR\Java\*"
PathDirLoop:
  IfErrors PathDirEnd
  StrCmp $1 "." PathDirNext
  StrCmp $1 ".." PathDirNext
  Goto PathDirEnd
PathDirNext:
  FindNext $0 $1
  Goto PathDirLoop
PathDirEnd:
FindClose $0
  StrCpy $1 "$INSTDIR\Java\$1\bin"
  ; Append system Path
  Push "PATH"
  Push "P"
  Push "HKLM"
  Push "$1"
  Call EnvVarUpdate
  Pop  "$0"
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  ; Check if java.exe exists
  IfFileExists "$1\java.exe" JavaPathStorage
  Push "The following file : $1\java.exe, cannot be found."
  Goto InstallJavaError

JavaPathStorage:
  StrCpy $JavaPath $1 -4
  Goto End

InstallJavaError:
  Pop $1
  MessageBox MB_OK "The setup is about to be interrupted for the following reason : $1"
  Pop $1 	; Restore $1
  Pop $0 	; Restore $0
  Abort
End:
  Pop $1	; Restore $1
  Pop $0	; Restore $0
FunctionEnd

Function DetectJava64
  Push "${JAVA_VERSION}"
  Call DetectJava
FunctionEnd

Function CheckInstalledJava64
  call CheckInstalledJava
FunctionEnd

; If first element in stack is jdk, then searchng only jdk
Function CheckInstalledJava
  Push "${JAVA_VERSION}"
  Call DetectJava
  Exch $0	; Get return value from stack
  StrCmp $0 "0" MustInstallJava
  StrCmp $0 "-1" MustInstallJava
  Goto JavaAlreadyInstalled
MustInstallJava:
  Exch $0	; $0 now has the installoptions page return value
  Pop $0	; Restore $0
  StrCpy $InstallJava "yes"
  Return
JavaAlreadyInstalled:
  StrCpy $InstallJava "no"
  Pop $0		; Restore $0
  Return
FunctionEnd

; Returns: 0 - JRE not found. -1 - JRE found but too old. Otherwise - Path to JAVA EXE

; DetectJRE. Version requested is on the stack.
; Returns (on stack)	"0" on failure (java too old or not installed), otherwise path to java interpreter
; Stack value will be overwritten!
Function DetectJava
  Exch $0	; Get version requested
		; Now the previous value of $0 is on the stack, and the asked for version of JDK is in $0
  Push $0	; $1 = Java version string (ie 1.5.0)
  StrCpy $JavaType "Java Development Kit"
  Call DetectJavaImpl
  Exch $0	; Get return value from stack
  StrCmp $0 "0" SearchJRE 0
  StrCmp $0 "-1" SearchJRE 0
  Exch $0	; Put return value to stack
  Goto DetectJavaEnd
SearchJRE:
  StrCpy $JavaType "Java Runtime Environment"
  Call DetectJavaImpl
  Exch $0	; Get return value from stack
  StrCmp $0 "0" CheckNewJdkInstalled 0
  StrCmp $0 "-1" CheckNewJdkInstalled 0
  Exch $0	; Put return value to stack
  Goto DetectJavaEnd

CheckNewJdkInstalled:
  SearchPath $0 java.exe
  StrCmp $0 "" DetectJavaNotFound
  nsExec::Exec "$0 --list-modules"
  Pop $1
  StrCmp $1 "0" 0 DetectJavaNotFound
  StrCpy $0 $0 -13
  Exch $0	; Put return value to stack
  Goto DetectJavaEnd

DetectJavaNotFound:
  StrCpy $0 "0"	; Put "JRE not found" to stack
  Exch $0	;
  Goto DetectJavaEnd

DetectJavaEnd:
  Exch
  Pop $0
FunctionEnd

; Returns: 0 - JRE not found. -1 - JRE found but too old. Otherwise - Path to JAVA EXE

; DetectJRE. Version requested is on the stack.
; Returns (on stack)	"0" on failure (java too old or not installed), otherwise path to java interpreter
; Stack value will be overwritten!
# -----------------------------  DetectJavaImpl Begin ----------
Function DetectJavaImpl
var /GLOBAL version_requested
var /GLOBAL version_requested_major
var /GLOBAL version_requested_mid
var /GLOBAL version_requested_minor
var /GLOBAL version_found
var /GLOBAL version_found_major
var /GLOBAL version_found_mid
var /GLOBAL version_found_minor
StrCpy $version_requested_major "0"
StrCpy $version_requested_mid "0"
StrCpy $version_requested_minor "0"
StrCpy $version_found_major "0"
StrCpy $version_found_mid "0"
StrCpy $version_found_minor "0"
  Exch $version_requested	; Get version requested
		; Now the previous value of $0 is on the stack, and the asked for version of JDK is in $0
  Push $1	; $1 = Java version string (ie 1.5.0)
  Push $2	; $2 = Javahome
  Push $3	; $3 and $4 are used for checking the major/minor version of java
  Push $4

  ReadRegStr $1 HKLM "SOFTWARE\JavaSoft\$JavaType" "CurrentVersion"
  ReadRegStr $version_found HKLM "SOFTWARE\JavaSoft\$JavaType" "CurrentVersion"
  StrCmp $version_found "" NoFound
  ReadRegStr $2 HKLM "SOFTWARE\JavaSoft\$JavaType\$1" "JavaHome"
  StrCmp $2 "" NoFound

     
;--------------- Parsing Requested JAVA Version Begin --------------------------------
Push 3
Push "."
     Push $version_requested
Call strExplode
Pop $0
IntCmp $0 1 Required_get1Digit Required_ParseError Required_chk2Digits
Required_get1Digit:
Pop $version_requested_major
Goto End_Parse_Requested
Required_chk2Digits:
IntCmp $0 2 Required_get2Digits Required_ParseError Required_chk3Digits
Required_get2Digits:
Pop $version_requested_major
Pop $version_requested_minor
Goto End_Parse_Requested


Required_chk3Digits:
IntCmp $0 3 Required_get3Digits Required_ParseError Required_ParseError





Required_ParseError:
MessageBox MB_OK "DetectJavaImpl strExplode Bad Requested JAVA Version format: $version_requested"
Abort


Required_get3Digits:
Pop $version_requested_major
Pop $version_requested_mid
Pop $version_requested_minor
;--------------- Parsing Requested JAVA Version End --------------------------------
End_Parse_Requested:
;Goto FoundNew

;--------------- Parsing Current JAVA Version Begin --------------------------------
Push 3
Push "."
     Push $version_found
Call strExplode
Pop $0
IntCmp $0 1 Current_get1Digit Current_ParseError Current_chk2Digits
Current_get1Digit:
Pop $version_found_major
Goto End_Parse_Current
Current_chk2Digits:
IntCmp $0 2 Current_get2Digits Current_ParseError Current_chk3Digits
Current_get2Digits:
Pop $version_found_major
Pop $version_found_minor
Goto End_Parse_Current


Current_chk3Digits:
IntCmp $0 3 Current_get3Digits Current_ParseError Current_ParseError





Current_ParseError:
MessageBox MB_OK "DetectJavaImpl strExplode Bad Current JAVA Version format: $version_found"
Abort


Current_get3Digits:
Pop $version_found_major
Pop $version_found_mid
Pop $version_found_minor
;--------------- Parsing Current JAVA Version End --------------------------------
End_Parse_Current:
;IntCmp $0 5 is5 lessthan5 morethan5
;IntCmp $version_requested_major $version_found_major MajorEqualCheckMiddle FoundOld FoundNew
IntCmp $version_found_major $version_requested_major MajorEqualCheckMiddle FoundOld FoundNew


MajorEqualCheckMiddle:
IntCmp $version_found_mid $version_requested_mid MidEqualCheckMinor FoundOld FoundNew

MidEqualCheckMinor:
IntCmp $version_found_minor $version_requested_minor FoundNew FoundOld FoundNew
;Goto FoundNew
     




NoFound:
  Push "0"
  Goto DetectJavaImplEnd

FoundOld:
  Push "0"
  Goto DetectJavaImplEnd
FoundNew:

  Push "$2"
DetectJavaImplEnd:
FunctionEnd		; DetectJavaImpl
# -----------------------------  DetectJavaImpl End ----------

Function setJavaHomeInit
  push $0
  push $1

  StrCmp $JavaPath "" 0 JavaHomeReadReg
  Call DetectJava64
  Pop $JavaPath	  ; DetectJRE's return value

JavaHomeReadReg:
  ReadRegStr $0 "${WriteEnvStr_RegRoot}" "${WriteEnvStr_RegKey}" "JAVA_HOME"
  StrCmp "$0" "$JavaPath" setJavaHomeInit_Exit

  !insertmacro MUI_INSTALLOPTIONS_WRITE "SetJavaHomePage.ini" "Field 1" "Text" $(TEXT_JAVAHOME_REASON)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "SetJavaHomePage.ini" "Field 2" "Text" "JAVA_HOME=$JavaPath"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "SetJavaHomePage.ini"
setJavaHomeInit_Exit:
  pop $1
  pop $0
FunctionEnd

Function setJavaHomeLeave
  push $0
  ReadINIStr $0 "$PLUGINSDIR\SetJavaHomePage.ini" "Field 2" "State"
  StrCmp $0 1 0 JAVA_HOME_End
  WriteRegStr "${WriteEnvStr_RegRoot}" "${WriteEnvStr_RegKey}" "JAVA_HOME" $JavaPath
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
JAVA_HOME_End:
  pop $0
FunctionEnd

!endif
