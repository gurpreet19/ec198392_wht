CREATE OR REPLACE PACKAGE EcBp_Area_Theoretical IS

/****************************************************************
** Package        :  EcBp_Area_Theoretical, header part
**
** $Revision: 1.0 $
**
** Purpose        :  Provides theoretical fluid values (rates etc)
**	                  for a given Area.
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.10.15
**
** Modification history:
**
** Version  Date     	Whom  Change description:
** -------  ------   	----- --------------------------------------
** 1.0   	27.10.15  	kashisag   Initial version
*****************************************************************/

FUNCTION getAreaPhaseStdVolDay(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_type  VARCHAR2,
                          p_phase VARCHAR2) RETURN NUMBER;

FUNCTION getAreaPhaseStdVolMonth(p_object_id VARCHAR2,
                                 p_daytime   DATE,
                                 p_type      VARCHAR2,
                                 p_phase     VARCHAR2) RETURN NUMBER ;

END EcBp_Area_Theoretical;