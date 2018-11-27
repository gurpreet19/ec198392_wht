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
** Created  : 11.01.2006  Stian Skjørestad
**
** Modification history:
**
** Date       Whom  	 		Change description:
** --------   ----- 			---------------------------------------------

*****************************************************************************/

FUNCTION productionDate(p_daytime DATE, p_limit VARCHAR) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(productionDate, WNDS, WNPS, RNPS);

FUNCTION getDailyFlowRatePrHour(p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getDailyFlowRatePrHour, WNDS, WNPS, RNPS);

FUNCTION getProcessingUnitFlowRatePrHr(p_daytime DATE, p_flow_rate NUMBER, p_processing_unit VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getProcessingUnitFlowRatePrHr, WNDS, WNPS, RNPS);


END EcBp_Wet_Gas;