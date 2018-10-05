CREATE OR REPLACE PACKAGE EcDp_Calc_Method IS

/****************************************************************
** Package        :  EcDp_Calc_Method, header part
**
** $Revision: 1.76 $
**
** Purpose        :  Definition of calculation methods
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.12.1999  Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ------      -----     -----------------------------------
** 1.0      27.12.1999  CFS       Initial version
** 3.0      06.03.2000  DN        Two new methods: subsea_wells and curve_ap
** 3.1      10.05.2000  AV        Added new functions
** 3.1      10.05.2000	PGI       Added function remove_bsw
** 3.2	    18.05.2000  PGI       Changed REMOVE_BSW function to GROSS_BSW.
** 3.3      25.05.2000  MAO       Added function grs_analysis
** 3.4      29.05.2000  AV        Added function INTERPOLATED_GOR
** 3.5      31.05.2000  CFS       Added function ATTRIBUTE
** 3.6      15.06.2000  PGI       Added functions CARGO_ANALYSIS, COND_WATER_FRAC
** 3.8      18.08.2000  HNE       Added functions API_ANALYSIS, VOLUME_DENSITY, GRS_MASS, GRS_VOL, NET_MASS and NET_VOL
** 3.10     09.01.2001	GOZ       Added function FLOWRATE
** 3.11     17.01.2001  UMF       Added function LAB
** 3.12	    08.05.2001	TSB       Added function GRS_BSW_VOL
** 3.13	    18.05.2001	?        Added function INTERPOLATE_WT
** 3.14	    22.05.2001  MNY       Added function MASS_DENSITY
** 3.15     26.06.2001	GOZ       Added function SPLIT_FRAC
** 3.16     26.11.2001  DN        Added function INTERMEDIATE
** 3.17     19.12.2001  JDB       Added function CRUDE
** 3.17     19.12.2001  JDB       Added function HEAVY_CRUDE
** 3.19	    22.02.2002  FBa       Added function WELL_ESTIMATE
** 3.20     23.04.2002  HVE       Added function TOTALIZER
** 3.21     06.06.2002  ?        Added function GRS_BSW
**                      TeJ       Added functions WELL_EST_DETAIL and DECLINE
** 3.22     13.04.2004  EOL       Added function FORMULA
**          24.05.2004  FBa       Removed functions MPM, IDUN, F1, F2 and FLOWRATE
**          25.05.2004  FBa       Removed functions PREVIOUS_WT and WELL_ESTIMATE
**          27.05.2004  AV        Added functions NA, GROSS_FACTOR, TANK_DUAL_DIP, BATCH_API
** 1.6      27.05.2004  FBa       Added function WELL_EST_PUMP_SPEED
**          27.05.2004  FBa       Added function ANALYSIS_SP_GRAV
**          28.05.2004  AV        Added functions RUNTIME_RATE, OPEN_CLOSE_WEIGHT
**          28.05.2004  AV        Added functions TOTALIZER_EVENT , NET_VOL_WATER
**          10.06.2004  DN        Removed obsolete manual functions.
**          28.10.2004  Toha      Added function AGA
**          12.04.2005  kaurrnar  Added function MEAS_OW_TEST_GOR
**          22.04.2005  kaurrnar  Added function POTENTIAL_DEFERED
**          02.05.2005  HNE       Added new function USER_EXIT
**          12.05.2005  ROV       Added new function WET_GAS_MEASURED #2136
**          25.07.2005  Darren    TI# 2391 Added new functions DAY_PLAN and MTH_PLAN
**          09.08.2005  Darren    TI# 2234 Added new functions VOLUME_GCV
**          08.09.2005  Darren    TI# 2379 Added new functions STEPPED, EXTRAPOLATE, INTERPOLATE_EXTRAPOLATE
**          15.11.2005  Ron       TI# 2612 Added new function WELL_EST_DETAIL_DEFERRED
**          05.12.2005  Rov       TI#2618  Added new function WELL_TEST_AND_ESTIMATE and POT_CLOSED_DEFERRED
**          19.12.2005  Ron       TI#2615 Added new function NET_VOL_CGR, NET_VOL_WGR, GRS_VOL_WDF, GRS_MASS_WDF
**          20.03.2006  Seongkok  Added function GROSS_BSW_SALT
**          27.03.2006  eizwanik  Added function MEASURED_TRUCKED
**          16.05.2006  johanein  Added function LIQUID_MEASURED
**          06.11.2006  ottermag  Added functions MEASURED_TRUCKED_LOAD/UNLOAD
**          29.11.2006  Rajarsar  Added function MEASURED_NET
**          08.02.2007  Rajarsar  Added function LAST_RATE_AND_ONTIME
**          13.03.2007  zakiiari  ECPD-3714: Added function WELLTEST_FWS
**          19.03.2007  zakiiari  ECPD-5109: Added function MEASURED_MTH and MEASURED_MTH_XTPL_DAY
**          19.03.2007  Lau       ECPD-2026: Added function TOTALIZER_EVENT_EXTRAPOLATE
**          30.04.2007  Rajarsar  ECPD-5248: Added function VOLUME_MBTU
**          31.05.2007  Rajarsar  ECPD-5361: Added function: VOLUME_REF_MBTU and removed VOLUME_MBTU
**          17.08.2007  Rajarsar  ECPD-5562: Added function: EVENT_INJ_DATA
**          27.08.2007  kaurrnar  ECPD-6294: Added function: WELL_REFERENCE
**          23.11.2007  Yoon Oon  ECPD-6635: Added function: AGGR_SUB_DAY_THEOR
**	 	 	    20.02.2008  oonnnng	  ECPD-6978: Added new function ENERGY_GCV.
**	 	 	    04.03.2008  oonnnng	  ECPD-7593: Added new function ONE and ZERO.
**			    04.03.2008  oonnnng	  ECPD-7594: Added function WPI_RP_BHP and BHP_SI_BHP_FLOW.
**          16.04.2008  aliassit  ECPD-6486: Added function NET_MASS_WATER
**          05.05.2008  rajarsar  ECPD-8287: Added function GAS_WGR, GAS_CGR, OIL_GOR, OIL_WATER_CUT, GAS_WATER_CUT, OIL_WOR.
**          19.06.2008  rajarsar  ECPD-6768: Added function WELL_INV_WITHDRAW
**			    15.07.2008	oonnnng	  ECPD-8987: Added function GRS_MINUS_NET.
**	        21.08.2008	rajarsar  ECPD-9038: Added function CO2_REF_VALUE.
**          09.02.2009  farhaann  ECPD-10761:Added function GRS_MASS_MINUS_WATER.
**          26.02.2009  farhaann  ECPD-11055:Added function COMP_ANALYSIS_SPOT, COMP_ANALYSIS_DAY and COMP_ANALYSIS_MTH
**          02.09.2009  farhaann  ECPD-11887:Added function GRS_MASS_BSW_VOL
**          17.11.2009  madondin  ECPD-13196:Added new function for WELL_TANK and rename WELL_TANK to TANK_WELL
**          07.01.2010  farhaann  ECPD-13520:Added function MEASURED_API
**          19.01.2010  aliassit  ECPD-13264:Added function REF_GCV
**          11.02.2010  aliassit  ECPD-13678:Added function EXTERNAL_1, EXTERNAL_2, EXTERNAL_3, EXTERNAL_4
**          11.02.2010  aliassit  ECPD-11535:Added function MEAS_SWING_WELL
**          15.03.2010  leongsei  ECPD-13916:Added function WATER_GWR
**          16.03.2010  aliassit  ECPD-14146:Added function WET_GAS_MEASURED_DWF
**          24.03.2010  mariadav  ECPD-14275:New Stream Gross Volume method for Totalizer
**          08.11.2010  rajarsar  ECPD-15760:Added function BUDGET_PLAN,POTENTIAL_PLAN,TARGET_PLAN,OTHER_PLAN
**          17-11-2011  leongwen  ECPD-18170:Added function CURVE_LIQUID, LIQ_WATER_CUT to support liquid phase calc.
**          19-01-2012  rajarsar  ECPD-19447:Added function CURVE_GAS, CURVE_WATER to support different curve phases correctly.
**          20.02.2012  kumarsur  ECPD-20098: Calc method code "CURVE" fails for all phases other than "OIL".
**          07-05-2012  limmmchu  ECPD-18569:Added function SAMPLE_ANALYSIS
** 					29.04.2013  musthram  ECPD-22038:Added function ALLOC_THEOR
**          23-05-2013  rajarsar  ECPD-23714: Removed function DERIVED.
**          28-05-2013  rajarsar  ECPD-21876: Removed function MEASURED_TRUCK_LOAD and MEASURED_TRUCK_UNLOAD.
**          11-11-2013  leongwen  ECPD-22183: Added the function SEASONAL_VALUE to support stream seasonal values screen.
**          08-01-2015  dhavaalo  ECPD-25537: Added the function AGGR_EVENT_THEOR to support New Theoretical Oil/Gas/Wat/Cond Production Method
**          21-09-2015  dhavaalo  ECPD-31281: Added function MEASURED_NET,PERIOD_WELL_TEST to support New Theoretical Oil/Gas/Wat/Cond Monthly Production Method
**          21.09.2015  kashisag ECPD-29803: Added function for  Consecutive Well Test
**          22-09-2015  kumarsur  ECPD-31862: Added FORECAST_PROD to support new forecast.
**          01-10-2015  dhavaalo  ECPD-32095: Added function SUM_FROM_DAILY,SUM_FROM_DAILY_ALLOCATED to support New Theoretical Monthly Steam injection Method
**          15-07-2016  singishi  ECPD-37144: Added Function EXTERNAL_5
**          07-09-2016  keskaash  ECPD-35948: Added two new functions CHOKE_QUADRATIC_CURVE and CHOKE_QUADRATIC_CURVE_CORR
**          25-08-2016  jainngou  ECPD-36092: Added Function MPM2_CORR and MPM2_CORR to support new meter 1 and 2 correction factor.
**          30-08-2016  beeraneh  ECPD-35760: Added Function MPM_NET
**          27-09-2016  keskaash  ECPD-35756: Added Function SUBWELL.
**          02-01-2017  singishi  ECPD-38497: Added function SAMPLE_ANALYSIS_SPOT,SAMPLE_ANALYSIS_DAY,SAMPLE_ANALYSIS_MTH.
**          03-03-2017  aaaaasho  ECPD-36107: Added function PREALLOC_MEAS_GL.
**          14-03-2018  abdulmaw  ECPD-52711: Added function VFM_PRIORITIZED
*****************************************************************/

FUNCTION INTERMEDIATE
RETURN VARCHAR2;

--

FUNCTION ALLOCATED
RETURN VARCHAR2;

--

FUNCTION ALLOC_THEOR
RETURN VARCHAR2;

--

FUNCTION ANALYSIS
RETURN VARCHAR2;

--

FUNCTION ATTRIBUTE
RETURN VARCHAR2;

--

FUNCTION CALCULATED
RETURN VARCHAR2;

--

FUNCTION CARGO_ANALYSIS
RETURN VARCHAR2;

--
FUNCTION CHOKE_QUADRATIC_CURVE
RETURN VARCHAR2;

--
FUNCTION CHOKE_QUADRATIC_CURVE_CORR
RETURN VARCHAR2;

--
FUNCTION COMP_ALLOC
RETURN VARCHAR2;

--

FUNCTION COMP_ANALYSIS
RETURN VARCHAR2;

--

FUNCTION COND_WATER_FRAC
RETURN VARCHAR2;

--

FUNCTION SUBSEA_WELLS
RETURN VARCHAR2;

--

FUNCTION CURVE
RETURN VARCHAR2;

--

FUNCTION CURVE_LIQUID
RETURN VARCHAR2;

--
FUNCTION CURVE_GAS
RETURN VARCHAR2;

--
FUNCTION CURVE_GAS_LIFT
RETURN VARCHAR2;

--
FUNCTION CURVE_WATER
RETURN VARCHAR2;

FUNCTION CURVE_CHOKE
RETURN VARCHAR2;

--

FUNCTION CURVE_CHOKE_NAT
RETURN VARCHAR2;

--

FUNCTION CURVE_WHP
RETURN VARCHAR2;

--

FUNCTION CURVE_ANNULUS_PRESS
RETURN VARCHAR2;

--

FUNCTION FORMULA
RETURN VARCHAR2;

--

FUNCTION GROSS_BSW
RETURN VARCHAR2;

--

FUNCTION GRS_BSW
RETURN VARCHAR2;

--

FUNCTION GRS_ANALYSIS
RETURN VARCHAR2;

--

FUNCTION MASS_DENSITY
RETURN VARCHAR2;

--

FUNCTION MEASURED
RETURN VARCHAR2;

--

FUNCTION TOTALIZER
RETURN VARCHAR2;

--

FUNCTION NODE
RETURN VARCHAR2;

--

FUNCTION QUAL_ANALYSIS
RETURN VARCHAR2;

--

FUNCTION WELL_TEST
RETURN VARCHAR2;

--

FUNCTION SHIP_ALLOC
RETURN VARCHAR2;

--

FUNCTION SHIP_COMP_ALLOC
RETURN VARCHAR2;

--

FUNCTION SHIP_COMP_STREAM
RETURN VARCHAR2;

--

FUNCTION SHIP_STREAM
RETURN VARCHAR2;

--

FUNCTION REF_STREAM
RETURN VARCHAR2;

--

FUNCTION REF_VALUE
RETURN VARCHAR2;

--

FUNCTION THEORETICAL
RETURN VARCHAR2;

--

FUNCTION WELL
RETURN VARCHAR2;

--

FUNCTION VOL
RETURN VARCHAR2;

--

FUNCTION MASS
RETURN VARCHAR2;

--

FUNCTION PREV_WT_RPM
RETURN VARCHAR2;

--

FUNCTION GOR
RETURN VARCHAR2;

--

FUNCTION CALC_METHOD
RETURN VARCHAR2;

--

FUNCTION INTERPOLATED_GOR
RETURN VARCHAR2;

--

FUNCTION VOLUME_DENSITY
RETURN VARCHAR2;

--

FUNCTION API_ANALYSIS
RETURN VARCHAR2;

--

FUNCTION ANALYSIS_SP_GRAV
RETURN VARCHAR2;

--

FUNCTION GRS_MASS
RETURN VARCHAR2;

--

FUNCTION GRS_VOL
RETURN VARCHAR2;

--

FUNCTION NET_MASS
RETURN VARCHAR2;

--

FUNCTION NET_VOL
RETURN VARCHAR2;

--

FUNCTION LAB
RETURN VARCHAR2;

--

FUNCTION GRS_BSW_VOL
RETURN VARCHAR2;

--

FUNCTION INTERPOLATE_WT
RETURN VARCHAR2;

--

FUNCTION SPLIT_FRAC
RETURN VARCHAR2;

--

FUNCTION CRUDE
RETURN VARCHAR2;

--

FUNCTION HEAVY_CRUDE
RETURN VARCHAR2;

--

FUNCTION WELL_EST_DETAIL
RETURN VARCHAR2;

--

FUNCTION WELL_EST_PUMP_SPEED
RETURN VARCHAR2;

--

FUNCTION DECLINE
RETURN VARCHAR2;

--

FUNCTION NA
RETURN VARCHAR2;

--

FUNCTION GROSS_FACTOR
RETURN VARCHAR2;

--

FUNCTION TANK_DUAL_DIP
RETURN VARCHAR2;

--

FUNCTION NET_MASS_WATER
RETURN VARCHAR2;

--

FUNCTION BATCH_API
RETURN VARCHAR2;

--

FUNCTION RUNTIME_RATE
RETURN VARCHAR2;

--

FUNCTION OPEN_CLOSE_WEIGHT
RETURN VARCHAR2;

--

FUNCTION TOTALIZER_EVENT
RETURN VARCHAR2;

--

FUNCTION TOTALIZER_EVENT_EXTRAPOLATE
RETURN VARCHAR2;

--

FUNCTION TOTALIZER_DAY
RETURN VARCHAR2;

--

FUNCTION TOTALIZER_DAY_EXTRAPOLATE
RETURN VARCHAR2;

--

FUNCTION NET_VOL_WATER
RETURN VARCHAR2;

--

FUNCTION AGA
RETURN VARCHAR2;

--

FUNCTION MEAS_OW_TEST_GOR
RETURN VARCHAR2;

--

FUNCTION POTENTIAL_DEFERED
RETURN VARCHAR2;

--

FUNCTION USER_EXIT
RETURN VARCHAR2;

--

FUNCTION WET_GAS_MEASURED
RETURN VARCHAR2;

--

FUNCTION LIQUID_MEASURED
RETURN VARCHAR2;

--

FUNCTION FORECAST
RETURN VARCHAR2;

--

FUNCTION VOLUME_GCV
RETURN VARCHAR2;

--

FUNCTION STEPPED
RETURN VARCHAR2;

--

FUNCTION EXTRAPOLATE
RETURN VARCHAR2;

--

FUNCTION INTERPOLATE_EXTRAPOLATE
RETURN VARCHAR2;

--

FUNCTION WELL_EST_DETAIL_DEFERRED
RETURN VARCHAR2;

--

FUNCTION WELL_TEST_AND_ESTIMATE
RETURN VARCHAR2;

--

FUNCTION POT_CLOSED_DEFERRED
RETURN VARCHAR2;

--

FUNCTION NET_VOL_CGR
RETURN VARCHAR2;

--

FUNCTION NET_VOL_WGR
RETURN VARCHAR2;

--

FUNCTION GRS_VOL_WDF
RETURN VARCHAR2;

--

FUNCTION GRS_MASS_WDF
RETURN VARCHAR2;

--

FUNCTION GROSS_BSW_SALT
RETURN VARCHAR2;

--

FUNCTION MEASURED_TRUCKED
RETURN VARCHAR2;

--

FUNCTION MEASURED_NET
RETURN VARCHAR2;

--

FUNCTION LAST_RATE_AND_ONTIME
RETURN VARCHAR2;

--

FUNCTION WELLTEST_FWS
RETURN VARCHAR2;

--

FUNCTION MEASURED_MTH
RETURN VARCHAR2;

--

FUNCTION MEASURED_MTH_XTPL_DAY
RETURN VARCHAR2;

--

FUNCTION VOLUME_REF_MBTU
RETURN VARCHAR2;

--

FUNCTION EVENT_INJ_DATA
RETURN VARCHAR2;

--

FUNCTION WELL_REFERENCE
RETURN VARCHAR2;

--

FUNCTION AGGR_SUB_DAY_THEOR
RETURN VARCHAR2;

--

FUNCTION ENERGY_GCV
RETURN VARCHAR2;

--

FUNCTION ONE
RETURN VARCHAR2;

--

FUNCTION ZERO
RETURN VARCHAR2;

--

FUNCTION WPI_RP_BHP
RETURN VARCHAR2;

--

FUNCTION BHP_SI_BHP_FLOW
RETURN VARCHAR2;

--

FUNCTION GAS_WGR
RETURN VARCHAR2;

--

FUNCTION GAS_CGR
RETURN VARCHAR2;

--

FUNCTION OIL_GOR
RETURN VARCHAR2;

--

FUNCTION OIL_WATER_CUT
RETURN VARCHAR2;

--

FUNCTION GAS_WATER_CUT
RETURN VARCHAR2;

--

FUNCTION LIQ_WATER_CUT
RETURN VARCHAR2;

--

FUNCTION OIL_WOR
RETURN VARCHAR2;

--

FUNCTION FLWL_EST_DETAIL
RETURN VARCHAR2;

--

FUNCTION MPM
RETURN VARCHAR2;

--

FUNCTION WELL_INV_WITHDRAW
RETURN VARCHAR2;

--

FUNCTION GRS_MINUS_NET
RETURN VARCHAR2;

--

FUNCTION CO2_REF_VALUE
RETURN VARCHAR2;

--

FUNCTION MASS_DIV_DENSITY
RETURN VARCHAR2;

--

FUNCTION SYSTEM_DENSITY
RETURN VARCHAR2;

--

FUNCTION GRS_MASS_MINUS_WATER
RETURN VARCHAR2;

--

FUNCTION COMP_ANALYSIS_SPOT
RETURN VARCHAR2;

--

FUNCTION COMP_ANALYSIS_DAY
RETURN VARCHAR2;

--

FUNCTION COMP_ANALYSIS_MTH
RETURN VARCHAR2;

--

FUNCTION SAMPLE_ANALYSIS
RETURN VARCHAR2;

--

FUNCTION SAMPLE_ANALYSIS_SPOT
RETURN VARCHAR2;

--

FUNCTION SAMPLE_ANALYSIS_DAY
RETURN VARCHAR2;

--

FUNCTION SAMPLE_ANALYSIS_MTH
RETURN VARCHAR2;

--

FUNCTION TANK_WELL
RETURN VARCHAR2;

--

FUNCTION WELL_TANK
RETURN VARCHAR2;

--

FUNCTION GRS_MASS_BSW_VOL
RETURN VARCHAR2;

--

FUNCTION MEASURED_API
RETURN VARCHAR2;

--

FUNCTION REF_GCV
RETURN VARCHAR2;

--

FUNCTION EXTERNAL_1
RETURN VARCHAR2;

--

FUNCTION EXTERNAL_2
RETURN VARCHAR2;

--

FUNCTION EXTERNAL_3
RETURN VARCHAR2;

--

FUNCTION EXTERNAL_4
RETURN VARCHAR2;

--

FUNCTION EXTERNAL_5
RETURN VARCHAR2;

--

FUNCTION MEAS_SWING_WELL
RETURN VARCHAR2;

--

FUNCTION WATER_GWR
RETURN VARCHAR2;

--

FUNCTION WET_GAS_MEASURED_DWF
RETURN VARCHAR2;

--

FUNCTION TOTALIZER_EVENT_RAW
RETURN VARCHAR2;

--

FUNCTION BUDGET_PLAN
RETURN VARCHAR2;

--

FUNCTION POTENTIAL_PLAN
RETURN VARCHAR2;
--

FUNCTION TARGET_PLAN
RETURN VARCHAR2;

--

FUNCTION OTHER_PLAN
RETURN VARCHAR2;

--

FUNCTION SEASONAL_VALUE
RETURN VARCHAR2;

--

FUNCTION AGGR_EVENT_THEOR
RETURN VARCHAR2;

--

FUNCTION CONSEC_WELL_TEST
RETURN VARCHAR2;

--

FUNCTION PERIOD_WELL_TEST
RETURN VARCHAR2;

FUNCTION SUM_FROM_DAILY
RETURN VARCHAR2;

FUNCTION SUM_FROM_DAILY_ALLOCATED
RETURN VARCHAR2;

--

FUNCTION FORECAST_PROD
RETURN VARCHAR2;

--
FUNCTION MPM_NET
RETURN VARCHAR2;

--

FUNCTION MPM_CORR
RETURN VARCHAR2;

--

FUNCTION MPM2_CORR
RETURN VARCHAR2;

--

FUNCTION SUBWELL
RETURN VARCHAR2;

--

FUNCTION PREALLOC_MEAS_GL
RETURN VARCHAR2;

--

FUNCTION VFM_PRIORITIZED
RETURN VARCHAR2;

END EcDp_Calc_Method;