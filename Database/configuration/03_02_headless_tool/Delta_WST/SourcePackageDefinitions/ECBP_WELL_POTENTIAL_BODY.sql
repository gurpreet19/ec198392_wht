CREATE OR REPLACE PACKAGE BODY EcBp_Well_Potential IS
/****************************************************************
** Package        :  EcDp_Well_Potential, header part
**
** $Revision: 1.61 $
**
** Purpose        :  Finds well potential using source-method
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.07.2000  �ne Bakkane
**
** Modification history:
**
** Date     Whom       Change description:
** ------   -----      --------------------------------------
** 18.05.2001  �      Added method for potential calculation in findOilProducionPotential, ->INTERPOLATE_WT
** 02.12.2002  HNE     Added new method to find potential in well_estimate_detail.
** 02.04.2004  SHN     Added support for getCurveRate in findConProductionPotential,findGasInjectionPotential,
**                     findGasProductionPotential,findOilProductionPotential,findWatInjectionPotential,findWatProductionPotential
** 24.05.2004  FBa     Fixed function calls to EcBp_Well_Theoretical.getCurveRate
** 25.05.2004  FBa     Removed references to EcDp_Calc_Methd.PREVIOUS_WT
** 26.05.2004  FBa     Column avg_dh_pump_rpm renamed to avg_dh_pump_speed in pwel_day_status
** 09.06.2004  AV      Added new method WELL_EST_PUMP_SPEED an logic to use well attributes POTEN_2ND_VALUE
**                     and POTEN_3RD_VALUE if well has run time = 0
** 11.06.2004  DN      Removed MANUAL-method.
** 11.08.2004 mazrina  Removed sysnam and update as necessary
** 28.02.2005 kaurrnar Removed deadcodes
**                     Removed references to ec_xxx_attribute packages
** 12.04.205  SHN      Performance Test cleanup
** 22.04.2005 kaurrnar Added new function calcDayWellDefermentVol
** 28.04.2005 DN       Bug fix in calcDayWellDefermentVol: local variable declaration.
** 03.06.2005 ROV      Tracker #1822:Renamed function calcDayWellDefermentVol to calcDayWellProdDefermentVol.
**                     Updated call in functions to ecdp_objects_deferment_event.calcWellLossDay to reflect
**                     change in function name to calcWellProdLossDay.Updated call in functions to
**                     ecdp_objects_event.calcWellLossDay to reflect change in function name to calcWellProdLossDay
** 03.06.2005 ROV      Tracker #2309: Added support for calc_method = 'WELL_EST_DETAIL' in findConProductionPotential
** 27.07.2005 Darren   TI#2391 Added support for new POTENTIAL_METHOD 'DAY_PLAN' and 'MTH_PLAN'
                       in EcBp_Well_Potensial.findOilProductionPotential
                          EcBp_Well_Potensial.findGaslProductionPotential
                          EcBp_Well_Potensial.findWatProductionPotential
                          EcBp_Well_Potensial.findConProductionPotential
                          EcBp_Well_Potensial.findWatInjectionPotential
                          EcBp_Well_Potensial.findGasInjectionPotential
** 09.08.2005 Darren   TI#2391 Update references column names con_rate to cond_rate
** 23.08.2005 Darren   TD4125 Fix bug in all function where potential method = MTH_PLAN
** 09.09.2005 Ron	     The call for EcDp_Well_Estimate.getLast*StdRate is updated to a new function EcDp_Well_Estimate.get*StdRate to support the new
**				             Well Decline Rate Support where the well can be configureed to have interpolated, extrapolated or stepped rate.
** 15.09.2005 ROV	#2674: Updated the find*Potential functions for potential method = 'CURVE' to find on_stream_hrs using EcDp_Well.getPwel/IwelOnStreamHrs
                               Updated the find*ProductionPotential functions to use new EcBp_Well_Theoretical.getGasLiftStdRateDay instead of hardcoded connection
                               against pwel_day_status for arguments specifying gas lift rate.
                               Also fixed wrong use of ec_ packages when retreiving poten_3rd_value
** 03.10.2005 DN       TD4311: The daily plan functions must retrieve the last recent record using the '<='-operator.
** 08.11.2005 bohhhron TI#2626 : Added new functions findGasLiftPotential and findDiluentPotential
** 01.12.2005 DN       Function getInterpolatedOilProdPot moved from EcDp_Well_Potential to EcDp_Well_Estimate.
** 04.12.2005 ROV      TI#2618:Added support for new potential_method = 'WELL_TEST_AND_ESTIMATE' in methods for produced oil, gas, water, gas lift and diluent
** 29.12.2005 ROV      TI#2618: Updated all functions using well test data to use actual production day start (00:00)+ prod_day_offset in calls looking up well tests
**                              since valid_from_date on well test results now are specified as a full daytime.
** 04.04.2005 ROV      TI#3299: Updated implementation of method 'WELL_TEST_AND_ESTIMATE' in functions find#ProductionPotential
** 05.04.2006 johanein TI#3668: Updated CURVE methods for functions find#InjectionPotential and find#ProductionPotential
** 29.05.2007 zakiiari ECPD-3905: Updated all function by replacing DAY_PLAN / MTH_PLAN with FORECAST
** 22.08.2007 leongsei Added new function findSteamInjectionPotential
** 06.09.2007 rajarsar ECPD-6264 Added new function findOilMassProdPotential,findGasMassProdPotential, findCondMassProdPotential, findWaterMassProdPotential, calcDayWellProdDefermentMass
** 10.10.2007 rajarsar ECPD-6313: Updated calcDayWellProdDefermentVol to support new deferment version PD.0006
** 12.02.2008 ismaiime ECPD-7571: Updated all functions to support potential volume method = USER_EXIT
** 21.04.2008 aliassit ECPD-7726: Added gas, water and steam injectors to support potential volume method = EVENT_INJ_DATA
** 22.04.2008 aliassit ECPD-7726: Modify calculation for EVENT_INJ_DATA
** 23.04.2008 aliassit ECPD-7726: Removed ln_prod_day_offset from ld_cur_date:= (cur_rate.daytime -  ln_prod_day_offset); 	in EVENT_INJ_DATA
** 26.05.08   oonnnng  ECPD-8471: Replace USER_EXIT test statements with [ (substr(lv2_gas_lift_method,1,9) = EcDp_Calc_Method.USER_EXIT) ].
** 26.08.2008 rajarsar ECPD-9038: Added new function: findCo2InjectionPotential
** 16.09.2008 leeeewei ECPD-9363: Added new potential mass method VOLUME_DENSITY to findxxxmassprodpotential
** 30-12-2008 leongwen ECPD-7847 Fix the conversion problem which is the additional task besides the new BF of Well Downtime - by Well
** 31.12.2008 sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions calcDayWellProdDefermentVol, calcDayWellProdDefermentMass.
** 06.02.2009 rajarsar ECPD-10975:Updated all functions to support daylight savings
** 23.04.2009 leongsei ECPD-11367: Modified function findGasInjectionPotential, findWatInjectionPotential, findOilProductionPotential,
**                                                   findSteamInjectionPotential to pass in curve_id as parameter for ec_performance_curve
** 21.10.2009 leeeewei ECPD-11636: Removed potential method for Steam Injector = CURVE from function findSteamInjectionPotential
** 30.11.2009 oonnnng  ECPD-13232: Added WELL_TEST_AND_ESTIMATE method to findConProductionPotential() function.
** 08.11.2010 rajarsar ECPD-15760: Added BUDGET_PLAN, POTENTIAL_PLAN,TARGET_PLAN and OTHER_PLAN method to findConProductionPotential(),findGasInjectionPotential,findOilProductionPotential
**                                 findGasProductionPotential,findWatInjectionPotential,findSteamInjectionPotential,findCo2InjectionPotential and findWatProductionPotential function.
** 28-01-2011 leongwen ECDP-16574: To correct and enhance the screens which are affected by the changes made in ECPD-16525.
** 01-06-2011 leongwen ECPD-17489: Well Plan PP.0027. ecbp_well_potential.findGasProductionPotential. Incorrect ref. to class name in POTENTIAL_PLAN potential method
** 06-06-2011 leongwen ECPD-17490: EcBp_Well_Potential Incorrect input date for decline of well plan potentials
** 23-05-2012 rajarsar ECPD-18696: Updated findConProductionPotential,findOilProductionPotential,findGasProductionPotential,findWatProductionPotential,findGasLiftPotential and findDiluentPotential.
** 22.11.2013 kumarsur ECPD-18576: Updated getCurveRate to support new parameters added phase_current,ac_frequency and intake_press.
** 02.12.2013 makkkkam ECPD-23832: Updated getCurveRate to support new parameters added mpm_oil_rate,mpm_gas_rate,mpm_water_rate and mpm_cond_rate.
** 26.11.2014 abdulmaw ECPD-29389: Updated calcDayWellProdDefermentVol to support PD.0020
** 23.09.2015 kumarsur ECPD-31862: Added FORECAST_PROD.
** 12.04.2016 jainnraj ECPD-33875: Modified findConProductionPotential,findOilProductionPotential,findGasProductionPotential,findWatProductionPotential to modify all the curve methods using pwel_day_status.avg_annulus_press to pwel_day_status.avg_annulus
** 09.03.2017 leongwen ECPD-43536: Modified findGasInjectionPotential, findWatInjectionPotential, findSteamInjectionPotential, findCo2InjectionPotential, findOilMassProdPotential, findGasMassProdPotential, findCondMassProdPotential,
                                   findWaterMassProdPotential functions on the affected renamed column name.
** 31.03.2017 chaudgau ECPD-36124: Modified calls to getCurveRate in required sub programs to support new Curve Parameter AVG_DH_PUMP_POWER
** 12-05-2017 jainnraj ECPD-42563: Renamed function call getProdForecastId to getProdScenarioId.
** 16-08-2017 shindani ECPD-31708: Updated getCurveRate to support new parameter AVG_DP_VENTURI.
** 28-12-2017 jainnraj ECPD-31884: Removing all the calls where potential_method is Ecdp_Calc_Method.FORECAST
*****************************************************************/

------------------------------------------------------------------
-- Function:    findConProductionPotential
-- Description: Returns the valid condensate production potential
------------------------------------------------------------------
FUNCTION findConProductionPotential(
	p_object_id        well.object_id%TYPE,
  	p_daytime          DATE,
	p_potential_method VARCHAR2 DEFAULT NULL ,
	p_decline_flag VARCHAR2 DEFAULT NULL)

RETURN NUMBER IS

lv2_potential_method   VARCHAR2(30);
lv2_decline_flag      VARCHAR2(1);
ln_return_val           NUMBER;
lr_day_rec              PWEL_DAY_STATUS%ROWTYPE;
lr_well_version         WELL_VERSION%ROWTYPE;
lr_pwel_result	        PWEL_RESULT%ROWTYPE;
lr_perf_curve           PERFORMANCE_CURVE%ROWTYPE;
ln_poten_2nd_value      NUMBER;
ln_poten_3rd_value      NUMBER;
ln_on_strm_hrs          NUMBER;
ln_prod_day_offset      NUMBER;
ld_start_daytime        DATE;
ld_from_date            DATE;
ln_fcst_scen_no         NUMBER;
lv2_scenario_id        VARCHAR2(32);
lv_perf_curve_id	   PERFORMANCE_CURVE.PERF_CURVE_ID%TYPE;

ld_end_daytime          DATE;
lb_first                BOOLEAN;
ld_eff_daytime          DATE;
ld_next_eff_daytime     DATE;
ld_prev_estimate        DATE;
ld_next_estimate        DATE;
ln_prev_test_no         NUMBER;
ld_prev_test            DATE;
ld_next_test            DATE;
ln_vol_rate             NUMBER;
lr_well_event_row       WELL_EVENT%ROWTYPE;
ln_day_frac             NUMBER;

BEGIN

   lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_potential_method := Nvl(p_potential_method, lr_well_version.potential_method);
   lv2_decline_flag := Nvl(p_decline_flag, Nvl(lr_well_version.decline_flag, 'N'));

   IF (lv2_potential_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;

      ln_return_val := EcDp_Well_Estimate.getCondStdRate(p_object_id,ld_start_daytime);

      -- method is candidate for decline calculations
      IF lv2_decline_flag = 'Y' THEN
         lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_pwel_result.valid_from_date;
         ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'CONDENSATE', ln_return_val);
      END IF;


   ELSIF (lv2_potential_method = EcDp_Calc_Method.CURVE) THEN

       lr_day_rec :=  ec_pwel_day_status.row_by_pk(
                           p_object_id,
                           p_daytime);

       ln_on_strm_hrs := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime);

       IF Nvl(ln_on_strm_hrs,0) > 0 THEN


          ln_return_val := EcBp_Well_Theoretical.getCurveRate(
                              p_object_id,
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
                              EcBp_Well_Theoretical.getGasLiftStdRateDay(p_object_id,p_daytime),
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
                              lr_day_rec.avg_dp_venturi
                              );

        ELSE

          lv_perf_curve_id := EcDp_Performance_Curve.getPrevWellPerformanceCurveId(
                                            p_object_id,
                                            p_daytime,
                                            EcDp_Curve_Purpose.PRODUCTION,
                                            EcDp_Phase.CONDENSATE);

          lr_perf_curve := ec_performance_curve.row_by_pk(lv_perf_curve_id);

          -- Find reference values from POTEN_2ND_VALUE and POTEN_3RD_VALUE
          ln_poten_2nd_value :=  lr_perf_curve.poten_2nd_value;
          ln_poten_3rd_value :=  lr_perf_curve.poten_3rd_value;

          ln_return_val := EcBp_Well_Theoretical.getCurveRate(
                              p_object_id,
                              p_daytime,
                              EcDp_Phase.CONDENSATE,
                              EcDp_Curve_Purpose.PRODUCTION,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              NULL,
                              NULL,
                              NULL,
                              ln_poten_3rd_value,
                              ln_poten_3rd_value,
                              NULL,
                              NULL,
                              ln_poten_3rd_value,
                              NULL,
                              ln_poten_2nd_value,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              ln_poten_2nd_value
                              );

       END IF;

      -- method is candidate for decline calculations
      IF lv2_decline_flag = 'Y' THEN
         ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.CONDENSATE));
         ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'CONDENSATE', ln_return_val);
       END IF;

   ELSIF (lv2_potential_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_pwel_day_alloc.alloc_cond_vol(p_object_id,p_daytime,lv2_scenario_id),ec_fcst_pwel_day.cond_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

   ELSIF (lv2_potential_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;
         ld_end_daytime := ld_start_daytime + 1;
         lb_first := TRUE;
         ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
         ld_next_eff_daytime := ld_start_daytime;

         WHILE ld_next_eff_daytime < ld_end_daytime LOOP

            ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
            ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

            ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
            ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
            ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

            IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
               ln_return_val := NULL;
               EXIT;
            ELSE
               ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
            END IF;

            IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
               lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
               ln_vol_rate := lr_pwel_result.net_cond_rate_adj;

            ELSE -- Use well production estimate for this period
               lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
               ln_vol_rate := Nvl(lr_well_event_row.cond_rate,lr_well_event_row.gas_rate* lr_well_event_row.cgr);

            END IF;

            -- find start of next period
            ld_next_eff_daytime := LEAST(
                                         LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                        ld_end_daytime);

            -- find fraction of the day current production potential covers
            ln_day_frac  := (ld_next_eff_daytime - GREATEST(ld_eff_daytime,ld_start_daytime));

            IF lb_first THEN
              ln_return_val := ln_vol_rate * ln_day_frac;
              lb_first := FALSE;
            ELSE
              ln_return_val := nvl(ln_return_val,0) + (ln_vol_rate * ln_day_frac);
            END IF;

            ld_eff_daytime := ld_next_eff_daytime;

         END LOOP;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.BUDGET_PLAN) THEN
    ln_return_val := ec_object_plan.cond_rate(p_object_id,p_daytime,'WELL_PLAN_BUDGET', '<=');

     -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_BUDGET');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'CONDENSATE', ln_return_val);
    END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.POTENTIAL_PLAN) THEN
    ln_return_val := ec_object_plan.cond_rate(p_object_id,p_daytime,'WELL_PLAN_POTENTIAL', '<=');

     -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_POTENTIAL');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'CONDENSATE', ln_return_val);
    END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.TARGET_PLAN) THEN
    ln_return_val := ec_object_plan.cond_rate(p_object_id,p_daytime,'WELL_PLAN_TARGET', '<=');

       -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_TARGET');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'CONDENSATE', ln_return_val);
    END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.OTHER_PLAN) THEN
    ln_return_val := ec_object_plan.cond_rate(p_object_id,p_daytime,'WELL_PLAN_OTHER', '<=');

     -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_OTHER');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'CONDENSATE', ln_return_val);
    END IF;

  ELSIF (substr(lv2_potential_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_return_val := Ue_Well_Potential.getConProductionPotential(
               p_object_id,
               p_daytime);

  ELSE -- undefined

     ln_return_val := NULL;

  END IF;

  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;


   RETURN ln_return_val;

END findConProductionPotential;


------------------------------------------------------------------
-- Function:    findGasInjectionPotential
-- Description: Returns the valid water injection potential
------------------------------------------------------------------
FUNCTION findGasInjectionPotential (
  p_object_id        well.object_id%TYPE,
  p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

  lv2_potential_method  VARCHAR2(30);
  ln_return_val          NUMBER;
  lr_day_rec             IWEL_DAY_STATUS%ROWTYPE;
  ln_poten_2nd_value     NUMBER;
  ln_on_strm_hrs         NUMBER;
  ln_fcst_scen_no        NUMBER;
  lv2_scenario_id        VARCHAR2(32);
  ld_daytime              DATE;
  ln_prod_day_offset      NUMBER;
  ld_cur_date             DATE;
  ln_inj_rate             NUMBER;
  ln_duration_fraction    NUMBER;
  ln_total_inj_rate       NUMBER;
  ln_fraction_rate        NUMBER;
  lv_perf_curve_id        NUMBER;

  CURSOR c_well_use_in_alloc IS
  SELECT *
  FROM well_event wed
  WHERE wed.object_id = p_object_id
  AND wed.EVENT_DAY = p_daytime
  AND wed.use_in_alloc = 'Y'
  AND wed.EVENT_TYPE = 'IWEL_EVENT_GAS'
  UNION
  SELECT *
  FROM well_event we2
  WHERE we2.object_id = p_object_id
  AND we2.use_in_alloc = 'Y'
  AND we2.EVENT_TYPE = 'IWEL_EVENT_GAS'
  AND we2.daytime =
  (select max(daytime) from well_event we3
  WHERE we3.object_id = p_object_id
  AND we3.use_in_alloc = 'Y'
  AND we3.EVENT_TYPE = 'IWEL_EVENT_GAS'
  AND we3.event_day < p_daytime);

BEGIN

  lv2_potential_method := Nvl(p_potential_method,ec_well_version.potential_gas_inj_method(
                                      p_object_id,
                                      p_daytime,
                                      '<='));

  IF (lv2_potential_method = EcDp_Calc_Method.CURVE) THEN

    lr_day_rec :=  ec_iwel_day_status.row_by_pk(
                           p_object_id,
                           p_daytime,
                           -- injection type is Gas Injection
                           'GI');

    ln_on_strm_hrs := EcDp_Well.getIwelOnStreamHrs(p_object_id,'GI',p_daytime);

    IF Nvl(ln_on_strm_hrs,0) > 0 THEN

      ln_return_val := EcBp_Well_Theoretical.getCurveRate(
                          p_object_id,
                          p_daytime,
                          EcDp_Phase.GAS,
                          EcDp_Curve_Purpose.INJECTION,
                          lr_day_rec.avg_choke_size,
                          lr_day_rec.avg_wh_press,
                          lr_day_rec.avg_wh_temp,
                          lr_day_rec.avg_bh_press,
                          lr_day_rec.avg_annulus_press,
                          lr_day_rec.avg_wh_usc_press,
                          lr_day_rec.avg_wh_dsc_press,
                          NULL, --lr_day_rec.bs_w,
                          NULL, --lr_day_rec.avg_dh_pump_speed,
                          NULL, --lr_day_rec.avg_gl_choke,
                          NULL, --lr_day_rec.avg_gl_press,
                          NULL, --EcBp_Well_Theoretical.getGasLiftStdRateDay(p_object_id, p_daytime, NULL),
                          NULL, --lr_day_rec.avg_gl_diff_press
                          NULL,  --avg_flow_,mass
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
                          'CURVE_INJ_GAS'
                         );

    ELSE

      lv_perf_curve_id := EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.INJECTION, EcDp_Phase.GAS);

      -- Find reference values from POTEN_2ND_VALUE
      ln_poten_2nd_value :=  ec_performance_curve.poten_2nd_value(lv_perf_curve_id);

      ln_return_val := EcBp_Well_Theoretical.getCurveRate(
                          p_object_id,
                          p_daytime,
                          EcDp_Phase.GAS,
                          EcDp_Curve_Purpose.INJECTION,
                          ln_poten_2nd_value,
                          ln_poten_2nd_value,
                          ln_poten_2nd_value,
                          ln_poten_2nd_value,
                          ln_poten_2nd_value,
                          NULL,
                          NULL,
                          null,
                          null,
                          null,
                          null,
                          null,
                          null,
                          NULL,  --avg_flow_mass
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          ln_poten_2nd_value
                          );

    END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_iwel_day_alloc.alloc_inj_vol(p_object_id,p_daytime,'GI',lv2_scenario_id),ec_fcst_iwel_day.gas_inj_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.EVENT_INJ_DATA) THEN

    ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24);
    ld_daytime := p_daytime + ln_prod_day_offset;
    ln_fraction_rate     := 0;
    ln_duration_fraction := 0;
    ln_total_inj_rate    := NULL;

    FOR cur_rate IN c_well_use_in_alloc LOOP
      -- get the inj rate of the last record registered for this record which is used in alloc.
      IF (cur_rate.event_day < p_daytime) then
        ln_inj_rate := cur_rate.avg_inj_rate;

      ELSE
        ln_duration_fraction := cur_rate.daytime - nvl(ld_cur_date, ld_daytime);
        ln_fraction_rate     :=  ln_fraction_rate +  (ln_duration_fraction * nvl( ln_inj_rate,0));
        ld_cur_date          := cur_rate.daytime;
        ln_inj_rate          :=  cur_rate.avg_inj_rate;
      END IF;
    END LOOP;

    ln_total_inj_rate :=  ln_fraction_rate    + (((ld_daytime + 1) - nvl(ld_cur_date,ld_daytime)) *  ln_inj_rate);

    ln_return_val := ln_total_inj_rate;


  ELSIF (lv2_potential_method = Ecdp_Calc_Method.BUDGET_PLAN) THEN
    ln_return_val := ec_object_plan.gas_inj_rate(p_object_id,p_daytime,'WELL_PLAN_BUDGET', '<=');

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.POTENTIAL_PLAN) THEN
    ln_return_val := ec_object_plan.gas_inj_rate(p_object_id,p_daytime,'WELL_PLAN_POTENTIAL', '<=');

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.TARGET_PLAN) THEN
    ln_return_val := ec_object_plan.gas_inj_rate(p_object_id,p_daytime,'WELL_PLAN_TARGET', '<=');

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.OTHER_PLAN) THEN
    ln_return_val := ec_object_plan.gas_inj_rate(p_object_id,p_daytime,'WELL_PLAN_OTHER', '<=');

  ELSIF (substr(lv2_potential_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_return_val := Ue_Well_Potential.getGasInjectionPotential(
              p_object_id,
              p_daytime);

  ELSE -- undefined
    ln_return_val := NULL;

  END IF;

  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;

  RETURN ln_return_val;

END findGasInjectionPotential;


------------------------------------------------------------------
-- Function:    findOilProductionPotential
-- Description: Returns the valid oil production potential
------------------------------------------------------------------
FUNCTION findOilProductionPotential (
  p_object_id        well.object_id%TYPE,
  p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL,
  p_decline_flag VARCHAR2 DEFAULT NULL)

RETURN NUMBER IS

  lv2_potential_method  VARCHAR2(30);
  lv2_decline_flag      VARCHAR2(1);
  lv_perf_curve_id       PERFORMANCE_CURVE.PERF_CURVE_ID%TYPE;

  ln_return_val         NUMBER;
  ln_poten_2nd_value    NUMBER;
  ln_poten_3rd_value    NUMBER;
  ln_test_pump_speed    NUMBER;
  ln_pump_speed_ratio   NUMBER;
  ln_on_strm_hrs        NUMBER;
  ln_day_frac           NUMBER;
  ln_prod_day_offset    NUMBER;
  ln_prev_test_no       NUMBER;
  ln_vol_rate           NUMBER;


  lr_pwel_result  PWEL_RESULT%ROWTYPE;
  lr_day_rec            PWEL_DAY_STATUS%ROWTYPE;
  lr_well_event_row     WELL_EVENT%ROWTYPE;
  lr_well_version       WELL_VERSION%ROWTYPE;
  lr_perf_curve           PERFORMANCE_CURVE%ROWTYPE;
  lb_first              BOOLEAN;

  ld_start_daytime      DATE;
  ld_end_daytime        DATE;
  ld_eff_daytime        DATE;
  ld_next_eff_daytime   DATE;
  ld_prev_estimate      DATE;
  ld_next_estimate      DATE;
  ld_prev_test          DATE;
  ld_next_test          DATE;
  ld_from_date          DATE;

  ln_fcst_scen_no       NUMBER;
  lv2_scenario_id        VARCHAR2(32);

BEGIN

  lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_potential_method := Nvl(p_potential_method, lr_well_version.potential_method);
  lv2_decline_flag := Nvl(p_decline_flag, Nvl(lr_well_version.decline_flag, 'N'));

  IF (lv2_potential_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
    ld_start_daytime := p_daytime + ln_prod_day_offset;

    ln_return_val := EcDp_Well_Estimate.getOilStdRate(p_object_id,ld_start_daytime);

    -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
      ld_from_date := lr_pwel_result.valid_from_date;
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'OIL', ln_return_val);
    END IF;

  ELSIF (lv2_potential_method = EcDp_Calc_Method.WELL_EST_PUMP_SPEED) THEN

    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
    ld_start_daytime := p_daytime + ln_prod_day_offset;

    ln_test_pump_speed := EcDp_Well_Estimate.getLastAvgDhPumpSpeed(p_object_id, ld_start_daytime);

    IF Nvl(ln_test_pump_speed,0) = 0 THEN

      ln_pump_speed_ratio := 1;  -- Avoid div/0

    ELSE

      lr_day_rec :=  ec_pwel_day_status.row_by_pk(
                            p_object_id,
                            p_daytime);

      IF Nvl(lr_day_rec.avg_dh_pump_speed,0) > 0 THEN
        ln_pump_speed_ratio := lr_day_rec.avg_dh_pump_speed / ln_test_pump_speed;
      ELSE
        lv_perf_curve_id := EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.OIL);

        ln_pump_speed_ratio := Nvl(ec_performance_curve.poten_3rd_value(lv_perf_curve_id),0)/ln_test_pump_speed;
      END IF;

    END IF;

    ln_return_val := EcDp_Well_Estimate.getOilStdRate(p_object_id,ld_start_daytime);
    ln_return_val := ln_return_val * ln_pump_speed_ratio;

    -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
      ld_from_date := lr_pwel_result.valid_from_date;
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'OIL', ln_return_val);
    END IF;

  ELSIF (lv2_potential_method = EcDp_Calc_Method.INTERPOLATE_WT) THEN

    ln_return_val := EcDp_Well_Estimate.getInterpolatedOilProdPot(p_object_id, p_daytime);

  ELSIF (lv2_potential_method = EcDp_Calc_Method.CURVE) THEN

    lr_day_rec :=  ec_pwel_day_status.row_by_pk(
                           p_object_id,
                           p_daytime);

    ln_on_strm_hrs := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime);


    IF Nvl(ln_on_strm_hrs,0) > 0 THEN

      ln_return_val := EcBp_Well_Theoretical.getCurveRate(
                              p_object_id,
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
                              EcBp_Well_Theoretical.getGasLiftStdRateDay(p_object_id,p_daytime),
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
                              lr_day_rec.avg_dp_venturi
                              );

    ELSE

      lv_perf_curve_id := EcDp_Performance_Curve.getWellPerformanceCurveId(
                                            p_object_id,
                                            p_daytime,
                                            EcDp_Curve_Purpose.PRODUCTION,
                                            EcDp_Phase.OIL);

      lr_perf_curve := ec_performance_curve.row_by_pk(lv_perf_curve_id);

      -- Find reference values from POTEN_2ND_VALUE
      ln_poten_2nd_value :=  lr_perf_curve.poten_2nd_value;
      ln_poten_3rd_value :=  lr_perf_curve.poten_3rd_value;

      ln_return_val := EcBp_Well_Theoretical.getCurveRate(
                              p_object_id,
                              p_daytime,
                              EcDp_Phase.OIL,
                              EcDp_Curve_Purpose.PRODUCTION,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              NULL,
                              NULL,
                              NULL,
                              ln_poten_3rd_value,
                              ln_poten_3rd_value,
                              NULL,
                              NULL,
                              ln_poten_3rd_value,
                              NULL,
                              ln_poten_2nd_value,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              ln_poten_2nd_value
                              );

    END IF;

    -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.OIL));
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'OIL', ln_return_val);
    END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_pwel_day_alloc.alloc_net_oil_vol(p_object_id,p_daytime,lv2_scenario_id), ec_fcst_pwel_day.net_oil_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

  ELSIF (lv2_potential_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
    ld_start_daytime := p_daytime + ln_prod_day_offset;
    ld_end_daytime := ld_start_daytime + 1;
    lb_first := TRUE;
    ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
    ld_next_eff_daytime := ld_start_daytime;

    WHILE ld_next_eff_daytime < ld_end_daytime LOOP

      ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
      ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

      ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
      ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
      ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

      IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
        ln_return_val := NULL;
        EXIT;
      ELSE
        ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
      END IF;

      IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
        lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
        ln_vol_rate := lr_pwel_result.net_oil_rate_adj;

      ELSE -- Use well production estimate for this period
        lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
        ln_vol_rate := Nvl(lr_well_event_row.net_oil_rate,lr_well_event_row.grs_oil_rate*(1-lr_well_event_row.bs_w));

      END IF;

      -- find start of next period
      ld_next_eff_daytime := LEAST(
                                   LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                   ld_end_daytime);

      -- find fraction of the day current production potential covers
      ln_day_frac  := (ld_next_eff_daytime - GREATEST(ld_eff_daytime,ld_start_daytime));

      IF lb_first THEN
        ln_return_val := ln_vol_rate * ln_day_frac;
        lb_first := FALSE;
      ELSE
        ln_return_val := nvl(ln_return_val,0) + (ln_vol_rate * ln_day_frac);
      END IF;

      ld_eff_daytime := ld_next_eff_daytime;

    END LOOP;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.BUDGET_PLAN) THEN
    ln_return_val := ec_object_plan.oil_rate(p_object_id,p_daytime,'WELL_PLAN_BUDGET', '<=');

    -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_BUDGET');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'OIL', ln_return_val);
   END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.POTENTIAL_PLAN) THEN
    ln_return_val := ec_object_plan.oil_rate(p_object_id,p_daytime,'WELL_PLAN_POTENTIAL', '<=');

     -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_POTENTIAL');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'OIL', ln_return_val);
   END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.TARGET_PLAN) THEN
    ln_return_val := ec_object_plan.oil_rate(p_object_id,p_daytime,'WELL_PLAN_TARGET', '<=');

    -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_TARGET');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'OIL', ln_return_val);
   END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.OTHER_PLAN) THEN
    ln_return_val := ec_object_plan.oil_rate(p_object_id,p_daytime,'WELL_PLAN_OTHER', '<=');

     -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_OTHER');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'OIL', ln_return_val);
   END IF;

  ELSIF (substr(lv2_potential_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_return_val := Ue_Well_Potential.getOilProductionPotential(
                        p_object_id,
                        p_daytime);

  ELSE -- undefined

    ln_return_val := NULL;

  END IF;

  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;

  RETURN ln_return_val;

END findOilProductionPotential;


------------------------------------------------------------------
-- Function:    findGasProductionPotential
-- Description: Returns the valid gas production potential
------------------------------------------------------------------

FUNCTION findGasProductionPotential (
  p_object_id        well.object_id%TYPE,
    p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL,
  p_decline_flag VARCHAR2 DEFAULT NULL)

RETURN NUMBER IS

   lv2_potential_method  VARCHAR2(30);
   lv2_decline_flag      VARCHAR2(1);
   ln_return_val         NUMBER;
   ln_poten_2nd_value    NUMBER;
   ln_poten_3rd_value    NUMBER;
   ln_test_pump_speed    NUMBER;
   ln_pump_speed_ratio   NUMBER;
   ln_on_strm_hrs        NUMBER;
   ln_day_frac           NUMBER;
   ln_prod_day_offset    NUMBER;
   ln_prev_test_no       NUMBER;
   ln_vol_rate           NUMBER;
   ln_oil_rate            NUMBER;
   ln_gas_rate            NUMBER;
   ln_gor                 NUMBER;


   lr_pwel_result   PWEL_RESULT%ROWTYPE;
   lr_day_rec            PWEL_DAY_STATUS%ROWTYPE;
   lr_well_event_row     WELL_EVENT%ROWTYPE;
   lr_well_version       WELL_VERSION%ROWTYPE;
   lr_perf_curve           PERFORMANCE_CURVE%ROWTYPE;
   lb_first              BOOLEAN;

   ld_start_daytime      DATE;
   ld_end_daytime        DATE;
   ld_eff_daytime        DATE;
   ld_next_eff_daytime   DATE;
   ld_prev_estimate      DATE;
   ld_next_estimate      DATE;
   ld_prev_test          DATE;
   ld_next_test          DATE;
   ld_from_date          DATE;
   ln_fcst_scen_no       NUMBER;
   lv2_scenario_id        VARCHAR2(32);
   lv_perf_curve_id        PERFORMANCE_CURVE.PERF_CURVE_ID%TYPE;

BEGIN

   lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_potential_method := Nvl(p_potential_method, lr_well_version.potential_method);
   lv2_decline_flag := Nvl(p_decline_flag, Nvl(lr_well_version.decline_flag, 'N'));

   IF (lv2_potential_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;

      ln_return_val := EcDp_Well_Estimate.getGasStdRate(p_object_id,ld_start_daytime);

      -- method is candidate for decline calculations
      IF lv2_decline_flag = 'Y' THEN
         lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_pwel_result.valid_from_date;
         ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'GAS', ln_return_val);
      END IF;

   ELSIF (lv2_potential_method = EcDp_Calc_Method.WELL_EST_PUMP_SPEED) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;


      IF EcDp_Well.getWellType(
                         p_object_id, p_daytime) = EcDp_Well_Type.GAS_PRODUCER THEN
         ln_return_val := NULL;  -- Downhole pump speed method not relevant for gas producers!

      ELSE -- Use oil rate and GOR

         lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, ld_start_daytime);

         ln_oil_rate := lr_pwel_result.net_oil_rate_adj;
         ln_gas_rate := lr_pwel_result.gas_rate_adj;

         IF Nvl(ln_oil_rate,0) = 0 THEN
            ln_return_val := 0;    -- No oil, means no gas... Avoid div/0
         ELSE
            ln_gor := ln_gas_rate / ln_oil_rate;

            ln_return_val := findOilProductionPotential(
                                            p_object_id,
                                            p_daytime,
                                            lv2_potential_method) * ln_gor;
         END IF;

      END IF;

      -- method is candidate for decline calculations
      IF lv2_decline_flag = 'Y' THEN
         lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_pwel_result.valid_from_date;
         ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'GAS', ln_return_val);
      END IF;

   ELSIF (lv2_potential_method = EcDp_Calc_Method.CURVE) THEN

       lr_day_rec :=  ec_pwel_day_status.row_by_pk(
                           p_object_id,
                           p_daytime);


       ln_on_strm_hrs := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime);

       IF Nvl(ln_on_strm_hrs,0) > 0 THEN

          ln_return_val := EcBp_Well_Theoretical.getCurveRate(
                              p_object_id,
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
                              EcBp_Well_Theoretical.getGasLiftStdRateDay(p_object_id,p_daytime),
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
                              lr_day_rec.avg_dp_venturi
                              );

       ELSE

          lv_perf_curve_id := EcDp_Performance_Curve.getPrevWellPerformanceCurveId(
                                            p_object_id,
                                            p_daytime,
                                            EcDp_Curve_Purpose.PRODUCTION,
                                            EcDp_Phase.GAS);

          lr_perf_curve := ec_performance_curve.row_by_pk(lv_perf_curve_id);

          -- Find reference values from POTEN_2ND_VALUE
          ln_poten_2nd_value :=  lr_perf_curve.poten_2nd_value;
          ln_poten_3rd_value :=  lr_perf_curve.poten_3rd_value;

          ln_return_val := EcBp_Well_Theoretical.getCurveRate(
                              p_object_id,
                              p_daytime,
                              EcDp_Phase.GAS,
                              EcDp_Curve_Purpose.PRODUCTION,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              NULL,
                              NULL,
                              NULL,
                              ln_poten_3rd_value,
                              ln_poten_3rd_value,
                              NULL,
                              NULL,
                              ln_poten_3rd_value,
                              NULL,
                              ln_poten_2nd_value,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              ln_poten_2nd_value
                              );

       END IF;

      -- method is candidate for decline calculations
  IF lv2_decline_flag = 'Y' THEN
     ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.GAS));
     ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'GAS', ln_return_val);
  END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_pwel_day_alloc.alloc_gas_vol(p_object_id,p_daytime,lv2_scenario_id), ec_fcst_pwel_day.gas_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

  ELSIF (lv2_potential_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;
         ld_end_daytime := ld_start_daytime + 1;
         lb_first := TRUE;
         ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
         ld_next_eff_daytime := ld_start_daytime;

         WHILE ld_next_eff_daytime < ld_end_daytime LOOP

            ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
            ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

            ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
            ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
            ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

            IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
               ln_return_val := NULL;
               EXIT;
            ELSE
               ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
            END IF;

            IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
               lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
               ln_vol_rate := lr_pwel_result.gas_rate_adj;

            ELSE -- Use well production estimate for this period
               lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
               ln_vol_rate := Nvl(lr_well_event_row.gas_rate,lr_well_event_row.net_oil_rate* lr_well_event_row.gor);

            END IF;

            -- find start of next period
            ld_next_eff_daytime := LEAST(
                                         LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                        ld_end_daytime);

            -- find fraction of the day current production potential covers
            ln_day_frac  := (ld_next_eff_daytime - GREATEST(ld_eff_daytime,ld_start_daytime));

            IF lb_first THEN
              ln_return_val := ln_vol_rate * ln_day_frac;
              lb_first := FALSE;
            ELSE
              ln_return_val := nvl(ln_return_val,0) + (ln_vol_rate * ln_day_frac);
            END IF;

            ld_eff_daytime := ld_next_eff_daytime;

         END LOOP;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.BUDGET_PLAN) THEN
    ln_return_val := ec_object_plan.gas_rate(p_object_id,p_daytime,'WELL_PLAN_BUDGET', '<=');

    -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_BUDGET');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'GAS', ln_return_val);
   END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.POTENTIAL_PLAN) THEN
    ln_return_val := ec_object_plan.gas_rate(p_object_id,p_daytime,'WELL_PLAN_POTENTIAL', '<=');

    -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_POTENTIAL');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'GAS', ln_return_val);
   END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.TARGET_PLAN) THEN
    ln_return_val := ec_object_plan.gas_rate(p_object_id,p_daytime,'WELL_PLAN_TARGET', '<=');

     -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_TARGET');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'GAS', ln_return_val);
   END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.OTHER_PLAN) THEN
    ln_return_val := ec_object_plan.gas_rate(p_object_id,p_daytime,'WELL_PLAN_OTHER', '<=');

     -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_OTHER');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'GAS', ln_return_val);
   END IF;

  ELSIF (substr(lv2_potential_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_return_val := Ue_Well_Potential.getGasProductionPotential(
               p_object_id,
               p_daytime);

  ELSE -- undefined

     ln_return_val := NULL;

  END IF;


  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;


   RETURN ln_return_val;


END findGasProductionPotential;


------------------------------------------------------------------
-- Function:    findWatInjectionPotential
-- Description: Returns the valid water injection potential
------------------------------------------------------------------
FUNCTION findWatInjectionPotential (
  p_object_id        well.object_id%TYPE,
  p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

  lv2_potential_method  VARCHAR2(30);
  ln_return_val        NUMBER;
  lr_day_rec           IWEL_DAY_STATUS%ROWTYPE;
  ln_poten_2nd_value   NUMBER;
  ln_on_strm_hrs       NUMBER;
  ln_fcst_scen_no      NUMBER;
  lv2_scenario_id        VARCHAR2(32);
  ld_daytime              DATE;
  ln_prod_day_offset      NUMBER;
  ld_cur_date             DATE;
  ln_inj_rate             NUMBER;
  ln_duration_fraction    NUMBER;
  ln_total_inj_rate       NUMBER;
  ln_fraction_rate        NUMBER;
  lv_perf_curve_id        NUMBER;

  CURSOR c_well_use_in_alloc IS
  SELECT *
  FROM well_event wed
  WHERE wed.object_id = p_object_id
  AND wed.EVENT_DAY = p_daytime
  AND wed.use_in_alloc = 'Y'
  AND wed.EVENT_TYPE = 'IWEL_EVENT_WATER'
  UNION
  SELECT *
  FROM well_event we2
  WHERE we2.object_id = p_object_id
  AND we2.use_in_alloc = 'Y'
  AND we2.EVENT_TYPE = 'IWEL_EVENT_WATER'
  AND we2.daytime =
  (select max(daytime) from well_event we3
  WHERE we3.object_id = p_object_id
  AND we3.use_in_alloc = 'Y'
  AND we3.EVENT_TYPE = 'IWEL_EVENT_WATER'
  AND we3.event_day < p_daytime);

BEGIN

  lv2_potential_method := Nvl(p_potential_method,ec_well_version.pot_water_inj_method(
                              p_object_id,
                              p_daytime,
                              '<='));

  IF (lv2_potential_method = EcDp_Calc_Method.CURVE) THEN

    lr_day_rec :=  ec_iwel_day_status.row_by_pk(
                           p_object_id,
                           p_daytime,
                           'WI');

    ln_on_strm_hrs := EcDp_Well.getIwelOnStreamHrs(p_object_id,'WI',p_daytime);

    IF Nvl(ln_on_strm_hrs,0) > 0 THEN

      ln_return_val := EcBp_Well_Theoretical.getCurveRate(
                              p_object_id,
                              p_daytime,
                              EcDp_Phase.WATER,
                              EcDp_Curve_Purpose.INJECTION,
                              lr_day_rec.avg_choke_size,
                              lr_day_rec.avg_wh_press,
                              lr_day_rec.avg_wh_temp,
                              lr_day_rec.avg_bh_press,
                              lr_day_rec.avg_annulus_press,
                              lr_day_rec.avg_wh_usc_press,
                              lr_day_rec.avg_wh_dsc_press,
                              NULL, --lr_day_rec.bs_w,
                              NULL, --lr_day_rec.avg_dh_pump_speed,
                              NULL, --lr_day_rec.avg_gl_choke,
                              NULL, --lr_day_rec.avg_gl_press,
                              NULL, --EcBp_Well_Theoretical.getGasLiftStdRateDay(p_object_id,p_daytime),
                              NULL, --lr_day_rec.avg_gl_diff_press
                              NULL,  --avg_flow_mass
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
                              'CURVE_INJ_WATER'
                              );

    ELSE

      lv_perf_curve_id := EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.INJECTION, EcDp_Phase.WATER);

      -- Find reference values from POTEN_2ND_VALUE
      ln_poten_2nd_value := ec_performance_curve.poten_2nd_value(lv_perf_curve_id);

      ln_return_val := EcBp_Well_Theoretical.getCurveRate(
                              p_object_id,
                              p_daytime,
                              EcDp_Phase.WATER,
                              EcDp_Curve_Purpose.INJECTION,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              ln_poten_2nd_value,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,  --avg_flow_mass
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              ln_poten_2nd_value
                              );

    END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_iwel_day_alloc.alloc_inj_vol(p_object_id,p_daytime,'WI',lv2_scenario_id), ec_fcst_iwel_day.water_inj_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.EVENT_INJ_DATA) THEN
    ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24);
    ld_daytime := p_daytime + ln_prod_day_offset;
    ln_fraction_rate     := 0;
    ln_duration_fraction := 0;
    ln_total_inj_rate    := NULL;

    FOR cur_rate IN c_well_use_in_alloc LOOP
      -- get the inj rate of the last record registered for this record which is used in alloc.
      IF (cur_rate.event_day < p_daytime) then
        ln_inj_rate := cur_rate.avg_inj_rate;
      ELSE
        ln_duration_fraction := cur_rate.daytime - nvl(ld_cur_date, ld_daytime);
        ln_fraction_rate     :=  ln_fraction_rate +  (ln_duration_fraction * nvl( ln_inj_rate,0));
        ld_cur_date          := cur_rate.daytime;
        ln_inj_rate          :=  cur_rate.avg_inj_rate;
      END IF;
    END LOOP;

    ln_total_inj_rate :=  ln_fraction_rate    + (((ld_daytime + 1) - nvl(ld_cur_date,ld_daytime)) *  ln_inj_rate);

    ln_return_val := ln_total_inj_rate;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.BUDGET_PLAN) THEN
    ln_return_val := ec_object_plan.wat_inj_rate(p_object_id,p_daytime,'WELL_PLAN_BUDGET', '<=');

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.POTENTIAL_PLAN) THEN
    ln_return_val := ec_object_plan.wat_inj_rate(p_object_id,p_daytime,'WELL_PLAN_POTENTIAL', '<=');

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.TARGET_PLAN) THEN
    ln_return_val := ec_object_plan.wat_inj_rate(p_object_id,p_daytime,'WELL_PLAN_TARGET', '<=');

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.OTHER_PLAN) THEN
    ln_return_val := ec_object_plan.wat_inj_rate(p_object_id,p_daytime,'WELL_PLAN_OTHER', '<=');

  ELSIF (substr(lv2_potential_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_return_val := Ue_Well_Potential.getWatInjectionPotential(
                        p_object_id,
                        p_daytime);

  ELSE -- undefined

    ln_return_val := NULL;

  END IF;

  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;

  RETURN ln_return_val;

END findWatInjectionPotential;


------------------------------------------------------------------
-- Function:    findSteamInjectionPotential
-- Description: Returns the valid stream injection potential
------------------------------------------------------------------
FUNCTION findSteamInjectionPotential (
  p_object_id        well.object_id%TYPE,
  p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

  lv2_potential_method  VARCHAR2(30);
  ln_return_val         NUMBER;
  lr_day_rec            IWEL_DAY_STATUS%ROWTYPE;
  ln_poten_2nd_value    NUMBER;
  ln_on_strm_hrs        NUMBER;
  ln_fcst_scen_no       NUMBER;
  lv2_scenario_id        VARCHAR2(32);
  ld_daytime              DATE;
  ln_prod_day_offset      NUMBER;
  ld_cur_date             DATE;
  ln_inj_rate             NUMBER;
  ln_duration_fraction    NUMBER;
  ln_total_inj_rate       NUMBER;
  ln_fraction_rate        NUMBER;
  lv_perf_curve_id        NUMBER;

  CURSOR c_well_use_in_alloc IS
  SELECT *
  FROM well_event wed
  WHERE wed.object_id = p_object_id
  AND wed.EVENT_DAY = p_daytime
  AND wed.use_in_alloc = 'Y'
  AND wed.EVENT_TYPE = 'IWEL_EVENT_STEAM'
  UNION
  SELECT *
  FROM well_event we2
  WHERE we2.object_id = p_object_id
  AND we2.use_in_alloc = 'Y'
  AND we2.EVENT_TYPE = 'IWEL_EVENT_STEAM'
  AND we2.daytime =
  (select max(daytime) from well_event we3
  WHERE we3.object_id = p_object_id
  AND we3.use_in_alloc = 'Y'
  AND we3.EVENT_TYPE = 'IWEL_EVENT_STEAM'
  AND we3.event_day < p_daytime);

BEGIN

  lv2_potential_method := Nvl(p_potential_method,ec_well_version.pot_steam_inj_method(
                             p_object_id,
                             p_daytime,
                             '<='));

  IF (lv2_potential_method = Ecdp_Calc_Method.EVENT_INJ_DATA) THEN
    ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24);
    ld_daytime := p_daytime + ln_prod_day_offset;
    ln_fraction_rate     := 0;
    ln_duration_fraction := 0;
    ln_total_inj_rate    := NULL;

    FOR cur_rate IN c_well_use_in_alloc LOOP
      -- get the inj rate of the last record registered for this record which is used in alloc.
      IF (cur_rate.event_day < p_daytime) then
        ln_inj_rate := cur_rate.avg_inj_rate;
      ELSE
        ln_duration_fraction := cur_rate.daytime - nvl(ld_cur_date, ld_daytime);
        ln_fraction_rate     :=  ln_fraction_rate +  (ln_duration_fraction * nvl( ln_inj_rate,0));
        ld_cur_date          := cur_rate.daytime;
        ln_inj_rate          :=  cur_rate.avg_inj_rate;
      END IF;
    END LOOP;
    ln_total_inj_rate :=  ln_fraction_rate    + (((ld_daytime + 1) - nvl(ld_cur_date,ld_daytime)) *  ln_inj_rate);

    ln_return_val := ln_total_inj_rate;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.BUDGET_PLAN) THEN
    ln_return_val := ec_object_plan.steam_inj_rate(p_object_id,p_daytime,'WELL_PLAN_BUDGET', '<=');

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.POTENTIAL_PLAN) THEN
    ln_return_val := ec_object_plan.steam_inj_rate(p_object_id,p_daytime,'WELL_PLAN_POTENTIAL', '<=');

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.TARGET_PLAN) THEN
    ln_return_val := ec_object_plan.steam_inj_rate(p_object_id,p_daytime,'WELL_PLAN_TARGET', '<=');

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.OTHER_PLAN) THEN
    ln_return_val := ec_object_plan.steam_inj_rate(p_object_id,p_daytime,'WELL_PLAN_OTHER', '<=');

  ELSIF (substr(lv2_potential_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_return_val := Ue_Well_Potential.getSteamInjectionPotential(
              p_object_id,
              p_daytime);

  ELSE -- undefined

    ln_return_val := NULL;

  END IF;

  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;

  RETURN ln_return_val;

END findSteamInjectionPotential;


------------------------------------------------------------------
-- Function:    findCo2InjectionPotential
-- Description: Returns the valid co2 injection potential
------------------------------------------------------------------
FUNCTION findCo2InjectionPotential (
  p_object_id        well.object_id%TYPE,
  p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

lv2_potential_method  VARCHAR2(30);
ln_return_val         NUMBER;
ln_fcst_scen_no       NUMBER;
lv2_scenario_id        VARCHAR2(32);
ld_daytime              DATE;

BEGIN

   lv2_potential_method := Nvl(p_potential_method,ec_well_version.pot_co2_inj_method(
                              p_object_id,
                             p_daytime,
                             '<='));


  IF (lv2_potential_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_iwel_day_alloc.alloc_inj_vol(p_object_id,p_daytime,'CI',lv2_scenario_id), ec_fcst_iwel_day.co2_inj_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

   ELSIF (lv2_potential_method = Ecdp_Calc_Method.BUDGET_PLAN) THEN
     ln_return_val := ec_object_plan.co2_inj_rate(p_object_id,p_daytime,'WELL_PLAN_BUDGET', '<=');

   ELSIF (lv2_potential_method = Ecdp_Calc_Method.POTENTIAL_PLAN) THEN
     ln_return_val := ec_object_plan.co2_inj_rate(p_object_id,p_daytime,'WELL_PLAN_POTENTIAL', '<=');

   ELSIF (lv2_potential_method = Ecdp_Calc_Method.TARGET_PLAN) THEN
     ln_return_val := ec_object_plan.co2_inj_rate(p_object_id,p_daytime,'WELL_PLAN_TARGET', '<=');

   ELSIF (lv2_potential_method = Ecdp_Calc_Method.OTHER_PLAN) THEN
     ln_return_val := ec_object_plan.co2_inj_rate(p_object_id,p_daytime,'WELL_PLAN_OTHER', '<=');

   ELSIF (substr(lv2_potential_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_return_val := Ue_Well_Potential.getCO2InjectionPotential(
               p_object_id,
               p_daytime);

   ELSE -- undefined

     ln_return_val := NULL;

   END IF;

   IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
     ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
   END IF;


   RETURN ln_return_val;


END findCo2InjectionPotential;

------------------------------------------------------------------
-- Function:    findWatProductionPotential
-- Description: Returns the valid water production potential
------------------------------------------------------------------
FUNCTION findWatProductionPotential (
  p_object_id        well.object_id%TYPE,
    p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL,
  p_decline_flag VARCHAR2 DEFAULT NULL)

RETURN NUMBER IS

   lv2_potential_method  VARCHAR2(30);
   lv2_decline_flag      VARCHAR2(1);
   ln_return_val         NUMBER;
   ln_poten_2nd_value    NUMBER;
   ln_poten_3rd_value    NUMBER;
   ln_test_pump_speed    NUMBER;
   ln_pump_speed_ratio   NUMBER;
   ln_on_strm_hrs        NUMBER;
   ln_day_frac           NUMBER;
   ln_prod_day_offset    NUMBER;
   ln_prev_test_no       NUMBER;
   ln_vol_rate           NUMBER;
   ln_oil_rate           NUMBER;
   ln_gas_rate           NUMBER;
   ln_gor                NUMBER;
   ln_wat_rate           NUMBER;
   ln_wat_oil_ratio      NUMBER;

   lr_pwel_result   PWEL_RESULT%ROWTYPE;
   lr_day_rec            PWEL_DAY_STATUS%ROWTYPE;
   lr_well_event_row     WELL_EVENT%ROWTYPE;
   lr_well_version       WELL_VERSION%ROWTYPE;
   lb_first              BOOLEAN;

   ld_start_daytime      DATE;
   ld_end_daytime        DATE;
   ld_eff_daytime        DATE;
   ld_next_eff_daytime   DATE;
   ld_prev_estimate      DATE;
   ld_next_estimate      DATE;
   ld_prev_test          DATE;
   ld_next_test          DATE;
   ld_from_date          DATE;
   ln_fcst_scen_no       NUMBER;
   lv2_scenario_id        VARCHAR2(32);


BEGIN

   lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_potential_method := Nvl(p_potential_method, lr_well_version.potential_method);
   lv2_decline_flag := Nvl(p_decline_flag, Nvl(lr_well_version.decline_flag, 'N'));

   IF (lv2_potential_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;

      ln_return_val := EcDp_Well_Estimate.getWatStdRate(p_object_id, ld_start_daytime);

      -- method is candidate for decline calculations
      IF lv2_decline_flag = 'Y' THEN
         lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_pwel_result.valid_from_date;
         ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'WATER', ln_return_val);
      END IF;

   ELSIF (lv2_potential_method = EcDp_Calc_Method.WELL_EST_PUMP_SPEED) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;

      lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, ld_start_daytime);

      ln_oil_rate := lr_pwel_result.net_oil_rate_adj;
      ln_wat_rate := lr_pwel_result.tot_water_rate_adj;

      IF Nvl(ln_oil_rate, 0) = 0 THEN -- Avoid div/0, no oil means no water...
         ln_return_val := 0;
      ELSE
         ln_wat_oil_ratio := ln_wat_rate / ln_oil_rate;
         ln_return_val := findOilProductionPotential(
                                               p_object_id,
                                               p_daytime,
                                               lv2_potential_method) * ln_wat_oil_ratio;
      END IF;

      -- method is candidate for decline calculations
      IF lv2_decline_flag = 'Y' THEN
         lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
         ld_from_date := lr_pwel_result.valid_from_date;
         ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'WATER', ln_return_val);
      END IF;

   ELSIF (lv2_potential_method = EcDp_Calc_Method.CURVE) THEN

       lr_day_rec :=  ec_pwel_day_status.row_by_pk(
                           p_object_id,
                           p_daytime);

       ln_return_val := EcBp_Well_Theoretical.getCurveRate(
                           p_object_id,
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
                           EcBp_Well_Theoretical.getGasLiftStdRateDay(p_object_id,p_daytime),
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
                           lr_day_rec.avg_dp_venturi
                           );

    -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
       ld_from_date := ec_performance_curve.daytime(EcDp_Performance_Curve.getWellPerformanceCurveId(p_object_id, p_daytime, EcDp_Curve_Purpose.PRODUCTION, EcDp_Phase.WATER));
       ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'WATER', ln_return_val);
    END IF;


  ELSIF (lv2_potential_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_pwel_day_alloc.alloc_water_vol(p_object_id,p_daytime,lv2_scenario_id), ec_fcst_pwel_day.water_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

  ELSIF (lv2_potential_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

         ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
         ld_start_daytime := p_daytime + ln_prod_day_offset;
         ld_end_daytime := ld_start_daytime + 1;
         lb_first := TRUE;
         ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
         ld_next_eff_daytime := ld_start_daytime;

         WHILE ld_next_eff_daytime < ld_end_daytime LOOP

            ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
            ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

            ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
            ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
            ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

            IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
               ln_return_val := NULL;
               EXIT;
            ELSE
               ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
            END IF;

            IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
               lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
               ln_vol_rate := lr_pwel_result.tot_water_rate_adj;

            ELSE -- Use well production estimate for this period
               lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
               ln_vol_rate := Nvl(lr_well_event_row.water_rate,0)+ Nvl(lr_well_event_row.grs_oil_rate*lr_well_event_row.bs_w,0);

            END IF;

            -- find start of next period
            ld_next_eff_daytime := LEAST(
                                         LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                        ld_end_daytime);

            -- find fraction of the day current production potential covers
            ln_day_frac  := (ld_next_eff_daytime - GREATEST(ld_eff_daytime,ld_start_daytime));

            IF lb_first THEN
              ln_return_val := ln_vol_rate * ln_day_frac;
              lb_first := FALSE;
            ELSE
              ln_return_val := nvl(ln_return_val,0) + (ln_vol_rate * ln_day_frac);
            END IF;

            ld_eff_daytime := ld_next_eff_daytime;

         END LOOP;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.BUDGET_PLAN) THEN
    ln_return_val := ec_object_plan.water_rate(p_object_id,p_daytime,'WELL_PLAN_BUDGET', '<=');
    -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_BUDGET');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'WATER', ln_return_val);
    END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.POTENTIAL_PLAN) THEN
    ln_return_val := ec_object_plan.water_rate(p_object_id,p_daytime,'WELL_PLAN_POTENTIAL', '<=');

     -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_POTENTIAL');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'WATER', ln_return_val);
    END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.TARGET_PLAN) THEN
    ln_return_val := ec_object_plan.water_rate(p_object_id,p_daytime,'WELL_PLAN_TARGET', '<=');

     -- method is candidate for decline calculations
    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_TARGET');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'WATER', ln_return_val);
    END IF;

  ELSIF (lv2_potential_method = Ecdp_Calc_Method.OTHER_PLAN) THEN
    ln_return_val := ec_object_plan.water_rate(p_object_id,p_daytime,'WELL_PLAN_OTHER', '<=');

    IF lv2_decline_flag = 'Y' THEN
      ld_from_date := EcBp_Well_Potential.findObjPlanMaxDaytime(p_object_id, p_daytime, 'WELL_PLAN_OTHER');
      ln_return_val := EcBp_Well_Theoretical.declineResult(p_object_id, p_daytime, ld_from_date, 'WATER', ln_return_val);
    END IF;

  ELSIF (substr(lv2_potential_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_return_val := Ue_Well_Potential.getWatProductionPotential(
               p_object_id,
               p_daytime);

  ELSE -- undefined

     ln_return_val := NULL;

  END IF;


  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;


   RETURN ln_return_val;


END findWatProductionPotential;

------------------------------------------------------------------
-- Function:    findGasLiftPotential
-- Description: Returns the valid gas lift potential
------------------------------------------------------------------
FUNCTION findGasLiftPotential(
  p_object_id        well.object_id%TYPE,
    p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

   lv2_potential_method  VARCHAR2(30);

   ln_return_val         NUMBER;
   ln_poten_2nd_value    NUMBER;
   ln_poten_3rd_value    NUMBER;
   ln_test_pump_speed    NUMBER;
   ln_pump_speed_ratio   NUMBER;
   ln_on_strm_hrs        NUMBER;
   ln_day_frac           NUMBER;
   ln_prod_day_offset    NUMBER;
   ln_prev_test_no       NUMBER;
   ln_vol_rate           NUMBER;
   ln_oil_rate           NUMBER;
   ln_gas_rate           NUMBER;
   ln_gor                NUMBER;
   ln_wat_rate           NUMBER;
   ln_wat_oil_ratio      NUMBER;

   lr_pwel_result   PWEL_RESULT%ROWTYPE;
   lr_day_rec            PWEL_DAY_STATUS%ROWTYPE;
   lr_well_event_row     WELL_EVENT%ROWTYPE;
   lb_first              BOOLEAN;

   ld_start_daytime      DATE;
   ld_end_daytime        DATE;
   ld_eff_daytime        DATE;
   ld_next_eff_daytime   DATE;
   ld_prev_estimate      DATE;
   ld_next_estimate      DATE;
   ld_prev_test          DATE;
   ld_next_test          DATE;
   ln_fcst_scen_no       NUMBER;
   lv2_scenario_id        VARCHAR2(32);


BEGIN

   lv2_potential_method := Nvl(p_potential_method,ec_well_version.potential_method(
                       p_object_id,
                                      p_daytime,
                           '<='));

   IF (lv2_potential_method = EcDp_Calc_Method.CURVE) THEN

      ln_return_val := NULL;

   ELSIF (lv2_potential_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;

      lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, ld_start_daytime);
      ln_return_val := lr_pwel_result.GL_RATE;

   ELSIF (lv2_potential_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_pwel_day_alloc.alloc_gl_vol(p_object_id,p_daytime,lv2_scenario_id), ec_fcst_pwel_day.gas_lift_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

  ELSIF (lv2_potential_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

     ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
     ld_start_daytime := p_daytime + ln_prod_day_offset;
     ld_end_daytime := ld_start_daytime + 1;
     lb_first := TRUE;
     ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
     ld_next_eff_daytime := ld_start_daytime;

     WHILE ld_next_eff_daytime < ld_end_daytime LOOP

        ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
        ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

        ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
        ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
        ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

        IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
           ln_return_val := NULL;
           EXIT;
        ELSE
           ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
        END IF;

        IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
           lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
           ln_vol_rate := lr_pwel_result.gl_rate;

        ELSE -- Use well production estimate for this period
           lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
           ln_vol_rate := lr_well_event_row.gl_rate;

        END IF;

        -- find start of next period
        ld_next_eff_daytime := LEAST(
                                     LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                    ld_end_daytime);

        -- find fraction of the day current production potential covers
        ln_day_frac  := (ld_next_eff_daytime - GREATEST(ld_eff_daytime,ld_start_daytime));

        IF lb_first THEN
          ln_return_val := ln_vol_rate * ln_day_frac;
          lb_first := FALSE;
        ELSE
          ln_return_val := nvl(ln_return_val,0) + (ln_vol_rate * ln_day_frac);
        END IF;

        ld_eff_daytime := ld_next_eff_daytime;

     END LOOP;

  ELSIF (substr(lv2_potential_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_return_val := Ue_Well_Potential.getGasLiftPotential(
               p_object_id,
               p_daytime);

  ELSE -- undefined

     ln_return_val := NULL;

  END IF;

  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;


  RETURN ln_return_val;

END findGasLiftPotential;


------------------------------------------------------------------
-- Function:    findDiluentPotential
-- Description: Returns the valid diluent potential
------------------------------------------------------------------
FUNCTION findDiluentPotential(
  p_object_id        well.object_id%TYPE,
    p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

   lv2_potential_method  VARCHAR2(30);

   ln_return_val         NUMBER;
   ln_poten_2nd_value    NUMBER;
   ln_poten_3rd_value    NUMBER;
   ln_test_pump_speed    NUMBER;
   ln_pump_speed_ratio   NUMBER;
   ln_on_strm_hrs        NUMBER;
   ln_day_frac           NUMBER;
   ln_prod_day_offset    NUMBER;
   ln_prev_test_no       NUMBER;
   ln_vol_rate           NUMBER;
   ln_oil_rate           NUMBER;
   ln_gas_rate           NUMBER;
   ln_gor                NUMBER;
   ln_wat_rate           NUMBER;
   ln_wat_oil_ratio      NUMBER;

   lr_pwel_result   PWEL_RESULT%ROWTYPE;
   lr_day_rec            PWEL_DAY_STATUS%ROWTYPE;
   lr_well_event_row     WELL_EVENT%ROWTYPE;
   lb_first              BOOLEAN;

   ld_start_daytime      DATE;
   ld_end_daytime        DATE;
   ld_eff_daytime        DATE;
   ld_next_eff_daytime   DATE;
   ld_prev_estimate      DATE;
   ld_next_estimate      DATE;
   ld_prev_test          DATE;
   ld_next_test          DATE;
   ln_fcst_scen_no       NUMBER;
   lv2_scenario_id        VARCHAR2(32);


BEGIN

   lv2_potential_method := Nvl(p_potential_method,ec_well_version.potential_method(
                       p_object_id,
                                      p_daytime,
                           '<='));

   IF (lv2_potential_method = EcDp_Calc_Method.CURVE) THEN

     ln_return_val := NULL;

   ELSIF (lv2_potential_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;

      lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, ld_start_daytime);
      ln_return_val := lr_pwel_result.DILUENT_RATE;


  ELSIF (lv2_potential_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_pwel_day_alloc.alloc_diluent_vol(p_object_id,p_daytime,lv2_scenario_id), ec_fcst_pwel_day.diluent_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

  ELSIF (lv2_potential_method = EcDp_Calc_Method.WELL_TEST_AND_ESTIMATE) THEN

     ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
     ld_start_daytime := p_daytime + ln_prod_day_offset;
     ld_end_daytime := ld_start_daytime + 1;
     lb_first := TRUE;
     ld_eff_daytime := ld_start_daytime; -- Internal date used to control how much of the day we have calculated so far
     ld_next_eff_daytime := ld_start_daytime;

     WHILE ld_next_eff_daytime < ld_end_daytime LOOP

        ld_prev_estimate := EcDp_Well_Event.getLastPwelEstimateDaytime(p_object_id,ld_eff_daytime);
        ld_next_estimate := EcDp_Well_Event.getNextPwelEstimateDaytime(p_object_id,ld_eff_daytime + 1/86400);

        ln_prev_test_no  := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id,ld_eff_daytime);
        ld_prev_test     := ec_ptst_result.valid_from_date(ln_prev_test_no);
        ld_next_test     := ec_ptst_result.valid_from_date(EcDp_Performance_Test.getNextValidWellResultNo(p_object_id,ld_eff_daytime + 1/86400));

        IF (ld_prev_test = NULL AND ld_prev_estimate = NULL) THEN -- No estimate/test available -> Must exit loop and return NULL
           ln_return_val := NULL;
           EXIT;
        ELSE
           ld_eff_daytime := GREATEST(Nvl(ld_prev_estimate,ld_prev_test),Nvl(ld_prev_test,ld_prev_estimate));
        END IF;

        IF ld_eff_daytime = ld_prev_test THEN -- Use well test for this period
           lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, ln_prev_test_no);
           ln_vol_rate := lr_pwel_result.diluent_rate;

        ELSE -- Use well production estimate for this period
           lr_well_event_row := ec_well_event.row_by_pk(p_object_id,'PWEL_ESTIMATE',ld_eff_daytime);
           ln_vol_rate := lr_well_event_row.diluent_rate;

        END IF;

        -- find start of next period
        ld_next_eff_daytime := LEAST(
                                     LEAST( Nvl(ld_next_estimate,ld_end_daytime), Nvl(ld_next_test,ld_end_daytime)),
                                    ld_end_daytime);

        -- find fraction of the day current production potential covers
        ln_day_frac  := (ld_next_eff_daytime - GREATEST(ld_eff_daytime,ld_start_daytime));

        IF lb_first THEN
          ln_return_val := ln_vol_rate * ln_day_frac;
          lb_first := FALSE;
        ELSE
          ln_return_val := nvl(ln_return_val,0) + (ln_vol_rate * ln_day_frac);
        END IF;

        ld_eff_daytime := ld_next_eff_daytime;

     END LOOP;

  ELSIF (substr(lv2_potential_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_return_val := Ue_Well_Potential.getDiluentPotential(
               p_object_id,
               p_daytime);

  ELSE -- undefined

     ln_return_val := NULL;

  END IF;

  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;


    RETURN ln_return_val;

END findDiluentPotential;


------------------------------------------------------------------
-- Function:    findOilMassProductionPotential
-- Description: Returns the valid oil mass production potential
------------------------------------------------------------------

FUNCTION findOilMassProdPotential (
  p_object_id        well.object_id%TYPE,
    p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

   lv2_potential_mass_method   VARCHAR2(30);
   ln_return_val               NUMBER;
   ln_prod_day_offset          NUMBER;
   lr_pwel_result   PWEL_RESULT%ROWTYPE;
   ld_start_daytime            DATE;
   ln_fcst_scen_no             NUMBER;
   lv2_scenario_id        VARCHAR2(32);
   ln_potential_volume         NUMBER;
   ln_well_oil_density         NUMBER;


BEGIN

   lv2_potential_mass_method := Nvl(p_potential_method,ec_well_version.potential_mass_method(p_object_id, p_daytime, '<='));


   IF (lv2_potential_mass_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

     ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
     ld_start_daytime := p_daytime + ln_prod_day_offset;

     ln_return_val := EcDp_Well_Estimate.getOilStdMassRate(p_object_id,ld_start_daytime);

   ELSIF (lv2_potential_mass_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_pwel_day_alloc.alloc_net_oil_mass(p_object_id,p_daytime,lv2_scenario_id), ec_fcst_pwel_day.net_oil_mass_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

   ELSIF (lv2_potential_mass_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
     ln_potential_volume := findOilProductionPotential(p_object_id, p_daytime);
     ln_well_oil_density := EcBp_Well_Theoretical.findOilStdDensity(p_object_id, p_daytime);
     ln_return_val := ln_potential_volume * ln_well_oil_density;


   ELSIF (substr(lv2_potential_mass_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_return_val := Ue_Well_Potential.getOilMassPotential(
               p_object_id,
               p_daytime);
   ELSE -- undefined

     ln_return_val := NULL;

  END IF;

  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;


   RETURN ln_return_val;


END findOilMassProdPotential;

------------------------------------------------------------------
-- Function:    findGasMassProdPotential
-- Description: Returns the valid gas mass production potential
------------------------------------------------------------------

FUNCTION findGasMassProdPotential (
  p_object_id        well.object_id%TYPE,
    p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

   lv2_potential_mass_method  VARCHAR2(30);
   ln_return_val         NUMBER;
   ln_prod_day_offset    NUMBER;
   lr_pwel_result   PWEL_RESULT%ROWTYPE;
   ld_start_daytime      DATE;
   ln_fcst_scen_no       NUMBER;
   lv2_scenario_id        VARCHAR2(32);
   ln_potential_volume   NUMBER;
   ln_well_gas_density   NUMBER;


BEGIN

   lv2_potential_mass_method := Nvl(p_potential_method,ec_well_version.potential_mass_method(p_object_id, p_daytime, '<='));


   IF (lv2_potential_mass_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

     ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
     ld_start_daytime := p_daytime + ln_prod_day_offset;

     ln_return_val := EcDp_Well_Estimate.getGasStdMassRate(p_object_id,ld_start_daytime);

   ELSIF (lv2_potential_mass_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_pwel_day_alloc.alloc_gas_mass(p_object_id,p_daytime,lv2_scenario_id), ec_fcst_pwel_day.gas_mass_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

   ELSIF (lv2_potential_mass_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
     ln_potential_volume := findGasProductionPotential(p_object_id, p_daytime);
     ln_well_gas_density := EcBp_Well_Theoretical.findGasStdDensity(p_object_id, p_daytime);
     ln_return_val := ln_potential_volume * ln_well_gas_density;

   ELSIF (substr(lv2_potential_mass_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_return_val := Ue_Well_Potential.getGasMassPotential(
               p_object_id,
               p_daytime);
   ELSE -- undefined

     ln_return_val := NULL;

  END IF;

  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;



   RETURN ln_return_val;


END findGasMassProdPotential;


------------------------------------------------------------------
-- Function:    findCondMassProdPotential
-- Description: Returns the valid cond mass production potential
------------------------------------------------------------------

FUNCTION findCondMassProdPotential (
  p_object_id        well.object_id%TYPE,
    p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

   lv2_potential_mass_method  VARCHAR2(30);
   ln_return_val         NUMBER;
   ln_prod_day_offset    NUMBER;
   lr_pwel_result   PWEL_RESULT%ROWTYPE;
   ld_start_daytime      DATE;
   ln_fcst_scen_no       NUMBER;
   lv2_scenario_id        VARCHAR2(32);
   ln_potential_volume   NUMBER;
   ln_well_oil_density   NUMBER;


BEGIN

   lv2_potential_mass_method := Nvl(p_potential_method,ec_well_version.potential_mass_method(p_object_id, p_daytime, '<='));

   IF (lv2_potential_mass_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

     ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
     ld_start_daytime := p_daytime + ln_prod_day_offset;

     ln_return_val := EcDp_Well_Estimate.getCondStdMassRate(p_object_id,ld_start_daytime);

   ELSIF (lv2_potential_mass_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_pwel_day_alloc.alloc_cond_mass(p_object_id,p_daytime,lv2_scenario_id), ec_fcst_pwel_day.cond_mass_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

   ELSIF (lv2_potential_mass_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
     ln_potential_volume := findConProductionPotential(p_object_id, p_daytime);
     ln_well_oil_density := EcBp_Well_Theoretical.findOilStdDensity(p_object_id, p_daytime);
     ln_return_val := ln_potential_volume * ln_well_oil_density;

   ELSIF (substr(lv2_potential_mass_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_return_val := Ue_Well_Potential.getCondMassPotential(
               p_object_id,
               p_daytime);
   ELSE -- undefined

     ln_return_val := NULL;

  END IF;

  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;



   RETURN ln_return_val;


END findCondMassProdPotential;


------------------------------------------------------------------
-- Function:    findWaterMassProdPotential
-- Description: Returns the valid water mass production potential
------------------------------------------------------------------

FUNCTION findWaterMassProdPotential (
  p_object_id        well.object_id%TYPE,
    p_daytime          DATE,
  p_potential_method VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

   lv2_potential_mass_method  VARCHAR2(30);
   ln_return_val         NUMBER;
   ln_prod_day_offset    NUMBER;
   lr_pwel_result   PWEL_RESULT%ROWTYPE;
   ld_start_daytime      DATE;
   ln_fcst_scen_no       NUMBER;
   lv2_scenario_id        VARCHAR2(32);
   ln_potential_volume   NUMBER;
   ln_well_wat_density   NUMBER;


BEGIN

   lv2_potential_mass_method := Nvl(p_potential_method,ec_well_version.potential_mass_method(p_object_id, p_daytime, '<='));


   IF (lv2_potential_mass_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

     ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id,p_daytime)/24;
     ld_start_daytime := p_daytime + ln_prod_day_offset;

     ln_return_val := EcDp_Well_Estimate.getWatStdMassRate(p_object_id,ld_start_daytime);

   ELSIF (lv2_potential_mass_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
    lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
    ln_return_val := NVL(ec_fcst_pwel_day_alloc.alloc_water_mass(p_object_id,p_daytime,lv2_scenario_id), ec_fcst_pwel_day.water_mass_rate(p_object_id,p_daytime,lv2_scenario_id,'<='));

   ELSIF (lv2_potential_mass_method = EcDp_Calc_Method.VOLUME_DENSITY) THEN
     ln_potential_volume := findWatProductionPotential(p_object_id, p_daytime);
     ln_well_wat_density := EcBp_Well_Theoretical.findWatStdDensity(p_object_id, p_daytime);
     ln_return_val := ln_potential_volume * ln_well_wat_density;

   ELSIF (substr(lv2_potential_mass_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_return_val := Ue_Well_Potential.getWaterMassPotential(
               p_object_id,
               p_daytime);
   ELSE -- undefined

     ln_return_val := NULL;

  END IF;

  IF (ec_ctrl_system_attribute.attribute_text(p_daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
    ln_return_val := ln_return_val/24 * Ecdp_Timestamp.getNumHours('WELL', p_object_id,p_daytime);
  END IF;


   RETURN ln_return_val;


END findWaterMassProdPotential;


------------------------------------------------------------------
-- Function:    calcDayWellProdDefermentVol
-- Description: Returns the valid well deferment production volume
------------------------------------------------------------------
FUNCTION calcDayWellProdDefermentVol (
  p_object_id  well.object_id%TYPE,
    p_daytime  DATE,
  p_phase    VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

ln_return_val   NUMBER;
ln_def_version  VARCHAR2(1000);

BEGIN

   ln_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');

   IF (ln_def_version = 'PD.0001') THEN
    ln_return_val := ecdp_objects_deferment_event.calcWellProdLossDay(p_object_id, p_daytime, p_phase);

   ELSIF (ln_def_version = 'PD.0020') THEN
     ln_return_val := ecbp_deferment.calcWellProdLossDay(p_object_id, p_daytime, p_phase);

   ELSE -- undefined
     ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;


END calcDayWellProdDefermentVol;

------------------------------------------------------------------
-- Function:    calcDayWellProdDefermentMass
-- Description: Returns the valid well deferment production mass
------------------------------------------------------------------
FUNCTION calcDayWellProdDefermentMass (
  p_object_id  well.object_id%TYPE,
    p_daytime  DATE,
  p_phase    VARCHAR2 DEFAULT NULL )

RETURN NUMBER IS

ln_return_val   NUMBER;
ln_def_version  VARCHAR2(1000);

BEGIN

   ln_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');

   IF (ln_def_version = 'PD.0001') THEN
    ln_return_val := ecdp_objects_deferment_event.calcWellProdLossDayMass(p_object_id, p_daytime, p_phase);

   ELSE -- undefined
     ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END calcDayWellProdDefermentMass;

------------------------------------------------------------------
-- Function:    findObjPlanMaxDaytime
-- Description: Returns the valid co2 injection potential
------------------------------------------------------------------
FUNCTION findObjPlanMaxDaytime (
  p_object_id        well.object_id%TYPE,
  p_daytime          DATE,
  p_class_name       VARCHAR2 )

RETURN DATE IS

ld_from_date         DATE;

CURSOR c_get_max_daytime (cp_object_id VARCHAR2, cp_daytime DATE, cp_class_name VARCHAR2) IS
SELECT a.daytime Max_daytime
FROM object_plan a
where a.class_name = cp_class_name
AND a.object_id = cp_object_id
AND a.daytime =
  (SELECT max(b.daytime)
   From object_plan b
   WHERE b.class_name = cp_class_name
   AND b.object_id = cp_object_id
   AND b.daytime <= cp_daytime);

BEGIN

  FOR curRec IN c_get_max_daytime(p_object_id, p_daytime, p_class_name) LOOP
    ld_from_date := curRec.Max_daytime;
  END LOOP;

  RETURN ld_from_date;

END findObjPlanMaxDaytime;

END EcBp_Well_Potential;