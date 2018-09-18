CREATE OR REPLACE TYPE BODY T_REVN_DATA_EXT_PARAM_VAL AS

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    CONSTRUCTOR FUNCTION T_REVN_DATA_EXT_PARAM_VAL (
         p_parameter_name                  IN VARCHAR2
        ,p_parameter_value                 IN VARCHAR2
    ) RETURN SELF AS RESULT
    IS
    BEGIN
        PARAMETER_NAME := p_parameter_name;
        PARAMETER_VAL_STRING := p_parameter_value;

        RETURN;
    END;
END;