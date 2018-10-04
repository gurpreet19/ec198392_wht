CREATE OR REPLACE TRIGGER "IU_PRODUCT_MEAS_SETUP" 
BEFORE INSERT OR UPDATE ON product_meas_setup
FOR EACH ROW
BEGIN
    -- $Revision: 1.3 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;
      IF :new.product_meas_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('PRODUCT_MEAS_SETUP',:new.product_meas_no);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := User;
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
         END IF;

      END IF;
    END IF;
END;

