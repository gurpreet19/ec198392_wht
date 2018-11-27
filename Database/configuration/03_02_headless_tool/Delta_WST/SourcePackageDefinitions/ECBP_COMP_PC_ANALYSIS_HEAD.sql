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
**          20.10.2016 keskaash ECPD-36865: Modified getStreamCompWtPct, added parameter p_fluid_state.
********************************************************************/

FUNCTION calcTotMolFrac(p_object_id VARCHAR2,p_pc_id VARCHAR2,p_daytime DATE)
RETURN NUMBER;

FUNCTION calcTotMolPeriodAnFrac(p_analysis_no NUMBER)
RETURN NUMBER;


FUNCTION calcTotMassFrac(p_object_id VARCHAR2,p_pc_id VARCHAR2,p_daytime DATE)
RETURN NUMBER;

FUNCTION calcTotPeriodAnMassFrac(p_analysis_no NUMBER)
RETURN NUMBER;


FUNCTION calcCompWtPct(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_analysis_type      VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_mol_pct            NUMBER)
RETURN NUMBER;


FUNCTION calcCompMassFrac(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_pc_id     VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_mol_pct            NUMBER)
RETURN NUMBER;

FUNCTION calcCompMassFracPeriodAn(
   p_object_id          	VARCHAR2,
   p_daytime            	DATE,
   p_daytime_summer_time	VARCHAR2,
   p_component_no       	VARCHAR2,
   p_analysis_type      	VARCHAR2,
   p_sampling_method    	VARCHAR2,
   p_mol_pct            	NUMBER)
RETURN NUMBER;

FUNCTION calcCompMolPct(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_analysis_type      VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_weight_pct         NUMBER)
RETURN NUMBER;

FUNCTION calcCompMolFrac(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_pc_id              VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_weight_pct         NUMBER)
RETURN NUMBER;


FUNCTION calcCompMolFracPeriodAn(
   p_object_id          	VARCHAR2,
   p_daytime            	DATE,
   p_daytime_summer_time	VARCHAR2,
   p_component_no       	VARCHAR2,
   p_analysis_type      	VARCHAR2,
   p_sampling_method    	VARCHAR2,
   p_weight_pct         	NUMBER)
RETURN NUMBER;
------------------------------------------------------------------
-- getStreamCompWtPct
-- will return a comp wt % from the latest analysis of a stream
------------------------------------------------------------------
FUNCTION getStreamCompWtPct(
     p_object_id          stream.object_id%TYPE,
     p_daytime            DATE,
     p_component_no       VARCHAR2,
     p_analysis_type      VARCHAR2,
     p_sampling_method    VARCHAR2,
     p_phase              VARCHAR2 DEFAULT NULL,
     p_fluid_state        VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

PROCEDURE checkAnalysisLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

PROCEDURE CheckFluidComponentLock(p_operation VARCHAR2, p_new_lock_columns EcDp_Month_lock.column_list, p_old_lock_columns EcDp_Month_lock.column_list);

END EcBp_Comp_PC_Analysis;