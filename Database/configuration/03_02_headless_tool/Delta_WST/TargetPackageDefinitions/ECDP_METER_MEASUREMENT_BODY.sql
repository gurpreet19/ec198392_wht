CREATE OR REPLACE PACKAGE BODY EcDp_Meter_Measurement IS
/******************************************************************************
** Package        :  EcDp_Meter_Measurement, body part
**
** Purpose        :  Find and work with meter measurement data
**
** Documentation  :  www.energy-components.com
**
** Created        :  11.02.2009 Olav Nærland
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
**18.05.2011   lauuufus ECPD-17232, change table name meter_day_measurement to meter_measurement
** 07.12.2011  leeeewei ECPD-19090: Added new function setMeterCompStatus
** 08.12.2011  leeeewei ECPD-19090: Modified setMeterCompStatus
** 19.12.2011  leeeewei ECPD-19090: Use correct EC Codes when retrieving status value
** 03.01.2012  leeeewei ECPD-19090: Modified setMeterCompStatus to only update when there is changes on record status
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNumberOfSubDailyRecords
-- Description    : Returns the number of sub-daily (hourly) delivery records for the given production day.
--
-- Preconditions  : p_date should be a logical production day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : meter_sub_day_meas
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
  p_object_id     VARCHAR2,
  p_date          DATE
)
RETURN INTEGER
--</EC-DOC>
IS
   li_cnt   INTEGER;
BEGIN
   SELECT COUNT(*) INTO li_cnt
   FROM meter_sub_day_meas
   WHERE object_id = p_object_id
   AND production_day = p_date;

   RETURN li_cnt;
END getNumberOfSubDailyRecords;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNumberOfApprovedDeliveries
-- Description    : Finds the number of approved daily meter measurement records.
--
-- Preconditions  : p_daytime should be a logical production day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : meter_measurement
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the number of daily data records with record status 'A'
--
---------------------------------------------------------------------------------------------------
FUNCTION getNumberOfApprovedDeliveries(
  p_object_id  VARCHAR2,
  p_daytime            DATE
)
RETURN INTEGER
--</EC-DOC>
IS
   li_cnt   INTEGER;
BEGIN
   SELECT COUNT(*) INTO li_cnt
   FROM meter_measurement
   WHERE daytime = p_daytime
   AND record_status = 'A'
   AND object_id  = p_object_id;

   RETURN li_cnt;
END getNumberOfApprovedDeliveries;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : aggregateSubDailyToDaily
-- Description    : Sums up hourly quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be a logical production day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : meter_sub_day_meas
--                  meter_measurement
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities (VOL_QTY, MASS_QTY AND ENERGY_QTY) for the given day. The resulting
--                  quantity is written to the daily quantity table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateSubDailyToDaily(
	p_object_id   	VARCHAR2,
	p_daytime             	DATE,
	p_user					VARCHAR2
)
--</EC-DOC>
IS
	ln_sum_vol_qty    NUMBER :=0;
	ln_sum_mass_qty	NUMBER :=0;
	ln_sum_energy_qty	NUMBER :=0;

	CURSOR c_sum_vol_qty IS
		SELECT SUM(vol_qty) AS vol_result, SUM(mass_qty) AS mass_result, SUM(energy_qty) AS energy_result
		FROM meter_sub_day_meas
		WHERE object_id = p_object_id AND production_day = p_daytime;
BEGIN
	FOR curNomSum IN c_sum_vol_qty LOOP
		ln_sum_vol_qty := curNomSum.vol_result;
		ln_sum_mass_qty := curNomSum.mass_result;
		ln_sum_energy_qty := curNomSum.energy_result;
	END LOOP;

	UPDATE meter_measurement
	SET vol_qty = ln_sum_vol_qty, mass_qty = ln_sum_mass_qty, energy_qty = ln_sum_energy_qty, last_updated_by = p_user
	WHERE object_id = p_object_id AND daytime = p_daytime;

  IF SQL%ROWCOUNT = 0 THEN
     INSERT INTO METER_MEASUREMENT (Object_Id, Daytime, Vol_Qty, Mass_Qty, Energy_Qty, Created_By)
     VALUES( p_object_id, p_daytime, ln_sum_vol_qty, ln_sum_mass_qty, ln_sum_energy_qty, p_user);

  END IF;

END aggregateSubDailyToDaily;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createMeterDayHours
-- Description    : Generates sub-daily data records for a day.
--
-- Preconditions  : p_daytime should be a logical production day(zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : meter_measurement
--                  meter_sub_day_meas
--
-- Using functions: getNumberOfApprovedDeliveries
--                  getNumberOfSubDailyRecords
--
-- Configuration
-- required       :
--
-- Behaviour      : First checks if the user has suffucient priviliges if the day has been approved.
--                  Then generates any missing hourly rows for the given production day, taking day
--                  offsets and daylight savings time transitions into account.
--                  If no sub-daily records already existed then the daily quantity is distributed
--                  evenly to the new records. Otherwise, any new records get zero quantity.
--
---------------------------------------------------------------------------------------------------
PROCEDURE createMeterDayHours(
	p_object_id	VARCHAR2,
	p_daytime       DATE,
	p_curr_user		VARCHAR2,
	p_accessLevel	INTEGER
)
--</EC-DOC>
IS
	li_pointer			     INTEGER;
	li_record_count 	   INTEGER;

	ln_daily_vol_qty 		 NUMBER := 0;
	ln_daily_mass_qty 	 NUMBER := 0;
	ln_daily_energy_qty  NUMBER := 0;

  lv2_pdd_object_id    VARCHAR2(32);
  lv2_freq_code        VARCHAR2(32);


	ln_hourly_vol_qty    NUMBER :=0;
	ln_hourly_mass_qty   NUMBER :=0;
	ln_hourly_energy_qty NUMBER :=0;

	lr_daytime EcDp_Date_Time.Ec_Unique_Daytimes;

	CURSOR c_day (cp_object_id VARCHAR2, cp_daytime DATE) IS
		SELECT vol_qty, mass_qty, energy_qty
		FROM meter_measurement
		WHERE object_id = cp_object_id
			AND daytime = cp_daytime;

BEGIN
	IF p_object_id IS NULL or p_daytime iS NULL THEN
		RAISE_APPLICATION_ERROR(-20103,'createMeterDayHours requires p_object_id and p_daytime to be a non-NULL value.');
	END IF;

   IF getNumberOfApprovedDeliveries(p_object_id,p_daytime) > 0 AND p_accessLevel<60 THEN
      RAISE_APPLICATION_ERROR(-20509,'Unsufficient priviliges to generate hourly records for '||to_char(p_daytime,'yyyy-mm-dd'));
   END IF;

  lv2_pdd_object_id := Nvl(ec_meter_version.production_day_id(p_object_id,p_daytime,'<='),Ecdp_Date_Time.getDefaultProdDayDefinition(p_daytime));
  lv2_freq_code := '1H';

  lr_daytime := Ecdp_Date_Time.getProductionDayDaytimes(lv2_pdd_object_id,lv2_freq_code,p_daytime);

	FOR curNom IN c_day(p_object_id, p_daytime) LOOP
		ln_daily_vol_qty := curNom.vol_qty;
		ln_daily_mass_qty := curNom.mass_qty;
		ln_daily_energy_qty := curNom.energy_qty;
	END LOOP;

	--Only inserting calculated values for hourly quantity when there are no records from before
	IF getNumberOfSubDailyRecords(p_object_id,p_daytime) = 0 THEN
		ln_hourly_vol_qty := ln_daily_vol_qty / lr_daytime.COUNT;
		ln_hourly_mass_qty := ln_daily_mass_qty / lr_daytime.COUNT;
		ln_hourly_energy_qty := ln_daily_energy_qty / lr_daytime.COUNT;
	END IF;

	FOR li_pointer in 1..lr_daytime.COUNT LOOP
		SELECT COUNT(*)
		INTO li_record_count
		FROM meter_sub_day_meas
		WHERE object_id = p_object_id
			AND daytime = lr_daytime(li_pointer).daytime
			AND summer_time = lr_daytime(li_pointer).summertime_flag;

		IF li_record_count = 0 THEN
				INSERT INTO meter_sub_day_meas(object_id, daytime, production_day, summer_time, vol_qty, mass_qty, energy_qty, created_by)
				VALUES (p_object_id, lr_daytime(li_pointer).daytime, p_daytime, lr_daytime(li_pointer).summertime_flag, ln_hourly_vol_qty,ln_hourly_mass_qty, ln_hourly_energy_qty, p_curr_user);
		END IF;
	END LOOP;
END createMeterDayHours;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : setMeterCompStatus
-- Description    : Sets record status of meter composition to 'A' when measurement status is Approved
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : fluid_component_analysis
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : If measurement status is set to approved, record status for all compositions should be updated to 'A'
--
---------------------------------------------------------------------------------------------------
PROCEDURE setMeterCompStatus(p_analysis_no VARCHAR2,
                             p_user_id     VARCHAR2 DEFAULT NULL)
--</EC-DOC>
 IS

  lv_record_status VARCHAR2(16);
  lr_analysis      object_fluid_analysis%ROWTYPE;

  CURSOR c_object_fluid_analysis IS
    SELECT *
      FROM object_fluid_analysis
     WHERE analysis_no = p_analysis_no;

BEGIN

  FOR mycur IN c_object_fluid_analysis LOOP
    lr_analysis := mycur;
  END LOOP;

  lv_record_status := ec_prosty_codes.alt_code(lr_analysis.analysis_status,
                                               'ANALYSIS_STATUS');

  IF lr_analysis.record_status <> lv_record_status THEN
    -- update object_fluid_analysis
    UPDATE object_fluid_analysis
       SET record_status = lv_record_status, last_updated_by = p_user_id
     WHERE analysis_no = lr_analysis.analysis_no;

    -- update fluid_analysis_component
    UPDATE fluid_analysis_component
       SET record_status     = lv_record_status,
           last_updated_by   = p_user_id,
           last_updated_date = Ecdp_Date_Time.getCurrentSysdate
     WHERE analysis_no = lr_analysis.analysis_no;

  END IF;

END setMeterCompStatus;

END EcDp_Meter_Measurement;