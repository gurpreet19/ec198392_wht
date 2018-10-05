CREATE OR REPLACE PACKAGE EcBp_Cargo_Activity IS
/******************************************************************************
** Package        :  EcBp_Cargo_Activity, head part
**
** $Revision: 1.4 $
**
** Purpose        :  Provide procedures that will be used as trigger action in the class LIFTING_ACTIVITY
**
** Created  	  :  06.10.2006 / Kok Seong (Khew)
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
** 02.09.2013	muhammah		ECPD-6031: Added lifting_event to PROCEDURE activityBOLmapping
** 02.06.2017 sharawan    ECPD-41532: Added getActivityElapsedTime for calculating elapsed time minus the delays happen in between
********************************************************************************************************************************/

PROCEDURE activityBOLmapping(
	p_cargo_no		NUMBER,
	p_activity_code		VARCHAR2,
	p_run_no		NUMBER,
	p_lifting_event VARCHAR2
);

FUNCTION getLiftingStartDate(
	p_cargo_no NUMBER,
	p_activity_type VARCHAR2 DEFAULT 'LOAD',
	p_lifting_event VARCHAR2 DEFAULT 'LOAD'
) RETURN DATE;

FUNCTION getLiftingEndDate(
	p_cargo_no NUMBER,
	p_activity_type VARCHAR2 DEFAULT 'LOAD',
	p_lifting_event VARCHAR2 DEFAULT 'LOAD'
) RETURN DATE;

FUNCTION getActivityElapsedTime(
	p_cargo_no NUMBER,
	p_activity_start DATE,
  p_activity_end DATE
) RETURN VARCHAR2;

END EcBp_Cargo_Activity;