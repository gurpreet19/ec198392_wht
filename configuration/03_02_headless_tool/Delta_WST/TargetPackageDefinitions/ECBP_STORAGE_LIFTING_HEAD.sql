CREATE OR REPLACE PACKAGE EcBP_Storage_Lifting IS
/******************************************************************************
** Package        :  EcBp_Storage_Lift_Nomination, header part
**
** $Revision: 1.11.76.2 $
**
** Purpose        :  Business logic for storage lift nominations
**
** Documentation  :  www.energy-components.com
**
** Created  : 24.09.2004 Kari Sandvik
**
** Modification history:
**
** Date        Whom     Change description:
** ----------  -----    -------------------------------------------
** 11.10.2005  skjorsti	Added procedure calcLiftedValue and function calcExpectedUnload
** 14.10.2005  skjorsti Added function getLiftedValue
** 02.11.2005  DN       Renamed function getLiftedValue to getLiftedValueByUnloadItem.
** 14.01.2012  meisihil  Added function getHourlyLiftedValue
********************************************************************/

PROCEDURE calcLiftedValue (p_parcel_no NUMBER);
PROCEDURE calcUnloadValue (p_parcel_no NUMBER);

FUNCTION calcExpUnload (p_parcel_no NUMBER, p_product_meas_no NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcExpUnload, WNDS, WNPS, RNPS);

FUNCTION getLiftedValueByUnloadItem (p_parcel_no NUMBER, p_product_meas_no NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getLiftedValueByUnloadItem, WNDS, WNPS, RNPS);

FUNCTION getProdMeasNo(p_parcel_no NUMBER, p_lifting_event VARCHAR2 DEFAULT 'LOAD') RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getProdMeasNo, WNDS, WNPS, RNPS);

FUNCTION getHourlyLiftedValue(p_parcel_no NUMBER, p_daytime DATE, p_product_meas_no NUMBER, p_activity_type VARCHAR2 DEFAULT 'LOAD') RETURN NUMBER;

END EcBP_Storage_Lifting;