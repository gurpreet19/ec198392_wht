CREATE OR REPLACE TYPE BODY T_REVN_FT_DOC_INFO AS
    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    CONSTRUCTOR FUNCTION T_REVN_FT_DOC_INFO(
         p_document_key                     VARCHAR2
     )
    RETURN SELF AS RESULT
    IS
    BEGIN
       key := p_document_key;
       RETURN;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE refresh
    IS
        CURSOR c_get_document_info(
            cp_document_key                VARCHAR2
        ) IS
            SELECT doc.object_id,
               doc.document_concept,
               doc.document_level_code,
               doc.daytime,
               doc.status_code,
               doc.processing_period,
               doc.document_date,
               doc.customer_id,
               doc.booking_currency_id,
               doc.contract_group_code,
               doc.contract_doc_id
            FROM cont_document doc
            WHERE doc.document_key = cp_document_key;
    BEGIN
       FOR doc IN c_get_document_info(key) LOOP
           concept := doc.document_concept;
           status := doc.status_code;
           daytime := doc.daytime;
           document_date := doc.document_date;
           level_code := doc.document_level_code;
           contract_id := doc.object_id;
           processing_period := doc.processing_period;
           customer_id := doc.customer_id;
           booking_currency_id := doc.booking_currency_id;
           contract_group := doc.contract_group_code;
           template_id := doc.contract_doc_id;
       END LOOP;
    END;
END;