CREATE OR REPLACE PACKAGE BODY ue_Storage_Lift_Nomination IS
/******************************************************************************
** Package        :  ue_Storage_Lift_Nomination, body part
**
** $Revision: 1.9.2.2 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.04.2006 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -----------------------------------------------------------------------------------------------
**       18.10.2006  rajarsar Tracker 4635 - Added deleteNomination Procedure
** 1.10  12.09.2012  meisihil   ECPD-20962: Added function setBalanceDelta
**       24.01.2013  meisihil  ECPD-20962: Added functions aggrSubDayLifting, calcSubDayLifting to support liftings spread over hours
** -------  ------   ----- -----------------------------------------------------------------------------------------------
*/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : expectedUnloadDate
-- Description    : Returns the expected unload date for the parcel
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
FUNCTION expectedUnloadDate(p_parcel_no NUMBER)
RETURN DATE
--</EC-DOC>
IS

BEGIN
	RETURN NULL;
END expectedUnloadDate;

---------------------------------------------------------------------------------------------------
-- Function       : deleteNomination
-- Description    : Delete all nominations in the selected period that is not fixed and where cargo status is not Official and ready for harbour
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
PROCEDURE deleteNomination(p_storage_id VARCHAR2,p_from_date DATE,p_to_date DATE)
--</EC-DOC>
IS
BEGIN
	NULL;
END deleteNomination;

---------------------------------------------------------------------------------------------------
-- Function       : validateSplit
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
PROCEDURE validateSplit(p_parcel_no NUMBER)
--</EC-DOC>
IS
BEGIN
	--NULL;
  -- Override the call to EcBp_Storage_Lift_Nomination if project spesific code.
  Ecbp_Storage_Lift_Nomination.validateSplit(p_parcel_no);
END validateSplit;

---------------------------------------------------------------------------------------------------
-- Function       : getDefaultSplit
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
PROCEDURE getDefaultSplit(p_parcel_no NUMBER)
--</EC-DOC>
IS

cursor c_get_lifting_account(b_parcel_no number) is
select lifting_account_id
from storage_lift_nomination t
where t.parcel_no = b_parcel_no;

BEGIN

  -- Override the call to EcBp_Storage_Lift_Nomination if project spesific code.
  FOR r_get_la IN c_get_lifting_account(p_parcel_no) loop
      IF r_get_la.lifting_account_id IS NOT NULL THEN
       EcBp_Storage_Lift_Nomination.createUpdateSplit(p_parcel_no, NULL, r_get_la.lifting_account_id);
      END IF;
  END LOOP;


END getDefaultSplit;

---------------------------------------------------------------------------------------------------
-- Function       : setBalanceDelta
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
PROCEDURE setBalanceDelta(p_parcel_no NUMBER)
--</EC-DOC>
IS

	CURSOR c_nomination(cp_parcel_no number)
	IS
		SELECT nvl(purge_qty, 0) + nvl(cooldown_qty, 0) + nvl(vapour_return_qty, 0) + nvl(lauf_qty, 0) balance_delta_qty,
		       nvl(purge_qty2, 0) + nvl(cooldown_qty2, 0) + nvl(vapour_return_qty2, 0) + nvl(lauf_qty2, 0) balance_delta_qty2,
		       nvl(purge_qty3, 0) + nvl(cooldown_qty3, 0) + nvl(vapour_return_qty3, 0) + nvl(lauf_qty3, 0) balance_delta_qty3
		  FROM storage_lift_nomination
		 WHERE parcel_no = cp_parcel_no;

BEGIN

  -- Override the call to EcBp_Storage_Lift_Nomination if project spesific code.
  FOR c_nom IN c_nomination(p_parcel_no) loop
      UPDATE storage_lift_nomination set balance_delta_qty = c_nom.balance_delta_qty, balance_delta_qty2 = c_nom.balance_delta_qty2, balance_delta_qty3 = c_nom.balance_delta_qty3
       WHERE parcel_no = p_parcel_no;
  END LOOP;


END setBalanceDelta;

---------------------------------------------------------------------------------------------------
-- Function       : aggrSubDayLifting
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
FUNCTION aggrSubDayLifting(p_parcel_no NUMBER, p_daytime DATE, p_column VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS
	ln_result NUMBER;
BEGIN
	ln_result := EcBp_Storage_Lift_Nomination.aggrSubDayLifting(p_parcel_no, p_daytime, p_column, p_xtra_qty);
	RETURN ln_result;
END aggrSubDayLifting;

---------------------------------------------------------------------------------------------------
-- Procedure      : calcSubDayLifting
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
PROCEDURE calcSubDayLifting(p_parcel_no NUMBER)
--</EC-DOC>
IS
BEGIN
	EcBp_Storage_Lift_Nomination.calcSubDayLifting(p_parcel_no);
END calcSubDayLifting;

END ue_Storage_Lift_Nomination;