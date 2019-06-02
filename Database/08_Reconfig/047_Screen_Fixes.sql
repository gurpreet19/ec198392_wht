--Tank Daily


SET ESCAPE ON;
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','BSW_VOL','DESCRIPTION',2500,'/EC','APPLICATION','BS\&W Volume');
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','BSW_VOL','LABEL',2500,'/EC','APPLICATION','BS\&W');
SET ESCAPE OFF;
INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) VALUES ('TANK_DAY_INV_OIL','BSW_VOL','viewunit',2500,'/EC','STATIC_PRESENTATION','PCT');
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','BSW_VOL','viewwidth',2500,'/EC','STATIC_PRESENTATION',70);
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','BSW_VOL','viewformatmask',2500,'/EC','STATIC_PRESENTATION','##0.00');
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','BSW_VOL','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','DECODE(Ec_tank_version.bs_w_vol_method(DV_TANK_DAY_INV_SINGLE_DIP.OBJECT_ID,DV_TANK_DAY_INV_SINGLE_DIP.DAYTIME,''<=''),''MEASURED'',''vieweditable=true'',''vieweditable=false'')');
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','BSW_VOL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION',350);

Insert into CLASS_ATTRIBUTE_CNFG (CLASS_NAME,ATTRIBUTE_NAME,APP_SPACE_CNTX,IS_KEY,DATA_TYPE,DB_MAPPING_TYPE,DB_SQL_SYNTAX) values ('TANK_DAY_INV_OIL','CALC_DENSITY','WST','N','NUMBER','FUNCTION','(ECBP_TANK.findStdDens(TANK_MEASUREMENT.OBJECT_ID,TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE,TANK_MEASUREMENT.DAYTIME)*1000)');

Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','CALC_DENSITY','DB_SORT_ORDER',2500,'/','VIEWLAYER',360);
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','CALC_DENSITY','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION',360);
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','CALC_DENSITY','LABEL',2500,'/EC','APPLICATION','Calc Density');
INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) VALUES ('TANK_DAY_INV_OIL','CALC_DENSITY','viewlabelhead',2500,'/EC','STATIC_PRESENTATION','Actual');
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','CALC_DENSITY','viewwidth',2500,'/EC','STATIC_PRESENTATION',70);
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','CALC_DENSITY','viewformatmask',2500,'/EC','STATIC_PRESENTATION','##0');
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','CALC_DENSITY','UOM_CODE',2500,'/','VIEWLAYER','STD_LNG_DENS');

INSERT INTO T_BASIS_ACCESS (ROLE_ID, APP_ID, LEVEL_ID, OBJECT_ID) VALUES ('CP.ORIGINAL.READ',1,10,(SELECT OBJECT_ID FROM T_BASIS_OBJECT WHERE OBJECT_NAME LIKE '%/com.ec.prod.po.screens/daily_tank_status_1%'));
INSERT INTO T_BASIS_ACCESS (ROLE_ID, APP_ID, LEVEL_ID, OBJECT_ID) VALUES ('PA.A.DATA.WRITE',1,60,(SELECT OBJECT_ID FROM T_BASIS_OBJECT WHERE OBJECT_NAME LIKE '%/com.ec.prod.po.screens/daily_tank_status_1%'));
INSERT INTO T_BASIS_ACCESS (ROLE_ID, APP_ID, LEVEL_ID, OBJECT_ID) VALUES ('PA.DATA.READ',1,10,(SELECT OBJECT_ID FROM T_BASIS_OBJECT WHERE OBJECT_NAME LIKE '%/com.ec.prod.po.screens/daily_tank_status_1%'));
INSERT INTO T_BASIS_ACCESS (ROLE_ID, APP_ID, LEVEL_ID, OBJECT_ID) VALUES ('PA.P.DATA.WRITE',1,40,(SELECT OBJECT_ID FROM T_BASIS_OBJECT WHERE OBJECT_NAME LIKE '%/com.ec.prod.po.screens/daily_tank_status_1%'));
INSERT INTO T_BASIS_ACCESS (ROLE_ID, APP_ID, LEVEL_ID, OBJECT_ID) VALUES ('PA.V.DATA.WRITE',1,50,(SELECT OBJECT_ID FROM T_BASIS_OBJECT WHERE OBJECT_NAME LIKE '%/com.ec.prod.po.screens/daily_tank_status_1%'));

UPDATE TANK_VERSION SET  BF_USAGE='PO.0005' WHERE  BF_USAGE='PO.0005.04'; 

--Schedule Lifting Chart
INSERT INTO T_BASIS_ACCESS (ROLE_ID, APP_ID, LEVEL_ID, OBJECT_ID) VALUES ('CP.ORIGINAL.READ',1,10,(SELECT OBJECT_ID FROM T_BASIS_OBJECT WHERE OBJECT_NAME LIKE '%/com.ec.tran.cp.screens/schedule_lifting_jsf/CLASS1/STOR_DAY_BALANCE_GRAPH/CLASS2/STOR_BERTH_DAY_RESTR/CLASS3/STORAGE_LIFT_NOM_SCHED%'));

--Harbour Dues Setup
delete from class_attr_property_cnfg where class_name='HARBOUR_DUE_ITEMS' 
and attribute_name in ('START_DATE','END_DATE') and PROPERTY_CODE='viewhidden' and PROPERTY_VALUE='true';

--UPGCVX-1660
INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
VALUES ('CHEM_TANK_STATUS','TANK_METER_FREQ','LABEL',2500,'/EC','APPLICATION','Tank Meter Frequency');

--UPGCVX-1663
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('STRM_DAY_STREAM_MEAS_GAS','GRS_VOL_GAS','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION',500);
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('STRM_DAY_STREAM_MEAS_GAS','GRS_MASS_GAS','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION',525);

UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='GAS_VOL' AND UNIT='MCF';


DELETE CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='STRM_DAY_STREAM_DER_GAS' AND ATTRIBUTE_NAME='ALLOC_ENERGY' AND PROPERTY_CODE='viewhidden' AND OWNER_CNTX=2500;
DELETE CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='STRM_DAY_STREAM_MEAS_GAS' AND ATTRIBUTE_NAME='NET_MASS_GAS' AND PROPERTY_CODE='viewhidden' AND OWNER_CNTX=2500;

--UPGCVX-1675
UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='Y',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='LIQ_MASS' AND UNIT='LBS';

--UPGCVX-1665
UPDATE CLASS_ATTR_PROPERTY_CNFG SET PROPERTY_VALUE='(CASE WHEN UE_CT_VALIDATION_CHECK.checkAccess(''23000'',ecdp_context.getAppUseR,''CALC_TRAN_CP_FCST_LOG'',ACCEPT_STATUS,JOB_ID) = ''1'' THEN ''true;'' ELSE ''false;'' END)' WHERE CLASS_NAME='CALC_TRAN_CP_FCST_LOG' AND ATTRIBUTE_NAME ='ACCEPT_STATUS' AND PROPERTY_CODE='vieweditable' ;

UPDATE SYSTEM_MONTH SET LOCK_IND='Y' where LOCK_IND='X';

COMMIT;