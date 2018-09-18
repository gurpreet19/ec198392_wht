CREATE OR REPLACE PACKAGE BODY EcDp_Contract_Account IS
/****************************************************************
** Package        :  EcDp_Contract_Account; body part
**
** $Revision:  $
**
** Purpose        :  Encapsulates functionality and values that stem from contract accounts
**
** Documentation  :  www.energy-components.com
**
** Created        :  21.08.2015	sharawan
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 21.08.2015	sharawan	ECPD-31682: Initial Version - Added validation logic procedure for Contract Account screen
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validate
-- Description    : Validation logic that will be called upon save on CONTRACT_ACCOUNT class
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
PROCEDURE validate(p_contract_id VARCHAR2,
				   p_account_code VARCHAR2)
--</EC-DOC>
IS

-- cursor to find contract account
CURSOR c_account (cp_object_id VARCHAR2, cp_account_code VARCHAR2)
	IS
		SELECT	ec_contract.object_code(a.object_id) contract_code,
            a.interface_to_revenue,
            a.delivery_point_id,
            a.price_object_id,
            a.price_concept_code,
            a.line_item_based_type,
            a.product_id,
			a.qty1_revn_mapping --added to retrieve qty1 revn mapping value
		FROM	contract_account a
		WHERE	a.object_id = cp_object_id
			AND	a.account_code = cp_account_code;

BEGIN

    FOR curAcc IN c_account(p_contract_id, p_account_code) LOOP
      IF NVL(curAcc.interface_to_revenue, 'N') = 'Y' THEN

        IF curAcc.delivery_point_id IS NULL THEN
           Raise_Application_Error(-20407, 'Delivery Point must be set.');
        END IF;

        IF curAcc.price_object_id IS NULL THEN
           IF curAcc.product_id IS NULL THEN
              Raise_Application_Error(-20408, 'Product is required when Price Object is not set.');
           END IF;
           IF curAcc.price_concept_code IS NULL THEN
              Raise_Application_Error(-20409, 'Price Concept Code is required when Price Object is not set.');
           END IF;
        END IF;

		--validation to check QTY1 mapping is set
        IF curAcc.Qty1_Revn_Mapping IS NULL and NVL(curAcc.line_item_based_type,'QTY') = 'QTY'  THEN
          Raise_Application_Error(-20410, 'Revenue Mapping QTY1 must be set when Interface to Revenue has been set to Yes.');
        END IF;

      END IF;
    END LOOP;

END validate;

END EcDp_Contract_Account;