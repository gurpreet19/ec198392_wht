CREATE OR REPLACE PACKAGE EcBp_Comp_PC_Analysis IS
/******************************************************************************
** Package        :  EcBp_Comp_PC_Analysis, header part
**
** $Revision: 1.1 $
**
** Purpose        :  <purpose description>
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.02.2010  Kenneth Masamba
**
** Modification history:
**
** Version  Date       Whom  Change description:
** -------  ------     ----- -------------------------------------------
** 1.0      02.04.2000  JEH  Initial Version
** 1.1      30.06.2001  AIE  Handle C7+ in calcCompWtPct,calcCompMolPct
**          02.06.2004  DN   Changed signature in calcCompWtPct and calcCompMolPct functions.
** 1.2      03.08.2004  kaurrnar     removed sysnam and stream_code and update as necessary
**          24.05.2005 DN    TI 2145: Added function calcTotMassFrac, calcTotMolFrac, calcCompMolFrac and calcCompMassFrac.
********************************************************************/

FUNCTION calcTotMolFrac(p_object_id VARCHAR2,p_pc_id VARCHAR2,p_daytime DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcTotMolFrac, WNDS, WNPS, RNPS);

FUNCTION calcTotMolPeriodAnFrac(p_analysis_no NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcTotMolPeriodAnFrac, WNDS, WNPS, RNPS);


FUNCTION calcTotMassFrac(p_object_id VARCHAR2,p_pc_id VARCHAR2,p_daytime DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcTotMassFrac, WNDS, WNPS, RNPS);

FUNCTION calcTotPeriodAnMassFrac(p_analysis_no NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcTotPeriodAnMassFrac, WNDS, WNPS, RNPS);


FUNCTION calcCompWtPct(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_analysis_type      VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_mol_pct            NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcCompWtPct, WNDS, WNPS, RNPS);


FUNCTION calcCompMassFrac(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_pc_id     VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_mol_pct            NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcCompMassFrac, WNDS, WNPS, RNPS);

FUNCTION calcCompMassFracPeriodAn(
   p_object_id          	VARCHAR2,
   p_daytime            	DATE,
   p_daytime_summer_time	VARCHAR2,
   p_component_no       	VARCHAR2,
   p_analysis_type      	VARCHAR2,
   p_sampling_method    	VARCHAR2,
   p_mol_pct            	NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcCompMassFracPeriodAn, WNDS, WNPS, RNPS);

FUNCTION calcCompMolPct(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_analysis_type      VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_weight_pct         NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcCompMolPct, WNDS, WNPS, RNPS);

FUNCTION calcCompMolFrac(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_pc_id              VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_weight_pct         NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcCompMolFrac, WNDS, WNPS, RNPS);


FUNCTION calcCompMolFracPeriodAn(
   p_object_id          	VARCHAR2,
   p_daytime            	DATE,
   p_daytime_summer_time	VARCHAR2,
   p_component_no       	VARCHAR2,
   p_analysis_type      	VARCHAR2,
   p_sampling_method    	VARCHAR2,
   p_weight_pct         	NUMBER)
RETURN NUMBER;


PRAGMA RESTRICT_REFERENCES (calcCompMolFracPeriodAn, WNDS, WNPS, RNPS);
------------------------------------------------------------------
-- getStreamCompWtPct
-- will return a comp wt % from the latest analysis of a stream
------------------------------------------------------------------
FUNCTION getStreamCompWtPct(
     p_object_id          stream.object_id%TYPE,
     p_daytime            DATE,
     p_component_no       VARCHAR2,
     p_analysis_type      VARCHAR2,
     p_sampling_method    VARCHAR2)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getStreamCompWtPct, WNDS, WNPS, RNPS);

PROCEDURE checkAnalysisLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

PROCEDURE CheckFluidComponentLock(p_operation VARCHAR2, p_new_lock_columns EcDp_Month_lock.column_list, p_old_lock_columns EcDp_Month_lock.column_list);

END EcBp_Comp_PC_Analysis;