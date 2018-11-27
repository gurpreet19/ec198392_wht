CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Analysis IS
/****************************************************************
** Package        :  EcDp_Stream_Analysis
**
** $Revision: 1.22 $
**
** Purpose        :  This package is responsible for data access to
**                   stream analysis properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.02.2000  Carl-Fredrik S�sen
**
** Modification history:
**
** Date       Whom  Change description:
** ------     ----- --------------------------------------
** 01.02.00   CFS    First version
** 18.05.00   DN    New function getCargoBswVolFrac
** 15.06.00   PGI   Added function getCondWatFrac
** 16.06.00   PGI   getCargoBswVolFrac: Find correct stock_code in stock from 'from_node' in stream
** 17.07.00   DN    getCargoBswVolFrac: Bug fix from previous change. Must be compatible with other licenses.
** 09.11.00   DN    getCargoBswVolFrac: Get the AUTO-sampling-method analysis preferably. Bug fix ECRS: ML�00118.
** 14.12.2000 FBa   getCargoBswVolFrac: Take analysis from any storage. Previous version failed if more than one storage per facility.
** 05.01.2001 FBa   Added function getCargoDensity
** 22.02.2001 HVe   Added function getDayOilInWater
** 03.04.2001 KEJ   Documented functions and procedures.
** 18.09.2001 DN    Adapted to new cargo model. Requires release 6.5.0.
** 27.05.2004 DN    Adapted to 7.4 analysis model and removed function getCondWatFrac.
** 11.08.2004 mazrina    removed sysnam and update as necessary
** 21.10.2004 DN    Removed getCargo-functions.
** 28.10.2004 Toha  Added GetAgaAnalysis, GetAgaAnalysisItem
** 01.11.2004 Toha  fixed getAgaAnalysis, getAgaAnalysisItem, now using tables instead of views
** 15.02.2005 Ron/Jerome Modified getBswVolFrac and getBswWeightFrac according to Tracker 1227
** 28.02.2005 kaurrnar	Removed deadcodes
**			Removed references to ec_xxx_attribute packages
** 07.03.2005 kaurrnar	Changed from aga_ref_analysis to aga_ref_analysis_id
** 10.05.2005 DN    Function getAGAAnalysis: Modified function call with p_daytime instead of sysdate and simple assignment.
** 25.07.2005 Ron Boh   Added new function getPrevAnalysisDaytime
** 18.08.2005 Toha  TI 2282: Updated getBswVolFrac, getBswWightFrac, getPrevAnalysisDaytime to use analysis reference
** 16.12.2005 Dn    Added getNextAGAAnalysisSample.
** 07.09.2007 idrussab    ECPD-6295: Added getSaltWeightFrac
** 31.12.2008 sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                     getBswVolFrac, getBswWeightFrac, getSaltWeightFrac, getDayOilInWater.
** 27.04.2009 sharawan ECPD-11582: Modify cursor in getCompositeAnalysisStatus and getCompositeAnalysisComment functions to find for �COMPOSITE� sampling_method.
** 24.06-2014 dhavaalo ECPD-27943: Enhancement to Support Aga package. Modified GetAGAAnalysisItem function to Support for COMPRESSIBILITY_FLOW,COMPRESSIBILITY_STD columns added.
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getBswVolFrac
-- Description  : Returns bsw volume fraction for a stream from an analysis
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--                STRM_OIL_ANALYSIS
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour: If the BS_W fraction is null then the function returns the sum of BS and WATER.
--
---------------------------------------------------------------------------------------------------
FUNCTION getBswVolFrac (
   p_object_id stream.object_id%TYPE,
   p_daytime     DATE)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_bsw_cur(cp_object_id VARCHAR2, cp_phase VARCHAR2, cp_daytime DATE) IS
SELECT Max(x.bs_w) max_bsw
FROM   object_fluid_analysis x
WHERE  x.object_id = cp_object_id
AND    x.phase = cp_phase
AND    x.analysis_status = 'APPROVED'
AND    x.valid_from_date = (
	    SELECT Max(y.valid_from_date)
		 FROM  object_fluid_analysis y
		 WHERE y.object_id = x.object_id
		 AND y.phase = x.phase
		 AND y.bs_w IS NOT NULL
  	 AND y.analysis_status = x.analysis_status
     AND y.valid_from_date <= cp_daytime);

ln_return_val NUMBER;
lv2_analysis_ref_id stream.object_id%TYPE;

BEGIN

   lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   FOR mycur IN c_bsw_cur(lv2_analysis_ref_id, EcDp_Phase.OIL, p_daytime) LOOP

      ln_return_val := mycur.max_bsw;

   END LOOP;

   RETURN ln_return_val;

END getBswVolFrac;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getBswWeightFrac
-- Description  : Returns the base sediment and water weight fraction
--                from an analysis of a stream valid for a given day.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--                strm_oil_analysis
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getBswWeightFrac (
   p_object_id stream.object_id%TYPE,
   p_daytime     DATE)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_bsw_wt_cur(cp_object_id VARCHAR2, cp_phase VARCHAR2, cp_daytime DATE) IS
SELECT x.bs_w_wt
FROM   object_fluid_analysis x
WHERE  x.object_id = cp_object_id
AND    x.phase = cp_phase
AND    x.analysis_status = 'APPROVED'
AND    x.valid_from_date = (
	    SELECT Max(y.valid_from_date)
	    FROM   object_fluid_analysis y
	    WHERE  y.object_id = x.object_id
	    AND    y.phase = x.phase
  	  AND    y.analysis_status = x.analysis_status
      AND    y.valid_from_date <= cp_daytime);

ln_return_val NUMBER;
lv2_analysis_ref_id stream.object_id%TYPE;

BEGIN

   lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   FOR mycur IN c_bsw_wt_cur(lv2_analysis_ref_id, EcDp_Phase.OIL, p_daytime) LOOP

      ln_return_val := mycur.bs_w_wt;

   END LOOP;

   RETURN ln_return_val;

END getBswWeightFrac;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getSaltWeightFrac
-- Description  : Returns the base sediment and salt weight fraction
--                from an analysis of a stream valid for a given day.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--                strm_oil_analysis
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getSaltWeightFrac (
   p_object_id stream.object_id%TYPE,
   p_daytime     DATE)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_salt_wt_cur(cp_object_id VARCHAR2, cp_phase VARCHAR2, cp_daytime DATE) IS
SELECT x.salt
FROM   object_fluid_analysis x
WHERE  x.object_id = cp_object_id
AND    x.phase = cp_phase
AND    x.analysis_status = 'APPROVED'
AND    x.valid_from_date = (
	    SELECT Max(y.valid_from_date)
	    FROM   object_fluid_analysis y
	    WHERE  y.object_id = x.object_id
	    AND    y.phase = x.phase
  	  AND    y.analysis_status = x.analysis_status
      AND    y.valid_from_date <= cp_daytime);

ln_return_val NUMBER;
lv2_analysis_ref_id stream.object_id%TYPE;

BEGIN

   lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   FOR mycur IN c_salt_wt_cur(lv2_analysis_ref_id, EcDp_Phase.OIL, p_daytime) LOOP

      ln_return_val := mycur.salt;

   END LOOP;

   RETURN ln_return_val;

END getSaltWeightFrac;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getDayOilInWater
-- Description  : Returns daily Oil_in_water for
--                a stream from an analysis
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions: ec_strm_water_analysis.oil_in_water
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getDayOilInWater (
   p_object_id stream.object_id%TYPE,
   p_daytime     DATE)

RETURN NUMBER
--<EC-DOC>
IS
ln_return_val NUMBER;
BEGIN
	-- The 'AUTO' parameter gives the analysis result relevant for a day.
	ln_return_val := ec_strm_water_analysis.oil_in_water(p_object_id, p_daytime, 'AUTO');
  RETURN ln_return_val;
END getDayOilInWater;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getAGAAnalysis
-- Description  : Return analyis for stream
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getAGAAnalysis(p_object_id stream.object_id%TYPE, p_daytime DATE)
RETURN object_aga_analysis%ROWTYPE
--</EC-DOC>
IS

CURSOR c_aga_analysis(cp_object_id stream.object_id%TYPE, cp_daytime DATE) IS
  SELECT * FROM object_aga_analysis ac
    WHERE ac.ANALYSIS_STATUS='APPROVED'
    AND ac.VALID_FROM_DATE = (SELECT max(valid_from_date) FROM object_aga_analysis x
                                WHERE x.object_id = ac.object_id
                                AND x.valid_from_date <= cp_daytime
                                AND x.analysis_status = 'APPROVED')
    AND ac.OBJECT_ID = cp_object_id;

  ln_analysis_ref varchar2(32);
  lr_aga_analysis object_aga_analysis%ROWTYPE;
  lb_found BOOLEAN;

BEGIN
    lr_aga_analysis := NULL;
    lb_found := FALSE;

    FOR cur_rec IN c_aga_analysis(p_object_id, p_daytime) LOOP
      lr_aga_analysis := cur_rec;
      lb_found := TRUE;
    END LOOP;

    IF NOT lb_found THEN

      ln_analysis_ref := ec_strm_version.aga_ref_analysis_id(p_object_id, p_daytime, '<=');

      FOR cur_rec IN c_aga_analysis(ln_analysis_ref, p_daytime) LOOP
        lr_aga_analysis := cur_rec;
      END LOOP;

    END IF;

    RETURN lr_aga_analysis;

END getAGAAnalysis;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getNextAGAAnalysisSample
-- Description  : Return the next valid AGA-analysis for a stream
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getNextAGAAnalysisSample(p_object_id stream.object_id%TYPE, p_daytime DATE)
RETURN object_aga_analysis%ROWTYPE
--</EC-DOC>
IS

CURSOR c_aga_analysis(cp_object_id stream.object_id%TYPE, cp_daytime DATE) IS
  SELECT * FROM object_aga_analysis ac
    WHERE ac.ANALYSIS_STATUS='APPROVED'
    AND ac.VALID_FROM_DATE = (SELECT MIN(valid_from_date) FROM object_aga_analysis x
                                WHERE x.object_id = ac.object_id
                                AND x.valid_from_date > cp_daytime
                                AND x.analysis_status = 'APPROVED')
    AND ac.OBJECT_ID = cp_object_id;

  ln_analysis_ref varchar2(32);
  lr_aga_analysis object_aga_analysis%ROWTYPE;
  lb_found BOOLEAN;

BEGIN
    lr_aga_analysis := NULL;
    lb_found := FALSE;

    FOR cur_rec IN c_aga_analysis(p_object_id, p_daytime) LOOP
      lr_aga_analysis := cur_rec;
      lb_found := TRUE;
    END LOOP;

    IF NOT lb_found THEN

      ln_analysis_ref := ec_strm_version.aga_ref_analysis_id(p_object_id, p_daytime, '<=');

      FOR cur_rec IN c_aga_analysis(ln_analysis_ref, p_daytime) LOOP
        lr_aga_analysis := cur_rec;
      END LOOP;

    END IF;

    RETURN lr_aga_analysis;

END getNextAGAAnalysisSample;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getAGAAnalysisItem
-- Description  : Return analyis item for stream
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION GetAGAAnalysisItem(p_object_id stream.object_id%TYPE,
                            p_item     VARCHAR2,
                            p_daytime  DATE)
RETURN NUMBER
--</EC-DOC>
IS
  lr_aga_analysis object_aga_analysis%ROWTYPE;
  ln_return_value number;

  begin
    lr_aga_analysis := getAGAAnalysis(p_object_id, p_daytime);

    IF p_item = 'ANALYSIS_NO' THEN
      ln_return_value := lr_aga_analysis.ANALYSIS_NO;
    ELSIF p_item = 'TS' THEN
      ln_return_value := lr_aga_analysis.TS;
    ELSIF p_item = 'PS' THEN
      ln_return_value := lr_aga_analysis.PS;
    ELSIF p_item = 'RHOTP' THEN
      ln_return_value := lr_aga_analysis.RHOTP;
    ELSIF p_item = 'RHOS' THEN
      ln_return_value := lr_aga_analysis.RHOS;
    ELSIF p_item = 'FPVS' THEN
      ln_return_value := lr_aga_analysis.FPVS;
    ELSIF p_item = 'VISC' THEN
      ln_return_value := lr_aga_analysis.VISC;
    ELSIF p_item = 'KFAC' THEN
      ln_return_value := lr_aga_analysis.KFAC;
    ELSIF p_item = 'IFLUID' THEN
      ln_return_value := TO_NUMBER(lr_aga_analysis.IFLUID);
    ELSIF p_item = 'GRS' THEN
      ln_return_value := lr_aga_analysis.GRS;
    ELSIF p_item = 'ZAIRS' THEN
      ln_return_value := lr_aga_analysis.ZAIRS;
    ELSIF p_item = 'GS_CALC_METHOD' THEN
      ln_return_value := TO_NUMBER(lr_aga_analysis.GS_CALC_METHOD);
    ELSIF p_item = 'HV' THEN
      ln_return_value := lr_aga_analysis.HV;
    ELSIF p_item = 'GRGR' THEN
      ln_return_value := lr_aga_analysis.GRGR;
    ELSIF p_item = 'X1' THEN
      ln_return_value := lr_aga_analysis.X1;
    ELSIF p_item = 'X2' THEN
      ln_return_value := lr_aga_analysis.X2;
    ELSIF p_item = 'X3' THEN
      ln_return_value := lr_aga_analysis.X3;
    ELSIF p_item = 'X4' THEN
      ln_return_value := lr_aga_analysis.X4;
    ELSIF p_item = 'TB' THEN
      ln_return_value := lr_aga_analysis.TB;
    ELSIF p_item = 'PB' THEN
      ln_return_value := lr_aga_analysis.PB;
    ELSIF p_item = 'TGR' THEN
      ln_return_value := lr_aga_analysis.TGR;
    ELSIF p_item = 'PGR' THEN
      ln_return_value := lr_aga_analysis.PGR;
    ELSIF p_item = 'TD' THEN
      ln_return_value := lr_aga_analysis.TD;
    ELSIF p_item = 'PD' THEN
      ln_return_value := lr_aga_analysis.PD;
    ELSIF p_item = 'TH' THEN
      ln_return_value := lr_aga_analysis.TH;
	ELSIF p_item = 'COMPRESS_FLOW' THEN
      ln_return_value := lr_aga_analysis.COMPRESSIBILITY_FLOW;
    ELSIF p_item = 'COMPRESS_STD' THEN
      ln_return_value := lr_aga_analysis.COMPRESSIBILITY_STD;
    ELSE
      RAISE_APPLICATION_ERROR(-20200, 'Unknown Analysis Item');
    END IF;
    return ln_return_value;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20200, 'No Data Found');
  end GetAGAAnalysisItem;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getPrevAnalysisDaytime
-- Description  : Return the previous day time for the latest previous analyis for stream by using
--                object_id instead of the analysis_no.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getPrevAnalysisDaytime(p_object_id stream.object_id%TYPE, p_daytime DATE, p_analysis_type VARCHAR2, p_num_rows NUMBER DEFAULT 1)
RETURN DATE
--</EC-DOC>
IS

CURSOR c_compute (cp_object_id stream.object_id%TYPE, cp_daytime DATE, cp_analysis_type VARCHAR2) IS
SELECT daytime
FROM object_fluid_analysis
WHERE object_id = cp_object_id
AND daytime < cp_daytime
AND analysis_type = cp_analysis_type
ORDER BY daytime DESC;

ld_return_val DATE := NULL;
lv2_analysis_ref_id stream.object_id%TYPE;

BEGIN

   lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   IF p_num_rows >= 1 THEN
      FOR cur_rec IN c_compute(lv2_analysis_ref_id, p_daytime, p_analysis_type) LOOP
         ld_return_val := cur_rec.daytime;
         IF c_compute%ROWCOUNT = p_num_rows THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;
   RETURN ld_return_val;

END getPrevAnalysisDaytime;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getCompositeAnalysisStatus
-- Description  : Return composite analysis status
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getCompositeAnalysisStatus(p_object_id stream.object_id%TYPE, p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS


CURSOR c_analysis(cp_object_id stream.object_id%TYPE, cp_daytime DATE) IS
   SELECT * FROM object_fluid_analysis ofa
   WHERE ofa.object_id = cp_object_id
   AND ofa.daytime = cp_daytime
   AND ofa.sampling_method = 'COMPOSITE';

lv2_return_val VARCHAR2(32);

BEGIN

   lv2_return_val := 'Not calculated';
   FOR cur_rec IN c_analysis(p_object_id, p_daytime) LOOP
       lv2_return_val := 'OK';
   END LOOP;

   RETURN lv2_return_val;

END getCompositeAnalysisStatus;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getCompositeAnalysisComment
-- Description  : Return composite analysis comment
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getCompositeAnalysisComment(p_object_id stream.object_id%TYPE, p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS


CURSOR c_analysis(cp_object_id stream.object_id%TYPE, cp_daytime DATE) IS
   SELECT ofa.comments
   FROM object_fluid_analysis ofa
   WHERE ofa.object_id = cp_object_id
   AND ofa.daytime = cp_daytime
   AND ofa.sampling_method like 'COMPOSITE';

lv2_return_val VARCHAR2(1000);

BEGIN

   lv2_return_val := null;

   FOR cur_rec IN c_analysis(p_object_id, p_daytime) LOOP
          lv2_return_val := cur_rec.comments;
   END LOOP;

   RETURN lv2_return_val;

END getCompositeAnalysisComment;

END;