-- Purpose of script : It will migrate data from Equipment Downtime tab on Deferment screen(PD.0020) to Equipment Downtime (PD.0022)
-- Created  : 01-JUL-2017  (Gaurav Chaudhary)
--
-- Modification history:
-- Date         Whom      Change description:
-- ----         -----     -----------------------------------
-- 01-JUL-2017  chaudgau  Initial Version
--

-- PL/SQL Block : For data upgrade from Equipment Downtime tab on Deferment screen(PD.0020) to Equipment Downtime (PD.0022)
-- EC Code for downtime_class_type will be considered as EQPM_DT


-- Cursor Declaration
-- Pull data for D/T Type Group, Single and Group child
-- Move data for parent data section with new event_no and use it to migrate child data section data, along with updation of parent_event_no
-- EC Ccode Data from downtime_type will be moved to equip_downtime.downtime_class_type column
-- Production day and end day will be generated for each record
 
BEGIN

    INSERT INTO equip_downtime
        (
            object_id, object_type, master_event_id
          , parent_event_no, parent_daytime, parent_object_id
          , downtime_class_type, daytime, end_date, day, end_day
          , reason_code_1, reason_code_2, reason_code_3, reason_code_4
          , comments
          , value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10
          , text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10
          , date_1, date_2, date_3, date_4, date_5
          , rev_text, record_status
        )
    SELECT
		   wd.object_id, wd.object_type, wd.master_event_id
		 , NULL parent_event_no, NULL parent_daytime, NULL parent_object_id
		 , 'EQPM_DT' downtime_type, wd.daytime, wd.end_date, wd.day, wd.end_day
		 , wd.reason_code_type_1, wd.reason_code_type_2, wd.reason_code_type_3, wd.reason_code_type_4
		 , wd.comments
		 , wd.value_1, wd.value_2, wd.value_3, wd.value_4, wd.value_5, wd.value_6, wd.value_7, wd.value_8, wd.value_9, wd.value_10
		 , wd.text_1, wd.text_2, wd.text_3, wd.text_4, wd.text_5, wd.text_6, wd.text_7, wd.text_8, wd.text_9, wd.text_10
		 , wd.date_1, wd.date_2, wd.date_3, wd.date_4, wd.date_5
		 , wd.rev_text, wd.record_status
	  FROM deferment_event wd
	  JOIN eqpm_version oa ON oa.object_id = wd.object_id
	 WHERE wd.deferment_type = 'SINGLE'
     AND wd.daytime >= oa.daytime
     AND (oa.end_date is NULL OR wd.daytime < oa.end_date);

  COMMIT;
END;
/