CREATE OR REPLACE TRIGGER "IU_T_BASIS_CLIENTERRORLOG" 
BEFORE INSERT OR UPDATE ON t_basis_ClientErrorLog
FOR EACH ROW
BEGIN
    -- $Revision: 1.3 $
    -- Basis
    IF Inserting THEN

       IF :new.UserRegistered IS NULL THEN
          :new.UserRegistered := USER;
       END IF;
       IF :new.osuser_id  IS NULL THEN
          SELECT sys_context('USERENV','OS_USER')
          INTO :new.osuser_id
          FROM dual;
       END IF;

       :new.DateRegistered := EcDp_Date_Time.getCurrentSysdate;

       :NEW.record_status := NVL(:NEW.record_status,'P');
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

