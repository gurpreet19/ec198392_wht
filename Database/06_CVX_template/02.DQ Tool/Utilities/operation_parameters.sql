-- ##################################################################
-- ## Please enter schema properties before running the install.
-- ##################################################################

ACCEPT operation char           PROMPT 'Please enter an operation_name (e.g. MCA):'

ACCEPT database_name char       PROMPT 'please enter the database name (eg. ECCNAEPDEV):'

ACCEPT ec_schema_password       PROMPT 'Please enter the eckernel_&&operation password:'

ACCEPT ec_application_password  PROMPT 'Please enter the energyx_&&operation password:'

--ACCEPT ec_reporting_password    PROMPT 'Please enter the reporting_&&operation password:'

--ACCEPT ec_transfer_password     PROMPT 'Please enter the transfer_&&operation password:'

ACCEPT ts_data                  PROMPT 'Please enter the Data Tablespace (e.g. DATA01_&&operation):'

ACCEPT ts_index                 PROMPT 'Please enter the Index Tablespace (e.g. INDEX02_&&operation):'

--ACCEPT ts_temp                  PROMPT 'Please enter the Temporary Tablespace (e.g. TEMP):'
