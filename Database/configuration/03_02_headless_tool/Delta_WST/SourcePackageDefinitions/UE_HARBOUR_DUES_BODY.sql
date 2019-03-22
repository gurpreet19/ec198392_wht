CREATE OR REPLACE PACKAGE BODY UE_HARBOUR_DUES IS
/******************************************************************************
** Package        :  UE_HARBOUR_DUES, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Includes user-exit functionality for harbour dues screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.11.2011 Carsten Claussen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -----------------------------------------------------------------------------------------------
*/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validate_harbour_dues
-- Description    : Validates new Harbour Dues Items
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
PROCEDURE validate_harbour_dues(p_due_code VARCHAR2, p_due_item_code  VARCHAR2, p_start_date DATE, p_end_date DATE)

--</EC-DOC>
IS

  e_prior_start_date EXCEPTION;

BEGIN

  IF ec_harbour_dues.prev_equal_daytime (p_due_code, p_start_date) > p_start_date THEN
    RAISE e_prior_start_date;
  END IF;

EXCEPTION
  WHEN e_prior_start_date THEN
       RAISE_APPLICATION_ERROR(-20218,'Due item start date
	   can not be prior to Due Types start date');

  WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20000,'Unknown error occured in UE.');

END validate_harbour_dues;
END UE_HARBOUR_DUES;