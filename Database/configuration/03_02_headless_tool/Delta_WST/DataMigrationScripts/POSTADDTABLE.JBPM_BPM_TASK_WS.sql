BEGIN
	INSERT INTO JBPM_BPM_TASK_WS(GLOBAL_ID, REF_JSON, STATE_DEFINITION, STATE, CORRELATION_GLOBAL_ID, CORRELATION_REF_JSON)
	SELECT GLOBAL_ID, REF_JSON, STATE_DEFINITION, STATE, CORRELATION_GLOBAL_ID, CORRELATION_REF_JSON
	FROM JBPM_BPM_TASK_STATE;
END;
--~^UTDELIM^~--

	