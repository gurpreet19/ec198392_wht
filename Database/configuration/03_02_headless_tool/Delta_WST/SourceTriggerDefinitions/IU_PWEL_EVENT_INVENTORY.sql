CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PWEL_EVENT_INVENTORY" 
BEFORE INSERT OR UPDATE ON PWEL_EVENT_INVENTORY
FOR EACH ROW
BEGIN
    -- Common

    IF Inserting OR (Updating('GRS_OIL_OUT') OR Updating('BSW_OUT') OR Updating('GRS_OIL_IN') OR Updating('BSW_IN') OR Updating('GRS_OIL_OUT') OR Updating('BSW_OUT')) THEN
    	:new.net_oil     := nvl(:new.grs_oil_in,0)*(1-nvl(:new.bsw_in,0)) - nvl(:new.grs_oil_out,0)*(1-nvl(:new.bsw_out,0));
    	:new.water       := nvl(:new.grs_oil_in,0)*nvl(:new.bsw_in,0) - nvl(:new.grs_oil_out,0)*nvl(:new.bsw_out,0);

    END IF;


     IF Inserting OR (Updating('UNLOAD_DAYTIME'))THEN
         EcDp_Timestamp_Utils.syncUtcDate(:NEW.unload_stream_id, :NEW.utc_unload_daytime, :NEW.unload_daytime);
         EcDp_Timestamp_Utils.setProductionDay(:NEW.unload_stream_id, :NEW.utc_unload_daytime, :NEW.unload_day);

     END IF;


    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_daytime, :NEW.production_day);

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.unload_stream_id, :OLD.utc_unload_daytime, :NEW.utc_unload_daytime, :OLD.unload_daytime, :NEW.unload_daytime);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.unload_stream_id, :OLD.utc_unload_daytime, :NEW.utc_unload_daytime, :OLD.unload_day, :NEW.unload_day);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.production_day, :NEW.production_day);

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
