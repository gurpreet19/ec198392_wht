-- Grant access to new objects
-- Create missing synonyms.
--
set define on

prompt Grants to ECKERNEL.

@@create_missing_grants.sql

GRANT EXECUTE ON ECDP_CONTEXT TO REPORTING_&operation;

CONNECT energyx_&operation/&ec_energyx_password@&database_name

prompt Sync Synonyms for EnergyX

@@sync_private_synonyms.sql

CONNECT transfer_&operation/&ec_transfer_password@&database_name

prompt Sync Synonyms for Transfer

@@sync_private_synonyms.sql

CONNECT reporting_&operation/&ec_reporting_password@&database_name

prompt Sync Synonyms for Reporting

@@sync_private_synonyms.sql

prompt Back TO EC Main schema

CONNECT eckernel_&operation/&ec_schema_password@&database_name

