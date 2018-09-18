CREATE OR REPLACE PACKAGE BODY ECDP_REVN_COMMON IS


    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetFullDateString(
         p_date                            DATE
        )
    RETURN VARCHAR2
    IS
    BEGIN
        IF p_date IS NULL
        THEN
            RAISE ge_null_parameter_exception;
        END IF;

        RETURN to_char(p_date, 'YYYY-MM-DD"T"HH24:MI:SS');

    END GetFullDateString;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         VARCHAR2
        ,p_value_2                         VARCHAR2
        ,p_true_when_value_1_is_null       T_BOOLEAN_STR DEFAULT gv2_false
        )
    RETURN T_BOOLEAN_STR
    IS
    BEGIN
        RETURN TranslateBoolean(Equals(
            p_value_1, p_value_2, TranslateToBoolean(p_true_when_value_1_is_null)));
    END equals;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         NUMBER
        ,p_value_2                         NUMBER
        ,p_true_when_value_1_is_null       T_BOOLEAN_STR DEFAULT gv2_false
        )
    RETURN T_BOOLEAN_STR
    IS
    BEGIN
        RETURN TranslateBoolean(Equals(
            p_value_1, p_value_2, TranslateToBoolean(p_true_when_value_1_is_null)));
    END equals;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         DATE
        ,p_value_2                         DATE
        ,p_true_when_value_1_is_null       T_BOOLEAN_STR DEFAULT gv2_false
        )
    RETURN T_BOOLEAN_STR
    IS
    BEGIN
        RETURN TranslateBoolean(Equals(
            p_value_1, p_value_2, TranslateToBoolean(p_true_when_value_1_is_null)));
    END equals;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         VARCHAR2
        ,p_value_2                         VARCHAR2
        ,p_true_when_value_1_is_null       BOOLEAN
        )
    RETURN BOOLEAN
    IS
      lb_result BOOLEAN;
    BEGIN
        IF p_value_1 IS NULL AND (p_value_2 IS NULL OR p_true_when_value_1_is_null = true)  THEN
            lb_result := TRUE;
        ELSIF p_value_1 like '%*%' AND p_value_2 not like '%*%' THEN
            lb_result := upper(p_value_2) like upper(REPLACE(p_value_1,'*','%')) ;
        ELSE
            lb_result := (p_value_1 = p_value_2);
        END IF;

        RETURN NVL(lb_result, FALSE);
    END;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         NUMBER
        ,p_value_2                         NUMBER
        ,p_true_when_value_1_is_null       BOOLEAN
        )
    RETURN BOOLEAN
    IS
      lb_result BOOLEAN;
    BEGIN
        IF p_value_1 IS NULL AND p_value_2 IS NULL
        THEN
            lb_result := TRUE;
        ELSIF p_true_when_value_1_is_null
        THEN
            lb_result := (NVL(p_value_1, p_value_2) = p_value_2);
        ELSE
            lb_result := (p_value_1 = p_value_2);
        END IF;

        RETURN NVL(lb_result, FALSE);
    END;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Equals(
         p_value_1                         DATE
        ,p_value_2                         DATE
        ,p_true_when_value_1_is_null       BOOLEAN
        )
    RETURN BOOLEAN
    IS
      lb_result BOOLEAN;
    BEGIN
        IF p_value_1 IS NULL AND p_value_2 IS NULL
        THEN
            lb_result := TRUE;
        ELSIF p_true_when_value_1_is_null
        THEN
            lb_result := (NVL(p_value_1, p_value_2) = p_value_2);
        ELSE
            lb_result := (p_value_1 = p_value_2);
        END IF;

        RETURN NVL(lb_result, FALSE);
    END;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION TranslateBoolean(
         lp_value                          BOOLEAN
        )
    RETURN T_BOOLEAN_STR
    IS
    BEGIN
        IF lp_value IS NULL
        THEN
            RAISE ge_null_parameter_exception;
        END IF;

        IF lp_value
        THEN
            RETURN gv2_true;
        ELSE
            RETURN gv2_false;
        END IF;
    END TranslateBoolean;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION TranslateToBoolean(
         lp_value                          T_BOOLEAN_STR
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF lp_value IS NULL
        THEN
            RAISE ge_null_parameter_exception;
        END IF;

        IF lp_value = gv2_true
        THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END TranslateToBoolean;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE RaiseAppErrorWhenNull(
         p_value                           VARCHAR2
        ,p_error_msg                       VARCHAR2
        ,p_error_no                        NUMBER DEFAULT -20000
        )
    IS
    BEGIN
        IF p_error_no IS NULL
        THEN
            RAISE ge_null_parameter_exception;
        END IF;

        IF p_value IS NULL
        THEN
            raise_application_error(p_error_no, p_error_msg);
        END IF;
    END RaiseAppErrorWhenNull;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION SplitStr(
         p_str                             VARCHAR2
        ,p_split_regex                     VARCHAR2
        )
    RETURN T_TABLE_VARCHAR2
    IS
        lo_result T_TABLE_VARCHAR2;
        lv2_item VARCHAR2(64);
    BEGIN
        lo_result := T_TABLE_VARCHAR2();

        lv2_item := regexp_substr(p_str, p_split_regex, 1, lo_result.count + 1);
        WHILE lv2_item IS NOT NULL
        LOOP
            lo_result.extend(1);
            lo_result(lo_result.count) := lv2_item;
            lv2_item := regexp_substr(p_str, '[^,]+', 1, lo_result.count + 1);
        END LOOP;

        RETURN lo_result;

    END SplitStr;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION SplitStrByComma(
         p_str                             VARCHAR2
        )
    RETURN T_TABLE_VARCHAR2
    IS
    BEGIN
        RETURN SplitStr(p_str, gv2_split_regex_comma);

    END SplitStrByComma;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Concat(
         p_str                             T_TABLE_VARCHAR2
        ,p_split                           VARCHAR2
        )
    RETURN VARCHAR2
    IS
        lv2_result VARCHAR2(320);
    BEGIN
        IF p_str.COUNT > 0
        THEN
            lv2_result := p_str(p_str.FIRST);
        END IF;

        FOR idx IN p_str.FIRST + 1 .. p_str.LAST
        LOOP
            lv2_result := lv2_result || p_split || p_str(idx);
        END LOOP;

        RETURN lv2_result;

    END Concat;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION ConcatByComma(
         p_str                             T_TABLE_VARCHAR2
        )
    RETURN VARCHAR2
    IS
    BEGIN
        RETURN Concat(p_str, gv2_concat_regex_comma);

    END ConcatByComma;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION Code(
         p_code_text                       VARCHAR2
        ,p_code_type                       VARCHAR2
        )
    RETURN PROSTY_CODES.CODE%TYPE
    IS
        v_return_val PROSTY_CODES.CODE%TYPE;
         CURSOR c_col_val IS
             SELECT code col
             FROM PROSTY_CODES
             WHERE code_text = p_code_text
                 AND code_type = p_code_type;
    BEGIN
        FOR cur_row IN c_col_val LOOP
            v_return_val := cur_row.col;
        END LOOP;

        RETURN v_return_val;
    END Code;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetNumbers(
         p_to                              NUMBER
        )
    RETURN T_TABLE_NUMBER
    IS
        lt_range                           t_table_number;
    BEGIN
        SELECT rownum
        BULK COLLECT INTO lt_range
        FROM dual
        CONNECT BY rownum <= p_to;

        RETURN lt_range;
    END;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION get_ratio(
        p_part                             NUMBER
       ,p_total                            NUMBER
       )
    RETURN NUMBER
    IS
    BEGIN
        IF (p_part = 0 AND p_total = 0) OR p_total = 0 THEN
            RETURN NULL;
        ELSE
            RETURN p_part/p_total;
        END IF;
    END;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION get_next(
        p_collection                       IN OUT NOCOPY t_table_varchar2
       ,p_index                            IN OUT NUMBER
       )
    RETURN VARCHAR2
    IS
    BEGIN
        p_index := p_index + 1;
        RETURN CASE WHEN p_collection.count >= p_index THEN p_collection(p_index) ELSE NULL END;
    END;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION append(
        p_collection                       IN OUT NOCOPY t_table_varchar2
       ,p_value                            VARCHAR2
       )
    RETURN NUMBER
    IS
    BEGIN
        p_collection.extend;
        p_collection(p_collection.last) := p_value;
        RETURN p_collection.last;
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION append(
        p_collection                       IN OUT NOCOPY t_table_number
       ,p_value                            NUMBER
       )
    RETURN NUMBER
    IS
    BEGIN
        p_collection.extend;
        p_collection(p_collection.last) := p_value;
        RETURN p_collection.last;
    END;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE append(
        p_collection                       IN OUT NOCOPY t_table_varchar2
       ,p_value                            VARCHAR2
       )
    IS
        l_new_index                        NUMBER;
    BEGIN
        l_new_index := append(p_collection, p_value);
    END;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE append(
        p_collection                       IN OUT NOCOPY t_table_number
       ,p_value                            NUMBER
       )
    IS
        l_new_index                        NUMBER;
    BEGIN
        l_new_index := append(p_collection, p_value);
    END;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION contains(
        p_collection                       IN OUT NOCOPY t_table_varchar2
       ,p_value                            VARCHAR2
       )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_collection IS NULL OR p_collection.count = 0 THEN
            RETURN FALSE;
        END IF;

        FOR idx IN p_collection.first..p_collection.last LOOP
            IF p_collection(idx) = p_value THEN
                RETURN TRUE;
            END IF;
        END LOOP;

        RETURN FALSE;
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION contains(
        p_collection                       IN OUT NOCOPY t_table_number
       ,p_value                            NUMBER
       )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_collection IS NULL OR p_collection.count = 0 THEN
            RETURN FALSE;
        END IF;

        FOR idx IN p_collection.first..p_collection.last LOOP
            IF p_collection(idx) = p_value THEN
                RETURN TRUE;
            END IF;
        END LOOP;

        RETURN FALSE;
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------

END ECDP_REVN_COMMON;