CREATE OR REPLACE EDITIONABLE TRIGGER "BIUD_CLASS_ATTRIBUTE_CNFG" 
BEFORE INSERT OR UPDATE OR DELETE ON class_attribute_cnfg
FOR EACH ROW
BEGIN
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.class_name, :old.class_name), 'VIEWLAYER', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.class_name, :old.class_name), 'REPORTLAYER', TRUE);
END;
