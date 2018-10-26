CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_RE_ACROSS_NODE" ("NODE_OBJECT_ID", "DAYTIME", "B_OBJECT_ID", "B_CODE", "B_NAME") AS 
  (
---------------------------------------------------------------------------------------------------
-- File name: v_re_across_node.sql
-- View name: v_re_across_node
-- $Revision: 1.4 $
--
-- Purpose  : Used to retrieve information on hydrocarbon balance between nodes in EC
--	          The first section retrieves all from nodes and the second retrieves all to nodes
--
-- Modification history:
--
--  Version     Date        Whom    Change description:
---------------------------------------------------------------------------------------------------
--      1.0     14.06.2006  SSK     Initial version
--              24.01.2007  SRA     Migrated version
---------------------------------------------------------------------------------------------------
        -- Select all from nodes
          SELECT   ec_strm_version.from_node_id(si.STREAM_ID,xstim.DAYTIME,'<=')     NODE_OBJECT_ID
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
                  AND bv.daytime = (SELECT max(daytime) FROM balance_version WHERE object_id = b.object_id AND daytime <= xstim.daytime)
                  AND bv.object_id = bs.object_id
                  AND bs.stream_item_id = xstim.object_id
                  AND xstim.object_id = si.object_id
                  AND xstim.daytime BETWEEN b.start_date AND NVL(b.end_date, xstim.daytime)
                  AND ec_stream_item_version.reporting_category(xstim.object_id, xstim.daytime, '<=') <> 1
          UNION
          -- Select all to nodes
          SELECT   ec_strm_version.to_node_id(si.STREAM_ID,xstim.DAYTIME,'<=')       NODE_OBJECT_ID
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
                  AND bv.daytime = (SELECT max(daytime) FROM balance_version WHERE object_id = b.object_id AND daytime <= xstim.daytime)
                  AND bv.object_id = bs.object_id
                  AND bs.stream_item_id = xstim.object_id
                  AND xstim.object_id = si.object_id
                  AND xstim.daytime BETWEEN b.start_date AND NVL(b.end_date, xstim.daytime)
                  AND ec_stream_item_version.reporting_category(xstim.object_id, xstim.daytime, '<=') <> 1
)