CREATE OR REPLACE PACKAGE EcDp_Inventory IS
/****************************************************************
** Package        :  EcDp_Inventory, header part
**
** $Revision: 1.70 $
**
** Purpose        :  Provide special functions on Inventory handling. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created        : 19.07.2002  MAnfred Vonlanthen
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- --------------------------------------
** 05.02.2004  KJT  Change "PRODUCT_GROUP" to "PRODUCT_GROUP_CODE"
** 20.11.2008  OAN  Added new procedures and functions for historic layers.
**                  FUNCTION  IsAttributeEditable
**                  PROCEDURE SetStimMthInvHistoric
**                  PROCEDURE SetInvLayerHistoric
**                  PROCEDURE RemoveStimMthInvHistoric
**                  PROCEDURE ProcessHistoricInventory
**                  FUNCTION  IsValuationNotRun
**                  PROCEDURE CheckLayerSave
*****************************************************************/

TYPE t_dist_mov_rec IS RECORD (
    object_id inv_dist_valuation.object_id%TYPE,
    daytime inv_dist_valuation.daytime%TYPE,
    year_code inv_dist_valuation.year_code%TYPE,
    qty1 NUMBER,
    qty2 NUMBER,
    ppa_qty1 NUMBER,
    ppa_qty2 NUMBER,
    ps_qty1 NUMBER,
    ps_qty2 NUMBER,
    ppa_ps_qty1 NUMBER,
    ppa_ps_qty2 NUMBER
);

TYPE t_dist_mov IS TABLE OF t_dist_mov_rec;

FUNCTION GetLocalCurrencyCode(
   p_object_id           VARCHAR2, -- inventory object id
   p_daytime             DATE
   ) RETURN VARCHAR2;

FUNCTION GetStimValueByUOM(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_target_uom		       VARCHAR2
   ) RETURN NUMBER;

FUNCTION GetActualStimPeriodValue(
   p_object_id	         VARCHAR2,
   p_daytime             DATE
   ) RETURN EcDp_Unit.t_uomtable;

FUNCTION GetBookedStimValueByUOM(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_target_uom		       VARCHAR2
   ) RETURN NUMBER;

FUNCTION GetActualPeriodDistMovement(
   p_object_id	         VARCHAR2,
   p_inventory_id        VARCHAR2,
   p_daytime             DATE
   ) RETURN EcDp_Unit.t_uomtable;

FUNCTION GetPhysicalStockDistMovement(p_object_id      VARCHAR2,
                                      p_inventory_id   VARCHAR2,
                                      p_daytime        DATE
                                      )
  RETURN EcDp_Unit.t_uomtable;


FUNCTION GetDistPriorPeriodAdjustment(
   p_object_id	         VARCHAR2,
   p_inventory_id        VARCHAR2,
   p_daytime             DATE
   ) RETURN EcDp_Unit.t_uomtable;


FUNCTION GetDistPriorPeriodPhyStockAdj(p_object_id      VARCHAR2,
                                            p_inventory_id   VARCHAR2,
                                            p_daytime        DATE
                                            )
RETURN EcDp_Unit.t_uomtable;

FUNCTION GetStimBookedProdValueByUOM(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_target_uom		       VARCHAR2
   ) RETURN NUMBER;

FUNCTION GetDistBookedProdYTD(
   p_object_id	         VARCHAR2,
   p_inventory_id        VARCHAR2,
   p_daytime             DATE,
   p_target_uom          VARCHAR2
   ) RETURN NUMBER;

FUNCTION GetDistBookedTotProdMTH(
   p_object_id	         VARCHAR2,
   p_inventory_id        VARCHAR2,
   p_daytime             DATE,
   p_target_uom          VARCHAR2
   ) RETURN NUMBER;

FUNCTION GetInvActTotProdYTD(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_target_uom          VARCHAR2
   ) RETURN NUMBER;

FUNCTION GetDistRateVal(
   p_object_id    IN     VARCHAR2,
   p_inventory_id IN     VARCHAR2,
   p_rate_type    IN     VARCHAR2,
   p_daytime      IN     DATE,
   p_ignore_error BOOLEAN DEFAULT FALSE
   ) RETURN NUMBER;

FUNCTION GetInvAvgRate(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_rate_type           VARCHAR2,
   p_target_uom          VARCHAR2,
   p_ignore_error BOOLEAN DEFAULT FALSE
   ) RETURN NUMBER;

PROCEDURE CalcAvgULRate(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_process_historic    VARCHAR2 DEFAULT 'FALSE',
   p_force_avg_upd       VARCHAR2 DEFAULT 'FALSE'
   );

PROCEDURE CalcDistPosition(
   p_inventory_id        VARCHAR2,
   p_daytime             DATE,
   p_user                VARCHAR2,
   p_process_historic    VARCHAR2 DEFAULT 'FALSE'
   );

PROCEDURE CalcTotalPosition(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_user                VARCHAR2,
   p_process_historic    VARCHAR2 DEFAULT 'FALSE'
   );

PROCEDURE GenMthStaticInvData(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_process_historic    VARCHAR2 DEFAULT 'FALSE'
   );

PROCEDURE InstantiateMth(
   p_object_id	         VARCHAR2,
   p_daytime             DATE
   );

PROCEDURE DeleteInventory(p_object_id      VARCHAR2,
                          p_old_start_date DATE,
                          p_new_start_date DATE,
                          p_old_end_date   DATE,
                          p_new_end_date   DATE);

PROCEDURE ProcessInventory(
    p_object_id          VARCHAR2,
    p_daytime            DATE,
    p_user               VARCHAR2 DEFAULT NULL,
    p_process_historic   VARCHAR2 DEFAULT 'FALSE'
    );

PROCEDURE CreateRelInvDist(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_user                VARCHAR2 DEFAULT NULL
   );

PROCEDURE GenNewRates (
   p_object_id VARCHAR2,
   p_daytime DATE);

PROCEDURE setInventoryStatus(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_doc_level           VARCHAR2,
   p_user                VARCHAR2 DEFAULT NULL
   );

PROCEDURE GenMthBookingData(
   p_object_id           VARCHAR2,
   p_daytime             DATE, -- booking period
   p_user                VARCHAR2
   );

PROCEDURE GenMthReversalBookingData(
   p_object_id           VARCHAR2,
   p_daytime             DATE, -- booking period
   p_user                VARCHAR2
   );

PROCEDURE GenMthAsIsInvData(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_last_run_time       DATE
  );

FUNCTION GetInvMaterialCode(
   p_object_id	         VARCHAR2,
   p_daytime             DATE
   ) RETURN VARCHAR2;

FUNCTION GetMaterialCodeFromSreamItem(
   p_object_id	         VARCHAR2,
   p_daytime             DATE
   ) RETURN VARCHAR2;

PROCEDURE ValidateFxRates(
   p_object_id           VARCHAR2,
   p_daytime             VARCHAR2,
   p_fx_type             VARCHAR2,
   p_mode                VARCHAR2 -- UL or OL
   );

PROCEDURE ValidateInventoryObj(p_ul_pricing_currency_code VARCHAR2,
                               p_ul_booking_currency_code VARCHAR2,
                               p_ul_memo_currency_code    VARCHAR2,
                               p_ol_pricing_currency_code VARCHAR2,
                               p_ol_booking_currency_code VARCHAR2,
                               p_ol_memo_currency_code    VARCHAR2,
                               p_ps_account_mapping       VARCHAR2,
                               p_ps_ind                   VARCHAR2,
                               p_daytime                  DATE);


FUNCTION IsInUnderLift(p_object_id     VARCHAR2,
                       p_daytime       DATE,
                       p_fallback_date DATE DEFAULT NULL) RETURN VARCHAR2;

FUNCTION IsInOverLift(p_object_id     VARCHAR2,
                      p_daytime       DATE,
                      p_fallback_date DATE DEFAULT NULL) RETURN VARCHAR2;

PROCEDURE CheckProduction (
   p_object_id           VARCHAR2,
   p_daytime             DATE
   );

FUNCTION GetEndPriorYear(
   p_object_id           VARCHAR2,
   p_daytime             DATE
   ) RETURN DATE;

FUNCTION GetNewDistRelStatus (
    p_object_id VARCHAR2,
    p_daytime DATE
) RETURN VARCHAR2;

PROCEDURE CheckDistRelations (
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_user                VARCHAR2
   );

FUNCTION GetCostElementBW(
   p_object_id           VARCHAR2,
   p_dist_obj_id         VARCHAR2,
   p_daytime             DATE
   ) RETURN VARCHAR2;

FUNCTION GetMarginOrderBW(
   p_object_id           VARCHAR2,
   p_dist_obj_id         VARCHAR2,
   p_daytime             DATE
   ) RETURN VARCHAR2;

FUNCTION GetProductCodeBW(
   p_fin_material_code   VARCHAR2,
   p_daytime             DATE
   ) RETURN VARCHAR2;

FUNCTION GetYTDProductionIfFG(p_object_id VARCHAR2, p_daytime DATE, p_dist_id VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;

FUNCTION GetStimPriorPeriodAdjustment (
   p_object_id           VARCHAR2,
   p_daytime             DATE  -- the daytime to calculate the ppa for
   ) RETURN EcDp_Unit.t_uomtable;

FUNCTION GetSIPYAByUOM (
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom                 VARCHAR2
   ) RETURN NUMBER;

PROCEDURE WriteAvgRate(p_object_id VARCHAR2,
                       p_daytime   DATE,
                       p_rate      NUMBER,
                       p_user      VARCHAR2);


FUNCTION GetPositionAvgRate(p_object_id VARCHAR2, p_daytime DATE)
  RETURN NUMBER;

PROCEDURE ConfigureReport(p_object_id            VARCHAR2,
                          p_daytime              VARCHAR2,
                          p_report_definition_no NUMBER);

PROCEDURE ValidateReportBeforeGenerate(p_inventory_id         VARCHAR2,
                                       p_daytime              VARCHAR2,
                                       p_report_definition_no VARCHAR2);

FUNCTION IsAttributeEditable(
  p_object_id      VARCHAR2,
  p_daytime        DATE,
  p_attribute_name VARCHAR2
  ) RETURN VARCHAR2;


PROCEDURE SetStimMthInvHistoric
  (p_object_id VARCHAR2,
   p_daytime   DATE,
   p_user_id   VARCHAR2);

PROCEDURE SetInvLayerHistoric
  (p_object_id VARCHAR2,
   p_daytime   DATE,
   p_user_id   VARCHAR2);


PROCEDURE RemoveStimMthInvHistoric
  (p_object_id VARCHAR2, -- Inventory ID
   p_daytime   DATE,
   p_user_id   VARCHAR2);

   PROCEDURE ProcessHistoricInventory
  (p_object_id VARCHAR2, -- Inventory ID
   p_daytime   DATE,
   p_user_id   VARCHAR2);

FUNCTION IsValuationNotRun(
  p_object_id      VARCHAR2,
  p_historic       VARCHAR2 DEFAULT 'FALSE',
  p_physical_stock VARCHAR2 DEFAULT 'FALSE'
  ) RETURN VARCHAR2;

PROCEDURE CheckLayerSave(
  p_object_id      VARCHAR2,
  p_daytime        DATE,
  p_overlift       VARCHAR2 default 'FALSE');

PROCEDURE VerifyLayer(p_inv_position VARCHAR2
                     ,p_object_id VARCHAR2
                     ,p_daytime DATE
                     ,p_qty1 NUMBER
                     ,p_qty2 NUMBER
                     ,p_rate NUMBER
                     ,p_pricing_value NUMBER
                     ,p_level VARCHAR2);

PROCEDURE ProcessInvLayer(p_object_id VARCHAR2
                         ,p_daytime DATE
                         ,p_call_tag VARCHAR2
                         ,p_valuation_method VARCHAR2
                         ,p_opening_qty1 NUMBER
                         ,p_opening_qty2 NUMBER
                         ,p_ytd_movement_qty1 NUMBER
                         ,p_ytd_movement_qty2 NUMBER
                         ,p_ytd_ps_mov_qty1 NUMBER
                         ,p_ytd_ps_mov_qty2 NUMBER
                         ,p_ul_rate NUMBER
                         ,p_ol_rate NUMBER
                         ,p_ps_rate NUMBER
                         ,p_user VARCHAR2
                         ,p_process_historic VARCHAR2)
;

FUNCTION getLayerDistValue(p_value NUMBER,
                           p_code VARCHAR2,
                           p_object_id VARCHAR2,
                           p_dist_id VARCHAR2,
                           p_daytime DATE
                          )
RETURN NUMBER;

FUNCTION GetPpaLayer(p_object_id VARCHAR2, p_daytime DATE, p_movement_qty NUMBER, p_dist_id VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION GetFinInterfaceFile(p_object_id VARCHAR2, p_daytime DATE, p_year_code VARCHAR2)
RETURN VARCHAR2;

PROCEDURE CalcPricingValue(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2);

PROCEDURE CalcCurrencyValues(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2);

PROCEDURE ProcessInvDistLayer(p_object_id VARCHAR2
                         ,p_daytime DATE
                         ,p_year_code VARCHAR2
                         ,p_ytd_movement_qty1 NUMBER
                         ,p_call_tag VARCHAR2
                         ,p_user VARCHAR2
                         ,p_valuation_method VARCHAR2
                         ,p_process_historic VARCHAR2
                         ,p_used_whole_layer BOOLEAN)
;

PROCEDURE PopulateUOM(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2);

PROCEDURE PopulateCurrencies(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2);

FUNCTION GetInventoryValue(p_object_id VARCHAR2, p_daytime DATE, p_attribute VARCHAR2) RETURN NUMBER;

FUNCTION GetInventoryBusinessUnitID(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

PROCEDURE ValidateInventory(p_object_id VARCHAR2,
                            p_daytime DATE);

FUNCTION GetFormatString(p_string VARCHAR2) RETURN VARCHAR2;

END Ecdp_Inventory;