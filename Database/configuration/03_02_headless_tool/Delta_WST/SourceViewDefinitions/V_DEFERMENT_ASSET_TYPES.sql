CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DEFERMENT_ASSET_TYPES" ("CLASS_NAME", "CLASS_LABEL", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_deferment_asset_types.sql
-- View name: v_deferment_asset_types
--
-- $Revision: 1.3 $
--
-- Purpose  : Select a union of all types that we can assign deferment on
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 25.04.2006 MOT    New
-- 22.05.2006 DN     Re-wrote to use class_relation directly and not use inline view.
-- 06.07.2006 Lau    TI# 4015:Remove selection from class relation table.Should only list:Deferment Object,Facility Class 1,Well Hookup,Well
----------------------------------------------------------------------------------------------------
SELECT class_name, EcDp_ClassMeta_Cnfg.getLabel(class_name) class_label, record_status, created_by, created_date, last_updated_by, last_updated_date, rev_no, rev_text
FROM class_cnfg
WHERE class_name in ('DEFERMENT_GROUP', 'WELL', 'FCTY_CLASS_1', 'WELL_HOOKUP')
)