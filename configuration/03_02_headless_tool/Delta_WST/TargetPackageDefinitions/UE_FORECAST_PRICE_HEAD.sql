CREATE OR REPLACE PACKAGE ue_Forecast_Price IS
/****************************************************************
** Package        :  ue_Forecast_Price; head part
**
** $Revision: 1.2 $
**
** Purpose        :  Price Forecast business logic
**
** Documentation  :  www.energy-components.com
**
** Created        :  08.01.2009 Olav Nærland
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
*************************************************************************/

PROCEDURE copyFromForecast(p_forecast_id VARCHAR2, p_new_forecast_code VARCHAR2, p_new_forecast_name VARCHAR2, p_start_date DATE, p_end_date DATE DEFAULT NULL);

END ue_Forecast_Price;