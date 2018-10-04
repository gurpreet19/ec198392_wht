CREATE OR REPLACE PACKAGE EcBp_Facility_Analysis is
/****************************************************************
** Package        :  EcBp_Facility_Analysis, header part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting the new business function related to facility analysis
**
** Documentation  :  www.energy-components.com
**
** Created  : 08/02/2013  Lim Chun Guan
**
** Modification history:
**
** Date          Whom         Change description:
** ----------    --------     --------------------------------------
** 08.02.2013    limmmchu     ECPD-23143: Initial version
*****************************************************************/

PROCEDURE checkIfPeriodOverlaps(p_asset_id VARCHAR2,p_start_date DATE, p_end_date DATE, p_fcty_object_id VARCHAR2, p_analysis_item VARCHAR2);

FUNCTION getAnalysisFreq(
         p_fcty_object_id VARCHAR2,
         p_start_date DATE,
         p_asset_id VARCHAR2,
         p_analysis_item VARCHAR2)
RETURN VARCHAR2;

FUNCTION getAnalysisTarget(
         p_fcty_object_id VARCHAR2,
         p_start_date DATE,
         p_asset_id VARCHAR2,
         p_analysis_item VARCHAR2)
RETURN VARCHAR2;

PROCEDURE checkManualDaytime(p_daytime DATE);

FUNCTION getAvgValue(p_fcty_object_id VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_analysis_item VARCHAR2, P_days NUMBER)
RETURN NUMBER;

PROCEDURE checkDelete(p_fcty_object_id VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_analysis_item VARCHAR2);

end EcBp_Facility_Analysis;