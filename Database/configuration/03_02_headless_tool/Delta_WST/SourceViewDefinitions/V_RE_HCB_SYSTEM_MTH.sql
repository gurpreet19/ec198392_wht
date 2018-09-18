CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_RE_HCB_SYSTEM_MTH" ("REPORT_LAYER", "MONTH", "DAYTIME", "BALANCE_CODE", "BALANCE_NAME", "BALANCE_CODE_NAME", "MASS_UOM_CODE", "VOLUME_UOM_CODE", "ENERGY_UOM_CODE", "NET_ENERGY", "NET_MASS", "NET_VOLUME", "USE_SYSTEM", "IN_OUT", "AT_NODE_CODE", "AT_NODE_NAME", "FROM_NODE_CODE", "FROM_NODE_NAME", "TO_NODE_CODE", "TO_NODE_NAME", "FIELD_CODE", "FIELD_NAME", "STREAM_CATEGORY_CODE", "STREAM_ITEM_CODE", "STREAM_ITEM_NAME", "MASTER_UOM_GROUP", "STATUS", "NET_ENERGY_JO", "NET_ENERGY_TH", "NET_ENERGY_WH", "NET_ENERGY_BE", "NET_MASS_MA", "NET_MASS_MV", "NET_MASS_UA", "NET_MASS_UV", "NET_VOLUME_BI", "NET_VOLUME_BM", "NET_VOLUME_SF", "NET_VOLUME_NM", "NET_VOLUME_SM", "PRODUCT_CODE") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- File name: v_re_hcb_system_mth.sql
-- View name: v_re_hcb_system_mth
--
--
-- $Revision: 1.3 $
--
-- Purpose  : This report contains values for a hydrocarbon balance for a system.
--            The report_layer column tells from which report_layer the number come.
--
-- Description : The view contain a list of all stream_item objects that is connected to a balance object. The purpose of
--               this view is to get a system balance. Positive or negative values in the balance is decided by the USE_SYSTEM
--               attribute (objects_rel_attribute between balance and stream_item). Only records that have a value in the
--               IN_OUT column should be a part of the balance
--
-- Modification history:
--
-- Version  Date        Whom    Change description:
-----------------------------------------------------------------------------------------------------------------------------------
--  1.1     04.03.2006  SSK     Initial version, unions of v_re_hcb_system_ac, v_re_hcb_system_rep and v_re_hcb_system_boo
--         13.02.2007 SRA   Migrated version
-----------------------------------------------------------------------------------------------------------------------------------
SELECT     'AS_IS' REPORT_LAYER,
           vac."MONTH",vac."DAYTIME",vac."BALANCE_CODE",vac."BALANCE_NAME",vac."BALANCE_CODE_NAME",vac."MASS_UOM_CODE",vac."VOLUME_UOM_CODE",vac."ENERGY_UOM_CODE",vac."NET_ENERGY",vac."NET_MASS",vac."NET_VOLUME",vac."USE_SYSTEM",vac."IN_OUT",vac."AT_NODE_CODE",vac."AT_NODE_NAME",vac."FROM_NODE_CODE",vac."FROM_NODE_NAME",vac."TO_NODE_CODE",vac."TO_NODE_NAME",vac."FIELD_CODE",vac."FIELD_NAME",vac."STREAM_CATEGORY_CODE",vac."STREAM_ITEM_CODE",vac."STREAM_ITEM_NAME",vac."MASTER_UOM_GROUP",vac."STATUS",vac."NET_ENERGY_JO",vac."NET_ENERGY_TH",vac."NET_ENERGY_WH",vac."NET_ENERGY_BE",vac."NET_MASS_MA",vac."NET_MASS_MV",vac."NET_MASS_UA",vac."NET_MASS_UV",vac."NET_VOLUME_BI",vac."NET_VOLUME_BM",vac."NET_VOLUME_SF",vac."NET_VOLUME_NM",vac."NET_VOLUME_SM",vac."PRODUCT_CODE"
FROM       v_re_hcb_system_ac vac
UNION ALL
SELECT    'BOOKED' REPORT_LAYER,
          vboo."MONTH",vboo."DAYTIME",vboo."BALANCE_CODE",vboo."BALANCE_NAME",vboo."BALANCE_CODE_NAME",vboo."MASS_UOM_CODE",vboo."VOLUME_UOM_CODE",vboo."ENERGY_UOM_CODE",vboo."NET_ENERGY",vboo."NET_MASS",vboo."NET_VOLUME",vboo."USE_SYSTEM",vboo."IN_OUT",vboo."AT_NODE_CODE",vboo."AT_NODE_NAME",vboo."FROM_NODE_CODE",vboo."FROM_NODE_NAME",vboo."TO_NODE_CODE",vboo."TO_NODE_NAME",vboo."FIELD_CODE",vboo."FIELD_NAME",vboo."STREAM_CATEGORY_CODE",vboo."STREAM_ITEM_CODE",vboo."STREAM_ITEM_NAME",vboo."MASTER_UOM_GROUP",vboo."STATUS",vboo."NET_ENERGY_JO",vboo."NET_ENERGY_TH",vboo."NET_ENERGY_WH",vboo."NET_ENERGY_BE",vboo."NET_MASS_MA",vboo."NET_MASS_MV",vboo."NET_MASS_UA",vboo."NET_MASS_UV",vboo."NET_VOLUME_BI",vboo."NET_VOLUME_BM",vboo."NET_VOLUME_SF",vboo."NET_VOLUME_NM",vboo."NET_VOLUME_SM",vboo."PRODUCT_CODE"
FROM      v_re_hcb_system_boo vboo
UNION ALL
SELECT    'REPORTED' REPORT_LAYER,
          vrep."MONTH",vrep."DAYTIME",vrep."BALANCE_CODE",vrep."BALANCE_NAME",vrep."BALANCE_CODE_NAME",vrep."MASS_UOM_CODE",vrep."VOLUME_UOM_CODE",vrep."ENERGY_UOM_CODE",vrep."NET_ENERGY",vrep."NET_MASS",vrep."NET_VOLUME",vrep."USE_SYSTEM",vrep."IN_OUT",vrep."AT_NODE_CODE",vrep."AT_NODE_NAME",vrep."FROM_NODE_CODE",vrep."FROM_NODE_NAME",vrep."TO_NODE_CODE",vrep."TO_NODE_NAME",vrep."FIELD_CODE",vrep."FIELD_NAME",vrep."STREAM_CATEGORY_CODE",vrep."STREAM_ITEM_CODE",vrep."STREAM_ITEM_NAME",vrep."MASTER_UOM_GROUP",vrep."STATUS",vrep."NET_ENERGY_JO",vrep."NET_ENERGY_TH",vrep."NET_ENERGY_WH",vrep."NET_ENERGY_BE",vrep."NET_MASS_MA",vrep."NET_MASS_MV",vrep."NET_MASS_UA",vrep."NET_MASS_UV",vrep."NET_VOLUME_BI",vrep."NET_VOLUME_BM",vrep."NET_VOLUME_SF",vrep."NET_VOLUME_NM",vrep."NET_VOLUME_SM",vrep."PRODUCT_CODE"
FROM      v_re_hcb_system_rep vrep
)