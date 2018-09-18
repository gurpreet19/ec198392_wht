CREATE OR REPLACE PACKAGE BODY EcBp_alloc_job IS
/***************************************************************
** Package:                EcBp_alloc_job
**
** Revision :
**
** Purpose:		   This package handles the business logic when changing allocation job pass.
**
** Documentation:
**
** Created  :              11.03.2005  BOHHHRON
**
** Modification history:
**
** Date:    Whom: Change description:
** -------- ----- --------------------------------------------
**
***************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : budAllocJobDefinition
-- Description    : It checks from the ALLOC_JOB_LOG whether any calculations for the selected job
--                  and daytime has been run before. If so, the selected job will not able to be
--                  modified or deleted.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : ALLOC_JOB_LOG
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE budAllocJobDefinition (p_job_no	varchar2,
				 p_daytime	DATE)
--</EC-DOC>
IS

CURSOR c_calc_executed(cp_job_no varchar2, cp_daytime DATE) IS
	SELECT 1
	FROM alloc_job_log
	WHERE job_no = cp_job_no
	AND daytime = cp_daytime;


BEGIN
	FOR curCalcExecuted IN c_calc_executed(p_job_no, p_daytime) LOOP
		Raise_Application_Error(-20399, 'Calculation has already been executed for this job at current day daytime');
	END LOOP;

END budAllocJobDefinition;

END EcBp_alloc_job;

