!ifndef __RUNA_LANG_FILE__
!define __RUNA_LANG_FILE__

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Russian"

LangString RunaWFE_VersionDiffer ${LANG_ENGLISH} "Your current RunaWFE version is differs from installing version. All components will be changed to new one. Continue?"
LangString RunaWFE_VersionDiffer ${LANG_RUSSIAN} "������ ������ RunaWFE ��� ����������� �� ����������. ��� ������������� ���������� ����� �������� �� �������. ����������?"

LangString RunaWFE_VersionInstalled ${LANG_ENGLISH} "Current RunaWFE version is already installed."
LangString RunaWFE_VersionInstalled ${LANG_RUSSIAN} "�� ���������� ��� ����������� ������� ������ RunaWFE."

LangString RunaWFE_Path ${LANG_ENGLISH} "Path:"
LangString RunaWFE_Path ${LANG_RUSSIAN} "����:"

LangString RunaWFE_Continue ${LANG_ENGLISH} "Continue?"
LangString RunaWFE_Continue ${LANG_RUSSIAN} "����������?"

LangString RunaWFE_CurrentlyInstalledEdition ${LANG_ENGLISH} "Currently installed RunaWFE"
LangString RunaWFE_CurrentlyInstalledEdition ${LANG_RUSSIAN} "������������� �� ���������� �������� RunaWFE"

LangString RunaWFE_EditionIncompatible ${LANG_ENGLISH} "is incompatible with RunaWFE Free. Aborting."
LangString RunaWFE_EditionIncompatible ${LANG_RUSSIAN} "������������ � ��������������� RunaWFE Free. ������ ���������."

LangString RunaWFE_EditionInstalling ${LANG_ENGLISH} "You are installing RunaWFE"
LangString RunaWFE_EditionInstalling ${LANG_RUSSIAN} "�� �������������� �������� RunaWFE"

LangString RunaWFE_FreeIsIncompatible ${LANG_ENGLISH} "but installed RunaWFE Free is detected. You will not be able to use RunaWFE Free after installation completion."
LangString RunaWFE_FreeIsIncompatible ${LANG_RUSSIAN} ", �� �� ���������� ���������� RunaWFE Free. � ������� ������� �� Free ����� �����������."

LangString ClientDistr_Desc ${LANG_ENGLISH} "Install RunaWFE client applications. It contains Developer Studio, Task notifier, Web link to main RunaWFE server and RunaWFE simulation server."
LangString ClientDistr_Desc ${LANG_RUSSIAN} "���������� ���������� ���������� RunaWFE. ��������� ���������� �������� � ���� ����� ����������, ����������� ����� � ����� �������� RunaWFE ������."
LangString ServerDistr_Desc ${LANG_ENGLISH} "Install main RunaWFE server."
LangString ServerDistr_Desc ${LANG_RUSSIAN} "���������� �������� RunaWFE ������."

LangString ComponentRTN_Name ${LANG_ENGLISH} "Task notifier"
LangString ComponentRTN_Name ${LANG_RUSSIAN} "����������� �����"
LangString ComponentWEB_Name ${LANG_ENGLISH} "Web link"
LangString ComponentWEB_Name ${LANG_RUSSIAN} "�������� ������"
LangString ComponentGPD_Name ${LANG_ENGLISH} "Developer Studio"
LangString ComponentGPD_Name ${LANG_RUSSIAN} "����� ����������"
LangString ComponentSIM_Name ${LANG_ENGLISH} "Simulation server"
LangString ComponentSIM_Name ${LANG_RUSSIAN} "������-���������"

LangString ComponentSRV_Name ${LANG_ENGLISH} "Server"
LangString ComponentSRV_Name ${LANG_RUSSIAN} "������"

LangString ComponentJBOSS_Name ${LANG_ENGLISH} ""
LangString ComponentJBOSS_Name ${LANG_RUSSIAN} ""

LangString ComponentGPD_Desc ${LANG_ENGLISH} "Developer Studio is an application to develop processes for RunaWFE"
LangString ComponentGPD_Desc ${LANG_RUSSIAN} "����� ���������� - ����������, ��������������� ��� ���������� ��������� ������� RunaWFE"
LangString ComponentRTN_Desc ${LANG_ENGLISH} "Task notifier is an application for automatic checks for new tasks"
LangString ComponentRTN_Desc ${LANG_RUSSIAN} "����������� ������ - ����������, ��������������� ��� �������������� �������� �� ����� ������ ������������"
LangString ComponentWEB_Desc ${LANG_ENGLISH} "Web link to main workflow server"
LangString ComponentWEB_Desc ${LANG_RUSSIAN} "������ �� web ��������� ��������� RunaWFE �������"
LangString ComponentSIM_Desc ${LANG_ENGLISH} "RunaWFE simulation server - used for testing purposes"
LangString ComponentSIM_Desc ${LANG_RUSSIAN} "�������� RunaWFE ������. ������������ ��� ������������ ��������� � �. �."

LangString ComponentSRV_Desc ${LANG_ENGLISH} "RunaWFE server"
LangString ComponentSRV_Desc ${LANG_RUSSIAN} "������ RunaWFE"

LangString ComponentJBOSS_Desc ${LANG_ENGLISH} ""
LangString ComponentJBOSS_Desc ${LANG_RUSSIAN} ""

LangString ShortcutDesc_GPD ${LANG_ENGLISH} "Developer Studio is an application to develop processes for RunaWFE"
LangString ShortcutDesc_GPD ${LANG_RUSSIAN} "����� ���������� - ����������, ��������������� ��� ���������� ��������� ������� RunaWFE"
LangString ShortcutDesc_RTN ${LANG_ENGLISH} "Task notifier is an application for automatic checks for new tasks"
LangString ShortcutDesc_RTN ${LANG_RUSSIAN} "����������� ������ - ����������, ��������������� ��� �������������� �������� �� ����� ������ ������������"
LangString ShortcutDesc_StartSim ${LANG_ENGLISH} "Start RunaWFE simulation server"
LangString ShortcutDesc_StartSim ${LANG_RUSSIAN} "��������� �������� ������ RunaWFE"
LangString ShortcutDesc_StopSim ${LANG_ENGLISH} "Stop RunaWFE simulation server"
LangString ShortcutDesc_StopSim ${LANG_RUSSIAN} "���������� �������� ������ RunaWFE"

LangString DesktopLinks ${LANG_ENGLISH} "Install links to runawfe applications at desktop"
LangString DesktopLinks ${LANG_RUSSIAN} "�������� �� ������� ���� ������ ���������� runawfe"
LangString installNewDatabase ${LANG_ENGLISH} "Delete old runawfe database and install new database for simulation server (with demo processes)"
LangString installNewDatabase ${LANG_RUSSIAN} "������� ������ ���� ������ �������-���������� � ��������� ����� ���� ������ (� ����������������� ����������)"
LangString installNewWorkspace ${LANG_ENGLISH} "Delete old (from previous installations) runawfe demo processes and install new"
LangString installNewWorkspace ${LANG_RUSSIAN} "������� ������ (���������� ����� ���������� ���������) ���������������� �������� � ���������� �����"
LangString installSimulationLoginLinks ${LANG_ENGLISH} "Install web links to enter simulation as demo user"
LangString installSimulationLoginLinks ${LANG_RUSSIAN} "���������� ������ � web ���������� ��� ����� � ��������� ��� ���� ��������������"
LangString installCleanAllOldData ${LANG_ENGLISH} "Remove all data/artifacts from old installation (clean install)"
LangString installCleanAllOldData ${LANG_RUSSIAN} "������� ��� ������ � ���������, ���������� �� ���������� ���������"
LangString installAllowStatisticReport ${LANG_ENGLISH} "Allow reporting technical information about operation of a system. This data will help us to develop and improve the product."
LangString installAllowStatisticReport ${LANG_RUSSIAN} "�������� ����������� ���������� � ������ �������. ��� ������ ��������� ��� ��� �������� � ��������� �������."
LangString installRtnAutorunAtSystemStartup ${LANG_ENGLISH} "Task-notification app run automatically at startup OS."
LangString installRtnAutorunAtSystemStartup ${LANG_RUSSIAN} "������������� ��������� ����������� ����� ��� ������ �������."

LangString rebootIsRequired ${LANG_ENGLISH} "Reboot is required for correct service start. Reboot now?"
LangString rebootIsRequired ${LANG_RUSSIAN} "��� ���������� ������ ������������� ������������� ���������. ������������� ����������?"

  LangString TEXT_SERVERINFO ${LANG_ENGLISH} "Some of selected components need additional information. Type host name (in DNS notation or IP address) and port of main RunaWFE server."
  LangString TEXT_SERVERINFO ${LANG_RUSSIAN} "��������� �� ��������� ����������� ��������� ����� ��������� RunaWFE �������. ������� ��� ������� (� ���� DNS ����� ��� IP ������) � web ���� ��������� ������� RunaWFE"
  LangString TEXT_SERVERINFO_SERVER ${LANG_ENGLISH} "Select a port for RunaWFE web interface"
  LangString TEXT_SERVERINFO_SERVER ${LANG_RUSSIAN} "�������� ����, �� ������� ����� �������� Web ��������� RunaWFE"
  LangString TEXT_SERVERINFO_HOST ${LANG_ENGLISH} "Host:"
  LangString TEXT_SERVERINFO_HOST ${LANG_RUSSIAN} "����:"
  LangString TEXT_SERVERINFO_PORT ${LANG_ENGLISH} "Port:"
  LangString TEXT_SERVERINFO_PORT ${LANG_RUSSIAN} "����:"
  LangString TEXT_SERVERINFO_HOSTEMPTY ${LANG_ENGLISH} "Host is empty. Set correct host name."
  LangString TEXT_SERVERINFO_HOSTEMPTY ${LANG_RUSSIAN} "��� ������� ������. ���������� ��� ��������� ������� RunaWFE"
  LangString TEXT_SERVERINFO_TITLE ${LANG_ENGLISH} "More information required"
  LangString TEXT_SERVERINFO_TITLE ${LANG_RUSSIAN} "���������� �������������� ����������"

  LangString TEXT_JAVAHOME_TITLE ${LANG_ENGLISH} "JAVA_HOME system variable installation"
  LangString TEXT_JAVAHOME_TITLE ${LANG_RUSSIAN} "��������� ��������� ���������� JAVA_HOME"
  LangString TEXT_JAVAHOME_REASON ${LANG_ENGLISH} "It's strongly recomended to point system variable JAVA_HOME to Java Development Kit (not Java Runtime Environment) for correct working of RunaWFE server. Set checkbox to point JAVA_HOME to Java."
  LangString TEXT_JAVAHOME_REASON ${LANG_RUSSIAN} "��� ���������� ������ ������� RunaWFE ������������� ���������� ��������� ���������� JAVA_HOME �� Java Development Kit. ���������� ������, ����� ������� JAVA_HOME"
  LangString ENV_VAR_WARN ${LANG_ENGLISH} "The System Properties window is open. You should close it for correct operation."
  LangString ENV_VAR_WARN ${LANG_RUSSIAN} "���� �������� ������� �������. ��� ���������� ������ ������� ������� ���."

LangString JDK_INSTALLREASON ${LANG_ENGLISH} "Some of your components need Java to work. JRE will be installed."
LangString JDK_INSTALLREASON ${LANG_RUSSIAN} "��������� �� ��������� ����������� ��� ������� ��������� JRE. ���������� JRE �� ��������� ����."

LangString JDK_INSTALL_LABEL ${LANG_ENGLISH} "Install JRE"
LangString JDK_INSTALL_LABEL ${LANG_RUSSIAN} "����������"
LangString JDK_EXIT_LABEL ${LANG_ENGLISH} "Exit"
LangString JDK_EXIT_LABEL ${LANG_RUSSIAN} "�����"

LangString RUNA_LOGO_IMG ${LANG_ENGLISH} "logo_runa_en.bmp"
LangString RUNA_LOGO_IMG ${LANG_RUSSIAN} "logo_runa_ru.bmp"

LangString TEXT_PROJECT_SITE ${LANG_ENGLISH} "Project site: http://www.runawfe.org"
LangString TEXT_PROJECT_SITE ${LANG_RUSSIAN} "���� �������: https://runawfe.ru/RunaWFE"
LangString LINK_PROJECT_SITE ${LANG_ENGLISH} "http://www.runawfe.org"
LangString LINK_PROJECT_SITE ${LANG_RUSSIAN} "https://runawfe.ru/RunaWFE"

LangString TEXT_BEGIN_INSTALLATION ${LANG_ENGLISH} "Install"
LangString TEXT_BEGIN_INSTALLATION ${LANG_RUSSIAN} "����������"
LangString TEXT_ANNOTATION_INSTALLATION ${LANG_ENGLISH} "Runa WFE is a free solution for enterprise business processes management. It is delivered under LGPL licence. RunaWFE consists of workflow core and a set of additional components. The main goal of these components is to provide convenience to the end-user.\n\nFor a first quick glimpse of the system it is recommended to install only client components. Client component $\"Simulation server$\" is a version of RunaWFE server adopted for a working station. Start $\"Simulation server$\" in order to start the system. This can be done from the menu option Start/Programs/RunaWFE/Start Simulation. Next step is to run web-interface by choosing Start/Programs/RunaWFE/Simulation Web Interface.\n\nAdministrator's default login is $\"Administrator$\", password is $\"wf$\"."
LangString TEXT_ANNOTATION_INSTALLATION ${LANG_RUSSIAN} "RunaWFE - ��� ��������� ������� �� ���������� ������ ���������� �����������. ���������������� ��� �������� ��������� LGPL. RunaWFE ������� �� workflow ���� � ������ �������������� �����������, ������ ������� - ���������� ������� ������ ��������� ������������.\n\n��� ������� ���������� � �������� ������������� ���������� �� ��������� ������  ���������� ����������. ���������� ��������� $\"������-���������$\" �������� �������������� ��� ������� ������� ������� RunaWFE �������.\n\n��� ������ ������ � �������� ��������� $\"������-���������$\". ��� ����� ������� �������� ���� ����/���������/RunaWFE/Start Simulation. ����� ��������� web-��������� ���������� - ����/���������/RunaWFE/Simulation Web Interface.\n\n����� �������������� �� ��������� � $\"Administrator$\", ������� $\"wf$\"."

LangString CloseBtn ${LANG_ENGLISH} "Close"
LangString CloseBtn ${LANG_RUSSIAN} "������"

LangString DB_H2_DEFAULT ${LANG_ENGLISH} "H2 Database Engine (by default)"
LangString DB_H2_DEFAULT ${LANG_RUSSIAN} "H2 Database Engine (�� ���������)"
LangString DB_POSTGRESQL ${LANG_ENGLISH} "PostgreSQL"
LangString DB_POSTGRESQL ${LANG_RUSSIAN} "PostgreSQL"
LangString DB_MSSQL ${LANG_ENGLISH} "MS SQL"
LangString DB_MSSQL ${LANG_RUSSIAN} "MS SQL"
LangString DB_ORACLE ${LANG_ENGLISH} "Oracle"
LangString DB_ORACLE ${LANG_RUSSIAN} "Oracle"

LangString DB_DIALOG_LABEL ${LANG_ENGLISH} "Database settings"
LangString DB_DIALOG_LABEL ${LANG_RUSSIAN} "��������� ����������� � ���� ������"
LangString DB_TYPE_LABEL ${LANG_ENGLISH} "SQL server"
LangString DB_TYPE_LABEL ${LANG_RUSSIAN} "SQL ������"
LangString DB_HOST_LABEL ${LANG_ENGLISH} "Host"
LangString DB_HOST_LABEL ${LANG_RUSSIAN} "����"
LangString DB_PORT_LABEL ${LANG_ENGLISH} "Port"
LangString DB_PORT_LABEL ${LANG_RUSSIAN} "����"
LangString DB_LOGIN_LABEL ${LANG_ENGLISH} "Login"
LangString DB_LOGIN_LABEL ${LANG_RUSSIAN} "�����"
LangString DB_PASSWORD_LABEL ${LANG_ENGLISH} "Password"
LangString DB_PASSWORD_LABEL ${LANG_RUSSIAN} "������"
LangString DB_NAME_LABEL ${LANG_ENGLISH} "Database"
LangString DB_NAME_LABEL ${LANG_RUSSIAN} "�������� ���� ������"

!endif
