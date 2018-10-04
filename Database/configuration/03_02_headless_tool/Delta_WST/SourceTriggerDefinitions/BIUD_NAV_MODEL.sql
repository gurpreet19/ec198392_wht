CREATE OR REPLACE EDITIONABLE TRIGGER "BIUD_NAV_MODEL" 
BEFORE INSERT OR UPDATE OR DELETE ON nav_model
FOR EACH ROW
BEGIN
  ecdp_viewlayer_utils.set_dirty_ind(nvl(:new.model, :old.model), 'NAVMODEL', TRUE);
END;
