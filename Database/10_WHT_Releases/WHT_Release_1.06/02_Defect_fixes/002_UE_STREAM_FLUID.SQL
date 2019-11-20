create or replace package Ue_Stream_Fluid is

/****************************************************************
** Package        :  Ue_Stream_Fluid
**
** Modification history:
**
** Date        Whom     Change description:
** ---------   -------- --------------------------------------
** 21.12.2007  oonnnng  ECPD-6716: Add getBSWVol and getBSWWT function.
** 20.02.2008  oonnnng	ECPD-6978: Add getGCV function.
** 09.02.2009  farhaann ECPD-10761: Added getNetStdMass, getGrsStdMass, getWatVol, getCondVol, getEnergy,
**                                  getStdDens, getWatMass and getGrsDens functions.
** 03.08.09    embonhaf ECPD-11153 Added VCF calculation for stream.
** 19.11.2009  leongwen ECPD-13175 Added findOnStreamHours function.
** 09.01.2013  hismahas ECPD-22580 Added getGrsStdVol and getNetStdVol functions.
** 08.05.2013  musthram ECPD-23714 Added  getPowerConsumption and getSaltWT functions.
** 03.03.2014  dhavaalo ECPD-26738 Package ue_stream_fluid is missing the parameter P_TODATE in all functions
****************************************************************/

FUNCTION getBSWVol(
      p_object_id    stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION getBSWWT(
      p_object_id    stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION getGCV(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getGrsStdMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getGrsStdVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getNetStdMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getNetStdVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getWatVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getCondVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getEnergy(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getStdDens(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION getWatMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getGrsDens(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION getVCF(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION getPowerConsumption(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getSaltWT(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER;

FUNCTION findOnStreamHours(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER;

end Ue_Stream_Fluid;
/
create or replace package body Ue_Stream_Fluid is
/****************************************************************
** Package        :  Ue_Stream_Fluid, body part
**
** Purpose        :  This package is used to program theoretical calculation when a predefined method supplied by EC does not cover the requirements.
**                   Upgrade processes will never replace this package.
**
** Modification history:
**
** Date        Whom     Change description:
** ---------   -------- --------------------------------------
** 21.12.2007  oonnnng  ECPD-6716: Add getBSWVol and getBSWWT function.
** 20.02.2008  oonnnng	ECPD-6978: Add getGCV function.
** 09.02.2009  farhaann ECPD-10761: Added getNetStdMass, getGrsStdMass, getWatVol, getCondVol, getEnergy,
**                                  getStdDens, getWatMass and getGrsDens functions.
** 03.08.09    embonhaf ECPD-11153 Added VCF calculation for stream.
** 19.11.2009  leongwen ECPD-13175 Added findOnStreamHours function.
** 09.01.2013  hismahas ECPD-22580 Added getGRsStdVol and getNetStdVol functions.
** 08.05.2013  musthram ECPD-23714 Added  getPowerConsumption and getSaltWT functions.
** 03.03.2014  dhavaalo ECPD-26738 Package ue_stream_fluid is missing the parameter P_TODATE in all functions
** 07.05.2019  gedv     Item_132202: ISWR03158: Updated the gross mass function to use new volume method for water streams.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getBSWVol
-- Description    : Returns BS and W (volume)
---------------------------------------------------------------------------------------------------
FUNCTION getBSWVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getBSWVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getBSWWT
-- Description    : Returns BS and W (weight)
---------------------------------------------------------------------------------------------------
FUNCTION getBSWWT(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getBSWWT;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGCV
-- Description    : Returns GCV value
---------------------------------------------------------------------------------------------------
FUNCTION getGCV(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGCV;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getGrsStdMass
-- Description    : Returns getGrsStdMass value
---------------------------------------------------------------------------------------------------
FUNCTION getGrsStdMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
    v_return_value NUMBER;
	lv2_stream_phase VARCHAR2(32);
	v_vol NUMBER;

BEGIN
	lv2_stream_phase := EC_STRM_VERSION.STREAM_PHASE(p_object_id, p_daytime, '<=');

    IF lv2_stream_phase = 'COND' THEN

		IF ECDP_OBJECTS.GetObjCode(p_object_id) = 'SW_GP_COND_TANK' THEN
			v_return_value := ecbp_stream_fluid.findgrsstdmass(p_object_id, p_daytime, null, EcDp_Calc_Method.NET_MASS_WATER);
		END IF;

	END IF;

    IF lv2_stream_phase = 'WAT' THEN
-- Item_132202: ISWR03158: Starts       
	   v_vol:=null;
        select distinct GRS_VOL_TO_BE_USED into v_vol from DV_STRM_DAY_STREAM_MEAS_WAT where object_id=p_object_id and daytime=p_daytime;
		v_return_value := nvl(v_vol, EcBp_Stream_Fluid.findGrsStdVol(p_object_id,p_daytime)) * EcBp_Stream_Fluid.findGrsDens(p_object_id,p_daytime);
-- Item_132202: ISWR03158: Ends.
	END IF;


	RETURN v_return_value;
END getGrsStdMass;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getGrsStdVol
-- Description    : Returns getGrsStdVol value
---------------------------------------------------------------------------------------------------
FUNCTION getGrsStdVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGrsStdVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNetStdMass
-- Description    : Returns NetStdMass value
---------------------------------------------------------------------------------------------------
FUNCTION getNetStdMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv_not_lifted_today NUMBER;
    lv_not_lifted_prev NUMBER;
    lv_not_lifted NUMBER;
    lv_Load NUMBER;
    lr_analysis_sample object_fluid_analysis%ROWTYPE;
    lv_LNG_id VARCHAR(32);
    lv_COND_id VARCHAR(32);
    lv_Density NUMBER;


    CURSOR C_CARGO(cp_Code VARCHAR2) IS
      SELECT OBJECT_ID,CARGO_NO
      FROM DV_STOR_DAY_EXPORT_STATUS
      WHERE daytime BETWEEN (p_daytime-1) AND (p_daytime)
      AND OBJECT_CODE = cp_Code
      GROUP BY OBJECT_ID,CARGO_NO
      ORDER BY CARGO_NO;

    ln_grs_mass         NUMBER;
    ln_wat_mass         NUMBER;
    ln_net_mass         NUMBER;
	lv_forecast_object_id VARCHAR2(32);

BEGIN
--Start Edit: tlxt
--The data class for Day end Not lifted is "DV_STOR_DAY_EXPORT_STATUS"
--FOR LNG/COND Related streams
    CASE ECDP_OBJECTS.GetObjCode(p_object_id)
        WHEN  'SW_GP_LNG_FORECAST' THEN
            --get forecast mass rate
			SELECT object_id INTO lv_forecast_object_id FROM OV_CT_PROD_FORECAST WHERE FORECAST_TYPE = 'ADP_PLAN' AND SCENARIO = 'REF_PROD' AND RECORD_STATUS = 'A' AND LAST_UPD_DATE = (SELECT MAX(LAST_UPD_DATE) FROM OV_CT_PROD_FORECAST WHERE FORECAST_TYPE = 'ADP_PLAN' AND SCENARIO = 'REF_PROD' AND RECORD_STATUS = 'A' AND OBJECT_START_DATE <= p_daytime AND OBJECT_END_DATE - 1 >= p_daytime);
			IF lv_forecast_object_id IS NOT NULL THEN
                SELECT LNG_MASS_RATE INTO lv_Load FROM DV_CT_PROD_STRM_FORECAST WHERE OBJECT_CODE = 'SW_GP_LNG_FORECAST' AND FORECAST_TYPE = 'ADP_PLAN' AND SCENARIO = 'REF_PROD' AND RECORD_STATUS = 'A' AND DAYTIME = p_daytime AND FORECAST_OBJECT_ID = lv_forecast_object_id;
            ELSE
                lv_Load := 0;
            END IF;
        WHEN  'SW_GP_LNG_NOT_LIFTED' THEN
            --get the LNG and COND object ID
            lv_LNG_id := ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_LNG_CARGO');
            lv_COND_id := ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_COND_CARGO');
            --IF it is 'SW_GP_LNG_NOT_LIFTED', then it means we need to get the value from the Day End Not Lifted BF in Marine
            FOR curCARGO IN C_CARGO('STW_LNG') LOOP
                SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime)
                INTO lv_not_lifted_today
                FROM DUAL;

                IF NVL(lv_not_lifted_today,0) <> 0 THEN
                    lv_not_lifted := lv_not_lifted_today;
                ELSE
                    lv_not_lifted := 0;
                END IF;
                lv_Load := nvl(lv_Load,0) + lv_not_lifted;
            END LOOP;
            lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_LNG_id, 'STRM_LNG_COMP', NULL, p_daytime, 'LNG');
            lv_Density := lr_analysis_sample.density/1000;

            --loaded value in Vol, need to convert to Mass
            lv_Load := lv_Density * lv_Load;
        WHEN  'SW_GP_LNG_LOAD' THEN
            --get the LNG and COND object ID
            lv_LNG_id := ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_LNG_CARGO');
            lv_COND_id := ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_COND_CARGO');
            --this is the Lifted value.
            --Formula: CargoEventCalc + decode(today's DENL, 0,prev's DENL,today's DENL)
            FOR curCARGO IN C_CARGO('STW_LNG') LOOP
			            lv_not_lifted := 0;
                        SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime) INTO lv_not_lifted_today FROM DUAL;

                        SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime-1) INTO lv_not_lifted_prev FROM DUAL;

                        IF NVL(lv_not_lifted_today,0) <> 0 THEN
                            lv_not_lifted := lv_not_lifted_today;
							lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_LNG_id, 'STRM_LNG_COMP', 'SPOT', p_daytime, 'LNG');
							lv_Density := lr_analysis_sample.density / 1000;
							lv_not_lifted := lv_Density * lv_not_lifted;
                        END IF;

						IF NVL(lv_not_lifted_prev,0) <> 0 THEN
							lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_LNG_id, 'STRM_LNG_COMP', 'SPOT', p_daytime - 1, 'LNG');
							lv_Density := lr_analysis_sample.density / 1000;
							--loaded value in Vol, need to convert to Mass based on previous day density
							lv_not_lifted_prev := lv_Density * lv_not_lifted_prev;
							lv_not_lifted := lv_not_lifted_prev * -1 + NVL(lv_not_lifted, 0);
                        END IF;

                        lv_Load := nvl(lv_Load,0) + NVL(lv_not_lifted, 0);
            END LOOP;
            --lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_LNG_id, 'STRM_LNG_COMP', 'SPOT', p_daytime, 'LNG');
            --lv_Density := lr_analysis_sample.density/1000;
            --loaded value in Vol, need to convert to Mass
            --lv_Load := lv_Density * lv_Load;
			lv_Load := NVL(lv_Load, 0) + EcBp_Stream_Fluid.findNetStdMass(ec_stream.object_id_by_uk('SW_GP_LNG_CARGO'), p_daytime);
            --ln_return_val := nvl(lv_Load,0) + nvl(EC_STRM_EVENT.math_net_mass(ECDP_OBJECTS.GetObjIDFromCode('STREAM','SW_GP_LNG_CARGO'),'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
        WHEN  'SW_GP_LNG_CARGO' THEN
            --This stream should be set to UE as it will be inserted into LACT Ticket screen and not seen in any of the Stream_day_stream class
            --ln_return_val :=nvl(EC_STRM_EVENT.math_net_mass(p_object_id,'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
			lv_Load :=nvl(EC_STRM_EVENT.math_net_mass(p_object_id,'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
        WHEN  'SW_GP_COND_NOT_LIFTED' THEN
            --get the LNG and COND object ID
            lv_LNG_id := ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_LNG_CARGO');
            lv_COND_id := ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_COND_CARGO');
            --IF it is 'SW_GP_COND_NOT_LIFTED', then it means we need to get the value from the Day End Not Lifted BF in Marine
            FOR curCARGO IN C_CARGO('STW_COND') LOOP
                SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime) INTO lv_not_lifted_today FROM DUAL;

                IF NVL(lv_not_lifted_today,0) <> 0 THEN
                    lv_not_lifted := lv_not_lifted_today;
                ELSE
                    lv_not_lifted := 0;
                END IF;
                lv_Load := nvl(lv_Load,0) + lv_not_lifted;
            END LOOP;
            lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_COND_id, 'STRM_OIL_COMP', 'SPOT', p_daytime, 'COND');
            lv_Density := lr_analysis_sample.density/1000;
            --loaded value in Vol, need to convert to Mass
            --ln_return_val := lv_Density * lv_Load;
			lv_Load := lv_Density * lv_Load;
            WHEN  'SW_GP_COND_LOAD' THEN
            --get the LNG and COND object ID
            lv_LNG_id := ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_LNG_CARGO');
            lv_COND_id := ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_COND_CARGO');
            --this is the Lifted value.
            --Formula: CargoEventCalc + decode(today's DENL, 0,prev's DENL,today's DENL)
            FOR curCARGO IN C_CARGO('STW_COND') LOOP
						lv_not_lifted := 0;

						SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime) INTO lv_not_lifted_today FROM DUAL;

                        SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime-1) INTO lv_not_lifted_prev FROM DUAL;

                        IF NVL(lv_not_lifted_today,0) <> 0 THEN
                            lv_not_lifted := lv_not_lifted_today;
							lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_COND_id, 'STRM_OIL_COMP', 'SPOT', p_daytime, 'COND');
							lv_Density := lr_analysis_sample.density / 1000;
							--loaded value in Vol, need to convert to Mass based on today's density
							lv_not_lifted := lv_Density * lv_not_lifted;
						END IF;

                        IF NVL(lv_not_lifted_prev,0) <> 0 THEN
							lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_COND_id, 'STRM_OIL_COMP', 'SPOT', p_daytime - 1, 'COND');
							lv_Density := lr_analysis_sample.density / 1000;
							--loaded value in Vol, need to convert to Mass based on yesterday density
							lv_not_lifted_prev := lv_Density * lv_not_lifted_prev;
							lv_not_lifted := lv_not_lifted_prev * -1 + NVL(lv_not_lifted, 0);
                        END IF;
                        lv_Load := NVL(lv_Load, 0) + NVL(lv_not_lifted, 0);
            END LOOP;

            --ln_return_val := nvl(lv_Load,0) + nvl(EC_STRM_EVENT.math_net_mass(ECDP_OBJECTS.GetObjIDFromCode('STREAM','SW_GP_COND_CARGO'),'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
			lv_Load := NVL(lv_Load, 0) + NVL(EC_STRM_EVENT.math_net_mass(ECDP_OBJECTS.GetObjIDFromCode('STREAM', 'SW_GP_COND_CARGO'), 'STRM_OIL_BATCH_EVENT', p_daytime, (p_daytime + 1 - 1 / 24 / 60 / 60)), 0);
        WHEN  'SW_GP_COND_CARGO' THEN
            --This stream should be set to UE as it will be inserted into LACT Ticket screen and not seen in any of the Stream_day_stream class
            --ln_return_val :=nvl(EC_STRM_EVENT.math_net_mass(p_object_id,'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
			lv_Load :=nvl(EC_STRM_EVENT.math_net_mass(p_object_id,'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
        WHEN  'SW_GP_BOG_IMPORT' THEN
            --This stream should be set to UE as it will be inserted into LACT Ticket screen and not seen in any of the Stream_day_stream class
            --ln_return_val :=nvl(EC_STRM_EVENT.math_net_mass(p_object_id,'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
			lv_Load :=nvl(EC_STRM_EVENT.math_net_mass(p_object_id,'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
--Calculating BOG for C1 and INERT
        ----Item 127686: ISWR02347: Commenting below stream as we are not using them anymore:SW_GP_BOG_C1_IMPORT
        /*WHEN  'SW_GP_BOG_C1_IMPORT' THEN
            --check from DV_STRM_OIL_BATCH_EVENT-->SG_BOG_IMPORT->PURGE_IND. If it is NOT 'Y', then it is considered as "C1"
            lv_Load := 0;
			IF NVL(EC_STRM_EVENT.TEXT_10(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_BOG_IMPORT'),'STRM_OIL_BATCH_EVENT',p_daytime,'='),'N') <> 'Y' THEN
                lv_Load :=nvl(EC_STRM_EVENT.math_net_mass(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_BOG_IMPORT'),'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
            END IF;*/
        WHEN 'SW_GP_LNG_PURGE' THEN
            --Item 127686: This stream should be set to UE as it will be inserted into LACT Ticket screen and not seen in any of the Stream_day_stream class
            lv_load := NVL (ec_strm_event.math_net_mass(p_object_id, 'STRM_OIL_BATCH_EVENT', p_daytime, (p_daytime + 1 - 1 / 24 / 60 / 60)), 0);
        --Item 127686: ISWR02347: If purging happened that is to be accounted in SW_GP_BOG_INERT_IMPORT, since Purge Ind is redundant now, using Purge Volume to determine it.
        WHEN  'SW_GP_BOG_INERT_IMPORT' THEN
            --check from DV_STRM_OIL_BATCH_EVENT-->SG_BOG_IMPORT->PURGE_IND. If it is 'Y', then it is considered as "INERT"
            lv_Load := 0;
			--IF NVL(EC_STRM_EVENT.TEXT_10(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_BOG_IMPORT'),'STRM_OIL_BATCH_EVENT',p_daytime,'='),'N') = 'Y' THEN
            IF EC_STRM_EVENT.NET_VOL(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_LNG_PURGE'),'STRM_OIL_BATCH_EVENT',p_daytime,'>=') > 0 THEN
            lv_Load :=nvl(EC_STRM_EVENT.math_net_mass(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_BOG_IMPORT'),'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
            END IF;
		ELSE
			if (ec_strm_day_stream.text_4(p_object_id,p_daytime) = 'Y') then
			--The 'Fall back calc' has been selected, so we need to use the relevent fall back calculation. ec_strm_version.ref_object_id_5 Maps to the fallback calc forthe passed in object_id
				ln_net_mass :=  ecbp_stream_fluid.findNetStdMass(ec_strm_version.ref_object_id_5(p_object_id,p_daytime,'<='), p_daytime);

			else
			--We are not using the fall back calc so fine the watermass as pr normal,  and subtract water mass from the grss mass.
				ln_grs_mass := ecbp_stream_fluid.findGrsStdMass(p_object_id,p_daytime);

				ln_wat_mass := ecbp_stream_fluid.findwatmass(p_object_id,p_daytime);

				ln_net_mass := ln_grs_mass - ln_wat_mass;

			end if;

			--Final check if the net_mass has from the above calcs has returned null then we use the grss mass
			lv_Load := nvl(ln_net_mass, ln_grs_mass);
		END CASE;


 RETURN lv_Load;
END getNetStdMass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNetStdVol
-- Description    : Returns NetStdVol value
---------------------------------------------------------------------------------------------------
FUNCTION getNetStdVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
lv_not_lifted_today NUMBER;
lv_not_lifted_prev NUMBER;
lv_not_lifted NUMBER;
lv_Cargo NUMBER;
lv_Load NUMBER;
lv_CARGO_NO VARCHAR(30);

CURSOR C_CARGO(cp_Code VARCHAR2) IS
  SELECT OBJECT_ID,CARGO_NO
  FROM DV_STOR_DAY_EXPORT_STATUS
  WHERE daytime BETWEEN (p_daytime-1) AND (p_daytime)
  AND OBJECT_CODE = cp_Code
  GROUP BY OBJECT_ID,CARGO_NO
  ORDER BY CARGO_NO ;

BEGIN
--Start Edit: tlxt
--The data class for Day end Not lifted is "DV_STOR_DAY_EXPORT_STATUS"
--FOR LNG/COND Related streams
    CASE ECDP_OBJECTS.GetObjCode(p_object_id)
        WHEN  'SW_GP_LNG_NOT_LIFTED' THEN
            --IF it is 'SG_LNG_NOT_LIFTED', then it means we need to get the value from the Day End Not Lifted BF in Marine
            FOR curCARGO IN C_CARGO('STW_LNG') LOOP
                SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime)
                INTO lv_not_lifted_today
                FROM DUAL;

                IF NVL(lv_not_lifted_today,0) <> 0 THEN
                    lv_not_lifted := lv_not_lifted_today;
                ELSE
                    lv_not_lifted := 0;
                END IF;
                lv_Load := nvl(lv_Load,0) + lv_not_lifted;
            END LOOP;
        WHEN  'SW_GP_LNG_LOAD' THEN
            --this is the Lifted value.
            --Formula: CargoEventCalc + decode(today's DENL, 0,prev's DENL,today's DENL)
            FOR curCARGO IN C_CARGO('STW_LNG') LOOP
                        SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime)
                        INTO lv_not_lifted_today
                        FROM DUAL;

                        SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime-1)
                        INTO lv_not_lifted_prev
                        FROM DUAL;

                        IF NVL(lv_not_lifted_today,0) <> 0 THEN

                            lv_not_lifted := lv_not_lifted_today;
                        END IF;
                        IF NVL(lv_not_lifted_prev,0) <> 0 THEN
                            lv_not_lifted := lv_not_lifted_prev * -1 + nvl(lv_not_lifted, 0);
                        END IF;
                        lv_Load := nvl(lv_Load,0) + nvl(lv_not_lifted, 0);

            END LOOP;
            --lv_Load := nvl(lv_Load,0) + nvl(EC_STRM_EVENT.math_net_vol(ECDP_OBJECTS.GetObjIDFromCode('STREAM','SG_LNG_CARGO'),'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
			lv_Load := NVL(lv_Load, 0) + EcBp_Stream_Fluid.findNetStdVol(ec_stream.object_id_by_uk('SW_GP_LNG_CARGO'), p_daytime);
        WHEN  'SW_GP_LNG_CARGO' THEN
            --This stream should be set to UE as it will be inserted into LACT Ticket screen and not seen in any of the Stream_day_stream class
            lv_Load:=nvl(EC_STRM_EVENT.math_net_vol(p_object_id,'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
        WHEN  'SW_GP_COND_NOT_LIFTED' THEN
            --IF it is 'SG_COND_NOT_LIFTED', then it means we need to get the value from the Day End Not Lifted BF in Marine
            FOR curCARGO IN C_CARGO('STW_COND') LOOP
                SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime)
                INTO lv_not_lifted_today
                FROM DUAL;

                IF NVL(lv_not_lifted_today,0) <> 0 THEN
                    lv_not_lifted := lv_not_lifted_today;
                ELSE
                    lv_not_lifted := 0;
                END IF;
                lv_Load := nvl(lv_Load,0) + lv_not_lifted;
            END LOOP;
        WHEN  'SW_GP_COND_LOAD' THEN
            --this is the Lifted value.
            --Formula: CargoEventCalc + decode(today's DENL, 0,prev's DENL,today's DENL)
            FOR curCARGO IN C_CARGO('STW_COND') LOOP
                        SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime)
                        INTO lv_not_lifted_today
                        FROM DUAL;

                        SELECT EC_STOR_PERIOD_EXPORT_STATUS.EXPORT_QTY(curCARGO.OBJECT_ID,curCARGO.CARGO_NO,p_daytime-1)
                        INTO lv_not_lifted_prev
                        FROM DUAL;

                        IF NVL(lv_not_lifted_today,0) <> 0 THEN

                            lv_not_lifted := lv_not_lifted_today;
                        END IF;
                        IF NVL(lv_not_lifted_prev,0) <> 0 THEN
                            lv_not_lifted := lv_not_lifted_prev * -1 + nvl(lv_not_lifted, 0);
                        END IF;
                        lv_Load := nvl(lv_Load,0) + nvl(lv_not_lifted, 0);
            END LOOP;
            lv_Load := nvl(lv_Load,0) + nvl(EC_STRM_EVENT.math_net_vol(ECDP_OBJECTS.GetObjIDFromCode('STREAM','SW_GP_COND_CARGO'),'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
        WHEN  'SW_GP_COND_CARGO' THEN
            --This stream should be set to UE as it will be inserted into LACT Ticket screen and not seen in any of the Stream_day_stream class
            lv_Load:=nvl(EC_STRM_EVENT.math_net_vol(p_object_id,'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
        WHEN  'SW_GP_BOG_IMPORT' THEN
            --This stream should be set to UE as it will be inserted into LACT Ticket screen and not seen in any of the Stream_day_stream class
            lv_Load:=nvl(EC_STRM_EVENT.math_net_vol(p_object_id,'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
        WHEN 'SW_GP_LNG_PURGE' THEN
            --Item 127686: This stream should be set to UE as it will be inserted into LACT Ticket screen and not seen in any of the Stream_day_stream class
            lv_load := NVL (ec_strm_event.math_net_vol(p_object_id, 'STRM_OIL_BATCH_EVENT', p_daytime, (p_daytime + 1 - 1 / 24 / 60 / 60)), 0);
        --Calculating BOG for C1 and INERT
        --Item 127686: ISWR02347: Commenting below two streams as we are not using them anymore:SW_GP_BOG_C1_IMPORT/SW_GP_BOG_C1_IMP_BAL
      /*WHEN  'SW_GP_BOG_C1_IMPORT' THEN
            --check from DV_STRM_OIL_BATCH_EVENT-->SG_BOG_IMPORT->PURGE_IND. If it is NOT 'Y', then it is considered as "C1"
            lv_Load := 0;
			IF NVL(EC_STRM_EVENT.TEXT_10(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_BOG_IMPORT'),'STRM_OIL_BATCH_EVENT',p_daytime,'='),'N') <> 'Y' THEN
                lv_Load :=nvl(EC_STRM_EVENT.math_net_vol(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_BOG_IMPORT'),'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
            END IF;
        WHEN  'SW_GP_BOG_C1_IMP_BAL' THEN
            --check from DV_STRM_OIL_BATCH_EVENT-->SG_BOG_IMPORT->PURGE_IND. If it is NOT 'Y', then it is considered as "C1"
            lv_Load := 0;
			IF NVL(EC_STRM_EVENT.TEXT_10(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_BOG_IMPORT'),'STRM_OIL_BATCH_EVENT',p_daytime,'='),'N') <> 'Y' THEN
                lv_Load :=nvl(EC_STRM_EVENT.math_net_vol(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_BOG_IMPORT'),'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0)-nvl(ecbp_stream_fluid.findGrsStdVol(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_BOG_C1_IMP_FLR'),p_daytime),0);
            END IF;*/
        --Item 127686: ISWR02347: If purging happened that is to be accounted in SW_GP_BOG_INERT_IMPORT, since Purge Ind is redundant now,
        WHEN  'SW_GP_BOG_INERT_IMPORT' THEN
            --check from DV_STRM_OIL_BATCH_EVENT-->SG_BOG_IMPORT->PURGE_IND. If it is 'Y', then it is considered as "INERT"
            lv_Load := 0;
			--IF NVL(EC_STRM_EVENT.TEXT_10(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_BOG_IMPORT'),'STRM_OIL_BATCH_EVENT',p_daytime,'='),'N') = 'Y' THEN
            IF EC_STRM_EVENT.NET_VOL(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_LNG_PURGE'),'STRM_OIL_BATCH_EVENT',p_daytime,'>=') > 0 THEN
               lv_Load :=nvl(EC_STRM_EVENT.math_net_vol(ECDP_OBJECTS.GETOBJIDFROMCODE('STREAM','SW_GP_BOG_IMPORT'),'STRM_OIL_BATCH_EVENT',p_daytime,(p_daytime+1-1/24/60/60)),0);
            END IF;

		ELSE
			lv_Load:= 0;
		END CASE;


RETURN lv_Load;
--end edit
END getNetStdVol;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getWatVol
-- Description    : Returns getWatVol value
---------------------------------------------------------------------------------------------------
FUNCTION getWatVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWatVol;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getCondVol
-- Description    : Returns getCondVol value
---------------------------------------------------------------------------------------------------
FUNCTION getCondVol(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getCondVol;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getEnergy
-- Description    : Returns getEnergy value
---------------------------------------------------------------------------------------------------
FUNCTION getEnergy(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getEnergy;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getStdDens
-- Description    : Returns getStdDens value
---------------------------------------------------------------------------------------------------
FUNCTION getStdDens(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
ln_return_val    NUMBER;
lv2_phase    VARCHAR2(32);
code         VARCHAR2(32);
lr_analysis_sample object_fluid_analysis%ROWTYPE;
ln_cond_storage_net_mass    NUMBER;
ln_cond_storage_net_vol    NUMBER;
lv2_cond_storage_id         VARCHAR2(32) := ECDP_OBJECTS.GetObjIDFromCode('STORAGE','STW_COND');

-- Item_126915: Begin
lv_delta_mass	NUMBER;
lv_load_mass 	NUMBER;
lv_delta_vol	NUMBER;
lv_load_vol		NUMBER;
lv_from_uom		VARCHAR2(32);
-- Item_126915: End

BEGIN
  lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');
  code      := EcDp_Objects.GetObjCode(p_object_id);


    IF lv2_phase = 'GAS' THEN

		ln_return_val := ec_strm_reference_value.gas_density(p_object_id, p_daytime, '<=');

    END IF;

    IF lv2_phase = 'COND' THEN


		ln_return_val := ec_strm_reference_value.con_density(p_object_id, p_daytime, '<=') / 1000;
		--lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(p_object_id, 'STRM_OIL_COMP', null, p_daytime, 'COND');
        --ln_return_val := lr_analysis_sample.density/1000;

		IF ECDP_OBJECTS.GETOBJCODE(p_object_id) = 'SWR_GP_COND_STORE' THEN

			ln_cond_storage_net_mass := EcBp_Storage_Measurement.getStorageDayClosingNetMass(lv2_cond_storage_id,p_daytime);
			ln_cond_storage_net_vol := EcBp_Storage_Measurement.getStorageDayClosingNetVol(lv2_cond_storage_id,p_daytime);

			IF ln_cond_storage_net_vol IS NOT NULL AND ln_cond_storage_net_vol <> 0 THEN

				ln_return_val := (ln_cond_storage_net_mass * 1000) / ln_cond_storage_net_vol;

			ELSE

				ln_return_val := NULL;

			END IF;

		END IF;

		-- Item_126915: Begin
		-- ISWR02262:R22 Daily reporting Discrepencies
		-- calculate density for SWR_GP_COND_PROD (Mass/Volume of SW_GP_COND_STORE_DELTA and SW_GP_COND_LOAD)
		IF ECDP_OBJECTS.GETOBJCODE(p_object_id) = 'SWR_GP_COND_PROD' THEN
			lv_delta_mass	:= 0;
			lv_load_mass 	:= 0;
			lv_delta_vol	:= 0;
			lv_load_vol	:= 0;
			lv_delta_mass := ROUND(NVL(EcBp_Stream_Fluid.findNetStdMass(ec_stream.object_id_by_uk('SW_GP_COND_STORE_DELTA'), p_daytime), 0),2);
			lv_load_mass := ROUND(NVL(EcBp_Stream_Fluid.findNetStdMass(ec_stream.object_id_by_uk('SW_GP_COND_LOAD'), p_daytime), 0),2);
			lv_delta_vol := ROUND(NVL(EcBp_Stream_Fluid.findNetStdVol(ec_stream.object_id_by_uk('SW_GP_COND_STORE_DELTA'), p_daytime), 0),2);
			lv_load_vol := ROUND(NVL(EcBp_Stream_Fluid.findNetStdVol(ec_stream.object_id_by_uk('SW_GP_COND_LOAD'), p_daytime), 0),2);

			IF lv_delta_vol + lv_load_vol = 0 THEN
				ln_return_val := 0;
			ELSE
				SELECT PROPERTY_VALUE INTO lv_from_uom FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME = 'STRM_DAY_STREAM_DER_OIL' AND ATTRIBUTE_NAME = 'NET_MASS' AND PROPERTY_CODE='UOM_CODE';
				ln_return_val := ROUND(ECDP_UNIT.CONVERTVALUE((lv_delta_mass + lv_load_mass) / (lv_delta_vol + lv_load_vol), ECDP_UNIT.GETUNITFROMLOGICAL(lv_from_uom), 'KG'),3);

			END IF;
		END IF;
		-- Item_126915: End
	END IF;

    IF lv2_phase = 'WAT' THEN

		ln_return_val := ec_strm_reference_value.wat_density(p_object_id, p_daytime, '<=') / 1000;

	END IF;

	-- Get density for LNG rundown
	  IF lv2_phase = 'LNG' THEN

		 lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(ec_stream.object_id_by_uk('SW_GP_LNG_CARGO'), 'STRM_LNG_COMP', null, p_daytime, 'LNG');

		 ln_return_val := lr_analysis_sample.density;

	  END IF;



   RETURN ln_return_val;
END getStdDens;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getWatMass
-- Description    : Returns getWatMass value
---------------------------------------------------------------------------------------------------
FUNCTION getWatMass(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
	ln_grs_mass NUMBER;
	ln_bsw_wt NUMBER;
	ln_return_val NUMBER;

BEGIN

	ln_grs_mass := ecbp_stream_fluid.findGrsStdMass(p_object_id,p_daytime);

	ln_bsw_wt := ecbp_stream_fluid.getBswWeightFrac(p_object_id,p_daytime);

	ln_return_val := ln_grs_mass * ln_bsw_wt;


   RETURN ln_return_val;
END getWatMass;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getGrsDens
-- Description    : Returns getGrsDens value
---------------------------------------------------------------------------------------------------
FUNCTION getGrsDens(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_return_val    NUMBER;
	lv2_phase    VARCHAR2(32);
	lv2_ref_stream VARCHAR2(32);
	code         VARCHAR2(32);
BEGIN
	lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');
	code      := EcDp_Objects.GetObjCode(p_object_id);












	IF lv2_phase = 'WAT' THEN



		lv2_ref_stream := EcBp_Stream.findRefAnalysisStream(p_object_id, p_daytime);

		ln_return_val := ec_strm_reference_value.value_30(nvl(lv2_ref_stream,p_object_id), p_daytime, '<=') / 1000;

	END IF;












	RETURN ln_return_val;
END getGrsDens;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getVCF
-- Description    : Returns VCF value
---------------------------------------------------------------------------------------------------
FUNCTION getVCF(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getVCF;

--<EC-DOC>


---------------------------------------------------------------------------------------------------
-- Function       : getPowerConsumption
-- Description    : Returns PowerConsumption value
---------------------------------------------------------------------------------------------------
FUNCTION getPowerConsumption(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getPowerConsumption;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getSaltWT
-- Description    : Returns SaltWeightFrac value
---------------------------------------------------------------------------------------------------
FUNCTION getSaltWT(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getSaltWT;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : findOnStreamHours
-- Description    : Returns On Stream Hours
---------------------------------------------------------------------------------------------------
FUNCTION findOnStreamHours(
      p_object_id   stream.object_id%TYPE,
  	  p_daytime     DATE,
      p_today       DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findOnStreamHours;

end Ue_Stream_Fluid;
/