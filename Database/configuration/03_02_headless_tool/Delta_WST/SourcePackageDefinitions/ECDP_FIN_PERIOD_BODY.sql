CREATE OR REPLACE PACKAGE BODY EcDp_Fin_Period IS
/****************************************************************
** Package        :  EcDp_Fin_Period, body part
**
** $Revision: 1.23 $
**
** Purpose        :  Provide special functions on Financials Periods
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.11.2005 Trond-Arne Brattli
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
*****************************************************************/

PROCEDURE ClosePeriod(
   p_period_type VARCHAR2, -- BOOKING or REPORTING
   p_daytime DATE, -- period
   p_user VARCHAR2,
   p_closing_time DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate
)

IS

BEGIN

     IF p_period_type = 'BOOKING' THEN

       UPDATE system_mth_status
          SET closed_book_date = p_closing_time
             ,last_updated_by = p_user
        WHERE daytime = Trunc( p_daytime , 'MM' );

        -- Delete the generated validation lists
        Ecdp_Stream_Item_Validation.DeleteValidationLists(p_daytime);

     ELSIF p_period_type = 'REPORTING' THEN

       UPDATE system_mth_status
          SET closed_report_date = p_closing_time
             ,last_updated_by = p_user
        WHERE daytime = Trunc( p_daytime , 'MM' );

     END IF;

END;


PROCEDURE OpenPeriod(
   p_period_type VARCHAR2, -- BOOKING or REPORTING
   p_daytime DATE, -- period
   p_user VARCHAR2
)


IS

BEGIN

     IF p_period_type = 'BOOKING' THEN

       UPDATE system_mth_status
          SET closed_book_date = NULL
             ,last_updated_by = p_user
        WHERE daytime = Trunc( p_daytime , 'MM' );


     ELSIF p_period_type = 'REPORTING' THEN

       UPDATE system_mth_status
          SET closed_report_date = NULL
             ,last_updated_by = p_user
        WHERE daytime = Trunc( p_daytime , 'MM' );

     END IF;

END;


FUNCTION GetCurrOpenPeriod( --This function is no longer in used
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate,
   p_period_type VARCHAR2 DEFAULT 'BOOKING'

)

RETURN DATE

IS

ld_return_val DATE;

lv2_daytime DATE := Trunc(Nvl(p_daytime, Ecdp_Timestamp.getCurrentSysdate),'MM');

CURSOR c_per IS
SELECT daytime
FROM system_mth_status
WHERE closed_book_date IS NULL
ORDER BY daytime;

CURSOR c_rep_per IS
SELECT daytime
FROM system_mth_status
WHERE closed_report_date IS NULL
ORDER BY daytime;

BEGIN

     IF p_period_type = 'BOOKING' THEN

         FOR PerCur IN c_per LOOP

             IF PerCur.daytime = lv2_daytime THEN

                ld_return_val := PerCur.daytime;
                EXIT; -- got it

             ELSIF PerCur.daytime < lv2_daytime THEN -- Less than

                ld_return_val := PerCur.daytime;
                EXIT; -- got it

             ELSE -- greater than

                IF ld_return_val IS NULL THEN

                   -- take it
                  ld_return_val := PerCur.daytime;

                ELSE

                    IF Abs(PerCur.daytime - ld_return_val) > Abs(PerCur.daytime - lv2_daytime) THEN

                       ld_return_val := PerCur.daytime; -- this period is closer

                    END IF;

                END IF;

                EXIT; -- got it

             END IF;

         END LOOP;

     ELSIF p_period_type = 'REPORTING' THEN

         FOR PerCur IN c_rep_per LOOP

             IF PerCur.daytime = lv2_daytime THEN

                ld_return_val := PerCur.daytime;
                EXIT; -- got it

             ELSIF PerCur.daytime < lv2_daytime THEN -- Less than

                ld_return_val := PerCur.daytime;
                EXIT; -- got it

             ELSE -- greater than

                IF ld_return_val IS NULL THEN

                   -- take it
                  ld_return_val := PerCur.daytime;

                ELSE

                    IF Abs(PerCur.daytime - ld_return_val) > Abs(PerCur.daytime - lv2_daytime) THEN

                       ld_return_val := PerCur.daytime; -- this period is closer

                    END IF;

                END IF;

                EXIT; -- got it

             END IF;

         END LOOP;

      END IF;

     RETURN ld_return_val;

END GetCurrOpenPeriod;

---------------------------------------------------------------------------------------------------
PROCEDURE instantiatePeriodForCompany(p_user VARCHAR2, p_company_id VARCHAR2)
IS
    CURSOR c_generated_years IS
        SELECT DISTINCT TRUNC(SYSTEM_MTH_STATUS.DAYTIME, 'YYYY') YEAR
        FROM SYSTEM_MTH_STATUS
        ORDER BY TRUNC(SYSTEM_MTH_STATUS.DAYTIME, 'YYYY');

BEGIN
    FOR lci_year IN c_generated_years LOOP
        instantiatePeriod(lci_year.YEAR, p_user, p_company_id);
    END LOOP;
END instantiatePeriodForCompany;

---------------------------------------------------------------------------------------------------
PROCEDURE instantiateMissingPeriods(
    p_daytime                            DATE,
    p_user                               VARCHAR2)
IS
    ln_last_year NUMBER;
    ln_end_period NUMBER;
    ln_tmp_year_booking NUMBER;
    ln_tmp_year_reporting NUMBER;
    ln_tmp_year NUMBER;

    CURSOR c_codes IS
        SELECT pc.code
        FROM PROSTY_CODES pc
        WHERE pc.code_type = 'BOOKING_AREA_CODE';
BEGIN
    FOR cur IN c_codes LOOP
        ln_tmp_year_booking := to_number(to_char(getLatestFullyClosedPeriod(cur.code, 'BOOKING'),'YYYY'));
        ln_tmp_year_reporting := to_number(to_char(getLatestFullyClosedPeriod(cur.code, 'REPORTING'),'YYYY'));

        IF ln_tmp_year_booking < ln_tmp_year_reporting THEN
            ln_tmp_year := ln_tmp_year_booking;
        ELSE
            ln_tmp_year := ln_tmp_year_reporting;
        END IF;

        IF ln_last_year IS NULL OR ln_last_year > ln_tmp_year THEN
            ln_last_year := ln_tmp_year;
        END IF;
    END LOOP;

    IF TO_NUMBER(TO_CHAR(p_daytime,'YYYY')) > ln_last_year THEN
        ln_end_period :=TO_NUMBER(TO_CHAR(p_daytime,'YYYY'));
            FOR i in ln_last_year..ln_end_period loop
                instantiatePeriod(to_date(to_char(i),'yyyy'), p_user);
            END LOOP;
    END IF;
END;
---------------------------------------------------------------------------------------------------
PROCEDURE instantiatePeriod
 (p_daytime DATE,  p_user VARCHAR2, p_company_id VARCHAR2 DEFAULT NULL)
IS

CURSOR c_country(cp_daytime DATE) IS
SELECT o.object_id
FROM  GEOGR_AREA_VERSION oa, GEOGRAPHICAL_AREA o
WHERE oa.object_id = o.object_id
AND o.class_name='COUNTRY'
AND cp_daytime >= Nvl(o.start_date,cp_daytime-1)
AND cp_daytime < Nvl(o.end_date,cp_daytime+1)
;

-- Get all system companies for the given daytime version.
-- If cp_company_id is given, then only that company will be
-- queried.
CURSOR c_company(cp_daytime DATE, cp_country_id VARCHAR2, cp_company_id VARCHAR2 DEFAULT NULL) IS
SELECT o.object_id
FROM COMPANY_VERSION oa, COMPANY o
WHERE o.object_id = NVL(cp_company_id, o.object_id)
AND oa.object_id = o.object_id
AND o.class_name='COMPANY'
AND oa.country_id = cp_country_id
AND cp_daytime >= Nvl(o.start_date,cp_daytime-1)
AND cp_daytime < Nvl(o.end_date,cp_daytime+1)
AND (oa.system_company_ind = 'Y' OR o.object_code like '%FULL%')
;

CURSOR c_closed IS
SELECT count(*) as closed
FROM SYSTEM_MTH_STATUS sms
WHERE sms.closed_book_date IS NOT NULL OR sms.closed_report_date IS NOT NULL
;

CURSOR c_min_year IS
SELECT min(sms.daytime) as daytime
FROM SYSTEM_MTH_STATUS sms
;

CURSOR c_max_year IS
SELECT max(sms.daytime) as daytime
FROM SYSTEM_MTH_STATUS sms
;

CURSOR c_codes IS
SELECT pc.code
FROM PROSTY_CODES pc
WHERE pc.code_type = 'BOOKING_AREA_CODE';


TYPE AREA_CODE_AND_DATE_TABLE IS TABLE OF DATE INDEX BY SYSTEM_MTH_STATUS.Booking_Area_Code%TYPE;

area_max_fully_close_date_book AREA_CODE_AND_DATE_TABLE;
area_max_fully_close_date_rep AREA_CODE_AND_DATE_TABLE;

ln_counter NUMBER;
ld_min_year DATE;
ld_max_year DATE;
ld_max_closed_booking_month DATE;
ld_max_closed_reporting_month DATE;

BEGIN

     FOR cur IN c_min_year LOOP
         ld_min_year := cur.daytime;
     END LOOP;

     FOR cur IN c_max_year LOOP
         ld_max_year := cur.daytime;
     END LOOP;

     --check if the year is valid
     IF  TRUNC(p_daytime, 'YYYY') > add_months(TRUNC(ld_max_year,'YYYY'),12) OR  TRUNC(p_daytime, 'YYYY') < add_months(TRUNC(ld_min_year, 'YYYY'),-12) THEN
        RAISE_APPLICATION_ERROR(-20000,'The selected year must be next or prior to the exist period of year(s)');
     END IF;

     FOR curRow IN c_closed LOOP
         --if there is a cloded period(s)
         IF curRow.closed <> 0 THEN
             --if there is existing period(s)s

                IF TRUNC(p_daytime, 'YYYY') < TRUNC(ld_min_year, 'YYYY') THEN
                   RAISE_APPLICATION_ERROR(-20000,'The selected year must be later than ' || to_char(ld_min_year, 'YYYY'));
                END IF;

        END IF;
     END LOOP;

    -- Find out the max fully closed (all companies in that
    -- month are closed) daytime for each booking area
    FOR codes IN c_codes LOOP
        area_max_fully_close_date_book(codes.CODE) := getLatestFullyClosedPeriod(codes.CODE, 'BOOKING');
        area_max_fully_close_date_rep(codes.CODE) := getLatestFullyClosedPeriod(codes.CODE, 'REPORTING');
    END LOOP;


    FOR country IN c_country(p_daytime) LOOP

       FOR company IN c_company(p_daytime, country.object_id, p_company_id) LOOP

          FOR codes IN c_codes LOOP

            ld_max_closed_booking_month := area_max_fully_close_date_book(codes.CODE);
            ld_max_closed_reporting_month := area_max_fully_close_date_rep(codes.CODE);

            FOR ln_months IN 0..11 LOOP

                  SELECT count (*) INTO ln_counter
                    FROM system_mth_status sms
                   WHERE sms.country_id = country.object_id
                     AND sms.company_id = company.object_id
                     AND sms.booking_area_code = codes.code
                     AND sms.daytime = ADD_MONTHS(TRUNC(p_daytime, 'YYYY'),ln_months);

                  IF (ln_counter = 0) THEN

                    -- Generate period record for new company/month,
                    -- the period is closed when record with newer daytime
                    -- and the same booking area code is found closed.
                    INSERT INTO system_mth_status(
                            country_id,
                            company_id,
                            daytime,
                            booking_area_code,
                            instantiate_date,
                            created_by,
                            created_date,
                            Closed_Book_Date,
                            Closed_Report_Date
                            )
                    VALUES (
                            country.object_id,
                            company.object_id,
                            ADD_MONTHS(TRUNC(p_daytime, 'YYYY'),ln_months),
                            codes.code,
                            Ecdp_Timestamp.getCurrentSysdate,
                            p_user,
                            Ecdp_Timestamp.getCurrentSysdate,
                            CASE
                                WHEN ld_max_closed_booking_month IS NULL OR ld_max_closed_booking_month < ADD_MONTHS(TRUNC(p_daytime, 'YYYY'),ln_months)
                                    THEN NULL
                                ELSE Ecdp_Timestamp.getCurrentSysdate
                                END,
                            CASE
                                WHEN ld_max_closed_reporting_month IS NULL OR ld_max_closed_reporting_month < ADD_MONTHS(TRUNC(p_daytime, 'YYYY'),ln_months)
                                    THEN NULL
                                ELSE Ecdp_Timestamp.getCurrentSysdate
                                END
                            );

                  END IF;

             END LOOP; --months

           END LOOP; --codes

        END LOOP; --company

    END LOOP; --country

    --delete any companies in there that are not system company any more:
    DELETE FROM SYSTEM_MTH_STATUS S
        WHERE TRUNC(S.DAYTIME, 'YYYY') = TRUNC(P_DAYTIME, 'YYYY')
            AND NVL(EC_COMPANY_VERSION.SYSTEM_COMPANY_IND(S.COMPANY_ID, S.DAYTIME, '<='), 'N') = 'N';

END instantiatePeriod;

---------------------------------------------------------------------------------------------------

FUNCTION getLatestFullyClosedPeriod(p_booking_area_code VARCHAR2, p_period_type VARCHAR2)
    RETURN DATE
IS
    CURSOR c_daytime_with_no_open(cp_booking_area_code VARCHAR2, cp_period_type VARCHAR2)
    IS
        SELECT SYSTEM_MTH_STATUS.DAYTIME DAYTIME
        FROM SYSTEM_MTH_STATUS
        WHERE SYSTEM_MTH_STATUS.BOOKING_AREA_CODE = cp_booking_area_code
        GROUP BY SYSTEM_MTH_STATUS.DAYTIME
        HAVING SUM(
            CASE
                WHEN (
                    CASE cp_period_type
                        WHEN 'BOOKING'
                            THEN SYSTEM_MTH_STATUS.CLOSED_BOOK_DATE
                        ELSE SYSTEM_MTH_STATUS.CLOSED_REPORT_DATE
                        END) IS NULL
                    THEN 1
                ELSE 0
                END) = 0
        ORDER BY SYSTEM_MTH_STATUS.DAYTIME DESC;

    ld_result DATE;
BEGIN
    FOR lci_daytime IN c_daytime_with_no_open(p_booking_area_code, p_period_type) LOOP
        ld_result := lci_daytime.DAYTIME;
        EXIT;
    END LOOP;

    RETURN ld_result;
END getLatestFullyClosedPeriod;

---------------------------------------------------------------------------------------------------
FUNCTION getClosedPeriodStatusAll
 (p_daytime DATE, p_country_id VARCHAR2, p_company_id VARCHAR2, p_period_type VARCHAR2)
 RETURN VARCHAR2 --Y = all booking area code for that period is closed
                 --N = one or more booking are code is not closed
IS
CURSOR c_codes IS
SELECT pc.code
FROM PROSTY_CODES pc
WHERE pc.code_type = 'BOOKING_AREA_CODE';


CURSOR c_sms (cp_daytime DATE, cp_country_id VARCHAR2, cp_company_id VARCHAR2, cp_booking_area_code VARCHAR2, cp_period_type VARCHAR2) IS
SELECT DECODE(cp_period_type, 'BOOKING', sms.closed_book_date, sms.closed_report_date) as closed_date
FROM SYSTEM_MTH_STATUS sms
WHERE sms.daytime = cp_daytime
AND sms.country_id = cp_country_id
AND sms.company_id = cp_company_id
AND sms.booking_area_code = cp_booking_area_code;

BEGIN

     FOR v1 IN c_codes LOOP

        FOR v2 IN c_sms(p_daytime, p_country_id, p_company_id, v1.code, p_period_type) LOOP

             IF v2.closed_date IS NULL THEN
                RETURN 'N';
             END IF;

         END LOOP;

     END LOOP;

 RETURN 'Y';

END getClosedPeriodStatusAll;

FUNCTION getClosedPeriodStatus
 (p_daytime DATE)
 RETURN VARCHAR2
IS

BEGIN

  IF p_daytime > Ecdp_Timestamp.getCurrentSysdate THEN
     --to be closed
     RETURN '>';
  ELSIF p_daytime <= Ecdp_Timestamp.getCurrentSysdate THEN
     --closed
     RETURN '<=';
  ELSE
     RETURN null;
  END IF;

END getClosedPeriodStatus;

PROCEDURE updatePeriod(p_daytime           DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE,
 p_user VARCHAR2,
 p_action VARCHAR2, --Close or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
                       p_ind               VARCHAR2) -- Y or N Good one ;-)
IS

invalid_closed_date EXCEPTION;
invalid_reopen_date EXCEPTION;
invalid_reopen_date2 EXCEPTION;
invalid_to_close_date EXCEPTION;
invalid_to_close_date2 EXCEPTION;

lv2_report_booking_ind VARCHAR2(1);


CURSOR c_max_period_closed(cp_country_id VARCHAR2, cp_company_id VARCHAR2, cp_booking_area_code VARCHAR2, cp_period_type VARCHAR2) IS
select MAX(daytime) as daytime from system_mth_status t where
          t.country_id = cp_country_id AND
          t.company_id = NVL(cp_company_id, t.company_id) AND
          t.booking_area_code = NVL(cp_booking_area_code, t.booking_area_code) AND
          DECODE(cp_period_type, 'BOOKING', t.closed_book_date, t.closed_report_date) IS NOT NULL AND
          DECODE(cp_period_type, 'BOOKING', t.closed_book_date, t.closed_report_date) <= Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_max_period_generated(cp_country_id VARCHAR2, cp_company_id VARCHAR2, cp_booking_area_code VARCHAR2, cp_period_type VARCHAR2, cp_daytime_boundary DATE) IS
select MAX(daytime) as daytime from system_mth_status t where
          t.country_id = cp_country_id AND
          t.company_id = NVL(cp_company_id, t.company_id) AND
          t.booking_area_code = NVL(cp_booking_area_code, t.booking_area_code) AND
          t.daytime < cp_daytime_boundary;

CURSOR c_max_period_to_close(cp_country_id VARCHAR2, cp_company_id VARCHAR2, cp_booking_area_code VARCHAR2, cp_period_type VARCHAR2) IS
select MAX(daytime) as daytime from system_mth_status t where
          t.country_id = cp_country_id AND
          t.company_id = NVL(cp_company_id, t.company_id) AND
          t.booking_area_code = NVL(cp_booking_area_code, t.booking_area_code) AND
          DECODE(cp_period_type, 'BOOKING', t.closed_book_date, t.closed_report_date) IS NOT NULL AND
          DECODE(cp_period_type, 'BOOKING', t.closed_book_date, t.closed_report_date) > Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_min_period(cp_country_id VARCHAR2, cp_company_id VARCHAR2, cp_booking_area_code VARCHAR2, cp_period_type VARCHAR2) IS
select MIN(t.daytime) as daytime from system_mth_status t where
          t.country_id = cp_country_id AND
          t.company_id = NVL(cp_company_id, t.company_id) AND
          t.booking_area_code = NVL(cp_booking_area_code, t.booking_area_code);

ld_closed_date         DATE;
ld_max_period_closed   DATE;
ld_max_period_generated DATE;
ld_max_period_to_close DATE;
ld_old_closed_date     DATE;
ld_min_period          DATE;

CURSOR c_qty_close(cp_daytime DATE, cp_country_id VARCHAR2, cp_period_type VARCHAR2, cp_company_id varchar default null) IS
SELECT count(*) num
  FROM system_mth_status sms
 WHERE sms.booking_area_code = 'QUANTITIES'
   AND sms.daytime = cp_daytime
   AND sms.country_id = cp_country_id
   AND sms.company_id = nvl(cp_company_id,sms.company_id)
   AND DECODE(cp_period_type, 'BOOKING', sms.closed_book_date, sms.closed_report_date) IS NOT NULL;


CURSOR c_qty_reopen(cp_daytime DATE, cp_country_id VARCHAR2, cp_period_type VARCHAR2, cp_company_id varchar default null) IS
SELECT count(*) num
FROM system_mth_status sms
WHERE sms.booking_area_code = 'QUANTITIES'
AND sms.daytime = cp_daytime
AND sms.country_id = cp_country_id
AND sms.company_id = nvl(cp_company_id,sms.company_id)
AND DECODE(cp_period_type, 'BOOKING', sms.closed_book_date, sms.closed_report_date) IS NULL;

BEGIN

    lv2_report_booking_ind := Nvl(ec_ctrl_system_attribute.attribute_text(p_daytime,'ALIGN_REPORTING_BOOKING','<='),'N');

    -- "Instead-of" user exits
    IF p_booking_area_code = 'JOU_ENT' AND ue_Fin_Period.isUpdatePeriodJouEntUEE = 'TRUE' THEN

      ue_Fin_Period.UpdatePeriodJouEntUEE(p_daytime, p_country_id, p_company_id, p_booking_area_code, p_to_close_date, p_user, p_action, p_period_type, p_ind);

    ELSIF p_booking_area_code = 'QUANTITIES' AND ue_Fin_Period.isUpdatePeriodQuantityUEE = 'TRUE' THEN

      ue_Fin_Period.UpdatePeriodQuantityUEE(p_daytime, p_country_id, p_company_id, p_booking_area_code, p_to_close_date, p_user, p_action, p_period_type, p_ind);

    ELSIF p_booking_area_code = 'INVENTORY' AND ue_Fin_Period.isUpdatePeriodInventoryUEE = 'TRUE' THEN

      ue_Fin_Period.UpdatePeriodInventoryUEE(p_daytime, p_country_id, p_company_id, p_booking_area_code, p_to_close_date, p_user, p_action, p_period_type, p_ind);

    ELSIF p_booking_area_code = 'SALE' AND ue_Fin_Period.isUpdatePeriodSaleUEE = 'TRUE' THEN

      ue_Fin_Period.UpdatePeriodSaleUEE(p_daytime, p_country_id, p_company_id, p_booking_area_code, p_to_close_date, p_user, p_action, p_period_type, p_ind);

    ELSIF p_booking_area_code = 'PURCHASE' AND ue_Fin_Period.isUpdatePeriodPurchaseUEE = 'TRUE' THEN

      ue_Fin_Period.UpdatePeriodPurchaseUEE(p_daytime, p_country_id, p_company_id, p_booking_area_code, p_to_close_date, p_user, p_action, p_period_type, p_ind);

    ELSIF p_booking_area_code = 'TA_INCOME' AND ue_Fin_Period.isUpdatePeriodTaIncomeUEE = 'TRUE' THEN

      ue_Fin_Period.UpdatePeriodTaIncomeUEE(p_daytime, p_country_id, p_company_id, p_booking_area_code, p_to_close_date, p_user, p_action, p_period_type, p_ind);

    ELSIF p_booking_area_code = 'TA_COST' AND ue_Fin_Period.isUpdatePeriodTaCostUEE = 'TRUE' THEN

      ue_Fin_Period.UpdatePeriodTaCostUEE(p_daytime, p_country_id, p_company_id, p_booking_area_code, p_to_close_date, p_user, p_action, p_period_type, p_ind);

    ELSE

       -- "Pre" User Exit
       IF ue_Fin_Period.isUpdatePeriodPreUEE = 'TRUE' THEN
         ue_Fin_Period.UpdatePeriodPreUEE(p_daytime, p_country_id, p_company_id, p_booking_area_code, p_to_close_date, p_user, p_action, p_period_type, p_ind);
       END IF;


       --special handling for QUANTITIES
       IF p_booking_area_code = 'QUANTITIES' AND p_action = 'CLOSE'  THEN

          FOR cur2 IN c_qty_close(p_daytime, p_country_id, p_period_type,p_company_id) LOOP

             IF cur2.num > 0 THEN
                RETURN;
             END IF;

          END LOOP;

       ELSIF p_booking_area_code = 'QUANTITIES' AND p_action = 'REOPEN' THEN

          FOR cur2 IN c_qty_reopen(p_daytime, p_country_id, p_period_type,p_company_id) LOOP

             IF cur2.num > 0 THEN
                RETURN;
             END IF;

          END LOOP;

       END IF;

       IF p_action = 'CLOSE' THEN
          IF p_ind = 'Y' THEN
             ld_closed_date := Ecdp_Timestamp.getCurrentSysdate;
          ELSIF p_ind = 'N' THEN
             ld_closed_date := p_to_close_date;
          END IF;
       ELSIF p_action = 'REOPEN' AND p_ind = 'Y' THEN
         ld_closed_date := NULL;
       END IF;

        --getting the Max Period Closed
        FOR cur IN c_max_period_closed(p_country_id, p_company_id, p_booking_area_code, p_period_type) LOOP
          ld_max_period_closed := cur.daytime;
        END LOOP;
        --getting the Max Period Generated
        FOR cur IN c_max_period_generated(p_country_id, p_company_id, p_booking_area_code, p_period_type, p_daytime) LOOP
          ld_max_period_generated := cur.daytime;
        END LOOP;
        --getting the Max Period To Close
        FOR cur IN c_max_period_to_close(p_country_id, p_company_id, p_booking_area_code, p_period_type) LOOP
          ld_max_period_to_close := cur.daytime;
        END LOOP;
        --getting the Min Period
        FOR cur IN c_min_period(p_country_id, p_company_id, p_booking_area_code, p_period_type) LOOP
          ld_min_period := cur.daytime;
        END LOOP;

        IF p_period_type = 'BOOKING' THEN
           ld_old_closed_date := ec_system_mth_status.closed_book_date(p_daytime, p_country_id, p_company_id, p_booking_area_code);
        ELSIF p_period_type = 'REPORTING' THEN
           ld_old_closed_date := ec_system_mth_status.closed_report_date(p_daytime, p_country_id, p_company_id, p_booking_area_code);
        END IF;

        --if updating to close date
        IF  p_ind = 'N' AND p_action = 'CLOSE' THEN

           IF p_to_close_date IS NOT NULL THEN

               IF ld_max_period_closed IS NULL AND p_daytime <> ld_min_period THEN
                  RAISE invalid_to_close_date2;
               END IF;

               IF ld_max_period_generated <> ld_max_period_closed THEN
                   RAISE invalid_to_close_date2;
               END IF;

               IF  p_to_close_date < Ecdp_Timestamp.getCurrentSysdate THEN
                  RAISE invalid_to_close_date;
               END IF;

           END IF;

        ELSE --when the checkbox is checked.

            IF p_action = 'CLOSE' THEN
                --if there is no closed period and not closing the earliest period
                IF ld_max_period_closed IS NULL AND p_daytime <> ld_min_period THEN
                   RAISE invalid_closed_date;
                END IF;

                --this is for updating all booking periods.
                IF ld_old_closed_date IS NULL THEN
                  --if not closing the next period of latest closed period
                  IF ld_max_period_generated <> ld_max_period_closed THEN
                     RAISE invalid_closed_date;
                  END IF;
                END IF;

           ELSIF p_action = 'REOPEN' THEN

                --if not reopening the latest closed period.
                IF p_daytime <> ld_max_period_closed THEN
                    RAISE invalid_reopen_date;
                END IF;
                --if there is time to close is set in next month
                IF p_daytime < ld_max_period_to_close THEN
                    RAISE invalid_reopen_date2;
                END IF;

            END IF;

        END IF;

        --update only fulfill below condition
        IF  (p_ind='Y' AND p_action='CLOSE' AND (ld_old_closed_date IS NULL OR ld_old_closed_date > Ecdp_Timestamp.getCurrentSysdate))
           OR (p_ind='N' AND p_action='CLOSE')
           OR (p_ind='Y' AND p_action='REOPEN')THEN

           IF p_period_type = 'BOOKING' THEN

              UPDATE system_mth_status sms
                 SET sms.closed_book_date  = ld_closed_date,
                   sms.last_updated_by = p_user,
                   sms.last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                   sms.rev_no = sms.rev_no + 1
               WHERE sms.daytime = p_daytime
                 AND sms.country_id = p_country_id
                 AND sms.company_id =
                     DECODE(p_booking_area_code, 'QUANTITIES', sms.company_id, p_company_id)
                 AND sms.booking_area_code = p_booking_area_code;

                 ecdp_document_gen.cleanupstimrecords(p_company_id, p_booking_area_code, p_user);

                IF lv2_report_booking_ind = 'Y' THEN
                  --let the Reporting Periods follow the Booking Periods
                  UPDATE system_mth_status sms
                     SET sms.closed_report_date = ld_closed_date, --set the closed_REPORT_date as well
                         sms.last_updated_by    = p_user,
                         sms.last_updated_date  = Ecdp_Timestamp.getCurrentSysdate,
                         sms.rev_no             = sms.rev_no + 1
                   WHERE sms.daytime = p_daytime
                     AND sms.country_id = p_country_id
                     AND sms.company_id =
                         DECODE(p_booking_area_code, 'QUANTITIES', sms.company_id, p_company_id)
                     AND sms.booking_area_code = p_booking_area_code;
                END IF;


           ELSIF p_period_type = 'REPORTING' THEN

                UPDATE system_mth_status sms SET
                   sms.closed_report_date = ld_closed_date,
                   sms.last_updated_by = p_user,
                   sms.last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                   sms.rev_no = sms.rev_no + 1
                 WHERE
                   sms.daytime = p_daytime  AND
                   sms.country_id = p_country_id  AND
                   sms.company_id = DECODE(p_booking_area_code, 'QUANTITIES', sms.company_id, p_company_id) AND
                   sms.booking_area_code = p_booking_area_code;

                 IF lv2_report_booking_ind = 'Y' THEN
                    --let the Booking Periods follow the Reporting Periods
                    UPDATE system_mth_status sms
                       SET sms.closed_book_date  = ld_closed_date, --set the closed_BOOK_date as well
                           sms.last_updated_by   = p_user,
                           sms.last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                           sms.rev_no            = sms.rev_no + 1
                     WHERE sms.daytime = p_daytime
                       AND sms.country_id = p_country_id
                       AND sms.company_id =
                           DECODE(p_booking_area_code, 'QUANTITIES', sms.company_id, p_company_id)
                       AND sms.booking_area_code = p_booking_area_code;
                 END IF;

             END IF;

        END IF;

        -- "Post" User Exit
        IF ue_Fin_Period.isUpdatePeriodPostUEE = 'TRUE' THEN
          ue_Fin_Period.UpdatePeriodPostUEE(p_daytime, p_country_id, p_company_id, p_booking_area_code, p_to_close_date, p_user, p_action, p_period_type, p_ind);
        END IF;

      END IF; -- "instead of" user exit

EXCEPTION    -- This can fail if there are gaps between periods
       WHEN invalid_closed_date THEN
		 	   RAISE_APPLICATION_ERROR(-20000,'All month(s) must be closed before  ' || p_daytime);
       WHEN invalid_reopen_date THEN
		 	   RAISE_APPLICATION_ERROR(-20000,'All month(s) must be reopened after  ' || p_daytime);
       WHEN invalid_to_close_date THEN
		 	   RAISE_APPLICATION_ERROR(-20000,'Time to close must be later or equals to current system time');
       WHEN invalid_to_close_date2 THEN
		 	   RAISE_APPLICATION_ERROR(-20000,'The previous period must be closed before setting time to close for ' || p_daytime);
       WHEN invalid_reopen_date2 THEN
		 	   RAISE_APPLICATION_ERROR(-20000,'The next period of ' || p_booking_area_code ||  '''s (Time to Close) date must be cleared before reopening ' || p_daytime);

END updatePeriod;


PROCEDURE updatePeriodAll
 (p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2,
 p_ind VARCHAR2)
 IS

CURSOR c_codes IS
SELECT pc.code as booking_area_code
FROM PROSTY_CODES pc
WHERE pc.code_type = 'BOOKING_AREA_CODE';



BEGIN
     --when checkbox is checked
     IF p_ind='Y' THEN

       FOR cur IN c_codes LOOP

           --special handling for QUANTITIES.
           updatePeriod(p_daytime, p_country_id, p_company_id, cur.booking_area_code, NULL,  p_user,  p_action, p_period_type, p_ind);

       END LOOP; --codes

     END IF;

END updatePeriodAll;

FUNCTION getCurrentOpenPeriod (
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_period_type VARCHAR2 DEFAULT 'BOOKING',
 p_doc_key VARCHAR2 DEFAULT NULL,
 p_doc_date DATE DEFAULT NULL
)
RETURN DATE
IS

CURSOR c_per(cp_country_id VARCHAR2, cp_company_id VARCHAR2, cp_booking_area_code VARCHAR2, cp_period_type VARCHAR2) IS
SELECT daytime
FROM system_mth_status
WHERE
(DECODE(cp_period_type, 'BOOKING', closed_book_date, closed_report_date) IS NULL
OR DECODE(cp_period_type, 'BOOKING', closed_book_date, closed_report_date) > Ecdp_Timestamp.getCurrentSysdate)
AND country_id = cp_country_id
AND company_id = cp_company_id
AND booking_area_code = cp_booking_area_code
ORDER BY daytime;

ld_return_val DATE := NULL;
ld_temp_val DATE := NULL;
ld_doc_date DATE := NULL;
lv2_daytime DATE := Trunc(Ecdp_Timestamp.getCurrentSysdate,'MM');

BEGIN

    /*
    FOR cur IN c_per(p_country_id, p_company_id, p_booking_area_code, p_period_type) LOOP
       RETURN cur.daytime;
    END LOOP;

    RETURN NULL;
    */

     FOR cur IN c_per(p_country_id, p_company_id, p_booking_area_code, p_period_type) LOOP

             IF cur.daytime = lv2_daytime THEN

                ld_temp_val := cur.daytime;
                EXIT; -- got it

             ELSIF cur.daytime < lv2_daytime THEN -- Less than

                ld_temp_val := cur.daytime;
                EXIT; -- got it

             ELSE -- greater than

                IF ld_temp_val IS NULL THEN

                   -- take it
                  ld_temp_val := cur.daytime;

                ELSE

                    IF Abs(cur.daytime - ld_temp_val) > Abs(cur.daytime - lv2_daytime) THEN

                       ld_temp_val := cur.daytime; -- this period is closer

                    END IF;

                END IF;

                EXIT; -- got it

             END IF;

         END LOOP;



   IF  ( p_booking_area_code IN ('SALE','PURCHASE','TA_INCOME','TA_COST','JOU_ENT')
          AND ec_ctrl_system_attribute.attribute_text(lv2_daytime,'DEFAULT_BOOKING_PERIOD','<=') = 'OLDEST_OPEN'
        )
      OR
      ( p_booking_area_code='QUANTITIES'
       )
      OR
      ( p_booking_area_code IN ('SALE','PURCHASE','TA_INCOME','TA_COST','JOU_ENT')
        AND ec_ctrl_system_attribute.attribute_text(lv2_daytime,'DEFAULT_BOOKING_PERIOD','<=') = 'BY_DOC_DATE'
        AND ec_ctrl_system_attribute.attribute_text(lv2_daytime,'ALIGN_REPORTING_BOOKING','<=') = 'N'
        AND p_period_type='REPORTING'
       )
       OR (p_booking_area_code='INVENTORY'
       )
    THEN

         ld_return_val := ld_temp_val;

    ELSIF
       ( p_booking_area_code IN ('SALE','PURCHASE','TA_INCOME','TA_COST','JOU_ENT')
        AND ec_ctrl_system_attribute.attribute_text(lv2_daytime,'DEFAULT_BOOKING_PERIOD','<=') = 'BY_DOC_DATE'
       )
      OR
       (p_booking_area_code IN ('SALE','PURCHASE','TA_INCOME','TA_COST','JOU_ENT')
        AND (ec_ctrl_system_attribute.attribute_text(lv2_daytime,'DEFAULT_BOOKING_PERIOD','<=') = 'BY_DOC_DATE')
        AND ec_ctrl_system_attribute.attribute_text(lv2_daytime,'ALIGN_REPORTING_BOOKING','<=') = 'Y'
        AND p_period_type='REPORTING'
       )
    THEN
          IF p_doc_date is null then
            ld_doc_date := ec_cont_document.document_date(p_doc_key);
          else
            ld_doc_date := p_doc_date;
          end if;

          IF ld_temp_val <= ld_doc_date THEN
              ld_return_val := ld_doc_date;
           ELSE
             ld_return_val := ld_temp_val;
           END IF;

    END IF;

     RETURN ld_return_val;

END getCurrentOpenPeriod;

FUNCTION getCurrOpenPeriodByObject (
 p_object_id VARCHAR2,
 p_daytime DATE,
 p_booking_area_code VARCHAR2,
 p_period_type VARCHAR2 DEFAULT 'BOOKING',
 p_doc_key VARCHAR2 DEFAULT NULL,
 p_doc_date DATE DEFAULT NULL)
RETURN DATE
IS

CURSOR c_company(cp_daytime DATE, cp_country_id VARCHAR2) IS
SELECt o.object_id
FROM COMPANY_VERSION oa, COMPANY o
WHERE oa.object_id = o.object_id
AND o.class_name='COMPANY'
AND oa.country_id = cp_country_id
AND cp_daytime >= Nvl(o.start_date,cp_daytime-1)
AND cp_daytime < Nvl(o.end_date,cp_daytime+1)
AND o.object_code like '%FULL%'
;

lv2_country_id VARCHAR(32);
lv2_company_id VARCHAR(32);
lv2_booking_area_code VARCHAR(32);
ld_curr_open_period DATE;

BEGIN

    IF p_booking_area_code IS NULL THEN
       lv2_booking_area_code := ec_contract_version.financial_code(p_object_id, p_daytime, '<=');
    ELSE
       lv2_booking_area_code := p_booking_area_code;
    END IF;

       lv2_company_id := getCompanyIdByAreaCode(p_object_id, p_daytime, lv2_booking_area_code);
       lv2_country_id := ec_company_version.country_id(lv2_company_id, p_daytime, '<=');


    ld_curr_open_period := getCurrentOpenPeriod(lv2_country_id, lv2_company_id, lv2_booking_area_code, p_period_type,p_doc_key,p_doc_date);

    IF ld_curr_open_period IS NULL THEN
       --GET THE FULL company period if it is null
       FOR cur IN c_company(p_daytime, lv2_country_id) LOOP
           lv2_company_id := cur.object_id;
       END LOOP;
       ld_curr_open_period := getCurrentOpenPeriod(lv2_country_id, lv2_company_id, lv2_booking_area_code, p_period_type,p_doc_key,p_doc_date);
    END IF;

    RETURN ld_curr_open_period;

END getCurrOpenPeriodByObject;


FUNCTION getCompanyIdByAreaCode(
 p_object_id VARCHAR2,
 p_daytime DATE,
 p_booking_area_code VARCHAR2
)
RETURN VARCHAR2
IS

 lv2_company_id VARCHAR(32);
 lv2_booking_area_code VARCHAR(32);

BEGIN

    IF p_booking_area_code IS NULL THEN
       lv2_booking_area_code := ec_contract_version.financial_code(p_object_id, p_daytime, '<=');
    ELSE
       lv2_booking_area_code := p_booking_area_code;
    END IF;

    IF lv2_booking_area_code IN ('SALE','PURCHASE','TA_INCOME','TA_COST','JOU_ENT') THEN

       lv2_company_id := ec_contract_version.company_id(p_object_id, p_daytime, '<=');

    ELSIF lv2_booking_area_code = 'INVENTORY' THEN

       lv2_company_id := ec_inventory_version.company_id(p_object_id, p_daytime, '<=');

    ELSIF lv2_booking_area_code = 'QUANTITIES' THEN

       lv2_company_id := ec_stream_item_version.company_id(p_object_id, p_daytime, '<=');

    END IF;

       RETURN lv2_company_id;

END getCompanyIdByAreaCode;

FUNCTION chkPeriodExistByObject (
 p_object_id VARCHAR2,
 p_daytime DATE,
 p_document_date DATE,
 p_booking_area_code VARCHAR2,
 p_period_type VARCHAR2 DEFAULT 'BOOKING')
RETURN DATE
IS

CURSOR c_company(cp_daytime DATE, cp_country_id VARCHAR2) IS
SELECt o.object_id
FROM COMPANY_VERSION oa, COMPANY o
WHERE oa.object_id = o.object_id
AND o.class_name='COMPANY'
AND oa.country_id = cp_country_id
AND cp_daytime >= Nvl(o.start_date,cp_daytime-1)
AND cp_daytime < Nvl(o.end_date,cp_daytime+1)
AND o.object_code like '%FULL%';

CURSOR c_chk(cp_country_id VARCHAR2, cp_company_id VARCHAR2, cp_booking_area_code VARCHAR2, cp_daytime DATE) IS
SELECT daytime
FROM system_mth_status
WHERE country_id = cp_country_id
AND company_id = cp_company_id
AND booking_area_code = cp_booking_area_code
AND daytime = trunc(cp_daytime,'month');

lv2_country_id VARCHAR(32);
lv2_company_id VARCHAR(32);
lv2_booking_area_code VARCHAR(32);
ld_open_period DATE;

BEGIN

    IF p_booking_area_code IS NULL THEN
       lv2_booking_area_code := ec_contract_version.financial_code(p_object_id, p_daytime, '<=');
    ELSE
       lv2_booking_area_code := p_booking_area_code;
    END IF;

       lv2_company_id := getCompanyIdByAreaCode(p_object_id, p_daytime, lv2_booking_area_code);
       lv2_country_id := ec_company_version.country_id(lv2_company_id, p_daytime, '<=');

     FOR cur IN c_chk(lv2_country_id, lv2_company_id, lv2_booking_area_code,p_document_date) LOOP
           ld_open_period := cur.daytime;
     END LOOP;

    IF ld_open_period IS NULL THEN
       --GET THE FULL company period if it is null
       FOR cur IN c_company(p_daytime, lv2_country_id) LOOP
           lv2_company_id := cur.object_id;
       END LOOP;
       FOR cur IN c_chk(lv2_country_id, lv2_company_id, lv2_booking_area_code, p_document_date) LOOP
           ld_open_period := cur.daytime;
       END LOOP;
    END IF;

    RETURN ld_open_period;

END chkPeriodExistByObject;

END EcDp_Fin_Period;