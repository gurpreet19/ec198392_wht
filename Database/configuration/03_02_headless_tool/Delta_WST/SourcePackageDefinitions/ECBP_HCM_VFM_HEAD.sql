CREATE OR REPLACE PACKAGE EcBp_HCM_VFM IS

/****************************************************************
** Package        :  EcBp_HCM_VFM, header part
**
** $Revision: 1.59 $
**
** Purpose        :  To support Technic FMC
**
** Documentation  :  www.energy-components.com
**
** Created  : 13.03.2018  Mawaddah Abdul Latif
**
** Modification history:
**
** Date         Whom      Change description:
** ------       -----     --------------------------------------
** 13.03.2018   abdulmaw  ECPD-52711: Initial version
*****************************************************************/

FUNCTION getOilStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;

FUNCTION getGasStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION getWatStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION getCondStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION getGasLiftStdRateDay(
   p_object_id        well.object_id%TYPE,
   p_daytime          DATE)
RETURN NUMBER;

FUNCTION findOilMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION findGasMassDay (
   p_object_id well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION findWaterMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION findCondMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

END EcBp_HCM_VFM;