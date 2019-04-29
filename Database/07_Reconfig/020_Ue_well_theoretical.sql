create or replace 
PACKAGE Ue_Well_Theoretical IS

/****************************************************************
** Package        :  Ue_Well_Theoretical, header part
*
** Version  Date      Whom      Change description:
** -------  ------    -----     -----------------------------------
**          22.11.07  Yoon Oon  ECPD-6635: Added new functions getDiluentStdRateDay, getGasLiftStdRateDay
**          07.01.08  Kenneth
**                    Masamba   ECPD-6861: Added new functions findWaterCutPct, findCondGasRatio, findGasOilRatio, findSand, findWetDryFactor
**          04.03.08  oonnnng   ECPD-7593: Add new function findWaterGasRatio().
**          17.04.08  sharawan  ECPD-8222: Add new UE functions for sub daily methods
**                              (getOilStdVolSubDay, getGasStdVolSubDay, getWatStdVolSubDay, getCondStdVolSubDay, getGasLiftStdVolSubDay, getDiluentStdVolSubDay).
**          18.08.08  rajarsar  ECPD-9038: Added new function getCO2StdRateDay().
**          19.01.10  aliassit  ECPD-13264: Added new function getGasEnergyDay() and findGCV()
**          28.01.10  madondin  ECPD-13375: WELL - Added USER_EXIT to function findOilStdDensity, findGasStdDensity and findWatStdDensity
**          15.03.10  leongsei  ECPD-13916: Added function findGasWaterRatio
**          18.03.10  aliassit  ECPD-14146: Added function findDryWetFactor
**          26.10-10  Leongwen  ECPD-15122 PT well fluid rate estimation should also work for user exit methods
**          16.07.12  Leongwen  ECPD-21376 Added FUNCTION getInjectedMassStdRateDay()
** 			02.10.13  abdulmaw  ECPD-24427: Added new function getMeterMethod.
** 			08.10.13  abdulmaw  ECPD-24390: Added new function findFuelFlareVent to support fuel, flare and vent in well.
**	 		08.01.2015 dhavaalo ECPD-25537: Added new function getOilStdRateEvent,getGasStdRateEvent,getWatStdRateEvent and getCondStdRateEvent
*****************************************************************/

FUNCTION getOilStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;


FUNCTION getGasStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;


FUNCTION getWatStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;


FUNCTION getCondStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;


FUNCTION getInjectedStdRateDay(
   p_object_id well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION findOilMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findGasMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWaterMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findCondMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getDiluentStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getGasLiftStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWaterCutPct(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findCondGasRatio(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findGasOilRatio(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWaterOilRatio(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findSand(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWetDryFactor(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWaterGasRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER;


FUNCTION getOilStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getGasStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getWatStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getCondStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getDiluentStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getGasLiftStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION declineResult(p_object_id    VARCHAR2,
   p_daytime      DATE,
   p_from_date    DATE,
   p_phase        VARCHAR2,
   p_value        VARCHAR2)
RETURN NUMBER;


FUNCTION getCO2StdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findGCV(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getGasEnergyDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findOilStdDensity(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findGasStdDensity(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWatStdDensity(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findGasWaterRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER;

FUNCTION findDryWetFactor(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER;

FUNCTION getInjectedMassStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime     DATE )
RETURN NUMBER;

FUNCTION getMeterMethod(
   p_object_id well.object_id%TYPE,
   p_daytime DATE)
RETURN NUMBER;

FUNCTION findFuelFlareVent(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_ffv_type VARCHAR2)
RETURN NUMBER;

FUNCTION getOilStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getGasStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getWatStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getCondStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

END Ue_Well_Theoretical;
/

create or replace 
PACKAGE BODY Ue_Well_Theoretical IS
/****************************************************************
** Package        :  Ue_Well_Theoretical, body part
**
** This package is used to program theoretical calculation when a predefined method supplied by EC does not cover the requirements.
** Upgrade processes will never replace this package.
** Version  Date      Whom      Change description:
** -------  ------    -----     -----------------------------------
**          22.11.07  Yoon Oon  ECPD-6635: Added new functions getDiluentStdRateDay, getGasLiftStdRateDay
**          07.01.08  Kenneth
**                    Masamba   ECPD-6861: Added new functions findWaterCutPct, findCondGasRatio, findGasOilRatio, findSand, findWetDryFactor
**          04.03.08	oonnnng	  ECPD-7593: Add new function findWaterGasRatio().
**          17.04.08  sharawan  ECPD-8222: Add new UE functions for sub daily methods
**                              (getOilStdVolSubDay, getGasStdVolSubDay, getWatStdVolSubDay, getCondStdVolSubDay, getGasLiftStdVolSubDay, getDiluentStdVolSubDay).
**          18.08.08	rajarsar  ECPD-9038: Add new function getCO2StdRateDay().
**          19.01.10  aliassit  ECPD-13264: Added new function getGasEnergyDay() and findGCV()
**          28.01.10  madondin  ECPD-13375: WELL - Added USER_EXIT to function findOilStdDensity, findGasStdDensity and findWatStdDensity
**          15.03.10  leongsei  ECPD-13916: Added function findGasWaterRatio
**          18.03.10  aliassit  ECPD-14146: Added function findDryWetFactor
**          26.10-10  Leongwen  ECPD-15122 PT well fluid rate estimation should also work for user exit methods
**          16.07.12  Leongwen  ECPD-21376 Added FUNCTION getInjectedMassStdRateDay()
**          09.03.15  udfd  changed FindGasMassDay(), FindCondMassDay(), FindWaterMassDay()
**          22.05.15  udfd  changed FindCondMassDay(), FindWaterMassDay()
** 			02.10.13  abdulmaw  ECPD-24427: Added new function getMeterMethod.
** 			08.10.13  abdulmaw  ECPD-24390: Added new function findFuelFlareVent to support fuel, flare and vent in well.
**	 		08.01.15  dhavaalo  ECPD-25537: Added new function getOilStdRateEvent,getGasStdRateEvent,getWatStdRateEvent and getCondStdRateEvent
***        01.09.16  Reapplied CVX customizations
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateDay
-- Description    : Returns theoretical oil volume
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_result_no   NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getOilStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateDay
-- Description    : Returns theoretical gas volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_result_no   NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateDay
-- Description    : Returns theoretical water volume
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_result_no   NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWatStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateDay
-- Description    : Returns theoretical condensate volume
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_result_no   NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getCondStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjectedStdRateDay
-- Description    : Returns theoretical injected volume
---------------------------------------------------------------------------------------------------
FUNCTION getInjectedStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getInjectedStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOilMassDay
-- Description    : Returns theoretical oil mass
---------------------------------------------------------------------------------------------------
FUNCTION findOilMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findOilMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasMassDay
-- Description    : Returns theoretical gas mass
-- Function modified to handle mass and not rates LBFK 22-May-2013
-- Function modified - source attribute changed from avg_flow_mass to avg_gas_mass 08-Aug-2014
-- Function modified - well theoreticals for 2-7 changed to calc mass as Vol*Density 06-Oct-2014
---------------------------------------------------------------------------------------------------
FUNCTION findGasMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

   lr_pwel_day_status    PWEL_DAY_STATUS%ROWTYPE;
    lr_density            NUMBER;
BEGIN
    lr_pwel_day_status := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
    lr_density := ecbp_well_theoretical.findGasStdDensity(p_object_id, p_daytime);

    /* User Exit by RYGX 9-Jul-2012
    PWEL_DAY_STATUS.TEXT_15 = Source Type for Well Theoretical.
    Well Theoreticals can be calculated 1 of 7 ways:
        1. SPFM_MEAS_RATE    SPFM Meter Measured Rate PWEL_DAY_STATUS.AVG_FLOW_MASS
        2. FMT              FMT                         PWEL_DAY_STATUS.VALUE_20
        3. IFM_CHOKE        IFM_CHOKE                   PWEL_DAY_STATUS.VALUE_21
        4. IFM_IPR          IFM_IPR                     PWEL_DAY_STATUS.VALUE_22
        5. IFM_VLP_PRO      IFM_VLP_PRO                 PWEL_DAY_STATUS.VALUE_23
        6. IFM_VLP_GAP      IFM_VLP_GAP                 PWEL_DAY_STATUS.VALUE_24
        7. IFM_VLP_IPR      IFM_VLP_IPR                 PWEL_DAY_STATUS.VALUE_25
    Use the WGR and CGR Well Reference Values to determine
    the Theoretical Values for Condensate and Water
    If no valid values are found in SPFM or any of the other derived mass,
    a NULL will always be displayed in the Theoretical Value
    It is then up to the user to debug why the values were not populated */

    IF lr_pwel_day_status.text_15 = 'SPFM' THEN
        RETURN(lr_pwel_day_status.avg_gas_mass);

    -- need to calc mass from volume (gas volume from IFM and FMT assumed to be in kSm3)
    ELSIF lr_pwel_day_status.text_15 = 'FMT' THEN
        RETURN(lr_pwel_day_status.value_20*lr_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_CHOKE' THEN
        RETURN(lr_pwel_day_status.value_21*lr_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_IPR' THEN
        RETURN(lr_pwel_day_status.value_22*lr_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_VLP_PRO' THEN
        RETURN(lr_pwel_day_status.value_23*lr_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_VLP_GAP' THEN
        RETURN(lr_pwel_day_status.value_24*lr_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_VLP_IPR' THEN
        RETURN(lr_pwel_day_status.value_25*lr_density);

  ELSE
    --Handle the case where no appropriate value is entered in Source
    RETURN NULL;

  END IF;
END findGasMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterMassDay
-- Description    : Returns theoretical water mass
-- Function modified to handle mass and not rates LBFK 22-May-2013 */
-- Function modified - source attribute changed from avg_flow_mass to avg_gas_mass 08-Aug-2014 */
-- Function modified - well theoreticals for 2-7 changed to calc mass as Vol*Density*WGR06-Oct-2014												   
---------------------------------------------------------------------------------------------------
FUNCTION findWaterMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

   lr_pwel_day_status  PWEL_DAY_STATUS%ROWTYPE;
    --lr_well_ref_value   WELL_REFERENCE_VALUE%ROWTYPE;
    lr_wgr              NUMBER;
    lr_wat_density      NUMBER;
    lr_g_density      NUMBER;
BEGIN
    lr_pwel_day_status := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
    lr_wgr := ecbp_well_theoretical.findWaterGasRatio(p_object_id, p_daytime);
    --lr_well_ref_value := ec_well_reference_value.row_by_pk(p_object_id, p_daytime, '<=');
    lr_wat_density :=  ecbp_well_theoretical.findWatStdDensity(p_object_id, p_daytime);
    lr_g_density := ecbp_well_theoretical.findGasStdDensity(p_object_id, p_daytime);

    /* User Exit by RYGX 9-Jul-2012
    PWEL_DAY_STATUS.TEXT_15 = Source Type for Well Theoretical.
    Well Theoreticals can be calculated 1 of 7 ways:
        1. SPFM_MEAS_RATE    SPFM Meter Measured Rate PWEL_DAY_STATUS.AVG_FLOW_MAS
        2. FMT              FMT                         PWEL_DAY_STATUS.VALUE_20
        3. IFM_CHOKE        IFM_CHOKE                   PWEL_DAY_STATUS.VALUE_21
        4. IFM_IPR          IFM_IPR                     PWEL_DAY_STATUS.VALUE_22
        5. IFM_VLP_PRO      IFM_VLP_PRO                 PWEL_DAY_STATUS.VALUE_23
        6. IFM_VLP_GAP      IFM_VLP_GAP                 PWEL_DAY_STATUS.VALUE_24
        7. IFM_VLP_IPR      IFM_VLP_IPR                 PWEL_DAY_STATUS.VALUE_25
    Use the WGR and CGR Well Reference Values to determine
    the Theoretical Values for Condensate and Water
    If no valid values are found in SPFM or any of the other derived mass,
    a NULL will always be displayed in the Theoretical Value
    It is then up to the user to debug why the values were not populated */

   -- convert gas tonnes to kg, divide by density to convert to vol, apply wgr, apply water density to get water mass
    IF lr_pwel_day_status.text_15 = 'SPFM' THEN
        RETURN((lr_pwel_day_status.avg_gas_mass/lr_g_density)*lr_wgr*lr_wat_density);

    -- need to calc mass from volume (gas volume from IFM and FMT assumed to be in kSm3)
    ELSIF lr_pwel_day_status.text_15 = 'FMT' THEN

        RETURN(lr_pwel_day_status.value_20*lr_wgr*lr_wat_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_CHOKE' THEN

        RETURN(lr_pwel_day_status.value_21*lr_wgr*lr_wat_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_IPR' THEN
        RETURN(lr_pwel_day_status.value_22*lr_wgr*lr_wat_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_VLP_PRO' THEN
        RETURN(lr_pwel_day_status.value_23*lr_wgr*lr_wat_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_VLP_GAP' THEN
        RETURN(lr_pwel_day_status.value_24*lr_wgr*lr_wat_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_VLP_IPR' THEN
        RETURN(lr_pwel_day_status.value_25*lr_wgr*lr_wat_density);

    ELSE
        --Handle the case where no appropriate value is entered in Source
        RETURN NULL;

    END IF;
END findWaterMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondMassDay
-- Description    : Returns theoretical cond mass
-- Function modified to handle mass and not rates LBFK 22-May-2013
-- Function modified - source attribute changed from avg_flow_mass to avg_gas_mass 08-Aug-2014
-- Function modified - well theoreticals for 2-7 changed to calc mass as Vol*Density*CGR06-Oct-2014												
---------------------------------------------------------------------------------------------------
FUNCTION findCondMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

    lr_pwel_day_status  PWEL_DAY_STATUS%ROWTYPE;
    lr_cgr              NUMBER;
    lr_density          NUMBER;
    lr_g_density         NUMBER;
BEGIN
	 lr_pwel_day_status := ec_pwel_day_status.row_by_pk(p_object_id, p_daytime);
    lr_cgr := ecbp_well_theoretical.findCondGasRatio(p_object_id, p_daytime);
    lr_density := ecbp_well_theoretical.findOilStdDensity(p_object_id, p_daytime);
    lr_g_density := ecbp_well_theoretical.findGasStdDensity(p_object_id, p_daytime);

    /* User Exit by RYGX 9-Jul-2012
       PWEL_DAY_STATUS.TEXT_15 = Source Type for Well Theoretical.
       Well Theoreticals can be calculated 1 of 7 ways:
        1. SPFM_MEAS_RATE    SPFM Meter Measured Rate PWEL_DAY_STATUS.AVG_FLOW_MASS
        2. FMT              FMT                         PWEL_DAY_STATUS.VALUE_20
        3. IFM_CHOKE        IFM_CHOKE                   PWEL_DAY_STATUS.VALUE_21
        4. IFM_IPR          IFM_IPR                     PWEL_DAY_STATUS.VALUE_22
        5. IFM_VLP_PRO      IFM_VLP_PRO                 PWEL_DAY_STATUS.VALUE_23
        6. IFM_VLP_GAP      IFM_VLP_GAP                 PWEL_DAY_STATUS.VALUE_24
        7. IFM_VLP_IPR      IFM_VLP_IPR                 PWEL_DAY_STATUS.VALUE_25
      Use the WGR and CGR Well Reference Values to determine
       the Theoretical Values for Condensate and Water
      If no valid values are found in SPFM or any of the other derived mass,
       a NULL will always be displayed in the Theoretical Value
      It is then up to the user to debug why the values were not populated */

    -- divide gas tonnes by density to convert to vol, apply cgr, apply cond density to get cond mass
    IF lr_pwel_day_status.text_15 = 'SPFM' THEN
        RETURN((lr_pwel_day_status.avg_gas_mass/lr_g_density)*lr_cgr*lr_density);

    -- need to calc mass from volume (gas volume from IFM and FMT assumed to be in kSm3)
    ELSIF lr_pwel_day_status.text_15 = 'FMT' THEN
        RETURN(lr_cgr*lr_pwel_day_status.value_20*lr_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_CHOKE' THEN
        RETURN(lr_cgr*lr_pwel_day_status.value_21*lr_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_IPR' THEN
        RETURN(lr_cgr*lr_pwel_day_status.value_22*lr_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_VLP_PRO' THEN
        RETURN(lr_cgr*lr_pwel_day_status.value_23*lr_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_VLP_GAP' THEN
        RETURN(lr_cgr*lr_pwel_day_status.value_24*lr_density);

    ELSIF lr_pwel_day_status.text_15 = 'IFM_VLP_IPR' THEN
        RETURN(lr_cgr*lr_pwel_day_status.value_25*lr_density);

    ELSE
        --Handle the case where no appropriate value is entered in Source
        RETURN NULL;
  END IF;
				   
END findCondMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDiluentStdRateDay
-- Description    : Returns theoretical diluent volume
---------------------------------------------------------------------------------------------------
FUNCTION getDiluentStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getDiluentStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasLiftStdRateDay
-- Description    : Returns theoretical gas lift volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasLiftStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasLiftStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterCutPct
-- Description    : Returns BSW volume for well on a given day at standard conditions, source method specifiedReturns theoretical gas lift volume
---------------------------------------------------------------------------------------------------
FUNCTION findWaterCutPct(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWaterCutPct;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondGasRatio
-- Description    : Returns Condensate Gas Ratio for well on a given day at standard conditions, source method specified
-- Function modified - CGR is taken from Well Test Results 07-Oct-2014  
---------------------------------------------------------------------------------------------------
FUNCTION findCondGasRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

   lr_pwel_result pwel_result%ROWTYPE;
BEGIN
   lr_pwel_result := ecdp_performance_test.getLastValidWellResult(p_object_id, p_daytime);

   RETURN lr_pwel_result.cgr;
END findCondGasRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasOilRatio
-- Description    : Returns Gas Oil Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findGasOilRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findGasOilRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterOilRatio
-- Description    : Returns Water Oil Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWaterOilRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWaterOilRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findSand
-- Description    : Returns Sand for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findSand(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findSand;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWetDryFactor
-- Description    : Returns Wet Dry Factor Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWetDryFactor(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWetDryFactor;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterGasRatio
-- Description    : Returns Water Gas Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWaterGasRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS
   lr_pwel_result pwel_result%ROWTYPE;

BEGIN
  lr_pwel_result := ecdp_performance_test.getLastValidWellResult(p_object_id, p_daytime);

   RETURN lr_pwel_result.wgr;
END findWaterGasRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdVolSubDay
-- Description    : Returns sub daily theoretical oil volume
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getOilStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdVolSubDay
-- Description    : Returns sub daily theoretical gas volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdVolSubDay
-- Description    : Returns sub daily theoretical water volume
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWatStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdVolSubDay
-- Description    : Returns sub daily theoretical condensate volume
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getCondStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDiluentStdVolSubDay
-- Description    : Returns sub daily theoretical diluent volume
---------------------------------------------------------------------------------------------------
FUNCTION getDiluentStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getDiluentStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasLiftStdVolSubDay
-- Description    : Returns sub daily theoretical gas lift volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasLiftStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasLiftStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : declineResult
-- Description    : Returns decline Result
---------------------------------------------------------------------------------------------------
FUNCTION declineResult(p_object_id    VARCHAR2,
                         p_daytime      DATE,
                         p_from_date    DATE,
                         p_phase        VARCHAR2,
                         p_value        VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

   RETURN NULL;
END declineResult;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCO2StdRateDay
-- Description    : Returns theoretical CO2 volume
---------------------------------------------------------------------------------------------------
FUNCTION getCO2StdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getCO2StdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGCV
-- Description    : Returns gas clorific value
---------------------------------------------------------------------------------------------------
FUNCTION findGCV(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findGCV;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasEnergyDay
-- Description    : Returns theoretical gas energy volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasEnergyDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasEnergyDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOilStdDensity
-- Description    : Returns oil density
-- updated 06/10/2014 - takes density from last approved sample analysis					   
---------------------------------------------------------------------------------------------------
FUNCTION findOilStdDensity(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

   lr_analysis      object_fluid_analysis%ROWTYPE;
BEGIN

   -- take last approved analysis
   lr_analysis := EcDp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'WELL_OIL_COMP', null, p_daytime, 'OIL');

   RETURN lr_analysis.density;
END findOilStdDensity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasStdDensity
-- Description    : Returns gas density
-- updated 06/10/2014 - takes density from last approved sample analysis									 
---------------------------------------------------------------------------------------------------
FUNCTION findGasStdDensity(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

   lr_analysis      object_fluid_analysis%ROWTYPE;
BEGIN
  -- take last approved analysis
  lr_analysis := EcDp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'WELL_GAS_COMP', null, p_daytime, 'GAS');

  RETURN lr_analysis.gas_density;
  
END findGasStdDensity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWatStdDensity
-- Description    : Returns water density
---------------------------------------------------------------------------------------------------
FUNCTION findWatStdDensity(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWatStdDensity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasWaterRatio
-- Description    : Returns Gas Water Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findGasWaterRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findGasWaterRatio;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findDryWetFactor
-- Description    : Returns Dry Wet Factor for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findDryWetFactor(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findDryWetFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjectedMassStdRateDay
-- Description    : Returns the injected standard mass rate on a given day.
---------------------------------------------------------------------------------------------------
FUNCTION getInjectedMassStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getInjectedMassStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMeterMethod
-- Description    : Returns the meter method.
---------------------------------------------------------------------------------------------------
FUNCTION getMeterMethod(
   p_object_id well.object_id%TYPE,
   p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

   RETURN NULL;

END getMeterMethod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findFuelFlareVent
-- Description    :
---------------------------------------------------------------------------------------------------
FUNCTION findFuelFlareVent(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_ffv_type VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

   RETURN NULL;

END findFuelFlareVent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateEvent
-- Description    : Returns theoretical oil rate
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdRateEvent(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getOilStdRateEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateEvent
-- Description    : Returns theoretical gas rate
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdRateEvent(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getGasStdRateEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateEvent
-- Description    : Returns theoretical water rate
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdRateEvent(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getWatStdRateEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateEvent
-- Description    : Returns theoretical condensate rate
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdRateEvent(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getCondStdRateEvent;

END Ue_well_theoretical;
/