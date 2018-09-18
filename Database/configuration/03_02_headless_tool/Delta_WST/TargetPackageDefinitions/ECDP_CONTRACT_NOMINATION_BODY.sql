CREATE OR REPLACE PACKAGE BODY EcDp_Contract_Nomination IS
/******************************************************************************
** Package        :  EcDp_Contract_Nomination, body part
**
** $Revision: 1.8 $
**
** Purpose        :  Find and work with nomination data
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2004 Tor-Erik Hauge
**
** Modification history:
**
** Date        Whom        Change description:
** ------      -----       -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH         Initial version (first build / handover to test)
** 03.01.2005  BIH         TD2724: Added validation of daily nomination quantity during aggregation from sub-daily to daily
** 11.01.2005  BIH         Added / cleaned up documentation
** 16.05.2005  kaurrnar	   Added raise application error for createDaysForWeek procedure
** 25.04.2006  eikebeir    Added aggrSentSubDailyToDaily and aggrAdjSubDailyToDaily
** 15.05.2009  masamken    create new Procedures createDaysForPeriod / deleteHourlyData
**
********************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNumberOfSubDailyRecords
-- Description    : Returns the number of sub-daily (hourly) nomination records for the given contract day.
--
-- Preconditions  : p_date should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_nom
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
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_date                DATE
)
RETURN INTEGER
--</EC-DOC>
IS
   li_cnt   INTEGER;
BEGIN
   SELECT COUNT(*) INTO li_cnt
   FROM cntr_sub_day_dp_nom
   WHERE object_id = p_contract_id
   AND delivery_point_id = p_delivery_point_id
   AND production_day = p_date;
   RETURN li_cnt;
END getNumberOfSubDailyRecords;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDailyNomination
-- Description    : Returns the daily nominated qty for a given contract and delivery point.
--
-- Preconditions  : p_date should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_nom
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the quantity from the daily record (not as a sum of sub-daily).
--
---------------------------------------------------------------------------------------------------
FUNCTION getDailyNomination(
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_qty   NUMBER;
   CURSOR c_qty IS
      SELECT NVL(nominated_qty,0) AS nominated_qty
      FROM cntr_day_dp_nom
      WHERE object_id = p_contract_id
      AND delivery_point_id = p_delivery_point_id
      AND daytime = p_date;
BEGIN
   ln_qty := NULL;
   FOR r_qty IN c_qty LOOP
      ln_qty := NVL(ln_qty,0) + r_qty.nominated_qty;
   END LOOP;
   RETURN ln_qty;
END getDailyNomination;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDailyContractNominatedQty
-- Description    : Returns the total daily nominated qty (for all delivery points) for a given contract.
--
-- Preconditions  : p_date should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_nom
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the quantity from the daily records (not as a sum of sub-daily).
--
---------------------------------------------------------------------------------------------------
FUNCTION getDailyContractNominatedQty(
  p_contract_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_qty   NUMBER;
   CURSOR c_qty IS
      SELECT NVL(nominated_qty,0) AS nominated_qty
      FROM cntr_day_dp_nom
      WHERE object_id = p_contract_id
      AND daytime = p_date;
BEGIN
   ln_qty := NULL;
   FOR r_qty IN c_qty LOOP
      ln_qty := NVL(ln_qty,0) + r_qty.nominated_qty;
   END LOOP;
   RETURN ln_qty;
END getDailyContractNominatedQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMonthlyContractNominatedQty
-- Description    : Returns the total monthly nominated qty (for all delivery points) for a given contract.
--
-- Preconditions  : p_date should be a logical contract month (zero days/hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_nom
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the sum of the quantities from the daily records.
--
---------------------------------------------------------------------------------------------------
FUNCTION getMonthlyContractNominatedQty(
  p_contract_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_qty   NUMBER;
   CURSOR c_qty IS
      SELECT NVL(nominated_qty,0) AS nominated_qty
      FROM cntr_day_dp_nom
      WHERE object_id = p_contract_id
      AND daytime >= p_date AND daytime < add_months(p_date,1);
BEGIN
   ln_qty := NULL;
   FOR r_qty IN c_qty LOOP
      ln_qty := NVL(ln_qty,0) + r_qty.nominated_qty;
   END LOOP;
   RETURN ln_qty;
END getMonthlyContractNominatedQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDailyNomination
-- Description    : Returns the sub-daily nominated qty for a given contract and delivery point.
--
-- Preconditions  : p_daytime should be a logical contract hour (zero minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_nom
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the quantity from the sub-daily record.
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDailyNomination(
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_daytime             DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_qty   NUMBER;
   CURSOR c_qty IS
      SELECT NVL(nominated_qty,0) AS nominated_qty
      FROM cntr_sub_day_dp_nom
      WHERE object_id = p_contract_id
      AND delivery_point_id = p_delivery_point_id
      AND daytime = p_daytime;
BEGIN
   ln_qty := NULL;
   FOR r_qty IN c_qty LOOP
      ln_qty := NVL(ln_qty,0) + r_qty.nominated_qty;
   END LOOP;
   RETURN ln_qty;
END getSubDailyNomination;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : aggregateSubDailyToDaily
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_nom
--                  cntr_day_dp_nom
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities for the given day. The resulting
--                  quantity is written to the daily nominated quantity table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateSubDailyToDaily(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime    	DATE,
	p_user			VARCHAR2
)
--</EC-DOC>
IS
	ln_sum_nominated_qty    NUMBER :=0;

	CURSOR c_sum_nominated_qty IS
		SELECT SUM(nominated_qty) result
		FROM cntr_sub_day_dp_nom
		WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND production_day = p_daytime;

BEGIN
   -- Find the day total
	FOR curNomSum IN c_sum_nominated_qty LOOP
		ln_sum_nominated_qty:= curNomSum.result;
	END LOOP;

	-- Check against upper and lower limit. Throws an exception if the qty is invalid.
	validateDailyNominationQty(p_contract_id, p_daytime, ln_sum_nominated_qty);

   -- Update day record
	UPDATE cntr_day_dp_nom SET nominated_qty = ln_sum_nominated_qty, last_updated_by = p_user
	WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime;
END aggregateSubDailyToDaily;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : aggrNomSubDailyToDaily
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_nom
--                  cntr_day_dp_nom
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities for the given day. The resulting
--                  quantity is written to the daily nominated quantity table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggrNomSubDailyToDaily(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime    	DATE,
	p_user         VARCHAR2  DEFAULT NULL

)
--</EC-DOC>
IS
	ln_sum_nominated_qty    NUMBER :=0;
	lv_record_exists       VARCHAR2(1):='N';

	CURSOR c_sum_nominated_qty IS
		SELECT SUM(Nvl(nominated_qty,0)) result
		FROM cntr_sub_day_dp_nom
		WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND production_day = p_daytime;

	CURSOR c_day_exits IS
	      SELECT 1 from cntr_day_dp_nom
	      WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime;

BEGIN
   -- Find the day total
	FOR curNomSum IN c_sum_nominated_qty LOOP
		ln_sum_nominated_qty:= curNomSum.result;
	END LOOP;

   FOR object_id in c_day_exits LOOP
      lv_record_exists := 'Y';
   END LOOP;

   IF lv_record_exists = 'Y' THEN -- update existing record
      UPDATE cntr_day_dp_nom SET nominated_qty = ln_sum_nominated_qty, last_updated_by = p_user
	   WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime;

   ELSIF lv_record_exists = 'N'THEN --create new record
      INSERT INTO cntr_day_dp_nom (object_id, delivery_point_id,daytime, nominated_qty, created_by, created_date)
      VALUES( p_contract_id, p_delpt_id, p_daytime,ln_sum_nominated_qty, p_user, sysdate);
   END IF;

   -- Update day record

END aggrNomSubDailyToDaily;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : aggrReqSubDailyToDaily
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_nom
--                  cntr_day_dp_nom
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities for the given day. The resulting
--                  quantity is written to the daily nominated quantity table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggrReqSubDailyToDaily(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime    	DATE,
	p_user         VARCHAR2 DEFAULT NULL

)
--</EC-DOC>
IS
	ln_sum_req_qty    NUMBER :=0;
   lv_record_exists       VARCHAR2(1):='N';

	CURSOR c_day_exits IS
	SELECT 1 from cntr_day_dp_nom
	WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime;


	CURSOR c_sum_received_qty IS
		SELECT SUM(Nvl(REQUESTED_QTY, 0)) result
		FROM cntr_sub_day_dp_nom
		WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND production_day = p_daytime;

BEGIN
   -- Find the day total
	FOR curNomSum IN c_sum_received_qty LOOP
		ln_sum_req_qty:= curNomSum.result;
	END LOOP;

   FOR object_id in c_day_exits LOOP
      lv_record_exists := 'Y';
   END LOOP;

   IF lv_record_exists = 'Y' THEN -- update existing record
      UPDATE cntr_day_dp_nom
      SET REQUESTED_QTY = ln_sum_req_qty, last_updated_by = p_user
	  WHERE object_id = p_contract_id
	  	AND delivery_point_id = p_delpt_id
	  	AND daytime = p_daytime;

   ELSIF lv_record_exists = 'N' THEN --create new record
      INSERT INTO cntr_day_dp_nom (object_id, delivery_point_id,daytime, REQUESTED_QTY, created_by, created_date)
      VALUES( p_contract_id, p_delpt_id, p_daytime,ln_sum_req_qty, p_user, sysdate);
   END IF;
END aggrReqSubDailyToDaily;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : aggrSentSubDailyToDaily
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_nom
--                  cntr_day_dp_nom
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities for the given day. The resulting
--                  quantity is written to the daily nominated quantity table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggrSentSubDailyToDaily(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime    	DATE,
	p_user         VARCHAR2 DEFAULT NULL

)
--</EC-DOC>
IS
	ln_sum_sent_qty    NUMBER :=0;
   lv_record_exists       VARCHAR2(1):='N';

	CURSOR c_day_exits IS
	SELECT 1 from cntr_day_dp_nom
	WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime;


	CURSOR c_sum_sent_qty IS
		SELECT SUM(Nvl(SENT_QTY, 0)) result
		FROM cntr_sub_day_dp_nom
		WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND production_day = p_daytime;

BEGIN
   -- Find the day total
	FOR curNomSum IN c_sum_sent_qty LOOP
		ln_sum_sent_qty:= curNomSum.result;
	END LOOP;

   FOR object_id in c_day_exits LOOP
      lv_record_exists := 'Y';
   END LOOP;

   IF lv_record_exists = 'Y' THEN -- update existing record
      UPDATE cntr_day_dp_nom
      SET SENT_QTY = ln_sum_sent_qty, last_updated_by = p_user
	  WHERE object_id = p_contract_id
	  	AND delivery_point_id = p_delpt_id
	  	AND daytime = p_daytime;

   ELSIF lv_record_exists = 'N' THEN --create new record
      INSERT INTO cntr_day_dp_nom (object_id, delivery_point_id,daytime, SENT_QTY, created_by, created_date)
      VALUES( p_contract_id, p_delpt_id, p_daytime,ln_sum_sent_qty, p_user, sysdate);
   END IF;
END aggrSentSubDailyToDaily;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : aggrAdjSubDailyToDaily
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_nom
--                  cntr_day_dp_nom
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities for the given day. The resulting
--                  quantity is written to the daily nominated quantity table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggrAdjSubDailyToDaily(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime    	DATE,
	p_user         VARCHAR2 DEFAULT NULL

)
--</EC-DOC>
IS
	ln_sum_adj_qty    NUMBER :=0;
   lv_record_exists       VARCHAR2(1):='N';

	CURSOR c_day_exits IS
	SELECT 1 from cntr_day_dp_nom
	WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime;


	CURSOR c_sum_adj_qty IS
		SELECT SUM(Nvl(ADJUSTED_QTY, 0)) result
		FROM cntr_sub_day_dp_nom
		WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND production_day = p_daytime;

BEGIN
   -- Find the day total
	FOR curNomSum IN c_sum_adj_qty LOOP
		ln_sum_adj_qty:= curNomSum.result;
	END LOOP;

   FOR object_id in c_day_exits LOOP
      lv_record_exists := 'Y';
   END LOOP;

   IF lv_record_exists = 'Y' THEN -- update existing record
      UPDATE cntr_day_dp_nom
      SET ADJUSTED_QTY = ln_sum_adj_qty, last_updated_by = p_user
	  WHERE object_id = p_contract_id
	  	AND delivery_point_id = p_delpt_id
	  	AND daytime = p_daytime;

   ELSIF lv_record_exists = 'N' THEN --create new record
      INSERT INTO cntr_day_dp_nom (object_id, delivery_point_id,daytime, ADJUSTED_QTY, created_by, created_date)
      VALUES( p_contract_id, p_delpt_id, p_daytime,ln_sum_adj_qty, p_user, sysdate);
   END IF;
END aggrAdjSubDailyToDaily;






--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateDailyNominationQty
-- Description    : Checks that the given quantity is within the valid range of nomination qunatities
--                  defined by the contract.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Contract.getMinimumDailyNominationQty
--                  EcDp_Contract.getMaximumDailyNominationQty
--
-- Configuration
-- required       :
--
-- Behaviour      : Raises an exception if the quantity is not valid.
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateDailyNominationQty(
	p_contract_id	VARCHAR2,
	p_daytime    	DATE,
	p_qty          NUMBER
)
--</EC-DOC>
IS
	lv_type		VARCHAR2(32);
	ln_dcq      NUMBER;
  	ln_min_qty              NUMBER;
	ln_max_qty              NUMBER;
BEGIN
	-- get validation method
	lv_type := ecdp_contract_attribute.getAttributeString(p_contract_id, 'NOMINATION_VALIDATION' , p_daytime);

	IF lv_type = 'DCQ' THEN
		ln_dcq := EcDp_Sales_Contract.getActualDCQ(p_contract_id, p_daytime);

		ln_min_qty := Nvl( ln_dcq * (ecdp_contract_attribute.getAttributeNumber(p_contract_id, 'MIN_NOM_LIMIT' , p_daytime)/100), 0);
		ln_max_qty := Nvl( ln_dcq * (ecdp_contract_attribute.getAttributeNumber(p_contract_id, 'MAX_NOM_LIMIT' , p_daytime)/100), 0);

		IF p_qty < ln_min_qty OR p_qty > ln_max_qty THEN
		   RAISE_APPLICATION_ERROR(-20510,'The total nominated quantity for '||TO_CHAR(p_daytime,'yyyy-mm-dd')||
		      ' ('||p_qty||') is outside the valid range ('||ln_min_qty||' to '||ln_max_qty||').');
		END IF;
	ELSIF lv_type = 'USER_EXIT' THEN
		ue_Contract_Nomination.validateDailyNominationQty(p_contract_id, p_daytime, p_qty);
	END IF;
END validateDailyNominationQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createDaysForWeek
-- Description    : Generates emty records in cntr_day_dp_nom starting for p_daytime and
--                  the 6 next days for contract p_contract_id and delivery point p_delpt_id
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_nom
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
	ld_end      		DATE;
	ld_daytime  		DATE;
	li_day_record_count	INTEGER;

BEGIN
	ld_end := p_daytime + 6;
	ld_daytime := p_daytime;

	WHILE  ld_daytime <= ld_end	LOOP
		SELECT COUNT(*)
		INTO li_day_record_count
		FROM cntr_day_dp_nom
		WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = ld_daytime;

		IF li_day_record_count <= 0 THEN
			INSERT INTO cntr_day_dp_nom (object_id, delivery_point_id, daytime, nominated_qty, created_by) VALUES (p_contract_id, p_delpt_id,  ld_daytime, 0, p_curr_user);
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
      FROM cntr_day_dp_nom
      WHERE object_id = c_res.contract_id AND delivery_point_id = c_res.delivery_point_id AND daytime = ld_daytime;
      IF li_day_record_count = 0 THEN
         INSERT INTO cntr_day_dp_nom (object_id, delivery_point_id, daytime, nominated_qty, created_by) VALUES (c_res.contract_id, c_res.delivery_point_id,  ld_daytime, 0, p_curr_user);
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
-- Using Tables   : cntr_sub_day_dp_nom
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

    DELETE FROM cntr_sub_day_dp_nom
     WHERE object_id = p_object_id
	 AND delivery_point_id = p_delpt_id
	 AND production_day = p_production_day;

END deleteHourlyData;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createContractDayHours
-- Description    : Generates sub-daily nomination data records for a contract day.
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_nom
--                  cntr_sub_day_dp_nom
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
	p_contract_id  VARCHAR2,
	p_delpt_id     VARCHAR2,
	p_daytime      DATE,
	p_curr_user    VARCHAR2
)
--</EC-DOC>
IS
	li_pointer        INTEGER;
	li_record_count   INTEGER;
	ln_daily_qty      NUMBER := 0;
	ln_hourly_qty     NUMBER := 0;
--  lecd_ProductionDayStart      EcDp_Date_Time.EC_unique_daytime;
	lr_daytime                   Ecdp_Date_Time.Ec_Unique_Daytimes;

	CURSOR c_day_nom IS
		SELECT nominated_qty
		FROM cntr_day_dp_nom
		WHERE object_id = p_contract_id AND delivery_point_id = p_delpt_id AND daytime = p_daytime;

BEGIN
	IF p_contract_id IS NULL or p_delpt_id IS NULL or p_daytime iS NULL THEN
		RAISE_APPLICATION_ERROR(-20103,'createContractDayHours requires p_contract_id, p_delpt_id and p_daytime to be a non-NULL value.');
	END IF;

	lr_daytime:= EcDp_ContractDay.getProductionDayDaytimes('CONTRACT',p_contract_id,p_daytime);

	FOR curNom IN c_day_nom LOOP
		ln_daily_qty:= curNom.nominated_qty;
	END LOOP;

	--Only inserting calculated values for hourly quantity when there are no records from before
	IF getNumberOfSubDailyRecords(p_contract_id,p_delpt_id,p_daytime) = 0 THEN
		ln_hourly_qty:= ln_daily_qty / lr_daytime.COUNT;
	END IF;

	FOR li_pointer in 1..lr_daytime.COUNT LOOP
		SELECT COUNT(*)
			INTO li_record_count
			FROM cntr_sub_day_dp_nom
			WHERE object_id = p_contract_id
			AND delivery_point_id = p_delpt_id
			AND daytime = lr_daytime(li_pointer).daytime
			--AND production_day = p_daytime
			AND summer_time = lr_daytime(li_pointer).summertime_flag;

		IF li_record_count = 0 THEN
			INSERT INTO cntr_sub_day_dp_nom (object_id, delivery_point_id,  daytime, production_day, summer_time, nominated_qty, created_by) VALUES (p_contract_id, p_delpt_id, lr_daytime(li_pointer).daytime, p_daytime, lr_daytime(li_pointer).summertime_flag, ln_hourly_qty, p_curr_user);
		END IF;
	END LOOP;
END createContractDayHours;


END EcDp_Contract_Nomination;