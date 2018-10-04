CREATE OR REPLACE PACKAGE EcDp_BPM_util_json IS

    -----------------------------------------------------------------------
    -- Inserts an element to a JSON array string.
    --
    -- p_json: The json string
    -- p_element_json: The json element to insert
    -- p_position_idx: Zero-based position indicates where to insert the
    --     given element
    ----+----------------------------------+-------------------------------
    FUNCTION insert_array_element(
        p_json                             VARCHAR2
       ,p_element_json                     VARCHAR2
       ,p_position_idx                     NUMBER
       )
    RETURN VARCHAR2;


    -----------------------------------------------------------------------
    -- Extracts value in a JSON string and returns the value.
    --
    -- p_json: The json string
    ----+----------------------------------+-------------------------------
    FUNCTION value_of(
        p_json                           VARCHAR2
    )
    RETURN VARCHAR2;


    -----------------------------------------------------------------------
    -- Extracts value in a JSON string and returns string representation
    -- of it.
    --
    -- p_json: The json string
    ----+----------------------------------+-------------------------------
    FUNCTION value_of(
        p_json                           VARCHAR2
       ,p_json_path                      VARCHAR2
    )
    RETURN VARCHAR2;


    -----------------------------------------------------------------------
    -- Gets the end index of an object in the given JSON.
    --
    -- p_json: The json string
    -- p_start_idx: The start of an element whose end to search for
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_obj(
        p_json                           VARCHAR2
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER;


    -----------------------------------------------------------------------
    -- Gets the end index of an array in the given JSON.
    --
    -- p_json: The json string
    -- p_start_idx: The start of an element whose end to search for
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_array(
        p_json                           VARCHAR2
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER;


    -----------------------------------------------------------------------
    -- Gets the end index of a string in the given JSON.
    --
    -- p_json: The json string
    -- p_start_idx: The start of an element whose end to search for
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_string(
        p_json                           VARCHAR2
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER;


    -----------------------------------------------------------------------
    -- Gets the end index of a number in the given JSON.
    --
    -- p_json: The json string
    -- p_start_idx: The start of an element whose end to search for
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_number(
        p_json                           VARCHAR2
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER;


    -----------------------------------------------------------------------
    -- Gets the end index of a element in the given JSON.
    --
    -- p_json: The json string
    -- p_start_idx: The start of an element whose end to search for
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_element(
        p_json                           VARCHAR2
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER;

    -----------------------------------------------------------------------
    -- Gets the start index of the value section in a name-value pair.
    --
    -- p_json: The json string
    -- p_start_idx: The start of a name-value pair
    ----+----------------------------------+-------------------------------
    FUNCTION start_of_value(
        p_json                           VARCHAR2
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER;

    -----------------------------------------------------------------------
    -- Gets the end index of a name-value pair.
    --
    -- p_json: The json string
    -- p_start_idx: The start of an element whose end to search for
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_value_pair(
        p_json                           VARCHAR2
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER;


    -----------------------------------------------------------------------
    -- Gets the start index of a named root element.
    --
    -- p_json: The json string
    -- p_element_name: The name of the root element
    -- p_start_idx: The start of an element whose end to search for
    ----+----------------------------------+-------------------------------
    FUNCTION start_of(
        p_json                           VARCHAR2
       ,p_element_name                   VARCHAR2
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER;

    -----------------------------------------------------------------------
    -- Gets the start index of an element indicated in the provided path.
    --
    -- p_json: The json string
    -- p_json_path: The path of the element
    -- p_start_idx: The start of an element whose end to search for
    ----+----------------------------------+-------------------------------
    FUNCTION start_of_path(
        p_json                           VARCHAR2
       ,p_json_path                      VARCHAR2
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER;


    -----------------------------------------------------------------------
    -- Replaces the JSON value in given path.
    --
    -- p_json: The json string
    -- p_json_path: The path of the element
    -- p_value_json: The new value to replace with
    ----+----------------------------------+-------------------------------
    FUNCTION replace_value(
        p_json                           VARCHAR2
       ,p_json_path                      VARCHAR2
       ,p_value_json                     VARCHAR2
    )
    RETURN VARCHAR2;

    -----------------------------------------------------------------------
    -- Inserts an element to a JSON array string.
    --
    -- p_json: The json string
    -- p_element_json: The json element to insert
    -- p_position_idx: Zero-based position indicates where to insert the
    --     given element
    ----+----------------------------------+-------------------------------
    FUNCTION insert_array_element(
        p_json                             VARCHAR2
       ,p_json_path                        VARCHAR2
       ,p_element_json                     VARCHAR2
       ,p_position_idx                     NUMBER
       )
    RETURN VARCHAR2;

    -----------------------------------------------------------------------
    -- Removes the quotes (") around a value.
    --
    -- p_value: The value
    ----+----------------------------------+-------------------------------
    FUNCTION without_quotes(
        p_value                            VARCHAR2
        )
    RETURN VARCHAR2;

END EcDp_BPM_util_json;
