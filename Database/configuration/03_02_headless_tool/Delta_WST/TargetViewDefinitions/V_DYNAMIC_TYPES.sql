CREATE OR REPLACE FORCE VIEW "V_DYNAMIC_TYPES" ("LABEL", "NAME", "TYPE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name:v_dynamic_types.sql
-- View name: v_dynamic_types
--
-- $Revision: 1.5 $
--
-- Purpose  : Select a union of all types in the system. To be used when selecting a dynamic type.
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 07.12.2005 MOT    New
-- 02.10.2006 Lau    TI 4094 - Report Parameter Enhancement
----------------------------------------------------------------------------------------------------
select label, name, type, record_status, created_by, created_date, last_updated_by, last_updated_date, rev_no, rev_text from
(
	select c.label, c.class_name name, 'EC_OBJECT_TYPE' type, record_status, created_by, created_date, last_updated_by, last_updated_date, rev_no, rev_text from class c
	where c.class_type = 'OBJECT'
	union all
	select distinct codes.code_type label, codes.code_type, 'EC_CODE_TYPE', NULL record_status, NULL created_by, NULL created_date, NULL last_updated_by, NULL last_updated_date, NULL rev_no, NULL rev_text from prosty_codes codes
	union all
	select codes.code_text label, codes.code, 'BASIC_TYPE', record_status, created_by, created_date, last_updated_by, last_updated_date, rev_no, rev_text from prosty_codes codes
	where codes.code_type = 'BASIC_TYPE'
 	union all
 	select codes.code_text label, codes.code, 'EC_TABLE_TYPE', record_status, created_by, created_date, last_updated_by, last_updated_date, rev_no, rev_text from prosty_codes codes
	where codes.code_type = 'EC_TABLE_TYPE'
	union all
 	select codes.code_text label, codes.code, 'USER_EXIT', record_status, created_by, created_date, last_updated_by, last_updated_date, rev_no, rev_text from prosty_codes codes
	where codes.code_type = 'UE_PARAM_SUB_TYPE'
) A
)