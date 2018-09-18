CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CNTR_PG_SETUP" ("OBJECT_ID", "CONTRACT_ID", "DAYTIME", "END_DATE", "USE_IND", "RTY_BASE_VOLUME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
---------------------------------------------------------------------------------------------------
-- File name v_cntr_pg_setup.sql
-- View name v_cntr_pg_setup
--
-- $Revision: 1.2 $
--
-- Purpose
-- group product group together
-- Modification history
--
-- Date       Whom        Change description
-- ---------- ----        ----------------------------------------------------------------------------
--21 March 2014 masamken
----------------------------------------------------------------------------------------------------
SELECT
    C.OBJECT_ID,
	C.CONTRACT_ID,
	C.DAYTIME,
	C.END_DATE,
	--C.PRODUCT_ID,
	C.USE_IND,
	C.RTY_BASE_VOLUME,
  NULL AS RECORD_STATUS,
	NULL AS CREATED_BY,
	NULL AS CREATED_DATE,
  'PLACEHOLDER_PLACEHOLDER_VALUE1' AS LAST_UPDATED_BY,
	NULL AS LAST_UPDATED_DATE,
	NULL AS REV_NO,
	NULL AS REV_TEXT
FROM CNTR_PG_SETUP C
GROUP BY C.OBJECT_ID, C.CONTRACT_ID, C.USE_IND, C.RTY_BASE_VOLUME, C.DAYTIME, c.END_DATE, C.LAST_UPDATED_BY
)