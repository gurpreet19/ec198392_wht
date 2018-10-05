CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_PENDING_STIM_PERIOD" ("STIM_PENDING_NO", "PERIOD", "DAYTIME", "STATUS_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  SELECT DISTINCT  spi.stim_pending_no                  STIM_PENDING_NO
                 ,spi.period                          PERIOD
                 , TRUNC(spi.daytime,'MM')            DAYTIME
                 , min(spi.status_code)               STATUS_CODE -- Failure is shown if it exists
                 , 'P'                                RECORD_STATUS
                 , 'SYSTEM'                           CREATED_BY
                 , to_date('1900-01-01','YYYY-MM-DD') CREATED_DATE
                 , 'SYSTEM'                           LAST_UPDATED_BY
                 , to_date('1900-01-01','YYYY-MM-DD') LAST_UPDATED_DATE
                 , 0                                  REV_NO
                 , 'NA'                               REV_TEXT
                 , NULL                               APPROVAL_STATE
                 , NULL                               APPROVAL_BY
                 , NULL                               APPROVAL_DATE
                 , NULL                               REC_ID
FROM stim_pending_item spi
group by spi.stim_pending_no,spi.period,TRUNC(spi.daytime,'MM')