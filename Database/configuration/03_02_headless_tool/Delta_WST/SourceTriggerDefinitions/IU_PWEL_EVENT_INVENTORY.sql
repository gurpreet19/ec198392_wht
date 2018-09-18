CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PWEL_EVENT_INVENTORY" 
BEFORE INSERT OR UPDATE ON PWEL_EVENT_INVENTORY
FOR EACH ROW
BEGIN
    -- Basis

    IF Inserting OR (Updating('GRS_OIL_OUT') OR Updating('BSW_OUT') OR Updating('GRS_OIL_IN') OR Updating('BSW_IN') OR Updating('GRS_OIL_OUT') OR Updating('BSW_OUT')) THEN
    	:new.net_oil     := nvl(:new.grs_oil_in,0)*(1-nvl(:new.bsw_in,0)) - nvl(:new.grs_oil_out,0)*(1-nvl(:new.bsw_out,0));
    	:new.water       := nvl(:new.grs_oil_in,0)*nvl(:new.bsw_in,0) - nvl(:new.grs_oil_out,0)*nvl(:new.bsw_out,0);

    END IF;


     IF Inserting OR (Updating('UNLOAD_DAYTIME'))THEN
         :new.unload_day := EcDp_ProductionDay.getProductionDay('STREAM',:NEW.unload_stream_id, :NEW.unload_daytime, NULL);
     END IF;


    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');
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
