CREATE OR REPLACE PACKAGE EcBp_Account_Status IS
/****************************************************************
** Package        :  EcBp_account_status
**
** $Revision: 1.3 $
**
** Purpose        :  This package is responsible for calculation of Monthly account
**                   status for loading volume and nominated volume
**
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.06.2001  Stig Vidar Nordgård
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0    20.06.2001  SVN  First version
**
** 1.1		08.01.2001	BOW	 Added function 'daily_refinery_offtake' -> Returns daily value forecast or planned.
**
** Date       Whom  Change description:
** ---------- ----- --------------------------------------
** 08.09.2004 KSN	Updated to 8.0 (Tracker 1255)
*****************************************************************/

/*
TYPE tab_account_no IS TABLE OF lift_agreement_account.account_no%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_pct_split IS TABLE OF lift_agreement_account.fixed_pct%TYPE INDEX BY BINARY_INTEGER;
*/
/*****************************************************************/
FUNCTION refinery_offtake(p_storage_id VARCHAR2,
         p_company_id VARCHAR2,
         p_startday DATE,
         p_endday DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (refinery_offtake, WNDS, WNPS, RNPS);

/*****************************************************************/
FUNCTION adjustment(p_storage_id VARCHAR2,
         p_company_id VARCHAR2,
         p_startday DATE,
         p_endday DATE) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (adjustment, WNDS, WNPS, RNPS);


/*****************************************************************/
FUNCTION producer_balance(p_storage_id     VARCHAR2,
                 p_account_no       VARCHAR2,
                 p_transaction_type VARCHAR2,
                 p_from_day         DATE,
                 p_to_day           DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (producer_balance, WNDS, WNPS, RNPS);
/*****************************************************************/

END EcBp_Account_Status;