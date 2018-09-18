CREATE OR REPLACE PACKAGE ue_Contract_Tran IS
/****************************************************************
** Package        :  ue_Contract_Tran; head part
**
** $Revision: 1.4 $
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
** 12.02.2014   muhammah  ECPD-17241: Added function copyContract, InsNewContract, InsNewContractCopy.
** 13.02.2014   sharawan  ECPD-17241: Modify procedure amendContract
**************************************************************************************************/

PROCEDURE amendContract(
  p_new_object_id VARCHAR2,
  p_from_object_id VARCHAR2,
  p_user VARCHAR2);

PROCEDURE createPrepareContract(p_PREPARE_NO NUMBER, p_user VARCHAR2 DEFAULT NULL);

FUNCTION copyContract(
   p_from_object_id VARCHAR2,
   p_start_date DATE DEFAULT NULL,
   p_end_date DATE DEFAULT NULL,
   p_from_code      VARCHAR2,
   p_prepare_no VARCHAR2 DEFAULT NULL,
   p_user  VARCHAR2)
 RETURN VARCHAR2;

FUNCTION InsNewContractCopy(p_object_id  VARCHAR2, -- to copy from
                            p_start_date DATE, -- to copy from
                            p_code       VARCHAR2,
                            p_user       VARCHAR2,
                            p_end_date   DATE)
 RETURN VARCHAR2;

FUNCTION InsNewContract(p_object_id   VARCHAR2,
                        p_object_code VARCHAR2,
                        p_start_date  DATE,
                        p_end_date    DATE DEFAULT NULL,
                        p_user        VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

END ue_Contract_Tran;