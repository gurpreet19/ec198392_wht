CREATE OR REPLACE PACKAGE ecdp_reconciliation IS
  /****************************************************************
  ** Package        :  ecdp_reconciliation, header part
  **
  ** $Revision: 1.0 $
  **
  ** Purpose        :  To reconcile the 2 runs of the royalty calculation
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created  : 10.07.2016  Swastik Jain
  **
  ** Modification history:
  **
  ** Version  Date        Whom  Change description:
  ** -------  ------      ----- --------------------------------------
  ********************************************************************/

  FUNCTION RunExtract(p_compare_type VARCHAR2, p_document_key NUMBER)
    RETURN VARCHAR2;

  PROCEDURE RunExtractLine(p_recon_no NUMBER,
                           p_daytime  DATE,
                           p_line_tag VARCHAR2);

  FUNCTION GetReconcileCode(p_reconciliation_no VARCHAR2,
                            p_reconcile_type    VARCHAR2,
                            p_from_doc_key      NUMBER,
                            p_to_doc_key        NUMBER,
                            p_compare_type      VARCHAR2) RETURN VARCHAR2;

  PROCEDURE RunTIP(p_document_key NUMBER, p_compare_type VARCHAR2);

  FUNCTION RunTILP(p_recon_tiP_no NUMBER) RETURN VARCHAR2;

  FUNCTION RunTILP_SRC(p_recon_tilp_no number) RETURN VARCHAR2;

  FUNCTION GetRoyParams(p_type VARCHAR2, p_dsf_detail_id VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION GetVariance(p_search_param VARCHAR2,
                       p_search_val   VARCHAR2,
                       p_table_name   VARCHAR2) RETURN VARCHAR2;

  FUNCTION accrual_ind(p_document_key VARCHAR2)
  RETURN CALC_REFERENCE.ACCRUAL_IND%TYPE;
  FUNCTION summary_setup_id(p_dataset VARCHAR2)
  RETURN varchar2;
  FUNCTION IsSummary(p_inventory_id VARCHAR2) RETURN VARCHAR2;

  FUNCTION VarianceTable (p_PERIOD VARCHAR2,
                        p_GROUP_BY_CODE VARCHAR2 default null,
                        p_RECON_TYPE VARCHAR2 default null,
                        p_CONTRACT_PS VARCHAR2 default null,
                        p_CONTRACT_INT VARCHAR2,
                        p_DOC_TYPE VARCHAR2 default null,
                        p_FIN_WBS VARCHAR2 default null,
                        p_FIN_COST_CENTER_CODE VARCHAR2 default null,
                        p_FIN_ACCOUNT_CODE VARCHAR2 default null,
                        p_DATASET VARCHAR2 default null,
                        p_DOCUMENT_KEY VARCHAR2,
                        p_CONTRACT_HLD VARCHAR2,
                        p_AMOUNT VARCHAR2 default null,
                        p_QTY VARCHAR2 default null,
                        p_SHOW_ZERO_VARIANCE VARCHAR2 default null)
  RETURN T_TABLE_MAPPING_VARIANCE;

  FUNCTION variance_detail (p_PERIOD VARCHAR2,
                        p_GROUP_BY_CODE VARCHAR2,
                        p_CONTRACT_INT VARCHAR2,
                        p_DOCUMENT_KEY VARCHAR2,
                        p_CONTRACT_HLD VARCHAR2,
                        p_GROUP_BY_VALUE VARCHAR2)

  RETURN T_TABLE_MAPPING_VARIANCE;

END ecdp_reconciliation;