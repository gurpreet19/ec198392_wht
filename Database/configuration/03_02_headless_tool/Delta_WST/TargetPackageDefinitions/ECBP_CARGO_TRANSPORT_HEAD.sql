CREATE OR REPLACE PACKAGE EcBp_Cargo_Transport IS
/******************************************************************************
** Package        :  EcBp_Cargo_Transport, header part
**
** $Revision: 1.14.40.2 $
**
** Purpose        :  Business logic for cargo transport
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.09.2004 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -------------------------------------------
** #.#   DD.MM.YYYY  <initials>
**       22.06.2006   zakiiari  TI#1955: Added copyBwdNominatedCarrier,getCarrierName procedure spec
**       29.06.2012   meisihil  ECPD-21412: Add getCarrierLaytime function.
********************************************************************/

FUNCTION getLiftingAccount(p_cargo_no NUMBER) RETURN VARCHAR2;

FUNCTION getStorages(p_cargo_no NUMBER) RETURN VARCHAR2;

FUNCTION getCargoName(p_cargo_no NUMBER,p_parcels VARCHAR2) RETURN VARCHAR2;

FUNCTION getCargoNo(p_cargo_name VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCargoNo, WNDS, WNPS, RNPS);

FUNCTION getFirstNomDate(p_cargo_no NUMBER) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getFirstNomDate, WNDS, WNPS, RNPS);

FUNCTION getLastNomDate(p_cargo_no NUMBER) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getLastNomDate, WNDS, WNPS, RNPS);

FUNCTION getDateDiff(p_from_date IN DATE, p_to_date IN DATE) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getDateDiff, WNDS, WNPS, RNPS);

PROCEDURE cleanLonesomeCargoes;

PROCEDURE moveCargo(p_cargo_no NUMBER, p_day_offset NUMBER, p_fcast_id VARCHAR2 DEFAULT NULL);

PROCEDURE bdCargoTransport(p_cargo_no NUMBER);

PROCEDURE auCargoTransport(p_cargo_no NUMBER, p_old_cargo_status VARCHAR2, p_new_cargo_status VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE connectNomToCargo(p_cargo_no NUMBER, p_parcels VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE copyBwdNominatedCarrier(p_cargo_no    NUMBER,
                                  p_carrier_id  VARCHAR2,
                                  p_user        VARCHAR2 DEFAULT NULL);

FUNCTION getCarrierName(p_carrier_id VARCHAR2, p_cargo_no NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getCarrierName, WNDS, WNPS, RNPS);

FUNCTION getCarrierLaytime(p_carrier_id VARCHAR2, p_cargo_no NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getCarrierLaytime, WNDS, WNPS, RNPS);

FUNCTION getCarrierLaytimeDate(p_carrier_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getCarrierLaytimeDate, WNDS, WNPS, RNPS);

END EcBp_Cargo_Transport;