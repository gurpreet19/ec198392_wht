

UPDATE SYSTEM_MONTH SET LOCK_IND= (CASE WHEN (LOCK_IND='Y') THEN 'N' ELSE (NULL) END)  WHERE DAYTIME IN ('01-SEP-16','01-OCT-16','01-NOV-16','01-DEC-16','01-JAN-17','01-FEB-17','01-MAR-17','01-APR-17'
,'01-MAY-17','01-JUN-17','01-JUL-17','01-AUG-17','01-SEP-17','01-OCT-17','01-NOV-17','01-DEC-17','01-JAN-18'
,'01-FEB-18','01-MAR-18','01-APR-18','01-MAY-18','01-JUN-18','01-JUL-18','01-AUG-18','01-SEP-18','01-OCT-18','01-NOV-18','01-DEC-18'
,'01-JAN-19','01-FEB-19','01-MAR-19','01-APR-19','01-MAY-19','01-JUN-19','01-JUL-19','01-AUG-19','01-SEP-19','01-OCT-19','01-NOV-19','01-DEC-19');

BEGIN
  -- Update data for network_filter_id with corresponding well facility class 1 id
  UPDATE ov_perf_interval SET network_filter_id = ec_well_version.op_fcty_class_1_id(well_id,daytime,'<=');
  Commit;
END;
/

UPDATE SYSTEM_MONTH SET LOCK_IND= (CASE WHEN (LOCK_IND='N') THEN 'Y' ELSE (NULL) END)  WHERE DAYTIME IN ('01-SEP-16','01-OCT-16','01-NOV-16','01-DEC-16','01-JAN-17','01-FEB-17','01-MAR-17','01-APR-17'
,'01-MAY-17','01-JUN-17','01-JUL-17','01-AUG-17','01-SEP-17','01-OCT-17','01-NOV-17','01-DEC-17','01-JAN-18'
,'01-FEB-18','01-MAR-18','01-APR-18','01-MAY-18','01-JUN-18','01-JUL-18','01-AUG-18','01-SEP-18','01-OCT-18','01-NOV-18','01-DEC-18'
,'01-JAN-19','01-FEB-19','01-MAR-19','01-APR-19','01-MAY-19','01-JUN-19','01-JUL-19','01-AUG-19','01-SEP-19','01-OCT-19','01-NOV-19','01-DEC-19');

COMMIT;