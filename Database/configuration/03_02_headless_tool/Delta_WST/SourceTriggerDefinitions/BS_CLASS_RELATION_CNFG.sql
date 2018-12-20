CREATE OR REPLACE EDITIONABLE TRIGGER "BS_CLASS_RELATION_CNFG" 
BEFORE INSERT OR UPDATE OR DELETE ON Class_Relation_Cnfg
BEGIN
  FOR curDirtyDescendent IN ecdp_viewlayer_utils.getAllGrmodel LOOP
    ecdp_viewlayer_utils.set_dirty_ind(curDirtyDescendent.class_name, 'VIEWLAYER', TRUE);
    ecdp_viewlayer_utils.set_dirty_ind(curDirtyDescendent.class_name, 'REPORTLAYER', TRUE);
  END LOOP;
END;