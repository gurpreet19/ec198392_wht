CREATE OR REPLACE PACKAGE EcDp_Nomination_Location IS
/******************************************************************************
** Package        :  EcDp_Nomination_Location, Header
**
** $Revision: 1.1.4.1 $
**
** Purpose        :  Nomination functions
**
** Documentation  :  www.energy-components.com
**
** Created        :  15.02.2012 Kenneth Masamba
**
** Modification history:
**
** Date        Whom  	   Change description:
** ------      ----- 	   -----------------------------------------------------------------------------------
** 27.09.2013  leeeewei		Added getSumFracCompRecFac, getSumFracProductCompRecFac and getFcstSumFracCompRecFac
**************************************************************************************************************/


FUNCTION getTotalReqQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalAccQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalExtAccQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2, p_date DATE) RETURN NUMBER;
FUNCTION getTotalAdjQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalExtAdjQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalConfQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalExtConfQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalSchedQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
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
FUNCTION getFirstContractID(p_company_id VARCHAR2) RETURN VARCHAR2;
--
FUNCTION getLocationType(p_object_id VARCHAR2) RETURN VARCHAR2;
FUNCTION getDelstrmLocationType(p_delstrm_id VARCHAR2) RETURN VARCHAR2;
FUNCTION getLocationName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
--
FUNCTION lesserRule(p_qty_one NUMBER, p_qty_two NUMBER) RETURN NUMBER;
FUNCTION converteQty(p_qty NUMBER, p_from_unit VARCHAR2, p_to_unit VARCHAR2, p_from_condition VARCHAR2, p_to_condition VARCHAR2, p_pct NUMBER, p_daytime DATE DEFAULT NULL) RETURN NUMBER;
PROCEDURE CheckTransportNomination(p_object_id VARCHAR2,p_contract_id VARCHAR2,p_entry_location_id VARCHAR2,p_exit_location_id VARCHAR2);

--
PROCEDURE validateRenomTime(p_parent_nomination_seq	VARCHAR2, p_object_id VARCHAR2, p_daytime DATE);
--
FUNCTION getTotalReqTransfQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalAccTransfQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalAdjTransfQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalSchTransfQtyPrContract(p_location_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;

FUNCTION getSumFracCompRecFac(p_class_name VARCHAR2,p_object_id VARCHAR2,p_daytime DATE)RETURN NUMBER;
FUNCTION getSumFracProductCompRecFac(p_class_name VARCHAR2,p_object_id VARCHAR2,p_product_id VARCHAR2,p_daytime DATE)RETURN NUMBER;
FUNCTION getFcstSumFracCompRecFac(p_class_name VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_forecast_id VARCHAR2)RETURN NUMBER;

END EcDp_Nomination_Location;