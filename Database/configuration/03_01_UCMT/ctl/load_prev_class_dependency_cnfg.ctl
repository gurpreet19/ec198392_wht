LOAD DATA
CHARACTERSET AL32UTF8
CONTINUEIF LAST <> ';'
INTO TABLE u_class_dependency_cnfg
FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' 
TRAILING NULLCOLS
(parent_class,
 child_class,
 dependency_type,
 app_space_cntx,
 created_by "user",
 created_date "sysdate")
