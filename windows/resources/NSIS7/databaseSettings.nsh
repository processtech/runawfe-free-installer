!ifndef DATABASE_SETTINGS_NSH
!define DATABASE_SETTINGS_NSH

!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "languages.nsh"

Var DB_Type
Var DB_Host
Var DB_Port
Var DB_Login
Var DB_Password
Var DB_Name

Var DB_DropList

Var DB_Host_Control
Var DB_Host_Label
Var DB_Port_Control
Var DB_Port_Label
Var DB_Login_Control
Var DB_Login_Label
Var DB_Password_Control
Var DB_Password_Label
Var DB_Name_Control
Var DB_Name_Label

Function DB_OnChange
        Pop $1
        ${NSD_GetText} $1 $0
        ${If} $0 == "$(DB_H2_DEFAULT)"
              Push ${SW_HIDE}
        ${Else}
              Push ${SW_SHOW}
        ${Endif}
        Pop $2
        ShowWindow $DB_Host_Control $2
        ShowWindow $DB_Host_Label $2
        ShowWindow $DB_Port_Control $2
        ShowWindow $DB_Port_Label $2
        ShowWindow $DB_Login_Control $2
        ShowWindow $DB_Login_Label $2
        ShowWindow $DB_Password_Control $2
        ShowWindow $DB_Password_Label $2
        ShowWindow $DB_Name_Control $2
        ShowWindow $DB_Name_Label $2

        ${Switch} $0
        ${Case} "$(DB_H2_DEFAULT)"
                ${Break}
        ${Case} "$(DB_POSTGRESQL)"
                ${NSD_SetText} $DB_Port_Control "5432"
                ${Break}
        ${Case} "$(DB_MSSQL)"
                ${NSD_SetText} $DB_Port_Control "1433"
                ${Break}
        ${Case} "$(DB_ORACLE)"
                ${NSD_SetText} $DB_Port_Control "1521"
                ${Break}
        ${EndSwitch}
FunctionEnd

Function showDatabaseSettings
	nsDialogs::Create 1018
	Pop $1

        ${NSD_CreateLabel} 10% 0 80% 12u "$(DB_DIALOG_LABEL)"
	Pop $1

	${NSD_CreateLabel} 5% 20u 30% 12u "$(DB_TYPE_LABEL)"
	Pop $1
	${NSD_CreateDropList} 35% 20u 60% 25u ""
	Pop $DB_DropList
	${NSD_CB_AddString} $DB_DropList "$(DB_H2_DEFAULT)"
	${NSD_CB_AddString} $DB_DropList "$(DB_POSTGRESQL)"
	${NSD_CB_AddString} $DB_DropList "$(DB_MSSQL)"
	${NSD_CB_AddString} $DB_DropList "$(DB_ORACLE)"
	${NSD_CB_SelectString} $DB_DropList "$(DB_H2_DEFAULT)"
	${NSD_OnChange} $DB_DropList DB_OnChange

        ${NSD_CreateLabel} 5% 40u 30% 12u "$(DB_HOST_LABEL)"
	Pop $DB_Host_Label
	${NSD_CreateText} 35% 40u 60% 12u "localhost"
	Pop $DB_Host_Control

        ${NSD_CreateLabel} 5% 60u 10% 12u "$(DB_PORT_LABEL)"
	Pop $DB_Port_Label
	${NSD_CreateText} 35% 60u 60% 12u ""
	Pop $DB_Port_Control

        ${NSD_CreateLabel} 5% 80u 30% 12u "$(DB_LOGIN_LABEL)"
	Pop $DB_Login_Label
	${NSD_CreateText} 35% 80u 60% 12u ""
	Pop $DB_Login_Control

        ${NSD_CreateLabel} 5% 100u 30% 12u "$(DB_PASSWORD_LABEL)"
	Pop $DB_Password_Label
	${NSD_CreateText} 35% 100u 60% 12u ""
	Pop $DB_Password_Control

        ${NSD_CreateLabel} 5% 120u 30% 12u "$(DB_NAME_LABEL)"
	Pop $DB_Name_Label
	${NSD_CreateText} 35% 120u 60% 12u ""
	Pop $DB_Name_Control

        Push $DB_DropList
        call DB_OnChange

	nsDialogs::Show
FunctionEnd

Function databaseSettingsLeave
        ${NSD_GetText} $DB_DropList $DB_Type
        ${NSD_GetText} $DB_Host_Control $DB_Host
        ${NSD_GetText} $DB_Port_COntrol $DB_Port
        ${NSD_GetText} $DB_Login_Control $DB_Login
        ${NSD_GetText} $DB_Password_Control $DB_Password
        ${NSD_GetText} $DB_Name_Control $DB_Name
FunctionEnd

!endif
