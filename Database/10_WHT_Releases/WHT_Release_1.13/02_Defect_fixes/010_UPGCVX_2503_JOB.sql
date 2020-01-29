BEGIN
    DBMS_SCHEDULER.drop_job(job_name => 'EC_BS_INST_NEW_DAY_START');
	DBMS_SCHEDULER.drop_job(job_name => 'EC_BS_INST_NEW_DAY_END');
	DBMS_SCHEDULER.drop_job(job_name => 'UE_BS_INST_NEW_DAY_END');
	DBMS_SCHEDULER.drop_job(job_name => 'AUTO_CLOSE_OLD_DT_EVENTS');
END;
/