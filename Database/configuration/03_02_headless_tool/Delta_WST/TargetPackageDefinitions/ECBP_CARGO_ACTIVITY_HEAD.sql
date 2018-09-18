CREATE OR REPLACE PACKAGE EcBp_Cargo_Activity IS
/******************************************************************************
** Package        :  EcBp_Cargo_Activity, head part
**
** $Revision: 1.1.76.4 $
**
** Purpose        :  Provide procedures that will be used as trigger action in the class LIFTING_ACTIVITY
**
** Created  	  :  06.10.2006 / Kok Seong (Khew)
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
**
********************************************************************************************************************************/

PROCEDURE activityBOLmapping(
	p_cargo_no		NUMBER,
	p_activity_code		VARCHAR2,
	p_run_no		NUMBER
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

END EcBp_Cargo_Activity;