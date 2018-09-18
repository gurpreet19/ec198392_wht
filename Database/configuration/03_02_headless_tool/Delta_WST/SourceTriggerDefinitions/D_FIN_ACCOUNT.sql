CREATE OR REPLACE EDITIONABLE TRIGGER "D_FIN_ACCOUNT" 
BEFORE DELETE ON FIN_ACCOUNT
FOR EACH ROW
DECLARE

BEGIN
       ECDP_RR_REVN_MAPPING_INTERFACE.CheckIfAddedToList(
                               :OLD.object_id,
                               :OLD.object_code,'FIN_ACCOUNT'
                             );
END;
