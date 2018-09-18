CREATE OR REPLACE PACKAGE EcBp_alloc_job IS
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
PROCEDURE budAllocJobDefinition (p_job_no	varchar2,
				 p_daytime	DATE);

END EcBp_alloc_job;