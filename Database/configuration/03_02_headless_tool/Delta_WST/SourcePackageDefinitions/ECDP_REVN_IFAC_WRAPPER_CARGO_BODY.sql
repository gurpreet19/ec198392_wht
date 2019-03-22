CREATE OR REPLACE PACKAGE BODY EcDp_REVN_IFAC_WRAPPER_CARGO IS

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION CalculateQuantities_P(
                         p_ifac_table                       T_TABLE_IFAC_CARGO_VALUE
                        ,p_target_profit_center_id          VARCHAR2
                        ,p_target_vendor_id                 VARCHAR2
                        ,p_level_calculate_from             VARCHAR2
                        ,p_qty_1                            OUT NUMBER
                        ,p_qty_2                            OUT NUMBER
                        ,p_qty_3                            OUT NUMBER
                        ,p_qty_4                            OUT NUMBER
                        ,p_grs_qty_1                        OUT NUMBER
                        ,p_grs_qty_2                        OUT NUMBER
                        ,p_grs_qty_3                        OUT NUMBER
                        ,p_grs_qty_4                        OUT NUMBER
                        ,p_pricing_value                    OUT NUMBER
                        ,p_percent_base_amt                 OUT NUMBER
                        ,p_int_base_amt                     OUT NUMBER
                        ,p_level_calculate_from_actual      OUT VARCHAR2
                        )
RETURN BOOLEAN
IS
    lb_record_found BOOLEAN := FALSE;
BEGIN
    FOR i_index IN p_ifac_table.FIRST .. p_ifac_table.LAST
    LOOP
        IF ECDP_REVN_IFAC_WRAPPER.ShouldAddQuantity_I(
                         p_target_profit_center_id
                        ,p_target_vendor_id
                        ,p_level_calculate_from
                        ,p_level_calculate_from_actual
                        ,p_ifac_table(i_index).PROFIT_CENTER_ID
                        ,p_ifac_table(i_index).VENDOR_ID
                        ,p_ifac_table(i_index).INTERFACE_LEVEL
                        )
        THEN
            IF NOT lb_record_found
            THEN
                p_level_calculate_from_actual := p_ifac_table(i_index).INTERFACE_LEVEL;
                lb_record_found := TRUE;

                p_qty_1            := p_ifac_table(i_index).NET_QTY1;
                p_qty_2            := p_ifac_table(i_index).NET_QTY2;
                p_qty_3            := p_ifac_table(i_index).NET_QTY3;
                p_qty_4            := p_ifac_table(i_index).NET_QTY4;
                p_grs_qty_1        := p_ifac_table(i_index).grs_qty1;
                p_grs_qty_2        := p_ifac_table(i_index).grs_qty2;
                p_grs_qty_3        := p_ifac_table(i_index).grs_qty3;
                p_grs_qty_4        := p_ifac_table(i_index).grs_qty4;
                p_pricing_value    := p_ifac_table(i_index).pricing_value;
                p_percent_base_amt := p_ifac_table(i_index).percentage_base_amount;
                p_int_base_amt     := p_ifac_table(i_index).int_base_amount;
            ELSE
                p_qty_1            := p_qty_1 + p_ifac_table(i_index).NET_QTY1;
                p_qty_2            := p_qty_2 + p_ifac_table(i_index).NET_QTY2;
                p_qty_3            := p_qty_3 + p_ifac_table(i_index).NET_QTY3;
                p_qty_4            := p_qty_4 + p_ifac_table(i_index).NET_QTY4;
                p_grs_qty_1        := p_ifac_table(i_index).grs_qty1;
                p_grs_qty_2        := p_ifac_table(i_index).grs_qty2;
                p_grs_qty_3        := p_ifac_table(i_index).grs_qty3;
                p_grs_qty_4        := p_ifac_table(i_index).grs_qty4;
                p_pricing_value    := p_pricing_value + p_ifac_table(i_index).pricing_value;
                p_percent_base_amt := p_percent_base_amt + p_ifac_table(i_index).percentage_base_amount;
                p_int_base_amt     := p_int_base_amt + p_ifac_table(i_index).int_base_amount;
            END IF;
        END IF;
    END LOOP;

    RETURN lb_record_found;
END CalculateQuantities_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION LevelRecordsExists_P(p_ifac_table T_TABLE_IFAC_CARGO_VALUE, p_level VARCHAR2, p_creation_type VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN
IS
    b_record_found BOOLEAN := FALSE;
BEGIN
    FOR i_index IN p_ifac_table.FIRST .. p_ifac_table.LAST
    LOOP
        IF p_ifac_table(i_index).INTERFACE_LEVEL = p_level
           AND p_ifac_table(i_index).CREATION_TYPE = NVL(p_creation_type, p_ifac_table(i_index).CREATION_TYPE)
        THEN
            b_record_found := TRUE;
            EXIT;
        END IF;
    END LOOP;

    RETURN b_record_found;
END LevelRecordsExists_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION FindLineItemLevelRecord_P(p_ifac_table T_TABLE_IFAC_CARGO_VALUE)
RETURN NUMBER
IS
BEGIN
    FOR i_index IN p_ifac_table.FIRST .. p_ifac_table.LAST
    LOOP
        IF p_ifac_table(i_index).INTERFACE_LEVEL = ECDP_REVN_IFAC_WRAPPER.gconst_level_line_item
        THEN
            RETURN i_index;
        END IF;
    END LOOP;

    RETURN NULL;
END FindLineItemLevelRecord_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE FillCommonRecordFields_P(
                         p_from_record                      T_IFAC_CARGO_VALUE
                        ,p_to_record                        IN OUT NOCOPY T_IFAC_CARGO_VALUE
                        )
IS
BEGIN
    p_to_record.CONTRACT_CODE                   := p_from_record.CONTRACT_CODE           ;
    p_to_record.CARGO_NO                        := p_from_record.CARGO_NO                ;
    p_to_record.PARCEL_NO                       := p_from_record.PARCEL_NO               ;
    p_to_record.QTY_TYPE                        := p_from_record.QTY_TYPE                ;
    p_to_record.ALLOC_NO                        := p_from_record.ALLOC_NO                ;
    p_to_record.SO_NUMBER                       := p_from_record.SO_NUMBER               ;
    p_to_record.LOADING_DATE                    := p_from_record.LOADING_DATE            ;
    p_to_record.LOADING_COMM_DATE               := p_from_record.LOADING_COMM_DATE       ;
    p_to_record.DELIVERY_DATE                   := p_from_record.DELIVERY_DATE           ;
    p_to_record.DELIVERY_COMM_DATE              := p_from_record.DELIVERY_COMM_DATE      ;
    p_to_record.POINT_OF_SALE_DATE              := p_from_record.POINT_OF_SALE_DATE      ;
    p_to_record.BL_DATE                         := p_from_record.BL_DATE                 ;
    p_to_record.PRICE_DATE                      := p_from_record.PRICE_DATE              ;
    p_to_record.PRICE_OBJECT_CODE               := p_from_record.PRICE_OBJECT_CODE       ;
    p_to_record.PRICE_OBJECT_ID                 := p_from_record.PRICE_OBJECT_ID         ;
    p_to_record.PRICE_STATUS                    := p_from_record.PRICE_STATUS            ;
    p_to_record.DISCHARGE_BERTH_CODE            := p_from_record.DISCHARGE_BERTH_CODE    ;
    p_to_record.LOADING_BERTH_CODE              := p_from_record.LOADING_BERTH_CODE      ;
    p_to_record.DISCHARGE_PORT_CODE             := p_from_record.DISCHARGE_PORT_CODE     ;
    p_to_record.LOADING_PORT_CODE               := p_from_record.LOADING_PORT_CODE       ;
    p_to_record.CONSIGNOR_CODE                  := p_from_record.CONSIGNOR_CODE          ;
    p_to_record.CONSIGNEE_CODE                  := p_from_record.CONSIGNEE_CODE          ;
    p_to_record.CARRIER_CODE                    := p_from_record.CARRIER_CODE            ;
    p_to_record.VOYAGE_NO                       := p_from_record.VOYAGE_NO               ;
    p_to_record.PRODUCT_CODE                    := p_from_record.PRODUCT_CODE            ;
    p_to_record.PRICE_CONCEPT_CODE              := p_from_record.PRICE_CONCEPT_CODE      ;
    p_to_record.UOM1_CODE                       := p_from_record.UOM1_CODE               ;
    p_to_record.UOM2_CODE                       := p_from_record.UOM2_CODE               ;
    p_to_record.UOM3_CODE                       := p_from_record.UOM3_CODE               ;
    p_to_record.UOM4_CODE                       := p_from_record.UOM4_CODE               ;
    p_to_record.STATUS                          := p_from_record.STATUS                  ;
    p_to_record.DESCRIPTION                     := p_from_record.DESCRIPTION             ;
    p_to_record.CARRIER_ID                      := p_from_record.CARRIER_ID              ;
    p_to_record.CONSIGNEE_ID                    := p_from_record.CONSIGNEE_ID            ;
    p_to_record.CONSIGNOR_ID                    := p_from_record.CONSIGNOR_ID            ;
    p_to_record.CONTRACT_ID                     := p_from_record.CONTRACT_ID             ;
    p_to_record.DISCHARGE_BERTH_ID              := p_from_record.DISCHARGE_BERTH_ID      ;
    p_to_record.DISCHARGE_PORT_ID               := p_from_record.DISCHARGE_PORT_ID       ;
    p_to_record.DOC_SETUP_CODE                  := p_from_record.DOC_SETUP_CODE          ;
    p_to_record.DOC_SETUP_ID                    := p_from_record.DOC_SETUP_ID            ;
    p_to_record.DOC_STATUS                      := p_from_record.DOC_STATUS              ;
    p_to_record.IGNORE_IND                      := p_from_record.IGNORE_IND              ;
    p_to_record.LOADING_BERTH_ID                := p_from_record.LOADING_BERTH_ID        ;
    p_to_record.LOADING_PORT_ID                 := p_from_record.LOADING_PORT_ID         ;
    p_to_record.PRECEDING_DOC_KEY               := p_from_record.PRECEDING_DOC_KEY       ;
    p_to_record.PRODUCT_ID                      := p_from_record.PRODUCT_ID              ;
    p_to_record.PRODUCT_SALES_ORDER_ID          := p_from_record.PRODUCT_SALES_ORDER_ID  ;
    p_to_record.PRODUCT_SALES_ORDER_CODE        := p_from_record.PRODUCT_SALES_ORDER_CODE;
    p_to_record.SOURCE_ENTRY_NO                 := p_from_record.SOURCE_ENTRY_NO         ;
    p_to_record.SOURCE_NODE_CODE                := p_from_record.SOURCE_NODE_CODE        ;
    p_to_record.SOURCE_NODE_ID                  := p_from_record.SOURCE_NODE_ID          ;
    p_to_record.TRANSACTION_KEY                 := p_from_record.TRANSACTION_KEY         ;
    p_to_record.TRANS_TEMP_CODE                 := p_from_record.TRANS_TEMP_CODE         ;
    p_to_record.TRANS_TEMP_ID                   := p_from_record.TRANS_TEMP_ID           ;
    p_to_record.UNIT_PRICE                      := p_from_record.UNIT_PRICE              ;
    p_to_record.VAT_CODE                        := p_from_record.VAT_CODE                ;
    p_to_record.IFAC_TT_CONN_CODE               := p_from_record.IFAC_TT_CONN_CODE       ;
    p_to_record.ALLOC_NO_MAX_IND                := p_from_record.ALLOC_NO_MAX_IND        ;
    p_to_record.TRANS_KEY_SET_IND               := p_from_record.TRANS_KEY_SET_IND       ;
    --p_to_record.ORIGINAL_IFAC_DATA              := p_from_record.ORIGINAL_IFAC_DATA      ;
    p_to_record.TEXT_1                          := p_from_record.TEXT_1                  ;
    p_to_record.TEXT_2                          := p_from_record.TEXT_2                  ;
    p_to_record.TEXT_3                          := p_from_record.TEXT_3                  ;
    p_to_record.TEXT_4                          := p_from_record.TEXT_4                  ;
    p_to_record.TEXT_5                          := p_from_record.TEXT_5                  ;
    p_to_record.TEXT_6                          := p_from_record.TEXT_6                  ;
    p_to_record.TEXT_7                          := p_from_record.TEXT_7                  ;
    p_to_record.TEXT_8                          := p_from_record.TEXT_8                  ;
    p_to_record.TEXT_9                          := p_from_record.TEXT_9                  ;
    p_to_record.TEXT_10                         := p_from_record.TEXT_10                 ;
    p_to_record.VALUE_1                         := p_from_record.VALUE_1                 ;
    p_to_record.VALUE_2                         := p_from_record.VALUE_2                 ;
    p_to_record.VALUE_3                         := p_from_record.VALUE_3                 ;
    p_to_record.VALUE_4                         := p_from_record.VALUE_4                 ;
    p_to_record.VALUE_5                         := p_from_record.VALUE_5                 ;
    p_to_record.VALUE_6                         := p_from_record.VALUE_6                 ;
    p_to_record.VALUE_7                         := p_from_record.VALUE_7                 ;
    p_to_record.VALUE_8                         := p_from_record.VALUE_8                 ;
    p_to_record.VALUE_9                         := p_from_record.VALUE_9                 ;
    p_to_record.VALUE_10                        := p_from_record.VALUE_10                ;
    p_to_record.DATE_1                          := p_from_record.DATE_1                  ;
    p_to_record.DATE_2                          := p_from_record.DATE_2                  ;
    p_to_record.DATE_3                          := p_from_record.DATE_3                  ;
    p_to_record.DATE_4                          := p_from_record.DATE_4                  ;
    p_to_record.DATE_5                          := p_from_record.DATE_5                  ;
    p_to_record.DATE_6                          := p_from_record.DATE_6                  ;
    p_to_record.DATE_7                          := p_from_record.DATE_7                  ;
    p_to_record.DATE_8                          := p_from_record.DATE_8                  ;
    p_to_record.DATE_9                          := p_from_record.DATE_9                  ;
    p_to_record.DATE_10                         := p_from_record.DATE_10                 ;
    p_to_record.REF_OBJECT_ID_1                 := p_from_record.REF_OBJECT_ID_1         ;
    p_to_record.REF_OBJECT_ID_2                 := p_from_record.REF_OBJECT_ID_2         ;
    p_to_record.REF_OBJECT_ID_3                 := p_from_record.REF_OBJECT_ID_3         ;
    p_to_record.REF_OBJECT_ID_4                 := p_from_record.REF_OBJECT_ID_4         ;
    p_to_record.REF_OBJECT_ID_5                 := p_from_record.REF_OBJECT_ID_5         ;
    p_to_record.REF_OBJECT_ID_6                 := p_from_record.REF_OBJECT_ID_6         ;
    p_to_record.REF_OBJECT_ID_7                 := p_from_record.REF_OBJECT_ID_7         ;
    p_to_record.REF_OBJECT_ID_8                 := p_from_record.REF_OBJECT_ID_8         ;
    p_to_record.REF_OBJECT_ID_9                 := p_from_record.REF_OBJECT_ID_9         ;
    p_to_record.REF_OBJECT_ID_10                := p_from_record.REF_OBJECT_ID_10        ;
    p_to_record.RECORD_STATUS                   := p_from_record.RECORD_STATUS           ;
    p_to_record.CREATED_BY                      := p_from_record.CREATED_BY              ;
    p_to_record.CREATED_DATE                    := p_from_record.CREATED_DATE            ;
    p_to_record.LAST_UPDATED_BY                 := p_from_record.LAST_UPDATED_BY         ;
    p_to_record.LAST_UPDATED_DATE               := p_from_record.LAST_UPDATED_DATE       ;
    p_to_record.REV_NO                          := p_from_record.REV_NO                  ;
    p_to_record.REV_TEXT                        := p_from_record.REV_TEXT                ;
    p_to_record.APPROVAL_BY                     := p_from_record.APPROVAL_BY             ;
    p_to_record.APPROVAL_DATE                   := p_from_record.APPROVAL_DATE           ;
    p_to_record.APPROVAL_STATE                  := p_from_record.APPROVAL_STATE          ;
    p_to_record.REC_ID                          := p_from_record.REC_ID                  ;
    p_to_record.CUSTOMER_CODE                   := p_from_record.CUSTOMER_CODE           ;
    p_to_record.CUSTOMER_ID                     := p_from_record.CUSTOMER_ID             ;
    p_to_record.UNIT_PRICE_UNIT                 := p_from_record.UNIT_PRICE_UNIT         ;
    p_to_record.LI_UNIQUE_KEY_1                 := p_from_record.LI_UNIQUE_KEY_1         ;
    p_to_record.LI_UNIQUE_KEY_2                 := p_from_record.LI_UNIQUE_KEY_2         ;

END FillCommonRecordFields_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION CreateTransLevelRecord_P(
                         p_ifac_sample_qty                  IN OUT NOCOPY T_IFAC_CARGO_VALUE
                        )
RETURN T_IFAC_CARGO_VALUE
IS
    lt_ifac_qty T_IFAC_CARGO_VALUE;
BEGIN
    lt_ifac_qty := WrapInterfaceRecord(NULL);
    lt_ifac_qty.INTERFACE_LEVEL      := ECDP_REVN_IFAC_WRAPPER.gconst_level_transaction;
    lt_ifac_qty.CREATION_TYPE        := ECDP_REVN_IFAC_WRAPPER.gconst_creation_type_auto_gen;
    lt_ifac_qty.CREATED_DATE         := Ecdp_Timestamp.getCurrentSysdate;

    FillCommonRecordFields_P(p_ifac_sample_qty, lt_ifac_qty);

    return lt_ifac_qty;
END CreateTransLevelRecord_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION CreateLineItemLevelRecord_P(
                         p_ifac_sample_qty                  T_IFAC_CARGO_VALUE
                        ,p_qty_1                            NUMBER
                        ,p_qty_2                            NUMBER
                        ,p_qty_3                            NUMBER
                        ,p_qty_4                            NUMBER
                        ,p_grs_qty_1                        NUMBER
                        ,p_grs_qty_2                        NUMBER
                        ,p_grs_qty_3                        NUMBER
                        ,p_grs_qty_4                        NUMBER
                        ,p_pricing_value                    NUMBER
                        ,p_percent_base_amt                 NUMBER
                        ,p_int_base_amt                     NUMBER
                        ,p_dist_object_type                 VARCHAR2
                        ,p_dist_type                        VARCHAR2
                        ,p_dist_code                        VARCHAR2
                        )
RETURN T_IFAC_CARGO_VALUE
IS
    lt_sales_qty T_IFAC_CARGO_VALUE;
    lv2_sum_object_id VARCHAR2(32);
BEGIN
    lt_sales_qty := WrapInterfaceRecord(NULL);
    lt_sales_qty.INTERFACE_LEVEL       := ECDP_REVN_IFAC_WRAPPER.gconst_level_line_item;
    lt_sales_qty.LINE_ITEM_BASED_TYPE  := p_ifac_sample_qty.LINE_ITEM_BASED_TYPE;
    lt_sales_qty.LINE_ITEM_TYPE        := p_ifac_sample_qty.LINE_ITEM_TYPE;
    lt_sales_qty.VENDOR_CODE           := ECDP_REVN_IFAC_WRAPPER.gconst_sum_vendor_code_gen;
    lt_sales_qty.VENDOR_ID             := ec_company.object_id_by_uk(lt_sales_qty.VENDOR_CODE,'VENDOR') ;
    lt_sales_qty.PROFIT_CENTER_CODE    := nvl(p_dist_code,ECDP_REVN_IFAC_WRAPPER.gconst_sum_code);
    lv2_sum_object_id := ecdp_objects.GetObjIDFromCode(nvl(p_dist_object_type,'FIELD'),lt_sales_qty.PROFIT_CENTER_CODE);
    IF lv2_sum_object_id IS NULL AND p_dist_type = 'OBJECT_LIST' THEN
      lv2_sum_object_id := ec_object_list.object_id_by_uk(lt_sales_qty.PROFIT_CENTER_CODE);
    END IF;
    lt_sales_qty.PROFIT_CENTER_ID      := lv2_sum_object_id;
    lt_sales_qty.NET_QTY1              := p_qty_1;
    lt_sales_qty.NET_QTY2              := p_qty_2;
    lt_sales_qty.NET_QTY3              := p_qty_3;
    lt_sales_qty.NET_QTY4              := p_qty_4;
    lt_sales_qty.GRS_QTY1              := p_grs_qty_1;
    lt_sales_qty.GRS_QTY2              := p_grs_qty_2;
    lt_sales_qty.GRS_QTY3              := p_grs_qty_3;
    lt_sales_qty.GRS_QTY4              := p_grs_qty_4;
    lt_sales_qty.PRICING_VALUE         := p_pricing_value;
    lt_sales_qty.PERCENTAGE_VALUE      := p_ifac_sample_qty.PERCENTAGE_VALUE;
    lt_sales_qty.PERCENTAGE_BASE_AMOUNT:= p_percent_base_amt;
    lt_sales_qty.INT_BASE_AMOUNT       := p_int_base_amt;
    lt_sales_qty.CREATION_TYPE         := ECDP_REVN_IFAC_WRAPPER.gconst_creation_type_auto_gen;
    lt_sales_qty.CREATED_DATE          := Ecdp_Timestamp.getCurrentSysdate;

    FillCommonRecordFields_P(p_ifac_sample_qty, lt_sales_qty);

    RETURN lt_sales_qty;
END CreateLineItemLevelRecord_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION CreatePCLevelRecord_P(
                         p_ifac_sample_qty                  T_IFAC_CARGO_VALUE
                        ,p_profit_center_id                 VARCHAR2
                        ,p_vendor_id                        VARCHAR2
                        ,p_qty_1                            NUMBER
                        ,p_qty_2                            NUMBER
                        ,p_qty_3                            NUMBER
                        ,p_qty_4                            NUMBER
                        ,p_grs_qty_1                        NUMBER
                        ,p_grs_qty_2                        NUMBER
                        ,p_grs_qty_3                        NUMBER
                        ,p_grs_qty_4                        NUMBER
                        ,p_pricing_value                    NUMBER
                        ,p_percent_base_amt                 NUMBER
                        ,p_int_base_amt                     NUMBER
                        ,p_dist_method                      VARCHAR2
                        )
RETURN T_IFAC_CARGO_VALUE
IS
    lt_sales_qty T_IFAC_CARGO_VALUE;
BEGIN
    lt_sales_qty := WrapInterfaceRecord(NULL);
    lt_sales_qty.INTERFACE_LEVEL              := ECDP_REVN_IFAC_WRAPPER.gconst_level_profit_center;
    lt_sales_qty.LINE_ITEM_BASED_TYPE         := p_ifac_sample_qty.LINE_ITEM_BASED_TYPE;
    lt_sales_qty.LINE_ITEM_TYPE               := p_ifac_sample_qty.LINE_ITEM_TYPE;
    lt_sales_qty.VENDOR_CODE                  := NVL(ecdp_objects.getobjcode(p_vendor_id), ECDP_REVN_IFAC_WRAPPER.gconst_sum_vendor_code_gen);
    lt_sales_qty.VENDOR_ID                    := p_vendor_id;
    lt_sales_qty.PROFIT_CENTER_ID             := p_profit_center_id;
    lt_sales_qty.PROFIT_CENTER_CODE           := ecdp_objects.getobjcode(p_profit_center_id);
    lt_sales_qty.NET_QTY1                     := p_qty_1;
    lt_sales_qty.NET_QTY2                     := p_qty_2;
    lt_sales_qty.NET_QTY3                     := p_qty_3;
    lt_sales_qty.NET_QTY4                     := p_qty_4;
    lt_sales_qty.GRS_QTY1                     := p_grs_qty_1;
    lt_sales_qty.GRS_QTY2                     := p_grs_qty_2;
    lt_sales_qty.GRS_QTY3                     := p_grs_qty_3;
    lt_sales_qty.GRS_QTY4                     := p_grs_qty_4;
    lt_sales_qty.PRICING_VALUE                := p_pricing_value;
    lt_sales_qty.PERCENTAGE_VALUE             := p_ifac_sample_qty.PERCENTAGE_VALUE;
    lt_sales_qty.PERCENTAGE_BASE_AMOUNT       := p_percent_base_amt;
    lt_sales_qty.INT_BASE_AMOUNT              := p_int_base_amt;
    lt_sales_qty.LI_DIST_METHOD               := p_dist_method;
    lt_sales_qty.CREATED_BY                   := ECDP_REVN_IFAC_WRAPPER.gconst_creation_type_auto_gen;
    lt_sales_qty.CREATED_DATE                 := Ecdp_Timestamp.getCurrentSysdate;

    FillCommonRecordFields_P(p_ifac_sample_qty, lt_sales_qty);

    RETURN lt_sales_qty;
END CreatePCLevelRecord_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION CreateVendorLevelRecord_P(
                         p_ifac_sample_qty                  T_IFAC_CARGO_VALUE
                        ,p_profit_center_id                 VARCHAR2
                        ,p_vendor_id                        VARCHAR2
                        ,p_qty_1                            NUMBER
                        ,p_qty_2                            NUMBER
                        ,p_qty_3                            NUMBER
                        ,p_qty_4                            NUMBER
                        ,p_grs_qty_1                        NUMBER
                        ,p_grs_qty_2                        NUMBER
                        ,p_grs_qty_3                        NUMBER
                        ,p_grs_qty_4                        NUMBER
                        ,p_pricing_value                    NUMBER
                        ,p_percent_base_amt                 NUMBER
                        ,p_int_base_amt                     NUMBER
                        )
RETURN T_IFAC_CARGO_VALUE
IS
    lt_ifac_qty T_IFAC_CARGO_VALUE;
BEGIN
    lt_ifac_qty := WrapInterfaceRecord(NULL);
    lt_ifac_qty.INTERFACE_LEVEL             := ECDP_REVN_IFAC_WRAPPER.gconst_level_vendor;
    lt_ifac_qty.LINE_ITEM_BASED_TYPE        := p_ifac_sample_qty.LINE_ITEM_BASED_TYPE;
    lt_ifac_qty.LINE_ITEM_TYPE              := p_ifac_sample_qty.LINE_ITEM_TYPE;
    lt_ifac_qty.VENDOR_CODE                 := ecdp_objects.getobjcode(p_vendor_id);
    lt_ifac_qty.VENDOR_ID                   := p_vendor_id;
    lt_ifac_qty.PROFIT_CENTER_ID            := p_profit_center_id;
    lt_ifac_qty.PROFIT_CENTER_CODE          := ecdp_objects.getobjcode(p_profit_center_id);
    lt_ifac_qty.NET_QTY1                    := p_qty_1;
    lt_ifac_qty.NET_QTY2                    := p_qty_2;
    lt_ifac_qty.NET_QTY3                    := p_qty_3;
    lt_ifac_qty.NET_QTY4                    := p_qty_4;
    lt_ifac_qty.GRS_QTY1                    := p_grs_qty_1;
    lt_ifac_qty.GRS_QTY2                    := p_grs_qty_2;
    lt_ifac_qty.GRS_QTY3                    := p_grs_qty_3;
    lt_ifac_qty.GRS_QTY4                    := p_grs_qty_4;
    lt_ifac_qty.PRICING_VALUE               := p_pricing_value;
    lt_ifac_qty.PERCENTAGE_VALUE            := p_ifac_sample_qty.PERCENTAGE_VALUE;
    lt_ifac_qty.PERCENTAGE_BASE_AMOUNT      := p_percent_base_amt;
    lt_ifac_qty.INT_BASE_AMOUNT             := p_int_base_amt;
    lt_ifac_qty.CREATED_BY                  := ECDP_REVN_IFAC_WRAPPER.gconst_creation_type_auto_gen;
    lt_ifac_qty.CREATED_DATE                := Ecdp_Timestamp.getCurrentSysdate;

    FillCommonRecordFields_P(p_ifac_sample_qty, lt_ifac_qty);

    RETURN lt_ifac_qty;
END CreateVendorLevelRecord_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPCDistInfo_P(
                         p_common_data                      ECDP_REVN_IFAC_WRAPPER.T_GET_IFAC_COMMON_DATA
                        ,p_ifac_table                       T_TABLE_IFAC_CARGO_VALUE
                        ,p_level_calculate_from             VARCHAR2
                        ,p_level_calculate_from_actual      OUT VARCHAR2
                        )
RETURN T_TABLE_REVN_DIST_INFO
IS
    profit_center_dist_info T_TABLE_REVN_DIST_INFO;
    lt_temp_profit_center_id_table ECDP_REVN_IFAC_WRAPPER.T_TABLE_OBJECT_ID;
BEGIN
    profit_center_dist_info := T_TABLE_REVN_DIST_INFO();

    lt_temp_profit_center_id_table := ECDP_REVN_IFAC_WRAPPER.T_TABLE_OBJECT_ID();

    p_level_calculate_from_actual := ECDP_REVN_IFAC_WRAPPER.gconst_level_line_item;

    -- This method takes the splits for all the profit centers from the system configuration.
    ECDP_REVN_IFAC_WRAPPER.GetPCDistInfo_Trans_I(p_common_data, profit_center_dist_info);
    IF NVL(p_level_calculate_from, ECDP_REVN_IFAC_WRAPPER.gconst_level_vendor) = ECDP_REVN_IFAC_WRAPPER.gconst_level_vendor
    THEN
        FOR i_index IN p_ifac_table.FIRST .. p_ifac_table.LAST
        LOOP
            IF p_ifac_table(i_index).INTERFACE_LEVEL = ECDP_REVN_IFAC_WRAPPER.gconst_level_vendor
                AND NOT ECDP_REVN_IFAC_WRAPPER.ContainsObjectID_I(lt_temp_profit_center_id_table, p_ifac_table(i_index).PROFIT_CENTER_ID)
            THEN
                ECDP_REVN_IFAC_WRAPPER.AddPCDistInfo_I(lt_temp_profit_center_id_table, p_ifac_table(i_index).PROFIT_CENTER_ID);
                p_level_calculate_from_actual := p_ifac_table(i_index).INTERFACE_LEVEL;
            END IF;
        END LOOP;
    END IF;

    IF NVL(p_level_calculate_from, ECDP_REVN_IFAC_WRAPPER.gconst_level_profit_center) = ECDP_REVN_IFAC_WRAPPER.gconst_level_profit_center
        AND lt_temp_profit_center_id_table.COUNT = 0
    THEN
        FOR i_index IN p_ifac_table.FIRST .. p_ifac_table.LAST
        LOOP
            IF p_ifac_table(i_index).INTERFACE_LEVEL = ECDP_REVN_IFAC_WRAPPER.gconst_level_profit_center
                AND NOT ECDP_REVN_IFAC_WRAPPER.ContainsObjectID_I(lt_temp_profit_center_id_table, p_ifac_table(i_index).PROFIT_CENTER_ID)
            THEN
                ECDP_REVN_IFAC_WRAPPER.AddPCDistInfo_I(lt_temp_profit_center_id_table, p_ifac_table(i_index).PROFIT_CENTER_ID);
                p_level_calculate_from_actual := p_ifac_table(i_index).INTERFACE_LEVEL;
            END IF;
        END LOOP;
    END IF;

    IF lt_temp_profit_center_id_table.COUNT > 0
    THEN
        profit_center_dist_info := ECDP_REVN_IFAC_WRAPPER.FilterPCDistInfoItem_I(profit_center_dist_info, lt_temp_profit_center_id_table);
    END IF;

    RETURN profit_center_dist_info;
END GetPCDistInfo_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPCDistFromProcessedDoc_P(
                         p_common_data                      ECDP_REVN_IFAC_WRAPPER.T_GET_IFAC_COMMON_DATA
                        ,p_ifac_table                       T_TABLE_IFAC_CARGO_VALUE
                        ,p_level_calculate_from             VARCHAR2
                        ,p_level_calculate_from_actual      OUT VARCHAR2
                        )
RETURN T_TABLE_REVN_DIST_INFO
IS
  CURSOR c_share_from_processed_doc( cp_document_key            VARCHAR2)
   IS
  SELECT distinct(clid.split_share),clid.split_method,clid.profit_centre_id,clid.stream_item_id
  FROM cont_line_item_dist clid
  WHERE clid.document_key= cp_document_key
  And clid.line_item_based_type = 'QTY';

    profit_center_dist_info T_TABLE_REVN_DIST_INFO;
    lt_temp_profit_center_id_table ECDP_REVN_IFAC_WRAPPER.T_TABLE_OBJECT_ID;
BEGIN
    profit_center_dist_info := T_TABLE_REVN_DIST_INFO();

    lt_temp_profit_center_id_table := ECDP_REVN_IFAC_WRAPPER.T_TABLE_OBJECT_ID();

    p_level_calculate_from_actual := ECDP_REVN_IFAC_WRAPPER.gconst_level_line_item;
     FOR i_pc_dist_info IN c_share_from_processed_doc(p_common_data.IFAC_PREC_DOCUMENT_KEY) LOOP
                IF NOT ECDP_REVN_IFAC_WRAPPER.ContainsDistInfo_I(profit_center_dist_info, NULL,i_pc_dist_info.PROFIT_CENTRE_ID) THEN
                    profit_center_dist_info.EXTEND(1);
                    profit_center_dist_info(profit_center_dist_info.LAST) := T_REVN_DIST_INFO(null,null,null,null,null,null,null);
                    profit_center_dist_info(profit_center_dist_info.LAST).STREAM_ITEM_ID         := i_pc_dist_info.PROFIT_CENTRE_ID;
                    profit_center_dist_info(profit_center_dist_info.LAST).PROFIT_CENTER_ID       := i_pc_dist_info.PROFIT_CENTRE_ID;
                    profit_center_dist_info(profit_center_dist_info.LAST).SPLIT_KEY_ID           := p_common_data.TRANS_SPLIT_KEY_ID;
                    profit_center_dist_info(profit_center_dist_info.LAST).CHILD_SPLIT_KEY_ID     := ec_split_key_setup.child_split_key_id(p_common_data.TRANS_SPLIT_KEY_ID, i_pc_dist_info.PROFIT_CENTRE_ID, p_common_data.IFAC_PROCESSING_PERIOD, '<=');
                    profit_center_dist_info(profit_center_dist_info.LAST).SPLIT_SHARE            := i_pc_dist_info.SPLIT_SHARE;
                    profit_center_dist_info(profit_center_dist_info.LAST).DIST_METHOD            := 'QTY';
                END IF;
     END LOOP;

    RETURN profit_center_dist_info;
END GetPCDistFromProcessedDoc_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION CheckAndFillLineItemLevel_P(
                         p_common_data                      ECDP_REVN_IFAC_WRAPPER.T_GET_IFAC_COMMON_DATA
                        ,p_ifac_table                       IN OUT NOCOPY T_TABLE_IFAC_CARGO_VALUE
                        )
RETURN NUMBER
IS
    lt_sales_sample_qty T_IFAC_CARGO_VALUE;
    ln_qty_1 NUMBER;
    ln_qty_2 NUMBER;
    ln_qty_3 NUMBER;
    ln_qty_4 NUMBER;
    ln_pricing_value NUMBER;
    ln_percent_base_amt NUMBER;
    ln_int_base_amt NUMBER;
    ln_grs_qty_1 NUMBER;
    ln_grs_qty_2 NUMBER;
    ln_grs_qty_3 NUMBER;
    ln_grs_qty_4 NUMBER;
    lv2_level_calculated_from VARCHAR2(32);
    ln_record_index NUMBER;
BEGIN
    IF p_ifac_table.COUNT = 0
    THEN
        RETURN NULL;
    END IF;

    ln_record_index := p_common_data.LI_LEVEL_IFAC_INDEX;

       IF (UPPER(p_common_data.TRANS_DIST_TYPE)='OBJECT_LIST' AND  ecdp_object_list.VerifySplitShare(ec_object_list.object_id_by_uk(p_common_data.TRANS_DIST_CODE),p_common_data.IFAC_PERIOD_START_DATE)=ecdp_revn_common.gv2_false
           AND p_common_data.TRANS_IS_REDUCED_CONFIG
           AND LevelRecordsExists_P(p_ifac_table, EcDp_REVN_IFAC_WRAPPER.gconst_level_line_item, EcDp_REVN_IFAC_WRAPPER.gconst_creation_type_interface)
           AND NOT LevelRecordsExists_P(p_ifac_table, EcDp_REVN_IFAC_WRAPPER.gconst_level_profit_center, EcDp_REVN_IFAC_WRAPPER.gconst_creation_type_interface)
           AND NOT LevelRecordsExists_P(p_ifac_table, EcDp_REVN_IFAC_WRAPPER.gconst_level_vendor, EcDp_REVN_IFAC_WRAPPER.gconst_creation_type_interface)
           )
         THEN
           RAISE_APPLICATION_ERROR(-20000, 'Error:'||'Split share of object list '||p_common_data.TRANS_DIST_CODE ||'for date '||p_common_data.IFAC_PERIOD_START_DATE|| ' not added to 100%');
        END IF;

    IF ln_record_index IS NULL
    THEN
        IF NOT CalculateQuantities_P(p_ifac_table, NULL, NULL, NULL,
                        ln_qty_1, ln_qty_2, ln_qty_3, ln_qty_4,
                        ln_grs_qty_1, ln_grs_qty_2, ln_grs_qty_3, ln_grs_qty_4,ln_pricing_value, ln_percent_base_amt,ln_int_base_amt ,lv2_level_calculated_from)
        THEN
            RAISE ECDP_REVN_IFAC_WRAPPER.ge_record_qty_missing;
        END IF;

        lt_sales_sample_qty := p_ifac_table(1);
        p_ifac_table.EXTEND(1);
        p_ifac_table(p_ifac_table.LAST) := CreateLineItemLevelRecord_P(
                        lt_sales_sample_qty, ln_qty_1, ln_qty_2, ln_qty_3, ln_qty_4, ln_grs_qty_1, ln_grs_qty_2, ln_grs_qty_3, ln_grs_qty_4, ln_pricing_value, ln_percent_base_amt, ln_int_base_amt,
                        p_common_data.TRANS_DIST_OBJECT_TYPE,
                        p_common_data.TRANS_DIST_TYPE,
                        p_common_data.TRANS_DIST_CODE);
        ln_record_index := p_ifac_table.LAST;
    END IF;

    RETURN ln_record_index;
EXCEPTION
    WHEN ECDP_REVN_IFAC_WRAPPER.ge_record_qty_missing
    THEN
        RAISE_APPLICATION_ERROR(-20000, 'Cannot find QTY values on interface records.');
END CheckAndFillLineItemLevel_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetIfacQTY1_P(p_ifac_table         T_TABLE_IFAC_CARGO_VALUE
                      ,p_ifac_level         varchar2
                      ,p_profit_center_id   varchar2 DEFAULT NULL)
RETURN NUMBER
IS
    ln_qty NUMBER;
BEGIN
    -- Get QTY1 from LI (sum of all PS's).
    ln_qty := 0;
    FOR i_it IN p_ifac_table.FIRST .. p_ifac_table.LAST
    LOOP
        IF  p_ifac_table(i_it).INTERFACE_LEVEL = p_ifac_level
        AND p_ifac_table(i_it).PROFIT_CENTER_ID = nvl(p_profit_center_id, p_ifac_table(i_it).PROFIT_CENTER_ID)
        THEN
            ln_qty := p_ifac_table(i_it).NET_QTY1;
        END IF;
    END LOOP;
    RETURN ln_qty;
END GetIfacQTY1_P;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE CheckAndFillPCLevel_P(
                         p_common_data                      ECDP_REVN_IFAC_WRAPPER.T_GET_IFAC_COMMON_DATA
                        ,p_profit_center_dist_info          IN OUT NOCOPY T_TABLE_REVN_DIST_INFO
                        ,p_ifac_table                       IN OUT NOCOPY T_TABLE_IFAC_CARGO_VALUE
                        )
IS
    lt_sales_sample_qty T_IFAC_CARGO_VALUE;
    ln_qty_li NUMBER;
    ln_qty_1 NUMBER;
    ln_qty_2 NUMBER;
    ln_qty_3 NUMBER;
    ln_qty_4 NUMBER;
    ln_grs_qty_1 NUMBER;
    ln_grs_qty_2 NUMBER;
    ln_grs_qty_3 NUMBER;
    ln_grs_qty_4 NUMBER;
    ln_pricing_value NUMBER;
    ln_percentage_base_amt NUMBER;
    ln_int_base_amt NUMBER;
    lv2_level_calculated_from VARCHAR2(32);
    lv2_document_id VARCHAR2(32) ;
    lb_doc_booked BOOLEAN;
BEGIN
    IF p_ifac_table.COUNT = 0
    THEN
        RETURN;
    END IF;

    -- Look up the LineItem QTY1 value.
    ln_qty_li := GetIfacQTY1_P(p_ifac_table,ECDP_REVN_IFAC_WRAPPER.gconst_level_line_item);
    IF(p_common_data.LI_ITEM_BASED_TYPE = 'QTY')
    THEN
        p_profit_center_dist_info := GetPCDistInfo_P(p_common_data, p_ifac_table, NULL, lv2_level_calculated_from);
    ELSE
           -- It has to check if the doc already exists and is not booked then get the fall back shares from qty
        lb_doc_booked := CASE WHEN ec_cont_document.document_level_code(p_common_data.IFAC_PREC_DOCUMENT_KEY) = 'BOOKED' THEN TRUE ELSE FALSE END;
      --Means there was already a qty line iteam and its share is used .SO dist method must be qty
        IF(p_profit_center_dist_info IS Not NULL AND p_profit_center_dist_info.COUNT > 0)
        THEN
          p_profit_center_dist_info(p_profit_center_dist_info.last).DIST_METHOD :='QTY';
         -- Not booked and no distribution, look for shares on open documents with QTY's.
        ELSE IF((lb_doc_booked = false) AND ( p_profit_center_dist_info IS NULL OR p_profit_center_dist_info.count = 0)) --means document already exists and this is a modification
        THEN
            p_profit_center_dist_info := GetPCDistFromProcessedDoc_P(p_common_data, p_ifac_table, NULL, lv2_level_calculated_from);
        -- If shares is still empty, get it from the system.
        END IF;
        END IF;
        IF p_profit_center_dist_info IS NULL OR p_profit_center_dist_info.COUNT = 0
        THEN
            p_profit_center_dist_info := GetPCDistInfo_P(p_common_data, p_ifac_table, NULL, lv2_level_calculated_from);
        END IF;

    END IF;
    IF LevelRecordsExists_P(p_ifac_table, ECDP_REVN_IFAC_WRAPPER.gconst_level_profit_center)
    THEN
        -- Calculate ProfitCenter shares and update the share table (for QTY type only).
        FOR i_it IN p_ifac_table.FIRST .. p_ifac_table.LAST
        LOOP
            IF p_ifac_table(i_it).INTERFACE_LEVEL = 'FIELD'
            THEN
              -- Update the share table
            FOR i_field_index IN p_profit_center_dist_info.FIRST .. p_profit_center_dist_info.LAST
            LOOP
               IF  (p_profit_center_dist_info(i_field_index).PROFIT_CENTER_ID = p_ifac_table(i_it).PROFIT_CENTER_ID)
                  AND (p_profit_center_dist_info(i_field_index).VENDOR_ID IS NULL)
                  THEN
                      p_profit_center_dist_info(i_field_index).SPLIT_SHARE := CASE ln_qty_li WHEN 0 THEN 0 ELSE p_ifac_table(i_it).NET_QTY1 / ln_qty_li END;
                      p_profit_center_dist_info(i_field_index).DIST_METHOD := 'IFAC_PC';
               END IF;
              END LOOP;
            END IF;
        END LOOP;
    ELSE
        IF p_profit_center_dist_info IS NOT NULL AND p_profit_center_dist_info.COUNT > 0
        THEN
            FOR i_field_index IN p_profit_center_dist_info.FIRST .. p_profit_center_dist_info.LAST
            LOOP
                -- Skip if this is a Vendor share
                IF p_profit_center_dist_info(i_field_index).VENDOR_ID IS NOT NULL
                THEN
                    RETURN;
                END IF;

                IF CalculateQuantities_P(p_ifac_table,
                        p_profit_center_dist_info(i_field_index).PROFIT_CENTER_ID, NULL, ECDP_REVN_IFAC_WRAPPER.gconst_level_vendor,
                        ln_qty_1, ln_qty_2, ln_qty_3, ln_qty_4, ln_grs_qty_1, ln_grs_qty_2, ln_grs_qty_3, ln_grs_qty_4, ln_pricing_value, ln_percentage_base_amt, ln_int_base_amt,
                        lv2_level_calculated_from)
                THEN
                    -- Update the share in the dist table.
                    p_profit_center_dist_info(i_field_index).SPLIT_SHARE := CASE ln_qty_li WHEN 0 THEN 0 ELSE ln_qty_1 / ln_qty_li END;
                ELSE
                    IF CalculateQuantities_P(p_ifac_table,
                        NULL, NULL, ECDP_REVN_IFAC_WRAPPER.gconst_level_line_item,
                        ln_qty_1, ln_qty_2, ln_qty_3, ln_qty_4,ln_grs_qty_1, ln_grs_qty_2, ln_grs_qty_3, ln_grs_qty_4, ln_pricing_value, ln_percentage_base_amt ,ln_int_base_amt,
                        lv2_level_calculated_from)
                    THEN
                            ln_qty_1               := ln_qty_1 * p_profit_center_dist_info(i_field_index).SPLIT_SHARE;
                            ln_qty_2               := ln_qty_2 * p_profit_center_dist_info(i_field_index).SPLIT_SHARE;
                            ln_qty_3               := ln_qty_3 * p_profit_center_dist_info(i_field_index).SPLIT_SHARE;
                            ln_qty_4               := ln_qty_4 * p_profit_center_dist_info(i_field_index).SPLIT_SHARE;
                            ln_grs_qty_1           := ln_grs_qty_1 * p_profit_center_dist_info(i_field_index).SPLIT_SHARE;
                            ln_grs_qty_2           := ln_grs_qty_2 * p_profit_center_dist_info(i_field_index).SPLIT_SHARE;
                            ln_grs_qty_3           := ln_grs_qty_3 * p_profit_center_dist_info(i_field_index).SPLIT_SHARE;
                            ln_grs_qty_4           := ln_grs_qty_4 * p_profit_center_dist_info(i_field_index).SPLIT_SHARE;
                            ln_pricing_value       := ln_pricing_value * p_profit_center_dist_info(i_field_index).SPLIT_SHARE;
                            ln_percentage_base_amt := ln_percentage_base_amt * p_profit_center_dist_info(i_field_index).SPLIT_SHARE;
                            ln_int_base_amt        := ln_int_base_amt * p_profit_center_dist_info(i_field_index).SPLIT_SHARE;
                    END IF;
                END IF;

                lt_sales_sample_qty := p_ifac_table(1);
                p_ifac_table.EXTEND(1);
                p_ifac_table(p_ifac_table.LAST) := CreatePCLevelRecord_P(
                                lt_sales_sample_qty, p_profit_center_dist_info(i_field_index).PROFIT_CENTER_ID,
                                p_ifac_table(p_common_data.LI_LEVEL_IFAC_INDEX).VENDOR_ID,
                                ln_qty_1, ln_qty_2, ln_qty_3, ln_qty_4,  ln_grs_qty_1, ln_grs_qty_2,ln_grs_qty_3,ln_grs_qty_4,ln_pricing_value,ln_percentage_base_amt,ln_int_base_amt,p_profit_center_dist_info(i_field_index).DIST_METHOD);
            END LOOP;
        END IF;
    END IF;
EXCEPTION
    WHEN ECDP_REVN_IFAC_WRAPPER.ge_record_qty_missing
    THEN
        RAISE_APPLICATION_ERROR(-20000, 'Cannot find QTY values on either transaction or vendor level records.');
END CheckAndFillPCLevel_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE CheckAndFillVendorLevel_P(
                         p_common_data                      ECDP_REVN_IFAC_WRAPPER.T_GET_IFAC_COMMON_DATA
                        ,p_profit_center_dist_info          IN OUT NOCOPY T_TABLE_REVN_DIST_INFO
                        ,p_ifac_table                       IN OUT NOCOPY T_TABLE_IFAC_CARGO_VALUE
                        )
IS
    lt_sales_sample_qty T_IFAC_CARGO_VALUE;
    ln_qty_ps NUMBER;
    ln_qty_1 NUMBER;
    ln_qty_2 NUMBER;
    ln_qty_3 NUMBER;
    ln_qty_4 NUMBER;
    ln_grs_qty_1 NUMBER;
    ln_grs_qty_2 NUMBER;
    ln_grs_qty_3 NUMBER;
    ln_grs_qty_4 NUMBER;
    ln_pricing_value  NUMBER;
    ln_percent_base_amt NUMBER;
    ln_int_base_amt  NUMBER;
    vendor_dist_info T_TABLE_REVN_DIST_INFO;
    lo_profit_center_dist_info_idx NUMBER;
BEGIN
    IF p_ifac_table.COUNT = 0
    THEN
        RETURN;
    END IF;

    IF LevelRecordsExists_P(p_ifac_table, ECDP_REVN_IFAC_WRAPPER.gconst_level_vendor)
    THEN
        -- Update the shares from QTY1
        FOR i_ifac_index IN p_ifac_table.FIRST .. p_ifac_table.LAST
        LOOP
            IF p_ifac_table(i_ifac_index).INTERFACE_LEVEL = ECDP_REVN_IFAC_WRAPPER.gconst_level_vendor
            THEN
              ln_qty_ps := GetIfacQTY1_P(p_ifac_table, ECDP_REVN_IFAC_WRAPPER.gconst_level_profit_center, p_ifac_table(i_ifac_index).PROFIT_CENTER_ID);
              EcDp_REVN_IFAC_WRAPPER.CheckAndFillDistInfo_I(p_profit_center_dist_info, p_ifac_table(i_ifac_index).PROFIT_CENTER_ID, p_ifac_table(i_ifac_index).VENDOR_ID, CASE ln_qty_ps WHEN 0 THEN 0 ELSE p_ifac_table(i_ifac_index).NET_QTY1 / ln_qty_ps END);
              p_ifac_table(i_ifac_index).LI_DIST_METHOD := 'IFAC_COMP';
            END IF;
        END LOOP;
    ELSE
        FOR i_ifac_index IN p_ifac_table.FIRST .. p_ifac_table.LAST
        LOOP
            IF p_ifac_table(i_ifac_index).INTERFACE_LEVEL = ECDP_REVN_IFAC_WRAPPER.gconst_level_profit_center
            THEN
                -- Look for existing vendor share
                vendor_dist_info := ECDP_REVN_IFAC_WRAPPER.GetVendorDistInfo_I(p_profit_center_dist_info, p_ifac_table(i_ifac_index).PROFIT_CENTER_ID);
                IF vendor_dist_info IS NULL OR vendor_dist_info.COUNT = 0
                THEN
                    -- Get vendor share from config
                    lo_profit_center_dist_info_idx := ECDP_REVN_IFAC_WRAPPER.FindDistInfo_I(
                                                   p_profit_center_dist_info,
                                                   p_ifac_table(i_ifac_index).PROFIT_CENTER_ID,
                                                   NULL);

                    IF lo_profit_center_dist_info_idx > 0
                    THEN
                        vendor_dist_info := ECDP_REVN_IFAC_WRAPPER.GetVendorDistInfoFromConfig_I(
                                                   p_common_data,
                                                   p_profit_center_dist_info(lo_profit_center_dist_info_idx));
                    END IF;
                END IF;

                IF vendor_dist_info IS NOT NULL AND vendor_dist_info.COUNT > 0
                THEN
                    FOR i_vendor_index IN vendor_dist_info.FIRST .. vendor_dist_info.LAST
                    LOOP
                        ln_qty_1 := p_ifac_table(i_ifac_index).NET_QTY1 * vendor_dist_info(i_vendor_index).SPLIT_SHARE;
                        ln_qty_2 := p_ifac_table(i_ifac_index).NET_QTY2 * vendor_dist_info(i_vendor_index).SPLIT_SHARE;
                        ln_qty_3 := p_ifac_table(i_ifac_index).NET_QTY3 * vendor_dist_info(i_vendor_index).SPLIT_SHARE;
                        ln_qty_4 := p_ifac_table(i_ifac_index).NET_QTY4 * vendor_dist_info(i_vendor_index).SPLIT_SHARE;
                        ln_grs_qty_1 := p_ifac_table(i_ifac_index).GRS_QTY1 * vendor_dist_info(i_vendor_index).SPLIT_SHARE;
                        ln_grs_qty_2 := p_ifac_table(i_ifac_index).GRS_QTY2 * vendor_dist_info(i_vendor_index).SPLIT_SHARE;
                        ln_grs_qty_3 := p_ifac_table(i_ifac_index).GRS_QTY3 * vendor_dist_info(i_vendor_index).SPLIT_SHARE;
                        ln_grs_qty_4 := p_ifac_table(i_ifac_index).GRS_QTY4 * vendor_dist_info(i_vendor_index).SPLIT_SHARE;
                        ln_pricing_value    := p_ifac_table(i_ifac_index).pricing_value * vendor_dist_info(i_vendor_index).SPLIT_SHARE;
                        ln_percent_base_amt := p_ifac_table(i_ifac_index).percentage_base_amount * vendor_dist_info(i_vendor_index).SPLIT_SHARE;
                        ln_int_base_amt     := p_ifac_table(i_ifac_index).int_base_amount * vendor_dist_info(i_vendor_index).SPLIT_SHARE;
                        lt_sales_sample_qty := p_ifac_table(1);
                        p_ifac_table.EXTEND(1);
                        p_ifac_table(p_ifac_table.LAST) := CreateVendorLevelRecord_P(
                                        lt_sales_sample_qty, p_ifac_table(i_ifac_index).PROFIT_CENTER_ID,
                                        vendor_dist_info(i_vendor_index).VENDOR_ID, ln_qty_1, ln_qty_2, ln_qty_3, ln_qty_4, ln_grs_qty_1, ln_grs_qty_2, ln_grs_qty_3, ln_grs_qty_4 , ln_pricing_value, ln_percent_base_amt, ln_int_base_amt);

                        -- Add vendor dist
                        EcDp_REVN_IFAC_WRAPPER.CheckAndFillDistInfo_I(p_profit_center_dist_info, vendor_dist_info(i_vendor_index).PROFIT_CENTER_ID, vendor_dist_info(i_vendor_index).VENDOR_ID, vendor_dist_info(i_vendor_index).SPLIT_SHARE);
                    END LOOP;
                END IF;
            END IF;
        END LOOP;
    END IF;
END CheckAndFillVendorLevel_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION CreateCommonData_P(
                         p_records                          T_TABLE_IFAC_CARGO_VALUE
                        )
RETURN ECDP_REVN_IFAC_WRAPPER.T_GET_IFAC_COMMON_DATA
IS
    lrec_trans_version TRANSACTION_TMPL_VERSION%ROWTYPE;
    lv2_error_msg VARCHAR2(100);

    lo_sample_ifac_data T_IFAC_CARGO_VALUE;
    lo_common_data ECDP_REVN_IFAC_WRAPPER.T_GET_IFAC_COMMON_DATA;
BEGIN
    lo_sample_ifac_data := p_records(1);

    lo_common_data.IFAC_PROCESSING_PERIOD := ECDP_REVN_IFAC_COMMON.GetCargoProcessingPeriod(lo_sample_ifac_data, EC_CONTRACT.start_date(lo_sample_ifac_data.CONTRACT_ID));
    lrec_trans_version := ec_transaction_tmpl_version.row_by_pk(lo_sample_ifac_data.TRANS_TEMP_ID, lo_common_data.IFAC_PROCESSING_PERIOD, '<=');

    lo_common_data.CONTRACT_COMPANY_CODE := ec_company.object_code(ec_contract_version.company_id(lo_sample_ifac_data.Contract_Id, lo_common_data.IFAC_PROCESSING_PERIOD,'<='));
    lo_common_data.CONTRACT_COMPOSITION := ecdp_contract_setup.GetContractComposition(lo_sample_ifac_data.Contract_Id,lo_sample_ifac_data.TRANS_TEMP_ID, lo_common_data.IFAC_PROCESSING_PERIOD);
    lo_common_data.TRANS_SI_ID := lrec_trans_version.stream_item_id;
    lo_common_data.CONTRACT_FINANCIAL_CODE := ec_contract_version.financial_code(lo_sample_ifac_data.CONTRACT_ID, lo_common_data.IFAC_PROCESSING_PERIOD, '<=');
    lo_common_data.TRANS_IS_REDUCED_CONFIG := ECDP_TRANSACTION.IsReducedConfig(
                                lo_sample_ifac_data.CONTRACT_ID,
                                lo_sample_ifac_data.DOC_SETUP_ID,
                                lo_sample_ifac_data.TRANS_TEMP_ID,
                                NULL,
                                lo_common_data.IFAC_PROCESSING_PERIOD);

    IF lo_common_data.TRANS_SI_ID IS NULL
    THEN
        lo_common_data.TRANS_SI_ID := ecdp_transaction.GetTransStreamItem(
                                 'NONE'
                                ,'sysadmin'
                                ,NULL
                                ,'Y'
                                ,lv2_error_msg
                                ,lo_sample_ifac_data.TRANS_TEMP_ID
                                ,lo_common_data.IFAC_PROCESSING_PERIOD
                                ,lo_sample_ifac_data.UOM1_CODE
                                ,lo_sample_ifac_data.PRODUCT_ID
                                );
    END IF;

    lo_common_data.TRANS_DIST_ID := ECDP_TRANSACTION.GetDistObjectID(lo_common_data.CONTRACT_COMPOSITION, lrec_trans_version.dist_code, lrec_trans_version.dist_object_type);
    lo_common_data.TRANS_SPLIT_KEY_ID := lrec_trans_version.split_key_id;
    lo_common_data.TRANS_SI_STREAM_ID := ec_stream_item.stream_id(lo_common_data.TRANS_SI_ID);
    lo_common_data.LI_LEVEL_IFAC_INDEX := FindLineItemLevelRecord_P(p_records);
    lo_common_data.TRANS_DIST_SPLIT_TYPE := lrec_trans_version.dist_split_type;
    lo_common_data.IFAC_PRODUCT_ID := lo_sample_ifac_data.PRODUCT_ID;
    lo_common_data.IFAC_UOM1_CODE := lo_sample_ifac_data.UOM1_CODE;
    lo_common_data.IFAC_CONTRACT_ID := lo_sample_ifac_data.CONTRACT_ID;
    lo_common_data.IFAC_CUSTOMER_ID := lo_sample_ifac_data.CUSTOMER_ID;
    lo_common_data.IFAC_TRANSACTION_TEMPLATE_ID := lo_sample_ifac_data.TRANS_TEMP_ID;
    lo_common_data.TRANS_USE_STREAM_ITEM_IND := lrec_trans_version.use_stream_items_ind;
    lo_common_data.TRANS_DIST_CODE := lrec_trans_version.dist_code;
    lo_common_data.TRANS_DIST_TYPE := lrec_trans_version.dist_type;
    lo_common_data.TRANS_DIST_OBJECT_TYPE := lrec_trans_version.dist_object_type;
    lo_common_data.IFAC_PERIOD_START_DATE := lo_common_data.IFAC_PROCESSING_PERIOD;
    lo_common_data.IFAC_PREC_DOCUMENT_KEY := lo_sample_ifac_data.PRECEDING_DOC_KEY;
    lo_common_data.LI_ITEM_BASED_TYPE := lo_sample_ifac_data.LINE_ITEM_BASED_TYPE;
    lo_common_data.LINE_ITEM_TYPE := lo_sample_ifac_data.line_item_type;
    lo_common_data.UNIT_PRICE_UNIT := lo_sample_ifac_data.UNIT_PRICE_UNIT;
    lo_common_data.LI_UNIQUE_KEY_1 := lo_sample_ifac_data.LI_UNIQUE_KEY_1;
    lo_common_data.LI_UNIQUE_KEY_2 := lo_sample_ifac_data.LI_UNIQUE_KEY_2;

    RETURN lo_common_data;
END CreateCommonData_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE CompleteIfac_P(
                         p_records                          IN OUT NOCOPY T_TABLE_IFAC_CARGO_VALUE
                        ,p_qty_pc_share                     IN OUT NOCOPY T_TABLE_REVN_DIST_INFO
                        )
IS
    lo_profit_center_dist_info T_TABLE_REVN_DIST_INFO;
    lo_common_data ECDP_REVN_IFAC_WRAPPER.T_GET_IFAC_COMMON_DATA;
    ln_percentage_value        NUMBER;
    ln_trans_id                NUMBER;
    ln_li_id                   NUMBER;
BEGIN
    IF p_records.COUNT >0
    THEN
      -- If share already given, put it as default for PC and VENDOR.
        IF p_records(p_records.LAST).INTERFACE_LEVEL = EcDp_REVN_FT_CONSTANTS.ifac_level_line_item
        THEN
            lo_profit_center_dist_info := p_qty_pc_share;
        END IF;

        -- Create common data from scratch.
        lo_common_data := CreateCommonData_P(p_records);
        lo_common_data.LI_LEVEL_IFAC_INDEX := CheckAndFillLineItemLevel_P(lo_common_data, p_records);

        CheckAndFillPCLevel_P(lo_common_data, lo_profit_center_dist_info, p_records);
        CheckAndFillVendorLevel_P(lo_common_data, lo_profit_center_dist_info, p_records);

         -- Quality check for PERCENTAGE_VALUE
        IF p_records(p_records.LAST).LINE_ITEM_BASED_TYPE = EcDp_REVN_FT_CONSTANTS.li_btype_percentage_all
        OR p_records(p_records.LAST).LINE_ITEM_BASED_TYPE = EcDp_REVN_FT_CONSTANTS.li_btype_percentage_qty
        OR p_records(p_records.LAST).LINE_ITEM_BASED_TYPE = EcDp_REVN_FT_CONSTANTS.li_btype_percentage_manual
        THEN
            ln_trans_id         := p_records(p_records.LAST).TRANS_ID;
            ln_li_id            := p_records(p_records.LAST).LI_ID;
            ln_percentage_value := p_records(p_records.LAST).PERCENTAGE_VALUE;

            FOR i_records_index IN p_records.FIRST .. p_records.LAST
            LOOP
                IF  p_records(i_records_index).TRANS_ID = ln_trans_id
                AND p_records(i_records_index).LI_ID = ln_li_id
                AND p_records(i_records_index).PERCENTAGE_VALUE <> ln_percentage_value
                THEN
                    RAISE_APPLICATION_ERROR(-20000, 'Error: Interfaced values in the "PERCENTAGE_VALUE" column are not equal on ALL levels for interface type "'||p_records(i_records_index).LINE_ITEM_BASED_TYPE || '".');
                END IF;
            END LOOP;
        END IF;

         -- Return the new share. Only if QTY records exists.
        IF p_records(p_records.FIRST).LINE_ITEM_BASED_TYPE = EcDp_REVN_FT_CONSTANTS.li_btype_quantity
        THEN
            p_qty_pc_share := lo_profit_center_dist_info;
        END IF;


        -- Testing start: Log the share
        /*
        if p_qty_pc_share is not null and p_qty_pc_share.count > 0 then
            FOR i_share IN p_qty_pc_share.FIRST .. p_qty_pc_share.LAST
            LOOP
                -- Profit Senter
                if p_qty_pc_share(i_share).PROFIT_CENTER_ID is not null and p_qty_pc_share(i_share).VENDOR_ID is null then
                  ecdp_dynsql.WriteTempText('GHO_PS_' || lo_common_data.LI_ITEM_BASED_TYPE, rpad(ecdp_objects.GetObjCode(p_qty_pc_share(i_share).PROFIT_CENTER_ID),10,' ') || '=' || p_qty_pc_share(i_share).SPLIT_SHARE);
                end if;
                -- Vendor
                if p_qty_pc_share(i_share).VENDOR_ID is not null then
                  ecdp_dynsql.WriteTempText('GHO_V_' || lo_common_data.LI_ITEM_BASED_TYPE, rpad(ecdp_objects.GetObjCode(p_qty_pc_share(i_share).PROFIT_CENTER_ID),10,' ') || '-> ' || rpad(ecdp_objects.GetObjCode(p_qty_pc_share(i_share).VENDOR_ID),15,' ') || '=' || p_qty_pc_share(i_share).SPLIT_SHARE);
                end if;
            END LOOP;
        end if;
        */
        -- Testing end

    END IF;
END CompleteIfac_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetIfacForLineItem(
                         p_contract_id                     VARCHAR2
                        ,p_customer_id                     VARCHAR2
                        ,p_cargo_no                        VARCHAR2
                        ,p_parcel_no                       VARCHAR2
                        ,p_uom1_code                       VARCHAR2
                        ,p_doc_status                      VARCHAR2
                        ,p_cli_uk1                         VARCHAR2
                        ,p_cli_uk2                         VARCHAR2
                        ,p_ifac_tt_conn_code               VARCHAR2
                        ,p_ifac_li_conn_code               VARCHAR2
                        ,p_price_concept_code              VARCHAR2
                        ,p_price_object_id                 VARCHAR2
                        ,p_trans_temp_id                   VARCHAR2
                        ,p_qty_pc_share                    IN OUT NOCOPY T_TABLE_REVN_DIST_INFO
                        ,p_line_item_based_type            VARCHAR2 DEFAULT 'QTY'
                        ,p_line_item_type                  VARCHAR2 DEFAULT NULL
                        ,p_line_item_code                  VARCHAR2 DEFAULT NULL
                        )
RETURN T_TABLE_IFAC_CARGO_VALUE
IS
    lt_ifac_table T_TABLE_IFAC_CARGO_VALUE;
    n_ifac_table_index NUMBER;

    CURSOR c_ifac_data(
               cp_contract_id          VARCHAR2
              ,cp_customer_id          VARCHAR2
              ,cp_cargo_no             VARCHAR2
              ,cp_parcel_no            VARCHAR2
              ,cp_uom1_code            VARCHAR2
              ,cp_doc_status           VARCHAR2
              ,cp_cli_uk1              VARCHAR2
              ,cp_cli_uk2              VARCHAR2
              ,cp_ifac_tt_conn_code    VARCHAR2
              ,cp_if_li_conn_code      VARCHAR2
              ,cp_price_concept_code   VARCHAR2 DEFAULT NULL
              ,cp_price_object_id      VARCHAR2 DEFAULT NULL
              ,cp_trans_temp_id        VARCHAR2
              ,cp_line_item_based_type VARCHAR2
              ,cp_line_item_type       VARCHAR2
              ,cp_line_item_code       VARCHAR2
              ) IS
      SELECT sm.*
        FROM ifac_cargo_value sm
       WHERE sm.alloc_no_max_ind = 'Y'
            AND sm.ignore_ind = 'N'
            AND sm.contract_id = cp_contract_id
            AND NVL(sm.customer_id, '$NULL$') = NVL(cp_customer_id, '$NULL$')
            AND sm.cargo_no = cp_cargo_no
            AND sm.parcel_no = cp_parcel_no
            AND sm.uom1_code = cp_uom1_code
            AND ((cp_ifac_tt_conn_code is NULL AND sm.ifac_tt_conn_code IS NULL) OR (sm.ifac_tt_conn_code = cp_ifac_tt_conn_code))
            AND ((cp_if_li_conn_code is NULL AND sm.ifac_li_conn_code IS NULL) OR (sm.ifac_li_conn_code = cp_if_li_conn_code))
            AND ((cp_doc_status is NULL AND sm.doc_status IS NULL) OR (sm.doc_status = cp_doc_status))
            AND sm.price_concept_code = NVL(cp_price_concept_code, sm.price_concept_code)
            AND sm.price_object_id = nvl(cp_price_object_id, sm.price_object_id)
            AND sm.trans_temp_id = cp_trans_temp_id
            AND sm.line_item_based_type = NVL(cp_line_item_based_type,'QTY')
            AND (cp_line_item_type IS NULL OR sm.line_item_type = cp_line_item_type)
            AND (cp_line_item_code IS NULL OR sm.line_item_code = cp_line_item_code)
            --Li_Unique_Key 1 and 2 are for other line items only.
            AND nvl(sm.Li_Unique_Key_1,'$NULL$') = case sm.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(sm.Li_Unique_Key_1,'$NULL$') else nvl(cp_cli_uk1,'$NULL$') end
            AND nvl(sm.Li_Unique_Key_2,'$NULL$') = case sm.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(sm.Li_Unique_Key_2,'$NULL$') else nvl(cp_cli_uk2,'$NULL$') end;


BEGIN
    lt_ifac_table := T_TABLE_IFAC_CARGO_VALUE();

    FOR i_cargo_ifac_rec IN c_ifac_data(
                                  p_contract_id
                                 ,p_customer_id
                                 ,p_cargo_no
                                 ,p_parcel_no
                                 ,p_uom1_code
                                 ,p_doc_status
                                 ,p_cli_uk1
                                 ,p_cli_uk2
                                 ,p_ifac_tt_conn_code
                                 ,p_ifac_li_conn_code
                                 ,p_price_concept_code
                                 ,p_price_object_id
                                 ,p_trans_temp_id
                                 ,p_line_item_based_type
                                 ,p_line_item_type
                                 ,p_line_item_code
                                 )
    LOOP
        lt_ifac_table.extend(1);
        n_ifac_table_index := lt_ifac_table.last;
        lt_ifac_table(n_ifac_table_index) := WrapInterfaceRecord(i_cargo_ifac_rec);
    END LOOP;

    CompleteIfac_P(lt_ifac_table, p_qty_pc_share);

    RETURN lt_ifac_table;
END GetIfacForLineItem;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE GetContLineItemDistMethod_P(p_ifac_table_li  IN OUT NOCOPY T_TABLE_IFAC_CARGO_VALUE,
                                      p_ifac_table_qty_li T_TABLE_IFAC_CARGO_VALUE )
IS
  lt_isQtyShare Boolean;
  lt_dist_method VARCHAR2(32);
BEGIN
    lt_isQtyShare :=true;

    -- This is if there is already a qty line item iterfaced
    IF(p_ifac_table_qty_li is not null and p_ifac_table_qty_li.count !=0)
    THEN

           FOR i_ifac IN p_ifac_table_li.FIRST .. p_ifac_table_li.LAST
             LOOP
                    -- If vendor or process level is interfaced
                    IF(p_ifac_table_li(i_ifac).CREATION_TYPE ='INTERFACE' and ((p_ifac_table_li(i_ifac).INTERFACE_LEVEL ='VENDOR') OR (p_ifac_table_li(i_ifac).INTERFACE_LEVEL ='FIELD')))
                    then
                    lt_isQtyShare :=false;
                    END IF;
             END LOOP;

           --case is when there is already qty line item interfaced and for teh other line item there is no vendor or field level interfaced the shares are taken from qty.
             IF(lt_isQtyShare =true) THEN
                    FOR i_ifac IN p_ifac_table_li.FIRST .. p_ifac_table_li.LAST
                    LOOP
                        IF(p_ifac_table_li(i_ifac).INTERFACE_LEVEL ='LI') THEN
                            p_ifac_table_li(i_ifac).LI_DIST_METHOD:='QTY';
                        ELSE
                          p_ifac_table_li(i_ifac).LI_DIST_METHOD:='';
                        END IF;
                    END LOOP;
             END IF;

     ELSE


        --If field dist method has data tht is put as level dist method
        FOR i_ifac IN p_ifac_table_li.FIRST .. p_ifac_table_li.LAST
          LOOP

                IF(p_ifac_table_li(i_ifac).INTERFACE_LEVEL ='FIELD' and p_ifac_table_li(i_ifac).CREATION_TYPE ='INTERFACE')
                THEN
                      lt_dist_method :='IFAC_PC';
                ELSE
                IF(p_ifac_table_li(i_ifac).INTERFACE_LEVEL ='FIELD' and p_ifac_table_li(i_ifac).LI_DIST_METHOD is not null and p_ifac_table_li(i_ifac).CREATION_TYPE !='INTERFACE')
                THEN
                     lt_dist_method := p_ifac_table_li(i_ifac).LI_DIST_METHOD;
                END IF;
                END IF;

        END LOOP;

        --If vendor level  dist method has data that has precedence and is put as Li level dist method
        FOR i_ifac IN p_ifac_table_li.FIRST .. p_ifac_table_li.LAST
          LOOP
                IF(p_ifac_table_li(i_ifac).INTERFACE_LEVEL ='VENDOR' and p_ifac_table_li(i_ifac).CREATION_TYPE ='INTERFACE')
                THEN
                     lt_dist_method :='IFAC_COMP';
                ELSE
                IF(p_ifac_table_li(i_ifac).INTERFACE_LEVEL ='VENDOR' and p_ifac_table_li(i_ifac).CREATION_TYPE !='INTERFACE' and p_ifac_table_li(i_ifac).LI_DIST_METHOD  is not null)
                THEN
                     lt_dist_method :=p_ifac_table_li(i_ifac).LI_DIST_METHOD;
                END IF;
                END IF;
        END LOOP;


           FOR i_ifac IN p_ifac_table_li.FIRST .. p_ifac_table_li.LAST
           LOOP
               IF(p_ifac_table_li(i_ifac).INTERFACE_LEVEL ='LI')
               THEN
                      p_ifac_table_li(i_ifac).LI_DIST_METHOD:=lt_dist_method;
               ELSE
                      p_ifac_table_li(i_ifac).LI_DIST_METHOD:='';
               END IF;
            END LOOP;

   END IF;



END GetContLineItemDistMethod_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetIfacForDocument(
                         p_contract_id                     objects.object_id%TYPE
                        ,p_cargo_no                        VARCHAR2
                        ,p_parcel_no                       VARCHAR2
                        ,p_point_of_sale_date              DATE
                        ,p_contract_doc_id                 objects.object_id%TYPE
                        ,p_customer_id                     objects.object_id%TYPE
                        )
RETURN T_TABLE_IFAC_CARGO_VALUE
IS
    lt_ifac_table_trans T_IFAC_CARGO_VALUE;
    lt_ifac_table_li T_TABLE_IFAC_CARGO_VALUE;
    lt_ifac_table_doc T_TABLE_IFAC_CARGO_VALUE;
    lt_ifac_table_qty_li T_TABLE_IFAC_CARGO_VALUE;
    lt_qty_pc_share T_TABLE_REVN_DIST_INFO;
    n_li_id NUMBER;
    n_trans_id NUMBER;
    isQtyShare   boolean;

    -- TODO: this comes from GenCargoDocument.c_Cargo and v_cargo_qty_contract
    --       the view can be removed
    CURSOR c_transactions(
                         cp_contract_id                     VARCHAR2
                        ,cp_cargo_no                        VARCHAR2
                        ,cp_parcel_no                       VARCHAR2
                        ,cp_point_of_sale_date              DATE
                        ,cp_contract_doc_id                 VARCHAR2
                        ,cp_customer_id                     VARCHAR2
                        )
    IS
        SELECT DISTINCT contract_id,
                        cargo_no,
                        point_of_sale_date,
                        preceding_doc_key,
                        doc_setup_id,
                        doc_status,
                        loading_port_id,
                        source_node_id,
                        customer_id,
                        description,
                        IFAC_TT_CONN_CODE,
                        trans_temp_id,
                        product_id,
                        price_object_id,
                        price_concept_code,
                        uom1_code,
                        parcel_no
          FROM ifac_cargo_value cv
         WHERE cv.trans_key_set_ind = 'N'
           AND cv.alloc_no_max_ind = 'Y'
           AND cv.ignore_ind = 'N'
           AND cv.contract_id = cp_contract_id
           AND cv.cargo_no = NVL(cp_cargo_no, cv.cargo_no)
           AND cv.parcel_no = NVL(cp_parcel_no, cv.parcel_no)
           AND cv.doc_setup_id = cp_contract_doc_id
           AND cv.customer_id = cp_customer_id
           AND TRUNC(cv.point_of_sale_date, 'MM') = TRUNC(cp_point_of_sale_date, 'MM')
           AND cv.product_id IS NOT NULL;


  CURSOR c_line_items(
               cp_trans_temp_id                      objects.object_id%TYPE
              ,cp_price_object_id                    objects.object_id%TYPE
              ,cp_customer_id                        objects.object_id%TYPE
              ,cp_price_concept_code                 objects.code%TYPE
              ,cp_doc_status                         VARCHAR2
              ,cp_ifac_tt_conn_code                  objects.code%TYPE)
    IS
       SELECT DISTINCT lic.trans_temp_id,
                       lic.product_id,
                       lic.price_object_id,
                       lic.customer_id,
                       lic.price_concept_code,
                       lic.doc_status,
                       lic.uom1_code,
                       lic.li_unique_key_1,
                       lic.li_unique_key_2,
                       lic.ifac_tt_conn_code,
                       lic.ifac_li_conn_code,
                       lic.contract_id,
                       lic.line_item_based_type,
                       lic.line_item_type,
                       lic.line_item_code,
                       lic.line_item_key
         FROM ifac_cargo_value lic
        WHERE lic.trans_key_set_ind = 'N'
          AND lic.alloc_no_max_ind = 'Y'
          AND lic.ignore_ind = 'N'
          AND lic.trans_temp_id = cp_trans_temp_id
          AND lic.price_object_id = cp_price_object_id
          AND lic.customer_id = cp_customer_id
          AND lic.price_concept_code = cp_price_concept_code
          AND lic.doc_status = cp_doc_status
          AND ((lic.ifac_tt_conn_code is null and
              cp_ifac_tt_conn_code is null) or
              lic.ifac_tt_conn_code = cp_ifac_tt_conn_code)
        ORDER BY DECODE(Line_Item_Based_Type, 'QTY', 1, 99);


BEGIN
    lt_ifac_table_doc := T_TABLE_IFAC_CARGO_VALUE();
    n_trans_id := 0;

    FOR i_cargo_ifac_rec_trans IN c_transactions(
                                  p_contract_id
                                 ,p_cargo_no
                                 ,p_parcel_no
                                 ,p_point_of_sale_date
                                 ,p_contract_doc_id
                                 ,p_customer_id
                                 )
    LOOP
        lt_ifac_table_trans := NULL;
        lt_ifac_table_qty_li :=NULL;
        n_trans_id := n_trans_id + 1;
        n_li_id := 0;
        FOR i_ifac_rec_li IN c_line_items(
                                  i_cargo_ifac_rec_trans.trans_temp_id
                                 ,i_cargo_ifac_rec_trans.price_object_id
                                 ,i_cargo_ifac_rec_trans.customer_id
                                 ,i_cargo_ifac_rec_trans.price_concept_code
                                 ,i_cargo_ifac_rec_trans.doc_status
                                 ,i_cargo_ifac_rec_trans.ifac_tt_conn_code)
        LOOP
            n_li_id := n_li_id + 1;
            lt_ifac_table_li := GetIfacForLineItem(
                                    i_ifac_rec_li.contract_id
                                   ,i_ifac_rec_li.customer_id
                                   ,i_cargo_ifac_rec_trans.cargo_no
                                   ,i_cargo_ifac_rec_trans.parcel_no
                                   ,i_ifac_rec_li.uom1_code
                                   ,i_ifac_rec_li.doc_status
                                   ,i_ifac_rec_li.li_unique_key_1
                                   ,i_ifac_rec_li.li_unique_key_2
                                   ,i_ifac_rec_li.ifac_tt_conn_code
                                   ,i_ifac_rec_li.ifac_li_conn_code
                                   ,i_ifac_rec_li.price_concept_code
                                   ,i_ifac_rec_li.price_object_id
                                   ,i_ifac_rec_li.trans_temp_id
                                   ,lt_qty_pc_share
                                   ,i_ifac_rec_li.Line_Item_Based_Type
                                   ,i_ifac_rec_li.Line_Item_Type
                                   ,i_ifac_rec_li.Line_Item_Code
                                   );
            IF lt_ifac_table_li.COUNT > 0
            THEN
            GetContLineItemDistMethod_P(lt_ifac_table_li,lt_ifac_table_qty_li);
            END IF;
            IF i_ifac_rec_li.Line_Item_Based_Type = 'QTY' THEN
                lt_ifac_table_qty_li := lt_ifac_table_li;
            END IF;

        IF lt_ifac_table_li.COUNT > 0
        THEN
            IF lt_ifac_table_trans IS NULL THEN
                    lt_ifac_table_trans := CreateTransLevelRecord_P(lt_ifac_table_li(1));
                    lt_ifac_table_trans.TRANS_ID := n_trans_id;
                    lt_ifac_table_trans.LI_ID := null;
                    lt_ifac_table_doc.EXTEND(1);
                    lt_ifac_table_doc(lt_ifac_table_doc.LAST) := lt_ifac_table_trans;
                END IF;

                FOR i_ifac IN lt_ifac_table_li.FIRST .. lt_ifac_table_li.LAST
                LOOP
                    lt_ifac_table_li(i_ifac).TRANS_ID := n_trans_id;
                    lt_ifac_table_li(i_ifac).LI_ID := n_li_id;
                    lt_ifac_table_doc.EXTEND(1);
                    lt_ifac_table_doc(lt_ifac_table_doc.LAST) := lt_ifac_table_li(i_ifac);
                END LOOP;
        END IF;
    END LOOP;
    END LOOP;

    RETURN lt_ifac_table_doc;
END GetIfacForDocument;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetIfacRelatesTo_TRANS_P(p_ifac IFAC_CARGO_VALUE%ROWTYPE)
RETURN T_TABLE_IFAC_CARGO_VALUE
IS
  p_qty_pc_share   T_TABLE_REVN_DIST_INFO;
BEGIN
    RETURN GetIfacForLineItem(
               p_ifac.contract_id
              ,p_ifac.customer_id
              ,p_ifac.cargo_no
              ,p_ifac.parcel_no
              ,p_ifac.uom1_code
              ,p_ifac.doc_status
              ,p_ifac.li_unique_key_1
              ,p_ifac.li_unique_key_2
              ,p_ifac.ifac_tt_conn_code
              ,p_ifac.ifac_li_conn_code
              ,p_ifac.price_concept_code
              ,p_ifac.price_object_id
              ,p_ifac.trans_temp_id
              ,p_qty_pc_share
              ,p_ifac.line_item_based_type
              ,p_ifac.line_item_type
              ,p_ifac.line_item_code
              );

END GetIfacRelatesTo_TRANS_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetIfacRelatesTo_DOC_P(p_ifac IFAC_CARGO_VALUE%ROWTYPE)
RETURN T_TABLE_IFAC_CARGO_VALUE
IS
BEGIN
    RETURN GetIfacForDocument(
                         p_ifac.contract_id
                        ,p_ifac.cargo_no
                        ,p_ifac.parcel_no
                        ,p_ifac.point_of_sale_date
                        ,p_ifac.Doc_Setup_Id
                        ,p_ifac.customer_id
                        );

END GetIfacRelatesTo_DOC_P;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
/*
PROCEDURE CompleteIfac(
                         p_records             IN OUT T_TABLE_IFAC_CARGO_VALUE
                        )
IS
p_qty_pc_share T_TABLE_REVN_DIST_INFO;
BEGIN
    FOR i_ifac_index IN p_records.FIRST .. p_records.LAST
    LOOP
        p_records(i_ifac_index).INTERFACE_LEVEL := ECDP_REVN_IFAC_WRAPPER.GetIfacRecordLevel_I(p_records(i_ifac_index).PROFIT_CENTER_CODE, p_records(i_ifac_index).VENDOR_CODE, p_records(i_ifac_index).OBJECT_TYPE);
        p_records(i_ifac_index).CREATION_TYPE := ECDP_REVN_IFAC_WRAPPER.gconst_creation_type_interface;
    END LOOP;
        CompleteIfac_P(p_records,p_qty_pc_share);

END CompleteIfac;
*/
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

/*FUNCTION GetPeriodIfac(p_args T_GET_PERIOD_IFAC_PARAMS)
RETURN SYS_REFCURSOR
IS
    lt_ifac_table T_TABLE_IFAC_CARGO_VALUE;
    l_result_cursor SYS_REFCURSOR;
BEGIN
    lt_ifac_table := GetPeriodIfac_INTERNAL(p_args);

    open l_result_cursor for
        select * from table(cast (lt_ifac_table as T_TABLE_IFAC_CARGO_VALUE));

    RETURN l_result_cursor;
END GetPeriodIfac;*/
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetIfacRelatesTo(
                         p_source_entry_no NUMBER
                        ,p_scope VARCHAR2
                        )
RETURN T_TABLE_IFAC_CARGO_VALUE
IS
    lrec_ifac IFAC_CARGO_VALUE%ROWTYPE;
BEGIN
    lrec_ifac := EC_IFAC_CARGO_VALUE.row_by_pk(p_source_entry_no);

    IF p_scope = ECDP_REVN_IFAC_WRAPPER.gconst_get_ifac_scope_document
    THEN
        RETURN GetIfacRelatesTo_DOC_P(lrec_ifac);
    ELSIF p_scope = ECDP_REVN_IFAC_WRAPPER.gconst_get_ifac_scope_trans
    THEN
        RETURN GetIfacRelatesTo_TRANS_P(lrec_ifac);
    END IF;

    RETURN NULL;

END GetIfacRelatesTo;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION WrapInterfaceRecord(
                         p_ifac                             IFAC_CARGO_VALUE%ROWTYPE
                        )
RETURN T_IFAC_CARGO_VALUE
IS
    lt_object T_IFAC_CARGO_VALUE;
    lv2_interface_level VARCHAR2(32);
BEGIN
    IF p_ifac.source_entry_no IS NOT NULL
    THEN
        lv2_interface_level := ECDP_REVN_IFAC_WRAPPER.GetIfacRecordLevel_I(p_ifac.PROFIT_CENTER_CODE, p_ifac.vendor_code, p_ifac.object_type);

        lt_object := T_IFAC_CARGO_VALUE(
                         p_ifac.CONTRACT_CODE
                        ,p_ifac.CARGO_NO
                        ,p_ifac.PARCEL_NO
                        ,p_ifac.VENDOR_CODE
                        ,p_ifac.QTY_TYPE
                        ,p_ifac.PROFIT_CENTER_CODE
                        ,p_ifac.ALLOC_NO
                        ,p_ifac.SO_NUMBER
                        ,p_ifac.LOADING_DATE
                        ,p_ifac.LOADING_COMM_DATE
                        ,p_ifac.DELIVERY_DATE
                        ,p_ifac.DELIVERY_COMM_DATE
                        ,p_ifac.POINT_OF_SALE_DATE
                        ,p_ifac.BL_DATE
                        ,p_ifac.PRICE_DATE
                        ,p_ifac.PRICE_OBJECT_CODE
                        ,p_ifac.PRICE_OBJECT_ID
                        ,p_ifac.PRICE_STATUS
                        ,p_ifac.DISCHARGE_BERTH_CODE
                        ,p_ifac.LOADING_BERTH_CODE
                        ,p_ifac.DISCHARGE_PORT_CODE
                        ,p_ifac.LOADING_PORT_CODE
                        ,p_ifac.CONSIGNOR_CODE
                        ,p_ifac.CONSIGNEE_CODE
                        ,p_ifac.CARRIER_CODE
                        ,p_ifac.VOYAGE_NO
                        ,p_ifac.PRODUCT_CODE
                        ,p_ifac.PRICE_CONCEPT_CODE
                        ,p_ifac.NET_QTY1
                        ,p_ifac.GRS_QTY1
                        ,p_ifac.UOM1_CODE
                        ,p_ifac.NET_QTY2
                        ,p_ifac.GRS_QTY2
                        ,p_ifac.UOM2_CODE
                        ,p_ifac.NET_QTY3
                        ,p_ifac.GRS_QTY3
                        ,p_ifac.UOM3_CODE
                        ,p_ifac.NET_QTY4
                        ,p_ifac.GRS_QTY4
                        ,p_ifac.UOM4_CODE
                        ,p_ifac.STATUS
                        ,p_ifac.DESCRIPTION
                        ,p_ifac.CARRIER_ID
                        ,p_ifac.CONSIGNEE_ID
                        ,p_ifac.CONSIGNOR_ID
                        ,p_ifac.CONTRACT_ID
                        ,p_ifac.DISCHARGE_BERTH_ID
                        ,p_ifac.DISCHARGE_PORT_ID
                        ,p_ifac.DOC_SETUP_CODE
                        ,p_ifac.DOC_SETUP_ID
                        ,p_ifac.DOC_STATUS
                        ,p_ifac.IGNORE_IND
                        ,p_ifac.LOADING_BERTH_ID
                        ,p_ifac.LOADING_PORT_ID
                        ,p_ifac.DOCUMENT_KEY
                        ,p_ifac.PRECEDING_DOC_KEY
                        ,p_ifac.PRODUCT_ID
                        ,p_ifac.PRODUCT_SALES_ORDER_ID
                        ,p_ifac.PROFIT_CENTER_ID
                        ,p_ifac.PRODUCT_SALES_ORDER_CODE
                        ,p_ifac.SOURCE_ENTRY_NO
                        ,p_ifac.SOURCE_NODE_CODE
                        ,p_ifac.SOURCE_NODE_ID
                        ,p_ifac.TRANSACTION_KEY
                        ,p_ifac.TRANS_TEMP_CODE
                        ,p_ifac.TRANS_TEMP_ID
                        ,p_ifac.LI_UNIQUE_KEY_1
                        ,p_ifac.LI_UNIQUE_KEY_2
                        ,p_ifac.UNIT_PRICE
                        ,p_ifac.VENDOR_ID
                        ,p_ifac.VAT_CODE
                        ,p_ifac.IFAC_TT_CONN_CODE
                        ,p_ifac.IFAC_LI_CONN_CODE
                        ,p_ifac.ALLOC_NO_MAX_IND
                        ,p_ifac.TRANS_KEY_SET_IND
                        ,p_ifac.ORIGINAL_IFAC_DATA
                        ,p_ifac.dist_type
                        ,p_ifac.object_type
                        ,p_ifac.LINE_ITEM_BASED_TYPE
                        ,p_ifac.PRICING_VALUE
                        ,p_ifac.LINE_ITEM_TYPE
                        ,p_ifac.INT_FROM_DATE
                        ,p_ifac.INT_TO_DATE
                        ,p_ifac.INT_COMPOUNDING_PERIOD
                        ,p_ifac.PERCENTAGE_VALUE
                        ,p_ifac.PERCENTAGE_BASE_AMOUNT
                        ,p_ifac.INT_BASE_RATE
                        ,p_ifac.INT_RATE_OFFSET
                        ,p_ifac.LI_PRICE_OBJECT_CODE
                        ,p_ifac.LI_PRICE_OBJECT_ID
                        ,p_ifac.LINE_ITEM_TEMPLATE_ID
                        ,p_ifac.UNIT_PRICE_UNIT
                        ,p_ifac.INT_TYPE
                        ,p_ifac.INT_BASE_AMOUNT
                        ,p_ifac.LINE_ITEM_CODE
                        ,p_ifac.LINE_ITEM_KEY
                        ,p_ifac.TEXT_1
                        ,p_ifac.TEXT_2
                        ,p_ifac.TEXT_3
                        ,p_ifac.TEXT_4
                        ,p_ifac.TEXT_5
                        ,p_ifac.TEXT_6
                        ,p_ifac.TEXT_7
                        ,p_ifac.TEXT_8
                        ,p_ifac.TEXT_9
                        ,p_ifac.TEXT_10
                        ,p_ifac.VALUE_1
                        ,p_ifac.VALUE_2
                        ,p_ifac.VALUE_3
                        ,p_ifac.VALUE_4
                        ,p_ifac.VALUE_5
                        ,p_ifac.VALUE_6
                        ,p_ifac.VALUE_7
                        ,p_ifac.VALUE_8
                        ,p_ifac.VALUE_9
                        ,p_ifac.VALUE_10
                        ,p_ifac.DATE_1
                        ,p_ifac.DATE_2
                        ,p_ifac.DATE_3
                        ,p_ifac.DATE_4
                        ,p_ifac.DATE_5
                        ,p_ifac.DATE_6
                        ,p_ifac.DATE_7
                        ,p_ifac.DATE_8
                        ,p_ifac.DATE_9
                        ,p_ifac.DATE_10
                        ,p_ifac.REF_OBJECT_ID_1
                        ,p_ifac.REF_OBJECT_ID_2
                        ,p_ifac.REF_OBJECT_ID_3
                        ,p_ifac.REF_OBJECT_ID_4
                        ,p_ifac.REF_OBJECT_ID_5
                        ,p_ifac.REF_OBJECT_ID_6
                        ,p_ifac.REF_OBJECT_ID_7
                        ,p_ifac.REF_OBJECT_ID_8
                        ,p_ifac.REF_OBJECT_ID_9
                        ,p_ifac.REF_OBJECT_ID_10
                        ,p_ifac.RECORD_STATUS
                        ,p_ifac.CREATED_BY
                        ,p_ifac.CREATED_DATE
                        ,p_ifac.LAST_UPDATED_BY
                        ,p_ifac.LAST_UPDATED_DATE
                        ,p_ifac.REV_NO
                        ,p_ifac.REV_TEXT
                        ,p_ifac.APPROVAL_BY
                        ,p_ifac.APPROVAL_DATE
                        ,p_ifac.APPROVAL_STATE
                        ,p_ifac.REC_ID
                        ,p_ifac.CUSTOMER_CODE
                        ,p_ifac.CUSTOMER_ID
                        ,lv2_interface_level
                        ,ECDP_REVN_IFAC_WRAPPER.gconst_creation_type_interface
                        ,0
                        ,0
                        ,NULL
                        ,p_ifac.Preceding_Li_Key
                        ,p_ifac.Preceding_Trans_Key);
    ELSE
        lt_object := T_IFAC_CARGO_VALUE(
                         NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                        ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,ECDP_REVN_IFAC_WRAPPER.gconst_creation_type_auto_gen,0,0,NULL,NULL,NULL);
    END IF;

    RETURN lt_object;

END WrapInterfaceRecord;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetTransactionLevelIfacRecords(
                         p_records                          IN T_TABLE_IFAC_CARGO_VALUE
                        )
RETURN T_TABLE_IFAC_CARGO_VALUE
IS
    lt_filtered_records T_TABLE_IFAC_CARGO_VALUE;
BEGIN
    lt_filtered_records := T_TABLE_IFAC_CARGO_VALUE();

    IF p_records.COUNT > 0
    THEN
        FOR i_record IN p_records.FIRST .. p_records.LAST
        LOOP
            IF p_records(i_record).INTERFACE_LEVEL = ECDP_REVN_IFAC_WRAPPER.gconst_level_transaction
            THEN
                lt_filtered_records.EXTEND(1);
                lt_filtered_records(lt_filtered_records.LAST) := p_records(i_record);
            END IF;
        END LOOP;
    END IF;

    RETURN lt_filtered_records;
END GetTransactionLevelIfacRecords;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPCLevelIfacRecords(
                         p_records                          T_TABLE_IFAC_CARGO_VALUE
                        ,p_transaction_level_record         T_IFAC_CARGO_VALUE
                        ,p_profit_center_id                 VARCHAR2 DEFAULT NULL
                        )
RETURN T_TABLE_IFAC_CARGO_VALUE
IS
    lt_filtered_records T_TABLE_IFAC_CARGO_VALUE;
BEGIN
    lt_filtered_records := T_TABLE_IFAC_CARGO_VALUE();

    IF p_records.COUNT > 0
    THEN
        FOR i_record IN p_records.FIRST .. p_records.LAST
        LOOP
            IF p_records(i_record).INTERFACE_LEVEL = ECDP_REVN_IFAC_WRAPPER.gconst_level_profit_center
                AND p_records(i_record).LI_ID = p_transaction_level_record.LI_ID
                AND ECDP_REVN_IFAC_WRAPPER.Equals_I(p_profit_center_id, p_records(i_record).PROFIT_CENTER_ID, TRUE)
            THEN
                lt_filtered_records.EXTEND(1);
                lt_filtered_records(lt_filtered_records.LAST) := p_records(i_record);
            END IF;
        END LOOP;
    END IF;

    RETURN lt_filtered_records;
END GetPCLevelIfacRecords;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetVendorLevelIfacRecords(
                         p_records                          T_TABLE_IFAC_CARGO_VALUE
                        ,p_pc_level_record                  T_IFAC_CARGO_VALUE
                        ,p_vendor_id                        VARCHAR2 DEFAULT NULL
                        )
RETURN T_TABLE_IFAC_CARGO_VALUE
IS
    lt_filtered_records T_TABLE_IFAC_CARGO_VALUE;
BEGIN
    lt_filtered_records := T_TABLE_IFAC_CARGO_VALUE();

    IF p_records.COUNT > 0
    THEN
        FOR i_record IN p_records.FIRST .. p_records.LAST
        LOOP
            IF p_records(i_record).INTERFACE_LEVEL = ECDP_REVN_IFAC_WRAPPER.gconst_level_vendor
                AND p_records(i_record).LI_ID = p_pc_level_record.LI_ID
                AND p_records(i_record).PROFIT_CENTER_ID = p_pc_level_record.PROFIT_CENTER_ID
                AND ECDP_REVN_IFAC_WRAPPER.Equals_I(p_vendor_id, p_records(i_record).VENDOR_ID, TRUE)
            THEN
                lt_filtered_records.EXTEND(1);
                lt_filtered_records(lt_filtered_records.LAST) := p_records(i_record);
            END IF;
        END LOOP;
    END IF;

    RETURN lt_filtered_records;
END GetVendorLevelIfacRecords;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION IfacRecordHasVendorPC(
                         p_source_entry_no                  NUMBER
                        ,p_vendor_id                        varchar2 default 'XX'
                        ,p_profit_centre                    varchar2 default 'XX'
                        )
RETURN varchar2
IS
    lt_filtered_records T_TABLE_IFAC_CARGO_VALUE;
    lv2_found_pc        VARCHAR2(1):='N';
    lv2_found_vendor    VARCHAR2(1):='N';
    lv2_found           VARCHAR2(1):='N';
BEGIN
    lt_filtered_records := GetIfacRelatesTo(
                         p_source_entry_no
                        ,'TRANSACTION'
                        );
    IF nvl(p_vendor_id,'XX')='XX' THEN
      lv2_found_vendor := 'Y';
    END IF;
    IF nvl(p_profit_centre,'XX')='XX' THEN
      lv2_found_pc := 'Y';
    END IF;

    IF lt_filtered_records.COUNT > 0
    THEN
        FOR i_record IN lt_filtered_records.FIRST .. lt_filtered_records.LAST
        LOOP
            IF  p_profit_centre = lt_filtered_records(i_record).profit_center_id then
               lv2_found_pc := 'Y';
            END IF;
            IF  p_vendor_id = lt_filtered_records(i_record).vendor_id then
               lv2_found_vendor := 'Y';
            END IF;
            IF lv2_found_pc  = 'Y' AND lv2_found_vendor = 'Y' THEN
              lv2_found := 'Y';
              EXIT;
            END IF;
        END LOOP;
    END IF;
RETURN lv2_found;
END IfacRecordHasVendorPC;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Sort(
                         p_collection                       IN OUT NOCOPY T_TABLE_IFAC_CARGO_VALUE
                        ,p_by                               VARCHAR2 DEFAULT NULL
                        ,p_decodes                          VARCHAR2 DEFAULT NULL
                        )
RETURN T_TABLE_IFAC_CARGO_VALUE
IS
    lv2_normal_order_by varchar2(500);
    lv2_sql varchar2(1000);
    lc_result sys_refcursor;
    lt_new_collection T_TABLE_IFAC_CARGO_VALUE;
BEGIN
    if p_collection is null then
        return null;
    end if;

    lv2_normal_order_by := 'TRANS_ID, nvl(LI_ID, -1), DECODE(INTERFACE_LEVEL, '''
        || EcDp_REVN_IFAC_WRAPPER.gconst_level_transaction || ''', 0, '''
        || EcDp_REVN_IFAC_WRAPPER.gconst_level_line_item  || ''', 1, '''
        || EcDp_REVN_IFAC_WRAPPER.gconst_level_profit_center || ''', 2, '''
        || EcDp_REVN_IFAC_WRAPPER.gconst_level_vendor || ''', 3, 4)';

    if p_by is null then
        lv2_sql := 'SELECT CAST(MULTISET(SELECT * FROM table(:1) ORDER BY ' || lv2_normal_order_by || ') AS T_TABLE_IFAC_CARGO_VALUE) FROM DUAL';
    elsif p_decodes is null then
        lv2_sql := 'SELECT CAST(MULTISET(SELECT * FROM table(:1) ORDER BY ' || lv2_normal_order_by || ', ' || p_by || ') AS T_TABLE_IFAC_CARGO_VALUE) FROM DUAL';
    else
        lv2_sql := 'SELECT CAST(MULTISET(SELECT * FROM table(:collection) ORDER BY ' || lv2_normal_order_by || ', decode('|| p_by ||', '|| p_decodes ||')) AS T_TABLE_IFAC_CARGO_VALUE) FROM DUAL';
    end IF;

    open lc_result for lv2_sql
        using in p_collection;
    loop
        fetch lc_result into lt_new_collection;
        exit when lc_result%notfound;
    end loop;
    close lc_result;

    return lt_new_collection;
END;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Finds the index of interface records with given attributes.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Find(
                         p_ifac                             in out nocopy t_table_ifac_cargo_value
                        ,p_range                            t_table_number DEFAULT NULL
                        ,p_level                            VARCHAR2 default null
                        ,p_trans_id                         number default null
                        ,p_li_id                            number default null
                        ,p_transaction_key                  varchar2 default null
                        ,p_line_item_key                    varchar2 default NULL
                        ,p_profit_center_id                 VARCHAR2 DEFAULT NULL
                        ,p_vendor_id                        VARCHAR2 DEFAULT NULL
)
return T_TABLE_NUMBER
is
    ids T_TABLE_NUMBER;
    current_rec t_ifac_cargo_value;
    lt_range t_table_number;
    ifac_count NUMBER;
begin
    ids := T_TABLE_NUMBER();
    lt_range := p_range;

    IF p_ifac IS NULL OR p_ifac.count = 0 THEN
        RETURN ids;
    END IF;

    IF lt_range IS NULL THEN
        ifac_count := p_ifac.count;
        SELECT rownum
        BULK COLLECT INTO lt_range
        FROM dual
        CONNECT BY rownum <= ifac_count;
    END IF;

    for idx in 1..lt_range.count loop
        current_rec := p_ifac(lt_range(idx));
        if ecdp_revn_common.equals(p_level, current_rec.INTERFACE_LEVEL, ecdp_revn_common.gv2_true) = ecdp_revn_common.gv2_true
            and ecdp_revn_common.equals(p_trans_id, current_rec.trans_id, ecdp_revn_common.gv2_true) = ecdp_revn_common.gv2_true
            and ecdp_revn_common.equals(p_li_id, current_rec.li_id, ecdp_revn_common.gv2_true) = ecdp_revn_common.gv2_true
            and ecdp_revn_common.equals(p_transaction_key, current_rec.transaction_key, ecdp_revn_common.gv2_true) = ecdp_revn_common.gv2_true
            and ecdp_revn_common.equals(p_line_item_key, current_rec.line_item_key, ecdp_revn_common.gv2_true) = ecdp_revn_common.gv2_true
            and ecdp_revn_common.equals(p_profit_center_id, current_rec.PROFIT_CENTER_ID, ecdp_revn_common.gv2_true) = ecdp_revn_common.gv2_true
            and ecdp_revn_common.equals(p_vendor_id, current_rec.VENDOR_ID, ecdp_revn_common.gv2_true) = ecdp_revn_common.gv2_true then
            ids.extend(1);
            ids(ids.last) := lt_range(idx);
        end if;
    end loop;

    return ids;
end;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Finds the first index of interface records with given attributes.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Find_One(
                         p_ifac                             in out nocopy t_table_ifac_cargo_value
                        ,p_range                            t_table_number DEFAULT NULL
                        ,p_level                            VARCHAR2 default null
                        ,p_trans_id                         number default null
                        ,p_li_id                            number default null
                        ,p_transaction_key                  varchar2 default null
                        ,p_line_item_key                    varchar2 default NULL
                        ,p_profit_center_id                 VARCHAR2 DEFAULT NULL
                        ,p_vendor_id                        VARCHAR2 DEFAULT NULL
)
return NUMBER
is
    ids T_TABLE_NUMBER;
begin
    ids := Find(p_ifac, p_range, p_level, p_trans_id, p_li_id, p_transaction_key, p_line_item_key, p_profit_center_id, p_vendor_id);
    IF ids.count = 0 THEN
        RETURN NULL;
    ELSE
        RETURN ids(1);
    END IF;
end;


------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Filter(
                         p_collection                       IN OUT NOCOPY t_table_ifac_cargo_value
                        ,p_condition                        VARCHAR2
                        )
RETURN T_TABLE_IFAC_CARGO_VALUE
IS
    lv2_sql varchar2(1000);
    lc_result sys_refcursor;
    lt_new_collection T_TABLE_IFAC_CARGO_VALUE;
BEGIN
    if p_collection is null then
        return null;
    end if;

    if p_condition is null then
        lv2_sql := 'SELECT CAST(MULTISET(SELECT * FROM table(:1)) AS T_TABLE_IFAC_CARGO_VALUE) FROM DUAL';
    else
        lv2_sql := 'SELECT CAST(MULTISET(SELECT * FROM table(:1) WHERE ' || p_condition || ') AS T_TABLE_IFAC_CARGO_VALUE) FROM DUAL';
    end IF;

    open lc_result for lv2_sql
        using in p_collection;
    loop
        fetch lc_result into lt_new_collection;
        exit when lc_result%notfound;
    end loop;
    close lc_result;

    return lt_new_collection;
END;
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Filters the interface records with given attributes.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Filter(
                         p_collection                       in out nocopy t_table_ifac_cargo_value
                        ,p_level                            VARCHAR2
                        ,p_trans_id                         NUMBER
                        ,p_li_id                            NUMBER
                        ,p_transaction_key                  VARCHAR2
)
RETURN T_TABLE_IFAC_CARGO_VALUE
IS
    lv2_condition VARCHAR2(500);
BEGIN
    lv2_condition := '1 = 1 ';
    IF p_level IS NOT NULL THEN
        lv2_condition := lv2_condition || ' and INTERFACE_LEVEL = ' || p_level;
    END IF;

    IF p_trans_id IS NOT NULL THEN
        lv2_condition := lv2_condition || ' and trans_id = ' || p_trans_id;
    END IF;

    IF p_li_id IS NOT NULL THEN
        lv2_condition := lv2_condition || ' and li_id = ' || p_li_id;
    END IF;

    IF p_transaction_key IS NOT NULL THEN
        lv2_condition := lv2_condition || ' and transaction_key = ' || p_transaction_key;
    END IF;

    RETURN Filter(p_collection, lv2_condition);
END;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- Gets distinct values of given attribute on collection.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Aggregate(
                         p_collection                       IN OUT NOCOPY t_table_ifac_cargo_value
                        ,p_by                               VARCHAR2
                        )
RETURN t_table_varchar2
IS
    lv2_sql varchar2(1000);
    lc_result sys_refcursor;
    lt_new_collection t_table_varchar2;
BEGIN
    if p_collection is null OR p_by is null then
        return null;
    end if;

    lt_new_collection := t_table_varchar2();
    lv2_sql := 'SELECT to_char(' || p_by || ') AS val FROM table(:collection)';

    open lc_result for lv2_sql
        using in p_collection;
    fetch lc_result BULK COLLECT into lt_new_collection;
    close lc_result;

    return lt_new_collection;
END;

END EcDp_REVN_IFAC_WRAPPER_CARGO;