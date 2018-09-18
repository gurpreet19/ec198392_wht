CREATE OR REPLACE package ue_Outbound_Interface IS
/****************************************************************
**
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** Enable this User Exit by setting variable below "isUserExitEnabled" = 'TRUE'
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
**
** Package        :  ue_Outbound_Interface, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Provide special functions for outbound interfaces
**
** Documentation  :  www.energy-components.com
**
** Created  : 13.02.2008  EnergyComponents Team
**
** Modification history:
**
** Version  Date       Whom       Change description:
** -------  ---------- ---------- --------------------------------------
** 1.1	    13.08.2008 OLSOOATL   Initial version
************************************************************************/
isUserExitEnabled varchar2(32) := 'FALSE';

FUNCTION TransferInventory(
p_inventory_id VARCHAR2 DEFAULT NULL
,p_daytime VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
---------------------------------------------------------------------------------
FUNCTION TransferSPSales(
p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
---------------------------------------------------------------------------------
FUNCTION TransferSPReallocation(
p_document_id VARCHAR2 DEFAULT NULL,
p_realloc_no NUMBER DEFAULT NULL)
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
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION TransferERPDocument(
         p_document_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
end ue_Outbound_Interface;