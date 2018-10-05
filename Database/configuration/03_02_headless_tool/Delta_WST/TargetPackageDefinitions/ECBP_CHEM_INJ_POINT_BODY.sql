CREATE OR REPLACE PACKAGE BODY EcBp_Chem_Inj_Point IS
/***********************************************************************************************************************************************
** Package  :  EcBp_Chem_Inj_Point, body part
**
** $Revision: 1.2 $
**
** Purpose  :  Business functions related to chemical injection point
**
** Created  :  20.01.2010 Annida Farhana
**
** How-To   :  Se www.energy-components.com for full version
**
** Modification history:
**
** Date:      Whom:    Change description:
** ---------- -----    --------------------------------------------
** 20.01.2010 farhaann  Initial version

***********************************************************************************************************************************************/
  -- General cursor to get value from chem_inj_point, chem_inj_point_version and chem_inj_point_status
 CURSOR c_chemical_injection (cp_object_id VARCHAR2, cp_daytime DATE)  IS
 SELECT cip.object_id,
       cipv.asset_type,
       cipv.asset_id,
       cipv.recommended_dosage,
       cipv.rec_dosage_uom,
       cipv.rec_dosage_method,
       cipv.inj_reg_method,
       cips.object_id status_obj_id,
       cips.daytime,
       cips.inj_vol,
       cips.time_span,
       cips.inj_ppm,
       cips.on_time
  FROM chem_inj_point         cip,
       chem_inj_point_version cipv,
       chem_inj_point_status  cips
 WHERE cips.object_id = cp_object_id
   AND cipv.object_id = cips.object_id
   AND cip.object_id = cips.object_id
   AND cips.daytime = cp_daytime
   AND cipv.daytime <= cp_daytime
   AND nvl(cipv.end_date, cp_daytime + 1) > cp_daytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getChemDosage
-- Description    : Include calculated volume based on production figures in the recommended dosage and Injection Registration Method
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_INJ_POINT, CHEM_INJ_POINT_VERSION, CHEM_INJ_POINT_STATUS
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getChemDosage(
         p_object_id VARCHAR2,
         p_daytime     DATE)

RETURN NUMBER
--<EC-DOC>
IS
    ln_asset_id    VARCHAR2(32) := NULL;
    ln_asset      VARCHAR2(32) := NULL;
    ln_rec_dosage_uom    VARCHAR2(32) := NULL;
    ln_rec_dosage_method  VARCHAR2(32) := NULL;
    ln_return_val            NUMBER := NULL;
    ln_rec_dosage          NUMBER := NULL;
    lv_inj_reg_method    VARCHAR(32) := NULL;
    ln_inj_ppm  NUMBER := NULL;
    ln_on_time NUMBER := NULL;
    ln_inj_vol NUMBER := NULL;
    ln_asset_volume NUMBER := NULL;

BEGIN
    -- Get the chemical injection point configuration
    FOR cur_row IN c_chemical_injection (p_object_id, p_daytime) LOOP
        ln_asset_id := cur_row.asset_id;
        ln_asset := cur_row.asset_type;
        ln_rec_dosage := cur_row.recommended_dosage;
        ln_rec_dosage_method := cur_row.rec_dosage_method;
        lv_inj_reg_method := cur_row.inj_reg_method;
        ln_inj_ppm := cur_row.inj_ppm;
        ln_on_time := cur_row.on_time;
        ln_inj_vol := cur_row.inj_vol;
        ln_rec_dosage_uom := cur_row.rec_dosage_uom;
    END LOOP;

    -- If the recommended dosage UOM is ppm need to calculate the recommended dosage based on the asset production
    ln_asset_volume :=  EcDp_Chemical_Product.getAssetVolume(ln_asset, ln_asset_id, ln_rec_dosage_method, p_daytime);

    IF lv_inj_reg_method = 'VOLUME' THEN
      ln_return_val := ln_inj_vol;
    ELSIF lv_inj_reg_method = 'PPM' THEN
      ln_return_val := ln_inj_ppm * ln_asset_volume / 1000000;
    ELSIF lv_inj_reg_method = 'ON_TIME' THEN
      IF ln_rec_dosage_uom = 'PPM' THEN
        ln_return_val := ln_rec_dosage / 24 * ln_on_time * ln_asset_volume / 1000000 ;
      ELSE
        ln_return_val := ln_rec_dosage / 24 * ln_on_time;
      END IF;
    END IF;

   RETURN ln_return_val;

END getChemDosage;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getChemVolPpm
-- Description    : Calculates the chemical volume in parts per million based on production figures and Injection Registration Method
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_INJ_POINT, CHEM_INJ_POINT_VERSION, CHEM_INJ_POINT_STATUS
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getChemVolPpm(
         p_object_id VARCHAR2,
         p_daytime     DATE)

RETURN NUMBER
--<EC-DOC>
IS
    ln_asset_id    VARCHAR2(32) := NULL;
    ln_asset      VARCHAR2(32) := NULL;
    ln_rec_dosage_uom    VARCHAR2(32) := NULL;
    ln_rec_dosage_method  VARCHAR2(32) := NULL;
    ln_return_val            NUMBER := NULL;
    ln_rec_dosage          NUMBER := NULL;
    lv_inj_reg_method    VARCHAR(32) := NULL;
    ln_inj_ppm  NUMBER := NULL;
    ln_on_time NUMBER := NULL;
    ln_inj_vol NUMBER := NULL;
    ln_asset_volume NUMBER := NULL;

BEGIN
    -- Get the chemical Injection Configuration
    FOR cur_row IN c_chemical_injection (p_object_id, p_daytime) LOOP
        ln_asset_id := cur_row.asset_id;
        ln_asset := cur_row.asset_type;
        ln_rec_dosage_uom := cur_row.rec_dosage_uom;
        ln_rec_dosage_method := cur_row.rec_dosage_method;
        lv_inj_reg_method := cur_row.inj_reg_method;
        ln_inj_ppm := cur_row.inj_ppm;
        ln_rec_dosage := cur_row.recommended_dosage;
        ln_on_time := cur_row.on_time;
        ln_inj_vol := cur_row.inj_vol;
    END LOOP;

    -- Calc Ppm based on chemical injection vol and production flowrate based on Injection Registration Method.
    ln_asset_volume := EcDp_Chemical_Product.getAssetVolume(ln_asset, ln_asset_id, ln_rec_dosage_method, p_daytime);

    IF lv_inj_reg_method = 'VOLUME' THEN
      IF ln_asset_volume > 0 then
        ln_return_val :=   ln_inj_vol / ln_asset_volume * 1000000;
      END IF;
    ELSIF lv_inj_reg_method = 'PPM' THEN
      ln_return_val := ln_inj_ppm;
    ELSIF lv_inj_reg_method = 'ON_TIME' THEN
      IF ln_rec_dosage_uom = 'PPM' THEN
        ln_return_val := ln_rec_dosage;
      ELSE
        IF ln_asset_volume > 0 then
          ln_return_val := ln_rec_dosage / 24 * ln_on_time / ln_asset_volume * 1000000;
        END IF;
      END IF;
    END IF;

  RETURN ln_return_val;

END getChemVolPpm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcRecomVolume
-- Description    : Calculate Recommended Volume based on production figures, recommended uom and recommended dosage
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_INJ_POINT, CHEM_INJ_POINT_VERSION, CHEM_INJ_POINT_STATUS
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcRecomVolume(
         p_object_id VARCHAR2,
         p_daytime     DATE)

RETURN NUMBER
--<EC-DOC>
IS

    ln_asset_id    VARCHAR2(32) := NULL;
    ln_asset      VARCHAR2(32) := NULL;
    ln_rec_dosage_method  VARCHAR2(32) := NULL;
    ln_return_val            NUMBER := NULL;
    ln_rec_dosage          NUMBER := NULL;
    ln_rec_dosage_uom    VARCHAR2(32) := NULL;
    lv_inj_reg_method VARCHAR2(32) := NULL;
    ln_asset_volume NUMBER := NULL;

BEGIN
    -- Get the chemical Injection Configuration
    FOR cur_row IN c_chemical_injection (p_object_id, p_daytime) LOOP
        ln_asset_id := cur_row.asset_id;
        ln_asset := cur_row.asset_type;
        ln_rec_dosage := cur_row.recommended_dosage;
        ln_rec_dosage_method := cur_row.rec_dosage_method;
        lv_inj_reg_method := cur_row.inj_reg_method;
        ln_rec_dosage_uom := cur_row.rec_dosage_uom;
    END LOOP;

    ln_asset_volume := EcDp_Chemical_Product.getAssetVolume(ln_asset, ln_asset_id, ln_rec_dosage_method, p_daytime);

    IF ln_rec_dosage_uom = 'PPM' THEN
      ln_return_val := ln_asset_volume * ln_rec_dosage / 1000000;
    ELSE
      ln_return_val := Null;
    END IF;

  RETURN ln_return_val;

END calcRecomVolume;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getLastNotNullInjVolDate
-- Description    : The last date injection was registered (e.g. either inj_vol > 0 OR inj_ppm > 0 OR on_time > 0 )
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CHEM_INJ_POINT, CHEM_INJ_POINT_VERSION, CHEM_INJ_POINT_STATUS
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastNotNullInjVolDate(
         p_object_id VARCHAR2,
         p_daytime     DATE)

RETURN DATE
--<EC-DOC>
IS

    CURSOR c_chemical_injection(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT max(daytime) max_daytime from chem_inj_point_status cips
    WHERE cips.object_id = p_object_id
    AND (cips.inj_vol > 0 OR cips.inj_ppm > 0 OR cips.on_time > 0)
    AND cips.daytime < p_daytime;

    ln_inj_vol_date  DATE;

BEGIN
    -- Get the chemical Injection Configuration
    FOR cur_row IN c_chemical_injection(p_object_id, p_daytime) LOOP
        ln_inj_vol_date := cur_row.max_daytime ;
   END LOOP;

   RETURN ln_inj_vol_date;

END getLastNotNullInjVolDate;

END EcBp_Chem_Inj_Point;