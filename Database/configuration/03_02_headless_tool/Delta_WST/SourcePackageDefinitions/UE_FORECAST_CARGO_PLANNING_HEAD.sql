CREATE OR REPLACE PACKAGE ue_Forecast_Cargo_Planning IS
  /****************************************************************
  ** Package        :  ue_Forecast_Cargo_Planning; head part
  **
  ** $Revision: 1.2 $
  **
  ** Purpose        :  Cargo Planning Forecast business logic
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created        :  06.06.2008 Kari Sandvik
  **
  ** Modification history:
  **
  ** Date          Whom      Change description:
  ** ----------    -----     -------------------------------------------
  ** 18/11/2013  muhammah  ECPD-25921: add procedure deleteForecastCascade
  ** 15/01/2016  sharawan  ECPD-33109: added parameter for copyFromOriginal and copyFromForecast used in Forecast Manager screen
  ** 27/09/2016  asareswi  ECPD-39168: Added procedure PopulateStorage to populate PROD stream data into TRAN table
  ** 15/08/2017  sharawan  ECPD-47293: Added procedure validateDate to validate End Date when creating Forecast in Forecast Manager screen
  ** 15/11/2018  thotesan  ECPD-59863: Added function includeInCopy to get cargo status for Copy to orgional plan.
  *************************************************************************/

  PROCEDURE copyFromOriginal(p_new_forecast_code VARCHAR2,
                             p_start_date        DATE,
                             p_end_date          DATE,
                             p_storage_id        VARCHAR2 DEFAULT NULL);

  PROCEDURE copyFromForecast(p_forecast_id       VARCHAR2,
                             p_new_forecast_code VARCHAR2,
                             p_start_date        DATE,
                             p_end_date          DATE,
                             p_storage_id        VARCHAR2 DEFAULT NULL);

  PROCEDURE copyToOriginal(p_forecast_id VARCHAR2);

  PROCEDURE deleteForecastCascade(p_forecast_id VARCHAR2,
                                  p_start_date  DATE,
                                  p_end_date    DATE);

  PROCEDURE copyFromOriginalFcstMngr(p_new_forecast_code VARCHAR2,
                                     p_start_date        DATE,
                                     p_end_date          DATE,
                                     p_storage_id        VARCHAR2 DEFAULT NULL);

  PROCEDURE copyFromForecastFcstMngr(p_forecast_id       VARCHAR2,
                                     p_new_forecast_code VARCHAR2,
                                     p_start_date        DATE,
                                     p_end_date          DATE,
                                     p_storage_id        VARCHAR2 DEFAULT NULL);

  PROCEDURE copyToOriginalFcstMngr(p_forecast_id VARCHAR2);

  PROCEDURE deleteForecastFM(p_forecast_id VARCHAR2);

  PROCEDURE PopulateStorage( p_tran_forecast_id VARCHAR2
							, p_prod_forecast_id VARCHAR2
							, p_prod_fcst_scenario_id VARCHAR2
							, p_daytime DATE
							, p_storage_id VARCHAR2
							, p_stream_id VARCHAR2);

  PROCEDURE validateDate(p_from_date DATE, p_to_date DATE);
  FUNCTION includeInCopy(p_forecast_id VARCHAR2, p_cargo_no NUMBER, p_parcel_no NUMBER,p_cargo_status VARCHAR2,p_fcst_cargo_status VARCHAR2) RETURN VARCHAR2;
END ue_Forecast_Cargo_Planning;