CREATE OR REPLACE PACKAGE BODY EcDp_Sales_Accounting IS
/******************************************************************************
** Package        :  EcDp_Sales_Accounting, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Account processing and approval
**
** Documentation  :  www.energy-components.com
**
** Created  : 13.12.2004 Bent Ivar Helland
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   Initial version (first build / handover to test)
** 11.01.2005  BIH   Added / cleaned up documentation
** 01.03.2005  kaurrnar	Removed references to ec_xxx_attribute packages.
**			Renamed xxx_attribute table to xxx_version.
** 11.03.2005  DN    Redefined getAccountAttributeText with new name getAccountAttributeVersion. Added getAccountName.
** 06.07.2005  DN    TI-2298: renamed cntr_delivery_event tp cntr_dp_event.
** 09.08.2005 kaurrnar	Added 'where' condition to approveMonthlyAccounts to access cntr_DP_EVENT table
** 06.12.2005  skjorsti	Removed function getAccountAttributeVersion (ti3106)
** 06.12.2005  skjorsti	Updated function getAccountCalcOrder to use new package (ti3106)
** 06.12.2005  skjorsti	Updated cursor c_accounts to use new table contract_account (ti3106)
** 06.12.2005  skjorsti	Updated function processDailyAccounts. Updated reference to cursor c_accounts and to function EcDp_Sales_Acc_Price_Concept (ti3106)
** 07.12.2005  skjorsti	Removed function getAccountName. As no version table exists anymore, PK is enough as argument for this property -> using ec_package instead (ti3106)
** 07.12.2005  skjorsti	Updated function updateAccountStatus; deemed_qty->vol_qty, added account_code argument to function and modified statements accordingly (ti3106).
** 07.12.2005  skjorsti	Updated function processDailyAccounts; added argument account_code to call to updateAccountStatus (ti3106).
** 07.12.2005  skjorsti	Updated function isAccountEditable; removed daytime argument. Replaced call to function getAccountAttributeVersion with call to ec_contract_account. Argument usage should be reconsidered (ti3106)
** 07.12.2005  skjorsti	Updated function getNumberOfApprovedAccounts. Rewritten join between cntr_acc_period_status and contract_account. Status record still compared towards column in cntr_acc_period_status (ti3106)
** 07.12.2005  skjorsti	Updated function getNumberOfProcessedAccounts. Rewritten join between cntr_acc_period_status and contract_account. Date is found in table contract (ti3106)
** 07.12.2005  skjorsti	Updated function approveYearlyAccounts. Rewritten join between cntr_acc_period_status and contract_account. Date is found in table contract (ti3106)
** 07.12.2005  skjorsti	Updated function approveMonthlyAccounts. Rewritten join between cntr_acc_period_status and contract_account. Date is found in table contract (ti3106)
** 13.12.2005  skjorsti Modified references to ecdp_sales_contract.<function> to use ecdp_contract instead.
** 13.12.2005  skjorsti Updated functions according to redesign of contracts and accounts (TI3102/3106)
** 16.12.2005  eideekri	Updated function processDailyAccounts. Rewritten for the change from del_qty into vol_qty, mass_qty and energy_qty.
** 01.02.2006  skjorsti Updated procedure processMonthlyAccounts and  processYearlyAccounts. Added contract-date validation to cursor c_accounts. (TD 5520/5546/5499)
** 21-07-2009 leongwen ECPD-11578 support multiple timezones to add production object id to pass into the function ecdp_date_time.summertime_flag()
** 25-10-2016  thotesan ECPD-37786: Modified update statements in approveMonthlyAccounts,approveYearlyAccounts so that last_updated_date will be populated when function is triggered.
*****************************************************************************************************************************************************************************/

--
-- Cursor used by several methods in this package to find all accounts for a contract,
-- including the account's price concept code
-- The result is sorted on the account calculation order.
--
CURSOR 		c_accounts(p_contract_id VARCHAR2, p_daytime DATE) IS
   SELECT 	a.object_id, a.account_code, a.price_concept_code as category
   FROM 	contract_account a, contract c
   WHERE 	c.object_id = a.object_id 				AND
   			a.object_id = p_contract_id 		AND
   			c.start_date <= p_daytime 				AND
   			Nvl(c.end_date,p_daytime+1) > p_daytime
  ORDER BY getAccountCalcOrder(category);


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : processDailyAccounts
-- Description    : Processes the daily accounts.
--
-- Preconditions  : The p_contract_day parameter should be the logical contract day (zero hours/minutes/seconds).
--                  Must have delivery data for the requested contract day.
-- Postconditions :
--
-- Using tables   : nomination_point
--                  cntr_period_status
--
-- Using functions: getNumberOfApprovedAccounts
--                  updateAccountStatus
--                  getHourlyOffSpecFraction
--                  getDailyOffSpecFraction
--                  EcDp_Contract.getContractDayStartTime
--                  EcDp_Sales_Contract.getContractDayHours
--                  EcDp_Sales_Delivery.getNumberOfSubDailyRecords
--                  EcDp_Sales_Delivery.getSubDailyDeliveredQty
--                  EcDp_Sales_Delivery.getDailyDeliveredQty
--                  EcDp_Sales_Contract_Price.getNormalGasUnitPrice
--                  EcDp_Sales_Contract_Price.getOffspecGasUnitPrice
--
-- Configuration
-- required       :
--
-- Behaviour      : First checks that the user have the necessary rights if the accounts have been approved.
--                  Then the accounts are calculated, based on category:
--                   * Normal Gas and Off-spec Gas accounts are calculated from an analysis of any off-spec events
--                     that intersect with the given day. If hourly data exist then the analysis is done by looking for
--                     the fraction of each hour that is off-spec. Otherwise the analysis is done as fractions of the
--                     total daily quantity.
--                   * Total Delivered Gas accounts are calculated as Normal Gas + Offspec Gas
--                     the daily account values.
--                  If hourly data exist then the price determination is done at the start of each hour.
--                  Otherwise, the price at the start of the contract day is used for the whole day.
--                  Finally, the day status record is updated with the last run date.
--
---------------------------------------------------------------------------------------------------
PROCEDURE processDailyAccounts(
  p_contract_id  VARCHAR2,
  p_contract_day       DATE,
  p_username           VARCHAR2,
  p_accessLevel        INTEGER
)
--</EC-DOC>
IS
   ld_daytime              DATE;    -- The daytime to use for looking up values, = contract day start time
   ln_normal_qty           NUMBER;
   ln_normal_price         NUMBER;
   ln_offspec_qty          NUMBER;
   ln_offspec_price        NUMBER;
   ln_normal_unit_price    NUMBER;
   ln_offspec_unit_price   NUMBER;
   ln_tot_qty              NUMBER;
   ln_offspec_frac         NUMBER;
   r_hours                 EcDp_Date_Time.Ec_Unique_Daytimes;
   lecd_ProductionDayStart EcDp_Date_Time.EC_unique_daytime;
   CURSOR c_dps(p_daytime DATE) IS
      SELECT delivery_point_id
      FROM nomination_point
      WHERE contract_id = p_contract_id
      AND start_date <= p_daytime
      AND NVL(end_date, p_daytime+1) > p_daytime;
BEGIN
   -- TODO: validate p_contract_day

   -- Check access level vs data status
   --
   IF getNumberOfApprovedAccounts(p_contract_id,p_contract_day,'DAY') > 0 AND p_accessLevel<60 THEN
      RAISE_APPLICATION_ERROR(-20500,'Unsufficient priviliges to recalculate approved accounts for '||to_char(p_contract_day,'yyyy-mm-dd'));
   END IF;

   -- We need the full daytime to get the correct price info if hourly prices are allowed...
   lecd_ProductionDayStart := EcDp_ContractDay.getProductionDayStartTime('CONTRACT',p_contract_id,p_contract_day);
   ld_daytime := lecd_ProductionDayStart.daytime;
   --
   -- Calculate the base numbers (normal and offspec qty and price) for the contract
   --
   ln_normal_qty := 0;
   ln_normal_price := 0;
   ln_offspec_qty := 0;
   ln_offspec_price := 0;
   FOR r_dp IN c_dps(ld_daytime) LOOP
      -- Are there any sub-daily data for this delivery point?
      IF EcDp_Contract_Delivery.getNumberOfSubDailyRecords(p_contract_id,r_dp.delivery_point_id,p_contract_day) > 0 THEN

         --
         -- Calculate on hourly level
         --
         r_hours := EcDp_ContractDay.getProductionDayDaytimes('CONTRACT',p_contract_id,p_contract_day);
         FOR i IN 1..r_hours.COUNT LOOP
            ln_tot_qty := EcDp_Contract_Delivery.getSubDailyDeliveredQty(p_contract_id, r_dp.delivery_point_id, r_hours(i).daytime);

            IF ln_tot_qty IS NULL THEN
               -- TODO: error handling for missing hourly delivery data ?
               ln_tot_qty := 0;
            END IF;
            ln_offspec_frac := getHourlyOffSpecFraction(p_contract_id, r_dp.delivery_point_id, r_hours(i).daytime);
            -- Get the price info
            ln_normal_unit_price := EcDp_Sales_Contract_Price.getNormalGasUnitPrice(p_contract_id, r_hours(i).daytime);
            ln_offspec_unit_price := EcDp_Sales_Contract_Price.getOffspecGasUnitPrice(p_contract_id, r_hours(i).daytime);
            -- Aggregate qty and price info
            ln_normal_qty := ln_normal_qty + ln_tot_qty * (1 - ln_offspec_frac);
            ln_normal_price := ln_normal_price + ln_tot_qty * (1 - ln_offspec_frac) * ln_normal_unit_price;
            ln_offspec_qty := ln_offspec_qty + ln_tot_qty * ln_offspec_frac;
            ln_offspec_price := ln_offspec_price + ln_tot_qty * ln_offspec_frac * ln_offspec_unit_price;
         END LOOP;
      ELSE
         --
         -- Calculate on daily level
         --
         -- Find total qty and the fraction of off-spec gas qty
         ln_tot_qty := EcDp_Contract_Delivery.getDailyDeliveredQty(p_contract_id, r_dp.delivery_point_id, p_contract_day);
         IF ln_tot_qty IS NULL THEN
            -- error handling for missing delivery data
            RAISE_APPLICATION_ERROR(-20501,'Missing daily delivery data for delivery point ''' ||
                          EcDp_Objects.getObjName(r_dp.delivery_point_id, ld_daytime) ||
                          ''' at '||to_char(p_contract_day,'yyyy-mm-dd')||chr(10) || chr(13));
         END IF;
         ln_offspec_frac := getDailyOffSpecFraction(p_contract_id, r_dp.delivery_point_id, p_contract_day);
         -- Get the price info
         ln_normal_unit_price := EcDp_Sales_Contract_Price.getNormalGasUnitPrice(p_contract_id, ld_daytime);
         ln_offspec_unit_price := EcDp_Sales_Contract_Price.getOffspecGasUnitPrice(p_contract_id, ld_daytime);
         -- Aggregate qty and price info
         ln_normal_qty := ln_normal_qty + ln_tot_qty * (1 - ln_offspec_frac);
         ln_normal_price := ln_normal_price + ln_tot_qty * (1 - ln_offspec_frac) * ln_normal_unit_price;
         ln_offspec_qty := ln_offspec_qty + ln_tot_qty * ln_offspec_frac;
         ln_offspec_price := ln_offspec_price + ln_tot_qty * ln_offspec_frac * ln_offspec_unit_price;
      END IF;
   END LOOP;

   --
   -- Update any contract accounts
   --
   FOR r_account IN c_accounts(p_contract_id, ld_daytime) LOOP
   	IF r_account.category = 'NORMAL_GAS' THEN
         updateAccountStatus(r_account.account_code,r_account.object_id, p_contract_day, 'DAY', ln_normal_qty,ln_normal_price,p_username);
      ELSIF r_account.category = 'OFF_SPEC_GAS' THEN
         updateAccountStatus(r_account.account_code,r_account.object_id, p_contract_day, 'DAY', ln_offspec_qty,ln_offspec_price,p_username);
      ELSIF r_account.category = 'TOTAL_DELIVERED_GAS' THEN
         updateAccountStatus(r_account.account_code,r_account.object_id, p_contract_day, 'DAY', NVL(ln_normal_qty,0)+NVL(ln_offspec_qty,0),NVL(ln_normal_price,0)+NVL(ln_offspec_price,0),p_username);
      END IF;
   END LOOP;

   -- Update run date
   UPDATE cntr_period_status
   SET run_date = Ecdp_Timestamp.getCurrentSysdate, last_updated_by = p_username
   WHERE object_id = p_contract_id
   AND daytime = p_contract_day
   AND time_span = 'DAY';

END processDailyAccounts;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : processMonthlyAccounts
-- Description    : Processes monthly accounts. Automatically processes all daily accounts for the entire month first.
--
-- Preconditions  : The p_contract_month parameter should be the logical contract month (zero days/hours/minutes/seconds).
-- Postconditions :
--
-- Using tables   : sales_contract
--                  cntr_acc_period_status
--                  cntr_account
--                  cntr_account_version
--                  cntr_period_status
--
-- Using functions: getNumberOfApprovedAccounts
--                  processDailyAccounts
--                  updateAccountStatus
--                  EcDp_Sales_Contract.getMonthlyTakeOrPayLimit
--                  EcDp_Contract_Attribute.getAttributeDaytime
--                  EcDp_Sales_Contract_Price.getMonthlyTakeOrPayPrice
--                  ec_cntr_version....
--                  EcDp_Sales_Account_Category.OFF_SPEC_GAS
--                  EcDp_Sales_Account_Category.NORMAL_GAS
--                  EcDp_Sales_Account_Category.TOTAL_DELIVERED_GAS
--                  EcDp_Sales_Account_Category.TAKE_OR_PAY_PENALTY
--                  EcDp_Sales_Account_Category.ADJUSTMENT
--                  EcDp_Sales_Account_Category.INVOICE_TOTAL
--
-- Configuration
-- required       :
--
-- Behaviour      : First checks that the user have the necessary rights if the accounts have been approved.
--                  Then the daily processing is run for the entire month, to make sure that the daily data
--                  exists and are up to date.
--                  Then the accounts are calculated, based on category:
--                   * Normal Gas, Off-spec Gas and Total Delivered Gas accounts are calculated by aggregating
--                     the daily account values.
--                   * Take-or-Pay Gas is calculated as max(take-or-pay limit - total delivered , 0).
--                     If there is no Total Delivered Gas account then the sum of Normal Gas and Off-spec Gas is used.
--                   * Adjustment accounts are not changed, but a new row is inserted if none exists in the data table
--                   * Invoice Total accounts are calculated as (total delivered + take-or-pay + adjustments).
--                     If there is no Total Delivered Gas account then the sum of Normal Gas and Off-spec Gas is used.
--                     If the "Enforce take-or-pay" contract attribute is set to No then take-or-pay will not be included.
--                  Finally, the month status record is updated with the last run date.
--
---------------------------------------------------------------------------------------------------
PROCEDURE processMonthlyAccounts(
   p_contract_id  VARCHAR2,
   p_contract_month     DATE,
   p_username           VARCHAR2,
   p_accessLevel        INTEGER
)
--</EC-DOC>
IS
   ld_daytime              DATE;    -- The daytime to use for looking up values, = contract month start time
   ld_contract_start       DATE;
   ld_contract_end         DATE;
   ld_day                  DATE;
   ln_qty                  NUMBER;
   ln_tot_price            NUMBER;
   ln_normal_qty           NUMBER;
   ln_offspec_qty          NUMBER;
   ln_total_del_qty        NUMBER;
   lv2_exlude_normal       VARCHAR2(100);
   lv2_exlude_offspec      VARCHAR2(100);
   lv2_exlude_takeorpay    VARCHAR2(100);
   li_tmp                  INTEGER;
   lv2_enforce_takeorpay   VARCHAR2(100);

	lr_contract contract%ROWTYPE;


BEGIN
   -- TODO: validate p_contract_month

   --
   -- Check access level vs data status
   --

   IF getNumberOfApprovedAccounts(p_contract_id,p_contract_month,'MTH') > 0 AND p_accessLevel<60 THEN
      RAISE_APPLICATION_ERROR(-20500,'Unsufficient priviliges to recalculate approved accounts for '||to_char(p_contract_month,'yyyy-mm'));
   END IF;

   ld_daytime := EcDp_Contract_Attribute.getAttributeDaytime(p_contract_id, p_contract_month, 'MTH');		-- 01.05.2004

   --
   -- Run daily processing for all days in month
   -- Limit to valid days for contract... (contract start / end date...)
   --
   lr_contract := ec_contract.row_by_pk(p_contract_id);
   ld_contract_start := lr_contract.start_date;	-- 01.09.2002
   ld_contract_end := lr_contract.end_date;		-- 01.12.2004


   ld_day := p_contract_month;
   WHILE ld_day < add_months(p_contract_month, 1) LOOP
      IF ld_day >= ld_contract_start AND ld_day < NVL(ld_contract_end,ld_day+1) THEN
         processDailyAccounts(p_contract_id,ld_day,p_username,p_accesslevel);
      END IF;
      ld_day := ld_day + 1;
   END LOOP;

   --
   -- Run through the accounts and calculate the results
   --
   FOR r_account IN c_accounts(p_contract_id, ld_daytime) LOOP								--	6 stk
      IF r_account.category IN ('NORMAL_GAS', 'OFF_SPEC_GAS', 'TOTAL_DELIVERED_GAS') THEN

         SELECT SUM(vol_qty), SUM(total_price) INTO ln_qty, ln_tot_price
         FROM cntr_acc_period_status
         WHERE object_id=r_account.object_id
         AND   account_code = r_account.account_code
         AND daytime>=p_contract_month AND daytime<add_months(p_contract_month, 1)
         AND time_span='DAY';

         updateAccountStatus(r_account.account_code,r_account.object_id,p_contract_month,'MTH',ln_qty,ln_tot_price,p_username);




        -- Store qty for later use!
        IF r_account.category = 'NORMAL_GAS' THEN
            ln_normal_qty:=ln_qty;
        ELSIF r_account.category = 'OFF_SPEC_GAS' THEN
            ln_offspec_qty:=ln_qty;
        ELSIF r_account.category = 'TOTAL_DELIVERED_GAS' THEN
            ln_total_del_qty:=ln_qty;
        END IF;

     ELSIF r_account.category = 'TAKE_OR_PAY_PENALTY' THEN
         ln_qty:=ln_total_del_qty;
         IF ln_qty IS NULL THEN
            ln_qty := NVL(ln_normal_qty,0) + NVL(ln_offspec_qty,0);
         END IF;
         -- TODO: change EcDp_Sales_Contract.getMonthlyTakeOrPayLimit(p_contract_id,p_contract_month) - ln_qty;
         ln_qty:= ecdp_contract_attribute.getAttributeNumber(p_contract_id, 'ACQ', p_contract_month)/12 * ecdp_contract_attribute.getAttributeNumber(p_contract_id, 'TAKE_OR_PAY_LIMIT', p_contract_month) - ln_qty;

        IF ln_qty > 0 THEN
            ln_tot_price := ln_qty * EcDp_Sales_Contract_Price.getMonthlyTakeOrPayPrice(p_contract_id,p_contract_month);
            updateAccountStatus(r_account.account_code,r_account.object_id,p_contract_month,'MTH',ln_qty,ln_tot_price,p_username);
         ELSE
            -- No take-or-pay value
            updateAccountStatus(r_account.account_code,r_account.object_id,p_contract_month,'MTH',0,0,p_username);
         END IF;

      ELSIF r_account.category = 'INVOICE_TOTAL' THEN
         -- If we have a total delivered then use all except normal and off-spec
         -- Otherwise we use all....
         lv2_exlude_normal:='x';
         lv2_exlude_offspec:='x';
         lv2_exlude_takeorpay:='x';

         IF ln_total_del_qty IS NOT NULL THEN
            lv2_exlude_normal:= 'NORMAL_GAS';
            lv2_exlude_offspec:= 'OFF_SPEC_GAS';
         END IF;
         -- Exclude take-or-pay if enforce <> Y
         lv2_enforce_takeorpay := ecdp_contract_attribute.getAttributeNumber(p_contract_id, 'TAKE_OR_PAY_ENFORCE_IND', ld_daytime);

         IF lv2_enforce_takeorpay <> 'Y' THEN
            lv2_exlude_takeorpay := 'TAKE_OR_PAY_PENALTY';
         END IF;

         SELECT SUM(vol_qty), SUM(total_price) INTO ln_qty, ln_tot_price
         FROM cntr_acc_period_status status, price_concept p,
         (
            SELECT a.object_id,a.price_concept_code, a.account_code
            FROM contract_account a, contract c, contract_version cv
            WHERE cv.object_id=c.object_id
            AND c.object_id = a.object_id
            AND a.object_id = p_contract_id
            AND cv.daytime = (SELECT MAX(daytime) FROM contract_version WHERE object_id = c.object_id AND c.object_id = a.object_id AND daytime<=ld_daytime)
            AND c.start_date <= ld_daytime
            AND NVL(c.end_date,ld_daytime+1) > ld_daytime
         ) account
         WHERE account.object_id = status.object_id
         AND account.account_code = status.account_code
         AND status.daytime = p_contract_month
         AND status.time_span='MTH'
         AND account.price_concept_code = p.price_concept_code
         AND p.price_concept_code NOT IN ('INVOICE_TOTAL', lv2_exlude_normal, lv2_exlude_offspec, lv2_exlude_takeorpay);

         updateAccountStatus(r_account.account_code,r_account.object_id,p_contract_month,'MTH',ln_qty,ln_tot_price,p_username);

      ELSIF r_account.category = 'ADJUSTMENT' THEN
         SELECT	COUNT(*) INTO li_tmp
         FROM 	cntr_acc_period_status
         WHERE 	object_id=r_account.object_id
         AND   	account_code = r_account.account_code
         AND 	daytime=p_contract_month
         AND 	time_span='MTH';

         IF li_tmp = 0 THEN
            -- Create blank record if it doesn't exist...
            updateAccountStatus(r_account.account_code,r_account.object_id,p_contract_month,'MTH',0,0,p_username);
         END IF;
      END IF;

   END LOOP;

   -- Update run date
   UPDATE cntr_period_status
   SET run_date = Ecdp_Timestamp.getCurrentSysdate, last_updated_by = p_username
   WHERE object_id = p_contract_id
   AND daytime = p_contract_month
   AND time_span = 'MTH';


END processMonthlyAccounts;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : processYearlyAccounts
-- Description    : Processes yearly accounts.
--
-- Preconditions  : The p_contract_year parameter should be the logical contract year (zero month/day/hour/minutes/seconds).
--                  Monthly accounts must be processed and approved for the entire contract year.
-- Postconditions :
--
-- Using tables   : sales_contract
--                  cntr_acc_period_status
--                  cntr_period_status
--
-- Using functions: getNumberOfApprovedAccounts
--                  getNumberOfProcessedAccounts
--                  updateAccountStatus
--                  EcDp_Contract_Attribute.getAttributeDaytime
--                  EcDp_Sales_Contract.getContractYearStartDate
--                  Ecdp_Timestamp.getCurrentSysdate
--
-- Configuration
-- required       :
--
-- Behaviour      : First checks that the user have the necessary rights if the accounts have been approved.
--                  Then the monthly values are aggregated to year level, taking contract year offset and
--                  potentially the contract's start or end date into account.
--                  Finally, the month status record is updated with the last run date.
--
---------------------------------------------------------------------------------------------------
PROCEDURE processYearlyAccounts(
  p_contract_id  VARCHAR2,
  p_contract_year      DATE,
  p_username           VARCHAR2,
  p_accessLevel        INTEGER
)
--</EC-DOC>
IS

   ld_daytime           DATE;
   ld_start_mth         DATE;
   ld_end_mth           DATE;
   ld_contract_start    DATE;
   ld_contract_end      DATE;
   ld_mth               DATE;
   li_num_acc           INTEGER;
   ln_qty               NUMBER;
   ln_price             NUMBER;
BEGIN

   --
   -- Check access level vs data status
   --
   IF getNumberOfApprovedAccounts(p_contract_id,p_contract_year,'YR') > 0 AND p_accessLevel<60 THEN
      RAISE_APPLICATION_ERROR(-20500,'Unsufficient priviliges to recalculate approved accounts for '||to_char(p_contract_year,'yyyy'));
   END IF;

   -- Get the dates to use in queries etc
   ld_daytime := EcDp_Contract_Attribute.getAttributeDaytime(p_contract_id, p_contract_year, 'YR');
   ld_start_mth := EcDp_Contract.getContractYearStartDate(p_contract_id, p_contract_year);
   ld_end_mth := EcDp_Contract.getContractYearStartDate(p_contract_id, ADD_MONTHS(p_contract_year, 12));

   -- Only use times within the contract's life period
   SELECT start_date, end_date INTO ld_contract_start, ld_contract_end
   FROM contract
   WHERE object_id = p_contract_id;

   IF ld_start_mth < TRUNC(ld_contract_start, 'mm') THEN
      ld_start_mth := TRUNC(ld_contract_start, 'mm');
   END IF;
   IF ld_end_mth > ADD_MONTHS(TRUNC(ld_contract_end, 'mm'),1) THEN
      IF TRUNC(ld_contract_end, 'mm') = ld_contract_end THEN
         ld_end_mth := ld_contract_end;
      ELSE
         ld_end_mth := ADD_MONTHS(TRUNC(ld_contract_end, 'mm'),1);
      END IF;
   END IF;

   --
   -- Check that we have approved accounts for each month within the period
   --
   ld_mth := ld_start_mth;
   WHILE ld_mth < ld_end_mth LOOP
      li_num_acc := getNumberOfProcessedAccounts(p_contract_id, ld_mth, 'MTH');
      IF li_num_acc = 0 THEN
         RAISE_APPLICATION_ERROR(-20507,'The monthly accounts has not been calculated for '||to_char(ld_mth,'yyyy-mm'));
      END IF;
      IF getNumberOfApprovedAccounts(p_contract_id, ld_mth, 'MTH') < li_num_acc THEN
            RAISE_APPLICATION_ERROR(-20507,'There are unapproved monthly account data for '||to_char(ld_mth,'yyyy-mm'));
      END IF;
      ld_mth := ADD_MONTHS(ld_mth, 1);
   END LOOP;


   --
   -- Update the contract accounts
   --
   FOR r_account IN c_accounts(p_contract_id, ld_daytime) LOOP
      -- Aggregate monthly values
      SELECT SUM(vol_qty), SUM(total_price) INTO ln_qty, ln_price
      FROM cntr_acc_period_status
      WHERE object_id = r_account.object_id
      AND   account_code = r_account.account_code
      AND time_span = 'MTH'
      AND daytime >= ld_start_mth
      AND daytime < ld_end_mth;

      updateAccountStatus(r_account.account_code,r_account.object_id, p_contract_year, 'YR', ln_qty, ln_price, p_username);
   END LOOP;


   -- Update run date
   UPDATE cntr_period_status
   SET run_date = Ecdp_Timestamp.getCurrentSysdate, last_updated_by = p_username
   WHERE object_id = p_contract_id
   AND daytime = p_contract_year
   AND time_span = 'YR';

END processYearlyAccounts;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : approveMonthlyAccounts
-- Description    : Approves the monthly account values and the underlying daily and sub-daily information.
--                  (Daily account values, daily and sub-daily delivery data, daily and sub-daily nomination
--                  data and delivery events within the month).
--
-- Preconditions  : The p_contract_month parameter should be the logical contract month (zero days/hours/minutes/seconds).
--                  Monthly accounts should be processed.
--                  No unapproved events should cross the end-of-month boundary.
-- Postconditions :
--
-- Using tables   : cntr_dp_event
--                  cntr_acc_period_status
--                  contract_account
--                  cntr_day_dp_nom
--                  cntr_sub_day_dp_nom
--                  cntr_day_dp_delivery
--                  cntr_sub_day_dp_delivery
--
-- Using functions: getNumberOfProcessedAccounts
--                  EcDp_Contract.getContractDayStartTime
--                  EcDp_Contract_Attribute.getAttributeDaytime
--
-- Configuration
-- required       :
--
-- Behaviour      : Sets the data status to 'A' for the the account values and underlying data for the
--                  entire contract month.
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveMonthlyAccounts(
  p_contract_id  VARCHAR2,
  p_contract_month     DATE,
  p_username           VARCHAR2,
  p_accessLevel        INTEGER
)
--</EC-DOC>
IS
   ld_daytime              DATE;    -- The daytime to use for looking up values, = contract month start time
   ld_month_start_time     DATE;
   ld_month_end_time       DATE;
   li_tmp                  INTEGER;
   lecd_ProductionDayStart EcDp_Date_Time.EC_unique_daytime;
BEGIN

   --
   -- Check that the accounts have been calculated
   --
   IF getNumberOfProcessedAccounts(p_contract_id,p_contract_month,'MTH') = 0 THEN
      RAISE_APPLICATION_ERROR(-20502,'The accounts must be calculated before they can be approved.');
   END IF;


   lecd_ProductionDayStart := EcDp_ContractDay.getProductionDayStartTime('CONTRACT',p_contract_id,p_contract_month);
   ld_month_start_time := lecd_ProductionDayStart.daytime;

   lecd_ProductionDayStart := EcDp_ContractDay.getProductionDayStartTime('CONTRACT',p_contract_id,ADD_MONTHS(p_contract_month,1));
   ld_month_end_time := lecd_ProductionDayStart.daytime;


   ld_daytime := EcDp_Contract_Attribute.getAttributeDaytime(p_contract_id, p_contract_month, 'MTH');

   --
   -- Check that no unapproved events cross the end-of-month boundary
   --
   SELECT COUNT(*) INTO li_tmp
   FROM cntr_dp_event
   WHERE object_id = p_contract_id
   AND daytime < ld_month_end_time                              -- Starts before this contract month ends
   AND NVL(end_date,ld_month_end_time+1) > ld_month_end_time    -- Ends after this contract month ends
   AND NVL(record_status,'P')<>'A'
   AND event_type = EcDp_Delivery_Event_Type.OFF_SPEC_GAS;

   IF li_tmp > 0 THEN
      RAISE_APPLICATION_ERROR(-20503,'There are unapproved events that start before and end after '||
         to_char(ld_month_end_time,'yyyy-mm-dd hh24:mi'));
   END IF;

   --
   -- Approve the daily and monthly accounts
   --
UPDATE	cntr_acc_period_status
SET		record_status='A',last_updated_by = ecdp_context.getAppUser, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
WHERE 	NVL(record_status,'P')<>'A' AND
		time_span IN ('MTH','DAY') AND
		daytime >= p_contract_month AND
		daytime < ADD_MONTHS(p_contract_month,1) AND
   		(object_id, account_code) IN (
      								SELECT 	ca.object_id, ca.account_code
									FROM 	contract_account ca, contract co
									WHERE 	ca.object_id = co.object_id AND
        									co.object_id = p_contract_id AND
											co.start_date < ADD_MONTHS(ld_daytime,1) AND
											NVL(co.end_date, ld_daytime+1) > ld_daytime
				   					);





   --
   -- Approve the nomination data (daily and sub-daily)
   --
   UPDATE cntr_day_dp_nom
   SET record_status='A',last_updated_by = ecdp_context.getAppUser, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
   WHERE object_id = p_contract_id
   AND daytime >= p_contract_month
   AND daytime < ADD_MONTHS(p_contract_month,1)
   AND NVL(record_status,'P')<>'A';

   UPDATE cntr_sub_day_dp_nom
   SET record_status='A',last_updated_by = ecdp_context.getAppUser, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
   WHERE object_id = p_contract_id
   AND production_day >= p_contract_month
   AND production_day < ADD_MONTHS(p_contract_month,1)
   AND NVL(record_status,'P')<>'A';

   --
   -- Approve the delivery data (daily and sub-daily)
   --
   UPDATE cntr_day_dp_delivery
   SET record_status='A',last_updated_by = ecdp_context.getAppUser, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
   WHERE object_id = p_contract_id
   AND daytime >= p_contract_month
   AND daytime < ADD_MONTHS(p_contract_month,1)
   AND NVL(record_status,'P')<>'A';

   UPDATE cntr_sub_day_dp_delivery
   SET record_status='A',last_updated_by = ecdp_context.getAppUser, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
   WHERE object_id = p_contract_id
   AND production_day >= p_contract_month
   AND production_day < ADD_MONTHS(p_contract_month,1)
   AND NVL(record_status,'P')<>'A';

   --
   -- Approve the events
   --
   UPDATE cntr_dp_event
   SET record_status='A',last_updated_by = ecdp_context.getAppUser, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
   WHERE object_id = p_contract_id
   AND daytime < ld_month_end_time                                -- Starts before this contract month ends
   AND NVL(end_date,ld_month_start_time+1) > ld_month_start_time  -- Ends after this contract month starts
   AND NVL(record_status,'P')<>'A'
   AND event_type = EcDp_Delivery_Event_Type.OFF_SPEC_GAS;

END approveMonthlyAccounts;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : approveYearlyAccounts
-- Description    : Approves the yearly account values.
--
-- Preconditions  : The p_contract_year parameter should be the logical contract year (zero month/day/hour/minutes/seconds).
--                  The monthly account values must be calculated.
-- Postconditions :
--
-- Using tables   : cntr_acc_period_status
--                  contract_account
--					contract
--
-- Using functions: getNumberOfProcessedAccounts
--                  EcDp_Contract.getContractYearStartDate
--
-- Configuration
-- required       :
--
-- Behaviour      : Sets the data status for all yearly account statuses to 'A'.
--                  An exception is thrown if the preconditions are'n met.
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveYearlyAccounts(
   p_contract_id  VARCHAR2,
   p_contract_year      DATE,
   p_username           VARCHAR2,
   p_accessLevel        INTEGER
)
--</EC-DOC>
IS
   ld_year_start        DATE;
BEGIN
	 --
 	 -- Check that the accounts have been calculated
 	 --
  	IF getNumberOfProcessedAccounts(p_contract_id, p_contract_year, 'YR') = 0 THEN
      RAISE_APPLICATION_ERROR(-20502,'The accounts must be calculated before they can be approved.');
   END IF;

   ld_year_start := EcDp_Contract.getContractYearStartDate(p_contract_id, p_contract_year);

   --
   -- Approve the yearly accounts
   --
UPDATE	cntr_acc_period_status
SET		record_status='A',last_updated_by = ecdp_context.getAppUser, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
WHERE 	NVL(record_status,'P')<>'A' AND
		time_span = 'YR' AND
		daytime = p_contract_year AND
   		(object_id, account_code) IN (
      								SELECT 	ca.object_id, ca.account_code
									FROM 	contract_account ca, contract co
									WHERE 	ca.object_id = co.object_id AND
        									co.object_id = p_contract_id AND
											co.start_date < ADD_MONTHS(ld_year_start,12) AND
											NVL(co.end_date, ld_year_start+1) > ld_year_start
				   					);
END approveYearlyAccounts;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNumberOfProcessedAccounts
-- Description    : Returns the number of processed accounts for the given contract, daytime and time span (DAY, MTH or YR).
--
-- Preconditions  : The p_daytime and p_time_span parameters must "match", so if the time span is DAY
--                  then the daytime must be a contract day (no hours/minutes/seconds). Similarly for
--                  MTH and YR timespans.
-- Postconditions :
--
-- Using tables   : cntr_acc_period_status
--                  contract_account
--					contract
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Selects the number of account status records
--
---------------------------------------------------------------------------------------------------
FUNCTION getNumberOfProcessedAccounts(
  p_contract_id  VARCHAR2,
  p_daytime            DATE,
  p_time_span          VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS
   li_cnt   INTEGER;
BEGIN

SELECT 	COUNT(*) INTO li_cnt
FROM 	cntr_acc_period_status
WHERE 	daytime = p_daytime AND
   		time_span = p_time_span AND
   		(object_id, account_code) IN (
      								SELECT 	ca.object_id, ca.account_code
									FROM 	contract_account ca, contract co
									WHERE 	ca.object_id = co.object_id AND
        									co.object_id = p_contract_id AND
											co.start_date <= p_daytime AND
											NVL(co.end_date, p_daytime+1) > p_daytime
				   					);

   RETURN li_cnt;

END getNumberOfProcessedAccounts;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNumberOfApprovedAccounts
-- Description    : Returns the number of approved accounts for the given contract, daytime and time span (DAY, MTH or YR).
--
-- Preconditions  : The p_daytime and p_time_span parameters must "match", so if the time span is DAY
--                  then the daytime must be a contract day (no hours/minutes/seconds). Similarly for
--                  MTH and YR timespans.
-- Postconditions :
--
-- Using tables   : cntr_acc_period_status
--                  contract_account
--					contract
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Selects the number of account status records with data status = 'A'
--
---------------------------------------------------------------------------------------------------
FUNCTION getNumberOfApprovedAccounts(
  p_contract_id  VARCHAR2,
  p_daytime            DATE,
  p_time_span          VARCHAR2
)
RETURN INTEGER
--</EC-DOC>
IS
   li_cnt   INTEGER;
BEGIN

SELECT 	COUNT(*) INTO li_cnt
FROM 	cntr_acc_period_status
WHERE 	daytime = p_daytime AND
   		time_span = p_time_span AND
   		record_status = 'A' AND
   		(object_id, account_code) IN (
      								SELECT 	ca.object_id, ca.account_code
									FROM 	contract_account ca, contract co
									WHERE 	ca.object_id = co.object_id AND
        									co.object_id = p_contract_id AND
											co.start_date <= p_daytime AND
											NVL(co.end_date, p_daytime+1) > p_daytime
				   					);
   RETURN li_cnt;

END getNumberOfApprovedAccounts;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAccountCalcOrder
-- Description    : Returns the calculation order for accounts of a given price concept
--                  Accounts with a low calculation order should be calculated first.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Sales_Acc_Price_Concept.OFF_SPEC_GAS
--                  EcDp_Sales_Acc_Price_Concept.NORMAL_GAS
--                  EcDp_Sales_Acc_Price_Concept.TOTAL_DELIVERED_GAS
--                  EcDp_Sales_Acc_Price_Concept.TAKE_OR_PAY_PENALTY
--                  EcDp_Sales_Acc_Price_Concept.ADJUSTMENT
--                  EcDp_Sales_Acc_Price_Concept.INVOICE_TOTAL
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAccountCalcOrder(
   p_category     VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
   IF p_category = EcDp_Sales_Acc_Price_Concept.OFF_SPEC_GAS THEN
      RETURN 10;
   ELSIF p_category = EcDp_Sales_Acc_Price_Concept.NORMAL_GAS THEN
      RETURN 20;
   ELSIF p_category = EcDp_Sales_Acc_Price_Concept.TOTAL_DELIVERED_GAS THEN
      RETURN 30;
   ELSIF p_category = EcDp_Sales_Acc_Price_Concept.TAKE_OR_PAY_PENALTY THEN
      RETURN 40;
   ELSIF p_category = EcDp_Sales_Acc_Price_Concept.ADJUSTMENT THEN
      RETURN 50;
   ELSIF p_category = EcDp_Sales_Acc_Price_Concept.INVOICE_TOTAL THEN
      RETURN 60;
   ELSE
      RETURN 70;
   END IF;
END getAccountCalcOrder;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isAccountEditable
-- Description    : Returns a boolean flag ('Y' or 'N') indicating whether or not the account is allowed
--                  to be editable in the client.
--
-- Preconditions  : The p_daytime and p_time_span parameters must "match", so if the time span is DAY
--                  then the daytime must be a contract day (no hours/minutes/seconds). Similarly for
--                  MTH and YR timespans.
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Sales_Acc_Price_Concept.ADJUSTMENT
--					Ec_contract_account.price_concept_code
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns 'Y' for monthly accounts of type ADJUSTMENT and 'N' for all other
--                  combinations.
--
---------------------------------------------------------------------------------------------------

FUNCTION isAccountEditable(
	p_object_id		VARCHAR2,
   p_account_code   VARCHAR2,
   p_time_span   	VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

   lv2_retval     VARCHAR2(1);
   lv2_category   VARCHAR2(1000);



BEGIN

   lv2_retval:='N';
   IF p_time_span = 'MTH' THEN


      lv2_category := ec_contract_account.price_concept_code(p_object_id, p_account_code);

      IF lv2_category = EcDp_Sales_Acc_Price_Concept.ADJUSTMENT THEN
         lv2_retval:='Y';
      END IF;
   END IF;
   RETURN lv2_retval;

END isAccountEditable;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : updateAccountStatus
-- Description    : Updates the account status with the new information, or inserts a new row if
--                  none exists for the given account, daytime and time span.
--
-- Preconditions  : The p_daytime and p_time_span parameters must "match", so if the time span is DAY
--                  then the daytime must be a contract day (no hours/minutes/seconds). Similarly for
--                  MTH and YR timespans.
-- Postconditions :
--
-- Using tables   : cntr_acc_period_status
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : First tries an update. If no rows where affected then a new row is inserted.
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateAccountStatus(
	p_account_code		VARCHAR2,
  	p_object_id        VARCHAR2,
  	p_daytime           DATE,
  	p_time_span         VARCHAR2,
  	p_qty               NUMBER,
  	p_total_price       NUMBER,
  	p_username          VARCHAR2
)
--</EC-DOC>
IS
BEGIN

   -- Try an update
   UPDATE 	cntr_acc_period_status
   SET 		vol_qty=p_qty, total_price=p_total_price, last_updated_by=p_username
   WHERE 	account_code = p_account_code AND
   			object_id = p_object_id AND
   			daytime = p_daytime AND
   			time_span = p_time_span;

   -- If no rows updated then do an insert
   IF SQL%ROWCOUNT = 0 THEN
      INSERT INTO cntr_acc_period_status(object_id,account_code,daytime,time_span,vol_qty,total_price,created_by)
      VALUES(p_object_id,p_account_code,p_daytime,p_time_span,p_qty,p_total_price,p_username);
   END IF;


END updateAccountStatus;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getHourlyOffSpecFraction
-- Description    : Finds the fraction of the given contract hour that has off-spec events.
--
-- Preconditions  : The p_daytime parameter should be a logical contract hour (zero minutes/seconds).
-- Postconditions :
--
-- Using tables   : cntr_dp_event
--
-- Using functions: EcDp_Delivery_Event_Type.OFF_SPEC_GAS
--
-- Configuration
-- required       :
--
-- Behaviour      : Truncates event information (in memory, not persisted) as needed to get a set of disjunct
--                  off-spec periods within the given contract hour.
--                  Calculates the fraction of the contract hour for each such off-spec period and aggregates
--                  to get the total fraction.
--
---------------------------------------------------------------------------------------------------
FUNCTION getHourlyOffSpecFraction(
  p_contract_id  VARCHAR2,
  p_delivery_point_id  VARCHAR2,
  p_daytime            DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_off_spec_len      NUMBER;
   ld_last_event_end    DATE;
   ld_start             DATE;
   ld_end               DATE;
   CURSOR c_events IS
      SELECT daytime,end_date FROM cntr_dp_event
      WHERE daytime < (p_daytime+1/24)
      AND NVL(end_date,p_daytime+1) > p_daytime
      AND object_id = p_contract_id
      AND delivery_point_id = p_delivery_point_id
      AND event_type = EcDp_Delivery_Event_Type.OFF_SPEC_GAS
      ORDER BY DAYTIME;
BEGIN
   ln_off_spec_len := 0;
   ld_last_event_end := p_daytime;
   FOR r_event IN c_events LOOP
      -- Remove overlap with previously handled events and limit to the one-hour interval
      IF r_event.DAYTIME >= ld_last_event_end THEN
         ld_start := r_event.daytime;
      ELSE
         ld_start := ld_last_event_end;
      END IF;
      IF r_event.end_date <= p_daytime+1/24 THEN
         ld_end := r_event.end_date;
      ELSE
         ld_end := p_daytime+1/24;
      END IF;
      -- Add the possibly amended duration of this event to the total
      ln_off_spec_len := ln_off_spec_len + (ld_end - ld_start);
      -- Keep track of how much we have covered so far
      ld_last_event_end := ld_end;
   END LOOP;
   RETURN ln_off_spec_len * 24; -- ln_off_spec_len / (1/24)
END getHourlyOffSpecFraction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDailyOffSpecFraction
-- Description    : Finds the fraction of the given contract day that has off-spec events.
--
-- Preconditions  : The p_contract_day parameter should be the logical contract day (zero hours/minutes/seconds).
-- Postconditions :
--
-- Using tables   : cntr_dp_event
--
-- Using functions: EcDp_Delivery_Event_Type.OFF_SPEC_GAS
--                  EcDp_Contract.getContractDayStartTime
--                  EcDp_Contract.getContractDayFraction
--
-- Configuration
-- required       :
--
-- Behaviour      : Truncates event information (in memory, not persisted) as needed to get a set of disjunct
--                  off-spec periods within the given contract day.
--                  Calculates the fraction of the contract day for each such off-spec period and aggregates
--                  to get the total fraction.
--                  The fraction calculations use UTC internally to handle daylight savings time transitions.
--
---------------------------------------------------------------------------------------------------
FUNCTION getDailyOffSpecFraction(
  p_contract_id  VARCHAR2,
  p_delivery_point_id  VARCHAR2,
  p_contract_day       DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_total_frac        NUMBER;
   ld_day_start         DATE;
   ld_day_end           DATE;
   ld_last_event_end    DATE;
   ld_start             DATE;
   ld_end               DATE;
   lc_pday_obj_id_start VARCHAR2(32);
   lc_pday_obj_id_end   VARCHAR2(32);

   CURSOR c_events(p_start DATE,p_end DATE) IS
      SELECT daytime,end_date FROM cntr_dp_event
      WHERE daytime < p_end
      AND NVL(end_date,p_start+1) > p_start
      AND object_id = p_contract_id
      AND delivery_point_id = p_delivery_point_id
      AND event_type = EcDp_Delivery_Event_Type.OFF_SPEC_GAS
      ORDER BY daytime;
BEGIN
   ln_total_frac := 0;
   ld_day_start := EcDp_ContractDay.getProductionDayStart('CONTRACT',p_contract_id,p_contract_day);
   ld_day_end := EcDp_ContractDay.getProductionDayStart('CONTRACT',p_contract_id,p_contract_day+1);
   ld_last_event_end := ld_day_start;
   FOR r_event IN c_events(ld_day_start,ld_day_end) LOOP
      -- Remove overlap with previously handled events
      IF r_event.daytime >= ld_last_event_end THEN
         ld_start := r_event.daytime;
      ELSE
         ld_start := ld_last_event_end;
      END IF;
      IF r_event.end_date <= ld_day_end THEN
         ld_end := r_event.end_date;
      ELSE
         ld_end := ld_day_end;
      END IF;
      -- Add the overlap between this event and the given day to the total
      lc_pday_obj_id_start := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_contract_id, ld_start);
      lc_pday_obj_id_end := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_contract_id, ld_end);
      ln_total_frac := ln_total_frac + EcDp_ContractDay.getProductionDayFraction('CONTRACT',p_contract_id,p_contract_day,ld_start, ecdp_date_time.summertime_flag(ld_start, NULL, lc_pday_obj_id_start),ld_end,ecdp_date_time.summertime_flag(ld_end, NULL, lc_pday_obj_id_end));
      -- Keep track of how much we have covered so far
      ld_last_event_end := ld_end;
   END LOOP;
   RETURN ln_total_frac;
END getDailyOffSpecFraction;

END EcDp_Sales_Accounting;