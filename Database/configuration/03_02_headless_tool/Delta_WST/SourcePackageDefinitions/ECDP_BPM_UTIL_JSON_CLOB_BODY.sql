CREATE OR REPLACE PACKAGE BODY EcDp_BPM_util_json_clob IS

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION insert_array_element(
        p_json                             IN OUT NOCOPY CLOB
       ,p_element_json                     VARCHAR2
       ,p_position_idx                     NUMBER
       )
    RETURN VARCHAR2
    IS
        n_idx                              NUMBER;
        n_element_json                     VARCHAR2(256);
    BEGIN
        n_idx := dbms_lob.instr(p_json, '[');

        FOR pos_idx IN 0..p_position_idx - 1
        LOOP
            n_idx := dbms_lob.instr(p_json, ',', n_idx + 1);
            IF (n_idx = 0) THEN
               EXIT;
            END IF;
        END LOOP;

        IF (n_idx = 0) THEN
            n_idx := dbms_lob.instr(p_json, ']') - 1;
            n_element_json := ',' || p_element_json;
        ELSE
            n_element_json := p_element_json || ',';
        END IF;

        RETURN dbms_lob.substr(p_json, n_idx, 1) || n_element_json || dbms_lob.substr(p_json, 32767, n_idx + 1);
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION value_of(
        p_json                           IN OUT NOCOPY CLOB
    )
    RETURN VARCHAR2
    IS
        n_value                          VARCHAR2(256);
        n_value_start_idx                NUMBER;
        n_value_end_idx                  NUMBER;
    BEGIN
        n_value_start_idx := dbms_lob.instr(p_json, '".value":') + LENGTH('".value":');
        n_value_end_idx := dbms_lob.instr(p_json, ',', n_value_start_idx);
        n_value := dbms_lob.substr(p_json, n_value_end_idx - n_value_start_idx, n_value_start_idx);

        RETURN n_value;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_obj(
        p_json                           IN OUT NOCOPY CLOB
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER
    IS
        n_idx                            NUMBER;
        n_start_idx                      NUMBER;
        n_end_idx                        NUMBER;
        n_level                          NUMBER;
    BEGIN
        n_idx := p_start_idx;
        n_level := 1;

        WHILE n_level <> 0
        LOOP
            n_start_idx := dbms_lob.instr(p_json, '{', n_idx + 1);
            n_end_idx := dbms_lob.instr(p_json, '}', n_idx + 1);

            IF n_start_idx <> 0 AND n_start_idx < n_end_idx THEN
                n_idx := n_start_idx;
                n_level := n_level + 1;
            ELSE
                n_idx := n_end_idx;
                n_level := n_level - 1;
            END IF;

            IF n_idx = 0 THEN
                EXIT;
            END IF;
        END LOOP;

        RETURN n_idx;
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_array(
        p_json                           IN OUT NOCOPY CLOB
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER
    IS
        n_idx                            NUMBER;
        n_start_idx                      NUMBER;
        n_end_idx                        NUMBER;
        n_level                          NUMBER;
    BEGIN
        n_idx := p_start_idx;
        n_level := 1;

        WHILE n_level <> 0
        LOOP
            n_start_idx := dbms_lob.instr(p_json, '[', n_idx + 1);
            n_end_idx := dbms_lob.instr(p_json, ']', n_idx + 1);

            IF n_start_idx <> 0 AND n_start_idx < n_end_idx THEN
                n_idx := n_start_idx;
                n_level := n_level + 1;
            ELSE
                n_idx := n_end_idx;
                n_level := n_level - 1;
            END IF;

            IF n_idx = 0 THEN
                EXIT;
            END IF;
        END LOOP;

        RETURN n_idx;
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_string(
        p_json                           IN OUT NOCOPY CLOB
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER
    IS
        n_idx                            NUMBER;
        n_escaped_idx                    NUMBER;
        n_end_idx                        NUMBER;
        n_found                          BOOLEAN;
    BEGIN
        n_idx := p_start_idx;
        n_found := FALSE;

        WHILE NOT n_found
        LOOP
            n_escaped_idx := dbms_lob.instr(p_json, '\"', n_idx + 1);
            n_end_idx := dbms_lob.instr(p_json, '"', n_idx + 1);

            IF n_escaped_idx <> 0 AND n_escaped_idx < n_end_idx THEN
                n_idx := n_escaped_idx + 2;
            ELSE
                n_idx := n_end_idx;
                n_found := TRUE;
            END IF;

            IF n_idx = 0 THEN
                EXIT;
            END IF;
        END LOOP;

        RETURN n_idx;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_number(
        p_json                           IN OUT NOCOPY CLOB
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER
    IS
        n_end_idx_1                      NUMBER;
        n_end_idx_2                      NUMBER;
        n_end_idx_3                      NUMBER;
    BEGIN
        n_end_idx_1 := dbms_lob.instr(p_json, ',', p_start_idx + 1);
        n_end_idx_2 := dbms_lob.instr(p_json, ']', p_start_idx + 1);
        n_end_idx_3 := dbms_lob.instr(p_json, '}', p_start_idx + 1);

        IF n_end_idx_1 <> 0 THEN
            RETURN n_end_idx_1 - 1;
        ELSIF n_end_idx_2 <> 0 THEN
            RETURN n_end_idx_2 - 1;
        ELSIF n_end_idx_3 <> 0 THEN
            RETURN n_end_idx_3 - 1;
        ELSE
            RETURN LENGTH(p_json);
        END IF;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_element(
        p_json                           IN OUT NOCOPY CLOB
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER
    IS
        n_start_symbol                   VARCHAR2(1);
    BEGIN
        n_start_symbol := dbms_lob.substr(p_json, 1, p_start_idx);

        IF n_start_symbol = '{' THEN
            RETURN end_of_obj(p_json, p_start_idx);
        ELSIF n_start_symbol = '[' THEN
            RETURN end_of_array(p_json, p_start_idx);
        ELSIF n_start_symbol = '"' THEN
            RETURN end_of_string(p_json, p_start_idx);
        ELSIF n_start_symbol = ':' THEN
            RETURN 0;
        ELSE
            RETURN end_of_number(p_json, p_start_idx);
        END IF;
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION start_of_value(
        p_json                           IN OUT NOCOPY CLOB
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER
    IS
        n_value_sep_idx                  NUMBER;
    BEGIN
        n_value_sep_idx := dbms_lob.instr(p_json, ':', p_start_idx);

        IF n_value_sep_idx = 0 THEN
            RETURN 0;
        ELSE
            RETURN n_value_sep_idx + 1;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION end_of_value_pair(
        p_json                           IN OUT NOCOPY CLOB
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER
    IS
        n_value_start_idx                NUMBER;
    BEGIN
        n_value_start_idx := start_of_value(p_json, p_start_idx);

        IF n_value_start_idx = 0 THEN
            RETURN 0;
        ELSE
            RETURN end_of_element(p_json, n_value_start_idx);
        END IF;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION start_of(
        p_json                           IN OUT NOCOPY CLOB
       ,p_element_name                   VARCHAR2
       ,p_start_idx                      NUMBER
    )
    RETURN NUMBER
    IS
        n_idx                            NUMBER;
        n_end_idx                        NUMBER;
    BEGIN
        n_idx := p_start_idx;
        n_end_idx := end_of_element(p_json, p_start_idx);

        WHILE n_idx < n_end_idx LOOP
            IF dbms_lob.instr(p_json, '"' || p_element_name || '"', n_idx + 1) = n_idx + 1 THEN
                RETURN n_idx + 1;
            ELSE
                n_idx := end_of_value_pair(p_json, n_idx + 1) + 1;
            END IF;
        END LOOP;

        RETURN 0;
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION start_of_path(
        p_json                           IN OUT NOCOPY CLOB
       ,p_json_path                      VARCHAR2
    )
    RETURN NUMBER
    IS
        CURSOR n_path(cp_path_str VARCHAR2) IS (
            SELECT regexp_substr(cp_path_str,'[^/]+', 1, LEVEL) AS NAME FROM dual
            CONNECT BY regexp_substr(cp_path_str, '[^/]+', 1, LEVEL) IS NOT NULL
        );

        n_idx                            NUMBER;
    BEGIN
        n_idx := 1;

        FOR p IN n_path(p_json_path)
        LOOP
            IF n_idx <> 1 THEN
                n_idx := start_of_value(p_json, n_idx + 1);
                IF n_idx = 0 THEN
                    EXIT;
                END IF;
            END IF;

            n_idx := start_of(p_json, p.name, n_idx);
            IF n_idx = 0 THEN
                EXIT;
            END IF;
        END LOOP;

        RETURN n_idx;
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION value_of(
        p_json                           IN OUT NOCOPY CLOB
       ,p_json_path                      VARCHAR2
    )
    RETURN VARCHAR2
    IS
        n_idx                            NUMBER;
        n_end_idx                        NUMBER;
    BEGIN
        n_idx := start_of_path(p_json, p_json_path);
        IF n_idx = 0 THEN
            RETURN NULL;
        END IF;

        n_idx := start_of_value(p_json, n_idx + 1);
        n_end_idx := end_of_element(p_json, n_idx);

        IF n_idx = 0 THEN
            RETURN NULL;
        END IF;

        RETURN dbms_lob.substr(p_json, n_end_idx - n_idx + 1, n_idx);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION replace_value(
        p_json                           CLOB
       ,p_json_path                      VARCHAR2
       ,p_value_json                     VARCHAR2
    )
    RETURN CLOB
    IS
        n_idx                            NUMBER;
        n_end_idx                        NUMBER;
        n_json                           CLOB;
    BEGIN
        n_json := p_json;
        n_idx := start_of_path(n_json, p_json_path);
        IF n_idx = 0 THEN
            RETURN p_json;
        END IF;

        n_idx := start_of_value(n_json, n_idx + 1);
        n_end_idx := end_of_element(n_json, n_idx);

        IF n_idx = 0 THEN
            RETURN p_json;
        END IF;

        RETURN dbms_lob.substr(n_json, n_idx - 1, 1) || p_value_json || dbms_lob.substr(n_json, 32767, n_end_idx + 1);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION replace_name(
        p_json                           CLOB
       ,p_json_path                      VARCHAR2
       ,p_name_json                      VARCHAR2
    )
    RETURN CLOB
    IS
        n_idx                            NUMBER;
        n_end_idx                        NUMBER;
        n_json                           CLOB;
    BEGIN
        n_json := p_json;
        n_idx := start_of_path(n_json, p_json_path);
        IF n_idx = 0 THEN
            RETURN NULL;
        END IF;

        n_end_idx := end_of_element(n_json, n_idx);

        IF n_idx = 0 THEN
            RETURN NULL;
        END IF;

        RETURN dbms_lob.substr(n_json, n_idx - 1, 1) || p_name_json || dbms_lob.substr(n_json, 32767, n_end_idx + 1);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION insert_array_element(
        p_json                             CLOB
       ,p_json_path                        VARCHAR2
       ,p_element_json                     VARCHAR2
       ,p_position_idx                     NUMBER
       )
    RETURN CLOB
    IS
        n_value                            VARCHAR2(512);
        n_json                             CLOB;
    BEGIN
        n_json := p_json;
        n_value := value_of(n_json, p_json_path);
        n_value := insert_array_element(n_value, p_element_json, p_position_idx);
        RETURN replace_value(n_json, p_json_path, n_value);
    END;

END EcDp_BPM_util_json_clob;