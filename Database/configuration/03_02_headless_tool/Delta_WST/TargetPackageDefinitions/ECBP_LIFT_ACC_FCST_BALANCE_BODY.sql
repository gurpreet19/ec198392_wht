CREATE OR REPLACE PACKAGE BODY EcBp_Lift_Acc_Fcst_Balance IS
/****************************************************************
** Package        :  EcBp_Lift_Acc_Fcst_Balance; body part
**
** $Revision: 1.11.4.12 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  12.06.2008	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 15.11.2011  leeeewei Added sum function to cursor curNom in calcEstClosingBalanceDay
** 29.05.2012  meisihil Added new function getInitBalance, and updated calcEstClosingBalanceDay to read initial balance for forecast
** 12.09.2012  meisihil ECPD-20962: Included balance delta in calcEstClosingBalanceDay and calcEstClosingBalanceSubDay
** 21.12.2012  meisihil ECPD-22567: Updated global variables to distinguish between forecasts
** 24.01.2013  meisihil ECPD-20056: Updated function calcEstClosingBalanceDay to support liftings spread over hours
******************************************************************/

/**private global session variables **/
TYPE prevDate IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE prevQty IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE prevObject IS TABLE OF VARCHAR2(32) INDEX BY BINARY_INTEGER;
TYPE prevForecast IS TABLE OF VARCHAR2(32) INDEX BY BINARY_INTEGER;
TYPE prevSummerTime IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
gv_prev_date prevDate;
gv_prev_date2 prevDate;
gv_prev_date3 prevDate;
gv_prev_qty prevQty;
gv_prev_qty2 prevQty;
gv_prev_qty3 prevQty;
gv_prev_object prevObject;
gv_prev_object2 prevObject;
gv_prev_object3 prevObject;
gv_prev_forecast prevForecast;
gv_prev_forecast2 prevForecast;
gv_prev_forecast3 prevForecast;

gv_prev_sub_date prevDate;
gv_prev_sub_date2 prevDate;
gv_prev_sub_date3 prevDate;
gv_prev_sub_qty prevQty;
gv_prev_sub_qty2 prevQty;
gv_prev_sub_qty3 prevQty;
gv_prev_sub_object prevObject;
gv_prev_sub_object2 prevObject;
gv_prev_sub_object3 prevObject;
gv_prev_sub_forecast prevForecast;
gv_prev_sub_forecast2 prevForecast;
gv_prev_sub_forecast3 prevForecast;
gv_prev_sub_st_flag prevSummerTime;
gv_prev_sub_st_flag2 prevSummerTime;
gv_prev_sub_st_flag3 prevSummerTime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAdjustments (private)
-- Description    : get forecast adjustments for defined lifting account and period
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
FUNCTION getAdjustments(p_object_id VARCHAR2,
               p_forecast_id   VARCHAR2,
               p_from_date   DATE,
               p_to_date   DATE,
               p_xtra_qty  NUMBER DEFAULT 0) RETURN NUMBER
--</EC-DOC>
 IS

  CURSOR c_debit(cp_lifting_account_id VARCHAR2,cp_forecast_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
  		SELECT decode(cp_xtra_qty, 0, SUM(adj_qty), 1, SUM(adj_qty2), 2, SUM(adj_qty3)) adj_qty
		  FROM fcst_lift_acc_adj
		 WHERE object_id = cp_lifting_account_id
		   AND forecast_id = cp_forecast_id
		   AND daytime >= cp_from_date
		   AND daytime < cp_to_date;

	CURSOR c_credit(cp_lifting_account_id VARCHAR2,cp_forecast_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
  		SELECT decode(cp_xtra_qty, 0, SUM(adj_qty), 1, SUM(adj_qty2), 2, SUM(adj_qty3)) adj_qty
		  FROM fcst_lift_acc_adj
		 WHERE to_object_id = cp_lifting_account_id
		   AND forecast_id = cp_forecast_id
		   AND daytime >= cp_from_date
		   AND daytime < cp_to_date;

	CURSOR c_single(cp_lifting_account_id VARCHAR2,cp_forecast_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
  		SELECT decode(cp_xtra_qty, 0, SUM(adj_qty), 1, SUM(adj_qty2), 2, SUM(adj_qty3)) adj_qty
		  FROM fcst_lift_acc_adj_single
		 WHERE object_id = cp_lifting_account_id
		   AND forecast_id = cp_forecast_id
		   AND daytime >= cp_from_date
		   AND daytime < cp_to_date;

	ln_debit_qty      NUMBER;
	ln_credit_qty     NUMBER;
	ln_single_qty     NUMBER;

BEGIN
	FOR curDebit IN c_debit(p_object_id, p_forecast_id, p_from_date, p_to_date, p_xtra_qty) LOOP
		ln_debit_qty := curDebit.adj_qty;
	END LOOP;

	FOR curCredit IN c_credit(p_object_id, p_forecast_id, p_from_date, p_to_date, p_xtra_qty) LOOP
		ln_credit_qty := curCredit.adj_qty;
	END LOOP;

	FOR curSingle IN c_single(p_object_id, p_forecast_id, p_from_date, p_to_date, p_xtra_qty) LOOP
		ln_single_qty := curSingle.adj_qty;
	END LOOP;

	RETURN Nvl(ln_credit_qty, 0) - Nvl(ln_debit_qty, 0) + nvl(ln_single_qty,0);

END getAdjustments;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAdjustmentsSubDay
-- Description    : Get all adjustments up til an hour. It only support hourly data
--
-- Preconditions  :  To date is made inclusive
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
FUNCTION getAdjustmentsSubDay(p_object_id VARCHAR2,
               p_forecast_id   VARCHAR2,
               p_from_date DATE,
               p_to_date DATE,
               p_xtra_qty  NUMBER DEFAULT 0) RETURN NUMBER
--</EC-DOC>
 IS

BEGIN
  RETURN getAdjustments(p_object_id, p_forecast_id, p_from_date, (p_to_date + 1/24), p_xtra_qty);

END getAdjustmentsSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcEstClosingBalanceDay
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :                                                                                                                          --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcEstClosingBalanceDay(p_object_id  VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--<EC-DOC>
IS
	CURSOR curProd(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_from DATE, cp_to DATE) IS
	SELECT sum(f.forecast_qty) forecast_qty, sum(f.forecast_qty2) forecast_qty2, sum(f.forecast_qty3) forecast_qty3
	FROM  lift_acc_day_fcst_fcast f
	WHERE f.object_id = cp_object_id
		AND f.forecast_id = cp_forecast_id
		AND f.daytime >= cp_from
	    AND f.daytime < cp_to;

	CURSOR curNom(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_cargo_off_qty_ind VARCHAR2,cp_from DATE, cp_to DATE) IS
	SELECT
		SUM(decode(cp_cargo_off_qty_ind,'N',f.grs_vol_nominated, nvl(ecbp_storage_lift_nomination.getLiftedVol(f.parcel_no,null),f.grs_vol_nominated))) NOMINATED_QTY,
		SUM(decode(cp_cargo_off_qty_ind,'N',f.grs_vol_nominated2,nvl(ecbp_storage_lift_nomination.getLiftedVol(f.parcel_no,1),   f.grs_vol_nominated2))) NOMINATED_QTY2,
		SUM(decode(cp_cargo_off_qty_ind,'N',f.grs_vol_nominated3,nvl(ecbp_storage_lift_nomination.getLiftedVol(f.parcel_no,2),   f.grs_vol_nominated3))) NOMINATED_QTY3,
        SUM(decode(cp_cargo_off_qty_ind,'N',f.balance_delta_qty,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(f.parcel_no),   f.balance_delta_qty))) balance_delta_qty,
        SUM(decode(cp_cargo_off_qty_ind,'N',f.balance_delta_qty2,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(f.parcel_no,1),f.balance_delta_qty2))) balance_delta_qty2,
        SUM(decode(cp_cargo_off_qty_ind,'N',f.balance_delta_qty3,nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(f.parcel_no,2),f.balance_delta_qty3))) balance_delta_qty3
	FROM  stor_fcst_lift_nom f
	WHERE f.lifting_account_id = cp_object_id
		AND f.forecast_id = cp_forecast_id
		AND nvl(f.bl_date, f.NOM_FIRM_DATE) >= cp_from
	    AND nvl(f.bl_date, f.NOM_FIRM_DATE) < cp_to
	    AND nvl(f.DELETED_IND, 'N') <> 'Y'
	    AND Ec_cargo_fcst_transport.cargo_status(f.cargo_no, f.forecast_id) <> 'D';

	CURSOR curNom_sub_day(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2,cp_from DATE, cp_to DATE, cp_xtra_qty NUMBER) IS
	SELECT
        SUM(ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(f.forecast_id, f.PARCEL_NO, sn.production_day, NULL, cp_xtra_qty)) NOMINATED_QTY,
        SUM(ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(f.forecast_id, f.PARCEL_NO, sn.production_day, 'BALANCE_DELTA', cp_xtra_qty)) balance_delta_qty
	FROM  stor_fcst_lift_nom f,
      	  (SELECT distinct forecast_id, production_day, parcel_no FROM stor_fcst_sub_day_lift_nom) sn
	WHERE f.lifting_account_id = cp_object_id
		AND f.forecast_id = cp_forecast_id
		AND f.parcel_no = sn.parcel_no
		AND f.forecast_id = sn.forecast_id
		AND sn.production_day >= cp_from
	    AND sn.production_day < cp_to
	    AND nvl(f.DELETED_IND, 'N') <> 'Y'
	    AND Ec_cargo_fcst_transport.cargo_status(f.cargo_no, f.forecast_id) <> 'D';

  ld_forecast_start_day DATE;
  ld_start_mth DATE;
  ln_prod 	NUMBER;
  ln_nom	NUMBER;
  ln_balance_delta NUMBER;
  ln_firstday_opening_bal NUMBER;
  lv_storage_type VARCHAR2(32);
  ln_closing_balance NUMBER;
  ln_adjustment NUMBER;
  ld_from_date DATE;
  ld_to_date DATE;
  lv_read_sub_day VARCHAR2(1);

  lv_prev_qty   NUMBER;
  lv_prev_date  DATE;
  lv_prev_object  VARCHAR2(32);

  ln_index NUMBER := 0;
BEGIN
    lv_read_sub_day := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_sub_day');

	IF p_xtra_qty = 1 THEN
		FOR i IN 1..gv_prev_object2.count LOOP
			IF gv_prev_object2(i) = p_object_id AND gv_prev_forecast2(i) = p_forecast_id THEN
				ln_index := i;
				EXIT;
			END IF;
		END LOOP;
		IF ln_index = 0 THEN
			ln_index := gv_prev_qty2.count + 1;
			gv_prev_qty2(ln_index):=0;
			gv_prev_date2(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
			gv_prev_object2(ln_index) := '0';
			gv_prev_forecast2(ln_index) := '0';
		END IF;

		--use prev_date2 and prev_qty2
		lv_prev_date:=gv_prev_date2(ln_index);
		lv_prev_qty:=gv_prev_qty2(ln_index);
		lv_prev_object:=gv_prev_object2(ln_index);
	ELSIF p_xtra_qty = 2 THEN
		FOR i IN 1..gv_prev_object3.count LOOP
			IF gv_prev_object3(i) = p_object_id AND gv_prev_forecast3(i) = p_forecast_id THEN
				ln_index := i;
				EXIT;
			END IF;
		END LOOP;
		IF ln_index = 0 THEN
			ln_index := gv_prev_qty3.count + 1;
			gv_prev_qty3(ln_index):=0;
			gv_prev_date3(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
			gv_prev_object3(ln_index) := '0';
			gv_prev_forecast3(ln_index) := '0';
		END IF;

		--use prev_date3 and prev_qty3
		lv_prev_date:=gv_prev_date3(ln_index);
		lv_prev_qty:=gv_prev_qty3(ln_index);
		lv_prev_object:=gv_prev_object3(ln_index);
	ELSE
		--use prev_date and prev_qty
		FOR i IN 1..gv_prev_object.count LOOP
			IF gv_prev_object(i) = p_object_id AND gv_prev_forecast(i) = p_forecast_id THEN
				ln_index := i;
				EXIT;
			END IF;
		END LOOP;
		IF ln_index = 0 THEN
			ln_index := gv_prev_qty.count + 1;
			gv_prev_qty(ln_index):=0;
			gv_prev_date(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
			gv_prev_object(ln_index) := '0';
			gv_prev_forecast(ln_index) := '0';
		END IF;

		lv_prev_date:=gv_prev_date(ln_index);
		lv_prev_qty:=gv_prev_qty(ln_index);
		lv_prev_object:=gv_prev_object(ln_index);
	END IF;

	ld_forecast_start_day := ec_forecast.start_date(p_forecast_id);
	ld_start_mth := TRUNC(ld_forecast_start_day, 'MONTH');

	IF (lv_prev_object = p_object_id) AND (trunc(lv_prev_date,'DD') - trunc(p_daytime,'DD')=0) THEN
		RETURN NVL(lv_prev_qty,0);
	ELSIF (lv_prev_object = p_object_id) AND (trunc(lv_prev_date,'DD') - trunc(p_daytime-1,'DD')=0) THEN
		ln_firstday_opening_bal := NVL(lv_prev_qty,0);
		ld_forecast_start_day := p_daytime;
	ELSE
		-- Get initial opening balance from forecast
		ln_firstday_opening_bal := getInitBalance(p_object_id, p_forecast_id, p_xtra_qty);
		IF ln_firstday_opening_bal IS NULL THEN
			-- No initial opening balance on forecast - find from actual
			IF (ld_forecast_start_day = ld_start_mth) THEN
				-- get opening balance month
				ln_firstday_opening_bal := EcBp_Lift_Acc_Balance.calcEstOpeningBalanceMth(p_object_id, ld_start_mth, p_xtra_qty );
			ELSE
				-- get opening balance for forecast
				ln_firstday_opening_bal := Nvl(EcBp_Lift_Acc_Balance.calcEstClosingBalanceDay(p_object_id, ld_forecast_start_day-1,p_xtra_qty),0);
			END IF;
		END IF;
	END IF;

  	-- get production
  	FOR c_Prod IN curProd (p_object_id, p_forecast_id, ld_forecast_start_day, p_daytime+1) LOOP
	   IF (p_xtra_qty = 1) THEN
		  ln_prod := c_Prod.forecast_qty2;
	   ELSIF (p_xtra_qty = 2) THEN
		  ln_prod := c_Prod.forecast_qty3;
	   ELSE
	      ln_prod := c_Prod.forecast_qty;
	   END IF;
	END LOOP;

	-- get nominations
    IF nvl(lv_read_sub_day, 'N') = 'Y' THEN
		FOR c_Nom IN curNom_sub_day (p_object_id, p_forecast_id, ld_forecast_start_day, p_daytime+1, p_xtra_qty) LOOP
		   ln_nom := c_Nom.NOMINATED_QTY;
		   ln_balance_delta := c_Nom.balance_delta_qty;
		END LOOP;
	ELSE
		FOR c_Nom IN curNom (p_object_id, p_forecast_id,nvl(ec_forecast.cargo_off_qty_ind(p_forecast_id),'N'), ld_forecast_start_day, p_daytime+1) LOOP
	   IF (p_xtra_qty = 1) THEN
		  ln_nom := c_Nom.NOMINATED_QTY2;
		  ln_balance_delta := c_Nom.balance_delta_qty2;
	   ELSIF (p_xtra_qty = 2) THEN
		  ln_nom := c_Nom.NOMINATED_QTY3;
		  ln_balance_delta := c_Nom.balance_delta_qty3;
	   ELSE
		  ln_nom := c_Nom.NOMINATED_QTY;
		  ln_balance_delta := c_Nom.balance_delta_qty;
	   END IF;
		END LOOP;
	END IF;


	ln_adjustment := Nvl(getAdjustments(p_object_id, p_forecast_id, ld_forecast_start_day, p_daytime+1, p_xtra_qty),0);
  	lv_storage_type := ec_stor_version.storage_type(ec_lifting_account.storage_id(p_object_id), p_daytime, '<=');
  	IF (lv_storage_type = 'IMPORT') THEN
		ln_closing_balance := ln_firstday_opening_bal + Nvl(ln_nom,0) - Nvl(ln_prod,0);
	ELSE
		ln_closing_balance := ln_firstday_opening_bal - Nvl(ln_nom,0) + Nvl(ln_prod,0);
	END IF;

	ln_closing_balance := ln_closing_balance + nvl(ln_adjustment,0) - nvl(ln_balance_delta,0);

	IF p_xtra_qty=1 THEN
		gv_prev_date2(ln_index):=p_daytime;
		gv_prev_qty2(ln_index):=ln_closing_balance;
		gv_prev_object2(ln_index):=p_object_id;
		gv_prev_forecast2(ln_index):=p_forecast_id;
	ELSIF p_xtra_qty=2 THEN
		gv_prev_date3(ln_index):=p_daytime;
		gv_prev_qty3(ln_index):=ln_closing_balance;
		gv_prev_object3(ln_index):=p_object_id;
		gv_prev_forecast3(ln_index):=p_forecast_id;
	ELSE
		gv_prev_date(ln_index):=p_daytime;
		gv_prev_qty(ln_index):=ln_closing_balance;
		gv_prev_object(ln_index):=p_object_id;
		gv_prev_forecast(ln_index):=p_forecast_id;
	END IF;

	RETURN ln_closing_balance;

END calcEstClosingBalanceDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcEstClosingBalanceSubDay
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :                                                                                                                          --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcEstClosingBalanceSubDay(p_object_id  VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--<EC-DOC>
IS
	CURSOR c_qty (cp_object_id  VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE) IS
		select sum(f.forecast_qty) qty, sum(f.forecast_qty2) qty2, sum(f.forecast_qty3) qty3
		  from lift_acc_sub_day_fcst_fc f
		 where f.object_id = cp_object_id
		   and f.forecast_id = cp_forecast_id
		   and f.daytime  between cp_start and cp_end;

	CURSOR c_qty_summer_intercept (cp_object_id  VARCHAR2, cp_forecast_id VARCHAR2, cp_start DATE, cp_end DATE, cp_summer_time VARCHAR2) IS
		select sum(f.forecast_qty) qty, sum(f.forecast_qty2) qty2, sum(f.forecast_qty3) qty3
		  from lift_acc_sub_day_fcst_fc f
		 where f.object_id = cp_object_id
		   and f.forecast_id = cp_forecast_id
		   and f.daytime  between cp_start and cp_end
		   and f.summer_time = cp_summer_time;

	CURSOR c_sumerTime_flag(cp_object_id VARCHAR2, cp_start DATE, cp_end DATE) IS
		SELECT ecdp_date_time.summertime_flag(t.daytime) summerFlag
		from lift_acc_sub_day_fcst_fc t
		where t.daytime >= cp_start
			AND t.daytime <= cp_end
			AND t.object_id = cp_object_id;


	ln_closing_balance      NUMBER;
	ln_day_tot_lifted		NUMBER;
	ln_day_official			NUMBER	:=	0;
	ln_adjustment 			NUMBER;
	ld_production_day DATE;
	ld_startDate      DATE;
	lv_storage_type	VARCHAR2(32);
	lv_summer_flag VARCHAR2(32);

	lv_prev_qty   NUMBER;
	lv_prev_date  DATE;
	lv_prev_object  VARCHAR2(32);
	lv_prev_st_flag  VARCHAR2(1);
--	lv_use_prev	BOOLEAN;

	ln_index NUMBER := 0;
BEGIN
	IF p_xtra_qty = 1 THEN
		FOR i IN 1..gv_prev_sub_object2.count LOOP
			IF gv_prev_sub_object2(i) = p_object_id AND gv_prev_sub_forecast2(i) = p_forecast_id THEN
				ln_index := i;
				EXIT;
			END IF;
		END LOOP;
		IF ln_index = 0 THEN
			ln_index := gv_prev_sub_qty2.count + 1;
			gv_prev_sub_qty2(ln_index):=0;
			gv_prev_sub_date2(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
			gv_prev_sub_object2(ln_index) := '0';
			gv_prev_sub_st_flag2(ln_index) := 'N';
			gv_prev_sub_forecast2(ln_index) := '0';
		END IF;

		--use prev_date2 and prev_qty2
		lv_prev_date:=gv_prev_sub_date2(ln_index);
		lv_prev_qty:=gv_prev_sub_qty2(ln_index);
		lv_prev_object:=gv_prev_sub_object2(ln_index);
		lv_prev_st_flag:=gv_prev_sub_st_flag2(ln_index);
	ELSIF p_xtra_qty = 2 THEN
		FOR i IN 1..gv_prev_sub_object3.count LOOP
			IF gv_prev_sub_object3(i) = p_object_id AND gv_prev_sub_forecast3(i) = p_forecast_id THEN
				ln_index := i;
				EXIT;
			END IF;
		END LOOP;
		IF ln_index = 0 THEN
			ln_index := gv_prev_sub_qty3.count + 1;
			gv_prev_sub_qty3(ln_index):=0;
			gv_prev_sub_date3(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
			gv_prev_sub_object3(ln_index) := '0';
			gv_prev_sub_st_flag3(ln_index) := 'N';
			gv_prev_sub_forecast3(ln_index) := '0';
		END IF;

		--use prev_date3 and prev_qty3
		lv_prev_date:=gv_prev_sub_date3(ln_index);
		lv_prev_qty:=gv_prev_sub_qty3(ln_index);
		lv_prev_object:=gv_prev_sub_object3(ln_index);
		lv_prev_st_flag:=gv_prev_sub_st_flag3(ln_index);
	ELSE
		--use prev_date and prev_qty
		FOR i IN 1..gv_prev_sub_object.count LOOP
			IF gv_prev_sub_object(i) = p_object_id AND gv_prev_sub_forecast(i) = p_forecast_id THEN
				ln_index := i;
				EXIT;
			END IF;
		END LOOP;
		IF ln_index = 0 THEN
			ln_index := gv_prev_sub_qty.count + 1;
			gv_prev_sub_qty(ln_index):=0;
			gv_prev_sub_date(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
			gv_prev_sub_object(ln_index) := '0';
			gv_prev_sub_st_flag(ln_index) := 'N';
			gv_prev_sub_forecast(ln_index) := '0';
		END IF;

		lv_prev_date:=gv_prev_sub_date(ln_index);
		lv_prev_qty:=gv_prev_sub_qty(ln_index);
		lv_prev_object:=gv_prev_sub_object(ln_index);
		lv_prev_st_flag:=gv_prev_sub_st_flag(ln_index);
	END IF;

	IF (lv_prev_object = p_object_id) AND (trunc(lv_prev_date,'HH') - trunc(p_daytime,'HH')=0) AND (lv_prev_st_flag = p_summer_time) THEN
		RETURN NVL(lv_prev_qty,0);
	ELSE
		ld_production_day := EcDp_ProductionDay.getProductionDay('STORAGE', ec_lifting_account.storage_id(p_object_id), p_daytime, p_summer_time);
	    ld_startDate      := EcDp_ProductionDay.getProductionDayStart('STORAGE', ec_lifting_account.storage_id(p_object_id), ld_production_day);

		-- get opening balance of the day
		ln_closing_balance := nvl(calcEstClosingBalanceDay(p_object_id, p_forecast_id, ld_production_day - 1, p_xtra_qty), 0);
	END IF;

	-- get sub day numbers
	ln_adjustment := Nvl(getAdjustmentsSubDay(p_object_id, p_forecast_id, ld_startDate, p_daytime, p_xtra_qty),0);

	--checking the summer time flag
	FOR curIn IN c_sumerTime_flag(p_object_id, ld_startDate, p_daytime) LOOP
		lv_summer_flag := curIn.summerFlag;
	END LOOP;

	IF(p_summer_time != lv_summer_flag)THEN
		-- Get forecast/official production during an intercept
		FOR curQty IN c_qty_summer_intercept(p_object_id, p_forecast_id, ld_startDate, p_daytime, p_summer_time) LOOP
			IF (p_xtra_qty = 1) THEN
				ln_day_official := curQty.qty2;
			ELSIF (p_xtra_qty = 2) THEN
				ln_day_official := curQty.qty3;
			ELSE
				ln_day_official := curQty.qty;
			END IF;
		END LOOP;

		-- Get lifted qty during an intercept
		ln_day_tot_lifted := Nvl(EcDp_Stor_Fcst_Balance.getAccEstLiftedQtySubDay(p_object_id, p_forecast_id, ld_startDate, p_daytime, p_xtra_qty, 'Y', p_summer_time),0);
    ELSE
		-- Get forecast/official production normal operations
		FOR curQty IN c_qty(p_object_id, p_forecast_id, ld_startDate, p_daytime) LOOP
			IF (p_xtra_qty = 1) THEN
				ln_day_official := curQty.qty2;
			ELSIF (p_xtra_qty = 2) THEN
				ln_day_official := curQty.qty3;
			ELSE
				ln_day_official := curQty.qty;
			END IF;
		END LOOP;

		-- Get lifted qty normal operations
		ln_day_tot_lifted := Nvl(EcDp_Stor_Fcst_Balance.getAccEstLiftedQtySubDay(p_object_id, p_forecast_id, ld_startDate, p_daytime, p_xtra_qty, 'Y'),0);
	END IF;

	lv_storage_type   := ec_stor_version.storage_type(ec_lifting_account.storage_id(p_object_id), p_daytime, '<=');
	IF (lv_storage_type = 'IMPORT') THEN
		ln_closing_balance := ln_closing_balance - nvl(ln_day_official, 0) + ln_day_tot_lifted;
	ELSE
		ln_closing_balance := ln_closing_balance + nvl(ln_day_official, 0) - ln_day_tot_lifted;
	END IF;

	ln_closing_balance := ln_closing_balance + nvl(ln_adjustment,0);

	IF p_xtra_qty=1 THEN
		gv_prev_sub_date2(ln_index):=p_daytime;
		gv_prev_sub_qty2(ln_index):=ln_closing_balance;
		gv_prev_sub_object2(ln_index):=p_object_id;
		gv_prev_sub_st_flag2(ln_index):=p_summer_time;
		gv_prev_sub_forecast2(ln_index):=p_forecast_id;
	ELSIF p_xtra_qty=2 THEN
		gv_prev_sub_date3(ln_index):=p_daytime;
		gv_prev_sub_qty3(ln_index):=ln_closing_balance;
		gv_prev_sub_object3(ln_index):=p_object_id;
		gv_prev_sub_st_flag3(ln_index):=p_summer_time;
		gv_prev_sub_forecast3(ln_index):=p_forecast_id;
	ELSE
		gv_prev_sub_date(ln_index):=p_daytime;
		gv_prev_sub_qty(ln_index):=ln_closing_balance;
		gv_prev_sub_object(ln_index):=p_object_id;
		gv_prev_sub_st_flag(ln_index):=p_summer_time;
		gv_prev_sub_forecast(ln_index):=p_forecast_id;
	END IF;

	RETURN ln_closing_balance;

END calcEstClosingBalanceSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInitBalance
-- Description    : Finds initial balance for the lifting account in the forecast
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :                                                                                                                          --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getInitBalance(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--<EC-DOC>
IS
	ln_opening_balance		NUMBER;

	CURSOR c_init(cp_object_id VARCHAR2, cp_forecast_id VARCHAR2, cp_xtra_qty NUMBER)
	IS
		SELECT DECODE(cp_xtra_qty,0, balance, 1, balance2, 2, balance3) balance
		  FROM fcst_lift_acc_init_bal
		 WHERE forecast_id = cp_forecast_id
		   AND object_id = cp_object_id;
BEGIN
	FOR c_cur IN c_init(p_object_id, p_forecast_id, p_xtra_qty) LOOP
		ln_opening_balance := c_cur.balance;
	END LOOP;

	RETURN ln_opening_balance;
END;

END EcBp_Lift_Acc_Fcst_Balance;