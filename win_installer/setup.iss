;contribute on http://github.com/stfx/innodependencyinstaller or http://codeproject.com/Articles/20868/NET-Framework-1-1-2-0-3-5-Installer-for-InnoSetup

;comment out product defines to disable installing them
;#define use_iis

#define use_dotnetfx46
#define use_msiproduct
#define use_vc2013
#define use_vc2015

#define MyAppSetupName 'WebViewANESample'
#define MyAppVersion '0.0.24'

[Setup]
AppName={#MyAppSetupName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppSetupName} {#MyAppVersion}
AppCopyright=Copyright © 2017 Tua Rua Ltd
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany=Tua Rua Ltd.
AppPublisher=Tua Rua Ltd.
;AppPublisherURL=http://...
;AppSupportURL=http://...
;AppUpdatesURL=http://...
OutputBaseFilename={#MyAppSetupName}-{#MyAppVersion}
DefaultGroupName={#MyAppSetupName}
DefaultDirName={pf}\{#MyAppSetupName}
UninstallDisplayIcon={app}\WebViewANESample.exe
OutputDir=bin
SourceDir=.
AllowNoIcons=yes
;SetupIconFile=MyProgramIcon
SolidCompression=yes

;MinVersion default value: "0,5.0 (Windows 2000+) if Unicode Inno Setup, else 4.0,4.0 (Windows 95+)"
;MinVersion=0,5.0
PrivilegesRequired=admin
ArchitecturesAllowed=x86 x64 ia64

;Downloading and installing dependencies will only work if the memo/ready page is enabled (default behaviour)
DisableReadyPage=no
DisableReadyMemo=no

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"
Name: "it"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "nl"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "pl"; MessagesFile: "compiler:Languages\Polish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "src\*.*"; DestDir: "{app}"; Flags: replacesameversion
Source: "src\Adobe Air\*.*"; DestDir: "{app}\Adobe Air"; Flags: replacesameversion recursesubdirs
Source: "src\META-INF\*.*"; DestDir: "{app}\META-INF"; Flags: replacesameversion recursesubdirs
Source: "src\locales\*.*"; DestDir: "{app}\locales"; Flags: replacesameversion recursesubdirs

[Icons]
Name: "{group}\{#MyAppSetupName}"; Filename: "{app}\WebViewANESample.exe"
Name: "{group}\{cm:UninstallProgram,{#MyAppSetupName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppSetupName}"; Filename: "{app}\{#MyAppSetupName}.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppSetupName}.exe"; Description: "{cm:LaunchProgram,{#MyAppSetupName}}"; Flags: nowait postinstall skipifsilent

[CustomMessages]
win_sp_title=Windows %1 Service Pack %2


; shared code for installing the products
#include "scripts\products.iss"
; helper functions
#include "scripts\products\stringversion.iss"
#include "scripts\products\winversion.iss"
#include "scripts\products\fileversion.iss"
#include "scripts\products\dotnetfxversion.iss"

; actual products



#ifdef use_dotnetfx46
#include "scripts\products\dotnetfx46.iss"
#endif

#ifdef use_msiproduct
#include "scripts\products\msiproduct.iss"
#endif
#ifdef use_vc2013
#include "scripts\products\vcredist2013.iss"
#endif
#ifdef use_vc2015
#include "scripts\products\vcredist2015.iss"
#endif


[Code]
function InitializeSetup(): boolean;
begin
	// initialize windows version
	initwinversion();






#ifdef use_dotnetfx46
    dotnetfx46(60); // min allowed version is 4.6.0
#endif

#ifdef use_vc2013
	SetForceX86(true); // force 32-bit install of next products
	vcredist2013();
	//SetForceX86(false); // disable forced 32-bit install again
#endif
#ifdef use_vc2015
  SetForceX86(true);
	vcredist2015();
#endif



	Result := true;
end;
