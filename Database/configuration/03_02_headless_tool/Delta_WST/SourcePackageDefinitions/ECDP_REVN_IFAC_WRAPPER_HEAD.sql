CREATE OR REPLACE PACKAGE EcDp_REVN_IFAC_WRAPPER IS

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-- TODO: replace the usage of the following constants with ones in ecdp_revn_constants
gconst_sum_code CONSTANT VARCHAR2(8) :=  'SUM';
gconst_sum_vendor_code_suffix CONSTANT VARCHAR2(8) :=  '_FULL';
gconst_sum_vendor_code_gen CONSTANT VARCHAR2(32) :=  'AUTO_GEN_FULL';
gconst_level_transaction CONSTANT VARCHAR2(11) :=  'TRANS';
gconst_level_line_item CONSTANT VARCHAR2(11) := 'LI';
gconst_level_profit_center CONSTANT VARCHAR2(11) :=  'FIELD';
gconst_level_vendor CONSTANT VARCHAR2(11) :=  'VENDOR';
gconst_creation_type_interface CONSTANT VARCHAR2(32) := 'INTERFACE';
gconst_creation_type_auto_gen CONSTANT VARCHAR2(32) := 'AUTO_GENERATED';
-- TODO



gconst_get_ifac_scope_document CONSTANT VARCHAR2(32) := 'DOCUMENT';
gconst_get_ifac_scope_trans CONSTANT VARCHAR2(32) := 'TRANSACTION';
ge_record_qty_missing EXCEPTION;
ge_vendor_record_missing EXCEPTION;
ge_field_record_missing EXCEPTION;
ge_trans_record_missing EXCEPTION;
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
/*
TYPE T_DIST_INFO IS RECORD
(
     DISTRIBUTION_OBJECT_ID                VARCHAR2(32) -- for profit center dist
    ,VENDOR_ID                             VARCHAR2(32) -- for vendor dist
    ,STREAM_ITEM_ID                        VARCHAR2(32)
    ,SPLIT_KEY_ID                          VARCHAR2(32)
    ,CHILD_SPLIT_KEY_ID                    VARCHAR2(32)
    ,SPLIT_SHARE                           NUMBER
);


TYPE T_TABLE_DIST_INFO IS TABLE OF T_DIST_INFO;
*/
---------------
---------------

TYPE T_QTY_DIST IS RECORD
(
     QTY_LI_IFAC            T_TABLE_IFAC_SALES_QTY
    ,ALL_LI_IFAC            T_TABLE_IFAC_SALES_QTY
    ,QTY_PC_SHARE           T_TABLE_REVN_DIST_INFO
    ,QTY_VENDOR_SHARE       T_TABLE_REVN_DIST_INFO

);

TYPE T_TABLE_QTY_DIST IS TABLE OF T_QTY_DIST;

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
TYPE T_TABLE_OBJECT_ID IS TABLE OF VARCHAR2(32);
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
TYPE T_GET_IFAC_COMMON_DATA IS RECORD
(
     TRANS_IS_REDUCED_CONFIG               BOOLEAN
    ,CONTRACT_COMPOSITION                  VARCHAR2(32)
    ,CONTRACT_COMPANY_CODE                 VARCHAR2(32)
    ,CONTRACT_FINANCIAL_CODE               VARCHAR2(32)
    ,TRANS_DIST_ID                         VARCHAR2(32)
    ,TRANS_SI_STREAM_ID                    VARCHAR2(32)
    ,TRANS_SI_ID                           VARCHAR2(32)
    ,TRANS_SPLIT_KEY_ID                    VARCHAR2(32)
    ,TRANS_LEVEL_IFAC_INDEX                NUMBER
    ,TRANS_DIST_SPLIT_TYPE                 VARCHAR2(32)
    ,IFAC_TRANSACTION_TEMPLATE_ID          VARCHAR2(32)
    ,IFAC_PROCESSING_PERIOD                VARCHAR2(32)
    ,IFAC_PRODUCT_ID                       VARCHAR2(32)
    ,IFAC_UOM1_CODE                        VARCHAR2(32)
    ,IFAC_CONTRACT_ID                      VARCHAR2(32)
    ,IFAC_CUSTOMER_ID                      VARCHAR2(32)
    ,IFAC_PREC_DOCUMENT_KEY                VARCHAR2(32)
    ,GROUP_ID                              NUMBER
    ,TRANS_USE_STREAM_ITEM_IND             VARCHAR2(1)
    ,TRANS_DIST_CODE                       VARCHAR2(32)
    ,TRANS_DIST_TYPE                       VARCHAR2(32)
    ,TRANS_DIST_OBJECT_TYPE                VARCHAR2(32)
    ,IFAC_PERIOD_START_DATE                VARCHAR2(32)
    ,LI_ITEM_BASED_TYPE                    VARCHAR2(32)
    ,LI_LEVEL_IFAC_INDEX                   NUMBER
    ,LINE_ITEM_TYPE                        VARCHAR2(32)
    ,UNIT_PRICE_UNIT                       VARCHAR2(32)
    ,LI_UNIQUE_KEY_1                       VARCHAR2(240)
    ,LI_UNIQUE_KEY_2                       VARCHAR2(240)
    ,CONTRACT_ACCOUNT                      IFAC_SALES_QTY.CONTRACT_ACCOUNT%TYPE
    ,CONTRACT_ACCOUNT_CLASS                IFAC_SALES_QTY.CONTRACT_ACCOUNT_CLASS%TYPE
    ,CALC_RUN_NO                           IFAC_SALES_QTY.CALC_RUN_NO%TYPE
    --,QTY_LI_IFAC                           T_TABLE_IFAC_SALES_QTY
    --,QTY_PC_SHARE                          T_TABLE_REVN_DIST_INFO
    -- may be needed at vendor share level ?? ,QTY_VENDOR_SHARE                      T_TABLE_DIST_INFO
);
/*------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
TYPE T_GET_PERIOD_IFAC_PARAMS IS RECORD
(
     p_contract_id                         objects.object_id%TYPE
    ,p_price_concept_code                  price_concept.price_concept_code%TYPE
    ,p_price_object_id                     objects.object_id%TYPE
    ,p_product_id                          objects.object_id%TYPE
    ,p_delivery_point_id                   objects.object_id%TYPE
    ,p_profit_center_id                    objects.object_id%TYPE -- OPTIONAL
    ,p_vendor_id                           objects.object_id%TYPE -- OPTIONAL
    ,p_customer_id                         objects.object_id%TYPE
    ,p_qty_status                          Transaction_Tmpl_Version.Req_Qty_Type%TYPE
    ,p_doc_status_code                     cont_document.status_code%TYPE
    ,p_period_start_date                   DATE
    ,p_period_end_date                     DATE
    ,p_uom1_code                           VARCHAR2(32)
    ,p_ct_uk1                              VARCHAR2(32)
    ,p_ct_uk2                              VARCHAR2(32)
    ,p_if_tt_conn_code                     VARCHAR2(32)
    ,p_processing_period                   DATE
);*/
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetIfacRecordLevel_I(
                         p_profit_center_code               VARCHAR2
                        ,p_vendor_code                      VARCHAR2
                        ,p_object_type                        VARCHAR2
                        )
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Equals_I(
                         p_value_1                          VARCHAR2
                        ,p_value_2                          VARCHAR2
                        ,p_true_when_value_1_is_null        BOOLEAN
                        )
RETURN BOOLEAN;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE CheckAndFillDistInfo_I(
                         p_dist_info                        IN OUT NOCOPY T_TABLE_REVN_DIST_INFO
                        ,p_profit_center_id                 VARCHAR2
                        ,p_vendor_id                        VARCHAR2 DEFAULT NULL
                        ,p_split_share                      NUMBER  DEFAULT 0
                        );
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ContainsObjectID_I(
                         p_object_id_table                  T_TABLE_OBJECT_ID
                        ,p_object_id                        VARCHAR2
                        )
RETURN BOOLEAN;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ContainsDistInfo_I(
                         p_dist_info                        T_TABLE_REVN_DIST_INFO
                        ,p_vendor_id                        VARCHAR2
                        ,p_profit_center_id                 VARCHAR2
                        )
RETURN BOOLEAN;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ShouldAddQuantity_I(
                         p_target_profit_center_id          VARCHAR2
                        ,p_target_vendor_id                 VARCHAR2
                        ,p_level_calculate_from             VARCHAR2
                        ,p_level_calculate_from_actual      VARCHAR2
                        ,p_current_profit_center_id         VARCHAR2
                        ,p_current_vendor_id                VARCHAR2
                        ,p_current_interface_level          VARCHAR2
                        )
RETURN BOOLEAN;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE AddPCDistInfo_I(
                         p_dist_info_table                  IN OUT NOCOPY ECDP_REVN_IFAC_WRAPPER.T_TABLE_OBJECT_ID
                        ,p_profit_center_id                 VARCHAR2
                        );
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE AddVendorDistInfo_I(
                         p_dist_info_table                  IN OUT NOCOPY /*ECDP_REVN_IFAC_WRAPPER.*/ T_TABLE_REVN_DIST_INFO
                        ,p_stream_item_id                   VARCHAR2
                        ,p_distributin_object_id            VARCHAR2
                        ,p_vendor_id                        VARCHAR2
                        ,p_split_key_id                     VARCHAR2
                        ,p_child_split_key_id               VARCHAR2
                        ,p_split_share                      NUMBER
                        );
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION FindDistInfo_I(
                         p_dist_info_table                  T_TABLE_REVN_DIST_INFO
                        ,p_profit_center_id_to_find         VARCHAR2                             -- OPTIONAL
                        ,p_vendor_id_to_find                VARCHAR2                             -- OPTIONAL
                        )
RETURN NUMBER;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE GetPCDistInfo_Trans_I(
                         p_common_data                      T_GET_IFAC_COMMON_DATA
                        ,p_profit_center_dist_info          IN OUT NOCOPY T_TABLE_REVN_DIST_INFO
                        );
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetVendorDistInfo_I(
                         p_dist_info                        T_TABLE_REVN_DIST_INFO
                        ,p_profit_center_id                 VARCHAR2
                        )
RETURN T_TABLE_REVN_DIST_INFO;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetVendorDistInfoFromConfig_I(
                         p_common_data                      T_GET_IFAC_COMMON_DATA
                        ,p_profit_center_dist_info          T_REVN_DIST_INFO
                        )
RETURN T_TABLE_REVN_DIST_INFO;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION FilterPCDistInfoItem_I(
                         p_profit_center_dist_info          T_TABLE_REVN_DIST_INFO
                        ,p_profit_centers_to_keep           T_TABLE_OBJECT_ID
                        )
RETURN T_TABLE_REVN_DIST_INFO;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

END EcDp_REVN_IFAC_WRAPPER;