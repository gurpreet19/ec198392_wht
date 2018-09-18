LOAD DATA
CHARACTERSET AL32UTF8
CONTINUEIF LAST <> ';'
INTO TABLE u_class_attribute_cnfg
FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' 
TRAILING NULLCOLS
(class_name,
 attribute_name,
 app_space_cntx  "NVL(:app_space_cntx,'NULL')" ,
 is_key,
 data_type,
 db_mapping_type,
 db_sql_syntax char(4000) NULLIF db_sql_syntax=BLANKS,
 created_by "user",
 created_date "sysdate")
