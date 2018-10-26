CREATE OR REPLACE PACKAGE EcDp_Tank IS

/****************************************************************
** Package        :  EcDp_Tank, header part
**
** $Revision: 1.10 $
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
**			23.10.2012	limmmchu	ECPD:22037 added procedure createTankTapsAnalysis
**          22.01.2016	wonggkai	ECPD-30947 added procedure updateTankUsageEndDate
*****************************************************************/

FUNCTION getStartDate(
  p_tank_object_id TANK.OBJECT_ID%TYPE)
RETURN DATE;

FUNCTION getDeadStockVol(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN NUMBER;

FUNCTION getDeadStockMass(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN NUMBER;

FUNCTION getMaxVol(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN NUMBER;

FUNCTION getTankMeterFrequency(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN VARCHAR2;

FUNCTION getTankType(
  p_tank_object_id TANK.OBJECT_ID%TYPE,
  p_daytime        DATE)
RETURN VARCHAR2;

FUNCTION  getTankFacility(
   p_tank_object_id  IN VARCHAR2,
   p_daytime           IN DATE)
RETURN VARCHAR2;

PROCEDURE SetTankTapsEndDate( p_Object_id     VARCHAR2,
                          p_Daytime    DATE,
                          p_DML_Type      VARCHAR2);

PROCEDURE createTankTapsAnalysis(p_object_id VARCHAR2, p_analysis_no NUMBER, p_daytime DATE, p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE updateTankUsageEndDate(p_object_id VARCHAR2, p_daytime DATE);

END EcDp_Tank;