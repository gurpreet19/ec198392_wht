LOAD DATA
CHARACTERSET AL32UTF8
APPEND
CONTINUEIF LAST <> ';'
INTO TABLE class_attr_property_cnfg
FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' 
TRAILING NULLCOLS
(class_name,
 attribute_name,
 property_code,
 owner_cntx,
 presentation_cntx,
 property_type,
 property_value char(4000)  NULLIF property_value=BLANKS "REPLACE(:property_value,'<NEWLINE>',chr(10))",
 created_by "user",
 created_date "sysdate")
