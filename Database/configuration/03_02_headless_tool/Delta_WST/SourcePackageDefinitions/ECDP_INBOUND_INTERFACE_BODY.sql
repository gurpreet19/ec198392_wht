CREATE OR REPLACE PACKAGE BODY EcDp_Inbound_Interface IS
    --*********************************************************************
    --* This package contains members for resolving values on Revenue FT
    --* document interfacing.
    --*********************************************************************

    TYPE t_PriceTable IS TABLE OF IFAC_PRICE%ROWTYPE;
    TYPE t_QtyTable IS TABLE OF IFAC_QTY%ROWTYPE;
    SUBTYPE t_resolve_phase IS VARCHAR2(32);

    c_resolve_phase_pre t_resolve_phase := 'pre_resolving';
    c_resolve_phase_post t_resolve_phase := 'post_resolving';

    ori_ifac_data_splitor CONSTANT VARCHAR2(5) := '$$$';
    ori_ifac_null_data CONSTANT VARCHAR2(6) := '[NULL]';
    ori_ifac_number_format CONSTANT VARCHAR2(60) := '999999999999999.999999999999999';
    ori_ifac_date_format constant varchar2(21) := 'YYYY-MM-DD HH24:MI:SS';

    TYPE t_RevnLogInterface IS RECORD (
        LOG_NO      NUMBER,
        LOG_STATUS  VARCHAR2(32));

    rec_RevnLogInterface t_RevnLogInterface;


    -----------------------------------------------------------------------
    -- Appends original CLOB.
    ----+----------------------------------+-------------------------------
    PROCEDURE append_ori_clob_p(
        p_lob                              IN OUT NOCOPY CLOB
       ,p_data                             VARCHAR2
       ,p_skip_splitor                     BOOLEAN DEFAULT FALSE
       )
    IS
    BEGIN
        dbms_lob.append(p_lob, nvl(p_data, ori_ifac_null_data));

        IF NOT p_skip_splitor THEN
            dbms_lob.append(p_lob, ori_ifac_data_splitor);
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Appends original CLOB.
    ----+----------------------------------+-------------------------------
    PROCEDURE append_ori_clob_p(
        p_lob                              IN OUT NOCOPY CLOB
       ,p_data                             NUMBER
       ,p_skip_splitor                     BOOLEAN DEFAULT FALSE
       )
    IS
    BEGIN
        dbms_lob.append(p_lob, NVL(TO_CHAR(p_data, ORI_IFAC_NUMBER_FORMAT), ORI_IFAC_NULL_DATA));

        IF NOT p_skip_splitor THEN
            dbms_lob.append(p_lob, ori_ifac_data_splitor);
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Appends original CLOB.
    ----+----------------------------------+-------------------------------
    PROCEDURE append_ori_clob_p(
        p_lob                              IN OUT NOCOPY CLOB
       ,p_data                             DATE
       ,p_skip_splitor                     BOOLEAN DEFAULT FALSE
       )
    IS
    BEGIN
        dbms_lob.append(p_lob, NVL(TO_CHAR(p_data, ori_ifac_date_format), ORI_IFAC_NULL_DATA));

        IF NOT p_skip_splitor THEN
            dbms_lob.append(p_lob, ori_ifac_data_splitor);
        END IF;
    END;


    -----------------------------------------------------------------------
    -- Write status to log when interfacing data.
    ----+----------------------------------+-------------------------------
    PROCEDURE WriteRevnLogInterface_P(
        p_log_item_status                  VARCHAR2
       ,p_log_item_description             VARCHAR2 DEFAULT NULL
       ,p_contract_id                      VARCHAR2 DEFAULT NULL
       ,p_source_entry_no                  NUMBER DEFAULT NULL
       ,p_new_log                          BOOLEAN DEFAULT FALSE
       )
    IS
      lv2_Category                         VARCHAR2(32) := 'INTERFACE';
      ln_Log_Item_No                       NUMBER;
    BEGIN
      -- 1. Create parent log if missing
      -- 2. Update parent if ERROR, WARNING or SUCCESS
      -- 3. Create child log

      -- Create parent log
      IF p_new_log THEN
        rec_RevnLogInterface := NULL;
        rec_RevnLogInterface.LOG_NO := ECDP_REVN_LOG.CreateLog(lv2_Category, ECDP_REVN_LOG.LOG_STATUS_UNKNOWN, 'Interface data', p_contract_id);
        rec_RevnLogInterface.LOG_STATUS := ECDP_REVN_LOG.LOG_STATUS_UNKNOWN;
        ECDP_REVN_LOG.UpdateLog(rec_RevnLogInterface.LOG_NO, ECDP_REVN_LOG.LOG_STATUS_UNKNOWN, 'Source Entry No: ' || to_char(p_source_entry_no), NULL, NULL, NULL, NULL, NULL, NULL, NULL, p_source_entry_no);
      END IF;

      -- Exit if missing LOG_NO
      IF rec_RevnLogInterface.LOG_NO IS NULL THEN
        RETURN;
      END IF;

      -- Update parent if ERROR
      IF  (p_log_item_status = ECDP_REVN_LOG.LOG_STATUS_ERROR)
      AND (rec_RevnLogInterface.LOG_STATUS != ECDP_REVN_LOG.LOG_STATUS_ERROR) THEN
        ECDP_REVN_LOG.UpdateLog(rec_RevnLogInterface.LOG_NO, p_log_item_status);
        rec_RevnLogInterface.LOG_STATUS := p_log_item_status;
      END IF;

      -- Update parent if WARNING
      IF (p_log_item_status = ECDP_REVN_LOG.LOG_STATUS_WARNING)
      AND (rec_RevnLogInterface.LOG_STATUS != ECDP_REVN_LOG.LOG_STATUS_ERROR)
      AND (rec_RevnLogInterface.LOG_STATUS != ECDP_REVN_LOG.LOG_STATUS_WARNING) THEN
        ECDP_REVN_LOG.UpdateLog(rec_RevnLogInterface.LOG_NO, p_log_item_status);
        rec_RevnLogInterface.LOG_STATUS := p_log_item_status;
      END IF;

      -- Update parent if SUCCESS
      IF p_log_item_status = ECDP_REVN_LOG.LOG_STATUS_SUCCESS THEN
        IF  (rec_RevnLogInterface.LOG_STATUS != ECDP_REVN_LOG.LOG_STATUS_WARNING)
        AND (rec_RevnLogInterface.LOG_STATUS != ECDP_REVN_LOG.LOG_STATUS_ERROR) THEN
          ECDP_REVN_LOG.UpdateLog(rec_RevnLogInterface.LOG_NO, ECDP_REVN_LOG.LOG_STATUS_SUCCESS);
        END IF;
        rec_RevnLogInterface := NULL;
      END IF;

      -- Create child log
      IF p_log_item_description IS NOT NULL THEN
        ln_Log_Item_No := ECDP_REVN_LOG.CreateLogItem(rec_RevnLogInterface.LOG_NO, lv2_Category, p_log_item_status, NULL, p_log_item_description, NULL);
      END IF;
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE WriteInterfaceLog_P(
        p_table_name                       VARCHAR2
       ,p_text                             VARCHAR2
       ,p_log_level                        VARCHAR2
    )
    IS
    BEGIN
      IF p_table_name IS NOT NULL AND p_text IS NOT NULL THEN
        INSERT INTO interface_log(log_item_no, table_name, daytime, log_level, text)
        VALUES (ecdp_system_key.assignNextNumber('INTERFACE_LOG'), p_table_name, Ecdp_Timestamp.getCurrentSysdate, nvl(p_log_level, 'INFO'), SUBSTR(p_text, 1, 2000));
      END IF;
    END;

    -----------------------------------------------------------------------
    -- Resolve values for Free Unit line item interface.
    ----+----------------------------------+-------------------------------
    FUNCTION resolve_as_free_unit_li_p(
        p_ifac                             IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
       ,p_phase                            t_resolve_phase
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_ifac.line_item_based_type <> ecdp_revn_ft_constants.li_btype_free_unit THEN
            RETURN FALSE;
        END IF;

        CASE p_phase
            WHEN c_resolve_phase_pre THEN
                NULL;
            WHEN c_resolve_phase_post THEN
                -- fallback unit price unit to the unit on price object
                IF p_ifac.unit_price_unit IS NULL THEN
                    p_ifac.unit_price_unit :=
                        ec_product_price_version.uom(p_ifac.price_object_id, p_ifac.processing_period, '<=');
                END IF;

                IF p_ifac.unit_price_unit IS NULL THEN
                    WriteRevnLogInterface_P(
                        EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR,
                        'No unit price unit found, the unit needs to either be specified in interface, or be available on the price object.');
                END IF;
            ELSE
                NULL;
        END CASE;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Resolve values for Free Unit line item interface.
    ----+----------------------------------+-------------------------------
    FUNCTION resolve_as_free_unit_li_p(
        p_ifac                             IN OUT NOCOPY IFAC_CARGO_VALUE%ROWTYPE
       ,p_phase                            t_resolve_phase
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_ifac.line_item_based_type <> ecdp_revn_ft_constants.li_btype_free_unit THEN
            RETURN FALSE;
        END IF;

        CASE p_phase
            WHEN c_resolve_phase_pre THEN
                NULL;
            WHEN c_resolve_phase_post THEN
                -- fallback unit price unit to the unit on price object
                IF p_ifac.unit_price_unit IS NULL THEN
                    p_ifac.unit_price_unit :=
                        ec_product_price_version.uom(p_ifac.price_object_id, p_ifac.point_of_sale_date, '<=');
                END IF;

                IF p_ifac.unit_price_unit IS NULL THEN
                    WriteRevnLogInterface_P(
                        EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR,
                        'No unit price unit found, the unit needs to either be specified in interface, or be available on the price object.');
                END IF;
            ELSE
                NULL;
        END CASE;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Resolve values for Free Unit Price Object line item interface.
    ----+----------------------------------+-------------------------------
    FUNCTION resolve_as_free_unit_po_li_p(
        p_ifac                             IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
       ,p_phase                            t_resolve_phase
        )
    RETURN BOOLEAN
    IS
    lv2_unit_price_unit varchar2(32) :=null;
    BEGIN
        IF p_ifac.line_item_based_type <> ecdp_revn_ft_constants.li_btype_free_unit_po THEN
            RETURN FALSE;
        END IF;

        IF p_phase = c_resolve_phase_pre OR p_phase = c_resolve_phase_post THEN
            -- fallback unit price unit to the unit on price object
            IF p_ifac.li_price_object_id IS NULL OR p_ifac.processing_period IS NULL THEN
                WriteRevnLogInterface_P(
                    EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR,
                    'No unit price unit found. It cannot be looked up because of missing ' ||
                    case nvl(p_ifac.li_price_object_id,'NULL') when 'NULL' then 'LI_PRICE_OBJECT_ID' else '' end ||
                    case nvl(p_ifac.li_price_object_id,'NULL') || nvl(to_char(p_ifac.processing_period,'yyyymmdd'),'NULL') when 'NULLNULL' then ' and ' else '' end ||
                    case nvl(to_char(p_ifac.processing_period,'yyyymmdd'),'NULL') when 'NULL' then 'PROCESSING_PERIOD' else '' end ||
                    ' in ifac.');
                RETURN TRUE;
            END IF;

            lv2_unit_price_unit := ec_product_price_version.uom(p_ifac.li_price_object_id, p_ifac.processing_period, '<=');
            p_ifac.unit_price_unit :=lv2_unit_price_unit;
            IF p_ifac.unit_price_unit IS NULL THEN
                WriteRevnLogInterface_P(
                    EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR,
                    'No unit price unit found, the unit needs to either be specified in interface, or be available on the price object.');
            END IF;

        ELSE
            NULL;
        END IF;

        RETURN TRUE;
    END;
      -----------------------------------------------------------------------
    -- Resolve values for Free Unit Price Object line item interface.
    ----+----------------------------------+-------------------------------
    FUNCTION resolve_as_free_unit_po_li_p(
        p_ifac                             IN OUT NOCOPY IFAC_CARGO_VALUE%ROWTYPE
       ,p_phase                            t_resolve_phase
        )
    RETURN BOOLEAN
    IS
    lv2_unit_price_unit varchar2(32) :=null;
    BEGIN
        IF p_ifac.line_item_based_type <> ecdp_revn_ft_constants.li_btype_free_unit_po THEN
            RETURN FALSE;
        END IF;

        CASE p_phase
            WHEN c_resolve_phase_pre THEN
                NULL;
            WHEN c_resolve_phase_post THEN
                -- fallback unit price unit to the unit on price object
                IF p_ifac.li_price_object_id IS NULL OR p_ifac.point_of_sale_date IS NULL THEN
                    WriteRevnLogInterface_P(
                        EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR,
                        'No unit price unit found. It cannot be looked up because of missing ' ||
                        case nvl(p_ifac.li_price_object_id,'NULL') when 'NULL' then 'LI_PRICE_OBJECT_ID' else '' end ||
                        case nvl(p_ifac.li_price_object_id,'NULL') || nvl(to_char(p_ifac.point_of_sale_date,'yyyymmdd'),'NULL') when 'NULLNULL' then ' and ' else '' end ||
                        case nvl(to_char(p_ifac.point_of_sale_date,'yyyymmdd'),'NULL') when 'NULL' then 'POINT_OF_SALE_DATE' else '' end ||
                        ' in ifac.');
                    RETURN TRUE;
                END IF;

                lv2_unit_price_unit := ec_product_price_version.uom(p_ifac.li_price_object_id, p_ifac.point_of_sale_date, '<=');
                p_ifac.unit_price_unit :=lv2_unit_price_unit;
                IF p_ifac.unit_price_unit IS NULL THEN
                    WriteRevnLogInterface_P(
                        EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR,
                        'No unit price unit found, the unit needs to either be specified in interface, or be available on the price object.');
                END IF;


            ELSE
                NULL;
        END CASE;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Resolve values for Interest line item interface.
    ----+----------------------------------+-------------------------------
    FUNCTION resolve_as_interest_li_p(
        p_ifac                             IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
       ,p_phase                            t_resolve_phase
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_ifac.line_item_based_type <> ecdp_revn_ft_constants.li_btype_interest THEN
            RETURN FALSE;
        END IF;

        CASE p_phase
            WHEN c_resolve_phase_pre THEN
                -- Valid to be interfaced on Line Item level only
                IF nvl(ec_prosty_codes.is_active(p_ifac.object_type,'DIST_TYPE'),'N') != 'Y' THEN
                    WriteRevnLogInterface_P(
                        EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR,
                        p_ifac.line_item_based_type || ' is to be interfaced on Line Item level only. Interfaced distribution type is ''' || p_ifac.object_type || '''. This record is disabled.');
                    p_ifac.ignore_ind :=  ecdp_revn_common.gv2_true;
                END IF;

                -- fallback line item type, since it is required for interest line items
                IF p_ifac.line_item_type IS NULL THEN
                    p_ifac.line_item_type := ecdp_revn_ft_constants.li_btype_interest;
                END IF;
            WHEN c_resolve_phase_post THEN
                NULL;
            ELSE
                NULL;
        END CASE;

        RETURN TRUE;
    END;
    -----------------------------------------------------------------------
    -- Resolve values for Interest line item interface.
    ----+----------------------------------+-------------------------------
    FUNCTION resolve_as_interest_li_p(
        p_ifac                             IN OUT NOCOPY IFAC_CARGO_VALUE%ROWTYPE
       ,p_phase                            t_resolve_phase
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_ifac.line_item_based_type <> ecdp_revn_ft_constants.li_btype_interest THEN
            RETURN FALSE;
        END IF;

        CASE p_phase
            WHEN c_resolve_phase_pre THEN
                -- Valid to be interfaced on Line Item level only
                IF nvl(ec_prosty_codes.is_active(p_ifac.object_type,'DIST_TYPE'),'N') != 'Y' THEN
                    WriteRevnLogInterface_P(
                        EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR,
                        p_ifac.line_item_based_type || ' is to be interfaced on Line Item level only. Interfaced distribution type is ''' || p_ifac.object_type || '''. This record is disabled.');
                    p_ifac.ignore_ind :=  ecdp_revn_common.gv2_true;
                END IF;

                -- fallback line item type, since it is required for interest line items
                IF p_ifac.line_item_type IS NULL THEN
                    p_ifac.line_item_type := ecdp_revn_ft_constants.li_btype_interest;
                END IF;
            WHEN c_resolve_phase_post THEN
                NULL;
            ELSE
                NULL;
        END CASE;

        RETURN TRUE;
    END;
    -----------------------------------------------------------------------
    -- Resolve values for Fixed value line item interface.
    ----+----------------------------------+-------------------------------
    FUNCTION resolve_as_fixed_value_li_p(
        p_ifac                             IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
       ,p_phase                            t_resolve_phase
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_ifac.line_item_based_type <> ecdp_revn_ft_constants.li_btype_fixed_value THEN
            RETURN FALSE;
        END IF;

        CASE p_phase
            WHEN c_resolve_phase_pre THEN
                NULL;
            WHEN c_resolve_phase_post THEN
                WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_WARNING, 'No pricing value provided.');
            ELSE
                NULL;
        END CASE;

        RETURN TRUE;
    END;
 -----------------------------------------------------------------------
    -- Resolve values for Fixed value line item interface.
    ----+----------------------------------+-------------------------------
    FUNCTION resolve_as_fixed_value_li_p(
        p_ifac                             IN OUT NOCOPY IFAC_CARGO_VALUE%ROWTYPE
       ,p_phase                            t_resolve_phase
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_ifac.line_item_based_type <> ecdp_revn_ft_constants.li_btype_fixed_value THEN
            RETURN FALSE;
        END IF;

        CASE p_phase
            WHEN c_resolve_phase_pre THEN
                NULL;
            WHEN c_resolve_phase_post THEN
                WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_WARNING, 'No pricing value provided.');
            ELSE
                NULL;
        END CASE;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Map internal with external codes.
    ----+----------------------------------+-------------------------------
    procedure resolve_internal_map_p(
        p_ifac                             IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
       ,p_daytime                          IN DATE
       )
    IS
    BEGIN
        p_ifac.Contract_Code       := getMappingCode(p_ifac.contract_code, 'CONTRACT', p_daytime);
        p_ifac.Vendor_Code         := getMappingCode(p_ifac.vendor_code, 'VENDOR', p_daytime);
        p_ifac.Customer_Code       := getMappingCode(p_ifac.customer_code, 'CUSTOMER', p_daytime);
        p_ifac.Product_Code        := getMappingCode(p_ifac.Product_Code, 'PRODUCT', p_daytime);
        p_ifac.Delivery_Point_Code := getMappingCode(p_ifac.Delivery_Point_Code, 'DELIVERY_POINT', p_daytime);
        p_ifac.Profit_Center_Code  := getMappingCode(p_ifac.Profit_Center_Code, p_ifac.Object_Type, p_daytime);
        p_ifac.Price_Object_Code   := getMappingCode(p_ifac.price_object_code, 'PRICE_OBJECT', p_daytime);
        p_ifac.Price_Concept_Code  := getMappingCode(p_ifac.Price_Concept_Code, 'PRICE_CONCEPT', p_daytime);
        p_ifac.li_Price_Object_Code   := getMappingCode(p_ifac.li_price_object_code, 'PRICE_OBJECT', p_daytime);
        p_ifac.Qty_Status          := getMappingCode(p_ifac.Qty_Status, 'QTY_STATUS', p_daytime);
        p_ifac.Price_Status        := getMappingCode(p_ifac.Price_Status, 'PRICE_STATUS', p_daytime);
        p_ifac.Uom1_Code           := getMappingCode(p_ifac.Uom1_Code, 'UOM', p_daytime);
        p_ifac.Uom2_Code           := getMappingCode(p_ifac.Uom2_Code, 'UOM', p_daytime);
        p_ifac.Uom3_Code           := getMappingCode(p_ifac.Uom3_Code, 'UOM', p_daytime);
        p_ifac.Uom4_Code           := getMappingCode(p_ifac.Uom4_Code, 'UOM', p_daytime);
        p_ifac.Uom5_Code           := getMappingCode(p_ifac.Uom5_Code, 'UOM', p_daytime);
        p_ifac.Uom6_Code           := getMappingCode(p_ifac.Uom6_Code, 'UOM', p_daytime);
        p_ifac.Source_Node_Code    := getMappingCode(p_ifac.Source_Node_Code, 'ALLOC_NODE', p_daytime);
    END;

    -----------------------------------------------------------------------
    -- Resolved common values on given ifac.
    ----+----------------------------------+-------------------------------
    procedure resolve_common_values_p(
        p_ifac                             IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
       ,p_daytime                          IN DATE
       )
    IS
        l_price_object_version_rec         product_price_version%ROWTYPE := NULL;
        l_price_object_rec                 product_price%ROWTYPE := NULL;
    BEGIN
        IF p_ifac.line_item_based_type is null then
          p_ifac.line_item_based_type := 'QTY';
        end if;

        IF p_ifac.line_item_type is NULL
            AND p_ifac.line_item_based_type <> 'QTY' then
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_WARNING, 'Missing Line Item Type.');
        end if;

        -- Get contract object_id based on contract code
        IF p_ifac.Contract_Id IS NULL THEN
          p_ifac.Contract_Id := ec_contract.object_id_by_uk(p_ifac.contract_code);
        END IF;
        IF p_ifac.Contract_Id IS NULL THEN
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No valid Contract found in Ifac Record for code: ' || nvl(p_ifac.contract_code,'NULL'));
        ELSE
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Contract is found in Ifac Record for code: ' || p_ifac.contract_code);
        END IF;

        -- Get vendor object_id based on vendor code
        IF p_ifac.Vendor_Id IS NULL THEN
          p_ifac.Vendor_Id := ec_company.object_id_by_uk(p_ifac.vendor_code, 'VENDOR');
        END IF;
        IF p_ifac.Vendor_Id IS NULL THEN
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Vendor found in Ifac Record for code: ' || nvl(p_ifac.vendor_code,'NULL'));
        ELSE
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Vendor is found in Ifac Record for code: ' || p_ifac.vendor_code);
        END IF;

        -- Get product object_id based on product code
        IF p_ifac.Product_Id IS NULL THEN
          p_ifac.Product_Id := ec_product.object_id_by_uk(p_ifac.Product_Code);
        END IF;
        IF p_ifac.Product_Id IS NULL THEN
          IF p_ifac.Product_Code IS NULL THEN
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No Product Code found in Ifac Record.');
          ELSE
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No valid Product found in Ifac Record for code: ' || nvl(p_ifac.Product_Code,'NULL'));
          END IF;
        ELSE
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Product is found in Ifac Record for code: ' || p_ifac.Product_Code);
        END IF;

        -- Get delivery_point object_id based on delivery_point code
        IF p_ifac.Delivery_Point_Id IS NULL THEN
          p_ifac.Delivery_Point_Id := ec_delivery_point.object_id_by_uk(p_ifac.Delivery_Point_Code);
        END IF;
        IF p_ifac.Delivery_Point_Id IS NULL THEN
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Delivery Point found in Ifac Record for code: ' || nvl(p_ifac.Delivery_Point_Code,'NULL'));
        ELSE
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Delivery Point is found in Ifac Record for code: ' || p_ifac.Delivery_Point_Code);
        END IF;

        -- Get profit centre id based on distribution object type
        IF p_ifac.Profit_Center_Id IS NULL THEN
           IF p_ifac.object_type = 'OBJECT_LIST' THEN
              IF p_ifac.Profit_Center_code = 'SUM' THEN
                 p_ifac.Profit_Center_Id := ec_field.object_id_by_uk(p_ifac.Profit_Center_Code, 'FIELD');
              ELSE
                 p_ifac.Profit_Center_Id := ecdp_objects.GetObjIDFromCode(p_ifac.object_type, p_ifac.Profit_Center_code);
              END IF;
           ELSE
             p_ifac.Profit_Center_Id :=	ecdp_objects.GetObjIDFromCode(p_ifac.object_type, p_ifac.Profit_Center_code);
           END IF;
           IF p_ifac.object_type IS NULL THEN  -- This is only for scenrio tester which supports only field
             p_ifac.Profit_Center_Id := ec_field.object_id_by_uk(p_ifac.Profit_Center_Code, 'FIELD');
           END IF;
        END IF;
        IF p_ifac.Profit_Center_Id IS NULL THEN
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No valid ' || p_ifac.object_type || ' found in Ifac Record for code: ' || nvl(p_ifac.Profit_Center_Code,'NULL'));
        ELSE
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid ' || p_ifac.object_type || ' is found in Ifac Record for code: ' || p_ifac.Profit_Center_Code);
        END IF;

        -- Get source node object_id based on source node code
        IF p_ifac.Source_Node_Id IS NULL THEN
          p_ifac.Source_Node_Id := ecdp_objects.GetObjIDFromCode('ALLOC_NODE', p_ifac.Source_Node_Code);
        END IF;
        IF p_ifac.Source_Node_Id IS NULL THEN
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Source Node found in Ifac Record for code: ' || nvl(p_ifac.Source_Node_Code,'NULL'));
        ELSE
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Source Node is found in Ifac Record for code: ' || p_ifac.Source_Node_Code);
        END IF;

        -- Get mapping code for price_object_code (must be valid codes from IFAC_SALES_QTY)
        IF p_ifac.Price_Object_Id IS NULL THEN
          p_ifac.Price_Object_Id := ec_product_price.object_id_by_uk(p_ifac.Price_Object_Code);
        END IF;

        IF p_ifac.Price_Object_Id IS NULL THEN
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'No Price Object found based on Price Object Code: ' || nvl(p_ifac.Price_Object_Code,'NULL'));
        ELSE
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Price Object is found based on Price Object Code: ' || p_ifac.Price_Object_Code);

          -- Set quantity status and price status from price object, if not set already
          l_price_object_version_rec := ec_product_price_version.row_by_pk(p_ifac.Price_Object_Id, p_daytime, '<=');
          l_price_object_rec := ec_product_price.row_by_pk(p_ifac.Price_Object_Id);

          IF l_price_object_version_rec.quantity_status IS NOT NULL AND p_ifac.Qty_Status IS NULL THEN
            p_ifac.Qty_Status := l_price_object_version_rec.quantity_status;
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Qty Status ''' || l_price_object_version_rec.quantity_status || ''' is set based on Price Object Code: ' || p_ifac.Price_Object_Code);
          END IF;

          IF l_price_object_version_rec.price_status IS NOT NULL AND p_ifac.Price_Status IS NULL THEN
            p_ifac.Price_Status := l_price_object_version_rec.Price_Status;
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Status ''' || l_price_object_version_rec.Price_Status || ''' is set based on Price Object Code: ' || p_ifac.Price_Object_Code);
          END IF;

          p_ifac.Product_id := l_price_object_rec.product_id ;
          p_ifac.Price_Concept_Code := l_price_object_rec.price_concept_code ;
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Concept ''' || p_ifac.Price_Concept_Code || ''' is set based on Price Object Code: ' || p_ifac.Price_Object_Code);
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Product ''' || ec_product.object_code(p_ifac.Product_id) || ''' is set based on Price Object Code: ' || p_ifac.Price_Object_Code);
        END IF;

        -- If no product is found by now, log it as ERROR
        IF p_ifac.Product_Id IS NULL THEN
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No valid Product found in Ifac Record or by config.');
        END IF;

        -- Get mapping code for li_price_object_code (must be valid codes from IFAC_SALES_QTY)
        IF p_ifac.li_Price_Object_Id IS NULL THEN
          p_ifac.li_Price_Object_Id := ec_product_price.object_id_by_uk(p_ifac.li_Price_Object_Code);
        END IF;
    END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getQty_P
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE getQty_P(
    uomGroup VARCHAR2,
    qty IN OUT NUMBER,
    uom IN OUT VARCHAR2,
    qTab IN OUT t_QtyTable )
--</EC-DOC>
IS
BEGIN

   IF (uomGroup = 'M') THEN
      IF (qTab(qTab.last).uom1_code IS NOT NULL AND Ecdp_Unit.GetUOMGroup(qTab(qTab.last).uom1_code) = 'M') THEN
         qty := qTab(qTab.last).qty1;
         qTab(qTab.last).qty1 := NULL;
         uom := qTab(qTab.last).uom1_code;
         qTab(qTab.last).uom1_code := NULL;
      ELSIF (qTab(qTab.last).uom2_code IS NOT NULL AND Ecdp_Unit.GetUOMGroup(qTab(qTab.last).uom2_code) = 'M') THEN
         qty := qTab(qTab.last).qty2;
         qTab(qTab.last).qty2 := NULL;
         uom := qTab(qTab.last).uom2_code;
         qTab(qTab.last).uom2_code := NULL;
      ELSIF (qTab(qTab.last).uom3_code IS NOT NULL AND Ecdp_Unit.GetUOMGroup(qTab(qTab.last).uom3_code) = 'M') THEN
         qty := qTab(qTab.last).qty3;
         qTab(qTab.last).qty3 := NULL;
         uom := qTab(qTab.last).uom3_code;
         qTab(qTab.last).uom3_code := NULL;
      END IF;
   ELSIF (uomGroup = 'V') THEN
      IF (qTab(qTab.last).uom1_code IS NOT NULL AND Ecdp_Unit.GetUOMGroup(qTab(qTab.last).uom1_code) = 'V') THEN
         qty := qTab(qTab.last).qty1;
         qTab(qTab.last).qty1 := NULL;
         uom := qTab(qTab.last).uom1_code;
         qTab(qTab.last).uom1_code := NULL;
      ELSIF (qTab(qTab.last).uom2_code IS NOT NULL AND Ecdp_Unit.GetUOMGroup(qTab(qTab.last).uom2_code) = 'V') THEN
         qty := qTab(qTab.last).qty2;
         qTab(qTab.last).qty2 := NULL;
         uom := qTab(qTab.last).uom2_code;
         qTab(qTab.last).uom2_code := NULL;
      ELSIF (qTab(qTab.last).uom3_code IS NOT NULL AND Ecdp_Unit.GetUOMGroup(qTab(qTab.last).uom3_code) = 'V') THEN
         qty := qTab(qTab.last).qty3;
         qTab(qTab.last).qty3 := NULL;
         uom := qTab(qTab.last).uom3_code;
         qTab(qTab.last).uom3_code := NULL;
      END IF;
   ELSIF (uomGroup = 'E') THEN
      IF (qTab(qTab.last).uom1_code IS NOT NULL AND Ecdp_Unit.GetUOMGroup(qTab(qTab.last).uom1_code) = 'E') THEN
         qty := qTab(qTab.last).qty1;
         qTab(qTab.last).qty1 := NULL;
         uom := qTab(qTab.last).uom1_code;
         qTab(qTab.last).uom1_code := NULL;
      ELSIF (qTab(qTab.last).uom2_code IS NOT NULL AND Ecdp_Unit.GetUOMGroup(qTab(qTab.last).uom2_code) = 'E') THEN
         qty := qTab(qTab.last).qty2;
         qTab(qTab.last).qty2 := NULL;
         uom := qTab(qTab.last).uom2_code;
         qTab(qTab.last).uom2_code := NULL;
      ELSIF (qTab(qTab.last).uom3_code IS NOT NULL AND Ecdp_Unit.GetUOMGroup(qTab(qTab.last).uom3_code) = 'E') THEN
         qty := qTab(qTab.last).qty3;
         qTab(qTab.last).qty3 := NULL;
         uom := qTab(qTab.last).uom3_code;
         qTab(qTab.last).uom3_code := NULL;
      END IF;
   ELSIF (uomGroup = 'X') THEN
      IF (qTab(qTab.last).uom1_code IS NOT NULL) THEN
         qty := qTab(qTab.last).qty1;
         qTab(qTab.last).qty1 := NULL;
         uom := qTab(qTab.last).uom1_code;
         qTab(qTab.last).uom1_code := NULL;
      ELSIF (qTab(qTab.last).uom2_code IS NOT NULL) THEN
         qty := qTab(qTab.last).qty2;
         qTab(qTab.last).qty2 := NULL;
         uom := qTab(qTab.last).uom2_code;
         qTab(qTab.last).uom2_code := NULL;
      ELSIF (qTab(qTab.last).uom3_code IS NOT NULL) THEN
         qty := qTab(qTab.last).qty3;
         qTab(qTab.last).qty3 := NULL;
         uom := qTab(qTab.last).uom3_code;
         qTab(qTab.last).uom3_code := NULL;
      END IF;
   END IF;
END getQty_P;


-----------------------------------------------------------------------------------------------------------------------------

 -- Returning TRANS, FIELD or VENDOR reflecting what level the interfaced qty record belong to
FUNCTION GetIfacRecordLevel(p_profit_center_code VARCHAR2,
                            p_vendor_code VARCHAR2,
                            p_contract_comp VARCHAR2,
                            p_object_type   VARCHAR2
) RETURN VARCHAR2
IS

  lv2_level VARCHAR2(32);

BEGIN

-- Analyze which level the records belongs to
    IF NVL(p_object_type,'OBJECT') = 'OBJECT_LIST' OR  p_profit_center_code = 'SUM' THEN

       lv2_level := 'TRANS';

    ELSIF p_contract_comp LIKE 'MVMF' THEN

       IF p_profit_center_code = 'SUM'  THEN

         lv2_level := 'TRANS';

       ELSE

         IF p_vendor_code LIKE '%_FULL' THEN

            lv2_level := 'FIELD';

         ELSE

            lv2_level := 'VENDOR';

         END IF;

       END IF;

    ELSIF p_contract_comp LIKE 'SVMF' THEN

       IF p_profit_center_code = 'SUM'  THEN

         lv2_level := 'TRANS';

       ELSE

         -- Field and Vendor levels are equal in terms of field and vendor code.
         lv2_level := 'FIELD';

       END IF;

    ELSIF p_contract_comp LIKE 'MVSF' THEN

       IF p_vendor_code LIKE '%_FULL' THEN

          -- Transaction and field levels are equal in terms of field and vendor code.
          lv2_level := 'TRANS';

       ELSE

          lv2_level := 'VENDOR';

       END IF;

    ELSIF p_contract_comp LIKE 'SVSF' THEN

       -- All levels are equal in terms of field and vendor code.
       lv2_level := 'TRANS';

    ELSIF p_contract_comp LIKE 'SVXF' THEN -- Unknown field composition

          lv2_level := 'VENDOR';

    ELSIF p_contract_comp LIKE 'MVXF' THEN -- Unknown field composition

       IF p_vendor_code LIKE '%_FULL' THEN

          -- Transaction and field levels are equal in terms of field and vendor code.
          lv2_level := 'FIELD';

       ELSE

          lv2_level := 'VENDOR';

       END IF;

    END IF;


  RETURN lv2_level;

END GetIfacRecordLevel;


-----------------------------------------------------------------------------------------------------------------------------
FUNCTION EncodeOriginalSalesQtyRecord_P(p_ifac_rec     IFAC_SALES_QTY%ROWTYPE,
                                      close_lob      BOOLEAN DEFAULT TRUE)
RETURN CLOB
IS
    l_ori_data         CLOB;
BEGIN
    dbms_lob.createtemporary(l_ori_data, true, dbms_lob.session);
    dbms_lob.open(l_ori_data, dbms_lob.lob_readwrite);

    -- Constract the string containing original data
    --
    -- NOTE: if more columns are added, it also should be added in function DecodeOrignalSalesQtyRecord
    --       and remove from ReAnalyseSalesQtyRecord.
    --
    append_ori_clob_p(l_ori_data, p_ifac_rec.CONTRACT_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.PROCESSING_PERIOD);
    append_ori_clob_p(l_ori_data, p_ifac_rec.PROFIT_CENTER_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.VENDOR_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.PRICE_CONCEPT_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.DELIVERY_POINT_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.PRODUCT_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.QTY_STATUS);
    append_ori_clob_p(l_ori_data, p_ifac_rec.PRICE_STATUS);
    append_ori_clob_p(l_ori_data, p_ifac_rec.DOC_STATUS);
    append_ori_clob_p(l_ori_data, p_ifac_rec.PERIOD_START_DATE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.PERIOD_END_DATE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.INT_FROM_DATE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.INT_TO_DATE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.LINE_ITEM_BASED_TYPE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.LINE_ITEM_TYPE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.INT_TYPE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.UNIT_PRICE_UNIT);
    append_ori_clob_p(l_ori_data, p_ifac_rec.SOURCE_NODE_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.PRICE_DATE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.PRICE_OBJECT_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.SALES_ORDER);
    append_ori_clob_p(l_ori_data, p_ifac_rec.UNIQUE_KEY_1);
    append_ori_clob_p(l_ori_data, p_ifac_rec.UNIQUE_KEY_2);
    append_ori_clob_p(l_ori_data, p_ifac_rec.VAT_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.IFAC_TT_CONN_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.IFAC_LI_CONN_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.CUSTOMER_CODE);
    append_ori_clob_p(l_ori_data, p_ifac_rec.Calc_Run_No);
    append_ori_clob_p(l_ori_data, p_ifac_rec.contract_account);
    append_ori_clob_p(l_ori_data, p_ifac_rec.contract_account_class);
    append_ori_clob_p(l_ori_data, p_ifac_rec.SOURCE_ENTRY_NO);
    append_ori_clob_p(l_ori_data, p_ifac_rec.LI_UNIQUE_KEY_1);
    append_ori_clob_p(l_ori_data, p_ifac_rec.LI_UNIQUE_KEY_2, TRUE);

    IF close_lob THEN
        dbms_lob.close(l_ori_data);
    END IF;

    RETURN l_ori_data;
END EncodeOriginalSalesQtyRecord_P;




-----------------------------------------------------------------------------------------------------------------------------

FUNCTION EncodeOriginalCargoRecord_P(p_ifac_rec        IFAC_CARGO_VALUE%ROWTYPE,
                                   close_lob         BOOLEAN DEFAULT TRUE)
RETURN CLOB
IS
    llob_data         CLOB;
BEGIN
    dbms_lob.createtemporary(llob_data, true, dbms_lob.session);
    dbms_lob.open(llob_data, dbms_lob.lob_readwrite);

    -- Constract the string containing original data
    --
    -- NOTE: if more columns are added, it also should be added in function DecodeOrignalCargoRecord
    --       and remove from ReAnalyseCargoRecord.
    --

    append_ori_clob_p(llob_data, p_ifac_rec.CONTRACT_CODE);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.VENDOR_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.CARGO_NO, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.PARCEL_NO, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.QTY_TYPE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.PROFIT_CENTER_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.PRICE_CONCEPT_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.PRODUCT_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.PRODUCT_SALES_ORDER_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.LOADING_COMM_DATE, ori_ifac_date_format), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.LOADING_DATE, ori_ifac_date_format), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.DELIVERY_COMM_DATE, ori_ifac_date_format), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.DELIVERY_DATE, ori_ifac_date_format), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.POINT_OF_SALE_DATE, ori_ifac_date_format), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.BL_DATE, ori_ifac_date_format), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.PRICE_DATE, ori_ifac_date_format), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.PRICE_STATUS, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.LOADING_PORT_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.DISCHARGE_PORT_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.CONSIGNOR_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.CONSIGNEE_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.CARRIER_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.VOYAGE_NO, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.DOC_STATUS, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.UNIT_PRICE, ORI_IFAC_NUMBER_FORMAT), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

/*    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.NET_QTY1, ORI_IFAC_NUMBER_FORMAT), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.GRS_QTY1, ORI_IFAC_NUMBER_FORMAT), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);
*/
    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.UOM1_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

/*    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.NET_QTY2, ORI_IFAC_NUMBER_FORMAT), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.GRS_QTY2, ORI_IFAC_NUMBER_FORMAT), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);
*/
    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.UOM2_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

/*    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.NET_QTY3, ORI_IFAC_NUMBER_FORMAT), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.GRS_QTY3, ORI_IFAC_NUMBER_FORMAT), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);
*/
    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.UOM3_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

/*    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.NET_QTY4, ORI_IFAC_NUMBER_FORMAT), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(p_ifac_rec.GRS_QTY4, ORI_IFAC_NUMBER_FORMAT), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);
*/
    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.UOM4_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.STATUS, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.DESCRIPTION, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.PRICE_OBJECT_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.CONTRACT_ID, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.VENDOR_ID, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.PRODUCT_ID, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.PROFIT_CENTER_ID, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.SOURCE_NODE_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(p_ifac_rec.SOURCE_NODE_ID, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.VAT_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.IFAC_TT_CONN_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.CUSTOMER_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(P_IFAC_REC.SOURCE_ENTRY_NO, ORI_IFAC_NUMBER_FORMAT), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.LOADING_BERTH_ID, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.LOADING_BERTH_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.DISCHARGE_BERTH_ID, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.DISCHARGE_BERTH_CODE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(P_IFAC_REC.INT_FROM_DATE, ori_ifac_date_format), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(TO_CHAR(P_IFAC_REC.INT_TO_DATE, ori_ifac_date_format), ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.LINE_ITEM_BASED_TYPE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.LINE_ITEM_TYPE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.INT_TYPE, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.UNIT_PRICE_UNIT, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.LI_UNIQUE_KEY_1, ORI_IFAC_NULL_DATA));
    DBMS_LOB.APPEND(LLOB_DATA, ORI_IFAC_DATA_SPLITOR);

    DBMS_LOB.APPEND(LLOB_DATA, NVL(P_IFAC_REC.LI_UNIQUE_KEY_2, ORI_IFAC_NULL_DATA));

    IF close_lob THEN
        dbms_lob.close(llob_data);
    END IF;

    RETURN llob_data;
END EncodeOriginalCargoRecord_P;


-----------------------------------------------------------------------------------------------------------------------------

FUNCTION DecodeOriginalSalesQtyRecord(P_ENCODEDRECORD CLOB)
RETURN IFAC_SALES_QTY%ROWTYPE
IS
    LLOB_DATA CLOB;
    LREC_RESULT IFAC_SALES_QTY%ROWTYPE;
    LN_CURRENT_INDEX NUMBER;
    LN_ELEMENT_END_INDEX NUMBER;
    LV2_ELEMENT_STR  VARCHAR2(2000);
    LT_VALUES t_table_varchar2;
    LN_VALUES_COUNT NUMBER;
    LN_LOB_LENGTH NUMBER;
    LN_VALUES_INDEX NUMBER;
    LB_WAS_RECORD_OPEN BOOLEAN;

BEGIN
    IF P_ENCODEDRECORD IS NOT NULL THEN
        LT_VALUES := t_table_varchar2();
        LLOB_DATA := P_ENCODEDRECORD;

        LB_WAS_RECORD_OPEN := TRUE;
        IF DBMS_LOB.ISOPEN(LLOB_DATA) = 0 THEN
            DBMS_LOB.OPEN(LLOB_DATA, DBMS_LOB.LOB_READONLY);
            LB_WAS_RECORD_OPEN := FALSE;
        END IF;

        -- Start reading the CLOB
        LN_CURRENT_INDEX := 1;
        LN_ELEMENT_END_INDEX := INSTRC(LLOB_DATA, ORI_IFAC_DATA_SPLITOR, LN_CURRENT_INDEX);
        LN_VALUES_COUNT := 0;
        LN_LOB_LENGTH := LENGTH(LLOB_DATA);

        WHILE(LN_CURRENT_INDEX <= LN_LOB_LENGTH) LOOP
            -- Get column string
            LV2_ELEMENT_STR := SUBSTRC(LLOB_DATA, LN_CURRENT_INDEX, CASE WHEN LN_ELEMENT_END_INDEX > 0 THEN (LN_ELEMENT_END_INDEX - LN_CURRENT_INDEX) ELSE LN_LOB_LENGTH - LN_CURRENT_INDEX + 1 END);
            IF LV2_ELEMENT_STR = ORI_IFAC_NULL_DATA THEN
                LV2_ELEMENT_STR := NULL;
            END IF;

            -- Put column string to collection
            LT_VALUES.EXTEND(1);
            LN_VALUES_COUNT := LN_VALUES_COUNT + 1;
            LT_VALUES(LN_VALUES_COUNT) := LV2_ELEMENT_STR;

            -- If the splitor was not found in last iteration
            -- exit the loop
            IF LN_ELEMENT_END_INDEX = 0 THEN
                EXIT;
            END IF;

            -- Get the start position of next string
            LN_CURRENT_INDEX := LN_ELEMENT_END_INDEX + LENGTH(ORI_IFAC_DATA_SPLITOR);
            LN_ELEMENT_END_INDEX := INSTRC(LLOB_DATA, ORI_IFAC_DATA_SPLITOR, LN_CURRENT_INDEX);
        END LOOP;

        IF NOT LB_WAS_RECORD_OPEN THEN
            DBMS_LOB.CLOSE(LLOB_DATA);
        END IF;

        -- Fill the column values into IFAC_SALES_QTY record
        LN_VALUES_INDEX := 0;

        lrec_result.contract_code := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.processing_period := to_date(ecdp_revn_common.get_next(lt_values, ln_values_index), ori_ifac_date_format);
        lrec_result.profit_center_code := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.vendor_code := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.price_concept_code := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.delivery_point_code := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.PRODUCT_CODE := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.QTY_STATUS := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.PRICE_STATUS := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.DOC_STATUS := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.PERIOD_START_DATE := to_date(ecdp_revn_common.get_next(lt_values, ln_values_index), ori_ifac_date_format);
        lrec_result.PERIOD_END_DATE := to_date(ecdp_revn_common.get_next(lt_values, ln_values_index), ori_ifac_date_format);
        lrec_result.INT_FROM_DATE := to_date(ecdp_revn_common.get_next(lt_values, ln_values_index), ori_ifac_date_format);
        lrec_result.INT_TO_DATE := to_date(ecdp_revn_common.get_next(lt_values, ln_values_index), ori_ifac_date_format);
        lrec_result.LINE_ITEM_BASED_TYPE := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.LINE_ITEM_TYPE := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.INT_TYPE := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.UNIT_PRICE_UNIT := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.SOURCE_NODE_CODE := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.PRICE_DATE := to_date(ecdp_revn_common.get_next(lt_values, ln_values_index), ori_ifac_date_format);
        lrec_result.PRICE_OBJECT_CODE := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.SALES_ORDER := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.UNIQUE_KEY_1 := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.UNIQUE_KEY_2 := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.VAT_CODE := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.IFAC_TT_CONN_CODE := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.IFAC_LI_CONN_CODE := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.CUSTOMER_CODE := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.Calc_Run_No := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.Contract_Account := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.Contract_Account_Class := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.SOURCE_ENTRY_NO := TO_NUMBER(ecdp_revn_common.get_next(lt_values, ln_values_index), ori_ifac_number_format);
        lrec_result.LI_UNIQUE_KEY_1 := ecdp_revn_common.get_next(lt_values, ln_values_index);
        lrec_result.LI_UNIQUE_KEY_2 := ecdp_revn_common.get_next(lt_values, ln_values_index);

    END IF;

    RETURN lrec_result;

EXCEPTION
    WHEN OTHERS THEN
        -- Close the CLOB if it is still open
        IF DBMS_LOB.ISOPEN(LLOB_DATA) = 1 THEN
            DBMS_LOB.CLOSE(LLOB_DATA);
        END IF;

        RAISE_APPLICATION_ERROR(-20000, 'Errored when trying to decode data. ' || SQLERRM);

END DecodeOriginalSalesQtyRecord;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION DecodeOriginalCargoRecord(P_ENCODEDRECORD CLOB)
RETURN IFAC_CARGO_VALUE%ROWTYPE
IS
    TYPE VARCHAR2_TABLE IS TABLE OF VARCHAR2(2000);

    LLOB_DATA CLOB;
    LREC_RESULT IFAC_CARGO_VALUE%ROWTYPE;
    LN_CURRENT_INDEX NUMBER;
    LN_ELEMENT_END_INDEX NUMBER;
    LV2_ELEMENT_STR  VARCHAR2(240);
    LT_VALUES VARCHAR2_TABLE;
    LN_VALUES_COUNT NUMBER;
    LN_LOB_LENGTH NUMBER;
    LN_VALUES_INDEX NUMBER;
    LB_WAS_RECORD_OPEN BOOLEAN;
BEGIN
    IF P_ENCODEDRECORD IS NOT NULL THEN
        LT_VALUES := VARCHAR2_TABLE();
        LLOB_DATA := P_ENCODEDRECORD;

        LB_WAS_RECORD_OPEN := TRUE;
        IF DBMS_LOB.ISOPEN(LLOB_DATA) = 0 THEN
            DBMS_LOB.OPEN(LLOB_DATA, DBMS_LOB.LOB_READONLY);
            LB_WAS_RECORD_OPEN := FALSE;
        END IF;

        -- Start reading the CLOB
        LN_CURRENT_INDEX := 1;
        LN_ELEMENT_END_INDEX := INSTRC(LLOB_DATA, ORI_IFAC_DATA_SPLITOR, LN_CURRENT_INDEX);
        LN_VALUES_COUNT := 0;
        LN_LOB_LENGTH := LENGTH(LLOB_DATA);

        WHILE(LN_CURRENT_INDEX <= LN_LOB_LENGTH) LOOP
            -- Get column string
            LV2_ELEMENT_STR := SUBSTRC(LLOB_DATA, LN_CURRENT_INDEX, CASE WHEN LN_ELEMENT_END_INDEX > 0 THEN (LN_ELEMENT_END_INDEX - LN_CURRENT_INDEX) ELSE LN_LOB_LENGTH - LN_CURRENT_INDEX + 1 END);
            IF LV2_ELEMENT_STR = ORI_IFAC_NULL_DATA THEN
                LV2_ELEMENT_STR := NULL;
            END IF;

            -- Put column string to collection
            LT_VALUES.EXTEND(1);
            LN_VALUES_COUNT := LN_VALUES_COUNT + 1;
            LT_VALUES(LN_VALUES_COUNT) := LV2_ELEMENT_STR;

            -- If the splitor was not found in last iteration
            -- exit the loop
            IF LN_ELEMENT_END_INDEX = 0 THEN
                EXIT;
            END IF;

            -- Get the start position of next string
            LN_CURRENT_INDEX := LN_ELEMENT_END_INDEX + LENGTH(ORI_IFAC_DATA_SPLITOR);
            LN_ELEMENT_END_INDEX := INSTRC(LLOB_DATA, ORI_IFAC_DATA_SPLITOR, LN_CURRENT_INDEX);
        END LOOP;

        IF NOT LB_WAS_RECORD_OPEN THEN
            DBMS_LOB.CLOSE(LLOB_DATA);
        END IF;

        -- Fill the column values into IFAC_CARGO_VALUE record
        LN_VALUES_INDEX := 0;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.CONTRACT_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.VENDOR_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.CARGO_NO := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.PARCEL_NO := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.QTY_TYPE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.PROFIT_CENTER_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.PRICE_CONCEPT_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.PRODUCT_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.PRODUCT_SALES_ORDER_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.LOADING_COMM_DATE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_DATE(LT_VALUES(LN_VALUES_INDEX), ori_ifac_date_format) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.LOADING_DATE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_DATE(LT_VALUES(LN_VALUES_INDEX), ori_ifac_date_format) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.DELIVERY_COMM_DATE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_DATE(LT_VALUES(LN_VALUES_INDEX), ori_ifac_date_format) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.DELIVERY_DATE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_DATE(LT_VALUES(LN_VALUES_INDEX), ori_ifac_date_format) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.POINT_OF_SALE_DATE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_DATE(LT_VALUES(LN_VALUES_INDEX), ori_ifac_date_format) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.BL_DATE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_DATE(LT_VALUES(LN_VALUES_INDEX), ori_ifac_date_format) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.PRICE_DATE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_DATE(LT_VALUES(LN_VALUES_INDEX), ori_ifac_date_format) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.PRICE_STATUS := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.LOADING_PORT_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.DISCHARGE_PORT_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.CONSIGNOR_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.CONSIGNEE_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.CARRIER_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.VOYAGE_NO := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.DOC_STATUS := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.UNIT_PRICE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_NUMBER(LT_VALUES(LN_VALUES_INDEX), ORI_IFAC_NUMBER_FORMAT) ELSE NULL END;

/*        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.NET_QTY1 := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_NUMBER(LT_VALUES(LN_VALUES_INDEX), ORI_IFAC_NUMBER_FORMAT) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.GRS_QTY1 := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_NUMBER(LT_VALUES(LN_VALUES_INDEX), ORI_IFAC_NUMBER_FORMAT) ELSE NULL END;
*/
        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.UOM1_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

/*        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.NET_QTY2 := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_NUMBER(LT_VALUES(LN_VALUES_INDEX), ORI_IFAC_NUMBER_FORMAT) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.GRS_QTY2 := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_NUMBER(LT_VALUES(LN_VALUES_INDEX), ORI_IFAC_NUMBER_FORMAT) ELSE NULL END;
*/
        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.UOM2_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

/*        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.NET_QTY3 := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_NUMBER(LT_VALUES(LN_VALUES_INDEX), ORI_IFAC_NUMBER_FORMAT) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.GRS_QTY3 := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_NUMBER(LT_VALUES(LN_VALUES_INDEX), ORI_IFAC_NUMBER_FORMAT) ELSE NULL END;
*/
        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.UOM3_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

/*        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.NET_QTY4 := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_NUMBER(LT_VALUES(LN_VALUES_INDEX), ORI_IFAC_NUMBER_FORMAT) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.GRS_QTY4 := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_NUMBER(LT_VALUES(LN_VALUES_INDEX), ORI_IFAC_NUMBER_FORMAT) ELSE NULL END;
*/
        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.UOM4_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.STATUS := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.DESCRIPTION := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.PRICE_OBJECT_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.CONTRACT_ID := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.VENDOR_ID := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.PRODUCT_ID := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.PROFIT_CENTER_ID := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.SOURCE_NODE_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.SOURCE_NODE_ID := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.VAT_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.IFAC_TT_CONN_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.CUSTOMER_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.SOURCE_ENTRY_NO := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_NUMBER(LT_VALUES(LN_VALUES_INDEX), ORI_IFAC_NUMBER_FORMAT) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.LOADING_BERTH_ID := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.LOADING_BERTH_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.DISCHARGE_BERTH_ID := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.DISCHARGE_BERTH_CODE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.INT_FROM_DATE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_DATE(LT_VALUES(LN_VALUES_INDEX), ori_ifac_date_format) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.INT_TO_DATE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN TO_DATE(LT_VALUES(LN_VALUES_INDEX), ori_ifac_date_format) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.LINE_ITEM_BASED_TYPE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.LINE_ITEM_TYPE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.INT_TYPE := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.UNIT_PRICE_UNIT := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.LI_UNIQUE_KEY_1 := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

        LN_VALUES_INDEX := LN_VALUES_INDEX + 1;
        LREC_RESULT.LI_UNIQUE_KEY_2 := CASE WHEN LN_VALUES_COUNT >= LN_VALUES_INDEX THEN LT_VALUES(LN_VALUES_INDEX) ELSE NULL END;

    END IF;

    RETURN LREC_RESULT;

EXCEPTION
    WHEN OTHERS THEN
        -- Close the CLOB if it is still open
        IF DBMS_LOB.ISOPEN(LLOB_DATA) = 1 THEN
            DBMS_LOB.CLOSE(LLOB_DATA);
        END IF;

        RAISE_APPLICATION_ERROR(-20000, 'Errored when trying to decode data. ' || SQLERRM);

END DecodeOriginalCargoRecord;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetIfacCargoQtyTT
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION GetIfacCargoQtyTT(p_Rec_ICV ifac_cargo_value%ROWTYPE)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_tt(
            cp_daytime                              DATE,
            cp_Contract_Id                          VARCHAR2,
            cp_Price_Concept_Code                   VARCHAR2,
            cp_Price_Object_Id                      VARCHAR2,
            cp_Uom1_Code                            VARCHAR2,
            cp_Product_Id                           VARCHAR2,
            cp_Qty_Type                             VARCHAR2,
            cp_if_tt_conn_code                      VARCHAR2,
            cp_preceding                            VARCHAR2,
            cp_dist_type                            VARCHAR2,
            cp_dist_object_type                     VARCHAR2,
            cp_profit_centre_id                     VARCHAR2)
IS
  SELECT ct.transaction_key, tt.object_id, ct.document_key, ttv.dist_code, cdv.automation_priority
    FROM contract_doc             cd,
         contract_doc_version     cdv,
         transaction_template     tt,
         transaction_tmpl_version ttv,
         cont_transaction         ct
   WHERE cd.contract_id = cp_Contract_Id
     AND cd.object_id = cdv.object_id
     AND cdv.daytime <= cp_daytime
     AND NVL(cdv.end_date, cp_daytime+1) > cp_daytime

     AND tt.contract_doc_id = cd.object_id
     AND tt.object_id = ttv.object_id
     AND ttv.daytime <= cp_daytime
     AND NVL(ttv.end_date, cp_daytime+1) > cp_daytime
     AND tt.object_id = ct.trans_template_id(+)

     AND cdv.automation_ind = 'Y'
     AND cdv.automation_priority IS NOT NULL
     AND ttv.uom1_code = cp_uom1_code
     AND nvl(ttv.req_qty_type,cp_Qty_Type) = cp_Qty_Type
     AND ttv.transaction_scope = 'CARGO_BASED'
     AND nvl(ttv.ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')

     -- Cater for no price object on transaction template:
     AND NVL(ttv.price_concept_code,NVL(cp_Price_Concept_Code,'x')) = NVL( cp_Price_Concept_Code , NVL(ttv.price_concept_code,'x') )
     AND NVL(ttv.price_object_id,NVL(cp_price_object_id,'x')) =    NVL(cp_price_object_id,NVL(TTV.price_object_id,'x'))
     AND NVL(ttv.product_id,NVL(cp_Product_Id,'x')) = NVL( cp_Product_Id, NVL(ttv.product_id,'x') )

     -- Match on tt's object or object list. Dist Code is mandatory.
     AND  ttv.dist_object_type = decode(cp_dist_object_type,'OBJECT_LIST',
                               ec_object_list_version.class_name(cp_profit_centre_id,cp_daytime,'<='),
                               NVL(cp_dist_object_type,'FIELD'))
     AND (ecdp_inbound_interface.isObjectInObjectList(cp_profit_centre_id, ec_object_list.object_id_by_uk(ttv.dist_code), cp_daytime) = 'Y'
               or ecdp_objects.GetObjCode(cp_profit_centre_id) IN ('SUM',ttv.dist_code)
         )
 ORDER BY DECODE(ecdp_objects.GetObjCode(cp_profit_centre_id),'SUM',
                 DECODE(ttv.dist_type, 'OBJECT_LIST', 1, 10),  -- If interfacing a sum object list should come first otherwise they come last
                 DECODE(ttv.dist_type, 'OBJECT_LIST', 10, 1)), decode(cp_preceding,'Y', Decode(cdv.doc_concept_code,'STANDALONE',1,0),0),-- IF there is a preceding document standalones should have lower priorty
                 automation_priority ;

CURSOR c_object_list (
            cp_object_list_id                       VARCHAR2,
            cp_daytime                              DATE)
IS
SELECT ecdp_objects.GetObjIDFromCode(object_list_setup.GENERIC_CLASS_NAME, object_list_setup.GENERIC_OBJECT_CODE) object_id
    FROM object_list_setup
   WHERE object_list_setup.object_id = cp_object_list_id
     AND object_list_setup.daytime <= cp_daytime;

   lv2_cont_comp VARCHAR2(32);
   lv2_result VARCHAR2(32);
   lb_documentExist BOOLEAN := FALSE;
   ld_processing_period DATE;
   lrec_cd cont_document%ROWTYPE;
   lrec_ct cont_transaction%ROWTYPE;
   lv2_preceding_doc_key VARCHAR2(32);
   lv2_dendent_possible VARCHAR(1) := 'N';

   lv2_dist_type VARCHAR2(32);
BEGIN


   lv2_dist_type := p_Rec_ICV.dist_type;
   IF p_Rec_ICV.Dist_Type IS NULL THEN
     IF p_Rec_ICV.Profit_Center_Code = 'SUM' THEN
       lv2_dist_type := 'OBJECT_LIST';
     ELSE
       lv2_dist_type := 'OBJECT';
     END IF;
   END IF;
   IF p_Rec_ICV.trans_temp_id_ovrd IS NULL THEN
    IF p_Rec_ICV.Contract_Id IS NOT NULL THEN
       ld_processing_period := ecdp_revn_ifac_common.GetCargoProcessingPeriod(p_Rec_ICV, ec_contract.start_date(p_Rec_ICV.Contract_Id));
    END IF;

    lv2_preceding_doc_key := ecdp_document_gen_util.GetCargoPrecedingDocKey(p_Rec_ICV.contract_id,
                                 p_Rec_ICV.cargo_no,
                                 p_Rec_ICV.Parcel_No,
                                 NULL ,
                                 p_Rec_ICV.Bl_Date,
                                 p_Rec_ICV.Ifac_Tt_Conn_Code,
                                 p_Rec_ICV.customer_id);

    IF lv2_preceding_doc_key IS NOT NULL THEN
      IF ec_cont_document.document_level_code(lv2_preceding_doc_key) in ('TRANSFER','BOOKED') THEN
        lv2_dendent_possible := 'Y';
      END IF;
    END IF;
    lv2_cont_comp := ecdp_contract_setup.getvendorcomposition(p_Rec_Icv.Contract_Id, ld_processing_period);
    WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Finding Transaction Template using Composition: ' || nvl(p_Rec_Icv.Dist_Type,'NULL'));

    FOR tt IN c_tt(ld_processing_period,
                   p_Rec_Icv.Contract_Id,
                   p_Rec_Icv.Price_Concept_Code,
                   p_rec_icv.price_object_id,
                   p_rec_icv.uom1_code,
                   p_Rec_Icv.Product_Id,
                   p_Rec_Icv.Qty_Type,
                   p_Rec_Icv.ifac_tt_conn_code,
                   lv2_dendent_possible,
                   lv2_dist_type,
                   p_Rec_Icv.Object_Type,
                   p_Rec_Icv.Profit_Center_id) LOOP


      --Filters out standalone when a booked, non-reversal document is found and the preceding document key is not emp?ty
      IF lv2_result IS NULL OR (lb_documentExist and (lv2_preceding_doc_key is null or ec_contract_doc_version.doc_concept_code(ec_transaction_template.contract_doc_id(tt.object_id),ld_processing_period,'<=') != 'STANDALONE')) THEN

          IF p_Rec_ICV.Profit_Center_Code = 'SUM' OR p_Rec_ICV.Object_Type = 'OBJECT_LIST' THEN
            lv2_result := tt.object_id;

          ELSE

            FOR object_list IN c_object_list(ec_object_list.object_id_by_uk(tt.dist_code), ld_processing_period) LOOP
              IF object_list.object_id = p_Rec_ICV.Profit_Center_Id THEN -- Profit center found in field group
                lv2_result := tt.object_id;

              END IF;
            END LOOP;
          END IF;

          IF lv2_result IS NULL AND  tt.dist_code = p_Rec_ICV.Profit_Center_Code THEN
            lv2_result := tt.object_id; -- Profit center match on transaction template

          END IF;

        -- This sub was added because we might want to use the next (priority) of document setup
        -- if a booked non-reversed document already exists for the selected document setup.
        IF tt.document_key IS NOT NULL THEN

           lrec_cd := ec_cont_document.row_by_pk(tt.document_key);
           lrec_ct := ec_cont_transaction.row_by_pk(tt.transaction_key);
           IF lrec_cd.reversal_ind = 'N' AND lrec_cd.document_level_code = 'BOOKED' AND ecdp_document.GetReversalDoc(tt.document_key) IS NULL  THEN
               IF lrec_ct.cargo_name = p_Rec_ICV.Cargo_No and
                  lrec_ct.parcel_name = p_Rec_ICV.Parcel_No then
						lb_documentExist := TRUE;
		END IF;
          ELSE
            lb_documentExist := FALSE;

          END IF;
        ELSE
          lb_documentExist := FALSE;
        END IF;

      END IF;

    END LOOP;
    ELSE
        lv2_result := p_Rec_ICV.trans_temp_id_ovrd;
      END IF;
    RETURN lv2_result;

END GetIfacCargoQtyTT;

    -----------------------------------------------------------------------
    -- Validates interfaced Vat Code.
    ----+----------------------------------+-------------------------------
    FUNCTION validate_vat_code_p(
        p_contract_id                      VARCHAR2,
        p_daytime                          DATE,
        p_vat_code                         VARCHAR2
        )
    RETURN BOOLEAN
    IS
        l_result                           BOOLEAN := TRUE;

        CURSOR c_vat_code(
            cp_contract_id                 VARCHAR2,
            cp_tt_daytime                  DATE,
            cp_vat_code                    VARCHAR2)
        IS
             SELECT COUNT(*) AS vat_count
             FROM ov_vat_code
             WHERE vat_type = 'I'
               AND code = cp_vat_code
               AND (( COUNTRY_ID IN
                   (SELECT com_v.country_id
                      FROM COMPANY_VERSION com_v
                     WHERE com_v.object_id =
                           ec_contract_version.company_id(cp_contract_id,
                                                          cp_tt_daytime,
                                                          '<=')
                       AND com_v.daytime =
                           (SELECT max(com_v2.daytime)
                              FROM COMPANY_VERSION com_v2
                             WHERE com_v2.object_id =
                                   ec_contract_version.company_id(cp_contract_id,
                                                                  cp_tt_daytime,
                                                                  '<=')
                               AND com_v2.daytime <= cp_tt_daytime))
                )or (object_id in
                   (select object_id
                      from VAT_CODE_COUNTRY_SETUP
                     where country_id =
                           ec_company_version.country_id(ec_contract_version.company_id(cp_contract_id,
                                                                                        cp_tt_daytime,
                                                                                        '<='),
                                                         cp_tt_daytime,
                                                         '<='))));

    BEGIN
        IF p_contract_id IS NOT NULL AND p_daytime IS NOT NULL AND p_vat_code IS NOT NULL THEN
            FOR rsVC IN c_vat_code(p_contract_id,
                                   p_daytime,
                                   p_vat_code) LOOP
                IF rsVC.Vat_Count = 0 THEN
                    l_result := FALSE;
                END IF;
            END LOOP;
        END IF;

        RETURN l_result;
    END validate_vat_code_p;

    -----------------------------------------------------------------------
    -- Validates given ifac record for common data.
    --
    -- Parameters:
    --     p_intermediate_result: the intermediate validation result from
    --         previous validators.
    ----+----------------------------------+-------------------------------
    PROCEDURE validate_ifac_common_p(
        p_ifac                             IN OUT NOCOPY ifac_sales_qty%ROWTYPE
       ,p_intermediate_result              IN OUT BOOLEAN
       ,p_error_message                    OUT VARCHAR2
       )
    IS
    BEGIN
        IF NOT p_intermediate_result THEN
            RETURN;
        END IF;

        -- Validates when ifac_li_conn_code presents, line_item_template_id is required
        IF p_ifac.ifac_li_conn_code IS NOT NULL AND p_ifac.line_item_template_id IS NULL THEN
            p_intermediate_result := FALSE;
            p_error_message := 'Was not able to find a line item template with [Interface Line Item Connection Code] = '''
                || p_ifac.ifac_li_conn_code || '''.';
            RETURN;
        END IF;

        -- Validates Vat Code
        IF NOT validate_vat_code_p(p_ifac.contract_id, p_ifac.processing_period, p_ifac.vat_code) THEN
            p_intermediate_result := FALSE;
            p_error_message := 'Vat Code ''' || p_ifac.vat_code || ''' for ' || p_ifac.line_item_based_type || ' line item is not valid for current contract.' || ec_transaction_template.start_date(p_ifac.trans_temp_id);
            RETURN;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Validates given ifac record.
    ----+----------------------------------+-------------------------------
    FUNCTION validate_ifac_p(
        p_ifac                             IN OUT NOCOPY ifac_sales_qty%ROWTYPE
       ,p_error_message                    OUT VARCHAR2
       )
    RETURN BOOLEAN
    IS
        l_error_message                    VARCHAR2(2000);
        l_result                           BOOLEAN;
    BEGIN
        l_result := TRUE;

        validate_ifac_common_p(p_ifac, l_result, p_error_message);

        RETURN l_result;
    END;

    -----------------------------------------------------------------------
    -- Gets transaction template for line interface (period based).
    ----+----------------------------------+-------------------------------
    FUNCTION find_transaction_template(
        p_Rec                              IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
       ,p_doc_concept_code                 VARCHAR2 DEFAULT NULL
       )
    RETURN T_REVN_OBJ_INFO
    IS
        l_tt_info                          T_REVN_OBJ_INFO;
        lb_documentExist                   BOOLEAN := FALSE;
        l_tt_overwrite                     transaction_template.object_id%TYPE;
        l_transaction_tmpl_rec             transaction_tmpl_version%ROWTYPE;

        CURSOR c_Trans(
                cp_contract_id                          VARCHAR2,
                cp_daytime                              DATE,
                cp_from_date                            DATE,
                cp_to_date                              DATE,
                cp_delivery_point_id                    VARCHAR2,
                cp_product_id                           VARCHAR2,
                cp_profit_centre_id                     VARCHAR2,
                cp_qty_status                           VARCHAR2,
                cp_price_concept_code                   VARCHAR2,
                cp_price_object_id                      VARCHAR2,
                cp_uom1_code                            VARCHAR2,
                cp_doc_concept_code                     VARCHAR2,
                cp_if_tt_conn_code                      VARCHAR2 DEFAULT NULL,
                cp_dist_type                            VARCHAR2,
                cp_object_type                          VARCHAR2)
        IS
            select * from (
              -- Full config (tt has Price Object, may not have delivery point) for QTY
              SELECT DISTINCT tt.object_id,
                              tt.object_code,
                              ct.document_key,
                              ttv.name,
                              cdv.automation_priority,
                              tt.sort_order tt_sort_order,
                              1 sort_order,
                              ttv.dist_type,
                              ttv.daytime,
                              ttv.end_date
                FROM contract_doc             cd,
                   contract_doc_version     cdv,
                   transaction_template     tt,
                   transaction_tmpl_version ttv,
                   cont_transaction         ct
               WHERE cd.contract_id = cp_contract_id
                 AND cdv.object_id = cd.object_id
                 AND cdv.daytime <= cp_daytime
                 AND cdv.automation_ind = 'Y'
                 AND cdv.automation_priority IS NOT NULL
                 AND nvl(cdv.end_date, cp_daytime + 1) > cp_daytime
                 AND tt.contract_doc_id = cd.object_id
                 AND ttv.object_id = tt.object_id
                 AND ttv.daytime <= cp_daytime
                 AND NVL(ttv.end_date, cp_daytime + 1) > cp_daytime
                 AND tt.object_id = ct.trans_template_id(+)
                 AND cp_from_date = ct.supply_from_date(+)
                 AND cp_to_date = ct.supply_to_date(+)
                 -- Cater for no price object and no price concept code on transaction template:
                 AND NVL(ttv.price_concept_code,NVL(cp_price_concept_code,'x')) = NVL( cp_price_concept_code , NVL(ttv.price_concept_code,'x') )
                 AND NVL(ttv.price_object_id,NVL(cp_price_object_id,'x')) =    NVL(cp_price_object_id,NVL(TTV.price_object_id,'x'))
                 AND NVL(ttv.product_id,NVL(cp_Product_Id,'x')) = NVL( cp_Product_Id, NVL(ttv.product_id,'x') )
                 AND NVL(ttv.req_qty_type,NVL(cp_qty_status,'x')) =
                   CASE cp_qty_status WHEN 'PPA' THEN NVL(ttv.req_qty_type,NVL(cp_qty_status,'x'))
                      ELSE
                        NVL( cp_qty_status, NVL(ttv.req_qty_type,'x') )
                      END
                 AND NVL(ttv.uom1_code,NVL(cp_uom1_code,'x')) = NVL( cp_uom1_code, NVL(ttv.uom1_code,'x') )
                 AND NVL(ttv.delivery_point_id,NVL(cp_delivery_point_id,'x')) = NVL( cp_delivery_point_id, NVL(ttv.delivery_point_id,'x') )
                 AND nvl(ttv.ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')
                 AND ttv.price_object_id = CASE WHEN cp_price_object_id IS NULL THEN ttv.price_object_id ELSE cp_price_object_id END
                 -- If looking for a doc setup with a specific concept (p_doc_concept_code is optional)
                 AND cdv.doc_concept_code LIKE (CASE WHEN cp_doc_concept_code IS NOT NULL THEN cp_doc_concept_code ELSE cdv.doc_concept_code END)
                 -- Match on tt's object or object list. Dist Code is mandatory.
                 AND ttv.dist_object_type = decode(cp_object_type,'OBJECT_LIST',
                                             ec_object_list_version.class_name(cp_profit_centre_id,cp_daytime,'<='),
                                             NVL(cp_object_type,'FIELD'))
                 AND (ecdp_inbound_interface.isObjectInObjectList(cp_profit_centre_id, ec_object_list.object_id_by_uk(ttv.dist_code), cp_daytime) = 'Y'
                             or ecdp_objects.GetObjCode(cp_profit_centre_id) IN ('SUM',ttv.dist_code))
        UNION ALL
          -- Reduced config (with Price Object interfaced in)
          SELECT DISTINCT tt.object_id,
                          tt.object_code,
                          ct.document_key,
                          ttv.name,
                          cdv.automation_priority,
                          tt.sort_order tt_sort_order,
                          1 sort_order,
                          ttv.dist_type,
                          ttv.daytime,
                          ttv.end_date
            FROM contract_doc             cd,
               contract_doc_version     cdv,
               transaction_template     tt,
                 transaction_tmpl_version ttv,
                 cont_transaction         ct
           WHERE cd.contract_id = cp_contract_id
             AND cdv.object_id = cd.object_id
             AND cdv.daytime <= cp_daytime
             AND cdv.automation_ind = 'Y'
             AND cdv.automation_priority IS NOT NULL
             AND nvl(cdv.end_date, cp_daytime + 1) > cp_daytime
             AND tt.contract_doc_id = cd.object_id
             AND ttv.object_id = tt.object_id
             AND ttv.daytime <= cp_daytime
             AND NVL(ttv.end_date, cp_daytime + 1) > cp_daytime
             AND tt.object_id = ct.trans_template_id(+)
             AND cp_from_date = ct.supply_from_date(+)
             AND cp_to_date = ct.supply_to_date(+)
             -- If key matching columns are blank on the TT, it means it accepts any value from the interface ('x' = 'x').
             -- Delivery point should not be mandatory in ifac if Transaction Template is set
             AND NVL(ttv.delivery_point_id,'x')  = CASE WHEN ttv.delivery_point_id  IS NULL THEN 'x' ELSE nvl(cp_delivery_point_id,ttv.delivery_point_id) END
             AND NVL(ttv.req_qty_type,'x')       = CASE WHEN ttv.req_qty_type       IS NULL THEN 'x' ELSE cp_qty_status END
             AND NVL(ttv.uom1_code,'x')          = CASE WHEN ttv.uom1_code          IS NULL THEN 'x' ELSE cp_uom1_code END
             AND NVL(ttv.price_concept_code,'x') = CASE WHEN ttv.price_concept_code IS NULL THEN 'x' ELSE cp_price_concept_code END
             AND nvl(ttv.price_object_id,'x')    = CASE WHEN ttv.price_object_id    IS NULL THEN 'x' ELSE NVL(cp_price_object_id,nvl(ttv.price_object_id,'x')) END
             AND NVL(ttv.product_id,'x')         = CASE WHEN ttv.product_id         IS NULL THEN 'x' ELSE cp_product_id END
             AND nvl(ttv.ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')
             -- If looking for a doc setup with a specific concept (p_doc_concept_code is optional)
             AND cdv.doc_concept_code LIKE (CASE WHEN cp_doc_concept_code IS NOT NULL THEN cp_doc_concept_code ELSE cdv.doc_concept_code END)
             -- Match on tt's object or object list. Dist Code is mandatory.
             AND ttv.dist_object_type = decode(cp_object_type,
                                                'OBJECT_LIST',
                                                ec_object_list_version.class_name(cp_profit_centre_id,cp_daytime,'<='),
                                                NVL(cp_object_type,'FIELD'))
             AND (ecdp_inbound_interface.isObjectInObjectList(cp_profit_centre_id, ec_object_list.object_id_by_uk(ttv.dist_code), cp_daytime) = 'Y'
                         or ecdp_objects.GetObjCode(cp_profit_centre_id) IN ('SUM',ttv.dist_code))
             --AND ttv.dist_type = cp_dist_type -- TODO: is this required? logic added by Piyali
         )
         ORDER BY DECODE(ecdp_objects.GetObjCode(cp_profit_centre_id),'SUM',
                         DECODE(dist_type, 'OBJECT_LIST', 1, 10),  -- If interfacing a sum object list should come first otherwise they come last
                         DECODE(dist_type, 'OBJECT_LIST', 10, 1)), automation_priority, sort_order, tt_sort_order;

        lv2_dist_type VARCHAR2(32);
    BEGIN
        IF p_Rec.trans_temp_id_ovrd IS NULL THEN
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO,
                'Finding Transaction Template using Composition ''' || nvl(p_Rec.Dist_Type,'NULL')
                || ''' and doc concept ''' || nvl(p_doc_concept_code,'NULL') || '''.');

            lv2_dist_type := p_Rec.Dist_Type;
            IF p_Rec.Dist_Type IS NULL THEN
                IF p_Rec.Profit_Center_Code = 'SUM' THEN
                    lv2_dist_type := 'OBJECT_LIST';
                ELSE
                    lv2_dist_type := 'OBJECT';
                END IF;
            END IF;

            FOR rsT IN c_Trans(
                    p_Rec.Contract_Id,
                    p_Rec.Processing_Period,
                    p_Rec.Period_Start_Date,
                    p_Rec.Period_End_Date,
                    p_Rec.Delivery_Point_Id,
                    p_Rec.Product_Id,
                    p_Rec.Profit_Center_id,
                    p_Rec.Qty_Status,
                    p_Rec.Price_Concept_Code,
                    p_Rec.Price_Object_Id,
                    p_Rec.Uom1_Code,
                    p_doc_concept_code,
                    p_Rec.ifac_tt_conn_code,
                    lv2_dist_type,
                    nvl(p_Rec.Object_Type, 'FIELD')) LOOP
                IF l_tt_info.object_id IS NULL OR (lb_documentExist and ec_contract_doc_version.doc_concept_code(
                        ec_transaction_template.contract_doc_id(rsT.object_id),
                        p_Rec.Processing_Period,'<=') != 'STANDALONE') THEN
                    l_tt_info := T_REVN_OBJ_INFO(
                        object_id => rsT.object_id, object_name => rsT.name, object_code => rsT.object_code,
                        version_date => rsT.daytime, version_end_date => rsT.end_date);

                    -- This sub was added because we might want to use the next (priority) of document setup
                    -- if a booked non-reversed document already exists for the selected document setup.
                    IF rsT.document_key IS NOT NULL THEN
                        IF nvl(ec_cont_document.reversal_ind(rsT.document_key),'N') = 'N'
                               AND ecdp_document.GetReversalDoc(rsT.document_key) IS NULL
                               AND nvl(ec_cont_document.document_level_code(rsT.document_key),'NA') = 'BOOKED' THEN
                            lb_documentExist := TRUE;
                        ELSE
                            lb_documentExist := FALSE;
                        END IF;
                    ELSE
                        lb_documentExist := FALSE;
                    END IF;
               END IF;
            END LOOP;
        ELSE
            --l_tt_overwrite := ec_ifac_sales_qty.trans_temp_id_ovrd(p_Rec.Source_Entry_No);
            l_transaction_tmpl_rec := ec_transaction_tmpl_version.row_by_pk(
                p_Rec.trans_temp_id_ovrd, p_Rec.Processing_Period, '<=');
            l_tt_info := T_REVN_OBJ_INFO(
                object_id => l_transaction_tmpl_rec.object_id,
                object_name => l_transaction_tmpl_rec.name,
                object_code => p_Rec.Trans_Temp_Code_Ovrd,
                version_date => l_transaction_tmpl_rec.daytime,
                version_end_date => l_transaction_tmpl_rec.end_date);
        END IF;

        RETURN l_tt_info;
    END find_transaction_template;


    -----------------------------------------------------------------------
    -- Gets line item template for quantity line interface (period
    -- based).
    ----+----------------------------------+-------------------------------
    FUNCTION find_line_item_template_qty_p(
        p_Rec                              IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
       ,p_transaction_template             IN OUT NOCOPY T_REVN_OBJ_INFO
       )
    RETURN T_REVN_OBJ_INFO
    IS
        l_lit_info                         T_REVN_OBJ_INFO;

        -- This cursor returns best match non-qty line item under given
        -- transaction template version.
        CURSOR c_line_item(
            cp_transaction_template_id              transaction_template.object_id%TYPE
           ,cp_transaction_template_ver             transaction_tmpl_version.daytime%TYPE
           ,cp_line_item_type                       line_item_tmpl_version.line_item_type%TYPE
           ,cp_ifac_li_conn_code                    line_item_tmpl_version.ifac_li_conn_code%TYPE
        )
        IS
            SELECT litv.object_id
                ,lit.object_code
                ,litv.name
                ,litv.daytime
                ,litv.end_date
            FROM transaction_tmpl_version    ttv
                ,line_item_template          lit
                ,line_item_tmpl_version      litv
            WHERE ttv.object_id = cp_transaction_template_id
                AND ttv.daytime = cp_transaction_template_ver
                AND lit.transaction_template_id = ttv.object_id
                AND litv.object_id = lit.object_id
                AND litv.daytime <= ttv.daytime
                AND NVL(litv.end_date, ttv.daytime + 1) > ttv.daytime
                AND litv.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity
                AND (cp_line_item_type IS NULL OR litv.line_item_type = cp_line_item_type)
                AND ((cp_ifac_li_conn_code IS NULL AND litv.ifac_li_conn_code IS NULL)
                    OR litv.ifac_li_conn_code = cp_ifac_li_conn_code)
            ORDER BY lit.sort_order, lit.object_code;
    BEGIN
        IF p_Rec.Line_Item_Based_Type != ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        WriteRevnLogInterface_P(
            EcDp_Revn_Log.LOG_STATUS_ITEM_INFO,
            'Finding line item template under transaction template ''' || p_transaction_template.object_name || '''.');

        FOR rec IN c_Line_item(
                p_transaction_template.object_id
               ,p_transaction_template.version_date
               ,p_Rec.Line_Item_Type
               ,p_Rec.ifac_li_conn_code) LOOP
            l_lit_info := T_REVN_OBJ_INFO(object_code => rec.object_code,
                object_name => rec.name, object_id => rec.object_id,
                version_date => rec.daytime, version_end_date => rec.end_date);
            EXIT;
        END LOOP;

        RETURN l_lit_info;
    END;


    -----------------------------------------------------------------------
    -- Gets line item template for quantity line interface (cargo
    -- based).
    ----+----------------------------------+-------------------------------
    FUNCTION find_line_item_temp_qty_ca_p(
        p_Rec                              IN OUT NOCOPY IFAC_CARGO_VALUE%ROWTYPE
       ,p_transaction_template             IN OUT NOCOPY T_REVN_OBJ_INFO
       )
    RETURN T_REVN_OBJ_INFO
    IS
        l_lit_info                         T_REVN_OBJ_INFO;

        -- This cursor returns best match non-qty line item under given
        -- transaction template version.
        CURSOR c_line_item(
            cp_transaction_template_id              transaction_template.object_id%TYPE
           ,cp_transaction_template_ver             transaction_tmpl_version.daytime%TYPE
           ,cp_line_item_type                       line_item_tmpl_version.line_item_type%TYPE
           ,cp_ifac_li_conn_code                    line_item_tmpl_version.ifac_li_conn_code%TYPE
        )
        IS
            SELECT litv.object_id
                ,lit.object_code
                ,litv.name
                ,litv.daytime
                ,litv.end_date
            FROM transaction_tmpl_version    ttv
                ,line_item_template          lit
                ,line_item_tmpl_version      litv
            WHERE ttv.object_id = cp_transaction_template_id
                AND ttv.daytime = cp_transaction_template_ver
                AND lit.transaction_template_id = ttv.object_id
                AND litv.object_id = lit.object_id
                AND litv.daytime <= ttv.daytime
                AND NVL(litv.end_date, ttv.daytime + 1) > ttv.daytime
                AND litv.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity
                AND (cp_line_item_type IS NULL OR litv.line_item_type = cp_line_item_type)
                AND ((cp_ifac_li_conn_code IS NULL AND litv.ifac_li_conn_code IS NULL)
                    OR litv.ifac_li_conn_code = cp_ifac_li_conn_code)
            ORDER BY lit.sort_order, lit.object_code;
    BEGIN
        IF p_Rec.Line_Item_Based_Type != ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        WriteRevnLogInterface_P(
            EcDp_Revn_Log.LOG_STATUS_ITEM_INFO,
            'Finding line item template under transaction template ''' || p_transaction_template.object_name || '''.');

        FOR rec IN c_Line_item(
                p_transaction_template.object_id
               ,p_transaction_template.version_date
               ,p_Rec.Line_Item_Type
               ,p_Rec.ifac_LI_CONN_CODE) LOOP
            l_lit_info := T_REVN_OBJ_INFO(object_code => rec.object_code,
                object_name => rec.name, object_id => rec.object_id,
                version_date => rec.daytime, version_end_date => rec.end_date);
            EXIT;
        END LOOP;

        RETURN l_lit_info;
    END;

    -----------------------------------------------------------------------
    -- Gets line item template for non-quantity line interface (period
    -- based).
    ----+----------------------------------+-------------------------------
    FUNCTION find_line_item_template_nq_p(
        p_Rec                              IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
       ,p_transaction_template             IN OUT NOCOPY T_REVN_OBJ_INFO
       )
    RETURN T_REVN_OBJ_INFO
    IS
        l_lit_info                         T_REVN_OBJ_INFO;

        -- This cursor returns best match non-qty line item under given
        -- transaction template version.
        CURSOR c_Line_item(
            cp_transaction_template_id              transaction_template.object_id%TYPE
           ,cp_transaction_template_ver             transaction_tmpl_version.daytime%TYPE
           ,cp_line_item_based_type                 VARCHAR2
           ,cp_line_item_type                       VARCHAR2
           ,cp_ifac_li_conn_code                    line_item_tmpl_version.ifac_li_conn_code%TYPE
           ,cp_unit_price_unit                      VARCHAR2
           ,cp_unit_price                           NUMBER
           ,cp_pricing_value                        NUMBER
           ,cp_percentage_value                     NUMBER
           ,cp_price_object_id                      line_item_tmpl_version.price_object_id%TYPE
        )
        IS
            SELECT litv.object_id
                ,lit.object_code
                ,litv.name
                ,litv.daytime
                ,litv.end_date
            FROM transaction_tmpl_version    ttv
                ,line_item_template          lit
                ,line_item_tmpl_version      litv
            WHERE ttv.object_id = cp_transaction_template_id
                AND ttv.daytime = cp_transaction_template_ver
                AND lit.transaction_template_id = ttv.object_id
                AND litv.object_id = lit.object_id
                AND litv.daytime <= ttv.daytime
                AND NVL(litv.end_date, ttv.daytime + 1) > ttv.daytime
                AND litv.line_item_based_type = cp_line_item_based_type
                AND litv.line_item_type = cp_line_item_type
              --  AND nvl(litv.unit_price_unit , 'X') = nvl(cp_unit_price_unit ,'X')
                --AND (litv.line_item_based_type != ecdp_revn_ft_constants.LI_BTYPE_FREE_UNIT
                --    OR (litv.unit_price_unit = cp_UNIT_PRICE_UNIT AND litv.unit_price = cp_unit_price))
                AND (litv.line_item_based_type != ecdp_revn_ft_constants.LI_BTYPE_FREE_UNIT_PO
                    OR litv.Price_Object_Id = cp_price_object_id)
                --AND (litv.line_item_based_type != ecdp_revn_ft_constants.LI_BTYPE_FIXED_VALUE
                --    OR litv.line_item_value = cp_pricing_value)
                --AND (litv.line_item_based_type NOT IN (ecdp_revn_ft_constants.LI_BTYPE_PERCENTAGE_QTY, ecdp_revn_ft_constants.LI_BTYPE_PERCENTAGE_ALL)
                --    OR litv.percentage_value = cp_percentage_value)
                AND ((cp_ifac_li_conn_code IS NULL AND litv.ifac_li_conn_code IS NULL)
                    OR litv.ifac_li_conn_code = cp_ifac_li_conn_code)
            ORDER BY lit.sort_order, lit.object_code;

        lv2_dist_type VARCHAR2(32);
    BEGIN
        IF p_Rec.Line_Item_Based_Type = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        WriteRevnLogInterface_P(
            EcDp_Revn_Log.LOG_STATUS_ITEM_INFO,
            'Finding line item template under transaction template ''' || p_transaction_template.object_name || '''.');

        FOR rec IN c_Line_item(
                p_transaction_template.object_id
               ,p_transaction_template.version_date
               ,p_Rec.line_item_based_type
               ,p_Rec.line_item_type
               ,p_Rec.ifac_li_conn_code
               ,p_Rec.Unit_Price_Unit
               ,p_Rec.unit_price
               ,p_Rec.pricing_value
               ,p_Rec.percentage_value
               ,p_Rec.li_price_object_id) LOOP
            l_lit_info := T_REVN_OBJ_INFO(object_code => rec.object_code,
                object_name => rec.name, object_id => rec.object_id,
                version_date => rec.daytime, version_end_date => rec.end_date);
            EXIT;
        END LOOP;

        RETURN l_lit_info;
    END;


   -----------------------------------------------------------------------
    -- Gets line item template for non-quantity line interface (period
    -- based).
    ----+----------------------------------+-------------------------------
    FUNCTION find_line_item_temp_nq_ca_p(
        p_Rec                              IN OUT NOCOPY IFAC_CARGO_VALUE%ROWTYPE
       ,p_transaction_template             IN OUT NOCOPY T_REVN_OBJ_INFO
       )
    RETURN T_REVN_OBJ_INFO
    IS
        l_lit_info                         T_REVN_OBJ_INFO;

        -- This cursor returns best match non-qty line item under given
        -- transaction template version.
        CURSOR c_Line_item(
            cp_transaction_template_id              transaction_template.object_id%TYPE
           ,cp_transaction_template_ver             transaction_tmpl_version.daytime%TYPE
           ,cp_line_item_based_type                 VARCHAR2
           ,cp_line_item_type                       VARCHAR2
           ,cp_ifac_li_conn_code                    line_item_tmpl_version.ifac_li_conn_code%TYPE
           ,cp_unit_price_unit                      VARCHAR2
           ,cp_unit_price                           NUMBER
           ,cp_pricing_value                        NUMBER
           ,cp_percentage_value                     NUMBER
           ,cp_price_object_id                      line_item_tmpl_version.price_object_id%TYPE
        )
        IS
            SELECT litv.object_id
                ,lit.object_code
                ,litv.name
                ,litv.daytime
                ,litv.end_date
            FROM transaction_tmpl_version    ttv
                ,line_item_template          lit
                ,line_item_tmpl_version      litv
            WHERE ttv.object_id = cp_transaction_template_id
                AND ttv.daytime = cp_transaction_template_ver
                AND lit.transaction_template_id = ttv.object_id
                AND litv.object_id = lit.object_id
             --   AND nvl(litv.unit_price_unit , 'X') = nvl(cp_unit_price_unit ,'X')
                AND litv.daytime <= ttv.daytime
                AND NVL(litv.end_date, ttv.daytime + 1) > ttv.daytime
                AND litv.line_item_based_type = cp_line_item_based_type
                AND litv.line_item_type = cp_line_item_type
                --AND (litv.line_item_based_type != ecdp_revn_ft_constants.LI_BTYPE_FREE_UNIT_PO
                --    OR litv.Price_Object_Id = cp_price_object_id)
                AND ((cp_ifac_li_conn_code IS NULL AND litv.ifac_li_conn_code IS NULL)
                    OR litv.ifac_li_conn_code = cp_ifac_li_conn_code)
            ORDER BY lit.sort_order, lit.object_code;

        lv2_dist_type VARCHAR2(32);
    BEGIN
        IF p_Rec.Line_Item_Based_Type = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN NULL;
        END IF;

        WriteRevnLogInterface_P(
            EcDp_Revn_Log.LOG_STATUS_ITEM_INFO,
            'Finding line item template under transaction template ''' || p_transaction_template.object_name || '''.');

        FOR rec IN c_Line_item(
                p_transaction_template.object_id
               ,p_transaction_template.version_date
               ,p_Rec.line_item_based_type
               ,p_Rec.line_item_type
               ,p_Rec.ifac_li_conn_code
               ,p_Rec.Unit_Price_Unit
               ,p_Rec.unit_price
               ,p_Rec.pricing_value
               ,p_Rec.percentage_value
               ,p_Rec.li_price_object_id) LOOP
            l_lit_info := T_REVN_OBJ_INFO(object_code => rec.object_code,
                object_name => rec.name, object_id => rec.object_id,
                version_date => rec.daytime, version_end_date => rec.end_date);
            EXIT;
        END LOOP;

        RETURN l_lit_info;
    END;

    -----------------------------------------------------------------------
    -- Gets line item template line interface (period based).
    ----+----------------------------------+-------------------------------
    FUNCTION find_line_item_template_p(
        p_ifac_rec_period                  IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
       ,p_transaction_template             IN OUT NOCOPY T_REVN_OBJ_INFO
       )
    RETURN T_REVN_OBJ_INFO
    IS
    BEGIN
        IF p_ifac_rec_period.LINE_ITEM_BASED_TYPE = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN find_line_item_template_qty_p(p_ifac_rec_period, p_transaction_template);
        ELSE
            RETURN find_line_item_template_nq_p(p_ifac_rec_period, p_transaction_template);
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Gets line item template line interface (Cargo based).
    ----+----------------------------------+-------------------------------
    FUNCTION find_line_item_temp_ca_p(
        p_ifac_rec_cargo                   IN OUT NOCOPY IFAC_CARGO_VALUE%ROWTYPE
       ,p_transaction_template             IN OUT NOCOPY T_REVN_OBJ_INFO
       )
    RETURN T_REVN_OBJ_INFO
    IS
    BEGIN
        IF p_ifac_rec_cargo.LINE_ITEM_BASED_TYPE = ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN find_line_item_temp_qty_ca_p(p_ifac_rec_cargo, p_transaction_template);
        ELSE
            RETURN find_line_item_temp_nq_ca_p(p_ifac_rec_cargo, p_transaction_template);
        END IF;
    END;

----------------------------------------------------------------------------------------------------------------
-- Get or validate document setup. Returns NULL if not found or currently set ds was found invalid.
FUNCTION GetIfacDocDocSetup(prec ifac_document%ROWTYPE
)
RETURN VARCHAR2
IS

  lv2_ret_id VARCHAR2(32) := NULL;

  CURSOR c_contract_doc(cp_contract_id VARCHAR2, cp_contract_doc_id VARCHAR2, cp_daytime DATE) IS
    SELECT cd.object_id
      FROM contract_doc cd, contract_doc_version cdv
     WHERE cdv.object_id = cd.object_id
       AND cdv.daytime <= cp_daytime
       AND nvl(cdv.end_date, cp_daytime + 1) > cp_daytime
       AND cd.contract_id = cp_contract_id
       AND cd.object_id = NVL(cp_contract_doc_id, cd.object_id) -- Contract Doc Is is set if validating value from external system
       AND cdv.erp_document_ind = 'Y'
     ORDER BY cdv.automation_priority;

BEGIN

   FOR rsC IN c_contract_doc(prec.contract_id, prec.contract_doc_id, prec.daytime) LOOP

      lv2_ret_id := rsC.Object_Id;

   END LOOP;

   RETURN lv2_ret_id;

END GetIfacDocDocSetup;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetPeriodReallocBalance(p_contract_id VARCHAR2,
                                 p_prec_doc_key VARCHAR2,
                                 p_daytime DATE
) RETURN NUMBER
IS

CURSOR c_bal(cp_contract_id VARCHAR2, cp_prec_doc_key VARCHAR2, cp_processing_period DATE) IS
  SELECT
  ((
  -- Sum of new qty (transaction level)
  NVL((
      SELECT SUM(cv1.qty1) sumqty
        FROM table(ECdp_revn_ifac_wrapper_period.GetIfacForDocument(cp_contract_id,NULL,cp_processing_period, NULL, NULL)) cv1
       WHERE ecdp_revn_ifac_wrapper.gconst_level_transaction = cv1.interface_level
      ),0)
  ) + - (
  -- Minus invoiced qty
  NVL((

  SELECT sum(cli.qty1) sumqty
    FROM cont_line_item cli
   WHERE cli.transaction_key IN (SELECT transaction_key
                                  FROM cont_transaction ct
                                 WHERE ct.document_key = cp_prec_doc_key
                                   AND ct.reversal_ind = 'N')
     AND cli.line_item_based_type = 'QTY'
  ),0)
  )) Balance
  FROM DUAL;

  ln_balance NUMBER := -1;

BEGIN

  FOR rsBal IN c_bal(p_contract_id, p_prec_doc_key, p_daytime) LOOP

    ln_balance := rsBal.Balance;

  END LOOP;

  RETURN ln_balance;

END GetPeriodReallocBalance;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetIfacRecordPriceObject
-- Description    : Reurns the price object that matches the parameter criterias.
--                  In case of several hits, we return the first object sorted by object_code ASCENDING.
--                  Supports both contract specific and general price objects
-- Preconditions  :
-- Postconditions :
-- Using tables   : product_price, product_price_version
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION GetIfacRecordPriceObject(p_contract_id        VARCHAR2,
                                  p_product_id         VARCHAR2,
                                  p_price_concept_code VARCHAR2,
                                  p_quantity_status    VARCHAR2,
                                  p_price_status       VARCHAR2,
                                  p_daytime            DATE,
                                  p_uom_code           VARCHAR2 DEFAULT NULL
)RETURN VARCHAR2
IS

  CURSOR c_PP(cp_contract_id VARCHAR2, cp_product_id VARCHAR2, cp_price_concept_code VARCHAR2, cp_price_status VARCHAR2, cp_quantity_status VARCHAR2, cp_daytime DATE, cp_uom_code VARCHAR2) IS
    SELECT pp.object_id
      FROM product_price pp, product_price_version ppv
     WHERE pp.object_id = ppv.object_id
       AND ppv.daytime <= cp_daytime
       AND nvl(ppv.end_date, cp_daytime + 1) > cp_daytime
       AND (pp.contract_id = cp_contract_id
        OR EXISTS (
            SELECT 1
              FROM contract_price_setup cps
             WHERE cps.object_id = cp_contract_id
               AND cps.product_price_id = pp.object_id
               AND cps.price_type = 'GENERAL'
               AND cps.daytime <= cp_daytime
               AND nvl(cps.end_date, cp_daytime + 1) > cp_daytime
                 )) -- Support both contract specific and general price objects
       AND pp.product_id = cp_product_id
       AND pp.price_concept_code = cp_price_concept_code
       AND ppv.price_status = cp_price_status
       AND ppv.quantity_status = cp_quantity_status
       AND ppv.uom = nvl(cp_uom_code,ppv.uom)
       AND pp.revn_ind = 'Y'
     ORDER BY pp.object_code; -- In case of several hits, we return the first object sorted by object_code ASCENDING.

  lv2_ret_id product_price.object_code%TYPE := NULL;

BEGIN

  FOR rsPP IN c_pp(p_contract_id, p_product_id, p_price_concept_code, p_price_status, p_quantity_status, p_daytime, p_uom_code) LOOP

    IF lv2_ret_id IS NULL THEN

      lv2_ret_id := rsPP.object_id;

    END IF;

    END LOOP;

  RETURN lv2_ret_id;

END GetIfacRecordPriceObject;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyQTY
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION verifyQTY(
   p_value NUMBER,
   p_uom VARCHAR2,
   p_daytime DATE,
   p_master_uom VARCHAR2 DEFAULT NULL
                     )
RETURN VARCHAR2
--</EC-DOC>
IS
lr_unit ctrl_unit%ROWTYPE;
BEGIN
    -- Return if both Value and Uom is NULL
    IF (p_value IS NULL AND p_uom IS NULL) THEN
        RETURN 'OK';
      END IF;

    -- QTY but no UOM
    IF (p_value IS NULL AND p_uom IS NOT NULL) THEN
        Raise_Application_Error(-20000, 'No quantity given, but uom is specified ' || p_uom );
      END IF;

    -- UOM but no QTY
    IF (p_value IS NOT NULL AND p_uom IS NULL) THEN
        Raise_Application_Error(-20000, 'No UOM given, but value is specified ' || p_value );
          END IF;

    -- UOM not present in the system
    IF (p_uom IS NOT NULL) THEN
         lr_unit := ec_ctrl_unit.row_by_pk(p_uom);
         IF (lr_unit.unit IS NULL) THEN
             Raise_Application_Error(-20000, 'Specified UOM not present in the system ' || p_uom );
      END IF;
     END IF;

    -- UOM in wrong group
    IF (p_master_uom IS NOT NULL) THEN
        IF (NVL(ecdp_unit.GetUOMGroup(lr_unit.unit),'X') <> p_master_uom) THEN
            Raise_Application_Error(-20000, 'Specified UOM not present in the correct UOM group ' || p_uom );
        END IF;
   END IF;

    RETURN 'OK';
END verifyQTY;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyConversion
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION verifyConversion(
   p_value NUMBER,
   p_uom1 VARCHAR2,
   p_uom2 VARCHAR2,
   p_daytime DATE,
   p_master_uom1 VARCHAR2,
   p_master_uom2 VARCHAR2
   )
RETURN VARCHAR2
--</EC-DOC>
IS

lr_uom1 ctrl_unit%ROWTYPE;
lr_uom2 ctrl_unit%ROWTYPE;

BEGIN
    -- QTY but no UOM
    IF (p_value IS NULL AND (p_uom1 IS NOT NULL OR p_uom2 IS NOT NULL)) THEN
        Raise_Application_Error(-20000, 'No quantity given, but uom is specified ' || p_uom1 || ' ' || p_uom2 );
    END IF;

    -- UOM but no QTY
    IF (p_value IS NOT NULL AND (p_uom1 IS NULL OR p_uom2 IS NULL)) THEN
        Raise_Application_Error(-20000, 'UOM not correct, but value is specified ' || p_value );
   END IF;

    -- UOM not present in the system
    IF (p_uom1 IS NOT NULL OR p_uom2 IS NOT NULL) THEN
         lr_uom1 := ec_ctrl_unit.row_by_pk(p_uom1);
         lr_uom2 := ec_ctrl_unit.row_by_pk(p_uom2);
         IF (lr_uom1.unit IS NULL OR lr_uom2.unit IS NULL) THEN
             Raise_Application_Error(-20000, 'Specified UOM not present in the system ' || p_uom1 || ' ' || p_uom2 );
                    END IF;
                  END IF;

    -- UOM1 in wrong group
    IF (lr_uom1.unit IS NOT NULL) THEN
        IF (NVL(ecdp_unit.GetUOMGroup(lr_uom1.unit),'X') <> p_master_uom1) THEN
            Raise_Application_Error(-20000, 'Specified UOM not present in the correct UOM group ' || p_uom1 );
        END IF;
         END IF;

    -- UOM2 in wrong group
    IF (lr_uom2.unit IS NOT NULL) THEN
        IF (NVL(ecdp_unit.GetUOMGroup(lr_uom2.unit),'X') <> p_master_uom2) THEN
            Raise_Application_Error(-20000, 'Specified UOM not present in the correct UOM group ' || p_uom2 );
            END IF;
         END IF;

    RETURN 'OK';
END verifyConversion;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMethodValue
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getMethodValue(p_column VARCHAR2
                        ,p_qty_method VARCHAR2
                        ,p_value NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS
lv2_stmt VARCHAR2(2000);
BEGIN
    lv2_stmt := '';
    IF (p_qty_method = 'REPLACE') THEN
        lv2_stmt := ' ' || p_column || ' = ' || p_value;
    ELSIF (p_qty_method = 'ADD_INCR') THEN
        lv2_stmt := ' ' || p_column || ' = NVL(' || p_column || ',0) + ' || p_value;
    ELSIF (p_qty_method = 'ADD_DECR') THEN
        lv2_stmt := ' ' || p_column || ' = NVL(' || p_column || ',0) - ' || p_value;
   END IF;

    RETURN lv2_stmt;
END getMethodValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TransferSPPrices
-- Description    : Process all SP Prices
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE TransferSPPrices(
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate -- run time
   )
--</EC-DOC>
IS

CURSOR c_new_elements IS
SELECT *
 FROM IFAC_PRICE v_re
 WHERE STATUS IS NULL OR STATUS IN ('NEW', 'UPDATED')
;
lv2_stauts VARCHAR2(200);
BEGIN
   FOR elem IN c_new_elements LOOP
      lv2_stauts := Ecdp_Inbound_Interface.TransferSPPricesRecord(elem, p_user, p_daytime);
      -- TODO: Update status on records transfered
   END LOOP;
END TransferSPPrices;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TransferSPPricesRecord
-- Description    : Process one SP Prices record
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION TransferSPPricesRecord(
   p_Rec       IFAC_PRICE%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate -- run time
   ) RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_inco_term(cp_inco_term VARCHAR2) IS
SELECT
   pc.price_concept_code
FROM
   price_concept pc
WHERE
   pc.incoterm_code = cp_inco_term
;

CURSOR c_mapping_codes(cp_code VARCHAR2) IS
SELECT
   mc.local_code LOCAL_CODE
FROM
   mapping_code mc
WHERE
   mc.local_class_name = 'PRICE_CONCEPT'
   AND mc.external_code = cp_code
;

lv2_contract_id       objects.object_id%TYPE;
lv2_price_concept_id       objects.object_id%TYPE;
lb_pc_found BOOLEAN := false;

price_concept_not_found EXCEPTION;

ltab_price t_PriceTable := t_PriceTable();

lb_process BOOLEAN := false;

lv2_status VARCHAR2(200);
lv2_contract_code VARCHAR2(200);

BEGIN
   --
   -- If contract is not found asume general price
   -- Price concept : First try incoterm then mapping codes and last the code itself
   -- Price element : First try mapping codes if no match try code, remember one price can end up in several records
   --
    ltab_price.extend;
    ltab_price(ltab_price.last) := p_Rec;

    lv2_contract_code := getMappingCode(p_Rec.contract_code, 'CONTRACT');

    IF (lv2_contract_code IS NOT NULL) THEN
        lv2_contract_id := ec_contract.object_id_by_uk(lv2_contract_code);
        IF (lv2_contract_id IS NULL) THEN
             Raise_Application_Error(-20000,'Contract not found.');
        END IF;
    ELSE
        lv2_contract_id := NULL;
    END IF;

    IF (lv2_contract_id IS NULL) THEN -- General Price

       FOR inco IN c_inco_term(p_Rec.price_concept_code) LOOP
          lb_pc_found := true;
          lv2_price_concept_id := inco.price_concept_code;
          lb_process := processGPPE(lv2_price_concept_id, p_Rec, p_user);
          IF (NOT lb_process) THEN
             ltab_price(ltab_price.last).STATUS := 'FAILURE';
             Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
          END IF;
       END LOOP;

       IF (NOT lb_pc_found) THEN
          FOR mapping IN c_mapping_codes(p_Rec.price_concept_code) LOOP
             lv2_price_concept_id := mapping.local_code;
             lb_pc_found := true;
             lb_process := processGPPE(lv2_price_concept_id, p_Rec, p_user);
             IF (NOT lb_process) THEN
                ltab_price(ltab_price.last).STATUS := 'FAILURE';
                Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
             END IF;
          END LOOP;
       END IF;

       IF (NOT lb_pc_found) THEN
          lv2_price_concept_id := p_Rec.price_concept_code;
          IF (lv2_price_concept_id IS NULL) THEN
             ltab_price(ltab_price.last).STATUS := 'FAILURE';
             Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
          END IF;
          lb_process := processGPPE(lv2_price_concept_id, p_Rec, p_user);
          IF (NOT lb_process) THEN
             ltab_price(ltab_price.last).STATUS := 'FAILURE';
             Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
          END IF;
       ELSE
          IF (lv2_price_concept_id IS NULL) THEN
             ltab_price(ltab_price.last).STATUS := 'FAILURE';
             Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
          END IF;
       END IF;

       IF (lv2_price_concept_id IS NULL) THEN
             ltab_price(ltab_price.last).STATUS := 'FAILURE';
             Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
       END IF;

    ELSE -- Contract Price
       FOR inco IN c_inco_term(p_Rec.price_concept_code) LOOP
          lb_pc_found := true;
          lv2_price_concept_id := inco.price_concept_code;
          lb_process := processCPPE(lv2_contract_id, lv2_price_concept_id, p_Rec, p_user);
          IF (NOT lb_process) THEN
             ltab_price(ltab_price.last).STATUS := 'FAILURE';
             Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
          END IF;
       END LOOP;

       IF (NOT lb_pc_found) THEN
          FOR mapping IN c_mapping_codes(p_Rec.price_concept_code) LOOP
             lv2_price_concept_id := mapping.local_code;
             lb_pc_found := true;
             lb_process := processCPPE(lv2_contract_id, lv2_price_concept_id, p_Rec, p_user);
             IF (NOT lb_process) THEN
                ltab_price(ltab_price.last).STATUS := 'FAILURE';
                Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
             END IF;
          END LOOP;
       END IF;

       IF (NOT lb_pc_found) THEN
          lv2_price_concept_id := p_Rec.price_concept_code;
          IF (lv2_price_concept_id IS NULL) THEN
             ltab_price(ltab_price.last).STATUS := 'FAILURE';
             Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
          END IF;
          lb_process := processCPPE(lv2_contract_id, lv2_price_concept_id, p_Rec, p_user);
          IF (NOT lb_process) THEN
             ltab_price(ltab_price.last).STATUS := 'FAILURE';
             Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
          END IF;
       ELSE
          IF (lv2_price_concept_id IS NULL) THEN
             ltab_price(ltab_price.last).STATUS := 'FAILURE';
             Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
          END IF;
       END IF;

       IF (lv2_price_concept_id IS NULL) THEN
             ltab_price(ltab_price.last).STATUS := 'FAILURE';
             Raise_Application_Error(-20000,'Price Concept not found in EC Revenue');
       END IF;
    END IF;

    IF (ltab_price(ltab_price.last).STATUS IS NULL) THEN
       ltab_price(ltab_price.last).STATUS := 'SUCCESS';
    END IF;

   FOR i IN 1..ltab_price.COUNT LOOP
      lv2_status := ltab_price(i).STATUS;
   END LOOP;

   ltab_price.delete;

   RETURN lv2_status;

EXCEPTION
   WHEN price_concept_not_found THEN
      Raise_Application_Error(-20000,'Price concept not found.');
END TransferSPPricesRecord;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : processGPPE
-- Description    : GeneralPrices
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION processGPPE(p_price_concept_id VARCHAR2,
                     p_interface_row IFAC_PRICE%ROWTYPE,
                     p_user VARCHAR2)
RETURN BOOLEAN
IS

CURSOR c_mapping_codes(cp_code VARCHAR2) IS
SELECT
   mc.local_code LOCAL_CODE
FROM
   mapping_code mc
WHERE
   mc.local_class_name = 'PRICE_ELEMENT'
   AND mc.external_code = cp_code
;

CURSOR c_price_struct(cp_currency VARCHAR2, cp_uom VARCHAR2, cp_price_concept_id VARCHAR2, cp_product VARCHAR2) IS
SELECT
   pp.object_id OBJECT_ID,
   ppv.daytime
FROM
   product_price pp
   ,product_price_version ppv
WHERE
   pp.object_id = ppv.object_id
   AND ec_product.object_code(pp.product_id) = cp_product
   AND ppv.uom = cp_uom
   AND pp.price_concept_code = cp_price_concept_id
   AND ec_currency.object_code(ppv.currency_id) = cp_currency
;

CURSOR c_pe(cp_pc_code VARCHAR2, cp_pe_code VARCHAR2) IS
SELECT ppva.object_id, ppva.daytime
FROM
    product_price pp
    ,product_price_value ppva
WHERE
  pp.object_id = ppva.object_id
  AND ppva.price_concept_code = cp_pc_code
  AND ppva.price_element_code = cp_pe_code
;

lb_instantiatied BOOLEAN := false;
lb_pe_found BOOLEAN := false;
lv2_price_element_id objects.object_id%TYPE;
lv2_price_concept_id objects.object_id%TYPE;

wrong_price_concept EXCEPTION;

lv2_product VARCHAR2(200);

BEGIN
   lv2_product := getMappingCode(p_interface_row.product, 'PRODUCT');

   IF lv2_product IS NULL THEN
      lv2_product := p_interface_row.PRODUCT;
   END IF;

   -- Price element : First try mapping codes if no match try code, remember one price can end up in several records, then the code itself
   FOR prcStruct IN c_price_struct(p_interface_row.CURRENCY_CODE, p_interface_row.UOM_CODE, p_price_concept_id, lv2_product) LOOP
      FOR elements IN c_mapping_codes(p_interface_row.PRICE_ELEMENT_CODE) LOOP
         lb_pe_found := true;
         IF (NOT lb_instantiatied) THEN
            Ecdp_Price.InstantiateMth(p_interface_row.DAYTIME , p_user);
            lb_instantiatied := true;
         END IF;
         -- Find the PRICE_ELEMENTS based on mapping codes
         lv2_price_element_id := elements.local_code;
         lv2_price_concept_id := p_interface_row.price_element_code;
         IF (lv2_price_concept_id IS NULL) THEN
            RETURN false;
         END IF;

         FOR pe IN c_pe(p_price_concept_id, elements.local_code) LOOP

            UPDATE product_price_value t SET
               t.adj_price_value = p_interface_row.PRICE_VALUE
            WHERE
               t.object_id = pe.object_id
               AND t.daytime = pe.daytime;
         END LOOP;

      END LOOP;

      IF (NOT lb_pe_found) THEN
         lv2_price_element_id := p_interface_row.PRICE_ELEMENT_CODE;
         lv2_price_concept_id := p_interface_row.price_concept_code;
         IF (lv2_price_concept_id IS NULL) THEN
            RETURN false;
         END IF;
--         Ecdp_Price.InstantiateMth(p_interface_row.DAYTIME , p_user);
-- TODO: Add records
         -- Update PRCL_MTH_VALUE
         FOR pe IN c_pe(p_price_concept_id, p_interface_row.PRICE_ELEMENT_CODE) LOOP
            UPDATE product_price_value t SET
               t.adj_price_value = p_interface_row.PRICE_VALUE
            WHERE
               t.object_id = pe.object_id
               AND t.daytime = pe.daytime;
         END LOOP;
      END IF;

      lb_pe_found := false;

   END LOOP;
   RETURN true;
EXCEPTION
   WHEN wrong_price_concept THEN
      Raise_Application_Error(-20000,'Either wrong price concept or price concept not found.');
END processGPPE;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : processCPPE
-- Description    : ContractPrices
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION processCPPE(p_contract_id VARCHAR2,
                     p_price_concept_id VARCHAR2,
                     p_interface_row IFAC_PRICE%ROWTYPE,
                     p_user VARCHAR2)
RETURN BOOLEAN
--<EC-DOC>
IS

CURSOR c_mapping_codes(cp_code VARCHAR2) IS
SELECT
   mc.local_code LOCAL_CODE
FROM
   mapping_code mc
WHERE
   mc.local_class_name = 'PRICE_ELEMENT'
   AND mc.external_code = cp_code
;

CURSOR c_po(cp_contract_id VARCHAR2, cp_uom_code VARCHAR2, cp_pricing_currency_id VARCHAR2, cp_product_id VARCHAR2,
            cp_pc_code VARCHAR2, cp_pe_code VARCHAR2, cp_daytime DATE) IS
SELECT pp.object_id, pp.product_id, ppva.price_element_code, ppva.price_concept_code, ppva.price_category
FROM product_price pp,
     product_price_version ppv,
     product_price_value ppva
WHERE pp.object_id = ppva.object_id
   AND pp.contract_id = cp_contract_id
   AND ppv.object_id = pp.object_id
   AND ppv.daytime <= cp_daytime
   AND nvl(ppv.end_date, cp_daytime+1) > cp_daytime
   AND ppv.uom = cp_uom_code
   AND ppv.currency_id = cp_pricing_currency_id
   AND pp.product_id = cp_product_id
   AND pp.price_concept_code = cp_pc_code
   AND ppva.price_element_code = cp_pe_code
;

lv2_product_id objects.object_id%TYPE;
lv2_product_code VARCHAR2(200);
lv2_uom1_code VARCHAR2(200);
lv2_currency_id VARCHAR2(200);

ln_count_po NUMBER := 0;
ln_price_value NUMBER;

lv2_po_id VARCHAR2(32);
lv2_pc_code VARCHAR2(32);
lv2_pe_code VARCHAR2(32);
lv2_price_category VARCHAR2(32);

BEGIN
   lv2_product_code := getMappingCode(p_interface_row.product, 'PRODUCT', p_interface_row.DAYTIME);
   lv2_product_id := ec_product.object_id_by_uk(lv2_product_code);

   lv2_uom1_code := getMappingCode(p_interface_row.uom_code, 'UOM', p_interface_row.DAYTIME);
   lv2_currency_id := ec_currency.object_id_by_uk(getMappingCode(p_interface_row.CURRENCY_CODE, 'UOM', p_interface_row.DAYTIME));

   ln_price_value := p_interface_row.price_value;

   -- First try and find price element through mapping codes if not go directly on code
   FOR elements IN c_mapping_codes(p_interface_row.PRICE_ELEMENT_CODE) LOOP
     FOR inst IN c_po(p_contract_id, lv2_uom1_code, lv2_currency_id, lv2_product_id, p_price_concept_id, elements.local_code, p_interface_row.DAYTIME) LOOP

        lv2_po_id := inst.object_id;
        lv2_pc_code := inst.price_concept_code;
        lv2_pe_code := inst.price_element_code;
		lv2_price_category := inst.price_category;

        ln_count_po := ln_count_po + 1;

     END LOOP;
   END LOOP;

   -- No price object with price element from mapping code was found
   IF ln_count_po = 0 THEN
     FOR inst IN c_po(p_contract_id, lv2_uom1_code, lv2_currency_id, lv2_product_id, p_price_concept_id, p_interface_row.PRICE_ELEMENT_CODE, p_interface_row.DAYTIME) LOOP

        lv2_po_id := inst.object_id;
        lv2_pc_code := inst.price_concept_code;
        lv2_pe_code := inst.price_element_code;
        lv2_price_category := inst.price_category;

        ln_count_po := ln_count_po + 1;

     END LOOP;
   END IF;

   -- If no or more than 1 po is found, bail out.
   IF ln_count_po <> 1 THEN
      RETURN false;
   ELSE
      -- Instantiate price value record
      EcDp_Price.InsNewPriceObjectValue(lv2_po_id, lv2_pc_code, lv2_pe_code, p_interface_row.DAYTIME,lv2_price_category);

      -- Set the price
      UPDATE product_price_value ppva SET
          ppva.adj_price_value = ln_price_value
       WHERE ppva.object_id = lv2_po_id
         AND ppva.price_concept_code = lv2_pc_code
         AND ppva.price_element_code = lv2_pe_code
         AND ppva.daytime = p_interface_row.DAYTIME
		 AND ppva.price_category = lv2_price_category;

   END IF;

   RETURN true;

END processCPPE;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TransferQuantities
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE TransferQuantities(
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate -- run time
   )
--</EC-DOC>
IS
CURSOR c_new_qtys IS
SELECT *
 FROM IFAC_QTY v_re
 WHERE STATUS IS NULL OR STATUS IN ('NEW', 'UPDATED')
;

lv2_status VARCHAR2(200);

BEGIN
   FOR qty IN c_new_qtys LOOP
      lv2_status := TransferQuantitiesRecord(qty, p_user, p_daytime);
      -- TODO: Update status on records transfered
   END LOOP;
END TransferQuantities;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TransferQuantitiesRecord
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION TransferQuantitiesRecord(p_Rec     IFAC_QTY%ROWTYPE,
                                  p_user    VARCHAR2,
                                  p_daytime DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate -- run time
                                  ) RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_sis(cp_si_category VARCHAR2, cp_product VARCHAR2, cp_company VARCHAR2, cp_profit_center VARCHAR2, cp_node VARCHAR2, cp_stream_item_code VARCHAR2) IS
SELECT si.object_id stream_item_id, rownum
  FROM stream_item si, stream_item_version siv
 WHERE si.object_id = siv.object_id
   AND siv.daytime <= p_daytime
   AND nvl(siv.end_date, p_daytime+1) > p_daytime
   AND ((ec_stream_category.object_code(siv.stream_item_category_id) =
       cp_si_category AND
       ec_company.object_code(siv.company_id) = cp_company AND ec_product.object_code(ec_stream_item_version.product_id(si.object_id,
                                                                                                                          p_daytime,
                                                                                                                          '<=')) =
       cp_product AND
       ec_field.object_code(siv.field_id) = cp_profit_center AND
       (ecdp_stream_item.getnode(siv.value_point,
                                   si.object_id,
                                   siv.daytime,
                                   'CODE') = cp_node OR cp_node IS NULL) AND
       cp_stream_item_code IS NULL) OR
       si.object_code = cp_stream_item_code)
 ORDER BY rownum DESC;

lv2_si_category VARCHAR2(200);
lv2_product VARCHAR2(200);
lv2_company VARCHAR2(200);
lv2_profit_center VARCHAR2(200);
lv2_node VARCHAR2(200);
lv2_si_code VARCHAR2(200);

ltab_qty t_QtyTable := t_QtyTable();

lv2_qty_volume NUMBER := NULL;
lv2_uom_volume VARCHAR2(200) := NULL;
lv2_qty_mass NUMBER := NULL;
lv2_uom_mass VARCHAR2(200) := NULL;
lv2_qty_energy NUMBER := NULL;
lv2_uom_energy VARCHAR2(200) := NULL;

lv2_master_uom_group VARCHAR2(200) := NULL;
lv2_status VARCHAR2(200);

lv2_uom_object_id VARCHAR2(32);
lv2_uom VARCHAR2(32);

not_unique_stream_item EXCEPTION;

BEGIN

/* LOGIC

Interface

QTY1
UOM1
QTY1
UOM2
QTY1
UOM3

* X Only one UOM per UOM group
* X Use SIs UOM if set and convert, If SIs UOM not set use the one supplied
* X Master UOM group must be present in the interface record
* X SI calc method must not be SP, if SP -> Failure
* X Calc method must be updated, eg. if calc method = FO/SK/EK then OW
* X If UOM group is disabled then do not import values

*/

  -- Implementing "INSTEAD OF" user exit
  IF ue_Inbound_Interface.isTransferQtyRecordUEE = 'TRUE' THEN

   RETURN ue_Inbound_Interface.TransferQuantitiesRecord(p_Rec,p_user,p_daytime);

ELSE
      -- Implementing "PRE" user exit
      IF ue_Inbound_Interface.isTransferQtyRecPreUEE = 'TRUE' THEN
          lv2_status := ue_Inbound_Interface.TransferQuantitiesRecordPre(p_Rec,p_user,p_daytime,lv2_status);
          IF lv2_status ='ERROR' THEN
                  RETURN lv2_status;
          END IF;
      END IF;

      ltab_qty.extend;
      ltab_qty(ltab_qty.last) := p_Rec;
      ltab_qty(ltab_qty.last).STATUS := 'FAILURE';

      -- Do not process if daytime is NULL
      IF (p_Rec.daytime IS NULL) THEN
         Raise_Application_Error(-20000,'Daytime can not be null');
      END IF;

      lv2_si_category := getMappingCode(p_Rec.stream_item_category, 'STREAM_ITEM_CATEGORY', p_Rec.daytime);

      lv2_product := getMappingCode(p_Rec.product ,'PRODUCT',p_Rec.daytime);

      lv2_company := getMappingCode(p_Rec.company, 'COMPANY', p_Rec.daytime);

      lv2_profit_center := getMappingCode(p_Rec.profit_center, 'FIELD', p_Rec.daytime);

      lv2_node := getMappingCode(p_Rec.Node, 'NODE', p_Rec.daytime);

      lv2_si_code := getMappingCode(p_Rec.Stream_Item_Code, 'STREAM_ITEM', p_Rec.daytime);

      IF Upper(Nvl(p_Rec.day_mth,'null')) not in ('D','M') THEN
         Raise_Application_Error(-20000,'Day Month indicator must be "D" or "M"');
      ELSIF Upper(p_Rec.day_mth) = 'M' and p_Rec.daytime <> Trunc(p_Rec.daytime,'MM') THEN
         Raise_Application_Error(-20000,'Monthly numbers must be on the first of the month');
      END IF;

      -- UOM1
      lv2_uom_object_id := getMappingCode(p_Rec.Uom1_Code, 'UOM', p_Rec.DAYTIME);
      lv2_uom := lv2_uom_object_id;
      IF (lv2_uom IS NULL AND ltab_qty(ltab_qty.last).Uom1_Code IS NOT NULL) THEN
         Raise_Application_Error(-20000,'UOM code not valid.');
      ELSE
         ltab_qty(ltab_qty.last).Uom1_Code := lv2_uom;
      END IF;

      -- UOM2
      lv2_uom_object_id := getMappingCode(p_Rec.Uom2_Code, 'UOM', p_Rec.DAYTIME);
      lv2_uom := lv2_uom_object_id;
      IF (lv2_uom_object_id IS NULL) THEN
         lv2_uom := getMappingCode(p_Rec.Uom2_Code, 'UOM', p_Rec.DAYTIME);
      END IF;

      IF (lv2_uom IS NULL AND ltab_qty(ltab_qty.last).Uom2_Code IS NOT NULL) THEN
         Raise_Application_Error(-20000,'UOM code not valid.');
      ELSE
         ltab_qty(ltab_qty.last).Uom2_Code := lv2_uom;
      END IF;

      -- UOM3
      lv2_uom_object_id := getMappingCode(p_Rec.Uom3_Code, 'UOM', p_Rec.DAYTIME);
      lv2_uom := lv2_uom_object_id;
      IF (lv2_uom_object_id IS NULL) THEN
         lv2_uom := getMappingCode(p_Rec.Uom3_Code, 'UOM', p_Rec.DAYTIME);
      END IF;

      IF (lv2_uom IS NULL AND ltab_qty(ltab_qty.last).Uom3_Code IS NOT NULL) THEN
         Raise_Application_Error(-20000,'UOM code not valid.');
      ELSE
         ltab_qty(ltab_qty.last).Uom3_Code := lv2_uom;
      END IF;

      getQty_P('M', lv2_qty_mass, lv2_uom_mass, ltab_qty);
      getQty_P('V', lv2_qty_volume, lv2_uom_volume, ltab_qty);
      getQty_P('E', lv2_qty_energy, lv2_uom_energy, ltab_qty);

      FOR sis IN c_sis(lv2_si_category, lv2_product, lv2_company, lv2_profit_center,lv2_node,lv2_si_code) LOOP

      IF sis.rownum > 1 THEN
         Raise not_unique_stream_item;
      END IF;
         -- Stream Item update
         lv2_master_uom_group := ec_stream_item_version.master_uom_group(sis.stream_item_id, p_Rec.daytime, '<=');

         IF (lv2_master_uom_group = 'M' AND lv2_qty_mass IS NULL) THEN
            Raise_Application_Error(-20000,'Master UOM is Mass and no mass quantity is supplied');
         ELSIF (lv2_master_uom_group = 'M' AND ec_stream_item_version.use_mass_ind(sis.stream_item_id, p_Rec.daytime, '<=') <> 'Y') THEN
            Raise_Application_Error(-20000,'Master UOM is Mass and mass is not enabled in Revenue');
         END IF;

         IF (lv2_master_uom_group = 'V' AND lv2_qty_volume IS NULL) THEN
            Raise_Application_Error(-20000,'Master UOM is Volume and no volume quantity is supplied');
         ELSIF (lv2_master_uom_group = 'V' AND ec_stream_item_version.use_volume_ind(sis.stream_item_id, p_Rec.daytime, '<=') <> 'Y') THEN
            Raise_Application_Error(-20000,'Master UOM is Volume and volume is not enabled in Revenue');
         END IF;

         IF (lv2_master_uom_group = 'E' AND lv2_qty_energy IS NULL) THEN
            Raise_Application_Error(-20000,'Master UOM is Energy and no energy quantity is supplied');
         ELSIF (lv2_master_uom_group = 'E' AND ec_stream_item_version.use_energy_ind(sis.stream_item_id, p_Rec.daytime, '<=') <> 'Y') THEN
            Raise_Application_Error(-20000,'Master UOM is Energy and energy is not enabled in Revenue');
         END IF;

         ltab_qty(ltab_qty.last).STATUS := 'SUCCESS';
         IF (p_Rec.day_mth = 'D') THEN
            UpdAddInterfaceDayValue('FINAL'
                                   ,p_Rec.daytime
                                   ,sis.STREAM_ITEM_ID
                                   ,'REPLACE'
                                   ,lv2_qty_volume
                                   ,lv2_uom_volume
                                   ,lv2_qty_mass
                                   ,lv2_uom_mass
                                   ,lv2_qty_energy
                                   ,lv2_uom_energy
                                   ,NULL -- X1
                                   ,NULL -- X1
                                   ,NULL -- X2
                                   ,NULL -- X2
                                   ,NULL -- X3
                                   ,NULL -- X3
                                   ,p_user
                                 );
         ELSIF (p_Rec.day_mth = 'M') THEN
            UpdAddInterfaceMthValue('FINAL'
                                   ,p_Rec.daytime
                                   ,sis.STREAM_ITEM_ID
                                   ,'REPLACE'
                                   ,lv2_qty_volume
                                   ,lv2_uom_volume
                                   ,lv2_qty_mass
                                   ,lv2_uom_mass
                                   ,lv2_qty_energy
                                   ,lv2_uom_energy
                                   ,NULL -- X1
                                   ,NULL -- X1
                                   ,NULL -- X2
                                   ,NULL -- X2
                                   ,NULL -- X3
                                   ,NULL -- X3
                                   ,p_user
                                 );
         END IF;

      END LOOP; -- StreamItems

      IF (ltab_qty(ltab_qty.last).STATUS = 'FAILURE') THEN
         Raise_Application_Error(-20000,'Record can not be updated due to incorrect codes');
      END IF;

     NULL;

  FOR i IN 1..ltab_qty.COUNT LOOP

     lv2_status := ltab_qty(i).STATUS;

  END LOOP;

   ltab_qty.delete;

  -- Implementing "POST" user exit
  IF ue_Inbound_Interface.isTransferQtyRecPostUEE='TRUE' THEN
        lv2_status := ue_Inbound_Interface.TransferQuantitiesRecordPost(p_Rec,p_user,p_daytime,lv2_status);
   END IF;

   RETURN lv2_status;

END IF; -- Is "INSTEAD OF" user exit enabled?


EXCEPTION
   WHEN not_unique_stream_item THEN
      Raise_Application_Error(-20000,'Stream item identifier not unique');
END TransferQuantitiesRecord;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : UpdAddInterfaceDayValue
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
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
   p_density_volume_uom           VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

CURSOR c_daysiv IS
SELECT *
  FROM stim_day_value
 WHERE object_id = p_stream_item_id
   AND daytime = p_date;

lv2_sql VARCHAR2(4000);

BEGIN
     FOR lrecday_siv IN c_daysiv LOOP
			-- Using NA because Calc method on object will never be SP
            IF (nvl(lrecday_siv.calc_method,'NA') = 'SP') THEN
               Raise_Application_Error(-20000,'Can not update SP calc method');
            END IF;

            lv2_sql := 'UPDATE stim_day_value SET status = ''' || p_status || '''';

            IF (p_uom_volume is not null) AND (p_qty_volume is not null) THEN
              lrecday_siv.net_volume_value := Ecdp_Unit.convertValue(p_qty_volume, p_uom_volume, lrecday_siv.volume_uom_code, p_date);
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_volume_value', p_qty_method, lrecday_siv.net_volume_value) || ', volume_uom_code = ''' || lrecday_siv.volume_uom_code || '''';
            END IF;

            IF (p_uom_mass is not null) AND (p_qty_mass is not null) THEN
              lrecday_siv.net_mass_value := Ecdp_Unit.convertValue(p_qty_mass, p_uom_mass, lrecday_siv.mass_uom_code, p_date);
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_mass_value', p_qty_method, lrecday_siv.net_mass_value) || ', mass_uom_code = ''' || lrecday_siv.mass_uom_code || '''';
            END IF;

            IF (p_uom_energy is not null) AND (p_qty_energy is not null) THEN
              lrecday_siv.net_energy_value := Ecdp_Unit.convertValue(p_qty_energy, p_uom_energy, lrecday_siv.energy_uom_code, p_date);
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_energy_value', p_qty_method, lrecday_siv.net_energy_value) || ', energy_uom_code = ''' || lrecday_siv.energy_uom_code || '''';
            END IF;

            IF (p_uom_x1 is not null) AND (p_qty_x1 is not null) THEN
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_extra1_value', p_qty_method, p_qty_x1) || ', extra1_uom_code = ''' || p_uom_x1 || '''';
            END IF;
            IF (p_uom_x2 is not null) AND (p_qty_x2 is not null) THEN
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_extra2_value', p_qty_method, p_qty_x2) || ', extra2_uom_code = ''' || p_uom_x2 || '''';
            END IF;
            IF (p_uom_x3 is not null) AND (p_qty_x3 is not null) THEN
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_extra3_value', p_qty_method, p_qty_x3) || ', extra3_uom_code = ''' || p_uom_x3 || '''';
            END IF;

            IF (p_gcv IS NOT NULL) THEN
              lv2_sql := lv2_sql || ' , gcv = ' || p_gcv || ', gcv_energy_uom = ''' || p_gcv_energy_uom || ''', gcv_volume_uom = ''' || p_gcv_volume_uom || '''';
            END IF;

            IF (p_density IS NOT NULL) THEN
              lv2_sql := lv2_sql || ' , density = ' || p_density || ', density_mass_uom = ''' || p_density_mass_uom || ''', density_volume_uom = ''' || p_density_volume_uom || '''';
            END IF;

            IF (p_mcv IS NOT NULL) THEN
              lv2_sql := lv2_sql || ' , mcv = ' || p_mcv || ', mcv_energy_uom = ''' || p_mcv_energy_uom || ''', mcv_mass_uom = ''' || p_mcv_mass_uom || '''';
            END IF;

            lv2_sql := lv2_sql || ' ,last_updated_by = ''' || p_user || '''';
            lv2_sql := lv2_sql || ' WHERE object_id = ''' || p_stream_item_id || '''';
            lv2_sql := lv2_sql || ' AND daytime = to_date('''|| to_char(p_date,'YYYY-MM-DD"T"HH24:MI:SS') || ''',''YYYY-MM-DD"T"HH24:MI:SS'') ';

            -- Execute the Statement
            execute immediate lv2_sql;

             INSERT INTO stim_cascade_asynch
                    (object_id
                   , period
                   , daytime
                   , BULK_CASCADE_IND) values (
                     p_stream_item_id
                    ,'DAY'
                    ,p_date
                    ,'Y');
     END LOOP;

END UpdAddInterfaceDayValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : UpdAddInterfaceMthValue
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
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
   p_density_volume_uom           VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

CURSOR c_mthsiv IS
SELECT *
FROM stim_mth_value
WHERE object_id = p_stream_item_id
  AND daytime = p_date;

lv2_sql VARCHAR2(4000);

BEGIN
     FOR lrecmth_siv IN c_mthsiv LOOP
			-- Using NA because Calc method on object will never be SP
            IF (nvl(lrecmth_siv.calc_method,'NA') = 'SP') THEN
               Raise_Application_Error(-20000,'Can not update SP calc method');
            END IF;

            lv2_sql := 'UPDATE stim_mth_value SET status = ''' || p_status || '''';

            IF (p_uom_volume is not null) AND (p_qty_volume is not null) THEN
              lrecmth_siv.net_volume_value := Ecdp_Unit.convertValue(p_qty_volume, p_uom_volume, lrecmth_siv.volume_uom_code, p_date);
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_volume_value', p_qty_method, lrecmth_siv.net_volume_value) || ', volume_uom_code = ''' || lrecmth_siv.volume_uom_code || '''';
            END IF;

            IF (p_uom_mass is not null) AND (p_qty_mass is not null) THEN
              lrecmth_siv.net_mass_value := Ecdp_Unit.convertValue(p_qty_mass, p_uom_mass, lrecmth_siv.mass_uom_code, p_date);
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_mass_value', p_qty_method, lrecmth_siv.net_mass_value) || ', mass_uom_code = ''' || lrecmth_siv.mass_uom_code || '''';
            END IF;

            IF (p_uom_energy is not null) AND (p_qty_energy is not null) THEN
              lrecmth_siv.net_energy_value := Ecdp_Unit.convertValue(p_qty_energy, p_uom_energy, lrecmth_siv.energy_uom_code, p_date);
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_energy_value', p_qty_method, lrecmth_siv.net_energy_value) || ', energy_uom_code = ''' || lrecmth_siv.energy_uom_code || '''';
            END IF;

            IF (p_uom_x1 is not null) AND (p_qty_x1 is not null) THEN
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_extra1_value', p_qty_method, p_qty_x1) || ', extra1_uom_code = ''' || p_uom_x1 || '''';
            END IF;
            IF (p_uom_x2 is not null) AND (p_qty_x2 is not null) THEN
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_extra2_value', p_qty_method, p_qty_x2) || ', extra2_uom_code = ''' || p_uom_x2 || '''';
            END IF;
            IF (p_uom_x3 is not null) AND (p_qty_x3 is not null) THEN
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_extra3_value', p_qty_method, p_qty_x3) || ', extra3_uom_code = ''' || p_uom_x3 || '''';
            END IF;

            IF (p_gcv IS NOT NULL) THEN
              lv2_sql := lv2_sql || ' , gcv = ' || p_gcv || ', gcv_energy_uom = ''' || p_gcv_energy_uom || ''', gcv_volume_uom = ''' || p_gcv_volume_uom || '''';
            END IF;

            IF (p_density IS NOT NULL) THEN
              lv2_sql := lv2_sql || ' , density = ' || p_density || ', density_mass_uom = ''' || p_density_mass_uom || ''', density_volume_uom = ''' || p_density_volume_uom || '''';
            END IF;

            IF (p_mcv IS NOT NULL) THEN
              lv2_sql := lv2_sql || ' , mcv = ' || p_mcv || ', mcv_energy_uom = ''' || p_mcv_energy_uom || ''', mcv_mass_uom = ''' || p_mcv_mass_uom || '''';
            END IF;

            IF (p_booking_period IS NOT NULL) THEN
              lv2_sql := lv2_sql || ' , booking_period = to_date('''|| to_char(p_booking_period,'YYYY-MM-DD"T"HH24:MI:SS') || ''',''YYYY-MM-DD"T"HH24:MI:SS'') ';
            END IF;

            IF (p_reporting_period IS NOT NULL) THEN
              lv2_sql := lv2_sql || ' , reporting_period = to_date('''|| to_char(p_reporting_period,'YYYY-MM-DD"T"HH24:MI:SS') || ''',''YYYY-MM-DD"T"HH24:MI:SS'') ';
            END IF;

            lv2_sql := lv2_sql || ' ,last_updated_by = ''' || p_user || '''';
            lv2_sql := lv2_sql || ' WHERE object_id = ''' || p_stream_item_id || '''';
            lv2_sql := lv2_sql || ' AND daytime = to_date('''|| to_char(p_date,'YYYY-MM-DD"T"HH24:MI:SS') || ''',''YYYY-MM-DD"T"HH24:MI:SS'') ';

            -- Execute the Statement
            execute immediate lv2_sql;

             INSERT INTO stim_cascade_asynch
                    (object_id
                   , period
                   , daytime
                   , BULK_CASCADE_IND) values (
                     p_stream_item_id
                    ,'MTH'
                    ,p_date
                    ,'Y');
     END LOOP;

END UpdAddInterfaceMthValue;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMappingCode
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getMappingCode(
   p_code  VARCHAR2,
   p_class VARCHAR2,
   p_daytime DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate,
   p_system VARCHAR2 default null
   )
RETURN VARCHAR2
--</EC-DOC>
IS

/*
MAPPING_NO          NUMBER
DAYTIME             DATE
NAME                VARCHAR2(240)  Y
LOCAL_CLASS_NAME    VARCHAR2(24)   Y
LOCAL_CODE          VARCHAR2(32)   Y
EXTERNAL_SYSTEM     VARCHAR2(240)  Y
EXTERNAL_CLASS_NAME VARCHAR2(240)  Y
EXTERNAL_CODE       VARCHAR2(240)  Y
*/

CURSOR c_mapping_codes IS
SELECT
   mc.local_code
FROM mapping_code mc
WHERE
   mc.local_class_name = p_class
   AND mc.local_class_name = NVL(mc.external_class_name, mc.local_class_name)
   AND mc.external_code = p_code
   AND mc.daytime <= p_daytime
   and mc.external_system = nvl(p_system,mc.external_system)
;

lv2_code VARCHAR2(200);
BEGIN
   IF (p_code IS NULL) THEN
       RETURN NULL;
   END IF;
   lv2_code := p_code;

   FOR codes IN c_mapping_codes LOOP
      lv2_code := codes.local_code;
   END LOOP;

   RETURN lv2_code;
END getMappingCode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : ImportSAPReturnStatus
-- Description    : Moves documents to level 'BOOKED'
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ImportSAPReturnStatus (
   p_record_id                   IN VARCHAR2 DEFAULT NULL,
   p_invoice_no                  IN VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

  CURSOR c_document(c_document_no VARCHAR2) IS
  SELECT object_id, document_key
  FROM   cont_document d
  WHERE  document_key = c_document_no
  AND    document_level_code = 'TRANSFER';

BEGIN
   -- At least for now the approach here is simple
   -- Only care about record_id = COMP (Completed)
   -- Take the starvol_invoice_no (Starvol Document Number) and check if document_level = 'TRANSFER'
   -- In that case move it to the next level BOOKED.

   IF p_record_id = 'COMP' THEN

     FOR curDoc IN c_document(p_invoice_no) LOOP

        UPDATE cont_document
        SET SET_TO_NEXT_IND = 'Y'
        WHERE object_id = curDoc.object_id
        AND   document_key = curDoc.document_key;

     END LOOP;

   END IF;

END ImportSAPReturnStatus;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ImportVOqty
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ImportVOqty(
    p_status                    VARCHAR2, -- 1, FINAL / ACCRUAL
    p_data_type                 VARCHAR2, -- 2 D / M
    p_qty_method                VARCHAR2, -- 3 ADD_INCR / REPLACE / ADD_DECR
    p_daytime                   VARCHAR2, -- 4
    p_booking_period            VARCHAR2, -- 5
    p_reporting_period          VARCHAR2, -- 6
    p_stream_item_code          VARCHAR2, -- 7
    p_qty_volume                NUMBER, -- 8
    p_uom_volume                VARCHAR2, -- 9
    p_qty_mass                  NUMBER, -- 10
    p_uom_mass                  VARCHAR2, -- 11
    p_qty_energy                NUMBER, -- 12
    p_uom_energy                VARCHAR2, -- 13
    p_extra1_qty                NUMBER, -- 14
    p_extra1_uom                VARCHAR2, -- 15
    p_extra2_qty                NUMBER, -- 16
    p_extra2_uom                VARCHAR2, -- 17
    p_extra3_qty                NUMBER, -- 18
    p_extra3_uom                VARCHAR2, -- 19
    p_gcv                       NUMBER, -- 20
    p_gcv_energy_uom            VARCHAR2, -- 21
    p_gcv_volume_uom            VARCHAR2, -- 22
    p_mcv                       NUMBER, -- 23
    p_mcv_energy_uom            VARCHAR2, -- 24
    p_mcv_mass_uom              VARCHAR2, -- 25
    p_density                   NUMBER, -- 26
    p_density_mass_uom          VARCHAR2, -- 27
    p_density_volume_uom        VARCHAR2, -- 28
    p_user                      VARCHAR2 DEFAULT 'upload', -- 29
    p_forecast_code             VARCHAR2 DEFAULT NULL -- 30
   )
--</EC-DOC>
IS
lv2_si_object_id VARCHAR2(32);
lv2_forecast_id VARCHAR2(32);
ld_daytime DATE;
ld_booking_period DATE := NULL;
ld_reporting_period DATE := NULL;
BEGIN
    -- Status Not correct
    IF (p_status NOT IN ('FINAL','ACCRUAL')) THEN
        Raise_Application_Error(-20000, 'Status not supplied or incorrect (FINAL / ACCRUAL)');
    END IF;

    -- Data Type Not correct
    IF (p_data_type NOT IN ('D','M','FM')) THEN
        Raise_Application_Error(-20000, 'Data type not supplied or incorrect (D / M / FM)');
    END IF;

    -- Daytime in wrong format
    ld_daytime := to_date(p_daytime, 'DD.MM.YYYY');
    IF (ld_daytime IS NULL) THEN
        Raise_Application_Error(-20000, 'Daytime wrong ' || p_daytime);
    ELSE
        IF (( p_data_type = 'M' OR p_data_type = 'FM' ) AND Trunc(ld_daytime,'MM') <> to_date(p_daytime, 'DD.MM.YYYY'))  THEN
            Raise_Application_Error(-20000, 'Daytime wrong for monthly number' || p_daytime);
        END IF;
    END IF;

    -- Stream Item CODE not found
    lv2_si_object_id := ec_stream_item.object_id_by_uk(p_stream_item_code);
    IF (lv2_si_object_id IS NULL) THEN
        Raise_Application_Error(-20000, 'Stream Item not found ' || p_stream_item_code);
    END IF;


    -- Booking period wrong
    IF (p_booking_period IS NOT NULL) THEN
        ld_booking_period := to_date(p_booking_period, 'DD.MM.YYYY');
        IF (ld_booking_period IS NULL) THEN
            Raise_Application_Error(-20000, 'Booking period wrong ' || p_booking_period);
        END IF;
    END IF;

    -- Reporting period wrong
    IF (p_reporting_period IS NOT NULL) THEN
        ld_reporting_period := to_date(p_reporting_period, 'DD.MM.YYYY');
        IF (ld_reporting_period IS NULL) THEN
            Raise_Application_Error(-20000, 'Reporting period wrong ' || p_reporting_period);
        END IF;
    END IF;

    -- QTY Method not correct
    IF (p_qty_method NOT IN ('ADD_INCR','REPLACE','ADD_DECR')) THEN
        Raise_Application_Error(-20000, 'QTY Method is not in (ADD_INCR / REPLACE / ADD_DECR) : ' || p_qty_method);
    END IF;

    -- Volume verification
    IF (verifyQTY(p_qty_volume, p_uom_volume, ld_daytime, 'V') <> 'OK') THEN
        Raise_Application_Error(-20000, 'Volume wrong');
    END IF;

    -- Mass verification
    IF (verifyQTY(p_qty_mass, p_uom_mass, ld_daytime, 'M') <> 'OK') THEN
        Raise_Application_Error(-20000, 'Mass wrong');
    END IF;

    -- Energy verification
    IF (verifyQTY(p_qty_energy, p_uom_energy, ld_daytime, 'E') <> 'OK') THEN
        Raise_Application_Error(-20000, 'Energy wrong');
    END IF;

    -- EXTRA1 verification
    IF (verifyQTY(p_extra1_qty, p_extra1_uom, ld_daytime) <> 'OK') THEN
        Raise_Application_Error(-20000, 'Extra 1 wrong');
    END IF;

    -- EXTRA2 verification
    IF (verifyQTY(p_extra2_qty, p_extra2_uom, ld_daytime) <> 'OK') THEN
        Raise_Application_Error(-20000, 'Extra 2 wrong');
    END IF;

    -- EXTRA3 verification
    IF (verifyQTY(p_extra3_qty, p_extra3_uom, ld_daytime) <> 'OK') THEN
        Raise_Application_Error(-20000, 'Extra 3 wrong');
    END IF;

    -- GCV verification
    IF (verifyConversion(p_gcv, p_gcv_energy_uom, p_gcv_volume_uom, ld_daytime, 'E', 'V') <> 'OK') THEN
        Raise_Application_Error(-20000, 'GCV wrong');
    END IF;

    -- Density verification
    IF (verifyConversion(p_density, p_density_mass_uom, p_density_volume_uom, ld_daytime, 'M', 'V') <> 'OK') THEN
        Raise_Application_Error(-20000, 'Density wrong');
    END IF;

    -- MCV verification
    IF (verifyConversion(p_mcv, p_mcv_energy_uom, p_mcv_mass_uom, ld_daytime, 'E', 'M') <> 'OK') THEN
        Raise_Application_Error(-20000, 'Density wrong');
    END IF;

    IF (p_data_type = 'D') THEN
        UpdAddInterfaceDayValue(p_status
                               ,ld_daytime
                               ,lv2_si_object_id
                               ,p_qty_method
                               ,p_qty_volume
                               ,p_uom_volume
                               ,p_qty_mass
                               ,p_uom_mass
                               ,p_qty_energy
                               ,p_uom_energy
                               ,p_extra1_qty
                               ,p_extra1_uom
                               ,p_extra2_qty
                               ,p_extra2_uom
                               ,p_extra3_qty
                               ,p_extra3_uom
                               ,p_user
                               ,ld_booking_period
                               ,ld_reporting_period
                               ,p_gcv
                               ,p_gcv_energy_uom
                               ,p_gcv_volume_uom
                               ,p_mcv
                               ,p_mcv_energy_uom
                               ,p_mcv_mass_uom
                               ,p_density
                               ,p_density_mass_uom
                               ,p_density_volume_uom
                               );
    ELSIF (P_data_type = 'M') THEN
        UpdAddInterfaceMthValue(p_status
                               ,ld_daytime
                               ,lv2_si_object_id
                               ,p_qty_method
                               ,p_qty_volume
                               ,p_uom_volume
                               ,p_qty_mass
                               ,p_uom_mass
                               ,p_qty_energy
                               ,p_uom_energy
                               ,p_extra1_qty
                               ,p_extra1_uom
                               ,p_extra2_qty
                               ,p_extra2_uom
                               ,p_extra3_qty
                               ,p_extra3_uom
                               ,p_user
                               ,ld_booking_period
                               ,ld_reporting_period
                               ,p_gcv
                               ,p_gcv_energy_uom
                               ,p_gcv_volume_uom
                               ,p_mcv
                               ,p_mcv_energy_uom
                               ,p_mcv_mass_uom
                               ,p_density
                               ,p_density_mass_uom
                               ,p_density_volume_uom
                               );

        ELSIF (P_data_type = 'FM') THEN -- Forecast
              lv2_forecast_id := ec_forecast.object_id_by_uk('FORECAST',p_forecast_code);
                IF (lv2_forecast_id IS NULL) THEN
                    Raise_Application_Error(-20000, 'Forecast case not Found : ' || p_forecast_code);
                END IF;

                UpdAddInterfaceFcstMthValue(lv2_forecast_id
                                       ,p_status
                                       ,ld_daytime
                                       ,lv2_si_object_id
                                       ,p_qty_method
                                       ,p_qty_volume
                                       ,p_uom_volume
                                       ,p_qty_mass
                                       ,p_uom_mass
                                       ,p_qty_energy
                                       ,p_uom_energy
                                       ,p_extra1_qty
                                       ,p_extra1_uom
                                       ,p_extra2_qty
                                       ,p_extra2_uom
                                       ,p_extra3_qty
                                       ,p_extra3_uom
                                       ,p_user
                                       ,ld_booking_period
                                       ,ld_reporting_period
                                       ,p_gcv
                                       ,p_gcv_energy_uom
                                       ,p_gcv_volume_uom
                                       ,p_mcv
                                       ,p_mcv_energy_uom
                                       ,p_mcv_mass_uom
                                       ,p_density
                                       ,p_density_mass_uom
                                       ,p_density_volume_uom
                                       );


        END IF;

END ImportVOqty;





--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : UpdAddInterfaceFcstMthValue
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
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
   p_density_volume_uom           VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

CURSOR c_mthsiv IS
SELECT *
FROM stim_fcst_mth_value
WHERE object_id = p_stream_item_id
  AND forecast_id = p_forecast_id
  AND daytime = p_date;

lv2_sql VARCHAR2(4000);

BEGIN
/**
 IGNORE UPLOAD INTO ACTUAL MONTHS for YTM cases
*/

     FOR lrecmth_siv IN c_mthsiv LOOP
			-- Using NA because Calc method on object will never be SP
            IF (nvl(lrecmth_siv.calc_method,'NA') = 'SP') THEN
               Raise_Application_Error(-20000,'Can not update SP calc method');
            END IF;

            lv2_sql := 'UPDATE stim_fcst_mth_value SET status = ''' || p_status || '''';

            IF (p_uom_volume is not null) AND (p_qty_volume is not null) THEN
              lrecmth_siv.net_volume_value := Ecdp_Unit.convertValue(p_qty_volume, p_uom_volume, lrecmth_siv.volume_uom_code, p_date);
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_volume_value', p_qty_method, lrecmth_siv.net_volume_value) || ', volume_uom_code = ''' || lrecmth_siv.volume_uom_code || '''';
            END IF;

            IF (p_uom_mass is not null) AND (p_qty_mass is not null) THEN
              lrecmth_siv.net_mass_value := Ecdp_Unit.convertValue(p_qty_mass, p_uom_mass, lrecmth_siv.mass_uom_code, p_date);
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_mass_value', p_qty_method, lrecmth_siv.net_mass_value) || ', mass_uom_code = ''' || lrecmth_siv.mass_uom_code || '''';
            END IF;

            IF (p_uom_energy is not null) AND (p_qty_energy is not null) THEN
              lrecmth_siv.net_energy_value := Ecdp_Unit.convertValue(p_qty_energy, p_uom_energy, lrecmth_siv.energy_uom_code, p_date);
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_energy_value', p_qty_method, lrecmth_siv.net_energy_value) || ', energy_uom_code = ''' || lrecmth_siv.energy_uom_code || '''';
            END IF;

            IF (p_uom_x1 is not null) AND (p_qty_x1 is not null) THEN
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_extra1_value', p_qty_method, p_qty_x1) || ', extra1_uom_code = ''' || p_uom_x1 || '''';
            END IF;
            IF (p_uom_x2 is not null) AND (p_qty_x2 is not null) THEN
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_extra2_value', p_qty_method, p_qty_x2) || ', extra2_uom_code = ''' || p_uom_x2 || '''';
            END IF;
            IF (p_uom_x3 is not null) AND (p_qty_x3 is not null) THEN
              lv2_sql := lv2_sql || ' , ' || getMethodValue('net_extra3_value', p_qty_method, p_qty_x3) || ', extra3_uom_code = ''' || p_uom_x3 || '''';
            END IF;

            IF (p_gcv IS NOT NULL) THEN
              lv2_sql := lv2_sql || ' , gcv = ' || p_gcv || ', gcv_energy_uom = ''' || p_gcv_energy_uom || ''', gcv_volume_uom = ''' || p_gcv_volume_uom || '''';
            END IF;

            IF (p_density IS NOT NULL) THEN
              lv2_sql := lv2_sql || ' , density = ' || p_density || ', density_mass_uom = ''' || p_density_mass_uom || ''', density_volume_uom = ''' || p_density_volume_uom || '''';
            END IF;

            IF (p_mcv IS NOT NULL) THEN
              lv2_sql := lv2_sql || ' , mcv = ' || p_mcv || ', mcv_energy_uom = ''' || p_mcv_energy_uom || ''', mcv_mass_uom = ''' || p_mcv_mass_uom || '''';
            END IF;

            lv2_sql := lv2_sql || ' ,last_updated_by = ''' || p_user || '''';
            lv2_sql := lv2_sql || ' WHERE object_id = ''' || p_stream_item_id || '''';
            lv2_sql := lv2_sql || ' AND forecast_id = ''' || p_forecast_id || '''';
            lv2_sql := lv2_sql || ' AND daytime = to_date('''|| to_char(p_date,'YYYY-MM-DD"T"HH24:MI:SS') || ''',''YYYY-MM-DD"T"HH24:MI:SS'') ';

            -- Execute the Statement
            execute immediate lv2_sql;

             INSERT INTO stim_cascade (object_id, period, daytime, forecast_id, last_updated_by) VALUES
                 (p_stream_item_id, 'FCST_MTH', p_date, p_forecast_id, 'INTERNAL');

     END LOOP;

END UpdAddInterfaceFcstMthValue;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetNextPeriodAllocNo
-- Description    : Returns the next alloc_no for a given ifac_sales_qty record.
--                  Will not return a alloc_no if the main key ids have no valid value.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION GetNextPeriodAllocNo (
         p_Contract_Id          VARCHAR2,
         p_Vendor_Id            VARCHAR2,
         p_Customer_id          VARCHAR2,
         p_Product_Id           VARCHAR2,
         p_Delivery_Point_Id    VARCHAR2,
         p_Profit_Center_Id     VARCHAR2,
         p_Price_Concept_Code   VARCHAR2,
         p_Qty_Status           VARCHAR2,
         p_uom1_code            VARCHAR2,
         p_price_object_id      VARCHAR2,
         p_Unique_Key_1         VARCHAR2,
         p_Unique_Key_2         VARCHAR2,
         p_Li_Unique_Key_1      VARCHAR2,
         p_Li_Unique_Key_2      VARCHAR2,
         p_Daytime              DATE,
         p_Period_Start_Date    DATE,
         p_Period_End_Date      DATE,
         p_ifac_tt_conn_code    VARCHAR2,
         p_ifac_li_conn_code    VARCHAR2,
         p_Line_Item_Based_Type VARCHAR2,
         p_Line_Item_Type       VARCHAR2
) RETURN NUMBER
IS

  CURSOR c_Max(cp_contract_Id           VARCHAR2,
               cp_vendor_Id             VARCHAR2,
               cp_customer_Id           VARCHAR2,
               cp_product_Id            VARCHAR2,
               cp_delivery_point_Id     VARCHAR2,
               cp_field_Id              VARCHAR2,
               cp_price_concept_code    VARCHAR2,
               cp_Qty_Status            VARCHAR2,
               cp_uom1_code             VARCHAR2,
               cp_price_object_id       VARCHAR2,
               cp_Unique_Key_1          VARCHAR2,
               cp_Unique_Key_2          VARCHAR2,
               cp_Li_Unique_Key_1       VARCHAR2,
               cp_Li_Unique_Key_2       VARCHAR2,
               cp_processing_period     DATE,
               cp_Period_Start_Date     DATE,
               cp_Period_End_Date       DATE,
               cp_ifac_tt_conn_code     VARCHAR2,
               cp_ifac_li_conn_code     VARCHAR2,
               cp_Line_Item_Based_Type  VARCHAR2,
               cp_Line_Item_Type        VARCHAR2
               ) IS
    SELECT NVL(MAX(isq.alloc_no),-1)+1 MaxAlloc
      FROM ifac_sales_qty isq
     WHERE isq.contract_Id         = cp_contract_Id
       AND isq.vendor_Id           = cp_vendor_Id
       AND NVL(isq.customer_Id,'X')= NVL(cp_customer_Id,'X')
       AND isq.product_Id          = cp_product_Id
       AND isq.delivery_point_Id   = cp_delivery_point_Id
       AND isq.profit_center_Id    = cp_field_Id
       AND isq.price_concept_code  = cp_price_concept_code
       AND isq.qty_status          = cp_qty_status
       AND nvl(isq.uom1_code,'X')  = NVL(cp_uom1_code,nvl(isq.uom1_code,'X'))
       AND NVL(isq.price_object_id,'X') = NVL(cp_price_object_id,'X')
       AND isq.processing_period   = cp_processing_period
       AND NVL(isq.unique_key_1,'X') = NVL(cp_unique_key_1,'X')
       AND NVL(isq.unique_key_2,'X') = NVL(cp_unique_key_2,'X')
       AND NVL(isq.ifac_tt_conn_code,'X') = NVL(cp_ifac_tt_conn_code,'X')
       AND NVL(isq.ifac_li_conn_code,'X') = NVL(cp_ifac_li_conn_code,'X')
       AND isq.period_start_date   = cp_Period_Start_Date
       AND isq.period_end_date     = cp_Period_End_Date
       AND isq.line_item_based_type = cp_Line_Item_Based_Type
       AND nvl(isq.Line_Item_type,'X') = nvl(cp_Line_Item_Type,'X')
       --Li_Unique_Key 1 and 2 are for other line items only.
       AND nvl(isq.Li_Unique_Key_1,'$NULL$') = case isq.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(isq.Li_Unique_Key_1,'$NULL$') else nvl(cp_Li_Unique_Key_1,'$NULL$') end
       AND nvl(isq.Li_Unique_Key_2,'$NULL$') = case isq.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(isq.Li_Unique_Key_2,'$NULL$') else nvl(cp_Li_Unique_Key_2,'$NULL$') end;

  ln_max NUMBER := 0;

BEGIN

   -- Get the max alloc no on this setup
   IF p_contract_Id         IS NULL OR
      p_vendor_Id           IS NULL OR
      p_customer_Id         IS NULL OR
      p_product_Id          IS NULL OR
      p_delivery_point_Id   IS NULL OR
      p_profit_center_Id    IS NULL OR
      p_price_concept_code  IS NULL OR
      p_Qty_Status          IS NULL OR
      p_daytime             IS NULL THEN

     ln_max := NULL;

   ELSE
     FOR rsC IN c_Max(p_Contract_Id,
                      p_Vendor_Id,
                      p_Customer_Id,
                      p_Product_Id,
                      p_Delivery_Point_Id,
                      p_Profit_Center_Id,
                      p_Price_Concept_Code,
                      p_Qty_Status,
                      p_uom1_code,
                      p_price_object_id,
                      p_Unique_Key_1,
                      p_Unique_Key_2,
                      p_Li_Unique_Key_1,
                      p_Li_Unique_Key_2,
                      p_Daytime,
                      p_Period_Start_Date,
                      p_Period_End_Date,
                      p_ifac_tt_conn_code,
                      p_ifac_li_conn_code,
                      p_Line_Item_Based_Type ,
                      p_Line_Item_Type
                      ) LOOP
      ln_max := rsC.Maxalloc;
   END LOOP;
   END IF;

   RETURN ln_max;

END GetNextPeriodAllocNo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetNextCargoAllocNo
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION GetNextCargoAllocNo(
          p_contract_id          VARCHAR2,
          p_vendor_id            VARCHAR2,
          p_Customer_id          VARCHAR2,
          p_cargo_no             VARCHAR2,
          p_parcel_no            VARCHAR2,
          p_qty_type             VARCHAR2,
          p_profit_center_id     VARCHAR2,
          p_price_concept_code   VARCHAR2,
          p_Product_Id           VARCHAR2,
          p_uom1_code            VARCHAR2,
          p_price_object_id      VARCHAR2,
          p_Li_Unique_Key_1      VARCHAR2,
          p_Li_Unique_Key_2      VARCHAR2,
          p_ifac_tt_conn_code    VARCHAR2,
          p_ifac_li_conn_code    VARCHAR2,
          p_Line_Item_Based_Type VARCHAR2,
          p_Line_Item_Type       VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_Max(cp_contract_id           VARCHAR2,
             cp_vendor_id             VARCHAR2,
             cp_customer_id           VARCHAR2,
             cp_cargo_no              VARCHAR2,
             cp_parcel_no             VARCHAR2,
             cp_qty_type              VARCHAR2,
             cp_profit_center_id      VARCHAR2,
             cp_price_concept_code    VARCHAR2,
             cp_product_id            VARCHAR2,
             cp_uom1_code             VARCHAR2,
             cp_price_object_id       VARCHAR2,
             cp_Li_Unique_Key_1       VARCHAR2,
             cp_Li_Unique_Key_2       VARCHAR2,
             cp_ifac_tt_conn_code     VARCHAR2,
             cp_ifac_li_conn_code     VARCHAR2,
             cp_Line_Item_Based_Type  VARCHAR2,
             cp_Line_Item_Type        VARCHAR2) IS
 SELECT NVL(MAX(cv.alloc_no),-1)+1 MaxAlloc
  FROM ifac_cargo_value cv
  WHERE cv.contract_id = cp_contract_id
    AND cv.vendor_id = cp_vendor_id
    AND NVL(cv.customer_Id,'X')= NVL(cp_customer_Id,'X')
    AND cv.cargo_no = cp_cargo_no
    AND cv.parcel_no = cp_parcel_no
    AND cv.qty_type = cp_qty_type
    AND cv.profit_center_id = cp_profit_center_id
    AND cv.price_concept_code = cp_price_concept_code
    AND cv.product_id = cp_product_id
    AND nvl(cv.uom1_code,'X')  = NVL(cp_uom1_code,nvl(cv.uom1_code,'X'))
    AND NVL(cv.price_object_id,'X') = NVL(cp_price_object_id,'X')
    AND NVL(cv.ifac_tt_conn_code,'X') = NVL(cp_ifac_tt_conn_code,'X')
    AND (cv.line_item_based_type = cp_Line_Item_Based_Type
         AND nvl(cv.ifac_li_conn_code,'X') = NVL(cp_ifac_li_conn_code,'X')
         AND nvl(cv.Line_Item_type,'X') = nvl(cp_Line_Item_Type,'X'))
    --Li_Unique_Key 1 and 2 are for other line items only.
    AND nvl(cv.Li_Unique_Key_1,'$NULL$') = case cv.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(cv.Li_Unique_Key_1,'$NULL$') else nvl(cp_Li_Unique_Key_1,'$NULL$') end
    AND nvl(cv.Li_Unique_Key_2,'$NULL$') = case cv.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(cv.Li_Unique_Key_2,'$NULL$') else nvl(cp_Li_Unique_Key_2,'$NULL$') end;

  ln_max NUMBER := NULL;

BEGIN

   IF p_contract_id IS NULL OR
      p_vendor_id IS NULL OR
      p_customer_id IS NULL OR
      p_cargo_no IS NULL OR
      p_parcel_no IS NULL OR
      p_qty_Type IS NULL OR
      p_profit_center_id IS NULL OR
      p_price_concept_code IS NULL OR
      p_Product_Id IS NULL THEN

      ln_max := NULL;

   ELSE

      -- Get the max alloc no on this setup
      FOR rsC IN c_Max(p_contract_id,
                       p_vendor_id,
                       p_customer_id,
                       p_cargo_no,
                       p_parcel_no,
                       p_qty_type,
                       p_profit_center_id,
                       p_price_concept_code,
                       p_Product_Id,
                       p_uom1_code,
                       p_price_object_id,
                       p_Li_Unique_Key_1,
                       p_Li_Unique_Key_2,
                       p_ifac_tt_conn_code,
                       p_ifac_li_conn_code ,
                       p_Line_Item_Based_Type ,
                       p_Line_Item_Type) LOOP
         ln_max := rsC.Maxalloc;
      END LOOP;

   END IF;

   RETURN ln_max;

END GetNextCargoAllocNo;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetQtyAllocNo
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION GetQtyAllocNo (
         p_Product            VARCHAR2,
         p_Company            VARCHAR2,
         p_Profit_Center      VARCHAR2,
         p_Si_category        VARCHAR2,
         p_day_mth            VARCHAR2,
         p_Node               VARCHAR2,
         p_Stream_item_Code   VARCHAR2,
         p_Daytime            DATE
) RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_alloc IS
  SELECT q.alloc_no
    FROM ifac_qty q
   WHERE q.product = p_Product
     AND q.company = p_Company
     AND q.profit_center = p_Profit_Center
     AND q.stream_item_category = p_Si_category
     and q.day_mth = p_day_mth
     AND nvl(q.node, 'NA') = nvl(p_Node, 'NA')
     AND nvl(q.stream_item_code, 'NA') = nvl(p_Stream_item_Code, 'NA')
     AND q.daytime = p_Daytime;

lv2_product        VARCHAR2(32) := NULL;
lv2_company         VARCHAR2(32) := NULL;
lv2_field           VARCHAR2(32) := NULL;
lv2_si_category    VARCHAR2(32) := NULL;
lv2_info         VARCHAR2(240) := NULL;
ln_max           NUMBER := NULL;

no_si_category   EXCEPTION;
no_product       EXCEPTION;
no_company       EXCEPTION;
no_field         EXCEPTION;

BEGIN
lv2_info := '. Parameters: Product: ' || p_Product || ', Company: ' || p_Company || ', Field: ' || p_Profit_Center || ', Stream Item Category: ' || p_Si_category ||
', Node: ' || p_Node || ', Stream Item: ' || p_Stream_item_Code;

   -- Get mapping codes
   lv2_product := getMappingCode(p_Product, 'PRODUCT', p_Daytime);
   IF (lv2_product IS NULL) THEN
       RAISE no_product;
   END IF;

   lv2_company := getMappingCode(p_Company, 'COMPANY', p_Daytime);
   IF (lv2_company IS NULL) THEN
       RAISE no_company;
   END IF;

   lv2_field := getMappingCode(p_Profit_Center, 'FIELD', p_Daytime);
   IF (lv2_field IS NULL) THEN
       RAISE no_field;
   END IF;

   lv2_si_category := getMappingCode(p_Si_category, 'STREAM_ITEM_CATEGORY', p_Daytime);
   IF (lv2_si_category IS NULL) THEN
       RAISE no_si_category;
   END IF;

   -- Get the max alloc no on this setup
   FOR ca IN c_alloc LOOP
      ln_max := ca.alloc_no;
   END LOOP;

   IF ln_max IS NULL THEN
      ln_max := 0;
   ELSE
      ln_max := ln_max + 1;
   END IF;

   RETURN ln_max;

EXCEPTION
   WHEN no_product THEN
      Raise_Application_Error(-20000,'Product not found: ' || p_Product || lv2_info);
    WHEN no_company THEN
      Raise_Application_Error(-20000,'Company not found: ' || p_company || lv2_info);
      WHEN no_field THEN
      Raise_Application_Error(-20000,'Field not found: ' || p_Profit_Center || lv2_info);
    WHEN no_si_category THEN
      Raise_Application_Error(-20000,'Stream Item Category not found: ' || p_Si_category || lv2_info);


END GetQtyAllocNo;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION IsPOValidForContract_P(p_Contract_Id     VARCHAR2,
                                       p_Price_Object_Id VARCHAR2)
RETURN BOOLEAN
IS

  CURSOR c_po_check(cp_Contract_Id VARCHAR2, cp_Price_Object_Id VARCHAR2) IS
    SELECT pp.object_id
      FROM product_price pp
     WHERE pp.contract_id = cp_Contract_Id
       AND pp.object_id = cp_Price_Object_Id
    UNION ALL
    SELECT ps.product_price_id
     FROM contract_price_setup ps
    WHERE ps.object_id = cp_Contract_Id
       AND ps.product_price_id = cp_Price_Object_Id;

  lb_po_valid BOOLEAN := FALSE;

BEGIN

    IF p_Price_Object_Id IS NOT NULL THEN

      -- Verify that PO is connected to the contract as a contract specific or general price object
      FOR rsPOC IN c_po_check(p_Contract_Id, p_Price_Object_Id) LOOP
        lb_po_valid := TRUE;
      END LOOP;

    END IF;

    RETURN lb_po_valid;

END IsPOValidForContract_P;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isVendorValidForContract_P(p_contract_id VARCHAR2,
                                  p_vendor_id VARCHAR2)
RETURN BOOLEAN
IS

  CURSOR c_parties IS
    SELECT cps.company_id
      FROM contract_party_share cps
     WHERE cps.object_id = p_contract_id
       AND cps.company_id = p_vendor_id
       AND cps.party_role = 'VENDOR';

  lb_found BOOLEAN := FALSE;

BEGIN

  FOR rsCPS IN c_parties LOOP
    lb_found := TRUE;
  END LOOP;

  RETURN lb_found;

END isVendorValidForContract_P;



FUNCTION ResolveSalesQtyRecord_P(
    p_Rec IN OUT NOCOPY IFAC_SALES_QTY%ROWTYPE
    ,p_daytime DATE)
RETURN IFAC_SALES_QTY%ROWTYPE
IS
  isqRec                ifac_sales_qty%ROWTYPE := NULL;
  lo_ifac               T_IFAC_SALES_QTY;
  lrec_tt               transaction_template%ROWTYPE := NULL;
  lrec_ttv              transaction_tmpl_version%ROWTYPE := NULL;
  lrec_pt               cont_transaction%ROWTYPE := NULL;
  lrec_po               product_price%ROWTYPE := NULL;
  lv2_tt_other_id       transaction_template.object_id%TYPE := NULL;
  ln_balance            NUMBER := NULL;
  ld_cntr_end_date      DATE;
  lb_has_multi_period   BOOLEAN := FALSE;
  lb_has_reconciliation BOOLEAN := FALSE;
  lb_prec_doc_booked    BOOLEAN := FALSE;
  lb_prec_doc_transfer  BOOLEAN := FALSE;

  l_trans_tmpl_info                T_REVN_OBJ_INFO;
  l_trans_tmpl_info_realloc        T_REVN_OBJ_INFO;
  l_trans_tmpl_info_another        T_REVN_OBJ_INFO;
  l_li_tmpl_info                   T_REVN_OBJ_INFO;
  l_resovled                       BOOLEAN;
  l_error_message                  VARCHAR2(2000);
  l_phase                          t_resolve_phase;

  CURSOR c_new(cp_contract_id VARCHAR2, cp_processing_period DATE) IS
    SELECT cv.*
      FROM ifac_sales_qty cv
     WHERE cv.contract_id = cp_contract_id
       AND cv.processing_period = cp_processing_period
       AND cv.trans_key_set_ind = 'N'
       AND cv.alloc_no_max_ind = 'Y';

BEGIN
    isqRec := p_Rec;

    resolve_internal_map_p(isqRec, p_daytime);
    resolve_common_values_p(isqRec, p_daytime);

    l_phase := c_resolve_phase_pre;
    l_resovled := resolve_as_free_unit_li_p(isqRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_free_unit_po_li_p(isqRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_fixed_value_li_p(isqRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_interest_li_p(isqRec, l_phase) OR l_resovled;

    -- Validate Vendor to contract parties
    IF isqRec.Vendor_Code NOT LIKE '%_FULL' THEN
      IF NOT isVendorValidForContract_P(isqRec.Contract_Id, isqRec.Vendor_Id) THEN
        isqRec.Vendor_Id := NULL;
        isqRec.Vendor_Code := 'INVALID';
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'Vendor is not valid for contract.');
      END IF;
    END IF;

    -- Check whether this is to be regarded as a prior period adjustment (PPA)
    -- This will override the qty status provided by interfacing system (EC or external)
    --    isqRec.Qty_Status := getQtyStatus(isqRec);

    -- Set processing period if not set by interface
    IF isqRec.Processing_Period IS NULL THEN
      IF isqRec.Qty_Status = 'PPA' THEN -- Potentially multiple periods in one document
        isqRec.Processing_Period := TRUNC(Ecdp_Timestamp.getCurrentSysdate, 'MM'); -- TODO: Get this based on a setting or user Exit?
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Processing Period was not supplied. Is set to current month: ' || isqRec.Processing_Period);
      ELSE
        IF isqRec.Period_Start_Date IS NOT NULL THEN
          isqRec.Processing_Period := TRUNC(isqRec.Period_Start_Date, 'MM');
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Processing Period is set to Supply From Date: ' || isqRec.Processing_Period);
        ELSIF isqRec.Period_end_Date IS NOT NULL THEN
          isqRec.Processing_Period := TRUNC(isqRec.Period_end_Date, 'MM');
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Processing Period is set to Supply To Date: ' || isqRec.Processing_Period);
        ELSE
          isqRec.Processing_Period := TRUNC(Ecdp_Timestamp.getCurrentSysdate, 'MM');
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Processing Period is set to current month: ' || isqRec.Processing_Period);
        END IF;
      END IF;
    END IF;

    -- Set period start/end dates
    IF isqRec.Period_Start_Date IS NOT NULL AND isqRec.Period_End_Date IS NULL THEN
      -- Set missing end date based on start date
      isqRec.Period_End_Date := LAST_DAY(isqRec.Period_Start_Date);
    ELSIF isqRec.Period_Start_Date IS NULL AND isqRec.Period_End_Date IS NOT NULL THEN
      -- Set missing start date based on end date
      isqRec.Period_Start_Date := TRUNC(isqRec.Period_End_Date, 'MM');
    ELSIF isqRec.Period_Start_Date IS NULL AND isqRec.Period_End_Date IS NULL THEN
      -- If no period dates have been set, use last resort - processing period
      isqRec.Period_Start_Date := TRUNC(isqRec.Processing_Period, 'MM');
      isqRec.Period_End_Date   := LAST_DAY(isqRec.Processing_Period);
    END IF;

    -- Make sure the isqRec.Period_End_Date is not after the Contract End Date
    ld_cntr_end_date := ec_contract.end_date(isqRec.Contract_Id);
    IF isqRec.Period_End_Date >= ld_cntr_end_date THEN
      isqRec.Period_End_Date := ld_cntr_end_date - 1; -- '-1' because the contract is not valid on the end date
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Contract ends before the period end date (' || isqRec.Period_End_Date + 1 || '), so it has been adjusted (' || isqRec.Period_End_Date || ').');
    END IF;

    -- Get Customer_ID based on Customer_Code
    IF isqRec.Customer_Code IS NOT NULL THEN
      isqRec.Customer_Id := ec_company.object_id_by_uk(isqRec.Customer_Code,'CUSTOMER');

      IF isqRec.Customer_Id IS NULL THEN
         isqRec.Customer_Code := 'INVALID_CUSTOMER';
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No valid Customer found for code: ' || isqRec.Customer_Code);
      ELSE
         IF EcDp_Contract_Setup.IsAllowedContractCustomer(
                isqRec.Contract_Id,
                isqRec.Customer_Id,
                p_daytime) = 'Y'
         THEN
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Customer found for code: ' || isqRec.Customer_Code);
         ELSE
            isqRec.Customer_Id := NULL;
            isqRec.Customer_Code := 'RESTRICTED_CUSTOMER';
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'A restricted Customer found for code: ' || isqRec.Customer_Code);
         END IF;
      END IF;
    ELSE
      isqRec.Customer_Id := EcDp_Contract_Setup.GetContractCustomerId(isqRec.Contract_Id, p_daytime);
      isqRec.Customer_code := ec_company.object_code(isqRec.Customer_Id);

      IF isqRec.Customer_Id IS NULL THEN
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No customer defined in contract');
      ELSE
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Customer is set to default contract customer: ' || EcDp_Objects.getObjCode(isqRec.Customer_Id));
      END IF;

    END IF;

    -- Get the preceding transaction and document.
    lo_ifac := ecdp_revn_ifac_wrapper_period.WrapInterfaceRecord(isqRec);
    isqRec.preceding_li_key := Ecdp_Document_Gen_Util.find_preceding_li_i(lo_ifac);
    IF isqRec.preceding_li_key IS NOT NULL THEN
        isqRec.Preceding_Trans_Key := ec_cont_line_item.transaction_key(isqRec.preceding_li_key);
    ELSE
        isqRec.Preceding_Trans_Key := Ecdp_Document_Gen_Util.GetIfacPrecedingTransKey(lo_ifac);
    END IF;

    lrec_pt                    := ec_cont_transaction.row_by_pk(isqRec.Preceding_Trans_Key);
    isqRec.Preceding_Doc_Key   := nvl(lrec_pt.document_key,p_Rec.Preceding_Doc_Key);
    IF (ec_cont_transaction.ppa_trans_code(isqRec.Preceding_Trans_Key )='PPA_PRICE') THEN
              isqRec.Preceding_Doc_Key   := ecdp_document.GetNonPPADocumentKey(isqRec.Preceding_Trans_Key);
    END IF;

    lb_prec_doc_booked := CASE WHEN ec_cont_document.document_level_code(isqRec.Preceding_Doc_Key) = 'BOOKED' THEN TRUE ELSE FALSE END;

    -- Determine Transaction Template --
    lb_has_multi_period   := Ecdp_Contract_Setup.ContractHasDocSetupConcept(isqRec.Contract_Id,
                                                                            isqRec.Processing_Period,
                                                                            'MULTI_PERIOD');
    lb_has_reconciliation := Ecdp_Contract_Setup.ContractHasDocSetupConcept(isqRec.Contract_Id,
                                                                            isqRec.Processing_Period,
                                                                            'RECONCILIATION');


    -- Find price object using period record parameters
    IF isqRec.Price_Object_Id IS NULL THEN
      isqRec.Price_Object_Id := GetIfacRecordPriceObject(isqRec.Contract_Id,
                                                         isqRec.product_id,
                                                         isqRec.price_concept_code,
                                                         isqRec.Qty_Status,
                                                         isqRec.Price_Status,
                                                         isqRec.Processing_Period,
                                                         isqRec.Uom1_Code
                                                         );
      IF isqRec.Price_Object_Id IS NULL THEN
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No Price Object found based on Ifac Record parameters.');
      ELSE
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Object ''' || ec_product_price.object_code(isqRec.Price_Object_Id) || ''' is set based on Ifac Record parameters.');
      END IF;
    END IF;

    -- For PPA: If no specific PPA Price object was found, copy from the preceding transaction.
    IF isqRec.Price_Object_Id IS NULL AND isqRec.Qty_Status = 'PPA' THEN
      isqRec.Price_Object_Id := lrec_pt.price_object_id;
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Taking Price Object from preceding transaction for PPA: '|| ec_product_price.object_code(isqRec.Price_Object_Id));
    END IF;


    -- Check if this record belongs to a contract that has got the "Multi Period Document" or "Reconciliation" Document Setup
    -- If this doc setup exists on a contract, the contract can not have other document setups (for now)
    IF lb_has_multi_period OR (lb_has_reconciliation AND isqRec.Qty_Status = 'PPA') THEN

      -- Find the best suited trans template
      IF lb_has_multi_period THEN
          l_trans_tmpl_info := find_transaction_template(isqRec, 'MULTI_PERIOD');
      END IF;

      -- NOTE - not all records for Multi Period have a preceding transaction, but Reconciliation records MUST have preceding transactions
      IF isqRec.Preceding_Trans_Key IS NOT NULL THEN

        IF lb_prec_doc_booked THEN

          IF lb_has_reconciliation AND isqRec.Qty_Status = 'PPA' THEN
            l_trans_tmpl_info := find_transaction_template(isqRec, 'RECONCILIATION');
          END IF;

        ELSE
          -- The interface has received a PPA record with a preceding transaction that is NOT booked.
          -- This is a quantity update. Preceding document is the document that was created with the first interface set.

          NULL;
        END IF;
      ELSE
        -- The interface has received a record for Multi Period without finding a preceding transaction.
        -- TODO: Add log description of this somewhere?
        NULL;
      END IF;
    ELSE
      -- This is NOT a Multi Period or Reconciliation Document record
      -- If the document found is in TRANSFER we must do as if it was BOOKED
      -- because we are NOT taking a doc at TRANSFER back to OPEN to update it with new quantities
      IF isqRec.Preceding_Doc_Key IS NOT NULL AND Ecdp_Document.IsDocLevelLocked(isqRec.Preceding_Doc_Key) = 'TRUE' THEN
        -- Handle reallocation
        IF ecdp_contract_setup.ContractHasDocSetupConcept(isqRec.Contract_Id,
                                                          isqRec.Processing_Period,
                                                          'REALLOCATION') THEN
          -- Find best suited reallocation transaction template, if any
          l_trans_tmpl_info_realloc := find_transaction_template(isqRec, 'REALLOCATION');

          -- If set up for reallocation support, check balance
          IF l_trans_tmpl_info_realloc.object_id IS NOT NULL THEN
            ln_balance := GetPeriodReallocBalance(isqRec.Contract_Id,
                                                  isqRec.Preceding_Doc_Key,
                                                  isqRec.Processing_Period);

            -- If balance is zero, this could be a record contributing in a reallocation.
            IF ln_balance = 0 THEN
              -- Set reallocation tt/ds on this record
              l_trans_tmpl_info := l_trans_tmpl_info_realloc;
              -- Set reallocation tt/ds on the other records
              FOR rsN IN c_New(isqRec.Contract_Id, isqRec.Processing_Period) LOOP
                l_trans_tmpl_info_another := find_transaction_template(rsN, 'REALLOCATION');

                UPDATE ifac_sales_qty cv
                   SET cv.trans_temp_id   = l_trans_tmpl_info_another.object_id,
                       cv.trans_temp_code = ec_transaction_template.object_code(l_trans_tmpl_info_another.object_id),
                       cv.doc_setup_id    = ec_transaction_template.contract_doc_id(l_trans_tmpl_info_another.object_id),
                       cv.doc_setup_code  = ec_contract_doc.object_code(ec_transaction_template.contract_doc_id(l_trans_tmpl_info_another.object_id))
                 WHERE cv.source_entry_no = rsN.Source_Entry_No;

              END LOOP;

            ELSE
              -- Balance is not zero.
              -- Set the matched dependent document setup on current record.
              l_trans_tmpl_info := find_transaction_template(isqRec, 'DEPENDENT%');
              FOR rsN IN c_New(isqRec.Contract_Id, isqRec.Processing_Period) LOOP
                -- Balance is not zero. Set the matched dependent document setup on all records.
                l_trans_tmpl_info_another := find_transaction_template(rsN, 'DEPENDENT%');

                UPDATE ifac_sales_qty cv
                   SET cv.trans_temp_id   = l_trans_tmpl_info_another.object_id,
                       cv.trans_temp_code = ec_transaction_template.object_code(l_trans_tmpl_info_another.object_id),
                       cv.doc_setup_id    = ec_transaction_template.contract_doc_id(l_trans_tmpl_info_another.object_id),
                       cv.doc_setup_code  = ec_contract_doc.object_code(ec_transaction_template.contract_doc_id(l_trans_tmpl_info_another.object_id))
                 WHERE cv.source_entry_no = rsN.Source_Entry_No;
                 WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Transaction Template Code and Document Setup Code are set in Ifac table: ' || ec_contract_doc.object_code(ec_transaction_template.contract_doc_id(lv2_tt_other_id)) ||'/'||ec_transaction_template.object_code(lv2_tt_other_id));

              END LOOP;
            END IF; -- balance zero?
          END IF; -- realloc tt found?
        ELSE
          -- No reallocation ds found
          -- Try to find dependent ds
          l_trans_tmpl_info := find_transaction_template(isqRec, 'DEPENDENT%');
        END IF;
      ELSE
        -- Booked preceding not found
        -- If we have found a preceding doc and it is at level OPEN | VALID1 | VALID2 then
        -- this doc will be our preceding doc that should be updated
        IF isqRec.Preceding_Doc_Key IS NOT NULL THEN
          --find the type of doc setup this doc is:
          IF ec_cont_document.document_concept(isqRec.Preceding_Doc_Key) = 'STANDALONE' THEN
            l_trans_tmpl_info := find_transaction_template(isqRec, 'STANDALONE');

            IF l_trans_tmpl_info.object_id IS NULL THEN
               -- We did not find a standalone DS match. This record may be data for the dependent
               -- document, made available BEFORE the standalone has been booked.
               -- Back end Action for this record will be VALIDATE_PRECEDING.

               l_trans_tmpl_info := find_transaction_template(isqRec, 'DEPENDENT%');

            END IF;

          ELSE
            -- Try to find dependent document setup as we have already an existing doc:
            l_trans_tmpl_info := find_transaction_template(isqRec, 'DEPENDENT%');
          END IF;
        ELSE
          --we have no existing doc
          -- Try to find standalone ds
          l_trans_tmpl_info := find_transaction_template(isqRec, 'STANDALONE');
        END IF;
      END IF;
    END IF; -- Multi Period / Reconciliation Document?

    --If no document setup was found then will run reanalyze to see if a preceding was just created
    IF l_trans_tmpl_info.object_id IS NULL AND isqRec.Preceding_Doc_Key IS NULL THEN


      isqRec.Preceding_Doc_Key   := nvl(isqRec.Preceding_Doc_Key,
                                     ecdp_document_gen_util.GetPeriodPrecedingDocKey(isqRec.Contract_Id,
                                                                                     isqRec.Processing_Period,
                                                                                     isqRec.Period_Start_Date,
                                                                                     isqRec.Price_Concept_Code,
                                                                                     isqRec.Delivery_Point_Id,
                                                                                     isqRec.Product_Id,
                                                                                     isqRec.Customer_Id,
                                                                                     isqRec.Unique_Key_1,
                                                                                     isqRec.Unique_Key_2,
                                                                                     null,
                                                                                     isqRec.Ifac_Tt_Conn_Code,
                                                                                     null,
                                                                                     isqRec.Qty_Status,
                                                                                     isqRec.Price_Status,
                                                                                     isqRec.Uom1_Code,
                                                                                     isqRec.Price_Object_Id));
    	 IF isqRec.Preceding_Doc_Key IS NOT NULL THEN --This will rerun it with the new preceding document that was just created
          isqRec := ResolveSalesQtyRecord_P(isqRec,p_daytime);
          RETURN isqRec;
       END IF;

    END IF;

    IF l_trans_tmpl_info.object_id IS NOT NULL THEN
      lrec_tt  := ec_transaction_template.row_by_pk(l_trans_tmpl_info.object_id);
      lrec_ttv := ec_transaction_tmpl_version.row_by_pk(l_trans_tmpl_info.object_id, l_trans_tmpl_info.version_date);
      isqRec.Trans_Temp_Id   := l_trans_tmpl_info.object_id;
      isqRec.Trans_Temp_Code := l_trans_tmpl_info.object_code;
      isqRec.Doc_Setup_Id    := lrec_tt.contract_doc_id;
      isqRec.Doc_Setup_Code  := ec_contract_doc.object_code(isqRec.Doc_Setup_Id);

      l_li_tmpl_info := find_line_item_template_p(isqRec, l_trans_tmpl_info);
      isqRec.Line_Item_Template_Id := l_li_tmpl_info.object_id;

    IF isqRec.Preceding_Doc_Key is null then -- Check to see if should be appending and existing document
         isqRec.Preceding_Doc_Key   := nvl(isqRec.Preceding_Doc_Key,
                                     ecdp_document_gen_util.GetPeriodPrecedingDocKey(isqRec.Contract_Id,
                                                                                     isqRec.Processing_Period,
                                                                                     isqRec.Period_Start_Date,
                                                                                     isqRec.Price_Concept_Code,
                                                                                     isqRec.Delivery_Point_Id,
                                                                                     isqRec.Product_Id,
                                                                                     isqRec.Customer_Id,
                                                                                     isqRec.Unique_Key_1,
                                                                                     isqRec.Unique_Key_2,
                                                                                     null,
                                                                                     isqRec.Ifac_Tt_Conn_Code,
                                                                                     lrec_tt.contract_doc_id));

      END IF;

      -- Find price object from transaction template
      IF isqRec.Price_Object_Id IS NULL AND lrec_ttv.price_object_id IS NOT NULL THEN
        isqRec.Price_Object_Id := lrec_ttv.price_object_id;
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Object ''' || ec_product_price.object_code(isqRec.Price_Object_Id) || ''' is set based on Transaction Template.');
      END IF;
      IF isqRec.Price_Object_Id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'No Price Object found based on Transaction Template.');
      END IF;

      -- Find price object using transaction template config
      IF isqRec.Price_Object_Id IS NULL AND lrec_ttv.price_object_id IS NULL THEN
        isqRec.Price_Object_Id := GetIfacRecordPriceObject(isqRec.Contract_Id,
                                                           lrec_ttv.product_id,
                                                           lrec_ttv.price_concept_code,
                                                           lrec_ttv.req_qty_type,
                                                           lrec_ttv.req_price_status,
                                                           isqRec.Processing_Period,
                                                           lrec_ttv.Uom1_Code
                                                           );
        IF isqRec.Price_Object_Id IS NOT NULL THEN
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Object ''' || ec_product_price.object_code(isqRec.Price_Object_Id) || ''' is set based on Transaction Template configuration.');
        END IF;
      END IF;
      IF isqRec.Price_Object_Id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'No Price Object found based on Transaction Template configuration.');
      END IF;

      -- Validate price object against contract
      IF NOT IsPOValidForContract_P(isqRec.Contract_Id, isqRec.Price_Object_Id) THEN
        isqRec.Price_Object_Id   := NULL;
        isqRec.Price_Object_Code := NULL;
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Object is not valid for this Contract. Price Object is removed.');
      END IF;

      -- Set price object code based on ID
      IF isqRec.Price_Object_Id IS NOT NULL THEN
        isqRec.Price_Object_code := ec_product_price.object_code(isqRec.Price_Object_Id);
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'Price Object Code ''' || nvl(isqRec.Price_Object_code,'NULL') || ''' is set based on Price Object ID.');
      END IF;

      --Delivery point should be able to be sat from transaction template if not in ifac
      IF isqRec.Delivery_Point_Id IS NULL AND lrec_ttv.delivery_point_id IS NOT NULL THEN
        isqRec.Delivery_Point_Id :=  lrec_ttv.delivery_point_id;
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Delivery Point ''' || ec_delivery_point.object_code(isqRec.Delivery_Point_Id) || ''' is set based on Transaction Template.');
      END IF;

    ELSE
      -- Could not find any matching transaction template. Record can not be used in document processing.
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No Transaction Template found!!!');
    END IF;

    -- Set product and price concept based on price object
    IF isqRec.Price_Object_Id IS NOT NULL THEN
      lrec_po := ec_product_price.row_by_pk(isqRec.Price_Object_Id);

      isqRec.Product_Id := lrec_po.product_id;
      isqRec.Product_Code := ec_product.object_code(lrec_po.product_id);
      isqRec.Price_Concept_Code := lrec_po.price_concept_code;
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Product Code ''' || isqRec.Product_Code || ''' is set based on Price Object Code: ' || ec_product_price.object_code(isqRec.Price_Object_Id));
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Concept Code ''' || isqRec.Price_Concept_Code || ''' is set based on Price Object Code: ' || ec_product_price.object_code(isqRec.Price_Object_Id));
    ELSIF isqRec.Line_Item_Based_Type = 'QTY' THEN
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No Price Object found!!!');
    END IF;

    l_phase := c_resolve_phase_post;
    l_resovled := resolve_as_free_unit_li_p(isqRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_free_unit_po_li_p(isqRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_fixed_value_li_p(isqRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_interest_li_p(isqRec, l_phase) OR l_resovled;

    IF NOT validate_ifac_p(isqRec, l_error_message) THEN
        WriteRevnLogInterface_P(
            EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR,
            'Interface record validation failed. ' || l_error_message);
        isqRec.Ignore_Ind := ecdp_revn_common.gv2_true;
    END IF;

    RETURN isqRec;
END ResolveSalesQtyRecord_P;
-----------------------------------------------------------------------------------------------------------------------------

FUNCTION ResolveCargoRecord_P(p_Rec IFAC_CARGO_VALUE%ROWTYPE, p_daytime DATE) RETURN IFAC_CARGO_VALUE%ROWTYPE
IS
  icvRec                            Ifac_Cargo_Value%ROWTYPE;
  lo_ifac                           t_ifac_cargo_value;
  lrec_ttv                          transaction_template%ROWTYPE := NULL;
  lrec_tt                           transaction_tmpl_version%ROWTYPE;
  lv2_tt_id                         transaction_template.object_id%type;
  ld_daytime                        DATE;
  l_trans_tmpl_info                 T_REVN_OBJ_INFO;
  l_li_tmpl_info                    T_REVN_OBJ_INFO;
  lrec_pt                           cont_transaction%ROWTYPE := NULL;
  l_resovled                        BOOLEAN;
  l_phase                           t_resolve_phase;

BEGIN
    icvRec := p_Rec;

     -- Truncate point of sale date to the month date (first day of month)
     ld_daytime := NVL(trunc(p_Rec.point_of_sale_date,'MM'), p_daytime);

     -- Map internal with external codes
     icvRec.Contract_Code       := getMappingCode(p_Rec.contract_code, 'CONTRACT', ld_daytime);
     icvRec.Vendor_Code         := getMappingCode(p_Rec.vendor_code, 'VENDOR', ld_daytime);
     icvRec.Product_Code        := getMappingCode(p_Rec.product_code, 'PRODUCT', ld_daytime);
     icvRec.Loading_Port_Code   := getMappingCode(p_Rec.loading_port_code, 'PORT', ld_daytime);
     icvRec.Discharge_Port_Code := getMappingCode(p_Rec.discharge_port_code, 'PORT', ld_daytime);
     icvRec.Profit_Center_Code  := getMappingCode(p_Rec.profit_center_code, p_Rec.Object_Type, ld_daytime);
     icvRec.carrier_Code        := getMappingCode(p_Rec.carrier_Code, 'CARRIER', ld_daytime);
     icvRec.Consignor_Code      := getMappingCode(p_Rec.Consignor_Code, 'VENDOR', ld_daytime);
     icvRec.Consignee_Code      := getMappingCode(p_Rec.Consignee_Code, 'CUSTOMER', ld_daytime);
     icvRec.Uom1_Code           := getMappingCode(p_Rec.uom1_code, 'UOM', ld_daytime);
     icvRec.Uom2_Code           := getMappingCode(p_Rec.uom2_code, 'UOM', ld_daytime);
     icvRec.Uom3_Code           := getMappingCode(p_Rec.uom3_code, 'UOM', ld_daytime);
     icvRec.Uom4_Code           := getMappingCode(p_Rec.uom4_code, 'UOM', ld_daytime);
     icvRec.qty_type            := getMappingCode(p_rec.qty_type, 'QTY_TYPE');
     icvRec.price_concept_code  := getMappingCode(p_rec.price_concept_code, 'PRICE_CONCEPT');
     icvRec.Price_Object_Code   := getMappingCode(p_rec.price_object_code, 'PRICE_OBJECT');
     icvRec.Source_Node_Code    := getMappingCode(p_Rec.Source_Node_Code, 'ALLOC_NODE', ld_daytime);
     icvRec.Loading_Berth_Code  := getMappingCode(p_Rec.Loading_Berth_Code, 'BERTH', ld_daytime);
     icvRec.Discharge_Berth_Code:= getMappingCode(p_Rec.Discharge_Berth_Code, 'BERTH', ld_daytime);
     icvRec.Int_From_Date       := getMappingCode(p_Rec.Int_From_Date, 'INT_FROM_DATE', ld_daytime);
     icvRec.Int_To_Date         := getMappingCode(p_Rec.Int_To_Date, 'INT_TO_DATE', ld_daytime);
     icvRec.Line_Item_Based_Type:= getMappingCode(p_Rec.Line_Item_Based_Type, 'LINE_ITEM_BASED_TYPE', ld_daytime);
     icvRec.Line_Item_Type      := getMappingCode(p_Rec.Line_Item_Type, 'LINE_ITEM_TYPE', ld_daytime);
     icvRec.Int_Type            := getMappingCode(p_Rec.Int_Type, 'INT_TYPE', ld_daytime);
     icvRec.Unit_Price_Unit     := getMappingCode(p_Rec.Unit_Price_Unit, 'UNIT_PRICE_UNIT', ld_daytime);
     icvRec.li_Price_Object_Code:= getMappingCode(p_Rec.li_price_object_code, 'PRICE_OBJECT', ld_daytime);

     -- Validate Line_Item_Based_Type
     IF icvRec.line_item_based_type IS NULL THEN
          icvRec.line_item_based_type := 'QTY';
     END IF;

     -- Validate Line_Item_Type
     IF icvRec.line_item_type is NULL AND icvRec.line_item_based_type <> 'QTY' THEN
       WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_WARNING, 'Missing Line Item Type.');
     END IF;

     -- Get contract object_id based on contract code
     IF icvRec.Contract_Id IS NULL THEN
       icvRec.Contract_Id := ec_contract.object_id_by_uk(icvRec.contract_code);
     END IF;
     IF icvRec.Contract_Id IS NULL THEN
       WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No valid Contract found in Ifac Record for code: ' || nvl(icvRec.contract_code,'NULL'));
     ELSE
       WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Contract is found in Ifac Record for code: ' || icvRec.contract_code);
     END IF;

     -- Get vendor object_id based on vendor code
     IF icvRec.Vendor_Id IS NULL THEN
        icvRec.Vendor_Id := ec_company.object_id_by_uk(icvRec.vendor_code, 'VENDOR');
     END IF;
     IF icvRec.Vendor_Id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Vendor found in Ifac Record for code: ' || nvl(icvRec.vendor_code,'NULL'));
     ELSE
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Vendor is found in Ifac Record for code: ' || icvRec.vendor_code);
     END IF;

     -- Get product object_id based on product code
     IF icvRec.Product_Id IS NULL THEN
        icvRec.Product_Id := ec_product.object_id_by_uk(icvRec.Product_Code);
     END IF;
     IF icvRec.Product_Id IS NULL THEN
        IF icvRec.Product_Code IS NULL THEN
           WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No Product Code found in Ifac Record.');
        ELSE
           WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No valid Product found in Ifac Record for code: ' || nvl(icvRec.Product_Code,'NULL'));
        END IF;
     ELSE
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Product is found in Ifac Record for code: ' || icvRec.Product_Code);
     END IF;

     -- Get loading port object_id based on loading port code
     IF icvRec.Loading_Port_Id IS NULL THEN
        icvRec.Loading_Port_Id := ec_port.object_id_by_uk(icvRec.Loading_Port_Code);
     END IF;
     IF icvRec.Loading_Port_Id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Loading Port found in Ifac Record for code: ' || nvl(icvRec.Loading_Port_Code,'NULL'));
     ELSE
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Loading Port is found in Ifac Record for code: ' || icvRec.Loading_Port_Code);
     END IF;

     -- Get discharge port object_id based on discharge port code
     IF icvRec.discharge_Port_Id IS NULL THEN
        icvRec.discharge_Port_Id := ec_port.object_id_by_uk(icvRec.discharge_Port_Code);
     END IF;
     IF icvRec.discharge_Port_Id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Discharge Port found in Ifac Record for code: ' || nvl(icvRec.discharge_Port_Code,'NULL'));
     ELSE
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Discharge Port is found in Ifac Record for code: ' || icvRec.discharge_Port_Code);
     END IF;

     -- Get field object_id based on field code
     IF icvRec.Profit_Center_Id IS NULL THEN

       IF p_Rec.object_type = 'OBJECT_LIST' THEN
          IF icvRec.Profit_Center_code = 'SUM' THEN
             icvRec.Profit_Center_Id := ec_field.object_id_by_uk(icvRec.Profit_Center_Code, 'FIELD');
          ELSE
             icvRec.Profit_Center_Id := ecdp_objects.GetObjIDFromCode(p_Rec.object_type, icvRec.Profit_Center_code);
          END IF;
       ELSE
          icvRec.Profit_Center_Id :=	ecdp_objects.GetObjIDFromCode(p_Rec.object_type, icvRec.Profit_Center_code);
       END IF;
       IF p_Rec.object_type IS NULL THEN -- This is only for scenrio tester which supports only field
         icvRec.Profit_Center_Id := ec_field.object_id_by_uk(icvRec.Profit_Center_Code, 'FIELD');
       END IF;
     END IF;
     IF icvRec.Profit_Center_Id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No valid ' || p_Rec.object_type || ' found in Ifac Record for code: ' || nvl(icvRec.Profit_Center_Code,'NULL'));
    ELSE
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid ' || p_Rec.object_type || ' is found in Ifac Record for code: ' || icvRec.Profit_Center_Code);
    END IF;

     -- Get source node object_id based on source node code
     IF icvRec.Source_Node_Id IS NULL THEN
        icvRec.Source_Node_Id := ecdp_objects.GetObjIDFromCode('ALLOC_NODE',icvRec.Source_Node_Code);
     END IF;
     IF icvRec.Source_Node_Id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Source Node found in Ifac Record for code: ' || nvl(icvRec.Source_Node_Code,'NULL'));
     ELSE
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Source Node is found in Ifac Record for code: ' || icvRec.Source_Node_Code);
     END IF;

     -- Get mapping code for vessel_code (must be valid codes from IFAC_CARGO_VALUE)
     IF icvRec.carrier_id IS NULL THEN
        icvRec.carrier_id := ec_carrier.object_id_by_uk(icvRec.Carrier_Code);
     END IF;
     IF icvRec.carrier_id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Carrier found in Ifac Record for code: ' || nvl(icvRec.Carrier_Code,'NULL'));
     ELSE
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Carrier is found in Ifac Record for code: ' || icvRec.Carrier_Code);
     END IF;

     -- Get mapping code for consignor_code (must be valid codes from IFAC_CARGO_VALUE)
     IF icvRec.Consignor_id IS NULL THEN
        icvRec.Consignor_id := ec_company.object_id_by_uk(icvRec.Consignor_code, 'VENDOR');
     END IF;
     IF icvRec.Consignor_id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Consignor found in Ifac Record for code: ' || nvl(icvRec.Consignor_code,'NULL'));
     ELSE
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Consignor is found in Ifac Record for code: ' || icvRec.Consignor_code);
     END IF;

     -- Get mapping code for consignee_code (must be valid codes from IFAC_CARGO_VALUE)
     IF icvRec.Consignee_id IS NULL THEN
        icvRec.Consignee_id := ec_company.object_id_by_uk(icvRec.Consignee_code, 'CUSTOMER');
     END IF;
     IF icvRec.Consignee_id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Consignee found in Ifac Record for code: ' || nvl(icvRec.Consignee_code,'NULL'));
     ELSE
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Consignee is found in Ifac Record for code: ' || icvRec.Consignee_code);
     END IF;

     -- Get mapping code for price_object_code (must be valid codes from IFAC_CARGO_VALUE)
     IF icvRec.Price_Object_Id IS NULL THEN
        icvRec.Price_Object_Id := ec_product_price.object_id_by_uk(icvRec.Price_Object_Code);

        IF icvRec.Price_Object_Id IS NOT NULL THEN
           WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Price Object Id is found based on interfaced Price Object Code: ' || icvRec.Price_Object_Code);
        ELSE
           WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'No Price Object Id found based on interfaced Price Object Code: ' || nvl(icvRec.Price_Object_Code,'NULL'));
        END IF;

        -- Set price object code based on ID
        IF icvRec.Product_Id IS NULL THEN
          icvRec.Product_Id := ec_product_price.product_id(icvRec.Price_Object_Id);
          icvRec.Product_Code := ec_product.object_code(icvRec.Product_Id);
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Product Code ''' || icvRec.Product_Code || ''' is set based on Price Object Code: ' || icvRec.Price_Object_Code);
        END IF;
        IF icvRec.Price_Concept_Code IS NULL THEN
          icvRec.Price_Concept_Code := ec_product_price.price_concept_code(icvRec.Price_Object_Id);
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Concept Code ''' || icvRec.Price_Concept_Code || ''' is set based on Price Object Code: ' || icvRec.Price_Object_Code);
        END IF;
        IF icvRec.Qty_Type IS NULL THEN
          icvRec.Qty_Type := ec_product_price_version.quantity_status(icvRec.Price_Object_Id,p_daytime,'<=');
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Qty Type ''' || nvl(icvRec.Qty_Type,'NULL') || ''' is set based on Price Object Code: ' || icvRec.Price_Object_Code);
        END IF;
        IF icvRec.Price_Status IS NULL THEN
          icvRec.Price_Status := ec_product_price_version.price_status(icvRec.Price_Object_Id,p_daytime,'<=');
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Status ''' || nvl(icvRec.Price_Status,'NULL') || ''' is set based on Price Object Code: ' || icvRec.Price_Object_Code);
        END IF;
     END IF;

     -- If no product is found by now, log it as ERROR
     IF icvRec.Product_Id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No valid Product found in Ifac Record or by config.');
     END IF;

    -- Get Customer_ID based on Customer_Code
    IF icvRec.Customer_Code IS NOT NULL THEN
      icvRec.Customer_Id := ec_company.object_id_by_uk(icvRec.Customer_Code,'CUSTOMER');

      IF icvRec.Customer_Id IS NULL THEN
         icvRec.Customer_Code := 'INVALID_CUSTOMER';
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No valid Customer found for code: ' || icvRec.Customer_Code);
      ELSE
         IF EcDp_Contract_Setup.IsAllowedContractCustomer(
                icvRec.Contract_Id,
                icvRec.Customer_Id,
                p_daytime) = 'Y'
         THEN
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Customer found for code: ' || icvRec.Customer_Code);
         ELSE
            icvRec.Customer_Id := NULL;
            icvRec.Customer_Code := 'RESTRICTED_CUSTOMER';
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'A restricted Customer found for code: ' || icvRec.Customer_Code);
         END IF;
      END IF;
    ELSE
      icvRec.Customer_Id := EcDp_Contract_Setup.GetContractCustomerId(icvRec.Contract_Id, p_daytime);
      icvRec.Customer_code := ec_company.object_code(icvRec.Customer_Id);

      IF icvRec.Customer_Id IS NULL THEN
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No customer defined in contract');
      ELSE
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Customer is set to default contract customer: ' || EcDp_Objects.getObjCode(icvRec.Customer_Id));
      END IF;

    END IF;


    -- Get loading berth object_id based on loading berth code
     IF icvRec.Loading_Berth_Id IS NULL THEN
        icvRec.Loading_Berth_Id := ec_berth.object_id_by_uk(icvRec.Loading_Berth_Code);
     END IF;
     IF icvRec.Loading_Berth_Id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Loading Berth found in Ifac Record for code: ' || nvl(icvRec.Loading_Berth_Code,'NULL'));
     ELSE
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Loading Berth is found in Ifac Record for code: ' || icvRec.Loading_Berth_Code);
     END IF;
     -- Get discharge berth object_id based on discharge berth code
     IF icvRec.Discharge_Berth_Id IS NULL THEN
        icvRec.Discharge_Berth_Id := ec_berth.object_id_by_uk(icvRec.Discharge_Berth_Code);
     END IF;
     IF icvRec.Discharge_Berth_Id IS NULL THEN
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No valid Discharge Berth found in Ifac Record for code: ' || nvl(icvRec.Discharge_Berth_Code,'NULL'));
     ELSE
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Discharge Berth is found in Ifac Record for code: ' || icvRec.Discharge_Berth_Code);
     END IF;


    l_phase := c_resolve_phase_pre;
    l_resovled := resolve_as_free_unit_li_p(icvRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_free_unit_po_li_p(icvRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_fixed_value_li_p(icvRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_interest_li_p(icvRec, l_phase) OR l_resovled;

    -- Get the preceding transaction and document.
    lo_ifac := ecdp_revn_ifac_wrapper_cargo.WrapInterfaceRecord(icvRec);
    icvRec.preceding_li_key := Ecdp_Document_Gen_Util.find_preceding_li_i(lo_ifac);
    IF icvRec.preceding_li_key IS NOT NULL THEN
        icvRec.Preceding_Trans_Key := ec_cont_line_item.transaction_key(icvRec.preceding_li_key);
    ELSE
        icvRec.Preceding_Trans_Key := Ecdp_Document_Gen_Util.GetIfacPrecedingTransKey(lo_ifac);
    END IF;

    lrec_pt                    := ec_cont_transaction.row_by_pk(icvRec.Preceding_Trans_Key);
    icvRec.Preceding_Doc_Key   := nvl(lrec_pt.document_key,p_Rec.Preceding_Doc_Key);


    IF icvRec.Preceding_Doc_Key IS NULL THEN-- Check to see if should be appending and existing document
         icvRec.Preceding_Doc_Key   := nvl(icvRec.Preceding_Doc_Key,
                                     ecdp_document_gen_util.GetCargoPrecedingDocKey(
                                            icvRec.contract_id,
                                            icvRec.Cargo_No,
                                            icvRec.Parcel_No,
                                            icvRec.Document_Key,
                                            NULL,
                                            icvRec.Ifac_Tt_Conn_Code,
                                            icvRec.customer_id));

      IF icvRec.Preceding_Doc_Key IS NOT NULL THEN --This will rerun it with the new preceding document that was just created
          icvRec := ResolveCargoRecord_P(icvRec,p_daytime);
          RETURN icvRec;
       END IF;

    END IF;


/*
    IF ec_cont_document.document_level_code(icvrec.preceding_doc_key) NOT IN ('BOOKED','TRANSFER') THEN
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Preceding Document Key ''' || nvl(icvrec.preceding_doc_key,'NULL') || ''' is removed because Preceding Document is not transferred or booked.');
      icvrec.preceding_doc_key  := NULL;
    END IF;
*/
    IF icvrec.preceding_doc_key IS NOT NULL THEN
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Preceding Document Key set to ''' || nvl(icvrec.preceding_doc_key,'NULL') || '''.');
    END IF;



   lv2_tt_id := GetIfacCargoQtyTT(icvRec);

    IF lv2_tt_id IS NULL THEN
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No Transaction Template found!!!');
    ELSE

      icvRec.Trans_Temp_Id := lv2_tt_id;
      icvRec.Trans_Temp_Code := ec_transaction_template.object_code(lv2_tt_id);
      icvRec.Doc_Setup_Id := ec_transaction_template.contract_doc_id(lv2_tt_id);
      icvRec.Doc_Setup_Code := ec_contract_doc.object_code(icvRec.Doc_Setup_Id);
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Transaction Template is found: ' || icvRec.Trans_Temp_Code);
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'A valid Document Setup is found: ' || icvRec.Doc_Setup_Code);
      l_trans_tmpl_info  := T_REVN_OBJ_INFO(
                object_id => lv2_tt_id,
                object_name => icvRec.Trans_Temp_Code,
                object_code => icvRec.Trans_Temp_Code,
                version_date => ec_transaction_template.start_date(lv2_tt_id),
                version_end_date =>  ec_transaction_template.end_date(lv2_tt_id));
      l_li_tmpl_info := find_line_item_temp_ca_p(icvrec, l_trans_tmpl_info);
      icvrec.Line_Item_Template_Id := l_li_tmpl_info.object_id;
      -- Find correct transaction template
      lrec_tt := ec_transaction_tmpl_version.row_by_pk(lv2_tt_id, ld_daytime, '<=');
      -- Find price object directly from transaction template
      IF icvRec.Price_Object_Id IS NULL AND lrec_tt.price_object_id IS NOT NULL THEN
         icvRec.Price_Object_Id := lrec_tt.price_object_id;
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Object ''' || ec_product_price.object_code(icvRec.Price_Object_Id) || ''' from Transaction Template will be used.');
      END IF;
      IF icvRec.Price_Object_Id IS NULL THEN
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'No Price Object found based on Transaction Template.');
      END IF;

      -- Find price object using transaction template config
      IF icvRec.Price_Object_Id IS NULL AND lrec_tt.price_object_id IS NULL THEN
         icvRec.Price_Object_Id := GetIfacRecordPriceObject(icvRec.Contract_Id,
                                                            lrec_tt.product_id,
                                                            lrec_tt.price_concept_code,
                                                            lrec_tt.req_qty_type,
                                                            lrec_tt.req_price_status,
                                                            ld_daytime);
         IF icvRec.Price_Object_Id IS NOT NULL THEN
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Object ''' || ec_product_price.object_code(icvRec.Price_Object_Id) || ''' is set based on Transaction Template configuration.');
         END IF;
      END IF;
      IF icvRec.Price_Object_Id IS NULL THEN
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'No Price Object found based on Transaction Template configuration.');
      END IF;

      -- Get mapping code for li_price_object_code (must be valid codes from IFAC_SALES_QTY)
      IF icvRec.li_Price_Object_Id IS NULL THEN
         icvRec.li_Price_Object_Id := ec_product_price.object_id_by_uk(icvRec.li_Price_Object_Code);
      END IF;
      -- Try to set BL Date based on base code
      IF icvRec.BL_Date IS NULL AND lrec_tt.bl_date_base_code IS NOT NULL THEN
         icvRec.BL_Date := CASE lrec_tt.bl_date_base_code
                        WHEN 'LOADING_COMMENCED_DATE' THEN icvRec.Loading_Comm_Date
                        WHEN 'LOADING_COMPLETED_DATE' THEN icvRec.loading_date END;
         IF icvRec.BL_Date IS NOT NULL THEN
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Bill Of Lading Date is set based on Transaction Template base code: ' || nvl(lrec_tt.bl_date_base_code,'NULL'));
         END IF;
      END IF;
      IF icvRec.BL_Date IS NULL THEN
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No Bill Of Lading Date found based on Transaction Template.');
      END IF;

      -- Try to set POS Date based on base code
      IF icvRec.Point_Of_Sale_Date IS NULL AND lrec_tt.posd_base_code IS NOT NULL THEN
         icvRec.Point_Of_Sale_Date := CASE lrec_tt.posd_base_code
                                         WHEN 'LOADING_COMMENCED_DATE'  THEN icvRec.loading_comm_date
                                         WHEN 'LOADING_COMPLETED_DATE'  THEN icvRec.loading_date
                                         WHEN 'DELIVERY_COMMENCED_DATE' THEN icvRec.delivery_comm_date
                                         WHEN 'DELIVERY_COMPLETED_DATE' THEN icvRec.delivery_date
                                         WHEN 'BL_DATE'                 THEN icvRec.bl_date END;
         IF icvRec.Point_Of_Sale_Date IS NOT NULL THEN
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Point Of Sale Date is set based on Transaction Template base code: ' || nvl(lrec_tt.posd_base_code,'NULL'));
         END IF;
      END IF;
      IF icvRec.Point_Of_Sale_Date IS NULL THEN
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No Point Of Sale Date found based on Transaction Template.');
      END IF;

      -- Try to set Price Date based on base code
      IF icvRec.Price_Date IS NULL AND lrec_tt.price_date_base_code IS NOT NULL THEN
           icvRec.Price_Date := CASE lrec_tt.price_date_base_code
                                 WHEN 'LOADING_COMMENCED_DATE'  THEN icvRec.loading_comm_date
                                 WHEN 'LOADING_COMPLETED_DATE'  THEN icvRec.loading_date
                                 WHEN 'DELIVERY_COMMENCED_DATE' THEN icvRec.delivery_comm_date
                                 WHEN 'DELIVERY_COMPLETED_DATE' THEN icvRec.delivery_date
                                 WHEN 'POINT_OF_SALE_DATE'      THEN icvRec.Point_Of_Sale_Date
                                 WHEN 'BL_DATE'                 THEN icvRec.bl_date END;
         IF icvRec.Price_Date IS NOT NULL THEN
            WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Date is set based on Transaction Template base code: ' || nvl(lrec_tt.price_date_base_code,'NULL'));
         END IF;
      END IF;
      IF icvRec.Price_Date IS NULL THEN
         WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No Price Date found based on Transaction Template.');
      END IF;
    END IF;

    -- Last attempt to find price object using cargo record parameters, if not found using TT, or a TT was not found
    IF icvRec.Price_Object_Id IS NULL THEN
       icvRec.Price_Object_Id := GetIfacRecordPriceObject(icvRec.Contract_Id,
                                                          icvRec.product_id,
                                                          icvRec.price_concept_code,
                                                          icvRec.Qty_Type,
                                                          icvRec.Price_Status,
                                                          ld_daytime);
       IF icvRec.Price_Object_Id IS NOT NULL THEN
          WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Object ''' || ec_product_price.object_code(icvRec.Price_Object_Id) || ''' is set based on cargo record parameters.');
       END IF;
    END IF;
    IF icvRec.Price_Object_Id IS NULL THEN
       WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'No Price Object found based on cargo record parameters.');
    END IF;

    -- Validate price object against contract
    IF NOT IsPOValidForContract_P(icvRec.Contract_Id, icvRec.Price_Object_Id) THEN
       icvRec.Price_Object_Id := NULL;
       icvRec.Price_Object_Code := NULL;
       WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'Price Object is not valid for current contract. Price object is removed.');
    END IF;

    -- Validate Vendor to contract parties
    IF icvRec.Vendor_Code NOT LIKE '%_FULL' THEN
      IF NOT isVendorValidForContract_P(icvRec.Contract_Id, icvRec.Vendor_Id) THEN
        icvRec.Vendor_Id := NULL;
        icvRec.Vendor_Code := 'INVALID';
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'Vendor is not valid for current contract. Vendor is removed.');
      END IF;
    END IF;

    -- Set price object code based on ID
    IF icvRec.Price_Object_Id IS NOT NULL THEN
      icvRec.Price_Object_code := ec_product_price.object_code(icvRec.Price_Object_Id);
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'Price Object Code ''' || nvl(icvRec.Price_Object_code,'NULL') || ''' is set based on Price Object ID.');
      IF icvRec.Product_Id IS NULL THEN
        icvRec.Product_Id := ec_product_price.product_id(icvRec.Price_Object_Id);
        icvRec.Product_Code := ec_product.object_code(icvRec.Product_Id);
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Product Code ''' || icvRec.Product_Code || ''' is set based on Price Object Code: ' || icvRec.Price_Object_Code);
      END IF;
      IF icvRec.Price_Concept_Code IS NULL THEN
        icvRec.Price_Concept_Code := ec_product_price.price_concept_code(icvRec.Price_Object_Id);
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Concept Code ''' || icvRec.Price_Concept_Code || ''' is set based on Price Object Code: ' || icvRec.Price_Object_Code);
      END IF;
      IF icvRec.Qty_Type IS NULL THEN
        icvRec.Qty_Type := ec_product_price_version.quantity_status(icvRec.Price_Object_Id,p_daytime,'<=');
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Qty Type ''' || icvRec.Qty_Type || ''' is set based on Price Object Code: ' || icvRec.Price_Object_Code);
      END IF;
      IF icvRec.Price_Status IS NULL THEN
        icvRec.Price_Status := ec_product_price_version.price_status(icvRec.Price_Object_Id,p_daytime,'<=');
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, 'Price Status ''' || icvRec.Price_Status || ''' is set based on Price Object Code: ' || icvRec.Price_Object_Code);
      END IF;
    ELSE
      WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR, 'No Price Object found.');
    END IF;

    l_phase := c_resolve_phase_post;
    l_resovled := resolve_as_free_unit_li_p(icvRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_free_unit_po_li_p(icvRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_fixed_value_li_p(icvRec, l_phase) OR l_resovled;
    l_resovled := resolve_as_interest_li_p(icvRec, l_phase) OR l_resovled;

    -- Validates Vat Code
    IF NOT validate_vat_code_p(icvRec.contract_id, icvRec.Point_Of_Sale_Date, icvRec.vat_code) THEN
      WriteRevnLogInterface_P(
        EcDp_Revn_Log.LOG_STATUS_ITEM_ERROR,
        'Vat Code ''' || icvRec.vat_code || ''' for ' || icvRec.line_item_based_type || ' line item is not valid for current contract.');
      icvRec.Ignore_Ind := ecdp_revn_common.gv2_true;
    END IF;

    RETURN icvRec;
END ResolveCargoRecord_P;

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-- Set alloc_no_max_ind to N for all records representing previous allocations.
-- p_source_entry_no represents the record with the highest allocation number.
PROCEDURE UpdateCargoIfacMaxAllocInd_P(p_source_entry_no NUMBER)
IS
  lrec_smcv ifac_cargo_value%ROWTYPE := ec_ifac_cargo_value.row_by_pk(p_source_entry_no);
BEGIN

  UPDATE ifac_cargo_value cv
    SET cv.alloc_no_max_ind = 'N'
    WHERE cv.contract_id = lrec_smcv.contract_id
      AND cv.vendor_id = lrec_smcv.vendor_id
      AND NVL(cv.customer_id, '$NULL$') = NVL(lrec_smcv.customer_id, '$NULL$')
      AND cv.cargo_no = lrec_smcv.cargo_no
      AND cv.parcel_no = lrec_smcv.parcel_no
      AND cv.qty_type = lrec_smcv.qty_type
      AND cv.price_concept_code = lrec_smcv.price_concept_code
      AND cv.profit_center_id = lrec_smcv.profit_center_id
      AND cv.product_id = lrec_smcv.product_id
      AND cv.uom1_code = lrec_smcv.uom1_code
      AND NVL(cv.price_object_id,'X') = NVL(lrec_smcv.price_object_id,'X')
      AND nvl(cv.ifac_tt_conn_code,'X') = nvl(lrec_smcv.ifac_tt_conn_code,'X')
      AND nvl(cv.ifac_li_conn_code,'X') = nvl(lrec_smcv.ifac_li_conn_code,'X')
      AND cv.line_item_based_type = lrec_smcv.line_item_based_type
      AND nvl(cv.Line_Item_type,'X') = nvl(lrec_smcv.line_item_type,'X')
      AND cv.alloc_no < lrec_smcv.alloc_no
     --Li_Unique_Key 1 and 2 are for other line items only.
     AND nvl(cv.Li_Unique_Key_1,'$NULL$') = case cv.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(cv.Li_Unique_Key_1,'$NULL$') else nvl(lrec_smcv.Li_Unique_Key_1,'$NULL$') end
     AND nvl(cv.Li_Unique_Key_2,'$NULL$') = case cv.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(cv.Li_Unique_Key_2,'$NULL$') else nvl(lrec_smcv.Li_Unique_Key_2,'$NULL$') end;

END UpdateCargoIfacMaxAllocInd_P;

-----------------------------------------------------------------------------------------------------------------------------
-- Set alloc_no_max_ind to N for all records representing previous allocations.
PROCEDURE UpdatePeriodIfacMaxAllocInd_P(p_contract_id VARCHAR2,
                                        p_vendor_id VARCHAR2,
                                        p_customer_id VARCHAR2,
                                        p_field_id VARCHAR2,
                                        p_price_concept_code VARCHAR2,
                                        p_delivery_point_id VARCHAR2,
                                        p_product_id VARCHAR2,
                                        p_alloc_no NUMBER,
                                        p_qty_status VARCHAR2,
                                        p_processing_period DATE,
                                        p_uom1_code VARCHAR2,
                                        p_price_object_id VARCHAR2,
                                        p_period_start_date DATE,
                                        p_period_end_date DATE,
                                        p_unique_key_1 VARCHAR2,
                                        p_unique_key_2 VARCHAR2,
                                        p_li_unique_key_1 VARCHAR2,
                                        p_li_unique_key_2 VARCHAR2,
                                        p_ifac_tt_conn_code VARCHAR2,
                                        p_ifac_li_conn_code VARCHAR2,
                                        p_Line_Item_Based_Type VARCHAR2,
                                        p_Line_Item_Type VARCHAR2)
IS
BEGIN

  UPDATE ifac_sales_qty isq
     SET isq.alloc_no_max_ind = 'N'
   WHERE isq.contract_id = p_contract_id
     AND isq.vendor_id = p_vendor_id
     AND NVL(isq.customer_id, '$NULL$') = NVL(p_customer_id, '$NULL$')
     AND isq.profit_center_id = p_field_id
     AND isq.price_concept_code = p_price_concept_code
     AND isq.delivery_point_id = p_delivery_point_id
     AND isq.product_id = p_product_id
     AND isq.processing_period = p_processing_period
     AND isq.period_start_date = p_period_start_date
     AND isq.period_end_date = p_period_end_date
     AND isq.line_item_based_type = p_line_item_based_type
     AND nvl(isq.Line_Item_type,'X') = nvl(p_Line_Item_Type,'X')
     AND isq.uom1_code = p_uom1_code
     --If New is final will override Provisional
     AND NVL(isq.price_object_id,'X') =
                    CASE WHEN (p_qty_status = 'FINAL' AND isq.qty_status = 'PROV') or (p_qty_status = 'PPA' AND isq.qty_status != 'PPA') THEN
                      NVL(isq.price_object_id,'X')
                    ELSE
                      NVL(p_price_object_id,'X')
                    END
     AND NVL(isq.unique_key_1,'X') = NVL(p_unique_key_1,'X')
     AND NVL(isq.unique_key_2,'X') = NVL(p_unique_key_2,'X')
     AND nvl(isq.ifac_tt_conn_code,'X') = nvl(p_ifac_tt_conn_code,'X')
     AND nvl(isq.ifac_li_conn_code,'X') = nvl(p_ifac_li_conn_code,'X')
     --If Final set all Prov to ind = 'N', if PPA set all to = 'N'
     AND (
         (isq.alloc_no < p_alloc_no AND isq.qty_status = p_qty_status)
         OR
         (  (p_qty_status = 'FINAL' AND isq.qty_status = 'PROV')) OR (p_qty_status = 'PPA' AND isq.qty_status != 'PPA') )
     --Li_Unique_Key 1 and 2 are for other line items only.
     AND nvl(isq.Li_Unique_Key_1,'$NULL$') = case isq.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(isq.Li_Unique_Key_1,'$NULL$') else nvl(p_Li_Unique_Key_1,'$NULL$') end
     AND nvl(isq.Li_Unique_Key_2,'$NULL$') = case isq.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(isq.Li_Unique_Key_2,'$NULL$') else nvl(p_Li_Unique_Key_2,'$NULL$') end;

END UpdatePeriodIfacMaxAllocInd_P;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ReceiveSalesQtyRecord
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ReceiveSalesQtyRecord(p_Rec     IFAC_SALES_QTY%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate -- run time
   )
--</EC-DOC>
 IS

  isqRec                ifac_sales_qty%ROWTYPE := NULL;
  ll_original_ifac_data CLOB;

BEGIN

  /*
  If this is a PPA (qty status) record, look for the document setup with the PPA document concept.
    If this is a record for a contract with the "Multi Period Document" Documennt setup, choose this one.
  */

  -- Implementing "INSTEAD OF" User Exit
  IF ue_inbound_interface.isReceiveSalesQtyRecordUEE = 'TRUE' THEN
    ue_inbound_interface.ReceiveSalesQtyRecord(p_Rec, p_user, p_daytime);
  ELSE
    isqRec := p_Rec; -- enable override of values

    -- Implementing "PRE" User Exit
    IF ue_inbound_interface.isReceiveSalesQtyRecPreUEE = 'TRUE' THEN
      ue_inbound_interface.ReceiveSalesQtyRecordPre(isqRec, p_user, p_daytime);
    END IF;

     -- Set source entry no (pk)
     isqRec.Source_Entry_No := ecdp_system_key.assignNextNumber('IFAC_SALES_QTY');

     -- Start a new log
     WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, NULL, ec_contract.object_id_by_uk(getMappingCode(isqRec.contract_code, 'CONTRACT', p_daytime)), isqRec.Source_Entry_No, TRUE);

     ll_original_ifac_data := EncodeOriginalSalesQtyRecord_P(isqRec);
     -- Resolve ifac record values
     isqRec := ResolveSalesQtyRecord_P(
        isqRec,
        NVL(trunc(isqRec.processing_period,'MM'), nvl(trunc(isqRec.period_start_date,'MM'), Ecdp_Timestamp.getCurrentSysdate)));

     -- Set allocation number. If one of the id's have not been resolved, the alloc_no will not be set.
     IF p_rec.alloc_no IS NOT NULL AND isqRec.contract_id IS NOT NULL AND
       isqRec.vendor_id IS NOT NULL AND isqRec.product_id IS NOT NULL AND
                                             isqRec.delivery_point_id IS NOT NULL AND
                                             isqRec.profit_center_id IS NOT NULL THEN

       isqRec.alloc_no := p_rec.alloc_no;
     ELSE
       isqRec.alloc_no := GetNextPeriodAllocNo(isqRec.contract_id,
                                               isqRec.vendor_id,
                                               isqRec.customer_id,
                                               isqRec.product_id,
                                               isqRec.delivery_point_id,
                                               isqRec.profit_center_id,
                                               isqRec.price_concept_code,
                                               isqRec.Qty_Status,
                                               isqRec.Uom1_Code,
                                               isqRec.Price_Object_Id,
                                               isqRec.Unique_Key_1,
                                               isqRec.Unique_Key_2,
                                               isqRec.Li_Unique_Key_1,
                                               isqRec.Li_Unique_Key_2,
                                               isqRec.Processing_Period,
                                               isqRec.Period_Start_Date,
                                               isqRec.Period_End_Date,
                                               isqRec.ifac_tt_conn_code,
                                               isqRec.ifac_li_conn_code,
                                               isqRec.Line_Item_Based_Type,
                                               isqRec.Line_Item_Type);
     END IF;

     isqRec.Original_Ifac_Data := ll_original_ifac_data;

     isqRec.trans_key_set_ind := 'N';
     isqRec.alloc_no_max_ind := 'Y';
     isqRec.ignore_ind := NVL(isqRec.ignore_ind, 'N');
     WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'Max Alloc is ' || case nvl(isqRec.alloc_no,-999999) when -999999 then 'NULL' else to_char(isqRec.alloc_no) end);
     if isqRec.Qty1 != 0 then
        isqRec.Unit_Price := nvl(isqRec.Unit_Price, isqRec.Pricing_Value/isqRec.Qty1);
     END IF;

     INSERT INTO Ifac_Sales_Qty VALUES isqRec;

     -- Set alloc no max ind = 'N' on lower allocs
     UpdatePeriodIfacMaxAllocInd_P(isqRec.Contract_Id,
                                   isqRec.Vendor_Id,
                                   isqRec.Customer_Id,
                                   isqRec.Profit_Center_Id,
                                   isqRec.Price_Concept_Code,
                                   isqRec.Delivery_Point_Id,
                                   isqRec.Product_Id,
                                   isqRec.Alloc_No,
                                   isqRec.Qty_Status,
                                   isqRec.Processing_Period,
                                   isqRec.Uom1_Code,
                                   isqRec.Price_Object_Id,
                                   isqRec.Period_Start_Date,
                                   isqRec.Period_End_Date,
                                   isqRec.Unique_Key_1,
                                   isqRec.Unique_Key_2,
                                   isqRec.Li_Unique_Key_1,
                                   isqRec.Li_Unique_Key_2,
                                   isqRec.ifac_tt_conn_code,
                                   isqRec.ifac_li_conn_code,
                                   isqRec.Line_Item_Based_Type,
                                   isqRec.Line_Item_Type);

     -- Implementing "POST" User Exit
     IF ue_inbound_interface.isReceiveSalesQtyRecPostUEE = 'TRUE' THEN
       ue_inbound_interface.ReceiveSalesQtyRecordPost(isqRec, p_user, p_daytime);
     END IF;

     WriteRevnLogInterface_P(ECDP_REVN_LOG.LOG_STATUS_SUCCESS);

   END IF; -- Is "Instead of" UserExit enabled?
END ReceiveSalesQtyRecord;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ReceiveCargoQtyRecord
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ReceiveCargoQtyRecord(
   p_Rec       Ifac_Cargo_Value%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate -- run time
   )
--</EC-DOC>
IS

  icvRec Ifac_Cargo_Value%ROWTYPE;
  ll_original_ifac_data CLOB;

BEGIN


  -- Implementing "INSTEAD OF" User Exit
  IF ue_inbound_interface.isReceiveCargoQtyRecordUEE = 'TRUE' THEN

     ue_inbound_interface.ReceiveCargoQtyRecord(p_Rec, p_user, p_daytime);


  ELSE

     icvRec := p_Rec; -- enable override of values



     -- Implementing "PRE" User Exit
     IF ue_inbound_interface.isReceiveCargoQtyRecPreUEE = 'TRUE' THEN

        ue_inbound_interface.ReceiveCargoQtyRecordPre(icvRec, p_user, p_daytime);

     END IF;

     -- Set source entry no (pk)
     icvRec.Source_Entry_No := ecdp_system_key.assignNextNumber('IFAC_CARGO_VALUE');
     -- Start a new log
     WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, NULL, ec_contract.object_id_by_uk(getMappingCode(p_Rec.contract_code, 'CONTRACT', NVL(trunc(icvRec.Point_Of_Sale_Date,'MM'), p_daytime))), icvRec.Source_Entry_No, TRUE);

     ll_original_ifac_data := EncodeOriginalCargoRecord_P(icvRec);

     -- Resolve ifac record values
     icvRec := ResolveCargoRecord_P(
        icvRec,
        NVL(trunc(icvRec.point_of_sale_date, 'MM'), nvl(trunc(icvRec.delivery_date, 'MM'), nvl(trunc(icvRec.loading_date, 'MM'), Ecdp_Timestamp.getCurrentSysdate))));

    -- Set allocation number. If one of the id's have not been resolved, the alloc_no will not be set.
    IF p_rec.alloc_no IS NOT NULL AND icvRec.contract_id IS NOT NULL AND
                                      icvRec.vendor_id IS NOT NULL AND
                                      icvRec.Cargo_No IS NOT NULL AND
                                      icvRec.Parcel_No IS NOT NULL AND
                                      icvRec.Qty_Type IS NOT NULL AND
                                      icvRec.profit_center_id IS NOT NULL AND
                                      icvRec.Price_Concept_Code IS NOT NULL AND
                                      icvRec.Product_Id IS NOT NULL THEN

      icvRec.alloc_no := p_rec.alloc_no;

    ELSE

      icvRec.alloc_no := GetNextCargoAllocNo(icvRec.contract_id,
                                             icvRec.vendor_id,
                                             icvRec.customer_id,
                                             icvRec.cargo_no,
                                             icvRec.parcel_no,
                                             icvRec.qty_type,
                                             icvRec.profit_center_id,
                                             icvRec.price_concept_code,
                                             icvRec.Product_Id,
                                             icvRec.Uom1_Code,
                                             icvRec.Price_Object_Id,
                                             icvRec.Li_Unique_Key_1,
                                             icvRec.Li_Unique_Key_2,
                                             icvRec.ifac_tt_conn_code,
                                             icvRec.ifac_li_conn_code,
                                             icvRec.Line_Item_Based_Type,
                                             icvRec.Line_Item_Type);
    END IF;

    icvRec.Original_Ifac_Data := ll_original_ifac_data;
    icvRec.trans_key_set_ind := 'N';
    icvRec.alloc_no_max_ind := 'Y';
    icvRec.ignore_ind := NVL(icvRec.ignore_ind, 'N');
    WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'Max Alloc is ' || case nvl(icvRec.alloc_no,-999999) when -999999 then 'NULL' else to_char(icvRec.alloc_no) end);

    icvRec.Unit_Price := nvl(icvRec.Unit_Price, icvRec.Pricing_Value/icvRec.Net_Qty1);

    INSERT INTO Ifac_Cargo_Value VALUES icvRec;

    -- Update previous allocs of the same record, set alloc_no_max_ind = 'N'
    UpdateCargoIfacMaxAllocInd_P(icvRec.Source_Entry_No);

    -- Implementing "POST" User Exit
    IF ue_inbound_interface.isReceiveCargoQtyRecPostUEE = 'TRUE' THEN

      ue_inbound_interface.ReceiveCargoQtyRecordPost(icvRec, p_user, p_daytime);

    END IF;
    WriteRevnLogInterface_P(ECDP_REVN_LOG.LOG_STATUS_SUCCESS);

  END IF; -- "Instead of" User exit enabled?

END ReceiveCargoQtyRecord;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ReceiveIfacDocRecord
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ReceiveIfacDocRecord(
   p_Rec_doc   IFAC_DOCUMENT%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate -- run time
   )
--</EC-DOC>
IS

  lrec_doc ifac_document%ROWTYPE;

BEGIN

  WriteInterfaceLog_P('IFAC_DOCUMENT', 'START ReceiveIfacDocRecord. Contract: ' || p_rec_doc.contract_code || ', Document Date: ' || p_rec_doc.daytime || ', Ext Doc Key: ' || p_rec_doc.ext_doc_key, 'INFO');


  -- Implementing "INSTEAD OF" User Exit
  IF ue_inbound_interface.isReceiveIfacDocRecordUEE = 'TRUE' THEN


    ue_inbound_interface.ReceiveIfacDocRecord(p_Rec_doc, p_user, p_daytime);

  ELSE

     lrec_doc := p_Rec_doc; -- Enable override of values

     -- Implementing "PRE" User Exit
     IF ue_inbound_interface.isReceiveIfacDocRecPreUEE = 'TRUE' THEN

        ue_inbound_interface.ReceiveIfacDocRecordPre(lrec_doc, p_user, p_daytime);

        END IF;

     -- Map external with internal codes
     lrec_doc.contract_code               := getMappingCode(p_Rec_doc.contract_code, 'CONTRACT', lrec_doc.daytime); -- EC Object
     lrec_doc.contract_doc_code           := getMappingCode(p_Rec_doc.contract_Doc_Code, 'CONTRACT_DOC', lrec_doc.daytime); -- EC Object
     lrec_doc.contract_area_code          := getMappingCode(p_Rec_doc.contract_area_code, 'CONTRACT_AREA', lrec_doc.daytime); -- EC Object
     lrec_doc.contract_group_code         := getMappingCode(p_Rec_doc.contract_group_code, 'CONTRACT_GROUP', lrec_doc.daytime); -- EC Object
     lrec_doc.contract_term_code          := getMappingCode(p_Rec_doc.contract_term_code, 'CONTRACT_TERM', lrec_doc.daytime); -- EC Object
     lrec_doc.payment_scheme_code         := getMappingCode(p_Rec_doc.payment_scheme_code, 'PAYMENT_SCHEME', lrec_doc.daytime); -- EC Object
     lrec_doc.payment_term_code           := getMappingCode(p_Rec_doc.payment_term_code, 'PAYMENT_TERM', lrec_doc.daytime); -- EC Object
     lrec_doc.payment_cal_coll_code       := getMappingCode(p_Rec_doc.payment_cal_coll_code, 'CALENDAR_COLLECTION', lrec_doc.daytime); -- EC Object
     lrec_doc.payment_term_base_code      := getMappingCode(p_Rec_doc.payment_term_base_code, 'PAYMENT_TERM_BASE', lrec_doc.daytime); -- EC Code
     lrec_doc.booking_currency_code       := getMappingCode(p_Rec_doc.booking_currency_code, 'CURRENCY', lrec_doc.daytime); -- EC Object
     lrec_doc.memo_currency_code          := getMappingCode(p_Rec_doc.memo_currency_code, 'CURRENCY', lrec_doc.daytime); -- EC Object
     lrec_doc.doc_date_cal_coll_code      := getMappingCode(p_Rec_doc.doc_date_cal_coll_code, 'CALENDAR_COLLECTION', lrec_doc.daytime); -- EC Object
     lrec_doc.doc_date_term_code          := getMappingCode(p_Rec_doc.doc_date_term_code, 'DOC_DATE_TERM', lrec_doc.daytime); -- EC Object
     lrec_doc.doc_received_base_code      := getMappingCode(p_Rec_doc.doc_received_base_code, 'DOC_RECEIVED_BASE', lrec_doc.daytime); -- EC Code
     lrec_doc.doc_received_term_code      := getMappingCode(p_Rec_doc.doc_received_term_code, 'DOC_RECEIVED_TERM', lrec_doc.daytime); -- EC Object
     lrec_doc.doc_rec_cal_coll_code       := getMappingCode(p_Rec_doc.doc_rec_cal_coll_code, 'CALENDAR_COLLECTION', lrec_doc.daytime); -- EC Object
     lrec_doc.document_concept            := getMappingCode(p_Rec_doc.document_concept, 'DOCUMENT_CONCEPT', lrec_doc.daytime); -- EC Code
     lrec_doc.document_type               := getMappingCode(p_Rec_doc.document_type, 'DOCUMENT_TYPE', lrec_doc.daytime); -- EC Code
     lrec_doc.price_basis                 := getMappingCode(p_Rec_doc.price_basis, 'PRICE_BASIS', lrec_doc.daytime); -- EC Code
     lrec_doc.status_code                 := getMappingCode(p_Rec_doc.status_code, 'STATUS_CODE', lrec_doc.daytime); -- EC Code


     -- Validate Objects
     IF ValidateInterfacedECObject(lrec_doc.Contract_Id, ec_contract.object_id_by_uk(lrec_doc.contract_code), lrec_doc.contract_code, 'CONTRACT', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.Contract_Id := NULL;
        ELSE
         lrec_doc.Contract_Id := NVL(lrec_doc.Contract_Id,ec_contract.object_id_by_uk(lrec_doc.contract_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_doc.contract_doc_id, ec_contract_doc.object_id_by_uk(lrec_doc.contract_doc_code), lrec_doc.contract_doc_code, 'CONTRACT_DOC', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.contract_doc_id := NULL;
       ELSE
         lrec_doc.contract_doc_id := NVL(lrec_doc.contract_doc_id,ec_contract_doc.object_id_by_uk(lrec_doc.contract_doc_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_doc.contract_area_id, ec_contract_area.object_id_by_uk(lrec_doc.contract_area_code), lrec_doc.contract_area_code, 'CONTRACT_AREA', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.contract_area_id := NULL;
       ELSE
         lrec_doc.contract_area_id := NVL(lrec_doc.contract_area_id,ec_contract_area.object_id_by_uk(lrec_doc.contract_area_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_doc.contract_group_id, ec_calc_collection.object_id_by_uk(lrec_doc.contract_group_code), lrec_doc.contract_group_code, 'CONTRACT_GROUP', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.contract_group_id := NULL;
       ELSE
         lrec_doc.contract_group_id := NVL(lrec_doc.contract_group_id,ec_calc_collection.object_id_by_uk(lrec_doc.contract_group_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_doc.payment_scheme_id, ec_payment_scheme.object_id_by_uk(lrec_doc.payment_scheme_code), lrec_doc.payment_scheme_code, 'PAYMENT_SCHEME', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.payment_scheme_id := NULL;
       ELSE
         lrec_doc.payment_scheme_id := NVL(lrec_doc.payment_scheme_id,ec_payment_scheme.object_id_by_uk(lrec_doc.payment_scheme_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_doc.payment_term_id, ec_payment_term.object_id_by_uk(lrec_doc.payment_term_code), lrec_doc.payment_term_code, 'PAYMENT_TERM', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.payment_term_id := NULL;
       ELSE
         lrec_doc.payment_term_id := NVL(lrec_doc.payment_term_id,ec_payment_term.object_id_by_uk(lrec_doc.payment_term_code));
    END IF;
     IF ValidateInterfacedECObject(lrec_doc.payment_cal_coll_id, ec_calendar_collection.object_id_by_uk(lrec_doc.payment_cal_coll_code), lrec_doc.payment_cal_coll_code, 'CALENDAR_COLLECTION', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.payment_cal_coll_id := NULL;
       ELSE
         lrec_doc.payment_cal_coll_id := NVL(lrec_doc.payment_cal_coll_id,ec_calendar_collection.object_id_by_uk(lrec_doc.payment_cal_coll_code));
    END IF;
     IF ValidateInterfacedECObject(lrec_doc.booking_currency_id, ec_currency.object_id_by_uk(lrec_doc.booking_currency_code), lrec_doc.booking_currency_code, 'CURRENCY', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.booking_currency_id := NULL;
       ELSE
         lrec_doc.booking_currency_id := NVL(lrec_doc.booking_currency_id,ec_currency.object_id_by_uk(lrec_doc.booking_currency_code));
    END IF;
     IF ValidateInterfacedECObject(lrec_doc.memo_currency_id, ec_currency.object_id_by_uk(lrec_doc.memo_currency_code), lrec_doc.memo_currency_code, 'CURRENCY', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.memo_currency_id := NULL;
       ELSE
         lrec_doc.memo_currency_id := NVL(lrec_doc.memo_currency_id,ec_currency.object_id_by_uk(lrec_doc.memo_currency_code));
    END IF;
     IF ValidateInterfacedECObject(lrec_doc.doc_date_cal_coll_id, ec_calendar_collection.object_id_by_uk(lrec_doc.doc_date_cal_coll_code), lrec_doc.doc_date_cal_coll_code, 'CALENDAR_COLLECTION', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.doc_date_cal_coll_id := NULL;
       ELSE
         lrec_doc.doc_date_cal_coll_id := NVL(lrec_doc.doc_date_cal_coll_id,ec_calendar_collection.object_id_by_uk(lrec_doc.doc_date_cal_coll_code));
    END IF;
     IF ValidateInterfacedECObject(lrec_doc.doc_date_term_id, ec_doc_date_term.object_id_by_uk(lrec_doc.doc_date_term_code), lrec_doc.doc_date_term_code, 'DOC_DATE_TERM', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.doc_date_term_id := NULL;
       ELSE
         lrec_doc.doc_date_term_id := NVL(lrec_doc.doc_date_term_id,ec_doc_date_term.object_id_by_uk(lrec_doc.doc_date_term_code));
    END IF;
     IF ValidateInterfacedECObject(lrec_doc.doc_received_term_id, ec_doc_received_term.object_id_by_uk(lrec_doc.doc_received_term_code), lrec_doc.doc_received_term_code, 'DOC_RECEIVED_TERM', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.doc_received_term_id := NULL;
       ELSE
         lrec_doc.doc_received_term_id := NVL(lrec_doc.doc_received_term_id,ec_doc_received_term.object_id_by_uk(lrec_doc.doc_received_term_code));
    END IF;
     IF ValidateInterfacedECObject(lrec_doc.doc_rec_cal_coll_id, ec_calendar_collection.object_id_by_uk(lrec_doc.doc_rec_cal_coll_code), lrec_doc.doc_rec_cal_coll_code, 'CALENDAR_COLLECTION', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.doc_rec_cal_coll_id := NULL;
       ELSE
         lrec_doc.doc_rec_cal_coll_id := NVL(lrec_doc.doc_rec_cal_coll_id,ec_calendar_collection.object_id_by_uk(lrec_doc.doc_rec_cal_coll_code));
      END IF;
     -- TODO: Add missing objects...


     -- Validate EC Codes
     IF ValidateInterfacedECCode(lrec_doc.contract_term_code, 'CONTRACT_TERM', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.contract_term_code := NULL;
    END IF;
     IF ValidateInterfacedECCode(lrec_doc.document_concept, 'DOCUMENT_CONCEPT', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.document_concept := NULL;
      END IF;
     IF ValidateInterfacedECCode(lrec_doc.document_type, 'DOCUMENT_TYPE', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.document_type := NULL;
    END IF;
     IF ValidateInterfacedECCode(lrec_doc.price_basis, 'PRICE_BASIS_TYPE', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.price_basis := NULL;
        END IF;
     IF ValidateInterfacedECCode(lrec_doc.status_code, 'STREAM_ITEM_STATUS', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.status_code := NULL;
      END IF;
     IF ValidateInterfacedECCode(lrec_doc.doc_received_base_code, 'DOC_RECEIVED_BASE_CODE', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.doc_received_base_code := NULL;
    END IF;
     IF ValidateInterfacedECCode(lrec_doc.payment_term_base_code, 'PAYMENT_TERMS_BASE_CODE', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.payment_term_base_code := NULL;
    END IF;
     IF ValidateInterfacedECCode(lrec_doc.financial_code, 'FINANCIAL_CODE', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.financial_code := NULL;
    END IF;
     IF ValidateInterfacedECCode(lrec_doc.bank_details_level_code, 'BANK_DETAILS_LEVEL_CODE', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.bank_details_level_code := NULL;
    END IF;
     IF ValidateInterfacedECCode(lrec_doc.int_base_amount_src, 'INT_BASE_AMOUNT_SRC_CODE', 'IFAC_DOCUMENT') = 'N' THEN
       lrec_doc.int_base_amount_src := NULL;
    END IF;

     -- Get or validate document setup.
     -- If ds is not set by interface, the best match (if any) is returned.
     -- If ds is set by interface, it is validated and returned if valid.
     lrec_doc.contract_doc_id := GetIfacDocDocSetup(lrec_doc);
     lrec_doc.contract_doc_code := ec_contract_doc.object_code(lrec_doc.contract_doc_id);



     INSERT INTO Ifac_Document VALUES lrec_doc;


     -- Implementing "POST" User Exit
     IF ue_inbound_interface.isReceiveIfacDocRecPostUEE = 'TRUE' THEN

        ue_inbound_interface.ReceiveIfacDocRecordPost(lrec_doc, p_user, p_daytime);

      END IF;



  END IF; -- Is "Instead of" user exit enabled?


  WriteInterfaceLog_P('IFAC_DOCUMENT', 'END ReceiveIfacDocRecord. Contract: ' || p_rec_doc.contract_code || ', Document Date: ' || p_rec_doc.daytime || ', Ext Doc Key: ' || p_rec_doc.ext_doc_key, 'INFO');

END ReceiveIfacDocRecord;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ReceiveERPPostingRecord
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ReceiveERPPostingRecord(
   p_Rec       IFAC_ERP_POSTINGS%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate -- run time
   )
--</EC-DOC>
IS

  lrec_post ifac_erp_postings%ROWTYPE;

BEGIN

  WriteInterfaceLog_P('IFAC_ERP_POSTING', 'START ReceiveERPPostingRecord. Posting Key: ' || p_rec.fin_posting_key || ', Debit/Credit: ' || p_rec.fin_debit_credit_code || ', GL Account: ' || p_rec.fin_gl_account_code, 'INFO');


  -- Implementing "INSTEAD OF" User Exit
  IF ue_inbound_interface.isReceiveERPPostRecordUEE = 'TRUE' THEN

    ue_inbound_interface.ReceiveERPPostingRecord(p_Rec, p_user, p_daytime);

    ELSE

     lrec_post := p_Rec; -- enable override of values

     -- Implementing "PRE" User Exit
     IF ue_inbound_interface.isReceiveERPPostRecPreUEE = 'TRUE' THEN

        ue_inbound_interface.ReceiveERPPostingRecordPre(lrec_post, p_user, p_daytime);

    END IF;

     -- Set source entry no (pk)
     lrec_post.Source_Entry_No := ecdp_system_key.assignNextNumber('IFAC_ERP_POSTINGS');


     -- Map external with internal codes
     -- EC Objects
     lrec_post.booking_currency_code       := getMappingCode(lrec_post.booking_currency_code, 'CURRENCY', lrec_post.daytime);
     lrec_post.local_currency_code         := getMappingCode(lrec_post.local_currency_code, 'CURRENCY', lrec_post.daytime);
     lrec_post.fin_customer_code           := getMappingCode(lrec_post.fin_customer_code, 'CUSTOMER', lrec_post.daytime);
     lrec_post.fin_cost_object_code        := getMappingCode(lrec_post.fin_cost_object_code, 'COST_OBJECT', lrec_post.daytime);
     lrec_post.fin_gl_account_code         := getMappingCode(lrec_post.fin_gl_account_code, 'FIN_ACCOUNT', lrec_post.daytime);
     lrec_post.fin_payment_term_code       := getMappingCode(lrec_post.fin_payment_term_code, 'PAYMENT_TERM', lrec_post.daytime);
     lrec_post.fin_profit_center_code      := getMappingCode(lrec_post.fin_profit_center_code, 'FIELD', lrec_post.daytime);
     lrec_post.fin_vendor_code             := getMappingCode(lrec_post.fin_vendor_code, 'VENDOR', lrec_post.daytime);
     lrec_post.fin_wbs_code                := getMappingCode(lrec_post.fin_wbs_code, 'WBS', lrec_post.daytime);
     lrec_post.fin_revenue_order_code      := getMappingCode(lrec_post.fin_revenue_order_code, 'REVENUE_ORDER', lrec_post.daytime);
     lrec_post.fin_cost_center_code        := getMappingCode(lrec_post.fin_cost_center_code, 'COST_CENTER', lrec_post.daytime);
     lrec_post.fin_vat_code                := getMappingCode(lrec_post.fin_vat_code, 'VAT_CODE', lrec_post.daytime);
     lrec_post.for_payment_country_code    := getMappingCode(lrec_post.for_payment_country_code, 'COUNTRY', lrec_post.daytime);
     lrec_post.for_payment_bank_code       := getMappingCode(lrec_post.for_payment_bank_code, 'BANK', lrec_post.daytime);

     -- EC Codes
     lrec_post.fin_account_type            := getMappingCode(lrec_post.fin_account_type, 'FIN_ACCOUNT_TYPE', lrec_post.Daytime);
     lrec_post.fin_debit_credit_code       := getMappingCode(lrec_post.fin_debit_credit_code, 'ACCOUNT_CLASS_CODE', lrec_post.Daytime);
--     lrec_post.fin_document_type           := getMappingCode(lrec_post.fin_document_type, 'DOCUMENT_TYPE', lrec_post.Daytime);
     lrec_post.fin_transaction_type        := getMappingCode(lrec_post.fin_transaction_type, 'TRANSACTION_TYPE', lrec_post.Daytime);

     -- UOM
     lrec_post.Uom1_Code                   := getMappingCode(lrec_post.Uom1_Code, 'UOM', lrec_post.Daytime);


     -- Validate Objects
     IF ValidateInterfacedECObject(lrec_post.booking_currency_Id, ec_currency.object_id_by_uk(lrec_post.booking_currency_code), lrec_post.booking_currency_code, 'CURRENCY', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.booking_currency_Id := NULL;
       ELSE
         lrec_post.booking_currency_Id := NVL(lrec_post.booking_currency_Id,ec_currency.object_id_by_uk(lrec_post.local_currency_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_post.local_currency_Id, ec_currency.object_id_by_uk(lrec_post.local_currency_code), lrec_post.local_currency_code, 'CURRENCY', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.local_currency_id := NULL;
       ELSE
         lrec_post.local_currency_id := NVL(lrec_post.local_currency_id,ec_currency.object_id_by_uk(lrec_post.local_currency_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_post.fin_customer_Id, ec_company.object_id_by_uk(lrec_post.fin_customer_code,'CUSTOMER'), lrec_post.fin_customer_code, 'CUSTOMER', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_customer_id := NULL;
       ELSE
         lrec_post.fin_customer_id := NVL(lrec_post.fin_customer_id,ec_company.object_id_by_uk(lrec_post.fin_customer_code,'CUSTOMER'));
     END IF;
     IF ValidateInterfacedECObject(lrec_post.fin_cost_object_Id, ec_fin_cost_object.object_id_by_uk(lrec_post.fin_cost_object_code), lrec_post.fin_cost_object_code, 'COST_OBJECT', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_cost_object_Id := NULL;
       ELSE
         lrec_post.fin_cost_object_Id := NVL(lrec_post.fin_cost_object_Id,ec_fin_cost_object.object_id_by_uk(lrec_post.fin_cost_object_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_post.fin_gl_account_id, ec_fin_account.object_id_by_uk(lrec_post.fin_gl_account_code), lrec_post.fin_gl_account_code, 'FIN_ACCOUNT', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_gl_account_Id := NULL;
       ELSE
         lrec_post.fin_gl_account_Id := NVL(lrec_post.fin_gl_account_Id,ec_fin_account.object_id_by_uk(lrec_post.fin_gl_account_code));
  END IF;
     IF ValidateInterfacedECObject(lrec_post.fin_payment_term_Id, ec_payment_term.object_id_by_uk(lrec_post.fin_payment_term_code), lrec_post.fin_payment_term_code, 'PAYMENT_TERM', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_payment_term_Id := NULL;
       ELSE
         lrec_post.fin_payment_term_Id := NVL(lrec_post.fin_payment_term_Id,ec_payment_term.object_id_by_uk(lrec_post.fin_payment_term_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_post.fin_profit_center_id, ec_field.object_id_by_uk(lrec_post.fin_profit_center_code,'FIELD'), lrec_post.fin_profit_center_code, 'FIELD', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_profit_center_Id := NULL;
       ELSE
         lrec_post.fin_profit_center_Id := NVL(lrec_post.fin_profit_center_Id,ec_field.object_id_by_uk(lrec_post.fin_profit_center_code,'FIELD'));
     END IF;
     IF ValidateInterfacedECObject(lrec_post.fin_vendor_Id, ec_company.object_id_by_uk(lrec_post.fin_vendor_code, 'VENDOR'), lrec_post.fin_vendor_code, 'VENDOR', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_vendor_Id := NULL;
       ELSE
         lrec_post.fin_vendor_Id := NVL(lrec_post.fin_vendor_Id,ec_company.object_id_by_uk(lrec_post.fin_vendor_code, 'VENDOR'));
     END IF;
     IF ValidateInterfacedECObject(lrec_post.fin_wbs_Id, ec_fin_wbs.object_id_by_uk(lrec_post.fin_wbs_code), lrec_post.fin_wbs_code, 'FIN_WBS', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_wbs_Id := NULL;
       ELSE
         lrec_post.fin_wbs_Id := NVL(lrec_post.fin_wbs_Id,ec_fin_wbs.object_id_by_uk(lrec_post.fin_wbs_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_post.fin_revenue_order_Id, ec_fin_revenue_order.object_id_by_uk(lrec_post.fin_revenue_order_code), lrec_post.fin_revenue_order_code, 'FIN_REVENUE_ORDER', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_revenue_order_Id := NULL;
       ELSE
         lrec_post.fin_revenue_order_Id := NVL(lrec_post.fin_revenue_order_Id,ec_fin_revenue_order.object_id_by_uk(lrec_post.fin_revenue_order_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_post.fin_cost_center_Id, ec_fin_cost_center.object_id_by_uk(lrec_post.fin_cost_center_code), lrec_post.fin_cost_center_code, 'FIN_COST_CENTER', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_cost_center_Id := NULL;
       ELSE
         lrec_post.fin_cost_center_Id := NVL(lrec_post.fin_cost_center_Id,ec_fin_cost_center.object_id_by_uk(lrec_post.fin_cost_center_code));
    END IF;
     IF ValidateInterfacedECObject(lrec_post.fin_vat_Id, ec_vat_code.object_id_by_uk(lrec_post.fin_vat_code), lrec_post.fin_vat_code, 'VAT_CODE', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_vat_Id := NULL;
       ELSE
         lrec_post.fin_vat_Id := NVL(lrec_post.fin_vat_Id,ec_vat_code.object_id_by_uk(lrec_post.fin_vat_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_post.for_payment_country_code, ec_geographical_area.object_id_by_uk('COUNTRY',lrec_post.for_payment_country_code), lrec_post.for_payment_country_code, 'COUNTRY', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.for_payment_country_id := NULL;
       ELSE
         lrec_post.for_payment_country_id := NVL(lrec_post.for_payment_country_id,ec_geographical_area.object_id_by_uk('COUNTRY',lrec_post.for_payment_country_code));
     END IF;
     IF ValidateInterfacedECObject(lrec_post.for_payment_bank_code, ec_bank.object_id_by_uk(lrec_post.for_payment_bank_code), lrec_post.for_payment_bank_code, 'BANK', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.for_payment_bank_id := NULL;
       ELSE
         lrec_post.for_payment_bank_id := NVL(lrec_post.for_payment_bank_id,ec_bank.object_id_by_uk(lrec_post.for_payment_bank_code));
     END IF;

     -- Validate EC Codes
     IF ValidateInterfacedECCode(lrec_post.fin_account_type, 'FIN_ACCOUNT_TYPE', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_account_type := NULL;
        END IF;
     IF ValidateInterfacedECCode(lrec_post.fin_debit_credit_code, 'ACCOUNT_CLASS_CODE', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_debit_credit_code := NULL;
        END IF;
--     IF ValidateInterfacedECCode(lrec_post.fin_document_type, 'DOCUMENT_TYPE', 'IFAC_ERP_POSTINGS') = 'N' THEN
--       lrec_post.fin_document_type := NULL;
--     END IF;
     IF ValidateInterfacedECCode(lrec_post.fin_transaction_type, 'TRANSACTION_TYPE', 'IFAC_ERP_POSTINGS') = 'N' THEN
       lrec_post.fin_transaction_type := NULL;
        END IF;
     -- etc...
/*
TODO: Are these also EC-codes?
controling_area
fin_account_type
fin_business_area
fin_equity_group
fin_equity_type
fin_joint_venture
*/

     INSERT INTO Ifac_Erp_Postings VALUES lrec_post;

     -- Implementing "POST" User Exit
     IF ue_inbound_interface.isReceiveERPPostRecPostUEE = 'TRUE' THEN

        ue_inbound_interface.ReceiveERPPostingRecordPost(lrec_post, p_user, p_daytime);

    END IF;

  END IF; -- Is Instead of user exit enabled?

  WriteInterfaceLog_P('IFAC_ERP_POSTING', 'END ReceiveERPPostingRecord. Posting Key: ' || p_rec.fin_posting_key || ', Debit/Credit: ' || p_rec.fin_debit_credit_code || ', GL Account: ' || p_rec.fin_gl_account_code, 'INFO');

END ReceiveERPPostingRecord;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION ValidateInterfacedECCode(p_code       VARCHAR2, -- EC Code
                                  p_code_type  VARCHAR2, -- EC Code Type
                                  p_table_name VARCHAR2  -- Interface table
)RETURN VARCHAR2
IS

  lv2_ret_val VARCHAR2(1) := 'Y';
  lv2_err_msg VARCHAR2(320);

BEGIN

   IF p_code IS NOT NULL THEN
     IF nvl(ec_prosty_codes.is_active(p_code, p_code_type),'N') = 'N' THEN

        lv2_err_msg := '[' || p_code || '] is not recognized as a valid or active EC Code of type ' || p_code_type;
        lv2_ret_val := 'N';
        WriteInterfaceLog_P(p_table_name, lv2_err_msg, 'DEBUG');

     END IF;
      END IF;

   RETURN lv2_ret_val;

END ValidateInterfacedECCode;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION ValidateInterfacedECObject(p_object_id       VARCHAR2, -- EC object id, directly from interface
                                    p_object_id_by_uk VARCHAR2, -- EC object id, resolved by object_code
                                    p_object_code     VARCHAR2, -- EC object code
                                    p_class_name      VARCHAR2, -- EC object class
                                    p_table_name      VARCHAR2  -- Interface table
)RETURN VARCHAR2
IS

  lv2_ret_val VARCHAR2(1) := 'Y';
  lv2_err_msg VARCHAR2(320);
  lb_found BOOLEAN := FALSE;

  CURSOR c_obj(cp_object_id VARCHAR2, cp_class_name VARCHAR2) IS
    SELECT o.object_id
      FROM objects o
     WHERE o.object_id = cp_object_id
       AND o.class_name = cp_class_name;

BEGIN

  IF p_object_id IS NOT NULL THEN

    FOR rsObj IN c_obj(p_object_id, p_class_name) LOOP
      lb_found := TRUE;
    END LOOP;

    IF NOT lb_found THEN
      lv2_err_msg := '[' || p_object_id || '] is not recognized as a valid EC object id for class ' || p_class_name;
      lv2_ret_val := 'N';
      WriteInterfaceLog_P(p_table_name, lv2_err_msg, 'DEBUG');
    END IF;

  ELSIF p_object_id IS NULL AND p_object_code IS NOT NULL THEN

    IF p_object_id_by_uk IS NULL THEN
       lv2_err_msg := '[' || p_object_code || '] is not recognized as a valid EC object of class ' || p_class_name;
       lv2_ret_val := 'N';
       WriteInterfaceLog_P(p_table_name, lv2_err_msg, 'DEBUG');
      END IF;
    END IF;

  RETURN lv2_ret_val;

END ValidateInterfacedECObject;
-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE WriteInterfaceLog(p_table_name VARCHAR2,
                            p_text       VARCHAR2,
                            p_log_level  VARCHAR2
)
IS
BEGIN

  IF p_table_name IS NOT NULL AND p_text IS NOT NULL THEN

    INSERT INTO interface_log(log_item_no, table_name, daytime, log_level, text)
    VALUES (ecdp_system_key.assignNextNumber('INTERFACE_LOG'), p_table_name, Ecdp_Timestamp.getCurrentSysdate, nvl(p_log_level, 'INFO'), SUBSTR(p_text, 1, 2000));

    END IF;

END WriteInterfaceLog;



-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isObjectInObjectList
(
	p_object_id                           VARCHAR2,
	p_object_list_id                      VARCHAR2,
	p_daytime                             DATE
)
RETURN VARCHAR2
IS
	CURSOR c_object_list(cp_object_list_id VARCHAR2, cp_object_class VARCHAR2, cp_object_code VARCHAR2, cp_daytime DATE)
	IS
		SELECT object_list_setup.object_id
		FROM object_list_setup
		WHERE object_list_setup.GENERIC_CLASS_NAME = cp_object_class
			AND object_list_setup.GENERIC_OBJECT_CODE = cp_object_code
			AND object_list_setup.object_id = cp_object_list_id
			AND object_list_setup.daytime <= cp_daytime
      AND nvl(object_list_setup.end_date,cp_daytime+1) > cp_daytime ;

	lv2_ret_val VARCHAR2(1) := 'N';
	lv2_generic_class_name OBJECT_LIST_SETUP.GENERIC_CLASS_NAME%TYPE;
	lv2_generic_object_code OBJECT_LIST_SETUP.GENERIC_OBJECT_CODE%TYPE;

BEGIN
    lv2_generic_class_name := ecdp_objects.GetObjClassName(p_object_id);
    lv2_generic_object_code := ecdp_objects.GetObjCode(p_object_id);

	FOR rsFG IN c_object_list(p_object_list_id, lv2_generic_class_name, lv2_generic_object_code, p_daytime) LOOP
		lv2_ret_val := 'Y';
	END LOOP;

	RETURN lv2_ret_val;

END isObjectInObjectList;

-----------------------------------------------------------------------------------------------------------------------------


FUNCTION isObjectCodeinObjectList
(
	p_object_code                         VARCHAR2,
	p_object_list_id                      VARCHAR2,
	p_daytime                             DATE
)
RETURN VARCHAR2
IS
	CURSOR c_object_list(cp_object_list_id VARCHAR2, cp_object_code VARCHAR2, cp_daytime DATE)
	IS
		SELECT object_list_setup.object_id
		FROM object_list_setup
		WHERE object_list_setup.GENERIC_OBJECT_CODE = cp_object_code
			AND object_list_setup.object_id = cp_object_list_id
			AND object_list_setup.daytime <= cp_daytime
      AND nvl(object_list_setup.end_date,cp_daytime+1) > cp_daytime ;

	lv2_ret_val VARCHAR2(1) := 'N';

BEGIN

	FOR rsFG IN c_object_list(p_object_list_id, p_object_code, p_daytime) LOOP
		lv2_ret_val := 'Y';
	END LOOP;

	RETURN lv2_ret_val;

END isObjectCodeinObjectList;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION ReAnalyseSalesQtyRecord(p_Rec IFAC_SALES_QTY%ROWTYPE, p_user VARCHAR2 DEFAULT USER) RETURN IFAC_SALES_QTY%ROWTYPE
IS
    lrec_rsPd IFAC_SALES_QTY%ROWTYPE;

    CURSOR c_log(cp_contract_id VARCHAR2, cp_source_entry_no NUMBER) IS
      SELECT log_no, status
        FROM revn_log
       WHERE category = 'INTERFACE'
         AND contract_id = cp_contract_id
         AND value_1 = cp_source_entry_no;
BEGIN

    IF p_Rec.ORIGINAL_IFAC_DATA IS NOT NULL THEN
        -- Get the orignal ifac record and re-analyse it
        lrec_rsPd := Ecdp_Inbound_Interface.DecodeOriginalSalesQtyRecord(p_Rec.Original_Ifac_Data);

        -- Set columns that are not stored in the original data LOB
        lrec_rsPd.Qty1 := p_Rec.Qty1;
        lrec_rsPd.Qty2 := p_Rec.Qty2;
        lrec_rsPd.Qty3 := p_Rec.Qty3;
        lrec_rsPd.Qty4 := p_Rec.Qty4;
        lrec_rsPd.Qty5 := p_Rec.Qty5;
        lrec_rsPd.Qty6 := p_Rec.Qty6;
        lrec_rsPd.Uom1_Code := p_Rec.Uom1_Code;
        lrec_rsPd.Uom2_Code := p_Rec.Uom2_Code;
        lrec_rsPd.Uom3_Code := p_Rec.Uom3_Code;
        lrec_rsPd.Uom4_Code := p_Rec.Uom4_Code;
        lrec_rsPd.Uom5_Code := p_Rec.Uom5_Code;
        lrec_rsPd.Uom6_Code := p_Rec.Uom6_Code;
        lrec_rsPd.Unit_Price := p_Rec.Unit_Price;
        lrec_rsPd.STATUS := p_Rec.STATUS;
        lrec_rsPd.DESCRIPTION := p_Rec.DESCRIPTION;

        lrec_rsPd.LINE_ITEM_BASED_TYPE := p_Rec.Line_Item_Based_Type;
        lrec_rsPd.UNIT_PRICE_UNIT  := p_Rec.Unit_Price_Unit;
        lrec_rsPd.INT_TYPE  := p_Rec.Int_Type;
        lrec_rsPd.INT_BASE_AMOUNT := p_Rec.Int_Base_Amount;
        lrec_rsPd.INT_BASE_RATE := p_Rec.Int_Base_Rate;
        lrec_rsPd.INT_RATE_OFFSET := p_Rec.Int_Rate_Offset;
        lrec_rsPd.INT_FROM_DATE := p_Rec.Int_From_Date;
        lrec_rsPd.INT_TO_DATE := p_Rec.Int_To_Date;
        lrec_rsPd.Int_Compounding_Period := p_Rec.Int_Compounding_Period;
        lrec_rsPd.Li_Price_Object_Code := p_Rec.Li_Price_Object_Code;
        lrec_rsPd.PERCENTAGE_VALUE := p_Rec.Percentage_Value;
        lrec_rsPd.PERCENTAGE_BASE_AMOUNT := p_Rec.Percentage_Base_Amount;
        lrec_rsPd.PRICING_VALUE  := p_Rec.Pricing_Value;
        lrec_rsPd.LINE_ITEM_TYPE  := p_Rec.Line_Item_Type;

        lrec_rsPd.DATE_1 := p_Rec.DATE_1;
        lrec_rsPd.DATE_2 := p_Rec.DATE_2;
        lrec_rsPd.DATE_3 := p_Rec.DATE_3;
        lrec_rsPd.DATE_4 := p_Rec.DATE_4;
        lrec_rsPd.DATE_5 := p_Rec.DATE_5;
        lrec_rsPd.DATE_6 := p_Rec.DATE_6;
        lrec_rsPd.DATE_7 := p_Rec.DATE_7;
        lrec_rsPd.DATE_8 := p_Rec.DATE_8;
        lrec_rsPd.DATE_9 := p_Rec.DATE_9;
        lrec_rsPd.DATE_10 := p_Rec.DATE_10;
        lrec_rsPd.TEXT_1 := p_Rec.TEXT_1;
        lrec_rsPd.TEXT_2 := p_Rec.TEXT_2;
        lrec_rsPd.TEXT_3 := p_Rec.TEXT_3;
        lrec_rsPd.TEXT_4 := p_Rec.TEXT_4;
        lrec_rsPd.TEXT_5 := p_Rec.TEXT_5;
        lrec_rsPd.TEXT_6 := p_Rec.TEXT_6;
        lrec_rsPd.TEXT_7 := p_Rec.TEXT_7;
        lrec_rsPd.TEXT_8 := p_Rec.TEXT_8;
        lrec_rsPd.TEXT_9 := p_Rec.TEXT_9;
        lrec_rsPd.TEXT_10 := p_Rec.TEXT_10;
        lrec_rsPd.VALUE_1 := p_Rec.VALUE_1;
        lrec_rsPd.VALUE_2 := p_Rec.VALUE_2;
        lrec_rsPd.VALUE_3 := p_Rec.VALUE_3;
        lrec_rsPd.VALUE_4 := p_Rec.VALUE_4;
        lrec_rsPd.VALUE_5 := p_Rec.VALUE_5;
        lrec_rsPd.VALUE_6 := p_Rec.VALUE_6;
        lrec_rsPd.VALUE_7 := p_Rec.VALUE_7;
        lrec_rsPd.VALUE_8 := p_Rec.VALUE_8;
        lrec_rsPd.VALUE_9 := p_Rec.VALUE_9;
        lrec_rsPd.VALUE_10 := p_Rec.VALUE_10;
        lrec_rsPd.Object_Type := p_Rec.object_type;
        lrec_rsPd.Dist_Type := p_Rec.dist_type;
        lrec_rsPd.Pricing_Value := p_rec.pricing_value;
        lrec_rsPd.Source_Entry_No := p_Rec.Source_Entry_No;
        lrec_rsPd.Customer_Id := p_rec.customer_id; -- The overriden Customer id needs to be restored
        lrec_rsPd.Customer_code := p_rec.customer_code; -- The overriden Customer code needs to be restored

        -- Continue on existing log
        rec_RevnLogInterface := NULL;
        FOR rsLog IN c_log(ec_contract.object_id_by_uk(lrec_rsPd.Contract_Code), lrec_rsPd.Source_Entry_No) LOOP
            rec_RevnLogInterface.LOG_NO := rsLog.Log_No;
            rec_RevnLogInterface.LOG_STATUS := rsLog.Status;
        END LOOP;
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, '__________   Starting RE-analyse of Ifac Record   __________________________________________________');

        lrec_rsPd.Trans_Temp_Id_Ovrd := p_rec.trans_temp_id_ovrd; -- The overriden transaction template needs to be restored
        lrec_rsPd.Trans_Temp_Code_Ovrd := p_rec.trans_temp_code_ovrd; -- The overriden transaction template needs to be restored

        -- Resolve the record
        lrec_rsPd := Ecdp_Inbound_Interface.ResolveSalesQtyRecord_P(
            lrec_rsPd,
            NVL(trunc(lrec_rsPd.processing_period,'MM'), nvl(trunc(lrec_rsPd.period_start_date,'MM'), Ecdp_Timestamp.getCurrentSysdate)));

        -- Set other columns that should be set by the system
        lrec_rsPd.Alloc_No := p_Rec.Alloc_No;
        lrec_rsPd.trans_key_set_ind := CASE WHEN lrec_rsPd.Transaction_Key IS NULL THEN 'N' ELSE 'Y' END;
        lrec_rsPd.alloc_no_max_ind := p_Rec.alloc_no_max_ind;
        lrec_rsPd.ignore_ind := p_Rec.ignore_ind;
        lrec_rsPd.record_status := p_Rec.RECORD_STATUS;
        lrec_rsPd.created_by := p_rec.CREATED_BY;
        lrec_rsPd.created_date := p_rec.CREATED_DATE;
        lrec_rsPd.last_updated_by := CASE WHEN p_user IS NULL THEN USER ELSE p_user END;
        lrec_rsPd.last_updated_date := Ecdp_Timestamp.getCurrentSysdate();
        lrec_rsPd.rev_no := p_rec.rev_no;
        lrec_rsPd.rev_text := p_rec.rev_text;
        lrec_rsPd.approval_by := p_rec.approval_by;
        lrec_rsPd.approval_date := p_rec.approval_date;
        lrec_rsPd.approval_state := p_rec.approval_state;
        lrec_rsPd.rec_id := p_rec.rec_id;
        lrec_rsPd.original_ifac_data := p_rec.original_ifac_data; -- The original data needs to be stored

        -- If before the reanalysis there was a price object and this is a PPA record, that is pulling from preceding
        -- And wasn't able to find the preceding after the re analyse it should keep the same price object as before
        -- Will error later when checking PPA has a preceding transaction
        IF p_rec.price_object_id is not null and lrec_rsPd.Price_Object_Id is null and p_rec.qty_status = 'PPA' THEN
          IF ec_product_price_version.quantity_status(p_rec.price_object_id,p_rec.processing_period,'<=') != 'PPA' THEN
             lrec_rsPd.price_object_id := p_rec.price_object_id;
             lrec_rsPd.price_object_code := p_rec.price_object_code;

          END IF;
        END IF;

        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'Max Alloc is ' || case nvl(lrec_rsPd.alloc_no,-999999) when -999999 then 'NULL' else to_char(lrec_rsPd.alloc_no) end);
        WriteRevnLogInterface_P(ECDP_REVN_LOG.LOG_STATUS_SUCCESS);
    ELSE
        -- Fail-safe, should not happen if the update-script has been run
        lrec_rsPd := p_Rec;
    END IF;

    RETURN lrec_rsPd;

END ReAnalyseSalesQtyRecord;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION ReAnalyseCargoRecord(p_Rec IFAC_CARGO_VALUE%ROWTYPE, p_user VARCHAR2 DEFAULT USER) RETURN IFAC_CARGO_VALUE%ROWTYPE
IS
    lrec_rsPd ifac_cargo_value%ROWTYPE;

    CURSOR c_log(cp_contract_id VARCHAR2, cp_source_entry_no NUMBER) IS
      SELECT log_no, status
        FROM revn_log
       WHERE category = 'INTERFACE'
         AND contract_id = cp_contract_id
         AND value_1 = cp_source_entry_no;
BEGIN
    IF p_Rec.original_ifac_data IS NOT NULL THEN
        -- Get the orignal ifac record and re-analyse it
        lrec_rsPd := Ecdp_Inbound_Interface.DecodeOriginalCargoRecord(p_Rec.Original_Ifac_Data);

        -- Set columns that are not stored in the original data LOB
        lrec_rsPd.Net_Qty1 := p_Rec.Net_Qty1;
        lrec_rsPd.Grs_Qty1 := p_Rec.Grs_Qty1;
        lrec_rsPd.Net_Qty2 := p_Rec.Net_Qty2;
        lrec_rsPd.Grs_Qty2 := p_Rec.Grs_Qty2;
        lrec_rsPd.Net_Qty3 := p_Rec.Net_Qty3;
        lrec_rsPd.Grs_Qty3 := p_Rec.Grs_Qty3;

        lrec_rsPd.DATE_1 := p_Rec.DATE_1;
        lrec_rsPd.DATE_2 := p_Rec.DATE_2;
        lrec_rsPd.DATE_3 := p_Rec.DATE_3;
        lrec_rsPd.DATE_4 := p_Rec.DATE_4;
        lrec_rsPd.DATE_5 := p_Rec.DATE_5;
        lrec_rsPd.DATE_6 := p_Rec.DATE_6;
        lrec_rsPd.DATE_7 := p_Rec.DATE_7;
        lrec_rsPd.DATE_8 := p_Rec.DATE_8;
        lrec_rsPd.DATE_9 := p_Rec.DATE_9;
        lrec_rsPd.DATE_10 := p_Rec.DATE_10;
        lrec_rsPd.TEXT_1 := p_Rec.TEXT_1;
        lrec_rsPd.TEXT_2 := p_Rec.TEXT_2;
        lrec_rsPd.TEXT_3 := p_Rec.TEXT_3;
        lrec_rsPd.TEXT_4 := p_Rec.TEXT_4;
        lrec_rsPd.TEXT_5 := p_Rec.TEXT_5;
        lrec_rsPd.TEXT_6 := p_Rec.TEXT_6;
        lrec_rsPd.TEXT_7 := p_Rec.TEXT_7;
        lrec_rsPd.TEXT_8 := p_Rec.TEXT_8;
        lrec_rsPd.TEXT_9 := p_Rec.TEXT_9;
        lrec_rsPd.TEXT_10 := p_Rec.TEXT_10;
        lrec_rsPd.VALUE_1 := p_Rec.VALUE_1;
        lrec_rsPd.VALUE_2 := p_Rec.VALUE_2;
        lrec_rsPd.VALUE_3 := p_Rec.VALUE_3;
        lrec_rsPd.VALUE_4 := p_Rec.VALUE_4;
        lrec_rsPd.VALUE_5 := p_Rec.VALUE_5;
        lrec_rsPd.VALUE_6 := p_Rec.VALUE_6;
        lrec_rsPd.VALUE_7 := p_Rec.VALUE_7;
        lrec_rsPd.VALUE_8 := p_Rec.VALUE_8;
        lrec_rsPd.VALUE_9 := p_Rec.VALUE_9;
        lrec_rsPd.VALUE_10 := p_Rec.VALUE_10;
        lrec_rspd.object_type := p_rec.object_type;
        lrec_rspd.dist_type := p_rec.dist_type;
        lrec_rspd.pricing_value := p_Rec.Pricing_Value;
        lrec_rspd.unit_price := p_Rec.Unit_Price;
        lrec_rsPd.Li_Price_Object_Code := p_Rec.Li_Price_Object_Code;
        lrec_rsPd.Li_Price_Object_id := p_Rec.Li_Price_Object_id;
        lrec_rspd.customer_id := p_rec.customer_id; -- The overriden Customer id needs to be restored
        lrec_rspd.customer_code := p_rec.customer_code; -- The overriden Customer code needs to be restored

        -- Continue on existing log
        rec_RevnLogInterface := NULL;
        FOR rsLog IN c_log(ec_contract.object_id_by_uk(lrec_rsPd.Contract_Code), lrec_rsPd.Source_Entry_No) LOOP
            rec_RevnLogInterface.LOG_NO := rsLog.Log_No;
            rec_RevnLogInterface.LOG_STATUS := rsLog.Status;
        END LOOP;
        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_INFO, '__________   Starting RE-analyse of Ifac Record   __________________________________________________');

        lrec_rspd.trans_temp_id_ovrd := p_rec.trans_temp_id_ovrd; -- The overriden transaction template needs to be restored
        lrec_rspd.trans_temp_code_ovrd := p_rec.trans_temp_code_ovrd; -- The overriden transaction template needs to be restored

        -- Resolve the record
        lrec_rsPd := Ecdp_Inbound_Interface.ResolveCargoRecord_P(
            lrec_rsPd,
            NVL(trunc(lrec_rsPd.point_of_sale_date, 'MM'), nvl(trunc(lrec_rsPd.delivery_date, 'MM'), nvl(trunc(lrec_rsPd.loading_date, 'MM'), Ecdp_Timestamp.getCurrentSysdate))));

        -- Set other columns that should be set by the system
        lrec_rspd.alloc_no := p_rec.alloc_no;
        lrec_rspd.source_entry_no := p_rec.source_entry_no;
        lrec_rsPd.trans_key_set_ind := CASE WHEN lrec_rsPd.Transaction_Key IS NULL THEN 'N' ELSE 'Y' END;
        lrec_rspd.alloc_no_max_ind := p_rec.alloc_no_max_ind;
        lrec_rspd.ignore_ind := p_rec.ignore_ind;
        lrec_rspd.record_status := p_rec.record_status;
        lrec_rspd.created_by := p_rec.created_by;
        lrec_rspd.created_date := p_rec.created_date;
        lrec_rsPd.last_updated_by := CASE WHEN p_user IS NULL THEN USER ELSE p_user END;
        lrec_rsPd.last_updated_date := Ecdp_Timestamp.getCurrentSysdate();
        lrec_rspd.rev_no := p_rec.rev_no;
        lrec_rspd.rev_text := p_rec.rev_text;
        lrec_rspd.approval_by := p_rec.approval_by;
        lrec_rspd.approval_date := p_rec.approval_date;
        lrec_rspd.approval_state := p_rec.approval_state;
        lrec_rspd.rec_id := p_rec.rec_id;
        lrec_rspd.original_ifac_data := p_rec.original_ifac_data; -- The original data needs to be stored

        WriteRevnLogInterface_P(EcDp_Revn_Log.LOG_STATUS_ITEM_DEBUG, 'Max Alloc is ' || case nvl(lrec_rspd.alloc_no,-999999) when -999999 then 'NULL' else to_char(lrec_rspd.alloc_no) end);
        WriteRevnLogInterface_P(ECDP_REVN_LOG.LOG_STATUS_SUCCESS);
    ELSE
        lrec_rsPd := p_Rec;
    END IF;

    RETURN lrec_rsPd;

END ReAnalyseCargoRecord;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ReAnalyseNewSalesQtyRecords(p_contract_id      VARCHAR2,
                                      p_contract_area_id VARCHAR2,
                                      p_business_unit_id VARCHAR2,
                                      p_user VARCHAR2 DEFAULT USER)
IS
    lrec_rsPd IFAC_SALES_QTY%ROWTYPE;

    CURSOR c_not_processed_ifac_rec IS
        SELECT ifac_sales_qty.*
        FROM ifac_sales_qty, contract_version, contract_area_version, business_unit
        WHERE ifac_sales_qty.alloc_no_max_ind = 'Y'
             AND ifac_sales_qty.ignore_ind = 'N'
             AND ifac_sales_qty.trans_key_set_ind = 'N'
             AND ifac_sales_qty.processing_period >= ADD_MONTHS(TRUNC(Ecdp_Timestamp.getCurrentSysdate,'MM'), (NVL(ec_ctrl_system_attribute.attribute_value(TRUNC(Ecdp_Timestamp.getCurrentSysdate,'MM'), 'DOC_GEN_MONTHS', '<='), 120) * -1))
             AND ifac_sales_qty.contract_id = contract_version.object_id
             AND contract_version.object_id = nvl(p_contract_id, contract_version.object_id)
             AND contract_version.contract_area_id = contract_area_version.object_id
             AND contract_area_version.object_id = nvl(p_contract_area_id, contract_area_version.object_id)
             AND contract_area_version.business_unit_id = business_unit.object_id
             AND business_unit.object_id = nvl(p_business_unit_id, business_unit.object_id)
        ORDER BY ifac_sales_qty.source_entry_no;

BEGIN

  -- Implementing "Instead" User Exit
     IF ue_inbound_interface.isReAnalyseNewSalesQtyUEE = 'TRUE' THEN
         ue_inbound_interface.getNewSalesQtyRecords(p_contract_id ,p_contract_area_id ,p_business_unit_id ,p_user );
     ELSE
         -- Implementing "PRE" User Exit
         IF ue_inbound_interface.isReAnalyzeNewSalesQtyPreUEE = 'TRUE' THEN
            ue_inbound_interface.getNewSalesQtyRecordsPre (p_contract_id ,p_contract_area_id ,p_business_unit_id ,p_user );
         END IF;
          -- Re-analyse the ifac data in case related data changed after it was interfaced
          FOR li_rec IN c_not_processed_ifac_rec LOOP
              lrec_rsPd := EcDp_Inbound_Interface.ReAnalyseSalesQtyRecord(li_rec, p_user);

              UPDATE IFAC_SALES_QTY
                 SET ROW = lrec_rsPd
              WHERE Source_Entry_No = lrec_rsPd.Source_Entry_No;

          END LOOP;
          -- Implementing "POST" User Exit
         IF ue_inbound_interface.isReAnalyzeNewSalesQtyPostUEE = 'TRUE' THEN
            ue_inbound_interface.getNewSalesQtyRecordsPost (p_contract_id ,p_contract_area_id ,p_business_unit_id ,p_user, lrec_rsPd);
         END IF;
     END IF;

END ReAnalyseNewSalesQtyRecords;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ReAnalyseAllSalesQtyRecords(p_contract_id      VARCHAR2,
                                      p_processing_period  DATE,
                                      p_user VARCHAR2 DEFAULT USER)
IS
    lrec_rsPd IFAC_SALES_QTY%ROWTYPE;

    CURSOR c_not_processed_ifac_rec IS
        SELECT ifac_sales_qty.*
        FROM ifac_sales_qty, contract_version, contract_area_version, business_unit
        WHERE ifac_sales_qty.alloc_no_max_ind = 'Y'
             AND ifac_sales_qty.ignore_ind = 'N'
             AND ifac_sales_qty.Processing_Period >= p_processing_period
             AND ifac_sales_qty.processing_period >= ADD_MONTHS(TRUNC(Ecdp_Timestamp.getCurrentSysdate,'MM'), (NVL(ec_ctrl_system_attribute.attribute_value(TRUNC(Ecdp_Timestamp.getCurrentSysdate,'MM'), 'DOC_GEN_MONTHS', '<='), 120) * -1))
             AND ifac_sales_qty.contract_id = contract_version.object_id
             AND contract_version.object_id = nvl(p_contract_id, contract_version.object_id)
             AND contract_version.contract_area_id = contract_area_version.object_id
             AND contract_area_version.business_unit_id = business_unit.object_id
        ORDER BY ifac_sales_qty.source_entry_no;

BEGIN
    -- Re-analyse the ifac data in case related data changed after it was interfaced
    FOR li_rec IN c_not_processed_ifac_rec LOOP
        lrec_rsPd := EcDp_Inbound_Interface.ReAnalyseSalesQtyRecord(li_rec, p_user);

        UPDATE IFAC_SALES_QTY
           SET ROW = lrec_rsPd
        WHERE Source_Entry_No = lrec_rsPd.Source_Entry_No;

    END LOOP;
END ReAnalyseAllSalesQtyRecords;
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE ReAnalyseNewCargoRecords(p_contract_id      VARCHAR2,
                                   p_contract_area_id VARCHAR2,
                                   p_business_unit_id VARCHAR2,
                                   p_user VARCHAR2 DEFAULT USER)
IS
    lrec_rsPd IFAC_CARGO_VALUE%ROWTYPE;

    CURSOR c_not_processed_ifac_rec IS
        SELECT ifac_cargo_value.*
        FROM ifac_cargo_value, contract_version, contract_area_version, business_unit
        WHERE ifac_cargo_value.alloc_no_max_ind = 'Y'
             AND ifac_cargo_value.ignore_ind = 'N'
             AND ifac_cargo_value.trans_key_set_ind = 'N'
             AND ifac_cargo_value.point_of_sale_date >= ADD_MONTHS(TRUNC(Ecdp_Timestamp.getCurrentSysdate,'MM'), (NVL(ec_ctrl_system_attribute.attribute_value(TRUNC(Ecdp_Timestamp.getCurrentSysdate,'MM'), 'DOC_GEN_MONTHS', '<='), 120) * -1))
             AND ifac_cargo_value.contract_id = contract_version.object_id
             AND contract_version.object_id = nvl(p_contract_id, contract_version.object_id)
             AND contract_version.contract_area_id = contract_area_version.object_id
             AND contract_area_version.object_id = nvl(p_contract_area_id, contract_area_version.object_id)
             AND contract_area_version.business_unit_id = business_unit.object_id
             AND business_unit.object_id = nvl(p_business_unit_id, business_unit.object_id)
        ORDER BY ifac_cargo_value.source_entry_no;

BEGIN
      -- Implementing "Instead" User Exit
 IF ue_inbound_interface.isReAnalyseNewCargoRecUEE = 'TRUE' THEN
     ue_inbound_interface.getNewCargoRecords(p_contract_id ,p_contract_area_id ,p_business_unit_id ,p_user );
  ELSE
     -- Implementing "PRE" User Exit
     IF ue_inbound_interface.isReAnalyzeNewCargoRecPreUEE = 'TRUE' THEN
        ue_inbound_interface.getNewCargoRecordsPre (p_contract_id ,p_contract_area_id ,p_business_unit_id ,p_user );
     END IF;
    -- Re-analyse the ifac data in case related data changed after it was interfaced
    FOR li_rec IN c_not_processed_ifac_rec LOOP
        lrec_rsPd := EcDp_Inbound_Interface.ReAnalyseCargoRecord(li_rec, p_user);

        UPDATE IFAC_CARGO_VALUE
            SET ROW = lrec_rsPd
        WHERE Source_Entry_No = lrec_rsPd.Source_Entry_No;

    END LOOP;
          -- Implementing "POST" User Exit
      IF ue_inbound_interface.isReAnalyzeNewCargoRecPostUEE = 'TRUE' THEN
        ue_inbound_interface.getNewCargoRecordsPost(p_contract_id ,p_contract_area_id ,p_business_unit_id ,p_user, lrec_rsPd);
      END IF;
  END IF ;

END ReAnalyseNewCargoRecords;

-----------------------------------------------------------------------------------------------------------------------------


PROCEDURE ReAnalyseAllCargoRecords(p_contract_id      VARCHAR2,
                                   p_document_key     VARCHAR2,
                                   p_user VARCHAR2 DEFAULT USER)
IS
    lrec_rsPd IFAC_CARGO_VALUE%ROWTYPE;

    CURSOR c_not_processed_ifac_rec IS
        SELECT ifac_cargo_value.*
        FROM ifac_cargo_value, contract_version, contract_area_version, business_unit, cont_transaction
        WHERE cont_transaction.document_key = p_document_key
             AND to_char(cont_transaction.cargo_no) = ifac_cargo_value.cargo_no
             AND to_char(cont_transaction.parcel_no) = ifac_cargo_value.parcel_no
             AND ifac_cargo_value.alloc_no_max_ind = 'Y'
             AND ifac_cargo_value.ignore_ind = 'N'
             AND ifac_cargo_value.point_of_sale_date >= ADD_MONTHS(TRUNC(Ecdp_Timestamp.getCurrentSysdate,'MM'), (NVL(ec_ctrl_system_attribute.attribute_value(TRUNC(Ecdp_Timestamp.getCurrentSysdate,'MM'), 'DOC_GEN_MONTHS', '<='), 120) * -1))
             AND ifac_cargo_value.contract_id = contract_version.object_id
             AND contract_version.object_id = nvl(p_contract_id, contract_version.object_id)
             AND contract_version.contract_area_id = contract_area_version.object_id
             AND contract_area_version.business_unit_id = business_unit.object_id
        ORDER BY ifac_cargo_value.source_entry_no;

BEGIN
    -- Re-analyse the ifac data in case related data changed after it was interfaced
    FOR li_rec IN c_not_processed_ifac_rec LOOP
        lrec_rsPd := EcDp_Inbound_Interface.ReAnalyseCargoRecord(li_rec, p_user);

        UPDATE IFAC_CARGO_VALUE
            SET ROW = lrec_rsPd
        WHERE Source_Entry_No = lrec_rsPd.Source_Entry_No;

    END LOOP;
END ReAnalyseAllCargoRecords;
-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE UpdateTransTempCodeOvrd(
    p_contract_id 	           VARCHAR2,
    p_trans_temp_id 	         VARCHAR2,
    p_trans_temp_code 	       VARCHAR2,
    p_processing_period        DATE,
    p_doc_setup_id             VARCHAR2,
    p_sample_source_entry_no   NUMBER,
    p_product_id               VARCHAR2,
    p_type 	                   VARCHAR2)
--</EC-DOC>
IS
lrec_Start                    IFAC_SALES_QTY%ROWTYPE;
lrec_Changed                  IFAC_SALES_QTY%ROWTYPE;
lrec_Orig                     IFAC_SALES_QTY%ROWTYPE;
lrec_Cargo_Start                    IFAC_CARGO_VALUE%ROWTYPE;
lrec_Cargo_Changed                  IFAC_CARGO_VALUE%ROWTYPE;
lrec_Cargo_Orig                     IFAC_CARGO_VALUE%ROWTYPE;

BEGIN
   IF  p_type = 'PERIOD' THEN
      lrec_Start := ec_ifac_sales_qty.row_by_pk(p_sample_source_entry_no);
      lrec_Orig := DecodeOriginalSalesQtyRecord(lrec_Start.ORIGINAL_IFAC_DATA);

      IF p_trans_temp_code != 'Default_Transaction_Template' THEN
        lrec_Orig.Trans_Temp_Id_Ovrd := p_trans_temp_id;
        lrec_Orig.Trans_Temp_code_Ovrd := p_trans_temp_code;
        lrec_Changed := ResolveSalesQtyRecord_P(lrec_Orig,p_processing_period);
      ELSE
        lrec_Orig.Trans_Temp_Id_Ovrd := NULL;
        lrec_Orig.Trans_Temp_code_Ovrd := NULL;
        lrec_Changed := ResolveSalesQtyRecord_P(lrec_Orig,p_processing_period);
      END IF;

        	     UPDATE ifac_sales_qty
                        set   trans_temp_id        = lrec_Changed.trans_temp_id,
                              trans_temp_code      = lrec_Changed.trans_temp_code,
                              price_object_id      = lrec_Changed.price_object_id,
                              price_object_code    = lrec_Changed.price_object_code,
                              product_id           = lrec_Changed.product_id,
                              product_code         = lrec_Changed.product_code,
                              price_concept_code   = lrec_Changed.price_concept_code,
                              delivery_point_id    = lrec_Changed.delivery_point_id,
                              delivery_point_code  = lrec_Changed.delivery_point_code,
                              trans_temp_id_ovrd   = lrec_Changed.trans_temp_id_ovrd,
                              trans_temp_code_ovrd = lrec_Changed.trans_temp_code_ovrd,
                              doc_setup_id         = lrec_Changed.doc_setup_id,
                              doc_setup_code       = lrec_Changed.doc_setup_code
                       WHERE contract_code        = lrec_start.Contract_Code
                        AND   NVL(Customer_Id,'X') = NVL(lrec_start.Customer_Id,'X')
                        AND nvl(uom1_code,'X')  = nvl(lrec_start.uom1_code,'X')
						            AND   processing_period    = lrec_start.Processing_Period
						            AND   period_start_date  = lrec_start.period_start_date
						            AND   period_end_date  = lrec_start.period_end_date
                        AND   doc_setup_id  = lrec_start.doc_setup_id
                        AND   trans_temp_id  = lrec_start.trans_temp_id
                        AND   nvl(Delivery_Point_Code,'xx')
                                                   = nvl(lrec_start.Delivery_Point_Code,'xx')
                        AND   price_concept_code   = lrec_start.Price_Concept_Code
						            AND   price_object_id   = lrec_start.price_object_id
                        AND   product_code         = lrec_start.Product_Code
                        AND   qty_status           = lrec_start.Qty_Status
                        AND   NVL(Unique_Key_1,'xx') = nvl(lrec_start.Unique_Key_1,'xx')
                        AND   NVL(Unique_Key_2,'xx') = nvl(lrec_start.Unique_Key_2,'xx')
                        AND   NVL(ifac_tt_conn_code,'xx') = nvl(lrec_start.ifac_tt_conn_code,'xx')
                        AND   alloc_no_max_ind     = 'Y'
                        AND   ignore_ind           = 'N';

 ELSE
      lrec_cargo_start := ec_ifac_cargo_value.row_by_pk(p_sample_source_entry_no);
      lrec_cargo_Orig := DecodeOriginalCargoRecord(lrec_cargo_start.ORIGINAL_IFAC_DATA);

      IF p_trans_temp_code != 'Default_Transaction_Template' THEN
        lrec_cargo_Orig.Trans_Temp_Id_Ovrd := p_trans_temp_id;
        lrec_cargo_Orig.Trans_Temp_code_Ovrd := p_trans_temp_code;
        lrec_cargo_Changed := ResolveCargoRecord_P(lrec_cargo_Orig,p_processing_period);
      ELSE
        lrec_cargo_Orig.Trans_Temp_Id_Ovrd := NULL;
        lrec_cargo_Orig.Trans_Temp_code_Ovrd := NULL;
        lrec_cargo_Changed := ResolveCargoRecord_P(lrec_cargo_Orig,p_processing_period);
      END IF;




UPDATE ifac_cargo_value
                        set   trans_temp_id        = lrec_cargo_Changed.trans_temp_id,
                              trans_temp_code      = lrec_cargo_Changed.trans_temp_code,
                              price_object_id      = lrec_cargo_Changed.price_object_id,
                              price_object_code    = lrec_cargo_Changed.price_object_code,
                              product_id           = lrec_cargo_Changed.product_id,
                              product_code         = lrec_cargo_Changed.product_code,
                              price_concept_code   = lrec_cargo_Changed.price_concept_code,
                              bl_date              = lrec_cargo_Changed.bl_date,
                              point_of_sale_date   = lrec_cargo_Changed.point_of_sale_date,
                              price_date           = lrec_cargo_Changed.price_date,
                              trans_temp_id_ovrd   = lrec_cargo_Changed.trans_temp_id_ovrd,
                              trans_temp_code_ovrd = lrec_cargo_Changed.trans_temp_code_ovrd,
                              doc_setup_id         = lrec_cargo_Changed.doc_setup_id,
                              doc_setup_code       = lrec_cargo_Changed.doc_setup_code
                       WHERE contract_code        = lrec_cargo_start.Contract_Code
                        AND   cargo_no             = lrec_cargo_start.Cargo_No
                        AND   parcel_no            = lrec_cargo_start.Parcel_No
                        AND   price_concept_code   = lrec_cargo_start.Price_Concept_Code
                        AND   product_code         = lrec_cargo_start.Product_Code
						            AND nvl(uom1_code,'X')  = nvl(lrec_cargo_start.uom1_code,'X')
                        AND   doc_setup_id  = lrec_cargo_start.doc_setup_id
                        AND   trans_temp_id  = lrec_cargo_start.trans_temp_id
                        AND   Qty_Type           = lrec_cargo_start.Qty_Type
                        AND   NVL(ifac_tt_conn_code,'xx') = nvl(lrec_cargo_start.ifac_tt_conn_code,'xx')
                        AND   alloc_no_max_ind     = 'Y'
                        AND   ignore_ind           = 'N';


    end if;

END UpdateTransTempCodeOvrd;

-----------------------------------------------------------------------------------------------------------------------------
  PROCEDURE UpdateCustomerOvrd(p_sample_source_entry_no NUMBER,
                               p_customer_id            VARCHAR2,
                               p_type                   VARCHAR2) IS

    lrec_rsPd_r IFAC_SALES_QTY%ROWTYPE;
    lrec_rscr_r IFAC_CARGO_VALUE%ROWTYPE;
    li_c_rec    IFAC_CARGO_VALUE%ROWTYPE;
    ln_new_alloc NUMBER;
    cursor c_Pending_Cargos(clrec_rscr_r IFAC_CARGO_VALUE%ROWTYPE) is
    select * from ifac_cargo_value
    where transaction_key is null
      and NVL(ignore_ind,'N') = 'N'
      AND ALLOC_NO_MAX_IND = 'Y'
      AND CUSTOMER_ID != p_customer_id
      AND cargo_no = clrec_rscr_r.Cargo_No
      AND contract_code = clrec_rscr_r.Contract_Code
      AND customer_id = clrec_rscr_r.Customer_Id
      AND parcel_no = clrec_rscr_r.Parcel_No
      AND price_concept_code = clrec_rscr_r.Price_Concept_Code
      AND product_code = clrec_rscr_r.product_code
      AND qty_type = clrec_rscr_r.Qty_Type;

    cursor c_pending_period(clrec_rsPd_r IFAC_SALES_QTY%ROWTYPE) is
    select * from ifac_sales_qty
      where transaction_key is null
      and NVL(ignore_ind,'N') = 'N'
      AND ALLOC_NO_MAX_IND = 'Y'
      AND CUSTOMER_ID != p_customer_id
      and contract_code = clrec_rsPd_r.Contract_Code
       AND customer_id = clrec_rsPd_r.Customer_Id
       AND processing_period = clrec_rsPd_r.Processing_Period
       AND delivery_point_code = clrec_rsPd_r.Delivery_Point_Code
       AND price_concept_code = clrec_rsPd_r.Price_Concept_Code
       AND product_code = clrec_rsPd_r.Product_Code
       AND qty_status = clrec_rsPd_r.Qty_Status
       ;



  BEGIN
    --Proc allows to update the customer from Period doc pending screen .
    IF p_type = 'PERIOD' THEN
      lrec_rsPd_r := ec_ifac_sales_qty.row_by_pk(p_sample_source_entry_no);
      If p_customer_id <> lrec_rsPd_r.customer_id and
         p_customer_id is not null then
         for pending in c_pending_period(lrec_rsPd_r) LOOP
         --With customer changing the key is changing for alloc_no
            ln_new_alloc :=
               GetNextPeriodAllocNo(
                pending.contract_id        ,
                pending.vendor_id          ,
                p_customer_id        ,
                pending.Product_Id         ,
                pending.delivery_point_id         ,
                pending.profit_center_id   ,
                pending.price_concept_code ,
                pending.Qty_Status           ,
                pending.uom1_code          ,
                pending.price_object_id    ,
                pending.Unique_Key_1,
                pending.Unique_Key_2,
                pending.Li_Unique_Key_1,
                pending.Li_Unique_Key_2,
                pending.Processing_Period,
                pending.Period_Start_Date,
                pending.Period_End_Date,
                pending.ifac_tt_conn_code,
                pending.ifac_li_conn_code    ,
                pending.Line_Item_Based_Type ,
                pending.Line_Item_Type);


        UPDATE ifac_sales_qty
           SET customer_id = p_customer_id,
               customer_code=ec_company.object_code(p_customer_id),
               alloc_no = ln_new_alloc
         WHERE pending.Source_Entry_No = source_entry_no;
       END LOOP;
        IF SQL%ROWCOUNT > 0 THEN
          --ReAnalyse the changes after updating the Customer
          ReAnalyseAllSalesQtyRecords(lrec_rsPd_r.Contract_Id,
                                      lrec_rsPd_r.Processing_Period);
        END IF;
      END IF;
    ELSIF p_type = 'CARGO' then
      lrec_rscr_r := ec_ifac_cargo_value.row_by_pk(p_sample_source_entry_no);
      If p_customer_id <> lrec_rscr_r.customer_id and
         p_customer_id is not null then

         for pending in c_Pending_Cargos(lrec_rscr_r) loop

             ln_new_alloc :=
               GetNextCargoAllocNo(
                pending.contract_id        ,
                pending.vendor_id          ,
                p_customer_id        ,
                pending.cargo_no           ,
                pending.parcel_no           ,
                pending.qty_type           ,
                pending.profit_center_id   ,
                pending.price_concept_code ,
                pending.Product_Id         ,
                pending.uom1_code          ,
                pending.price_object_id    ,
                pending.Li_Unique_Key_1      ,
                pending.Li_Unique_Key_2      ,
                pending.ifac_tt_conn_code,
                pending.ifac_li_conn_code    ,
                pending.Line_Item_Based_Type ,
                pending.Line_Item_Type);


        UPDATE ifac_cargo_value
                 SET customer_id = p_customer_id,
                 customer_code=ec_company.object_code(p_customer_id),
                 alloc_no = ln_new_alloc
               WHERE pending.Source_Entry_No = source_entry_no;

         END LOOP;


        IF SQL%ROWCOUNT > 0 THEN
          --ReAnalyse the changes after updating the Customer
          lrec_rscr_r.customer_id := p_customer_id;
          lrec_rscr_r.customer_code := ec_company.object_code(p_customer_id);
          lrec_rscr_r.alloc_no := ec_ifac_cargo_value.alloc_no(lrec_rscr_r.Source_Entry_No);
          li_c_rec                := ReAnalyseCargoRecord(lrec_rscr_r);
          UPDATE IFAC_CARGO_VALUE
             SET ROW = li_c_rec
           WHERE Source_Entry_No = lrec_rscr_r.Source_Entry_No;
        END IF;
      END IF;

    END IF;
  END UpdatecustomerOvrd;
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetAllIfacPossibleTT(p_source_entry_no 	  NUMBER,
                              p_doc_setup_id 	      VARCHAR2,
                              p_type 	              VARCHAR2)
RETURN T_TABLE_MIXED_DATA
--</EC-DOC>
IS

    l_doc_concept_code IFAC_SALES_QTY.Doc_Setup_Id%type;
    lrec_isq IFAC_SALES_QTY%ROWTYPE;
    lrec_icv IFAC_CARGO_VALUE%ROWTYPE;
    ld_processing_period DATE;

BEGIN

     IF p_type = 'PERIOD' THEN
         lrec_isq := ec_ifac_sales_qty.row_by_pk(p_source_entry_no);

         select cdv.Doc_Concept_Code
           into l_doc_concept_code
           from contract_doc_version cdv
          where cdv.object_id = p_doc_setup_id
            and cdv.daytime =
                (select max(sb.daytime)
                   from contract_doc_version sb
                  where sb.object_id = cdv.object_id
                    and sb.daytime <= lrec_isq.period_start_date);

         RETURN GetAllPossibleIfacSalesTT(
                     lrec_isq
                     ,l_doc_concept_code
                     );
     ELSE IF p_type = 'CARGO' THEN
          lrec_icv := ec_ifac_cargo_value.row_by_pk(p_source_entry_no);
          ld_processing_period := ecdp_revn_ifac_common.getcargoprocessingperiod(lrec_icv,ec_contract.start_date(lrec_icv.contract_id));

          select Doc_Concept_Code
            into l_doc_concept_code
            from contract_doc_version cdv
           where cdv.object_id = p_doc_setup_id
             and cdv.daytime =
                 (select max(sb.daytime)
                    from contract_doc_version sb
                   where sb.object_id = cdv.object_id
                     and sb.daytime <= ld_processing_period);


          RETURN GetAllPossibleIfacCargoTT(lrec_icv,l_doc_concept_code);
          END IF;
     END IF;

END GetAllIfacPossibleTT;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetAllPossibleIfacSalesTT(p_Rec 	IFAC_SALES_QTY%ROWTYPE,
                                 p_doc_concept_code 	VARCHAR2)
RETURN T_TABLE_MIXED_DATA
--</EC-DOC>
IS
lt_transaction_template T_TABLE_MIXED_DATA;
lv2_Price_Concept_Code    VARCHAR2(32);
lv2_price_object_id       VARCHAR2(32);
lv2_product_id            VARCHAR2(32);
lv2_delivery_point_id     VARCHAR2(32);
lv2_req_qty_type          VARCHAR2(32);
lv2_uom1_code             VARCHAR2(32);
lrec_rsPd                 IFAC_SALES_QTY%ROWTYPE;

 CURSOR c_Trans(
            cp_contract_id                          VARCHAR2,
            cp_daytime                              DATE,
            cp_from_date                            DATE,
            cp_to_date                              DATE,
            cp_delivery_point_id                    VARCHAR2,
            cp_product_id                           VARCHAR2,
            cp_profit_centre_id                     VARCHAR2,
            cp_qty_status                           VARCHAR2,
            cp_price_concept_code                   VARCHAR2,
            cp_price_object_id                      VARCHAR2,
            cp_uom1_code                            VARCHAR2,
            cp_doc_concept_code                     VARCHAR2,
            cp_if_tt_conn_code                      VARCHAR2 DEFAULT NULL)
IS

-- Full config (tt has Price Object, may not have delivery point):
  SELECT DISTINCT tt.object_id,
                  ct.document_key,
                  ttv.name,
                  cdv.automation_priority,
                  tt.sort_order tt_sort_order,
                  tt.object_code,
                  1 sort_order
    FROM contract_doc             cd,
       contract_doc_version     cdv,
       transaction_template     tt,
       transaction_tmpl_version ttv,
       cont_transaction         ct
   WHERE cd.contract_id = cp_contract_id
     AND cdv.object_id = cd.object_id
     AND cdv.daytime <= cp_daytime
     AND nvl(cdv.end_date, cp_daytime + 1) > cp_daytime
     AND tt.contract_doc_id = cd.object_id
     AND ttv.object_id = tt.object_id
     AND ttv.daytime <= cp_daytime
     AND NVL(ttv.end_date, cp_daytime + 1) > cp_daytime
     AND tt.object_id = ct.trans_template_id(+)
     AND cp_from_date = ct.supply_from_date(+)
     AND cp_to_date = ct.supply_to_date(+)
     -- Cater for no price object and no price concept code on transaction template:
     AND NVL(ttv.price_concept_code,NVL(cp_price_concept_code,'x')) = NVL( cp_price_concept_code , NVL(ttv.price_concept_code,'x') )
     AND NVL(ttv.price_object_id,NVL(cp_price_object_id,'x')) =    NVL(cp_price_object_id,NVL(TTV.price_object_id,'x'))
     AND NVL(ttv.product_id,NVL(cp_Product_Id,'x')) = NVL( cp_Product_Id, NVL(ttv.product_id,'x') )
     AND NVL(ttv.req_qty_type,NVL(cp_qty_status,'x')) =
       CASE cp_qty_status WHEN 'PPA' THEN NVL(ttv.req_qty_type,NVL(cp_qty_status,'x'))
          ELSE
            NVL( cp_qty_status, NVL(ttv.req_qty_type,'x') )
          END
     AND NVL(ttv.uom1_code,NVL(cp_uom1_code,'x')) = NVL( cp_uom1_code, NVL(ttv.uom1_code,'x') )
     AND NVL(ttv.delivery_point_id,NVL(cp_delivery_point_id,'x')) = NVL( cp_delivery_point_id, NVL(ttv.delivery_point_id,'x') )

     AND nvl(ttv.ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')
     AND ttv.price_object_id = CASE WHEN cp_price_object_id IS NULL THEN ttv.price_object_id ELSE cp_price_object_id END

     -- If looking for a doc setup with a specific concept (p_doc_concept_code is optional)
     AND cdv.doc_concept_code LIKE (CASE WHEN cp_doc_concept_code IS NOT NULL THEN cp_doc_concept_code ELSE cdv.doc_concept_code END)

     -- Match on tt's object or object list. Dist Code is mandatory.
     AND ttv.dist_code = CASE --This rule is for interfacing a "Sum" profit center:
                              WHEN ttv.dist_type = 'OBJECT_LIST' AND ecdp_objects.GetObjCode(cp_profit_centre_id) = 'SUM' THEN ttv.dist_code
                              --This rule is for interfacing an Object List on Line Item level:
                              WHEN ttv.dist_type = 'OBJECT_LIST' AND ttv.dist_type = EcDp_Objects.GetObjClassName(cp_profit_centre_id) THEN ttv.dist_code
                              --This rule is for interfacing Object on Field or Vendor level:
                              WHEN ttv.dist_type = 'OBJECT_LIST' THEN CASE ecdp_inbound_interface.isObjectInObjectList(cp_profit_centre_id, ec_object_list.object_id_by_uk(ttv.dist_code), cp_daytime) WHEN 'Y' THEN ttv.dist_code ELSE 'X' END
                              --This rule is for interfacing Object:
                              WHEN ttv.dist_type = 'OBJECT' THEN ecdp_objects.GetObjCode(cp_profit_centre_id) END
UNION ALL
-- Reduced config (Price Object):
  SELECT DISTINCT tt.object_id,
                  ct.document_key,
                  ttv.name,
                  cdv.automation_priority,
                  tt.sort_order tt_sort_order,
                  tt.object_code,
                  1 sort_order
    FROM contract_doc             cd,
       contract_doc_version     cdv,
       transaction_template     tt,
         transaction_tmpl_version ttv,
         cont_transaction         ct
   WHERE cd.contract_id = cp_contract_id
     AND cdv.object_id = cd.object_id
     AND cdv.daytime <= cp_daytime
     AND nvl(cdv.end_date, cp_daytime + 1) > cp_daytime
   AND tt.contract_doc_id = cd.object_id
     AND ttv.object_id = tt.object_id
     AND ttv.daytime <= cp_daytime
     AND NVL(ttv.end_date, cp_daytime + 1) > cp_daytime
     AND tt.object_id = ct.trans_template_id(+)
     AND cp_from_date = ct.supply_from_date(+)
     AND cp_to_date = ct.supply_to_date(+)

     -- If key matching columns are blank on the TT, it means it accepts any value from the interface ('x' = 'x').
     -- Delivery point should not be mandatory in ifac if Transaction Template is set
     AND NVL(ttv.delivery_point_id,'x')  = CASE WHEN ttv.delivery_point_id  IS NULL THEN 'x' ELSE nvl(cp_delivery_point_id,ttv.delivery_point_id) END
     AND NVL(ttv.req_qty_type,'x')       = CASE WHEN ttv.req_qty_type       IS NULL THEN 'x' ELSE cp_qty_status END
     AND NVL(ttv.uom1_code,'x')          = CASE WHEN ttv.uom1_code          IS NULL THEN 'x' ELSE cp_uom1_code END
     AND NVL(ttv.price_concept_code,'x') = CASE WHEN ttv.price_concept_code IS NULL THEN 'x' ELSE cp_price_concept_code END
     AND nvl(ttv.price_object_id,'x')    = CASE WHEN ttv.price_object_id    IS NULL THEN 'x' ELSE NVL(cp_price_object_id,nvl(ttv.price_object_id,'x')) END
     AND NVL(ttv.product_id,'x')         = CASE WHEN ttv.product_id         IS NULL THEN 'x' ELSE cp_product_id END
	 AND nvl(ttv.ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')

     -- If looking for a doc setup with a specific concept (p_doc_concept_code is optional)
     AND cdv.doc_concept_code LIKE (CASE WHEN cp_doc_concept_code IS NOT NULL THEN cp_doc_concept_code ELSE cdv.doc_concept_code END)

     -- Match on tt's object or object list. Dist Code is mandatory.
     AND ttv.dist_code = CASE --This rule is for interfacing a "Sum" profit center:
                              WHEN ttv.dist_type = 'OBJECT_LIST' AND ecdp_objects.GetObjCode(cp_profit_centre_id) = 'SUM' THEN ttv.dist_code
                              --This rule is for interfacing an Object List on Line Item level:
                              WHEN ttv.dist_type = 'OBJECT_LIST' AND ttv.dist_type = EcDp_Objects.GetObjClassName(cp_profit_centre_id) THEN ttv.dist_code
                              --This rule is for interfacing Object on Field or Vendor level:
                              WHEN ttv.dist_type = 'OBJECT_LIST' THEN CASE ecdp_inbound_interface.isObjectInObjectList(cp_profit_centre_id, ec_object_list.object_id_by_uk(ttv.dist_code), cp_daytime) WHEN 'Y' THEN ttv.dist_code ELSE 'X' END
                              --This rule is for interfacing Object:
                              WHEN ttv.dist_type = 'OBJECT' THEN ecdp_objects.GetObjCode(cp_profit_centre_id) END

  ORDER BY automation_priority, sort_order, tt_sort_order;

BEGIN
     lt_transaction_template := T_TABLE_MIXED_DATA();

     IF p_Rec.ORIGINAL_IFAC_DATA IS NOT NULL THEN
        -- Get the orignal ifac record and re-analyse it
        lrec_rsPd              := Ecdp_Inbound_Interface.DecodeOriginalSalesQtyRecord(p_Rec.Original_Ifac_Data);
        lv2_price_object_id    := ec_product_price.object_id_by_uk(lrec_rsPd.Price_Object_Code);

        IF lv2_price_object_id IS NOT NULL THEN
           lv2_Price_Concept_Code := nvl(lrec_rsPd.Price_Concept_Code,ec_product_price.price_concept_code(lv2_price_object_id));
           lv2_product_id := nvl(ec_product.object_id_by_uk(lrec_rsPd.Product_Code),ec_product_price.product_id(lv2_price_object_id));
        ELSE
            lv2_product_id := ec_product.object_id_by_uk(lrec_rsPd.Product_Code);
        END IF;

        lv2_delivery_point_id  := nvl(lrec_rsPd.Delivery_Point_Id,ec_delivery_point.object_code(lrec_rsPd.Delivery_Point_Id));
        lv2_req_qty_type       := lrec_rsPd.Qty_Status;
        lv2_uom1_code          := lrec_rsPd.Uom1_Code;
    ELSE
        lv2_price_object_id    := p_Rec.price_object_id;
        lv2_Price_Concept_Code := p_Rec.Price_Concept_Code;
        lv2_product_id         := p_Rec.product_id;
        lv2_delivery_point_id  := p_Rec.Delivery_Point_id;
        lv2_req_qty_type       := p_Rec.Qty_Status;
        lv2_uom1_code          := p_Rec.Uom1_Code;
    END IF;

     FOR rsT IN c_Trans(p_Rec.Contract_Id,
                         p_Rec.Processing_Period,
                         p_Rec.Period_Start_Date,
                         p_Rec.Period_End_Date,
                         lv2_delivery_point_id,
                         lv2_product_id,
                         p_Rec.Profit_Center_id,
                         lv2_req_qty_type,
                         lv2_Price_Concept_Code,
                         lv2_price_object_id,
                         lv2_uom1_code,
                         p_doc_concept_code,
                         p_Rec.ifac_tt_conn_code)
     LOOP
     lt_transaction_template.EXTEND(1);
     lt_transaction_template(lt_transaction_template.LAST) := T_MIXED_DATA(rsT.object_id,rsT.name);
     lt_transaction_template(lt_transaction_template.LAST).text_1 :=  rsT.object_code;
     END LOOP;

     lt_transaction_template.EXTEND(1);
     lt_transaction_template(lt_transaction_template.LAST) := T_MIXED_DATA('','Default Transaction Template');
     lt_transaction_template(lt_transaction_template.LAST).text_1 :=  'Default_Transaction_Template';

     RETURN lt_transaction_template;

END GetAllPossibleIfacSalesTT;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetAllPossibleIfacCargoTT(p_Rec_ICV 	IFAC_CARGO_VALUE%ROWTYPE, p_doc_concept_code 	VARCHAR2)
RETURN T_TABLE_MIXED_DATA
--</EC-DOC>
IS
       lt_transaction_template T_TABLE_MIXED_DATA;
       CURSOR c_tt(
            cp_daytime                              DATE,
            cp_Contract_Id                          VARCHAR2,
            cp_Price_Concept_Code                   VARCHAR2,
            cp_Price_Object_Id                      VARCHAR2,
            cp_Uom1_Code                            VARCHAR2,
            cp_Product_Id                           VARCHAR2,
            cp_Qty_Type                             VARCHAR2,
            cp_if_tt_conn_code                      VARCHAR2,
            cp_preceding                            VARCHAR2,
            cp_doc_concept_code                     VARCHAR2)
       IS
       SELECT ct.transaction_key, tt.object_id, ct.document_key, ttv.dist_code, cdv.automation_priority, ttv.name, tt.object_code
         FROM contract_doc             cd,
              contract_doc_version     cdv,
              transaction_template     tt,
              transaction_tmpl_version ttv,
              cont_transaction         ct
        WHERE cd.contract_id = cp_Contract_Id
          AND cd.object_id = cdv.object_id
          AND cdv.daytime <= cp_daytime
          AND NVL(cdv.end_date, cp_daytime+1) > cp_daytime

          AND tt.contract_doc_id = cd.object_id
          AND tt.object_id = ttv.object_id
          AND ttv.daytime <= cp_daytime
          AND NVL(ttv.end_date, cp_daytime+1) > cp_daytime
          AND tt.object_id = ct.trans_template_id(+)

          AND cdv.automation_ind = 'Y'
          AND ttv.uom1_code = cp_uom1_code
          AND nvl(ttv.req_qty_type,cp_Qty_Type) = cp_Qty_Type
          AND ttv.transaction_scope = 'CARGO_BASED'
          AND nvl(ttv.ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')

          -- Cater for no price object on transaction template:
          AND NVL(ttv.price_concept_code,NVL(cp_Price_Concept_Code,'x')) = NVL( cp_Price_Concept_Code , NVL(ttv.price_concept_code,'x') )
          AND NVL(ttv.price_object_id,NVL(cp_price_object_id,'x')) =    NVL(cp_price_object_id,NVL(TTV.price_object_id,'x'))
          AND NVL(ttv.product_id,NVL(cp_Product_Id,'x')) = NVL( cp_Product_Id, NVL(ttv.product_id,'x') )
          -- If looking for a doc setup with a specific concept (p_doc_concept_code is optional)
          AND cdv.doc_concept_code LIKE (CASE WHEN cp_doc_concept_code IS NOT NULL THEN cp_doc_concept_code ELSE cdv.doc_concept_code END)

          ORDER BY decode (cp_preceding,NULL,0, -- IF there is a preceding document standalones should have lower priorty
                   decode(cdv.doc_concept_code,'STANDALONE',1,0)),
                   automation_priority ;

          lv2_result VARCHAR2(32);
          ld_processing_period DATE;
          lv2_preceding_doc_key VARCHAR2(32);
          lv2_Price_Concept_Code    VARCHAR2(32);
          lv2_price_object_id       VARCHAR2(32);
          lv2_product_id            VARCHAR2(32);
          lrec_rsPd                 IFAC_CARGO_VALUE%ROWTYPE;

BEGIN

    lt_transaction_template := T_TABLE_MIXED_DATA();

    IF p_Rec_ICV.Contract_Id IS NOT NULL THEN
       ld_processing_period := ecdp_revn_ifac_common.GetCargoProcessingPeriod(p_Rec_ICV, ec_contract.start_date(p_Rec_ICV.Contract_Id));
    END IF;

    IF p_Rec_ICV.ORIGINAL_IFAC_DATA IS NOT NULL THEN
        -- Get the orignal ifac record and re-analyse it
        lrec_rsPd := Ecdp_Inbound_Interface.DecodeOriginalCargoRecord(p_Rec_ICV.Original_Ifac_Data);
        lv2_price_object_id    := ec_product_price.object_id_by_uk(lrec_rsPd.Price_Object_Code);

        IF lv2_price_object_id IS NOT NULL THEN
           lv2_Price_Concept_Code := nvl(lrec_rsPd.Price_Concept_Code,ec_product_price.price_concept_code(lv2_price_object_id));
           lv2_product_id := nvl(ec_product.object_id_by_uk(lrec_rsPd.Product_Code),ec_product_price.product_id(lv2_price_object_id));
        ELSE
            lv2_product_id := ec_product.object_id_by_uk(lrec_rsPd.Product_Code);
        END IF;

    ELSE
        lv2_price_object_id := p_rec_icv.price_object_id;
        lv2_Price_Concept_Code := p_Rec_Icv.Price_Concept_Code;
        lv2_product_id := p_Rec_Icv.product_id;
    END IF;

    lv2_preceding_doc_key := ecdp_document_gen_util.GetCargoPrecedingDocKey(p_Rec_ICV.contract_id,
                                 p_Rec_ICV.cargo_no,
                                 p_Rec_ICV.Parcel_No,
                                 NULL ,
                                 p_Rec_ICV.Bl_Date,
                                 NULL,
                                 p_Rec_ICV.customer_id);

    FOR tt IN c_tt(ld_processing_period,
                   p_Rec_Icv.Contract_Id,
                   lv2_Price_Concept_Code,
                   lv2_price_object_id,
                   p_rec_icv.uom1_code,
                   lv2_product_id,
                   p_Rec_Icv.Qty_Type,
                   p_Rec_Icv.ifac_tt_conn_code,
                   lv2_preceding_doc_key,
                   p_doc_concept_code) LOOP

                lv2_result := tt.object_id;
                lt_transaction_template.EXTEND(1);
                lt_transaction_template(lt_transaction_template.LAST) := T_MIXED_DATA(lv2_result,tt.name);
                lt_transaction_template(lt_transaction_template.LAST).text_1 :=  tt.object_code;

     END LOOP;

     lt_transaction_template.EXTEND(1);
     lt_transaction_template(lt_transaction_template.LAST) := T_MIXED_DATA('','Default Transaction Template');
     lt_transaction_template(lt_transaction_template.LAST).text_1 :=  'Default_Transaction_Template';

     RETURN lt_transaction_template;

END GetAllPossibleIfacCargoTT;

-----------------------------------------------------------------------------------------------------------------------------


PROCEDURE ReanalyseAccruals IS
   cursor cr_Accruals is
   select document_key, processing_period
     FROM ACCRUALS_FOR_REANALYSE;

  BEGIN
    FOR Accruals in cr_accruals loop
      IF ec_cont_document.doc_scope(Accruals.document_key) = 'CARGO_BASED' THEN
        ReAnalyseAllCargoRecords(ec_cont_document.object_id(Accruals.document_key),Accruals.document_key);
      ELSE
        ReAnalyseAllSalesQtyRecords(ec_cont_document.object_id(Accruals.document_key),Accruals.Processing_Period);
      END IF;
    END LOOP;
    DELETE FROM ACCRUALS_FOR_REANALYSE;

END ReanalyseAccruals;

END EcDp_Inbound_Interface;