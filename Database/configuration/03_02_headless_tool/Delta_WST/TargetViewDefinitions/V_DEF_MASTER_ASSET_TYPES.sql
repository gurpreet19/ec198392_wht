CREATE OR REPLACE FORCE VIEW "V_DEF_MASTER_ASSET_TYPES" ("CLASS_NAME", "CLASS_LABEL", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_def_master_asset_types.sql
-- View name: v_def_master_asset_types
--
-- $Revision: 1.3 $
--
-- Purpose  : Select a union of all types that we can assign deferment on
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 18.12.2006 rajarsar    New
--30.09.2009 aliassit ECPD-12730: Added new class_name 'FIELD' to asset type popup
----------------------------------------------------------------------------------------------------
SELECT class_name,
label class_label,
record_status,
created_by,
created_date,
last_updated_by,
last_updated_date,
rev_no, rev_text
FROM class
WHERE class_name in ('FCTY_CLASS_1', 'FCTY_CLASS_2', 'WELL', 'DEFERMENT_GROUP','FIELD'))