CREATE OR REPLACE PACKAGE BODY EcBp_Contract_Mth_Adjustment IS
/****************************************************************
** Package        :  EcBp_Contract_Mth_Adjustment; body part
**
** $Revision: 1.1 $
**
** Purpose        :  Handles validation for screen Monthly Contract Allocation Ajustment
**
** Documentation  :  www.energy-components.com
**
** Created        :  15.12.2005 Stian Skj�tad
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------

**************************************************************************************************/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getAllocatedCompanyAdjustedVol
-- Description    : This function summarizes the total allocated delivered to a contract and adjust
--                  that number with potential adjustments. The function might have to support
--                  different dimension of all allocated numbers, e.g. with and without composition.
--
-- Preconditions  :
-- Postconditions : This function is no used in the screen, but should be used by the reporting layer.
--
-- Using tables   : cntr_mth_cpy_alloc_adj
--
-- Using functions: getAllocatedCompanyVol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAllocatedCompanyAdjustedVol (p_company_id VARCHAR2,
                                 p_object_id  VARCHAR2,
                                 p_daytime    DATE
)
RETURN NUMBER
--</EC-DOC>
IS

   CURSOR c_adj_alloc (cp_company_id VARCHAR2,
                    cp_object_id VARCHAR2,
                    cp_daytime DATE) IS

       SELECT SUM(NVL(ALLOC_QTY, 0) + NVL(credit, 0) - NVL(debit, 0)) total
          FROM cntr_mth_cpy_alloc_adj
          WHERE object_id=cp_object_id
          AND   company_id=cp_company_id
          AND   daytime=cp_daytime;

   ln_adjusted_value NUMBER;

BEGIN
      FOR one_row IN c_adj_alloc(p_company_id, p_object_id, p_daytime) LOOP
           ln_adjusted_value := one_row.total;
      END LOOP;

      RETURN ln_adjusted_value;
END getAllocatedCompanyAdjustedVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateAdjustment
-- Description    : The function should validate
--   	            1. That the total added and subtracted for the month is the same for all contracts.
--
-- Preconditions  :
-- Postconditions : Throw application exception if validation failed.
--
-- Using tables   :
--
-- Using functions: ec_cntr_mth_cpy_alloc_adj.ALLOC_QTY, ec_cntr_mth_cpy_alloc_adj.DEBIT
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateAdjustment(p_company_id VARCHAR2,p_object_id  VARCHAR2,p_daytime    DATE)
--</EC-DOC>
IS

   ln_alloc    NUMBER;
   ln_debit    NUMBER;

BEGIN
	-- validate if allocated delivered is missing or less than debit
	ln_alloc := ec_cntr_mth_cpy_alloc_adj.ALLOC_QTY(p_object_id, p_company_id, p_daytime, '<=');
	ln_debit := ec_cntr_mth_cpy_alloc_adj.DEBIT(p_object_id, p_company_id, p_daytime, '<=');

	IF (NVL(ln_alloc, 0) < NVL(ln_debit, 0)) THEN
		RAISE_APPLICATION_ERROR (-20517, 'The total subtracted is higher than allocated to the contract for the selected company');
	END IF;

END validateAdjustment;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateTotalAdjustment
-- Description    : The function should validate
--   	            That the total subtracted of a contract for a company is equal or less
--                     than total allocated delivered
--
-- Preconditions  :
-- Postconditions : Throw application exception if validation failed.
--
-- Using tables   : cntr_mth_cpy_alloc_adj
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateTotalAdjustment(p_company_id VARCHAR2, p_daytime    DATE)
--</EC-DOC>
IS

	CURSOR 		c_adjusted_diff (cp_company_id VARCHAR2,
							cp_daytime DATE) IS
	SELECT	sum(credit) credit, sum(debit) debit
	FROM  	cntr_mth_cpy_alloc_adj
	WHERE 	company_id=cp_company_id
			AND	daytime=cp_daytime;

   ln_credit    NUMBER;
   ln_debit    NUMBER;

BEGIN
	-- validate total values
	FOR onerow IN c_adjusted_diff(p_company_id, p_daytime) LOOP
      ln_credit := onerow.credit;
      ln_debit := onerow.debit;

      IF (NVL(ln_credit,0) <> NVL(ln_debit,0)) THEN
         RAISE_APPLICATION_ERROR (-20518, 'The total added and subtracted on the contracts is not the same');
      END IF;
   END LOOP;

END validateTotalAdjustment;


END EcBp_Contract_Mth_Adjustment;