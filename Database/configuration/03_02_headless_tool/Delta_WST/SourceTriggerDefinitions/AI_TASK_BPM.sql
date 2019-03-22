CREATE OR REPLACE EDITIONABLE TRIGGER "AI_TASK_BPM" 
AFTER INSERT ON TASK FOR EACH ROW
DECLARE
    result number;
    p_attributes T_BPM_TABLE_T_EVENT_ATTRIBUTE;
BEGIN
    IF :NEW.TASK_TYPE = 'CP_ERROR' OR :NEW.TASK_TYPE = 'CP_WARNING' THEN
        p_attributes := T_BPM_TABLE_T_EVENT_ATTRIBUTE();
        result := ecdp_bpm_ec_event_inbound.on_generic_event('refresh_cp_task', 'control_point', p_attributes);
    END IF;
END;
