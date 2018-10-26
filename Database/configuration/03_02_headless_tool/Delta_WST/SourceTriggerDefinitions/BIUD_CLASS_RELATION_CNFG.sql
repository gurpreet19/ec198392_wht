CREATE OR REPLACE EDITIONABLE TRIGGER "BIUD_CLASS_RELATION_CNFG" 
BEFORE INSERT OR UPDATE OR DELETE ON class_relation_cnfg
FOR EACH ROW
BEGIN
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.to_class_name, :old.to_class_name), 'VIEWLAYER', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.to_class_name, :old.to_class_name), 'REPORTLAYER', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind('CLASS_RELATION', 'MATVIEW', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind('CLASS_REL_DB_MAPPING', 'MATVIEW', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind('CLASS_REL_PRESENTATION', 'MATVIEW', TRUE);
END;
