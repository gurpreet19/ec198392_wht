CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALENDAR_SETUP" ("DAYTIME", "OBJECT_ID", "COMMENTS", "HOLIDAY_COMMENT", "COLOR_CODE", "TEXTCOLOR_CODE", "TOOLTIP", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  WITH calendar_query AS
 (SELECT cd.daytime AS daytime,
         c.object_id,
         cd.holiday_ind AS holiday_ind,
         cc.comments AS comments
    FROM calendar c,
         calendar_version cv,
         calendar_day cd,
         calendar_day_comment cc
   WHERE c.object_id = cv.object_id
     AND c.object_id = cd.object_id
     AND cd.object_id = cc.object_id (+)
     AND cd.daytime = cc.daytime (+)
     AND (cd.holiday_ind = 'Y' OR  (cd.holiday_ind = 'N' AND cc.comments IS NOT NULL))
     AND cd.daytime BETWEEN cv.daytime AND NVL(cv.end_date, cd.daytime + 1)
),
color_tooltip_query AS
 (SELECT daytime,
         object_id,
         CASE WHEN holiday_ind = 'N' AND comments IS NOT NULL THEN 'COMMENT' ELSE 'HOLIDAY' END AS holiday_comment,
         comments AS tooltip
    FROM calendar_query)
SELECT cq.daytime,
       cq.object_id,
       cq.comments,
       tq.holiday_comment,
       CASE (tq.holiday_comment || (CASE WHEN (NVL(LENGTH(tq.tooltip),0) > 0) THEN '' ELSE '_NULL' END))
           WHEN 'COMMENT' THEN ec_prosty_codes.alt_code('COMMENT_BG','CALENDAR_SETUP_COLOR')
           WHEN 'HOLIDAY' THEN ec_prosty_codes.alt_code('COMMENT_BG','CALENDAR_SETUP_COLOR')
           ELSE NULL
       END AS color_code,
       ec_prosty_codes.alt_code(tq.holiday_comment,'CALENDAR_SETUP_COLOR') AS textcolor_code,
       tq.tooltip,
       NULL AS record_status,
       NULL AS created_by,
       NULL AS created_date,
       NULL AS last_updated_by,
       NULL AS last_updated_date,
       NULL AS rev_no,
       NULL AS rev_text
  FROM calendar_query cq,
       color_tooltip_query tq
 WHERE cq.daytime = tq.daytime
   AND cq.object_id = tq.object_id