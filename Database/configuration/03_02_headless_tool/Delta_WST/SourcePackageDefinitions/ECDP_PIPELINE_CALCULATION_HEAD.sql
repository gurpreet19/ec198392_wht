CREATE OR REPLACE PACKAGE EcDp_Pipeline_Calculation IS

/****************************************************************
** Package        :  EcDp_Pipeline_Calculation, head part
**
** $Revision: 1.3 $
**
** Purpose        :  Calculation on pipelines.
**
** Documentation  :  www.energy-components.com
**
** Created  : 09.05.2006  Kristin Eide
**
** Modification history:
**
** Version  Date     	Whom  		Change description:
** -------  ------   	----- 		--------------------------------------
** 1.0	   09.05.06 	eideekri   	Initial version. Added function getTransactionBalace.
** 1.2     23.08.06     rajarsar    Tracker 4233. Added function getPigTravelDuration.
** 1.5	   10.10.07	    rajarsar    ECPD-6281: Updated getPigTravelDuration to change the return type
*****************************************************************/


FUNCTION getTransactionBalance(p_pipe_id VARCHAR2, p_profit_centre_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2)
RETURN NUMBER;

FUNCTION getPigTravelDuration(p_pipe_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

END EcDp_Pipeline_Calculation;