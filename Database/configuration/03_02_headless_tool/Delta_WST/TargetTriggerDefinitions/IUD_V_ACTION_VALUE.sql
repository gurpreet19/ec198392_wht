CREATE OR REPLACE TRIGGER "IUD_V_ACTION_VALUE" 
  INSTEAD OF UPDATE ON V_ACTION_VALUE
  FOR EACH row

DECLARE
   lv2_operation char(3);
   lv2_last_updated_by VARCHAR2(30);
   ln_count NUMBER;
BEGIN

   SELECT count(*)
   INTO ln_count
   FROM action_instance_value
   WHERE action_instance_no = :old.action_instance_no
   AND action_parameter_no = :old.action_parameter_no;

IF (ln_count >= 1) THEN
  UPDATE action_instance_value
     SET parameter_value        = :New.parameter_value,
         record_status          = :New.record_status,
         created_by             = :New.created_by,
         created_date           = :New.created_date,
         last_updated_by        = :New.last_updated_by,
         last_updated_date      = :New.last_updated_date
   	WHERE ACTION_INSTANCE_NO    = :Old.ACTION_INSTANCE_NO
	AND action_parameter_no	= :Old.action_parameter_no;
ELSE
	INSERT INTO action_instance_value (
        action_instance_no,
        action_parameter_no,
        parameter_value,
        record_status,
        created_by,
        created_date,
        last_updated_by,
        last_updated_date
	)
	VALUES (
		:New.action_instance_no,
        :New.action_parameter_no,
        :New.parameter_value,
        :New.record_status,
        :New.created_by,
        :New.created_date,
        :New.last_updated_by,
        :New.last_updated_date
	);
END IF;

   IF (Nvl(:new.rev_no, 0) <> :old.rev_no) OR (Deleting) THEN
   IF Deleting THEN
     lv2_operation := 'DEL';
     lv2_last_updated_by := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
   ELSE
     lv2_operation := 'UPD';
     lv2_last_updated_by := :new.last_updated_by;
   END IF;
   	INSERT INTO v_action_value_JN
     (jn_operation, jn_oracle_user, jn_datetime, jn_notes
     ,ACTION_INSTANCE_NO,
     ACTION_PARAMETER_NO,
     NAME,
     PARAMETER_TYPE,
     PARAMETER_SUB_TYPE,
     PARAMETER_VALUE,
     DESCRIPTION,
     PARAMETER_STATIC_VALUE,
     MANDATORY_IND
       ,RECORD_STATUS
       ,CREATED_BY
       ,CREATED_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATED_DATE
       ,REV_NO
       ,REV_TEXT
)
   VALUES
      (lv2_operation, lv2_last_updated_by, EcDp_Date_Time.getCurrentSysdate, EcDp_User_Session.getUserSessionParameter('JN_NOTES')
     ,:old.ACTION_INSTANCE_NO,
     :old.ACTION_PARAMETER_NO,
     :old.NAME,
     :old.PARAMETER_TYPE,
     :old.PARAMETER_SUB_TYPE,
     :old.PARAMETER_VALUE,
     :old.DESCRIPTION,
     :old.PARAMETER_STATIC_VALUE,
     :old.MANDATORY_IND
       ,:old.RECORD_STATUS
       ,:old.CREATED_BY
       ,:old.CREATED_DATE
       ,:old.LAST_UPDATED_BY
       ,:old.LAST_UPDATED_DATE
       ,:old.REV_NO
       ,:old.REV_TEXT
);
END IF;

END iud_v_action_value;

