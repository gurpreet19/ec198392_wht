LOAD DATA
CHARACTERSET AL32UTF8
CONTINUEIF LAST <> ';'
INTO TABLE u_class_relation_cnfg
FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' 
TRAILING NULLCOLS
(from_class_name,
 to_class_name,
 role_name,
 app_space_cntx,
 is_key,
 is_bidirectional,
 group_type,
 multiplicity,
 db_mapping_type,
 db_sql_syntax char(4000) NULLIF db_sql_syntax=BLANKS,
 reverse_approval_ind,
 approval_ind,
 created_by "user",
 created_date "sysdate")
