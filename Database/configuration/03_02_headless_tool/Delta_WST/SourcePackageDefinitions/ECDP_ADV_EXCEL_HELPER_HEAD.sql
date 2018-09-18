CREATE OR REPLACE PACKAGE EcDp_Adv_Excel_Helper IS
/****************************************************************
** Package        :  EcDp_Adv_Excel_Helper, header part
**
** $Revision: 1.7 $
**
** Purpose        :  Provice helper functions for the advanced Excel Import mechanism.
**
** Documentation  :  www.energy-components.com
**
** Created  :
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
*****************************************************************/

FUNCTION getKey(p_class_name VARCHAR2,
                p_key_num NUMBER)
RETURN VARCHAR2;

FUNCTION getKeyType(p_class_name VARCHAR2,
                p_key_num NUMBER)
RETURN VARCHAR2;

FUNCTION checkKey(p_class_name VARCHAR2,
  p_key_value_1 VARCHAR2,
  p_key_value_2 VARCHAR2 DEFAULT NULL,
  p_key_value_3 VARCHAR2 DEFAULT NULL,
  p_key_value_4 VARCHAR2 DEFAULT NULL,
  p_key_value_5 VARCHAR2 DEFAULT NULL,
  p_key_value_6 VARCHAR2 DEFAULT NULL,
  p_key_value_7 VARCHAR2 DEFAULT NULL,
  p_key_value_8 VARCHAR2 DEFAULT NULL,
  p_key_value_9 VARCHAR2 DEFAULT NULL,
  p_key_value_10 VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION getSQLAnd(p_column VARCHAR2, p_data_type VARCHAR2, p_value VARCHAR2)
RETURN VARCHAR2;

END EcDp_Adv_Excel_Helper;