CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_VAL" ("PRECEDENCE", "VAL_CAT", "VAL_TYPE", "OBJECT_ID", "ATTRIBUTE_NAME", "WARN_MIN", "WARN_MAX", "WARN_PCT", "ERR_MIN", "ERR_MAX") AS 
  SELECT 10 precedence, 'W' val_cat, 'WARN' val_type, v.object_id, v.attribute_name, to_char(v.WARN_MIN) WARN_MIN, to_char(v.WARN_MAX) WARN_MAX, NULL WARN_PCT, NULL err_min, NULL err_max from OBJECT_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (WARN_MIN IS NOT NULL AND WARN_MAX IS NOT NULL)
UNION ALL
SELECT 30 precedence, 'W' val_cat, 'WARN_MIN' val_type, v.object_id, v.attribute_name, to_char(v.WARN_MIN) WARN_MIN, NULL WARN_MAX, NULL WARN_PCT, NULL err_min, NULL err_max from OBJECT_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (WARN_MIN IS NOT NULL AND WARN_MAX IS NULL)
UNION ALL
SELECT 30 precedence, 'W' val_cat, 'WARN_MAX' val_type, v.object_id, v.attribute_name, NULL WARN_MIN, to_char(v.WARN_MAX) WARN_MAX, NULL WARN_PCT, NULL err_min, NULL err_max from OBJECT_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (WARN_MIN IS NULL AND WARN_MAX IS NOT NULL)
UNION ALL
SELECT 5 precedence, 'W' val_cat, 'WARN_PCT' val_type, v.object_id, v.attribute_name, NULL WARN_MIN, NULL WARN_MAX, to_char(v.WARN_PCT), NULL ERR_MIN, NULL ERR_MAX from OBJECT_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND WARN_PCT IS NOT NULL
UNION ALL
SELECT 10 precedence, 'E' val_cat, 'ERR' val_type, v.object_id, v.attribute_name, NULL WARN_MIN, NULL WARN_MAX, NULL WARN_PCT, to_char(v.ERR_MIN) ERR_MIN, to_char(v.ERR_MAX) ERR_MAX from OBJECT_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (ERR_MIN IS NOT NULL AND ERR_MAX IS NOT NULL)
UNION ALL
SELECT 30 precedence, 'E' val_cat, 'ERR_MIN' val_type, v.object_id, v.attribute_name, NULL WARN_MIN, NULL WARN_MAX, NULL WARN_PCT, to_char(v.ERR_MIN) ERR_MIN, NULL ERR_MAX from OBJECT_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (ERR_MIN IS NOT NULL AND ERR_MAX IS NULL)
UNION ALL
SELECT 30 precedence, 'E' val_cat, 'ERR_MAX' val_type, v.object_id, v.attribute_name, NULL WARN_MIN, NULL WARN_MAX, NULL WARN_PCT, NULL err_min, to_char(v.err_max) err_max from OBJECT_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (ERR_MIN IS NULL AND ERR_MAX IS NOT NULL)
UNION ALL
SELECT 23 precedence, 'W' val_cat, 'WARN' val_type, null, v.attribute_name, to_char(v.WARN_MIN) WARN_MIN, to_char(v.WARN_MAX) WARN_MAX, NULL WARN_PCT, NULL err_min, NULL err_max from CLASS_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (WARN_MIN IS NOT NULL AND WARN_MAX IS NOT NULL)
UNION ALL
SELECT 25 precedence, 'W' val_cat, 'WARN_MIN' val_type, null, v.attribute_name, to_char(v.WARN_MIN) WARN_MIN, NULL WARN_MAX, NULL WARN_PCT, NULL err_min, NULL err_max from CLASS_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (WARN_MIN IS NOT NULL AND WARN_MAX IS NULL)
UNION ALL
SELECT 25 precedence, 'W' val_cat, 'WARN_MAX' val_type, null, v.attribute_name, NULL WARN_MIN, to_char(v.WARN_MAX) WARN_MAX, NULL WARN_PCT, NULL err_min, NULL err_max from CLASS_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (WARN_MIN IS NULL AND WARN_MAX IS NOT NULL)
UNION ALL
SELECT 20 precedence, 'W' val_cat, 'WARN_PCT' val_type, null, v.attribute_name, NULL WARN_MIN, NULL WARN_MAX, to_char(v.WARN_PCT), NULL ERR_MIN, NULL ERR_MAX from CLASS_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND WARN_PCT IS NOT NULL
UNION ALL
SELECT 23 precedence, 'E' val_cat, 'ERR' val_type, null, v.attribute_name, NULL WARN_MIN, NULL WARN_MAX, NULL WARN_PCT, to_char(v.ERR_MIN) ERR_MIN, to_char(v.ERR_MAX) ERR_MAX from CLASS_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (ERR_MIN IS NOT NULL AND ERR_MAX IS NOT NULL)
UNION ALL
SELECT 25 precedence, 'E' val_cat, 'ERR_MIN' val_type, null, v.attribute_name, NULL WARN_MIN, NULL WARN_MAX, NULL WARN_PCT, to_char(v.ERR_MIN) ERR_MIN, NULL ERR_MAX from CLASS_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (ERR_MIN IS NOT NULL AND ERR_MAX IS NULL)
UNION ALL
SELECT 25 precedence, 'E' val_cat, 'ERR_MAX' val_type, null, v.attribute_name, NULL WARN_MIN, NULL WARN_MAX, NULL WARN_PCT, NULL err_min, to_char(v.err_max) err_max from CLASS_ATTR_VALIDATION v
    WHERE class_name = 'PWEL_SUB_DAY_STATUS'
    AND (ERR_MIN IS NULL AND ERR_MAX IS NOT NULL)