CREATE OR REPLACE PACKAGE ECDP_REVN_COMMON IS

    ge_data_type_not_supported EXCEPTION;
    ge_null_parameter_exception EXCEPTION;

    SUBTYPE T_BOOLEAN_STR IS VARCHAR2(1);
    gv2_true CONSTANT T_BOOLEAN_STR := 'Y';
    gv2_false CONSTANT T_BOOLEAN_STR := 'N';

    SUBTYPE T_VALUE_CATEGORY IS VARCHAR2(32);
    gv2_value_category_object CONSTANT T_VALUE_CATEGORY := 'OBJECT';
    gv2_value_category_object_list CONSTANT T_VALUE_CATEGORY := 'OBJECT_LIST';
    gv2_value_category_ec_code CONSTANT T_VALUE_CATEGORY := 'EC_CODE';

    SUBTYPE T_APPROVAL_STATE IS VARCHAR2(1);
    gv2_approval_state_official CONSTANT T_APPROVAL_STATE := 'O';
    gv2_approval_state_updated CONSTANT T_APPROVAL_STATE := 'U';
    gv2_approval_state_deleted CONSTANT T_APPROVAL_STATE := 'D';
    gv2_approval_state_new CONSTANT T_APPROVAL_STATE := 'N';

    SUBTYPE T_RECORD_STATUS IS VARCHAR2(1);
    gv2_record_status_provisional CONSTANT T_RECORD_STATUS := 'P';
    gv2_record_status_approved CONSTANT T_RECORD_STATUS := 'A';

    SUBTYPE t_param_value_type IS VARCHAR2(32);
    gv2_value_type_string CONSTANT T_PARAM_VALUE_TYPE := 'STRING';
    gv2_value_type_number CONSTANT T_PARAM_VALUE_TYPE := 'NUMBER';
    gv2_value_type_date CONSTANT T_PARAM_VALUE_TYPE := 'DATE';
    gv2_value_type_boolean CONSTANT T_PARAM_VALUE_TYPE := 'BOOLEAN';

    gv2_user_system CONSTANT t_basis_user.user_id%TYPE := 'SYSTEM';
    gv2_split_regex_comma CONSTANT VARCHAR2(32) := '([^,])+';
    gv2_concat_regex_comma CONSTANT VARCHAR2(5) := ',';

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetFullDateString(
         p_date                            DATE
        )
    RETURN VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         VARCHAR2
        ,p_value_2                         VARCHAR2
        ,p_true_when_value_1_is_null       T_BOOLEAN_STR DEFAULT gv2_false
        )
    RETURN T_BOOLEAN_STR;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         NUMBER
        ,p_value_2                         NUMBER
        ,p_true_when_value_1_is_null       T_BOOLEAN_STR DEFAULT gv2_false
        )
    RETURN T_BOOLEAN_STR;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         DATE
        ,p_value_2                         DATE
        ,p_true_when_value_1_is_null       T_BOOLEAN_STR DEFAULT gv2_false
        )
    RETURN T_BOOLEAN_STR;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         VARCHAR2
        ,p_value_2                         VARCHAR2
        ,p_true_when_value_1_is_null       BOOLEAN
        )
    RETURN BOOLEAN;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         NUMBER
        ,p_value_2                         NUMBER
        ,p_true_when_value_1_is_null       BOOLEAN
        )
    RETURN BOOLEAN;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         DATE
        ,p_value_2                         DATE
        ,p_true_when_value_1_is_null       BOOLEAN
        )
    RETURN BOOLEAN;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION TranslateBoolean(
         lp_value                          BOOLEAN
        )
    RETURN T_BOOLEAN_STR;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION TranslateToBoolean(
         lp_value                          T_BOOLEAN_STR
        )
    RETURN BOOLEAN;

    -----------------------------------------------------------------------
    -- Raise Application Error when given value is null.
    ----+----------------------------------+-------------------------------
    PROCEDURE RaiseAppErrorWhenNull(
         p_value                           VARCHAR2
        ,p_error_msg                       VARCHAR2
        ,p_error_no                        NUMBER DEFAULT -20000
        );
    -----------------------------------------------------------------------
    -- Splits a string into rows using given splitor regular expression.
    ----+----------------------------------+-------------------------------
    FUNCTION SplitStr(
         p_str                             VARCHAR2
        ,p_split_regex                     VARCHAR2
        )
    RETURN T_TABLE_VARCHAR2;
    -----------------------------------------------------------------------
    -- Splits a comma-splited string into rows.
    ----+----------------------------------+-------------------------------
    FUNCTION SplitStrByComma(
         p_str                             VARCHAR2
        )
    RETURN T_TABLE_VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Concat(
         p_str                             T_TABLE_VARCHAR2
        ,p_split                           VARCHAR2
        )
    RETURN VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION ConcatByComma(
         p_str                             T_TABLE_VARCHAR2
        )
    RETURN VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Code(
         p_code_text                       VARCHAR2
        ,p_code_type                       VARCHAR2
        )
    RETURN PROSTY_CODES.CODE%TYPE;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetNumbers(
         p_to                              NUMBER
        )
    RETURN T_TABLE_NUMBER;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION get_ratio(
        p_part                             NUMBER
       ,p_total                            NUMBER
       )
    RETURN NUMBER;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION get_next(
        p_collection                       IN OUT NOCOPY t_table_varchar2
       ,p_index                            IN OUT NUMBER
       )
    RETURN VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION append(
        p_collection                       IN OUT NOCOPY t_table_varchar2
       ,p_value                            VARCHAR2
       )
    RETURN NUMBER;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION append(
        p_collection                       IN OUT NOCOPY t_table_number
       ,p_value                            NUMBER
       )
    RETURN NUMBER;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE append(
        p_collection                       IN OUT NOCOPY t_table_varchar2
       ,p_value                            VARCHAR2
       );
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE append(
        p_collection                       IN OUT NOCOPY t_table_number
       ,p_value                            NUMBER
       );
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION contains(
        p_collection                       IN OUT NOCOPY t_table_varchar2
       ,p_value                            VARCHAR2
       )
    RETURN BOOLEAN;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION contains(
        p_collection                       IN OUT NOCOPY t_table_number
       ,p_value                            NUMBER
       )
    RETURN BOOLEAN;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------

END ECDP_REVN_COMMON;