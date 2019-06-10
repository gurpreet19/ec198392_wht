BEGIN
update viewlayer_dirty_log 
set dirty_ind='Y'
where object_name IN (  'CHANNEL',
                       'CHEM_INJ_POINT',
                       'CHEM_TANK',
                       'CHOKE_MODEL',
                       'COLLECTION_POINT',
                       'EQPM',
                       'FIELD',
                       'FORECAST_COMPARISON',
                       'FORECAST_GROUP',
                       'LOADING_ARM',
                       'OPERATOR_ROUTE',
                       'PILOT',
                       'PILOT_BOAT',
                       'PLANNED_WELL',
                       'SHIFT',
                       'STORAGE',
                       'STREAM',
                       'TANK',
                       'TESTSEPARATOR',
                       'TEST_DEVICE',
                       'TUG_BOAT',
                       'WELL',
                       'WELL_HOLE',
                       'WELL_HOOKUP'
                     )
and dirty_type='VIEWLAYER';

COMMIT;

END;
/

exec ecdp_viewlayer_utils.set_dirty_ind('STORAGE_LIFT_NOMINATION','REPORTLAYER',TRUE);
exec ecdp_viewlayer_utils.set_dirty_ind('STORAGE_LIFT_NOM_ALLOC','REPORTLAYER',TRUE);
exec ecdp_viewlayer_utils.set_dirty_ind('STORAGE_LIFT_NOM_BLMR','REPORTLAYER',TRUE);
exec ecdp_viewlayer_utils.set_dirty_ind('STORAGE_LIFT_NOM_DETAIL','REPORTLAYER',TRUE);

exec ecdp_viewlayer_utils.set_dirty_ind('STORAGE_LIFT_NOM_INFO','REPORTLAYER',TRUE);
exec ecdp_viewlayer_utils.set_dirty_ind('STORAGE_LIFT_NOM_LA','REPORTLAYER',TRUE);
exec ecdp_viewlayer_utils.set_dirty_ind('STORAGE_LIFT_NOM_OVERV','REPORTLAYER',TRUE);
exec ecdp_viewlayer_utils.set_dirty_ind('STORAGE_LIFT_NOM_POPUP','REPORTLAYER',TRUE);

exec ecdp_viewlayer_utils.set_dirty_ind('STORAGE_LIFT_NOM_SCHED','REPORTLAYER',TRUE);
exec ecdp_viewlayer_utils.set_dirty_ind('STORAGE_LIFT_NOM_SPLIT','REPORTLAYER',TRUE);
exec ecdp_viewlayer_utils.set_dirty_ind('STORAGE_LIFT_NOM_UNLOAD','REPORTLAYER',TRUE);
exec ecdp_viewlayer_utils.set_dirty_ind('PORT_RES_USAGE_POOL','REPORTLAYER',TRUE);

commit;