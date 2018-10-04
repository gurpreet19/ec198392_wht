CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_SPLIT_KEY_SETUP" ("OBJECT_ID", "DAYTIME", "OBJECT_DATE_IND", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- File name: v_split_key_setup.sql
-- View name: v_split_key_setup
--
-- $Revision: 1.2 $
--
-- Purpose  : This view is used by split share business functions to retrieve a date to put a valid share on.
--
-- Modification history:
--
-- Version  Date        Whom    Change description:
-----------------------------------------------------------------------------------------------------------------------------------
--         15.12.2008 SSK   Initial version
-----------------------------------------------------------------------------------------------------------------------------------
select sks.object_id,
       sks.daytime,
       'N' object_date_ind,
       sks.record_status,
       sks.created_by,
       sks.created_date,
       sks.last_updated_by,
       sks.last_updated_date,
       sks.rev_no,
       sks.rev_text
  from split_key_setup sks
union
select sk.object_id,
       sk.start_date daytime,
       'Y' object_date_ind,
       sk.record_status,
       sk.created_by,
       sk.created_date,
       sk.last_updated_by,
       sk.last_updated_date,
       sk.rev_no,
       sk.rev_text
  from split_key sk
)