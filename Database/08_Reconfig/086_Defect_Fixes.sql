--UPGCVX-1816
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'PWEL_PERIOD_STATUS','FUTURE_UTILITY','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','340' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'PWEL_PERIOD_LAST_STATUS','FUTURE_UTILITY','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','340' from dual;

UPDATE TV_EC_CODES SET IS_ACTIVE='N' WHERE CODE_TYPE='WELL_STATUS' AND CODE='PLANNED';

--UPGCVX-1819
Update tv_ctrl_tv_presentation SET  COmponent_EXT_NAME = '/com.ec.wheatstone.screens/sale_calc_day'
where COmponent_LABEL like 'Daily Contract Calculation' and COmponent_ID = 'SA0001_SALE_CALC_DAY'; 

--UPGCVX-1820
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='STORAGE_LIFT_NOMINATION' AND ATTRIBUTE_NAME='PROFIT_CENTRE_NAME' AND PROPERTY_CODE='viewhidden' AND OWNER_CNTX=2500 AND PROPERTY_VALUE='true';

--UPGCVX-1821
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_FINDER_OBJECTS' AND ATTRIBUTE_NAME='DAYTIME' AND PROPERTY_CODE='viewhidden' AND PROPERTY_VALUE='true';
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_FINDER_OBJECTS' AND ATTRIBUTE_NAME='END_DATE' AND PROPERTY_CODE='viewhidden' AND PROPERTY_VALUE='true';
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) 
select 'TANK_FINDER_OBJECTS','OBJECT_END_DATE','LABEL',2500,'/EC','APPLICATION','Object End Date' from dual;