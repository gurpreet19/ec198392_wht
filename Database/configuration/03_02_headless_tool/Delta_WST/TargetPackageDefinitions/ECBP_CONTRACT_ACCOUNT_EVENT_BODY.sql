CREATE OR REPLACE PACKAGE BODY EcBp_Contract_Account_Event IS
/******************************************************************************
** Package        :  EcBp_Contract_Account_Event, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Class action for cntr_ACC_DAY_EVENT
**
** Documentation  :  www.energy-components.com
**
** Created        :  12.12.2005	Stian Skjørestad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
**
********************************************************************/




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateQty
-- Description    : If the is_mandatory is set to Y for the event type in CNTR_ACC_EVENT_TYPE  and the qty is empty, an error should be returned.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :                                                                                                                            --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Raises application error if quantity is empty for mandatory event types
--
---------------------------------------------------------------------------------------------------

PROCEDURE validateQty(
  p_contract_id       VARCHAR2,
  p_account_code			VARCHAR2,
  p_event_type				VARCHAR2,
  p_qty						NUMBER
)
--</EC-DOC>
IS

CURSOR c_mandatory_qty(cp_contract_id VARCHAR2, cp_account_code VARCHAR2, cp_event_type VARCHAR2)
IS
SELECT	c.is_mandatory
FROM	cntr_acc_event_type c
WHERE	c.object_id = cp_contract_id AND
		c.account_code = cp_account_code AND
		c.event_type = cp_event_type;

BEGIN

FOR c_row IN c_mandatory_qty(p_contract_id, p_account_code, p_event_type) LOOP
IF (c_row.is_mandatory='Y' AND p_qty IS NULL) THEN
RAISE_APPLICATION_ERROR(-20522, 'The Qty is mandatory for the contract account and event type');
END IF;

END LOOP;

END validateQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setRecordStatus
-- Description    : Updates record_status for rows that have accept_ind checked ('Y')
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :   cntr_account_event                                                                                                                         --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setRecordStatus(
  p_object_id		       	VARCHAR2,
  p_account_code			VARCHAR2,
  p_event_type				VARCHAR2,
  p_daytime					DATE,
  p_user					VARCHAR2 DEFAULT NULL
  )
--</EC-DOC>

IS
BEGIN

UPDATE 	cntr_account_event
SET		record_status = 'A', last_updated_by = p_user
WHERE	object_id = p_object_id AND
		account_code = p_account_code AND
		event_type = p_event_type AND
		daytime = p_daytime AND
		accept_ind = 'Y';

UPDATE 	cntr_account_event
SET		record_status = 'P', last_updated_by = p_user
WHERE	object_id = p_object_id AND
		account_code = p_account_code AND
		event_type = p_event_type AND
		daytime = p_daytime AND
		(accept_ind = 'N' OR accept_ind IS NULL);


END setRecordStatus;
END EcBp_Contract_Account_Event;