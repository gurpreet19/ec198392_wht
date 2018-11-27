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
** Created  : 06.12.2005 Stian Skjørestad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------

********************************************************************/


FUNCTION NORMAL_GAS
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(NORMAL_GAS, WNDS, WNPS, RNPS);

--

FUNCTION OFF_SPEC_GAS
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(OFF_SPEC_GAS, WNDS, WNPS, RNPS);

--

FUNCTION TOTAL_DELIVERED_GAS
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(TOTAL_DELIVERED_GAS, WNDS, WNPS, RNPS);

--

FUNCTION TAKE_OR_PAY_PENALTY
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(TAKE_OR_PAY_PENALTY, WNDS, WNPS, RNPS);

--

FUNCTION INVOICE_TOTAL
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(INVOICE_TOTAL, WNDS, WNPS, RNPS);

--

FUNCTION ADJUSTMENT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(ADJUSTMENT, WNDS, WNPS, RNPS);

--

END EcDp_Sales_Acc_Price_Concept;