CREATE OR REPLACE PACKAGE ue_Contract_Attribute IS
/****************************************************************
** Package        :  ue_Contract_Attribute; head part
**
** $Revision: 1.1.92.1 $
**
** Purpose        :  Special package for attributes that are customer specific
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2005	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 10.08.2012 farhaann ECPD-21665: Added new parameter p_object_ec_code in getAttributeString, getAttributeDate and getAttributeNumber
**************************************************************************************************/

FUNCTION getAttributeString (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_object_ec_code VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getAttributeString, WNDS, WNPS, RNPS);

FUNCTION getAttributeDate (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_object_ec_code VARCHAR2 DEFAULT NULL) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getAttributeDate, WNDS, WNPS, RNPS);

FUNCTION getAttributeNumber (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_object_ec_code VARCHAR2 DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getAttributeNumber, WNDS, WNPS, RNPS);

END ue_Contract_Attribute;