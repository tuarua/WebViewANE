;contribute: http://github.com/stfx/innodependencyinstaller
;original article: http://codeproject.com/Articles/20868/NET-Framework-1-1-2-0-3-5-Installer-for-InnoSetup

;comment out product defines to disable installing them
;#define use_iis

#define use_dotnetfx46
#define use_msiproduct
#define use_vc2015

#define MyAppSetupName 'WebViewANESample'
#define MyAppVersion '1.7.0'

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
UninstallDisplayIcon={app}\{#MyAppSetupName}.exe
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

; supported languages
#include "scripts\lang\english.iss"
#include "scripts\lang\german.iss"
#include "scripts\lang\french.iss"
#include "scripts\lang\italian.iss"
#include "scripts\lang\dutch.iss"

#ifdef UNICODE
#include "scripts\lang\chinese.iss"
#include "scripts\lang\polish.iss"
#include "scripts\lang\russian.iss"
#include "scripts\lang\japanese.iss"
#endif

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "src\*.*"; DestDir: "{app}"; Flags: replacesameversion
Source: "src\Adobe Air\*.*"; DestDir: "{app}\Adobe Air"; Flags: replacesameversion recursesubdirs
Source: "src\META-INF\*.*"; DestDir: "{app}\META-INF"; Flags: replacesameversion recursesubdirs
Source: "src\locales\*.*"; DestDir: "{app}\locales"; Flags: replacesameversion recursesubdirs
Source: "src\swiftshader\*.*"; DestDir: "{app}\swiftshader"; Flags: replacesameversion recursesubdirs

[Icons]
Name: "{group}\{#MyAppSetupName}"; Filename: "{app}\{#MyAppSetupName}.exe"
Name: "{group}\{cm:UninstallProgram,{#MyAppSetupName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppSetupName}"; Filename: "{app}\{#MyAppSetupName}.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppSetupName}.exe"; Description: "{cm:LaunchProgram,{#MyAppSetupName}}"; Flags: nowait postinstall skipifsilent

[CustomMessages]
DependenciesDir=MyProgramDependencies


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
#ifdef use_vc2015
#include "scripts\products\vcredist2015.iss"
#endif


[Code]
function InitializeSetup(): boolean;
begin
	// initialize windows version
	initwinversion();


#ifdef use_dotnetfx46
    dotnetfx46(62); // min allowed version is 4.6.0
#endif

#ifdef use_vc2015
  SetForceX86(true);
	vcredist2015('14');
#endif



	Result := true;
end;