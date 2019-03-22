CREATE OR REPLACE EDITIONABLE TRIGGER "BIUD_CLASS_DEPENDENCY_CNFG" 
BEFORE INSERT OR UPDATE OR DELETE ON class_dependency_cnfg
FOR EACH ROW
BEGIN
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.parent_class, :old.parent_class), 'VIEWLAYER', TRUE);
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.parent_class, :old.parent_class), 'REPORTLAYER', TRUE);

  IF nvl(:new.dependency_type, :old.dependency_type) = 'ACCESS_CONTROLLED_BY' THEN
    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.child_class, :old.child_class), 'VIEWLAYER', TRUE);
    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.child_class, :old.child_class), 'REPORTLAYER', TRUE);
    ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.child_class, :old.child_class), 'DAC', TRUE);
  END IF;
END;
