CREATE OR REPLACE EDITIONABLE TRIGGER "BIUD_CLASS_RELATION_CNFG" 
BEFORE INSERT OR UPDATE OR DELETE ON class_relation_cnfg
FOR EACH ROW
BEGIN
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.to_class_name, :old.to_class_name), 'VIEWLAYER', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.to_class_name, :old.to_class_name), 'REPORTLAYER', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.from_class_name, :old.from_class_name), 'VIEWLAYER', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.from_class_name, :old.from_class_name), 'REPORTLAYER', TRUE);
END;
