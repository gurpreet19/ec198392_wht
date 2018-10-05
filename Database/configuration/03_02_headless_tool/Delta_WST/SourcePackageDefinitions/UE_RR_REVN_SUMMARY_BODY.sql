CREATE OR REPLACE PACKAGE BODY ue_RR_Revn_Summary IS
/****************************************************************
** Package        :  ue_RR_Revn_Summary, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Provide user exit functions for package EcDp_RR_Revn_Summary
**
** Documentation  :  www.energy-components.com
**
** Created  : 18.04.2012  Georg Hoien
**
** Modification history:
**
** Version  Date       Whom       Change description:
** -------  ---------- ---------- --------------------------------------
** 1.0	    18.04.2012 HOIENGEO   Initial version
************************************************************************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CreateSummaryMonth
-- Description    : This is a INSTEAD OF user-exit addon to the standard CreateSummaryMonth.
-- Preconditions  : Must be enabled using global variable isCreateSummaryMonthUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE CreateSummaryMonth(p_Rec IN OUT cont_doc%ROWTYPE,
                             p_contract_id      VARCHAR2,
                             p_summary_setup_id VARCHAR2,
                             p_period           DATE)
IS
--</EC-DOC>
BEGIN
  NULL;
END CreateSummaryMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CreateSummaryMonth
-- Description    : This is a INSTEAD OF user-exit addon to the standard CreateSummaryMonth.
-- Preconditions  : Must be enabled using global variable isCreateSummaryMonthUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE Revn_CreateSummaryMonth(p_Rec IN OUT cont_doc%ROWTYPE,
                             p_contract_id      VARCHAR2,
                             p_summary_setup_id VARCHAR2,
                             p_period           DATE,
                             lrec_cjs IN OUT cont_journal_summary%ROWTYPE)
IS
--</EC-DOC>
BEGIN
  NULL;
END Revn_CreateSummaryMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CreateSummaryMonthPre
-- Description    : This is a PRE user-exit addon to the standard CreateSummaryMonth.
-- Preconditions  : Must be enabled using global variable isCreateSummaryMonthPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------

PROCEDURE CreateSummaryMonthPre(p_Rec IN OUT cont_doc%ROWTYPE,
                                p_contract_id      VARCHAR2,
                                p_summary_setup_id VARCHAR2,
                                p_period           DATE)
IS
--</EC-DOC>
BEGIN
  NULL;
END CreateSummaryMonthPre;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CreateSummaryMonthPost
-- Description    : This is a POST user-exit addon to the standard CreateSummaryMonth.
-- Preconditions  : Must be enabled using global variable isCreateSummaryMonthPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------

PROCEDURE CreateSummaryMonthPost(p_Rec IN OUT cont_journal_summary%ROWTYPE,
                                 p_contract_id      VARCHAR2,
                                 p_summary_setup_id VARCHAR2,
                                 p_period           DATE)
IS
--</EC-DOC>
BEGIN
  NULL;
END CreateSummaryMonthPost;

END ue_RR_Revn_Summary;