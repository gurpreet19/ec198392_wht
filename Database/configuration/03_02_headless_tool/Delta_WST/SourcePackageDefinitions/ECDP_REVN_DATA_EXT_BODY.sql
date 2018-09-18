CREATE OR REPLACE PACKAGE BODY EcDp_Revn_Data_Ext IS

    -----------------------------------------------------------------------
    -- [PRIVATE] Type declarations
    ----+----------------------------------+-------------------------------
    SUBTYPE t_data_format IS VARCHAR2(32);
    SUBTYPE t_operator IS revn_data_filter_rule.op%TYPE;
    SUBTYPE t_version_rule IS revn_data_filter_version.version_rule%TYPE;
    SUBTYPE t_value_category IS revn_data_filter_rule.value_category%TYPE;
    SUBTYPE t_execution_mode IS VARCHAR2(12);
    SUBTYPE t_value_expression IS VARCHAR2(320);
    SUBTYPE t_raw_value IS VARCHAR2(320);


    TYPE t_class_attribute_info IS RECORD (
         attribute_name                    class_attribute_cnfg.attribute_name%TYPE
        ,data_type                         class_attribute_cnfg.data_type%TYPE
        ,is_key                            ecdp_revn_common.T_BOOLEAN_STR
    );

    TYPE t_data_filter IS RECORD (
         object_id                         revn_data_filter.object_id%TYPE
        ,object_code                       revn_data_filter.object_code%TYPE
        ,daytime                           revn_data_filter_version.daytime%TYPE
        ,class_to_read                     revn_data_filter.class_to_read%TYPE
        ,NAME                              revn_data_filter_version.NAME%TYPE
        ,description                       revn_data_filter_version.description%TYPE
        ,version_rule                      revn_data_filter_version.version_rule%TYPE
        ,version_attribute                 revn_data_filter_version.version_attribute%TYPE
        ,version_end_attribute             revn_data_filter_version.version_end_attribute%TYPE
        ,version_end_attribute_days_inc    NUMBER
        ,version_from                      t_raw_value
        ,version_from_categor              t_value_category
        ,version_to                        t_raw_value
        ,version_to_categor                t_value_category
    );

    TYPE t_data_filter_rule IS RECORD (
         filter_rule_number                revn_data_filter_rule.filter_rule_number%TYPE
        ,attribute_name                    revn_data_filter_rule.attribute_name%TYPE
        ,op                                revn_data_filter_rule.op%TYPE
        ,value_category                    revn_data_filter_rule.value_category%TYPE
        ,value_expression                  t_value_expression
        ,raw_value                         revn_data_filter_rule.value%TYPE
        ,group_no                          revn_data_filter_rule.group_no%TYPE
    );

    TYPE t_data_filter_param IS RECORD (
         param_name                        revn_data_filter_param.param_name%TYPE
        ,param_value_type                  revn_data_filter_param.param_value_type%TYPE
        ,raw_argument_value                t_raw_value
    );

    TYPE t_execution_context IS RECORD (
         param_data_filter_id              revn_data_filter.object_id%TYPE
        ,param_daytime                     revn_data_filter_version.daytime%TYPE
        ,param_arguments                   t_table_revn_data_ext_arg
        ,param_execution_mode              T_EXECUTION_MODE
        ,param_attribute_to_return         class_attribute_cnfg.attribute_name%TYPE
        ,param_attribute_to_read           class_attribute_cnfg.attribute_name%TYPE
        ,param_max_row_count               NUMBER
    );

    TYPE t_table_class_attribute_info IS TABLE OF t_class_attribute_info;
    TYPE t_table_revn_data_filter_param IS TABLE OF t_data_filter_param;
    TYPE t_table_revn_data_filter_rule IS TABLE OF t_data_filter_rule;

    ex_data_filter_ver_not_found EXCEPTION;
    ex_data_filter_not_found EXCEPTION;
    ex_argument_missing EXCEPTION;
    ex_invalid_argument_value EXCEPTION;
    ex_invalid_value_format EXCEPTION;
    ex_invalid_parameter_data_type EXCEPTION;
    ex_param_n_class_dt_not_match EXCEPTION;
    ex_invalid_class_att_name EXCEPTION;
    ex_parameter_not_found EXCEPTION;
    ex_raw_value_null EXCEPTION;
    ex_invalid_value_category EXCEPTION;
    ex_invalid_fix_value EXCEPTION;

    -----------------------------------------------------------------------
    -- [PRIVATE] Constants
    ----+----------------------------------+-------------------------------
    lv2_default_number_format T_DATA_FORMAT := '9999999999.9999999999';
    lv2_default_date_format T_DATA_FORMAT := 'YYYY-MM-DD"T"HH24:MI:SS';

    lv2_class_att_daytime class_attribute_cnfg.attribute_name%TYPE := 'DAYTIME';
    lv2_class_att_enddate class_attribute_cnfg.attribute_name%TYPE := 'END_DATE';

    lv2_op_equals T_OPERATOR := 'EQUALS';
    lv2_op_not_equals T_OPERATOR := 'NOT_EQUALS';
    lv2_op_greater_than T_OPERATOR := 'GREATER_THAN';
    lv2_op_less_than T_OPERATOR := 'LESS_THAN';
    lv2_op_greater_equal_to T_OPERATOR := 'GREATER_THAN_EQUALS';
    lv2_op_less_equal_to T_OPERATOR := 'LESS_THAN_EQUALS';
    lv2_op_is_null T_OPERATOR := 'IS_NULL';
    lv2_op_is_not_null T_OPERATOR := 'IS_NOT_NULL';
    lv2_op_in T_OPERATOR := 'IN';
    lv2_op_not_in T_OPERATOR := 'NOT_IN';
    lv2_op_like T_OPERATOR := 'LIKE';
    lv2_op_not_like T_OPERATOR := 'NOT_LIKE';

    lv2_val_category_parameter T_VALUE_CATEGORY := 'PARAMETER';
    lv2_val_category_ec_code_list T_VALUE_CATEGORY := 'EC_CODE_LIST';
    lv2_val_category_object_list T_VALUE_CATEGORY := 'OBJECT_LIST';
    lv2_val_category_function T_VALUE_CATEGORY := 'PARAMETERLESS_FUNCTION';
    lv2_val_category_fixed_value T_VALUE_CATEGORY := 'FIXED_VALUE';

    ln_default_group_no revn_data_filter_rule.group_no%TYPE := -1.77;

    lv2_execution_mode_full T_EXECUTION_MODE := 'FULL';
    lv2_execution_mode_attribute T_EXECUTION_MODE := 'SINGLE_ATT';

    lv2_version_rule_all T_VERSION_RULE := 'ALL';
    lv2_version_rule_latest T_VERSION_RULE := 'LATEST';
    lv2_version_rule_earliest T_VERSION_RULE := 'EARLIEST';
    lv2_version_rule_in_range T_VERSION_RULE := 'IN_RANGE';
    lv2_version_rule_exists_when T_VERSION_RULE := 'EXISTS_WHEN';

    lv2_raw_data_table_name VARCHAR2(32) := 'raw_data';

    lv2_class_type_object CLASS_CNFG.CLASS_TYPE%TYPE := 'OBJECT';
    lv2_class_type_table CLASS_CNFG.CLASS_TYPE%TYPE := 'TABLE';
    lv2_class_type_data CLASS_CNFG.CLASS_TYPE%TYPE := 'DATA';
    lv2_class_type_interface CLASS_CNFG.CLASS_TYPE%TYPE := 'INTERFACE';

    lv2_ex_att_data_type_integer class_attribute_cnfg.data_type%TYPE := 'INTEGER';


    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- data filter param.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidFParam_P(
         p_filter_param                    IN OUT NOCOPY t_data_filter_param
        ,p_detailed_message                VARCHAR2
    )
    IS
    BEGIN
        raise_application_error(
            -20001,
            'Data filter parameter ''' || p_filter_param.param_name || ''' is invalid. ' || p_detailed_message);
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by data filter
    -- param data type and class attribute data type do not match.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidFParam_ClassAtt_P(
         p_filter_param                    IN OUT NOCOPY t_data_filter_param
        ,p_class_attribute                 IN OUT NOCOPY t_class_attribute_info
    )
    IS
    BEGIN
        Raise_InvalidFParam_P(p_filter_param, 'Data type on paramter (''' || p_filter_param.param_value_type || ''') does not match the one on class attribute ''' || p_class_attribute.attribute_name || ''' (''' || p_class_attribute.data_type || '''), please check data filter configuration which references this parameter.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by wrong
    -- parameter data type. When referenced by version rule, it should be
    -- type DATE.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidFParam_VerS_P(
         p_filter_param                    IN OUT NOCOPY t_data_filter_param
    )
    IS
    BEGIN
        Raise_InvalidFParam_P(p_filter_param, 'Data type on paramter (''' || p_filter_param.param_value_type || ''') has to be ''DATE'' since it is referenced by data filter version rule (from version).');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by wrong
    -- parameter data type. When referenced by version rule, it should be
    -- type DATE.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidFParam_VerT_P(
         p_filter_param                    IN OUT NOCOPY t_data_filter_param
    )
    IS
    BEGIN
        Raise_InvalidFParam_P(p_filter_param, 'Data type on paramter (''' || p_filter_param.param_value_type || ''') has to be ''DATE'' since it is referenced by data filter version rule (to version).');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- data filter rule.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidFilRule_P(
         p_filter_rule                     IN OUT NOCOPY t_data_filter_rule
        ,p_detailed_message                VARCHAR2
    )
    IS
    BEGIN
        raise_application_error(
            -20002,
            'Data filter rule (rule number: ' || p_filter_rule.filter_rule_number || ') is not valid. ' || p_detailed_message);
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- data filter class attribute.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidFilRule_AttName_P(
         p_filter_rule                      IN OUT NOCOPY t_data_filter_rule
    )
    IS
    BEGIN
        Raise_InvalidFilRule_P(p_filter_rule, 'Class attriute ' || p_filter_rule.attribute_name || ' cannot be found. ');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- data filter rule fixed value.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidFilRule_FixVal_P(
         p_filter_rule                      IN OUT NOCOPY t_data_filter_rule
        ,p_matching_class_attribute         IN OUT NOCOPY t_class_attribute_info
        ,p_value_format                     VARCHAR2
    )
    IS
    BEGIN
        Raise_InvalidFilRule_P(p_filter_rule, 'Error on fixed value (''' || p_filter_rule.raw_value || ''') found when tried to parse with data type ''' || p_matching_class_attribute.data_type || ''' and format ''' || p_value_format || ''', according to class attribute ''' || p_matching_class_attribute.attribute_name || '''. ');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by null value
    -- on data filter rule.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidFilRule_ValNull_P(
         p_filter_rule                      IN OUT NOCOPY t_data_filter_rule
    )
    IS
    BEGIN
        Raise_InvalidFilRule_P(p_filter_rule, 'Value provided on data filter rule cannot be null. ');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- value category on data filter rule.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidFilRule_InvCat_P(
         p_filter_rule                     IN OUT NOCOPY t_data_filter_rule
    )
    IS
    BEGIN
        Raise_InvalidFilRule_P(p_filter_rule, 'Value category ''' || p_filter_rule.value_category || ''' is not supported. ');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- parameter reference on data filter rule.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidFilRule_InvPara_P(
         p_filter_rule                     IN OUT NOCOPY t_data_filter_rule
    )
    IS
    BEGIN
        Raise_InvalidFilRule_P(p_filter_rule, 'Parameter ''' || p_filter_rule.raw_value || ''' is not found. ');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- data filter.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_P(
         p_detailed_message                VARCHAR2
    )
    IS
    BEGIN
        raise_application_error(-20003, 'Data filter is invalid. ' || p_detailed_message);
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- from version value.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerFVal_P(
         p_version_rule_raw_val            VARCHAR2
        ,p_value_format                    IN OUT NOCOPY t_data_format
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('Error on version rule - from version value (' || p_version_rule_raw_val || ') found when tried to parse with data type ''' || ecdp_revn_common.gv2_value_type_date || ''' and format ''' || p_value_format || '''.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- to version value.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerTVal_P(
         p_version_rule_raw_val            VARCHAR2
        ,p_value_format                    IN OUT NOCOPY t_data_format
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('Error on version rule - to version value (' || p_version_rule_raw_val || ') found when tried to parse with data type ''' || ecdp_revn_common.gv2_value_type_date || ''' and format ''' || p_value_format || '''.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by null
    -- start version attribute.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerSAttNul_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('Version Attribute cannot be null.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by null
    -- end version attribute.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerEAttNul_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('End Version Attribute cannot be null.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- start version attribute.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerSAttNF_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('Version Attribute ''' || p_data_filter.version_attribute || ''' is not found on class ''' || p_data_filter.class_to_read || '''.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- end version attribute.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerEAttNF_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('Version Attribute ''' || p_data_filter.version_end_attribute || ''' is not found on class ''' || p_data_filter.class_to_read || '''.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by null found
    -- on From Version raw value.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerFNull_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('From version cannot be null.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by null found
    -- on To Version raw value.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerTNull_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('To version cannot be null.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- value category of from version.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerFCat_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('Value category ' || p_data_filter.version_from_categor || ''' is not supported.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- value category of to version.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerTCat_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('Value category ' || p_data_filter.version_to_categor || ''' is not supported.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by parameter
    -- not found.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerF_PNF_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('Parameter ''' || p_data_filter.version_from || ''' referenced by from version value is not found.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by parameter
    -- not found.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidDFil_VerT_PNF_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('Parameter ''' || p_data_filter.version_to || ''' referenced by to version value is not found.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- parameter referenced by from version value.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidFParam_VerF_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        Raise_InvalidDFil_P('Version Attribute ''' || p_data_filter.version_attribute || ''' is not found on class ''' || p_data_filter.class_to_read || '''.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- parameter value input to public procedures.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_ProcedureParamError_P(
         p_parameter_name                  VARCHAR2
        ,p_parameter_value                 VARCHAR2
        ,p_detailed_message                VARCHAR2
    )
    IS
    BEGIN
        raise_application_error(-20004, 'Value ''' || p_parameter_value || ''' of parameter ''' || p_parameter_name || ''' is not valid. ' || p_detailed_message);
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by null
    -- parameter value.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_NullProcParamError_P(
         p_parameter_name                  VARCHAR2
    )
    IS
    BEGIN
        raise_application_error(-20004, 'Value of parameter ''' || p_parameter_name || ''' cannot be null. ');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- data filter argument error.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidArgVal_P(
         p_argument_name                    VARCHAR2
        ,p_value_in_string                  VARCHAR2
        ,p_detailed_message                VARCHAR2
    )
    IS
    BEGIN
        raise_application_error(-20005, 'Value (''' || p_value_in_string || ''') of data filter parameter ''' || p_argument_name || ''' is invalid. ' || p_detailed_message);
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- data filter argument error.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidArgVal_Bool_P(
         p_argument_name                    VARCHAR2
        ,p_value_in_string                  VARCHAR2
    )
    IS
    BEGIN
        Raise_InvalidArgVal_P(p_argument_name, p_value_in_string, 'The value is not valid as BOOLEAN, possible values are NULL, ''Y'' and ''N''.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Raise an application error which is caused by invalid
    -- data filter argument error.
    ----+----------------------------------+-------------------------------
    PROCEDURE Raise_InvalidArgVal_Other_P(
         p_argument_name                    VARCHAR2
        ,p_value_in_string                  VARCHAR2
        ,p_value_format                     VARCHAR2
    )
    IS
    BEGIN
        Raise_InvalidArgVal_P(p_argument_name, p_value_in_string, 'Tried to parse using format ''' || p_value_format || '''.');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Finds parameter index in given collection.
    ----+----------------------------------+-------------------------------
    FUNCTION FindParameterIdx_P(
         p_parameter_name                  revn_data_filter_param.param_name%TYPE
        ,p_parameters                      IN OUT NOCOPY t_table_revn_data_filter_param
    )
    RETURN NUMBER
    IS
    BEGIN
        FOR p_idx IN p_parameters.first .. p_parameters.last LOOP
            IF p_parameters(p_idx).param_name = p_parameter_name THEN
                RETURN p_idx;
            END IF;
        END LOOP;

        RETURN NULL;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Finds argument in given collection.
    ----+----------------------------------+-------------------------------
    FUNCTION FindArgument_P(
         p_parameter_name                  revn_data_filter_param.param_name%TYPE
        ,p_arguments                       IN OUT NOCOPY t_table_revn_data_ext_arg
    )
    RETURN t_revn_data_ext_param_val
    IS
    BEGIN
        FOR argument_idx IN p_arguments.first .. p_arguments.last LOOP
            IF p_arguments(argument_idx).parameter_name = p_parameter_name THEN
                RETURN p_arguments(argument_idx);
            END IF;
        END LOOP;

        RETURN NULL;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Finds class attribute index from given collection.
    ----+----------------------------------+-------------------------------
    FUNCTION FindClassAttributeIdx_P(
         p_attribute_name                  IN class_attribute_cnfg.attribute_name%TYPE
        ,p_class_attributes                IN OUT NOCOPY t_table_class_attribute_info
    )
    RETURN NUMBER
    IS
    BEGIN
        FOR att_idx IN p_class_attributes.first .. p_class_attributes.last LOOP
            IF p_class_attributes(att_idx).attribute_name = p_attribute_name THEN
                RETURN att_idx;
            END IF;
        END LOOP;

        RETURN NULL;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets default value format.
    ----+----------------------------------+-------------------------------
    FUNCTION GetDefaultValueFormat_P(
         p_parameter_value_type            IN revn_data_filter_param.param_value_type%TYPE
    )
    RETURN T_DATA_FORMAT
    IS
        lv2_data_format T_DATA_FORMAT;
    BEGIN
        lv2_data_format := NULL;

        IF p_parameter_value_type = ecdp_revn_common.gv2_value_type_number THEN
            lv2_data_format := lv2_default_number_format;
        ELSIF p_parameter_value_type = ecdp_revn_common.gv2_value_type_date THEN
            lv2_data_format := lv2_default_date_format;
        END IF;

        RETURN lv2_data_format;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Adds class attribute info.
    ----+----------------------------------+-------------------------------
    PROCEDURE AddClassAttribute_P(
         p_class_attributes                IN OUT NOCOPY t_table_class_attribute_info
        ,p_attribute_name                  IN class_attribute_cnfg.attribute_name%TYPE
        ,p_data_type                       IN class_attribute_cnfg.data_type%TYPE
        ,p_is_key                          IN ecdp_revn_common.T_BOOLEAN_STR
    )
    IS
    BEGIN
        IF FindClassAttributeIdx_P(p_attribute_name, p_class_attributes) IS NULL THEN
            p_class_attributes.extend;
            p_class_attributes(p_class_attributes.last).attribute_name := p_attribute_name;
            p_class_attributes(p_class_attributes.last).data_type := p_data_type;
            p_class_attributes(p_class_attributes.last).is_key := p_is_key;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Adds common class attributes info.
    ----+----------------------------------+-------------------------------
    PROCEDURE AddCommonClassAttributes_P(
         p_class                           IN OUT NOCOPY CLASS_CNFG%ROWTYPE
        ,p_class_attributes                IN OUT NOCOPY t_table_class_attribute_info
    )
    IS
    BEGIN
        AddClassAttribute_P(p_class_attributes, 'CREATED_BY', ecdp_revn_common.gv2_value_type_string, ecdp_revn_common.gv2_false);
        AddClassAttribute_P(p_class_attributes, 'CREATED_DATE', ecdp_revn_common.gv2_value_type_date, ecdp_revn_common.gv2_false);
        AddClassAttribute_P(p_class_attributes, 'LAST_UPDATED_BY', ecdp_revn_common.gv2_value_type_string, ecdp_revn_common.gv2_false);
        AddClassAttribute_P(p_class_attributes, 'LAST_UPDATED_DATE', ecdp_revn_common.gv2_value_type_date, ecdp_revn_common.gv2_false);

        IF p_class.class_type = lv2_class_type_data THEN
            AddClassAttribute_P(p_class_attributes, 'OBJECT_CODE', ecdp_revn_common.gv2_value_type_string, ecdp_revn_common.gv2_false);
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets class attributes information of given class.
    ----+----------------------------------+-------------------------------
    FUNCTION GetClassAttributesInfo_P(
         p_class                           IN OUT NOCOPY CLASS_CNFG%ROWTYPE
    )
    RETURN t_table_class_attribute_info
    IS
        CURSOR lv_get_class_attributes(
            cp_class_name                  class_attribute_cnfg.class_name%TYPE
        )
        IS
            SELECT * FROM (
              SELECT attribute_name, decode(data_type, lv2_ex_att_data_type_integer, ecdp_revn_common.gv2_value_type_number, data_type) AS data_type, is_key
              FROM class_attribute_cnfg
              WHERE class_name = cp_class_name
              UNION ALL
              SELECT ROLE_NAME || '_ID', 'STRING', IS_KEY
              FROM CLASS_RELATION_CNFG WHERE TO_CLASS_NAME = cp_class_name
              UNION ALL
              SELECT 'REV_NO' attribute_name,  'NUMBER' data_type, 'N' is_key FROM DUAL
              )
            ORDER BY DECODE(is_key, ecdp_revn_common.gv2_true, 0, 1), attribute_name;

        lo_result t_table_class_attribute_info;
    BEGIN
        lo_result := t_table_class_attribute_info();

        OPEN lv_get_class_attributes(p_class.class_name);
        FETCH lv_get_class_attributes BULK COLLECT INTO lo_result;
        CLOSE lv_get_class_attributes;

        AddCommonClassAttributes_P(p_class, lo_result);

        RETURN lo_result;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets an object which contains data filter information
    ----+----------------------------------+-------------------------------
    FUNCTION GetDataFilter_P(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
        ,p_daytime                         DATE
    )
    RETURN t_data_filter
    IS
        lo_data_filter revn_data_filter%ROWTYPE;
        ld_data_filter_ver revn_data_filter_version.daytime%TYPE;
        lo_revn_data_filter_version revn_data_filter_version%ROWTYPE;

        lo_result t_data_filter;
    BEGIN
        IF p_data_filter_id IS NULL THEN
            RAISE ex_data_filter_not_found;
        END IF;

        lo_data_filter := ec_revn_data_filter.row_by_pk(p_data_filter_id);

        IF lo_data_filter.object_id IS NULL THEN
            RAISE ex_data_filter_not_found;
        END IF;

        ld_data_filter_ver := ec_revn_data_filter_version.prev_equal_daytime(p_data_filter_id, p_daytime);

        IF ld_data_filter_ver IS NULL THEN
            RAISE ex_data_filter_ver_not_found;
        END IF;

        lo_revn_data_filter_version := ec_revn_data_filter_version.row_by_pk(p_data_filter_id, p_daytime);

        lo_result.object_id := p_data_filter_id;
        lo_result.object_code := lo_data_filter.object_code;
        lo_result.daytime := lo_revn_data_filter_version.daytime;
        lo_result.class_to_read := lo_data_filter.class_to_read;
        lo_result.name := lo_revn_data_filter_version.name;
        lo_result.description := lo_revn_data_filter_version.description;
        lo_result.version_rule := lo_revn_data_filter_version.version_rule;
        lo_result.version_from_categor := lo_revn_data_filter_version.version_rule_value_categor;
        lo_result.version_from := lo_revn_data_filter_version.version_rule_value;
        lo_result.version_attribute := lo_revn_data_filter_version.version_attribute;
        lo_result.version_to_categor := lo_revn_data_filter_version.version_rule_end_value_categor;
        lo_result.version_to := lo_revn_data_filter_version.version_rule_end_value;
        lo_result.version_end_attribute := lo_revn_data_filter_version.version_end_attribute;

        RETURN lo_result;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets filter rules for a data filter version.
    ----+----------------------------------+-------------------------------
    FUNCTION GetRules_P(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
        ,p_data_filter_version             IN revn_data_filter_version.daytime%TYPE
    )
    RETURN t_table_revn_data_filter_rule
    IS
        CURSOR lc_get_data_filter_rules(
            cp_data_filter_id              revn_data_filter.object_id%TYPE
           ,cp_data_filter_version         revn_data_filter_version.daytime%TYPE)
        IS
            SELECT filter_rule_number, attribute_name, op, value_category, NULL, value, NVL(group_no, ln_default_group_no)
            FROM revn_data_filter_rule
            WHERE object_id = cp_data_filter_id
                AND daytime = cp_data_filter_version
            ORDER BY group_no, attribute_name, op, value_category, value;

        lo_result t_table_revn_data_filter_rule;
    BEGIN
        lo_result := t_table_revn_data_filter_rule();

        OPEN lc_get_data_filter_rules(p_data_filter_id, p_data_filter_version);
        FETCH lc_get_data_filter_rules BULK COLLECT INTO lo_result;
        CLOSE lc_get_data_filter_rules;

        RETURN lo_result;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets parameter info for a data filter.
    ----+----------------------------------+-------------------------------
    FUNCTION GetParameters_P(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
    )
    RETURN t_table_revn_data_filter_param
    IS
        CURSOR lc_get_data_filter_parameters(
            cp_data_filter_id              revn_data_filter.object_id%TYPE)
        IS
            SELECT param_name, param_value_type, NULL
            FROM revn_data_filter_param
            WHERE object_id = cp_data_filter_id
            ORDER BY param_name;

        lo_result t_table_revn_data_filter_param;
    BEGIN
        lo_result := t_table_revn_data_filter_param();

        OPEN lc_get_data_filter_parameters(p_data_filter_id);
        FETCH lc_get_data_filter_parameters BULK COLLECT INTO lo_result;
        CLOSE lc_get_data_filter_parameters;

        RETURN lo_result;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Validates parameter exists.
    ----+----------------------------------+-------------------------------
    PROCEDURE ValidateParameterExists_P(
         p_parameter_name                  VARCHAR2
        ,p_parameters                      IN OUT NOCOPY t_table_revn_data_filter_param
    )
    IS
    BEGIN
        IF FindParameterIdx_P(p_parameter_name, p_parameters) IS NULL THEN
            RAISE ex_parameter_not_found;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Validates raw value not null.
    ----+----------------------------------+-------------------------------
    PROCEDURE ValidateRawValueNotNull_P(
         p_raw_value                       t_raw_value
    )
    IS
    BEGIN
        IF p_raw_value IS NULL THEN
            RAISE ex_raw_value_null;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Validates given bollean str string.
    ----+----------------------------------+-------------------------------
    PROCEDURE ValidateBooleanStrString_P(
         p_value_in_string                 VARCHAR2
    )
    IS
    BEGIN
        IF NOT p_value_in_string = ecdp_revn_common.gv2_true
            AND NOT p_value_in_string = ecdp_revn_common.gv2_false THEN
            RAISE ex_invalid_value_format;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Validates given number string.
    ----+----------------------------------+-------------------------------
    PROCEDURE ValidateNumberString_P(
         p_value_in_string                 VARCHAR2
        ,p_value_format                    T_DATA_FORMAT
    )
    IS
        lv2_test_number NUMBER;
    BEGIN
        BEGIN
            lv2_test_number := to_number(p_value_in_string, p_value_format);
        EXCEPTION WHEN OTHERS THEN
            RAISE ex_invalid_value_format;
        END;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Validates given date string.
    ----+----------------------------------+-------------------------------
    PROCEDURE ValidateDateString_P(
         p_value_in_string                 VARCHAR2
        ,p_value_format                    T_DATA_FORMAT
    )
    IS
        lv2_test_date DATE;
    BEGIN
        BEGIN
            lv2_test_date := to_date(p_value_in_string, p_value_format);
        EXCEPTION WHEN OTHERS THEN
            RAISE ex_invalid_value_format;
        END;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Validates version rule settings.
    ----+----------------------------------+-------------------------------
    PROCEDURE ValidateValueCategory_P(
         p_value_category                  t_value_category
        ,p_raw_value                       t_raw_value
        ,p_parameters                      IN OUT NOCOPY t_table_revn_data_filter_param
    )
    IS
    BEGIN
        IF p_value_category = lv2_val_category_parameter THEN
            ValidateRawValueNotNull_P(p_raw_value);
            ValidateParameterExists_P(p_raw_value, p_parameters);

        ELSIF p_value_category = lv2_val_category_fixed_value THEN
            ValidateRawValueNotNull_P(p_raw_value);

        ELSIF p_value_category = lv2_val_category_function THEN
            ValidateRawValueNotNull_P(p_raw_value);

        ELSIF p_value_category = lv2_val_category_object_list THEN
            ValidateRawValueNotNull_P(p_raw_value);

        ELSIF p_value_category = lv2_val_category_ec_code_list THEN
            ValidateRawValueNotNull_P(p_raw_value);

        ELSE
            RAISE ex_invalid_value_category;

        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets value SQL expression.
    ----+----------------------------------+-------------------------------
    FUNCTION GetSimpleValueExpression_P(
         p_value_in_string                 t_raw_value
        ,p_value_type                      VARCHAR2
        ,p_value_format                    T_DATA_FORMAT
    )
    RETURN VARCHAR2
    IS
        lv2_expression VARCHAR2(320);
        lv2_safe_value_in_string VARCHAR2(320);
        lv2_safe_value_format VARCHAR2(320);
    BEGIN
        lv2_expression := 'NULL';

        IF p_value_in_string IS NULL THEN
            IF p_value_type = ecdp_revn_common.gv2_value_type_boolean THEN
                lv2_expression := '''' || ecdp_revn_common.gv2_false || '''';
            END IF;
        ELSE
            lv2_safe_value_in_string := ecdp_dynsql.SafeString(p_value_in_string);
            lv2_safe_value_format := ecdp_dynsql.SafeString(p_value_format);

            IF p_value_type = ecdp_revn_common.gv2_value_type_string THEN
                lv2_expression := lv2_safe_value_in_string;

            ELSIF p_value_type = ecdp_revn_common.gv2_value_type_number THEN
                ValidateNumberString_P(p_value_in_string, p_value_format);
                lv2_expression := 'to_number(' || lv2_safe_value_in_string || ', ' || lv2_safe_value_format || ')';

            ELSIF p_value_type = ecdp_revn_common.gv2_value_type_date THEN
                ValidateDateString_P(p_value_in_string, p_value_format);
                lv2_expression := 'to_date(' || lv2_safe_value_in_string || ', ' || lv2_safe_value_format || ')';

            ELSIF p_value_type = ecdp_revn_common.gv2_value_type_boolean THEN
                ValidateBooleanStrString_P(p_value_in_string);
                lv2_expression := lv2_safe_value_in_string;

            END IF;
        END IF;

        RETURN lv2_expression;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Resolve the value expression string by given value
    -- category.
    ----+----------------------------------+-------------------------------
    FUNCTION GetValueExpression_P(
         p_value_string                    t_raw_value
        ,p_value_category                  t_value_category
        ,p_data_type                       ecdp_revn_common.t_param_value_type
        ,p_value_ref_version_date          DATE
        ,p_parameters                      IN OUT NOCOPY t_table_revn_data_filter_param
    )
    RETURN VARCHAR2
    IS
        lv2_value_expression VARCHAR2(320);
        lv2_actual_value_format VARCHAR2(32);
        ln_ref_parameter_idx NUMBER;
        lo_ref_parameter t_data_filter_param;
    BEGIN
        lv2_actual_value_format := GetDefaultValueFormat_P(p_data_type);
        ValidateValueCategory_P(p_value_category, p_value_string, p_parameters);

        IF p_value_category = lv2_val_category_parameter THEN
            ln_ref_parameter_idx := FindParameterIdx_P(p_value_string, p_parameters);
            lo_ref_parameter := p_parameters(ln_ref_parameter_idx);

            IF lo_ref_parameter.param_value_type <> p_data_type THEN
                RAISE ex_invalid_parameter_data_type;
            END IF;

            BEGIN
                lv2_value_expression := GetSimpleValueExpression_P(
                     lo_ref_parameter.raw_argument_value
                    ,p_data_type
                    ,lv2_actual_value_format
                );
            EXCEPTION
                WHEN ex_invalid_value_format THEN
                    Raise_InvalidArgVal_Other_P(
                         lo_ref_parameter.param_name
                        ,lo_ref_parameter.raw_argument_value
                        ,lv2_actual_value_format
                    );
            END;

        ELSIF p_value_category = lv2_val_category_fixed_value THEN
            BEGIN
                lv2_value_expression := GetSimpleValueExpression_P(
                     p_value_string
                    ,p_data_type
                    ,lv2_actual_value_format
                );
            EXCEPTION
                WHEN ex_invalid_value_format THEN
                    RAISE ex_invalid_fix_value;
            END;

        ELSIF p_value_category = lv2_val_category_function THEN
            lv2_value_expression := p_value_string || '()';

        ELSIF p_value_category = lv2_val_category_object_list THEN
            lv2_value_expression :=
                'SELECT generic_object_code FROM dv_object_list_setup list_setup WHERE list_setup.object_code = ' || ecdp_dynsql.SafeString(p_value_string) || ' AND daytime >= to_date(''' || to_char(p_value_ref_version_date, 'YYYYMMDD') || ''', ''YYYYMMDD'') AND (end_date IS NULL OR end_date > to_date(''' || to_char(p_value_ref_version_date, 'YYYYMMDD') || ''', ''YYYYMMDD''))';

        ELSIF p_value_category = lv2_val_category_ec_code_list THEN
            lv2_value_expression :=
                'SELECT generic_object_code FROM dv_object_list_setup list_setup WHERE list_setup.object_code = ' || ecdp_dynsql.SafeString(p_value_string) || ' AND daytime >= to_date(''' || to_char(p_value_ref_version_date, 'YYYYMMDD') || ''', ''YYYYMMDD'') AND (end_date IS NULL OR end_date > to_date(''' || to_char(p_value_ref_version_date, 'YYYYMMDD') || ''', ''YYYYMMDD''))';

        END IF;

        RETURN lv2_value_expression;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets if value is required on data filter rule.
    ----+----------------------------------+-------------------------------
    FUNCTION RuleValueRequired_P(
         p_filter_rule                     IN OUT NOCOPY t_data_filter_rule
    )
    RETURN BOOLEAN
    IS
    BEGIN
        RETURN p_filter_rule.op IN (lv2_op_equals, lv2_op_not_equals,
            lv2_op_greater_than, lv2_op_less_than, lv2_op_greater_equal_to,
            lv2_op_less_equal_to, lv2_op_in, lv2_op_not_in, lv2_op_like,
            lv2_op_not_like);
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Resolve the values used in given filter rules.
    ----+----------------------------------+-------------------------------
    PROCEDURE ResolveRuleValues_P(
         p_version_date                    DATE
        ,p_parameters                      IN OUT NOCOPY t_table_revn_data_filter_param
        ,p_class_attributes                IN OUT NOCOPY t_table_class_attribute_info
        ,p_filter_rules                    IN OUT NOCOPY t_table_revn_data_filter_rule
    )
    IS
        ln_this_class_attribute_idx NUMBER;
        lo_ref_param_idx NUMBER;
    BEGIN
        IF p_filter_rules.count = 0 THEN
            RETURN;
        END IF;

        FOR filter_rule_idx IN p_filter_rules.first .. p_filter_rules.last LOOP
            ln_this_class_attribute_idx := FindClassAttributeIdx_P(p_filter_rules(filter_rule_idx).attribute_name, p_class_attributes);

            IF ln_this_class_attribute_idx IS NULL THEN
                Raise_InvalidFilRule_AttName_P(p_filter_rules(filter_rule_idx));
            END IF;

            BEGIN
                IF RuleValueRequired_P(p_filter_rules(filter_rule_idx)) THEN
                    p_filter_rules(filter_rule_idx).value_expression := GetValueExpression_P(
                         p_filter_rules(filter_rule_idx).raw_value
                        ,p_filter_rules(filter_rule_idx).value_category
                        ,p_class_attributes(ln_this_class_attribute_idx).data_type
                        ,p_version_date
                        ,p_parameters
                    );
                ELSE
                    p_filter_rules(filter_rule_idx).value_expression := NULL;
                END IF;
            EXCEPTION
                WHEN ex_invalid_fix_value THEN
                    Raise_InvalidFilRule_FixVal_P(p_filter_rules(filter_rule_idx), p_class_attributes(ln_this_class_attribute_idx), GetDefaultValueFormat_P(p_class_attributes(ln_this_class_attribute_idx).data_type));
                WHEN ex_invalid_parameter_data_type THEN
                    lo_ref_param_idx := FindParameterIdx_P(p_filter_rules(filter_rule_idx).raw_value, p_parameters);
                    Raise_InvalidFParam_ClassAtt_P(p_parameters(lo_ref_param_idx), p_class_attributes(ln_this_class_attribute_idx));
                WHEN ex_raw_value_null THEN
                    Raise_InvalidFilRule_ValNull_P(p_filter_rules(filter_rule_idx));
                WHEN ex_invalid_value_category THEN
                    Raise_InvalidFilRule_InvCat_P(p_filter_rules(filter_rule_idx));
                WHEN ex_parameter_not_found THEN
                    Raise_InvalidFilRule_InvPara_P(p_filter_rules(filter_rule_idx));
                END;

        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Sets default parameter value format if not set.
    ----+----------------------------------+-------------------------------
    PROCEDURE SetArgumentValueFormat_P(
         p_parameter_value_type            IN revn_data_filter_param.param_value_type%TYPE
        ,p_parameter_value                 IN OUT NOCOPY t_revn_data_ext_param_val
    )
    IS

    BEGIN
        IF p_parameter_value.parameter_val_format IS NOT NULL THEN
            RETURN;
        END IF;

        p_parameter_value.parameter_val_format := GetDefaultValueFormat_P(p_parameter_value_type);
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Converts string parameter value to default format.
    ----+----------------------------------+-------------------------------
    FUNCTION GetParameterRawValue_P(
         p_parameter_value_type            IN revn_data_filter_param.param_value_type%TYPE
        ,p_parameter_value                 IN OUT NOCOPY t_revn_data_ext_param_val
    )
    RETURN t_raw_value
    IS
        lv2_raw_value t_raw_value;
        ln_converted_number NUMBER;
        ld_converted_date DATE;
    BEGIN
        IF p_parameter_value_type = ecdp_revn_common.gv2_value_type_string THEN
            lv2_raw_value := p_parameter_value.parameter_val_string;

        ELSIF p_parameter_value_type = ecdp_revn_common.gv2_value_type_number THEN
            BEGIN
                ln_converted_number := to_number(p_parameter_value.parameter_val_string, p_parameter_value.parameter_val_format);
            EXCEPTION
                WHEN OTHERS THEN
                    Raise_InvalidArgVal_Other_P(p_parameter_value.PARAMETER_NAME, p_parameter_value.PARAMETER_VAL_STRING, p_parameter_value.PARAMETER_VAL_FORMAT);
            END;

            lv2_raw_value := to_char(ln_converted_number, GetDefaultValueFormat_P(p_parameter_value_type));

        ELSIF p_parameter_value_type = ecdp_revn_common.gv2_value_type_date THEN
            BEGIN
                ld_converted_date := to_date(p_parameter_value.parameter_val_string, p_parameter_value.parameter_val_format);
            EXCEPTION
                WHEN OTHERS THEN
                    Raise_InvalidArgVal_Other_P(p_parameter_value.PARAMETER_NAME, p_parameter_value.PARAMETER_VAL_STRING, p_parameter_value.PARAMETER_VAL_FORMAT);
            END;

            lv2_raw_value := to_char(ld_converted_date, GetDefaultValueFormat_P(p_parameter_value_type));

        ELSIF p_parameter_value_type = ecdp_revn_common.gv2_value_type_boolean THEN
            IF p_parameter_value.parameter_val_string IS NULL THEN
                lv2_raw_value := ecdp_revn_common.gv2_false;
            ELSE
                IF NOT p_parameter_value.parameter_val_string = ecdp_revn_common.gv2_true
                    AND NOT p_parameter_value.parameter_val_string = ecdp_revn_common.gv2_false THEN
                    Raise_InvalidArgVal_Bool_P(p_parameter_value.PARAMETER_NAME, p_parameter_value.PARAMETER_VAL_STRING);
                END IF;

                lv2_raw_value := p_parameter_value.parameter_val_string;
            END IF;

        END IF;

        RETURN lv2_raw_value;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Validates and converts parameter values according to
    -- filter parameter settings.
    ----+----------------------------------+-------------------------------
    PROCEDURE PerpareArguments_P(
         p_parameters                      IN OUT NOCOPY t_table_revn_data_filter_param
        ,p_arguments                       IN OUT NOCOPY t_table_revn_data_ext_arg
    )
    IS
        lo_this_param_idx NUMBER;
        lo_this_param t_data_filter_param;
        lo_this_argument t_revn_data_ext_param_val;
    BEGIN
        IF p_arguments IS NULL THEN
            Raise_NullProcParamError_P('p_arguments');
        END IF;

        IF p_parameters IS NULL THEN
            Raise_NullProcParamError_P('p_parameters');
        END IF;

        IF p_parameters.count = 0 THEN
            RETURN;
        END IF;

        IF p_arguments.count = 0 THEN
            RETURN;
        END IF;

        FOR argument_idx IN p_arguments.first .. p_arguments.last LOOP
            lo_this_argument := p_arguments(argument_idx);
            lo_this_param_idx := FindParameterIdx_P(lo_this_argument.parameter_name, p_parameters);

            IF lo_this_param_idx IS NOT NULL THEN
                lo_this_param := p_parameters(lo_this_param_idx);
                SetArgumentValueFormat_P(lo_this_param.param_value_type, lo_this_argument);
                p_parameters(lo_this_param_idx).raw_argument_value := GetParameterRawValue_P(lo_this_param.param_value_type, lo_this_argument);
            END IF;
        END LOOP;
    END;


    -----------------------------------------------------------------------
    -- [PRIVATE] Constructs WHERE condition SQL.
    ----+----------------------------------+-------------------------------
    PROCEDURE ConstructCondition_P(
         p_data_filter_rule                IN OUT NOCOPY t_data_filter_rule
        ,p_sql                             IN OUT NOCOPY CLOB
    )
    IS
    BEGIN
        IF p_data_filter_rule.op = lv2_op_equals THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' = ' || p_data_filter_rule.value_expression);

        ELSIF p_data_filter_rule.op = lv2_op_not_equals THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' <> ' || p_data_filter_rule.value_expression);

        ELSIF p_data_filter_rule.op = lv2_op_greater_than THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' > ' || p_data_filter_rule.value_expression);

        ELSIF p_data_filter_rule.op = lv2_op_less_than THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' < ' || p_data_filter_rule.value_expression);

        ELSIF p_data_filter_rule.op = lv2_op_greater_equal_to THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' >= ' || p_data_filter_rule.value_expression);

        ELSIF p_data_filter_rule.op = lv2_op_less_equal_to THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' <= ' || p_data_filter_rule.value_expression);

        ELSIF p_data_filter_rule.op = lv2_op_is_null THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' IS NULL ');

        ELSIF p_data_filter_rule.op = lv2_op_is_not_null THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' IS NOT NULL ');

        ELSIF p_data_filter_rule.op = lv2_op_in THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' IN ( ' || p_data_filter_rule.value_expression);

        ELSIF p_data_filter_rule.op = lv2_op_not_in THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' NOT IN ( ' || p_data_filter_rule.value_expression);

        ELSIF p_data_filter_rule.op = lv2_op_like THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' LIKE ' || p_data_filter_rule.value_expression);

        ELSIF p_data_filter_rule.op = lv2_op_not_like THEN
            dbms_lob.append(p_sql, p_data_filter_rule.attribute_name || ' NOT LIKE ' || p_data_filter_rule.value_expression);

        END IF;

        dbms_lob.append(p_sql, ' ');
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Constructs column list
    ----+----------------------------------+-------------------------------
    PROCEDURE ConstructColumnList_P(
         p_sql                             IN OUT NOCOPY CLOB
        ,p_column_list                     IN OUT NOCOPY t_table_varchar2
        ,p_is_first                        IN BOOLEAN
        ,p_column_to_exclude               IN VARCHAR2
    )
    IS
        lb_first_handled BOOLEAN;
    BEGIN
        IF p_column_list.count = 0 THEN
            RETURN;
        END IF;

        lb_first_handled := FALSE;

        FOR col_idx IN p_column_list.first .. p_column_list.last LOOP
            IF p_column_to_exclude <> p_column_list(col_idx) THEN
                IF NOT lb_first_handled THEN
                    IF p_is_first THEN
                        dbms_lob.append(p_sql, p_column_list(col_idx));
                    ELSE
                        dbms_lob.append(p_sql, ', ' || p_column_list(col_idx));
                    END IF;

                    lb_first_handled := TRUE;
                ELSE
                    dbms_lob.append(p_sql, ', ' || p_column_list(col_idx));
                END IF;
            END IF;
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets a value indicates whether version attribute is
    -- required.
    ----+----------------------------------+-------------------------------
    FUNCTION IsVerAttRequired_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    RETURN BOOLEAN
    IS
    BEGIN
        RETURN p_data_filter.version_rule IN (
            lv2_version_rule_earliest, lv2_version_rule_latest, lv2_version_rule_exists_when, lv2_version_rule_in_range);
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets a value indicates whether version end attribute is
    -- required.
    ----+----------------------------------+-------------------------------
    FUNCTION IsVerEndAttRequired_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    RETURN BOOLEAN
    IS
    BEGIN
        RETURN p_data_filter.version_rule IN (lv2_version_rule_in_range, lv2_version_rule_exists_when);
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets a value indicates whether version value is
    -- required.
    ----+----------------------------------+-------------------------------
    FUNCTION IsVerValRequired_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    RETURN BOOLEAN
    IS
    BEGIN
        RETURN p_data_filter.version_rule IN (lv2_version_rule_exists_when, lv2_version_rule_in_range);
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets a value indicates whether version end value is
    -- required.
    ----+----------------------------------+-------------------------------
    FUNCTION IsVerEndValRequired_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    RETURN BOOLEAN
    IS
    BEGIN
        RETURN p_data_filter.version_rule = lv2_version_rule_in_range;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Gets the actual version attribute to use.
    ----+----------------------------------+-------------------------------
    PROCEDURE SetActualVerAttribute_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
        ,p_class                           IN OUT NOCOPY CLASS_CNFG%ROWTYPE
        ,p_class_attributes                IN OUT NOCOPY t_table_class_attribute_info
    )
    IS
        ln_found_att_idx NUMBER;
    BEGIN
        IF NOT IsVerAttRequired_P(p_data_filter) THEN
            p_data_filter.version_attribute := NULL;
            RETURN;
        END IF;

        IF p_class.class_type = lv2_class_type_data THEN
            p_data_filter.version_attribute := lv2_class_att_daytime;
        ELSIF p_class.class_type = lv2_class_type_object THEN
            p_data_filter.version_attribute := lv2_class_att_daytime;
        ELSE
            IF p_data_filter.version_attribute IS NULL THEN
                Raise_InvalidDFil_VerSAttNul_P(p_data_filter);
            ELSE
                ln_found_att_idx := FindClassAttributeIdx_P(p_data_filter.version_attribute, p_class_attributes);

                IF ln_found_att_idx IS NULL THEN
                    Raise_InvalidDFil_VerSAttNF_P(p_data_filter);
                END IF;

                p_data_filter.version_attribute := p_data_filter.version_attribute;
            END IF;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Sets the actual end version attribute to use.
    ----+----------------------------------+-------------------------------
    PROCEDURE SetActualEndVerAttribute_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
        ,p_class                           IN OUT NOCOPY CLASS_CNFG%ROWTYPE
        ,p_class_attributes                IN OUT NOCOPY t_table_class_attribute_info
    )
    IS
        ln_found_att_idx NUMBER;
    BEGIN
        IF NOT IsVerEndAttRequired_P(p_data_filter) THEN
            p_data_filter.version_end_attribute := NULL;
            RETURN;
        END IF;

        IF p_class.class_type = lv2_class_type_object THEN
            p_data_filter.version_end_attribute := lv2_class_att_enddate;
        ELSE
            IF p_data_filter.version_end_attribute IS NULL THEN
                p_data_filter.version_end_attribute := p_data_filter.version_attribute;

                IF p_data_filter.version_attribute IS NULL THEN
                    Raise_InvalidDFil_VerEAttNul_P(p_data_filter);
                END IF;
            ELSE
                ln_found_att_idx := FindClassAttributeIdx_P(p_data_filter.version_end_attribute, p_class_attributes);

                IF ln_found_att_idx IS NULL THEN
                    Raise_InvalidDFil_VerEAttNF_P(p_data_filter);
                END IF;

                p_data_filter.version_end_attribute := p_data_filter.version_end_attribute;
            END IF;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Sets the end date attribute increasement.
    ----+----------------------------------+-------------------------------
    PROCEDURE SetEndAttributeDaysInc_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        IF p_data_filter.version_end_attribute IS NOT NULL
            AND p_data_filter.version_attribute = p_data_filter.version_end_attribute THEN
            IF p_data_filter.version_rule = lv2_version_rule_exists_when THEN
                p_data_filter.version_end_attribute_days_inc := 1;
            ELSIF p_data_filter.version_rule = lv2_version_rule_in_range THEN
                p_data_filter.version_end_attribute_days_inc := -1;
            END IF;
        ELSE
            p_data_filter.version_end_attribute_days_inc := 0;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Validates version rule.
    ----+----------------------------------+-------------------------------
    PROCEDURE ValidateVerRuleCode_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
    )
    IS
    BEGIN
        IF p_data_filter.version_rule NOT IN (lv2_version_rule_earliest, lv2_version_rule_latest, lv2_version_rule_exists_when, lv2_version_rule_in_range, lv2_version_rule_all) THEN
            Raise_InvalidDFil_P('Version rule ''' || p_data_filter.version_rule || ''' is not recognized.');
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Validates version rule settings.
    ----+----------------------------------+-------------------------------
    PROCEDURE ValidateVerRuleSettings_P(
         p_data_filter                     IN OUT NOCOPY t_data_filter
        ,p_parameters                      IN OUT NOCOPY t_table_revn_data_filter_param
    )
    IS
    BEGIN
        IF IsVerValRequired_P(p_data_filter) THEN
            BEGIN
                ValidateValueCategory_P(p_data_filter.version_from_categor, p_data_filter.version_from, p_parameters);
            EXCEPTION
                WHEN ex_raw_value_null THEN
                    Raise_InvalidDFil_P('Version value cannot be null.');
                WHEN ex_parameter_not_found THEN
                    Raise_InvalidDFil_P('Parameter ''' || p_data_filter.version_from || ''' referenced by version rule is not found.');
                WHEN ex_invalid_value_category THEN
                    Raise_InvalidDFil_P('Value category ''' || p_data_filter.version_from_categor || ''' referenced by version rule is invalid.');
            END;
        END IF;

        IF IsVerEndValRequired_P(p_data_filter) THEN
            BEGIN
                ValidateValueCategory_P(p_data_filter.version_to_categor, p_data_filter.version_to, p_parameters);
            EXCEPTION
                WHEN ex_raw_value_null THEN
                    Raise_InvalidDFil_P('Version end value cannot be null.');
                WHEN ex_parameter_not_found THEN
                    Raise_InvalidDFil_P('Parameter ''' || p_data_filter.version_to || ''' referenced by version rule is not found.');
                WHEN ex_invalid_value_category THEN
                    Raise_InvalidDFil_P('Value category ''' || p_data_filter.version_to_categor || ''' referenced by version rule is invalid.');
            END;
        END IF;

        ValidateVerRuleCode_P(p_data_filter);
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Constructs conditions for max row count limit.
    ----+----------------------------------+-------------------------------
    FUNCTION ConstructRowLimitConditions_P(
         p_sql                             IN OUT NOCOPY CLOB
        ,p_max_row_count                   IN NUMBER
        ,p_where_statement_exist           IN BOOLEAN
    )
    RETURN BOOLEAN
    IS
        lo_key_columns t_table_varchar2;
        lv2_date_expression VARCHAR2(64);
        lv2_end_date_expression VARCHAR2(64);
        lv2_date_format t_data_format;
        lo_ref_param_idx NUMBER;
    BEGIN
        IF p_max_row_count IS NULL OR p_max_row_count < 0 THEN
            RETURN FALSE;
        END IF;

        IF NOT p_where_statement_exist THEN
            dbms_lob.append(p_sql, ' WHERE ');
        ELSE
            dbms_lob.append(p_sql, ' AND ');
        END IF;

        dbms_lob.append(p_sql, 'ROWNUM <= ' || p_max_row_count);

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Constructs conditions for version rule.
    ----+----------------------------------+-------------------------------
    FUNCTION ConstructVerRuleConditions_P(
         p_sql                             IN OUT NOCOPY CLOB
        ,p_data_filter                     IN OUT NOCOPY t_data_filter
        ,p_class                           IN OUT NOCOPY CLASS_CNFG%ROWTYPE
        ,p_class_attributes                IN OUT NOCOPY t_table_class_attribute_info
        ,p_parameters                      IN OUT NOCOPY t_table_revn_data_filter_param
    )
    RETURN BOOLEAN
    IS
        lo_key_columns t_table_varchar2;
        lv2_date_expression VARCHAR2(64);
        lv2_end_date_expression VARCHAR2(64);
        lv2_date_format t_data_format;
        lo_ref_param_idx NUMBER;
    BEGIN
        IF NVL(p_data_filter.version_rule, lv2_version_rule_all) = lv2_version_rule_all THEN
            RETURN FALSE;
        END IF;

        lo_key_columns := t_table_varchar2();
        FOR att_idx IN p_class_attributes.first .. p_class_attributes.last LOOP
            IF p_class_attributes(att_idx).is_key = ecdp_revn_common.gv2_true THEN
                lo_key_columns.extend;
                lo_key_columns(lo_key_columns.last) := p_class_attributes(att_idx).attribute_name;
            END IF;
        END LOOP;

        lv2_date_format := GetDefaultValueFormat_P(ecdp_revn_common.gv2_value_type_date);

        IF p_class.class_type = lv2_class_type_object THEN
            IF p_data_filter.version_rule = lv2_version_rule_earliest THEN
                dbms_lob.append(p_sql, ' WHERE (' || p_data_filter.version_attribute || ', object_id) IN (SELECT MIN(' || p_data_filter.version_attribute || '), object_id FROM ' || lv2_raw_data_table_name || ' GROUP BY object_id)');

            ELSIF p_data_filter.version_rule = lv2_version_rule_latest THEN
                dbms_lob.append(p_sql, ' WHERE (' || p_data_filter.version_attribute || ', object_id) IN (SELECT MAX(' || p_data_filter.version_attribute || '), object_id FROM ' || lv2_raw_data_table_name || ' GROUP BY object_id)');

            ELSIF p_data_filter.version_rule = lv2_version_rule_exists_when THEN
                BEGIN
                    lv2_date_expression := GetValueExpression_P(
                         p_data_filter.version_from
                        ,p_data_filter.version_from_categor
                        ,ecdp_revn_common.gv2_value_type_date
                        ,p_data_filter.daytime
                        ,p_parameters
                    );
                EXCEPTION
                    WHEN ex_invalid_fix_value THEN
                        Raise_InvalidDFil_VerFVal_P(p_data_filter.version_from, lv2_date_format);
                    WHEN ex_invalid_parameter_data_type THEN
                        lo_ref_param_idx := FindParameterIdx_P(p_data_filter.version_from, p_parameters);
                        Raise_InvalidFParam_VerS_P(p_parameters(lo_ref_param_idx));
                    WHEN ex_raw_value_null THEN
                        Raise_InvalidDFil_VerFNull_P(p_data_filter);
                    WHEN ex_invalid_value_category THEN
                        Raise_InvalidDFil_VerFCat_P(p_data_filter);
                    WHEN ex_parameter_not_found THEN
                        Raise_InvalidDFil_VerF_PNF_P(p_data_filter);
                END;

                dbms_lob.append(p_sql, ' WHERE (' || p_data_filter.version_attribute || ', object_id) IN (SELECT ' || p_data_filter.version_attribute || ', object_id FROM ' || lv2_raw_data_table_name || ' WHERE ' || p_data_filter.version_attribute || ' <= ' || lv2_date_expression || ' AND nvl(' || p_data_filter.version_end_attribute || ' + (' || p_data_filter.version_end_attribute_days_inc || '), ' || lv2_date_expression || ' + 1) > ' || lv2_date_expression || ' GROUP BY object_id, ' || p_data_filter.version_attribute || ')');
            ELSIF p_data_filter.version_rule = lv2_version_rule_in_range THEN
                BEGIN
                    lv2_date_expression := GetValueExpression_P(
                         p_data_filter.version_from
                        ,p_data_filter.version_from_categor
                        ,ecdp_revn_common.gv2_value_type_date
                        ,p_data_filter.daytime
                        ,p_parameters
                    );
                EXCEPTION
                    WHEN ex_invalid_fix_value THEN
                        Raise_InvalidDFil_VerFVal_P(p_data_filter.version_from, lv2_date_format);
                    WHEN ex_invalid_parameter_data_type THEN
                        lo_ref_param_idx := FindParameterIdx_P(p_data_filter.version_from, p_parameters);
                        Raise_InvalidFParam_VerS_P(p_parameters(lo_ref_param_idx));
                    WHEN ex_raw_value_null THEN
                        Raise_InvalidDFil_VerFNull_P(p_data_filter);
                    WHEN ex_invalid_value_category THEN
                        Raise_InvalidDFil_VerFCat_P(p_data_filter);
                    WHEN ex_parameter_not_found THEN
                        Raise_InvalidDFil_VerF_PNF_P(p_data_filter);
                END;

                BEGIN
                    lv2_end_date_expression := GetValueExpression_P(
                         p_data_filter.version_to
                        ,p_data_filter.version_to_categor
                        ,ecdp_revn_common.gv2_value_type_date
                        ,p_data_filter.daytime
                        ,p_parameters
                    );
                EXCEPTION
                    WHEN ex_invalid_fix_value THEN
                        Raise_InvalidDFil_VerTVal_P(p_data_filter.version_to, lv2_date_format);
                    WHEN ex_invalid_parameter_data_type THEN
                        lo_ref_param_idx := FindParameterIdx_P(p_data_filter.version_to, p_parameters);
                        Raise_InvalidFParam_VerT_P(p_parameters(lo_ref_param_idx));
                    WHEN ex_raw_value_null THEN
                        Raise_InvalidDFil_VerTNull_P(p_data_filter);
                    WHEN ex_invalid_value_category THEN
                        Raise_InvalidDFil_VerTCat_P(p_data_filter);
                    WHEN ex_parameter_not_found THEN
                        Raise_InvalidDFil_VerT_PNF_P(p_data_filter);
                END;

                dbms_lob.append(p_sql, ' WHERE (' || p_data_filter.version_attribute || ', object_id) IN (SELECT ' || p_data_filter.version_attribute || ', object_id FROM ' || lv2_raw_data_table_name || ' WHERE ' || p_data_filter.version_attribute || ' >= ' || lv2_date_expression || ' AND nvl(' || p_data_filter.version_end_attribute || ' + (' || p_data_filter.version_end_attribute_days_inc || '), ' || lv2_end_date_expression || ' - 1) < ' || lv2_end_date_expression || ' GROUP BY object_id, ' || p_data_filter.version_attribute || ')');
            END IF;

        ELSIF p_class.class_type IN (lv2_class_type_data, lv2_class_type_table, lv2_class_type_interface) THEN
            dbms_lob.append(p_sql, ' WHERE (' || p_data_filter.version_attribute);
            ConstructColumnList_P(p_sql, lo_key_columns, FALSE, p_data_filter.version_attribute);

            IF p_data_filter.version_rule = lv2_version_rule_earliest THEN
                dbms_lob.append(p_sql, ') IN (SELECT MIN(' || p_data_filter.version_attribute || ')');
                ConstructColumnList_P(p_sql, lo_key_columns, FALSE, p_data_filter.version_attribute);
                dbms_lob.append(p_sql, ' FROM ' || lv2_raw_data_table_name || ' GROUP BY ' || p_data_filter.version_attribute);
                ConstructColumnList_P(p_sql, lo_key_columns, FALSE, p_data_filter.version_attribute);

                dbms_lob.append(p_sql, ')');

            ELSIF p_data_filter.version_rule = lv2_version_rule_latest THEN
                dbms_lob.append(p_sql, ') IN (SELECT MAX(' || p_data_filter.version_attribute || ')');
                ConstructColumnList_P(p_sql, lo_key_columns, FALSE, p_data_filter.version_attribute);
                dbms_lob.append(p_sql, ' FROM ' || lv2_raw_data_table_name || ' GROUP BY ' || p_data_filter.version_attribute);
                ConstructColumnList_P(p_sql, lo_key_columns, FALSE, p_data_filter.version_attribute);

                dbms_lob.append(p_sql, ')');

            ELSIF p_data_filter.version_rule = lv2_version_rule_exists_when THEN
                BEGIN
                    lv2_date_expression := GetValueExpression_P(
                         p_data_filter.version_from
                        ,p_data_filter.version_from_categor
                        ,ecdp_revn_common.gv2_value_type_date
                        ,p_data_filter.daytime
                        ,p_parameters
                    );
                EXCEPTION
                    WHEN ex_invalid_fix_value THEN
                        Raise_InvalidDFil_VerFVal_P(p_data_filter.version_from, lv2_date_format);
                    WHEN ex_invalid_parameter_data_type THEN
                        lo_ref_param_idx := FindParameterIdx_P(p_data_filter.version_from, p_parameters);
                        Raise_InvalidFParam_VerS_P(p_parameters(lo_ref_param_idx));
                    WHEN ex_raw_value_null THEN
                        Raise_InvalidDFil_VerFNull_P(p_data_filter);
                    WHEN ex_invalid_value_category THEN
                        Raise_InvalidDFil_VerFCat_P(p_data_filter);
                    WHEN ex_parameter_not_found THEN
                        Raise_InvalidDFil_VerF_PNF_P(p_data_filter);
                END;

                dbms_lob.append(p_sql, ') IN (SELECT ' || p_data_filter.version_attribute);
                ConstructColumnList_P(p_sql, lo_key_columns, FALSE, p_data_filter.version_attribute);
                dbms_lob.append(p_sql, ' FROM ' || lv2_raw_data_table_name || ' WHERE ' || p_data_filter.version_attribute || ' <= ' || lv2_date_expression || ' AND nvl(' || p_data_filter.version_end_attribute || ' + (' || p_data_filter.version_end_attribute_days_inc || '), ' || lv2_date_expression || ' + 1) > ' || lv2_date_expression || ' GROUP BY ' || p_data_filter.version_attribute);
                ConstructColumnList_P(p_sql, lo_key_columns, FALSE, p_data_filter.version_attribute);
                dbms_lob.append(p_sql, ')');
            ELSIF p_data_filter.version_rule = lv2_version_rule_in_range THEN
                BEGIN
                    lv2_date_expression := GetValueExpression_P(
                         p_data_filter.version_from
                        ,p_data_filter.version_from_categor
                        ,ecdp_revn_common.gv2_value_type_date
                        ,p_data_filter.daytime
                        ,p_parameters
                    );
                EXCEPTION
                    WHEN ex_invalid_fix_value THEN
                        Raise_InvalidDFil_VerFVal_P(p_data_filter.version_from, lv2_date_format);
                    WHEN ex_invalid_parameter_data_type THEN
                        lo_ref_param_idx := FindParameterIdx_P(p_data_filter.version_from, p_parameters);
                        Raise_InvalidFParam_VerS_P(p_parameters(lo_ref_param_idx));
                    WHEN ex_raw_value_null THEN
                        Raise_InvalidDFil_VerFNull_P(p_data_filter);
                    WHEN ex_invalid_value_category THEN
                        Raise_InvalidDFil_VerFCat_P(p_data_filter);
                    WHEN ex_parameter_not_found THEN
                        Raise_InvalidDFil_VerF_PNF_P(p_data_filter);
                END;

                BEGIN
                    lv2_end_date_expression := GetValueExpression_P(
                         p_data_filter.version_to
                        ,p_data_filter.version_to_categor
                        ,ecdp_revn_common.gv2_value_type_date
                        ,p_data_filter.daytime
                        ,p_parameters
                    );
                EXCEPTION
                    WHEN ex_invalid_fix_value THEN
                        Raise_InvalidDFil_VerTVal_P(p_data_filter.version_to, lv2_date_format);
                    WHEN ex_invalid_parameter_data_type THEN
                        lo_ref_param_idx := FindParameterIdx_P(p_data_filter.version_to, p_parameters);
                        Raise_InvalidFParam_VerT_P(p_parameters(lo_ref_param_idx));
                    WHEN ex_raw_value_null THEN
                        Raise_InvalidDFil_VerTNull_P(p_data_filter);
                    WHEN ex_invalid_value_category THEN
                        Raise_InvalidDFil_VerTCat_P(p_data_filter);
                    WHEN ex_parameter_not_found THEN
                        Raise_InvalidDFil_VerT_PNF_P(p_data_filter);
                END;

                dbms_lob.append(p_sql, ' ) IN (SELECT ' || p_data_filter.version_attribute || ' FROM ' || lv2_raw_data_table_name || ' WHERE ' || p_data_filter.version_attribute || ' >= ' || lv2_date_expression || ' AND nvl(' || p_data_filter.version_end_attribute || ' + (' || p_data_filter.version_end_attribute_days_inc || '), ' || lv2_end_date_expression || ' - 1) < ' || lv2_end_date_expression || ' GROUP BY ' || p_data_filter.version_attribute);
                ConstructColumnList_P(p_sql, lo_key_columns, FALSE, p_data_filter.version_attribute);
                dbms_lob.append(p_sql, ')');
            END IF;
        END IF;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Constructs WHERE condition SQL.
    ----+----------------------------------+-------------------------------
    PROCEDURE ConstructWhere_P(
         p_sql                             IN OUT NOCOPY CLOB
        ,p_data_filter_rules               IN OUT NOCOPY t_table_revn_data_filter_rule
    )
    IS
        ln_open_parenthsis_level NUMBER;
        lb_current_group_no NUMBER;
        lb_current_sub_group_att_name VARCHAR2(32);
        lo_this_filter_rule t_data_filter_rule;
        lo_next_filter_rule t_data_filter_rule;
    BEGIN
        ln_open_parenthsis_level := 0;

        IF p_data_filter_rules.count > 0 THEN
            dbms_lob.append(p_sql, 'WHERE ');

            FOR rule_idx IN p_data_filter_rules.first .. p_data_filter_rules.last LOOP
                lo_this_filter_rule := p_data_filter_rules(rule_idx);

                -- Construct left parenthesis
                IF lb_current_group_no IS NULL THEN
                    ln_open_parenthsis_level := ln_open_parenthsis_level + 1;
                    dbms_lob.append(p_sql, '( ');
                END IF;

                IF rule_idx < p_data_filter_rules.last THEN
                    lo_next_filter_rule := p_data_filter_rules(rule_idx + 1);

                    IF lb_current_sub_group_att_name IS NULL
                          AND lo_next_filter_rule.group_no = lo_this_filter_rule.group_no
                          AND lo_next_filter_rule.attribute_name = lo_this_filter_rule.attribute_name THEN
                        ln_open_parenthsis_level := ln_open_parenthsis_level + 1;
                        dbms_lob.append(p_sql, '( ');
                    END IF;
                END IF;

                -- Construct condition itself
                ConstructCondition_P(lo_this_filter_rule, p_sql);

                IF ((lo_this_filter_rule.op = lv2_op_in) OR (lo_this_filter_rule.op = lv2_op_not_in)) THEN
                  dbms_lob.append(p_sql, ') ');
                END IF;

                -- Construct right parenthesis and logical operator
                IF rule_idx = p_data_filter_rules.last THEN
                    EXIT;
                END IF;

                lb_current_group_no := lo_this_filter_rule.group_no;

                IF lo_next_filter_rule.group_no <> lb_current_group_no THEN
                    IF lb_current_sub_group_att_name IS NOT NULL THEN
                        lb_current_sub_group_att_name := NULL;
                        ln_open_parenthsis_level := ln_open_parenthsis_level - 1;
                        dbms_lob.append(p_sql, ') ');
                    END IF;

                    ln_open_parenthsis_level := ln_open_parenthsis_level - 1;
                    dbms_lob.append(p_sql, ') OR ');
                    lb_current_group_no := NULL;
                ELSE
                    IF lb_current_sub_group_att_name IS NOT NULL THEN
                        IF lo_next_filter_rule.attribute_name = lb_current_sub_group_att_name THEN
                            dbms_lob.append(p_sql, 'OR ');
                        ELSE
                            lb_current_sub_group_att_name := NULL;
                            ln_open_parenthsis_level := ln_open_parenthsis_level - 1;
                            dbms_lob.append(p_sql, ') AND ');
                        END IF;
                    ELSE
                        IF lo_next_filter_rule.attribute_name = lo_this_filter_rule.attribute_name THEN
                            lb_current_sub_group_att_name := lo_next_filter_rule.attribute_name;
                            dbms_lob.append(p_sql, 'OR ');
                        ELSE
                            dbms_lob.append(p_sql, 'AND ');
                        END IF;
                    END IF;
                END IF;
            END LOOP;

            -- Close open parenthsises
            FOR level_idx IN 1 .. ln_open_parenthsis_level LOOP
                dbms_lob.append(p_sql, ') ');
            END LOOP;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Constructs result column list
    ----+----------------------------------+-------------------------------
    PROCEDURE ConstructResultColumnList_P(
         p_execution_mode                  IN T_EXECUTION_MODE
        ,p_attribute_to_return             IN class_attribute_cnfg.attribute_name%TYPE
        ,p_attribute_to_read               IN class_attribute_cnfg.attribute_name%TYPE
        ,p_class_info                      IN OUT NOCOPY CLASS_CNFG%ROWTYPE
        ,p_sql                             IN OUT NOCOPY CLOB
    )
    IS
        lv_attribute_to_read               VARCHAR2(128) := 'NULL';
        lv_data_type                       CLASS_ATTRIBUTE_CNFG.DATA_TYPE%TYPE;
    BEGIN
        --Resolve how to convert the value of ATTRIBUTE_TO_READ into a string.
        IF p_attribute_to_read IS NOT NULL THEN
            lv_data_type := ec_class_attribute_cnfg.data_type(p_class_info.class_name, p_attribute_to_read);
            CASE lv_data_type
                WHEN 'BOOLEAN' THEN lv_attribute_to_read := p_attribute_to_read;
                WHEN 'DATE'    THEN lv_attribute_to_read := 'TO_CHAR(' || p_attribute_to_read || ',''YYYY-MM-DD"T"HH24:MI:SS'')';
                WHEN 'INTEGER' THEN lv_attribute_to_read := 'TO_CHAR(' || p_attribute_to_read || ')';
                WHEN 'NUMBER'  THEN lv_attribute_to_read := 'TO_CHAR(' || p_attribute_to_read || ')';
                WHEN 'STRING'  THEN lv_attribute_to_read := p_attribute_to_read;
                ELSE                lv_attribute_to_read := p_attribute_to_read;
            END CASE;
        END IF;
        lv_attribute_to_read := ', ' || lv_attribute_to_read || ' AS ATTRIBUTE_TO_READ ';

        --Construct the result column list
        IF p_execution_mode = lv2_execution_mode_full THEN
            dbms_lob.append(p_sql, 'raw_data.* ' || lv_attribute_to_read);
        ELSIF p_execution_mode = lv2_execution_mode_attribute THEN
            IF p_class_info.class_type = lv2_class_type_object THEN
                dbms_lob.append(p_sql, p_attribute_to_return || lv_attribute_to_read || ', DAYTIME, END_DATE, CLASS_NAME, OBJECT_ID, CODE, REC_ID, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO ');
            ELSIF p_class_info.class_type = lv2_class_type_data THEN
                dbms_lob.append(p_sql, p_attribute_to_return || lv_attribute_to_read || ', DAYTIME, NULL AS END_DATE, CLASS_NAME, OBJECT_ID, OBJECT_CODE, REC_ID, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO ');
            ELSIF p_class_info.class_type = lv2_class_type_table THEN
                dbms_lob.append(p_sql, p_attribute_to_return || lv_attribute_to_read || ', NULL AS DAYTIME, NULL AS END_DATE, TABLE_CLASS_NAME, NULL AS OBJECT_ID, NULL AS CODE, REC_ID, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO ');
            ELSE
                dbms_lob.append(p_sql, p_attribute_to_return || lv_attribute_to_read || ', NULL AS DAYTIME, NULL AS END_DATE, CLASS_NAME, NULL AS OBJECT_ID, NULL AS CODE, REC_ID, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO ');
            END IF;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Executes SQL
    ----+----------------------------------+-------------------------------
    FUNCTION ExecuteSql_P(
         p_sql                             IN OUT NOCOPY VARCHAR2
    )
    RETURN SYS_REFCURSOR
    IS
        lo_ref_cursor SYS_REFCURSOR;
	  BEGIN
        OPEN lo_ref_cursor FOR p_sql;

        RETURN lo_ref_cursor;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Validates attbibute name parameter
    ----+----------------------------------+-------------------------------
    PROCEDURE ValidateAttributeNameParam_P(
         p_attribute_to_return             IN class_attribute_cnfg.attribute_name%TYPE
        ,p_execution_mode                  IN t_execution_mode
        ,p_data_filter                     IN OUT NOCOPY t_data_filter
        ,p_class_attributes                IN OUT NOCOPY t_table_class_attribute_info
    )
    IS
        ln_this_class_attribute_idx NUMBER;
    BEGIN
        IF p_execution_mode <> lv2_execution_mode_attribute THEN
            RETURN;
        END IF;

        ln_this_class_attribute_idx := FindClassAttributeIdx_P(p_attribute_to_return, p_class_attributes);

        IF ln_this_class_attribute_idx IS NULL THEN
            Raise_ProcedureParamError_P('p_attribute_to_return', p_attribute_to_return, 'Attribute ''' || p_attribute_to_return || ''' is not found on class ''' || p_data_filter.class_to_read || '''.');
        END IF;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Constructs SQL for fetching data
    ----+----------------------------------+-------------------------------
    FUNCTION ConstructSql_P(
         p_execution_context               IN OUT NOCOPY T_EXECUTION_CONTEXT
    )
    RETURN VARCHAR2
    IS
        lo_data_filter t_data_filter;
        lo_class CLASS_CNFG%ROWTYPE;
        lo_data_filter_params t_table_revn_data_filter_param;
        lo_data_filter_rules t_table_revn_data_filter_rule;
        lo_class_attributes t_table_class_attribute_info;
        lv2_sql CLOB;
        lv2_sql_varchar VARCHAR2(4000);
        lb_where_appended BOOLEAN;
    BEGIN
        dbms_lob.createtemporary(lv2_sql, true, dbms_lob.session);
        dbms_lob.open(lv2_sql, dbms_lob.lob_readwrite);

        lo_data_filter := GetDataFilter_P(p_execution_context.param_data_filter_id, p_execution_context.param_daytime);
        lo_data_filter_params := GetParameters_P(lo_data_filter.object_id);
        lo_data_filter_rules := GetRules_P(lo_data_filter.object_id, lo_data_filter.daytime);
        PerpareArguments_P(lo_data_filter_params, p_execution_context.param_arguments);

        lo_class := ec_class_cnfg.row_by_pk(lo_data_filter.class_to_read);
        lo_class_attributes := GetClassAttributesInfo_P(lo_class);
        ValidateAttributeNameParam_P(p_execution_context.param_attribute_to_return, p_execution_context.param_execution_mode, lo_data_filter, lo_class_attributes);
        ResolveRuleValues_P(p_execution_context.param_daytime, lo_data_filter_params, lo_class_attributes, lo_data_filter_rules);

        SetActualVerAttribute_P(lo_data_filter, lo_class, lo_class_attributes);
        SetActualEndVerAttribute_P(lo_data_filter, lo_class, lo_class_attributes);
        SetEndAttributeDaysInc_P(lo_data_filter);
        ValidateVerRuleSettings_P(lo_data_filter, lo_data_filter_params);

        dbms_lob.append(lv2_sql, 'WITH raw_data AS ( ');
        dbms_lob.append(lv2_sql, 'SELECT * FROM ' || ecdp_classmeta.getClassViewName(lo_data_filter.class_to_read) || ' ');
        ConstructWhere_P(lv2_sql, lo_data_filter_rules);
        dbms_lob.append(lv2_sql, ') ');

        dbms_lob.append(lv2_sql, 'SELECT ');
        ConstructResultColumnList_P(p_execution_context.param_execution_mode, p_execution_context.param_attribute_to_return, p_execution_context.param_attribute_to_read, lo_class, lv2_sql);
        dbms_lob.append(lv2_sql, 'FROM raw_data ');
        lb_where_appended := ConstructVerRuleConditions_P(lv2_sql, lo_data_filter, lo_class, lo_class_attributes, lo_data_filter_params);
        lb_where_appended := ConstructRowLimitConditions_P(lv2_sql, p_execution_context.param_max_row_count, lb_where_appended);

        lv2_sql_varchar := dbms_lob.substr(lv2_sql, 4000, 1);
        dbms_lob.close(lv2_sql);

        RETURN lv2_sql_varchar;
    END;

    -----------------------------------------------------------------------
    -- [PRIVATE] Execute data filter
    ----+----------------------------------+-------------------------------
    FUNCTION ExecuteDataFilter_P(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
        ,p_daytime                         IN revn_data_filter_version.daytime%TYPE
        ,p_arguments                       IN OUT NOCOPY t_table_revn_data_ext_arg
        ,p_execution_mode                  IN T_EXECUTION_MODE
        ,p_attribute_to_return             IN class_attribute_cnfg.attribute_name%TYPE
        ,p_attribute_to_read               IN class_attribute_cnfg.attribute_name%TYPE
        ,p_max_row_count                   IN NUMBER
    )
    RETURN SYS_REFCURSOR
    IS
        lv2_sql_varchar VARCHAR2(4000);
        lo_execution_context T_EXECUTION_CONTEXT;
    BEGIN
        lo_execution_context.param_data_filter_id := p_data_filter_id;
        lo_execution_context.param_daytime := p_daytime;
        lo_execution_context.param_arguments := p_arguments;
        lo_execution_context.param_execution_mode := p_execution_mode;
        lo_execution_context.param_attribute_to_return := p_attribute_to_return;
        lo_execution_context.param_attribute_to_read := p_attribute_to_read;
        lo_execution_context.param_max_row_count := p_max_row_count;

        lv2_sql_varchar :=
            ConstructSql_P(lo_execution_context);

        RETURN ExecuteSql_P(lv2_sql_varchar);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION BuildQuery_GetClassRecords(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
        ,p_daytime                         IN revn_data_filter_version.daytime%TYPE
        ,p_arguments                       IN t_table_revn_data_ext_arg
        ,p_max_row_count                   IN NUMBER DEFAULT NULL
    )
    RETURN VARCHAR2
    IS
        lo_execution_context T_EXECUTION_CONTEXT;
        lv_text VARCHAR2(2000);
    BEGIN
        lo_execution_context.param_data_filter_id := p_data_filter_id;
        lo_execution_context.param_daytime := p_daytime;
        lo_execution_context.param_arguments := p_arguments;
        lo_execution_context.param_execution_mode := lv2_execution_mode_full;
        lo_execution_context.param_max_row_count := p_max_row_count;

        RETURN ConstructSql_P(lo_execution_context);
    EXCEPTION
        WHEN ex_data_filter_not_found THEN
            Raise_ProcedureParamError_P('p_data_filter_id', p_data_filter_id, 'Data filter does not exist.');
        WHEN ex_data_filter_ver_not_found THEN
            Raise_ProcedureParamError_P('p_daytime', p_daytime, 'Data filter version does not exist.');
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION BuildQuery_GetClassAttribute(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
        ,p_daytime                         IN revn_data_filter_version.daytime%TYPE
        ,p_arguments                       IN t_table_revn_data_ext_arg
        ,p_attribute_to_return             IN class_attribute_cnfg.attribute_name%TYPE
        ,p_max_row_count                   IN NUMBER DEFAULT NULL
    )
    RETURN VARCHAR2
    IS
        lo_execution_context T_EXECUTION_CONTEXT;
    BEGIN
        lo_execution_context.param_data_filter_id := p_data_filter_id;
        lo_execution_context.param_daytime := p_daytime;
        lo_execution_context.param_arguments := p_arguments;
        lo_execution_context.param_execution_mode := lv2_execution_mode_attribute;
        lo_execution_context.param_attribute_to_return := p_attribute_to_return;
        lo_execution_context.param_max_row_count := p_max_row_count;

        RETURN ConstructSql_P(lo_execution_context);
    EXCEPTION
        WHEN ex_invalid_class_att_name THEN
            Raise_ProcedureParamError_P('p_attribute_to_return', p_attribute_to_return, NULL);
        WHEN ex_data_filter_not_found THEN
            Raise_ProcedureParamError_P('p_data_filter_id', p_data_filter_id, 'Data filter does not exist.');
        WHEN ex_data_filter_ver_not_found THEN
            Raise_ProcedureParamError_P('p_daytime', p_daytime, 'Data filter version does not exist.');
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION GetClassRecords(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
        ,p_daytime                         IN revn_data_filter_version.daytime%TYPE
        ,p_arguments                       IN t_table_revn_data_ext_arg
        ,p_max_row_count                   IN NUMBER DEFAULT NULL
    )
    RETURN SYS_REFCURSOR
    IS
        lo_arguments t_table_revn_data_ext_arg;
    BEGIN
        lo_arguments := p_arguments;

        RETURN ExecuteDataFilter_P(
            p_data_filter_id, p_daytime, lo_arguments, lv2_execution_mode_full, NULL, NULL, p_max_row_count);
    EXCEPTION
        WHEN ex_data_filter_not_found THEN
            Raise_ProcedureParamError_P('p_data_filter_id', p_data_filter_id, 'Data filter does not exist.');
        WHEN ex_data_filter_ver_not_found THEN
            Raise_ProcedureParamError_P('p_daytime', p_daytime, 'Data filter version does not exist.');
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION GetClassAttribute(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
        ,p_daytime                         IN revn_data_filter_version.daytime%TYPE
        ,p_arguments                       IN t_table_revn_data_ext_arg
        ,p_attribute_to_return             IN class_attribute_cnfg.attribute_name%TYPE
        ,p_attribute_to_read               IN class_attribute_cnfg.attribute_name%TYPE
        ,p_max_row_count                   IN NUMBER DEFAULT NULL
    )
    RETURN SYS_REFCURSOR
    IS
        lo_arguments t_table_revn_data_ext_arg;
    BEGIN
        lo_arguments := p_arguments;

        RETURN ExecuteDataFilter_P(
            p_data_filter_id, p_daytime, lo_arguments, lv2_execution_mode_attribute, p_attribute_to_return, p_attribute_to_read, p_max_row_count);
    EXCEPTION
        WHEN ex_invalid_class_att_name THEN
            Raise_ProcedureParamError_P('p_attribute_to_return', p_attribute_to_return, NULL);
        WHEN ex_data_filter_not_found THEN
            Raise_ProcedureParamError_P('p_data_filter_id', p_data_filter_id, 'Data filter does not exist.');
        WHEN ex_data_filter_ver_not_found THEN
            Raise_ProcedureParamError_P('p_daytime', p_daytime, 'Data filter version does not exist.');
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION GetAttributeNameFromFilterRule(
        p_object_id                        VARCHAR2,
        p_period                           DATE,
        p_value                            VARCHAR2
    )
    RETURN VARCHAR2
    IS
        CURSOR c_data_filter_rule IS
        SELECT r.attribute_name
          FROM revn_data_filter_rule r, revn_data_filter_version oa, revn_data_filter o
               --Versioning and relations
         WHERE r.object_id = oa.object_id
           AND oa.object_id = o.object_id
           AND r.daytime >= oa.daytime
           AND r.daytime < nvl(oa.end_date,r.daytime + 1)
               --Get specific rule by the parameters
           AND r.object_id = p_object_id
           AND r.value_category = 'PARAMETER'
           AND r.value = p_value
           AND p_period >= oa.daytime
           AND p_period < nvl(oa.end_date,p_period + 1);

        lv_attribute_name                  VARCHAR2(240);
    BEGIN
        FOR curRule in c_data_filter_rule() LOOP
            lv_attribute_name := curRule.attribute_name;
        END LOOP;

        RETURN lv_attribute_name;
    END GetAttributeNameFromFilterRule;

END EcDp_Revn_Data_Ext;