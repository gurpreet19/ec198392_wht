CREATE OR REPLACE EDITIONABLE TRIGGER "D_FIN_COST_CENTER" 
BEFORE DELETE ON FIN_COST_CENTER
FOR EACH ROW
DECLARE

BEGIN
       ECDP_RR_REVN_MAPPING_INTERFACE.CheckIfAddedToList(
                               :OLD.object_id,
                               :OLD.object_code,'FIN_COST_CENTER'
                             );
END;
