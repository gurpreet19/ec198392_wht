CREATE OR REPLACE PACKAGE ECDP_REVN_FT_ERROR IS

    -----------------------------------------------------------------------
    -- Exception caused by incorrect ifac data, where the vendor level qty
    -- does not add up to match the profit center level qty
    ----+----------------------------------+-------------------------------
    invalid_ifac_vendor_not_add_up EXCEPTION;

    -----------------------------------------------------------------------
    -- Exception caused by incorrect ifac data, where the profit center
    -- level qty does not add up to match the transaction level qty
    ----+----------------------------------+-------------------------------
    invalid_ifac_pc_not_add_up EXCEPTION;

    -----------------------------------------------------------------------
    -- Exception caused by vendor configuration not found in the
    -- transaction distribution setup
    ----+----------------------------------+-------------------------------
    no_vendor_dist_config_found EXCEPTION;

    -----------------------------------------------------------------------
    -- Exception caused by an invalid line item key.
    ----+----------------------------------+-------------------------------
    invalid_line_item_key EXCEPTION;

    -----------------------------------------------------------------------
    -- Exception caused by an invalid transaction scope.
    ----+----------------------------------+-------------------------------
    invalid_trans_scope EXCEPTION;

    -----------------------------------------------------------------------
    -- Exception caused by the operating line item's distribution is
    -- referenced by other items.
    ----+----------------------------------+-------------------------------
    li_dist_ref_exists EXCEPTION;

    PROCEDURE r_invalid_ifac_vendor_not_ad__;
    PROCEDURE r_invalid_ifac_pc_not_add_up;
    PROCEDURE r_no_vendor_dist_config_found;
    PROCEDURE r_li_dist_ref_exists(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
        );
    PROCEDURE r_invalid_line_item_key(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
        );

END ECDP_REVN_FT_ERROR;