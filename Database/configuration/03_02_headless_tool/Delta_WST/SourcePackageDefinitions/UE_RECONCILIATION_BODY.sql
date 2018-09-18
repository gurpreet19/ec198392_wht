CREATE OR REPLACE PACKAGE BODY ue_reconciliation IS
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




---------------------------------------------------------------------------------------------------
-- Function      :   GetReconcileCode
-- Description    : Allows using a user exit for generating Code
---------------------------------------------------------------------------------------------------

function GetReconcileCode(p_reconciliation_no VARCHAR2,
                          p_reconcile_type VARCHAR2,
                          p_from_doc_key VARCHAR2,
                          p_to_doc_key VARCHAR2,
                          p_compare_type VARCHAR2)
return VARCHAR2 is
    lv2_Code VARCHAR2(32);
Begin
  lv2_Code := p_reconciliation_no;

	return lv2_Code;
end GetReconcileCode;

END ue_reconciliation;