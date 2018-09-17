CREATE OR REPLACE PACKAGE EcDp_Nomination_Cntr_Supp_Bal IS
/******************************************************************************
** Package        :  EcDp_Nomination_Cntr_Supp_Bal, Header
**
** $Revision: 1.2.2.1 $
**
** Purpose        :  Nomination functions
**
** Documentation  :  www.energy-components.com
**
** Created        :  15.02.2012 Kenneth Masamba
**
** Modification history:
**
** Date        	Whom  	   	Change description:
** ------      	-------- 	-----------------------------------------------------------------------------------
** 16.04.2013	muhammah	ECPD-23877: added p_location_id, p_transfer_service to functions:getTotalReqTransfQtyPrContract, getTotalAccTransfQtyPrContract,getTotalAdjTransfQtyPrContract,getTotalSchTransfQtyPrContract
**************************************************************************************************************/


FUNCTION getTotalReqQtyPrContract(p_location_id VARCHAR2,p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_supplier_nompnt_id VARCHAR2) RETURN NUMBER;
FUNCTION getTotalAccQtyPrContract(p_location_id VARCHAR2,p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_supplier_nompnt_id VARCHAR2) RETURN NUMBER;
FUNCTION getTotalExtAccQtyPrContract(p_location_id VARCHAR2,p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2, p_date DATE,p_supplier_nompnt_id VARCHAR2) RETURN NUMBER;
FUNCTION getTotalAdjQtyPrContract(p_location_id VARCHAR2,p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_supplier_nompnt_id VARCHAR2) RETURN NUMBER;
FUNCTION getTotalExtAdjQtyPrContract(p_location_id VARCHAR2,p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_supplier_nompnt_id VARCHAR2) RETURN NUMBER;
FUNCTION getTotalConfQtyPrContract(p_location_id VARCHAR2,p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_supplier_nompnt_id VARCHAR2) RETURN NUMBER;
FUNCTION getTotalExtConfQtyPrContract(p_location_id VARCHAR2,p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_supplier_nompnt_id VARCHAR2) RETURN NUMBER;
FUNCTION getTotalSchedQtyPrContract(p_location_id VARCHAR2,p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_nom_type VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_supplier_nompnt_id VARCHAR2) RETURN NUMBER;
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

FUNCTION getTotalReqTransfQtyPrContract (p_location_id VARCHAR2, p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_supplier_nompnt_id VARCHAR2, p_transfer_service VARCHAR2 DEFAULT NULL) RETURN NUMBER;
FUNCTION getTotalAccTransfQtyPrContract (p_location_id VARCHAR2, p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_supplier_nompnt_id VARCHAR2, p_transfer_service VARCHAR2 DEFAULT NULL) RETURN NUMBER;
FUNCTION getTotalAdjTransfQtyPrContract (p_location_id VARCHAR2, p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_supplier_nompnt_id VARCHAR2, p_transfer_service VARCHAR2 DEFAULT NULL) RETURN NUMBER;
FUNCTION getTotalSchTransfQtyPrContract(p_location_id VARCHAR2, p_contract_id VARCHAR2,p_nom_cycle VARCHAR2,p_oper_nom_ind VARCHAR2,p_date DATE,p_supplier_nompnt_id VARCHAR2, p_transfer_service VARCHAR2 DEFAULT NULL) RETURN NUMBER;

END EcDp_Nomination_Cntr_Supp_Bal;