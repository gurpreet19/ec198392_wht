CREATE OR REPLACE PACKAGE EcDp_BPM_util_json_clob IS

    -----------------------------------------------------------------------
    -- Replaces the JSON value in given path.
    --
    -- p_json: The json string
    -- p_json_path: The path of the element
    -- p_value_json: The new value to replace with
    ----+----------------------------------+-------------------------------
    FUNCTION replace_value(
        p_json                           CLOB
       ,p_json_path                      VARCHAR2
       ,p_value_json                     VARCHAR2
    )
    RETURN CLOB;

    -----------------------------------------------------------------------
    -- Replaces the element name in given path.
    --
    -- p_json: The json string
    -- p_json_path: The path of the element
    -- p_value_json: The new name represented in JSON
    ----+----------------------------------+-------------------------------
    FUNCTION replace_name(
        p_json                           CLOB
       ,p_json_path                      VARCHAR2
       ,p_name_json                      VARCHAR2
    )
    RETURN CLOB;

    -----------------------------------------------------------------------
    -- Inserts an element to a JSON array string.
    --
    -- p_json: The json string
    -- p_element_json: The json element to insert
    -- p_position_idx: Zero-based position indicates where to insert the
    --     given element
    ----+----------------------------------+-------------------------------
    FUNCTION insert_array_element(
        p_json                             CLOB
       ,p_json_path                        VARCHAR2
       ,p_element_json                     VARCHAR2
       ,p_position_idx                     NUMBER
       )
    RETURN CLOB;

END EcDp_BPM_util_json_clob;
