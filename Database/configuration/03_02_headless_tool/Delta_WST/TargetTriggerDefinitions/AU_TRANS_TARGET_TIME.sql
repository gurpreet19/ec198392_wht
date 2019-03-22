CREATE OR REPLACE TRIGGER "AU_TRANS_TARGET_TIME" 
AFTER UPDATE ON TRANS_TARGET_TIME
FOR EACH ROW

DECLARE
  CURSOR c_mapping IS
  SELECT t.prod_day_start, t.target_interval, m.source_id,
         m.tag_id,m.pk_attr_1,m.pk_val_1,m.pk_attr_2,m.pk_val_2,
         m.pk_attr_3,m.pk_val_3,m.pk_attr_4,m.pk_val_4,m.pk_attr_5,m.pk_val_5,
		 m.pk_attr_6,m.pk_val_6,m.pk_attr_7,m.pk_val_7,m.pk_attr_8,m.pk_val_8,
		 m.pk_attr_9,m.pk_val_9,m.pk_attr_10,m.pk_val_10
  FROM  trans_template t, trans_mapping m
  WHERE t.template_no = m.template_no
  AND   m.tag_id = :old.target_tagid;

  ln_prodday_offset NUMBER;
  ln_target_interval NUMBER;
  lv2_source_id      trans_mapping.source_id%TYPE;
  lb_is_systemuser   BOOLEAN := FALSE;
  lv2_user           VARCHAR2(100); --T_basis_user.user_id%TYPE;
  ln_pos             NUMBER;
  ld_next_read       DATE;

BEGIN

    lv2_user := Nvl(:NEW.LAST_UPDATED_BY,:NEW.CREATED_BY);

    IF Nvl(lv2_user,'ecissystem') <> 'ecissystem' THEN
      -- Adjust NEXT READ if changed by other than ECIS

      ln_prodday_offset := 0;

        FOR cm IN c_mapping LOOP
            lv2_source_id  := cm.source_id;
            ln_prodday_offset  := Nvl(cm.prod_day_start,0);
            ln_target_interval := Nvl(cm.target_interval,0);

            ld_next_read := ecdp_ecishelper.calcnextread(cm.source_id, cm.tag_id,cm.pk_attr_1,cm.pk_val_1,cm.pk_attr_2,cm.pk_val_2,
                                                         cm.pk_attr_3,cm.pk_val_3,cm.pk_attr_4,cm.pk_val_4,cm.pk_attr_5,cm.pk_val_5,
														 cm.pk_attr_6,cm.pk_val_6,cm.pk_attr_7,cm.pk_val_7,cm.pk_attr_8,cm.pk_val_8,
														 cm.pk_attr_9,cm.pk_val_9,cm.pk_attr_10,cm.pk_val_10,
                                                         :NEW.last_transfer,cm.prod_day_start,cm.target_interval);

        END LOOP;





      UPDATE TRANS_SOURCE_TIME
      set next_read = ld_next_read,
          last_updated_by = 'TRIGGER'
      where source_id = lv2_source_id
      AND   tag_id = :new.target_tagid;

    END IF;
END;

