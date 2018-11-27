CREATE OR REPLACE PACKAGE EcDp_PPA_Price IS

  -- Author  : ROSNEDAG
  -- Created : 24.06.2011 12:17:52
  -- Purpose : Handle creation of Prior Period Adjustment documents for price changes.

TYPE t_doc_arr IS RECORD
  (
   dockey VARCHAR2(32),
   newdoc BOOLEAN
  );

TYPE t_docTable IS TABLE OF t_doc_arr;

TYPE t_source_doc_arr IS RECORD
  (
   dockey VARCHAR2(32)
  );

TYPE t_sourceDocTable IS TABLE OF t_source_doc_arr;


FUNCTION GenPriceAdjustmentDoc(p_contract_id  VARCHAR2,
                               p_period_from  DATE,
                               p_period_to    DATE,
                               p_user         VARCHAR2,
                               p_log_item_no  IN OUT NUMBER,
                               p_nav_id       VARCHAR2,
                               p_document_key VARCHAR2 DEFAULT NULL,
                               p_log_type VARCHAR2) RETURN VARCHAR2;



END EcDp_PPA_Price;