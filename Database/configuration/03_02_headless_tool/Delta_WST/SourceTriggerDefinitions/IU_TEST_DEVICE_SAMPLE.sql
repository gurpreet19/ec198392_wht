CREATE OR REPLACE EDITIONABLE TRIGGER "IU_TEST_DEVICE_SAMPLE" 
BEFORE INSERT OR UPDATE ON test_device_sample

FOR EACH ROW
DECLARE
  lv_oil_meter_code VARCHAR2(32);
  lv_gas_meter_code VARCHAR2(32);
  lv_water_meter_code VARCHAR2(32);

BEGIN
  -- $Revision: 1.14 $
  -- Common
  IF :new.data_class_name LIKE '%TDEV_SAMPLE%' THEN
    IF Inserting AND NOT ( :new.oil_out_rate_1_raw IS NULL and :new.oil_out_rate_2_raw IS NULL  AND :NEW.oil_out_rate_3_raw IS NULL ) THEN
      lv_oil_meter_code := EcDp_Performance_Test.getMeterCode(:new.object_id, :new.daytime, 'OIL');
      IF lv_oil_meter_code = 'OIL_METER_1' THEN
        :new.oil_out_rate_raw := :new.oil_out_rate_1_raw;
      END IF;
      IF lv_oil_meter_code = 'OIL_METER_2' THEN
        :new.oil_out_rate_raw := :new.oil_out_rate_2_raw;
      END IF;
      IF lv_oil_meter_code = 'OIL_METER_3' THEN
        :new.oil_out_rate_raw := :new.oil_out_rate_3_raw;
      END IF;
    END IF;

    IF Inserting AND NOT (  :new.gas_out_rate_1_raw IS NULL and :new.gas_out_rate_2_raw IS NULL  AND  :new.gas_out_rate_3_raw IS NULL ) THEN
      lv_gas_meter_code := EcDp_Performance_Test.getMeterCode(:new.object_id, :new.daytime, 'GAS');
      IF lv_gas_meter_code = 'GAS_METER_1' THEN
        :new.gas_out_rate_raw := :new.gas_out_rate_1_raw;
      END IF;
      IF lv_gas_meter_code = 'GAS_METER_2' THEN
        :new.gas_out_rate_raw := :new.gas_out_rate_2_raw;
      END IF;
      IF lv_gas_meter_code = 'GAS_METER_3' THEN
        :new.gas_out_rate_raw := :new.gas_out_rate_3_raw;
      END IF;
    END IF;

    IF Inserting AND NOT ( :new.water_out_rate_1_raw IS NULL and :new.water_out_rate_2_raw  IS NULL AND  :new.water_out_rate_3_raw IS NULL ) THEN
      lv_water_meter_code := EcDp_Performance_Test.getMeterCode(:new.object_id, :new.daytime, 'WATER');
        IF lv_water_meter_code = 'WATER_METER_1' THEN
        :new.water_out_rate_raw := :new.water_out_rate_1_raw;
      END IF;
      IF lv_water_meter_code = 'WATER_METER_2' THEN
        :new.water_out_rate_raw := :new.water_out_rate_2_raw;
      END IF;
      IF lv_water_meter_code = 'WATER_METER_3' THEN
        :new.water_out_rate_raw := :new.water_out_rate_3_raw;
      END IF;
    END IF;

    IF  (Updating('OIL_OUT_RATE_RAW') OR Updating('OIL_OUT_RATE_1_RAW') OR Updating('OIL_OUT_RATE_2_RAW') OR Updating('OIL_OUT_RATE_3_RAW') ) THEN
      lv_oil_meter_code := EcDp_Performance_Test.getMeterCode(:new.object_id, :new.daytime, 'OIL');
      IF lv_oil_meter_code = 'OIL_METER_1' THEN
        :new.oil_out_rate_raw := :new.oil_out_rate_1_raw;
      END IF;
      IF lv_oil_meter_code = 'OIL_METER_2' THEN
        :new.oil_out_rate_raw := :new.oil_out_rate_2_raw;
      END IF;
      IF lv_oil_meter_code = 'OIL_METER_3' THEN
        :new.oil_out_rate_raw := :new.oil_out_rate_3_raw;
      END IF;
    END IF;

    IF (Updating('GAS_OUT_RATE_RAW') OR Updating('GAS_OUT_RATE_1_RAW') OR Updating('GAS_OUT_RATE_2_RAW') OR Updating('GAS_OUT_RATE_3_RAW')) THEN
      lv_gas_meter_code := EcDp_Performance_Test.getMeterCode(:new.object_id, :new.daytime, 'GAS');
      IF lv_gas_meter_code = 'GAS_METER_1' THEN
        :new.gas_out_rate_raw := :new.gas_out_rate_1_raw;
      END IF;
      IF lv_gas_meter_code = 'GAS_METER_2' THEN
        :new.gas_out_rate_raw := :new.gas_out_rate_2_raw;
      END IF;
      IF lv_gas_meter_code = 'GAS_METER_3' THEN
        :new.gas_out_rate_raw := :new.gas_out_rate_3_raw;
      END IF;
    END IF;

    IF (Updating('WATER_OUT_RATE_RAW') OR Updating('WATER_OUT_RATE_1_RAW') OR Updating('WATER_OUT_RATE_2_RAW') OR Updating('WATER_OUT_RATE_3_RAW')) THEN
      lv_water_meter_code := EcDp_Performance_Test.getMeterCode(:new.object_id, :new.daytime, 'WATER');
      IF lv_water_meter_code = 'WATER_METER_1' THEN
        :new.water_out_rate_raw := :new.water_out_rate_1_raw;
      END IF;
      IF lv_water_meter_code = 'WATER_METER_2' THEN
        :new.water_out_rate_raw := :new.water_out_rate_2_raw;
      END IF;
      IF lv_water_meter_code = 'WATER_METER_3' THEN
        :new.water_out_rate_raw := :new.water_out_rate_3_raw;
      END IF;
    END IF;

  END IF;

  IF Inserting THEN

    :NEW.record_status := NVL(:NEW.record_status,'P');
    :new.dayhr :=trunc(:new.daytime,'HH24');
    IF :new.created_by IS NULL THEN
       :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
    END IF;

    EcDp_Timestamp_Utils.syncUtcDate('TEST_DEVICE', :NEW.object_id, :NEW.utc_daytime, :NEW.time_zone, :NEW.daytime, :NEW.summer_time);
    EcDp_Timestamp_Utils.setProductionDay('TEST_DEVICE', :NEW.object_id, :NEW.utc_daytime, :NEW.production_day);

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
