CREATE OR REPLACE PACKAGE EcDp_Contract_Capacity IS
/****************************************************************
** Package        :  EcDp_Contract_Capacity; head part
**
** $Revision: 1.4.24.3 $
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
** 27.08.2012  sharawan  ECPD-21657: Added function getAccumulatedQty() and procedure aggregateRequestQty().
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
FUNCTION getNominationQty(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2) RETURN NUMBER;
FUNCTION getSubDayNominationQty(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2) RETURN NUMBER;
FUNCTION getDayIconPath(p_objectId VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
FUNCTION getSubDayIconPath(p_objectId VARCHAR2, p_timestamp DATE) RETURN VARCHAR2;


END EcDp_Contract_Capacity;