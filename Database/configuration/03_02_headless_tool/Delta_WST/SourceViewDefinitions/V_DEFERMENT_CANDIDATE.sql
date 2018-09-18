CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DEFERMENT_CANDIDATE" ("OBJECT_ID", "DAYTIME", "START_DAYTIME", "END_DAYTIME", "EVENT_CREATED", "ERR_LOG", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT DISTINCT object_id
      ,NVL(CASE
            -- Ignore last row data for each object_id
            WHEN RANK() OVER(PARTITION BY object_id ORDER BY daytime DESC) <> 1 OR ( IS_OFFICIAL='Y' AND (RANK() OVER(PARTITION BY object_id ORDER BY daytime DESC))=1)
              THEN NVL(-- Consider daytime as start daytime if status =0
                         DECODE(status, 0, daytime),
                       -- Consider daytime of previous row if that has status =0
                         LAG(DECODE(status, 0, daytime)) OVER (PARTITION BY object_id ORDER BY object_id, daytime ASC)
                       )
            ELSE NULL
        END,CASE
            -- Ignore last row data for each object_id
            WHEN RANK() OVER(PARTITION BY object_id ORDER BY daytime DESC) <> 1 OR ( IS_OFFICIAL='Y' AND (RANK() OVER(PARTITION BY object_id ORDER BY daytime DESC))=1)
              THEN NVL(-- Consider daytime as end daytime if status =1
                         DECODE(status, 1, daytime),
                       -- Consider daytime of following row if that has status =1
                         LEAD(DECODE(status, 1, daytime)) OVER (PARTITION BY object_id ORDER BY object_id, daytime ASC)
                       )
            ELSE NULL
        END) Daytime
      , CASE
            -- Ignore last row data for each object_id
            WHEN RANK() OVER(PARTITION BY object_id ORDER BY daytime DESC) <> 1 OR ( IS_OFFICIAL='Y' AND (RANK() OVER(PARTITION BY object_id ORDER BY daytime DESC))=1)

              THEN NVL(-- Consider daytime as start daytime if status =0
                         DECODE(status, 0, daytime),
                       -- Consider daytime of previous row if that has status =0
                         LAG(DECODE(status, 0, daytime)) OVER (PARTITION BY object_id ORDER BY object_id, daytime ASC)
                       )
            ELSE NULL
        END start_daytime
      , CASE
            -- Ignore last row data for each object_id
            WHEN RANK() OVER(PARTITION BY object_id ORDER BY daytime DESC) <> 1 OR ( IS_OFFICIAL='Y' AND (RANK() OVER(PARTITION BY object_id ORDER BY daytime DESC))=1)
              THEN NVL(-- Consider daytime as end daytime if status =1
                         DECODE(status, 1, daytime),
                       -- Consider daytime of following row if
                       -- Next row is not last row for given object id
                       -- And it has status =1
                         CASE
                           WHEN RANK() OVER(PARTITION BY object_id ORDER BY daytime DESC) > 1
                           THEN LEAD(DECODE(status, 1, daytime)) OVER (PARTITION BY object_id ORDER BY object_id, daytime ASC)
                           ELSE NULL
                         END
                       )
            ELSE NULL
        END end_daytime
      ,event_created
      ,err_log
      ,NULL record_status
      ,NULL created_by
      ,NULL created_date
      ,NULL last_updated_by
      ,NULL last_updated_date
      ,NULL rev_no
      ,NULL rev_text
  FROM deferment_status_log