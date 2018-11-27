CREATE OR REPLACE PACKAGE BODY EcDp_Chemical_Tank IS
/***********************************************************************************************************************************************
** Package  :  EcDp_Chemical_Tank, body part
**
** $Revision: 1.21 $
**
** Purpose  :  Business functions related to chemical tanks
**
** Created  :  03.03.2004 Frode Barstad
**
** How-To   :  Se www.energy-components.com for full version
**
** Modification history:
**
** Date:      Revision: Whom:     Change description:
** ---------- --------- -----     --------------------------------------------
** 03.03.2004 1.0       FBa       Initial version
** 16.03.2004 1.1       HNE       Bugfix and dm changes
** 21.03.2004 1.6       FBa       Changed getPrevMeasDate and getOpeningVol to use data with closing volume NOT NULL.
**                                Returning a date with NULL closing volume does not make sense. Resolves performance issue.
** 26.10.2004 1.7       Chongjer  Made changes to EcDp_Chemical_Tank.getConsumedVol()
**                                   Purpose: Return consumed for a given date, either stored or calculated.
**                                   Assumptions: The consumption is linear between two readings of closing
**                                      tank status. Functions only access records having NOT NULL values for the
**                                      column selected.
**                                   Definition:
**                                      Filled record - A record where the column FILLED_VOL is not null
**                                      Closing record - A record where the column GRS_VOL is not null
**                                      1.	Previous and future closing records existso	Average consumed = ((previous closing record - future closing record) + (sum filled records between previous and future date for closing record) / (future date - previous date for closing record))
**                                      2.	Previous and/or future closing is missingo	Average consumed = attribute consumed rate (new attribute holding default consumption)
**                                      3.	Previous closing do not exist, but future closing existso	Assume new product and tank combination => previous closing is 0 and previous date is the date when product and tank was connected. Then used same logic as under item 1.
**
**                                Made changes EcDp_Chemical_Tank.getClosingVol()
**                                   Purpose: Return closing volume for a given date, either stored or calculated.A db function must be able to calculate closing inventory for a given date.
**                                   The assumption is that the consumption is linear between two reading of closing tank status. <date> is the date you pass into the function.
**                                   Definition:
**                                      Filled record - A record where the column FILLED_VOL is not null
**                                      Closing record - A record where the column GRS_VOL is not null
**                                      1.	Closing exists for the <date>o	Return stored closing inventory for the <date>. If "closing UOM" is percent, convert to volume using tank max volume attribute.
**                                      2.	Previous closing exists, but not future closingo	Closing <date> = previous closing record - (consumed rate (attribute) * (<date> - previous date) + filled records between previous and <date>
**                                      3.	Previous and future closing existo	Closing <date> = previous closing - (EcDp_Chemical_Tank.getConsumedVol(<date>) *  (<date> - previous date)) + filled between previous and <date>
**                                      4.	Previous and future closing do not existo	Assume new product and tank combination => previous closing is 0 and previous date is the date when product and tank was connected. Then use the same logic as under item 2.
**                                      5.	Previous do not exist, but future doeso	Assume new product and tank combination => previous closing is 0 and previous date is the date when product and tank was connected. Then used same logic as under item 3.
**
**                                Made changes EcDp_Chemical_Tank.getOpeningVol()
**                                   Change this function to lookup EcDp_Chemical_Tank.getClosingVol( <date> - 1).(opening is equal y'day closing.
**
**                                Added new function EcDp_Chemical_Tank.getClosingUnit()
**                                   Return the value of the TANK_CLOSING_UNIT attribute on CHEM_TANK
**
**                                Added new function EcDp_Chemical_Tank.getDailyConsumtionRate()
**                                   Return the value of the DAILY_CONSUMPTION_RATE attribute on CHEM_TANK
** 14.12.2004           DN        Replaced units with EcDp_unit.
** 02.02.2005 1.8       Darren    Added new procedure biuSetEndDate to validate event overlapping and set end date for chemical tank product combination
** 08.02.2005           SHN       Fixed several bugs,tracker 1992, in cursor C_SUM_FILLED_VOL,getConsumedVol and getClosingVol.
** 24.05.2005           kaurrnar  Changed chem_product_attribute to chem_product_version and chem_tank_attribute to chem_tank_version
** 13.06.2005 1.9       Chongjer  Modified biuSetEndDate to check for overlapping of period, TD2961 in 8.1.
** 24.10.2005 1.10      Rahmanaz  Modified biuSetEndDate to disable overlapping of period, TI2636 in 8.3.
** 16.11.2005 1.21      eizwanik  TI#3133 - Solved defects in getConsumedVol function
** 14.10.2014 10.1      sohalran  getConsumedVol is now using the p_uom parameter as return value .
***********************************************************************************************************************************************/

CURSOR c_product_for_tank (p_tank_object_id VARCHAR2, p_daytime DATE) IS
SELECT chem_product_id
FROM chem_tank_product
WHERE object_id = p_tank_object_id
AND p_daytime >= daytime AND (end_date > p_daytime OR end_date IS NULL);

CURSOR c_prev_tank_reading_daytime (p_tank_object_id VARCHAR2, p_daytime   DATE) IS
SELECT max(daytime) daytime
FROM CHEM_TANK_STATUS
WHERE object_id = p_tank_object_id AND daytime < p_daytime AND grs_vol IS NOT NULL;

CURSOR c_sum_filled_vol (p_tank_object_id VARCHAR2, from_daytime DATE, to_daytime DATE) IS
SELECT SUM(NVL(FILLED_VOL, 0)) SUM_FILLED_VOL
FROM CHEM_TANK_STATUS
WHERE object_id = p_tank_object_id
AND daytime BETWEEN
from_daytime AND to_daytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDefaultUOM
-- Description    : Returns default Unit of Measure for tank
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_TANK_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDefaultUOM(p_tank_object_id IN VARCHAR2,
                       p_daytime        IN DATE DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_retval VARCHAR2(300);
  ld_date    DATE;

BEGIN
  ld_date := Nvl(p_daytime, Ecdp_Timestamp.getCurrentSysdate);

  lv2_retval := ec_chem_tank_version.UNIT(p_tank_object_id, ld_date, '<=');
  RETURN lv2_retval;
END getDefaultUOM;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getClosingUnit
-- Description    : Returns Closing Inventory Unit of Measure for tank
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_TANK_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getClosingUnit(p_tank_object_id IN VARCHAR2,
                       p_daytime        IN DATE DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_retval VARCHAR2(300);
  ld_date    DATE;

BEGIN
  ld_date := Nvl(p_daytime, Ecdp_Timestamp.getCurrentSysdate);

  lv2_retval := ec_chem_tank_version.TANK_CLOSING_UNIT(p_tank_object_id, ld_date, '<=');
  RETURN lv2_retval;
END getClosingUnit;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductID
-- Description    : Returns product on tank
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_TANK_PRODUCT
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductID(p_tank_object_id IN VARCHAR2,
                      p_daytime        IN DATE DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_retval chem_tank_product.chem_product_id%TYPE;
  ld_date    DATE;

BEGIN
  ld_date := Nvl(p_daytime, Ecdp_Timestamp.getCurrentSysdate);

  FOR prodCur IN c_product_for_tank(p_tank_object_id, ld_date) LOOP
     lv2_retval := prodCur.chem_product_id;
  END LOOP;
  RETURN lv2_retval;
END getProductID;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductCode
-- Description    : Returns code for product on tank
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Chemical_Product.getProductCode
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductCode(p_tank_object_id IN VARCHAR2,
                        p_daytime        IN DATE DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_retval VARCHAR2(300);
  ld_date    DATE;

BEGIN
  ld_date := Nvl(p_daytime, Ecdp_Timestamp.getCurrentSysdate);

  lv2_retval := EcDp_Chemical_Product.getProductCode(getProductId(p_tank_object_id, ld_date), ld_date);
  RETURN lv2_retval;
END getProductCode;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductName
-- Description    : Returns name for product on tank
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Chemical_Product.getProductName
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductName(p_tank_object_id IN VARCHAR2,
                        p_daytime        IN DATE DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_retval VARCHAR2(300);
  ld_date    DATE;

BEGIN
  ld_date := Nvl(p_daytime, Ecdp_Timestamp.getCurrentSysdate);

  lv2_retval := EcDp_Chemical_Product.getProductName(getProductId(p_tank_object_id, ld_date), ld_date);
  RETURN lv2_retval;
END getProductName;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getClosingVol
-- Description    : Returns closing volume for the day, or if null, returns opening volume as closing (no metering today)
--                  Return closing volume for a given date, either stored or calculated.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getRealClosingVol, getOpeningVol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getClosingVol(p_tank_object_id IN VARCHAR2,
                       p_daytime        IN DATE,
                       p_uom            IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  ln_prev_opening         DATE;
  ln_future_opening       DATE;
  ln_return               NUMBER;

  ln_closing_unit         VARCHAR(32);
  ln_max_vol              NUMBER;
  previous_daytime        DATE;
  previous_closing_record NUMBER;
  ln_cal_consumed         NUMBER;
  ln_cal_filled           NUMBER;

BEGIN
  ln_return := 0;

  SELECT MAX(daytime) into ln_prev_opening FROM CHEM_TANK_STATUS
         WHERE object_id = p_tank_object_id AND daytime <= p_daytime AND grs_vol IS NOT NULL;

  SELECT MIN(daytime) into ln_future_opening FROM CHEM_TANK_STATUS
         WHERE object_id = p_tank_object_id AND daytime >= p_daytime AND grs_vol IS NOT NULL;

  IF p_daytime = ln_prev_opening THEN
     --1 closing exists for input date
     --if closing unit is in pct, then conversion to vol is done
     ln_closing_unit := getClosingUnit(p_tank_object_id, p_daytime);
     IF ('PCT' = ln_closing_unit) THEN
     	ln_max_vol := ec_chem_tank_version.MAX_VOLUME(p_tank_object_id, p_daytime, '<=') / 100;
     	ln_return := getRealClosingVol(p_tank_object_id, p_daytime) * ln_max_vol;
     ELSE
     	ln_return := getRealClosingVol(p_tank_object_id, p_daytime, p_uom);
     END IF;

  ELSIF ln_prev_opening IS NOT NULL AND ln_future_opening IS NULL THEN
    --2 previous closing exists, but not future closing
    FOR mypday IN c_prev_tank_reading_daytime(p_tank_object_id, p_daytime) LOOP
        previous_daytime := mypday.daytime;
    END LOOP;
    previous_closing_record := getClosingVol(p_tank_object_id, previous_daytime);
    ln_cal_consumed := getDailyConsumptionRate(p_tank_object_id, p_daytime) * (p_daytime - previous_daytime);
    FOR mycalfil IN c_sum_filled_vol(p_tank_object_id, previous_daytime, p_daytime) LOOP
       ln_cal_filled := mycalfil.sum_filled_vol;
    END LOOP;
    ln_return := (previous_closing_record - ln_cal_consumed) + ln_cal_filled;
    NULL;

  ELSIF ln_prev_opening IS NOT NULL AND ln_future_opening IS NOT NULL THEN
    --3 previous and future closing exists
    FOR mycur IN c_prev_tank_reading_daytime(p_tank_object_id, p_daytime) LOOP
        previous_daytime := mycur.daytime;
    END LOOP;
    previous_closing_record := getClosingVol(p_tank_object_id, previous_daytime);
    ln_cal_consumed := getConsumedVol(p_tank_object_id, p_daytime) * (p_daytime - previous_daytime);
    FOR mycalfil IN c_sum_filled_vol(p_tank_object_id, previous_daytime, p_daytime) LOOP
        ln_cal_filled := mycalfil.sum_filled_vol;
    END LOOP;
    ln_return := (previous_closing_record - ln_cal_consumed) + ln_cal_filled;
    NULL;

  ELSIF ln_prev_opening IS NULL AND ln_future_opening IS NULL THEN
    --4 previous and future closing does not exists
    previous_daytime := Nvl(getPrevConnectionDate(p_tank_object_id, p_daytime),p_daytime - 1);
    previous_closing_record := 0;
    ln_cal_consumed := getDailyConsumptionRate(p_tank_object_id, p_daytime) * (p_daytime - previous_daytime);
    FOR mycalfil IN c_sum_filled_vol(p_tank_object_id, previous_daytime, p_daytime) LOOP
        ln_cal_filled := mycalfil.sum_filled_vol;
    END LOOP;
    ln_return := (previous_closing_record - ln_cal_consumed) + ln_cal_filled;
    NULL;

  ELSIF ln_prev_opening IS NULL AND ln_future_opening IS NOT NULL THEN
    --5 previous closing does not exist but future closing exists
    previous_daytime := Nvl(getPrevConnectionDate(p_tank_object_id, p_daytime),p_daytime - 1);
    previous_closing_record := 0;
    ln_cal_consumed := getConsumedVol(p_tank_object_id, p_daytime) * (p_daytime - previous_daytime);
    FOR mycalfil IN c_sum_filled_vol(p_tank_object_id, previous_daytime, p_daytime) LOOP
        ln_cal_filled := mycalfil.sum_filled_vol;
    END LOOP;
    ln_return := (previous_closing_record - ln_cal_consumed) + ln_cal_filled;
    NULL;

  END IF;
  RETURN ln_return;
END getClosingVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRealClosingVol
-- Description    : Returns sum of closing volume for all tanks with selected product
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getDefaultUOM, ec_chem_tank_version, ec_chem_tank_period_status, EcDp_Units
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getRealClosingVol(p_tank_object_id IN VARCHAR2,
                           p_daytime        IN DATE,
                           p_uom            IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_return_uom  ctrl_unit_conversion.to_unit%TYPE;
  lv2_tank_uom    ctrl_unit_conversion.from_unit%TYPE;
  ln_tank_vol     NUMBER;
  ln_retval       NUMBER;


BEGIN
  IF p_uom IS NULL THEN
    lv2_return_uom := getDefaultUOM(p_tank_object_id, p_daytime);
  ELSE
    lv2_return_uom := p_uom;
  END IF;

  lv2_tank_uom := getDefaultUOM(p_tank_object_id, p_daytime);
  ln_tank_vol  := ec_chem_tank_status.grs_vol(p_tank_object_id, p_daytime, '=');
  ln_retval    := EcDp_Unit.convertValue(ln_tank_vol, lv2_tank_uom, lv2_return_uom, p_daytime);

  RETURN ln_retval;

END getRealClosingVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPrevConnectionDate
-- Description    : Returns date for previous connection to chem_product. This to ensure that we dont select
--                  records for another product.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_chem_tank_period, getDefaultMeterFreq
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPrevConnectionDate(p_tank_object_id IN VARCHAR2,
                               p_daytime        IN DATE)
RETURN DATE
--</EC-DOC>
IS
  ld_prev_daytime  DATE;

  CURSOR c_chem_tank_product IS
  SELECT daytime
  FROM chem_tank_product
  WHERE object_id = p_tank_object_id
  AND daytime < p_daytime AND (end_date > p_daytime OR end_date IS NULL);

BEGIN

  FOR mycur IN c_chem_tank_product LOOP
    ld_prev_daytime := mycur.daytime;
  END LOOP;

  RETURN ld_prev_daytime;
END getPrevConnectionDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPrevMeasDate
-- Description    : Returns previous measurement day
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getRealClosingVol, getOpeningVol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPrevMeasDate(p_tank_object_id IN VARCHAR2,
                         p_daytime        IN DATE )

RETURN DATE
--</EC-DOC>
IS
  ld_prev_daytime      DATE;
  ld_prev_conn_daytime DATE;
  ld_return_date       DATE;

BEGIN
  -- make sure we dont select closing date prior current tank - product connection!
  ld_prev_conn_daytime := Nvl(getPrevConnectionDate(p_tank_object_id, p_daytime),p_daytime-1);
  -- get daytime for previous record for the tank.
  FOR lc_prev_daytime IN c_prev_tank_reading_daytime(p_tank_object_id, p_daytime) LOOP
    ld_prev_daytime := lc_prev_daytime.daytime;
  END LOOP;

  IF ld_prev_daytime >= ld_prev_conn_daytime THEN
    -- previous closing date is within current connection
    ld_return_date := ld_prev_daytime;
  ELSIF ld_prev_daytime < ld_prev_conn_daytime THEN
    -- there is no previous reading for this connection. Set previous reading equal start of connection.
    ld_return_date := ld_prev_conn_daytime;
  ELSE
    ld_return_date := NULL;
  END IF;

  RETURN ld_return_date;
END getPrevMeasDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOpeningVol
-- Description    : Returns opening volume for selected tank. Uses previous period's closing volume as opening.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getClosingVol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getOpeningVol(p_tank_object_id IN VARCHAR2,
                       p_daytime        IN DATE,
                       p_uom            IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval        NUMBER := 0;

BEGIN

    ln_retval := getClosingVol(p_tank_object_id, p_daytime-1, p_uom);

  RETURN ln_retval;
END getOpeningVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFilledVol
-- Description    : Returns sum of filled volume for all tanks with selected product
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_TANK_DAY_STATUS, CHEM_TANK_PRODUCT
--
-- Using functions: EcDp_Chemical_Tank.getFilledVol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getFilledVol( p_tank_object_id IN VARCHAR2,
                       p_daytime        IN DATE,
                       p_uom            IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_return_uom   ctrl_unit_conversion.to_unit%TYPE;
  lv2_tank_uom     ctrl_unit_conversion.from_unit%TYPE;
  ln_tank_vol      NUMBER;
  ln_retval        NUMBER := 0;

BEGIN

  IF p_uom IS NULL THEN
    lv2_return_uom := getDefaultUOM(p_tank_object_id, p_daytime);
  ELSE
    lv2_return_uom := p_uom;
  END IF;

  lv2_tank_uom := getDefaultUOM(p_tank_object_id, p_daytime);

  ln_tank_vol  := ec_chem_tank_status.filled_vol(p_tank_object_id, p_daytime, '=');
  ln_retval := EcDp_unit.convertValue(ln_tank_vol, lv2_tank_uom, lv2_return_uom, p_daytime);

  RETURN ln_retval;

END getFilledVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getConsumedVol
-- Description    : : Return consumed for a given date, either stored or calculated for a tank.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_TANK_DAY_STATUS, CHEM_TANK_PRODUCT
--
-- Using functions: EcDp_Chemical_Tank.getConsumedVol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getConsumedVol( p_tank_object_id IN VARCHAR2,
                         p_daytime        IN DATE,
                         p_uom            IN VARCHAR2 DEFAULT NULL
                         )
RETURN NUMBER
--</EC-DOC>
IS

  ln_retval                NUMBER;

  ln_prev_closing          DATE;
  ln_future_closing        DATE;
  diff_prev_future_closing NUMBER;
  ln_cal_filled            NUMBER;
  number_of_days           NUMBER;
  previous_closing_daytime DATE;
  previous_closing_record  NUMBER;
  lv2_return_uom           ctrl_unit_conversion.to_unit%TYPE;
  lv2_tank_uom             ctrl_unit_conversion.from_unit%TYPE;

BEGIN

  SELECT MAX(daytime) into ln_prev_closing FROM CHEM_TANK_STATUS
         WHERE object_id = p_tank_object_id AND daytime < p_daytime AND grs_vol IS NOT NULL;

  SELECT MIN(daytime) into ln_future_closing FROM CHEM_TANK_STATUS
         WHERE object_id = p_tank_object_id AND daytime >= p_daytime AND grs_vol IS NOT NULL;

  IF (ln_prev_closing IS NOT NULL AND ln_future_closing IS NOT NULL) THEN
     diff_prev_future_closing := (getClosingVol(p_tank_object_id, ln_prev_closing) - getClosingVol(p_tank_object_id, ln_future_closing));

     FOR mycalfil IN c_sum_filled_vol(p_tank_object_id, ln_prev_closing+1, ln_future_closing) LOOP
         ln_cal_filled := mycalfil.sum_filled_vol;
     END LOOP;

     number_of_days := (ln_future_closing - ln_prev_closing);
     ln_retval := ((diff_prev_future_closing + ln_cal_filled)/number_of_days);

  ELSIF (ln_prev_closing IS NULL AND ln_future_closing IS NOT NULL) THEN
     previous_closing_daytime := Nvl(getPrevConnectionDate(p_tank_object_id, p_daytime+1),p_daytime - 1);
     previous_closing_record := 0;
     diff_prev_future_closing := previous_closing_record - getClosingVol(p_tank_object_id, ln_future_closing);
     FOR mycalfil IN c_sum_filled_vol(p_tank_object_id, previous_closing_daytime, ln_future_closing) LOOP
         ln_cal_filled := mycalfil.sum_filled_vol;
     END LOOP;

     number_of_days := (ln_future_closing - previous_closing_daytime)+1;

     IF number_of_days > 0 THEN
     	ln_retval := ((diff_prev_future_closing + ln_cal_filled)/number_of_days);
     ELSE
     	ln_retval := NULL;
     END IF;

  ELSIF (ln_prev_closing IS NULL OR ln_future_closing IS NULL) THEN
     --get default consumption rate from column
     ln_retval := getDailyConsumptionRate(p_tank_object_id, p_daytime);
  END IF;

  IF p_uom IS NULL THEN
    lv2_return_uom := getDefaultUOM(p_tank_object_id, p_daytime);
  ELSE
    lv2_return_uom := p_uom;
  END IF;

  lv2_tank_uom := getDefaultUOM(p_tank_object_id, p_daytime);
  ln_retval    := EcDp_Unit.convertValue(ln_retval, lv2_tank_uom, lv2_return_uom, p_daytime);

  RETURN ln_retval;

END getConsumedVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDailyConsumptionRate
-- Description    : Return the value of the DAILY_CONSUMPTION_RATE attribute on CHEM_TANK
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_TANK_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDailyConsumptionRate(p_tank_object_id IN VARCHAR2,
                       p_daytime        IN DATE DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_retval VARCHAR2(300);
  ld_date    DATE;

BEGIN
  ld_date := Nvl(p_daytime, Ecdp_Timestamp.getCurrentSysdate);

  lv2_retval := ec_chem_tank_version.DAILY_CONSUMPTION_RATE(p_tank_object_id, ld_date, '<=');
  RETURN lv2_retval;
END getDailyConsumptionRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : biuSetEndDate
-- Description    : Check for period overlapping and
--                set end_date for previous chemical tank product combination if not exist
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_TANK_PRODUCT
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE biuSetEndDate(p_object_id VARCHAR2, -- CHEM TANK ID
                   p_old_daytime DATE, -- OLD START DATE
                   p_daytime DATE, -- START DATE
                   p_end_date DATE,
                   p_chem_product_id VARCHAR2
                   ) IS

 -- Check for overlapping
     CURSOR c_chem_tank_product(cp_object_id varchar2,
                                cp_old_daytime date,
                                cp_daytime date,
                                cp_end_date date,
                                cp_chem_product_id varchar2)
                                IS

        SELECT 1 one
        FROM chem_tank_product
        WHERE object_id = cp_object_id
        AND ( -- overlapped date period
        (cp_daytime >= daytime AND cp_daytime < end_date)
        OR
        (cp_end_date > daytime AND cp_end_date <= end_date)
        OR
        (cp_daytime <= daytime AND cp_end_date IS NULL)
        OR
        (cp_daytime <= daytime AND cp_end_date >= end_date)
        OR
        (cp_daytime <= daytime AND end_date IS NULL AND cp_end_date > daytime))
        AND NOT
        ( -- not current record
        chem_product_id = cp_chem_product_id
        AND object_id = cp_object_id
        AND daytime = cp_old_daytime
        )
;

 BEGIN

    FOR ITEM IN c_chem_tank_product(p_object_id, p_old_daytime, p_daytime, p_end_date, p_chem_product_id) LOOP
        Raise_Application_Error(-20121, 'The date overlaps with another period');
    END LOOP;

   -- update previous row end date if null
   UPDATE CHEM_TANK_PRODUCT
   SET end_date = p_daytime
   WHERE object_id = p_object_id
   AND daytime < p_daytime
   AND end_date IS NULL;

END biuSetEndDate;

END EcDp_Chemical_Tank;