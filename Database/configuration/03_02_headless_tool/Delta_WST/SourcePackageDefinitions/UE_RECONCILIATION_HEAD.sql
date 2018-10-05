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

UseUEReconcileCode BOOLEAN := FALSE;

END ue_reconciliation;