LOAD DATA
CHARACTERSET AL32UTF8
CONTINUEIF LAST <> ';'
INTO TABLE u_class_trigger_actn_cnfg
FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' 
TRAILING NULLCOLS
(class_name,
 triggering_event,
 trigger_type,
 sort_order,
 db_sql_syntax char(4000) NULLIF db_sql_syntax=BLANKS,
 app_space_cntx,
 created_by "user",
 created_date "sysdate")
 
 
 

