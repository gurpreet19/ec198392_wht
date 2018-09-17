CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_TRANS_CONFIG" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON v_trans_config
FOR EACH ROW
-- $Revision: 1.6 $
DECLARE
-- Variables for storing temporary values
lv2_mapping_no              trans_mapping.mapping_no%TYPE;
lv2_template_no             trans_template.template_no%TYPE;
lv2_template_code           trans_template.template_code%TYPE;
lv2_source_id               trans_mapping.source_id%TYPE;
lv2_tag_id                  trans_mapping.tag_id%TYPE;
lv2_from_unit               trans_mapping.from_unit%TYPE;
lv2_to_unit                 trans_mapping.to_unit%TYPE;
lv2_data_class              trans_mapping.data_class%TYPE;
lv2_attribute               trans_mapping.attribute%TYPE;
lv2_pk_attr_1               trans_mapping.pk_attr_1%TYPE;
lv2_pk_val_1                trans_mapping.pk_val_1%TYPE;
lv2_pk_attr_2               trans_mapping.pk_attr_2%TYPE;
lv2_pk_val_2                trans_mapping.pk_val_2%TYPE;
lv2_pk_attr_3               trans_mapping.pk_attr_3%TYPE;
lv2_pk_val_3                trans_mapping.pk_val_3%TYPE;
lv2_pk_attr_4               trans_mapping.pk_attr_4%TYPE;
lv2_pk_val_4                trans_mapping.pk_val_4%TYPE;
lv2_pk_attr_5               trans_mapping.pk_attr_5%TYPE;
lv2_pk_val_5                trans_mapping.pk_val_5%TYPE;
lv2_pk_attr_6               trans_mapping.pk_attr_6%TYPE;
lv2_pk_val_6                trans_mapping.pk_val_6%TYPE;
lv2_pk_attr_7               trans_mapping.pk_attr_7%TYPE;
lv2_pk_val_7                trans_mapping.pk_val_7%TYPE;
lv2_pk_attr_8               trans_mapping.pk_attr_8%TYPE;
lv2_pk_val_8                trans_mapping.pk_val_8%TYPE;
lv2_pk_attr_9               trans_mapping.pk_attr_9%TYPE;
lv2_pk_val_9                trans_mapping.pk_val_9%TYPE;
lv2_pk_attr_10              trans_mapping.pk_attr_10%TYPE;
lv2_pk_val_10               trans_mapping.pk_val_10%TYPE;
lv2_active                  trans_mapping.active%TYPE;
lv2_description             trans_mapping.description%TYPE;
ld_last_transfer            trans_target_time.last_transfer%TYPE;
ld_last_transfer_write      trans_target_time.last_transfer_write%TYPE;
lv2_force_read              trans_target_time.force_read%TYPE;
lv2_record_status           trans_mapping.record_status%TYPE;
lv2_created_by              trans_mapping.created_by%TYPE;
lv2_created_date            trans_mapping.created_date%TYPE;
lv2_last_updated_by         trans_mapping.last_updated_by%TYPE;
lv2_last_updated_date       trans_mapping.last_updated_date%TYPE;
lv2_rev_no                  trans_mapping.rev_no%TYPE;
lv2_rev_text                trans_mapping.rev_text%TYPE;
lv2_from_time               trans_mapping.from_time%TYPE;
lv2_to_time                 trans_mapping.to_time%TYPE;

BEGIN

IF INSERTING THEN
  ld_last_transfer          := Nvl(:New.last_transfer,trunc(Ecdp_Timestamp.getCurrentSysdate));
  lv2_force_read            := 'Y';
END IF;

IF DELETING OR UPDATING THEN

  --lv2_rev_text := Nvl(:New.rev_text,'Modified by IUD trigger - no revision text was given');

  SELECT last_transfer, last_transfer_write, force_read
    INTO ld_last_transfer, ld_last_transfer_write, lv2_force_read
    FROM trans_target_time
   WHERE target_tagid = :Old.tag_id;

  IF UPDATING ('LAST_TRANSFER') THEN
		ld_last_transfer := Nvl(:New.last_transfer, :Old.last_transfer);
    lv2_force_read := 'Y';
  END IF;

END IF;

-- If inserting or updating, then generate values for new mapping
IF INSERTING OR UPDATING THEN
  lv2_mapping_no            := :New.mapping_no;
  lv2_template_no           := :New.template_no;
  lv2_template_code         := :New.template_code;
  lv2_source_id             := :New.source_id;
  lv2_tag_id                := :New.tag_id;
  lv2_from_unit             := :New.from_unit;
  lv2_to_unit               := :New.to_unit;
  lv2_data_class            := :New.data_class;
  lv2_attribute             := :New.attribute;
  lv2_pk_attr_1             := :New.pk_attr_1;
  lv2_pk_val_1              := :New.pk_val_1;
  lv2_pk_attr_2             := :New.pk_attr_2;
  lv2_pk_val_2              := :New.pk_val_2;
  lv2_pk_attr_3             := :New.pk_attr_3;
  lv2_pk_val_3              := :New.pk_val_3;
  lv2_pk_attr_4             := :New.pk_attr_4;
  lv2_pk_val_4              := :New.pk_val_4;
  lv2_pk_attr_5             := :New.pk_attr_5;
  lv2_pk_val_5              := :New.pk_val_5;
  lv2_pk_attr_6             := :New.pk_attr_6;
  lv2_pk_val_6              := :New.pk_val_6;
  lv2_pk_attr_7             := :New.pk_attr_7;
  lv2_pk_val_7              := :New.pk_val_7;
  lv2_pk_attr_8             := :New.pk_attr_8;
  lv2_pk_val_8              := :New.pk_val_8;
  lv2_pk_attr_9             := :New.pk_attr_9;
  lv2_pk_val_9              := :New.pk_val_9;
  lv2_pk_attr_10            := :New.pk_attr_10;
  lv2_pk_val_10             := :New.pk_val_10;
  lv2_active                := :New.active;
  lv2_description           := :New.description;
  lv2_record_status         := :New.record_status;
  lv2_created_by            := :New.created_by;
  lv2_created_date          := :New.created_date;
  lv2_last_updated_by       := :New.last_updated_by;
  lv2_last_updated_date     := :New.last_updated_date;
  lv2_rev_no                := :New.rev_no;
  lv2_rev_text              := :New.rev_text;
  lv2_from_time             := :New.from_time;
  lv2_to_time               := :New.to_time;

  IF (lv2_template_no IS NULL) OR (lv2_template_code <> :Old.template_code) THEN
  	SELECT template_no INTO lv2_template_no
      FROM trans_template t
     WHERE t.template_code = lv2_template_code;
  END IF;

END IF;

-- Delete section
IF DELETING THEN

	DELETE FROM trans_target_time
   WHERE target_tagid = :Old.tag_id;

	DELETE FROM trans_mapping
   WHERE tag_id = :Old.tag_id;

END IF;

-- Update section
IF UPDATING THEN

  IF lv2_last_updated_by is NULL THEN
    lv2_last_updated_by := User;
  END IF;
  IF lv2_last_updated_date is NULL THEN
    lv2_last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
  END IF;

  -- Only update OV_TRANS_MAPPING if something apart from last_transfer has changed
  -- (We don't won't journal logging of mapping if only last_transfer is updated)
  IF Nvl(lv2_mapping_no,-999999999) <> Nvl(:Old.mapping_no,-999999999)
  	OR Nvl(lv2_template_no,-999999999) <> Nvl(:Old.template_no,-999999999)
  	OR Nvl(:New.source_id,'Dummy') <> Nvl(:Old.source_id,'Dummy')
  	OR Nvl(:New.tag_id,'Dummy') <> Nvl(:Old.tag_id,'Dummy')
  	OR Nvl(:New.from_unit,'Dummy') <> Nvl(:Old.from_unit,'Dummy')
  	OR Nvl(:New.to_unit,'Dummy') <> Nvl(:Old.to_unit,'Dummy')
  	OR Nvl(:New.data_class,'Dummy') <> Nvl(:Old.data_class,'Dummy')
  	OR Nvl(:New.attribute,'Dummy') <> Nvl(:Old.attribute,'Dummy')
  	OR Nvl(:New.pk_attr_1,'Dummy') <> Nvl(:Old.pk_attr_1,'Dummy')
  	OR Nvl(:New.pk_val_1,'Dummy') <> Nvl(:Old.pk_val_1,'Dummy')
  	OR Nvl(:New.pk_attr_2,'Dummy') <> Nvl(:Old.pk_attr_2,'Dummy')
  	OR Nvl(:New.pk_val_2,'Dummy') <> Nvl(:Old.pk_val_2,'Dummy')
  	OR Nvl(:New.pk_attr_3,'Dummy') <> Nvl(:Old.pk_attr_3,'Dummy')
  	OR Nvl(:New.pk_val_3,'Dummy') <> Nvl(:Old.pk_val_3,'Dummy')
  	OR Nvl(:New.pk_attr_4,'Dummy') <> Nvl(:Old.pk_attr_4,'Dummy')
  	OR Nvl(:New.pk_val_4,'Dummy') <> Nvl(:Old.pk_val_4,'Dummy')
  	OR Nvl(:New.pk_attr_5,'Dummy') <> Nvl(:Old.pk_attr_5,'Dummy')
  	OR Nvl(:New.pk_val_5,'Dummy') <> Nvl(:Old.pk_val_5,'Dummy')
  	OR Nvl(:New.pk_attr_6,'Dummy') <> Nvl(:Old.pk_attr_6,'Dummy')
  	OR Nvl(:New.pk_val_6,'Dummy') <> Nvl(:Old.pk_val_6,'Dummy')
  	OR Nvl(:New.pk_attr_7,'Dummy') <> Nvl(:Old.pk_attr_7,'Dummy')
  	OR Nvl(:New.pk_val_7,'Dummy') <> Nvl(:Old.pk_val_7,'Dummy')
  	OR Nvl(:New.pk_attr_8,'Dummy') <> Nvl(:Old.pk_attr_8,'Dummy')
  	OR Nvl(:New.pk_val_8,'Dummy') <> Nvl(:Old.pk_val_8,'Dummy')
  	OR Nvl(:New.pk_attr_9,'Dummy') <> Nvl(:Old.pk_attr_9,'Dummy')
  	OR Nvl(:New.pk_val_9,'Dummy') <> Nvl(:Old.pk_val_9,'Dummy')
  	OR Nvl(:New.pk_attr_10,'Dummy') <> Nvl(:Old.pk_attr_10,'Dummy')
  	OR Nvl(:New.pk_val_10,'Dummy') <> Nvl(:Old.pk_val_10,'Dummy')
  	OR Nvl(:New.active,'Dummy') <> Nvl(:Old.active,'Dummy')
  	OR Nvl(:New.description,'Dummy') <> Nvl(:Old.description,'Dummy')
	OR Nvl(:New.to_time,to_date('1970-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')) <> Nvl(:Old.to_time,to_date('1970-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'))
	OR Nvl(:New.from_time,to_date('1970-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')) <> Nvl(:Old.from_time,to_date('1970-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')) THEN

    	UPDATE trans_mapping
         SET mapping_no = lv2_mapping_no,
             template_no = lv2_template_no,
             source_id = lv2_source_id,
             tag_id = lv2_tag_id,
             from_unit = lv2_from_unit,
             to_unit = lv2_to_unit,
             data_class = lv2_data_class,
             attribute = lv2_attribute,
             pk_attr_1 = lv2_pk_attr_1,
             pk_val_1 = lv2_pk_val_1,
             pk_attr_2 = lv2_pk_attr_2,
             pk_val_2 = lv2_pk_val_2,
             pk_attr_3 = lv2_pk_attr_3,
             pk_val_3 = lv2_pk_val_3,
             pk_attr_4 = lv2_pk_attr_4,
             pk_val_4 = lv2_pk_val_4,
             pk_attr_5 = lv2_pk_attr_5,
             pk_val_5 = lv2_pk_val_5,
             pk_attr_6 = lv2_pk_attr_6,
             pk_val_6 = lv2_pk_val_6,
             pk_attr_7 = lv2_pk_attr_7,
             pk_val_7 = lv2_pk_val_7,
             pk_attr_8 = lv2_pk_attr_8,
             pk_val_8 = lv2_pk_val_8,
             pk_attr_9 = lv2_pk_attr_9,
             pk_val_9 = lv2_pk_val_9,
             pk_attr_10 = lv2_pk_attr_10,
             pk_val_10 = lv2_pk_val_10,
             active = lv2_active,
             description = lv2_description,
             record_status = lv2_record_status,
             created_by = lv2_created_by,
             created_date = lv2_created_date,
             last_updated_by = lv2_last_updated_by,
             last_updated_date = lv2_last_updated_date,
             rev_no = nvl(rev_no,0) + 1,
             rev_text = lv2_rev_text,
             from_time = lv2_from_time,
             to_time = lv2_to_time
       WHERE mapping_no = :Old.mapping_no;

  ELSIF :New.last_transfer <> :Old.last_transfer THEN
    -- If last_Transfer is updated, then we must also make sure that last_updated_date of this mapping is updated
    -- This way the TagCollector is automatically restarted.
    -- To achive this, we do a dummy configuration change.
    UPDATE trans_mapping
       SET last_updated_by = lv2_last_updated_by
     WHERE mapping_no = lv2_mapping_no;

  END IF;

  -- TRANS_TARGET_TIME is always updated.
  UPDATE trans_target_time
     SET target_tagid = lv2_tag_id,
         last_transfer = ld_last_transfer,
         force_read = lv2_force_read
   WHERE target_tagid = :Old.tag_id;

END IF;


-- Insert section
IF INSERTING THEN
  INSERT INTO trans_mapping (
         mapping_no,
         template_no,
         source_id,
         tag_id,
         from_unit,
         to_unit,
         data_class,
         attribute,
         pk_attr_1,
         pk_val_1,
         pk_attr_2,
         pk_val_2,
         pk_attr_3,
         pk_val_3,
         pk_attr_4,
         pk_val_4,
         pk_attr_5,
         pk_val_5,
         pk_attr_6,
         pk_val_6,
         pk_attr_7,
         pk_val_7,
         pk_attr_8,
         pk_val_8,
         pk_attr_9,
         pk_val_9,
         pk_attr_10,
         pk_val_10,
         active,
         description,
         record_status,
         created_by,
         created_date,
         last_updated_by,
         last_updated_date,
         rev_no,
         rev_text,
		 from_time,
		 to_time
  )
  VALUES (
         lv2_mapping_no,
         lv2_template_no,
         lv2_source_id,
         lv2_tag_id,
         lv2_from_unit,
         lv2_to_unit,
         lv2_data_class,
         lv2_attribute,
         lv2_pk_attr_1,
         lv2_pk_val_1,
         lv2_pk_attr_2,
         lv2_pk_val_2,
         lv2_pk_attr_3,
         lv2_pk_val_3,
         lv2_pk_attr_4,
         lv2_pk_val_4,
         lv2_pk_attr_5,
         lv2_pk_val_5,
         lv2_pk_attr_6,
         lv2_pk_val_6,
         lv2_pk_attr_7,
         lv2_pk_val_7,
         lv2_pk_attr_8,
         lv2_pk_val_8,
         lv2_pk_attr_9,
         lv2_pk_val_9,
         lv2_pk_attr_10,
         lv2_pk_val_10,
         lv2_active,
         lv2_description,
         lv2_record_status,
         lv2_created_by,
         lv2_created_date,
         lv2_last_updated_by,
         lv2_last_updated_date,
         lv2_rev_no,
         lv2_rev_text,
		 lv2_from_time,
		 lv2_to_time
  ) RETURNING tag_id INTO lv2_tag_id;

  INSERT INTO trans_target_time (
--  	sysnam,
    target_tagid,
    last_transfer,
    force_read
  )
  VALUES (
--  	'EC',
    lv2_tag_id,
    ld_last_transfer,
    lv2_force_read
  );
END IF;

END;
