CREATE OR REPLACE TYPE T_REVN_DATA_EXT_PARAM_VAL AS OBJECT (
     PARAMETER_NAME                    VARCHAR2(240)
    ,PARAMETER_VAL_STRING              VARCHAR2(240)
    ,PARAMETER_VAL_FORMAT              VARCHAR2(32)


    -----------------------------------------------------------------------
    -- Initializes a new T_REVN_DATA_EXT_PARAM_VAL object.
    ----+----------------------------------+-------------------------------
    ,CONSTRUCTOR FUNCTION T_REVN_DATA_EXT_PARAM_VAL (
         p_parameter_name                  IN VARCHAR2
        ,p_parameter_value                 IN VARCHAR2
    ) RETURN SELF AS RESULT
)
;