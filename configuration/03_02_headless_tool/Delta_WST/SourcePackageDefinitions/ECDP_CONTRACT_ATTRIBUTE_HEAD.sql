CREATE OR REPLACE PACKAGE EcDp_Contract_Attribute IS
/****************************************************************
** Package        :  EcDp_Contract_Attribute; head part
**
** $Revision: 1.6 $
**
** Purpose        :  Enables the retreival of contract attribute values.
**					 The functions will alwasy return a value based on the contract template
**
** Documentation  :  www.energy-components.com
**
** Created        :  08.12.2005	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 05.05.2009 leeeewei ECPD-11287: Added new procedure validateContractAttributeDate to validate daytime of contract attributes against the start and end date of contract
** 29.04.2009 leeeewei ECPD-11701: Added new procedure validateContractAttributeDate to validate daytime of contract attributes against the start and end date of contract
** 10.08.2012 farhaann ECPD-21414: Added new parameter p_object_ec_code in getAttributeString, getAttributeDate and getAttributeNumber
** 16.08.2013 leeeewei ECPD-19773: Added new function getSumCntrQty
** 13.07.2015 muhammah ECPD-31335: Added new procedure validateDimension
** 05.01.2018 thotesan ECPD-44181: Added new procedure SetContractAttrVersion
**************************************************************************************************/

FUNCTION getAttributeDaytime (p_object_id VARCHAR2, p_date DATE, p_time_span VARCHAR2) RETURN DATE;

FUNCTION getAttributeString (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_is_contract_date VARCHAR2 DEFAULT 'N', p_object_ec_code VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

FUNCTION getAttributeDate (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_is_contract_date VARCHAR2 DEFAULT 'N', p_object_ec_code VARCHAR2 DEFAULT NULL) RETURN DATE;

FUNCTION getAttributeNumber (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_is_contract_date VARCHAR2 DEFAULT 'N', p_object_ec_code VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getAttributeValueAsString (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_object_ec_code VARCHAR2 default NULL) RETURN VARCHAR2;

PROCEDURE validateContractAttributeDate(p_object_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE);

FUNCTION getSumCntrQty(p_object_id VARCHAR2, p_contract_year DATE)RETURN NUMBER;

PROCEDURE validateDimension( p_dim_code VARCHAR2);

PROCEDURE SetContractAttrVersion(p_object_id VARCHAR2,p_attribute_name VARCHAR2,p_daytime DATE, p_dim_code VARCHAR2);

END EcDp_Contract_Attribute;