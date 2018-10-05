CREATE OR REPLACE PACKAGE BODY EcDp_Calc_Method IS

/****************************************************************
** Package        :  EcDp_Calc_Method, body part
**
** $Revision: 1.67.2.3 $
**
** Purpose        :  Definition of calculation methods
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.12.1999  Carl-Fredrik S�rensen
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ------      -----     -----------------------------------
** 1.0      22.12.1999  CFS       Initial version
** 3.0      06.03.2000  DN        Two new methods: subsea_wells and curve_ap
** 3.1      10.05.2000  AV        Added new functions
** 3.1      10.05.2000  PGI       Added function: remove_bsw
** 3.2	    18.05.2000  PGI       Changed REMOVE_BSW function to GROSS_BSW
** 3.3      25.05.2000  MAO       Added function: grs_analysis
** 3.4      29.05.2000  AV        Added function: INTERPOLATED_GOR
** 3.5      31.05.2000  CFS       Added function: ATTRIBUTE
** 3.6      15.06.2000  PGI       Added functions CARGO_ANALYSIS, COND_WATER_FRAC
** 3.8      18.07.2000  HNE       Added function API_ANALYSIS, VOLUME_DENSITY, GRS_MASS, GRS_VOL, NET_MASS and NET_VOL
** 3.10	    09.01.2001	G�        Added function FLOWRATE
** 3.11     09.01.2001  UMF       Added function LAB
** 3.12	    08.05.2001	TSB       Added function GRS_BSW_VOL
** 3.13	    18.05.2001	�J        Added function INTERPOLATE_WT
** 3.14	    22.05.2001  MNY       Added function MASS_DENSITY
** 3.15	    25.06.2001  GOZ       Added function SPLIT_FRAC
** 3.16     26.11.2001  DN        Added function INTERMEDIATE
** 3.17     19.12.2001  JDB       Added function CRUDE
** 3.17     19.12.2001  JDB       Added function HEAVY_CRUDE
** 3.19	    22.02.2002  FBa       Added function WELL_ESTIMATE
** 3.20     23.04.2002  HVE       Added function TOTALIZER
** 3.21     06.06.2002  �J        Added function GRS_BSW
**                      TeJ       Added functions WELL_EST_DETAIL and DECLINE
** 3.22     13.03.2004  EOL       Added function FORMULA
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
**          05.12.2005  Rov       TI#2618  Added new function WELL_TEST_AND_ESIMATE and POT_CLOSED_DEFERRED
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
**          23.11.2007  Yoon Oon  ECPD-6635: Added new function AGGR_SUB_DAY_THEOR
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
**          07-05-2012  limmmchu  ECPD-20876:Added function SAMPLE_ANALYSIS
** 			30.04.2013  musthram  ECPD-24081:Added function ALLOC_THEOR
**          08-01-2015  dhavaalo  ECPD-28604: Added the function AGGR_EVENT_THEOR to support New Theoretical Oil/Gas/Wat/Cond Production Method
*****************************************************************/

FUNCTION INTERMEDIATE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'INTERMEDIATE';

END INTERMEDIATE;

--

FUNCTION ALLOCATED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'ALLOCATED';

END ALLOCATED;

--

FUNCTION ALLOC_THEOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'ALLOC_THEOR';

END ALLOC_THEOR;

--

FUNCTION ANALYSIS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'ANALYSIS';

END ANALYSIS;

--

FUNCTION ATTRIBUTE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'ATTRIBUTE';

END ATTRIBUTE;

--

FUNCTION CALCULATED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CALCULATED';

END CALCULATED;

--

FUNCTION CARGO_ANALYSIS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CARGO_ANALYSIS';

END CARGO_ANALYSIS;

--

FUNCTION COMP_ALLOC
RETURN VARCHAR2 IS

BEGIN

   RETURN 'COMP_ALLOC';

END COMP_ALLOC;

--

FUNCTION COMP_ANALYSIS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'COMP_ANALYSIS';

END COMP_ANALYSIS;

--

FUNCTION COND_WATER_FRAC
RETURN VARCHAR2 IS

BEGIN

   RETURN 'COND_WATER_FRAC';

END COND_WATER_FRAC;

--

FUNCTION SUBSEA_WELLS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SUBWELL';

END SUBSEA_WELLS;

--

FUNCTION CURVE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CURVE';

END CURVE;

--

FUNCTION CURVE_LIQUID
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CURVE_LIQUID';

END CURVE_LIQUID;

--

FUNCTION CURVE_GAS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CURVE_GAS';

END CURVE_GAS;

--

FUNCTION CURVE_GAS_LIFT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CURVE_GAS_LIFT';

END CURVE_GAS_LIFT;

--

FUNCTION CURVE_WATER
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CURVE_WATER';

END CURVE_WATER;

--
FUNCTION CURVE_CHOKE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CURVE_CHOKE';

END CURVE_CHOKE;

--

FUNCTION CURVE_CHOKE_NAT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CURVE_CHOKE_NAT';

END CURVE_CHOKE_NAT;

--

FUNCTION CURVE_WHP
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CURVE_WHP';

END CURVE_WHP;

--

FUNCTION CURVE_ANNULUS_PRESS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CURVE_AP';

END CURVE_ANNULUS_PRESS;

--

FUNCTION DERIVED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'DERIVED';

END DERIVED;

--

FUNCTION FORMULA
RETURN VARCHAR2 IS

BEGIN

   RETURN 'FORMULA';

END FORMULA;

--

--------------------------------------------------------------
-- FUNCTION: Gross_Bsw
-- This is primary used to indicate that net volume on
-- a stream is found by removing bsw from gross volume
--------------------------------------------------------------
FUNCTION GROSS_BSW
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GROSS_BSW';

END GROSS_BSW;

--

FUNCTION GRS_BSW
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GRS_BSW';

END GRS_BSW;

--

FUNCTION GRS_ANALYSIS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GRS_ANALYSIS';

END GRS_ANALYSIS;

--

FUNCTION MASS_DENSITY
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MASS_DENSITY';

END MASS_DENSITY;

--

FUNCTION MEASURED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MEASURED';

END MEASURED;

--

FUNCTION TOTALIZER
RETURN VARCHAR2 IS

BEGIN

   RETURN 'TOTALIZER';

END TOTALIZER;

--

FUNCTION NODE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'NODE';

END NODE;

--

FUNCTION QUAL_ANALYSIS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'QUAL_ANALYSIS';

END QUAL_ANALYSIS;

--

FUNCTION WELL_TEST
RETURN VARCHAR2 IS

BEGIN

   RETURN 'PREVIOUS_WT';

END WELL_TEST;

--

FUNCTION REF_STREAM
RETURN VARCHAR2 IS

BEGIN

   RETURN 'REF_STREAM';

END REF_STREAM;

--

FUNCTION REF_VALUE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'REF_VALUE';

END REF_VALUE;

--

FUNCTION SHIP_ALLOC
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SHIP_ALLOC';

END SHIP_ALLOC;

--

FUNCTION SHIP_COMP_ALLOC
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SHIP_COMP_ALLOC';

END SHIP_COMP_ALLOC;

--

FUNCTION SHIP_COMP_STREAM
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SHIP_COMP_STREAM';

END SHIP_COMP_STREAM;

--

FUNCTION SHIP_STREAM
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SHIP_STREAM';

END SHIP_STREAM;

--

FUNCTION THEORETICAL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'THEORETICAL';

END THEORETICAL;

--

FUNCTION WELL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WELL';

END WELL;

--

FUNCTION VOL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'VOL';

END VOL;

--


FUNCTION MASS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MASS';

END MASS;

--

FUNCTION PREV_WT_RPM
RETURN VARCHAR2 IS

BEGIN

   RETURN 'PREV_WT_RPM';

END PREV_WT_RPM;

--

FUNCTION GOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GOR';

END GOR;

--

FUNCTION CALC_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CALC_METHOD';

END CALC_METHOD;

--

FUNCTION INTERPOLATED_GOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'INTERPOLATED_GOR';

END INTERPOLATED_GOR;

--

FUNCTION API_ANALYSIS
RETURN VARCHAR2 IS
BEGIN
   RETURN 'API_ANALYSIS';
END API_ANALYSIS;

--

FUNCTION ANALYSIS_SP_GRAV
RETURN VARCHAR2 IS
BEGIN
   RETURN 'ANALYSIS_SP_GRAV';
END ANALYSIS_SP_GRAV;

--

FUNCTION VOLUME_DENSITY
RETURN VARCHAR2 IS
BEGIN
   RETURN 'VOLUME_DENSITY';
END VOLUME_DENSITY;

--

FUNCTION GRS_MASS
RETURN VARCHAR2 IS
BEGIN
   RETURN 'GRS_MASS';
END GRS_MASS;

--

FUNCTION GRS_VOL
RETURN VARCHAR2 IS
BEGIN
   RETURN 'GRS_VOL';
END GRS_VOL;

--

FUNCTION NET_MASS
RETURN VARCHAR2 IS
BEGIN
   RETURN 'NET_MASS';
END NET_MASS;

--

FUNCTION NET_VOL
RETURN VARCHAR2 IS
BEGIN
   RETURN 'NET_VOL';
END NET_VOL;

--

FUNCTION LAB
RETURN VARCHAR2 IS
BEGIN
   RETURN 'LAB';
END LAB;

--

FUNCTION GRS_BSW_VOL
RETURN VARCHAR2 IS
BEGIN
   RETURN 'GRS_BSW_VOL';
END GRS_BSW_VOL;

--

FUNCTION INTERPOLATE_WT
RETURN VARCHAR2 IS
BEGIN
   RETURN 'INTERPOLATE_WT';
END INTERPOLATE_WT;

--

FUNCTION SPLIT_FRAC
RETURN VARCHAR2 IS
BEGIN
   RETURN 'SPLIT_FRAC';
END SPLIT_FRAC;

--

FUNCTION CRUDE
RETURN VARCHAR2 IS
BEGIN
   RETURN 'CRUDE';
END CRUDE;

--


FUNCTION HEAVY_CRUDE
RETURN VARCHAR2 IS
BEGIN
   RETURN 'HEAVY_CRUDE';
END HEAVY_CRUDE;

--

FUNCTION WELL_EST_DETAIL
RETURN VARCHAR2 IS
BEGIN
   RETURN 'WELL_EST_DETAIL';
END WELL_EST_DETAIL;

--

FUNCTION WELL_EST_PUMP_SPEED
RETURN VARCHAR2 IS
BEGIN
   RETURN 'WELL_EST_PUMP_SPEED';
END WELL_EST_PUMP_SPEED;

--

FUNCTION DECLINE
RETURN VARCHAR2 IS
BEGIN
   RETURN 'DECLINE';
END DECLINE;

--

FUNCTION NA
RETURN VARCHAR2 IS
BEGIN
   RETURN 'NA';
END NA;

--

FUNCTION GROSS_FACTOR
RETURN VARCHAR2 IS
BEGIN
   RETURN 'GROSS_FACTOR';
END GROSS_FACTOR;

--

FUNCTION TANK_DUAL_DIP
RETURN VARCHAR2 IS
BEGIN
   RETURN 'TANK_DUAL_DIP';
END TANK_DUAL_DIP;

--

FUNCTION NET_MASS_WATER
RETURN VARCHAR2 IS
BEGIN
   RETURN 'NET_MASS_WATER';
END NET_MASS_WATER;

--

FUNCTION BATCH_API
RETURN VARCHAR2 IS
BEGIN
   RETURN 'BATCH_API';
END BATCH_API;

--

FUNCTION RUNTIME_RATE
RETURN VARCHAR2 IS
BEGIN
   RETURN 'RUNTIME_RATE';
END RUNTIME_RATE;

--

FUNCTION OPEN_CLOSE_WEIGHT
RETURN VARCHAR2 IS
BEGIN
   RETURN 'OPEN_CLOSE_WEIGHT';
END OPEN_CLOSE_WEIGHT;

--

FUNCTION TOTALIZER_EVENT
RETURN VARCHAR2  IS
BEGIN
   RETURN 'TOTALIZER_EVENT';
END TOTALIZER_EVENT;

--

FUNCTION TOTALIZER_EVENT_EXTRAPOLATE
RETURN VARCHAR2  IS
BEGIN
   RETURN 'TOTALIZER_EVENT_EXTRAPOLATE';
END TOTALIZER_EVENT_EXTRAPOLATE;

--

FUNCTION TOTALIZER_DAY
RETURN VARCHAR2  IS
BEGIN
   RETURN 'TOTALIZER_DAY';
END TOTALIZER_DAY;

--

FUNCTION TOTALIZER_DAY_EXTRAPOLATE
RETURN VARCHAR2  IS
BEGIN
   RETURN 'TOTALIZER_DAY_EXTRAPOLATE';
END TOTALIZER_DAY_EXTRAPOLATE;

--

FUNCTION NET_VOL_WATER
RETURN VARCHAR2 IS
BEGIN
   RETURN 'NET_VOL_WATER';
END NET_VOL_WATER;

--

FUNCTION AGA
RETURN VARCHAR2 IS
BEGIN
   RETURN 'AGA';
END AGA;

--

FUNCTION MEAS_OW_TEST_GOR
RETURN VARCHAR2 IS
BEGIN
   RETURN 'MEAS_OW_TEST_GOR';
END MEAS_OW_TEST_GOR;

--

FUNCTION POTENTIAL_DEFERED
RETURN VARCHAR2 IS
BEGIN
   RETURN 'POTENTIAL_DEFERED';
END POTENTIAL_DEFERED;

--

FUNCTION USER_EXIT
RETURN VARCHAR2 IS
BEGIN
   RETURN 'USER_EXIT';
END USER_EXIT;

--

FUNCTION WET_GAS_MEASURED
RETURN VARCHAR2 IS
BEGIN
   RETURN 'WET_GAS_MEASURED';
END WET_GAS_MEASURED;

--

FUNCTION LIQUID_MEASURED
RETURN VARCHAR2 IS
BEGIN
   RETURN 'LIQUID_MEASURED';
END LIQUID_MEASURED;

--

FUNCTION FORECAST
RETURN VARCHAR2 IS

BEGIN

   RETURN 'FORECAST';

END FORECAST;

--

FUNCTION VOLUME_GCV
RETURN VARCHAR2 IS

BEGIN

   RETURN 'VOLUME_GCV';

END VOLUME_GCV;

--

FUNCTION STEPPED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'STEPPED';

END STEPPED;

--

FUNCTION EXTRAPOLATE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'EXTRAPOLATE';

END EXTRAPOLATE;

--

FUNCTION INTERPOLATE_EXTRAPOLATE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'INTERPOLATE_EXTRAPOLATE';

END INTERPOLATE_EXTRAPOLATE;

--

FUNCTION WELL_EST_DETAIL_DEFERRED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WELL_EST_DETAIL_DEFERRED';

END WELL_EST_DETAIL_DEFERRED;

--

FUNCTION WELL_TEST_AND_ESTIMATE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WELL_TEST_AND_ESTIMATE';

END WELL_TEST_AND_ESTIMATE;

--

FUNCTION POT_CLOSED_DEFERRED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'POT_CLOSED_DEFERRED';

END POT_CLOSED_DEFERRED;

--

FUNCTION NET_VOL_CGR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'NET_VOL_CGR';

END NET_VOL_CGR;

--

FUNCTION NET_VOL_WGR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'NET_VOL_WGR';

END NET_VOL_WGR;

--

FUNCTION GRS_VOL_WDF
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GRS_VOL_WDF';

END GRS_VOL_WDF;

--

FUNCTION GRS_MASS_WDF
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GRS_MASS_WDF';

END GRS_MASS_WDF;

--

FUNCTION GROSS_BSW_SALT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GROSS_BSW_SALT';

END GROSS_BSW_SALT;

--

FUNCTION MEASURED_TRUCKED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MEASURED_TRUCKED';

END MEASURED_TRUCKED;

--

FUNCTION MEASURED_TRUCKED_LOAD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MEASURED_TRUCKED_LOAD';

END MEASURED_TRUCKED_LOAD;

--

FUNCTION MEASURED_TRUCKED_UNLOAD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MEASURED_TRUCKED_UNLOAD';

END MEASURED_TRUCKED_UNLOAD;

--

FUNCTION MEASURED_NET
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MEASURED_NET';

END MEASURED_NET;

--

FUNCTION LAST_RATE_AND_ONTIME
RETURN VARCHAR2 IS

BEGIN

   RETURN 'LAST_RATE_AND_ONTIME';

END LAST_RATE_AND_ONTIME;

--

FUNCTION WELLTEST_FWS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WELLTEST_FWS';

END WELLTEST_FWS;

--

FUNCTION MEASURED_MTH
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MEASURED_MTH';

END MEASURED_MTH;

--

FUNCTION MEASURED_MTH_XTPL_DAY
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MEASURED_MTH_XTPL_DAY';

END MEASURED_MTH_XTPL_DAY;

--

FUNCTION VOLUME_REF_MBTU
RETURN VARCHAR2 IS

BEGIN

   RETURN 'VOLUME_REF_MBTU';

END VOLUME_REF_MBTU;

--

FUNCTION EVENT_INJ_DATA
RETURN VARCHAR2 IS

BEGIN

   RETURN 'EVENT_INJ_DATA';

END EVENT_INJ_DATA;

--

FUNCTION WELL_REFERENCE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WELL_REFERENCE';

END WELL_REFERENCE;

--

FUNCTION AGGR_SUB_DAY_THEOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'AGGR_SUB_DAY_THEOR';

END AGGR_SUB_DAY_THEOR;

--

FUNCTION ENERGY_GCV
RETURN VARCHAR2 IS

BEGIN

   RETURN 'ENERGY_GCV';

END ENERGY_GCV;

--

FUNCTION ONE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'ONE';

END ONE;

--

FUNCTION ZERO
RETURN VARCHAR2 IS

BEGIN

   RETURN 'ZERO';

END ZERO;

--

FUNCTION WPI_RP_BHP
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WPI_RP_BHP';

END WPI_RP_BHP;

--

FUNCTION BHP_SI_BHP_FLOW
RETURN VARCHAR2 IS

BEGIN

   RETURN 'BHP_SI_BHP_FLOW';

END BHP_SI_BHP_FLOW;

--

FUNCTION GAS_WGR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GAS_WGR';

END GAS_WGR;

--

FUNCTION GAS_CGR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GAS_CGR';

END GAS_CGR;

--

FUNCTION OIL_GOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'OIL_GOR';

END OIL_GOR;

--

FUNCTION OIL_WATER_CUT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'OIL_WATER_CUT';

END OIL_WATER_CUT;

--

FUNCTION GAS_WATER_CUT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GAS_WATER_CUT';

END GAS_WATER_CUT;

--

FUNCTION LIQ_WATER_CUT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'LIQ_WATER_CUT';

END LIQ_WATER_CUT;

--

FUNCTION OIL_WOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'OIL_WOR';

END OIL_WOR;

--

FUNCTION FLWL_EST_DETAIL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'FLWL_EST_DETAIL';

END FLWL_EST_DETAIL;

--

FUNCTION MPM
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MPM';

END MPM;

--

FUNCTION WELL_INV_WITHDRAW
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WELL_INV_WITHDRAW';

END WELL_INV_WITHDRAW;

--

FUNCTION GRS_MINUS_NET
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GRS_MINUS_NET';

END GRS_MINUS_NET;

--

FUNCTION CO2_REF_VALUE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CO2_REF_VALUE';

END CO2_REF_VALUE;

--

FUNCTION MASS_DIV_DENSITY
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MASS_DIV_DENSITY';

END MASS_DIV_DENSITY;

--

FUNCTION SYSTEM_DENSITY
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SYSTEM_DENSITY';

END SYSTEM_DENSITY;

--

FUNCTION GRS_MASS_MINUS_WATER
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GRS_MASS_MINUS_WATER';

END GRS_MASS_MINUS_WATER;

--

FUNCTION COMP_ANALYSIS_SPOT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'COMP_ANALYSIS_SPOT';

END COMP_ANALYSIS_SPOT;

--

FUNCTION COMP_ANALYSIS_DAY
RETURN VARCHAR2 IS

BEGIN

   RETURN 'COMP_ANALYSIS_DAY';

END COMP_ANALYSIS_DAY;

--

FUNCTION COMP_ANALYSIS_MTH
RETURN VARCHAR2 IS

BEGIN

   RETURN 'COMP_ANALYSIS_MTH';

END COMP_ANALYSIS_MTH;

--

FUNCTION SAMPLE_ANALYSIS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SAMPLE_ANALYSIS';

END SAMPLE_ANALYSIS;

--

FUNCTION TANK_WELL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'TANK_WELL';

END TANK_WELL;

--

FUNCTION WELL_TANK
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WELL_TANK';

END WELL_TANK;

--

FUNCTION GRS_MASS_BSW_VOL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GRS_MASS_BSW_VOL';

END GRS_MASS_BSW_VOL;

--

FUNCTION MEASURED_API
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MEASURED_API';

END MEASURED_API;

--

FUNCTION REF_GCV
RETURN VARCHAR2 IS

BEGIN

   RETURN 'REF_GCV';

END REF_GCV;

--

FUNCTION EXTERNAL_1
RETURN VARCHAR2 IS

BEGIN

   RETURN 'EXTERNAL_1';

END EXTERNAL_1;

--

FUNCTION EXTERNAL_2
RETURN VARCHAR2 IS

BEGIN

   RETURN 'EXTERNAL_2';

END EXTERNAL_2;

--

FUNCTION EXTERNAL_3
RETURN VARCHAR2 IS

BEGIN

   RETURN 'EXTERNAL_3';

END EXTERNAL_3;

--

FUNCTION EXTERNAL_4
RETURN VARCHAR2 IS

BEGIN

   RETURN 'EXTERNAL_4';

END EXTERNAL_4;

--

FUNCTION MEAS_SWING_WELL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'MEAS_SWING_WELL';

END MEAS_SWING_WELL;

--

FUNCTION WATER_GWR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WATER_GWR';

END WATER_GWR;

--

FUNCTION WET_GAS_MEASURED_DWF
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WET_GAS_MEASURED_DWF';

END WET_GAS_MEASURED_DWF;

--


FUNCTION TOTALIZER_EVENT_RAW
RETURN VARCHAR2 IS

BEGIN

   RETURN 'TOTALIZER_EVENT_RAW';

END TOTALIZER_EVENT_RAW;

--

FUNCTION BUDGET_PLAN
RETURN VARCHAR2 IS

BEGIN

   RETURN 'BUDGET_PLAN';

END BUDGET_PLAN;
--

FUNCTION POTENTIAL_PLAN
RETURN VARCHAR2 IS

BEGIN

   RETURN 'POTENTIAL_PLAN';

END POTENTIAL_PLAN;
--

FUNCTION TARGET_PLAN
RETURN VARCHAR2 IS

BEGIN

   RETURN 'TARGET_PLAN';

END TARGET_PLAN;
--
FUNCTION OTHER_PLAN
RETURN VARCHAR2 IS

BEGIN

   RETURN 'OTHER_PLAN';

END OTHER_PLAN;
--
FUNCTION AGGR_EVENT_THEOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'AGGR_EVENT_THEOR';

END AGGR_EVENT_THEOR;

END EcDp_Calc_Method;