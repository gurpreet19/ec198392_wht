LOAD DATA
CHARACTERSET AL32UTF8
CONTINUEIF LAST <> ';'
INTO TABLE class_tra_property_cnfg
FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' 
TRAILING NULLCOLS
(class_name,
 triggering_event,
 trigger_type,
 sort_order,
 property_code,
 owner_cntx,
 property_type,
 property_value char(4000) NULLIF property_value=BLANKS,
 created_by "user",
 created_date "sysdate")
