; Harte Gold VP config and cert/key distribution pakacge

SetCompressor lzma

!define PRODUCT_PUBLISHER "Harte Gold Corporation"

!addplugindir .

; Modern user interface
!include "MUI2.nsh"

; Install for current user in user's profile
!define MULTIUSER_EXECUTIONLEVEL user
!include "MultiUser.nsh"

; x64.nsh for architecture detection
!include "x64.nsh"

; Read the command-line parameters
!insertmacro GetParameters
!insertmacro GetOptions

;--------------------------------
;Configuration

; Package name as shown in the installer GUI
Name "${PACKAGE_NAME} ${VERSION_STRING}"

; PROGRAMFILES gets properly defined for 64 bit and 32 bit
InstallDir "$PROGRAMFILES\OpenVPN"

; Installer filename
OutFile "${OUTPUT}"

ShowInstDetails show

;--------------------------------
;Modern UI Configuration

; Compile-time constants which we'll need during install
!define MUI_WELCOMEPAGE_TEXT "This will install the certificate and connection profile for using ${PACKAGE_NAME}. You will require the certificate key password to comlete the installation.$\r$\nIf you do not have the password, please contact the administrator.$\r$\n$\r$\nA separate Certificate Import Wizard will open during the instalaltion -- follow its prompts, input the password and complete the import.$\r$\n$\r$\n$\r$\nCopyright (c) 2017 Selva Nair <selva.nair@gmail.com>"

!define MUI_COMPONENTSPAGE_TEXT_TOP "Select the components to install/upgrade."

!define MUI_COMPONENTSPAGE_SMALLDESC

!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_ABORTWARNING
;!define MUI_ICON "icon.ico"
;!define MUI_UNICON "icon.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "install-whirl.bmp"

!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Start the VPN client"
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchGUI"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

;--------------------------------
;Languages
 
!insertmacro MUI_LANGUAGE "English"
  
;--------------------------------
;Language Strings

LangString DESC_SecCert ${LANG_ENGLISH} "Install certificate and private key"
LangString DESC_SecConfig ${LANG_ENGLISH} "Install connection profile and scripts"

;--------------------------------
;Reserve Files
  
;Things that need to be extracted on first (keep these lines before any File command!)
;Only useful for BZIP2 compression

ReserveFile "install-whirl.bmp"

;--------------------------------
;Macros

;--------------------
;Pre-install section

Section -pre
SectionEnd

Section "Certificate and Key" SecCert
	SetOverwrite on
	;SetOutPath "$TEMP"
	SetOutPath "$INSTDIR\config\${CONFIG}"

	File "config\${CONFIG}.p12"
	ExecShell "" "$INSTDIR\config\${CONFIG}\${CONFIG}.p12"
        ;nsExec::ExecToLog 'certutil -f -user -importpfx "$TEMP\user-cert.p12" NoExport'

	Pop $R0 # return value/error/timeout

	;Delete "$TEMP\user-cert.p12"

SectionEnd

Section "Connection Profile and Scripts" SecConfig
	SetOverwrite on
	SetOutPath "$INSTDIR\config\${CONFIG}"

	File "config\${CONFIG}.ovpn"
	File "config\${CONFIG}_up.bat"
	; copy extra files
SectionEnd

;--------------------------------
;Installer Sections

Function .onInit
	${GetParameters} $R0
	ClearErrors

	${If} ${RunningX64}
		SetRegView 64
	${EndIf}
	StrCpy $INSTDIR "$PROFILE\OpenVPN"
	!insertmacro MULTIUSER_INIT
FunctionEnd

Function LaunchGUI
	${If} ${RunningX64}
		ExecShell "" "$PROGRAMFILES64\OpenVPN\bin\openvpn-gui.exe"
	${Else}	
		ExecShell "" "$PROGRAMFILES\OpenVPN\bin\openvpn-gui.exe"
	${EndIf}

FunctionEnd

;--------------------------------
;Dependencies

Function .onSelChange
FunctionEnd

;--------------------
;Post-install section

Section -post

SectionEnd

;--------------------------------
;Descriptions

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${SecCert} $(DESC_SecCert)
	!insertmacro MUI_DESCRIPTION_TEXT ${SecConfig} $(DESC_SecConfig)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
