CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_QRTZ_TRIGGERS" 
  instead of UPDATE OR INSERT on v_qrtz_triggers
  for each ROW
-- $Revision: 1.2 $
BEGIN
   IF UPDATING THEN
        UPDATE qrtz_triggers SET
        SCHED_NAME = :NEW.SCHED_NAME,
        JOB_NAME = :NEW.JOB_NAME,
        JOB_GROUP = :NEW.JOB_GROUP,
        DESCRIPTION = :NEW.DESCRIPTION ,
        NEXT_FIRE_TIME = :NEW.NEXT_FIRE_TIME ,
        PREV_FIRE_TIME = :NEW.PREV_FIRE_TIME ,
        TRIGGER_STATE = decode(:NEW.TRIGGER_STATE, 	'PAUSED', TRIGGER_state,
													'PAUSED_BLOCKED', 'BLOCKED',
													:NEW.trigger_state), --else
        TRIGGER_TYPE = :NEW.TRIGGER_TYPE ,
        START_TIME = :NEW.START_TIME ,
        END_TIME = :NEW.END_TIME ,
        CALENDAR_NAME = :NEW.CALENDAR_NAME ,
        MISFIRE_INSTR = :NEW.MISFIRE_INSTR ,
        JOB_DATA = :NEW.JOB_DATA ,
        PRIORITY = :NEW.PRIORITY,
        RECORD_STATUS = :NEW.RECORD_STATUS ,
        CREATED_BY = :NEW.CREATED_BY ,
        CREATED_DATE = :NEW.CREATED_DATE ,
        LAST_UPDATED_BY = :NEW.LAST_UPDATED_BY ,
        LAST_UPDATED_DATE = :NEW.LAST_UPDATED_DATE ,
        REV_NO = :NEW.REV_NO ,
        REV_TEXT = :NEW.REV_TEXT
		WHERE trigger_name = :OLD.trigger_name
		AND trigger_group = :OLD.trigger_group;
	END IF;
	IF INSERTING THEN
		INSERT INTO qrtz_triggers ("SCHED_NAME","TRIGGER_NAME","TRIGGER_GROUP","JOB_NAME","JOB_GROUP","DESCRIPTION","NEXT_FIRE_TIME","PREV_FIRE_TIME",
            "TRIGGER_STATE", "TRIGGER_TYPE","START_TIME","END_TIME","CALENDAR_NAME","MISFIRE_INSTR","JOB_DATA","PRIORITY","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT")
            values (:new.SCHED_NAME, :new.TRIGGER_NAME, :new.TRIGGER_GROUP, :new.JOB_NAME, :new.JOB_GROUP,
			:new.DESCRIPTION, :new.NEXT_FIRE_TIME,
            :new.PREV_FIRE_TIME,
			decode(:NEW.TRIGGER_STATE, 'PAUSED', 'WAITING', 'PAUSED_BLOCKED', 'WAITING', :NEW.trigger_state),
			:new.TRIGGER_TYPE,
            :new.START_TIME, :new.END_TIME, :new.CALENDAR_NAME, :new.MISFIRE_INSTR,
            :new.JOB_DATA, :new.PRIORITY, :new.RECORD_STATUS, :new.CREATED_BY, :new.CREATED_DATE,
            :new.LAST_UPDATED_BY, :new.LAST_UPDATED_DATE, :new.REV_NO, :new.REV_TEXT);
	END IF;
END;
