CREATE OR REPLACE TYPE T_REVN_FT_DOC_INFO AS OBJECT (
    key                               VARCHAR2(32)
   ,concept                           VARCHAR2(32)
   ,status                            VARCHAR(32)
   ,daytime                           DATE
   ,document_date                     DATE
   ,processing_period                 DATE
   ,level_code                        VARCHAR(32)
   ,contract_id                       VARCHAR(32)
   ,customer_id                       VARCHAR(32)
   ,booking_currency_id               VARCHAR(32)
   ,contract_group                    VARCHAR(32)
   ,template_id                       VARCHAR(32)

    -----------------------------------------------------------------------
    -- Initializes a new T_REVN_FT_DOC_INFO object.
    ----+----------------------------------+-------------------------------
   ,CONSTRUCTOR FUNCTION T_REVN_FT_DOC_INFO(
        p_document_key                     VARCHAR2
    )
    RETURN SELF AS RESULT

   ,MEMBER PROCEDURE refresh
)
;