CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_RE_HCB_BETWEEN_NODES_BOO" ("BALANCE", "MONTH", "BALANCE_CODE", "BALANCE_NAME", "BALANCE_CODE_NAME", "OBJECT_ID", "DAYTIME", "MASS_UOM_CODE", "VOLUME_UOM_CODE", "ENERGY_UOM_CODE", "NET_ENERGY", "NET_MASS", "NET_VOLUME", "IN_OUT", "BETWEEN_NODE1_CODE", "BETWEEN_NODE1_NAME", "BETWEEN_NODE2_CODE", "BETWEEN_NODE2_NAME", "AT_NODE_CODE", "AT_NODE_NAME", "FROM_NODE_CODE", "FROM_NODE_NAME", "TO_NODE_CODE", "TO_NODE_NAME", "FIELD_CODE", "FIELD_NAME", "STREAM_CATEGORY_CODE", "STREAM_ITEM_CODE", "STREAM_ITEM_NAME", "MASTER_UOM_GROUP", "STATUS", "NET_ENERGY_JO", "NET_ENERGY_TH", "NET_ENERGY_WH", "NET_ENERGY_BE", "NET_MASS_MA", "NET_MASS_MV", "NET_MASS_UA", "NET_MASS_UV", "NET_VOLUME_BI", "NET_VOLUME_BM", "NET_VOLUME_SF", "NET_VOLUME_NM", "NET_VOLUME_SM", "PRODUCT_CODE") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- File name: v_re_hcb_between_nodes_boo.sql
-- View name: v_re_hcb_between_nodes_boo
-- $Revision: 1.10 $
--
-- Purpose  : This report contains values for a hydrocarbon balance between connected nodes
--
-- Description : The view contain a list of all stream_item objects that is connected to a balance object. The purpose of
--               this view is to get a between node balance. Positive or negative values in the balance is decided by the
--               function called GetBetweenNodeDir (in the Ecdb_Balance package). Only records that have a value in the
--               IN_OUT column should be a part of the balance. There are two joins to sub-selects in this view. The purpose
--               of these sub selects is to get all nodes for each stream_item (between_node1) against all nodes for each
--               stream_item (between_node2). This results in a cartesian product.
--
-- Modification history:
--
-- Version Date       Whom  Change description:
----------------------------------------------------------------------------------------------------
--         12.02.2007 SRA   Migrated version
----------------------------------------------------------------------------------------------------
SELECT  b.object_id                                                                                                                                                                                                           BALANCE
        ,TO_CHAR(smv.daytime,'YYYY/MM')                                                                                                                                                                                       MONTH                   -- STIM_MTH_BOOKED.DAYTIME
        ,RTRIM(RPAD(between_node1.b_code,250))                                                                                                                                                                                BALANCE_CODE            -- BALANCE.CODE
        ,RTRIM(RPAD(between_node1.b_name,250))                                                                                                                                                                                BALANCE_NAME            -- BALANCE.NAME
        ,RTRIM(RPAD(between_node1.b_code||' '||between_node1.b_name,250))                                                                                                                                                     BALANCE_CODE_NAME
        ,smv.object_id                                                                                                                                                                                                        OBJECT_ID
        ,smv.daytime                                                                                                                                                                                                          DAYTIME                 -- STIM_MTH_BOOKED.DAYTIME
        ,RTRIM(RPAD(bv.mass_uom_code,250))                                                                                                                          MASS_UOM_CODE           -- BALANCE.MASS_UOM_CODE
        ,RTRIM(RPAD(bv.volume_uom_code,250))                                                                                                                        VOLUME_UOM_CODE         -- BALANCE.VOLUME_UOM_CODE
        ,RTRIM(RPAD(bv.energy_uom_code,250))                                                                                                                        ENERGY_UOM_CODE         -- BALANCE.ENERGY_UOM_CODE
        ,EcDp_Unit.convertValue(stim.net_energy_jo, '100MJ', bv.energy_uom_code, stim.daytime)*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)   NET_ENERGY
        ,EcDp_Unit.convertValue(stim.net_mass_ma, 'MT', bv.mass_uom_code, stim.daytime)*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)          NET_MASS
        ,EcDp_Unit.convertValue(stim.net_volume_bi, 'BBLS', bv.volume_uom_code, stim.daytime)*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)  NET_VOLUME
        ,DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime), Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),'IN','OUT')                                                                                                                                                        IN_OUT
        ,RTRIM(RPAD(between_node1.node_CODE,250))                                                                                                                                                                              BETWEEN_NODE1_CODE      -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(between_node1.node_NAME,250))                                                                                                                                                                              BETWEEN_NODE1_NAME      -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(between_node2.node_CODE,250))                                                                                                                                                                              BETWEEN_NODE2_CODE      -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(between_node2.node_NAME,250))                                                                                                                                                                              BETWEEN_NODE2_NAME      -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime,'CODE'),250))                                                                                                                                                                                        AT_NODE_CODE            -- STREAM_ITEM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime,'NAME'),250))                                                                                                                                                                                        AT_NODE_NAME            -- STREAM_ITEM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime,'CODE'),250))                                                                                                                                                                                   FROM_NODE_CODE          -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime,'NAME'),250))                                                                                                                                                                                   FROM_NODE_NAME          -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime,'CODE'),250))                                                                                                                                                                                     TO_NODE_CODE            -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime,'NAME'),250))                                                                                                                                                                                     TO_NODE_NAME            -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(ec_field.object_code(ec_stream_item_version.field_id(smv.object_id, smv.daytime, '<=')),250))                                                                                                                                                                                       FIELD_CODE
        ,RTRIM(RPAD(ec_field_version.name(ec_stream_item_version.field_id(smv.object_id, smv.daytime, '<='), smv.daytime, '<='),250))                                                                                                                                                                                       FIELD_NAME
        ,RTRIM(RPAD(ec_strm_version.stream_category(si.stream_id, smv.daytime, '<='),250))                                                                                                                                                                             STREAM_CATEGORY_CODE    -- STREAM.STREAM_CATEGORY_CODE
        ,RTRIM(RPAD(ec_stream_item.object_code(smv.object_id),250))                                                                                                                                                                                 STREAM_ITEM_CODE        -- STREAM_ITEM.CODE
        ,RTRIM(RPAD(ec_stream_item_version.name(smv.object_id, smv.daytime, '<='),250))                                                                                                                                                                                 STREAM_ITEM_NAME        -- STREAM_ITEM.NAME
        ,RTRIM(RPAD(ec_stream_item_version.master_uom_group(smv.object_id,smv.daytime,'<='),250))                                                                                                                              MASTER_UOM_GROUP        -- STREAM_ITEM.MASTER_UOM_GROUP
        ,stim.status                                                                                                                                                                                                           STATUS                  -- STIM_MTH_BOOKED.STATUS
        ,stim.net_energy_jo*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_ENERGY_JO           -- STIM_DAY_ACTUAL.NET_ENERGY_JO
        ,stim.net_energy_th*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_ENERGY_TH           -- STIM_DAY_ACTUAL.NET_ENERGY_TH
        ,stim.net_energy_wh*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_ENERGY_WH           -- STIM_DAY_ACTUAL.NET_ENERGY_WH
        ,stim.net_energy_be*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_ENERGY_BE           -- STIM_DAY_ACTUAL.NET_ENERGY_BE
        ,stim.net_mass_ma  *DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_MASS_MA             -- STIM_DAY_ACTUAL.NET_MASS_MA
        ,stim.net_mass_mv  *DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_MASS_MV             -- STIM_DAY_ACTUAL.NET_MASS_MV
        ,stim.net_mass_ua  *DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_MASS_UA             -- STIM_DAY_ACTUAL.NET_MASS_UA
        ,stim.net_mass_uv  *DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_MASS_UV             -- STIM_DAY_ACTUAL.NET_MASS_UV
        ,stim.net_volume_bi*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_VOLUME_BI           -- STIM_DAY_ACTUAL.NET_VOLUME_BI
        ,stim.net_volume_bm*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_VOLUME_BM           -- STIM_DAY_ACTUAL.NET_VOLUME_BM
        ,stim.net_volume_sf*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_VOLUME_SF           -- STIM_DAY_ACTUAL.NET_VOLUME_SF
        ,stim.net_volume_nm*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_VOLUME_NM           -- STIM_DAY_ACTUAL.NET_VOLUME_NM
        ,stim.net_volume_sm*DECODE(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime),Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),-1,1)                                                                                                                               NET_VOLUME_SM           -- STIM_DAY_ACTUAL.NET_VOLUME_SM
        ,ec_product.object_code(ec_stream_item_version.product_id(smv.object_id, smv.daytime, '<='))                                                                                                                                                                                                     PRODUCT_CODE            -- STIM_MTH_VALUE.PRODUCT_CODE
--        ,sic_so.attribute_value                                                                                                                                                                                               SIC_SORT_ORDER                      -- STIM_MTH_VALUE.STREAM_ITEM_CATEGORY -> SORT_ORDER
FROM    balance b                                                                                                                                                                                                             -- BALANCE
        ,balance_version bv
        ,balance_setup b_si                                                                                                                                                                                                -- BALANCE -> STREAM_ITEM
        ,stim_mth_booked stim                                                                                                                                                                                                 -- STIM_MTH_BOOKED
        ,stim_mth_value  smv
        ,stream_item si
        ,stream_item_version siv
        -- Sub select that lists all distinct nodes (from_node and to_node) that a stream is connected too.
        , v_re_between_node                                                                                                                                                                                                   BETWEEN_NODE1
        , v_re_between_node                                                                                                                                                                                                   BETWEEN_NODE2
--        ,objects_attribute  sic_so
WHERE   stim.object_id = smv.object_id
AND     stim.daytime = smv.daytime
AND     b.object_id = bv.object_id
AND     bv.daytime = (SELECT MAX(daytime) FROM balance_version WHERE object_id = bv.object_id AND daytime <= stim.daytime)
AND     siv.daytime = (SELECT MAX(daytime) FROM stream_item_version WHERE object_id = si.object_id AND daytime <= stim.daytime)
AND     siv.object_id = si.object_id
-- balance -> stream_item
AND     b.object_id = b_si.object_id                                                                                                                                                                                  -- BALANCE -> STREAM_ITEM
AND     smv.object_id = b_si.stream_item_id                                                                                                                                                                                 -- BALANCE -> STREAM_ITEM
AND     b_si.stream_item_id = si.object_id
--AND     smv.daytime BETWEEN Nvl(b_si.start_date,smv.daytime) AND Nvl(b_si.end_date-1/(24*60*60),smv.daytime)
--      join in between_node1
AND     smv.daytime = between_node1.daytime                                                                                                                                                                                   -- STIM_MTH_BOOKED -> BETWEEN_NODE
AND     b.object_id = between_node1.b_object_id                                                                                                                                                                               -- BALANACE->STREAM_ITEM.ATTRIBUTE -> BETWEEN_NODE1
--      join in between_node2
AND     smv.daytime = between_node2.daytime                                                                                                                                                                                   -- STIM_MTH_BOOKED -> BETWEEN NODE
AND     b.object_id = between_node2.b_object_id                                                                                                                                                                               -- BALANACE->STREAM_ITEM.ATTRIBUTE -> BETWEEN_NODE2
--      include only rows which is in the balance (IN_OUT is not null)
AND     Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime) <> Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime)
AND     Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime) = BETWEEN_NODE1.node_object_id
AND     Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime) =  BETWEEN_NODE2.node_object_id
AND    (
         (Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime) = Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime)
          AND     EXISTS (
          SELECT 1 FROM stim_mth_value smv2,
                        balance_setup b_si2
          WHERE    b_si2.object_id = b.object_id
          AND      smv2.object_id = b_si2.stream_item_id
          AND      smv2.daytime = smv.daytime
--          AND      smv2.daytime BETWEEN Nvl(b_si2.start_date,smv2.daytime) AND Nvl(b_si2.end_date-1/(24*60*60),smv2.daytime)
          AND      ec_stream_item.stream_id(smv2.object_id) = ec_stream_item.stream_id(smv.object_id)
          AND      Ecdp_Stream_Item.GetNode('FROM_NODE', smv2.object_id, smv2.daytime) = Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime)
          AND      Ecdp_Stream_Item.GetNode('TO_NODE', smv2.object_id, smv2.daytime) = Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime)
          AND      ec_stream_item_version.field_id(smv2.object_id,smv2.daytime,'<=') = ec_stream_item_version.field_id(smv.object_id,smv.daytime,'<=') )
        )
        OR
         (Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime) = Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime)
          AND     EXISTS (
          SELECT 1 FROM stim_mth_value smv2,
                        balance_setup b_si2
          WHERE    b_si2.object_id = b.object_id
          AND      smv2.object_id = b_si2.stream_item_id
          AND      smv2.daytime = smv.daytime
--          AND      smv2.daytime BETWEEN Nvl(b_si2.start_date,smv2.daytime) AND Nvl(b_si2.end_date-1/(24*60*60),smv2.daytime)
          AND      ec_stream_item.stream_id(smv2.object_id) = ec_stream_item.stream_id(smv.object_id)
          AND      Ecdp_Stream_Item.GetNode('FROM_NODE', smv2.object_id, smv2.daytime) = Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime)
          AND      Ecdp_Stream_Item.GetNode('TO_NODE', smv2.object_id, smv2.daytime) = Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime)
          AND      ec_stream_item_version.field_id(smv2.object_id,smv2.daytime,'<=') = ec_stream_item_version.field_id(smv.object_id,smv.daytime,'<=') )
        )
    )
AND     siv.reporting_category <> 1
--AND    smv.stream_item_category_object_id = sic_so.object_id
--AND    smv.reporting_category <> 1
--AND    sic_so.class_name = 'STREAM_ITEM_CATEGORY'
--AND    sic_so.attribute_type = 'SORT_ORDER'
--AND    smv.daytime BETWEEN Nvl(sic_so.daytime,smv.daytime) AND Nvl(sic_so.end_date-1/(24*60*60),smv.daytime)
)