CREATE OR REPLACE PACKAGE ue_train_storage_yield IS

/******************************************************************************
** Package        :  ue_train_storage_yield, header part
**
** $Revision: 1.3.2.2 $
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
** 01.03.2013  farhaann  ECPD-21758: Created getProdRundown, validateOverlappingPeriod, insertStorageYieldFactor, deleteFactor, deleteChildStorage and updateStorageYieldFactor.\
** 12.03.2014  chooysie  ECPD-27051: Created getFcstProdRundown, validateOverlappingFcstPeriod, insertFcstStorageYieldFactor and deleteFcstChildStorage
*/

FUNCTION getProdRundown(p_object_id VARCHAR2, p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

PROCEDURE validateOverlappingPeriod(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE);

PROCEDURE insertStorageYieldFactor(p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE updateStorageYieldFactor(p_process_train_id VARCHAR2);

PROCEDURE deleteFactor(p_process_train_id VARCHAR2, p_storage_id VARCHAR2);

PROCEDURE deleteChildStorage(p_object_id VARCHAR2, p_daytime DATE);

FUNCTION getFcstProdRundown(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

PROCEDURE validateOverlappingFcstPeriod(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_end_date DATE);

PROCEDURE insertFcstStorageYieldFactor(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE);

PROCEDURE deleteFcstChildStorage(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE);

END ue_train_storage_yield;