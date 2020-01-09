UPDATE tv_uom_Setup
SET db_unit            ='N',
  report_unit          ='N',
  view_unit            ='N'
WHERE MEASUREMENT_TYPE = 'ENERGY_RATE_MTH'
AND unit               ='MJPERMTH';

UPDATE tv_uom_Setup
SET db_unit            ='N',
  report_unit          ='N',
  view_unit            ='N'
WHERE MEASUREMENT_TYPE = 'STD_LNG_DENS'
AND unit               ='LBSPERBBLS';

commit;

UPDATE viewlayer_dirty_log
SET DIRTY_IND      ='Y'
WHERE object_name IN ('CT_PROD_STRM_PC_FCST_LST');
COMMIT;
EXECUTE EcDp_Viewlayer.BuildViewLayer('CT_PROD_STRM_PC_FCST_LST') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('CT_PROD_STRM_PC_FCST_LST') ;