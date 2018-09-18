CREATE OR REPLACE TRIGGER "IU_OBJ_FLUID_ANA_DETAIL" 
BEFORE INSERT OR UPDATE ON OBJ_FLUID_ANA_DETAIL
FOR EACH ROW
BEGIN
    -- $Revision: 1.2 $
    -- Common
    IF Inserting THEN
      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;
     IF :new.analysis_item IS NULL THEN
         EcDp_System_Key.assignNextNumber('OBJ_FLUID_ANA_DETAIL',:new.analysis_item);
      END IF;

	 IF :new.daytime IS NULL THEN
         :new.daytime := ec_object_fluid_analysis.daytime(:new.analysis_no);
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

