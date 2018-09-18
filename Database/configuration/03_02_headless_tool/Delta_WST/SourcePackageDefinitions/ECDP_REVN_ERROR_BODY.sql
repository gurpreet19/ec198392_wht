CREATE OR REPLACE PACKAGE BODY ECDP_REVN_ERROR IS

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE r_null_argument(
        p_argument_name                    VARCHAR2
       )
    IS
    BEGIN
        Raise_Application_Error(
            -20000,
            'The argument ''' || p_argument_name || ''' cannot be null.');
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE assert_argument_not_null(
        p_argument_name                    VARCHAR2
       ,p_argument_value                   VARCHAR2
       )
    IS
    BEGIN
        IF p_argument_value IS NULL THEN
            r_null_argument(p_argument_name);
        END IF;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE assert_argument_not_null(
        p_argument_name                    VARCHAR2
       ,p_argument_value                   NUMBER
       )
    IS
    BEGIN
        IF p_argument_value IS NULL THEN
            r_null_argument(p_argument_name);
        END IF;
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE assert_argument_not_null(
        p_argument_name                    VARCHAR2
       ,p_argument_value                   DATE
       )
    IS
    BEGIN
        IF p_argument_value IS NULL THEN
            r_null_argument(p_argument_name);
        END IF;
    END;

END ECDP_REVN_ERROR;