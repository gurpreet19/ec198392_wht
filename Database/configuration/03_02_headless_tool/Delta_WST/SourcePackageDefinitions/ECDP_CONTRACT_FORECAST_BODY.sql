CREATE OR REPLACE PACKAGE BODY EcDp_Contract_Forecast IS
/****************************************************************
** Package        :  EcDp_Contract_Forecast
**
** $Revision: 1.5 $
**
** Purpose        :  Find, generate and aggregate sale forecast data.
**
** Documentation  :  www.energy-components.com
**
** Created        :  16.12.2004  Tor-Erik Hauge
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   Initial version (first build / handover to test)
** 11.01.2005  BIH   Added / cleaned up documentation
** 07.11.2006  RAJARSAR Added aggregateDailyToMonthly Procedure and aggregateForecastVolQty Function
** 14.09.2007  KAURRJES ECPD:6339 - Corrected the checking in the While Loop to include the last day of the period.
** 13.05.2009  MASAMKEN ECPD:11561 - Create two new functions createDaysForPeriod and deleteHourlyData.
******************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createDaysForWeek
-- Description    : Generates emty records in cntr_day_dp_forecast starting for p_daytime and
--                  the 6 next days for contract p_contract_id and delivery point p_delpt_id
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE createDaysForWeek(
   p_contract_id	VARCHAR2,
   p_delpt_id		VARCHAR2,
   p_daytime		DATE,
   p_curr_user 	VARCHAR2
)
--</EC-DOC>
IS
   ld_end               DATE;
   ld_daytime           DATE;
   li_day_record_count  INTEGER;
BEGIN
   ld_end := p_daytime + 6;
   ld_daytime := p_daytime;

   WHILE ld_daytime <= ld_end LOOP
      SELECT COUNT(*)
      INTO li_day_record_count
      FROM cntr_day_dp_forecast
      WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = ld_daytime;
      IF li_day_record_count = 0 THEN
         INSERT INTO cntr_day_dp_forecast (object_id, delivery_point_id, daytime, forecast_qty, created_by) VALUES (p_contract_id, p_delpt_id,  ld_daytime, 0, p_curr_user);
      END IF;
      ld_daytime := ld_daytime + 1;
   END LOOP;
END createDaysForWeek;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createDaysForPeriod
-- Description    : Generates emty records in cntr_day_dp_forecast starting for p_fromdate upto p_todate
-- for contract p_contract_id and delivery point p_delpt_id
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE createDaysForPeriod(
   p_nav_model         VARCHAR2,
   p_nav_class_name    VARCHAR2,
   p_nav_object_id     VARCHAR2,
   p_delivery_point_id VARCHAR2 DEFAULT NULL,
   p_bfprofile         VARCHAR2,
   p_from_date         DATE,
   p_to_date           DATE,
   p_curr_user 	       VARCHAR2
)
IS


cursor c_cntr_dp is
select np.CONTRACT_ID,
       np.DELIVERY_POINT_ID,
       greatest(np.DAYTIME, p_from_date) fromdate,
       least(nvl(np.END_DATE, c.END_DATE), p_to_date) todate
  from nav_model_object_relation r, ov_nomination_point np, ov_contract c
 where r.class_name = 'CONTRACT'
   and r.model = p_nav_model
   and ((r.ancestor_object_id = p_nav_object_id and
       r.ancestor_class_name = p_nav_class_name) or
       (r.object_id = p_nav_object_id and 'CONTRACT' = p_nav_class_name))
   and r.object_id = c.OBJECT_ID
   and c.DAYTIME < p_to_date
   and (c.END_DATE > p_to_date or c.END_DATE is null)
   and c.BF_PROFILE in (select s.profile_code
                          from bf_profile_setup s
                         where s.bf_code = p_bfprofile)
   and r.object_id = np.CONTRACT_ID
   and (np.DELIVERY_POINT_ID = nvl(p_delivery_point_id, np.DELIVERY_POINT_ID))
   and np.DAYTIME < p_to_date
   and (np.END_DATE > p_from_date or np.END_DATE is null);


   ld_end               DATE;
   ld_daytime           DATE;
   li_day_record_count  INTEGER;
BEGIN

  FOR c_res in c_cntr_dp LOOP
    ld_daytime := c_res.fromdate ;
    WHILE ld_daytime < c_res.todate LOOP
      SELECT COUNT(*)
      INTO li_day_record_count
      FROM cntr_day_dp_forecast
      WHERE object_id = c_res.contract_id AND delivery_point_id = c_res.delivery_point_id AND daytime = ld_daytime;
      IF li_day_record_count = 0 THEN
         INSERT INTO cntr_day_dp_forecast (object_id, delivery_point_id, daytime, forecast_qty, created_by) VALUES (c_res.contract_id, c_res.delivery_point_id,  ld_daytime, 0, p_curr_user);
      END IF;
      ld_daytime := ld_daytime + 1;
   END LOOP;
  END LOOP;

END createDaysForPeriod;



--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : deleteHourlyData
-- Description    : Function deletes hourly data for given daily data
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : cntr_sub_day_dp_forecast
--
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
PROCEDURE deleteHourlyData(
   p_object_id         VARCHAR2,
   p_delpt_id          VARCHAR2,
   p_production_day         DATE
)
 IS


BEGIN

    DELETE FROM cntr_sub_day_dp_forecast
     WHERE object_id = p_object_id
	 AND delivery_point_id = p_delpt_id
	 AND production_day = p_production_day;

END deleteHourlyData;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createContractDayHours
-- Description    : Generates hourly records into cntr_sub_day_dp_forecast
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_forecast
--                  cntr_sub_day_dp_forecast
--
-- Using functions: getNumberOfSubDailyRecords
--                  EcDp_Contract.getContractDayHours
--
-- Configuration
-- required       :
--
-- Behaviour      : Generates any missing hourly rows for the given contract day, taking contract
--                  day offsets and daylight savings time transitions into account.
--                  If no sub-daily records already existed then the daily quantity is distributed
--                  evenly to the new records. Otherwise, any new records get zero quantity.
--
---------------------------------------------------------------------------------------------------
PROCEDURE createContractDayHours(
   p_contract_id	VARCHAR2,
   p_delpt_id     	VARCHAR2,
   p_daytime       DATE,
   p_curr_user		VARCHAR2
)
--</EC-DOC>
IS
   li_pointer        INTEGER := 0;
   li_record_count   INTEGER;
   ln_daily_qty      NUMBER := 0;
   ln_hourly_qty     NUMBER := 0;
   lr_daytime        EcDp_Date_Time.Ec_Unique_Daytimes;

   CURSOR c_day_forecast IS
      SELECT forecast_qty
      FROM cntr_day_dp_forecast
      WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime;

BEGIN
	IF p_contract_id IS NULL or p_delpt_id IS NULL or p_daytime iS NULL
		THEN
			RAISE_APPLICATION_ERROR(-20103,'createContractDayHours requires p_contract_id, p_delpt_id and p_daytime to be a non-NULL value.');
	END IF;
   lr_daytime := EcDp_ContractDay.getProductionDayDaytimes('CONTRACT',p_contract_id,p_daytime);

   FOR curForecast IN c_day_forecast LOOP
      ln_daily_qty:= curForecast.forecast_qty;
   END LOOP;

   --Only inserting calculated values for hourly quantity when there are no records from before
   IF getNumberOfSubDailyRecords(p_contract_id,p_delpt_id,p_daytime) = 0 THEN
      ln_hourly_qty:= ln_daily_qty / lr_daytime.COUNT;
   END IF;

   FOR li_pointer in 1..lr_daytime.COUNT LOOP
      SELECT COUNT(*)
      INTO li_record_count
      FROM cntr_sub_day_dp_forecast
      WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = lr_daytime(li_pointer).daytime AND production_day = p_daytime AND summer_time = lr_daytime(li_pointer).summertime_flag;
      IF li_record_count = 0 THEN
         INSERT INTO cntr_sub_day_dp_forecast (object_id, delivery_point_id,  daytime, production_day, summer_time, forecast_qty, created_by) VALUES (p_contract_id, p_delpt_id, lr_daytime(li_pointer).daytime, p_daytime, lr_daytime(li_pointer).summertime_flag, ln_hourly_qty, p_curr_user);
      END IF;
   END LOOP;
END createContractDayHours;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNumberOfSubDailyRecords
-- Description    : Returns the number of hourly forecasts records for contract p_contract_id
--                  and delivery point p_delpt_id at day p_daytime
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getNumberOfSubDailyRecords(
   p_contract_id  	VARCHAR2,
   p_delpt_id  	VARCHAR2,
   p_daytime		DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   li_number_of_sub_daily_records INTEGER;
BEGIN
   SELECT COUNT(*)
   INTO li_number_of_sub_daily_records
   FROM cntr_sub_day_dp_forecast
   WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND production_day = p_daytime;

   RETURN li_number_of_sub_daily_records;
END getNumberOfSubDailyRecords;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDailyForecast
-- Description    : Returns the daily forecast for contract p_contract_id and delivery point
--                  p_delpt_id at day p_daytime
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the quantity from the daily record (not as a sum of sub-daily).
--
---------------------------------------------------------------------------------------------------
FUNCTION getDailyForecast(
   p_contract_id	VARCHAR2,
   p_delpt_id	  	VARCHAR2,
   p_daytime  		DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_day_forecast NUMBER;
   CURSOR c_forecast_qty IS
      SELECT forecast_qty
      FROM cntr_day_dp_forecast
      WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime;
BEGIN
   FOR curForecast IN c_forecast_qty LOOP
      ln_day_forecast:= curForecast.forecast_qty;
   END LOOP;
   RETURN ln_day_forecast;
END getDailyForecast;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDailyForecast
-- Description    : Returns the hourly forecast for contract p_contract_id and delivery point
--                  p_delpt_id at daytime p_daytime
--
-- Preconditions  : p_daytime should be a logical contract hour (zero minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDailyForecast(
   p_contract_id	VARCHAR2,
   p_delpt_id	  	VARCHAR2,
   p_daytime  		DATE,
   p_summer_time	VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_sub_day_forecast NUMBER;
   CURSOR c_forecast_qty IS
      SELECT forecast_qty
      FROM cntr_sub_day_dp_forecast
      WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime AND summer_time = p_summer_time;
BEGIN
   FOR curForecast IN c_forecast_qty LOOP
      ln_sub_day_forecast:= curForecast.forecast_qty;
   END LOOP;
   RETURN ln_sub_day_forecast;
END getSubDailyForecast;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aggregateSubDailyToDaily
-- Description    : Calculates the sum of all hourly forecasts at day p_daytime for contract
--                  p_contract_id and delivery_point p_delpt_id and inserts the result into
--                  the daily forecast record
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_forecast
--                  cntr_sub_day_dp_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateSubDailyToDaily(
   p_contract_id	VARCHAR2,
   p_delpt_id	VARCHAR2,
   p_daytime    	DATE,
   p_user		VARCHAR2
)
--</EC-DOC>
IS
   ln_sum_forecast_qty    NUMBER :=0;

   CURSOR c_sum_forecast_qty IS
      SELECT SUM(forecast_qty) result
      FROM cntr_sub_day_dp_forecast
      WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND production_day = p_daytime;
BEGIN
   FOR curForecastSum IN c_sum_forecast_qty LOOP
      ln_sum_forecast_qty:= curForecastSum.result;
   END LOOP;

   UPDATE cntr_day_dp_forecast SET forecast_qty = ln_sum_forecast_qty, last_updated_by = p_user
   WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime;
END aggregateSubDailyToDaily;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aggregateDailyToMonthly
-- Description    : Calculates the sum of all hourly forecasts at day p_daytime for contract
--                  p_contract_id and delivery_point p_delpt_id and inserts the result into
--                  the daily forecast record
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_forecast
--                  cntr_sub_day_dp_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateDailyToMonthly(
   p_contract_id	VARCHAR2,
   p_delpt_id	VARCHAR2,
   p_daytime    	DATE,
   p_user		VARCHAR2
)
--</EC-DOC>
IS
   ln_sum_forecast_qty    NUMBER :=0;

   CURSOR c_sum_forecast_qty IS
      SELECT SUM(forecast_qty) result
      FROM cntr_day_dp_forecast
      WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime;
BEGIN
   FOR curForecastSum IN c_sum_forecast_qty LOOP
      ln_sum_forecast_qty:= curForecastSum.result;
   END LOOP;

END aggregateDailyToMonthly;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION aggregateForecastVolQty
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION aggregateForecastVolQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_iterator NUMBER;
ld_end DATE;
ld_daytime DATE;
ln_sum_vol_qty    NUMBER;
ln_result NUMBER;

BEGIN

   ld_end := LAST_DAY(p_daytime);
   ld_daytime := TRUNC (p_daytime, 'MONTH');

	ln_sum_vol_qty :=0;
	ln_result := 0;

   WHILE ld_daytime <= ld_end LOOP

   	SELECT SUM(forecast_qty) INTO ln_result
			FROM cntr_day_dp_forecast
			WHERE object_id = p_object_id
			AND delivery_point_id = p_delivery_point_id
			AND daytime = ld_daytime;

		ln_sum_vol_qty:=ln_sum_vol_qty+Nvl(ln_result,0);

		ld_daytime := ld_daytime + 1;

   END LOOP;

  RETURN ln_sum_vol_qty;

END  aggregateForecastVolQty;



END EcDp_Contract_Forecast;