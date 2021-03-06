INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('STOR_DAY_DIP_STATUS', 'DAYTIME', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION', 'true');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('STOR_DAY_DIP_STATUS', 'CLOSE_GRS_MASS', 'DISABLED_IND', 2500, '/', 'VIEWLAYER', 'N');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('STOR_DAY_DIP_STATUS', 'CLOSE_NET_MASS', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION', 'true');


UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('STOR_DAY_DIP_STATUS');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('STOR_DAY_DIP_STATUS') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('STOR_DAY_DIP_STATUS');

INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('TANK_DAY_INV_OIL', 'OPENING_GRS_VOL', 'viewlabelhead', 2500, '/EC', 'STATIC_PRESENTATION', '');
INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('TANK_DAY_INV_OIL', 'CLOSING_GRS_VOL', 'viewlabelhead', 2500, '/EC', 'STATIC_PRESENTATION', '');
INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('TANK_DAY_INV_OIL', 'OPENING_GRS_MASS', 'viewlabelhead', 2500, '/EC', 'STATIC_PRESENTATION', '');
INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('TANK_DAY_INV_OIL', 'CLOSING_GRS_MASS', 'viewlabelhead', 2500, '/EC', 'STATIC_PRESENTATION', '');
INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('TANK_DAY_INV_OIL', 'AVG_PRESS', 'viewlabelhead', 2500, '/EC', 'STATIC_PRESENTATION', '');
INSERT INTO CLASS_ATTR_PROPERTY_CNFG(CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES('TANK_DAY_INV_OIL', 'AVG_TEMP', 'viewlabelhead', 2500, '/EC', 'STATIC_PRESENTATION', '');

UPDATE CLASS_ATTR_PROPERTY_CNFG set PROPERTY_VALUE=450 where class_name ='TANK_DAY_INV_OIL' and attribute_name ='OPENING_GRS_MASS' and PROPERTY_CODE='SCREEN_SORT_ORDER'  and OWNER_CNTX=2500;

UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('TANK_DAY_INV_OIL');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('TANK_DAY_INV_OIL') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('TANK_DAY_INV_OIL');

