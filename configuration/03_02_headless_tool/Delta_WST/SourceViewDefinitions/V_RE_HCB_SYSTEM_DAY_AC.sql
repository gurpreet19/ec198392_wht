CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_RE_HCB_SYSTEM_DAY_AC" ("DAYTIME", "BALANCE_CODE", "BALANCE_NAME", "BALANCE_CODE_NAME", "MASS_UOM_CODE", "VOLUME_UOM_CODE", "ENERGY_UOM_CODE", "NET_ENERGY", "NET_MASS", "NET_VOLUME", "USE_SYSTEM", "IN_OUT", "AT_NODE_CODE", "AT_NODE_NAME", "FROM_NODE_CODE", "FROM_NODE_NAME", "TO_NODE_CODE", "TO_NODE_NAME", "FIELD_CODE", "FIELD_NAME", "STREAM_CATEGORY_CODE", "STREAM_ITEM_CODE", "STREAM_ITEM_NAME", "MASTER_UOM_GROUP", "STATUS", "NET_ENERGY_JO", "NET_ENERGY_TH", "NET_ENERGY_WH", "NET_ENERGY_BE", "NET_MASS_MA", "NET_MASS_MV", "NET_MASS_UA", "NET_MASS_UV", "NET_VOLUME_BI", "NET_VOLUME_BM", "NET_VOLUME_SF", "NET_VOLUME_NM", "NET_VOLUME_SM", "PRODUCT_CODE") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- File name: v_re_hcb_system_day_ac.sql
-- View name: v_re_hcb_system_day_ac
--
-- $Revision: 1.6 $
--
-- Purpose  : This report contains values for a hydrocarbon balance for a system (actual version)
--
-- Description : The view contain a list of all stream_item objects that is connected to a balance object. The purpose of
--               this view is to get a system balance. Positive or negative values in the balance is decided by the USE_SYSTEM
--               attribute (objects_rel_attribute between balance and stream_item). Only records that have a value in the
--               IN_OUT column should be a part of the balance
--
-- Modification history:
--
-- Version Date       Whom  Change description:
----------------------------------------------------------------------------------------------------
-- 1.0     03.07.2006 SSK   Initial version
-- 1.1     06.07.2006 SSK   Removed records that has USE_SYSTEM_CODE equal to 0
--         13.02.2007 SRA   Migrated version
----------------------------------------------------------------------------------------------------
SELECT  stim.daytime                                                                                                                     DAYTIME                 -- STIM_MTH_ACTUAL.DAYTIME
        ,RTRIM(RPAD(b.object_code,250))                                                                                                   BALANCE_CODE            -- BALANCE.CODE
        ,RTRIM(RPAD(a_b_c.name,250))                                                                                                      BALANCE_NAME            -- BALANCE.NAME
        ,RTRIM(RPAD(b.object_code||' '||a_b_c.name,250))                                                                                  BALANCE_CODE_NAME
        ,RTRIM(RPAD(a_b_c.mass_uom_code,250))                                                                                             MASS_UOM_CODE           -- BALANCE.MASS_UOM_CODE
        ,RTRIM(RPAD(a_b_c.volume_uom_code,250))                                                                                           VOLUME_UOM_CODE         -- BALANCE.VOLUME_UOM_CODE
        ,RTRIM(RPAD(a_b_c.energy_uom_code,250))                                                                                           ENERGY_UOM_CODE         -- BALANCE.ENERGY_UOM_CODE
        ,EcDp_Unit.convertValue(stim.net_energy_jo, '100MJ', a_b_c.energy_uom_code, stim.daytime)*to_number(b_si.use_system_code)         NET_ENERGY
        ,EcDp_Unit.convertValue(stim.net_mass_ma, 'MT', a_b_c.mass_uom_code, stim.daytime)*to_number(b_si.use_system_code)                NET_MASS
        ,EcDp_Unit.convertValue(stim.net_volume_bi, 'BBLS', a_b_c.volume_uom_code, stim.daytime)*to_number(b_si.use_system_code)          NET_VOLUME
        ,b_si.use_system_code			                                                                                                        USE_SYSTEM	           -- BALANCE->STREAM_ITEM.USE_SYSTEM
        ,DECODE(b_si.use_system_code,-1,'IN',1,'OUT')                                                                                     IN_OUT                  -- BALANCE->STREAM_ITEM.USE_SYSTEM (relation attribute)
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime,'CODE'),250))                                          AT_NODE_CODE            -- STREAM_ITEM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime,'NAME'),250))                                          AT_NODE_NAME            -- STREAM_ITEM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime,'CODE'),250))                                        FROM_NODE_CODE          -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime,'NAME'),250))                                        FROM_NODE_NAME          -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime,'CODE'),250))                                          TO_NODE_CODE            -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime,'NAME'),250))                                          TO_NODE_NAME            -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(ec_field.object_code(ec_stream_item_version.field_id(smv.object_id, smv.daytime, '<=')),250))                         FIELD_CODE
        ,RTRIM(RPAD(ec_field_version.name(ec_stream_item_version.field_id(smv.object_id, smv.daytime, '<='), smv.daytime, '<='),250))     FIELD_NAME
        ,RTRIM(RPAD(ec_strm_version.stream_category(si.stream_id, smv.daytime, '<='),250))                                                STREAM_CATEGORY_CODE    -- STREAM.STREAM_CATEGORY_CODE
        ,RTRIM(RPAD(ec_stream_item.object_code(smv.object_id),250))                                                                       STREAM_ITEM_CODE        -- STREAM_ITEM.CODE
        ,RTRIM(RPAD(ec_stream_item_version.name(smv.object_id, smv.daytime, '<='),250))                                                   STREAM_ITEM_NAME        -- STREAM_ITEM.NAME
        ,RTRIM(RPAD(ec_stream_item_version.master_uom_group(smv.object_id,smv.daytime,'<='),250))                                         MASTER_UOM_GROUP        -- STREAM_ITEM.MASTER_UOM_GROUP
        ,stim.status                                                                                                                      STATUS                  -- STIM_MTH_ACTUAL.STATUS
        ,stim.net_energy_jo*to_number(b_si.use_system_code)                                                                               NET_ENERGY_JO           -- STIM_MTH_ACTUAL.NET_ENERGY_JO
        ,stim.net_energy_th*to_number(b_si.use_system_code)                                                                               NET_ENERGY_TH           -- STIM_MTH_ACTUAL.NET_ENERGY_TH
        ,stim.net_energy_wh*to_number(b_si.use_system_code)                                                                               NET_ENERGY_WH           -- STIM_MTH_ACTUAL.NET_ENERGY_WH
        ,stim.net_energy_be*to_number(b_si.use_system_code)                                                                               NET_ENERGY_BE           -- STIM_MTH_ACTUAL.NET_ENERGY_BE
        ,stim.net_mass_ma*to_number(b_si.use_system_code)                                                                                 NET_MASS_MA             -- STIM_MTH_ACTUAL.NET_MASS_MA
        ,stim.net_mass_mv*to_number(b_si.use_system_code)                                                                                 NET_MASS_MV             -- STIM_MTH_ACTUAL.NET_MASS_MV
        ,stim.net_mass_ua*to_number(b_si.use_system_code)                                                                                 NET_MASS_UA             -- STIM_MTH_ACTUAL.NET_MASS_UA
        ,stim.net_mass_uv*to_number(b_si.use_system_code)                                                                                 NET_MASS_UV             -- STIM_MTH_ACTUAL.NET_MASS_UV
        ,stim.net_volume_bi*to_number(b_si.use_system_code)                                                                               NET_VOLUME_BI           -- STIM_MTH_ACTUAL.NET_VOLUME_BI
        ,stim.net_volume_bm*to_number(b_si.use_system_code)                                                                               NET_VOLUME_BM           -- STIM_MTH_ACTUAL.NET_VOLUME_BM
        ,stim.net_volume_sf*to_number(b_si.use_system_code)                                                                               NET_VOLUME_SF           -- STIM_MTH_ACTUAL.NET_VOLUME_SF
        ,stim.net_volume_nm*to_number(b_si.use_system_code)                                                                               NET_VOLUME_NM           -- STIM_MTH_ACTUAL.NET_VOLUME_NM
        ,stim.net_volume_sm*to_number(b_si.use_system_code)                                                                               NET_VOLUME_SM           -- STIM_MTH_ACTUAL.NET_VOLUME_SM
        ,ec_product.object_code(ec_stream_item_version.product_id(smv.object_id, smv.daytime, '<='))                                      PRODUCT_CODE            -- STIM_MTH_VALUE.PRODUCT_CODE
--        ,sic_so.attribute_value                                                                                                         SIC_SORT_ORDER          -- STIM_MTH_VALUE.STREAM_ITEM_CATEGORY -> SORT_ORDER
FROM     balance b
        ,balance_version a_b_c
        ,balance_setup b_si
        ,stim_day_actual stim
        ,stim_mth_value  smv
        ,stream_item si
        ,stream_item_version siv
--        ,objects_attribute  sic_so
WHERE   stim.object_id = smv.object_id
AND     TRUNC(stim.daytime,'MM') = smv.daytime
AND     b.object_id = a_b_c.object_id                  -- BALANCE (OBJECT -> ATTRIBUTE)
AND     stim.object_id = si.object_id
AND     a_b_c.daytime = (SELECT MAX(daytime) FROM balance_version WHERE object_id = b.object_id AND daytime <= stim.daytime)
AND     stim.object_id = siv.object_id
AND     siv.daytime = (SELECT MAX(daytime) FROM stream_item_version WHERE object_id = stim.object_id AND daytime <= stim.daytime)
AND     stim.daytime BETWEEN Nvl(a_b_c.daytime,stim.daytime) AND Nvl(a_b_c.end_date-1/(24*60*60),stim.daytime)
AND     b.object_id = b_si.object_id           -- BALANCE -> STREAM_ITEM
--AND     stim.daytime BETWEEN Nvl(b_si.start_date,stim.daytime) AND Nvl(b_si.end_date-1/(24*60*60),stim.daytime)
AND     smv.object_id = b_si.stream_item_id           -- BALANCE -> STREAM_ITEM
AND     to_number(b_si.use_system_code) != 0
AND     siv.reporting_category <> 1
)