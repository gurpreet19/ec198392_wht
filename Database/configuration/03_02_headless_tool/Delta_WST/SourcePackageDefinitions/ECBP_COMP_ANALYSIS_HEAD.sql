CREATE OR REPLACE PACKAGE EcBp_Comp_Analysis IS
/******************************************************************************
** Package        :  EcBp_Comp_Analysis, header part
**
** $Revision: 1.5 $
**
** Purpose        :  <purpose description>
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.04.2001  John Egil Harveland
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
**          05.10.2016 KESKAASH  ECPD-36304: Added procedure createCompOrfGas.
**          18.10.2016 johamlei	Added function createCompMth
**          20.10.2016 keskaash  ECPD-36865: Modified createCompOrfGas and getStreamCompWtPct, added parameter p_fluid_state
**          29.08.2017 kashisag  ECPD-36104: Added new function findWellHCLiqPhase
**          23.10.2018 kaushaak  ECPD-51659: Added new function calcTheorDens
********************************************************************/

FUNCTION calcTotMolFrac(p_analysis_no NUMBER)
RETURN NUMBER;

FUNCTION calcTotMolPeriodAnFrac(p_analysis_no NUMBER)
RETURN NUMBER;


FUNCTION calcTotMassFrac(p_analysis_no NUMBER)
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
   p_analysis_type      VARCHAR2,
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
   p_analysis_type      VARCHAR2,
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
--   p_sysnam             VARCHAR2,
--   p_stream_code        VARCHAR2,
     p_object_id          stream.object_id%TYPE,
     p_daytime            DATE,
     p_component_no       VARCHAR2,
     p_analysis_type      VARCHAR2,
     p_sampling_method    VARCHAR2,
     p_phase              VARCHAR2 DEFAULT NULL,
     p_fluid_state        VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

PROCEDURE createCompOrfGas(
  p_object_id       VARCHAR2,
  p_daytime         DATE,
  p_orf_type        VARCHAR2,
  p_analysis_type   VARCHAR2,
  p_sampling_method VARCHAR2 DEFAULT NULL,       -- sampling method for acceptable analyses - will also be set on result record
  p_fluid_state     VARCHAR2 DEFAULT NULL,       -- fluid state for acceptable analyses
  p_timescope       VARCHAR2 DEFAULT 'DAY')  ;    -- DAY or MONTH

PROCEDURE createCompMth(
  p_object_id       VARCHAR2,
  p_daytime         DATE,
  p_analysis_type   VARCHAR2,
  p_sampling_method VARCHAR2 DEFAULT NULL,  -- sampling method for acceptable analyses
  p_fluid_state     VARCHAR2 DEFAULT NULL,  -- fluid state for acceptable analyses
  p_method          VARCHAR2 DEFAULT NULL);

-------------------------------------------------------------------
--- Finds the native hydrocarbon liquid phases produced by the well.
--- Investigates all quality-streams found for the well (both through
--- active rbf-connections and alternatively for the configured quality-stream on well
-------------------------------------------------------------------
FUNCTION findWellHCLiqPhase(p_well_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

FUNCTION calcTheorDens(p_object_id       VARCHAR2,   --could be both WELL and STREAM
                       p_daytime         DATE,
                       p_standard_id     VARCHAR2 DEFAULT NULL,
                       p_sampling_method VARCHAR2 DEFAULT NULL,
                       p_fluid_state     VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

END EcBp_Comp_Analysis;