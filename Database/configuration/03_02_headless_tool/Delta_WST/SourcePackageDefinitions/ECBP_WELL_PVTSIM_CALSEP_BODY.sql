CREATE OR REPLACE PACKAGE BODY ECBP_WELL_PVTSIM_CALSEP IS
/****************************************************************
** Package        :  ECBP_WELL_PVTSIM_CALSEP,  body part
**
** This package is used to program theoretical calculation when a predefined method supplied by EC does not cover the requirements.
** Upgrade processes will never replace this package.
** Date        Whom      Change description:
** --------    ------    -----------------------------------
** 08.03.2011  musaamah  ECPD-15331: Modified cursor in function CalcFluidQualityMix to access quality stream from RBF_VERSION (version table) instead of RESV_BLOCK_FORMATION (main table).
**                                   This is due to the column STREAM_ID which has been moved from RESV_BLOCK_FORMATION to RBF_VERSION.
** 30.07.2012  leongsei  ECPD-10325: Replaced dbms_output by EcDp_DynSql.WriteDebugText
** 13.05.2014  deshpadi  ECPD-26763: Modified cursor in function CalcFluidQualityMix to access RESB_BLOCK_FORMATION_ID, that has been moved to PERF_INTERVAL_VERSION table from PERF_INTERVAL table.
** 08.08.2016  kolleadr	 ECPD-35944: Add function called XML_TAGVALUES, this function will be used by the STRM_REFERENCE_VALUE attribute FLUID_XML_INFO to display key information from the Calsep fluid xml.
**
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :
-- Description    :
---------------------------------------------------------------------------------------------------

FUNCTION CalcFluidQualityMix(p_result_no NUMBER)
RETURN qstrm_pmass_arr PIPELINED
IS

-- Cursor for listing all fluid quality candidates under all wells that are active flowing participants in a specific test result.
-- If configured, the well_version.fluid_quality stream will override the entire well-reservoir model for that well.
CURSOR c_rbfconnect(cp_result_no VARCHAR2, cp_daytime DATE) IS
SELECT DISTINCT
ec_rbf_version.stream_id(rbfv.object_id,rbfv.daytime) AS QSTRM_ID,
rbf.object_id AS RBF_ID,
w.object_id AS WELL_ID,
'RBF' AS SOURCE
FROM well w, webo_bore wb ,webo_interval wbi, resv_block_formation rbf, rbf_version rbfv, perf_interval pi, perf_interval_version piv
WHERE wb.well_id = w.object_id
AND wbi.well_bore_id = wb.object_id
AND pi.webo_interval_id = wbi.object_id
AND piv.object_id = pi.object_id
AND rbf.object_id = piv.resv_block_formation_id
--AND rbf.object_id = pi.resv_block_formation_id
AND ec_well_version.fluid_quality(w.object_id , cp_daytime, '<=') is null
AND w.object_id in (SELECT DISTINCT object_id FROM pwel_result WHERE flowing_ind = 'Y' AND result_no = cp_result_no)
UNION
SELECT DISTINCT
ec_well_version.fluid_quality(well.object_id , cp_daytime, '<=') AS QSTRM_ID,
'none' AS RBF_ID,
well.object_id AS WELL_ID,
'WV' AS SOURCE
FROM well
WHERE
ec_well_version.fluid_quality(well.object_id , cp_daytime, '<=') is not null
AND well.object_id in (SELECT DISTINCT object_id FROM pwel_result WHERE flowing_ind = 'Y' AND result_no = cp_result_no)
ORDER BY QSTRM_ID
;


--Associative array for phase volume production and contribution fractions for each well-qstream combination.
TYPE qstrm_pvfrac_rec is record(
        well_id      varchar2(32),
        qstrm_id     varchar2(32),
        est_oil      number,
        est_gas      number,
        est_con      number,
        oil_frac     number,
        gas_frac     number,
        con_frac     number);
TYPE qstrm_pvfrac_arr is table of qstrm_pvfrac_rec index by pls_integer;
qstrm_pvfrac         qstrm_pvfrac_arr;
Qindx1               PLS_INTEGER;


--Pipelined row containing active qstream_id's and their respective hc mass contribution
qstrm_pmass_row      qstrm_pmass_rec := qstrm_pmass_rec(NULL,NULL,NULL);
Qindx2               PLS_INTEGER;


ld_daytime          DATE;
ln_prod_oil         NUMBER;
ln_prod_gas         NUMBER;
ln_prod_con         NUMBER;
ln_oil_dens         NUMBER;
ln_gas_dens         NUMBER;
ln_con_dens         NUMBER;
ln_Qindx1_max       NUMBER;

/*
v_output1           varchar2(255);
v_output2           varchar2(255);
*/

BEGIN

ld_daytime := trunc(ec_ptst_result.daytime(p_result_no),'DD');
Qindx1 := 1;

    FOR connection in c_rbfconnect(p_result_no, ld_daytime) LOOP
        qstrm_pvfrac(Qindx1).qstrm_id := connection.qstrm_id;
        qstrm_pvfrac(Qindx1).well_id  := connection.well_id;
        qstrm_pvfrac(Qindx1).est_oil  := nvl(ecdp_performance_test.getOilStdRateDay(p_result_no, connection.well_id , ld_daytime),100);  --defaulted.  must configure perfcurve
        qstrm_pvfrac(Qindx1).est_gas  := nvl(ecdp_performance_test.getGasStdRateDay(p_result_no, connection.well_id , ld_daytime),100000); --defaulted.  must configure perfcurve
        qstrm_pvfrac(Qindx1).est_con  := nvl(ecdp_performance_test.getCondStdRateDay(p_result_no, connection.well_id , ld_daytime),50); --defaulted.  must configure perfcurve

        IF connection.source = 'WV' THEN   -- piece of cake:   only one fluid quality for this well
          qstrm_pvfrac(Qindx1).oil_frac := 1;
          qstrm_pvfrac(Qindx1).gas_frac := 1;
          qstrm_pvfrac(Qindx1).con_frac := 1;

        ELSE    -- aggregate all split factors for all phases for this specific well - rbf (qstream) connection.
          qstrm_pvfrac(Qindx1).oil_frac := nvl(ecdp_well_reservoir.getWellRBFPhaseFraction(connection.well_id, connection.rbf_id, ld_daytime, 'OP'), 0);
          qstrm_pvfrac(Qindx1).gas_frac := nvl(ecdp_well_reservoir.getWellRBFPhaseFraction(connection.well_id, connection.rbf_id, ld_daytime, 'GP'), 0);
          qstrm_pvfrac(Qindx1).con_frac := nvl(ecdp_well_reservoir.getWellRBFPhaseFraction(connection.well_id, connection.rbf_id, ld_daytime, 'CP'), 0);

        END IF;

/*      v_output1 :=  Qindx1||'    '||connection.source||'    '||qstrm_pvfrac(Qindx1).qstrm_id||'   '||qstrm_pvfrac(Qindx1).well_id||'    '||qstrm_pvfrac(Qindx1).est_oil||'   '||qstrm_pvfrac(Qindx1).est_gas||'   '||qstrm_pvfrac(Qindx1).est_con||'   '||qstrm_pvfrac(Qindx1).oil_frac||'   '||qstrm_pvfrac(Qindx1).gas_frac||'   '||qstrm_pvfrac(Qindx1).con_frac;
        EcDp_DynSql.WriteDebugText('CalcFluidQualityMix', v_output1, 'DEBUG' );
*/
        Qindx1 := Qindx1 + 1;
    END LOOP;

    Qindx1 := 1;
    Qindx2 := 1;
    ln_prod_oil := 0;
    ln_prod_gas := 0;
    ln_prod_con := 0;
    ln_Qindx1_max := qstrm_pvfrac.count;

    LOOP
        EXIT WHEN Qindx1 IS NULL;
          ln_prod_oil := ln_prod_oil + qstrm_pvfrac(Qindx1).est_oil * qstrm_pvfrac(Qindx1).oil_frac;
          ln_prod_gas := ln_prod_gas + qstrm_pvfrac(Qindx1).est_gas * qstrm_pvfrac(Qindx1).gas_frac;
          ln_prod_con := ln_prod_con + qstrm_pvfrac(Qindx1).est_con * qstrm_pvfrac(Qindx1).con_frac;
          ln_oil_dens := nvl(ec_strm_reference_value.density(qstrm_pvfrac(Qindx1).qstrm_id, ld_daytime, '<='),1);  --replace with proper oil_density column (jira)
          ln_gas_dens := nvl(ec_strm_reference_value.density(qstrm_pvfrac(Qindx1).qstrm_id, ld_daytime, '<='),1);  --replace with proper gas_density column (jira)
          ln_con_dens := nvl(ec_strm_reference_value.density(qstrm_pvfrac(Qindx1).qstrm_id, ld_daytime, '<='),1);  --replace with proper con_density column (jira)
          IF (Qindx1 = ln_Qindx1_max) OR (qstrm_pvfrac(Qindx1).qstrm_id != qstrm_pvfrac(Qindx1+1).qstrm_id) THEN

            qstrm_pmass_row.indx := Qindx2;
            qstrm_pmass_row.qstrm_id := qstrm_pvfrac(Qindx1).qstrm_id;
            qstrm_pmass_row.hc_mass := (ln_prod_oil * ln_oil_dens) + (ln_prod_gas * ln_gas_dens) + (ln_prod_con * ln_con_dens);
            ln_prod_oil := 0;
            ln_prod_gas := 0;
            ln_prod_con := 0;
            IF qstrm_pmass_row.hc_mass > 0 THEN
              PIPE ROW (qstrm_pmass_row);
              Qindx2 := Qindx2 + 1;
            END IF;
          END IF;
        Qindx1 := qstrm_pvfrac.next(Qindx1);
      END LOOP;


/*    Qindx2 := 1;
    LOOP
        EXIT WHEN Qindx2 IS NULL;
        lv2_return_value := lv2_return_value||qstrm_pmass(Qindx2).qstrm_id||':'||qstrm_pmass(Qindx2).hc_mass||':';
        Qindx2 := qstrm_pmass.next(Qindx2);
     END LOOP;
*/


/*  Qindx2 := 1;
    LOOP
        EXIT WHEN Qindx2 IS NULL;
        v_output2 :=  Qindx2||'    '||qstrm_pmass(Qindx2).qstrm_id||'   '||qstrm_pmass(Qindx2).hc_mass;
        EcDp_DynSql.WriteDebugText('CalcFluidQualityMix', v_output2, 'DEBUG' );
        Qindx2 := qstrm_pmass.next(Qindx2);
     END LOOP;
*/

RETURN;

END CalcFluidQualityMix;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : xml_tagvalues                                                    			 --
-- Description    : Returns key information from the Calsep fluid xml   						 --
--																								 --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : STRM_REFERENCE_VALUE                                                              				 --
--                                                                                               --
-- Using functions:                                      										 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION xml_tagvalues(p_object_id VARCHAR2,p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

TYPE   varray_varchar IS VARYING ARRAY(20) OF VARCHAR2(32);
var_varray_varchar varray_varchar;
i_xml    		CLOB;
lv2_xml_char 	VARCHAR2(4096);
lv2_TAG  		VARCHAR2(32);
lv2_retval		VARCHAR2(512);
ln_0     		NUMBER;
ln_1     		NUMBER;
ln_2     		NUMBER;

BEGIN
  var_varray_varchar  := varray_varchar('WellText','TestText','FluidText','SampleText','ExtraText','ExtraInfoText','DateTimeText','NComponents');
  SELECT xmlfluid INTO i_xml FROM strm_reference_value WHERE object_id = p_object_id AND daytime = (SELECT max(t.daytime) FROM strm_reference_value t WHERE t.object_id = p_object_id AND t.daytime <= p_daytime);
  lv2_xml_char := to_char(substr(i_xml,1,1024));

  FOR i IN 1 .. var_varray_varchar.count LOOP
    lv2_TAG  := var_varray_varchar(i);
    ln_0 := length(lv2_TAG);
    ln_1 := instr(lv2_xml_char,'<'||lv2_TAG||'>',1,1);
    ln_2 := instr(lv2_xml_char,'</'||lv2_TAG||'>',1,1);
    lv2_retval := lv2_retval||lv2_TAG||': '||substr(lv2_xml_char,ln_1+ln_0+2,ln_2-ln_1-ln_0-2)||chr(13)||chr(10);
  END LOOP;

  RETURN lv2_retval;
END xml_tagvalues;

END ECBP_WELL_PVTSIM_CALSEP;