CREATE OR REPLACE PACKAGE BODY ue_Outbound_Interface IS
/****************************************************************
** Package        :  ue_Outbound_Interface, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Provide special functions for outbound interfaces
**
** Documentation  :  www.energy-components.com
**
** Created  : 13.08.2008  EnergyComponents Team
**
** Modification history:
**
** Version  Date       Whom       Change description:
** -------  ---------- ---------- --------------------------------------
** 1.1	    13.08.2008 OLSOOATL   Initial version
************************************************************************************************************************************************************/


FUNCTION TransferInventory(
p_inventory_id VARCHAR2 DEFAULT NULL
,p_daytime VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
BEGIN
   RETURN NULL;
END;
---------------------------------------------------------------------------------

FUNCTION TransferSPSales(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
BEGIN
   RETURN NULL;
END;
---------------------------------------------------------------------------------

FUNCTION TransferSPReallocation(
p_document_id VARCHAR2 DEFAULT NULL,
p_realloc_no NUMBER DEFAULT NULL)
RETURN VARCHAR2
IS
BEGIN
   RETURN NULL;
END;
---------------------------------------------------------------------------------

FUNCTION TransferSPPurchases(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
BEGIN
   RETURN NULL;
END;
---------------------------------------------------------------------------------

FUNCTION TransferSPTariffIncome(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
BEGIN
   RETURN NULL;
END;
---------------------------------------------------------------------------------

FUNCTION TransferSPTariffCost(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
BEGIN
   RETURN NULL;
END;
---------------------------------------------------------------------------------

FUNCTION TransferSPJournalEntry(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
BEGIN
   RETURN NULL;
END;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION TransferERPDocument(
         p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
BEGIN
   RETURN NULL;
END;

end ue_Outbound_Interface;