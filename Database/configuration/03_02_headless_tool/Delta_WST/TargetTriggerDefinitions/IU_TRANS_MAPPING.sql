CREATE OR REPLACE TRIGGER "IU_TRANS_MAPPING" 
BEFORE INSERT OR UPDATE ON TRANS_MAPPING
FOR EACH ROW
BEGIN
    -- $Revision: 1.4 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.MAPPING_NO IS NULL THEN
         EcDp_System_key.assignNextNumber('TRANS_MAPPING',:NEW.MAPPING_NO);
      END IF;

     IF :new.TAG_ID IS NULL THEN
         :new.TAG_ID := ue_trans_tagname.getCalcTagId(:new.MAPPING_NO);
         IF :new.TAG_ID IS NULL THEN
           :new.TAG_ID := 'DUMMY -' || :new.MAPPING_NO;
           :new.active := 'N';
         END IF;
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

