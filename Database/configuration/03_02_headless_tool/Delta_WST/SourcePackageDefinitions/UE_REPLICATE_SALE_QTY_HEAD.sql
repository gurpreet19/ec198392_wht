CREATE OR REPLACE PACKAGE UE_Replicate_Sale_Qty IS
/****************************************************************
** Package        :  UE_Replicate_Sale_Qty
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  23.09.2015  Arvid Gjosaeter
**
** Modification history:
**
** Date        Whom  		Change description:
** ------      ----- 		-----------------------------------------------------------------------------------------------
******************************************************************/

isQtyUOMMappingUEE VARCHAR2(32) := 'FALSE';
isQtyValueMappingUEE VARCHAR2(32) := 'FALSE';
isFinalAccrualDocUEE VARCHAR2(32) := 'FALSE';
isinsertSalesQtyUEE VARCHAR2(32) := 'FALSE';
isIFAC_TRANSACTION_LEVELUEE VARCHAR2(32) := 'FALSE';
isIFAC_PROFIT_CENTRE_LEVELUEE VARCHAR2(32) := 'FALSE';
isIFAC_COMPANY_LEVELUEE VARCHAR2(32) := 'FALSE';
isinsertIFAC_PC_CPY_QtyUEE VARCHAR2(32) := 'FALSE';
isPriceStatusUEE VARCHAR2(32) := 'FALSE';
isGetIfacRecordPriceObjectUEE VARCHAR2(32) := 'FALSE';

FUNCTION ue_QtyUOMMapping(
                        p_mapping_value     VARCHAR2,
                        p_vol_uom           VARCHAR2,
                        p_mass_uom          VARCHAR2,
                        p_energy_uom        VARCHAR2,
                        p_x1_uom            VARCHAR2,
                        p_x2_uom            VARCHAR2,
                        p_x3_uom            VARCHAR2) RETURN VARCHAR2;

FUNCTION ue_QtyValueMapping(
                        p_mapping_value     VARCHAR2,
                        p_vol_qty           NUMBER DEFAULT NULL,
                        p_mass_qty          NUMBER DEFAULT NULL,
                        p_energy_qty        NUMBER DEFAULT NULL,
                        p_x1_qty            NUMBER DEFAULT NULL,
                        p_x2_qty            NUMBER DEFAULT NULL,
                        p_x3_qty            NUMBER DEFAULT NULL ) RETURN NUMBER;

PROCEDURE ue_insertSalesQty(
                        p_class_name        VARCHAR2,
                        p_object_id         VARCHAR2,
                        p_account_code      VARCHAR2,
                        p_profit_centre_id  VARCHAR2,
                        p_company_id        VARCHAR2,
                        p_time_span         VARCHAR2,
                        p_daytime           DATE,
                        p_vol_qty           NUMBER,
                        p_mass_qty          NUMBER,
                        p_energy_qty        NUMBER,
                        p_user              VARCHAR2,
                        p_doc_status        VARCHAR2
);

PROCEDURE ue_IFAC_TRANSACTION_LEVEL(
                        p_class_name        VARCHAR2,
                        p_object_id         VARCHAR2,
                        p_account_code      VARCHAR2,
                        p_time_span         VARCHAR2,
                        p_daytime           DATE,
                        p_vol_qty           NUMBER,
                        p_mass_qty          NUMBER,
                        p_energy_qty        NUMBER,
                        p_user              VARCHAR2,
                        p_doc_status        VARCHAR2
);

PROCEDURE ue_IFAC_PROFIT_CENTRE_LEVEL(
                        p_class_name        VARCHAR2,
                        p_object_id         VARCHAR2,
                        p_account_code      VARCHAR2,
                        p_profit_centre_id  VARCHAR2,
                        p_time_span         VARCHAR2,
                        p_daytime           DATE,
                        p_vol_qty           NUMBER,
                        p_mass_qty          NUMBER,
                        p_energy_qty        NUMBER,
                        p_user              VARCHAR2,
                        p_doc_status        VARCHAR2
);

PROCEDURE ue_IFAC_COMPANY_LEVEL(
                        p_class_name        VARCHAR2,
                        p_object_id         VARCHAR2,
                        p_account_code      VARCHAR2,
                        p_profit_centre_id  VARCHAR2,
                        p_vendor_id         VARCHAR2,
                        p_time_span         VARCHAR2,
                        p_daytime           DATE,
                        p_vol_qty           NUMBER,
                        p_mass_qty          NUMBER,
                        p_energy_qty        NUMBER,
                        p_user              VARCHAR2,
                        p_doc_status        VARCHAR2
);

PROCEDURE ue_insertIFAC_PC_CPY_Qty(
                        p_class_name        VARCHAR2,
                        p_object_id         VARCHAR2,
                        p_account_code      VARCHAR2,
                        p_profit_centre_id  VARCHAR2,
                        p_vendor_id         VARCHAR2,
                        p_party_share       VARCHAR2,
                        p_time_span         VARCHAR2,
                        p_daytime           DATE,
                        p_vol_qty           NUMBER,
                        p_mass_qty          NUMBER,
                        p_energy_qty        NUMBER,
                        p_user              VARCHAR2,
                        p_doc_status        VARCHAR2
);

FUNCTION ue_FinalAccrualDoc(
                        p_class_name        VARCHAR2,
                        p_object_id         VARCHAR2,
                        p_account_code      VARCHAR2,
                        p_profit_centre_id  VARCHAR2,
                        p_vendor_id         VARCHAR2,
                        p_party_share       VARCHAR2,
                        p_time_span         VARCHAR2,
                        p_daytime           DATE,
                        p_vol_qty           NUMBER,
                        p_mass_qty          NUMBER,
                        p_energy_qty        NUMBER,
                        p_user              VARCHAR2,
                        p_doc_status        VARCHAR2) RETURN VARCHAR2;

FUNCTION ue_PriceStatus(p_class_name        VARCHAR2,
                        p_object_id         VARCHAR2,
                        p_account_code      VARCHAR2,
                        p_profit_centre_id  VARCHAR2,
                        p_vendor_id         VARCHAR2,
                        p_party_share       VARCHAR2,
                        p_time_span         VARCHAR2,
                        p_daytime           DATE,
                        p_vol_qty           NUMBER,
                        p_mass_qty          NUMBER,
                        p_energy_qty        NUMBER,
                        p_user              VARCHAR2,
                        p_doc_status        VARCHAR2)  RETURN VARCHAR2;

FUNCTION ue_GetIfacRecordPriceObject(
                        p_contract_id        VARCHAR2,
                        p_product_id         VARCHAR2,
                        p_price_concept_code VARCHAR2,
                        p_quantity_status    VARCHAR2,
                        p_price_status       VARCHAR2,
                        p_daytime            DATE,
                        p_uom_code           VARCHAR2 DEFAULT NULL)RETURN VARCHAR2;


END UE_Replicate_Sale_Qty;