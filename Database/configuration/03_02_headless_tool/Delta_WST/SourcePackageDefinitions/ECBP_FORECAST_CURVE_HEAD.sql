CREATE OR REPLACE PACKAGE EcBp_Forecast_Curve IS
/****************************************************************
** Package        :  EcBp_Forecast_Curve
**
** $Revision: 1.0 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Well Production Curves and Scenario Curves.
**
** Documentation  :  www.energy-components.com
**
** Created  : 28.02.2018  kashisag
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 28.02.2018   kashisag ECDP-53209: Added new function for child record count
*****************************************************************/


FUNCTION countSegmentRecords(p_fcst_curve_id NUMBER) RETURN NUMBER;

END EcBp_Forecast_Curve;