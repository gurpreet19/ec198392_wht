CREATE OR REPLACE PACKAGE ue_Contract_Revn IS
/****************************************************************
** Package        :  ue_Contract_Revn; head part
**
** $Revision: 1.3 $
**
** Purpose        :  User exit package for revenue releated functionality for contracts
**				  :  Any implementation found here is considered an example implementaiont.
**				  :	 Project may override and adjust this ue package
**
** Documentation  :  www.energy-components.com
**
** Created        :  03.02.2009	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
**************************************************************************************************/
FUNCTION copyContract(
   p_object_id VARCHAR2, -- to copy from
   p_code      VARCHAR2,
   p_user      VARCHAR2,
   p_cntr_type VARCHAR2 default NULL, --to indicate the copy will be Deal contract (D) or Contract Template (T)
   p_new_startdate DATE DEFAULT NULL,
   p_new_enddate DATE DEFAULT NULL)
RETURN VARCHAR2; -- new contract code

END ue_Contract_Revn;