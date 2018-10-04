CREATE OR REPLACE EDITIONABLE TRIGGER "IU_BPM_PA_COMMAND_QUEUE" 
BEFORE INSERT OR UPDATE ON JBPM_BPM_PA_COMMAND_QUEUE
FOR EACH ROW
BEGIN
    -- Basis
    IF Inserting THEN
      IF :new.ID IS NULL THEN
         EcDp_System_Key.assignNextNumber('JBPM_BPM_PA_COMMAND_QUEUE', :new.ID);
      END IF;

      IF :new.created_time IS NULL THEN
         :new.created_time := Ecdp_Timestamp.getCurrentSysdate;
      END IF;

    END IF;
END;
