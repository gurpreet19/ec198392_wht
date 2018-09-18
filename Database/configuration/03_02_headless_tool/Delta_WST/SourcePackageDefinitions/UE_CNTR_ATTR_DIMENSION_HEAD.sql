CREATE OR REPLACE PACKAGE ue_cntr_attr_dimension IS
/******************************************************************************
** Package        :  ue_cntr_attr_dimension, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Includes user-exit functionality for contract attributes screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.08.2012 Annida Farhana
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 03.08.2012  farhaann ECPD-21414: Initial version
*/

FUNCTION getAttributeString (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_object_ec_code VARCHAR2) RETURN VARCHAR2;

FUNCTION getAttributeDate (p_contract_id VARCHAR2, p_attribute_name VARCHAR2, p_daytime DATE, p_object_ec_code VARCHAR2) RETURN DATE;

FUNCTION getAttributeNumber (p_contract_id VARCHAR2, p_attribute_name VARCHAR2,p_daytime DATE, p_object_ec_code VARCHAR2) RETURN NUMBER;

END ue_cntr_attr_dimension;