CREATE OR REPLACE FORCE VIEW "V_DOCUMENT_INSTR_TEMPLATE" ("LA_CPY_ID", "TEMPLATE_CODE", "TEMPLATE_NAME", "DEFAULT_IND", "CARGO_DOC_TEMPLATE_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name v_document_instr_template.sql
-- View name v_document_instr_template
--
-- $Revision: 1.1.2.1 $
--
-- Purpose
-- To union 2 document template tables: Lifting Account and Company
-- Modification history
--
-- Date       Whom      Change description
-- ---------- ----      --------------------------------------------------------------------------------
--4 Dec 2012 muhammah	ECPD-22515: Document Instruction Template without relation to Lifting Account
----------------------------------------------------------------------------------------------------
select
		la.OBJECT_ID as LA_CPY_ID,
		la.TEMPLATE_CODE,
		la.TEMPLATE_NAME,
		la.DEFAULT_IND,
		la.CARGO_DOC_TEMPLATE_CODE,
		la.RECORD_STATUS as RECORD_STATUS,
		la.CREATED_BY as CREATED_BY,
		la.CREATED_DATE as CREATED_DATE,
		la.LAST_UPDATED_BY as LAST_UPDATED_BY,
		la.LAST_UPDATED_DATE as LAST_UPDATED_DATE,
		la.REV_NO as REV_NO,
		la.REV_TEXT as REV_TEXT
FROM lift_acc_doc_template la
UNION
SELECT
		co.OBJECT_ID as LA_CPY_ID,
		co.TEMPLATE_CODE,
		co.TEMPLATE_NAME,
		co.DEFAULT_IND,
		co.CARGO_DOC_TEMPLATE_CODE,
		co.RECORD_STATUS as RECORD_STATUS,
		co.CREATED_BY as CREATED_BY,
		co.CREATED_DATE as CREATED_DATE,
		co.LAST_UPDATED_BY as LAST_UPDATED_BY,
		co.LAST_UPDATED_DATE as LAST_UPDATED_DATE,
		co.REV_NO as REV_NO,
		co.REV_TEXT as REV_TEXT
FROM company_doc_template co
)