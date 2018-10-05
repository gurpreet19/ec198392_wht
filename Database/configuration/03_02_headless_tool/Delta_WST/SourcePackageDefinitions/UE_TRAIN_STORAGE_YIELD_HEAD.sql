CREATE OR REPLACE PACKAGE ue_train_storage_yield IS

/******************************************************************************
** Package        :  ue_train_storage_yield, header part
**
** $Revision: 1.5 $
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
** 01.03.2013  farhaann  ECPD-19774: Created getProdRundown, validateOverlappingPeriod and insertStorageYieldFactor
** 04.03.2013  farhaann  ECPD-19774: Created deleteFactor and deleteChildStorage
** 06.03.2013  farhaann  ECPD-19774: Created updateStorageYieldFactor
** 12.03.2014  chooysie  ECPD-26914: Created getFcstProdRundown, validateOverlappingFcstPeriod, insertFcstStorageYieldFactor and deleteFcstChildStorage
** 25.06.2014  farhaann  ECPD-27949: Created populateProductionForecast and populateFcstProductionForecast
** 24.07.2017  asareswi  ECPD-38098: Added forecast_id parameter in populateFcstProductionForecast procedure.
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

PROCEDURE populateProductionForecast(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE);

PROCEDURE populateFcstProductionForecast(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_end_date DATE);

END ue_train_storage_yield;