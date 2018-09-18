CREATE OR REPLACE PACKAGE BODY ue_Forecast_Cargo_Planning IS
/****************************************************************
** Package        :  ue_Forecast_Cargo_Planning; body part
**
** $Revision: 1.1.40.3 $
**
** Purpose        :  Handles capacity release operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  06.06.2008 Kari Sandvik
**
** Modification history:
**
** Date       	 Whom  		Change description:
** ----------  	----- 		-------------------------------------------
** 19/11/2013	muhammah	ECPD-26093: add procedure deleteForecastCascade
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFromOriginal
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFromOriginal(p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

BEGIN
	EcBp_Forecast_Cargo_Planning.copyFromOriginal(p_new_forecast_code, p_start_date, p_end_date, p_storage_id);

END copyFromOriginal;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFromForecast
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFromForecast(p_forecast_id VARCHAR2, p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

BEGIN
	EcBp_Forecast_Cargo_Planning.copyFromForecast(p_forecast_id, p_new_forecast_code, p_start_date, p_end_date, p_storage_id);

END copyFromForecast;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyToOriginal
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyToOriginal(p_forecast_id VARCHAR2)
--</EC-DOC>
IS

BEGIN
	EcBp_Forecast_Cargo_Planning.copyToOriginal(p_forecast_id);

END copyToOriginal;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteForecastCascade
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteForecastCascade(p_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE)
--</EC-DOC>

IS

BEGIN

     NULL;

END deleteForecastCascade;

END ue_Forecast_Cargo_Planning;