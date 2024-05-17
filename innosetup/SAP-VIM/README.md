# All in one installer couple of packages
This is all-in-one installer many of packages and configuration. \
It's for speed up installation and configuration process for new client stations (PC/NTB). \
Installer reduces install steps from cca 75 to 10 and allow remote silent install / deploy. \
This installer just install many packages and configuration, but doesn't contains uninstalation procedures. So, you have to go to install programs (Windows -> control panel -> ...) and uinstall each of packages.

### Directory structure should be:
* VIM-Installer
  * icons
  * Output
    * SAPVIM-Installer-1.0.9.exe
  * sources
    * 00_requirments
      * Runtimes
      * ndp48-x86-x64-allos-enu.exe
    * 01_SAP_connector
      * sapnco31P_4-70002626
        * SapNCox86Setup.exe
    * 02_Entreprise_scan
      * 01-OT-SCAN-1640
        * Data1.cab
        * Enterprise Scan 16.4.0.msi
      * 02-OT-SCAN-1640-patch
        * esc-1640-005.msp
      * 03-Imaging_plugin
        * Capture Imaging Plugin 16.6.10.msi
    * 03_Document_pipeline
      * configuration
      * modules
      * export.js
    * 04_Validation_client
      * Validation for SAP Solutions CE 24.2.msi
    * 05_LanguagePacks
      * enterprise_scan_1640_czech_language.msi
      * enterprise_scan_1640_polish_language.msi
    * 06_ES_config
      * ES test + prod.xml
    * cp.exe
    * modpath.exe
    * mv.exe
    * source.zip
    * unzip.exe
 * SAP-VIM-Installer.iss

### Explain
Output = Final install package \
source = all content is inside source.zip file \
SAPVIM-Installer-x.x.x.exe contains "source.zip" and all exe utilities.  \

Most of all packages have enabled installation logs, so all this logs are in this directory \
C:\company_sap\logs

For more info see installer script.

 
