CREATE OR REPLACE PACKAGE BODY ue_Forecast_Price IS
/****************************************************************
** Package        :  ue_Forecast_Price; body part
**
** $Revision: 1.2 $
**
** Purpose        :  Price Forecast business logic
**
** Documentation  :  www.energy-components.com
**
** Created        :  08.01.2009 Olav N?and
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
********************************************************************/

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
PROCEDURE copyFromForecast(p_forecast_id VARCHAR2, p_new_forecast_code VARCHAR2, p_new_forecast_name VARCHAR2, p_start_date DATE, p_end_date DATE DEFAULT NULL)
--</EC-DOC>
IS

BEGIN
  EcDp_Forecast_Price.copyFromForecast(p_forecast_id, p_new_forecast_code, p_new_forecast_name, p_start_date, p_end_date);
END copyFromForecast;

END ue_Forecast_Price;