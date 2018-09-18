CREATE OR REPLACE PACKAGE BODY EcDp_Curve_Parameter IS

/****************************************************************
** Package        :  EcDp_Curve_Parameter, body part
**
** $Revision: 1.7.46.3 $
**
** Purpose        :  Provides declarations for curve parameters (axis)
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.09.2000 Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date     	Whom  	Change description:
** -------  ---------- 	----- 	--------------------------------------
** 			22.08.2002	ATL		Added function GL_RATE
** 4.3      19.09.02    FST		Added GAS_RATE
** 4.4      16.10.2002	EJJ		Added function DP_TUBING
********
**          20.02.2004  BIH   	Added function NONE
**          18.04.2005  Toha  	Added GL_DIFF_PRESS
**	    	03.04.2006  EJJ   	Added DP_CHOKE, GL_CHOKE, GL_PRESS, WATERCUT_PCT, LIQUID_RATE
**			03.12.2007	oonnnng	ECPD-6541: Added AVG_FLOW_MASS
**			30.08.2012  musaamah ECPD-20773: Change function from BH_PRESS to DH_PRESS.
**          22.11.2013  kumarsur ECPD-26104: Added PHASE_CURRENT,AC_FREQUENCY,INTAKE_PRESS,DRIVE_FREQUENCY,DRIVE_CURRENT.
**          02.12.2013  makkkkam ECPD-25991: Added MPM_COND_RATE
*****************************************************************/

-------------------------------------------------------------------------------------------------
-- ANNULUS_PRESS
-- Constant function, returns 'ANNULUS_PRESS'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION ANNULUS_PRESS

RETURN VARCHAR2 IS

BEGIN

  RETURN 'ANNULUS_PRESS';

END ANNULUS_PRESS;


-------------------------------------------------------------------------------------------------
-- NONE
-- Constant function, returns 'NONE'
-- Used as performance curve parameter code
-------------------------------------------------------------------------------------------------
FUNCTION NONE

RETURN VARCHAR2 IS

BEGIN

  RETURN 'NONE';

END NONE;


-------------------------------------------------------------------------------------------------
-- DH_PRESS
-- Constant function, returns 'DH_PRESS'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION DH_PRESS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'DH_PRESS';

END DH_PRESS;

-------------------------------------------------------------------------------------------------
-- CHOKE
-- Constant function, returns 'CHOKE'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION CHOKE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'CHOKE';

END CHOKE;


-------------------------------------------------------------------------------------------------
-- CHOKE_NATURAL
-- Constant function, returns 'CHOKE_NATURAL'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION CHOKE_NATURAL

RETURN VARCHAR2 IS
BEGIN

  RETURN 'CHOKE_NATURAL';

END CHOKE_NATURAL;

-------------------------------------------------------------------------------------------------
-- DRY_OIL_RATE
-- Constant function, returns 'DRY_OIL_RATE'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION DRY_OIL_RATE

RETURN VARCHAR2
IS

BEGIN

  RETURN 'DRY_OIL_RATE';

END DRY_OIL_RATE;


-------------------------------------------------------------------------------------------------
-- GAS_RATE
-- Constant function, returns 'GAS_RATE'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION GAS_RATE

RETURN VARCHAR2
IS

BEGIN

  RETURN 'GAS_RATE';

END GAS_RATE;

-------------------------------------------------------------------------------------------------
-- HXT_WH_PRESS
-- Constant function, returns 'HXT_WH_PRESS'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION HXT_WH_PRESS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'HXT_WH_PRESS';

END HXT_WH_PRESS;

-------------------------------------------------------------------------------------------------
-- INJ_VOL_RATE
-- Constant function, returns 'INJ_VOL_RATE'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION INJ_VOL_RATE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'INJ_VOL_RATE';

END INJ_VOL_RATE;


-------------------------------------------------------------------------------------------------
-- mpm_wh_press
-- Constant function, returns 'MPM_WH_PRESS'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION MPM_WH_PRESS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'MPM_WH_PRESS';

END MPM_WH_PRESS;

--

FUNCTION SS_PRESS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'SS_PRESS';

END SS_PRESS;

--

FUNCTION TS_PRESS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'TS_PRESS';

END TS_PRESS;

--

FUNCTION TS_DSC_PRESS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'TS_DSC_PRESS';

END TS_DSC_PRESS;

-------------------------------------------------------------------------------------------------
-- WH_DSC_PRESS
-- Constant function, returns 'WH_DSC_PRESS'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION WH_DSC_PRESS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'WH_DSC_PRESS';

END WH_DSC_PRESS;

-------------------------------------------------------------------------------------------------
-- WH_PRESS
-- Constant function, returns 'WH_PRESS'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION WH_PRESS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'WH_PRESS';

END WH_PRESS;

-------------------------------------------------------------------------------------------------
-- WH_TEMP
-- Constant function, returns 'WH_TEMP'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION WH_TEMP

RETURN VARCHAR2 IS
BEGIN

  RETURN 'WH_TEMP';

END WH_TEMP;

-------------------------------------------------------------------------------------------------
-- GL_RATE
-- Constant function, returns 'GL_RATE'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION GL_RATE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'GL_RATE';

END GL_RATE;

-------------------------------------------------------------------------------------------------
-- DP_TUBING
-- Constant function, returns 'DP_TUBING'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION DP_TUBING

RETURN VARCHAR2 IS
BEGIN

  RETURN 'DP_TUBING';

END DP_TUBING;


------------------------------------------------------------------------------------------------
-- RPM
-- Constant function, returns 'RPM'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION RPM

RETURN VARCHAR2 IS
BEGIN

  RETURN 'RPM';

END RPM;

------------------------------------------------------------------------------------------------
-- GL_DIFF_PRESS
-- Constant function, returns 'GL_DIFF_PRESS'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION GL_DIFF_PRESS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'GL_DIFF_PRESS';

END GL_DIFF_PRESS;

------------------------------------------------------------------------------------------------
-- DP_CHOKE
-- Constant function, returns 'DP_CHOKE'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION DP_CHOKE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'DP_CHOKE';

END DP_CHOKE;

------------------------------------------------------------------------------------------------
-- GL_CHOKE
-- Constant function, returns 'GL_CHOKE'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION GL_CHOKE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'GL_CHOKE';

END GL_CHOKE;

------------------------------------------------------------------------------------------------
-- GL_PRESS
-- Constant function, returns 'GL_PRESS'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION GL_PRESS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'GL_PRESS';

END GL_PRESS;

------------------------------------------------------------------------------------------------
-- WATERCUT_PCT
-- Constant function, returns 'WATERCUT_PCT'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION WATERCUT_PCT

RETURN VARCHAR2 IS
BEGIN

  RETURN 'WATERCUT_PCT';

END WATERCUT_PCT;

------------------------------------------------------------------------------------------------
-- LIQUID_RATE
-- Constant function, returns 'LIQUID_RATE'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION LIQUID_RATE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'LIQUID_RATE';

END LIQUID_RATE;

------------------------------------------------------------------------------------------------
-- AVG_FLOW_MASS
-- Constant function, returns 'AVG_FLOW_MASS'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION AVG_FLOW_MASS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'AVG_FLOW_MASS';

END AVG_FLOW_MASS;

------------------------------------------------------------------------------------------------
-- DP_FLOWLINE
-- Constant function, returns 'DP_FLOWLINE'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION DP_FLOWLINE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'DP_FLOWLINE';

END DP_FLOWLINE;

------------------------------------------------------------------------------------------------
-- DT_FLOWLINE
-- Constant function, returns 'DT_FLOWLINE'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION DT_FLOWLINE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'DT_FLOWLINE';

END DT_FLOWLINE;

------------------------------------------------------------------------------------------------
-- MPM_OIL_RATE
-- Constant function, returns 'MPM_OIL_RATE'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION MPM_OIL_RATE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'MPM_OIL_RATE';

END MPM_OIL_RATE;

------------------------------------------------------------------------------------------------
-- MPM_GAS_RATE
-- Constant function, returns 'MPM_GAS_RATE'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION MPM_GAS_RATE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'MPM_GAS_RATE';

END MPM_GAS_RATE;

------------------------------------------------------------------------------------------------
-- MPM_WATER_RATE
-- Constant function, returns 'MPM_WATER_RATE'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION MPM_WATER_RATE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'MPM_WATER_RATE';

END MPM_WATER_RATE;

------------------------------------------------------------------------------------------------
-- MPM_COND_RATE
-- Constant function, returns 'MPM_COND_RATE'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION MPM_COND_RATE

RETURN VARCHAR2 IS
BEGIN

  RETURN 'MPM_COND_RATE';

END MPM_COND_RATE;

------------------------------------------------------------------------------------------------
-- PHASE_CURRENT
-- Constant function, returns 'PHASE_CURRENT'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION PHASE_CURRENT

RETURN VARCHAR2 IS
BEGIN

  RETURN 'PHASE_CURRENT';

END PHASE_CURRENT;

------------------------------------------------------------------------------------------------
-- AC_FREQUENCY
-- Constant function, returns 'AC_FREQUENCY'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION AC_FREQUENCY

RETURN VARCHAR2 IS
BEGIN

  RETURN 'AC_FREQUENCY';

END AC_FREQUENCY;

------------------------------------------------------------------------------------------------
-- DRIVE_CURRENT
-- Constant function, returns 'DRIVE_CURRENT'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION DRIVE_CURRENT

RETURN VARCHAR2 IS
BEGIN

  RETURN 'DRIVE_CURRENT';

END DRIVE_CURRENT;

------------------------------------------------------------------------------------------------
-- DRIVE_FREQUENCY
-- Constant function, returns 'DRIVE_FREQUENCY'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION DRIVE_FREQUENCY

RETURN VARCHAR2 IS
BEGIN

  RETURN 'DRIVE_FREQUENCY';

END DRIVE_FREQUENCY;

------------------------------------------------------------------------------------------------
-- INTAKE_PRESS
-- Constant function, returns 'INTAKE_PRESS'
-- Used in lookup function
-------------------------------------------------------------------------------------------------
FUNCTION INTAKE_PRESS

RETURN VARCHAR2 IS
BEGIN

  RETURN 'INTAKE_PRESS';

END INTAKE_PRESS;

END EcDp_Curve_Parameter;