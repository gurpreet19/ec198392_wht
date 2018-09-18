CREATE OR REPLACE PACKAGE EcDp_Fcst_Fluid IS
/****************************************************************
** Package        :  EcDp_Fcst_Fluid
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for data access to
**                   fluid analysis figures for any analysis object.
**
** Documentation  :  www.energy-components.com
**
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 29.07.2014 dhavaalo   ECPD-31274-Initial version

*****************************************************************/

PROCEDURE createCompSetForAnalysis(p_comp_set VARCHAR2 DEFAULT NULL, p_analysis_no NUMBER, p_daytime DATE, p_user_id VARCHAR2 DEFAULT NULL);

FUNCTION calcHeatingValue (
   p_analysis_no      NUMBER)

RETURN NUMBER;

END EcDp_Fcst_Fluid;