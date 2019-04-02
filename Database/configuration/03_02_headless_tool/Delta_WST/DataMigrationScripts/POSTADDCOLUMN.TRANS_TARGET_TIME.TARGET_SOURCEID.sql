begin
    EXECUTE immediate 'ALTER PACKAGE ECDP_TIMESTAMP compile';
	EXECUTE immediate 'ALTER PACKAGE ECDP_TIMESTAMP compile body';
    EXECUTE immediate 'ALTER PACKAGE ECDP_DATE_TIME compile';
	EXECUTE immediate 'ALTER PACKAGE ECDP_DATE_TIME compile body';
    EXCEPTION
		WHEN OTHERS THEN
		NULL;      
END;
--~^UTDELIM^~--

begin  
	UPDATE TRANS_TARGET_TIME TT SET TT.TARGET_SOURCEID = (SELECT SOURCE_ID FROM TRANS_MAPPING TM WHERE TM.TAG_ID = TT.TARGET_TAGID),
	last_updated_by = last_updated_by,
	last_updated_date = last_updated_date
	where TT.TARGET_SOURCEID is null;
END;
--~^UTDELIM^~--