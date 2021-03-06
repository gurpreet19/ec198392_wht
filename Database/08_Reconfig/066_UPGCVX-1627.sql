UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='GAS_MASS' AND UNIT='KG';
UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='GAS_MASS' AND UNIT='LBS';
UPDATE TV_UOM_SETUP SET DB_UNIT='Y',REPORT_UNIT='Y',VIEW_UNIT='Y' WHERE MEASUREMENT_TYPE='GAS_MASS' AND UNIT='TONNES';

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_PTST_PWEL_RESULT','WGR','UOM_CODE',2500,'/','VIEWLAYER','RATIO_LIQ_GAS_WT');

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_PTST_PWEL_RESULT','CGR','UOM_CODE',2500,'/','VIEWLAYER','RATIO_LIQ_GAS_WT');

UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='PRESS_ABS' AND UNIT='PSIA';
UPDATE TV_UOM_SETUP SET DB_UNIT='Y',REPORT_UNIT='Y',VIEW_UNIT='Y' WHERE MEASUREMENT_TYPE='PRESS_ABS' AND UNIT='KPAA';

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_PTST_PWEL_RESULT','BH_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');


UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='PRESS_GAUGE' AND UNIT='PSIG';
UPDATE TV_UOM_SETUP SET DB_UNIT='Y',REPORT_UNIT='Y',VIEW_UNIT='Y' WHERE MEASUREMENT_TYPE='PRESS_GAUGE' AND UNIT='KPAG';

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_PTST_PWEL_RESULT','WH_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_PTST_PWEL_RESULT','WH_USC_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');


Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_PTST_PWEL_RESULT','WH_DSC_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');

UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='WATER_VOL' AND UNIT='M3';
UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='WATER_VOL' AND UNIT='BBLS';
UPDATE TV_UOM_SETUP SET DB_UNIT='Y',REPORT_UNIT='Y',VIEW_UNIT='Y' WHERE MEASUREMENT_TYPE='WATER_VOL' AND UNIT='SM3';


UPDATE CLASS_CNFG SET DB_OBJECT_NAME='DEFERMENT_EVENT' WHERE CLASS_NAME IN ('CT_LPO_OFF_EVENT','CT_EQPM_OFF_EVENT');
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='EcBp_Deferment.getparenteventlossrate(deferment_event.event_no,''COND'',deferment_type) / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_COND_DEN'',''<='')' WHERE CLASS_NAME='CT_LPO_OFF_EVENT' AND ATTRIBUTE_NAME='COND_EVENT_LOSS_V';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='EcBp_Deferment.getpotentialrate(EVENT_NO,''COND'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_COND_DEN'',''<='')' WHERE CLASS_NAME='CT_LPO_OFF_EVENT' AND ATTRIBUTE_NAME='COND_POTENTIAL_V';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='EcBp_Deferment.getparenteventlossrate(deferment_event.event_no,''GAS'',deferment_type) / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_GAS_DEN'',''<='')' WHERE CLASS_NAME='CT_LPO_OFF_EVENT' AND ATTRIBUTE_NAME='GAS_EVENT_LOSS_V';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='EcBp_Deferment.getpotentialrate(EVENT_NO,''GAS'') / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_GAS_DEN'',''<='')' WHERE CLASS_NAME='CT_LPO_OFF_EVENT' AND ATTRIBUTE_NAME='GAS_POTENTIAL_V';

UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='deferment_event.COND_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_COND_DEN'',''<='')' WHERE CLASS_NAME='CT_LPO_OFF_EVENT' AND ATTRIBUTE_NAME='COND_LOSS_RATE_V';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX ='deferment_event.GAS_LOSS_RATE / EC_CTRL_SYSTEM_ATTRIBUTE.attribute_value(deferment_event.daytime,''LPO_GAS_DEN'',''<='')' WHERE CLASS_NAME='CT_LPO_OFF_EVENT' AND ATTRIBUTE_NAME='GAS_LOSS_RATE_V';

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_LPO_OFF_EVENT','COND_EVENT_LOSS','UOM_CODE',2500,'/','VIEWLAYER','LIQ_MASS');

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_LPO_OFF_EVENT','GAS_EVENT_LOSS','UOM_CODE',2500,'/','VIEWLAYER','GAS_MASS');

