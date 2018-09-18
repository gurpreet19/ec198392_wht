LOAD DATA
CHARACTERSET AL32UTF8
CONTINUEIF LAST <> ';'
INTO TABLE u_class_cnfg
FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' 
TRAILING NULLCOLS
(class_name,
 class_type,
 app_space_cntx,
 time_scope_code,
 owner_class_name,
 db_object_type,
 db_object_name,
 db_object_attribute NULLIF db_object_attribute=BLANKS,
 db_where_condition char(4000) NULLIF db_where_condition=BLANKS,
 db_object_owner "user",
 created_by "user",
 created_date "sysdate")
