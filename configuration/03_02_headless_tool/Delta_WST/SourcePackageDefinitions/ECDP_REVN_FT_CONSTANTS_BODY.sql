CREATE OR REPLACE PACKAGE BODY EcDp_REVN_FT_CONSTANTS IS

    -----------------------------------------------------------------------
    -- Sub-type for FT line item distribution methods.
    ----+----------------------------------+-------------------------------
    FUNCTION li_dist_mtd_priority(
        p_dist_mtd                         T_LI_DIST_MTD
        )
    RETURN NUMBER
    IS
    BEGIN
        RETURN CASE p_dist_mtd
            WHEN li_dist_mtd_ifac_all THEN 1
            WHEN li_dist_mtd_ifac_pc_only THEN 2
            WHEN li_dist_mtd_ifac THEN 3
            WHEN li_dist_mtd_qty_li THEN 4
            WHEN li_dist_mtd_sys_split_key THEN 5
            WHEN li_dist_mtd_sys_obj_list THEN 6
            ELSE -1
        END;
    END;

END EcDp_REVN_FT_CONSTANTS;