CREATE OR REPLACE PACKAGE ECDP_REVN_ERROR IS

    -----------------------------------------------------------------------
    -- Exception for debugging purpose.
    ----+----------------------------------+-------------------------------
    debug_exception EXCEPTION;

    -----------------------------------------------------------------------
    -- Exception caused by running into a not implemented logic.
    ----+----------------------------------+-------------------------------
    not_implemented EXCEPTION;

    -----------------------------------------------------------------------
    -- Exception caused by null argument value.
    ----+----------------------------------+-------------------------------
    null_argument EXCEPTION;

    -----------------------------------------------------------------------
    -- Exception caused by invalid argument value.
    ----+----------------------------------+-------------------------------
    invalid_argument_value EXCEPTION;

    -----------------------------------------------------------------------
    -- Raises an application error for null_argument exception.
    ----+----------------------------------+-------------------------------
    PROCEDURE r_null_argument(
        p_argument_name                    VARCHAR2
       );

    -----------------------------------------------------------------------
    -- Asserts an argument is not null. When null, an application error is
    -- thrown.
    ----+----------------------------------+-------------------------------
    PROCEDURE assert_argument_not_null(
        p_argument_name                    VARCHAR2
       ,p_argument_value                   VARCHAR2
       );

    -----------------------------------------------------------------------
    -- Asserts an argument is not null. When null, an application error is
    -- thrown.
    ----+----------------------------------+-------------------------------
    PROCEDURE assert_argument_not_null(
        p_argument_name                    VARCHAR2
       ,p_argument_value                   NUMBER
       );


    -----------------------------------------------------------------------
    -- Asserts an argument is not null. When null, an application error is
    -- thrown.
    ----+----------------------------------+-------------------------------
    PROCEDURE assert_argument_not_null(
        p_argument_name                    VARCHAR2
       ,p_argument_value                   DATE
       );

END ECDP_REVN_ERROR;