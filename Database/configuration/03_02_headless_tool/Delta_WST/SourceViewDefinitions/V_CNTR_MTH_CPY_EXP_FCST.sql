CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CNTR_MTH_CPY_EXP_FCST" ("OBJECT_ID", "DAYTIME", "COMPANY_ID", "CATEGORY_CODE", "EXP", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
/**************************************************************
** Script:	v_cntr_mth_cpy_cat_forecast.sql
**
** $Revision: 1.2 $
**
** Purpose: Forecasted expenditure on a contract, in a month, for a company, on a category
**
** General Logic:
**
** Created:   28.11.2006  Magnus Otteraa
**
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
**************************************************************/
SELECT 	cme.object_id,
		cme.daytime,
		cme.company_id,
		cme.category_code,
		sum(cme.exp_value) exp,
		'P' record_status,
		NULL created_by,
		NULL created_date,
		NULL last_updated_by,
		NULL last_updated_date,
		NULL rev_no,
		NULL rev_text
	FROM CNTR_MTH_EXP_FORECAST cme
	WHERE cme.company_id is not null
	GROUP BY cme.object_id, cme.daytime, cme.company_id, cme.category_code
)