CREATE OR REPLACE PACKAGE BODY EcBp_Stream IS

/****************************************************************
** Package        :  EcBp_Stream, body part
**
** $Revision: 1.29 $
**
** Purpose        :  This package is responsible for finding specific stream properties
**                   that is not achievable directly in the stream objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.12.1999  Carl-Fredrik S�sen
**
** Modification history:
**
**  Date        Whom      Change description:
**  ----------  --------  --------------------------------------
**  05.12.1999  CFS       First version
**  30.03.2001  KEJ       Documented functions and procedures.
**  02.04.2001  JEH       Added aggStrmFromPeriodToDay and aggStrmFromDayToMonth
**  12.06.2001  AIE       Added aggAllStrmPeriodToDay and aggAllStrmDayToMonth
**  05.01.2004  SHN       Replaced table strm_reference_values with stream_attribute in function findRefValue.
**  21.06.2004  AV        Reversed change in findRefValue, we are still using strm_reference_value
**  28.07.2004  KSN        Added AND ln_net_std_vol <> 0 to setDefaultTicketVol (Tracker 1341)
**  10.08.2004  Toha      Replaced sysnam+stream_code to stream.object_id and updated as necessary.
**  03.12.2004  DN        TI 1823: Removed dummy package constructor.
**  28.01.2005  Ron       Added getResvBlockFormationValue to get the value for the Resvoir Block Formation field in the Maintain Stream Screen.
**  28.02.2005  kaurrnar  Removed deadcode.
**                          Removed references to ec_xxx_attribute packages.
**  07.03.2005  Toha   TI 1965: Removed function aggAllStrmPeriodToDay, aggAllStrmDayToMonth
**  27.04.2005  DN        Removed function getRefValue.
**  28.04.2005  DN        Bug fix: id columns must be declared varchar2(32).
**  09.11.2005  kaurrnar  TI 2743: Ticket Volume default to NULL if net volume is 0 for function setDefaultTicketVol
**  08.08.2007  idrussab  ECPD-6122: use ec_strm_version.stream_phase replacing ecdp_stream.getStreamPhase
**  20.09.2007  idrussab  ECPD-6591: Removed function getRefQualityStream and update findRefAnalysisStream
**  03.10.2007  ismaiime  ECPD:6683: Update findRefAnalysisStream
**  21.11.2008  oonnnng   ECPD-6067: Added local month lock checking in setDefaultTicketVol function.
**  30.12.2008  sharawan  ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions aggStrmFromPeriodToDay, aggStrmFromDayToMonth.
**  17.02.2009  leongsei  ECPD-6067: Modified function setDefaultTicketVol for new parameter p_local_lock
**  10.04.2009  oonnnng   ECPD-6067: Update local lock checking function in setDefaultTicketVol() function with the new design.
**  27.01.2012  kumarsur  ECPD-19809: added getRateUom.
**  23.08.2018  abdulmaw  ECPD-49811: added getUom.
*****************************************************************/
--<EC-DOC>
-----------------------------------------------------------------
-- Function     : findRefAnalysisStream
-- Description  : Returns an analysis reference stream from STRM_REFERENCE_STREAM
--
-- Preconditions:
-- Postcondition:
-- Using Tables:
--
-- Using functions:
--                 EC_STRM_REFERENCE_STREAM.ANALYSIS_STREAM
--                 ECDP_STREAM.GETSTREAMWELL
--                 ECBP_STREAM.GETREFQUALITYSTREAM
--
-- Configuration
-- required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION findRefAnalysisStream (p_object_id   stream.object_id%TYPE,
                                p_daytime     DATE)

RETURN VARCHAR2
--<EC-DOC>
IS

lv2_ref_stream  VARCHAR2(32);

BEGIN
   /*
   lv2_ref_stream := ec_strm_reference_stream.analysis_stream_id(
                        p_object_id,
                        p_daytime, '<=');
   */
   -- TODO: Check if this is a good approach to find an analysis stream. This should
   -- maybe be handled on the client

   lv2_ref_stream := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   RETURN lv2_ref_stream;

END findRefAnalysisStream;


--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getResvBlockFormationValue
-- Description  : Returns the value of Reservoir Block Formation by appending the description of
--                Reservoir Block and Reservoir Formation.
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: EC_RESV_BLOCK.DESCRIPTION
--                  EC_RESV_FORMATION.DESCRIPTION
-- Configuration
-- required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getResvBlockFormationValue(p_block_id     VARCHAR2,
                                    p_formation_id VARCHAR2)
RETURN VARCHAR2 IS
   v_return_val VARCHAR2(2000);

   BEGIN

   IF (p_block_id is NULL) AND (p_formation_id is NULL) THEN
         v_return_val := NULL;
   ELSE
      v_return_val := EC_RESV_BLOCK.DESCRIPTION(p_block_id) || ' - ' || EC_RESV_FORMATION.DESCRIPTION(p_formation_id);
   END IF;

   RETURN v_return_val;
END getResvBlockFormationValue;


------------------------------------------------------------------
-- PROCEDURE:  aggStrmFromPeriodToDay
-- Purpose:    Aggregate period data to daily data for Stream.
--             (strm_period_status => strm_day_stream)
------------------------------------------------------------------
PROCEDURE aggStrmFromPeriodToDay(p_object_id    stream.object_id%TYPE,
                                 p_day          DATE,
                                 p_time_span    VARCHAR2)
IS

   CURSOR c_strm IS
   SELECT SUM(grs_mass)  sum_grs_mass,
          SUM(grs_vol)   sum_grs_vol,
          SUM(temp    * grs_mass)/SUM(DECODE(NVL(temp,0),0,NULL,grs_mass))    calc_temp,
          SUM(press   * grs_mass)/SUM(DECODE(NVL(press,0),0,NULL,grs_mass))   calc_press,
          SUM(density * grs_mass)/SUM(DECODE(NVL(density,0),0,NULL,grs_mass)) calc_density,
          SUM(energy)    sum_energy
     FROM strm_period_status
    WHERE object_id = p_object_id
      AND day       = p_day
      AND time_span = p_time_span;

   ln_grs_mass    NUMBER;
   ln_grs_vol     NUMBER;
   ln_energy      NUMBER;
   ln_avg_temp    NUMBER;
   ln_avg_press   NUMBER;
   ln_density     NUMBER;

BEGIN

   FOR strm_rec IN c_strm LOOP

      ln_grs_mass    := strm_rec.sum_grs_mass;
      ln_grs_vol     := strm_rec.sum_grs_vol;
      ln_energy      := strm_rec.sum_energy;
      ln_avg_temp    := strm_rec.calc_temp;
      ln_avg_press   := strm_rec.calc_press;
      ln_density     := strm_rec.calc_density;

      UPDATE strm_day_stream
         SET grs_mass     = ln_grs_mass,
             grs_vol      = ln_grs_vol,
             energy       = ln_energy,
             avg_temp     = ln_avg_temp,
             avg_press    = ln_avg_press,
             density      = ln_density
       WHERE object_id    = p_object_id
         AND daytime      = p_day;

   END LOOP;
END aggStrmFromPeriodToDay;
-- End Procedure


------------------------------------------------------------------
-- PROCEDURE:  aggStrmFromDayToMonth
-- Purpose:    Aggregate daily data to monthly data.
--             (strm_day_stream => strm_mth_stream)
------------------------------------------------------------------
PROCEDURE aggStrmFromDayToMonth(
     p_object_id   stream.object_id%TYPE,
     p_day             DATE
)
IS

   ld_first_day   DATE;
   ld_last_day    DATE;

   CURSOR c_strm IS
   SELECT SUM(grs_mass)  sum_grs_mass,
          SUM(grs_vol)   sum_grs_vol,
          SUM(avg_temp  * grs_mass)/SUM(DECODE(NVL(avg_temp,0),0,NULL,grs_mass))    calc_temp,
          SUM(avg_press * grs_mass)/SUM(DECODE(NVL(avg_press,0),0,NULL,grs_mass))   calc_press,
          SUM(density   * grs_mass)/SUM(DECODE(NVL(density,0),0,NULL,grs_mass)) calc_density,
          SUM(energy)    sum_energy
     FROM strm_day_stream
    WHERE object_id          = p_object_id
      AND daytime           >= ld_first_day
      AND daytime           <= ld_last_day;

   ln_grs_mass    NUMBER;
   ln_grs_vol     NUMBER;
   ln_energy      NUMBER;
   ln_avg_temp    NUMBER;
   ln_avg_press    NUMBER;
   ln_density     NUMBER;

BEGIN
   ld_first_day      := trunc(p_day,'MON');
   ld_last_day       := last_day(p_day);

   -- Saved on first day in month.
   FOR strm_rec IN c_strm LOOP

      ln_grs_mass    := strm_rec.sum_grs_mass;
      ln_grs_vol     := strm_rec.sum_grs_vol;
      ln_energy      := strm_rec.sum_energy;
      ln_avg_temp    := strm_rec.calc_temp;
      ln_avg_press   := strm_rec.calc_press;
      ln_density     := strm_rec.calc_density;

      UPDATE strm_mth_stream
         SET grs_mass     = ln_grs_mass,
             grs_vol      = ln_grs_vol,
             energy       = ln_energy,
             avg_temp     = ln_avg_temp,
             avg_press    = ln_avg_press,
             density      = ln_density
       WHERE object_id    = p_object_id
         AND daytime      = ld_first_day;

   END LOOP;
END aggStrmFromDayToMonth;
-- End Procedure

--<EC-DOC>
-----------------------------------------------------------------
-- Function     : setDefaultTicketVol
-- Description  : Set default value (NetStdVol) for Ticket Net Volume
--                (STRM_EVENT.NET_VOL) if NULL
--
-- Preconditions: Possibly uncommitted changes.
-- Postcondition:
-- Using Tables:  STRM_EVENT
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour:
--
-----------------------------------------------------------------
PROCEDURE setDefaultTicketVol(
   p_strm_object_id STREAM.OBJECT_ID%TYPE,
   p_daytime DATE,
   p_ticket_net_vol STRM_EVENT.NET_VOL%TYPE)
--</EC-DOC>
IS
  ln_net_std_vol  STRM_EVENT.NET_VOL%TYPE;
BEGIN

   IF (p_ticket_net_vol IS NULL OR p_ticket_net_vol=0) THEN
     ln_net_std_vol := EcBp_Stream_Fluid.findNetStdVol(p_strm_object_id,
                                                       p_daytime,
                                                       null,
                                                       EcDp_Calc_Method.BATCH_API);

     IF ln_net_std_vol IS NOT NULL AND ln_net_std_vol <> 0 THEN


       -- lock check
       IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

          EcDp_Month_lock.raiseValidationError('PROCEDURE', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'EcBp_Stream.setDefaultTicketVol: Can not do this in a locked month');

       END IF;

       EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_strm_object_id,
                                   p_daytime, p_daytime,
                                   'PROCEDURE', 'EcBp_Stream.setDefaultTicketVol: Can not do this in a local locked month.');

        -- Update STRM_EVENT record with default
        UPDATE STRM_EVENT
           SET NET_VOL       = ln_net_std_vol
         WHERE OBJECT_ID     = p_strm_object_id AND
               EVENT_TYPE    = 'STRM_OIL_BATCH_EVENT' AND
               DAYTIME       = p_daytime;

     END IF;
   END IF;

END setDefaultTicketVol;
-- End Procedure

---------------------------------------------------------------------------------------------------
-- Function       : getRateUom
-- Description    : Returns the UOM of planned rate for a stream based on phase of the stream.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
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
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
FUNCTION getRateUom(p_object_id VARCHAR2,
                  p_daytime DATE,
                  p_rate_type VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_phase VARCHAR(32);
  lv2_uom VARCHAR2(32);

   CURSOR cur_view_unit(c_uom_meas_type VARCHAR2) IS
   SELECT unit
   FROM ctrl_uom_setup cus
   WHERE cus.measurement_type = c_uom_meas_type
   AND cus.view_unit_ind = 'Y';

BEGIN

  lv2_phase := ec_strm_version.stream_phase(p_object_id,p_daytime,'<=');
  IF p_rate_type = 'VOLUME' THEN
    lv2_uom := EcDp_ClassMeta_Cnfg.getUomCode('STRM_PLAN_BUDGET','VOLUME_RATE');
    IF lv2_uom IS NULL THEN
      IF lv2_phase IN ('OIL','COND','STEAM') THEN
        lv2_uom := 'STD_LIQ_VOL_RATE';
      ELSIF lv2_phase = 'WAT' THEN
        lv2_uom := 'STD_WATER_RATE';
      ELSIF lv2_phase = 'GAS' THEN
        lv2_uom := 'STD_GAS_RATE';
      ELSE
        lv2_uom := 'STD_LIQ_VOL_RATE';
      END IF;
    END IF;
  ELSE -- mass
    lv2_uom := EcDp_ClassMeta_Cnfg.getUomCode('STRM_PLAN_BUDGET','MASS_RATE');
    IF lv2_uom IS NULL THEN
      IF lv2_phase IN ('OIL','COND','STEAM','WAT') THEN
        lv2_uom := 'LIQ_MASS_RATE';
      ELSIF lv2_phase = 'GAS' THEN
        lv2_uom := 'GAS_MASS_RATE';
      ELSE
        lv2_uom := 'LIQ_MASS_RATE';
      END IF;
    END IF;
END IF;

  FOR c_view_unit IN cur_view_unit(lv2_uom) LOOP
    lv2_uom := c_view_unit.unit;
  END LOOP;

 lv2_uom:= ECDP_UNIT.GetUnitLabel(lv2_uom);

RETURN lv2_uom;
END getRateUom;

---------------------------------------------------------------------------------------------------
-- Function       : getUom
-- Description    : Returns the UOM of a stream based on phase of the stream.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
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
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
FUNCTION getUom(p_object_id VARCHAR2,
                p_daytime DATE,
                p_type VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
--</EC-DOC>
IS
   lv2_phase     VARCHAR(32);
   lv2_uom       ctrl_uom_setup.unit%TYPE;
   lv2_unitLabel ctrl_unit.label%TYPE;

   CURSOR cur_view_unit(c_uom_meas_type VARCHAR2) IS
   SELECT unit
   FROM ctrl_uom_setup cus
   WHERE cus.measurement_type = c_uom_meas_type
   AND cus.view_unit_ind = 'Y';

BEGIN

  lv2_phase := ec_strm_version.stream_phase(p_object_id,p_daytime,'<=');
  IF p_type = 'VOLUME' THEN
    IF lv2_phase = 'OIL' THEN
      lv2_uom := 'STD_OIL_VOL';
    ELSIF lv2_phase = 'WAT' THEN
      lv2_uom := 'WATER_VOL';
    ELSIF lv2_phase = 'GAS' THEN
      lv2_uom := 'STD_GAS_VOL';
    ELSIF lv2_phase = 'LNG' THEN
      lv2_uom := 'STD_LNG_VOL';
    ELSIF lv2_phase = 'STEAM' THEN
      lv2_uom := 'STEAM_VOL_CWE';
    ELSE
      lv2_uom := 'STD_LIQ_VOL';
    END IF;

  ELSIF p_type = 'MASS' THEN
    IF lv2_phase = 'OIL' THEN
      lv2_uom := 'OIL_MASS';
    ELSIF lv2_phase = 'WAT' THEN
      lv2_uom := 'WATER_MASS';
    ELSIF lv2_phase = 'GAS' THEN
      lv2_uom := 'GAS_MASS';
    ELSIF lv2_phase = 'LNG' THEN
      lv2_uom := 'LNG_MASS';
    ELSIF lv2_phase = 'STEAM' THEN
      lv2_uom := 'STEAM_MASS';
    ELSE
      lv2_uom := 'LIQ_MASS';
    END IF;
  END IF;

  FOR c_view_unit IN cur_view_unit(lv2_uom) LOOP
    lv2_uom := c_view_unit.unit;
  END LOOP;

  lv2_unitLabel:= ECDP_UNIT.GetUnitLabel(lv2_uom);

RETURN lv2_unitLabel;
END getUom;

END;