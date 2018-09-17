CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_RE_HCB_ACCROSS_NODE_AC" ("MONTH", "DAYTIME", "BALANCE_CODE", "BALANCE_NAME", "BALANCE_CODE_NAME", "MASS_UOM_CODE", "VOLUME_UOM_CODE", "ENERGY_UOM_CODE", "NET_ENERGY", "NET_MASS", "NET_VOLUME", "IN_OUT", "ACROSS_NODE_CODE", "ACROSS_NODE_NAME", "AT_NODE_CODE", "AT_NODE_NAME", "FROM_NODE_CODE", "FROM_NODE_NAME", "TO_NODE_CODE", "TO_NODE_NAME", "STREAM_CATEGORY_CODE", "STREAM_ITEM_CODE", "STREAM_ITEM_NAME", "MASTER_UOM_GROUP", "STATUS", "NET_ENERGY_JO", "NET_ENERGY_TH", "NET_ENERGY_WH", "NET_ENERGY_BE", "NET_MASS_MA", "NET_MASS_MV", "NET_MASS_UA", "NET_MASS_UV", "NET_VOLUME_BI", "NET_VOLUME_BM", "NET_VOLUME_SF", "NET_VOLUME_NM", "NET_VOLUME_SM") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- File name: v_re_hcb_accross_node_ac.sql
-- View name: v_re_hcb_accross_node_ac
-- $Revision: 1.6 $
--
-- Purpose  :     This report contains values for a hydrocarbon balance across node (actual version)
--
-- Description :  The view contain a list of all stream_item objects that is connected to a balance object. The purpose of
--                this view is to get a across node balance. Positive or negative values in the balance is decided by the
--                function called GetStreamDir (in the Ecdb_Balance package). Only records that have a value in the IN_OUT
--                column should be a part of this balance. There are a join to a sub-select in this view. The purpose of
--                this sub-select is to get all nodes for each stream_item (accross_node). This results in a cartesian product.
--
-- Modification history:
--
-- Version Date       Whom  Change description:
----------------------------------------------------------------------------------------------------
-- 1.0     30.06.2006 SSK   Initial version
--         26.01.2007 SRA   Migrated version
----------------------------------------------------------------------------------------------------
SELECT  TO_CHAR(stim.daytime,'YYYY/MM')                                                                                                                                                                                                               MONTH                   -- STIM_MTH_ACTUAL.DAYTIME
        ,stim.daytime                                                                                                                                                                                                                                 DAYTIME                 -- STIM_MTH_ACTUAL.DAYTIME
        ,RTRIM(RPAD(b.object_code,250))                                                                                                                                                                                                        BALANCE_CODE            -- BALANCE.CODE
        ,RTRIM(RPAD(bv.name,250))                                                                                                                                                              BALANCE_NAME            -- BALANCE.NAME
        ,RTRIM(RPAD(b.object_code || ' ' || bv.name,250))                                                                                                                                   BALANCE_CODE_NAME
        ,RTRIM(RPAD(bv.mass_uom_code,250))                                                                                                                                                     MASS_UOM_CODE           -- BALANCE.MASS_UOM_CODE
        ,RTRIM(RPAD(bv.volume_uom_code,250))                                                                                                                                                   VOLUME_UOM_CODE         -- BALANCE.VOLUME_UOM_CODE
        ,RTRIM(RPAD(bv.energy_uom_code,250))                                                                                                                                                   ENERGY_UOM_CODE         -- BALANCE.ENERGY_UOM_CODE
        ,Ecdp_Unit.convertValue(stim.net_energy_jo, '100MJ', bv.energy_uom_code, stim.daytime)*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)   NET_ENERGY
        ,Ecdp_Unit.convertValue(stim.net_mass_ma, 'MT', bv.mass_uom_code, stim.daytime)*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)          NET_MASS
        ,Ecdp_Unit.convertValue(stim.net_volume_bi, 'BBLS60', bv.volume_uom_code, stim.daytime)*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)  NET_VOLUME
        ,DECODE(Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id),-1,'IN',1,'OUT')                                                                                                                          IN_OUT                  --
        ,RTRIM(RPAD(ec_node.object_code(across_node.node_object_id),250))                                                                                                                                                 ACROSS_NODE_CODE        -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(ec_node_version.name(across_node.node_object_id,stim.daytime,'<='),250))                                                                                                                                                 ACROSS_NODE_NAME        -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('AT_NODE', stim.object_id, stim.daytime,'CODE'),250))                                                                                                                                                AT_NODE_CODE            -- STREAM_ITEM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('AT_NODE', stim.object_id, stim.daytime,'NAME'),250))                                                                                                                                                AT_NODE_NAME            -- STREAM_ITEM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(ec_node.object_code(sv.from_node_id),250))                                                                                                                                            FROM_NODE_CODE          -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(ec_node_version.name(sv.from_node_id, stim.daytime ,'<='),250))                                                                                                                                            FROM_NODE_NAME          -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(ec_node.object_code(sv.to_node_id),250))                                                                                                                                              TO_NODE_CODE            -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(ec_node_version.name(sv.to_node_id, stim.daytime ,'<='),250))                                                                                                                                              TO_NODE_NAME            -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(sv.stream_category,250))                                                                                                                                              STREAM_CATEGORY_CODE    -- STREAM.STREAM_CATEGORY_CODE
        ,RTRIM(RPAD(si.object_code,250))                                                                                                                                                             STREAM_ITEM_CODE        -- STREAM_ITEM.CODE
        ,RTRIM(RPAD(siv.name,250))                                                                                                                                                             STREAM_ITEM_NAME        -- STREAM_ITEM.NAME
        ,RTRIM(RPAD(siv.master_uom_group,250))                                                                                                                                                 MASTER_UOM_GROUP        -- STREAM_ITEM.MASTER_UOM_GROUP
        ,stim.status                                                                                                                                                                                                                                  STATUS                  -- STIM_MTH_ACTUAL.STATUS
        ,stim.net_energy_jo*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                               NET_ENERGY_JO           -- STIM_MTH_ACTUAL.NET_ENERGY_JO
        ,stim.net_energy_th*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                               NET_ENERGY_TH           -- STIM_MTH_ACTUAL.NET_ENERGY_TH
        ,stim.net_energy_wh*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                               NET_ENERGY_WH           -- STIM_MTH_ACTUAL.NET_ENERGY_WH
        ,stim.net_energy_be*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                               NET_ENERGY_BE           -- STIM_MTH_ACTUAL.NET_ENERGY_BE
        ,stim.net_mass_ma*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                                 NET_MASS_MA             -- STIM_MTH_ACTUAL.NET_MASS_MA
        ,stim.net_mass_mv*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                                 NET_MASS_MV             -- STIM_MTH_ACTUAL.NET_MASS_MV
        ,stim.net_mass_ua*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                                 NET_MASS_UA             -- STIM_MTH_ACTUAL.NET_MASS_UA
        ,stim.net_mass_uv*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                                 NET_MASS_UV             -- STIM_MTH_ACTUAL.NET_MASS_UV
        ,stim.net_volume_bi*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                               NET_VOLUME_BI           -- STIM_MTH_ACTUAL.NET_VOLUME_BI
        ,stim.net_volume_bm*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                               NET_VOLUME_BM           -- STIM_MTH_ACTUAL.NET_VOLUME_BM
        ,stim.net_volume_sf*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                               NET_VOLUME_SF           -- STIM_MTH_ACTUAL.NET_VOLUME_SF
        ,stim.net_volume_nm*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                               NET_VOLUME_NM           -- STIM_MTH_ACTUAL.NET_VOLUME_NM
        ,stim.net_volume_sm*Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id)                                                                                                                               NET_VOLUME_SM           -- STIM_MTH_ACTUAL.NET_VOLUME_SM
FROM    stream s                                                 -- STREAM
        ,strm_version sv                                           -- STRM_VERSION
        ,stream_item si                                               -- STREAM_ITEM
        ,balance b                                                -- BALANCE
        ,balance_version bv                                                -- BALANCE_VERSION
        ,stream_item_version siv -- objects_relation s_si                                    -- STREAM -> STREAM_ITEM
        ,balance_setup b_si                                    -- BALANCE -> STREAM_ITEM
        ,stim_mth_actual stim                                   -- STIM_MTH_ACTUAL
        -- Sub select that lists all distinct nodes (from_node and to_node) that a stream is connected too.
        ,V_FROM_NODE_CONCAT_TO_NODE_AC                            ACROSS_NODE
WHERE   si.object_id = siv.object_id
AND     siv.daytime = (SELECT max(daytime) FROM stream_item_version WHERE object_id = siv.object_id AND daytime <= stim.daytime)
AND     s.object_id = sv.object_id                                -- STREAM -> STRM_VERSION
AND     sv.daytime = (SELECT max(daytime) FROM strm_version WHERE object_id = sv.object_id AND daytime <= stim.daytime)
AND     si.stream_id = s.object_id                                -- STREAM -> STREAM_ITEM
AND     b.object_id = b_si.object_id                              -- BALANCE -> BALANCE_SETUP
AND     b.object_id = bv.object_id
AND     bv.daytime = (SELECT max(daytime) FROM balance_version WHERE object_id = bv.object_id AND daytime <= stim.daytime)
AND     b_si.stream_item_id = si.object_id                        -- BALANCE_SETUP -> STREAM_ITEM
AND     si.object_id = stim.object_id                             -- STREAM_ITEM -> STIM_MTH_ACTUAL
AND     stim.daytime = across_node.daytime                        -- STIM_MTH_ACTUAL -> ACROSS_NODE
AND     b.object_code = across_node.attribute_text                -- BALANACE->STREAM_ITEM.ATTRIBUTE -> ACROSS_NODE
--and     Ecdp_Balance.GetStreamDir(b.object_id,si.object_id,stim.daytime,across_node.node_object_id) IS NOT NULL  -- This condition makes the view slower
)