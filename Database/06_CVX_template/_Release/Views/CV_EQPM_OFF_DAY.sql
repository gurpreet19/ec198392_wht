begin
execute immediate 'drop view cv_eqpm_off_day';
    exception when others then
    null;
end;
/

CREATE OR REPLACE FORCE VIEW CV_EQPM_OFF_DAY
(
   EVENT_NO,
   PARENT_EVENT_NO,
   MASTER_EVENT_ID,
   PARENT_MASTER_EVENT_ID,
   PARENT_OBJECT_ID,
   PARENT_DAYTIME,
   OBJECT_ID,
   OBJECT_TYPE,
   DEFERMENT_TYPE,
   EVENT_TYPE,
   DAYTIME,
   START_DATE,
   END_DATE,
   EQUIPMENT_ID,
   REASON_CODE_1,
   REASON_CODE_2,
   REASON_CODE_3,
   REASON_CODE_4,
   STATUS,
   COMMENTS,
   DUR_HRS_DAY,
   TEXT_1,
   TEXT_2,
   TEXT_3,
   TEXT_4,
   VALUE_1,
   VALUE_2,
   VALUE_3,
   VALUE_4,
   VALUE_5,
   VALUE_6,
   VALUE_7,
   VALUE_8,
   VALUE_9,
   VALUE_10,
   RECORD_STATUS,
   CREATED_BY,
   CREATED_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATED_DATE,
   REV_NO,
   REV_TEXT,
   APPROVAL_BY,
   APPROVAL_DATE,
   APPROVAL_STATE,
   REC_ID
)
   BEQUEATH DEFINER
AS
   SELECT D.EVENT_NO,
          D.PARENT_EVENT_NO,
          D.MASTER_EVENT_ID,
          D.PARENT_MASTER_EVENT_ID,
          D.PARENT_OBJECT_ID,
          D.PARENT_DAYTIME,
          D.OBJECT_ID,
          D.OBJECT_TYPE,
          D.DEFERMENT_TYPE,
          D.EVENT_TYPE,
          S.DAYTIME AS DAYTIME,
          D.DAYTIME AS START_DATE,
          D.END_DATE,
          D.EQUIPMENT_ID,
          D.REASON_CODE_1,
          D.REASON_CODE_2,
          D.REASON_CODE_3,
          D.REASON_CODE_4,
          D.STATUS,
          D.COMMENTS,
          GREATEST (
               (  LEAST (
                     NVL (D.END_DATE, S.DAYTIME + NVL (D.VALUE_2, 0) + 1),
                     S.DAYTIME + NVL(D.VALUE_2,0) + 1)
                - GREATEST (D.DAYTIME, S.DAYTIME + NVL (D.VALUE_2, 0)))
             * 24,
             0)
             AS DUR_HRS_DAY,
          D.TEXT_1,
          D.TEXT_2,
          D.TEXT_3,
          D.TEXT_4,
          D.VALUE_1,
          D.VALUE_2,
          D.VALUE_3,
          D.VALUE_4,
          D.VALUE_5,
          D.VALUE_6,
          D.VALUE_7,
          D.VALUE_8,
          D.VALUE_9,
          D.VALUE_10,
          D.RECORD_STATUS,
          D.CREATED_BY,
          D.CREATED_DATE,
          D.LAST_UPDATED_BY,
          D.LAST_UPDATED_DATE,
          D.REV_NO,
          D.REV_TEXT,
          D.APPROVAL_BY,
          D.APPROVAL_DATE,
          D.APPROVAL_STATE,
          D.REC_ID
     FROM DEFERMENT_EVENT D, SYSTEM_DAYS S
    WHERE     D.EVENT_TYPE = 'DOWN'
          AND D.OBJECT_TYPE IN (SELECT DISTINCT eqpm_type
                                  FROM equipment)
          AND S.DAYTIME + NVL (D.VALUE_2, 0) > D.DAYTIME - 1
          AND (   S.DAYTIME + NVL (D.VALUE_2, 0) < D.END_DATE
               OR D.END_DATE IS NULL)
          AND S.DAYTIME + NVL (D.VALUE_2, 0) <
                 ECDP_DATE_TIME.GETCURRENTSYSDATE - 1;

