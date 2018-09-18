CREATE OR REPLACE PACKAGE BODY Ue_Tank_Calculation IS
/****************************************************************
** Package        :  Ue_Tank_Calculation, body part
**
** This package is used to program theoretical calculation when a predefined method supplied by EC does not cover the requirements.
** Upgrade processes will never replace this package.
**
** Date:       Whom:   Change description:
** --------    -----   --------------------------------------------
** 21.12.2007  oonnnng ECPD-6716:  Add getBSW() function.
** 07.01.2010  oonnnng ECPD-13585:  Add calcRoofDisplacementVol() function.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrsVol
-- Description    : Returns Tank's Gross Volume
---------------------------------------------------------------------------------------------------
FUNCTION getGrsVol(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGrsVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrsMass
-- Description    : Returns Tank's Gross Mass
---------------------------------------------------------------------------------------------------
FUNCTION getGrsMass(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGrsMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNetMass
-- Description    : Returns Tank's Net Mass
---------------------------------------------------------------------------------------------------
FUNCTION getNetMass(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getNetMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getVolumeCorrectionFactor
-- Description    : Returns Tank's Volume Correction Factor
---------------------------------------------------------------------------------------------------
FUNCTION getVolumeCorrectionFactor(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getVolumeCorrectionFactor;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWaterVol
-- Description    : Returns Tank's Water Volume
---------------------------------------------------------------------------------------------------
FUNCTION getWaterVol(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getWaterVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFreeWaterVol
-- Description    : Returns Tank's Free Water Volume
---------------------------------------------------------------------------------------------------
FUNCTION getFreeWaterVol(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getFreeWaterVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :getObsDens
-- Description    : Returns density at stock tank conditions
---------------------------------------------------------------------------------------------------
FUNCTION getObsDens(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getObsDens;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :getBSWVol
-- Description    : Returns BS and W (volume) at standard conditions
---------------------------------------------------------------------------------------------------
FUNCTION getBSWVol(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getBSWVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :getStdDens
-- Description    : Returns density at standard conditions
---------------------------------------------------------------------------------------------------
FUNCTION getStdDens(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getStdDens;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :getBSWWT
-- Description    : Returns BS and W (volume) at standard conditions
---------------------------------------------------------------------------------------------------
FUNCTION getBSWWT(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getBSWWT;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcRoofDisplacementVol
-- Description    : Returns roof displacement volume
---------------------------------------------------------------------------------------------------
FUNCTION calcRoofDisplacementVol(
   p_object_id          TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_dip_level          NUMBER,
   p_daytime            DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END calcRoofDisplacementVol;

END Ue_Tank_Calculation;