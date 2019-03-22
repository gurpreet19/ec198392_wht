CREATE OR REPLACE PACKAGE ue_reconciliation IS
  /****************************************************************
  ** Package        :  ue_reconciliation, header part
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


  FUNCTION GetReconcileCode(p_reconciliation_no VARCHAR2,
                            p_reconcile_type VARCHAR2,
                            p_from_doc_key VARCHAR2,
                            p_to_doc_key VARCHAR2,
                            p_compare_type VARCHAR2)
  RETURN VARCHAR2;

  PROCEDURE VarianceTable (p_PERIOD VARCHAR2,
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
                        p_SHOW_ZERO_VARIANCE VARCHAR2 default null,
                        p_table IN OUT T_TABLE_MAPPING_VARIANCE);

  PROCEDURE variance_detail (p_PERIOD VARCHAR2,
                        p_GROUP_BY_CODE VARCHAR2 default null,
                        p_CONTRACT_INT VARCHAR2,
                        p_DOCUMENT_KEY VARCHAR2,
                        p_CONTRACT_HLD VARCHAR2,
                        p_GROUP_BY_VALUE VARCHAR2,
                        p_table IN OUT T_TABLE_MAPPING_VARIANCE) ;

UseUEReconcileCode BOOLEAN := FALSE;
UseUECMVarianceHandling BOOLEAN := FALSE;
UseUECMVarianceDetail BOOLEAN := FALSE;

END ue_reconciliation;