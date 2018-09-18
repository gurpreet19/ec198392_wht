CREATE OR REPLACE PACKAGE ue_Contract_Capacity IS

/******************************************************************************
** Package        :  ue_contract_capacity, header part
**
** $Revision: 1.6 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : Fusan
**
** Modification history:
**
** Version  Date        Whom    Change description:
** -------  ------      -----   -----------------------------------------------------------------------------------------------
**          10-Mar-2010 oonnnng ECPD-12078: Add p_req_seq paramter to submitTerminalRequest() function.
**          24.01.2013  meisihil  ECPD-26382: Updated parameters for functions getNominationQty, getSubDayNominationQty, getSubDayIconPath and getSubDayIconPath
**
****************************************************/

PROCEDURE submitTerminalRequest(p_req_seq NUMBER, p_object_id VARCHAR2, p_daytime DATE, p_requested_qty NUMBER);
FUNCTION getCapacityUom(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
FUNCTION getCapacityQty(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2) RETURN NUMBER;
FUNCTION getSubDayCapacityQty(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2) RETURN NUMBER;
FUNCTION getNominationQty(p_object_id VARCHAR2, p_daytime DATE, p_nom_status varchar2) RETURN NUMBER;
FUNCTION getSubDayNominationQty(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_nom_status VARCHAR2) RETURN NUMBER;
FUNCTION getDayIconPath(p_objectId VARCHAR2, p_daytime DATE, p_capacity_qty NUMBER) RETURN VARCHAR2;
FUNCTION getSubDayIconPath(p_objectId VARCHAR2, p_timestamp DATE, p_summer_time VARCHAR2, p_capacity_qty NUMBER) RETURN VARCHAR2;

END ue_Contract_Capacity;
