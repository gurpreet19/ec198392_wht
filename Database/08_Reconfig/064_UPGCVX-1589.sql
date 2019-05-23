update prosty_codes set alt_code='/com.ec.wheatstone.screens/layout/cond_demurrage.xml' where code='COND_DEMURRAGE';
update prosty_codes set alt_code='/com.ec.wheatstone.screens/layout/cond_ebo' where code='COND_EBO';

UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='NVL(EC_LIFTING_ACTIVITY.TO_daytime(CARGO_NO, UE_CT_DEMURRAGE.GetDemurrageActivityCode(CARGO_NO, DEMURRAGE_TYPE, ''END''), 1,''LOAD''), EC_LIFTING_ACTIVITY.from_daytime(CARGO_NO, UE_CT_DEMURRAGE.GetDemurrageActivityCode(CARGO_NO, DEMURRAGE_TYPE, ''END''), 1,''LOAD''))-EC_LIFTING_ACTIVITY.from_daytime(CARGO_NO, UE_CT_DEMURRAGE.GetDemurrageActivityCode(CARGO_NO, DEMURRAGE_TYPE, ''START''), 1,''LOAD'')'
WHERE CLASS_NAME='DEMURRAGE' AND ATTRIBUTE_NAME='INTERMEDIATE_LAYTIME';

UPDATE CLASS_ATTRIBUTE_CNFG SET DB_SQL_SYNTAX='EcBp_demurrage.findDelayFromTimesheet(CARGO_NO, DEMURRAGE_TYPE, LIFTING_EVENT)' WHERE CLASS_NAME='DEMURRAGE' AND ATTRIBUTE_NAME='TS_DELAY';

insert into class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
values ('DEMURRAGE', 'TS_DELAY', 'DISABLED_IND', 2500, '/', 'VIEWLAYER','Y');