CREATE OR REPLACE PACKAGE BODY EcDp_Well_Reservoir IS
/****************************************************************
** Package      :  EcDp_Well_Reservoir
**
** $Revision: 1.36.2.1 $
**
** Purpose      :  This package defines well/reservoir related
**                 functionality.

** Documentation:  www.energy-components.com
**
** Created      : 18.11.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date        Whom      Change description:
** --------    ----      -----------------------------------
** 02.12.99    CFS       First Version
** 05.09.00    CFS       findBlockFormationStream did not handle several levels of formation codes when only one level of fault block.
** 04.04.01    KEJ       Documented functions and procedures.
** 05.09.01    DN        Made formation and block local variables definitions generic.
** 06.03.02    DN        Added procedures createWellBore and createWellBoreInterval. Copied from BP US San Juan BPUS_Config.
** 19.03.04    SHN       Added procedure validateWeboIntervalSplit.
** 19.04.2004  FBa       Rewritten function getReservoirBlockPhaseFraction. Added local procedures getWeBoPhaseFracFromWell and getResvBlockPhaseFracFromWeBo
** 19.04.2004  FBa       Modified according to latest data model change, EC 7.3 Build 6.
** 11.08.2004  mazrina   Removed sysnam and update as necessary
** 28.10.2004  DN        Replaced block_id and formation_id with resv_block_formation_id.
** 02.03.2004  DN        Replaced webo_interval_seq with start date.
** 13.04.2005  SHN       Replaced reference from stream.resv_block_formation_id<->resv_block_formation_id.object_id with stream.object_id<->resv_block_formation.stream_id.
** 28/06/2005  SHN       Tracker 2385. Updated getBlockFormationStream because stream_type,stream_phase is moved from table STREAM to STRM_VERSION.
** 31.10.2005  ROV       Fixed error in cursor well_bores in EcDp_Well_Reservoir.getReservoirBlockPhaseFraction
** 15.11.2005  DN        TI2742: Fixed references to new resevoir table structure.
** 28.11.2005  ROV       TI2742: Added new function getResvBlockFormPhaseFraction
** 29.11.2005  ROV       TI2742/TI645: Updated getResvBlockPhaseFracFromWebo and getWeBoFracFromWell to handle phase = STEAM
** 01.12.2005  ROV       TI2742: Due to performance problems method getResvBlockFormPhaseFraction have been replaced by new method getWellRBFPhaseFraction
** 16.02.2005  ROV       TI2742/TD5393 Updated validateWeboIntervalSplit to include check for phase = STEAM, fixed small bug in getWellRBFPhaseFraction related to phase STEAM
** 30.08.2006  HUS       TI3154: Added getWellCoEntPhaseFraction
** 28.09.2006  zakiiari  TI#2610: Added SetWeboIntervalShareEndDate procedure
** 08.11.2006  zakiiari  TI#4512: Updated validateWeboIntervalSplit, getFirstWellPerfFaultBlock, getFirstWellPerfFormation
** 10.11.2006  zakiiari  TI#4512: Added getResvBlockPhaseFracFromPfInt, modified getResvBlockPhaseFracFromWeBo
** 13.03.2007  rajarsar  ECPD-3709: Updated  getWellRBFPhaseFraction,validatePerfIntervalSplit, validateWeboIntervalSplit to include water inj and gas inj
** 13.09.2007  kaurrnar  ECPD-4415: Added cursor and IF condition to getRefQualityStream FUNCTION
** 11.10.2007  Lau       ECPD-6612: Added daytime parameter to getRefQualityStream function
** 12.11.2007  ismaiime	 ECPD-6222 Add parameter p_allow_zero when calling function ecdp_objects_split.ValidateValues in ValidateWeboIntervalSplit
** 20.11.2007  ismaiime	 ECPD-6926 Modify cursor in getResvBlockPhaseFracFromPfInt to access the split factors
** 16.12.2008  oonnnng	 ECPD-10234 Update EcDp_Objects_Split.ValidateValues's last parameter (p_allow_zero) to NULL in
**                       validateWeboIntervalSplit and validatePerfIntervalSplit functions.
** 20.04.2009  oonnnng	 ECPD-6067 Add parameter to CreateNewWellBoreIntervalShare(), setWeboIntervalShareEndDate(),
**                       CreateNewPerfIntervalShare(), and setPerfIntervalShareEndDate() functions.
** 05.11.2009 farhaann   ECPD-12788:Added getReservoirBlockGasInjFrac(),getReservoirBlockWatInjFrac() and getReservoirBlockSteamInjFrac().
**                                 :Handle GAS_INJ and WAT_INJ phase in getWeBoPhaseFracFromWell(), getResvBlockPhaseFracFromWeBo() and getResvBlockPhaseFracFromPfInt().
** 08.03.2011  musaamah  ECPD-15331: Modified cursor in function getBlockFormationStream to access quality stream from RBF_VERSION (version table) instead of RESV_BLOCK_FORMATION (main table).
**                                   This is due to the column STREAM_ID which has been moved from RESV_BLOCK_FORMATION to RBF_VERSION.
** 19.01.2012  choonshu	 ECPD-19821: Added validateWeboSplitFactor procedure
** 23.04.2013  wonggkai	 ECPD-24041: Removed distinct keyword in getWellRBFPhaseFraction()
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateWeboIntervalSplit
-- Description    : Validate all split columns on table WEBO_INTERVAL_GOR,
--                  an error is raised if total sum is different than 100.
--                  This functions is a wrapper for EcDp_Objects_Split.ValidateColumn.
-- Preconditions  :
-- Postconditions : Uncommitted changes.
--
-- Using tables   : WEBO_INTERVAL, WEBO_INTERVAL_GOR
--
-- Using functions: EcDp_Objects_Split.ValidateColumn
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateWeboIntervalSplit(p_well_bore_id    VARCHAR2,
                                    p_daytime         DATE)
--</EC-DOC>
IS

   CURSOR c_split IS
      select wig.oil_pct, wig.gas_pct, wig.cond_pct, wig.water_pct, wig.steam_pct, wig.gas_inj_pct, wig.wat_inj_pct
      FROM webo_interval wi, webo_interval_gor wig
      where wi.object_id = wig.object_id
      and wi.well_bore_id = p_well_bore_id
      and wig.daytime = p_daytime;

   l_oil_pct   EcDp_Objects_Split.t_number_list;
   l_gas_pct   EcDp_Objects_Split.t_number_list;
   l_cond_pct  EcDp_Objects_Split.t_number_list;
   l_water_pct EcDp_Objects_Split.t_number_list;
   l_steam_pct EcDp_Objects_Split.t_number_list;
   l_gas_inj_pct EcDp_Objects_Split.t_number_list;
   l_wat_inj_pct EcDp_Objects_Split.t_number_list;


   ln_count NUMBER DEFAULT 1;

BEGIN

   FOR curSplit IN c_split LOOP

      l_oil_pct(ln_count)     :=  curSplit.oil_pct;
      l_gas_pct(ln_count)     :=  curSplit.gas_pct;
      l_cond_pct(ln_count)    :=  curSplit.cond_pct;
      l_water_pct(ln_count)   :=  curSplit.water_pct;
      l_steam_pct(ln_count)   :=  curSplit.steam_pct;
      l_gas_inj_pct(ln_count) :=  curSplit.gas_inj_pct;
      l_wat_inj_pct(ln_count) :=  curSplit.wat_inj_pct;


      ln_count := ln_count + 1;

   END LOOP;

   EcDp_Objects_Split.ValidateValues(l_oil_pct,l_oil_pct.count,'oil_pct');
   EcDp_Objects_Split.ValidateValues(l_gas_pct,l_gas_pct.count,'gas_pct');
   EcDp_Objects_Split.ValidateValues(l_cond_pct,l_cond_pct.count,'cond_pct');
   EcDp_Objects_Split.ValidateValues(l_water_pct,l_water_pct.count,'water_pct');
   EcDp_Objects_Split.ValidateValues(l_steam_pct,l_steam_pct.count,'steam_pct');
   EcDp_Objects_Split.ValidateValues(l_gas_inj_pct,l_gas_inj_pct.count,'gas_inj_pct');
   EcDp_Objects_Split.ValidateValues(l_wat_inj_pct,l_wat_inj_pct.count,'wat_inj_pct');



END validateWeboIntervalSplit;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createWellBore                                                               --
-- Description    : Creates a well bore representation.                                          --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions : Uncommitted changes.                                                         --
--                                                                                               --
-- Using tables   : WEBO_BORE                                                                    --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE createWellBore (
   p_object_id well.object_id%TYPE,
   p_bore_id VARCHAR2,
   p_start_date VARCHAR2
)
--</EC-DOC>
IS
   CURSOR c_bore(p_well_id VARCHAR2) IS
   SELECT COUNT(1) count
   FROM webo_bore
   WHERE well_id = p_object_id
     AND object_id = p_bore_id;

   ln_bore NUMBER;
BEGIN
   ln_bore := 0;

   -- Does the bore exist
   FOR cCur IN c_bore(p_object_id) LOOP
      ln_bore := cCur.count;
   END LOOP;

   IF ln_bore = 0 THEN
      INSERT INTO WEBO_BORE(well_id,object_id,START_DATE)
      VALUES(p_object_id,p_bore_id,p_start_date);
   END IF;

END createWellBore;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createWellBoreInterval                                                       --
-- Description    : Creates a perforation interval entry along with a new well bore.             --
--                  Establishes a connection to the low level reservoar unit                     --
-- Preconditions  :                                                                              --
-- Postconditions : Uncommitted changes.                                                         --
--                                                                                               --
-- Using tables   : WEBO_INTERVAL                                                                --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE createWellBoreInterval (
   p_object_id well.object_id%TYPE,
   p_bore_id webo_bore.object_id%TYPE,
   p_interval_id VARCHAR2,
   p_zone VARCHAR2,
   p_block VARCHAR2,
   p_start_date VARCHAR2
)
--</EC-DOC>
IS
   CURSOR c_interval(p_well_id VARCHAR2) IS
   SELECT COUNT(object_id) count
   FROM webo_interval
   WHERE well_bore_id = p_bore_id
     AND object_id = p_interval_id;

   ln_interval NUMBER;
BEGIN
   ln_interval := 0;
   createWellBore(p_object_id,p_bore_id,p_start_date);

   -- Does the interval exist
   FOR cCur in c_interval(p_object_id) LOOP
      ln_interval := cCur.count;
   END LOOP;

   IF ln_interval = 0 THEN
      INSERT INTO webo_interval(WELL_BORE_id, object_id,START_DATE)
      VALUES (p_bore_id,p_interval_id,p_start_date);
   END IF;

END createWellBoreInterval;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findBlockFormationStream                                                     --
-- Description    : Find a reference quality stream from a block/reservoir                       --
--                  The formation and fault blocks may be structured parent/child                --
--                  relationships, where a certain formation i.e. has a parent                   --
--                  formation and likewise a fault block has a parent                            --
--                  fault block. The set of fault blocks and formations represent                --
--                  the reservoir.                                                               --
--                  A combination of a fault block and a formation may have a stream             --
--                  related to it representing a fluid for the reservoir block. The              --
--                  well is completed/perforated one or more reservoir blocks. the               --
--                  case where a several formations and/or fault blocks has the same             --
--                  fluid, the stream may be associated to parent combinations.                  --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: ECDP_WELL_RESERVOIR.FINDBLOCKFORMATIONSTREAM                                 --
--                  ECDP_WELL_RESERVOIR.GETBLOCKFORMATIONSTREAM                                  --
--                  EC_RESV_FORMATION.FORMATION_CODE_PARENT                                      --
--                  EC_RESV_BLOCK.FAULT_BLOCK_PARENT                                             --
--                                                                                               --
-- Configuration                                                                                 --
-- required       : At least one well bore interval.                                             --
--                                                                                               --
-- Behaviour      :                                                                              --
--                 1. Find stream from current formation or fault block                          --
--                 2. Try from the parent formation                                              --
--                 3. Try from the parent fault block                                            --
--                 4. Try from the formation without fault block                                 --
--                 5. Try from the fault block without formation                                 --
--                 6. Go to 1 with parent formation and current fault block                      --
--                 7. Go to 1 with parent formation and parent fault block                       --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION findBlockFormationStream(
   p_stream_phase VARCHAR2,
   p_block_id resv_block.object_id%TYPE,
   p_formation_id resv_formation.object_id%TYPE)

RETURN VARCHAR2
--<EC-DOC>
IS

ln_stream_id          stream.object_id%TYPE;
lv2_formation_parent    resv_formation.object_id%TYPE;
lv2_fault_block_parent  resv_block.object_id%TYPE;

BEGIN

   -- Find stream from current formation and/or fault block
   ln_stream_id := getBlockFormationStream(
                              p_stream_phase,
                              p_block_id,
                              p_formation_id);

   IF (ln_stream_id IS NOT NULL) THEN

      RETURN ln_stream_id;

   END IF;

   --
   -- No stream found for the current fault block and formation
   -- Find stream from parent formation
   --
   IF ((p_formation_id IS NOT NULL) AND (p_block_id IS NOT NULL)) THEN
      -- Try to find stream from formation parent
      lv2_formation_parent := ec_resv_formation.resv_formation_id(
                                 p_formation_id);

      IF (lv2_formation_parent IS NOT NULL) AND (lv2_formation_parent <> p_formation_id) THEN

         ln_stream_id := getBlockFormationStream(
                              p_stream_phase,
                              p_block_id,
                              lv2_formation_parent);
      END IF;

      IF (ln_stream_id IS NOT NULL) THEN

         RETURN ln_stream_id;

      END IF;

   END IF;

   --
   -- Find stream from fault parent block
   --
   IF ((p_formation_id IS NOT NULL) AND (p_block_id IS NOT NULL)) THEN
      -- Try to find the fault block parent
      lv2_fault_block_parent := ec_resv_block.resv_block_id(
                                    p_block_id);

      IF (lv2_fault_block_parent IS NOT NULL) AND (lv2_fault_block_parent <> p_block_id) THEN

         ln_stream_id := getBlockFormationStream(
                              --p_sysnam,
                              p_stream_phase,
                              lv2_fault_block_parent,
                              p_formation_id);

      END IF;

      IF (ln_stream_id IS NOT NULL) THEN

         RETURN ln_stream_id;

      END IF;

   END IF;

   --
   -- Find stream where fault block is not set, ensure that the recursion ends by
   -- only allowing calls from the level of the recursion where both p_fault_block and
   -- formation is set
   --
   IF ((p_formation_id IS NOT NULL) AND (p_block_id IS NOT NULL)) THEN
      -- Try from formation without fault block
      ln_stream_id := getBlockFormationStream(
                           p_stream_phase,
                           NULL,
                           p_formation_id);

      IF (ln_stream_id IS NOT NULL) THEN

         RETURN ln_stream_id;

      END IF;

   END IF;

   IF ((p_formation_id IS NOT NULL) AND (p_block_id IS NOT NULL)) THEN
      -- Try from fault block without formation

      ln_stream_id := getBlockFormationStream(
                           p_stream_phase,
                           p_block_id,
                           NULL);

      IF (ln_stream_id IS NOT NULL) THEN

         RETURN ln_stream_id;

      END IF;

   END IF;


   --
   -- Was not able to find any stream for the current fault block and formation or any
   -- combinations with the parents. Now try to go up to the next level recursive.
   --
   IF ((lv2_formation_parent IS NOT NULL) OR
       (lv2_fault_block_parent IS NOT NULL)) THEN

    -- Keep the current fault block if no parents
    IF (lv2_fault_block_parent IS NULL) THEN

      lv2_fault_block_parent := p_block_id;

    END IF;

    -- Keep the current formation if no parents
    IF (lv2_formation_parent IS NULL) THEN

      lv2_formation_parent := p_formation_id;

    END IF;

      ln_stream_id := findBlockFormationStream(
                           p_stream_phase,
                           lv2_fault_block_parent,
                           lv2_formation_parent);

   END IF;


   RETURN ln_stream_id;

END findBlockFormationStream;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getBlockFormationStream                                                      --
-- Description    : Read the stream name referencing from a certain reservoir                    --
--                  formation and fault block                                                    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : stream                                                                       --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       : STREAM_VERSION.STREAM_TYPE  = EcDp_Stream_Type.QUALITY                               --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getBlockFormationStream (
   p_stream_phase VARCHAR2,
   p_block_id resv_block.object_id%TYPE,
   p_formation_id resv_formation.object_id%TYPE)

RETURN VARCHAR2
--<EC-DOC>
IS

CURSOR c_stream(cp_stream_phase VARCHAR2, cp_block_id VARCHAR2, cp_formation_id VARCHAR2) IS
SELECT rbfv.stream_id
FROM resv_block_formation rbf, rbf_version rbfv, stream s, strm_version sv
WHERE s.object_id = sv.object_id
AND rbfv.stream_id = s.object_id
AND rbf.resv_block_id = cp_block_id
AND rbf.resv_formation_id = cp_formation_id
AND sv.stream_phase = cp_stream_phase
AND sv.stream_type  = EcDp_Stream_Type.QUALITY;

ln_stream_id stream.object_id%TYPE;

BEGIN

   FOR c_cur IN c_stream(p_stream_phase, p_block_id, p_formation_id)  LOOP

      ln_stream_id := c_cur.stream_id;
      EXIT;

   END LOOP;

   RETURN ln_stream_id;

END getBlockFormationStream;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFirstWellPerfFaultBlock                                                   --
-- Description    : Find the reservoir block perforated by the first/last?                       --
--                  well perforation                                                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : PERF_INTERVAL, WEBO_INTERVAL                                                                --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       : At least one well bore interval.                                             --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getFirstWellPerfFaultBlock(
   p_well_id VARCHAR2)

RETURN VARCHAR2
--<EC-DOC>
IS

CURSOR c_fault_block IS
SELECT bf.resv_block_id
FROM webo_interval i, resv_block_formation bf, perf_interval pi,
     webo_bore wb
WHERE
      --bf.object_id = i.resv_block_formation_id
      bf.object_id = pi.resv_block_formation_id
AND   i.object_id = pi.webo_interval_id
AND   wb.object_id = i.well_bore_id
AND   wb.well_id = p_well_id
ORDER BY i.start_date
;

lv2_fault_block  resv_block.object_id%TYPE;

BEGIN

   FOR c_cur IN c_fault_block LOOP

      lv2_fault_block := c_cur.resv_block_id;

   END LOOP;

   RETURN lv2_fault_block;

END getFirstWellPerfFaultBlock;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFirstWellPerfFormation                                                    --
-- Description    : Find the reservoir formation perforated by the first/last ?                  --
--                  well perforation                                                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : PERF_INTERVAL, WEBO_INTERVAL                                                                --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       : At least one well bore interval.                                             --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getFirstWellPerfFormation(
   p_well_id VARCHAR2)

RETURN VARCHAR2
--<EC-DOC>
IS

CURSOR c_formation_code IS
SELECT bf.resv_formation_id
FROM webo_interval i, resv_block_formation bf, perf_interval pi,
     webo_bore wb
WHERE
      --bf.object_id = i.resv_block_formation_id
      bf.object_id = pi.resv_block_formation_id
AND   i.object_id = pi.webo_interval_id
AND   wb.object_id = i.well_bore_id
AND   wb.well_id = p_well_id
ORDER BY i.start_date
;

lv2_formation_code resv_formation.object_id%TYPE;

BEGIN

   FOR c_cur IN c_formation_code LOOP

      lv2_formation_code := c_cur.resv_formation_id;

   END LOOP;

   RETURN lv2_formation_code;

END getFirstWellPerfFormation;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRefQualityStream                                                          --
-- Description    : Find the reservoir quality stream for a well                                 --
--                  This function does at the moment only return the quality stream              --
--                  for the first/last well perforation,                                         --
--                  should generalise to handle any perforation.                                 --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                  ECDP_WELL_RESERVOIR.GETFIRSTWELLPERFFAULTBLOCK                               --
--                  ECDP_WELL_RESERVOIR.GETFIRSTWELLPERFFORMATION                                --
--                  ECDP_WELL_RESERVOIR.FINDBLOCKFORMATIONSTREAM                                 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getRefQualityStream(
   p_well_id VARCHAR2,
   p_phase   VARCHAR2,
   p_daytime DATE DEFAULT TRUNC(SYSDATE) )

RETURN VARCHAR2
--<EC-DOC>
IS

CURSOR c_fluid_quality (cp_well_id VARCHAR2,cp_datetime DATE) IS
SELECT wv.fluid_quality
  FROM well w, well_version wv
 WHERE wv.object_id = w.object_id
   AND wv.object_id = cp_well_id
   AND daytime = (
   SELECT MAX(daytime)
   FROM well_version
   WHERE object_id = cp_well_id
   AND daytime <= cp_datetime);

lv2_ref_stream     stream.object_id%TYPE;
lv2_formation_id   resv_formation.object_id%TYPE;
lv2_block_id       resv_block.object_id%TYPE;

BEGIN

   FOR cur_fluid_quality IN c_fluid_quality(p_well_id,p_daytime)  LOOP
      IF cur_fluid_quality.fluid_quality IS NOT NULL THEN
         lv2_ref_stream  := cur_fluid_quality.fluid_quality;
      ELSE
         lv2_block_id := getFirstWellPerfFaultBlock(p_well_id);
         lv2_formation_id := getFirstWellPerfFormation(p_well_id);
         lv2_ref_stream := findBlockFormationStream(p_phase,
                                                    lv2_block_id,
                                                    lv2_formation_id);
      END IF;
   END LOOP;

   RETURN lv2_ref_stream;

END getRefQualityStream;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getReservoirBlockConFraction                                                 --
-- Description    : Returns the reservoir block fraction of the well stream condensate phase     --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: getReservoirBlockPhaseFraction                                               --
--                  EcDp_Phase.CONDENSATE                                                        --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getReservoirBlockConFraction(
  p_object_id well.object_id%TYPE,
  p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime        DATE)

RETURN NUMBER
--<EC-DOC>
IS

ln_res_block_contr NUMBER := 0; -- assume no contribution

BEGIN

  ln_res_block_contr := getReservoirBlockPhaseFraction(
                  p_object_id,
                  p_block_id,
                  p_formation_id,
                  p_daytime,
                  EcDp_Phase.CONDENSATE);

   RETURN ln_res_block_contr;

END getReservoirBlockConFraction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getReservoirBlockGasFraction                                                 --
-- Description    : Returns the reservoir block fraction of the well stream gas phase            --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: getReservoirBlockPhaseFraction                                               --
--                  EcDp_Phase.GAS                                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getReservoirBlockGasFraction(
  p_object_id well.object_id%TYPE,
  p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime        DATE)

RETURN NUMBER
--<EC-DOC>
IS

ln_res_block_contr NUMBER := 0; -- assume no contribution

BEGIN

  ln_res_block_contr := getReservoirBlockPhaseFraction(
                  p_object_id,
                  p_block_id,
                  p_formation_id,
                  p_daytime,
                  EcDp_Phase.GAS);

   RETURN ln_res_block_contr;

END getReservoirBlockGasFraction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getReservoirBlockOilFraction                                                 --
-- Description    : Returns the reservoir block fraction of the well stream oil phase            --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: getReservoirBlockPhaseFraction                                               --
--                  EcDp_Phase.OIL                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getReservoirBlockOilFraction(
  p_object_id well.object_id%TYPE,
  p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime        DATE)

RETURN NUMBER
--<EC-DOC>
IS

ln_res_block_contr NUMBER := 0; -- assume no contribution

BEGIN

  ln_res_block_contr := getReservoirBlockPhaseFraction(
                  p_object_id,
                  p_block_id,
                  p_formation_id,
                  p_daytime,
                  EcDp_Phase.OIL);

   RETURN ln_res_block_contr;

END getReservoirBlockOilFraction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getReservoirBlockWatFraction                                                 --
-- Description    : Returns the reservoir block fraction of the well stream water phase          --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: getReservoirBlockPhaseFraction                                               --
--                  EcDp_Phase.WATER                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getReservoirBlockWatFraction(
  p_object_id well.object_id%TYPE,
  p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime        DATE)

RETURN NUMBER
--<EC-DOC>
IS

ln_res_block_contr NUMBER := 0; -- assume no contribution

BEGIN

  ln_res_block_contr := getReservoirBlockPhaseFraction(
                p_object_id,
                p_block_id,
                p_formation_id,
                p_daytime,
                EcDp_Phase.WATER);

   RETURN ln_res_block_contr;

END getReservoirBlockWatFraction;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getReservoirBlockGasInjFrac                                                  --
-- Description    : Returns the reservoir block fraction of the well stream gas injection phase  --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: getReservoirBlockPhaseFraction                                               --
--                  EcDp_Phase.GAS_INJ                                                           --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getReservoirBlockGasInjFrac(
  p_object_id well.object_id%TYPE,
  p_block_id IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime DATE)

RETURN NUMBER
--<EC-DOC>
IS

ln_res_block_contr NUMBER := 0; -- assume no contribution

BEGIN

 ln_res_block_contr := getReservoirBlockPhaseFraction(
                       p_object_id,
                       p_block_id,
                       p_formation_id,
		                   p_daytime,
		                   EcDp_Phase.GAS_INJ);

 RETURN ln_res_block_contr;

END getReservoirBlockGasInjFrac;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getReservoirBlockWatInjFrac                                                  --
-- Description    : Returns the reservoir block fraction of the well stream water injection phase--
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: getReservoirBlockPhaseFraction                                               --
--                  EcDp_Phase.WAT_INJ                                                           --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getReservoirBlockWatInjFrac(
  p_object_id well.object_id%TYPE,
  p_block_id IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime DATE)

RETURN NUMBER
--<EC-DOC>
IS

ln_res_block_contr NUMBER := 0; -- assume no contribution

BEGIN

 ln_res_block_contr := getReservoirBlockPhaseFraction(
                       p_object_id,
                       p_block_id,
                       p_formation_id,
		                   p_daytime,
		                   EcDp_Phase.WAT_INJ);

 RETURN ln_res_block_contr;

END getReservoirBlockWatInjFrac;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getReservoirBlockSteamInjFrac                                                --
-- Description    : Returns the reservoir block fraction of the well stream steam injection phase--
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: getReservoirBlockPhaseFraction                                               --
--                  EcDp_Phase.STEAM                                                             --
--                  (The EcDp_Phase.STEAM is steam injection.                                    --
--                   There is no STEAM production, so STEAM is injection)                        --                                                        --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getReservoirBlockSteamInjFrac(
  p_object_id well.object_id%TYPE,
  p_block_id IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime DATE)

RETURN NUMBER
--<EC-DOC>
IS

ln_res_block_contr NUMBER := 0; -- assume no contribution

BEGIN

 ln_res_block_contr := getReservoirBlockPhaseFraction(
                       p_object_id,
                       p_block_id,
                       p_formation_id,
		                   p_daytime,
		                   EcDp_Phase.STEAM);

 RETURN ln_res_block_contr;

END getReservoirBlockSteamInjFrac;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWellBorePhaseFracFromWell                                                 --
-- Description    : Returns the well bore fraction of the well stream
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: EcDp_Phase
--                  ec_webo_split_factor
--
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getWeBoPhaseFracFromWell(
  p_well_id        VARCHAR2,
  p_well_bore_id   VARCHAR2,
  p_daytime        DATE,
  p_phase          VARCHAR2)
RETURN NUMBER
--<EC-DOC>
IS

  CURSOR c_well_bores IS
  SELECT *
    FROM webo_bore
   WHERE well_id = p_well_id
     AND start_date <= p_daytime AND (end_date>p_daytime OR end_date IS NULL);

  ln_webo_frac      NUMBER := 0;
  ln_num_well_bores NUMBER := 0;

BEGIN
  FOR lc_webo IN c_well_bores LOOP
    ln_num_well_bores := ln_num_well_bores + 1;

    IF lc_webo.object_id = p_well_bore_id THEN
      IF p_phase = EcDp_Phase.OIL THEN
        ln_webo_frac := Nvl(ec_webo_split_factor.oil_contrib_pct(p_well_id,p_well_bore_id,p_daytime,'<=')/100, 0);
      ELSIF p_phase = EcDp_Phase.GAS THEN
        ln_webo_frac := Nvl(ec_webo_split_factor.gas_contrib_pct(p_well_id,p_well_bore_id,p_daytime,'<=')/100, 0);
      ELSIF p_phase = EcDp_Phase.WATER THEN
        ln_webo_frac := Nvl(ec_webo_split_factor.water_contrib_pct(p_well_id,p_well_bore_id,p_daytime,'<=')/100, 0);
      ELSIF p_phase = EcDp_Phase.CONDENSATE THEN
        ln_webo_frac := Nvl(ec_webo_split_factor.cond_contrib_pct(p_well_id,p_well_bore_id,p_daytime,'<=')/100, 0);
      ELSIF p_phase = EcDp_Phase.STEAM THEN
        ln_webo_frac := Nvl(ec_webo_split_factor.steam_contrib_pct(p_well_id,p_well_bore_id,p_daytime,'<=')/100, 0);
      ELSIF p_phase = EcDp_Phase.GAS_INJ THEN
        ln_webo_frac := Nvl(ec_webo_split_factor.gas_inj_pct(p_well_id,p_well_bore_id,p_daytime,'<=')/100, 0);
      ELSIF p_phase = EcDp_Phase.WAT_INJ THEN
        ln_webo_frac := Nvl(ec_webo_split_factor.wat_inj_pct(p_well_id,p_well_bore_id,p_daytime,'<=')/100, 0);
      END IF;
    END IF;
  END LOOP;

  -- Special case handling: if only ONE well bore, then return 100%
  IF ln_num_well_bores = 1 THEN
    ln_webo_frac := 1;
  END IF;

  RETURN ln_webo_frac;

END getWeBoPhaseFracFromWell;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getResvBlockPhaseFracFromWeBo                                                 --
-- Description    : Returns the reservoir block fraction of a well bore stream phase
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: EcDp_Phase
--                  ec_webo_interval
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getResvBlockPhaseFracFromWeBo(
  p_well_id        VARCHAR2,
  p_well_bore_id   VARCHAR2,
  p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime        DATE,
  p_phase          VARCHAR2)
RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_webo_intervals (p_well_id VARCHAR2, p_well_bore_id VARCHAR2, p_daytime DATE) IS
SELECT i.*
  FROM webo_interval i
  WHERE i.well_bore_id=p_well_bore_id
  AND i.start_date<=p_daytime AND (i.end_date>p_daytime OR i.end_date IS NULL);
/*
SELECT i.*, f.resv_formation_id, f.resv_block_id
  FROM webo_interval i, resv_block_formation f,
 WHERE well_bore_id=p_well_bore_id
   AND pi.webo_interval_id = i.object_id
   --AND i.resv_block_formation_id = f.object_id
   AND pi.resv_block_formation_id = f.object_id
   AND i.start_date<=p_daytime AND (i.end_date>p_daytime OR i.end_date IS NULL)
   AND pi.start_date<=p_daytime AND (pi.end_date>p_daytime OR pi.end_date IS NULL);
*/

  ln_num_intervals       NUMBER := 0;
  --ln_num_intervals_block NUMBER := 0;
  ln_frac_phase          NUMBER := 0;

BEGIN
  FOR lc_webo_interval IN c_webo_intervals(p_well_id, p_well_bore_id, p_daytime) LOOP
    ln_num_intervals := ln_num_intervals + 1;

    IF p_phase = EcDp_Phase.OIL THEN
     ln_frac_phase := ln_frac_phase + Nvl( ec_webo_interval_gor.oil_pct(lc_webo_interval.object_id,
                                                                      p_daytime,
                                                                      '<='),
                                      0)/100;
    ELSIF p_phase = EcDp_Phase.GAS THEN
     ln_frac_phase := ln_frac_phase + Nvl( ec_webo_interval_gor.gas_pct(lc_webo_interval.object_id,
                                                                        p_daytime,
                                                                        '<='),
                                      0)/100;
    ELSIF p_phase = EcDp_Phase.WATER THEN
     ln_frac_phase := ln_frac_phase + Nvl( ec_webo_interval_gor.water_pct(lc_webo_interval.object_id,
                                                                          p_daytime,
                                                                          '<='),
                                      0)/100;
    ELSIF p_phase = EcDp_Phase.CONDENSATE THEN
     ln_frac_phase := ln_frac_phase + Nvl( ec_webo_interval_gor.cond_pct(lc_webo_interval.object_id,
                                                                         p_daytime,
                                                                         '<='),
                                       0)/100;

    ELSIF p_phase = EcDp_Phase.STEAM THEN
     ln_frac_phase := ln_frac_phase + Nvl( ec_webo_interval_gor.steam_pct(lc_webo_interval.object_id,
                                                                          p_daytime,
                                                                          '<='),
                                      0)/100;

    ELSIF p_phase = EcDp_Phase.GAS_INJ THEN
     ln_frac_phase := ln_frac_phase + Nvl( ec_webo_interval_gor.gas_inj_pct(lc_webo_interval.object_id,
                                                                            p_daytime,
                                                                            '<='),
                                      0)/100;

    ELSIF p_phase = EcDp_Phase.WAT_INJ THEN
     ln_frac_phase := ln_frac_phase + Nvl( ec_webo_interval_gor.wat_inj_pct(lc_webo_interval.object_id,
                                                                            p_daytime,
                                                                            '<='),
                                      0)/100;
    END IF;
  END LOOP;

  -- Special case handling: if only ONE perforation on bore, and this perforation is within requested block, then return 100%
  IF ln_num_intervals = 1 THEN
    ln_frac_phase := 1;
  END IF;

  RETURN ln_frac_phase;

END getResvBlockPhaseFracFromWeBo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getResvBlockPhaseFracFromPfInt                                                 --
-- Description    : Returns the reservoir block fraction of a well bore stream phase
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: EcDp_Phase
--                  ec_perf_interval
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getResvBlockPhaseFracFromPfInt(
  p_well_id        VARCHAR2,
  p_well_bore_id   VARCHAR2,
  p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime        DATE,
  p_phase          VARCHAR2)
RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_perf_intervals (p_well_id VARCHAR2, p_well_bore_id VARCHAR2, p_daytime DATE) IS
SELECT pi.*, f.resv_formation_id, f.resv_block_id
  FROM perf_interval pi, webo_interval wbi, resv_block_formation f, perf_interval_gor pg
 WHERE pi.webo_interval_id = wbi.object_id
   AND wbi.well_bore_id = p_well_bore_id
   AND pi.resv_block_formation_id = f.object_id
   AND pi.object_id = pg.object_id
   AND pi.start_date<=p_daytime AND (pi.end_date>p_daytime OR pi.end_date IS NULL)
   AND (pg.end_date IS NULL OR pg.end_date > p_daytime)
   AND p_daytime BETWEEN pg.daytime AND Nvl(pg.end_date-1,p_daytime+1);


  ln_num_intervals       NUMBER := 0;
  ln_num_intervals_block NUMBER := 0;
  ln_frac_phase          NUMBER := 0;

BEGIN
  FOR lc_perf_interval IN c_perf_intervals(p_well_id, p_well_bore_id, p_daytime) LOOP
    ln_num_intervals := ln_num_intervals + 1;
    IF lc_perf_interval.resv_block_id = p_block_id AND lc_perf_interval.resv_formation_id = p_formation_id THEN
       ln_num_intervals_block := ln_num_intervals_block + 1;

       IF p_phase = EcDp_Phase.OIL THEN
         ln_frac_phase := ln_frac_phase + Nvl( ec_perf_interval_gor.oil_pct(lc_perf_interval.object_id,
                                                                          p_daytime,
                                                                          '<='),
                                          0)/100;
       ELSIF p_phase = EcDp_Phase.GAS THEN
         ln_frac_phase := ln_frac_phase + Nvl( ec_perf_interval_gor.gas_pct(lc_perf_interval.object_id,
                                                                            p_daytime,
                                                                            '<='),
                                          0)/100;
       ELSIF p_phase = EcDp_Phase.WATER THEN
         ln_frac_phase := ln_frac_phase + Nvl( ec_perf_interval_gor.water_pct(lc_perf_interval.object_id,
                                                                              p_daytime,
                                                                              '<='),
                                          0)/100;
       ELSIF p_phase = EcDp_Phase.CONDENSATE THEN
         ln_frac_phase := ln_frac_phase + Nvl( ec_perf_interval_gor.cond_pct(lc_perf_interval.object_id,
                                                                             p_daytime,
                                                                             '<='),
                                           0)/100;

       ELSIF p_phase = EcDp_Phase.STEAM THEN
         ln_frac_phase := ln_frac_phase + Nvl( ec_perf_interval_gor.steam_pct(lc_perf_interval.object_id,
                                                                              p_daytime,
                                                                              '<='),
                                          0)/100;

       ELSIF p_phase = EcDp_Phase.GAS_INJ THEN
         ln_frac_phase := ln_frac_phase + Nvl( ec_perf_interval_gor.gas_inj_pct(lc_perf_interval.object_id,
                                                                                p_daytime,
                                                                                '<='),
                                          0)/100;

       ELSIF p_phase = EcDp_Phase.WAT_INJ THEN
         ln_frac_phase := ln_frac_phase + Nvl( ec_perf_interval_gor.wat_inj_pct(lc_perf_interval.object_id,
                                                                                p_daytime,
                                                                                '<='),
                                          0)/100;

       END IF;
    END IF;
  END LOOP;

  -- Special case handling: if only ONE perforation on bore, and this perforation is within requested block, then return 100%
  IF ln_num_intervals = 1 AND ln_num_intervals_block = 1 THEN
    ln_frac_phase := 1;
  END IF;

  RETURN ln_frac_phase;

END getResvBlockPhaseFracFromPfInt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getReservoirBlockPhaseFraction                                               --
-- Description    : Returns the reservoir block fraction of a well stream phase                  --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : webo_bore                                                                    --
--                  webo_interval_gor                                                            --
--                  webo_interval                                                                --
--                                                                                               --
-- Using functions: WellBoreCur.well_bore_no                                                     --
--                  EcDp_Phase.OIL                                                               --
--                  ResFracCure.OIL_FRACTION                                                     --
--                  EcDp_Phase.GAS                                                               --
--                  ResFracCure.GAS_FRACTION                                                     --
--                  EcDp_Phase.CONDENSATE                                                        --
--                  ResFracCure.CON_FRACTION                                                     --
--                  EcDp_Phase.WATER                                                             --
--                  ResFracCure.WAT_FRACTION                                                     --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getReservoirBlockPhaseFraction(
  p_object_id well.object_id%TYPE,
  p_block_id  IN resv_block.object_id%TYPE,
  p_formation_id IN resv_formation.object_id%TYPE,
  p_daytime        DATE,
  p_phase        VARCHAR2)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR well_bores IS
SELECT object_id
FROM webo_bore
WHERE well_id = p_object_id
  AND p_daytime BETWEEN Nvl(start_date,p_daytime-1) AND Nvl(end_date,p_daytime+1);

ln_webo_contr           NUMBER;
ln_res_block_contr      NUMBER := 0;
ln_res_block_webo_contr NUMBER;
ln_res_block_perf_contr NUMBER;

BEGIN

  FOR WellBoreCur IN well_bores LOOP
    ln_webo_contr := getWeBoPhaseFracFromWell( p_object_id,
                                               WellBoreCur.object_id,
                                               p_daytime,
                                               p_phase);

    ln_res_block_webo_contr := getResvBlockPhaseFracFromWeBo(p_object_id,
                                                             WellBoreCur.object_id,
                                                             p_block_id,
                                                             p_formation_id,
                                                             p_daytime,
                                                             p_phase);

    ln_res_block_perf_contr := getResvBlockPhaseFracFromPfInt(p_object_id,
                                                              WellBoreCur.object_id,
                                                              p_block_id,
                                                              p_formation_id,
                                                              p_daytime,
                                                              p_phase);

    ln_res_block_contr := ln_res_block_contr + (ln_res_block_webo_contr * ln_webo_contr * ln_res_block_perf_contr);

  END LOOP;

  RETURN ln_res_block_contr;

END getReservoirBlockPhaseFraction;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CreateNewWellBoreIntervalShare
-- Description    :Temporary override of EcDp_Objects_Split.CreateNewShare. Remove when cleanup in table
--          webo_interval_gor
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE CreateNewWellBoreIntervalShare(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2
        )
--</EC-DOC>
IS

   CURSOR c_columns(p_table_name  VARCHAR2) IS
    SELECT * FROM cols
    WHERE table_name = 'DV_WELL_BORE_INTERVAL_SPLIT' AND column_name <> 'DAYTIME';


   CURSOR c_class_db_mapping(p_class_name  VARCHAR2) IS
    SELECT * FROM class_db_mapping
    WHERE class_name = p_class_name;

   CURSOR c_class IS
    SELECT 1 FROM class
    WHERE class_name = 'WELL_BORE_INTERVAL_SPLIT'
    AND  Nvl(lock_ind,'N') = 'Y';


   lv2_owner            class_db_mapping.db_object_owner%TYPE;
   lv2_table_name       class_db_mapping.db_object_name%TYPE;
   lv2_cols             VARCHAR2(4000);
   lv2_sql              VARCHAR2(32000);
   ld_next_daytime      DATE;


BEGIN

   -- Get table_name
   FOR curClass IN c_class_db_mapping(p_class_name) LOOP
      lv2_owner := curClass.db_object_owner;
      lv2_table_name := curClass.db_object_name;
   END LOOP;

   -----------------------------
   -- Build and execute insert statement
   ------------------------------

   FOR curColum IN c_columns(lv2_table_name) LOOP

     lv2_cols := lv2_cols || ', ' || curColum.column_name;

   END LOOP;

   FOR curLock IN c_class LOOP  -- Will only enter loop and check for lock if lock_ind = Y

     -- Need to enforce locking check, assuming that this follows the analysis case, meaning we must check if there are
     -- any locked months between the new split and the next split for given owner object.

     lv2_sql := 'SELECT min(daytime) FROM dv_well_bore_interval_split'  ||
                ' WHERE WELL_BORE_ID = :p_owner_object_id ' || CHR(10) ||
                ' AND daytime > :p_daytime ';

     BEGIN

       EXECUTE IMMEDIATE lv2_sql INTO ld_next_daytime USING p_owner_object_id, p_daytime ;

     EXCEPTION    -- This can fail if there are now next split, then set next split to NULL
       WHEN OTHERS THEN
          ld_next_daytime := NULL;

     END;

     EcDp_Month_lock.validatePeriodForLockOverlap('INSERTING', p_daytime, ld_next_daytime, 'EcDp_Performance_Lock.CreateNewWellBoreIntervalShare, new split have effect on locked period.', p_owner_object_id);

  END LOOP;


   lv2_sql := 'INSERT INTO dv_well_bore_interval_split' ||
              '(daytime' || lv2_cols || ')'   || CHR(10) ||
              ' SELECT :p_daytime' || lv2_cols || CHR(10) ||
              ' FROM dv_well_bore_interval_split '|| CHR(10) ||
              ' WHERE WELL_BORE_ID = :p_owner_object_id ' || CHR(10) ||
              ' AND daytime <= :p_daytime AND :p_daytime < Nvl(end_date,:p_daytime + 1/(24*60*60))';

  EXECUTE IMMEDIATE lv2_sql USING p_daytime,p_owner_object_id, p_daytime, p_daytime, p_daytime;

   lv2_sql := 'UPDATE dv_well_bore_interval_split' ||
              ' SET end_date = :p_daytime'||CHR(10)||
              ' WHERE WELL_BORE_ID = :p_object_id AND daytime < :p_daytime  AND :p_daytime < Nvl(end_date, :p_daytime+1/(24*60*60))';

   EXECUTE IMMEDIATE lv2_sql using p_daytime,p_owner_object_id,p_daytime,p_daytime,p_daytime;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWellRBFPhaseFraction                                                      --
-- Description    : Returns the fraction of a wells total production/injection of a given phase  --
--                  originating from a given reservoir block formation               --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                            --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION getWellRBFPhaseFraction(
        p_well_id well.object_id%TYPE,
        p_resv_block_form_id IN resv_block_formation.object_id%TYPE,
  p_daytime DATE,
  p_phase_direction  VARCHAR2)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR well_rbfCur IS
 SELECT
 w.object_id AS WELL_ID,
 wbs.oil_contrib_pct as BoreOilPct,
 wbs.gas_contrib_pct as BoreGasPct,
 wbs.water_contrib_pct as BoreWaterPct,
 wbs.cond_contrib_pct as BoreCondPct,
 wbs.steam_contrib_pct as BoreSteamPct,
 wbs.gas_inj_pct as BoreGasInjPct,
 wbs.wat_inj_pct as BoreWatInjPct,
 wbis.oil_pct AS IntOilPct,
 wbis.gas_pct as IntGasPct,
 wbis.water_pct as IntWaterPct,
 wbis.cond_pct as IntCondPct,
 wbis.steam_pct as IntSteamPct,
 wbis.gas_inj_pct as IntGasInjPct,
 wbis.wat_inj_pct as IntWatInjPct,
 pis.oil_pct as PerfIntOilPct,
 pis.gas_pct as PerfIntGasPct,
 pis.water_pct as PerfIntWaterPct,
 pis.cond_pct as PerfIntCondPct,
 pis.steam_pct as PerfIntSteamInjPct,
 pis.gas_inj_pct as PerfIntGasInjPct,
 pis.wat_inj_pct as PerfIntWatInjPct,
 sd.daytime AS daytime
 FROM well w, webo_bore wb ,webo_interval wbi,system_days sd, webo_split_factor wbs, webo_interval_gor wbis, resv_block_formation rbf, perf_interval pi, perf_interval_gor pis
 WHERE wb.well_id = w.object_id
 AND wbi.well_bore_id = wb.object_id
 AND pi.webo_interval_id = wbi.object_id
 AND wbs.well_bore_id = wb.object_id
 AND wbis.object_id = wbi.object_id
 AND pis.object_id = pi.object_id
 --AND rbf.object_id = wbi.resv_block_formation_id
 AND rbf.object_id = pi.resv_block_formation_id
 AND wbis.daytime <= sd.daytime
 AND (wbis.end_date is null OR wbis.end_date > sd.daytime)
 AND wbs.daytime <= sd.daytime
 AND (wbs.end_date is null OR wbs.end_date > sd.daytime)
 AND pis.daytime <= sd.daytime
 AND (pis.end_date is null OR pis.end_date > sd.daytime)
 AND sd.daytime = p_daytime
 AND w.object_id = p_well_id
 AND rbf.object_id = p_resv_block_form_id;



ln_well_rbf_frac   NUMBER;
ln_webo_int_frac   NUMBER;
ln_perf_int_frac   NUMBER;
lb_first BOOLEAN := TRUE;

BEGIN

  FOR myCur IN well_rbfCur LOOP

       IF p_phase_direction = 'OP' THEN -- Oil Production/OP
         --ln_webo_int_frac := myCur.BoreOilPct/100 * myCur.IntOilPct/100;
         ln_perf_int_frac := myCur.BoreOilPct/100 * myCur.IntOilPct/100 * myCur.Perfintoilpct/100;

       ELSIF p_phase_direction = 'GP' THEN -- Gas Production/GP
         --ln_webo_int_frac := myCur.BoreGasPct/100 * myCur.IntGasPct/100;
         ln_perf_int_frac := myCur.BoreGasPct/100 * myCur.IntGasPct/100 * myCur.Perfintgaspct/100;

       ELSIF p_phase_direction = 'WP' THEN -- Water Production/ WP
         --ln_webo_int_frac := myCur.BoreWaterPct/100 * myCur.IntWaterPct/100;
         ln_perf_int_frac := myCur.BoreWaterPct/100 * myCur.IntWaterPct/100 * myCur.Perfintwaterpct/100;

       ELSIF p_phase_direction = 'CP' THEN -- Condensate Production/ CP
         --ln_webo_int_frac := myCur.BoreCondPct/100 * myCur.IntCondPct/100;
         ln_perf_int_frac := myCur.BoreCondPct/100 * myCur.IntCondPct/100 * myCur.Perfintcondpct/100;

       ELSIF p_phase_direction = 'SI' THEN -- Steam Injection / SI
         --ln_webo_int_frac := myCur.BoreSteamPct/100 * myCur.IntSteamPct/100;
         ln_perf_int_frac := myCur.BoreSteamPct/100 * myCur.IntSteamPct/100 * myCur.Perfintsteaminjpct/100;

       ELSIF p_phase_direction = 'WI' THEN
         ln_perf_int_frac := myCur.BoreWatInjPct/100 * myCur.IntWatInjPct/100 * myCur.Perfintwatinjpct/100;

       ELSIF p_phase_direction = 'GI' THEN
         ln_perf_int_frac := myCur.BoreGasInjPct/100 * myCur.IntGasInjPct/100 * myCur.Perfintgasinjpct/100;

       END IF;


    IF(lb_first) THEN

        --ln_well_rbf_frac := ln_webo_int_frac;
        ln_well_rbf_frac := ln_perf_int_frac;
        lb_first := FALSE;

    ELSE
        --ln_well_rbf_frac := ln_well_rbf_frac + ln_webo_int_frac;
        ln_well_rbf_frac := ln_well_rbf_frac + ln_perf_int_frac;
    END IF;


  END LOOP;

  RETURN ln_well_rbf_frac;


END getWellRBFPhaseFraction;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWellCoEntPhaseFraction                           --
-- Description    : Returns the fraction of a wells total production/injection of a given phase  --
--                  originating from a well and commercial entity                 --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                   --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getWellCoEntPhaseFraction(
    p_well_id  well.object_id%TYPE,
  p_coent_id  commercial_entity.object_id%TYPE,
  p_daytime  DATE,
  p_phase    VARCHAR2)
RETURN NUMBER
--<EC-DOC>
IS

CURSOR well_rbfCur IS
 SELECT DISTINCT wb.well_id, rb.object_id resv_block_id, rf.object_id resv_formation_id
  FROM resv_block_formation rbf,
       rbf_version rbfv,
       resv_block rb,
       resv_formation rf,
       webo_bore wb,
       webo_interval wbi,
       perf_interval pi
  WHERE wb.object_id = wbi.well_bore_id
  AND wbi.object_id = pi.webo_interval_id
  --AND rbf.object_id = wbi.resv_block_formation_id
  AND rbf.object_id = pi.resv_block_formation_id
  AND rbfv.object_id = rbf.object_id
  AND rbfv.commercial_entity_id = p_coent_id
  AND wb.well_id = p_well_id
  AND rbf.resv_block_id = rb.object_id
  AND rbf.resv_formation_id = rf.object_id
  AND p_daytime BETWEEN wb.start_date AND Nvl(wb.end_date-1,p_daytime+1)
  AND p_daytime BETWEEN wbi.start_date AND Nvl(wbi.end_date-1,p_daytime+1)
  AND p_daytime BETWEEN rf.start_date AND Nvl(rf.end_date-1,p_daytime+1)
  AND p_daytime BETWEEN rbf.start_date AND Nvl(rbf.end_date-1,p_daytime+1)
  AND p_daytime BETWEEN pi.start_date AND Nvl(pi.end_date-1,p_daytime+1)
  AND p_daytime BETWEEN rbfv.daytime AND Nvl(rbfv.end_date-1,p_daytime+1);

ln_well_rbf_frac NUMBER := 0;

BEGIN

  FOR well_rbf IN well_rbfCur LOOP
    ln_well_rbf_frac := Nvl(ln_well_rbf_frac,0) + getReservoirBlockPhaseFraction(
                    well_rbf.well_id,
                well_rbf.resv_block_id,
                  well_rbf.resv_formation_id,
                p_daytime,
                p_phase);
  END LOOP;

  RETURN ln_well_rbf_frac;

END getWellCoEntPhaseFraction;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SetWeboIntervalShareEndDate
-- Description    : Setting end date to selected well bore interval share/split
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setWeboIntervalShareEndDate(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2
        )
--</EC-DOC>
IS

   CURSOR c_class_db_mapping(p_class_name  VARCHAR2) IS
    SELECT * FROM class_db_mapping
    WHERE class_name = p_class_name;

   CURSOR c_class IS
    SELECT 1 FROM class
    WHERE class_name = 'WELL_BORE_INTERVAL_SPLIT'
    AND  Nvl(lock_ind,'N') = 'Y';


   lv2_owner            class_db_mapping.db_object_owner%TYPE;
   lv2_table_name       class_db_mapping.db_object_name%TYPE;
   lv2_sql              VARCHAR2(32000);
   ld_next_daytime      DATE;

BEGIN

  -- Get table_name
  FOR curClass IN c_class_db_mapping(p_class_name) LOOP
    lv2_owner := curClass.db_object_owner;
    lv2_table_name := curClass.db_object_name;
  END LOOP;

  FOR curLock IN c_class LOOP  -- Will only enter loop and check for lock if lock_ind = Y

    -- Need to enforce locking check, assuming that this follows the analysis case, meaning we must check if there are
    -- any locked months between the new split and the next split for given owner object.

    lv2_sql := 'SELECT min(daytime) FROM dv_well_bore_interval_split'  ||
              ' WHERE WELL_BORE_ID = :p_owner_object_id ' || CHR(10) ||
              ' AND daytime > :p_daytime ';

    BEGIN
      EXECUTE IMMEDIATE lv2_sql INTO ld_next_daytime USING p_owner_object_id, p_daytime ;

    EXCEPTION    -- This can fail if there are now next split, then set next split to NULL
      WHEN OTHERS THEN
        ld_next_daytime := NULL;
    END;

    EcDp_Month_lock.validatePeriodForLockOverlap('UPDATING', p_daytime, ld_next_daytime, 'EcDp_Well_Reservoir.SetWeboIntervalShareEndDate, end-date split have effect on locked period.', p_owner_object_id);

  END LOOP;
   -----------------------------
   -- Build and execute update statement
   ------------------------------
  lv2_sql := 'UPDATE dv_well_bore_interval_split' ||
            ' SET end_date = :p_daytime'||CHR(10)||
            ' WHERE WELL_BORE_ID = :p_object_id AND daytime < :p_daytime  AND :p_daytime < Nvl(end_date, :p_daytime+1/(24*60*60))';

  EXECUTE IMMEDIATE lv2_sql using p_daytime,p_owner_object_id,p_daytime,p_daytime,p_daytime;

END SetWeboIntervalShareEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CreateNewPerfIntervalShare
-- Description    :Temporary override of EcDp_Objects_Split.CreateNewShare. Remove when cleanup in table
--          webo_interval_gor
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE CreateNewPerfIntervalShare(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2
        )
--</EC-DOC>
IS

   CURSOR c_columns(p_table_name  VARCHAR2) IS
    SELECT * FROM cols
    WHERE table_name = 'DV_PERF_INTERVAL_SPLIT' AND column_name <> 'DAYTIME';


   CURSOR c_class_db_mapping(p_class_name  VARCHAR2) IS
    SELECT * FROM class_db_mapping
    WHERE class_name = p_class_name;

   CURSOR c_class IS
    SELECT 1 FROM class
    WHERE class_name = 'PERF_INTERVAL_SPLIT'
    AND  Nvl(lock_ind,'N') = 'Y';


   lv2_owner            class_db_mapping.db_object_owner%TYPE;
   lv2_table_name       class_db_mapping.db_object_name%TYPE;
   lv2_cols             VARCHAR2(4000);
   lv2_sql              VARCHAR2(32000);
   ld_next_daytime      DATE;


BEGIN

   -- Get table_name
   FOR curClass IN c_class_db_mapping(p_class_name) LOOP
      lv2_owner := curClass.db_object_owner;
      lv2_table_name := curClass.db_object_name;
   END LOOP;

   -----------------------------
   -- Build and execute insert statement
   ------------------------------

   FOR curColum IN c_columns(lv2_table_name) LOOP

     lv2_cols := lv2_cols || ', ' || curColum.column_name;

   END LOOP;

   FOR curLock IN c_class LOOP  -- Will only enter loop and check for lock if lock_ind = Y

     -- Need to enforce locking check, assuming that this follows the analysis case, meaning we must check if there are
     -- any locked months between the new split and the next split for given owner object.

     lv2_sql := 'SELECT min(daytime) FROM DV_PERF_INTERVAL_SPLIT'  ||
                ' WHERE WEBO_INTERVAL_ID = :p_owner_object_id ' || CHR(10) ||
                ' AND daytime > :p_daytime ';

     BEGIN

       EXECUTE IMMEDIATE lv2_sql INTO ld_next_daytime USING p_owner_object_id, p_daytime ;

     EXCEPTION    -- This can fail if there are now next split, then set next split to NULL
       WHEN OTHERS THEN
          ld_next_daytime := NULL;

     END;

     EcDp_Month_lock.validatePeriodForLockOverlap('INSERTING', p_daytime, ld_next_daytime, 'EcDp_Performance_Lock.CreateNewPerfIntervalShare, new split have effect on locked period.', p_owner_object_id);

  END LOOP;


   lv2_sql := 'INSERT INTO dv_perf_interval_split' ||
              '(daytime' || lv2_cols || ')'   || CHR(10) ||
              ' SELECT :p_daytime' || lv2_cols || CHR(10) ||
              ' FROM dv_perf_interval_split '|| CHR(10) ||
              ' WHERE WEBO_INTERVAL_ID = :p_owner_object_id ' || CHR(10) ||
              ' AND daytime <= :p_daytime AND :p_daytime < Nvl(end_date,:p_daytime + 1/(24*60*60))';

  EXECUTE IMMEDIATE lv2_sql USING p_daytime,p_owner_object_id, p_daytime, p_daytime, p_daytime;

   lv2_sql := 'UPDATE dv_perf_interval_split' ||
              ' SET end_date = :p_daytime'||CHR(10)||
              ' WHERE WEBO_INTERVAL_ID = :p_object_id AND daytime < :p_daytime  AND :p_daytime < Nvl(end_date, :p_daytime+1/(24*60*60))';

   EXECUTE IMMEDIATE lv2_sql using p_daytime,p_owner_object_id,p_daytime,p_daytime,p_daytime;

END CreateNewPerfIntervalShare;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SetPerfIntervalShareEndDate
-- Description    : Setting end date to selected perforation interval share/split
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setPerfIntervalShareEndDate(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2
        )
--</EC-DOC>
IS

   CURSOR c_class_db_mapping(p_class_name  VARCHAR2) IS
    SELECT * FROM class_db_mapping
    WHERE class_name = p_class_name;

   CURSOR c_class IS
    SELECT 1 FROM class
    WHERE class_name = 'PERF_INTERVAL_SPLIT'
    AND  Nvl(lock_ind,'N') = 'Y';


   lv2_owner            class_db_mapping.db_object_owner%TYPE;
   lv2_table_name       class_db_mapping.db_object_name%TYPE;
   lv2_sql              VARCHAR2(32000);
   ld_next_daytime      DATE;

BEGIN

  -- Get table_name
  FOR curClass IN c_class_db_mapping(p_class_name) LOOP
    lv2_owner := curClass.db_object_owner;
    lv2_table_name := curClass.db_object_name;
  END LOOP;

  FOR curLock IN c_class LOOP  -- Will only enter loop and check for lock if lock_ind = Y

    -- Need to enforce locking check, assuming that this follows the analysis case, meaning we must check if there are
    -- any locked months between the new split and the next split for given owner object.

    lv2_sql := 'SELECT min(daytime) FROM dv_perf_interval_split'  ||
              ' WHERE WEBO_INTERVAL_ID = :p_owner_object_id ' || CHR(10) ||
              ' AND daytime > :p_daytime ';

    BEGIN
      EXECUTE IMMEDIATE lv2_sql INTO ld_next_daytime USING p_owner_object_id, p_daytime ;

    EXCEPTION    -- This can fail if there are now next split, then set next split to NULL
      WHEN OTHERS THEN
        ld_next_daytime := NULL;
    END;

    EcDp_Month_lock.validatePeriodForLockOverlap('UPDATING', p_daytime, ld_next_daytime, 'EcDp_Well_Reservoir.SetPerfIntervalShareEndDate, end-date split have effect on locked period.', p_owner_object_id);

  END LOOP;
   -----------------------------
   -- Build and execute update statement
   ------------------------------
  lv2_sql := 'UPDATE dv_perf_interval_split' ||
            ' SET end_date = :p_daytime'||CHR(10)||
            ' WHERE WEBO_INTERVAL_ID = :p_object_id AND daytime < :p_daytime  AND :p_daytime < Nvl(end_date, :p_daytime+1/(24*60*60))';

  EXECUTE IMMEDIATE lv2_sql using p_daytime,p_owner_object_id,p_daytime,p_daytime,p_daytime;

END SetPerfIntervalShareEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validatePerfIntervalSplit
-- Description    : Validate all split columns on table PERF_INTERVAL_GOR,
--                  an error is raised if total sum is different than 100.
--                  This functions is a wrapper for EcDp_Objects_Split.ValidateColumn.
-- Preconditions  :
-- Postconditions : Uncommitted changes.
--
-- Using tables   : PERF_INTERVAL, PERF_INTERVAL_GOR
--
-- Using functions: EcDp_Objects_Split.ValidateColumn
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validatePerfIntervalSplit(p_well_bore_interval_id    VARCHAR2,
                                    p_daytime                  DATE)
--</EC-DOC>
IS

   CURSOR c_split IS
      select pg.oil_pct, pg.gas_pct, pg.cond_pct, pg.water_pct, pg.steam_pct, pg.gas_inj_pct, pg.wat_inj_pct
      from perf_interval pi, perf_interval_gor pg
      where pi.object_id = pg.object_id
      and pi.webo_interval_id = p_well_bore_interval_id
      and pg.daytime = p_daytime;

   l_oil_pct   EcDp_Objects_Split.t_number_list;
   l_gas_pct   EcDp_Objects_Split.t_number_list;
   l_cond_pct  EcDp_Objects_Split.t_number_list;
   l_water_pct EcDp_Objects_Split.t_number_list;
   l_steam_pct EcDp_Objects_Split.t_number_list;
   l_gas_inj_pct EcDp_Objects_Split.t_number_list;
   l_wat_inj_pct EcDp_Objects_Split.t_number_list;


   ln_count NUMBER DEFAULT 1;

BEGIN

   FOR curSplit IN c_split LOOP

      l_oil_pct(ln_count)     :=  curSplit.oil_pct;
      l_gas_pct(ln_count)     :=  curSplit.gas_pct;
      l_cond_pct(ln_count)    :=  curSplit.cond_pct;
      l_water_pct(ln_count)   :=  curSplit.water_pct;
      l_steam_pct(ln_count)   :=  curSplit.steam_pct;
      l_gas_inj_pct(ln_count)  :=  curSplit.gas_inj_pct;
      l_wat_inj_pct(ln_count)  :=  curSplit.wat_inj_pct;


      ln_count := ln_count + 1;

   END LOOP;

   EcDp_Objects_Split.ValidateValues(l_oil_pct,l_oil_pct.count,'oil_pct');
   EcDp_Objects_Split.ValidateValues(l_gas_pct,l_gas_pct.count,'gas_pct');
   EcDp_Objects_Split.ValidateValues(l_cond_pct,l_cond_pct.count,'cond_pct');
   EcDp_Objects_Split.ValidateValues(l_water_pct,l_water_pct.count,'water_pct');
   EcDp_Objects_Split.ValidateValues(l_steam_pct,l_steam_pct.count,'steam_pct');
   EcDp_Objects_Split.ValidateValues(l_gas_inj_pct,l_gas_inj_pct.count,'gas_inj_pct');
   EcDp_Objects_Split.ValidateValues(l_wat_inj_pct,l_wat_inj_pct.count,'wat_inj_pct');



END validatePerfIntervalSplit;

---------------------------------------------------------------------------------------------------
-- Procedure      : validateWeboSplitFactor
-- Description    : Validate all split columns on table WEBO_SPLIT_FACTOR,
--                  an error is raised if total sum is different than 100.
--                  This functions is a wrapper for EcDp_Objects_Split.ValidateColumn.
-- Preconditions  :
-- Postconditions : Uncommitted changes.
--
-- Using tables   : WEBO_SPLIT_FACTOR, WELL
--
-- Using functions: EcDp_Objects_Split.ValidateColumn
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateWeboSplitFactor(p_well_id    VARCHAR2,
                                    p_daytime         DATE)
--</EC-DOC>
IS

   CURSOR c_split IS
      select oil_contrib_pct, gas_contrib_pct, cond_contrib_pct, water_contrib_pct, steam_contrib_pct, gas_inj_pct, wat_inj_pct
      FROM webo_split_factor
      where object_id = p_well_id
      and daytime = p_daytime;

   l_oil_contrib_pct   EcDp_Objects_Split.t_number_list;
   l_gas_contrib_pct   EcDp_Objects_Split.t_number_list;
   l_cond_contrib_pct  EcDp_Objects_Split.t_number_list;
   l_water_contrib_pct EcDp_Objects_Split.t_number_list;
   l_steam_contrib_pct EcDp_Objects_Split.t_number_list;
   l_gas_inj_pct       EcDp_Objects_Split.t_number_list;
   l_wat_inj_pct       EcDp_Objects_Split.t_number_list;


   ln_count NUMBER DEFAULT 1;

BEGIN

   FOR curSplit IN c_split LOOP

      l_oil_contrib_pct(ln_count)     :=  curSplit.Oil_Contrib_Pct;
      l_gas_contrib_pct(ln_count)     :=  curSplit.Gas_Contrib_Pct;
      l_cond_contrib_pct(ln_count)    :=  curSplit.Cond_Contrib_Pct;
      l_water_contrib_pct(ln_count)   :=  curSplit.Water_Contrib_Pct;
      l_steam_contrib_pct(ln_count)   :=  curSplit.Steam_Contrib_Pct;
      l_gas_inj_pct(ln_count) :=  curSplit.Gas_Inj_Pct;
      l_wat_inj_pct(ln_count) :=  curSplit.Wat_Inj_Pct;


      ln_count := ln_count + 1;

   END LOOP;

   EcDp_Objects_Split.ValidateValues(l_oil_contrib_pct,l_oil_contrib_pct.count,'oil_contrib_pct');
   EcDp_Objects_Split.ValidateValues(l_gas_contrib_pct,l_gas_contrib_pct.count,'gas_contrib_pct');
   EcDp_Objects_Split.ValidateValues(l_cond_contrib_pct,l_cond_contrib_pct.count,'cond_contrib_pct');
   EcDp_Objects_Split.ValidateValues(l_water_contrib_pct,l_water_contrib_pct.count,'water_contrib_pct');
   EcDp_Objects_Split.ValidateValues(l_steam_contrib_pct,l_steam_contrib_pct.count,'steam_contrib_pct');
   EcDp_Objects_Split.ValidateValues(l_gas_inj_pct,l_gas_inj_pct.count,'gas_inj_pct');
   EcDp_Objects_Split.ValidateValues(l_wat_inj_pct,l_wat_inj_pct.count,'wat_inj_pct');



END validateWeboSplitFactor;

END EcDp_Well_Reservoir;