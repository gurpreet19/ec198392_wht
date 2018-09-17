CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FCST_MTH_STATUS" 
BEFORE INSERT OR UPDATE ON FCST_MTH_STATUS
FOR EACH ROW
DECLARE
    -- local variables here

    lv2_uom_group VARCHAR2(1);
    lv2_uom_subgroup ctrl_unit.uom_subgroup%type;
    lv2_uom_subgroup_qtytarget ctrl_unit.uom_subgroup%type;
    lv2_stream_item_id VARCHAR2(32);

BEGIN
    -- Copied From Basis
    IF Inserting THEN
      :new.daytime := trunc(:new.daytime,'MM');
      :new.record_status := 'P';
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

	IF (ec_forecast.functional_area_code(:New.object_id) = 'QUANTITY_FORECAST') THEN -- Only run for QTY FCST

    IF (Updating('NET_QTY') OR Updating('UOM')) AND :New.last_updated_by <> 'INTERNAL' THEN

        lv2_stream_item_id := ec_fcst_member.stream_item_id(:New.MEMBER_NO);

        IF lv2_stream_item_id IS NOT NULL THEN
            lv2_uom_group := ecdp_unit.GetUOMGroup(:New.UOM);

            -- Do Mass update on STIM table
            IF (lv2_uom_group = 'M') THEN
                UPDATE stim_fcst_mth_value t
                   SET t.net_mass_value  = ecdp_unit.convertValue(:New.NET_QTY,
                                                                  :New.UOM,
                                                                  t.mass_uom_code,
                                                                  :New.DAYTIME),
                       t.last_updated_by = 'INTERNAL'
                 WHERE t.object_id = lv2_stream_item_id
                   AND t.forecast_id = :New.OBJECT_ID
                   AND t.daytime = :New.DAYTIME;

            -- Do Volume update on STIM table
            -- Added support for BOE conversion (ECPD-12942 | skjorsti)
            ELSIF (lv2_uom_group = 'V') THEN

                UPDATE stim_fcst_mth_value t
                   SET t.net_volume_value = ecdp_unit.convertValue(:New.NET_QTY,
                                                                   :New.UOM,
                                                                   t.volume_uom_code,
                                                                   :New.DAYTIME),
                       t.last_updated_by  = 'INTERNAL'
                 WHERE t.object_id = lv2_stream_item_id
                   AND t.forecast_id = :New.OBJECT_ID
                   AND t.daytime = :New.DAYTIME;

            -- Do Energy update on STIM table
            ELSIF (lv2_uom_group = 'E') THEN
                lv2_uom_subgroup := ec_ctrl_unit.uom_subgroup(:new.uom);
                lv2_uom_subgroup_qtytarget := ec_ctrl_unit.uom_subgroup(ec_stim_fcst_mth_value.energy_uom_code(lv2_stream_item_id,:new.object_id,:new.daytime));

           -- None or both are BOE numbers. Normal conversion logic applies
         IF (lv2_uom_subgroup = 'BE' AND lv2_uom_subgroup_qtytarget = 'BE') OR (lv2_uom_subgroup <> 'BE' AND lv2_uom_subgroup_qtytarget <> 'BE') THEN

              UPDATE stim_fcst_mth_value t
                 SET t.net_energy_value = ecdp_unit.convertValue(:New.NET_QTY,
                                                                 :New.UOM,
                                                                 t.energy_uom_code,
                                                                 :New.DAYTIME),
                     t.last_updated_by  = 'INTERNAL'
               WHERE t.object_id = lv2_stream_item_id
                 AND t.forecast_id = :New.OBJECT_ID
                 AND t.daytime = :New.DAYTIME;

           -- Qty Target is BOE
           ELSIF lv2_uom_subgroup_qtytarget = 'BE' THEN

                 UPDATE stim_fcst_mth_value t
                    SET t.net_energy_value = ecdp_stream_item.GetBOEUnitValue(lv2_stream_item_id,
                                                                              :new.daytime,
                                                                              :new.net_qty,
                                                                              :new.uom,
                                                                              t.boe_from_uom_code,
                                                                              t.energy_uom_code,
                                                                              t.boe_factor),
                        t.last_updated_by  = 'INTERNAL'
                  WHERE t.object_id = lv2_stream_item_id
                    AND t.forecast_id = :new.object_id
                    and t.daytime = :new.daytime;

             -- Source is BOE
             ELSIF lv2_uom_subgroup = 'BE' THEN

                  UPDATE stim_fcst_mth_value t
                     SET t.net_energy_value = ecdp_stream_item.getBOEInvertUnitValue(lv2_stream_item_id,
                                                                                     :new.daytime,
                                                                                     :new.net_qty,
                                                                                     t.energy_uom_code,
                                                                                     t.boe_from_uom_code,
                                                                                     :new.uom,
                                                                                     t.boe_factor),
                         t.last_updated_by  = 'INTERNAL'
                   WHERE t.object_id = lv2_stream_item_id
                     AND t.forecast_id = :new.object_id
                     and t.daytime = :new.daytime;

           END IF;
            END IF;

            -- The code bellow is to synchronize data between STIM_FCST table and FCST tables
            IF (:New.last_updated_by <> 'INTERNAL') THEN
                -- Force cascade update
                INSERT INTO stim_cascade (object_id, period, daytime, forecast_id, last_updated_by) VALUES
                 (lv2_stream_item_id, 'FCST_MTH', :New.DAYTIME, :New.OBJECT_ID, 'INTERNAL');
            END IF;

        END IF; -- Stream Item

    END IF; -- NET_QTY or UOM

	END IF; -- QTY FCST

END IU_FCST_MTH_STATUS;
