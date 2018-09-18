CREATE OR REPLACE PACKAGE EcBp_Contract IS
/****************************************************************
** Package        :  EcBp_Contract; head part
**
** $Revision: 1.1 $
**
** Purpose        :  Handles validation on class Contract
**
** Documentation  :  www.energy-components.com
**
** Created        :  01.12.2005	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
**************************************************************************************************/

PROCEDURE validateContract(p_CONTRACT_YEAR_START NUMBER, p_CONTRACT_DAY_START VARCHAR2);


END EcBp_Contract;