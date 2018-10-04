CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CLASS_VAL" ("VAL_TYPE", "ATTRIBUTE_NAME") AS 
  SELECT 'WARN_MIN' val_type, v.attribute_name FROM CLASS_ATTR_VALIDATION v
WHERE class_name = 'PWEL_SUB_DAY_STATUS'
AND (WARN_MIN IS NOT NULL)
UNION ALL
SELECT 'WARN_MAX' val_type, v.attribute_name FROM CLASS_ATTR_VALIDATION v
WHERE class_name = 'PWEL_SUB_DAY_STATUS'
AND (WARN_MAX IS NOT NULL)
UNION ALL
SELECT 'WARN_PCT' val_type, v.attribute_name FROM CLASS_ATTR_VALIDATION v
WHERE class_name = 'PWEL_SUB_DAY_STATUS'
AND WARN_PCT IS NOT NULL
UNION ALL
SELECT 'ERR_MIN' val_type, v.attribute_name FROM CLASS_ATTR_VALIDATION v
WHERE class_name = 'PWEL_SUB_DAY_STATUS'
AND (ERR_MIN IS NOT NULL)
UNION ALL
SELECT 'ERR_MAX' val_type, v.attribute_name FROM CLASS_ATTR_VALIDATION v
WHERE class_name = 'PWEL_SUB_DAY_STATUS'
AND (ERR_MAX IS NOT NULL)