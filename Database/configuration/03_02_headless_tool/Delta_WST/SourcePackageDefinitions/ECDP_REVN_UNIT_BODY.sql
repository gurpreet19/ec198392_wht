CREATE OR REPLACE PACKAGE BODY EcDp_Revn_Unit IS
/***************************************************************************************
** Package	:  EcDp_Revn_Unit
**
** $Revision: 1.6 $
**
**
** Purpose	:  Functions used to convert to either other units or fractions for EC Revenue
**
** General Logic:
**
** Modification history:
**
** Date:     Whom	Change description:
** yyyymmdd
** --------  ---- ----------------------------------------------------------------------
** 20070112 SRA  Initial version
****************************************************************************************
*/


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
FUNCTION convertValue(p_input_val NUMBER,
                      p_from_unit VARCHAR2,
                      p_to_unit   VARCHAR2,
                      p_object_id VARCHAR2, -- The object_id to get the BOE factor from
                      p_daytime   DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

	IF p_from_unit = p_to_unit THEN

		RETURN p_input_val; -- no conversion required

  ELSE

    IF (p_to_unit LIKE '%BOE') AND (p_from_unit NOT LIKE '%BOE') THEN

      ln_return_val := boe_convert(p_input_val, p_from_unit, p_to_unit, p_daytime, p_object_id);

    ELSE

    -- Standard conversion

    ln_return_val := EcDp_Unit.convertValue(p_input_val,
                                            p_from_unit,
                                            p_to_unit,
                                            p_daytime,
                                            p_source_object_id_1 => p_object_id);


    END IF;

	END IF;

	RETURN ln_return_val;

END convertValue;

FUNCTION boe_convert(p_input_val      NUMBER,
                     p_from_unit      VARCHAR2,
                     p_to_unit        VARCHAR2,
                     p_daytime        DATE,
                     p_stream_item_id VARCHAR2,
                     p_boe_from_uom   VARCHAR2 DEFAULT NULL,
                     p_boe_factor     NUMBER DEFAULT NULL)
RETURN NUMBER
IS

ln_return_val NUMBER;
lv2_boe_from_unit VARCHAR2(32);
ln_boe_factor VARCHAR2(32);
ln_source_val  NUMBER;
l_ConvFact ecdp_stream_item.t_conversion;

BEGIN
    IF p_boe_from_uom IS NULL OR p_boe_factor IS NULL THEN

      l_ConvFact := ecdp_stream_item.getdefBOE(p_stream_item_id,p_daytime);
      lv2_boe_from_unit := l_ConvFact.from_uom;
      ln_boe_factor := l_ConvFact.factor;

    ELSE

        lv2_boe_from_unit := p_boe_from_uom;
        ln_boe_factor := p_boe_factor;

    END IF;

    ln_source_val := Ecdp_Unit.convertValue(p_input_val, p_from_unit, lv2_boe_from_unit, p_daytime);

    ln_return_val := ln_source_val * ln_boe_factor;

    IF (p_to_unit <> 'BOE') THEN
        ln_return_val := Ecdp_Unit.convertValue(ln_return_val, 'BOE', p_to_unit, p_daytime);
    END IF;

    RETURN ln_return_val;

END boe_convert;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : BOEInvert                                                                 --
-- Description    : Takes the BOE value as input assumed to be represented in any unit of subgroup BE
--                  The function will return this number represented in the BOE from unit UOM.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :

---------------------------------------------------------------------------------------------------
FUNCTION BOEInvert(p_input_val      NUMBER,
                   p_boe_to_uom     VARCHAR2,
                   p_daytime        DATE,
                   p_stream_item_id VARCHAR2,
                   p_boe_from_uom   VARCHAR2 DEFAULT NULL,
                   p_boe_factor     NUMBER DEFAULT NULL)
RETURN NUMBER
IS

ln_return_val      NUMBER;
ln_boe_val         NUMBER;
lv2_boe_from_unit  VARCHAR2(32);
ln_boe_factor      VARCHAR2(32);
l_ConvFact         ecdp_stream_item.t_conversion;

BEGIN
    -- Pick up factor and uom from config if not passed as arguments
    IF p_boe_from_uom IS NULL OR p_boe_factor IS NULL THEN
      l_ConvFact := ecdp_stream_item.getdefBOE(p_stream_item_id,p_daytime);
      lv2_boe_from_unit := l_ConvFact.from_uom;
      ln_boe_factor := l_ConvFact.factor;
    ELSE
        lv2_boe_from_unit := p_boe_from_uom;
        ln_boe_factor := p_boe_factor;
    END IF;


    -- Need the input value represented in standard BOE unit
    IF (p_boe_to_uom <> 'BOE') THEN
        ln_boe_val := Ecdp_Unit.convertValue(p_input_val,p_boe_to_uom,'BOE',p_daytime);
     ELSE
     ln_boe_val := p_input_val;
    END IF;

    BEGIN



        ln_return_val := ln_boe_val * (1/ln_boe_factor);

    EXCEPTION

          WHEN ZERO_DIVIDE THEN
             ln_return_val := 0; -- unknown
         END;



    RETURN ln_return_val;


END BOEInvert;


FUNCTION GetUOMSetQty( -- returns the best match from input list
   ptab_uom_set  IN OUT EcDp_Unit.t_uomtable,
   target_uom_code VARCHAR2,
   p_daytime DATE,
   p_object_id VARCHAR2,
   p_do_delete BOOLEAN DEFAULT TRUE
   )

RETURN NUMBER

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


             IF (p_do_delete) THEN
                 -- remove from array
                 ptab_uom_set(i) := ptab_uom_set(ptab_uom_set.LAST);
                 ptab_uom_set.DELETE(ptab_uom_set.LAST);
                 ptab_uom_set.TRIM;
             END IF;

             EXIT;

          END IF;

     END LOOP;

     IF ln_qty IS NULL AND ptab_uom_set.EXISTS(1) THEN

         lv2_target_sub_group := Ecdp_Unit.GetUOMSubGroup(target_uom_code);

        -- then see if we can find a subgroup
         FOR i IN 1..ptab_uom_set.COUNT LOOP


             IF Ecdp_Unit.GetUOMSubGroup(ptab_uom_set(i).uom) = lv2_target_sub_group THEN

                 -- found it !
                 ln_qty := convertValue(ptab_uom_set(i).qty,ptab_uom_set(i).uom,target_uom_code,p_object_id,p_daytime);

                 IF (p_do_delete) THEN
                     -- remove from array
                     ptab_uom_set(i) := ptab_uom_set(ptab_uom_set.LAST);
                     ptab_uom_set.DELETE(ptab_uom_set.LAST);
                     ptab_uom_set.TRIM;
                 END IF;

                 EXIT;

              END IF;

        END LOOP;

     END IF;

   END IF;

   -- still no hit, then perform attempt to convert by look-up in conversion table
   IF ln_qty IS NULL AND ptab_uom_set.EXISTS(1) THEN

         FOR i IN 1..ptab_uom_set.COUNT LOOP

             ln_qty := convertValue(ptab_uom_set(i).qty,ptab_uom_set(i).uom,target_uom_code,p_object_id,p_daytime);

             IF ln_qty IS NOT NULL THEN

               IF (p_do_delete) THEN
                   -- remove from array
                   ptab_uom_set(i) := ptab_uom_set(ptab_uom_set.LAST);
                   ptab_uom_set.DELETE(ptab_uom_set.LAST);
                   ptab_uom_set.TRIM;
               END IF;

               EXIT;

             END IF;

         END LOOP;

   END IF;


   RETURN ln_qty;


END GetUOMSetQty;

-------------------------------------------------------------------------------------------------
-- Function       : getUnitLabel
-- Description    : Returns the name of the currency or the label of the unit. If name/label is NULL then it returns the p_unit input parameter.
--                  NB! Currency units MUST be given with the currency OBJECT_ID. E.g: ec_currency.object_id_by_uk(PRICING_CURR_CODE).
--                  Default value for daytime is CurrentSysdate.
-------------------------------------------------------------------------------------------------
FUNCTION getUnitLabel(
    p_unit      VARCHAR2,
    p_daytime   DATE DEFAULT NULL)
RETURN VARCHAR2
IS
    CURSOR c_curr_unit(c_curr_unit_id VARCHAR2, c_daytime DATE) IS
    SELECT *
      FROM v_curr_unit
     WHERE curr_unit_id = c_curr_unit_id
       AND c_daytime >= daytime
       AND c_daytime < nvl(end_date, c_daytime + 1);

    lv_daytime      DATE;
    lv_unit_name    VARCHAR2(240);
BEGIN
    lv_daytime := NVL(p_daytime, ecdp_timestamp.getCurrentSysdate);
    FOR c_rec IN c_curr_unit(p_unit, lv_daytime) LOOP
      lv_unit_name := NVL(c_rec.name, c_rec.code);
    END LOOP;

    RETURN NVL(lv_unit_name, p_unit); -- The NVL is handling FREE_UNIT situations.
END getUnitLabel;

-------------------------------------------------------------------------------------------------
-- Function       : getCombinedUnitCodes/Labels
-- Description    : Returns a combined string of UOM and Currency codes with a divider e.g: EUR/Kg
--                  NB! Currency units MUST be given with the currency OBJECT_ID. E.g: ec_currency.object_id_by_uk(PRICING_CURR_CODE)
--                  Both p_unit1, p_operator must be non-NULL else NULL will be returned.
--                  One of p_unit2 or p_unit2_alternative must be non-NULL else NULL will be returned.
--                  Check2 must be TRUE to use p_unit2, if not p_unit2_alternative will be used.
--                  Valid operators: '=' | '<>'
--                  Turn of the checking by setting the operator to NULL.
--                  For FREE_UNITs the code will be used if no name/label are found for the given code.
-------------------------------------------------------------------------------------------------
FUNCTION getCombinedUnitLabels(
    p_unit1             VARCHAR2,
    p_unit2             VARCHAR2,
    p_divider           VARCHAR2,
    p_prefix            VARCHAR2 DEFAULT NULL,
    p_postfix           VARCHAR2 DEFAULT NULL,
    p_check2_value1     VARCHAR2 DEFAULT NULL,
    p_check2_value2     VARCHAR2 DEFAULT NULL,
    p_check2_operator   VARCHAR2 DEFAULT NULL,
    p_unit2_alternative VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
    lv_unit1_lbl        VARCHAR2(100);
    lv_unit2_lbl        VARCHAR2(100);
    lv_unit2_lbl_alt    VARCHAR2(100);
    lv_combined         VARCHAR2(240);
BEGIN
    lv_unit1_lbl     := getUnitLabel(p_unit1);
    lv_unit2_lbl     := getUnitLabel(p_unit2);
    lv_unit2_lbl_alt := getUnitLabel(p_unit2_alternative);
    lv_combined      := getCombinedUnitCodes(lv_unit1_lbl, lv_unit2_lbl, p_divider, p_prefix, p_postfix, p_check2_value1, p_check2_value2, p_check2_operator, lv_unit2_lbl_alt);

    RETURN lv_combined;
END getCombinedUnitLabels;
-------------------------------------------------------------------------------------------------
FUNCTION getCombinedUnitCodes(
    p_unit1             VARCHAR2,
    p_unit2             VARCHAR2,
    p_divider           VARCHAR2,
    p_prefix            VARCHAR2 DEFAULT NULL,
    p_postfix           VARCHAR2 DEFAULT NULL,
    p_check2_value1     VARCHAR2 DEFAULT NULL,
    p_check2_value2     VARCHAR2 DEFAULT NULL,
    p_check2_operator   VARCHAR2 DEFAULT NULL,
    p_unit2_alternative VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
    lv_combined         VARCHAR(240);
    lv_unit2            VARCHAR(100);
    invalid_operator    EXCEPTION;
BEGIN
    -- Qualify fixed input parameters
    IF (p_unit1 IS NULL OR p_divider IS NULL) THEN
        RETURN NULL;
    END IF;

    -- Perform checking and processing of unit2
    IF (p_check2_operator = '=') THEN
        IF (p_check2_value1 = p_check2_value2) THEN
            lv_unit2 := p_unit2;
        ELSE
            lv_unit2 := p_unit2_alternative;
        END IF;
    ELSIF (p_check2_operator = '<>') THEN
        IF (p_check2_value1 <> p_check2_value2) THEN
            lv_unit2 := p_unit2;
        ELSE
            lv_unit2 := p_unit2_alternative;
        END IF;
    ELSIF (p_check2_operator IS NOT NULL) THEN
        RAISE invalid_operator;
    ELSE
        lv_unit2 := p_unit2;
    END IF;

    -- Build - return blank if unit2 is NULL
    IF (lv_unit2 IS NOT NULL) THEN
        lv_combined := p_prefix || p_unit1 || p_divider || lv_unit2 || p_postfix;
    END IF;

    RETURN lv_combined;
EXCEPTION
    WHEN invalid_operator THEN
        Raise_Application_Error(-20000,'Invalid operator: ' || p_check2_operator);
END getCombinedUnitCodes;

-------------------------------------------------------------------------------------------------
-- Function       : getPricingCurrencyIdIfUnique
-- Description    : Returns the currency id for Pricing Currency at Document level.
--                  It will return the id ONLY if there is a single/common Pricing Currency within
--                  the Document. If several different Pricing Currencies are in use NULL will
--                  be returned.
-- References     : The logic used is the same as in EcDp_Transaction.GetSumTransPricingValue
-------------------------------------------------------------------------------------------------
FUNCTION getPricingCurrencyIdIfUnique(
    p_document_key  VARCHAR2)
RETURN VARCHAR2
IS

CURSOR c_count(cp_document_key VARCHAR2) IS
SELECT count(*) AS NUM
FROM (SELECT distinct ct.pricing_currency_id, ct.document_key
        FROM cont_transaction ct
       WHERE ct.document_key = p_document_key
);

CURSOR c_id(cp_document_key VARCHAR2) IS
SELECT DISTINCT(pricing_currency_id) currency_id
  FROM cont_transaction ct
 WHERE ct.document_key = p_document_key
;

BEGIN
    FOR rec IN c_count(p_document_key) LOOP
        IF rec.NUM = 1 THEN
            FOR rec2 IN c_id(p_document_key) LOOP
                RETURN rec2.currency_id;
            END LOOP;
        ELSE
            RETURN NULL;
        END IF;
    END LOOP;
END getPricingCurrencyIdIfUnique;

END EcDp_Revn_Unit;