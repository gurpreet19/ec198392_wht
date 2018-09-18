CREATE OR REPLACE PACKAGE EcDp_Contract IS
/****************************************************************
** Package        :  EcDp_Contract; head part
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2005	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
**************************************************************************************************/

FUNCTION getContractYearStartDate(  p_object_id     VARCHAR2,  p_contract_year DATE) RETURN DATE;

FUNCTION getContractYear(  p_object_id     VARCHAR2,  p_contract_day  DATE) RETURN DATE;

END EcDp_Contract;