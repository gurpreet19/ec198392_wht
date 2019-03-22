CREATE OR REPLACE EDITIONABLE TRIGGER "BIUD_CLASS_REL_PROPERTY_CNFG" 
BEFORE INSERT OR UPDATE OR DELETE ON class_rel_property_cnfg
FOR EACH ROW
DECLARE
BEGIN
  IF nvl(:new.property_type, :old.property_type) = 'VIEWLAYER' THEN
    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.to_class_name, :old.to_class_name), 'VIEWLAYER', TRUE);
    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.to_class_name, :old.to_class_name), 'REPORTLAYER', TRUE);

    IF nvl(:new.property_code, :old.property_code) = 'ACCESS_CONTROL_METHOD' THEN
        ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.to_class_name, :old.to_class_name), 'DAC', TRUE);
    END IF;

    TCP_CLASS_REL_PROPERTY_CNFG.insert_data(nvl(:new.to_class_name, :old.to_class_name));
  END IF;
END;
