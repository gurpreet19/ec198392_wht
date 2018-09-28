LOAD DATA
CHARACTERSET AL32UTF8
CONTINUEIF LAST <> ';'
INTO TABLE class_attribute_cnfg
FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' 
TRAILING NULLCOLS
(class_name,
 attribute_name,
 app_space_cntx,
 is_key,
 data_type,
 db_mapping_type,
 db_sql_syntax char(4000) NULLIF db_sql_syntax=BLANKS,
 db_join_table,
 db_join_where char(4000) NULLIF db_join_where=BLANKS,
 REFERENCE_KEY,
 REFERENCE_TYPE,
 REFERENCE_VALUE,
 created_by "user",
 created_date "sysdate")
