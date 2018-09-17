CREATE OR REPLACE PACKAGE EcDp_Revn_Forecast IS
/**************************************************************
** Package        :  EcDp_Revn_Forecast, header part
**
** $Revision: 1.62 $
**
**
** Purpose	:  Forecast functionality
**
** General Logic:
**
** Modification history:
**
** See body part
**
**************************************************************/

TYPE t_revn_price_rec IS RECORD
  (
    term_price NUMBER,
    spot_price NUMBER
);

TYPE t_revn_rec IS RECORD
  (
    act_net_price NUMBER,
    local_gross_revenue NUMBER,
    local_non_adj_revenue NUMBER,
    value_adj NUMBER,
    local_term_value NUMBER,
    local_spot_value NUMBER
);

TYPE t_fcst_inv_rec IS RECORD
  (
    opening_pos_qty NUMBER,
    closing_pos_qty NUMBER,
    qty_uom VARCHAR2(16),
    closing_value NUMBER,
    rate NUMBER
);

TYPE t_object_rec IS RECORD
  (
    object_id VARCHAR2(32),
    object_type VARCHAR2(32)
);

TYPE t_cascade_rec IS RECORD
  (
    calc_type VARCHAR2(32),
    execution_order NUMBER,
    object_id VARCHAR2(32),
    CODE VARCHAR2(32),
    Equation VARCHAR2(2000),
    calc_method VARCHAR2(32),
    Measure VARCHAR2(32),
    NetMass NUMBER,
    NetMassUnit VARCHAR2(32),
    NetVolume NUMBER,
    NetVolumeUnit VARCHAR2(32),
    NetEnergy NUMBER,
    NetEnergyUnit VARCHAR2(32),
    NetExtra1     NUMBER,
    Extra1Unit VARCHAR2(32),
    NetExtra2     NUMBER,
    Extra2Unit VARCHAR2(32),
    NetExtra3     NUMBER,
    Extra3Unit VARCHAR2(32),
    conversion_method VARCHAR2(32),
    SplitShare NUMBER,
    daytime DATE,
    status VARCHAR2(32),
    record_status VARCHAR2(32),
    split_type VARCHAR2(32),
    density NUMBER,
    densityMassUnit VARCHAR2(32),
    densityVolumeUnit VARCHAR2(32),
    gcv NUMBER,
    gcvEnergyUnit VARCHAR2(32),
    gcvVolumeUnit VARCHAR2(32),
    mcv NUMBER,
    mcvEnergyUnit VARCHAR2(32),
    mcvMassUnit VARCHAR2(32),
    boeFromUnit VARCHAR2(32),
    boeUnit     VARCHAR2(32),
    boeFactor   VARCHAR2(32),
    density_source_id VARCHAR2(32),
    gcv_source_id VARCHAR2(32),
    mcv_source_id VARCHAR2(32),
    boe_source_id VARCHAR2(32)
);

TYPE t_object_tab IS TABLE OF t_object_rec;

TYPE t_object_rows IS TABLE OF t_cascade_rec; -- VARCHAR2(32);

FUNCTION getCascadeRows(
   p_forecast_id VARCHAR2,
   p_object_id VARCHAR2,
   p_daytime   DATE
) RETURN t_object_rows PIPELINED ;

PROCEDURE getCascadeIds (
   p_object_tab IN OUT t_object_tab,
   p_forecast_id VARCHAR2,
   p_object_id VARCHAR2,
   p_daytime   DATE
);

FUNCTION copyFcstObj(
   p_object_id VARCHAR2, -- to copy from
   p_daytime   DATE, -- start date
   p_user      VARCHAR2)

RETURN VARCHAR2; -- new contract object_id

PROCEDURE delFcstObj(
   p_object_id VARCHAR2, -- to delete
   p_user VARCHAR2
  )
;

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
;

PROCEDURE InstantiateFcst(
   p_object_id VARCHAR2
  ,p_daytime DATE);

PROCEDURE verifyQtyFcst(
   p_object_id VARCHAR2,
   p_field_id VARCHAR2,
   p_company_id VARCHAR2)
;

PROCEDURE approveQtyFcst(
   p_object_id VARCHAR2,
   p_field_group_id VARCHAR2,
   p_company_id VARCHAR2)
;

PROCEDURE unapproveQtyFcst(
   p_object_id VARCHAR2,
   p_field_group_id VARCHAR2,
   p_company_id VARCHAR2)
;
FUNCTION getConvertedValue(p_stream_item_id VARCHAR2,
                           p_forecast_id    VARCHAR2,
                           p_daytime        DATE,
                           p_value          NUMBER,
                           p_from_uom       VARCHAR2,
                           p_to_uom         VARCHAR2,
                           p_status         VARCHAR2) RETURN NUMBER;

FUNCTION getSumProductMthByField(
   p_object_id VARCHAR2,
   p_daytime DATE,
   p_field_id VARCHAR2,
   p_product_id VARCHAR2,
   p_company_id VARCHAR2,
   p_product_context VARCHAR2
) RETURN NUMBER
;

FUNCTION getOverWrittenInd(p_object_id  VARCHAR2,
                                 p_daytime    DATE,
                                 p_field_id   VARCHAR2,
                                 p_product_id VARCHAR2,
                                 p_company_id VARCHAR2,
                                 p_product_context VARCHAR2)
RETURN VARCHAR2;

FUNCTION getSumAllProductMthByField(p_object_id       VARCHAR2,
                                    p_daytime         DATE,
                                    p_field_id        VARCHAR2,
                                    p_company_id      VARCHAR2,
                                    p_product_context VARCHAR2)
  RETURN NUMBER
;

FUNCTION getInventoryMovement(p_member_no NUMBER, p_daytime DATE, p_prod_coll_type VARCHAR2)
RETURN NUMBER;




FUNCTION getSumProductYrByField(p_object_id       VARCHAR2,
                                p_field_id        VARCHAR2,
                                p_product_id      VARCHAR2,
                                p_company_id      VARCHAR2,
                                p_product_context VARCHAR2

                                ) RETURN NUMBER
;

FUNCTION getSumAllProductYrByField(
   p_object_id VARCHAR2,
   p_field_id VARCHAR2,
   p_company_id VARCHAR2,
   p_product_context VARCHAR2
) RETURN NUMBER
;

FUNCTION getNumDaysInYear(
   p_year DATE
) RETURN INTEGER
;

FUNCTION getStatus (
  p_object_id VARCHAR2,
  p_field_id VARCHAR2,
  p_company_id VARCHAR2,
  p_prod_col_type VARCHAR2,
  p_status VARCHAR2
) RETURN NUMBER
;

FUNCTION getForecastStatus(p_forecast_id VARCHAR2)
RETURN VARCHAR2
;

FUNCTION getAllStatus (
  p_object_id VARCHAR2,
  p_field_id VARCHAR2,
  p_company_id VARCHAR2,
  p_prod_col_type VARCHAR2 DEFAULT 'QUANTITY'
) RETURN VARCHAR2
;

FUNCTION getStreamItemStatus (
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_field_id VARCHAR2,
  p_company_id VARCHAR2,
  p_status VARCHAR2
) RETURN NUMBER
;

FUNCTION getAllStreamItemStatus (
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_field_id VARCHAR2,
  p_company_id VARCHAR2
) RETURN VARCHAR2
;

FUNCTION getPYAStreamItemStatus (
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_status VARCHAR2
 )
RETURN NUMBER;

FUNCTION getPYAGPurchNetQty(p_forecast_id  VARCHAR2,
                         p_object_id      VARCHAR2, -- contract
                         p_product_id     VARCHAR2,
                         p_to_uom         VARCHAR2,
                         p_from_uom       VARCHAR2,
                         p_daytime        DATE)
RETURN NUMBER;

FUNCTION getAllPYAStreamItemStatus (
  p_object_id VARCHAR2,
  p_daytime DATE
  )
RETURN VARCHAR2;

FUNCTION genForecastCase(p_object_id   VARCHAR2,
                         p_daytime     DATE,
                         p_user        VARCHAR2,
                         p_forecast_id VARCHAR2 DEFAULT NULL
                         ) RETURN VARCHAR2;


PROCEDURE delForecastCase(p_stim_fcst_no NUMBER)
;

FUNCTION chkStreamItem (
 p_object_id VARCHAR2,
 p_product_id VARCHAR2,
 p_stream_item_id VARCHAR2,
 p_product_context VARCHAR2
)
RETURN NUMBER
;

PROCEDURE updNetQty(p_object_id VARCHAR2,
                      p_member_no NUMBER,
                      p_daytime   VARCHAR2,
                      p_user      VARCHAR2,
                      p_net_qty   NUMBER DEFAULT NULL);

PROCEDURE postUpdNetQtyMember(p_object_id VARCHAR2,
                    p_member_no NUMBER,
                    p_daytime   VARCHAR2,
                    p_user      VARCHAR2);

PROCEDURE postUpdNetQty(p_object_id VARCHAR2,
                    p_member_no NUMBER,
                    p_daytime   VARCHAR2,
                    p_user      VARCHAR2,
                    p_net_qty   NUMBER DEFAULT NULL,
                    p_stream_item_id VARCHAR2 DEFAULT NULL);

PROCEDURE updPyaQty(--p_object_id VARCHAR2,
                    p_member_no NUMBER,
                    --p_daytime   VARCHAR2,
                    p_user      VARCHAR2,
                    p_pya_qty   NUMBER DEFAULT NULL);

FUNCTION getSumPYearAdjByField(p_object_id  VARCHAR2,
                               p_daytime    DATE,
                               p_field_id   VARCHAR2,
                               p_product_id VARCHAR2,
                               p_prod_cnxt  VARCHAR2,
                               p_company_id VARCHAR2,
                               p_to_uom VARCHAR2 DEFAULT NULL
                               ) RETURN NUMBER;

FUNCTION getSumAllPYearAdjByField(p_object_id  VARCHAR2,
                               p_daytime    DATE,
                               p_field_group_id   VARCHAR2,
                               p_product_id VARCHAR2,
                               p_prod_cntx  VARCHAR2,
                               p_company_id VARCHAR2
                               )  RETURN NUMBER;

FUNCTION getSumAllPYearAdj(p_object_id  VARCHAR2,
                           p_daytime    DATE,
                           p_field_group_id   VARCHAR2,
                           p_product_id VARCHAR2,
                           p_prod_cntx  VARCHAR2,
                           p_company_id VARCHAR2)  RETURN NUMBER;

PROCEDURE updateFcstProductSetup(
   p_object_id VARCHAR2,
   p_product_collection_type VARCHAR2,
   p_n_product_id VARCHAR2,
   p_n_COMMERCIAL_ADJ_TYPE VARCHAR2,
   p_n_SWAP_ADJ_TYPE VARCHAR2,
   p_o_product_id VARCHAR2,
   p_o_COMMERCIAL_ADJ_TYPE VARCHAR2,
   p_o_SWAP_ADJ_TYPE VARCHAR2
   );

PROCEDURE validateFcstMember (
 p_object_id VARCHAR2,
 p_product_id VARCHAR2,
 p_n_stream_item_id VARCHAR2,
 p_o_stream_item_id VARCHAR2,
 p_product_collection_type VARCHAR2,
 p_flag VARCHAR2
 );

PROCEDURE populateFcstMember(
   p_object_id VARCHAR2,
   p_product_id VARCHAR2,
   p_product_collection_type VARCHAR2,
   p_commercial_adj_type VARCHAR2,
   p_swap_adj_type VARCHAR2
   );

PROCEDURE delCascadeFcstMember(
   p_object_id VARCHAR2,
   p_product_id VARCHAR2,
   p_product_collection_type VARCHAR2
   );

FUNCTION getYearlyValueMthFxByMember(p_member_no VARCHAR2, -- Forecast Member No
                                  p_fromdate  DATE,
                                  p_todate    DATE,
                                  p_type      VARCHAR2) -- Column to calculate
                                  RETURN NUMBER;

FUNCTION getPlanQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                            p_daytime   DATE,     -- YEAR or MONTH date
                            p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
                            RETURN NUMBER;

FUNCTION getCommAdjQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                               p_daytime   DATE,  -- YEAR or MONTH date
                               p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
                              RETURN NUMBER;

FUNCTION getSwapAdjQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                               p_daytime   DATE,  -- YEAR or MONTH date
                               p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
                              RETURN NUMBER;

FUNCTION getAvailSalesQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                                  p_daytime   DATE,  -- YEAR or MONTH date
                                  p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
                                 RETURN NUMBER;

FUNCTION getSaleQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                            p_daytime   DATE,     -- YEAR or MONTH date
                            p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
                            RETURN NUMBER;

FUNCTION getSpotSaleQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                             p_daytime   DATE,  -- YEAR or MONTH date
                             p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
                            RETURN NUMBER;

FUNCTION getTermSaleQtyByMember(p_member_no VARCHAR2, -- Forecast Member No
                             p_daytime   DATE,  -- YEAR or MONTH date
                             p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
                            RETURN NUMBER;

FUNCTION getInventoryMovQtyLiqByMember(p_member_no VARCHAR2, -- Forecast Member No
                                    p_daytime   DATE,  -- YEAR or MONTH date
                                    p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
                                   RETURN NUMBER;

FUNCTION getInventoryMovQtyGSalByMember(p_member_no VARCHAR2, -- Forecast Member No
                                    p_daytime   DATE,  -- YEAR or MONTH date
                                    p_type      VARCHAR2) -- YEAR, SUM_YEAR_BY_MTH or MONTH
                                   RETURN NUMBER;

FUNCTION getSumBasePriceByMember(p_object_id VARCHAR2,
                                 p_daytime   DATE,
                                 p_field_id  VARCHAR2,
                                 p_product_id VARCHAR2) RETURN NUMBER;


FUNCTION getSumDifferentialByMember(p_object_id VARCHAR2,
                                    p_daytime   DATE,
                                    p_field_id  VARCHAR2,
                                    p_product_id VARCHAR2) RETURN NUMBER;



FUNCTION isPriorToPlanDate(p_object_id VARCHAR2, p_daytime DATE, p_false_on_plan_date VARCHAR2 DEFAULT 'FALSE')

 RETURN VARCHAR2;

FUNCTION getSumTermPriceByMember(p_object_id  VARCHAR2,
                                 p_daytime    DATE,
                                 p_field_id   VARCHAR2,
                                 p_product_id VARCHAR2)
RETURN NUMBER;


FUNCTION getSumSpotPriceByMember(p_object_id  VARCHAR2,
                                 p_daytime    DATE,
                                 p_field_id   VARCHAR2,
                                 p_product_id VARCHAR2)
RETURN NUMBER;

FUNCTION getSumCostPriceByMember(p_object_id   VARCHAR2,
                                 p_daytime     DATE,
                                 p_contract_id VARCHAR2,
                                 p_product_id  VARCHAR2)
RETURN NUMBER;

FUNCTION getSumSalesPriceByMember(p_object_id  VARCHAR2,
                                  p_daytime    DATE,
                                  p_contract_id VARCHAR2,
                                  p_product_id VARCHAR2)
RETURN NUMBER;



PROCEDURE PopulateFcst(p_object_id      VARCHAR2,
                       p_func_area_code VARCHAR2,
                       p_user           VARCHAR2);


PROCEDURE setValidPlanDate(p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE approveRevnFcst(
   p_object_id VARCHAR2,
   p_field_group_id VARCHAR2,
   p_product_collection_type VARCHAR2)
;

PROCEDURE verifyRevnFcst(p_object_id VARCHAR2, p_member_no VARCHAR2);

PROCEDURE updFcstLiquidPrices(p_member_no    NUMBER,
                              p_daytime      DATE,
                              p_base_price   NUMBER,
                              p_differential NUMBER,
                              p_forex        NUMBER);


PROCEDURE updateFcstGSalesPrices(p_member_no NUMBER, p_daytime DATE);


PROCEDURE updateFcstLiquidRevenueValues(p_member_no NUMBER, p_daytime DATE);


PROCEDURE updateFcstLiquidQuantities(p_member_no      NUMBER,
                                     p_daytime        DATE);

PROCEDURE postUpdateFcstRevnQuantities(p_member_no NUMBER, p_daytime DATE);

PROCEDURE updateFcstGSalesRevenue(p_member_no NUMBER, p_daytime DATE);
PROCEDURE updateFcstGPurchPrice(p_member_no NUMBER, p_daytime DATE);
PROCEDURE updateFcstGPurchRevenue(p_member_no NUMBER, p_daytime DATE);
PROCEDURE updateFcstGSalesQuantities(p_member_no NUMBER, p_daytime DATE);
PROCEDURE updateFcstGPurchQuantities(p_member_no NUMBER, p_daytime DATE);
PROCEDURE updateFcstGSSpotTermQty(p_member_no NUMBER, p_daytime DATE);


FUNCTION RevnFcstProductInQtyFcst(p_object_id  VARCHAR2, -- FORECAST
                                  p_product_id VARCHAR2,
                                  p_field_id VARCHAR2,
                                  p_company_id VARCHAR2,
                                  p_daytime    DATE)
RETURN VARCHAR2;

PROCEDURE validateFcstOwner(p_forecast_owner VARCHAR2, p_user VARCHAR2, p_forecast_scope VARCHAR2);

FUNCTION getStatusRevn (
  p_object_id VARCHAR2,
  p_member_no VARCHAR2,
  p_status VARCHAR2
) RETURN NUMBER
;

FUNCTION getAllStatusRevn (
  p_object_id VARCHAR2,
  p_member_no VARCHAR2
) RETURN VARCHAR2
;

FUNCTION getSplitKey(p_forecast_id VARCHAR2,
p_stream_item_id VARCHAR2,
p_daytime DATE)
RETURN VARCHAR2
;

FUNCTION GetConvValue (
   p_forecast_id VARCHAR2,
   p_stream_item_id VARCHAR2,  -- STREAM_ITEM object_id
   p_daytime DATE, -- Date to process for
   p_group VARCHAR2, -- M V or E
   p_to_uom VARCHAR2
) RETURN NUMBER
;

FUNCTION checkConversionFactorExists(p_daytime        DATE,
                                     p_stream_item_id VARCHAR2,
                                     p_forecast_id    VARCHAR2,
                                     p_from_uom       VARCHAR2,
                                     p_to_uom         VARCHAR2,
                                     p_status         VARCHAR2)
  RETURN NUMBER;

FUNCTION checkConversionFactorExistsSum(p_object_id VARCHAR2,
                                        p_daytime   DATE,
                                        p_field_id  VARCHAR2,
                                        p_company_id VARCHAR2,
                                        p_product_context VARCHAR2
                                        )
RETURN NUMBER;

FUNCTION getStreamItemAttribute(p_forecast_id VARCHAR2,
p_stream_item_id VARCHAR2,
p_daytime DATE,
p_attribute VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetSplitShareMth(
   p_forecast_id VARCHAR2,
   p_object_id VARCHAR2,
   p_daytime   DATE
) RETURN NUMBER;


FUNCTION getOpeningPosionByMember(p_member_no VARCHAR2,
                                  p_daytime   DATE,
                                  p_type      VARCHAR2) RETURN NUMBER;

FUNCTION getClosingPosionByMember(p_member_no VARCHAR2,
                                  p_daytime   DATE,
                                  p_type      VARCHAR2) RETURN NUMBER;

FUNCTION getClosingValueByMember(p_member_no VARCHAR2,
                                 p_daytime   DATE,
                                 p_type      VARCHAR2) RETURN NUMBER;



FUNCTION getInventoryClosingPos(
   p_forecast_id VARCHAR2,
   p_member_no VARCHAR2,
   p_uom VARCHAR2,
   p_daytime   DATE
) RETURN t_fcst_inv_rec;

PROCEDURE updateFcstINQuantities(p_member_no NUMBER, p_daytime DATE);

PROCEDURE deleteFcstValues(
p_forecast_id VARCHAR2 -- Forecast_Id
);

FUNCTION getNetQty(p_object_id      VARCHAR2, -- forecast case
                   p_stream_item_id VARCHAR2,
                   p_to_uom         VARCHAR2,
                   p_daytime        DATE)
--</EC-DOC>
RETURN NUMBER;

PROCEDURE updateStimFcst(
          p_forecast_id VARCHAR2,
          p_daytime DATE);

FUNCTION getSaleQty(p_forecast_id VARCHAR2,
                    p_stream_item_id VARCHAR2,
                    p_to_uom         VARCHAR2,
                    p_daytime        DATE,
                    p_prod_coll_type VARCHAR2,
                    p_cntr_term_code VARCHAR2 DEFAULT NULL) -- SPOT/TERM/NULL)
  --</EC-DOC>
RETURN NUMBER;

FUNCTION getSaleQtyCache(p_stream_item_id VARCHAR2,
                    p_to_uom         VARCHAR2,
                    p_daytime        DATE,
                    p_prod_coll_type VARCHAR2,
                    p_cntr_term_code VARCHAR2 DEFAULT NULL) -- SPOT/TERM/NULL)
  --</EC-DOC>
RETURN NUMBER;

FUNCTION getRevnRec_cache(p_object_id               VARCHAR2, -- Forecast object_id
                          p_stream_item_id          VARCHAR2,
                          p_product_id              VARCHAR2,
                          p_product_context         VARCHAR2,
                          p_product_collection_type VARCHAR2,
                          p_qty                     NUMBER, -- spot price qty / term price qty
                          p_daytime                 DATE)
--                                         p_cntr_term_code          VARCHAR2 DEFAULT NULL) -- SPOT/TERM/NULL
 RETURN t_revn_rec;

PROCEDURE Cache_GETREVNREC(p_object_id VARCHAR2);

PROCEDURE Cache_getSaleQty(p_object_id VARCHAR2) ;

PROCEDURE Cache_DayMembers(p_object_id VARCHAR2) ;


PROCEDURE ValidateFcstStreamItem (
   p_object_id VARCHAR2,
   p_stim_fcst_no NUMBER,
   p_daytime   DATE);

PROCEDURE SetObjectEndDate(p_object_id              VARCHAR2,
                           p_object_start_date      DATE,
                           p_functional_area_code   VARCHAR2,
                           p_daytime                DATE);
----------------------------------------------------------------------------------------------------------------
PROCEDURE DeleteFcstObj(p_object_id                 VARCHAR2,
                        p_user                      VARCHAR2);
----------------------------------------------------------------------------------------------------------------
END Ecdp_Revn_Forecast;