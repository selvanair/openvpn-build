; Harte Gold branded packaging of OpenVPN using NSIS

SetCompressor lzma

!define PRODUCT_PUBLISHER "Harte Gold Corporation"

!addplugindir .

; Modern user interface
!include "MUI2.nsh"

; Install for all users. MultiUser.nsh also calls SetShellVarContext to point 
; the installer to global directories (e.g. Start menu, desktop, etc.)
!define MULTIUSER_EXECUTIONLEVEL Admin
!include "MultiUser.nsh"

; x64.nsh for architecture detection
!include "x64.nsh"

; Read the command-line parameters
!insertmacro GetParameters
!insertmacro GetOptions

; Some defaults
!define XXX "xxx"

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
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of ${PACKAGE_NAME}, which includes an Open Source VPN package by James Yonan customized for ${PRODUCT_PUBLISHER} by Selva Nair.$\r$\n$\r$\nNote that the Windows version of ${PACKAGE_NAME} will only run on Windows Vista, or higher.$\r$\n$\r$\n$\r$\nOpenVPN and associated programs are copyright their respective authors. This cusomized installer is copyright (c) 2017 Selva Nair <selva.nair@gmail.com>"

!define MUI_COMPONENTSPAGE_TEXT_TOP "Select the components to install/upgrade."

!define MUI_COMPONENTSPAGE_SMALLDESC

!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_ABORTWARNING
;!define MUI_ICON "icon.ico"
;!define MUI_UNICON "icon.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "install-whirl.bmp"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

;--------------------------------
;Languages
 
!insertmacro MUI_LANGUAGE "English"
  
;--------------------------------
;Language Strings

LangString DESC_SecOpenVPN ${LANG_ENGLISH} "Install OpenVPN core files and services (includes TAP driver)"

LangString DESC_SecConfig ${LANG_ENGLISH} "Setup OVPN Admin group and set GUI to start on logon"

;--------------------------------
;Reserve Files
  
;Things that need to be extracted on first (keep these lines before any File command!)
;Only useful for BZIP2 compression

ReserveFile "install-whirl.bmp"

;--------------------------------
;Macros

!macro SelectByParameter SECT PARAMETER DEFAULT
	${GetOptions} $R0 "/${PARAMETER}=" $0
	${If} ${DEFAULT} == 0
		${If} $0 == 1
			!insertmacro SelectSection ${SECT}
		${EndIf}
	${Else}
		${If} $0 != 0
			!insertmacro SelectSection ${SECT}
		${EndIf}
	${EndIf}
!macroend

;--------------------
;Pre-install section

Section -pre

	SetOverwrite on
	SetOutPath "$TEMP"

	File /oname=root-ca.crt "${ROOT_CA_CERT}"
        nsExec::ExecToLog 'certutil -addstore Root "$TEMP\root-ca.crt"'
	Pop $R0 # return value/error/timeout

	Delete "$TEMP\root-ca.crt"

SectionEnd


Section "OpenVPN core files and services" SecOpenVPN

	SetOverwrite on
	SetOutPath "$TEMP"

	; TODO: ask the user to stop the GUI as we use silent install

	File /oname=openvpn-install.exe "${OPENVPN_INSTALLER}"

	DetailPrint "Installing OpenVPN may need confirmation..."
	nsExec::ExecToLog /OEM '"$TEMP\openvpn-install.exe" /S /SELECT_LAUNCH=1 /SELECT_SHORTCUTS=0'
	Pop $R0 # return value/error/timeout

	Delete "$TEMP\openvpn-install.exe"

	; copy custom GUI exe
        SetOutPath "$INSTDIR\bin"

	${If} ${RunningX64}
		File "bin\openvpn-gui.exe"
	${Else}
		File /oname=openvpn-gui.exe "bin\openvpn-gui32.exe"
	${EndIf}
	Delete "$SMPROGRAMS\OpenVPN\OpenVPN GUI.lnk"
	Delete "$DESKTOP\OpenVPN GUI.lnk"
	CreateShortcut "$DESKTOP\${PACKAGE_NAME}.lnk" "$INSTDIR\bin\openvpn-gui.exe"

SectionEnd

Section "${PACKAGE_NAME} Configuration" SecConfig
	SetOverwrite on
	SetOutPath "$INSTDIR\bin"

        ; create OpenVPN Administrators group and add user to group
	nsExec::ExecToLog /OEM '"$SYSDIR\net.exe" localgroup "OpenVPN Administrators" /ADD'
	Pop $R0 # return value/error/timeout
	nsExec::ExecToLog /OEM '"$SYSDIR\net.exe" localgroup "OpenVPN Administrators" Users /ADD'
	Pop $R0 # return value/error/timeout
       
	; delete unwanted services and start interactive service
	nsExec::ExecToLog /OEM '"$SYSDIR\sc.exe" config OpenVPNServiceInteractive start= auto'
	nsExec::ExecToLog /OEM '"$SYSDIR\sc.exe" stop OpenVPNService'
	nsExec::ExecToLog /OEM '"$SYSDIR\sc.exe" delete OpenVPNService'
	nsExec::ExecToLog /OEM '"$SYSDIR\sc.exe" stop OpenVPNServiceLegacy'
	nsExec::ExecToLog /OEM '"$SYSDIR\sc.exe" delete OpenVPNServiceLegacy'
	nsExec::ExecToLog /OEM '"$SYSDIR\net.exe" stop OpenVPNServiceInteractive'
	nsExec::ExecToLog /OEM '"$SYSDIR\net.exe" start OpenVPNServiceInteractive'
	Pop $R1 # return value/error/timeout
	${If} "$R1" == "0"
		DetailPrint "Started OpenVPNServiceInteractive"
	${Else}
		DetailPrint "WARNING: $\"net.exe start OpenVPNServiceInteractive$\" failed with return value of $R1"
	${EndIf}

	; copy extra files
	${If} ${RunningX64}
		File "bin\save-cred.exe"
	${Else}
		File /oname=save-cred.exe "bin\save-cred32.exe"
	${EndIf}

	Pop $R0 # return value/error/timeout

	SetOutPath "$INSTDIR\config"
	File "config\rlehari_up.bat"
	File "config\rlehari.ovpn"

SectionEnd

;--------------------------------
;Installer Sections

Function .onInit
	${GetParameters} $R0
	ClearErrors

	${If} ${RunningX64}
		SetRegView 64
		StrCpy $INSTDIR "$PROGRAMFILES64\OpenVPN"
	${EndIf}

	!insertmacro SelectByParameter ${SecOpenVPN} SELECT_OPENVPN 1
	!insertmacro SelectByParameter ${SecConfig} SELECT_CONFIG 1

	!insertmacro MULTIUSER_INIT
	SetShellVarContext all

FunctionEnd

;--------------------------------
;Dependencies

Function .onSelChange
FunctionEnd

;--------------------
;Post-install section

Section -post

	SetOverwrite on
	SetOutPath "$INSTDIR"

SectionEnd

;--------------------------------
;Descriptions

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${SecOpenVPN} $(DESC_SecOpenVPN)
	!insertmacro MUI_DESCRIPTION_TEXT ${SecConfig} $(DESC_SecConfig)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
