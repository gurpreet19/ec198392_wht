CREATE OR REPLACE PACKAGE BODY EcDp_Cost IS
/****************************************************************
** Package        :  EcDp_Cost, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Support functionality for Cost of Service etc.
**
** Documentation  :  www.energy-components.com
**
** Created  : 31.08.2010  Stian Skj�restad
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
*****************************************************************/



--<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : InstantiateMth
  -- Description    : Instantiates cost_asset_cos
  -- Preconditions  :
  -- Postconditions :
  -- Using tables   :
  -- Using functions:
  -- Configuration
  -- required       :
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE InstantiateMth(p_object_id VARCHAR2,
                         p_daytime   DATE,
                         p_user      VARCHAR2)
--<EC-DOC>
IS

BEGIN
    InstantiateYear(p_object_id,p_daytime,p_user);

    BEGIN
        INSERT INTO cost_asset_cos
            (object_id, daytime, period, created_by)
        VALUES
            (p_object_id, TRUNC(p_daytime, 'MM'), 'MTH', p_user);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL;
    END;

END InstantiateMth;


--<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : InstantiateYear
  -- Description    :
  -- Preconditions  :
  -- Postconditions :
  -- Using tables   :
  -- Using functions:
  -- Configuration
  -- required       :
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE InstantiateYear(p_object_id VARCHAR2,
                         p_daytime   DATE,
                         p_user      VARCHAR2)
--<EC-DOC>
IS

BEGIN
    BEGIN
        INSERT INTO cost_asset_cos
            (object_id, daytime, period, created_by)
        VALUES
            (p_object_id, TRUNC(p_daytime, 'YYYY'), 'YEAR', p_user);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL;
   END;
END InstantiateYear;


--<EC-DOC>
  ---------------------------------------------------------------------------------------------------
-- Procedure      : SetCostofServiceCost
-- Description    : Saves values back to the Summary
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE SetCostofServiceCost(
                    p_trans_inv_id VARCHAR2,
                    p_daytime DATE,
                    p_capital_charge     NUMBER,
                    p_operating_charge   NUMBER,
                    p_return_on_capital  NUMBER
                    )
--<EC-DOC>
IS

    ln_ret_val  NUMBER;
    lv2_doc_key VARCHAR2(32);

    CURSOR c_tiv(cp_trans_inv_id VARCHAR2, cp_daytime DATE) IS
      SELECT tips.OBJECT_ID contract_id, tiv.summary_setup_id
        FROM TRANS_INV_PROD_STREAM tips,
             TRANS_INVENTORY_VERSION tiv
       WHERE tiv.object_id = cp_trans_inv_id
         AND tips.inventory_id = cp_trans_inv_id
         AND cp_daytime >= tiv.daytime
         AND cp_daytime < nvl(tiv.end_date, cp_daytime + 1)
         AND cp_daytime >= tips.daytime
         AND cp_daytime < nvl(tips.end_date, cp_daytime + 1);

BEGIN
    -- First get the transaction document key, then use the key
    -- to find the matching journal summary value, which also should
    -- be approved and have tag = 'CAPITAL_ADDITIONS'
    FOR rsRCC IN c_tiv(p_trans_inv_id, p_daytime) LOOP

        lv2_doc_key := Ecdp_Rr_Revn_Summary.GetLastAppSummaryDoc(rsRCC.contract_id,
                                                               rsRCC.summary_setup_id,
                                                               p_daytime,
                                                               p_trans_inv_id);
      --  RAISE_APPLICATION_ERROR(-20001,lv2_doc_key);
            UPDATE cont_journal_summary
             set actual_amount = p_capital_charge,
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 last_updated_by = 'cos_calculation'
            where tag = 'CAPITAL_CHARGE_CALC'
             AND record_status = 'A'
             AND document_key = lv2_doc_key
             AND actual_amount != p_capital_charge;

            UPDATE cont_journal_summary set actual_amount = p_operating_charge,
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 last_updated_by = 'cos_calculation'
            where tag = 'OPERATING_CHARGE_CALC'
             AND record_status = 'A'
             AND document_key = lv2_doc_key
             AND actual_amount != p_operating_charge;

            UPDATE cont_journal_summary set actual_amount = p_return_on_capital,
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 last_updated_by = 'cos_calculation'
            where tag = 'RETURN_ON_CAPITAL'
             AND record_status = 'A'
             AND document_key = lv2_doc_key
             AND actual_amount != p_return_on_capital;

    END LOOP;


END SetCostofServiceCost;
  -- Procedure      : CalculateMth
  -- Description    : Calculates all values for cost of service columns
  -- Preconditions  :
  -- Postconditions :
  -- Using tables   :
  -- Using functions:
  -- Configuration
  -- required       :
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE CalculateMth(p_object_id VARCHAR2,
                       p_daytime   DATE,
                       p_user      VARCHAR2)
--<EC-DOC>
IS

    ln_capital_cost               NUMBER;
    ln_starting_balance           NUMBER;
    ln_ending_balance             NUMBER;
    ln_straight_line_depr         NUMBER;
    ln_return_on_capital          NUMBER;
    ln_capital_charge             NUMBER;
    ln_capital_charge_pr_unit     NUMBER;
    ln_operating_charge           NUMBER;
    ln_operating_charge_pr_unit   NUMBER;
    ln_cos_pr_unit                NUMBER;
    ln_addition                   NUMBER := 0;
    ln_capital_cost_depr          NUMBER; -- Captial cost for depreciation (Cumulative?)
    ln_total_additions            NUMBER; -- Total addition cost for prior months
    ln_operating_charge_additions NUMBER; -- Addition costs that goes to Operating Charge
    ln_throughput                 NUMBER;
    lb_reached_requirement        BOOLEAN := FALSE; -- Indicates if addition cost reached the threshold factor.
    lrec_trans_inventory          trans_inventory_version%ROWTYPE;
    ln_adjustment_amount          NUMBER;
    lv2_required_action           VARCHAR2(10);
    ln_previous_value             NUMBER; -- The previously calculated value of monthly COS for the given month
    lv2_addition_method           VARCHAR2(32);
    ln_prior_year_count           NUMBER;
    lb_new_insert                 BOOLEAN := FALSE;
    ld_january                    DATE; -- Date of january of current year
    ld_december                   DATE; -- Date of december of current year
    ld_prev_mth                   DATE; -- Date of previous month
    ln_prev_mth_rcc               NUMBER; -- Running capital cost of previous month
    ln_current_rcc                NUMBER; -- Current running captial cost

    CURSOR c_prior_year(cp_daytime DATE) IS
    SELECT daytime
      FROM system_month
     WHERE TRUNC(daytime,'yyyy') = trunc(cp_daytime - 365,'yyyy');

  BEGIN

    -- Get the dates
    ld_january           := trunc(p_daytime, 'yyyy');
    ld_december          := trunc(ld_january - 360, 'MM');
    ld_prev_mth          := add_months(p_daytime, -1);

    -- Get inventory for the given date
    lrec_trans_inventory := ec_trans_inventory_version.row_by_pk(p_object_id,p_daytime,'<=');

    -- get the previously calculated total (capital+operationg) before calculating to know
    -- what to state as the recommended action
    -- The value is Monthly COS
    ln_previous_value := ec_cost_asset_cos.capital_charge(p_object_id,p_daytime,'MTH','=')
                         +
                         ec_cost_asset_cos.operating_charge(p_object_id,p_daytime,'MTH','=');


    -- loop through each month in the current year up until the previous month
    -- and finds out the total additions for the current year (less current month)
    FOR prev_mth IN 1 .. to_number(to_char(p_daytime, 'mm')) - 1 LOOP
      ln_total_additions := ln_total_additions
                            +
                            nvl(ec_cost_asset_cos.addition(p_object_id,ld_prev_mth,'MTH', '='),0);
    END LOOP;

    -- Checks to see if threshold was reached in prior month
    lv2_required_action := getrequiredaction(p_daytime, p_object_id,nvl(ln_total_additions,0));

    -- Instantiation is done if required
    instantiatemth(p_object_id, p_daytime, p_user);

    -- Gets the running captial cost for current and previous month
    ln_prev_mth_rcc := nvl(getrunningcapitalcost(p_object_id, ld_prev_mth),0);
    ln_current_rcc := getrunningcapitalcost(p_object_id, p_daytime);

    -- gets current month additions
    IF ln_prev_mth_rcc <> 0 AND ln_current_rcc IS NOT NULL THEN
       ln_addition := ln_current_rcc - ln_prev_mth_rcc;
    END IF;

    ln_total_additions := ln_total_additions + ln_addition;

    -- Capital cost uses the running capital cost from the prior month
    ln_capital_cost    := ln_prev_mth_rcc;

    -- This will set the opening balance and depreciation running capital to the additions
    -- when very first entry
    -- BUG: ln_capital_cost will always equals to ln_prev_mth_rcc, should the ln_capital_cost be ln_current_rcc?
    --      ln_prev_mth_rcc = 0 should be removed since it might be value from last year December
    IF NVL(ln_total_additions,0) = 0 AND ln_capital_cost > 0 AND ln_prev_mth_rcc = 0 THEN
      ln_capital_cost_depr := ln_capital_cost;
      lb_new_insert        := TRUE;
    END IF;

    -- Set the january balance (depreciation) (find out if should set the deprecation running capital to normal rcc).
    IF lb_new_insert = FALSE AND to_number(to_char(p_daytime, 'mm')) = 1 THEN

      -- Get if previous year's captial cost for depreciation > 0
      SELECT COUNT(*)
        INTO ln_prior_year_count
        FROM cost_asset_cos cac
       WHERE nvl(cac.capital_cost_depr, 0) <> 0
         AND object_id = p_object_id
         AND trunc(daytime, 'YYYY') = trunc(p_daytime - 1, 'YYYY');

      -- Must get prior year additions if depreciation method was NOT used in the prior year.
      -- it must be added to the depreciation running capital in the current
      -- Also if there is no data in the prior year must set depreciation for running capital.
      IF ln_prior_year_count = 0 OR
        getadditionmethod(ld_December, p_object_id) = 'Depreciation' THEN

        ln_total_additions := 0;

        -- Get total addition costs in prior year
        FOR prev_mth IN c_prior_year(p_daytime) LOOP
                  ln_total_additions := ln_total_additions
                                        +
                                        nvl(ec_cost_asset_cos.addition(p_object_id,prev_mth.daytime,'MTH','='),0);
        END LOOP;


        -- Get Running Captial Cost for Depreciation from DEC last year + total additions from last year
        ln_capital_cost_depr := nvl(ec_cost_asset_cos.capital_cost_depr(p_object_id,
                                                                        add_months(trunc(p_daytime, 'yyyy'), -1), 'MTH', '='), 0)
                                +
                                ln_total_additions;

        ln_total_additions   := 0;
      ELSE

        ln_capital_cost_depr := nvl(ec_cost_asset_cos.capital_cost_depr(p_object_id,ld_prev_mth,'MTH','='),0);

      END IF;
    END IF;


    lv2_addition_method := getadditionmethod(p_daytime, p_object_id, ln_total_additions);
    IF lv2_addition_method = 'Depreciation' THEN
      lb_reached_requirement := TRUE;
    ELSE
      lb_reached_requirement := FALSE;
    END IF;

    -- If current year does fullfill requirement threshold
    -- then use deprecition method otherwise use operating
    -- Set the depreciation for current month if it is not January, and check if the
    -- addition cost should go to operation charge (Operation method)
    IF lb_reached_requirement = TRUE THEN
      -- **** The Depreciation Method

      -- Get the depreciation for current month (if it is Jan, it alreaedy
      -- been handled above)
      -- If not January, pull cummulative for depreciation
      IF to_number(to_char(p_daytime, 'mm')) <> 1 THEN
        -- Get Captial Cost for Depreciation from prior month.
        ln_capital_cost_depr := nvl(ec_cost_asset_cos.capital_cost_depr(p_object_id, ld_prev_mth, 'MTH', '='), 0);

      END IF;

      -- additions should not go into the operation charges
      ln_operating_charge_additions := 0;

    ELSE
      -- **** The Operation Method

      -- Additions should be added to operating costs
      ln_operating_charge_additions := ln_addition;

      -- when operating method use the deprecation rcc from the prior month
      -- when it is not january (january may need to include additions in prior year)
      -- and has already been handled

      IF to_number(to_char(p_daytime, 'mm')) <> 1 THEN
         ln_capital_cost_depr := nvl(ec_cost_asset_cos.capital_cost_depr(p_object_id,ld_prev_mth,'MTH','=') ,0) ;
      END IF;
    END IF;

    -- if very first occurance set depreciation to cost
    IF ln_capital_cost_depr = 0 THEN

      ln_capital_cost_depr := nvl(ln_capital_cost, 0);

    END IF;


    -- Calculate other stuff
    ln_starting_balance := nvl(ec_cost_asset_cos.ending_balance(p_object_id,ld_prev_mth,'MTH','='),0) ;

    --set starting balance for first occurance

    IF ln_starting_balance = 0 AND ln_capital_cost_depr > 0 THEN

      ln_starting_balance := ln_capital_cost_depr;

    ELSE

      ln_starting_balance := ln_starting_balance +
                              ec_cost_asset_cos.addition(p_object_id,ld_prev_mth,'MTH','=');
    END IF;

    ln_straight_line_depr := (nvl(ln_capital_cost_depr, 0) *
                             nvl(lrec_trans_inventory.depreciation, 0)) / 12;

    ln_ending_balance := ln_starting_balance - ln_straight_line_depr;

    ln_return_on_capital := to_number(getreturnoncapital(p_object_id, p_daytime, ln_starting_balance, ln_ending_balance,'MTH'));

    ln_capital_charge   := nvl(ln_straight_line_depr, 0)
                           +
                         nvl(ln_return_on_capital, 0);

    -- operating change may include additions if operating method is used
    ln_operating_charge := getoperatingcharge(p_object_id, p_daytime, 'MTH')
                           +
                           ln_operating_charge_additions;

    ln_throughput := ue_rr_revn_mapping.getthroughput(p_object_id, p_daytime);

    IF ln_throughput <> 0 THEN

      ln_operating_charge_pr_unit := ln_operating_charge / ln_throughput;
      ln_capital_charge_pr_unit   := ln_capital_charge / ln_throughput;

    ELSE

      ln_operating_charge_pr_unit := 0;
      ln_capital_charge_pr_unit   := 0;

    END IF;

    ln_cos_pr_unit := nvl(ln_capital_charge_pr_unit, 0) +
                      nvl(ln_operating_charge_pr_unit, 0);


    UPDATE cost_asset_cos c
       SET c.capital_cost                = ln_capital_cost,
           c.starting_balance            = ln_starting_balance,
           c.straight_line_depcreciation = ln_straight_line_depr,
           c.ending_balance              = ln_ending_balance,
           c.return_of_capital           = ln_return_on_capital,
           c.capital_charge              = ln_capital_charge,
           c.capital_charge_per_unit     = ln_capital_charge_pr_unit,
           c.operating_charge            = ln_operating_charge,
           c.operating_charge_per_unit   = ln_operating_charge_pr_unit,
           c.cos_per_unit                = ln_cos_pr_unit,
           c.last_updated_by             = p_user,
           c.addition                    = ln_addition,
           c.capital_cost_depr           = ln_capital_cost_depr,
           c.addition_method             = lv2_addition_method,
           c.last_value_change           = decode(nvl(ln_previous_value,
                                                      ln_capital_charge +
                                                      ln_operating_charge),
                                                  ln_capital_charge +
                                                  ln_operating_charge,
                                                  c.last_value_change,
                                                  Ecdp_Timestamp.getCurrentSysdate)
     WHERE object_id = p_object_id
       AND daytime = p_daytime
       AND period = 'MTH';

       SetCostofServiceCost(p_object_id,p_daytime,ln_capital_charge,ln_operating_charge,ln_return_on_capital);

END CalculateMth;

--<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : CalculateYear
  -- Description    :
  -- Prec           onditions  :
  -- Postconditions :
  -- Using tables   :
  -- Using functions:
  -- Configuration
  -- required       :
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE CalculateYear(p_object_id VARCHAR2,
                       p_daytime   DATE,
                       p_user      VARCHAR2)
--<EC-DOC>

   IS
    ln_capital_cost             NUMBER;
    ln_starting_balance         NUMBER;
    ln_ending_balance           NUMBER;
    ln_straight_line_depr       NUMBER;
    ln_return_on_capital        NUMBER;
    ln_capital_charge           NUMBER;
    ln_capital_charge_pr_unit   NUMBER;
    ln_operating_charge         NUMBER;
    ln_operating_charge_pr_unit NUMBER;
    ln_cos_pr_unit              NUMBER;
    ln_capital_cost_depr        NUMBER;
    ln_throughput               NUMBER;
    lrec_trans_inventory        trans_inventory_version%ROWTYPE;
    ld_mth                      DATE;
    ln_addition                 NUMBER;

    CURSOR c_months(cp_daytime DATE) IS
      SELECT daytime
        FROM system_month
       WHERE daytime = trunc(daytime, 'mm')
         AND trunc(daytime, 'yyyy') = trunc(cp_daytime);

  BEGIN
    -- Instantiation is done if required
    instantiateyear(p_object_id, p_daytime, p_user);

    lrec_trans_inventory := ec_trans_inventory_version.row_by_pk(p_object_id,p_daytime,'<=');

    -- Recalculate all months within this year
    ld_mth := p_daytime;

    WHILE trunc(ld_mth, 'YYYY') < add_months(p_daytime, 12) LOOP

      calculatemth(p_object_id, ld_mth, p_user);
      ld_mth := add_months(ld_mth, 1);

    END LOOP;


    FOR cc_month IN c_months(p_daytime) LOOP

      IF ln_starting_balance IS NULL OR ln_starting_balance = 0 THEN
         ln_starting_balance  := ec_cost_asset_cos.starting_balance(p_object_id,cc_month.daytime,'MTH','<=');
      END IF;


      ln_capital_cost       := nvl(ec_cost_asset_cos.capital_cost(p_object_id,cc_month.daytime,'MTH', '='),
                             ln_capital_cost);

      ln_capital_cost_depr  := nvl(ec_cost_asset_cos.capital_cost_depr(p_object_id,cc_month.daytime,'MTH', '='),
                             ln_capital_cost_depr);

      ln_straight_line_depr := nvl(ln_straight_line_depr,0) +
                               nvl(ec_cost_asset_cos.straight_line_depcreciation(p_object_id,cc_month.daytime, 'MTH','='),
                                   0);

      ln_ending_balance     := nvl(ec_cost_asset_cos.ending_balance(p_object_id, cc_month.daytime,'MTH', '='),
                                  ln_ending_balance);

      ln_return_on_capital := nvl(ln_return_on_capital,0) +
                               nvl(ec_cost_asset_cos.return_of_capital(p_object_id, cc_month.daytime, 'MTH', '='),
                                  0);


      ln_capital_charge := nvl(ln_capital_charge,0) +
                               nvl(ec_cost_asset_cos.capital_charge(p_object_id,cc_month.daytime,'MTH','='),
                               ln_capital_charge);

      ln_operating_charge :=nvl( ln_operating_charge,0) +
                               nvl(ec_cost_asset_cos.operating_charge(p_object_id,cc_month.daytime,'MTH','='),
                                 ln_operating_charge);

      ln_addition := nvl(ln_addition,0) +
                               nvl(ec_cost_asset_cos.addition(p_object_id,cc_month.daytime,'MTH','='),
                                 ln_operating_charge);
    END LOOP;

    ln_throughput := ue_rr_revn_mapping.getthroughput(p_object_id,p_daytime,'YEAR');

    IF ln_throughput <> 0 THEN
      ln_operating_charge_pr_unit := ln_operating_charge / ln_throughput;
      ln_capital_charge_pr_unit   := ln_capital_charge / ln_throughput;
    ELSE
      ln_operating_charge_pr_unit := 0;
      ln_capital_charge_pr_unit   := 0;
    END IF;

    ln_cos_pr_unit := nvl(ln_capital_charge_pr_unit, 0) +
                      nvl(ln_operating_charge_pr_unit, 0);

    UPDATE cost_asset_cos c
       SET c.capital_cost                = ln_capital_cost,
           c.starting_balance            = ln_starting_balance,
           c.straight_line_depcreciation = ln_straight_line_depr,
           c.ending_balance              = ln_ending_balance,
           c.return_of_capital           = ln_return_on_capital,
           c.capital_charge              = ln_capital_charge,
           c.capital_charge_per_unit     = ln_capital_charge_pr_unit,
           c.operating_charge            = ln_operating_charge,
           c.operating_charge_per_unit   = ln_operating_charge_pr_unit,
           c.cos_per_unit                = ln_cos_pr_unit,
           c.last_updated_by             = p_user,
           c.capital_cost_depr           = ln_capital_cost_depr,
           c.addition                    = ln_addition
     WHERE object_id = p_object_id
       AND daytime = p_daytime
       AND period = 'YEAR';

END CalculateYear;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetRunningCapitalCost
-- Description    : Gets the running capital cost off of the approved summary for the month on the inventory.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetRunningCapitalCost(
                    p_trans_inv_id VARCHAR2,
                    p_daytime DATE)
RETURN NUMBER
--<EC-DOC>
IS

    ln_ret_val  NUMBER;
    lv2_doc_key VARCHAR2(32);

    CURSOR c_tiv(cp_trans_inv_id VARCHAR2, cp_daytime DATE) IS
      SELECT tips.object_id contract_id, tiv.summary_setup_id
        FROM trans_inventory_version tiv,
             trans_inv_prod_stream tips
       WHERE tiv.object_id = cp_trans_inv_id
         AND cp_daytime >= tiv.daytime
         AND tips.inventory_id = tiv.object_id
         AND cp_daytime < nvl(tiv.end_date, cp_daytime + 1)
         and cp_daytime >= tips.daytime
         AND cp_daytime < nvl(tips.end_date, cp_daytime + 1);

    CURSOR c_cjs(cp_doc_key VARCHAR2) IS
      SELECT cjs.actual_amount
        FROM cont_journal_summary cjs
       WHERE cjs.document_key = cp_doc_key
         AND cjs.tag = 'CAPITAL_ADDITIONS'
         AND record_status = 'A';

BEGIN

    -- First get the transaction document key, then use the key
    -- to find the matching journal summary value, which also should
    -- be approved and have tag = 'CAPITAL_ADDITIONS'
    FOR rsRCC IN c_tiv(p_trans_inv_id, p_daytime) LOOP
        lv2_doc_key := Ecdp_Rr_Revn_Summary.GetLastAppSummaryDoc(rsRCC.contract_id,
                                                               rsRCC.summary_setup_id,
                                                               p_daytime,
                                                               p_trans_inv_id);
        FOR rsCJS IN c_cjs(lv2_doc_key) LOOP
            ln_ret_val := rsCJS.actual_amount;
        END LOOP;
    END LOOP;

    RETURN ln_ret_val;

END GetRunningCapitalCost;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetOperatingCharge
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetOperatingCharge(p_trans_inv_id VARCHAR2,
                    p_daytime      DATE,
                    p_period       VARCHAR2) RETURN NUMBER
--<EC-DOC>
IS

    ln_ret_val  NUMBER;
    lv2_doc_key VARCHAR2(32);

    CURSOR c_tiv(cp_trans_inv_id VARCHAR2, cp_daytime DATE) IS
      SELECT tips.object_id contract_id, tiv.summary_setup_id
        FROM trans_inventory_version tiv,
             trans_inv_prod_stream tips
       WHERE tiv.object_id = cp_trans_inv_id
         AND cp_daytime >= tiv.daytime
         AND tips.inventory_id = tiv.object_id
         AND cp_daytime < nvl(tiv.end_date, cp_daytime + 1)
         and cp_daytime >= tips.daytime
         AND cp_daytime < nvl(tips.end_date, cp_daytime + 1);

    CURSOR c_cjs(cp_doc_key VARCHAR2) IS
      SELECT cjs.actual_amount
        FROM cont_journal_summary cjs
       WHERE cjs.document_key = cp_doc_key
         AND cjs.tag = 'OPERATING_CHARGE'
         AND record_status = 'A';

    CURSOR c_months(cp_daytime DATE, cp_period VARCHAR2) IS
     SELECT distinct daytime
        FROM system_mth_status
       WHERE trunc(daytime, decode(cp_period, 'YEAR', 'YYYY', 'MM')) =
             cp_daytime
         AND trunc(daytime, 'MM') = daytime
       ORDER BY daytime;

BEGIN
    ln_ret_val := 0;
    FOR rsdates IN c_months(p_daytime, p_period) LOOP
        FOR rsrcc IN c_tiv(p_trans_inv_id, rsdates.daytime) LOOP
            lv2_doc_key := ecdp_rr_revn_summary.getlastappsummarydoc(rsrcc.contract_id,
                                                                     rsrcc.summary_setup_id,
                                                                     rsdates.daytime,
                                                                     p_trans_inv_id);

            FOR rscjs IN c_cjs(lv2_doc_key) LOOP
              ln_ret_val := ln_ret_val + rscjs.actual_amount;
            END LOOP;
        END LOOP;
    END LOOP;

    RETURN ln_ret_val;

END GetOperatingCharge;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetReturnOnCapital
-- Description    : Calculates the Return on Capital using the price indexes.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetReturnOnCapital(p_trans_inv_id VARCHAR2,
                    p_daytime DATE,
                    p_starting_balance NUMBER DEFAULT NULL,
                    p_ending_balance NUMBER DEFAULT NULL,
                    p_period           VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--<EC-DOC>
IS

    lrec_tiv               trans_inventory_version%ROWTYPE := ec_trans_inventory_version.row_by_pk(p_trans_inv_id,
                                                                                                   p_daytime,
                                                                                                   '<=');
    ln_ret_val             NUMBER;
    ln_debt_factor         NUMBER; -- TODO: Get non-static value
    ln_equity_factor       NUMBER; -- TODO: Get non-static value
    ln_long_term_bond_rate NUMBER; -- Long Term Bond Rate - Monthly
    ln_corp_tax_rate       NUMBER; -- Corporate Tax Rate - Yearly
    ln_neb_equity_rate     NUMBER; -- National Energy Board Equity Rate - Yearly
    ln_month_value         NUMBER;
    ln_static_debt_adj     NUMBER;
    ln_static_equity_adj   NUMBER;

    ld_daytime DATE;

    CURSOR c_months(cp_daytime DATE) IS
      SELECT daytime
        FROM system_days
       WHERE trunc(daytime, 'YYYY') = trunc(cp_daytime, 'YYYY')
         AND trunc(daytime, 'MM') = daytime
       ORDER BY daytime;

  BEGIN

    IF p_period = 'MTH' THEN
      ld_daytime := p_daytime;
      -- Get rate from price index
      ln_long_term_bond_rate := ec_price_in_item_value.index_value(lrec_tiv.long_term_bond_rate_id,
                                                                 ld_daytime,'PRICE_INDEX_MTH_VALUE',
                                                                 '<=') / 100;

      ln_debt_factor       := nvl(ec_price_in_item_value.index_value(ec_price_input_item.object_id_by_uk('DEBT_FACTOR','PRICE_INDEX'),
                                                                   ld_daytime,'PRICE_INDEX_MTH_VALUE',
                                                                 '<='),.45);
      ln_equity_factor     := nvl(ec_price_in_item_value.index_value(ec_price_input_item.object_id_by_uk('EQUITY_FACTOR','PRICE_INDEX'),
                                                                   ld_daytime,'PRICE_INDEX_MTH_VALUE',
                                                                 '<='),.55);
      ln_static_debt_adj   := nvl(ec_price_in_item_value.index_value(ec_price_input_item.object_id_by_uk('STATIC_DEBT_ADJ','PRICE_INDEX'),
                                                                   ld_daytime,'PRICE_INDEX_MTH_VALUE',
                                                                 '<='),0.01);
      ln_static_equity_adj := nvl(ec_price_in_item_value.index_value(ec_price_input_item.object_id_by_uk('STATIC_EQUITY_ADJ','PRICE_INDEX'),
                                                                   ld_daytime,'PRICE_INDEX_MTH_VALUE',
                                                                 '<='),0.03);

      ln_month_value := ((p_starting_balance + p_ending_balance) / 2);

      IF lrec_tiv.cost_asset_type IN ('BASIC', 'NON_BASIC_SERVICE') THEN

        ln_ret_val := ln_month_value * ln_long_term_bond_rate;

      ELSIF lrec_tiv.cost_asset_type = 'NON_BASIC_PIPELINE' THEN

        ln_corp_tax_rate := ec_price_in_item_value.index_value(lrec_tiv.corporate_tax_rate_id,
                                                             ld_daytime,
                                                             'PRICE_INDEX_MTH_VALUE',
                                                             '<=') / 100;

        IF ln_debt_factor IS NOT NULL AND
           ln_long_term_bond_rate IS NOT NULL AND
           ln_equity_factor IS NOT NULL AND ln_corp_tax_rate IS NOT NULL THEN

          -- 45% x (LTBR +1) + 55% x (NEB Equity rate)/(1-Corporate Tax Rate)
          ln_ret_val := ln_month_value *
                        ((ln_debt_factor *
                        (ln_long_term_bond_rate + ln_static_debt_adj)) +
                        (ln_equity_factor *
                        (ln_long_term_bond_rate + ln_static_equity_adj) /
                        (1 - ln_corp_tax_rate))) / 12;
        END IF;

      END IF;

    ELSE
      ln_ret_val := 0;
      FOR ld_month IN c_months(p_daytime) LOOP
        ln_ret_val := ln_ret_val + nvl(ec_cost_asset_cos.return_of_capital(p_trans_inv_id,
                                                                           ld_month.daytime,
                                                                           'MTH',
                                                                           '='),
                                       0);
      END LOOP;
    END IF;

    RETURN ln_ret_val;

END GetReturnOnCapital;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetAdditionMethod
-- Description    : This figures out if required threshhold is reached and returns the Depreciation method to use
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Operation Method: When the total additions for the year has not reached the threshold
--                  factor (either the January opening balance or the first balance value in the year,
--                  times the system attribute COST_ADDITION_PERCENTAGE which has a default value of 10%).
--                  This method will have the running capital cost constant and the Monthly Operation charge
--                  will include the additions for the month. The additions will be included in the opening
--                  balance in the next year.
--
--                  Depreciation Method: When the additions have reached the threshold during the year then
--                  the additions will be added to the Depreciation Running Capital Cost and will be depreciated
--                  in the current year in the straight line depreciation. (The additions will not be part of
--                  the operating charges).
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetAdditionMethod(p_daytime   DATE,
                         p_object_id VARCHAR2,
                         p_ytd_value NUMBER DEFAULT NULL) --the value to date for the year so far
RETURN VARCHAR2
--<EC-DOC>
IS
lv2_status         VARCHAR2(32);
ln_total_additions NUMBER := 0;

BEGIN

-- if ytd value has been sent it only take values in the current year after the given month
IF p_ytd_value IS NOT NULL THEN
  SELECT SUM(nvl(cac.addition, 0)) + nvl(p_ytd_value, 0)
    INTO ln_total_additions
    FROM cost_asset_cos cac
   WHERE cac.object_id = p_object_id
     AND cac.period = 'MTH'
     AND trunc(daytime, 'yyyy') = trunc(p_daytime, 'yyyy')
     AND trunc(daytime, 'mm') > trunc(p_daytime, 'mm');
ELSE
  -- get the total for the year
  SELECT SUM(nvl(cac.addition, 0))
    INTO ln_total_additions
    FROM cost_asset_cos cac
   WHERE cac.object_id = p_object_id
     AND cac.period = 'MTH'
     AND trunc(daytime, 'yyyy') = trunc(p_daytime, 'yyyy');
END IF;


-- If the total additions during the year have reached the threshold,
-- use depreciatoin; if not use Operating method.
 IF ln_total_additions >= GetYearThreshold(p_daytime, p_object_id) THEN
  lv2_status := 'Depreciation';
ELSE
  lv2_status := 'Operating';
END IF;

RETURN lv2_status;
END GetAdditionMethod;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetYearThreshold
-- Description    : Gets the threshold value for addition cost for the year.
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetYearThreshold(p_daytime DATE, p_object_id VARCHAR2)
    RETURN NUMBER
--<EC-DOC>
IS
    ln_starting        NUMBER;
BEGIN
    -- get january capital_cost
    ln_starting := nvl(ec_cost_asset_cos.capital_cost(p_object_id,trunc(p_daytime,'yyyy'),'MTH','='),0);

    -- If there was no january cost get the first value that was not 0
    IF ln_starting = 0 THEN
      SELECT MAX(capital_cost)
        INTO ln_starting
        FROM cost_asset_cos
       WHERE period = 'MTH'
         AND object_id = p_object_id
         AND daytime = (SELECT MIN(daytime)
                          FROM cost_asset_cos
                         WHERE period = 'MTH'
                           AND object_id = p_object_id
                           AND nvl(capital_cost, 0) <> 0);
    END IF;

    -- the threshold is default 10% of starting value for the year
    RETURN ln_starting * NVL(ec_ctrl_system_attribute.attribute_value(p_daytime,'COST_ADDITION_PERCENTAGE','<='),0.1);
END GetYearThreshold;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetRequiredAction
-- Description    : Check to see if the stored method (previously ran) matches the method that should not be used.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION GetRequiredAction(p_daytime   DATE,
                         p_object_id VARCHAR2,
                         p_ytd_value NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
lv2_status VARCHAR2(10);
BEGIN

-- Sees if the previous runs method is different than the current.
-- Since the values depend on the addition method, so if they are different
-- then the values should be updated.
IF nvl(ec_cost_asset_cos.addition_method(p_object_id, p_daytime, 'MTH', '='),'Operating') <>
   getadditionmethod(p_daytime, p_object_id, p_ytd_value) THEN
  lv2_status := 'Update';
END IF;

RETURN lv2_status;
END GetRequiredAction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetRequiredActionYR
-- Description    : Check to see if the stored method (previously ran) matches the method that should not be used.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION GetRequiredActionYR(p_daytime   DATE,
                         p_object_id VARCHAR2,
                         p_ytd_value NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
lv2_status VARCHAR2(10);

    CURSOR c_months(cp_daytime DATE) IS
  SELECT daytime
    FROM system_days
   WHERE trunc(daytime, 'YYYY') = trunc(cp_daytime, 'YYYY')
     AND trunc(daytime, 'MM') = daytime
   ORDER BY daytime;

BEGIN

-- Loop thought each month to see if there is any month
-- needs to be updated, if so, set the required action
-- of the year to "update".
FOR mths IN c_months(p_daytime) LOOP
  IF nvl(ec_cost_asset_cos.addition_method(p_object_id, mths.daytime, 'MTH', '='), 'Operating') <>
     getadditionmethod(p_daytime, p_object_id, p_ytd_value) THEN
     lv2_status := 'Update';
     EXIT;
  END IF;
END LOOP;
RETURN lv2_status;

END GetRequiredActionYR;

END EcDp_Cost;