INSERT
INTO CLASS_ATTR_PROPERTY_CNFG
  (
    CLASS_NAME,
    ATTRIBUTE_NAME,
    PROPERTY_CODE,
    OWNER_CNTX,
    PRESENTATION_CNTX,
    PROPERTY_TYPE,
    PROPERTY_VALUE,
    RECORD_STATUS,
    REV_TEXT
  )
  VALUES
  (
    'PROD_LIFT_ACTIVITY_CODE',
    'TIMELINE_CODE',
    'viewhidden',
    0,
    '/EC',
    'STATIC_PRESENTATION',
    'true',
    'P',
    'UPGCVX-2542'
  );
  
  commit;
  
  UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('PROD_LIFT_ACTIVITY_CODE');
commit;

exec ecdp_viewlayer.buildviewlayer('PROD_LIFT_ACTIVITY_CODE', p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer('PROD_LIFT_ACTIVITY_CODE', p_force => 'Y'); 