CREATE OR REPLACE PACKAGE EcDp_Sales_Acc_Price_Concept IS
/******************************************************************************
** Package        :  EcDp_Sales_Acc_Price_Concept, head part
**
** $Revision: 1.1 $
**
** Purpose        :  Contains constants for Sales Account Price Concepts. Replace package EcDp_Sales_Account_Category
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.12.2005 Stian Skj?tad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------

********************************************************************/


FUNCTION NORMAL_GAS
RETURN VARCHAR2;

--

FUNCTION OFF_SPEC_GAS
RETURN VARCHAR2;

--

FUNCTION TOTAL_DELIVERED_GAS
RETURN VARCHAR2;

--

FUNCTION TAKE_OR_PAY_PENALTY
RETURN VARCHAR2;

--

FUNCTION INVOICE_TOTAL
RETURN VARCHAR2;

--

FUNCTION ADJUSTMENT
RETURN VARCHAR2;

--

END EcDp_Sales_Acc_Price_Concept;