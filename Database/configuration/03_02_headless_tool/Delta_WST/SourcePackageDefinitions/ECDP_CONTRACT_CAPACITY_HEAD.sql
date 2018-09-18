CREATE OR REPLACE PACKAGE EcDp_Contract_Capacity IS
/****************************************************************
** Package        :  EcDp_Contract_Capacity; head part
**
** $Revision: 1.7 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  15.09.2008  Arief Zaki
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 16.09.2008  zakiiari  ECPD-9807: initial version
** 19.05.2009  oonnnng   ECPD-11850: Added getAwardedCapacity() and getAvailableCapacity() functions.
** 28.10.2009  oonnnng   ECPD-13151: Amended getAwardedCapacity() and getAvailableCapacity() functions to return NUMBER, not INTEGER.
** 14.09.2012  sharawan  ECPD-19576: Added function getAccumulatedQty() and procedure aggregateRequestQty().
** 24.01.2013  meisihil  ECPD-26382: Added function checkConnOverlaps
** 24.01.2013  meisihil  ECPD-26382: Updated parameters for functions getNominationQty, getSubDayNominationQty, getSubDayIconPath and getSubDayIconPath
** 06-08-2015  asareswi  ECPD-26383: Updated function getAvailableCapacity : Added sum() in the cntr_period_capacity query to get the total capacity for the contract capacity for a day and subtract it from default reserved capacity.
**************************************************************************************************/

FUNCTION getReservedTerminalCapacity(p_object_id CONTRACT.OBJECT_ID%TYPE, p_daytime DATE)
RETURN NUMBER;

FUNCTION getAvailableTerminalCapacity(p_object_id CONTRACT.OBJECT_ID%TYPE, p_daytime DATE)
RETURN NUMBER;

FUNCTION getAwardedCapacity(p_contract_id VARCHAR2, p_location_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

FUNCTION getAvailableCapacity(p_contract_id VARCHAR2, p_location_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

FUNCTION getAccumulatedQty(p_contract_id VARCHAR2, p_oper_location_id VARCHAR2, p_cntr_cap_type VARCHAR2, p_daytime DATE)
RETURN NUMBER;

PROCEDURE aggregateRequestQty(
  	p_contract_id   	          VARCHAR2,
  	p_daytime                 DATE,
    p_oper_location_id        VARCHAR2,
    p_cntr_cap_type           VARCHAR2
);
FUNCTION getCapacityUom(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
FUNCTION getCapacityQty(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2) RETURN NUMBER;
FUNCTION getSubDayCapacityQty(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2) RETURN NUMBER;
FUNCTION getNominationQty(p_object_id VARCHAR2, p_daytime DATE, p_nom_status VARCHAR2) RETURN NUMBER;
FUNCTION getSubDayNominationQty(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_nom_status VARCHAR2) RETURN NUMBER;
FUNCTION getDayIconPath(p_objectId VARCHAR2, p_daytime DATE, p_capacity_qty NUMBER) RETURN VARCHAR2;
FUNCTION getSubDayIconPath(p_objectId VARCHAR2, p_timestamp DATE, p_summer_time VARCHAR2, p_capacity_qty NUMBER) RETURN VARCHAR2;

PROCEDURE checkConnOverlaps(p_object_id VARCHAR2, p_location_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_nomination_type VARCHAR2);

END EcDp_Contract_Capacity;