CREATE OR REPLACE PACKAGE EcBp_Contract_Parties IS
/****************************************************************
** Package        :  EcBp_Contract_Parties; head part
**
** $Revision: 1.5 $
**
** Purpose        :  Handles with contract parties
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2005	Jean Ferre
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 31/08/2011  meisihil     ECPD-17893: Added new updateDelShareEndDate function
**************************************************************************************************/

PROCEDURE createNewShare(p_contract_id VARCHAR2, p_party_role VARCHAR2, p_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE updateNewShareEndDate(p_contract_id VARCHAR2, p_party_role VARCHAR2, p_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE validateShare(p_contract_id VARCHAR2, p_daytime DATE, p_party_role VARCHAR2, p_class_name VARCHAR2);

PROCEDURE updateDelShareEndDate(p_contract_id VARCHAR2, p_party_role VARCHAR2, p_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

END EcBp_Contract_Parties;