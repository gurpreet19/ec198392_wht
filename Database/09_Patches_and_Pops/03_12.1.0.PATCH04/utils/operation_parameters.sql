/*

A] ACCEPT OPERATION PARAMETERS FROM USER:

	To accept operation parameters such as operation, ec_schema_password, ec_application_password, ec_reporting_password, ec_transfer_password, database_name, ts_data, ts_index, etc. from user. Use below six ACCEPT statements:

	ACCEPT operation PROMPT 'Enter value for operation:'
	ACCEPT ec_schema_password PROMPT 'Enter value for ec_schema_password:' HIDE
	ACCEPT ec_application_password PROMPT 'Enter value for ec_application_password:' HIDE
	ACCEPT ec_reporting_password PROMPT 'Enter value for ec_reporting_password:' HIDE
	ACCEPT ec_transfer_password PROMPT 'Enter value for ec_transfer_password:' HIDE
	ACCEPT database_name PROMPT 'Enter value for database_connect_string:'
	ACCEPT ts_data PROMPT 'Enter value for ts_data:'
	ACCEPT ts_index PROMPT 'Enter value for ts_index:'


B] ACCEPT OPERATION PARAMETERS FROM ecdb.properties FILE:

	To fetch operation parameters such as operation, ec_schema_password, ec_application_password, ec_reporting_password, ec_transfer_password, database_name, ts_data, ts_index, etc. from ecdb.properties file:

		1) ecdb.properties file should have below parameters defined:

			define operation=$OPERATION$
			define ec_schema_password=$EC_SCHEMA_PASSWORD$
			define ec_application_password=$EC_APPLICATION_PASSWORD$
			define ec_reporting_password=$EC_REPORTING_PASSWORD$
			define ec_transfer_password=$EC_TRANSFER_PASSWORD$
			define database_name=$DATABASE_NAME$
			define ts_data=$TS_DATA$
			define ts_index=$TS_INDEX$

			For example:

			define operation=EC
			define ec_schema_password=energy
			define ec_application_password=energy
			define ec_reporting_password=energy
			define ec_transfer_password=energy			
			define database_name=localhost:1521/ORCL
			define ts_data=USERS
			define ts_index=USERS

		2) Add 'START &1' command to accept path of ecdb.properties and remove all six ACCEPT statements from this file.

			START &1

		3) And provide path of ecdb.properties while calling upgrade.sql or install-patch.sql.

			SQL> @upgrade.sql $PATH_OF_ecdb.properties_FILE$

			SQL> @install-patch.sql $PATH_OF_ecdb.properties_FILE$

			For example:

			SQL> @upgrade.sql ecdb.properties

			SQL> @install-patch.sql ecdb.properties

*/

ACCEPT operation PROMPT 'Enter value for operation:'
ACCEPT ec_schema_password PROMPT 'Enter value for ec_schema_password:' HIDE
ACCEPT ec_application_password PROMPT 'Enter value for ec_application_password:' HIDE
ACCEPT ec_reporting_password PROMPT 'Enter value for ec_reporting_password:' HIDE
ACCEPT ec_transfer_password PROMPT 'Enter value for ec_transfer_password:' HIDE
ACCEPT database_name PROMPT 'Enter value for database_connect_string:'
ACCEPT ts_data PROMPT 'Enter value for ts_data:'
ACCEPT ts_index PROMPT 'Enter value for ts_index:'
