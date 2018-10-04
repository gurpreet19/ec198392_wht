CREATE OR REPLACE PACKAGE EcDp_Inbound_Interface IS
/**************************************************************
** Package        :  EcDp_Inbound_Interface, header part
**
** $Revision: 1.107 $
**
** Purpose	:  ALL inbound DB interfaces
**
** General Logic:
**
**************************************************************/
FUNCTION find_transaction_template(
        p_Rec                              IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
       ,p_doc_concept_code                 VARCHAR2 DEFAULT NULL
       )     RETURN T_REVN_OBJ_INFO;

FUNCTION isObjectInObjectList
(
    p_object_id                           VARCHAR2,
    p_object_list_id                      VARCHAR2,
    p_daytime                             DATE
)
RETURN VARCHAR2;

FUNCTION isObjectCodeinObjectList
(
    p_object_code                         VARCHAR2,
    p_object_list_id                      VARCHAR2,
    p_daytime                             DATE
)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE TransferSPPrices(
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate); -- run time
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION TransferSPPricesRecord(
   p_Rec       IFAC_PRICE%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate -- run time
   ) RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE TransferQuantities(
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate); -- run time
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION TransferQuantitiesRecord(
   p_Rec       IFAC_QTY%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate -- run time
   ) RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION processGPPE(p_price_concept_id VARCHAR2, p_interface_row IFAC_PRICE%ROWTYPE, p_user VARCHAR2) RETURN BOOLEAN;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION processCPPE(p_contract_id VARCHAR2, p_price_concept_id VARCHAR2, p_interface_row IFAC_PRICE%ROWTYPE, p_user VARCHAR2) RETURN BOOLEAN;
-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE UpdAddInterfaceDayValue(
   p_status                       VARCHAR2,
   p_date                         DATE,
   p_stream_item_id               VARCHAR2,
   p_qty_method                   VARCHAR2,
   p_qty_volume                   VARCHAR2,
   p_uom_volume                   VARCHAR2,
   p_qty_mass                     VARCHAR2,
   p_uom_mass                     VARCHAR2,
   p_qty_energy                   VARCHAR2,
   p_uom_energy                   VARCHAR2,
   p_qty_x1                       VARCHAR2,
   p_uom_x1                       VARCHAR2,
   p_qty_x2                       VARCHAR2,
   p_uom_x2                       VARCHAR2,
   p_qty_x3                       VARCHAR2,
   p_uom_x3                       VARCHAR2,
   p_user                         VARCHAR2,
   p_booking_period               DATE DEFAULT NULL,
   p_reporting_period             DATE DEFAULT NULL,
   p_gcv                          VARCHAR2 DEFAULT NULL,
   p_gcv_energy_uom               VARCHAR2 DEFAULT NULL,
   p_gcv_volume_uom               VARCHAR2 DEFAULT NULL,
   p_mcv                          VARCHAR2 DEFAULT NULL,
   p_mcv_energy_uom               VARCHAR2 DEFAULT NULL,
   p_mcv_mass_uom                 VARCHAR2 DEFAULT NULL,
   p_density                      VARCHAR2 DEFAULT NULL,
   p_density_mass_uom             VARCHAR2 DEFAULT NULL,
   p_density_volume_uom           VARCHAR2 DEFAULT NULL);
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE UpdAddInterfaceMthValue(
   p_status                       VARCHAR2,
   p_date                         DATE,
   p_stream_item_id               VARCHAR2,
   p_qty_method                   VARCHAR2,
   p_qty_volume                   VARCHAR2,
   p_uom_volume                   VARCHAR2,
   p_qty_mass                     VARCHAR2,
   p_uom_mass                     VARCHAR2,
   p_qty_energy                   VARCHAR2,
   p_uom_energy                   VARCHAR2,
   p_qty_x1                       VARCHAR2,
   p_uom_x1                       VARCHAR2,
   p_qty_x2                       VARCHAR2,
   p_uom_x2                       VARCHAR2,
   p_qty_x3                       VARCHAR2,
   p_uom_x3                       VARCHAR2,
   p_user                         VARCHAR2,
   p_booking_period               DATE DEFAULT NULL,
   p_reporting_period             DATE DEFAULT NULL,
   p_gcv                          VARCHAR2 DEFAULT NULL,
   p_gcv_energy_uom               VARCHAR2 DEFAULT NULL,
   p_gcv_volume_uom               VARCHAR2 DEFAULT NULL,
   p_mcv                          VARCHAR2 DEFAULT NULL,
   p_mcv_energy_uom               VARCHAR2 DEFAULT NULL,
   p_mcv_mass_uom                 VARCHAR2 DEFAULT NULL,
   p_density                      VARCHAR2 DEFAULT NULL,
   p_density_mass_uom             VARCHAR2 DEFAULT NULL,
   p_density_volume_uom           VARCHAR2 DEFAULT NULL);
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE UpdAddInterfaceFcstMthValue(
   p_forecast_id                  VARCHAR2,
   p_status                       VARCHAR2,
   p_date                         DATE,
   p_stream_item_id               VARCHAR2,
   p_qty_method                   VARCHAR2,
   p_qty_volume                   VARCHAR2,
   p_uom_volume                   VARCHAR2,
   p_qty_mass                     VARCHAR2,
   p_uom_mass                     VARCHAR2,
   p_qty_energy                   VARCHAR2,
   p_uom_energy                   VARCHAR2,
   p_qty_x1                       VARCHAR2,
   p_uom_x1                       VARCHAR2,
   p_qty_x2                       VARCHAR2,
   p_uom_x2                       VARCHAR2,
   p_qty_x3                       VARCHAR2,
   p_uom_x3                       VARCHAR2,
   p_user                         VARCHAR2,
   p_booking_period               DATE DEFAULT NULL,
   p_reporting_period             DATE DEFAULT NULL,
   p_gcv                          VARCHAR2 DEFAULT NULL,
   p_gcv_energy_uom               VARCHAR2 DEFAULT NULL,
   p_gcv_volume_uom               VARCHAR2 DEFAULT NULL,
   p_mcv                          VARCHAR2 DEFAULT NULL,
   p_mcv_energy_uom               VARCHAR2 DEFAULT NULL,
   p_mcv_mass_uom                 VARCHAR2 DEFAULT NULL,
   p_density                      VARCHAR2 DEFAULT NULL,
   p_density_mass_uom             VARCHAR2 DEFAULT NULL,
   p_density_volume_uom           VARCHAR2 DEFAULT NULL);
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION getMappingCode(
   p_code  VARCHAR2,
   p_class VARCHAR2,
   p_daytime DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate,
   p_system VARCHAR2 default null
   )
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ImportSAPReturnStatus (
   p_record_id                   IN VARCHAR2 DEFAULT NULL,
   p_invoice_no                  IN VARCHAR2 DEFAULT NULL);
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ImportVOqty(
    p_status VARCHAR2, -- 1
    p_data_type VARCHAR2, -- 2
    p_qty_method VARCHAR2, -- 3
    p_daytime VARCHAR2, -- 4
    p_booking_period VARCHAR2, -- 5
    p_reporting_period VARCHAR2, -- 6
    p_stream_item_code VARCHAR2, -- 7
    p_qty_volume NUMBER, -- 8
    p_uom_volume VARCHAR2, -- 9
    p_qty_mass NUMBER, -- 10
    p_uom_mass VARCHAR2, -- 11
    p_qty_energy NUMBER, -- 12
    p_uom_energy VARCHAR2, -- 13
    p_extra1_qty NUMBER, -- 14
    p_extra1_uom VARCHAR2, -- 15
    p_extra2_qty NUMBER, -- 16
    p_extra2_uom VARCHAR2, -- 17
    p_extra3_qty NUMBER, -- 18
    p_extra3_uom VARCHAR2, -- 19
    p_gcv NUMBER, -- 20
    p_gcv_energy_uom VARCHAR2, -- 21
    p_gcv_volume_uom VARCHAR2, -- 22
    p_mcv NUMBER, -- 23
    p_mcv_energy_uom VARCHAR2, -- 24
    p_mcv_mass_uom VARCHAR2, -- 25
    p_density NUMBER, -- 26
    p_density_mass_uom VARCHAR2, -- 27
    p_density_volume_uom VARCHAR2, -- 28
    p_user VARCHAR2 DEFAULT 'upload', -- 29
    p_forecast_code VARCHAR2 DEFAULT NULL); -- 30
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetQtyAllocNo (
         p_Product            VARCHAR2,
         p_Company            VARCHAR2,
         p_Profit_Center      VARCHAR2,
         p_Si_category        VARCHAR2,
         p_day_mth            VARCHAR2,
         p_Node               VARCHAR2,
         p_Stream_item_Code   VARCHAR2,
         p_Daytime            DATE
) RETURN NUMBER;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetIfacRecordLevel(p_profit_center_code VARCHAR2,
                            p_vendor_code VARCHAR2,
                            p_contract_comp VARCHAR2,
                            p_object_type   VARCHAR2
) RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ReceiveSalesQtyRecord(p_Rec       IFAC_SALES_QTY%ROWTYPE,
                                p_user      VARCHAR2,
                                p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate -- run time
                                );
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ReceiveCargoQtyRecord(
   p_Rec       Ifac_Cargo_Value%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate);
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ReceiveIfacDocRecord(
   p_Rec_doc   IFAC_DOCUMENT%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate); -- run time
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ReceiveERPPostingRecord(
   p_Rec       IFAC_ERP_POSTINGS%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate);
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION ValidateInterfacedECCode(p_code       VARCHAR2, -- EC Code
                                  p_code_type  VARCHAR2, -- EC Code Type
                                  p_table_name VARCHAR2  -- Interface table
)RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION ValidateInterfacedECObject(p_object_id       VARCHAR2, -- EC object id, directly from interface
                                    p_object_id_by_uk VARCHAR2, -- EC object id, resolved by object_code
                                    p_object_code     VARCHAR2, -- EC object code
                                    p_class_name      VARCHAR2, -- EC object class
                                    p_table_name      VARCHAR2  -- Interface table
)RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION ReAnalyseSalesQtyRecord(p_Rec IFAC_SALES_QTY%ROWTYPE, p_user VARCHAR2 DEFAULT USER)
RETURN IFAC_SALES_QTY%ROWTYPE;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION ReAnalyseCargoRecord(p_Rec IFAC_CARGO_VALUE%ROWTYPE, p_user VARCHAR2 DEFAULT USER)
RETURN IFAC_CARGO_VALUE%ROWTYPE;
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ReAnalyseNewSalesQtyRecords(p_contract_id      VARCHAR2,
                                      p_contract_area_id VARCHAR2,
                                      p_business_unit_id VARCHAR2,
                                      p_user VARCHAR2 DEFAULT USER);
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ReAnalyseNewCargoRecords(p_contract_id      VARCHAR2,
                                   p_contract_area_id VARCHAR2,
                                   p_business_unit_id VARCHAR2,
                                   p_user VARCHAR2 DEFAULT USER);
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE UpdateTransTempCodeOvrd(p_contract_id 	       VARCHAR2,
                                  p_trans_temp_id 	       VARCHAR2,
                                  p_trans_temp_code 	       VARCHAR2,
                                  p_processing_period 	       DATE,
                                  p_doc_setup_id               VARCHAR2,
                                  p_sample_source_entry_no     NUMBER,
                                  p_product_id                 VARCHAR2,
                                  p_type 	               VARCHAR2);
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetAllIfacPossibleTT(p_source_entry_no    NUMBER,
                              p_doc_setup_id 	   VARCHAR2,
                              p_type 	           VARCHAR2)
RETURN T_TABLE_MIXED_DATA;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetAllPossibleIfacSalesTT(p_rec 	        IFAC_SALES_QTY%ROWTYPE,
                                   p_doc_concept_code 	VARCHAR2)
RETURN T_TABLE_MIXED_DATA;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetAllPossibleIfacCargoTT(p_Rec_ICV 	        IFAC_CARGO_VALUE%ROWTYPE,
                                   p_doc_concept_code 	VARCHAR2)

RETURN T_TABLE_MIXED_DATA;
-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ReAnalyseAllCargoRecords(p_contract_id      VARCHAR2,
                                   p_document_key     VARCHAR2,
                                   p_user VARCHAR2 DEFAULT USER);
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ReAnalyseAllSalesQtyRecords(p_contract_id      VARCHAR2,
                                      p_processing_period  DATE,
                                      p_user VARCHAR2 DEFAULT USER);
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ReanalyseAccruals;

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE UpdateCustomerOvrd(p_sample_source_entry_no NUMBER,
                             p_customer_id            VARCHAR2,
                             p_type                   VARCHAR2);
-----------------------------------------------------------------------------------------------------------------------------


END EcDp_Inbound_Interface;