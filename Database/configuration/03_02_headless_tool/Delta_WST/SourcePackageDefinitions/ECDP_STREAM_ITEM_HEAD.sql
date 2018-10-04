CREATE OR REPLACE PACKAGE EcDp_Stream_Item IS
/********************************************************************************************************************************
** Package        :  EcDp_StreamItem, header part
**
** $Revision: 1.64 $
**
** Purpose        :  Provide special functions on Stream_Item. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.07.2002  Henning Stokke
**
** Modification history:
**
** Date         Whom  Change description:
** ----------   ----- --------------------------------------
** 20.08.2006   sra   Initial version on 9.1
** 09.01.2007   seongkok   Added new procedures checkExistedStim, checkRedundantStim, checkIsInStim, checkForecaseCaseStim and checkForecastCaseAdjStim
*********************************************************************************************************************************/


-- use this record type to return conversion factors with FROM / TO UOM
TYPE t_conversion IS RECORD
  (
     factor   NUMBER,
	 from_uom VARCHAR2(32),
	 to_uom   VARCHAR2(32),
	 source VARCHAR2(200),
   source_object_id varchar2(32)
  );

TYPE t_siv_net IS RECORD
  (
   net_volume_value NUMBER,
   volume_uom_code  VARCHAR2(32),
   net_mass_value   NUMBER,
   mass_uom_code    VARCHAR2(32),
   net_energy_value NUMBER,
   energy_uom_code  VARCHAR2(32),
   net_extra1_value NUMBER,
   extra1_uom_code  VARCHAR2(32),
   net_extra2_value NUMBER,
   extra2_uom_code  VARCHAR2(32),
   net_extra3_value NUMBER,
   extra3_uom_code  VARCHAR2(32)
  );

TYPE t_net_sub_uom IS RECORD
  (
    NET_ENERGY_JO	NUMBER	,
    NET_ENERGY_TH	NUMBER	,
    NET_ENERGY_WH	NUMBER	,
    NET_ENERGY_BE NUMBER  ,
    NET_MASS_MA	  NUMBER	,
    NET_MASS_MV	  NUMBER	,
    NET_MASS_UA	  NUMBER	,
    NET_MASS_UV	  NUMBER	,
    NET_VOLUME_BI	NUMBER	,
    NET_VOLUME_BM	NUMBER	,
    NET_VOLUME_SF	NUMBER	,
    NET_VOLUME_NM	NUMBER	,
    NET_VOLUME_SM	NUMBER
  );

TYPE t_stim_rec IS RECORD (
    object_id stim_day_value.object_id%TYPE,
    mass_uom_code stim_day_value.mass_uom_code%TYPE,
    volume_uom_code stim_day_value.volume_uom_code%TYPE,
        energy_uom_code stim_day_value.energy_uom_code%TYPE,
    extra1_uom_code stim_day_value.extra1_uom_code%TYPE,
    extra2_uom_code stim_day_value.extra2_uom_code%TYPE,
    extra3_uom_code stim_day_value.extra3_uom_code%TYPE,
    master_uom_group stream_item_version.master_uom_group%TYPE,
    conversion_method stream_item_version.conversion_method%TYPE,
    use_mass_ind stream_item_version.use_mass_ind%TYPE,
    use_volume_ind stream_item_version.use_volume_ind%TYPE,
    use_energy_ind stream_item_version.use_energy_ind%TYPE,
    use_extra1_ind stream_item_version.use_extra1_ind%TYPE,
    use_extra2_ind stream_item_version.use_extra2_ind%TYPE,
    use_extra3_ind stream_item_version.use_extra3_ind%TYPE
);

TYPE t_stim IS TABLE OF t_stim_rec;

-- Function that returns an indicator (parent, parentnochild, child or none) of the field that
-- is connected to a specified stream_item.

FUNCTION GetProductCodeLabel(
   p_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_daytime   DATE
)

RETURN VARCHAR2;

FUNCTION GetNWIObjectId(
   p_object_id	         VARCHAR2,
   p_daytime             DATE
      )
RETURN VARCHAR2;

FUNCTION GetParentChildFieldIndicator(
   p_object_id         VARCHAR2,
   p_field_object_id   VARCHAR2,
   p_daytime           DATE,
   p_SIC_OBJECT_ID     VARCHAR2 DEFAULT NULL,
   p_product_object_id VARCHAR2 DEFAULT NULL,
   p_company_object_id VARCHAR2 DEFAULT NULL
)

RETURN VARCHAR2;

FUNCTION GetMthQtyByUOM(
   p_object_id	         VARCHAR2,
   p_uom_code            VARCHAR2,
   p_daytime             DATE,
   p_allow_null          VARCHAR2 DEFAULT 'N')
RETURN NUMBER;

FUNCTION GetMthMasterQty(
   p_object_id	         VARCHAR2,
   p_daytime             DATE
      )
RETURN NUMBER;

FUNCTION GetMthMasterUom(
   p_object_id	         VARCHAR2,
   p_daytime             DATE
      )
RETURN VARCHAR2;

FUNCTION GetDayMasterQty(
   p_object_id	         VARCHAR2,
   p_daytime             DATE
      )
RETURN NUMBER;

FUNCTION GetDayMasterUom(
   p_object_id	         VARCHAR2,
   p_daytime             DATE
      )
RETURN VARCHAR2;

FUNCTION GetMthPlanVol(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2
)

RETURN NUMBER;

FUNCTION GetMthPlanMass(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2)

RETURN NUMBER;

FUNCTION GetMthPlanEnergy(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2)

RETURN NUMBER;

FUNCTION GetMthPlanExtra1(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2)

RETURN NUMBER;

FUNCTION GetMthPlanExtra2(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2)

RETURN NUMBER;

FUNCTION GetMthPlanExtra3(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2)

RETURN NUMBER;
FUNCTION GenDayAccrual(
   p_object_id VARCHAR2, -- The stream which the procedure should run for
   p_daytime DATE, -- Date to run for
   p_type VARCHAR2,
   p_user VARCHAR2
) RETURN VARCHAR2;

FUNCTION GetDayAccrualVol(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;

FUNCTION GetDayAccrualMass(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;

FUNCTION GetDayAccrualEnergy(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;

FUNCTION GetDayAccrualExtra1(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;

FUNCTION GetDayAccrualExtra2(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;

FUNCTION GetDayAccrualExtra3(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;

FUNCTION GenMthAccrual(
   p_object_id VARCHAR2, -- The list object_id which the procedure should run for
   p_daytime DATE, -- Date to run for
   p_type VARCHAR2,
   p_user VARCHAR2
) RETURN VARCHAR2;

FUNCTION GetMthAccrualVol(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;

FUNCTION GetMthAccrualMass(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;


FUNCTION GetMthAccrualEnergy(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;

FUNCTION GetMthAccrualExtra1(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;

FUNCTION GetMthAccrualExtra2(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;

FUNCTION GetMthAccrualExtra3(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER;

FUNCTION GetMthAccrualFromDays(
   p_object_id	         VARCHAR2,
   p_daytime             DATE, -- The month which days should be calculated from
   p_uom_code            VARCHAR2
)
RETURN NUMBER;

FUNCTION GetMthAccrualTextFromDays(
   p_object_id	         VARCHAR2,
   p_daytime             DATE, -- The month which days should be calculated from
   p_uom_code            VARCHAR2
)
RETURN VARCHAR2;

FUNCTION isCalcMethodEditable(
   p_calc_method      VARCHAR2
) RETURN varchar2;

FUNCTION isStreamItemEditable(
   p_object_id        VARCHAR2,
   p_daytime          DATE,
   p_attribute_name   VARCHAR2,
   p_calc_method      VARCHAR2
) RETURN VARCHAR2;

FUNCTION GetSplitShareDay(
   p_object_id VARCHAR2,
   p_daytime   DATE
) RETURN NUMBER;

FUNCTION GetSplitShareMth(
   p_object_id VARCHAR2,
   p_daytime   DATE
) RETURN NUMBER;



FUNCTION GetDefDensity(
   p_object_id           VARCHAR2,
   p_daytime             DATE
)
RETURN t_conversion;

FUNCTION GetDefGCV(
   p_object_id           VARCHAR2,
   p_daytime             DATE
)
RETURN t_conversion;

FUNCTION GetDefMCV(
   p_object_id           VARCHAR2,
   p_daytime             DATE
)
RETURN t_conversion;


FUNCTION GetDefBOE(p_object_id VARCHAR2, p_daytime DATE)

 RETURN t_conversion;

FUNCTION GetSubGroupValue(
   pr_stim_mth_value   stim_mth_value%ROWTYPE,
   p_uom_group   VARCHAR2,
   p_uom_subgroup VARCHAR2
   )
RETURN NUMBER;

FUNCTION GetBOEUnitValue(p_object_id         VARCHAR2,
                         p_daytime           DATE,
                         p_net_value         NUMBER,
                         p_uom_code          VARCHAR2,
                         p_boe_from_uom_code VARCHAR2,
                         p_boe_to_uom_code   VARCHAR2,
                         p_boe_factor        NUMBER)

 RETURN NUMBER;

FUNCTION GetBOEValue(pr_stim_mth_value stim_mth_value%ROWTYPE)
RETURN NUMBER;

FUNCTION GetBOEStimValue(p_object_id         VARCHAR2,
                         p_daytime           DATE,
                         p_net_volume_value  NUMBER,
                         p_volume_uom_code   VARCHAR2,
                         p_net_mass_value    NUMBER,
                         p_mass_uom_code     VARCHAR2,
                         p_net_energy_value  NUMBER,
                         p_energy_uom_code   VARCHAR2,
                         p_net_extra1_value  NUMBER,
                         p_extra1_uom_code   VARCHAR2,
                         p_net_extra2_value  NUMBER,
                         p_extra2_uom_code   VARCHAR2,
                         p_net_extra3_value  NUMBER,
                         p_extra3_uom_code   VARCHAR2,
                         p_boe_from_uom_code VARCHAR2,
                         p_boe_to_uom_code   VARCHAR2,
                         p_boe_factor        NUMBER)
  RETURN NUMBER;


FUNCTION getBOEInvertUnitValue(p_object_id         VARCHAR2,
                               p_daytime           DATE,
                               p_net_value         NUMBER,
                               p_uom               VARCHAR2,
                               p_boe_from_uom_code VARCHAR2,
                               p_boe_to_uom_code   VARCHAR2,
                               p_boe_factor        NUMBER) RETURN NUMBER;

FUNCTION GetPerBookedCrudeSaleVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;
FUNCTION GetPerBookedCrudeSaleVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerBookedGasSaleVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerBookedCrudePurchVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;
FUNCTION GetPerBookedCrudePurchVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerBookedGasPurchVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerBookedCrudeVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerBookedCrudeVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerBookedGasVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerReportedCrudeSaleVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerReportedCrudeSaleVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerReportedGasSaleVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerReportedCrudePurchVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerReportedCrudePurchVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerReportedGasPurchVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerReportedCrudeVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerReportedCrudeVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION GetPerReportedGasVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   ) RETURN NUMBER;

FUNCTION SumDayPeriodVol(
   p_object_id VARCHAR2,
   p_from_daytime DATE,
   p_to_daytime DATE,
   p_to_uom_code VARCHAR2
) RETURN NUMBER;

FUNCTION SumPrevMthAsIsVol(
   p_object_id VARCHAR2,
   p_daytime DATE,
   p_to_uom_code VARCHAR2
) RETURN NUMBER;

FUNCTION SumYTDAsIsVol(
   p_object_id VARCHAR2,
   p_daytime DATE,
   p_to_uom_code VARCHAR2
) RETURN NUMBER;

FUNCTION GetProductFromSI(
   p_object_id VARCHAR2,
   p_daytime DATE
   ) RETURN VARCHAR2;

PROCEDURE InsGenPeriodFromSIList(
   p_list_id             VARCHAR2,
   p_start_date          DATE,
   p_end_date            DATE,
   p_period_type         VARCHAR2
);

PROCEDURE UpdAddToSIValueMth(
   p_object_id             VARCHAR2,
   p_daytime               DATE,
   ptab_uom_set            EcDp_Unit.t_uomtable,
   p_status                VARCHAR2,
   p_user                  VARCHAR2,
   p_upd_flag              VARCHAR2 DEFAULT 'ADD_INCR', -- use REPLACE to set new values, ADD_INCR to add to existing
   p_reverse_factor        NUMBER DEFAULT 1,
   p_do_delete             BOOLEAN DEFAULT TRUE,
   p_contract_id           VARCHAR2 DEFAULT NULL,
   p_alloc_no              NUMBER DEFAULT NULL,
   p_vendor_id             VARCHAR2 DEFAULT NULL,
   p_delivery_point_id     VARCHAR2 DEFAULT NULL,
   p_price_concept_code    VARCHAR2 DEFAULT NULL,
   p_cargo_name            VARCHAR2 DEFAULT NULL,
   p_parcel_name           VARCHAR2 DEFAULT NULL,
   p_qty_type              VARCHAR2 DEFAULT NULL,
   p_is_cascade_scheduled  VARCHAR2 DEFAULT 'N'
);

PROCEDURE UpdAddToSIValueDay(
   p_object_id             VARCHAR2,
   p_daytime             DATE,
   ptab_uom_set          EcDp_Unit.t_uomtable,
   p_status              VARCHAR2,
   p_user                VARCHAR2,
   p_upd_flag            VARCHAR2 DEFAULT 'ADD_INCR' -- use REPLACE to set new values, ADD_INCR to add to existing
);

PROCEDURE ImportSIValueMth(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   ptab_uom_set          EcDp_Unit.t_uomtable,
   p_status              VARCHAR2,
   p_user                VARCHAR2,
   p_upd_flag            VARCHAR2 DEFAULT 'ADD_INCR',
   p_reverse_factor      NUMBER DEFAULT 1
);

PROCEDURE ImportSIValueDay(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   ptab_uom_set          EcDp_Unit.t_uomtable,
   p_status              VARCHAR2,
   p_user                VARCHAR2,
   p_upd_flag            VARCHAR2 DEFAULT 'ADD_INCR'
);

FUNCTION GetUOMGroup(
   p_uom VARCHAR2)
RETURN VARCHAR2;

PROCEDURE GenMthAsBookedStaticData(
   p_daytime             DATE,
   p_last_run_time       DATE
);

PROCEDURE GenMthAsReportedStaticData(
   p_daytime             DATE,
   p_last_run_time       DATE
);

PROCEDURE GenMthAsIsStaticData(
   p_daytime             DATE,
   p_last_run_time       DATE
);

-- PROCEDURE GenMthStaticData;

PROCEDURE DelEmptyGenPeriod;
/*
PROCEDURE GenPeriodMth(
   p_stim_gen_period_rec stim_period_gen_value%ROWTYPE
);

PROCEDURE GenPeriodDay(
   p_stim_gen_period_rec stim_period_gen_value%ROWTYPE
);
*/
PROCEDURE InstantiateVO(
  p_daytime DATE,
  p_company_id VARCHAR2 DEFAULT NULL,
  p_object_list VARCHAR2 DEFAULT NULL,
  p_type VARCHAR2
);

PROCEDURE InstantiateDay(
   p_daytime DATE,
   p_company_id VARCHAR2 DEFAULT NULL,
   p_si_object_id VARCHAR2 DEFAULT NULL
);

PROCEDURE InstantiateNextVO(
  p_company_id VARCHAR2 DEFAULT NULL,
  p_object_list VARCHAR2 DEFAULT NULL,
  p_type VARCHAR2
);

PROCEDURE InstantiateNextDay(p_company_id VARCHAR2 DEFAULT NULL);

PROCEDURE InstantiateAllVO(
  p_start_date DATE,
  p_end_date DATE,
  p_company_id VARCHAR2 DEFAULT NULL,
  p_object_list VARCHAR2 DEFAULT NULL,
  p_type VARCHAR2
);

PROCEDURE InstantiateDays(p_start_date DATE,
p_end_date DATE,
p_company_id VARCHAR2 DEFAULT NULL);

PROCEDURE InstantiateMth(
   p_daytime DATE,
   p_company_id VARCHAR2 DEFAULT NULL,
   p_si_object_id VARCHAR2 DEFAULT NULL
);

PROCEDURE InstantiateNextMth(p_company_id VARCHAR2 DEFAULT NULL);

PROCEDURE InstantiateMths(p_start_date DATE,
          p_end_date DATE,
   		  p_company_id VARCHAR2 DEFAULT NULL);

PROCEDURE InstantiatePeriodDay(p_start_date DATE,
   p_end_date   DATE
);

PROCEDURE InstantiatePeriodMth(
   p_start_date DATE,
   p_end_date   DATE
);

PROCEDURE UpdateSplitKeyMth(
   p_object_id VARCHAR2,
   p_daytime DATE
);

PROCEDURE UpdateSplitKeyDay(
   p_object_id VARCHAR2,
   p_daytime DATE
);

PROCEDURE UpdateSplitKey(p_object_id             VARCHAR2,
                         p_business_function_url VARCHAR2,
                         p_daytime               DATE,
                         p_user_id               VARCHAR2,
                         p_stim_pending_no       NUMBER DEFAULT NULL,
                         p_stream_item_id        VARCHAR2 DEFAULT NULL);

PROCEDURE UpdateConversionFactor(p_object_id             VARCHAR2, -- Either Country, Field or Node object_id or relation object_id
                                 p_business_function_url VARCHAR2,
                                 p_daytime               VARCHAR2, -- The daytime to run the update for
                                 p_end_date              VARCHAR2, -- The end_date for the conversion factors
                                 p_user                  VARCHAR2,
                                 p_stim_pending_no       NUMBER DEFAULT NULL);


PROCEDURE UpdateBOEConversionFactor(p_object_id             VARCHAR2,
                                    p_business_function_url VARCHAR2,
                                    p_daytime               VARCHAR2,
                                    p_end_date              VARCHAR2,
                                    p_user                  VARCHAR2,
                                    p_stim_pending_no       NUMBER DEFAULT NULL);



PROCEDURE UpdateSTIMConversionFactor(
   p_object_id VARCHAR2, -- Stream_Item object_id
   p_daytime DATE, -- The daytime to run the update for
   p_type VARCHAR2, -- Either DAY or MTH
   p_user VARCHAR2,
   p_forecast_id VARCHAR2 DEFAULT NULL
);

PROCEDURE UpdateListStrmConversionFactor(
   p_object_id VARCHAR2, -- List object_id or Stream object_id
   p_daytime DATE, -- The daytime to run the update for
   p_type VARCHAR2, -- Either DAY or MTH
   p_user VARCHAR2
);

FUNCTION GetConvValue (
   p_object_id VARCHAR2,  -- STREAM_ITEM object_id
   p_daytime DATE, -- Date to process for
   p_type VARCHAR2, -- DAY or MTH
   p_group VARCHAR2, -- M V or E
   p_to_uom VARCHAR2
) RETURN NUMBER;

PROCEDURE Validate_Stream_Item -- validate a stream item prior to committing save
(  p_object_id VARCHAR2,
   p_daytime  DATE
);

PROCEDURE DelStreamItem(
   p_object_id VARCHAR2,
   p_daytime   DATE DEFAULT NULL,
   p_user      VARCHAR2 DEFAULT NULL
);

PROCEDURE CleanUpStreamItem(
    p_object_id VARCHAR2,
    p_clean_up_cm VARCHAR2, -- CALC_METHOD
    p_clean_up_sk VARCHAR2, -- SPLIT_KEY
    p_daytime DATE,
    p_user VARCHAR2
);


Function crossGroupUnitConvert(
  p_si_object_id varchar2 ,
  p_daytime date,
  p_from_group varchar2,
  p_from_uom varchar2,
  p_to_group varchar2,
  p_to_uom varchar2,
  p_value number)

RETURN NUMBER;


PROCEDURE SetSIParentFieldIndicator(
   p_si_object_id  VARCHAR2,
   p_daytime       DATE,
   p_user          VARCHAR2
   );


PROCEDURE checkExistedStim(
   p_object_id       IN VARCHAR2,
   p_product_id      IN VARCHAR2,
   p_product_context IN VARCHAR2);


PROCEDURE checkRedundantStim(
   p_object_id       IN VARCHAR2,
   p_product_id      IN VARCHAR2,
   p_stream_item_id  IN VARCHAR2,
   p_product_context IN VARCHAR2);


PROCEDURE checkIsInStim(
   p_flag			 IN VARCHAR2,
   p_object_id       IN VARCHAR2,
   p_product_id      IN VARCHAR2,
   p_stream_item_id  IN VARCHAR2,
   p_product_context IN VARCHAR2);


PROCEDURE checkForecastCaseStim(
   p_object_id       IN VARCHAR2,
   p_product_id      IN VARCHAR2,
   p_stream_item_id  IN VARCHAR2,
   p_product_context IN VARCHAR2);


PROCEDURE checkForecastCaseAdjStim(
   p_object_id       IN VARCHAR2,
   p_product_id      IN VARCHAR2,
   p_stream_item_id  IN VARCHAR2,
   p_product_context IN VARCHAR2);

PROCEDURE run_status_process(p_process_id VARCHAR2,
                      p_from_daytime DATE,
                      p_to_daytime DATE DEFAULT NULL,
                      p_field_group_id VARCHAR2,
                      p_user_id VARCHAR2 DEFAULT NULL);

FUNCTION GetNode(
  p_where VARCHAR2, -- FROM_NODE, TO_NODE or AT_NODE
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_attribute VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

PROCEDURE checkUniqueQtyFcstCase(
   p_object_id       VARCHAR2,
   p_product_id      VARCHAR2,
   p_product_context VARCHAR2,
   p_sort_order      NUMBER);

FUNCTION GetStimDeltaValue(
  p_new_value NUMBER,
  p_old_value NUMBER,
  p_delta_value NUMBER,
  p_sum_prior_delta_value NUMBER
  )
RETURN NUMBER;

PROCEDURE updateStreamItem(p_object_id             VARCHAR2,
                           p_start_date            DATE,
                           p_business_function_url VARCHAR2,
                           p_user                  VARCHAR2,
                           p_end_date              DATE DEFAULT NULL,
                           p_stim_pending_no       NUMBER DEFAULT NULL);


FUNCTION GenStreamItemCopy(
   p_object_id VARCHAR2, -- to copy from
   p_code      VARCHAR2)
RETURN VARCHAR2; -- new stream item object_id

PROCEDURE populateSIFormula(
   p_calc_method VARCHAR2, -- SK or FO
   p_daytime     DATE,
   p_user        VARCHAR2,
   p_stream_item_id VARCHAR2 DEFAULT NULL -- If you want to do this on only one SI
   );

PROCEDURE IsIntergroupConversionValid(p_density            NUMBER,
                                     p_density_mass_uom   VARCHAR2,
                                     p_density_volume_uom VARCHAR2,
                                     p_gcv                NUMBER,
                                     p_gcv_energy_uom     VARCHAR2,
                                     p_gcv_volume_uom     VARCHAR2,
                                     p_mcv                NUMBER,
                                     p_mcv_energy_uom     VARCHAR2,
                                     p_mcv_mass_uom       VARCHAR2);



PROCEDURE populateFcstSIFormula(p_object_id           VARCHAR2,
                                p_forecast_id         VARCHAR2,
                                p_daytime             DATE,
                                p_user                VARCHAR2);

PROCEDURE updateStimFcstFormula(p_object_id      VARCHAR2,
                                p_stream_item_id VARCHAR2,
                                p_forecast_id    VARCHAR2,
                                p_daytime          DATE,
                                p_user           VARCHAR2);

PROCEDURE updAccrualToFinal(p_object_id     VARCHAR2,
                           p_daytime        DATE,
                           p_type           VARCHAR2,
                           p_user           VARCHAR2);

FUNCTION GetConversionFactorValue(p_object_id VARCHAR2,
                                  p_daytime   DATE,
                                  p_type      VARCHAR2) RETURN NUMBER;
FUNCTION GetConversionFactorUom(p_object_id VARCHAR2,
                                p_daytime   DATE,
                                p_type      VARCHAR2,
                                p_subtype   VARCHAR2) RETURN VARCHAR2;
FUNCTION getConversionFactorValue(p_stream_item_id VARCHAR2,
                                  p_source_id VARCHAR2, p_daytime DATE,
                                  p_source_type VARCHAR2, p_value NUMBER)
  RETURN NUMBER;
FUNCTION getConversionFactorUOM(p_stream_item_id VARCHAR2,
                                p_source_id VARCHAR2, p_daytime DATE,
                                p_source_type VARCHAR2, p_value NUMBER,
                                p_uom_type VARCHAR) RETURN VARCHAR2;
FUNCTION getConversionFactorSourceId(p_stream_item_id VARCHAR2,
                                     p_source_id VARCHAR2, p_daytime DATE,
                                     p_source_type VARCHAR2, p_value NUMBER)
  RETURN VARCHAR2;

PROCEDURE InsertUpdateIUCVersion(p_class_name VARCHAR2,
                           p_object_id  VARCHAR2,
                           p_daytime    DATE,
                           p_user       VARCHAR2);

PROCEDURE InsertUpdateIUCFieldVersion(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2);
PROCEDURE InsertUpdateIUCNodeVersion(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2);
PROCEDURE InsertUpdateIUCCountryVersion(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2);

FUNCTION getNodeId(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION ApplyRounding(p_value NUMBER, p_rounding NUMBER) RETURN NUMBER;

FUNCTION GetSplitShareMthPC(p_split_key VARCHAR2,
                            p_source_member_id VARCHAR2,
                            p_processing_period DATE)
RETURN NUMBER;

END EcDp_Stream_Item;