CREATE OR REPLACE PACKAGE BODY EcBp_Well_Test_Status_Log IS
/****************************************************************
** Package        :  EcBp_Well_Test_Status_Log, body part
**
** $Revision: 1.0 $
**
** Purpose        :  This package is responsible for supporting business function
**                   related to Automatic Well Test Event Creation (PT.0021)
** Documentation  :  www.energy-components.com
**
** Created  : 11.09.2018  Gaurav Chaudhary
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 11.09.2018 chaudgau ECPD-50462 Initial Draft
********************************************************************/
TYPE gt_objectCode IS TABLE OF well.object_code%TYPE;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : logError
-- Description    : It help record error against proposed deferment row
-- Using tables   : proposed_well_tests
---------------------------------------------------------------------------------------------------
PROCEDURE logError(p_object_id VARCHAR2, p_daytime DATE DEFAULT NULL, p_msg VARCHAR2)
IS
BEGIN
  UPDATE proposed_well_tests
          SET err_log = p_msg
    WHERE object_id=p_object_id
          AND daytime = p_daytime;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getSystemSetting
-- Description    : fetches system setting value for given key and daytime
-- Using tables   : tv_system_setting
---------------------------------------------------------------------------------------------------
FUNCTION getSystemSetting
(
  p_key VARCHAR2
 ,p_daytime DATE DEFAULT ecdp_date_time.getcurrentsysdate
) RETURN VARCHAR2
RESULT_CACHE
IS
  lv2_value VARCHAR2(2000);
BEGIN
  SELECT VALUE
    INTO lv2_value
    FROM v_system_setting
   WHERE key = p_key
     AND daytime <= p_daytime
ORDER BY daytime DESC FETCH FIRST ROW ONLY;

RETURN lv2_value;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END getSystemSetting;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : flushData
-- Description    : Used to clean data from table leaving last two status of each Object
--
-- Using tables   : well_test_creation_log, proposed_well_tests
---------------------------------------------------------------------------------------------------
PROCEDURE flushData IS
  ln_num_days number;
BEGIN
  ln_num_days:= getSystemSetting
                         (
                          'WELL_TEST_LOG_FLUSH'
                          );

   DELETE FROM proposed_well_tests p
   WHERE p.daytime <= (ecdp_date_time.getcurrentsysdate - ln_num_days);

  DELETE FROM well_test_creation_log
   WHERE daytime <= (ecdp_date_time.getcurrentsysdate - ln_num_days);
END flushData;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getArray
-- Description    : It split the list of values from a string to associative array where
--                          name of array element will be the value, extracted from string
-- Using tables   :
---------------------------------------------------------------------------------------------------
FUNCTION getArray(p_list VARCHAR2,p_separator VARCHAR2 DEFAULT ',')
  RETURN gt_objectCode
 IS
    la_list                  gt_objectCode:=gt_objectCode();
    lv2_list                VARCHAR2(4000);
    ln_startPosition  NUMBER := 1;
    ln_nextPosition  NUMBER := 0;
    ln_index             NUMBER := 1;
    ln_charCount     NUMBER;
BEGIN
    IF p_list IS NULL
    THEN
        RETURN la_list;
    ELSE
        lv2_list := TRIM(p_separator FROM p_list);
    END IF;

    LOOP
        ln_nextPosition := instr(lv2_list
                                ,p_separator
                                ,1
                                ,ln_index);

        IF ln_nextPosition = 0
          THEN  ln_charCount := 4000;
          ELSE ln_charCount := ln_nextPosition - ln_startPosition;
        END IF;

        la_list.EXTEND;
        la_list(ln_index) := TRIM(substr(lv2_list, ln_startPosition, ln_charCount));
        ln_startPosition := ln_nextPosition + 1;
        ln_index         := ln_index + 1;
        EXIT WHEN ln_startPosition = 1;
    END LOOP;

    RETURN la_list;
END getArray;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getList
-- Description    : It convert a nested table to comma separated list of values
-- Using tables   :
---------------------------------------------------------------------------------------------------
FUNCTION getList(p_la_list gt_objectCode)
  RETURN VARCHAR2
 IS
    lv2_list VARCHAR2(4000);
BEGIN

    IF p_la_list IS EMPTY THEN
        RETURN NULL;
    ELSE
         FOR i IN 1..p_la_list.COUNT
         LOOP
             IF i=1 THEN
                lv2_list := TRIM(p_la_list(i));
            ELSE
               lv2_list := lv2_list || ',' || TRIM(p_la_list(i));
            END IF;
        END LOOP;
    END IF;

    RETURN lv2_list;
END getList;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createEvent
-- Description    : Generate deferment event into target BF (PD.0020 / PD.0023)
--
-- Using tables   : tv_prod_test, tv_well_test_def
---------------------------------------------------------------------------------------------------
PROCEDURE createEvent
(
     p_td_object_id     VARCHAR2
    ,p_start_date       DATE
    ,p_end_date         DATE
    ,p_n_wells_on_test  VARCHAR2
    ,p_o_wells_on_test  VARCHAR2
    ,p_creation_mode    VARCHAR2
    ,p_event_type       VARCHAR2
    ,p_test_no          NUMBER DEFAULT NULL
) IS
  lv2_err_msg       VARCHAR2(2000);
  ln_test_no        NUMBER:= p_test_no;
  lt_old_list       gt_objectCode;
  lt_target_list    gt_objectCode;
  lt_final_list     gt_objectCode;
  lv2_separator     VARCHAR2(10);

  CURSOR c_prod_test_define(cp_td_object_id VARCHAR2)
  IS
    SELECT MAX(pt.test_no) test_no
            FROM tv_test_device_test_def td JOIN tv_prod_test pt
                 ON pt.test_no = td.test_no
        WHERE pt.test_type = 'MULTI_WELL'
              AND pt.end_date IS NULL
              AND td.object_id =  cp_td_object_id
              AND pt.record_status ='P'
              AND pt.start_date <= p_start_date;

BEGIN

  lv2_separator := getSystemSetting('WELLS_ON_TEST_DELIMITER',TRUNC(NVL(p_start_date,p_end_date)));

IF UPPER(p_event_type) = 'UPDATING' OR (LOWER(p_creation_mode) = 'manual' AND ln_test_no IS NOT NULL) THEN

-- Check for test no in proposed tests
IF ln_test_no IS NULL THEN
   BEGIN
      SELECT test_no INTO ln_test_no
         FROM proposed_well_tests
       WHERE end_date IS NULL
             AND object_id = p_td_object_id;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
  END;

  IF ln_test_no IS NULL THEN
      FOR curTestNo IN c_prod_test_define(p_td_object_id)
     LOOP
         ln_test_no := curTestNo.Test_No;
    END LOOP;
 END IF;
END IF;

IF ln_test_no IS NULL THEN
  logError(p_td_object_id, p_start_date, 'No relevant production test data is found.');
  RETURN;
END IF;

    IF p_n_wells_on_test IS NOT NULL THEN
        IF lower(p_creation_mode) = 'manual' AND p_o_wells_on_test IS NULL THEN
         BEGIN
          SELECT ecdp_objects.GetObjCode(wt.object_id) BULK COLLECT INTO lt_old_list
            FROM tv_well_test_def wt
            JOIN tv_prod_test pt ON pt.test_no = wt.test_no
           WHERE pt.test_no = p_test_no
             AND pt.end_date IS NULL;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
               -- If defined test has been closed the create a new test definition
               logError(p_td_object_id, p_start_date, 'No open ended production test found.');
         END;
        ELSE
          lt_old_list := getArray(p_o_wells_on_test, lv2_separator);
        END IF;
          lt_target_list := getArray(p_n_wells_on_test, lv2_separator);
          lt_final_list := lt_target_list MULTISET EXCEPT DISTINCT lt_old_list;
          FOR i IN 1..lt_final_list.COUNT
          LOOP
                INSERT INTO tv_well_test_def (TEST_NO, OBJECT_ID, CLASS_NAME, rev_text)
                VALUES (ln_test_no, Ecdp_Objects.GetObjIDFromCode('WELL',lt_final_list(i)), 'WELL', 'Created ' || lower(p_creation_mode) || ' from PT.0021.');
          END LOOP;
    END IF;

    IF p_end_date IS NOT NULL THEN
         UPDATE tv_prod_test o
            SET end_date = p_end_date
                ,rev_text  = 'End_Date updated ' || lower(p_creation_mode) || ' from PT.0021.'
          WHERE test_no =ln_test_no
            AND end_date IS NULL;

           IF SQL%ROWCOUNT = 0 THEN
             logError(p_td_object_id, p_start_date, 'No open ended production test found.');
           END IF;
    END IF;
ELSIF UPPER(p_event_type) = 'INSERTING' OR ((LOWER(p_creation_mode) = 'manual' AND ln_test_no IS NULL)) THEN

      IF ln_test_no IS NULL THEN
           FOR curTestNo IN c_prod_test_define(p_td_object_id)
         LOOP
             ln_test_no := curTestNo.Test_No;
        END LOOP;
     END IF;

     IF ln_test_no IS NOT NULL THEN
       createEvent(p_td_object_id, p_start_date, p_start_date, NULL, NULL, p_creation_mode,'UPDATING',ln_test_no);
     END IF;

      -- Create new Production test event
      EcDp_System_Key.assignNextNumber('PTST_DEFINITION', ln_test_no);
       INSERT INTO tv_prod_test (test_no, start_date, end_date, test_type, test_device, rev_text)
        VALUES (ln_test_no, p_start_date, p_end_date, 'MULTI_WELL', p_td_object_id, 'Created ' || lower(p_creation_mode) || ' from PT.0021');

      lt_target_list := getArray(p_n_wells_on_test, lv2_separator);

      FOR i IN 1..lt_target_list.COUNT
      LOOP
          INSERT INTO tv_well_test_def (TEST_NO, OBJECT_ID, CLASS_NAME)
          VALUES (ln_test_no, Ecdp_Objects.GetObjIDFromCode('WELL',lt_target_list(i)), 'WELL');
     END LOOP;
END IF;

  UPDATE dv_proposed_well_tests
         SET test_no = ln_test_no
        ,error_log = NULL
  WHERE object_id=p_td_object_id
        AND daytime = p_start_date;

EXCEPTION
  WHEN OTHERS THEN
  lv2_err_msg := SUBSTR(SQLERRM,11);
  logError(p_td_object_id, p_start_date, lv2_err_msg);
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : isRedundant
-- Description    : It confirm about new record being redundant with respect to last row for same test device
-- Using tables   : well_test_creation_log
---------------------------------------------------------------------------------------------------
FUNCTION isRedundant
(
   p_td_object_id VARCHAR2
  ,p_wells_on_test VARCHAR2
  ,p_daytime DATE
  ,p_chk_proposed_tab VARCHAR2 DEFAULT 'N'
) RETURN NUMBER
IS
    lv2_TargetListOfWell   WELL_TEST_CREATION_LOG.WELLS_ON_TEST%TYPE;
    lt_proposed                  gt_objectCode;
    lt_target_list                   gt_objectCode;
    lt_minus_list                      gt_objectCode;
    ln_isFound                    NUMBER:=1;
    lv2_separator              VARCHAR2(10);

BEGIN
  IF p_chk_proposed_tab='N' THEN
        BEGIN
                SELECT wells_on_test INTO lv2_TargetListOfWell
                   FROM well_test_creation_log
                WHERE object_id = p_td_object_id
           ORDER BY daytime DESC FETCH FIRST ROW ONLY;

               IF TRIM(lv2_TargetListOfWell) = TRIM(p_wells_on_test) THEN
                 RETURN 1;
               ELSE
                 RETURN 0;
               END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RETURN 0;
        END;
  ELSE
        -- Check if we have any proposed production test with no end date for same test device
       lv2_separator := getSystemSetting('WELLS_ON_TEST_DELIMITER',TRUNC(p_daytime));

        BEGIN
            SELECT wells_on_test INTO lv2_TargetListOfWell
               FROM proposed_well_tests
             WHERE object_id = p_td_object_id
                   AND end_date IS NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN ln_isFound:=0;
        END;

        IF ln_isFound=0 OR  lv2_TargetListOfWell IS NULL THEN
          RETURN 0;
        ELSE
                lt_proposed := getArray(p_wells_on_test, lv2_separator);
                lt_target_list := getArray(lv2_TargetListOfWell, lv2_separator);
                lt_minus_list := lt_proposed MULTISET EXCEPT ALL lt_target_list;
                IF lt_minus_list.EXISTS(1) THEN
                  RETURN 0;
                ELSE
                  RETURN 1;
              END IF;
        END IF;
  END IF;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : proposeEvent
-- Description    : It verifies if Test configuration  is available in proposed data section and
--                        either update an existing proposed test configuration or create a new one
-- Using tables   :
---------------------------------------------------------------------------------------------------
PROCEDURE proposeEvent
                (p_td_object_id VARCHAR2
                ,p_daytime DATE
                ,p_wells_on_test VARCHAR2
                )
IS
  lt_proposed                gt_objectCode;
  lt_target_list                 gt_objectCode;
  lt_final_list                    gt_objectCode;
  lv2_separator              VARCHAR2(10);
  lv2_TargetListOfWell  proposed_well_tests.wells_on_test%TYPE;
  ln_isFound                  NUMBER:=1;

BEGIN
   -- Split the list of well in array form
    lv2_separator := getSystemSetting('WELLS_ON_TEST_DELIMITER',TRUNC(p_daytime));
    lt_proposed  := getArray(p_wells_on_test, lv2_separator);

    -- Check if we have any proposed production test with no end date for same test device
    BEGIN
        SELECT wells_on_test INTO lv2_TargetListOfWell
           FROM proposed_well_tests
         WHERE object_id = p_td_object_id
               AND end_date IS NULL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN ln_isFound:=0;
    END;

    IF ln_isFound = 0
       AND p_wells_on_test IS NULL
    THEN
        RETURN;
    END IF;
    -- If no Production test is found with open end date then propose new production test
    IF ln_isFound=0 THEN
          INSERT INTO dv_proposed_well_tests(object_id, daytime, wells_on_test)
          VALUES(p_td_object_id, p_daytime, p_wells_on_test);
    ELSE
            -- Production Test found with open end date (end date is null)
            -- Check if there is an overlap of well in proposed test and raw data
            IF lv2_TargetListOfWell IS NOT NULL THEN
                    lt_target_list := getArray(lv2_TargetListOfWell, lv2_separator);
                    lt_final_list := lt_proposed MULTISET UNION DISTINCT lt_target_list;

                    --There is no overlap if count is lt_final_list element COUNT matches
                    -- with total count of other two nested tables.
                    -- Close the existing event and propose a new event with new Wells
                    IF lt_final_list.COUNT = (lt_proposed.COUNT + lt_target_list.COUNT) THEN
                        UPDATE dv_proposed_well_tests
                                SET end_date = p_daytime
                         WHERE object_id=p_td_object_id AND end_date IS NULL;

                         INSERT INTO dv_proposed_well_tests (object_id, daytime, wells_on_test)
                                 VALUES (p_td_object_id, p_daytime, p_wells_on_test);
                    ELSE
                      -- If overlap is found then update the list of well in the configuration
                      lv2_TargetListOfWell := getList(lt_final_list);

                      UPDATE dv_proposed_well_tests
                              SET wells_on_test = lv2_TargetListOfWell
                       WHERE object_id=p_td_object_id AND end_date IS NULL;
                    END IF;
               ELSE
                   -- This step will only execute when prosposed event has production test
                   -- for test device but no well exists in list of wells
                       lv2_TargetListOfWell := getList(lt_proposed);
                      UPDATE dv_proposed_well_tests
                              SET wells_on_test = lv2_TargetListOfWell
                       WHERE object_id=p_td_object_id AND end_date IS NULL;
              END IF;
    END IF;
END;

END EcBp_Well_Test_Status_Log;