CREATE OR REPLACE EDITIONABLE TRIGGER "IU_OBJECTS_DEFERMENT_EVENT" 
BEFORE INSERT OR UPDATE ON objects_deferment_event
FOR EACH ROW
BEGIN
    -- $Revision: 1.4 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');

      IF :NEW.production_day IS NULL THEN
         :new.production_day := EcDp_ProductionDay.getProductionDay(:NEW.object_type,:NEW.object_id, :NEW.daytime);
      END IF;

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

      IF :new.event_id IS NULL THEN
        EcDp_System_Key.assignNextNumber('OBJECTS_DEFERMENT_EVENT', :NEW.event_id);
      END IF;

      IF :new.oil_prod_loss IS NULL THEN
      	:new.oil_prod_loss := ecbp_well_potential.findOilProductionPotential(
      									     :new.object_id,
      									     :new.production_day);
      END IF;

      IF :new.gas_prod_loss IS NULL THEN
      	:new.gas_prod_loss := ecbp_well_potential.findGasProductionPotential(
      									     :new.object_id,
      									     :new.production_day);
      END IF;

      IF :new.water_prod_loss IS NULL THEN
      	:new.water_prod_loss := ecbp_well_potential.findWatProductionPotential(
      									       :new.object_id,
      									       :new.production_day);
      END IF;

      IF :new.cond_prod_loss IS NULL THEN
      	:new.cond_prod_loss := ecbp_well_potential.findConProductionPotential(
      									     :new.object_id,
      									     :new.production_day);
      END IF;

      IF :new.gas_inj_loss IS NULL THEN
      	:new.gas_inj_loss := ecbp_well_potential.findGasInjectionPotential(
      									   :new.object_id,
      									   :new.production_day);
      END IF;

      IF :new.water_inj_loss IS NULL THEN
      	:new.water_inj_loss := ecbp_well_potential.findWatInjectionPotential(
      									     :new.object_id,
      									     :new.production_day);
      END IF;

    ELSE
      IF UPDATING('DAYTIME') THEN
         :new.production_day := EcDp_ProductionDay.getProductionDay(:NEW.object_type,:NEW.object_id, :NEW.daytime);
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
    Ecdp_objects_deferment_event.v_num_rows := Ecdp_objects_deferment_event.v_num_rows + 1;
    Ecdp_objects_deferment_event.v_event_ids(Ecdp_objects_deferment_event.v_num_rows) := :new.event_id;
    Ecdp_objects_deferment_event.v_daytimes(Ecdp_objects_deferment_event.v_num_rows) := :new.daytime;
    Ecdp_objects_deferment_event.v_end_dates(Ecdp_objects_deferment_event.v_num_rows) := :new.end_date;
    Ecdp_objects_deferment_event.v_object_ids(Ecdp_objects_deferment_event.v_num_rows) := :new.object_id;
    Ecdp_objects_deferment_event.v_object_types(Ecdp_objects_deferment_event.v_num_rows) := :new.object_type;
    Ecdp_objects_deferment_event.v_parent_event_ids(Ecdp_objects_deferment_event.v_num_rows) := :new.parent_event_id;
END;
