CREATE OR REPLACE PACKAGE BODY EcBp_Stream_Formula IS
/**************************************************************
** Package  :  ecbp_stream_formula, body part
**
** $Revision: 1.65.12.5 $
**
** Purpose  :  Package for evaluating generic methods used in
**                 stream formulas.
**
** General Logic:
**
** Modification history:
**
** Date:      Whom     Change description:
** ---------- -------- ---------------------------------------------
** 15.03.04   EOL      Created package
** 11.06.04   EOL      Added mass methods for Storage and Stream
** 03.08.2004 mazrina  removed sysnam and update as necessary
** 01.12.04   SHN      Added cursor to loop over a given period for storage objects.
** 28.01.2005 zalannur,
              idrussab Added 4 new methods for Storage (NET_VOL_SM3, GRS_VOL_SM3, NET_VOL_BBLS, GRS_VOL_BBLS)
** 31.01.2005 zalannur,
              idrussab Rename Storage method from (NET_VOL_SM3, GRS_VOL_SM3, NET_VOL_BBLS, GRS_VOL_BBLS) to (LIFTED_NET_VOL_SM3, LIFTED_GRS_VOL_SM3, LIFTED_NET_VOL_BBLS, LIFTED_GRS_VOL_BBLS)
** 04.08.2005 chongjer Added support for object class Tank, Facility Class 1, Well Hookup
** 06.08.2005 chongjer Updated codes for Facility Class 1 and Well Hookup
** 22.11.2005 chongjer Added support for object class Tank.
** 21.12.2005 bohhhron Added support for new method for object stream
** 29.12.2005 bohhhron Added support for new method for well hookup and facility
**                       TOTAL_THEOR_WELL_WAT_INJ
**                       TOTAL_THEOR_WELL_GAS_INJ
**                       TOTAL_THEOR_WELL_STEAM_INJ
**                       TOTAL_THEOR_WELL_GAS_LIFT_PROD
**                       TOTAL_THEOR_WELL_DILUENT_PROD
** 08.09.2006 vikaaroa Modified evaluateMethod to use ecbp_tank.findOpening/Closing# method within the section dealing with object_type = 'TANK'
** 29.09.2006 ottermag #4509: Added storage methods
** 09.01.2007 kaurrjes ECPD-4806: Added support for new method for storage
**                       LIFTED_GRS_VOL_SM3
**                       LIFTED_GRS_VOL_BBLS
**                       EXPORTED_DAY_GRS_BBLS
**                       EXPORTED_DAY_GRS_SM3
**                       EXPORTED_MTH_GRS_BBLS
**                       EXPORTED_MTH_GRS_SM3
** 23.08.2007 rajarsar ECPD-6246: Added support for new method Energy for stream
** 11.09.2007 idrussab ECPD-6295: Modified function evaluateMethod, add SALT_WT
** 03.03.2008 rajarsar ECPD-7127: Added function call to ecbp_stream_fluid.findPowerConsumption at evaluateMethod for stream objects
** 24.06.2008 aliassit ECPD-7988: Added support for stream method = REF_HOURLY_VOL_RATE and added new object type EQUIPMENT including methods for EQUIPMENT
** 12.08.2008 leeeewei ECPD-9343: Added new monthly allocation method for stream
** 26.08.2008 aliassit ECPD-9080: Added p_stream_id to some places in function evaluateMethod
** 04.09.2008 rajarsar ECPD-9038: Added support for new facility method = TOTAL_THEOR_WELL_CO2_PROD for FCTY_CLASS_1 in evaluateMethod
** 07.10.2008 embonhaf ECPD-10002 Fixed cursor c_eqpm_event_status not retrieving value when event day equals daytime.
** 17.10.2008 oonnnng  ECPD-8419: Added p_method = GCV for p_object_type = STREAM in evaluateMethod function.
** 22.10.2008 aliassit ECPD-8973: Added new methods for Storage: WAT_VOL_DAY_DIFF and WAT_VOL_MTH_DIFF
** 22.11.2008 oonnnng  ECPD-6067: Added local month lock checking in checkStrmFormulaLock function.
** 01.12.2008 leongsei ECPD-10290: Modified function evaluateMethod for new equipment method DAILY_NET_VOL_1, DAILY_NET_VOL_2, DAILY_NET_VOL_3, DAILY_NET_VOL_4,
**                                                                                           SUM_EVENT_VOL_1, SUM_EVENT_VOL_2, SUM_EVENT_VOL_3, SUM_EVENT_VOL_4,
**                                                                                           SUM_EVENT_RATE_1, SUM_EVENT_RATE_2, SUM_EVENT_RATE_3,
**                                                                                           SUM_EVENT_VALUE_1, SUM_EVENT_VALUE_2, SUM_EVENT_VALUE_3
** 05.12.2008 oonnnng  ECPD-10387: Amend p_object_type = 'WELL_HOOKUP' in evaluateMethod function, by add parameter p_steramId for calcWellHookupGasLiftDay, and calcWellHookupDiluentDay.
** 12.12.2008 oonnnng  ECPD-10330: Add nvl (function call,0) under p_object_type = 'STORAGE' in evaluateMethod function.
** 16.12.2008 oonnnng  ECPD-10317: Add new methods TOTAL_THEOR_WELL_OIL_MASS_PROD, TOTAL_THEOR_WELL_GAS_MASS_PROD, TOTAL_THEOR_WELL_WAT_MASS_PROD
**                     for p_object_type = FCTY_CLASS_1 and p_object_type = WELL_HOOKUP.
** 15.01.2009 aliassit ECPD-10563: Added new methods for FCTY_CLASS_1 and WELL_HOOKUP to handle sum theoretical calculation regardless allocation network
** 09.02.2009 farhaann ECPD-10761: Added support for new method for object stream
**                                  NET_DENS
**                                  WAT_MASS
** 17.02.2009 leongsei ECPD-6067: Modified function checkStrmFormulaLock for local lock
** 17.03.2009 rajarsar   ECPD-9038: Added support for new method for well hookup and facility
**                       TOTAL_THEOR_WELL_CO2_INJ
**                       TOTAL_THEOR_WELL_CO2_PROD
**                       SUM_OPER_WELL_CO2_PROD
**                       SUM_OPER_WELL_CO2_INJ
** 17.08.2009 oonnnng  ECPD-12535: Amended methods 'WAT_VOL_MTH_DIFF', 'WAT_VOL_DAY_DIFF' to 'WATER_VOL_MTH_DIFF', 'WATER_VOL_DAY_DIFF'.
** 18.09.2009 aliassit ECPD-12558: Added support for Well hookup and facility and field
**                       SUM_WELL_ALLOC_NET_OIL_VOL
**                     SUM_WELL_ALLOC_WAT_VOL
**                       SUM_WELL_ALLOC_GAS_VOL
**                       SUM_WELL_ALLOC_COND_VOL
**                       SUM_WELL_ALLOC_GL_VOL
**                       SUM_WELL_ALLOC_DILUENT_VOL
**                       SUM_WELL_ALLOC_CO2_VOL
**                       SUM_WELL_ALLOC_NET_OIL_MASS
**                       SUM_WELL_ALLOC_WAT_MASS
**                       SUM_WELL_ALLOC_GAS_MASS
**                       SUM_WELL_ALLOC_COND_MASS
**                       SUM_WELL_ALLOC_WAT_INJ_VOL
**                       SUM_WELL_ALLOC_GAS_INJ_VOL
**                       SUM_WELL_ALLOC_STEAM_INJ_VOL
**                       SUM_WELL_ALLOC_CO2_INJ_VOL
**                       SUM_WELL_ALLOC_WAT_INJ
**                       SUM_WELL_ALLOC_GAS_INJ
**                       SUM_WELL_ALLOC_STEAM_INJ
**                       SUM_WELL_ALLOC_CO2_INJ
** 08.03.2010 ismaiime ECPD-13611: Modified function evaluateMethod when calculating RUN_TIME on EQUIPMENT objects.
** 28.04.2010 farhaann ECPD-14069: Added REF_CGR method in evaluateMethod function.
** 06.05.2010 oonnnng  ECPD-14643: Amended the object_type = EQUIPMENT, and on_time_method = EQUIPMENT_DOWNTIME's logic in evaluateMethod() function.
** 23.07.2010 rajarsar ECPD-14387: Added ALLOC_ENERGY method for Stream in evaluateMethod function.
** 09.02.2011 farhaann ECPD-16651: Modified function evaluateMethod when calculating RUN_TIME on EQUIPMENT objects to handle daylight savings.
** 02.03.2011 syazwnur  ECPD-16737: Added new method TOTAL_THEOR_WELL_COND_MASS_PROD for p_object_type = WELL_HOOKUP.
** 09.05.2012 limmmchu ECPD-20889: Added new method FLWL_THEOR_WAT_INJ_VOL,FLWL_THEOR_GAS_INJ_VOL,'FLWL_THEOR_OIL_MASS,FLWL_THEOR_GAS_MASS,FLWL_THEOR_WATER_MASS,FLWL_THEOR_COND_MASS for p_object_type = FLOWLINE.
** 13.07.2012 musthram ECPD-21503: Added new method under Facility Objects - TOTAL_THEOR_WELL_COND_MASS_PROD and SUM_OPER_WELL_COND_MASS_PROD
** 01.11.2012 limmmchu ECPD-22065: Enhance evaluateMethod to support DILUENT_VOL_DAY_DIFF
** 21.03.2013 kumarsur ECPD-23650: Modified evaluateMethod().
** 29.11.2013 abdulmaw ECPD-26223: Modified evaluateMethod to handle monthly storage funtions.
**************************************************************/
---------------------------------------------------------------
--
-- Function name:
--              evaluateMethod
--
-- Purpose:
--              Function to parse methods described in <p_method>,
--              translate these into PLSQL package calls,
--              execute these and return the answer
--
-- Logic:
--              Provide a one to one mapping between defined methods
--              and PLSQL functions in packagelayer.
--
-- Supported object types:
--              STREAM       - Single stream
--              STORAGE      - Single storage
--              TANK         - Single tank
--    EQUIPMENT    - Single Equipment
--
-- Supported methods:
--              NET_VOL                        (STREAM)
--              ALLOC_NET_VOL                  (STREAM)
--              GRS_VOL                        (STREAM)
--              NET_MASS                       (STREAM)
--              ALLOC_NET_MASS                 (STREAM)
--              GRS_MASS                       (STREAM)
--              BS_W_VOL                       (STREAM)
--              BS_W_WT                        (STREAM)
--              COND_VOL                       (STREAM)
--              WAT_VOL                        (STREAM)
--              REF_HOURLY_VOL_RATE            (STREAM)
--              MTH_ALLOC_NET_VOL              (STREAM)
--              MTH_ALLOC_NET_MASS             (STREAM)
--              MTH_ALLOC_ENERGY               (STREAM)
--              NET_DENS                       (STREAM)
--              WAT_MASS                       (STREAM)
--              ALLOC_ENERGY                   (STREAM)
--
--              GRS_MASS_DAY_DIFF              (STORAGE)
--              GRS_MASS_MTH_DIFF              (STORAGE)
--              GRS_VOL_DAY_DIFF               (STORAGE)
--              GRS_VOL_MTH_DIFF               (STORAGE)
--              NET_MASS_DAY_DIFF              (STORAGE)
--              NET_MASS_MTH_DIFF              (STORAGE)
--              NET_VOL_DAY_DIFF               (STORAGE)
--              NET_VOL_MTH_DIFF               (STORAGE)
--              WAT_VOL_DAY_DIFF               (STORAGE)
--              WAT_VOL_MTH_DIFF               (STORAGE)

--              NET_VOL_DAY_CLOSING            (STORAGE)
--              GRS_VOL_DAY_CLOSING            (STORAGE)
--              NET_MASS_DAY_CLOSING           (STORAGE)
--              GRS_MASS_DAY_CLOSING           (STORAGE)
--              GRS_VOL_AVAILABLE              (STORAGE)

--              LIFTED_NET_VOL_SM3             (STORAGE)
--              LIFTED_NET_VOL_BBLS            (STORAGE)
--              LIFTED_GRS_VOL_SM3             (STORAGE)
--              LIFTED_GRS_VOL_BBLS            (STORAGE)
--
--              EXPORTED_DAY_NET_BBLS          (STORAGE)
--              EXPORTED_DAY_NET_SM3           (STORAGE)
--              EXPORTED_MTH_NET_BBLS          (STORAGE)
--              EXPORTED_MTH_NET_SM3           (STORAGE)
--              EXPORTED_DAY_GRS_BBLS          (STORAGE)
--              EXPORTED_DAY_GRS_SM3           (STORAGE)
--              EXPORTED_MTH_GRS_BBLS          (STORAGE)
--              EXPORTED_MTH_GRS_SM3           (STORAGE)
--
--              NET_VOL_DAY_OPENING            (TANK)
--              NET_VOL_DAY_CLOSING            (TANK)
--              GRS_VOL_DAY_OPENING            (TANK)
--              GRS_VOL_DAY_CLOSING            (TANK)
--              NET_MASS_DAY_OPENING           (TANK)
--              NET_MASS_DAY_CLOSING           (TANK)
--              GRS_MASS_DAY_OPENING           (TANK)
--              GRS_MASS_DAY_CLOSING           (TANK)
--              WAT_VOL_DAY_OPENING            (TANK)
--              WAT_VOL_DAY_CLOSING            (TANK)
--
--              TOTAL_THEOR_WELL_OIL_PROD      (FCTY_CLASS_1)
--              TOTAL_THEOR_WELL_GAS_PROD      (FCTY_CLASS_1)
--              TOTAL_THEOR_WELL_CO2_PROD      (FCTY_CLASS_1)
--              TOTAL_THEOR_WELL_WAT_PROD      (FCTY_CLASS_1)
--              TOTAL_THEOR_WELL_COND_PROD     (FCTY_CLASS_1)
--              TOTAL_THEOR_WELL_WAT_INJ       (FCTY_CLASS_1)
--              TOTAL_THEOR_WELL_GAS_INJ       (FCTY_CLASS_1)
--              TOTAL_THEOR_WELL_CO2_INJ       (FCTY_CLASS_1)
--              TOTAL_THEOR_WELL_STEAM_INJ     (FCTY_CLASS_1)
--              TOTAL_THEOR_WELL_GAS_LIFT_PROD (FCTY_CLASS_1)
--              TOTAL_THEOR_WELL_DILUENT_PROD  (FCTY_CLASS_1)
--              SUM_OPER_WELL_OIL_PROD         (FCTY_CLASS_1)
--              SUM_OPER_WELL_GAS_PROD      (FCTY_CLASS_1)
--              SUM_OPER_WELL_WAT_PROD      (FCTY_CLASS_1)
--              SUM_OPER_WELL_COND_PROD     (FCTY_CLASS_1)
--              SUM_OPER_WELL_WAT_INJ       (FCTY_CLASS_1)
--              SUM_OPER_WELL_GAS_INJ       (FCTY_CLASS_1)
--              SUM_OPER_WELL_STEAM_INJ     (FCTY_CLASS_1)
--              SUM_OPER_WELL_GAS_LIFT_PROD (FCTY_CLASS_1)
--              SUM_OPER_WELL_DILUENT_PROD  (FCTY_CLASS_1)
--              SUM_OPER_WELL_CO2_PROD      (FCTY_CLASS_1)
--              SUM_OPER_WELL_CO2_INJ       (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_NET_OIL_VOL  (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_WAT_VOL      (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_GAS_VOL      (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_COND_VOL     (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_GL_VOL        (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_DILUENT_VOL  (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_CO2_VOL      (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_NET_OIL_MASS  (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_WAT_MASS      (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_GAS_MASS      (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_COND_MASS    (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_WAT_INJ_VOL  (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_GAS_INJ_VOL  (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_STEAM_INJ_VOL  (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_CO2_INJ_VOL  (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_WAT_INJ      (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_GAS_INJ      (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_STEAM_INJ    (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_CO2_INJ      (FCTY_CLASS_1)
--
--              TOTAL_THEOR_WELL_OIL_PROD      (WELL_HOOKUP)
--              TOTAL_THEOR_WELL_GAS_PROD      (WELL_HOOKUP)
--              TOTAL_THEOR_WELL_WAT_PROD      (WELL_HOOKUP)
--              TOTAL_THEOR_WELL_COND_PROD     (WELL_HOOKUP)
--              TOTAL_THEOR_WELL_WAT_INJ       (WELL_HOOKUP)
--              TOTAL_THEOR_WELL_GAS_INJ       (WELL_HOOKUP)
--              TOTAL_THEOR_WELL_STEAM_INJ     (WELL_HOOKUP)
--              TOTAL_THEOR_WELL_GAS_LIFT_PROD (WELL_HOOKUP)
--              TOTAL_THEOR_WELL_DILUENT_PROD  (WELL_HOOKUP)
--              TOTAL_THEOR_WELL_CO2_PROD      (WELL_HOOKUP)
--              TOTAL_THEOR_WELL_CO2_INJ       (WELL_HOOKUP)
--              SUM_OPER_WELL_OIL_PROD      (WELL_HOOKUP)
--              SUM_OPER_WELL_GAS_PROD      (WELL_HOOKUP)
--              SUM_OPER_WELL_CO2_PROD      (WELL_HOOKUP)
--              SUM_OPER_WELL_WAT_PROD      (WELL_HOOKUP)
--              SUM_OPER_WELL_COND_PROD     (WELL_HOOKUP)
--              SUM_OPER_WELL_WAT_INJ       (WELL_HOOKUP)
--              SUM_OPER_WELL_GAS_INJ       (WELL_HOOKUP)
--              SUM_OPER_WELL_CO2_INJ       (WELL_HOOKUP)
--              SUM_OPER_WELL_STEAM_INJ     (WELL_HOOKUP)
--              SUM_OPER_WELL_GAS_LIFT_PROD (WELL_HOOKUP)
--              SUM_OPER_WELL_DILUENT_PROD  (WELL_HOOKUP)
--              SUM_WELL_ALLOC_NET_OIL_VOL  (WELL_HOOKUP)
--              SUM_WELL_ALLOC_WAT_VOL      (WELL_HOOKUP)
--              SUM_WELL_ALLOC_GAS_VOL      (WELL_HOOKUP)
--              SUM_WELL_ALLOC_COND_VOL     (WELL_HOOKUP)
--              SUM_WELL_ALLOC_GL_VOL        (WELL_HOOKUP)
--              SUM_WELL_ALLOC_DILUENT_VOL  (WELL_HOOKUP)
--              SUM_WELL_ALLOC_CO2_VOL      (WELL_HOOKUP)
--              SUM_WELL_ALLOC_NET_OIL_MASS  (WELL_HOOKUP)
--              SUM_WELL_ALLOC_WAT_MASS      (WELL_HOOKUP)
--              SUM_WELL_ALLOC_GAS_MASS      (WELL_HOOKUP)
--              SUM_WELL_ALLOC_COND_MASS    (WELL_HOOKUP)
--              SUM_WELL_ALLOC_WAT_INJ_VOL  (WELL_HOOKUP)
--              SUM_WELL_ALLOC_GAS_INJ_VOL  (WELL_HOOKUP)
--              SUM_WELL_ALLOC_STEAM_INJ_VOL  (WELL_HOOKUP)
--              SUM_WELL_ALLOC_CO2_INJ_VOL  (WELL_HOOKUP)
--              SUM_WELL_ALLOC_WAT_INJ      (FCTY_CLASS_1)
--              SUM_WELL_ALLOC_GAS_INJ      (WELL_HOOKUP)
--              SUM_WELL_ALLOC_STEAM_INJ    (WELL_HOOKUP)
--              SUM_WELL_ALLOC_CO2_INJ      (WELL_HOOKUP)
--
--              SUM_DAILY_NET_VOL              (EQUIPMENT)
--              SUM_EVENT_NET_VOL              (EQUIPMENT)
--              RUN_TIME                       (EQUIPMENT)
--              DAILY_NET_VOL_1                (EQUIPMENT)
--              DAILY_NET_VOL_2                (EQUIPMENT)
--              DAILY_NET_VOL_3                (EQUIPMENT)
--              DAILY_NET_VOL_4                (EQUIPMENT)
--              SUM_EVENT_VOL_1                (EQUIPMENT)
--              SUM_EVENT_VOL_2                (EQUIPMENT)
--              SUM_EVENT_VOL_3                (EQUIPMENT)
--              SUM_EVENT_VOL_4                (EQUIPMENT)
--              SUM_EVENT_RATE_1               (EQUIPMENT)
--              SUM_EVENT_RATE_2               (EQUIPMENT)
--              SUM_EVENT_RATE_3               (EQUIPMENT)
--              SUM_EVENT_VALUE_1              (EQUIPMENT)
--              SUM_EVENT_VALUE_2              (EQUIPMENT)
--              SUM_EVENT_VALUE_3              (EQUIPMENT)
--
--              FLWL_THEOR_OIL_VOL             (FLOWLINE)
--              FLWL_THEOR_GAS_VOL             (FLOWLINE)
--              FLWL_THEOR_WATER_VOL           (FLOWLINE)
--              FLWL_THEOR_COND_VOL            (FLOWLINE)
--              AVG_OIL_MASS                   (FLOWLINE)
--              AVG_GAS_MASS                   (FLOWLINE)
--              AVG_WATER_MASS                 (FLOWLINE)
--
-- Preconditions:
--              Codes (methods, object types) should be defined in PROSTY_CODES
--              The objects (stream, wells) has to be configured with attributes,
--              so that e.g net_vol_method, grs_vol_method, calc_method are defined.
--
--              Naming convention {'FCTY_GP', 'FCTY_OP', 'FCTY_WI', 'FCTY_GI'}
--
--              FCTY_GP = All wells of type GP for given facility
--              FCTY_OP = All wells of type OP for given facility
--              FCTY_GI = All wells of type GI for given facility
--              FCTY_WI = All wells of type WI for given facility
--------------------------------------------------------------

FUNCTION evaluateMethod(
      p_object_type VARCHAR2,
      p_object_id stream.object_id%TYPE,
      p_method  VARCHAR2,
      p_daytime DATE,
      p_to_date DATE DEFAULT NULL,
      p_stream_id VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

 ln_return_val NUMBER:=0;
 ln_downtime_hrs NUMBER:=0;
 ln_num_hours NUMBER;
 ld_daytime DATE;
 ln_prod_day_offset NUMBER;
 ld_first_day_of_month DATE;

 CURSOR c_days IS
  SELECT *
  FROM system_days
  WHERE daytime BETWEEN p_daytime AND Nvl(p_to_date,p_daytime);

 CURSOR c_well_equip_downtime(cp_daytime DATE) IS
  SELECT *
  FROM well_equip_downtime
  WHERE object_id = p_object_id
  AND (daytime < cp_daytime+1 AND (end_date > cp_daytime OR end_date IS NULL))
  ORDER BY daytime ASC;

 CURSOR c_eqpm_event_status(cp_daytime DATE) IS
  SELECT *
  FROM eqpm_event_status
  WHERE object_id = p_object_id
  AND event_day = cp_daytime;

 CURSOR c_strm_reference(cp_object_id VARCHAR2, cp_fromday DATE) IS
  SELECT *
  FROM strm_reference_value
  WHERE object_id = cp_object_id
  AND daytime <= cp_fromday;


BEGIN

  IF (substr(p_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_return_val := ue_stream_formula.evaluateMethod (
          p_object_type,
          p_object_id,
          p_method,
          p_daytime,
          p_to_date,
          p_stream_id);
  -- Stream objects

  ELSIF p_object_type IN ('STREAM') THEN

    IF p_method = 'NET_VOL' THEN
      ln_return_val := ecbp_stream_fluid.findNetStdVol(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'GRS_VOL' THEN
      ln_return_val := ecbp_stream_fluid.findGrsStdVol(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'NET_MASS' THEN
      ln_return_val := ecbp_stream_fluid.findNetStdMass(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'GRS_MASS' THEN
      ln_return_val := ecbp_stream_fluid.findGrsStdMass(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'WAT_VOL' THEN
      ln_return_val := ecbp_stream_fluid.findWatVol(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'COND_VOL' THEN
      ln_return_val := ecbp_stream_fluid.findCondVol(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'BS_W_VOL' THEN
      ln_return_val := ecbp_stream_fluid.getBswVolFrac(p_object_id,p_daytime);

    ELSIF p_method = 'BS_W_WT' THEN
      ln_return_val := ecbp_stream_fluid.getBswWeightFrac(p_object_id,p_daytime);

    ELSIF p_method = 'SALT_WT' THEN
      ln_return_val := ecbp_stream_fluid.getSaltWeightFrac(p_object_id,p_daytime);

    ELSIF p_method = 'ALLOC_NET_VOL' THEN
      ln_return_val := ec_strm_day_alloc.math_net_vol(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'ALLOC_NET_MASS' THEN
      ln_return_val := ec_strm_day_alloc.math_net_mass(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'ENERGY' THEN
      ln_return_val := ecbp_stream_fluid.findEnergy(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'POWER_CONSUMPTION' THEN
      ln_return_val := ecbp_stream_fluid.findPowerConsumption(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'REF_GOR' THEN
      ln_return_val := ec_strm_reference_value.gor(p_object_id,p_daytime,'<=');

    ELSIF p_method = 'REF_CGR' THEN
      ln_return_val := ec_strm_reference_value.cgr(p_object_id,p_daytime,'<=');

    ELSIF p_method = 'REF_HOURLY_VOL_RATE' THEN
      FOR cur_strm_reference IN c_strm_reference(p_object_id, p_daytime) LOOP
        IF ec_strm_reference_value.rate_uom(cur_strm_reference.object_id, cur_strm_reference.daytime, '<=') = 'HOURLY' THEN
          ln_return_val := ec_strm_reference_value.rate(cur_strm_reference.object_id, cur_strm_reference.daytime, '<=');
        END IF;
      END LOOP;

    ELSIF p_method = 'MTH_ALLOC_NET_VOL' THEN
      ld_first_day_of_month := TRUNC(TO_DATE(p_daytime),'MONTH');
      IF (p_daytime = ld_first_day_of_month) THEN
        ln_return_val := ec_strm_mth_alloc.net_vol(p_object_id,p_daytime);
      ELSE
        ln_return_val := NULL;
      END IF;

    ELSIF p_method = 'MTH_ALLOC_NET_MASS' THEN
      ld_first_day_of_month := TRUNC(TO_DATE(p_daytime),'MONTH');
      IF (p_daytime = ld_first_day_of_month) THEN
        ln_return_val := ec_strm_mth_alloc.net_mass(p_object_id,p_daytime);
      ELSE
        ln_return_val := NULL;
      END IF;

    ELSIF p_method = 'MTH_ALLOC_ENERGY' THEN
      ld_first_day_of_month := TRUNC(TO_DATE(p_daytime),'MONTH');
      IF (p_daytime = ld_first_day_of_month) THEN
        ln_return_val := ec_strm_mth_alloc.alloc_energy(p_object_id,p_daytime);
      ELSE
        ln_return_val := NULL;
      END IF;

    ELSIF p_method = 'GCV' THEN
      ln_return_val := ecbp_stream_fluid.findGCV(p_object_id,p_daytime);

    ELSIF p_method = 'NET_DENS' THEN
      ln_return_val := ecbp_stream_fluid.findStdDens(p_object_id,p_daytime);

    ELSIF p_method = 'WAT_MASS' THEN
      ln_return_val := ecbp_stream_fluid.findWatMass(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'ALLOC_ENERGY' THEN
      ln_return_val := ec_strm_day_alloc.math_alloc_energy(p_object_id,p_daytime,p_to_date);

    ELSIF p_method = 'DILUENT_VOL' THEN
      ln_return_val := ecbp_stream_fluid.calcDiluentVol(p_object_id,p_daytime,p_to_date);

    ELSE -- Unsupported method
      RAISE_APPLICATION_ERROR(-20000, 'Unsupported method: ' || p_method);
      -- ln_return_val := NULL;

    END IF;

  -- Storage objects
  ELSIF p_object_type = 'STORAGE' THEN

    FOR curDay IN c_days LOOP

      IF p_method = 'NET_VOL_DAY_DIFF' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.findStorageNetDayDiff(
                                                                      p_object_id,
                                                                      curDay.daytime);

	  ELSIF p_method = 'DILUENT_VOL_DAY_DIFF' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.findStorageDiluentDayDiff(
                                                                      p_object_id,
                                                                      curDay.daytime);

      ELSIF p_method = 'GRS_VOL_DAY_DIFF' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.findStorageGrsDayDiff(
                                                                      p_object_id,
                                                                      curDay.daytime);

      ELSIF p_method = 'NET_MASS_DAY_DIFF' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.findStorageNetMassDayDiff(
                                                                      p_object_id,
                                                                      curDay.daytime);
      ELSIF p_method = 'GRS_MASS_DAY_DIFF' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.findStorageGrsMassDayDiff(
                                                                      p_object_id,
                                                                      curDay.daytime);
      ELSIF p_method = 'NET_VOL_MTH_DIFF' THEN
        IF (curDay.daytime = LAST_DAY(curDay.daytime)) THEN
		  ln_return_val := ecbp_storage_measurement.findStorageNetMthDiff(
                                                                      p_object_id,
                                                                      curDay.daytime);
		ELSE
          ln_return_val := NULL;
        END IF;
      ELSIF p_method = 'GRS_VOL_MTH_DIFF' THEN
	    IF (curDay.daytime = LAST_DAY(curDay.daytime)) THEN
          ln_return_val := ecbp_storage_measurement.findStorageGrsMthDiff(
                                                                      p_object_id,
                                                                      curDay.daytime);
		ELSE
          ln_return_val := NULL;
        END IF;
      ELSIF p_method = 'NET_MASS_MTH_DIFF' THEN
	    IF (curDay.daytime = LAST_DAY(curDay.daytime)) THEN
          ln_return_val := ecbp_storage_measurement.findStorageNetMassMthDiff(
                                                                      p_object_id,
                                                                      curDay.daytime);
		ELSE
          ln_return_val := NULL;
        END IF;
      ELSIF p_method = 'GRS_MASS_MTH_DIFF' THEN
	    IF (curDay.daytime = LAST_DAY(curDay.daytime)) THEN
          ln_return_val := ecbp_storage_measurement.findStorageGrsMassMthDiff(
                                                                      p_object_id,
                                                                      curDay.daytime);
		ELSE
          ln_return_val := NULL;
        END IF;
      ELSIF p_method = 'LIFTED_NET_VOL_SM3' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findStorageLiftedNetVolSm3(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'LIFTED_NET_VOL_BBLS' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findStorageLiftedNetVolBbls(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'LIFTED_GRS_VOL_SM3' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findStorageLiftedGrsVolSm3(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'LIFTED_GRS_VOL_BBLS' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findStorageLiftedGrsVolBbls(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'EXPORTED_DAY_NET_BBLS' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findExpNotLiftedDayNetBbls(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'EXPORTED_DAY_NET_SM3' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findExpNotLiftedDayNetSm3(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'EXPORTED_MTH_NET_BBLS' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findExpNotLiftedMthNetBbls(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'EXPORTED_MTH_NET_SM3' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findExpNotLiftedMthNetSm3(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'EXPORTED_DAY_GRS_BBLS' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findExpNotLiftedDayGrsBbls(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'EXPORTED_DAY_GRS_SM3' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findExpNotLiftedDayGrsSm3(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'EXPORTED_MTH_GRS_BBLS' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findExpNotLiftedMthGrsBbls(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'EXPORTED_MTH_GRS_SM3' THEN
        ln_return_val := ln_return_val + nvl(ecbp_storage_measurement.findExpNotLiftedMthGrsSm3(
                                                                      p_object_id,
                                                                      curDay.daytime),0);
      ELSIF p_method = 'NET_VOL_DAY_CLOSING' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.getStorageDayClosingNetVol(p_object_id,curDay.daytime);

      ELSIF p_method = 'GRS_VOL_DAY_CLOSING' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.getStorageDayGrsClosingVol(p_object_id,curDay.daytime);

      ELSIF p_method = 'NET_MASS_DAY_CLOSING' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.getStorageDayClosingNetMass(p_object_id,curDay.daytime);

      ELSIF p_method = 'GRS_MASS_DAY_CLOSING' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.getStorageDayGrsClosingMass(p_object_id,curDay.daytime);

      ELSIF p_method = 'GRS_VOL_AVAILABLE' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.findStorageTotalVolume(p_object_id,curDay.daytime);

      ELSIF p_method = 'ENERGY_CLOSING' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.getStorageDayClosingEnergy(p_object_id,curDay.daytime);

      ELSIF p_method = 'ENERGY_DAY_DIFF' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.findStorageEnergyDayDiff(
                                                                    p_object_id,
                                                                    curDay.daytime);

      ELSIF p_method = 'ENERGY_MTH_DIFF' THEN
	    IF (curDay.daytime = LAST_DAY(curDay.daytime)) THEN
		  ln_return_val := ecbp_storage_measurement.findStorageEnergyMthDiff(
                                                                    p_object_id,
                                                                    curDay.daytime);
		ELSE
          ln_return_val := NULL;
        END IF;
      ELSIF p_method = 'WATER_VOL_DAY_DIFF' THEN
        ln_return_val := ln_return_val + ecbp_storage_measurement.findStorageWatDayDiff(
                                                                    p_object_id,
                                                                    curDay.daytime);

      ELSIF p_method = 'WATER_VOL_MTH_DIFF' THEN
	    IF (curDay.daytime = LAST_DAY(curDay.daytime)) THEN
          ln_return_val := ecbp_storage_measurement.findStorageWatMthDiff(
                                                                    p_object_id,
                                                                    curDay.daytime);
		ELSE
          ln_return_val := NULL;
        END IF;
      ELSE -- Unsupported method
        RAISE_APPLICATION_ERROR(-20000, 'Unsupported method: ' || p_method);
        --ln_return_val := NULL;

      END IF;

    END LOOP;

  -- Tank objects
  ELSIF p_object_type = 'TANK' THEN

    IF p_method = 'NET_VOL_DAY_OPENING' THEN
      ln_return_val := ecbp_tank.findOpeningNetVol(p_object_id,'DAY_CLOSING',p_daytime);

    ELSIF p_method = 'NET_VOL_DAY_CLOSING' THEN
      ln_return_val := ecbp_tank.findClosingNetVol(p_object_id,'DAY_CLOSING',p_daytime);

    ELSIF p_method = 'GRS_VOL_DAY_OPENING' THEN
      ln_return_val := ecbp_tank.findOpeningGrsVol(p_object_id,'DAY_CLOSING',p_daytime);

    ELSIF p_method = 'GRS_VOL_DAY_CLOSING' THEN
      ln_return_val := ecbp_tank.findClosingGrsVol(p_object_id,'DAY_CLOSING',p_daytime);

    ELSIF p_method = 'NET_MASS_DAY_OPENING' THEN
      ln_return_val := ecbp_tank.findOpeningNetMass(p_object_id,'DAY_CLOSING',p_daytime);

    ELSIF p_method = 'NET_MASS_DAY_CLOSING' THEN
      ln_return_val := ecbp_tank.findClosingNetMass(p_object_id,'DAY_CLOSING',p_daytime);

    ELSIF p_method = 'GRS_MASS_DAY_OPENING' THEN
      ln_return_val := ecbp_tank.findOpeningGrsMass(p_object_id,'DAY_CLOSING',p_daytime);

    ELSIF p_method = 'GRS_MASS_DAY_CLOSING' THEN
      ln_return_val := ecbp_tank.findClosingGrsMass(p_object_id,'DAY_CLOSING',p_daytime);

    ELSIF p_method = 'WAT_VOL_DAY_OPENING' THEN
      ln_return_val := ecbp_tank.findOpeningWatVol(p_object_id,'DAY_CLOSING',p_daytime);

    ELSIF p_method = 'WAT_VOL_DAY_CLOSING' THEN
      ln_return_val := ecbp_tank.findClosingWatVol(p_object_id,'DAY_CLOSING',p_daytime);

    ELSIF p_method = 'ENERGY_OPENING' THEN
      ln_return_val := ecbp_tank.findOpeningEnergy(p_object_id,'DAY_CLOSING',p_daytime);

    ELSIF p_method = 'ENERGY_CLOSING' THEN
      ln_return_val := ecbp_tank.findClosingEnergy(p_object_id,'DAY_CLOSING',p_daytime);

    ELSE -- Unsupported method
      RAISE_APPLICATION_ERROR(-20000, 'Unsupported method: ' || p_method);
      -- ln_return_val := NULL;

    END IF;

  -- Facility objects
  ELSIF p_object_type = 'FCTY_CLASS_1' THEN
    FOR curDay IN c_days LOOP
      IF p_method = 'TOTAL_THEOR_WELL_OIL_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityOilDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_GAS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityGasDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_WAT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityWatDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_COND_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityCondDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_WAT_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityWatInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_GAS_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityGasInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_STEAM_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilitySteamInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_GAS_LIFT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityGasLiftDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_DILUENT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityDiluentDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_CO2_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityCO2Day(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_CO2_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityCO2InjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_OIL_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityOilMassDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_GAS_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityGasMassDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_WAT_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityWatMassDay(p_object_id, curDay.daytime),0);

	  ELSIF p_method = 'TOTAL_THEOR_WELL_COND_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcFacilityCondMassDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_OIL_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityOilDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_GAS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityGasDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_WAT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityWatDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_COND_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityCondDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_WAT_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityWatInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_GAS_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityGasInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_STEAM_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilitySteamInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_GAS_LIFT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityGasLiftDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_DILUENT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityDiluentDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_CO2_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityCO2Day(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_CO2_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityCO2InjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_OIL_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityOilMassDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_GAS_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityGasMassDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_WAT_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityWatMassDay(p_object_id, curDay.daytime),0);

	  ELSIF p_method = 'SUM_OPER_WELL_COND_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Facility_Theoretical.calcSumOperFacilityCondMassDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_WELL_ALLOC_NET_OIL_VOL' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocProdVolume(p_object_id, 'NET_OIL_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_VOL' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocProdVolume(p_object_id, 'WAT_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_VOL' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocProdVolume(p_object_id, 'GAS_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_COND_VOL' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocProdVolume(p_object_id, 'COND_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GL_VOL' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocProdVolume(p_object_id, 'GL_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_DILUENT_VOL' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocProdVolume(p_object_id, 'DILUENT_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_CO2_VOL' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocProdVolume(p_object_id, 'CO2_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_NET_OIL_MASS' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocProdMass(p_object_id, 'NET_OIL_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_MASS' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocProdMass(p_object_id, 'WAT_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_MASS' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocProdMass(p_object_id, 'GAS_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_COND_MASS' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocProdMass(p_object_id, 'COND_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocInjVolume(p_object_id, 'WI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocInjVolume(p_object_id, 'GI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_STEAM_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocInjVolume(p_object_id, 'SI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_CO2_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocInjVolume(p_object_id, 'CI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_INJ' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocInjMass(p_object_id, 'WI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_INJ' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocInjMass(p_object_id, 'GI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_STEAM_INJ' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocInjMass(p_object_id, 'SI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_CO2_INJ' THEN
        ln_return_val := NVL(ecdp_facility_allocated.sumFctyAllocInjMass(p_object_id, 'CI', curDay.daytime), 0);



      ELSE -- Unsupported method
        RAISE_APPLICATION_ERROR(-20000, 'Unsupported method: ' || p_method);
        ln_return_val := NULL;

      END IF;

    END LOOP;

  -- Well Hookup objects
  ELSIF p_object_type = 'WELL_HOOKUP' THEN
    FOR curDay IN c_days LOOP
      IF p_method = 'TOTAL_THEOR_WELL_OIL_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupOilDay(p_object_id, curDay.daytime, p_stream_id),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_GAS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupGasDay(p_object_id, curDay.daytime, p_stream_id),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_WAT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupWatDay(p_object_id, curDay.daytime, p_stream_id),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_COND_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupCondDay(p_object_id, curDay.daytime, p_stream_id),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_WAT_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupWatInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_GAS_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupGasInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_STEAM_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupSteamInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_GAS_LIFT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupGasLiftDay(p_object_id, curDay.daytime, p_stream_id),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_DILUENT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupDiluentDay(p_object_id, curDay.daytime, p_stream_id),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_OIL_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupOilMassDay(p_object_id, curDay.daytime, p_stream_id),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_GAS_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupGasMassDay(p_object_id, curDay.daytime, p_stream_id),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_WAT_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupWatMassDay(p_object_id, curDay.daytime, p_stream_id),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_COND_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupCondMassDay(p_object_id, curDay.daytime, p_stream_id),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_CO2_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupCO2Day(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'TOTAL_THEOR_WELL_CO2_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcWellHookupCO2InjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_OIL_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookOilDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_GAS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookGasDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_WAT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookWatDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_COND_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookCondDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_WAT_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookWatInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_GAS_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookGasInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_STEAM_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookSteamInjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_GAS_LIFT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookGasLiftDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_DILUENT_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookDiluentDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_CO2_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookCO2Day(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_CO2_INJ' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookCO2InjDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_OIL_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookOilMassDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_GAS_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookGasMassDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_OPER_WELL_WAT_MASS_PROD' THEN
        ln_return_val := ln_return_val + NVL(ecbp_Well_Hookup_Theoretical.calcSumOperWellHookWatMassDay(p_object_id, curDay.daytime),0);

      ELSIF p_method = 'SUM_WELL_ALLOC_NET_OIL_VOL' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocProdVolume(p_object_id, 'NET_OIL_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_VOL' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocProdVolume(p_object_id, 'WAT_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_VOL' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocProdVolume(p_object_id, 'GAS_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_COND_VOL' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocProdVolume(p_object_id, 'COND_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GL_VOL' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocProdVolume(p_object_id, 'GL_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_DILUENT_VOL' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocProdVolume(p_object_id, 'DILUENT_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_CO2_VOL' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocProdVolume(p_object_id, 'CO2_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_NET_OIL_MASS' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocProdMass(p_object_id, 'NET_OIL_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_MASS' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocProdMass(p_object_id, 'WAT_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_MASS' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocProdMass(p_object_id, 'GAS_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_COND_MASS' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocProdMass(p_object_id, 'COND_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocInjVolume(p_object_id, 'WI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocInjVolume(p_object_id, 'GI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_STEAM_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocInjVolume(p_object_id, 'SI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_CO2_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocInjVolume(p_object_id, 'CI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_INJ' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocInjMass(p_object_id, 'WI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_INJ' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocInjMass(p_object_id, 'GI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_STEAM_INJ' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocInjMass(p_object_id, 'SI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_CO2_INJ' THEN
        ln_return_val := NVL(ecdp_well_hookup_alloc.sumWellHookAllocInjMass(p_object_id, 'CI', curDay.daytime), 0);



      ELSE -- Unsupported method
         RAISE_APPLICATION_ERROR(-20000, 'Unsupported method: ' || p_method);
         ln_return_val := NULL;

      END IF;

    END LOOP;

  -- Field objects
  ELSIF p_object_type = 'FIELD' THEN
    FOR curDay IN c_days LOOP
     IF p_method = 'SUM_WELL_ALLOC_NET_OIL_VOL' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocProdVolume(p_object_id, 'NET_OIL_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_VOL' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocProdVolume(p_object_id, 'WAT_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_VOL' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocProdVolume(p_object_id, 'GAS_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_COND_VOL' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocProdVolume(p_object_id, 'COND_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GL_VOL' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocProdVolume(p_object_id, 'GL_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_DILUENT_VOL' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocProdVolume(p_object_id, 'DILUENT_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_CO2_VOL' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocProdVolume(p_object_id, 'CO2_VOL', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_NET_OIL_MASS' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocProdMass(p_object_id, 'NET_OIL_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_MASS' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocProdMass(p_object_id, 'WAT_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_MASS' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocProdMass(p_object_id, 'GAS_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_COND_MASS' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocProdMass(p_object_id, 'COND_MASS', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocInjVolume(p_object_id, 'WI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocInjVolume(p_object_id, 'GI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_STEAM_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocInjVolume(p_object_id, 'SI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_CO2_INJ_VOL' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocInjVolume(p_object_id, 'CI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_WAT_INJ' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocInjMass(p_object_id, 'WI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_GAS_INJ' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocInjMass(p_object_id, 'GI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_STEAM_INJ' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocInjMass(p_object_id, 'SI', curDay.daytime), 0);

      ELSIF p_method = 'SUM_WELL_ALLOC_CO2_INJ' THEN
        ln_return_val := NVL(ecdp_field_alloc.sumFieldAllocInjMass(p_object_id, 'CI', curDay.daytime), 0);



      ELSE -- Unsupported method
         RAISE_APPLICATION_ERROR(-20000, 'Unsupported method: ' || p_method);
         ln_return_val := NULL;

      END IF;

    END LOOP;

  -- Flowline objects
  ELSIF p_object_type = 'FLOWLINE' THEN
    IF p_method = 'FLWL_THEOR_OIL_VOL' THEN
      ln_return_val := EcBp_Flowline_Theoretical.getOilStdRateDay(p_object_id, p_daytime);

    ELSIF p_method = 'FLWL_THEOR_GAS_VOL' THEN
      ln_return_val := EcBp_Flowline_Theoretical.getGasStdRateDay(p_object_id, p_daytime);

    ELSIF p_method = 'FLWL_THEOR_WATER_VOL' THEN
      ln_return_val := EcBp_Flowline_Theoretical.getWatStdRateDay(p_object_id, p_daytime);

    ELSIF p_method = 'FLWL_THEOR_COND_VOL' THEN
      ln_return_val := EcBp_Flowline_Theoretical.getCondStdRateDay(p_object_id, p_daytime);

	ELSIF p_method = 'FLWL_THEOR_WAT_INJ_VOL' THEN
      ln_return_val := EcBp_Flowline_Theoretical.getInjectedStdRateDay(p_object_id, 'WI', p_daytime);

	ELSIF p_method = 'FLWL_THEOR_GAS_INJ_VOL' THEN
	  ln_return_val := EcBp_Flowline_Theoretical.getInjectedStdRateDay(p_object_id, 'GI', p_daytime);

	ELSIF p_method = 'FLWL_THEOR_OIL_MASS' THEN
	  ln_return_val := EcBp_Flowline_Theoretical.findOilMassDay(p_object_id, p_daytime);

    ELSIF p_method = 'FLWL_THEOR_GAS_MASS' THEN
      ln_return_val := EcBp_Flowline_Theoretical.findGasMassDay(p_object_id, p_daytime);

    ELSIF p_method = 'FLWL_THEOR_WATER_MASS' THEN
      ln_return_val := EcBp_Flowline_Theoretical.findWaterMassDay(p_object_id, p_daytime);

    ELSIF p_method = 'FLWL_THEOR_COND_MASS' THEN
      ln_return_val := EcBp_Flowline_Theoretical.findCondMassDay(p_object_id, p_daytime);

    ELSIF p_method = 'AVG_OIL_MASS' THEN
      ln_return_val := ec_pflw_day_status.math_avg_oil_mass(p_object_id, p_daytime,p_to_date);

    ELSIF p_method = 'AVG_GAS_MASS' THEN
      ln_return_val := ec_pflw_day_status.math_avg_gas_mass(p_object_id, p_daytime,p_to_date);

    ELSIF p_method = 'AVG_WATER_MASS' THEN
      ln_return_val := ec_pflw_day_status.math_avg_water_mass(p_object_id, p_daytime,p_to_date);

    ELSE -- Unsupported method
      RAISE_APPLICATION_ERROR(-20000, 'Unsupported method: ' || p_method);
      ln_return_val := NULL;

    END IF;

  -- Equipment Objects
  ELSIF p_object_type = 'EQUIPMENT' THEN
    IF p_method = 'SUM_DAILY_NET_VOL' THEN
      ln_return_val := NVL(ec_eqpm_day_status.vol_1(p_object_id, p_daytime),0) + NVL(ec_eqpm_day_status.vol_2(p_object_id, p_daytime),0) + NVL(ec_eqpm_day_status.vol_3(p_object_id, p_daytime),0) + NVL(ec_eqpm_day_status.vol_4(p_object_id, p_daytime),0);

    ELSIF p_method = 'SUM_EVENT_NET_VOL' THEN
      FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
        ln_return_val := NVL(curEvent.vol_1,0) + NVL(curEvent.vol_2,0) + NVL(curEvent.vol_3,0) + NVL(curEvent.vol_4,0);
      END LOOP;

    ELSIF p_method = 'RUN_TIME' THEN
      IF ec_eqpm_version.on_time_method(p_object_id,p_daytime,'<=') = 'MEAS_DAILY_EQUIP' THEN
        ln_return_val := ec_eqpm_day_status.on_stream_hrs(p_object_id, p_daytime);

      ELSIF ec_eqpm_version.on_time_method(p_object_id,p_daytime,'<=') = 'MEAS_EVENT_EQUIP' THEN
        IF ec_eqpm_version.eqpm_data_freq(p_object_id, p_daytime,'<=') = 'DAY' THEN
          FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
           ln_return_val := curEvent.on_strm_hrs;

          END LOOP;
        END IF;

      ELSIF ec_eqpm_version.on_time_method(p_object_id,p_daytime,'<=') = 'EQUIP_DOWNTIME' THEN
        ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('EQUIPMENT',p_object_id,p_daytime)/24);
        ld_daytime := p_daytime + ln_prod_day_offset;
        ln_return_val := ecdp_date_time.getNumHours('EQUIPMENT',p_object_id, p_daytime);

        FOR curDowntime IN c_well_equip_downtime(ld_daytime) LOOP
          ln_num_hours := ecdp_date_time.getNumHours('EQUIPMENT',p_object_id, p_daytime);
		  ln_downtime_hrs := (least(nvl(curDowntime.end_date, ld_daytime+1), ld_daytime+1) - greatest(curDowntime.daytime, ld_daytime)) * ln_num_hours;
          ln_return_val := ln_return_val - ln_downtime_hrs;

        END LOOP;
      END IF;

    ELSIF p_method = 'DAILY_NET_VOL_1' THEN
      ln_return_val := ec_eqpm_day_status.vol_1(p_object_id, p_daytime);

    ELSIF p_method = 'DAILY_NET_VOL_2' THEN
      ln_return_val := ec_eqpm_day_status.vol_2(p_object_id, p_daytime);

    ELSIF p_method = 'DAILY_NET_VOL_3' THEN
      ln_return_val := ec_eqpm_day_status.vol_3(p_object_id, p_daytime);

    ELSIF p_method = 'DAILY_NET_VOL_4' THEN
      ln_return_val := ec_eqpm_day_status.vol_4(p_object_id, p_daytime);

    ELSIF p_method = 'SUM_EVENT_VOL_1' THEN
      FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
         ln_return_val := ln_return_val + NVL(curEvent.vol_1,0);
      END LOOP;

    ELSIF p_method = 'SUM_EVENT_VOL_2' THEN
      FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
         ln_return_val := ln_return_val + NVL(curEvent.vol_2,0);
      END LOOP;

    ELSIF p_method = 'SUM_EVENT_VOL_3' THEN
      FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
         ln_return_val := ln_return_val + NVL(curEvent.vol_3,0);
      END LOOP;

    ELSIF p_method = 'SUM_EVENT_VOL_4' THEN
      FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
         ln_return_val := ln_return_val + NVL(curEvent.vol_4,0);
      END LOOP;

    ELSIF p_method = 'SUM_EVENT_RATE_1' THEN
      FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
         ln_return_val := ln_return_val + NVL(curEvent.rate_1,0);
      END LOOP;

    ELSIF p_method = 'SUM_EVENT_RATE_2' THEN
      FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
         ln_return_val := ln_return_val + NVL(curEvent.rate_2,0);
      END LOOP;

    ELSIF p_method = 'SUM_EVENT_RATE_3' THEN
      FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
         ln_return_val := ln_return_val + NVL(curEvent.rate_3,0);
      END LOOP;

    ELSIF p_method = 'SUM_EVENT_VALUE_1' THEN
      FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
         ln_return_val := ln_return_val + NVL(curEvent.value_1,0);
      END LOOP;

    ELSIF p_method = 'SUM_EVENT_VALUE_2' THEN
      FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
         ln_return_val := ln_return_val + NVL(curEvent.value_2,0);
      END LOOP;

    ELSIF p_method = 'SUM_EVENT_VALUE_3' THEN
      FOR curEvent IN c_eqpm_event_status (p_daytime) LOOP
         ln_return_val := ln_return_val + NVL(curEvent.value_3,0);
      END LOOP;

    ELSE -- Unsupported method
      RAISE_APPLICATION_ERROR(-20000, 'Unsupported method: ' || p_method);
      ln_return_val := NULL;

    END IF;

  ELSE -- Unsupported object type
    ln_return_val := NULL;

  END IF;

  -- return value
  RETURN ln_return_val;

-- End function
END evaluateMethod;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkStrmFormulaLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated stream formula record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Stream_Formula.getNextFormula,
--                  EcDp_Stream_Formula.getPreviousFormula,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkStrmFormulaLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

  ld_new_current_valid DATE;
  ld_old_current_valid DATE;
  ld_new_next_valid DATE;
  ld_old_next_valid DATE;
  ld_old_prev_valid DATE;

  ld_locked_month DATE;
  lv2_id VARCHAR2(2000);
  lr_strm_formula strm_formula%ROWTYPE;
  lv2_columns_updated VARCHAR2(1);

  lv2_o_obj_id                  VARCHAR2(32);
  lv2_n_obj_id                  VARCHAR2(32);
  lv2_parent_object_id          VARCHAR2(32);
  lv2_local_lock                VARCHAR2(32);

BEGIN

  ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
  ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

  IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
    lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
  END IF;

  IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
    lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
  END IF;

  IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

    lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

    lr_strm_formula := EcDp_Stream_Formula.getNextFormula(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           p_new_lock_columns('FORMULA_METHOD').column_data.AccessVarchar2,
                           ld_new_current_valid);

    ld_new_next_valid := lr_strm_formula.daytime;
    EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

  ELSIF p_operation = 'UPDATING' THEN

    lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

    -- get the next valid daytime
    lr_strm_formula := EcDp_Stream_Formula.getNextFormula(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           p_new_lock_columns('FORMULA_METHOD').column_data.AccessVarchar2,
                           ld_new_current_valid);

    ld_new_next_valid := lr_strm_formula.daytime;

    lr_strm_formula := NULL;

    lr_strm_formula := EcDp_Stream_Formula.getNextFormula(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           p_old_lock_columns('FORMULA_METHOD').column_data.AccessVarchar2,
                           ld_old_current_valid);

    ld_old_next_valid := lr_strm_formula.daytime;

    IF ld_new_next_valid = ld_old_current_valid THEN
      ld_new_next_valid := ld_old_next_valid;
    END IF;

    -- Get previous record
    lr_strm_formula := NULL;
    lr_strm_formula := EcDp_Stream_Formula.getPreviousFormula(
                   p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                   p_new_lock_columns('FORMULA_METHOD').column_data.AccessVarchar2,
                   ld_old_current_valid);

    ld_old_prev_valid := lr_strm_formula.daytime;

    p_old_lock_columns('DAYTIME').is_checked := 'Y';
    IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
      lv2_columns_updated := 'Y';
    ELSE
      lv2_columns_updated := 'N';
    END IF;

    EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                             ld_old_current_valid,
                                             ld_new_next_valid,
                                             ld_old_next_valid,
                                             ld_old_prev_valid,
                                             lv2_columns_updated,
                                             lv2_id,
                                             lv2_n_obj_id);

  ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

    lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

    lr_strm_formula := EcDp_Stream_Formula.getNextFormula(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           p_old_lock_columns('FORMULA_METHOD').column_data.AccessVarchar2,
                           ld_old_current_valid);

    ld_old_next_valid := lr_strm_formula.daytime;
    EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_o_obj_id);

  END IF;

END checkStrmFormulaLock;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkStrmFormulaVariableLock
-- Description    :
--
-- Preconditions  : Checks whether a stream formula variable record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_strm_formula,
--                  checkStrmFormulaLock
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkStrmFormulaVariableLock(p_operation VARCHAR2, p_new_lock_columns EcDp_Month_lock.column_list, p_old_lock_columns EcDp_Month_lock.column_list)
--</EC-DOC>
IS

  lr_strm_formula strm_formula%ROWTYPE;
  l_new_lock_columns EcDp_Month_lock.column_list;
  l_old_lock_columns EcDp_Month_lock.column_list;

BEGIN

  -- Get the parent record
  IF p_operation IN ('INSERTING','UPDATING') THEN
    lr_strm_formula := ec_strm_formula.row_by_pk(p_new_lock_columns('FORMULA_NO').column_data.AccessNumber);
  ELSE
    lr_strm_formula := ec_strm_formula.row_by_pk(p_old_lock_columns('FORMULA_NO').column_data.AccessNumber);
  END IF;

  -- Populate parent table columns in structure.
  EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',AnyData.Convertdate(lr_strm_formula.daytime));
  EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'CLASS_NAME','STRM_FORMULA','VARCHAR2','N','N', NULL);
  EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_strm_formula.object_id));
  EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'FORMULA_METHOD','FORMULA_METHOD','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_strm_formula.formula_method));
  EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'FORMULA_NO','FORMULA_NO','NUMBER','N','N',AnyData.ConvertNumber(lr_strm_formula.formula_no));

  EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',AnyData.Convertdate(lr_strm_formula.daytime));
  EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'CLASS_NAME','STRM_FORMULA','VARCHAR2','N','N', NULL);
  EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_strm_formula.object_id));
  EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'FORMULA_METHOD','FORMULA_METHOD','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_strm_formula.formula_method));
  EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'FORMULA_NO','FORMULA_NO','NUMBER','N','N',AnyData.ConvertNumber(lr_strm_formula.formula_no));

  -- Do whatever you want as long the parent is unlocked
  checkStrmFormulaLock('UPDATING', l_new_lock_columns, l_old_lock_columns);

END checkStrmFormulaVariableLock;


-- end package
END EcBp_Stream_Formula;