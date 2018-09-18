CREATE OR REPLACE PACKAGE BODY UE_Replicate_Sale_Qty IS
/****************************************************************
** Package        :  UE_Replicate_Sale_Qty
**
** $Revision: 1.10 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  19.04.2006  Jean Ferre
**
** Modification history:
**
** Date        Whom  		Change description:
** ------      ----- 		-----------------------------------------------------------------------------------------------
** 19.04.2006  Jean Ferre  Initial version
** 11.05.2006 	KSN			Rewrite
******************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : ue_insertSalesQty
-- Description    : Inserting sales quantities to ecrevenue interface ifac_sales_qty
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
---------------------------------------------------------------------------------------------------
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
)
IS

BEGIN
  --Test
  delete from t_temptext where id = 'ue_insertSalesQty';
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'p_class_name is ' || p_class_name);
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'p_object_id is ' || p_object_id);
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_object_id));
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'p_account_code is ' || p_account_code);
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'p_profit_centre_id is ' || p_profit_centre_id);
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'Code for p_profit_centre_id is ' || ecdp_objects.GetObjCode(p_profit_centre_id));
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'p_time_span is ' || p_time_span);
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'p_daytime is ' || p_daytime);
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'p_vol_qty is ' || p_vol_qty);
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'p_mass_qty is ' || p_mass_qty);
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'p_energy_qty is ' || p_energy_qty);
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'p_doc_status is ' || p_doc_status);
  ecdp_dynsql.WriteTempText('ue_insertSalesQty', 'p_user is ' || p_user);

  --Put your User Exit code here:

END ue_insertSalesQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : ue_IFAC_TRANSACTION_LEVEL
-- Description    : Inserting sales quantities to EC Revenue interface ifac_sales_qty
--                  at Transaction Level, e.g. No Profit Centre given
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
---------------------------------------------------------------------------------------------------
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
)

IS

BEGIN

  --Test
  delete from t_temptext where id = 'ue_IFAC_TRANSACTION_LEVEL';
  ecdp_dynsql.WriteTempText('ue_IFAC_TRANSACTION_LEVEL', 'p_class_name is ' || p_class_name);
  ecdp_dynsql.WriteTempText('ue_IFAC_TRANSACTION_LEVEL', 'p_object_id is ' || p_object_id);
  ecdp_dynsql.WriteTempText('ue_IFAC_TRANSACTION_LEVEL', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_object_id));
  ecdp_dynsql.WriteTempText('ue_IFAC_TRANSACTION_LEVEL', 'p_account_code is ' || p_account_code);
  ecdp_dynsql.WriteTempText('ue_IFAC_TRANSACTION_LEVEL', 'p_time_span is ' || p_time_span);
  ecdp_dynsql.WriteTempText('ue_IFAC_TRANSACTION_LEVEL', 'p_daytime is ' || p_daytime);
  ecdp_dynsql.WriteTempText('ue_IFAC_TRANSACTION_LEVEL', 'p_vol_qty is ' || p_vol_qty);
  ecdp_dynsql.WriteTempText('ue_IFAC_TRANSACTION_LEVEL', 'p_mass_qty is ' || p_mass_qty);
  ecdp_dynsql.WriteTempText('ue_IFAC_TRANSACTION_LEVEL', 'p_energy_qty is ' || p_energy_qty);
  ecdp_dynsql.WriteTempText('ue_IFAC_TRANSACTION_LEVEL', 'p_doc_status is ' || p_doc_status);
  ecdp_dynsql.WriteTempText('ue_IFAC_TRANSACTION_LEVEL', 'p_user is ' || p_user);

  --Put your User Exit code here:


END ue_IFAC_TRANSACTION_LEVEL;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : ue_IFAC_PROFIT_CENTRE_LEVEL
-- Description    : Inserting sales quantities to EC Revenue interface ifac_sales_qty
--                  at Profit Centre Level, e.g. Profit Centre given
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
---------------------------------------------------------------------------------------------------
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
)

IS

BEGIN
  --Test
  delete from t_temptext where id = 'ue_IFAC_PROFIT_CENTRE_LEVEL';
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'p_class_name is ' || p_class_name);
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'p_object_id is ' || p_object_id);
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_object_id));
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'p_account_code is ' || p_account_code);
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'p_profit_centre_id is ' || p_profit_centre_id);
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'Code for p_profit_centre_id is ' || ecdp_objects.GetObjCode(p_profit_centre_id));
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'p_time_span is ' || p_time_span);
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'p_daytime is ' || p_daytime);
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'p_vol_qty is ' || p_vol_qty);
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'p_mass_qty is ' || p_mass_qty);
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'p_energy_qty is ' || p_energy_qty);
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'p_doc_status is ' || p_doc_status);
  ecdp_dynsql.WriteTempText('ue_IFAC_PROFIT_CENTRE_LEVEL', 'p_user is ' || p_user);

  --Put your User Exit code here:

END ue_IFAC_PROFIT_CENTRE_LEVEL;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : ue_IFAC_PROFIT_CENTRE_LEVEL
-- Description    : Inserting sales quantities to EC Revenue interface ifac_sales_qty
--                  at Profit Centre Level, e.g. Profit Centre given
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
---------------------------------------------------------------------------------------------------
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
)

IS

BEGIN
  --Test
  delete from t_temptext where id = 'ue_IFAC_COMPANY_LEVEL';
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_class_name is ' || p_class_name);
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_object_id is ' || p_object_id);
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_object_id));
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_account_code is ' || p_account_code);
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_profit_centre_id is ' || p_profit_centre_id);
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'Code for p_profit_centre_id is ' || ecdp_objects.GetObjCode(p_profit_centre_id));
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_vendor_id is ' || p_vendor_id);
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'Code for p_company_id is ' || ecdp_objects.GetObjCode(p_vendor_id));
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_time_span is ' || p_time_span);
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_daytime is ' || p_daytime);
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_vol_qty is ' || p_vol_qty);
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_mass_qty is ' || p_mass_qty);
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_energy_qty is ' || p_energy_qty);
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_doc_status is ' || p_doc_status);
  ecdp_dynsql.WriteTempText('ue_IFAC_COMPANY_LEVEL', 'p_user is ' || p_user);

  --Put your User Exit code here:

END ue_IFAC_COMPANY_LEVEL;

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
)

IS

BEGIN
  --Test
  delete from t_temptext where id = 'ue_insertIFAC_PC_CPY_Qty';
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_class_name is ' || p_class_name);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_object_id is ' || p_object_id);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_object_id));
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_account_code is ' || p_account_code);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_profit_centre_id is ' || p_profit_centre_id);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'Code for p_profit_centre_id is ' || ecdp_objects.GetObjCode(p_profit_centre_id));
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_vendor_id is ' || p_vendor_id);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'Code for p_vendor_id is ' || ecdp_objects.GetObjCode(p_vendor_id));
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_party_share is ' || p_party_share);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_time_span is ' || p_time_span);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_daytime is ' || p_daytime);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_vol_qty is ' || p_vol_qty);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_mass_qty is ' || p_mass_qty);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_energy_qty is ' || p_energy_qty);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_doc_status is ' || p_doc_status);
  ecdp_dynsql.WriteTempText('ue_insertIFAC_PC_CPY_Qty', 'p_user is ' || p_user);

  --Put your User Exit code here:

END ue_insertIFAC_PC_CPY_Qty;


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
                        p_doc_status        VARCHAR2) RETURN VARCHAR2

IS

BEGIN
  --Test
  delete from t_temptext where id = 'ue_FinalAccrualDoc';
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_class_name is ' || p_class_name);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_object_id is ' || p_object_id);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_object_id));
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_account_code is ' || p_account_code);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_profit_centre_id is ' || p_profit_centre_id);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'Code for p_profit_centre_id is ' || ecdp_objects.GetObjCode(p_profit_centre_id));
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_vendor_id is ' || p_vendor_id);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'Code for p_vendor_id is ' || ecdp_objects.GetObjCode(p_vendor_id));
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_party_share is ' || p_party_share);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_time_span is ' || p_time_span);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_daytime is ' || p_daytime);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_vol_qty is ' || p_vol_qty);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_mass_qty is ' || p_mass_qty);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_energy_qty is ' || p_energy_qty);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_doc_status is ' || p_doc_status);
  ecdp_dynsql.WriteTempText('ue_FinalAccrualDoc', 'p_user is ' || p_user);

  --Put your User Exit code here:
  RETURN NULL;

END ue_FinalAccrualDoc;

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
                        p_doc_status        VARCHAR2)  RETURN VARCHAR2

IS

BEGIN
  --Test
  delete from t_temptext where id = 'ue_PriceStatus';
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_class_name is ' || p_class_name);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_object_id is ' || p_object_id);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_object_id));
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_account_code is ' || p_account_code);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_profit_centre_id is ' || p_profit_centre_id);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'Code for p_profit_centre_id is ' || ecdp_objects.GetObjCode(p_profit_centre_id));
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_vendor_id is ' || p_vendor_id);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'Code for p_vendor_id is ' || ecdp_objects.GetObjCode(p_vendor_id));
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_party_share is ' || p_party_share);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_time_span is ' || p_time_span);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_daytime is ' || p_daytime);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_vol_qty is ' || p_vol_qty);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_mass_qty is ' || p_mass_qty);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_energy_qty is ' || p_energy_qty);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_doc_status is ' || p_doc_status);
  ecdp_dynsql.WriteTempText('ue_PriceStatus', 'p_user is ' || p_user);

  --Put your User Exit code here:
  RETURN NULL;

END ue_PriceStatus;

FUNCTION ue_GetIfacRecordPriceObject(
                        p_contract_id        VARCHAR2,
                        p_product_id         VARCHAR2,
                        p_price_concept_code VARCHAR2,
                        p_quantity_status    VARCHAR2,
                        p_price_status       VARCHAR2,
                        p_daytime            DATE,
                        p_uom_code           VARCHAR2 DEFAULT NULL)RETURN VARCHAR2

IS

BEGIN
  --Test
  delete from t_temptext where id = 'ue_GetIfacRecordPriceObject';
  ecdp_dynsql.WriteTempText('ue_GetIfacRecordPriceObject', 'p_contract_id is ' || p_contract_id);
  ecdp_dynsql.WriteTempText('ue_GetIfacRecordPriceObject', 'Code for p_object_id is ' || ecdp_objects.GetObjCode(p_contract_id));
  ecdp_dynsql.WriteTempText('ue_GetIfacRecordPriceObject', 'p_product_id is ' || p_product_id);
  ecdp_dynsql.WriteTempText('ue_GetIfacRecordPriceObject', 'Code for p_product_id is ' || ecdp_objects.GetObjCode(p_product_id));
  ecdp_dynsql.WriteTempText('ue_GetIfacRecordPriceObject', 'p_price_concept_code is ' || p_price_concept_code);
  ecdp_dynsql.WriteTempText('ue_GetIfacRecordPriceObject', 'p_quantity_status is ' || p_quantity_status);
  ecdp_dynsql.WriteTempText('ue_GetIfacRecordPriceObject', 'p_price_status is ' || p_price_status);
  ecdp_dynsql.WriteTempText('ue_GetIfacRecordPriceObject', 'p_daytime is ' || p_daytime);
  ecdp_dynsql.WriteTempText('ue_GetIfacRecordPriceObject', 'p_uom_code is ' || p_uom_code);

  --Put your User Exit code here:
  RETURN NULL;

END ue_GetIfacRecordPriceObject;

FUNCTION ue_QtyUOMMapping(
                        p_mapping_value     VARCHAR2,
                        p_vol_uom           VARCHAR2,
                        p_mass_uom          VARCHAR2,
                        p_energy_uom        VARCHAR2,
                        p_x1_uom            VARCHAR2,
                        p_x2_uom            VARCHAR2,
                        p_x3_uom            VARCHAR2) RETURN VARCHAR2
IS

BEGIN

  --Test
  delete from t_temptext where id = 'ue_QtyUOMMapping';
  ecdp_dynsql.WriteTempText('ue_QtyUOMMapping', 'p_mapping_value is ' || p_mapping_value);
  ecdp_dynsql.WriteTempText('ue_QtyUOMMapping', 'p_vol_uom is ' || p_vol_uom);
  ecdp_dynsql.WriteTempText('ue_QtyUOMMapping', 'p_mass_uom is ' || p_mass_uom);
  ecdp_dynsql.WriteTempText('ue_QtyUOMMapping', 'p_energy_uom is ' || p_energy_uom);
  ecdp_dynsql.WriteTempText('ue_QtyUOMMapping', 'p_x1_uom is ' || p_x1_uom);
  ecdp_dynsql.WriteTempText('ue_QtyUOMMapping', 'p_x2_uom is ' || p_x2_uom);
  ecdp_dynsql.WriteTempText('ue_QtyUOMMapping', 'p_x3_uom is ' || p_x3_uom);

  --Put your User Exit code here:
  RETURN NULL;

END ue_QtyUOMMapping;

FUNCTION ue_QtyValueMapping(
                        p_mapping_value     VARCHAR2,
                        p_vol_qty           NUMBER DEFAULT NULL,
                        p_mass_qty          NUMBER DEFAULT NULL,
                        p_energy_qty        NUMBER DEFAULT NULL,
                        p_x1_qty            NUMBER DEFAULT NULL,
                        p_x2_qty            NUMBER DEFAULT NULL,
                        p_x3_qty            NUMBER DEFAULT NULL ) RETURN NUMBER
IS

BEGIN
  --Test
  delete from t_temptext where id = 'ue_QtyValueMapping';
  ecdp_dynsql.WriteTempText('ue_QtyValueMapping', 'p_mapping_value is ' || p_mapping_value);
  ecdp_dynsql.WriteTempText('ue_QtyValueMapping', 'p_vol_qty is ' || p_vol_qty);
  ecdp_dynsql.WriteTempText('ue_QtyValueMapping', 'p_mass_qty is ' || p_mass_qty);
  ecdp_dynsql.WriteTempText('ue_QtyValueMapping', 'p_energy_qty is ' || p_energy_qty);
  ecdp_dynsql.WriteTempText('ue_QtyValueMapping', 'p_x1_qty is ' || p_x1_qty);
  ecdp_dynsql.WriteTempText('ue_QtyValueMapping', 'p_x2_qty is ' || p_x2_qty);
  ecdp_dynsql.WriteTempText('ue_QtyValueMapping', 'p_x3_qty is ' || p_x3_qty);

  --Put your User Exit code here:
  RETURN NULL;

END ue_QtyValueMapping;

END UE_Replicate_Sale_Qty;