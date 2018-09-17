CREATE OR REPLACE TRIGGER "IU_WEBO_PRESS_TEST_GRAD" 
BEFORE INSERT OR UPDATE ON WEBO_PRESS_TEST_GRAD
FOR EACH ROW
BEGIN
    -- Basis
    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      IF :new.gradient_seq IS NULL THEN
        -- :new.gradient_seq := EcDp_Webo_Press_Test.assignNextGradientSeq(:new.event_no);
		 EcDp_System_Key.assignNextNumber('WEBO_PRESS_TEST_GRAD',:new.gradient_seq);
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

