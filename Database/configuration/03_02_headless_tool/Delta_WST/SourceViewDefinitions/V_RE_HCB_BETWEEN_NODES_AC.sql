CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_RE_HCB_BETWEEN_NODES_AC" ("BALANCE", "MONTH", "BALANCE_CODE", "BALANCE_NAME", "BALANCE_CODE_NAME", "OBJECT_ID", "DAYTIME", "MASS_UOM_CODE", "VOLUME_UOM_CODE", "ENERGY_UOM_CODE", "NET_ENERGY", "NET_MASS", "NET_VOLUME", "IN_OUT", "BETWEEN_NODE1_CODE", "BETWEEN_NODE1_NAME", "BETWEEN_NODE2_CODE", "BETWEEN_NODE2_NAME", "AT_NODE_CODE", "AT_NODE_NAME", "FROM_NODE_CODE", "FROM_NODE_NAME", "TO_NODE_CODE", "TO_NODE_NAME", "STREAM_CATEGORY_CODE", "STREAM_ITEM_CODE", "STREAM_ITEM_NAME", "STATUS", "NET_ENERGY_JO", "NET_ENERGY_TH", "NET_ENERGY_WH", "NET_ENERGY_BE", "NET_MASS_MA", "NET_MASS_MV", "NET_MASS_UA", "NET_MASS_UV", "NET_VOLUME_BI", "NET_VOLUME_BM", "NET_VOLUME_SF", "NET_VOLUME_NM", "NET_VOLUME_SM") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- File name:     v_re_vo_hcb_between_nodes_ac.sql
-- View name:     v_re_vo_hcb_between_nodes_ac
-- $Revision: 1.10 $
--
-- Purpose  :     This report contains values for a hydrocarbon balance between connected nodes (actual values)
--
-- Description : The view uses the view v_from_node_concat_to_node which contain a list of all stream_item objects that is connected to a balance object.
--               The purpose of this view is to get a between node balance. Positive or negative values in the balance is decided by the
--               function called GetBetweenNodeDir (in the Ecdb_Balance package). Only records that have a value in the
--               IN_OUT column should be a part of the balance. The purpose of the joins with v_from_node_concat_to_node
--               is to get all nodes for each stream_item (between_node1) against all nodes for each stream_item (between_node2). This results in a cartesian product.
--
-- Modification history:
--
-- Version Date       Whom  Change description:
----------------------------------------------------------------------------------------------------
-- 1.0     27.06.2006 SSK   Initial version
-- 1.5     30.06.2006 SSK   Modified where-clause. Removed check if ecdp_balance.getBetweenNodeDirAc returns null.
--         12.02.2007 SRA   Migrated version
----------------------------------------------------------------------------------------------------
SELECT  b.object_id                                                                                                                                                                                                                                                                                     BALANCE
        ,TO_CHAR(stim.daytime,'YYYY/MM')                                                                                                                                                                                                                                                                MONTH                   -- STIM_MTH_ACTUAL.DAYTIME
        ,RTRIM(RPAD(b.object_code,250))                                                                                                                                                                                                                                                          BALANCE_CODE            -- BALANCE.CODE
        ,RTRIM(RPAD(a_b_c.name,250))                                                                                                                                                                                                                BALANCE_NAME            -- BALANCE.NAME
        ,RTRIM(RPAD(b.object_code||' '||a_b_c.name,250))						                                                                                                                                                                          BALANCE_CODE_NAME
        ,si.object_id                                                                                                                                                                                                                                                                                   OBJECT_ID
        ,stim.daytime                                                                                                                                                                                                                                                                                   DAYTIME                 -- STIM_MTH_ACTUAL.DAYTIME
        ,RTRIM(RPAD(a_b_c.MASS_UOM_CODE,250))              						                                                                                                                                                                              MASS_UOM_CODE
        ,RTRIM(RPAD(a_b_c.VOLUME_UOM_CODE,250))                                                                                                                                                                                                     VOLUME_UOM_CODE         -- BALANCE.VOLUME_UOM_CODE
        ,RTRIM(RPAD(a_b_c.ENERGY_UOM_CODE,250))                                                                                                                                                                                                     ENERGY_UOM_CODE         -- BALANCE.ENERGY_UOM_CODE
        ,EcDp_Unit.convertValue(stim.net_energy_jo, '100MJ', a_b_c.energy_uom_code, stim.daytime)*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)   NET_ENERGY
        ,EcDp_Unit.convertValue(stim.net_mass_ma, 'MT', a_b_c.mass_uom_code, stim.daytime)*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)          NET_MASS
        ,EcDp_Unit.convertValue(stim.net_volume_bi, 'BBLS', a_b_c.volume_uom_code, stim.daytime)*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)  NET_VOLUME
        ,DECODE(EcDp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id),-1,'IN',1,'OUT')                                                                                                                                      IN_OUT
        ,RTRIM(RPAD(ec_node.object_code(between_node1.node_object_id),250))                                                                                                                                                                                                  BETWEEN_NODE1_CODE      -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(ec_node_version.name(between_node1.node_object_id,stim.daytime,'<='),250))                                                                                                                                                                                                  BETWEEN_NODE1_NAME      -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(ec_node.object_code(between_node2.node_object_id),250))                                                                                                                                                                                                  BETWEEN_NODE2_CODE      -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(ec_node_version.name(between_node2.node_object_id,stim.daytime,'<='),250))                                                                                                                                                                                                  BETWEEN_NODE2_NAME      -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('AT_NODE', si.object_id, stim.daytime,'CODE'),250))                                                                                                                                                                                                   AT_NODE_CODE            -- STREAM_ITEM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('AT_NODE', si.object_id, stim.daytime,'NAME'),250))                                                                                                                                                                                                   AT_NODE_NAME            -- STREAM_ITEM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('FROM_NODE', si.object_id, stim.daytime,'CODE'),250))                                                                                                                                                                                               FROM_NODE_CODE          -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('FROM_NODE', si.object_id, stim.daytime,'NAME'),250))                                                                                                                                                                                               FROM_NODE_NAME          -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('TO_NODE', si.object_id, stim.daytime,'CODE'),250))                                                                                                                                                                                                 TO_NODE_CODE            -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('TO_NODE', si.object_id, stim.daytime,'NAME'),250))                                                                                                                                                                                                 TO_NODE_NAME            -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(sv.stream_category,250))                                                                                                                                                                                                 STREAM_CATEGORY_CODE    -- STREAM.STREAM_CATEGORY_CODE
        ,RTRIM(RPAD(si.object_code,250))                                                                                                                                                                                                                STREAM_ITEM_CODE        -- STREAM_ITEM.CODE
        ,RTRIM(RPAD(siv.name,250))                                                                                                                                                                                                                STREAM_ITEM_NAME        -- STREAM_ITEM.NAME
        ,stim.status                                                                                                                                                                                                                                                                                     STATUS                  -- STIM_MTH_ACTUAL.STATUS
        ,stim.net_energy_jo*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                           NET_ENERGY_JO           -- STIM_MTH_ACTUAL.NET_ENERGY_JO
        ,stim.net_energy_th*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                           NET_ENERGY_TH           -- STIM_MTH_ACTUAL.NET_ENERGY_TH
        ,stim.net_energy_wh*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                           NET_ENERGY_WH           -- STIM_MTH_ACTUAL.NET_ENERGY_WH
        ,stim.net_energy_be*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                           NET_ENERGY_BE           -- STIM_MTH_ACTUAL.NET_ENERGY_BE
        ,stim.net_mass_ma*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                             NET_MASS_MA             -- STIM_MTH_ACTUAL.NET_MASS_MA
        ,stim.net_mass_mv*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                             NET_MASS_MV             -- STIM_MTH_ACTUAL.NET_MASS_MV
        ,stim.net_mass_ua*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                             NET_MASS_UA             -- STIM_MTH_ACTUAL.NET_MASS_UA
        ,stim.net_mass_uv*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                             NET_MASS_UV             -- STIM_MTH_ACTUAL.NET_MASS_UV
        ,stim.net_volume_bi*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                           NET_VOLUME_BI           -- STIM_MTH_ACTUAL.NET_VOLUME_BI
        ,stim.net_volume_bm*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                           NET_VOLUME_BM           -- STIM_MTH_ACTUAL.NET_VOLUME_BM
        ,stim.net_volume_sf*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                           NET_VOLUME_SF           -- STIM_MTH_ACTUAL.NET_VOLUME_SF
        ,stim.net_volume_nm*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                           NET_VOLUME_NM           -- STIM_MTH_ACTUAL.NET_VOLUME_NM
        ,stim.net_volume_sm*Ecdp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id)                                                                                                                                           NET_VOLUME_SM           -- STIM_MTH_ACTUAL.NET_VOLUME_SM
FROM    stream s                                                 -- STREAM
        ,strm_version sv
        ,stream_item si                                               -- STREAM_ITEM
        ,stream_item_version siv
        ,balance b                                                -- BALANCE
        ,balance_version a_b_c                                  -- BALANCE ATTRIBUTE (CODE)
--        ,objects_relation s_si                                    -- STREAM -> STREAM_ITEM
        ,balance_setup b_si                                    -- BALANCE -> STREAM_ITEM
        ,stim_mth_actual stim                                     -- STIM_MTH_ACTUAL
        ,v_from_node_concat_to_node_ac BETWEEN_NODE1
        ,v_from_node_concat_to_node_ac BETWEEN_NODE2
WHERE
si.object_id = stim.object_id                                     -- STREAM_ITEM -> STIM_MTH_ACTUAL
-- attribute balance.code
AND     b.object_id = a_b_c.object_id                             -- BALANCE (OBJECT -> ATTRIBUTE)
AND     a_b_c.daytime = (SELECT MAX(daytime) FROM balance_version WHERE object_id = b.object_id AND daytime <= stim.daytime)
-- stream -> stram_item
AND     s.object_id = si.stream_id                                -- STREAM -> STREAM_ITEM
AND     sv.daytime = (SELECT MAX(daytime) FROM strm_version WHERE object_id = s.object_id AND daytime <= stim.daytime)
AND     si.object_id = siv.object_id
AND     siv.daytime = (SELECT MAX(daytime) FROM stream_item_version WHERE object_id = si.object_id AND daytime <= stim.daytime)
-- balance -> stream_item
AND     b.object_id = b_si.object_id                              -- BALANCE -> STREAM_ITEM
AND     si.object_id = b_si.stream_item_id                         -- BALANCE -> STREAM_ITEM
--      join in between_node1
AND     stim.daytime = between_node1.daytime                      -- STIM_MTH_ACTUAL -> ACROSS_NODE
AND     b.object_code = between_node1.attribute_text       -- BALANACE->STREAM_ITEM.ATTRIBUTE -> BETWEEN_NODE1
--      join in between_node2
AND     stim.daytime = between_node2.daytime                      -- STIM_MTH_ACTUAL -> ACROSS_NODE
AND     b.object_code = between_node2.attribute_text       -- BALANACE->STREAM_ITEM.ATTRIBUTE -> BETWEEN_NODE2
--      include only rows which is in the balance (IN_OUT is not null)
AND EcDp_Balance.GetBetweenNodeDirAc(b.object_id,si.object_id,stim.daytime,between_node1.node_object_id, between_node2.node_object_id) IS NOT NULL
)