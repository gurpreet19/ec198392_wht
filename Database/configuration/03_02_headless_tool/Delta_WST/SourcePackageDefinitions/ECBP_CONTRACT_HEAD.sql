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
PROCEDURE validateOverlapPeriod(p_object_id VARCHAR2, p_job_id VARCHAR2, p_daytime DATE, p_end_date DATE);


END EcBp_Contract;