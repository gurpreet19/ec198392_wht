CREATE OR REPLACE PACKAGE BODY EcDp_Sales_Contract IS
/******************************************************************************
** Package        :  EcDp_Sales_Contract, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Encapsulates functionality and values that stem from contract attributes
**
** Documentation  :  www.energy-components.com
**
** Created  : 13.12.2004 Bent Ivar Helland
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   	Initial version (first build / handover to test)
** 03.01.2005  BIH   	Added getMinimumDailyNominationQty and getMaximumDailyNominationQty
** 11.01.2005  BIH   	Added / cleaned up documentation
** 18.10.2005  SKJORSTI Added function getActualDCQ
** 19.10.2005  SKJORSTI	Renamed function getDCQ to getRawDCQ
** 06.12.2005  SKJORSTI Updated function getContractYearStartDate. Changed from SCTR_VERSION.CONTRACT_YEAR_START to CONTRACT.START_YEAR (ti3102)
** 06.12.2005  SKJORSTI Updated function getAttributeDaytime. Changed from using table SALES_CONTRACT to use table CONTRACT (ti3102)
** 14.12.2005  EIDEEKRI	Removed getAnnualPlannedProductionDays, getMonthlyTakeOrPayLimit, getYearlyTakeOrPayLimit
** 15.12.2005  SKJORSTI Moved procedure validateDCQ from ecbp_gas_sales_contract (deprecated) to here.
** 14.07.2006  SKJORSTI TI3928: Updated function getRawDCQ and getActualDCQ to retrieve the DCQ attribute from the contract.
** 21.07.2006  SKJORSTI	TI3928: Changed getRawDCQ to use contract_day instead of contract_year
** 29.12.2006  KAURRJES ECPD-4793: Changed DCQ to NUMBER instead of INTEGER in the validateDCQ procedure.
********************************************************************/


--<EC-DOC>


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRawDCQ
-- Description    : Returns the DCQ (Daily Contract Quantity) for a given contract day.
--
-- Preconditions  : The input date should be the logical contract date (zero hour/minutes/seconds).
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getContractYear
--                  ecdp_contract_attribute.getAttributeNumber
--
-- Configuration
-- required       :
--
-- Behaviour      : Retrieves DCQ attribute-value from the contract. This might be a user-exit.
--                  Note that an exception is thrown if the input date precondition is not met.
--
---------------------------------------------------------------------------------------------------
FUNCTION getRawDCQ(
  p_object_id     VARCHAR2,
  p_contract_day  DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ld_contract_year  DATE;
BEGIN
   -- Validate p_contract_day
   IF p_contract_day IS NULL OR p_contract_day <> TRUNC(p_contract_day) THEN
      RAISE_APPLICATION_ERROR(-20000,'getRawDCQ requires p_contract_day to be a non-NULL day value.');
   END IF;

   --ld_contract_year := EcDp_Contract.getContractYear(p_object_id, p_contract_day);

   RETURN ecdp_contract_attribute.getAttributeNumber(p_object_id, 'DCQ', p_contract_day);
END getRawDCQ;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getActualDCQ
-- Description    : Returns the Actual DCQ (Daily Contract Quantity) for a given contract day. Either the original DCQ value, or an overrided value due to
--		    planned delivery restrictions IF existing.
--
-- Preconditions  : The input date should be the logical contract date (zero hour/minutes/seconds).
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Contract.getContractYear
--                  getRawDCQ
--		    ec_cntr_day_restriction.DCQ
--
-- Configuration
-- required       :
--
-- Behaviour      : IF an overrided DCQ value EXISTS, this one will be returned. Else getRawDCQ is returned.
--                  Note that an exception is thrown if the input date precondition is not met.
---------------------------------------------------------------------------------------------------
FUNCTION getActualDCQ(
  p_object_id     VARCHAR2,
  p_contract_day  DATE
)
RETURN NUMBER
--</EC-DOC>
IS
   ld_contract_year  DATE;
   v_dcq NUMBER;
BEGIN
   -- Validate p_contract_day
   IF p_contract_day IS NULL OR p_contract_day <> TRUNC(p_contract_day) THEN
      RAISE_APPLICATION_ERROR(-20000,'getActualDCQ requires p_contract_day to be a non-NULL day value.');
   END IF;

   v_dcq := ec_cntr_day_restriction.DCQ(p_object_id, p_contract_day);

   IF v_dcq IS NOT NULL THEN
   RETURN v_dcq;
   END IF;

   RETURN getRawDCQ(p_object_id,p_contract_day);
END getActualDCQ;


--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : checkRelations                                                              --
-- Description    : Raises an exception if attemting to store a relation that overlaps          --
--					an already existing realtion, or if attempting to store a relation with     --
--                  end date exceeding the object end date of the related objects	            --
--                                                                                              --
-- Preconditions  : 																			--
-- Postcondition  :                                                                             --
-- Using Tables   : sctr_delivery_pnt_usage														--
--                                                                                              --
-- Using functions: ecdp_objects.GetObjEndDate													--
--                  																			--
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
PROCEDURE checkRelations(

		p_contract_id	VARCHAR2,
		p_delpt_id		VARCHAR2,
		p_daytime		DATE,
		p_end_date		DATE
		)

		IS
			li_conflict_record_count	INTEGER;
			ld_contract_end_date	DATE := ecdp_objects.GetObjEndDate(p_contract_id);
			ld_delpt_end_date	    DATE := ecdp_objects.GetObjEndDate(p_delpt_id);
			ld_delpt_start_date	    DATE := ecdp_objects.GetObjStartDate(p_delpt_id);

		BEGIN

		SELECT COUNT(*)
		INTO li_conflict_record_count
		FROM nomination_point
		WHERE contract_id = p_contract_id AND
		delivery_point_id = p_delpt_id AND
		start_date <> p_daytime AND
		nvl(p_end_date,start_date+1) > start_date AND
		p_daytime < nvl(end_date,p_daytime + 1);
		IF li_conflict_record_count > 0 THEN
			RAISE_APPLICATION_ERROR(-20511,'You are not allowed to store because an overlapping relation for already exist between contract: '||EcDp_Objects.GetObjName(p_contract_id,p_daytime)||' and delivery point: '||EcDp_Objects.GetObjName(p_delpt_id,p_daytime) );
		ELSE
			IF p_daytime < ld_delpt_start_date THEN
				RAISE_APPLICATION_ERROR(-20109,'The start date of the relation can not be prior to the object_start_date of delivery point: '||EcDp_Objects.GetObjName(p_delpt_id,p_daytime));
			ELSE
				IF p_end_date > nvl(ld_contract_end_date,p_end_date + 1) THEN
					RAISE_APPLICATION_ERROR(-20110,'The end date of the relation can not exceed the object_end_date of contract: '||EcDp_Objects.GetObjName(p_contract_id,p_daytime));
				ELSE
					IF p_end_date > nvl(ld_delpt_end_date,p_end_date + 1) THEN
						RAISE_APPLICATION_ERROR(-20110,'The end date of the relation can not exceed the object_end_date of delviery point: '||EcDp_Objects.GetObjName(p_delpt_id,p_daytime));
					END IF;
				END IF;
			END IF;
		END IF;
	END;

	--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateDCQ
-- Description    : Validate Daily Contract Quantity
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Raises application error if trying to insert or update DCQ to be less than 0 or larger than initial DCQ defined in contract
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateDCQ(p_object_id VARCHAR2,
                      p_contract_day  DATE,
                      p_adjusted_dcq NUMBER)
--</EC-DOC>
IS
ln_dcq NUMBER := getRawDCQ(p_object_id, p_contract_day);

BEGIN

   IF NOT p_adjusted_dcq BETWEEN 0 AND ln_dcq THEN
      RAISE_APPLICATION_ERROR(-20519, 'Adjusted DCQ must be a number between 0 and contract DCQ - ' || ln_dcq);
   END IF;

END validateDCQ;

END EcDp_Sales_Contract;