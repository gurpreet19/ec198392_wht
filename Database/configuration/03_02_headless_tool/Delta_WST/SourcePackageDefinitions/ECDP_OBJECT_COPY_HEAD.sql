CREATE OR REPLACE PACKAGE Ecdp_Object_Copy IS

/********************************************************************************************************************************
** Package        :  Ecdp_Object_Copy, header part
**
** $Revision:
**
** Purpose        :  Provide copy function
**
** Documentation  :  www.energy-components.com
**
** Created  : 25.01.2010  Lau
**
** Modification history:
**
** Date         Whom  Change description:
** ----------   ----- --------------------------------------
** 12.02.2014   muhammah  ECPD-17241: Added function GetCopyObjectName
** 13.02.2014   sharawan  ECPD-17241: Added function genNewCntrObjCode
** 19.02.2014   sharawan  ECPD-17241: Added function genNewCntrObjName (generate Name for Copy Contract features)
**********************************************************************************************************************************/

FUNCTION GetCopyObjectCode
         (p_class_name VARCHAR2,
         p_object_copy_code VARCHAR2,
         p_class_type VARCHAR2 DEFAULT 'OBJECT')
RETURN VARCHAR2;

FUNCTION GetCopyObjectName
         (p_class_name VARCHAR2,
         p_object_copy_name VARCHAR2,
         p_class_type VARCHAR2 DEFAULT 'OBJECT')
RETURN VARCHAR2;

FUNCTION genNewCntrObjCode(p_old_contract_code VARCHAR2,
                           p_new_contract_code VARCHAR2,
                           p_old_object_code VARCHAR2,
                           p_class_name VARCHAR2)
RETURN VARCHAR2;

FUNCTION genNewCntrObjName(p_old_contract_name VARCHAR2,
                           p_new_contract_name VARCHAR2,
                           p_old_object_name VARCHAR2,
                           p_class_name VARCHAR2)
RETURN VARCHAR2;

end Ecdp_Object_Copy;