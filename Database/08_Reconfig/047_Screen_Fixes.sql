--Tank Daily


SET ESCAPE ON;
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','BSW_VOL','DESCRIPTION',2500,'/EC','APPLICATION','BS\&W Volume');
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','BSW_VOL','LABEL',2500,'/EC','APPLICATION','BS\&W');
SET ESCAPE OFF;
INSERT INTO CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) VALUES ('TANK_DAY_INV_OIL','BSW_VOL','viewunit',2500,'/EC','STATIC_PRESENTATION','PCT');
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','BSW_VOL','viewwidth',2500,'/EC','STATIC_PRESENTATION',70);
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','BSW_VOL','viewformatmask',2500,'/EC','STATIC_PRESENTATION','##0.00');
Insert into CLASS_ATTR_PROPERTY_CNFG (CLASS_NAME,ATTRIBUTE_NAME,PROPERTY_CODE,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_TYPE,PROPERTY_VALUE) values ('TANK_DAY_INV_OIL','BSW_VOL','PresentationSyntax',2500,'/EC','DYNAMIC_PRESENTATION','DECODE(Ec_tank_version.bs_w_vol_method(DV_TANK_DAY_INV_OIL.OBJECT_ID,DV_TANK_DAY_INV_OIL.DAYTIME,''<=''),''MEASURED'',''vieweditable=true'',''vieweditable=false'')');
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

--UPGCVX-1760
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' AND ATTRIBUTE_NAME='DIP_UOM' AND PROPERTY_CODE='viewhidden' AND PROPERTY_VALUE='true';
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','DIP_UOM','DESCRIPTION',2500,'/EC','APPLICATION','Dip UOM' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','DIP_UOM','DB_SORT_ORDER',2500,'/','VIEWLAYER','300' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','DIP_UOM','LABEL',2500,'/EC','APPLICATION','UOM' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','DIP_UOM','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','300' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','DIP_UOM','viewwidth',2500,'/EC','STATIC_PRESENTATION','30' from dual;

DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' AND ATTRIBUTE_NAME='DIP_LEVEL' AND PROPERTY_CODE='viewhidden' AND PROPERTY_VALUE='true';
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','DIP_LEVEL','DESCRIPTION',2500,'/EC','APPLICATION','Total dip height' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','DIP_LEVEL','DB_SORT_ORDER',2500,'/','VIEWLAYER','200' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','DIP_LEVEL','LABEL',2500,'/EC','APPLICATION','Dip' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','DIP_LEVEL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','200' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','DIP_LEVEL','viewwidth',2500,'/EC','STATIC_PRESENTATION','50' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','DIP_LEVEL','viewformatmask',2500,'/EC','DYNAMIC_PRESENTATION','decode(DIP_UOM,''PCT'', ''#,##0.00'',''M'', ''#,##0.000'',''CM'', ''#,##0'', ''RC'', ''#,##0'', ''inch::f'''' i" n/4'')' from dual;

DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TANK_DAY_INV_OIL' AND ATTRIBUTE_NAME='BSW_VOL' AND PROPERTY_CODE='DISABLED_IND' AND OWNER_CNTX=2500 AND PROPERTY_VALUE='Y';
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','BSW_VOL','DB_SORT_ORDER',2500,'/','VIEWLAYER','350' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','TANK_METER_FREQ','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','150' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','OPENING_GRS_VOL','DESCRIPTION',2500,'/EC','APPLICATION','Opening Grs Volume' from dual;
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='EcBp_Tank.findOpeningGrsVol(TANK_MEASUREMENT.object_id, ''DAY_CLOSING'', TANK_MEASUREMENT.daytime)' WHERE CLASS_NAME='TANK_DAY_INV_OIL' AND ATTRIBUTE_NAME='OPENING_GRS_VOL';

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','OPENING_GRS_VOL','LABEL',2500,'/EC','APPLICATION','Opening Grs Vol' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','OPENING_GRS_VOL','viewwidth',2500,'/EC','STATIC_PRESENTATION','70' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','OPENING_GRS_VOL','UOM_CODE',2500,'/','VIEWLAYER','STD_LNG_VOL' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','OPENING_GRS_VOL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','400' from dual;

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','CLOSING_GRS_VOL','DESCRIPTION',2500,'/EC','APPLICATION','Closing Grs Volume' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','CLOSING_GRS_VOL','LABEL',2500,'/EC','APPLICATION','Closing Grs Vol' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','CLOSING_GRS_VOL','viewwidth',2500,'/EC','STATIC_PRESENTATION','70' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','CLOSING_GRS_VOL','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','500' from dual;
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_MAPPING_TYPE='FUNCTION',DB_SQL_SYNTAX='EcBp_Tank.findGrsVol(TANK_MEASUREMENT.object_id, ''DAY_CLOSING'', TANK_MEASUREMENT.daytime)' WHERE CLASS_NAME='TANK_DAY_INV_OIL' AND ATTRIBUTE_NAME='CLOSING_GRS_VOL';

UPDATE CLASS_ATTR_PROPERTY_CNFG SET property_value='STD_LNG_VOL' WHERE CLASS_NAME='TANK_DAY_INV_OIL' AND ATTRIBUTE_NAME='CLOSING_GRS_VOL' and property_code='UOM_CODE' and  owner_cntx=2500 and property_value='STD_LIQ_VOL';

Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','OPENING_GRS_MASS','LABEL',2500,'/EC','APPLICATION','Opening Grs Mass' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','OPENING_GRS_MASS','UOM_CODE',2500,'/','VIEWLAYER','OIL_MASS' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TANK_DAY_INV_OIL','OPENING_GRS_MASS','SCREEN_SORT_ORDER',2500,'/EC','APPLICATION','800' from dual;

delete from CLASS_ATTR_PROPERTY_CNFG where CLASS_NAME='TANK_DAY_INV_OIL' AND ATTRIBUTE_NAME='CLOSING_GRS_MASS' and property_code='LABEL' and  owner_cntx=2500 and property_value='Closing';
UPDATE CLASS_ATTRIBUTE_CNFG SET DB_MAPPING_TYPE='FUNCTION',DB_SQL_SYNTAX='EcBp_Tank.findGrsMass(TANK_MEASUREMENT.object_id, ''DAY_CLOSING'', TANK_MEASUREMENT.daytime)' WHERE CLASS_NAME='TANK_DAY_INV_OIL' AND ATTRIBUTE_NAME='CLOSING_GRS_MASS';
UPDATE CLASS_ATTR_PROPERTY_CNFG SET property_value='OIL_MASS' WHERE CLASS_NAME='TANK_DAY_INV_OIL' AND ATTRIBUTE_NAME='CLOSING_GRS_MASS' and property_code='UOM_CODE' and  owner_cntx=2500 and property_value='LIQ_MASS';
UPDATE CLASS_ATTR_PROPERTY_CNFG SET property_value=900 WHERE CLASS_NAME='TANK_DAY_INV_OIL' AND ATTRIBUTE_NAME='CLOSING_GRS_MASS' and property_code='SCREEN_SORT_ORDER' and  owner_cntx=2500 and property_value=1600;

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('TANK_DAY_INV_OIL', 'CALC_CLOSING_OIL_VOL', 'viewhidden', 2500, '/EC', 'STATIC_PRESENTATION','true');

UPDATE TV_UOM_SETUP SET DB_UNIT='N',REPORT_UNIT='N',VIEW_UNIT='N' WHERE MEASUREMENT_TYPE='STD_LNG_DENS' AND UNIT='KGPERSM3';

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

--UPGCVX-1730
UPDATE TV_UNIT_CONVERSION SET MULT_FACT='6.2922636' WHERE FROM_UNIT='SM3' AND TO_UNIT='BBLS' AND DAYTIME='01-JAN-60';
UPDATE TV_UNIT_CONVERSION SET MULT_FACT='0.035383251' WHERE FROM_UNIT='SM3' AND TO_UNIT='MSCF' AND DAYTIME='01-JAN-60';

--MESSAGE_GENERATION
delete from CLASS_ATTR_PROPERTY_CNFG where CLASS_NAME='MESSAGE_GENERATION' AND ATTRIBUTE_NAME='MESSAGE_TYPE' and property_code='viewhidden' and  owner_cntx=2500 and property_value='true';

--Daily Nomination Point Availability
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='TRNP_DAY_AVAILABILITY' AND ATTRIBUTE_NAME='UOM' AND PROPERTY_CODE='viewhidden' AND PROPERTY_VALUE='true';
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'TRNP_DAY_AVAILABILITY','UOM','LABEL',2500,'/EC','APPLICATION','Uom' from dual;

--Gas Stream Component Analysis
DELETE FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME='STRM_GAS_ANALYSIS' AND ATTRIBUTE_NAME='WOBBE_INDEX' AND PROPERTY_CODE='viewhidden' AND PROPERTY_VALUE='true';

--Stream AGA Analysis
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'AGA_CONSTANT','AGA3_TYPE','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'AGA_CONSTANT','COMPRES_FLOW','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'AGA_CONSTANT','COMPRES_STD','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'AGA_CONSTANT','CONDITION_FACTOR','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;
Insert into CLASS_ATTR_PROPERTY_CNFG(class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) select 'AGA_CONSTANT','EFF_CORR_FACTOR','viewhidden',2500,'/EC','STATIC_PRESENTATION','true' from dual;

COMMIT;