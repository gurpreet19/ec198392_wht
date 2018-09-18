CREATE OR REPLACE PACKAGE BODY EcDp_Sales_Contract_Price IS
/******************************************************************************
** Package        :  EcDp_Sales_Contract_Price, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Provides unit price information for a sales contract
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2004 Bent Ivar Helland
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   Initial version (first build / handover to test)
** 11.01.2005  BIH   Added / cleaned up documentation
** 01.03.2005  kaurrnar	Removed references to ec_xxx_attribute packages
** 21-07-2009 leongwen ECPD-11578 support multiple timezones
**																to add production object id to pass into the function ecdp_date_time.local2utc()
** 19-01-2011 leeeewei Added new function getAnySubPriceElement
** 21.04.2015 leeeewei Added parameter for InsNewPriceElementSet
********************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNormalGasUnitPrice
-- Description    : Returns the unit price for normal quality gas valid at the given daytime.
--
-- Preconditions  : Assumes that prices are stored with the unit given by EcDp_Sales_Contract.getUnitPriceUOM
-- Postconditions :
--
-- Using tables   : cntr_unit_price
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the unit price for the given contract with the highest daytime <= p_daytime.
--
---------------------------------------------------------------------------------------------------
FUNCTION getNormalGasUnitPrice(
  p_object_id  VARCHAR2,
  p_daytime    DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_price    NUMBER;
   CURSOR c_price IS
      SELECT price
      FROM cntr_unit_price
      WHERE object_id = p_object_id
      AND daytime = (
         SELECT MAX(daytime)
         FROM cntr_unit_price
         WHERE object_id = p_object_id
         AND daytime <= p_daytime
      );
BEGIN
   -- This method must return the unit price from the price entry screen
   -- It must be in a unit that allows direct multiplication with the qty
   -- In other words the unit must be EcDp_Sales_Contract.getPriceUOM / EcDp_Sales_Contract.getQtyUOM

   FOR r_price IN c_price LOOP
      ln_price := r_price.price;
   END LOOP;

   RETURN ln_price;
END getNormalGasUnitPrice;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOffspecGasUnitPrice
-- Description    : Returns the unit price for normal quality gas valid at the given daytime.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getNormalGasUnitPrice
--                  ec_cntr_version....
--
-- Configuration
-- required       : The OFF_SPEC_PRICE_FACTOR contract attribute must have a value.
--
-- Behaviour      : Looks up the OFF_SPEC_PRICE_FACTOR attribute, and calculates the off-spec price
--                  as the normal gas price multiplied with the price factor.
--
---------------------------------------------------------------------------------------------------
FUNCTION getOffspecGasUnitPrice(
  p_object_id  VARCHAR2,
  p_daytime    DATE
)
RETURN NUMBER
--</EC-DOC>
IS

   ln_normal_price   NUMBER;
   ln_offspec_factor NUMBER;
BEGIN

   ln_normal_price := getNormalGasUnitPrice(p_object_id, p_daytime);
   ln_offspec_factor := EcDp_Contract_Attribute.getAttributeNumber(p_object_id, 'OFF_SPEC_PRICE_FACTOR', p_daytime);
   RETURN ln_normal_price * ln_offspec_factor;
END getOffspecGasUnitPrice;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMonthlyTakeOrPayPrice
-- Description    : Returns the unit price for take-or-pay penalty quantity for the given contract month.
--
-- Preconditions  : The input date should be the logical contract month (zero day/hour/minutes/seconds).
-- Postconditions :
--
-- Using tables   : cntr_unit_price
--                  sales_contract
--
-- Using functions: EcDp_Sales_Contract.getContractDayStartTime
--                  EcDp_Date_Time.local2utc
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the weighted average unit price from the price entry screen for the given month.
--                  Contract day offset and daylight savings time transistions are taken into account to get
--                  the correct weighting factors for each price that was valid within the month.
--                  Note that an exception is thrown if the input date precondition is not met.
--
---------------------------------------------------------------------------------------------------
FUNCTION getMonthlyTakeOrPayPrice(
  p_object_id        VARCHAR2,
  p_contract_month   DATE
)
RETURN NUMBER
--</EC-DOC>
IS

   ld_from_daytime   DATE;
   ld_to_daytime     DATE;
   ln_period_length  NUMBER;
   ln_price          NUMBER;
   ld_price_from     DATE;
   ld_price_to       DATE;
   ln_price_len      NUMBER;
   ld_contract_start DATE;
   ld_contract_end   DATE;
   lc_pday_obj_id_to_date			VARCHAR2(32);
   lc_pday_obj_id_from_date		VARCHAR2(32);
   lc_pday_obj_id_price_from	VARCHAR2(32);
   lc_pday_obj_id_price_to		VARCHAR2(32);

   CURSOR c_prices (p_from DATE, p_to DATE) IS
      SELECT price, daytime AS start_time,
             (SELECT MIN(p2.daytime) FROM cntr_unit_price p2 WHERE p2.object_id = p1.object_id AND p2.daytime > p1.daytime) AS end_time
      FROM cntr_unit_price p1
      WHERE object_id = p_object_id
      AND daytime < p_to
      AND daytime >= (
         SELECT MAX(daytime)
         FROM cntr_unit_price
         WHERE object_id = p_object_id
         AND daytime <= p_from
      )
      ORDER BY daytime;
BEGIN

   -- Validate p_contract_month
   IF p_contract_month IS NULL OR p_contract_month <> TRUNC(p_contract_month,'mm') THEN
      RAISE_APPLICATION_ERROR(-20000,'getMonthlyTakeOrPayPrice requires p_contract_month to be a non-NULL month value.');
   END IF;

   -- Find from and to daytimes to average the price for
   ld_from_daytime := EcDp_ContractDay.getProductionDayStart('CONTRACT',p_object_id, p_contract_month);
   ld_to_daytime := EcDp_ContractDay.getProductionDayStart('CONTRACT',p_object_id, ADD_MONTHS(p_contract_month, 1));

   -- Limit to the period the contract is valid...
   SELECT start_date, end_date
   INTO ld_contract_start, ld_contract_end
   FROM contract
   WHERE object_id = p_object_id;

   IF ld_from_daytime < ld_contract_start THEN
      -- TODO: Should we apply contract day offset here? If the contract is valid from 01.11 then we probably mean the contract day...
      ld_from_daytime := ld_contract_start;
   END IF;
   IF ld_to_daytime > ld_contract_end THEN
      -- TODO: Should we apply contract day offset here? If the contract is valid to 30.11 then we probably mean the contract day...
      ld_to_daytime := ld_contract_end;
   END IF;

   ln_price := NULL;
   lc_pday_obj_id_to_date := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_object_id, ld_to_daytime);
   lc_pday_obj_id_from_date := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_object_id, ld_from_daytime);
   ln_period_length := EcDp_Date_Time.local2utc(ld_to_daytime, NULL, lc_pday_obj_id_to_date) - EcDp_Date_Time.local2utc(ld_from_daytime, NULL, lc_pday_obj_id_from_date);

   FOR r_price IN c_prices(ld_from_daytime, ld_to_daytime) LOOP
      ld_price_from := r_price.start_time;
      ld_price_to := r_price.end_time;
      IF ld_price_from < ld_from_daytime THEN
         ld_price_from := ld_from_daytime;
      END IF;
      IF ld_price_to IS NULL OR ld_price_to > ld_to_daytime THEN
         ld_price_to := ld_to_daytime;
      END IF;
      lc_pday_obj_id_price_from := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_object_id, ld_price_from);
      lc_pday_obj_id_price_to := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_object_id, ld_price_to);
      ln_price_len := EcDp_Date_Time.local2utc(ld_price_to, NULL, lc_pday_obj_id_price_to) - EcDp_Date_Time.local2utc(ld_price_from, NULL, lc_pday_obj_id_price_from);
      ln_price := NVL(ln_price, 0) + NVL(r_price.price * ln_price_len / ln_period_length, 0);
   END LOOP;

   -- This method must return the weighted average unit price from the price entry screen for the interval
   RETURN ln_price;

END getMonthlyTakeOrPayPrice;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  InsNewPriceElementSet
-- Description    : Called from class contract_price_list used by business function Contract Price Values (EC Revenue)
--                  Depending on selected price object, this procedure creates a record for each price concept element defined on the price concept.
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
-- Behaviour      : Inserts into table product_price_value
--
-------------------------------------------------------------------------------------------------
PROCEDURE InsNewPriceElementSet(
    p_object_id                 VARCHAR2,
    p_price_concept_code        VARCHAR2,
    p_price_element_code        VARCHAR2,
    p_daytime                   DATE,
	p_price_category            VARCHAR2,
    p_user                      VARCHAR2
)
--<EC-DOC>
IS



CURSOR c_price_elements (cp_price_concept_code VARCHAR2) IS
       SELECT price_element_code
       FROM   price_concept_element
       WHERE  price_concept_code = cp_price_concept_code;


lrec_pp_value product_price_value%ROWTYPE;
ln_inserted NUMBER := 0;
BEGIN



lrec_pp_value := ec_product_price_value.row_by_pk(p_object_id,p_price_concept_code,p_price_element_code,p_daytime, p_price_category);

-- Inserting record for each price element


-- Checking if any price element has been inserted
FOR c_val IN c_price_elements(p_price_concept_code) LOOP

ln_inserted := 0;

SELECT count(*)
  INTO ln_inserted
  FROM product_price_value
 WHERE object_id = p_object_id
   AND price_concept_code = p_price_concept_code
   AND daytime = p_daytime
   AND price_element_code = c_val.price_element_code
   AND price_category = p_price_category;



    -- One record is already inserted
    IF  (ln_inserted = 0)  THEN

      INSERT
      INTO     product_price_value (object_id,price_concept_code,price_element_code,daytime,price_category,calc_price_value,adj_price_value,comments,created_by)
      VALUES   (p_object_id,p_price_concept_code, c_val.price_element_code,p_daytime,p_price_category,lrec_pp_value.calc_price_value,lrec_pp_value.adj_price_value,lrec_pp_value.comments,lrec_pp_value.created_by);
    END IF;
END LOOP;


END InsNewPriceElementSet;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  getAnyPriceElement
-- Description    : Retrieve one of the price_concept_elements on current price_concept
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
FUNCTION getAnyPriceElement(
   p_price_concept_code VARCHAR2,
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_price_category     VARCHAR2
)
RETURN VARCHAR2

IS

lv_price_element_code VARCHAR2(32);
lb_check VARCHAR2(1) := 'N';

CURSOR c_price_elements (cp_price_concept_code VARCHAR2) IS
       SELECT price_element_code
       FROM   price_concept_element
       WHERE  price_concept_code = cp_price_concept_code;



CURSOR c_prod_price_value (cp_object_id VARCHAR2, cp_price_concept_code VARCHAR2, cp_daytime DATE, cp_price_category VARCHAR2) IS
SELECT price_element_code
  FROM product_price_value
 WHERE object_id = cp_object_id
   AND price_concept_code = cp_price_concept_code
   AND daytime = cp_daytime
   AND price_category = cp_price_category;

BEGIN




----------
FOR c_val IN c_price_elements (p_price_Concept_code) LOOP

    -- Trying to return a price element not in use already in product_price_value for this price_object/price_concept
    FOR c_ppv IN c_prod_price_value(p_object_id,p_price_concept_code,p_daytime, p_price_category) LOOP
        IF c_val.price_element_code = c_ppv.price_element_code THEN
            lb_check := 'Y';
        END IF;
    END LOOP;

     IF (lb_check = 'N') THEN
      RETURN c_val.price_element_code;
     END IF;

lv_price_element_code := c_val.price_element_code;
END LOOP;

RETURN lv_price_element_code;

END getAnyPriceElement;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  getAnySubPriceElement
-- Description    : Retrieve one of the price_concept_elements on current price_concept for sub daily
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
FUNCTION getAnySubPriceElement(
   p_price_concept_code VARCHAR2,
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_price_category     VARCHAR2
)
RETURN VARCHAR2

IS

lv_price_element_code VARCHAR2(32);
lb_check VARCHAR2(1) := 'N';

CURSOR c_price_elements (cp_price_concept_code VARCHAR2) IS
       SELECT price_element_code
       FROM   price_concept_element
       WHERE  price_concept_code = cp_price_concept_code;



CURSOR c_prod_price_value (cp_object_id VARCHAR2, cp_price_concept_code VARCHAR2, cp_daytime DATE, cp_price_category VARCHAR2) IS
SELECT price_element_code
  FROM prod_price_sub_day_value
 WHERE object_id = cp_object_id
   AND price_concept_code = cp_price_concept_code
   AND daytime = cp_daytime
   AND price_category = cp_price_category;

BEGIN



----------
FOR c_val IN c_price_elements (p_price_Concept_code) LOOP

    -- Trying to return a price element not in use already in prod_price_sub_day_value for this price_object/price_concept
    FOR c_ppv IN c_prod_price_value(p_object_id,p_price_concept_code,p_daytime,p_price_category) LOOP
        IF c_val.price_element_code = c_ppv.price_element_code THEN
            lb_check := 'Y';
        END IF;
    END LOOP;

     IF (lb_check = 'N') THEN
      RETURN c_val.price_element_code;
     END IF;

lv_price_element_code := c_val.price_element_code;
END LOOP;

RETURN lv_price_element_code;

END getAnySubPriceElement;


END EcDp_Sales_Contract_Price;