CREATE OR REPLACE PACKAGE EcBp_Well_Theoretical_Month IS

/****************************************************************
** Package        :  EcBp_Well_Theoretical_Month, header part
**
** $Revision: 1.59 $
**
** Purpose        :  Calculates theoretical well values
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.09.2015  Alok Dhavale
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- --------------------------------------
** 21.09.15 dhavaalo      Initial version
** 07.10.15 dhavaalo      ECPD-32095-New Theoretical Monthly Method for Steam Injection-Function getInjectedStdRateMonth Added
*****************************************************************/

FUNCTION getOilStdRateMonth(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getGasStdRateMonth(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getWatStdRateMonth(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getCondStdRateMonth(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--
FUNCTION getInjectedStdRateMonth(
   p_object_id well.object_id%TYPE,
   p_inj_type    VARCHAR2,
   p_daytime     DATE,
   p_calc_inj_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

END EcBp_Well_Theoretical_Month;