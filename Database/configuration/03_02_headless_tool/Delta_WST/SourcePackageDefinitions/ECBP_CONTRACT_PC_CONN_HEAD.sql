CREATE OR REPLACE PACKAGE EcBp_Contract_Pc_Conn IS
/****************************************************************
** Package        :  EcBp_Contract_Pc_Conn; head part
**
** $Revision: 1.1 $
**
** Purpose        :  Handles validation on Contract Profit Centre (Company) List screens
**
** Documentation  :  www.energy-components.com
**
** Created        :  15.12.2005	Stian Skj�tad
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------

**************************************************************************************************/


PROCEDURE valSctrPc(p_contract_id VARCHAR2);
PROCEDURE valSctrPcCompany(p_contract_id VARCHAR2);
PROCEDURE validateDatePeriod(p_contract_id     VARCHAR2,
			     			 p_profit_centre_id VARCHAR2,
  			     			 p_company_id VARCHAR2 DEFAULT NULL);

END EcBp_Contract_Pc_Conn;