CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRUCK_TICKET_FINDER" ("OBJECT_ID", "OBJECT_TYPE", "DAYTIME", "DATA_CLASS_NAME", "EVENT_NO", "BATCH_NO", "PRODUCTION_DAY", "TICKET_NUMBER", "NON_UNIQUE", "TRANSPORT_COMPANY", "TRANSPORT_VEHICLE", "TRANSFER_TYPE", "TO_OBJECT_ID", "TO_OBJECT_TYPE", "COMMENTS", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
------------------------------------------------------------------------------------
--  v_truck_ticket_finder
--
-- $Revision: 1.2 $
--
--  Purpose:   Get all data from OBJECT_TRANSPORT_EVENT, STRM_TRANSPORT_EVENT and WELL_TRANSPORT_EVENT.
--             Used in truck ticket finder screen
--  Note:
--
--  When           Who           Why
--  -------------- ------------ --------
--  12-JUL-2013   Mawaddah 		Used in Truck Ticket finder screen
--  22-FEB-2016   Gaurav        Update Transport_company field name to company_id
-------------------------------------------------------------------------------------
SELECT ote.OBJECT_ID,
		ote.OBJECT_TYPE,
		ote.DAYTIME,
		ote.DATA_CLASS_NAME,
		ote.EVENT_NO,
		ote.BATCH_NO,
		ote.PRODUCTION_DAY,
		ote.TICKET_NUMBER,
		ote.NON_UNIQUE,
		ote.COMPANY_ID TRANSPORT_COMPANY,
		ote.TRANSPORT_VEHICLE,
		ote.TRANSFER_TYPE,
		ote.TO_OBJECT_ID,
		ote.TO_OBJECT_TYPE,
		ote.COMMENTS,
		ote.TEXT_1,
		ote.TEXT_2,
		ote.TEXT_3,
		ote.TEXT_4,
		ote.RECORD_STATUS,
		ote.CREATED_BY,
		ote.CREATED_DATE,
		ote.LAST_UPDATED_BY,
		ote.LAST_UPDATED_DATE,
		ote.REV_NO,
		ote.REV_TEXT
FROM OBJECT_TRANSPORT_EVENT ote
UNION
SELECT ste.OBJECT_ID,
		'STREAM' AS OBJECT_TYPE,
		ste.DAYTIME,
		ste.DATA_CLASS_NAME,
		ste.EVENT_NO,
		ste.BATCH_NO,
		ste.PRODUCTION_DAY,
		ste.TICKET_NUMBER,
		ste.NON_UNIQUE,
		ste.COMPANY_ID,
		ste.TRANSPORT_VEHICLE,
		ste.TRANSFER_TYPE,
		ste.STREAM_ID AS TO_OBJECT_ID,
		'STREAM' AS TO_OBJECT_TYPE,
		ste.COMMENTS,
		ste.TEXT_1,
		ste.TEXT_2,
		ste.TEXT_3,
		ste.TEXT_4,
		ste.RECORD_STATUS,
		ste.CREATED_BY,
		ste.CREATED_DATE,
		ste.LAST_UPDATED_BY,
		ste.LAST_UPDATED_DATE,
		ste.REV_NO,
		ste.REV_TEXT
FROM STRM_TRANSPORT_EVENT ste
UNION
SELECT wte.OBJECT_ID,
		'WELL' AS OBJECT_TYPE,
		wte.DAYTIME,
		wte.DATA_CLASS_NAME,
		wte.EVENT_NO,
		NULL AS BATCH_NO,
		wte.PRODUCTION_DAY,
		wte.TICKET_NUMBER,
		NULL AS NON_UNIQUE,
		wte.TRANSPORT_COMPANY,
		wte.TRANSPORT_VEHICLE,
		NULL AS TRANSFER_TYPE,
		NULL AS TO_OBJECT_ID,
		NULL AS TO_OBJECT_TYPE,
		wte.COMMENTS,
		wte.TEXT_1,
		wte.TEXT_2,
		wte.TEXT_3,
		wte.TEXT_4,
		wte.RECORD_STATUS,
		wte.CREATED_BY,
		wte.CREATED_DATE,
		wte.LAST_UPDATED_BY,
		wte.LAST_UPDATED_DATE,
		wte.REV_NO,
		wte.REV_TEXT
FROM WELL_TRANSPORT_EVENT wte
)