CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_ROYALTY_PARTY" ("CLASS_LABEL", "CLASS_NAME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
---------------------------------------------------------------------------------------------------
-- File name v_royalty_party.sql
-- View name v_royalty_party
--
-- $Revision: 1.2 $
--
-- Purpose
-- group product group together
-- Modification history
--
-- Date       Whom        Change description
-- ---------- ----        ----------------------------------------------------------------------------
--24 March 2014 masamken
----------------------------------------------------------------------------------------------------
SELECT CLASS_LABEL,
	   CLASS_NAME,
	   NULL AS RECORD_STATUS,
	   NULL AS CREATED_BY,
	   NULL AS CREATED_DATE,
	   NULL AS LAST_UPDATED_BY,
	   NULL AS LAST_UPDATED_DATE,
	   NULL AS REV_NO,
	   NULL AS REV_TEXT FROM (
	SELECT 	EcDp_ClassMeta_Cnfg.getLabel(C.CLASS_NAME) AS CLASS_LABEL, C.CLASS_NAME
	FROM  IV_ROYALTY_OWNERS IV, CLASS_CNFG C
	WHERE IV.CLASS_NAME = C.CLASS_NAME
)
GROUP BY CLASS_LABEL, CLASS_NAME
)