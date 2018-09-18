CREATE OR REPLACE PACKAGE EcDp_Outbound_Interface IS
/**************************************************************
** Package        :  EcDp_Outbound_Interface, header part
**
** $Revision: 1.10 $
**
** Purpose	:  ALL outbound DB interfaces
**
** General Logic:
**
** Modification history:
**
** Date:       Whom  Change description:
** ----------  ----  ---------------------------------------------
** PLEASE LOOK IN THE BODY COMMENTS FOR DETAILS
**************************************************************/

FUNCTION TransferInventory(
p_inventory_id VARCHAR2 DEFAULT NULL
,p_daytime VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
---------------------------------------------------------------------------------
FUNCTION TransferSPSales(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
---------------------------------------------------------------------------------
FUNCTION TransferSPPurchases(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
---------------------------------------------------------------------------------
FUNCTION TransferSPTariffIncome(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
---------------------------------------------------------------------------------
FUNCTION TransferSPTariffCost(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
---------------------------------------------------------------------------------
FUNCTION TransferSPJournalEntry(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
---------------------------------------------------------------------------------
FUNCTION TransferERPDocument(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
---------------------------------------------------------------------------------
PROCEDURE CLOBOpen;
---------------------------------------------------------------------------------
FUNCTION CLOBClose(
  p_module VARCHAR2
  ,p_interface_type VARCHAR2
  ,p_business_unit_code VARCHAR2
  ,p_path  VARCHAR2
) RETURN VARCHAR2;
---------------------------------------------------------------------------------
PROCEDURE  CLOBwriteln(
   p_Text  IN  VARCHAR2
);

END EcDp_Outbound_Interface;