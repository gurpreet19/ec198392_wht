CREATE OR REPLACE FORCE VIEW "V_CNTR_MTH_EXP" ("OBJECT_ID", "DAYTIME", "CATEGORY_CODE", "EXP", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
/**************************************************************
** Script:	v_cntr_mth_cat.sql
**
** $Revision: 1.2 $
**
** Purpose: Actual expenditure on a contract, in a month for a category, where company is null
**
** General Logic:
**
** Created:   28.11.2006  Magnus Otterå
**
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 04.05.2007 siah  ECPD-5318 Remove NVL in V_CNTR_MTH_EXP
**************************************************************/
SELECT 	cme.object_id,
		cme.daytime,
		cme.category_code,
		sum(cme.exp_value) exp,
		'P' record_status,
		NULL created_by,
		NULL created_date,
		NULL last_updated_by,
		NULL last_updated_date,
		NULL rev_no,
		NULL rev_text
	FROM CNTR_MTH_EXPENDITURE cme
	WHERE cme.company_id is null
	GROUP BY cme.object_id, cme.daytime, cme.category_code
)