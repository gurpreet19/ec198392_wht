CREATE OR REPLACE PACKAGE BODY EcDp_Chemical_Product IS
/***********************************************************************************************************************************************
** Package  :  EcDp_Chemical_Product, body part
**
** $Revision: 1.21 $
**
** Purpose  :  Business functions related to chemical products
**
** Created  :  03.03.2004 Frode Barstad
**
** How-To   :  Se www.energy-components.com for full version
**
** Modification history:
**
** Date:      Whom:    Change description:
** ---------- -----    --------------------------------------------
** 03.03.2004 FBa      Initial version
** 17.03.2004 HNE      Bugfixes and dm model upgrades
** 18.03.2004 DN       Bugfix in parameter call to ec_chem_product_attribute.
** 21.04.2004 FBa      Minor rewrites to cursors to better utilize indexes.
** 03.02.2005 Darren   Added new procedure buiSetEndDate
** 24.02.2005 kaurrnar Changed chem_product_attribute to chem_product_version
** 22.11.2005 Ron Boh  Added new function get_chem_dosage
** 23.11.2005 Ron Boh  Update function get_chem_dosage - remove condition net_gas, add condition wat_inj for asset_type well
** 23.11.2005 Ron Boh  Update function get_chem_dosage - add condition net_gas and gas_inj
** 23.11.2005 Ron Boh  Update function get_chem_dosage - update: when dosage method is net_gas return netstdvol instead of grsstdvol
						       - Remove the unit conversion before returning the values.
** 23.02.2006 rajarsar ECPD-4251: Update function get_chem_dosage and getChemVolPpm for ECPD-4251. Added function:calcRecomVolume, getLastNotNullInjVolDate and getAssetVolume.
** 01.04.2008 rajarsar ECPD-7844: Replaced getNumHours with 24 at get_chem_dosage and getChemVolPpm.
** 04.02.2010 farhaann ECPD-13601: Removed get_chem_dosage, getChemVolPpm, calcRecomVolume and getLastNotNullInjVolDate to Ecbp_Chem_Inj_Point package.
***********************************************************************************************************************************************/

CURSOR c_tanks_for_product (p_product_object_id VARCHAR2, p_daytime DATE) IS
SELECT object_id
  FROM chem_tank_product
 WHERE chem_product_id = p_product_object_id
   AND p_daytime >= daytime
   AND (end_date > p_daytime OR end_date IS NULL);

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDefaultUOM
-- Description    : Returns default Unit of Measure for product
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_PRODUCT_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDefaultUOM(p_product_object_id IN VARCHAR2,
                       p_daytime           IN DATE DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
   lv2_retval VARCHAR2(300);
   ld_date    DATE;

BEGIN
   ld_date := Nvl(p_daytime, EcDp_Date_Time.getCurrentSysdate);

   lv2_retval := ec_chem_product_version.UNIT(p_product_object_id, ld_date, '<=');  -- REPORT_UOM
   RETURN lv2_retval;
END getDefaultUOM;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductCode
-- Description    : Returns code for product
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_PRODUCT_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductCode (p_product_object_id IN VARCHAR2,
                         p_daytime           IN DATE DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
   lv2_retval VARCHAR2(300);
   ld_date    DATE;

BEGIN
   ld_date := Nvl(p_daytime, EcDp_Date_Time.getCurrentSysdate);

   lv2_retval := ec_chem_product.OBJECT_CODE(p_product_object_id);
   RETURN lv2_retval;
END getProductCode;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductName
-- Description    : Returns name for product
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_PRODUCT_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductName (p_product_object_id IN VARCHAR2,
                         p_daytime           IN DATE DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_retval VARCHAR2(300);
  ld_date    DATE;

BEGIN
   ld_date := Nvl(p_daytime, EcDp_Date_Time.getCurrentSysdate);

   lv2_retval := ec_chem_product_version.NAME(p_product_object_id,
                                              ld_date,
                                              '<=');
   RETURN lv2_retval;
END getProductName;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getClosingVol
-- Description    : Returns sum of closing volume for all tanks with selected product
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_TANK_PRODUCT
--
-- Using functions: EcDp_Chemical_Tank.getClosingVol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getClosingVol (p_product_object_id IN VARCHAR2,
                        p_daytime           IN DATE,
                        p_uom               IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_product_unit ctrl_unit_conversion.to_unit%TYPE;
   ln_retval        NUMBER := 0;

BEGIN
   IF p_uom IS NOT NULL THEN
      lv2_product_unit := p_uom;
   ELSE
      lv2_product_unit := getDefaultUOM(p_product_object_id, p_daytime);
   END IF;

   FOR tankCur IN c_tanks_for_product (p_product_object_id, p_daytime) LOOP
      ln_retval := ln_retval + Nvl(EcDp_Chemical_Tank.getClosingVol(tankCur.object_id,
                                                                    p_daytime,
                                                                    lv2_product_unit),
                                   0);
   END LOOP;

   RETURN ln_retval;
END getClosingVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOpeningVol
-- Description    : Returns sum of opening volume for all tanks with selected product
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_TANK_PRODUCT
--
-- Using functions: EcDp_Chemical_Tank.getOpeningVol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getOpeningVol (p_product_object_id IN VARCHAR2,
                        p_daytime           IN DATE,
                        p_uom               IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_product_unit ctrl_unit_conversion.to_unit%TYPE;
   ln_retval        NUMBER := 0;

BEGIN
   IF p_uom IS NOT NULL THEN
      lv2_product_unit := p_uom;
   ELSE
      lv2_product_unit := getDefaultUOM(p_product_object_id, p_daytime);
   END IF;

   FOR tankCur IN c_tanks_for_product (p_product_object_id, p_daytime) LOOP
      ln_retval := ln_retval + Nvl(EcDp_Chemical_Tank.getOpeningVol(tankCur.object_id,
                                                                    p_daytime,
                                                                    lv2_product_unit),
                                   0);
   END LOOP;

   RETURN ln_retval;
END getOpeningVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFilledVol
-- Description    : Returns sum of filled volume for all tanks with selected product
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_TANK_DAY_STATUS, CHEM_TANK_PRODUCT
--
-- Using functions: EcDp_Chemical_Tank.getFilledVol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getFilledVol (p_product_object_id IN VARCHAR2,
                       p_daytime           IN DATE,
                       p_uom               IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_product_unit ctrl_unit_conversion.to_unit%TYPE;
   ln_retval        NUMBER := 0;

BEGIN
   IF p_uom IS NOT NULL THEN
      lv2_product_unit := p_uom;
   ELSE
      lv2_product_unit := getDefaultUOM(p_product_object_id, p_daytime);
   END IF;

   FOR tankCur IN c_tanks_for_product (p_product_object_id, p_daytime) LOOP
      ln_retval := ln_retval + Nvl(EcDp_Chemical_Tank.getFilledVol(tankCur.object_id,
                                                                   p_daytime,
                                                                   lv2_product_unit),
                                   0);
   END LOOP;

   RETURN ln_retval;
END getFilledVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getConsumedVol
-- Description    : Returns sum of Consumed volume for all tanks with selected product
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_TANK_DAY_STATUS, CHEM_TANK_PRODUCT
--
-- Using functions: EcDp_Chemical_Tank.getConsumedVol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getConsumedVol (p_product_object_id IN VARCHAR2,
                         p_daytime           IN DATE,
                         p_uom               IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_product_unit ctrl_unit_conversion.to_unit%TYPE;
   ln_retval        NUMBER := 0;

BEGIN
   IF p_uom IS NOT NULL THEN
      lv2_product_unit := p_uom;
   ELSE
      lv2_product_unit := getDefaultUOM (p_product_object_id, p_daytime);
   END IF;

   FOR tankCur IN c_tanks_for_product (p_product_object_id, p_daytime) LOOP
      ln_retval := ln_retval + Nvl(EcDp_Chemical_Tank.getConsumedVol (tankCur.object_id,
                                                                      p_daytime,
                                                                      lv2_product_unit),
                                   0);
   END LOOP;

   RETURN ln_retval;
END getConsumedVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : biuSetEndDate
-- Description    : Check for period overlapping and
--                set end_date for previous chemical product and object combination if not exist
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PRODUCT_OBJECT_COMB
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE biuSetEndDate (p_asset_object_id VARCHAR2, -- ASSET OBJECT ID
                         p_start_date      DATE,     -- START DATE
                         p_end_date        DATE) IS

   -- Check for overlapping
   CURSOR c_chem_product_object_comb (cp_asset_object_id  VARCHAR2,
                                      cp_start_date       DATE,
                                      cp_end_date         DATE) IS
   SELECT 1 one
     FROM PRODUCT_OBJECT_COMB
    WHERE object_id = cp_asset_object_id
      AND cp_start_date < Nvl(end_date, cp_start_date + 1)
      AND Nvl(cp_end_date, start_date + 1) > start_date
      AND (cp_start_date <> start_date AND nvl(cp_end_date, end_date+1) <> end_date)
      AND NOT (cp_start_date > start_date AND end_date IS NULL);

BEGIN

   FOR ITEM IN c_chem_product_object_comb(p_asset_object_id, p_start_date, p_end_date) LOOP
      Raise_Application_Error(-20121, 'The Date Overlaps with another period');
   END LOOP;

   -- update previous row end date if null
   UPDATE PRODUCT_OBJECT_COMB
      SET end_date = p_start_date
    WHERE object_id = p_asset_object_id
      AND start_date < p_start_date
      AND end_date IS NULL;

END biuSetEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getAssetVolume
-- Description    : Calculate Asset Volume based on asset type, asset id, recommended dosage and daytime
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PRODUCT_OBJECT_COMB
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAssetVolume(p_asset VARCHAR2, p_asset_object_id VARCHAR2, p_rec_dosage_method VARCHAR2, p_daytime DATE)

RETURN NUMBER
--<EC-DOC>
IS
  ln_return_val NUMBER := NULL;

BEGIN

  IF p_asset = 'WELL' THEN
    IF p_rec_dosage_method = 'NET_OIL' THEN
      ln_return_val := Ecbp_Well_Theoretical.getOilStdRateDay(p_asset_object_id, p_daytime);
    ELSIF p_rec_dosage_method = 'NET_GAS' THEN
      ln_return_val := Ecbp_Well_Theoretical.getGasStdRateDay(p_asset_object_id, p_daytime);
    ELSIF p_rec_dosage_method = 'NET_WAT' THEN
      ln_return_val := Ecbp_Well_Theoretical.getWatStdRateDay(p_asset_object_id, p_daytime);
    ELSIF p_rec_dosage_method = 'GRS_FLUID' THEN
      ln_return_val := Ecbp_Well_Theoretical.getOilStdRateDay(p_asset_object_id, p_daytime) +  Ecbp_Well_Theoretical.getWatStdRateDay(p_asset_object_id, p_daytime);
    ELSIF p_rec_dosage_method = 'WAT_INJ' THEN
      ln_return_val := Ecbp_Well_Theoretical.getInjectedStdRateDay(p_asset_object_id, EcDp_Well_Type.WATER_INJECTOR, p_daytime);
    ELSIF p_rec_dosage_method = 'GAS_INJ' THEN
      ln_return_val := Ecbp_Well_Theoretical.getInjectedStdRateDay(p_asset_object_id, EcDp_Well_Type.GAS_INJECTOR, p_daytime);
    END IF;
  ELSIF p_asset = 'STREAM' THEN
    IF p_rec_dosage_method = 'NET_OIL' THEN
      ln_return_val := EcBp_Stream_Fluid.findNetStdVol(p_asset_object_id, p_daytime, p_daytime);
    ELSIF p_rec_dosage_method = 'NET_WAT' OR p_rec_dosage_method = 'WAT_INJ' THEN
      ln_return_val := EcBp_Stream_Fluid.findWatVol(p_asset_object_id, p_daytime, p_daytime);
    ELSIF p_rec_dosage_method = 'NET_GAS' OR p_rec_dosage_method = 'GAS_INJ' THEN
      ln_return_val :=  EcBp_Stream_Fluid.findNetStdVol(p_asset_object_id, p_daytime, p_daytime);
    ELSIF p_rec_dosage_method = 'GRS_FLUID' THEN
      ln_return_val := EcBp_Stream_Fluid.findGrsStdVol(p_asset_object_id, p_daytime, p_daytime);
    END IF;
  END IF;
  RETURN ln_return_val;
END getAssetVolume;

END EcDp_Chemical_Product;