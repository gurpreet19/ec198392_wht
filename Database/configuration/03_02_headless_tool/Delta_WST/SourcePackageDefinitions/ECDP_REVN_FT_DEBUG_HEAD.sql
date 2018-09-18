CREATE OR REPLACE PACKAGE ECDP_REVN_FT_DEBUG IS
    --*********************************************************************
    --* This package contains members for debugging revenue packages (FT
    --* module).
    --*********************************************************************

    -----------------------------------------------------------------------
    -- Writes the content of a FT document to t_temptext table.
    -- The id on t_temptext will be gv2_output_id.
    ----+----------------------------------+-------------------------------
    PROCEDURE write_doc(
        p_title                            VARCHAR2
       ,p_document_key                     cont_document.document_key%TYPE
        );

    -----------------------------------------------------------------------
    -- Writes the content of a period ifac collection to t_temptext table.
    -- The id on t_temptext will be gv2_output_id.
    ----+----------------------------------+-------------------------------
    PROCEDURE write(
        p_title                            VARCHAR2
       ,p_ifac_collection                  t_table_ifac_sales_qty
       ,p_indentation                     NUMBER DEFAULT 0
         );

    -----------------------------------------------------------------------
    -- Writes un-processed ifac data for period.
    ----+----------------------------------+-------------------------------
    PROCEDURE write_new_ifac_period(
        p_title                            VARCHAR2
        );

END ECDP_REVN_FT_DEBUG;