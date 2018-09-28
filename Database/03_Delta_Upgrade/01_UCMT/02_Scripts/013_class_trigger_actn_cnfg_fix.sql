--Update db_sql_syntax where there are no spaces behind a comma, to prevent too long lines of code that can't be splitted
update class_trigger_actn_cnfg
set    db_sql_syntax = regexp_replace(db_sql_syntax, ',([^\s])', ', \1', 1, 0, 'i')
where  app_space_cntx not in ('EC_ECDM', 'EC_FRMW', 'EC_PROD', 'EC_REVN', 'EC_SALE', 'EC_TRAN')
and    regexp_like(db_sql_syntax, ',([^\s])', 'i');
