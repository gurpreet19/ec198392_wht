CREATE OR REPLACE PACKAGE EcDp_NOMINATION_CONTRACT_BAL IS
/******************************************************************************
** Package        :  EcDp_NOMINATION_CONTRACT_BAL, Header
**
** $Revision: 1.1.4.2 $
**
** Purpose        :  Nomination functions
**
** Documentation  :  www.energy-components.com
**
** Created        :  14.02.2012 Kenneth Masamba
**
** Modification history:
**
** Date        Whom  	   Change description:
** ------      ----- 	   -----------------------------------------------------------------------------------
**14.02.2012   masamken    Initial Version
**22.10.2012   chooysie    ECPD-22175 Add function for Monthly Contract Balance screen
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
FUNCTION getTotalReqTransfQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalAccTransfQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalAdjTransfQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;
FUNCTION getTotalSchTransfQtyPrContract(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE) RETURN NUMBER;

FUNCTION getTotalReqQtyPrContractMth(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date_from DATE,p_date_to DATE) RETURN NUMBER;
FUNCTION getTotalAccQtyPrContractMth(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date_from DATE,p_date_to DATE) RETURN NUMBER;
FUNCTION getTotalAdjQtyPrContractMth(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date_from DATE,p_date_to DATE) RETURN NUMBER;
FUNCTION getTotalConfQtyPrContractMth(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date_from DATE,p_date_to DATE) RETURN NUMBER;
FUNCTION getTotalSchedQtyPrContractMth(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date_from DATE,p_date_to DATE) RETURN NUMBER;

FUNCTION getTotalReqTransfQtyPrCntrMth(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date_from DATE,p_date_to DATE) RETURN NUMBER;
FUNCTION getTotalAccTransfQtyPrCntrMth(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date_from DATE,p_date_to DATE) RETURN NUMBER;
FUNCTION getTotalAdjTransfQtyPrCntrMth(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date_from DATE,p_date_to DATE) RETURN NUMBER;
FUNCTION getTotalSchTransfQtyPrCntrMth(p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date_from DATE,p_date_to DATE) RETURN NUMBER;

END EcDp_NOMINATION_CONTRACT_BAL;