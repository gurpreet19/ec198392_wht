UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='GAS_MASS' AND UNIT='KG';
UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='GAS_MASS' AND UNIT='LBS';
UPDATE TV_UOM_SETUP SET DB_UNIT='Y',REPORT_UNIT='Y',VIEW_UNIT='Y' WHERE MEASUREMENT_TYPE='GAS_MASS' AND UNIT='TONNES';

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_PTST_PWEL_RESULT','WGR','UOM_CODE',2500,'/','VIEWLAYER','RATIO_LIQ_GAS_WT');

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_PTST_PWEL_RESULT','CGR','UOM_CODE',2500,'/','VIEWLAYER','RATIO_LIQ_GAS_WT');

UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='PRESS_ABS' AND UNIT='KPAA';
UPDATE TV_UOM_SETUP SET DB_UNIT='Y',REPORT_UNIT='Y',VIEW_UNIT='Y' WHERE MEASUREMENT_TYPE='PRESS_ABS' AND UNIT='PSIA';

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_PTST_PWEL_RESULT','BH_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');


UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='PRESS_GAUGE' AND UNIT='PSIG';
UPDATE TV_UOM_SETUP SET DB_UNIT='Y',REPORT_UNIT='Y',VIEW_UNIT='Y' WHERE MEASUREMENT_TYPE='PRESS_GAUGE' AND UNIT='KPAG';

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_PTST_PWEL_RESULT','WH_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values 
('CT_PTST_PWEL_RESULT','WH_USC_PRESS','UOM_CODE',2500,'/','VIEWLAYER','PRESS_ABS');