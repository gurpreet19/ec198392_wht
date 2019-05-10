-- ##################################################################
-- ## Please enter schema properties before running the install.
-- ##################################################################

-- ## Enter password for the main EC user (eckernel)
-- ## For example: define ec_schema_password='energy'
define ec_schema_password='energy'

-- ## Enter password for the EC application users (energyx,reporting,transfer)
-- ## For example: define ec_application_password='energy'
--define ec_application_password='energy'
define ec_energyx_password='energy'
define ec_transfer_password='energy'
define ec_reporting_password='energy'

-- ## Enter the Database name
-- ## This argument defines the connect string to use.
-- ## For example: define database_name='ec_db.myCompany.world'
define database_name='db.wstci.chevron.eccloud-tieto.com:1521/wstci'
define db_hostname='db.wstci.chevron.eccloud-tieto.com'
define db_port='1521'
define db_service_name='wstci'

-- ## Enter the Operation name
-- ## This will create a user called: "eckernel_<operation>"
-- ## For example: define operation='EC-8_0_0'
define operation='WST'

-- ## Enter name for data table space
-- ## For example: define ts_data='DATA01'
define ts_data='DATA01_WST'

-- ## Enter name for index table space
-- ## For example: define ts_index='INDEX02'
define ts_index='INDEX02_WST'

-- ## Set Oracle edition (Enterprice Edition is required for the upgrade)
-- ## For example: EE
define oracle_edition='EE'

-- ## Give the name of the environment (will be used for the lable) for example Production or Acceptance
define environment='CI'

-- ## Main configuration for the upgrade script
define NLS_LANG='AMERICAN'
define version_from='10.3.SP06_WST'
define version_to='12.1'
define DELTA_FOLDER_NAME='Delta_WST'
define headlesstool='headless-5.2.0'

-- ## Parameters how to run the upgrade script
-- ## Simulate query will only generate the queries but not execute the queries when set to 1 (possible values 1 or 0)
-- ## Delete gen files will delete the generated SQL files once executed when set to 1        (possible values 1 or 0)
-- ## Never stop on error will continue the script even when there are errors when set to 1   (possible values 1 or 0)

define SIMULATE_QUERY='0'
define DELETE_GEN_FILES='0'
define NEVER_STOP_ON_ERROR='1'
define INCL_Patches_and_POPs='0'
define INCL_GlobalTemlate='1'
define Prod_Diff_script='1' 
define INCL_DQ_TOOL='0'
define INCL_HPDI_TOOL='0'
define INCL_RP_PKGS='1'
define INCL_BBO_SCRIPTS='0'
define INCL_Releases='0'
