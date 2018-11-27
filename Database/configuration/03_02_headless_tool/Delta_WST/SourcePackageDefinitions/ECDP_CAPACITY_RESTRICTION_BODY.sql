CREATE OR REPLACE PACKAGE BODY EcDp_Capacity_Restriction IS
/****************************************************************
** Package        :  EcDp_Capacity_Restriction; body part
**
** $Revision: 1.7 $
**
** Purpose        :  Handles capacity restriction operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  09.04.2008 Arief Zaki
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 2008-04-09  zakiiari  ECPD-7663: Initial version
** 2010-10-05  Leongwen  ECPD-14028 The STORAGE class does not support implementation of the OPERATIONAL_LOCATIONS
** 2012-06-13  sharawan  ECPD-19476: Added new functions getRateSchedVolPrLoc, getSubDayRateSchedVolPrLoc, getRestrictedCapacity,
**                       getSubDayRestrictedCapacity for GD.0062-Sub Daily Nomination Location Capacity.
** 2012-07-02  sharawan  ECPD-20882: Modified function getCapacityUom and getDesignCapacity to query from iv_operational_restriction.
**                       This will cater for objects that are not implementing operational_locations interface.
** 2016-03-31  sharawan  ECPD-34226: Added procedure deleteDailyRestrictionFcst to handle deletion of daily data for period data deleted.
** 2017-03-16  sharawan  ECPD-44077: Added procedure deleteDailyRestriction to handle deletion of daily data for period data deleted.
** 2017-09-18  farhaann  ECPD-48304: Modified updateDailyRestriction to get restricted_capacity from ue_capacity_restriction.updateDailyRestriction() function.
** 2017-09-26  farhaann  ECPD-48605: Modified updateDailyRestriction and deleteDailyRestriction
** 2017-10-06  farhaann  ECPD-48605: Modified updateDailyRestriction and deleteDailyRestriction
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCapacityUom
-- Description    : Retrieve configured capacity uom of an object
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
---------------------------------------------------------------------------------------------------
FUNCTION getCapacityUom(p_object_id    VARCHAR2,
						p_daytime      DATE,
						p_compare_oper VARCHAR2 DEFAULT '=') RETURN VARCHAR2
--</EC-DOC>
 IS
	lv2_class_name VARCHAR2(32);
	ln_retval      VARCHAR2(32);
  lv_sql         VARCHAR2(1000);

BEGIN
	lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);

  lv_sql := 'select capacity_uom from iv_operational_restriction where object_id  = ''' || p_object_id ||
	           ''' and class_name = ''' || lv2_class_name ||
	           ''' and ''' || p_daytime || '''' || ' >= daytime ' ||
	           ' and ''' || p_daytime || '''' || '  < nvl(end_date, ''' || (p_daytime+1) || ''')';

  EXECUTE IMMEDIATE lv_sql INTO ln_retval;

	RETURN ln_retval;
END getCapacityUom;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDesignCapacity
-- Description    : Retrieve configured design capacity of an object
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
---------------------------------------------------------------------------------------------------
FUNCTION getDesignCapacity(p_object_id    VARCHAR2,
						   p_daytime      DATE,
						   p_compare_oper VARCHAR2 DEFAULT '=') RETURN NUMBER
--</EC-DOC>
 IS
	lv2_class_name VARCHAR2(32);
	ln_retval      NUMBER;
  lv_sql         VARCHAR2(1000);

BEGIN
	lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);

  lv_sql := 'select design_capacity from iv_operational_restriction where object_id  = ''' || p_object_id ||
	           ''' and class_name = ''' || lv2_class_name ||
	           ''' and ''' || p_daytime || '''' || ' >= daytime ' ||
	           ' and ''' || p_daytime || '''' || '  < nvl(end_date, ''' || (p_daytime+1) || ''')';

  EXECUTE IMMEDIATE lv_sql INTO ln_retval;

	RETURN ln_retval;
END getDesignCapacity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRateSchedVolPrLoc
-- Description    : The function is generic will either get interrupted or firm capacity, the class_name will determine the stage
--                  to pick the value from  in this context scheduled or adjusted.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cntr_day_cap, contract_capacity
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getRateSchedVolPrLoc(p_location_id    VARCHAR2,
               p_daytime                       DATE,
               p_rate_schedule                 VARCHAR2,
               p_class_name                    VARCHAR2) RETURN NUMBER
--</EC-DOC>
 IS
  ln_aggregated_qty                            NUMBER;

  CURSOR c_vol_qty(cp_location_id VARCHAR2, cp_daytime DATE, cp_rate_schedule VARCHAR2, cp_class_name VARCHAR2) IS
  SELECT SUM(NVL(VOL_QTY, NVL(MASS_QTY, ENERGY_QTY))) sum_vol_qty
  FROM cntr_day_cap cpc, contract_capacity p
  WHERE cpc.object_id = p.object_id
  AND p.location_id = cp_location_id
  AND cpc.daytime = cp_daytime
  AND cpc.rate_schedule = cp_rate_schedule
  AND cpc.class_name = cp_class_name;

BEGIN

  FOR curVolQty IN c_vol_qty(p_location_id, p_daytime, p_rate_schedule, p_class_name) LOOP
      ln_aggregated_qty := curVolQty.sum_vol_qty;
  END LOOP;

  IF ln_aggregated_qty =0 THEN
     return null;
  else
     return ln_aggregated_qty;
  END IF;

END getRateSchedVolPrLoc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayRateSchedVolPrLoc
-- Description    : The function is generic will either get interrupted or firm capacity, the class_name will determine the stage
--                  to pick the value from  in this context scheduled or adjusted.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cntr_sub_day_cap, contract_capacity
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayRateSchedVolPrLoc(p_location_id    VARCHAR2,
               p_daytime                       DATE,
               p_rate_schedule                 VARCHAR2,
               p_class_name                    VARCHAR2) RETURN NUMBER
--</EC-DOC>
 IS
  ln_aggregated_qty                            NUMBER;

  CURSOR c_vol_qty(cp_location_id VARCHAR2, cp_daytime DATE, cp_rate_schedule VARCHAR2, cp_class_name VARCHAR2) IS
  SELECT SUM(NVL(VOL_QTY, NVL(MASS_QTY, ENERGY_QTY))) sum_vol_qty
  FROM cntr_sub_day_cap cpc, contract_capacity p
  WHERE cpc.object_id = p.object_id
  AND p.location_id = cp_location_id
  AND cpc.daytime = cp_daytime
  AND cpc.rate_schedule = cp_rate_schedule
  AND cpc.class_name = cp_class_name;

BEGIN

  FOR curVolQty IN c_vol_qty(p_location_id, p_daytime, p_rate_schedule, p_class_name) LOOP
      ln_aggregated_qty := curVolQty.sum_vol_qty;
  END LOOP;

  IF ln_aggregated_qty =0 THEN
     return null;
  else
     return ln_aggregated_qty;
  END IF;

END getSubDayRateSchedVolPrLoc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRestrictedCapacity
-- Description    : Get restricted_capacity column value from oploc_daily_restriction table. If it is
--                  not available, fallback to the design_capacity value from iv_nomination_location.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : oploc_daily_restriction
--
-- Using functions:
--
-- Configuration
-- required       : design_capacity attribute added to nomination_location class
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getRestrictedCapacity(p_object_id    VARCHAR2,
						   p_daytime      DATE,
						   p_compare_oper VARCHAR2 DEFAULT '=') RETURN NUMBER
--</EC-DOC>
 IS
	lv2_class_name         VARCHAR2(32);
	ln_restricted_cap      NUMBER;
  ln_retval              NUMBER;
  lv_sql                 VARCHAR2(1000);

BEGIN

  ln_restricted_cap := ec_oploc_daily_restriction.restricted_capacity(p_object_id, p_daytime, p_compare_oper);

  IF ln_restricted_cap IS NULL THEN
	   lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);
     lv_sql := 'select design_capacity from iv_nomination_location where object_id  = ''' || p_object_id ||
	           ''' and class_name = ''' || lv2_class_name ||
	           ''' and ''' || p_daytime || '''' || ' >= daytime ' ||
	           ' and ''' || p_daytime || '''' || '  < nvl(end_date, ''' || (p_daytime+1) || ''')';

     EXECUTE IMMEDIATE lv_sql INTO ln_retval;

  ELSE
     ln_retval := ln_restricted_cap;
  END IF;

	RETURN ln_retval;

END getRestrictedCapacity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDayRestrictedCapacity
-- Description    : Get restricted_capacity column value from oploc_daily_restriction table. If it is
--                  not available, fallback to the design_capacity value from iv_nomination_location.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : oploc_sub_day_restrict
--
-- Using functions:
--
-- Configuration
-- required       : design_capacity attribute added to nomination_location class
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getSubDayRestrictedCapacity(p_object_id    VARCHAR2,
						   p_daytime      DATE,
						   p_compare_oper VARCHAR2 DEFAULT '=') RETURN NUMBER
--</EC-DOC>
 IS
	lv2_class_name         VARCHAR2(32);
	ln_subday_rest_cap     NUMBER;
  ln_des_cap              NUMBER;
  ln_retval              NUMBER;
  lv_sql                 VARCHAR2(1000);

BEGIN

  ln_subday_rest_cap := ec_oploc_sub_day_restrict.restricted_capacity(p_object_id, p_daytime, p_compare_oper);

  IF ln_subday_rest_cap IS NULL THEN
	   lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);
     lv_sql := 'select design_capacity from iv_nomination_location where object_id  = ''' || p_object_id ||
	           ''' and class_name = ''' || lv2_class_name ||
	           ''' and ''' || p_daytime || '''' || ' >= daytime ' ||
	           ' and ''' || p_daytime || '''' || '  < nvl(end_date, ''' || (p_daytime+1) || ''')';

     EXECUTE IMMEDIATE lv_sql INTO ln_des_cap;
     ln_retval := ln_des_cap/24;

  ELSE
     ln_retval := ln_subday_rest_cap;
  END IF;

	RETURN ln_retval;

END getSubDayRestrictedCapacity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : updateDailyRestriction
-- Description    : Based on the period restriction, daily restriction will be created for the object within the pre-defined period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OPLOC_PERIOD_RESTRICTION, OPLOC_DAY_RESTRICTION
--
-- Using functions: - Ecdp_Productionday.getProductionDay
--                  - Ecdp_Date_Time.getDateDiff
--                  - Ecdp_Timestamp.getNumHours
--
-- Configuration
-- required       :
--
-- Behaviour      :
--                If period is from 2003-1-1 10:00 till 2003-1-3 11:00 and production day is at 09:00
--                - Existing daily record for the same period will be removed
--                - 3 daily records will be created where each represent 1 production day
--                - On 2003-1-1; it will run with normal capacity for 1 hr. The remaining 23 hrs will be under restricted capacity
--                - On 2003-1-2; it will run under restricted capacity for whole day (24 hrs)
--                - On 2003-1-3; it will run under restricted capacity for 2 hrs. The remaining 22 hrs will be under normal capacity
---------------------------------------------------------------------------------------------------
PROCEDURE updateDailyRestriction(p_object_id      VARCHAR2,
								 p_old_start_date DATE,
								 p_new_start_date DATE,
								 p_old_end_date   DATE,
								 p_new_end_date   DATE)
--</EC-DOC>
 IS
	ld_period_first_date DATE;
	ld_period_last_date  DATE;
	ld_daytime           DATE;
	ld_pd_daytime        DATE;

	ln_hrs_diff    NUMBER;
	ln_hrs_total   NUMBER;
	ln_hrs_balance NUMBER;

	ln_design_cap   NUMBER;
	ln_restrict_cap NUMBER;
	ln_total_cap    NUMBER;

	lv2_rest_type VARCHAR2(32);
	lv2_class_name VARCHAR2(32);

BEGIN
	lv2_rest_type := ec_oploc_period_restriction.restriction_type(p_object_id, p_new_start_date);
    lv2_class_name := ecdp_objects.GetObjClassName(p_object_id);
	-- 1st day should be productionDay of start_date
	ld_period_first_date := Ecdp_Productionday.getProductionDay(lv2_class_name, p_object_id, p_new_start_date);

	-- last day should be productionDay of last_date
	ld_period_last_date := Ecdp_Productionday.getProductionDay(lv2_class_name, p_object_id, p_new_end_date);

	-- initial counter value
	ld_daytime := ld_period_first_date;

	-- delete existing daily
	DELETE FROM oploc_daily_restriction c
		 WHERE c.object_id = p_object_id
		   AND c.daytime >= Ecdp_Productionday.getProductionDay(lv2_class_name, p_object_id, p_old_start_date)
		   AND c.daytime <= Ecdp_Productionday.getProductionDay(lv2_class_name, p_object_id, p_old_end_date)
		   AND NOT EXISTS
			   (SELECT 'X'
				  FROM oploc_period_restriction s
				 WHERE s.object_id = p_object_id
				   AND (c.daytime BETWEEN Ecdp_Productionday.getProductionDay(lv2_class_name,p_object_id,s.start_date)
									  AND Ecdp_Productionday.getProductionDay(lv2_class_name,p_object_id,s.end_date))
				   AND (Ecdp_Productionday.getProductionDayStart(lv2_class_name,p_object_id,c.daytime) <> s.end_date));

	WHILE ld_daytime < ld_period_last_date + 1 LOOP
		-- Scenario 1: start_date and end_date fall into same day
		IF ld_period_first_date = ld_period_last_date THEN
			ln_hrs_diff    := Ecdp_Date_Time.getDateDiff('HH', p_new_start_date, p_new_end_date);
			ln_hrs_total   := Ecdp_Timestamp.getNumHours(lv2_class_name, p_object_id, ld_period_first_date);
			ln_hrs_balance := ln_hrs_total - ln_hrs_diff;

			ln_design_cap   := (getDesignCapacity(p_object_id, ld_period_first_date, '<=') / ln_hrs_total) *
							   ln_hrs_balance;
			ln_restrict_cap := (nvl(ec_oploc_period_restriction.restricted_capacity(p_object_id, p_new_start_date),
									getDesignCapacity(p_object_id, ld_period_first_date, '<=')) / ln_hrs_total) *
							   ln_hrs_diff;

		ELSE
			-- Scenario 2: different days
			IF ld_daytime = ld_period_first_date THEN
				ln_hrs_total  := Ecdp_Timestamp.getNumHours(lv2_class_name, p_object_id, ld_daytime);
				ld_pd_daytime := ld_daytime +
								 (Ecdp_Productionday.getProductionDayOffset(lv2_class_name, p_object_id, p_new_start_date) / 24);

				ln_hrs_diff    := Ecdp_Date_Time.getDateDiff('HH', ld_pd_daytime, p_new_start_date); -- hrs_diff -> design
				ln_hrs_balance := ln_hrs_total - ln_hrs_diff; -- hrs_bal -> restricted

				ln_design_cap   := (getDesignCapacity(p_object_id, ld_period_first_date, '<=') / ln_hrs_total) *
								   ln_hrs_diff;
				ln_restrict_cap := (nvl(ec_oploc_period_restriction.restricted_capacity(p_object_id,
																						p_new_start_date),
										getDesignCapacity(p_object_id, ld_period_first_date, '<=')) / ln_hrs_total) *
								   ln_hrs_balance;

			ELSIF ld_daytime = ld_period_last_date THEN
				ln_hrs_diff:= TO_CHAR(p_new_end_date, 'HH24');
				ln_hrs_balance := ecdp_productionday.getproductiondayoffset(lv2_class_name,p_object_id,p_new_end_date);
				IF ln_hrs_diff = ln_hrs_balance THEN
					EXIT;
				ELSE
				ln_hrs_total  := Ecdp_Timestamp.getNumHours(lv2_class_name, p_object_id, ld_daytime);
				ld_pd_daytime := ld_daytime +
								 (Ecdp_Productionday.getProductionDayOffset(lv2_class_name, p_object_id, p_new_end_date) / 24);

				ln_hrs_diff    := Ecdp_Date_Time.getDateDiff('HH', ld_pd_daytime, p_new_end_date); -- hrs_diff -> restricted
				ln_hrs_balance := ln_hrs_total - ln_hrs_diff; -- hrs_bal -> design

				ln_design_cap   := (getDesignCapacity(p_object_id, ld_period_last_date, '<=') / ln_hrs_total) *
								   ln_hrs_balance;
				ln_restrict_cap := (nvl(ec_oploc_period_restriction.restricted_capacity(p_object_id,
																						p_new_start_date),
										getDesignCapacity(p_object_id, ld_period_last_date, '<=')) / ln_hrs_total) *
								   ln_hrs_diff;
				END IF;
			ELSE
				--whole day should be having restricted capacity
				ln_design_cap := NULL;
				-- unless NULL restricted capacity, resort to design capacity
				ln_restrict_cap := nvl(ec_oploc_period_restriction.restricted_capacity(p_object_id,
																					   p_new_start_date),
									   getDesignCapacity(p_object_id, ld_daytime, '<='));

			END IF;
		END IF;

		ln_total_cap := nvl(ue_capacity_restriction.updateDailyRestriction(p_object_id,p_old_start_date,p_new_start_date,p_old_end_date,p_new_end_date),(nvl(ln_design_cap, 0) + nvl(ln_restrict_cap, 0)));

		MERGE INTO oploc_daily_restriction d
        USING (SELECT 1 FROM CTRL_DB_VERSION) m
        ON ( d.object_id = p_object_id AND d.daytime= ld_daytime)
        WHEN NOT MATCHED THEN
          INSERT (d.object_id, d.daytime, d.restricted_capacity, d.restriction_type, d.created_by)
          VALUES (p_object_id, ld_daytime, ln_total_cap, lv2_rest_type, ecdp_context.getAppUser);

		ld_daytime := ld_daytime + 1; -- increase by 1 day
	END LOOP;

END updateDailyRestriction;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : updateDailyRestrictionFcst
-- Description    : Based on the period restriction, daily restriction will be created for the object within the pre-defined period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_OPLOC_DAY_RESTRICT, FCST_OPLOC_PERIOD_RESTR
--
-- Using functions: - Ecdp_Productionday.getProductionDay
--                  - Ecdp_Date_Time.getDateDiff
--                  - Ecdp_Timestamp.getNumHours
--
-- Configuration
-- required       :
--
-- Behaviour      :
--                If period is from 2003-1-1 10:00 till 2003-1-3 11:00 and production day is at 09:00
--                - Existing daily record for the same period will be removed
--                - 3 daily records will be created where each represent 1 production day
--                - On 2003-1-1; it will run with normal capacity for 1 hr. The remaining 23 hrs will be under restricted capacity
--                - On 2003-1-2; it will run under restricted capacity for whole day (24 hrs)
--                - On 2003-1-3; it will run under restricted capacity for 2 hrs. The remaining 22 hrs will be under normal capacity
---------------------------------------------------------------------------------------------------
PROCEDURE updateDailyRestrictionFcst(p_object_id      VARCHAR2,
									 p_forecast_id    VARCHAR2,
									 p_old_start_date DATE,
									 p_new_start_date DATE,
									 p_old_end_date   DATE,
									 p_new_end_date   DATE)
--</EC-DOC>
 IS
	ld_period_first_date DATE;
	ld_period_last_date  DATE;
	ld_daytime           DATE;
	ld_pd_daytime        DATE;

	ln_hrs_diff    NUMBER;
	ln_hrs_total   NUMBER;
	ln_hrs_balance NUMBER;

	ln_design_cap   NUMBER;
	ln_restrict_cap NUMBER;
	ln_total_cap    NUMBER;

	lv2_rest_type VARCHAR2(32);

BEGIN
	lv2_rest_type := ec_FCST_OPLOC_PERIOD_RESTR.restriction_type(p_object_id, p_forecast_id, p_new_start_date);

	-- 1st day should be productionDay of start_date
	ld_period_first_date := Ecdp_Productionday.getProductionDay(NULL, p_object_id, p_new_start_date);

	-- last day should be productionDay of last_date
	ld_period_last_date := Ecdp_Productionday.getProductionDay(NULL, p_object_id, p_new_end_date);

	-- initial counter value
	ld_daytime := ld_period_first_date;

	-- delete existing daily
	DELETE FROM FCST_OPLOC_DAY_RESTRICT p
	 WHERE p.object_id = p_object_id
	   AND p.forecast_id = p_forecast_id
	   AND p.daytime >= Ecdp_Productionday.getProductionDay(NULL, p_object_id, p_old_start_date)
	   AND p.daytime <= Ecdp_Productionday.getProductionDay(NULL, p_object_id, p_old_end_date);

	WHILE ld_daytime < ld_period_last_date + 1 LOOP
		-- Scenario 1: start_date and end_date fall into same day
		IF ld_period_first_date = ld_period_last_date THEN
			ln_hrs_diff    := Ecdp_Date_Time.getDateDiff('HH', p_new_start_date, p_new_end_date);
			ln_hrs_total   := Ecdp_Timestamp.getNumHours(NULL, p_object_id, ld_period_first_date);
			ln_hrs_balance := ln_hrs_total - ln_hrs_diff;

			ln_design_cap   := (getDesignCapacity(p_object_id, ld_period_first_date, '<=') / ln_hrs_total) *
							   ln_hrs_balance;
			ln_restrict_cap := (nvl(ec_FCST_OPLOC_PERIOD_RESTR.restricted_capacity(p_object_id,
																				   p_forecast_id,
																				   p_new_start_date),
									getDesignCapacity(p_object_id, ld_period_first_date, '<=')) / ln_hrs_total) *
							   ln_hrs_diff;

		ELSE
			-- Scenario 2: different days
			IF ld_daytime = ld_period_first_date THEN
				ln_hrs_total  := Ecdp_Timestamp.getNumHours(NULL, p_object_id, ld_daytime);
				ld_pd_daytime := ld_daytime +
								 (Ecdp_Productionday.getProductionDayOffset(NULL, p_object_id, p_new_start_date) / 24);

				ln_hrs_diff    := Ecdp_Date_Time.getDateDiff('HH', ld_pd_daytime, p_new_start_date); -- hrs_diff -> design
				ln_hrs_balance := ln_hrs_total - ln_hrs_diff; -- hrs_bal -> restricted

				ln_design_cap   := (getDesignCapacity(p_object_id, ld_period_first_date, '<=') / ln_hrs_total) *
								   ln_hrs_diff;
				ln_restrict_cap := (nvl(ec_FCST_OPLOC_PERIOD_RESTR.restricted_capacity(p_object_id,
																					   p_forecast_id,
																					   p_new_start_date),
										getDesignCapacity(p_object_id, ld_period_first_date, '<=')) / ln_hrs_total) *
								   ln_hrs_balance;

			ELSIF ld_daytime = ld_period_last_date THEN
				ln_hrs_total  := Ecdp_Timestamp.getNumHours(NULL, p_object_id, ld_daytime);
				ld_pd_daytime := ld_daytime +
								 (Ecdp_Productionday.getProductionDayOffset(NULL, p_object_id, p_new_end_date) / 24);

				ln_hrs_diff    := Ecdp_Date_Time.getDateDiff('HH', ld_pd_daytime, p_new_end_date); -- hrs_diff -> restricted
				ln_hrs_balance := ln_hrs_total - ln_hrs_diff; -- hrs_bal -> design

				ln_design_cap   := (getDesignCapacity(p_object_id, ld_period_last_date, '<=') / ln_hrs_total) *
								   ln_hrs_balance;
				ln_restrict_cap := (nvl(ec_FCST_OPLOC_PERIOD_RESTR.restricted_capacity(p_object_id,
																					   p_forecast_id,
																					   p_new_start_date),
										getDesignCapacity(p_object_id, ld_period_last_date, '<=')) / ln_hrs_total) *
								   ln_hrs_diff;

			ELSE
				--whole day should be having restricted capacity
				ln_design_cap := NULL;
				-- unless NULL restricted capacity, resort to design capacity
				ln_restrict_cap := nvl(ec_FCST_OPLOC_PERIOD_RESTR.restricted_capacity(p_object_id,
																					  p_forecast_id,
																					  p_new_start_date),
									   getDesignCapacity(p_object_id, ld_daytime, '<='));

			END IF;
		END IF;

		ln_total_cap := nvl(ln_design_cap, 0) + nvl(ln_restrict_cap, 0);

		INSERT INTO FCST_OPLOC_DAY_RESTRICT
			(object_id, forecast_id, daytime, restricted_capacity, restriction_type, created_by)
		VALUES
			(p_object_id, p_forecast_id, ld_daytime, ln_total_cap, lv2_rest_type, ecdp_context.getAppUser);

		ld_daytime := ld_daytime + 1; -- increase by 1 day
	END LOOP;

END updateDailyRestrictionFcst;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : deleteDailyRestriction
-- Description    : Based on the period restriction, daily restriction will be deleted for the object within the pre-defined period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : oploc_daily_restriction, oploc_period_restriction
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      : Existing daily record for the same period will be removed
---------------------------------------------------------------------------------------------------
PROCEDURE deleteDailyRestriction(p_object_id      VARCHAR2,
							     p_old_start_date DATE,
								 p_old_end_date   DATE)
--</EC-DOC>
 IS

  lv2_class_name VARCHAR2(32);
  ld_old_start_date DATE;
  ld_old_end_date DATE;

BEGIN
  lv2_class_name := ecdp_objects.GetObjClassName(p_object_id);
  ld_old_start_date := Ecdp_Productionday.getProductionDay(lv2_class_name, p_object_id, p_old_start_date);
  ld_old_end_date := Ecdp_Productionday.getProductionDay(lv2_class_name, p_object_id, p_old_end_date);

  -- delete existing daily
  DELETE FROM oploc_daily_restriction c
     WHERE c.object_id = p_object_id
       AND c.daytime >= ld_old_start_date
       AND c.daytime <= ld_old_end_date
       AND NOT EXISTS
           (SELECT 'X'
              FROM oploc_period_restriction s
             WHERE s.object_id = p_object_id
               AND (c.daytime BETWEEN Ecdp_Productionday.getProductionDay(lv2_class_name,p_object_id,s.start_date)
                                  AND Ecdp_Productionday.getProductionDay(lv2_class_name,p_object_id,s.end_date))
               AND (Ecdp_Productionday.getProductionDayStart(lv2_class_name,p_object_id,c.daytime) <> s.end_date));

END deleteDailyRestriction;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : deleteDailyRestrictionFcst
-- Description    : Based on the period restriction, daily restriction will be deleted for the object within the pre-defined period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_OPLOC_DAY_RESTRICT
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      : Existing daily record for the same period will be removed
---------------------------------------------------------------------------------------------------
PROCEDURE deleteDailyRestrictionFcst(p_object_id      VARCHAR2,
									 p_forecast_id    VARCHAR2,
									 p_old_start_date DATE,
									 p_old_end_date   DATE)
--</EC-DOC>
 IS

BEGIN
	-- delete existing daily
	DELETE FROM FCST_OPLOC_DAY_RESTRICT p
	 WHERE p.object_id = p_object_id
	   AND p.forecast_id = p_forecast_id
	   AND p.daytime >= Ecdp_Productionday.getProductionDay(NULL, p_object_id, p_old_start_date)
	   AND p.daytime <= Ecdp_Productionday.getProductionDay(NULL, p_object_id, p_old_end_date);

END deleteDailyRestrictionFcst;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriod
-- Description    : Validate that the new entry should not overlap with existing period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OPLOC_PERIOD_RESTRICTION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateOverlappingPeriod(p_object_id      VARCHAR2,
									p_old_start_date DATE,
									p_new_start_date DATE,
									p_old_end_date   DATE,
									p_new_end_date   DATE)
--</EC-DOC>
 IS

	CURSOR c_overlapping_period(cp_object_id VARCHAR2, cp_start_date DATE, cp_end_date DATE) IS
		SELECT 'X'
		  FROM oploc_period_restriction t
		 WHERE t.object_id = cp_object_id
		   AND ((t.start_date <= cp_start_date AND cp_start_date < t.end_date) OR
			   (t.start_date < cp_end_date AND cp_end_date <= t.end_date) OR
			   (cp_start_date < t.end_date and t.end_date <= cp_end_date));

	CURSOR c_overlapping_per_exclude_curr(cp_object_id VARCHAR2, cp_old_start_date DATE, cp_start_date DATE, cp_end_date DATE) IS
		SELECT 'X'
		  FROM oploc_period_restriction t
		 WHERE t.object_id = cp_object_id
		   AND t.start_date <> cp_old_start_date
		   AND ((t.start_date <= cp_start_date AND cp_start_date < t.end_date) OR
			   (t.start_date < cp_end_date AND cp_end_date <= t.end_date) OR
			   (cp_start_date < t.end_date and t.end_date <= cp_end_date));

BEGIN

	IF p_old_start_date IS NULL AND p_old_end_date IS NULL THEN
		-- Check during initial insert
		FOR cur_period IN c_overlapping_period(p_object_id, p_new_start_date, p_new_end_date) LOOP
			RAISE_APPLICATION_ERROR(-20530, 'Not allowed to have overlapping period restriction.');
		END LOOP;
	ELSE
		-- Check during update only if dates differed
		IF (p_old_start_date <> p_new_start_date) OR (p_old_end_date <> p_new_end_date) THEN
			FOR cur_period IN c_overlapping_per_exclude_curr(p_object_id,
															 p_old_start_date,
															 p_new_start_date,
															 p_new_end_date) LOOP
				RAISE_APPLICATION_ERROR(-20530, 'Not allowed to have overlapping period restriction.');
			END LOOP;
		END IF;
	END IF;

END validateOverlappingPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateOverlappingPeriodFcst
-- Description    : Validate that the new entry should not overlap with existing period
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_OPLOC_PERIOD_RESTR
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateOverlappingPeriodFcst(p_object_id      VARCHAR2,
										p_forecast_id    VARCHAR2,
										p_old_start_date DATE,
										p_new_start_date DATE,
										p_old_end_date   DATE,
										p_new_end_date   DATE)
--</EC-DOC>
 IS

	CURSOR c_overlapping_period(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_start_date DATE, cp_end_date DATE) IS
		SELECT 'X'
		  FROM FCST_OPLOC_PERIOD_RESTR t
		 WHERE t.object_id = cp_object_id
		   AND t.forecast_id = cp_forecast_id
		   AND ((t.start_date <= cp_start_date AND cp_start_date < t.end_date) OR
			   (t.start_date < cp_end_date AND cp_end_date < t.end_date) OR
			   (cp_start_date < t.end_date and t.end_date < cp_end_date));

	CURSOR c_overlapping_per_exclude_curr(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_old_start_date DATE, cp_start_date DATE, cp_end_date DATE) IS
		SELECT 'X'
		  FROM FCST_OPLOC_PERIOD_RESTR t
		 WHERE t.object_id = cp_object_id
		   AND t.forecast_id = cp_forecast_id
		   AND t.start_date <> cp_old_start_date
		   AND ((t.start_date <= cp_start_date AND cp_start_date < t.end_date) OR
			   (t.start_date < cp_end_date AND cp_end_date < t.end_date) OR
			   (cp_start_date < t.end_date and t.end_date < cp_end_date));

BEGIN

	IF p_old_start_date IS NULL AND p_old_end_date IS NULL THEN
		-- Check during initial insert
		FOR cur_period IN c_overlapping_period(p_object_id, p_forecast_id, p_new_start_date, p_new_end_date) LOOP
			RAISE_APPLICATION_ERROR(-20530, 'Not allowed to have overlapping period restriction.');
		END LOOP;
	ELSE
		-- Check during update only if dates differed
		IF (p_old_start_date <> p_new_start_date) OR (p_old_end_date <> p_new_end_date) THEN
			FOR cur_period IN c_overlapping_per_exclude_curr(p_object_id,
															 p_forecast_id,
															 p_old_start_date,
															 p_new_start_date,
															 p_new_end_date) LOOP
				RAISE_APPLICATION_ERROR(-20530, 'Not allowed to have overlapping period restriction.');
			END LOOP;
		END IF;
	END IF;

END validateOverlappingPeriodFcst;

END EcDp_Capacity_Restriction;