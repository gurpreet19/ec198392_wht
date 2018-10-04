CREATE OR REPLACE FORCE VIEW "V_SCHEDULE" ("SCHEDULE_NO", "NAME", "SCHEDULE_GROUP", "RUN_AS_USER", "NOTIFY_ROLE", "LOG_LEVEL", "RETAIN_COUNT", "IGNORE_MISFIRE", "PIN_TO", "ENABLED_IND", "DESCRIPTION", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID", "SCHEDULE_TYPE") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_schedule.sql
-- View name: v_schedule
--
-- $Revision: 1.1.28.3 $
--
-- Purpose  : Listing all schedules grouped by truncated name. If schedule name has the format <name>.<object_id>.<AUTOGEN>
--	      then ".<object_id>.<AUTOGEN>" part is removed.
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 2010-03-25 rouhamaj	initial version.
----------------------------------------------------------------------------------------------------
SELECT ss.schedule_no
       ,ecdp_scheduler.getuniquename(ss.name) name
       ,ss.schedule_group
       ,ss.run_as_user
       ,ss.notify_role
       ,ss.log_level
       ,ss.retain_count
       ,ss.ignore_misfire
       ,ss.pin_to
       ,ss.enabled_ind
       ,ss.description
       ,ss.record_status
       ,ss.created_by
       ,ss.created_date
       ,ss.last_updated_by
       ,ss.last_updated_date
       ,ss.rev_no
       ,ss.rev_text
       ,ss.approval_state
       ,ss.approval_by
       ,ss.approval_date
       ,ss.rec_id
       ,ss.schedule_type
FROM schedule ss WHERE ss.schedule_no IN (
	SELECT  max(s.schedule_no) sched_no
  FROM schedule s
	GROUP BY
	        ecdp_scheduler.getuniquename(s.name)
	       ,s.description
	       ,s.schedule_group
	       ,s.pin_to
	       ,s.enabled_ind
	)
)