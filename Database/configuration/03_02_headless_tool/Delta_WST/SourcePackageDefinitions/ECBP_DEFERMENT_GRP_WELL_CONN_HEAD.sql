CREATE OR REPLACE PACKAGE EcBp_Deferment_Grp_Well_Conn IS
/****************************************************************
** Package        :  EcBp_Deferment_Grp_Well_Conn, header part
**
** $Revision: 1.1 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 29.07.2010  Lee Wei Yap
**
** Modification history:
**
** Date       Whom  		Change description:
** -------    ------        ----- -----------------------------------
** 29.07.2010 leeeewei		added checkDateWithinObjects and checkIfEventOverlaps
***************************************************/
PROCEDURE checkDateWithinObjects(
    p_object_id            VARCHAR2,
    p_well_id              VARCHAR2,
	p_start_date		   DATE,
    p_end_date             DATE
);

PROCEDURE checkIfEventOverlaps(
	p_object_id 		  VARCHAR2,
	p_well_id             VARCHAR2,
	p_start_date          DATE,
	p_end_date            DATE
);

END EcBp_Deferment_Grp_Well_Conn;