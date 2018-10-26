CREATE OR REPLACE EDITIONABLE TRIGGER "BS_NAV_MODEL" 
BEFORE INSERT OR UPDATE OR DELETE ON NAV_MODEL
BEGIN
  FOR curDirtyDescendent IN ecdp_viewlayer_utils.getAllNavModel LOOP
    ecdp_viewlayer_utils.set_dirty_ind(curDirtyDescendent.class_name, 'VIEWLAYER', TRUE);
    ecdp_viewlayer_utils.set_dirty_ind(curDirtyDescendent.class_name, 'REPORTLAYER', TRUE);
  END LOOP;
END;
