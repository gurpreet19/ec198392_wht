CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_IFAC_JOURNAL_ENTRY_DOC" ("SOURCE_DOC_NAME", "PERIOD", "UPLOAD_DATE", "SOURCE_DOC_VER", "IS_MAX_SOURCE_DOC_VER_IND", "JOURNAL_ENTRY_COUNT", "RECORD_STATUS", "APPROVAL_BY", "APPROVAL_DATE", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "OBJECT_ID", "REV_NO", "REV_TEXT") AS 
  SELECT
         ifac.source_doc_name AS source_doc_name
        ,TRUNC(ifac.PERIOD,'MM') AS PERIOD
        ,MIN(IFAC.Created_Date) AS upload_date
        ,ifac.source_doc_ver AS source_doc_ver
        ,ifac.is_max_source_doc_ver_ind AS is_max_source_doc_ver_ind
        ,COUNT(ifac.journal_entry_no) AS journal_entry_count
        ,MAX(record_status) AS record_status
        ,MAX(APPROVAL_BY) AS APPROVAL_BY
        ,MAX(APPROVAL_DATE) AS APPROVAL_DATE
        ,MAX(created_by) AS created_by
        ,MAX(created_date) AS created_date
        ,MAX(last_updated_by) AS last_updated_by
        ,MAX(last_updated_date) AS last_updated_date
        ,object_id AS object_id
        ,NULL AS rev_no
        ,NULL AS rev_text
    FROM IFAC_JOURNAL_ENTRY ifac
    GROUP BY ifac.source_doc_name, TRUNC(ifac.PERIOD,'MM'), ifac.source_doc_ver, ifac.is_max_source_doc_ver_ind,object_id