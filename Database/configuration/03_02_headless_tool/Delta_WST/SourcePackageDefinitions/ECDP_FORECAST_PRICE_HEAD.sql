CREATE OR REPLACE PACKAGE ECDP_Forecast_Price IS
/****************************************************************
** Package        :  ECDP_Forecast_Price; head part
**
** $Revision: 1.2 $
**
** Purpose        :  Price Forecast business logic
**
** Documentation  :  www.energy-components.com
**
** Created        :  08.01.2009 Olav N�and
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
*************************************************************************/

PROCEDURE createForecast(p_new_forecast_code VARCHAR2, p_new_forecast_name VARCHAR2, p_start_date DATE, p_end_date DATE, p_new_forecast_id OUT VARCHAR2);

PROCEDURE copyFromForecast(p_forecast_id VARCHAR2, p_new_forecast_code VARCHAR2, p_new_forecast_name VARCHAR2, p_start_date DATE, p_end_date DATE DEFAULT NULL);

PROCEDURE InsNewPriceElementSet(
    p_forecast_id               VARCHAR2,
    p_object_id                 VARCHAR2,
    p_price_concept_code        VARCHAR2,
    p_price_element_code        VARCHAR2,
    p_daytime                   DATE);

END ECDP_Forecast_Price;