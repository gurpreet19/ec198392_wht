CREATE OR REPLACE PACKAGE EcDp_REVN_CONSTANTS IS
    -----------------------------------------------------------------------
    -- Sub-type for object codes.
    ----+----------------------------------+-------------------------------
    SUBTYPE T_OBJECT_CODE IS objects.code%TYPE;

    -----------------------------------------------------------------------
    -- Sub-type for object id.
    ----+----------------------------------+-------------------------------
    SUBTYPE T_OBJECT_ID IS objects.object_id%TYPE;

    -----------------------------------------------------------------------
    -- Sub-type for EC Codes (prosty codes).
    ----+----------------------------------+-------------------------------
    SUBTYPE T_EC_CODE IS prosty_codes.code%TYPE;


END EcDp_REVN_CONSTANTS;