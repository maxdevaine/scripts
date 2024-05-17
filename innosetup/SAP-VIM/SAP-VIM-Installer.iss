;InnoSetupVersion=6.2.0
;Documentation :
;http://www.jrsoftware.org/ishelp/index.php
;Author: Max Devaine <maxdevaine@gmail.com>
;License: GPLv2

#define AppName "0- SAP VIM Installer "
#define AppShortName "SAPVIM-Installer"
#define AppPublisher "COMPANY a.s."
#define AppVersion "1.0.9"
#define DefaultDirName "C:\company_sap"

[Setup]
AppName={#AppName}
AppVersion={#AppVersion}
AppID={#AppName}
VersionInfoDescription=SAP VIM Installer Setup
VersionInfoProductName=0- SAP VIM Installer -0
;CreateAppDir=false
DefaultDirName={#DefaultDirName}
DefaultGroupName={#AppPublisher}
OutputBaseFilename=SAPVIM-Installer-{#AppVersion}
Compression=lzma2
SolidCompression=yes
;PrivilegesRequired=none
PrivilegesRequired=admin
;LicenseFile={#file AddBackslash(SourcePath) + "ISPPExample1License.txt"}
;UninstallDisplayIcon={app}\MyProg.exe
WizardImageFile=MIS_Library-logo2.bmp
SetupIconFile=icons\install.ico
UninstallIconFile=icons\uninstall.ico
//UninstallDisplayIcon={app}\icons\uninstall.ico
UninstallDisplayIcon={uninstallexe}
;DisableReadyMemo=yes
;DisableReadyPage=yes
;DisableWelcomePage=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
;DisableFinishedPage=yes
;DisableStartupPrompt=yes
;EnableDirDoesntExistWarning=no

;Password=heslo
;Encryption=yes

;LanguageDetectionMethod=uilanguage
;ChangesEnvironment=yes


[Code]
function IsDotNetDetected(version: string; service: cardinal): boolean;
// Indicates whether the specified version and service pack of the .NET Framework is installed.
//
// version -- Specify one of these strings for the required .NET Framework version:
//    'v1.1'          .NET Framework 1.1
//    'v2.0'          .NET Framework 2.0
//    'v3.0'          .NET Framework 3.0
//    'v3.5'          .NET Framework 3.5
//    'v4\Client'     .NET Framework 4.0 Client Profile
//    'v4\Full'       .NET Framework 4.0 Full Installation
//    'v4.5'          .NET Framework 4.5
//    'v4.5.1'        .NET Framework 4.5.1
//    'v4.5.2'        .NET Framework 4.5.2
//    'v4.6'          .NET Framework 4.6
//    'v4.6.1'        .NET Framework 4.6.1
//    'v4.6.2'        .NET Framework 4.6.2
//    'v4.7'          .NET Framework 4.7
//    'v4.7.1'        .NET Framework 4.7.1
//    'v4.7.2'        .NET Framework 4.7.2
//    'v4.8.0'        .NET Framework 4.8.0
//
// service -- Specify any non-negative integer for the required service pack level:
//    0               No service packs required
//    1, 2, etc.      Service pack 1, 2, etc. required
var
    key, versionKey: string;
    install, release, serviceCount, versionRelease: cardinal;
    success: boolean;
begin
    versionKey := version;
    versionRelease := 0;

    // .NET 1.1 and 2.0 embed release number in version key
    if version = 'v1.1' then begin
        versionKey := 'v1.1.4322';
    end else if version = 'v2.0' then begin
        versionKey := 'v2.0.50727';
    end

    // .NET 4.5 and newer install as update to .NET 4.0 Full
    else if Pos('v4.', version) = 1 then begin
        versionKey := 'v4\Full';
        case version of
          'v4.5':   versionRelease := 378389;
          'v4.5.1': versionRelease := 378675; // 378758 on Windows 8 and older
          'v4.5.2': versionRelease := 379893;
          'v4.6':   versionRelease := 393295; // 393297 on Windows 8.1 and older
          'v4.6.1': versionRelease := 394254; // 394271 before Win10 November Update
          'v4.6.2': versionRelease := 394802; // 394806 before Win10 Anniversary Update
          'v4.7':   versionRelease := 460798; // 460805 before Win10 Creators Update
          'v4.7.1': versionRelease := 461308; // 461310 before Win10 Fall Creators Update
          'v4.7.2': versionRelease := 461808; // 461814 before Win10 April 2018 Update
          'v4.8.0': versionRelease := 528372; // 
        end;
    end;

    // installation key group for all .NET versions
    key := 'SOFTWARE\Microsoft\NET Framework Setup\NDP\' + versionKey;

    // .NET 3.0 uses value InstallSuccess in subkey Setup
    if Pos('v3.0', version) = 1 then begin
        success := RegQueryDWordValue(HKLM, key + '\Setup', 'InstallSuccess', install);
    end else begin
        success := RegQueryDWordValue(HKLM, key, 'Install', install);
    end;

    // .NET 4.0 and newer use value Servicing instead of SP
    if Pos('v4', version) = 1 then begin
        success := success and RegQueryDWordValue(HKLM, key, 'Servicing', serviceCount);
    end else begin
        success := success and RegQueryDWordValue(HKLM, key, 'SP', serviceCount);
    end;

    // .NET 4.5 and newer use additional value Release
    if versionRelease > 0 then begin
        success := success and RegQueryDWordValue(HKLM, key, 'Release', release);
        success := success and (release >= versionRelease);
    end;

    result := success and (install = 1) and (serviceCount >= service);
end;


function InitializeSetup(): Boolean;
begin
    if not IsDotNetDetected('v4.8', 0) then begin
        MsgBox('MyApp requires Microsoft .NET Framework 4.8.'#13#13
            'Please use Windows Update to install this version,'#13
            'and then re-run the MyApp setup program.', mbInformation, MB_OK);
        result := false;
    end else
        result := true;
end;


// Check previos version to uninstall
function GetUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstPathOLD: String;
  sUnInstallString: String;
begin
  sUnInstPathOLD := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\0- SAP VIM Installer -0_is1');
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#emit SetupSetting("AppId")}_is1');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPathOLD, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;


function IsUpgrade(): Boolean;
begin
  Result := (GetUninstallString() <> '');
end;


function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
// Return Values:
// 1 - uninstall string is empty
// 2 - error executing the UnInstallString
// 3 - successfully executed the UnInstallString

  // default return value
  Result := 0;

  // get the uninstall string of the old app
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
end;



procedure CurStepChanged(CurStep: TSetupStep);

begin
  // Uninstall old version :
  if (CurStep=ssInstall) then
    begin
      if (IsUpgrade()) then
        begin
          UnInstallOldVersion();
        end;
    end;
  // Apply registry values after install
  if CurStep=ssPostInstall then 
    begin
     RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\IXOS\IXOS_ARCHIVE\Common', 'DPDIR', 'C:\OpenText\DPDIR');
     RegWriteDWordValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\IXOS\IXOS_ARCHIVE\CLIENT_INST_SCAN', 'CUSTDP', 1);
     RegWriteDWordValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\IXOS\IXOS_ARCHIVE\CLIENT_INST_SCAN\FEATURES', 'CUSTDP', 1);
    end;
end;




[Dirs]
Name: "{#DefaultDirName}"; Permissions: users-full; Flags: UninsNeverUninstall;
Name: "{#DefaultDirName}\logs"; Permissions: users-full; Flags: UninsNeverUninstall;
Name: "C:\OpenText\dp\base\config\servtab\NA"; Flags: deleteafterinstall;

[Files]
Source: "sources\UNZIP.EXE"; DestDir: "{tmp}\SAPVIM-INSTALL"; Flags: deleteafterinstall;
Source: "sources\source.zip"; DestDir: "{tmp}\SAPVIM-INSTALL"; Flags:deleteafterinstall;
Source: "sources\mv.exe"; DestDir: "{tmp}\SAPVIM-INSTALL"; Flags:deleteafterinstall;
Source: "sources\cp.exe"; DestDir: "{tmp}\SAPVIM-INSTALL"; Flags:deleteafterinstall;

[Messages]
WelcomeLabel2=This will install [name/ver] on your computer.%n%n- SAP Connector%n- Entreprise Scan%n- Document Pipeline%n- Validation Client%n- Language Pack %n- ES Config

[Icons]
Name: "{group}\{#AppShortName}\Uninstall"; Filename: "{uninstallexe}"

[Run]
; Unpack source file
Filename: "{tmp}\SAPVIM-INSTALL\UNZIP.EXE"; Parameters: " -qq -o {tmp}\SAPVIM-INSTALL\source.zip -d {tmp}\SAPVIM-INSTALL\unpack"; Flags: runhidden; StatusMsg: "(1/32) Unpacking source.zip..."

; 01 - Install SAP Connector
Filename: "{tmp}\SAPVIM-INSTALL\unpack\01_SAP_connector\sapnco31P_4-70002626\SapNCox86Setup.exe"; Parameters: "/Silent"; WorkingDir: {tmp}\SAPVIM-INSTALL\unpack\01_SAP_connector\; StatusMsg: "(2/32) Installing: SAP Connector";

; 02 - Install Enterprise Scan
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\SAPVIM-INSTALL\unpack\02_Entreprise_scan\01-OT-SCAN-1640\Enterprise Scan 16.4.0.msi"" INSTALLDIR=""C:\OpenText\DPDIR"" DP_DIR=""C:\OpenText\DPDIR"" DP_HOST=""localhost"" REMOTEINTERFACE_MODE=""no"" /qn  /l ""{#DefaultDirName}\logs\opentext-entscan.log"""; WorkingDir: {tmp}\SAPVIM-INSTALL\unpack\02_Entreprise_scan\01-OT-SCAN-1640\;  StatusMsg: "(3/32) Installing: Enterprise Scan";
Filename: "msiexec.exe"; Parameters: "/p ""{tmp}\SAPVIM-INSTALL\unpack\02_Entreprise_scan\02-OT-SCAN-1640-patch\esc-1640-005.msp"" /qn /l ""{#DefaultDirName}\logs\opentext-entscan-patch.log"""; WorkingDir: {tmp}\SAPVIM-INSTALL\unpack\02_Entreprise_scan\02-OT-SCAN-1640-patch\;  StatusMsg: "(4/32) Installing: Enterprise Scan Patch";
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\SAPVIM-INSTALL\unpack\02_Entreprise_scan\03-Imaging_plugin\Capture Imaging Plugin 16.6.10.msi"" /qn /l ""{#DefaultDirName}\logs\opentext-entscan-plugin.log"""; WorkingDir: {tmp}\SAPVIM-INSTALL\unpack\02_Entreprise_scan\03-Imaging_plugin\;  StatusMsg: "(5/32) Installing: Capture Imaging Plugin";

; 03a - Install Document Pipeline
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\modules\dp_base-16.2.0.msi"" INSTALLDIR=""C:\OpenText\dp\base"" INSTALLCONFIGDIR=""C:\OpenText\dp\base\""  LOGDIR=""C:\OpenText\var\log\"" VARDIR=""C:\OpenText\var\"" DPDIR=""C:\OpenText\DPDIR\"" EXTDIR=""C:\OpenText\var\dp\extdir\"" DSHOST="""" DSPORT="""" LOCALSYSTEM=""1"" /qn /l ""{#DefaultDirName}\logs\opentext-module-base.log"""; WorkingDir: {tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\modules\; StatusMsg: "(6/32) Installing: dp_base";
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\modules\dp_perl-16.2.0.msi"" INSTALLDIR=""C:\OpenText\dp\perl\"" /qn /l ""{#DefaultDirName}\logs\opentext-module-perl.log"""; WorkingDir: {tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\modules\;  StatusMsg: "(7/32) Installing: dp_perl";
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\modules\dp_info-16.2.0.msi"" INSTALLDIR=""C:\OpenText\dp\info\"" /qn /l ""{#DefaultDirName}\logs\opentext-module-info.log"""; WorkingDir: {tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\modules\;  StatusMsg: "(8/32) Installing: dp_info";
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\modules\DT_OCR_16.2.0.msi"" INSTALLDIR=""C:\OpenText\dp\ocr\"" /qn /l ""{#DefaultDirName}\logs\opentext-module-ocr.log"""; WorkingDir: {tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\modules\;  StatusMsg: "(9/32) Installing: DT_OCR";

; 03b - Configure Document Pipeline
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\40dt_cpfile.servtab"" ""C:\OpenText\dp\base\config\servtab\NA\40dt_cpfile.servtab"""; Flags: runhidden; StatusMsg: "(10/32) Move file: 40dt_cpfile.servtab";
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\40dt_doctods.servtab"" ""C:\OpenText\dp\base\config\servtab\NA\40dt_doctods.servtab"""; Flags: runhidden; StatusMsg: "(11/32) Move file: 40dt_doctods.servtab";
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\40dt_chkpout.servtab"" ""C:\OpenText\dp\base\config\servtab\NA\40dt_chkpout.servtab"""; Flags: runhidden; StatusMsg: "(12/32) Move file: 40dt_chkpout.servta";
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\40dt_page_idx.servtab"" ""C:\OpenText\dp\base\config\servtab\NA\40dt_page_idx.servtab"""; Flags: runhidden; StatusMsg: "(13/32) Move file: 40dt_page_idx.servtab";
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\40dt_prepdoc.servtab"" ""C:\OpenText\dp\base\config\servtab\NA\40dt_prepdoc.servtab"""; Flags: runhidden; StatusMsg: "(14/32) Move file: 40dt_prepdoc.servtab";
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\440dt_rendition.servtab"" ""C:\OpenText\dp\base\config\servtab\NA\40dt_rendition.servtab"""; Flags: runhidden; StatusMsg: "(15/32) Move file: 40dt_rendition.servtab";
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\40dt_tiff2mtiff.servtab"" ""C:\OpenText\dp\base\config\servtab\NA\40dt_tiff2mtiff.servtab"""; Flags: runhidden; StatusMsg: "(16/32) Move file: 40dt_tiff2mtiff.servtab";
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\40dt_timestampdt.servtab"" ""C:\OpenText\dp\base\config\servtab\NA\40dt_timestampdt.servtab"""; Flags: runhidden; StatusMsg: "(17/32) Move file: 40dt_timestampdt.servtab";
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\40dt_xsl_parser.servtab"" ""C:\OpenText\dp\base\config\servtab\NA\40dt_xsl_parser.servtab"""; Flags: runhidden; StatusMsg: "(18/32) Move file: 40dt_xsl_parser.servtab";
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\70dt_docrmext.servtab"" ""C:\OpenText\dp\base\config\servtab\NA\70dt_docrmext.servtab"""; Flags: runhidden; StatusMsg: "(19/32) Move file: 70dt_docrmext.servtab";
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\40dt_ocr.servtab.bak"" ""C:\OpenText\dp\base\config\servtab\NA\40dt_ocr.servtab.bak"""; Flags: runhidden; StatusMsg: "(20/32) Move file: 40dt_ocr.servtab.bak";
Filename: "{tmp}\SAPVIM-INSTALL\mv.exe"; Parameters: "-f ""C:\OpenText\dp\base\config\servtab\40dt_rendition.servtab"" ""C:\OpenText\dp\base\config\servtab\NA\40dt_rendition.servtab"""; Flags: runhidden; StatusMsg: "(21/32) Move file: 40dt_rendition.servtab";

Filename: "{tmp}\SAPVIM-INSTALL\cp.exe"; Parameters: "-f ""{tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\configuration\plainFileExport.dpconfig"" ""C:\OpenText\dp\base\config\dpconfig\plainFileExport.dpconfig"""; Flags: runhidden; StatusMsg: "(22/32) Copy file: plainFileExport.dpconfig";
Filename: "{tmp}\SAPVIM-INSTALL\cp.exe"; Parameters: "-f ""{tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\configuration\plainFileExport.dpinfo"" ""C:\OpenText\dp\base\config\dpconfig\plainFileExport.dpinfo"""; Flags: runhidden; StatusMsg: "23/32) Copy file: plainFileExport.dpinfo";
Filename: "{tmp}\SAPVIM-INSTALL\cp.exe"; Parameters: "-f ""{tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\configuration\50dt_export2file.servtab"" ""C:\OpenText\dp\base\config\servtab\50dt_export2file.servtab"""; Flags: runhidden; StatusMsg: "24/32) Copy file: 50dt_export2file.servtab";
Filename: "{tmp}\SAPVIM-INSTALL\cp.exe"; Parameters: "-f ""{tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\configuration\export2FileDt.pl"" ""C:\OpenText\dp\base\scripts\perl\export2FileDt.pl"""; Flags: runhidden; StatusMsg: "25/32) Copy file: export2FileDt.pl";
Filename: "{tmp}\SAPVIM-INSTALL\cp.exe"; Parameters: "-f ""{tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\configuration\root_path_mappings.txt"" ""C:\OpenText\dp\base\config\setup\root_path_mappings.txt"""; Flags: runhidden; StatusMsg: "26/32) Copy file: root_path_mappings.txt";
Filename: "{tmp}\SAPVIM-INSTALL\cp.exe"; Parameters: "-f ""{tmp}\SAPVIM-INSTALL\unpack\03_Document_pipeline\configuration\COMMON.Setup"" ""C:\OpenText\dp\base\config\setup\COMMON.Setup"""; Flags: runhidden; StatusMsg: "27/32) Copy file: COMMON.Setup";


; 04 - Install Validation Client
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\SAPVIM-INSTALL\unpack\04_Validation_client\Validation for SAP Solutions CE 24.2.msi"" /qn /l ""{#DefaultDirName}\logs\opentext-validclient.log"""; StatusMsg: "28/32) Installing: Validation Client for SAP";
;Filename: "{tmp}\SAPVIM-INSTALL\unpack\04_Validation_client\02-vc204patch05\setup.exe"; Parameters: "/Q";  WorkingDir: {tmp}\SAPVIM-INSTALL\unpack\04_Validation_client\02-vc204patch05\; StatusMsg: "29/32) Installing: Validation Client Patch";


; 05 - Install Enterprise Scan CZ Lang
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\SAPVIM-INSTALL\unpack\05_LanguagePacks\enterprise_scan_1640_czech_language.msi"" /qn /l ""{#DefaultDirName}\logs\opentext-validclient-czlang.log"""; StatusMsg: "30/32) Installing: Enterprise Scan CZ Language";
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\SAPVIM-INSTALL\unpack\05_LanguagePacks\enterprise_scan_1640_polish_language.msi"" /qn /l ""{#DefaultDirName}\logs\opentext-validclient-pllang.log"""; StatusMsg: "31/32) Installing: Enterprise Scan PL Language";

; 06 - Copy Enterprise Scan Config
Filename: "{tmp}\SAPVIM-INSTALL\cp.exe"; Parameters: "-f ""{tmp}\SAPVIM-INSTALL\unpack\06_ES_config\ES test + prod.xml"" ""{#DefaultDirName}\ES test + prod.xml"""; Flags: runhidden; StatusMsg: "32/32) Copy: Enterprise Scan xml config file";


// Registry section is moved to Code section
;[Registry]
; Add custom dp path :
;Root: HKLM; Subkey: "SOFTWARE\WOW6432Node\IXOS\IXOS_ARCHIVE\CLIENT_INST_SCAN"; ValueType: dword; ValueName: "CUSTDP"; ValueData: "1"; Flags: uninsdeletevalue;
;Root: HKLM; Subkey: "SOFTWARE\WOW6432Node\IXOS\IXOS_ARCHIVE\CLIENT_INST_SCAN\FEATURES"; ValueType: dword; ValueName: "CUSTDP"; ValueData: "1"; Flags: uninsdeletevalue;

; Workaround for Enterprise Scan (I don't know why, but parameter DP_DIR is ignored)
;Root: HKLM; Subkey: "SOFTWARE\WOW6432Node\IXOS\IXOS_ARCHIVE\Common"; ValueType: string; ValueName: "DPDIR"; ValueData: "C:\OpenText\DPDIR"; Flags: uninsdeletevalue;

[UninstallDelete]
Type: files; Name: "{#DefaultDirName}\Icons\install.ico"
Type: files; Name: "{#DefaultDirName}\Icons\uninstall.ico"
