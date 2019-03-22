CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALENDAR_COLL_WIDGET" ("DAYTIME", "OBJECT_ID", "HOLIDAY_COMMENT", "COLOR_CODE", "TEXTCOLOR_CODE", "TOOLTIP", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  WITH calendar_coll_query AS
 (SELECT cd.daytime AS daytime,
         ccs.calendar_collection_id AS object_id,
         cv.name AS calendar_name,
         cd.holiday_ind AS holiday_ind,
         cc.comments AS comments,
         RANK() OVER (PARTITION BY cd.daytime, ccs.calendar_collection_id ORDER BY cv.object_id) rank_cal_coll
    FROM calendar c,
         calendar_version cv,
         calendar_coll_setup ccs,
         calendar_day cd,
         calendar_day_comment cc
   WHERE c.object_id = cv.object_id
     AND c.object_id = cd.object_id
     AND c.object_id = ccs.object_id
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
    FROM calendar_coll_query
   WHERE rank_cal_coll = 1),
tooltip_query AS
 (SELECT LISTAGG(holiday_detail, CHR(10)) WITHIN GROUP(ORDER BY holiday_detail) holiday_detail,
         object_id,
         daytime
    FROM (SELECT CASE WHEN ccq.comments IS NOT NULL
                      THEN ccq.calendar_name || ' : ' || listagg(ccq.comments, ',') WITHIN GROUP(ORDER BY ccq.comments)
                      ELSE ''
                      END holiday_detail,
                 ccq.object_id,
                 ccq.daytime
            FROM calendar_coll_query ccq
           GROUP BY ccq.daytime, ccq.object_id, ccq.calendar_name, ccq.comments)
   GROUP BY daytime, object_id)
SELECT cq.daytime,
       cq.object_id,
       ctq.holiday_comment,
       CASE (ctq.holiday_comment || (CASE WHEN (NVL(LENGTH(ctq.tooltip),0) > 0) THEN '' ELSE '_NULL' END))
           WHEN 'COMMENT' THEN ec_prosty_codes.alt_code('COMMENT_BG','CALENDAR_SETUP_COLOR')
           WHEN 'HOLIDAY' THEN ec_prosty_codes.alt_code('COMMENT_BG','CALENDAR_SETUP_COLOR')
           ELSE NULL
       END AS color_code,
       ec_prosty_codes.alt_code(ctq.holiday_comment,'CALENDAR_SETUP_COLOR') AS textcolor_code,
       tq.holiday_detail tooltip,
       NULL AS record_status,
       NULL AS created_by,
       NULL AS created_date,
       NULL AS last_updated_by,
       NULL AS last_updated_date,
       NULL AS rev_no,
       NULL AS rev_text
  FROM calendar_coll_query cq,
       color_tooltip_query ctq,
       tooltip_query tq
 WHERE cq.daytime = ctq.daytime
   AND cq.object_id = ctq.object_id
   AND cq.object_id = tq.object_id
   AND cq.daytime = tq.daytime
   AND cq.rank_cal_coll = 1