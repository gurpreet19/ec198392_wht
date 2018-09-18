CREATE OR REPLACE TRIGGER "IU_OBJECT_FLUID_ANALYSIS" 
BEFORE INSERT OR UPDATE ON object_fluid_analysis
FOR EACH ROW
BEGIN
    -- $Revision: 1.16 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;
     IF :new.analysis_no IS NULL THEN

         EcDp_System_Key.assignNextNumber('OBJECT_FLUID_ANALYSIS',:new.analysis_no);

      END IF;

     IF :NEW.production_day IS NULL THEN
        :new.production_day := EcDp_ProductionDay.getProductionDay(NULL,:NEW.object_id, :NEW.daytime);
     END IF;

     IF :NEW.valid_from_date IS NULL THEN
        :NEW.valid_from_date := :NEW.production_day;
     END IF;

     IF :NEW.object_class_name IS NULL THEN
        :NEW.object_class_name := Ecdp_Objects.GetObjClassName(:NEW.object_id);
     END IF;

     IF INSERTING AND :NEW.analysis_status = 'APPROVED' THEN

            IF :NEW.valid_from_date is not NULL  THEN
              :NEW.check_unique := :NEW.analysis_type || :NEW.object_id || to_char(:NEW.valid_from_date,'dd.mm.yyyy hh24:mi:ss')|| :NEW.phase || SUBSTR(:NEW.sampling_method,1,11);
            ELSIF :NEW.valid_from_date is NULL  THEN
              :NEW.check_unique := :NEW.analysis_type || :NEW.object_id || to_char(:NEW.daytime,'dd.mm.yyyy hh24:mi:ss')|| :NEW.phase || SUBSTR(:NEW.sampling_method,1,11);
            END IF;

     END IF;


      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE

      IF :NEW.analysis_status = 'APPROVED' THEN

        IF :NEW.valid_from_date is not NULL THEN
                :NEW.check_unique := :NEW.analysis_type || :NEW.object_id || to_char(:NEW.valid_from_date,'dd.mm.yyyy hh24:mi:ss')|| :NEW.phase || SUBSTR(:NEW.sampling_method,1,11);

        ELSIF :NEW.valid_from_date is NULL THEN
                :NEW.check_unique := :NEW.analysis_type || :NEW.object_id || to_char(:NEW.daytime,'dd.mm.yyyy hh24:mi:ss')|| :NEW.phase || SUBSTR(:NEW.sampling_method,1,11);
        END IF;

     ELSIF :OLD.analysis_status = 'APPROVED' THEN
           :NEW.check_unique := NULL;
     END IF;

     IF :NEW.daytime <> :OLD.daytime THEN
         :new.production_day := Ecdp_Productionday.getProductionDay(NULL, :NEW.object_id, :NEW.daytime);
     END IF;

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

