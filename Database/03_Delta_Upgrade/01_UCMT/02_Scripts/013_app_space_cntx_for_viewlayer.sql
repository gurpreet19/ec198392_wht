DECLARE 
  PROCEDURE alterTrigger(p_trigger_name IN VARCHAR2, p_operation IN VARCHAR2)
  IS
  BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'ALTER TRIGGER '||p_trigger_name||' '||p_operation;
        EXCEPTION WHEN others THEN null;
    END;
  END;
BEGIN
  alterTrigger('biud_class_property_cnfg'     , 'DISABLE');
  alterTrigger('biu_class_property_cnfg'      , 'DISABLE');
  alterTrigger('biud_class_attr_property_cnfg', 'DISABLE');
  alterTrigger('biu_class_attr_property_cnfg' , 'DISABLE');
  alterTrigger('biud_class_rel_property_cnfg' , 'DISABLE');
  alterTrigger('biu_class_rel_property_cnfg'  , 'DISABLE');
  
  alterTrigger('ap_class_property_cnfg'       , 'DISABLE');
  alterTrigger('ap_class_attr_property_cnfg'  , 'DISABLE');
  alterTrigger('ap_class_rel_property_cnfg'   , 'DISABLE');
 
  UPDATE class_attr_property_cnfg SET last_updated_by=last_updated_by, last_updated_date=last_updated_date, presentation_cntx='/' WHERE property_type='VIEWLAYER' AND presentation_cntx='/EC';  
  UPDATE class_property_cnfg      SET last_updated_by=last_updated_by, last_updated_date=last_updated_date, presentation_cntx='/' WHERE property_type='VIEWLAYER' AND presentation_cntx='/EC';
  UPDATE class_rel_property_cnfg  SET last_updated_by=last_updated_by, last_updated_date=last_updated_date, presentation_cntx='/' WHERE property_type='VIEWLAYER' AND presentation_cntx='/EC';
  COMMIT;

  alterTrigger('biud_class_property_cnfg'     , 'ENABLE');
  alterTrigger('biu_class_property_cnfg'      , 'ENABLE');
  alterTrigger('biud_class_attr_property_cnfg', 'ENABLE');
  alterTrigger('biu_class_attr_property_cnfg' , 'ENABLE');
  alterTrigger('biud_class_rel_property_cnfg' , 'ENABLE');
  alterTrigger('biu_class_rel_property_cnfg'  , 'ENABLE');
  
  alterTrigger('ap_class_property_cnfg'       , 'ENABLE');
  alterTrigger('ap_class_attr_property_cnfg'  , 'ENABLE');
  alterTrigger('ap_class_rel_property_cnfg'   , 'ENABLE');
END;
/