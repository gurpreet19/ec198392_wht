CREATE OR REPLACE TYPE BODY T_IFAC_SALES_QTY AS

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION get_split_source_value
    RETURN NUMBER
    IS
    BEGIN
        RETURN CASE line_item_based_type
        WHEN 'QTY' THEN
            QTY1
        WHEN 'FREE_UNIT' THEN
            QTY1
        WHEN 'FREE_UNIT_PRICE_OBJECT' THEN
            QTY1
        WHEN 'FIXED_VALUE' THEN
            PRICING_VALUE
        WHEN 'PERCENTAGE_ALL' THEN
            NULL
        WHEN 'PERCENTAGE_QTY' THEN
            NULL
        WHEN 'PERCENTAGE_MANUAL' THEN
            PERCENTAGE_BASE_AMOUNT
        WHEN 'INTEREST' THEN
            INT_BASE_AMOUNT
        ELSE
            QTY1
        END;
    END;
END;