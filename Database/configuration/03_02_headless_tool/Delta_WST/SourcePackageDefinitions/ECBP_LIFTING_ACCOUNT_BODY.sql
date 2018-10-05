CREATE OR REPLACE PACKAGE BODY EcBp_Lifting_Account IS
  /**************************************************************************************************
  ** Package  :  EcBp_Lifting_Account
  **
  ** $Revision: 1.12 $
  **
  ** Purpose  :  Business logic for lifting account
  **
  **
  **
  ** General Logic:
  **
  ** Created:     02.11.2004 Kari Sandvik
  **
  ** Modification history:
  **
  ** Date:       Whom: Rev.  Change description:
  ** ----------  ----- ----  ------------------------------------------------------------------------
  ** 28.06.2007  ismaiime   1. procedure validateAccount : remove cursor to select contract_id from lifting_account
  **                    2. function getLiftingAccountCntr : add lifting_account_version table in the cursor
  ** 22.05.2010  lauuufus   Add procedure checkIfConnectionOverlaps
  ** 30.12.2011  farhaann   Added validateLiftingAccountSplit
  ** 12.12.2013  muhammah   ECPD-8558 : Added cursor c_validate_contract to procedure validateAccount
  **************************************************************************************************/

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getLiftingAccountCpyPc
  -- Description    : This functions return the lifting account for a storage , profit centre and a lifter
  -- Preconditions  :
  -- Postconditions : Uncommited changes
  --
  -- Using tables   : lifting_account
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION getLiftingAccountCpyPc(p_storage_id       VARCHAR2,
                                  p_company_id       VARCHAR2,
                                  p_profit_centre_id VARCHAR2,
                                  p_daytime          DATE) RETURN VARCHAR2
  --</EC-DOC>
   IS

    CURSOR c_account(cp_storage_id       VARCHAR2,
                     cp_company_id       VARCHAR2,
                     cp_profit_centre_id VARCHAR2,
                     cp_daytime          DATE) IS
      SELECT object_id
        FROM lifting_account
       WHERE company_id = cp_company_id
         AND storage_id = cp_storage_id
         AND profit_centre_id IS NOT NULL
         AND profit_centre_id = cp_profit_centre_id
         AND start_date <= cp_daytime
         AND (end_date >= cp_daytime OR end_date IS NULL)
       GROUP BY object_id;

    lv_liftAccId VARCHAR2(32);
    ln_count     NUMBER := 0;

  BEGIN

    FOR curAccount IN c_account(p_storage_id,
                                p_company_id,
                                p_profit_centre_id,
                                p_daytime) LOOP
      ln_count     := ln_count + 1;
      lv_liftAccId := curAccount.object_id;
    END LOOP;

    RETURN lv_liftAccId;
  END getLiftingAccountCpyPc;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getLiftingAccountCpy
  -- Description    : This functions return the lifting account for a storage and a lifter
  --                  It will return an error if more than one account is configured for a storage and company
  -- Preconditions  :
  -- Postconditions : Uncommited changes
  --
  -- Using tables   : lifting_account
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION getLiftingAccountCpy(p_storage_id VARCHAR2,
                                p_company_id VARCHAR2,
                                p_daytime    DATE) RETURN VARCHAR2
  --</EC-DOC>
   IS

    CURSOR c_account(cp_storage_id VARCHAR2,
                     cp_company_id VARCHAR2,
                     cp_daytime    DATE) IS
      SELECT object_id
        FROM lifting_account
       WHERE company_id = cp_company_id
         AND storage_id = cp_storage_id
         AND start_date <= cp_daytime
         AND (end_date >= cp_daytime OR end_date IS NULL)
       GROUP BY object_id;

    lv_liftAccId VARCHAR2(32);
    ln_count     NUMBER := 0;

  BEGIN

    FOR curAccount IN c_account(p_storage_id, p_company_id, p_daytime) LOOP
      ln_count     := ln_count + 1;
      lv_liftAccId := curAccount.object_id;
    END LOOP;

    IF ln_count > 1 THEN
      Raise_Application_Error(-20308,
                              'More than one lifting account for storage and company');
    END IF;

    RETURN lv_liftAccId;
  END getLiftingAccountCpy;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : getLiftingAccountCntr
  -- Description    : This functions return the lifting account for a contract
  --                  It will return an error if more than one account is configured for a storage and contract
  --
  -- Preconditions  :
  -- Postconditions : Uncommited changes
  --
  -- Using tables   : lifting_account
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION getLiftingAccountCntr(p_storage_id  VARCHAR2,
                                 p_contract_id VARCHAR2,
                                 p_daytime     DATE) RETURN VARCHAR2
  --</EC-DOC>
   IS

    CURSOR c_account(cp_storage_id  VARCHAR2,
                     cp_contract_id VARCHAR2,
                     cp_daytime     DATE) IS
      SELECT a.object_id
        FROM lifting_account a, lift_account_version av
       WHERE a.object_id = av.object_id
         AND a.storage_id = cp_storage_id
         AND av.contract_id = cp_contract_id
         AND a.start_date <= cp_daytime
         AND (a.end_date >= cp_daytime OR a.end_date IS NULL)
       GROUP BY a.object_id;

    lv_liftAccId VARCHAR2(32);
    ln_count     NUMBER := 0;

  BEGIN

    FOR curAccount IN c_account(p_storage_id, p_contract_id, p_daytime) LOOP
      ln_count     := ln_count + 1;
      lv_liftAccId := curAccount.object_id;
    END LOOP;

    IF ln_count > 1 THEN
      Raise_Application_Error(-20328,
                              'There is already a lifting account for this contract and storage');
    END IF;

    RETURN lv_liftAccId;
  END getLiftingAccountCntr;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : validateAccount
  -- Description    :
  -- Preconditions  :
  -- Postconditions : Uncommitted changes
  --
  -- Using tables   : lifting_account
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE validateAccount(p_object_id        VARCHAR2,
                            p_storage_id       VARCHAR2,
                            p_company_id       VARCHAR2,
                            p_profit_centre_id VARCHAR2,
                            p_contract_id      VARCHAR2,
                            p_validate_ind     CHAR)
  --</EC-DOC>
   IS

    CURSOR c_validate1(cp_object_id        VARCHAR2,
                       cp_storage_id       VARCHAR2,
                       cp_company_id       VARCHAR2,
                       cp_profit_centre_id VARCHAR2) IS
      SELECT profit_centre_id
        FROM lifting_account
       WHERE company_id = cp_company_id
         AND storage_id = cp_storage_id
         AND Nvl(profit_centre_id, cp_profit_centre_id) =
             cp_profit_centre_id
         AND object_id <> cp_object_id;

    CURSOR c_validate2(cp_object_id  VARCHAR2,
                       cp_storage_id VARCHAR2,
                       cp_company_id VARCHAR2) IS
      SELECT profit_centre_id
        FROM lifting_account
       WHERE company_id = cp_company_id
         AND storage_id = cp_storage_id
         AND object_id <> cp_object_id;

    CURSOR c_validate_contract(cp_object_id   VARCHAR2,
                               cp_storage_id  VARCHAR2,
                               cp_company_id  VARCHAR2,
                               cp_contract_id VARCHAR2) IS
      SELECT av.contract_id
        FROM lifting_account a, lift_account_version av
       WHERE a.object_id = av.object_id
         AND a.storage_id = cp_storage_id
         AND a.company_id = cp_company_id
         AND av.contract_id = cp_contract_id
         AND a.object_id <> cp_object_id;

  BEGIN

    IF p_company_id IS NULL THEN
      Raise_Application_Error(-20329,
                              'A lifting account must have a company');
    END IF;

    IF p_contract_id IS NOT NULL THEN
      IF p_validate_ind = 'Y' THEN
        FOR curVal IN c_validate_contract(p_object_id,
                                          p_storage_id,
                                          p_company_id,
                                          p_contract_id) LOOP
          Raise_Application_Error(-20338,
                                  'The account for this combination of Storage, Lifter(Company) and Contract already exist');
          EXIT;
        END LOOP;
      ELSE
        NULL;
      END IF;
    ELSE
      IF p_profit_centre_id IS NULL THEN
        FOR curVal IN c_validate2(p_object_id, p_storage_id, p_company_id) LOOP
          Raise_Application_Error(-20308,
                                  'Not allowed to have more than one account for a Storage, Lifter (Company) and Profit Centre');
          EXIT;
        END LOOP;
      ELSE
        FOR curVal IN c_validate1(p_object_id,
                                  p_storage_id,
                                  p_company_id,
                                  p_profit_centre_id) LOOP
          Raise_Application_Error(-20308,
                                  'Not allowed to have more than one account for a Storage, Lifter (Company) and Profit Centre');
          EXIT;
        END LOOP;
      END IF;
    END IF;

  END validateAccount;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      :checkIfConnectionOverlaps
  -- Description    : Checks if overlapping connection exists.
  --
  --
  -- Preconditions  :
  -- Postconditions : Raises an application error if overlapping connection exists.
  --
  -- Using tables   : CNTR_LIFT_ACC_CONN
  --
  --
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behavior       :
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE checkIfConnectionOverlaps(p_object_id   VARCHAR2,
                                      p_lift_acc_id VARCHAR2,
                                      p_daytime     DATE,
                                      p_end_date    DATE)
  --</EC-DOC>
   IS
    -- overlapping period can't exist in lifting account connection
    CURSOR c_lift_acc_conn IS
      SELECT *
        FROM CNTR_LIFT_ACC_CONN lac
       WHERE lac.object_id = p_object_id
         AND lac.lift_acc_id = p_lift_acc_id
         AND lac.daytime <> p_daytime
         AND (lac.end_date > p_daytime OR lac.end_date IS NULL)
         AND (lac.daytime < p_end_date OR p_end_date IS NULL);

    lv_message VARCHAR2(4000);

  BEGIN

    lv_message := null;

    FOR cur_lift_acc_conn IN c_lift_acc_conn LOOP
      lv_message := lv_message || cur_lift_acc_conn.object_id || ' ';
    END LOOP;

    IF lv_message is not null THEN
      RAISE_APPLICATION_ERROR(-20336,
                              'An lifting account connection must not overlap with existing connection period.');
    END IF;

  END checkIfConnectionOverlaps;

  ---------------------------------------------------------------------------------------------------
  -- Procedure      : validateLiftingAccountSplit
  -- Description    :
  --
  -- Preconditions  :
  -- Postcondition  :
  -- Using Tables   : cntr_lift_acc_share
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behavior       : The function are validating the sum of account_share. The sum have to be 100, otherwise a message error will be prompted
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE validateLiftingAccountSplit(p_object_id VARCHAR2,
                                        p_daytime   DATE) IS
    ln_count         NUMBER;
    ln_account_share NUMBER;

    CURSOR c_account_share IS
      SELECT account_share
        FROM cntr_lift_acc_share
       WHERE object_id = p_object_id
         AND daytime = p_daytime;

  BEGIN
    ln_account_share := 0;
    ln_count         := 0;

    FOR sumAccountShare IN c_account_share LOOP
      ln_count         := ln_count + 1;
      ln_account_share := ln_account_share +
                          ROUND(Nvl(sumAccountShare.account_share, 0), 9);
    END LOOP;

    IF ln_account_share <> 1 AND ln_count <> 0 THEN
      RAISE_APPLICATION_ERROR(-20326, 'The sum of equity has to be 100');
    END IF;

  END validateLiftingAccountSplit;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure       : populateSubDailyValueAdj
  -- Description    : Update production_day and summer time value.
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : lift_account_adjustment
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      : Update production_day and summer_time value.
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE populateSubDailyValueAdj(p_object_id VARCHAR2, p_daytime DATE)
  --</EC-DOC>
   IS
    lv_pday_object_id VARCHAR2(32);
    lv_summer_time    VARCHAR2(1);
    ld_production_day date;

  BEGIN
    lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL,
                                                                        p_object_id,
                                                                        p_daytime);

    lv_summer_time    := null;
    ld_production_day := null;

    IF lv_summer_time IS NULL THEN
      lv_summer_time := EcDp_Date_Time.summertime_flag(p_daytime,
                                                       NULL,
                                                       lv_pday_object_id);
    END IF;

    IF ld_production_day IS NULL THEN
      ld_production_day := EcDp_ProductionDay.getProductionDay('LIFTING_ACCOUNT',
                                                               p_object_id,
                                                               p_daytime,
                                                               lv_summer_time);
    END IF;

    UPDATE lift_account_adjustment
       SET production_day = ld_production_day, summer_time = lv_summer_time
     WHERE object_id = p_object_id
       AND daytime = p_daytime;

  END populateSubDailyValueAdj;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure       : populateSubDailyValueSinAdj
  -- Description    : Update production_day and summer time value.
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : LIFT_ACCOUNT_ADJ_SINGLE
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      : Update production_day and summer_time value.
  --
  ---------------------------------------------------------------------------------------------------
  PROCEDURE populateSubDailyValueSinAdj(p_object_id VARCHAR2,
                                        p_daytime   DATE)
  --</EC-DOC>
   IS
    lv_pday_object_id VARCHAR2(32);
    lv_summer_time    VARCHAR2(1);
    ld_production_day date;

  BEGIN
    lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL,
                                                                        p_object_id,
                                                                        p_daytime);

    lv_summer_time    := null;
    ld_production_day := null;

    IF lv_summer_time IS NULL THEN
      lv_summer_time := EcDp_Date_Time.summertime_flag(p_daytime,
                                                       NULL,
                                                       lv_pday_object_id);
    END IF;

    IF ld_production_day IS NULL THEN
      ld_production_day := EcDp_ProductionDay.getProductionDay('LIFTING_ACCOUNT',
                                                               p_object_id,
                                                               p_daytime,
                                                               lv_summer_time);
    END IF;

    UPDATE LIFT_ACCOUNT_ADJ_SINGLE
       SET production_day = ld_production_day, summer_time = lv_summer_time
     WHERE object_id = p_object_id
       AND daytime = p_daytime;

  END populateSubDailyValueSinAdj;

END EcBp_Lifting_Account;