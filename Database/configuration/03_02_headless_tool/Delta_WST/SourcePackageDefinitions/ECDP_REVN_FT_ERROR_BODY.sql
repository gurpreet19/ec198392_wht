CREATE OR REPLACE PACKAGE BODY ECDP_REVN_FT_ERROR IS
    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE r_invalid_ifac_vendor_not_ad__
    IS
    BEGIN
        Raise_Application_Error(-20000,
            'The vendor level qty does not add up to match the profit center level qty');
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE r_invalid_ifac_pc_not_add_up
    IS
    BEGIN
        Raise_Application_Error(-20000,
            'The profit center level qty does not add up to match the transaction level qty');
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE r_no_vendor_dist_config_found
    IS
    BEGIN
        Raise_Application_Error(-20000,
            'Vendor configuration not found in the transaction distribution setup');
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE r_invalid_line_item_key(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
        )
    IS
    BEGIN
        Raise_Application_Error(-20000,
            'The line item key ''' || p_line_item_key || ''' is invalid, no line item with the key is found in system.');
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE r_li_dist_ref_exists(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
        )
    IS
    BEGIN
        Raise_Application_Error(-20000,
            'The line item distribution ''' || p_line_item_key || ''' is shared by other line items.');
    END;

END ECDP_REVN_FT_ERROR;