CREATE OR REPLACE package ue_RR_Revn_Summary IS
/****************************************************************
**
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE

** Enable this User Exit by setting variables below to 'TRUE'

** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
**
** Package        :  ue_RR_Revn_Summary, header part
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
** 1.0	    18.04.2012 HOIENGEO   Initial version.
************************************************************************/

-- Enabling User Exits for EcDp_RR_Revn_Summary.CreateSummaryMonth
isCreateSummaryMonthUEE     VARCHAR2(32) := 'FALSE'; -- Instead of
isCreateSummaryMonthPreUEE  VARCHAR2(32) := 'FALSE'; -- Pre
isCreateSummaryMonthPostUEE VARCHAR2(32) := 'FALSE'; -- Post

-----------------------------------------------------------------------------------------------------------------------------

-- User Exit Set for EcDp_RR_Revn_Summary.CreateSummaryMonth
PROCEDURE CreateSummaryMonth(p_Rec              IN OUT cont_doc%ROWTYPE,
                             p_contract_id      VARCHAR2,
                             p_summary_setup_id VARCHAR2,
                             p_period           DATE);
PROCEDURE CreateSummaryMonthPre(p_Rec IN OUT cont_doc%ROWTYPE,
                                p_contract_id      VARCHAR2,
                                p_summary_setup_id VARCHAR2,
                                p_period           DATE);
PROCEDURE CreateSummaryMonthPost(p_Rec IN OUT cont_journal_summary%ROWTYPE,
                                 p_contract_id      VARCHAR2,
                                 p_summary_setup_id VARCHAR2,
                                 p_period           DATE);

PROCEDURE Revn_CreateSummaryMonth(p_Rec              IN OUT cont_doc%ROWTYPE,
                             p_contract_id      VARCHAR2,
                             p_summary_setup_id VARCHAR2,
                             p_period           DATE,
                             lrec_cjs IN OUT cont_journal_summary%ROWTYPE);
-----------------------------------------------------------------------------------------------------------------------------
end ue_RR_Revn_Summary;