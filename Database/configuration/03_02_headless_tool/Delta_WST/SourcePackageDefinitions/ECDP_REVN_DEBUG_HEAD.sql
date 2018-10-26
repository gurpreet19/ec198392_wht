CREATE OR REPLACE PACKAGE ECDP_REVN_DEBUG IS

    gv2_output_id CONSTANT VARCHAR2(32) := 'REVN_DEBUG';

    -----------------------------------------------------------------------
    -- Writes log header to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE write_header_i(
        p_header                           VARCHAR2
       ,p_subheader                        VARCHAR2
       ,p_indentation                      NUMBER DEFAULT 0
        );

    -----------------------------------------------------------------------
    -- Writes a seperator line to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE write_seperator(
        p_indentation                      NUMBER
       );

    -----------------------------------------------------------------------
    -- Writes a line to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE write(
        p_line                             VARCHAR2
       );

    -----------------------------------------------------------------------
    -- Writes a value to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE write(
        p_name                             VARCHAR2
       ,p_value                            VARCHAR2
       );

    -----------------------------------------------------------------------
    -- Writes a value to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE write(
        p_name                             VARCHAR2
       ,p_value                            NUMBER
       );

    -----------------------------------------------------------------------
    -- Writes a line to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE write_i(
        p_line                             VARCHAR2
       ,p_indentation                      NUMBER
       );

    -----------------------------------------------------------------------
    -- Writes a value to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE write_i(
        p_name                             VARCHAR2
       ,p_value                            VARCHAR2
       ,p_indentation                      NUMBER
       );

    -----------------------------------------------------------------------
    -- Writes a value to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE write_i(
        p_name                             VARCHAR2
       ,p_value                            NUMBER
       ,p_indentation                      NUMBER
       );

    -----------------------------------------------------------------------
    -- Writes a new line to t_temptext.
    ----+----------------------------------+-------------------------------
    PROCEDURE write;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------

END ECDP_REVN_DEBUG;