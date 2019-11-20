create or replace PACKAGE BODY              UE_CT_STREAM_FLUID is
/****************************************************************
** Package        :  UE_CT_STREAM_FLUID, body part
**
** Purpose        :  This package is used to suplement ECBP_STREAM_FLUID for stream fc density calculation.
**
** Modification history:
**
** Date        Whom     Change description:
** ---------   -------- --------------------------------------
** 08.02.2016  LBFK      Package Created
** 08.10.2016  CVMK      Added functions evaluateFormula(),getStreamFormulaStream()
** 29.03.2018  TLXT      Item_126915: Daily reporting Discrepencies
** 15.06.2018  KAJY      ISWR02542: Item_127929 SWR_GP_COND_PROD density60 logic update
** 16.07.2018  GEDV      ISWR02624: Item_128769 Update the logic to calculate density at 60F.
** 21.08.2018  GEDV      ISWR02624: Item_128769 Added NVL to accomodate the chnages to the delta stream
** 02.11.2018  KAJY      131368:ISWR02794: Logic to handle first day of tank storage
*****************************************************************/

---------------------------------------------------------------------------------------------------
-- Function       : DensityFC
-- Description    : Returns Mass Density at flow conditions (FC)
---------------------------------------------------------------------------------------------------
FUNCTION DensityFC(p_object_id stream.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 lv2_stream_type VARCHAR2(32);
 lv2_stream_phase VARCHAR2(32);

 ln_ret_val NUMBER;

BEGIN
    lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    lv2_stream_type := EC_STRM_VERSION.STREAM_TYPE(p_object_id, p_daytime, '<=');
    lv2_stream_phase := EC_STRM_VERSION.STREAM_PHASE(p_object_id, p_daytime, '<=');

    IF lv2_stream_phase = 'COND' THEN

        IF lv2_stream_type = 'M'THEN
            ln_ret_val := ec_strm_day_stream.value_1(p_object_id, p_daytime);
        ELSIF lv2_stream_type = 'D' AND (lv2_stream_code = 'SW_PL_WA356P_MSEP_COND' OR lv2_stream_code = 'SW_PL_WST_MSEP_COND') THEN
            ln_ret_val := ec_strm_day_stream.value_1(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T0_MSEP_COND'), p_daytime);
        END IF;

    END IF;

    IF lv2_stream_phase = 'WAT' THEN

        ln_ret_val := EcBp_Stream_Fluid.findGrsDens(p_object_id,p_daytime);

    END IF;

    return ln_ret_val;

END DensityFC;


FUNCTION Density60F(p_object_id stream.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
IS

 lv2_stream_phase VARCHAR2(32) := EC_STRM_VERSION.STREAM_PHASE(p_object_id, p_daytime, '<=');
  ln_density15C NUMBER;
 ln_ret_density60F NUMBER := NULL;
 ln_vcf NUMBER;

-- ISWR02542: Item_127929 Begin
  lv_delta_mass    NUMBER;
lv_load_mass     NUMBER;
lv_delta_vol60    NUMBER;
lv_load_vol60        NUMBER;
lv_from_uom        VARCHAR2(32);
ln_density60C   NUMBER;
-- ISWR02542: Item_127929 End

-- ISWR02624: Item_128769 Variable declaration starts
lv_Density60F1 NUMBER;
lv_Density60F2 NUMBER;
lv_delta_mass1 NUMBER;
lv_delta_mass2 NUMBER;
-- ISWR02624: Item_128769 Declaration ends.

BEGIN

    IF lv2_stream_phase = 'COND' THEN

        ln_density15C := EcBp_Stream_Fluid.findStdDens(p_object_id,p_daytime);
        -- Item_126915: Begin
        -- ISWR02262:R22 Daily reporting Discrepencies
        IF NVL(ln_density15C,0) <> 0 THEN
            ln_vcf := ecbp_vcf.calcVCFstdDensity_SI(ln_density15C, 15, 15.556);
            IF ln_vcf IS NOT NULL AND ln_vcf <> 0 THEN
                ln_ret_density60F := ln_density15C / ln_vcf;
            END IF;
        END IF;
--        IF ECDP_OBJECTS.GETOBJCODE(p_object_id) = 'SWR_GP_COND_PROD' AND NVL(ln_density15C,0) = 0 THEN
--            ln_ret_density60F := 0;
--        END IF;
        -- Item_126915: End

      -- ISWR02542: Item_127929 Begin
        IF ECDP_OBJECTS.GETOBJCODE(p_object_id) = 'SWR_GP_COND_PROD' THEN

            lv_delta_mass    := 0;
            lv_load_mass     := 0;
            lv_delta_vol60    := 0;
            lv_load_vol60    := 0;
            lv_delta_mass := ROUND(NVL(EcBp_Stream_Fluid.findNetStdMass(ec_stream.object_id_by_uk('SW_GP_COND_STORE_DELTA'), p_daytime), 0),2);
            lv_load_mass := ROUND(NVL(EcBp_Stream_Fluid.findNetStdMass(ec_stream.object_id_by_uk('SW_GP_COND_LOAD'), p_daytime), 0),2);
         -- ISWR02624: Item_128769 Starts: Update to the logic for Cond Prod stream
            If nvl(EcBp_Stream_Fluid.findNetStdVol(ec_stream.object_id_by_uk('SW_GP_COND_STORE_DELTA'),p_daytime),0)<>0 then
                ln_density15C := EcBp_Stream_Fluid.findNetStdMass(ec_stream.object_id_by_uk('SW_GP_COND_STORE_DELTA'),p_daytime)*1000/EcBp_Stream_Fluid.findNetStdVol(ec_stream.object_id_by_uk('SW_GP_COND_STORE_DELTA'),p_daytime);
            else
                ln_density15C := EcBp_Stream_Fluid.findStdDens(ec_stream.object_id_by_uk('SW_GP_COND_STORE_DELTA'),p_daytime);
            end if ;
         -- ISWR02624: Item_128769 Ends.
            IF NVL(ln_density15C,0) <> 0 THEN
                 --ISWR02624: Item_128769 Starts:
                   ln_density60C := Density60F(ec_stream.object_id_by_uk('SW_GP_COND_STORE_DELTA'), p_daytime);
                 -- ISWR02624: Item_128769 End
            lv_delta_vol60 := ROUND((lv_delta_mass/ln_density60C*1000),2);
            END IF;

            ln_density15C := EcBp_Stream_Fluid.findStdDens(ec_stream.object_id_by_uk('SW_GP_COND_LOAD'),p_daytime);
            IF NVL(ln_density15C,0) <> 0 THEN
            ln_density60C := Density60F(ec_stream.object_id_by_uk('SW_GP_COND_LOAD'), p_daytime);
            lv_load_vol60 := ROUND((lv_load_mass/ln_density60C*1000),2);
            END IF;


            IF lv_delta_vol60 + lv_load_vol60 = 0 THEN
                ln_ret_density60F := 0;
            ELSE
                SELECT PROPERTY_VALUE INTO lv_from_uom FROM CLASS_ATTR_PROPERTY_CNFG WHERE CLASS_NAME = 'STRM_DAY_STREAM_DER_OIL' AND ATTRIBUTE_NAME = 'NET_MASS' AND PROPERTY_CODE='UOM_CODE';
				-- ISWR02624: Item_128769 Starts: Added NVL to accomodate the chnages to the delta stream
                --ln_ret_density60F := ROUND(ECDP_UNIT.CONVERTVALUE((lv_delta_mass + lv_load_mass) / (lv_delta_vol60 + lv_load_vol60), ECDP_UNIT.GETUNITFROMLOGICAL(lv_from_uom), 'KG'),3);
				ln_ret_density60F := NVL(ROUND(ECDP_UNIT.CONVERTVALUE((lv_delta_mass + lv_load_mass) / (lv_delta_vol60 + lv_load_vol60), ECDP_UNIT.GETUNITFROMLOGICAL(lv_from_uom), 'KG'),3),0);
				-- ISWR02624: Item_128769 Ends
            END IF;

        END IF;
      -- ISWR02542: Item_127929 End

-- ISWR02624: Item_128769 Starts. Added new logic to calculate density at 60 for Cond delta stream.
        IF ECDP_OBJECTS.GETOBJCODE(p_object_id) = 'SW_GP_COND_STORE_DELTA' THEN
            lv_delta_mass1 := NVL(EcBp_Stream_Fluid.findNetStdMass(ec_stream.object_id_by_uk('SWR_GP_COND_STORE'), p_daytime-1), 0);
            lv_delta_mass2 := NVL(EcBp_Stream_Fluid.findNetStdMass(ec_stream.object_id_by_uk('SWR_GP_COND_STORE'), p_daytime), 0);
            lv_Density60F1 := UE_CT_STREAM_FLUID.Density60F(ec_stream.object_id_by_uk('SWR_GP_COND_STORE'),p_daytime-1);
            lv_Density60F2 := UE_CT_STREAM_FLUID.Density60F(ec_stream.object_id_by_uk('SWR_GP_COND_STORE'),p_daytime);

--Item 131368: ISWR02794: Logic to handle first day of tank storage  
          IF NVL(lv_delta_mass1,0)=0 and lv_Density60F2<>0 THEN
               ln_ret_density60F:=lv_delta_mass2/(lv_delta_mass2/lv_Density60F2);				
			   
-- Item 131368: ISWR02794: Ends
           ELSIF lv_Density60F1 <>0 and lv_Density60F2<>0 THEN
                IF (lv_delta_mass1/lv_Density60F1)<>(lv_delta_mass2/lv_Density60F2) THEN
                    ln_ret_density60F:=(lv_delta_mass2-lv_delta_mass1)/((lv_delta_mass2/lv_Density60F2)-(lv_delta_mass1/lv_Density60F1));
                ELSE
                    ln_ret_density60F:= NULL;
                END IF;
            ELSE
                ln_ret_density60F:= NULL;
            END IF;

        END IF;
-- ISWR02624: Item_128769 Ends.

    END IF;

    return ln_ret_density60F;

END Density60F;

FUNCTION NetVol15C(p_object_id stream.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
IS

 lv2_stream_phase VARCHAR2(32) := EC_STRM_VERSION.STREAM_PHASE(p_object_id, p_daytime, '<=');
 ln_net_mass NUMBER;
 ln_ret_theo_net_vol_15C NUMBER := NULL;

BEGIN

    IF lv2_stream_phase = 'LNG' THEN

        ln_net_mass := EcBp_Stream_Fluid.findNetStdMass(p_object_id,p_daytime);

        IF ln_net_mass IS NOT NULL THEN

            ln_ret_theo_net_vol_15C := UE_CT_REPORT_CALCS.CalcVolFromLNGMass(p_object_id, p_daytime, ln_net_mass,NULL,'N');

        END IF;


    END IF;

    return ln_ret_theo_net_vol_15C;

END NetVol15C;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : evaluateFormula
-- Description  : Build an expression from a stream formula.
--
-- Preconditions:  .
-- Postcondition:
--
-- Using Tables:
--
-- Using functions:
--
-- Configuration
-- required:         Configuration in STRM_FORMULA and STRM_FORMULA_VARIABLE tables.
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION evaluateFormula(
   p_formula_id     VARCHAR2,
   p_formula        VARCHAR2,
   p_daytime          DATE,
   p_stream_id    VARCHAR2 DEFAULT NULL
)

RETURN VARCHAR2
--</EC-DOC>
IS

li_len INTEGER;
li_pos INTEGER;
li_num INTEGER;
lv2_char VARCHAR2(1);
lv2_nvl_char VARCHAR2(4);
lv2_zero_char VARCHAR2(5);
lv2_null_char VARCHAR2(5);
lv2_formula VARCHAR2(10000);

BEGIN

    li_len := LENGTH(p_formula);
    li_pos := 1;
    li_num := 0;

    IF li_len > 0 THEN

      -- Replace all characters in A..Z with evaluation expression.
          -- If encounter NVL( then the formula will be interpreted as the NVL(*,*) function

        LOOP

                lv2_char := UPPER(SUBSTR(p_formula, li_pos, 1 ));
                lv2_nvl_char := UPPER(SUBSTR( p_formula, li_pos, 3 ));
                lv2_zero_char := UPPER(SUBSTR( p_formula, li_pos, 4 ));
                lv2_null_char := UPPER(SUBSTR( p_formula, li_pos, 4 ));

                  IF lv2_char >= 'A' AND lv2_char <= 'Z' THEN

                       IF lv2_nvl_char = 'NVL' THEN
                            lv2_formula := lv2_formula || '';
                            li_pos := li_pos + 3;
                       ELSIF lv2_zero_char = 'ZERO' THEN
                            --Zero(a,b) is a function in this package
                            lv2_formula := lv2_formula || 'ECDP_STREAM_FORMULA.ZERO';
                            li_pos := li_pos + 4;
                       ELSIF lv2_null_char = 'NULL' THEN
                            lv2_formula := lv2_formula || 'NULL';
                            li_pos := li_pos + 4;
                       ELSE
                            lv2_formula := lv2_formula || ecdp_objects.getObjCode(ec_strm_formula_variable.object_id(p_formula_id, lv2_char));
                            li_pos := li_pos + 1;
                       END IF;

                ELSIF (lv2_char >= '0' AND lv2_char <= '9') OR (lv2_char IN ('(', ')', ',')) THEN

                    lv2_formula := lv2_formula || '';
                    li_pos := li_pos + 1;

               ELSE
                    lv2_formula := lv2_formula || lv2_char;
                       li_pos := li_pos + 1;
                    li_num := 0;

                END IF;

                EXIT WHEN li_pos > li_len;

            END LOOP;

    END IF;

-- Return expression
  RETURN lv2_formula;

EXCEPTION

   WHEN OTHERS THEN
      RETURN NULL;

-- End function
END evaluateFormula;

/*-------------------------------------------------------------------------------------------------
--<EC-DOC>
---------------------------------------------------------------------------------------------------
--
-- FUNCTION: getStreamFormulaStream
--
-- PURPOSE:  Get stream(s) associated with formula stream
--
-- PARAMETERS:
--       p_object_id  (object_id)
--       p_daytime     (daytime)
--       p_method      (attribute used - e.g. NET_MASS_METHOD, ENERGY_METHOD, NET_VOL_METHOD)
--
-- RETURNS: VARCHAR2
--
-------------------------------------------------------------------------------------------------*/
FUNCTION getStreamFormulaStream(p_object_id VARCHAR2, p_daytime DATE, p_method VARCHAR2)
RETURN VARCHAR2
IS

lv_formula VARCHAR2(2500);
ln_formula_no NUMBER;
lv_formula_variable VARCHAR2(4000);
lv_ret_val VARCHAR2(4000);
lv_prev_strm_formula strm_formula%ROWTYPE;

BEGIN

    lv_prev_strm_formula := ecdp_stream_formula.getPreviousFormula(p_object_id, p_method, p_daytime);

    --Creates a list of objects used in a stream formula:
    SELECT sf.formula_no,
    evaluateFormula(sf.formula_no, sf.formula, p_daytime)
    INTO ln_formula_no, lv_formula
    FROM STRM_FORMULA sf, STRM_FORMULA_VARIABLE sfv
    WHERE sf.formula_no = lv_prev_strm_formula.formula_no
    AND sf.formula_no = sfv.formula_no
    AND sf.object_id = p_object_id
    AND sf.formula_method = p_method
    GROUP BY sf.formula_no, sf.formula;

    lv_ret_val := lv_formula;

--Return stream
RETURN lv_ret_val;

  -- End function
END getStreamFormulaStream;

end UE_CT_STREAM_FLUID;
/
