CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PWEL_DAY_STATUS" 
BEFORE INSERT OR UPDATE ON pwel_day_status
FOR EACH ROW
BEGIN
    -- $Revision: 1.13 $
    -- COMMON
   IF inserting THEN

      IF EcDp_Well.getWellClass(:NEW.object_id,
      				:New.daytime) = 'I' THEN
	      RAISE_APPLICATION_ERROR(-20000,'Attempt to insert production data for injection well ' ||
                   ec_well_version.name(:NEW.object_id, Ecdp_Timestamp.getCurrentSysdate, '<='));
      END IF;

      :new.daytime := trunc(:new.daytime,'DD');
      :NEW.record_status := NVL(:NEW.record_status,'P');

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

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

  END IF;
END;
