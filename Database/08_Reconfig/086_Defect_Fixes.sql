--UPGCVX-1816
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'PWEL_PERIOD_STATUS','FUTURE_UTILITY','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','340' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'PWEL_PERIOD_LAST_STATUS','FUTURE_UTILITY','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','340' from dual;

UPDATE TV_EC_CODES SET IS_ACTIVE='N' WHERE CODE_TYPE='WELL_STATUS' AND CODE='PLANNED';

--UPDATE T_BASIS_OBJECT SET OBJECT_NAME='/com.ec.wheatstone.screens/sale_calc_day' WHERE OBJECT_NAME='/com.ec.sale.sa.screens/sale_calc_day' ;
Update tv_ctrl_tv_presentation SET  COmponent_EXT_NAME = '/com.ec.sale.sa.screens/sale_calc_day' where COmponent_LABEL like 'Daily Contract Calculation' and COmponent_ID = 'SA0001_SALE_CALC_DAY'; 

--UPGCVX-1821
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_FINDER_OBJECTS' AND ATTRIBUTE_NAME='DAYTIME' AND PROPERTY_CODE='viewhidden' AND PROPERTY_VALUE='true';
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_FINDER_OBJECTS' AND ATTRIBUTE_NAME='END_DATE' AND PROPERTY_CODE='viewhidden' AND PROPERTY_VALUE='true';
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'TANK_FINDER_OBJECTS','OBJECT_END_DATE','LABEL',2500,'/EC','APPLICATION','Object End Date' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'TANK_FINDER_OBJECTS','DAYTIME','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','100' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'TANK_FINDER_OBJECTS','END_DATE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','200' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'TANK_FINDER_OBJECTS','CODE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','400' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'TANK_FINDER_OBJECTS','NAME','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','500' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'TANK_FINDER_OBJECTS','OBJECT_START_DATE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','600' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'TANK_FINDER_OBJECTS','OBJECT_END_DATE','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','700' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'TANK_FINDER_OBJECTS','END_DATE','vieweditable',2500,'/EC','STATIC_PRESENTATION','true' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'TANK_FINDER_OBJECTS','DAYTIME','vieweditable',2500,'/EC','STATIC_PRESENTATION','true' from dual;

--UPGCVX-1822
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'STORAGE_LIFT_NOM_INFO','START_LIFTING_DATE','DISABLED_IND',2500,'/','VIEWLAYER','N' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'STORAGE_LIFT_NOM_INFO','START_LIFTING_DATE','IS_MANDATORY',2500,'/','VIEWLAYER','Y' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'STORAGE_LIFT_NOM_INFO','START_LIFTING_DATE','LABEL',2500,'/EC','APPLICATION','Loading Start Time' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'STORAGE_LIFT_NOM_INFO','START_LIFTING_DATE','vieweditable',2500,'/EC','STATIC_PRESENTATION','false' from dual;

--UPGCVX-1818
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'EQPM_DAY_STATUS','AVG_PRESS','UOM_CODE',2500,'/','VIEWLAYER','' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)select 'EQPM_DAY_STATUS','AVG_TEMP','UOM_CODE',2500,'/','VIEWLAYER','' from dual;

--UPGCVX-1820

DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='STORAGE_LIFT_NOMINATION' AND ATTRIBUTE_NAME='PROFIT_CENTRE_NAME' AND PROPERTY_CODE='viewhidden' AND OWNER_CNTX=2500 AND PROPERTY_VALUE='true';
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE  CLASS_NAME='STORAGE_LIFT_NOMINATION' AND ATTRIBUTE_NAME='PROFIT_CENTRE_NAME' AND PROPERTY_CODE='REPORT_ONLY_IND' AND OWNER_CNTX=2500 AND PROPERTY_VALUE='Y';

UPDATE CLASS_ATTR_PROPERTY_CNFG SET PROPERTY_VALUE=550 WHERE CLASS_NAME='STORAGE_LIFT_NOMINATION' AND ATTRIBUTE_NAME='PROFIT_CENTRE_NAME' AND PROPERTY_CODE='SCREEN_SORT_ORDER' AND OWNER_CNTX=2500 AND PROPERTY_VALUE='4150';

