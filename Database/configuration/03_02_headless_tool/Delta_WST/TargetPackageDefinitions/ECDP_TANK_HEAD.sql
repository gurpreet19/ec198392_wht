CREATE OR REPLACE PACKAGE EcDp_Tank IS

/****************************************************************
** Package        :  EcDp_Tank, header part
**
** $Revision: 1.8.120.2 $
**
** Purpose        :  This package is responsible for finding specific
**                   stream properties that is not achievable directly
**                   in the stream objects.
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.11.2001  Frode Barstad
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ----------  ----- --------------------------------------
** 1.0      01.11.2001  FBa   First version
** 1.1      07.02.2002  FBa   Added SetAttribute
** 1.2      30.03.2004  FBa   Removed both functions, added getDeadStockVol and Mass.
**          02.03.2004	Ron	Removed function getTankCalcMethod.
**			17.10.2012	makkkkam	added procedure SetTankTapsEndDate
**			23.10.2012	limmmchu	ECPD:22065 added procedure createTankTapsAnalysis
*****************************************************************/

FUNCTION getStartDate(
  p_tank_object_id TANK.OBJECT_ID%TYPE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getStartDate,WNDS, WNPS, RNPS);

FUNCTION getDeadStockVol(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getDeadStockVol,WNDS, WNPS, RNPS);

FUNCTION getDeadStockMass(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getDeadStockMass,WNDS, WNPS, RNPS);

FUNCTION getMaxVol(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getMaxVol,WNDS, WNPS, RNPS);

FUNCTION getTankMeterFrequency(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getTankMeterFrequency,WNDS, WNPS, RNPS);

FUNCTION getTankType(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getTankType,WNDS, WNPS, RNPS);

FUNCTION  getTankFacility(
   p_tank_object_id  IN VARCHAR2,
   p_daytime           IN DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getTankFacility,WNDS, WNPS, RNPS);

PROCEDURE SetTankTapsEndDate( p_Object_id     VARCHAR2,
                          p_Daytime    DATE,
                          p_DML_Type      VARCHAR2);

PROCEDURE createTankTapsAnalysis(p_object_id VARCHAR2, p_analysis_no NUMBER, p_daytime DATE, p_user_id VARCHAR2 DEFAULT NULL);

END EcDp_Tank;