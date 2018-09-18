CREATE OR REPLACE PACKAGE ue_Storage_Lift_Nomination IS

/******************************************************************************
** Package        :  ue_Storage_Lift_Nomination, header part
**
** $Revision: 1.7.4.2 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.04.2006 Kari Sandvik
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 18.10.2006  rajarsar Tracker 4635 - Added deleteNomination Procedure
** 12.09.2012  meisihil  ECPD-20962: Added function setBalanceDelta
** 24.01.2013  meisihil  ECPD-20962: Added functions aggrSubDayLifting, calcSubDayLifting to support liftings spread over hours
** -------     ------   ----------------------------------------------------------------------------------------------------
*/

FUNCTION expectedUnloadDate(p_parcel_no NUMBER) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (expectedUnloadDate, WNDS, WNPS, RNPS);

PROCEDURE deleteNomination(p_storage_id VARCHAR2,p_from_date DATE,p_to_date DATE);

PROCEDURE validateSplit(p_parcel_no NUMBER);

PROCEDURE getDefaultSplit(p_parcel_no NUMBER);

PROCEDURE setBalanceDelta(p_parcel_no NUMBER);

FUNCTION aggrSubDayLifting(p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

PROCEDURE calcSubDayLifting(p_parcel_no NUMBER);

END ue_Storage_Lift_Nomination;