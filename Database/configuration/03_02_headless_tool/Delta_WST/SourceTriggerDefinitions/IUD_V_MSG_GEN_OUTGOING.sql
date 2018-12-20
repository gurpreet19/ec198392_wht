CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_MSG_GEN_OUTGOING" 
INSTEAD OF INSERT OR UPDATE OR DELETE ON V_MSG_GEN_OUTGOING
FOR EACH ROW
BEGIN

    IF INSERTING THEN

        INSERT INTO MESSAGE_GROUP_CONN(
             MESSAGE_DISTRIBUTION_NO
            ,MESSAGE_GROUP_ID
            ,CREATED_BY
           ) VALUES (
             :NEW.MESSAGE_DISTRIBUTION_NO
            ,:NEW.MESSAGE_GROUP_ID
            ,:NEW.CREATED_BY
           );

    ELSIF DELETING THEN

        DELETE FROM MESSAGE_GROUP_CONN
         WHERE MESSAGE_GROUP_ID = :OLD.MESSAGE_GROUP_ID
           AND MESSAGE_DISTRIBUTION_NO = :OLD.MESSAGE_DISTRIBUTION_NO;

    END IF;

END;