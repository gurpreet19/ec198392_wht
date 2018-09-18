CREATE OR REPLACE PACKAGE BODY ue_Opportunity IS
/****************************************************************
** Package        :  ue_Opportunity; head part
**
** $Revision: 1.8 $
**
** Purpose        :  Handles Opportunity operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  28.09.2016 thote sandeep
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  -----     -------------------------------------------
** 28.09.2016  thotesan  ECPD-36215: Initial Version.
** 17.10.2016  sharawan  ECPD-39295: Added procedure includeOpportunity and confirmOpportunity
**                       for Opportunities tab in Forecast Manager. Added private function isFcstCargo
**                       to check if the previous cargo is in new forecast
** 14.12.2016  thotesan  ECPD-41647: Added procedure ValidateCargo and modified includeOpportunity to add update statement to mark opportunity as NULL for reassignment of cargo
** 29.08.2017  baratmah  ECPD-42164: Modified procedure ValidateCargo to handle null condition of forecast and cargo.
**************************************************************************************************/

---------------------------------------------------------------------------------------------------
-- Function       : isFcstCargo
-- Description    : This function is used to check whether the cargo configured for the selected opportunity is within the selected forecast.
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
-- Behaviour      : Private
--
---------------------------------------------------------------------------------------------------
FUNCTION isFcstCargo (p_cargo_no NUMBER,
                      p_new_forecast_id VARCHAR2
                       ) RETURN BOOLEAN
--</EC-DOC>
IS
  ln_cargo_count NUMBER;

BEGIN
  SELECT count(c.cargo_no)
    INTO ln_cargo_count
    FROM cargo_fcst_transport c
   WHERE c.forecast_id = p_new_forecast_id
     and c.cargo_no = p_cargo_no;

   IF ln_cargo_count >=1 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
END isFcstCargo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyOpportunity
-- Description    : insert into OPPORTUNITY for copy functionality
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OPPORTUNITY
--
-- Using functions: EcDp_Opportunity.instantiateOpportunityGenTerm()
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE copyOpportunity(p_opportunity_name   VARCHAR2,
                           p_daytime            DATE,
                           p_end_date           DATE,
                           p_company_id         VARCHAR2,
                           p_contract_id        VARCHAR2,
                           p_term_code          VARCHAR2,
                           p_opportunity_status VARCHAR2,
                           p_period             VARCHAR2) IS
  ln_opportunity_no NUMBER;

BEGIN

  INSERT INTO OPPORTUNITY
    (OPPORTUNITY_NAME,
     DAYTIME,
     END_DATE,
     COMPANY_ID,
     CONTRACT_ID,
     TERM_CODE,
     OPPORTUNITY_STATUS,
     PERIOD)
  VALUES
    (p_opportunity_name,
     p_daytime,
     p_end_date,
     p_company_id,
     p_contract_id,
     p_term_code,
     p_opportunity_status,
     p_period);

  SELECT MAX(OPPORTUNITY_NO) INTO ln_opportunity_no FROM OPPORTUNITY;

  EcDp_Opportunity.instantiateOpportunityGenTerm(ln_opportunity_no,
                               p_opportunity_name,
                               p_daytime,
                               p_end_date,
                               p_company_id,
                               p_contract_id,
                               p_term_code,
                               p_opportunity_status,
                               p_period);

END copyOpportunity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : includeOpportunity
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: isFcstCargo is checking upon whether the cargo configured for the selected opportunity is within the selected forecast.
--                  A validation error message is thrown when the selected opportunity does not have cargo associated to it.
--                  Different configuration can be customized accordingly.
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE includeOpportunity(p_opportunity_no NUMBER,
                   p_forecast_id VARCHAR2)
--</EC-DOC>
IS
  CURSOR c_cargo_nomqty(cp_forecast_id VARCHAR2, cp_cargo_no NUMBER)
	IS
		SELECT parcel_no
		  FROM stor_fcst_lift_nom
		 WHERE forecast_id = cp_forecast_id
		   AND cargo_no = cp_cargo_no
       FOR UPDATE;

  ln_cargo_no NUMBER;

BEGIN
  -- check the cargo is in the new forecast to reset the Cargo No
  IF isFcstCargo(ec_opportunity_gen_term.cargo_no(p_opportunity_no), p_forecast_id) = TRUE THEN
     --Get the cargo assigned to the opportunity
     ln_cargo_no := ec_opportunity_gen_term.cargo_no(p_opportunity_no);
     -- Update stor_fcst_lift_nom with Opportunity = NULL if new cargo has been assigned to Opportunity
       UPDATE stor_fcst_lift_nom n
          SET n.Opportunity_No = NULL
        WHERE n.cargo_no =
              (SELECT s.cargo_no
                 FROM stor_fcst_lift_nom s
                WHERE s.forecast_id = p_forecast_id
                  AND s.opportunity_no = p_opportunity_no)
          AND n.forecast_id = p_forecast_id;

     --Update stor_fcst_lift_nom with opportunity_no for the selected forecast
     FOR cur_update_cargo IN c_cargo_nomqty(p_forecast_id, ln_cargo_no) LOOP
        UPDATE stor_fcst_lift_nom n
           SET n.grs_vol_nominated = ec_opportunity_gen_term.qty(p_opportunity_no),
               n.opportunity_no = p_opportunity_no
         WHERE n.parcel_no = cur_update_cargo.parcel_no
           AND n.forecast_id = p_forecast_id;
     END LOOP;
  ELSE
     ln_cargo_no := NULL;
     RAISE_APPLICATION_ERROR(-20581, 'There is no cargo/nominations linked to this Opportunities.');
  END IF;

END includeOpportunity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : confirmOpportunity
-- Description    :
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
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE confirmOpportunity(p_opportunity_no NUMBER)
--</EC-DOC>
IS

BEGIN

 -- update table OPPORTUNITY and OPPORTUNITY_GEN_TERM to status Approve
  UPDATE OPPORTUNITY_GEN_TERM
     SET OPPORTUNITY_STATUS = 'C'
   WHERE OPPORTUNITY_NO = p_opportunity_no;

  UPDATE OPPORTUNITY
     SET OPPORTUNITY_STATUS = 'C'
   WHERE OPPORTUNITY_NO = p_opportunity_no;

END confirmOpportunity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : ValidateCargo
-- Description    : Validates cargo against opportunity range.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_fcst_lift_nom
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE ValidateCargo(p_forecast_id VARCHAR2,p_cargo_no NUMBER,p_start_date DATE,p_end_date DATE)
IS
lv_count NUMBER;
BEGIN

 SELECT count(*)
  INTO lv_count
  FROM stor_fcst_lift_nom n
  WHERE n.forecast_id = p_forecast_id
   AND n.cargo_no = p_cargo_no
   AND nom_firm_date BETWEEN p_start_date and p_end_date;

  IF  p_forecast_id IS NULL OR p_cargo_no IS NULL THEN
  lv_count :=1;
  END IF;

   IF lv_count = 0 THEN
     RAISE_APPLICATION_ERROR(-20582, 'The Cargo selected is Outside the Opportunity range');
   END IF;

END ValidateCargo;
END ue_Opportunity;