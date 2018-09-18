CREATE OR REPLACE PACKAGE pck_status IS
/**************************************************************
** Package	:  PCK_STATUS
**
** $Revision: 1.13 $
**
** Purpose	:  Provide functions and procedures related data status transactions
**
** General Logic: Creates dynamic SQL to update record_status.
**
** Created:   	08.04.99 HN
**
** Modification history:
**
** Date:      Whom:  Change description:
** -------    -----  ------------------------------------------
** 19.12.2002 HN     Added p_user_id
** 25.06.2004 DN     Added procedure set_cargo_rs_by_code. TD 1407.
** 27.09.2004 SeongKok  Added procedure set_deferment_rs for TrackerIssue#679
** 10.03.2005 DN     Redefined procedure set_alloc_netw_log_status_rs.
** 31.03.2005 SHN    Removed obsolete procedure set_welltest_rs
** 28.04.2006 MOT    Added set_deferment_record_status due to new deferment tables (tracker 2611, and 3545)
** 29.04.2006 ZakiiAri  TI#3595: Added new parameter (p_user_id) to procedure set_cargo_rs, set_alloc_netw_log_status_rs, set_analysis_rs, set_deferment_rs
** 31.03.2008 oonnnng  ECPD-7263: Add p_to_daytime (END_DATE) to update_stat_process_status and update_stat_process_status functions.
** 10.02.2009 oonnnng  ECPD-10861: Add new procedure set_aga_analysis_rs.
**************************************************************/
--
--------------------------------------------------------------------------------------------------------------
-- PROCEDURES
-------------------------------------------------------------------------------------------------------------
PROCEDURE run_process(--p_sysnam VARCHAR2,
p_process_id VARCHAR2, p_from_daytime DATE, p_to_daytime DATE DEFAULT NULL, p_user_id VARCHAR2 DEFAULT NULL);
PROCEDURE run_child_process(--p_sysnam VARCHAR2,
p_process_id VARCHAR2, p_from_rs_level VARCHAR2, p_to_rs_level VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_total_rows_upd IN OUT NUMBER, p_user_id VARCHAR2 DEFAULT NULL);
PROCEDURE run_tasks(--p_sysnam VARCHAR2,
p_process_id VARCHAR2, p_from_rs_level VARCHAR2, p_to_rs_level VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_rows_updated IN OUT NUMBER, p_user_id VARCHAR2 DEFAULT NULL);
PROCEDURE update_stat_process_status(--p_sysnam VARCHAR2,
p_process_id VARCHAR2, p_to_rs_level VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_rows_updated NUMBER, p_user_id VARCHAR2 DEFAULT NULL);
PROCEDURE set_cargo_rs(--p_sysnam VARCHAR2,
p_cargo_no NUMBER, p_user_id VARCHAR2 DEFAULT NULL);
PROCEDURE set_cargo_rs_by_code(--p_sysnam VARCHAR2,
p_cargo_code VARCHAR2);

PROCEDURE set_deferment_rs(p_event_id VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE set_deferment_record_status(p_event_no VARCHAR2);

PROCEDURE set_alloc_netw_log_status_rs(p_run_no NUMBER,
                          p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE set_analysis_rs(p_object_id VARCHAR2, p_analysis_type VARCHAR2, p_sampling_method VARCHAR2, p_daytime DATE, p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE set_aga_analysis_rs(p_object_id VARCHAR2, p_analysis_type VARCHAR2,  p_daytime DATE, p_user_id VARCHAR2 DEFAULT NULL);

--------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-------------------------------------------------------------------------------------------------------------
FUNCTION process_day_rs(--p_sysnam VARCHAR2,
p_process_id VARCHAR2, p_from_day DATE, p_to_day DATE ) RETURN VARCHAR2;
FUNCTION access_to_process(--p_sysnam VARCHAR2,
         p_process_id VARCHAR2, p_user_id VARCHAR2) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------------------------------------
PRAGMA RESTRICT_REFERENCES(process_day_rs, WNPS, WNDS );
PRAGMA RESTRICT_REFERENCES(access_to_process, WNPS, WNDS );

END pck_status;