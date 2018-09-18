CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CLASS_MAPPING_DATA_EXT" ("OBJECT_ID", "DAYTIME", "REVN_DATA_FILTER_ID", "EXTRACT_VALUE_TYPE", "EXTRACT_ATTRIBUTE", "REPORT_REF_ITEM_ID", "REC_ID", "REV_NO") AS 
  SELECT jou.object_id,
       jou.daytime,
       jou.revn_data_filter_id,
       jou.extract_value_type,
       jou.extract_attribute,
       NVL(i.object_id, '*ALL_REPORT_REF*') report_ref_item_id,
       jou.rec_id,
       jou.rev_no
FROM journal_mapping_data_ext jou,
     cost_mapping_version c,
     report_ref_item_version i
WHERE jou.object_id = c.object_id
AND jou.daytime = c.daytime
AND c.report_ref_group_id = i.report_ref_group_id(+)