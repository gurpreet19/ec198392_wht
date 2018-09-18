DECLARE 
	 sqlQuery clob:='COMMENT ON TABLE STOR_FCST_SUBDAY_NOM_SUM IS ''This table is created with the intention of performance improvement of storage level , This table will hold the single record for STOR_FCST_SUB_DAY_LIFT_NOM and queries running in packages for retrival of storage level will refer to this STOR_FCST_SUBDAY_NOM_SUM table to avoid group function like SUM. This table is not to be modified''';
BEGIN
     EXECUTE IMMEDIATE sqlQuery;
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     EXCEPTION     
         WHEN OTHERS THEN
            --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
            raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm);
END;
--~^UTDELIM^~--
