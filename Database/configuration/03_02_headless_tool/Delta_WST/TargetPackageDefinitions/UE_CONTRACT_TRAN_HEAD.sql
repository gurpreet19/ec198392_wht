CREATE OR REPLACE PACKAGE ue_Contract_Tran IS
/****************************************************************
** Package        :  ue_Contract_Tran; head part
**
** $Revision: 1.3 $
**
** Purpose        :  User exit package for transport releated functionality for contracts
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

PROCEDURE amendContract(p_new_object_id VARCHAR2, p_from_object_id VARCHAR2, p_user VARCHAR2 DEFAULT NULL);
PROCEDURE createPrepareContract(p_PREPARE_NO NUMBER, p_user VARCHAR2 DEFAULT NULL);

END ue_Contract_Tran;