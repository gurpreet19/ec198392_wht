CREATE OR REPLACE PACKAGE EcDp_Delivery_Event_Type IS
/******************************************************************************
** Package        :  EcDp_Delivery_Event_Type, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Contains constants for Delivery Event Type codes.
**
** Documentation  :  www.energy-components.com
**
** Created        :  16.12.2004 Bent Ivar Helland
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   Initial version (first build / handover to test)
** 11.01.2005  BIH   Added / cleaned up documentation
** 09.08.2005 kaurrnar	Added Renomination function
** 12.10.2005 kristin eide	Added funtion qty
********************************************************************/


FUNCTION OFF_SPEC_GAS
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(OFF_SPEC_GAS, WNDS, WNPS, RNPS);

--

FUNCTION RENOMINATION
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(RENOMINATION, WNDS, WNPS, RNPS);

--
FUNCTION QTY
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(QTY, WNDS, WNPS, RNPS);

END EcDp_Delivery_Event_Type;