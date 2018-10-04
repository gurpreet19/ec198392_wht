CREATE OR REPLACE PACKAGE BODY EcDp_Payment_Scheme IS
/****************************************************************
** Package        :  EcDp_Payment_Scheme, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Provide functionality to handle validation and population of Payment Schemes
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.06.2007  Stian Skj?tad
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
*******************************************************************************************************************************/



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : AddYear
-- Description    : Populate the table payment_scheme_item with the combination of item_no, daytime and payment scheme (object_id)
--
-- Preconditions  : A Payment Scheme object must be available
--
-- Postconditions :
--
-- Using tables   : payment_scheme_item
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE AddYear(p_object_id VARCHAR2,
                  p_daytime   DATE,
                  p_year      NUMBER,
                  p_user      VARCHAR2)
IS

ld_year DATE;
ld_start_date DATE;
ld_end_date DATE;
ld_ps_start_date DATE := ec_payment_scheme.start_date(p_object_id);
ld_ps_end_date DATE := ec_payment_scheme.end_date(p_object_id);
ld_max_instantiated_year DATE;
ln_no_of_months INTEGER;
ln_iterator INTEGER;
ld_current DATE;
ld_daytime DATE := p_daytime;
lv2_weekday VARCHAR2(16);
ln_already_exists NUMBER := 0;

already_added EXCEPTION;
too_early_year EXCEPTION;
too_late_year EXCEPTION;
not_valid_year EXCEPTION;

BEGIN

     -- Checks if p_year is a four digit number.
     IF (length(p_year) <> 4) THEN

       RAISE not_valid_year;

     END IF;

     IF (p_year < 0) THEN

        RAISE not_valid_year;

     END IF;

     ld_year := to_date(p_year,'yyyy');

     -- Start date is initially set to January 1st of year p_year.
     ld_start_date := trunc(ld_year,'YYYY');

     -- End date is initially set to December 31st of year p_year.
     ld_end_date := trunc(add_months(ld_year,12),'YYYY')-1;

     -- If payment scheme object is not valid on ld_start_date, but is valid later the same year,
     -- ld_start_date is set to the object's start_date.
     IF ((ld_ps_start_date > ld_start_date) AND (trunc(ld_ps_start_date,'yyyy') = ld_start_date)) THEN

       ld_start_date := ld_ps_start_date;

     -- If payment scheme object does not start later the same year as ld_start_date,
     -- Exception is raised.
     ELSIF (trunc(ld_ps_start_date,'yyyy') > ld_start_date) THEN

       RAISE too_early_year;

     END IF;

     -- Corresponding checks for end_date.
     IF ((ld_ps_end_date < ld_end_date) AND (trunc(ld_ps_end_date,'yyyy') = trunc(ld_end_date,'yyyy'))) THEN

       ld_end_date := ld_ps_end_date;

     ELSIF (trunc(ld_ps_end_date,'yyyy') < trunc(ld_end_date,'yyyy')) THEN

       RAISE too_late_year;

     END IF;

     -- If no attributes are valid on p_daytime,
     -- the payment scheme object's start_date is used.
     IF (ld_daytime < ld_ps_start_date) THEN

       ld_daytime := ld_ps_start_date;

     END IF;

     -- Checks if p_year is already instantiated.
     SELECT count(*)
     INTO ln_already_exists
     FROM payment_scheme_prod_mth
     WHERE year = p_year
     and object_id = p_object_id;

     -- Checks if new days should be added even if year already instantiated
     SELECT max(daytime)
     INTO ld_max_instantiated_year
     FROM payment_scheme_prod_mth
     WHERE year = p_year
     AND object_id = p_object_id;

     -- right of and: checks if instantiated until end_date of object and checks if instantiated until last day of year inclusive.
     IF ln_already_exists > 0 AND (ld_max_instantiated_year = trunc(ld_ps_end_date,'MM') OR (ld_max_instantiated_year = add_months(trunc(to_date(p_year,'yyyy'),'yyyy'),11))) THEN

        RAISE already_added;

     END IF;

     -- If last test was passed, new months should be instantiated.
     IF ld_max_instantiated_year IS NOT NULL THEN

        ld_start_date := add_months(ld_max_instantiated_year,1);

     END IF;

     ln_no_of_months := months_between(ld_end_date,ld_start_date);

     -- Inserts the correct number of months
     FOR ln_iterator in 0..ln_no_of_months-1 LOOP

        ld_current := trunc(add_months(ld_start_date,ln_iterator),'MM');


        INSERT INTO payment_scheme_prod_mth
          (object_id,
           daytime,
           year,
           created_by

           )
        VALUES
          (p_object_id, ld_current, p_year, p_user);


     END LOOP;

EXCEPTION

     WHEN already_added THEN
              Raise_Application_Error(-20000, 'Year ' || p_year || ' is already added to the setup for ' || ec_payment_scheme_version.name(p_object_id, p_daytime,'<=') || '.');

     WHEN too_early_year THEN
              Raise_Application_Error(-20000, ec_payment_scheme_version.name(p_object_id, p_daytime,'<=') || ' is not valid before ' || to_char(ld_ps_start_date,'dd.mm.yyyy') ||'.');

     WHEN too_late_year THEN
              Raise_Application_Error(-20000, ec_payment_scheme_version.name(p_object_id, p_daytime,'<=') || ' is not valid after ' || to_char(ld_ps_end_date,'dd.mm.yyyy') ||'.');

     WHEN not_valid_year THEN
              Raise_Application_Error(-20000, p_year || ' is not a valid year.');

END AddYear;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : DelObj
-- Description    : Deletes from table payment_scheme_prod_mth when deleting the payment scheme object itself
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : payment_scheme_prod_mth
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE DelObj(p_object_id VARCHAR2, p_end_date DATE)

IS

ld_start_date DATE;

BEGIN

ld_start_date := ec_payment_scheme.start_date(p_object_id);


IF p_end_date = ld_start_date THEN
   -- Deleting reference
   delete from payment_scheme_prod_mth i where i.object_id = p_object_id;
END IF;

END DelObj;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : GetDaysLateTotal
-- Description    : Return the total number of days paid to late shared amoung all payments from a payment scheme
--
-- Preconditions  :
--
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
-------------------------------------------------------------------------------------------------
FUNCTION GetDaysLateTotal(p_object_id    VARCHAR2,
                          p_document_key VARCHAR2,
                          p_customer_id  VARCHAR2)
RETURN NUMBER
--</EC-DOC>



IS

ln_result                 NUMBER;

BEGIN


SELECT SUM(GREATEST(NVL(ct.pay_received_date, ct.pay_date) - ct.pay_date, 0))
  INTO ln_result
  FROM cont_pay_tracking_item ct
 WHERE ct.object_id = p_object_id
   AND ct.document_key = p_document_key
   AND ct.customer_id = p_customer_id;


RETURN nvl(ln_result,0);


END GetDaysLateTotal;





--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : GetBookedTotalMinusFixedV
-- Description    : Returns the booked total that are subject for payment scheme calculation and subtracts all
--                  fixed payment items found.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : payment_scheme_prod_mth
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION GetBookedTotalMinusFixedV(p_object_id    VARCHAR2,
                                    p_booked_total NUMBER,
                                    p_prod_mth     DATE)
RETURN NUMBER
--</EC-DOC>
IS

ln_return_v NUMBER;

CURSOR c_ps IS
SELECT SUM(nvl(p.item_value,0)) item_v
  FROM payment_scheme_item p
 WHERE p.object_id = p_object_id
   AND p.prod_mth = p_prod_mth;

BEGIN

-- Need to handle negative doc booking values.
FOR v IN c_ps LOOP
-- ln_return_v := abs(p_booked_total)-nvl(v.item_v,0);
 ln_return_v := p_booked_total-nvl(v.item_v,0);
END LOOP;


RETURN ln_return_v;
END GetBookedTotalMinusFixedV;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : WritePayTrackItems
-- Description    : Writes the payment tracking items based on the payment scheme configured on document setup
--
-- Preconditions  :
--
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
-------------------------------------------------------------------------------------------------
PROCEDURE WritePayTrackItems(p_object_id           VARCHAR2,
                             p_document_key        VARCHAR2,
                             p_payment_scheme_id   VARCHAR2,
                             p_document_type       VARCHAR2,
                             p_valid1_user_id      VARCHAR2,
                             p_owner_company_id    VARCHAR2,
                             p_customer_id         VARCHAR2,
                             p_vendor_id           VARCHAR2,
                             p_booking_currency_id VARCHAR2,
                             p_doc_booking_total   NUMBER,
                             p_contract_reference  VARCHAR2,
                             p_daytime             DATE)


IS

ln_item_no    NUMBER;
lv2_country_id VARCHAR2(32) := NULL;
lv2_booking_area_code VARCHAR2(32) := NULL;
ld_booking_period DATE := NULL;
ln_cpi_count NUMBER := 0;
ln_precision NUMBER := 2;
lv2_where VARCHAR2(2000);

CURSOR c_ps_validate (cp_object_id VARCHAR2) IS
SELECT p.item_no
  FROM payment_scheme_item p
 WHERE p.object_id = cp_object_id
   AND p.prod_mth = (SELECT MAX(TRUNC(ct.transaction_date, 'MM')) production_month
                       FROM cont_transaction ct
                      WHERE ct.document_key = p_document_key)
   AND p.value_type = 'FRACTION'
   AND EXISTS (SELECT 1
          FROM payment_scheme_item ps
         WHERE ps.object_id = cp_object_id
           AND ps.prod_mth =
               (SELECT MAX(TRUNC(ct.transaction_date, 'MM')) production_month
                  FROM cont_transaction ct
                 WHERE ct.document_key = p_document_key)
           AND ps.value_type = 'SHARE'
           AND ps.item_no <> p.item_no);


CURSOR c_ps (cp_object_id VARCHAR2, cp_book_total NUMBER, cp_booking_period DATE) IS
SELECT p.daytime,
       p.value_type,
       decode(p.value_type,'FRACTION',((p.frac_num/p.frac_denom)*GetBookedTotalMinusFixedV(cp_object_id,cp_book_total,p.prod_mth))+nvl(p.item_value,0),'SHARE',(p.item_share*GetBookedTotalMinusFixedV(cp_object_id,cp_book_total,p.prod_mth))+nvl(p.item_value,0),'VALUE',p.item_value) val,
       p.description
  FROM payment_scheme_item p
 WHERE p.object_id = cp_object_id
   AND p.prod_mth = cp_booking_period;

BEGIN

INSERT INTO CONT_PAY_TRACKING
  (OBJECT_ID,
   DOCUMENT_KEY,
   CUSTOMER_ID,
   PAY_DATE,
   INVOICED_AMOUNT,
   CURRENCY_CODE,
   CURRENCY_ID,
   DOCUMENT_TYPE,
   PRODUCT_GROUP_CODE,
   CONTRACT_AREA_CODE,
   CONTRACT_REFERENCE,
   CONTRACT_OWNER_ID,
   VENDOR_ID,
   VALID1_USER_ID)
VALUES
  (p_object_id,
   p_document_key,
   p_customer_id,
   ec_cont_document_company.due_date(p_document_key,p_customer_id),
   p_doc_booking_total,
   ec_currency.object_code(p_booking_currency_id),
   p_booking_currency_id,
   p_document_type,
   ec_contract_version.product_type(p_object_id, p_daytime, '<='),
   ec_contract_area.object_code(ec_contract_version.contract_area_id(p_object_id,p_daytime,'<=')),
   p_contract_reference,
   p_owner_company_id,
   p_vendor_id,
   p_valid1_user_id);


IF p_payment_scheme_id IS NULL THEN

   EcDp_System_Key.assignNextNumber('CONT_PAY_TRACKING_ITEM', ln_item_no);

   INSERT INTO CONT_PAY_TRACKING_ITEM
     (ITEM_NO,
      OBJECT_ID,
      DOCUMENT_KEY,
      CUSTOMER_ID,
      INVOICED_AMOUNT,
      booking_currency_code,
      PAY_DATE,
      PAY_RECEIVED,
      IS_SYSTEM_GENERATED)
   VALUES
     (ln_item_no,
      p_object_id,
      p_document_key,
      p_customer_id,
      p_doc_booking_total,
      ec_cont_pay_tracking.currency_code(p_document_key,p_customer_id),
      ec_cont_document_company.due_date(p_document_key,p_customer_id),
      0,
      'Y');

ELSE

   FOR c_validate IN c_ps_validate (p_payment_scheme_id) LOOP
       Raise_Application_Error(-20000,'Cannot use both share and fraction items on the same combination of production month on payment scheme '||ec_payment_scheme_version.name(p_Payment_Scheme_Id,p_daytime,'<='));
   END LOOP;

   -- Get current open booking period
   lv2_country_id := ec_company_version.country_id(p_owner_company_id, p_daytime, '<=');
   lv2_booking_area_code := ec_contract_version.financial_code(p_object_id, p_daytime, '<=');
   ld_booking_period := ecdp_fin_period.getCurrentOpenPeriod(lv2_country_id, p_owner_company_id, lv2_booking_area_code, 'BOOKING');



-- If a payment scheme object is configured, then valid records should be available at item level.
-- If this is not the case, either configuration or instantiation is missing.
  SELECT count(*)
    INTO ln_cpi_count
    FROM payment_scheme_item
   WHERE object_id = p_payment_scheme_id
     AND prod_mth = ld_booking_period;

     IF nvl(ln_cpi_count,0) = 0 THEN
        Raise_Application_Error(-20000,'The Payment scheme ('||ec_payment_scheme_version.name(p_Payment_Scheme_Id,p_daytime,'<=')||') does not have any payment scheme items where production month match the current open booking period ('||ld_booking_period||')');
     END IF;


   FOR c_p IN c_ps (p_payment_scheme_id, p_doc_booking_total, ld_booking_period) LOOP


       EcDp_System_Key.assignNextNumber('CONT_PAY_TRACKING_ITEM', ln_item_no);



       INSERT INTO CONT_PAY_TRACKING_ITEM
         (ITEM_NO,
          OBJECT_ID,
          DOCUMENT_KEY,
          CUSTOMER_ID,
          INVOICED_AMOUNT,
          PAY_DATE,
          PAY_RECEIVED,
          booking_currency_code,
          value_type,
          description)
       VALUES
         (ln_item_no,
          p_object_id,
          p_document_key,
          p_customer_id,
          ROUND(c_p.val,ln_precision), -- Adding proper rounding
          c_p.daytime,
          0,
          ec_cont_pay_tracking.currency_code(p_document_key,p_customer_id),
          c_p.value_type,
          c_p.description);

      END LOOP;

      -- Running some code to make sure the sum of payments still equals the document booking total value
      FOR c_p IN c_ps (p_payment_scheme_id, p_doc_booking_total, ld_booking_period) LOOP
        lv2_where := ' DOCUMENT_KEY = ''' || p_document_key || ''' AND CUSTOMER_ID = ''' || p_customer_id || '''';
        EcDp_Contract_Setup.GenericRounding('CONT_PAY_TRACKING_ITEM','INVOICED_AMOUNT',p_doc_booking_total,lv2_where);
      END LOOP;




END IF;

END WritePayTrackItems;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : getDaysOverdue
-- Description    : Return the total number of from due date to current date (sysdate)
--
-- Preconditions  :
--
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
-------------------------------------------------------------------------------------------------
FUNCTION getDaysOverdue(p_date DATE)
RETURN NUMBER
IS
  ln_days NUMBER;
  ld_current_date DATE := trunc(Ecdp_Timestamp.getCurrentSysdate(),'DD');
BEGIN

 IF ld_current_date > p_date THEN
    ln_days := ld_current_date - p_date;
 ELSE
    ln_days := 0;
 END IF;

 return ln_days;

END getDaysOverdue;

END EcDp_Payment_Scheme;