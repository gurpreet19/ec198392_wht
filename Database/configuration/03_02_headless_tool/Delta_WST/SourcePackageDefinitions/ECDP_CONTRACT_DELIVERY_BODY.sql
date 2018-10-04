CREATE OR REPLACE PACKAGE BODY EcDp_Contract_Delivery IS
/******************************************************************************
** Package        :  EcDp_Contract_Delivery, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Find and work with delivery data
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2004 Tor Erik Hauge
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   Initial version (first build / handover to test)
** 11.01.2005  BIH   Added / cleaned up documentation
** 02.12.2005  eideekri	changed reference to delivered_qty to vol_qty. Databasechange.
** 15.12.2005 	eideekri	Added function differenceNominatedDelivered
** 18.01.2006 	eideekri	Added function aggregateVolQty
** 18.01.2006 	eideekri	Added function aggregateMassQty
** 18.01.2006 	eideekri	Added function aggregateEnergyQty
** 18.01.2006 	eideekri	Removed function aggregateSubDailyToDaily (replaced by aggregateVolQty)
** 27.01.2006	eideekri	Corrected createContractDayHours. Also consider mass_qty and energy_qty when generate hourly data.
** 31.01.2006	eideekri	Corrected getSubDailyDeliveredQty. Added summerflag to cursor in order for the query to consider summer/wintertime.
								Corrected differenceNominatedDelivered. Added summerflag to cursor in order for the query to consider summer/wintertime.
** 05.07.2006   kaurrnar  TI#3929: Wrong difference calculation in Delivery screens in differenceNominatedDelivered
** 17.10.2006   kaurrjes  TI#4647: Wrong datatype for UOM in differenceNominatedDelivered
** 06.07.2007	  idrussab	ECPD-5795 Update aggregateVolQty, aggregateMassQty and aggregateEnergyQty to include daytime less than equal to ld_end so that sum will include last day of the month
** 21-07-2009 leongwen ECPD-11578 support multiple timezones
**																to add production object id to pass into the function ecdp_date_time.summertime_flag()
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNumberOfSubDailyRecords
-- Description    : Returns the number of sub-daily (hourly) delivery records for the given contract day.
--
-- Preconditions  : p_date should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_delivery
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
   FROM cntr_sub_day_dp_delivery
   WHERE object_id = p_contract_id
   AND delivery_point_id = p_delivery_point_id
   AND production_day = p_date;
   RETURN li_cnt;
END getNumberOfSubDailyRecords;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNumberOfApprovedDeliveries
-- Description    : Finds the number of approved daily delivery records.
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_delivery
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
  p_contract_id  VARCHAR2,
  p_daytime            DATE
)
RETURN INTEGER
--</EC-DOC>
IS
   li_cnt   INTEGER;
BEGIN
   SELECT COUNT(*) INTO li_cnt
   FROM cntr_day_dp_delivery
   WHERE daytime = p_daytime
   AND record_status = 'A'
   AND object_id  = p_contract_id;

   RETURN li_cnt;
END getNumberOfApprovedDeliveries;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION 		: differenceNominatedDelivered
-- Description    : return the difference between nominated qty and delivered qty.
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

FUNCTION differenceNominatedDelivered(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_daytime            DATE,
  p_time_span 		VARCHAR2,
  p_user		VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
lv_vol_uom CTRL_UNIT.UNIT%TYPE;
lv_mass_uom CTRL_UNIT.UNIT%TYPE;
lv_energy_uom CTRL_UNIT.UNIT%TYPE;
lv_nom_uom CTRL_UNIT.UNIT%TYPE;

ln_vol_qty NUMBER;
ln_mass_qty NUMBER;
ln_energy_qty NUMBER;
ln_nom_qty NUMBER;

ln_difference NUMBER;
ln_delivered NUMBER;


CURSOR c_mth_qty IS
	SELECT vol_qty, mass_qty,energy_qty
			FROM cntr_mth_dp_delivery
			WHERE object_id = p_object_id
			AND delivery_point_id = p_delivery_point_id
			AND daytime = p_daytime;

CURSOR c_day_qty IS
	SELECT vol_qty, mass_qty,energy_qty
			FROM cntr_day_dp_delivery
			WHERE object_id = p_object_id
			AND delivery_point_id = p_delivery_point_id
			AND daytime = p_daytime;

CURSOR c_sub_day_qty IS
	SELECT vol_qty, mass_qty,energy_qty
			FROM cntr_sub_day_dp_delivery
			WHERE object_id = p_object_id
			AND delivery_point_id = p_delivery_point_id
			AND daytime = p_daytime
			AND summer_time = Ecdp_Date_Time.summertime_flag(p_daytime, NULL, EcDp_ProductionDay.findProductionDayDefinition(NULL, p_object_id, p_daytime));


BEGIN

   ln_difference := 0;

   lv_nom_uom := ecdp_contract_attribute.getAttributeString(p_object_id,'NOM_UOM', p_daytime);
   lv_vol_uom := ecdp_contract_attribute.getAttributeString(p_object_id,'DEL_VOL_UOM', p_daytime);
   lv_mass_uom := ecdp_contract_attribute.getAttributeString(p_object_id,'DEL_MASS_UOM', p_daytime);
   lv_energy_uom := ecdp_contract_attribute.getAttributeString(p_object_id,'DEL_ENERGY_UOM', p_daytime);

   -- implement logic if contract does not have a nominated or delivered UOM?

   IF p_time_span = 'MTH' THEN
   	FOR r_mth_qty IN c_mth_qty LOOP
         ln_vol_qty := r_mth_qty.vol_qty;
         ln_mass_qty := r_mth_qty.mass_qty;
         ln_energy_qty := r_mth_qty.energy_qty;

      END LOOP;

   	ln_nom_qty := Nvl(ec_cntr_day_dp_nom.NOMINATED_QTY(p_object_id,p_delivery_point_id,p_daytime), 0);

   	IF lv_nom_uom = lv_vol_uom THEN
   		ln_difference := Nvl(ln_vol_qty, 0) - ln_nom_qty;
   	ELSIF lv_nom_uom = lv_mass_uom THEN
   		ln_difference := Nvl(ln_mass_qty, 0) - ln_nom_qty;
   	ELSIF lv_nom_uom = lv_energy_uom THEN
   		ln_difference := Nvl(ln_energy_qty, 0) - ln_nom_qty;
   	END IF;

   ELSIF p_time_span = 'DAY' THEN
   	FOR r_day_qty IN c_day_qty LOOP
         ln_vol_qty := r_day_qty.vol_qty;
         ln_mass_qty := r_day_qty.mass_qty;
         ln_energy_qty := r_day_qty.energy_qty;
      END LOOP;

   	ln_nom_qty := Nvl(EcDp_Contract_Nomination.getDailyNomination(p_object_id,p_delivery_point_id,p_daytime), 0);

   	IF 	lv_nom_uom = lv_vol_uom THEN
   		ln_difference := Nvl(ln_vol_qty, 0) - ln_nom_qty;
   	ELSIF lv_nom_uom = lv_mass_uom THEN
   		ln_difference := Nvl(ln_mass_qty, 0) - ln_nom_qty;
   	ELSIF lv_nom_uom = lv_energy_uom THEN
   		ln_difference := Nvl(ln_energy_qty, 0) - ln_nom_qty;
   	END IF;

   ELSIF p_time_span = 'SUB_DAY' THEN
   	FOR r_sub_day_qty IN c_sub_day_qty LOOP
         ln_vol_qty := r_sub_day_qty.vol_qty;
         ln_mass_qty := r_sub_day_qty.mass_qty;
         ln_energy_qty := r_sub_day_qty.energy_qty;
      END LOOP;

   	ln_nom_qty := Nvl(EcDp_Contract_Nomination.getSubDailyNomination(p_object_id,p_delivery_point_id,p_daytime), 0);

    IF 	lv_nom_uom = lv_vol_uom THEN
   		ln_difference := Nvl(ln_vol_qty, 0) - ln_nom_qty;
   	ELSIF lv_nom_uom = lv_mass_uom THEN
   		ln_difference := Nvl(ln_mass_qty, 0) - ln_nom_qty;
   	ELSIF lv_nom_uom = lv_energy_uom THEN
   		ln_difference := Nvl(ln_energy_qty, 0) - ln_nom_qty;
		END IF;

	END IF;

	RETURN ln_difference;

END differenceNominatedDelivered;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION aggregateVolQty
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

FUNCTION aggregateVolQty(
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

   	SELECT SUM(vol_qty) INTO ln_result
			FROM cntr_day_dp_delivery
			WHERE object_id = p_object_id
			AND delivery_point_id = p_delivery_point_id
			AND daytime = ld_daytime;

		ln_sum_vol_qty:=ln_sum_vol_qty+Nvl(ln_result,0);

		ld_daytime := ld_daytime + 1;

   END LOOP;

  RETURN ln_sum_vol_qty;

END  aggregateVolQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION aggregateMassQty
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

FUNCTION aggregateMassQty(
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
ln_sum_mass_qty    NUMBER;
ln_result NUMBER;

BEGIN

   ld_end := LAST_DAY(p_daytime);
   ld_daytime := TRUNC (p_daytime, 'MONTH');

	ln_sum_mass_qty :=0;
	ln_result := 0;

   WHILE ld_daytime <= ld_end LOOP

   	SELECT SUM(mass_qty) INTO ln_result
			FROM cntr_day_dp_delivery
			WHERE object_id = p_object_id
			AND delivery_point_id = p_delivery_point_id
			AND daytime = ld_daytime;

		ln_sum_mass_qty:=ln_sum_mass_qty+Nvl(ln_result,0);

		ld_daytime := ld_daytime + 1;

   END LOOP;

  RETURN ln_sum_mass_qty;

END  aggregateMassQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION aggregateEnergyQty
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

FUNCTION aggregateEnergyQty(
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
ln_sum_energy_qty    NUMBER;
ln_result NUMBER;

BEGIN

   ld_end := LAST_DAY(p_daytime);
   ld_daytime := TRUNC (p_daytime, 'MONTH');

	ln_sum_energy_qty :=0;
	ln_result := 0;

   WHILE ld_daytime <= ld_end LOOP

   	SELECT SUM(energy_qty) INTO ln_result
			FROM cntr_day_dp_delivery
			WHERE object_id = p_object_id
			AND delivery_point_id = p_delivery_point_id
			AND daytime = ld_daytime;

		ln_sum_energy_qty:=ln_sum_energy_qty+Nvl(ln_result,0);

		ld_daytime := ld_daytime + 1;

   END LOOP;

  RETURN ln_sum_energy_qty;

END  aggregateEnergyQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION aggregateProfitCentreVolQty
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

FUNCTION aggregateProfitCentreVolQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_profit_centre_id VARCHAR2,
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

   	SELECT SUM(vol_qty) INTO ln_result
			FROM cntr_day_dp_pc_delivery
			WHERE object_id = p_object_id
			AND delivery_point_id = p_delivery_point_id
			AND profit_centre_id = p_profit_centre_id
			AND daytime = ld_daytime;

		ln_sum_vol_qty:=ln_sum_vol_qty+Nvl(ln_result,0);

		ld_daytime := ld_daytime + 1;

   END LOOP;

  RETURN ln_sum_vol_qty;

END  aggregateProfitCentreVolQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION aggregateProfitCentreMassQty
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

FUNCTION aggregateProfitCentreMassQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_profit_centre_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_iterator NUMBER;
ld_end DATE;
ld_daytime DATE;
ln_sum_mass_qty    NUMBER;
ln_result NUMBER;

BEGIN

   ld_end := LAST_DAY(p_daytime);
   ld_daytime := TRUNC (p_daytime, 'MONTH');

	ln_sum_mass_qty :=0;
	ln_result := 0;

   WHILE ld_daytime <= ld_end LOOP

   	SELECT SUM(mass_qty) INTO ln_result
			FROM cntr_day_dp_pc_delivery
			WHERE object_id = p_object_id
			AND delivery_point_id = p_delivery_point_id
			AND profit_centre_id = p_profit_centre_id
			AND daytime = ld_daytime;

		ln_sum_mass_qty:=ln_sum_mass_qty+Nvl(ln_result,0);

		ld_daytime := ld_daytime + 1;

   END LOOP;

  RETURN ln_sum_mass_qty;

END  aggregateProfitCentreMassQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION aggregateProfitCentreEnergyQty
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

FUNCTION aggregateProfitCentreEnergyQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_profit_centre_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_iterator NUMBER;
ld_end DATE;
ld_daytime DATE;
ln_sum_energy_qty    NUMBER;
ln_result NUMBER;

BEGIN

   ld_end := LAST_DAY(p_daytime);
   ld_daytime := TRUNC (p_daytime, 'MONTH');

	ln_sum_energy_qty :=0;
	ln_result := 0;

   WHILE ld_daytime <= ld_end LOOP

   	SELECT SUM(energy_qty) INTO ln_result
			FROM cntr_day_dp_pc_delivery
			WHERE object_id = p_object_id
			AND delivery_point_id = p_delivery_point_id
			AND profit_centre_id = p_profit_centre_id
			AND daytime = ld_daytime;

		ln_sum_energy_qty:=ln_sum_energy_qty+Nvl(ln_result,0);

		ld_daytime := ld_daytime + 1;

   END LOOP;

  RETURN ln_sum_energy_qty;

END  aggregateProfitCentreEnergyQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDailyDeliveredQty
-- Description    : Returns the daily delivered qty for a given contract and delivery point.
--
-- Preconditions  : p_date should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_delivery
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the quantity from the daily record (not as a sum of sub-daily).
--
---------------------------------------------------------------------------------------------------
FUNCTION getDailyDeliveredQty(
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_qty   NUMBER;
   CURSOR c_qty IS
      SELECT NVL(vol_qty,0) AS vol_qty
      FROM cntr_day_dp_delivery
      WHERE object_id = p_contract_id
      AND delivery_point_id = p_delivery_point_id
      AND daytime = p_date;
BEGIN
   ln_qty := NULL;
   FOR r_qty IN c_qty LOOP
      ln_qty := NVL(ln_qty,0) + r_qty.vol_qty;
   END LOOP;
   RETURN ln_qty;
END getDailyDeliveredQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDailyContractDeliveredQty
-- Description    : Returns the total daily delivered qty (for all delivery points) for a given contract.
--
-- Preconditions  : p_date should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_delivery
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the quantity from the daily records (not as a sum of sub-daily).
--
---------------------------------------------------------------------------------------------------
FUNCTION getDailyContractDeliveredQty(
  p_contract_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_qty   NUMBER;
   CURSOR c_qty IS
      SELECT NVL(vol_qty,0) AS vol_qty
      FROM cntr_day_dp_delivery
      WHERE object_id = p_contract_id
      AND daytime = p_date;
BEGIN
   ln_qty := NULL;
   FOR r_qty IN c_qty LOOP
      ln_qty := NVL(ln_qty,0) + r_qty.vol_qty;
   END LOOP;
   RETURN ln_qty;
END getDailyContractDeliveredQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMonthlyContractDeliveredQty
-- Description    : Returns the total monthly delivered qty (for all delivery points) for a given contract.
--
-- Preconditions  : p_date should be a logical contract month (zero days/hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_delivery
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the sum of the quantities from the daily records.
--
---------------------------------------------------------------------------------------------------
FUNCTION getMonthlyContractDeliveredQty(
  p_contract_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_qty   NUMBER;
   CURSOR c_qty IS
      SELECT NVL(vol_qty,0) AS vol_qty
      FROM cntr_day_dp_delivery
      WHERE object_id = p_contract_id
      AND daytime >= p_date AND daytime < add_months(p_date,1);
BEGIN
   ln_qty := NULL;
   FOR r_qty IN c_qty LOOP
      ln_qty := NVL(ln_qty,0) + r_qty.vol_qty;
   END LOOP;
   RETURN ln_qty;
END getMonthlyContractDeliveredQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getYearlyContractDeliveredQty
-- Description    : Returns the total yearly delivered qty (for all delivery points) for a given contract.
--
-- Preconditions  : p_contract_year should be a logical contract year (zero months/days/hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_delivery
--
-- Using functions: EcDp_Contract.getContractYearStartDate
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the sum of the quantities from the daily records.
--
---------------------------------------------------------------------------------------------------
FUNCTION getYearlyContractDeliveredQty(
  p_contract_id   VARCHAR2,
  p_contract_year       DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ld_start_date  DATE;
   ld_end_date    DATE;
   ln_qty   NUMBER;
   CURSOR c_qty (p_from DATE, p_to DATE) IS
      SELECT NVL(vol_qty,0) AS vol_qty
      FROM cntr_day_dp_delivery
      WHERE object_id = p_contract_id
      AND daytime >= p_from AND daytime < p_to;
BEGIN
   ld_start_date := EcDp_Contract.getContractYearStartDate(p_contract_id, p_contract_year);
   ld_end_date := EcDp_Contract.getContractYearStartDate(p_contract_id, ADD_MONTHS(p_contract_year,12));
   ln_qty := NULL;
   FOR r_qty IN c_qty(ld_start_date, ld_end_date) LOOP
      ln_qty := NVL(ln_qty,0) + r_qty.vol_qty;
   END LOOP;
   RETURN ln_qty;
END getYearlyContractDeliveredQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubDailyDeliveredQty
-- Description    : Returns the sub-daily delivered qty for a given contract and delivery point.
--
-- Preconditions  : p_daytime should be a logical contract hour (zero minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_delivery
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the quantity from the sub-daily record.
--
---------------------------------------------------------------------------------------------------
FUNCTION getSubDailyDeliveredQty(
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_daytime             DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_qty   NUMBER;

   CURSOR c_qty IS
      SELECT NVL(vol_qty,0) AS vol_qty
      FROM cntr_sub_day_dp_delivery
      WHERE object_id = p_contract_id
      AND delivery_point_id = p_delivery_point_id
      AND daytime = p_daytime
      AND summer_time = Ecdp_Date_Time.summertime_flag(p_daytime, NULL, EcDp_ProductionDay.findProductionDayDefinition(NULL, p_contract_id, p_daytime));
BEGIN
   ln_qty := NULL;
   FOR r_qty IN c_qty LOOP
    ln_qty := NVL(ln_qty,0) + r_qty.vol_qty;
   END LOOP;
	RETURN ln_qty;
END getSubDailyDeliveredQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : aggregateSubDailyToDaily
-- Description    : Sums up hourly delivery quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_sub_day_dp_delivery
--                  cntr_day_dp_delivery
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities (VOL_QTY, MASS_QTY AND ENERGY_QTY) for the given day. The resulting
--                  quantity is written to the daily delivered quantity table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateSubDailyToDaily(
	p_contract_id   	VARCHAR2,
	p_delivery_point_id   	VARCHAR2,
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
		FROM cntr_sub_day_dp_delivery
		WHERE object_id = p_contract_id AND delivery_point_id = p_delivery_point_id AND production_day = p_daytime;
BEGIN
	FOR curNomSum IN c_sum_vol_qty LOOP
		ln_sum_vol_qty := curNomSum.vol_result;
		ln_sum_mass_qty := curNomSum.mass_result;
		ln_sum_energy_qty := curNomSum.energy_result;
	END LOOP;

	UPDATE cntr_day_dp_delivery
	SET vol_qty = ln_sum_vol_qty, mass_qty = ln_sum_mass_qty, energy_qty = ln_sum_energy_qty, last_updated_by = p_user
	WHERE object_id = p_contract_id AND delivery_point_id = p_delivery_point_id AND daytime = p_daytime;
END aggregateSubDailyToDaily;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createContractDayHours
-- Description    : Generates sub-daily delivery data records for a contract day.
--
-- Preconditions  : p_daytime should be a logical contract day (zero hours/minutes/seconds)
-- Postconditions :
--
-- Using tables   : cntr_day_dp_delivery
--                  cntr_sub_day_dp_delivery
--
-- Using functions: getNumberOfApprovedDeliveries
--                  getNumberOfSubDailyRecords
--                  EcDp_Contract.getContractDayHours
--
-- Configuration
-- required       :
--
-- Behaviour      : First checks if the user has suffucient priviliges if the day has been approved.
--                  Then generates any missing hourly rows for the given contract day, taking contract
--                  day offsets and daylight savings time transitions into account.
--                  If no sub-daily records already existed then the daily quantity is distributed
--                  evenly to the new records. Otherwise, any new records get zero quantity.
--
---------------------------------------------------------------------------------------------------
PROCEDURE createContractDayHours(
	p_contract_id	VARCHAR2,
	p_delpt_id     	VARCHAR2,
	p_daytime       DATE,
	p_curr_user		VARCHAR2,
	p_accessLevel	INTEGER
)
--</EC-DOC>
IS
	li_pointer			INTEGER;
	li_record_count 	INTEGER;

	ln_daily_vol_qty 		NUMBER := 0;
	ln_daily_mass_qty 		NUMBER := 0;
	ln_daily_energy_qty 		NUMBER := 0;

	ln_hourly_vol_qty NUMBER :=0;
	ln_hourly_mass_qty NUMBER :=0;
	ln_hourly_energy_qty NUMBER :=0;

	lr_daytime EcDp_Date_Time.Ec_Unique_Daytimes;

	CURSOR c_day_delivery (cp_contract_id VARCHAR2, cp_delpt_id VARCHAR2, cp_daytime DATE) IS
		SELECT vol_qty, mass_qty, energy_qty
		FROM cntr_day_dp_delivery
		WHERE object_id = cp_contract_id
			AND delivery_point_id = cp_delpt_id
			AND daytime = cp_daytime;

BEGIN
	IF p_contract_id IS NULL or p_delpt_id IS NULL or p_daytime iS NULL
		THEN
			RAISE_APPLICATION_ERROR(-20103,'createContractDayHours requires p_contract_id, p_delpt_id and p_daytime to be a non-NULL value.');
	END IF;
   IF getNumberOfApprovedDeliveries(p_contract_id,p_daytime) > 0 AND p_accessLevel<60 THEN
      RAISE_APPLICATION_ERROR(-20509,'Unsufficient priviliges to generate hourly records for '||to_char(p_daytime,'yyyy-mm-dd'));
   END IF;

	lr_daytime:=EcDp_ContractDay.getProductionDayDaytimes('CONTRACT',p_contract_id,p_daytime);
	FOR curNom IN c_day_delivery(p_contract_id, p_delpt_id, p_daytime) LOOP
		ln_daily_vol_qty := curNom.vol_qty;
		ln_daily_mass_qty := curNom.mass_qty;
		ln_daily_energy_qty := curNom.energy_qty;
	END LOOP;

	--Only inserting calculated values for hourly quantity when there are no records from before
	IF getNumberOfSubDailyRecords(p_contract_id,p_delpt_id,p_daytime) = 0 THEN
		ln_hourly_vol_qty := ln_daily_vol_qty / lr_daytime.COUNT;
		ln_hourly_mass_qty := ln_daily_mass_qty / lr_daytime.COUNT;
		ln_hourly_energy_qty := ln_daily_energy_qty / lr_daytime.COUNT;
	END IF;

	FOR li_pointer in 1..lr_daytime.COUNT LOOP
		SELECT COUNT(*)
		INTO li_record_count
		FROM cntr_sub_day_dp_delivery
		WHERE object_id = p_contract_id
			AND delivery_point_id = p_delpt_id
			AND daytime = lr_daytime(li_pointer).daytime
			--AND production_day = p_daytime
			AND summer_time = lr_daytime(li_pointer).summertime_flag;

		IF li_record_count = 0
			THEN
				INSERT INTO cntr_sub_day_dp_delivery (object_id, delivery_point_id,  daytime, production_day, summer_time, vol_qty, mass_qty, energy_qty, created_by)
				VALUES (p_contract_id, p_delpt_id, lr_daytime(li_pointer).daytime, p_daytime, lr_daytime(li_pointer).summertime_flag, ln_hourly_vol_qty,ln_hourly_mass_qty, ln_hourly_energy_qty, p_curr_user);
		END IF;
	END LOOP;
END createContractDayHours;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNominationPointId
-- Description    : The the nomination point id for a contract and a delivery point
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
FUNCTION getNominationPointId(p_contract_id VARCHAR2,
							p_delivery_point_id VARCHAR2,
							p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
	CURSOR c_nom_point (cp_contract_id VARCHAR2, cp_delpt_id VARCHAR2, cp_daytime DATE) IS
  		SELECT object_id
		FROM   nomination_point
		WHERE  contract_id =  cp_contract_id
      		AND delivery_point_id = cp_delpt_id
      		AND start_date <= p_daytime
      		AND Nvl(end_date, p_daytime+1) > p_daytime;


     lv_nomination_point_id VARCHAR2(32);
BEGIN
	FOR curNompnt IN c_nom_point(p_contract_id, p_delivery_point_id, p_daytime) LOOP
		lv_nomination_point_id := curNompnt.object_id;
	END LOOP;

	RETURN lv_nomination_point_id;

END getNominationPointId;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDelviertPointByType
-- Description    : The the delivery point by type. If more than one delivery point are assosiated to the contract, NULL is returned
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
FUNCTION getDelviertPointByType(p_contract_id VARCHAR2,
							p_dp_type VARCHAR2,
							p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
	CURSOR c_dp (cp_contract_id VARCHAR2, cp_dp_type VARCHAR2, cp_daytime DATE) IS
  		SELECT n.delivery_point_id
		FROM   nomination_point n,
				delivery_point d,
				delpnt_version v
		WHERE  n.contract_id =  cp_contract_id
      		AND n.delivery_point_id = d.object_id
          and d.object_id = v.object_id
          and v.delpnt_type = cp_dp_type
          AND v.daytime <= cp_daytime
      		AND Nvl(v.end_date, cp_daytime+1) > cp_daytime
          AND n.start_date <= cp_daytime
      		AND Nvl(n.end_date, cp_daytime+1) > cp_daytime;


     lv_dp_id VARCHAR2(32) := NULL;
BEGIN
	FOR curDp IN c_dp(p_contract_id, p_dp_type, p_daytime) LOOP
		-- return NULL if already set. Meast that there is more than one
		IF(lv_dp_id IS NOT NULL)THEN
			lv_dp_id := NULL;
		ELSE
			lv_dp_id := curDp.delivery_point_id;
		END IF;
	END LOOP;

	RETURN lv_dp_id;

END getDelviertPointByType;


END EcDp_Contract_Delivery;