CREATE OR REPLACE EDITIONABLE TRIGGER "D_FIN_REVENUE_ORDER" 
BEFORE DELETE ON FIN_REVENUE_ORDER
FOR EACH ROW
DECLARE

BEGIN
       ECDP_RR_REVN_MAPPING_INTERFACE.CheckIfAddedToList(
                               :OLD.object_id,
                               :OLD.object_code,'FIN_REVENUE_ORDER'
                             );
END;
