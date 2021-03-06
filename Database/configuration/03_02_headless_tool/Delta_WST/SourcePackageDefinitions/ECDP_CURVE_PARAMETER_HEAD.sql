CREATE OR REPLACE PACKAGE EcDp_Curve_Parameter IS

/****************************************************************
** Package        :  EcDp_Curve_Parameter, header part
**
** $Revision: 1.10 $
**
** Purpose        :  Provides declarations for curve parameters (axis)
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.09.2000 Carl-Fredrik S�rensen
**
** Modification history:
**
** Version  Date     	Whom   	Change description:
** -------  ---------- 	-----  	--------------------------------------
**    	    22.08.2002	ATL    	Added function GL_RATE
** 4.3      19.09.2002	FST    	Added GAS_RATE
** 4.4      16.10.2002	EJJ    	Added function DP_TUBING
********
**          20.02.2004  BIH    	Added function NONE
**          18.04.2005  Toha    Added GL_DIFF_PRESS
**	        03.04.2006  EJJ     Added DP_CHOKE, GL_CHOKE, GL_PRESS, WATERCUT_PCT, LIQUID_RATE
**		    02.12.2007  oonnnng	ECPD-6541: Added AVG_FLOW_MASS
**			23.11.2012 musaamah ECPD-20665: Change function from BH_PRESS to DH_PRESS.
**          22.11.2013 kumarsur ECPD-18576: Added PHASE_CURRENT,AC_FREQUENCY,INTAKE_PRESS,DRIVE_FREQUENCY,DRIVE_CURRENT.
**          02.12.2013 makkkkam ECPD-23832: Added MPM_COND_RATE
**          17.03.2017 mishrdha ECPD-36124: Added new function AVG_DH_PUMP_POWER
**          16.08.2017 shindani ECPD-31708: Added new funtion for AVG_DP_VENTURI.
*****************************************************************/

FUNCTION ANNULUS_PRESS

RETURN VARCHAR2;

--

FUNCTION NONE

RETURN VARCHAR2;

--
FUNCTION DH_PRESS

RETURN VARCHAR2;

--

FUNCTION CHOKE

RETURN VARCHAR2;

--

FUNCTION CHOKE_NATURAL

RETURN VARCHAR2;

--

FUNCTION DRY_OIL_RATE

RETURN VARCHAR2;

--

FUNCTION GAS_RATE

RETURN VARCHAR2;

--

FUNCTION HXT_WH_PRESS

RETURN VARCHAR2;

--

FUNCTION INJ_VOL_RATE

RETURN VARCHAR2;

--

FUNCTION MPM_WH_PRESS

RETURN VARCHAR2;

--

FUNCTION SS_PRESS

RETURN VARCHAR2;

--

FUNCTION TS_PRESS

RETURN VARCHAR2;

--

FUNCTION TS_DSC_PRESS

RETURN VARCHAR2;

--

FUNCTION WH_DSC_PRESS

RETURN VARCHAR2;

--

FUNCTION WH_PRESS

RETURN VARCHAR2;

--

FUNCTION WH_TEMP

RETURN VARCHAR2;

--

FUNCTION GL_RATE

RETURN VARCHAR2;

--

FUNCTION DP_TUBING

RETURN VARCHAR2;

--

FUNCTION RPM

RETURN VARCHAR2;

--

FUNCTION GL_DIFF_PRESS

RETURN VARCHAR2;

--

FUNCTION DP_CHOKE

RETURN VARCHAR2;

--

FUNCTION GL_CHOKE

RETURN VARCHAR2;

--

FUNCTION GL_PRESS

RETURN VARCHAR2;

--

FUNCTION WATERCUT_PCT

RETURN VARCHAR2;

--

FUNCTION LIQUID_RATE

RETURN VARCHAR2;

--

FUNCTION AVG_FLOW_MASS

RETURN VARCHAR2;

--

FUNCTION DP_FLOWLINE

RETURN VARCHAR2;

--

FUNCTION DT_FLOWLINE

RETURN VARCHAR2;

--

FUNCTION MPM_OIL_RATE

RETURN VARCHAR2;

--

FUNCTION MPM_GAS_RATE

RETURN VARCHAR2;

--

FUNCTION MPM_WATER_RATE

RETURN VARCHAR2;

--

FUNCTION MPM_COND_RATE

RETURN VARCHAR2;

--

FUNCTION PHASE_CURRENT

RETURN VARCHAR2;

--

FUNCTION AC_FREQUENCY

RETURN VARCHAR2;

--

FUNCTION DRIVE_CURRENT

RETURN VARCHAR2;
--

FUNCTION DRIVE_FREQUENCY

RETURN VARCHAR2;
--

FUNCTION INTAKE_PRESS

RETURN VARCHAR2;
--

FUNCTION AVG_DH_PUMP_POWER

RETURN VARCHAR2;

FUNCTION AVG_DP_VENTURI
RETURN VARCHAR2;

END EcDp_Curve_Parameter;