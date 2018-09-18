CREATE OR REPLACE PACKAGE BODY EcDp_Revn_Stim_Fcst IS
/**************************************************************
** Package        :  EcDp_Revn_Stim_Fcst, body part
**
** $Revision: 1.7 $
**
**
** Purpose	:  Forecast functionality
**
** General Logic:
**
** Modification history:
**
** Date:       Whom  Change description:
** ----------  ----  --------------------------------------------
** 29.05.2007         Initial version
** 19.12.2007  DN     Added bind variables to cursors. Rewrote PopulateStimFcstMth.
**************************************************************/


PROCEDURE InstantiateStimFcstMthYear(p_forecast_id VARCHAR2, p_stream_item_id VARCHAR2, p_daytime DATE) IS

ln_months NUMBER;


BEGIN
    -- Instantiate a whole year
    FOR ln_months IN 0..11 LOOP

        InstantiateStimFcstMth(p_forecast_id, p_stream_item_id, ADD_MONTHS(p_daytime, ln_months));

    END LOOP;

END InstantiateStimFcstMthYear;

PROCEDURE InstantiateStimFcstMth(p_forecast_id VARCHAR2, p_stream_item_id VARCHAR2, p_daytime DATE) IS

l_ConvFact EcDp_Stream_Item.t_conversion;
l_stim_fcst_mth_value stim_fcst_mth_value%ROWTYPE;
lv2_status stim_fcst_mth_value.status%TYPE := NULL;
lv2_conversion_method stream_item_version.conversion_method%TYPE;
lv2_set_to_zero varchar2(200);
ln_value NUMBER;
lv2_status_flag VARCHAR2(240);


BEGIN

    IF (p_forecast_id IS NULL) THEN
        Raise_Application_Error(-20000,'Can not instantiate when forecast case is not given');
    END IF;

lv2_conversion_method := ec_stream_item_version.conversion_method(p_stream_item_id, TRUNC(p_daytime,'MM'), '<=');

	-- insert all valid stream_items for a given month
	INSERT INTO stim_fcst_mth_value
	 	(OBJECT_ID
    ,FORECAST_ID
		,DAYTIME
		,CREATED_BY
		,LAST_UPDATED_BY -- include this during insert to allow for standard processing in subsequent updates
		,REV_TEXT
	 	)
	SELECT
	 	si.OBJECT_ID
    ,p_forecast_id
		,Trunc(p_daytime,'MM')
		,'INSTANTIATE'
		,'INSTANTIATE'
		,'Instantiated record'
	FROM stream_item si, stream s, strm_version sv
  WHERE si.object_id = p_stream_item_id
    AND si.stream_id = s.object_id
    AND s.object_id = sv.object_id
    AND sv.daytime = (SELECT MAX(svm.daytime) FROM strm_version svm WHERE svm.object_id = s.object_id AND svm.daytime <= TRUNC(p_daytime,'MM'))
    AND s.start_date <= p_daytime
    AND NVL(s.end_date, p_daytime+1) >= p_daytime
    AND si.start_date <= p_daytime
    AND NVL(si.end_date, p_daytime+1) >= p_daytime
	  AND NOT EXISTS (SELECT 'x' FROM stim_fcst_mth_value x WHERE x.object_id = si.object_id AND x.forecast_id = p_forecast_id AND x.daytime = Trunc(p_daytime,'MM'))
;

 	---------------------------------------------------------------------------
	-- Need to set default UOM from Stream_Item Attributes
	--
 	---------------------------------------------------------------------------
        l_stim_fcst_mth_value.CALC_METHOD := Ecdp_Revn_Forecast.getStreamItemAttribute(p_forecast_id, p_stream_item_id, TRUNC(p_daytime,'MM'), 'CALC_METHOD');

        lv2_status := null;

				lv2_set_to_zero := Ecdp_Revn_Forecast.getStreamItemAttribute(p_forecast_id, p_stream_item_id, TRUNC(p_daytime,'MM'), 'SET_TO_ZERO_METHOD_MTH');

      ---------------------------------------------------------------------------
      -- Default UOMs
      ---------------------------------------------------------------------------
      l_stim_fcst_mth_value.VOLUME_UOM_CODE := Ecdp_Revn_Forecast.getStreamItemAttribute(p_forecast_id, p_stream_item_id, TRUNC(p_daytime,'MM'), 'DEFAULT_UOM_VOLUME');
      l_stim_fcst_mth_value.MASS_UOM_CODE   := Ecdp_Revn_Forecast.getStreamItemAttribute(p_forecast_id, p_stream_item_id, TRUNC(p_daytime,'MM'), 'DEFAULT_UOM_MASS');
      l_stim_fcst_mth_value.ENERGY_UOM_CODE := Ecdp_Revn_Forecast.getStreamItemAttribute(p_forecast_id, p_stream_item_id, TRUNC(p_daytime,'MM'), 'DEFAULT_UOM_ENERGY');
      l_stim_fcst_mth_value.EXTRA1_UOM_CODE := Ecdp_Revn_Forecast.getStreamItemAttribute(p_forecast_id, p_stream_item_id, TRUNC(p_daytime,'MM'), 'DEFAULT_UOM_EXTRA1');
      l_stim_fcst_mth_value.EXTRA2_UOM_CODE := Ecdp_Revn_Forecast.getStreamItemAttribute(p_forecast_id, p_stream_item_id, TRUNC(p_daytime,'MM'), 'DEFAULT_UOM_EXTRA2');
      l_stim_fcst_mth_value.EXTRA3_UOM_CODE := Ecdp_Revn_Forecast.getStreamItemAttribute(p_forecast_id, p_stream_item_id, TRUNC(p_daytime,'MM'), 'DEFAULT_UOM_EXTRA3');

      ---------------------------------------------------------------------------
      -- Master UOM
      ---------------------------------------------------------------------------
      l_stim_fcst_mth_value.MASTER_UOM_GROUP := Ecdp_Revn_Forecast.getStreamItemAttribute(p_forecast_id, p_stream_item_id, TRUNC(p_daytime,'MM'), 'MASTER_UOM_GROUP');

     	---------------------------------------------------------------------------
     	-- If a Split key, instantiate split share
     	--
     	---------------------------------------------------------------------------

        IF l_stim_fcst_mth_value.CALC_METHOD = 'SK' THEN

		        l_stim_fcst_mth_value.SPLIT_SHARE  := Ecdp_Revn_Forecast.GetSplitShareMth(p_forecast_id, p_stream_item_id,TRUNC(p_daytime,'MM'));

        END IF;

        IF l_stim_fcst_mth_value.CALC_METHOD = 'CO' THEN
            INSERT INTO stim_cascade (object_id,period,daytime,forecast_id) VALUES (p_stream_item_id, 'FCST_MTH', TRUNC(p_daytime,'MM'), p_forecast_id);
        END IF;

        ---------------------------------------------------------------------------
   	    -- set default conversion factors
   	    -- For each factor set UOM from and to.
   	    ---------------------------------------------------------------------------

IF lv2_set_to_zero = 'ACCRUAL' THEN
               ln_value := 0;
               lv2_status_flag :='ACCRUAL';
        END IF;

        IF lv2_set_to_zero = 'FINAL' THEN
               ln_value := 0;
               lv2_status_flag :='FINAL';
        END IF;

        IF lv2_set_to_zero IS NULL THEN
               ln_value := NULL;
               lv2_status_flag := NULL;
        END IF;

         IF (l_stim_fcst_mth_value.VOLUME_UOM_CODE IS NOT NULL) THEN
                    l_stim_fcst_mth_value.NET_VOLUME_VALUE   := ln_value;
                    l_stim_fcst_mth_value.GROSS_VOLUME_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
         END IF;
                IF (l_stim_fcst_mth_value.MASS_UOM_CODE IS NOT NULL) THEN
                    l_stim_fcst_mth_value.NET_MASS_VALUE   := ln_value;
                    l_stim_fcst_mth_value.GROSS_MASS_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
                END IF;
                IF (l_stim_fcst_mth_value.ENERGY_UOM_CODE IS NOT NULL) THEN
                    l_stim_fcst_mth_value.NET_ENERGY_VALUE   := ln_value;
                    l_stim_fcst_mth_value.GROSS_ENERGY_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
                END IF;
                IF (l_stim_fcst_mth_value.EXTRA1_UOM_CODE IS NOT NULL) THEN
                    l_stim_fcst_mth_value.NET_EXTRA1_VALUE   := ln_value;
                    l_stim_fcst_mth_value.GROSS_EXTRA1_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
                END IF;
                IF (l_stim_fcst_mth_value.EXTRA2_UOM_CODE IS NOT NULL) THEN
                    l_stim_fcst_mth_value.NET_EXTRA2_VALUE   := ln_value;
                    l_stim_fcst_mth_value.GROSS_EXTRA2_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
                END IF;
                IF (l_stim_fcst_mth_value.EXTRA3_UOM_CODE IS NOT NULL) THEN
                    l_stim_fcst_mth_value.NET_EXTRA3_VALUE   := ln_value;
                    l_stim_fcst_mth_value.GROSS_EXTRA3_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
                END IF;


  IF lv2_conversion_method = 'CONVERSION_FACTOR' THEN


      l_ConvFact := EcDp_Stream_Item.GetDefDensity(p_stream_item_id, TRUNC(p_daytime,'MM'));
      l_stim_fcst_mth_value.density := l_ConvFact.factor;
      l_stim_fcst_mth_value.density_volume_uom := l_ConvFact.from_uom;
      l_stim_fcst_mth_value.density_mass_uom := l_ConvFact.to_uom;
      l_stim_fcst_mth_value.density_source_id := l_ConvFact.source_object_id;

      l_ConvFact := EcDp_Stream_Item.GetDefGCV(p_stream_item_id, TRUNC(p_daytime,'MM'));
      l_stim_fcst_mth_value.gcv := l_ConvFact.factor;
      l_stim_fcst_mth_value.gcv_volume_uom := l_ConvFact.from_uom;
      l_stim_fcst_mth_value.gcv_energy_uom := l_ConvFact.to_uom;
      l_stim_fcst_mth_value.gcv_source_id := l_ConvFact.source_object_id;


      l_ConvFact := EcDp_Stream_Item.GetDefMCV(p_stream_item_id, TRUNC(p_daytime,'MM'));
      l_stim_fcst_mth_value.mcv := l_ConvFact.factor;
      l_stim_fcst_mth_value.mcv_mass_uom := l_ConvFact.from_uom;
      l_stim_fcst_mth_value.mcv_energy_uom := l_ConvFact.to_uom;
      l_stim_fcst_mth_value.mcv_source_id := l_ConvFact.source_object_id;


  END IF;

        -- Handle possible BOE configuration for stream item to be instantiated
        l_ConvFact := EcDp_Stream_Item.GetDefBOE(p_stream_item_id, TRUNC(p_daytime,'MM'));
        l_stim_fcst_mth_value.boe_factor := l_ConvFact.factor;
        l_stim_fcst_mth_value.boe_from_uom_code := l_ConvFact.from_uom;
        l_stim_fcst_mth_value.boe_to_uom_code := l_ConvFact.to_uom;
        l_stim_fcst_mth_value.boe_source_id := l_ConvFact.source_object_id;

        -- Update everyting in one update

    UPDATE stim_fcst_mth_value
       SET volume_uom_code    = l_stim_fcst_mth_value.volume_uom_code,
           mass_uom_code      = l_stim_fcst_mth_value.mass_uom_code,
           energy_uom_code    = l_stim_fcst_mth_value.energy_uom_code,
           extra1_uom_code    = l_stim_fcst_mth_value.extra1_uom_code,
           extra2_uom_code    = l_stim_fcst_mth_value.extra2_uom_code,
           extra3_uom_code    = l_stim_fcst_mth_value.extra3_uom_code,
           net_mass_value     = l_stim_fcst_mth_value.net_mass_value,
           gross_mass_value   = l_stim_fcst_mth_value.gross_mass_value,
           net_volume_value   = l_stim_fcst_mth_value.net_volume_value,
           gross_volume_value = l_stim_fcst_mth_value.gross_volume_value,
           net_energy_value   = l_stim_fcst_mth_value.net_energy_value,
           gross_energy_value = l_stim_fcst_mth_value.gross_energy_value,
           net_extra1_value   = l_stim_fcst_mth_value.net_extra1_value,
           gross_extra1_value = l_stim_fcst_mth_value.gross_extra1_value,
           net_extra2_value   = l_stim_fcst_mth_value.net_extra2_value,
           gross_extra2_value = l_stim_fcst_mth_value.gross_extra2_value,
           net_extra3_value   = l_stim_fcst_mth_value.net_extra3_value,
           gross_extra3_value = l_stim_fcst_mth_value.gross_extra3_value,
           gcv                = l_stim_fcst_mth_value.gcv,
           gcv_energy_uom     = l_stim_fcst_mth_value.gcv_energy_uom,
           gcv_volume_uom     = l_stim_fcst_mth_value.gcv_volume_uom,
           density            = l_stim_fcst_mth_value.density,
           density_mass_uom   = l_stim_fcst_mth_value.density_mass_uom,
           density_volume_uom = l_stim_fcst_mth_value.density_volume_uom,
           mcv                = l_stim_fcst_mth_value.mcv,
           mcv_energy_uom     = l_stim_fcst_mth_value.mcv_energy_uom,
           mcv_mass_uom       = l_stim_fcst_mth_value.mcv_mass_uom,
           density_source_id  = l_stim_fcst_mth_value.density_source_id,
           gcv_source_id      = l_stim_fcst_mth_value.gcv_source_id,
           mcv_source_id      = l_stim_fcst_mth_value.mcv_source_id,
           boe_factor         = l_stim_fcst_mth_value.boe_factor,
           boe_from_uom_code  = l_stim_fcst_mth_value.boe_from_uom_code,
           boe_to_uom_code    = l_stim_fcst_mth_value.boe_to_uom_code,
           boe_source_id      = l_stim_fcst_mth_value.boe_source_id,
           split_share        = l_stim_fcst_mth_value.split_share,
           master_uom_group   = l_stim_fcst_mth_value.master_uom_group,
           status             = lv2_status,
           last_updated_by    = 'INSTANTIATE'
     WHERE object_id = p_stream_item_id
       AND forecast_id = p_forecast_id
       AND daytime = TRUNC(p_daytime, 'MM')
       AND last_updated_by = 'INSTANTIATE';

END InstantiateStimFcstMth;

--PROCEDURE PopulateStimFcstMth(p_forecast_id VARCHAR2, p_stream_item_id VARCHAR2, p_daytime DATE)
PROCEDURE PopulateStimFcstMth(p_forecast_id VARCHAR2, p_daytime DATE)
IS

CURSOR c_fcst_stream_items(cp_forecast_id VARCHAR2) IS
SELECT stream_item_id, swap_stream_item_id, adj_stream_item_id
FROM fcst_member
WHERE object_id = cp_forecast_id;

  ltab_objects EcDp_Revn_Forecast.t_object_tab;
  ln_months NUMBER;
  lb_found BOOLEAN := FALSE;

BEGIN
    -- Erase content
    DELETE FROM stim_cascade;

    FOR CurFcstSI IN c_fcst_stream_items(p_forecast_id) LOOP

        IF (CurFcstSI.Stream_Item_Id IS NOT NULL) THEN

            -- Insert into cascade table to make the cascade update SI set to zero
            ltab_objects := EcDp_Revn_Forecast.t_object_tab();

            -- Getting cascade Ids for each month, in case we have several versions of stream item formulas etc. p_daytime is always 01.01.XXXX.
            FOR ln_months IN 0..11 LOOP
               EcDp_Revn_Forecast.getCascadeIds(ltab_objects, p_forecast_id, CurFcstSI.Stream_Item_Id, ADD_MONTHS(p_daytime, ln_months));
            END LOOP;

            FOR i IN 1..ltab_objects.count LOOP
                IF (ltab_objects(i).object_id = CurFcstSI.Stream_Item_Id) THEN
                   lb_found := TRUE;
                END IF;
            END LOOP;

            IF (NOT lb_found) THEN
               ltab_objects.extend;
               ltab_objects(ltab_objects.last).object_id := CurFcstSI.Stream_Item_Id;
               ltab_objects(ltab_objects.last).object_type := 'WRITE';
            END IF;

            FOR i IN 1..ltab_objects.count LOOP

                IF (ec_stim_fcst_mth_value.count_rows(ltab_objects(i).object_id, p_forecast_id, p_daytime, ADD_MONTHS(p_daytime,11)) < 12) THEN

                   InstantiateStimFcstMthYear(p_forecast_id, ltab_objects(i).object_id, p_daytime);
                END IF;
            END LOOP;

        END IF;

        IF (CurFcstSI.Adj_Stream_Item_Id IS NOT NULL) THEN
            -- Insert into cascade table to make the cascade update SI set to zero

            ltab_objects := EcDp_Revn_Forecast.t_object_tab();

            -- Getting cascade Ids for each month, in case we have several versions of stream item formulas etc. p_daytime is always 01.01.XXXX.
            FOR ln_months IN 0..11 LOOP
               EcDp_Revn_Forecast.getCascadeIds(ltab_objects, p_forecast_id, CurFcstSI.Adj_Stream_Item_Id, ADD_MONTHS(p_daytime, ln_months));
            END LOOP;

            FOR i IN 1..ltab_objects.count LOOP
                IF (ec_stim_fcst_mth_value.count_rows(ltab_objects(i).object_id, p_forecast_id, p_daytime, ADD_MONTHS(p_daytime,11)) < 12) THEN
                    InstantiateStimFcstMthYear(p_forecast_id, ltab_objects(i).object_id, p_daytime);
                END IF;
            END LOOP;

        END IF;

        IF (CurFcstSI.Swap_Stream_Item_Id IS NOT NULL) THEN
            -- Insert into cascade table to make the cascade update SI set to zero

            ltab_objects := EcDp_Revn_Forecast.t_object_tab();

            -- Getting cascade Ids for each month, in case we have several versions of stream item formulas etc. p_daytime is always 01.01.XXXX.
            FOR ln_months IN 0..11 LOOP
               EcDp_Revn_Forecast.getCascadeIds(ltab_objects, p_forecast_id, CurFcstSI.Swap_Stream_Item_Id, ADD_MONTHS(p_daytime, ln_months));
            END LOOP;

            FOR i IN 1..ltab_objects.count LOOP
                IF (ec_stim_fcst_mth_value.count_rows(ltab_objects(i).object_id, p_forecast_id, p_daytime, ADD_MONTHS(p_daytime,11)) < 12) THEN
                    InstantiateStimFcstMthYear(p_forecast_id, ltab_objects(i).object_id, p_daytime);
                END IF;
            END LOOP;

        END IF;
    END LOOP;

    -- Update all Split Keys in forecast case
    updateSplitKeys(p_forecast_id);

END PopulateStimFcstMth;

PROCEDURE updateSplitKeys(p_forecast_id VARCHAR2)
IS

CURSOR c_stream_items(cp_forecast_id VARCHAR2) IS
SELECT si.object_id, si.daytime
FROM stim_fcst_mth_value si
WHERE si.forecast_id = cp_forecast_id
AND nvl(si.calc_method,ecdp_revn_forecast.getStreamItemAttribute(si.forecast_id,si.object_id,si.daytime,'CALC_METHOD')) = 'SK'
FOR UPDATE;

BEGIN

    FOR curSI IN c_stream_items(p_forecast_id) LOOP

        UPDATE stim_fcst_mth_value
        SET split_share = Ecdp_Revn_Forecast.GetSplitShareMth(p_forecast_id, curSI.Object_Id, TRUNC(curSI.Daytime,'MM'))
            ,last_updated_by = 'INSTANTIATE'
        WHERE CURRENT OF c_stream_items;

    END LOOP;
END;

-- PROCEDURE ReEstablishStimFcstMth(p_forecast_id VARCHAR2, p_daytime DATE) IS
PROCEDURE ReEstablishStimFcstMth(p_forecast_code VARCHAR2) IS

CURSOR c_fcst_number (cp_forecast_id VARCHAR2)IS
SELECT
    fms.daytime
    ,fms.object_id
    ,fms.net_qty
    ,fms.uom
    ,fm.stream_item_id
    ,fms.status
FROM
    fcst_mth_status fms, fcst_member fm
WHERE
    fm.member_no = fms.member_no
    AND fms.object_id = cp_forecast_id
;

CURSOR c_ow_stim_fcst (cp_forecast_id VARCHAR2)IS
SELECT
    s.daytime
    ,s.object_id
    ,Ecdp_Revn_Forecast.getStreamItemAttribute(cp_forecast_id, s.object_id, s.daytime, 'CALC_METHOD') new_calc_method
FROM
    stim_fcst_mth_value s
WHERE
    s.forecast_id = cp_forecast_id
    AND nvl(s.calc_method,'NA') = 'OW' -- Using NA because Calc method on object will never be OW
;

lv2_uom_group VARCHAR2(1);
lv2_stim_uom_group VARCHAR2(1);
lv2_forecast_id VARCHAR2(32);
lv2_daytime DATE;
lv2_calc_method VARCHAR2(32);

BEGIN
    lv2_forecast_id := ec_forecast.object_id_by_uk('FORECAST',p_forecast_code);
    lv2_daytime := TRUNC(ec_forecast.start_date(lv2_forecast_id), 'YYYY');

    -- Delete the old values in the STIM_FCST table
    DELETE FROM stim_fcst_mth_value sf WHERE sf.forecast_id = lv2_forecast_id;

    -- Repopulate the STIM_FCST layer
    PopulateStimFcstMth(lv2_forecast_id, lv2_daytime);

    -- Update values from FCST case...
    FOR CurFcstNum IN c_fcst_number(lv2_forecast_id) LOOP
          IF CurFcstNum.stream_item_id IS NOT NULL THEN
              lv2_uom_group := ecdp_unit.GetUOMGroup(CurFcstNum.Uom);
              lv2_stim_uom_group := ec_stim_fcst_mth_value.master_uom_group(CurFcstNum.stream_item_id, CurFcstNum.OBJECT_ID, CurFcstNum.DAYTIME, '<=');
              lv2_calc_method := Ecdp_Revn_Forecast.getStreamItemAttribute(CurFcstNum.OBJECT_ID, CurFcstNum.stream_item_id, CurFcstNum.Daytime, 'CALC_METHOD');

              -- Do Mass update on STIM table
              IF (lv2_uom_group = 'M' AND lv2_stim_uom_group = 'M') THEN
                  UPDATE stim_fcst_mth_value t SET t.net_mass_value = ecdp_unit.convertValue(CurFcstNum.NET_QTY,
                                                                                             CurFcstNum.UOM,
                                                                                             t.mass_uom_code,
                                                                                             CurFcstNum.DAYTIME),
                               t.last_updated_by = 'INTERNAL'
                  WHERE t.object_id = CurFcstNum.stream_item_id
                  AND t.forecast_id = CurFcstNum.OBJECT_ID
                  AND t.daytime = CurFcstNum.DAYTIME;
              -- Do Volume update on STIM table
              ELSIF (lv2_uom_group = 'V' AND lv2_stim_uom_group = 'V') THEN
                  UPDATE stim_fcst_mth_value t SET t.net_volume_value = ecdp_unit.convertValue(CurFcstNum.NET_QTY,
                                                                                             CurFcstNum.UOM,
                                                                                             t.volume_uom_code,
                                                                                             CurFcstNum.DAYTIME),
                               t.last_updated_by = 'INTERNAL'
                  WHERE t.object_id = CurFcstNum.stream_item_id
                  AND t.forecast_id = CurFcstNum.OBJECT_ID
                  AND t.daytime = CurFcstNum.DAYTIME;
              -- Do Energy update on STIM table
              ELSIF (lv2_uom_group = 'E' AND lv2_stim_uom_group = 'E') THEN
                  UPDATE stim_fcst_mth_value t SET t.net_energy_value = ecdp_unit.convertValue(CurFcstNum.NET_QTY,
                                                                                             CurFcstNum.UOM,
                                                                                             t.energy_uom_code,
                                                                                             CurFcstNum.DAYTIME),
                               t.last_updated_by = 'INTERNAL'
                  WHERE t.object_id = CurFcstNum.stream_item_id
                  AND t.forecast_id = CurFcstNum.OBJECT_ID
                  AND t.daytime = CurFcstNum.DAYTIME;
              END IF;

              IF (lv2_calc_method IN ('IP', 'CO')) THEN
                  -- Force Cascade
                  INSERT INTO stim_cascade (object_id, period, daytime, forecast_id, last_updated_by) VALUES
                   (CurFcstNum.stream_item_id, 'FCST_MTH', CurFcstNum.DAYTIME, CurFcstNum.OBJECT_ID, 'INTERNAL');
              END IF;

          END IF; -- Stream Item

    END LOOP; -- CurFcstNum

    -- Reset Calc Method
    FOR CurOw IN c_ow_stim_fcst(lv2_forecast_id) LOOP
        UPDATE stim_fcst_mth_value SET calc_method = NULL
         WHERE object_id = CurOw.Object_Id
         AND daytime = CurOw.daytime
         AND forecast_id = lv2_forecast_id
         ;
        EcDp_Revn_Forecast.postUpdNetQty(lv2_forecast_id, NULL, CurOw.daytime, USER, NULL, CurOw.Object_Id);
    END LOOP; -- CurOw

END ReEstablishStimFcstMth;


END EcDp_Revn_Stim_Fcst;