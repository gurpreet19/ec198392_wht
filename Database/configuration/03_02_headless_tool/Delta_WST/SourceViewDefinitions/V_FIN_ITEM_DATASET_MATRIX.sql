CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FIN_ITEM_DATASET_MATRIX" ("SORT_ORDER", "DAYTIME", "FIN_ITEM_ID", "FIN_ITEM_NAME", "UNIT", "OBJECT_LINK_TYPE", "OBJECT_LINK_ID", "COMPANY_ID", "TEMPLATE_CODE", "CONTRACT_AREA_ID", "TIME_SPAN", "FORMAT_MASK", "DATASET_VALUE_1", "DATASET_VALUE_2", "DATASET_VALUE_3", "DATASET_VALUE_4", "DATASET_VALUE_5", "DATASET_VALUE_6", "DATASET_VALUE_7", "DATASET_VALUE_8", "DATASET_VALUE_9", "DATASET_VALUE_10", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT rownum * 10 sort_order,
       daytime,
       fin_item_id,
       fin_item_name,
       unit,
       object_link_type,
       object_link_id,
       company_id,
       template_code,
       contract_area_id,
       time_span,
       format_mask,
       dataset_value_1,
       dataset_value_2,
       dataset_value_3,
       dataset_value_4,
       dataset_value_5,
       dataset_value_6,
       dataset_value_7,
       dataset_value_8,
       dataset_value_9,
       dataset_value_10,
       NULL record_status,
       NULL created_by,
       NULL created_date,
       NULL last_updated_by,
       NULL last_updated_date,
       NULL rev_no,
       NULL rev_text
FROM ( SELECT fi_entry.daytime,
              fi_entry.fin_item_id,
              ec_financial_item_version.name(fin_item_id, daytime, '<=') as fin_item_name,
              ec_code.dataset_value,
              fi_entry.value_result,
              fi_entry.unit,
              fi_entry.object_link_type,
              fi_entry.object_link_id,
              fi_entry.company_id,
              fi_entry.template_code,
              fi_entry.contract_area_id,
              fi_entry.time_span,
              fi_entry.format_mask
         FROM dv_fin_item_entry fi_entry,
          ( SELECT code,
                   dataset_value
              FROM v_fi_dataset_value
               ) ec_code
        WHERE fi_entry.dataset = ec_code.code
      )
       PIVOT
     (
     SUM(value_result)
       FOR dataset_value IN ('DATASET_VALUE_1'  AS DATASET_VALUE_1,
                             'DATASET_VALUE_2'  AS DATASET_VALUE_2,
                             'DATASET_VALUE_3'  AS DATASET_VALUE_3,
                             'DATASET_VALUE_4'  AS DATASET_VALUE_4,
                             'DATASET_VALUE_5'  AS DATASET_VALUE_5,
                             'DATASET_VALUE_6'  AS DATASET_VALUE_6,
                             'DATASET_VALUE_7'  AS DATASET_VALUE_7,
                             'DATASET_VALUE_8'  AS DATASET_VALUE_8,
                             'DATASET_VALUE_9'  AS DATASET_VALUE_9,
                             'DATASET_VALUE_10' AS DATASET_VALUE_10)
     )
ORDER BY DAYTIME, TIME_SPAN, FIN_ITEM_NAME