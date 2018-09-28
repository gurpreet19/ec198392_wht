-- ##################################################################
-- ## Please enter schema properties before running the install.
-- ##################################################################

-- ## Enter password for the main EC user (eckernel)
-- ## Ex: define ec_schema_password='energy'
define ec_schema_password='energy'

-- ## Enter password for the EC application users (energyx)
-- ## Ex: define ec_application_password='energy'
define ec_application_password='energy'

-- ## Enter password for the EC application users (reporting)
-- ## Ex: define ec_reporting_password='energy'
define ec_reporting_password='energy'

-- ## Enter password for the EC application users (transfer)
-- ## Ex: define ec_transfer_password='energy'
define ec_transfer_password='energy'

-- ## Enter the Database name
-- ## This argument defines the connect string to use.
-- ## Ex: define database_name='ec_db.myCompany.world'
define database_name='db.ec12nt.chevron.eccloud-tieto.com/ec12nt'

-- ## Enter the Operation name
-- ## This will create a user called: "eckernel_<operation>"
-- ## Ex: define operation='EC-8_0_0'
define operation='EC12SRC'

-- ## Enter name for data table space
-- ## Ex: define ts_data='DATA01'
define ts_data='DATA01'

-- ## Enter name for index table space
-- ## Ex: define ts_index='INDEX02'
define ts_index='INDEX02'

-- ## Enter name for temporary table space
-- ## Ex: define ts_temp='TEMP'
define ts_temp='TEMP'

-- ## Enter Time Zone
-- ## Ex: define tz_region='CET'
define tz_region='CET'
