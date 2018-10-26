CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALENDAR_SETUP" ("DAYTIME", "CALENDAR_ID", "COMMENTS", "HOLIDAY_COMMENT", "COLOR_CODE", "TEXTCOLOR_CODE", "TOOLTIP", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  WITH calendar_query AS
 (SELECT cd.daytime AS daytime,
         c.object_id AS calendar_id,
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
         calendar_id,
         CASE WHEN holiday_ind = 'N' AND comments IS NOT NULL THEN 'COMMENT' ELSE 'HOLIDAY' END AS holiday_comment,
         comments AS tooltip
    FROM calendar_query)
SELECT cq.daytime,
       cq.calendar_id,
       cq.comments,
       tq.holiday_comment,
       CASE (tq.holiday_comment || (CASE WHEN (nvl(length(tooltip),0) > 0) THEN '' ELSE '_NULL' END))
           WHEN 'COMMENT' THEN ec_prosty_codes.alt_code('COMMENT_BG','CALENDAR_SETUP_COLOR')
           WHEN 'HOLIDAY' THEN ec_prosty_codes.alt_code('COMMENT_BG','CALENDAR_SETUP_COLOR')
           ELSE NULL
       END AS COLOR_CODE,
       ec_prosty_codes.alt_code(tq.holiday_comment,'CALENDAR_SETUP_COLOR') AS TEXTCOLOR_CODE,
       tq.tooltip,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
  FROM calendar_query cq,
       color_tooltip_query tq
 WHERE cq.daytime = tq.daytime
   AND cq.calendar_id = tq.calendar_id