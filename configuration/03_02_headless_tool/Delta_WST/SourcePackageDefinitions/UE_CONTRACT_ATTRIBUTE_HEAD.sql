CREATE OR REPLACE PACKAGE ue_Contract_Attribute IS
/****************************************************************
** Package        :  ue_Contract_Attribute; head part
**
** $Revision: 1.3 $
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
** 10.08.2012 farhaann ECPD-21414: Added new parameter p_object_ec_code in getAttributeString, getAttributeDate and getAttributeNumber
** 07.02.2014 farhaann ECPD-26256: Added new function, getSortOrder
**************************************************************************************************/

FUNCTION getAttributeString (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_object_ec_code VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

FUNCTION getAttributeDate (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_object_ec_code VARCHAR2 DEFAULT NULL) RETURN DATE;

FUNCTION getAttributeNumber (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_object_ec_code VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION assignSortOrder (p_contract_id VARCHAR2, p_attribute_name VARCHAR2) RETURN NUMBER;

END ue_Contract_Attribute;