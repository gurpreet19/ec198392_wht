CREATE OR REPLACE PACKAGE BODY EcDp_WELL_PLT IS
/****************************************************************
** Package      :  EcDp_WELL_PLT
**
** $Revision: 1.1 $
**
** Purpose      :
**

** Documentation:  www.energy-components.com
**
** Created      : 27.11.2013  wonggkai
**
** Modification history:
**
** Date         Whom  Change description:
** --------     ----  -------------------------------
** 27.11.2013  wonggkai   ECPD-22045: Initial Version
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteWellPltResult
-- Description    : Delete child events in dv_WEBO_INT_PLT_TEST_RESULT
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : dv_WEBO_INT_PLT_TEST_RESULT
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteWellPltResult(p_object_id VARCHAR2, p_daytime date, p_run_no VARCHAR2)
--</EC-DOC>
IS

BEGIN

DELETE FROM dv_WEBO_INT_PLT_TEST_RESULT
WHERE object_id = p_object_id
AND daytime = p_daytime
AND run_no = p_run_no;

END deleteWellPltResult;


END EcDp_WELL_PLT;