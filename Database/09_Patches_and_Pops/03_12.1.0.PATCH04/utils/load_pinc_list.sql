INSERT INTO t_ctrl_pinc (tag, type, name, status, table_pk) SELECT NULL tag, NULL type, NULL name, NULL status, NULL table_pk FROM DUAL WHERE 1=0
UNION ALL SELECT '12.1.0.PATCH04', 'PACKAGE', 'ECDP_OBJECTS_CHECK', 'MODIFIED', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'PACKAGE', 'ECDP_SYNCHRONISE', 'MODIFIED', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'PACKAGE', 'ECDP_TRIGGER_UTILS', 'MODIFIED', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'PACKAGE BODY', 'ECBP_DEFERMENT', 'MODIFIED', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'PACKAGE BODY', 'ECDP_DEFERMENT', 'MODIFIED', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'PACKAGE BODY', 'ECDP_GENERATE', 'MODIFIED', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'PACKAGE BODY', 'ECDP_OBJECTS', 'MODIFIED', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'PACKAGE BODY', 'ECDP_OBJECTS_CHECK', 'MODIFIED', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'PACKAGE BODY', 'ECDP_SYNCHRONISE', 'MODIFIED', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'PACKAGE BODY', 'ECDP_TRIGGER_UTILS', 'MODIFIED', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'PACKAGE BODY', 'ECDP_VIEWLAYER', 'MODIFIED', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'TRIGGER', 'AU_DEFERMENT_EVENT', 'NEW', NULL FROM DUAL
UNION ALL SELECT '12.1.0.PATCH04', 'VIEW', 'V_IWEL_DAY_COMBINATION', 'MODIFIED', NULL FROM DUAL
;
