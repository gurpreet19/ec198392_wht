
-- Block 2 : For data upgrade from well downtime screen to well deferment
DECLARE
-- Cursor Declaration
-- Pull data for D/T Type Group and Single
CURSOR c_parent_well_downtime_rec
IS
SELECT
       object_id, object_type, event_no, parent_event_no, downtime_type
       ,downtime_categ, daytime, end_date, downtime_class_type, master_event_id
       ,parent_daytime, parent_master_event_id, parent_object_id
       ,reason_code_1, reason_code_2, reason_code_3, reason_code_4
       ,cond_loss_rate, cond_loss_volume, gas_loss_rate, gas_loss_volume, gas_inj_loss_rate
       ,gas_inj_loss_volume, oil_loss_rate, oil_loss_volume, steam_inj_loss_rate, steam_inj_loss_volume
       ,water_inj_loss_rate, water_inj_loss_volume, water_loss_rate, water_loss_volume, status
       ,equipment_id, comments, value_1, value_2, value_3, value_4, value_5
       ,value_6, value_7, value_8, value_9, value_10, text_1, text_2
       ,text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, date_1, date_2
       ,date_3, date_4, date_5, rev_text
  FROM deferment_event wd
 WHERE (wd.downtime_categ='WELL_OFF' AND wd.downtime_class_type IN ('GROUP','SINGLE'));

-- Pull data for D/T Type Group Child
CURSOR c_child_well_downtime_rec(pn_parent_event_no NUMBER)
IS
SELECT
       object_id, object_type, event_no, parent_event_no, downtime_type
       ,downtime_categ, daytime, end_date, downtime_class_type, master_event_id
       ,parent_daytime, parent_master_event_id, parent_object_id
       ,reason_code_1, reason_code_2, reason_code_3, reason_code_4
       ,cond_loss_rate, cond_loss_volume, gas_loss_rate, gas_loss_volume, gas_inj_loss_rate
       ,gas_inj_loss_volume, oil_loss_rate, oil_loss_volume, steam_inj_loss_rate, steam_inj_loss_volume
       ,water_inj_loss_rate, water_inj_loss_volume, water_loss_rate, water_loss_volume, status
       ,equipment_id, comments, value_1, value_2, value_3, value_4, value_5
       ,value_6, value_7, value_8, value_9, value_10, text_1, text_2
       ,text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, date_1, date_2
       ,date_3, date_4, date_5, rev_text
  FROM deferment_event wd
 WHERE wd.downtime_categ='WELL_OFF'
   AND wd.downtime_class_type = 'GROUP_CHILD'
   AND parent_event_no = pn_parent_event_no;

-- Local variable declaration
ln_event_no well_deferment.event_no%TYPE;

BEGIN

  FOR cpr IN c_parent_well_downtime_rec
  LOOP
    INSERT INTO well_deferment
        (
            object_id, object_type, parent_event_no, event_type, deferment_type, scheduled
          , daytime, end_date, master_event_id, parent_daytime, parent_master_event_id, parent_object_id
          , reason_code_1, reason_code_2, reason_code_3, reason_code_4
          , cond_loss_rate, cond_loss_volume
          , gas_loss_rate, gas_loss_volume, gas_inj_loss_rate, gas_inj_loss_volume
          , oil_loss_rate, oil_loss_volume, steam_inj_loss_rate
          , steam_inj_loss_volume, water_inj_loss_rate
          , water_inj_loss_volume, water_loss_rate, water_loss_volume, status
          , comments, value_1, value_2, value_3
          , value_4, value_5, value_6, value_7, value_8, value_9
          , value_10, text_1, text_2, text_3, text_4, text_5, text_6
          , text_7, text_8, text_9
          , text_10, date_1, date_2, date_3, date_4, date_5
          , reason_code_type_1 , reason_code_type_2, reason_code_type_3, reason_code_type_4
          , rev_text, equipment_id
        )
    VALUES
        (
            cpr.object_id, cpr.object_type, NULL, 'DOWN', cpr.downtime_class_type, 'N'
          , cpr.daytime, cpr.end_date, cpr.master_event_id, NULL, NULL, NULL
          , UPPER(TRIM(cpr.reason_code_1)),  UPPER(TRIM(cpr.reason_code_2)), UPPER(TRIM(cpr.reason_code_3)), UPPER(TRIM(cpr.reason_code_4))
          , cpr.cond_loss_rate, cpr.cond_loss_volume
          , cpr.gas_loss_rate, cpr.gas_loss_volume, cpr.gas_inj_loss_rate, cpr.gas_inj_loss_volume
          , cpr.oil_loss_rate, cpr.oil_loss_volume, cpr.steam_inj_loss_rate
          , cpr.steam_inj_loss_volume, cpr.water_inj_loss_rate
          , cpr.water_inj_loss_volume, cpr.water_loss_rate, cpr.water_loss_volume, cpr.status
          , cpr.comments, cpr.value_1, cpr.value_2, cpr.value_3
          , cpr.value_4, cpr.value_5, cpr.value_6, cpr.value_7, cpr.value_8, cpr.value_9
          , cpr.value_10, cpr.text_1, cpr.text_2, cpr.text_3, cpr.text_4, cpr.text_5, cpr.text_6
          , cpr.text_7, cpr.text_8, cpr.text_9
          , cpr.text_10, cpr.date_1, cpr.date_2, cpr.date_3, cpr.date_4, cpr.date_5
          , NVL2(cpr.reason_code_1,'WELL_DT_REAS_1',NULL), NVL2(cpr.reason_code_2,'WELL_DT_REAS_2',NULL)
          , NVL2(cpr.reason_code_3,'WELL_DT_REAS_3',NULL), NVL2(cpr.reason_code_4,'WELL_DT_REAS_4',NULL)
          , cpr.rev_text, cpr.equipment_id
        ) RETURNING event_no INTO ln_event_no;

    IF cpr.downtime_class_type <> 'SINGLE' THEN

        FOR ccr IN c_child_well_downtime_rec(cpr.event_no)
        LOOP

          INSERT INTO well_deferment
              (
                  object_id, object_type, parent_event_no, event_type, deferment_type, scheduled
                , daytime, end_date, master_event_id, parent_daytime, parent_master_event_id, parent_object_id
                , reason_code_1, reason_code_2, reason_code_3, reason_code_4
                , cond_loss_rate, cond_loss_volume
                , gas_loss_rate, gas_loss_volume, gas_inj_loss_rate, gas_inj_loss_volume
                , oil_loss_rate, oil_loss_volume, steam_inj_loss_rate
                , steam_inj_loss_volume, water_inj_loss_rate
                , water_inj_loss_volume, water_loss_rate, water_loss_volume, status
                , comments, value_1, value_2, value_3
                , value_4, value_5, value_6, value_7, value_8, value_9
                , value_10, text_1, text_2, text_3, text_4, text_5, text_6
                , text_7, text_8, text_9
                , text_10, date_1, date_2, date_3, date_4, date_5
                , reason_code_type_1 , reason_code_type_2, reason_code_type_3, reason_code_type_4
                , rev_text, equipment_id
              )
          VALUES
              (
                  ccr.object_id, ccr.object_type, ln_event_no, 'DOWN', ccr.downtime_class_type, 'N'
                , ccr.daytime, ccr.end_date, ccr.master_event_id, ccr.parent_daytime, ccr.parent_master_event_id, ccr.parent_object_id
                , UPPER(TRIM(ccr.reason_code_1)),  UPPER(TRIM(ccr.reason_code_2)), UPPER(TRIM(ccr.reason_code_3)), UPPER(TRIM(ccr.reason_code_4))
                , ccr.cond_loss_rate, ccr.cond_loss_volume
                , ccr.gas_loss_rate, ccr.gas_loss_volume, ccr.gas_inj_loss_rate, ccr.gas_inj_loss_volume
                , ccr.oil_loss_rate, ccr.oil_loss_volume, ccr.steam_inj_loss_rate
                , ccr.steam_inj_loss_volume, ccr.water_inj_loss_rate
                , ccr.water_inj_loss_volume, ccr.water_loss_rate, ccr.water_loss_volume, ccr.status
                , ccr.comments, ccr.value_1, ccr.value_2, ccr.value_3
                , ccr.value_4, ccr.value_5, ccr.value_6, ccr.value_7, ccr.value_8, ccr.value_9
                , ccr.value_10, ccr.text_1, ccr.text_2, ccr.text_3, ccr.text_4, ccr.text_5, ccr.text_6
                , ccr.text_7, ccr.text_8, ccr.text_9
                , ccr.text_10, ccr.date_1, ccr.date_2, ccr.date_3, ccr.date_4, ccr.date_5
                , NVL2(ccr.reason_code_1,'WELL_DT_REAS_1',NULL), NVL2(ccr.reason_code_2,'WELL_DT_REAS_2',NULL)
                , NVL2(ccr.reason_code_3,'WELL_DT_REAS_3',NULL), NVL2(ccr.reason_code_4,'WELL_DT_REAS_4',NULL)
                , ccr.rev_text, ccr.equipment_id
              );
        END LOOP;
    END IF;
  END LOOP;
  COMMIT;
END;


