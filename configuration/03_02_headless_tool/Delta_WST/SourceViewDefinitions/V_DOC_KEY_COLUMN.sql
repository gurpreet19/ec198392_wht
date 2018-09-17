CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DOC_KEY_COLUMN" ("CLASS_NAME", "ATTRIBUTE_NAME", "LABEL", "SORT_ORDER", "DISABLED_IND", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (-------------------------------------------------------------------------------------
--  V_DOC_KEY_COLUMN
--
-- $Revision: 0.1 $
--
--  Purpose: Source view for DOC_KEY_COLUMN class which is used as source for the "Document Id Column" dropdown.
--
-- Modification history:
--
-- Date              Whom         Change description
-- -----------    ------------    ----------------------------------------------------
-- 22-FEB-2017 	  Vikas Mhetre    Initial Version (Ref. ECPD-43214)
--
-------------------------------------------------------------------------------------
SELECT
    class_name,
    attribute_name,
    label,
    sort_order,
    disabled_ind,
    NULL record_status,
    NULL created_by,
    NULL created_date,
    NULL last_updated_by,
    NULL last_updated_date,
    NULL rev_no,
    NULL rev_text,
    NULL approval_by,
    NULL approval_date,
    NULL approval_state,
    NULL rec_id
FROM (
    SELECT ca.class_name,
           ca.attribute_name,
           EcDp_ClassMeta_Cnfg.getLabel(ca.class_name, ca.attribute_name) AS label,
           EcDp_ClassMeta_Cnfg.getScreenSortOrder(ca.class_name, ca.attribute_name) AS sort_order,
           EcDp_ClassMeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name)disabled_ind,
           ca.data_type
    FROM class_attribute_cnfg ca
    UNION ALL
    SELECT cr.to_class_name,
           cr.db_sql_syntax,
           EcDp_ClassMeta_Cnfg.getLabel(cr.from_class_name, cr.to_class_name, cr.role_name) AS label,
           EcDp_ClassMeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name) AS sort_order,
           EcDp_ClassMeta_Cnfg.isDisabled(cr.from_class_name, cr.to_class_name, cr.role_name) AS disabled_ind,
           'STRING'
    FROM class_relation_cnfg cr
    )
WHERE NVL(DISABLED_IND,'N') != 'Y'
  AND DATA_TYPE IN ('STRING', 'NUMBER', 'INTEGER')
)