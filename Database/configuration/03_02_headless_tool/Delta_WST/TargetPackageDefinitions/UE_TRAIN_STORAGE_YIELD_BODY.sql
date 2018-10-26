CREATE OR REPLACE PACKAGE BODY ue_train_storage_yield IS
/******************************************************************************
** Package        :  ue_train_storage_yield, body part
**
** $Revision: 1.4.2.3 $
**
** Purpose        :  Includes user-exit functionality for process train
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.03.2013 Annida Farhana
**
** Modification history:
**
** Date        Whom      Change description:
** -------     ------    -----------------------------------------------
** 01.03.2013  farhaann  ECPD-21758: Created getProdRundown, validateOverlappingPeriod, insertStorageYieldFactor, deleteFactor, deleteChildStorage and updateStorageYieldFactor.
** 12.03.2014  chooysie  ECPD-27051: Created getFcstProdRundown, validateOverlappingFcstPeriod, insertFcstStorageYieldFactor and deleteFcstChildStorage
*/
--------------------------------------------------------------------------------------------------
-- Function       : getProdRundown
-- Description    : Get Production Rundown value
---------------------------------------------------------------------------------------------------
FUNCTION getProdRundown(p_object_id VARCHAR2, p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER
 IS
  lv_ind NUMBER;
BEGIN
  lv_ind := EcDp_Train_Storage_Yield.getProdRundown(p_object_id, p_storage_id, p_daytime);
  RETURN lv_ind;
END getProdRundown;
---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriod
-- Description    : Validate that the new entry should not overlap with existing period
---------------------------------------------------------------------------------------------------
PROCEDURE validateOverlappingPeriod(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE)
 IS
BEGIN
  EcDp_Train_Storage_Yield.validateOverlappingPeriod(p_object_id, p_daytime, p_end_date);
END validateOverlappingPeriod;
---------------------------------------------------------------------------------------------------
-- Procedure      : insertStorageYieldFactor
-- Description    : Insert record in TRAIN_STORAGE_YIELD if new record created in TRAIN_INLET_GAS
---------------------------------------------------------------------------------------------------
PROCEDURE insertStorageYieldFactor(p_object_id VARCHAR2, p_daytime DATE)
 IS
BEGIN
  EcDp_Train_Storage_Yield.insertStorageYieldFactor(p_object_id, p_daytime);
END insertStorageYieldFactor;
---------------------------------------------------------------------------------------------------
-- Procedure      : updateStorageYieldFactor
-- Description    : Insert record in TRAIN_STORAGE_YIELD if new storage added in TRAIN_STOR_YIELD_FAC
---------------------------------------------------------------------------------------------------
PROCEDURE updateStorageYieldFactor(p_process_train_id VARCHAR2)
 IS
BEGIN
  EcDp_Train_Storage_Yield.updateStorageYieldFactor(p_process_train_id);
END updateStorageYieldFactor;
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteFactor
-- Description    : Delete records in TRAIN_STORAGE_YIELD if record in TRAIN_STOR_YIELD_FAC deleted
---------------------------------------------------------------------------------------------------
PROCEDURE deleteFactor(p_process_train_id VARCHAR2, p_storage_id VARCHAR2)
 IS
BEGIN
  EcDp_Train_Storage_Yield.deleteFactor(p_process_train_id, p_storage_id);
END deleteFactor;
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildStorage
-- Description    : Delete records in TRAIN_STORAGE_YIELD if record in TRAIN_INLET_GAS deleted
---------------------------------------------------------------------------------------------------
PROCEDURE deleteChildStorage(p_object_id VARCHAR2, p_daytime DATE)
 IS
BEGIN
  EcDp_Train_Storage_Yield.deleteChildStorage(p_object_id, p_daytime);
END deleteChildStorage;

--------------------------------------------------------------------------------------------------
-- Function       : getFcstProdRundown
-- Description    : Get Forecast Production Rundown value
---------------------------------------------------------------------------------------------------
FUNCTION getFcstProdRundown(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER
 IS
  lv_ind NUMBER;
BEGIN
  lv_ind := EcDp_Train_Storage_Yield.getFcstProdRundown(p_object_id, p_forecast_id, p_storage_id, p_daytime);
  RETURN lv_ind;
END getFcstProdRundown;

---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingFcstPeriod
-- Description    : Validate that the new forecast entry should not overlap with existing period
---------------------------------------------------------------------------------------------------
PROCEDURE validateOverlappingFcstPeriod(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_end_date DATE)
 IS
BEGIN
  EcDp_Train_Storage_Yield.validateOverlappingFcstPeriod(p_object_id, p_forecast_id, p_daytime, p_end_date);
END validateOverlappingFcstPeriod;

---------------------------------------------------------------------------------------------------
-- Procedure      : insertFcstStorageYieldFactor
-- Description    : Insert record in FCST_TRAIN_STORAGE_YIELD if new record created in FCST_TRAIN_INLET_GAS
---------------------------------------------------------------------------------------------------
PROCEDURE insertFcstStorageYieldFactor(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE)
 IS
BEGIN
  EcDp_Train_Storage_Yield.insertFcstStorageYieldFactor(p_object_id, p_forecast_id, p_daytime);
END insertFcstStorageYieldFactor;

---------------------------------------------------------------------------------------------------
-- Procedure      : deleteFcstChildStorage
-- Description    : Delete records in FCST_TRAIN_STORAGE_YIELD if record in FCST_TRAIN_INLET_GAS deleted
---------------------------------------------------------------------------------------------------
PROCEDURE deleteFcstChildStorage(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE)
 IS
BEGIN
  EcDp_Train_Storage_Yield.deleteFcstChildStorage(p_object_id, p_forecast_id, p_daytime);
END deleteFcstChildStorage;

END ue_train_storage_yield;