CREATE OR REPLACE PACKAGE BODY EcDp_Unit IS
/***************************************************************************************
** Package	:  EcDp_Unit
**
** $Revision: 1.32 $
**
**
** Purpose	:  Functions used to convert to either other units or fractions
**
** General Logic:
**
** Modification history:
**
** Date:     Whom	Change description:
** yyyymmdd
** --------  ---- ----------------------------------------------------------------------
** 20040505	KSN  Rewrite GetUnitFromLogical after new unit tables in db (tracker 702)
** 20050405 SHN  Added function GetViewFormatMask
** 20060823 SRA  Added Revenue Functionality
** 20061213 SSK	 Added t_uom_set
** 20070115 SIAH ECDP-4488 Improve performance for convertValue
** 20070709	SSK	 Renamed references from SCM to SM3
** 20100326 rajarsar ECPD:11223:Updated convertValue,added getUnitConObjFactor, getUnitConGrpFactor and getBaseUnitPrefFactor
** 20100715 leongwen ECPD-11731: Autorange feature not working correctly on Stable Period Graph
** 20111003 hodneeri ECPD-18461: Add support for user exit in unit conversion
** 20111003 hodneeri ECPD-18490: Fix bug when inverse unitconversion is performed
** 20111124 hodneeri ECPD-19247: Fix pragma problems with unitconversion fix, and make user exit package name hardcoded to UE_UOM.
****************************************************************************************
*/


TYPE t_uom_set IS RECORD
  (
   qty NUMBER,
   uom VARCHAR2(32)
  );


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetUOMGroup                                                                  --
-- Description    :                                                                              --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : ctrl_unit
--                                                                                               --
-- Using functions: ec_ctrl_unit
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION GetUOMGroup(p_uom_code  VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR cUomGroup IS
SELECT
    uom_group
FROM
    ctrl_unit t
WHERE
    t.unit = p_uom_code;

lv2_uom_group VARCHAR2(32);

BEGIN

    FOR uomGroup IN cUomGroup LOOP
        lv2_uom_group := uomGroup.Uom_Group;
    END LOOP;

    RETURN lv2_uom_group;

END GetUOMGroup;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetUOMSubGroup                                                                        --
-- Description    :               --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : ctrl_unit
--                                                                                               --
-- Using functions: ec_ctrl_unit
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION GetUOMSubGroup(p_uom_code  VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>

IS

CURSOR cUomSubGroup IS
SELECT
    uom_subgroup
FROM
    ctrl_unit t
WHERE
    t.unit = p_uom_code;

lv2_uom_subgroup VARCHAR2(32);

BEGIN

    FOR uomSubGroup IN cUomSubGroup LOOP
        lv2_uom_subgroup := uomSubGroup.Uom_SubGroup;
    END LOOP;

    RETURN lv2_uom_subgroup;

END GetUOMSubGroup;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetUOMSubGroupTarget                                                         --
-- Description    :               --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : none
--                                                                                               --
-- Using functions: none
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION GetUOMSubGroupTarget(
                     p_uom_subgroup  VARCHAR2)
RETURN VARCHAR2
--<EC-DOC>

IS

BEGIN

     IF p_uom_subgroup = 'JO' THEN RETURN '100MJ'; END IF;
     IF p_uom_subgroup = 'TH' THEN RETURN 'THERMS'; END IF;
     IF p_uom_subgroup = 'WH' THEN RETURN 'KWH'; END IF;
     IF p_uom_subgroup = 'MA' THEN RETURN 'MT'; END IF;
     IF p_uom_subgroup = 'MV' THEN RETURN 'MTV'; END IF;
     IF p_uom_subgroup = 'UA' THEN RETURN 'UST'; END IF;
     IF p_uom_subgroup = 'UV' THEN RETURN 'USTV'; END IF;
     IF p_uom_subgroup = 'BI' THEN RETURN 'BBLS'; END IF;
     IF p_uom_subgroup = 'BM' THEN RETURN 'BBLS15'; END IF;
     IF p_uom_subgroup = 'BE' THEN RETURN 'BOE'; END IF;
     IF p_uom_subgroup = 'SF' THEN RETURN 'MSCF'; END IF;
     IF p_uom_subgroup = 'NM' THEN RETURN 'MNM3'; END IF;
     IF p_uom_subgroup = 'SM' THEN RETURN 'MSM3'; END IF;

     RETURN NULL; -- not defined

END GetUOMSubGroupTarget;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetSubGroupFromUOM
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : none
--
-- Using functions: none
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION GetSubGroupFromUOM(
                     p_uom  VARCHAR2)
RETURN VARCHAR2
--<EC-DOC>

IS

BEGIN

     IF p_uom IN ('100MJ','J','KJ','MJ','GJ')                                        THEN RETURN 'JO' ; END IF;
     IF p_uom IN ('THERMS','KTHERMS','MTHERMS','GTHERMS','BTU','KBTU','MBTU','GBTU') THEN RETURN 'TH' ; END IF;
     IF p_uom IN ('KWH','MWH','GWH')                                                 THEN RETURN 'WH' ; END IF;
     IF p_uom IN ('MT','KMT','MMT')                                                  THEN RETURN 'MA' ; END IF;
     IF p_uom IN ('MTV','KMTV','MMTV')                                               THEN RETURN 'MV' ; END IF;
     IF p_uom IN ( 'UST','KUST','MUST')                                              THEN RETURN 'UA' ; END IF;
     IF p_uom IN ( 'USTV','KUSTV', 'MUSTV')                                          THEN RETURN 'UV' ; END IF;
     IF p_uom IN ( 'BBLS', 'KBBLS', 'MBBLS')                                         THEN RETURN 'BI' ; END IF;
     IF p_uom IN ( 'BBLS15', 'KBBLS15', 'MBBLS15')                                   THEN RETURN 'BM' ; END IF;
     IF p_uom IN ( 'BOE', 'KBOE', 'MBOE')                                            THEN RETURN 'BE' ; END IF;
     IF p_uom IN ( 'MSCF', 'SCF','MSCF')                                             THEN RETURN 'SF' ; END IF;
     IF p_uom IN ( 'MNM3', 'NM3','KNM3')                                             THEN RETURN 'NM' ; END IF;
     IF p_uom IN ( 'MSM3', 'LTR','SM3','KSM3')                                       THEN RETURN 'SM' ; END IF;

     RETURN NULL; -- not defined


END GetSubGroupFromUOM;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetUOMSetQty
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : none
--
-- Using functions: none
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION GetUOMSetQty( -- returns the best match from input list
   ptab_uom_set  IN OUT t_uomtable,
   target_uom_code VARCHAR2,
   p_daytime DATE
   )
RETURN NUMBER
--<EC-DOC>

IS

i INTEGER;

ln_qty NUMBER;

lv2_target_sub_group VARCHAR2(32);

BEGIN

  IF ptab_uom_set.EXISTS(1) THEN

     -- first see if we have a corresponding UOM
     FOR i IN 1..ptab_uom_set.COUNT LOOP

          IF ptab_uom_set(i).uom = target_uom_code THEN

             -- found it !
             ln_qty := ptab_uom_set(i).qty;

             -- remove from array
             ptab_uom_set(i) := ptab_uom_set(ptab_uom_set.LAST);
             ptab_uom_set.DELETE(ptab_uom_set.LAST);
             ptab_uom_set.TRIM;

             EXIT;

          END IF;

     END LOOP;

     IF ln_qty IS NULL AND ptab_uom_set.EXISTS(1) THEN

         lv2_target_sub_group := GetUOMSubGroup(target_uom_code);

        -- then see if we can find a subgroup
         FOR i IN 1..ptab_uom_set.COUNT LOOP


             IF GetUOMSubGroup(ptab_uom_set(i).uom) = lv2_target_sub_group THEN

                 -- found it !
                 ln_qty := convertValue(ptab_uom_set(i).qty, ptab_uom_set(i).uom, target_uom_code, p_daytime);

                 -- remove from array
                 ptab_uom_set(i) := ptab_uom_set(ptab_uom_set.LAST);
                 ptab_uom_set.DELETE(ptab_uom_set.LAST);
                 ptab_uom_set.TRIM;

                 EXIT;

              END IF;

        END LOOP;

     END IF;

   END IF;

   -- still no hit, then perform attempt to convert by look-up in conversion table
   IF ln_qty IS NULL AND ptab_uom_set.EXISTS(1) THEN

         FOR i IN 1..ptab_uom_set.COUNT LOOP

             ln_qty := convertValue(ptab_uom_set(i).qty, ptab_uom_set(i).uom, target_uom_code, p_daytime);

             IF ln_qty IS NOT NULL THEN

               -- remove from array
               ptab_uom_set(i) := ptab_uom_set(ptab_uom_set.LAST);
               ptab_uom_set.DELETE(ptab_uom_set.LAST);
               ptab_uom_set.TRIM;

               EXIT;

             END IF;

         END LOOP;

   END IF;


   RETURN ln_qty;


END GetUOMSetQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GenQtyUOMSet                                                                 --
-- Description    :                                                                              --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE GenQtyUOMSet(
    ptab_uom_set IN OUT t_uomtable,
    p_qty1 NUMBER,
    p_uom1 VARCHAR2,
    p_qty2 NUMBER,
    p_uom2 VARCHAR2,
    p_qty3 NUMBER,
    p_uom3 VARCHAR2,
    p_qty4 NUMBER,
    p_uom4 VARCHAR2,
    p_qty5 NUMBER DEFAULT NULL,
    p_uom5 VARCHAR2 DEFAULT NULL,
    p_qty6 NUMBER DEFAULT NULL,
    p_uom6 VARCHAR2 DEFAULT NULL
)
--<EC-DOC>
IS
BEGIN

    IF p_qty1 IS NOT NULL AND p_uom1 IS NOT NULL THEN

       ptab_uom_set.EXTEND;
       ptab_uom_set(ptab_uom_set.LAST).qty := p_qty1;
       ptab_uom_set(ptab_uom_set.LAST).uom := p_uom1;

    END IF;

    IF p_qty2 IS NOT NULL AND p_uom2 IS NOT NULL THEN

       ptab_uom_set.EXTEND;
       ptab_uom_set(ptab_uom_set.LAST).qty := p_qty2;
       ptab_uom_set(ptab_uom_set.LAST).uom := p_uom2;

    END IF;

    IF p_qty3 IS NOT NULL AND p_uom3 IS NOT NULL THEN

       ptab_uom_set.EXTEND;
       ptab_uom_set(ptab_uom_set.LAST).qty := p_qty3;
       ptab_uom_set(ptab_uom_set.LAST).uom := p_uom3;

    END IF;

    IF p_qty4 IS NOT NULL AND p_uom4 IS NOT NULL THEN

       ptab_uom_set.EXTEND;
       ptab_uom_set(ptab_uom_set.LAST).qty := p_qty4;
       ptab_uom_set(ptab_uom_set.LAST).uom := p_uom4;

    END IF;

    IF p_qty5 IS NOT NULL AND p_uom5 IS NOT NULL THEN

       ptab_uom_set.EXTEND;
       ptab_uom_set(ptab_uom_set.LAST).qty := p_qty5;
       ptab_uom_set(ptab_uom_set.LAST).uom := p_uom5;

    END IF;

    IF p_qty6 IS NOT NULL AND p_uom6 IS NOT NULL THEN

       ptab_uom_set.EXTEND;
       ptab_uom_set(ptab_uom_set.LAST).qty := p_qty6;
       ptab_uom_set(ptab_uom_set.LAST).uom := p_uom6;

    END IF;
END GenQtyUOMSet;

/**
 * Normal Unit Conversion
 * -- Include inverse
 */
FUNCTION getDefaultConvFactor(p_from_unit VARCHAR2, p_to_unit VARCHAR2, p_daytime DATE)
RETURN t_unit_rec
IS

lrec_unit t_unit_rec;

CURSOR cDefConversion(cp_from_unit VARCHAR2, cp_to_unit VARCHAR2, cp_daytime DATE) IS
SELECT * FROM (
SELECT
   10 sort_order -- Sort inverse first to make normal become the last choice in the cursor
   ,icuc.from_unit to_unit
   ,icuc.to_unit from_unit
   ,icuc.mult_fact mult_fact
   ,icuc.add_numb
   ,icuc.precision
   ,icuc.use_ue
   ,icuc.user_exit
   ,'Y' inverse
FROM
    ctrl_unit_conversion icuc
WHERE
    icuc.from_unit = cp_to_unit -- INVERSE
    AND icuc.to_unit = cp_from_unit -- INVERSE
    AND icuc.daytime = (SELECT MAX(daytime) FROM ctrl_unit_conversion WHERE from_unit = icuc.from_unit AND to_unit = icuc.to_unit AND daytime <= cp_daytime)
UNION
SELECT
   20 sort_order -- Sort "normal" last
   ,cuc.from_unit
   ,cuc.to_unit
   ,cuc.mult_fact
   ,cuc.add_numb
   ,cuc.precision
   ,cuc.use_ue
   ,cuc.user_exit
   ,'N' inverse
FROM
    ctrl_unit_conversion cuc
WHERE
    cuc.from_unit = cp_from_unit
    AND cuc.to_unit = cp_to_unit
    AND cuc.daytime = (SELECT MAX(daytime) FROM ctrl_unit_conversion WHERE from_unit = cuc.from_unit AND to_unit = cuc.to_unit AND daytime <= cp_daytime)
)
ORDER BY sort_order ASC;

BEGIN
    lrec_unit.from_unit := NULL;
    lrec_unit.to_unit := NULL;

    FOR curDefConv IN cDefConversion(p_from_unit, p_to_unit, p_daytime) LOOP
        lrec_unit.from_unit := curDefConv.From_Unit;
        lrec_unit.to_unit := curDefConv.To_Unit;
        lrec_unit.mult_fact := curDefConv.Mult_Fact;
        lrec_unit.add_numb := curDefConv.add_numb;
        lrec_unit.precision := curDefConv.Precision;
        lrec_unit.prefix := NULL;
        lrec_unit.prefix_factor := NULL;
        lrec_unit.use_ue := curDefConv.use_ue;
        lrec_unit.user_exit := curDefConv.user_exit;
        lrec_unit.inverse := curDefConv.inverse;
    END LOOP;

    RETURN lrec_unit;

END getDefaultConvFactor;


/**
 * Object Based Unit Conversion
 * -- Include inverse
 * -- Fallback to normal conversion if object conversion not found
 */
FUNCTION getObjectConvFactor(p_from_unit VARCHAR2, p_to_unit VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_prefix_ind VARCHAR2 DEFAULT 'N')
RETURN t_unit_rec
IS

lrec_unit t_unit_rec;

CURSOR cObjConversion(cp_from_unit VARCHAR2, cp_to_unit VARCHAR2, cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT * FROM (
SELECT
   10 sort_order -- Sort inverse first to make normal become the last choice in the cursor
   ,icuoc.to_unit from_unit
   ,icuoc.from_unit to_unit
   ,icuoc.mult_fact mult_fact
   ,icuoc.add_numb
   ,icuoc.precision
   ,icuoc.use_ue
   ,icuoc.user_exit
   ,'Y' inverse
FROM
    ctrl_unit_obj_conversion icuoc
WHERE
    icuoc.from_unit = cp_to_unit -- INVERSE
    AND icuoc.to_unit = cp_from_unit -- INVERSE
    AND icuoc.object_id = cp_object_id
    AND icuoc.daytime = (SELECT MAX(daytime)
                         FROM ctrl_unit_obj_conversion
                         WHERE from_unit = icuoc.from_unit
                         AND to_unit = icuoc.to_unit
                         AND object_id = icuoc.object_id
                         AND daytime <= cp_daytime)
UNION
SELECT
   20 sort_order -- Sort "normal" last
   ,cuoc.from_unit
   ,cuoc.to_unit
   ,cuoc.mult_fact
   ,cuoc.add_numb
   ,cuoc.precision
   ,cuoc.use_ue
   ,cuoc.user_exit
   ,'N' inverse
FROM
    ctrl_unit_obj_conversion cuoc
WHERE
    cuoc.from_unit = cp_from_unit
    AND cuoc.to_unit = cp_to_unit
    AND cuoc.object_id = cp_object_id
    AND cuoc.daytime = (SELECT MAX(daytime)
                         FROM ctrl_unit_obj_conversion
                         WHERE from_unit = cuoc.from_unit
                         AND to_unit = cuoc.to_unit
                         AND object_id = cuoc.object_id
                         AND daytime <= cp_daytime)
)
ORDER BY sort_order ASC;

BEGIN
    lrec_unit.from_unit := NULL;
    lrec_unit.to_unit := NULL;

    IF (p_object_id IS NOT NULL) THEN
        FOR curObjConv IN cObjConversion(p_from_unit, p_to_unit, p_object_id, p_daytime) LOOP
            lrec_unit.from_unit := curObjConv.From_Unit;
            lrec_unit.to_unit := curObjConv.To_Unit;
            lrec_unit.mult_fact := curObjConv.Mult_Fact;
            lrec_unit.add_numb := curObjConv.add_numb;
            lrec_unit.precision := curObjConv.Precision;
            lrec_unit.prefix := NULL;
            lrec_unit.prefix_factor := NULL;
            lrec_unit.use_ue := curObjConv.Use_Ue;
            lrec_unit.user_exit := curObjConv.User_Exit;
            lrec_unit.inverse := curObjConv.inverse;
        END LOOP;
    END IF;

    -- First fallback to pefix conversion if object conversion not found
    IF (lrec_unit.from_unit IS NULL AND p_prefix_ind = 'N') THEN
        lrec_unit := getBaseUnitFactor(p_from_unit, p_to_unit, p_object_id, p_daytime);
    END IF;

    -- Fallback to "normal" conversion if object conversion not found
    IF (lrec_unit.from_unit IS NULL) THEN
        lrec_unit := getDefaultConvFactor(p_from_unit, p_to_unit, p_daytime);
    END IF;

    RETURN lrec_unit;

END getObjectConvFactor;

/**
 * Base Unit Conversion
 */
FUNCTION getBaseUnitFactor(p_from_unit VARCHAR2, p_to_unit VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN t_unit_rec
IS

lrec_from_unit t_unit_rec;
lrec_to_unit t_unit_rec;

lrec_unit t_unit_rec;

CURSOR cBaseUnit(cp_from_unit VARCHAR2, cp_to_unit VARCHAR2) IS
SELECT
    'FROM' conv_type
    ,cu.base_unit
    ,cu.prefix_factor
    ,cu.prefix
FROM
    ctrl_unit cu
WHERE
    cu.unit = cp_from_unit
    AND cu.base_unit IS NOT NULL
    AND cu.prefix_factor IS NOT NULL
UNION
SELECT
    'TO' conv_type
    ,cu.base_unit
    ,cu.prefix_factor
    ,cu.prefix
FROM
    ctrl_unit cu
WHERE
    cu.unit = cp_to_unit
    AND cu.base_unit IS NOT NULL
    AND cu.prefix_factor IS NOT NULL
;

BEGIN
    lrec_from_unit.from_unit := NULL;
    lrec_from_unit.to_unit := NULL;
    lrec_to_unit.from_unit := NULL;
    lrec_to_unit.to_unit := NULL;

    lrec_unit.from_unit := NULL;
    lrec_unit.to_unit := NULL;
    lrec_unit.prefix_factor := NULL;

    FOR curBase IN cBaseUnit(p_from_unit, p_to_unit) LOOP
        IF (curBase.conv_type = 'FROM') THEN
            lrec_from_unit.from_unit := p_from_unit;
            lrec_from_unit.to_unit := curBase.Base_Unit;
            lrec_from_unit.prefix := curBase.Prefix;
            lrec_from_unit.prefix_factor := curBase.prefix_factor;
        END IF;

        IF (curBase.conv_type = 'TO') THEN
            lrec_to_unit.from_unit := p_to_unit;
            lrec_to_unit.to_unit := curBase.Base_Unit;
            lrec_to_unit.prefix := curBase.Prefix;
            lrec_to_unit.prefix_factor := curBase.prefix_factor;
        END IF;

    END LOOP;


    -- Use base unit on From side
    IF (lrec_from_unit.from_unit IS NOT NULL) THEN
        lrec_unit := getObjectConvFactor(lrec_from_unit.to_unit, p_to_unit, p_object_id, p_daytime, 'Y');
        lrec_unit.prefix := lrec_from_unit.prefix;
        lrec_unit.prefix_factor := 1 / lrec_from_unit.prefix_factor;
    END IF;

    -- Use base unit on To side
    IF (lrec_unit.from_unit IS NULL AND lrec_to_unit.from_unit IS NOT NULL) THEN
        lrec_unit := getObjectConvFactor(p_from_unit, lrec_to_unit.to_unit, p_object_id, p_daytime, 'Y');
        lrec_unit.prefix := lrec_to_unit.prefix;
        lrec_unit.prefix_factor := lrec_to_unit.prefix_factor;
    END IF;

    -- Use base unit on Both sides
    IF (lrec_unit.from_unit IS NULL AND lrec_from_unit.from_unit IS NOT NULL AND lrec_to_unit.from_unit IS NOT NULL) THEN
        lrec_unit := getObjectConvFactor(lrec_from_unit.to_unit, lrec_to_unit.from_unit, p_object_id, p_daytime, 'Y');
        lrec_unit.prefix := NULL;
        lrec_unit.prefix_factor := (1 / lrec_from_unit.prefix_factor) * lrec_to_unit.prefix_factor;
    END IF;

    RETURN lrec_unit;

END getBaseUnitFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : convertValue                                                                 --
-- Description    : returns a converted value based on factors in ctrl_unit_conversion.          --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : ctrl_unit_conversion                                                         --
--                                                                                               --
-- Using functions: ec_ctrl_unit_conversion                                                      --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION convertValue(p_input_val NUMBER
                      ,p_from_unit VARCHAR2
                      ,p_to_unit   VARCHAR2
                      ,p_daytime   DATE DEFAULT NULL
                      ,p_precision   NUMBER DEFAULT NULL
                      ,p_via_group VARCHAR2 DEFAULT 'N'
                      ,p_supress_error VARCHAR2 DEFAULT 'N'
                      ,p_source_object_id_1 VARCHAR2 DEFAULT NULL -- Infrastructure ID 1, can be left NULL for general conversion
                      ,p_source_object_id_2 VARCHAR2 DEFAULT NULL -- Infrastructure ID 2, fallback if not hit on no 1
                      ,p_source_object_id_3 VARCHAR2 DEFAULT NULL -- Infrastructure ID 3, fallback if not hit on no 2
                      ,p_source_object_id_4 VARCHAR2 DEFAULT NULL -- Infrastructure ID 4, fallback if not hit on no 3
                      ,p_source_object_id_5 VARCHAR2 DEFAULT NULL -- Infrastructure ID 5, fallback if not hit on no 4
                      )
RETURN NUMBER
 --</EC-DOC>
IS

lv_object_id VARCHAR2(32);
lrec_unit t_unit_rec;
ln_return_val NUMBER;
ld_daytime DATE;
lv_sql VARCHAR2(400);
lv_daytime VARCHAR2(25);
ln_precision NUMBER;

BEGIN
    ln_return_val := NULL;
    lrec_unit.from_unit := NULL;
    lrec_unit.to_unit := NULL;
    lrec_unit.prefix_factor := NULL;
    lv_object_id := NULL;
    lv_object_id := nvl(p_source_object_id_1,nvl(p_source_object_id_2,nvl(p_source_object_id_3,nvl(p_source_object_id_4,p_source_object_id_5))));

    ld_daytime := p_daytime;
    IF ld_daytime IS NULL THEN
        ld_daytime := sysdate;
    END IF;

    IF p_from_unit = p_to_unit THEN
      ln_return_val := p_input_val;
    ELSE
      IF (lv_object_id IS NULL) THEN -- Conversion without any object
          lrec_unit := getDefaultConvFactor(p_from_unit, p_to_unit, ld_daytime);

          IF (lrec_unit.from_unit IS NULL) THEN -- Try via base unit if normal conversion not found
              lrec_unit := getBaseUnitFactor(p_from_unit, p_to_unit, NULL, ld_daytime);
          END IF;

      ELSE -- Object Based conversion
          lrec_unit := getObjectConvFactor(p_from_unit, p_to_unit, lv_object_id, ld_daytime);

          IF (lrec_unit.from_unit IS NULL) THEN -- Try via base unit if normal conversion not found
              lrec_unit := getBaseUnitFactor(p_from_unit, p_to_unit, lv_object_id, ld_daytime);
          END IF;
      END IF;
      IF (lrec_unit.use_ue = 'Y') THEN

        IF ld_daytime IS NOT NULL THEN
           lv_daytime := to_char(ld_daytime,'YYYY-MM-DD"T"HH24:mi:ss');
        ELSE
           lv_daytime := '''''';
        END IF;
        IF p_precision IS NOT NULL THEN
          ln_precision := p_precision;
        ELSIF lrec_unit.precision IS NOT NULL THEN
          ln_precision := lrec_unit.precision;
        ELSE
          ln_precision := NULL;
        END IF;

        ln_return_val := UE_UOM.CONVERT(p_from_unit, p_to_unit, p_input_val, p_precision, lv_object_id, lv_daytime);

      ELSE
        IF(lrec_unit.inverse = 'Y') THEN
        ln_return_val := (p_input_val - NVL(lrec_unit.add_numb,0))/lrec_unit.mult_fact;
        ELSE
        ln_return_val := p_input_val * lrec_unit.mult_fact + NVL(lrec_unit.add_numb, 0);
        END IF;

        IF (lrec_unit.prefix_factor IS NOT NULL) THEN
            ln_return_val := ln_return_val * lrec_unit.prefix_factor;
        END IF;

        IF p_precision IS NOT NULL THEN
            ln_return_val := ROUND(ln_return_val, p_precision);
        ELSIF lrec_unit.precision IS NOT NULL THEN
            ln_return_val := ROUND(ln_return_val, lrec_unit.precision);
        END IF;
      END IF;
    END IF;

    RETURN ln_return_val;

END convertValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetUnitFromLogical                                                           --
-- Description    : returns a unit based on the logical unit							         --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : ctrl_unit_combination                                                        --
--                                                                                               --
-- Using functions: 					                                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION GetUnitFromLogical(p_measurement_type VARCHAR2) RETURN VARCHAR2
IS

	CURSOR cur_uom_setup IS
	SELECT unit
	FROM ctrl_uom_setup
	WHERE measurement_type = p_measurement_type
	and db_unit_ind = 'Y';

	lv2_unit VARCHAR2(16);

BEGIN
 	FOR unit IN cur_uom_setup LOOP
	 	lv2_unit := unit.unit;
	END LOOP;

   IF lv2_unit IS NULL THEN
   	RETURN p_measurement_type;
   ELSE
      RETURN lv2_unit;
   END IF;

END GetUnitFromLogical;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetViewUnitFromLogical                                                           --
-- Description    : returns a unit based on the logical unit							         --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : ctrl_unit_combination                                                        --
--                                                                                               --
-- Using functions: 					                                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION GetViewUnitFromLogical(p_measurement_type VARCHAR2) RETURN VARCHAR2
IS

	CURSOR cur_uom_setup IS
	SELECT unit
	FROM ctrl_uom_setup
	WHERE measurement_type = p_measurement_type
	and view_unit_ind = 'Y';

	lv2_unit VARCHAR2(16);

BEGIN
 	FOR unit IN cur_uom_setup LOOP
	 	lv2_unit := unit.unit;
	END LOOP;

   IF lv2_unit IS NULL THEN
   	RETURN p_measurement_type;
   ELSE
      RETURN lv2_unit;
   END IF;

END GetViewUnitFromLogical;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetUnitLabel                                                                 --
-- Description    : returns a labe for a unit 											         --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : ctrl_unit			                                                        --
--                                                                                               --
-- Using functions: 					                                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION GetUnitLabel(p_unit VARCHAR2) RETURN VARCHAR2
IS

	CURSOR cur_unit IS
	SELECT label
	FROM CTRL_UNIT
	WHERE unit = p_unit;

	lv2_label VARCHAR2(16);

BEGIN
 	FOR unit IN cur_unit LOOP
	 	lv2_label := unit.label;
	END LOOP;

   IF lv2_label IS NULL THEN
   	RETURN p_unit;
   ELSE
      RETURN lv2_label;
   END IF;

END GetUnitLabel;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetViewFormatMask
-- Description    : returns a viewformatmask for a unit
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : ctrl_measurement_type
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Check whether p_static_pres_syntax contains a viewformatmask-string, if so empty string will be returned, if not
--						  the defined format_mask in ctrl_uom_setup or ctrl_measurement_type will be returned
--
---------------------------------------------------------------------------------------------------
FUNCTION GetViewFormatMask(p_uom_code	VARCHAR2,
									p_static_pres_syntax	VARCHAR2)
RETURN VARCHAR2

IS

	CURSOR c_format_mask IS
	 SELECT u.unit, u.measurement_type, u.format_mask unit_format_mask, m.format_mask
	 FROM ctrl_uom_setup u, ctrl_measurement_type m
	 WHERE u.measurement_type = m.measurement_type
    AND m.measurement_type = p_uom_code
    AND u.view_unit_ind = 'Y';

	lv2_format_mask		VARCHAR2(1000);

BEGIN

	IF INSTR(LOWER(p_static_pres_syntax),'viewformatmask') > 0 THEN
		lv2_format_mask := '';
	ELSE

		FOR curFormatMask IN c_format_mask LOOP

			lv2_format_mask := Nvl(curFormatMask.unit_format_mask,curFormatMask.format_mask);

			IF lv2_format_mask IS NOT NULL THEN

				lv2_format_mask := 'viewformatmask='||lv2_format_mask||';';

			END IF;

		END LOOP;

	END IF;

	RETURN lv2_format_mask;

END GetViewFormatMask;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetRevnViewFormatMask
-- Description    : returns a viewformatmask for a unit
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : ctrl_measurement_type
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Check whether p_static_pres_syntax contains a viewformatmask-string, if so empty string will be returned, if not
--
---------------------------------------------------------------------------------------------------
FUNCTION GetRevnViewFormatMask(p_measurement_type VARCHAR2,p_uom_code	VARCHAR2)
RETURN VARCHAR2

IS

  CURSOR c_mask(cp_measurement_type VARCHAR2,cp_uom_code	VARCHAR2) IS
  SELECT
       format_mask
  FROM
       ctrl_uom_setup
  WHERE
       measurement_type = cp_measurement_type
   and unit = cp_uom_code
   and format_mask is not null
  UNION ALL
  SELECT
       format_mask
  FROM
       ctrl_measurement_type
  WHERE
       measurement_type = cp_measurement_type
  ;

BEGIN

  FOR r_mask IN c_mask(p_measurement_type, p_uom_code) LOOP
      return 'viewformatmask='|| r_mask.format_mask || ';';
  END LOOP;

  return '';

END GetRevnViewFormatMask;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getBaseUnitPrefFactor                                                                 --
-- Description    : returns a based unit pref factor 											         --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : ctrl_unit			                                                        --
--                                                                                               --
-- Using functions: 					                                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getBaseUnitPrefFactor(p_unit VARCHAR2, p_base_unit VARCHAR2)
RETURN NUMBER
IS

	CURSOR cur_unit IS
	SELECT cu.prefix_factor
	FROM CTRL_UNIT cu
	WHERE cu.unit = p_unit
  AND cu.base_unit = p_base_unit;

	ln_prefix_factor NUMBER;

BEGIN
 	FOR unit IN cur_unit LOOP
	  ln_prefix_factor := unit.prefix_factor;
	END LOOP;
  RETURN ln_prefix_factor;
END getBaseUnitPrefFactor;


END EcDp_Unit;