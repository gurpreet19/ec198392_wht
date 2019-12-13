UPDATE CLASS_ATTR_PROPERTY_CNFG set PROPERTY_VALUE='false' where class_name ='TANK_DAY_INV_OIL' and attribute_name ='CALC_CLOSING_OIL_VOL' and PROPERTY_CODE='viewhidden' and OWNER_CNTX=2500;

DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' and ATTRIBUTE_NAME='OPENING_GRS_VOL' AND PROPERTY_CODE='viewlabelhead' AND OWNER_CNTX=2500;
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' and ATTRIBUTE_NAME='OPENING_GRS_VOL' AND PROPERTY_CODE='SCREEN_SORT_ORDER' AND OWNER_CNTX=2500;
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' and ATTRIBUTE_NAME='CALC_CLOSING_OIL_VOL' AND PROPERTY_CODE='SCREEN_SORT_ORDER' AND OWNER_CNTX=2500;
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' and ATTRIBUTE_NAME='CLOSING_GRS_VOL' AND PROPERTY_CODE='SCREEN_SORT_ORDER' AND OWNER_CNTX=2500;
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' and ATTRIBUTE_NAME='CLOSING_GRS_VOL' AND PROPERTY_CODE='viewlabelhead' AND OWNER_CNTX=2500;
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' and ATTRIBUTE_NAME='OPENING_GRS_MASS' AND PROPERTY_CODE='viewlabelhead' AND OWNER_CNTX=2500;
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' and ATTRIBUTE_NAME='OPENING_GRS_MASS' AND PROPERTY_CODE='SCREEN_SORT_ORDER' AND OWNER_CNTX=2500;
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' and ATTRIBUTE_NAME='CLOSING_GRS_MASS' AND PROPERTY_CODE='SCREEN_SORT_ORDER' AND OWNER_CNTX=2500;
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' and ATTRIBUTE_NAME='CLOSING_GRS_MASS' AND PROPERTY_CODE='viewlabelhead' AND OWNER_CNTX=2500;




INSERT INTO class_attr_property_cnfg(CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE ) VALUES( 'TANK_DAY_INV_OIL', 'CALC_DENSITY','viewhidden',2500,'/EC', 'STATIC_PRESENTATION', 'true');

INSERT INTO class_attr_property_cnfg(CLASS_NAME,ATTRIBUTE_NAME, PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE  )VALUES('TANK_DAY_INV_OIL','DIP_LEVEL','viewhidden',2500, '/EC','STATIC_PRESENTATION','true');

INSERT INTO class_attr_property_cnfg(CLASS_NAME,ATTRIBUTE_NAME, PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE  )VALUES('TANK_DAY_INV_OIL','DIP_UOM','viewhidden',2500, '/EC','STATIC_PRESENTATION','true');


INSERT INTO class_attr_property_cnfg(CLASS_NAME,ATTRIBUTE_NAME, PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE  )VALUES('TANK_DAY_INV_OIL','BSW_VOL','viewhidden',2500, '/EC','STATIC_PRESENTATION','true');

INSERT INTO class_attr_property_cnfg(CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE ) VALUES( 'TANK_DAY_INV_OIL', 'CALC_CLOSING_OIL_VOL','SCREEN_SORT_ORDER',2500,'/EC', 'STATIC_PRESENTATION', 620);


Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN( 'TANK_DAY_INV_OIL');
commit;
exec ecdp_viewlayer.BuildViewLayer(p_class_name => 'TANK_DAY_INV_OIL',p_force => 'Y');

exec  EcDp_Viewlayer.BuildReportLayer(p_class_name => 'TANK_DAY_INV_OIL',p_force => 'Y');

commit;



