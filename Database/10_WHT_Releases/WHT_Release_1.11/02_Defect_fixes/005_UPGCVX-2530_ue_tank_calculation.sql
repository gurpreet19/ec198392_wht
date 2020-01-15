CREATE OR REPLACE PACKAGE BODY Ue_Tank_Calculation IS
/****************************************************************
** Package        :  Ue_Tank_Calculation, body part
**
** This package is used to program theoretical calculation when a predefined method supplied by EC does not cover the requirements.
** Upgrade processes will never replace this package.
**
** Date:       Whom:   Change description:
** --------    -----   --------------------------------------------
** 21.12.2007  oonnnng ECPD-6716:  Add getBSW() function.
** 07.01.2010  oonnnng ECPD-13585:  Add calcRoofDisplacementVol() function.
** 12.08.2013  kumarsur ECPD-22316:  Add findBlendShrinkageFactor() function.
** 27.05.2014  makkkkam ECPD-27440: Add findDiluentDens, findBitumenDens, findNetStdOilVol, findNetDiluentVol.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrsVol
-- Description    : Returns Tank's Gross Volume
---------------------------------------------------------------------------------------------------
FUNCTION getGrsVol(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS
CURSOR getValidComponent(
cp_daytime          DATE,
cp_analysis_type    VARCHAR2
)IS
SELECT COMPONENT_NO, SUM_FACTOR,MOL_WT
FROM DV_COMPONENT_CONSTANT
WHERE OBJECT_CODE = EC_CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT(cp_daytime,'STANDARD_CODE','<=')
AND EXISTS (SELECT 'TRUE' FROM TV_COMPONENT_SET_LIST SL WHERE SL.CODE = cp_analysis_type AND SL.COMPONENT_NO =  DV_COMPONENT_CONSTANT.COMPONENT_NO)
ORDER BY COMPONENT_NO;

CURSOR getCompFrLtAprAnal(
    cp_object_id        stream.object_id%TYPE,
    cp_analysis_type    VARCHAR2,
    cp_daytime          DATE,
    cp_phase            VARCHAR2,
    cp_component_no     VARCHAR2
)IS
SELECT COMPONENT_NO,WT_PCT,MOL_PCT
FROM fluid_analysis_component
WHERE ANALYSIS_NO in(
SELECT ANALYSIS_NO
      FROM object_fluid_analysis ofa
     WHERE ofa.object_id = cp_object_id
       AND ofa.analysis_type = cp_analysis_type
       --AND ofa.sampling_method = cp_sampling_method
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.phase = cp_phase
       AND ofa.valid_from_date = (
           SELECT MAX(ofb.valid_from_date)
             FROM object_fluid_analysis ofb
            WHERE ofb.object_id = ofa.object_id
              AND ofb.analysis_type = ofa.analysis_type
              AND ofb.sampling_method = ofa.sampling_method
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.phase = cp_phase
              AND ofb.valid_from_date <= cp_daytime)
)
AND COMPONENT_NO = cp_component_no;

ln_line_temperature number;
ln_line_pressure number;
ln_base_temperature number;
ln_base_pressure number;
lv_gas_standard VARCHAR2(32);
ln_pipeline_volume number;
lv_analysis_stream_id VARCHAR2(32);
ln_std_volume number;
ln_summation number;
ln_z_comp number;
lv_Product VARCHAR2(32);
lnStorageID storage.object_id%TYPE;
lv_stream_phase VARCHAR2(32);
lv_comp_set_code VARCHAR2(32);


BEGIN
--  Heading for gas pipeline line package
--  Determine if tank is part of a STORAGE with product GAS
	--lnProduct := ECDP_OBJECTS.GETOBJCODE(EC_STOR_VERSION.PRODUCT_ID((SELECT OBJECT_ID FROM DV_TANK_USAGE WHERE TANK_CODE IN (SELECT CODE FROM OV_TANK WHERE OBJECT_ID = p_object_id)),p_daytime,'<='));
	SELECT OBJECT_ID into lnStorageID FROM DV_TANK_USAGE WHERE TANK_CODE IN (SELECT CODE FROM OV_TANK WHERE OBJECT_ID = p_object_id);
	lv_Product := ECDP_OBJECTS.GETOBJCODE(
				 EC_STOR_VERSION.PRODUCT_ID(lnStorageID,p_daytime,'<=')
				);
	-- if so do the following, else return NULL
	IF NVL(lv_Product,'NONE') = 'GAS' THEN
		ln_line_temperature := EC_TANK_MEASUREMENT.VALUE_9(p_object_id,p_meas_event_type,p_daytime);  -- Get from daily tank
		ln_line_pressure := EC_TANK_MEASUREMENT.VALUE_10(p_object_id,p_meas_event_type,p_daytime); -- get from daily tank
        ln_base_temperature := ECDP_SYSTEM.getAttributeValue(p_daytime, 'REF_TEMP_BASE');
-- The system attribute reference pressure is in BAR.  Multiply by 100 to get KPAA
        ln_base_pressure := ECDP_SYSTEM.getAttributeValue(p_daytime, 'REF_PRESS_BASE') * 100;
		ln_pipeline_volume := EC_TANK_VERSION.MAX_VOL(p_object_id,p_daytime,'<=');
        lv_analysis_stream_id := EC_TANK_VERSION.analysis_stream_id(p_object_id,p_daytime,'<=');
 -- If the tank has a reference stream analysis then do a super compressibility calculation and ideal gas
       IF lv_analysis_stream_id is not null THEN
			-- Look up the STANDARD_CODE from system attributes
		   lv_gas_standard := ECDP_SYSTEM.getAttributeText(p_daytime, 'STANDARD_CODE');
			-- Look up the Reference stream from the Pipeline and check the Component Set used
			-- Look up the component set that belongs to the stream
			lv_comp_set_code := ec_strm_version.comp_set_code(lv_analysis_stream_id,p_daytime,'<=');
			-- Get the Stream Phase
			lv_stream_phase := EC_STRM_VERSION.STREAM_PHASE(lv_analysis_stream_id,p_daytime,'<=');
			ln_summation:=0;
		-- Iterate through each component in the hydrocarbon set
		FOR mycur IN getValidComponent(p_daytime, lv_comp_set_code ) LOOP
			--iterate thru component analysis
			FOR mycomp IN getCompFrLtAprAnal(lv_analysis_stream_id,lv_comp_set_code,p_daytime,lv_stream_phase,mycur.COMPONENT_NO  ) LOOP
			-- Make sure you are using the Mole percent and assume the analysis will have mole percent.
				ln_summation := ln_summation  + (mycomp.MOL_PCT/100 * mycur.SUM_FACTOR) ;
			END LOOP;
		END LOOP;
			-- Calculate the Z (super compressibility)
				ln_z_comp := 1 - (ln_line_pressure * (POWER(ln_summation,2)));
				ln_std_volume := ln_pipeline_volume * (ln_line_pressure / ln_base_pressure) * ((273.15 + ln_base_temperature)/(273.15+ln_line_temperature)) * ln_z_comp;
			-- Otherwise just do an ideal gas calculation
		ELSE
			ln_std_volume := ln_pipeline_volume * (ln_line_pressure / ln_base_pressure) * ((273.15 + ln_base_temperature)/(273.15+ln_line_temperature));
		END IF;
	ELSE
		ln_std_volume := NULL;
	END IF;
    RETURN ln_std_volume;
END getGrsVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrsMass
-- Description    : Returns Tank's Gross Mass
--  Use the gross volume and the corrected density to calculate the gross mass in the tank
---------------------------------------------------------------------------------------------------
FUNCTION getGrsMass(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
ln_grsmass number;
ln_grsstdvol number;
lr_measurement TANK_MEASUREMENT%ROWTYPE;
v_return_value NUMBER;
v_density_unit VARCHAR2(32);
v_source_mass_unit VARCHAR2(32);
v_target_mass_unit VARCHAR2(32);
CURSOR c_tank_measurement(p_tank_object_id IN TANK.OBJECT_ID%TYPE,
                          p_meas_event_type IN TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
                          p_daytime DATE) IS
SELECT *
FROM tank_measurement tm
WHERE tm.object_id = p_tank_object_id
  AND tm.measurement_event_type = p_meas_event_type
  AND tm.daytime = p_daytime;

BEGIN
   ln_grsstdvol := ecbp_tank.findGrsStdOilVol(p_object_id,p_meas_event_type,p_daytime);

  OPEN c_tank_measurement( p_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;

-- The following code does a look up for the unit conversion if the density is in kg/m3 and the mass is in tonnes
--  This conversion is being done on the tank measurement
    -- Get the units that we're starting from
    v_density_unit := ecdp_unit.getunitfromlogical(ecdp_classmeta_cnfg.getUomCode('TANK_OIL_BATCH_EXP_DET', 'CORR_DENSITY'));
    v_target_mass_unit := ecdp_unit.getunitfromlogical(ecdp_classmeta_cnfg.getUomCode('TANK_OIL_BATCH_EXP', 'STD_GRS_LIQ_MASS'));

    -- Assume that the source mass unit can be obtained by truncating the density unit up to the 'PER'
    -- Ex: 'KGPERSM3' has a mass output of 'KG'
    v_source_mass_unit := NVL(SUBSTR(v_density_unit, 0, INSTR(v_density_unit, 'PER') -1), v_density_unit);

    v_return_value:=ln_grsstdvol * lr_measurement.CORR_DENSITY;

    -- Now convert between the source and target mass units:

    IF v_target_mass_unit <> v_source_mass_unit THEN
        v_return_value := ecdp_unit.convertvalue(v_return_value, v_source_mass_unit, v_target_mass_unit);
    END IF;

  --  Final calcution including converting to tons from kg
  -- Round to 3 digits
  --ln_grsmass := round(v_return_value,3);
  ln_grsmass := v_return_value;

   RETURN ln_grsmass;

END getGrsMass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNetMass
-- Description    : Returns Tank's Net Mass
--  Use the net volume and the corrected density to calculate the net mass in the tank
---------------------------------------------------------------------------------------------------
FUNCTION getNetMass(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
ln_netmass number;
ln_netvol number;
lr_measurement TANK_MEASUREMENT%ROWTYPE;

CURSOR c_tank_measurement(p_tank_object_id IN TANK.OBJECT_ID%TYPE,
                          p_meas_event_type IN TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
                          p_daytime DATE) IS
SELECT *
FROM tank_measurement tm
WHERE tm.object_id = p_tank_object_id
  AND tm.measurement_event_type = p_meas_event_type
  AND tm.daytime = p_daytime;

BEGIN

   ln_netvol := ecbp_tank.findNetStdOilVol(p_object_id,p_meas_event_type,p_daytime);

    OPEN c_tank_measurement( p_object_id, p_meas_event_type, p_daytime );
  FETCH c_tank_measurement INTO lr_measurement;
  CLOSE c_tank_measurement;
  --  Final calcution including converting to tons from kg
  -- Round to 3 digits
   --ln_netmass := round(((ln_netvol * lr_measurement.CORR_DENSITY)/1000),3);
   ln_netmass := (ln_netvol * lr_measurement.CORR_DENSITY)/1000;

   RETURN ln_netmass;
END getNetMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getVolumeCorrectionFactor
-- Description    : Returns Tank's Volume Correction Factor
---------------------------------------------------------------------------------------------------
FUNCTION getVolumeCorrectionFactor(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getVolumeCorrectionFactor;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWaterVol
-- Description    : Returns Tank's Water Volume
---------------------------------------------------------------------------------------------------
FUNCTION getWaterVol(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
ln_watervol number;

BEGIN

ln_watervol := ECBP_TANK.FINDFREEWATERVOL(p_object_id,p_meas_event_type,p_daytime) +  ecbp_tank.findGrsOilVol(p_object_id,p_meas_event_type,p_daytime) *  ecbp_tank.findBSWVol(p_object_id,p_meas_event_type,p_daytime);

  RETURN ln_watervol;
END getWaterVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFreeWaterVol
-- Description    : Returns Tank's Free Water Volume
---------------------------------------------------------------------------------------------------
FUNCTION getFreeWaterVol(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getFreeWaterVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :getObsDens
-- Description    : Returns density at stock tank conditions
---------------------------------------------------------------------------------------------------
FUNCTION getObsDens(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
 -- Item 126541: Begin
      ln_obs_density NUMBER;
      lr_measurement TANK_MEASUREMENT%ROWTYPE;
	  lv_vcf_method  VARCHAR2(32);
      -- Item 126541: End
   BEGIN
      -- Item 126541: Begin
      --RETURN NULL;
	  lr_measurement := ec_tank_measurement.row_by_pk(p_object_id, p_meas_event_type, p_daytime);
	  lv_vcf_method := ec_tank_version.vcf_method(p_object_id, p_daytime, '<=');
	  IF lv_vcf_method = 'NO_VCF'
	  THEN
         -- Final calculation of observed density based on corrected density, run temperature and target temperature of 15 standard SI
         ln_obs_density := ecbp_vcf.calcDensityCorr_SI(lr_measurement.CORR_DENSITY, 15, lr_measurement.RUN_TEMP);
	  ELSE
	     -- Final calculation of observed density based on corrected density and VCF
         ln_obs_density := lr_measurement.CORR_DENSITY * lr_measurement.VCF;
	  END IF;

      RETURN ln_obs_density;
	  -- Item 126541: End
END getObsDens;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :getBSWVol
-- Description    : Returns BS and W (volume) at standard conditions
---------------------------------------------------------------------------------------------------
FUNCTION getBSWVol(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getBSWVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :getStdDens
-- Description    : Returns density at standard conditions
---------------------------------------------------------------------------------------------------
FUNCTION getStdDens(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
CURSOR getValidComponent(
cp_daytime          DATE,
cp_analysis_type    VARCHAR2
)IS
SELECT COMPONENT_NO, SUM_FACTOR,MOL_WT
FROM DV_COMPONENT_CONSTANT
WHERE OBJECT_CODE = EC_CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT(cp_daytime,'STANDARD_CODE','<=')
AND EXISTS (SELECT 'TRUE' FROM TV_COMPONENT_SET_LIST SL WHERE SL.CODE = cp_analysis_type AND SL.COMPONENT_NO =  DV_COMPONENT_CONSTANT.COMPONENT_NO)
ORDER BY COMPONENT_NO;

CURSOR getCompFrLtAprAnal(
    cp_object_id        stream.object_id%TYPE,
    cp_analysis_type    VARCHAR2,
    cp_daytime          DATE,
    cp_phase            VARCHAR2,
    cp_component_no     VARCHAR2
)IS
SELECT COMPONENT_NO,WT_PCT,MOL_PCT
FROM fluid_analysis_component
WHERE ANALYSIS_NO in(
SELECT ANALYSIS_NO
      FROM object_fluid_analysis ofa
     WHERE ofa.object_id = cp_object_id
       AND ofa.analysis_type = cp_analysis_type
       --AND ofa.sampling_method = cp_sampling_method
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.phase = cp_phase
       AND ofa.valid_from_date = (
           SELECT MAX(ofb.valid_from_date)
             FROM object_fluid_analysis ofb
            WHERE ofb.object_id = ofa.object_id
              AND ofb.analysis_type = ofa.analysis_type
              AND ofb.sampling_method = ofa.sampling_method
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.phase = cp_phase
              AND ofb.valid_from_date <= cp_daytime)
)
AND COMPONENT_NO = cp_component_no;


ln_base_temperature number;
ln_base_pressure number;
lv_gas_standard VARCHAR2(32);
lv_analysis_stream_id VARCHAR2(32);
ln_std_dens number;
ln_summation number;
ln_avg_mw number;
ln_z_comp number;
lv_Product VARCHAR2(32);
lnStorageID storage.object_id%TYPE;
lv_stream_phase VARCHAR2(32);
lv_comp_set_code VARCHAR2(32);
lv2_calc_method VARCHAR2(300);
lr_analysis_sample object_fluid_analysis%ROWTYPE;


BEGIN
--There were 2 type of Density used
--1) Gas Composition: applies to Gas Pipeline
--2) Stream Component Analysis: applies to Tank that uses reference stream BUT Tieto only support "STREAM_SAMPLE_ANALYSIS"
	-- Get Tank Density Method
	lv2_calc_method := Ec_Tank_version.DENSITY_METHOD(p_object_id, p_daytime, '<=') ;
	-- Gas Composition
/*	IF (lv2_calc_method = 'USER_EXIT_01') THEN

	--  Heading for gas pipeline line package
	--  Determine if tank is part of a STORAGE with product GAS
		SELECT OBJECT_ID into lnStorageID FROM DV_TANK_USAGE WHERE TANK_CODE IN (SELECT CODE FROM OV_TANK WHERE OBJECT_ID = p_object_id);
		lv_Product := ECDP_OBJECTS.GETOBJCODE(
					 EC_STOR_VERSION.PRODUCT_ID(lnStorageID,p_daytime,'<=')
					);
		-- if so do the following, else return NULL
		IF NVL(lv_Product,'NONE') = 'GAS' THEN
			ln_base_temperature := ECDP_SYSTEM.getAttributeValue(p_daytime, 'REF_TEMP_BASE');
	-- The system attribute reference pressure is in BAR.  Multiply by 100 to get KPAA
			ln_base_pressure := ECDP_SYSTEM.getAttributeValue(p_daytime, 'REF_PRESS_BASE') * 100;
			lv_analysis_stream_id := EC_TANK_VERSION.analysis_stream_id(p_object_id,p_daytime,'<=');
	 -- If the tank has a reference stream analysis then do a super compressibility calculation and ideal gas
		   IF lv_analysis_stream_id is not null THEN
				-- Look up the STANDARD_CODE from system attributes
			   lv_gas_standard := ECDP_SYSTEM.getAttributeText(p_daytime, 'STANDARD_CODE');
				-- Look up the Reference stream from the Pipeline and check the Component Set used
				-- Look up the component set that belongs to the stream
				lv_comp_set_code := ec_strm_version.comp_set_code(lv_analysis_stream_id,p_daytime,'<=');
				-- Get the Stream Phase
				lv_stream_phase := EC_STRM_VERSION.STREAM_PHASE(lv_analysis_stream_id,p_daytime,'<=');
				ln_summation:=0;
				ln_avg_mw := 0;
			-- Iterate through each component in the hydrocarbon set
			FOR mycur IN getValidComponent(p_daytime, lv_comp_set_code ) LOOP
				--iterate thru component analysis
				FOR mycomp IN getCompFrLtAprAnal(lv_analysis_stream_id,lv_comp_set_code,p_daytime,lv_stream_phase,mycur.COMPONENT_NO  ) LOOP
				-- Make sure you are using the Mole percent and assume the analysis will have mole percent.
					ln_summation := ln_summation  + (mycomp.MOL_PCT/100 * mycur.SUM_FACTOR) ;
					ln_avg_mw := ln_avg_mw + (mycomp.MOL_PCT/100 * mycur.MOL_WT);
				END LOOP;
			END LOOP;
				-- Calculate the Z (super compressibility)
					ln_z_comp := 1 - (ln_base_pressure * (POWER(ln_summation,2)));
				--  Calculate density and adjust for super compressibility
			  ln_std_dens := (ln_avg_mw * ln_base_pressure) / (8.314510 * (273.15 + ln_base_temperature)) / ln_z_comp ;
              --  convert density to tonnes/sm3
              ln_std_dens := ln_std_dens / 1000;
			ELSE
			  ln_std_dens := NULL;
			END IF;
		ELSE
			ln_std_dens := NULL;
		END IF;
	END IF;   */
	--Stream Component Analysis
	IF (lv2_calc_method = 'USER_EXIT_01') THEN
		lv_analysis_stream_id := NVL(EC_TANK_VERSION.analysis_stream_id(p_object_id,p_daytime,'<='),'NA');
		-- Get the Comp set code
		lv_comp_set_code := NVL(ec_strm_version.comp_set_code(lv_analysis_stream_id,p_daytime,'<='),'NA');
		-- Get the Stream Phase
		lv_stream_phase := EC_STRM_VERSION.STREAM_PHASE(lv_analysis_stream_id,p_daytime,'<=');
		lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_analysis_stream_id, lv_comp_set_code, 'SPOT', p_daytime, lv_stream_phase);
         --  convert density to tonnes/sm3
		ln_std_dens := lr_analysis_sample.density/1000;
	END IF;


    RETURN ln_std_dens;
END getStdDens;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :getBSWWT
-- Description    : Returns BS and W (volume) at standard conditions
---------------------------------------------------------------------------------------------------
FUNCTION getBSWWT(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getBSWWT;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcRoofDisplacementVol
-- Description    : Returns roof displacement volume
---------------------------------------------------------------------------------------------------
FUNCTION calcRoofDisplacementVol(
   p_object_id          TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_dip_level          NUMBER,
   p_daytime            DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END calcRoofDisplacementVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findBlendShrinkageFactor
-- Description    :
---------------------------------------------------------------------------------------------------
FUNCTION findBlendShrinkageFactor(
    p_object_id          TANK.OBJECT_ID%TYPE,
    p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
    p_daytime            DATE,
    p_diluent_dens       NUMBER,
	p_bitumen_dens       NUMBER,
	p_tank_dens          NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END findBlendShrinkageFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :findDiluentDens
-- Description    :
---------------------------------------------------------------------------------------------------
FUNCTION findDiluentDens(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END findDiluentDens;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :findBitumenDens
-- Description    :
---------------------------------------------------------------------------------------------------
FUNCTION findBitumenDens(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END findBitumenDens;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :findNetStdOilVol
-- Description    :
---------------------------------------------------------------------------------------------------
FUNCTION findNetStdOilVol(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END findNetStdOilVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :findNetDiluentVol
-- Description    :
---------------------------------------------------------------------------------------------------
FUNCTION findNetDiluentVol(
   p_object_id   tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END findNetDiluentVol;

END Ue_Tank_Calculation;
/
