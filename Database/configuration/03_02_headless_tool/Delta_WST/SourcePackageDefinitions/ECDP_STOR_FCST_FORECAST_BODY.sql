CREATE OR REPLACE PACKAGE BODY EcDp_Stor_Fcst_Forecast IS
/****************************************************************
** Package        :  EcDp_Stor_Fcst_Forecast; body part
**
** $Revision: 1.16 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  04.06.2008	Kari Sandvik
**
** Modification history:
**
** Date        Whom      	Change description:
** ----------  -----     	-------------------------------------------
** 05.12.2011  farhaann  	ECPD-15916: Added rev_no in apportionStorDay and apportionStorPcDay update statements
** 07.12.2011  farhaann  	ECPD-15916: Removed rev_no in apportionStorDay and apportionStorPcDay update statements
**                                      Modified update statements to refer to the view in apportionStorDay and apportionStorPcDay
** 23.05.2013  muhammah	    ECPD-23062: added PROCEDURE aiuStorPcForecast
** 31.10.2013  chooysie	    ECPD-25826: Modified function:aiuStorPcForecast to pick up correct lifting account when no porfit centre in connected to lifting account
** 25.11.2013  chooysie	    ECPD-12096: Modified function:aiuStorPcForecast to pass in exact profit centre id class from c_classes.
** 10.12.2013  chooysie	    ECPD-16016: Modified function:aiuStorPcForecast to pick equity share with correct equity phase.
** 28.12.2016  sharawan     ECPD-42222: Modified aiuStorPcForecast procedure to improve performance. Modified apportionStorPcDay to include cursor class.
**                                      Copied from ecdp_storage_forecast.
** 21.03.2017  baratmah     ECPD-43620: Modified procedure apportionStorPcDay to run it for all days in month.
******************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPlannedMonthAverage
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :  stor_mth_pc_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPlannedMonthAverage(p_storage_id VARCHAR2,
							p_pc_id VARCHAR2,
							p_forecast_id VARCHAR2,
							p_first_of_year DATE)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_forecast(p_storage_id VARCHAR2, p_pc_id VARCHAR2, cp_forecast_id VARCHAR2, p_first_of_year DATE, p_first_of_next_year DATE)IS
SELECT avg(t.forecast_qty) average
FROM stor_mth_fcst_pc_fcast t
WHERE t.object_id = p_storage_id AND
	t.profit_centre_id = p_pc_id AND
	t.forecast_id = cp_forecast_id AND
	t.daytime >= p_first_of_year AND
	t.daytime < p_first_of_next_year;

ln_month_average NUMBER := -1;
ld_fist_of_next_year DATE;

BEGIN
	ld_fist_of_next_year := add_months(p_first_of_year, 12);

	FOR forecastCur IN c_forecast (p_storage_id, p_pc_id, p_forecast_id, p_first_of_year, ld_fist_of_next_year) LOOP
  		ln_month_average := forecastCur.average;
	END LOOP;

	RETURN ln_month_average;

END getPlannedMonthAverage;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPlannedDayAverage
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_day_pc_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPlannedDayAverage(p_storage_id VARCHAR2,
							p_pc_id VARCHAR2,
							p_forecast_id VARCHAR2,
							p_first_of_month DATE)
RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_forecast(p_storage_id VARCHAR2, p_pc_id VARCHAR2, cp_forecast_id VARCHAR2, p_first_of_month DATE, p_first_of_next_month DATE)IS
SELECT avg(t.forecast_qty) average
FROM stor_day_fcst_pc_fcast t
WHERE t.object_id = p_storage_id AND
	t.profit_centre_id = p_pc_id AND
	t.forecast_id = cp_forecast_id AND
	t.daytime >= p_first_of_month AND
	t.daytime < p_first_of_next_month;

ln_day_average NUMBER := -1;
ld_fist_of_next_month DATE;

BEGIN
	ld_fist_of_next_month := add_months(p_first_of_month, 1);

	FOR forecastCur IN c_forecast (p_storage_id, p_pc_id, p_forecast_id, p_first_of_month, ld_fist_of_next_month) LOOP
  		ln_day_average := forecastCur.average;
	END LOOP;

	RETURN ln_day_average;

END getPlannedDayAverage;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPlannedYear                                  		                        --
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_mth_pc_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPlannedYear(p_storage_id VARCHAR2,
					p_pc_id VARCHAR2,
					p_forecast_id VARCHAR2,
					p_first_of_year DATE)
RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_forecast(p_storage_id VARCHAR2, p_pc_id VARCHAR2, cp_forecast_id VARCHAR2, p_first_of_year DATE, p_first_of_next_year DATE)IS
SELECT sum(t.forecast_qty) total
FROM stor_mth_fcst_pc_fcast t
WHERE t.object_id = p_storage_id AND
	t.profit_centre_id = p_pc_id AND
	t.forecast_id = cp_forecast_id AND
	t.daytime >= p_first_of_year AND
	t.daytime < p_first_of_next_year;

ln_year NUMBER := -1;
ld_fist_of_next_year DATE;

BEGIN
	ld_fist_of_next_year := add_months(p_first_of_year, 12);

	FOR forecastCur IN c_forecast (p_storage_id, p_pc_id, p_forecast_id, p_first_of_year, ld_fist_of_next_year) LOOP
  		ln_year := forecastCur.total;
	END LOOP;

	RETURN ln_year;

END getPlannedYear;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPlannedMonth
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_day_pc_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPlannedMonth(p_storage_id VARCHAR2,
					p_pc_id VARCHAR2,
					p_forecast_id VARCHAR2,
					p_first_of_month DATE)
RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_forecast(p_storage_id VARCHAR2, p_pc_id VARCHAR2, cp_forecast_id VARCHAR2, p_first_of_month DATE, p_first_of_next_month DATE)IS
SELECT sum(t.forecast_qty) total
FROM stor_day_fcst_pc_fcast t
WHERE t.object_id = p_storage_id AND
	t.profit_centre_id = p_pc_id AND
	t.forecast_id = cp_forecast_id AND
	t.daytime >= p_first_of_month AND
	t.daytime < p_first_of_next_month;

ln_month NUMBER := -1;
ld_fist_of_next_month DATE;

BEGIN
	ld_fist_of_next_month := add_months(p_first_of_month, 1);

	FOR forecastCur IN c_forecast (p_storage_id, p_pc_id, p_forecast_id, p_first_of_month, ld_fist_of_next_month) LOOP
  		ln_month := forecastCur.total;
	END LOOP;

	RETURN ln_month;

END getPlannedMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : apportionStorDay
-- Description    : Spreads the annual production forecast number on the months for selected month
--
-- Preconditions  : p_date must be first of the month
-- Postconditions : Uncommited changes
--
-- Using tables   : stor_day_fcst_fcast
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE apportionStorDay(p_date DATE,
                           p_forecast_month NUMBER,
                           p_storage_id VARCHAR2,
                           p_forecast_id VARCHAR2)
--</EC-DOC>
IS
 CURSOR c_exists(cp_storage_id VARCHAR2, cp_forecast_id VARCHAR2, cp_date DATE)IS
  SELECT t.FORECAST_QTY
   FROM stor_day_fcst_fcast t
   WHERE t.object_id = cp_storage_id AND
         t.forecast_id = cp_forecast_id AND
         t.daytime = cp_date;

 ln_rest				    NUMBER;
 ln_new_forecast 	  NUMBER;
 ln_day				      NUMBER;
 ln_date 			      DATE;
 ln_diff 			      NUMBER;
 ln_last_of_month 	DATE;
 lb_exists			    BOOLEAN := FALSE;
 lv_sql				      VARCHAR2(1000);

BEGIN
	-- find last date
	ln_date := p_date;
	ln_last_of_month := last_day(p_date);

	-- find days between
	ln_diff := ABS(ln_last_of_month - ln_date)+1;
	ln_rest := MOD(p_forecast_month, ln_diff);

	ln_new_forecast := p_forecast_month - ln_rest;
	ln_day := ln_new_forecast / ln_diff;

	FOR curExists IN c_exists(p_storage_id, p_forecast_id, p_date) LOOP
    lb_exists := TRUE;
	END LOOP;

	FOR Lcntr IN 1..ln_diff LOOP
    IF NOT lb_exists THEN
      -- delete existing if exists
      DELETE stor_day_fcst_fcast WHERE object_id = p_storage_id AND forecast_id = p_forecast_id AND daytime = ln_date;

    IF Lcntr = ln_diff THEN
        lv_sql := 'INSERT INTO DV_FCST_STOR_DAY_FORECAST (object_id, daytime, forecast_id, forecast_qty, created_by) VALUES ('''||p_storage_id||''', '''||ln_date||''', '''||p_forecast_id||''', '||(ln_day + ln_rest)||', ecdp_context.getAppUser)';
      ELSE
        lv_sql := 'INSERT INTO DV_FCST_STOR_DAY_FORECAST (object_id, daytime, forecast_id, forecast_qty, created_by) VALUES ('''||p_storage_id||''', '''||ln_date||''', '''||p_forecast_id||''', '||ln_day||', ecdp_context.getAppUser)';
      END IF;

    ELSE
      IF Lcntr = ln_diff THEN
        lv_sql := 'UPDATE DV_FCST_STOR_DAY_FORECAST set forecast_qty = '||(ln_day + ln_rest)||', last_updated_by = ecdp_context.getAppUser WHERE object_id = '''||p_storage_id||''' AND forecast_id = '''||p_forecast_id||''' AND daytime = '''||ln_date||'''';
      ELSE
        lv_sql := 'UPDATE DV_FCST_STOR_DAY_FORECAST set forecast_qty = '||ln_day||', last_updated_by = ecdp_context.getAppUser WHERE object_id = '''||p_storage_id||''' AND forecast_id = '''||p_forecast_id||''' AND daytime = '''||ln_date||'''';
      END IF;
    END IF;

    EXECUTE IMMEDIATE lv_sql;

    ln_date := ln_date + 1;
	END LOOP;

END apportionStorDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : apportionStorPcMonth
-- Description    : Spreads the annual production forecast number on the months and days for selected year
--
-- Preconditions  :
-- Postconditions : Uncommited changes
--
-- Using tables   : stor_mth_pc_forecast
-- Using functions: performApportionDay
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE apportionStorPcMonth(p_date DATE,
						p_forecast_year NUMBER,
						p_storage_id VARCHAR2,
            p_pc_id VARCHAR2,
						p_forecast_id VARCHAR2)
--</EC-DOC>
IS
ln_rest	NUMBER;
ln_new_forecast NUMBER;
ln_month	NUMBER;
ln_first_of_month DATE;

BEGIN
	ln_rest := MOD(p_forecast_year, 12);
	ln_new_forecast := p_forecast_year - ln_rest;
	ln_month := ln_new_forecast / 12;
	ln_first_of_month := p_date;

	FOR Lcntr IN 1..12
	LOOP
		-- delete existing if exists
		DELETE stor_mth_fcst_pc_fcast WHERE object_id = p_storage_id AND profit_centre_id = p_pc_id AND forecast_id = p_forecast_id AND daytime = trunc(ln_first_of_month, 'mm');

		IF Lcntr = 12 THEN
		    INSERT INTO stor_mth_fcst_pc_fcast (object_id, profit_centre_id, forecast_id, daytime, forecast_qty, created_by)
		    VALUES (p_storage_id, p_pc_id, p_forecast_id, ln_first_of_month, ln_month + ln_rest, ecdp_context.getAppUser);
			-- add days
			apportionStorPcDay(ln_first_of_month, ln_month + ln_rest, p_storage_id, p_pc_id, p_forecast_id);
		ELSE
		    INSERT INTO stor_mth_fcst_pc_fcast (object_id, profit_centre_id, forecast_id, daytime, forecast_qty, created_by)
		    VALUES (p_storage_id, p_pc_id, p_forecast_id, ln_first_of_month, ln_month, ecdp_context.getAppUser);
			-- add days
			apportionStorPcDay(ln_first_of_month, ln_month, p_storage_id, p_pc_id, p_forecast_id);
		END IF;

		ln_first_of_month := add_months(ln_first_of_month, 1);
	END LOOP;

END apportionStorPcMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : apportionStorPcDay
-- Description    : Spreads the annual production forecast number on the months for selected month
--
-- Preconditions  : p_date must be first of the month
-- Postconditions : Uncommited changes
--
-- Using tables   : stor_day_pc_forecast
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE apportionStorPcDay(p_date DATE,
					p_forecast_month NUMBER,
					p_storage_id VARCHAR2,
					p_pc_id VARCHAR2,
					p_forecast_id VARCHAR2)
--</EC-DOC>
IS
CURSOR	c_exists(cp_storage_id VARCHAR2, cp_pc_id VARCHAR2, cp_forecast_id VARCHAR2, cp_date DATE)IS
SELECT	t.forecast_qty
FROM 	stor_day_fcst_pc_fcast t
WHERE 	t.object_id = cp_storage_id AND
		t.profit_centre_id = cp_pc_id AND
		t.forecast_id = cp_forecast_id AND
		t.daytime = cp_date;

CURSOR c_class(cp_pc_id VARCHAR2) IS
  SELECT m.db_object_name, m.db_object_attribute
    FROM class_cnfg m
   INNER JOIN objects_table o
      ON o.class_name = m.class_name
   WHERE o.object_id = cp_pc_id;

ln_rest				NUMBER;
ln_new_forecast 	NUMBER;
ln_day				NUMBER;
ln_current          NUMBER;
ln_date 			DATE;
ln_diff 			NUMBER;
ln_last_of_month 	DATE;
lb_exists			BOOLEAN			:= FALSE;
lv_sql				VARCHAR2(1000);
lv_table            VARCHAR2(32);
lv_attribute        VARCHAR2(32);

BEGIN
	-- find last date
	ln_date := p_date;
	ln_last_of_month := last_day(p_date);

	-- find days between
	ln_diff := ABS(ln_last_of_month - ln_date)+1;
	ln_rest := MOD(p_forecast_month, ln_diff);

	ln_new_forecast := p_forecast_month - ln_rest;
	ln_day := ln_new_forecast / ln_diff;

    FOR one IN c_class(p_pc_id) LOOP
      lv_table := one.db_object_name;
      lv_attribute := one.db_object_attribute;
    END LOOP;

	FOR Lcntr IN 1..ln_diff
	LOOP

    IF Lcntr = ln_diff THEN
        ln_current := ln_day + ln_rest;
    ELSE
        ln_current := ln_day;
    END IF;

    DELETE stor_day_fcst_pc_fcast WHERE object_id = p_storage_id AND profit_centre_id = p_pc_id AND forecast_id = p_forecast_id AND daytime = ln_date;
    MERGE INTO stor_day_fcst_pc_fcast USING DUAL ON (object_id = p_storage_id AND profit_centre_id = p_pc_id AND forecast_id = p_forecast_id AND daytime = ln_date)
        WHEN MATCHED THEN UPDATE SET
            forecast_qty =  ln_current,
            last_updated_by = ecdp_context.getAppUser
        WHEN NOT MATCHED THEN INSERT (object_id, profit_centre_id, forecast_id, daytime, forecast_qty, created_by)
            VALUES (p_storage_id, p_pc_id, p_forecast_id, ln_date, ln_current, ecdp_context.getAppUser);

		-- insert/update account forecast

      ecdp_stor_fcst_forecast.aiuStorPcForecast(p_storage_id, p_forecast_id, p_pc_id, ln_date, NULL, ln_current, ecdp_context.getAppUser, lv_table, lv_attribute);

		-- aggregate storage forecast
		aggrForecast(p_storage_id, p_forecast_id, ln_date);

		ln_date := ln_date + 1;

	END LOOP;

END apportionStorPcDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStorPlannedDayAverage
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_day_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getStorPlannedDayAverage(p_storage_id VARCHAR2,
                                  p_forecast_id VARCHAR2,
                                  p_first_of_month DATE)
RETURN NUMBER
--</EC-DOC>
IS
 CURSOR c_forecast(p_storage_id VARCHAR2, cp_forecast_id VARCHAR2, p_first_of_month DATE, p_first_of_next_month DATE)IS
   SELECT avg(t.forecast_qty) average
   FROM stor_day_fcst_fcast t
   WHERE t.object_id = p_storage_id AND
         t.forecast_id = cp_forecast_id AND
         t.daytime >= p_first_of_month AND
         t.daytime < p_first_of_next_month;

 ln_day_average        NUMBER := -1;
 ld_fist_of_next_month DATE;

BEGIN
	ld_fist_of_next_month := add_months(p_first_of_month, 1);

	FOR forecastCur IN c_forecast (p_storage_id, p_forecast_id, p_first_of_month, ld_fist_of_next_month) LOOP
    ln_day_average := forecastCur.average;
	END LOOP;

	RETURN ln_day_average;
END getStorPlannedDayAverage;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStorPlannedMonth
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_day_fcst_fcast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getStorPlannedMonth(p_storage_id VARCHAR2,
                             p_forecast_id VARCHAR2,
                             p_first_of_month DATE)
RETURN NUMBER
--</EC-DOC>
IS
 CURSOR c_forecast(p_storage_id VARCHAR2, cp_forecast_id VARCHAR2, p_first_of_month DATE, p_first_of_next_month DATE)IS
   SELECT sum(t.forecast_qty) total
   FROM stor_day_fcst_fcast t
   WHERE t.object_id = p_storage_id AND
         t.forecast_id = cp_forecast_id AND
         t.daytime >= p_first_of_month AND
         t.daytime < p_first_of_next_month;

 ln_month              NUMBER := -1;
 ld_fist_of_next_month DATE;

BEGIN
	ld_fist_of_next_month := add_months(p_first_of_month, 1);

	FOR forecastCur IN c_forecast (p_storage_id, p_forecast_id, p_first_of_month, ld_fist_of_next_month) LOOP
    ln_month := forecastCur.total;
	END LOOP;

	RETURN ln_month;
END getStorPlannedMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aggrForecast
-- Description    :
--
-- Preconditions  :
-- Postconditions : Uncommited changes
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
PROCEDURE aggrForecast(p_object_id VARCHAR2,
						p_forecast_id VARCHAR2,
						p_daytime DATE)
--</EC-DOC>
IS

CURSOR c_official (cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_daytime DATE) IS
	SELECT	forecast_qty
	FROM	stor_day_fcst_fcast
	WHERE	object_id = cp_object_id
			AND forecast_id = cp_forecast_id
	      	AND daytime = cp_daytime;

CURSOR c_fcst (cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_daytime DATE) IS
	SELECT 	f.object_id, f.daytime, sum(f.forecast_qty) forecast_qty
	FROM 	stor_day_fcst_pc_fcast f
	WHERE	f.object_id = cp_object_id
			AND forecast_id = cp_forecast_id
	      	AND f.daytime = cp_daytime
	GROUP BY f.object_id, f.daytime;

	lv_exists       VARCHAR2(1):='N';

BEGIN
	FOR curForecast IN c_fcst (p_object_id,p_forecast_id,p_daytime)  LOOP
		FOR curOff IN c_official (p_object_id,p_forecast_id, p_daytime)  LOOP
			lv_exists := 'Y';
		END LOOP;

		IF lv_exists = 'Y' THEN
			UPDATE stor_day_fcst_fcast SET forecast_qty = curForecast.forecast_qty, last_updated_by = ecdp_context.getAppUser
			WHERE object_id = p_object_id AND forecast_id = p_forecast_id AND daytime = p_daytime;
		ELSE
			INSERT INTO stor_day_fcst_fcast (object_id, forecast_id, daytime, forecast_qty, created_by)
			VALUES (p_object_id, p_forecast_id, p_daytime, curForecast.forecast_qty, ecdp_context.getAppUser);
		END IF;
	END LOOP;

END aggrForecast;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : aggregateSubDay
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be production day. Daily record must exist before sub daily record
-- Postconditions :
--
-- Using tables   : stor_sub_day_fcst_fcast
--                  stor_day_fcst_fcast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities for the given day. The resulting
--                  quantity is written to the daily table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateSubDay(p_object_id VARCHAR2,
						  p_forecast_id VARCHAR2,
						  p_daytime   DATE,
						  p_xtra_qty  NUMBER DEFAULT 0)
--</EC-DOC>
 IS


	CURSOR c_sum_sub_day(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_daytime DATE) IS
		SELECT SUM(forecast_qty) forecast
		  FROM stor_sub_day_fcst_fcast
		 WHERE object_id = cp_object_id
		   AND production_day = cp_daytime
		   AND forecast_id = cp_forecast_id;

	CURSOR c_sum_sub_day2(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_daytime DATE) IS
		SELECT SUM(forecast_qty2) forecast2
		  FROM stor_sub_day_fcst_fcast
		 WHERE object_id = cp_object_id
		   AND production_day = cp_daytime
		   AND forecast_id = cp_forecast_id;

	CURSOR c_sum_sub_day3(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_daytime DATE) IS
		SELECT SUM(forecast_qty3) forecast3
		  FROM stor_sub_day_fcst_fcast
		 WHERE object_id = cp_object_id
		   AND production_day = cp_daytime
		   AND forecast_id = cp_forecast_id;

	ln_sum_sub_day NUMBER;

BEGIN
	IF (p_xtra_qty = 0) THEN
		FOR curSum IN c_sum_sub_day(p_object_id, p_forecast_id, p_daytime) LOOP
			ln_sum_sub_day := curSum.forecast;
		END LOOP;

		UPDATE stor_day_fcst_fcast
		   SET forecast_qty = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
		 WHERE object_id = p_object_id
		   AND daytime = p_daytime
		   AND forecast_id = p_forecast_id;

	ELSIF (p_xtra_qty = 1) THEN
		FOR curSum IN c_sum_sub_day2(p_object_id, p_forecast_id, p_daytime) LOOP
			ln_sum_sub_day := curSum.forecast2;
		END LOOP;

		UPDATE stor_day_fcst_fcast
		   SET forecast_qty2 = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
		 WHERE object_id = p_object_id
		   AND daytime = p_daytime
		   AND forecast_id = p_forecast_id;

	ELSIF (p_xtra_qty = 2) THEN
		FOR curSum IN c_sum_sub_day3(p_object_id, p_forecast_id, p_daytime) LOOP
			ln_sum_sub_day := curSum.forecast3;
		END LOOP;

		UPDATE stor_day_fcst_fcast
		   SET forecast_qty3 = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
		 WHERE object_id = p_object_id
		   AND daytime = p_daytime
		   AND forecast_id = p_forecast_id;

	END IF;
END aggregateSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aiuStorPcForecast
-- Description    : Splits the quantity in stor_day_fcst_fcast to LIFT_ACC_DAY_FCST_FCAST if possible. Using equity share.
--					(This procedure is not meant to be used when a real forecast/scenario module exist)
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STOR_DAY_FCST_PC_FCAST
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aiuStorPcForecast(p_storage_id VARCHAR2,
							p_forecast_id VARCHAR2,
							p_pc_id VARCHAR2,
							p_daytime DATE,
							p_old_qty NUMBER,
							p_new_qty NUMBER,
							p_user VARCHAR2 DEFAULT NULL,
              p_tablename VARCHAR2 DEFAULT NULL,
              p_versiontable VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

CURSOR c_classes (cp_pc_id VARCHAR2) IS
  SELECT m.db_object_name, m.db_object_attribute
    FROM class_cnfg m
   INNER JOIN class_dependency_cnfg d
      ON d.child_class = m.class_name
     AND d.dependency_type = 'IMPLEMENTS'
     AND d.parent_class = 'PROFIT_CENTRE'
   INNER JOIN objects_table o
      ON o.class_name = m.class_name
     AND o.object_id = cp_pc_id;

CURSOR c_la1 (cp_storage_id VARCHAR2, cp_company_id VARCHAR2, cp_pc_id VARCHAR2, cp_daytime DATE) IS
	SELECT a.object_id
	FROM lifting_account a
	WHERE a.storage_id = cp_storage_id
		AND a.company_id = cp_company_id
		AND profit_centre_id = cp_pc_id
		AND a.start_date <= cp_daytime
      	AND Nvl(a.end_date,cp_daytime+1) > cp_daytime;

CURSOR c_exist	(cp_la_id VARCHAR2, cp_forecast_id VARCHAR2, cp_daytime DATE) IS
	SELECT  forecast_qty

	FROM LIFT_ACC_DAY_FCST_FCAST
	WHERE object_id = cp_la_id
    AND forecast_id = cp_forecast_id
	AND daytime = cp_daytime;

	-- IMMEDIATE variables
	lv_pc		VARCHAR2(240); --Needed to test if COMMERCIAL ENTITY is profit centre.
	lv_from		VARCHAR2(240);
	lv_sql		VARCHAR2(1200);
	lv_date		VARCHAR2(100);
	--
	lv_cpy_id	VARCHAR2(32);
	lv_share	NUMBER;
	TYPE cv_type IS REF CURSOR;
	cv cv_type;
	lv_la_id	VARCHAR2(32);
	lv_insert	VARCHAR2(1)		:= 'Y';
	ln_qty		NUMBER;

BEGIN
	-- continue if it is forecast quantity that is inserted/updated
	IF Nvl(p_old_qty,-1) <> Nvl(p_new_qty,-1) THEN

		-- get companies and split %
    IF p_tablename IS NOT NULL AND p_versiontable IS NOT NULL THEN
        lv_from := p_versiontable;
        lv_pc   := p_tablename;
    ELSE
        FOR curClasses IN c_classes(p_pc_id) LOOP
          lv_from := curClasses.db_object_attribute;
          lv_pc := curClasses.db_object_name;
          --lv_where := 'AND r.profit_centre_id = '||curClasses.db_object_name||'.object_id';
          --lv_where := lv_where || ' AND '||curClasses.db_object_name||'.object_id = '||curClasses.db_object_attribute||'.object_id';
        END LOOP;
    END IF;


		lv_date := EcDp_DynSql.date_to_string(p_daytime);

		lv_sql := 'SELECT e.company_id, e.eco_share';
		lv_sql := lv_sql || ' FROM '||lv_from||', equity_share e, prosty_codes c ';
		-- This if statement allows COMMERCIAL_ENTITY to implement profit centre */
		IF lv_pc = 'COMMERCIAL_ENTITY' THEN
			lv_sql := lv_sql || ' WHERE '||lv_from||'.object_id = e.object_id';
		ELSE
			lv_sql := lv_sql || ' WHERE '||lv_from||'.commercial_entity_id = e.object_id';
		END IF;
		lv_sql := lv_sql || ' AND '||lv_from||'.object_id = :p_pc_id';
		lv_sql := lv_sql || ' AND c.CODE_TYPE=:code_type';
		lv_sql := lv_sql || ' AND e.fluid_type=c.code';
		lv_sql := lv_sql || ' AND upper(c.CODE_TEXT)=nvl(ec_product_version.product_type(ec_stor_version.product_id(:p_storage_id, :p_date,''<=''),:p_date,''<=''),''LIQUID'')';
		lv_sql := lv_sql || ' AND '||lv_from||'.daytime <= :p_date';
		lv_sql := lv_sql || ' AND Nvl('||lv_from||'.end_date, :p_date + 1) > :p_date';
		lv_sql := lv_sql || ' AND e.daytime <= :p_date';
		lv_sql := lv_sql || ' AND Nvl(e.end_date, :p_date +1) > :p_date';

		--EcDp_DynSql.WriteTempText('aiuStorPcForecast',lv_sql);

		BEGIN
         OPEN cv FOR lv_sql USING p_pc_id, 'EQUITY_PHASE', p_storage_id, p_daytime, p_daytime, p_daytime, p_daytime, p_daytime, p_daytime, p_daytime, p_daytime;
	          LOOP
		  	      FETCH cv INTO lv_cpy_id, lv_share;
			        EXIT WHEN cv%NOTFOUND;

	          		--EcDp_DynSql.WriteTempText('aiuStorPcForecast',lv_cpy_id||lv_share);

	          		-- Find lifting account with profit centre
	          		FOR curLa1 IN c_la1 (p_storage_id, lv_cpy_id, p_pc_id, p_daytime) LOOP
	          			lv_la_id := curLa1.object_id;
	          		END LOOP;

	          		--EcDp_DynSql.WriteTempText('aiuStorPcForecast',lv_la_id);

	          		IF lv_la_id IS NOT NULL THEN
                   MERGE INTO LIFT_ACC_DAY_FCST_FCAST USING DUAL ON (object_id = lv_la_id AND forecast_id = p_forecast_id AND daytime = p_daytime)
                            WHEN MATCHED THEN UPDATE SET forecast_qty = p_new_qty * (lv_share/100), last_updated_by = p_user
                            WHEN NOT MATCHED THEN INSERT (object_id, forecast_id, daytime, forecast_qty, created_by)
                                VALUES (lv_la_id, p_forecast_id, p_daytime, p_new_qty * (lv_share/100), p_user);
	          		ELSE
	          		-- Find lifting account without profit centre
	          		--  all profit centre values should be aggregated to the account
	          			lv_sql := 'SELECT sum(s.forecast_qty * (e.eco_share/100))';
                  lv_sql := lv_sql || ' FROM STOR_DAY_FCST_PC_FCAST s, '||lv_from||', equity_share e, prosty_codes c ';
                  lv_sql := lv_sql || ' WHERE '||lv_from||'.commercial_entity_id = e.object_id';
                  lv_sql := lv_sql || ' AND s.profit_centre_id = '||lv_from||'.object_id';
                  lv_sql := lv_sql || ' AND s.forecast_id = :forecast_id';
                  lv_sql := lv_sql || ' AND s.object_id = :storage_id';
                  lv_sql := lv_sql || ' AND c.CODE_TYPE=:code_type';
                  lv_sql := lv_sql || ' AND e.fluid_type=c.code';
                  lv_sql := lv_sql || ' AND upper(c.CODE_TEXT)=nvl(ec_product_version.product_type(ec_stor_version.product_id(:storage_id,:p_date,''<=''),:p_date,''<=''),''LIQUID'')';
                  lv_sql := lv_sql || ' AND s.daytime = :p_date';
                  lv_sql := lv_sql || ' AND '||lv_from||'.daytime <= s.daytime';
                  lv_sql := lv_sql || ' AND Nvl('||lv_from||'.end_date, s.daytime+1) > s.daytime';
                  lv_sql := lv_sql || ' AND e.daytime <= s.daytime';
                  lv_sql := lv_sql || ' AND Nvl(e.end_date, s.daytime+1) > s.daytime';
                  lv_sql := lv_sql || ' AND e.company_id = :cpy_id';


                --EcDp_DynSql.WriteTempText('aiuStorPcForecast',lv_sql);
                EXECUTE IMMEDIATE lv_sql INTO ln_qty USING p_forecast_id, p_storage_id, 'EQUITY_PHASE', p_storage_id, p_daytime, p_daytime, p_daytime, lv_cpy_id;

                IF lv_la_id is NULL THEN
                    select max(object_id) into lv_la_id from lifting_account a where a.COMPANY_ID = lv_cpy_id and a.storage_id = p_storage_id;
                END IF;

                MERGE INTO LIFT_ACC_DAY_FCST_FCAST USING DUAL ON (object_id = lv_la_id AND forecast_id = p_forecast_id AND daytime = p_daytime)
                    WHEN MATCHED THEN UPDATE SET forecast_qty = ln_qty, last_updated_by = p_user
                    WHEN NOT MATCHED THEN INSERT (object_id, forecast_id, daytime, forecast_qty, created_by)
                      VALUES (lv_la_id, p_forecast_id, p_daytime, ln_qty, p_user);

              END IF;
              lv_la_id := null;
              lv_insert := 'Y';
	        	END LOOP;
			   CLOSE cv;
      EXCEPTION WHEN OTHERS THEN
            EcDp_DynSql.WriteTempText('ERROR', 'AA: ' || SQLERRM);
    END;

	END IF;
END aiuStorPcForecast;

END EcDp_Stor_Fcst_Forecast;