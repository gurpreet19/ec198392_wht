CREATE OR REPLACE PACKAGE Ecdp_Transaction_Qty IS

    CURSOR gc_tt_company_share(
        cp_transaction_tmpl_id              VARCHAR2,
        cp_daytime                          DATE,
        cp_field_id                         VARCHAR2,
        cp_company_id                       VARCHAR2)
    IS
        SELECT COMPANY_SPLITS.SPLIT_SHARE_MTH SHARE_VALUE,
               ec_stream_item_version.company_id(COMPANY_SPLITS.split_member_id, COMPANY_SPLITS.daytime, '<=') COMPANY_ID
          FROM TRANSACTION_TMPL_VERSION TEMPLATES,
               SPLIT_KEY_SETUP          FIELD_SPLITS,
               SPLIT_KEY_SETUP          COMPANY_SPLITS,
               STREAM_ITEM_VERSION      STREAM_ITEM,
               STREAM_ITEM_VERSION      FIELD_STREAM_ITEM
         WHERE TEMPLATES.OBJECT_ID = cp_transaction_tmpl_id
           AND TEMPLATES.DAYTIME <= cp_daytime
           AND NVL(TEMPLATES.END_DATE, cp_daytime + 1) > cp_daytime
           AND FIELD_SPLITS.OBJECT_ID = TEMPLATES.SPLIT_KEY_ID
           AND FIELD_SPLITS.DAYTIME = TEMPLATES.DAYTIME
           AND COMPANY_SPLITS.OBJECT_ID = FIELD_SPLITS.CHILD_SPLIT_KEY_ID
           AND COMPANY_SPLITS.DAYTIME = FIELD_SPLITS.DAYTIME
           AND STREAM_ITEM.OBJECT_ID = COMPANY_SPLITS.SPLIT_MEMBER_ID
           AND STREAM_ITEM.DAYTIME <= COMPANY_SPLITS.DAYTIME
           AND NVL(STREAM_ITEM.END_DATE, COMPANY_SPLITS.DAYTIME + 1) > COMPANY_SPLITS.DAYTIME
           AND STREAM_ITEM.COMPANY_ID = NVL(cp_company_id, STREAM_ITEM.COMPANY_ID)
           AND FIELD_STREAM_ITEM.OBJECT_ID = FIELD_SPLITS.SPLIT_MEMBER_ID
           AND FIELD_STREAM_ITEM.DAYTIME <= FIELD_SPLITS.DAYTIME
           AND NVL(FIELD_STREAM_ITEM.END_DATE, FIELD_SPLITS.DAYTIME + 1) > FIELD_SPLITS.DAYTIME
           AND FIELD_STREAM_ITEM.FIELD_ID = NVL(cp_field_id, FIELD_STREAM_ITEM.FIELD_ID);


    PROCEDURE SetTransPriceObject(p_transaction_key      VARCHAR2,
                                  p_price_object_id      VARCHAR2,
                                  p_user                 VARCHAR2,
                                  p_qty_type_fallback    VARCHAR2 DEFAULT NULL);

    ------------------------+-----------------------------------+------------------------------------+---------------------------
    -- Generates quantities on specified transaction, including pulling values for quantity line
    -- items.
    --
    -- Usage: ecdp_transaction.fill_transaction_i. no screen usages.
    ------------------------+-----------------------------------+------------------------------------+---------------------------
    FUNCTION GenTransQty_I(
                             p_object_id                        VARCHAR2
                            ,p_transaction_id                   VARCHAR2
                            ,p_user                             VARCHAR2
                            ,p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
                            ,p_force_update                     BOOLEAN DEFAULT FALSE
    )
    RETURN BOOLEAN;

    FUNCTION GetFullCompanyFromContract(p_contract_id VARCHAR2, p_daytime DATE)
    RETURN VARCHAR2;

    -----------------------------------------------------------------------
    -- Creates missing quantity line items by looking at the price
    -- elements.
    ----+----------------------------------+-------------------------------
    PROCEDURE create_missing_qty_li_by_pel_i(
        p_transaction_key                  VARCHAR2
       );

    FUNCTION GetTransPriceObject(p_tran_po_id  VARCHAR2,
                                 p_ifac_po_id  VARCHAR2,
                                 p_daytime     DATE,
                                 p_silence_ind VARCHAR2 DEFAULT 'N',
                                 p_doc_concept VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;


    PROCEDURE SetTransVAT(p_transaction_key varchar2,p_vat_code varchar2 default null,p_user varchar2);

    FUNCTION VerifyVatCodeCountry (p_object_id varchar2,
                                   p_vat_code varchar2,
                                   p_daytime date,
                                   p_financial_code varchar2 ) return varchar2;

    FUNCTION GetFieldShare(p_transaction_tmpl_id  VARCHAR2, p_daytime DATE, p_dist_id VARCHAR2) RETURN NUMBER;

    FUNCTION GetCompanyShare(
        p_transaction_tmpl_id                   VARCHAR2,
        p_daytime                               DATE,
        p_field_id                              VARCHAR2,
        p_company_id                            VARCHAR2)
    RETURN NUMBER;

    FUNCTION SourceEntryNoExists(
              source_entry_no NUMBER,
              ltab t_table_number
              )
    RETURN VARCHAR2;


END Ecdp_Transaction_Qty;