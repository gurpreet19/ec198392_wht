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
**** 30.03.2016 dhavaalo 	ECPD-34727: Added new function  getJobName
***************************************************************/
PROCEDURE budAllocJobDefinition (p_job_no	varchar2,
				 p_daytime	DATE);

FUNCTION getJobName(P_JOB_ID VARCHAR2)
RETURN VARCHAR2;

END EcBp_alloc_job;