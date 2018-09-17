CREATE OR REPLACE PACKAGE BODY EcDp_Contract_Inventory IS
    /******************************************************************************
    ** Package        :  ecdp_contract_invetory, body part
    **
    ** $Revision: 1.13 $
    **
    ** Purpose        :  Find and work with delivery data
    **
    ** Documentation  :  www.energy-components.com
    **
    ** Created        :  17.02.2011 Kenneth Masamba
    **
    ** Modification history:
    **
    ** Date        Whom         Change description:
    ** ------      -----        -----------------------------------------------------------------------------------------------
    ** 17.02.2011  masamken     Initial version (Update inventory level)
	** 31.07.2012  sharawan     ECPD-19482: Add new function getAllocQty for GD.0047 : Monthly OBA Status screen
	** 31.07.2012  muhammah		ECPD-19482: Monthly OBA Status screen - Added new functions getAccumulatedBalDay and getAccumulatedBalMth
	** 30.08.2012  masamken		ECPD-21446: Created new function checkOperBalTrans
	** 26.09.2013  leeeewei		ECPD-24392: Added procedure checkTransSign
    ********************************************************************/

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : aggregateTransactions
    -- Description    : Retrieve sums of debit and credit quantity from daily contract location transactions
    --                  and aggregates all transaction for selected inventory and write a new closing inventory qty for the day
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : cntr_day_loc_inv_trans
    --                  cntr_day_loc_inventory
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      : Finds the sum of all debit and credit quantity in cntr_day_loc_inv_trans and aggregates
    --                  all transactions to inventory quantities for the given day. The new closing inventory
    --                  quantity is written to cntr_day_loc_inventory
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE aggregateDebitTransactions(p_object_id      VARCHAR2,
                                         p_daytime        DATE,
                                         p_debit_qty      NUMBER,
                                         p_credit_qty     NUMBER,
                                         p_old_debit_qty  NUMBER,
                                         p_old_credit_qty NUMBER)
    --</EC-DOC>
     IS
        ln_opening_inv_balance  NUMBER := 0;
        ln_new_closing_balance  NUMBER := 0;
        ln_old_closing_balance  NUMBER := 0;
        ln_tempo_debit_qty      NUMBER := 0;
        ln_tempo_credit_qty     NUMBER := 0;
        ln_tempo_old_debit_qty  NUMBER := 0;
        ln_tempo_old_credit_qty NUMBER := 0;
        ln_debit_counter        NUMBER := 0;
        ln_credit_counter       NUMBER := 0;

        CURSOR c_inv_qty IS
            SELECT inventory_qty
              INTO ln_opening_inv_balance
              FROM cntr_day_loc_inventory
             WHERE object_id = p_object_id
               AND daytime = p_daytime;

    BEGIN

        -- retrieving the current inventroy closing balance
        FOR curInvQty IN c_inv_qty LOOP
            ln_old_closing_balance := curInvQty.inventory_qty;
        END LOOP;
        IF ln_old_closing_balance IS NULL THEN
            ln_old_closing_balance := 0;
        END IF;
        --calculating the new closing balance in respect to the debit adjustments
        IF p_debit_qty IS NULL THEN
            ln_tempo_old_debit_qty := p_old_debit_qty;
            IF p_old_debit_qty IS NULL THEN
                ln_tempo_old_debit_qty := 0;
            END IF;
            ln_new_closing_balance := ln_old_closing_balance - ln_tempo_old_debit_qty;
            ln_debit_counter       := ln_debit_counter + 1;
        ELSE
            ln_tempo_debit_qty := p_debit_qty - p_old_debit_qty;
            IF p_old_debit_qty IS NULL THEN
                ln_tempo_debit_qty := p_debit_qty;
            END IF;
            ln_new_closing_balance := ln_old_closing_balance + ln_tempo_debit_qty;
            ln_debit_counter       := ln_debit_counter + 1;
        END IF;

        IF ln_debit_counter = 1 THEN
            UPDATE cntr_day_loc_inventory
               SET inventory_qty = ln_new_closing_balance, last_updated_by = ecdp_context.getAppUser
             WHERE object_id = p_object_id
               AND daytime = p_daytime;
        END IF;

    END aggregateDebitTransactions;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : aggregateTransactions
    -- Description    : Retrieve sums of debit and credit quantity from daily contract location transactions
    --                  and aggregates all transaction for selected inventory and write a new closing inventory qty for the day
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : cntr_day_loc_inv_trans
    --                  cntr_day_loc_inventory
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      : Finds the sum of all debit and credit quantity in cntr_day_loc_inv_trans and aggregates
    --                  all transactions to inventory quantities for the given day. The new closing inventory
    --                  quantity is written to cntr_day_loc_inventory
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE aggregateCreditTransactions(p_object_id      VARCHAR2,
                                          p_daytime        DATE,
                                          p_debit_qty      NUMBER,
                                          p_credit_qty     NUMBER,
                                          p_old_debit_qty  NUMBER,
                                          p_old_credit_qty NUMBER)
    --</EC-DOC>
     IS
        ln_opening_inv_balance  NUMBER := 0;
        ln_new_closing_balance  NUMBER := 0;
        ln_old_closing_balance  NUMBER := 0;
        ln_tempo_debit_qty      NUMBER := 0;
        ln_tempo_credit_qty     NUMBER := 0;
        ln_tempo_old_debit_qty  NUMBER := 0;
        ln_tempo_old_credit_qty NUMBER := 0;
        ln_debit_counter        NUMBER := 0;
        ln_credit_counter       NUMBER := 0;

        CURSOR c_inv_qty IS
            SELECT inventory_qty
              INTO ln_opening_inv_balance
              FROM cntr_day_loc_inventory
             WHERE object_id = p_object_id
               AND daytime = p_daytime;

    BEGIN

        -- retrieving the current inventroy closing balance
        FOR curInvQty IN c_inv_qty LOOP
            ln_old_closing_balance := curInvQty.inventory_qty;
        END LOOP;

        IF ln_old_closing_balance IS NULL THEN
            ln_old_closing_balance := 0;
        END IF;

        --calculating the new closing balance in respect to the credit adjustments
        IF p_credit_qty IS NULL THEN
            ln_tempo_old_credit_qty := p_old_credit_qty;
            IF p_old_credit_qty IS NULL THEN
                ln_tempo_old_credit_qty := 0;
            END IF;
            ln_new_closing_balance := ln_old_closing_balance + ln_tempo_old_credit_qty;
            ln_credit_counter      := ln_credit_counter + 1;
        ELSE
            ln_tempo_credit_qty := p_credit_qty - p_old_credit_qty;
            IF p_old_credit_qty IS NULL THEN
                ln_tempo_credit_qty := p_credit_qty;
            END IF;
            ln_new_closing_balance := ln_old_closing_balance - ln_tempo_credit_qty;
            ln_credit_counter      := ln_credit_counter + 1;
        END IF;

        IF ln_credit_counter = 1 THEN
            UPDATE cntr_day_loc_inventory
               SET inventory_qty = ln_new_closing_balance, last_updated_by = ecdp_context.getAppUser
             WHERE object_id = p_object_id
               AND daytime = p_daytime;

        END IF;

    END aggregateCreditTransactions;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : aggregateTransactions
    -- Description    : Retrieve sums of debit and credit quantity from daily contract location transactions
    --                  and aggregates all transaction for selected inventory and write a new closing inventory qty for the day
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : cntr_day_loc_inv_trans
    --                  cntr_day_loc_inventory
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      : Finds the sum of all debit and credit quantity in cntr_day_loc_inv_trans and aggregates
    --                  all transactions to inventory quantities for the given day. The new closing inventory
    --                  quantity is written to cntr_day_loc_inventory
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE aggregateDeletedDebitTrans(p_object_id      VARCHAR2,
                                         p_daytime        DATE,
                                         p_debit_qty      NUMBER,
                                         p_credit_qty     NUMBER,
                                         p_old_debit_qty  NUMBER,
                                         p_old_credit_qty NUMBER)
    --</EC-DOC>
     IS
        ln_opening_inv_balance  NUMBER := 0;
        ln_new_closing_balance  NUMBER := 0;
        ln_old_closing_balance  NUMBER := 0;
        ln_tempo_debit_qty      NUMBER := 0;
        ln_tempo_credit_qty     NUMBER := 0;
        ln_tempo_old_debit_qty  NUMBER := 0;
        ln_tempo_old_credit_qty NUMBER := 0;
        ln_debit_counter        NUMBER := 0;
        ln_credit_counter       NUMBER := 0;

        CURSOR c_inv_qty IS
            SELECT inventory_qty
              INTO ln_opening_inv_balance
              FROM cntr_day_loc_inventory
             WHERE object_id = p_object_id
               AND daytime = p_daytime;

    BEGIN

        -- retrieving the current inventroy closing balance
        FOR curInvQty IN c_inv_qty LOOP
            ln_old_closing_balance := curInvQty.inventory_qty;
        END LOOP;

        --calculating the new closing balance in respect to the credit adjustments
        IF p_old_debit_qty IS NULL THEN
            ln_tempo_old_debit_qty := 0;
            ln_new_closing_balance := ln_old_closing_balance + ln_tempo_old_debit_qty;
            ln_debit_counter       := ln_debit_counter + 1;
        ELSE
            ln_tempo_debit_qty     := p_old_debit_qty;
            ln_new_closing_balance := ln_old_closing_balance - ln_tempo_debit_qty;
            ln_debit_counter       := ln_debit_counter + 1;
        END IF;

        IF ln_debit_counter = 1 THEN
            UPDATE cntr_day_loc_inventory
               SET inventory_qty = ln_new_closing_balance, last_updated_by = ecdp_context.getAppUser
             WHERE object_id = p_object_id
               AND daytime = p_daytime;

        END IF;

    END aggregateDeletedDebitTrans;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : aggregateTransactions
    -- Description    : Retrieve sums of debit and credit quantity from daily contract location transactions
    --                  and aggregates all transaction for selected inventory and write a new closing inventory qty for the day
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : cntr_day_loc_inv_trans
    --                  cntr_day_loc_inventory
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      : Finds the sum of all debit and credit quantity in cntr_day_loc_inv_trans and aggregates
    --                  all transactions to inventory quantities for the given day. The new closing inventory
    --                  quantity is written to cntr_day_loc_inventory
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE aggregateDeletedCreditTrans(p_object_id      VARCHAR2,
                                          p_daytime        DATE,
                                          p_debit_qty      NUMBER,
                                          p_credit_qty     NUMBER,
                                          p_old_debit_qty  NUMBER,
                                          p_old_credit_qty NUMBER)
    --</EC-DOC>
     IS
        ln_opening_inv_balance  NUMBER := 0;
        ln_new_closing_balance  NUMBER := 0;
        ln_old_closing_balance  NUMBER := 0;
        ln_tempo_debit_qty      NUMBER := 0;
        ln_tempo_credit_qty     NUMBER := 0;
        ln_tempo_old_debit_qty  NUMBER := 0;
        ln_tempo_old_credit_qty NUMBER := 0;
        ln_debit_counter        NUMBER := 0;
        ln_credit_counter       NUMBER := 0;

        CURSOR c_inv_qty IS
            SELECT inventory_qty
              INTO ln_opening_inv_balance
              FROM cntr_day_loc_inventory
             WHERE object_id = p_object_id
               AND daytime = p_daytime;

    BEGIN

        -- retrieving the current inventroy closing balance
        FOR curInvQty IN c_inv_qty LOOP
            ln_old_closing_balance := curInvQty.inventory_qty;
        END LOOP;

        --calculating the new closing balance in respect to the credit adjustments
        IF p_old_credit_qty IS NULL THEN
            ln_tempo_old_credit_qty := 0;
            ln_new_closing_balance  := ln_old_closing_balance + ln_tempo_old_credit_qty;
            ln_credit_counter       := ln_credit_counter + 1;
        ELSE
            ln_tempo_credit_qty    := p_old_credit_qty;
            ln_new_closing_balance := ln_old_closing_balance + ln_tempo_credit_qty;
            ln_credit_counter      := ln_credit_counter + 1;
        END IF;

        IF ln_credit_counter = 1 THEN
            UPDATE cntr_day_loc_inventory
               SET inventory_qty = ln_new_closing_balance, last_updated_by = ecdp_context.getAppUser
             WHERE object_id = p_object_id
               AND daytime = p_daytime;

        END IF;

    END aggregateDeletedCreditTrans;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : addSwapTransactions
    -- Description    :
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : cntr_day_loc_inv_trans
    --                  cntr_day_loc_inventory
    --                  cntr_day_inv_swap
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE addSwapTransactions(p_swap_seq       NUMBER,
                                  p_class_name     VARCHAR2,
                                  p_sender_id      VARCHAR2,
                                  p_daytime        DATE,
                                  p_receiver_id    VARCHAR2,
                                  p_swap_qty       NUMBER)

        --</EC-DOC>
     IS

        ln_inventory_giver   NUMBER := 0;
        ln_inven_trans_giver NUMBER := 0;
        ln_inventory_rec     NUMBER := 0;
        lv2_inventory_status VARCHAR2(30) := 'PROVISIONAL';

    BEGIN

        IF p_class_name = 'CNTR_DAY_INV_SWAP' THEN
            --Crediting inventory

            select count(*)
              into ln_inventory_rec
              from cntr_day_loc_inventory
             WHERE object_id = p_sender_id
               AND daytime = p_daytime;

            IF ln_inventory_rec = 0 THEN
                INSERT INTO CNTR_DAY_LOC_INVENTORY
                    (object_id, daytime, status, created_by)
                VALUES
                    (p_sender_id, p_daytime, lv2_inventory_status, ecdp_context.getAppUser);
            END IF;

            INSERT INTO CNTR_DAY_LOC_INV_TRANS --DV_CNTR_DAY_LOC_INV_TRANS
                (object_id, daytime, credit_qty, transaction_type, event_reference, created_by)
            VALUES
                (p_sender_id, p_daytime, p_swap_qty, 'SWAP', 'SWAP_' || p_swap_seq, ecdp_context.getAppUser);

            aggregateCreditTransactions(p_sender_id, p_daytime, null, p_swap_qty, null, null);

            --Debiting inventory
            select count(*)
              into ln_inventory_rec
              from cntr_day_loc_inventory
             WHERE object_id = p_receiver_id
               AND daytime = p_daytime;

            IF ln_inventory_rec = 0 THEN
                INSERT INTO CNTR_DAY_LOC_INVENTORY
                    (object_id, daytime, status, created_by)
                VALUES
                    (p_receiver_id, p_daytime, lv2_inventory_status, ecdp_context.getAppUser);
            END IF;

            INSERT INTO CNTR_DAY_LOC_INV_TRANS --DV_CNTR_DAY_LOC_INV_TRANS
                (object_id, daytime, debit_qty, transaction_type, event_reference, created_by)
            VALUES
                (p_receiver_id, p_daytime, p_swap_qty, 'SWAP', 'SWAP_' || p_swap_seq, ecdp_context.getAppUser);

            aggregateDebitTransactions(p_receiver_id, p_daytime, p_swap_qty, null, null, null);
        END IF;

        IF p_class_name = 'CNTR_DAY_INV_CNTR_SWAP' THEN
            --Crediting inventory
            select count(*)
              into ln_inventory_rec
              from cntr_day_loc_inventory
             WHERE object_id = p_sender_id
               AND daytime = p_daytime;

            IF ln_inventory_rec = 0 THEN
                INSERT INTO CNTR_DAY_LOC_INVENTORY
                    (object_id, daytime, status, created_by)
                VALUES
                    (p_sender_id, p_daytime, lv2_inventory_status, ecdp_context.getAppUser);
            END IF;

            INSERT INTO CNTR_DAY_LOC_INV_TRANS --DV_CNTR_DAY_LOC_INV_TRANS
                (object_id, daytime, credit_qty, transaction_type, event_reference, created_by)
            VALUES
                (p_sender_id, p_daytime, p_swap_qty, 'SWAP', 'SWAP_' || p_swap_seq, ecdp_context.getAppUser);

            aggregateCreditTransactions(p_sender_id, p_daytime, null, p_swap_qty, null, null);

            --Debiting inventory
            select count(*)
              into ln_inventory_rec
              from cntr_day_loc_inventory
             WHERE object_id = p_receiver_id
               AND daytime = p_daytime;

            IF ln_inventory_rec = 0 THEN
                INSERT INTO CNTR_DAY_LOC_INVENTORY
                    (object_id, daytime, status, created_by)
                VALUES
                    (p_receiver_id, p_daytime, lv2_inventory_status, ecdp_context.getAppUser);
            END IF;

            INSERT INTO CNTR_DAY_LOC_INV_TRANS --DV_CNTR_DAY_LOC_INV_TRANS
                (object_id, daytime, debit_qty, transaction_type, event_reference, created_by)
            VALUES
                (p_receiver_id, p_daytime, p_swap_qty, 'SWAP', 'SWAP_' || p_swap_seq, ecdp_context.getAppUser);

            aggregateDebitTransactions(p_receiver_id, p_daytime, p_swap_qty, null, null, null);
        END IF;

        IF p_class_name = 'CNTR_DAY_INV_LOC_SWAP' THEN
            --Crediting inventory
            select count(*)
              into ln_inventory_rec
              from cntr_day_loc_inventory
             WHERE object_id = p_sender_id
               AND daytime = p_daytime;

            IF ln_inventory_rec = 0 THEN
                INSERT INTO CNTR_DAY_LOC_INVENTORY
                    (object_id, daytime, status, created_by)
                VALUES
                    (p_sender_id, p_daytime, lv2_inventory_status, ecdp_context.getAppUser);
            END IF;

            INSERT INTO CNTR_DAY_LOC_INV_TRANS --DV_CNTR_DAY_LOC_INV_TRANS
                (object_id, daytime, credit_qty, transaction_type, event_reference, created_by)
            VALUES
                (p_sender_id, p_daytime, p_swap_qty, 'SWAP', 'SWAP_' || p_swap_seq, ecdp_context.getAppUser);

            aggregateCreditTransactions(p_sender_id, p_daytime, null, p_swap_qty, null, null);

            --Debiting inventory
            select count(*)
              into ln_inventory_rec
              from cntr_day_loc_inventory
             WHERE object_id = p_receiver_id
               AND daytime = p_daytime;

            IF ln_inventory_rec = 0 THEN
                INSERT INTO CNTR_DAY_LOC_INVENTORY
                    (object_id, daytime, status, created_by)
                VALUES
                    (p_receiver_id, p_daytime, lv2_inventory_status, ecdp_context.getAppUser);
            END IF;

            INSERT INTO CNTR_DAY_LOC_INV_TRANS --DV_CNTR_DAY_LOC_INV_TRANS
                (object_id, daytime, debit_qty, transaction_type, event_reference, created_by)
            VALUES
                (p_receiver_id, p_daytime, p_swap_qty, 'SWAP', 'SWAP_' || p_swap_seq, ecdp_context.getAppUser);

            aggregateDebitTransactions(p_receiver_id, p_daytime, p_swap_qty, null, null, null);

        END IF;

    END addSwapTransactions;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAllocQty
-- Description    : Can be used to get Daily and Monthly data by supplying the time span of DAY or MTH
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cntr_day_loc_inv_trans
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAllocQty(
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_time_span VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
    ln_alloc_qty  NUMBER;
    ld_from_date       DATE;
    ld_to_date         DATE;

    CURSOR c_alloc_qty (cp_object_id VARCHAR2, cp_from_date DATE, cp_to_date DATE) IS
    SELECT (SUM(nvl(DEBIT_QTY, 0)) - SUM(nvl(CREDIT_QTY, 0))) ALLOC_QTY
    FROM cntr_day_loc_inv_trans
    WHERE object_id = p_object_id
    AND daytime >= cp_from_date
    AND daytime < cp_to_date
    AND transaction_type = 'OPER_IMB';

BEGIN

    IF p_time_span IN ('MTH', 'mth') THEN
       ld_from_date := TRUNC(p_daytime, 'MM');
       ld_to_date   := ADD_MONTHS(ld_from_date, 1);
    ELSIF p_time_span IN ('DAY', 'day') THEN
       ld_from_date := p_daytime;
       ld_to_date   := p_daytime + 1;
    END IF;

    FOR curAllocQty IN c_alloc_qty (p_object_id, ld_from_date, ld_to_date) LOOP
		    ln_alloc_qty := curAllocQty.ALLOC_QTY;
    END LOOP;

    IF ln_alloc_qty =0 THEN
       return null;
    else
       return ln_alloc_qty;
    END IF;

END getAllocQty;

--<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       : getAccumulatedBalDay
    -- Description    :The function gets accumulated balance for any date, when getting monthly
    --                 accumulated value remember to get end of that month. This function will be
    --                 used for monthly and daily section.
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : CNTR_DAY_LOC_INV_TRANS
    --                  CNTR_INV_MTH_BAL
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
  FUNCTION getAccumulatedBalDay(p_object_id VARCHAR2,
                                p_daytime DATE)
    RETURN NUMBER
  --</EC-DOC>
   IS
    CURSOR c_inv_qty IS
      SELECT sum(t.debit_qty) debit, sum(t.credit_qty) credit
        FROM CNTR_DAY_LOC_INV_TRANS t
       WHERE object_id = p_object_id
         AND daytime <= p_daytime;

    CURSOR c_mth_inv_qty (cp_start_of_mth date) IS
      SELECT sum(m.debit_qty) debit, sum(m.credit_qty) credit
        FROM CNTR_INV_MTH_BAL m
       WHERE object_id = p_object_id
         AND daytime <= cp_start_of_mth;

    ln_day_closing_balance NUMBER := 0;
    ln_mth_closing_balance NUMBER := 0;
    ln_closing_balance     NUMBER := 0;
    ld_start_of_mnth       DATE;
    ld_end_of_mnth         DATE;

  BEGIN

    -- getting daily clossing inventory
    FOR curInvQty IN c_inv_qty LOOP
      ln_day_closing_balance := NVL(curInvQty.debit,0) - NVL(curInvQty.credit,0);
    END LOOP;

    --getting monthly clossing inventory
    ld_start_of_mnth := TRUNC(p_daytime, 'MM');           --get start of the month of p_daytime
    ld_end_of_mnth := LAST_DAY(p_daytime);                --get end of month of month of p_daytime

    IF p_daytime = ld_end_of_mnth THEN
       FOR curInvQty IN c_mth_inv_qty(ld_start_of_mnth) LOOP
         ln_mth_closing_balance := NVL(curInvQty.debit, 0) - NVL(curInvQty.credit, 0);
       END LOOP;
    END IF;

  ln_closing_balance := ln_day_closing_balance + ln_mth_closing_balance;

  return ln_closing_balance;

  END getAccumulatedBalDay;

  --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       :  getAccumulatedBalMth
    -- Description    : This funtion will call getAccumulatedBalDay and pass the last day of the month.
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
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
  FUNCTION getAccumulatedBalMth(p_object_id VARCHAR2, p_daytime DATE)
    RETURN NUMBER
  --</EC-DOC>
  IS

    ld_end_of_mnth  DATE;
	  ln_bal_day			NUMBER;

  BEGIN

    ld_end_of_mnth := LAST_DAY(p_daytime);     --get end of month of month of p_daytime
	  ln_bal_day := getAccumulatedBalDay(p_object_id, ld_end_of_mnth);

  return ln_bal_day;

  END  getAccumulatedBalMth;

  --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       :  checkOperBalTrans
    -- Description    : This funtion will prevent inserting operational balance more than once in the inventory transaction table..
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   :cntr_day_loc_inv_trans
    --
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
  PROCEDURE checkOperBalTrans(p_object_id      VARCHAR2,
                        p_daytime        DATE,
						p_transaction_type VARCHAR2)
     IS
        numOfOperImbToday NUMBER;

    BEGIN

        select count(*)
        into numOfOperImbToday
        from cntr_day_loc_inv_trans
        where daytime = p_daytime
        and   object_id = p_object_id
        and   transaction_type = 'OPER_IMB';

        IF numOfOperImbToday>0 AND p_transaction_type = 'OPER_IMB' THEN
          Raise_Application_Error(-20572,'Not allowed to have more than one operational imbalance record for an inventory transaction in a day.');
        END IF;

    END checkOperBalTrans;

  --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Function       :  checkTransSign
    -- Description    : This prodecure checks if there are negative debit and credit quantities inserted into Daily Contract Inventory Matrix.
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
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
  PROCEDURE checkTransSign(p_debit       NUMBER,
                           p_credit      NUMBER) IS

  BEGIN

    IF p_debit < 0 OR p_credit < 0 THEN
      Raise_Application_Error(-20578,
                              'Not allowed to enter negative transaction.');
    END IF;

    IF p_debit IS NULL OR p_credit IS NULL THEN
      Raise_Application_Error(-20579,
                              'Not allowed to enter NULL transaction value.');
    END IF;

  END checkTransSign;

END EcDp_Contract_Inventory;