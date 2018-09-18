CREATE OR REPLACE TRIGGER "IUD_V_SCHEDULE" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON v_schedule
FOR EACH ROW
-- $Revision: 1.1.28.2 $
BEGIN

    IF INSERTING THEN
        INSERT INTO schedule(
             NAME
            ,SCHEDULE_NO
            ,SCHEDULE_GROUP
            ,RUN_AS_USER
            ,NOTIFY_ROLE
            ,LOG_LEVEL
            ,RETAIN_COUNT
            ,IGNORE_MISFIRE
            ,PIN_TO
            ,ENABLED_IND
            ,DESCRIPTION
            ,SCHEDULE_TYPE
            ,RECORD_STATUS
            ,CREATED_BY
            ,CREATED_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATED_DATE
            ,REV_NO
            ,REV_TEXT
            ,APPROVAL_STATE
            ,APPROVAL_BY
            ,APPROVAL_DATE
            ,REC_ID
           ) VALUES (
             :New.NAME
            ,:New.SCHEDULE_NO
            ,:New.SCHEDULE_GROUP
            ,:New.RUN_AS_USER
            ,:New.NOTIFY_ROLE
            ,:New.LOG_LEVEL
            ,:New.RETAIN_COUNT
            ,:New.IGNORE_MISFIRE
            ,:New.PIN_TO
            ,:New.ENABLED_IND
            ,:New.DESCRIPTION
            ,:New.SCHEDULE_TYPE
            ,:New.RECORD_STATUS
            ,:New.CREATED_BY
            ,:New.CREATED_DATE
            ,:New.LAST_UPDATED_BY
            ,:New.LAST_UPDATED_DATE
            ,:New.REV_NO
            ,:New.REV_TEXT
            ,:New.APPROVAL_STATE
            ,:New.APPROVAL_BY
            ,:New.APPROVAL_DATE
            ,:New.REC_ID
           );

    ELSIF DELETING THEN

        DELETE FROM schedule WHERE SCHEDULE_NO = :old.SCHEDULE_NO;

    END IF;

END;

