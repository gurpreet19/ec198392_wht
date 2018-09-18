CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_MNGR_CARGO_CALENDAR" ("DAYTIME", "BERTH_ID", "CARGO_NAME", "FORECAST_ID", "LIFTING_ACCOUNT_ID", "COUNT_BERTH", "DETAIL_CODE", "COLOR_CODE", "TEXTCOLOR_CODE", "TOOLTIP", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  WITH fcst_cargo_calendar_query AS
 (SELECT sd.daytime AS DAYTIME, cft.berth_id AS BERTH_ID, cft.cargo_name, sfln.forecast_id AS FORECAST_ID, sfln.lifting_account_id as LIFTING_ACCOUNT_ID
    FROM (system_days sd LEFT JOIN stor_fcst_lift_nom sfln ON
          sd.daytime = nvl(sfln.nom_firm_date, sfln.requested_date)),
         cargo_fcst_transport cft,
         cargo_status_mapping csm
   WHERE cft.cargo_no = sfln.cargo_no
     AND csm.cargo_status = cft.cargo_status
     AND csm.ec_cargo_status <> 'D'
     and sfln.forecast_id = cft.forecast_id
     and nvl(sfln.DELETED_IND, 'N') <> 'Y'
GROUP BY sd.daytime, cft.berth_id, cft.cargo_name,sfln.forecast_id,sfln.lifting_account_id),
--Set the detail_code for each cargo. It will count the berth to check for conflict and occupied cargo. Berth name will be use in tooltip_query
fcst_detail_code_query AS
 (SELECT daytime,
         berth_id,
         forecast_id,
         count(berth_id) AS count_berth,
         CASE WHEN berth_id IS NOT NULL AND count(1) > 1 THEN 'CONFLICT' ELSE 'OCCUPIED' END AS DETAIL_CODE,
         ec_berth_version.name(berth_id, daytime, '<=') AS berth_name
    FROM fcst_cargo_calendar_query
   GROUP BY daytime, berth_id, forecast_id),
--List the tooltip for each cargo in format Detail Code<next line> Berth Name : Cargo Name eg. Occupied<next line>Berth No. 1 : TS1_CARGO20
fcst_tooltip_query AS
 (SELECT listagg(cargo_detail, chr(10)) WITHIN GROUP(ORDER BY cargo_detail) cargo_name,
         daytime,
         forecast_id
    FROM (SELECT nvl(ec_prosty_codes.code_text(DETAIL_CODE,'CARGO_CALENDAR_DETAIL'),
                     ec_prosty_codes.code_text('UNASSIGNED','CARGO_CALENDAR_DETAIL')) || chr(10) ||
           dcq.berth_name || ' : ' || listagg(cargo_name, ',') WITHIN GROUP(ORDER BY cargo_name) cargo_detail,
                 ccq.daytime,
                 ccq.forecast_id
            FROM fcst_cargo_calendar_query ccq
            LEFT JOIN fcst_detail_code_query dcq
              ON ccq.daytime = dcq.daytime
             AND ccq.berth_id = dcq.berth_id
             AND ccq.forecast_id = dcq.forecast_id
           GROUP BY detail_code, ccq.daytime, dcq.berth_name,ccq.forecast_id)
   GROUP BY daytime, forecast_id)
SELECT cc.daytime AS DAYTIME,
       cc.berth_id AS BERTH_ID,
       cc.cargo_name,
       cc.forecast_id AS FORECAST_ID,
       cc.lifting_account_id AS LIFTING_ACCOUNT_ID,
       count_berth,
       nvl(ue_Stor_Fcst_Lift_Nom.getCalendarDetail(cc.daytime, cc.berth_id, cc.forecast_id),nvl(DETAIL_CODE, 'UNASSIGNED')) AS DETAIL_CODE,
       ec_prosty_codes.alt_code(nvl(ue_Stor_Fcst_Lift_Nom.getCalendarDetail(cc.daytime, cc.berth_id, cc.forecast_id),
                                nvl(DETAIL_CODE,'UNASSIGNED')),'CARGO_CALENDAR_DETAIL') AS COLOR_CODE,
       ue_Stor_Fcst_Lift_Nom.getTextColor(cc.daytime, cc.berth_id, cc.forecast_id) AS TEXTCOLOR_CODE,
       nvl(ue_Stor_Fcst_Lift_Nom.getCalendarTooltipFcstMngr(cc.daytime, cc.berth_id, cc.forecast_id, cc.lifting_account_id), tt.cargo_name) AS TOOLTIP,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
  FROM fcst_cargo_calendar_query cc
  LEFT OUTER JOIN fcst_detail_code_query dc
    ON cc.daytime = dc.daytime
   AND cc.berth_id = dc.berth_id
   AND cc.forecast_id = dc.forecast_id
  LEFT OUTER JOIN fcst_tooltip_query tt
    ON cc.daytime = tt.daytime
   AND cc.forecast_id = tt.forecast_id