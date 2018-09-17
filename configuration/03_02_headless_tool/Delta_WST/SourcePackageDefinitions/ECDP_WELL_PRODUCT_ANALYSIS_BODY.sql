CREATE OR REPLACE PACKAGE BODY EcDp_Well_Product_Analysis IS
/****************************************************************
** Package      :  EcDp_Well_Product_Analysis
**
** $Revision: 1.2 $
**
** Purpose      :
**

** Documentation:  www.energy-components.com
**
** Created      : 21.10.2013  wonggkai
**
** Modification history:
**
** Date         Whom  Change description:
** --------     ----  -----------------------------------
** 21.10.2013  wonggkai   ECPD-25327: Initial Version
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Function      : getYieldFactor
-- Description   : Returns Yield Factor by paramters
-----------------------------------------------------------------
FUNCTION getYieldFactor(p_well_object_id VARCHAR2, p_daytime date, p_product_id VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

  ln_yieldFactor NUMBER;
  CURSOR c_YieldFactor IS
      SELECT yield_factor
      FROM dv_well_product_ana_detail
      WHERE well_object_id = p_well_object_id
      AND DAYTIME = p_daytime
      AND product_id = p_product_id;

  BEGIN
      FOR r_id IN c_YieldFactor LOOP
          ln_yieldFactor:=r_id.yield_factor;
      END LOOP;

      RETURN ln_yieldFactor;
  END getYieldFactor ;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteAnalysisDetail
-- Description    : Delete child events in dv_well_product_ana_detail
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : dv_well_product_ana_detail
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
PROCEDURE deleteAnalysisDetail(p_well_object_id VARCHAR2, p_daytime date)
--</EC-DOC>
IS

BEGIN

DELETE FROM dv_well_product_ana_detail
WHERE well_object_id = p_well_object_id
AND daytime = p_daytime;

END deleteAnalysisDetail;


END EcDp_Well_Product_Analysis;