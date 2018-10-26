CREATE OR REPLACE PACKAGE BODY EcDp_REVN_IFAC_WRAPPER IS

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetIfacRecordLevel_I(
                         p_profit_center_code               VARCHAR2
                        ,p_vendor_code                      VARCHAR2
                        ,p_object_type                        VARCHAR2
                        )
RETURN VARCHAR2
IS
    lv2_level           VARCHAR2(32);
BEGIN
    IF p_profit_center_code = 'SUM'  OR p_object_type = 'OBJECT_LIST'
    THEN
        lv2_level := gconst_level_line_item;
    ELSE
        IF p_vendor_code LIKE '%_FULL'
        THEN
           lv2_level := gconst_level_profit_center;
        ELSE
           lv2_level := gconst_level_vendor;
        END IF;
    END IF;

    RETURN lv2_level;
END GetIfacRecordLevel_I;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Equals_I(       p_value_1                          VARCHAR2
                        ,p_value_2                          VARCHAR2
                        ,p_true_when_value_1_is_null        BOOLEAN
                        )
RETURN BOOLEAN
IS
BEGIN
    IF p_value_1 IS NULL AND p_value_2 IS NULL
    THEN
        RETURN TRUE;
    END IF;

    IF p_true_when_value_1_is_null
    THEN
        RETURN NVL(p_value_1, p_value_2) = p_value_2;
    ELSE
        RETURN p_value_1 = p_value_2;
    END IF;
END Equals_I;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE CheckAndFillDistInfo_I(
                         p_dist_info                        IN OUT NOCOPY T_TABLE_REVN_DIST_INFO
                        ,p_profit_center_id                 VARCHAR2 --DEFAULT NULL
                        ,p_vendor_id                        VARCHAR2 DEFAULT NULL
                        ,p_split_share                      NUMBER  DEFAULT 0
                        )
IS
    lb_ProfitCenter_Found BOOLEAN := false;
    lb_Vendor_Found       BOOLEAN := false;
BEGIN
    IF TRIM(p_profit_center_id) = ''
    THEN
        RETURN;
    END IF;

    -- Looking up existing share
    IF p_dist_info IS NOT NULL AND p_dist_info.COUNT > 0
    THEN
        FOR i_dist_index IN p_dist_info.FIRST .. p_dist_info.LAST
        LOOP
            IF p_dist_info(i_dist_index).PROFIT_CENTER_ID = p_profit_center_id
            THEN
                lb_ProfitCenter_Found  := true;
                IF p_dist_info(i_dist_index).VENDOR_ID = p_vendor_id
                THEN
                    lb_Vendor_Found := true;
                END IF;
            END IF;
        END LOOP;
    END IF;

    -- Add ProfitCenter (and Vendor) if missing
    IF (NOT lb_ProfitCenter_Found) OR (NOT lb_Vendor_Found AND NVL(p_vendor_id,'null') != 'null')
    THEN
        p_dist_info.EXTEND(1);
        p_dist_info(p_dist_info.LAST) := T_REVN_DIST_INFO(null,null,null,null,null,null,null);
        p_dist_info(p_dist_info.LAST).PROFIT_CENTER_ID  := p_profit_center_id;
        p_dist_info(p_dist_info.LAST).VENDOR_ID         := p_vendor_id;
        p_dist_info(p_dist_info.LAST).SPLIT_SHARE       := nvl(p_split_share,0);
    END IF;
END CheckAndFillDistInfo_I;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ContainsObjectID_I(
                         p_object_id_table                  T_TABLE_OBJECT_ID
                        ,p_object_id                        VARCHAR2
                        )
RETURN BOOLEAN
IS
BEGIN
    IF p_object_id_table.COUNT > 0
    THEN
        FOR i_index IN p_object_id_table.FIRST .. p_object_id_table.LAST
        LOOP
            IF Equals_I(p_object_id, p_object_id_table(i_index), FALSE)
            THEN
                RETURN TRUE;
            END IF;
        END LOOP;
    END IF;

    RETURN FALSE;
END ContainsObjectID_I;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION ContainsDistInfo_I(
                         p_dist_info                        T_TABLE_REVN_DIST_INFO
                        ,p_vendor_id                        VARCHAR2
                        ,p_profit_center_id                 VARCHAR2
                        )
RETURN BOOLEAN
IS
BEGIN
    IF p_dist_info.COUNT > 0
    THEN
        FOR i_index IN p_dist_info.FIRST .. p_dist_info.LAST
        LOOP
            IF Equals_I(p_vendor_id, p_dist_info(i_index).VENDOR_ID, TRUE)
                AND Equals_I(p_profit_center_id, p_dist_info(i_index).PROFIT_CENTER_ID, TRUE)
            THEN
                RETURN TRUE;
            END IF;
        END LOOP;
    END IF;

    RETURN FALSE;
END ContainsDistInfo_I;
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
RETURN BOOLEAN
IS
BEGIN
    IF Equals_I(p_target_profit_center_id, p_current_profit_center_id, TRUE)
        AND Equals_I(p_target_vendor_id, p_current_vendor_id, TRUE)
        AND COALESCE(p_level_calculate_from_actual, p_level_calculate_from, p_current_interface_level) = p_current_interface_level
    THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END ShouldAddQuantity_I;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE AddPCDistInfo_I(
                         p_dist_info_table                  IN OUT NOCOPY ECDP_REVN_IFAC_WRAPPER.T_TABLE_OBJECT_ID
                        ,p_profit_center_id                 VARCHAR2
                        )
IS
BEGIN
    p_dist_info_table.EXTEND(1);
    p_dist_info_table(p_dist_info_table.LAST) := p_profit_center_id;
END AddPCDistInfo_I;
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
                        )
IS
BEGIN
    p_dist_info_table.EXTEND(1);
    p_dist_info_table(p_dist_info_table.LAST) := T_REVN_DIST_INFO(null,null,null,null,null,null,null);
    p_dist_info_table(p_dist_info_table.LAST).STREAM_ITEM_ID         := p_stream_item_id;
    p_dist_info_table(p_dist_info_table.LAST).PROFIT_CENTER_ID       := p_distributin_object_id;
    p_dist_info_table(p_dist_info_table.LAST).VENDOR_ID              := p_vendor_id;
    p_dist_info_table(p_dist_info_table.LAST).SPLIT_KEY_ID           := p_split_key_id;
    p_dist_info_table(p_dist_info_table.LAST).CHILD_SPLIT_KEY_ID     := p_child_split_key_id;
    p_dist_info_table(p_dist_info_table.LAST).SPLIT_SHARE            := p_split_share;

END AddVendorDistInfo_I;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION FindDistInfo_I(
                         p_dist_info_table                  T_TABLE_REVN_DIST_INFO
                        ,p_profit_center_id_to_find         VARCHAR2                             -- OPTIONAL
                        ,p_vendor_id_to_find                VARCHAR2                             -- OPTIONAL
                        )
RETURN NUMBER
IS
    ln_found_dist_info NUMBER;
BEGIN
    IF p_dist_info_table.COUNT = 0
    THEN
        RETURN NULL;
    END IF;

    FOR i_index IN p_dist_info_table.FIRST .. p_dist_info_table.LAST
    LOOP
        IF Equals_I(p_profit_center_id_to_find, p_dist_info_table(i_index).PROFIT_CENTER_ID, p_true_when_value_1_is_null => TRUE)
            AND Equals_I(p_vendor_id_to_find, p_dist_info_table(i_index).VENDOR_ID, p_true_when_value_1_is_null => TRUE)
        THEN
            ln_found_dist_info := i_index;
            EXIT;
        END IF;
    END LOOP;

    RETURN ln_found_dist_info;
END FindDistInfo_I;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE GetPCDistInfo_Trans_I(
                         p_common_data                      T_GET_IFAC_COMMON_DATA
                        ,p_profit_center_dist_info          IN OUT NOCOPY T_TABLE_REVN_DIST_INFO
                        )
IS
    lv2_field_id                                            VARCHAR2(32);
    lt_dist_info                                            ECDP_TRANSACTION.T_TABLE_PC_DIST_INFO;
    lo_current_dist_info                                    ECDP_TRANSACTION.T_PC_DIST_INFO;
    lo_get_dist_info_param                                  ECDP_TRANSACTION.T_PARAM_GetDistInfoRC;
    lt_pc_dist_info                                         ECDP_TRANSACTION.T_TABLE_PROFIT_CENTRE_ID;
    lv_sum_split_share                                      NUMBER:=0;


BEGIN
    IF p_common_data.TRANS_IS_REDUCED_CONFIG THEN

            lt_pc_dist_info:=ECDP_TRANSACTION.GetPCInfoRC(p_common_data.TRANS_DIST_CODE,p_common_data.TRANS_DIST_TYPE,p_common_data.TRANS_DIST_OBJECT_TYPE,p_common_data.IFAC_PERIOD_START_DATE);

            IF lt_pc_dist_info.COUNT > 0 THEN
            FOR i_pc_dist_info IN lt_pc_dist_info.FIRST .. lt_pc_dist_info.LAST LOOP
                IF NOT ContainsDistInfo_I(p_profit_center_dist_info, NULL,lt_pc_dist_info(i_pc_dist_info).PROFIT_CENTRE_ID) THEN
                    p_profit_center_dist_info.EXTEND(1);
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST) := T_REVN_DIST_INFO(null,null,null,null,null,null,null);
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).STREAM_ITEM_ID         := lt_pc_dist_info(i_pc_dist_info).PROFIT_CENTRE_ID;
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).PROFIT_CENTER_ID       := lt_pc_dist_info(i_pc_dist_info).PROFIT_CENTRE_ID;
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).SPLIT_KEY_ID           := p_common_data.TRANS_SPLIT_KEY_ID;
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).CHILD_SPLIT_KEY_ID     := ec_split_key_setup.child_split_key_id(p_common_data.TRANS_SPLIT_KEY_ID, lt_pc_dist_info(i_pc_dist_info).PROFIT_CENTRE_ID, p_common_data.IFAC_PROCESSING_PERIOD, '<=');
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).SPLIT_SHARE            := lt_pc_dist_info(i_pc_dist_info).SPLIT_SHARE;
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).DIST_METHOD            := 'OBJ_LIST';
                END IF;
            END LOOP;
            END IF;

    ELSE
     IF p_common_data.TRANS_USE_STREAM_ITEM_IND='Y' THEN
        FOR i_field IN ECDP_LINE_ITEM.gc_split_key_setup(p_common_data.TRANS_SPLIT_KEY_ID, p_common_data.IFAC_PROCESSING_PERIOD) LOOP
            lv2_field_id := ec_stream_item_version.field_id(i_field.id, p_common_data.IFAC_PROCESSING_PERIOD, '<=');

                IF NOT ContainsDistInfo_I(p_profit_center_dist_info, NULL, lv2_field_id) THEN
                    p_profit_center_dist_info.EXTEND(1);
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST) := T_REVN_DIST_INFO(null,null,null,null,null,null,null);
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).STREAM_ITEM_ID         := i_field.source_member_id;
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).PROFIT_CENTER_ID       := lv2_field_id;
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).SPLIT_KEY_ID           := p_common_data.TRANS_SPLIT_KEY_ID;
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).CHILD_SPLIT_KEY_ID     := ec_split_key_setup.child_split_key_id(p_common_data.TRANS_SPLIT_KEY_ID, i_field.id, p_common_data.IFAC_PROCESSING_PERIOD, '<=');
		IF p_common_data.TRANS_DIST_SPLIT_TYPE = 'PERCENTAGE' THEN
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).SPLIT_SHARE            := Ecdp_split_key.GetSplitShareMth(p_common_data.TRANS_SPLIT_KEY_ID, i_field.id, p_common_data.IFAC_PROCESSING_PERIOD, p_common_data.IFAC_UOM1_CODE, 'SP_SPLIT_KEY');

                ELSIF p_common_data.TRANS_DIST_SPLIT_TYPE = 'SOURCE_SPLIT' THEN
                    -- TODO: refactor the logic inside ecdp_transaction.UpdTransSourceSplitShare and get
                    -- split share from it
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).SPLIT_SHARE :=Ecdp_Stream_Item.GetSplitShareMthPC(p_common_data.TRANS_SPLIT_KEY_ID,i_field.source_member_id,p_common_data.IFAC_PERIOD_START_DATE);
                END IF;
		END IF;
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).DIST_METHOD            := 'DIST';
		END LOOP;


            ELSE
            FOR i_field IN ECDP_LINE_ITEM.gc_split_key_setup(p_common_data.TRANS_SPLIT_KEY_ID, p_common_data.IFAC_PROCESSING_PERIOD) LOOP
                IF NOT ContainsDistInfo_I(p_profit_center_dist_info, NULL,i_field.id) THEN
                    p_profit_center_dist_info.EXTEND(1);
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST) := T_REVN_DIST_INFO(null,null,null,null,null,null,null);
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).STREAM_ITEM_ID         := i_field.id;
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).PROFIT_CENTER_ID       := i_field.id;
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).SPLIT_KEY_ID           := p_common_data.TRANS_SPLIT_KEY_ID;
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).CHILD_SPLIT_KEY_ID     := ec_split_key_setup.child_split_key_id(p_common_data.TRANS_SPLIT_KEY_ID,i_field.id, p_common_data.IFAC_PROCESSING_PERIOD, '<=');
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).SPLIT_SHARE            := Ecdp_split_key.GetSplitShareMth(p_common_data.TRANS_SPLIT_KEY_ID, i_field.id, p_common_data.IFAC_PROCESSING_PERIOD, p_common_data.IFAC_UOM1_CODE, 'SP_SPLIT_KEY');
                    p_profit_center_dist_info(p_profit_center_dist_info.LAST).DIST_METHOD            := 'DIST';
                END IF;
            END LOOP;
        END IF;
    END IF;
    --For loop is used to check split share is added to 100%
    lv_sum_split_share:=0;
    IF p_profit_center_dist_info.COUNT > 0 THEN
		FOR i IN p_profit_center_dist_info.FIRST..p_profit_center_dist_info.COUNT
		  LOOP
			IF (i=p_profit_center_dist_info.COUNT) THEN
			p_profit_center_dist_info(i).SPLIT_SHARE:=1-lv_sum_split_share;
			END IF;
			lv_sum_split_share:=lv_sum_split_share + p_profit_center_dist_info(i).SPLIT_SHARE;
		  END LOOP;
    END IF;
END GetPCDistInfo_Trans_I;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetVendorDistInfo_I(
                         p_dist_info                        T_TABLE_REVN_DIST_INFO
                        ,p_profit_center_id                 VARCHAR2
                        )
RETURN T_TABLE_REVN_DIST_INFO
IS
    lo_vendor_dist_info            T_TABLE_REVN_DIST_INFO;
BEGIN
    lo_vendor_dist_info := T_TABLE_REVN_DIST_INFO();

    -- Looking up existing vendor share
    IF p_dist_info IS NOT NULL AND p_dist_info.COUNT > 0
    THEN
        FOR i_dist_index IN p_dist_info.FIRST .. p_dist_info.LAST
        LOOP
            IF  p_dist_info(i_dist_index).PROFIT_CENTER_ID = p_profit_center_id
            AND p_dist_info(i_dist_index).VENDOR_ID IS NOT NULL
            THEN
                ECDP_REVN_IFAC_WRAPPER.AddVendorDistInfo_I(lo_vendor_dist_info, NULL, p_profit_center_id, p_dist_info(i_dist_index).VENDOR_ID, NULL, NULL, p_dist_info(i_dist_index).SPLIT_SHARE);
            END IF;
        END LOOP;
    END IF;

    RETURN lo_vendor_dist_info;
END GetVendorDistInfo_I;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetVendorDistInfoFromConfig_I(
                         p_common_data                      T_GET_IFAC_COMMON_DATA
                        ,p_profit_center_dist_info          T_REVN_DIST_INFO
                        )
RETURN T_TABLE_REVN_DIST_INFO
IS
    lo_vendor_dist_info            T_TABLE_REVN_DIST_INFO;
    lt_dist_info                   ECDP_TRANSACTION.T_TABLE_COMPANY_DIST_INFO;
    lo_current_dist_info           ECDP_TRANSACTION.T_COMPANY_DIST_INFO;
    lo_get_dist_info_param         ECDP_TRANSACTION.T_PARAM_GetDistInfoRC;
    lt_pc_vendor_dist_info         ECDP_TRANSACTION.T_TABLE_PC_VENDOR_ID;
    lv_sum_split_share             NUMBER;


BEGIN
    lo_vendor_dist_info := T_TABLE_REVN_DIST_INFO();

    IF p_common_data.TRANS_IS_REDUCED_CONFIG
    THEN

        lt_pc_vendor_dist_info:=ECDP_TRANSACTION.GetPCInfoRC_Vendor(ec_contract_doc.contract_id(ec_transaction_template.contract_doc_id(p_common_data.IFAC_TRANSACTION_TEMPLATE_ID)),p_common_data.IFAC_PERIOD_START_DATE);

			IF lt_pc_vendor_dist_info.count > 0 Then
				 FOR i_dist_info_index IN lt_pc_vendor_dist_info.FIRST .. lt_pc_vendor_dist_info.LAST
					LOOP

					    IF NOT ECDP_REVN_IFAC_WRAPPER.ContainsDistInfo_I(lo_vendor_dist_info, lt_pc_vendor_dist_info(i_dist_info_index).company_id, NULL)
						  THEN
							ECDP_REVN_IFAC_WRAPPER.AddVendorDistInfo_I(lo_vendor_dist_info, NULL, p_profit_center_dist_info.PROFIT_CENTER_ID, lt_pc_vendor_dist_info(i_dist_info_index).company_id, NULL, NULL, lt_pc_vendor_dist_info(i_dist_info_index).party_share/100);
						END IF;

					END LOOP;
			END IF;


    ELSE
        FOR i_company_dist IN ECDP_LINE_ITEM.gc_split_key_setup_company(
                                 p_profit_center_dist_info.CHILD_SPLIT_KEY_ID,
                                 p_common_data.IFAC_CONTRACT_ID,
                                 p_common_data.IFAC_CUSTOMER_ID,
                                 p_common_data.CONTRACT_FINANCIAL_CODE,
                                 p_common_data.IFAC_PROCESSING_PERIOD)
        LOOP
            IF NOT ECDP_REVN_IFAC_WRAPPER.ContainsDistInfo_I(lo_vendor_dist_info, i_company_dist.VENDOR_ID, NULL)
            THEN

                ECDP_REVN_IFAC_WRAPPER.AddVendorDistInfo_I(lo_vendor_dist_info, NULL, p_profit_center_dist_info.PROFIT_CENTER_ID, i_company_dist.VENDOR_ID, NULL, NULL, i_company_dist.VENDOR_SHARE);
            END IF;
        END LOOP;
   END IF;
   --For loop is used to check split share is added to 100%
   IF lo_vendor_dist_info.count > 0 THEN
		lv_sum_split_share:=0;
		FOR i IN lo_vendor_dist_info.FIRST..lo_vendor_dist_info.COUNT
			LOOP
				IF (i=lo_vendor_dist_info.COUNT ) THEN
					lo_vendor_dist_info(i).SPLIT_SHARE:=1-lv_sum_split_share;
				END IF;
					lv_sum_split_share:=lv_sum_split_share + lo_vendor_dist_info(i).SPLIT_SHARE;
		  END LOOP;
    END IF;
   RETURN lo_vendor_dist_info;
END GetVendorDistInfoFromConfig_I;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION FilterPCDistInfoItem_I(
                         p_profit_center_dist_info          T_TABLE_REVN_DIST_INFO
                        ,p_profit_centers_to_keep           T_TABLE_OBJECT_ID
                        )
RETURN T_TABLE_REVN_DIST_INFO
IS
    ln_index_to_keep NUMBER;
    lt_dist_info T_TABLE_REVN_DIST_INFO;
BEGIN
    lt_dist_info := T_TABLE_REVN_DIST_INFO();

    IF p_profit_centers_to_keep.COUNT > 0
    THEN
        FOR i_index IN p_profit_centers_to_keep.FIRST .. p_profit_centers_to_keep.LAST
        LOOP
            ln_index_to_keep := FindDistInfo_I(p_profit_center_dist_info, p_profit_centers_to_keep(i_index), NULL);

            IF ln_index_to_keep IS NOT NULL
            THEN
                lt_dist_info.EXTEND(1);
                lt_dist_info(lt_dist_info.LAST) := p_profit_center_dist_info(ln_index_to_keep);
            END IF;
        END LOOP;
    END IF;

    RETURN lt_dist_info;
END FilterPCDistInfoItem_I;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------


END EcDp_REVN_IFAC_WRAPPER;