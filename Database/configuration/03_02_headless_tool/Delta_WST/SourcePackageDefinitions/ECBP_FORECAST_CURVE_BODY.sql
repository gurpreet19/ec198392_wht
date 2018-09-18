CREATE OR REPLACE PACKAGE BODY EcBp_Forecast_Curve IS
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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : countSegmentRecords
-- Description    : Function for counting Segment records
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------

FUNCTION countSegmentRecords(p_fcst_curve_id NUMBER)
RETURN NUMBER
IS
 ln_row_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO ln_row_count
    FROM FCST_PROD_CURVES_SEGMENT
   WHERE fcst_curve_id = p_fcst_curve_id;

  RETURN ln_row_count;
END;


END EcBp_Forecast_Curve;