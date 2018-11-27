CREATE OR REPLACE PACKAGE EcBp_Forecast_Prod IS
/******************************************************************************
** Package        :  EcBp_Forecast_Prod, header part
**
** $Revision: 1.8 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  23-09-2015 Suresh Kumar
**
** Modification history:
**
** Date        Whom  Change description:
** 23-09-15	  kumarsur	ECPD-31862: Added getProdForecastId, dynCursorGetForecastId.
** 03-05-16   leongwen  ECPD-34297: Added getShortfallOverride and getShortfallFactor functions.
** 20-06-16   leongwen  ECPD-34297: Modified the getShortfallOverride and getShortfallFactor functions for parameter from p_forecast_id to p_scenario_id
** 26-06-16   kashisag  ECPD-36236 : Added getMaxConstraintValue to get maximum value for each phase as per scenario and daytime.
** 12-07-16   kumarsur  ECPD-36900: Modified scenario_id to object_id.
** 24-08-16   kashisag  ECPD-37330: Added getPhaseUOM, getPhaseUOMLabel and getConvertedVolume functions to get Phase UOM and volume as per selected phase
** 23-09-16   kashisag  ECPD-37500: Added new function to calculate the unconstrained potential value
** 13-10-16   khatrnit  ECPD-39279: Added getQuota to get quota as per scenario, daytime and phase
** 24-10-16   kashisag  ECPD-34301: Added new function to find parent for Comparison Code
** 16-12-16 kashisag,jainnraj ECPD-41773 Added new functions setFcstCompVariables,getGrpFcstVarDataGroup,getGrpFcstVarDataMonth,getGrpFcstVarDataDay,
**                            getGrpFcstPhaseDataGroup,getGrpFcstPhaseDataMonth,getGrpFcstPhaseDataDay,getGrpFcstEventDataGroup,getGrpFcstEventDataMonth,getGrpFcstEventDataDay
**                            for BF Forecast Compare Scenario - Direct (PP.0053)
** 27-02-2017 jainnraj  ECPD-40350: Added new functions setFcstAnalysisVariables for BF Forecast Scenarios Analysis (PP.0061).
** 12-05-2017 jainnraj  ECPD-42563: Renamed getProdForecastId and dynCursorGetForecastId to getProdScenarioId and dynCursorGetScenarioId respectively.

********************************************************************/

TYPE rc_fcst_data IS REF CURSOR;
TYPE t_object_id  IS TABLE OF FCST_SHORTFALL_FACTORS.FACTOR_ID%TYPE;
TYPE t_factor     IS TABLE OF FCST_SHORTFALL_FACTORS.OIL_S1P_FACTOR%TYPE;

TYPE t_var_data_rec IS RECORD (FORECAST_ID VARCHAR2(32), OBJECT_ID VARCHAR2(32), FROM_MONTH DATE, TO_MONTH DATE, VARIABLE_CODE VARCHAR2(32), VARIABLE_NAME VARCHAR2(32), SORT_ORDER NUMBER,
                               OIL NUMBER, GAS NUMBER, WAT NUMBER, COND NUMBER, GL NUMBER, DL NUMBER, WI NUMBER, GI NUMBER, SI NUMBER, CI NUMBER);
TYPE t_var_data_tab IS TABLE OF t_var_data_rec;

TYPE t_var_data_rec_mth IS RECORD (FORECAST_ID VARCHAR2(32), OBJECT_ID VARCHAR2(32), MONTH DATE, VARIABLE_CODE VARCHAR2(32), VARIABLE_NAME VARCHAR2(32), SORT_ORDER NUMBER,
                                   OIL NUMBER, GAS NUMBER, WAT NUMBER, COND NUMBER, GL NUMBER, DL NUMBER, WI NUMBER, GI NUMBER, SI NUMBER, CI NUMBER);
TYPE t_var_data_tab_mth IS TABLE OF t_var_data_rec_mth;

TYPE t_phase_data_rec IS RECORD (FORECAST_ID VARCHAR2(32), OBJECT_ID VARCHAR2(32), FROM_MONTH DATE, TO_MONTH DATE, PHASE_CODE VARCHAR2(32), PHASE_NAME VARCHAR2(32), SORT_ORDER NUMBER,
                                 POT_UNCONSTR NUMBER, CONSTR NUMBER, POT_CONSTR NUMBER, S1P_SHORTFALL NUMBER, S1U_SHORTFALL NUMBER, S2_SHORTFALL NUMBER, INT_CONSUMPT NUMBER, LOSSES NUMBER, COMPENSATION NUMBER, AVAIL_EXPORT NUMBER, INJ NUMBER);
TYPE t_phase_data_tab IS TABLE OF t_phase_data_rec;

TYPE t_phase_data_rec_mth IS RECORD (FORECAST_ID VARCHAR2(32), OBJECT_ID VARCHAR2(32), MONTH DATE, PHASE_CODE VARCHAR2(32), PHASE_NAME VARCHAR2(32), SORT_ORDER NUMBER,
                                     POT_UNCONSTR NUMBER, CONSTR NUMBER, POT_CONSTR NUMBER, S1P_SHORTFALL NUMBER, S1U_SHORTFALL NUMBER, S2_SHORTFALL NUMBER, INT_CONSUMPT NUMBER, LOSSES NUMBER, COMPENSATION NUMBER, AVAIL_EXPORT NUMBER, INJ NUMBER);
TYPE t_phase_data_tab_mth IS TABLE OF t_phase_data_rec_mth;

TYPE t_event_data_rec IS RECORD (FORECAST_ID VARCHAR2(32), OBJECT_ID VARCHAR2(32), FROM_MONTH DATE, TO_MONTH DATE, REASON_CODE_1 VARCHAR2(32),OIL_LOSS_VOLUME  NUMBER,GAS_LOSS_VOLUME  NUMBER,COND_LOSS_VOLUME  NUMBER,WATER_LOSS_VOLUME  NUMBER,
                                 WATER_INJ_LOSS_VOLUME  NUMBER,STEAM_INJ_LOSS_VOLUME  NUMBER,GAS_INJ_LOSS_VOLUME  NUMBER,DILUENT_LOSS_VOLUME  NUMBER,GAS_LIFT_LOSS_VOLUME  NUMBER,CO2_INJ_LOSS_VOLUME  NUMBER);
TYPE t_event_data_tab IS TABLE OF t_event_data_rec;

TYPE t_event_data_rec_mth IS RECORD (FORECAST_ID VARCHAR2(32), OBJECT_ID VARCHAR2(32), MONTH DATE, REASON_CODE_1 VARCHAR2(32),OIL_LOSS_VOLUME  NUMBER,GAS_LOSS_VOLUME  NUMBER,COND_LOSS_VOLUME  NUMBER,WATER_LOSS_VOLUME  NUMBER,WATER_INJ_LOSS_VOLUME  NUMBER,
                                     STEAM_INJ_LOSS_VOLUME  NUMBER,GAS_INJ_LOSS_VOLUME  NUMBER,DILUENT_LOSS_VOLUME  NUMBER,GAS_LIFT_LOSS_VOLUME  NUMBER,CO2_INJ_LOSS_VOLUME  NUMBER);
TYPE t_event_data_tab_mth IS TABLE OF t_event_data_rec_mth;


FUNCTION getProdScenarioId(p_object_id        VARCHAR2,
                                 p_daytime          DATE)
RETURN VARCHAR2;

PROCEDURE dynCursorGetScenarioId(p_crs     IN OUT rc_fcst_data,
                            p_object_id    VARCHAR2,
                            p_daytime      DATE
                            );

FUNCTION getShortfallOverride(p_scenario_id   VARCHAR2,
                              p_object_id     VARCHAR2,
                              p_daytime       DATE,
                              p_factor        VARCHAR2
                              )
RETURN NUMBER;

FUNCTION getShortfallFactor(p_scenario_id   VARCHAR2,
                            p_object_id     VARCHAR2,
                            p_daytime       DATE,
                            p_factor        VARCHAR2,
                            p_group_type    VARCHAR2 DEFAULT 'operational')
RETURN NUMBER;

FUNCTION getMaxConstraintValue(
                p_object_id VARCHAR2,
				p_daytime DATE  ,
				p_phase VARCHAR2 )
RETURN NUMBER;

FUNCTION getPhaseUOM( p_phase VARCHAR2
                       )
RETURN VARCHAR2;

FUNCTION getPhaseUOMLabel( p_phase VARCHAR2
                           )
RETURN VARCHAR2;

FUNCTION getConvertedVolume( p_phase      VARCHAR2,
						   p_phase_vol  NUMBER  )
RETURN NUMBER;

FUNCTION getUnconstrainedPotential(
                p_object_id VARCHAR2,
				p_scenario_id VARCHAR2,
				p_daytime DATE,
				p_phase VARCHAR2 )
RETURN NUMBER;

FUNCTION getQuota(
                p_scenario_id VARCHAR2,
                p_daytime DATE,
                p_phase VARCHAR2 )
RETURN NUMBER;


FUNCTION getComparisonParentID( p_comparison_id varchar2,
                                p_group_type   varchar2,
                                p_object_type  varchar2,
                                p_daytime date )
RETURN VARCHAR2;

FUNCTION setFcstCompVariables(p_forecast_id_1 VARCHAR2,p_forecast_id_2 VARCHAR2,p_scenario_id_1 VARCHAR2,p_scenario_id_2 VARCHAR2,p_from_date DATE,p_to_date DATE,p_offset_2 NUMBER) return VARCHAR2;

FUNCTION getGrpFcstVarDataGroup(p_scenario VARCHAR2)
RETURN t_var_data_tab PIPELINED;

FUNCTION getGrpFcstVarDataMonth(p_scenario VARCHAR2)
RETURN t_var_data_tab_mth PIPELINED;

FUNCTION getGrpFcstVarDataDay(p_scenario VARCHAR2)
RETURN t_var_data_tab_mth PIPELINED;

FUNCTION getGrpFcstPhaseDataGroup(p_scenario VARCHAR2 )
RETURN t_phase_data_tab PIPELINED;

FUNCTION getGrpFcstPhaseDataMonth(p_scenario VARCHAR2 )
RETURN t_phase_data_tab_mth PIPELINED;

FUNCTION getGrpFcstPhaseDataDay(p_scenario VARCHAR2 )
RETURN t_phase_data_tab_mth PIPELINED;

FUNCTION getGrpFcstEventDataGroup(p_scenario VARCHAR2)
RETURN t_event_data_tab PIPELINED;

FUNCTION getGrpFcstEventDataMonth(p_scenario VARCHAR2)
RETURN t_event_data_tab_mth PIPELINED;

FUNCTION getGrpFcstEventDataDay(p_scenario VARCHAR2)
RETURN t_event_data_tab_mth PIPELINED;

FUNCTION setFcstAnalysisVariables(p_comparison_code VARCHAR2)
RETURN VARCHAR2;

END EcBp_Forecast_Prod;