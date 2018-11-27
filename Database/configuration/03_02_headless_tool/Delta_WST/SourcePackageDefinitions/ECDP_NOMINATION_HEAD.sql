CREATE OR REPLACE PACKAGE EcDp_NOMINATION IS
/******************************************************************************
** Package        :  EcDp_NOMINATION, Header
**
** $Revision: 1.17 $
**
** Purpose        :  Nomination functions
**
** Documentation  :  www.energy-components.com
**
** Created        :  04.03.2008 Olav N�and
**
** Modification history:
**
** Date        Whom  	   Change description:
** ------      ----- 	   -----------------------------------------------------------------------------------
**04.03.2008   ON    	   Initial Version
**30.04.2008   ON    	   Added functions for company
**08.01.2009   musaamah    ECPD-9845: Change the return type for functions to return NUMBER instead of INTEGER
**20.05,2009   madondin    ECPD-11543: Changing contract or location to a nomination point should not be allow when nominations exists
**16.02,2011   masamken    ECPD-16565: Added new procedure validateRenomTime() validation of the duplicate daytime
**13.06.2012   sharawan    ECPD-19476: Added new functions getTotalAdjQtyPrLoc, getTotalSchedQtyPrLoc, getSubDayTotalAdjQtyPrLoc,
**                         getSubDayTotalSchedQtyPrLoc for GD.0062-Sub Daily Nomination Location Capacity.
**31.07.2012   sharawan    ECPD-19482: Add new functions getNomUOM, getTotalLocSchedQtyMth, getTotalLocSchedQtyDay,
**                         getTotalSchedQtyPrLocationMth, getTotalSchedQtyPrLocationDay for GD.0047 : Monthly OBA Status.
**17.04.2013   meisihil    ECPD-23623: Added new function getSortOrder
**19.04.2013   meisihil    ECPD-XXXXX: Added new functions getSubDayAccQtyPrContract. getSubDayAdjQtyPrContract, getSubDayConfQtyPrContract
**31.01.2014   meisihil    ECPD-25609: Added p_class_name parameter for functions getTotalAdjQtyPrLoc, getTotalSchedQtyPrLoc, getSubDayTotalAdjQtyPrLoc, getSubDayTotalSchedQtyPrLoc
**24.01.2018   sandetho    ECPD-50371: Added new function getSumNomptQty.
**13.02.2018   baratmah    ECPD-50100: Added new procedure validateOverlappingConnection.
**09.04.2018   baratmah    ECPD-52929: Added new function getClassName.
**************************************************************************************************************/


FUNCTION getTotalReqQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalAccQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalExtAccQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2, p_date DATE) RETURN NUMBER;
FUNCTION getTotalAdjQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalExtAdjQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalConfQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalExtConfQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalSchedQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
--
FUNCTION getTotalReqQtyPrCompany(p_company_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalAccQtyPrCompany(p_company_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalExtAccQtyPrCompany(p_company_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2, p_date DATE) RETURN NUMBER;
FUNCTION getTotalAdjQtyPrCompany(p_company_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalExtAdjQtyPrCompany(p_company_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalConfQtyPrCompany(p_company_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalExtConfQtyPrCompany(p_company_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalSchedQtyPrCompany(p_company_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
--
FUNCTION getTotalAdjQtyPrLoc(p_object_id VARCHAR2,p_nom_type VARCHAR2,p_daytime DATE,p_class_name VARCHAR2) RETURN NUMBER;
FUNCTION getTotalSchedQtyPrLoc(p_object_id VARCHAR2,p_nom_type VARCHAR2,p_daytime DATE,p_class_name VARCHAR2) RETURN NUMBER;
FUNCTION getSubDayTotalAdjQtyPrLoc(p_object_id VARCHAR2,p_nom_type VARCHAR2,p_daytime DATE,p_class_name VARCHAR2) RETURN NUMBER;
FUNCTION getSubDayTotalSchedQtyPrLoc(p_object_id VARCHAR2,p_nom_type VARCHAR2,p_daytime DATE,p_class_name VARCHAR2) RETURN NUMBER;
--
FUNCTION getFirstContractID(p_company_id VARCHAR2) RETURN VARCHAR2;
--
FUNCTION getLocationType(p_object_id VARCHAR2) RETURN VARCHAR2;
FUNCTION getDelstrmLocationType(p_delstrm_id VARCHAR2) RETURN VARCHAR2;
FUNCTION getLocationName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
--
FUNCTION getNomUOM(p_object_id VARCHAR2,p_daytime DATE) RETURN VARCHAR2;
FUNCTION getTotalLocSchedQtyMth(p_object_id VARCHAR2, p_location_id VARCHAR2,p_daytime DATE, p_class_name VARCHAR2 DEFAULT NULL) RETURN NUMBER;
FUNCTION getTotalLocSchedQtyDay(p_object_id VARCHAR2, p_location_id VARCHAR2,p_daytime DATE, p_class_name VARCHAR2 DEFAULT NULL, p_time_span VARCHAR2 DEFAULT NULL) RETURN NUMBER;
FUNCTION getTotalSchedQtyPrLocationMth(p_object_id VARCHAR2, p_location_id VARCHAR2, p_daytime DATE, p_oper_nom_ind VARCHAR2 DEFAULT NULL) RETURN NUMBER;
FUNCTION getTotalSchedQtyPrLocationDay(p_object_id VARCHAR2, p_location_id VARCHAR2, p_daytime DATE, p_oper_nom_ind VARCHAR2 DEFAULT NULL, p_time_span VARCHAR2 DEFAULT NULL) RETURN NUMBER;
--
FUNCTION lesserRule(p_qty_one NUMBER, p_qty_two NUMBER) RETURN NUMBER;
FUNCTION converteQty(p_qty NUMBER, p_from_unit VARCHAR2, p_to_unit VARCHAR2, p_from_condition VARCHAR2, p_to_condition VARCHAR2, p_pct NUMBER, p_daytime DATE DEFAULT NULL) RETURN NUMBER;
PROCEDURE CheckTransportNomination(p_object_id VARCHAR2,p_contract_id VARCHAR2,p_entry_location_id VARCHAR2,p_exit_location_id VARCHAR2);

--
PROCEDURE validateRenomTime(p_parent_nomination_seq	VARCHAR2, p_object_id VARCHAR2, p_daytime DATE);

FUNCTION getSortOrder(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getSubDayAccQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_summer_time VARCHAR2) RETURN NUMBER;
FUNCTION getSubDayAdjQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_summer_time VARCHAR2) RETURN NUMBER;
FUNCTION getSubDayConfQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_summer_time VARCHAR2) RETURN NUMBER;

PROCEDURE aggrRequestedQty(p_day_nom_seq NUMBER);
PROCEDURE validateRenomSubTime(p_day_nom_seq VARCHAR2, p_object_id VARCHAR2, p_production_day DATE, p_daytime DATE, p_summer_time VARCHAR2 DEFAULT 'N');
FUNCTION getSumNomptQty(p_to_nompnt_id VARCHAR2,p_daytime DATE) RETURN NUMBER;
PROCEDURE validateOverlappingConnection(p_object_id VARCHAR2, p_new_oploc_id VARCHAR2, p_old_oploc_id VARCHAR2, p_old_daytime DATE, p_new_daytime DATE, p_old_end_date DATE, p_new_end_date DATE);
FUNCTION getClassName(p_operational_location_id VARCHAR2) RETURN VARCHAR2;

END EcDp_NOMINATION;