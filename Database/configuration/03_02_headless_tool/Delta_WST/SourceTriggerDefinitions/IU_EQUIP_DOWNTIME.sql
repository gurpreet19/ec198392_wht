CREATE OR REPLACE EDITIONABLE TRIGGER "IU_EQUIP_DOWNTIME" 
BEFORE INSERT OR UPDATE ON EQUIP_DOWNTIME
FOR EACH ROW
DECLARE
    ld_prod_offset     DATE;
BEGIN
    -- Basis
    IF Inserting THEN

      IF :NEW.day IS NULL THEN
        :NEW.day := EcDp_ProductionDay.getProductionDay(NULL,:NEW.object_id, :NEW.daytime);
      END IF;

      IF :NEW.end_day IS NULL AND :NEW.end_date IS NOT NULL THEN
         ld_prod_offset := ecdp_productionday.getproductionday(NULL, :NEW.object_id, :NEW.end_date) + Ecdp_Productionday.getProductionDayOffset(null, :NEW.object_id, :NEW.end_date) / 24;
         IF :NEW.end_date = ld_prod_offset THEN
            :NEW.end_day := EcDp_ProductionDay.getProductionDay(NULL,:NEW.object_id, :NEW.end_date) - 1;
         ELSE
            :NEW.end_day := EcDp_ProductionDay.getProductionDay(NULL,:NEW.object_id, :NEW.end_date);
         END IF;
      END IF;

      :NEW.record_status := NVL(:NEW.record_status, 'P');
      IF :NEW.event_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('EQUIP_DOWNTIME', :NEW.event_no);
      END IF;
      IF :NEW.created_by IS NULL THEN
         :NEW.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :NEW.created_date IS NULL THEN
         :NEW.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :NEW.rev_no := 0;

    ELSE

      IF UPDATING('DAYTIME') THEN
         :NEW.day := EcDp_ProductionDay.getProductionDay(NULL,:NEW.object_id, :NEW.daytime);
      END IF;

      IF UPDATING('END_DATE') THEN
         IF :NEW.end_date IS NOT NULL THEN
            ld_prod_offset := ecdp_productionday.getproductionday(NULL, :NEW.object_id, :NEW.end_date) + Ecdp_Productionday.getProductionDayOffset(null, :NEW.object_id, :NEW.end_date) / 24;
            IF :NEW.end_date = ld_prod_offset THEN
               :NEW.end_day := EcDp_ProductionDay.getProductionDay(NULL,:NEW.object_id, :NEW.end_date) - 1;
            ELSE
               :NEW.end_day := EcDp_ProductionDay.getProductionDay(NULL,:NEW.object_id, :NEW.end_date);
            END IF;
         ELSE
            :NEW.end_day := null;
         END IF;
      END IF;

      IF NVL(:NEW.record_status,'P') = NVL(:OLD.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :NEW.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :NEW.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;
