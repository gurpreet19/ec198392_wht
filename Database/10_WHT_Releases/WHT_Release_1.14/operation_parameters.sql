-- ##################################################################
-- ## Please enter schema properties before running the install.
-- ##################################################################

-- ## Enter password for the main EC user (eckernel)
-- ## For example: define ec_schema_password='energy'
define ec_schema_password='energy'
define kc_schema_password='energy'

-- ## Enter password for the EC application users (energyx,reporting,transfer)
-- ## For example: define ec_application_password='energy'
--define ec_application_password='energy'
define ec_energyx_password='energy'
define ec_transfer_password='energy'
define ec_reporting_password='energy'

-- ## Enter the Database name
-- ## This argument defines the connect string to use.
-- ## For example: define database_name='ec_db.myCompany.world'
define database_name='wstsci.chxjb9iea7ey.us-east-1.rds.amazonaws.com:1521/wstsci'					  
define db_hostname='wstsci.chxjb9iea7ey.us-east-1.rds.amazonaws.com'
define db_port='1521'
define db_service_name='wstsci'

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

