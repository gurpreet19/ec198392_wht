CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALENDAR_COLL_LIST" ("CALENDAR_COLLECTION_ID", "CALENDAR_ID", "CALENDAR_CODE", "CALENDAR_NAME", "MAX_YEAR", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  WITH cal_coll_setup AS
 (SELECT ccs.calendar_collection_id,
             ccs.object_id,
             o.object_code,
             ec_calendar_version.name(o.object_id, oa.daytime, '<=') calendar_name
        FROM  calendar_coll_setup ccs
        INNER JOIN calendar_version oa ON oa.object_id = ccs.object_id AND ccs.daytime >= oa.daytime AND (oa.end_date is NULL OR ccs.daytime < oa.end_date)
        INNER JOIN calendar o ON o.object_id = oa.object_id)
SELECT calendar_collection_id,
       calendar_id,
       calendar_code,
       calendar_name,
       max_year,
       daytime,
       NULL record_status,
       NULL created_by,
       NULL created_date,
       NULL last_updated_by,
       NULL last_updated_date,
       NULL rev_no,
       NULL rev_text
FROM (
      SELECT ccs.calendar_collection_id,
             ccs.object_id   calendar_id,
             ccs.object_code calendar_code,
             ccs.calendar_name,
             cy.max_year,
             CASE WHEN cy.max_year IS NOT NULL
                  THEN TO_DATE('01-JAN-' || cy.max_year, 'DD-MON-RRRR')
                  ELSE NULL END daytime
        FROM cal_coll_setup ccs,
            (SELECT object_id,
                    MAX(year) max_year
               FROM v_calendar_year
           GROUP BY object_id) cy
       WHERE ccs.object_id = cy.object_id (+)
       UNION
       SELECT DISTINCT ccs.calendar_collection_id,
                       'ALL_CALENDARS' calendar_id,
                       'ALL'           calendar_code,
                       'All'           calendar_name,
                       c.max_year,
                       CASE WHEN c.max_year IS NOT NULL
                            THEN TO_DATE('01-JAN-' || c.max_year, 'DD-MON-RRRR')
                            ELSE NULL END daytime
         FROM cal_coll_setup ccs,
             (SELECT ccs.calendar_collection_id,
                     MAX(year) max_year
                FROM cal_coll_setup ccs,
                     v_calendar_year cy
               WHERE ccs.object_id = cy.object_id
            GROUP BY ccs.calendar_collection_id) c
        WHERE ccs.calendar_collection_id = c.calendar_collection_id(+)
      )