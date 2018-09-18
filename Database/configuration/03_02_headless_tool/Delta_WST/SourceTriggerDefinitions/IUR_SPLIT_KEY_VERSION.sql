CREATE OR REPLACE EDITIONABLE TRIGGER "IUR_SPLIT_KEY_VERSION" 
BEFORE INSERT OR UPDATE ON SPLIT_KEY_VERSION
FOR EACH ROW
DECLARE
o_rec_id          VARCHAR2(32) := :OLD.rec_id;
BEGIN
    IF Inserting THEN
      IF :new.rec_id IS NULL THEN
         :new.rec_id := SYS_GUID();
      END IF;
      IF INSERTING THEN

      IF :new.daytime IS NOT NULL
        THEN Ecdp_Split_Key.CopySplitKeySetupForNewVersion(:new.object_id,:new.daytime,USER);
      END IF;

 END IF;
    ELSE
         IF o_rec_id is null THEN
            o_rec_id := SYS_GUID();
          END IF;
          IF NOT UPDATING('REC_ID') THEN
            :new.rec_id := o_rec_id;
          END IF;
     END IF;
END;
