connect energyx_&operation/&ec_energyx_password@&database_name
execute dbms_utility.compile_schema(user,false);

connect transfer_&operation/&ec_transfer_password@&database_name
execute dbms_utility.compile_schema(user,false);

connect reporting_&operation/&ec_reporting_password@&database_name
execute dbms_utility.compile_schema(user,false);

connect eckernel_&operation/&ec_schema_password@&database_name