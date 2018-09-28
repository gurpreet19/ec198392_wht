------------------------------------------------------------------------------------------------

PROMPT
PROMPT Installing updates completed
PROMPT

PROMPT
PROMPT Creating missing grants
PROMPT
@.\_Release\utilities\create_missing_grants.sql


PROMPT
PROMPT Compiling invalids
PROMPT
@.\_Release\utilities\invalid.sql

PROMPT
PROMPT Total Invalids after running updates
PROMPT
@.\_Release\utilities\invalid_list.sql

disconnect

set define on

PROMPT
PROMPT Connecting to [energyx_&&operation@&&database_name]...
connect energyx_&&operation/"&&ec_application_password"@&&database_name

PROMPT
PROMPT Creating private synonym script for energyx.
PROMPT
@.\_Release\utilities\sync_private_synonyms.sql
disconnect

PROMPT
PROMPT Connecting to [reporting_&&operation@&&database_name]...
connect Reporting_&&operation/"&&ec_reporting_password"@&&database_name

PROMPT
PROMPT Creating private synonym script for reporting.
PROMPT
@.\_Release\utilities\sync_private_synonyms.sql
disconnect

PROMPT
PROMPT Connecting to [Transfer_&&operation@&&database_name]...
connect Transfer_&&operation/"&&ec_transfer_password"@&&database_name

PROMPT
PROMPT Creating private synonym script for transfer.
PROMPT
@.\_Release\utilities\sync_private_synonyms.sql
disconnect

spool off
exit
