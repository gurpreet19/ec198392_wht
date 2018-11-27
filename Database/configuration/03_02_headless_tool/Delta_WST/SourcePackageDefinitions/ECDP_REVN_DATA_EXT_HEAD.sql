CREATE OR REPLACE PACKAGE EcDp_Revn_Data_Ext IS

    -----------------------------------------------------------------------
    -- Type declarations
    ----+----------------------------------+-------------------------------
    SUBTYPE t_param_val_expression IS VARCHAR2(2000);

    -----------------------------------------------------------------------
    -- Constants
    ----+----------------------------------+-------------------------------

    -----------------------------------------------------------------------
    -- Builds query for data filter execution.
    ----+----------------------------------+-------------------------------
    FUNCTION BuildQuery_GetClassRecords(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
        ,p_daytime                         IN revn_data_filter_version.daytime%TYPE
        ,p_arguments                       IN t_table_revn_data_ext_arg
        ,p_max_row_count                   IN NUMBER DEFAULT NULL
    )
    RETURN VARCHAR2;

    -----------------------------------------------------------------------
    -- Builds query for data filter execution.
    ----+----------------------------------+-------------------------------
    FUNCTION BuildQuery_GetClassAttribute(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
        ,p_daytime                         IN revn_data_filter_version.daytime%TYPE
        ,p_arguments                       IN t_table_revn_data_ext_arg
        ,p_attribute_to_return             IN class_attribute_cnfg.attribute_name%TYPE
        ,p_max_row_count                   IN NUMBER DEFAULT NULL
    )
    RETURN VARCHAR2;

    -----------------------------------------------------------------------
    -- Executes data extraction rule and returns full class records.
    ----+----------------------------------+-------------------------------
    FUNCTION GetClassRecords(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
        ,p_daytime                         IN revn_data_filter_version.daytime%TYPE
        ,p_arguments                       IN t_table_revn_data_ext_arg
        ,p_max_row_count                   IN NUMBER DEFAULT NULL
    )
    RETURN SYS_REFCURSOR;

    -----------------------------------------------------------------------
    -- Executes data extraction rule and returns records with specified
    -- class attribute.
    ----+----------------------------------+-------------------------------
    FUNCTION GetClassAttribute(
         p_data_filter_id                  IN revn_data_filter.object_id%TYPE
        ,p_daytime                         IN revn_data_filter_version.daytime%TYPE
        ,p_arguments                       IN t_table_revn_data_ext_arg
        ,p_attribute_to_return             IN class_attribute_cnfg.attribute_name%TYPE
        ,p_attribute_to_read               IN class_attribute_cnfg.attribute_name%TYPE
        ,p_max_row_count                   IN NUMBER DEFAULT NULL
    )
    RETURN SYS_REFCURSOR;

    -----------------------------------------------------------------------
    -- Looks up the class attribute name from data filer based on values
    -- from the class mapping.
    ----+----------------------------------+-------------------------------
    FUNCTION GetAttributeNameFromFilterRule(
        p_object_id                        VARCHAR2,
        p_period                           DATE,
        p_value                            VARCHAR2
    )
    RETURN VARCHAR2;

END EcDp_Revn_Data_Ext;