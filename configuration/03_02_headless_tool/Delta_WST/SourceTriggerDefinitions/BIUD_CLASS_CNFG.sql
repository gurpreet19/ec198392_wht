CREATE OR REPLACE EDITIONABLE TRIGGER "BIUD_CLASS_CNFG" 
BEFORE INSERT OR UPDATE OR DELETE ON class_cnfg
FOR EACH ROW
BEGIN
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.class_name, :old.class_name), 'VIEWLAYER', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.class_name, :old.class_name), 'REPORTLAYER', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind('CLASS', 'MATVIEW', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind('CLASS_DB_MAPPING', 'MATVIEW', TRUE);
END;
