CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_SYSTEM_SETTING" ("KEY", "LABEL", "VALUE", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT key
      ,c.label
      ,nvl(value_string,
           nvl((CASE WHEN key IN ('DEFERMENT_STATUS_RUNNING', 'DEFERMENT_STATUS_STOPPED') then RTRIM(to_char(value_number, 'FM99990D99999'), to_char(0, 'D'))
                    ELSE to_char(value_number)
                END),
           to_char(value_date))) VALUE
      ,daytime daytime
      ,NULL record_status
      ,NULL created_by
      ,NULL created_date
      ,NULL last_updated_by
      ,NULL last_updated_date
      ,NULL rev_no
      ,NULL rev_text
  FROM ctrl_property cp
  JOIN ctrl_property_meta c
 USING (key)
 WHERE c.version_type = 'SYSTEM'
UNION ALL
SELECT key
      ,label
      ,nvl(default_value_string,
           nvl((CASE WHEN key IN ('DEFERMENT_STATUS_RUNNING', 'DEFERMENT_STATUS_STOPPED') then RTRIM(to_char(default_value_number, 'FM99990D99999'), to_char(0, 'D'))
                    ELSE to_char(default_value_number)
                END),
               to_char(default_value_date))) VALUE
      ,TO_DATE('1900-01-01','YYYY-MM-DD') daytime
      ,NULL record_status
      ,NULL created_by
      ,NULL created_date
      ,NULL last_updated_by
      ,NULL last_updated_date
      ,NULL rev_no
      ,NULL rev_text
  FROM ctrl_property_meta
 WHERE version_type = 'SYSTEM'