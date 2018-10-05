CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_RE_BETWEEN_NODE" ("NODE_OBJECT_ID", "NODE_CODE", "NODE_NAME", "DAYTIME", "B_OBJECT_ID", "B_CODE", "B_NAME") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- File name: v_re_between_node.sql
-- View name: v_re_between_node
--
-- $Revision: 1.4 $
--
-- Purpose  : Sub view to hydrocarbon balance Daily
--
-- Description : Distinct list of balance objects related nodes to through stream_items
--
-- Modification history:
--
-- Version Date       Whom  Change description:
----------------------------------------------------------------------------------------------------
--              24.01.2007  SRA     Migrated version
----------------------------------------------------------------------------------------------------
          -- Select all from nodes
          SELECT   ec_strm_version.from_node_id(si.STREAM_ID,xstim.DAYTIME,'<=')     NODE_OBJECT_ID
                  ,ec_node.object_code(ec_strm_version.from_node_id(si.STREAM_ID,xstim.DAYTIME,'<='))     NODE_CODE
                  ,ec_node_version.name(ec_strm_version.from_node_id(si.STREAM_ID,xstim.DAYTIME,'<='), xstim.daytime, '<=') NODE_NAME
                  ,xstim.daytime                                                     DAYTIME
                  ,b.object_id                                                       B_OBJECT_ID
                  ,b.object_code                                                     B_CODE
                  ,bv.name                                                           B_NAME
          FROM    balance b
                  ,balance_version bv
                  ,balance_setup bs
                  ,stim_mth_value xstim
                  ,stream_item si
          WHERE
                  b.object_id = bv.object_id
                  AND bv.daytime = ec_balance_version.prev_equal_daytime(b.object_id, xstim.daytime)
                  AND bv.object_id = bs.object_id
                  AND bs.stream_item_id = xstim.object_id
                  AND xstim.object_id = si.object_id
                  AND xstim.daytime BETWEEN b.start_date AND NVL(b.end_date, xstim.daytime)
                  AND ec_stream_item_version.reporting_category(xstim.object_id, xstim.daytime, '<=') <> 1
          UNION
          -- Select all to nodes
          SELECT   ec_strm_version.to_node_id(si.STREAM_ID,xstim.DAYTIME,'<=')     NODE_OBJECT_ID
                  ,ec_node.object_code(ec_strm_version.to_node_id(si.STREAM_ID,xstim.DAYTIME,'<='))     NODE_CODE
                  ,ec_node_version.name(ec_strm_version.to_node_id(si.STREAM_ID,xstim.DAYTIME,'<='), xstim.daytime, '<=') NODE_NAME
                  ,xstim.daytime                                                     DAYTIME
                  ,b.object_id                                                       B_OBJECT_ID
                  ,b.object_code                                                     B_CODE
                  ,bv.name                                                           B_NAME
          FROM    balance b
                  ,balance_version bv
                  ,balance_setup bs
                  ,stim_mth_value xstim
                  ,stream_item si
          WHERE
                  b.object_id = bv.object_id
                  AND bv.daytime = ec_balance_version.prev_equal_daytime(b.object_id, xstim.daytime)
                  AND bv.object_id = bs.object_id
                  AND bs.stream_item_id = xstim.object_id
                  AND xstim.object_id = si.object_id
                  AND xstim.daytime BETWEEN b.start_date AND NVL(b.end_date, xstim.daytime)
                  AND ec_stream_item_version.reporting_category(xstim.object_id, xstim.daytime, '<=') <> 1
)