CREATE OR REPLACE PACKAGE BODY EcDp_Train_Storage_Yield IS
/****************************************************************
** Package        :  EcDp_Train_Storage_Yield; body part
**
** $Revision: 1.1.2.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  01.03.2013 Annida Farhana
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  --------  -------------------------------------------
** 01.03.2013  farhaann  ECPD-21758: Created getProdRundown, validateOverlappingPeriod, insertStorageYieldFactor, updateStorageYieldFactor, deleteFactor and deleteChildStorage
** 12.03.2014  chooysie  ECPD-27051: Created getFcstProdRundown, validateOverlappingFcstPeriod, insertFcstStorageYieldFactor and deleteFcstChildStorage
******************************************************************/

--------------------------------------------------------------------------------------------------
-- Function       : getProdRundown
-- Description    : Get Production Rundown value
-- Using tables   : train_storage_yield
---------------------------------------------------------------------------------------------------
FUNCTION getProdRundown(p_object_id  VARCHAR2,
                        p_storage_id VARCHAR2,
                        p_daytime    DATE) RETURN NUMBER

 IS
  ln_return_val   NUMBER;
  ln_inlet_gas    NUMBER;
  ln_yield_factor NUMBER;

  CURSOR c_train(cp_object_id  VARCHAR2, cp_storage_id VARCHAR2, cp_daytime DATE) IS
    SELECT tsy.storage_id, tsy.yield_factor
      FROM train_storage_yield tsy
     WHERE tsy.object_id = cp_object_id
       AND tsy.storage_id = cp_storage_id
       AND tsy.daytime = cp_daytime;

BEGIN

  ln_inlet_gas := ec_train_inlet_gas.inlet_gas(p_object_id, p_daytime, '<=');

  FOR curTrain IN c_train(p_object_id, p_storage_id, p_daytime) LOOP
    ln_yield_factor := curTrain.yield_factor;
    ln_return_val   := ln_inlet_gas * ln_yield_factor;
  END LOOP;

  RETURN ln_return_val;

END getProdRundown;

---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriod
-- Description    : Validate that the new entry should not overlap with existing period
-- Using tables   : train_inlet_gas
---------------------------------------------------------------------------------------------------
PROCEDURE validateOverlappingPeriod(p_object_id VARCHAR2,
                                    p_daytime   DATE,
                                    p_end_date  DATE)

 IS

  CURSOR c_overlap(cp_object_id VARCHAR2, cp_daytime DATE, cp_end_date DATE) IS
    SELECT *
      FROM TRAIN_INLET_GAS tig
     WHERE tig.object_id = cp_object_id
       AND tig.daytime <> cp_daytime
       AND (tig.end_date >= cp_daytime OR tig.end_date IS NULL)
       AND (tig.daytime <= cp_end_date OR cp_end_date IS NULL);

  lv_message VARCHAR2(4000);

BEGIN

  lv_message := null;

  FOR cur_overlap IN c_overlap(p_object_id, p_daytime, p_end_date) LOOP
    lv_message := lv_message || cur_overlap.object_id || ' ';
  END LOOP;

  IF lv_message is not null THEN
    Raise_Application_Error(-20121,
                            'The date overlaps with another period');
  END IF;

END validateOverlappingPeriod;

---------------------------------------------------------------------------------------------------
-- Procedure      : insertStorageYieldFactor
-- Description    : Insert record in TRAIN_STORAGE_YIELD if new record created in TRAIN_INLET_GAS
-- Using tables   : train_inlet_gas, train_stor_yield_fac, train_storage_yield
---------------------------------------------------------------------------------------------------
PROCEDURE insertStorageYieldFactor(p_object_id VARCHAR2, p_daytime DATE)

 IS

  CURSOR c_stor_yield_factor(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT tig.object_id, tig.daytime, tsyf.storage_id, tsyf.yield_factor
      FROM train_inlet_gas tig, train_stor_yield_fac tsyf
     WHERE tig.object_id = cp_object_id
       AND tig.object_id = tsyf.process_train_id
       AND tig.daytime = cp_daytime;

BEGIN

  FOR cur_stor_yield_factor IN c_stor_yield_factor(p_object_id, p_daytime) LOOP
    INSERT INTO TRAIN_STORAGE_YIELD
      (object_id, daytime, storage_id, yield_factor, created_by)
    VALUES
      (p_object_id,
       p_daytime,
       cur_stor_yield_factor.storage_id,
       cur_stor_yield_factor.yield_factor,
       ecdp_context.getAppUser);
  END LOOP;

END insertStorageYieldFactor;

---------------------------------------------------------------------------------------------------
-- Procedure      : updateStorageYieldFactor
-- Description    : Insert record in TRAIN_STORAGE_YIELD and FCST_TRAIN_STORAGE_YIELD if new storage added in TRAIN_STOR_YIELD_FAC
-- Using tables   : train_inlet_gas, train_stor_yield_fac, train_storage_yield, fcst_train_inlet_gas, fcst_train_storage_yield
---------------------------------------------------------------------------------------------------
PROCEDURE updateStorageYieldFactor(p_process_train_id VARCHAR2)

 IS

  CURSOR c_stor_yield(cp_process_train_id VARCHAR2) IS
    select tsyf.storage_id,
           tsyf.process_train_id,
           tsyf.yield_factor,
           tig.daytime
      from train_stor_yield_fac tsyf, train_inlet_gas tig
     where tsyf.process_train_id = cp_process_train_id
       and tsyf.process_train_id = tig.object_id
       and tsyf.storage_id not in
           (select storage_id
              from train_storage_yield
             where object_id = cp_process_train_id);

  CURSOR c_fcst_stor_yield(cp_process_train_id VARCHAR2) IS
    select tsyf.storage_id,
           tig.forecast_id,
           tsyf.process_train_id,
           tsyf.yield_factor,
           tig.daytime
     from train_stor_yield_fac tsyf, fcst_train_inlet_gas tig
     where tsyf.process_train_id = cp_process_train_id
       and tsyf.process_train_id = tig.object_id
       and tsyf.storage_id not in
           (select storage_id
              from fcst_train_storage_yield
             where object_id = cp_process_train_id);

BEGIN

  FOR cur_stor_yield IN c_stor_yield(p_process_train_id) LOOP
    INSERT INTO TRAIN_STORAGE_YIELD
      (object_id, daytime, storage_id, yield_factor, created_by)
    VALUES
      (cur_stor_yield.process_train_id,
       cur_stor_yield.daytime,
       cur_stor_yield.storage_id,
       cur_stor_yield.yield_factor,
       ecdp_context.getAppUser);

  END LOOP;

  FOR cur_fcst_stor_yield IN c_fcst_stor_yield(p_process_train_id) LOOP
    INSERT INTO FCST_TRAIN_STORAGE_YIELD
      (object_id, forecast_id, daytime, storage_id, yield_factor, created_by)
    VALUES
      (cur_fcst_stor_yield.process_train_id,
       cur_fcst_stor_yield.forecast_id,
       cur_fcst_stor_yield.daytime,
       cur_fcst_stor_yield.storage_id,
       cur_fcst_stor_yield.yield_factor,
       ecdp_context.getAppUser);
  END LOOP;

END updateStorageYieldFactor;

---------------------------------------------------------------------------------------------------
-- Procedure      : deleteFactor
-- Description    : Delete records in TRAIN_STORAGE_YIELD and FCST_TRAIN_STORAGE_YIELD if record in TRAIN_STOR_YIELD_FAC deleted
-- Using tables   : train_storage_yield, fcst_train_storage_yield
---------------------------------------------------------------------------------------------------
PROCEDURE deleteFactor(p_process_train_id VARCHAR2, p_storage_id VARCHAR2)

 IS

BEGIN

  DELETE FROM train_storage_yield tsy
   WHERE tsy.object_id = p_process_train_id
     AND tsy.storage_id = p_storage_id;

  DELETE FROM FCST_TRAIN_STORAGE_YIELD tsy
   WHERE tsy.object_id = p_process_train_id
     AND tsy.storage_id = p_storage_id;

END deleteFactor;

---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildStorage
-- Description    : Delete records in TRAIN_STORAGE_YIELD if record in TRAIN_INLET_GAS deleted
-- Using tables   : train_storage_yield
---------------------------------------------------------------------------------------------------
PROCEDURE deleteChildStorage(p_object_id VARCHAR2, p_daytime DATE)

 IS

BEGIN

  DELETE FROM train_storage_yield
   WHERE object_id = p_object_id
     AND daytime = p_daytime;

END deleteChildStorage;

--------------------------------------------------------------------------------------------------
-- Function       : getFcstProdRundown
-- Description    : Get Forecast Production Rundown value
-- Using tables   : fcst_train_storage_yield
---------------------------------------------------------------------------------------------------
FUNCTION getFcstProdRundown(p_object_id  VARCHAR2,
                        p_forecast_id VARCHAR2,
                        p_storage_id VARCHAR2,
                        p_daytime    DATE) RETURN NUMBER

 IS
  ln_return_val   NUMBER;
  ln_inlet_gas    NUMBER;
  ln_yield_factor NUMBER :=0;

  CURSOR c_fcst_train(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2,cp_storage_id VARCHAR2,cp_daytime DATE) IS
    SELECT tsy.storage_id, tsy.yield_factor
      FROM fcst_train_storage_yield tsy
     WHERE tsy.object_id = cp_object_id
       AND tsy.forecast_id = cp_forecast_id
       AND tsy.storage_id = cp_storage_id
       AND tsy.daytime = cp_daytime;

BEGIN

  ln_inlet_gas := ec_fcst_train_inlet_gas.inlet_gas(p_object_id, p_forecast_id, p_daytime, '<=');

  FOR curFcstTrain IN c_fcst_train(p_object_id, p_forecast_id, p_storage_id, p_daytime) LOOP
    ln_yield_factor := curFcstTrain.yield_factor;
    ln_return_val   := ln_inlet_gas * ln_yield_factor;
  END LOOP;

  RETURN ln_return_val;

END getFcstProdRundown;

---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingFcstPeriod
-- Description    : Validate that the new forecast entry should not overlap with existing period
-- Using tables   : fcst_train_inlet_gas
---------------------------------------------------------------------------------------------------
PROCEDURE validateOverlappingFcstPeriod(p_object_id VARCHAR2,
                                    p_forecast_id VARCHAR2,
                                    p_daytime   DATE,
                                    p_end_date  DATE)

 IS

  CURSOR c_fcst_overlap(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2,cp_daytime DATE, cp_end_date  DATE) IS
    SELECT *
      FROM FCST_TRAIN_INLET_GAS tig
     WHERE tig.object_id = cp_object_id
       AND tig.forecast_id = cp_forecast_id
       AND tig.daytime <> cp_daytime
       AND (tig.end_date >= cp_daytime OR tig.end_date IS NULL)
       AND (tig.daytime <= cp_end_date OR cp_end_date IS NULL);

  lv_message VARCHAR2(4000);

BEGIN

  lv_message := null;

  FOR cur_fcst_overlap IN c_fcst_overlap(p_object_id, p_forecast_id, p_daytime, p_end_date) LOOP
    lv_message := lv_message || cur_fcst_overlap.object_id || ' ';
  END LOOP;

  IF lv_message is not null THEN
    Raise_Application_Error(-20121,
                            'The date overlaps with another period');
  END IF;

END validateOverlappingFcstPeriod;

---------------------------------------------------------------------------------------------------
-- Procedure      : insertFcstStorageYieldFactor
-- Description    : Insert record in FCST_TRAIN_STORAGE_YIELD if new record created in FCST_TRAIN_INLET_GAS
-- Using tables   : fcst_train_inlet_gas, train_stor_yield_fac, fcst_train_storage_yield
---------------------------------------------------------------------------------------------------
PROCEDURE insertFcstStorageYieldFactor(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE)

 IS

  CURSOR c_fcst_stor_yield_factor(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_daytime DATE) IS
    SELECT tig.object_id, tig.daytime, tsyf.storage_id, tsyf.yield_factor
      FROM fcst_train_inlet_gas tig, train_stor_yield_fac tsyf
     WHERE tig.object_id = cp_object_id
       AND tig.forecast_id = cp_forecast_id
       AND tig.object_id = tsyf.process_train_id
       AND tig.daytime = cp_daytime;

BEGIN

  FOR cur_fcst_stor_yield_factor IN c_fcst_stor_yield_factor(p_object_id, p_forecast_id, p_daytime) LOOP
    INSERT INTO FCST_TRAIN_STORAGE_YIELD
      (object_id, forecast_id, daytime, storage_id, yield_factor, created_by)
    VALUES
      (p_object_id,
       p_forecast_id,
       p_daytime,
       cur_fcst_stor_yield_factor.storage_id,
       cur_fcst_stor_yield_factor.yield_factor,
       ecdp_context.getAppUser);
  END LOOP;

END insertFcstStorageYieldFactor;

---------------------------------------------------------------------------------------------------
-- Procedure      : deleteFcstChildStorage
-- Description    : Delete records in FCST_TRAIN_STORAGE_YIELD if record in FCST_TRAIN_INLET_GAS deleted
-- Using tables   : fcst_train_storage_yield
---------------------------------------------------------------------------------------------------
PROCEDURE deleteFcstChildStorage(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE)

 IS

BEGIN

  DELETE FROM fcst_train_storage_yield
   WHERE object_id = p_object_id
     AND forecast_id = p_forecast_id
     AND daytime = p_daytime;

END deleteFcstChildStorage;

END EcDp_Train_Storage_Yield;