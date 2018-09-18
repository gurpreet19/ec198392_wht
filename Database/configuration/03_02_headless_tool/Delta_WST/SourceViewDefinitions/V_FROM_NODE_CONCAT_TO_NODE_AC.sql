CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FROM_NODE_CONCAT_TO_NODE_AC" ("NODE_OBJECT_ID", "DAYTIME", "ATTRIBUTE_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- File name: v_from_node_concat_to_node.sql
-- View name: v_from_node_concat_to_node
--
-- $Revision: 1.5 $
--
-- Purpose  :     The view lists all distinct from_nodes and to_nodes where a connection stream/stream item/balance exists that are connected to the node.
--                All nodes is found under alias NODE_OBJECT_ID
--
-- Description :
--
-- Modification history:
--
-- Version Date       Whom  Change description:
----------------------------------------------------------------------------------------------------
--              24.01.2007  SRA     Migrated version
----------------------------------------------------------------------------------------------------
          -- Select all from nodes
          SELECT   xsv.from_node_id                                                                     NODE_OBJECT_ID
                  ,xstim.daytime                                                                        DAYTIME
                  ,xb.object_code                                                                       ATTRIBUTE_TEXT
          FROM    stream xs
                  ,strm_version xsv
                  ,stream_item xsi
                  ,balance xb
                  ,balance_setup xb_s
                  ,stim_mth_actual xstim                          -- stim_mth_actual
          WHERE
                  xs.object_id = xsv.object_id                    -- stream -> strm_version
                  AND xsv.daytime = (SELECT max(daytime) FROM strm_version WHERE object_id = xsv.object_id AND daytime <= xstim.daytime)
                  AND xsi.stream_id = xs.object_id                -- stream -> stream_item
                  AND xb_s.stream_item_id = xsi.object_id         -- balance_setup -> stream_item
                  AND xb.object_id = xb_s.object_id               -- balance_setup -> balance
                  AND xstim.object_id = xsi.object_id             -- stim -> stream_item
          UNION
          -- Select all to nodes
          SELECT   ysv.to_node_id                                                                       NODE_OBJECT_ID
                  ,ystim.daytime                                                                        DAYTIME
                  ,yb.object_code                                                                       ATTRIBUTE_TEXT
          FROM    stream ys
                  ,strm_version ysv
                  ,stream_item ysi
                  ,balance yb
                  ,balance_setup yb_s
                  ,stim_mth_actual ystim                          -- stim_mth_actual
          WHERE
                  ys.object_id = ysv.object_id                    -- stream -> strm_version
                  AND ysv.daytime = (SELECT max(daytime) FROM strm_version WHERE object_id = ysv.object_id AND daytime <= ystim.daytime)
                  AND ysi.stream_id = ys.object_id                -- stream -> stream_item
                  AND yb_s.stream_item_id = ysi.object_id         -- balance_setup -> stream_item
                  AND yb.object_id = yb_s.object_id               -- balance_setup -> balance
                  AND ystim.object_id = ysi.object_id             -- stim -> stream_item
)