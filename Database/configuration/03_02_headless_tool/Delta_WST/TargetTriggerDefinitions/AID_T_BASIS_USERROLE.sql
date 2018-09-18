CREATE OR REPLACE TRIGGER "AID_T_BASIS_USERROLE" 
AFTER INSERT OR DELETE ON T_BASIS_USERROLE
FOR EACH ROW
DECLARE
BEGIN
    -- $Revision: 1.4 $
    -- Common

    IF INSERTING THEN
    Ecdp_Context.setDirtyAppUser(:new.user_id);
    ELSIF DELETING THEN
    Ecdp_Context.setDirtyAppUser(:old.user_id);
    END IF;
END;

