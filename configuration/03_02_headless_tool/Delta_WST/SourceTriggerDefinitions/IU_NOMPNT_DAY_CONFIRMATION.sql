CREATE OR REPLACE EDITIONABLE TRIGGER "IU_NOMPNT_DAY_CONFIRMATION" 
BEFORE INSERT OR UPDATE ON NOMPNT_DAY_CONFIRMATION
FOR EACH ROW
BEGIN
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.CONFIRMATION_SEQ IS NULL THEN
         EcDp_System_Key.assignNextNumber('NOMPNT_DAY_CONFIRMATION', :new.CONFIRMATION_SEQ);
      END IF;

	 :NEW.CONTRACT_ID := EC_NOMINATION_POINT.CONTRACT_ID(:NEW.object_id);
	 :NEW.ENTRY_LOCATION_ID := EC_NOMINATION_POINT.ENTRY_LOCATION_ID(:NEW.object_id);
	 :NEW.EXIT_LOCATION_ID := EC_NOMINATION_POINT.EXIT_LOCATION_ID(:NEW.object_id);

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;

      -- Make sure that no one updated contract and locations
      IF (:NEW.CONTRACT_ID IS NOT NULL AND :NEW.CONTRACT_ID <> :OLD.CONTRACT_ID) THEN
      		Raise_Application_Error(-20000,'Not allowed to update contract') ;
      END IF;

      IF (:NEW.ENTRY_LOCATION_ID IS NOT NULL AND :NEW.ENTRY_LOCATION_ID <> :OLD.ENTRY_LOCATION_ID) THEN
      		Raise_Application_Error(-20000,'Not allowed to update entry location') ;
      END IF;

      IF (:NEW.EXIT_LOCATION_ID IS NOT NULL AND :NEW.EXIT_LOCATION_ID <> :OLD.EXIT_LOCATION_ID) THEN
      		Raise_Application_Error(-20000,'Not allowed to update exit location') ;
      END IF;
    END IF;
END;
