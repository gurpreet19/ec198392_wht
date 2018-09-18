CREATE OR REPLACE PACKAGE BODY ue_demurrage IS
/******************************************************************************
** Package        :  ue_demurrage, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Includes user-exit functionality for demurrage
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.05.2007 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -----------------------------------------------------------------------------------------------
** 21.12.2012  chooysie Add demurrage_type as parameter to findCarrierLaytimeAllowance
*/

  --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : finDefaultDemurrageRate
-- Description    : Finds default demurrage rates based on carrier size
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
  FUNCTION finDefaultDemurrageRate(p_cargo_no NUMBER,
  									p_demurrage_type VARCHAR2,
  									p_lifting_event VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
	RETURN NULL;
END finDefaultDemurrageRate;

  --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCarrierLaytimeAllowance
-- Description    : This function will call for ecbp_demurrage.findCarrierLaytimeAllowance
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
FUNCTION findCarrierLaytimeAllowance(p_cargo_no NUMBER,
  									p_lifting_event VARCHAR2,
									p_demurrage_type VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN ecbp_demurrage.findCarrierLaytimeAllowance(p_cargo_no,p_lifting_event);
END findCarrierLaytimeAllowance;

END ue_demurrage;

