CREATE OR REPLACE TRIGGER "IU_WELL_VERSION" 
BEFORE INSERT OR UPDATE ON WELL_VERSION
FOR EACH ROW
BEGIN
    -- $Revision: 1.4 $
    -- Common
    IF Inserting THEN
      :new.IsProducer := EcDp_Well_Type.isProducer(:new.well_type);
      :new.IsProducerOrOther := EcDp_Well_Type.IsProducerOrOther(:new.well_type);
      :new.IsInjector := EcDp_Well_Type.IsInjector(:new.well_type);
      :new.IsOther := EcDp_Well_Type.IsOther(:new.well_type);
      :new.IsNotOther := EcDp_Well_Type.IsNotOther(:new.well_type);
      :new.IsOilProducer := EcDp_Well_Type.IsOilProducer(:new.well_type);
      :new.IsGasProducer := EcDp_Well_Type.IsGasProducer(:new.well_type);
      :new.IsCondensateProducer := EcDp_Well_Type.IsCondensateProducer(:new.well_type);
      :new.IsWaterProducer := EcDp_Well_Type.IsWaterProducer(:new.well_type);
      :new.IsGasInjector := EcDp_Well_Type.IsGasInjector(:new.well_type);
      :new.IsWaterInjector := EcDp_Well_Type.IsWaterInjector(:new.well_type);
      :new.IsAirInjector := EcDp_Well_Type.IsAirInjector(:new.well_type);
      :new.IsSteamInjector := EcDp_Well_Type.IsSteamInjector(:new.well_type);
      :new.IsWasteInjector := EcDp_Well_Type.IsWasteInjector(:new.well_type);
      :new.IsCO2Injector   := EcDp_Well_Type.IsCO2Injector(:new.well_type);

      :new.well_class := EcDp_Well_Type.findWellClass(:new.well_type);

      :NEW.record_status := NVL(:NEW.record_status,'P');

      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF :new.well_type <> :old.well_type THEN
         :new.IsProducer := EcDp_Well_Type.isProducer(:new.well_type);
         :new.IsProducerOrOther := EcDp_Well_Type.IsProducerOrOther(:new.well_type);
         :new.IsInjector := EcDp_Well_Type.IsInjector(:new.well_type);
         :new.IsOther := EcDp_Well_Type.IsOther(:new.well_type);
         :new.IsNotOther := EcDp_Well_Type.IsNotOther(:new.well_type);
         :new.IsOilProducer := EcDp_Well_Type.IsOilProducer(:new.well_type);
         :new.IsGasProducer := EcDp_Well_Type.IsGasProducer(:new.well_type);
         :new.IsCondensateProducer := EcDp_Well_Type.IsCondensateProducer(:new.well_type);
         :new.IsWaterProducer := EcDp_Well_Type.IsWaterProducer(:new.well_type);
         :new.IsGasInjector := EcDp_Well_Type.IsGasInjector(:new.well_type);
         :new.IsWaterInjector := EcDp_Well_Type.IsWaterInjector(:new.well_type);
         :new.IsAirInjector := EcDp_Well_Type.IsAirInjector(:new.well_type);
         :new.IsSteamInjector := EcDp_Well_Type.IsSteamInjector(:new.well_type);
         :new.IsWasteInjector := EcDp_Well_Type.IsWasteInjector(:new.well_type);
         :new.IsCO2Injector   := EcDp_Well_Type.IsCO2Injector(:new.well_type);

         :new.well_class := EcDp_Well_Type.findWellClass(:new.well_type);
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

