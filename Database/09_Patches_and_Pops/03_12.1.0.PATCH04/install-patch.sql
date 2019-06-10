define EC_RELEASE_VERSION='12.1.0.PATCH04'
define EC_RELEASE_DATE='17.05.2019'
define file_ext=.log

SPOOL upgrade-&EC_RELEASE_VERSION&file_ext
REM ======================================
REM ======== Energy Components ===========
REM ======================================
REM ======= D O  N O T  E D I T ==========
REM ======= (C) Tieto Norway AS ==========
REM ======================================
PROMPT **** ***************************** **** 
PROMPT **** Energy Component DB install script. 
PROMPT ****      (C) Tieto Norway AS 
PROMPT **** Release: 12.1.0.PATCH04
PROMPT **** SQLPlus: &_SQLPLUS_RELEASE 
PROMPT **** ***************************** **** 
PROMPT 
WHENEVER OSERROR EXIT -1
WHENEVER SQLERROR EXIT SQL.SQLCODE
TIMING START EnergyComponent_Total_Install_Time 
SET PAGESIZE 0
SET LINESIZE 999
SET HEADING OFF
SET VERIFY OFF
SET FEEDBACK ON
SET TRIMSPOOL ON
SET ECHO OFF
SET TIMING ON
PROMPT 
PROMPT ==================================

START &1

connect eckernel_&operation/&ec_schema_password@&database_name


EXECUTE ecdp_pinc.enableInstallMode('&EC_RELEASE_VERSION')

UPDATE T_PREFERANSE SET PREF_VERDI='&EC_RELEASE_VERSION' WHERE PREF_ID='INITAL_REL_TAG';
UPDATE T_PREFERANSE SET PREF_VERDI='&EC_RELEASE_DATE' WHERE PREF_ID='INITAL_REL_DATE';
UPDATE CTRL_DB_VERSION set DESCRIPTION='&EC_RELEASE_VERSION';
commit;

PROMPT [SYNC ASSIGN_ID_TABLE]
@utils\sync_assign_id.sql

PROMPT [UPDATING DATA MODEL]
@datamodel\upgrade-datamodel.sql

--Recompile invalid objects
PROMPT [RECOMPILE INVALID OBJECTS]
exec ecdp_dynsql.RecompileInvalid

PROMPT [UPDATING CLASS DATA]
@utils\disable_cons.sql CLASS
@class\upgrade-classes.sql
@utils\enable_cons.sql CLASS
COMMIT;

PROMPT [UPGRADING PACKAGES, VIEWS, TRIGGERS]
@source\packages.sql
@source\views.sql
@source\triggers.sql

PROMPT [UPDATING VIEWLAYER DIRTYLOG]
@config\update_viewlayer_dirtylog.sql

PROMPT [BUILD VIEW AND REPORT LAYER]
@utils\build_view_report.sql

PROMPT [RE-GENERATE ALL EC TABLE PACKAGES AND AUT TRIGGERS]
@datamodel\2019042301FRMW\ECPD-66394_regenerate_table_packages_and_aut_triggers.sql

PROMPT [POST UPGRADE SCRIPT]
@datamodel\2019040801FRMW\ECPD66350_upgrade_script.sql

PROMPT [ECDP_SYNCHRONISE.SYNCHRONISE]
execute ecdp_synchronise.Synchronise();

--Recompile invalid objects
PROMPT [RECOMPILE INVALID OBJECTS]
@utils\invalid.sql

PROMPT [GRANTING ACCESS]
@utils\create_missing_grants.sql

EXECUTE ecdp_pinc.disableInstallMode

disc

connect energyx_&operation/&ec_application_password@&database_name

PROMPT [SYNC SYNONYMS FOR_ENERGYX_USER]
@utils\sync_private_synonyms.sql
@utils\recompile_synonyms.sql

disc

connect reporting_&operation/&ec_reporting_password@&database_name
PROMPT [SYNC SYNONYMS FOR_REPORTING_USER]
@utils\sync_private_synonyms.sql
@utils\recompile_synonyms.sql

disc

connect transfer_&operation/&ec_transfer_password@&database_name
PROMPT [SYNC SYNONYMS FOR_TRANSFER_USER]
@utils\sync_private_synonyms.sql
@utils\recompile_synonyms.sql

disc

TIMING SHOW 

TIMING STOP EnergyComponent_Total_Install_Time

SPOOL OFF

exit