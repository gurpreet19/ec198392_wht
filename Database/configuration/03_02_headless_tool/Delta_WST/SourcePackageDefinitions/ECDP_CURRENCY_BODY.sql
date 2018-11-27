CREATE OR REPLACE PACKAGE BODY EcDp_Currency IS
/****************************************************************
** Package        :  EcDp_Currency
**
** $Revision: 1.14 $
**
** Purpose        :  Finds, generate and aggregate sale forecast data.
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.12.2004  Tor-Erik Hauge
**
** Modification history:
**
** Date       Whom       Change description:
** --------   -----     --------------------------------------
** 16.12.04   HaugeTor   Initial version
** 25.09.06   DN         Modified function getExchangeRate to cope with currency as object and time scope.
** 10.10.06   DN         Migrated convertViaCurrency and GetExRateViaCurrency from EC Revenue.
** 02.05.07   ChongJer   Updated functions with forex_source_id parameter
** 04.05.07   ChongJer   Updated GetExRateViaCurrency to take fallback method into consideration
******************************************************************/

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : getExchangeRate
-- Description    : Returns the exchange rate between parameter from_currency and to_currency
--                                      valid at daytime p_daytime. I.e if from_currency = USD and
--                  to_currency = NOK the 1 USD = x NOK, the value x is returned
--                                      Returns 0 if no exchange rate exist
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : currency_exchange
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : If time scope is not provided just use the previous record.
--
--------------------------------------------------------------------------------------------------
FUNCTION getExchangeRate(p_daytime            DATE,
                         p_from_currency_code VARCHAR2, -- Code
                         p_to_currency_code   VARCHAR2, -- Code
                         p_forex_source_id    VARCHAR2,
                         p_time_scope         VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_prev_equal_daytime(cp_from_currency_id VARCHAR2, cp_to_currency_id VARCHAR2, cp_daytime DATE) IS
SELECT *
FROM currency_exchange ce
WHERE ce.object_id = cp_from_currency_id
AND ce.currency_id = cp_to_currency_id
AND ce.daytime = (
 SELECT MAX(cp.daytime)
 FROM currency_exchange cp
 WHERE cp.object_id = ce.object_id
 AND cp.currency_id = ce.currency_id
 AND cp.daytime <= cp_daytime
);

     lv2_from_currency_id    VARCHAR2(32);
     lv2_to_currency_id      VARCHAR2(32);
     lv2_time_scope          VARCHAR2(32);
     ln_rate                 NUMBER;
     ld_pd                   DATE;
     ld_pd_inv               DATE;


BEGIN

   lv2_from_currency_id := ec_currency.object_id_by_uk(p_from_currency_code);

   lv2_to_currency_id := ec_currency.object_id_by_uk(p_to_currency_code);

   IF p_time_scope IS NULL THEN

      FOR cur_rec3 IN c_prev_equal_daytime(lv2_from_currency_id, lv2_to_currency_id, p_daytime) LOOP
          ld_pd := cur_rec3.daytime;
          lv2_time_scope := cur_rec3.time_scope;
      END LOOP;

      FOR cur_rec4 IN c_prev_equal_daytime(lv2_to_currency_id, lv2_from_currency_id, p_daytime) LOOP
          ld_pd_inv := cur_rec4.daytime;
          lv2_time_scope := cur_rec4.time_scope;
          -- Time scope should be the same as above
      END LOOP;

   ELSE

      lv2_time_scope := p_time_scope;
      ld_pd := ec_currency_exchange.prev_equal_daytime(lv2_from_currency_id, lv2_to_currency_id, lv2_time_scope, p_daytime, p_forex_source_id);
      ld_pd_inv := ec_currency_exchange.prev_equal_daytime(lv2_to_currency_id, lv2_from_currency_id, lv2_time_scope, p_daytime, p_forex_source_id);

   END IF;

   IF nvl(ld_pd,nvl(ld_pd_inv - 1,p_daytime)) < nvl(ld_pd_inv,nvl(ld_pd - 1, p_daytime)) THEN
      ln_rate := 1/ec_currency_exchange.rate(lv2_to_currency_id, lv2_from_currency_id, lv2_time_scope, p_daytime, p_forex_source_id, '<=');
   ELSE
      ln_rate := ec_currency_exchange.rate(lv2_from_currency_id, lv2_to_currency_id, lv2_time_scope, p_daytime, p_forex_source_id, '<=');
   END IF;

   RETURN ln_rate;

END getExchangeRate;


--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : convert
-- Description    : Returns a value that is the p_ammount in p_from_currency_code converted to units
-- of p_to_currency_code using the exchange_rate between the from and to currency valid at the given
-- p_daytime
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: getExchangeRate
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
----------------------------------------------------------------------------------------------------
FUNCTION convert(p_daytime            DATE,
                 p_amount             NUMBER,
                 p_from_currency_code VARCHAR2,
                 p_to_currency_code   VARCHAR2,
                 p_forex_source_id    VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
  ln_rate NUMBER;
BEGIN

   ln_rate := getExchangeRate(p_daytime, p_from_currency_code, p_to_currency_code, p_forex_source_id);

   RETURN ln_rate * p_amount;

END convert;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : convertViaCurrency
-- Description    : Returns a converted value based on factors in curr_exchange.
--
-- Preconditions  : Currency parameters are codes
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: GetExRateViaCurrency
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION convertViaCurrency(p_input_val       NUMBER,
                            p_from_curr_code  VARCHAR2,
                            p_to_curr_code    VARCHAR2,
                            p_via_curr_code   VARCHAR2,
                            p_daytime         DATE,
                            p_forex_source_id VARCHAR2,               --forex source
                            p_duration        VARCHAR2 DEFAULT 'DAILY') --forex time scope
RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   IF p_from_curr_code = p_to_curr_code THEN

      ln_return_val := p_input_val; -- no conversion required

   ELSE

      ln_return_val := p_input_val * GetExRateViaCurrency(p_from_curr_code, p_to_curr_code, p_via_curr_code, p_daytime, p_forex_source_id, p_duration);

   END IF;

   RETURN ln_return_val;

END convertViaCurrency;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetExRateViaCurrency
-- Description    : Returns a converted value based on factors in currency_exchange.
--
-- Preconditions  :  Currency parameters are codes
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_currency_exchange
--
-- Configuration
-- required       :
--
-- Behaviour      : GetExRateViaCurrency recursive.
--
---------------------------------------------------------------------------------------------------
FUNCTION GetExRowViaCurrency(p_from_curr_code  VARCHAR2,
                             p_to_curr_code    VARCHAR2,
                             p_via_curr_code   VARCHAR2,
                             p_daytime         DATE,
                             p_forex_source_id VARCHAR2, --forex source
                             p_duration        VARCHAR2 DEFAULT 'DAILY', --forex time scope
                             p_operator        VARCHAR2 DEFAULT '<=')
RETURN CURRENCY_EXCHANGE%ROWTYPE
--</EC-DOC>
IS

ln_return_val currency_exchange%ROWTYPE;
ln_factor1 NUMBER;
ld_factor1_date DATE;
ld_factor2_date DATE;
ln_factor2 NUMBER;
lv2_via_curr          currency.object_code%TYPE;
lv2_via_curr_id       currency.object_id%TYPE;
lv2_from_currrency_id currency.object_id%TYPE;
lv2_to_currency_id    currency.object_id%TYPE;
lv2_fallback VARCHAR2(32);
ld_daytime DATE;
lr_rec_local currency_exchange%ROWTYPE;

BEGIN

   lv2_via_curr_id := ec_currency.object_id_by_uk(p_via_curr_code);
   lv2_from_currrency_id := ec_currency.object_id_by_uk(p_from_curr_code);
   lv2_to_currency_id := ec_currency.object_id_by_uk(p_to_curr_code);

   -- check for fallback method
   lv2_fallback := ec_forex_source_setup.fallback(p_forex_source_id, p_duration, p_daytime, '<=');

   -- make monthly daytime to first of month
   -- ECPD-30878: making it possible to use several daily time scopes, like rounded daily rates (RND_DAILY)
   -- This is a 11_0-SP02 specific solution. Better handling of time scope / forex type.
   IF p_duration NOT LIKE '%DAILY%' THEN
      ld_daytime := trunc(p_daytime, 'MONTH');
   ELSE
      ld_daytime := p_daytime;
   END IF;

   IF p_from_curr_code = p_to_curr_code THEN

      ln_return_val.rate := 1; -- no conversion required
      ln_return_val.daytime := p_daytime;

   ELSE

      IF p_via_curr_code IS NOT NULL THEN

         -- try direct convert to 3rd currency
         IF lv2_fallback = 'NO_FALLBACK' THEN -- getting only exact exchange rate

            ln_factor1 := ec_currency_exchange.rate(lv2_from_currrency_id, lv2_via_curr_id, p_duration, ld_daytime, p_forex_source_id, '=');

         ELSIF lv2_fallback = 'LAST_AVAILABLE' THEN -- getting exact exchange rate (p_operator is '=') or use latest available (p_operator is '<=')

              ln_factor1 := ec_currency_exchange.rate(lv2_from_currrency_id, lv2_via_curr_id, p_duration, ld_daytime, p_forex_source_id, p_operator);
              ld_factor1_date := ec_currency_exchange.prev_equal_daytime(lv2_from_currrency_id, lv2_via_curr_id, p_duration, ld_daytime, p_forex_source_id);

         END IF;

         -- try inverse convert to 3rd currency
         lr_rec_local := ec_currency_exchange.row_by_pk(lv2_via_curr_id, lv2_from_currrency_id, p_duration, ld_daytime, p_forex_source_id, p_operator);

         IF ln_factor1 IS NULL OR (ld_factor1_date IS NOT NULL AND ld_factor1_date > nvl(lr_rec_local.daytime,ld_factor1_date+1))  THEN

            IF lv2_fallback = 'NO_FALLBACK' THEN -- getting only exact exchange rate

               ln_factor1 := ec_currency_exchange.rate(lv2_via_curr_id, lv2_from_currrency_id, p_duration, ld_daytime, p_forex_source_id, '=');

            ELSIF lv2_fallback = 'LAST_AVAILABLE' THEN -- getting exact exchange rate (p_operator is '=') or use latest available (p_operator is '<=')

                 ln_factor1 := lr_rec_local.rate;

            END IF;

            IF ln_factor1 IS NOT NULL AND ln_factor1 != 0 THEN

               -- get inverse
               ln_factor1 := 1/ln_factor1;

            END IF;

         END IF;


         -- try direct convert to target currency
         IF lv2_fallback = 'NO_FALLBACK' THEN -- getting only exact exchange rate

            ln_factor2 := ec_currency_exchange.rate(lv2_via_curr_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id, '=');

         ELSIF lv2_fallback = 'LAST_AVAILABLE' THEN -- getting exact exchange rate (p_operator is '=') or use latest available (p_operator is '<=')

              ln_factor2 := ec_currency_exchange.rate(lv2_via_curr_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id, p_operator);
              ld_factor2_date := ec_currency_exchange.prev_equal_daytime(lv2_via_curr_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id);

         END IF;

         -- try inverse convert to target currency
         lr_rec_local := ec_currency_exchange.row_by_pk(lv2_to_currency_id, lv2_via_curr_id, p_duration, ld_daytime, p_forex_source_id, p_operator);

         IF ln_factor2 IS NULL OR (ld_factor2_date IS NOT NULL AND ld_factor2_date > nvl(lr_rec_local.daytime,ld_factor2_date+1)) THEN

            IF lv2_fallback = 'NO_FALLBACK' THEN -- getting only exact exchange rate

               ln_factor2 := ec_currency_exchange.rate(lv2_to_currency_id, lv2_via_curr_id, p_duration, ld_daytime, p_forex_source_id, '=');

            ELSIF lv2_fallback = 'LAST_AVAILABLE' THEN -- getting exact exchange rate (p_operator is '=') or use latest available (p_operator is '<=')

                 ln_factor2 := lr_rec_local.rate;

            END IF;

            IF ln_factor2 IS NOT NULL AND ln_factor2 != 0 THEN

               -- get inverse
               ln_factor2 := 1/ln_factor2;

            END IF;

         END IF;

         ln_return_val.Rate := ln_factor1 * ln_factor2;

      ELSE

         -- try direct convert (source -> target) currency
         IF lv2_fallback = 'NO_FALLBACK' THEN -- getting only exact exchange rate

            ln_return_val := ec_currency_exchange.row_by_pk(lv2_from_currrency_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id, '=');

            -- try inverse convert (target -> source) currency
            IF ln_return_val.rate IS NULL THEN
               ln_return_val := ec_currency_exchange.row_by_pk(lv2_to_currency_id, lv2_from_currrency_id, p_duration, ld_daytime, p_forex_source_id, '=');

               IF ln_return_val.rate IS NOT NULL AND ln_return_val.rate != 0 THEN
                  -- get inverse
                  ln_return_val.rate := 1/ln_return_val.rate;
               END IF;

            END IF;

            -- if cannot get exact exchange rate, try to get exchange rate using triangulation method
            IF ln_return_val.rate IS NULL THEN

               lv2_via_curr := ec_ctrl_system_attribute.attribute_text(ld_daytime, 'FX_TRIANGULATE_CURR_CODE', '<=');

               IF lv2_via_curr IS NULL THEN

                  lv2_via_curr := 'EUR'; -- default currency

               END IF;

               -- recursive call (using exact exchange rate, p_operator is '=')
               ln_return_val := GetExRowViaCurrency(p_from_curr_code, p_to_curr_code ,lv2_via_curr, ld_daytime, p_forex_source_id, p_duration, '=');

            END IF;


         ELSIF lv2_fallback = 'LAST_AVAILABLE' THEN -- getting exact exchange rate if available, else use latest available

              -- try to get exact exchange rate (source -> target)
              ln_return_val := ec_currency_exchange.row_by_pk(lv2_from_currrency_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id, '=');

              -- try inverse exact exchange rate (target -> source)
              IF ln_return_val.rate IS NULL THEN
                 ln_return_val := ec_currency_exchange.row_by_pk(lv2_to_currency_id, lv2_from_currrency_id, p_duration, ld_daytime, p_forex_source_id, '=');

                 IF ln_return_val.rate IS NOT NULL AND ln_return_val.rate != 0 THEN
                    -- get inverse
                    ln_return_val.rate := 1/ln_return_val.rate;
                 END IF;

              END IF;

              -- if cannot get exact exchange rate, try to get exchange rate using triangulation method
              IF ln_return_val.rate IS NULL THEN

                 lv2_via_curr := ec_ctrl_system_attribute.attribute_text(ld_daytime, 'FX_TRIANGULATE_CURR_CODE', '<=');

                 IF lv2_via_curr IS NULL THEN

                    lv2_via_curr := 'EUR'; -- default currency

                 END IF;

                 -- recursive call (using exact exchange rate, p_operator is '=')
                 ln_return_val := GetExRowViaCurrency(p_from_curr_code, p_to_curr_code ,lv2_via_curr, ld_daytime, p_forex_source_id, p_duration, '=');

              END IF;

              -- if cannot get exact exchange rate, no exact result from triangulation method, try last available direct (source -> target)
              IF ln_return_val.rate IS NULL THEN
                 ln_return_val := ec_currency_exchange.row_by_pk(lv2_from_currrency_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id, '<=');
              END IF;

              -- try inverse last available exchange rate (target -> source)
              lr_rec_local := null;
              lr_rec_local := ec_currency_exchange.row_by_pk(lv2_to_currency_id, lv2_from_currrency_id, p_duration, ld_daytime, p_forex_source_id, '<=');

              IF ln_return_val.rate IS NULL OR (lr_rec_local.daytime > ln_return_val.daytime AND lr_rec_local.rate IS NOT NULL AND lr_rec_local.rate != 0) THEN
                 ln_return_val := lr_rec_local;

                 IF ln_return_val.rate IS NOT NULL AND ln_return_val.rate != 0 THEN
                    -- get inverse
                    ln_return_val.rate := 1/ln_return_val.rate;
                 END IF;

              END IF;

              -- try to get last available exchange rate using triangulation method
              IF ln_return_val.rate IS NULL THEN

                 lv2_via_curr := ec_ctrl_system_attribute.attribute_text(ld_daytime, 'FX_TRIANGULATE_CURR_CODE', '<=');

                 IF lv2_via_curr IS NULL THEN

                    lv2_via_curr := 'EUR'; -- default currency

                 END IF;

                 -- recursive call (using last available exchange rate, p_operator is '<=')
                 ln_return_val := GetExRowViaCurrency(p_from_curr_code, p_to_curr_code ,lv2_via_curr, ld_daytime, p_forex_source_id, p_duration, '<=');

              END IF;

         END IF;

       END IF;

   END IF;

   RETURN ln_return_val;

END GetExRowViaCurrency;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetExRateViaCurrency
-- Description    : Returns a converted value based on factors in currency_exchange.
--
-- Preconditions  :  Currency parameters are codes
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_currency_exchange
--
-- Configuration
-- required       :
--
-- Behaviour      : GetExRateViaCurrency recursive.
--
---------------------------------------------------------------------------------------------------
FUNCTION GetExRateViaCurrency(p_from_curr_code  VARCHAR2,
                              p_to_curr_code    VARCHAR2,
                              p_via_curr_code   VARCHAR2,
                              p_daytime         DATE,
                              p_forex_source_id VARCHAR2,               --forex source
                              p_duration        VARCHAR2 DEFAULT 'DAILY', --forex time scope
                              p_operator        VARCHAR2 DEFAULT '<=')
RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;
ln_factor1 NUMBER;
ld_factor1_date DATE;
ld_factor2_date DATE;
ln_factor2 NUMBER;
lv2_via_curr          currency.object_code%TYPE;
lv2_via_curr_id       currency.object_id%TYPE;
lv2_from_currrency_id currency.object_id%TYPE;
lv2_to_currency_id    currency.object_id%TYPE;
lv2_fallback VARCHAR2(32);
ld_daytime DATE;
lr_rec_local currency_exchange%ROWTYPE;
ln_return_val_date DATE;

BEGIN

   lv2_via_curr_id := ec_currency.object_id_by_uk(p_via_curr_code);
   lv2_from_currrency_id := ec_currency.object_id_by_uk(p_from_curr_code);
   lv2_to_currency_id := ec_currency.object_id_by_uk(p_to_curr_code);

   -- check for fallback method
   lv2_fallback := ec_forex_source_setup.fallback(p_forex_source_id, p_duration, p_daytime, '<=');

   -- make monthly daytime to first of month
   -- ECPD-30878: making it possible to use several daily time scopes, like rounded daily rates (RND_DAILY)
   -- This is a 11_0-SP02 specific solution. Better handling of time scope / forex type.
   IF p_duration NOT LIKE '%DAILY%' THEN
      ld_daytime := trunc(p_daytime, 'MONTH');
   ELSE
      ld_daytime := p_daytime;
   END IF;

   IF p_from_curr_code = p_to_curr_code THEN

      ln_return_val := 1; -- no conversion required

   ELSE

      IF p_via_curr_code IS NOT NULL THEN

         -- try direct convert to 3rd currency
         IF lv2_fallback = 'NO_FALLBACK' THEN -- getting only exact exchange rate

            ln_factor1 := ec_currency_exchange.rate(lv2_from_currrency_id, lv2_via_curr_id, p_duration, ld_daytime, p_forex_source_id, '=');

         ELSIF lv2_fallback = 'LAST_AVAILABLE' THEN -- getting exact exchange rate (p_operator is '=') or use latest available (p_operator is '<=')

              ln_factor1 := ec_currency_exchange.rate(lv2_from_currrency_id, lv2_via_curr_id, p_duration, ld_daytime, p_forex_source_id, p_operator);
              ld_factor1_date := ec_currency_exchange.prev_equal_daytime(lv2_from_currrency_id, lv2_via_curr_id, p_duration, ld_daytime, p_forex_source_id);

         END IF;

         -- try inverse convert to 3rd currency
         lr_rec_local := ec_currency_exchange.row_by_pk(lv2_via_curr_id, lv2_from_currrency_id, p_duration, ld_daytime, p_forex_source_id, p_operator);


         IF ln_factor1 IS NULL OR (ld_factor1_date IS NOT NULL AND ld_factor1_date > nvl(lr_rec_local.daytime,ld_factor1_date+1)) THEN

            IF lv2_fallback = 'NO_FALLBACK' THEN -- getting only exact exchange rate

               ln_factor1 := ec_currency_exchange.rate(lv2_via_curr_id, lv2_from_currrency_id, p_duration, ld_daytime, p_forex_source_id, '=');

            ELSIF lv2_fallback = 'LAST_AVAILABLE' THEN -- getting exact exchange rate (p_operator is '=') or use latest available (p_operator is '<=')

                 ln_factor1 := lr_rec_local.rate;

            END IF;

            IF ln_factor1 IS NOT NULL AND ln_factor1 != 0 THEN

               -- get inverse
               ln_factor1 := 1/ln_factor1;

            END IF;

         END IF;


         -- try direct convert to target currency
         IF lv2_fallback = 'NO_FALLBACK' THEN -- getting only exact exchange rate

            ln_factor2 := ec_currency_exchange.rate(lv2_via_curr_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id, '=');

         ELSIF lv2_fallback = 'LAST_AVAILABLE' THEN -- getting exact exchange rate (p_operator is '=') or use latest available (p_operator is '<=')

              ln_factor2 := ec_currency_exchange.rate(lv2_via_curr_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id, p_operator);
              ld_factor2_date := ec_currency_exchange.prev_equal_daytime(lv2_via_curr_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id);

         END IF;

         -- try inverse convert to target currency
         lr_rec_local := ec_currency_exchange.row_by_pk(lv2_to_currency_id, lv2_via_curr_id, p_duration, ld_daytime, p_forex_source_id, p_operator);

         IF ln_factor2 IS NULL OR (ld_factor2_date IS NOT NULL AND ld_factor2_date > nvl(lr_rec_local.daytime,ld_factor2_date+1)) THEN

            IF lv2_fallback = 'NO_FALLBACK' THEN -- getting only exact exchange rate

               ln_factor2 := ec_currency_exchange.rate(lv2_to_currency_id, lv2_via_curr_id, p_duration, ld_daytime, p_forex_source_id, '=');

            ELSIF lv2_fallback = 'LAST_AVAILABLE' THEN -- getting exact exchange rate (p_operator is '=') or use latest available (p_operator is '<=')

                 ln_factor2 := lr_rec_local.rate;

            END IF;

            IF ln_factor2 IS NOT NULL AND ln_factor2 != 0 THEN

               -- get inverse
               ln_factor2 := 1/ln_factor2;

            END IF;

         END IF;

         ln_return_val := ln_factor1 * ln_factor2;

      ELSE

         -- try direct convert (source -> target) currency
         IF lv2_fallback = 'NO_FALLBACK' THEN -- getting only exact exchange rate

            ln_return_val := ec_currency_exchange.rate(lv2_from_currrency_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id, '=');

            -- try inverse convert (target -> source) currency
            IF ln_return_val IS NULL THEN
               ln_return_val := ec_currency_exchange.rate(lv2_to_currency_id, lv2_from_currrency_id, p_duration, ld_daytime, p_forex_source_id, '=');

               IF ln_return_val IS NOT NULL AND ln_return_val != 0 THEN
                  -- get inverse
                  ln_return_val := 1/ln_return_val;
               END IF;

            END IF;

            -- if cannot get exact exchange rate, try to get exchange rate using triangulation method
            IF ln_return_val IS NULL THEN

               lv2_via_curr := ec_ctrl_system_attribute.attribute_text(ld_daytime, 'FX_TRIANGULATE_CURR_CODE', '<=');

               IF lv2_via_curr IS NULL THEN

                  lv2_via_curr := 'EUR'; -- default currency

               END IF;

               -- recursive call (using exact exchange rate, p_operator is '=')
               ln_return_val := GetExRateViaCurrency(p_from_curr_code, p_to_curr_code ,lv2_via_curr, ld_daytime, p_forex_source_id, p_duration, '=');

            END IF;


         ELSIF lv2_fallback = 'LAST_AVAILABLE' THEN -- getting exact exchange rate if available, else use latest available

              -- try to get exact exchange rate (source -> target)
              ln_return_val := ec_currency_exchange.rate(lv2_from_currrency_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id, '=');

              -- try inverse exact exchange rate (target -> source)
              IF ln_return_val IS NULL THEN
                 ln_return_val := ec_currency_exchange.rate(lv2_to_currency_id, lv2_from_currrency_id, p_duration, ld_daytime, p_forex_source_id, '=');

                 IF ln_return_val IS NOT NULL AND ln_return_val != 0 THEN
                    -- get inverse
                    ln_return_val := 1/ln_return_val;
                 END IF;

              END IF;

              -- if cannot get exact exchange rate, try to get exchange rate using triangulation method
              IF ln_return_val IS NULL THEN

                 lv2_via_curr := ec_ctrl_system_attribute.attribute_text(ld_daytime, 'FX_TRIANGULATE_CURR_CODE', '<=');

                 IF lv2_via_curr IS NULL THEN

                    lv2_via_curr := 'EUR'; -- default currency

                 END IF;

                 -- recursive call (using exact exchange rate, p_operator is '=')
                 ln_return_val := GetExRateViaCurrency(p_from_curr_code, p_to_curr_code ,lv2_via_curr, ld_daytime, p_forex_source_id, p_duration, '=');

              END IF;

              -- if cannot get exact exchange rate, no exact result from triangulation method, try last available direct (source -> target)
              IF ln_return_val IS NULL THEN
                 ln_return_val := ec_currency_exchange.rate(lv2_from_currrency_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id, '<=');
                 ln_return_val_date := ec_currency_exchange.prev_equal_daytime(lv2_from_currrency_id, lv2_to_currency_id, p_duration, ld_daytime, p_forex_source_id);
              END IF;

              -- try inverse last available exchange rate (target -> source)
              lr_rec_local := null;
              lr_rec_local := ec_currency_exchange.row_by_pk(lv2_to_currency_id, lv2_from_currrency_id, p_duration, ld_daytime, p_forex_source_id, '<=');

              IF ln_return_val IS NULL OR (nvl(lr_rec_local.daytime,ln_return_val_date-1) > ln_return_val_date AND lr_rec_local.rate IS NOT NULL AND lr_rec_local.rate != 0) THEN
                 ln_return_val := lr_rec_local.rate;

                 IF ln_return_val IS NOT NULL AND ln_return_val != 0 THEN
                    -- get inverse
                    ln_return_val := 1/ln_return_val;
                 END IF;

              END IF;

              -- try to get last available exchange rate using triangulation method
              IF ln_return_val IS NULL THEN

                 lv2_via_curr := ec_ctrl_system_attribute.attribute_text(ld_daytime, 'FX_TRIANGULATE_CURR_CODE', '<=');

                 IF lv2_via_curr IS NULL THEN

                    lv2_via_curr := 'EUR'; -- default currency

                 END IF;

                 -- recursive call (using last available exchange rate, p_operator is '<=')
                 ln_return_val := GetExRateViaCurrency(p_from_curr_code, p_to_curr_code ,lv2_via_curr, ld_daytime, p_forex_source_id, p_duration, '<=');

              END IF;

         END IF;

       END IF;

   END IF;

   RETURN ln_return_val;

END GetExRateViaCurrency;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetCurr100
-- Description    :
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
FUNCTION GetCurr100(p_currency_code VARCHAR2,
                    p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_curr_id VARCHAR2(32);

BEGIN

    lv2_curr_id := ec_currency.object_id_by_uk(p_currency_code);

    RETURN ec_currency_version.unit100(lv2_curr_id, p_daytime, '<=');

END GetCurr100;

FUNCTION GetForexDateViaCurrency(p_book_curr_code  VARCHAR2,
                              p_local_curr_code    VARCHAR2,
                              p_group_curr_code   VARCHAR2,
                              p_daytime         DATE,
                              p_forex_source_id VARCHAR2,               --forex source
                              p_duration        VARCHAR2 DEFAULT 'DAILY') --forex time scope
RETURN DATE
--</EC-DOC>
IS

ld_return_val DATE;
lv2_book_currrency_id currency.object_id%TYPE;
lv2_local_curr_id    currency.object_id%TYPE;
lv2_group_curr_id       currency.object_id%TYPE;
lv2_fallback VARCHAR2(32);
ld_BL DATE;
ld_Inv_BL DATE;
ld_BG DATE;
ld_Inv_BG DATE;
ld_forex_date DATE;

BEGIN

   lv2_book_currrency_id := ec_currency.object_id_by_uk(p_book_curr_code);
   lv2_local_curr_id := ec_currency.object_id_by_uk(p_local_curr_code);
   lv2_group_curr_id := ec_currency.object_id_by_uk(p_group_curr_code);

   ld_return_val := p_daytime;

   -- check for fallback method
   lv2_fallback := ec_forex_source_setup.fallback(p_forex_source_id, p_duration, p_daytime, '<=');

   IF lv2_fallback='LAST_AVAILABLE' THEN

       ld_BL := ec_currency_exchange.prev_equal_daytime(lv2_book_currrency_id,lv2_local_curr_id,p_duration,p_daytime,p_forex_source_id);

       ld_Inv_BL := ec_currency_exchange.prev_equal_daytime(lv2_local_curr_id,lv2_book_currrency_id,p_duration,p_daytime,p_forex_source_id);

       ld_BG := ec_currency_exchange.prev_equal_daytime(lv2_book_currrency_id,lv2_group_curr_id,p_duration,p_daytime,p_forex_source_id);

       ld_Inv_BG := ec_currency_exchange.prev_equal_daytime(lv2_group_curr_id,lv2_book_currrency_id,p_duration,p_daytime,p_forex_source_id);

       IF ld_BL IS NOT NULL THEN
          ld_forex_date := ld_BL;
       ELSE
          ld_forex_date :='01-JAN-1900'; -- set a dummy date
       END IF;

       IF ld_Inv_BL > ld_forex_date THEN
          ld_forex_date := ld_Inv_BL;
       END IF;

       IF ld_BG > ld_forex_date THEN
          ld_forex_date := ld_BG;
       END IF;

       IF ld_Inv_BG > ld_forex_date THEN
          ld_forex_date := ld_Inv_BG;
       END IF;

       IF ld_forex_date <> '01-JAN-1900' THEN
          ld_return_val := ld_forex_date;
       END IF;

   END IF;

    RETURN ld_return_val;

END GetForexDateViaCurrency;


END EcDp_Currency;