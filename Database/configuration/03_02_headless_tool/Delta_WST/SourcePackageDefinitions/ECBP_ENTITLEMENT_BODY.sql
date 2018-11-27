CREATE OR REPLACE PACKAGE BODY EcBp_Entitlement IS
/****************************************************************
** Package        :  EcBp_entitlement
**
** $Revision: 1.18 $
**
** Purpose        :  This package is responsible for calculating the availability
**                   for each equity holder, third party and contracted lifter
**                   associated with a terminal or production facility.
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.03.2001  Bj�Ovin Wivestad
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- --------------------------------------
** 110701   DN    Moved TYPE definition to body. Changed parameter interface
**                in function find_largest_entitlement. Rewritten code in that function.
**                Removed debug output statements.
** 120701   DN    Rewrote find_day_share with cursor loop usage.
**                Replaced COUNT with li_index in calc_contract_sales and calc_contract_nominations
** 240901   BOW   Rewrote CALC_PRODUTION to match database fix with new column in ACCOUNT -> ACCOUNT_CATEGORY.
** 111201   BOW   Changed IF criteria in calc_production from
**                   IF lv_account_category = 'AGREEMENT' to
**                   IF lv_account_category <> 'PRODUCTION'
**                          to handle other categories as well. New category added -> 'REFINERY'. Needed to isolate the OFFTAKE figures
** 190302   DN    Removed find_last_stor_date, get_stor_vol and generate_lifting_program. These function should be redesigned using new storage tables.
** 271202   HNE   New option to get plan data in function forecast_prod_day.
**                New procedure write_account_mth_balance.
**                Enhanced find_day_eco_share to support PSA agreements
** 230103   HNE   Removed nvl() in RETURN statement for function real_prod_day
**                Changed get_production_by_day to only pick forecasted number when production is NULL (and not 0)
** 060203   HNE   Added parameter p_daytime in call to find_start_date.
**                Added changes NIH did in april 2002.
** 300903   LJG   Changed findGrsStdVol to findNetStdVol in real_prod_day.
**                Removed cursor and code for terminal_receipt, as this will not be used anymore.
** 021003   HNE   Ref change 300903, need to test on grs_vol is not null, before accessing net_vol.
** 181103   DN    Replaced sysdate with new function.
** 010304   SHN   Removed use of table ctrl_alloc_log in procedure Write_Account_Mth_Balance.
**                Raise an exception instead of writing to ctrl_alloc_log.
** 081004   DN    Removed function calc_production_contract and find_day_share.
** 230105   kaurrnar      Changed COMPANY_ATTRIBUTE to COMPANY_VERSION
** 010305   Darren Changed referencing columns name to new columns name
**                   Changed find_day_eco_share ship_attribute to ship_version
** 020305 kaurrnar	Removed deadcodes.
** 070305   DN    Re-introduced ship_attribute.
** 280405   DN    Function forcast_prod_day: Removed unused local variable.
** 021105   DN    Removed unused local variable.
** 051108 leeeewei Modified cursor c_get_prod_share in function find_day_eco_share
** 250211 leongwen ECPD-16917 Fluid Type on Equity Share should be exposed in business logics
*****************************************************************/

/* FUNCTIONS local and global*/
-----------------------------------------------------------------------
-- Calculate the total production for a given company/account i a month
-----------------------------------------------------------------------
FUNCTION calc_production(p_storage_id   VARCHAR2,
                         p_shipper        VARCHAR2,
                         p_company_id     VARCHAR2,
                         p_account_no     VARCHAR2,
                         p_prod_plan      VARCHAR2,
                         p_from_day       DATE,
                         p_to_day         DATE,
                         p_phase          VARCHAR2) RETURN NUMBER
IS

ln_total_prod        NUMBER := 0;
lv_account_category VARCHAR2(16);

BEGIN
	-- Decide account type 'PRODUCTION'/'AGREEMENT'
	lv_account_category := ec_account.account_category(p_account_no);

	-- Calculate the production volume
	IF lv_account_category = 'PRODUCTION' THEN
		ln_total_prod := calc_production_prod(p_storage_id, p_shipper, p_company_id, p_prod_plan, p_from_day, p_to_day, p_phase);
	END IF;

	IF ln_total_prod IS NULL THEN
		ln_total_prod := 0;
	END IF;

	RETURN ln_total_prod;

END calc_production;

---------------------------------------------------------------
-- Find the total lifted volume for a company in a time period
-- This includes planned and real
-- HNE 23.01.03: Changed cursor after discussions with BOW. Added UNION ++
----------------------------------------------------------------
FUNCTION get_lifted_volume(p_account_no    VARCHAR2,
                           p_storage_id  VARCHAR2,
                           p_from_day      DATE,
                           p_to_day        DATE) RETURN NUMBER
IS
CURSOR c_get_parcel_no
IS
SELECT parcel_no
FROM acc_transaction ac
WHERE ac.daytime BETWEEN p_from_day AND p_to_day
AND ac.account_no = p_account_no
AND tran_status = 'A'
AND transaction_type = 'LIFTED'
UNION
SELECT parcel_no
FROM acc_transaction ac
WHERE ac.daytime BETWEEN p_from_day AND p_to_day
AND ac.account_no = p_account_no
AND tran_status = 'A'
AND transaction_type = 'PLANNED'
AND NOT EXISTS
    (SELECT 1
    FROM acc_transaction ac2
    WHERE ac2.account_no = ac.account_no
    AND ac2.tran_status = ac.tran_status
    AND ac2.parcel_no = ac.parcel_no
    AND ac2.transaction_type = 'LIFTED')
;

ln_lifted_vol     NUMBER := 0;

BEGIN

  FOR curParcelNo IN c_get_parcel_no LOOP
   ln_lifted_vol := ln_lifted_vol + ecbp_transaction.get_transaction_account(p_storage_id, curParcelNo.parcel_no, p_account_no);
 END LOOP;

  RETURN ln_lifted_vol;

END get_lifted_volume;
---------------------------------------------------------------
-- Find the account balance for a day
----------------------------------------------------------------
FUNCTION calc_day_balance(p_storage_id   VARCHAR2,
                          p_shipper        VARCHAR2,
                          p_company_id     VARCHAR2,
                          p_account_no     VARCHAR2,
                          p_daytime        DATE,
                          p_prod_plan      VARCHAR2,
                          p_phase          VARCHAR2) RETURN NUMBER
IS

ln_lifted_vol     NUMBER;
ln_prod_vol       NUMBER;
ln_balance        NUMBER := 0;
ln_offtake        NUMBER := 0;
ln_adjustment        NUMBER := 0;
ld_from_day       DATE;

BEGIN

-- Find last official balance
  ld_from_day := find_start_date(p_account_no, p_daytime);

  ln_balance := ec_account_mth_balance.balance(p_account_no, ld_from_day);
  IF ln_balance IS NULL THEN
      ln_balance := 0;
  END IF;

  ln_lifted_vol := get_lifted_volume(p_account_no, p_storage_id, ld_from_day, p_daytime);

  ln_offtake := ecbp_account_status.refinery_offtake(p_storage_id, p_company_id, ld_from_day, p_daytime);

  ln_adjustment := ecbp_account_status.adjustment(p_storage_id, p_company_id, ld_from_day, p_daytime);

  ln_prod_vol := calc_production(p_storage_id, p_shipper, p_company_id, p_account_no, p_prod_plan, ld_from_day, p_daytime, p_phase);

  ln_balance := ln_balance + ln_prod_vol - ln_lifted_vol - ln_offtake + ln_adjustment;

  RETURN ln_balance;

END calc_day_balance;

---------------------------------------------------------------
-- Decide the last registered balance
----------------------------------------------------------------
FUNCTION find_start_date(p_account_no VARCHAR2, p_daytime DATE) RETURN DATE
IS

ld_start_day  DATE;

BEGIN
  SELECT MAX(daytime)
  INTO ld_start_day
  FROM account_mth_balance
  WHERE account_no = p_account_no
  AND daytime <= nvl(p_daytime,Ecdp_Timestamp.getCurrentSysdate);

  RETURN ld_start_day;

END find_start_date;

---------------------------------------------------------------------------------------------------------
-- PROCEDURE Write_account_mth_balance
---------------------------------------------------------------------------------------------------------
--<EC-DOC>
PROCEDURE Write_account_mth_balance (p_storage_id VARCHAR2,
                                     p_daytime DATE,
                                     p_phase VARCHAR2) IS

CURSOR c_account(ld_day DATE) IS
SELECT a.storage_id
,coent.object_code shipper
,a.company_id
,a.account_no
,s.daytime
,'OFFICIAL' prod_plan
FROM  account a, commercial_entity coent, system_days s
WHERE s.daytime = ld_day
AND s.daytime BETWEEN a.start_date AND nvl(a.end_date,s.daytime)
AND a.storage_id = p_storage_id
AND a.commercial_entity_id = coent.object_id;

ln_account NUMBER;
ld_day DATE;

BEGIN

   ld_day := Last_Day(p_daytime);
   -- cannot write future dates
   IF ld_day < trunc(Ecdp_Timestamp.getCurrentSysdate,'MM') THEN

      FOR thisrow IN c_account(ld_day) LOOP
         ln_account := nvl(calc_day_balance(thisrow.storage_id,
                                            thisrow.shipper,
                                            thisrow.company_id,
                                            thisrow.account_no,
                                            thisrow.daytime,
                                            thisrow.prod_plan,
                                            p_phase),0);
         DELETE FROM account_mth_balance
         WHERE account_no = thisrow.account_no
         AND daytime = thisrow.daytime+1;

         INSERT INTO account_mth_balance (account_no, daytime, balance)
         VALUES (thisrow.account_no, thisrow.daytime+1, ln_account);

      END LOOP;

   ELSE
      Raise_Application_Error(-20000,'Monthly account balance cannot be run for current or future months');
   END IF;
END Write_Account_Mth_Balance;


-----------------------------------------------------------------------
-- Calculate the total production, forecast and real for a given period
-- Handles a change of share during the calculation period
-----------------------------------------------------------------------
FUNCTION calc_production_prod(p_storage_id   VARCHAR2,
                              p_shipper        VARCHAR2,
                              p_company_id     VARCHAR2,
                              p_plan           VARCHAR2,
                              p_from_day       DATE,
                              p_to_day         DATE,
                              p_phase          VARCHAR2) RETURN NUMBER
IS

ld_day          DATE;
ln_total_prod   NUMBER := 0;

BEGIN

  --Start looping from ld_day until end of month or specified day
  ld_day := p_from_day;

  WHILE ld_day <= p_to_day LOOP
    ln_total_prod := ln_total_prod + ((find_day_eco_share(p_shipper, p_company_id, ld_day, p_phase)/100) * get_production_by_day(p_storage_id, p_shipper, p_plan, ld_day));
    ld_day := ld_day + 1;
  END LOOP;

  RETURN ln_total_prod;

END calc_production_prod;

---------------------------------------------------------------
-- Find the equity_share for a day.
-- Need to loop since values might change during a period.
----------------------------------------------------------------
FUNCTION find_day_eco_share(p_shipper VARCHAR2,
							       p_company_id VARCHAR2,
							       p_day DATE,
                     p_phase VARCHAR2) RETURN NUMBER
IS


CURSOR c_get_prod_share(cp_shipper VARCHAR2, cp_company_id VARCHAR2, cp_daytime DATE) IS
SELECT es.eco_share
FROM commercial_entity coent,
	coent_version cv,
	equity_share es,
	licence l
WHERE es.company_id = cp_company_id
AND es.daytime = (SELECT MAX(daytime)
                  FROM equity_share
                  WHERE daytime <= cp_daytime
                  AND object_id = es.object_id
                  AND fluid_type = es.fluid_type)
AND coent.object_code = cp_shipper
AND cp_daytime >= cv.daytime
AND cp_daytime < nvl(cv.end_date, cp_daytime+1)
AND l.object_id = cv.licence_id
AND es.object_id = cv.object_id
AND cv.object_id = coent.object_id
AND es.fluid_type = p_phase;

ln_equity_share  NUMBER;

BEGIN

  OPEN c_get_prod_share(p_shipper, p_company_id, p_day);

  FETCH c_get_prod_share INTO ln_equity_share;
	  IF c_get_prod_share%NOTFOUND THEN
	    ln_equity_share := 0;
	  END IF;
  CLOSE c_get_prod_share;

  RETURN ln_equity_share;

END find_day_eco_share;

---------------------------------------------------------------
-- Find production volume forecast or real prod for a given day.
----------------------------------------------------------------
FUNCTION get_production_by_day(p_storage_id   VARCHAR2,
                               p_shipper        VARCHAR2,
                               p_plan           VARCHAR2,
                               p_day            DATE) RETURN NUMBER
IS

  ln_production   NUMBER;

BEGIN


  ln_production := real_prod_day(p_storage_id, p_shipper, p_day);
  --Get forecast if no real production
  IF ln_production IS NULL THEN
    ln_production := forcast_prod_day(p_storage_id, p_shipper, p_plan, p_day);
  END IF;

  RETURN Nvl(ln_production, 0);

END get_production_by_day;

---------------------------------------------------------------
-- Find real prod for a given day.
-- HNE Added test on grs_vol before accessing net_vol. If no production return null, then forcast is used.
----------------------------------------------------------------
FUNCTION real_prod_day(p_storage_id VARCHAR2,
         p_shipper VARCHAR2,
         p_daytime DATE)
         RETURN NUMBER
IS

lv2_prod_conf VARCHAR2(32);
lv2_prod_stream VARCHAR2(1000);
ln_real_prod_day NUMBER := NULL;

BEGIN

  lv2_prod_conf := ec_stor_version.RECEIPTS_SOURCE_CLASS(p_storage_id, p_daytime, '<=');
  IF lv2_prod_conf = 'STREAM' THEN
    lv2_prod_stream := ec_stor_version.RECEIPTS_OBJECT_ID(p_storage_id, p_daytime, '<=');
    IF ecbp_stream_fluid.findGrsStdVol(lv2_prod_stream, p_daytime) IS NOT NULL THEN -- net_vol is 0 when grs_vol is null.
        ln_real_prod_day := ecbp_stream_fluid.findNetStdVol(lv2_prod_stream, p_daytime);
    ELSE
        ln_real_prod_day := NULL;
    END IF;
  ELSE
    null;
  END IF;

  RETURN ln_real_prod_day;

END real_prod_day;

---------------------------------------------------------------
-- Find production volume forecast for a given day.
----------------------------------------------------------------
FUNCTION forcast_prod_day(
         p_storage_id VARCHAR2,
         p_shipper VARCHAR2,
         p_plan    VARCHAR2,
         p_daytime DATE)
         RETURN NUMBER
IS

ln_forcast_prod_day NUMBER := 0;
lv2_prod_conf VARCHAR2(32);
ln_real_prod_day NUMBER := NULL;

lv2_plan_method VARCHAR2(32);

lv2_stream_id VARCHAR2(32);

BEGIN

  lv2_prod_conf := ec_stor_version.PLAN_SOURCE_CLASS(p_storage_id, p_daytime, '<=');

  IF lv2_prod_conf = 'STREAM' THEN

    -- check if stream in plan_item, if so look up plan_item_value
    lv2_plan_method := ec_stor_version.PLAN_METHOD(p_storage_id, p_daytime, '<=');
    lv2_stream_id := ec_stor_version.PLAN_OBJECT_ID(p_storage_id, p_daytime, '<=');

    IF lv2_plan_method = 'STREAM' THEN
      -- Needs to define a derived stream that holds the correct number. Plan value is too generic....
      -- Hardcode in the derived stream package the correct select statement against plan_value.
      ln_forcast_prod_day := Ecbp_Stream_Fluid.Findgrsstdvol(lv2_stream_id, p_daytime);

    END IF;

  END IF;

  RETURN ln_forcast_prod_day;

END forcast_prod_day;


END EcBp_Entitlement;