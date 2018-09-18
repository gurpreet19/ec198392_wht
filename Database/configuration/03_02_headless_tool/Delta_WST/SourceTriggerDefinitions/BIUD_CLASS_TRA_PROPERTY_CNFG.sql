CREATE OR REPLACE EDITIONABLE TRIGGER "BIUD_CLASS_TRA_PROPERTY_CNFG" 
BEFORE INSERT OR UPDATE OR DELETE ON class_tra_property_cnfg
FOR EACH ROW
DECLARE
BEGIN
  IF nvl(:new.property_type, :old.property_type) = 'VIEWLAYER' THEN

    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.class_name, :old.class_name), 'VIEWLAYER', TRUE);
    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.class_name, :old.class_name), 'REPORTLAYER', TRUE);

  END IF;

  IF nvl(:new.property_code, :old.property_code)IN ('DESCRIPTION', 'DISABLED_IND') THEN

    ecdp_viewlayer_utils.set_dirty_ind('CLASS_TRIGGER_ACTION', 'MATVIEW', TRUE);

  END IF;
END;
