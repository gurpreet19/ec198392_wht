CREATE OR REPLACE PACKAGE BODY EcBp_Contract IS
/****************************************************************
** Package        :  EcBp_Contract; body part
**
** $Revision: 1.1 $
**
** Purpose        :  Handles validation on class Contract
**
** Documentation  :  www.energy-components.com
**
** Created        :  01.12.2005	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
**************************************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateContractYearStart
-- Description    : Validates CONTRACT_YEAR_START.
--
-- Preconditions  :
-- Postconditions : Possible unhandled application exceptions
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Validates that the contract year offset is in the range -11 .. 11 (inclusive).
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateContractYearStart(p_CONTRACT_YEAR_START NUMBER)
--</EC-DOC>
IS
BEGIN
	IF NOT p_CONTRACT_YEAR_START BETWEEN -11 AND 11 THEN
		RAISE_APPLICATION_ERROR(-20400, 'Contract Year Start must be between -11 and 11');
	END IF;
END validateContractYearStart;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateContractDayStart
-- Description    : Validates CONTRACT_DAY_START.
--
-- Preconditions  :
-- Postconditions : Possible unhandled application exceptions
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Validates that the contract day offset is on the format HH24:MI.
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateContractDayStart(p_contract_day_start VARCHAR2)
--</EC-DOC>
IS
   ln_tmp   INTEGER;
   lv2_tmp  VARCHAR2(10);
BEGIN
   -- Check that the string ends with :00
  	lv2_tmp := SUBSTR(p_contract_day_start,LENGTH(p_contract_day_start)-2);
  	IF lv2_tmp IS NULL OR lv2_tmp<>':00' THEN
      RAISE_APPLICATION_ERROR(-20401, 'Contract Day Start must have the format HH:00, where HH is between 00 and 23.');
  	END IF;

  	-- Check that the string before the : is one or two characters and don't contain a point or comma
  	lv2_tmp := SUBSTR(p_contract_day_start,1,LENGTH(p_contract_day_start)-3);
  	IF lv2_tmp IS NULL OR LENGTH(lv2_tmp)=0 OR LENGTH(lv2_tmp)>2 OR INSTR(lv2_tmp,'.')>0 OR INSTR(lv2_tmp,',')>0 THEN
      RAISE_APPLICATION_ERROR(-20401, 'Contract Day Start must have the format HH:00, where HH is between 00 and 23.');
  	END IF;

  	-- Check that the string before the : is a number between 0 and 23 (inclusive)
  	ln_tmp := TO_NUMBER(lv2_tmp);
  	IF ln_tmp IS NULL OR ln_tmp<0 OR ln_tmp>23 THEN
      RAISE_APPLICATION_ERROR(-20401, 'Contract Day Start must have the format HH:00, where HH is between 00 and 23.');
  	END IF;

EXCEPTION WHEN OTHERS THEN
   RAISE_APPLICATION_ERROR(-20401, 'Contract Day Start must have the format HH:00, where HH is between 00 and 23.');
END validateContractDayStart;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateContract
-- Description    : Validates the format and values for the START_YEAR and START_DAY contract attributes.
--
-- Preconditions  :
-- Postconditions : Possible unhandled application exceptions
--
-- Using tables   :
--
-- Using functions: validateContractYearStart
--                  validateContractDayStart
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateContract(p_CONTRACT_YEAR_START NUMBER, p_CONTRACT_DAY_START VARCHAR2)
--</EC-DOC>
IS
BEGIN
	validateContractYearStart(p_CONTRACT_YEAR_START);
	validateContractDayStart(p_CONTRACT_DAY_START);
END validateContract;


END EcBp_Contract;