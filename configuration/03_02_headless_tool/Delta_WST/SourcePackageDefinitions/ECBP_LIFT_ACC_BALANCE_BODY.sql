CREATE OR REPLACE PACKAGE BODY EcBp_Lift_Acc_Balance IS
/****************************************************************
** Package        :  EcBp_Lift_Acc_Balance; body part
**
** $Revision: 1.32 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  07.09.2006	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 31.05.2010  meisihil     ECPD-14855: Modified function CalcStorageLevel to utilise precalc'ed global variables
** 10.02.2012  sharawan     ECPD-19573 : Add function calcAggrEstClosingBalanceDay to sum the lifting account balance
**                          for lifting agreement lifting accounts.
** 26.09.2012  meisihil     ECPD-20961: Modified calcEstClosingBalanceMth, calcEstClosingBalanceDay and calcEstClosingBalanceSubDay to read allocated balance tables
** 12.09.2011  meisihil     ECPD-20962: Included balance delta in calcEstClosingBalanceDay and calcEstClosingBalanceSubDay
** 30.10.2013  leeeewei		ECPD-16883: Modified getAdjustmentsDay, getAdjustmentsMth and calcEstClosingBalanceDay to read use_sub_day from system settings
** 26.05.2015  sharawan     ECPD-19047: Added parameter p_ignore_cache to calcEstClosingBalanceDay and calcEstClosingBalanceSubDay
** 01.07.2016  asareswi		ECPD-32994: Modified calcEstClosingBalanceMth to get correct closing balance based on actuals.
** 25-10-2016  thotesan     ECPD-37786: Modified update statements in setClosingBalance so that last_updated_date will be populated when function is triggered.
** 21-07-2016  royyypur     ECPD-46254: replaced /com/ec/tran/cargo/storage_level/use_sub_day with  /com/ec/tran/cargo/storage_level/use_production_day.
******************************************************************/

/**private global session variables **/
TYPE prevDate IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE prevQty IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE prevObject IS TABLE OF VARCHAR2(32) INDEX BY BINARY_INTEGER;
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

gv_prev_sub_date prevDate;
gv_prev_sub_date2 prevDate;
gv_prev_sub_date3 prevDate;
gv_prev_sub_qty prevQty;
gv_prev_sub_qty2 prevQty;
gv_prev_sub_qty3 prevQty;
gv_prev_sub_object prevObject;
gv_prev_sub_object2 prevObject;
gv_prev_sub_object3 prevObject;
gv_prev_sub_st_flag prevSummerTime;
gv_prev_sub_st_flag2 prevSummerTime;
gv_prev_sub_st_flag3 prevSummerTime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAdjustments (private)
-- Description    : get adjustments for defined lifting account and period
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
						   p_from_date   DATE,
						   p_to_date   DATE,
						   p_xtra_qty  NUMBER DEFAULT 0) RETURN NUMBER
--</EC-DOC>
 IS

	CURSOR c_debit(cp_lifting_account_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
  		SELECT decode(cp_xtra_qty, 0, SUM(adj_qty), 1, SUM(adj_qty2), 2, SUM(adj_qty3)) adj_qty
		  FROM lift_account_adjustment
		 WHERE object_id = cp_lifting_account_id
		   AND daytime >= cp_from_date
		   AND daytime < cp_to_date;

	CURSOR c_credit(cp_lifting_account_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
  		SELECT decode(cp_xtra_qty, 0, SUM(adj_qty), 1, SUM(adj_qty2), 2, SUM(adj_qty3)) adj_qty
		  FROM lift_account_adjustment
		 WHERE to_object_id = cp_lifting_account_id
		   AND daytime >= cp_from_date
		   AND daytime < cp_to_date;

	CURSOR c_single(cp_lifting_account_id VARCHAR2, cp_from_date DATE, cp_to_date DATE, cp_xtra_qty NUMBER) IS
  		SELECT decode(cp_xtra_qty, 0, SUM(adj_qty), 1, SUM(adj_qty2), 2, SUM(adj_qty3)) adj_qty
		  FROM lift_account_adj_single
		 WHERE object_id = cp_lifting_account_id
		   AND daytime >= cp_from_date
		   AND daytime < cp_to_date;

	ln_debit_qty      NUMBER;
	ln_credit_qty     NUMBER;
	ln_single_qty     NUMBER;

BEGIN
	FOR curDebit IN c_debit(p_object_id, p_from_date, p_to_date, p_xtra_qty) LOOP
		ln_debit_qty := curDebit.adj_qty;
	END LOOP;

	FOR curCredit IN c_credit(p_object_id, p_from_date, p_to_date, p_xtra_qty) LOOP
		ln_credit_qty := curCredit.adj_qty;
	END LOOP;

	FOR curSingle IN c_single(p_object_id, p_from_date, p_to_date, p_xtra_qty) LOOP
		ln_single_qty := curSingle.adj_qty;
	END LOOP;

	RETURN Nvl(ln_credit_qty, 0) - Nvl(ln_debit_qty, 0) + nvl(ln_single_qty,0);

END getAdjustments;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOpeningBalanceMth
-- Description    : Opening balance = closing balance for previous month
--
-- Preconditions  :
-- Postconditions :
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
FUNCTION getOpeningBalanceMth (p_object_id 			VARCHAR2,
							p_daytime 				DATE,
							p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
IS
	CURSOR c_lift_account_mth_balance IS
  		SELECT BALANCE, BALANCE2, BALANCE3
		FROM lift_account_mth_balance
		WHERE object_id = p_object_id
		AND daytime = ADD_MONTHS(TRUNC(p_daytime,'mm'),-1);

	ln_opening_balance		NUMBER;

BEGIN
	-- Get closing balance for previous month
	FOR curClosingBalance IN c_lift_account_mth_balance LOOP
    	IF (p_xtra_qty = 1 ) THEN
			ln_opening_balance := curClosingBalance.balance2;
 		ELSIF (p_xtra_qty = 2 ) THEN
			ln_opening_balance := curClosingBalance.balance3;
		ELSE
			ln_opening_balance := curClosingBalance.balance;
		END IF;
	END LOOP;

	RETURN ln_opening_balance;

END getOpeningBalanceMth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcEstOpeningBalanceMth
-- Description    : Estimated Opening balance = closing balance for previous month
--
-- Preconditions  :
-- Postconditions :
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
FUNCTION calcEstOpeningBalanceMth (p_object_id 			VARCHAR2,
									 p_daytime 				DATE,
									 p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
IS

	CURSOR 	c_acc_balance(cp_object_id VARCHAR2, cp_daytime DATE) IS
		SELECT	count(*)  cnt
		FROM	lift_account_mth_balance
		WHERE	object_id = cp_object_id
		AND 	daytime < TRUNC(cp_daytime,'mm');

	ln_opening_balance		NUMBER;

BEGIN
	ln_opening_balance := getOpeningBalanceMth(p_object_id, p_daytime, p_xtra_qty);

	IF ln_opening_balance IS NULL THEN
		-- Is there a balance before this date?
		FOR curBalance IN c_acc_balance (p_object_id, p_daytime) LOOP
			IF curBalance.cnt > 0 THEN
				-- recursive since calcEstimatedClosingBalance calls this function for opening balance
				ln_opening_balance := calcEstClosingBalanceMth(p_object_id, ADD_MONTHS(TRUNC(p_daytime,'mm'),-1), p_xtra_qty);
			ELSE
				ln_opening_balance := 0;
			END IF;
		END LOOP;
	END IF;

	RETURN ln_opening_balance;

END calcEstOpeningBalanceMth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isLiftingAccountClosed
-- Description    : Returns 'Y' if lifting account got a value in balance/balance2 for selected month
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : lift_account_mth_balance                                                                                                                         --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isLiftingAccountClosed (p_object_id VARCHAR2,
								p_daytime DATE,
								p_xtra_qty NUMBER DEFAULT 0)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR 	c_acc_balance(cp_object_id VARCHAR2, cp_daytime DATE)
IS

SELECT	balance, balance2, balance3
FROM	lift_account_mth_balance
WHERE	object_id = cp_object_id
      	AND daytime = trunc(cp_daytime, 'MM');

lv_isClosed	VARCHAR2(1)	:= 'N';

BEGIN

	FOR curClosed IN c_acc_balance(p_object_id, p_daytime) LOOP
    	IF (p_xtra_qty = 1 ) THEN
			IF curClosed.balance2 IS NOT NULL THEN
				lv_isClosed := 'Y' ;
			END IF;
		ELSIF (p_xtra_qty = 2 ) THEN
			IF curClosed.balance3 IS NOT NULL THEN
				lv_isClosed := 'Y' ;
			END IF;
		ELSE
			IF curClosed.balance IS NOT NULL THEN
				lv_isClosed := 'Y' ;
			END IF;
		END IF;
	END LOOP;

	RETURN lv_isClosed;
END isLiftingAccountClosed;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcClosingBalanceMth
-- Description    : Calculate and returns the closing balance for the given month as
--                  opening balance + production share - lifted + adjustment
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:   getOpeningBalanceMth, EcDp_Lift_Acc_Official.getTotalMonth, EcDp_Storage_Balance.getAccLiftedQtyMth
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcClosingBalanceMth(p_object_id 			VARCHAR2,
							p_daytime 				DATE,
							p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
IS
	ln_closing_balance		NUMBER;
	ln_opening_balance		NUMBER;
	ln_official				NUMBER;
	ln_tot_lifted			NUMBER;
	ln_tot_adjustment		NUMBER;
BEGIN
	--TODO add usage of p_xtra_qty

	ln_opening_balance :=  Nvl(getOpeningBalanceMth(p_object_id, p_daytime, p_xtra_qty),0);
	ln_official := Nvl(EcDp_Lift_Acc_Official.getTotalMonth(p_object_id, p_daytime, 'OFFICIAL', p_xtra_qty),0);
	ln_tot_lifted := Nvl(EcDp_Storage_Balance.getAccLiftedQtyMth(p_object_id, p_daytime, p_xtra_qty),0);
	ln_tot_adjustment := Nvl(getAdjustmentsMth(p_object_id, p_daytime, p_xtra_qty),0);

	IF (ec_stor_version.storage_type(ec_lifting_account.storage_id(p_object_id), p_daytime, '<=') = 'IMPORT') THEN
		ln_closing_balance := ln_opening_balance - ln_official + ln_tot_lifted + ln_tot_adjustment;
	ELSE
		ln_closing_balance := ln_opening_balance + ln_official - ln_tot_lifted + ln_tot_adjustment;
	END IF;

	RETURN ln_closing_balance;

END calcClosingBalanceMth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcEstClosingBalanceMth
-- Description    :
--
-- Preconditions  :
-- Postconditions :
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
FUNCTION calcEstClosingBalanceMth (p_object_id 			VARCHAR2,
								p_daytime 				DATE,
								p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
IS
	ln_closing_balance		NUMBER;
	ln_opening_balance		NUMBER;
	ln_official				NUMBER := 0;
	ln_tot_lifted			NUMBER;
	ln_tot_adjustment		NUMBER;
	ld_from_date            DATE;

	CURSOR curQty(cp_object_id VARCHAR2, cp_from DATE, cp_to DATE) IS
 	SELECT sum(nvl(o.official_qty, f.forecast_qty)) qty,
         sum(nvl(o.official_qty2, f.forecast_qty2)) qty2,
         sum(nvl(o.official_qty3, f.forecast_qty3)) qty3
	FROM  lift_acc_day_forecast f, lift_acc_day_official o
	WHERE  o.object_id (+)= f.object_id
			AND f.object_id = p_object_id
	       and o.daytime (+)= f.daytime
	       and f.daytime >= cp_from
	       and f.daytime < cp_to;

	CURSOR c_actual(cp_object_id VARCHAR2, cp_daytime DATE, cp_xtra_qty NUMBER) IS
	    SELECT Trunc(la.daytime) last_day, DECODE(cp_xtra_qty, 1, closing_balance2, 2, closing_balance3, closing_balance) closing_balance
	    FROM   lift_acc_day_bal_alloc la
	    WHERE  la.object_id = cp_object_id
	    AND    la.daytime = (SELECT Trunc(Max(la2.daytime)) last_day
	            FROM   lift_acc_day_bal_alloc la2
	            WHERE  la2.object_id = cp_object_id
	            AND    la2.daytime <= cp_daytime
	            AND    (la2.closing_balance IS NOT NULL OR la2.closing_balance2 IS NOT NULL OR la2.closing_balance3 IS NOT NULL));

BEGIN
    --get latest allocated actual.
    FOR cur_rec IN c_actual(p_object_id, add_months(p_daytime,1), p_xtra_qty) LOOP
    	IF cur_rec.last_day >= p_daytime THEN
	        ld_from_date := cur_rec.last_day;
	        ln_opening_balance := cur_rec.closing_balance;
	    END IF;
    END LOOP;

    --check if latest actual is for requested date?
    IF ld_from_date = add_months(p_daytime,1)-1 THEN
    	ln_closing_balance := ln_opening_balance;
    ELSE
		IF ln_opening_balance IS NOT NULL THEN
			ln_closing_balance := Nvl(calcEstClosingBalanceDay(p_object_id, add_months(p_daytime, 1)-1, p_xtra_qty),0);
        ELSE
        	-- No actual last month
			ln_opening_balance :=  Nvl(calcEstOpeningBalanceMth(p_object_id, p_daytime, p_xtra_qty),0);
			ln_tot_lifted := Nvl(EcDp_Storage_Balance.getAccEstLiftedQtyMth(p_object_id, p_daytime, p_xtra_qty, 'Y'),0);
			ln_tot_adjustment := Nvl(getAdjustmentsMth(p_object_id, p_daytime, p_xtra_qty),0);

			FOR c_qty IN curQty (p_object_id, TRUNC(p_daytime, 'mm'), add_months(p_daytime, 1)) LOOP
		  		IF (p_xtra_qty = 1 ) THEN
					ln_official := c_qty.qty2;
		    ELSIF (p_xtra_qty = 2 ) THEN
					ln_official := c_qty.qty3;
				ELSE
					ln_official := c_qty.qty;
				END IF;
			END LOOP;

			IF (ec_stor_version.storage_type(ec_lifting_account.storage_id(p_object_id), p_daytime, '<=') = 'IMPORT') THEN
				ln_closing_balance := ln_opening_balance - Nvl(ln_official, 0) + ln_tot_lifted + ln_tot_adjustment;
			ELSE
				ln_closing_balance := ln_opening_balance + Nvl(ln_official, 0) - ln_tot_lifted + ln_tot_adjustment;
			END IF;
		END IF;
	END IF;


	RETURN ln_closing_balance;

END calcEstClosingBalanceMth;

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


FUNCTION calcEstClosingBalanceDay(p_object_id  VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0, p_ignore_cache VARCHAR2 DEFAULT 'N')
RETURN NUMBER
--<EC-DOC>
IS

  ln_firstday_opening_bal NUMBER;
  ln_day_opening_balance  NUMBER;
  ln_day_closing_balance  NUMBER;
  ln_closing_balance      NUMBER;
  ln_adjustment      	  NUMBER;

  ln_day_official   NUMBER;
  ln_day_tot_lifted       NUMBER;
  ld_start_day            DATE;
  ld_from_date      DATE;
  ld_to_date        DATE;
  ld_day_end   DATE;
  lb_actual         BOOLEAN;
  ld_today     DATE;

  lv_storage_type	VARCHAR2(32);

  lv_prev_qty   NUMBER;
  lv_prev_date  DATE;
  lv_prev_object  VARCHAR2(32);

  lv_read_prod_day VARCHAR2(1);

  ln_index NUMBER := 0;

	CURSOR c_actual(cp_object_id VARCHAR2, cp_daytime DATE, cp_xtra_qty NUMBER) IS
	    SELECT Trunc(la.daytime) last_day, DECODE(cp_xtra_qty, 1, closing_balance2, 2, closing_balance3, closing_balance) closing_balance
	    FROM   lift_acc_day_bal_alloc la
	    WHERE  la.object_id = cp_object_id
	    AND    la.daytime = (SELECT Trunc(Max(la2.daytime)) last_day
	            FROM   lift_acc_day_bal_alloc la2
	            WHERE  la2.object_id = cp_object_id
	            AND    la2.daytime <= cp_daytime
	            AND    (la2.closing_balance IS NOT NULL OR la2.closing_balance2 IS NOT NULL OR la2.closing_balance3 IS NOT NULL));

	CURSOR c_sub_day_actual(cp_object_id VARCHAR2, cp_production_day DATE) IS
	    SELECT distinct Trunc(la.daytime, 'HH') last_hour
	    FROM   lift_acc_sub_day_bal_al la
	    WHERE  la.object_id = cp_object_id
	    AND    la.production_day = cp_production_day
	    AND    la.daytime = (SELECT Trunc(Max(la2.daytime), 'HH')
	            FROM   lift_acc_sub_day_bal_al la2
	            WHERE  la2.object_id = cp_object_id
	            AND    la2.production_day = cp_production_day
	            AND    (la2.closing_balance IS NOT NULL OR la2.closing_balance2 IS NOT NULL OR la2.closing_balance3 IS NOT NULL));

BEGIN
	ld_today := TRUNC(Ecdp_Timestamp.getCurrentSysdate);

  	IF p_xtra_qty = 1 THEN
        FOR i IN 1..gv_prev_object2.count LOOP
          IF gv_prev_object2(i) = p_object_id THEN
            ln_index := i;
            EXIT;
          END IF;
        END LOOP;

        --reset global variable if cache is OFF (p_ignore_cache = 'Y')
        IF (ln_index = 0 OR p_ignore_cache = 'Y') THEN
          ln_index := gv_prev_qty2.count + 1;
          gv_prev_qty2(ln_index):=0;
          gv_prev_date2(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
          gv_prev_object2(ln_index) := '0';
        END IF;

        --use prev_date2 and prev_qty2
        lv_prev_date:=gv_prev_date2(ln_index);
        lv_prev_qty:=gv_prev_qty2(ln_index);
        lv_prev_object:=gv_prev_object2(ln_index);
    ELSIF p_xtra_qty = 2 THEN
        FOR i IN 1..gv_prev_object3.count LOOP
          IF gv_prev_object3(i) = p_object_id THEN
            ln_index := i;
            EXIT;
          END IF;
        END LOOP;

        --reset global variable if cache is OFF (p_ignore_cache = 'Y')
        IF (ln_index = 0 OR p_ignore_cache = 'Y') THEN
          ln_index := gv_prev_qty3.count + 1;
          gv_prev_qty3(ln_index):=0;
          gv_prev_date3(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
          gv_prev_object3(ln_index) := '0';
        END IF;

        --use prev_date3 and prev_qty3
        lv_prev_date:=gv_prev_date3(ln_index);
        lv_prev_qty:=gv_prev_qty3(ln_index);
        lv_prev_object:=gv_prev_object3(ln_index);
    ELSE
        --use prev_date and prev_qty
        FOR i IN 1..gv_prev_object.count LOOP
          IF gv_prev_object(i) = p_object_id THEN
            ln_index := i;
            EXIT;
          END IF;
        END LOOP;

        --reset global variable if cache is OFF (p_ignore_cache = 'Y')
        IF (ln_index = 0 OR p_ignore_cache = 'Y') THEN
          ln_index := gv_prev_qty.count + 1;
          gv_prev_qty(ln_index):=0;
          gv_prev_date(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
          gv_prev_object(ln_index) := '0';
        END IF;

        lv_prev_date:=gv_prev_date(ln_index);
        lv_prev_qty:=gv_prev_qty(ln_index);
        lv_prev_object:=gv_prev_object(ln_index);
	  END IF;

    lv_read_prod_day := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_production_day');

  	lv_storage_type := ec_stor_version.storage_type(ec_lifting_account.storage_id(p_object_id), p_daytime, '<=');
    IF lv_read_prod_day = 'Y' THEN
	   ld_to_date := EcDp_ProductionDay.getProductionDayStart('STORAGE',ec_lifting_account.storage_id(p_object_id),p_daytime + 1);
    ELSE
       ld_to_date := p_daytime + 1;
    END IF;
    lb_actual := false;


    --get latest allocated actual.
    FOR cur_rec IN c_actual(p_object_id, p_daytime, p_xtra_qty) LOOP
    	IF cur_rec.last_day >= TRUNC(p_daytime,'mm') THEN
	        ld_from_date := cur_rec.last_day;
	        ln_firstday_opening_bal := cur_rec.closing_balance;
	    END IF;
    END LOOP;

    --check if latest actual is for requested date?
    IF ld_from_date = p_daytime THEN
    	ln_closing_balance := ln_firstday_opening_bal;
    	lb_actual := true;
    ELSE
	-- get closing balance for previous month (starting point) as this month opening balance
		IF (lv_prev_object = p_object_id) AND (p_daytime >= ld_today) AND (trunc(lv_prev_date,'DD') - trunc(p_daytime,'DD')=0) THEN
			RETURN NVL(lv_prev_qty,0);
		ELSIF (lv_prev_object = p_object_id) AND (p_daytime >= ld_today) AND (trunc(lv_prev_date,'DD') - trunc(p_daytime-1,'DD')=0)  AND to_char(p_daytime,'dd') != '01' THEN
			ln_firstday_opening_bal := NVL(lv_prev_qty,0);
      		IF(lv_read_prod_day = 'Y')THEN
			   ld_from_date := EcDp_ProductionDay.getProductionDayStart('STORAGE',ec_lifting_account.storage_id(p_object_id),p_daytime);
       		ELSE
         		ld_from_date := p_daytime;
       		END IF;
		ELSE
			IF ln_firstday_opening_bal IS NOT NULL THEN
				ld_from_date := ld_from_date + 1;
	           	-- If sub daily allocated balance is calculated for the next day
	        	FOR cur_rec IN c_sub_day_actual(p_object_id, ld_from_date) LOOP
              		IF(lv_read_prod_day = 'Y')THEN
						ld_day_end := EcDp_ProductionDay.getProductionDayStart('STORAGE',ec_lifting_account.storage_id(p_object_id),ld_from_date + 1) - 1/24;
              		ELSE
                 		ld_day_end := (ld_from_date + 1)-1/24;
              		END IF;
	        		ln_firstday_opening_bal := calcEstClosingBalanceSubDay(p_object_id, ld_day_end, ecdp_date_time.summertime_flag(ld_day_end), p_xtra_qty, p_ignore_cache);
				    --check if latest actual is for requested date?
				    IF ld_from_date = p_daytime THEN
				    	ln_closing_balance := ln_firstday_opening_bal;
				        lb_actual := true;
				    END IF;
	        		ld_from_date := ld_from_date + 1;
	        	END LOOP;
			ELSE
				ln_firstday_opening_bal := Nvl(calcEstOpeningBalanceMth(p_object_id, p_daytime, p_xtra_qty),0);
        		IF (lv_read_prod_day = 'Y')THEN
					ld_from_date := EcDp_ProductionDay.getProductionDayStart('STORAGE',ec_lifting_account.storage_id(p_object_id),TRUNC(p_daytime,'mm'));
        		ELSE
          			ld_from_date := trunc(p_daytime,'mm');
        		END IF;
			END IF;
		END IF;
	END IF;

	IF NOT lb_actual THEN

		ln_adjustment := Nvl(getAdjustments(p_object_id, ld_from_date, ld_to_date, p_xtra_qty),0);

		ld_start_day := trunc(ld_from_date,'DD');
		ln_day_opening_balance := ln_firstday_opening_bal;

		WHILE ld_start_day <= p_daytime LOOP
      IF (p_xtra_qty = 1 ) THEN
        ln_day_official := Nvl(ec_lift_acc_day_official.official_qty2(p_object_id, ld_start_day), Nvl(ec_lift_acc_day_forecast.forecast_qty2(p_object_id, ld_start_day),0));
       ELSIF (p_xtra_qty = 2 ) THEN
        ln_day_official := Nvl(ec_lift_acc_day_official.official_qty3(p_object_id, ld_start_day), Nvl(ec_lift_acc_day_forecast.forecast_qty3(p_object_id, ld_start_day),0));
      ELSE
        ln_day_official := Nvl(ec_lift_acc_day_official.official_qty(p_object_id, ld_start_day), Nvl(ec_lift_acc_day_forecast.forecast_qty(p_object_id, ld_start_day),0));
      END IF;

	      ln_day_tot_lifted := Nvl(EcDp_Storage_Balance.getAccEstLiftedQtyDay(p_object_id, ld_start_day, p_xtra_qty, 'Y'),0);

      IF (lv_storage_type = 'IMPORT') THEN
        ln_day_closing_balance := ln_day_opening_balance - ln_day_official + ln_day_tot_lifted;
      ELSE
        ln_day_closing_balance := ln_day_opening_balance + ln_day_official - ln_day_tot_lifted;
      END IF;

      ln_day_opening_balance := ln_day_closing_balance; -- for next day (next iteration)
      ld_start_day := ld_start_day + 1; -- increase one day
    END LOOP;

	   ln_closing_balance := ln_day_closing_balance + nvl(ln_adjustment,0);
  END IF;

  /*****************************
  SAVE GLOBAL VARS FOR NEXT ITERATION
  */
  --STORE current closing balance for next iteration if the cache is turn ON (p_ignore_cache = 'N')
  IF (p_ignore_cache = 'N') THEN
    IF p_xtra_qty=1 THEN
      gv_prev_date2(ln_index):=p_daytime;
      gv_prev_qty2(ln_index):=ln_closing_balance;
      gv_prev_object2(ln_index):=p_object_id;
    ELSIF p_xtra_qty=2 THEN
      gv_prev_date3(ln_index):=p_daytime;
      gv_prev_qty3(ln_index):=ln_closing_balance;
      gv_prev_object3(ln_index):=p_object_id;
    ELSE
      gv_prev_date(ln_index):=p_daytime;
      gv_prev_qty(ln_index):=ln_closing_balance;
      gv_prev_object(ln_index):=p_object_id;
    END IF;
  END IF;

  RETURN ln_closing_balance;

END calcEstClosingBalanceDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcAggrEstClosingBalanceDay
-- Description    : Calculate the aggregated lifting account balance for all lifting accounts that is part
--                  of the Lifting Agreement for the selected contract for the nomination.
--
-- Preconditions  : The lifting account is part of the Lifting Agreement.
-- Postconditions :
--
-- Using tables   :                                                                                                                          --
-- Using functions: calcEstClosingBalanceDay
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------


FUNCTION calcAggrEstClosingBalanceDay(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--<EC-DOC>

IS
  --ln_count NUMBER;
  lv_contract_id VARCHAR2(32);
  ln_aggr_closing_bal NUMBER;

  CURSOR c_lift_account (cp_object_id VARCHAR2) IS
    SELECT lifting_account_id
    FROM cntr_lift_acc_share
    WHERE object_id = cp_object_id
    AND daytime <= p_daytime
    AND (end_date IS NULL OR end_date > p_daytime);

BEGIN
  --ln_count :=0;
  ln_aggr_closing_bal := 0;

  lv_contract_id := ec_lift_account_version.contract_id(p_object_id, p_daytime, '<=');

  FOR curLiftAccount IN c_lift_account (lv_contract_id)  LOOP
    --ln_count := ln_count + 1;
    ln_aggr_closing_bal := ln_aggr_closing_bal + calcEstClosingBalanceDay(curLiftAccount.lifting_account_id, p_daytime, p_xtra_qty);
  END LOOP;

  RETURN ln_aggr_closing_bal;

END calcAggrEstClosingBalanceDay;


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

FUNCTION calcEstClosingBalanceSubDay(p_object_id  VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0, p_ignore_cache VARCHAR2 DEFAULT 'N')
RETURN NUMBER
--<EC-DOC>
IS
  CURSOR c_qty (cp_object_id  VARCHAR2, cp_start DATE, cp_end DATE) IS
    select sum(nvl(o.official_qty, f.forecast_qty)) qty,
           sum(nvl(o.official_qty2, f.forecast_qty2)) qty2,
           sum(nvl(o.official_qty3, f.forecast_qty3)) qty3
      from lift_acc_sub_day_forecast f, lift_acc_sub_day_official o
     where o.object_id(+) = f.object_id
       and o.daytime(+) = f.daytime
       and o.summer_time(+) = f.summer_time
       and f.object_id = cp_object_id
       and f.daytime  between cp_start and cp_end;

  CURSOR c_qty_summer_intercept(cp_object_id  VARCHAR2, cp_start DATE, cp_end DATE, cp_summer_time VARCHAR2) IS
    select sum(nvl(o.official_qty, f.forecast_qty)) qty,
           sum(nvl(o.official_qty2, f.forecast_qty2)) qty2,
           sum(nvl(o.official_qty3, f.forecast_qty3)) qty3
      from lift_acc_sub_day_forecast f, lift_acc_sub_day_official o
     where o.object_id(+) = f.object_id
       and o.daytime(+) = f.daytime
       and o.summer_time(+) = f.summer_time
       and f.object_id = cp_object_id
       and f.daytime  between cp_start and cp_end
       and f.summer_time = cp_summer_time;

  CURSOR c_sumerTime_flag(cp_object_id VARCHAR2, cp_start DATE, cp_end DATE) IS
    SELECT ecdp_date_time.summertime_flag(t.daytime) summerFlag
    from lift_acc_sub_day_forecast t
    where t.daytime >= cp_start
      AND t.daytime <= cp_end
      AND t.object_id = cp_object_id;

	CURSOR c_actual(cp_object_id VARCHAR2, cp_production_day DATE, cp_daytime DATE, cp_xtra_qty NUMBER, cp_summer_time_order VARCHAR2) IS
	    SELECT Trunc(la.daytime,'HH') last_hour, summer_time, DECODE(cp_xtra_qty, 1, closing_balance2, 2, closing_balance3, closing_balance) closing_balance
	    FROM   lift_acc_sub_day_bal_al la
	    WHERE  la.object_id = cp_object_id
	    AND    la.production_day = cp_production_day
	    AND    la.daytime = (SELECT Trunc(Max(la2.daytime),'HH') last_day
	            FROM   lift_acc_sub_day_bal_al la2
	            WHERE  la2.object_id = cp_object_id
	            AND    la2.production_day = cp_production_day
	            AND    la2.daytime <= cp_daytime
	            AND    (la2.closing_balance IS NOT NULL OR la2.closing_balance2 IS NOT NULL OR la2.closing_balance3 IS NOT NULL))
	   ORDER BY daytime, decode(cp_summer_time_order,'ASC',summer_time,null) ASC, decode(cp_summer_time_order,'DESC',summer_time,null) DESC;

  ln_closing_balance      NUMBER;
  ln_day_tot_lifted    NUMBER;
  ln_day_official      NUMBER  :=  0;
  ln_adjustment      NUMBER;
  ld_production_day DATE;
  ld_startDate      DATE;
  lv_storage_type  VARCHAR2(32);
    lv_summer_flag VARCHAR2(32);
    lv_summer_time_order VARCHAR2(32);
	lud_next_hour EcDp_Date_Time.Ec_Unique_Daytime;

  lv_prev_qty   NUMBER;
  lv_prev_date  DATE;
  lv_prev_object  VARCHAR2(32);
  lv_prev_st_flag  VARCHAR2(1);

  ln_index NUMBER := 0;
BEGIN

  IF p_xtra_qty = 1 THEN
      FOR i IN 1..gv_prev_sub_object2.count LOOP
        IF gv_prev_sub_object2(i) = p_object_id THEN
          ln_index := i;
          EXIT;
        END IF;
      END LOOP;

      --reset global variable if cache is OFF (p_ignore_cache = 'Y')
      IF (ln_index = 0 OR p_ignore_cache = 'Y') THEN
        ln_index := gv_prev_sub_qty2.count + 1;
        gv_prev_sub_qty2(ln_index):=0;
        gv_prev_sub_date2(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
        gv_prev_sub_object2(ln_index) := '0';
        gv_prev_sub_st_flag2(ln_index) := 'N';
      END IF;

      --use prev_date2 and prev_qty2
      lv_prev_date:=gv_prev_sub_date2(ln_index);
      lv_prev_qty:=gv_prev_sub_qty2(ln_index);
      lv_prev_object:=gv_prev_sub_object2(ln_index);
      lv_prev_st_flag:=gv_prev_sub_st_flag2(ln_index);

  ELSIF p_xtra_qty = 2 THEN
      FOR i IN 1..gv_prev_sub_object3.count LOOP
        IF gv_prev_sub_object3(i) = p_object_id THEN
          ln_index := i;
          EXIT;
        END IF;
      END LOOP;

      --reset global variable if cache is OFF (p_ignore_cache = 'Y')
      IF (ln_index = 0 OR p_ignore_cache = 'Y') THEN
        ln_index := gv_prev_sub_qty3.count + 1;
        gv_prev_sub_qty3(ln_index):=0;
        gv_prev_sub_date3(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
        gv_prev_sub_object3(ln_index) := '0';
        gv_prev_sub_st_flag3(ln_index) := 'N';
      END IF;

      --use prev_date3 and prev_qty3
      lv_prev_date:=gv_prev_sub_date3(ln_index);
      lv_prev_qty:=gv_prev_sub_qty3(ln_index);
      lv_prev_object:=gv_prev_sub_object3(ln_index);
      lv_prev_st_flag:=gv_prev_sub_st_flag3(ln_index);
  ELSE
      --use prev_date and prev_qty
      FOR i IN 1..gv_prev_sub_object.count LOOP
        IF gv_prev_sub_object(i) = p_object_id THEN
          ln_index := i;
          EXIT;
        END IF;
      END LOOP;

      --reset global variable if cache is OFF (p_ignore_cache = 'Y')
      IF (ln_index = 0 OR p_ignore_cache = 'Y') THEN
        ln_index := gv_prev_sub_qty.count + 1;
        gv_prev_sub_qty(ln_index):=0;
        gv_prev_sub_date(ln_index) := TO_DATE('1900-01-01','YYYY-MM-dd');
        gv_prev_sub_object(ln_index) := '0';
        gv_prev_sub_st_flag(ln_index) := 'N';
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
        lv_summer_time_order := Nvl(ecdp_ctrl_property.getSystemProperty('/com/ec/frmw/summer_time/order'),'DESC');

		--get latest allocated actual.
		FOR cur_rec IN c_actual(p_object_id, ld_production_day, p_daytime, p_xtra_qty, lv_summer_time_order) LOOP
			IF cur_rec.last_hour >= ld_startDate THEN
				ln_closing_balance := cur_rec.closing_balance;
				IF cur_rec.last_hour = p_daytime AND cur_rec.summer_time = p_summer_time THEN
					RETURN NVL(cur_rec.closing_balance,0);
				ELSE
					lud_next_hour := EcDp_Date_Time.getNextHour(cur_rec.last_hour, cur_rec.summer_time);
					ld_StartDate := lud_next_hour.daytime;
					IF cur_rec.summer_time != lud_next_hour.summertime_flag THEN
						lv_summer_flag := cur_rec.summer_time;
					END IF;
				END IF;
			END IF;
		END LOOP;

    -- get opening balance of the day
		IF ln_closing_balance IS NULL THEN
		    IF to_char(ld_production_day,'dd') = '01' THEN
		      ln_closing_balance := Nvl(calcEstOpeningBalanceMth(p_object_id, ld_production_day, p_xtra_qty),0);
		    ELSE
		      ln_closing_balance := nvl(calcEstClosingBalanceDay(p_object_id, ld_production_day - 1, p_xtra_qty, p_ignore_cache), 0);
		    END IF;
		END IF;
	END IF;

  lv_storage_type   := ec_stor_version.storage_type(ec_lifting_account.storage_id(p_object_id), p_daytime, '<=');

  -- get sub day numbers
  ln_adjustment := Nvl(getAdjustmentsSubDay(p_object_id, ld_startDate, p_daytime, p_xtra_qty),0);

  --checking the summer time flag
	IF lv_summer_flag IS NULL THEN
	  FOR curIn IN c_sumerTime_flag(p_object_id, ld_startDate, p_daytime) LOOP
	    lv_summer_flag := curIn.summerFlag;
	  END LOOP;
	END IF;

  IF(p_summer_time != lv_summer_flag)THEN
        -- Get forecast/official production during an intercept
    FOR curQty IN c_qty_summer_intercept(p_object_id, ld_startDate, p_daytime, p_summer_time) LOOP
      IF (p_xtra_qty = 1) THEN
        ln_day_official := curQty.qty2;
      ELSIF (p_xtra_qty = 2) THEN
        ln_day_official := curQty.qty3;
      ELSE
        ln_day_official := curQty.qty;
      END IF;
    END LOOP;

		-- Get lifted qty during an intercept
		ln_day_tot_lifted := Nvl(EcDp_Storage_Balance.getAccEstLiftedQtySubDay(p_object_id, ld_startDate, p_daytime, p_xtra_qty, 'Y', p_summer_time),0);
      ELSE        -- Get forecast/official production normal operations
    FOR curQty IN c_qty(p_object_id, ld_startDate, p_daytime) LOOP
      IF (p_xtra_qty = 1) THEN
        ln_day_official := curQty.qty2;
      ELSIF (p_xtra_qty = 2) THEN
        ln_day_official := curQty.qty3;
      ELSE
        ln_day_official := curQty.qty;
      END IF;
    END LOOP;

		-- Get lifted qty normal operations
		ln_day_tot_lifted := Nvl(EcDp_Storage_Balance.getAccEstLiftedQtySubDay(p_object_id, ld_startDate, p_daytime, p_xtra_qty, 'Y'),0);
  END IF;

  IF (lv_storage_type = 'IMPORT') THEN
    ln_closing_balance := ln_closing_balance - nvl(ln_day_official, 0) + ln_day_tot_lifted;
  ELSE
    ln_closing_balance := ln_closing_balance + nvl(ln_day_official, 0) - ln_day_tot_lifted;
  END IF;

  ln_closing_balance := ln_closing_balance + nvl(ln_adjustment,0);

  /*****************************
  SAVE GLOBAL VARS FOR NEXT ITERATION
  *******************************/
  --STORE current calc'ed closing balance for next iteration if the cache is turn ON (p_ignore_cache = 'N')
  IF (p_ignore_cache = 'N') THEN
    IF p_xtra_qty=1 THEN
      gv_prev_sub_date2(ln_index):=p_daytime;
      gv_prev_sub_qty2(ln_index):=ln_closing_balance;
      gv_prev_sub_object2(ln_index):=p_object_id;
      gv_prev_sub_st_flag2(ln_index):=p_summer_time;
    ELSIF p_xtra_qty=2 THEN
      gv_prev_sub_date3(ln_index):=p_daytime;
      gv_prev_sub_qty3(ln_index):=ln_closing_balance;
      gv_prev_sub_object3(ln_index):=p_object_id;
      gv_prev_sub_st_flag3(ln_index):=p_summer_time;
    ELSE
      gv_prev_sub_date(ln_index):=p_daytime;
      gv_prev_sub_qty(ln_index):=ln_closing_balance;
      gv_prev_sub_object(ln_index):=p_object_id;
      gv_prev_sub_st_flag(ln_index):=p_summer_time;
    END IF;
  END IF;

  RETURN ln_closing_balance;

END calcEstClosingBalanceSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAdjustmentsMth
-- Description    : Get all adjustments for a month. It support sub day adjustments
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
FUNCTION getAdjustmentsMth(p_object_id VARCHAR2,
               p_daytime   DATE,
               p_xtra_qty  NUMBER DEFAULT 0) RETURN NUMBER
--</EC-DOC>
 IS

  ld_from_date      DATE;
  ld_to_date        DATE;
  lv_read_prod_day   VARCHAR2(1);

BEGIN

  lv_read_prod_day := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_production_day');

  IF lv_read_prod_day = 'Y' THEN
    ld_from_date      := EcDp_ProductionDay.getProductionDayStart('STORAGE',ec_lifting_account.storage_id(p_object_id),TRUNC(p_daytime));
    ld_to_date        := ADD_MONTHS(ld_from_date, 1);
  ELSE
     ld_from_date      := TRUNC(p_daytime);
     ld_to_date        := ADD_MONTHS(ld_from_date, 1);
  END IF;

  RETURN getAdjustments(p_object_id, ld_from_date, ld_to_date, p_xtra_qty);

END getAdjustmentsMth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAdjustmentsDay
-- Description    : Get all adjustments until a day. It support sub day adjustments
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
FUNCTION getAdjustmentsDay(p_object_id VARCHAR2,
               p_daytime   DATE,
               p_xtra_qty  NUMBER DEFAULT 0) RETURN NUMBER
--</EC-DOC>
 IS
  ld_from_date      DATE;
  ld_to_date        DATE;
  lv_read_prod_day   VARCHAR2(1);

BEGIN

  lv_read_prod_day := ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/storage_level/use_production_day');

  IF lv_read_prod_day = 'Y' THEN
    ld_from_date := EcDp_ProductionDay.getProductionDayStart('STORAGE',ec_lifting_account.storage_id(p_object_id),trunc(p_daytime,'MM'));
    ld_to_date   := EcDp_ProductionDay.getProductionDayStart('STORAGE',ec_lifting_account.storage_id(p_object_id),p_daytime) + 1;
  ELSE
    ld_from_date := trunc(p_daytime,'MM');
    ld_to_date   := p_daytime + 1;
  END IF;

  RETURN getAdjustments(p_object_id, ld_from_date, ld_to_date, p_xtra_qty);

END getAdjustmentsDay;

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
               p_from_date DATE,
               p_to_date DATE,
               p_xtra_qty  NUMBER DEFAULT 0) RETURN NUMBER
--</EC-DOC>
 IS

BEGIN
  RETURN getAdjustments(p_object_id, p_from_date, (p_to_date + 1/24), p_xtra_qty);

END getAdjustmentsSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : IsCargosClosed
-- Description    : Cargo is closed if cargo status is Closed, Approved or Cancelled
--                  A Cargo belong to the month where the bl_date is set (or nom firm date if bl date is missing)
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lift_nomination, cargo_transport
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsCargosClosed(p_lifting_account_id VARCHAR2,
            p_daytime  DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

  CURSOR c_unclosed_cargos (cp_lifting_account_id VARCHAR2, cp_daytime  DATE) IS
    SELECT count(*) count
    FROM storage_lift_nomination sln, cargo_transport ca
    WHERE sln.cargo_no = ca.cargo_no
    AND sln.lifting_account_id = cp_lifting_account_id
    AND Nvl(sln.bl_date,sln.nom_firm_date) BETWEEN TRUNC(cp_daytime,'mm') AND LAST_DAY(cp_daytime)
    AND EcBp_Cargo_Status.getEcCargoStatus(ca.cargo_status) NOT IN ('C','A', 'D');

  lv2_isClosed     VARCHAR2(1) := 'Y';

BEGIN

  FOR curCargo IN c_unclosed_cargos (p_lifting_account_id, p_daytime)  LOOP
    IF curCargo.count > 0 THEN
      lv2_isClosed := 'N';
    END IF;
  END LOOP;

  RETURN lv2_isClosed;

END IsCargosClosed;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : valInsertInitBalance
-- Description    :
--
-- Preconditions  :
-- Postconditions :
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
PROCEDURE valInsertInitBalance(p_object_id VARCHAR2)
--</EC-DOC>
IS

CURSOR   c_balance (cp_object_id VARCHAR2)
IS
SELECT  *
FROM  lift_account_mth_balance
WHERE  object_id = cp_object_id;

BEGIN
  FOR curBalance IN c_balance(p_object_id) LOOP
    Raise_Application_Error(-20307,'A Lifting Account cannot be initialized more than once');
  END LOOP;

END valInsertInitBalance;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : valUpdateInitBalance
-- Description    :
--
-- Preconditions  :
-- Postconditions :
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
PROCEDURE valUpdateInitBalance(p_object_id VARCHAR2, p_daytime DATE)
--</EC-DOC>
IS

CURSOR   c_balance (cp_object_id VARCHAR2, cp_daytime DATE)
IS
SELECT  count(*) cnt
FROM  lift_account_mth_balance
WHERE  object_id = cp_object_id;

BEGIN
  FOR curBalance IN c_balance(p_object_id, p_daytime) LOOP
    IF curBalance.cnt > 2 THEN
      Raise_Application_Error(-20319,'Not allowed to change date or start balance after next months balance is closed');
    ELSE
      DELETE from lift_account_mth_balance WHERE object_id= p_object_id and balance is null and daytime=
      (select max(daytime) from LIFT_ACCOUNT_MTH_BALANCE where object_id= p_object_id);
    END IF;
  END LOOP;

END valUpdateInitBalance;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : setClosingBalance
-- Description    :
--
-- Preconditions  :
-- Postconditions : Uncommited changes
--
-- Using tables   : lift_account_mth_balance                                                                                                                         --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setClosingBalance(p_object_id  VARCHAR2,
                   p_daytime    DATE,
                   p_balance    NUMBER,
                   p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
  ln_count        NUMBER;

BEGIN
--TODO Must set balance2

  -- Check whether the previous month is closed
  IF isLiftingAccountClosed(p_object_id,ADD_MONTHS(TRUNC(p_daytime,'mm'),-1)) = 'N' THEN
    Raise_Application_Error(-20310,'The lifting account for previous month has not been closed!' );
  END IF;

  -- Check whether the current month is closed
  IF isLiftingAccountClosed(p_object_id,TRUNC(p_daytime,'mm')) = 'Y' THEN
    Raise_Application_Error(-20576,'The lifting account for current month has been closed!' );
  END IF;

  -- Check wheter all cargos are closed
  IF IsCargosClosed(p_object_id,p_daytime) = 'N' THEN
    Raise_Application_Error(-20311,'All cargos have not been closed!');
  END IF;

  -- Check whether receipts for storages and commercial entity are missing
  IF EcDp_Lift_Acc_Official.IsMissingOfficialNumbers(p_object_id, p_daytime) = 'Y' THEN
    Raise_Application_Error(-20317,'Official numbers for Lifting Account are missing!');
  END IF;

   UPDATE lift_account_mth_balance
   SET balance = p_balance, last_updated_by = Nvl(p_user,USER), last_updated_date = Ecdp_Timestamp.getCurrentSysdate, rev_no = rev_no + 1
   WHERE object_id = p_object_id
   AND daytime = p_daytime;

  -- Do we need an update or insert statement?
  SELECT count(*)
    INTO ln_count
  FROM lift_account_mth_balance
  WHERE object_id = p_object_id
  AND daytime = ADD_MONTHS(p_daytime,1);

  IF ln_count = 0 THEN
    INSERT INTO lift_account_mth_balance(object_id, daytime, created_by)
    VALUES(p_object_id, ADD_MONTHS(p_daytime,1), Nvl(p_user,USER));
  END IF;

  -- update record status
  UPDATE  lift_acc_day_official
  SET    record_status = 'V', last_updated_by = Nvl(p_user,USER), last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE   object_id = p_object_id
    AND daytime BETWEEN TRUNC(p_daytime,'mm') AND LAST_DAY(p_daytime);

  UPDATE  lift_account_adjustment
  SET    record_status = 'V', last_updated_by = Nvl(p_user,USER), last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE   object_id = p_object_id
    AND daytime BETWEEN TRUNC(p_daytime,'mm') AND LAST_DAY(p_daytime);

  UPDATE  lift_account_mth_balance
  SET    record_status = 'V', last_updated_by = Nvl(p_user,USER), last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE   object_id = p_object_id
    AND daytime BETWEEN TRUNC(p_daytime,'mm') AND LAST_DAY(p_daytime);

END setClosingBalance;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : openNextMonthRecord
-- Description    :
--
-- Preconditions  :
-- Postconditions :
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
PROCEDURE openNextMonthRecord(p_object_id VARCHAR2, p_daytime DATE)
--</EC-DOC>
IS

CURSOR   c_balance (cp_object_id VARCHAR2, cp_daytime DATE)
IS
SELECT  count(*) cnt
FROM  lift_account_mth_balance
WHERE  object_id = cp_object_id and daytime=ADD_MONTHS(cp_daytime,1);

BEGIN
  FOR curBalance IN c_balance(p_object_id, p_daytime) LOOP
    IF curBalance.cnt = 0 THEN
       INSERT INTO lift_account_mth_balance(object_id, daytime, created_by)
       VALUES(p_object_id, ADD_MONTHS(p_daytime,1), ecdp_context.getAppUser);
    END IF;
  END LOOP;

END openNextMonthRecord;

END EcBp_Lift_Acc_Balance;