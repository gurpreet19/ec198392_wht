CREATE OR REPLACE PACKAGE BODY EcDp_Contract IS
/****************************************************************
** Package        :  EcDp_Contract; body part
**
** $Revision: 1.6 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2005	Kari Sandvik
**
** Modification history:
**
** Date        Whom     Change description:
** ----------  -----    -------------------------------------------
** 02/03/2006  kaurrnar TD5691: Fixed bug in getContractDayOffsetHours
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getContractYearStartDate
-- Description    : Returns the first contract day in the given contract year. Note that the returned
--                  value is the logical contract date, not the actual time. This can be found by applying
--                  the getContractDateStartTime function to the returned value.
--
-- Preconditions  : The input date should be the logical contract year (zero month/day/hour/minutes/seconds).
-- Postconditions :
--
-- Using tables   : contract
--
-- Using functions:
--
-- Configuration
-- required       : One and only one value must exist for the START_YEAR contract attribute.
--
-- Behaviour      : This function assumes that there is only one value for the START_YEAR attribute,
--                  and therefore performs a simple SELECT INTO statement go get the value of this attribute
--                  without any daytime checking. Otherwise it would be almost impossible to determine the correct
--                  daytime to use as entry date to the attribute table.
--                  Note that an exception is thrown if the input date precondition is not met.
--
---------------------------------------------------------------------------------------------------
FUNCTION getContractYearStartDate(
  p_object_id     VARCHAR2,
  p_contract_year DATE
)
RETURN DATE
--</EC-DOC>
IS

   ln_mth               NUMBER;
   CURSOR c_mth IS
      SELECT start_year AS offset
      FROM contract
      WHERE object_id = p_object_id;

BEGIN

   -- Validate p_contract_year
   IF p_contract_year IS NULL OR p_contract_year <> TRUNC(p_contract_year,'yyyy') THEN
      RAISE_APPLICATION_ERROR(-20000,'getContractYearStartDate requires p_contract_year to be a non-NULL year value.');
   END IF;

   FOR r_mth IN c_mth LOOP
      ln_mth := r_mth.offset;
   END LOOP;

   RETURN trunc(ADD_MONTHS(p_contract_year, ln_mth),'mm');

END getContractYearStartDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getContractYear
-- Description    : Returns the contract year that the given contract day belongs to.
--
-- Preconditions  : The input date should be the logical contract date (zero hour/minutes/seconds).
-- Postconditions : The returned value is the logical contract year, which might differ from the calendar year.
--
-- Using tables   :
--
-- Using functions: ec_contract.start_year
--
-- Configuration
-- required       : The START_YEAR contract attribute must have a value
--
-- Behaviour      : Truncates the date to month level to get the "contract month". The contract
--                  year start offset (in whole months) is the subtracted to convert from
--                  contract year to calendar year. Finally the result is truncated to year to get
--                  the logical contrat year (01.01 00:00:00 of that year).
--                  Note that an exception is thrown if the input date precondition is not met.
--
---------------------------------------------------------------------------------------------------
FUNCTION getContractYear(
  p_object_id     VARCHAR2,
  p_contract_day  DATE
)
RETURN DATE
--</EC-DOC>
IS
  ld_mth          DATE;
  ln_mth_offset   NUMBER;
BEGIN

   -- Validate p_contract_day
   IF p_contract_day IS NULL OR p_contract_day <> TRUNC(p_contract_day) THEN
      RAISE_APPLICATION_ERROR(-20000,'getContractYear requires p_contract_day to be a non-NULL day value.');
   END IF;

   -- Get the year offset from the contract
   ln_mth_offset := ec_contract.start_year(p_object_id);
   -- Find the contract month that p_contract_day is in
   ld_mth := TRUNC(p_contract_day,'mm');
   -- Subtract the offset to get the correct year!
   ld_mth := ADD_MONTHS(ld_mth, -ln_mth_offset);

   RETURN TRUNC(ld_mth,'yyyy');

END getContractYear;


END EcDp_Contract;