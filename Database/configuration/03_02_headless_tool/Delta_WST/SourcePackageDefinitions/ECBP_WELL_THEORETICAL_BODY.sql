CREATE OR REPLACE PACKAGE BODY EcBp_Well_Theoretical IS
/****************************************************************
** Package        :  EcBp_Well_Theoretical, body part
**
** $Revision: 1.223 $
**
** Purpose        :  Calculates theoretical well values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.01.2000  Carl-Fredrik S�sen
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ----------  --------  --------------------------------------
** 1.0      14.01.2000  CFS       Initial version
** 3.0      29.02.2000  DN        Three new functions returns choke or whp from standard rates.
** 3.0      02.03.2000  DN        Two new functions returns injected rates.
**                                4 new functions returns representative values.
** 3.0      10.03.2000  DN        Subtracts gaslift from gas rate functions.
** 3.1      16.03.2000  DN        Heidrun specific temporary solution.
** 3.2      04.05.2000  AV        Changed package to fit new curve model,
**                                Added new functions to find stdRate from halfhour
**                                Moved some functions to EcDp_Well_Theoretical
**                                Summarize procedures only used by Asgard moved to sepatate package
**                                Outdated functions removed.
** 3.3      07.06.2000  AV        Added manual handeling to findOilStdRateHalfHour
**          16.06.2000  �        getInjectedStdRateHalfHour always return 0 if on stream hrs = 0
** 4.0      22.06.2000  DN        Removed ecdp_gas_lift_method.NOT_APPLICABLE-function calls. Better solution needed.
** 4.1      20.07.2000  DN        New function findStdVolInPeriod.

** 4.2      27.07.2000  KB/AV     Added input parameter in cursor, Function getGasStdRateDayFromHalfHour
** 4.3      15.08.2000  AV        Changed find___StdRateHalfour to return 0 if on_strm_hrs = 0
**                                even if lookup value is null.
** 4.4      18.08.2000  DN        The previous change in functions getGasStdRateDay and getWatStdRateDay.
** 4.5      22.08.2000  AV        Added manual to getInjectedStdRateHalfhour using dayly value
** 4.6      31.08.2000  DN        New function calcStdRateDayWellToFlowline.
** 4.7      13.09.2000  TEJ       Fixed bug in getCurveProdStdRate.
**                                New function getCurveInjectionStdRate.
** 4.8      19.09.2000  DN        Bug fix when using MANUAL method. Ref. ECRS DN_00030.
**                                Added sections for GF-F1/F2 methods.
** 4.9      22.09.2000  CFS       Changed all calls to constant functions to EcDp_Curve_Constant
**                                Switched logic regarding mm-conversion of choke, to convert to mm when the curve
**                                is of type choke, and keep the value if the curve is of type CHOKE_NATURAL
** 4.10     28.09.2000  DN        Gas rate functions: CURVE method. Use GOR-method directly if possible.
** 4.11     24.10.2000  HS        Added logic to handle Calc_Method PREV_WT_RPM in findOil/Gas/WaterMassDay functions.
** 4.12     26.10.2000  DN        PREVIOUS_METHOD in getGasStdRateDay and getWatStdRateDay. Bug fix in findGasStdMassDay.
** 4.13     28.11.2000  RRA/BF    GetCurveinjectionStdrate bug fix use INJECTION purpose not PRODUCTION
** 4.14     30.11.2000  DN        findGasMassDay: PREVIOUS_WT, use Gor-density-last-net_oil calculation.
** 4.15     22.01.2001  UMF       New parameter in getXXXStdRateDayFromHalfHour - p_calc_method
** 4.16     24.01.2001  G�      New calc method 'FLOWRATE' in findGasStdRateHalfHour,findWatStdRateHalfHour, getGasStdRateDay and getWatStdRateDay.
** 4.17     12.06.2001  MVO       Add test to findGasMassDay and findOilMassDay to return 0 if on_steam_hrs is 0
**                      MVO       Add use of calc method to getCondStdRateDay
**                                Removed unlogical return of density in mass oilMass function
** 4.18     25.06.2001  DN        Bug fix in calcStdRateDayWellToFlowline. Include boundaries in date range check.
** 4.19     26.06.2001  G�DN     Added new method SPLIT_FRAC in function getInjectedStdRateDay.
** 4.20     17.10.2001  HVE       Added WELL_EVENT as deferment method in get(ogw)stdrateday.
**          09.11.2001  DN        QA previous change.
** 4.21     26.11.2001  DN        Added approach method INTERMEDIATE for interpolation between curves.
** 4.22     22.02.2002  FBa       Added method WELL_ESTIMATE for calculating Oil, Gas and Water rate from alternative well test (well_estimate)
** 4.23     10.04.2002  DN        Added findCondMassDay.
** 4.24     07.05.2002  FBa       Extended getGasLiftStdRateDay to support new method PREVIOUS_WT. Added attribute to use gl_hrs or on_stream_hrs in calculation.
** 4.25     30.05.2002  FBa       Added getGasHeatValDay.
** 4.26     04.06.2002  MTa       Modified getGasStdRateDay to mulitply by on stream ratio for the Previous Well Test method
** 4.27     24.08.2002  HNE       Bugfix in new functions %Samples. Didn't take into account that a well can be shut in.
** 4.28     19.10.2002  EJJ       Added support for curve parameter DP_TUBING (delta pressure over tubing = BHP-WHP)
** 4.29     23.10.2002  FST       Added function getCondStdRateDayFromHalfHour.
** 4.30     26.11.2002  DN        Re-established correct revisions.
** 4.31     02.12.2002  HNE       Added new method to get last welltest rate "WELL_EST_DETAIL". Gets data stored in well_estimate_detail
** 4.32     14.03.2003  HNE       Bugfix in getWatStdRateDay. Method 'WELL_EST_DETAIL' did not asjust for on time
**
**          05.03.2004  BIH       Moved findLookupValue to EcDp_Well_theoretical and renamed it to getCurveParamValue
**                                Added function getCurveStdRate
**                                Rewrote getCurveRate to use new function EcDp_Well_Theoretical.getCurveStdRate
**                                Removed code and raise an exception for performance curve operations that are
**                                not supported in the new performance curve packages.
**                                Generally renamed wgr (WaterGasRatio) to gwr (GasWaterRatio) and updated formulas accordingly
**                                Removed getCurveProdStdRate and getCurveInjectionStdRate.
**          17.03.2004  DN        Replaced ec_flowline_well_attribute with ec_flowline_sub_well_conn.
**          25.05.2004  FBa       Major rewrite for Release 7.4.
**          27.05.2004  FBa       Added support for calc method WELL_EST_PUMP_SPEED
**          27.05.2004  FBa       Added density functions and updated mass functions
**          17.06.2004  LIB       findOilMassDay, findGasMassDay, MassDay, findCondMassDay updated to
**                                call ec_well_attribute.attribute_text_by_id with compare '<=', and not use default '=' more
**          22.06.2004  AV        Corrected the compare '<=' instead of default '=', 2 more places
**                                Also changed behavior for method WELL_EST_PUMP_SPEED in getxxxStdRateDay
**                                to not assume pump ratio = 1 when it is undefined, return NULL
**          11.08.2004  Toha      Replaced sysnam+facility+well_no with well.object_id and updated as necessary.
**          19.10.2004  ROV       Updated getGasStdRateDay. If calc method = WELL_EST_PUMP_SPEED then use last gas rate from well test adjusted
**                                for pump speed ratio and on stream hours ratio.
**                                Updated getWatStdRateDay. If calc method = WELL_EST_PUMP_SPEED then use last water rate from well test adjusted
**                                for pump speed ratio and on stream hours ratio.
**                                Removed a lot of sysnam,facility references that were marked out but should have been removed completely in #1255
**          15.02.2005  Ron       Added new funtion getDiluentStdRateDay to support diluent in well test.
**          18.02.2005  Hang      Direct call to Constant like EcDp_Well_Type.WATER_GAS_INJECTOR is replaced
**                                with new function of EcDp_Well_Type.isWaterInjector as per enhancement for TI#1874.
**          28.02.2005  kaurrnar  Removed deadcodes.
**          02.03.2005  kaurrnar  Removed references to ec_well_attribute, replaced with ec_well_version.calc_method in getCondStdRateDay
**          22.03.2005  DN        Removed function reference in documentation: getOilStdQtyDayValidTest
**          12.04.2005  kaurrnar  Added condition for calc_method = 'MEAS_OW_TEST_GOR' in getOilStdRateDay, getWatStdRateDay, and getGasStdRateDay function
**          12.04.2005  SHN       Performance Test cleanup
**          13.05.2005  ROV       Tracker #2136 Added support for new theoretical methods
**          22.04.2005  kaurrnar  Added condition for new theoretical method - Potential_Deferred to
**                                getOilStdRateDay, getCondStdRateDay, getWatStdRateDay and getGasStdRateDay functions
**          18.04.2005  Toha      TI 1940 added getGasLiftStdRateDay
**                                Update getCurveRate: new function interface.
**          02.05.2005  HNE       Added support for user exit method (calc_method) Tracker 2121)
**          12.05.2005  ROV       Added support for new calc_method = WET_GAS_MEASURED in methods getGasStdRateDay,getCondStdRateDay and getWatStdRateDay
**          03.06.2005  ROV       #1822: Updated all references to EcBp_Well_Potential.calcDayWellDefermentVol to reflect that this function has been renamed to
**                                calcDayWellProdDefermentVol. Fixed error in getWatStdRateDay (phase was specified as WATER instead of WAT)
**          09.06.2005  ROV       #1822: Updated call to getCurveRate in getCondStdRateDay to apply function getGasLiftStdRateDay
**          10.06.2005  ROV       #2310: Updated getGasStdRateDay to use pwel_day_status.avg_flow_rate for calc_method = 'WET_GAS_MEASURED' instead of avg_gas_rate
**                                Added missing divide by zero logic for calc_method = 'WET_GAS_MEASURED' in getGasStdRateDay
**          14.06.2005  ROV       #2349: Addded missing pass of argument avg_gl_diff_press in call to EcBp_Well_Theoretical.getCurveRate in EcBp_Well_Theoretical.getGasLiftStdRateDay
**                      DN        TI2308: Removed function calcWellDefermentVol.
**          22.07.2005  SHN       Tracker 2244. Modified getDiluentStdRateDay. Added support for diluent_method.
**          05.08.2005  Ron       Tracker 2375. Modified getInjectedStdRateDay. Now the function gets the theoretical calculate method from the new well attribute CALC_INJ_METHOD.
**                                Wells can be both producer and injector at the same time. The attribute is to differentiate the calculate method for injection.
**          09.09.2005  Ron       The call for EcDp_Well_Estimate.getLast*StdRate is updated to a new function EcDp_Well_Estimate.get*StdRate to support the new
**                                Well Decline Rate Support where the well can be configureed to have interpolated, extrapolated or stepped rate.
**          09.09.2005  ROV       #1402: Updated functions to use EcDp_Well.getPwelOnStreamHrs/getIwelOnStreamHrs instead of simply reading values from pwel/iwel_day_status
**          23.09.2005  ROV       #2674: Updated calls against getCurveRate to use function getGasLiftStdRateDay for argument p_gas_lift_rate since gas lift can be picked from
**                                other places than the daily well status record.
**          15.11.2005  Ron       TI#2612 : Update function getGasLiftStdRateDay to support new gas lift method - Last Accepted Well Test minus Deferred.
**          12.12.2005  ROV       TI#2618: Added support for new theoretical method 'WELL_TEST_AND_ESTIMATE' in functions get#StdRateDay
**                                Updated theor method 'POTENTIAL_DEFERED' to be different for the two deferement versions.
**          29.12.2005  ROV       TI#2618: Updated all functions using well test data to use actual production day start (00:00)+ prod_day_offset in calls looking up well tests
**                                since valid_from_date on well test results now are specified as a full daytime.
**          10.02.2006  DN        TI#3308: Added test if a well is up prior to calling sub-functions to get estimates.
**          23.03.2006  kaurrnar  TI#2622: Added new function findBSWVol, findCondGasRatio, findSand, findGasOilRatio and findWetDryFactor
**                                Changed function getCondStdRateDay and getGasStdRateDay to call the new function
**          30.03.2006  eizwanik  TI#2341: Edited function getInjectedStdRateDay to calculate theoretical rates for injection wells
**          30.03.2006  eizwanik  TI#3155: Added new functions getGrsLoadOilStdRateDay and getNetLoadOilStdRateDay, to calculate total gross and total net volume
**                                for truck ticket load-to-wells operations
**          04.04.2006  ROV       TI#3299: Updated implementation of method 'WELL_TEST_AND_ESTIMATE' in functions get#StdRateDay
**          05.04.2006  johanein  TI#3668 and 3670: Updated all CURVE methods in functions get#StdRateday, find#MassDay, get#StdVolSubDay
**          11.04.2006  johanein  TI#3331 and 3334: Established correct subtraction of gas lift and diluent from measured wells
**                                New functions: getDiluentStdVolSubDay, getGasLiftStdVolSubDay
**          11.04.2006  olberegi  Removed PD.0001.01 and added PD.0001.02
**          05.05.2006  kaurrnar  TI#2622: Rename findBSWVol to findWaterCutPct
**                                Made changes to findCondGasRatio, findSand, findGasOilRatio and findWetDryFactor method
**          16.05.2006  johanein  TI#3757:Implemented method 'LIQUID_MEASURED' in functions getOilStdRateDay, getGasStdRateDay, getWatStdRateDay
**          29.05.2006  olberegi  TD#6280: The multiplication by ln_on_strm_ratio was removed from the PD.0001.02 calculations.
**          29.05.2006  ottermag  TD#6280: getDayRate functions updated: Multiplying potential with ecdp_well.getPwelPeriodOnStrmFromStatus instead of EcDp_Well.getPwelOnStreamHrs
**          13.09.2006  ottermag  TI1597: In getGasStdRateDay on curve method: Not necessary to check the primary phase and use GOR to get the Gas rate.
**          29.11.2006  rajarsar  TD#4820: Added Calc_Method='MEASURED_NET' in getOilStdRateDay,getGasStdRateDay,getWatStdRateDay,getOilStdVolSubDay,getGasStdVolSubDay,getWatStdVolSubDay
**          31.01.2007  rajarsar  ECPD-3633: Added Calc_Method='LAST_RATE_AND_ONTIME' in getInjectedStdRateDay
**          31.01.2007  rajarsar  ECPD-3633: Added new function : getLastNotNullInjRate
**          01.03.2007  embonhaf  ECPD-5051: Restructured algorithm and removed unnecessary function call to improve performance.
**          07.03.2007  leongsei  ECPD-3713 (PM)[TR#3814] New attributes: Flare and Venting both upstream and downstream of well meter.
**                                Modified WET_GAS_MEASURED calculation formula
**          13.03.2007  zakiiari  ECPD-3714: Modified getGasStdRateDay, getCondStdRateDay, getWatStdRateDay function to handle new calc method WELLTEST_FWS
**          19.03.2007  zakiiari  ECPD-5109: Modified getInjectedStdRateDay function to handle MEASURED_MTH and MEASURED_MTH_XTPL_DAY case
**          27.03.2007  leongsei  ECPD-3713 Added WET_GAS_MEASURED handling to function findCondGasRatio. The handling same as WELL_EST_DETAIL.
**          27.03.2007  rajarsar  ECPD-2281, ECPD-2282, ECPD-2283 Added getInjectedStdVolume, getInjectedStdDailyRate, getProducedStdVolume and getProducedStdDailyRate.
**                                Modified getGasStdRateDay, getWatStdRateDay, getCondStdRateDay and getInjectedStdRateDay to handle TOTALIZER_EVENT and TOTALIZER_EVENT_EXTRAPOLATE
**          20.04.2007  rajarsar  ECPD-2281, ECPD-2282, ECPD-2283 Modified getInjectedStdVolume, getInjectedStdDailyRate, getProducedStdVolume, getProducedStdDailyRate,
**                                getGasStdRateDay, getWatStdRateDay, getCondStdRateDay and getInjectedStdRateDay
**          23.04.2007  rajarsar  ECPD-4823 - Updated getInjectedStdRateDay with the introduction of new attributes:CALC_WATER_INJ_METHOD and CALC_STEAM_INJ_METHOD
**          08.06.2007  embonhaf  ECPD-5278 Modified calculation in getGasStdRateDay - WET_GAS_MEASURED
**          13.6.07     rajarsar  ECPD-2282: Added new function : getLastNotNullClosingValueDate
**                                Modified getInjectedStdVolume, getInjectedStdDailyRate, getProducedStdVolume, getProducedStdDailyRate,
**          17.06.2007  rajarsar  ECPD-5562 Updated getInjectedStdRateDay to include new method - EVENT_INJ_DATA
**          23.08.2007  rajarsar  ECPD-5562 Updated method - EVENT_INJ_DATA in getInjectedStdRateDay.
**          27.08.2007  leong     ECPD-3696 Modified function getInjectedStdRateDay to support stream
**          29.08.2007  kaurrnar  ECPD-6294 Updated findWaterCutPct and findGasOilRatio to support for BSW and GOR in Well Reference Value
**          06.09.07    Lau       ECPD-6268: Added function getGrsLoadOilMassDay and getNetLoadOilMassDay
**          07.09.07    rajarsar  ECPD-6264: Updated function findOilMassDay, findGasMassDay, findWaterMassDay, findCondMassDay
**          21.09.2007  kaurrnar  ECPD-6294: Updated findWaterCutPct by multiplying 100 to the obtained BSW value
**          08.10.2007  leongsei  ECPD-6298: Modified function getOilStdRateDay, getGasStdRateDay, getWatStdRateDay, getCondStdRateDay,
**                                           findOilMassDay, findGasMassDay, findWaterMassDay, findCondMassDay to get pwel_period_status.ACTIVE_WELL_STATUS directly
**          10.10.07    rajarsar  ECPD-6313: Updated function getOilStdRateDay, getGasStdRateDay, getCondStdRateDay, getInjectedStdRateDay
**          23.11.07    Yoon Oon  ECPD-6635: Updated function getOilStdRateDay, getGasStdRateDay, getWatStdRateDay, getCondStdRateDay, getDiluentStdRateDay, getGasLiftStdRateDay
**          03.12.07    oonnnng   ECPD-6541: Add p_avg_flow_mass attribute to getCurveRate, getOilStdRateDay, getGasStdRateDay, getWatStdRateDay, getCondStdRateDay , getInjectedStdRateDay,
**                                           getDiluentStdRateDay, getGasLiftStdRateDay, findOilMassDay, findGasMassDay, findWaterMassDay, findCondMassDay, getOilStdVolSubDay, getGasStdVolSubDay,
**                                           getWatStdVolSubDay and getGasLiftStdVolSubDay functions.
**          04.01.08    masamken  ECPD-6879: Updated  getGasStdRateDay.
**          04.01.08    masamken  ECPD-6861: Updated  findWaterCutPct, findCondGasRatio, findOilRatio, findSand, findWetDryFactor.
**          26.02.2008  ismaiime  ECPD-7702: Modify getDiluentStdRateDay and getGasLiftStdRateDay functions. When calc_method='POTENTIAL_DEFERED', replace prod_daytime to ld_start_daytime when calling ecdp_well.getPwelPeriodOnStrmFromStatus
**          04.03.2008  oonnnng   ECPD-7593: Add new method (ONE) for findWetDryFactor(), and (ZERO) for findWaterCutPct() functions.
**                                           Add new function findWaterGasRatio().
**                                           Amended code in getWatStdRateDay and getGasStdRateDay for WET_GAS_MEASURED, WELLTEST_FWS, TOTALIZER_EVENT and TOTALIZER_EVENT_EXTRAPOLATE methods.
**          04.03.2008  oonnnng   ECPD-7594: Add WPI_RP_BHP method for getOilStdRateDay, getGasStdRateDay, getWatStdRateDay
**                                           Add BHP_SI_BHP_FLOW method for getGasStdRateDay, getCondStdRateDay, getWatStdRateDay
**          01.04.2008  rajarsar  ECPD-7844: Replaced calling to EcDp_Date_Time.getProductionDayOffset with EcDp_ProductionDay.getProductionDayOffset.
**          07.04.2008  aliassit  ECPD-7967: Replaced 'IsIWellNotClosedLT' to 'IsWellNotClosedLt' due to renaming the previous 'IsIwellNotClosedLT' inside the EcDp_Well package
**          18.04.2008  sharawan  ECPD-8222: Modified functions getOilStdVolSubDay, getGasStdVolSubDay, getWatStdVolSubDay, getCondStdVolSubDay,
**                                            getGasLiftStdVolSubDay, getDiluentStdVolSubDay to read the new attribute to determine the method.
**          08.05.08    rajarsar  ECPD-8339: Add new function declineResult().
**          08.05.08    rajarsar  ECPD-5065: Added new function findWaterOilRatio().
**          08.05.08    rajarsar  ECPD-8287: Modified getOilStdRateDay, getGasStdRateDay, getWatStdRateDay, getCondStdRateDay,
**                                getOilStdVolSubDay, getGasStdVolSubDay, getWatStdVolSubDay, getCondStdVolSubDay.
**          26.05.08    oonnnng   ECPD-8471: Replace USER_EXIT test statements with [ (substr(lv2_gas_lift_method,1,9) = EcDp_Calc_Method.USER_EXIT) ].
**          04.07.2008  leeeewei  ECPD-8677: Replace getGasLiftStdRateDay in getOilStdVolSubDay, getWatStdVolSubDay and getCondStdVolSubDay with getGasLiftStdVolSubDay
**          08.07.2008  leeeewei  ECPD-8552: Removed test for well type in getGasStdVolSubDay
**          26.08.2008  rajarsar  ECPD-9038: Added new function getCO2StdRateDay() and updated getGasStdRateDay().
**          10.10.2008  leeeewei  ECPD-10029: Added test for zero oil volume for OIL_GOR, OIL_WOR,GAS_WGR, OIL_WATER_CUT, GAS_WATER_CUT method in getGasStdRateDay and getWatStdRateDay function
**          10.10.2008  ismaiime  ECPD-8745 Updated implementation of method WELL_TEST_AND_ESTIMATE, POTENTIAL_DEFERED and WET_GAS_MEASURED to return 0 when strm hours is 0
**          17.10.2008  rajarsar  ECPD-9038 Updated getGasStdRateDay()
**          26.11.2008  embonhaf  ECPD-10362 Updated functions getGas, getWat and getCondStdRateDay to return 0 instead of null which causes allocation to fail
**          31.12.2008  sharawan  ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                                 getCondStdRateDay, getInjectedStdRateDay, findOilStdDensity, findGasStdDensity, findOilMassDay, findGasMassDay, findWaterMassDay,
**                                 findCondMassDay, getOilStdVolSubDay, getGasStdVolSubDay, getWatStdVolSubDay, getCondStdVolSubDay, getDiluentStdVolSubDay,
**                                 getGasLiftStdVolSubDay, findWaterCutPct, findCondGasRatio, findSand, findGasOilRatio, findWetDryFactor, getInjectedStdVolume,
**                                 getProducedStdVolume, findWaterGasRatio.
**          02.01.2009  oonnnng   ECPD-9983: Update findOilStdDensity() and findGasStdDensity() functions by replace getLastAnalysisSampleByObject with getLastAnalysisSample.
**          06.02.2009  madondin  ECPD-10905: Modified getOilStdRateDay for method WPI_RP_BHP to adjust on_time
**          23.02.2009  rajarsar  ECPD-10975: Added checking for daylight savings for all getStdRateDay() functions.
**          27.07.2009  leongsei  ECPD-11962: Modified function getInjectedStdRateDay, method EVENT_INJ_DATA
**          25.08.2009  leongsei  ECPD-12353: Modified function getOilStdRateDay, method WELL_EST_DETAIL
**          08.10.2009  leongwen  ECPD-12867: Problems with new BF Daily Well Tank Data
**          05.11.2009  oonnnng   ECPD-13190: Amended the 'c_well_tank' cursor in getOilStdRateDay(), getWatStdRateDay(), and getCondStdRateDay() functions to filter 'exclude_well_tank' attribute .
**          01.12.2009  madondin  ECPD-13310: Modified getOilStdRateDay by adding new well type=GAS_PRODUCER_2
**          21.01.2010  rajarsar  ECPD-13196: Added new function findBSWTruck and updated getOilStdRateDay, getWatStdRateDay and getCondStdRateDay
**          27.01.2010  aliassit  ECPD-13264: Added new function getGasEnergyDay() and findGCV()
**          28.01.2010  madondin  ECPD-13375: WELL - Added USER_EXIT to function findOilStdDensity, findGasStdDensity and findWatStdDensity
**          03.03.2010  aliassit  ECPD-13264: Removed p_todat from findGCV()
**          12.02.2010  oonnnng   ECPD-13772: Modified function getGasStdVolSubDay for method OIL_GOR.
**          19.02.2010  aliassit  ECPD-13678: Added support for 4 external calculated theoretical rates per well for oil, cond, water and gas
**          18.02.2010  musaamah  ECPD-13894: Update sumTruckedNetOilFromWell(), sumTruckedWaterFromWell() and findBSWTruck() to exclude view WELL_LOADED_FROM_TRUCK.
**          03.03.2010  musaamah  ECPD-13369: Modified function getOilStdRateDay, getWatStdRateDay and getCondStdRateDay to include 'trucked out volume' in the theoretical methods for Oil, Cond and Water.
**          09.03.2010  aliassit  ECPD-13678: Modified the external theoretical methods to NOT adjust the on_time.
**          15.03.2010  leongsei  ECPD-13916: Modified func getGasStdRateDay, getWatStdRateDay and added findGasWaterRatio
**          18.03.2010  aliassit  ECPD-14146: Added new findDryWetFactor()
**          23.03.2010  oonnnng   ECPD-13618: Add support for WELL_TEST_AND_ESTIMATE method option in getCondStdRateDay() function.
**          23.03.2010  aliassit  ECPD-11535: Added function getGasStdRateDay, getCondStdRateDay and getWatStdRateDay to support Measured Swing Well
**          08.05.2010  oonnnng   ECPD-13075: Amended logic to return null when on_stream_hours is null in getOilStdRateDay(), getGasStdRateDay(), getWatStdRateDay(), getCondStdRateDay(), getInjectedStdRateDay(), getDiluentStdRateDay(), getGasLiftStdRateDay(), getCO2StdRateDay() functions.
**          05.05.2010  Leongwen  ECPD-10821: Misc sub daily improvements.
**          22.05.2010  aliassit  ECPD-14305: fix the MEAS_SWING_WELL in getGasStdRateDay, getWatStdRateDay and getCondStdRateDay
**          27.05.2010    madondin  ECPD-14324: Modified in function getOilStdRateDay and getOilStdVolSubDay, added well type GAS_PRODUCER_2(GP2)
**        16.07.2010  madondin  ECPD-14959: Modified in function getOilStdVolSubDay, getGasStdVolSubDay, getWatStdVolSubDay, getCondStdVolSubDay and getDiluentStdVolSubDay for EcDp_Calc_Method.MEASURED
**            19.11.2010  leeeewei  ECPD-16016: Modified calc method = WELL_REFERENCE in findOilStdDensity and findGasStdDensity
**            26.11.2010  syazwnur  ECPD-15993: Modified getGasLiftStdRateDay and getDiluentStdRateDay
**          14.12.2010  farhaann  ECPD-15823: Modified getProducedStdVolume and getProducedStdDailyRate.
**          15.12.2010  farhaann  ECPD-15823: Added totalizer event and totalizer event extrapolate method in getOilStdRateDay and getCondStdRateDay.
**          28-01-2011  leongwen  ECDP-16574: To correct and enhance the screens which are affected by the changes made in ECPD-16525.
**            28-02-2011    madondin  ECPD-16316: Modified getProducedStdVolume and getInjectedStdVolume to check the opening reading
**      08-03-2011  sharawan  ECPD-16612: Modified getGasLiftStdVolSubDay to cater for any on_stream_hrs adjustment when EcDp_Calc_Method.MEASURED.
**        05.07.2011  rajarsar  ECPD-17700: Updated getCurveRate to add p_calc_method as passing parameter and updated getOilStdRateDay,getGasStdRateDay,getWatStdRateDay,getCondStdRateDay and getInjectedStdRateDay.Updated findGasOilRatio and findWaterCutPct.
**      17-11-2011  leongwen  ECPD-18170: Updated getOilStdRateDay, getGasStdRateDay, getWatStdRateDay, getCondStdRateDay, findOilMassDay, findGasMassDay, findWaterMassDay,findCondMassDay,
**                                                getOilStdVolSubDay, getWatStdVolSubDay, getCondStdVolSubDay, findCondGasRatio, findGasOilRatio, findWaterGasRatio
**                                                with checking on EcDp_Calc_Method.CURVE_LIQUID and its related changes.
**        19.01.2012  rajarsar  ECPD-19447: Updated getOilStdRateDay,getGasStdRateDay,getWatStdRateDay,getCondStdRateDay,findCondGasRatio,findWaterGasRatio,getWaterGasRatio and findWaterOilRatio.
**        03.02.2012  rajarsar  ECPD-19740: Updated sumTruckedNetOilFromWell,sumTruckedWaterFromWell,findBSWTruck, getGrsLoadOilStdRateDay and getNetLoadOilStdRateDay.
**      20.02.2012 kumarsur ECPD-20098: Calc method code "CURVE" fails for all phases other than "OIL".
**      23.04.2012 syazwnur ECPD-20141: Updated getOilStdRateDay, getGasStdRateDay, getWatStdRateDay and getCondStdRateDay.
**        26.04.2012 choonshu    ECPD-19825: Updated getGasStdRateDay, getWatStdRateDay and getCondStdRateDay
**      03.05.2012 syazwnur ECPD-20506: Updated getOilStdVolSubDay, getGasStdVolSubDay, getWatStdVolSubDay and getCondStdVolSubDay.
**      22.05.2012 limmmchu ECPD-20273: Added NVL() function in getCondStdRateDay.
**      28.05.2012 limmmchu ECPD-4489 : Updated findWaterCutPct() and findCondGasRatio().
**      16.07.2012 leongwen ECPD-21376: Added the function getInjectedMassStdRateDay()
**         17-10-2012 kumarsur ECPD-21509: Modified findWaterCutPct ,findCondGasRatio, findGasOilRatio, findWaterGasRatio and findWaterOilRatio
**        01.11.2012 abdulmaw    ECPD-22037: Modified getInjectedStdRateDay
**        09.11.2012 limmmchu    ECPD-21585: Modified findOilMassDay, findGasMassDay, findWaterMassDay and findCondMassDay
**        21.01.2013 leongwen    ECPD-18492: Modified declineResult function to pass the p_daytime and p_from_date to ue_well_theoretical.declineResult
**        18.04.2013 wonggkai    ECPD-23800: Modified sum in function sumTruckedNetOilFromWell and sumTruckedWaterFromWell
**        28.05.2013 rajarsar    ECPD-21876: Modified function findBSWTruck,sumTruckedNetOilFromWell and sumTruckedWaterFromWell
**      14-06-2013 musthram ECPD-22763: Modified function findWaterCutPct
**        20.06.2013 rajarsar    ECPD-21876: Updated getGrsLoadOilMassDay, getNetLoadOilMassDay, sumTruckedNetOilFromWell and sumTruckedWaterFromWell.
**        14.08.2013 kumarsur    ECPD-24901: Modified getWatStdVolSubDay and getWatStdRateDay, added validation to avoid divide by zero for the LIQ_WATER_CUT methods
**      11.09.2013 musthram ECPD-24902: Modified getOilStdVolSubDay, getGasStdVolSubDay, getWatStdVolSubDay, getCondStdVolSubDay to support getGasLiftStdVolSubDay correctly
**      20.09.2013 musthram ECPD-25136: Modified getInjectedStdRateDay to support null values for inj_vol attribute
**        24.09.2013 kumarsur    ECPD-25305: Modified getNetLoadOilStdRateDay and getGrsLoadOilStdRateDay , added new function getLoadWaterStdRateDay.
**      23.09.2013 abdulmaw ECPD-24127: Modified getOilStdRateDay, getGasStdRateDay, getWatStdRateDay, getCondStdRateDay to support Override Theoretical Figures
**         25.09.2013 abdulmaw ECPD-24092: Added new function findAvgPrevMthBswTruck.
**         02.10.2013 abdulmaw ECPD-24427: Added new function getMeterMethod and modified getGasStdRateDay to support configurable meter correction method.
**         08.10.2013 abdulmaw ECPD-24390: Added new function findFuelFlareVent, sumFuelFlareVent and modified getGasStdRateDay to support fuel, flare and vent in well.
**         13.11.2013 abdulmaw ECPD-22183: Modified findFuelFlareVent to support well seasonal value.
**        22.11.2013 kumarsur    ECPD-18576: Modified getCurveRate added p_phase_current,p_ac_frequency and p_intake_press.
**         02.12.2013 makkkkam ECPD-23832: Modified getCurveRate added p_mpm_oil_rate,p_mpm_gas_rate,p_mpm_water_rate and p_mpm_cond_rate.
**         20.01.2014 wonggkai ECPD-26368: Performance tuning on method getOilStdRateDay, getGasStdRateDay, getWatStdRateDay, getCondStdRateDay, findDryWetFactor, getMeterMethod, findFuelFlareVent
**        29.01.2014 kumarsur    ECPD-26699: Modified getWatStdRateDay,getOilStdRateDay and getGasStdRateDay functions, removed lr_well_version.isGasProducer checking.
**         05.02.2014 wonggkai ECPD-26368: Modified getOilStdRateDay for well type GAS_PRODUCER_2
**         06.02.2014 wonggkai ECPD-26368: Bug fixed getWatStdRateDay for MPM method
**      25.03.2014 dhavaalo ECPD-26434  Theoretical water volume method on sub daily well
**         06.02.2014 wonggkai ECPD-27357: Remove commented/ unused code.
**         05.06.2014 dhavaalo ECPD-27333: Modified EcDp_Well_Theoretical.populateCurveParameterValues,getOilStdVolSubDay,getGasStdVolSubDay,getWatStdVolSubDay,getCondStdVolSubDay,getGasLiftStdVolSubDay,findWaterCutPct,findCondGasRatio ,findGasOilRatio
**                                        function to calculate Theoretical Water and Gas values correctly for day offset for Daily and sub-daily screen.
**         05.06.2014 dhavaalo ECPD-27333: Modified findWaterGasRatio,findWaterOilRatio function to calculate Theoretical Water and Gas values correctly for day offset for Daily and sub-daily screen.
**         25.11.2014 kumarsur ECPD-29460: Modified getCondStdRateDay, getOilStdRateDay, getGasStdRateDay and getWatStdRateDay.
**         26.11.2014 abdulmaw ECPD-29389: Modified getOilStdRateDay, getGasStdRateDay, getWatStdRateDay, getCondStdRateDay, getInjectedStdRateDay, getDiluentStdRateDay and getGasLiftStdRateDay to support PD.0020
**      22.12.2014 abdulmaw ECPD-29593: Modified getInjectedStdRateDay to use getIwelPeriodOnStrmFromStatus
**         08.01.2015 dhavaalo ECPD-25537: Added new function getOilStdRateEvent,getGasStdRateEvent,getWatStdRateEvent and getCondStdRateEvent
**        26.02.2015 dhavaalo ECPD-29953: Modified getOilStdRateDay, getGasStdRateDay, getWatStdRateDay, getCondStdRateDay
** 		  19.06.2015 dhavaalo ECPD-27830: Modified getGasStdRateDay as to include gas lift
**        21.09.2015 kashisag ECPD-29803: Added logic Consecutive Well Test for Oil, Gas, Water and Cond.
**      24.02.2016 kashisag ECPD-32010: Bug in EcBp_Well_Theoretical functions in the way override flag is handled
**      12.04.2016 jainnraj ECPD-33875: Modified getOilStdRateDay,getGasStdRateDay,getWatStdRateDay,getCondStdRateDay,getGasLiftStdRateDay,findOilMassDay,
findGasMassDay,findWaterMassDay,findCondMassDay to modify all the curve methods using pwel_day_status.avg_annulus_press to pwel_day_status.avg_annulus
**  	22.04.2016 jainnraj ECPD-34113: Modified findSeasonalWell to make changes for Seasonal value calculation for non leap year
**      05.07.2015 chaudgau ECPD-29040: Modified parameter list to add p_today param and its support to function getNetLoadOilStdRateDay and getLoadWaterStdRateDay
**  	07.07.2016 khatrnit ECPD-36218: Modified getGasLiftStdVolSubDay to support CURVE_GAS_LIFT as calculation method
**      15.07.2016 Singishi ECPD-37144: Added External Calculated Theoretical Rate 5
**      30.08.2016 beeraneh ECPD-35760: Added new functions findHCMassDay, findHCMassSubDay.
**	    07.09.2016 keskaash ECPD-35948: Added two new oil volume calculation methods CHOKE_QUADRATIC_CURVE and CHOKE_QUADRATIC_CURVE_CORR
**      22.09.2016 kolleadr ECPD-35914: Enhanced method support for well MPM rates
**      28.02.2017 khatrnit ECPD-37524: Added support for override in getInjectedStdRateDay
**      03.03.2017 aaaaasho ECPD-36107: Added new method support for preallocation of measured gaslift in getGasLiftStdRateDay
** 		07.03.2017 dhavaalo ECPD-27202: Modified getGasStdRateDay -Well Theoretical Gas Method = "BHP_SI_BHP_FLOW" must be adjusted for on_time
**      31.03.2017 chaudgau ECPD-36124: Modified getCurveRate and its calls in other sub programs to support new Curve Parameter AVG_DH_PUMP_POWER
**      10.04.2017 choooshu ECPD-44853: Fixed wrong id used in PREALLOC_MEAS_GL for getGasLiftStdRateDay
**      13.07.2017 singishi ECPD-46244: added zero check for OIL_WOR, GAS_CGR in getWatStdVolSubDay and getCondStdVolSubDay
**      16.08.2017 shindani ECPD-31708: Modified getCurveRate to support new Curve Parameter AVG_DP_VENTURI.
**      21.11.2017 dhavaalo ECPD-45043: Remove reference of PD.0006.
**      01.03.2018 singishi ECPD-51137: Removed all the references for PD.0001.02 and PD.0002.02
**      13.03.2018 abdulmaw ECPD-52711: Added support for EcBp_HCM_VFM
**      01.10.2018 abdulmaw ECPD-50441: Added support for VFM and VFM_NET
**      22.10.2018 solibhar ECPD-49510: Added support for MPM2 and MPM2_NET in getOilStdRateDay,getGasStdRateDay,getWatStdRateDay,getCondStdRateDay and in getOilStdVolSubDay,getGasStdVolSubDay,getWatStdVolSubDay,getCondStdVolSubDay
**      23.10.2018 kaushaak ECPD-51659: Modified findGasStdDensity
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurveRate
-- Description    : Returns theoretical rate from performance curve
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ECDP_WELL_THEORETICAL.GETPERFORMANCECURVEID
--                  EC_PERFORMANCE_CURVE.CURVE_PARAMETER_CODE
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCurveRate(p_object_id       well.object_id%TYPE,
                      p_daytime         DATE,
                      p_phase           VARCHAR2,
                      p_curve_purpose   VARCHAR2,
                      p_choke_size      NUMBER,
                      p_wh_press        NUMBER,
                      p_wh_temp         NUMBER,
                      p_bh_press        NUMBER,
                      p_annulus_press   NUMBER,
                      p_wh_usc_press    NUMBER,
                      p_wh_dsc_press    NUMBER,
                      p_bs_w            NUMBER,
                      p_dh_pump_rpm     NUMBER,
                      p_gl_choke        NUMBER,
                      p_gl_press        NUMBER,
                      p_gl_rate         NUMBER,
                      p_gl_diff_press   NUMBER DEFAULT 0,
                      p_avg_flow_mass   NUMBER DEFAULT 0,
                      p_phase_current   NUMBER,
                      p_ac_frequency    NUMBER,
                      p_intake_press    NUMBER,
                      p_mpm_oil_rate    NUMBER,
                      p_mpm_gas_rate    NUMBER,
                      p_mpm_water_rate    NUMBER,
                      p_mpm_cond_rate    NUMBER,
                      p_avg_dh_pump_power NUMBER,
                      p_avg_dp_venturi  NUMBER,
                      p_pressure_zone   VARCHAR2 DEFAULT 'NORMAL',
                      p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lr_params EcDp_Well_Theoretical.PerfCurveParamRec;
BEGIN
   -- We should ideally just get rid of this function altogether and have every function that currently
   -- uses this to use the new getCurveStdRate instead

   IF NVL(p_pressure_zone,'NORMAL')!='NORMAL' THEN
      RAISE_APPLICATION_ERROR(-20000,'Only NORMAL pressure zone is supported in performance curve calculations');
      RETURN NULL;
   END IF;
   lr_params.choke_size        := p_choke_size;
   lr_params.wh_press          := p_wh_press;
   lr_params.wh_temp           := p_wh_temp;
   lr_params.bh_press          := p_bh_press;
   lr_params.annulus_press     := p_annulus_press;
   lr_params.wh_usc_press      := p_wh_usc_press;
   lr_params.wh_dsc_press      := p_wh_dsc_press;
   lr_params.bs_w              := p_bs_w;
   lr_params.dh_pump_rpm       := p_dh_pump_rpm;
   lr_params.gl_choke          := p_gl_choke;
   lr_params.gl_press          := p_gl_press;
   lr_params.gl_rate           := p_gl_rate;
   lr_params.gl_diff_press     := p_gl_diff_press;
   lr_params.avg_flow_mass     := p_avg_flow_mass;
   lr_params.phase_current     := p_phase_current;
   lr_params.ac_frequency      := p_ac_frequency;
   lr_params.intake_press      := p_intake_press;
   lr_params.mpm_oil_rate      := p_mpm_oil_rate;
   lr_params.mpm_gas_rate      := p_mpm_gas_rate;
   lr_params.mpm_water_rate    := p_mpm_water_rate;
   lr_params.mpm_cond_rate     := p_mpm_cond_rate;
   lr_params.avg_dh_pump_power := p_avg_dh_pump_power;
   lr_params.avg_dp_venturi    := p_avg_dp_venturi;

   RETURN EcDp_Well_Theoretical.getCurveStdRate(p_object_id,
                                                p_daytime,
                                                p_curve_purpose,
                                                p_phase,
                                                lr_params,
                                                p_calc_method);
END getCurveRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateDay
-- Description    : Returns theoretical oil volume for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdRateDay(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL ,
                          p_decline_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method            VARCHAR2(32);
  lv2_def_version            VARCHAR2(32);
  lv_oil_method              VARCHAR2(32);
  lv2_decline_flag           VARCHAR2(1);
  lr_well_event_row          WELL_EVENT%ROWTYPE;
  lr_pwel_result             PWEL_RESULT%ROWTYPE;
  lr_well_ref_value          WELL_REFERENCE_VALUE%ROWTYPE;
  lr_well_version            WELL_VERSION%ROWTYPE;
  lr_pwel_day_status         PWEL_DAY_STATUS%ROWTYPE;

  ln_ret_val                 NUMBER;
  ln_diluent_rate            NUMBER;
  ln_pump_speed_ratio        NUMBER;
  ln_test_pump_speed         NUMBER;
  ln_on_strm_ratio           NUMBER;
  ln_prev_test_no            NUMBER;
  ln_vol_rate                NUMBER;
  ln_prod_day_offset         NUMBER;
  ln_mass_day                NUMBER;
  ln_stdDensity              NUMBER;
  ln_closeVol                NUMBER;
  ln_openVol                 NUMBER;
  ln_pwel_on_strm            NUMBER;
  ln_sum                     NUMBER;
  ln_total_daily_emul_prod   NUMBER;
  ln_fraction_vol            NUMBER;
  ln_totalizer_frac          NUMBER;
  ln_total_fraction_vol      NUMBER;
  ln_prodwhp     	         NUMBER;
  ln_prodchoke	             NUMBER;
  ln_testchoke               NUMBER;
  ln_choke_frac              NUMBER;

  lb_first                   BOOLEAN;
  ld_end_daytime             DATE;
  ld_start_daytime           DATE;
  ld_eff_daytime             DATE;
  ld_next_eff_daytime        DATE;
  ld_prev_estimate           DATE;
  ld_next_estimate           DATE;
  ld_prev_test               DATE;
  ld_next_test               DATE;
  ld_from_date               DATE;

  ld_prod_day                DATE;
  ld_max_daytime             DATE;

  ld_last_event_prior_prod_day DATE;
  lb_multiple_event BOOLEAN     :=FALSE;

  ln_volume                       NUMBER;
  ln_duration                     NUMBER;
  ln_count_day                    NUMBER;
  ln_result_no                    NUMBER;
  ln_meter_corr                   NUMBER;

CURSOR c_well_event_single(p_object_id well.object_id%TYPE, p_start_daytime DATE, p_end_daytime DATE) IS
   SELECT *
   FROM well_event we
   WHERE we.event_type = 'WELL_EVENT_SINGLE'
   AND we.object_id = p_object_id
   AND we.daytime between p_start_daytime and p_end_daytime
   ORDER BY we.daytime ASC;

  --cursor to fetch all the tank's connect to a well(WELL_TANK)
 CURSOR c_tank_well(cp_object_id well.object_id%TYPE) IS
    SELECT *
    FROM tank_version
    WHERE tank_well = cp_object_id
    AND daytime <= p_daytime AND (end_date > p_daytime OR end_date IS NULL)
    AND (exclude_tank_well='N' OR exclude_tank_well IS NULL);

CURSOR c_well_period_totalizer_maxday(cp_class_name VARCHAR2, cp_daytime DATE) IS
   SELECT max(daytime) max_daytime
   FROM well_period_totalizer
   WHERE object_id = p_object_id
   AND class_name = cp_class_name
   AND (to_char(to_date(cp_daytime), 'yyyymm') between to_char(to_date(end_date), 'yyyymm') AND to_char(add_months(to_date(TRUNC(to_date(end_date), 'mm')), 1), 'yyyymm'))
   ORDER BY daytime ASC;

CURSOR c_well_period_totalizer (cp_date DATE) IS
SELECT *
  FROM well_period_totalizer
  WHERE object_id = p_object_id
  AND (daytime < cp_date+1 AND end_date > cp_date)
  ORDER BY daytime ASC;

CURSOR c_prev_well_test(cp_object_id well.object_id%TYPE, cp_result_no NUMBER) IS
SELECT * FROM PWEL_RESULT
	WHERE object_id = cp_object_id
	AND result_no <> cp_result_no
	AND DURATION = 24
	AND STATUS = 'ACCEPTED'
	AND VALID_FROM_DATE < ec_pwel_result.valid_from_date(cp_object_id, cp_result_no)
	ORDER BY VALID_FROM_DATE DESC;

BEGIN

  -- oil_calc_method
  lr_well_version :=ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
lv2_calc_method := Nvl(p_calc_method, lr_well_version.calc_method);

  IF (lv2_calc_method IS NOT NULL) THEN
    lv2_decline_flag := Nvl(p_decline_flag, NVL(lr_well_version.decline_flag, 'N'));
  lr_pwel_day_status := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);


    IF ( p_calc_method IS NULL AND NVL(lr_well_version.allow_theor_override, 'N') = 'Y' AND lr_pwel_day_status.override_theor_oil IS NOT NULL) THEN
      ln_ret_val := lr_pwel_day_status.override_theor_oil;
  ELSE

  IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
    ln_diluent_rate  := getDiluentStdRateDay(p_object_id, p_daytime, lr_well_version.diluent_method);
      ln_ret_val       := lr_pwel_day_status.avg_oil_rate - Nvl(ln_diluent_rate,0);    -- Subtract diluent contribution if present

  ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED_NET) THEN
      ln_ret_val := lr_pwel_day_status.avg_oil_rate;  -- Return the value without any adjustments

  ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
    -- Include trucked out volume
      ln_ret_val := NVL(lr_pwel_day_status.avg_oil_rate, 0) + NVL(Ecbp_Well_Theoretical.sumTruckedNetOilFromWell(p_object_id, p_daytime), 0);

  -- External Calculated Theoretical Rate 1
  ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_1) THEN
      ln_ret_val := lr_pwel_day_status.ext_oil_rate_1;
  -- External Calculated Theoretical Rate 2
  ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_2) THEN
      ln_ret_val := lr_pwel_day_status.ext_oil_rate_2;
  -- External Calculated Theoretical Rate 3
  ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_3) THEN
      ln_ret_val := lr_pwel_day_status.ext_oil_rate_3;
  -- External Calculated Theoretical Rate 4
  ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_4) THEN
      ln_ret_val := lr_pwel_day_status.ext_oil_rate_4;
  -- External Calculated Theoretical Rate 5
  ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_5) THEN
      ln_ret_val := lr_pwel_day_status.ext_oil_rate_5;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.LIQUID_MEASURED) THEN
    ln_diluent_rate  := getDiluentStdRateDay(p_object_id, p_daytime, lr_well_version.diluent_method);
    IF lr_well_version.bsw_vol_method = EcDp_Calc_Method.MEASURED THEN
      -- Subtract measured watercut and diluent contribution if present
        ln_ret_val   := lr_pwel_day_status.avg_liquid_rate_m3 * (1 - findWaterCutPct(p_object_id, p_daytime, lr_well_version.bsw_vol_method, NULL, 'PWEL_DAY_STATUS') / 100) - Nvl(ln_diluent_rate, 0);
    ELSE
      -- Subtract diluent and powerwater and produced water cut
        ln_ret_val   := (lr_pwel_day_status.avg_liquid_rate_m3 - Nvl(ln_diluent_rate,0) - Nvl(lr_pwel_day_status.avg_powerwater_rate,0)) * (1 - findWaterCutPct(p_object_id,p_daytime, lr_well_version.bsw_vol_method, NULL, 'PWEL_DAY_STATUS') / 100);
    END IF;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
    -- we also need to add new parameter to EcDp_Well.getPwelOnStreamHrs to retreive the method. This new parameter must be default NULL.
    ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

    IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;

      ln_ret_val := EcDp_Well_Estimate.getOilStdRate(p_object_id, ld_start_daytime) * ln_on_strm_ratio;

    ELSIF ln_on_strm_ratio = 0 THEN
      ln_ret_val := 0;

    ELSE
      ln_ret_val := NULL;
    END IF;

    --calculate decline
    IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
      lr_pwel_result := Ecdp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
        ln_ret_val := declineResult(p_object_id, p_daytime, lr_pwel_result.valid_from_date, 'OIL', ln_ret_val);
    END IF;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_PUMP_SPEED) THEN

    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
    ld_start_daytime := p_daytime + ln_prod_day_offset;


        ln_test_pump_speed := EcDp_Well_Estimate.getLastAvgDhPumpSpeed(p_object_id, ld_start_daytime);

      IF ln_test_pump_speed IS NOT NULL AND ln_test_pump_speed <> 0 THEN
        ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

        IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
            ln_pump_speed_ratio := lr_pwel_day_status.avg_dh_pump_speed / ln_test_pump_speed;
            ln_ret_val := EcDp_Well_Estimate.getOilStdRate(p_object_id, ld_start_daytime) * ln_on_strm_ratio * ln_pump_speed_ratio;

        ELSIF ln_on_strm_ratio = 0 THEN
          ln_ret_val := 0;

        ELSE
          ln_ret_val := NULL;
        END IF;

      ELSE -- Not enough info to calculate, no assumptions about pump speed
        ln_ret_val := NULL;

      END IF;


    --calculate decline
    IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
      lr_pwel_result := Ecdp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
        ln_ret_val := declineResult(p_object_id, p_daytime, lr_pwel_result.valid_from_date, 'OIL', ln_ret_val);
    END IF;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN

    ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

    IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
      ln_ret_val := getCurveRate(p_object_id,
                                 p_daytime,
                                 EcDp_Phase.OIL,
                                 EcDp_Curve_Purpose.PRODUCTION,
                                   lr_pwel_day_status.avg_choke_size,
                                   lr_pwel_day_status.avg_wh_press,
                                   lr_pwel_day_status.avg_wh_temp,
                                   lr_pwel_day_status.avg_bh_press,
                                   lr_pwel_day_status.annulus_press,
                                   lr_pwel_day_status.avg_wh_usc_press,
                                   lr_pwel_day_status.avg_wh_dsc_press,
                                   lr_pwel_day_status.bs_w,
                                   lr_pwel_day_status.avg_dh_pump_speed,
                                   lr_pwel_day_status.avg_gl_choke,
                                   lr_pwel_day_status.avg_gl_press,
                                 getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method),
                                 lr_pwel_day_status.avg_gl_diff_press,
                                 lr_pwel_day_status.avg_flow_mass,
                                 lr_pwel_day_status.phase_current,
                                 lr_pwel_day_status.ac_frequency,
                                 lr_pwel_day_status.intake_press,
                                  lr_pwel_day_status.avg_mpm_oil_rate,
                                  lr_pwel_day_status.avg_mpm_gas_rate,
                                 lr_pwel_day_status.avg_mpm_water_rate,
                                 lr_pwel_day_status.avg_mpm_cond_rate,
                                 lr_pwel_day_status.avg_dh_pump_power,
                                 lr_pwel_day_status.avg_dp_venturi,
                                 NULL,
                                 lv2_calc_method);

      ln_ret_val := ln_ret_val * ln_on_strm_ratio;

    ELSIF ln_on_strm_ratio = 0 THEN
      ln_ret_val := 0;

    ELSE
      ln_ret_val := NULL;
    END IF;

    --calculate decline
    IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
      ld_from_date := ec_performance_curve.daytime(Ecdp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime,Ecdp_Curve_Purpose.PRODUCTION, EcDp_Phase.OIL,'CURVE'));
      ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'OIL', ln_ret_val);
    END IF;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN

    ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

    IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
      ln_ret_val := getCurveRate(p_object_id,
                                 p_daytime,
                                 EcDp_Phase.LIQUID,
                                 EcDp_Curve_Purpose.PRODUCTION,
                                 lr_pwel_day_status.avg_choke_size,
                                 lr_pwel_day_status.avg_wh_press,
                                 lr_pwel_day_status.avg_wh_temp,
                                 lr_pwel_day_status.avg_bh_press,
                                 lr_pwel_day_status.annulus_press,
                                 lr_pwel_day_status.avg_wh_usc_press,
                                 lr_pwel_day_status.avg_wh_dsc_press,
                                 lr_pwel_day_status.bs_w,
                                 lr_pwel_day_status.avg_dh_pump_speed,
                                 lr_pwel_day_status.avg_gl_choke,
                                 lr_pwel_day_status.avg_gl_press,
                                 getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method),
                                 lr_pwel_day_status.avg_gl_diff_press,
                                 lr_pwel_day_status.avg_flow_mass,
                                 lr_pwel_day_status.phase_current,
                                 lr_pwel_day_status.ac_frequency,
                                 lr_pwel_day_status.intake_press,
                                 lr_pwel_day_status.avg_mpm_oil_rate,
                                 lr_pwel_day_status.avg_mpm_gas_rate,
                                 lr_pwel_day_status.avg_mpm_water_rate,
                                 lr_pwel_day_status.avg_mpm_cond_rate,
                                 lr_pwel_day_status.avg_dh_pump_power,
                                 lr_pwel_day_status.avg_dp_venturi,
                                 NULL,
                                 lv2_calc_method);


     ln_ret_val :=  ln_ret_val *  ln_on_strm_ratio ;

    ELSIF ln_on_strm_ratio = 0 THEN
      ln_ret_val := 0;

    ELSE
      ln_ret_val := NULL;
    END IF;

    IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
      ld_from_date := ec_performance_curve.daytime(Ecdp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime,Ecdp_Curve_Purpose.PRODUCTION, EcDp_Phase.LIQUID,EcDp_Calc_Method.CURVE_LIQUID));
      ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, EcDp_Phase.LIQUID, ln_ret_val);
    END IF;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.POTENTIAL_DEFERED) THEN

    lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
    ld_start_daytime := p_daytime + ln_prod_day_offset;
    ld_end_daytime := ld_start_daytime + 1;

    IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
      IF ec_pwel_period_status.active_well_status(p_object_id,ld_start_daytime,'EVENT','<=') = 'CLOSED_LT' THEN
        ln_ret_val := 0;
      ELSE
        ln_ret_val := ecbp_well_potential.findOilProductionPotential(p_object_id, p_daytime, lr_well_version.potential_method, p_decline_flag)
                      - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'OIL');
      END IF;
    ELSIF (lv2_def_version = 'PD.0020') THEN
      -- get on strm from active status, its used several times here.
         ln_pwel_on_strm := ecdp_well.getPwelPeriodOnStrmFromStatus(p_object_id,ld_start_daytime,ld_end_daytime);
         -- if well has active_well_status<>OPEN for the whole day, then simply return 0 because there cannot be any deferment when well is not active.
         IF ln_pwel_on_strm = 0 THEN
            ln_ret_val := 0;
         ELSE
            ln_ret_val := (ecbp_well_potential.findOilProductionPotential(p_object_id, p_daytime, lr_well_version.potential_method,p_decline_flag) *
                           ln_pwel_on_strm /
                           Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime)
                          ) - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'OIL');
            -- since theoretical is calcualted as ("potential" * "open faction") - "deferred" we can easily get rounding problems when the well is closed or deferred the whole day.
            -- therefore, we can apply rounding to the result if the result is very close to zero.
            IF (ln_ret_val < 0.001 AND ln_ret_val > -0.001) THEN
               ln_ret_val := 0;
            END IF;
         END IF;
      ELSE -- undefined
        ln_ret_val := NULL;
      END IF;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
    ld_start_daytime := p_daytime + ln_prod_day_offset;
    ld_end_daytime := ld_start_daytime + 1;
    lb_first := TRUE;
    ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
    ld_next_eff_daytime := ld_start_daytime;
    ln_ret_val := 0;

    WHILE ld_next_eff_daytime < ld_end_daytime LOOP

      ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
      ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

      ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
      ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
      ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

      IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
        ln_ret_val := NULL;
        EXIT;
      ELSE
        ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
      END IF;

      -- find start of next period
      ld_next_eff_daytime := LEAST(
                                   LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                   ld_end_daytime);

      -- find well on stream fraction (part of current period)
      ln_on_strm_ratio  := EcDp_Well.getPwelPeriodOnStrmFromStatus(p_object_id,GREATEST(ld_eff_daytime,ld_start_daytime),ld_next_eff_daytime)/24;

      IF ln_on_strm_ratio > 0 THEN

        IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
          lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
          ln_vol_rate := lr_pwel_result.net_oil_rate_adj;

        ELSE -- Use well production estimate for this period
          lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
          ln_vol_rate := Nvl(lr_well_event_row.net_oil_rate,lr_well_event_row.grs_oil_rate*(1-lr_well_event_row.bs_w));

        END IF;

        IF lb_first THEN
          ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
          lb_first := FALSE;
        ELSE
          ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
        END IF;
      ELSE
        ln_ret_val := ln_ret_val;
      END IF;

      ld_eff_daytime := ld_next_eff_daytime;

    END LOOP;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_EVENT_THEOR AND lr_well_version.CALC_EVENT_METHOD = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      SELECT MAX(we.daytime) INTO ld_last_event_prior_prod_day
      FROM well_event we
      WHERE we.event_type = 'WELL_EVENT_SINGLE'
      AND we.object_id = p_object_id
      AND we.event_day = p_daytime
      ORDER BY we.daytime DESC;


       IF (ld_last_event_prior_prod_day IS NOT NULL) THEN
            lb_multiple_event:=TRUE;
       END IF;

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,NVL(ld_last_event_prior_prod_day,p_daytime))/24;
         ld_start_daytime := TRUNC(NVL(ld_last_event_prior_prod_day,p_daytime)) + ln_prod_day_offset;
         ld_end_daytime := ld_start_daytime + 1;
         ld_eff_daytime := ld_start_daytime;
         lb_first := TRUE;
         ln_ret_val := 0;

         WHILE ld_eff_daytime < ld_end_daytime LOOP
            ld_eff_daytime := NVL(EcDp_Well_Event.getLastWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_start_daytime);
            ld_eff_daytime := GREATEST(ld_eff_daytime, ld_start_daytime);

            IF(lb_multiple_event) THEN
             ln_on_strm_ratio  := EcDp_Well.getPwelEventOnStreamsHrs(p_object_id,ld_eff_daytime)/24;
            ELSE
             ln_on_strm_ratio  := EcDp_Well.getPwelOnStreamHrs(p_object_id,ld_eff_daytime)/24;
            END IF;

             IF ln_on_strm_ratio > 0 THEN
                  lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'WELL_EVENT_SINGLE',ld_eff_daytime);
                  ln_vol_rate := NVL(EcBp_Well_Theoretical.getOilStdRateEvent(p_object_id, ld_eff_daytime),lr_well_event_row.grs_oil_rate*(1-lr_well_event_row.bs_w));

               IF lb_first THEN
                 ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
                 lb_first := FALSE;
               ELSE
                 ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
               END IF;

             ELSE
                 ln_ret_val := ln_ret_val;
             END IF;

             ld_eff_daytime := NVL(EcDp_Well_Event.getNextWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_end_daytime);

          END LOOP;

    --Quadratic Curve methods
  ELSIF ( lv2_calc_method IN ( EcDp_Calc_Method.CHOKE_QUADRATIC_CURVE,EcDp_Calc_Method.CHOKE_QUADRATIC_CURVE_CORR )) THEN

		   lr_pwel_day_status := Ec_Pwel_Day_Status.row_by_pk(p_object_id, p_daytime);
		   ln_prodchoke       := EcBp_Well_Choke.convertToMilliMeter(p_object_id, p_daytime,lr_pwel_day_status.avg_choke_size);
                   ln_prodwhp         := lr_pwel_day_status.avg_wh_press;
		   ln_on_strm_ratio   := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

		   lr_pwel_result  := EcDp_Performance_Test.getLastValidWellResult(p_object_id,p_daytime); -- get valid test result record for well
		   ln_testchoke    := EcBp_Well_Choke.convertToMilliMeter(p_object_id, p_daytime,lr_pwel_result.choke_size); --convert the valid result choke to mm

			ln_ret_val := EcBp_Mathlib.quadraticCurve(ln_prodwhp, ln_prodchoke, lr_pwel_result.wh_press, ln_testchoke, lr_pwel_result.net_oil_rate_adj);

			IF ( lv2_calc_method = EcDp_Calc_Method.CHOKE_QUADRATIC_CURVE_CORR ) THEN
			 ln_choke_frac := (ln_prodchoke / ln_testchoke)**2;  -- Do not use curve when ratio between chokes goes beyond [0.9;1.1]

				IF (ln_choke_frac <= 0.9 OR ln_choke_frac >= 1.1)  THEN
					ln_ret_val := lr_pwel_result.net_oil_rate_adj;
				END IF;
			END IF;
			ln_ret_val := ln_ret_val * ln_on_strm_ratio;


      --user exit
  ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_EVENT_THEOR AND lr_well_version.CALC_EVENT_METHOD = EcDp_Calc_Method.USER_EXIT) THEN

      SELECT MAX(we.daytime) INTO ld_last_event_prior_prod_day
      FROM well_event we
      WHERE we.event_type = 'WELL_EVENT_SINGLE'
      AND we.object_id = p_object_id
      AND we.event_day = p_daytime
      ORDER BY we.daytime DESC;


       IF (ld_last_event_prior_prod_day IS NOT NULL) THEN
            lb_multiple_event:=TRUE;
       END IF;

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,NVL(ld_last_event_prior_prod_day,p_daytime))/24;
         ld_start_daytime := TRUNC(NVL(ld_last_event_prior_prod_day,p_daytime)) + ln_prod_day_offset;
         ld_end_daytime := ld_start_daytime + 1;
         ld_eff_daytime := ld_start_daytime;
         lb_first := TRUE;
         ln_ret_val := 0;

         WHILE ld_eff_daytime < ld_end_daytime LOOP
            ld_eff_daytime := NVL(EcDp_Well_Event.getLastWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_start_daytime);
            ld_eff_daytime := GREATEST(ld_eff_daytime, ld_start_daytime);

            IF(lb_multiple_event) THEN
             ln_on_strm_ratio  := EcDp_Well.getPwelEventOnStreamsHrs(p_object_id,ld_eff_daytime)/24;
            ELSE
             ln_on_strm_ratio  := EcDp_Well.getPwelOnStreamHrs(p_object_id,ld_eff_daytime)/24;
            END IF;

             IF ln_on_strm_ratio > 0 THEN
                  lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'WELL_EVENT_SINGLE',ld_eff_daytime);
                  ln_vol_rate := NVL(Ue_Well_Theoretical.getOilStdRateEvent(p_object_id, ld_eff_daytime),lr_well_event_row.grs_oil_rate*(1-lr_well_event_row.bs_w));

               IF lb_first THEN
                 ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
                 lb_first := FALSE;
               ELSE
                 ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
               END IF;

             ELSE
                 ln_ret_val := ln_ret_val;
             END IF;

             ld_eff_daytime := NVL(EcDp_Well_Event.getNextWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_end_daytime);

          END LOOP;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_CORR) THEN

      lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id,p_daytime);
      ln_meter_corr := ec_pwel_result.meter1_factor_hcliq(p_object_id, lr_pwel_result.result_no);
      ln_ret_val := ln_meter_corr * ec_pwel_day_status.avg_mpm_oil_rate(p_object_id, p_daytime);

  ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_CORR)  THEN

      lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id,p_daytime);
      ln_meter_corr := ec_pwel_result.meter2_factor_hcliq(p_object_id, lr_pwel_result.result_no);
      ln_ret_val := ln_meter_corr * ec_pwel_day_status.avg_mpm2_oil_rate(p_object_id, p_daytime);

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Well_Theoretical.getOilStdRateDay(
                      p_object_id,
                      p_daytime);

  ELSIF (lv2_calc_method IN (EcDp_Calc_Method.TOTALIZER_EVENT, EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE)) THEN

  --   lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
   ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;
   ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime)/24);
   ld_start_daytime := p_daytime + ln_prod_day_offset;

   IF ln_on_strm_ratio > 0 THEN
     ln_fraction_vol := 0;
     ln_totalizer_frac := 0;
     ln_total_fraction_vol := 0;


     IF lv2_calc_method = EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE THEN
       FOR curRec IN c_well_period_totalizer_maxday('PWEL_TOTALIZER_LIQ', ld_start_daytime) LOOP
         ld_max_daytime := curRec.Max_daytime;
       END LOOP;
       ld_start_daytime := ld_max_daytime;
     END IF ;

     -- loop to get the fraction volume based on the totalizer daily rate
     FOR cur_totalizer IN c_well_period_totalizer(ld_start_daytime) LOOP
       ln_totalizer_frac := least((cur_totalizer.end_date - ln_prod_day_offset),ld_start_daytime+1) - greatest((cur_totalizer.daytime - ln_prod_day_offset), ld_start_daytime);
       ln_fraction_vol := ln_fraction_vol + (ln_totalizer_frac * getProducedStdDailyRate(p_object_id, 'PWEL_TOTALIZER_LIQ', cur_totalizer.daytime));
     END LOOP;
     IF ln_fraction_vol > 0 THEN
       ln_ret_val :=  ln_fraction_vol * ln_on_strm_ratio;
     ELSE
       ln_ret_val := 0;
     END IF;

   ELSIF ln_on_strm_ratio = 0 THEN
     ln_ret_val := 0;

   ELSE
     ln_ret_val := NULL;
   END IF;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_SUB_DAY_THEOR) THEN
    ln_diluent_rate   := getDiluentStdRateDay(p_object_id, p_daytime, lr_well_version.diluent_method);
      ln_ret_val        := lr_pwel_day_status.sub_day_theor_oil - Nvl(ln_diluent_rate,0);

    IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
      ld_from_date := ec_performance_curve.daytime(Ecdp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, Ecdp_Curve_Purpose.PRODUCTION, EcDp_Phase.OIL));
      ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'OIL', ln_ret_val);
    END IF;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.WPI_RP_BHP) THEN
    --added for adjust on_time
    ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

    IF ln_on_strm_ratio > 0 THEN
      lr_well_ref_value := ec_well_reference_value.row_by_pk(p_object_id, p_daytime,'<=');
        ln_ret_val := lr_well_ref_value.well_perf_index * (lr_well_ref_value.resv_press - lr_pwel_day_status.avg_bh_press) ; /* WPI * (RP - BHP) */
      ln_ret_val := ln_ret_val * ln_on_strm_ratio;

    ELSIF ln_on_strm_ratio = 0 THEN
      ln_ret_val := 0;

    ELSE
      ln_ret_val := NULL;
    END IF;

  ELSIF(lv2_calc_method = EcDp_Calc_Method.MASS_DIV_DENSITY) THEN
    ln_mass_day := findOilMassDay(p_object_id,p_daytime,p_calc_method);

      lv_oil_method := Nvl(p_calc_method,lr_well_version.calc_method_mass);
    IF (lv_oil_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
      RAISE_APPLICATION_ERROR(-20604,'A loop was detected when trying to calculate Mass Day. Check Configuration.');
    END IF;

    IF ln_mass_day <> 0 THEN
      ln_stdDensity := findOilStdDensity(p_object_id,p_daytime,p_calc_method);

      IF ln_stdDensity > 0 THEN
        ln_ret_val := ln_mass_day / ln_stdDensity;
      ELSE
        ln_ret_val := NULL;
      END IF;

    ELSIF ln_mass_day = 0 THEN
      ln_ret_val := 0;
    ELSE
      ln_ret_val := NULL;

    END IF;

  ELSIF(lv2_calc_method = EcDp_Calc_Method.TANK_WELL) THEN -- method to calculate from the split of the tank and then to the well

        lb_first := TRUE;
        FOR mycur in c_tank_well(p_object_id) LOOP
           ln_closeVol := NVL(EcBp_Tank.findClosingNetVol(mycur.object_id, 'DAY_CLOSING', p_daytime),0);
           ln_openVol  := NVL(EcBp_Tank.findOpeningNetVol(mycur.object_id, 'DAY_CLOSING', p_daytime),0);
           IF lb_first THEN
             ln_ret_val := ln_closeVol - ln_openVol;
             lb_first := FALSE;
           ELSE
             ln_ret_val := ln_ret_val + ln_closeVol - ln_openVol;
           END IF;
        END LOOP;
        ln_ret_val := NVL(ln_ret_val,0) + NVL(Ecbp_Well_Theoretical.sumTruckedNetOilFromWell(p_object_id, p_daytime),0);

  ELSIF(lv2_calc_method = EcDp_Calc_Method.WELL_TANK) THEN -- method to calculate from split at the well and then applied to tank

     lb_first:= TRUE;
     FOR mycurTM IN c_tank_well(p_object_id) LOOP
        ln_closeVol := NVL(EcBp_Tank.findClosingGrsVol(mycurTM.object_id, 'DAY_CLOSING', p_daytime),0);
        ln_openVol  := NVL(EcBp_Tank.findOpeningGrsVol(mycurTM.object_id, 'DAY_CLOSING', p_daytime),0);
        IF lb_first THEN
           ln_sum:= ln_closeVol - ln_openVol;
           lb_first:= FALSE;
        ELSE
           ln_sum:= ln_sum + ln_closeVol - ln_openVol;
        END IF;
     END LOOP;
     -- get total daily emulsion production
     ln_total_daily_emul_prod := (NVL(ln_sum,0) + NVL(Ecbp_Well_Theoretical.sumTruckedNetOilFromWell(p_object_id, p_daytime),0) + NVL(Ecbp_Well_Theoretical.sumTruckedWaterFromWell(p_object_id, p_daytime),0));
     ln_ret_val := ln_total_daily_emul_prod - getWatStdRateDay(p_object_id, p_daytime);

  ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM) THEN
    ln_diluent_rate := getDiluentStdRateDay(p_object_id, p_daytime, lr_well_version.diluent_method);
      ln_ret_val := lr_pwel_day_status.avg_mpm_oil_rate - Nvl(ln_diluent_rate,0);    --Subtract diluent contribution if present
  ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
      ln_ret_val := lr_pwel_day_status.avg_mpm_oil_rate;    --Return MPM reading without subtracting diluent
  ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2) THEN
    ln_diluent_rate := getDiluentStdRateDay(p_object_id, p_daytime, lr_well_version.diluent_method);
      ln_ret_val := lr_pwel_day_status.avg_mpm2_oil_rate - Nvl(ln_diluent_rate,0);    --Subtract diluent contribution if present

  ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_NET) THEN
      ln_ret_val := lr_pwel_day_status.avg_mpm2_oil_rate;    --Return MPM2 reading without subtracting diluent

-- ECPD-29803 Logic for consecutive well test

  ELSIF (lv2_calc_method = EcDp_Calc_Method.CONSEC_WELL_TEST) THEN

    ln_result_no := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
    ln_count_day := 1;

    SELECT NVL(NET_OIL_RATE_ADJ, 0), NVL(DURATION, 0) INTO ln_volume, ln_duration
    FROM PWEL_RESULT
    WHERE RESULT_NO = ln_result_no;

    FOR cur_well_test in c_prev_well_test(p_object_id, ln_result_no) LOOP
      IF TRUNC(cur_well_test.valid_from_date) = TRUNC(ec_pwel_result.valid_from_date(p_object_id, ln_result_no) - ln_count_day) THEN
        ln_count_day := ln_count_day + 1;
        ln_volume := ln_volume + cur_well_test.net_oil_rate_adj;
        ln_duration := ln_duration + cur_well_test.duration;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    ln_ret_val := (ln_volume/ln_duration) * NVL(ec_pwel_day_status.on_stream_hrs(p_object_id, p_daytime, '<='), EcDp_Well.getPwelOnStreamHrs(p_object_id, p_daytime));

  ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_PRIORITIZED) THEN

    ln_ret_val := EcBp_HCM_VFM.getOilStdRateDay(p_object_id, p_daytime);

  ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM) THEN

    ln_diluent_rate := getDiluentStdRateDay(p_object_id, p_daytime, lr_well_version.diluent_method);
    ln_ret_val := lr_pwel_day_status.avg_vfm_oil_rate - Nvl(ln_diluent_rate,0);

  ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN

    ln_ret_val := lr_pwel_day_status.avg_vfm_oil_rate;

  END IF;

  END IF;
  ELSE -- if GP2, get the oil from condensate
       IF (lr_well_version.well_type = Ecdp_Well_Type.GAS_PRODUCER_2) THEN
        ln_ret_val := getCondStdRateDay(p_object_id, p_daytime);
     ELSE
        ln_ret_val := NULL;
     END IF;
  END IF; -- End check if lv2_calc_method is not null


  RETURN ln_ret_val;

END getOilStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateDay
-- Description    : Returns theoretical gas volume for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdRateDay(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL,
                          p_decline_flag VARCHAR2 DEFAULT NULL,
                          p_deduct_co2_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method       VARCHAR2(32);
   lv2_def_version       VARCHAR2(32);
   lv_gas_method            VARCHAR2(32);
   lv2_decline_flag      VARCHAR2(1);
   lv2_override_theor_flag     VARCHAR2(1);
   lv2_ffv_flag          VARCHAR2(1);

   lr_result_req         pwel_result%ROWTYPE;
   lr_well_event_row     WELL_EVENT%ROWTYPE;
   lr_pwel_result       PWEL_RESULT%ROWTYPE;
   lr_well_ref_value     WELL_REFERENCE_VALUE%ROWTYPE;
   lr_well_version       WELL_VERSION%ROWTYPE;
   lr_pwel_day_status         PWEL_DAY_STATUS%ROWTYPE;

   ln_oil_rate           NUMBER;
   ln_flow_rate          NUMBER;
   ln_ret_val            NUMBER;
   ln_gor                NUMBER;
   ln_gas_lift_rate      NUMBER;
   ln_on_stream_frac     NUMBER;
   ln_curve_value        NUMBER;
   ln_pump_speed_ratio   NUMBER;
   ln_test_pump_speed    NUMBER;
   ln_on_strm_ratio      NUMBER;
   ln_prev_test_no       NUMBER;
   ln_vol_rate           NUMBER;
   ln_prod_day_offset    NUMBER;
   ln_fraction_vol       NUMBER;
   ln_totalizer_frac     NUMBER;
   ln_total_fraction_vol NUMBER;
   ln_mass_day           NUMBER;
   ln_stdDensity         NUMBER;
   ln_pwel_on_strm       NUMBER;
   ln_dry_gas            NUMBER;
   ln_wet_gas            NUMBER;
   ln_meas_gas           NUMBER;
   ln_wet_meas_gas       NUMBER;

   ln_meter_factor       NUMBER;

   lb_first              BOOLEAN;

   ld_end_daytime        DATE;
   ld_start_daytime      DATE;
   ld_eff_daytime        DATE;
   ld_next_eff_daytime   DATE;
   ld_prev_estimate      DATE;
   ld_next_estimate      DATE;
   ld_prev_test          DATE;
   ld_next_test          DATE;
   ld_from_date          DATE;

   ld_prod_day           DATE;
   ld_max_daytime        DATE;
   ln_wet_dry_gas_ratio  NUMBER;
   ln_dry_wet_gas_ratio  NUMBER;

   ld_last_event_prior_prod_day DATE;
   lb_multiple_event BOOLEAN     :=FALSE;

   ln_volume                       NUMBER;
   ln_duration                     NUMBER;
   ln_count_day                    NUMBER;
   ln_result_no                    NUMBER;
   ln_meter_corr                   NUMBER;

CURSOR c_well_event_single(p_object_id well.object_id%TYPE, p_start_daytime DATE, p_end_daytime DATE) IS
SELECT *
  FROM well_event we
  WHERE we.event_type = 'WELL_EVENT_SINGLE'
  AND we.object_id = p_object_id
  AND we.daytime between p_start_daytime and p_end_daytime
  ORDER BY we.daytime ASC;

CURSOR c_well_period_totalizer_maxday(cp_class_name VARCHAR2, cp_daytime DATE) IS
   SELECT max(daytime) max_daytime
   FROM well_period_totalizer
   WHERE object_id = p_object_id
   AND class_name = cp_class_name
   AND (to_char(to_date(cp_daytime), 'yyyymm') between to_char(to_date(end_date), 'yyyymm') AND to_char(add_months(to_date(TRUNC(to_date(end_date), 'mm')), 1), 'yyyymm'))
   ORDER BY daytime ASC;


CURSOR c_well_period_totalizer (cp_date DATE) IS
SELECT *
  FROM well_period_totalizer
  WHERE object_id = p_object_id
  AND (daytime < cp_date+1 AND end_date > cp_date)
  ORDER BY daytime ASC;

CURSOR c_gas_event (cp_object_id well.object_id%TYPE, cp_fromday DATE) IS
SELECT *
  FROM well_swing_connection w
 WHERE w.object_id = cp_object_id
   AND w.event_day = cp_fromday
   AND w.asset_id = w.asset_id
   ORDER BY w.daytime ASC;

CURSOR c_prev_well_test(cp_object_id well.object_id%TYPE, cp_result_no NUMBER) IS
SELECT * FROM PWEL_RESULT
	WHERE object_id = cp_object_id
	AND result_no <> cp_result_no
	AND DURATION = 24
	AND STATUS = 'ACCEPTED'
	AND VALID_FROM_DATE < ec_pwel_result.valid_from_date(cp_object_id, cp_result_no)
	ORDER BY VALID_FROM_DATE DESC;

BEGIN
-- gas_calc_method
  lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_calc_method := Nvl(p_calc_method, lr_well_version.calc_gas_method);

  IF (lv2_calc_method IS NOT NULL) THEN
    lv2_decline_flag := Nvl(p_decline_flag, NVL(lr_well_version.decline_flag, 'N'));
  lr_pwel_day_status := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);

  lv2_ffv_flag := NVL(lr_well_version.ffv_flag, 'N');

    IF ( p_calc_method IS NULL AND  NVL(lr_well_version.allow_theor_override, 'N') = 'Y' AND lr_pwel_day_status.override_theor_gas IS NOT NULL) THEN
      ln_ret_val := lr_pwel_day_status.override_theor_gas;
  ELSE

   IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
      ln_gas_lift_rate := getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method);
        ln_ret_val       := lr_pwel_day_status.avg_gas_rate - Nvl(ln_gas_lift_rate,0);    -- Subtract gas lift contribution if present

      -- ffv calculation
      IF lv2_ffv_flag = 'Y' THEN
        ln_ret_val := ln_ret_val + sumFuelFlareVent(p_object_id, p_daytime, 'SUM_USM');
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED_NET) THEN
        ln_ret_val       := lr_pwel_day_status.avg_gas_rate;  -- Return the value without any adjustments

      -- ffv calculation
      IF lv2_ffv_flag = 'Y' THEN
        ln_ret_val := ln_ret_val + sumFuelFlareVent(p_object_id, p_daytime, 'SUM_USM');
      END IF;

   -- External Calculated Theoretical Rate 1
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_1) THEN
       ln_ret_val := lr_pwel_day_status.ext_gas_rate_1;
   -- External Calculated Theoretical Rate 2
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_2) THEN
       ln_ret_val := lr_pwel_day_status.ext_gas_rate_2;
   -- External Calculated Theoretical Rate 3
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_3) THEN
       ln_ret_val := lr_pwel_day_status.ext_gas_rate_3;
   -- External Calculated Theoretical Rate 4
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_4) THEN
       ln_ret_val := lr_pwel_day_status.ext_gas_rate_4;
   --External Calculated Theoretical Rate 5
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_5) THEN
       ln_ret_val := lr_pwel_day_status.ext_gas_rate_5;


   ELSIF (lv2_calc_method = EcDp_Calc_Method.OIL_GOR) THEN
      ln_oil_rate := getOilStdRateDay(p_object_id, p_daytime, NULL, p_decline_flag);
      IF ln_oil_rate > 0 THEN     -- Only worth getting GOR if Oil is > 0
         ln_ret_val := ln_oil_rate * findGasOilRatio(p_object_id, p_daytime, null, null, 'PWEL_DAY_STATUS');
      ELSIF ln_oil_rate = 0 THEN     -- if oil rate = 0, then gas is also zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := null;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_on_stream_frac := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

      IF ln_on_stream_frac > 0 THEN -- Only worth doing calculation when the well is up

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         ln_ret_val := EcDp_Well_Estimate.getGasStdRate(p_object_id, ld_start_daytime);
         ln_ret_val := ln_ret_val * ln_on_stream_frac;

      ELSIF ln_on_stream_frac = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

      -- decline calculations
      IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
         lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
           ln_ret_val := declineResult(p_object_id, p_daytime, lr_pwel_result.valid_from_date, 'GAS', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_PUMP_SPEED) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;


         ln_test_pump_speed := EcDp_Well_Estimate.getLastAvgDhPumpSpeed(p_object_id,
                                                                        ld_start_daytime);

         IF ln_test_pump_speed IS NOT NULL AND ln_test_pump_speed <> 0 THEN

           ln_on_stream_frac := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

           IF ln_on_stream_frac > 0 THEN -- Only worth doing calculation when the well is up
                ln_pump_speed_ratio := lr_pwel_day_status.avg_dh_pump_speed / ln_test_pump_speed;
              ln_ret_val := EcDp_Well_Estimate.getGasStdRate(p_object_id, ld_start_daytime);

              ln_ret_val := ln_ret_val * ln_on_stream_frac * ln_pump_speed_ratio;

           ELSIF ln_on_stream_frac = 0 THEN
             ln_ret_val := 0;

           ELSE
             ln_ret_val := NULL;
           END IF;


        ELSE -- Not enough info to calculate, no assumptions about pump speed
           ln_ret_val := NULL;

         END IF;


      -- decline calculations
    IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
         lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
           ln_ret_val := declineResult(p_object_id, p_daytime, lr_pwel_result.valid_from_date, 'GAS', ln_ret_val);
    END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_GAS) THEN

      ln_on_stream_frac := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

      IF ln_on_stream_frac > 0 THEN -- Only worth doing calculation when the well is up

            ln_curve_value := getCurveRate(p_object_id,
                                           p_daytime,
                                           EcDp_Phase.GAS,
                                           EcDp_Curve_Purpose.PRODUCTION,
                                           lr_pwel_day_status.avg_choke_size,
                                           lr_pwel_day_status.avg_wh_press,
                                           lr_pwel_day_status.avg_wh_temp,
                                           lr_pwel_day_status.avg_bh_press,
                                           lr_pwel_day_status.annulus_press,
                                           lr_pwel_day_status.avg_wh_usc_press,
                                           lr_pwel_day_status.avg_wh_dsc_press,
                                           lr_pwel_day_status.bs_w,
                                           lr_pwel_day_status.avg_dh_pump_speed,
                                           lr_pwel_day_status.avg_gl_choke,
                                           lr_pwel_day_status.avg_gl_press,
                                           getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method),
                                           lr_pwel_day_status.avg_gl_diff_press,
                                           lr_pwel_day_status.avg_flow_mass,
                                           lr_pwel_day_status.phase_current,
                                           lr_pwel_day_status.ac_frequency,
                                           lr_pwel_day_status.intake_press,
                                           lr_pwel_day_status.avg_mpm_oil_rate,
                                           lr_pwel_day_status.avg_mpm_gas_rate,
                                           lr_pwel_day_status.avg_mpm_water_rate,
                                           lr_pwel_day_status.avg_mpm_cond_rate,
                                           lr_pwel_day_status.avg_dh_pump_power,
                                           lr_pwel_day_status.avg_dp_venturi,
                                           NULL,
                                           lv2_calc_method);

            ln_ret_val := ln_curve_value * ln_on_stream_frac;

      ELSIF ln_on_stream_frac = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

      --calculate decline
      IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.GAS,'CURVE_GAS'));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'GAS', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.POTENTIAL_DEFERED) THEN

      lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ld_end_daytime := ld_start_daytime + 1;

      IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
         IF ec_pwel_period_status.active_well_status(p_object_id,ld_start_daytime,'EVENT','<=') = 'CLOSED_LT' THEN
            ln_ret_val := 0;
         ELSE
         ln_ret_val := ecbp_well_potential.findGasProductionPotential(p_object_id, p_daytime, lr_well_version.potential_method,p_decline_flag)
            - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'GAS');
         END IF;
      ELSIF (lv2_def_version = 'PD.0020') THEN
         -- get on strm from active status, its used several times here.
         ln_pwel_on_strm := ecdp_well.getPwelPeriodOnStrmFromStatus(p_object_id,ld_start_daytime,ld_end_daytime);
         -- if well has active_well_status<>OPEN for the whole day, then simply return 0 because there cannot be any deferment when well is not active.
         IF ln_pwel_on_strm = 0 THEN
            ln_ret_val := 0;
         ELSE
            ln_ret_val := (ecbp_well_potential.findGasProductionPotential(p_object_id, p_daytime, lr_well_version.potential_method,p_decline_flag) *
                           ln_pwel_on_strm /
                           Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime)
                          ) - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'GAS');
            -- since theoretical is calcualted as ("potential" * "open faction") - "deferred" we can easily get rounding problems when the well is closed or deferred the whole day.
            -- therefore, we can apply rounding to the result if the result is very close to zero.
            IF (ln_ret_val < 0.001 AND ln_ret_val > -0.001) THEN
               ln_ret_val := 0;
            END IF;
         END IF;
      ELSE -- undefined
        ln_ret_val := NULL;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WET_GAS_MEASURED) THEN

      ln_on_stream_frac := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_stream_frac > 0 THEN -- Only worth doing calculation when the well is up

         ln_meter_factor := getMeterMethod(p_object_id, p_daytime , lr_well_version.well_meter_method);
         ln_flow_rate := lr_pwel_day_status.avg_flow_rate;
       ln_wet_dry_gas_ratio := findWetDryFactor(p_object_id, p_daytime);
	   ln_gas_lift_rate := NVL(getGasLiftStdRateDay(p_object_id,p_daytime,lr_well_version.gas_lift_method),0);
       IF ln_wet_dry_gas_ratio > 0 THEN
          IF lv2_ffv_flag = 'Y' THEN
			ln_ret_val := (((ln_flow_rate * nvl(ln_meter_factor, 1)) + sumFuelFlareVent(p_object_id, p_daytime, 'SUM_USM'))
                     / ln_wet_dry_gas_ratio) - ln_gas_lift_rate;
          ELSE
            ln_ret_val := ((ln_flow_rate * nvl(ln_meter_factor, 1)) / ln_wet_dry_gas_ratio) - ln_gas_lift_rate ;
          END IF;
         ELSE

           ln_dry_wet_gas_ratio := findDryWetFactor(p_object_id, p_daytime);
           IF ln_dry_wet_gas_ratio > 0 THEN -- if ln_wet_dry_gas_ratio is null or <0, find dry wet gas ratio

          IF lv2_ffv_flag = 'Y' THEN
			ln_ret_val := (((ln_flow_rate * nvl(ln_meter_factor, 1)) + sumFuelFlareVent(p_object_id, p_daytime, 'SUM_USM'))
                        * ln_dry_wet_gas_ratio) - ln_gas_lift_rate;
          ELSE
            ln_ret_val := ((ln_flow_rate * nvl(ln_meter_factor, 1)) * ln_dry_wet_gas_ratio) - ln_gas_lift_rate;
          END IF;

       ELSE
         ln_ret_val := NULL;
       END IF;
          END IF;

      ELSIF ln_on_stream_frac = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ld_end_daytime := ld_start_daytime + 1;
      lb_first := TRUE;
      ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
      ld_next_eff_daytime := ld_start_daytime;
      ln_ret_val := 0;

      WHILE ld_next_eff_daytime < ld_end_daytime LOOP

         ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
         ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

         ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
         ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
         ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

         IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
            ln_ret_val := NULL;
            EXIT;
         ELSE
            ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
         END IF;

         -- find start of next period
         ld_next_eff_daytime := LEAST(
                                      LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                     ld_end_daytime);

         -- find well on stream fraction (part of current period)
         ln_on_strm_ratio  := EcDp_Well.getPwelPeriodOnStrmFromStatus(p_object_id,GREATEST(ld_eff_daytime,ld_start_daytime),ld_next_eff_daytime)/24;

         IF ln_on_strm_ratio > 0 THEN
           IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
              lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
              ln_vol_rate := lr_pwel_result.gas_rate_adj;

           ELSE -- Use well production estimate for this period
              lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
              ln_vol_rate := Nvl(lr_well_event_row.gas_rate,lr_well_event_row.net_oil_rate* lr_well_event_row.gor);

           END IF;

           IF lb_first THEN
             ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
             lb_first := FALSE;
           ELSE
             ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
           END IF;
         ELSE
             ln_ret_val := ln_ret_val;
         END IF;

         ld_eff_daytime := ld_next_eff_daytime;

      END LOOP;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_EVENT_THEOR AND lr_well_version.CALC_EVENT_GAS_METHOD = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      SELECT MAX(we.daytime) INTO ld_last_event_prior_prod_day
      FROM well_event we
      WHERE we.event_type = 'WELL_EVENT_SINGLE'
      AND we.object_id = p_object_id
      AND we.event_day = p_daytime
      ORDER BY we.daytime DESC;

        IF (ld_last_event_prior_prod_day IS NOT NULL) THEN
            lb_multiple_event:=TRUE;
        END IF;

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,NVL(ld_last_event_prior_prod_day,p_daytime))/24;
         ld_start_daytime := TRUNC(NVL(ld_last_event_prior_prod_day,p_daytime)) + ln_prod_day_offset;
         ld_end_daytime := ld_start_daytime + 1;
         ld_eff_daytime := ld_start_daytime;
         lb_first := TRUE;
         ln_ret_val := 0;

         WHILE ld_eff_daytime < ld_end_daytime LOOP

            ld_eff_daytime := NVL(EcDp_Well_Event.getLastWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_start_daytime);
            ld_eff_daytime := GREATEST(ld_eff_daytime, ld_start_daytime);

            IF(lb_multiple_event) THEN
             ln_on_strm_ratio  := EcDp_Well.getPwelEventOnStreamsHrs(p_object_id,ld_eff_daytime)/24;
            ELSE
             ln_on_strm_ratio  := EcDp_Well.getPwelOnStreamHrs(p_object_id,ld_eff_daytime)/24;
            END IF;


             IF ln_on_strm_ratio > 0 THEN
                  lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'WELL_EVENT_SINGLE',ld_eff_daytime);
                  ln_vol_rate := NVL(EcBp_Well_Theoretical.getGasStdRateEvent(p_object_id, ld_eff_daytime),lr_well_event_row.grs_oil_rate*(1-lr_well_event_row.bs_w));
               IF lb_first THEN
                 ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
                 lb_first := FALSE;
               ELSE
                 ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
               END IF;
             ELSE
                 ln_ret_val := ln_ret_val;
             END IF;

             ld_eff_daytime := NVL(EcDp_Well_Event.getNextWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_end_daytime);

          END LOOP;

--user exit
   ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_EVENT_THEOR AND lr_well_version.CALC_EVENT_GAS_METHOD = EcDp_Calc_Method.USER_EXIT) THEN

          SELECT MAX(we.daytime) INTO ld_last_event_prior_prod_day
          FROM well_event we
          WHERE we.event_type = 'WELL_EVENT_SINGLE'
          AND we.object_id = p_object_id
          AND we.event_day = p_daytime
          ORDER BY we.daytime DESC;

        IF (ld_last_event_prior_prod_day IS NOT NULL) THEN
            lb_multiple_event:=TRUE;
        END IF;

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,NVL(ld_last_event_prior_prod_day,p_daytime))/24;
         ld_start_daytime := TRUNC(NVL(ld_last_event_prior_prod_day,p_daytime)) + ln_prod_day_offset;
         ld_end_daytime := ld_start_daytime + 1;
         ld_eff_daytime := ld_start_daytime;
         lb_first := TRUE;
         ln_ret_val := 0;

         WHILE ld_eff_daytime < ld_end_daytime LOOP

            ld_eff_daytime := NVL(EcDp_Well_Event.getLastWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_start_daytime);
            ld_eff_daytime := GREATEST(ld_eff_daytime, ld_start_daytime);

            IF(lb_multiple_event) THEN
             ln_on_strm_ratio  := EcDp_Well.getPwelEventOnStreamsHrs(p_object_id,ld_eff_daytime)/24;
            ELSE
             ln_on_strm_ratio  := EcDp_Well.getPwelOnStreamHrs(p_object_id,ld_eff_daytime)/24;
            END IF;


             IF ln_on_strm_ratio > 0 THEN
                  lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'WELL_EVENT_SINGLE',ld_eff_daytime);
                  ln_vol_rate := NVL(Ue_Well_Theoretical.getGasStdRateEvent(p_object_id, ld_eff_daytime),lr_well_event_row.grs_oil_rate*(1-lr_well_event_row.bs_w));
               IF lb_first THEN
                 ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
                 lb_first := FALSE;
               ELSE
                 ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
               END IF;
             ELSE
                 ln_ret_val := ln_ret_val;
             END IF;

             ld_eff_daytime := NVL(EcDp_Well_Event.getNextWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_end_daytime);

          END LOOP;

   ELSIF (lv2_calc_method = Ecdp_Calc_Method.WELLTEST_FWS) THEN

      ln_on_stream_frac := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

      IF ln_on_stream_frac > 0 THEN -- Only worth doing calculation when the well is up

        ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
        ld_start_daytime := p_daytime + ln_prod_day_offset;
        lr_result_req := ecdp_performance_test.getLastValidWellResult(p_object_id, ld_start_daytime);
        ln_wet_dry_gas_ratio := findWetDryFactor(p_object_id, p_daytime);

        IF ln_wet_dry_gas_ratio > 0 THEN
           ln_ret_val := (lr_result_req.fws_rate/24*ln_on_stream_frac)/ln_wet_dry_gas_ratio * NVL(lr_result_req.well_meter_factor,1);
        ELSE
           ln_ret_val := NULL;
        END IF;

      ELSIF ln_on_stream_frac = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_CORR) THEN

       ln_gas_lift_rate := getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method);
       ln_result_no := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,p_daytime);
       ln_meter_corr := ec_pwel_result.meter1_factor_gas(p_object_id, ln_result_no);
       ln_ret_val := ln_meter_corr * ec_pwel_day_status.avg_mpm_gas_rate(p_object_id, p_daytime) - Nvl(ln_gas_lift_rate,0);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_CORR) THEN

       ln_gas_lift_rate := getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method);
       ln_result_no := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,p_daytime);
       ln_meter_corr := ec_pwel_result.meter2_factor_gas(p_object_id, ln_result_no);
       ln_ret_val := ln_meter_corr * ec_pwel_day_status.avg_mpm2_gas_rate(p_object_id, p_daytime) - Nvl(ln_gas_lift_rate,0);

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getGasStdRateDay(
               p_object_id,
               p_daytime);

   ELSIF (lv2_calc_method IN (EcDp_Calc_Method.TOTALIZER_EVENT, EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE)) THEN

     ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;
     ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime)/24);
     ld_start_daytime := p_daytime + ln_prod_day_offset;
     lr_result_req := ecdp_performance_test.getLastValidWellResult(p_object_id, ld_start_daytime);

     IF ln_on_strm_ratio > 0 THEN
       ln_fraction_vol := 0;
       ln_totalizer_frac := 0;
       ln_total_fraction_vol := 0;


       IF lv2_calc_method = EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE THEN
         FOR curRec IN c_well_period_totalizer_maxday('PWEL_TOTALIZER_GAS', ld_start_daytime) LOOP
           ld_max_daytime := curRec.Max_daytime;
         END LOOP;
         ld_start_daytime := ld_max_daytime;
       END IF ;

       -- loop to get the fraction volume based on the totalizer daily rate
       FOR cur_totalizer IN c_well_period_totalizer(ld_start_daytime) LOOP
         ln_totalizer_frac := least((cur_totalizer.end_date - ln_prod_day_offset),ld_start_daytime+1) - greatest((cur_totalizer.daytime - ln_prod_day_offset), ld_start_daytime);
         ln_fraction_vol := ln_fraction_vol + (ln_totalizer_frac * getProducedStdDailyRate(p_object_id, 'PWEL_TOTALIZER_GAS', cur_totalizer.daytime));
       END LOOP;
       IF ln_fraction_vol > 0 THEN
         ln_total_fraction_vol :=  ln_fraction_vol * ln_on_strm_ratio;
       ELSE
         ln_total_fraction_vol := 0;
       END IF;

     ELSIF ln_on_strm_ratio = 0 THEN
       ln_total_fraction_vol := 0;

     ELSE
       ln_total_fraction_vol := NULL;
     END IF;

     ln_wet_dry_gas_ratio := findWetDryFactor(p_object_id, p_daytime,lr_well_version.wdf_method);
     IF ln_wet_dry_gas_ratio > 0 AND ln_total_fraction_vol > 0 THEN
         ln_ret_val := (ln_total_fraction_vol + NVL(lr_pwel_day_status.usm_flare,0) + NVL(lr_pwel_day_status.usm_vent,0) + NVL(lr_pwel_day_status.usm_fuel,0)) /
                    ln_wet_dry_gas_ratio * NVL(lr_result_req.WELL_METER_FACTOR,1);

     ELSIF ln_wet_dry_gas_ratio IS NULL OR ln_total_fraction_vol IS NULL THEN
       ln_ret_val := NULL;

     ELSE
       ln_ret_val := 0;
     END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_SUB_DAY_THEOR) THEN
      ln_gas_lift_rate  := getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method);
        ln_ret_val        := lr_pwel_day_status.sub_day_theor_gas - Nvl(ln_gas_lift_rate,0);

      -- decline calculations
      IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.GAS));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'GAS', ln_ret_val);
      END IF;
   ELSIF (lv2_calc_method = EcDp_Calc_Method.BHP_SI_BHP_FLOW) THEN
      ln_on_stream_frac := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;
      IF ln_on_stream_frac > 0 THEN -- Only worth doing calculation when the well is up
        lr_well_ref_value := ec_well_reference_value.row_by_pk(p_object_id,p_daytime,'<=');
        ln_ret_val :=  lr_well_ref_value.drainage_const_c *
                   power ((power(lr_well_ref_value.bhp_shut_in, 2) -  power(lr_pwel_day_status.avg_bh_press,2) ),
                   lr_well_ref_value.non_ideal_gas_behavior_n); /*C(BHPsi^2 - BHPwf^2)^N*/
      ELSIF ln_on_stream_frac = 0 THEN
        ln_ret_val := 0;
      ELSE
        ln_ret_val := NULL;
      END IF;

   ELSIF(lv2_calc_method = EcDp_Calc_Method.MASS_DIV_DENSITY) THEN
      ln_mass_day := findGasMassDay(p_object_id,p_daytime,p_calc_method);

        lv_gas_method := Nvl (p_calc_method,lr_well_version.calc_method_mass);
            IF (lv_gas_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
               RAISE_APPLICATION_ERROR(-20604,'A loop was detected when trying to calculate Mass Day. Check Configuration.');
            END IF;

       IF ln_mass_day <> 0 THEN
         ln_stdDensity := findGasStdDensity(p_object_id,p_daytime,p_calc_method);

         IF ln_stdDensity > 0 THEN
                 ln_ret_val := ln_mass_day / ln_stdDensity;
         ELSE
                 ln_ret_val := NULL;
         END IF;

      ELSIF ln_mass_day = 0 THEN
         ln_ret_val := 0;
      ELSE
         ln_ret_val := NULL;

     END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WATER_GWR) THEN
      ln_ret_val := getWatStdRateDay(p_object_id, p_daytime);
      ln_ret_val := ln_ret_val * findGasWaterRatio(p_object_id, p_daytime);
   ELSIF (lv2_calc_method = Ecdp_Calc_Method.MEAS_SWING_WELL) THEN
     ln_meas_gas := getGasStdRateDay(p_object_id,p_daytime,'MEASURED'); --daily dry gas
     IF ln_meas_gas is null THEN
       ln_wet_meas_gas := getGasStdRateDay(p_object_id,p_daytime,'WET_GAS_MEASURED'); --daily wet gas vol
     END IF;
     ln_ret_val := NVL(ln_meas_gas, ln_wet_meas_gas); -- Start with the measured volume.
     lb_first := TRUE;
     -- Add any measured swing volume.
     FOR sumgas in c_gas_event(p_object_id, p_daytime) LOOP
         ln_dry_gas := sumgas.dry_gas_vol;
         ln_wet_gas := sumgas.well_wet_gas_vol;
         IF ln_dry_gas is not null or ln_wet_gas is not null THEN
           IF ln_dry_gas > 0 THEN
             -- Add dry gas to the volume.
             ln_ret_val := ln_ret_val + ln_dry_gas;
           ELSIF ln_wet_gas > 0 THEN
             IF ln_meas_gas is null and ln_wet_meas_gas > 0 THEN
               -- The well is flowing to a shared sep, then its flowing to another shared separator for the rest of the day.
               -- The well wet gas meter will measured total daily wet gas.
               -- "The volume prior to swing" volume will be the volume before the well swung.
               -- "The swing to" volume will be calculated as Daily measured - "swing from volume"
               null;
             ELSE
               -- Convert wet gas swing volume to dry gas and then add it to the volume.
               ln_ret_val := ln_ret_val + ln_wet_gas * ln_dry_wet_gas_ratio;
             END IF;
           END IF;
         END IF;
    END LOOP;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM) THEN
     ln_gas_lift_rate := getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method);
       ln_ret_val       := lr_pwel_day_status.avg_mpm_gas_rate - Nvl(ln_gas_lift_rate,0);    --Subtract gas lift contribution if present
   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
       ln_ret_val       := lr_pwel_day_status.avg_mpm_gas_rate; --Return MPM reading without subtracting gas lift

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2) THEN
     ln_gas_lift_rate := getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method);
       ln_ret_val       := lr_pwel_day_status.avg_mpm2_gas_rate - Nvl(ln_gas_lift_rate,0);    --Subtract gas lift contribution if present
   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_NET) THEN
       ln_ret_val       := lr_pwel_day_status.avg_mpm2_gas_rate; --Return MPM reading without subtracting gas lift


   ELSIF ( lv2_calc_method = EcDp_Calc_Method.CONSEC_WELL_TEST ) THEN
    ln_result_no := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
    ln_count_day := 1;

    SELECT NVL(GAS_RATE_ADJ, 0), NVL(DURATION, 0) INTO ln_volume, ln_duration
    FROM PWEL_RESULT
    WHERE RESULT_NO = ln_result_no;

    FOR cur_well_test in c_prev_well_test(p_object_id, ln_result_no) LOOP
      IF TRUNC(cur_well_test.valid_from_date) = TRUNC(ec_pwel_result.valid_from_date(p_object_id, ln_result_no) - ln_count_day) THEN
        ln_count_day := ln_count_day + 1;
        ln_volume := ln_volume + cur_well_test.gas_rate_adj;
        ln_duration := ln_duration + cur_well_test.duration;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    ln_ret_val := (ln_volume/ln_duration) * NVL(ec_pwel_day_status.on_stream_hrs(p_object_id, p_daytime, '<='), EcDp_Well.getPwelOnStreamHrs(p_object_id, p_daytime));

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_PRIORITIZED) THEN

     ln_ret_val := EcBp_HCM_VFM.getGasStdRateDay(p_object_id, p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM) THEN

     ln_gas_lift_rate := getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method);
     ln_ret_val := lr_pwel_day_status.avg_vfm_gas_rate - Nvl(ln_gas_lift_rate,0);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN

     ln_ret_val := lr_pwel_day_status.avg_vfm_gas_rate;

   ELSE  -- unknown method
      ln_ret_val := NULL;
   END IF;

    -- try to deduct any CO2 from the gas as this function should return hydrocarbon gas and not CO2
   IF ln_ret_val IS NOT NULL THEN
      IF ((p_deduct_co2_flag = 'Y' OR p_deduct_co2_flag IS NULL) AND lr_well_version.calc_co2_method IS NOT NULL) THEN
         RETURN ln_ret_val - NVL(getCO2StdRateDay(p_object_id, p_daytime),0);
      ELSE -- if it is the CO2 function that calls this function, then dont deduct co2. Co2 is calculated as e.g. = total gas * co2% from well test
         RETURN ln_ret_val;
      END IF;
   END IF;

  END IF;
  END IF; -- End check if lv2_calc_method is not null

  RETURN ln_ret_val;

END getGasStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateDay
-- Description    : Returns theoretical water volume for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdRateDay(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL,
                          p_decline_flag VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

   lv2_calc_method          VARCHAR2(32);
   lv2_def_version          VARCHAR2(32);
   lv_wat_method            VARCHAR2(32);
   lv2_decline_flag         VARCHAR2(1);
   lv2_tank_id              VARCHAR2(32);
   lv2_override_theor_flag  VARCHAR2(1);

   lr_day_rec               PWEL_DAY_STATUS%ROWTYPE;
   lr_well_event_row        WELL_EVENT%ROWTYPE;
   lr_pwel_result      PWEL_RESULT%ROWTYPE;
   lr_well_version          WELL_VERSION%ROWTYPE;
   lr_pwel_day_status         PWEL_DAY_STATUS%ROWTYPE;

   ln_oil_rate              NUMBER;
   ln_gas_rate              NUMBER;
   ln_ret_val               NUMBER;
   ln_wat_rate              NUMBER;
   ln_wat_oil_ratio         NUMBER;
   ln_water_cut             NUMBER;
   ln_on_strm_ratio         NUMBER;
   ln_test_pump_speed       NUMBER;
   ln_pump_speed_ratio      NUMBER;
   ln_prod_day_offset       NUMBER;
   ln_prev_test_no          NUMBER;
   ln_vol_rate              NUMBER;
   ln_diluent_rate          NUMBER;
   ln_mass_day              NUMBER;
   ln_stdDensity            NUMBER;
   ln_closeVol              NUMBER;
   ln_openVol               NUMBER;
   ln_pwel_on_strm          NUMBER;
   ln_truck_bsw             NUMBER;
   ln_sum                   NUMBER;
   ln_well_bsw              NUMBER;
   ln_total_daily_emul_prod NUMBER;
   ln_bsw                   NUMBER;
   ln_wgr                   NUMBER;
   ln_dry_wet_gas_ratio     NUMBER;
   ln_dry_gas               NUMBER;
   ln_wet_gas               NUMBER;

   lb_first                 BOOLEAN;

   ld_end_daytime           DATE;
   ld_start_daytime         DATE;
   ld_prev_period_start     DATE;
   ld_eff_daytime           DATE;
   ld_next_eff_daytime      DATE;
   ld_prev_estimate         DATE;
   ld_next_estimate         DATE;
   ld_prev_test             DATE;
   ld_next_test             DATE;
   ld_from_date             DATE;

   ld_prod_day              DATE;
   ld_last_event_prior_prod_day DATE;
   lb_multiple_event BOOLEAN     :=FALSE;

	ln_volume                       NUMBER;
	ln_duration                     NUMBER;
	ln_count_day                    NUMBER;
	ln_result_no                    NUMBER;
	ln_meter_corr                   NUMBER;

CURSOR c_well_event_single(p_object_id well.object_id%TYPE, p_start_daytime DATE, p_end_daytime DATE) IS
   SELECT *
      FROM well_event we
      WHERE we.event_type = 'WELL_EVENT_SINGLE'
      AND we.object_id = p_object_id
      AND we.daytime between p_start_daytime and p_end_daytime
      ORDER BY we.daytime ASC;

--cursor to fetch all the tank's connect to a well(WELL_TANK)
CURSOR c_tank_well(cp_object_id well.object_id%TYPE) IS
    SELECT *
    FROM tank_version
    WHERE tank_well = cp_object_id
    AND daytime <= p_daytime AND (end_date > p_daytime OR end_date IS NULL)
    AND (exclude_tank_well='N' OR exclude_tank_well IS NULL);

CURSOR c_swing_well_event (cp_object_id well.object_id%TYPE, cp_fromday DATE) IS
SELECT *
  FROM well_swing_connection w
 WHERE w.object_id = cp_object_id
   AND w.event_day = cp_fromday
   AND w.asset_id = w.asset_id
   ORDER BY w.daytime ASC;

CURSOR c_prev_well_test(cp_object_id well.object_id%TYPE, cp_result_no NUMBER) IS
SELECT * FROM PWEL_RESULT
	WHERE object_id = cp_object_id
	AND result_no <> cp_result_no
	AND DURATION = 24
	AND STATUS = 'ACCEPTED'
	AND VALID_FROM_DATE < ec_pwel_result.valid_from_date(cp_object_id, cp_result_no)
	ORDER BY VALID_FROM_DATE DESC;

BEGIN
  -- water_calc_method
  lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_calc_method := Nvl(p_calc_method, lr_well_version.calc_water_method);

  IF (lv2_calc_method IS NOT NULL) THEN
    lv2_decline_flag := Nvl(p_decline_flag, NVL(lr_well_version.decline_flag, 'N'));
  lr_pwel_day_status := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);



    IF (p_calc_method IS NULL AND NVL(lr_well_version.allow_theor_override, 'N') = 'Y' AND lr_pwel_day_status.override_theor_wat IS NOT NULL) THEN
      ln_ret_val := lr_pwel_day_status.override_theor_wat;
  ELSE
   IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
        ln_ret_val := lr_pwel_day_status.avg_water_rate;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
      -- Include trucked out volume
        ln_ret_val := NVL(lr_pwel_day_status.avg_water_rate, 0) + NVL(Ecbp_Well_Theoretical.sumTruckedWaterFromWell(p_object_id, p_daytime), 0);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.LIQUID_MEASURED) THEN
        ln_ret_val       := lr_pwel_day_status.avg_liquid_rate_m3;
      ln_diluent_rate  := getDiluentStdRateDay(p_object_id, p_daytime, lr_well_version.diluent_method);
      IF lr_well_version.bsw_vol_method = EcDp_Calc_Method.MEASURED THEN
        -- Apply measured watercut representing ALL water in liquid
        ln_ret_val   := ln_ret_val*(findWaterCutPct(p_object_id,p_daytime,lr_well_version.bsw_vol_method,NULL,'PWEL_DAY_STATUS')/100);
      ELSE
        -- Apply produced watercut to measured liquid after subtracting diluent and powerwater
        ln_ret_val   := (ln_ret_val - Nvl(ln_diluent_rate,0) - Nvl(lr_day_rec.avg_powerwater_rate,0)) * (findWaterCutPct(p_object_id,p_daytime,lr_well_version.bsw_vol_method,NULL,'PWEL_DAY_STATUS')/100);
      END IF;

   -- External Calculated Theoretical Rate 1
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_1) THEN
       ln_ret_val := lr_pwel_day_status.ext_wat_rate_1;
   -- External Calculated Theoretical Rate 2
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_2) THEN
       ln_ret_val := lr_pwel_day_status.ext_wat_rate_2;
   -- External Calculated Theoretical Rate 3
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_3) THEN
       ln_ret_val := lr_pwel_day_status.ext_wat_rate_3;
   -- External Calculated Theoretical Rate 4
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_4) THEN
       ln_ret_val := lr_pwel_day_status.ext_wat_rate_4;
   -- External Calculated Theoretical Rate 5
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_5) THEN
       ln_ret_val := lr_pwel_day_status.ext_wat_rate_5;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         ln_ret_val := EcDp_Well_Estimate.getWatStdRate(p_object_id, ld_start_daytime);
         ln_ret_val := ln_ret_val * ln_on_strm_ratio;

      ELSIF ln_on_strm_ratio = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

      -- calculate decline
      IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
         lr_pwel_result := Ecdp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_pwel_result.valid_from_date;
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WATER', ln_ret_val);

      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_PUMP_SPEED) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;


        ln_test_pump_speed := EcDp_Well_Estimate.getLastAvgDhPumpSpeed(p_object_id,
                                                                       ld_start_daytime);

        IF ln_test_pump_speed IS NOT NULL AND ln_test_pump_speed <> 0 THEN

           ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

           IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

                ln_pump_speed_ratio := lr_pwel_day_status.avg_dh_pump_speed / ln_test_pump_speed;
              ln_ret_val := EcDp_Well_Estimate.getWatStdRate(p_object_id, ld_start_daytime);
              ln_ret_val := ln_ret_val * ln_on_strm_ratio * ln_pump_speed_ratio;

           ELSIF ln_on_strm_ratio = 0 THEN
             ln_ret_val := 0;

           ELSE
             ln_ret_val := NULL;
           END IF;

         ELSE -- Not enough info to calculate, no assumptions about pump speed
           ln_ret_val := NULL;

         END IF;

      -- calculate decline
      IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
         lr_pwel_result := Ecdp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_pwel_result.valid_from_date;
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WATER', ln_ret_val);

      END IF;


   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_WATER) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_wat_rate := getCurveRate(p_object_id,
                                     p_daytime,
                                     EcDp_Phase.WATER,
                                     EcDp_Curve_Purpose.PRODUCTION,
                                     lr_pwel_day_status.avg_choke_size,
                                     lr_pwel_day_status.avg_wh_press,
                                     lr_pwel_day_status.avg_wh_temp,
                                     lr_pwel_day_status.avg_bh_press,
                                     lr_pwel_day_status.annulus_press,
                                     lr_pwel_day_status.avg_wh_usc_press,
                                     lr_pwel_day_status.avg_wh_dsc_press,
                                     lr_pwel_day_status.bs_w,
                                     lr_pwel_day_status.avg_dh_pump_speed,
                                     lr_pwel_day_status.avg_gl_choke,
                                     lr_pwel_day_status.avg_gl_press,
                                     getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method),
                                     lr_pwel_day_status.avg_gl_diff_press,
                                     lr_pwel_day_status.avg_flow_mass,
                                     lr_pwel_day_status.phase_current,
                                     lr_pwel_day_status.ac_frequency,
                                     lr_pwel_day_status.intake_press,
                                     lr_pwel_day_status.avg_mpm_oil_rate,
                                     lr_pwel_day_status.avg_mpm_gas_rate,
                                     lr_pwel_day_status.avg_mpm_water_rate,
                                     lr_pwel_day_status.avg_mpm_cond_rate,
                                     lr_pwel_day_status.avg_dh_pump_power,
                                     lr_pwel_day_status.avg_dp_venturi,
                                     NULL,
                                     lv2_calc_method);

         ln_ret_val := ln_wat_rate * ln_on_strm_ratio;

      ELSIF ln_on_strm_ratio = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

      -- calculate decline
      IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
         ld_from_date := ec_performance_curve.daytime(Ecdp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, Ecdp_Curve_Purpose.PRODUCTION, EcDp_Phase.WATER,'CURVE_WATER'));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WATER', ln_ret_val );
      END IF;
   ELSIF (lv2_calc_method = EcDp_Calc_Method.POTENTIAL_DEFERED) THEN
      lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ld_end_daytime := ld_start_daytime + 1;

      IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
         IF ec_pwel_period_status.active_well_status(p_object_id,ld_start_daytime,'EVENT','<=') = 'CLOSED_LT' THEN
            ln_ret_val := 0;
         ELSE
         ln_ret_val := ecbp_well_potential.findWatProductionPotential(p_object_id, p_daytime, lr_well_version.potential_method, p_decline_flag)
            - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'WAT');
         END IF;

      ELSIF (lv2_def_version = 'PD.0020') THEN
        -- get on strm from active status, its used several times here.
         ln_pwel_on_strm := ecdp_well.getPwelPeriodOnStrmFromStatus(p_object_id,ld_start_daytime,ld_end_daytime);
         -- if well has active_well_status<>OPEN for the whole day, then simply return 0 because there cannot be any deferment when well is not active.
         IF ln_pwel_on_strm = 0 THEN
            ln_ret_val := 0;
         ELSE
            ln_ret_val := (ecbp_well_potential.findWatProductionPotential(p_object_id, p_daytime, lr_well_version.potential_method,p_decline_flag) *
                           ln_pwel_on_strm /
                           Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime)
                          ) - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'WAT');
            -- since theoretical is calcualted as ("potential" * "open faction") - "deferred" we can easily get rounding problems when the well is closed or deferred the whole day.
            -- therefore, we can apply rounding to the result if the result is very close to zero.
            IF (ln_ret_val < 0.001 AND ln_ret_val > -0.001) THEN
               ln_ret_val := 0;
            END IF;
         END IF;
      ELSE -- undefined
        ln_ret_val := NULL;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_EVENT_THEOR AND lr_well_version.CALC_EVENT_WATER_METHOD = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      SELECT MAX(we.daytime) INTO ld_last_event_prior_prod_day
      FROM well_event we
      WHERE we.event_type = 'WELL_EVENT_SINGLE'
      AND we.object_id = p_object_id
      AND we.event_day = p_daytime
      ORDER BY we.daytime DESC;

        IF (ld_last_event_prior_prod_day IS NOT NULL) THEN
            lb_multiple_event:=TRUE;
        END IF;

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,NVL(ld_last_event_prior_prod_day,p_daytime))/24;
         ld_start_daytime := TRUNC(NVL(ld_last_event_prior_prod_day,p_daytime)) + ln_prod_day_offset;
         ld_end_daytime := ld_start_daytime + 1;
         ld_eff_daytime := ld_start_daytime;
         lb_first := TRUE;
         ln_ret_val := 0;

         WHILE ld_eff_daytime < ld_end_daytime LOOP

            ld_eff_daytime := NVL(EcDp_Well_Event.getLastWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_start_daytime);
            ld_eff_daytime := GREATEST(ld_eff_daytime, ld_start_daytime);

            IF(lb_multiple_event) THEN
             ln_on_strm_ratio  := EcDp_Well.getPwelEventOnStreamsHrs(p_object_id,ld_eff_daytime)/24;
            ELSE
             ln_on_strm_ratio  := EcDp_Well.getPwelOnStreamHrs(p_object_id,ld_eff_daytime)/24;
            END IF;


             IF ln_on_strm_ratio > 0 THEN
                  lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'WELL_EVENT_SINGLE',ld_eff_daytime);
                  ln_vol_rate := NVL(EcBp_Well_Theoretical.getWatStdRateEvent(p_object_id, ld_eff_daytime),lr_well_event_row.grs_oil_rate*(1-lr_well_event_row.bs_w));

               IF lb_first THEN
                 ln_ret_val := ln_vol_rate * ln_on_strm_ratio;

                 lb_first := FALSE;
               ELSE
                 ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);

               END IF;
             ELSE
                 ln_ret_val := ln_ret_val;
             END IF;

             ld_eff_daytime := NVL(EcDp_Well_Event.getNextWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_end_daytime);

          END LOOP;


   --user exit
   ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_EVENT_THEOR AND lr_well_version.CALC_EVENT_WATER_METHOD = EcDp_Calc_Method.USER_EXIT) THEN

      SELECT MAX(we.daytime) INTO ld_last_event_prior_prod_day
      FROM well_event we
      WHERE we.event_type = 'WELL_EVENT_SINGLE'
      AND we.object_id = p_object_id
      AND we.event_day = p_daytime
      ORDER BY we.daytime DESC;

        IF (ld_last_event_prior_prod_day IS NOT NULL) THEN
            lb_multiple_event:=TRUE;
        END IF;

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,NVL(ld_last_event_prior_prod_day,p_daytime))/24;
         ld_start_daytime := TRUNC(NVL(ld_last_event_prior_prod_day,p_daytime)) + ln_prod_day_offset;
         ld_end_daytime := ld_start_daytime + 1;
         ld_eff_daytime := ld_start_daytime;
         lb_first := TRUE;
         ln_ret_val := 0;

         WHILE ld_eff_daytime < ld_end_daytime LOOP

            ld_eff_daytime := NVL(EcDp_Well_Event.getLastWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_start_daytime);
            ld_eff_daytime := GREATEST(ld_eff_daytime, ld_start_daytime);

            IF(lb_multiple_event) THEN
             ln_on_strm_ratio  := EcDp_Well.getPwelEventOnStreamsHrs(p_object_id,ld_eff_daytime)/24;
            ELSE
             ln_on_strm_ratio  := EcDp_Well.getPwelOnStreamHrs(p_object_id,ld_eff_daytime)/24;
            END IF;


             IF ln_on_strm_ratio > 0 THEN
                  lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'WELL_EVENT_SINGLE',ld_eff_daytime);
                  ln_vol_rate := NVL(Ue_Well_Theoretical.getWatStdRateEvent(p_object_id, ld_eff_daytime),lr_well_event_row.grs_oil_rate*(1-lr_well_event_row.bs_w));

               IF lb_first THEN
                 ln_ret_val := ln_vol_rate * ln_on_strm_ratio;

                 lb_first := FALSE;
               ELSE
                 ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);

               END IF;
             ELSE
                 ln_ret_val := ln_ret_val;
             END IF;

             ld_eff_daytime := NVL(EcDp_Well_Event.getNextWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_end_daytime);

          END LOOP;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_CORR) THEN

       ln_result_no := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,p_daytime);
       ln_meter_corr := ec_pwel_result.meter1_factor_wat(p_object_id, ln_result_no);
       ln_ret_val := ln_meter_corr * ec_pwel_day_status.avg_mpm_water_rate(p_object_id, p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_CORR) THEN

       ln_result_no := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,p_daytime);
       ln_meter_corr := ec_pwel_result.meter2_factor_wat(p_object_id, ln_result_no);
       ln_ret_val := ln_meter_corr * ec_pwel_day_status.avg_mpm2_water_rate(p_object_id, p_daytime);

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

      ln_ret_val := Ue_Well_Theoretical.getWatStdRateDay(
               p_object_id,
               p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.GAS_WGR) THEN
      ln_gas_rate := getGasStdRateDay(p_object_id, p_daytime, lr_well_version.calc_gas_method, p_decline_flag);
      IF ln_gas_rate > 0 THEN   -- Only worth getting WGR if Gas is > 0
         ln_ret_val := ln_gas_rate * findWaterGasRatio(p_object_id, p_daytime, lr_well_version.wgr_method, p_decline_flag,'PWEL_DAY_STATUS');
      ELSIF ln_gas_rate = 0 THEN   -- if oil rate = 0, then water is also zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := NULL;
      END IF;


   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ld_end_daytime := ld_start_daytime + 1;
      lb_first := TRUE;
      ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
      ld_next_eff_daytime := ld_start_daytime;
      ln_ret_val := 0;

      WHILE ld_next_eff_daytime < ld_end_daytime LOOP

         ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
         ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

         ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
         ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
         ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

         IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
            ln_ret_val := NULL;
            EXIT;
         ELSE
            ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
         END IF;

         -- find start of next period
         ld_next_eff_daytime := LEAST(
                                      LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                     ld_end_daytime);

         -- find well on stream fraction (part of current period)
         ln_on_strm_ratio  := EcDp_Well.getPwelPeriodOnStrmFromStatus(p_object_id,GREATEST(ld_eff_daytime,ld_start_daytime),ld_next_eff_daytime)/24;

     IF ln_on_strm_ratio > 0 THEN
           IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
              lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
              ln_vol_rate := lr_pwel_result.tot_water_rate_adj;

           ELSE -- Use well production estimate for this period
              lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
              ln_vol_rate := Nvl(lr_well_event_row.water_rate,0)+ Nvl(lr_well_event_row.grs_oil_rate*lr_well_event_row.bs_w,0);

           END IF;

           IF lb_first THEN
             ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
             lb_first := FALSE;
           ELSE
             ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
           END IF;
       ELSE
         ln_ret_val := ln_ret_val;
     END IF;

         ld_eff_daytime := ld_next_eff_daytime;

      END LOOP;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_SUB_DAY_THEOR) THEN
        ln_ret_val   := lr_pwel_day_status.sub_day_theor_water;

      -- calculate decline
      IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.WATER));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WATER', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.OIL_WATER_CUT) THEN
      ln_water_cut := findWaterCutPct(p_object_id, p_daytime, lr_well_version.bsw_vol_method, p_decline_flag,'PWEL_DAY_STATUS')/100;
      ln_oil_rate := getOilStdRateDay(p_object_id,p_daytime,lr_well_version.calc_method,p_decline_flag);
      IF ln_oil_rate > 0 THEN
         IF (1 - ln_water_cut) <> 0 THEN
            ln_ret_val := (ln_oil_rate/(1 - ln_water_cut)) * ln_water_cut;
         ELSE   -- div by zero
            ln_ret_val := null;
         END IF;
      ELSIF ln_oil_rate = 0 THEN   -- if oil is zero, then also water is zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := null;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.GAS_WATER_CUT) THEN
      ln_water_cut := findWaterCutPct(p_object_id, p_daytime, lr_well_version.bsw_vol_method, p_decline_flag,'PWEL_DAY_STATUS') /100;
      ln_gas_rate := getGasStdRateDay(p_object_id,p_daytime,lr_well_version.calc_gas_method,p_decline_flag);
      IF ln_gas_rate > 0 THEN
         IF (1 - ln_water_cut) <> 0 THEN
            ln_ret_val := (ln_gas_rate/(1 - ln_water_cut)) * ln_water_cut;
         ELSE   -- div by zero
            ln_ret_val := null;
         END IF;
      ELSIF ln_gas_rate = 0 THEN   -- if oil is zero, then also water is zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := null;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.LIQ_WATER_CUT) THEN
      ln_water_cut := findWaterCutPct(p_object_id, p_daytime, lr_well_version.bsw_vol_method, p_decline_flag,'PWEL_DAY_STATUS')/100;
      ln_oil_rate := getOilStdRateDay(p_object_id,p_daytime,lr_well_version.calc_method,p_decline_flag);

      IF ln_oil_rate > 0 THEN
         IF (1 - ln_water_cut) <> 0 THEN
            ln_ret_val := (ln_oil_rate / (1 - ln_water_cut)) * ln_water_cut;
         ELSE   -- div by zero
            ln_ret_val := null;
         END IF;
      ELSIF ln_oil_rate = 0 THEN   -- if oil is zero, then also water is zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := null;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.OIL_WOR) THEN
      ln_oil_rate := getOilStdRateDay(p_object_id, p_daytime,null,p_decline_flag);
      IF ln_oil_rate > 0 THEN   -- Only worth getting WOR if Oil is > 0
         ln_ret_val := ln_oil_rate * findWaterOilRatio(p_object_id, p_daytime,null, p_decline_flag,'PWEL_DAY_STATUS');
      ELSIF ln_oil_rate=0 THEN   -- if oil rate = 0, then water is also zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := null;
      END IF;

   ELSIF(lv2_calc_method = EcDp_Calc_Method.MASS_DIV_DENSITY) THEN
      ln_mass_day := findWaterMassDay(p_object_id,p_daytime,p_calc_method);

      lv_wat_method := Nvl (p_calc_method,ec_well_version.calc_method_mass(p_object_id,p_daytime,'<='));
            IF (lv_wat_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
               RAISE_APPLICATION_ERROR(-20604,'A loop was detected when trying to calculate Mass Day. Check Configuration.');
            END IF;

     IF ln_mass_day <> 0 THEN
         ln_stdDensity := findWatStdDensity(p_object_id,p_daytime,p_calc_method);

         IF ln_stdDensity > 0 THEN
                 ln_ret_val := ln_mass_day / ln_stdDensity;
         ELSE
                 ln_ret_val := NULL;
         END IF;

      ELSIF ln_mass_day = 0 THEN
         ln_ret_val := 0;
      ELSE
         ln_ret_val := NULL;

     END IF;

   ELSIF(lv2_calc_method = EcDp_Calc_Method.TANK_WELL) THEN -- method to calculate from the split of the tank and then to the well

        lb_first := TRUE;
        FOR mycur in c_tank_well(p_object_id) LOOP
           ln_closeVol := NVL(EcBp_Tank.findClosingWatVol(mycur.object_id, 'DAY_CLOSING', p_daytime),0);
           ln_openVol  := NVL(EcBp_Tank.findOpeningWatVol(mycur.object_id, 'DAY_CLOSING', p_daytime),0);
           IF lb_first THEN
             ln_ret_val := ln_closeVol - ln_openVol;
             lb_first := FALSE;
           ELSE
             ln_ret_val := ln_ret_val + ln_closeVol - ln_openVol;
           END IF;
        END LOOP;
        ln_ret_val := NVL(ln_ret_val,0) + NVL(Ecbp_Well_Theoretical.sumTruckedWaterFromWell(p_object_id, p_daytime),0);

  ELSIF(lv2_calc_method = EcDp_Calc_Method.WELL_TANK) THEN -- method to calculate from split at the well and then applied to tank

      lb_first := TRUE;
      --for loop to get tank_id
      FOR mycur in c_tank_well(p_object_id) LOOP
         ln_closeVol := NVL(EcBp_Tank.findClosingGrsVol(mycur.object_id, 'DAY_CLOSING', p_daytime),0);
         ln_openVol  := NVL(EcBp_Tank.findOpeningGrsVol(mycur.object_id, 'DAY_CLOSING', p_daytime),0);
         IF lb_first THEN
            ln_sum := ln_closeVol - ln_openVol;
               lb_first := FALSE;
         ELSE
            ln_sum := ln_sum + ln_closeVol - ln_openVol;
         END IF;
      END LOOP;
      ln_truck_bsw := findBSWTruck(p_object_id,p_daytime);
      ln_well_bsw := ec_pwel_day_status.bs_w(p_object_id,p_daytime,'=');
      -- BSW to use
      ln_bsw:= NVL(ln_well_bsw,ln_truck_bsw);
      -- total of daily emulsion production
      ln_total_daily_emul_prod := (NVL(ln_sum,0) + NVL(Ecbp_Well_Theoretical.sumTruckedNetOilFromWell(p_object_id, p_daytime),0) + NVL(Ecbp_Well_Theoretical.sumTruckedWaterFromWell(p_object_id, p_daytime),0));
      ln_ret_val := ln_total_daily_emul_prod * ln_bsw;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WATER_GWR) THEN
        ln_ret_val := lr_pwel_day_status.avg_water_rate;
   ELSIF (lv2_calc_method = Ecdp_Calc_Method.MEAS_SWING_WELL) THEN
      -- Initial with measured water.
     ln_ret_val := getWatStdRateDay(p_object_id, p_daytime, 'MEASURED');
     IF ln_ret_val is null THEN
         ln_ret_val := getWatStdRateDay(p_object_id, p_daytime, 'GAS_WGR');
     END IF;
     -- Add any measured swing volume (dry gas * wgr).
     FOR res_swing in c_swing_well_event(p_object_id, p_daytime) LOOP
        IF ln_dry_wet_gas_ratio is null THEN
             ln_wgr := findWaterGasRatio(p_object_id, p_daytime, NULL, NULL,'PWEL_DAY_STATUS');
             ln_dry_wet_gas_ratio := findDryWetFactor(p_object_id,p_daytime); -- find the dry wet factor
             IF ln_dry_wet_gas_ratio is null then ln_dry_wet_gas_ratio := 1 / NVL(findWetDryFactor(p_object_id,p_daytime),1); END IF; -- If the dry wet ratio is null, calculate it from the wet dry ratio
        END IF;
         ln_dry_gas := res_swing.dry_gas_vol;
         ln_wet_gas := res_swing.well_wet_gas_vol;
         IF ln_dry_gas is not null or ln_wet_gas is not null THEN
           IF ln_dry_gas > 0 THEN
             ln_ret_val := ln_ret_val + ln_dry_gas * ln_wgr;
           ELSIF ln_wet_gas > 0 THEN
             IF getGasStdRateDay(p_object_id,p_daytime,'MEASURED') is not null THEN
               -- Convert wet gas swing volume to dry gas and then add it to the volume.
               ln_ret_val := ln_ret_val + ln_wet_gas * ln_dry_wet_gas_ratio * ln_wgr;
             END IF;
           END IF;
         END IF;
     END LOOP;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM) THEN
       ln_ret_val := lr_pwel_day_status.avg_mpm_water_rate - NVL(lr_pwel_day_status.avg_powerwater_rate,0); --Subtract powerwater if present
   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
       ln_ret_val := lr_pwel_day_status.avg_mpm_water_rate; --Measured MPM reading without subtract powerwater if present

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2) THEN
       ln_ret_val := lr_pwel_day_status.avg_mpm2_water_rate - NVL(lr_pwel_day_status.avg_powerwater_rate,0); --Subtract powerwater if present
   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_NET) THEN
       ln_ret_val := lr_pwel_day_status.avg_mpm2_water_rate; --Measured MPM2 reading without subtract powerwater if present

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CONSEC_WELL_TEST)  THEN
    ln_result_no := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
    ln_count_day := 1;

    SELECT NVL(TOT_WATER_RATE_ADJ, 0), NVL(DURATION, 0) INTO ln_volume, ln_duration
    FROM PWEL_RESULT
    WHERE RESULT_NO = ln_result_no;

    FOR cur_well_test in c_prev_well_test(p_object_id, ln_result_no) LOOP
      IF TRUNC(cur_well_test.valid_from_date) = TRUNC(ec_pwel_result.valid_from_date(p_object_id, ln_result_no) - ln_count_day) THEN
        ln_count_day := ln_count_day + 1;
        ln_volume := ln_volume + cur_well_test.tot_water_rate_adj;
        ln_duration := ln_duration + cur_well_test.duration;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    ln_ret_val := (ln_volume/ln_duration) * NVL(ec_pwel_day_status.on_stream_hrs(p_object_id, p_daytime, '<='), EcDp_Well.getPwelOnStreamHrs(p_object_id, p_daytime));

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_PRIORITIZED) THEN

     ln_ret_val := EcBp_HCM_VFM.getWatStdRateDay(p_object_id, p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM) THEN

     ln_ret_val := lr_pwel_day_status.avg_vfm_water_rate - NVL(lr_pwel_day_status.avg_powerwater_rate,0);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN

     ln_ret_val := lr_pwel_day_status.avg_vfm_water_rate;

   ELSE -- undefined
      ln_ret_val :=  NULL;

   END IF;

  END IF;
  END IF; -- End check if lv2_calc_method is not null

  RETURN ln_ret_val;

END getWatStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateDay
-- Description    : Returns theoretical condensate volume for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdRateDay(p_object_id   well.object_id%TYPE,
                           p_daytime     DATE,
                           p_calc_method VARCHAR2 DEFAULT NULL,
                           p_decline_flag VARCHAR2 DEFAULT NULL )
RETURN NUMBER
--</EC-DOC>
IS
   ln_cgr               NUMBER;
   ln_on_strm_ratio     NUMBER;
   ln_prod_day_offset   NUMBER;
   ln_gas_rate          NUMBER;
   ln_mass_day          NUMBER;
   ln_stdDensity        NUMBER;
   ln_sum_TruckWell     NUMBER;
   ln_closeVol          NUMBER;
   ln_openVol           NUMBER;

   ld_start_daytime     DATE;
   ld_end_daytime       DATE;
   lv2_calc_method      VARCHAR2(32);
   lv2_def_version      VARCHAR2(32);
   lv_cond_method       VARCHAR2(32);
   lv2_decline_flag     VARCHAR2(1);

   lr_well_version      WELL_VERSION%ROWTYPE;
   lr_pwel_result       Pwel_Result%ROWTYPE;
   lr_pwel_day_status   PWEL_DAY_STATUS%ROWTYPE;
   ln_ret_val           NUMBER;
   ln_pwel_on_strm      NUMBER;
   ln_bsw_fraction      NUMBER;
   ln_sum NUMBER;
   ln_total_daily_emul_prod NUMBER;
   ln_dry_wet_gas_ratio NUMBER;
   ln_dry_gas           NUMBER;
   ln_wet_gas           NUMBER;
   ln_fraction_vol      NUMBER;
   ln_totalizer_frac    NUMBER;
   ln_total_fraction_vol NUMBER;
   ld_prod_day          DATE;
   ld_from_date         DATE;
   lb_first             BOOLEAN;

   ld_eff_daytime       DATE;
   ld_next_eff_daytime  DATE;
   ld_prev_estimate     DATE;
   ld_next_estimate     DATE;
   ld_prev_test         DATE;
   ld_next_test         DATE;
   ld_max_daytime       DATE;
   ln_prev_test_no      NUMBER;
   ln_vol_rate          NUMBER;
   lr_well_event_row    WELL_EVENT%ROWTYPE;

   lv2_override_theor_flag     VARCHAR2(1);

   ld_last_event_prior_prod_day DATE;
   lb_multiple_event BOOLEAN     :=FALSE;
   ln_volume                       NUMBER;
   ln_duration                     NUMBER;
   ln_count_day                    NUMBER;
   ln_result_no                    NUMBER;
   ln_meter_corr                   NUMBER;

CURSOR c_well_event_single(p_object_id well.object_id%TYPE, p_start_daytime DATE, p_end_daytime DATE) IS
   SELECT *
      FROM well_event we
      WHERE we.event_type = 'WELL_EVENT_SINGLE'
      AND we.object_id = p_object_id
      AND we.daytime between p_start_daytime and p_end_daytime
      ORDER BY we.daytime ASC;

--cursor to fetch all the tank's connect to a well(WELL_TANK)
CURSOR c_tank_well(cp_object_id well.object_id%TYPE) IS
    SELECT *
    FROM tank_version
    WHERE tank_well = cp_object_id
    AND daytime <= p_daytime AND (end_date > p_daytime OR end_date IS NULL)
    AND (exclude_tank_well='N' OR exclude_tank_well IS NULL);

CURSOR c_swing_well_event (cp_object_id well.object_id%TYPE, cp_fromday DATE) IS
SELECT *
  FROM well_swing_connection w
 WHERE w.object_id = cp_object_id
   AND w.event_day = cp_fromday
   AND w.asset_id = w.asset_id
   ORDER BY w.daytime ASC;

CURSOR c_well_period_totalizer_maxday(cp_class_name VARCHAR2, cp_daytime DATE) IS
   SELECT max(daytime) max_daytime
   FROM well_period_totalizer
   WHERE object_id = p_object_id
   AND class_name = cp_class_name
   AND (to_char(to_date(cp_daytime), 'yyyymm') between to_char(to_date(end_date), 'yyyymm') AND to_char(add_months(to_date(TRUNC(to_date(end_date), 'mm')), 1), 'yyyymm'))
   ORDER BY daytime ASC;

CURSOR c_well_period_totalizer (cp_date DATE) IS
SELECT *
  FROM well_period_totalizer
  WHERE object_id = p_object_id
  AND (daytime < cp_date+1 AND end_date > cp_date)
  ORDER BY daytime ASC;

CURSOR c_prev_well_test(cp_object_id well.object_id%TYPE, cp_result_no NUMBER) IS
SELECT * FROM PWEL_RESULT
	WHERE object_id = cp_object_id
	AND result_no <> cp_result_no
	AND DURATION = 24
	AND STATUS = 'ACCEPTED'
	AND VALID_FROM_DATE < ec_pwel_result.valid_from_date(cp_object_id, cp_result_no)
	ORDER BY VALID_FROM_DATE DESC;


BEGIN
   -- cond_calc_method
   lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');

  lv2_calc_method := Nvl(p_calc_method, lr_well_version.calc_cond_method);

  IF (lv2_calc_method IS NOT NULL) THEN
  lv2_decline_flag := Nvl(p_decline_flag, NVL(lr_well_version.decline_flag,'N'));
    lr_pwel_day_status := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);



    IF ( p_calc_method IS NULL AND  NVL(lr_well_version.allow_theor_override, 'N') = 'Y' AND lr_pwel_day_status.override_theor_cond IS NOT NULL) THEN
    ln_ret_val := lr_pwel_day_status.override_theor_cond;
  ELSE
   IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
        ln_ret_val := lr_pwel_day_status.avg_cond_rate;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
     -- Include trucked out volume
       ln_ret_val := NVL(lr_pwel_day_status.avg_cond_rate, 0) + NVL(Ecbp_Well_Theoretical.sumTruckedNetOilFromWell(p_object_id, p_daytime), 0);

   -- External Calculated Theoretical Rate 1
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_1) THEN
       ln_ret_val := lr_pwel_day_status.ext_cond_rate_1;
   -- External Calculated Theoretical Rate 2
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_2) THEN
       ln_ret_val := lr_pwel_day_status.ext_cond_rate_2;
   -- External Calculated Theoretical Rate 3
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_3) THEN
       ln_ret_val := lr_pwel_day_status.ext_cond_rate_3;
   -- External Calculated Theoretical Rate 4
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_4) THEN
       ln_ret_val := lr_pwel_day_status.ext_cond_rate_4;
   -- External Calculated Theoretical Rate 5
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_5) THEN
       ln_ret_val := lr_pwel_day_status.ext_cond_rate_5;


   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         ln_ret_val := EcDp_Well_Estimate.getCondStdRate(p_object_id, ld_start_daytime);
         ln_ret_val := ln_ret_val * ln_on_strm_ratio;

      ELSIF ln_on_strm_ratio = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

      -- method is candidate for decline calculations
      IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
         lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_pwel_result.valid_from_date;
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'CONDENSATE', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN

     ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

     IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

       ln_ret_val := getCurveRate(p_object_id,
                                    p_daytime,
                                    EcDp_Phase.CONDENSATE,
                                    EcDp_Curve_Purpose.PRODUCTION,
                                    lr_pwel_day_status.avg_choke_size,
                                    lr_pwel_day_status.avg_wh_press,
                                    lr_pwel_day_status.avg_wh_temp,
                                    lr_pwel_day_status.avg_bh_press,
                                    lr_pwel_day_status.annulus_press,
                                    lr_pwel_day_status.avg_wh_usc_press,
                                    lr_pwel_day_status.avg_wh_dsc_press,
                                    lr_pwel_day_status.bs_w,
                                    lr_pwel_day_status.avg_dh_pump_speed,
                                    lr_pwel_day_status.avg_gl_choke,
                                    lr_pwel_day_status.avg_gl_press,
                                    getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method),
                                    lr_pwel_day_status.avg_gl_diff_press,
                                    lr_pwel_day_status.avg_flow_mass,
                                    lr_pwel_day_status.phase_current,
                                    lr_pwel_day_status.ac_frequency,
                                    lr_pwel_day_status.intake_press,
                                    lr_pwel_day_status.avg_mpm_oil_rate,
                                    lr_pwel_day_status.avg_mpm_gas_rate,
                                    lr_pwel_day_status.avg_mpm_water_rate,
                                    lr_pwel_day_status.avg_mpm_cond_rate,
                                    lr_pwel_day_status.avg_dh_pump_power,
                                    lr_pwel_day_status.avg_dp_venturi,
                                    NULL,
                                    lv2_calc_method);

       ln_ret_val := ln_ret_val * ln_on_strm_ratio;

      ELSIF ln_on_strm_ratio = 0 THEN
        ln_ret_val := 0;
      ELSE
        ln_ret_val := NULL;
      END IF;

      -- method is candidate for decline calculations
      IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
        ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.CONDENSATE,'CURVE'));
        ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date,'CONDENSATE' , ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN

     ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_ret_val := getCurveRate(p_object_id,
                                    p_daytime,
                                    EcDp_Phase.CONDENSATE,
                                    EcDp_Curve_Purpose.PRODUCTION,
                                    lr_pwel_day_status.avg_choke_size,
                                    lr_pwel_day_status.avg_wh_press,
                                    lr_pwel_day_status.avg_wh_temp,
                                    lr_pwel_day_status.avg_bh_press,
                                    lr_pwel_day_status.annulus_press,
                                    lr_pwel_day_status.avg_wh_usc_press,
                                    lr_pwel_day_status.avg_wh_dsc_press,
                                    lr_pwel_day_status.bs_w,
                                    lr_pwel_day_status.avg_dh_pump_speed,
                                    lr_pwel_day_status.avg_gl_choke,
                                    lr_pwel_day_status.avg_gl_press,
                                    getGasLiftStdRateDay(p_object_id, p_daytime, lr_well_version.gas_lift_method),
                                    lr_pwel_day_status.avg_gl_diff_press,
                                    lr_pwel_day_status.avg_flow_mass,
                                    lr_pwel_day_status.phase_current,
                                    lr_pwel_day_status.ac_frequency,
                                    lr_pwel_day_status.intake_press,
                                    lr_pwel_day_status.avg_mpm_oil_rate,
                                    lr_pwel_day_status.avg_mpm_gas_rate,
                                    lr_pwel_day_status.avg_mpm_water_rate,
                                    lr_pwel_day_status.avg_mpm_cond_rate,
                                    lr_pwel_day_status.avg_dh_pump_power,
                                    lr_pwel_day_status.avg_dp_venturi,
                                    NULL,
                                    lv2_calc_method);

         ln_ret_val := ln_ret_val * ln_on_strm_ratio;

      ELSIF ln_on_strm_ratio = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

      -- method is candidate for decline calculations
      IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.CONDENSATE,'CURVE_LIQUID'));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date,'CONDENSATE' , ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.POTENTIAL_DEFERED) THEN
      lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ld_end_daytime := ld_start_daytime + 1;

      IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
         IF ec_pwel_period_status.active_well_status(p_object_id,ld_start_daytime,'EVENT','<=') = 'CLOSED_LT' THEN
            ln_ret_val := 0;
         ELSE
         ln_ret_val := ecbp_well_potential.findConProductionPotential(p_object_id, p_daytime, lr_well_version.potential_method, p_decline_flag)
            - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'COND');
         END IF;

      ELSIF (lv2_def_version = 'PD.0020') THEN
         -- get on strm from active status, its used several times here.
         ln_pwel_on_strm := ecdp_well.getPwelPeriodOnStrmFromStatus(p_object_id,ld_start_daytime,ld_end_daytime);
         -- if well has active_well_status<>OPEN for the whole day, then simply return 0 because there cannot be any deferment when well is not active.
         IF ln_pwel_on_strm = 0 THEN
            ln_ret_val := 0;
         ELSE
            ln_ret_val := (ecbp_well_potential.findConProductionPotential(p_object_id, p_daytime, lr_well_version.potential_method,p_decline_flag) *
                           ln_pwel_on_strm /
                           Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime)
                          ) - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'COND');
            -- since theoretical is calcualted as ("potential" * "open faction") - "deferred" we can easily get rounding problems when the well is closed or deferred the whole day.
            -- therefore, we can apply rounding to the result if the result is very close to zero.
            IF (ln_ret_val < 0.001 AND ln_ret_val > -0.001) THEN
               ln_ret_val := 0;
            END IF;
         END IF;
      ELSE -- undefined
        ln_ret_val := NULL;
      END IF;

    ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ld_end_daytime := ld_start_daytime + 1;
      lb_first := TRUE;
      ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
      ld_next_eff_daytime := ld_start_daytime;
      ln_ret_val := 0;

      WHILE ld_next_eff_daytime < ld_end_daytime LOOP

        ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
        ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

        ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
        ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
        ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

        IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
           ln_ret_val := NULL;
           EXIT;
        ELSE
           ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
        END IF;

        -- find start of next period
        ld_next_eff_daytime := LEAST(
                                     LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                     ld_end_daytime);

        -- find well on stream fraction (part of current period)
        ln_on_strm_ratio  := EcDp_Well.getPwelPeriodOnStrmFromStatus(p_object_id,GREATEST(ld_eff_daytime,ld_start_daytime),ld_next_eff_daytime)/24;

        IF ln_on_strm_ratio > 0 THEN

           IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
              lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
              ln_vol_rate := lr_pwel_result.net_cond_rate_adj;

           ELSE -- Use well production estimate for this period
              lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
              ln_vol_rate := Nvl(lr_well_event_row.cond_rate, lr_well_event_row.gas_rate * lr_well_event_row.cgr);

           END IF;

           IF lb_first THEN
              ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
              lb_first := FALSE;
           ELSE
              ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
           END IF;
        ELSE
          ln_ret_val := ln_ret_val;
        END IF;

        ld_eff_daytime := ld_next_eff_daytime;

      END LOOP;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.GAS_CGR) THEN
      ln_gas_rate := getGasStdRateDay(p_object_id, p_daytime, lr_well_version.calc_gas_method, p_decline_flag);
      IF ln_gas_rate > 0 THEN
        ln_ret_val := ln_gas_rate * findCondGasRatio(p_object_id, p_daytime, lr_well_version.cgr_method, p_decline_flag,'PWEL_DAY_STATUS');
      ELSIF ln_gas_rate = 0 THEN
        ln_ret_val := 0;
      ELSE
        ln_ret_val:= NULL;
      END IF;

    ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_EVENT_THEOR AND lr_well_version.CALC_EVENT_COND_METHOD = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      SELECT MAX(we.daytime) INTO ld_last_event_prior_prod_day
      FROM well_event we
      WHERE we.event_type = 'WELL_EVENT_SINGLE'
      AND we.object_id = p_object_id
      AND we.event_day = p_daytime
      ORDER BY we.daytime DESC;

       IF (ld_last_event_prior_prod_day IS NOT NULL) THEN
            lb_multiple_event:=TRUE;
       END IF;

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,NVL(ld_last_event_prior_prod_day,p_daytime))/24;
         ld_start_daytime := TRUNC(NVL(ld_last_event_prior_prod_day,p_daytime)) + ln_prod_day_offset;
         ld_end_daytime := ld_start_daytime + 1;
         ld_eff_daytime := ld_start_daytime;
         lb_first := TRUE;
         ln_ret_val := 0;

         WHILE ld_eff_daytime < ld_end_daytime LOOP

            ld_eff_daytime := NVL(EcDp_Well_Event.getLastWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_start_daytime);
            ld_eff_daytime := GREATEST(ld_eff_daytime, ld_start_daytime);

            IF(lb_multiple_event) THEN
             ln_on_strm_ratio  := EcDp_Well.getPwelEventOnStreamsHrs(p_object_id,ld_eff_daytime)/24;
            ELSE
             ln_on_strm_ratio  := EcDp_Well.getPwelOnStreamHrs(p_object_id,ld_eff_daytime)/24;
            END IF;


             IF ln_on_strm_ratio > 0 THEN
                  lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'WELL_EVENT_SINGLE',ld_eff_daytime);
                  ln_vol_rate := NVL(EcBp_Well_Theoretical.getCondStdRateEvent(p_object_id, ld_eff_daytime),lr_well_event_row.grs_oil_rate*(1-lr_well_event_row.bs_w));

               IF lb_first THEN
                 ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
                 lb_first := FALSE;
               ELSE
                 ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
               END IF;
             ELSE
                 ln_ret_val := ln_ret_val;
             END IF;

             ld_eff_daytime := NVL(EcDp_Well_Event.getNextWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_end_daytime);

          END LOOP;

   --user exit
   ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_EVENT_THEOR AND lr_well_version.CALC_EVENT_COND_METHOD = EcDp_Calc_Method.USER_EXIT) THEN
    SELECT MAX(we.daytime) INTO ld_last_event_prior_prod_day
      FROM well_event we
      WHERE we.event_type = 'WELL_EVENT_SINGLE'
      AND we.object_id = p_object_id
      AND we.event_day = p_daytime
      ORDER BY we.daytime DESC;

       IF (ld_last_event_prior_prod_day IS NOT NULL) THEN
            lb_multiple_event:=TRUE;
       END IF;

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,NVL(ld_last_event_prior_prod_day,p_daytime))/24;
         ld_start_daytime := TRUNC(NVL(ld_last_event_prior_prod_day,p_daytime)) + ln_prod_day_offset;
         ld_end_daytime := ld_start_daytime + 1;
         ld_eff_daytime := ld_start_daytime;
         lb_first := TRUE;
         ln_ret_val := 0;

         WHILE ld_eff_daytime < ld_end_daytime LOOP

            ld_eff_daytime := NVL(EcDp_Well_Event.getLastWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_start_daytime);
            ld_eff_daytime := GREATEST(ld_eff_daytime, ld_start_daytime);

            IF(lb_multiple_event) THEN
             ln_on_strm_ratio  := EcDp_Well.getPwelEventOnStreamsHrs(p_object_id,ld_eff_daytime)/24;
            ELSE
             ln_on_strm_ratio  := EcDp_Well.getPwelOnStreamHrs(p_object_id,ld_eff_daytime)/24;
            END IF;


             IF ln_on_strm_ratio > 0 THEN
                  lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'WELL_EVENT_SINGLE',ld_eff_daytime);
                  ln_vol_rate := NVL(Ue_Well_Theoretical.getCondStdRateEvent(p_object_id, ld_eff_daytime),lr_well_event_row.grs_oil_rate*(1-lr_well_event_row.bs_w));

               IF lb_first THEN
                 ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
                 lb_first := FALSE;
               ELSE
                 ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
               END IF;
             ELSE
                 ln_ret_val := ln_ret_val;
             END IF;

             ld_eff_daytime := NVL(EcDp_Well_Event.getNextWellEventSingleDaytime(p_object_id,ld_eff_daytime), ld_end_daytime);

          END LOOP;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_CORR) THEN

       ln_result_no := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,p_daytime);
       ln_meter_corr := ec_pwel_result.meter1_factor_hcliq(p_object_id, ln_result_no);
       ln_ret_val := ln_meter_corr * ec_pwel_day_status.avg_mpm_cond_rate(p_object_id, p_daytime, '=');

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_CORR) THEN

       ln_result_no := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,p_daytime);
       ln_meter_corr := ec_pwel_result.meter2_factor_hcliq(p_object_id, ln_result_no);
       ln_ret_val := ln_meter_corr * ec_pwel_day_status.avg_mpm2_cond_rate(p_object_id, p_daytime, '=');

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getCondStdRateDay(
               p_object_id,
               p_daytime);
   --TOTALIZER_EVENT and TOTALIZER_EVENT_EXTRAPOLATE
   ELSIF (lv2_calc_method IN (EcDp_Calc_Method.TOTALIZER_EVENT, EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE)) THEN

   ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime,lr_well_version.on_strm_method) / 24;
   ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime)/24);
   ld_start_daytime := p_daytime + ln_prod_day_offset;

   IF ln_on_strm_ratio > 0 THEN
     ln_fraction_vol := 0;
     ln_totalizer_frac := 0;
     ln_total_fraction_vol := 0;


     IF lv2_calc_method = EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE THEN
       FOR curRec IN c_well_period_totalizer_maxday('PWEL_TOTALIZER_LIQ', ld_start_daytime) LOOP
         ld_max_daytime := curRec.Max_daytime;
       END LOOP;
       ld_start_daytime := ld_max_daytime;
     END IF ;

     -- loop to get the fraction volume based on the totalizer daily rate
     FOR cur_totalizer IN c_well_period_totalizer(ld_start_daytime) LOOP
       ln_totalizer_frac := least((cur_totalizer.end_date - ln_prod_day_offset),ld_start_daytime+1) - greatest((cur_totalizer.daytime - ln_prod_day_offset), ld_start_daytime);
       ln_fraction_vol := ln_fraction_vol + (ln_totalizer_frac * getProducedStdDailyRate(p_object_id, 'PWEL_TOTALIZER_LIQ', cur_totalizer.daytime));
     END LOOP;
     IF ln_fraction_vol > 0 THEN
       ln_ret_val :=  ln_fraction_vol * ln_on_strm_ratio;
     ELSE
       ln_ret_val := 0;
     END IF;

   ELSIF ln_on_strm_ratio = 0 THEN
     ln_ret_val := 0;

   ELSE
     ln_ret_val := NULL;
   END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.AGGR_SUB_DAY_THEOR) THEN
      ln_ret_val   := lr_pwel_day_status.sub_day_theor_cond;

      -- method is candidate for decline calculations
      IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.CONDENSATE));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'CONDENSATE', ln_ret_val);
      END IF;

   ELSIF(lv2_calc_method = EcDp_Calc_Method.MASS_DIV_DENSITY) THEN
      ln_mass_day := findCondMassDay(p_object_id,p_daytime,p_calc_method);

      lv_cond_method := Nvl (p_calc_method,ec_well_version.calc_method_mass(p_object_id,p_daytime,'<='));
            IF (lv_cond_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
               RAISE_APPLICATION_ERROR(-20604,'A loop was detected when trying to calculate Mass Day. Check Configuration.');
            END IF;

       IF ln_mass_day <> 0 THEN
         ln_stdDensity := findWatStdDensity(p_object_id,p_daytime,p_calc_method);

         IF ln_stdDensity > 0 THEN
                 ln_ret_val := ln_mass_day / ln_stdDensity;
         ELSE
                 ln_ret_val := NULL;
         END IF;

      ELSIF ln_mass_day = 0 THEN
         ln_ret_val := 0;
      ELSE
         ln_ret_val := NULL;

     END IF;

   ELSIF(lv2_calc_method = EcDp_Calc_Method.TANK_WELL) THEN

        lb_first:= TRUE;
        FOR mycur in c_tank_well(p_object_id) LOOP
           ln_closeVol := NVL(EcBp_Tank.findClosingNetVol(mycur.object_id, 'DAY_CLOSING', p_daytime),0);
           ln_openVol  := NVL(EcBp_Tank.findOpeningNetVol(mycur.object_id, 'DAY_CLOSING', p_daytime),0);
           IF lb_first THEN
             ln_ret_val := ln_closeVol - ln_openVol;
             lb_first := FALSE;
           ELSE
             ln_ret_val := ln_ret_val + ln_closeVol - ln_openVol;
           END IF;
        END LOOP;
        ln_ret_val := NVL(ln_ret_val,0) + NVL(Ecbp_Well_Theoretical.sumTruckedNetOilFromWell(p_object_id, p_daytime),0);

   ELSIF(lv2_calc_method = EcDp_Calc_Method.WELL_TANK) THEN -- method to calculate from split at the well and then applied to tank

     lb_first:= TRUE;
     FOR mycurTM IN c_tank_well(p_object_id) LOOP
        ln_closeVol := NVL(EcBp_Tank.findClosingGrsVol(mycurTM.object_id, 'DAY_CLOSING', p_daytime),0);
        ln_openVol  := NVL(EcBp_Tank.findOpeningGrsVol(mycurTM.object_id, 'DAY_CLOSING', p_daytime),0);
        IF lb_first THEN
           ln_sum:= ln_closeVol - ln_openVol;
           lb_first:= FALSE;
        ELSE
           ln_sum:= ln_sum + ln_closeVol - ln_openVol;
        END IF;
     END LOOP;
     -- get total daily emulsion production
     ln_total_daily_emul_prod := (NVL(ln_sum,0) + NVL(Ecbp_Well_Theoretical.sumTruckedNetOilFromWell(p_object_id, p_daytime),0) + NVL(Ecbp_Well_Theoretical.sumTruckedWaterFromWell(p_object_id, p_daytime),0));
     ln_ret_val := ln_total_daily_emul_prod - getWatStdRateDay(p_object_id, p_daytime);

   ELSIF(lv2_calc_method = Ecdp_Calc_Method.MEAS_SWING_WELL) THEN
     ln_ret_val := getCondStdRateDay(p_object_id, p_daytime, 'MEASURED');
     -- Add any measured swing volume (dry gas * cgr).
     IF ln_ret_val is null THEN
         -- Should always use the Wet gas metered method to find the gas
         -- Must use the specific method. If we doesn't do that it will double account the swing volumes
         ln_ret_val :=getGasStdRateDay(p_object_id, p_daytime, EcDp_Calc_Method.WET_GAS_MEASURED);
         IF ln_ret_val is not null THEN
                 ln_ret_val:= ln_ret_val * findCondGasRatio(p_object_id, p_daytime, lr_well_version.cgr_method,NULL,'PWEL_DAY_STATUS');
         END IF;
     END IF;
     FOR res_swing in c_swing_well_event(p_object_id, p_daytime) LOOP
        IF ln_dry_wet_gas_ratio is null THEN
             ln_cgr := findCondGasRatio(p_object_id, p_daytime,NULL,NULL,'PWEL_DAY_STATUS');
             ln_dry_wet_gas_ratio := findDryWetFactor(p_object_id,p_daytime); -- find the dry wet factor
             IF ln_dry_wet_gas_ratio is null then ln_dry_wet_gas_ratio := 1 / NVL(findWetDryFactor(p_object_id,p_daytime),1); END IF; -- If the dry wet ratio is null, calculate it from the wet dry ratio
        END IF;
         ln_dry_gas := res_swing.dry_gas_vol;
         ln_wet_gas := res_swing.well_wet_gas_vol;
         IF ln_dry_gas is not null or ln_wet_gas is not null THEN
           IF ln_dry_gas > 0 THEN
             ln_ret_val := ln_ret_val + ln_dry_gas * ln_cgr;
           ELSIF ln_wet_gas > 0 THEN  -- Wet gas swing volume is only added if the dry gas is measured.
             IF getGasStdRateDay(p_object_id,p_daytime,'MEASURED') is not null THEN
               -- Convert wet gas swing volume to dry gas and then add it to the volume.
               ln_ret_val := ln_ret_val + ln_wet_gas * ln_dry_wet_gas_ratio * ln_cgr;
             END IF;
           END IF;
         END IF;
     END LOOP;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM) THEN
     ln_ret_val  := lr_pwel_day_status.avg_mpm_cond_rate;
   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
     ln_ret_val  := lr_pwel_day_status.avg_mpm_cond_rate;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2) THEN
     ln_ret_val  := lr_pwel_day_status.avg_mpm2_cond_rate;
   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_NET) THEN
     ln_ret_val  := lr_pwel_day_status.avg_mpm2_cond_rate;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CONSEC_WELL_TEST) THEN
     ln_result_no := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
     ln_count_day := 1;

     SELECT NVL(NET_COND_RATE_ADJ, 0), NVL(DURATION, 0) INTO ln_volume, ln_duration
     FROM PWEL_RESULT
     WHERE RESULT_NO = ln_result_no;

     FOR cur_well_test in c_prev_well_test(p_object_id, ln_result_no) LOOP
        IF TRUNC(cur_well_test.valid_from_date) = TRUNC(ec_pwel_result.valid_from_date(p_object_id, ln_result_no) - ln_count_day) THEN
            ln_count_day := ln_count_day + 1;
            ln_volume := ln_volume + cur_well_test.net_cond_rate_adj;
            ln_duration := ln_duration + cur_well_test.duration;
        ELSE
            EXIT;
        END IF;
     END LOOP;

     ln_ret_val := (ln_volume/ln_duration) * NVL(ec_pwel_day_status.on_stream_hrs(p_object_id, p_daytime, '<='), EcDp_Well.getPwelOnStreamHrs(p_object_id, p_daytime));

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_PRIORITIZED) THEN

     ln_ret_val := EcBp_HCM_VFM.getCondStdRateDay(p_object_id, p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN

     ln_ret_val := lr_pwel_day_status.avg_vfm_cond_rate;

   ELSE
        ln_ret_val := NULL;

   END IF;

  END IF;
  END IF; -- End check if lv2_calc_method is not null

  RETURN ln_ret_val;


END getCondStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjectedStdRateDay
-- Description    : Returns theoretical injection volume for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getInjectedStdRateDay(p_object_id   well.object_id%TYPE,
                               p_inj_type    VARCHAR2,
                               p_daytime     DATE,
                               p_calc_inj_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_inj_method    VARCHAR2(32);
   lr_day_rec         iwel_day_status%ROWTYPE;
   ln_ret_val         NUMBER;
   ln_on_strm_ratio   NUMBER;
   ld_start_daytime     DATE;
   ld_end_daytime       DATE;
   lv2_phase          VARCHAR2(32);
   ln_curve_value     NUMBER;
   ln_inj_rate_value  NUMBER;
   lv2_def_version    VARCHAR2(32);
   lr_iwel_day_status IWEL_DAY_STATUS%ROWTYPE;
   lr_well_version    WELL_VERSION%ROWTYPE;

   ld_prod_day                DATE;
   ld_daytime                 DATE;
   ld_maxdaytime              DATE;
   ln_mth_inj_vol             NUMBER;
   ln_prevmth_inj_vol         NUMBER;
   ln_on_strm_mth             NUMBER;
   ln_on_strm_prevmth         NUMBER;
   ln_prod_day_offset         NUMBER;
   ln_totalizer_frac          NUMBER;
   ln_fraction_vol            NUMBER;
   lv2_class_name             VARCHAR2(32);
   ld_cur_date                DATE;
   ln_total_vol               NUMBER;
   ln_inj_rate                NUMBER;
   ln_duration_fraction       NUMBER;
   ln_total_inj_rate          NUMBER;
   ln_fraction_rate           NUMBER;
   ln_iwel_on_strm            NUMBER;
   lv2_inj_type               VARCHAR2(32);

   CURSOR c_well_period_totalizer_maxday(cp_class_name VARCHAR2, cp_daytime DATE) IS
   SELECT max(daytime) max_daytime
   FROM well_period_totalizer
   WHERE object_id = p_object_id
   AND class_name = cp_class_name
   AND (to_char(to_date(cp_daytime), 'yyyymm') between to_char(to_date(end_date), 'yyyymm') AND to_char(add_months(to_date(TRUNC(to_date(end_date), 'mm')), 1), 'yyyymm'))
   ORDER BY daytime ASC;

   CURSOR c_well_period_totalizer(cp_class_name VARCHAR2, cp_daytime DATE) IS
   SELECT *
   FROM well_period_totalizer
   WHERE object_id = p_object_id
   AND (daytime < cp_daytime+1 AND end_date > cp_daytime)
   ORDER BY daytime ASC;

   CURSOR c_well_use_in_alloc(cp_class_name VARCHAR2) IS
   SELECT * FROM
   (SELECT *
   FROM well_event wed
   WHERE wed.object_id = p_object_id
   AND wed.EVENT_DAY = p_daytime
   AND wed.use_in_alloc = 'Y'
   AND wed.EVENT_TYPE = cp_class_name
   UNION
   SELECT *
   FROM well_event we2
   WHERE we2.object_id = p_object_id
   AND we2.use_in_alloc = 'Y'
   AND we2.EVENT_TYPE = cp_class_name
   AND we2.daytime =
   (select max(daytime) from well_event we3
   WHERE we3.object_id = p_object_id
   AND we3.use_in_alloc = 'Y'
   AND we3.EVENT_TYPE = cp_class_name
   AND we3.event_day < p_daytime)
   ) ORDER BY DAYTIME ASC;

BEGIN

  lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
  lr_iwel_day_status := ec_iwel_day_status.row_by_pk(p_object_id, p_daytime, p_inj_type);

  IF (p_inj_type = Ecdp_Well_Type.GAS_INJECTOR)
  THEN
    IF (p_calc_inj_method IS NULL AND NVL(lr_well_version.allow_theor_override, 'N') = 'Y' AND lr_iwel_day_status.override_theor_gas IS NOT NULL)
    THEN
      ln_ret_val := lr_iwel_day_status.override_theor_gas;
      RETURN ln_ret_val;
    ELSE
      lv2_calc_inj_method := Nvl(p_calc_inj_method,lr_well_version.calc_inj_method);
    END IF;

  ELSIF (p_inj_type = Ecdp_Well_Type.WATER_INJECTOR)
  THEN
    IF (p_calc_inj_method IS NULL AND NVL(lr_well_version.allow_theor_override, 'N') = 'Y' AND lr_iwel_day_status.override_theor_wat IS NOT NULL)
    THEN
      ln_ret_val := lr_iwel_day_status.override_theor_wat;
      RETURN ln_ret_val;
    ELSE
      lv2_calc_inj_method := Nvl(p_calc_inj_method,lr_well_version.calc_water_inj_method);
    END IF;

  ELSIF (p_inj_type = Ecdp_Well_Type.STEAM_INJECTOR)
  THEN
    IF (p_calc_inj_method IS NULL AND NVL(lr_well_version.allow_theor_override, 'N') = 'Y' AND lr_iwel_day_status.override_theor_steam IS NOT NULL)
    THEN
      ln_ret_val := lr_iwel_day_status.override_theor_steam;
      RETURN ln_ret_val;
    ELSE
      lv2_calc_inj_method := Nvl(p_calc_inj_method, lr_well_version.calc_steam_inj_method);
    END IF;

  ELSIF (p_inj_type = Ecdp_Well_Type.CO2_INJECTOR)
  THEN
    IF (p_calc_inj_method IS NULL AND NVL(lr_well_version.allow_theor_override, 'N') = 'Y' AND lr_iwel_day_status.override_theor_co2 IS NOT NULL)
    THEN
      ln_ret_val := lr_iwel_day_status.override_theor_co2;
      RETURN ln_ret_val;
    ELSE
      lv2_calc_inj_method := Nvl(p_calc_inj_method, ec_well_version.calc_co2_inj_method(p_object_id, p_daytime, '<='));
    END IF;
  END IF;


  IF (substr(lv2_calc_inj_method,1,9) = 'CURVE_INJ') THEN
    ln_on_strm_ratio := EcDp_Well.getIwelOnStreamHrs(p_object_id,p_inj_type,p_daytime,lr_well_version.on_strm_method) / 24;

    IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

      IF (p_inj_type = EcDp_Well_Type.WATER_INJECTOR) THEN
        lv2_phase := EcDp_Phase.WATER;
      ELSIF (p_inj_type = EcDp_Well_Type.GAS_INJECTOR) THEN
        lv2_phase := EcDp_Phase.GAS;
      END IF;

      lr_day_rec := ec_iwel_day_status.row_by_pk(p_object_id, p_daytime, p_inj_type);
      ln_curve_value := getCurveRate(p_object_id,
                                     p_daytime,
                                     lv2_phase,
                                     EcDp_Curve_Purpose.INJECTION,
                                     lr_day_rec.avg_choke_size,
                                     lr_day_rec.avg_wh_press,
                                     lr_day_rec.avg_wh_temp,
                                     lr_day_rec.avg_bh_press,
                                     lr_day_rec.avg_annulus_press,
                                     lr_day_rec.avg_wh_usc_press,
                                     lr_day_rec.avg_wh_dsc_press,
                                     NULL, --injectors do not have bs_w
                                     NULL, --injectors do not have dh pumps
                                     NULL, --injectors do not have gas lift
                                     NULL, --injectors do not have gas lift
                                     NULL, --injectors do not have gas lift
                                     NULL,  --injectors do not have gas lift
                                     NULL, -- avg_flow_mass,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     lr_day_rec.avg_dp_venturi,
                                     NULL,
                                     lv2_calc_inj_method);

      ln_ret_val := ln_curve_value * ln_on_strm_ratio;

    ELSIF ln_on_strm_ratio = 0 THEN
      ln_ret_val := 0;

    ELSE
      ln_ret_val := NULL;
    END IF;

  ELSIF (lv2_calc_inj_method = Ecdp_Calc_Method.MEASURED) THEN
    lr_day_rec := ec_iwel_day_status.row_by_pk(p_object_id, p_daytime, p_inj_type);
    IF NOT(lr_day_rec.inj_vol IS NULL AND lr_day_rec.inj_vol_2 IS NULL) THEN
      ln_ret_val := NVL(lr_day_rec.inj_vol,0) + NVL(lr_day_rec.inj_vol_2,0);
    END IF;

  ELSIF (substr(lv2_calc_inj_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Well_Theoretical.getInjectedStdRateDay(
                    p_object_id,
                    p_inj_type,
                    p_daytime);

  ELSIF (lv2_calc_inj_method = EcDp_Calc_Method.POTENTIAL_DEFERED) THEN

    lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
    ld_start_daytime := p_daytime + ln_prod_day_offset;
    ld_end_daytime := ld_start_daytime + 1;

    IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
      IF Ecdp_Well.IsWellNotClosedLT (p_object_id, ld_start_daytime) = 'N' THEN
        ln_ret_val := 0;
      ELSE
        IF (p_inj_type = EcDp_Well_Type.WATER_INJECTOR) THEN
          ln_ret_val := ecbp_well_potential.findWatInjectionPotential(p_object_id, p_daytime,lr_well_version.pot_water_inj_method )
                        - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'WAT_INJ');

        ELSIF (p_inj_type = EcDp_Well_Type.STEAM_INJECTOR) THEN
          ln_ret_val := ecbp_well_potential.findSteamInjectionPotential(p_object_id, p_daytime,lr_well_version.pot_steam_inj_method)
                        - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'STEAM');

        ELSIF (p_inj_type = EcDp_Well_Type.GAS_INJECTOR) THEN
          ln_ret_val := ecbp_well_potential.findGasInjectionPotential(p_object_id, p_daytime,lr_well_version.potential_gas_inj_method)
                        - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'GAS_INJ');

        END IF;
      END IF;

    ELSIF (lv2_def_version = 'PD.0020') THEN

       IF (p_inj_type = EcDp_Well_Type.WATER_INJECTOR) THEN
          ln_iwel_on_strm := ecdp_well.getIwelPeriodOnStrmFromStatus(p_object_id,'WI',ld_start_daytime,ld_end_daytime);
          IF ln_iwel_on_strm = 0 THEN
            ln_ret_val := 0;
          ELSE
            ln_ret_val := ecbp_well_potential.findWatInjectionPotential(p_object_id, p_daytime, lr_well_version.pot_water_inj_method) * ln_iwel_on_strm /Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime)
                                              - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'WAT_INJ');
          END IF;

       ELSIF (p_inj_type = EcDp_Well_Type.STEAM_INJECTOR) THEN
          ln_iwel_on_strm := ecdp_well.getIwelPeriodOnStrmFromStatus(p_object_id,'SI',ld_start_daytime,ld_end_daytime);
          IF ln_iwel_on_strm = 0 THEN
            ln_ret_val := 0;
          ELSE
            ln_ret_val := ecbp_well_potential.findSteamInjectionPotential(p_object_id, p_daytime, lr_well_version.pot_steam_inj_method) * ln_iwel_on_strm /Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime)
                                              - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'STEAM');
          END IF;

       ELSIF (p_inj_type = EcDp_Well_Type.GAS_INJECTOR) THEN
          ln_iwel_on_strm := ecdp_well.getIwelPeriodOnStrmFromStatus(p_object_id,'GI',ld_start_daytime,ld_end_daytime);
          IF ln_iwel_on_strm = 0 THEN
            ln_ret_val := 0;
          ELSE
            ln_ret_val := ecbp_well_potential.findGasInjectionPotential(p_object_id, p_daytime, lr_well_version.potential_gas_inj_method) * ln_iwel_on_strm /Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime)
                                              - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'GAS_INJ');
          END IF;
       END IF;
          -- since theoretical is calcualted as ("potential" * "open faction") - "deferred" we can easily get rounding problems when the well is closed or deferred the whole day.
          -- therefore, we can apply rounding to the result if the result is very close to zero.
       IF (ln_ret_val < 0.001 AND ln_ret_val > -0.001) THEN
          ln_ret_val := 0;
       END IF;

    ELSE -- undefined
       ln_ret_val := NULL;
    END IF;

  ELSIF (lv2_calc_inj_method = Ecdp_Calc_Method.LAST_RATE_AND_ONTIME) THEN
      ln_on_strm_ratio := EcDp_Well.getIwelOnStreamHrs(p_object_id,p_inj_type,p_daytime,lr_well_version.on_strm_method) / 24;

      IF ln_on_strm_ratio > 0 THEN
        ln_inj_rate_value := getLastNotNullInjRate(p_object_id, p_daytime, p_inj_type);
        ln_ret_val := ln_inj_rate_value * ln_on_strm_ratio;

      ELSIF ln_on_strm_ratio = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;

      END IF;

  ELSIF (lv2_calc_inj_method = Ecdp_Calc_Method.MEASURED_MTH) THEN

      ln_on_strm_ratio := EcDp_Well.getIwelOnStreamHrs(p_object_id,p_inj_type,p_daytime,lr_well_version.on_strm_method) / 24;
      ln_mth_inj_vol := ec_iwel_mth_status.inj_vol(p_object_id,TRUNC(p_daytime,'MM'),p_inj_type);
      ln_on_strm_mth := Ecdp_Well.calcOnStrmDaysInMonth(p_object_id,p_inj_type,TRUNC(p_daytime,'MM'));

      IF ln_on_strm_mth > 0 THEN
        IF ln_on_strm_ratio > 0 THEN
          ln_ret_val := ln_on_strm_ratio * ln_mth_inj_vol / ln_on_strm_mth;

        ELSIF ln_on_strm_ratio = 0 THEN
          ln_ret_val := 0;

        ELSE
          ln_ret_val := NULL;
        END IF;
      ELSE
        ln_ret_val := null;
      END IF;

  ELSIF (lv2_calc_inj_method = Ecdp_Calc_Method.MEASURED_MTH_XTPL_DAY) THEN

      ln_mth_inj_vol := ec_iwel_mth_status.inj_vol(p_object_id,TRUNC(p_daytime,'MM'),p_inj_type);
      ln_on_strm_ratio := EcDp_Well.getIwelOnStreamHrs(p_object_id,p_inj_type,p_daytime,lr_well_version.on_strm_method) / 24;

      IF ln_mth_inj_vol IS NOT NULL THEN
        -- return actual values based on current month
        ln_on_strm_mth := Ecdp_Well.calcOnStrmDaysInMonth(p_object_id,p_inj_type,TRUNC(p_daytime,'MM'));
        IF ln_on_strm_mth > 0 THEN
          IF ln_on_strm_ratio > 0 THEN
             ln_ret_val := ln_on_strm_ratio * ln_mth_inj_vol / ln_on_strm_mth;

          ELSIF ln_on_strm_ratio = 0 THEN
            ln_ret_val := 0;

          ELSE
            ln_ret_val := NULL;
          END IF;
        ELSE
          ln_ret_val := null;
        END IF;
      ELSE
        -- return extrapolate values based on prev month
        ln_prevmth_inj_vol := ec_iwel_mth_status.inj_vol(p_object_id,TRUNC(add_months(p_daytime,-1),'MM'),p_inj_type);
        ln_on_strm_prevmth := Ecdp_Well.calcOnStrmDaysInMonth(p_object_id,p_inj_type,TRUNC(add_months(p_daytime,-1),'MM'));
        IF ln_on_strm_prevmth > 0 THEN
          IF ln_on_strm_ratio > 0 THEN
            ln_ret_val := ln_on_strm_ratio * ln_prevmth_inj_vol / ln_on_strm_prevmth;

          ELSIF ln_on_strm_ratio = 0 THEN
            ln_ret_val := 0;

          ELSE
            ln_ret_val := NULL;
          END IF;
        ELSE
          ln_ret_val := null;
        END IF;
      END IF;

  ELSIF (lv2_calc_inj_method IN (EcDp_Calc_Method.TOTALIZER_EVENT, EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE)) THEN

     ln_on_strm_ratio := EcDp_Well.getIwelOnStreamHrs(p_object_id,p_inj_type,p_daytime,lr_well_version.on_strm_method) / 24;
     ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime)/24);
     ld_daytime := p_daytime + ln_prod_day_offset;

     IF ln_on_strm_ratio > 0 THEN
       IF (p_inj_type = EcDp_Well_Type.WATER_INJECTOR) THEN
         lv2_class_name := 'IWEL_TOTALIZER_WAT';
       ELSIF (p_inj_type = EcDp_Well_Type.GAS_INJECTOR) THEN
         lv2_class_name := 'IWEL_TOTALIZER_GAS';
       END IF;

       ln_fraction_vol := 0;
       ln_totalizer_frac := 0;

       IF lv2_calc_inj_method = EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE THEN
         FOR curRec IN c_well_period_totalizer_maxday(lv2_class_name, ld_daytime) LOOP
           ld_maxdaytime := curRec.Max_daytime;
         END LOOP;
         ld_daytime := ld_maxdaytime;
       END IF ;

       FOR curTotalizer IN c_well_period_totalizer(lv2_class_name, ld_daytime) LOOP
         ln_totalizer_frac := least((curTotalizer.end_date - ln_prod_day_offset), ld_daytime+1) - greatest((curTotalizer.daytime - ln_prod_day_offset), ld_daytime);
         ln_fraction_vol := ln_fraction_vol  + (ln_totalizer_frac * getInjectedStdDailyRate(p_object_id, lv2_class_name, curTotalizer.daytime));
       END LOOP;

       IF ln_fraction_vol > 0 THEN
         ln_ret_val :=  ln_fraction_vol * ln_on_strm_ratio;
       ELSE
         ln_ret_val := null;
       END IF;

     ELSIF ln_on_strm_ratio = 0 THEN
       ln_ret_val := 0;

     ELSE
       ln_ret_val := NULL;
     END IF;

  ELSIF (lv2_calc_inj_method = Ecdp_Calc_Method.EVENT_INJ_DATA) THEN

     ln_on_strm_ratio := EcDp_Well.getIwelOnStreamHrs(p_object_id,p_inj_type,p_daytime,lr_well_version.on_strm_method) / 24;

     IF (p_inj_type = Ecdp_Well_Type.GAS_INJECTOR) THEN
       lv2_class_name := 'IWEL_EVENT_GAS';
     ELSIF (p_inj_type = Ecdp_Well_Type.WATER_INJECTOR) THEN
       lv2_class_name := 'IWEL_EVENT_WATER';
     ELSIF (p_inj_type = Ecdp_Well_Type.STEAM_INJECTOR) THEN
       lv2_class_name := 'IWEL_EVENT_STEAM';
     END IF;

     ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime)/24);
     -- ld_daytime is the production day adjusted for production day offset. This can be compared directly with the records daytime.
     ld_daytime := p_daytime + ln_prod_day_offset;
     ln_fraction_rate     := 0;
     ln_duration_fraction := 0;

     -- only worth calculating if well is open parts of the day.
     IF ln_on_strm_ratio > 0 THEN
       -- the cursor is sorted by daytime ASC where the first record is less than production day start.
       FOR cur_rate IN c_well_use_in_alloc(lv2_class_name) LOOP
         -- get the inj rate of the last record registered for this record which is used in alloc.
         IF (cur_rate.event_day < p_daytime) THEN           ln_inj_rate := cur_rate.avg_inj_rate;
         ELSE
           -- the fraction of this record is the record daytime minus previous record daytime or start of production day if not previous records
           ln_duration_fraction := cur_rate.daytime - NVL(ld_cur_date, ld_daytime);
           ln_fraction_rate     := ln_fraction_rate +  (ln_duration_fraction * NVL( ln_inj_rate,0));
           ld_cur_date          := cur_rate.daytime;
           ln_inj_rate          := cur_rate.avg_inj_rate;
         END IF;
       END LOOP;
       -- add the remaining part of the production day (last record in prod day until end of production day)
       ln_total_inj_rate :=  ln_fraction_rate    + (((ld_daytime + 1) - NVL(ld_cur_date,ld_daytime)) *  ln_inj_rate);

       -- finally; adjust for well on_time.
       IF  ln_total_inj_rate is not null THEN
         ln_ret_val :=  ln_total_inj_rate * ln_on_strm_ratio;
       ELSE
         ln_ret_val := null;
       END IF;

     ELSIF ln_on_strm_ratio = 0 THEN
       ln_ret_val := 0;
     ELSE
       ln_ret_val := NULL;
     END IF;

  END IF;
  RETURN ln_ret_val;

END getInjectedStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDiluentStdRateDay
-- Description    : Returns theoretical diluent volume for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDiluentStdRateDay(p_object_id        VARCHAR2,
                              p_daytime          DATE,
                              p_diluent_method   VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_diluent_method  VARCHAR2(32);
   lv2_def_version     VARCHAR2(32);

   lr_day_rec          PWEL_DAY_STATUS%ROWTYPE;
   lr_well_event_row   WELL_EVENT%ROWTYPE;
   lr_pwel_result      PWEL_RESULT%ROWTYPE;

   lb_first              BOOLEAN;

   ln_prev_test_no       NUMBER;
   ln_vol_rate           NUMBER;
   ln_ret_val            NUMBER;
   ln_prod_day_offset    NUMBER;
   ln_on_strm_ratio      NUMBER;

   ld_end_daytime           DATE;
   ld_start_daytime         DATE;
   ld_eff_daytime           DATE;
   ld_next_eff_daytime      DATE;
   ld_prev_estimate         DATE;
   ld_next_estimate         DATE;
   ld_prev_test             DATE;
   ld_next_test             DATE;

   ld_prod_day                DATE;

BEGIN

   lv2_diluent_method := Nvl(p_diluent_method,ec_well_version.diluent_method(p_object_id,p_daytime,'<='));

   IF (lv2_diluent_method = EcDp_Calc_Method.MEASURED) THEN
      lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id,p_daytime);
      ln_ret_val := lr_day_rec.avg_diluent_rate;

   ELSIF (lv2_diluent_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ld_end_daytime := ld_start_daytime + 1;
      lb_first := TRUE;
      ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
      ld_next_eff_daytime := ld_start_daytime;
      ln_ret_val := 0;

      WHILE ld_next_eff_daytime < ld_end_daytime LOOP

         ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
         ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

         ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
         ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
         ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

         IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
            ln_ret_val := NULL;
            EXIT;
         ELSE
            ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
         END IF;

         -- find start of next period
         ld_next_eff_daytime := LEAST(
                                      LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                     ld_end_daytime);

         -- find well on stream fraction (part of current period)
         ln_on_strm_ratio  := EcDp_Well.getPwelPeriodOnStrmFromStatus(p_object_id,GREATEST(ld_eff_daytime,ld_start_daytime),ld_next_eff_daytime)/24;

         IF ln_on_strm_ratio > 0 THEN
           IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
              lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
              ln_vol_rate := lr_pwel_result.diluent_rate;

           ELSE -- Use well production estimate for this period
              lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
              ln_vol_rate := lr_well_event_row.diluent_rate;

           END IF;

           IF lb_first THEN
             ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
             lb_first := FALSE;
           ELSE
             ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
           END IF;
       ELSE
         ln_ret_val := ln_ret_val;
     END IF;

         ld_eff_daytime := ld_next_eff_daytime;

      END LOOP;

   ELSIF (lv2_diluent_method = EcDp_Calc_Method.POTENTIAL_DEFERED) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ld_end_daytime := ld_start_daytime + 1;

      ln_on_strm_ratio  :=  ecdp_well.getPwelPeriodOnStrmFromStatus(p_object_id,ld_start_daytime,ld_end_daytime)/Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
         lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');

         IF (lv2_def_version = 'PD.0020') THEN -- only PD.0020 are supported
            ln_ret_val := (ecbp_well_potential.findDiluentPotential(p_object_id, p_daytime) * ln_on_strm_ratio) - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'DILUENT');

         ELSE
            ln_ret_val := NULL;

         END IF;

      ELSIF ln_on_strm_ratio = 0 THEN
         ln_ret_val := 0;

      ELSE
         ln_ret_val := NULL;
      END IF;

   ELSIF (lv2_diluent_method = EcDp_Calc_Method.AGGR_SUB_DAY_THEOR) THEN
      lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id,p_daytime);
      ln_ret_val := lr_day_rec.sub_day_theor_diluent;

   ELSIF (substr(lv2_diluent_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getDiluentStdRateDay(
               p_object_id,
               p_daytime);

   ELSE -- undefined
      ln_ret_val := NULL;
   END IF;

   RETURN ln_ret_val;

END getDiluentStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCO2StdRateDay
-- Description    : Returns theoretical CO2 volume for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCO2StdRateDay(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL,
                          p_decline_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method       VARCHAR2(32);
   lv2_decline_flag      VARCHAR2(32);

   lr_pwel_result   PWEL_RESULT%ROWTYPE;
   lr_well_version       WELL_VERSION%ROWTYPE;

   ln_ret_val            NUMBER;
   ln_on_stream_frac     NUMBER;
   ln_prod_day_offset    NUMBER;


   ld_start_daytime      DATE;
   ld_from_date          DATE;

BEGIN
-- calc_co2_method
   lr_well_version  := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_calc_method  := Nvl(p_calc_method, lr_well_version.calc_co2_method);
   lv2_decline_flag := Nvl(p_decline_flag, NVL(lr_well_version.decline_flag, 'N'));

   -- calculate CO2 volume as Gas * CO2% from
   IF (lv2_calc_method = EcDp_Calc_Method.CO2_REF_VALUE) THEN
      ln_ret_val := getGasStdRateDay(p_object_id, p_daytime, NULL, lv2_decline_flag, 'N') -- the 'N' to avoid that the function calls this function (loop)
                  * ec_well_reference_value.co2_fraction(p_object_id, p_daytime, '<=');

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_on_stream_frac := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_stream_frac > 0 THEN -- Only worth doing calculation when the well is up

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         ln_ret_val := getGasStdRateDay(p_object_id, p_daytime, NULL, lv2_decline_flag, 'N');

         -- decline calculations for gas
         IF (lv2_decline_flag = 'Y' AND ln_ret_val > 0) THEN
            lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
            ld_from_date := lr_pwel_result.valid_from_date;
            ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'GAS', ln_ret_val);
         END IF;

         -- calc CO2 as Gas Volume * CO2 fraction from latest well test.
         ln_ret_val := ln_ret_val * EcDp_Well_Estimate.getLastCO2Fraction(p_object_id, ld_start_daytime);

      ELSIF ln_on_stream_frac = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

   ELSIF lv2_calc_method = EcDp_Calc_Method.USER_EXIT THEN
      ln_ret_val := Ue_Well_Theoretical.getCO2StdRateDay(
               p_object_id,
               p_daytime);
   END IF;

   RETURN ln_ret_val;

END getCO2StdRateDay;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasLiftStdRateDay
-- Description    : Returns theoretical gaslift volume for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGasLiftStdRateDay(p_object_id     well.object_id%TYPE,
                              p_daytime       DATE,
                              p_gas_lift_method   VARCHAR2 DEFAULT NULL )
RETURN NUMBER
--</EC-DOC>
IS
   lv2_gas_lift_method   VARCHAR2(32);
   lv2_def_version       VARCHAR2(32);
   lv2_gl_source         VARCHAR2(32);

   lr_day_rec            PWEL_DAY_STATUS%ROWTYPE;
   lr_result_rec         pwel_result%ROWTYPE;
   lr_well_event_row     WELL_EVENT%ROWTYPE;
   lb_first              BOOLEAN;
   lr_pwel_result   PWEL_RESULT%ROWTYPE;

   ld_end_daytime        DATE;
   ld_start_daytime      DATE;
   ld_prev_period_start  DATE;
   ld_eff_daytime        DATE;
   ld_next_eff_daytime   DATE;
   ld_prev_estimate      DATE;
   ld_next_estimate      DATE;
   ld_prev_test          DATE;
   ld_next_test          DATE;

   ln_ret_val            NUMBER;
   ln_on_strm_ratio      NUMBER;
   ln_pump_speed_ratio   NUMBER;
   ln_test_pump_speed    NUMBER;
   ln_prod_day_offset    NUMBER;
   ln_prev_test_no       NUMBER;
   ln_vol_rate           NUMBER;
   ln_result_no          NUMBER;
   ln_meter_corr         NUMBER;
   ln_gl_corr            NUMBER;
   ln_gl_well_meas       NUMBER;
   ln_gl_total           NUMBER;

   ld_prod_day           DATE;


BEGIN

   lv2_gas_lift_method := NVL(p_gas_lift_method,
                              ec_well_version.gas_lift_method(p_object_id,
                                                              p_daytime,
                                                              '<='));

   IF (lv2_gas_lift_method = EcDp_Calc_Method.MEASURED) THEN
      lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_day_rec.avg_gl_rate;

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.CURVE_GAS_LIFT) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
         ln_ret_val := getCurveRate(p_object_id,
                                    p_daytime,
                                    'GAS',
                                    'GAS_LIFT',
                                    NULL, -- well choke not relevant input
                                    NULL, -- wh press not relevant input
                                    NULL, -- wh temp not relevant input
                                    NULL, -- bh press not relevant input
                                    lr_day_rec.annulus_press,
                                    NULL, -- wh usc pressnot relevant input
                                    NULL, -- wh dsc pressnot relevant input
                                    NULL, -- well bs_w not relevant input
                                    NULL, -- dh_pump_speed not relevant input
                                    lr_day_rec.avg_gl_choke,
                                    lr_day_rec.avg_gl_press,
                                    NULL, -- gl_rate not relevant input
                                    lr_day_rec.avg_gl_diff_press,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    lr_day_rec.avg_dp_venturi,
                                    NULL,
                                    lv2_gas_lift_method);

         ln_ret_val := ln_ret_val * ln_on_strm_ratio;

      ELSIF ln_on_strm_ratio = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         lr_result_rec := EcDp_Performance_Test.getLastValidWellResult(p_object_id, ld_start_daytime);

         ln_ret_val := lr_result_rec.gl_rate * ln_on_strm_ratio;

      ELSIF ln_on_strm_ratio = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.WELL_EST_DETAIL_DEFERRED) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

        ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
        ld_start_daytime := p_daytime + ln_prod_day_offset;

        lr_result_rec := EcDp_Performance_Test.getLastValidWellResult(p_object_id, ld_start_daytime);

        ln_ret_val := (lr_result_rec.gl_rate * ln_on_strm_ratio)
              - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'GAS_LIFT');

      ELSIF ln_on_strm_ratio = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ld_end_daytime := ld_start_daytime + 1;
      lb_first := TRUE;
      ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
      ld_next_eff_daytime := ld_start_daytime;
      ln_ret_val := 0;

      WHILE ld_next_eff_daytime < ld_end_daytime LOOP

         ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
         ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

         ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
         ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
         ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

         IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
            ln_ret_val := NULL;
            EXIT;
         ELSE
            ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
         END IF;

         -- find start of next period
         ld_next_eff_daytime := LEAST(
                                      LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                     ld_end_daytime);

         -- find well on stream fraction (part of current period)
         ln_on_strm_ratio  := EcDp_Well.getPwelPeriodOnStrmFromStatus(p_object_id,GREATEST(ld_eff_daytime,ld_start_daytime),ld_next_eff_daytime)/24;

     IF ln_on_strm_ratio > 0 THEN
           IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
              lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
              ln_vol_rate := lr_pwel_result.gl_rate;

           ELSE -- Use well production estimate for this period
              lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
              ln_vol_rate := lr_well_event_row.gl_rate;

           END IF;


           IF lb_first THEN
             ln_ret_val := ln_vol_rate * ln_on_strm_ratio;
             lb_first := FALSE;
           ELSE
             ln_ret_val := ln_ret_val + (ln_vol_rate * ln_on_strm_ratio);
           END IF;
     ELSE
       ln_ret_val := ln_ret_val;
     END IF;

         ld_eff_daytime := ld_next_eff_daytime;

      END LOOP;

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.POTENTIAL_DEFERED) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ld_end_daytime := ld_start_daytime + 1;

      ln_on_strm_ratio  :=  ecdp_well.getPwelPeriodOnStrmFromStatus(p_object_id,ld_start_daytime,ld_end_daytime)/Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
        lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
        IF (lv2_def_version = 'PD.0020') THEN
           ln_ret_val := (EcBp_well_potential.findGasLiftPotential(p_object_id, p_daytime) * ln_on_strm_ratio) - ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'GAS_LIFT');
        ELSE -- only PD.0020 are supported
           ln_ret_val := NULL;

        END IF;

      ELSIF ln_on_strm_ratio = 0 THEN
        ln_ret_val := 0;

      ELSE
        ln_ret_val := NULL;
      END IF;

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.AGGR_SUB_DAY_THEOR) THEN
      lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_day_rec.sub_day_theor_gas_lift;

   ELSIF  lv2_gas_lift_method = EcDp_Calc_Method.PREALLOC_MEAS_GL THEN
      ln_result_no := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,p_daytime);
      ln_meter_corr := NVL(ec_pwel_result.meter1_factor_gl(p_object_id, ln_result_no),1);
      ln_gl_corr := ln_meter_corr * ec_pwel_day_status.avg_gl_rate(p_object_id, p_daytime,'=');
      lv2_gl_source := ec_well_version.GL_SOURCE_STRM_ID(p_object_id, p_daytime, '<=');

      SELECT SUM(avg_gl_rate * NVL(ec_pwel_result.meter1_factor_gl(object_id,EcDp_Performance_Test.getLastValidWellResultNo(object_id, daytime)),1)) INTO ln_GL_well_meas
      FROM pwel_day_status
      WHERE ec_well_version.prod_method(object_id, p_daytime, '<=') = 'GL'
      AND ec_well_version.GL_SOURCE_STRM_ID(object_id, p_daytime, '<=') = lv2_gl_source
      AND daytime = p_daytime;

      -- Update the total well measurement volume with the meter factor
      ln_gl_well_meas := (ln_GL_well_meas - ec_pwel_day_status.avg_gl_rate(p_object_id, p_daytime,'=') ) + ln_gl_corr;
      ln_gl_total := ecbp_stream_fluid.findNetStdVol(lv2_GL_source, p_daytime);
      ln_ret_val := ln_gl_corr * (ln_gl_total / ln_gl_well_meas);

   ELSIF (substr(lv2_gas_lift_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getGasLiftStdRateDay(
               p_object_id,
               p_daytime);

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.VFM_PRIORITIZED) THEN

      ln_ret_val := EcBp_HCM_VFM.getGasLiftStdRateDay(p_object_id, p_daytime);

   ELSE -- undefined method
      ln_ret_val := null;
   END IF;

   RETURN ln_ret_val;

END getGasLiftStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOilStdDensity
-- Description    : Returns oil density for well on a given day at standard conditions, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findOilStdDensity(p_object_id    VARCHAR2,
                           p_daytime      DATE,
                           p_calc_method  VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

   lv2_calc_method VARCHAR2(32);
   ln_ret_val      NUMBER;
   lr_analysis     object_fluid_analysis%ROWTYPE;
   ln_wat_dens     NUMBER;


BEGIN

   lv2_calc_method := Nvl(p_calc_method,
                          ec_well_version.std_oil_density_method(p_object_id,
                                                                 p_daytime,
                                                                 '<='));

   IF (lv2_calc_method = EcDp_Calc_Method.ANALYSIS_SP_GRAV) THEN

      lr_analysis := EcDp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'WELL_OIL_COMP', null, p_daytime, EcDp_Phase.OIL);

      ln_wat_dens := EcDp_System.getWaterDensity(p_daytime => p_daytime);
      ln_ret_val  := lr_analysis.sp_grav * ln_wat_dens;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_REFERENCE) THEN
      ln_ret_val := ecdp_well_ref_values.getAttribute(p_object_id,'OIL_DENSITY',p_daytime);

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN      ln_ret_val := Ue_Well_Theoretical.findOilStdDensity(
               p_object_id,
               p_daytime);

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;


   RETURN ln_ret_val;

END findOilStdDensity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasStdDensity
-- Description    : Returns gas density for well on a given day at standard conditions, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGasStdDensity(p_object_id    VARCHAR2,
                           p_daytime      DATE,
                           p_calc_method  VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

   lv2_calc_method  VARCHAR2(32);
   ln_ret_val       NUMBER;
   lv2_ref_strm_id  VARCHAR2(32);
   lr_analysis      object_fluid_analysis%ROWTYPE;
   ln_air_dens      NUMBER;

BEGIN

   lv2_calc_method := Nvl(p_calc_method,
                          ec_well_version.std_gas_density_method(p_object_id,
                                                                 p_daytime,
                                                                 '<='));

   IF (lv2_calc_method = EcDp_Calc_Method.ANALYSIS_SP_GRAV) THEN

      lr_analysis := EcDp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'WELL_GAS_COMP', null, p_daytime, EcDp_Phase.GAS);

      ln_air_dens := EcDp_System.getAirDensity(p_daytime => p_daytime);

      ln_ret_val := lr_analysis.sp_grav * ln_air_dens;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_REFERENCE) THEN
      ln_ret_val := ecdp_well_ref_values.getAttribute(p_object_id,'GAS_DENSITY',p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.ANALYSIS_QUALITY_STRM) THEN  --estimates the density from quality stream compositional analysis
      lv2_ref_strm_id := ec_well_version.fluid_quality(p_object_id, p_daytime,'<=');
      ln_ret_val := ecbp_comp_analysis.calcTheorDens(lv2_ref_strm_id, p_daytime);

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findGasStdDensity(p_object_id, p_daytime);

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;


   RETURN ln_ret_val;

END findGasStdDensity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWatStdDensity
-- Description    : Returns water density for well on a given day at standard conditions, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWatStdDensity(p_object_id   VARCHAR2,
                           p_daytime     DATE,
                           p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

   ln_ret_val      NUMBER;
   lv2_calc_method    VARCHAR2(32);

BEGIN

   lv2_calc_method := Nvl(p_calc_method,
                          ec_well_version.std_wat_density_method(p_object_id,
                                                                 p_daytime,
                                                                 '<='));

    IF (lv2_calc_method = EcDp_Calc_Method.WELL_REFERENCE) THEN
      ln_ret_val := ecdp_well_ref_values.getAttribute(p_object_id,'WAT_DENSITY',p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.SYSTEM_DENSITY) THEN
   ln_ret_val := EcDp_System.getWaterDensity(p_daytime => p_daytime);

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findWatStdDensity(
               p_object_id,
               p_daytime);

   ELSE -- by default density
      ln_ret_val := EcDp_System.getWaterDensity(p_daytime => p_daytime);


   END IF;

   RETURN ln_ret_val;

END findWatStdDensity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOilMassDay
-- Description    : Returns theoretical oil mass for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findOilMassDay(p_object_id   VARCHAR2,
                        p_daytime     DATE,
                        p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

   lv2_calc_method    VARCHAR2(32);
   lv2_def_version    VARCHAR2(32);
   ln_ret_val         NUMBER;
   lr_day_rec         PWEL_DAY_STATUS%ROWTYPE;
   ln_vol             NUMBER;
   ln_density         NUMBER;
   ln_on_strm_ratio   NUMBER;
   ln_prod_day_offset NUMBER;
   ld_end_daytime     DATE;
   ld_start_daytime   DATE;


BEGIN

   lv2_calc_method := Nvl(p_calc_method, ec_well_version.calc_method_mass(p_object_id,p_daytime,'<='));

   IF (lv2_calc_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN

      ln_vol := getOilStdRateDay(p_object_id, p_daytime);
      ln_density := findOilStdDensity(p_object_id, p_daytime);
      ln_ret_val := ln_vol * ln_density;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN

      lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_day_rec.avg_oil_mass;

   ELSIF ((lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) OR (lv2_calc_method = EcDp_Calc_Method.CURVE)) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
         ln_ret_val := getCurveRate(p_object_id,
                                    p_daytime,
                                    EcDp_Phase.OIL,
                                    EcDp_Curve_Purpose.PRODUCTION,
                                    lr_day_rec.avg_choke_size,
                                    lr_day_rec.avg_wh_press,
                                    lr_day_rec.avg_wh_temp,
                                    lr_day_rec.avg_bh_press,
                                    lr_day_rec.annulus_press,
                                    lr_day_rec.avg_wh_usc_press,
                                    lr_day_rec.avg_wh_dsc_press,
                                    lr_day_rec.bs_w,
                                    lr_day_rec.avg_dh_pump_speed,
                                    lr_day_rec.avg_gl_choke,
                                    lr_day_rec.avg_gl_press,
                                    getGasLiftStdRateDay(p_object_id, p_daytime, NULL),
                                    lr_day_rec.avg_gl_diff_press,
                                    lr_day_rec.avg_flow_mass,
                                    lr_day_rec.phase_current,
                                    lr_day_rec.ac_frequency,
                                    lr_day_rec.intake_press,
                                    lr_day_rec.avg_mpm_oil_rate,
                                    lr_day_rec.avg_mpm_gas_rate,
                                    lr_day_rec.avg_mpm_water_rate,
                                    lr_day_rec.avg_mpm_cond_rate,
                                    lr_day_rec.avg_dh_pump_power,
                                    lr_day_rec.avg_dp_venturi,
                                    NULL,
                                    lv2_calc_method);

         ln_ret_val := ln_ret_val * ln_on_strm_ratio;

      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.POTENTIAL_DEFERED) THEN

       lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
       ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
       ld_start_daytime := p_daytime + ln_prod_day_offset;
       ld_end_daytime := ld_start_daytime + 1;

       IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
         IF ec_pwel_period_status.active_well_status(p_object_id,ld_start_daytime,'EVENT','<=') = 'CLOSED_LT' THEN
          ln_ret_val := 0;
         ELSE
         ln_ret_val := ecbp_well_potential.findOilMassProdPotential(p_object_id, p_daytime)
            - ecbp_well_potential.calcDayWellProdDefermentMass(p_object_id, p_daytime, 'OIL_MASS');
         END IF;
      ELSE -- undefined
     ln_ret_val := NULL;

      END IF;

    ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         ln_ret_val := EcDp_Well_Estimate.getOilStdMassRate(p_object_id, ld_start_daytime) * ln_on_strm_ratio;

      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
      ln_ret_val := ec_pwel_day_status.avg_mpm_oil_mass_rate(p_object_id,p_daytime,'=');


   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findOilMassDay(
               p_object_id,
               p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_PRIORITIZED) THEN

      ln_ret_val := EcBp_HCM_VFM.findOilMassDay(p_object_id, p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN

      ln_ret_val := ec_pwel_day_status.avg_vfm_oil_mass_rate(p_object_id,p_daytime,'=');

   ELSE  -- undefined
         ln_ret_val := NULL;

   END IF;


   RETURN ln_ret_val;

END findOilMassDay;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasMassDay
-- Description    : Returns theoretical gas mass for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGasMassDay (
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lv2_def_version    VARCHAR2(32);
   ln_ret_val         NUMBER;
   lr_day_rec         PWEL_DAY_STATUS%ROWTYPE;
   ln_vol             NUMBER;
   ln_density         NUMBER;
   ln_on_strm_ratio   NUMBER;
   ln_prod_day_offset NUMBER;
   ld_end_daytime     DATE;
   ld_start_daytime   DATE;


BEGIN

   lv2_calc_method := Nvl(p_calc_method,
                          ec_well_version.calc_method_mass(p_object_id,p_daytime, '<='));


   IF (lv2_calc_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
      ln_vol     := getGasStdRateDay(p_object_id,
                                     p_daytime);

      ln_density := findGasStdDensity(p_object_id,
                                      p_daytime);

      ln_ret_val := ln_vol * ln_density;
      -- No need to compensate for downtime, already done in volume calculation

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN

      lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_day_rec.avg_gas_mass;

   ELSIF ((lv2_calc_method = EcDp_Calc_Method.CURVE_GAS) OR (lv2_calc_method = EcDp_Calc_Method.CURVE) OR (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID)) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
         ln_ret_val := getCurveRate(p_object_id,
                                    p_daytime,
                                    EcDp_Phase.GAS,
                                    EcDp_Curve_Purpose.PRODUCTION,
                                    lr_day_rec.avg_choke_size,
                                    lr_day_rec.avg_wh_press,
                                    lr_day_rec.avg_wh_temp,
                                    lr_day_rec.avg_bh_press,
                                    lr_day_rec.annulus_press,
                                    lr_day_rec.avg_wh_usc_press,
                                    lr_day_rec.avg_wh_dsc_press,
                                    lr_day_rec.bs_w,
                                    lr_day_rec.avg_dh_pump_speed,
                                    lr_day_rec.avg_gl_choke,
                                    lr_day_rec.avg_gl_press,
                                    getGasLiftStdRateDay(p_object_id, p_daytime, NULL),
                                    lr_day_rec.avg_gl_diff_press,
                                    lr_day_rec.avg_flow_mass,
                                    lr_day_rec.phase_current,
                                    lr_day_rec.ac_frequency,
                                    lr_day_rec.intake_press,
                                    lr_day_rec.avg_mpm_oil_rate,
                                    lr_day_rec.avg_mpm_gas_rate,
                                    lr_day_rec.avg_mpm_water_rate,
                                    lr_day_rec.avg_mpm_cond_rate,
                                    lr_day_rec.avg_dh_pump_power,
                                    lr_day_rec.avg_dp_venturi,
                                    NULL,
                                    lv2_calc_method);

         ln_ret_val := ln_ret_val * ln_on_strm_ratio;
      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.POTENTIAL_DEFERED) THEN

       lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
       ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
       ld_start_daytime := p_daytime + ln_prod_day_offset;
       ld_end_daytime := ld_start_daytime + 1;

       IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
         IF ec_pwel_period_status.active_well_status(p_object_id,ld_start_daytime,'EVENT','<=') = 'CLOSED_LT' THEN
          ln_ret_val := 0;
         ELSE
         ln_ret_val := ecbp_well_potential.findGasMassProdPotential(p_object_id, p_daytime)
            - ecbp_well_potential.calcDayWellProdDefermentMass(p_object_id, p_daytime, 'GAS_MASS');
         END IF;
      ELSE -- undefined
     ln_ret_val := NULL;

      END IF;

    ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         ln_ret_val := EcDp_Well_Estimate.getGasStdMassRate(p_object_id, ld_start_daytime) * ln_on_strm_ratio;

      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
	    ln_ret_val := ec_pwel_day_status.avg_mpm_gas_mass_rate(p_object_id,p_daytime,'=');

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findGasMassDay(
               p_object_id,
               p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_PRIORITIZED) THEN

      ln_ret_val := EcBp_HCM_VFM.findGasMassDay(p_object_id, p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN

      ln_ret_val := ec_pwel_day_status.avg_vfm_gas_mass_rate(p_object_id,p_daytime,'=');

   ELSE  -- undefined
         ln_ret_val := NULL;

   END IF;


   RETURN ln_ret_val;


END findGasMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterMassDay
-- Description    : Returns theoretical water mass for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWaterMassDay (p_object_id   VARCHAR2,
                           p_daytime     DATE,
                           p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lv2_def_version    VARCHAR2(32);
   ln_ret_val         NUMBER;
   lr_day_rec         PWEL_DAY_STATUS%ROWTYPE;
   ln_vol             NUMBER;
   ln_density         NUMBER;
   ln_on_strm_ratio   NUMBER;
   ln_prod_day_offset NUMBER;
   ld_end_daytime     DATE;
   ld_start_daytime   DATE;


BEGIN

   lv2_calc_method := Nvl(p_calc_method,
                          ec_well_version.calc_method_mass(p_object_id, p_daytime, '<='));


   IF (lv2_calc_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
      ln_vol := getWatStdRateDay(p_object_id,
                                 p_daytime);

      ln_density := findWatStdDensity(p_object_id, p_daytime);

      ln_ret_val := ln_vol * ln_density;
      -- No need to compensate for downtime, already done in volume calculation

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN

      lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_day_rec.avg_water_mass;

   ELSIF (substr(lv2_calc_method,1,5) = EcDp_Calc_Method.CURVE) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
         ln_ret_val := getCurveRate(p_object_id,
                                    p_daytime,
                                    EcDp_Phase.WATER,
                                    EcDp_Curve_Purpose.PRODUCTION,
                                    lr_day_rec.avg_choke_size,
                                    lr_day_rec.avg_wh_press,
                                    lr_day_rec.avg_wh_temp,
                                    lr_day_rec.avg_bh_press,
                                    lr_day_rec.annulus_press,
                                    lr_day_rec.avg_wh_usc_press,
                                    lr_day_rec.avg_wh_dsc_press,
                                    lr_day_rec.bs_w,
                                    lr_day_rec.avg_dh_pump_speed,
                                    lr_day_rec.avg_gl_choke,
                                    lr_day_rec.avg_gl_press,
                                    getGasLiftStdRateDay(p_object_id, p_daytime, NULL),
                                    lr_day_rec.avg_gl_diff_press,
                                    lr_day_rec.avg_flow_mass,
                                    lr_day_rec.phase_current,
                                    lr_day_rec.ac_frequency,
                                    lr_day_rec.intake_press,
                                    lr_day_rec.avg_mpm_oil_rate,
                                    lr_day_rec.avg_mpm_gas_rate,
                                    lr_day_rec.avg_mpm_water_rate,
                                    lr_day_rec.avg_mpm_cond_rate,
                                    lr_day_rec.avg_dh_pump_power,
                                    lr_day_rec.avg_dp_venturi,
                                    NULL,
                                    lv2_calc_method);

         ln_ret_val := ln_ret_val * ln_on_strm_ratio;

      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;


   ELSIF (lv2_calc_method = EcDp_Calc_Method.POTENTIAL_DEFERED) THEN

       lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
       ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
       ld_start_daytime := p_daytime + ln_prod_day_offset;
       ld_end_daytime := ld_start_daytime + 1;

       IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
         IF ec_pwel_period_status.active_well_status(p_object_id,ld_start_daytime,'EVENT','<=') = 'CLOSED_LT' THEN
          ln_ret_val := 0;
         ELSE
         ln_ret_val := ecbp_well_potential.findWaterMassProdPotential(p_object_id, p_daytime)
            - ecbp_well_potential.calcDayWellProdDefermentMass(p_object_id, p_daytime, 'WAT_MASS');
         END IF;
      ELSE -- undefined
     ln_ret_val := NULL;

      END IF;

    ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         ln_ret_val := EcDp_Well_Estimate.getWatStdMassRate(p_object_id, ld_start_daytime) * ln_on_strm_ratio;

      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
	    ln_ret_val := ec_pwel_day_status.avg_mpm_wat_mass_rate(p_object_id,p_daytime,'=');

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findWaterMassDay(
               p_object_id,
               p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_PRIORITIZED) THEN

      ln_ret_val := EcBp_HCM_VFM.findWaterMassDay(p_object_id, p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN

      ln_ret_val := ec_pwel_day_status.avg_vfm_wat_mass_rate(p_object_id,p_daytime,'=');

   ELSE  -- undefined
         ln_ret_val := NULL;

   END IF;


   RETURN ln_ret_val;


END findWaterMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondMassDay
-- Description    : Returns theoretical condensate mass for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findCondMassDay (p_object_id   VARCHAR2,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lv2_def_version    VARCHAR2(32);
   ln_ret_val         NUMBER;
   lr_day_rec         PWEL_DAY_STATUS%ROWTYPE;
   ln_vol             NUMBER;
   ln_density         NUMBER;
   ln_on_strm_ratio   NUMBER;
   ln_prod_day_offset NUMBER;
   ld_end_daytime     DATE;
   ld_start_daytime   DATE;


BEGIN

   lv2_calc_method := Nvl(p_calc_method,
                          ec_well_version.calc_method_mass(p_object_id, p_daytime, '<='));


   IF (lv2_calc_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
      ln_vol     := getCondStdRateDay(p_object_id,
                                      p_daytime);

      ln_density := findOilStdDensity(p_object_id,
                                      p_daytime);

      ln_ret_val := ln_vol * ln_density;
      -- No need to compensate for downtime, already done in volume calculation

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN

      lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_day_rec.avg_cond_mass;

   ELSIF ((lv2_calc_method = EcDp_Calc_Method.CURVE_GAS) OR (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID)) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
         ln_ret_val := getCurveRate(p_object_id,
                                    p_daytime,
                                    EcDp_Phase.CONDENSATE,
                                    EcDp_Curve_Purpose.PRODUCTION,
                                    lr_day_rec.avg_choke_size,
                                    lr_day_rec.avg_wh_press,
                                    lr_day_rec.avg_wh_temp,
                                    lr_day_rec.avg_bh_press,
                                    lr_day_rec.annulus_press,
                                    lr_day_rec.avg_wh_usc_press,
                                    lr_day_rec.avg_wh_dsc_press,
                                    lr_day_rec.bs_w,
                                    lr_day_rec.avg_dh_pump_speed,
                                    lr_day_rec.avg_gl_choke,
                                    lr_day_rec.avg_gl_press,
                                    getGasLiftStdRateDay(p_object_id, p_daytime, NULL),
                                    lr_day_rec.avg_gl_diff_press,
                                    lr_day_rec.avg_flow_mass,
                                    lr_day_rec.phase_current,
                                    lr_day_rec.ac_frequency,
                                    lr_day_rec.intake_press,
                                    lr_day_rec.avg_mpm_oil_rate,
                                    lr_day_rec.avg_mpm_gas_rate,
                                    lr_day_rec.avg_mpm_water_rate,
                                    lr_day_rec.avg_mpm_cond_rate,
                                    lr_day_rec.avg_dh_pump_power,
                                    lr_day_rec.avg_dp_venturi,
                                    NULL,
                                    lv2_calc_method);

         ln_ret_val := ln_ret_val * ln_on_strm_ratio;

      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.POTENTIAL_DEFERED) THEN

       lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
       ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
       ld_start_daytime := p_daytime + ln_prod_day_offset;
       ld_end_daytime := ld_start_daytime + 1;

       IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
         IF ec_pwel_period_status.active_well_status(p_object_id,ld_start_daytime,'EVENT','<=') = 'CLOSED_LT' THEN
          ln_ret_val := 0;
         ELSE
         ln_ret_val := ecbp_well_potential.findCondMassProdPotential(p_object_id, p_daytime)
            - ecbp_well_potential.calcDayWellProdDefermentMass(p_object_id, p_daytime, 'COND_MASS');
         END IF;
      ELSE -- undefined
     ln_ret_val := NULL;

      END IF;

    ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         ln_ret_val := EcDp_Well_Estimate.getCondStdMassRate(p_object_id, ld_start_daytime) * ln_on_strm_ratio;

      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
	    ln_ret_val := ec_pwel_day_status.avg_mpm_cond_mass_rate(p_object_id,p_daytime,'=');

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findCondMassDay(
               p_object_id,
               p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_PRIORITIZED) THEN

      ln_ret_val := EcBp_HCM_VFM.findCondMassDay(p_object_id, p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN

      ln_ret_val := ec_pwel_day_status.avg_vfm_cond_mass_rate(p_object_id,p_daytime,'=');

   ELSE  -- undefined
         ln_ret_val := NULL;

   END IF;


   RETURN ln_ret_val;


END findCondMassDay;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdVolSubDay
-- Description    : Returns theoretical oil rate for a prod. well during a sub daily time period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EC_pwel_sub_day_status.ROW_BY_PK
--                  ECDP_WELL_TEST.GETLASTOILSTDRATE
--                  ECBP_WELL_THEORETICAL.GETOILSTDRATEDAY
--                  ECBP_WELL_THEORETICAL.GETCURVERATE
--
-- Configuration
-- required       :
--
-- Behaviour      : p_calc_method = 'MEASURED'
--                  Get the pre-calculated volume directly from half hour table
--
--                  p_calc_method = 'CURVE'
--                  Calculate the volume by using performance curve lookup.
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdVolSubDay(p_object_id   VARCHAR2,
                            p_daytime     DATE,
                            p_calc_method VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

lv2_calc_method        VARCHAR2(32);
ln_ret_val             NUMBER;
ln_diluent_vol         NUMBER;
lr_sub_day_rec         pwel_sub_day_status%ROWTYPE;
ln_curve_value         NUMBER;
ln_on_strm_ratio       NUMBER;
ln_prod_day_offset     NUMBER;
ld_start_daytime       DATE;
lr_well_version        WELL_VERSION%ROWTYPE;
lv2_well_type          VARCHAR2(32);
ln_period_hrs          NUMBER;

BEGIN
   -- oil sub day calc method
   lv2_calc_method := Nvl(p_calc_method,ec_well_version.calc_sub_day_method(p_object_id,
                                                                            p_daytime,
                                                                            '<='));

   lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id,
                                                      p_daytime);

   -- to get the well type
   lv2_well_type := ec_well_version.well_type(p_object_id, p_daytime);

   IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs/24;
      ln_ret_val       := lr_sub_day_rec.avg_oil_rate*ln_on_strm_ratio;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
         ln_diluent_vol   := getDiluentStdVolSubDay(p_object_id, p_daytime, NULL);
         ln_ret_val       := ln_ret_val - Nvl(ln_diluent_vol,0);    -- Subtract diluent contribution if present
      ELSE -- zero on strm ratio = zero volume
         ln_ret_val := 0;
      END IF;

   -- External Calculated Theoretical Rate 1
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_1) THEN
     ln_ret_val := lr_sub_day_rec.ext_oil_rate_1;
   -- External Calculated Theoretical Rate 2
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_2) THEN
     ln_ret_val := lr_sub_day_rec.ext_oil_rate_2;
   -- External Calculated Theoretical Rate 3
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_3) THEN
     ln_ret_val := lr_sub_day_rec.ext_oil_rate_3;
   -- External Calculated Theoretical Rate 4
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_4) THEN
     ln_ret_val := lr_sub_day_rec.ext_oil_rate_4;
   -- External Calculated Theoretical Rate 5
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_5) THEN
     ln_ret_val := lr_sub_day_rec.ext_oil_rate_5;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED_NET) THEN
      ln_ret_val       := lr_sub_day_rec.avg_oil_rate;  -- Return the value without any adjustments


   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN

      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_period_hrs := EcBp_Well_SubDaily.getPeriodHrs(p_object_id, p_daytime);
         ln_period_hrs := TO_NUMBER(24/ln_period_hrs);
         ln_curve_value := getCurveRate(p_object_id,
                                        EcDp_ProductionDay.getProductionDay('WELL', p_object_id, p_daytime),
                                        EcDp_Phase.OIL,
                                        EcDp_Curve_Purpose.PRODUCTION,
                                        lr_sub_day_rec.avg_choke_size,
                                        lr_sub_day_rec.avg_wh_press,
                                        lr_sub_day_rec.avg_wh_temp,
                                        lr_sub_day_rec.avg_bh_press,
                                        lr_sub_day_rec.avg_annulus_press,
                                        lr_sub_day_rec.avg_wh_usc_press,
                                        lr_sub_day_rec.avg_wh_dsc_press,
                                        lr_sub_day_rec.bs_w,
                                        lr_sub_day_rec.avg_dh_pump_speed,
                                        lr_sub_day_rec.avg_gl_choke_size,
                                        lr_sub_day_rec.avg_gl_press,
                                        getGasLiftStdVolSubDay(p_object_id, p_daytime, NULL) * ln_period_hrs,
                                        lr_sub_day_rec.avg_gl_diff_press,
                                        NULL,
                                        lr_sub_day_rec.phase_current,
                                        lr_sub_day_rec.ac_frequency,
                                        lr_sub_day_rec.intake_press,
                                        lr_sub_day_rec.avg_mpm_oil_rate,
                                        lr_sub_day_rec.avg_mpm_gas_rate,
                                        lr_sub_day_rec.avg_mpm_water_rate,
                                        lr_sub_day_rec.avg_mpm_cond_rate,
                                        lr_sub_day_rec.avg_dh_pump_power,
                                        lr_sub_day_rec.avg_dp_venturi,
                                        NULL,
                                        lv2_calc_method);

         ln_ret_val := ln_curve_value * ln_on_strm_ratio;

      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN

      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_period_hrs := EcBp_Well_SubDaily.getPeriodHrs(p_object_id, p_daytime);
         ln_period_hrs := TO_NUMBER(24/ln_period_hrs);
         ln_curve_value := getCurveRate(p_object_id,
                                        EcDp_ProductionDay.getProductionDay('WELL', p_object_id, p_daytime),
                                        EcDp_Phase.LIQUID,
                                        EcDp_Curve_Purpose.PRODUCTION,
                                        lr_sub_day_rec.avg_choke_size,
                                        lr_sub_day_rec.avg_wh_press,
                                        lr_sub_day_rec.avg_wh_temp,
                                        lr_sub_day_rec.avg_bh_press,
                                        lr_sub_day_rec.avg_annulus_press,
                                        lr_sub_day_rec.avg_wh_usc_press,
                                        lr_sub_day_rec.avg_wh_dsc_press,
                                        lr_sub_day_rec.bs_w,
                                        lr_sub_day_rec.avg_dh_pump_speed,
                                        lr_sub_day_rec.avg_gl_choke_size,
                                        lr_sub_day_rec.avg_gl_press,
                                        getGasLiftStdVolSubDay(p_object_id, p_daytime, NULL) * ln_period_hrs,
                                        lr_sub_day_rec.avg_gl_diff_press,
                                        NULL,
                                        lr_sub_day_rec.phase_current,
                                        lr_sub_day_rec.ac_frequency,
                                        lr_sub_day_rec.intake_press,
                                        lr_sub_day_rec.avg_mpm_oil_rate,
                                        lr_sub_day_rec.avg_mpm_gas_rate,
                                        lr_sub_day_rec.avg_mpm_water_rate,
                                        lr_sub_day_rec.avg_mpm_cond_rate,
                                        lr_sub_day_rec.avg_dh_pump_power,
                                        lr_sub_day_rec.avg_dp_venturi,
                                        NULL,
                                        lv2_calc_method);

         ln_ret_val := ln_curve_value * ln_on_strm_ratio;

      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

    -- we also need to add new parameter to EcDp_Well.getPwelOnStreamHrs to retreive the method. This new parameter must be default NULL.
    ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;

    IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;

      ln_ret_val := EcDp_Well_Estimate.getOilStdRate(p_object_id, ld_start_daytime) * ln_on_strm_ratio;

    ELSIF ln_on_strm_ratio = 0 THEN
      ln_ret_val := 0;

    ELSE
      ln_ret_val := NULL;
    END IF;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getOilStdVolSubDay(
                     p_object_id,
                     p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
      lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_sub_day_rec.avg_mpm_oil_rate;
      ln_diluent_vol := getDiluentStdVolSubDay(p_object_id, p_daytime,ec_well_version.diluent_sub_day_method(p_object_id,
                                                p_daytime,
                                                '<='));
      ln_ret_val := ln_ret_val * ln_on_strm_ratio;	  -- calculate mpm day rate to a mpm sub daily volume
      ln_ret_val := ln_ret_val - Nvl(ln_diluent_vol,0); --Subtract diluent contribution if present

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
      ln_ret_val       := lr_sub_day_rec.avg_mpm_oil_rate * ln_on_strm_ratio; --Returns MPM value without subtraction of artificial lifts

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
      lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_sub_day_rec.avg_mpm2_oil_rate;
      ln_diluent_vol := getDiluentStdVolSubDay(p_object_id, p_daytime,ec_well_version.diluent_sub_day_method(p_object_id,
                                                p_daytime,
                                                '<='));
      ln_ret_val := ln_ret_val * ln_on_strm_ratio;	  -- calculate mpm2 day rate to a mpm2 sub daily volume
      ln_ret_val := ln_ret_val - Nvl(ln_diluent_vol,0); --Subtract diluent contribution if present

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_NET) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
      ln_ret_val       := lr_sub_day_rec.avg_mpm2_oil_rate * ln_on_strm_ratio; --Returns MPM2 value without subtraction of artificial lifts


   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
      ln_ret_val       := lr_sub_day_rec.avg_vfm_oil_rate;
      ln_diluent_vol   := getDiluentStdVolSubDay(p_object_id, p_daytime,ec_well_version.diluent_sub_day_method(p_object_id,
                                                p_daytime,
                                                '<='));
      ln_ret_val       := ln_ret_val * ln_on_strm_ratio;	  -- calculate vfm day rate to a vfm sub daily volume
      ln_ret_val       := ln_ret_val - Nvl(ln_diluent_vol,0); --Subtract diluent contribution if present

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
      ln_ret_val       := lr_sub_day_rec.avg_vfm_oil_rate * ln_on_strm_ratio;

   ELSE-- if GP2, get the oil from condensate
      IF (lv2_well_type = Ecdp_Well_Type.GAS_PRODUCER_2) THEN
         ln_ret_val := getCondStdVolSubDay(p_object_id, p_daytime,NULL);
      ELSE
         ln_ret_val := NULL;
      END IF;

   END IF;

   RETURN ln_ret_val;

END getOilStdVolSubDay;



---------------------------------------------------------------------------------------------------
-- Function       : getGasStdVolSubDay
-- Description    : Returns theoretical gas rate for a prod. well during a sub daily time period.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdVolSubDay(p_object_id    VARCHAR2,
                            p_daytime      DATE,
                            p_calc_method  VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   ln_ret_val         NUMBER;
   ln_gor             NUMBER;
   lr_sub_day_rec     pwel_sub_day_status%ROWTYPE;
   ln_gas_lift_rate   NUMBER;
   ln_curve_value     NUMBER;
   ln_oil_rate        NUMBER;
   ln_on_strm_ratio   NUMBER;
   ln_prod_day_offset NUMBER;
   ld_start_daytime   DATE;
   lr_well_version    WELL_VERSION%ROWTYPE;
   ln_on_stream_frac  NUMBER;
   ln_period_hrs      NUMBER;

BEGIN

   -- gas sub day calc method
   lv2_calc_method := Nvl(p_calc_method,ec_well_version.calc_sub_day_gas_method(p_object_id,
                                                                            p_daytime,
                                                                            '<='));
   lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id,
                                                      p_daytime);

   IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs/24;
      ln_ret_val       := lr_sub_day_rec.avg_gas_rate*ln_on_strm_ratio;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
         ln_gas_lift_rate := getGasLiftStdVolSubday(p_object_id, p_daytime, NULL);
         ln_ret_val       := ln_ret_val - NVL(ln_gas_lift_rate,0);
      ELSE -- zero on strm ratio = zero volume
         ln_ret_val := 0;
      END IF;

   -- External Calculated Theoretical Rate 1
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_1) THEN
     ln_ret_val := lr_sub_day_rec.ext_gas_rate_1;
   -- External Calculated Theoretical Rate 2
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_2) THEN
     ln_ret_val := lr_sub_day_rec.ext_gas_rate_2;
   -- External Calculated Theoretical Rate 3
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_3) THEN
     ln_ret_val := lr_sub_day_rec.ext_gas_rate_3;
   -- External Calculated Theoretical Rate 4
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_4) THEN
     ln_ret_val := lr_sub_day_rec.ext_gas_rate_4;
   -- External Calculated Theoretical Rate 5
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_5) THEN
     ln_ret_val := lr_sub_day_rec.ext_gas_rate_5;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED_NET) THEN
      ln_ret_val       := lr_sub_day_rec.avg_gas_rate;  -- Return the value without any adjustments

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_GAS) THEN

         ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;

         IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

            ln_period_hrs := EcBp_Well_SubDaily.getPeriodHrs(p_object_id, p_daytime);
            ln_period_hrs := TO_NUMBER(24/ln_period_hrs);
            ln_curve_value := getCurveRate(p_object_id,
                                           EcDp_ProductionDay.getProductionDay('WELL', p_object_id, p_daytime),
                                           EcDp_Phase.GAS,
                                           EcDp_Curve_Purpose.PRODUCTION,
                                           lr_sub_day_rec.avg_choke_size,
                                           lr_sub_day_rec.avg_wh_press,
                                           lr_sub_day_rec.avg_wh_temp,
                                           lr_sub_day_rec.avg_bh_press,
                                           lr_sub_day_rec.avg_annulus_press,
                                           lr_sub_day_rec.avg_wh_usc_press,
                                           lr_sub_day_rec.avg_wh_dsc_press,
                                           lr_sub_day_rec.bs_w,
                                           lr_sub_day_rec.avg_dh_pump_speed,
                                           lr_sub_day_rec.avg_gl_choke_size,
                                           lr_sub_day_rec.avg_gl_press,
                                           getGasLiftStdVolSubDay(p_object_id, p_daytime, NULL) * ln_period_hrs,
                                           lr_sub_day_rec.avg_gl_diff_press,
                                           NULL,
                                           lr_sub_day_rec.phase_current,
                                           lr_sub_day_rec.ac_frequency,
                                           lr_sub_day_rec.intake_press,
                                           lr_sub_day_rec.avg_mpm_oil_rate,
                                           lr_sub_day_rec.avg_mpm_gas_rate,
                                           lr_sub_day_rec.avg_mpm_water_rate,
                                           lr_sub_day_rec.avg_mpm_cond_rate,
                                           lr_sub_day_rec.avg_dh_pump_power,
                                           lr_sub_day_rec.avg_dp_venturi,
                                           NULL,
                                           lv2_calc_method);


            ln_ret_val := ln_curve_value * ln_on_strm_ratio;

         ELSE
            ln_ret_val := ln_on_strm_ratio;
         END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_on_stream_frac := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_stream_frac > 0 THEN -- Only worth doing calculation when the well is up

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         ln_ret_val := EcDp_Well_Estimate.getGasStdRate(p_object_id, ld_start_daytime);
         ln_ret_val := ln_ret_val * ln_on_stream_frac;

      ELSE
         ln_ret_val := 0;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.OIL_GOR) THEN
      ln_oil_rate := getOilStdVolSubDay(p_object_id, p_daytime, NULL);
      IF ln_oil_rate > 0 THEN     -- Only worth getting GOR if Oil is > 0
         ln_ret_val := ln_oil_rate * findGasOilRatio(p_object_id,p_daytime,null,null,'PWEL_SUB_DAY_STATUS');
      ELSIF ln_oil_rate = 0 THEN     -- if oil rate = 0, then gas is also zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := null;
      END IF;


   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getGasStdVolSubDay(
                     p_object_id,
                     p_daytime);


   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM) THEN
     ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
     lr_sub_day_rec   := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);
     ln_ret_val       := lr_sub_day_rec.avg_mpm_gas_rate;
     ln_gas_lift_rate := getGasLiftStdVolSubDay(p_object_id, p_daytime, ec_well_version.gas_lift_sub_day_method(p_object_id,
                                                p_daytime,
                                                '<='));
     ln_ret_val       := ln_ret_val * ln_on_strm_ratio;	  -- calculate mpm day rate to a mpm sub daily volume
     ln_ret_val       := ln_ret_val - Nvl(ln_gas_lift_rate,0);    --Subtract gas lift contribution if present

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
	  ln_ret_val       := lr_sub_day_rec.avg_mpm_gas_rate * ln_on_strm_ratio; --Returns MPM value without subtraction of artificial lifts

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2) THEN
     ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
     lr_sub_day_rec   := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);
     ln_ret_val       := lr_sub_day_rec.avg_mpm2_gas_rate;
     ln_gas_lift_rate := getGasLiftStdVolSubDay(p_object_id, p_daytime, ec_well_version.gas_lift_sub_day_method(p_object_id,
                                                p_daytime,
                                                '<='));
     ln_ret_val       := ln_ret_val * ln_on_strm_ratio;	  -- calculate mpm2 day rate to a mpm2 sub daily volume
     ln_ret_val       := ln_ret_val - Nvl(ln_gas_lift_rate,0);    --Subtract gas lift contribution if present

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_NET) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
	  ln_ret_val       := lr_sub_day_rec.avg_mpm2_gas_rate * ln_on_strm_ratio; --Returns MPM2 value without subtraction of artificial lifts

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
      ln_ret_val       := lr_sub_day_rec.avg_vfm_gas_rate;
      ln_gas_lift_rate := getGasLiftStdVolSubDay(p_object_id, p_daytime, ec_well_version.gas_lift_sub_day_method(p_object_id,
                                                p_daytime,
                                                '<='));
      ln_ret_val       := ln_ret_val * ln_on_strm_ratio;	  -- calculate vfm day rate to a vfm sub daily volume
      ln_ret_val       := ln_ret_val - Nvl(ln_gas_lift_rate,0); --Subtract gas lift contribution if present

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
      ln_ret_val       := lr_sub_day_rec.avg_vfm_gas_rate * ln_on_strm_ratio;

   ELSE  -- Undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;

END getGasStdVolSubDay;


---------------------------------------------------------------------------------------------------
-- Function       : getWatStdVolSubDay
-- Description    : Returns theoretical water rate for a prod. well during a sub daily time period.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdVolSubDay(p_object_id   VARCHAR2,
                            p_daytime     DATE,
                            p_calc_method VARCHAR2)

RETURN NUMBER IS

   lv2_calc_method       VARCHAR2(32);
   ln_ret_val            NUMBER;
   lr_sub_day_rec        pwel_sub_day_status%ROWTYPE;
   ln_curve_value        NUMBER;
   ln_on_strm_ratio      NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;
   lr_well_version       WELL_VERSION%ROWTYPE;
   ln_water_cut          NUMBER;
   ln_oil_rate           NUMBER;
   ln_period_hrs         NUMBER;
   ln_gas_rate           NUMBER;


BEGIN
    -- water sub day calc method
   lv2_calc_method := Nvl(p_calc_method,ec_well_version.calc_sub_day_water_method(p_object_id,
                                                                            p_daytime,
                                                                            '<='));

   lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);

   IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs/24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
           ln_ret_val    := lr_sub_day_rec.avg_water_rate*ln_on_strm_ratio;
      ELSE
         ln_ret_val    := 0; -- zero on strm ratio = zero volume
      END IF;

   -- External Calculated Theoretical Rate 1
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_1) THEN
     ln_ret_val := lr_sub_day_rec.ext_wat_rate_1;
   -- External Calculated Theoretical Rate 2
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_2) THEN
     ln_ret_val := lr_sub_day_rec.ext_wat_rate_2;
   -- External Calculated Theoretical Rate 3
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_3) THEN
     ln_ret_val := lr_sub_day_rec.ext_wat_rate_3;
   -- External Calculated Theoretical Rate 4
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_4) THEN
     ln_ret_val := lr_sub_day_rec.ext_wat_rate_4;
   -- External Calculated Theoretical Rate 5
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_5) THEN
     ln_ret_val := lr_sub_day_rec.ext_wat_rate_5;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_WATER) THEN

      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_period_hrs := EcBp_Well_SubDaily.getPeriodHrs(p_object_id, p_daytime);
         ln_period_hrs := TO_NUMBER(24/ln_period_hrs);
         ln_curve_value := getCurveRate(p_object_id,
                                        EcDp_ProductionDay.getProductionDay('WELL', p_object_id, p_daytime),
                                        EcDp_Phase.WATER,
                                        EcDp_Curve_Purpose.PRODUCTION,
                                        lr_sub_day_rec.avg_choke_size,
                                        lr_sub_day_rec.avg_wh_press,
                                        lr_sub_day_rec.avg_wh_temp,
                                        lr_sub_day_rec.avg_bh_press,
                                        lr_sub_day_rec.avg_annulus_press,
                                        lr_sub_day_rec.avg_wh_usc_press,
                                        lr_sub_day_rec.avg_wh_dsc_press,
                                        lr_sub_day_rec.bs_w,
                                        lr_sub_day_rec.avg_dh_pump_speed,
                                        lr_sub_day_rec.avg_gl_choke_size,
                                        lr_sub_day_rec.avg_gl_press,
                                        getGasLiftStdVolSubDay(p_object_id, p_daytime, NULL) * ln_period_hrs,
                                        lr_sub_day_rec.avg_gl_diff_press,
                                        NULL,
                                        lr_sub_day_rec.phase_current,
                                        lr_sub_day_rec.ac_frequency,
                                        lr_sub_day_rec.intake_press,
                                        lr_sub_day_rec.avg_mpm_oil_rate,
                                        lr_sub_day_rec.avg_mpm_gas_rate,
                                        lr_sub_day_rec.avg_mpm_water_rate,
                                        lr_sub_day_rec.avg_mpm_cond_rate,
                                        lr_sub_day_rec.avg_dh_pump_power,
                                        lr_sub_day_rec.avg_dp_venturi,
                                        NULL,
                                        lv2_calc_method);

         ln_ret_val := ln_curve_value * ln_on_strm_ratio;
      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         ln_ret_val := EcDp_Well_Estimate.getWatStdRate(p_object_id, ld_start_daytime);
         ln_ret_val := ln_ret_val * ln_on_strm_ratio;
      ELSE
         ln_ret_val := 0;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.OIL_WATER_CUT) THEN

      ln_water_cut := findWaterCutPct(p_object_id, p_daytime, lr_well_version.bsw_vol_method, NULL, 'PWEL_SUB_DAY_STATUS')/100;
      ln_oil_rate := getOilStdVolSubDay(p_object_id,p_daytime,lr_well_version.calc_method);
      IF ln_oil_rate > 0 THEN
         IF (1 - ln_water_cut) <> 0 THEN
            ln_ret_val := (ln_oil_rate/(1 - ln_water_cut)) * ln_water_cut;
         ELSE   -- div by zero
            ln_ret_val := null;
         END IF;
      ELSIF ln_oil_rate = 0 THEN   -- if oil is zero, then also water is zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := null;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.LIQ_WATER_CUT) THEN

      ln_water_cut := findWaterCutPct(p_object_id, p_daytime, lr_well_version.bsw_vol_method, NULL, 'PWEL_SUB_DAY_STATUS')/100;
      ln_oil_rate := getOilStdVolSubDay(p_object_id,p_daytime,lr_well_version.calc_method);

      IF ln_oil_rate > 0 THEN
         IF (1 - ln_water_cut) <> 0 THEN
            ln_ret_val := (ln_oil_rate / (1 - ln_water_cut)) * ln_water_cut;
         ELSE   -- div by zero
            ln_ret_val := null;
         END IF;
      ELSIF ln_oil_rate = 0 THEN   -- if oil is zero, then also water is zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := null;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.OIL_WOR) THEN
      ln_oil_rate := getOilStdVolSubDay(p_object_id, p_daytime,NULL);
      IF ln_oil_rate > 0 THEN   -- Only worth getting WOR if Oil is > 0
         ln_ret_val := ln_oil_rate * findWaterOilRatio(p_object_id, p_daytime,NULL,NULL,'PWEL_SUB_DAY_STATUS');
      ELSIF ln_oil_rate=0 THEN   -- if oil rate = 0, then water is also zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := NULL;
      END IF;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getWatStdVolSubDay(
                     p_object_id,
                     p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM) THEN
     ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
     lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);
     ln_ret_val     := lr_sub_day_rec.avg_mpm_water_rate - NVL(lr_sub_day_rec.avg_powerwater_rate,0); --Subtract powerwater if present
     ln_ret_val     := ln_ret_val * ln_on_strm_ratio;	  -- calculate mpm day rate to a mpm sub daily volume

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
	  ln_ret_val       := lr_sub_day_rec.avg_mpm_water_rate * ln_on_strm_ratio; --Returns MPM value without subtraction of artificial lifts

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2) THEN
     ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
     lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);
     ln_ret_val     := lr_sub_day_rec.avg_mpm2_water_rate - NVL(lr_sub_day_rec.avg_powerwater_rate,0); --Subtract powerwater if present
     ln_ret_val     := ln_ret_val * ln_on_strm_ratio;	  -- calculate mpm2 day rate to a mpm2 sub daily volume

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_NET) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
	  ln_ret_val       := lr_sub_day_rec.avg_mpm2_water_rate * ln_on_strm_ratio; --Returns MPM2 value without subtraction of artificial lifts

  ELSIF (lv2_calc_method = EcDp_Calc_Method.GAS_WGR) THEN
     ln_gas_rate := getGasStdVolSubDay(p_object_id, p_daytime, lr_well_version.calc_gas_method);
      IF ln_gas_rate > 0 THEN   -- Only worth getting WGR if Gas is > 0
         ln_ret_val := ln_gas_rate * findWaterGasRatio(p_object_id, p_daytime, lr_well_version.wgr_method, NULL,'PWEL_SUB_DAY_STATUS');
      ELSIF ln_gas_rate = 0 THEN   -- if oil rate = 0, then water is also zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := NULL;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
      ln_ret_val       := lr_sub_day_rec.avg_vfm_water_rate - NVL(lr_sub_day_rec.avg_powerwater_rate,0); --Subtract powerwater if present
      ln_ret_val       := ln_ret_val * ln_on_strm_ratio;	  -- calculate vfm day rate to a vfm sub daily volume

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
      ln_ret_val       := lr_sub_day_rec.avg_vfm_water_rate * ln_on_strm_ratio;

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN  ln_ret_val;

END getWatStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdVolSubDay
-- Description    : Returns theoretical condensate rate for a well gas producer during a given
--                  sub daily period.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EcDp_Well_Theoretical.getGasCondensateRatio
--                  findGasStdRateSubDay
--
-- Configuration
-- required       :
--
-- Behaviour      : Get theoretical gas rate for given well on actual time. Divide by gcr
--
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdVolSubDay(p_object_id    VARCHAR2,
                             p_daytime      DATE,
                             p_calc_method  VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

   lv2_calc_method      VARCHAR2(32);
   ln_ret_val           NUMBER;
   ln_cgr               NUMBER;
   lr_sub_day_rec       pwel_sub_day_status%ROWTYPE;
   ln_curve_value       NUMBER;
   ln_on_strm_ratio     NUMBER;
   ln_prod_day_offset   NUMBER;
   ld_start_daytime     DATE;
   lr_well_version      WELL_VERSION%ROWTYPE;
   ln_period_hrs        NUMBER;
   ln_gas_rate          NUMBER;

BEGIN
   -- cond sub day calc method
   lv2_calc_method := Nvl(p_calc_method,ec_well_version.calc_sub_day_cond_method(p_object_id,
                                                                            p_daytime,
                                                                            '<='));

   lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);

   IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs/24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
         ln_ret_val    := lr_sub_day_rec.avg_cond_rate*ln_on_strm_ratio;
      ELSE -- zero on strm ratio = zero volume
         ln_ret_val    := 0;
      END IF;

   -- External Calculated Theoretical Rate 1
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_1) THEN
     ln_ret_val := lr_sub_day_rec.ext_cond_rate_1;
   -- External Calculated Theoretical Rate 2
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_2) THEN
     ln_ret_val := lr_sub_day_rec.ext_cond_rate_2;
   -- External Calculated Theoretical Rate 3
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_3) THEN
     ln_ret_val := lr_sub_day_rec.ext_cond_rate_3;
   -- External Calculated Theoretical Rate 4
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_4) THEN
     ln_ret_val := lr_sub_day_rec.ext_cond_rate_4;
   -- External Calculated Theoretical Rate 5
   ELSIF (lv2_calc_method = EcDp_Calc_Method.EXTERNAL_5) THEN
     ln_ret_val := lr_sub_day_rec.ext_cond_rate_5;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN

      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_period_hrs := EcBp_Well_SubDaily.getPeriodHrs(p_object_id, p_daytime);
         ln_period_hrs := TO_NUMBER(24/ln_period_hrs);
         ln_curve_value := getCurveRate(p_object_id,
                                        EcDp_ProductionDay.getProductionDay('WELL', p_object_id, p_daytime),
                                        EcDp_Phase.CONDENSATE,
                                        EcDp_Curve_Purpose.PRODUCTION,
                                        lr_sub_day_rec.avg_choke_size,
                                        lr_sub_day_rec.avg_wh_press,
                                        lr_sub_day_rec.avg_wh_temp,
                                        lr_sub_day_rec.avg_bh_press,
                                        lr_sub_day_rec.avg_annulus_press,
                                        lr_sub_day_rec.avg_wh_usc_press,
                                        lr_sub_day_rec.avg_wh_dsc_press,
                                        lr_sub_day_rec.bs_w,
                                        lr_sub_day_rec.avg_dh_pump_speed,
                                        lr_sub_day_rec.avg_gl_choke_size,
                                        lr_sub_day_rec.avg_gl_press,
                                        getGasLiftStdVolSubDay(p_object_id, p_daytime, NULL) * ln_period_hrs,
                                        lr_sub_day_rec.avg_gl_diff_press,
                                        NULL,
                                        lr_sub_day_rec.phase_current,
                                        lr_sub_day_rec.ac_frequency,
                                        lr_sub_day_rec.intake_press,
                                        lr_sub_day_rec.avg_mpm_oil_rate,
                                        lr_sub_day_rec.avg_mpm_gas_rate,
                                        lr_sub_day_rec.avg_mpm_water_rate,
                                        lr_sub_day_rec.avg_mpm_cond_rate,
                                        lr_sub_day_rec.avg_dh_pump_power,
                                        lr_sub_day_rec.avg_dp_venturi,
                                        NULL,
                                        lv2_calc_method);

         ln_ret_val := ln_curve_value * ln_on_strm_ratio;
      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN

      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_period_hrs := EcBp_Well_SubDaily.getPeriodHrs(p_object_id, p_daytime);
         ln_period_hrs := TO_NUMBER(24/ln_period_hrs);
         ln_curve_value := getCurveRate(p_object_id,
                                        EcDp_ProductionDay.getProductionDay('WELL', p_object_id, p_daytime),
                                        EcDp_Phase.CONDENSATE,
                                        EcDp_Curve_Purpose.PRODUCTION,
                                        lr_sub_day_rec.avg_choke_size,
                                        lr_sub_day_rec.avg_wh_press,
                                        lr_sub_day_rec.avg_wh_temp,
                                        lr_sub_day_rec.avg_bh_press,
                                        lr_sub_day_rec.avg_annulus_press,
                                        lr_sub_day_rec.avg_wh_usc_press,
                                        lr_sub_day_rec.avg_wh_dsc_press,
                                        lr_sub_day_rec.bs_w,
                                        lr_sub_day_rec.avg_dh_pump_speed,
                                        lr_sub_day_rec.avg_gl_choke_size,
                                        lr_sub_day_rec.avg_gl_press,
                                        getGasLiftStdVolSubDay(p_object_id, p_daytime, NULL) * ln_period_hrs,
                                        lr_sub_day_rec.avg_gl_diff_press,
                                        NULL,
                                        lr_sub_day_rec.phase_current,
                                        lr_sub_day_rec.ac_frequency,
                                        lr_sub_day_rec.intake_press,
                                        lr_sub_day_rec.avg_mpm_oil_rate,
                                        lr_sub_day_rec.avg_mpm_gas_rate,
                                        lr_sub_day_rec.avg_mpm_water_rate,
                                        lr_sub_day_rec.avg_mpm_cond_rate,
                                        lr_sub_day_rec.avg_dh_pump_power,
                                        lr_sub_day_rec.avg_dp_venturi,
                                        NULL,
                                        lv2_calc_method);

         ln_ret_val := ln_curve_value * ln_on_strm_ratio;
      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;

         ln_ret_val := EcDp_Well_Estimate.getCondStdRate(p_object_id, ld_start_daytime);
         ln_ret_val := ln_ret_val * ln_on_strm_ratio;

      ELSE
         ln_ret_val := 0;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.GAS_CGR) THEN

      ln_gas_rate := getGasStdVolSubDay(p_object_id, p_daytime,NULL);
      IF ln_gas_rate > 0 THEN    -- Only worth getting CGR if Gas is > 0
        ln_ret_val := ln_gas_rate * findCondGasRatio(p_object_id, p_daytime, NULL, NULL,'PWEL_SUB_DAY_STATUS');
      ELSIF ln_gas_rate = 0 THEN
        ln_ret_val := 0; 		-- if gas rate = 0, then condensate is also zero
      ELSE
         ln_ret_val := NULL;
      END IF;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getCondStdVolSubDay(
                     p_object_id,
                     p_daytime);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM) THEN
     ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
     lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);
     ln_ret_val  := lr_sub_day_rec.avg_mpm_cond_rate;
     ln_ret_val       := ln_ret_val * ln_on_strm_ratio;	  -- calculate mpm day rate to a mpm sub daily volume
   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
     ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
     ln_ret_val       := lr_sub_day_rec.avg_mpm_cond_rate * ln_on_strm_ratio; --Returns MPM value without subtraction of artificial lifts

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2) THEN
     ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
     lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);
     ln_ret_val  := lr_sub_day_rec.avg_mpm2_cond_rate;
     ln_ret_val       := ln_ret_val * ln_on_strm_ratio;	  -- calculate mpm2 day rate to a mpm2 sub daily volume
   ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM2_NET) THEN
     ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
     ln_ret_val       := lr_sub_day_rec.avg_mpm2_cond_rate * ln_on_strm_ratio; --Returns MPM2 value without subtraction of artificial lifts

   ELSIF (lv2_calc_method = EcDp_Calc_Method.VFM_NET) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;
      ln_ret_val       := lr_sub_day_rec.avg_vfm_cond_rate * ln_on_strm_ratio;

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;

END getCondStdVolSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDiluentStdVolSubDay
-- Description    : Returns theoretical Diluent rate for a prod well during a sub daily time period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Type.pb_comp_number
--                  Ec_pwel_sub_day_status.row_by_pk
--                  EcDp_Calc_Method
--
--
-- Configuration
-- required       :
--
-- Behaviour      : p_calc_method = 'MEASURED'
--                  Get the pre-calculated volume directly from half hour table
--
--                  p_calc_method = 'CURVE'  => NOTYET since Diluent is not a curve phase
--
---------------------------------------------------------------------------------------------------

FUNCTION getDiluentStdVolSubDay(p_object_id   VARCHAR2,
                            p_daytime     DATE,
                            p_calc_method VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

lv2_calc_method   VARCHAR2(32);
ln_ret_val        NUMBER;
lr_sub_day_rec    pwel_sub_day_status%ROWTYPE;
ln_curve_value    NUMBER;
ln_on_strm_ratio  NUMBER;

BEGIN

   lv2_calc_method := Nvl(p_calc_method,ec_well_version.diluent_sub_day_method(p_object_id,
                                                                               p_daytime,
                                                                               '<='));
   lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id,
                                                      p_daytime);

   IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs/24;

      IF ln_on_strm_ratio > 0 THEN -- zero on strm ratio = zero volume
         ln_ret_val    := lr_sub_day_rec.avg_diluent_rate*ln_on_strm_ratio;
      ELSE
         ln_ret_val    := 0;
      END IF;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getDiluentStdVolSubDay(
                     p_object_id,
                     p_daytime);

   ELSE
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;

END getDiluentStdVolSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasLiftStdVolSubDay
-- Description    : Returns theoretical Gas Lift rate for a prod well during a sub daily time period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Type.pb_comp_number
--                  Ec_pwel_sub_day_status.row_by_pk
--                  EcDp_Calc_Method
--                  EcBp_Well_Theoretical.GetCurveRate
--
-- Configuration
-- required       :
--
-- Behaviour      : p_calc_method = 'MEASURED'
--                  Get the pre-calculated volume directly from half hour table
--
--                  p_calc_method = 'CURVE'
--                  Calculate the volume by using performance curve lookup.
---------------------------------------------------------------------------------------------------

FUNCTION getGasLiftStdVolSubDay(p_object_id   VARCHAR2,
                            p_daytime     DATE,
                            p_calc_method VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

lv2_calc_method   VARCHAR2(32);
ln_ret_val        NUMBER;
lr_sub_day_rec    pwel_sub_day_status%ROWTYPE;
ln_curve_value    NUMBER;
ln_on_strm_ratio  NUMBER;

BEGIN

   lv2_calc_method := Nvl(p_calc_method,ec_well_version.gas_lift_sub_day_method(p_object_id,
                                                                                p_daytime,
                                                                                '<='));
   lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id,
                                                      p_daytime);

   IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up
         ln_ret_val    := lr_sub_day_rec.avg_gl_rate*ln_on_strm_ratio;
      ELSE -- zero on strm ratio = zero volume
         ln_ret_val    := 0;
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_GAS_LIFT) THEN

      ln_on_strm_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         ln_curve_value := getCurveRate(p_object_id,
                                        EcDp_ProductionDay.getProductionDay('WELL', p_object_id, p_daytime),
                                        'GAS',
                                        'GAS_LIFT',
                                        NULL, --lr_sub_day_rec.avg_choke_size,
                                        NULL, --lr_sub_day_rec.avg_wh_press,
                                        NULL, --lr_sub_day_rec.avg_wh_temp,
                                        NULL, --lr_sub_day_rec.avg_bh_press,
                                        lr_sub_day_rec.avg_annulus_press,
                                        NULL, --lr_sub_day_rec.avg_wh_usc_press,
                                        NULL, --lr_sub_day_rec.avg_wh_dsc_press,
                                        NULL, --lr_sub_day_rec.bs_w,
                                        NULL, --lr_sub_day_rec.avg_dh_pump_speed,
                                        lr_sub_day_rec.avg_gl_choke_size,
                                        lr_sub_day_rec.avg_gl_press,
                                        NULL, --getGasLiftStdRateDay(p_object_id, p_daytime, NULL),
                                        lr_sub_day_rec.avg_gl_diff_press,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        lr_sub_day_rec.avg_dp_venturi,
                                        NULL,
                                        lv2_calc_method);

         ln_ret_val := ln_curve_value * ln_on_strm_ratio;

      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getGasLiftStdVolSubDay(
                     p_object_id,
                     p_daytime);

   ELSE
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;

END getGasLiftStdVolSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterCutPct
-- Description    : Returns BSW volume for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWaterCutPct(p_object_id    VARCHAR2,
                    p_daytime      DATE,
                    p_calc_method  VARCHAR2 DEFAULT NULL,
                    p_decline_flag VARCHAR2 DEFAULT NULL,
                    p_class_name VARCHAR2 DEFAULT NULL,
                    p_result_no NUMBER DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lv2_decline_flag   VARCHAR2(1);
   lr_well_est_detail PWEL_RESULT%ROWTYPE;
   lr_day_rec         PWEL_DAY_STATUS%ROWTYPE;
   lr_well_version    WELL_VERSION%ROWTYPE;
   lr_analysis_sample OBJECT_FLUID_ANALYSIS%ROWTYPE;
   ln_ret_val       NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;
   ld_from_date          DATE;

BEGIN

   lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_calc_method := Nvl(p_calc_method, lr_well_version.bsw_vol_method);
   lv2_decline_flag := Nvl(p_decline_flag, Nvl(lr_well_version.decline_flag, 'N'));

   IF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      lr_well_est_detail := ecdp_performance_test.getLastValidWellResult(p_object_id, ld_start_daytime);
      ln_ret_val := lr_well_est_detail.watercut_pct;

      --calculate decline
      IF lv2_decline_flag = 'Y' THEN
         lr_well_est_detail := Ecdp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_well_est_detail.valid_from_date;
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WATER_CUT', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
      lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime, '<=');
      ln_ret_val := 100 * lr_day_rec.bs_w;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
        IF p_class_name = 'PWEL_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PWEL_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
     ln_ret_val := ecdp_well_theoretical.getWaterCutPct(p_object_id, ld_start_daytime, EcDp_Phase.OIL, EcDp_Calc_Method.CURVE,p_class_name,p_result_no);

      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_performance_curve.daytime(Ecdp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, Ecdp_Curve_Purpose.PRODUCTION, EcDp_Phase.OIL, EcDp_Calc_Method.CURVE));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WATER_CUT', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN
        IF p_class_name = 'PWEL_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PWEL_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
     ln_ret_val := ecdp_well_theoretical.getWaterCutPct(p_object_id, ld_start_daytime, EcDp_Phase.LIQUID, EcDp_Calc_Method.CURVE_LIQUID, p_class_name, p_result_no);

      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_performance_curve.daytime(Ecdp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, Ecdp_Curve_Purpose.PRODUCTION, EcDp_Phase.LIQUID, EcDp_Calc_Method.CURVE_LIQUID));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WATER_CUT', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_REFERENCE) THEN
      ln_ret_val := 100 * ecdp_well_ref_values.getAttribute(p_object_id,'BSW',p_daytime);

     IF lv2_decline_flag = 'Y' THEN
        ld_from_date := ec_well_reference_value.prev_daytime(p_object_id, p_daytime);
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WATER_CUT', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.SAMPLE_ANALYSIS) THEN
      lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'WELL_SAMPLE_ANALYSIS', null, p_daytime);
      ln_ret_val := lr_analysis_sample.bs_w;

      --calculate decline
     IF lv2_decline_flag = 'Y' THEN
         ld_from_date := lr_analysis_sample.valid_from_date;
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WATER_CUT', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.ZERO) THEN
      ln_ret_val := 0;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findWaterCutPct(p_object_id,p_daytime);

   END IF;

   RETURN ln_ret_val;
END findWaterCutPct;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondGasRatio
-- Description    : Returns Condensate Gas Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findCondGasRatio(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_calc_method  VARCHAR2 DEFAULT NULL,
                          p_decline_flag VARCHAR2 DEFAULT NULL,
                          p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lv2_decline_flag   VARCHAR2(1);
   lr_well_est_detail PWEL_RESULT%ROWTYPE;
   lr_well_version    WELL_VERSION%ROWTYPE;
   lr_analysis_sample OBJECT_FLUID_ANALYSIS%ROWTYPE;
   ln_ret_val       NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;
   ld_from_date          DATE;

BEGIN

   lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');

   lv2_calc_method := Nvl(p_calc_method, lr_well_version.cgr_method);
   lv2_decline_flag := Nvl(p_decline_flag, NVL(lr_well_version.decline_flag,'N'));

   IF (lv2_calc_method IN (EcDp_Calc_Method.WELL_EST_DETAIL, EcDp_Calc_Method.WET_GAS_MEASURED, EcDp_Calc_Method.TOTALIZER_EVENT, EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE)) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      lr_well_est_detail := ecdp_performance_test.getLastValidWellResult(p_object_id, ld_start_daytime);
      ln_ret_val := lr_well_est_detail.cgr;

      IF lv2_decline_flag = 'Y' THEN
         lr_well_est_detail := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_well_est_detail.valid_from_date;
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'CGR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_GAS) THEN
        IF p_class_name = 'PWEL_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PWEL_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
      ln_ret_val := ecdp_well_theoretical.getCondensateGasRatio(p_object_id, ld_start_daytime, EcDp_Phase.GAS, EcDp_Calc_Method.CURVE_GAS,p_class_name);

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.GAS, EcDp_Calc_Method.CURVE_GAS));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'CGR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_REFERENCE) THEN
      ln_ret_val := ecdp_well_ref_values.getAttribute(p_object_id,'CGR',p_daytime);

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_well_reference_value.prev_daytime(p_object_id, p_daytime);
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'CGR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.SAMPLE_ANALYSIS) THEN
      lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'WELL_SAMPLE_ANALYSIS', null, p_daytime);
      ln_ret_val := lr_analysis_sample.cgr;

      --calculate decline
      IF lv2_decline_flag = 'Y' THEN
      ld_from_date := lr_analysis_sample.valid_from_date;
      ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'CGR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.ZERO) THEN
      ln_ret_val := 0;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findCondGasRatio(p_object_id,p_daytime);

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;
END findCondGasRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findSand
-- Description    : Returns Sand for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findSand(p_object_id    VARCHAR2,
                  p_daytime      DATE,
                  p_calc_method  VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lr_well_est_detail PWEL_RESULT%ROWTYPE;
   ln_ret_val       NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;

BEGIN

   lv2_calc_method := Nvl(p_calc_method, ec_well_version.sand_method(p_object_id,p_daytime,'<='));

   IF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      lr_well_est_detail := ecdp_performance_test.getLastValidWellResult(p_object_id, ld_start_daytime);
      ln_ret_val := lr_well_est_detail.sand_content;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findSand(p_object_id,p_daytime);

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;
END findSand;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasOilRatio
-- Description    : Returns Gas Oil Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findGasOilRatio(p_object_id    VARCHAR2,
                         p_daytime      DATE,
                         p_calc_method  VARCHAR2 DEFAULT NULL,
                         p_decline_flag VARCHAR2 DEFAULT NULL,
                         p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lv2_decline_flag           VARCHAR2(1);
   lr_well_est_detail PWEL_RESULT%ROWTYPE;
   lr_well_version           WELL_VERSION%ROWTYPE;
   ln_ret_val       NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;
   ld_from_date          DATE;

BEGIN

   lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');

   lv2_calc_method := Nvl(p_calc_method, lr_well_version.gor_method);
   lv2_decline_flag := Nvl(p_decline_flag, NVL(lr_well_version.decline_flag,'N'));

   IF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      lr_well_est_detail := ecdp_performance_test.getLastValidWellResult(p_object_id, ld_start_daytime);
      ln_ret_val := lr_well_est_detail.gor;

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         lr_well_est_detail := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_well_est_detail.valid_from_date;
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'GOR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
        IF p_class_name = 'PWEL_DAY_STATUS' THEN
            ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
            ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PWEL_SUB_DAY_STATUS' THEN
            ld_start_daytime := p_daytime;
        ELSE
            ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
            ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
      ln_ret_val := ecdp_well_theoretical.getGasOilRatio(p_object_id, ld_start_daytime, EcDp_Phase.OIL, EcDp_Calc_Method.CURVE,p_class_name);

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.OIL,EcDp_Calc_Method.CURVE));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'GOR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN
        IF p_class_name = 'PWEL_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PWEL_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
      ln_ret_val := ecdp_well_theoretical.getGasOilRatio(p_object_id, ld_start_daytime, EcDp_Phase.LIQUID, EcDp_Calc_Method.CURVE_LIQUID,p_class_name);

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.LIQUID,EcDp_Calc_Method.CURVE_LIQUID));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'GOR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_REFERENCE) THEN
      ln_ret_val := ecdp_well_ref_values.getAttribute(p_object_id,'GOR',p_daytime);

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_well_reference_value.prev_daytime(p_object_id, p_daytime);
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'GOR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.ZERO) THEN
      ln_ret_val := 0;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findGasOilRatio(p_object_id,p_daytime);

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;
END findGasOilRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWetDryFactor
-- Description    : Returns Wet Dry Factor Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWetDryFactor(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_calc_method  VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lr_well_est_detail PWEL_RESULT%ROWTYPE;
   ln_ret_val       NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;

BEGIN

   lv2_calc_method := Nvl(p_calc_method, ec_well_version.wdf_method(p_object_id,p_daytime,'<='));

   IF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      lr_well_est_detail := ecdp_performance_test.getLastValidWellResult(p_object_id, ld_start_daytime);
      ln_ret_val := lr_well_est_detail.wet_dry_gas_ratio;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.ONE) THEN
      ln_ret_val := 1;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findWetDryFactor(p_object_id,p_daytime);

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;
END findWetDryFactor;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrsLoadOilStdRateDay
-- Description    : Returns the total gross load oil delivery to a given well for a given day
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrsLoadOilStdRateDay(p_object_id   well.object_id%TYPE,
                              p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

   ln_ret_val            NUMBER;

   CURSOR c_well_loadoil_event(cp_object_id VARCHAR2, cp_day DATE) IS
    SELECT event_no
    FROM well_transport_event
    WHERE object_id = cp_object_id
    AND production_day = cp_day
    AND data_class_name = 'WELL_LOADED_FROM_TRUCK'
    UNION ALL
    SELECT event_no
    FROM object_transport_event
    WHERE to_object_id = cp_object_id
    AND production_day = cp_day
    AND data_class_name = 'OBJECT_SINGLE_TRANSFER'
    AND to_object_type = 'WELL';

   BEGIN

    ln_ret_val := 0;

    FOR curEvent IN c_well_loadoil_event(p_object_id, p_daytime) LOOP
       ln_ret_val :=  ln_ret_val + EcBp_Truck_Ticket.findGrsStdVol(curEvent.Event_No);
    END LOOP;

    RETURN ln_ret_val;

    END getGrsLoadOilStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNetLoadOilStdRateDay
-- Description    : Returns the total gross load oil delivery to a given well for a given day
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getNetLoadOilStdRateDay(p_object_id   well.object_id%TYPE,
                              p_daytime     DATE,
                              p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

   ln_ret_val            NUMBER;

   CURSOR c_well_loadoil_event(cp_object_id VARCHAR2, cp_day DATE, cp_todate DATE) IS
    SELECT event_no
    FROM well_transport_event
    WHERE object_id = cp_object_id
    AND production_day BETWEEN cp_day and NVL(cp_todate, cp_day)
    AND data_class_name = 'WELL_LOADED_FROM_TRUCK'
    UNION ALL
    SELECT event_no
    FROM object_transport_event
    WHERE to_object_id = cp_object_id
    AND production_day BETWEEN cp_day and NVL(cp_todate, cp_day)
    AND data_class_name = 'OBJECT_SINGLE_TRANSFER'
    AND to_object_type = 'WELL';

   BEGIN

    ln_ret_val := 0;

    FOR curEvent IN c_well_loadoil_event(p_object_id, p_daytime, p_today) LOOP
       ln_ret_val :=  ln_ret_val + EcBp_Truck_Ticket.findNetStdVol(curEvent.Event_No);
    END LOOP;

    RETURN ln_ret_val;

END getNetLoadOilStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastInjRateDaytime
-- Description    : Returns the latest available daily injection rate on a given
--                  daytime on or prior to a given daytime
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getLastNotNullInjRate(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_inj_type    VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS


CURSOR c_iwel_day_status(cp_object_id well.object_id%TYPE, cp_daytime DATE, cp_inj_type VARCHAR2) IS
  SELECT inj_rate
  FROM iwel_day_status
  WHERE object_id = cp_object_id
  AND inj_type = cp_inj_type
  AND daytime = (
  SELECT max(daytime)From iwel_day_status i2
  WHERE i2.object_id = cp_object_id
  AND i2.inj_type = cp_inj_type
  AND i2.inj_rate is not null
  AND i2.daytime <= cp_daytime);

  ln_inj_rate  NUMBER;

BEGIN

   FOR curRec IN c_iwel_day_status(p_object_id, p_daytime, p_inj_type) LOOP
     ln_inj_rate := curRec.inj_rate;
   END LOOP;

   RETURN ln_inj_rate;

END getLastNotNullInjRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjectedStdVolume
-- Description    : Returns the volume for the whole totalizer event.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getInjectedStdVolume(p_object_id   well.object_id%TYPE,
                              p_class_name VARCHAR2,
                              p_daytime    DATE)
RETURN NUMBER
--</EC-DOC>
IS

lv2_calc_inj_method VARCHAR2(32);
lv2_inj_type        VARCHAR2(32);
ln_return_val       NUMBER;
ln_closing_reading  NUMBER;
ln_opening_reading  NUMBER;
ln_opening          NUMBER;
ln_rollover_val     NUMBER;
ln_meter_factor     NUMBER;
ln_conver_factor    NUMBER;
ln_manual_adj       NUMBER;
ln_day_rate         NUMBER;
ln_prod_day_offset  NUMBER;
ln_totalizer_frac   NUMBER;
ln_fraction         NUMBER;
ld_maxdaytime       DATE;
ld_from_date        DATE;
ld_to_date          DATE;



CURSOR c_well_period_totalizer(cp_object_id VARCHAR2, cp_class_name VARCHAR2, cp_fromday DATE) IS
SELECT *
FROM well_period_totalizer
WHERE object_id = cp_object_id
AND daytime = cp_fromday
AND class_name = cp_class_name;

CURSOR c_system_days(cp_fromday DATE, cp_todate DATE) IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN cp_fromday - 1 AND cp_todate -- totalizers must have end_date, no default NVL(). In this case cd_todate is inclusive as well.
ORDER BY daytime ASC;


BEGIN

  IF (p_class_name = 'IWEL_TOTALIZER_GAS') THEN
    lv2_calc_inj_method :=  ec_well_version.calc_inj_method(p_object_id,p_daytime,'<=');
    lv2_inj_type       :=  'GI';
  ELSIF (p_class_name = 'IWEL_TOTALIZER_WAT') THEN
    lv2_calc_inj_method :=  ec_well_version.calc_water_inj_method(p_object_id,p_daytime,'<=');
    lv2_inj_type       :=  'WI';
  END IF;


  IF (lv2_calc_inj_method = EcDp_Calc_Method.TOTALIZER_EVENT) THEN

    FOR cur_well_period_totalizer IN c_well_period_totalizer(p_object_id, p_class_name, p_daytime) LOOP
      ln_closing_reading :=  cur_well_period_totalizer.closing_reading;
      ln_opening_reading :=  cur_well_period_totalizer.opening_reading;
      ln_opening         :=  ec_well_period_totalizer.closing_reading(cur_well_period_totalizer.object_id,cur_well_period_totalizer.class_name,cur_well_period_totalizer.daytime,'<');
      ln_meter_factor    :=  ec_well_reference_value.meter_factor(p_object_id,p_daytime, '<=');
      ln_conver_factor   :=  ec_well_reference_value.conversion_factor(p_object_id,p_daytime, '<=');
      ln_manual_adj      :=  cur_well_period_totalizer.manual_adjustment;
      ln_rollover_val    :=  ec_well_reference_value.totalizer_max_count(cur_well_period_totalizer.object_id, cur_well_period_totalizer.daytime,'<=');

      -- to check if ln_opening_reading is null
      IF ln_opening_reading IS NULL THEN
         IF ec_well_reference_value.volume_entry_flag(cur_well_period_totalizer.object_id,cur_well_period_totalizer.daytime,'<=') = 'Y' THEN
            ln_opening := 0;
         END IF;
      END IF;

      IF (ln_opening_reading > ln_closing_reading) THEN
        ln_return_val := ((ln_closing_reading - NVL(ln_opening_reading,ln_opening) + ln_rollover_val) * NVL(ln_meter_factor, 1)*  NVL(ln_conver_factor, 1)) + NVL( ln_manual_adj, 0) ;
      ELSE
        ln_return_val := ((ln_closing_reading - NVL(ln_opening_reading,ln_opening)) * NVL(ln_meter_factor, 1)*  NVL(ln_conver_factor, 1)) + NVL( ln_manual_adj, 0) ;
      END IF;
    END LOOP;

  ELSIF (lv2_calc_inj_method = EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE) THEN

    ln_fraction := 0;
    ln_return_val  := null;
    ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime)/24);

    ln_closing_reading :=  ec_well_period_totalizer.closing_reading(p_object_id, p_class_name, p_daytime, '=');
    ln_opening_reading :=  ec_well_period_totalizer.opening_reading(p_object_id, p_class_name, p_daytime, '=');
    ln_opening         :=  ec_well_period_totalizer.closing_reading(p_object_id, p_class_name, p_daytime, '<');

          -- to check if ln_opening_reading is null
    IF ln_opening_reading IS NULL THEN
       IF ec_well_reference_value.volume_entry_flag(p_object_id, p_daytime, '<=') = 'Y' THEN
          ln_opening := 0;
       END IF;
    END IF;

    IF ln_closing_reading IS NULL AND (ln_opening_reading IS NULL OR ln_opening IS NULL) THEN
      ld_maxdaytime      := getLastNotNullClosingValueDate(p_object_id, p_class_name, p_daytime);
      IF ld_maxdaytime is NOT NULL THEN
        ln_day_rate    := getInjectedStdDailyRate(p_object_id, p_class_name, ld_maxdaytime); -- get Daily rate

        FOR cur_well_period_totalizer_extp IN c_well_period_totalizer( p_object_id, p_class_name, p_daytime) LOOP
          ld_from_date   := cur_well_period_totalizer_extp.daytime - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)
          ld_to_date     := cur_well_period_totalizer_extp.end_date - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)

          FOR mycur IN c_system_days(ld_from_date, ld_to_date) LOOP -- loop all days this totalizer are involved in
            -- calculate fraction for each day as: fraction of day covered by totalizer * on_time that day.
            ln_totalizer_frac := least((cur_well_period_totalizer_extp.end_date - ln_prod_day_offset),mycur.daytime+1) - greatest((cur_well_period_totalizer_extp.daytime - ln_prod_day_offset),mycur.daytime);
            ln_fraction       := ln_fraction + (ln_totalizer_frac * NVL(EcDp_Well.getIwelOnStreamHrs(p_object_id, lv2_inj_type, mycur.daytime),0));
          END LOOP;

          IF ln_fraction > 0 THEN
            ln_return_val := ln_day_rate * ln_fraction / 24;
          ELSE
            ln_return_val := null;
          END IF;
        END LOOP;
      END IF;
    ELSE   -- Opening Reading and Closing Reading values are entered by users
      ln_meter_factor    :=  ec_well_reference_value.meter_factor(p_object_id,p_daytime, '<=');
      ln_conver_factor   :=  ec_well_reference_value.conversion_factor(p_object_id,p_daytime, '<=');
      ln_manual_adj      :=  ec_well_period_totalizer.manual_adjustment(p_object_id, p_class_name, p_daytime, '=');
      ln_rollover_val    :=  ec_well_reference_value.totalizer_max_count(p_object_id,p_daytime, '<=');

      IF (ln_opening_reading > ln_closing_reading) THEN
        ln_return_val := ((ln_closing_reading - NVL(ln_opening_reading,ln_opening) + ln_rollover_val) * NVL(ln_meter_factor, 1)*  NVL(ln_conver_factor, 1)) + NVL( ln_manual_adj, 0) ;
      ELSE
        ln_return_val := ((ln_closing_reading - NVL(ln_opening_reading,ln_opening))* NVL(ln_meter_factor, 1)*  NVL(ln_conver_factor, 1)) + NVL( ln_manual_adj, 0) ;
      END IF;
    END IF;
  END IF ;
  RETURN ln_return_val;
END getInjectedStdVolume;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjectedStdDailyRate
-- Description    : Returns a calculated daily rate (24 hours) for the totalizer reading. The daily rate is representative for a open well.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getInjectedStdDailyRate(p_object_id   well.object_id%TYPE,
                                 p_class_name    VARCHAR2,
                                 p_daytime    DATE)


RETURN NUMBER
--</EC-DOC>
IS

lv2_calc_inj_method VARCHAR2(32);
ln_net_vol          NUMBER;
ln_return_val       NUMBER;
ln_prod_day_offset  NUMBER;
ln_totalizer_frac   NUMBER;
ln_fraction         NUMBER;
ld_from_date        DATE;
ld_to_date          DATE;
lv2_inj_type        VARCHAR2(32);


CURSOR c_well_period_totalizer(cp_class_name VARCHAR2, cp_daytime DATE) IS
SELECT *
FROM well_period_totalizer
WHERE object_id = p_object_id
AND daytime = cp_daytime
AND class_name = cp_class_name;

CURSOR c_system_days(cp_fromday DATE, cp_todate DATE) IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN cp_fromday - 1 AND cp_todate -- totalizers must have end_date, no default NVL(). In this case cd_todate is inclusive as well.
ORDER BY daytime ASC;

BEGIN

  IF (p_class_name = 'IWEL_TOTALIZER_GAS') THEN
    lv2_calc_inj_method :=  ec_well_version.calc_inj_method(p_object_id,p_daytime,'<=');
    lv2_inj_type       :=  'GI';
  ELSIF (p_class_name = 'IWEL_TOTALIZER_WAT') THEN
    lv2_calc_inj_method :=  ec_well_version.calc_water_inj_method(p_object_id,p_daytime,'<=');
    lv2_inj_type       :=  'WI';
  END IF;

  IF (lv2_calc_inj_method = EcDp_Calc_Method.TOTALIZER_EVENT) THEN

    ln_net_vol  := getInjectedStdVolume(p_object_id, p_class_name, p_daytime); -- total volume for the period
    ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime)/24);
    ln_fraction := 0;
    ln_totalizer_frac := 0;

    FOR cur_totalizer IN c_well_period_totalizer(p_class_name, p_daytime) LOOP
      -- find first and last production date
      ld_from_date := cur_totalizer.daytime - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)
      ld_to_date   := cur_totalizer.end_date - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)

      FOR mycur IN c_system_days(ld_from_date, ld_to_date) LOOP -- loop all days this totalizer are involved in
       -- calculate fraction for each day as: fraction of day covered by totalizer * on_time that day.
        ln_totalizer_frac := least((cur_totalizer.end_date - ln_prod_day_offset),mycur.daytime+1) - greatest((cur_totalizer.daytime - ln_prod_day_offset),mycur.daytime);
        ln_fraction := ln_fraction + (ln_totalizer_frac * NVL(EcDp_Well.getIwelOnStreamHrs(p_object_id, lv2_inj_type, mycur.daytime),0));
      END LOOP;

      IF ln_fraction > 0 THEN
        ln_return_val := ln_net_vol / ln_fraction * 24;
      ELSE
        ln_return_val := null;
      END IF;
    END LOOP;

  ELSIF (lv2_calc_inj_method = EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE) THEN

    ln_net_vol         := getInjectedStdVolume(p_object_id, p_class_name, p_daytime); -- total volume for the period
    ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime)/24);
    ln_fraction := 0;

    FOR cur_totalizer_extp IN c_well_period_totalizer(p_class_name, p_daytime) LOOP
      ld_from_date := cur_totalizer_extp.daytime - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)
      ld_to_date   := cur_totalizer_extp.end_date - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)

      FOR mycur IN c_system_days(ld_from_date, ld_to_date) LOOP -- loop all days this totalizer are involved in
      -- calculate fraction for each day as: fraction of day covered by totalizer * on_time that day.
        ln_totalizer_frac := least((cur_totalizer_extp.end_date - ln_prod_day_offset),mycur.daytime+1) - greatest((cur_totalizer_extp.daytime - ln_prod_day_offset),mycur.daytime);
        ln_fraction       := ln_fraction + (ln_totalizer_frac * NVL(EcDp_Well.getIwelOnStreamHrs(p_object_id, lv2_inj_type, mycur.daytime),0));
      END LOOP;

      IF ln_fraction > 0 THEN
        ln_return_val := ln_net_vol / ln_fraction * 24 ;
      ELSE
        ln_return_val := null;
      END IF;
    END LOOP;
  END IF;
  RETURN ln_return_val;
END getInjectedStdDailyRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProducedtdVolume
-- Description    : Returns the volume for the whole totalizer event.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProducedStdVolume(p_object_id   well.object_id%TYPE,
                              p_class_name VARCHAR2,
                              p_daytime    DATE)
RETURN NUMBER
--</EC-DOC>
IS

lv2_calc_method VARCHAR2(32);
ln_return_val       NUMBER;
ln_closing_reading  NUMBER;
ln_opening_reading  NUMBER;
ln_opening          NUMBER;
ln_rollover_val     NUMBER;
ln_meter_factor     NUMBER;
ln_conver_factor    NUMBER;
ln_gravity_factor   NUMBER;
ln_manual_adj       NUMBER;
ln_day_rate         NUMBER;
ln_prod_day_offset  NUMBER;
ln_totalizer_frac   NUMBER;
ln_fraction         NUMBER;
ld_maxdaytime       DATE;
ld_from_date        DATE;
ld_to_date          DATE;
lv2_oil_well_type   VARCHAR2(1);
lv2_cond_well_type  VARCHAR2(1);

CURSOR c_well_period_totalizer(cp_object_id VARCHAR2, cp_class_name VARCHAR2, cp_fromday DATE) IS
SELECT *
FROM well_period_totalizer
WHERE object_id = cp_object_id
AND class_name = cp_class_name
AND daytime = cp_fromday;

CURSOR c_system_days(cp_fromday DATE, cp_todate DATE) IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN cp_fromday - 1 AND cp_todate -- totalizers must have end_date, no default NVL(). In this case cd_todate is inclusive as well.
ORDER BY daytime ASC;

BEGIN

  IF (p_class_name = 'PWEL_TOTALIZER_GAS') THEN
    lv2_calc_method :=  ec_well_version.calc_gas_method(p_object_id, p_daytime,'<=');
  ELSIF (p_class_name = 'PWEL_TOTALIZER_LIQ') THEN
    lv2_oil_well_type := ec_well_version.isoilproducer(p_object_id, p_daytime,'<=');
    lv2_cond_well_type := ec_well_version.iscondensateproducer(p_object_id, p_daytime,'<=');
    -- If ISOILPRODUCER = Y
    IF (lv2_oil_well_type = 'Y') THEN
       lv2_calc_method := ec_well_version.calc_method(p_object_id, p_daytime,'<=');
    END IF;

    -- If ISCONDENSATEPRODUCER = Y
    IF (lv2_cond_well_type = 'Y') THEN
       lv2_calc_method := ec_well_version.calc_cond_method(p_object_id, p_daytime,'<=');
    END IF;
  END IF;

  IF (lv2_calc_method = EcDp_Calc_Method.TOTALIZER_EVENT) THEN

    FOR cur_well_period_totalizer IN c_well_period_totalizer(p_object_id, p_class_name, p_daytime) LOOP
      ln_closing_reading :=  cur_well_period_totalizer.closing_reading;
      ln_opening_reading :=  cur_well_period_totalizer.opening_reading; --override
      ln_opening         :=  ec_well_period_totalizer.closing_reading(cur_well_period_totalizer.object_id,cur_well_period_totalizer.class_name,cur_well_period_totalizer.daytime,'<');
      ln_meter_factor    :=  ec_well_reference_value.meter_factor(p_object_id,p_daytime, '<=');
      ln_conver_factor   :=  ec_well_reference_value.conversion_factor(p_object_id,p_daytime, '<=');
      ln_gravity_factor  :=  ec_well_reference_value.gravity_factor(p_object_id,p_daytime, '<=');
      ln_manual_adj      :=  cur_well_period_totalizer.manual_adjustment;
      ln_rollover_val    :=  ec_well_reference_value.totalizer_max_count(cur_well_period_totalizer.object_id, cur_well_period_totalizer.daytime,'<=');

      -- to check if ln_opening_reading is null
      IF ln_opening_reading IS NULL THEN
         IF ec_well_reference_value.volume_entry_flag(cur_well_period_totalizer.object_id,cur_well_period_totalizer.daytime,'<=') = 'Y' THEN
            ln_opening := 0;
         END IF;
      END IF;

      IF ln_closing_reading < NVL(ln_opening_reading, ln_opening) THEN
        ln_return_val := ((ln_closing_reading - NVL(ln_opening_reading,ln_opening) + ln_rollover_val) * NVL(ln_meter_factor, 1) *  NVL(ln_conver_factor, 1) *  NVL(ln_gravity_factor, 1)) + NVL( ln_manual_adj, 0) ;
      ELSE
        ln_return_val := ((ln_closing_reading - NVL(ln_opening_reading,ln_opening)) * NVL(ln_meter_factor, 1)*  NVL(ln_conver_factor, 1) *  NVL(ln_gravity_factor, 1)) + NVL( ln_manual_adj, 0) ;
      END IF;
    END LOOP;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE) THEN

    ln_fraction := 0;
    ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime)/24);

    ln_closing_reading :=  ec_well_period_totalizer.closing_reading(p_object_id, p_class_name, p_daytime, '=');
    ln_opening_reading :=  ec_well_period_totalizer.opening_reading(p_object_id, p_class_name, p_daytime, '=');
    ln_opening         :=  ec_well_period_totalizer.closing_reading(p_object_id, p_class_name, p_daytime, '<');

    -- to check if ln_opening_reading is null
    IF ln_opening_reading IS NULL THEN
       IF ec_well_reference_value.volume_entry_flag(p_object_id, p_daytime, '<=') = 'Y' THEN
          ln_opening := 0;
       END IF;
    END IF;

    IF ln_closing_reading IS NULL AND (ln_opening_reading IS NULL OR ln_opening IS NULL) THEN
      ld_maxdaytime  :=  getLastNotNullClosingValueDate(p_object_id, p_class_name, p_daytime);

      IF ld_maxdaytime is NOT NULL THEN
        ln_day_rate    := getProducedStdDailyRate(p_object_id, p_class_name, ld_maxdaytime); -- get Daily rate
        FOR cur_well_period_totalizer_extp IN c_well_period_totalizer( p_object_id, p_class_name, p_daytime) LOOP
          ld_from_date   := cur_well_period_totalizer_extp.daytime - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)
          ld_to_date     := cur_well_period_totalizer_extp.end_date - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)

          FOR mycur IN c_system_days(ld_from_date, ld_to_date) LOOP -- loop all days this totalizer are involved in
            -- calculate fraction for each day as: fraction of day covered by totalizer * on_time that day.
            ln_totalizer_frac := least((cur_well_period_totalizer_extp.end_date - ln_prod_day_offset),mycur.daytime+1) - greatest((cur_well_period_totalizer_extp.daytime - ln_prod_day_offset),mycur.daytime);
            ln_fraction       := ln_fraction + (ln_totalizer_frac * NVL(EcDp_Well.getPwelOnStreamHrs(p_object_id, mycur.daytime),0));
          END LOOP;

          IF ln_fraction > 0 THEN
            ln_return_val := ln_day_rate * ln_fraction / 24;
          ELSE
            ln_return_val := null;
          END IF;
        END LOOP;
      END IF;
    ELSE   -- Opening Reading and Closing Reading values are entered by users
      ln_meter_factor    :=  ec_well_reference_value.meter_factor(p_object_id,p_daytime, '<=');
      ln_conver_factor   :=  ec_well_reference_value.conversion_factor(p_object_id,p_daytime, '<=');
      ln_gravity_factor  :=  ec_well_reference_value.gravity_factor(p_object_id,p_daytime, '<=');
      ln_manual_adj      :=  ec_well_period_totalizer.manual_adjustment(p_object_id, p_class_name, p_daytime, '=');
      ln_rollover_val    :=  ec_well_reference_value.totalizer_max_count(p_object_id,p_daytime, '<=');

      IF ln_closing_reading < NVL(ln_opening_reading, ln_opening) THEN
        ln_return_val := ((ln_closing_reading - NVL(ln_opening_reading,ln_opening) + ln_rollover_val) * NVL(ln_meter_factor, 1)*  NVL(ln_conver_factor, 1) * NVL(ln_gravity_factor, 1)) + NVL( ln_manual_adj, 0) ;
      ELSE
        ln_return_val := ((ln_closing_reading - NVL(ln_opening_reading,ln_opening))* NVL(ln_meter_factor, 1)*  NVL(ln_conver_factor, 1) *  NVL(ln_gravity_factor, 1)) + NVL( ln_manual_adj, 0) ;
      END IF;
    END IF;
  END IF;
  RETURN ln_return_val;
END getProducedStdVolume;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProducedStdDailyRate
-- Description    : Returns a calculated daily rate for the totalizer reading. The daily rate is representative for a open well.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProducedStdDailyRate(p_object_id   well.object_id%TYPE,
                                 p_class_name    VARCHAR2,
                                 p_daytime    DATE)


RETURN NUMBER
--</EC-DOC>
IS

lv2_calc_method VARCHAR2(32);
ln_net_vol          NUMBER;
ln_return_val       NUMBER;
ln_prod_day_offset  NUMBER;
ln_totalizer_frac   NUMBER;
ln_fraction         NUMBER;
ld_from_date        DATE;
ld_to_date          DATE;
lv2_oil_well_type   VARCHAR2(1);
lv2_cond_well_type  VARCHAR2(1);

CURSOR c_well_period_totalizer(cp_class_name VARCHAR2, cp_daytime DATE) IS
SELECT *
FROM well_period_totalizer
WHERE object_id = p_object_id
AND daytime = cp_daytime
AND class_name = cp_class_name;

CURSOR c_system_days(cp_fromday DATE, cp_todate DATE) IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN cp_fromday - 1 AND cp_todate -- totalizers must have end_date, no default NVL(). In this case cd_todate is inclusive as well.
ORDER BY daytime ASC;

BEGIN

  IF (p_class_name = 'PWEL_TOTALIZER_GAS') THEN
    lv2_calc_method :=  ec_well_version.calc_gas_method(p_object_id, p_daytime,'<=');
  ELSIF (p_class_name = 'PWEL_TOTALIZER_LIQ') THEN
    lv2_oil_well_type := ec_well_version.isoilproducer(p_object_id, p_daytime,'<=');
    lv2_cond_well_type := ec_well_version.iscondensateproducer(p_object_id, p_daytime,'<=');
    -- If ISOILPRODUCER = Y
    IF (lv2_oil_well_type = 'Y') THEN
       lv2_calc_method := ec_well_version.calc_method(p_object_id, p_daytime,'<=');
    END IF;

    -- If ISCONDENSATEPRODUCER = Y
    IF (lv2_cond_well_type = 'Y') THEN
       lv2_calc_method := ec_well_version.calc_cond_method(p_object_id, p_daytime,'<=');
    END IF;
  END IF;



  IF (lv2_calc_method = EcDp_Calc_Method.TOTALIZER_EVENT) THEN
    ln_net_vol  := getProducedStdVolume(p_object_id, p_class_name, p_daytime); -- total volume for the period
    ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime)/24);
    ln_fraction := 0;

    FOR cur_totalizer IN c_well_period_totalizer(p_class_name, p_daytime) LOOP
      -- find first and last production date
      ld_from_date := cur_totalizer.daytime - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)
      ld_to_date   := cur_totalizer.end_date - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)

      FOR mycur IN c_system_days(ld_from_date, ld_to_date) LOOP -- loop all days this totalizer are involved in
       -- calculate fraction for each day as: fraction of day covered by totalizer * on_time that day.
        ln_totalizer_frac := least((cur_totalizer.end_date - ln_prod_day_offset),mycur.daytime+1) - greatest((cur_totalizer.daytime - ln_prod_day_offset),mycur.daytime);
        ln_fraction := ln_fraction + (ln_totalizer_frac * NVL(EcDp_Well.getPwelOnStreamHrs(p_object_id, mycur.daytime),0));
      END LOOP;

      IF ln_fraction > 0 THEN
        ln_return_val := ln_net_vol / ln_fraction * 24;
      ELSE
        ln_return_val := null;
      END IF;

    END LOOP;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.TOTALIZER_EVENT_EXTRAPOLATE) THEN
    ln_net_vol         := getProducedStdVolume(p_object_id, p_class_name, p_daytime); -- total volume for the period
    ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime)/24);
    ln_fraction := 0;

    FOR cur_totalizer_extp IN c_well_period_totalizer(p_class_name, p_daytime) LOOP
      ld_from_date := cur_totalizer_extp.daytime - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)
      ld_to_date   := cur_totalizer_extp.end_date - ln_prod_day_offset; -- take away offset, e.g. 6/24 hours, the rest is production day)

      FOR mycur IN c_system_days(ld_from_date, ld_to_date) LOOP -- loop all days this totalizer are involved in
        -- calculate fraction for each day as: fraction of day covered by totalizer * on_time that day.
        ln_totalizer_frac := least((cur_totalizer_extp.end_date - ln_prod_day_offset),mycur.daytime+1) - greatest((cur_totalizer_extp.daytime - ln_prod_day_offset),mycur.daytime);
        ln_fraction       := ln_fraction + (ln_totalizer_frac * NVL(EcDp_Well.getPwelOnStreamHrs(p_object_id, mycur.daytime),0));
      END LOOP;
      IF ln_fraction > 0 THEN
        ln_return_val := ln_net_vol / ln_fraction * 24 ;
      ELSE
        ln_return_val := null;
      END IF;
    END LOOP;
  END IF;
  RETURN ln_return_val;
END getProducedStdDailyRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastNotNullClosingValueDate
-- Description    : Returns the latest available date where the closing reading is not null and within the same month or next month
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getLastNotNullClosingValueDate(
    p_object_id well.object_id%TYPE,
   p_class_name    VARCHAR2,
    p_daytime DATE)
RETURN DATE
--</EC-DOC>
IS


CURSOR c_well_period_tot IS
  SELECT max(daytime) max_daytime
  FROM well_period_totalizer
  WHERE object_id = p_object_id
  AND class_name = p_class_name
  AND (to_char(to_date(p_daytime), 'yyyymm') between to_char(to_date(end_date), 'yyyymm') AND to_char(add_months(to_date(TRUNC(to_date(end_date), 'mm')), 1), 'yyyymm'))
  AND CLOSING_READING IS NOT NULL
  ORDER BY daytime ASC;

  ld_max_daytime  DATE;

BEGIN

   FOR curRec IN c_well_period_tot LOOP
     ld_max_daytime := curRec.max_daytime;
   END LOOP;

   RETURN ld_max_daytime;

END getLastNotNullClosingValueDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrsLoadOilMassDay
-- Description    : Returns the total gross load oil delivery to a given well for a given day
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrsLoadOilMassDay(p_object_id   well.object_id%TYPE,
                              p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

  ln_ret_val    NUMBER;
  lb_first      BOOLEAN;

  CURSOR c_well_loadoil_event IS
    SELECT event_no
    FROM well_transport_event wte
    WHERE wte.object_id = p_object_id
    AND wte.production_day = p_daytime
    AND wte.data_class_name = 'WELL_LOADED_FROM_TRUCK'
    UNION ALL
    SELECT event_no
    FROM object_transport_event ote
    WHERE ote.object_id = p_object_id
    AND ote.production_day = p_daytime
    AND ote.data_class_name = 'OBJECT_SINGLE_TRANSFER'
    AND ote.object_type = 'WELL';

BEGIN
  lb_first:= TRUE;
  FOR myCur IN c_well_loadoil_event LOOP
    IF lb_first THEN
      ln_ret_val:= EcBp_Truck_Ticket.findWellGrsStdMass(myCur.event_no,p_object_id);
      lb_first:= FALSE;
    ELSE
      ln_ret_val:= ln_ret_val + EcBp_Truck_Ticket.findWellGrsStdMass(myCur.event_no, p_object_id);
    END IF;
  END LOOP;
  RETURN ln_ret_val;

END getGrsLoadOilMassDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNetLoadOilMassDay
-- Description    : Returns the total gross load oil delivery to a given well for a given day
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getNetLoadOilMassDay(p_object_id   well.object_id%TYPE,
                              p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

 ln_ret_val    NUMBER;
   lb_first      BOOLEAN;

  CURSOR c_well_loadoil_event IS
    SELECT event_no
    FROM well_transport_event wte
    WHERE wte.object_id = p_object_id
    AND wte.production_day = p_daytime
    AND wte.data_class_name = 'WELL_LOADED_FROM_TRUCK'
    UNION ALL
    SELECT event_no
    FROM object_transport_event ote
    WHERE ote.object_id = p_object_id
    AND ote.production_day = p_daytime
    AND ote.data_class_name = 'OBJECT_SINGLE_TRANSFER'
    AND ote.object_type = 'WELL';

BEGIN
  lb_first:= TRUE;
  FOR myCur IN c_well_loadoil_event LOOP
    IF lb_first THEN
      ln_ret_val:= EcBp_Truck_Ticket.findWellNetStdMass(myCur.event_no,p_object_id);
      lb_first:= FALSE;
    ELSE
      ln_ret_val:= ln_ret_val + EcBp_Truck_Ticket.findWellNetStdMass(myCur.event_no,p_object_id);
    END IF;
  END LOOP;
  RETURN ln_ret_val;

END getNetLoadOilMassDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterGasRatio
-- Description    : Returns Water Gas Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWaterGasRatio(p_object_id    VARCHAR2,
                         p_daytime      DATE,
                         p_calc_method  VARCHAR2 DEFAULT NULL,
                         p_decline_flag VARCHAR2 DEFAULT NULL,
                         p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lv2_decline_flag   VARCHAR2(1);
   lr_well_est_detail PWEL_RESULT%ROWTYPE;
   lr_well_version           WELL_VERSION%ROWTYPE;
   ln_ret_val       NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;
   ld_from_date          DATE;

BEGIN

   lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');

   lv2_calc_method := Nvl(p_calc_method, lr_well_version.wgr_method);
   lv2_decline_flag := Nvl(p_decline_flag, NVL(lr_well_version.decline_flag,'N'));

   IF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      lr_well_est_detail := ecdp_performance_test.getLastValidWellResult(p_object_id, ld_start_daytime);
      ln_ret_val := lr_well_est_detail.wgr;

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         lr_well_est_detail := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_well_est_detail.valid_from_date;
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WGR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_GAS) THEN
        IF p_class_name = 'PWEL_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PWEL_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
      ln_ret_val := ecdp_well_theoretical.getWaterGasRatio(p_object_id, ld_start_daytime, EcDp_Phase.GAS, EcDp_Calc_Method.CURVE_GAS,p_class_name);

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.GAS, EcDp_Calc_Method.CURVE_GAS));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WGR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_REFERENCE) THEN
      ln_ret_val := ec_well_reference_value.wgr(p_object_id, p_daytime, '<=');

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_well_reference_value.prev_daytime(p_object_id, p_daytime);
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WGR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.ZERO) THEN
      ln_ret_val := 0;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findWaterGasRatio(p_object_id,p_daytime);

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;

END findWaterGasRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterOilRatio
-- Description    : Returns Water Oil Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWaterOilRatio(p_object_id    VARCHAR2,
                         p_daytime      DATE,
                         p_calc_method  VARCHAR2 DEFAULT NULL,
                         p_decline_flag VARCHAR2 DEFAULT NULL,
                         p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lv2_decline_flag           VARCHAR2(1);
   lr_well_est_detail PWEL_RESULT%ROWTYPE;
   lr_well_version           WELL_VERSION%ROWTYPE;
   ln_ret_val            NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;
   ld_from_date          DATE;

BEGIN

   lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');

   lv2_calc_method := Nvl(p_calc_method, lr_well_version.wor_method);
   lv2_decline_flag := Nvl(p_decline_flag, NVL(lr_well_version.decline_flag,'N'));

  IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
        IF p_class_name = 'PWEL_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PWEL_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
      ln_ret_val := ecdp_well_theoretical.getWaterOilRatio(p_object_id, ld_start_daytime,EcDp_Phase.OIL, EcDp_Calc_Method.CURVE,p_class_name);

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION,EcDp_Phase.OIL, EcDp_Calc_Method.CURVE));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WOR', ln_ret_val);
      END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN
        IF p_class_name = 'PWEL_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PWEL_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
      ln_ret_val := ecdp_well_theoretical.getWaterOilRatio(p_object_id, ld_start_daytime,EcDp_Phase.LIQUID, EcDp_Calc_Method.CURVE_LIQUID,p_class_name);

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION,EcDp_Phase.LIQUID, EcDp_Calc_Method.CURVE_LIQUID));
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WOR', ln_ret_val);
      END IF;



   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_REFERENCE) THEN
      ln_ret_val := ecdp_well_ref_values.getAttribute(p_object_id,'WOR',p_daytime);

      -- decline calculations
      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_well_reference_value.prev_daytime(p_object_id, p_daytime);
         ln_ret_val := declineResult(p_object_id, p_daytime, ld_from_date, 'WOR', ln_ret_val);
      END IF;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.ZERO) THEN
      ln_ret_val := 0;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findWaterOilRatio(p_object_id,p_daytime);

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;
END findWaterOilRatio;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : declineResult
-- Description    : Returns Well decline rate
--                  the cursor will fetch all records within the p_from_date (date when decline starts) till p_daytime (date we will calc decline for)
--                  value from current cursor will be used in next loop. that's why copy them into variables
---------------------------------------------------------------------------------------------------

FUNCTION declineResult(p_object_id    VARCHAR2,
                         p_daytime      DATE,
                         p_from_date    DATE,
                         p_phase        VARCHAR2,
                         p_value        VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
   ln_ret_val            NUMBER;
   ln_day                NUMBER;
   ld_prev_day           DATE;
   ln_prev_decline_factor NUMBER;
   ln_prev_curve_exponential NUMBER;
   lb_first_iteration    BOOLEAN;
   lv2_prev_trend_method VARCHAR2(30);


CURSOR c_well_decline IS
SELECT daytime, decline_factor, curve_exponential, trend_method
FROM well_decline w1
WHERE w1.trend_parameter = p_phase
AND w1.object_id = p_object_id
AND w1.daytime < p_daytime -- less than because we need to create a dummy final row.
AND w1.daytime >=
   (SELECT max(daytime) FROM well_decline w2
   WHERE w2.trend_parameter = p_phase
   AND w2.object_id = p_object_id
   AND w2.daytime <= p_from_date)
UNION ALL
SELECT daytime, null decline_factor, null curve_exponential, null trend_method
FROM system_days
where daytime=p_daytime
ORDER BY daytime ASC;

BEGIN

   ln_ret_val := 0;
   ld_prev_day := p_from_date;
   lb_first_iteration := TRUE;
   ln_ret_val := p_value;

   FOR mycur IN c_well_decline LOOP
      IF NOT lb_first_iteration THEN
         ln_day := LEAST(p_daytime,mycur.daytime) - GREATEST(p_from_date,ld_prev_day);
         IF lv2_prev_trend_method = 'EXP' THEN
            ln_ret_val := ln_ret_val * POWER(EXP(1),(ln_prev_decline_factor*ln_day));
         ELSIF lv2_prev_trend_method = 'LINEAR' THEN
            ln_ret_val := ln_ret_val * (1 + (ln_prev_decline_factor * ln_day));
         ELSIF lv2_prev_trend_method = 'HARMONIC' THEN
            ln_ret_val := ln_ret_val / (1 - (ln_prev_decline_factor * ln_day));
         ELSIF lv2_prev_trend_method = 'HYPERBOLIC' THEN
            IF ln_prev_curve_exponential > 0 and ln_prev_curve_exponential < 1 THEN
               ln_ret_val := ln_ret_val / (power(1 - (ln_prev_decline_factor * ln_day * ln_prev_curve_exponential), (1/ln_prev_curve_exponential)));
            ELSE
               ln_ret_val := null;
            END IF;
         ELSIF (substr(lv2_prev_trend_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
               ln_ret_val := ue_well_theoretical.declineResult(p_object_id, p_daytime, p_from_date, p_phase, ln_ret_val);
         END IF;
      ELSE
         lb_first_iteration := FALSE;
      END IF;

      ld_prev_day := mycur.daytime;
      ln_prev_decline_factor := mycur.decline_factor;
      ln_prev_curve_exponential := mycur.curve_exponential;
      lv2_prev_trend_method := mycur.trend_method;
   END LOOP;

   RETURN ln_ret_val;
END declineResult;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumTruckedNetOilFromWell
-- Description    : This function returns prorated and loaded net vol value
--
--
---------------------------------------------------------------------------------------------------

FUNCTION sumTruckedNetOilFromWell(
    p_object_id    VARCHAR2,
    p_daytime      DATE)
RETURN NUMBER
--</EC-DOC>
IS

  ln_ret_val           NUMBER;
  lb_first             BOOLEAN;

  CURSOR c_truck_ticket IS
    SELECT event_no
    FROM well_transport_event wte
    WHERE wte.object_id = p_object_id
    AND wte.production_day = p_daytime
    AND wte.data_class_name = 'WELL_LOAD_TO_STRM'
    UNION ALL
    SELECT event_no
    FROM object_transport_event ote
    WHERE ote.object_id = p_object_id
    AND ote.production_day = p_daytime
    AND ote.data_class_name = 'OBJECT_SINGLE_TRANSFER'
    AND ote.object_type = 'WELL';

BEGIN
  lb_first:= TRUE;
  FOR myCur IN c_truck_ticket LOOP
    IF lb_first THEN
      ln_ret_val:= EcBp_Truck_Ticket.findWellStdVol(myCur.event_no,p_object_id);
      lb_first:= FALSE;
    ELSE
      ln_ret_val:= ln_ret_val + EcBp_Truck_Ticket.findWellStdVol(myCur.event_no,p_object_id);
    END IF;
  END LOOP;
  RETURN ln_ret_val;
END sumTruckedNetOilFromWell;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumTruckedWaterFromWell
-- Description    : This function returns prorated and loaded net vol value
--
--
---------------------------------------------------------------------------------------------------

FUNCTION sumTruckedWaterFromWell(
    p_object_id    VARCHAR2,
    p_daytime      DATE)
RETURN NUMBER
--</EC-DOC>
IS

  ln_ret_val           NUMBER;
  lb_first             BOOLEAN;

  CURSOR c_truck_ticket IS
    SELECT event_no
    FROM well_transport_event wte
    WHERE wte.object_id = p_object_id
    AND wte.production_day = p_daytime
    AND wte.data_class_name = 'WELL_LOAD_TO_STRM'
    UNION ALL
    SELECT event_no
    FROM object_transport_event ote
    WHERE ote.object_id = p_object_id
    AND ote.production_day = p_daytime
    AND ote.data_class_name = 'OBJECT_SINGLE_TRANSFER'
    AND ote.object_type = 'WELL';

BEGIN
  lb_first:= TRUE;
  FOR myCur IN c_truck_ticket LOOP
    IF lb_first THEN
      ln_ret_val:= EcBp_Truck_Ticket.findWellWaterVol(myCur.event_no, p_object_id);
      lb_first:= FALSE;
    ELSE
      ln_ret_val:= ln_ret_val + EcBp_Truck_Ticket.findWellWaterVol(myCur.event_no, p_object_id);
    END IF;
  END LOOP;
  RETURN ln_ret_val;
END sumTruckedWaterFromWell;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findBSWTruck
--
-- Description    : Returns average BS and W (volume) from last X truck loads
--
-- Preconditions  : NBR_TRUCK_LOADS_AVG_BSW value must be set in System Attribute
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION findBSWTruck(
  p_object_id VARCHAR2,
  p_daytime            DATE)
RETURN NUMBER
--</EC-DOC>
IS
    ln_truck_nbr NUMBER;
    ln_sumwater  NUMBER;
    ln_sumgrs    NUMBER;
    ln_retval    NUMBER;
    ld_next_date DATE;

CURSOR c_truck_ticket(cp_daytime DATE) IS
   SELECT wte.daytime, wte.event_no
   FROM  well_transport_event wte
   WHERE wte.object_id = p_object_id
   AND wte.data_class_name = 'WELL_LOAD_TO_STRM'
   AND wte.daytime=(SELECT MAX(wte2.daytime)
                    FROM well_transport_event wte2
                    WHERE wte2.object_id=p_object_id AND wte2.data_class_name='WELL_LOAD_TO_STRM' and wte2.daytime<cp_daytime)
   UNION ALL
   SELECT ote.daytime, ote.event_no
   FROM  object_transport_event ote
   WHERE ote.object_id = p_object_id
   AND ote.data_class_name = 'OBJECT_SINGLE_TRANSFER'
   AND ote.object_type = 'WELL'
   AND ote.daytime=(SELECT MAX(ote2.daytime)
                    FROM object_transport_event ote2
                    WHERE ote2.object_id=p_object_id AND ote2.data_class_name='OBJECT_SINGLE_TRANSFER' AND ote2.object_type='WELL' AND ote2.daytime<cp_daytime);
BEGIN
  -- last X trucks have been assinged in system attribute
  ln_truck_nbr := NVL(NVL(ec_well_reference_value.nbr_truck_loads_avg_bsw(p_object_id,p_daytime,'<='),ec_ctrl_system_attribute.attribute_value(p_daytime,'NBR_TRUCK_LOADS_AVG_BSW','<=')),1);
  -- find first truck ticket
  FOR myCur in c_truck_ticket(p_daytime) LOOP
    ld_next_date := myCur.daytime;
    ln_sumwater := EcBp_Truck_Ticket.findWatVol(myCur.event_no);
    ln_sumgrs :=  EcBp_Truck_Ticket.findGrsStdVol(myCur.event_no);
  END LOOP;
  IF ln_truck_nbr > 1 THEN
  -- loop next tickets
    FOR i IN 1..(ln_truck_nbr-1) LOOP
      FOR myCur IN c_truck_ticket(ld_next_date) LOOP
        ld_next_date := myCur.daytime;
        ln_sumwater := ln_sumwater + EcBp_Truck_Ticket.findWatVol(myCur.event_no);
        ln_sumgrs :=  ln_sumgrs + EcBp_Truck_Ticket.findGrsStdVol(myCur.event_no);
      END LOOP;
    END LOOP;
  END IF;
  -- perform NULL division
  IF ln_sumgrs = 0 THEN
    IF ln_sumwater = 0 THEN
      ln_retval:=0;
    ELSE
      ln_retval:=NULL;
    END IF;
  ELSE
    ln_retval := ln_sumwater/ln_sumgrs;
  END IF;
RETURN ln_retval;

END findBSWTruck;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGCV
-- Description    : Returns the Gas Colorific Value for a
--                  given well and day.
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : OBJECT_FLUID_ANALYSIS
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGCV (
     p_object_id    well.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val    NUMBER;
lv2_method    VARCHAR2(32);
lv2_well_object_id  stream.object_id%TYPE;
lv2_energy  VARCHAR2(30);
lv2_volume VARCHAR2(30);
ln_energy NUMBER;
ln_gas_rate NUMBER;
lr_analysis_sample object_fluid_analysis%ROWTYPE;

BEGIN

   -- Determine which GCV method to use
   lv2_method := Nvl(p_method, ec_well_version.GCV_METHOD(
                 p_object_id,
                 p_daytime,
                 '<='));

      -- METHOD= 'COMP_ANALYSIS' (get density from last 'comp' analysis)
      IF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS) THEN
         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'WELL_GAS_COMP', null, p_daytime);
         ln_return_val := lr_analysis_sample.gcv;

      -- METHOD= 'COMP_ANALYSIS_SPOT'
      ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_SPOT) THEN
         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'WELL_GAS_COMP', 'SPOT', p_daytime);
         ln_return_val := lr_analysis_sample.gcv;

      -- METHOD= 'COMP_ANALYSIS_DAY'
      ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_DAY) THEN
         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'WELL_GAS_COMP', 'DAY_SAMPLER', p_daytime);
         ln_return_val := lr_analysis_sample.gcv;

      -- METHOD= 'COMP_ANALYSIS_MTH'
      ELSIF (lv2_method = EcDp_Calc_Method.COMP_ANALYSIS_MTH) THEN
         lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'WELL_GAS_COMP', 'MTH_SAMPLER', p_daytime);
         ln_return_val := lr_analysis_sample.gcv;

      ELSIF lv2_method = EcDp_Calc_Method.MEASURED THEN
         ln_return_val := ec_pwel_day_status.avg_gas_gcv(p_object_id,p_daytime);

      ELSIF lv2_method = 'ENERGY_DIV_VOLUME' THEN
         -- Determine which energy method to use
         lv2_energy := ec_well_version.ENERGY_METHOD(
                               p_object_id,
                               p_daytime,
                                '<=' );
          --Raise app[ication error if energy method = VOLUME_GCV
         IF (lv2_energy = EcDp_Calc_Method.VOLUME_GCV) THEN
           RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate Energy. Check Configuration.');
         END IF;

         ln_return_val := 0;
         ln_energy := Ecbp_Well_Theoretical.getGasEnergyDay(p_object_id, p_daytime);
         ln_gas_rate := Ecbp_Well_Theoretical.getGasStdRateDay(p_object_id,p_daytime);

         IF ln_energy = 0 THEN
           ln_return_val := 0;
         ELSIF ln_energy <> 0 THEN
           IF (ln_gas_rate = 0 OR ln_gas_rate IS NULL) THEN
             ln_return_val := NULL;
           ELSE
             ln_return_val := ln_energy/ln_gas_rate;
           END IF;
         END IF;
      --METHOD= REF_GCV
      ELSIF lv2_method = Ecdp_Calc_Method.REF_GCV THEN
        ln_return_val := Ecdp_Well_Ref_Values.getAttribute(p_object_id,'GCV',p_daytime);

      ELSIF lv2_method = EcDp_Calc_Method.USER_EXIT THEN
        ln_return_val := ue_well_theoretical.findGCV(p_object_id, p_daytime);

      ELSE -- Not supported

        ln_return_val := NULL;

      END IF;

   RETURN ln_return_val;

END findGCV;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasEnergyDay
-- Description    : Returns the Gas Calorific Value for a given well
--                  and day.
-- Preconditions  :
-- Postcondition  : All input data to calucations must have a defined value or else
--                  the funtion will return null
-- Using Tables   : SYSTEM_DAYS
--                  PWEL_DAY_STATUS
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative WELL_VERSION.... (WELL_ENERGY_METHOD):
--
--                1. 'MEASURED': Find energy from pwel_day_status only.
--                2. 'VOLUME_GCV': Net Volume * Latest GCV from latest gas well analysis
--                3. 'USER_EXIT'
--
---------------------------------------------------------------------------------------------------
FUNCTION getGasEnergyDay (
     p_object_id    well.object_id%TYPE,
     p_daytime      DATE,
     p_method       VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

lv2_method    VARCHAR2(30);
ln_return_val NUMBER;
lv2_well_object_id     well.object_id%TYPE;
ld_fromday               DATE;
ld_today                 DATE;
ln_total_energy          NUMBER;

BEGIN

   lv2_well_object_id := p_object_id;
   -- Determine which method to use
   lv2_method := Nvl(p_method,
         ec_well_version.ENERGY_METHOD(
                     p_object_id,
                     p_daytime,
                           '<=' ));
   -- METHOD= 'MEASURED' ( Only measured values.)
   IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN
      ln_return_val := ec_pwel_day_status.avg_gas_energy(p_object_id,p_daytime);
   -- METHOD= 'VOLUME_GCV' ( Net Volume * Latest GCV from latest gas stream analysis )
   ELSIF (lv2_method = EcDp_Calc_Method.VOLUME_GCV) THEN
      ln_return_val := Ecbp_Well_Theoretical.getGasStdRateDay(p_object_id,p_daytime) *
                                                                          Ecbp_Well_Theoretical.findGCV(p_object_id,p_daytime);
   ELSIF  (lv2_method = ecdp_calc_method.USER_EXIT) THEN
      ln_return_val := ue_well_theoretical.getGasEnergyDay(p_object_id, p_daytime);
   ELSE
      ln_return_val := NULL;
   END IF;
   RETURN ln_return_val;

END getGasEnergyDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasWaterRatio
-- Description    : Returns Gas Water Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findGasWaterRatio(p_object_id    VARCHAR2,
                           p_daytime      DATE,
                           p_calc_method  VARCHAR2 DEFAULT NULL,
                           p_decline_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lr_well_version    WELL_VERSION%ROWTYPE;
   ln_ret_val         NUMBER;
BEGIN

   lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_calc_method := Nvl(p_calc_method, lr_well_version.gwr_method);

   IF (lv2_calc_method = EcDp_Calc_Method.WELL_REFERENCE) THEN
      ln_ret_val := ec_well_reference_value.gwr(p_object_id, p_daytime, '<=');

   ELSIF (lv2_calc_method = EcDp_Calc_Method.ZERO) THEN
      ln_ret_val := 0;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findGasWaterRatio(p_object_id,p_daytime);

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;

END findGasWaterRatio;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findDryWetFactor
-- Description    : Returns Dry Wet Factor Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findDryWetFactor(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_calc_method  VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lr_well_est_detail PWEL_RESULT%ROWTYPE;
   ln_ret_val       NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;

BEGIN

   lv2_calc_method := Nvl(p_calc_method, ec_well_version.dwf_method(p_object_id,p_daytime,'<='));

   IF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      lr_well_est_detail := ecdp_performance_test.getLastValidWellResult(p_object_id, ld_start_daytime);
      ln_ret_val := lr_well_est_detail.dry_wet_gas_ratio;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.ONE) THEN
      ln_ret_val := 1;

   ELSIF (lv2_calc_method = Ecdp_Calc_Method.ZERO) THEN
      ln_ret_val := 0;

   ELSIF (lv2_calc_method = Ecdp_Calc_Method.WELL_REFERENCE) THEN
-- Check performance
      ln_ret_val := ec_well_reference_value.dwf(p_object_id,p_daytime, '<=');

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.findDryWetFactor(p_object_id,p_daytime);

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;
END findDryWetFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjectedMassStdRateDay
-- Description    : Returns the injected mass for a well on a given day.
---------------------------------------------------------------------------------------------------
FUNCTION getInjectedMassStdRateDay (
         p_object_id   well.object_id%TYPE,
         p_inj_type    VARCHAR2,
         p_daytime     DATE,
         p_calc_inj_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_inj_method      VARCHAR2(32);
   ln_ret_val               NUMBER;
   lr_day_rec               IWEL_DAY_STATUS%ROWTYPE;
   ln_vol                   NUMBER;
   ln_density               NUMBER;

BEGIN

  lv2_calc_inj_method := Nvl(p_calc_inj_method,ec_well_version.calc_inj_method_mass(p_object_id,p_daytime, '<='));

  IF (lv2_calc_inj_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
    ln_vol:= EcBp_Well_Theoretical.getInjectedStdRateDay(p_object_id, p_inj_type, p_daytime);
    IF (p_inj_type = Ecdp_Well_Type.GAS_INJECTOR OR
        p_inj_type = Ecdp_Well_Type.AIR_INJECTOR OR
        p_inj_type = Ecdp_Well_Type.CO2_INJECTOR) THEN
      ln_density := EcBp_Well_Theoretical.findGasStdDensity(p_object_id, p_daytime);
    ELSIF (p_inj_type = Ecdp_Well_Type.WATER_INJECTOR OR
           p_inj_type = Ecdp_Well_Type.STEAM_INJECTOR) THEN
      ln_density := EcBp_Well_Theoretical.findWatStdDensity(p_object_id, p_daytime);
    END IF;
    ln_ret_val := ln_vol * ln_density;
  ELSIF (lv2_calc_inj_method = EcDp_Calc_Method.MEASURED) THEN
    lr_day_rec := ec_iwel_day_status.row_by_pk(p_object_id, p_daytime, p_inj_type);
      ln_ret_val := lr_day_rec.inj_mass;
  ELSIF (substr(lv2_calc_inj_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Well_Theoretical.getInjectedMassStdRateDay(p_object_id, p_inj_type, p_daytime);
  ELSE  -- undefined
    ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;

END getInjectedMassStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLoadWaterStdRateDay
-- Description    : Returns the total water loaded.
---------------------------------------------------------------------------------------------------
FUNCTION getLoadWaterStdRateDay(p_object_id   well.object_id%TYPE,
                                p_daytime     DATE,
                                p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   ln_ret_val            NUMBER;

   CURSOR c_well_loadoil_event(cp_object_id VARCHAR2, cp_day DATE, cp_todate DATE) IS
    SELECT event_no
    FROM well_transport_event
    WHERE object_id = cp_object_id
    AND production_day BETWEEN cp_day and NVL(cp_todate, cp_day)
    AND data_class_name = 'WELL_LOADED_FROM_TRUCK'
    UNION ALL
    SELECT event_no
    FROM object_transport_event
    WHERE to_object_id = cp_object_id
    AND production_day BETWEEN cp_day and NVL(cp_todate, cp_day)
    AND data_class_name = 'OBJECT_SINGLE_TRANSFER'
    AND to_object_type = 'WELL';

BEGIN
    ln_ret_val := 0;

    FOR curEvent IN c_well_loadoil_event(p_object_id, p_daytime, p_today) LOOP
       ln_ret_val :=  ln_ret_val + EcBp_Truck_Ticket.findWatVol(curEvent.Event_No);
    END LOOP;

    RETURN ln_ret_val;

END getLoadWaterStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findAvgPrevMthBswTruck
-- Description    : Returns the average of last month truck tickets.
---------------------------------------------------------------------------------------------------
FUNCTION findAvgPrevMthBswTruck (p_object_id VARCHAR2,
                                 p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

   ln_sumwater NUMBER;
   ln_sumgrs NUMBER;
   ln_retval NUMBER;

   CURSOR c_truck_ticket IS
    SELECT wte.daytime, wte.event_no
    FROM well_transport_event wte
    WHERE wte.object_id = p_object_id
    AND wte.data_class_name = 'WELL_LOAD_TO_STRM'
    AND wte.daytime >=p_daytime AND wte.daytime <= LAST_DAY(p_daytime)
    UNION ALL
    SELECT ote.daytime, ote.event_no
    FROM object_transport_event ote
    WHERE ote.object_id = p_object_id
    AND ote.data_class_name = 'OBJECT_SINGLE_TRANSFER'
    AND ote.object_type = 'WELL'
    AND ote.daytime >=p_daytime AND ote.daytime <= LAST_DAY(p_daytime);

BEGIN

    ln_sumwater := 0;
    ln_sumgrs := 0;
    ln_retval := 0;

    FOR myCur IN c_truck_ticket LOOP
       ln_sumwater := ln_sumwater + EcBp_Truck_Ticket.findWatVol(myCur.event_no);
       ln_sumgrs := ln_sumgrs + EcBp_Truck_Ticket.findGrsStdVol(myCur.event_no);
    END LOOP;

    -- perform NULL division
    IF ln_sumgrs = 0 THEN
       IF ln_sumwater = 0 THEN
          ln_retval:=0;
       ELSE
          ln_retval:=NULL;
       END IF;
    ELSE
       ln_retval := ln_sumwater/ln_sumgrs;
    END IF;

    RETURN ln_retval;

END findAvgPrevMthBswTruck;

---------------------------------------------------------------------------------------------------
-- Function       : getMeterMethod
-- Description    : Returns the meter method.
---------------------------------------------------------------------------------------------------
FUNCTION getMeterMethod (p_object_id well.object_id%TYPE,
                         p_daytime DATE,
                         p_meter_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

   lv2_calc_method       VARCHAR2(32);
   lr_well_version       WELL_VERSION%ROWTYPE;
   lr_analysis_sample    OBJECT_FLUID_ANALYSIS%ROWTYPE;
   lr_well_test          pwel_result%ROWTYPE;
   ln_ret_val            NUMBER;
   ld_start_daytime      DATE;

BEGIN

   lv2_calc_method := p_meter_method;
   IF p_meter_method IS NULL THEN
   lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_calc_method := lr_well_version.well_meter_method;
   END IF;


   IF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      ld_start_daytime := p_daytime + (Ecdp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24);
      lr_well_test := ecdp_performance_test.getLastValidWellResult(p_object_id, ld_start_daytime);
      ln_ret_val := lr_well_test.well_meter_factor;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.SAMPLE_ANALYSIS) THEN
      ld_start_daytime := p_daytime + (Ecdp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24);
      lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'WELL_SAMPLE_ANALYSIS', null, ld_start_daytime);
      ln_ret_val := lr_analysis_sample.meter_factor;

   ELSIF (lv2_calc_method = EcDp_Calc_Method.WELL_REFERENCE) THEN
      ln_ret_val := ec_well_reference_value.meter_factor(p_object_id, p_daytime, '<=');

   ELSIF (lv2_calc_method = EcDp_Calc_Method.NA) THEN
      ln_ret_val := NULL;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getMeterMethod(p_object_id,p_daytime);

   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;

END getMeterMethod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findFuelFlareVent
-- Description    : return fuel/flare/vent based on the method define in well config
---------------------------------------------------------------------------------------------------
FUNCTION findFuelFlareVent(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_ffv_type VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

  lr_well_version          WELL_VERSION%ROWTYPE;

  lv2_seasonal_well        VARCHAR2(32);

  ln_well_ref              NUMBER;
  ln_on_strm_ratio         NUMBER;
  ln_well_season        NUMBER;
  ln_return                NUMBER;


BEGIN

  lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');

  IF p_ffv_type = 'USM_FUEL' THEN

    IF lr_well_version.usm_fuel_method = 'MEASURED' THEN
       ln_return := ec_pwel_day_status.usm_fuel(p_object_id, p_daytime);

    ELSIF lr_well_version.usm_fuel_method = 'WELL_REFERENCE' THEN

       ln_well_ref := ec_well_reference_value.fuel_factor(p_object_id, p_daytime, '<=');
       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_ref * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF lr_well_version.usm_fuel_method = 'RATE_CALCULATION' THEN

       lv2_seasonal_well := NVL(lr_well_version.ref_seasonal_well_id, p_object_id);
       ln_well_season := EcBp_Well_Theoretical.findSeasonalWell(lv2_seasonal_well, p_daytime, 'FUEL');

       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_season * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF (substr(lr_well_version.usm_fuel_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
       ln_return := Ue_Well_Theoretical.findFuelFlareVent(p_object_id, p_daytime, p_ffv_type);
    END IF;

  ELSIF p_ffv_type = 'USM_FLARE' THEN

    IF lr_well_version.usm_flare_method = 'MEASURED' THEN
       ln_return := ec_pwel_day_status.usm_flare(p_object_id, p_daytime);

    ELSIF lr_well_version.usm_flare_method = 'WELL_REFERENCE' THEN
       ln_well_ref := ec_well_reference_value.flare_factor(p_object_id, p_daytime, '<=');
       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_ref * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF lr_well_version.usm_flare_method = 'RATE_CALCULATION' THEN

       lv2_seasonal_well := NVL(lr_well_version.ref_seasonal_well_id, p_object_id);
       ln_well_season := EcBp_Well_Theoretical.findSeasonalWell(lv2_seasonal_well, p_daytime, 'FLARE');

       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_season * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF (substr(lr_well_version.usm_flare_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
       ln_return := Ue_Well_Theoretical.findFuelFlareVent(p_object_id, p_daytime, p_ffv_type);
    END IF;

  ELSIF p_ffv_type = 'USM_VENT' THEN

    IF lr_well_version.usm_vent_method = 'MEASURED' THEN
       ln_return := ec_pwel_day_status.usm_vent(p_object_id, p_daytime);

    ELSIF lr_well_version.usm_vent_method = 'WELL_REFERENCE' THEN
       ln_well_ref := ec_well_reference_value.vent_factor(p_object_id, p_daytime, '<=');
       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_ref * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF lr_well_version.usm_vent_method = 'RATE_CALCULATION' THEN

       lv2_seasonal_well := NVL(lr_well_version.ref_seasonal_well_id, p_object_id);
       ln_well_season := EcBp_Well_Theoretical.findSeasonalWell(lv2_seasonal_well, p_daytime, 'VENT');

       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_season * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF (substr(lr_well_version.usm_vent_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
       ln_return := Ue_Well_Theoretical.findFuelFlareVent(p_object_id, p_daytime, p_ffv_type);
    END IF;

  ELSIF p_ffv_type = 'DSM_FUEL' THEN

    IF lr_well_version.dsm_fuel_method = 'MEASURED' THEN
       ln_return := ec_pwel_day_status.dsm_fuel(p_object_id, p_daytime);

    ELSIF lr_well_version.dsm_fuel_method = 'WELL_REFERENCE' THEN
       ln_well_ref := ec_well_reference_value.fuel_factor(p_object_id, p_daytime, '<=');
       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_ref * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF lr_well_version.dsm_fuel_method = 'RATE_CALCULATION' THEN

       lv2_seasonal_well := NVL(lr_well_version.ref_seasonal_well_id, p_object_id);
       ln_well_season := EcBp_Well_Theoretical.findSeasonalWell(lv2_seasonal_well, p_daytime, 'FUEL');

       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_season * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF (substr(lr_well_version.dsm_fuel_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
       ln_return := Ue_Well_Theoretical.findFuelFlareVent(p_object_id, p_daytime, p_ffv_type);
    END IF;

  ELSIF p_ffv_type = 'DSM_FLARE' THEN

    IF lr_well_version.dsm_flare_method = 'MEASURED' THEN
       ln_return := ec_pwel_day_status.dsm_flare(p_object_id, p_daytime);

    ELSIF lr_well_version.dsm_flare_method = 'WELL_REFERENCE' THEN
       ln_well_ref := ec_well_reference_value.flare_factor(p_object_id, p_daytime, '<=');
       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_ref * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF lr_well_version.dsm_flare_method = 'RATE_CALCULATION' THEN

       lv2_seasonal_well := NVL(lr_well_version.ref_seasonal_well_id, p_object_id);
       ln_well_season := EcBp_Well_Theoretical.findSeasonalWell(lv2_seasonal_well, p_daytime, 'FLARE');

       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_season * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF (substr(lr_well_version.dsm_flare_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
       ln_return := Ue_Well_Theoretical.findFuelFlareVent(p_object_id, p_daytime, p_ffv_type);
    END IF;

  ELSIF p_ffv_type = 'DSM_VENT' THEN

    IF lr_well_version.dsm_vent_method = 'MEASURED' THEN
       ln_return := ec_pwel_day_status.dsm_vent(p_object_id, p_daytime);

    ELSIF lr_well_version.dsm_vent_method = 'WELL_REFERENCE' THEN
       ln_well_ref := ec_well_reference_value.vent_factor(p_object_id, p_daytime, '<=');
       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_ref * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF lr_well_version.dsm_vent_method = 'RATE_CALCULATION' THEN

       lv2_seasonal_well := NVL(lr_well_version.ref_seasonal_well_id, p_object_id);
       ln_well_season := EcBp_Well_Theoretical.findSeasonalWell(lv2_seasonal_well, p_daytime, 'VENT');

       ln_on_strm_ratio := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime) / 24;

       IF ln_on_strm_ratio > 0 THEN
          ln_return := ln_well_season * ln_on_strm_ratio;
       ELSE
          ln_return := 0;
       END IF;

    ELSIF (substr(lr_well_version.dsm_vent_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
       ln_return := Ue_Well_Theoretical.findFuelFlareVent(p_object_id, p_daytime, p_ffv_type);
    END IF;

  ELSE

    ln_return := NULL;

  END IF;

  RETURN ln_return;

END findFuelFlareVent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumFuelFlareVent
-- Description    : Return sum of fuel/flare/vent
---------------------------------------------------------------------------------------------------
FUNCTION sumFuelFlareVent(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_ffv_type VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

  ln_return            NUMBER;
  ln_usm_fuel          NUMBER;
  ln_usm_flare         NUMBER;
  ln_usm_vent          NUMBER;
  ln_dsm_fuel          NUMBER;
  ln_dsm_flare         NUMBER;
  ln_dsm_vent          NUMBER;

BEGIN

  IF p_ffv_type = 'SUM_FUEL' THEN

    ln_usm_fuel := findFuelFlareVent(p_object_id, p_daytime, 'USM_FUEL');
    ln_dsm_fuel := findFuelFlareVent(p_object_id, p_daytime, 'DSM_FUEL');
    ln_return := NVL(ln_usm_fuel,0) + NVL(ln_dsm_fuel,0);

  ELSIF p_ffv_type = 'SUM_FLARE' THEN

    ln_usm_flare := findFuelFlareVent(p_object_id, p_daytime, 'USM_FLARE');
    ln_dsm_flare := findFuelFlareVent(p_object_id, p_daytime, 'DSM_FLARE');
    ln_return := NVL(ln_usm_flare,0) + NVL(ln_dsm_flare,0);

  ELSIF p_ffv_type = 'SUM_VENT' THEN

    ln_usm_vent := findFuelFlareVent(p_object_id, p_daytime, 'USM_VENT');
    ln_dsm_vent := findFuelFlareVent(p_object_id, p_daytime, 'DSM_VENT');
    ln_return := NVL(ln_usm_vent,0) + NVL(ln_dsm_vent,0);

  ELSIF p_ffv_type = 'SUM_USM' THEN

    ln_usm_fuel := findFuelFlareVent(p_object_id, p_daytime, 'USM_FUEL');
    ln_usm_flare := findFuelFlareVent(p_object_id, p_daytime, 'USM_FLARE');
    ln_usm_vent := findFuelFlareVent(p_object_id, p_daytime, 'USM_VENT');
    ln_return := NVL(ln_usm_fuel,0) + NVL(ln_usm_flare,0) + NVL(ln_usm_vent,0);

  ELSIF p_ffv_type = 'SUM_DSM' THEN

    ln_dsm_fuel := findFuelFlareVent(p_object_id, p_daytime, 'DSM_FUEL');
    ln_dsm_flare := findFuelFlareVent(p_object_id, p_daytime, 'DSM_FLARE');
    ln_dsm_vent := findFuelFlareVent(p_object_id, p_daytime, 'DSM_VENT');
    ln_return := NVL(ln_dsm_fuel,0) + NVL(ln_dsm_flare,0) + NVL(ln_dsm_vent,0) ;

  ELSIF p_ffv_type = 'SUM' THEN

    ln_usm_fuel := findFuelFlareVent(p_object_id, p_daytime, 'USM_FUEL');
    ln_dsm_fuel := findFuelFlareVent(p_object_id, p_daytime, 'DSM_FUEL');
    ln_usm_flare := findFuelFlareVent(p_object_id, p_daytime, 'USM_FLARE');
    ln_dsm_flare := findFuelFlareVent(p_object_id, p_daytime, 'DSM_FLARE');
    ln_usm_vent := findFuelFlareVent(p_object_id, p_daytime, 'USM_VENT');
    ln_dsm_vent := findFuelFlareVent(p_object_id, p_daytime, 'DSM_VENT');
    ln_return := NVL(ln_usm_fuel,0) + NVL(ln_usm_flare,0) + NVL(ln_usm_vent,0) + NVL(ln_dsm_fuel,0) + NVL(ln_dsm_flare,0) + NVL(ln_dsm_vent,0) ;

  ELSE

    ln_return := NULL;

  END IF;

  RETURN ln_return;

END sumFuelFlareVent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findSeasonalWell
-- Description    : return seasonal value
---------------------------------------------------------------------------------------------------
FUNCTION findSeasonalWell(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_ffv_type VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

  ln_First_year        VARCHAR2(32);

  ln_return                NUMBER;
  ln_last_fuel               NUMBER;
  ln_last_flare              NUMBER;
  ln_last_vent               NUMBER;

  ld_curr_season_year   DATE;
  ld_first_valid_from   DATE;
  ld_daytime            DATE;

  TYPE t_valid_from IS TABLE OF DATE;
  typ_valid_from        t_valid_from      := t_valid_from();

  TYPE t_seasonal_fuel IS TABLE OF NUMBER;
  typ_seasonal_fuel     t_seasonal_fuel        := t_seasonal_fuel();

  TYPE t_seasonal_flare IS TABLE OF NUMBER;
  typ_seasonal_flare    t_seasonal_flare    := t_seasonal_flare();

  TYPE t_seasonal_vent IS TABLE OF NUMBER;
  typ_seasonal_vent     t_seasonal_vent        := t_seasonal_vent();


  CURSOR c_curr_season(cp_object_id VARCHAR2, cp_day DATE) IS
    SELECT MAX(TRUNC(a.valid_from, 'YYYY')) first_day
    FROM WELL_SEASONAL_VALUE a
    WHERE a.object_id = cp_object_id
    AND a.valid_from <= cp_day;

  CURSOR c_all_seasons(cp_object_id VARCHAR2, cp_firstday DATE) IS
    SELECT a.valid_from, a.fuel, a.flare, a.vent
    FROM WELL_SEASONAL_VALUE a
    WHERE a.object_id = cp_object_id
    AND a.valid_from between cp_firstday
    AND to_date('31-12' || to_char(cp_firstday, 'YYYY'), 'DD-MM-YYYY')
    ORDER BY a.valid_from ASC;

BEGIN
   ld_daytime:=p_daytime;
  FOR curCurrent_Season in c_curr_season(p_object_id, p_daytime) LOOP
    ld_curr_season_year := curCurrent_Season.first_day;
  END LOOP;

  IF ld_curr_season_year IS NOT NULL THEN
      OPEN c_all_seasons(p_object_id, ld_curr_season_year);
      FETCH c_all_seasons BULK COLLECT INTO typ_valid_from, typ_seasonal_fuel, typ_seasonal_flare, typ_seasonal_vent;
      CLOSE c_all_seasons;

      FOR c IN typ_valid_from.FIRST .. typ_valid_from.LAST  -- Prepare the control values
      LOOP
          IF c = 1 THEN
            ld_first_Valid_From := typ_valid_from(c);
          ln_First_year := to_char(ld_first_Valid_From, 'YYYY');
      END IF;

      ln_last_fuel := typ_seasonal_fuel(c);
          ln_last_flare := typ_seasonal_flare(c);
          ln_last_vent := typ_seasonal_vent(c);
      END LOOP;

      FOR i IN typ_valid_from.FIRST .. typ_valid_from.LAST
      LOOP
      IF ld_daytime >= typ_valid_from(i) THEN
        IF TRUNC(ld_daytime, 'YYYY') > TRUNC(ld_first_Valid_From, 'YYYY') THEN -- Next year, check before assign value
			IF ( to_char(ld_daytime, 'DD')= '29' and to_char(ld_daytime, 'MM')='02' and (NOT ((mod(ln_First_year,4) = 0 and mod(ln_First_year,100) != 0) or mod(ln_First_year,400)=0 ))) THEN
                 ld_daytime:= ld_daytime-1;
             END IF; --If passed date is 29-Feb and last seasonal value year is not a leap year
          IF to_date( (to_char(ld_daytime, 'DD') || '-' || to_char(ld_daytime, 'MM') || '-' || ln_First_year), 'DD-MM-YYYY' ) < ld_first_Valid_From THEN
            IF (p_ffv_type = 'FUEL') THEN
              ln_return := ln_last_fuel;
            ELSIF (p_ffv_type = 'FLARE') THEN
              ln_return := ln_last_flare;
            ELSIF (p_ffv_type = 'VENT') THEN
              ln_return := ln_last_vent;
            END IF;
            EXIT;
          ELSIF to_date( (to_char(ld_daytime, 'DD') || '-' || to_char(ld_daytime, 'MM') || '-' || ln_First_year), 'DD-MM-YYYY' ) >= typ_valid_from(i) THEN
            IF (p_ffv_type = 'FUEL') THEN
              ln_return := typ_seasonal_fuel(i);
            ELSIF (p_ffv_type = 'FLARE') THEN
              ln_return := typ_seasonal_flare(i);
            ELSIF (p_ffv_type = 'VENT') THEN
              ln_return := typ_seasonal_vent(i);
            END IF;
          END IF;
        ELSE -- current year, must assign value
          IF (p_ffv_type = 'FUEL') THEN
            ln_return := typ_seasonal_fuel(i);
          ELSIF (p_ffv_type = 'FLARE') THEN
            ln_return := typ_seasonal_flare(i);
          ELSIF (p_ffv_type = 'VENT') THEN
            ln_return := typ_seasonal_vent(i);
          END IF;
        END IF;
      END IF;
      END LOOP;
      RETURN ln_return;
  ELSE
      RETURN NULL;
    END IF;

END findSeasonalWell;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateEvent
-- Description    : Returns theoretical oil rate for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdRateEvent(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method            VARCHAR2(32);
  lr_well_version            WELL_VERSION%ROWTYPE;
  lr_pwel_sub_day_status     pwel_sub_day_status%ROWTYPE;
  lr_well_test               pwel_result%ROWTYPE;

  ln_ret_val                 NUMBER;
  ln_prev_test_no            NUMBER;

  ld_prev_test               DATE;
BEGIN
  lr_well_version :=ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_calc_method := Nvl(p_calc_method, lr_well_version.CALC_EVENT_METHOD);
  lr_pwel_sub_day_status := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);

  IF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
        ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,p_daytime);
        ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);

        ln_ret_val := EcDp_Well_Estimate.getOilStdRate(p_object_id, ld_prev_test);

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Well_Theoretical.getOilStdRateEvent(
                        p_object_id,
                        p_daytime);
  END IF; -- End check if lv2_calc_method

  RETURN ln_ret_val;

END getOilStdRateEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateEvent
-- Description    : Returns theoretical gas rate for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdRateEvent(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method            VARCHAR2(32);
  lr_well_version            WELL_VERSION%ROWTYPE;
  lr_pwel_sub_day_status     pwel_sub_day_status%ROWTYPE;

  ln_ret_val                 NUMBER;
  ln_prev_test_no            NUMBER;

  ld_prev_test               DATE;
BEGIN
lr_well_version :=ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
lv2_calc_method := Nvl(p_calc_method, lr_well_version.CALC_EVENT_GAS_METHOD);
lr_pwel_sub_day_status := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);

IF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,p_daytime);
      ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);

      ln_ret_val := EcDp_Well_Estimate.getGasStdRate(p_object_id, ld_prev_test);

ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Well_Theoretical.getGasStdRateEvent(
                      p_object_id,
                      p_daytime);
END IF; -- End check if lv2_calc_method

  RETURN ln_ret_val;

END getGasStdRateEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateEvent
-- Description    : Returns theoretical water rate for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdRateEvent(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method            VARCHAR2(32);
  lr_well_version            WELL_VERSION%ROWTYPE;
  lr_pwel_sub_day_status     pwel_sub_day_status%ROWTYPE;

  ln_ret_val                 NUMBER;
  ln_prev_test_no            NUMBER;

  ld_prev_test               DATE;
BEGIN
lr_well_version :=ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
lv2_calc_method := Nvl(p_calc_method, lr_well_version.CALC_EVENT_WATER_METHOD);
lr_pwel_sub_day_status := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);

IF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN
      ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,p_daytime);
      ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);

      ln_ret_val := EcDp_Well_Estimate.getWatStdRate(p_object_id, ld_prev_test);

ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Well_Theoretical.getWatStdRateEvent(
                      p_object_id,
                      p_daytime);
END IF; -- End check if lv2_calc_method

  RETURN ln_ret_val;

END getWatStdRateEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateEvent
-- Description    : Returns theoretical condensate rate for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdRateEvent(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method            VARCHAR2(32);
  lr_well_version            WELL_VERSION%ROWTYPE;
  lr_pwel_sub_day_status     pwel_sub_day_status%ROWTYPE;

  ln_ret_val                 NUMBER;
  ln_prev_test_no            NUMBER;

  ld_prev_test               DATE;
BEGIN
lr_well_version :=ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
lv2_calc_method := Nvl(p_calc_method, lr_well_version.CALC_EVENT_COND_METHOD);
lr_pwel_sub_day_status := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);

IF (lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,p_daytime);
      ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);

      ln_ret_val := EcDp_Well_Estimate.getCondStdRate(p_object_id, ld_prev_test);

ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Well_Theoretical.getCondStdRateEvent(
                      p_object_id,
                      p_daytime);
END IF; -- End check if lv2_calc_method

  RETURN ln_ret_val;

END getCondStdRateEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findHCMassDay
-- Description    : Returns theoretical hydrocarbon mass for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findHCMassDay(p_object_id   well.object_id%TYPE,
                       p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS
  lr_day_rec            PWEL_DAY_STATUS%ROWTYPE;
  lv2_calc_method       VARCHAR2(32);
  lv2_gl_Qstream        VARCHAR2(32);
  lr_pwel_result        PWEL_RESULT%ROWTYPE;
  ln_gl_dens            NUMBER;
  ln_gl_mass            NUMBER;
  ln_ret_val            NUMBER;
  ln_meter_corr         NUMBER;
  ln_mpm_corr_hc_mass   NUMBER;
BEGIN
lv2_calc_method := ec_well_version.calc_method_mass(p_object_id, p_daytime, '<=');
lr_day_rec := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);

IF EcDp_Well.getPwelOnStreamHrs(p_object_id, p_daytime) = 0 THEN -- Well closed => zero flow

  RETURN 0;

ELSIF EcDp_Well.getPwelOnStreamHrs(p_object_id, p_daytime) IS NULL THEN -- Well closed => zero flow

  RETURN NULL;

END IF;

IF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN -- Return MPM-values as received

      ln_ret_val := nvl(lr_day_rec.mpm_hc_mass_rate,(lr_day_rec.avg_mpm_gas_mass_rate + (nvl(lr_day_rec.avg_mpm_oil_mass_rate,lr_day_rec.avg_mpm_cond_mass_rate))));

ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_CORR) THEN  -- Return MPM-values as received with CorrFactor
      lr_pwel_result  := EcDp_Performance_Test.getLastValidWellResult(p_object_id,p_daytime); -- get valid test result record for well
      ln_meter_corr := ec_pwel_result.meter1_factor_hc(p_object_id, lr_pwel_result.result_no);
      ln_mpm_corr_hc_mass := lr_day_rec.mpm_hc_mass_rate * NVL(ln_meter_corr,1);

      ln_ret_val := nvl(ln_mpm_corr_hc_mass,(lr_day_rec.avg_mpm_gas_mass_rate + (nvl(lr_day_rec.avg_mpm_oil_mass_rate,lr_day_rec.avg_mpm_cond_mass_rate))));

ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM) THEN  -- Return MPM-values but subtract gas lift mass
      lv2_gl_Qstream := ec_fcty_version.gl_quality_stream_id(ec_well_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),p_daytime,'<=');
      ln_gl_dens     := ecbp_stream_fluid.findStdDens(lv2_gl_Qstream,p_daytime);
      ln_gl_mass     := nvl(ecbp_well_theoretical.getGasLiftStdRateDay(p_object_id, p_daytime) * ln_gl_dens,0);

      ln_ret_val     := nvl(lr_day_rec.mpm_hc_mass_rate,(lr_day_rec.avg_mpm_gas_mass_rate + (nvl(lr_day_rec.avg_mpm_oil_mass_rate,lr_day_rec.avg_mpm_cond_mass_rate)))) - ln_gl_mass;

END IF; -- End check if lv2_calc_method

  RETURN ln_ret_val;

END findHCMassDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findHCMassSubDay
-- Description    : Returns theoretical hydrocarbon mass for well during a given sub daily time period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findHCMassSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS
   lr_sub_day_rec            PWEL_SUB_DAY_STATUS%ROWTYPE;
   lv2_calc_method           VARCHAR2(32);
   lv2_gl_Qstream            VARCHAR2(32);
   lr_pwel_result            PWEL_RESULT%ROWTYPE;
   ln_gl_dens                NUMBER;
   ln_gl_mass                NUMBER;
   ln_ret_val                NUMBER;
   ln_meter_corr             NUMBER;
   ln_mpm_corr_hc_mass       NUMBER;
BEGIN
lv2_calc_method := ec_well_version.calc_method_mass(p_object_id, p_daytime, '<=');
lr_sub_day_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id, p_daytime);
IF lr_sub_day_rec.on_stream_hrs = 0 THEN -- Well closed => zero flow

  RETURN 0;

ELSIF lr_sub_day_rec.on_stream_hrs IS NULL THEN -- Well closed => zero flow

  RETURN NULL;

END IF;

IF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN -- Return MPM-values as received
      ln_ret_val := nvl(lr_sub_day_rec.mpm_hc_mass_rate,(lr_sub_day_rec.avg_mpm_gas_mass_rate + (nvl(lr_sub_day_rec.avg_mpm_oil_mass_rate,lr_sub_day_rec.avg_mpm_cond_mass_rate))));

ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM_CORR) THEN  -- Return MPM-values as received with CorrFactor
      lr_pwel_result  := EcDp_Performance_Test.getLastValidWellResult(p_object_id,p_daytime); -- get valid test result record for well
      ln_meter_corr := ec_pwel_result.meter1_factor_hc(p_object_id, lr_pwel_result.result_no);
      ln_mpm_corr_hc_mass := lr_sub_day_rec.mpm_hc_mass_rate * NVL(ln_meter_corr,1);

      ln_ret_val := nvl(ln_mpm_corr_hc_mass,(lr_sub_day_rec.avg_mpm_gas_mass_rate + (nvl(lr_sub_day_rec.avg_mpm_oil_mass_rate,lr_sub_day_rec.avg_mpm_cond_mass_rate))));

ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM) THEN  -- Return MPM-values but subtract gas lift mass
      lv2_gl_Qstream := ec_fcty_version.gl_quality_stream_id(ec_well_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),p_daytime,'<=');
      ln_gl_dens     := ecbp_stream_fluid.findStdDens(lv2_gl_Qstream,p_daytime);
      ln_gl_mass     := nvl(ecbp_well_theoretical.getGasLiftStdVolSubDay(p_object_id, p_daytime, NULL) * ln_gl_dens,0);

      ln_ret_val     := nvl(lr_sub_day_rec.mpm_hc_mass_rate,(lr_sub_day_rec.avg_mpm_gas_mass_rate + (nvl(lr_sub_day_rec.avg_mpm_oil_mass_rate,lr_sub_day_rec.avg_mpm_cond_mass_rate)))) - ln_gl_mass;

END IF;

  RETURN ln_ret_val; -- End check if lv2_calc_method

END findHCMassSubDay;

END EcBp_well_theoretical;