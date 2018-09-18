CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CARGO_CALENDAR" ("DAYTIME", "BERTH_ID", "CARGO_NAME", "COUNT_BERTH", "DETAIL_CODE", "COLOR_CODE", "TEXTCOLOR_CODE", "TOOLTIP", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  WITH cargo_calendar_query AS --Join system_days, storage_lift_nomination, cargo_transport and cargo_status_mapping table
 (SELECT sd.daytime AS DAYTIME, ct.berth_id AS BERTH_ID, ct.cargo_name
    FROM (system_days sd LEFT JOIN storage_lift_nomination sln ON
          sd.daytime = nvl(sln.nom_firm_date, sln.requested_date)),
         cargo_transport ct,
         cargo_status_mapping csm
   WHERE ct.cargo_no = sln.cargo_no
     AND csm.cargo_status = ct.cargo_status
     AND csm.ec_cargo_status <> 'D'
   GROUP BY sd.daytime, ct.berth_id, ct.cargo_name),
detail_code_query AS --Set the detail_code for each cargo. It will count the berth to check for conflict and occupied cargo and get the berth name that will be use in tooltip_query
 (SELECT daytime,
         berth_id,
         count(1) AS count_berth,
         CASE WHEN berth_id IS NOT NULL AND count(1) > 1 THEN 'CONFLICT' ELSE 'OCCUPIED' END AS DETAIL_CODE,
         ec_berth_version.name(berth_id, daytime, '<=') AS berth_name
    FROM cargo_calendar_query
   GROUP BY daytime, berth_id),
tooltip_query AS --List the tooltip for each cargo in format Detail Code<next line> Berth Name : Cargo Name eg. Occupied<next line>Berth No. 1 : TS1_CARGO20
 (SELECT listagg(cargo_detail, chr(10)) WITHIN GROUP(ORDER BY cargo_detail) cargo_name,
         daytime
    FROM (SELECT nvl(ec_prosty_codes.code_text(DETAIL_CODE,'CARGO_CALENDAR_DETAIL'),
                     ec_prosty_codes.code_text('UNASSIGNED','CARGO_CALENDAR_DETAIL')) || chr(10) ||
					 dcq.berth_name || ' : ' || listagg(cargo_name, ',') WITHIN GROUP(ORDER BY cargo_name) cargo_detail,
                 ccq.daytime
            FROM cargo_calendar_query ccq
            LEFT JOIN detail_code_query dcq
              ON ccq.daytime = dcq.daytime
             AND ccq.berth_id = dcq.berth_id
           GROUP BY detail_code, ccq.daytime, dcq.berth_name)
   GROUP BY daytime)
SELECT cc.daytime AS DAYTIME,
       cc.berth_id AS BERTH_ID,
       cc.cargo_name,
       count_berth,
       nvl(ue_storage_lift_nomination.getCalendarDetail(cc.daytime, cc.berth_id),nvl(DETAIL_CODE, 'UNASSIGNED')) AS DETAIL_CODE,
       ec_prosty_codes.alt_code(nvl(ue_storage_lift_nomination.getCalendarDetail(cc.daytime, cc.berth_id),
                                nvl(DETAIL_CODE,'UNASSIGNED')),'CARGO_CALENDAR_DETAIL') AS COLOR_CODE,
       ue_storage_lift_nomination.getTextColor(cc.daytime, cc.berth_id) AS TEXTCOLOR_CODE,
       nvl(ue_storage_lift_nomination.getCalendarTooltip(cc.daytime, cc.berth_id), tt.cargo_name) AS TOOLTIP,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
  FROM cargo_calendar_query cc
  LEFT OUTER JOIN detail_code_query dc
    ON cc.daytime = dc.daytime
   AND cc.berth_id = dc.berth_id
  LEFT OUTER JOIN tooltip_query tt
    ON cc.daytime = tt.daytime