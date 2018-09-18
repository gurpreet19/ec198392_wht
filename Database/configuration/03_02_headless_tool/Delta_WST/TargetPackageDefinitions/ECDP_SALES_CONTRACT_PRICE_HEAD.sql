CREATE OR REPLACE PACKAGE EcDp_Sales_Contract_Price IS
/******************************************************************************
** Package        :  EcDp_Sales_Contract_Price, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Provides unit price information for a sales contract
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2004 Bent Ivar Helland
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   Initial version (first build / handover to test)
** 11.01.2005  BIH   Added / cleaned up documentation
** 23.11.2006  SSK   Added InsNewPriceElementSet (Moved from EC Revenue)
** 19.01.2011 leeeewei Added new function getAnySubPriceElement
********************************************************************/

--

FUNCTION getNormalGasUnitPrice(
  p_object_id  VARCHAR2,
  p_daytime    DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getNormalGasUnitPrice, WNDS, WNPS, RNPS);

--

FUNCTION getOffspecGasUnitPrice(
  p_object_id  VARCHAR2,
  p_daytime    DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getOffspecGasUnitPrice, WNDS, WNPS, RNPS);

--

FUNCTION getMonthlyTakeOrPayPrice(
  p_object_id        VARCHAR2,
  p_contract_month   DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getMonthlyTakeOrPayPrice, WNDS, WNPS, RNPS);


PROCEDURE InsNewPriceElementSet(
    p_object_id                 VARCHAR2,
    p_price_concept_code        VARCHAR2,
    p_price_element_code        VARCHAR2,
    p_daytime                   DATE,
    p_user                      VARCHAR2
);

FUNCTION getAnyPriceElement(
   p_price_concept_code VARCHAR2,
   p_object_id          VARCHAR2,
   p_daytime            DATE
) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getAnyPriceElement, WNDS, WNPS, RNPS);

FUNCTION getAnySubPriceElement(
   p_price_concept_code VARCHAR2,
   p_object_id          VARCHAR2,
   p_daytime            DATE
) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getAnySubPriceElement, WNDS, WNPS, RNPS);

--

END EcDp_Sales_Contract_Price;