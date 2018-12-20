CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_RE_HCB_ACCR_NODE_DAY_AC" ("DAYTIME", "BALANCE_CODE", "BALANCE_NAME", "BALANCE_CODE_NAME", "IN_OUT", "MASS_UOM_CODE", "VOLUME_UOM_CODE", "ENERGY_UOM_CODE", "NET_ENERGY", "NET_MASS", "NET_VOLUME", "ACROSS_NODE_CODE", "ACROSS_NODE_NAME", "AT_NODE_CODE", "AT_NODE_NAME", "FROM_NODE_CODE", "FROM_NODE_NAME", "TO_NODE_CODE", "TO_NODE_NAME", "FIELD_CODE", "FIELD_NAME", "STREAM_CATEGORY_CODE", "STREAM_ITEM_CODE", "STREAM_ITEM_NAME", "MASTER_UOM_GROUP", "STATUS", "NET_ENERGY_JO", "NET_ENERGY_TH", "NET_ENERGY_WH", "NET_ENERGY_BE", "NET_MASS_MA", "NET_MASS_MV", "NET_MASS_UA", "NET_MASS_UV", "NET_VOLUME_BI", "NET_VOLUME_BM", "NET_VOLUME_SF", "NET_VOLUME_NM", "NET_VOLUME_SM", "PRODUCT_CODE") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- File name: v_re_hcb_accr_node_day_ac.sql
-- View name: v_re_hcb_accr_node_day_ac
--
-- $Revision: 1.5 $
--
-- Purpose  : This report contains values for a hydrocarbon balance across node (actual version)
--
-- Description : The view contain a list of all stream_item objects that is connected to a balance object. The purpose of
--               this view is to get a across node balance. Positive or negative values in the balance is decided by the
--               function called GetStreamDir (in the Ecdb_Balance package). Only records that have a value in the IN_OUT
--               column should be a part of this balance. There are a join to a sub-select in this view. The purpose of
--               this sub-select is to get all nodes for each stream_item (accross_node). This results in a cartesian product.
--
-- Modification history:
--
-- Version Date       Whom  Change description:
----------------------------------------------------------------------------------------------------
-- 1.0     03.06.2006 SSK   Initial version
--         24.01.2007 SRA   Migrated version
----------------------------------------------------------------------------------------------------
SELECT  stim.daytime                                                                                                                                                                                                      DAYTIME                 -- STIM_DAY_ACTUAL.DAYTIME
        ,RTRIM(RPAD(across_node.b_code,250))                                                                                                                                                                              BALANCE_CODE            -- BALANCE.CODE
        ,RTRIM(RPAD(across_node.b_name,250))                                                                                                                                                                              BALANCE_NAME            -- BALANCE.NAME
        ,RTRIM(RPAD(across_node.b_code||' '||across_node.b_name,250))                                                                                                                                                     BALANCE_CODE_NAME       -- BALANCE.CODE||BALANCE.NAME
        ,DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),'OUT','IN')                                                                                                                                            IN_OUT                  --
        ,RTRIM(RPAD(bv.mass_uom_code,250))                                                                                                                         MASS_UOM_CODE           -- BALANCE.MASS_UOM_CODE
        ,RTRIM(RPAD(bv.volume_uom_code,250))                                                                                                                       VOLUME_UOM_CODE         -- BALANCE.VOLUME_UOM_CODE
        ,RTRIM(RPAD(bv.energy_uom_code,250))                                                                                                                       ENERGY_UOM_CODE         -- BALANCE.ENERGY_UOM_CODE
        ,EcDp_Unit.convertValue(stim.net_energy_jo, '100MJ', bv.energy_uom_code, stim.daytime)*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)   NET_ENERGY
        ,EcDp_Unit.convertValue(stim.net_mass_ma, 'MT', bv.mass_uom_code, stim.daytime)*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)          NET_MASS
        ,EcDp_Unit.convertValue(stim.net_volume_bi, 'BBLS', bv.volume_uom_code, stim.daytime)*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)  NET_VOLUME
        ,RTRIM(RPAD(ec_node.object_code(across_node.node_object_id),250))                                                                                                                     ACROSS_NODE_CODE        -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(ec_node_version.name(across_node.node_object_id,stim.daytime,'<='),250))                                                                                                                     ACROSS_NODE_NAME        -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime,'CODE'),250))                                                                                                                                                                              AT_NODE_CODE          -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime,'NAME'),250))                                                                                                                                                                              AT_NODE_NAME          -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime,'CODE'),250))                                                                                                                                                                              FROM_NODE_CODE          -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime,'NAME'),250))                                                                                                                                                                              FROM_NODE_NAME          -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime,'CODE'),250))                                                                                                                                                                                TO_NODE_CODE            -- STREAM.OBJECT_ID -> NODE.CODE
        ,RTRIM(RPAD(Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime,'NAME'),250))                                                                                                                                                                                TO_NODE_NAME            -- STREAM.OBJECT_ID -> NODE.NAME
        ,RTRIM(RPAD(ec_field.object_code(ec_stream_item_version.field_id(smv.object_id, smv.daytime, '<=')),250))                                                                                                         FIELD_CODE
        ,RTRIM(RPAD(ec_field_version.name(ec_stream_item_version.field_id(smv.object_id, smv.daytime, '<='), smv.daytime, '<='),250))                                                                                     FIELD_NAME
        ,RTRIM(RPAD(ec_stream_category.object_code(ec_strm_version.stream_category(ec_stream_item.stream_id(smv.object_id), smv.daytime, '<=')),250))                                                                     STREAM_CATEGORY_CODE    -- STREAM.STREAM_CATEGORY_CODE
        ,RTRIM(RPAD(ec_stream_item.object_code(smv.object_id) ,250))                                                                                                                                                      STREAM_ITEM_CODE        -- STREAM_ITEM.CODE
        ,RTRIM(RPAD(ec_stream_item_version.name(smv.object_id, smv.daytime, '<='),250))                                                                                                                                   STREAM_ITEM_NAME        -- STREAM_ITEM.NAME
        ,RTRIM(RPAD(ec_stream_item_version.master_uom_group(smv.object_id,smv.daytime,'<='),250))                                                                                                                         MASTER_UOM_GROUP        -- STREAM_ITEM.MASTER_UOM_GROUP
        ,stim.status                                                                                                                                                                                                      STATUS                  -- STIM_DAY_ACTUAL.STATUS
        ,stim.net_energy_jo*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_ENERGY_JO           -- STIM_DAY_ACTUAL.NET_ENERGY_JO
        ,stim.net_energy_th*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_ENERGY_TH           -- STIM_DAY_ACTUAL.NET_ENERGY_TH
        ,stim.net_energy_wh*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_ENERGY_WH           -- STIM_DAY_ACTUAL.NET_ENERGY_WH
        ,stim.net_energy_be*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_ENERGY_BE           -- STIM_DAY_ACTUAL.NET_ENERGY_BE
        ,stim.net_mass_ma  *DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_MASS_MA             -- STIM_DAY_ACTUAL.NET_MASS_MA
        ,stim.net_mass_mv  *DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_MASS_MV             -- STIM_DAY_ACTUAL.NET_MASS_MV
        ,stim.net_mass_ua  *DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_MASS_UA             -- STIM_DAY_ACTUAL.NET_MASS_UA
        ,stim.net_mass_uv  *DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_MASS_UV             -- STIM_DAY_ACTUAL.NET_MASS_UV
        ,stim.net_volume_bi*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_VOLUME_BI           -- STIM_DAY_ACTUAL.NET_VOLUME_BI
        ,stim.net_volume_bm*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_VOLUME_BM           -- STIM_DAY_ACTUAL.NET_VOLUME_BM
        ,stim.net_volume_sf*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_VOLUME_SF           -- STIM_DAY_ACTUAL.NET_VOLUME_SF
        ,stim.net_volume_nm*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_VOLUME_NM           -- STIM_DAY_ACTUAL.NET_VOLUME_NM
        ,stim.net_volume_sm*DECODE(across_node.node_object_id,Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime),1,-1)                                                                                                                               NET_VOLUME_SM           -- STIM_DAY_ACTUAL.NET_VOLUME_SM
        ,ec_product.object_code(ec_stream_item_version.product_id(smv.object_id, smv.daytime, '<='))                                                                                                                                                                PRODUCT_CODE            -- STIM_MTH_VALUE.PRODUCT_CODE
--        ,sic_so.attribute_value                                                                                                                                                                                           SIC_SORT_ORDER          -- STIM_MTH_VALUE.STREAM_ITEM_CATEGORY -> SORT_ORDER
FROM    stim_day_actual stim                                     -- STIM_DAY_ACTUAL
        ,stim_mth_value  smv
        ,v_re_across_node ACROSS_NODE
        ,balance b                                                -- BALANCE
        ,balance_version bv                                                -- BALANCE_VERSION
        ,balance_setup b_si                                    -- BALANCE -> STREAM_ITEM
--        ,objects_attribute  sic_so
WHERE   stim.object_id = smv.object_id                            -- STIM_DAY_ACTUAL -> STIM_MTH_VALUE
AND     TRUNC(stim.daytime,'MM') = smv.daytime                    -- STIM_DAY_ACTUAL -> STIM_MTH_VALUE
AND     b.object_id = b_si.object_id                             -- BALANCE -> STREAM_ITEM
AND     b.object_id = bv.object_id
AND     bv.daytime = (SELECT max(daytime) FROM balance_version WHERE object_id = b.object_id AND daytime <= smv.daytime)
AND     smv.daytime >= b_si.daytime
AND     smv.object_id = b_si.stream_item_id                          -- BALANCE -> STREAM_ITEM
AND     smv.daytime = across_node.daytime                         -- STIM_DAY_ACTUAL -> ACROSS_NODE
AND     b.object_id = across_node.b_object_id                     -- BALANACE->OBJECT_ID -> ACROSS_NODE
AND     ( ec_strm_version.from_node_id(ec_stream_item.stream_id(smv.object_id), smv.daytime, '<=') = across_node.node_object_id
       OR ec_strm_version.to_node_id(ec_stream_item.stream_id(smv.object_id), smv.daytime, '<=') = across_node.node_object_id  )
-- Ref VO007-13 Exclude stream items not measured at AT_NODE, if there is another
--              stream_item measured at AT_NODE belonging to the same STREAM
AND   NOT EXISTS (
      SELECT 1 FROM stim_mth_value smv2,
                    balance_setup b_si2
          WHERE    b_si2.object_id = b.object_id
          AND      smv2.object_id = b_si2.stream_item_id
          AND      smv2.daytime = smv.daytime
          AND      smv2.daytime >= Nvl(b_si2.daytime,smv2.daytime)
          AND      ec_stream_item.stream_id(smv2.object_id) = ec_stream_item.stream_id(smv.object_id)
          AND      Ecdp_Stream_Item.GetNode('FROM_NODE', smv2.object_id, smv2.daytime) = Ecdp_Stream_Item.GetNode('FROM_NODE', smv.object_id, smv.daytime)
          AND      Ecdp_Stream_Item.GetNode('TO_NODE', smv2.object_id, smv2.daytime) = Ecdp_Stream_Item.GetNode('TO_NODE', smv.object_id, smv.daytime)
          -- Critical part of check
          AND      Ecdp_Stream_Item.GetNode('AT_NODE', smv.object_id, smv.daytime) <> across_node.node_object_id
          AND      Ecdp_Stream_Item.GetNode('AT_NODE', smv2.object_id, smv2.daytime) = across_node.node_object_id
          AND      ec_stream_item_version.field_id(smv2.object_id, smv2.daytime, '<=') = ec_stream_item_version.field_id(smv.object_id, smv.daytime, '<=')
          )
)