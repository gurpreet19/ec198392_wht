CREATE OR REPLACE PACKAGE BODY EcBp_Cargo_Planning IS
  /****************************************************************
  ** Package        :  EcBp_Cargo_Planning; body part
  **
  ** $Revision: 1.1.2.1 $
  **
  ** Purpose        :  Handles cargo planning forecast calculations
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created        :  11.03.2013 Lee Wei Yap
  **
  ** Modification history:
  **
  ** Date        Whom    Change description:
  ** 11/3/2013   leeeewei  ECPD-23302: add setProcessTrainEvent and delProcessTrainEvent
  **
  ********************************************************************/
  CURSOR c_yield_factor(cp_object_id VARCHAR2) IS
    select t.process_train_id, t.storage_id, t.yield_factor
      from train_stor_yield_fac t
     where t.process_train_id = cp_object_id;

  CURSOR c_fcst_sub_day_qty(cp_storage_id VARCHAR2,
                            cp_object_id  VARCHAR2,
                            cp_daytime    DATE,
                            cp_end_date   DATE) IS
    select s.object_id, s.daytime, s.grs_vol
      from stor_sub_day_pc_fcst s
     where s.object_id = cp_storage_id
       and s.profit_centre_id = cp_object_id
       and s.daytime >= trunc(cp_daytime)
       and s.daytime < trunc(cp_end_date) + 1
     order by s.object_id, s.daytime;

  CURSOR c_sum_sub_day(cp_storage_id VARCHAR2,
                       cp_object_id  VARCHAR2,
                       cp_daytime    DATE) IS
    SELECT SUM(GRS_VOL) daily_rundown
      FROM stor_sub_day_pc_fcst
     WHERE object_id = cp_storage_id
       AND profit_centre_id = cp_object_id
       AND production_day = cp_daytime;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : setProcessTrainEvent
  -- Description    : calculate the production forecast rundown on daily and subdaily for a storage when an event is registered
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : TRAIN_STOR_YIELD_FAC, STOR_DAY_PC_fORECAST, STOR_SUB_DAY_PC_fCST, STOR_DAY_FORECAST
  -- Using functions: Ecdp_storage_forecast.aggrForecast
  --
  -- Configuration
  -- required       : Process Train Storage Yield Factor, Period Process Train Storage Yield, Process Train Event Profile
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------

  PROCEDURE setProcessTrainEvent(p_object_id  VARCHAR2,
                                 p_daytime    DATE,
                                 p_end_date   DATE,
                                 p_event_code VARCHAR2)

   IS

    lv_storage_id VARCHAR2(32);

    ln_inlet_gas      NUMBER;
    ln_end_inlet_gas  NUMBER;
    ln_ramp_down_hrs  NUMBER;
    ln_ramp_down_rate NUMBER;
    ln_yield_factor   NUMBER;
    ln_grs_vol        NUMBER;
    ln_rundown        NUMBER;
    ln_sum_sub_day    NUMBER;
    ln_ramp_up_hrs    NUMBER;
    ln_ramp_up_rate   NUMBER;
    ln_end_grs_vol    NUMBER;

    ld_daytime   DATE;
    ld_from_date DATE;
    ld_to_date   DATE;

  BEGIN

    ln_inlet_gas := ec_train_inlet_gas.inlet_gas(p_object_id,
                                                 p_daytime,
                                                 '<=');

    ln_end_inlet_gas := ec_train_inlet_gas.inlet_gas(p_object_id,
                                                     p_end_date,
                                                     '<=');

    ln_ramp_down_hrs := ec_prtr_event_profile.ramp_down_hrs(p_object_id,
                                                            p_event_code,
                                                            p_daytime,
                                                            '<=');

    ln_ramp_up_hrs := ec_prtr_event_profile.ramp_up_hrs(p_object_id,
                                                        p_event_code,
                                                        p_daytime,
                                                        '<=');

    ln_ramp_down_rate := ec_prtr_event_profile.ramp_down_rate(p_object_id,
                                                              p_event_code,
                                                              p_daytime,
                                                              '<=');

    ln_ramp_up_rate := ec_prtr_event_profile.ramp_up_rate(p_object_id,
                                                          p_event_code,
                                                          p_daytime,
                                                          '<=');

    IF (ln_ramp_down_hrs IS NOT NULL AND ln_ramp_down_rate IS NOT NULL AND ln_ramp_up_hrs IS NOT NULL AND ln_ramp_up_rate IS NOT NULL) THEN
      FOR cur_yield_factor IN c_yield_factor(p_object_id) LOOP

        lv_storage_id   := cur_yield_factor.storage_id;
        ln_yield_factor := cur_yield_factor.yield_factor;
        ln_grs_vol := ln_inlet_gas * ln_yield_factor / 24;

        FOR cur_fcst_sub_day_qty in c_fcst_sub_day_qty(lv_storage_id,
                                                       p_object_id,
                                                       p_daytime,
                                                       p_end_date) LOOP

          ld_daytime := cur_fcst_sub_day_qty.daytime;

          -- event period
          IF (ld_daytime >= p_daytime AND ld_daytime < p_end_date) THEN

            -- ramp up
            IF (ld_daytime > (p_end_date - ln_ramp_up_hrs / 24) AND
               ld_daytime < p_end_date) THEN

              ln_rundown := ln_grs_vol +
                            (ln_ramp_up_rate * ln_yield_factor / 24);

             --ramp down
            ELSE

              ln_rundown := ln_grs_vol -
                            (ln_ramp_down_rate * ln_yield_factor / 24);

              IF ln_rundown <= 0 THEN
                ln_rundown := 0;
              END IF;
            END IF;

            UPDATE stor_sub_day_pc_fcst
               SET grs_vol = ln_rundown
             WHERE object_id = lv_storage_id
               AND profit_centre_id = p_object_id
               AND daytime = ld_daytime;

            ln_grs_vol := ln_rundown;

            -- check if inlet gas is still the same when event ends
          ELSIF (ld_daytime >= p_end_date AND
                ld_daytime < trunc(p_end_date) + 1) THEN
            ln_end_grs_vol := ln_end_inlet_gas * ln_yield_factor / 24;

            UPDATE stor_sub_day_pc_fcst
               SET grs_vol = ln_end_grs_vol
             WHERE object_id = lv_storage_id
               AND profit_centre_id = p_object_id
               AND daytime = ld_daytime;

           --event not started
          ELSE
            UPDATE stor_sub_day_pc_fcst
               SET grs_vol = ln_grs_vol
             WHERE object_id = lv_storage_id
               AND profit_centre_id = p_object_id
               AND daytime = ld_daytime;

          END IF;

          ld_daytime := ld_daytime + 1 / 24;

        END LOOP;

        ld_from_date := trunc(p_daytime);
        ld_to_date   := trunc(p_end_date) + 1;

        -- Update daily rundown
        WHILE (ld_from_date < ld_to_date) LOOP

          FOR curSum IN c_sum_sub_day(lv_storage_id,
                                      p_object_id,
                                      ld_from_date) LOOP

            ln_sum_sub_day := curSum.daily_rundown;

          END LOOP;

          UPDATE stor_day_pc_forecast
             SET grs_vol = ln_sum_sub_day
           WHERE object_id = lv_storage_id
             AND profit_centre_id = p_object_id
             AND daytime = ld_from_date;

          -- aggregate to stor_day_forecast table
          ecdp_storage_forecast.aggrForecast(lv_storage_id, ld_from_date);

          ld_from_date := ld_from_date + 1;

        END LOOP;
      END LOOP;
    END IF;

  END setProcessTrainEvent;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : delProcessTrainEvent
  -- Description    : Delete process train event and recalculate rundown to their original values defined in the process train yield factors
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : TRAIN_STOR_YIELD_FAC, STOR_DAY_PC_fORECAST, STOR_SUB_DAY_PC_fCST, STOR_DAY_FORECAST
  -- Using functions: Ecdp_storage_forecast.aggrForecast
  --
  -- Configuration
  -- required       : Process Train Storage Yield Factor, Period Process Train Storage Yield, Process Train Event Profile
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE delProcessTrainEvent(p_object_id  VARCHAR2,
                                 p_daytime    DATE,
                                 p_end_date   DATE)

   IS

    lv_storage_id VARCHAR2(32);

    ln_yield_factor  NUMBER;
    ln_grs_vol       NUMBER;
    ln_inlet_gas     NUMBER;
    ln_end_inlet_gas NUMBER;
    ln_sum_sub_day   NUMBER;

    ld_daytime   DATE;
    ld_from_date DATE;
    ld_to_date   DATE;

  BEGIN

    ln_inlet_gas := ec_train_inlet_gas.inlet_gas(p_object_id,
                                                 p_daytime,
                                                 '<=');

    ln_end_inlet_gas := ec_train_inlet_gas.inlet_gas(p_object_id,
                                                     p_end_date,
                                                     '<=');

    for cur_yield_factor in c_yield_factor(p_object_id) loop
      lv_storage_id   := cur_yield_factor.storage_id;
      ln_yield_factor := cur_yield_factor.yield_factor;

      for cur_fcst_sub_day_qty in c_fcst_sub_day_qty(lv_storage_id,
                                                     p_object_id,
                                                     p_daytime,
                                                     p_end_date) loop

        ld_daytime := cur_fcst_sub_day_qty.daytime;
        IF (ln_inlet_gas <> ln_end_inlet_gas) THEN
          IF (ld_daytime >= trunc(p_daytime) AND ld_daytime < trunc(p_end_date)) THEN
            ln_grs_vol := ln_inlet_gas * ln_yield_factor / 24;
          ELSE
            ln_grs_vol := ln_end_inlet_gas * ln_yield_factor / 24;
          END IF;
        END IF;

        UPDATE stor_sub_day_pc_fcst
           SET grs_vol = ln_grs_vol
         WHERE object_id = lv_storage_id
           AND profit_centre_id = p_object_id
           AND daytime = ld_daytime;

        ld_daytime := ld_daytime + 1 / 24;
      END LOOP;

      ld_from_date := trunc(p_daytime);
      ld_to_date   := trunc(p_end_date) + 1;

      While (ld_from_date < ld_to_date) loop
        FOR curSum IN c_sum_sub_day(lv_storage_id,
                                    p_object_id,
                                    ld_from_date) LOOP

          ln_sum_sub_day := curSum.daily_rundown;

        END LOOP;

        UPDATE stor_day_pc_forecast
           SET grs_vol = ln_sum_sub_day
         WHERE object_id = lv_storage_id
           AND profit_centre_id = p_object_id
           AND daytime = ld_from_date;

        ecdp_storage_forecast.aggrForecast(lv_storage_id, ld_from_date);

        ld_from_date := ld_from_date + 1;

      END LOOP;
    END LOOP;

  END delProcessTrainEvent;

END EcBp_Cargo_Planning;