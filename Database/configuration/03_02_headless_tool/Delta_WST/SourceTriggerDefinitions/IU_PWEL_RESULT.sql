CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PWEL_RESULT" 
BEFORE INSERT OR UPDATE ON PWEL_RESULT
FOR EACH ROW
BEGIN
    -- Basis
    IF Inserting THEN
      IF :new.record_status IS NULL THEN
        :new.record_status := 'P';
      END IF;
      IF :NEW.status = 'ACCEPTED' AND :NEW.use_calc='Y' THEN
        :NEW.check_unique := :NEW.object_id || to_char(:NEW.valid_from_date,'dd.mm.yyyy hh24:mi:ss');
      ELSE
        :NEW.check_unique := null;
      END IF;
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF ((:NEW.status <> :OLD.status OR :NEW.use_calc <> :OLD.use_calc OR :NEW.valid_from_date <> :OLD.valid_from_date) AND
           :NEW.status = 'ACCEPTED' AND :NEW.use_calc='Y') THEN
        :NEW.check_unique := :NEW.object_id || to_char(:NEW.valid_from_date,'dd.mm.yyyy hh24:mi:ss');
      ELSIF (:NEW.status <> 'ACCEPTED' OR :NEW.use_calc <> 'Y') THEN
        :NEW.check_unique := null;
      END IF;
      IF :new.data_class_name = 'PWEL_RESULT' AND
        (NVL(:NEW.NET_OIL_RATE_ADJ,0) <> NVL(:OLD.NET_OIL_RATE_ADJ,0) OR
        NVL(:NEW.GAS_RATE_ADJ,0) <> NVL(:OLD.GAS_RATE_ADJ,0) OR
        NVL(:NEW.TOT_WATER_RATE_ADJ,0) <> NVL(:OLD.TOT_WATER_RATE_ADJ,0) OR
        NVL(:NEW.GL_RATE,0) <> NVL(:OLD.GL_RATE,0) OR
        NVL(:NEW.GOR,0) <> NVL(:OLD.GOR,0) OR
        NVL(:NEW.GLR,0) <> NVL(:OLD.GLR,0) OR
        NVL(:NEW.WATERCUT_PCT,0) <> NVL(:OLD.WATERCUT_PCT,0) OR
        NVL(:NEW.NET_COND_RATE_ADJ,0) <> NVL(:OLD.NET_COND_RATE_ADJ,0) OR
        NVL(:NEW.CGR,0) <> NVL(:OLD.CGR,0) OR
        NVL(:NEW.WGR,0) <> NVL(:OLD.WGR,0) OR
        NVL(:NEW.WET_DRY_GAS_RATIO,0) <> NVL(:OLD.WET_DRY_GAS_RATIO,0) OR
        NVL(:NEW.WET_GAS_GRAVITY,0) <> NVL(:OLD.WET_GAS_GRAVITY,0) OR
        NVL(:NEW.GAS_SP_GRAV,0) <> NVL(:OLD.GAS_SP_GRAV,0)) THEN

        :NEW.RATE_SOURCE := 'MANUAL';
    END IF;
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
    -- if there is no test device and data class is PWEL_RESULT, then do some calculations
    IF :new.test_device IS NULL and :new.data_class_name = 'PWEL_RESULT' THEN
      IF ec_well_version.isOilProducer(:new.object_id, :new.daytime, '<=')='Y' THEN
        IF :new.NET_OIL_RATE_ADJ > 0 THEN
          :new.GOR := :new.GAS_RATE_ADJ/:new.NET_OIL_RATE_ADJ;
          :new.WOR := :new.TOT_WATER_RATE_ADJ/:new.NET_OIL_RATE_ADJ;
        END IF;
      END IF;

      IF ec_well_version.isOilProducer(:new.object_id, :new.daytime, '<=')='Y' THEN
        IF (:new.NET_OIL_RATE_ADJ + :new.TOT_WATER_RATE_ADJ) > 0 THEN
          :new.GLR := :new.GAS_RATE_ADJ/(:new.NET_OIL_RATE_ADJ + :new.TOT_WATER_RATE_ADJ);
          :new.WATERCUT_PCT := (:new.TOT_WATER_RATE_ADJ/(:new.NET_OIL_RATE_ADJ + :new.TOT_WATER_RATE_ADJ))*100;
        END IF;
      END IF;

      IF (ec_well_version.isGasProducer(:new.object_id, :new.daytime, '<=')='Y' OR ec_well_version.isCondensateProducer(:new.object_id, :new.daytime, '<=')='Y') THEN
        IF :new.GAS_RATE_ADJ > 0 THEN
          :new.CGR := :new.NET_COND_RATE_ADJ/:new.GAS_RATE_ADJ;
          :new.WGR := :new.TOT_WATER_RATE_ADJ/:new.GAS_RATE_ADJ;
          :new.WET_DRY_GAS_RATIO := :new.FWS_RATE/:new.GAS_RATE_ADJ;
          :new.WET_GAS_GRAVITY := (2.856 * (:new.NET_COND_RATE_ADJ/:new.GAS_RATE_ADJ)) + :new.GAS_SP_GRAV;
        END IF;
      END IF;
    END IF;

    -- set the Liquid Rate value
    :new.LIQUID_RATE_ADJ := nvl(:new.NET_OIL_RATE_ADJ, :new.NET_COND_RATE_ADJ) + nvl(:new.TOT_WATER_RATE_ADJ, 0);
END;
