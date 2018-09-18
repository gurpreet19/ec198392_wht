CREATE OR REPLACE PACKAGE EcDp_REVN_FT_CONSTANTS IS
    -----------------------------------------------------------------------
    -- Sub-type for FT Document Contract Groups.
    ----+----------------------------------+-------------------------------
    SUBTYPE T_CONT_GUP IS EcDp_REVN_CONSTANTS.T_EC_CODE;

    -- All
    cont_gup_ALL                           CONSTANT T_CONT_GUP := 'ALL';
    -- All Cargo Based
    cont_gup_ALL_CARGO                     CONSTANT T_CONT_GUP := 'ALL_CARGO';
    -- All Period Based
    cont_gup_ALL_PERIOD                    CONSTANT T_CONT_GUP := 'ALL_PERIOD';

    -----------------------------------------------------------------------
    -- Sub-type for FT Document Concepts.
    ----+----------------------------------+-------------------------------
    SUBTYPE T_DOC_CONCEPT IS EcDp_REVN_CONSTANTS.T_EC_CODE;

    -- Standalone Document
    doc_concept_STANDALONE                 CONSTANT T_DOC_CONCEPT := 'STANDALONE';
    -- Dependent Document with reinvoice non QTY line items
    doc_concept_DPDT                       CONSTANT T_DOC_CONCEPT := 'DEPENDENT';
    -- Dependent Document without reversal
    doc_concept_DPDT_WITHOUT_REVS          CONSTANT T_DOC_CONCEPT := 'DEPENDENT_WITHOUT_REVERSAL';
    -- Dependent Document without reinvoice non QTY line items
    doc_concept_DPDT_PART_REVS             CONSTANT T_DOC_CONCEPT := 'DEPENDENT_PARTIALLY_REVERSAL';
    -- Dependent Document with reversal of QTY line items only
    doc_concept_DPDT_ONLY_QTY_REVS         CONSTANT T_DOC_CONCEPT := 'DEPENDENT_ONLY_QTY_REVERSAL';
    -- Dependent Previous Month Correction
    doc_concept_DPDT_PREV_MTH_CORR         CONSTANT T_DOC_CONCEPT := 'DEPENDENT_PREV_MTH_CORR';
    -- Multi Period Document
    doc_concept_MULTI_PERIOD               CONSTANT T_DOC_CONCEPT := 'MULTI_PERIOD';
    -- Reallocation Document
    doc_concept_REALLOCATION               CONSTANT T_DOC_CONCEPT := 'REALLOCATION';
    -- PPA Document
    doc_concept_PPA                        CONSTANT T_DOC_CONCEPT := 'PPA';

    -----------------------------------------------------------------------
    -- Sub-type for FT transaction scopes.
    ----+----------------------------------+-------------------------------
    SUBTYPE T_TRANS_SCOPE IS EcDp_REVN_CONSTANTS.T_EC_CODE;

    trans_scope_period                     CONSTANT T_TRANS_SCOPE := 'PERIOD_BASED';
    trans_scope_cargo                      CONSTANT T_TRANS_SCOPE := 'CARGO_BASED';

    -----------------------------------------------------------------------
    -- Sub-type for FT line item based types.
    ----+----------------------------------+-------------------------------
    SUBTYPE T_LI_BTYPE IS EcDp_REVN_CONSTANTS.T_EC_CODE;

    li_btype_quantity                      CONSTANT T_LI_BTYPE := 'QTY';
    li_btype_free_unit                     CONSTANT T_LI_BTYPE := 'FREE_UNIT';
    li_btype_free_unit_po                  CONSTANT T_LI_BTYPE := 'FREE_UNIT_PRICE_OBJECT';
    li_btype_fixed_value                   CONSTANT T_LI_BTYPE := 'FIXED_VALUE';
    li_btype_percentage_all                CONSTANT T_LI_BTYPE := 'PERCENTAGE_ALL';
    li_btype_percentage_qty                CONSTANT T_LI_BTYPE := 'PERCENTAGE_QTY';
    li_btype_percentage_manual             CONSTANT T_LI_BTYPE := 'PERCENTAGE_MANUAL';
    li_btype_interest                      CONSTANT T_LI_BTYPE := 'INTEREST';

    -----------------------------------------------------------------------
    -- Sub-type for FT line item distribution methods.
    ----+----------------------------------+-------------------------------
    SUBTYPE T_LI_DIST_MTD IS EcDp_REVN_CONSTANTS.T_EC_CODE;

    -- Derived direcly from quantity line item split, Changings in QTY cascade to Line item
    li_dist_mtd_qty_li                     CONSTANT T_LI_DIST_MTD := 'QTY';
    -- Distribution split sat with full config on the document setup
    li_dist_mtd_sys_split_key              CONSTANT T_LI_DIST_MTD := 'DIST';
    -- Pulling splits from the object list sat up on the transactions's config
    li_dist_mtd_sys_obj_list               CONSTANT T_LI_DIST_MTD := 'OBJ_LIST';
    -- Used shares coming from ifac. This dist method is only for getting priority
    -- margin purpose, should not be stored as line item meta.
    li_dist_mtd_ifac                       CONSTANT T_LI_DIST_MTD := 'IFAC';
    -- Levels were interfaced into IFAC and distribution is used
    li_dist_mtd_ifac_pc_only               CONSTANT T_LI_DIST_MTD := 'IFAC_COMP';
    -- Interfaced in Profit center level but Company split is pulling from object list or vendor split
    li_dist_mtd_ifac_all                   CONSTANT T_LI_DIST_MTD := 'IFAC_PC';

    -- Gets the distribution priority
    FUNCTION li_dist_mtd_priority(
        p_dist_mtd                         T_LI_DIST_MTD
        )
    RETURN NUMBER;

    -----------------------------------------------------------------------
    -- Sub-type for FT document interface record levels.
    ----+----------------------------------+-------------------------------
    SUBTYPE T_IFAC_LEVEL IS VARCHAR2(7);
    -- Transaction level
    ifac_level_transaction                 CONSTANT T_IFAC_LEVEL :=  'TRANS';
    -- Line item level
    ifac_level_line_item                   CONSTANT T_IFAC_LEVEL := 'LI';
    -- Field level
    ifac_level_profit_center               CONSTANT T_IFAC_LEVEL :=  'FIELD';
    -- Vendor level
    ifac_level_vendor                      CONSTANT T_IFAC_LEVEL :=  'VENDOR';

    -----------------------------------------------------------------------
    -- Sub-type for FT document interface record creation type.
    ----+----------------------------------+-------------------------------
    SUBTYPE T_IFAC_CTYPE IS VARCHAR2(15);
    -- Ifac record is interfaced in
    ifac_ctype_interface                   CONSTANT T_IFAC_CTYPE := 'INTERFACE';
    -- Ifac record is created by the system
    ifac_ctype_auto_gen                    CONSTANT T_IFAC_CTYPE := 'AUTO_GENERATED';

    -----------------------------------------------------------------------
    -- Sub-type for FT object creation method.
    ----+----------------------------------+-------------------------------
    SUBTYPE T_C_MTD IS VARCHAR2(15);
    -- The object is created manually by the user (default value)
    c_mtd_manual                      CONSTANT T_C_MTD := 'MANUAL';
    -- The object is created from interface data
    c_mtd_interface                   CONSTANT T_C_MTD := 'INTERFACE';
    -- The object is created by the system automatically
    c_mtd_auto_gen                    CONSTANT T_C_MTD := 'AUTO_GENERATED';
    -- The object is created by the system automatically
    c_mtd_other                       CONSTANT T_C_MTD := 'OTHER';

    -----------------------------------------------------------------------
    -- Codes used in FT document interface.
    ----+----------------------------------+-------------------------------
    -- Vendor code used on transaction and line item level of
    -- FT document interface records to represents a non-exist summary
    -- object
    ifac_sum_code                          CONSTANT EcDp_REVN_CONSTANTS.T_OBJECT_CODE := 'SUM';
    -- Profit center code suffix used on FT document interface records to
    -- represents a non-exist summary object
    ifac_sum_vend_code_suffix              CONSTANT EcDp_REVN_CONSTANTS.T_OBJECT_CODE := '_FULL';
    -- Profit center code suffix used on FT document interface (auto-gen)
    -- records to represents a non-exist summary object
    ifac_sum_vendor_code_gen               CONSTANT EcDp_REVN_CONSTANTS.T_OBJECT_CODE := 'AUTO_GEN_FULL';

END EcDp_REVN_FT_CONSTANTS;