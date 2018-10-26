CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_OBJ_LIST_CONTRACT" ("OBJECT_ID", "DAYTIME", "OBJECT_CODE", "SRC_CODE", "END_DATE", "NAME", "TRG_DATASET", "TRG_DATASET_NAME", "REPORT_REF", "REPORT_REF_NAME", "CONTRACT_ID", "CONTRACT_NAME", "TYPE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT cmss.object_id,
       cmv.daytime,
       cm.object_code,
       cmss.src_code,
       cmv.end_date,
       cmv.name,
       cmv.trg_dataset,
       ec_prosty_codes.code_text(cmv.trg_dataset, 'DATASET') trg_dataset_name,
       ec_report_reference.object_code(cmv.Report_Ref_Id) report_ref,
       ec_report_reference_version.name(cmv.report_ref_id, cmv.daytime, '<=') report_ref_name,
       nvl(cv.object_id, cce.element_id) contract_id,
       nvl(cv.name, ec_contract_version.name(cce.element_id, cmv.daytime, '<=')) contract_name,
       EcDp_ClassMeta_Cnfg.getLabel('CONTRACT') as Type,
       cmv.RECORD_STATUS,
       cmv.CREATED_BY,
       cmv.CREATED_DATE,
       cmv.LAST_UPDATED_BY,
       cmv.LAST_UPDATED_DATE,
       cmv.REV_NO,
       cmv.REV_TEXT
  FROM COST_MAPPING            cm,
       COST_MAPPING_SRC_SETUP  cmss,
       cost_mapping_version    cmv,
       CONTRACT_VERSION        cv,
       CALC_COLLECTION_ELEMENT cce
 WHERE cm.object_id = cmv.object_id
   and cmv.object_id = cmss.object_id
   and cv.object_id(+) = cmv.trg_contract_id
   and cce.object_id(+) = cmv.trg_contract_group_id
   and cmss.object_type = 'OBJECT_LIST'