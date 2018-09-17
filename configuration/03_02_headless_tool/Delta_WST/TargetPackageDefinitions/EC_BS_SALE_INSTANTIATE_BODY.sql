CREATE OR REPLACE PACKAGE BODY Ec_Bs_Sale_Instantiate IS

/***********************************************************************************************************************************************
** Package        :  Ec_Bs_Sale_Instantiate, body part
**
** $Revision: 1.18.24.1 $
**
** Purpose        :  Instantiate records in EC Sale data tables.
**
** Created        :  15.12.2004  Tor-Erik Hauge
**
** Documentation  :  www.energy-components.com
**
** Short how-to:
**	Create an instantiate procedure for the table(s) you want to instantiate. In this procedure
**	create a cursor that finds the primary keys for those tables you want to instantiate.
**	Loop this cursor and insert records for the daytime(s) taken as parameter.
**	Add the created procedure to the for loop in new_day_end.
**
** Modification history:
**
** Date        Whom     Change description:
** ----------  -------- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   		Initial version (first build / handover to test)
** 11.01.2005  BIH   		Added / cleaned up documentation
** 11.01.2006  ssk	 		Added procedure i_wet_gas_hourly_profile for instantiation of wet gas hourly profile
** 11.01.2006  eideekri Added procEc_Bs_Sale_Instantiateedure i_ngl_export and  for instantiation of Ngl Export
** 11.01.2006  eideekri Added procedure i_wet_gas_export_fuel and for instantiation of  Wet Gas Export and Fuel
** 01.02.2006  skjorsti Added a call to procedure newMonth from procedure new_day_end (TD 5495)
** 10.07.2006  eizwanik #3851 and #3968: Updated i_wet_gas_export_fuel, i_ngl_export, and i_wet_gas_hourly_profile to obtain correct production day
** 01.09.2006  chongjer Updated procedure i_scontr_per_status to instantiate sub daily records, tracker 4254
** 05.05.2007  rahmanaz ECPD-5523 - Updated procedure i_expenditure by adding join contract.object_id = cntr_expenditure_code.object_id
** 08.05.2007  seongkok	#5571  Updated i_gscontr_day_del to check against the flag to enable/disable the instantiation.
** 30.08.2007  ismaiime Updated i_wet_gas_export_fuel to only instantiate objects available current date
** 23.09.2008  embonhaf Added check for null delivery_point_id in i_gscontr_day_del and i_gscontr_mth_del
** 27.01.2009  masamken change this table STRM_SUB_DAY_FLD_SCHEME to STRM_SUB_DAY_SCHEME, and attribute feild_id to parent_object_id
** 18.09.2009  oonnnng  ECPD-9853: Added checking that record is set to be instantiated in i_gscontr_mth_del(), i_scontr_per_status(),
**                      i_wet_gas_hourly_profile, priceIndexMth(), priceIndexDay(), and i_expenditure() functions.
** 10.04.2013  limmmchu ECPD-23822: Modified new_day_end to have the checking of future date for p_to_daytime
******************************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : new_day_end
-- Description    : Performs instantiation at day end
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : system_days
--
-- Using functions: EcDp_Date_Time.getCurrentSysdate
--
-- Configuration
-- required       :
--
-- Behaviour      : Insert new rows in system_days as needed. Then calls the individual instantiation
--                  methods that should run on day end.
--					Finally runs procedure newMonth
--
---------------------------------------------------------------------------------------------------
PROCEDURE new_day_end(
   p_daytime      DATE,
   p_to_daytime   DATE DEFAULT NULL
)
--</EC-DOC>
IS
   ld_day         DATE;
   ld_end_date    DATE;
   lr_system_day  system_days%ROWTYPE;

   CURSOR c_daytime IS
      SELECT daytime
      FROM system_days
      WHERE daytime BETWEEN p_daytime
      AND Nvl(p_to_daytime, TRUNC(EcDp_Date_Time.getCurrentSysdate, 'DD'));

BEGIN
   -- exclude future dates
   IF p_daytime <= Trunc(EcDp_Date_Time.getCurrentSysdate, 'DD') THEN
      -- make sure all rows are present in system_days
      IF (p_to_daytime IS NULL OR p_to_daytime < p_daytime) THEN
         ld_end_date := p_daytime;
      ELSE
        IF p_to_daytime > Trunc(EcDp_Date_Time.getCurrentSysdate, 'DD') THEN
          ld_end_date := Trunc(EcDp_Date_Time.getCurrentSysdate, 'DD');
        ELSE
          ld_end_date := p_to_daytime;
        END IF;
      END IF;

      FOR ln_day_count IN 0 .. (ld_end_date - p_daytime) LOOP
         ld_day := p_daytime + ln_day_count;
         lr_system_day := ec_system_days.row_by_pk(ld_day);
         IF lr_system_day.daytime IS NULL THEN
           INSERT INTO system_days (daytime) VALUES (ld_day);
         END IF; -- else skip
      END LOOP;

      FOR mycur IN c_daytime LOOP
      	   i_gscontr_day_del(mycur.daytime);
      	   i_scontr_per_status(mycur.daytime);
           i_wet_gas_hourly_profile(mycur.daytime);
           i_ngl_export(mycur.daytime);
           i_wet_gas_export_fuel(mycur.daytime);
           newMonth(mycur.daytime);
      END LOOP;
   END IF;
END new_day_end;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : i_gscontr_day_del
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cntr_delivery_pnt_usage
--                  cntr_day_dp_delivery
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Inserts empty records into cntr_day_dp_delivery for p_daytime for all combinations of
--                  gas sale contracts and delivery points extracted from table
--
---------------------------------------------------------------------------------------------------
PROCEDURE i_gscontr_day_del(
   p_daytime DATE
)
--</EC-DOC>
IS

ln_test VARCHAR2(20);

   CURSOR cur_get_keys IS
      SELECT DISTINCT cd.contract_id, cd.delivery_point_id
      FROM nomination_point cd
      WHERE p_daytime >= cd.start_date
      AND p_daytime < Nvl(cd.end_date, p_daytime + 1)
      AND cd.delivery_point_id is not null
      AND NOT EXISTS
      (
         SELECT 1
         FROM cntr_day_dp_delivery x
         WHERE cd.contract_id = x.object_id AND cd.delivery_point_id = x.delivery_point_id AND p_daytime = x.daytime
      );
BEGIN

	IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/sale/ds/instantiate/SCTR_DAY_DEL', p_daytime) ='Y' THEN
	   	FOR mycur IN cur_get_keys LOOP
	    	INSERT INTO cntr_day_dp_delivery(object_id, delivery_point_id, daytime)
	      	VALUES(mycur.contract_id, mycur.delivery_point_id, p_daytime);
	   	END LOOP;
	END IF;
END i_gscontr_day_del;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : i_gscontr_mth_del
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
-- Behaviour      : Inserts empty records into cntr_mth_dp_delivery for p_daytime for all combinations of
--                  gas sale contracts and delivery points extracted from table
--
---------------------------------------------------------------------------------------------------
PROCEDURE i_gscontr_mth_del(
p_daytime DATE)
--<EC-DOC>

IS
ld_daytime DATE := TRUNC (TO_DATE (p_daytime), 'MONTH');

   CURSOR cur_get_keys IS
      SELECT DISTINCT cd.contract_id, cd.delivery_point_id
      FROM nomination_point cd
      WHERE ld_daytime >= cd.start_date
      AND ld_daytime < Nvl(cd.end_date, LAST_DAY(ld_daytime))
      AND cd.delivery_point_id is not null
      AND NOT EXISTS
      (
         SELECT 1
         FROM cntr_mth_dp_delivery x
         WHERE cd.contract_id = x.object_id AND cd.delivery_point_id = x.delivery_point_id AND ld_daytime = x.daytime
      );

BEGIN

   IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/sale/ds/instantiate/SCTR_MTH_DEL', p_daytime) ='Y' THEN
     FOR mycur IN cur_get_keys LOOP
        INSERT INTO cntr_mth_dp_delivery(object_id, delivery_point_id, daytime)
        VALUES(mycur.contract_id, mycur.delivery_point_id, ld_daytime);
     END LOOP;
   END IF;
END i_gscontr_mth_del;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : i_scontr_per_status
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : contract
--                  cntr_period_status
--                  cntr_sub_day_status
--
-- Using functions: EcDp_Contract.getContractYear
--
-- Configuration
-- required       :
--
-- Behaviour      : Inserts records into cntr_period_status for gas sales contracts. If none of them exists from
--                  possible three records can be inserted for each object, a daily, a monthly and a yearly (time_span:
--                  DAY/MTH/YR). For sub daily, records are inserted into cntr_sub_day_status.
--
---------------------------------------------------------------------------------------------------
PROCEDURE i_scontr_per_status(
   p_daytime DATE
)
--</EC-DOC>
IS

   li_n_curr_mth_records 	INTEGER := 0;
   li_n_curr_yr_records 	INTEGER := 0;
   ld_daytimes            EcDp_Date_Time.Ec_Unique_Daytimes;
   ld_production_day      DATE;
   ld_summer_time         VARCHAR2(1);
   ld_prod_daytime        DATE;
   ln_insert              VARCHAR(1);

   CURSOR cur_sub_day IS
      SELECT DISTINCT c.object_id
      FROM contract c, contract_account ca
      WHERE p_daytime >= c.start_date
      AND p_daytime < Nvl(c.end_date, p_daytime + 1)
      AND SALE_IND = 'Y'
      AND c.object_id = ca.object_id;

   CURSOR cur_sub_day_exist_test (cp_object_id VARCHAR2, cp_daytime DATE, cp_production_day DATE, cp_summer_time VARCHAR2) IS
	    SELECT 1
	    FROM cntr_sub_day_status
	    WHERE object_id = cp_object_id
		  AND daytime = cp_daytime
      AND production_day = cp_production_day
		  AND summer_time = cp_summer_time;

   CURSOR cur_day IS
      SELECT c.object_id
      FROM contract c
      WHERE p_daytime >= c.start_date
      AND p_daytime < Nvl(c.end_date, p_daytime + 1)
      AND SALE_IND = 'Y'
      AND NOT EXISTS
      (
         SELECT 1
         FROM cntr_period_status x
         WHERE c.object_id = x.object_id AND x.daytime = trunc(p_daytime,'dd') and x.time_span = 'DAY'
       );

   CURSOR cur_mth IS
      SELECT c.object_id
      FROM contract c
      WHERE p_daytime >= c.start_date
      AND p_daytime < Nvl(c.end_date, p_daytime + 1)
      AND SALE_IND = 'Y'
      AND NOT EXISTS
      (
         SELECT 1
         FROM cntr_period_status x
         WHERE c.object_id = x.object_id AND x.daytime = trunc(p_daytime,'mm') and x.time_span = 'MTH'
      );

   CURSOR cur_yr IS
      SELECT c.object_id
      FROM contract c
      WHERE p_daytime >= c.start_date
      AND p_daytime < Nvl(c.end_date, p_daytime + 1)
      AND SALE_IND = 'Y'
      AND NOT EXISTS
      (
         SELECT 1
         FROM cntr_period_status x
         WHERE c.object_id = x.object_id
         AND x.daytime = EcDp_Contract.getContractYear(c.object_id,trunc(p_daytime))
         and x.time_span = 'YR'
      );

BEGIN

   ld_production_day := p_daytime;

   IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/sale/ds/instantiate/SCTR_SUB_DAY_STATUS', p_daytime) ='Y' THEN
     FOR mycur IN cur_sub_day LOOP
        ld_daytimes := ecdp_productionday.getProductionDayDaytimes('CONTRACT', mycur.object_id, ld_production_day);

        FOR li_pointer in 1..ld_daytimes.COUNT LOOP
           ln_insert := 'Y';
           ld_prod_daytime := ld_daytimes(li_pointer).daytime;
           ld_summer_time := ld_daytimes(li_pointer).summertime_flag;

           FOR cur_exist IN cur_sub_day_exist_test(mycur.object_id, ld_prod_daytime, ld_production_day, ld_summer_time) LOOP
              ln_insert := 'N';
           END LOOP;

           IF ln_insert = 'Y' THEN
              INSERT INTO cntr_sub_day_status (object_id, daytime, production_day, summer_time)
              VALUES (mycur.object_id, ld_prod_daytime, ld_production_day, ld_summer_time);
           END IF;
        END LOOP;
     END LOOP;
   END IF;

   IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/sale/ds/instantiate/SCTR_DAY_STATUS', p_daytime) ='Y' THEN
     FOR mycur IN cur_day LOOP
        INSERT INTO cntr_period_status (object_id, daytime, time_span)
        VALUES (mycur.object_id, p_daytime, 'DAY');
     END LOOP;
   END IF;

   IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/sale/ds/instantiate/SCTR_MTH_STATUS', p_daytime) ='Y' THEN
     FOR mycur IN cur_mth LOOP
        INSERT INTO cntr_period_status (object_id, daytime, time_span)
        VALUES (mycur.object_id, trunc(p_daytime,'mm'), 'MTH');
     END LOOP;
   END IF;

   IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/sale/ds/instantiate/SCTR_YR_STATUS', p_daytime) ='Y' THEN
     FOR mycur IN cur_yr LOOP
        INSERT INTO cntr_period_status (object_id, daytime, time_span)
        VALUES (mycur.object_id, EcDp_Contract.getContractYear(mycur.object_id,trunc(p_daytime,'dd')), 'YR');
     END LOOP;
   END IF;

END i_scontr_per_status;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : i_wet_gas_hourly_profile
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions: ecbp_dry_gas_target.getOffset, Ecdp_Date_Time.utc2local
--
-- Configuration
-- required       :
--
-- Behaviour      : Inserts empty records into wet_gas_hourly_profile
--
---------------------------------------------------------------------------------------------------
PROCEDURE i_wet_gas_hourly_profile(
   p_daytime DATE
)
--</EC-DOC>
IS
ld_daytimes EcDp_Date_Time.Ec_Unique_Daytimes;
ld_production_day DATE;
ld_summer_time VARCHAR2(1);
ld_prod_daytime DATE;
ln_insert VARCHAR(1);

CURSOR c_unique (cp_daytime DATE, cp_summertime_flag VARCHAR2) IS
	SELECT 	1
	FROM 	wet_gas_hourly_profile
	WHERE 	daytime = cp_daytime AND
			summer_time = cp_summertime_flag;

BEGIN
	ld_production_day := p_daytime + 2;
  	ld_daytimes := ecdp_productionday.getProductionDayDaytimes('STREAM', NULL, ld_production_day);  	-- Retrieves system attribute production day start

  IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/sale/ds/instantiate/WET_GAS_HOURLY_PROFILE', p_daytime) ='Y' THEN
    FOR li_pointer in 1..ld_daytimes.COUNT LOOP

      ln_insert := 'Y';
      ld_prod_daytime := ld_daytimes(li_pointer).daytime;
      ld_summer_time := ld_daytimes(li_pointer).summertime_flag;

    -- Determining if row is already present in table
      FOR c_val IN c_unique(ld_prod_daytime, ld_summer_time)  LOOP
        ln_insert := 'N';
      END LOOP;

      IF ln_insert = 'Y' THEN
        INSERT INTO wet_gas_hourly_profile(daytime,production_day,summer_time)
        VALUES (ld_prod_daytime, ld_production_day, ld_summer_time);
      END IF;

    END LOOP;
  END IF;

END i_wet_gas_hourly_profile;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :  newMonth
-- Description    :  Do instantiations on first day of each month
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :  When called, check if date is first of month, and then call listed procedures.
--
---------------------------------------------------------------------------------------------------
PROCEDURE newMonth(p_daytime DATE)
--</EC-DOC>
IS
BEGIN

	-- exclude future dates and make sure date is the first in the month.
	IF (p_daytime <= trunc(EcDp_Date_Time.getCurrentSysdate, 'DD') AND
		to_char(p_daytime, 'DD') = '01') THEN
		-- procedures to call:
		priceIndexMth(p_daytime);
		priceIndexDay(p_daytime);
		i_gscontr_mth_del(p_daytime);
		i_expenditure(p_daytime);
	END IF;

END newMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : priceIndexMth
-- Description    : Instantiate price_index_values monthly
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : price_index, price_index_version, price_index_value
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Insert a row in PRICE_INDEX_VALUE for all valid price indexes
--		    for selected month where FREQUENCY is MONTH
---------------------------------------------------------------------------------------------------
PROCEDURE priceIndexMth(
	p_daytime DATE)
--</EC-DOC>
IS
	-- Find all indexes valid for this month, with frequency = MTH
	CURSOR cur_active_index IS
		SELECT piv.object_id,
		       pi.object_code
		  FROM price_index_version piv, price_index pi
		 WHERE piv.object_id = pi.object_id
		   AND piv.frequency = 'MTH'
		   AND piv.daytime <= p_daytime
		   AND (piv.end_date >= last_day(trunc(p_daytime, 'MONTH')) OR
		       piv.end_date IS NULL)
		   AND NOT EXISTS (
		   	SELECT 1
		          FROM price_index_value piva
		         WHERE piva.object_id = piv.object_id
		           AND piva.daytime = trunc(p_daytime, 'DD'));

BEGIN

  IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/sale/ds/instantiate/PRICE_INDEX_MTH_VALUE', p_daytime) ='Y' THEN
    FOR index_cur IN cur_active_index LOOP
      INSERT INTO price_index_value (
        object_id,
        daytime)
      VALUES (index_cur.object_id,
        p_daytime);
    END LOOP;
  END IF;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : priceIndexDay
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Insert rows in PRICE_INDEX_VALUE for all valid price indexes
--		    			  for selected month where FREQUENCY is DAY
---------------------------------------------------------------------------------------------------
PROCEDURE priceIndexDay(
	p_daytime DATE)
--</EC-DOC>
IS
	-- Find all indexes valid for this month, with frequency = DAY
	CURSOR cur_active_index IS
		SELECT piv.object_id,
           pi.object_code,
           piv.daytime,
           piv.end_date
		  FROM price_index_version piv, price_index pi
		 WHERE piv.object_id = pi.object_id
		   AND piv.frequency = 'DAY'
		   AND piv.daytime <= p_daytime
		   AND (piv.end_date >= p_daytime OR
		       piv.end_date IS NULL);
/*		   AND (piv.end_date >= last_day(trunc(p_daytime, 'MONTH')) OR
		       piv.end_date IS NULL);
*/
  next_date DATE;
  my_rec price_index_value%rowtype;
  index_valid BOOLEAN;


BEGIN

  IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/sale/ds/instantiate/PRICE_INDEX_DAY_VALUE', p_daytime) ='Y' THEN
    FOR index_cur IN cur_active_index LOOP
      FOR loop_counter IN 1 .. to_char(last_day(trunc(p_daytime, 'MONTH')),
                                       'DD') LOOP
        next_date := to_date(concat(concat(loop_counter, '.'),
                                    to_char(p_daytime, 'MM.YYYY')),
                             'DD.MM.YYYY');

        my_rec := ec_price_index_value.row_by_pk(index_cur.object_id,
                                                 next_date);
        IF my_rec.object_id IS NULL THEN
          IF index_cur.end_date > NEXT_DATE OR index_cur.end_date IS NULL THEN
            INSERT INTO price_index_value
              (object_id, daytime)
            VALUES
              (index_cur.object_id, next_date);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  END IF;
END priceIndexDay;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : i_wet_gas_export_fuel
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : strm_sub_day_scheme
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Insert rows in strm_sub_day_scheme
---------------------------------------------------------------------------------------------------
PROCEDURE i_wet_gas_export_fuel(
	p_daytime DATE)
--</EC-DOC>
IS

ld_daytimes EcDp_Date_Time.Ec_Unique_Daytimes;
ld_production_day DATE;
ld_summer_time VARCHAR2(1);
ld_prod_daytime DATE;
ln_insert VARCHAR(1);

CURSOR cur_object(cp_daytime DATE)IS
	SELECT DISTINCT r.object_id, r.sort_order, r.uom , c.ATTRIBUTE_NAME, c.stream_id
	FROM dispatching_row_mapping r, dispatching_col_mapping c
	WHERE r.bf_class_name = 'GAS_DAY_EXP_AND_FUEL'
		AND r.object_id = c.object_id
		AND c.grouping_type = 'SUB_DAILY'
		AND (c.end_date > p_daytime OR c.end_date is null)
		AND c.daytime <= cp_daytime;

CURSOR cur_exist_test (cp_object_id VARCHAR2, cp_parent_object_id VARCHAR2, cp_daytime DATE, cp_summertime VARCHAR2) IS
	SELECT 1
	FROM strm_sub_day_scheme
	WHERE object_id = cp_object_id
		AND parent_object_id = cp_parent_object_id
		AND daytime = cp_daytime
		AND summer_time = cp_summertime
		AND data_class_name = 'GAS_SUB_DAY_EXP_AND_FUEL';


BEGIN
	ld_production_day := p_daytime + 2;

	FOR index_cur IN cur_object(ld_production_day) LOOP

      	ld_daytimes := ecdp_productionday.getProductionDayDaytimes('STREAM', index_cur.stream_id, ld_production_day);

		FOR li_pointer in 1..ld_daytimes.COUNT LOOP

			ln_insert := 'Y';
			ld_prod_daytime := ld_daytimes(li_pointer).daytime;
			ld_summer_time := ld_daytimes(li_pointer).summertime_flag;


			FOR cur_exist IN cur_exist_test(index_cur.stream_id, index_cur.object_id, ld_prod_daytime, ld_summer_time) LOOP
				ln_insert := 'N';
			END LOOP;

			IF ln_insert = 'Y' THEN
				INSERT INTO strm_sub_day_scheme (OBJECT_ID,PARENT_OBJECT_ID, DAYTIME, PRODUCTION_DAY, SUMMER_TIME, DATA_CLASS_NAME)
				VALUES (index_cur.stream_id, index_cur.object_id, ld_prod_daytime, ld_production_day, ld_summer_time, 'GAS_SUB_DAY_EXP_AND_FUEL');
			END IF;

		END LOOP;
	END LOOP;

END i_wet_gas_export_fuel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : i_ngl_export
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : strm_sub_day_scheme
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Insert rows in strm_sub_day_scheme
---------------------------------------------------------------------------------------------------
PROCEDURE i_ngl_export(
	p_daytime DATE)
--</EC-DOC>
IS

ld_daytimes EcDp_Date_Time.Ec_Unique_Daytimes;
ld_production_day DATE;
ld_summer_time VARCHAR2(1);
ld_prod_daytime DATE;
ln_insert VARCHAR(1);

CURSOR cur_object IS
	SELECT DISTINCT r.object_id, r.sort_order, r.uom , c.ATTRIBUTE_NAME, c.stream_id
	FROM dispatching_row_mapping r, dispatching_col_mapping c
	WHERE r.bf_class_name = 'GAS_DAY_NGL_EXPORT'
		AND r.object_id = c.object_id
		AND c.grouping_type = 'SUB_DAILY';

CURSOR cur_exist_test (cp_object_id VARCHAR2, cp_parent_object_id VARCHAR2, cp_daytime DATE, cp_summertime VARCHAR2) IS
	SELECT 1
	FROM strm_sub_day_scheme
	WHERE object_id = cp_object_id
		AND parent_object_id = cp_parent_object_id
		AND daytime = cp_daytime
		AND summer_time = cp_summertime
		AND data_class_name = 'GAS_SUB_DAY_NGL_EXPORT';

BEGIN
	ld_production_day := p_daytime + 2;

	FOR index_cur IN cur_object LOOP

      	ld_daytimes := ecdp_productionday.getProductionDayDaytimes('STREAM', index_cur.stream_id, ld_production_day);

		FOR li_pointer in 1..ld_daytimes.COUNT LOOP

			ln_insert := 'Y';
			ld_prod_daytime := ld_daytimes(li_pointer).daytime;
			ld_summer_time := ld_daytimes(li_pointer).summertime_flag;


			FOR cur_exist IN cur_exist_test(index_cur.stream_id, index_cur.object_id, ld_prod_daytime, ld_summer_time) LOOP
				ln_insert := 'N';
			END LOOP;

			IF ln_insert = 'Y' THEN
         		INSERT INTO strm_sub_day_scheme (OBJECT_ID,PARENT_OBJECT_ID, DAYTIME, PRODUCTION_DAY, SUMMER_TIME, DATA_CLASS_NAME)
				VALUES (index_cur.stream_id, index_cur.object_id, ld_prod_daytime, ld_production_day, ld_summer_time, 'GAS_SUB_DAY_NGL_EXPORT');
			END IF;

		END LOOP;
	END LOOP;

END i_ngl_export;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : i_expenditure
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
-- Behaviour      : Inserts expenditure rows both actual and forecast
--
---------------------------------------------------------------------------------------------------
PROCEDURE i_expenditure(p_daytime DATE)
--<EC-DOC>

IS

-- all sale contracts
	CURSOR c_cntr_1 (cp_daytime DATE) IS
	SELECT c.object_id, e.category_code, e.exp_code, e.company_id
	FROM contract c,
       	cntr_expenditure_code e
	WHERE c.SALE_IND = 'Y'
		AND c.object_id = e.object_id
		AND c.START_DATE <= cp_daytime
		AND c.END_DATE > cp_daytime
		AND e.daytime <= cp_daytime
  		AND Nvl(e.end_date, cp_daytime+1) > cp_daytime
  		AND NOT EXISTS
      (
         SELECT 1
         FROM cntr_mth_expenditure x
         WHERE e.object_id = x.object_id AND cp_daytime = x.daytime
         AND x.category_code = e.category_code AND x.exp_code = e.exp_code
      );


  	CURSOR c_cntr_2 (cp_daytime DATE) IS
	SELECT c.object_id, e.category_code, e.exp_code, e.company_id
	FROM contract c,
       	cntr_expenditure_code e
	WHERE c.SALE_IND = 'Y'
		AND c.object_id = e.object_id
		AND c.START_DATE <= cp_daytime
		AND c.END_DATE > cp_daytime
		AND e.daytime <= cp_daytime
  		AND Nvl(e.end_date, cp_daytime+1) > cp_daytime
  		AND NOT EXISTS
      (
         SELECT 1
         FROM cntr_mth_exp_forecast x
         WHERE e.object_id = x.object_id AND cp_daytime = x.daytime
         AND x.category_code = e.category_code AND x.exp_code = e.exp_code
      );

BEGIN


  IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/sale/ds/instantiate/SCTR_MTH_EXPENDITURE', p_daytime) ='Y' THEN
    FOR mycur IN c_cntr_1 (p_daytime) LOOP
      INSERT INTO cntr_mth_expenditure (OBJECT_ID, CATEGORY_CODE, EXP_CODE, DAYTIME, COMPANY_ID)
      VALUES (mycur.object_id, mycur.category_code, mycur.exp_code, p_daytime, mycur.company_id);
    END LOOP;
  END IF;


  IF Ecdp_Ctrl_Property.getSystemProperty('/com/ec/sale/ds/instantiate/SCTR_MTH_EXP_FORECAST', p_daytime) ='Y' THEN
    FOR mycur IN c_cntr_2 (p_daytime) LOOP
      INSERT INTO cntr_mth_exp_forecast (OBJECT_ID, CATEGORY_CODE, EXP_CODE, DAYTIME, COMPANY_ID)
      VALUES (mycur.object_id, mycur.category_code, mycur.exp_code, p_daytime, mycur.company_id);
    END LOOP;
  END IF;

END i_expenditure;


END Ec_Bs_Sale_Instantiate;