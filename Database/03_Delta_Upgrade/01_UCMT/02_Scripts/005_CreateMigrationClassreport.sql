set hea off
set lines 999
set pages 999
set echo off
spool logging/MigrationClassreport.html

select text 
from   t_temptext 
where  id = 'UPGRADE_CLASS_COMPARE'
order by line_number;

spool off

Prompt Please check logging/MigrationClassreport.html for Class migration statistics. 
--Prompt Next step is to export the class config
--Prompt with ../sql-loader-data/create_EC_class_csv/export_sqlloader_file.sql




