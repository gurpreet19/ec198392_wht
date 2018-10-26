CREATE OR REPLACE FORCE VIEW "V_CNTR_MTH_EXP_FCST" ("OBJECT_ID", "DAYTIME", "CATEGORY_CODE", "EXP", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
/**************************************************************
** Script:	v_cntr_mth_cat_forecast.sql
**
** $Revision: 1.1 $
**
** Purpose: Forecasted expenditure on a contract, in a month for a category, where company is null
**
** General Logic:
**
** Created:   28.11.2006  Magnus Otterå
**
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
**************************************************************/
SELECT 	cme.object_id,
		cme.daytime,
		cme.category_code,
		sum(nvl(cme.exp_value,0)) exp,
		'P' record_status,
		NULL created_by,
		NULL created_date,
		NULL last_updated_by,
		NULL last_updated_date,
		NULL rev_no,
		NULL rev_text
	FROM CNTR_MTH_EXP_FORECAST cme
	WHERE cme.company_id is null
	GROUP BY cme.object_id, cme.daytime, cme.category_code
)