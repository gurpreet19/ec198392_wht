CREATE OR REPLACE TRIGGER "IU_WELL_EQUIP_DOWNTIME" 
BEFORE INSERT OR UPDATE ON WELL_EQUIP_DOWNTIME
FOR EACH ROW
BEGIN
    -- Basis
    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');
       --new event_no will be assigned to WELL_EQUIP_DOWNTIME
      IF :new.event_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('WELL_EQUIP_DOWNTIME', :new.event_no);
      END IF;
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
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

