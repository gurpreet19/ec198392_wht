CREATE OR REPLACE PACKAGE BODY ECDP_REVN_DEBUG IS

    cons_indentation_length                CONSTANT NUMBER := 4;
    cons_line_length                       CONSTANT NUMBER := 70;
    cons_line_seperator                    CONSTANT VARCHAR2(1) := '-';

    -----------------------------------------------------------------------
    -- Writes an empty line to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE new_line_p
    IS
    BEGIN
        ECDP_DYNSQL.WriteTempText(gv2_output_id, ' ');
    END;

    -----------------------------------------------------------------------
    -- Writes a line to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE write_line_p(
        p_line                             VARCHAR2
       ,p_indentation                      NUMBER DEFAULT 1
       )
    IS
        pedding VARCHAR2(100);
    BEGIN
        pedding := RPAD('    ',cons_indentation_length * p_indentation,' ');
        ECDP_DYNSQL.WriteTempText(gv2_output_id, pedding || p_line);
    END;

    -----------------------------------------------------------------------
    -- Writes a value to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE write_value_p(
        p_name                             VARCHAR2
       ,p_value                            VARCHAR2
       ,p_indentation                      NUMBER DEFAULT 1
       )
    IS
        pedding VARCHAR2(100);
    BEGIN
        pedding := RPAD('    ',cons_indentation_length * p_indentation,' ');
        ECDP_DYNSQL.WriteTempText(gv2_output_id, pedding || p_name || ' = ' || NVL(p_value, '(NULL)'));
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write_header_i(
        p_header                           VARCHAR2
       ,p_subheader                        VARCHAR2
       ,p_indentation                      NUMBER DEFAULT 0
        )
    IS
    BEGIN
        IF p_subheader IS NOT NULL THEN
            write_line_p(p_header || ' - ' || p_subheader, p_indentation);
        ELSE
            write_line_p(p_header, p_indentation);
        END IF;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write_seperator(
        p_indentation                      NUMBER
       )
    IS
        l_seperator_len                    NUMBER;
    BEGIN
        l_seperator_len := cons_line_length - p_indentation * cons_indentation_length;
        write_line_p(RPAD(cons_line_seperator,l_seperator_len,cons_line_seperator), p_indentation);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write
    IS
    BEGIN
        new_line_p;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write(
        p_line                             VARCHAR2
       )
    IS
    BEGIN
        write_line_p(p_line);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write(
        p_name                             VARCHAR2
       ,p_value                            VARCHAR2
       )
    IS
    BEGIN
        write_value_p(p_name, p_value);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write(
        p_name                             VARCHAR2
       ,p_value                            NUMBER
       )
    IS
    BEGIN
        write_value_p(p_name, to_char(p_value));
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write_i(
        p_line                             VARCHAR2
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        write_line_p(p_line, p_indentation);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write_i(
        p_name                             VARCHAR2
       ,p_value                            VARCHAR2
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        write_value_p(p_name, p_value, p_indentation);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write_i(
        p_name                             VARCHAR2
       ,p_value                            NUMBER
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        write_value_p(p_name, to_char(p_value), p_indentation);
    END;

END ECDP_REVN_DEBUG;