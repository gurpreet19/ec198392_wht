LOAD DATA
CHARACTERSET AL32UTF8
APPEND
CONTINUEIF LAST <> ';'
INTO TABLE class_rel_property_cnfg
FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' 
TRAILING NULLCOLS
(from_class_name,
 to_class_name,
 role_name,
 property_code,
 owner_cntx,
 presentation_cntx,
 property_type,
 property_value char(4000) NULLIF property_value=BLANKS,
 created_by "user",
 created_date "sysdate")
