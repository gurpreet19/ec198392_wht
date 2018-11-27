CREATE OR REPLACE PACKAGE EcBp_Wet_Gas IS
/****************************************************************
** Package        :  EcBp_Wet_Gas
**
** $Revision: 1.1 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.01.2006  Stian Skj�tad
**
** Modification history:
**
** Date       Whom  	 		Change description:
** --------   ----- 			---------------------------------------------

*****************************************************************************/

FUNCTION productionDate(p_daytime DATE, p_limit VARCHAR) RETURN DATE;

FUNCTION getDailyFlowRatePrHour(p_daytime DATE) RETURN NUMBER;

FUNCTION getProcessingUnitFlowRatePrHr(p_daytime DATE, p_flow_rate NUMBER, p_processing_unit VARCHAR2) RETURN NUMBER;


END EcBp_Wet_Gas;