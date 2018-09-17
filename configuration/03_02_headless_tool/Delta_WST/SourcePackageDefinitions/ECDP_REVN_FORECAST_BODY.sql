CREATE OR REPLACE PACKAGE BODY EcDp_Revn_Forecast IS
/**************************************************************
** Package        :  EcDp_Revn_Forecast, body part
**
** $Revision: 1.62 $
**
**
** Purpose  :  Forecast functionality
**
** General Logic:
**
** Modification history:
**
** Date:       Whom  Change description:
** ----------  ----  --------------------------------------------
** 09.01.2007  Kheng   Initial version
** 10.01.2007  Lau     Modified procedure PopulateQtyFcst
** 10.01.2007  DN      Renamed swap_adj_ind to swap_adj_type and commercial_adj_ind to commercial_adj_type.
** 12.01.2007  Lau     Added procedure verifyQtyFcst,approveQtyFcst and unapproveQtyFcst
** 15.01.2007  Lau     Modified procedure PopulateQtyFcst and InstantiateQtyFcst
** 15.01.2007  DN      Function copyFcstObj: Renamed stream_item_id to cpy_adj_stream_item_id.
** 16.01.2007  Jerome  Added functions getNumDaysInYear, getSumProductMthByField, getSumAllProductMthByField, getSumProductYrByField and getSumAllProductYrByField
** 16.01.2007  Lau     Modified procedure PopulateQtyFcst and InstantiateQtyFcst
** 17.01.2007  Lau     Added functions getStatus and getAllStatus
** 17.01.2007  Kheng   Updated validateInsUpd - delete all FCST_MTH_STATUS and also update plan date while start date changed
** 17.01.2007  Jerome  Added functions getStreamItemStatus and getAllStreamItemStatus
** 18.01.2007  Jerome  Added function getMemberNo
** 19.01.2007  Jerome  Modified function getMemberNo and getStreamItemStatus
** 19.01.2007  Lau     Modified functions getStatus,getAllStatus,verifyQtyFcst,approveQtyFcst and unapproveQtyFcst and added function chkStreamItem
** 19.01.2007  Kheng   Updated validateInsUpd, check againts referred qty forecast
** 19.01.2007  DN      Replaced ov_forecast with underlaying tables.
** 11.05.2007  Jerome  Modified copyFcstObj to copy forex source id and forex time scope (ECPD 4950)
** 18.05.2007  Jerome  Modified getConvertedValue to take into account missing fcst_mth_status.status value
** 11.04.2008  SSK     Modified getInventoryClosingPos to use inventory SI for UOM conversion rather than FCST SI
**************************************************************/



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   getSumPriceElements
-- Description    :  Return base price for revenue forecast case with method plan
--                   The most recent price prior to or equal daytime will be used
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getSumPriceElements(p_object_id               VARCHAR2, -- Forecast object_id
                             p_product_id              VARCHAR2,
                             p_product_context         VARCHAR2,
                             p_product_collection_type VARCHAR2,
                             p_daytime                 DATE)
--</EC-DOC>
RETURN t_revn_price_rec

IS

ln_price_elm_val            NUMBER := 0;
lv_general_price_id         VARCHAR2(32);
lv_price_concept_code       VARCHAR2(32);
lv_uom                      VARCHAR2(32);
lv_product_uom              VARCHAR2(32);
lv_stream_item_id           VARCHAR2(32);

lv_general_price_2_id         VARCHAR2(32);
lv_price_concept_code_2       VARCHAR2(32);
ln_price_elm_val_2            NUMBER := 0;
lv_uom_2                      VARCHAR2(32);

lrec_price t_revn_price_rec;

CURSOR c_pr_elm_val (cp_general_price_id VARCHAR2, cp_price_concept_code VARCHAR2, cp_daytime DATE)
IS
   SELECT nvl(ec_product_price_value.adj_price_value(cp_general_price_id,
                                                     cp_price_concept_code,
                                                     ppv.price_element_code,
                                                     cp_daytime,
                                                     '<='),
              ec_product_price_value.calc_price_value(cp_general_price_id,
                                                      cp_price_concept_code,
                                                      ppv.price_element_code,
                                                      cp_daytime,
                                                      '<=')) pr_elm_val,
              ec_product_price_version.uom(cp_general_price_id, cp_daytime,'<=') uom
     FROM product_price_value ppv
    WHERE ppv.object_id = cp_general_price_id
      AND ppv.price_concept_code = cp_price_concept_code
      AND ppv.daytime = (SELECT max(p.daytime)
                       FROM product_price_value p
                      WHERE p.object_id = cp_general_price_id
                        AND p.price_concept_code = cp_price_concept_code
                        AND daytime <= cp_daytime);

CURSOR c_si IS
SELECT fm.stream_item_id
FROM fcst_member fm
WHERE fm.object_id = p_object_id
AND fm.product_id = p_product_id
AND fm.product_context = p_product_context
AND fm.product_collection_type = p_product_collection_type
;


BEGIN

    lv_general_price_id := ec_fcst_product_setup.product_price_id(p_object_id,
                                                                  p_product_id,
                                                                  p_product_context,
                                                                  p_product_collection_type);

    lv_price_concept_code := ec_product_price.price_concept_code(lv_general_price_id);

    lv_general_price_2_id := ec_fcst_product_setup.text_4(p_object_id,
                                                                  p_product_id,
                                                                  p_product_context,
                                                                  p_product_collection_type);

    lv_price_concept_code_2 := ec_product_price.price_concept_code(lv_general_price_2_id);


     -- Summing up al price values on the price elements that are present on the price concept on the cchosen price object
     -- Value is put into fcst_mth_status.base_price.
    FOR c_pr_val IN c_pr_elm_val (lv_general_price_id, lv_price_concept_code, p_daytime) LOOP

        ln_price_elm_val := ln_price_elm_val + nvl(c_pr_val.pr_elm_val,0);
        lv_uom := c_pr_val.uom;

    END LOOP;

     -- Summing up al price values on the price elements that are present on the price concept on the cchosen price object
     -- Value is put into fcst_mth_status.base_price.
    FOR c_pr_val_2 IN c_pr_elm_val(lv_general_price_2_id, lv_price_concept_code_2, p_daytime) LOOP

        ln_price_elm_val_2 := ln_price_elm_val_2 + nvl(c_pr_val_2.pr_elm_val,0);
        lv_uom_2 := c_pr_val_2.uom;

    END LOOP;


    lv_product_uom := ec_fcst_product_setup.product_uom(p_object_id, p_product_id, p_product_context, p_product_collection_type);

    -- Find Stream Item in use
    FOR curSi IN c_si LOOP
        lv_stream_item_id := curSi.Stream_Item_Id;
    END LOOP;

    -- currency conversion
    ln_price_elm_val  := ecdp_currency.convertViaCurrency(ln_price_elm_val,
                                                      ec_product_price_version.currency_id(lv_general_price_id,p_daytime,'<='),
                                                      ec_fcst_product_setup.currency_id(p_object_id,p_product_id,p_product_context,p_product_collection_type),
                                                      null,
                                                      p_daytime,
                                                      ec_forecast_version.forex_source_id(p_object_id, p_daytime, '<='),
                                                      ec_forecast_version.time_scope(p_object_id, p_daytime, '<='));

    -- currency conversion
    ln_price_elm_val_2  := ecdp_currency.convertViaCurrency(ln_price_elm_val_2,
                                                      ec_product_price_version.currency_id(lv_general_price_2_id,p_daytime,'<='),
                                                      ec_fcst_product_setup.currency_id(p_object_id,p_product_id,p_product_context,p_product_collection_type),
                                                      null,
                                                      p_daytime,
                                                      ec_forecast_version.forex_source_id(p_object_id, p_daytime, '<='),
                                                      ec_forecast_version.time_scope(p_object_id, p_daytime, '<='));

    -- Do Unit Conversion as well
    ln_price_elm_val  := ecdp_revn_unit.convertValue(ln_price_elm_val, lv_uom, lv_product_uom, lv_stream_item_id, p_daytime);

    -- Do Unit Conversion as well
    ln_price_elm_val_2  := ecdp_revn_unit.convertValue(ln_price_elm_val_2, lv_uom, lv_product_uom, lv_stream_item_id, p_daytime);

    lrec_price.term_price := ln_price_elm_val;
    lrec_price.spot_price := ln_price_elm_val_2;

    RETURN lrec_price;

END getSumPriceElements;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   getSaleQty
-- Description    :  Return base price for revenue forecast case with method plan
--                :  If Contract Term Code is not passed as argument, then this is not considered.
--                :  Else, the contract found on the line item must match this criteria.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getSaleQty(p_forecast_id VARCHAR2,
                    p_stream_item_id VARCHAR2,
                    p_to_uom         VARCHAR2,
                    p_daytime        DATE,
                    p_prod_coll_type VARCHAR2,
                    p_cntr_term_code VARCHAR2 DEFAULT NULL) -- SPOT/TERM/NULL)
  --</EC-DOC>
RETURN NUMBER

IS

ltab_uom_set ecdp_unit.t_UOMTable := EcDp_Unit.t_uomtable();
ln_result                   NUMBER;



CURSOR c_li_dist (cp_stream_item_id VARCHAR2, cp_daytime DATE, cp_plan_date DATE, cp_prod_coll_type VARCHAR2, cp_cntr_term_code VARCHAR2) IS
SELECT c.qty1,c.uom1_code,c.qty2,c.uom2_code,c.qty3,c.uom3_code,c.qty4,c.uom4_code, c.dist_id,
ec_stream_item_version.product_id(c.stream_item_id,c.daytime,'<=') product_id,
ec_stream_item_version.company_id(c.stream_item_id,c.daytime,'<=') company_id
FROM   cont_line_item_dist c
WHERE  c.line_item_based_type = 'QTY'
AND    c.move_qty_to_vo_ind = 'Y'
AND    c.document_key IN
                       (SELECT  cd.document_key
                        FROM    cont_document cd
                        WHERE   cd.document_level_code = 'BOOKED'
                        AND     cd.financial_code = decode(cp_prod_coll_type,'GAS_PURCHASE','PURCHASE','GAS_SALES','SALE','LIQUID','SALE')
                        AND     cd.booking_period <= NVL(cp_plan_date, cd.booking_period + 1)
                        )
AND    c.transaction_key IN
                         (SELECT ct.transaction_key
                          FROM   cont_transaction ct
                          WHERE  ct.transaction_date BETWEEN cp_daytime AND last_day(cp_daytime)
                          )
AND    c.dist_id IN
                 (SELECT siv.field_id
                  FROM   stream_item si, stream_item_version siv
                  WHERE  si.object_id = cp_stream_item_id
                  AND    si.object_id = siv.object_id
                  AND    cp_daytime >= si.start_date
                  AND    cp_daytime < nvl(si.end_date,cp_daytime+1)
                  AND    siv.daytime =
                                     (
                                     SELECT MAX(sivn.daytime)
                                     FROM   stream_item_version sivn
                                     WHERE  sivn.object_id = si.object_id
                                     AND    sivn.daytime <= cp_daytime
                                     )


                  )
AND
((
SELECT siv.product_id
    FROM stream_item si, stream_item_version siv
   WHERE si.object_id = c.stream_item_id
     AND si.object_id = siv.object_id
     AND c.daytime >= si.start_date
     AND c.daytime < nvl(si.end_date, c.daytime + 1)
     AND    siv.daytime =
                     (
                     SELECT MAX(sivn.daytime)
                     FROM   stream_item_version sivn
                     WHERE  sivn.object_id = siv.object_id
                     AND    sivn.daytime <= c.daytime
                     )
)
=
(
SELECT siv2.product_id
    FROM stream_item si2, stream_item_version siv2
   WHERE si2.object_id = cp_stream_item_id
     AND si2.object_id = siv2.object_id
     AND cp_daytime >= si2.start_date
     AND cp_daytime < nvl(si2.end_date, cp_daytime + 1)
     AND    siv2.daytime =
                        (
                         SELECT MAX(sivn.daytime)
                         FROM   stream_item_version sivn
                         WHERE  sivn.object_id = siv2.object_id
                         AND    siv2.daytime <= cp_daytime
                         )
))
AND
((
SELECT siv.company_id
  FROM stream_item si, stream_item_version siv
 WHERE si.object_id = c.stream_item_id
   AND si.object_id = siv.object_id
   AND c.daytime >= si.start_date
   AND c.daytime < nvl(si.end_date, c.daytime + 1)
   AND    siv.daytime =
                       (
                       SELECT MAX(sivn.daytime)
                       FROM   stream_item_version sivn
                       WHERE  sivn.object_id = siv.object_id
                       AND    sivn.daytime <= c.daytime
                       )
)
=
(
SELECT siv.company_id
  FROM stream_item si, stream_item_version siv
 WHERE si.object_id = cp_stream_item_id
   AND si.object_id = siv.object_id
   AND cp_daytime >= si.start_date
   AND cp_daytime < nvl(si.end_date, cp_daytime + 1)
   AND    siv.daytime =
                       (
                       SELECT MAX(sivn.daytime)
                       FROM   stream_item_version sivn
                       WHERE  sivn.object_id = siv.object_id
                       AND    sivn.daytime <= cp_daytime
                       )
))
AND

((
SELECT cov.contract_term_code
  FROM contract co, contract_version cov
 WHERE co.object_id = c.object_id
   AND co.object_id = cov.object_id
   AND cp_daytime >= co.start_date
   AND cp_daytime < nvl(co.end_date, cp_daytime + 1)
   AND    cov.daytime =
                       (
                       SELECT MAX(cnv.daytime)
                       FROM   contract_version cnv
                       WHERE  cnv.object_id = cov.object_id
                       AND    cnv.daytime <= cp_daytime
                       )
)
=
(
nvl(cp_cntr_term_code,
(SELECT cov.contract_term_code
  FROM contract co, contract_version cov
 WHERE co.object_id = c.object_id
   AND co.object_id = cov.object_id
   AND cp_daytime >= co.start_date
   AND cp_daytime < nvl(co.end_date, cp_daytime + 1)
   AND    cov.daytime =
                       (
                       SELECT MAX(cnv.daytime)
                       FROM   contract_version cnv
                       WHERE  cnv.object_id = cov.object_id
                       AND    cnv.daytime <= cp_daytime
                       )
))));

lv2_plan_date DATE;

BEGIN

    IF (ec_forecast_version.populate_method(p_forecast_id, p_daytime, '<=') = 'YEAR_TO_MONTH') THEN
        lv2_plan_date := ec_forecast_version.plan_date(p_forecast_id, p_daytime, '<=');
    ELSE
        lv2_plan_date := NULL;
    END IF;

FOR c_val IN c_li_dist (p_stream_item_id, p_daytime, lv2_plan_date, p_prod_coll_type, p_cntr_term_code) LOOP


     -- copy figures to table
    EcDp_unit.GenQtyUOMSet(ltab_uom_set, c_val.qty1, c_val.uom1_code
                           ,c_val.qty2, c_val.uom2_code
                           ,c_val.qty3, c_val.uom3_code
                           ,c_val.qty4, c_val.uom4_code);


    -- Retrieving the best match value
    ln_result := NVL(ln_result,0) + NVL(EcDp_Unit.GetUOMSetQty(ltab_uom_set, p_to_uom, p_daytime),0);


    -- Resetting the uom set
    ltab_uom_set := EcDp_Unit.t_uomtable();

END LOOP;

RETURN ln_result;

END getSaleQty;


FUNCTION getPYASaleQty(p_forecast_id    VARCHAR2,
                       p_stream_item_id VARCHAR2,
                       p_to_uom         VARCHAR2,
                       p_daytime        DATE,
                       p_prod_coll_type VARCHAR2,
                       p_cntr_term_code VARCHAR2 DEFAULT NULL) -- SPOT/TERM/NULL)
  --</EC-DOC>
RETURN NUMBER
IS

ltab_uom_set ecdp_unit.t_UOMTable := EcDp_Unit.t_uomtable();
ln_result                   NUMBER;

CURSOR c_li_dist_pya (cp_stream_item_id VARCHAR2, cp_daytime DATE, cp_plan_date DATE, cp_prod_coll_type VARCHAR2, cp_cntr_term_code VARCHAR2) IS
SELECT c.qty1,c.uom1_code,c.qty2,c.uom2_code,c.qty3,c.uom3_code,c.qty4,c.uom4_code, c.dist_id,
ec_stream_item_version.product_id(c.stream_item_id,c.daytime,'<=') product_id,
ec_stream_item_version.company_id(c.stream_item_id,c.daytime,'<=') company_id
FROM   cont_line_item_dist c
WHERE  c.line_item_based_type = 'QTY'
AND    c.document_key IN
                       (SELECT  cd.document_key
                        FROM    cont_document cd
                        WHERE   cd.document_level_code = 'BOOKED'
                        AND     cd.financial_code = decode(cp_prod_coll_type,'GAS_PURCHASE','PURCHASE','GAS_SALES','SALE','LIQUID','SALE')
                        AND     cd.booking_period <= NVL(cp_plan_date, cd.booking_period + 1)
                        )
AND    c.transaction_key IN
                         (SELECT ct.transaction_key
                          FROM   cont_transaction ct, cont_document cd
                          WHERE  TRUNC(ct.transaction_date,'YYYY') = ADD_MONTHS(TRUNC(cp_daytime,'YYYY'),-12)
         AND ct.document_key = cd.document_key
   AND TRUNC(cd.booking_period,'YYYY') = TRUNC(cp_daytime,'YYYY')
                          )
AND    c.dist_id IN
                 (SELECT siv.field_id
                  FROM   stream_item si, stream_item_version siv
                  WHERE  si.object_id = cp_stream_item_id
                  AND    si.object_id = siv.object_id
                  AND    cp_daytime >= si.start_date
                  AND    cp_daytime < nvl(si.end_date,cp_daytime+1)
                  AND    siv.daytime =
                                     (
                                     SELECT MAX(sivn.daytime)
                                     FROM   stream_item_version sivn
                                     WHERE  sivn.object_id = si.object_id
                                     AND    sivn.daytime <= cp_daytime
                                     )


                  )
AND
((
SELECT siv.product_id
                   FROM stream_item si, stream_item_version siv
                   WHERE si.object_id = c.stream_item_id
                     AND si.object_id = siv.object_id
                     AND c.daytime >= si.start_date
                     AND c.daytime < nvl(si.end_date, c.daytime + 1)
                     AND    siv.daytime =
                                     (
                                     SELECT MAX(sivn.daytime)
                                     FROM   stream_item_version sivn
                                     WHERE  sivn.object_id = siv.object_id
                                     AND    sivn.daytime <= c.daytime
                                     )
)
=
(
SELECT siv2.product_id
                    FROM stream_item si2, stream_item_version siv2
                   WHERE si2.object_id = cp_stream_item_id
                     AND si2.object_id = siv2.object_id
                     AND cp_daytime >= si2.start_date
                     AND cp_daytime < nvl(si2.end_date, cp_daytime + 1)
                     AND    siv2.daytime =
                                        (
                                         SELECT MAX(sivn.daytime)
                                         FROM   stream_item_version sivn
                                         WHERE  sivn.object_id = siv2.object_id
                                         AND    siv2.daytime <= cp_daytime
                                         )
))
AND
((
SELECT siv.company_id
  FROM stream_item si, stream_item_version siv
 WHERE si.object_id = c.stream_item_id
   AND si.object_id = siv.object_id
   AND c.daytime >= si.start_date
   AND c.daytime < nvl(si.end_date, c.daytime + 1)
   AND    siv.daytime =
                       (
                       SELECT MAX(sivn.daytime)
                       FROM   stream_item_version sivn
                       WHERE  sivn.object_id = siv.object_id
                       AND    sivn.daytime <= c.daytime
                       )
)
=
(
SELECT siv.company_id
  FROM stream_item si, stream_item_version siv
 WHERE si.object_id = cp_stream_item_id
   AND si.object_id = siv.object_id
   AND cp_daytime >= si.start_date
   AND cp_daytime < nvl(si.end_date, cp_daytime + 1)
   AND    siv.daytime =
                       (
                       SELECT MAX(sivn.daytime)
                       FROM   stream_item_version sivn
                       WHERE  sivn.object_id = siv.object_id
                       AND    sivn.daytime <= cp_daytime
                       )
))
AND

((
SELECT cov.contract_term_code
  FROM contract co, contract_version cov
 WHERE co.object_id = c.object_id
   AND co.object_id = cov.object_id
   AND cp_daytime >= co.start_date
   AND cp_daytime < nvl(co.end_date, cp_daytime + 1)
   AND    cov.daytime =
                       (
                       SELECT MAX(cnv.daytime)
                       FROM   contract_version cnv
                       WHERE  cnv.object_id = cov.object_id
                       AND    cnv.daytime <= cp_daytime
                       )
)
=
(
nvl(cp_cntr_term_code,
(SELECT cov.contract_term_code
  FROM contract co, contract_version cov
 WHERE co.object_id = c.object_id
   AND co.object_id = cov.object_id
   AND cp_daytime >= co.start_date
   AND cp_daytime < nvl(co.end_date, cp_daytime + 1)
   AND    cov.daytime =
                       (
                       SELECT MAX(cnv.daytime)
                       FROM   contract_version cnv
                       WHERE  cnv.object_id = cov.object_id
                       AND    cnv.daytime <= cp_daytime
                       )
))));

lv2_plan_date DATE;

BEGIN

    IF (ec_forecast_version.populate_method(p_forecast_id, p_daytime, '<=') = 'YEAR_TO_MONTH') THEN
        lv2_plan_date := ec_forecast_version.plan_date(p_forecast_id, p_daytime, '<=');
    ELSE
        lv2_plan_date := NULL;
    END IF;

  FOR c_pya_val IN c_li_dist_pya (p_stream_item_id, p_daytime, lv2_plan_date, p_prod_coll_type, p_cntr_term_code) LOOP

       -- copy figures to table
      EcDp_unit.GenQtyUOMSet(ltab_uom_set, c_pya_val.qty1, c_pya_val.uom1_code
                             ,c_pya_val.qty2, c_pya_val.uom2_code
                             ,c_pya_val.qty3, c_pya_val.uom3_code
                             ,c_pya_val.qty4, c_pya_val.uom4_code);

      -- Retrieving the best match value
      ln_result := NVL(ln_result,0) + NVL(EcDp_Unit.GetUOMSetQty(ltab_uom_set, p_to_uom, p_daytime),0);

      -- Resetting the uom set
      ltab_uom_set := EcDp_Unit.t_uomtable();

  END LOOP;

  RETURN ln_result;

END getPYASaleQty;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   getGPurchNetQty
-- Description    :  Return base price for revenue forecast case with method plan
--                :  If Contract Term Code is not passed as argument, then this is not considered.
--                :  Else, the contract found on the line item must match this criteria.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getGPurchNetQty(p_forecast_id    VARCHAR2,
                         p_object_id      VARCHAR2, -- contract
                         p_product_id     VARCHAR2,
                         p_to_uom         VARCHAR2,
                         p_from_uom       VARCHAR2,
                         p_daytime        DATE)


  --</EC-DOC>
RETURN NUMBER

IS

ltab_uom_set ecdp_unit.t_UOMTable := EcDp_Unit.t_uomtable();
ln_result                   NUMBER;



CURSOR c_li_dist (cp_object_id VARCHAR2, cp_product_id VARCHAR2, cp_daytime DATE, cp_plan_date DATE) IS
SELECT c.qty1,c.uom1_code,c.qty2,c.uom2_code,c.qty3,c.uom3_code,c.qty4,c.uom4_code
FROM   cont_line_item c
WHERE  c.line_item_based_type = 'QTY'
AND    c.object_id = cp_object_id
AND    c.document_key IN
                       (SELECT  cd.document_key
                        FROM    cont_document cd
                        WHERE   cd.document_level_code = 'BOOKED'
                        AND     cd.financial_code = 'PURCHASE'
                        AND     cd.booking_period <= NVL(cp_plan_date, cd.booking_period + 1)
                        )
AND    c.transaction_key IN
                         (SELECT ct.transaction_key
                          FROM   cont_transaction ct
                          WHERE  ct.transaction_date BETWEEN cp_daytime AND last_day(cp_daytime)
                          AND    ct.product_id = cp_product_id
                          );


lv2_plan_date DATE;

BEGIN

    IF (ec_forecast_version.populate_method(p_forecast_id, p_daytime, '<=') = 'YEAR_TO_MONTH') THEN
        lv2_plan_date := ec_forecast_version.plan_date(p_forecast_id, p_daytime, '<=');
    ELSE
        lv2_plan_date := NULL;
    END IF;

FOR c_val IN c_li_dist (p_object_id, p_product_id, p_daytime, lv2_plan_date) LOOP

     -- copy figures to table
    EcDp_unit.GenQtyUOMSet(ltab_uom_set, c_val.qty1, c_val.uom1_code
                           ,c_val.qty2, c_val.uom2_code
                           ,c_val.qty3, c_val.uom3_code
                           ,c_val.qty4, c_val.uom4_code);


    -- Retrieving the best match value
    ln_result := NVL(ln_result,0) + NVL(EcDp_Unit.GetUOMSetQty(ltab_uom_set, p_to_uom, p_daytime),0);


    -- Resetting the uom set
    ltab_uom_set := EcDp_Unit.t_uomtable();

END LOOP;




RETURN ln_result;

END getGPurchNetQty;

FUNCTION getPYAGPurchNetQty(p_forecast_id  VARCHAR2,
                         p_object_id      VARCHAR2, -- contract
                         p_product_id     VARCHAR2,
                         p_to_uom         VARCHAR2,
                         p_from_uom       VARCHAR2,
                         p_daytime        DATE)


  --</EC-DOC>
RETURN NUMBER

IS

ltab_uom_set ecdp_unit.t_UOMTable := EcDp_Unit.t_uomtable();
ln_result                   NUMBER;



CURSOR c_li_dist (cp_object_id VARCHAR2, cp_product_id VARCHAR2, cp_daytime DATE, cp_plan_date DATE) IS
SELECT c.qty1,c.uom1_code,c.qty2,c.uom2_code,c.qty3,c.uom3_code,c.qty4,c.uom4_code
FROM   cont_line_item c
WHERE  c.line_item_based_type = 'QTY'
AND    c.object_id = cp_object_id
AND    c.document_key IN
                       (SELECT  cd.document_key
                        FROM    cont_document cd
                        WHERE   cd.document_level_code = 'BOOKED'
                        AND     cd.financial_code = 'PURCHASE'
                        AND     cd.booking_period <= NVL(cp_plan_date, cd.booking_period + 1)
                        )
AND    c.transaction_key IN
                         (SELECT ct.transaction_key
                          FROM   cont_transaction ct, cont_document cd
                          WHERE  ct.product_id = cp_product_id
                              AND cd.document_key = ct.document_key
                              AND TRUNC(ct.transaction_date,'YYYY') = ADD_MONTHS(TRUNC(cp_daytime,'YYYY'),-12)
                              AND ct.document_key = cd.document_key
                              AND TRUNC(cd.booking_period,'YYYY') = TRUNC(cp_daytime,'YYYY')
                          );

lv2_plan_date DATE;

BEGIN

    IF (ec_forecast_version.populate_method(p_forecast_id, p_daytime, '<=') = 'YEAR_TO_MONTH') THEN
        lv2_plan_date := ec_forecast_version.plan_date(p_forecast_id, p_daytime, '<=');
    ELSE
        lv2_plan_date := NULL;
    END IF;


FOR c_val IN c_li_dist (p_object_id, p_product_id, p_daytime, lv2_plan_date) LOOP

     -- copy figures to table
    EcDp_unit.GenQtyUOMSet(ltab_uom_set, c_val.qty1, c_val.uom1_code
                           ,c_val.qty2, c_val.uom2_code
                           ,c_val.qty3, c_val.uom3_code
                           ,c_val.qty4, c_val.uom4_code);


    -- Retrieving the best match value
    ln_result := NVL(ln_result,0) + NVL(EcDp_Unit.GetUOMSetQty(ltab_uom_set, p_to_uom, p_daytime),0);


    -- Resetting the uom set
    ltab_uom_set := EcDp_Unit.t_uomtable();

END LOOP;

RETURN ln_result;

END getPYAGPurchNetQty;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   getNetQty
-- Description    :  Return the net qty from referenced quantity forecast for the same stream_item and date
--
-- Preconditions  :  Stream item on quantity and stream item on revenue forecast must match.
--                   If this match is not present, actual numbers from VO will be retrieved and persisted in the net_qty column
--                   This is the difference between this function and getNetQtyPlan which does not return any VO number if
--                   Nothing is found on the referenced quantity forecast for this stream item
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getNetQty(p_object_id      VARCHAR2, -- forecast case
                   p_stream_item_id VARCHAR2,
                   p_to_uom         VARCHAR2,
                   p_daytime        DATE)
--</EC-DOC>
RETURN NUMBER

IS

ln_result NUMBER := NULL;
lv2_uom VARCHAR2(32);
lv2_uom_group VARCHAR2(1);
lb_found BOOLEAN := FALSE;

CURSOR c_member (cp_object_id VARCHAR2, cp_stream_item_id VARCHAR2) IS
  SELECT f.member_no
   FROM fcst_member f
  WHERE f.object_id = cp_object_id
  AND   f.stream_item_id = cp_stream_item_id;

CURSOR c_qty_fcst_net_qty (cp_member_no NUMBER, cp_daytime DATE) IS
SELECT f.net_qty, f.uom
FROM fcst_mth_status f
WHERE f.member_no = cp_member_no
AND   f.daytime = cp_daytime;

CURSOR c_stim_fcst (cp_forecast_id VARCHAR2, cp_stream_item_id VARCHAR2, cp_daytime DATE) IS
SELECT t.net_mass_value, t.mass_uom_code, t.net_volume_value, t.volume_uom_code, t.net_energy_value, t.energy_uom_code
FROM stim_fcst_mth_value t
WHERE t.object_id = cp_stream_item_id
AND t.forecast_id = cp_forecast_id
AND t.daytime = cp_daytime
;

BEGIN

    FOR mem IN c_member (p_object_id, p_stream_item_id) LOOP

        FOR net_qty IN c_qty_fcst_net_qty(mem.member_no, p_daytime) LOOP
            ln_result := nvl(net_qty.net_qty,0);
            lv2_uom := net_qty.uom;
            ln_result := ecdp_unit.convertValue(ln_result, net_qty.uom, p_to_uom,p_daytime);
        END LOOP;

    END LOOP;

  IF (isPriorToPlanDate(p_object_id, p_daytime) = 'TRUE') THEN -- Actual

        IF (ln_result IS NULL) THEN
           ln_result := Ecdp_Stream_Item.GetMthQtyByUOM(p_stream_item_id, p_to_uom, p_daytime, 'Y');
      END IF;

  ELSE -- Plan

    IF ln_result IS NOT NULL THEN
          ln_result := nvl(ecdp_unit.convertValue(ln_result,lv2_uom,p_to_uom,p_daytime),0);
      ELSE
          lv2_uom_group := ecdp_unit.GetUOMGroup(p_to_uom);

          -- Try and find the Stream Item in the STIM_FCST_MTH_VALUE table
          FOR stim IN c_stim_fcst(p_object_id, p_stream_item_id, p_daytime) LOOP
              lb_found := TRUE;
              IF (lv2_uom_group = 'M') THEN
                  ln_result := nvl(ecdp_unit.convertValue(stim.net_mass_value, stim.mass_uom_code, p_to_uom,p_daytime),0);
              ELSIF (lv2_uom_group = 'V') THEN
                  ln_result := nvl(ecdp_unit.convertValue(stim.net_volume_value, stim.volume_uom_code, p_to_uom,p_daytime),0);
              ELSIF (lv2_uom_group = 'E') THEN
                  ln_result := nvl(ecdp_unit.convertValue(stim.net_energy_value, stim.energy_uom_code, p_to_uom,p_daytime),0);
              END IF;

          END LOOP;

          IF p_stream_item_id IS NOT NULL AND NOT lb_found THEN
              ln_result := Ecdp_Stream_Item.GetMthQtyByUOM(p_stream_item_id, p_to_uom, p_daytime, 'Y');
          END IF;

      END IF;

  END IF; -- Prior to plan

    RETURN ln_result;

END getNetQty;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   getNetQtyPlan
-- Description    :  Return the net qty from referenced quantity forecast for the same stream_item and date
--                   No other value will be returned while being on plan dates
--                   This is the difference between this function and getNetQty which will retrieve a value from VO
--                   if nothing is found on the referenced quantity forecast for this stream item.
--
-- Preconditions  :
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getNetQtyPlan(p_object_id      VARCHAR2, -- forecast case
                       p_stream_item_id VARCHAR2,
                       p_to_uom         VARCHAR2,
                       p_daytime        DATE)
--</EC-DOC>
RETURN NUMBER


IS

ln_result NUMBER := NULL;
lv2_uom_group VARCHAR2(1);
lb_found BOOLEAN := FALSE;

CURSOR c_member (cp_object_id VARCHAR2, cp_stream_item_id VARCHAR2) IS
  SELECT f.member_no
   FROM fcst_member f
  WHERE f.object_id = cp_object_id
  AND   f.stream_item_id = cp_stream_item_id;

CURSOR c_qty_fcst_net_qty (cp_member_no NUMBER, cp_daytime DATE) IS
SELECT f.net_qty, f.uom
FROM fcst_mth_status f, fcst_member fm
WHERE f.member_no = cp_member_no
AND   f.member_no = fm.member_no
AND   fm.product_context = 'PRODUCTION'
AND   f.daytime = cp_daytime;

CURSOR c_stim_fcst (cp_forecast_id VARCHAR2, cp_stream_item_id VARCHAR2, cp_daytime DATE) IS
SELECT t.net_mass_value, t.mass_uom_code, t.net_volume_value, t.volume_uom_code, t.net_energy_value, t.energy_uom_code
FROM stim_fcst_mth_value t
WHERE t.object_id = cp_stream_item_id
AND t.forecast_id = cp_forecast_id
AND t.daytime = cp_daytime
;

BEGIN

    lv2_uom_group := ecdp_unit.GetUOMGroup(p_to_uom);

    FOR mem IN c_member (p_object_id, p_stream_item_id) LOOP

        FOR net_qty IN c_qty_fcst_net_qty(mem.member_no, p_daytime) LOOP
            ln_result := net_qty.net_qty;
            ln_result := ecdp_unit.convertValue(ln_result, net_qty.uom, p_to_uom,p_daytime);
        END LOOP;

     END LOOP;

  IF ( ec_forecast_version.populate_method(p_object_id, p_daytime, '<=') <> 'PLAN'
       AND isPriorToPlanDate(p_object_id, p_daytime) = 'TRUE') THEN -- Actual

        IF (ln_result IS NULL) THEN
           ln_result := Ecdp_Stream_Item.GetMthQtyByUOM(p_stream_item_id, p_to_uom, p_daytime, 'Y');
        END IF;

  ELSE -- Plan

       IF (ln_result IS NULL) THEN
           -- Try and find the Stream Item in the STIM_FCST_MTH_VALUE table
           FOR stimPlan IN c_stim_fcst(p_object_id, p_stream_item_id, p_daytime) LOOP
              lb_found := TRUE;
              IF (lv2_uom_group = 'M') THEN
                  ln_result := nvl(ecdp_unit.convertValue(stimPlan.net_mass_value, stimPlan.mass_uom_code, p_to_uom,p_daytime),0);
              ELSIF (lv2_uom_group = 'V') THEN
                  ln_result := nvl(ecdp_unit.convertValue(stimPlan.net_volume_value, stimPlan.volume_uom_code, p_to_uom,p_daytime),0);
              ELSIF (lv2_uom_group = 'E') THEN
                  ln_result := nvl(ecdp_unit.convertValue(stimPlan.net_energy_value, stimPlan.energy_uom_code, p_to_uom,p_daytime),0);
              END IF;
          END LOOP;

        END IF;

  END IF; -- Prior to plan

    RETURN ln_result;

END getNetQtyPlan;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   getQtyFcstStatus
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getQtyFcstStatus(p_object_id      VARCHAR2, -- forecast case
                          p_stream_item_id VARCHAR2,
                          p_daytime        DATE)
--</EC-DOC>
RETURN VARCHAR2


IS

lv_result VARCHAR2(32) := NULL;


CURSOR c_member (cp_object_id VARCHAR2, cp_stream_item_id VARCHAR2) IS
  SELECT f.member_no
   FROM fcst_member f
  WHERE f.object_id = cp_object_id
  AND   f.stream_item_id = cp_stream_item_id;



CURSOR c_qty_fcst_status (cp_member_no NUMBER, cp_daytime DATE) IS
SELECT f.status
FROM fcst_mth_status f
WHERE f.member_no = cp_member_no
AND   f.daytime = cp_daytime;



BEGIN


FOR mem IN c_member (p_object_id, p_stream_item_id) LOOP

    FOR status IN c_qty_fcst_status(mem.member_no, p_daytime) LOOP

       IF status.status IS NOT NULL THEN
          lv_result := status.status;
        END IF;
    END LOOP;


END LOOP;

IF lv_result IS NULL THEN
   lv_result := ec_stim_mth_value.status(p_stream_item_id,p_daytime,'<=');


END IF;



RETURN lv_result;

END getQtyFcstStatus;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   getNetCostForActualNumbers
-- Description    :  Returns the net quantities divided to net price. If scope is set, only spot/term prices/quantities are picked
--                :  If the last argument is specified, make sure that also the argument p_spot_price_qty reflects the
--                :  proper contract term cod
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getNetCostForActualNumbers(p_forecast_id             VARCHAR2,
                                    p_object_id               VARCHAR2, -- Contract object_id
                                    p_product_id              VARCHAR2,
                                    p_qty                     NUMBER, -- spot price qty / term price qty
                                    p_daytime                 DATE)
--</EC-DOC>
RETURN NUMBER

IS

ln_act_net_value            NUMBER := 0;

CURSOR c_li_dist (cp_object_id VARCHAR2, cp_product_id VARCHAR2, cp_daytime DATE, cp_plan_date DATE) IS
SELECT c.booking_value, c.document_key, c.transaction_key, rownum
FROM   cont_line_item c
WHERE  c.line_item_based_type = 'QTY'
AND    c.object_id = cp_object_id
AND    c.document_key IN
                       (SELECT  cd.document_key
                        FROM    cont_document cd
                        WHERE   cd.document_level_code = 'BOOKED'
                        AND     cd.financial_code = 'PURCHASE'
                        AND     cd.booking_period <= NVL(cp_plan_date, cd.booking_period + 1)
                        )
AND    c.transaction_key IN
                         (SELECT ct.transaction_key
                          FROM   cont_transaction ct
                          WHERE  ct.transaction_date BETWEEN cp_daytime AND last_day(cp_daytime)
                          AND    ct.product_id = cp_product_id
                          );

lv2_plan_date DATE;

BEGIN

    IF (ec_forecast_version.populate_method(p_forecast_id, p_daytime, '<=') = 'YEAR_TO_MONTH') THEN
        lv2_plan_date := ec_forecast_version.plan_date(p_forecast_id, p_daytime, '<=');
    ELSE
        lv2_plan_date := NULL;
    END IF;

-- Retrieving net price for actual numbers. Using pricing_currency / contract / line item level
    -- Assuming this currency is used by cont_line_item.pricing_value.
FOR net_pr IN c_li_dist (p_object_id, p_product_id,p_daytime, lv2_plan_date) LOOP
    ln_act_net_value := nvl(ln_act_net_value,0) + nvl(net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(net_pr.transaction_key);


END LOOP;


    -- Returning price divided on quantity (avoiding division by zero)
    IF p_qty IS NOT NULL AND p_qty <> 0 THEN
        RETURN ln_act_net_value/p_qty;
      ELSE RETURN 0;
    END IF;



RETURN 0;
END getNetCostForActualNumbers;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   getRevnRec
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getRevnRec(p_object_id               VARCHAR2, -- Forecast object_id
                                         p_stream_item_id          VARCHAR2,
                                         p_product_id              VARCHAR2,
                                         p_product_context         VARCHAR2,
                                         p_product_collection_type VARCHAR2,
                                         p_qty                     NUMBER, -- spot price qty / term price qty
                                         p_daytime                 DATE)
--                                         p_cntr_term_code          VARCHAR2 DEFAULT NULL) -- SPOT/TERM/NULL
RETURN t_revn_rec
IS

   lrec_revn t_revn_rec;

   lv2_line_item_type VARCHAR2(32);

CURSOR c_li_dist (cp_stream_item_id VARCHAR2, cp_daytime DATE, cp_plan_date DATE, cp_product_collection_type VARCHAR2) IS
SELECT c.booking_value,
       c.document_key,
       c.transaction_key,
       c.value_adjustment,
       ec_contract_version.contract_term_code(c.object_id, c.daytime, '<=') term_code,
       c.line_item_type,
       c.line_item_based_type,
       c.booking_value * DECODE(ec_cont_transaction.reversed_trans_key(c.transaction_key)
           , NULL, ec_cont_transaction.ex_booking_local(c.transaction_key)
           , ec_cont_transaction.ex_booking_local(ec_cont_transaction.reversed_trans_key(c.transaction_key))) local_value
FROM  cont_line_item_dist c
WHERE c.line_item_type IN ('SALE','PAY_ADJ')
  AND c.dist_id IN
                 (SELECT siv.field_id
                  FROM   stream_item si, stream_item_version siv
                  WHERE  si.object_id = cp_stream_item_id
                  AND    si.object_id = siv.object_id
                  AND    cp_daytime >= si.start_date
                  AND    cp_daytime < nvl(si.end_date,cp_daytime+1)
                  AND    siv.daytime =
                                     (
                                     SELECT MAX(sivn.daytime)
                                     FROM   stream_item_version sivn
                                     WHERE  sivn.object_id = si.object_id
                                     AND    sivn.daytime <= cp_daytime
                                     )


                  )
AND
((
SELECT siv.product_id
    FROM stream_item si, stream_item_version siv
   WHERE si.object_id = c.stream_item_id
     AND si.object_id = siv.object_id
     AND c.daytime >= si.start_date
     AND c.daytime < nvl(si.end_date, c.daytime + 1)
     AND    siv.daytime =
                     (
                     SELECT MAX(sivn.daytime)
                     FROM   stream_item_version sivn
                     WHERE  sivn.object_id = siv.object_id
                     AND    sivn.daytime <= c.daytime
                     )
     )
=
(
SELECT siv2.product_id
    FROM stream_item si2, stream_item_version siv2
   WHERE si2.object_id = cp_stream_item_id
     AND si2.object_id = siv2.object_id
     AND cp_daytime >= si2.start_date
     AND cp_daytime < nvl(si2.end_date, cp_daytime + 1)
     AND    siv2.daytime =
                        (
                         SELECT MAX(sivn.daytime)
                         FROM   stream_item_version sivn
                         WHERE  sivn.object_id = siv2.object_id
                         AND    siv2.daytime <= cp_daytime
                         )
))
AND
((
SELECT siv.company_id
  FROM stream_item si, stream_item_version siv
 WHERE si.object_id = c.stream_item_id
   AND si.object_id = siv.object_id
   AND c.daytime >= si.start_date
   AND c.daytime < nvl(si.end_date, c.daytime + 1)
   AND    siv.daytime =
                       (
                       SELECT MAX(sivn.daytime)
                       FROM   stream_item_version sivn
                       WHERE  sivn.object_id = siv.object_id
                       AND    sivn.daytime <= c.daytime
                       )
)
=
(
SELECT siv.company_id
  FROM stream_item si, stream_item_version siv
 WHERE si.object_id = cp_stream_item_id
   AND si.object_id = siv.object_id
   AND cp_daytime >= si.start_date
   AND cp_daytime < nvl(si.end_date, cp_daytime + 1)
   AND    siv.daytime =
                       (
                       SELECT MAX(sivn.daytime)
                       FROM   stream_item_version sivn
                       WHERE  sivn.object_id = siv.object_id
                       AND    sivn.daytime <= cp_daytime
                       )
))
AND    c.document_key IN
                       (SELECT  cd.document_key
                        FROM    cont_document cd
                        WHERE   cd.document_level_code = 'BOOKED'
                        AND     cd.financial_code = decode(cp_product_collection_type,'GAS_PURCHASE','PURCHASE','GAS_SALES','SALE','LIQUID','SALE')
                        AND     cd.booking_period <= NVL(cp_plan_date, cd.booking_period + 1)
                        )
AND    c.transaction_key IN
                         (SELECT ct.transaction_key
                          FROM   cont_transaction ct
                          WHERE  ct.transaction_date BETWEEN cp_daytime AND last_day(cp_daytime)
                          )
;

lv2_plan_date DATE;

BEGIN

    IF (ec_forecast_version.populate_method(p_object_id, p_daytime, '<=') = 'YEAR_TO_MONTH') THEN
        lv2_plan_date := ec_forecast_version.plan_date(p_object_id, p_daytime, '<=');
    ELSE
        lv2_plan_date := NULL;
    END IF;

    lrec_revn.act_net_price := 0;
    lrec_revn.local_gross_revenue := 0;
    lrec_revn.local_non_adj_revenue := 0;
    lrec_revn.value_adj := 0;
    lrec_revn.local_term_value := 0;
    lrec_revn.local_spot_value := 0;

    lv2_line_item_type := ec_fcst_product_setup.value_adj_type(p_object_id, p_product_id, p_product_context, p_product_collection_type);
    -- All Line items
    FOR net_pr IN c_li_dist (p_stream_item_id, p_daytime, lv2_plan_date, p_product_collection_type) LOOP

        IF (net_pr.line_item_based_type = 'QTY') THEN
            lrec_revn.act_net_price := nvl(lrec_revn.act_net_price,0) + nvl(net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(net_pr.transaction_key);

            lrec_revn.local_gross_revenue := nvl(lrec_revn.local_gross_revenue,0) + (nvl(net_pr.local_value,0)/nvl(net_pr.value_adjustment,1));
--            + (nvl(net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(net_pr.transaction_key)/nvl(net_pr.value_adjustment,1));

--            lrec_revn.local_non_adj_revenue := nvl(lrec_revn.local_non_adj_revenue,0) + (nvl(net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(net_pr.transaction_key));
            lrec_revn.local_non_adj_revenue := nvl(lrec_revn.local_non_adj_revenue,0) + nvl(net_pr.local_value,0);

            IF (net_pr.term_code = 'SPOT') THEN
                lrec_revn.local_spot_value := nvl(lrec_revn.local_spot_value,0) + nvl(net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(net_pr.transaction_key);
            ELSIF (net_pr.term_code = 'TERM') THEN
                lrec_revn.local_term_value := nvl(lrec_revn.local_term_value,0) + nvl(net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(net_pr.transaction_key);
            END IF;
        ELSE
            IF (net_pr.line_item_type = NVL(lv2_line_item_type,'XXX')) THEN
                lrec_revn.value_adj := nvl(lrec_revn.value_adj,0) + (nvl(net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(net_pr.transaction_key));
            END IF;
        END IF;

    END LOOP;

    -- Returning price divided on quantity (avoiding division by zero)
    IF p_qty IS NOT NULL AND p_qty <> 0 THEN
        lrec_revn.act_net_price := lrec_revn.act_net_price / p_qty;
    ELSE
        lrec_revn.act_net_price := 0;
    END IF;

    RETURN lrec_revn;

END getRevnRec;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   getRevnRec
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getPYARevnRec(p_object_id               VARCHAR2, -- Forecast object_id
                                         p_stream_item_id          VARCHAR2,
                                         p_product_id              VARCHAR2,
                                         p_product_context         VARCHAR2,
                                         p_product_collection_type VARCHAR2,
                                         p_qty                     NUMBER, -- spot price qty / term price qty
                                         p_daytime                 DATE)
--                                         p_cntr_term_code          VARCHAR2 DEFAULT NULL) -- SPOT/TERM/NULL
RETURN t_revn_rec
IS

   lrec_revn t_revn_rec;

   lv2_line_item_type VARCHAR2(32);

CURSOR c_pya_li_dist (cp_stream_item_id VARCHAR2, cp_daytime DATE, cp_plan_date DATE, cp_product_collection_type VARCHAR2) IS
SELECT c.booking_value,
       c.document_key,
       c.transaction_key,
       c.value_adjustment,
       ec_contract_version.contract_term_code(c.object_id, c.daytime, '<=') term_code,
       c.line_item_type,
       c.line_item_based_type
FROM   cont_line_item_dist c
WHERE  c.dist_id IN
                 (SELECT siv.field_id
                  FROM   stream_item si, stream_item_version siv
                  WHERE  si.object_id = cp_stream_item_id
                  AND    si.object_id = siv.object_id
                  AND    cp_daytime >= si.start_date
                  AND    cp_daytime < nvl(si.end_date,cp_daytime+1)
                  AND    siv.daytime =
                                     (
                                     SELECT MAX(sivn.daytime)
                                     FROM   stream_item_version sivn
                                     WHERE  sivn.object_id = si.object_id
                                     AND    sivn.daytime <= cp_daytime
                                     )


                  )
AND
((
SELECT siv.product_id
      FROM stream_item si, stream_item_version siv
     WHERE si.object_id = c.stream_item_id
       AND si.object_id = siv.object_id
       AND c.daytime >= si.start_date
       AND c.daytime < nvl(si.end_date, c.daytime + 1)
       AND    siv.daytime =
                       (
                       SELECT MAX(sivn.daytime)
                       FROM   stream_item_version sivn
                       WHERE  sivn.object_id = siv.object_id
                       AND    sivn.daytime <= c.daytime
                       )
)
=
(
SELECT siv2.product_id
    FROM stream_item si2, stream_item_version siv2
   WHERE si2.object_id = cp_stream_item_id
     AND si2.object_id = siv2.object_id
     AND cp_daytime >= si2.start_date
     AND cp_daytime < nvl(si2.end_date, cp_daytime + 1)
     AND    siv2.daytime =
                        (
                         SELECT MAX(sivn.daytime)
                         FROM   stream_item_version sivn
                         WHERE  sivn.object_id = siv2.object_id
                         AND    siv2.daytime <= cp_daytime
                         )
     )
)
AND
((
SELECT siv.company_id
  FROM stream_item si, stream_item_version siv
 WHERE si.object_id = c.stream_item_id
   AND si.object_id = siv.object_id
   AND c.daytime >= si.start_date
   AND c.daytime < nvl(si.end_date, c.daytime + 1)
   AND    siv.daytime =
                       (
                       SELECT MAX(sivn.daytime)
                       FROM   stream_item_version sivn
                       WHERE  sivn.object_id = siv.object_id
                       AND    sivn.daytime <= c.daytime
                       )
)
=
(
SELECT siv.company_id
  FROM stream_item si, stream_item_version siv
 WHERE si.object_id = cp_stream_item_id
   AND si.object_id = siv.object_id
   AND cp_daytime >= si.start_date
   AND cp_daytime < nvl(si.end_date, cp_daytime + 1)
   AND    siv.daytime =
                       (
                       SELECT MAX(sivn.daytime)
                       FROM   stream_item_version sivn
                       WHERE  sivn.object_id = siv.object_id
                       AND    sivn.daytime <= cp_daytime
                       )
))
AND    c.document_key IN
                       (SELECT  cd.document_key
                        FROM    cont_document cd
                        WHERE   cd.document_level_code = 'BOOKED'
                        AND     cd.financial_code = decode(cp_product_collection_type,'GAS_PURCHASE','PURCHASE','GAS_SALES','SALE','LIQUID','SALE')
                        AND     cd.booking_period <= NVL(cp_plan_date, cd.booking_period + 1)
                        )
AND    c.transaction_key IN
                         (SELECT ct.transaction_key
                          FROM   cont_transaction ct, cont_document cd
                          WHERE cd.document_key = ct.document_key
                              AND TRUNC(ct.transaction_date,'YYYY') = ADD_MONTHS(TRUNC(cp_daytime,'YYYY'),-12)
                              AND ct.document_key = cd.document_key
                              AND TRUNC(cd.booking_period,'YYYY') = TRUNC(cp_daytime,'YYYY')
                          )
;

lv2_plan_date DATE;

BEGIN

    IF (ec_forecast_version.populate_method(p_object_id, p_daytime, '<=') = 'YEAR_TO_MONTH') THEN
        lv2_plan_date := ec_forecast_version.plan_date(p_object_id, p_daytime, '<=');
    ELSE
        lv2_plan_date := NULL;
    END IF;

    lrec_revn.act_net_price := 0;
    lrec_revn.local_gross_revenue := 0;
    lrec_revn.local_non_adj_revenue := 0;
    lrec_revn.value_adj := 0;
    lrec_revn.local_term_value := 0;
    lrec_revn.local_spot_value := 0;

    lv2_line_item_type := ec_fcst_product_setup.value_adj_type(p_object_id, p_product_id, p_product_context, p_product_collection_type);
    -- All Line items
    FOR pya_net_pr IN c_pya_li_dist (p_stream_item_id, p_daytime, lv2_plan_date, p_product_collection_type) LOOP

        IF (pya_net_pr.line_item_based_type = 'QTY') THEN
            lrec_revn.act_net_price := nvl(lrec_revn.act_net_price,0) + nvl(pya_net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(pya_net_pr.transaction_key);

            lrec_revn.local_gross_revenue := nvl(lrec_revn.local_gross_revenue,0) + (nvl(pya_net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(pya_net_pr.transaction_key)/nvl(pya_net_pr.value_adjustment,1));

            lrec_revn.local_non_adj_revenue := nvl(lrec_revn.local_non_adj_revenue,0) + (nvl(pya_net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(pya_net_pr.transaction_key));

            IF (pya_net_pr.term_code = 'SPOT') THEN
                lrec_revn.local_spot_value := nvl(lrec_revn.local_spot_value,0) + nvl(pya_net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(pya_net_pr.transaction_key);
            ELSIF (pya_net_pr.term_code = 'TERM') THEN
                lrec_revn.local_term_value := nvl(lrec_revn.local_term_value,0) + nvl(pya_net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(pya_net_pr.transaction_key);
            END IF;
        ELSE
            IF (pya_net_pr.line_item_type = NVL(lv2_line_item_type,'XXX')) THEN
                lrec_revn.value_adj := nvl(lrec_revn.value_adj,0) + (nvl(pya_net_pr.booking_value,0)*ec_cont_transaction.ex_booking_local(pya_net_pr.transaction_key));
            END IF;
        END IF;

    END LOOP;

    -- Returning price divided on quantity (avoiding division by zero)
    IF p_qty IS NOT NULL AND p_qty <> 0 THEN
        lrec_revn.act_net_price := lrec_revn.act_net_price / p_qty;
    ELSE
        lrec_revn.act_net_price := 0;
    END IF;

    RETURN lrec_revn;

END getPYARevnRec;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :   popRevnFcstPlan
-- Description    :   Populates a revenue forecast Plan case
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE popRevnFcstPlan(p_object_id               VARCHAR2, -- Forecast object_id
                          p_forex                   NUMBER,
                          p_product_id              VARCHAR2,
                          p_product_context         VARCHAR2,
                          p_product_collection_type VARCHAR2,
                          p_member_no               VARCHAR2,
                          p_daytime                 DATE,
                          p_term_base_price         NUMBER,
                          p_spot_base_price         NUMBER,
                          p_net_qty_plan            NUMBER,
                          p_uom                     VARCHAR2)
--</EC-DOC>

IS

lv_forex_currency_id VARCHAR2(32);
lv_price_currency_id VARCHAR2(32);
lv_price_object_id   VARCHAR2(32);
ln_net_price         NUMBER := 0;
lv_prod_coll_type    VARCHAR2(32);
ln_purch_net_revenue      NUMBER;
ln_available_for_sale NUMBER;
ln_closing_pos_last_mth   NUMBER;
ln_inv_movement      NUMBER;

ln_inv_opening_pos_tmp NUMBER;
ln_inv_rate_tmp        NUMBER;
ln_inv_closing_pos_qty_tmp NUMBER;

BEGIN


lv_prod_coll_type := ec_fcst_member.product_collection_type(p_member_no);

    -- Use p_base_price calc
    SELECT (p_term_base_price + NVL(differential, 0))
      INTO ln_net_price
      FROM fcst_mth_status f
     WHERE f.object_id = p_object_id
       AND f.daytime = p_daytime
       AND f.member_no = p_member_no;

    -- Use base_price calc if no price is found
    IF (ln_net_price IS NULL) THEN
          SELECT (base_price + NVL(differential, 0))
            INTO ln_net_price
            FROM fcst_mth_status f
           WHERE f.object_id = p_object_id
             AND f.daytime = p_daytime
             AND f.member_no = p_member_no;
    END IF;

  lv_forex_currency_id := ec_company_version.local_currency_id(ec_forecast_version.company_id(p_object_id,p_daytime,'<='),p_daytime,'<=');
  lv_price_currency_id := ec_fcst_product_setup.currency_id(p_object_id,p_product_id,p_product_context,p_product_collection_type);
  lv_price_object_id := ec_fcst_product_setup.product_price_id(p_object_id,p_product_id,p_product_context,p_product_collection_type);

  IF lv_prod_coll_type = 'GAS_SALES' OR lv_prod_coll_type = 'LIQUID' THEN

    ln_closing_pos_last_mth := ec_fcst_mth_status.inv_closing_pos_qty(p_member_no,add_months(p_daytime,-1));

--    ln_available_for_sale := ecdp_revn_forecast.getAvailSalesQtyByMember(p_member_no, p_daytime, 'MONTH');
    ln_available_for_sale := p_net_qty_plan;

    -- Retrieve Inventory Movement
    ln_inv_movement := getInventoryMovement(p_member_no,p_daytime,lv_prod_coll_type);

    -- Update fcst_mth_status
      UPDATE fcst_mth_status fms
         SET fms.cost_price        = -p_term_base_price,             -- Cost price should be represented as negative values
             fms.forex             = p_forex,
             fms.forex_currency_id = lv_forex_currency_id,
             fms.price_currency_id = lv_price_currency_id,
             fms.status             = 'PLAN',                            -- QA: Arvid / Stina
             fms.base_price         = decode(lv_price_object_id,null,fms.base_price,p_term_base_price),
--             fms.differential       = decode(lv_price_object_id,null,fms.differential, DECODE(p_term_base_price, null, null, 0) ),
             fms.spot_price         = decode(lv_price_object_id,null,fms.base_price,p_spot_base_price),
             fms.term_price         = decode(lv_price_object_id,null,fms.base_price,p_term_base_price),
             fms.net_price          = ln_net_price,
             fms.local_spot_price   = decode(lv_prod_coll_type,'GAS_SALES',decode(lv_price_object_id,null,fms.spot_price,nvl(p_spot_base_price,0)*p_forex),(ln_net_price*p_forex)),
             fms.local_term_price   = decode(lv_price_object_id,null,fms.term_price,nvl(p_term_base_price,0))*p_forex,
             fms.net_qty            = nvl(p_net_qty_plan,fms.net_qty),    -- QA: Arvid / Stina
             fms.sale_qty           = nvl(fms.sale_qty, (ln_available_for_sale + nvl(fms.commercial_adj_qty, 0) + nvl(fms.swap_adj_qty, 0) + nvl(ln_closing_pos_last_mth,nvl(nvl(ln_closing_pos_last_mth,fms.inv_opening_pos_qty),0)))),
             fms.uom                = nvl(p_uom,fms.uom),    --
             fms.inv_opening_pos_qty =  nvl(ln_closing_pos_last_mth,fms.inv_opening_pos_qty)
           --  fms.inv_closing_pos_qty =  nvl(fms.inv_closing_pos_qty,nvl(ln_inv_movement,0) + nvl(ln_closing_pos_last_mth,0)),
          --   fms.inv_closing_value   =  nvl(fms.inv_closing_value,(nvl(ln_inv_movement,0) + nvl(ln_closing_pos_last_mth,0)) * nvl(fms.inv_rate,0))
       WHERE fms.object_id = p_object_id
         AND fms.daytime = p_daytime
         AND fms.member_no = p_member_no;

    IF lv_prod_coll_type = 'GAS_SALES' THEN
      -- Update the split between Spot and Term Sales Qty
      updateFcstGSSpotTermQty(p_member_no, p_daytime);
    END IF;

    -- Do another update in order to be able to use the variables updated in the previous update
      UPDATE fcst_mth_status fms
         SET
             fms.local_gross_revenue = decode(nvl(lv_prod_coll_type,0),'GAS_SALES',nvl(fms.term_sale_qty,0)*nvl(fms.local_term_price,0)+(nvl(fms.spot_sale_qty,0)*nvl(fms.local_spot_price,0)),nvl(nvl(fms.sale_qty,0)*nvl(fms.local_spot_price,0),0)), -- QA: Arvid / Stina
             fms.local_net_revenue   =  nvl(nvl(decode(nvl(lv_prod_coll_type,0),'GAS_SALES',nvl(fms.term_sale_qty,0)*nvl(fms.local_term_price,0)+(nvl(fms.spot_sale_qty,0)*nvl(fms.local_spot_price,0))
                                      ,nvl(nvl(fms.sale_qty,0)*nvl(fms.local_spot_price,0),0)),0)+(nvl(nvl(fms.sale_qty,0)*nvl(fms.local_spot_price,0),0)*(nvl(fms.pct_adj_price,0)/100)),0)+nvl(fms.value_adj_price,0)
       WHERE fms.object_id = p_object_id
         AND fms.daytime = p_daytime
         AND fms.member_no = p_member_no;

         -- Need to populate inventory numbers stepwise
         ln_inv_opening_pos_tmp  := ec_fcst_mth_status.inv_opening_pos_qty(p_member_no,p_daytime);
         ln_inv_rate_tmp         := ec_fcst_mth_status.inv_rate(p_member_no,p_daytime);

         UPDATE fcst_mth_status fms_clp
            SET fms_clp.inv_closing_pos_qty = nvl(ln_inv_movement, 0) + nvl(ln_inv_opening_pos_tmp, 0)
          WHERE fms_clp.daytime = p_daytime
            AND fms_clp.member_no = p_member_no;

          ln_inv_closing_pos_qty_tmp   := ec_fcst_mth_status.inv_closing_pos_qty(p_member_no,p_daytime);

              UPDATE fcst_mth_status fms_clp
            SET fms_clp.inv_closing_value = nvl(ln_inv_rate_tmp,0) * nvl(ln_inv_closing_pos_qty_tmp,0)
          WHERE fms_clp.daytime = p_daytime
            AND fms_clp.member_no = p_member_no;


            -- Cleanup
            ln_inv_opening_pos_tmp        := NULL;
            ln_inv_rate_tmp               := NULL;
            ln_inv_closing_pos_qty_tmp    := NULL;


    -- Done populating inventory numbers


  ELSIF lv_prod_coll_type = 'GAS_PURCHASE' THEN

  -- Determining local net revenue for purchase forecast case
SELECT ((-nvl(p_term_base_price,0)) * nvl(p_forex,0) * NVL(p_net_qty_plan,fms.net_qty)) +
       (nvl(fms.sales_price,0) * nvl(p_forex,0) * NVL(p_net_qty_plan,fms.net_qty))
  INTO ln_purch_net_revenue
  FROM fcst_mth_status fms
 WHERE fms.object_id = p_object_id
   AND fms.daytime = p_daytime
   AND fms.member_no = p_member_no;


-- Update fcst_mth_status
          UPDATE fcst_mth_status fms
             SET fms.cost_price        = -p_term_base_price,             -- Cost price should be represented as negative values
                 fms.forex             = p_forex,
                 fms.forex_currency_id = lv_forex_currency_id,
                 fms.price_currency_id = lv_price_currency_id,
                 fms.status             = 'PLAN',                          -- QA: Arvid / Stina
                 fms.base_price         = decode(lv_price_object_id,null,fms.base_price,p_term_base_price),
--                 fms.differential       = decode(lv_price_object_id,null,fms.differential, DECODE(p_term_base_price, null, null, 0)),
                 fms.net_price          = ln_net_price,
                 fms.net_qty            = nvl(p_net_qty_plan,fms.net_qty),    -- QA: Arvid / Stina
                 fms.uom                = nvl(p_uom,fms.uom),    --
                 fms.local_net_revenue = ln_purch_net_revenue
           WHERE fms.object_id = p_object_id
             AND fms.daytime = p_daytime
             AND fms.member_no = p_member_no;

END IF;

END popRevnFcstPlan;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :   popRevnFcstYTM
-- Description    :   Populates a revenue forecast Year to Month case
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE popRevnFcstYTM(p_object_id               VARCHAR2, -- Forecast object_id
                         p_forex                   NUMBER,
                         p_stream_item_id          VARCHAR2,
                         p_product_id              VARCHAR2,
                         p_product_context         VARCHAR2,
                         p_product_collection_type VARCHAR2,
                         p_member_no               VARCHAR2,
                         p_daytime                 DATE,
                         p_comm_adj                NUMBER,
                         p_swap_adj                NUMBER,
                         p_status                  VARCHAR2,
                         p_term_base_price         NUMBER,
                         p_spot_base_price         NUMBER,
                         p_prior_to_plan_date      VARCHAR2,
                         p_act_net_price           NUMBER,
                         p_net_qty                 NUMBER,
                         p_sale_qty                NUMBER,
                         p_uom                     VARCHAR2,
                         p_net_qty_plan            NUMBER,
                         p_spot_sale_qty           NUMBER,
                         p_term_sale_qty           NUMBER,
                         p_local_gross_revenue     NUMBER,
                         p_value_adj               NUMBER,
                         p_local_non_adj_revenue   NUMBER,
                         p_ln_gpurch_net_qty       NUMBER,
                         p_act_net_cost            NUMBER,
                         p_local_term_price        NUMBER DEFAULT NULL,
                         p_local_spot_price        NUMBER DEFAULT NULL)
--</EC-DOC>

IS
lv_forex_currency_id      VARCHAR2(32);
lv_price_currency_id      VARCHAR2(32);
ln_net_price              NUMBER := 0;
lv_official_fcst_id       VARCHAR2(32);
ln_off_swap_adj           NUMBER;
ln_off_comm_adj           NUMBER;
lv_prod_coll_type         VARCHAR2(32);
lv_price_object_id        VARCHAR2(32);
ln_pct_adj                NUMBER;
ln_local_net_revenue      NUMBER;
ln_purch_net_revenue      NUMBER;
lv2_status                VARCHAR2(32);
ln_available_for_sale     NUMBER;
ln_diff                   NUMBER;
ln_closing_pos_last_mth   NUMBER;
ln_last_actual_inv_rate   NUMBER;
ln_inv_closing_pos_qty    NUMBER;
ln_inv_closing_value      NUMBER;

lrec_inv t_fcst_inv_rec := null;

ln_inv_opening_pos_tmp NUMBER;
ln_inv_rate_tmp        NUMBER;
ln_inv_closing_pos_qty_tmp NUMBER;

BEGIN

    -- Use p_base_price calc
    SELECT (p_term_base_price + NVL(differential, 0))
      INTO ln_net_price
      FROM fcst_mth_status f
     WHERE f.object_id = p_object_id
       AND f.daytime = p_daytime
       AND f.member_no = p_member_no;

    -- Use base_price calc if no price is found
    IF (ln_net_price IS NULL) THEN
          SELECT (base_price + NVL(differential, 0))
            INTO ln_net_price
            FROM fcst_mth_status f
           WHERE f.object_id = p_object_id
             AND f.daytime = p_daytime
             AND f.member_no = p_member_no;
    END IF;

lv_forex_currency_id := ec_company_version.local_currency_id(ec_forecast_version.company_id(p_object_id,p_daytime,'<='),p_daytime,'<=');
lv_price_currency_id := ec_fcst_product_setup.currency_id(p_object_id,p_product_id,p_product_context,p_product_collection_type);
lv_prod_coll_type := ec_fcst_member.product_collection_type(p_member_no);
lv_price_object_id := ec_fcst_product_setup.product_price_id(p_object_id,p_product_id,p_product_context,p_product_collection_type);

IF p_prior_to_plan_date = 'TRUE' THEN

  IF nvl(p_local_gross_revenue,0) < 1 AND nvl(p_local_gross_revenue,0) > -1 THEN
     ln_pct_adj := -(1-(NVL(p_local_non_adj_revenue,0)/1));

  ELSE
      ln_pct_adj := -(1-(NVL(p_local_non_adj_revenue,0)/(NVL(p_local_gross_revenue,1))));

  END IF;


  ln_pct_adj := ln_pct_adj*100;

  IF NVL(p_local_non_adj_revenue,0) = 0 OR NVL(p_local_gross_revenue,0) = 0 THEN
     ln_pct_adj := 0;
  END IF;



  lrec_inv := getInventoryClosingPos(p_object_id, p_member_no, p_uom, p_daytime);

  ln_local_net_revenue := nvl(p_local_gross_revenue,0) + (nvl(p_local_gross_revenue,0)*(nvl(ln_pct_adj,0)/100))+nvl(p_value_adj,0);

  -- Determining local net revenue for purchase forecast case
  SELECT (-(nvl(p_act_net_cost,0)/p_forex) * nvl(p_forex,0) * NVL(p_ln_gpurch_net_qty,0)) +
         (0 * nvl(p_forex,0) * NVL(p_ln_gpurch_net_qty,0))
    INTO ln_purch_net_revenue
    FROM fcst_mth_status fms
   WHERE fms.object_id = p_object_id
     AND fms.daytime = p_daytime
     AND fms.member_no = p_member_no;

  -- Determining status for actual records
  SELECT decode(lv_prod_coll_type,
                'GAS_PURCHASE',
                ecdp_contract_setup.GetDocumentsStatus(ec_fcst_member.contract_id(p_member_no)),
                p_status)
    INTO lv2_status
    FROM fcst_member f
   WHERE f.member_no = p_member_no;

  -- Update fcst_mth_status
    UPDATE fcst_mth_status fms
       SET fms.cost_price        = decode(lv_prod_coll_type,'GAS_PURCHASE',-(nvl(p_act_net_cost,0)/p_forex),fms.cost_price),              -- Cost price should be represented as negative values
           fms.forex             = p_forex,
           fms.forex_currency_id = lv_forex_currency_id,
           fms.price_currency_id = lv_price_currency_id,
           fms.commercial_adj_qty = p_comm_adj,
           fms.swap_adj_qty       = p_swap_adj,
           fms.status             = lv2_status,                  -- QA: Arvid / Stina
           fms.base_price         = NULL,
           fms.differential       = NULL,
           fms.sales_price        = 0,
           fms.term_price         = p_local_term_price/p_forex,
           fms.net_price          = p_act_net_price/p_forex,
           fms.spot_price         = decode(lv_prod_coll_type,'GAS_SALES',nvl(p_local_spot_price,0)/p_forex,nvl(p_act_net_price,0)/p_forex),
           fms.local_spot_price   = decode(lv_prod_coll_type,'GAS_SALES',p_local_spot_price,p_act_net_price),
           fms.local_term_price   = p_local_term_price,
           fms.net_qty            = decode(lv_prod_coll_type,'GAS_PURCHASE',NVL(p_ln_gpurch_net_qty,0),nvl(p_net_qty,0)),                  -- QA: Arvid / Stina
           fms.uom                = NVL(p_uom, fms.uom),
           fms.sale_qty           = nvl(p_sale_qty,0),
           fms.spot_sale_qty      = nvl(p_spot_sale_qty,0),
           fms.term_sale_qty      = nvl(p_term_sale_qty,0),
           fms.local_net_revenue  = decode(lv_prod_coll_type,'GAS_PURCHASE',ln_purch_net_revenue,ln_local_net_revenue),
           fms.local_gross_revenue = p_local_gross_revenue,
           fms.value_adj_price     = p_value_adj,
           fms.pct_adj_price       = ln_pct_adj,
           fms.inv_opening_pos_qty = decode(lv_prod_coll_type,'GAS_PURCHASE',fms.inv_opening_pos_qty,lrec_inv.opening_pos_qty),
           fms.inv_closing_pos_qty = decode(lv_prod_coll_type,'GAS_PURCHASE',fms.inv_closing_pos_qty,lrec_inv.closing_pos_qty),
           fms.inv_closing_value   = decode(lv_prod_coll_type,'GAS_PURCHASE',fms.inv_closing_value,lrec_inv.closing_value),
           fms.inv_rate            = decode(lv_prod_coll_type,'GAS_PURCHASE',fms.inv_rate,lrec_inv.rate)
     WHERE fms.object_id = p_object_id
       AND fms.daytime = p_daytime
       AND fms.member_no = p_member_no;



  ELSIF p_prior_to_plan_date = 'FALSE' THEN

    -- Determining local net revenue for purchase forecast case
    SELECT ((-nvl(p_term_base_price,0)) * nvl(p_forex,0) * NVL(p_net_qty_plan,fms.net_qty)) +
           (nvl(fms.sales_price,0) * nvl(p_forex,0) * NVL(p_net_qty_plan,fms.net_qty))
      INTO ln_purch_net_revenue
      FROM fcst_mth_status fms
     WHERE fms.object_id = p_object_id
       AND fms.daytime = p_daytime
       AND fms.member_no = p_member_no;

    -- Retrieving closing position for last month. Will be null if this is the first month
    ln_closing_pos_last_mth := ec_fcst_mth_status.inv_closing_pos_qty(p_member_no,add_months(p_daytime,-1));

    -- Retrieving the last actual inventory rate which means the rate from the last month before the plan date
    ln_last_actual_inv_rate := ec_fcst_mth_status.inv_rate(p_member_no,ec_forecast_version.plan_date(p_object_id,p_daytime,'<='));


    IF (lv_prod_coll_type <> 'GAS_PURCHASE') THEN
        ln_available_for_sale := p_net_qty_plan + nvl(p_comm_adj, 0) + nvl(p_swap_adj, 0) + NVL(ln_closing_pos_last_mth, NVL(lrec_inv.opening_pos_qty, 0));
    ELSE
        ln_available_for_sale := p_net_qty_plan + nvl(p_comm_adj, 0) + nvl(p_swap_adj, 0);
    END IF;

    IF (lv_price_object_id IS NULL AND ec_fcst_mth_status.base_price(p_member_no, p_daytime) IS NOT NULL) THEN
        ln_diff := 0;
    ELSIF (p_term_base_price IS NOT NULL AND lv_price_object_id IS NOT NULL) THEN
        ln_diff := 0;
    ELSE
        ln_diff := NULL;
    END IF;


    -- Update fcst_mth_status
    UPDATE fcst_mth_status fms
       SET fms.cost_price        = -p_term_base_price,                      -- Cost price should be represented as negative values
           fms.forex             = p_forex,
           fms.forex_currency_id = lv_forex_currency_id,
           fms.price_currency_id = lv_price_currency_id,
           fms.status             = 'PLAN',                          -- QA: Arvid / Stina
--           fms.base_price         = NVL(fms.base_price, decode(lv_price_object_id,null,fms.base_price,p_base_price)),
           fms.base_price         = decode(lv_price_object_id,null,fms.base_price,p_term_base_price),
           fms.differential       = NVL(fms.differential, ln_diff),
           fms.net_price          = ln_net_price,
           fms.spot_price         = decode(lv_price_object_id,null,fms.base_price,p_spot_base_price),
           fms.term_price         = decode(lv_price_object_id,null,fms.base_price,p_term_base_price),
           fms.local_spot_price   = decode(lv_prod_coll_type,'GAS_SALES',decode(lv_price_object_id,null,fms.spot_price,nvl(p_spot_base_price,0)*p_forex),(ln_net_price*p_forex)),--ln_net_price*p_forex,
           fms.local_term_price   = decode(lv_price_object_id,null,fms.term_price,nvl(p_term_base_price,0))*p_forex,
           fms.net_qty            = NVL(p_net_qty_plan,fms.net_qty),    -- QA: Arvid / Stina
           fms.sale_qty           = NVL(fms.sale_qty, ln_available_for_sale),
           fms.uom                = NVL(p_uom, fms.uom),
           fms.inv_opening_pos_qty = decode(lv_prod_coll_type,'GAS_PURCHASE',fms.inv_opening_pos_qty,nvl(ln_closing_pos_last_mth,fms.inv_opening_pos_qty)),
         --  fms.inv_closing_pos_qty = decode(lv_prod_coll_type,'GAS_PURCHASE',fms.inv_closing_pos_qty,nvl(ln_inv_closing_pos_qty,0) + nvl(ln_closing_pos_last_mth,0)),
           fms.inv_rate            = decode(lv_prod_coll_type,'GAS_PURCHASE',fms.inv_rate,nvl(fms.inv_rate,ln_last_actual_inv_rate))
          -- fms.inv_closing_value   = decode(lv_prod_coll_type,'GAS_PURCHASE',fms.inv_closing_value,nvl(ln_inv_closing_value,0) *  nvl(ln_last_actual_inv_rate,0))
     WHERE fms.object_id = p_object_id
       AND fms.daytime = p_daytime
       AND fms.member_no = p_member_no;

    -- Do another update in order to be able to use the variables updated in the previous update
      UPDATE fcst_mth_status fms
         SET
           fms.local_gross_revenue = decode(nvl(lv_prod_coll_type,0),'GAS_SALES',nvl(fms.term_sale_qty,0)*nvl(fms.local_term_price,0)+(nvl(fms.spot_sale_qty,0)*nvl(fms.local_spot_price,0)),nvl(nvl(fms.sale_qty,0)*nvl(fms.local_spot_price,0),0)), -- QA: Arvid / Stina
           fms.local_net_revenue = nvl(nvl(decode(nvl(lv_prod_coll_type,0),'GAS_PURCHASE',ln_purch_net_revenue,'GAS_SALES',nvl(fms.term_sale_qty,0)*nvl(fms.local_term_price,0)+(nvl(fms.spot_sale_qty,0)*nvl(fms.local_spot_price,0)),nvl(nvl(fms.sale_qty,0)*nvl(fms.local_spot_price,0),0)),0)+(nvl(fms.sale_qty*fms.local_spot_price,0)*(nvl(fms.pct_adj_price,0)/100)),0)+nvl(fms.value_adj_price,0)
       WHERE fms.object_id = p_object_id
         AND fms.daytime = p_daytime
         AND fms.member_no = p_member_no;

    -- Need to populate inventory numbers stepwise
    -- Retrieving Inventory movements
    ln_inv_closing_pos_qty := getInventoryMovement(p_member_no,p_daytime,lv_prod_coll_type);
    ln_inv_closing_value := getInventoryMovement(p_member_no,p_daytime,lv_prod_coll_type) + nvl(ln_closing_pos_last_mth,0);
    ln_inv_opening_pos_tmp  := ec_fcst_mth_status.inv_opening_pos_qty(p_member_no,p_daytime);
    ln_inv_rate_tmp         := ec_fcst_mth_status.inv_rate(p_member_no,p_daytime);


         UPDATE fcst_mth_status fms_clp
            SET fms_clp.inv_closing_pos_qty = decode(lv_prod_coll_type,'GAS_PURCHASE',fms_clp.inv_closing_pos_qty,nvl(ln_inv_opening_pos_tmp,0) + nvl(ln_inv_closing_pos_qty,0))
          WHERE fms_clp.daytime = p_daytime
            AND fms_clp.member_no = p_member_no;

          ln_inv_closing_pos_qty_tmp   := ec_fcst_mth_status.inv_closing_pos_qty(p_member_no,p_daytime);

              UPDATE fcst_mth_status fms_clp
            SET fms_clp.inv_closing_value = nvl(ln_inv_rate_tmp,0) * nvl(ln_inv_closing_pos_qty_tmp,0)
          WHERE fms_clp.daytime = p_daytime
            AND fms_clp.member_no = p_member_no;

            -- Cleanup
            ln_inv_opening_pos_tmp        := NULL;
            ln_inv_rate_tmp               := NULL;
            ln_inv_closing_pos_qty_tmp    := NULL;

    -- Done populating inventory numbers

     IF lv_prod_coll_type = 'GAS_SALES' THEN
       -- Update the split between spot and term sales qty
       updateFcstGSSpotTermQty(p_member_no, p_daytime);
     END IF;
  END IF;

END popRevnFcstYTM;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   copyFcstObj
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION copyFcstObj(
   p_object_id VARCHAR2,
   p_daytime   DATE, -- start date
   p_user      VARCHAR2)

RETURN VARCHAR2 -- new contract object_id
--</EC-DOC>
IS

lf_new_member_no NUMBER;

CURSOR c_ov_forecast IS
SELECT
    fc.object_code fc_object_code,
    fc.start_date fc_start_date,
    fc.end_date fc_end_date,
    fc.functional_area_code fc_functional_area_code,
    fc.description fc_description,
    fc.created_by fc_created_by,
    fcv.object_id fcv_object_id,
    fcv.daytime fcv_daytime,
    fcv.end_date fcv_end_date,
    fcv.name fcv_name,
    fcv.populate_method fcv_populate_method,
    fcv.company_id fcv_company_id,
    fcv.forecast_id fcv_forecast_id,
    fcv.official_ind fcv_official_ind,
    fcv.field_group_type fcv_field_group_type,
    fcv.product_sum_uom fcv_product_sum_uom,
    fcv.forecast_scope fcv_forecast_scope,
    fcv.period_type fcv_period_type,
    fcv.probability fcv_probability,
    fcv.comments fcv_comments,
    fcv.forex_source_id fcv_forex_source_id,
    fcv.time_scope fcv_time_scope,
    fcv.plan_date fcv_plan_date,
    fcv.created_by fcv_created_by,
    fcv.populate_date fcv_populate_date,
    fcv.populate_by fcv_populate_by,
    fcv.text_1,
    fcv.text_2,
    fcv.text_3,
    fcv.text_4,
    fcv.text_5,
    fcv.text_6,
    fcv.text_7,
    fcv.text_8,
    fcv.text_9,
    fcv.text_10,
    fcv.value_1,
    fcv.value_2,
    fcv.value_3,
    fcv.value_4,
    fcv.value_5,
    fcv.date_1,
    fcv.date_2,
    fcv.date_3,
    fcv.date_4,
    fcv.date_5,
    fcv.ref_object_id_1,
    fcv.ref_object_id_2,
    fcv.ref_object_id_3,
    fcv.ref_object_id_4,
    fcv.ref_object_id_5
FROM forecast fc, forecast_version fcv
WHERE fc.object_id = p_object_id
   AND fc.object_id = fcv.object_id
   AND p_daytime >= fcv.daytime
   AND p_daytime < nvl(fcv.end_date, p_daytime + 1)
   AND p_daytime >= Nvl(fc.start_date, p_daytime - 1)
   AND p_daytime < Nvl(fc.end_date, p_daytime + 1);

lv2_fc_object_code forecast.object_code%TYPE;
ld_fc_start_date DATE := ec_forecast.start_date(p_object_id);
lv2_fcv_object_id forecast_version.object_id%TYPE;
lv2_fcv_name forecast_version.name%TYPE;

invalid_start_date EXCEPTION;

    --copying FCST_PRODUCT_SETUP
    /*CURSOR c_fcst_product_setup IS
    SELECT lv2_fcv_object_id, PRODUCT_ID, PRODUCT_COLLECTION_TYPE, PRODUCT_UOM, PRODUCT_LABEL, COMMERCIAL_ADJ_TYPE, SWAP_ADJ_TYPE, VALUE_ADJ_TYPE, PCT_ADJ_IND, PRODUCT_PRICE_ID, CURRENCY_ID, CPY_ADJ_STREAM_ITEM_ID, FULL_ADJ_STREAM_ITEM_ID, SORT_ORDER, COMMENTS, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, VALUE_10, TEXT_1, TEXT_2, TEXT_3, TEXT_4, DATE_1, DATE_2, DATE_3, DATE_4, DATE_5
    FROM fcst_product_setup WHERE object_id = p_object_id;*/

    --copying FCST_MEMBER
    CURSOR c_fcst_member IS
    SELECT lv2_fcv_object_id,
           MEMBER_NO,
           MEMBER_TYPE,
           FIELD_ID,
           PRODUCT_ID,
           CONTRACT_ID,
           STREAM_ITEM_ID,
           ADJ_STREAM_ITEM_ID,
           PRODUCT_COLLECTION_TYPE,
           COMMENTS,
           SPLIT_KEY_ID,
           INVENTORY1_ID,
           INVENTORY2_ID,
           INVENTORY3_ID,
           INVENTORY4_ID,
           INVENTORY5_ID,
           VALUE_1,
           VALUE_2,
           VALUE_3,
           VALUE_4,
           VALUE_5,
           VALUE_6,
           VALUE_7,
           VALUE_8,
           VALUE_9,
           VALUE_10,
           TEXT_1,
           TEXT_2,
           TEXT_3,
           TEXT_4,
           DATE_1,
           DATE_2,
           DATE_3,
           DATE_4,
           DATE_5,
           PRODUCT_CONTEXT,
           SWAP_STREAM_ITEM_ID
      FROM fcst_member
     WHERE object_id = p_object_id;

    CURSOR c_stim_fcst IS
    SELECT * FROM stim_fcst_mth_value sfmv WHERE sfmv.forecast_id = p_object_id;

    --copying FCST_MTH_STATUS
    /*CURSOR c_fcst_mth_status IS
    SELECT lv2_fcv_object_id, MEMBER_NO, DAYTIME, NET_QTY, UOM, COMMERCIAL_ADJ_QTY, SWAP_ADJ_QTY, VALUE_ADJ_QTY, PCT_ADJ_QTY, TERM_SALE_QTY, SPOT_SALE_QTY, BASE_PRICE, TERM_PRICE, SPOT_PRICE, COST_PRICE, SALES_PRICE, FOREX, FOREX_CURRENCY_ID, PRICE_CURRENCY_ID, DIFFERENTIAL, VALUE_ADJ_PRICE, PCT_ADJ_PRICE, COMMENTS, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, VALUE_10, TEXT_1, TEXT_2, TEXT_3, TEXT_4, DATE_1, DATE_2, DATE_3, DATE_4, DATE_5
    FROM fcst_mth_status WHERE object_id = p_object_id;*/

BEGIN

     IF (p_daytime < ld_fc_start_date) THEN
        RAISE invalid_start_date;
     END IF;

     FOR c_val IN c_ov_forecast LOOP

       lv2_fc_object_code := Ecdp_Object_Copy.GetCopyObjectCode('FORECAST',c_val.fc_object_code || '_COPY');

       INSERT INTO forecast
         (class_name,
         object_code,
          start_date,
          end_date,
          functional_area_code,
          description,
          created_by)
       VALUES
         ('FORECAST',
          lv2_fc_object_code,
          c_val.fc_start_date ,
          c_val.fc_end_date,
          c_val.fc_functional_area_code,
          c_val.fc_description,
          p_user)
      RETURNING object_id INTO lv2_fcv_object_id;



         INSERT INTO forecast_version
         (object_id,
          daytime,
          end_date,
          name,
          populate_method,
          company_id,
          forecast_id,
          official_ind,
          field_group_type,
          product_sum_uom,
          forecast_scope,
          period_type,
          probability,
          forex_source_id,
          time_scope,
          comments,
          plan_date,
          created_by,
          populate_date,
          populate_by,
          text_1,
          text_2,
          text_3,
          text_4,
          text_5,
          text_6,
          text_7,
          text_8,
          text_9,
          text_10,
          value_1,
          value_2,
          value_3,
          value_4,
          value_5,
          date_1,
          date_2,
          date_3,
          date_4,
          date_5,
          ref_object_id_1,
          ref_object_id_2,
          ref_object_id_3,
          ref_object_id_4,
          ref_object_id_5
          )
       VALUES
         (lv2_fcv_object_id,
          c_val.fcv_daytime,
          c_val.fcv_end_date,
          c_val.fcv_name,
          c_val.fcv_populate_method,
          c_val.fcv_company_id,
          c_val.fcv_forecast_id,
          'N',
          c_val.fcv_field_group_type,
          c_val.fcv_product_sum_uom,
          c_val.fcv_forecast_scope,
          c_val.fcv_period_type,
          c_val.fcv_probability,
          c_val.fcv_forex_source_id,
          c_val.fcv_time_scope,
          c_val.fcv_comments,
          c_val.fcv_plan_date,
          p_user,
          c_val.fcv_populate_date,
          c_val.fcv_populate_by,
          c_val.text_1,
          c_val.text_2,
          c_val.text_3,
          c_val.text_4,
          c_val.text_5,
          c_val.text_6,
          c_val.text_7,
          c_val.text_8,
          c_val.text_9,
          c_val.text_10,
          c_val.value_1,
          c_val.value_2,
          c_val.value_3,
          c_val.value_4,
          c_val.value_5,
          c_val.date_1,
          c_val.date_2,
          c_val.date_3,
          c_val.date_4,
          c_val.date_5,
          c_val.ref_object_id_1,
          c_val.ref_object_id_2,
          c_val.ref_object_id_3,
          c_val.ref_object_id_4,
          c_val.ref_object_id_5);

    END LOOP;



    --copying FCST_PRODUCT_SETUP
    INSERT INTO fcst_product_setup
      (OBJECT_ID,
       PRODUCT_ID,
       PRODUCT_COLLECTION_TYPE,
       PRODUCT_UOM,
       PRODUCT_LABEL,
       COMMERCIAL_ADJ_TYPE,
       SWAP_ADJ_TYPE,
       VALUE_ADJ_TYPE,
       PCT_ADJ_IND,
       PRODUCT_PRICE_ID,
       CURRENCY_ID,
       CPY_ADJ_STREAM_ITEM_ID,
       FULL_ADJ_STREAM_ITEM_ID,
       SORT_ORDER,
       COMMENTS,
       VALUE_1,
       VALUE_2,
       VALUE_3,
       VALUE_4,
       VALUE_5,
       VALUE_6,
       VALUE_7,
       VALUE_8,
       VALUE_9,
       VALUE_10,
       TEXT_1,
       TEXT_2,
       TEXT_3,
       TEXT_4,
       DATE_1,
       DATE_2,
       DATE_3,
       DATE_4,
       DATE_5,
       PRODUCT_CONTEXT)
      SELECT lv2_fcv_object_id,
             PRODUCT_ID,
             PRODUCT_COLLECTION_TYPE,
             PRODUCT_UOM,
             PRODUCT_LABEL,
             COMMERCIAL_ADJ_TYPE,
             SWAP_ADJ_TYPE,
             VALUE_ADJ_TYPE,
             PCT_ADJ_IND,
             PRODUCT_PRICE_ID,
             CURRENCY_ID,
             CPY_ADJ_STREAM_ITEM_ID,
             FULL_ADJ_STREAM_ITEM_ID,
             SORT_ORDER,
             COMMENTS,
             VALUE_1,
             VALUE_2,
             VALUE_3,
             VALUE_4,
             VALUE_5,
             VALUE_6,
             VALUE_7,
             VALUE_8,
             VALUE_9,
             VALUE_10,
             TEXT_1,
             TEXT_2,
             TEXT_3,
             TEXT_4,
             DATE_1,
             DATE_2,
             DATE_3,
             DATE_4,
             DATE_5,
             PRODUCT_CONTEXT
        FROM fcst_product_setup
       WHERE object_id = p_object_id;


    FOR c_val IN c_fcst_member LOOP

        EcDp_System_Key.assignNextNumber('FCST_MEMBER', lf_new_member_no);
        INSERT INTO fcst_member
          (OBJECT_ID,
           MEMBER_NO,
           MEMBER_TYPE,
           FIELD_ID,
           PRODUCT_ID,
           CONTRACT_ID,
           STREAM_ITEM_ID,
           ADJ_STREAM_ITEM_ID,
           PRODUCT_COLLECTION_TYPE,
           COMMENTS,
           SPLIT_KEY_ID,
           INVENTORY1_ID,
           INVENTORY2_ID,
           INVENTORY3_ID,
           INVENTORY4_ID,
           INVENTORY5_ID,
           VALUE_1,
           VALUE_2,
           VALUE_3,
           VALUE_4,
           VALUE_5,
           VALUE_6,
           VALUE_7,
           VALUE_8,
           VALUE_9,
           VALUE_10,
           TEXT_1,
           TEXT_2,
           TEXT_3,
           TEXT_4,
           DATE_1,
           DATE_2,
           DATE_3,
           DATE_4,
           DATE_5,
           PRODUCT_CONTEXT,
           SWAP_STREAM_ITEM_ID)
        VALUES
          (lv2_fcv_object_id,
           lf_new_member_no,
           c_val.MEMBER_TYPE,
           c_val.FIELD_ID,
           c_val.PRODUCT_ID,
           c_val.CONTRACT_ID,
           c_val.STREAM_ITEM_ID,
           c_val.ADJ_STREAM_ITEM_ID,
           c_val.PRODUCT_COLLECTION_TYPE,
           c_val.COMMENTS,
           c_val.SPLIT_KEY_ID,
           c_val.INVENTORY1_ID,
           c_val.INVENTORY2_ID,
           c_val.INVENTORY3_ID,
           c_val.INVENTORY4_ID,
           c_val.INVENTORY5_ID,
           c_val.VALUE_1,
           c_val.VALUE_2,
           c_val.VALUE_3,
           c_val.VALUE_4,
           c_val.VALUE_5,
           c_val.VALUE_6,
           c_val.VALUE_7,
           c_val.VALUE_8,
           c_val.VALUE_9,
           c_val.VALUE_10,
           c_val.TEXT_1,
           c_val.TEXT_2,
           c_val.TEXT_3,
           c_val.TEXT_4,
           c_val.DATE_1,
           c_val.DATE_2,
           c_val.DATE_3,
           c_val.DATE_4,
           c_val.DATE_5,
           c_val.PRODUCT_CONTEXT,
           c_val.SWAP_STREAM_ITEM_ID);

        INSERT INTO fcst_mth_status
          (OBJECT_ID,
           MEMBER_NO,
           DAYTIME,
           NET_QTY,
           UOM,
           LOCAL_GROSS_REVENUE,
           LOCAL_NET_REVENUE,
           LOCAL_SPOT_PRICE,
           LOCAL_TERM_PRICE,
           NET_PRICE,
           COMMERCIAL_ADJ_QTY,
           SWAP_ADJ_QTY,
           VALUE_ADJ_QTY,
           PCT_ADJ_QTY,
           SALE_QTY,
           TERM_SALE_QTY,
           SPOT_SALE_QTY,
           BASE_PRICE,
           TERM_PRICE,
           SPOT_PRICE,
           COST_PRICE,
           SALES_PRICE,
           FOREX,
           FOREX_CURRENCY_ID,
           PRICE_CURRENCY_ID,
           DIFFERENTIAL,
           VALUE_ADJ_PRICE,
           PCT_ADJ_PRICE,
           INV_CLOSING_POS_QTY,
           INV_CLOSING_VALUE,
           INV_OPENING_POS_QTY,
           INV_RATE,
           COMMENTS,
           VALUE_1,
           VALUE_2,
           VALUE_3,
           VALUE_4,
           VALUE_5,
           VALUE_6,
           VALUE_7,
           VALUE_8,
           VALUE_9,
           VALUE_10,
           TEXT_1,
           TEXT_2,
           TEXT_3,
           TEXT_4,
           DATE_1,
           DATE_2,
           DATE_3,
           DATE_4,
           DATE_5,
           STATUS)
          SELECT lv2_fcv_object_id,
                 lf_new_member_no,
                 DAYTIME,
                 NET_QTY,
                 UOM,
                 LOCAL_GROSS_REVENUE,
                 LOCAL_NET_REVENUE,
                 LOCAL_SPOT_PRICE,
                 LOCAL_TERM_PRICE,
                 NET_PRICE,
                 COMMERCIAL_ADJ_QTY,
                 SWAP_ADJ_QTY,
                 VALUE_ADJ_QTY,
                 PCT_ADJ_QTY,
                 SALE_QTY,
                 TERM_SALE_QTY,
                 SPOT_SALE_QTY,
                 BASE_PRICE,
                 TERM_PRICE,
                 SPOT_PRICE,
                 COST_PRICE,
                 SALES_PRICE,
                 FOREX,
                 FOREX_CURRENCY_ID,
                 PRICE_CURRENCY_ID,
                 DIFFERENTIAL,
                 VALUE_ADJ_PRICE,
                 PCT_ADJ_PRICE,
                 INV_CLOSING_POS_QTY,
                 INV_CLOSING_VALUE,
                 INV_OPENING_POS_QTY,
                 INV_RATE,
                 COMMENTS,
                 VALUE_1,
                 VALUE_2,
                 VALUE_3,
                 VALUE_4,
                 VALUE_5,
                 VALUE_6,
                 VALUE_7,
                 VALUE_8,
                 VALUE_9,
                 VALUE_10,
                 TEXT_1,
                 TEXT_2,
                 TEXT_3,
                 TEXT_4,
                 DATE_1,
                 DATE_2,
                 DATE_3,
                 DATE_4,
                 DATE_5,
                 STATUS
            FROM fcst_mth_status
           WHERE object_id = p_object_id
             and member_no = c_val.member_no;

        INSERT INTO fcst_yr_status
          (OBJECT_ID,
           MEMBER_NO,
           DAYTIME,
           NET_QTY,
           UOM,
           LOCAL_GROSS_REVENUE,
           LOCAL_NET_REVENUE,
           LOCAL_SPOT_PRICE,
           LOCAL_TERM_PRICE,
           NET_PRICE,
           COMMERCIAL_ADJ_QTY,
           SWAP_ADJ_QTY,
           VALUE_ADJ_QTY,
           PCT_ADJ_QTY,
           SALE_QTY,
           TERM_SALE_QTY,
           SPOT_SALE_QTY,
           BASE_PRICE,
           TERM_PRICE,
           SPOT_PRICE,
           COST_PRICE,
           SALES_PRICE,
           FOREX,
           FOREX_CURRENCY_ID,
           PRICE_CURRENCY_ID,
           DIFFERENTIAL,
           VALUE_ADJ_PRICE,
           PCT_ADJ_PRICE,
           INV_CLOSING_POS_QTY,
           INV_CLOSING_VALUE,
           INV_OPENING_POS_QTY,
           INV_RATE,
           COMMENTS,
           VALUE_1,
           VALUE_2,
           VALUE_3,
           VALUE_4,
           VALUE_5,
           VALUE_6,
           VALUE_7,
           VALUE_8,
           VALUE_9,
           VALUE_10,
           TEXT_1,
           TEXT_2,
           TEXT_3,
           TEXT_4,
           DATE_1,
           DATE_2,
           DATE_3,
           DATE_4,
           DATE_5,
           STATUS)
          SELECT lv2_fcv_object_id,
                 lf_new_member_no,
                 DAYTIME,
                 NET_QTY,
                 UOM,
                 LOCAL_GROSS_REVENUE,
                 LOCAL_NET_REVENUE,
                 LOCAL_SPOT_PRICE,
                 LOCAL_TERM_PRICE,
                 NET_PRICE,
                 COMMERCIAL_ADJ_QTY,
                 SWAP_ADJ_QTY,
                 VALUE_ADJ_QTY,
                 PCT_ADJ_QTY,
                 SALE_QTY,
                 TERM_SALE_QTY,
                 SPOT_SALE_QTY,
                 BASE_PRICE,
                 TERM_PRICE,
                 SPOT_PRICE,
                 COST_PRICE,
                 SALES_PRICE,
                 FOREX,
                 FOREX_CURRENCY_ID,
                 PRICE_CURRENCY_ID,
                 DIFFERENTIAL,
                 VALUE_ADJ_PRICE,
                 PCT_ADJ_PRICE,
                 INV_CLOSING_POS_QTY,
                 INV_CLOSING_VALUE,
                 INV_OPENING_POS_QTY,
                 INV_RATE,
                 COMMENTS,
                 VALUE_1,
                 VALUE_2,
                 VALUE_3,
                 VALUE_4,
                 VALUE_5,
                 VALUE_6,
                 VALUE_7,
                 VALUE_8,
                 VALUE_9,
                 VALUE_10,
                 TEXT_1,
                 TEXT_2,
                 TEXT_3,
                 TEXT_4,
                 DATE_1,
                 DATE_2,
                 DATE_3,
                 DATE_4,
                 DATE_5,
                 STATUS
            FROM fcst_yr_status
           WHERE object_id = p_object_id
             and member_no = c_val.member_no;

    END LOOP;

    -- Copy STIM_FCST_MTH_VALUE
    FOR CurStimFcst IN c_stim_fcst LOOP
        INSERT INTO stim_fcst_mth_value (
                        OBJECT_ID
                        ,FORECAST_ID
                        ,DAYTIME
                        ,STATUS
                        ,PERIOD_REF_ITEM
                        ,CALC_METHOD
                        ,BOOKING_STATUS
                        ,NET_MASS_VALUE
                        ,GROSS_MASS_VALUE
                        ,MASS_UOM_CODE
                        ,NET_VOLUME_VALUE
                        ,GROSS_VOLUME_VALUE
                        ,VOLUME_UOM_CODE
                        ,NET_ENERGY_VALUE
                        ,GROSS_ENERGY_VALUE
                        ,ENERGY_UOM_CODE
                        ,NET_EXTRA1_VALUE
                        ,GROSS_EXTRA1_VALUE
                        ,EXTRA1_UOM_CODE
                        ,NET_EXTRA2_VALUE
                        ,GROSS_EXTRA2_VALUE
                        ,EXTRA2_UOM_CODE
                        ,NET_EXTRA3_VALUE
                        ,GROSS_EXTRA3_VALUE
                        ,EXTRA3_UOM_CODE
                        ,GCV
                        ,GCV_ENERGY_UOM
                        ,GCV_VOLUME_UOM
                        ,DENSITY
                        ,DENSITY_MASS_UOM
                        ,DENSITY_VOLUME_UOM
                        ,MCV
                        ,MCV_ENERGY_UOM
                        ,MCV_MASS_UOM
                        ,SPLIT_SHARE
                        ,MASTER_UOM_GROUP
                        ,DENSITY_SOURCE_ID
                        ,GCV_SOURCE_ID
                        ,MCV_SOURCE_ID
                        ,COMMENTS
                        ,VALUE_1
                        ,VALUE_2
                        ,VALUE_3
                        ,VALUE_4
                        ,VALUE_5
                        ,VALUE_6
                        ,VALUE_7
                        ,VALUE_8
                        ,VALUE_9
                        ,VALUE_10
                        ,TEXT_1
                        ,TEXT_2
                        ,TEXT_3
                        ,TEXT_4
                        ,DATE_1
                        ,DATE_2
                        ,DATE_3
                        ,DATE_4
                        ,DATE_5
                        ,last_updated_by
        )
          SELECT OBJECT_ID
                        ,lv2_fcv_object_id
                        ,DAYTIME
                        ,STATUS
                        ,PERIOD_REF_ITEM
                        ,CALC_METHOD
                        ,BOOKING_STATUS
                        ,NET_MASS_VALUE
                        ,GROSS_MASS_VALUE
                        ,MASS_UOM_CODE
                        ,NET_VOLUME_VALUE
                        ,GROSS_VOLUME_VALUE
                        ,VOLUME_UOM_CODE
                        ,NET_ENERGY_VALUE
                        ,GROSS_ENERGY_VALUE
                        ,ENERGY_UOM_CODE
                        ,NET_EXTRA1_VALUE
                        ,GROSS_EXTRA1_VALUE
                        ,EXTRA1_UOM_CODE
                        ,NET_EXTRA2_VALUE
                        ,GROSS_EXTRA2_VALUE
                        ,EXTRA2_UOM_CODE
                        ,NET_EXTRA3_VALUE
                        ,GROSS_EXTRA3_VALUE
                        ,EXTRA3_UOM_CODE
                        ,GCV
                        ,GCV_ENERGY_UOM
                        ,GCV_VOLUME_UOM
                        ,DENSITY
                        ,DENSITY_MASS_UOM
                        ,DENSITY_VOLUME_UOM
                        ,MCV
                        ,MCV_ENERGY_UOM
                        ,MCV_MASS_UOM
                        ,SPLIT_SHARE
                        ,MASTER_UOM_GROUP
                        ,DENSITY_SOURCE_ID
                        ,GCV_SOURCE_ID
                        ,MCV_SOURCE_ID
                        ,COMMENTS
                        ,VALUE_1
                        ,VALUE_2
                        ,VALUE_3
                        ,VALUE_4
                        ,VALUE_5
                        ,VALUE_6
                        ,VALUE_7
                        ,VALUE_8
                        ,VALUE_9
                        ,VALUE_10
                        ,TEXT_1
                        ,TEXT_2
                        ,TEXT_3
                        ,TEXT_4
                        ,DATE_1
                        ,DATE_2
                        ,DATE_3
                        ,DATE_4
                        ,DATE_5
                        ,'INSTANTIATE' -- Last_Updated_By
              FROM stim_fcst_mth_value
              WHERE object_id = CurStimFcst.Object_Id
              AND forecast_id = CurStimFcst.Forecast_Id
              AND daytime = CurStimFcst.Daytime;
    END LOOP;



     RETURN lv2_fc_object_code;

EXCEPTION

         WHEN invalid_start_date THEN

              Raise_Application_Error(-20000,'Can not make a forecast copy before the original contract date.');

END copyFcstObj;

PROCEDURE delFcstObj(
   p_object_id VARCHAR2,
   p_user VARCHAR2
   )
IS
  ln_counter NUMBER;
BEGIN

 SELECT count(*) into ln_counter
 FROM forecast fc, forecast_version fcv
 WHERE fc.object_id = p_object_id
   AND fc.object_id = fcv.object_id
   /*AND p_daytime >= fcv.daytime
   AND p_daytime < nvl(fcv.end_date, p_daytime + 1)
   AND p_daytime >= Nvl(fc.start_date, p_daytime - 1)
   AND p_daytime < Nvl(fc.end_date, p_daytime + 1)*/
   AND fcv.record_status = 'A'
   AND fcv.forecast_scope = 'PUBLIC'
   AND fcv.official_ind = 'Y';


 if ln_counter > 0 then
    Raise_Application_Error(-20000, 'It is not allowed to delete a Forecast Case which is PUBLIC, set to Official and has status Approved');
 else

     --deleting FCST_YR_STATUS
     delete FCST_YR_STATUS where object_id = p_object_id;

     --deleting FCST_MTH_STATUS
     delete FCST_MTH_STATUS where object_id = p_object_id;

     --deleting STIM_FCST_MTH_VALUE
     delete STIM_FCST_MTH_VALUE where forecast_id = p_object_id;

     --deleting FCST_MEMBER
     delete FCST_MEMBER where object_id = p_object_id;

     --deleting FCST_PRODUCT_SETUP
     delete FCST_PRODUCT_SETUP where object_id = p_object_id;

     --deleting forecast object and version
     ecdp_objects.DelObj(p_object_id);

 end if;

END delFcstObj;

PROCEDURE validateFcstObj(
   p_object_id VARCHAR2,
   p_n_object_start_date DATE,
   p_o_object_start_date DATE,
   p_populate_method VARCHAR2,
   p_plan_date DATE,
   p_forecast_scope  VARCHAR2,
   p_official_ind  VARCHAR2,
   p_functional_area_code VARCHAR2,
   p_forecast_id VARCHAR2
   )
IS
  ln_counter NUMBER;
  lv2_revn_fcst VARCHAR(4000) := null;
  lv2_qty_fcst_id VARCHAR(32);

  -- Get all revenue forecast cases has references to current object.
  CURSOR c_revn_fcst(cp_object_id VARCHAR2) IS
  SELECT o.object_id
  FROM FORECAST_VERSION oa, FORECAST o
  WHERE oa.object_id = o.object_id
  AND oa.daytime <= p_plan_date
  AND Nvl(oa.end_date, p_plan_date + 1) > p_plan_date
  AND o.FUNCTIONAL_AREA_CODE = 'REVENUE_FORECAST'
  AND oa.FORECAST_ID = cp_object_id;

BEGIN


  /*IF (p_plan_date >= p_object_start_date and p_plan_date <= p_object_end_date) = false then
     Raise_Application_Error(-20000, 'Plan Date must be in between Start Date and End Date');
  END IF;*/

  --if Revenue Forecast Case is offical
 if p_functional_area_code = 'REVENUE_FORECAST' and p_official_ind = 'Y' then

       --get connected Qty Fcst Id
       --lv2_qty_fcst_id := ec_forecast_version.forecast_id(p_object_id, p_o_object_start_date, '<=');
       --check against the connected Qty Fcst Case, if it is not Official
       if ec_forecast_version.official_ind(p_forecast_id, ec_forecast.start_date(p_forecast_id), '<=') <> 'Y' then
           Raise_Application_Error(-20000, 'For Offical Revenue Forecast Case, only Offical Quantity Forecast Case could be referred.');
       end if;

 end if;

   --if Quantity Forecast Case is offical
 if p_functional_area_code = 'QUANTITY_FORECAST' and p_official_ind = 'N' then

       --if official indicator is updated
      if  p_official_ind <> ec_forecast_version.official_ind(p_object_id, p_o_object_start_date, '<=') then
          --find revn fcst id
          SELECT COUNT(*) INTO ln_counter
           FROM forecast f,
                forecast_version fv
          WHERE f.object_id = fv.object_id
            AND fv.forecast_id = p_object_id
            AND fv.official_ind = 'Y';
          --if currenty qty fcst is referred by any official revn fcst
          if ln_counter > 0 then
             Raise_Application_Error(-20000, 'It is not allowed to have Unofficial Quantity Forecast Case which is being referred by Official Revenue Forecast Case.');
          end if;
       end if;

 end if;

 --it is not allowed to have private official forecast case
 if p_forecast_scope = 'PRIVATE' and p_official_ind = 'Y' then
        Raise_Application_Error(-20000, 'It is not allowed to have Official Private Forecast Case');
 end if;

 --if update Forecast Scope from Public to Private
 if p_forecast_scope = 'PRIVATE' and ec_forecast_version.forecast_scope(p_object_id, p_o_object_start_date, '<=') = 'PUBLIC' then
    --Raise_Application_Error(-20000,'UPDATING FORECAST SCOPE!');
    --check all the record status
    SELECT COUNT(*) INTO ln_counter
     FROM forecast f,
          forecast_version fv
    WHERE f.object_id = fv.object_id
      AND fv.forecast_id = p_object_id
      AND f.functional_area_code = p_functional_area_code
      AND EXISTS
          (SELECT fv.object_id
             FROM fcst_mth_status fms
            WHERE fms.object_id = fv.object_id
              AND (record_status = 'A' OR record_status = 'V'));

     if ln_counter > 0 then
         Raise_Application_Error(-20000, 'Approved or Verified data found! It is not allowed to update forecast scope from Public to Private');
     end if;
 end if;

  --verify if start date has been changed
  if p_n_object_start_date <> p_o_object_start_date  then

        --Raise_Application_Error(-20000, 'DIFF, old=' || p_o_object_start_date || ', new=' || p_n_object_start_date);
        --update plan date when object start date changed
--        update FORECAST_VERSION set plan_date = add_months(plan_date, months_between(p_n_object_start_date, p_o_object_start_date))
--        where object_id = p_object_id;

        -- Set Plan date to Jan in the "new" year and set end_date
        UPDATE forecast_version fv SET plan_date = TRUNC(p_n_object_start_date, 'YYYY'), fv.end_date = ADD_MONTHS(p_n_object_start_date,12)-1
        WHERE object_id = p_object_id;

        -- Set end_date
        UPDATE forecast f SET f.end_date = ADD_MONTHS(p_n_object_start_date,12)-1
        WHERE object_id = p_object_id;

        --remove all month quantities when object start date changed
        delete FCST_MTH_STATUS where object_id = p_object_id;

         --remove all year quantities when object start date changed
        delete FCST_YR_STATUS where object_id = p_object_id;

 end if;

  --check if public quantity forecast case has been referred by revenue forecast
  if p_forecast_scope = 'PRIVATE' and p_functional_area_code = 'QUANTITY_FORECAST' then

     --if quantity forecast references found, get all the revenue forecast cases
     FOR cur_rec IN c_revn_fcst(p_object_id) LOOP
        lv2_revn_fcst := lv2_revn_fcst || ecdp_objects.GetObjCode(cur_rec.object_id) || ', ';
     END LOOP;

     if lv2_revn_fcst is not null then
       Raise_Application_Error(-20000, 'Update Failed! The current public Quantity Forecast Case has been referred by Revenue Forecase Case(s):' || lv2_revn_fcst);
     end if;

  end if;

  --check existing record based on forecast critiria
  IF p_object_id is null THEN --Inserting

          IF p_populate_method = 'YEAR_TO_MONTH' then

              SELECT count(*) into ln_counter
              FROM forecast fc, forecast_version fcv
              WHERE fc.object_id = fcv.object_id
              AND fcv.populate_method = p_populate_method
              AND fcv.plan_date = NVL(p_plan_date, fcv.plan_date)
              AND fcv.forecast_scope = NVL(p_forecast_scope, fcv.forecast_scope)
              AND fcv.official_ind = NVL(p_official_ind, fcv.official_ind)
              AND fc.functional_area_code = NVL(p_functional_area_code, fc.functional_area_code)
              AND fcv.populate_method = 'YEAR_TO_MONTH'
              AND fcv.forecast_scope = 'PUBLIC'
              AND fcv.official_ind = 'Y';

           ELSE

              SELECT count(*) into ln_counter
              FROM forecast fc, forecast_version fcv
              WHERE fc.object_id = fcv.object_id
              AND fcv.populate_method = p_populate_method
              AND to_char(fcv.plan_date, 'yyyy') = NVL(to_char(p_plan_date, 'yyyy'), to_char(fcv.plan_date, 'yyyy'))
              AND fcv.forecast_scope = NVL(p_forecast_scope, fcv.forecast_scope)
              AND fcv.official_ind = NVL(p_official_ind, fcv.official_ind)
              AND fc.functional_area_code = NVL(p_functional_area_code, fc.functional_area_code)
              AND fcv.populate_method = 'PLAN'
              AND fcv.forecast_scope = 'PUBLIC'
              AND fcv.official_ind = 'Y';

            END IF;

    ELSE --Updating
          IF p_populate_method = 'YEAR_TO_MONTH' then

              SELECT count(*) into ln_counter
              FROM forecast fc, forecast_version fcv
              WHERE fc.object_id = fcv.object_id
              AND fcv.populate_method = p_populate_method
              AND fcv.plan_date = NVL(p_plan_date, fcv.plan_date)
              AND fcv.forecast_scope = NVL(p_forecast_scope, fcv.forecast_scope)
              AND fcv.official_ind = NVL(p_official_ind, fcv.official_ind)
              AND fc.functional_area_code = NVL(p_functional_area_code, fc.functional_area_code)
              AND fcv.populate_method = 'YEAR_TO_MONTH'
              AND fcv.forecast_scope = 'PUBLIC'
              AND fcv.official_ind = 'Y'
              AND fc.object_id <> p_object_id;

           ELSE

              SELECT count(*) into ln_counter
              FROM forecast fc, forecast_version fcv
              WHERE fc.object_id = fcv.object_id
              AND fcv.populate_method = p_populate_method
              AND to_char(fcv.plan_date, 'yyyy') = NVL(to_char(p_plan_date, 'yyyy'), to_char(fcv.plan_date, 'yyyy'))
              AND fcv.forecast_scope = NVL(p_forecast_scope, fcv.forecast_scope)
              AND fcv.official_ind = NVL(p_official_ind, fcv.official_ind)
              AND fc.functional_area_code = NVL(p_functional_area_code, fc.functional_area_code)
              AND fcv.populate_method = 'PLAN'
              AND fcv.forecast_scope = 'PUBLIC'
              AND fcv.official_ind = 'Y'
              AND fc.object_id <> p_object_id;

            END IF;

    END IF;

    if ln_counter > 0 then
       Raise_Application_Error(-20000, 'There can only exist One offical Public Forecast for each ' || p_populate_method);
    end if;

END validateFcstObj;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  PopulateQtyFcst
-- Description    :  Populates a Quantity Forecast Case
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE PopulateQtyFcst(
   p_object_id VARCHAR2, -- Forecast object_id
   p_user      VARCHAR2)
--</EC-DOC>
IS

-- The forecast case itself
CURSOR c_forecast IS
SELECT object_id, plan_date, daytime
  FROM forecast_version
 WHERE object_id = p_object_id
   AND populate_method = 'YEAR_TO_MONTH'
   AND record_status = 'P';

-- All the products for a forecast case
CURSOR c_fcst_prod (cp_object_id VARCHAR2, cp_product_id VARCHAR2, cp_product_context VARCHAR2) IS
SELECT fps.object_id, fps.product_id, fps.product_uom, fps.cpy_adj_stream_item_id, fps.full_adj_stream_item_id
  FROM fcst_product_setup fps
 WHERE fps.object_id = cp_object_id
   AND fps.product_id = cp_product_id
   AND fps.product_context = cp_product_context;

-- All members in a given forecast case
CURSOR c_fcst_member (cp_object_id VARCHAR2) IS
SELECT fm.member_no,
       fm.stream_item_id,
       fm.product_id product_id,
--       ec_strm_version.product_id (ec_stream_item.stream_id(fm.stream_item_id),
--                                  f.start_date,
--                                  '<=') product_id,
       fm.product_context,
       fm.adj_stream_item_id
  FROM fcst_member fm, forecast f
 WHERE fm.object_id = cp_object_id
   AND fm.object_id = f.object_id
   AND fm.RECORD_STATUS = 'P';

-- Loop through each Month of actual numbers
CURSOR c_stim_mth (cp_stream_item_id VARCHAR2, cp_plan_date DATE) IS
SELECT smv.object_id object_id, smv.daytime daytime, smv.status status
  FROM stim_mth_value smv
 WHERE smv.object_id = cp_stream_item_id
   AND TRUNC (smv.daytime, 'YYYY') = TRUNC (cp_plan_date, 'YYYY')
   AND smv.daytime <= cp_plan_date;

lv2_product_id VARCHAR2(32);
lv2_uom_code VARCHAR2(32);
ln_qty NUMBER;
ld_start_date DATE;
ln_counter NUMBER;

BEGIN

    SELECT COUNT(*) INTO ln_counter
    FROM fcst_mth_status
   WHERE object_id = p_object_id
     AND record_status IN ('A');


  IF (ln_counter > 0) THEN
     Raise_Application_Error(-20000, 'Not allowed to update quantities when the forecast case is approved or verified. Please un-approve to continue.');
  END IF;


  ld_start_date := ec_forecast.start_date(p_object_id);

  InstantiateFcst(p_object_id, ld_start_date);

  FOR cur_rec_forecast IN c_forecast LOOP

     -- Populate stream items
     FOR cur_rec_fcst_member IN c_fcst_member(cur_rec_forecast.object_id) LOOP



        -- Find product for SI
        lv2_product_id := NULL;
        FOR cur_prod IN c_fcst_prod(cur_rec_forecast.object_id, cur_rec_fcst_member.product_id, cur_rec_fcst_member.product_context) LOOP
            lv2_product_id := cur_prod.product_id;
            lv2_uom_code := cur_prod.product_uom;
        END LOOP;
        IF (lv2_product_id IS NULL) THEN
            Raise_Application_Error(-20000, 'Product not found in forecast case members');
        END IF;

        FOR cur_rec_stim_mth IN c_stim_mth(cur_rec_fcst_member.stream_item_id,cur_rec_forecast.plan_date) LOOP

              ln_qty := Ecdp_Stream_Item.GetMthQtyByUOM(cur_rec_stim_mth.object_id, lv2_uom_code, cur_rec_stim_mth.daytime);
              -- Update with actual numbers
              UPDATE fcst_mth_status fms
                 SET fms.net_qty = ln_qty,
                     fms.uom = lv2_uom_code,
                     fms.status  = cur_rec_stim_mth.status
               WHERE object_id = p_object_id
                 AND member_no = cur_rec_fcst_member.member_no
                 AND daytime = cur_rec_stim_mth.daytime;

        END LOOP; -- end c_stim_mth

        -- Sum the adjustment stream item values up till plan date
        SELECT SUM(Ecdp_Stream_Item.GetMthQtyByUOM(cur_rec_fcst_member.adj_stream_item_id, lv2_uom_code, smv.daytime))
          INTO ln_qty
          FROM stim_mth_value smv
         WHERE smv.object_id = cur_rec_fcst_member.adj_stream_item_id
           AND smv.daytime <= cur_rec_forecast.plan_date;

        -- Update fcst_yr_status
        UPDATE fcst_yr_status fys
           SET fys.net_qty = ln_qty,
               fys.status  = getAllPYAStreamItemStatus(cur_rec_fcst_member.adj_stream_item_id, daytime)
         WHERE object_id = cur_rec_forecast.object_id
           AND member_no = cur_rec_fcst_member.member_no
           AND daytime = cur_rec_forecast.daytime;

    END LOOP; -- end c_fcst_member

  END LOOP; -- end c_forecast

  -- Set populate by and date
  UPDATE forecast_version
     SET populate_by = p_user, populate_date = Ecdp_Timestamp.getCurrentSysdate
   WHERE object_id = p_object_id;

END PopulateQtyFcst;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  PopulateRevnFcst
-- Description    :  Populates a Revenue Forecast Case
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE PopulateRevnFcst(
   p_object_id VARCHAR2, -- Forecast object_id
   p_user      VARCHAR2)
IS

ld_start_date  DATE;
ld_revn_fcst_plan_date   DATE;
ld_qty_fcst_plan_date   DATE;
lv_qty_forecast_id       VARCHAR2(32);
--ln_qty_forecast_net_pr   NUMBER;
ln_net_qty               NUMBER;
ln_net_qty_plan          NUMBER;
ln_sale_qty              NUMBER;
ln_pya_spot_sale_qty          NUMBER;
ln_pya_term_sale_qty          NUMBER;
ln_spot_sale_qty              NUMBER;
ln_term_sale_qty              NUMBER;
lv_status                VARCHAR2(32);
lv_uom                   VARCHAR2(32);
lv_qty_fcst_uom          VARCHAR2(32);
lv_comm_adj              NUMBER;
lv_swap_adj              NUMBER;
lv_general_price_id       VARCHAR2(32);
--ln_sum_price_elements     NUMBER;
lrec_price                t_revn_price_rec;
lv_price_concept_code       VARCHAR2(32);
ln_act_net_price           NUMBER;
ln_act_net_price_spot           NUMBER;
ln_act_net_price_term           NUMBER;
ln_act_net_cost                 NUMBER;
lb_prior_to_plan_date      VARCHAR2(32);
ln_forex                   NUMBER;
lv_fcst_method             VARCHAR2(32);
ln_prod_currency_id           VARCHAR(32);
ln_local_currency_id          VARCHAR(32);
ln_local_gross_revenue        NUMBER;
ln_local_non_adj_revenue      NUMBER;
ln_value_adj                  NUMBER;
ln_local_term_price           NUMBER;
ln_local_spot_price           NUMBER;
ln_gpurch_net_qty             NUMBER;
lrec_revn                     t_revn_rec;
lrec_pya_revn                 t_revn_rec;
ln_pya_local_net_revenue      NUMBER;
lv_product_collection_type varchar(32);

-- Loop through all quantity fcst_mth_status, only needed to run through the months
CURSOR c_qty_fcst_mth_status (cp_qty_fcst_id VARCHAR2) IS
SELECT DISTINCT TRUNC(fms.daytime, 'MM') daytime
  FROM fcst_mth_status fms, fcst_member fm
 WHERE fms.object_id = cp_qty_fcst_id
   AND fms.member_no = fm.member_no
   ORDER BY TRUNC(fms.daytime, 'MM') ASC;

 -- Loop through all quantity fcst_yr_status
CURSOR c_qty_fcst_yr_status (cp_qty_fcst_id VARCHAR2, cp_field_id VARCHAR2, cp_company VARCHAR2, cp_product_id VARCHAR2, cp_product_context VARCHAR2) IS
SELECT fys.daytime, fys.net_qty, fys.uom
  FROM fcst_yr_status fys, fcst_member fm
 WHERE fys.object_id = cp_qty_fcst_id
   AND fys.member_no = fm.member_no
   AND NVL(fm.field_id,'XXX') = NVL(cp_field_id,'XXX')
   AND fm.product_id = cp_product_id
   AND
   (NVL((
SELECT siv.company_id
  FROM stream_item si, stream_item_version siv
 WHERE si.object_id = fm.stream_item_id
   AND si.object_id = siv.object_id
   AND fys.daytime >= si.start_date
   AND fys.daytime < nvl(si.end_date, fys.daytime + 1)
   AND    siv.daytime =
                       (
                       SELECT MAX(sivn.daytime)
                       FROM   stream_item_version sivn
                       WHERE  sivn.object_id = siv.object_id
                       AND    sivn.daytime <= fys.daytime
                       )
), 'XXX')
= NVL(cp_company ,'XXX')
)
AND fm.product_context = NVL(cp_product_context,fm.product_context);

-- All members in a given forecast case
CURSOR c_fcst_member (cp_object_id VARCHAR2) IS
SELECT fm.member_no,
       fm.stream_item_id,
       fm.product_collection_type,
       fm.contract_id,
       fm.product_id,
       fm.product_context,
       fm.adj_stream_item_id,
       fm.swap_stream_item_id,
       fm.field_id
  FROM fcst_member fm, forecast f
 WHERE fm.object_id = cp_object_id
   AND fm.object_id = f.object_id;

CURSOR c_distinct_product_context (cp_object_id VARCHAR2) IS
SELECT DISTINCT fm.product_context
FROM fcst_member fm
 WHERE fm.object_id = cp_object_id;

ln_conv_value NUMBER;

lv2_product_context VARCHAR2(200);

BEGIN
    Cache_daymembers(p_object_id);
    Cache_getSaleQty(p_object_id);
    Cache_GETREVNREC(p_object_id);

 ld_start_date := ec_forecast.start_date(p_object_id);
 InstantiateFcst(p_object_id, ld_start_date);
 lv_qty_forecast_id := ec_forecast_version.forecast_id(p_object_id, ld_start_date, '<=');

 -- Find distinct product context in QTY case
 lv2_product_context := NULL;
 FOR cur_product_context IN c_distinct_product_context(lv_qty_forecast_id) LOOP
     IF (cur_product_context.product_context = 'PRODUCTION') THEN
        lv2_product_context := 'PRODUCTION';
     END IF;
 END LOOP;

     FOR cur_rec_fcst_member IN c_fcst_member(p_object_id) LOOP -- All FCST_MEMBERS
        FOR cur_rec_mth_status IN c_qty_fcst_mth_status(lv_qty_forecast_id) LOOP -- The connected QTY_FCST_CASE
            lv_product_collection_type := ec_fcst_member.product_collection_type(cur_rec_fcst_member.member_no);



   -- TD6691:
 -- To be able to populate a Revenue Forecast the Plan Date of the Qty Forecast Case and the Plan Date of the Revenue Forecast
 -- must be consistent. If these Plan Dates are not consistent an errormessage should appear.
         ld_revn_fcst_plan_date := ec_forecast_version.plan_date(p_object_id,cur_rec_mth_status.daytime,'<=');
        ld_qty_fcst_plan_date := ec_forecast_version.plan_date(lv_qty_forecast_id,cur_rec_mth_status.daytime,'<=');

        IF ld_revn_fcst_plan_date <> ld_qty_fcst_plan_date THEN
                 Raise_Application_Error(-20000, 'Plan dates are not the same '||chr(13)||'Qty Forecast Case: '||ld_qty_fcst_plan_date ||chr(13)||'Revenue Forecast Case: '||ld_revn_fcst_plan_date);
        END IF;

         lv_status := getQtyFcstStatus(lv_qty_forecast_id,
                                       cur_rec_fcst_member.stream_item_id,
                                       cur_rec_mth_status.daytime);


          -- Uom on the given product on the current revenue forecast object
          lv_uom :=  ec_fcst_product_setup.product_uom (p_object_id,
                                                        cur_rec_fcst_member.product_id,
                                                        cur_rec_fcst_member.product_context,
                                                        cur_rec_fcst_member.product_collection_type);


           -- Uom on the given product on quantity forecast subject to revenue forecast
           lv_qty_fcst_uom := ec_fcst_product_setup.product_uom (lv_qty_forecast_id,
                                                        cur_rec_fcst_member.product_id,
                                                        'PRODUCTION',
                                                        'QUANTITY');

    -- Retrieving commercial adjustment quantity from VO
    -- NB: Function will only return the values from VO from the column repreenting the UOM passed in as argument.
    --     This applies even though this column is empty and the other columns are not empty.

    IF cur_rec_fcst_member.adj_stream_item_id IS NOT NULL THEN
     lv_comm_adj := nvl(ecdp_stream_item.GetMthQtyByUOM(cur_rec_fcst_member.adj_stream_item_id, lv_uom, cur_rec_mth_status.daytime, 'Y'),0);
     END IF;

     -- Retrieving swap adjustment quantity from VO
     -- NB: Function will only return the values from VO from the column repreenting the UOM passed in as argument.
     -- This applies even though this column is empty and the other columns are not empty.
     IF cur_rec_fcst_member.swap_stream_item_id IS NOT NULL THEN
     lv_swap_adj := ecdp_stream_item.GetMthQtyByUOM(cur_rec_fcst_member.swap_stream_item_id, lv_uom, cur_rec_mth_status.daytime, 'Y');
     END IF;

    -- Retrieving spot_sale_qty value(s) (Sales Qty in screen)
    -- NOTE: If only one value is in use (i.e. for liquids) then the spot_sale_qty column is used for this purpose
    ln_sale_qty := getSaleQtyCache(cur_rec_fcst_member.stream_item_id,lv_uom,cur_rec_mth_status.daytime,lv_product_collection_type);

    -- Retrieving net price for actual numbers. Using pricing_currency / contract / line item level
    -- Assuming this currency is used by cont_line_item.pricing_value.

    lrec_revn := getRevnRec_Cache(p_object_id,
                            cur_rec_fcst_member.stream_item_id,
                            cur_rec_fcst_member.product_id,
                            cur_rec_fcst_member.product_context,
                            cur_rec_fcst_member.product_collection_type,
                            ln_sale_qty,
                            cur_rec_mth_status.daytime);

    IF ec_fcst_member.product_collection_type(cur_rec_fcst_member.member_no) = 'GAS_SALES' THEN

       ln_spot_sale_qty := getSaleQtyCache(cur_rec_fcst_member.stream_item_id,lv_uom,cur_rec_mth_status.daytime,lv_product_collection_type,'SPOT');
       ln_term_sale_qty := getSaleQtyCache(cur_rec_fcst_member.stream_item_id,lv_uom,cur_rec_mth_status.daytime,lv_product_collection_type,'TERM');


       -- To get the correct local term price, the sum of the booked values must be divided
       -- on the sum of the quantities found on the same set of cont_line_item_dist records.
       IF (nvl(ln_term_sale_qty,0) <> 0) THEN
          ln_local_term_price :=  lrec_revn.local_term_value / ln_term_sale_qty;
       END IF;
       -- To get the correct local spot price, the sum of the booked values must be divided
       -- on the sum of the quantities found on the same set of cont_line_item_dist records
       IF (nvl(ln_spot_sale_qty,0) <> 0) THEN
          ln_local_spot_price :=  lrec_revn.local_spot_value / ln_spot_sale_qty;
       END IF;

    END IF; -- GAS SALES

    IF ec_fcst_member.product_collection_type(cur_rec_fcst_member.member_no) = 'GAS_PURCHASE' THEN

       ln_gpurch_net_qty := getGPurchNetQty(p_object_id,
                                            cur_rec_fcst_member.contract_id,
                                            cur_rec_fcst_member.product_id,
                                            lv_uom,
                                            lv_qty_fcst_uom,
                                            cur_rec_mth_status.daytime);


       ln_act_net_cost := getNetCostForActualNumbers(p_object_id,
                                                     cur_rec_fcst_member.contract_id,
                                                     cur_rec_fcst_member.product_id,
                                                     ln_gpurch_net_qty,
                                                     cur_rec_mth_status.daytime);

     END IF; -- GAS_PURCHASE

    -- Retrieving net qty (Plan Qty in screen) actual numbers for pre-plan months. If product (Stream item) not found on the connected quantity forecast setup, then
    -- this lookup will continue to VO to get numbers.
    ln_net_qty := getNetQty(lv_qty_forecast_id,cur_rec_fcst_member.stream_item_id,lv_uom,cur_rec_mth_status.daytime);

     -- Retrieving net qty for plan months (Plan Qty in screen). If product (Stream item) not found on the connected quantity forecast setup,
     -- then no value is returned
    ln_net_qty_plan := getNetQtyPlan(lv_qty_forecast_id,cur_rec_fcst_member.stream_item_id,lv_uom,cur_rec_mth_status.daytime);

    -- Retrieveing sum of price elements
    lrec_price        := getSumPriceElements(p_object_id,
                                                 cur_rec_fcst_member.product_id,
                                                 cur_rec_fcst_member.product_context,
                                                 cur_rec_fcst_member.product_collection_type,
                                                 cur_rec_mth_status.daytime);
     IF (lrec_price.spot_price IS NULL) THEN
         lrec_price.spot_price := lrec_price.term_price;
     END IF;

    lv_fcst_method := ec_forecast_version.populate_method(p_object_id,cur_rec_mth_status.daytime,'<=');
    lb_prior_to_plan_date := isPriorToPlanDate(p_object_id,cur_rec_mth_status.daytime);

    ln_act_net_price := lrec_revn.act_net_price;

    ln_local_gross_revenue := lrec_revn.local_gross_revenue;

    ln_local_non_adj_revenue := lrec_revn.local_non_adj_revenue;

    ln_value_adj := lrec_revn.value_adj;

       -- Finding forex
       ln_prod_currency_id :=  ec_fcst_product_setup.currency_id(p_object_id,
                                                              cur_rec_fcst_member.product_id,
                                                              cur_rec_fcst_member.product_context,
                                                              cur_rec_fcst_member.product_collection_type);

      ln_local_currency_id := ec_company_version.local_currency_id(ec_forecast_version.company_id(p_object_id,cur_rec_mth_status.daytime,'<='),cur_rec_mth_status.daytime,'<=');

       ln_forex := ecdp_currency.GetExRateViaCurrency(ec_currency.object_code(ln_prod_currency_id),
                                                      ec_currency.object_code(ln_local_currency_id),
                                                      null,
                                                      cur_rec_mth_status.daytime,
                                                      ec_forecast_version.forex_source_id(p_object_id, cur_rec_mth_status.daytime, '<='), --forex source
                                                      ec_forecast_version.time_scope(p_object_id, cur_rec_mth_status.daytime, '<='));    --forex time scope

          -- Values picked from the connected quantity foracast case
--           ln_qty_forecast_net_pr := ec_fcst_mth_status.base_price(cur_rec_mth_status.member_no,cur_rec_mth_status.daytime,'<=');

             IF lv_fcst_method = 'PLAN' THEN
                popRevnFcstPlan(p_object_id,
                                ln_forex,
                                cur_rec_fcst_member.product_id,
                                cur_rec_fcst_member.product_context,
                                cur_rec_fcst_member.product_collection_type,
                                cur_rec_fcst_member.member_no,
                                cur_rec_mth_status.daytime,
--                                ln_sum_price_elements,
                                lrec_price.term_price,
                                lrec_price.spot_price,
                                ln_net_qty_plan,
                                lv_uom);

             ELSIF lv_fcst_method = 'YEAR_TO_MONTH' THEN
                popRevnFcstYTM (p_object_id,
                                ln_forex,
                                cur_rec_fcst_member.stream_item_id,
                                cur_rec_fcst_member.product_id,
                                cur_rec_fcst_member.product_context,
                                cur_rec_fcst_member.product_collection_type,
                                cur_rec_fcst_member.member_no,
                                cur_rec_mth_status.daytime,
                                lv_comm_adj,
                                lv_swap_adj,
                                lv_status,
--                                ln_sum_price_elements,
                                lrec_price.term_price,
                                lrec_price.spot_price,
                                lb_prior_to_plan_date,
                                ln_act_net_price,
                                ln_net_qty,
                                ln_sale_qty,
                                lv_uom,
                                ln_net_qty_plan,
                                ln_spot_sale_qty,
                                ln_term_sale_qty,
                                ln_local_gross_revenue,
                                ln_value_adj,
                                ln_local_non_adj_revenue,
                                ln_gpurch_net_qty,
                                ln_act_net_cost,
                                ln_local_term_price,
                                ln_local_spot_price

                                );

             END IF;

       END LOOP;  -- MONTHS


       -- Updating yearly values
       FOR cur_rec_yr_status IN c_qty_fcst_yr_status(p_object_id, --lv_qty_forecast_id,
                                                     cur_rec_fcst_member.field_id,
                                                     ec_stream_item_version.company_id(cur_rec_fcst_member.stream_item_id,ec_stream_item.start_date(cur_rec_fcst_member.stream_item_id),'<='),
                                                     cur_rec_fcst_member.product_id,
                                                     NULL) --lv2_product_context)

      LOOP

        -- Retrieving spot_sale_qty value(s) (Sales Qty in screen)
        -- NOTE: If only one value is in use (i.e. for liquids) then the spot_sale_qty column is used for this purpose
        ln_pya_spot_sale_qty := getPYASaleQty(p_object_id
                                        ,cur_rec_fcst_member.stream_item_id
                                        ,lv_uom
                                        ,cur_rec_yr_status.daytime
                                        ,ec_fcst_member.product_collection_type(cur_rec_fcst_member.member_no)
                                        ,'SPOT');

        ln_pya_term_sale_qty := getPYASaleQty(p_object_id
                                         ,cur_rec_fcst_member.stream_item_id
                                        ,lv_uom
                                        ,cur_rec_yr_status.daytime
                                        ,ec_fcst_member.product_collection_type(cur_rec_fcst_member.member_no)
                                        ,'TERM');

        -- Retrieving PYA net price for actual numbers. Using pricing_currency / contract / line item level
        -- Assuming this currency is used by cont_line_item.pricing_value.
        -- This is trasactions having point of sale date in previous year and booking period in current year
        lrec_pya_revn := getPYARevnRec(p_object_id,
                              cur_rec_fcst_member.stream_item_id,
                              cur_rec_fcst_member.product_id,
                              cur_rec_fcst_member.product_context,
                              cur_rec_fcst_member.product_collection_type,
                              NVL(ln_pya_spot_sale_qty,0) + NVL(ln_pya_term_sale_qty,0),
                              cur_rec_yr_status.daytime);

        ln_pya_local_net_revenue := nvl(lrec_pya_revn.local_gross_revenue,0)
            + nvl(lrec_pya_revn.value_adj,0);

         ln_conv_value := getConvertedValue(cur_rec_fcst_member.stream_item_id,
                                            p_object_id
                                           ,cur_rec_yr_status.daytime
                                           ,cur_rec_yr_status.net_qty
                                           ,cur_rec_yr_status.uom
                                           ,ec_fcst_product_setup.product_uom(p_object_id
                                                                             ,cur_rec_fcst_member.product_id
                                                                             ,cur_rec_fcst_member.product_context
                                                                             ,cur_rec_fcst_member.product_collection_type)
                                           ,'PLAN');

    IF ec_fcst_member.product_collection_type(cur_rec_fcst_member.member_no) = 'GAS_PURCHASE' THEN

       ln_conv_value := getPYAGPurchNetQty(p_object_id,
                                            cur_rec_fcst_member.contract_id,
                                            cur_rec_fcst_member.product_id,
                                            lv_uom,
                                            lv_qty_fcst_uom,
                                            cur_rec_yr_status.daytime);
    END IF;

         -- Update fcst_yr_status
         UPDATE fcst_yr_status fys
            SET fys.net_qty = nvl(ln_conv_value,fys.net_qty)
               ,fys.sale_qty = NVL(ln_pya_spot_sale_qty,0) + NVL(ln_pya_term_sale_qty,0) -- PYA sale QTY
               ,fys.spot_sale_qty = ln_pya_spot_sale_qty
               ,fys.term_sale_qty = ln_pya_term_sale_qty
         ,fys.NET_PRICE = lrec_pya_revn.act_net_price
         ,fys.LOCAL_GROSS_REVENUE = lrec_pya_revn.local_gross_revenue
         ,fys.LOCAL_NET_REVENUE = ln_pya_local_net_revenue --lrec_pya_revn.local_non_adj_revenue
         ,fys.VALUE_ADJ_PRICE = lrec_pya_revn.value_adj
         ,fys.LOCAL_SPOT_PRICE = lrec_pya_revn.local_spot_value
         ,fys.LOCAL_TERM_PRICE = lrec_pya_revn.local_term_value
          WHERE fys.object_id = p_object_id
            AND fys.daytime = cur_rec_yr_status.daytime
            AND fys.member_no = cur_rec_fcst_member.member_no;

       END LOOP;

     END LOOP; -- MEMBERS


     -- Set populate by and date
  UPDATE forecast_version
     SET populate_by = p_user, populate_date = Ecdp_Timestamp.getCurrentSysdate
   WHERE object_id = p_object_id;




END PopulateRevnFcst;




--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  InstantiateFcst
-- Description    :  Instantiates the forecasting tables
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE InstantiateFcst(p_object_id VARCHAR2, p_daytime DATE)
--<EC-DOC>
IS

-- Members in the forecast case


/*
TODO:
Verify that we can pick product_id dicetly from this table instead of using the following statement:
ec_strm_version.product_id(ec_stream_item.stream_id(fm.stream_item_id),
                                  f.start_date,
                                  '<=') product_id,

Which can not be used for puchase forecast
*/


CURSOR c_fcst_member (cp_object_id VARCHAR2) IS
SELECT fm.member_no,
       fm.stream_item_id,
       fm.product_id,
       fm.product_context,
       fm.contract_id
  FROM fcst_member fm, forecast f
 WHERE fm.object_id = cp_object_id
   AND fm.object_id = f.object_id
   AND f.start_date = TRUNC(p_daytime, 'YYYY')
;

-- Products for the forecast case
CURSOR c_fcst_prod(cp_object_id VARCHAR2, cp_product_id VARCHAR2, cp_product_context VARCHAR2) IS
SELECT fps.object_id, fps.product_id, fps.product_uom
  FROM fcst_product_setup fps
 WHERE fps.object_id = cp_object_id
   AND fps.product_id = cp_product_id
   AND fps.product_context = cp_product_context
;

lv2_product_id VARCHAR2(32);
lv2_uom_code VARCHAR2(32);
ln_months NUMBER;
ln_counter NUMBER;

BEGIN

    FOR cur_member IN c_fcst_member(p_object_id) LOOP

    -- Need to check for contract as well as purchase forecast is not connected to any stream item
    IF cur_member.stream_item_id IS NOT NULL OR cur_member.contract_id IS NOT NULL THEN -- Might also need to check that product_collection_type = GAS_PURCHASE

        -- Find product for SI
        lv2_product_id := NULL;

        FOR cur_prod IN c_fcst_prod(p_object_id, cur_member.product_id, cur_member.product_context) LOOP

            lv2_product_id := cur_prod.product_id;
            lv2_uom_code := cur_prod.product_uom;

        END LOOP;
        IF (lv2_product_id IS NULL) THEN

            Raise_Application_Error(-20000, 'Product not found in forecast case members');
        END IF;

      END IF; -- Stream Item is null / no stream item if only gas purchase in revenue forecast setup

        -- Loop over all the months and insert records in the fcst_mth_status table
        FOR ln_months IN 0..11 LOOP

          SELECT count (*) INTO ln_counter
            FROM fcst_mth_status fms
           WHERE fms.object_id = p_object_id
             AND fms.member_no = cur_member.member_no
             AND fms.daytime = ADD_MONTHS(TRUNC(p_daytime, 'YYYY'),ln_months);

          IF (ln_counter = 0) THEN

            INSERT INTO fcst_mth_status(object_id, member_no, daytime, uom, status)
            VALUES (p_object_id, cur_member.member_no, ADD_MONTHS(TRUNC(p_daytime, 'YYYY'),ln_months), lv2_uom_code,'PLAN');

          END IF;

        END LOOP;

        --Checking fcst_yr_status table if record already exists
        SELECT COUNT (*) INTO ln_counter
          FROM fcst_yr_status fys
         WHERE fys.object_id = p_object_id
           AND fys.member_no = cur_member.member_no
           AND fys.daytime = TRUNC(p_daytime, 'YYYY');

        IF (ln_counter = 0) THEN

          INSERT INTO fcst_yr_status(object_id, member_no, daytime, uom, status)
          VALUES (p_object_id, cur_member.member_no, TRUNC(p_daytime, 'YYYY'), lv2_uom_code,'PLAN');

        END IF;

    END LOOP;

END InstantiateFcst;


PROCEDURE verifyQtyFcst(p_object_id  VARCHAR2,
                        p_field_id   VARCHAR2,
                        p_company_id VARCHAR2)
IS

ld_start_date DATE;
ld_daytime DATE;
ln_counter NUMBER;

CURSOR c_fcst (cp_daytime DATE) IS
SELECT fv.object_id,
       fm.member_no
  FROM forecast_version fv,
       fcst_member fm
 WHERE fv.object_id = fm.object_id
   AND fm.field_id = p_field_id
   AND fv.object_id = p_object_id
;
BEGIN

ld_start_date := ec_forecast.start_date(p_object_id);
ld_daytime := ec_forecast_version.plan_date(p_object_id, ld_start_date, '<=');

FOR cur_rec_fcst IN c_fcst(ld_daytime) LOOP

    UPDATE fcst_mth_status
       SET record_status = 'V'
     WHERE object_id = cur_rec_fcst.object_id
       AND member_no = cur_rec_fcst.member_no;

END LOOP;

UPDATE fcst_comment
   SET record_status = 'V'
 WHERE object_id = p_object_id
   AND field_id = p_field_id;

SELECT COUNT (*) INTO ln_counter
    FROM fcst_mth_status fms
   WHERE object_id = p_object_id
     AND record_status <> 'V';

  IF ln_counter = 0 THEN

    UPDATE forecast_version
       SET record_status = 'V'
     WHERE object_id = p_object_id;

    UPDATE forecast
       SET record_status = 'V'
     WHERE object_id = p_object_id;

    UPDATE fcst_product_setup
       SET record_status = 'V'
     WHERE object_id = p_object_id;

    UPDATE fcst_member
       SET record_status = 'V'
     WHERE object_id = p_object_id;

    UPDATE fcst_yr_status
       SET record_status = 'V'
     WHERE object_id = p_object_id;

  END IF;

END verifyQtyFcst;

PROCEDURE approveQtyFcst(
   p_object_id VARCHAR2,
   p_field_group_id VARCHAR2,
   p_company_id VARCHAR2)
IS

ld_start_date DATE;

BEGIN

ld_start_date := ec_forecast.start_date(p_object_id);

  UPDATE fcst_mth_status
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE fcst_comment
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE forecast_version
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE forecast
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE fcst_product_setup
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE fcst_member
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE fcst_yr_status
     SET record_status = 'A'
   WHERE object_id = p_object_id;

END approveQtyFcst;

PROCEDURE unapproveQtyFcst(
   p_object_id VARCHAR2,
   p_field_group_id VARCHAR2,
   p_company_id VARCHAR2)
IS

ln_counter NUMBER := 0;
ld_start_date DATE;
ld_daytime DATE;

BEGIN

ld_start_date := ec_forecast.start_date(p_object_id);
ld_daytime := ec_forecast_version.plan_date(p_object_id, ld_start_date, '<=');

 SELECT COUNT(*) INTO ln_counter
   FROM forecast f,
        forecast_version fv
  WHERE f.object_id = fv.object_id
    AND fv.forecast_id = p_object_id
    AND f.functional_area_code = 'REVENUE_FORECAST'
    AND EXISTS
        (SELECT fv.object_id
           FROM fcst_mth_status fms
          WHERE fms.object_id = fv.object_id
            AND record_status = 'A');


 IF ln_counter = 0 THEN -- No revenue forecast has been approved, can start unapproving quantity forecast

      UPDATE fcst_mth_status
         SET record_status = 'P'
       WHERE object_id = p_object_id;

      UPDATE fcst_comment
         SET record_status = 'P'
       WHERE object_id = p_object_id;

      UPDATE fcst_product_setup
         SET record_status = 'P'
       WHERE object_id = p_object_id;

      UPDATE fcst_member
         SET record_status = 'P'
       WHERE object_id = p_object_id;

      UPDATE forecast
         SET record_status = 'P'
       WHERE object_id = p_object_id;

      UPDATE forecast_version
         SET record_status = 'P'
       WHERE object_id = p_object_id;

      UPDATE fcst_yr_status
         SET record_status = 'P'
       WHERE object_id = p_object_id;

 ELSE

   Raise_Application_Error(-20000, 'Approved revenue forecast case found, cannot unapprove this quantity forecast');

 END IF;

END unapproveQtyFcst;

FUNCTION getConvertedValue(p_stream_item_id VARCHAR2,
                           p_forecast_id    VARCHAR2,
                           p_daytime        DATE,
                           p_value          NUMBER,
                           p_from_uom       VARCHAR2,
                           p_to_uom         VARCHAR2,
                           p_status         VARCHAR2) RETURN NUMBER
IS

lv2_from_group VARCHAR2(1);
lv2_to_group VARCHAR2(1);

ln_value NUMBER;
ln_in_conv_from_uom NUMBER;
ln_in_conv_to_uom NUMBER;
lv2_product_id VARCHAR2(32);
lv2_boe_from_unit VARCHAR2(32);
ln_boe_factor NUMBER;
lr_stim_fcst_mth_value stim_fcst_mth_value%rowtype;
l_ConvFact             ecdp_stream_item.t_conversion;

BEGIN
    lr_stim_fcst_mth_value := ec_stim_fcst_mth_value.row_by_pk(p_stream_item_id,p_forecast_id,p_daytime);
    IF (p_from_uom LIKE '%BOE' AND p_to_uom NOT LIKE '%BOE' ) THEN

        lv2_boe_from_unit :=  lr_stim_fcst_mth_value.Boe_From_Uom_Code;
        lv2_from_group := ecdp_unit.GetUOMGroup(lv2_boe_from_unit);
        ln_boe_factor := lr_stim_fcst_mth_value.boe_factor;
        ln_value := ecdp_stream_item.getBOEInvertUnitValue(p_stream_item_id,p_daytime,p_value,p_from_uom,lv2_boe_from_unit,p_from_uom,ln_boe_factor);

    ELSE
        lv2_from_group := ecdp_unit.GetUOMGroup(p_from_uom);
    END IF;

    IF (p_to_uom LIKE '%BOE' AND p_from_uom NOT LIKE '%BOE') THEN

        lv2_boe_from_unit :=  lr_stim_fcst_mth_value.Boe_From_Uom_Code;
        lv2_from_group := ecdp_unit.GetUOMGroup(lv2_boe_from_unit);
        ln_boe_factor := lr_stim_fcst_mth_value.boe_factor;
        ln_value := ecdp_stream_item.GetBOEUnitValue(p_stream_item_id,p_daytime,p_value,p_from_uom,lv2_boe_from_unit,p_to_uom,ln_boe_factor);

    ELSE
        lv2_to_group := ecdp_unit.GetUOMGroup(p_to_uom);
    END IF;

    -- If both groups are the same than standard unit conversion
    IF (lv2_from_group = lv2_to_group AND ln_value IS NULL) THEN
        IF (p_from_uom = p_to_uom) THEN
            ln_value := p_value;
        ELSE
            ln_value := Ecdp_Revn_Unit.convertValue(p_value, p_from_uom, p_to_uom, p_stream_item_id, p_daytime);
        END IF;
    END IF;

     /*
     Conversion (lv2_prod_uom_group -> lv2_sum_uom_group) using ecdp_stream_item.GetDefGCV, GetDefMCV, or GetDefDensity
      V -> M : volume * density  = mass  --ecdp_stream_item.GetDefDensity
      M -> V : mass / density = volume   --ecdp_stream_item.GetDefDensity
      E -> M : energy / mcv = mass       --ecdp_stream_item.GetDefMCV
      E -> V : energy / gcv = volume     --ecdp_stream_item.GetDefGCV
      V -> E : volume * gcv = energy     --ecdp_stream_item.GetDefGCV
      M -> E : mass * mcv = energy       --ecdp_stream_item.GetDefMCV
     */

     IF (lv2_from_group = 'M') THEN
        IF (lv2_to_group = 'V') THEN     -- M -> V : mass / density = volume
           IF (p_status = 'PLAN' OR p_status IS NULL) THEN
               l_ConvFact              := ecdp_stream_item.GetDefDensity(p_stream_item_id, p_daytime);
           ELSIF (p_status IN ('FINAL','ACCRUAL')) THEN
               l_ConvFact.factor   := ec_stim_mth_value.density(p_stream_item_id, p_daytime);
               l_ConvFact.from_uom := ec_stim_mth_value.density_volume_uom(p_stream_item_id, p_daytime);
               l_ConvFact.to_uom   := ec_stim_mth_value.density_mass_uom(p_stream_item_id, p_daytime);
           END IF;
           ln_in_conv_from_uom     := ecdp_revn_unit.convertValue(p_value, p_from_uom, l_ConvFact.to_uom, p_stream_item_id, p_daytime);
           ln_in_conv_to_uom       := ln_in_conv_from_uom / l_ConvFact.factor;
           ln_value                := ecdp_revn_unit.convertValue(ln_in_conv_to_uom, l_ConvFact.from_uom, p_to_uom, p_stream_item_id, p_daytime);
        ELSIF (lv2_to_group = 'E') THEN  -- M -> E : mass * mcv = energy
           IF (p_status = 'PLAN' OR p_status IS NULL) THEN
               l_ConvFact              := ecdp_stream_item.GetDefMCV(p_stream_item_id, p_daytime);
           ELSIF (p_status IN ('FINAL','ACCRUAL')) THEN
               l_ConvFact.factor   := ec_stim_mth_value.mcv(p_stream_item_id, p_daytime);
               l_ConvFact.from_uom := ec_stim_mth_value.mcv_mass_uom(p_stream_item_id, p_daytime);
               l_ConvFact.to_uom   := ec_stim_mth_value.mcv_energy_uom(p_stream_item_id, p_daytime);
           END IF;
           ln_in_conv_from_uom     := ecdp_revn_unit.convertValue(p_value, p_from_uom, l_ConvFact.from_uom, p_stream_item_id, p_daytime);
           ln_in_conv_to_uom       := ln_in_conv_from_uom * l_ConvFact.factor;
           ln_value                := ecdp_revn_unit.convertValue(ln_in_conv_to_uom, l_ConvFact.to_uom, p_to_uom, p_stream_item_id, p_daytime);
        END IF;
     END IF;

     IF (lv2_from_group = 'V') THEN
        IF (lv2_to_group = 'E') THEN     -- V -> E : volume * gcv = energy
           IF (p_status = 'PLAN' OR p_status IS NULL) THEN
               l_ConvFact              := ecdp_stream_item.GetDefGCV(p_stream_item_id, p_daytime);
           ELSIF (p_status IN ('FINAL','ACCRUAL')) THEN
               l_ConvFact.factor   := ec_stim_mth_value.gcv(p_stream_item_id, p_daytime);
               l_ConvFact.from_uom := ec_stim_mth_value.gcv_volume_uom(p_stream_item_id, p_daytime);
               l_ConvFact.to_uom   := ec_stim_mth_value.gcv_energy_uom(p_stream_item_id, p_daytime);
           END IF;
           ln_in_conv_from_uom     := ecdp_revn_unit.convertValue(p_value, p_from_uom, l_ConvFact.from_uom, p_stream_item_id, p_daytime);
           ln_in_conv_to_uom       := ln_in_conv_from_uom * l_ConvFact.factor;
           ln_value                := ecdp_revn_unit.convertValue(ln_in_conv_to_uom, l_ConvFact.to_uom, p_to_uom, p_stream_item_id, p_daytime);
        ELSIF (lv2_to_group = 'M') THEN  -- V -> M : volume * density  = mass
           IF (p_status = 'PLAN' OR p_status IS NULL) THEN
               l_ConvFact              := ecdp_stream_item.GetDefDensity(p_stream_item_id, p_daytime);
           ELSIF (p_status IN ('FINAL','ACCRUAL')) THEN
               l_ConvFact.factor   := ec_stim_mth_value.density(p_stream_item_id, p_daytime);
               l_ConvFact.from_uom := ec_stim_mth_value.density_volume_uom(p_stream_item_id, p_daytime);
               l_ConvFact.to_uom   := ec_stim_mth_value.density_mass_uom(p_stream_item_id, p_daytime);
           END IF;
           ln_in_conv_from_uom     := ecdp_revn_unit.convertValue(p_value, p_from_uom, l_ConvFact.from_uom, p_stream_item_id, p_daytime);
           ln_in_conv_to_uom       := ln_in_conv_from_uom * l_ConvFact.factor;
           ln_value                := ecdp_revn_unit.convertValue(ln_in_conv_to_uom, l_ConvFact.to_uom, p_to_uom, p_stream_item_id, p_daytime);
        END IF;
     END IF;

     IF (lv2_from_group = 'E') THEN
        IF (lv2_to_group = 'V') THEN     -- E -> V : energy / gcv = volume
           IF (p_status = 'PLAN' OR p_status IS NULL) THEN
               l_ConvFact              := ecdp_stream_item.GetDefGCV(p_stream_item_id, p_daytime);
           ELSIF (p_status IN ('FINAL','ACCRUAL')) THEN
               l_ConvFact.factor   := ec_stim_mth_value.gcv(p_stream_item_id, p_daytime);
               l_ConvFact.from_uom := ec_stim_mth_value.gcv_volume_uom(p_stream_item_id, p_daytime);
               l_ConvFact.to_uom   := ec_stim_mth_value.gcv_energy_uom(p_stream_item_id, p_daytime);
           END IF;
           ln_in_conv_from_uom     := ecdp_revn_unit.convertValue(p_value, p_from_uom, l_ConvFact.to_uom, p_stream_item_id, p_daytime);
           ln_in_conv_to_uom       := ln_in_conv_from_uom / l_ConvFact.factor;
           ln_value                := ecdp_revn_unit.convertValue(ln_in_conv_to_uom, l_ConvFact.from_uom, p_to_uom, p_stream_item_id, p_daytime);
        ELSIF (lv2_to_group = 'M') THEN  -- E -> M : energy / mcv = mass
           IF (p_status = 'PLAN' OR p_status IS NULL) THEN
               l_ConvFact              := ecdp_stream_item.GetDefMCV(p_stream_item_id, p_daytime);
           ELSIF (p_status IN ('FINAL','ACCRUAL')) THEN
               l_ConvFact.factor   := ec_stim_mth_value.mcv(p_stream_item_id, p_daytime);
               l_ConvFact.from_uom := ec_stim_mth_value.mcv_mass_uom(p_stream_item_id, p_daytime);
               l_ConvFact.to_uom   := ec_stim_mth_value.mcv_energy_uom(p_stream_item_id, p_daytime);
           END IF;
           ln_in_conv_from_uom     := ecdp_revn_unit.convertValue(p_value, p_from_uom, l_ConvFact.to_uom, p_stream_item_id, p_daytime);
           ln_in_conv_to_uom       := ln_in_conv_from_uom / l_ConvFact.factor;
           ln_value                := ecdp_revn_unit.convertValue(ln_in_conv_to_uom, l_ConvFact.from_uom, p_to_uom, p_stream_item_id, p_daytime);
        END IF;
     END IF;

    RETURN ln_value;

END getConvertedValue;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  getSumProductMthByField
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :  Sum product value in a month for a given product in a given field
--
-------------------------------------------------------------------------------------------------
FUNCTION getSumProductMthByField(p_object_id  VARCHAR2,
                                 p_daytime    DATE,
                                 p_field_id   VARCHAR2,
                                 p_product_id VARCHAR2,
                                 p_company_id VARCHAR2,
                                 p_product_context VARCHAR2)

RETURN NUMBER
IS

   ln_result NUMBER;

BEGIN

   --SELECT SUM (fms.net_qty)
   SELECT fms.net_qty
     INTO ln_result
     FROM fcst_member fm, fcst_mth_status fms
    WHERE fms.member_no = fm.member_no
      AND fm.product_id = p_product_id
      AND fm.field_id = p_field_id -- filter by field
      AND fms.object_id = p_object_id -- filter by forecast case
      AND fms.daytime = p_daytime -- filter by month
      AND fm.product_context = p_product_context
      AND p_company_id =
          (SELECT company_id
             FROM stream_item_version
            WHERE object_id = fm.stream_item_id
              AND field_id = p_field_id
              AND daytime = (SELECT MAX (daytime)
                               FROM stream_item_version
                              WHERE object_id = fm.stream_item_id
                                AND daytime <= p_daytime
                                AND field_id = p_field_id));


   --ln_result := nvl(ln_result, 0);

   RETURN ln_result;

END getSumProductMthByField;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  getOverWrittenInd
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :  Returns 'Y' if STIM_FCST_MTH_STATUS.CALC_METHOD='OW' else 'N'
--
-------------------------------------------------------------------------------------------------
FUNCTION getOverWrittenInd(p_object_id  VARCHAR2,
                                 p_daytime    DATE,
                                 p_field_id   VARCHAR2,
                                 p_product_id VARCHAR2,
                                 p_company_id VARCHAR2,
                                 p_product_context VARCHAR2)

RETURN VARCHAR2
IS

    lv2_result VARCHAR2(1) := 'N';
    lv2_stream_item_id VARCHAR2(32);

BEGIN

   SELECT fm.stream_item_id
     INTO lv2_stream_item_id
     FROM fcst_member fm, fcst_mth_status fms
    WHERE fms.member_no = fm.member_no
      AND fm.product_id = p_product_id
      AND fm.field_id = p_field_id -- filter by field
      AND fms.object_id = p_object_id -- filter by forecast case
      AND fms.daytime = p_daytime -- filter by month
      AND fm.product_context = p_product_context
      AND p_company_id =
          (SELECT company_id
             FROM stream_item_version
            WHERE object_id = fm.stream_item_id
              AND field_id = p_field_id
              AND daytime = (SELECT MAX (daytime)
                               FROM stream_item_version
                              WHERE object_id = fm.stream_item_id
                                AND daytime <= p_daytime
                                AND field_id = p_field_id));
	-- Using NA because Calc method on object will never be OW
    IF (nvl(ec_stim_fcst_mth_value.calc_method(lv2_stream_item_id, p_object_id, p_daytime),'NA') = 'OW') THEN
        lv2_result := 'Y';
    END IF;

   RETURN lv2_result;

END getOverWrittenInd;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSumAllProductMthByField
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :  Sum product value in a month for all products in a given field
--
-------------------------------------------------------------------------------------------------
FUNCTION getSumAllProductMthByField(p_object_id VARCHAR2,
                                    p_daytime   DATE,
                                    p_field_id  VARCHAR2,
                                    p_company_id VARCHAR2,
                                    p_product_context VARCHAR2
                                    )

RETURN NUMBER
IS

   lv2_prod_uom_group     VARCHAR2(16);
   lv2_sum_uom_group      VARCHAR2(16);
   ln_prod_val_in_sum_uom NUMBER;
   l_ConvFact             ecdp_stream_item.t_conversion;
   ln_counter             NUMBER;
   ln_sum_val             NUMBER;
   ln_prod_val_in_conv_from_uom VARCHAR2(16);
   ln_prod_val_in_conv_to_uom   VARCHAR2(16);
   ln_prod_val_in_conv_uom      VARCHAR2(16);
   lrec_stim STIM_MTH_VALUE%ROWTYPE;

CURSOR c_sum(cp_object_id VARCHAR2, cp_field_id VARCHAR2, cp_company_id VARCHAR2, cp_product_context VARCHAR2) IS
SELECT fms.daytime as fms_daytime,
       fms.net_qty,
       fms.uom,
       fms.status,
       fv.object_id,
       fv.daytime as fv_daytime,
       fv.populate_method,
       fv.product_sum_uom,
       fm.field_id,
       fm.product_id,
       fm.stream_item_id
  FROM fcst_member fm, fcst_mth_status fms, forecast_version fv
 WHERE fms.object_id = fm.object_id
   AND fv.object_id = fms.object_id
   AND fm.member_no = fms.member_no
   AND fm.field_id = p_field_id -- filter by field
   AND fms.object_id = p_object_id -- filter by forecast case
   AND fms.daytime = p_daytime
   --AND fm.product_context = p_product_context
   AND p_company_id =
       (SELECT company_id
          FROM stream_item_version
         WHERE object_id = fm.stream_item_id
           AND field_id = p_field_id
           AND daytime = (SELECT MAX (daytime)
                            FROM stream_item_version
                           WHERE object_id = fm.stream_item_id
                             AND daytime <= p_daytime
                             AND field_id = p_field_id));

BEGIN

   FOR cur_sum IN c_sum(p_object_id, p_field_id, p_company_id, p_product_context) LOOP

     lv2_prod_uom_group := ecdp_stream_item.GetUOMGroup(cur_sum.uom);
     lv2_sum_uom_group  := ecdp_stream_item.GetUOMGroup(cur_sum.product_sum_uom);

     -- same uom group, convert the value directly if they are in the same uom group
     IF (lv2_prod_uom_group = lv2_sum_uom_group) THEN

        ln_sum_val := nvl(ln_sum_val, 0) + NVL(getConvertedValue(cur_sum.stream_item_id
                                                      ,p_object_id
                                                      ,cur_sum.fms_daytime
                                                      ,cur_sum.net_qty
                                                      ,cur_sum.uom
                                                      ,cur_sum.product_sum_uom
                                                      ,cur_sum.status )
                                                      , 0);

     -- require inter uom group conversion
     -- attemp to get conversion factor from stim_mth_value table if instantiated
     ELSE
        -- check if month is instantiated
         lrec_stim.object_id := NULL;
         lrec_stim := ec_stim_mth_value.row_by_pk(cur_sum.stream_item_id, cur_sum.fms_daytime);

        IF ((lrec_stim.object_id IS NOT NULL) AND cur_sum.populate_method = 'YEAR_TO_MONTH' AND cur_sum.status <> 'PLAN') THEN -- If month is instantiated, use the values from stim_mth_value regardless of PLAN or YEAR_TO_MONTH

           ln_sum_val := nvl(ln_sum_val, 0) + NVL(getConvertedValue(cur_sum.stream_item_id
                                                      ,p_object_id
                                                      ,cur_sum.fms_daytime
                                                      ,cur_sum.net_qty
                                                      ,cur_sum.uom
                                                      ,cur_sum.product_sum_uom
                                                      ,cur_sum.status )
                                                      , 0);

        ELSE -- Not instantiated, use the conversion values from Node, Profit Center or Field level

           ln_prod_val_in_sum_uom := getConvertedValue(cur_sum.stream_item_id
                                                     ,p_object_id
                                                      ,cur_sum.fms_daytime
                                                      ,cur_sum.net_qty
                                                      ,cur_sum.uom
                                                      ,cur_sum.product_sum_uom
                                                      ,cur_sum.status );

           ln_sum_val := nvl(ln_sum_val, 0) + nvl(ln_prod_val_in_sum_uom,0);

        END IF;

     END IF;

   END LOOP;

   RETURN ln_sum_val;

END getSumAllProductMthByField;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  getSumProductYrByField
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :  Sum product value in a year for a given product in a given field
--
-------------------------------------------------------------------------------------------------
FUNCTION getSumProductYrByField(p_object_id           VARCHAR2,
                                p_field_id            VARCHAR2,
                                p_product_id          VARCHAR2,
                                p_company_id          VARCHAR2,
                                p_product_context     VARCHAR2
                                )

RETURN NUMBER
IS

   ln_result NUMBER;

BEGIN

   --SELECT SUM (getSumProductMthByField(p_object_id, fms.daytime, p_field_id, p_product_id, p_company_id))
   SELECT SUM (NVL(getSumProductMthByField(p_object_id, fms.daytime, p_field_id, p_product_id, p_company_id,p_product_context), 0))
     INTO ln_result
     FROM fcst_member fm, fcst_mth_status fms
    WHERE fm.product_id = p_product_id
      AND fms.member_no = fm.member_no
      AND fm.field_id = p_field_id -- filter by field
      AND fms.object_id = p_object_id -- filter by forecast case
      AND fm.product_context = p_product_context
      AND p_company_id =
          (SELECT company_id
             FROM stream_item_version
            WHERE object_id = fm.stream_item_id
              AND field_id = p_field_id
              AND daytime = (SELECT MAX (daytime)
                               FROM stream_item_version
                              WHERE object_id = fm.stream_item_id
                                AND daytime <= fms.daytime
                                AND field_id = p_field_id));

/*   SELECT SUM (fms.net_qty) into ln_result
     FROM fcst_member fm, fcst_mth_status fms
    WHERE fm.product_id = p_product_id
      AND fms.member_no = fm.member_no
      AND fm.field_id = p_field_id    -- filter by field
      AND fms.object_id = p_object_id -- filter by forecast case
      --AND ec_stream_item_version.company_id(fm.stream_item_id, ld_date, '<=') = p_company_id -- too slow
      \*AND p_company_id IN (
          SELECT DISTINCT company_id
            FROM stream_item_version
           WHERE object_id = fm.stream_item_id -- need to check/validate for daytime version
          )*\
      AND p_company_id = (
          SELECT company_id
            FROM stream_item_version
           WHERE object_id = fm.stream_item_id
           AND daytime =(select max(daytime) from stream_item_version
           where object_id = fm.stream_item_id
           and daytime <=ld_daytime))
      ;*/

   ln_result := nvl(ln_result, 0);

   RETURN ln_result;

END getSumProductYrByField;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSumAllProductYrByField
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :  Sum product value in a year for all products in a given field
--
-------------------------------------------------------------------------------------------------
FUNCTION getSumAllProductYrByField(p_object_id VARCHAR2,
                                   p_field_id  VARCHAR2,
                                   p_company_id VARCHAR2,
                                   p_product_context VARCHAR2
                                   )

RETURN NUMBER
IS

   lv2_prod_uom_group     VARCHAR2(16);
   lv2_sum_uom_group      VARCHAR2(16);
   ln_prod_val_in_sum_uom NUMBER;
   l_ConvFact             ecdp_stream_item.t_conversion;
   ln_counter             NUMBER;
   ln_sum_val             NUMBER;
   ln_prod_val_in_conv_from_uom VARCHAR2(16);
   ln_prod_val_in_conv_to_uom   VARCHAR2(16);
   ln_prod_val_in_conv_uom      VARCHAR2(16);
   lrec_stim STIM_MTH_VALUE%ROWTYPE;

CURSOR c_sum(cp_object_id VARCHAR2, cp_field_id VARCHAR2, cp_company_id VARCHAR2, cp_product_context VARCHAR2) IS
SELECT fms.daytime as fms_daytime,
       fms.net_qty,
       fms.uom,
       fms.status,
       fv.object_id,
       fv.daytime as fv_daytime,
       fv.populate_method,
       fv.product_sum_uom,
       fm.field_id,
       fm.product_id,
       fm.stream_item_id
  FROM fcst_member fm, fcst_mth_status fms, forecast_version fv
 WHERE fms.object_id = fm.object_id
   AND fv.object_id = fms.object_id
   AND fms.member_no = fm.member_no
   AND fm.field_id = cp_field_id -- filter by field
   AND fms.object_id = cp_object_id -- filter by forecast case
   --AND fm.product_context = cp_product_context
   AND cp_company_id =
       (SELECT company_id
          FROM stream_item_version
         WHERE object_id = fm.stream_item_id
           AND field_id = cp_field_id
           AND daytime = (SELECT MAX(daytime)
                            FROM stream_item_version
                           WHERE object_id = fm.stream_item_id
                             AND daytime <= fms.daytime
                             AND field_id = cp_field_id));

BEGIN

   FOR cur_sum IN c_sum(p_object_id, p_field_id, p_company_id, p_product_context) LOOP

     lv2_prod_uom_group := ecdp_stream_item.GetUOMGroup(cur_sum.uom);
     lv2_sum_uom_group  := ecdp_stream_item.GetUOMGroup(cur_sum.product_sum_uom);

     -- same uom group, convert the value directly if they are in the same uom group
     IF (lv2_prod_uom_group = lv2_sum_uom_group) THEN

        ln_sum_val := nvl(ln_sum_val, 0) + nvl(getConvertedValue(cur_sum.stream_item_id
                                                 ,p_object_id
                                                      ,cur_sum.fms_daytime
                                                      ,cur_sum.net_qty
                                                      ,cur_sum.uom
                                                      ,cur_sum.product_sum_uom
                                                      ,cur_sum.status
                                               ),0);

     -- require inter uom group conversion
     -- attemp to get conversion factor from stim_mth_value table if instantiated
     ELSE
        -- check if month is instantiated
         lrec_stim.object_id := NULL;
         lrec_stim := ec_stim_mth_value.row_by_pk(cur_sum.stream_item_id, cur_sum.fms_daytime);

        IF ((lrec_stim.object_id IS NOT NULL) AND cur_sum.populate_method = 'YEAR_TO_MONTH' AND cur_sum.status <> 'PLAN') THEN -- If month is instantiated, use the values from stim_mth_value regardless of PLAN or YEAR_TO_MONTH

           ln_sum_val := nvl(ln_sum_val, 0) + NVL(getConvertedValue(cur_sum.stream_item_id
                                                  ,p_object_id
                                                      ,cur_sum.fms_daytime
                                                      ,cur_sum.net_qty
                                                      ,cur_sum.uom
                                                      ,cur_sum.product_sum_uom
                                                      ,cur_sum.status ), 0);

        ELSE -- Not instantiated, use the conversion values from Node, Profit Center or Field level


           ln_prod_val_in_sum_uom := getConvertedValue(cur_sum.stream_item_id
                                                     ,p_object_id
                                                      ,cur_sum.fms_daytime
                                                      ,cur_sum.net_qty
                                                      ,cur_sum.uom
                                                      ,cur_sum.product_sum_uom
                                                      ,cur_sum.status );

           ln_sum_val := nvl(ln_sum_val, 0) + nvl(ln_prod_val_in_sum_uom,0);

        END IF;

     END IF;

   END LOOP;

   RETURN ln_sum_val;

END getSumAllProductYrByField;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  getNumDaysInYear
-- Description    :  Accept date and returns the number of days in the same year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getNumDaysInYear(p_year DATE)
RETURN INTEGER
IS

ln_year DATE;
ln_lastdate DATE;
ln_lastyrdate DATE;
ln_retval INTEGER;

BEGIN

  ln_year := TRUNC(p_year,'YYYY');
  ln_lastdate:= ADD_MONTHS(ln_year,12)-1;
  ln_lastyrdate :=ln_year-1;

  ln_retval := ln_lastdate - ln_lastyrdate;

  RETURN ln_retval;

END getNumDaysInYear;

FUNCTION getStatus (
  p_object_id VARCHAR2,
  p_field_id VARCHAR2,
  p_company_id VARCHAR2,
  p_prod_col_type VARCHAR2,
  p_status VARCHAR2
 )
RETURN NUMBER
IS

ln_counter NUMBER;
ld_daytime DATE;
BEGIN

ld_daytime := ec_forecast.end_date(p_object_id);


SELECT COUNT(*) INTO ln_counter
  FROM forecast_version fv,
       fcst_member fm
 WHERE fv.object_id = fm.object_id
   AND fm.field_id = p_field_id
   AND fm.product_collection_type = p_prod_col_type
   AND p_company_id =
       (SELECT company_id
          FROM stream_item_version
         WHERE object_id = fm.stream_item_id
           AND field_id = p_field_id
           AND daytime = (SELECT MAX (daytime)
                            FROM stream_item_version
                           WHERE object_id = fm.stream_item_id
                             AND daytime <= ld_daytime
                             AND field_id = p_field_id))
   AND fv.object_id = p_object_id
   AND EXISTS
        (SELECT fv.object_id
           FROM fcst_mth_status fms
          WHERE fms.object_id = fv.object_id
            AND fms.member_no = fm.member_no
            AND record_status = p_status);


    RETURN ln_counter;
END getStatus;

FUNCTION getForecastStatus(p_forecast_id VARCHAR2)
RETURN VARCHAR2
IS

CURSOR c_prov IS
SELECT count(*) rec_count
FROM
    fcst_mth_status fms
WHERE
    fms.object_id = p_forecast_id
    AND fms.record_status = 'P';

CURSOR c_ver IS
SELECT count(*) rec_count
FROM
    fcst_mth_status fms
WHERE
    fms.object_id = p_forecast_id
    AND fms.record_status = 'V';

CURSOR c_app IS
SELECT count(*) rec_count
FROM
    fcst_mth_status fms
WHERE
    fms.object_id = p_forecast_id
    AND fms.record_status = 'A';

ln_prov NUMBER;
ln_ver NUMBER;
ln_app NUMBER;

lv2_return_val VARCHAR2(240);

BEGIN
    -- Provisional Data
    FOR CurProv IN c_prov LOOP
        ln_prov := CurProv.rec_count;
    END LOOP;

    -- Verified Data
    FOR CurVer IN c_ver LOOP
        ln_ver := CurVer.rec_count;
    END LOOP;

    -- Approved Data
    FOR CurApp IN c_app LOOP
        ln_app := CurApp.rec_count;
    END LOOP;

    IF (ln_app > 0) THEN
        lv2_return_val := 'APPROVED';
    ELSIF (ln_ver > 0) THEN
        lv2_return_val := 'VERIFIED';
    ELSIF (ln_prov > 0) THEN
        lv2_return_val := 'PROVISIONAL';
    ELSE
        lv2_return_val := 'PROVISIONAL';
    END IF;

    RETURN lv2_return_val;

END getForecastStatus;

FUNCTION getAllStatus (
  p_object_id VARCHAR2,
  p_field_id VARCHAR2,
  p_company_id VARCHAR2,
  p_prod_col_type VARCHAR2 DEFAULT 'QUANTITY'
  )
RETURN VARCHAR2
IS
ln_counter NUMBER;
BEGIN

ln_counter := getStatus(p_object_id,p_field_id,p_company_id,p_prod_col_type,'P');                    -- Check for any record status with 'P'
IF ln_counter = 0 THEN                                                  -- If no record status with 'P'

   ln_counter := getStatus(p_object_id,p_field_id,p_company_id,p_prod_col_type,'V');                 ---- Check for any record status with 'V'
   IF  ln_counter = 0 THEN                                              ---- If no record status with 'V'

       ln_counter := getStatus(p_object_id,p_field_id,p_company_id,p_prod_col_type,'A');             ------ Check for any record status with 'A'
          IF  ln_counter = 0 THEN                                       ------ If no record status with 'A'
              RETURN '';                                                -------- return empty string as record status is not P, V or A
          ELSE
               RETURN ec_prosty_codes.code_text('A','DT_RECORD_STATUS');------ Return code text where code = 'A'
          END IF;
   ELSE
        RETURN ec_prosty_codes.code_text('V','DT_RECORD_STATUS');       ---- Return code text where code = 'V'
   END IF;
ELSE
   RETURN ec_prosty_codes.code_text('P','DT_RECORD_STATUS');            -- Return code text where code = 'P'
END IF;

END getAllStatus;


FUNCTION getStreamItemStatus (
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_field_id VARCHAR2,
  p_company_id VARCHAR2,
  p_status VARCHAR2
 )
RETURN NUMBER
IS
ln_counter NUMBER;

BEGIN

SELECT COUNT(*)
  INTO ln_counter
  FROM forecast_version fv, fcst_member fm
 WHERE fv.object_id = fm.object_id
   AND fm.field_id = p_field_id
   AND p_company_id =
       (SELECT company_id
          FROM stream_item_version
         WHERE object_id = fm.stream_item_id
           AND field_id = p_field_id
           AND daytime = (SELECT MAX (daytime)
                            FROM stream_item_version
                           WHERE object_id = fm.stream_item_id
                             AND daytime <= p_daytime
                             AND field_id = p_field_id))
   AND fv.object_id = p_object_id
   AND EXISTS (SELECT fv.object_id
          FROM fcst_mth_status fms
         WHERE fms.object_id = fv.object_id
           AND fms.member_no = fm.member_no
           AND fms.status = p_status
           AND fms.daytime = p_daytime);

    RETURN ln_counter;
END getStreamItemStatus;

FUNCTION getAllStreamItemStatus (
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_field_id VARCHAR2,
  p_company_id VARCHAR2
  )
RETURN VARCHAR2
IS
ln_counter NUMBER;
BEGIN

ln_counter := getStreamItemStatus(p_object_id,p_daytime,p_field_id,p_company_id,'ACCRUAL');
IF ln_counter = 0 THEN

   ln_counter := getStreamItemStatus(p_object_id,p_daytime,p_field_id,p_company_id,'PLAN');
   IF  ln_counter = 0 THEN

       ln_counter := getStreamItemStatus(p_object_id,p_daytime,p_field_id,p_company_id,'FINAL');
          IF  ln_counter = 0 THEN
               RETURN NULL; --not anything at all, set to default PLAN
          ELSE
               RETURN 'FINAL';
          END IF;
   ELSE
        RETURN 'PLAN';
   END IF;
ELSE
   RETURN 'ACCRUAL';
END IF;

END getAllStreamItemStatus;


FUNCTION getPYAStreamItemStatus(p_object_id VARCHAR2,
                                p_daytime   DATE,
                                p_status    VARCHAR2) RETURN NUMBER IS

  ln_counter NUMBER;

BEGIN

  SELECT COUNT(*)
    INTO ln_counter
    FROM stim_mth_value smv
   WHERE smv.object_id = p_object_id
     AND smv.daytime <= p_daytime
     AND smv.record_status = p_status;

  RETURN ln_counter;

END getPYAStreamItemStatus;


FUNCTION getAllPYAStreamItemStatus(p_object_id VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2 IS

  ln_counter NUMBER;

BEGIN

  ln_counter := getPYAStreamItemStatus(p_object_id, p_daytime, 'P'); -- Check for any record status with 'P'
  IF ln_counter = 0 THEN
    ln_counter := getPYAStreamItemStatus(p_object_id, p_daytime, 'V'); ---- Check for any record status with 'V'
    IF ln_counter = 0 THEN
      ln_counter := getPYAStreamItemStatus(p_object_id, p_daytime, 'A'); ------ Check for any record status with 'A'
      IF ln_counter = 0 THEN
        RETURN ''; -------- return empty string as record status is not P, V or A
      ELSE
        RETURN 'A';
      END IF;
    ELSE
      RETURN 'V';
    END IF;
  ELSE
    RETURN 'P';
  END IF;

END getAllPYAStreamItemStatus;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  genForecastCase
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :  Called from the screen Stream Item Forecast Properties -> Inserst a forecast case
--                   If a forecast id is not provided, this function will create a general forecast case for specified stream item
--
-------------------------------------------------------------------------------------------------
FUNCTION genForecastCase(p_object_id   VARCHAR2,
                         p_daytime     DATE,
                         p_user        VARCHAR2,
                         p_forecast_id VARCHAR2 DEFAULT NULL)

 RETURN VARCHAR2

IS

lrec_si stream_item%ROWTYPE;
lrec_siv stream_item_version%ROWTYPE;
lrec_fc forecast%ROWTYPE;
ln_id stim_fcst_setup.stim_fcst_no%TYPE;

BEGIN

IF p_object_id IS NULL THEN
   Raise_Application_Error(-20000,'Stream Item must be provided in order to create a forecast case.');
END IF;

lrec_si := ec_stream_item.row_by_pk(p_object_id);
lrec_siv := ec_stream_item_version.row_by_pk(lrec_si.object_id,p_daytime,'<=');
lrec_fc := ec_forecast.row_by_pk(p_forecast_id);

INSERT INTO stim_fcst_setup
  (object_id,
   daytime,
   end_date,
   forecast_id,
   label,
   calc_method,
   default_uom_mass,
   default_uom_volume,
   default_uom_energy,
   default_uom_extra1,
   default_uom_extra2,
   default_uom_extra3,
   master_uom_group,
   set_to_zero_method_mth,
   stream_item_formula,
   use_mass_ind,
   use_volume_ind,
   use_energy_ind,
   use_extra1_ind,
   use_extra2_ind,
   use_extra3_ind,
   split_key_id,
   split_company_id,
   split_field_id,
   split_product_id,
   split_item_other_id,
   comments,
   created_by)
VALUES
  (lrec_si.object_id,
   p_daytime,
   nvl(lrec_siv.end_date,lrec_si.end_date),
   nvl(p_forecast_id,null),
   lrec_si.description,
   lrec_siv.calc_method,
   lrec_siv.default_uom_mass,
   lrec_siv.default_uom_volume,
   lrec_siv.default_uom_energy,
   lrec_siv.default_uom_extra1,
   lrec_siv.default_uom_extra2,
   lrec_siv.default_uom_extra3,
   lrec_siv.master_uom_group,
   lrec_siv.set_to_zero_method_mth,
   lrec_siv.stream_item_formula,
   lrec_siv.use_mass_ind,
   lrec_siv.use_volume_ind,
   lrec_siv.use_energy_ind,
   lrec_siv.use_extra1_ind,
   lrec_siv.use_extra2_ind,
   lrec_siv.use_extra3_ind,
   lrec_siv.split_key_id,
   lrec_siv.split_company_id,
   lrec_siv.split_field_id,
   lrec_siv.split_product_id,
   lrec_siv.split_item_other_id,
   lrec_siv.comments,
   p_user)
RETURNING stim_fcst_no INTO ln_id;

    -- Copy the formula into the configuration
    INSERT INTO stim_fcst_formula
      (object_id, stream_item_id, forecast_id, daytime)
      SELECT lrec_si.object_id,
             sif.stream_item_id,
             nvl(p_forecast_id, 'GENERAL_FCST_FORMULA'),
             sif.daytime
        FROM stream_item_formula sif
       WHERE sif.object_id = lrec_si.object_id
         AND sif.daytime = lrec_siv.daytime;

  RETURN ln_id;

END genForecastCase;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  delForecastCase
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :  Called from the screen Stream Item Forecast Properties -> Deletes the specified forecast case
--
-------------------------------------------------------------------------------------------------
PROCEDURE delForecastCase(p_stim_fcst_no NUMBER)
--</EC-DOC>

IS

ld_date DATE;

BEGIN
ld_date := ec_stim_fcst_setup.daytime(p_stim_fcst_no);


    -- Delete for formula configuration
    DELETE FROM stim_fcst_formula sff
     WHERE sff.forecast_id =
           (SELECT DISTINCT NVL(forecast_id, 'GENERAL_FCST_FORMULA')
              FROM stim_fcst_setup sfs
             WHERE sfs.stim_fcst_no = p_stim_fcst_no)
       AND sff.object_id IN
           (SELECT object_id
              FROM stim_fcst_setup sfs
             WHERE sfs.stim_fcst_no = p_stim_fcst_no)
       AND sff.daytime = ld_date;

    DELETE FROM stim_fcst_setup sfs
     where sfs.stim_fcst_no = p_stim_fcst_no;

END delForecastCase;

FUNCTION chkStreamItem (
 p_object_id VARCHAR2,
 p_product_id VARCHAR2,
 p_stream_item_id VARCHAR2,
 p_product_context VARCHAR2
)
RETURN NUMBER
IS
ld_start_date DATE;
lv_field_id VARCHAR2(32);
lv_company_id VARCHAR2(32);
ln_counter NUMBER;
BEGIN
ld_start_date := ec_forecast.start_date(p_object_id);
lv_field_id := ec_stream_item_version.field_id(p_stream_item_id, ld_start_date, '<=');
lv_company_id := ec_stream_item_version.company_id(p_stream_item_id, ld_start_date, '<=');

SELECT COUNT (*) INTO ln_counter
FROM fcst_member
WHERE object_id = p_object_id
  AND product_id = p_product_id
  AND field_id = lv_field_id
  AND product_context = p_product_context
  AND lv_company_id = ec_stream_item_version.company_id(fcst_member.stream_item_id, ld_start_date, '<=');

RETURN ln_counter;
END chkStreamItem;

PROCEDURE updNetQty(p_object_id VARCHAR2,
                    p_member_no NUMBER,
                    p_daytime   VARCHAR2,
                    p_user      VARCHAR2,
                    p_net_qty   NUMBER DEFAULT NULL)

IS

lv2_stream_item_id VARCHAR2(32);
lv2_uom VARCHAR2(32);
lv2_uom_group VARCHAR2(1);

BEGIN


    UPDATE fcst_mth_status fms
        SET fms.net_qty = p_net_qty, fms.last_updated_by = p_user
    WHERE object_id = p_object_id
        AND member_no = p_member_no
        AND daytime = to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS');


END updNetQty;

PROCEDURE postUpdNetQtyMember(p_object_id VARCHAR2,
                    p_member_no NUMBER,
                    p_daytime   VARCHAR2,
                    p_user      VARCHAR2)

IS
lv2_stream_item_id VARCHAR2(32) := NULL;
lv2_uom_group VARCHAR2(1);
lv2_uom VARCHAR2(32);
ln_value NUMBER;
lrec_fcst_mth_status fcst_mth_status%ROWTYPE;
lrec_stim_fcst_mth_value stim_fcst_mth_value%ROWTYPE;
BEGIN
    lv2_stream_item_id := ec_fcst_member.stream_item_id(p_member_no);

    lrec_fcst_mth_status := ec_fcst_mth_status.row_by_pk(p_member_no, to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS'));

    lrec_stim_fcst_mth_value := ec_stim_fcst_mth_value.row_by_pk(lv2_stream_item_id, p_object_id, to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS'));
    lv2_uom_group := Ecdp_Unit.GetUOMGroup(lrec_fcst_mth_status.uom);

    IF (lv2_uom_group = 'M') THEN
        ln_value := lrec_stim_fcst_mth_value.net_mass_value;
        lv2_uom := lrec_stim_fcst_mth_value.mass_uom_code;
    ELSIF (lv2_uom_group = 'V') THEN
        ln_value := lrec_stim_fcst_mth_value.net_volume_value;
        lv2_uom := lrec_stim_fcst_mth_value.volume_uom_code;
    ELSIF (lv2_uom_group = 'E') THEN
        ln_value := lrec_stim_fcst_mth_value.net_energy_value;
        lv2_uom := lrec_stim_fcst_mth_value.energy_uom_code;
    END IF;

    -- Convert the value to the correct UOM
    ln_value := Ecdp_Revn_Unit.convertValue(ln_value, lv2_uom, lrec_fcst_mth_status.uom, lv2_stream_item_id, to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS'));

    -- Do the update on "dependent" stream items
    UPDATE fcst_mth_status fms
        SET fms.net_qty = ln_value, fms.last_updated_by = 'INTERNAL'
    WHERE object_id = p_object_id
        AND member_no = p_member_no
        AND daytime = to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS');

END postUpdNetQtyMember;

PROCEDURE postUpdNetQty(p_object_id VARCHAR2,
                    p_member_no NUMBER,
                    p_daytime   VARCHAR2,
                    p_user      VARCHAR2,
                    p_net_qty   NUMBER DEFAULT NULL,
                    p_stream_item_id VARCHAR2 DEFAULT NULL)

IS

lv2_stream_item_id VARCHAR2(32) := NULL;

CURSOR c_stream_items(cp_excl_si VARCHAR2) IS
SELECT
    fm.stream_item_id, fm.member_no
FROM
    fcst_member fm
WHERE
    fm.object_id = p_object_id
--    AND fm.stream_item_id <> NVL(cp_excl_si,'XXX')
;

lv2_uom VARCHAR2(32);
lv2_uom_group VARCHAR2(1);
lrec_fcst_mth_status fcst_mth_status%ROWTYPE;
lrec_stim_fcst_mth_value stim_fcst_mth_value%ROWTYPE;
ln_value NUMBER;

BEGIN
    -- find the stream item in use
    if (p_stream_item_id IS NOT NULL) THEN
        lv2_stream_item_id := p_stream_item_id;
    ELSE
        lv2_stream_item_id := ec_fcst_member.stream_item_id(p_member_no);
    END IF;

    IF ((lv2_stream_item_id IS NULL AND p_member_no IS NULL) OR (lv2_stream_item_id IS NOT NULL)) THEN
        -- Loop through all stream items except the one being updated
        FOR CurSi IN c_stream_items(lv2_stream_item_id) LOOP
            lrec_fcst_mth_status := ec_fcst_mth_status.row_by_pk(CurSi.member_no, to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS'));

            -- If QTY is NULL or last updated by cascade => No manual update then do the update
--            IF ((lrec_fcst_mth_status.net_qty IS NULL OR lrec_fcst_mth_status.last_updated_by = 'INTERNAL') AND
--                CurSi.Stream_Item_Id IS NOT NULL ) THEN
            IF ( CurSi.Stream_Item_Id IS NOT NULL ) THEN
                lrec_stim_fcst_mth_value := ec_stim_fcst_mth_value.row_by_pk(CurSi.Stream_Item_Id, p_object_id, to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS'));
                lv2_uom_group := Ecdp_Unit.GetUOMGroup(lrec_fcst_mth_status.uom);

                IF (lv2_uom_group = 'M') THEN
                    ln_value := lrec_stim_fcst_mth_value.net_mass_value;
                    lv2_uom := lrec_stim_fcst_mth_value.mass_uom_code;
                ELSIF (lv2_uom_group = 'V') THEN
                    ln_value := lrec_stim_fcst_mth_value.net_volume_value;
                    lv2_uom := lrec_stim_fcst_mth_value.volume_uom_code;
                ELSIF (lv2_uom_group = 'E') THEN
                    ln_value := lrec_stim_fcst_mth_value.net_energy_value;
                    lv2_uom := lrec_stim_fcst_mth_value.energy_uom_code;
                END IF;

                -- Convert the value to the correct UOM

               ln_value := getconvertedvalue(CurSi.Stream_Item_Id,p_object_id,to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS'),ln_value,lv2_uom,lrec_fcst_mth_status.uom,'PLAN');

                -- Do the update on "dependent" stream items
                UPDATE fcst_mth_status fms
                    SET fms.net_qty = ln_value, fms.last_updated_by = 'INTERNAL'
                WHERE object_id = p_object_id
                    AND member_no = CurSi.Member_No
                    AND daytime = to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS');

            END IF;
        END LOOP;
    END IF;

END postUpdNetQty;

PROCEDURE updPyaQty(--p_object_id VARCHAR2,
                    p_member_no NUMBER,
                    --p_daytime   VARCHAR2,
                    p_user      VARCHAR2,
                    p_pya_qty   NUMBER DEFAULT NULL)

IS
BEGIN

UPDATE fcst_yr_status fys
   SET fys.net_qty = p_pya_qty, fys.last_updated_by = p_user
 WHERE --object_id = p_object_id
   --AND
   member_no = p_member_no;
   --AND daytime = to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS');

   --ecdp_dynsql.WriteTempText('updPyaQty', 'member_number = '||p_member_no||' and pya_qty = '||p_pya_qty);

END updPyaQty;


FUNCTION getSumPYearAdjByField(p_object_id  VARCHAR2,
                               p_daytime    DATE,
                               p_field_id   VARCHAR2,
                               p_product_id VARCHAR2,
                               p_prod_cnxt  VARCHAR2,
                               p_company_id VARCHAR2,
                               p_to_uom VARCHAR2 DEFAULT NULL
                               )
RETURN NUMBER
IS

   ln_result NUMBER := NULL;

CURSOR c_res IS
SELECT fys.net_qty net_qty
      ,fys.daytime daytime
      ,DECODE(fys.status,'PLAN','PLAN','FINAL','FINAL','ACCRUAL','ACCRUAL','P','FINAL','PLAN') status
      ,fys.uom prod_uom
      ,ec_forecast_version.product_sum_uom(fys.object_id, fys.daytime, '<=') sum_uom
      ,fm.adj_stream_item_id stream_item_id
  FROM fcst_product_setup fps, fcst_member fm, fcst_yr_status fys
 WHERE fps.object_id = fm.object_id
   AND fps.product_id = fm.product_id
   AND fps.product_context = fm.product_context
   AND fys.object_id = fm.object_id
   AND fps.product_collection_type = fm.product_collection_type
   AND fys.member_no = fm.member_no
   AND fys.object_id=p_object_id
   AND fm.field_id = p_field_id
   AND fm.product_id = p_product_id
   AND fm.product_context = p_prod_cnxt
   AND fys.daytime = p_daytime
   AND p_company_id = ec_stream_item_version.company_id(fm.adj_stream_item_id, p_daytime, '<=');

BEGIN

    FOR Curr IN c_res LOOP
        IF (p_to_uom IS NULL) THEN
            ln_result := Curr.Net_Qty;
        ELSE
            ln_result := getConvertedValue(Curr.Stream_Item_Id
                                       ,p_object_id
                                       ,Curr.Daytime
                                       ,Curr.Net_Qty
                                       ,Curr.Prod_Uom
                                       ,p_to_uom
                                       ,Curr.status);
        END IF;
    END LOOP;

RETURN ln_result;

END getSumPYearAdjByField;


FUNCTION getSumAllPYearAdjByField(p_object_id  VARCHAR2,
                                  p_daytime    DATE,
                                  p_field_group_id   VARCHAR2,
                                  p_product_id VARCHAR2,
                                  p_prod_cntx  VARCHAR2,
                                  p_company_id VARCHAR2
                                  )

RETURN NUMBER
IS

   ln_result NUMBER;

BEGIN

SELECT SUM (getSumPYearAdjByField(p_object_id, p_daytime, fm.field_id, p_product_id, p_prod_cntx, p_company_id))
  INTO ln_result
  FROM fcst_product_setup fps, fcst_member fm, fcst_yr_status fys
 WHERE fps.object_id = fm.object_id
   AND fps.product_id = fm.product_id
   AND fps.product_context = fm.product_context
   AND fys.object_id = fm.object_id
   AND fps.product_collection_type = fm.product_collection_type
   AND fys.member_no = fm.member_no
   AND fys.object_id = p_object_id
   AND fm.field_id IN ( SELECT object_id
                          FROM field_group_setup
                         WHERE field_group_id = p_field_group_id
                         )
   AND fm.product_id = p_product_id
   AND fm.object_id = p_object_id
   AND fys.daytime = p_daytime
   AND p_company_id = ec_stream_item_version.company_id(fm.adj_stream_item_id, p_daytime, '<=');

RETURN ln_result;

END getSumAllPYearAdjByField;

FUNCTION getSumAllPYearAdj(p_object_id  VARCHAR2,
                           p_daytime    DATE,
                           p_field_group_id   VARCHAR2,
                           p_product_id VARCHAR2,
                           p_prod_cntx  VARCHAR2,
                           p_company_id VARCHAR2
                           )

RETURN NUMBER
IS

   ln_result NUMBER;

BEGIN

SELECT SUM (getSumPYearAdjByField(p_object_id, p_daytime, fm.field_id, fm.product_id, fm.product_context, p_company_id, ec_forecast_version.product_sum_uom(p_object_id, p_daytime,'<=')))
  INTO ln_result
  FROM fcst_product_setup fps, fcst_member fm, fcst_yr_status fys
 WHERE fps.object_id = fm.object_id
   AND fps.product_id = fm.product_id
   AND fps.product_context = fm.product_context
   AND fys.object_id = fm.object_id
   AND fps.product_collection_type = fm.product_collection_type
   AND fys.member_no = fm.member_no
   AND fys.object_id = p_object_id
   AND fm.field_id IN ( SELECT object_id
                          FROM field_group_setup
                         WHERE field_group_id = p_field_group_id
                         )
   AND fm.product_id = p_product_id
   AND fm.object_id = p_object_id
   AND fys.daytime = p_daytime
   AND p_company_id = ec_stream_item_version.company_id(fm.adj_stream_item_id, p_daytime, '<=');

RETURN ln_result;

END getSumAllPYearAdj;

-----------------------------------------------------------------------------------------------------

PROCEDURE updateFcstProductSetup(
   p_object_id VARCHAR2,
   p_product_collection_type VARCHAR2,
   p_n_product_id VARCHAR2,  --new value
   p_n_commercial_adj_type VARCHAR2, --new value
   p_n_swap_adj_type VARCHAR2, --new value
   p_o_product_id VARCHAR2, --old value
   p_o_commercial_adj_type VARCHAR2, --old value
   p_o_swap_adj_type VARCHAR2  --old value
   )
IS
BEGIN

   --if either product id, commercial adj type or swap adj type is updated, repopulate Fcst_Member table
   IF p_n_product_id||p_n_COMMERCIAL_ADJ_TYPE||p_n_SWAP_ADJ_TYPE <> p_o_product_id||p_o_COMMERCIAL_ADJ_TYPE||p_o_SWAP_ADJ_TYPE THEN

      --delete all child records from Fcst Yr Status, Fcst Mth Status and Fcst Member
      delCascadeFcstMember(p_object_id, p_o_product_id, p_product_collection_type);
      --repopulate the Fcst Member
      populateFcstMember(p_object_id, p_n_product_id, p_product_collection_type, p_n_commercial_adj_type, p_n_swap_adj_type);

   END IF;
   --skip repopulation if the product_id, commercial adj type and swap adj type is not changed.

END updateFcstProductSetup;

-----------------------------------------------------------------------------------------------------

PROCEDURE validateFcstMember (
 p_object_id VARCHAR2,
 p_product_id VARCHAR2,
 p_n_stream_item_id VARCHAR2,
 p_o_stream_item_id VARCHAR2,
 p_product_collection_type VARCHAR2,
 p_flag VARCHAR2
)
IS
   ld_start_date DATE;
   lv_n_field_id VARCHAR2(32);
   lv_o_field_id VARCHAR2(32);
   lv_company_id VARCHAR2(32);
   ln_counter NUMBER := 0;
BEGIN

   ld_start_date := ec_forecast.start_date(p_object_id);
   lv_n_field_id := ec_stream_item_version.field_id(p_n_stream_item_id, ld_start_date, '<=');
   lv_o_field_id := ec_stream_item_version.field_id(p_o_stream_item_id, ld_start_date, '<=');
   lv_company_id := ec_stream_item_version.company_id(p_n_stream_item_id, ld_start_date, '<=');

  IF p_flag = 'INSERT' THEN
    --check if duplicated stream item added
    SELECT Count(*) into ln_counter
    FROM fcst_member
    WHERE object_id = p_object_id
    AND product_id = p_product_id
    AND stream_item_id = p_n_stream_item_id
    AND product_collection_type =  p_product_collection_type;

    IF (ln_counter > 0) THEN
       RAISE_APPLICATION_ERROR(-20000,'Duplicated Stream Item is selected');
    END IF;

    --check if stream's field has already existed
     SELECT COUNT (*) INTO ln_counter
     FROM fcst_member
     WHERE object_id = p_object_id
     AND product_id = p_product_id
     AND product_collection_type =  p_product_collection_type
     AND field_id = lv_n_field_id
     AND ec_stream_item_version.company_id(fcst_member.stream_item_id, ld_start_date, '<=') = lv_company_id;

    IF ln_counter > 0 THEN
       RAISE_APPLICATION_ERROR(-20000,'Unique Stream item required per Field per Company per Product');
    END IF;

  ELSE -- IF UPDATE

      --if stream item has been changed
      IF p_n_stream_item_id <> p_o_stream_item_id THEN
           -- if stream item field has not been changed
           IF  lv_n_field_id <> lv_o_field_id  THEN

           --check if stream's field has already existed
           SELECT COUNT (*) INTO ln_counter
           FROM fcst_member
           WHERE object_id = p_object_id
           AND product_id = p_product_id
           AND product_collection_type =  p_product_collection_type
           AND field_id = lv_n_field_id
           AND ec_stream_item_version.company_id(fcst_member.stream_item_id, ld_start_date, '<=') = lv_company_id;

            IF ln_counter > 0 THEN
               RAISE_APPLICATION_ERROR(-20000,'Unique Stream item required per Field per Company per Product');
            END IF;

          END IF;--stream item's field

      END IF;--stream item

  END IF;

END validateFcstMember;

-----------------------------------------------------------------------------------------------------

PROCEDURE populateFcstMember(
   p_object_id VARCHAR2,
   p_product_id VARCHAR2,
   p_product_collection_type VARCHAR2,
   p_commercial_adj_type VARCHAR2,
   p_swap_adj_type VARCHAR2
   )
IS

  ld_date DATE := nvl(ec_forecast_version.plan_date(p_object_id,ec_forecast.start_date(p_object_id),'<='),ec_forecast.start_date(p_object_id));
  lv_qty_fcst_id forecast.object_id%TYPE := ec_forecast_version.forecast_id(p_object_id, ec_forecast.start_date(p_object_id), '<=');
  lv_company_id forecast_version.company_id%TYPE := ec_forecast_version.company_id(p_object_id, ec_forecast.start_date(p_object_id), '<=');
  --lv_stream_item_id fcst_member.stream_item_id%TYPE;
  lv_member_type fcst_member.member_type%TYPE;
  lv_pre_field_code_1 VARCHAR2(32) := ' '; -- a variable to keep previous field code to ensure there is only 1 field record in each fcst_member for that particular product
  lv_pre_field_code_2 VARCHAR2(32) := ' ';
  ln_new_member_no NUMBER := 0;-- new generated member no
  ln_pre_member_no NUMBER := 0;-- a variable to keep previous inserted member no
  ln_counter_1 NUMBER := 0; -- counter for skip updating fcst_member's stream item id to NULL if already updated once
  ln_counter_2 NUMBER := 0; -- counter for skip updating fcst_member's adj stream item id to NULL if already updated once
  ln_indicator NUMBER;
  lv_qty_adj_stream_item_id fcst_member.adj_stream_item_id%TYPE;
  lv_qty_swap_stream_item_id fcst_member.swap_stream_item_id%TYPE;

  --cursor to get all connected qty stream item
  CURSOR c_fcst_member (cp_daytime DATE, cp_qty_fcst_id VARCHAR2, cp_field_id VARCHAR2, cp_product_id VARCHAR2, cp_company_id VARCHAR2) IS
  SELECT
      fm.field_id,  fm.product_id,  fm.stream_item_id,  fm.adj_stream_item_id,  fm.swap_stream_item_id, rownum
  FROM fcst_member fm, stream_item_version osi
  WHERE fm.object_id = cp_qty_fcst_id
  AND fm.field_id = cp_field_id
  AND fm.product_id = cp_product_id
  AND fm.product_collection_type = 'QUANTITY'
  AND fm.stream_item_id = osi.OBJECT_ID
  AND osi.COMPANY_ID = cp_company_id
  AND fm.product_context = 'PRODUCTION'
  AND osi.daytime = (SELECT MAX(daytime) FROM stream_item_version WHERE object_id = osi.object_id AND osi.DAYTIME <= cp_daytime );


  --cursor to get All candidates stream item
  CURSOR c_stim (cp_qty_fcst_id VARCHAR2, cp_company_id VARCHAR2, cp_product_id VARCHAR2) IS
  SELECT ec_field.object_code(osi.field_id) field_code, osi.field_id, s.object_id
    FROM stream_item s, stream_item_version osi, strm_version sv, fcst_member fcstm
   WHERE osi.FIELD_ID IN
         (SELECT field_id FROM fcst_member fm WHERE fm.object_id = cp_qty_fcst_id
          AND fm.product_id = cp_product_id
          AND ec_stream_item_version.company_id(fm.stream_item_id, ld_date, '<=') = cp_company_id)
     AND osi.STREAM_ITEM_CATEGORY_ID IN
         (SELECT STREAM_ITEM_CATEGORY_ID
            FROM stream_item_version osi
           WHERE object_id IN
                 (SELECT stream_item_id
                    FROM fcst_member
                   WHERE object_id = lv_qty_fcst_id)
               AND osi.company_id = cp_company_id)
     AND osi.company_id = cp_company_id --revn_fcs
     AND sv.OBJECT_ID = s.stream_id
   AND sv.daytime <= ld_date
   AND NVL(sv.end_date, ld_date+1) > ld_date
   AND osi.product_id = cp_product_id
   AND s.object_id = osi.object_id
   AND osi.daytime <= ld_date
   AND NVL(osi.end_date, ld_date+1) > ld_date
   AND fcstm.STREAM_ITEM_ID = osi.object_id
   AND fcstm.object_id = cp_qty_fcst_id
     AND fcstm.PRODUCT_CONTEXT <> 'CONSUMPTION'
 ORDER BY ec_field.object_code(osi.field_id) ASC;


  --cursor to get All candidates adj stream item
  CURSOR c_adj_stim (cp_qty_fcst_id VARCHAR2, cp_company_id VARCHAR2, cp_product_id VARCHAR2, cp_commercial_adj_type VARCHAR2) IS
  SELECT ec_field.object_code(osi.field_id) field_code, osi.field_id, s.object_id
    FROM stream_item s, stream_item_version osi, strm_version sv, fcst_member fcstm
   WHERE osi.FIELD_ID in
         (SELECT field_id FROM fcst_member fm where fm.object_id = cp_qty_fcst_id
          AND fm.product_id = cp_product_id)
     AND (SELECT object_code
            FROM stream_category
           WHERE object_id = osi.STREAM_ITEM_CATEGORY_ID) =
         cp_commercial_adj_type
     AND osi.company_id = cp_company_id --revn_fcs
     AND sv.OBJECT_ID = s.stream_id
   AND sv.daytime <= ld_date
   AND NVL(sv.end_date, ld_date+1) > ld_date
   AND osi.product_id = cp_product_id
   AND s.object_id = osi.object_id
   AND osi.company_id = cp_company_id
   AND osi.daytime <= ld_date
   AND NVL(osi.end_date, ld_date+1) > ld_date
   AND fcstm.STREAM_ITEM_ID = osi.object_id
   AND fcstm.object_id = cp_qty_fcst_id
   ORDER BY ec_field.object_code(osi.field_id) ASC;

  --cursor to get All candidates swap stream item
  CURSOR c_swap_stim (cp_qty_fcst_id VARCHAR2, cp_company_id VARCHAR2, cp_product_id VARCHAR2, cp_swap_adj_type VARCHAR2) IS
  SELECT ec_field.object_code(osi.field_id) field_code, osi.field_id, s.object_id
    FROM stream_item s, stream_item_version osi, strm_version sv, fcst_member fcstm
   WHERE osi.FIELD_ID IN
         (SELECT field_id FROM fcst_member fm where fm.object_id = cp_qty_fcst_id
          AND fm.product_id = cp_product_id)
     AND (SELECT object_code
            FROM stream_category
           WHERE object_id = osi.STREAM_ITEM_CATEGORY_ID) =
         cp_swap_adj_type
     AND osi.company_id = cp_company_id --revn_fcs
     AND sv.OBJECT_ID = s.stream_id
   AND sv.daytime <= ld_date
   AND NVL(sv.end_date, ld_date+1) > ld_date
   AND osi.product_id = cp_product_id
   AND s.object_id = osi.object_id
   AND osi.company_id = cp_company_id
   AND osi.daytime <= ld_date
   AND NVL(osi.end_date, ld_date+1) > ld_date
   AND fcstm.STREAM_ITEM_ID = osi.object_id
   AND fcstm.object_id = cp_qty_fcst_id
   ORDER BY ec_field.object_code(osi.field_id) ASC;

BEGIN

  -- Raise_Application_Error(-20000, 'Populate 1st');
  --find member type based on product collection type
  select DECODE(p_product_collection_type, 'GAS_PURCHASE', 'CONTRACT_PRODUCT','FIELD_PRODUCT') into  lv_member_type from dual;

  --product collection type <> GAS PURCHASE, start populate stream items
  IF p_product_collection_type <> 'GAS_PURCHASE' THEN

  FOR cur_rec_stim IN c_stim(lv_qty_fcst_id, lv_company_id, p_product_id) LOOP

      --if current field code not equals then insert new record into fcst_member
     IF cur_rec_stim.field_code <> lv_pre_field_code_1 THEN

        ln_indicator := 0;
        --assign an new member no for new record
         EcDp_System_Key.assignNextNumber('FCST_MEMBER', ln_new_member_no);



         --if qty stream items found
         FOR cur_rec_fcst_member IN c_fcst_member(ld_date, lv_qty_fcst_id, cur_rec_stim.field_id, p_product_id, lv_company_id) LOOP

           --if connected qty fcst_member stream item found
           ln_indicator := 1;
           lv_qty_adj_stream_item_id := null; -- cur_rec_fcst_member.adj_stream_item_id;
           lv_qty_swap_stream_item_id := null; --cur_rec_fcst_member.swap_stream_item_id;


            --copy  qty fcst_member stream item
            INSERT INTO FCST_MEMBER
           (
              OBJECT_ID,
              MEMBER_NO,
              MEMBER_TYPE,
              PRODUCT_COLLECTION_TYPE,
              COMMENTS,
              FIELD_ID,
              PRODUCT_ID,
              CONTRACT_ID,
              STREAM_ITEM_ID,
              ADJ_STREAM_ITEM_ID,
              SWAP_STREAM_ITEM_ID,
              PRODUCT_CONTEXT
            )
            VALUES
            (
              p_object_id,
              ln_new_member_no,
              lv_member_type,
              p_product_collection_type,
              NULL,
              cur_rec_fcst_member.field_id,
              cur_rec_fcst_member.product_id,
              NULL,
              cur_rec_fcst_member.stream_item_id,
              NULL, --cur_rec_fcst_member.adj_stream_item_id,
              NULL, --cur_rec_fcst_member.swap_stream_item_id,
              'REVENUE_FCST'
             );

         END LOOP;


         --if qty fcst member stream item not found
         IF ln_indicator = 0 THEN
           --populate stream items into forecast member table
             INSERT INTO FCST_MEMBER
             (
                OBJECT_ID,
                MEMBER_NO,
                MEMBER_TYPE,
                PRODUCT_COLLECTION_TYPE,
                COMMENTS,
                FIELD_ID,
                PRODUCT_ID,
                CONTRACT_ID,
                STREAM_ITEM_ID,
                ADJ_STREAM_ITEM_ID,
                SWAP_STREAM_ITEM_ID,
                PRODUCT_CONTEXT
              )
              VALUES
              (
                p_object_id,
                ln_new_member_no,
                lv_member_type,
                p_product_collection_type,
                NULL,
                cur_rec_stim.field_id,
                p_product_id,
                NULL,
                cur_rec_stim.object_id,
                NULL,
                NULL,
                'REVENUE_FCST'
               );

               --set counter 1 back to 0
               ln_counter_1 := 0;
          END IF; --skip populate from canditates stream item if qty stream item found

      ELSE --update the inserted record and set stream item equals to null, if field has already exists

         --if qty fcst member stream item not found
         IF ln_indicator = 0 THEN

            --skip update if already updated once for the same field
            if ln_counter_1 = 0 then

              UPDATE FCST_MEMBER SET STREAM_ITEM_ID = NULL
              WHERE OBJECT_ID = p_object_id
              AND MEMBER_NO = ln_pre_member_no
              AND MEMBER_TYPE = lv_member_type
              AND PRODUCT_COLLECTION_TYPE = p_product_collection_type
              AND FIELD_ID = cur_rec_stim.field_id
              AND PRODUCT_ID = p_product_id;

            end if;
              ln_counter_1 := ln_counter_1 + 1;  --if already updated once

          END IF; --skip update from canditates stream item if qty stream item found

      END IF;

     -- keep the previous field code and member_no
     lv_pre_field_code_1 := cur_rec_stim.field_code;
     ln_pre_member_no := ln_new_member_no;


        --if qty adj stream item is null then populate the candidate adj stream item
      IF lv_qty_adj_stream_item_id is null THEN

          --FOR UPDATING ADJ STREAM ITEM FOR EXISTING RECORDS IN FCST_MEMBER
          FOR cur_rec_adj_stim IN c_adj_stim(lv_qty_fcst_id, lv_company_id, p_product_id, p_commercial_adj_type) LOOP

          --if current field code not equals then insert new record into fcst_member
          IF cur_rec_adj_stim.field_code <>  lv_pre_field_code_2 THEN

             --Adj Stream Item if only 1 adj stream item per field
              UPDATE FCST_MEMBER SET ADJ_STREAM_ITEM_ID = cur_rec_adj_stim.object_id
              WHERE OBJECT_ID = p_object_id
              AND MEMBER_NO = ln_new_member_no
              AND MEMBER_TYPE = lv_member_type
              AND PRODUCT_COLLECTION_TYPE = p_product_collection_type
              AND FIELD_ID = cur_rec_adj_stim.field_id
              AND PRODUCT_ID = p_product_id;

               --set counter 2 back to 0
               ln_counter_2 := 0;

           ELSE --update the inserted record and set stream item equals to null, if field has already exists

              --skip update if already updated once for the same field
              if ln_counter_2 = 0 then

                UPDATE FCST_MEMBER SET ADJ_STREAM_ITEM_ID = NULL
                WHERE OBJECT_ID = p_object_id
                AND MEMBER_NO = ln_new_member_no
                AND MEMBER_TYPE = lv_member_type
                AND PRODUCT_COLLECTION_TYPE = p_product_collection_type
                AND FIELD_ID = cur_rec_adj_stim.field_id
                AND PRODUCT_ID = p_product_id;

              end if;

              ln_counter_2 := ln_counter_2 + 1;

           END IF;
           -- keep the previous field code and member_no
           lv_pre_field_code_2 := cur_rec_adj_stim.field_code;

           END LOOP; -- end c_adj_stim

         END IF; --skip update candidate adj stream item if qty adj stream item found

          --set previous field code code and counter back to 0
          lv_pre_field_code_2 := ' ';
          ln_counter_2 := 0;


       --if qty swap stream item is null then populate the candidate adj stream item
       IF lv_qty_swap_stream_item_id is null THEN

          --FOR UPDATING SWAP STREAM ITEM FOR EXISTING RECORDS IN FCST_MEMBER
          FOR cur_rec_swap_stim IN c_swap_stim(lv_qty_fcst_id, lv_company_id, p_product_id, p_swap_adj_type) LOOP

          --if current field code not equals then insert new record into fcst_member
          IF cur_rec_swap_stim.field_code <>  lv_pre_field_code_2 THEN

             --Adj Stream Item if only 1 adj stream item per field
              UPDATE FCST_MEMBER SET SWAP_STREAM_ITEM_ID = cur_rec_swap_stim.object_id
              WHERE OBJECT_ID = p_object_id
              AND MEMBER_NO = ln_new_member_no
              AND MEMBER_TYPE = lv_member_type
              AND PRODUCT_COLLECTION_TYPE = p_product_collection_type
              AND FIELD_ID = cur_rec_swap_stim.field_id
              AND PRODUCT_ID = p_product_id;

               --set counter 2 back to 0
               ln_counter_2 := 0;

           ELSE --update the inserted record and set stream item equals to null, if field has already exists

              --skip update if already updated once for the same field
              if ln_counter_2 = 0 then

                UPDATE FCST_MEMBER SET SWAP_STREAM_ITEM_ID = NULL
                WHERE OBJECT_ID = p_object_id
                AND MEMBER_NO = ln_new_member_no
                AND MEMBER_TYPE = lv_member_type
                AND PRODUCT_COLLECTION_TYPE = p_product_collection_type
                AND FIELD_ID = cur_rec_swap_stim.field_id
                AND PRODUCT_ID = p_product_id;

              end if;

              ln_counter_2 := ln_counter_2 + 1;

           END IF;
           -- keep the previous field code and member_no
           lv_pre_field_code_2 := cur_rec_swap_stim.field_code;

           END LOOP; -- end c_swap_stim

          END IF; --skip update candidate adj stream item if qty adj stream item found


  END LOOP; -- end c_stim

  END IF; -- skip populate if product collection type = GAS_PURCHASE

END populateFcstMember;


-----------------------------------------------------------------------------------------------------

PROCEDURE delCascadeFcstMember(
   p_object_id VARCHAR2,
   p_product_id VARCHAR2,
   p_product_collection_type VARCHAR2
   )
IS
  --cursor to get All member no for that particular product and collection type
  CURSOR c_fcst_member (cp_object_id VARCHAR2, cp_product_id  VARCHAR2, cp_product_collection_type VARCHAR2) IS
  SELECT MEMBER_NO FROM FCST_MEMBER
  WHERE OBJECT_ID = cp_object_id
  AND MEMBER_TYPE = DECODE(cp_product_collection_type, 'GAS_PURCHASE', 'CONTRACT_PRODUCT','FIELD_PRODUCT')
  AND PRODUCT_COLLECTION_TYPE = cp_product_collection_type
  AND PRODUCT_ID = cp_product_id;

BEGIN
      /*Raise_Application_Error(-20000,'TEST: forecast: ' || ec_forecast.object_code(p_object_id)
      || ', TEST: forecast: ' || ec_product.object_code(p_product_id)
      || ', Collection Type: ' || p_product_collection_type
      );*/

     FOR cur_rec IN c_fcst_member(p_object_id, p_product_id, p_product_collection_type) LOOP

         --deleting FCST_YR_STATUS
          delete FCST_YR_STATUS where object_id = p_object_id and member_no = cur_rec.member_no;

         --deleting FCST_MTH_STATUS
          delete FCST_MTH_STATUS where object_id = p_object_id and member_no = cur_rec.member_no;

         --deleting FCST_MEMBER
          delete FCST_MEMBER where object_id = p_object_id and member_no = cur_rec.member_no;

      END LOOP;

END delCascadeFcstMember;



FUNCTION getYearlyValueMthFxByMember(p_member_no VARCHAR2, -- Forecast Member No
                                  p_fromdate  DATE,
                                  p_todate    DATE,
                                  p_type      VARCHAR2) -- Column to calculate
RETURN NUMBER
IS
   ln_result NUMBER := 0;
   ln_counter NUMBER := 0;

   CURSOR c_calcYearValues (cp_member_no VARCHAR2, cp_fromdate DATE, cp_todate DATE) IS
   SELECT nvl(cost_price,0) * nvl(forex,0) local_cost_price,
          nvl(sales_price,0) * nvl(forex,0) local_sales_price,
          nvl(cost_price,0) * nvl(forex,0) * nvl(net_qty,0) purchase_cost,
          nvl(sales_price,0) * nvl(forex,0) * nvl(net_qty,0) sales_revenue,
          (nvl(cost_price,0) * nvl(forex,0) * nvl(net_qty,0)) +
          (nvl(sales_price,0) * nvl(forex,0) * nvl(net_qty,0)) net_revenue
   FROM fcst_mth_status
   WHERE member_no = cp_member_no
   AND daytime BETWEEN Nvl(cp_fromdate, to_date('01-01-1900','dd-mm-yyyy')) AND Nvl(cp_todate, cp_fromdate);
BEGIN

   FOR c_rec IN c_calcYearValues(p_member_no, p_fromdate, p_todate) LOOP
       IF lower(p_type) = 'local_cost_price' THEN
         IF c_rec.local_cost_price IS NOT NULL THEN
            ln_counter := ln_counter + 1;
            ln_result := ln_result + c_rec.local_cost_price;
         END IF;
       END IF;

       IF lower(p_type) = 'local_sales_price' THEN
         IF c_rec.local_sales_price IS NOT NULL THEN
            ln_counter := ln_counter + 1;
            ln_result := ln_result + c_rec.local_sales_price;
         END IF;
       END IF;

       IF lower(p_type) = 'purchase_cost' THEN
         IF c_rec.purchase_cost IS NOT NULL THEN
            ln_counter := ln_counter + 1;
            ln_result := ln_result + c_rec.purchase_cost;
         END IF;
       END IF;

       IF lower(p_type) = 'sales_revenue' THEN
         IF c_rec.sales_revenue IS NOT NULL THEN
            ln_counter := ln_counter + 1;
            ln_result := ln_result + c_rec.sales_revenue;
         END IF;
       END IF;

       IF lower(p_type) = 'net_revenue' THEN
         IF c_rec.net_revenue IS NOT NULL THEN
            ln_counter := ln_counter + 1;
            ln_result := ln_result + c_rec.net_revenue;
         END IF;
       END IF;
   END LOOP;

   IF ln_counter > 0 THEN
      IF p_type IN ('local_cost_price','local_sales_price') THEN -- If Average
         ln_result := ln_result / ln_counter;
      END IF;
   ELSE
      ln_result := NULL;
   END IF;

   RETURN ln_result;

END getYearlyValueMthFxByMember;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getPlanQtyByMember
-- Description    :  Gets the plan quantity for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getPlanQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                            p_daytime   DATE,     -- YEAR or MONTH date
                            p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
   ln_result NUMBER := NULL;
BEGIN

  IF p_type = 'YEAR' THEN
     ln_result := ec_fcst_yr_status.net_qty(p_member_no, TRUNC(p_daytime,'YYYY'), '=');

  ELSIF p_type = 'SUM_YEAR_BY_MTH' THEN
     -- Summing up year by using the MTH table, and adding prior year adjustment
     ln_result := ec_fcst_mth_status.math_net_qty(p_member_no,
                                                  TRUNC(p_daytime,'YYYY'),
                                                  ADD_MONTHS(TRUNC(p_daytime,'YYYY'),12),
                                                  'SUM') +
                  NVL(getPlanQtyByMember(p_member_no, TRUNC(p_daytime,'YYYY'), 'YEAR'),0);

  ELSIF p_type = 'MONTH' THEN
     ln_result := ec_fcst_mth_status.net_qty(p_member_no, TRUNC(p_daytime,'MM'), '=');

  END IF;

  RETURN ln_result;

END getPlanQtyByMember;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSwapAdjQtyByMember
-- Description    :  Gets the commercial adjustment quantity for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getCommAdjQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                               p_daytime   DATE,     -- YEAR or MONTH date
                               p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
   ln_result NUMBER := NULL;
BEGIN

  IF p_type = 'YEAR' THEN
     ln_result := ec_fcst_yr_status.commercial_adj_qty(p_member_no, TRUNC(p_daytime,'YYYY'), '=');

  ELSIF p_type = 'SUM_YEAR_BY_MTH' THEN
     -- Summing up year by using the MTH table, and adding prior year adjustment
     ln_result := ec_fcst_mth_status.math_commercial_adj_qty(p_member_no,
                                                    TRUNC(p_daytime,'YYYY'),
                                                    ADD_MONTHS(TRUNC(p_daytime,'YYYY'),12),
                                                    'SUM') +
                  NVL(getCommAdjQtyByMember(p_member_no, TRUNC(p_daytime,'YYYY'), 'YEAR'),0);

  ELSIF p_type = 'MONTH' THEN
     ln_result := ec_fcst_mth_status.commercial_adj_qty(p_member_no, TRUNC(p_daytime,'MM'), '=');

  END IF;

  RETURN ln_result;

END getCommAdjQtyByMember;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSwapAdjQtyByMember
-- Description    :  Gets the swap adjustment quantity for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getSwapAdjQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                               p_daytime   DATE,     -- YEAR or MONTH date
                               p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
   ln_result NUMBER := NULL;
BEGIN

  IF p_type = 'YEAR' THEN
     ln_result := ec_fcst_yr_status.swap_adj_qty(p_member_no, TRUNC(p_daytime,'YYYY'), '=');

  ELSIF p_type = 'SUM_YEAR_BY_MTH' THEN
     -- Summing up year by using the MTH table, and adding prior year adjustment
     ln_result := ec_fcst_mth_status.math_swap_adj_qty(p_member_no,
                                                       TRUNC(p_daytime,'YYYY'),
                                                       ADD_MONTHS(TRUNC(p_daytime,'YYYY'),12),
                                                       'SUM') +
                  NVL(getSwapAdjQtyByMember(p_member_no, TRUNC(p_daytime,'YYYY'), 'YEAR'),0);

  ELSIF p_type = 'MONTH' THEN
     ln_result := ec_fcst_mth_status.swap_adj_qty(p_member_no, TRUNC(p_daytime,'MM'), '=');

  END IF;

  RETURN ln_result;

END getSwapAdjQtyByMember;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getAvailSalesQtyByMember
-- Description    :  Gets the available sales quantity for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getAvailSalesQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                               p_daytime   DATE,     -- YEAR or MONTH date
                               p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
   ln_result NUMBER := NULL;
BEGIN

   ln_result := (NVL(getPlanQtyByMember(p_member_no, p_daytime, p_type),0) +
                (NVL(getCommAdjQtyByMember(p_member_no, p_daytime, p_type),0) +
                 NVL(getSwapAdjQtyByMember(p_member_no, p_daytime, p_type),0)));

   RETURN ln_result;

END getAvailSalesQtyByMember;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSaleQtyByMember
-- Description    :  Gets the sales quantity for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getSaleQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                            p_daytime   DATE,     -- YEAR or MONTH date
                            p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
   ln_result NUMBER;
   lv2_prod_coll_type VARCHAR2(32);
BEGIN



  IF p_type = 'YEAR' THEN
     lv2_prod_coll_type := ec_fcst_member.product_collection_type(p_member_no);

     -- For the PYA records we actually need to pick term/spot sale qtys for gas sales
     -- because sale_qty is not held up to date. (This should be handled the same way as for monthly records):
     IF lv2_prod_coll_type = 'GAS_SALES' THEN
        ln_result := nvl(ec_fcst_yr_status.term_sale_qty(p_member_no, TRUNC(p_daytime,'YYYY'), '='),0) +
                     nvl(ec_fcst_yr_status.spot_sale_qty(p_member_no, TRUNC(p_daytime,'YYYY'), '='),0);
     ELSE
        ln_result := ec_fcst_yr_status.sale_qty(p_member_no, TRUNC(p_daytime,'YYYY'), '=');
     END IF;

  ELSIF p_type = 'SUM_YEAR_BY_MTH' THEN
     -- Summing up year by using the MTH table, and adding prior year adjustment
     ln_result := ec_fcst_mth_status.math_sale_qty(p_member_no,
                                                   TRUNC(p_daytime,'YYYY'),
                                                   ADD_MONTHS(TRUNC(p_daytime,'YYYY'),12),
                                                   'SUM') +
                  NVL(getSaleQtyByMember(p_member_no, TRUNC(p_daytime,'YYYY'), 'YEAR'),0);

  ELSIF p_type = 'MONTH' THEN
     ln_result := ec_fcst_mth_status.sale_qty(p_member_no, TRUNC(p_daytime,'MM'), '=');

  END IF;

  RETURN ln_result;

END getSaleQtyByMember;




--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getOpeningPosiionByMember
-- Description    :  Gets the inventory opening position for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getOpeningPosionByMember(p_member_no VARCHAR2, -- Forecast Member No
                            p_daytime   DATE,     -- YEAR or MONTH date
                            p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
   ln_result NUMBER;
BEGIN

  IF p_type = 'YEAR' THEN
     ln_result := ec_fcst_yr_status.inv_opening_pos_qty(p_member_no, TRUNC(p_daytime,'YYYY'), '=');

  ELSIF p_type = 'SUM_YEAR_BY_MTH' THEN
     -- Summing up year by using the MTH table, and adding prior year adjustment
     ln_result := ec_fcst_mth_status.math_inv_opening_pos_qty(p_member_no,
                                                   TRUNC(p_daytime,'YYYY'),
                                                   ADD_MONTHS(TRUNC(p_daytime,'YYYY'),12),
                                                   'SUM') +
                  NVL(getOpeningPosionByMember(p_member_no, TRUNC(p_daytime,'YYYY'), 'YEAR'),0);

  ELSIF p_type = 'MONTH' THEN
     ln_result := ec_fcst_mth_status.inv_opening_pos_qty(p_member_no, TRUNC(p_daytime,'MM'), '=');

  END IF;

  RETURN ln_result;

END getOpeningPosionByMember;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getClosingPosionByMember
-- Description    :  Gets the inventory closing position for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getClosingPosionByMember(p_member_no VARCHAR2, -- Forecast Member No
                            p_daytime   DATE,     -- YEAR or MONTH date
                            p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
   ln_result NUMBER;
BEGIN

  IF p_type = 'YEAR' THEN
     ln_result := ec_fcst_yr_status.inv_closing_pos_qty(p_member_no, TRUNC(p_daytime,'YYYY'), '=');

  ELSIF p_type = 'SUM_YEAR_BY_MTH' THEN
     -- Summing up year by using the MTH table, and adding prior year adjustment
     ln_result := ec_fcst_mth_status.math_inv_closing_pos_qty(p_member_no,
                                                   TRUNC(p_daytime,'YYYY'),
                                                   ADD_MONTHS(TRUNC(p_daytime,'YYYY'),12),
                                                   'SUM') +
                  NVL(getClosingPosionByMember(p_member_no, TRUNC(p_daytime,'YYYY'), 'YEAR'),0);

  ELSIF p_type = 'MONTH' THEN
     ln_result := ec_fcst_mth_status.inv_closing_pos_qty(p_member_no, TRUNC(p_daytime,'MM'), '=');

  END IF;

  RETURN ln_result;

END getClosingPosionByMember;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getClosingValueByMember
-- Description    :  Gets the inventory closing value for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getClosingValueByMember(p_member_no VARCHAR2, -- Forecast Member No
                            p_daytime   DATE,     -- YEAR or MONTH date
                            p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
   ln_result NUMBER;
BEGIN

  IF p_type = 'YEAR' THEN
     ln_result := ec_fcst_yr_status.inv_closing_value(p_member_no, TRUNC(p_daytime,'YYYY'), '=');

  ELSIF p_type = 'SUM_YEAR_BY_MTH' THEN
     -- Summing up year by using the MTH table, and adding prior year adjustment
     ln_result := ec_fcst_mth_status.math_inv_closing_value(p_member_no,
                                                   TRUNC(p_daytime,'YYYY'),
                                                   ADD_MONTHS(TRUNC(p_daytime,'YYYY'),12),
                                                   'SUM') +
                  NVL(getClosingValueByMember(p_member_no, TRUNC(p_daytime,'YYYY'), 'YEAR'),0);

  ELSIF p_type = 'MONTH' THEN
     ln_result := ec_fcst_mth_status.inv_closing_value(p_member_no, TRUNC(p_daytime,'MM'), '=');

  END IF;

  RETURN ln_result;

END getClosingValueByMember;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSpotSaleQtyByMember
-- Description    :  Gets the spot sales quantity for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getSpotSaleQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                               p_daytime   DATE,     -- YEAR or MONTH date
                               p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
   ln_result NUMBER;
BEGIN

  IF p_type = 'YEAR' THEN
     ln_result := ec_fcst_yr_status.spot_sale_qty(p_member_no, TRUNC(p_daytime,'YYYY'), '=');

  ELSIF p_type = 'SUM_YEAR_BY_MTH' THEN
     -- Summing up year by using the MTH table, and adding prior year adjustment
     ln_result := ec_fcst_mth_status.math_spot_sale_qty(p_member_no,
                                                       TRUNC(p_daytime,'YYYY'),
                                                       ADD_MONTHS(TRUNC(p_daytime,'YYYY'),12),
                                                       'SUM') +
                  NVL(getSpotSaleQtyByMember(p_member_no, TRUNC(p_daytime,'YYYY'), 'YEAR'),0);

  ELSIF p_type = 'MONTH' THEN
     ln_result := ec_fcst_mth_status.spot_sale_qty(p_member_no, TRUNC(p_daytime,'MM'), '=');

  END IF;

  RETURN ln_result;

END getSpotSaleQtyByMember;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getTermSaleQtyByMember
-- Description    :  Gets the term sale quantity for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getTermSaleQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                               p_daytime   DATE,     -- YEAR or MONTH date
                               p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
   ln_result NUMBER;
BEGIN

  IF p_type = 'YEAR' THEN
     ln_result := ec_fcst_yr_status.term_sale_qty(p_member_no, TRUNC(p_daytime,'YYYY'), '=');

  ELSIF p_type = 'SUM_YEAR_BY_MTH' THEN
     -- Summing up year by using the MTH table, and adding prior year adjustment
     ln_result := ec_fcst_mth_status.math_term_sale_qty(p_member_no,
                                                       TRUNC(p_daytime,'YYYY'),
                                                       ADD_MONTHS(TRUNC(p_daytime,'YYYY'),12),
                                                       'SUM') +
                  NVL(getTermSaleQtyByMember(p_member_no, TRUNC(p_daytime,'YYYY'), 'YEAR'),0);

  ELSIF p_type = 'MONTH' THEN
     ln_result := ec_fcst_mth_status.term_sale_qty(p_member_no, TRUNC(p_daytime,'MM'), '=');

  END IF;

  RETURN ln_result;

END getTermSaleQtyByMember;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getInventoryMovQtyLiqByMember
-- Description    :  Gets the inventory movement for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getInventoryMovQtyLiqByMember(p_member_no VARCHAR2, -- Forecast Member No
                               p_daytime   DATE,     -- YEAR or MONTH date
                               p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
ln_result NUMBER;
ld_fcst_end_date DATE;
ld_fcst_start_date DATE;
lv2_fcst_id forecast.object_id%type;

BEGIN

lv2_fcst_id := ec_fcst_member.object_id(p_member_no);
ld_fcst_end_date := ec_forecast.end_date(lv2_fcst_id);
ld_fcst_start_date := ec_forecast.start_date(lv2_fcst_id);


   ln_result := nvl(getClosingPosionByMember(p_member_no, ld_fcst_end_date, 'MONTH'),0) -
                nvl(getOpeningPosionByMember(p_member_no, ld_fcst_start_date, 'MONTH'),0);

   RETURN ln_result;

END getInventoryMovQtyLiqByMember;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getInventoryMovQtyGSalByMember
-- Description    :  Gets the inventory movement for a certain member on a month or year
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getInventoryMovQtyGSalByMember(p_member_no VARCHAR2, -- Forecast Member No
                               p_daytime   DATE,     -- YEAR or MONTH date
                               p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
RETURN NUMBER
--</EC-DOC>
IS
   ln_result NUMBER;
ld_fcst_end_date DATE;
ld_fcst_start_date DATE;
lv2_fcst_id forecast.object_id%type;

BEGIN

lv2_fcst_id := ec_fcst_member.object_id(p_member_no);
ld_fcst_end_date := ec_forecast.end_date(lv2_fcst_id);
ld_fcst_start_date := ec_forecast.start_date(lv2_fcst_id);


   ln_result := nvl(getClosingPosionByMember(p_member_no, ld_fcst_end_date, 'MONTH'),0) -
                nvl(getOpeningPosionByMember(p_member_no, ld_fcst_start_date, 'MONTH'),0);

   RETURN ln_result;

END getInventoryMovQtyGSalByMember;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSumBasePriceByField
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getSumBasePriceByMember(p_object_id  VARCHAR2,
                                p_daytime    DATE,
                                p_field_id   VARCHAR2,
                                p_product_id VARCHAR2)
RETURN NUMBER
--</EC-DOC>



IS

ln_sum NUMBER := 0;

CURSOR c_fcst_member_field(cp_object_id VARCHAR2, cp_field_id VARCHAR2, cp_product_id VARCHAR2) IS
  SELECT member_no
    FROM fcst_member
   WHERE object_id = cp_object_id
     AND field_id = cp_field_id
     AND product_id = cp_product_id;






BEGIN
     FOR members IN c_fcst_member_field (p_object_id, p_field_id, p_product_id) LOOP
         ln_sum := ln_sum + nvl(ec_fcst_mth_status.math_base_price(members.member_no,p_daytime,last_day(p_daytime)),0);
     END LOOP;


RETURN ln_sum;

END getSumBasePriceByMember;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSumDifferentialByMember
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getSumDifferentialByMember(p_object_id  VARCHAR2,
                                    p_daytime    DATE,
                                    p_field_id   VARCHAR2,
                                    p_product_id VARCHAR2)
RETURN NUMBER
--</EC-DOC>



IS

ln_sum NUMBER := 0;

CURSOR c_fcst_member_field(cp_object_id VARCHAR2, cp_field_id VARCHAR2, cp_product_id VARCHAR2) IS
  SELECT member_no
    FROM fcst_member
   WHERE object_id = cp_object_id
     AND field_id = cp_field_id
     AND product_id = cp_product_id;



BEGIN
     FOR members IN c_fcst_member_field (p_object_id, p_field_id, p_product_id) LOOP
         ln_sum := ln_sum + nvl(ec_fcst_mth_status.math_differential(members.member_no,p_daytime,last_day(p_daytime)),0);
     END LOOP;


RETURN ln_sum;

END getSumDifferentialByMember;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  isPriorToPlanDate
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :  Returns TRUE if passed date is equal to or less than plan date. FALSE otherwise.
--                   Unless the last optional argument is passed as TRUE. In that case this function will return FALSE if passed date equals plan date
--
-------------------------------------------------------------------------------------------------
FUNCTION isPriorToPlanDate(p_object_id VARCHAR2, p_daytime DATE, p_false_on_plan_date VARCHAR2 DEFAULT 'FALSE')

RETURN VARCHAR2
--</EC-DOC>


IS

lv_result VARCHAR2(32) := 'TRUE';
ld_plan_date DATE;


BEGIN

ld_plan_date := ec_forecast_version.plan_date(p_object_id,p_daytime,'<=');

IF p_false_on_plan_date = 'FALSE' THEN
  IF p_daytime > NVL(ld_plan_date,p_daytime+1) THEN
     lv_result := 'FALSE';
  END IF;

ELSIF p_false_on_plan_date = 'TRUE' THEN
  IF p_daytime >= NVL(ld_plan_date,p_daytime+1) THEN
     lv_result := 'FALSE';
  END IF;
END IF;


RETURN lv_result;

END isPriorToPlanDate;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSumTermPriceByMember
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getSumTermPriceByMember(p_object_id  VARCHAR2,
                                 p_daytime    DATE,
                                 p_field_id   VARCHAR2,
                                 p_product_id VARCHAR2)
RETURN NUMBER
--</EC-DOC>



IS

ln_sum NUMBER := 0;

CURSOR c_fcst_member_field(cp_object_id VARCHAR2, cp_field_id VARCHAR2, cp_product_id VARCHAR2) IS
  SELECT member_no
    FROM fcst_member
   WHERE object_id = cp_object_id
     AND field_id = cp_field_id
     AND product_id = cp_product_id;


BEGIN
     FOR members IN c_fcst_member_field (p_object_id, p_field_id, p_product_id) LOOP
         ln_sum := ln_sum + nvl(ec_fcst_mth_status.math_term_price(members.member_no,p_daytime,last_day(p_daytime)),0);
     END LOOP;


RETURN ln_sum;

END getSumTermPriceByMember;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSumSpotPriceByMember
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getSumSpotPriceByMember(p_object_id  VARCHAR2,
                                 p_daytime    DATE,
                                 p_field_id   VARCHAR2,
                                 p_product_id VARCHAR2)
RETURN NUMBER
--</EC-DOC>



IS

ln_sum NUMBER := 0;

CURSOR c_fcst_member_field(cp_object_id VARCHAR2, cp_field_id VARCHAR2, cp_product_id VARCHAR2) IS
  SELECT member_no
    FROM fcst_member
   WHERE object_id = cp_object_id
     AND field_id = cp_field_id
     AND product_id = cp_product_id;


BEGIN
     FOR members IN c_fcst_member_field (p_object_id, p_field_id, p_product_id) LOOP
         ln_sum := ln_sum + nvl(ec_fcst_mth_status.math_spot_price(members.member_no,p_daytime,last_day(p_daytime)),0);
     END LOOP;


RETURN ln_sum;

END getSumSpotPriceByMember;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSumCostPriceByMember
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getSumCostPriceByMember(p_object_id      VARCHAR2,
                                 p_daytime        DATE,
                                 p_contract_id    VARCHAR2,
                                 p_product_id     VARCHAR2)
RETURN NUMBER
--</EC-DOC>



IS

ln_sum NUMBER := 0;

CURSOR c_fcst_member_prod(cp_object_id VARCHAR2, cp_contract_id VARCHAR2, cp_product_id VARCHAR2) IS
  SELECT member_no
    FROM fcst_member
   WHERE object_id = cp_object_id
     AND contract_id = cp_contract_id
     AND product_id = cp_product_id;


BEGIN
     FOR members IN c_fcst_member_prod (p_object_id, p_contract_id, p_product_id) LOOP
         ln_sum := ln_sum + nvl(ec_fcst_mth_status.math_cost_price(members.member_no,p_daytime,last_day(p_daytime)),0);
     END LOOP;


RETURN ln_sum;

END getSumCostPriceByMember;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getSumSalesPriceByMember
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getSumSalesPriceByMember(p_object_id   VARCHAR2,
                                  p_daytime     DATE,
                                  p_contract_id VARCHAR2,
                                  p_product_id  VARCHAR2)
RETURN NUMBER
--</EC-DOC>



IS

ln_sum NUMBER := 0;

CURSOR c_fcst_member_prod(cp_object_id VARCHAR2, cp_contract_id VARCHAR2, cp_product_id VARCHAR2) IS
  SELECT member_no
    FROM fcst_member
   WHERE object_id = cp_object_id
     AND contract_id = cp_contract_id
     AND product_id = cp_product_id;


BEGIN
     FOR members IN c_fcst_member_prod (p_object_id, p_contract_id, p_product_id) LOOP
         ln_sum := ln_sum + nvl(ec_fcst_mth_status.math_sales_price(members.member_no,p_daytime,last_day(p_daytime)),0);
     END LOOP;


RETURN ln_sum;

END getSumSalesPriceByMember;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  PopulateFcst
-- Description    :  This procedure is called from the Quantity and Revenue Forecast Properties business functions for EC Revenue.
--                   The procedure will based on the functional area code call the appropriate internal package procedure.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures: PopulateQtyFcst, PopulateRevnFcst
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE PopulateFcst(p_object_id      VARCHAR2,
                       p_func_area_code VARCHAR2,
                       p_user           VARCHAR2)
--</EC-DOC>
IS

CURSOR c_stream_items IS
SELECT fm.stream_item_id, fm.swap_stream_item_id, fm.adj_stream_item_id
FROM fcst_member fm
WHERE object_id = p_object_id;

CURSOR c_running IS
SELECT
    ec_forecast_version.name(aiv.parameter_value, aiv.created_date, '<=') FORECAST_NAME,
    qt.trigger_name,
  qt.trigger_group,
  ecdp_scheduler.QuartLongTimeToEcDate(qt.start_time) AS start_time,
      CASE when ecdp_scheduler.isJobExecuting(qt.trigger_name, qt.trigger_group) = 'Y'
        THEN 'EXECUTING' ELSE qt.trigger_state END AS trigger_state
    FROM qrtz_triggers qt, qrtz_job_details qjd, business_action ba, action_parameter ap, action_instance ai, action_instance_value aiv
    WHERE
    ba.name = 'REVN_' || substr(qjd.job_name, 0, instr(qjd.job_name, '.')-1)
    AND qt.trigger_name = qjd.job_name
    AND ap.business_action_no = ba.business_action_no
    AND ap.name = 'FORECAST_ID'
    AND aiv.action_parameter_no = ap.action_parameter_no
    AND ai.business_action_no = ba.business_action_no
    AND ai.action_instance_no = (SELECT max(action_instance_no) FROM action_instance WHERE business_action_no = ba.business_action_no )
    AND aiv.action_instance_no = ai.action_instance_no
    AND (qt.trigger_state!='COMPLETE' OR ecdp_scheduler.isJobExecuting(qt.trigger_name, qt.trigger_group)='Y')
      AND qt.trigger_name LIKE 'PopulateForecastCase%.AUTOGEN'
      AND ecdp_scheduler.QuartLongTimeToEcDate(qt.start_time) > Ecdp_Timestamp.getCurrentSysdate-1
;

ln_counter NUMBER := 0;

BEGIN

    FOR curRunning IN c_running LOOP
      ln_counter := ln_counter + 1;
      IF (curRunning.trigger_state = 'EXECUTING' AND ln_counter > 1) THEN
            Raise_Application_Error(-20000,'Can not start populate since there is an existing populate job running.');
    END IF;
  END LOOP;

    IF   p_func_area_code = 'QUANTITY_FORECAST' THEN
        PopulateQtyFcst(p_object_id,p_user);
        -- Populate STIM tables for forecast case
        EcDp_Revn_Stim_Fcst.PopulateStimFcstMth(p_object_id, ec_forecast.start_date(p_object_id));
    ELSIF p_func_area_code = 'REVENUE_FORECAST' THEN
        PopulateRevnFcst(p_object_id,p_user);
    END IF;

    -- Populate STIM tables for forecast case
    EcDp_Revn_Stim_Fcst.PopulateStimFcstMth(p_object_id, ec_forecast.start_date(p_object_id));

END PopulateFcst;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  setValidPlanDate
-- Description    :  Called when creating or modifying a forecast object.
--                   Makes sure plan date is set to first of January when populate method is set to plan
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE setValidPlanDate(p_object_id VARCHAR2, p_daytime DATE)
--</EC-DOC>


IS

ld_plan_date                          DATE;
lv_pop_method                         VARCHAR2(32);
ld_start_date                         DATE;
ld_end_date                           DATE;

BEGIN

    ld_plan_date := ec_forecast_version.plan_date(p_object_id,p_daytime,'<=');
    lv_pop_method := ec_forecast_version.populate_method(p_object_id,p_daytime,'<=');

    ld_start_date := ec_forecast.start_date(p_object_id);
    ld_end_date := ec_forecast.end_date(p_object_id);
    IF (ld_plan_date > ld_end_date) THEN
        RAISE_APPLICATION_ERROR(-20000,'Plan date can not be after end date.');
    END IF;
    IF (ld_plan_date < ld_start_date) THEN
        RAISE_APPLICATION_ERROR(-20000,'Plan date can not be before start date.');
    END IF;

    IF lv_pop_method = 'PLAN' THEN

        UPDATE forecast_version f
            SET f.plan_date = trunc(ld_plan_date, 'YYYY')
        WHERE f.object_id = p_object_id
            AND f.daytime = p_daytime;

    END IF;

END setValidPlanDate;
--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  approveQtyFcst
-- Description    :  Called when verify the forecast month status object.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE approveRevnFcst(
   p_object_id VARCHAR2,
   p_field_group_id VARCHAR2,
   p_product_collection_type VARCHAR2)
IS

ld_start_date DATE;
--ln_counter NUMBER := 0;
lv2_forecast_id VARCHAR2(32);


BEGIN

ld_start_date := ec_forecast.start_date(p_object_id);

SELECT ec_forecast_version.forecast_id(p_object_id, ld_start_date, '<=') into lv2_forecast_id from dual;

/*SELECT COUNT(*) INTO ln_counter
   FROM forecast f,
        forecast_version fv
  WHERE f.object_id = fv.object_id
    AND fv.forecast_id = lv2_forecast_id
    AND f.functional_area_code = 'QUANTITY_FORECAST'
    AND EXISTS
        (SELECT fv.object_id
           FROM fcst_mth_status fms
          WHERE fms.object_id = fv.object_id
            AND (record_status = 'P' OR record_status = 'V'));
*/
--if not all qty fcst member has been verify
--IF  ln_counter > 0 THEN
IF ec_forecast.record_status(ec_forecast_version.forecast_id(p_object_id, ec_forecast.start_date(p_object_id), '<=')) <> 'A' THEN
   Raise_Application_Error(-20000,'Quantity forecast case has to be approved before approval of Revenue forecast case');
END IF;

  UPDATE fcst_mth_status
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE fcst_comment
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE forecast_version
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE forecast
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE fcst_product_setup
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE fcst_member
     SET record_status = 'A'
   WHERE object_id = p_object_id;

  UPDATE fcst_yr_status
     SET record_status = 'A'
   WHERE object_id = p_object_id;

END approveRevnFcst;
--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  verifyQtyFcst
-- Description    :  Called when verify the forecast month status object.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE verifyRevnFcst(p_object_id  VARCHAR2,
                        p_member_no   VARCHAR2)
IS

ln_counter NUMBER;
lv2_field_id VARCHAR2(32);
lv2_product_id VARCHAR2(32);
lv2_product_collection_type fcst_member.product_collection_type%type;

BEGIN

lv2_field_id := ec_fcst_member.field_id(p_member_no);
lv2_product_id := ec_fcst_member.product_id(p_member_no);
lv2_product_collection_type := ec_fcst_member.product_collection_type(p_member_no);

--12 records has been updated to V
    UPDATE fcst_mth_status
       SET record_status = 'V'
     WHERE object_id = p_object_id
       AND member_no = p_member_no;

--year record has been updated to V
    UPDATE fcst_yr_status
       SET record_status = 'V'
     WHERE object_id = p_object_id
       AND member_no = p_member_no;

--update comment table
    UPDATE fcst_comment
       SET record_status = 'V'
     WHERE object_id = p_object_id
       AND field_id = lv2_field_id
       AND product_id = lv2_product_id;

--check by field by product by collection type
SELECT COUNT(*)
  INTO ln_counter
  FROM fcst_mth_status fms
 WHERE object_id = p_object_id
   AND record_status <> 'V'
   AND member_no in
       (select member_no
          from fcst_member
         where product_collection_type = lv2_product_collection_type
           and object_id = p_object_id
           AND product_id = lv2_product_id);

--if all are verified
  IF ln_counter = 0 THEN

     --verify fcst member by product by collection type
     UPDATE fcst_member
     SET record_status = 'V'
     WHERE object_id = p_object_id
     AND product_id = lv2_product_id
     AND product_collection_type = lv2_product_collection_type;

  END IF;

--by product by collection type
SELECT COUNT (*) INTO ln_counter
    FROM fcst_member fm
   WHERE object_id = p_object_id
     AND record_status <> 'V'
     AND product_id = lv2_product_id
     AND product_collection_type = lv2_product_collection_type;

--if all are verified
IF ln_counter = 0 THEN

     --verify fcst product setup by product by collection type
     UPDATE fcst_product_setup
     SET record_status = 'V'
     WHERE object_id = p_object_id
     AND product_id = lv2_product_id
     AND product_collection_type = lv2_product_collection_type;

 END IF;


SELECT COUNT (*) INTO ln_counter
    FROM fcst_product_setup fps
   WHERE object_id = p_object_id
     AND record_status <> 'V';

IF ln_counter = 0 THEN

  UPDATE forecast_version
       SET record_status = 'V'
     WHERE object_id = p_object_id;

    UPDATE forecast
       SET record_status = 'V'
     WHERE object_id = p_object_id;

 END IF;

END verifyRevnFcst;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updFcstLiquidPrices
-- Description    :  Called from the business action UpdatePopulatedValuesBusinessAction
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE updFcstLiquidPrices(p_member_no NUMBER, p_daytime DATE, p_base_price NUMBER, p_differential NUMBER, p_forex NUMBER)
--<EC-DOC>

IS

ln_value NUMBER;
ln_net_revenue   NUMBER;
ln_gross_revenue   NUMBER;

CURSOR v (cp_member_no NUMBER, cp_daytime DATE) IS

       SELECT f.net_price, f.local_spot_price, f.member_no, f.daytime, f.pct_adj_price, f.value_adj_price, f.sale_qty
         FROM fcst_mth_status f
        WHERE f.member_no = cp_member_no
          AND f.daytime = cp_daytime;


BEGIN


FOR c_val IN v (p_member_no, p_daytime) LOOP

ln_value := NVL(p_base_price+NVL(p_differential, 0),0);

--ln_net_revenue := ln_local_gross_revenue + (ln_local_gross_revenue*nvl(c_val.pct_adj_price,0)/100) + nvl(c_val.value_adj_price,0);

    -- Base price / differenctial or forex has been updated from screen
    IF ln_value <> nvl(c_val.net_price,0) THEN


ln_gross_revenue := c_val.sale_qty * (ln_value * p_forex);
ln_net_revenue :=  ln_gross_revenue + (ln_gross_revenue*nvl(c_val.pct_adj_price,0)/100) + nvl(c_val.value_adj_price,0);


       UPDATE fcst_mth_status f
          SET f.net_price        = ln_value,
              f.differential     = NVL(f.differential, 0), -- To add zero as default differential
              f.local_spot_price = ln_value * p_forex,
              f.local_gross_revenue = ln_gross_revenue,
              f.local_net_revenue = ln_net_revenue
        WHERE f.member_no = c_val.member_no
          AND f.daytime = c_val.daytime;

     -- Only Forex has been updated from screen
     ELSIF nvl(c_val.local_spot_price,0) <> nvl(c_val.net_price,0)*p_forex THEN

ln_gross_revenue := c_val.sale_qty * (c_val.net_price * p_forex);
ln_net_revenue  :=  ln_gross_revenue + (ln_gross_revenue*nvl(c_val.pct_adj_price,0)/100) + nvl(c_val.value_adj_price,0);

        UPDATE fcst_mth_status f
           SET f.local_spot_price = c_val.net_price * p_forex,
               f.local_gross_revenue = ln_gross_revenue,
               f.local_net_revenue = ln_net_revenue
         WHERE f.member_no = c_val.member_no
           AND f.daytime = c_val.daytime;

     END IF;

END LOOP;

END updFcstLiquidPrices;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updateFcstGSalesPrices
-- Description    :  Called from the business action UpdFcstGSalesPriceBusinessAction
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE updateFcstGSalesPrices(p_member_no NUMBER, p_daytime DATE)
--<EC-DOC>

IS

ln_local_term_price NUMBER;
ln_local_spot_price NUMBER;
ln_local_gross_revenue     NUMBER;
ln_net_revenue             NUMBER;

CURSOR v (cp_member_no NUMBER, cp_daytime DATE) IS

       SELECT f.net_price,
              f.local_spot_price,
              f.local_term_price,
              f.member_no,
              f.daytime,
              f.spot_sale_qty,
              f.term_sale_qty,
              f.pct_adj_price,
              f.value_adj_price,
              f.forex,
              f.term_price,
              f.spot_price
         FROM fcst_mth_status f
        WHERE f.member_no = cp_member_no
          AND f.daytime = cp_daytime;

BEGIN

FOR c_val IN v (p_member_no, p_daytime) LOOP

ln_local_term_price := NVL(c_val.term_price,0) * nvl(c_val.forex,0);
ln_local_spot_price := NVL(c_val.spot_price,0) * nvl(c_val.forex,0);

ln_local_gross_revenue := nvl(c_val.spot_sale_qty,0) * nvl(ln_local_spot_price,0);
ln_local_gross_revenue := ln_local_gross_revenue + (nvl(c_val.term_sale_qty,0) * nvl(ln_local_term_price,0));
ln_net_revenue := ln_local_gross_revenue + (ln_local_gross_revenue*nvl(c_val.pct_adj_price,0)/100) + nvl(c_val.value_adj_price,0);

    -- Base price / differenctial or forex has been updated from screen
    IF ln_local_term_price <> nvl(c_val.local_term_price,0) OR ln_local_spot_price <> nvl(c_val.local_spot_price,0) THEN

       UPDATE fcst_mth_status f
          SET f.local_term_price    = ln_local_term_price,
              f.local_spot_price    = ln_local_spot_price,
              f.local_gross_revenue = ln_local_gross_revenue,
              f.local_net_revenue   = ln_net_revenue
        WHERE f.member_no = c_val.member_no
          AND f.daytime = c_val.daytime;

     END IF;


END LOOP;

END updateFcstGSalesPrices;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updateFcstGSalesRevenue
-- Description    :  Called from the business action UpdFcstGSalesRevenueBusinessAction
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE updateFcstGSalesRevenue(p_member_no NUMBER, p_daytime DATE)
--<EC-DOC>

IS

CURSOR v (cp_member_no NUMBER, cp_daytime DATE) IS

       SELECT f.net_price,
              f.local_spot_price,
              f.local_term_price,
              f.member_no,
              f.daytime,
              f.local_gross_revenue,
              f.pct_adj_price,
              f.value_adj_price,
              f.local_net_revenue
         FROM fcst_mth_status f
        WHERE f.member_no = cp_member_no
          AND f.daytime = cp_daytime;


CURSOR v_yr (cp_member_no NUMBER, cp_daytime DATE) IS

       SELECT f.member_no,
              f.daytime,
              f.value_adj_price,
              f.local_net_revenue
         FROM fcst_yr_status f
        WHERE f.member_no = cp_member_no
          AND f.daytime = cp_daytime;

ln_value  NUMBER;
ln_yr_value  NUMBER;

BEGIN

FOR c_val IN v (p_member_no, p_daytime) LOOP

ln_value := nvl(c_val.local_gross_revenue,0) + ( nvl(c_val.local_gross_revenue,0)* nvl(c_val.pct_adj_price,0)/100) + nvl(c_val.value_adj_price,0);

   IF (ln_value <> nvl(c_val.local_net_revenue,0)) THEN

      UPDATE fcst_mth_status f
          SET f.local_net_revenue = ln_value
        WHERE f.member_no = c_val.member_no
          AND f.daytime = c_val.daytime;

   END IF;

END LOOP;


FOR c_val_yr IN v_yr (p_member_no, p_daytime) LOOP

   IF (nvl(c_val_yr.value_adj_price,0) <> nvl(c_val_yr.local_net_revenue,0)) THEN

      UPDATE fcst_yr_status f
          SET f.local_net_revenue = c_val_yr.value_adj_price
        WHERE f.member_no = c_val_yr.member_no
          AND f.daytime = c_val_yr.daytime;

   END IF;

END LOOP;



END updateFcstGSalesRevenue;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updateFcstGPurchPrice
-- Description    :  Called from the business action UpdFcstGPurchPriceBusinessAction
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE updateFcstGPurchPrice(p_member_no NUMBER, p_daytime DATE)
--<EC-DOC>

IS

ln_net_revenue NUMBER;

CURSOR v (cp_member_no NUMBER, cp_daytime DATE) IS

       SELECT f.cost_price,
              f.sales_price,
              f.forex,
              f.net_qty,
              f.daytime,
              f.member_no
         FROM fcst_mth_status f
        WHERE f.member_no = cp_member_no
          AND f.daytime = cp_daytime;


BEGIN

FOR c_val IN v (p_member_no, p_daytime) LOOP

  ln_net_revenue := (nvl(c_val.cost_price,0)*nvl(c_val.forex,0)*nvl(c_val.net_qty,0)) + (nvl(c_val.sales_price,0)*nvl(c_val.forex,0)*nvl(c_val.net_qty,0));


      -- Updating local net revenue
      UPDATE fcst_mth_status f
         SET f.local_net_revenue = ln_net_revenue
       WHERE f.member_no = c_val.member_no
         AND f.daytime = c_val.daytime;

END LOOP;


END updateFcstGPurchPrice;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updateFcstGPurchRevenue
-- Description    :  Called from the business action UpdFcstGPurchPriceBusinessAction
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE updateFcstGPurchRevenue(p_member_no NUMBER, p_daytime DATE)
--<EC-DOC>

IS

CURSOR v (cp_member_no NUMBER, cp_daytime DATE) IS

       SELECT f.net_price, f.local_spot_price, f.local_term_price, f.member_no, f.daytime
         FROM fcst_mth_status f
        WHERE f.member_no = cp_member_no
          AND f.daytime = cp_daytime;


BEGIN

FOR c_val IN v (p_member_no, p_daytime) LOOP

    NULL;

END LOOP;

END updateFcstGPurchRevenue;




--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updateFcstLiquidRevenueValues
-- Description    :  Called from the business action UpdFcstGSalesPriceBusinessAction
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE updateFcstLiquidRevenueValues(p_member_no NUMBER, p_daytime DATE)
--<EC-DOC>

IS

ln_net_revenue NUMBER;

CURSOR v (cp_member_no NUMBER, cp_daytime DATE) IS
       SELECT f.net_price,
              f.local_spot_price,
              f.local_term_price,
              f.member_no,
              f.daytime,
              f.local_net_revenue,
              f.local_gross_revenue,
              f.value_adj_price,
              f.pct_adj_price
         FROM fcst_mth_status f
        WHERE f.member_no = cp_member_no
          AND f.daytime = cp_daytime;

CURSOR v_yr (cp_member_no NUMBER, cp_daytime DATE) IS

       SELECT f.member_no,
              f.daytime,
              f.value_adj_price,
              f.local_net_revenue
         FROM fcst_yr_status f
        WHERE f.member_no = cp_member_no
          AND f.daytime = cp_daytime;

BEGIN

FOR c_val IN v (p_member_no, p_daytime) LOOP

ln_net_revenue := nvl(c_val.local_gross_revenue,0) + (nvl(c_val.local_gross_revenue,0)*nvl(c_val.pct_adj_price,0)/100) + nvl(c_val.value_adj_price,0);

    -- Updating local net revenue
    IF ln_net_revenue <> nvl(c_val.local_net_revenue,0) THEN

       UPDATE fcst_mth_status f
          SET f.local_net_revenue = ln_net_revenue
        WHERE f.member_no = c_val.member_no
          AND f.daytime = c_val.daytime;

     END IF;

END LOOP;


FOR c_val_yr IN v_yr (p_member_no, p_daytime) LOOP

   IF (nvl(c_val_yr.value_adj_price,0) <> nvl(c_val_yr.local_net_revenue,0)) THEN

      UPDATE fcst_yr_status f
          SET f.local_net_revenue = c_val_yr.value_adj_price
        WHERE f.member_no = c_val_yr.member_no
          AND f.daytime = c_val_yr.daytime;

   END IF;

END LOOP;


END updateFcstLiquidRevenueValues;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updateFcstLiquidQuantitiesValues
-- Description    :  Called from the business action UpdFcstLiquidQuantitiesBusinessAction
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE updateFcstLiquidQuantities(p_member_no NUMBER, p_daytime DATE)
--<EC-DOC>

IS

ln_net_revenue NUMBER;
ln_local_gross_revenue NUMBER;
lv2_fcst_id VARCHAR2(32);

CURSOR v (cp_member_no NUMBER, cp_daytime DATE) IS

       SELECT f.sale_qty,
              f.local_spot_price,
              f.local_gross_revenue,
              f.value_adj_price,
              f.pct_adj_price,
              f.daytime,
              f.member_no
         FROM fcst_mth_status f
        WHERE f.member_no = cp_member_no
          AND f.daytime = cp_daytime;


BEGIN

lv2_fcst_id := ec_fcst_member.object_id(p_member_no);


FOR c_val IN v (p_member_no, p_daytime) LOOP

  ln_local_gross_revenue := nvl(c_val.sale_qty,0) * nvl(c_val.local_spot_price,0);
  ln_net_revenue := ln_local_gross_revenue + (ln_local_gross_revenue*nvl(c_val.pct_adj_price,0)/100) + nvl(c_val.value_adj_price,0);

      -- Updating local gross / local net revenue
      IF ln_local_gross_revenue <> nvl(c_val.local_gross_revenue,0) THEN

         UPDATE fcst_mth_status f
            SET f.local_gross_revenue = ln_local_gross_revenue,
                f.local_net_revenue   = ln_net_revenue
          WHERE f.member_no = c_val.member_no
            AND f.daytime = c_val.daytime;

       END IF;



END LOOP;

updateFcstINQuantities(p_member_no,p_daytime);


END updateFcstLiquidQuantities;

PROCEDURE postUpdateFcstRevnQuantities(p_member_no NUMBER, p_daytime DATE)
--<EC-DOC>
IS

lv2_stream_item_id VARCHAR2(32);
lv2_forecast_id VARCHAR2(32);

CURSOR c_r_stream_items(cp_forecast_id VARCHAR2, cp_excl_si VARCHAR2) IS
SELECT
    fm.stream_item_id, fm.member_no
FROM
    fcst_member fm
WHERE
    fm.object_id = cp_forecast_id
    AND fm.stream_item_id <> cp_excl_si
;

lv2_uom VARCHAR2(32);
lv2_uom_group VARCHAR2(1);
lrec_fcst_mth_status fcst_mth_status%ROWTYPE;
lrec_stim_fcst_mth_value stim_fcst_mth_value%ROWTYPE;
ln_value NUMBER;

BEGIN
    -- find the stream item in use
    lv2_stream_item_id := ec_fcst_member.stream_item_id(p_member_no);
    lv2_forecast_id := ec_fcst_member.object_id(p_member_no);

    -- Loop through all stream items except the one being updated
    FOR CurRevnSi IN c_r_stream_items(lv2_forecast_id, lv2_stream_item_id) LOOP
        lrec_fcst_mth_status := ec_fcst_mth_status.row_by_pk(CurRevnSi.member_no, p_daytime);
        -- If QTY is NULL or last updated by cascade => No manual update then do the update
        IF ((lrec_fcst_mth_status.net_qty IS NULL OR lrec_fcst_mth_status.last_updated_by = 'INTERNAL') AND
           CurRevnSi.Stream_Item_Id IS NOT NULL) THEN
            lrec_stim_fcst_mth_value := ec_stim_fcst_mth_value.row_by_pk(CurRevnSi.Stream_Item_Id, lv2_forecast_id, p_daytime);
            lv2_uom_group := Ecdp_Unit.GetUOMGroup(lrec_fcst_mth_status.uom);

            IF (lv2_uom_group = 'M') THEN
                ln_value := lrec_stim_fcst_mth_value.net_mass_value;
                lv2_uom := lrec_stim_fcst_mth_value.mass_uom_code;
            ELSIF (lv2_uom_group = 'V') THEN
                ln_value := lrec_stim_fcst_mth_value.net_volume_value;
                lv2_uom := lrec_stim_fcst_mth_value.volume_uom_code;
            ELSIF (lv2_uom_group = 'E') THEN
                ln_value := lrec_stim_fcst_mth_value.net_energy_value;
                lv2_uom := lrec_stim_fcst_mth_value.energy_uom_code;
            END IF;

            -- Convert the value to the correct UOM
            ln_value := Ecdp_Revn_Unit.convertValue(ln_value, lv2_uom, lrec_fcst_mth_status.uom, CurRevnSi.Stream_Item_Id, p_daytime);

            -- Do the update on "dependent" stream items
            UPDATE fcst_mth_status fms
                SET fms.net_qty = ln_value, fms.last_updated_by = 'INTERNAL'
            WHERE object_id = lv2_forecast_id
                AND member_no = CurRevnSi.Member_No
                AND daytime = p_daytime;

        END IF;
    END LOOP;

END postUpdateFcstRevnQuantities;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updateFcstGSalesQuantities
-- Description    :  Called from the business action UpdFcstGSalesQuantitiesBusinessAction
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE updateFcstGSalesQuantities(p_member_no NUMBER, p_daytime DATE)
--<EC-DOC>

IS

ln_net_revenue NUMBER;
ln_local_gross_revenue NUMBER;
lv2_fcst_id VARCHAR2(32);


CURSOR v (cp_member_no NUMBER, cp_daytime DATE) IS

       SELECT f.spot_sale_qty,
              f.term_sale_qty,
              f.sale_qty,
              f.local_spot_price,
              f.local_term_price,
              f.local_gross_revenue,
              f.value_adj_price,
              f.pct_adj_price,
              f.daytime,
              f.member_no
         FROM fcst_mth_status f
        WHERE f.member_no = cp_member_no
          AND f.daytime = cp_daytime;

BEGIN

  lv2_fcst_id := ec_fcst_member.object_id(p_member_no);

  updateFcstGSSpotTermQty(p_member_no,p_daytime);

  FOR c_val IN v (p_member_no, p_daytime) LOOP

    ln_local_gross_revenue := nvl(c_val.spot_sale_qty,0) * nvl(c_val.local_spot_price,0);
    ln_local_gross_revenue := ln_local_gross_revenue + nvl(c_val.term_sale_qty,0) * nvl(c_val.local_term_price,0);

    ln_net_revenue := ln_local_gross_revenue + (ln_local_gross_revenue*nvl(c_val.pct_adj_price,0)/100) + nvl(c_val.value_adj_price,0);

    -- Updating local gross / local net revenue
    IF ln_local_gross_revenue <> nvl(c_val.local_gross_revenue,0) THEN

       UPDATE fcst_mth_status f
          SET f.local_gross_revenue = ln_local_gross_revenue,
              f.local_net_revenue   = ln_net_revenue
        WHERE f.member_no = c_val.member_no
          AND f.daytime = c_val.daytime;

    END IF;

  END LOOP;

  updateFcstINQuantities(p_member_no,p_daytime);

END updateFcstGSalesQuantities;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updateFcstGSSpotTermQty
-- Description    :  Called from updateFcstGSalesQuantities
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      : Splits Sales Qty into Term And Spot based on Split Key.
--
-------------------------------------------------------------------------------------------------
PROCEDURE updateFcstGSSpotTermQty(p_member_no NUMBER, p_daytime DATE)
--<EC-DOC>

IS

CURSOR c_splits(cp_split_key_id VARCHAR2, cp_split_member_id VARCHAR2) IS
    SELECT sks.split_share_mth
    FROM split_key_setup sks
    WHERE sks.object_id = cp_split_key_id
    AND sks.split_member_id = cp_split_member_id
    AND sks.daytime = (SELECT MAX(sks2.daytime)
                       FROM split_key_setup sks2
                       WHERE sks2.object_id = sks.object_id
                       AND sks2.split_member_id = sks.split_member_id
                       AND sks2.daytime <= p_daytime
                       AND sks2.daytime >= TRUNC(p_daytime,'yyyy'));

  lv2_split_key_id        VARCHAR(32) := NULL;
  lv2_other_split_spot_id VARCHAR(32) := NULL;
  lv2_other_split_term_id VARCHAR(32) := NULL;
  ln_split_share_spot     NUMBER := NULL;
  ln_split_share_term     NUMBER := NULL;
  no_split_shares         EXCEPTION; --??

BEGIN

    -- Get the split shares to use for this member/date
    lv2_split_key_id := ec_fcst_member.split_key_id(p_member_no);
    lv2_other_split_spot_id := ec_split_item_other.object_id_by_uk('SPOT');
    lv2_other_split_term_id := ec_split_item_other.object_id_by_uk('TERM');

    -- Get Spot Share
    FOR rsSK IN c_splits(lv2_split_key_id, lv2_other_split_spot_id) LOOP
        ln_split_share_spot := rsSK.split_share_mth;
    END LOOP;

    -- Get Term Share
    FOR rsSK IN c_splits(lv2_split_key_id, lv2_other_split_term_id) LOOP
        ln_split_share_term := rsSK.split_share_mth;
    END LOOP;

--    RAISE_APPLICATION_ERROR(-20000, 'Member: ' || p_member_no || ', daytime: ' || p_daytime || ', Split key ID: ' || lv2_split_key_id || ', split_share_spot: ' || ln_split_share_spot || ', split_share_term: ' || ln_split_share_term);

    -- If splits can not be retrieved, generate error.
    IF ln_split_share_spot IS NULL OR ln_split_share_term IS NULL THEN
       RAISE no_split_shares;
    END IF;

    -- Updating terma and spot share values
     UPDATE fcst_mth_status f
        SET f.spot_sale_qty = (f.sale_qty * ln_split_share_spot),
            f.term_sale_qty = (f.sale_qty * ln_split_share_term)
      WHERE f.member_no = p_member_no
        AND f.daytime = p_daytime;

EXCEPTION
  WHEN no_split_shares THEN
       RAISE_APPLICATION_ERROR(-20000, 'Can not calculate Term and/or Spot Quantity. No valid split shares were found on Split Key ' || ec_split_key_version.name(lv2_split_key_id, p_daytime, '<=') || ' for date ' || p_daytime);

END updateFcstGSSpotTermQty;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updateFcstGPurchQuantities
-- Description    :  Called from the business action UpdFcstGSalesQuantitiesBusinessAction
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE updateFcstGPurchQuantities(p_member_no NUMBER, p_daytime DATE)
--<EC-DOC>

IS

ln_net_revenue NUMBER;

CURSOR v (cp_member_no NUMBER, cp_daytime DATE) IS

       SELECT f.cost_price,
              f.sales_price,
              f.forex,
              f.net_qty,
              f.daytime,
              f.member_no
         FROM fcst_mth_status f
        WHERE f.member_no = cp_member_no
          AND f.daytime = cp_daytime;


BEGIN

FOR c_val IN v (p_member_no, p_daytime) LOOP

  ln_net_revenue := (nvl(c_val.cost_price,0)*nvl(c_val.forex,0)*nvl(c_val.net_qty,0)) + (nvl(c_val.sales_price,0)*nvl(c_val.forex,0)*nvl(c_val.net_qty,0));


      -- Updating local net revenue
      UPDATE fcst_mth_status f
         SET f.local_net_revenue = ln_net_revenue
       WHERE f.member_no = c_val.member_no
         AND f.daytime = c_val.daytime;

END LOOP;

END updateFcstGPurchQuantities;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  RevnFcstProductInQtyFcst
-- Description    :  Checks whether the Revenue Fcst Case member has a match in the connected Qty Fcst Case.
--                   Revenue Fcst Screens and Plan Qty column should thereby NOT be editable.
--
-- Used in        : Views: v_FCST_MTH_GSALES_MEMBER_QTY and v_FCST_MTH_LIQUID_MEMBER_QTY
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION RevnFcstProductInQtyFcst(
           p_object_id VARCHAR2, -- FORECAST
           p_product_id VARCHAR2,
           p_field_id VARCHAR2,
           p_company_id VARCHAR2,
           p_daytime DATE)
           RETURN VARCHAR2
--</EC-DOC>
IS
    lv2_ret VARCHAR2(32) := 'FALSE';
    ln_counter NUMBER;
BEGIN

 SELECT Count(*)
   INTO ln_counter
   FROM fcst_member fmb
  WHERE fmb.product_context = 'PRODUCTION'
    AND fmb.object_id = ec_forecast_version.forecast_id(p_object_id, p_daytime, '<=')
    AND fmb.product_id = p_product_id
    AND fmb.field_id = p_field_id
    AND ec_stream_item_version.company_id(fmb.stream_item_id, p_daytime, '<=') = p_company_id;

  IF (ln_counter > 0) THEN
     lv2_ret := 'TRUE';
  END IF;

  RETURN lv2_ret;

  END RevnFcstProductInQtyFcst;

----------------------------------------------------------------------------------------------------------------------------
PROCEDURE validateFcstOwner(p_forecast_owner VARCHAR2,
                            p_user VARCHAR2,
                            p_forecast_scope VARCHAR2)
IS
BEGIN
  --Raise_Application_Error(-20000, '1 '||p_forecast_owner||', 2 '|| p_user ||', 3 '|| p_forecast_scope);
     IF p_forecast_owner <> p_user AND p_forecast_scope = 'PRIVATE' THEN
        Raise_Application_Error(-20000,'It is not allowed to update other owner''s Forecast Case from Public to Private');
     END IF;
END;

----------------------------------------------------------------------------------------------------------------------------
FUNCTION getStatusRevn (
  p_object_id VARCHAR2,
  p_member_no VARCHAR2,
  p_status VARCHAR2
 )
RETURN NUMBER
IS
ln_counter NUMBER;
BEGIN

SELECT COUNT(*) INTO ln_counter
 FROM fcst_mth_status fms
WHERE fms.object_id = p_object_id
  AND fms.member_no = p_member_no
  AND record_status = p_status;

    RETURN ln_counter;
END getStatusRevn;

FUNCTION getAllStatusRevn (
  p_object_id VARCHAR2,
  p_member_no VARCHAR2
  )
RETURN VARCHAR2
IS
ln_counter NUMBER;
BEGIN

ln_counter := getStatusRevn(p_object_id,p_member_no,'P');                    -- Check for any record status with 'P'
IF ln_counter = 0 THEN                                                  -- If no record status with 'P'

   ln_counter := getStatusRevn(p_object_id,p_member_no,'V');                 ---- Check for any record status with 'V'
   IF  ln_counter = 0 THEN                                              ---- If no record status with 'V'

       ln_counter := getStatusRevn(p_object_id,p_member_no,'A');             ------ Check for any record status with 'A'
          IF  ln_counter = 0 THEN                                       ------ If no record status with 'A'
              RETURN '';                                                -------- return empty string as record status is not P, V or A
          ELSE
               RETURN ec_prosty_codes.code_text('A','DT_RECORD_STATUS');------ Return code text where code = 'A'
          END IF;
   ELSE
        RETURN ec_prosty_codes.code_text('V','DT_RECORD_STATUS');       ---- Return code text where code = 'V'
   END IF;
ELSE
   RETURN ec_prosty_codes.code_text('P','DT_RECORD_STATUS');            -- Return code text where code = 'P'
END IF;

END getAllStatusRevn;

FUNCTION getSplitKey(p_forecast_id VARCHAR2,
p_stream_item_id VARCHAR2,
p_daytime DATE)
RETURN VARCHAR2
IS

CURSOR c_spes_fcst IS
SELECT *
FROM stim_fcst_setup sfs
WHERE
   sfs.forecast_id = p_forecast_id
   AND sfs.object_id = p_stream_item_id
   AND sfs.daytime <= p_daytime
   AND NVL(sfs.end_date,p_daytime+1) >= p_daytime
;

CURSOR c_gen_fcst IS
SELECT *
FROM stim_fcst_setup sfs
WHERE
   sfs.forecast_id IS NULL
   AND sfs.object_id = p_stream_item_id
   AND sfs.daytime <= p_daytime
   AND NVL(sfs.end_date,p_daytime+1) >= p_daytime
;

lv2_return_value VARCHAR2(200) := NULL;

BEGIN
    -- Spesific Forecast Case
    FOR CurSpes IN c_spes_fcst LOOP
        lv2_return_value := CurSpes.split_key_id;
    END LOOP;

    -- General Forecast Case
    IF (lv2_return_value IS NULL) THEN
        FOR CurGen IN c_gen_fcst LOOP
            lv2_return_value := CurGen.split_key_id;
        END LOOP;
    END IF;

    -- Actual
    IF (lv2_return_value IS NULL) THEN
        lv2_return_value := ec_stream_item_version.split_key_id(p_stream_item_id, p_daytime, '<=');
    END IF;

    RETURN lv2_return_value;
END getSplitKey;

FUNCTION getStreamItemAttribute(p_forecast_id VARCHAR2,
p_stream_item_id VARCHAR2,
p_daytime DATE,
p_attribute VARCHAR2)
RETURN VARCHAR2
IS

CURSOR c_spes_fcst IS
SELECT *
FROM stim_fcst_setup sfs
WHERE
   sfs.forecast_id = p_forecast_id
   AND sfs.forecast_id IS NOT NULL
   AND sfs.object_id = p_stream_item_id
   AND sfs.daytime <= p_daytime
   AND NVL(sfs.end_date,p_daytime+1) > p_daytime
;

CURSOR c_gen_fcst IS
SELECT *
FROM stim_fcst_setup sfs
WHERE
   sfs.forecast_id IS NULL
   AND p_forecast_id IS NOT NULL
   AND sfs.object_id = p_stream_item_id
   AND sfs.daytime <= p_daytime
   AND NVL(sfs.end_date,p_daytime+1) > p_daytime
;

lv2_return_value VARCHAR2(2000) := 'NOT_FOUND';

BEGIN
    -- Spesific Forecast Case
    FOR CurSpes IN c_spes_fcst LOOP
        IF (p_attribute = 'CALC_METHOD') THEN
            lv2_return_value := CurSpes.calc_method;
        ELSIF (p_attribute = 'SET_TO_ZERO_METHOD_MTH') THEN
            lv2_return_value := CurSpes.set_to_zero_method_mth;
        ELSIF (p_attribute = 'DEFAULT_UOM_VOLUME') THEN
            lv2_return_value := CurSpes.default_uom_volume;
        ELSIF (p_attribute = 'DEFAULT_UOM_MASS') THEN
            lv2_return_value := CurSpes.default_uom_mass;
        ELSIF (p_attribute = 'DEFAULT_UOM_ENERGY') THEN
            lv2_return_value := CurSpes.default_uom_energy;
        ELSIF (p_attribute = 'DEFAULT_UOM_EXTRA1') THEN
            lv2_return_value := CurSpes.default_uom_extra1;
        ELSIF (p_attribute = 'DEFAULT_UOM_EXTRA2') THEN
            lv2_return_value := CurSpes.default_uom_extra2;
        ELSIF (p_attribute = 'DEFAULT_UOM_EXTRA3') THEN
            lv2_return_value := CurSpes.default_uom_extra3;
        ELSIF (p_attribute = 'MASTER_UOM_GROUP') THEN
            lv2_return_value := CurSpes.master_uom_group;
        ELSIF (p_attribute = 'STREAM_ITEM_FORMULA') THEN
            lv2_return_value := CurSpes.stream_item_formula;
        ELSIF (p_attribute = 'SPLIT_KEY_ID') THEN
            lv2_return_value := CurSpes.split_key_id;
        ELSIF (p_attribute = 'SPLIT_COMPANY_ID') THEN
            lv2_return_value := CurSpes.split_company_id;
        ELSIF (p_attribute = 'SPLIT_PRODUCT_ID') THEN
            lv2_return_value := CurSpes.split_product_id;
        ELSIF (p_attribute = 'SPLIT_FIELD_ID') THEN
            lv2_return_value := CurSpes.split_field_id;
        ELSIF (p_attribute = 'SPLIT_STREAM_ITEM_ID') THEN
            lv2_return_value := CurSpes.split_stream_item_id;
        ELSIF (p_attribute = 'SPLIT_ITEM_OTHER_ID') THEN
            lv2_return_value := CurSpes.split_item_other_id;
        END IF;
    END LOOP;

    -- General Forecast Case
    IF (lv2_return_value = 'NOT_FOUND') THEN
        FOR CurGen IN c_gen_fcst LOOP
            IF (p_attribute = 'CALC_METHOD') THEN
                lv2_return_value := CurGen.calc_method;
            ELSIF (p_attribute = 'SET_TO_ZERO_METHOD_MTH') THEN
            		lv2_return_value := CurGen.set_to_zero_method_mth;
            ELSIF (p_attribute = 'DEFAULT_UOM_VOLUME') THEN
                lv2_return_value := CurGen.default_uom_volume;
            ELSIF (p_attribute = 'DEFAULT_UOM_MASS') THEN
                lv2_return_value := CurGen.default_uom_mass;
            ELSIF (p_attribute = 'DEFAULT_UOM_ENERGY') THEN
                lv2_return_value := CurGen.default_uom_energy;
            ELSIF (p_attribute = 'DEFAULT_UOM_EXTRA1') THEN
                lv2_return_value := CurGen.default_uom_extra1;
            ELSIF (p_attribute = 'DEFAULT_UOM_EXTRA2') THEN
                lv2_return_value := CurGen.default_uom_extra2;
            ELSIF (p_attribute = 'DEFAULT_UOM_EXTRA3') THEN
                lv2_return_value := CurGen.default_uom_extra3;
            ELSIF (p_attribute = 'MASTER_UOM_GROUP') THEN
                lv2_return_value := CurGen.master_uom_group;
            ELSIF (p_attribute = 'STREAM_ITEM_FORMULA') THEN
                lv2_return_value := CurGen.stream_item_formula;
            ELSIF (p_attribute = 'SPLIT_KEY_ID') THEN
                lv2_return_value := CurGen.split_key_id;
            ELSIF (p_attribute = 'SPLIT_COMPANY_ID') THEN
                lv2_return_value := CurGen.split_company_id;
            ELSIF (p_attribute = 'SPLIT_PRODUCT_ID') THEN
                lv2_return_value := CurGen.split_product_id;
            ELSIF (p_attribute = 'SPLIT_FIELD_ID') THEN
                lv2_return_value := CurGen.split_field_id;
            ELSIF (p_attribute = 'SPLIT_STREAM_ITEM_ID') THEN
                lv2_return_value := CurGen.split_stream_item_id;
            ELSIF (p_attribute = 'SPLIT_ITEM_OTHER_ID') THEN
                lv2_return_value := CurGen.split_item_other_id;
            END IF;
        END LOOP;
    END IF;

    -- Actual
    IF (lv2_return_value = 'NOT_FOUND') THEN
        IF (p_attribute = 'CALC_METHOD') THEN
            lv2_return_value := ec_stream_item_version.calc_method(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'SET_TO_ZERO_METHOD_MTH') THEN
            lv2_return_value := ec_stream_item_version.SET_TO_ZERO_METHOD_MTH(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'DEFAULT_UOM_VOLUME') THEN
            lv2_return_value := ec_stream_item_version.default_uom_volume(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'DEFAULT_UOM_MASS') THEN
            lv2_return_value := ec_stream_item_version.default_uom_mass(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'DEFAULT_UOM_ENERGY') THEN
            lv2_return_value := ec_stream_item_version.default_uom_energy(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'DEFAULT_UOM_EXTRA1') THEN
            lv2_return_value := ec_stream_item_version.default_uom_extra1(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'DEFAULT_UOM_EXTRA2') THEN
            lv2_return_value := ec_stream_item_version.default_uom_extra2(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'DEFAULT_UOM_EXTRA3') THEN
            lv2_return_value := ec_stream_item_version.default_uom_extra3(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'MASTER_UOM_GROUP') THEN
            lv2_return_value := ec_stream_item_version.master_uom_group(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'STREAM_ITEM_FORMULA') THEN
            lv2_return_value := ec_stream_item_version.stream_item_formula(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'SPLIT_KEY_ID') THEN
            lv2_return_value := ec_stream_item_version.split_key_id(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'SPLIT_COMPANY_ID') THEN
            lv2_return_value := ec_stream_item_version.split_company_id(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'SPLIT_PRODUCT_ID') THEN
            lv2_return_value := ec_stream_item_version.split_product_id(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'SPLIT_FIELD_ID') THEN
            lv2_return_value := ec_stream_item_version.split_field_id(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'STREAM_ITEM_CATEGORY_ID') THEN
            lv2_return_value := ec_stream_item_version.stream_item_category_id(p_stream_item_id, p_daytime, '<=');
        ELSIF (p_attribute = 'SPLIT_ITEM_OTHER_ID') THEN
            lv2_return_value := ec_stream_item_version.split_item_other_id(p_stream_item_id, p_daytime, '<=');
        END IF;
    END IF;

    RETURN lv2_return_value;
END getStreamItemAttribute;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  GetConvValue
-- Description    :  Converts value to given unit based on numbers belonging to given group
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetConvValue (
   p_forecast_id VARCHAR2,
   p_stream_item_id VARCHAR2,  -- STREAM_ITEM object_id
   p_daytime DATE, -- Date to process for
   p_group VARCHAR2, -- M V or E
   p_to_uom VARCHAR2
) RETURN NUMBER
IS

   ln_value NUMBER;
   ln_return_value NUMBER;
   lv2_uom VARCHAR2(32);

BEGIN

    IF (p_group = 'M') THEN
        lv2_uom := ec_stim_fcst_mth_value.mass_uom_code(p_stream_item_id, p_forecast_id, p_daytime);
        ln_value := ec_stim_fcst_mth_value.net_mass_value(p_stream_item_id, p_forecast_id, p_daytime);
    ELSIF (p_group = 'V') THEN
        lv2_uom := ec_stim_fcst_mth_value.volume_uom_code(p_stream_item_id, p_forecast_id, p_daytime);
        ln_value := ec_stim_fcst_mth_value.net_volume_value(p_stream_item_id, p_forecast_id, p_daytime);
    ELSIF (p_group = 'E') THEN
        lv2_uom := ec_stim_fcst_mth_value.energy_uom_code(p_stream_item_id, p_forecast_id, p_daytime);
        ln_value := ec_stim_fcst_mth_value.net_energy_value(p_stream_item_id, p_forecast_id, p_daytime);
    END IF;

    ln_return_value := EcDp_Revn_Unit.convertValue(ln_value, lv2_uom, p_to_uom, p_stream_item_id, p_daytime);

    RETURN ln_return_value;

END GetConvValue;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  checkConversionFactorExists
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION checkConversionFactorExists(p_daytime        DATE,
                                     p_stream_item_id VARCHAR2,
                                     p_forecast_id    VARCHAR2,
                                     p_from_uom       VARCHAR2,
                                     p_to_uom         VARCHAR2,
                                     p_status         VARCHAR2)
  RETURN NUMBER
--</EC-DOC>
IS

   ln_result          NUMBER := 0;
   lv2_prod_uom_group VARCHAR2(16);
   lv2_sum_uom_group  VARCHAR2(16);

BEGIN

   lv2_prod_uom_group := ecdp_stream_item.GetUOMGroup(p_from_uom);
   lv2_sum_uom_group  := ecdp_stream_item.GetUOMGroup(p_to_uom);

   IF (lv2_prod_uom_group = lv2_sum_uom_group) THEN

     IF (getConvertedValue(p_stream_item_id
                            ,p_forecast_id
                           ,p_daytime
                           ,100
                           ,p_from_uom
                           ,p_to_uom
                           ,'PLAN')) IS NOT NULL THEN

         ln_result := 1;  --Conversion factor exists

      ELSE

         ln_result := 0;  --Conversion factor doesn't exists

      END IF;

   ELSE

      IF (getConvertedValue(p_stream_item_id, p_forecast_id,  p_daytime, 100, p_from_uom, p_to_uom, p_status)) IS NOT NULL THEN

         ln_result := 1;  --Conversion factor exists

      ELSE

         ln_result := 0;  --Conversion factor doesn't exists

      END IF;

   END IF;

   RETURN ln_result;

END checkConversionFactorExists;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  checkConversionFactorExistsSum
-- Description    :  Perform checking on all stream item's uom conversion factor existance
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION checkConversionFactorExistsSum(p_object_id VARCHAR2,
                                        p_daytime   DATE,
                                        p_field_id  VARCHAR2,
                                        p_company_id VARCHAR2,
                                        p_product_context VARCHAR2
                                        )

RETURN NUMBER
--</EC-DOC>
IS

   ln_convFact NUMBER;
   ln_result NUMBER;

CURSOR c_sum(cp_object_id VARCHAR2, cp_field_id VARCHAR2, cp_company_id VARCHAR2, cp_product_context VARCHAR2) IS
SELECT fms.daytime as fms_daytime,
       fms.net_qty,
       fms.uom,
       fms.status,
       fv.object_id,
       fv.daytime as fv_daytime,
       fv.populate_method,
       fv.product_sum_uom,
       fm.field_id,
       fm.product_id,
       fm.stream_item_id
  FROM fcst_member fm, fcst_mth_status fms, forecast_version fv
 WHERE fms.object_id = fm.object_id
   AND fv.object_id = fms.object_id
   AND fm.member_no = fms.member_no
   AND fm.field_id = p_field_id -- filter by field
   AND fms.object_id = p_object_id -- filter by forecast case
   AND fms.daytime = p_daytime
   --AND fm.product_context = p_product_context
   AND p_company_id =
       (SELECT company_id
          FROM stream_item_version
         WHERE object_id = fm.stream_item_id
           AND field_id = p_field_id
           AND daytime = (SELECT MAX (daytime)
                            FROM stream_item_version
                           WHERE object_id = fm.stream_item_id
                             AND daytime <= p_daytime
                             AND field_id = p_field_id));

BEGIN

   FOR cur_sum IN c_sum(p_object_id, p_field_id, p_company_id, p_product_context) LOOP

     ln_convFact := checkConversionFactorExists(cur_sum.fms_daytime, cur_sum.stream_item_id, p_object_id,cur_sum.uom, cur_sum.product_sum_uom, cur_sum.status);

     IF (ln_convFact = 0) THEN
        ln_result := 0;
        RETURN ln_result; --exit from loop directly
     END IF;

   END LOOP;

   IF (ln_result = 0) THEN
      ln_result := 0;
   ELSE
       ln_result := 1;
   END IF;

   RETURN ln_result;

END checkConversionFactorExistsSum;

---------------------------------------------------------------------------
--  FUNCTION GetSplitShareMth
--
---------------------------------------------------------------------------
FUNCTION GetSplitShareMth(
   p_forecast_id VARCHAR2,
   p_object_id VARCHAR2,
   p_daytime   DATE
) RETURN NUMBER

IS

ln_share NUMBER;

CURSOR c_split(cp_object_id VARCHAR2, cp_member_id VARCHAR2) IS
SELECT t.object_id object_id, t.split_share_mth split_share_mth FROM
split_key_setup t WHERE
t.object_id = cp_object_id
AND t.split_member_id = cp_member_id
AND t.daytime = (SELECT MAX(daytime) FROM
    split_key_setup t WHERE
    t.object_id = cp_object_id
    AND t.split_member_id = cp_member_id
    AND t.daytime <= p_daytime)
;

lv2_split_key VARCHAR2(32) := NULL;
lv2_sk_type VARCHAR2(32);
lv2_member_id VARCHAR2(32);

BEGIN

    lv2_split_key := getStreamItemAttribute(p_forecast_id, p_object_id, p_daytime, 'SPLIT_KEY_ID');

    lv2_sk_type := ec_split_key_version.split_type(lv2_split_key, p_daytime, '<=');

    IF (lv2_sk_type = 'COMPANY') THEN
        lv2_member_id := getStreamItemAttribute(p_forecast_id, p_object_id, p_daytime, 'SPLIT_COMPANY_ID');
    ELSIF (lv2_sk_type = 'PRODUCT') THEN
        lv2_member_id := getStreamItemAttribute(p_forecast_id, p_object_id, p_daytime, 'SPLIT_PRODUCT_ID');
    ELSIF (lv2_sk_type = 'FIELD') THEN
        lv2_member_id := getStreamItemAttribute(p_forecast_id, p_object_id, p_daytime, 'SPLIT_FIELD_ID');
    ELSIF (lv2_sk_type = 'STREAM_ITEM_CAT') THEN
        lv2_member_id := getStreamItemAttribute(p_forecast_id, p_object_id, p_daytime, 'STREAM_ITEM_CATEGORY_ID');
    ELSIF (lv2_sk_type = 'STREAM_ITEM') THEN
        lv2_member_id := getStreamItemAttribute(p_forecast_id, p_object_id, p_daytime, 'SPLIT_STREAM_ITEM_ID');
    ELSIF (lv2_sk_type = 'SPLIT_ITEM_OTHER') THEN
        lv2_member_id := getStreamItemAttribute(p_forecast_id, p_object_id, p_daytime, 'SPLIT_ITEM_OTHER_ID');
    END IF;

    FOR rSplit IN c_split(lv2_split_key, lv2_member_id) LOOP
        ln_share := rSplit.Split_Share_Mth;
    END LOOP;

    RETURN ln_share;

END GetSplitShareMth;

FUNCTION getCascadeRows(
   p_forecast_id VARCHAR2,
   p_object_id VARCHAR2,
   p_daytime   DATE
) RETURN t_object_rows PIPELINED
IS

CURSOR c_stream_items(cp_forecast_id VARCHAR2, cp_stream_item_id VARCHAR2, cp_daytime DATE) IS
SELECT
    'NA' calc_type,
    rownum execution_order,
    smv.object_id,
    si.object_code CODE,
    getStreamItemAttribute(cp_forecast_id, cp_stream_item_id, cp_daytime, 'STREAM_ITEM_FORMULA') Equation,
    nvl(smv.calc_method,ecdp_revn_forecast.getStreamItemAttribute(smv.forecast_id,smv.object_id,smv.daytime,'CALC_METHOD')) calc_method,
    smv.MASTER_UOM_GROUP Measure,
    smv.net_mass_value NetMass,
    smv.mass_uom_code NetMassUnit,
    smv.net_volume_value NetVolume,
    smv.volume_uom_code NetVolumeUnit,
    smv.net_energy_value NetEnergy,
    smv.energy_uom_code NetEnergyUnit,
    smv.net_extra1_value NetExtra1,
    smv.extra1_uom_code Extra1Unit,
    smv.net_extra2_value NetExtra2,
    smv.extra2_uom_code Extra2Unit,
    smv.net_extra3_value NetExtra3,
    smv.extra3_uom_code Extra3Unit,
    ec_stream_item_version.conversion_method(smv.object_id,smv.daytime,'<=') conversion_method,
    decode(nvl(smv.calc_method,ecdp_revn_forecast.getStreamItemAttribute(smv.forecast_id,smv.object_id,smv.daytime,'CALC_METHOD')),'SK',ecdp_revn_forecast.GetSplitShareMth(smv.forecast_id, smv.object_id, smv.daytime),smv.split_share) SplitShare,
    smv.daytime daytime,
    smv.status status,
    smv.record_status record_status,
    ec_split_key_version.split_type(EcDp_Revn_Forecast.getSplitKey(p_forecast_id, smv.object_id, smv.daytime), smv.daytime, '<=') split_type,
    ecdp_stream_item.getConversionFactorValue(smv.object_id, smv.density_source_id,smv.daytime, 'DENSITY', smv.density) density,
    decode(smv.density_source_id,null,smv.density_mass_uom,ecdp_stream_item.getConversionFactorUOM(smv.object_id, smv.density_source_id,smv.daytime, 'DENSITY', smv.density, 'TO_UOM'))  density_mass_uom,
    decode(smv.density_source_id,null,smv.density_volume_uom,ecdp_stream_item.getConversionFactorUOM(smv.object_id, smv.density_source_id,smv.daytime, 'DENSITY', smv.density, 'FROM_UOM')) density_volume_uom,
    ecdp_stream_item.getConversionFactorValue(smv.object_id, smv.gcv_source_id,smv.daytime, 'GCV', smv.gcv) gcv,
    decode(smv.gcv_source_id,null,smv.gcv_energy_uom,ecdp_stream_item.getConversionFactorUOM(smv.object_id, smv.gcv_source_id,smv.daytime, 'GCV', smv.gcv, 'TO_UOM'))  gcv_energy_uom,
    decode(smv.gcv_source_id,null,smv.gcv_volume_uom,ecdp_stream_item.getConversionFactorUOM(smv.object_id, smv.gcv_source_id,smv.daytime, 'GCV', smv.gcv, 'FROM_UOM')) gcv_volume_uom,
    ecdp_stream_item.getConversionFactorValue(smv.object_id, smv.mcv_source_id,smv.daytime, 'MCV', smv.mcv) mcv,
    decode(smv.mcv_source_id,null,smv.mcv_energy_uom,ecdp_stream_item.getConversionFactorUOM(smv.object_id, smv.mcv_source_id,smv.daytime, 'MCV', smv.mcv, 'TO_UOM'))  mcv_energy_uom,
    decode(smv.mcv_source_id,null,smv.mcv_mass_uom,ecdp_stream_item.getConversionFactorUOM(smv.object_id, smv.mcv_source_id,smv.daytime, 'MCV', smv.mcv, 'FROM_UOM')) mcv_mass_uom,
    decode(smv.boe_source_id,null,smv.boe_from_uom_code,ecdp_stream_item.getConversionFactorUOM(smv.object_id, smv.boe_source_id,smv.daytime, 'BOE', smv.boe_factor, 'FROM_UOM'))  boe_from_uom_code,
    decode(smv.boe_source_id,null,smv.boe_to_uom_code,ecdp_stream_item.getConversionFactorUOM(smv.object_id, smv.boe_source_id,smv.daytime, 'BOE', smv.boe_factor, 'TO_UOM')) boe_to_uom_code,
    ecdp_stream_item.getConversionFactorValue(smv.object_id, smv.boe_source_id,smv.daytime, 'BOE', smv.boe_factor) boe_factor,
    smv.density_source_id,
    smv.gcv_source_id,
    smv.mcv_source_id,
    smv.boe_source_id
FROM
    stim_fcst_mth_value smv
    ,stream_item si
WHERE
    smv.forecast_id = p_forecast_id
    AND smv.object_id = cp_stream_item_id
    AND smv.object_id = si.object_id
    AND smv.daytime = cp_daytime;

    lrec_cascade t_cascade_rec;
    ltab_objects t_object_tab := t_object_tab();

BEGIN
    ltab_objects.extend;
    ltab_objects(ltab_objects.last).object_id := p_object_id;
    ltab_objects(ltab_objects.last).object_type := 'WRITE';

    getCascadeIds(ltab_objects,
                  p_forecast_id,
                  p_object_id,
                  p_daytime);

    FOR i IN 1..ltab_objects.count LOOP
        FOR curSis IN c_stream_items(p_forecast_id, ltab_objects(i).object_id, p_daytime) LOOP
            lrec_cascade.calc_type := ltab_objects(i).object_type;
            lrec_cascade.execution_order := i;
            lrec_cascade.object_id := curSis.Object_Id;
            lrec_cascade.CODE := curSis.Code;
            lrec_cascade.Equation := curSis.Equation;
            lrec_cascade.calc_method := curSis.Calc_Method;
            lrec_cascade.Measure := curSis.Measure;
            lrec_cascade.NetMass := curSis.Netmass;
            lrec_cascade.NetMassUnit := curSis.Netmassunit;
            lrec_cascade.NetVolume := curSis.Netvolume;
            lrec_cascade.NetVolumeUnit := curSis.Netvolumeunit;
            lrec_cascade.NetEnergy := curSis.Netenergy;
            lrec_cascade.NetEnergyUnit := curSis.Netenergyunit;
            lrec_cascade.NetExtra1 := curSis.Netextra1;
            lrec_cascade.Extra1Unit := curSis.Extra1unit;
            lrec_cascade.NetExtra2 := curSis.Netextra2;
            lrec_cascade.Extra2Unit := curSis.Extra2unit;
            lrec_cascade.NetExtra3 := curSis.Netextra3;
            lrec_cascade.Extra3Unit := curSis.Extra3unit;
            lrec_cascade.conversion_method := curSis.Conversion_Method;
            lrec_cascade.SplitShare := curSis.Splitshare;
            lrec_cascade.daytime := curSis.Daytime;
            lrec_cascade.status := curSis.Status;
            lrec_cascade.record_status := curSis.Record_Status;
            lrec_cascade.split_type := curSis.Split_Type;
            lrec_cascade.density := curSis.density;
            lrec_cascade.densityMassUnit := curSis.density_mass_uom;
            lrec_cascade.densityVolumeUnit := curSis.density_volume_uom;
            lrec_cascade.gcv := curSis.gcv;
            lrec_cascade.gcvEnergyUnit := curSis.gcv_energy_uom;
            lrec_cascade.gcvVolumeUnit := curSis.gcv_volume_uom;
            lrec_cascade.mcv := curSis.mcv;
            lrec_cascade.mcvEnergyUnit := curSis.mcv_energy_uom;
            lrec_cascade.mcvMassUnit := curSis.mcv_mass_uom;
            lrec_cascade.boeFromUnit := curSis.Boe_From_Uom_Code;
            lrec_cascade.boeUnit := curSis.Boe_To_Uom_Code;
            lrec_cascade.boeFactor := curSis.Boe_Factor;




            PIPE ROW ( lrec_cascade );
        END LOOP;
    END LOOP;

    RETURN;

END getCascadeRows;


PROCEDURE getCascadeIds (
   p_object_tab IN OUT t_object_tab,
   p_forecast_id VARCHAR2,
   p_object_id VARCHAR2,
   p_daytime   DATE
)
IS

CURSOR c_cascade(cp_stream_item_id VARCHAR2, cp_forecast_id VARCHAR2, cp_daytime DATE) IS
  -- Formula from Actual config
SELECT sif.object_id
  FROM stream_item_formula sif
 WHERE NOT EXISTS
       (SELECT 1
          FROM stim_fcst_setup sfs
         WHERE sfs.object_id = sif.object_id
           AND sfs.daytime <= sif.daytime
           AND nvl(sfs.end_date, sif.daytime + 1) > sif.daytime)
   AND sif.stream_item_id = cp_stream_item_id
   AND sif.daytime = (SELECT MAX(daytime)
                        FROM stream_item_formula
                       WHERE object_id = sif.object_id
                         AND stream_item_id = sif.stream_item_id
                         AND daytime <= cp_daytime)
UNION ALL
-- Formula from General Fcst config
SELECT sff_gen.object_id
  FROM stim_fcst_formula sff_gen
 WHERE sff_gen.forecast_id = 'GENERAL_FCST_FORMULA'
   AND NOT EXISTS
 (SELECT 1
          FROM stim_fcst_setup sfs_gen
         WHERE sfs_gen.forecast_id = sff_gen.forecast_id
           AND sfs_gen.object_id = sff_gen.object_id
           AND sfs_gen.daytime <= sff_gen.daytime
           AND nvl(sfs_gen.end_date, sff_gen.daytime + 1) > sff_gen.daytime)
   AND sff_gen.stream_item_id = cp_stream_item_id
   AND sff_gen.daytime = (SELECT MAX(daytime)
                         FROM stim_fcst_formula
                        WHERE object_id = sff_gen.object_id
                          AND stream_item_id = sff_gen.stream_item_id
                          AND forecast_id = sff_gen.forecast_id -- 'GENERAL_FCST_FORMULA'
                          AND daytime <= cp_daytime)
UNION ALL
-- Formula from Specific Fcst config
SELECT sff_spec.object_id
  FROM stim_fcst_formula sff_spec
 WHERE sff_spec.forecast_id = cp_forecast_id
   AND sff_spec.stream_item_id = cp_stream_item_id
   AND sff_spec.daytime = (SELECT MAX(daytime)
                         FROM stim_fcst_formula sff_sub
                        WHERE sff_sub.object_id = sff_spec.object_id
                          AND sff_sub.stream_item_id = sff_spec.stream_item_id
                          AND sff_sub.forecast_id = sff_spec.forecast_id
                          AND sff_sub.daytime <= cp_daytime)
;


CURSOR c_read(cp_stream_item_id VARCHAR2, cp_forecast_id VARCHAR2, cp_daytime DATE) IS
  -- Actual
  SELECT actual.stream_item_id
  FROM stream_item_formula actual
  WHERE NOT EXISTS (SELECT 1
                    FROM stim_fcst_setup sfs
                    WHERE sfs.object_id = actual.object_id
                    AND   sfs.daytime <= actual.daytime
                    AND   nvl(sfs.end_date,actual.daytime+1) > actual.daytime)
  AND actual.object_id = cp_stream_item_id
  AND actual.daytime = (SELECT MAX(daytime)
                         FROM stream_item_formula
                        WHERE object_id = actual.object_id
                          AND stream_item_id = actual.stream_item_id
                          AND daytime <= cp_daytime)
UNION ALL
 -- General
 SELECT sff_gen.stream_item_id
  FROM stim_fcst_formula sff_gen
  WHERE sff_gen.forecast_id = 'GENERAL_FCST_FORMULA'
  AND NOT EXISTS (SELECT 1
                  FROM stim_fcst_setup sfs_gen
                  WHERE sfs_gen.forecast_id = cp_forecast_id
                  AND sfs_gen.object_id = sff_gen.object_id
                  AND sfs_gen.daytime <= sff_gen.daytime
                  AND nvl(sfs_gen.end_date, sff_gen.daytime + 1) > sff_gen.daytime)
  AND sff_gen.object_id = cp_stream_item_id
  AND sff_gen.daytime = (SELECT MAX(daytime)
                         FROM stim_fcst_formula
                        WHERE object_id = sff_gen.object_id
                          AND stream_item_id = sff_gen.stream_item_id
                          AND forecast_id = sff_gen.forecast_id -- 'GENERAL_FCST_FORMULA'
                          AND daytime <= cp_daytime)
UNION ALL
  -- Specific
  SELECT sff_spec.stream_item_id
  FROM stim_fcst_formula sff_spec
  WHERE sff_spec.forecast_id = cp_forecast_id
  AND sff_spec.object_id = cp_stream_item_id
  AND sff_spec.daytime = (SELECT MAX(daytime)
                         FROM stim_fcst_formula sff_sub
                        WHERE sff_sub.object_id = sff_spec.object_id
                          AND sff_sub.stream_item_id = sff_spec.stream_item_id
                          AND sff_sub.forecast_id = sff_spec.forecast_id
                          AND sff_sub.daytime <= cp_daytime)
;

lb_found BOOLEAN := FALSE;
lb_in_list BOOLEAN := FALSE;


BEGIN

    -- Read
    FOR curReadObjs IN c_read(p_object_id, p_forecast_id, p_daytime) LOOP

        FOR i IN 1..p_object_tab.count LOOP
            IF (p_object_tab(i).object_id = curReadObjs.stream_item_id) THEN
                lb_found := TRUE;
            END IF;
        END LOOP;

        IF (NOT lb_found) THEN
            p_object_tab.extend;
            p_object_tab(p_object_tab.last).object_id := curReadObjs.stream_item_id;
            p_object_tab(p_object_tab.last).object_type := 'READ';
        END IF;

        lb_found := FALSE;
    END LOOP;

    -- Write
    FOR curObjs IN c_cascade(p_object_id, p_forecast_id, p_daytime) LOOP
        lb_in_list := FALSE;

        FOR i IN 1..p_object_tab.count LOOP
            IF (p_object_tab(i).object_id = curObjs.object_id) THEN
                IF (p_object_tab(i).object_type = 'READ') THEN
                    p_object_tab(i).object_type := 'WRITE';
                    lb_in_list := TRUE;
                END IF;
                lb_found := TRUE;
            END IF;
        END LOOP;

        IF (NOT lb_found ) THEN
            p_object_tab.extend;
            p_object_tab(p_object_tab.last).object_id := curObjs.object_id;
            p_object_tab(p_object_tab.last).object_type := 'WRITE';

            getCascadeIds(p_object_tab,
                          p_forecast_id,
                          curObjs.object_id,
                          p_daytime);

        ELSIF (lb_in_list) THEN

                    getCascadeIds(p_object_tab,
                          p_forecast_id,
                          curObjs.object_id,
                          p_daytime);

        END IF;

        lb_found := FALSE;
        lb_in_list := FALSE;
    END LOOP;


END getCascadeIds;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getInventoryClosingPos
-- Description    :  Preparing a recordset of a certain set of inventory numbers to be used during a revenue forecast case.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getInventoryClosingPos(
   p_forecast_id VARCHAR2,
   p_member_no VARCHAR2,
   p_uom VARCHAR2,
   p_daytime   DATE
) RETURN t_fcst_inv_rec
IS
--</EC-DOC>
CURSOR c_members (cp_forecast_id VARCHAR2, cp_member_no VARCHAR2) IS
SELECT fm.inventory1_id,
       fm.inventory2_id,
       fm.inventory3_id,
       fm.inventory4_id,
       fm.inventory5_id,
       fm.field_id
  FROM fcst_member fm
 WHERE fm.object_id = cp_forecast_id
   AND fm.member_no = cp_member_no;

CURSOR c_inv_pos (cp_inventory_id VARCHAR2, cp_daytime DATE, cp_dist_id VARCHAR2) IS
SELECT NVL(idv.opening_ul_position_qty1, 0) +
       NVL(idv.opening_ol_position_qty1, 0) +
       NVL(idv.opening_ps_position_qty1, 0) opening_pos,
       NVL(idv.closing_ul_position_qty1, 0) +
       NVL(idv.closing_ol_position_qty1, 0) closing_pos,
       idv.uom1_code,
       NVL(idv.ul_booking_value, 0) + NVL(idv.ol_booking_value, 0) +
       NVL(idv.ps_booking_value, 0) closing_value
  FROM inv_valuation iv, inv_dist_valuation idv
 WHERE idv.object_id = cp_inventory_id
   AND idv.daytime = cp_daytime
   AND idv.dist_id = cp_dist_id
   AND iv.object_id = idv.object_id
   AND iv.daytime = idv.daytime
   AND iv.document_level_code = 'BOOKED';

CURSOR c_invFieldSI (cp_inventory_id VARCHAR2, cp_daytime DATE, cp_dist_id VARCHAR2) IS
SELECT iss.stream_item_id
  FROM inventory_stim_setup iss
 WHERE iss.object_id = cp_inventory_id
   AND iss.daytime <= cp_daytime
   and iss.inv_stream_item_type = 'INV'
   AND ec_stream_item_version.field_id(iss.stream_item_id, cp_daytime, '<=') =
       cp_dist_id;


lrec_inv t_fcst_inv_rec := null;
lv2_inv_curr inventory_version.ul_booking_currency_id%TYPE;
lv2_local_currency company_version.local_currency_id%TYPE;
lv2_inv_position VARCHAR2(32);
lv2_fx_source_id forecast_version.forex_source_id%TYPE;


BEGIN

-- Local currency picked from forecast case company
lv2_local_currency := ec_company_version.local_currency_id(ec_forecast_version.company_id(p_forecast_id,p_daytime,'<='),p_daytime,'<=');
lv2_fx_source_id := ec_forecast_version.forex_source_id(p_forecast_id,p_daytime,'<=');


    FOR curMembers IN c_members (p_forecast_id, p_member_no) LOOP
        -- Inv 1
        FOR curInv1 IN c_inv_pos (curMembers.Inventory1_Id, p_daytime, curMembers.Field_Id) LOOP

            FOR curInvField1 IN c_invFieldSI (curMembers.Inventory1_Id, p_daytime, curMembers.Field_Id) LOOP
              lrec_inv.opening_pos_qty := getConvertedValue(curInvField1.Stream_Item_Id,p_forecast_id, p_daytime, curInv1.opening_pos, curInv1.Uom1_Code, p_uom, 'FINAL');
              lrec_inv.closing_pos_qty := getConvertedValue(curInvField1.Stream_Item_Id, p_forecast_id,p_daytime, curInv1.closing_pos, curInv1.Uom1_Code, p_uom, 'FINAL');
            END LOOP;

            -- EVALUATION FOR CURRENCY CONVERSION

            -- Current inventory position
            lv2_inv_position := ecdp_inventory.isinunderlift(curMembers.Inventory1_Id,p_daytime);

            -- Current position is underlift
            IF lv2_inv_position = 'TRUE' THEN

               -- Pick underlift booking currency
               lv2_inv_curr := ec_inventory_version.ul_booking_currency_id(curMembers.Inventory1_Id,p_daytime,'<=');

            ELSE
               -- Pick overlift booking currency
               lv2_inv_curr := ec_inventory_version.ol_booking_currency_id(curMembers.Inventory1_Id,p_daytime,'<=');

            END IF;

               -- convert value
               lrec_inv.closing_value := ecdp_currency.convertviacurrency(curInv1.closing_value,lv2_inv_curr,lv2_local_currency,NULL,p_daytime,lv2_fx_source_id);


        END LOOP;
        -- Inv 2
        FOR curInv2 IN c_inv_pos (curMembers.Inventory2_Id, p_daytime, curMembers.Field_Id) LOOP

            FOR curInvField2 IN c_invFieldSI (curMembers.Inventory2_Id, p_daytime, curMembers.Field_Id) LOOP
              lrec_inv.opening_pos_qty := lrec_inv.opening_pos_qty +
                                          getConvertedValue(curInvField2.Stream_Item_Id,p_forecast_id, p_daytime, curInv2.opening_pos, curInv2.Uom1_Code, p_uom, 'FINAL');
              lrec_inv.closing_pos_qty := lrec_inv.closing_pos_qty +
                                          getConvertedValue(curInvField2.Stream_Item_Id, p_forecast_id,p_daytime, curInv2.closing_pos, curInv2.Uom1_Code, p_uom, 'FINAL');
            END LOOP;

         -- EVALUATION FOR CURRENCY CONVERSION

            -- Current inventory position
            lv2_inv_position := ecdp_inventory.isinunderlift(curMembers.Inventory2_Id,p_daytime);

            -- Current position is underlift
            IF lv2_inv_position = 'TRUE' THEN

               -- Pick underlift booking currency
               lv2_inv_curr := ec_inventory_version.ul_booking_currency_id(curMembers.Inventory2_Id,p_daytime,'<=');

            ELSE
               -- Pick overlift booking currency
               lv2_inv_curr := ec_inventory_version.ol_booking_currency_id(curMembers.Inventory2_Id,p_daytime,'<=');

            END IF;

               -- convert value
               lrec_inv.closing_value := nvl(lrec_inv.closing_value,0) + nvl(ecdp_currency.convertviacurrency(curInv2.closing_value,lv2_inv_curr,lv2_local_currency,NULL,p_daytime,lv2_fx_source_id),0);


        END LOOP;

        -- Inv 3
        FOR curInv3 IN c_inv_pos (curMembers.Inventory3_Id, p_daytime, curMembers.Field_Id) LOOP

            FOR curInvField3 IN c_invFieldSI (curMembers.Inventory3_Id, p_daytime, curMembers.Field_Id) LOOP
              lrec_inv.opening_pos_qty := lrec_inv.opening_pos_qty +
                                          getConvertedValue(curInvField3.Stream_Item_Id, p_forecast_id,p_daytime, curInv3.opening_pos, curInv3.Uom1_Code, p_uom, 'FINAL');
              lrec_inv.closing_pos_qty := lrec_inv.closing_pos_qty +
                                          getConvertedValue(curInvField3.Stream_Item_Id, p_forecast_id,p_daytime, curInv3.closing_pos, curInv3.Uom1_Code, p_uom, 'FINAL');
            END LOOP;
            -- EVALUATION FOR CURRENCY CONVERSION

            -- Current inventory position
            lv2_inv_position := ecdp_inventory.isinunderlift(curMembers.Inventory3_Id,p_daytime);

            -- Current position is underlift
            IF lv2_inv_position = 'TRUE' THEN

               -- Pick underlift booking currency
               lv2_inv_curr := ec_inventory_version.ul_booking_currency_id(curMembers.Inventory3_Id,p_daytime,'<=');

            ELSE
               -- Pick overlift booking currency
               lv2_inv_curr := ec_inventory_version.ol_booking_currency_id(curMembers.Inventory3_Id,p_daytime,'<=');

            END IF;

               -- convert value
               lrec_inv.closing_value := nvl(lrec_inv.closing_value,0) + nvl(ecdp_currency.convertviacurrency(curInv3.closing_value,lv2_inv_curr,lv2_local_currency,NULL,p_daytime,lv2_fx_source_id),0);

        END LOOP;
        -- Inv 4
        FOR curInv4 IN c_inv_pos (curMembers.Inventory4_Id, p_daytime, curMembers.Field_Id) LOOP

            FOR curInvField4 IN c_invFieldSI (curMembers.Inventory4_Id, p_daytime, curMembers.Field_Id) LOOP
              lrec_inv.opening_pos_qty := lrec_inv.opening_pos_qty +
                                          getConvertedValue(curInvField4.Stream_Item_Id, p_forecast_id,p_daytime, curInv4.opening_pos, curInv4.Uom1_Code, p_uom, 'FINAL');
              lrec_inv.closing_pos_qty := lrec_inv.closing_pos_qty +
                                          getConvertedValue(curInvField4.Stream_Item_Id, p_forecast_id,p_daytime, curInv4.closing_pos, curInv4.Uom1_Code, p_uom, 'FINAL');
            END LOOP;


            -- EVALUATION FOR CURRENCY CONVERSION

            -- Current inventory position
            lv2_inv_position := ecdp_inventory.isinunderlift(curMembers.Inventory4_Id,p_daytime);

            -- Current position is underlift
            IF lv2_inv_position = 'TRUE' THEN

               -- Pick underlift booking currency
               lv2_inv_curr := ec_inventory_version.ul_booking_currency_id(curMembers.Inventory4_Id,p_daytime,'<=');

            ELSE
               -- Pick overlift booking currency
               lv2_inv_curr := ec_inventory_version.ol_booking_currency_id(curMembers.Inventory4_Id,p_daytime,'<=');

            END IF;

               -- convert value
               lrec_inv.closing_value := nvl(lrec_inv.closing_value,0) + nvl(ecdp_currency.convertviacurrency(curInv4.closing_value,lv2_inv_curr,lv2_local_currency,NULL,p_daytime,lv2_fx_source_id),0);
        END LOOP;
        -- Inv 5
        FOR curInv5 IN c_inv_pos (curMembers.Inventory5_Id, p_daytime, curMembers.Field_Id) LOOP

            FOR curInvField5 IN c_invFieldSI (curMembers.Inventory5_Id, p_daytime, curMembers.Field_Id) LOOP
              lrec_inv.opening_pos_qty := lrec_inv.opening_pos_qty +
                                          getConvertedValue(curInvField5.Stream_Item_Id, p_forecast_id,p_daytime, curInv5.opening_pos, curInv5.Uom1_Code, p_uom, 'FINAL');
              lrec_inv.closing_pos_qty := lrec_inv.closing_pos_qty +
                                          getConvertedValue(curInvField5.Stream_Item_Id, p_forecast_id,p_daytime, curInv5.closing_pos, curInv5.Uom1_Code, p_uom, 'FINAL');
            END LOOP;

            -- EVALUATION FOR CURRENCY CONVERSION

            -- Current inventory position
            lv2_inv_position := ecdp_inventory.isinunderlift(curMembers.Inventory5_Id,p_daytime);

            -- Current position is underlift
            IF lv2_inv_position = 'TRUE' THEN

               -- Pick underlift booking currency
               lv2_inv_curr := ec_inventory_version.ul_booking_currency_id(curMembers.Inventory5_Id,p_daytime,'<=');

            ELSE
               -- Pick overlift booking currency
               lv2_inv_curr := ec_inventory_version.ol_booking_currency_id(curMembers.Inventory5_Id,p_daytime,'<=');

            END IF;

               -- convert value
               lrec_inv.closing_value := nvl(lrec_inv.closing_value,0) + nvl(ecdp_currency.convertviacurrency(curInv5.closing_value,lv2_inv_curr,lv2_local_currency,NULL,p_daytime,lv2_fx_source_id),0);

        END LOOP;

    END LOOP;

    lrec_inv.qty_uom := p_uom;

    IF (lrec_inv.closing_pos_qty <> 0) THEN
        lrec_inv.rate := lrec_inv.closing_value / lrec_inv.closing_pos_qty;
    ELSE
        lrec_inv.rate := 0;
    END IF;

    RETURN lrec_inv;

END getInventoryClosingPos;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  getInventoryMovement
-- Description    :  Return sum of all numbers that are required to get the inventory movement
--
-- Preconditions  :  This function should only be used for PLAN numbers as the inventory movement for actual numbers
--                   are retrieved from the inventory itself.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getInventoryMovement(p_member_no NUMBER, p_daytime DATE, p_prod_coll_type VARCHAR2)
RETURN NUMBER
--</EC-DOC>

IS

ln_inv_movement NUMBER;

CURSOR c_fms IS
SELECT nvl(fms.net_qty, 0) +
       nvl(fms.commercial_adj_qty, 0) +
       nvl(fms.swap_adj_qty, 0) -
       nvl(fms.sale_qty, 0) inv_movement
  FROM fcst_mth_status fms
 WHERE fms.member_no = p_member_no
   AND fms.daytime = p_daytime;

BEGIN

IF (p_prod_coll_type IN ('GAS_SALES','LIQUID')) THEN
  FOR cVGS IN c_fms LOOP
      ln_inv_movement := cVGS.inv_movement;
  END LOOP;
END IF;

RETURN ln_inv_movement;

END getInventoryMovement;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updateFcstINQuantities
-- Description    :  After the updateFcstGSalesQuantities or updateFcstLiquidQuantities has been runned, this one will be runned to
--                   update all the inventory related quantities.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE updateFcstINQuantities(p_member_no NUMBER, p_daytime DATE)
--<EC-DOC>


IS

CURSOR v (cp_member_no NUMBER, cp_daytime DATE) IS
  SELECT f.*
    FROM fcst_mth_status f
   WHERE f.member_no = cp_member_no
     AND f.daytime > cp_daytime
     ORDER BY f.daytime ASC;



lrec_fms                fcst_mth_status%ROWTYPE;

BEGIN



lrec_fms := ec_fcst_mth_status.row_by_pk(p_member_no,p_daytime);


-- Updating closing position qty on current record
UPDATE fcst_mth_status fmsc
   SET fmsc.inv_closing_pos_qty = (NVL(lrec_fms.net_qty, 0) +
                                  NVL(lrec_fms.commercial_adj_qty, 0) +
                                  NVL(lrec_fms.swap_adj_qty, 0) -
                                  NVL(lrec_fms.sale_qty,0) +
                                  nvl(lrec_fms.inv_opening_pos_qty, 0))
 WHERE fmsc.member_no = p_member_no
   AND fmsc.daytime = p_daytime;

-- Refreshing source variable
lrec_fms := ec_fcst_mth_status.row_by_pk(p_member_no,p_daytime);

-- Updating closing value on current record
 UPDATE fcst_mth_status fmsc2
    SET fmsc2.inv_closing_value = nvl(lrec_fms.inv_closing_pos_qty, 0) *
                                  nvl(lrec_fms.inv_rate, 0)
  WHERE fmsc2.member_no = lrec_fms.member_no
    AND fmsc2.daytime = lrec_fms.daytime;

-- Refreshing source variable
lrec_fms := ec_fcst_mth_status.row_by_pk(p_member_no,p_daytime);



   -- Looping through the rest of the records starting from daytime on edited record + 1
   FOR cv IN v(p_member_no, p_daytime) LOOP

       UPDATE fcst_mth_status fms
          SET fms.inv_opening_pos_qty = lrec_fms.inv_closing_pos_qty,
              fms.inv_closing_pos_qty = (NVL(fms.net_qty, 0) +
                                        NVL(fms.commercial_adj_qty, 0) +
                                        NVL(fms.swap_adj_qty, 0) -
                                        NVL(fms.sale_qty, 0)) +
                                        nvl(lrec_fms.inv_closing_pos_qty, 0)
        WHERE fms.member_no = cv.member_no
          AND fms.daytime = cv.daytime;

          IF (lrec_fms.inv_rate IS NOT NULL AND cv.inv_rate IS NULL) THEN

           UPDATE fcst_mth_status fmsr
              SET fmsr.inv_rate = lrec_fms.inv_rate
            WHERE fmsr.member_no = cv.member_no
              AND fmsr.daytime = cv.daytime;

          END IF;


          lrec_fms := ec_fcst_mth_status.row_by_pk(cv.member_no,cv.daytime);

          UPDATE fcst_mth_status fms
             SET fms.inv_closing_value = nvl(lrec_fms.inv_closing_pos_qty, 0) *
                                         nvl(lrec_fms.inv_rate,0)
           WHERE fms.member_no = cv.member_no
             AND fms.daytime = cv.daytime;

   END LOOP;



END updateFcstINQuantities;



PROCEDURE deleteFcstValues(
p_forecast_id VARCHAR2 -- Forecast_Id
)
IS
BEGIN
    -- Delete from the Stim layer
    DELETE FROM stim_fcst_mth_value where forecast_id = p_forecast_id;

    -- Delete from the Monthly Table
    DELETE FROM fcst_mth_status where object_id = p_forecast_id;

    -- Delete from the Yeary Table
    DELETE FROM fcst_yr_status where object_id = p_forecast_id;

END deleteFcstValues;



PROCEDURE updateStimFcst(p_forecast_id VARCHAR2,
p_daytime DATE)
IS

CURSOR c_stim
IS
SELECT object_id, daytime, calc_method
FROM stim_fcst_mth_value t
WHERE t.forecast_id = p_forecast_id
AND t.daytime >= p_daytime
AND nvl(t.calc_method,ecdp_revn_forecast.getStreamItemAttribute(t.forecast_id,t.object_id,t.daytime,'CALC_METHOD')) = 'SK';

CURSOR c_cascade
IS
SELECT distinct t.object_id, t.daytime
FROM stim_fcst_mth_value t,  fcst_member fm
WHERE t.forecast_id = p_forecast_id
AND t.forecast_id = fm.OBJECT_ID
AND t.daytime >= p_daytime
AND t.calc_method IN ('IP','SK','FO')
AND fm.STREAM_ITEM_ID = t.object_id
;

BEGIN

    FOR curStim IN c_stim LOOP

        -- Do the Split Share update
      UPDATE stim_fcst_mth_value
         SET split_share = EcDp_Revn_Forecast.getsplitsharemth(p_forecast_id,
                                                               curStim.object_id,
                                                               curStim.daytime)
       WHERE object_id = curStim.object_id
         AND daytime = curStim.daytime
         AND forecast_id = p_forecast_id;

  END LOOP;

    FOR curCascade IN c_cascade LOOP

        -- Make it run in cascade
            INSERT INTO stim_cascade (object_id,period,daytime,forecast_id) VALUES (curCascade.object_id, 'FCST_MTH', TRUNC(curCascade.daytime,'MM'), p_forecast_id);

  END LOOP;


END updateStimFcst;


PROCEDURE Cache_DayMembers(p_object_id VARCHAR2) IS PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN
    DELETE FROM fcst_daymembers_CACHE;
    commit;
            INSERT INTO fcst_daymembers_CACHE
                (
          SELECT
                fm.object_id,
                fm.stream_item_id,
                fm.product_collection_type,
                daytime,
                ec_forecast_version.plan_date(p_object_id, daytime, '<=')
            FROM fcst_member fm, forecast f,
            (SELECT DISTINCT TRUNC(fms.daytime, 'MM') daytime,fms.object_id
            FROM fcst_mth_status fms, fcst_member fm
           WHERE fms.member_no = fm.member_no
                and p_object_id = fms.object_id) dates
           WHERE
                 dates.object_id = fm.object_id
                 and
                 fm.object_id = p_object_id
             AND fm.object_id = f.object_id);
    commit;
END Cache_DayMembers;


FUNCTION getSaleQtyCache(p_stream_item_id VARCHAR2,
                    p_to_uom         VARCHAR2,
                    p_daytime        DATE,
                    p_prod_coll_type VARCHAR2,
                    p_cntr_term_code VARCHAR2 DEFAULT NULL) -- SPOT/TERM/NULL)
  --</EC-DOC>
RETURN NUMBER

IS

ltab_uom_set ecdp_unit.t_UOMTable := EcDp_Unit.t_uomtable();
ln_result                   NUMBER;
CURSOR c_li_dist (cp_stream_item_id VARCHAR2, cp_daytime DATE, cp_prod_coll_type VARCHAR2, cp_cntr_term_code VARCHAR2) IS
       select
       c.qty1,c.uom1_code,c.qty2,c.uom2_code,c.qty3,c.uom3_code,c.qty4,c.uom4_code, c.dist_id,
       C.product_id,C.company_id
       FROM
       fcst_getSaleQty_CACHE c
       WHERE
           cp_stream_item_id = c.stream_item_id
           AND
           cp_daytime = c.daytime
           AND
           cp_prod_coll_type = c.product_collection_type
           AND
           NVL(upper(cp_cntr_term_code),upper(c.type)) = upper(c.type);
BEGIN

FOR c_val IN c_li_dist (p_stream_item_id, p_daytime, p_prod_coll_type, p_cntr_term_code) LOOP



     -- copy figures to table
    EcDp_unit.GenQtyUOMSet(ltab_uom_set, c_val.qty1, c_val.uom1_code
                           ,c_val.qty2, c_val.uom2_code
                           ,c_val.qty3, c_val.uom3_code
                           ,c_val.qty4, c_val.uom4_code);


    -- Retrieving the best match value
    ln_result := NVL(ln_result,0) + NVL(EcDp_Unit.GetUOMSetQty(ltab_uom_set, p_to_uom, p_daytime),0);


    -- Resetting the uom set
    ltab_uom_set := EcDp_Unit.t_uomtable();

END LOOP;

RETURN ln_result;

END getSaleQtyCache;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   getRevnRec
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getRevnRec_cache(p_object_id               VARCHAR2, -- Forecast object_id
                                         p_stream_item_id          VARCHAR2,
                                         p_product_id              VARCHAR2,
                                         p_product_context         VARCHAR2,
                                         p_product_collection_type VARCHAR2,
                                         p_qty                     NUMBER, -- spot price qty / term price qty
                                         p_daytime                 DATE)
--                                         p_cntr_term_code          VARCHAR2 DEFAULT NULL) -- SPOT/TERM/NULL
RETURN t_revn_rec
IS

   lrec_revn t_revn_rec;

   lv2_line_item_type VARCHAR2(32);

CURSOR c_li_dist (cp_stream_item_id VARCHAR2, cp_daytime DATE, cp_product_collection_type VARCHAR2) IS
SELECT c.booking_value,
       c.document_key,
       c.value_adjustment,
       c.term_code,
       c.line_item_type,
       c.line_item_based_type,
       c.local_value,
       (select max(ex_booking_local) from cont_transaction where document_key = c.document_key) ex_booking_local
FROM  fcst_GETREVNREC_CACHE c
      where
         cp_stream_item_id = c.stream_item_id
         AND
         cp_daytime = C.DAYTIME
         AND
        cp_product_collection_type = C.product_collection_type
;

BEGIN

    lrec_revn.act_net_price := 0;
    lrec_revn.local_gross_revenue := 0;
    lrec_revn.local_non_adj_revenue := 0;
    lrec_revn.value_adj := 0;
    lrec_revn.local_term_value := 0;
    lrec_revn.local_spot_value := 0;

    lv2_line_item_type := ec_fcst_product_setup.value_adj_type(p_object_id, p_product_id, p_product_context, p_product_collection_type);
    -- All Line items
    FOR net_pr IN c_li_dist (p_stream_item_id, p_daytime, p_product_collection_type) LOOP

        IF (net_pr.line_item_based_type = 'QTY') THEN
            lrec_revn.act_net_price := nvl(lrec_revn.act_net_price,0) + nvl(net_pr.booking_value,0)*net_pr.ex_booking_local;

            lrec_revn.local_gross_revenue := nvl(lrec_revn.local_gross_revenue,0) + (nvl(net_pr.local_value,0)/nvl(net_pr.value_adjustment,1));
--            + (nvl(net_pr.booking_value,0)*net_pr.ex_booking_local/nvl(net_pr.value_adjustment,1));

--            lrec_revn.local_non_adj_revenue := nvl(lrec_revn.local_non_adj_revenue,0) + (nvl(net_pr.booking_value,0)*net_pr.ex_booking_local);
            lrec_revn.local_non_adj_revenue := nvl(lrec_revn.local_non_adj_revenue,0) + nvl(net_pr.local_value,0);

            IF (net_pr.term_code = 'SPOT') THEN
                lrec_revn.local_spot_value := nvl(lrec_revn.local_spot_value,0) + nvl(net_pr.booking_value,0)*net_pr.ex_booking_local;
            ELSIF (net_pr.term_code = 'TERM') THEN
                lrec_revn.local_term_value := nvl(lrec_revn.local_term_value,0) + nvl(net_pr.booking_value,0)*net_pr.ex_booking_local;
            END IF;
        ELSE
            IF (net_pr.line_item_type = NVL(lv2_line_item_type,'XXX')) THEN
                lrec_revn.value_adj := nvl(lrec_revn.value_adj,0) + (nvl(net_pr.booking_value,0)*net_pr.ex_booking_local);
            END IF;
        END IF;

    END LOOP;

    -- Returning price divided on quantity (avoiding division by zero)
    IF p_qty IS NOT NULL AND p_qty <> 0 THEN
        lrec_revn.act_net_price := lrec_revn.act_net_price / p_qty;
    ELSE
        lrec_revn.act_net_price := 0;
    END IF;

    RETURN lrec_revn;

END getRevnRec_cache;

PROCEDURE Cache_GETREVNREC(p_object_id VARCHAR2) IS PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR get_day_members (cp_object_id VARCHAR2,cp_daytime date) IS
        select * from fcst_daymembers_cache
            where object_id = cp_object_id
            and daytime = cp_daytime;
    CURSOR get_days (cp_object_id VARCHAR2) IS
        SELECT DISTINCT TRUNC(fms.daytime, 'MM') daytime,fms.object_id
            FROM fcst_mth_status fms, fcst_member fm
           WHERE fms.member_no = fm.member_no
           and cp_object_id = fms.object_id;
  BEGIN
    DELETE FROM fcst_GETREVNREC_CACHE WHERE object_id = p_object_id;
    commit;

    FOR days IN get_days (p_object_id) LOOP
    --    FOR day_members IN get_day_members (p_object_id,days.daytime) LOOP
                INSERT INTO fcst_GETREVNREC_CACHE
            (SELECT
                       day_members.daytime,day_members.object_id, day_members.product_collection_type,day_members.stream_item_id, c.booking_value,
                       c.document_key,
                       c.value_adjustment,
                       ec_contract_version.contract_term_code(c.object_id, c.daytime, '<=') term_code,
                       c.line_item_type,
                       c.line_item_based_type,
                       c.booking_value * DECODE(ec_cont_transaction.reversed_trans_key(c.transaction_key)
                           , NULL, ec_cont_transaction.ex_booking_local(c.transaction_key)
                           , ec_cont_transaction.ex_booking_local(ec_cont_transaction.reversed_trans_key(c.transaction_key))) local_value
                FROM  cont_line_item_dist c,
                    (select * from fcst_daymembers_cache where daytime = days.daytime and object_id = p_object_id) day_members
                WHERE c.line_item_type IN ('SALE','PAY_ADJ')
                  AND c.dist_id IN
                                 (SELECT siv.field_id
                                  FROM   stream_item si, stream_item_version siv
                                  WHERE  si.object_id = day_members.stream_item_id
                                  AND    si.object_id = siv.object_id
                                  AND    day_members.daytime >= si.start_date
                                  AND    day_members.daytime < nvl(si.end_date,day_members.daytime+1)
                                  AND    siv.daytime =
                                                     (
                                                     SELECT MAX(sivn.daytime)
                                                     FROM   stream_item_version sivn
                                                     WHERE  sivn.object_id = si.object_id
                                                     AND    sivn.daytime <= day_members.daytime
                                                     )


                                  )
                AND
                ((
                SELECT siv.product_id
                                   FROM stream_item si, stream_item_version siv
                                   WHERE si.object_id = c.stream_item_id
                                     AND si.object_id = siv.object_id
                                     AND c.daytime >= si.start_date
                                     AND c.daytime < nvl(si.end_date, c.daytime + 1)
                                     AND    siv.daytime =
                                                     (
                                                     SELECT MAX(sivn.daytime)
                                                     FROM   stream_item_version sivn
                                                     WHERE  sivn.object_id = siv.object_id
                                                     AND    sivn.daytime <= c.daytime
                                                     )
                )
                =
                (
                SELECT siv2.product_id
                                   FROM stream_item si2, stream_item_version siv2
                                   WHERE si2.object_id = day_members.stream_item_id
                                     AND si2.object_id = siv2.object_id
                                     AND day_members.daytime >= si2.start_date
                                     AND day_members.daytime < nvl(si2.end_date, day_members.daytime + 1)
                                     AND    siv2.daytime =
                                                        (
                                                         SELECT MAX(sivn.daytime)
                                                         FROM   stream_item_version sivn
                                                         WHERE  sivn.object_id = siv2.object_id
                                                         AND    siv2.daytime <= day_members.daytime
                                                         )
                ))
                AND
                ((
                SELECT siv.company_id
                  FROM stream_item si, stream_item_version siv
                 WHERE si.object_id = c.stream_item_id
                   AND si.object_id = siv.object_id
                   AND c.daytime >= si.start_date
                   AND c.daytime < nvl(si.end_date, c.daytime + 1)
                   AND    siv.daytime =
                                       (
                                       SELECT MAX(sivn.daytime)
                                       FROM   stream_item_version sivn
                                       WHERE  sivn.object_id = siv.object_id
                                       AND    sivn.daytime <= c.daytime
                                       )
                )
                =
                (
                SELECT siv.company_id
                  FROM stream_item si, stream_item_version siv
                 WHERE si.object_id = day_members.stream_item_id
                   AND si.object_id = siv.object_id
                   AND day_members.daytime >= si.start_date
                   AND day_members.daytime < nvl(si.end_date, day_members.daytime + 1)
                   AND    siv.daytime =
                                       (
                                       SELECT MAX(sivn.daytime)
                                       FROM   stream_item_version sivn
                                       WHERE  sivn.object_id = siv.object_id
                                       AND    sivn.daytime <= day_members.daytime
                                       )
                ))
                AND    c.document_key IN
                                       (SELECT  cd.document_key
                                        FROM    cont_document cd
                                        WHERE   cd.document_level_code = 'BOOKED'
                                        AND     cd.financial_code = decode(day_members.product_collection_type,'GAS_PURCHASE','PURCHASE','GAS_SALES','SALE','LIQUID','SALE')
                                        AND     cd.booking_period <= nvl(day_members.plan_date,cd.booking_period + 1)
                                        )
                AND    c.transaction_key IN
                                         (SELECT ct.transaction_key
                                          FROM   cont_transaction ct
                                          WHERE  ct.transaction_date BETWEEN day_members.daytime AND last_day(day_members.daytime)
                                          )
                );

            COMMIT;
          END LOOP;

        --END LOOP;
  END Cache_GETREVNREC;

PROCEDURE Cache_getSaleQty(p_object_id VARCHAR2) IS PRAGMA AUTONOMOUS_TRANSACTION;

    CURSOR get_day_members (cp_object_id VARCHAR2,cp_daytime date) IS
        select * from fcst_daymembers_cache
            where object_id = cp_object_id
            and daytime = cp_daytime;
    CURSOR get_days (cp_object_id VARCHAR2) IS
        SELECT DISTINCT TRUNC(fms.daytime, 'MM') daytime,fms.object_id
            FROM fcst_mth_status fms, fcst_member fm
           WHERE fms.member_no = fm.member_no
           and cp_object_id = fms.object_id;
  BEGIN
    DELETE FROM fcst_getSaleQty_CACHE WHERE object_id = p_object_id;
    commit;

    FOR days IN get_days (p_object_id) LOOP
--        FOR day_members IN get_day_members (p_object_id, days.daytime) LOOP
            INSERT INTO fcst_getSaleQty_CACHE
            (SELECT
                day_members.daytime,
                p_object_id,
                day_members.product_collection_type,
                day_members.stream_item_id,
                c.qty1,c.uom1_code,c.qty2,c.uom2_code,c.qty3,c.uom3_code,c.qty4,c.uom4_code, c.dist_id,
                ec_stream_item_version.product_id(c.stream_item_id,c.daytime,'<=') product_id,
                ec_stream_item_version.company_id(c.stream_item_id,c.daytime,'<=') company_id,
                (SELECT cov.contract_term_code
                  FROM contract co, contract_version cov
                 WHERE co.object_id = c.object_id
                   AND co.object_id = cov.object_id
                   AND day_members.daytime >= co.start_date
                   AND day_members.daytime < nvl(co.end_date, day_members.daytime + 1)
                   AND    cov.daytime =
                                       (
                                       SELECT MAX(cnv.daytime)
                                       FROM   contract_version cnv
                                       WHERE  cnv.object_id = cov.object_id
                                       AND    cnv.daytime <= day_members.daytime
                                       )
                ) as typex
                FROM   cont_line_item_dist c,
                    (select * from fcst_daymembers_cache where daytime = days.daytime and object_id = p_object_id) day_members
                    WHERE  c.line_item_based_type = 'QTY'
                AND    c.move_qty_to_vo_ind = 'Y'
                AND    c.document_key IN
                                       (SELECT  cd.document_key
                                        FROM    cont_document cd
                                        WHERE   cd.document_level_code = 'BOOKED'
                                        AND     cd.financial_code = decode(day_members.product_collection_type --cp_prod_coll_type
                                        ,'GAS_PURCHASE','PURCHASE','GAS_SALES','SALE','LIQUID','SALE')
                                        AND cd.booking_period <= NVL(day_members.plan_date,cd.booking_period + 1)
                                        )
                AND    c.transaction_key IN
                                         (SELECT ct.transaction_key
                                          FROM   cont_transaction ct
                                          WHERE  ct.transaction_date BETWEEN day_members.daytime AND last_day(day_members.daytime)
                                          )
                AND    c.dist_id IN
                                 (SELECT siv.field_id
                                  FROM   stream_item si, stream_item_version siv
                                  WHERE  si.object_id = day_members.stream_item_id
                                  AND    si.object_id = siv.object_id
                                  AND    day_members.daytime >= si.start_date
                                  AND    day_members.daytime < nvl(si.end_date,day_members.daytime+1)
                                  AND    siv.daytime =
                                                     (
                                                     SELECT MAX(sivn.daytime)
                                                     FROM   stream_item_version sivn
                                                     WHERE  sivn.object_id = day_members.stream_item_id
                                                     AND    sivn.daytime <= day_members.daytime
                                                     )


                                  )
                AND
                ((
                SELECT siv.product_id
                                   FROM stream_item si, stream_item_version siv
                                   WHERE si.object_id = c.stream_item_id
                                     AND si.object_id = siv.object_id
                                     AND c.daytime >= si.start_date
                                     AND c.daytime < nvl(si.end_date, c.daytime + 1)
                                     AND    siv.daytime =
                                                     (
                                                     SELECT MAX(sivn.daytime)
                                                     FROM   stream_item_version sivn
                                                     WHERE  sivn.object_id = siv.object_id
                                                     AND    sivn.daytime <= c.daytime
                                                     )
                )
                =
                (
                SELECT siv2.product_id
                                    FROM stream_item si2, stream_item_version siv2
                                   WHERE si2.object_id = day_members.stream_item_id
                                     AND si2.object_id = siv2.object_id
                                     AND day_members.daytime >= si2.start_date
                                     AND day_members.daytime < nvl(si2.end_date, day_members.daytime + 1)
                                     AND    siv2.daytime =
                                                        (
                                                         SELECT MAX(sivn.daytime)
                                                         FROM   stream_item_version sivn
                                                         WHERE  sivn.object_id = siv2.object_id
                                                         AND    siv2.daytime <= day_members.daytime
                                                         )
                ))
                AND
                ((
                SELECT siv.company_id
                  FROM stream_item si, stream_item_version siv
                 WHERE si.object_id = c.stream_item_id
                   AND si.object_id = siv.object_id
                   AND c.daytime >= si.start_date
                   AND c.daytime < nvl(si.end_date, c.daytime + 1)
                   AND    siv.daytime =
                                       (
                                       SELECT MAX(sivn.daytime)
                                       FROM   stream_item_version sivn
                                       WHERE  sivn.object_id = siv.object_id
                                       AND    sivn.daytime <= c.daytime
                                       )
                )
                =
                (
                SELECT siv.company_id
                  FROM stream_item si, stream_item_version siv
                 WHERE si.object_id = day_members.stream_item_id
                   AND si.object_id = siv.object_id
                   AND day_members.daytime >= si.start_date
                   AND day_members.daytime < nvl(si.end_date, day_members.daytime + 1)
                   AND    siv.daytime =
                                       (
                                       SELECT MAX(sivn.daytime)
                                       FROM   stream_item_version sivn
                                       WHERE  sivn.object_id = siv.object_id
                                       AND    sivn.daytime <= day_members.daytime
                                       )
                ))
                );
            COMMIT;
            END LOOP;
        --END LOOP;
  END Cache_getSaleQty;



-- Validate forecast stream item config prior to committing save
-- Run from PostStreamItemBusinessAction.
PROCEDURE ValidateFcstStreamItem (
   p_object_id VARCHAR2,
   p_stim_fcst_no NUMBER,
   p_daytime   DATE
)

IS

  generic_error   EXCEPTION;
  lv2_err_msg     VARCHAR2(2000);
  lv2_calc_method VARCHAR2(32) := ec_stim_fcst_setup.calc_method(p_stim_fcst_no);
  lv2_formula     VARCHAR2(2000) := ec_stim_fcst_setup.stream_item_formula(p_stim_fcst_no);

BEGIN

     IF lv2_calc_method IN ( 'IP', 'CO' ) THEN

        IF lv2_formula IS NOT NULL OR lv2_formula <> '' THEN

           lv2_err_msg := 'Stream items with calc method '|| lv2_calc_method ||' must have a blank Formula';

           RAISE generic_error;

        END IF;

     ELSIF lv2_calc_method IN ( 'SK' , 'FO' ) THEN

       IF lv2_formula IS NULL OR lv2_formula = '' THEN

           lv2_err_msg := 'Stream items with calc method '|| lv2_calc_method ||' can not have a blank Formula';

           RAISE generic_error;

       END IF;

     END IF;


EXCEPTION

   WHEN generic_error THEN
        Raise_Application_Error(-20000,lv2_err_msg || '. Stream item: ' || Nvl(ec_stream_item.object_code(p_object_id),' ') || ' - ' || Nvl(ec_stream_item_version.name(p_object_id,p_daytime,'<='),' '));

END ValidateFcstStreamItem;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  setObjectEndDate
-- Description    :  Called when creating or modifying a forecast object
--                   Makes sure end date is set to end of the year for Qunatity and forecast
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE SetObjectEndDate(p_object_id              VARCHAR2,
                           p_object_start_date      DATE,
                           p_functional_area_code   VARCHAR2,
                           p_daytime                DATE)
--</EC-DOC>


IS


BEGIN

    IF p_functional_area_code in ('QUANTITY_FORECAST','REVENUE_FORECAST') THEN

      UPDATE forecast f
        SET f.END_date = last_day(add_months(trunc(p_object_start_date,'YYYY'), 11))
        WHERE f.object_id = p_object_id;


      UPDATE forecast_version fv
        SET fv.END_date = last_day(add_months(trunc(p_object_start_date,'YYYY'), 11))
        WHERE fv.object_id = p_object_id
        AND fv.daytime = p_daytime;

    END IF;

END SetObjectEndDate;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  DeleteFcstObj
-- Description    :  This Procedure will delete Forecast Object in EC. This is done by setting
--                   end date same as start date.
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using procedures:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE DeleteFcstObj(p_object_id         VARCHAR2,
                        p_user              VARCHAR2)
--</EC-DOC>

IS

BEGIN

  -- Update Forecast Table
  UPDATE forecast f
  SET f.END_date = f.Start_Date, f.last_updated_by = p_user
  WHERE f.object_id = p_object_id;

  -- Update Forecast Version Table
  UPDATE forecast_version fv
  SET fv.END_date = fv.daytime, fv.last_updated_by = p_user
  WHERE fv.object_id = p_object_id;

END DeleteFcstObj;

END EcDp_Revn_Forecast;