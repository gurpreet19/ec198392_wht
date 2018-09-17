CREATE OR REPLACE PACKAGE EcBp_Lifting_Account IS
/**************************************************************************************************
** Package  :  EcBp_Lifting_Account
**
** $Revision: 1.12 $
**
** Purpose  :  Business logic for lifting account
**
**
**
** General Logic:
**
** Created:     02.11.2004 Kari Sandvik
**
** Modification history:
**
** Date:       Whom: Rev.  Change description:
** ----------  ----- ----  ------------------------------------------------------------------------
** 22.05.2010  lauuufus    Add procedure checkIfConnectionOverlaps
** 30.12.2011  farhaann    Added validateLiftingAccountSplit
** 12.12.2013  muhammah	   ECPD-8558 : Added parameter contract to procedure validateAccount
**************************************************************************************************/

FUNCTION getLiftingAccountCpyPc (p_storage_id VARCHAR2, p_company_id VARCHAR2, p_profit_centre_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getLiftingAccountCpy (p_storage_id VARCHAR2, p_company_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getLiftingAccountCntr (p_storage_id VARCHAR2, p_contract_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

PROCEDURE validateAccount (p_object_id VARCHAR2, p_storage_id VARCHAR2, p_company_id VARCHAR2, p_profit_centre_id VARCHAR2, p_contract_id VARCHAR2, p_validate_ind CHAR);

PROCEDURE checkIfConnectionOverlaps(p_object_id VARCHAR2,p_lift_acc_id VARCHAR2, p_daytime DATE, p_end_date DATE);

PROCEDURE validateLiftingAccountSplit(p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE populateSubDailyValueAdj(p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE populateSubDailyValueSinAdj(p_object_id VARCHAR2, p_daytime DATE);

END EcBp_Lifting_Account;