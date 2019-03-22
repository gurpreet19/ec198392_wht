CREATE OR REPLACE PACKAGE Ecdp_Transaction IS
/****************************************************************
** Package        :  Ecdp_Transaction, header part
**
** $Revision: 1.247 $
**
** Purpose        :  Provide special functions on Transactions.
**
** Documentation  :  www.energy-components.com
**
** Created  : 29.11.2005 Trond-Arne Brattli
**
** Modification history:
**
** Version  Date        Whom        Change description:
** -------  ------      -----       --------------------------------------
**                                  See package body for details
*************************************************************************/

TYPE gr_array IS RECORD
  (
   str1 VARCHAR2(32),
   str2 VARCHAR2(32),
   str3 VARCHAR2(32),
   str4 VARCHAR2(240),
   str5 VARCHAR2(240)
  );

TYPE gt_ArrTable IS TABLE OF gr_array;


------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
TYPE T_PC_DIST_INFO IS RECORD
(
      STREAM_ITEM_ID                        VARCHAR2(32)
     ,STREAM_ITEM_CODE                      VARCHAR2(32)
     ,PROFIT_CENTER_ID                      VARCHAR2(32)
     ,CHILD_SPLIT_KEY_ID                    VARCHAR2(32)
     ,PROFIT_CENTER_SHARE                   NUMBER
     ,MATCH_LEVEL                           NUMBER
);


TYPE T_TABLE_PC_DIST_INFO IS TABLE OF T_PC_DIST_INFO;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
TYPE T_COMPANY_DIST_INFO IS RECORD
(
      STREAM_ITEM_ID                         VARCHAR2(32)
     ,STREAM_ITEM_CODE                       VARCHAR2(32)
     ,VENDOR_ID                              VARCHAR2(32)
     ,VENDOR_SHARE                           NUMBER
     ,CUSTOMER_ID                            VARCHAR2(32)
     ,CUSTOMER_SHARE                         NUMBER
     ,MATCH_LEVEL                            NUMBER
);


TYPE T_TABLE_COMPANY_DIST_INFO IS TABLE OF T_COMPANY_DIST_INFO;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
TYPE T_PROFIT_CENTRE_ID IS RECORD
(
      PROFIT_CENTRE_ID                         VARCHAR2(32)
      ,SPLIT_SHARE                             NUMBER

);


TYPE T_TABLE_PROFIT_CENTRE_ID IS TABLE OF T_PROFIT_CENTRE_ID;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
TYPE T_PC_VENDOR_ID IS RECORD
(
       COMPANY_ID                             VARCHAR2(32)
      ,PARTY_SHARE                            NUMBER

);


TYPE T_TABLE_PC_VENDOR_ID IS TABLE OF T_PC_VENDOR_ID;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------



CURSOR gc_line_item(cp_transaction_key VARCHAR2) IS
SELECT c.line_item_key, c.line_item_based_type
  FROM cont_line_item c
 WHERE c.transaction_key = cp_transaction_key;

 CURSOR  gc_all_sorted_transactions (cp_document_key VARCHAR2) IS
 SELECT  transaction_key, ec_transaction_template.sort_order(trans_template_id) tt_sort
   FROM  cont_transaction
  WHERE  document_key = cp_document_key
ORDER BY transaction_date,
         tt_sort,
         ifac_unique_key_1,
         ifac_unique_key_2,
         nvl(preceding_trans_key,reversed_trans_key),
         nvl(reversal_ind,'N') DESC,
         transaction_key;

CURSOR gc_transaction_tmpl_missing(cp_document_key VARCHAR2) IS
        SELECT tmpl.object_id, tmpl_ver.daytime, tmpl_ver.name, tmpl.object_code
        FROM transaction_template tmpl, transaction_tmpl_version tmpl_ver, cont_document doc
        WHERE doc.document_key = cp_document_key
             AND tmpl.contract_doc_id = doc.contract_doc_id
             AND nvl(doc.processing_period, doc.DOCUMENT_DATE) >= tmpl_ver.daytime
             AND nvl(doc.processing_period, doc.DOCUMENT_DATE) < nvl(tmpl_ver.end_date, TO_DATE('9999-12-31', 'YYYY-MM-DD') )
             AND tmpl.object_id = tmpl_ver.object_id
              AND not exists (select TRANS_TEMPLATE_ID from cont_transaction where document_key = cp_document_key and TRANS_TEMPLATE_ID = tmpl.object_id)
        ORDER BY tmpl.object_id;


TYPE t_constrained_factor IS RECORD (
  uom2_factor NUMBER,
  uom3_factor NUMBER,
  uom4_factor NUMBER,
  stream_item_object_id objects.object_id%TYPE
);

TYPE t_constrained_factor_table IS TABLE OF t_constrained_factor;

TYPE t_transaction_id IS RECORD (
  object_id  VARCHAR2(32),
  document_key VARCHAR2(32),
  transaction_key VARCHAR2(32)
);

TYPE t_trans_table IS TABLE OF t_transaction_id;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Returns a collection of varchar2 containing keys of all quantity line items in the given transaction.
--
-- p_transaction_key: the key of transaction to generate lines for.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION get_qty_li_keys(
                         p_transaction_key                  VARCHAR2
)
RETURN t_table_varchar2;
------------------------+-----------------------------------+------------------------------------+---------------------------


FUNCTION getParcelNoPerTransaction(p_transaction_key VARCHAR2, p_daytime DATE) RETURN VARCHAR2;


FUNCTION GetQtyPrice(p_contract_id                  VARCHAR2,
                     p_line_item_id                 VARCHAR2,
                     p_line_item_template_object_id VARCHAR2,
                     p_transaction_key              VARCHAR2,
                     p_daytime                      DATE,
                     p_line_item_based_type         VARCHAR2 DEFAULT 'QTY',
                     p_price_object_id              VARCHAR2 DEFAULT NULL,
                     p_price_element_code           VARCHAR2 DEFAULT NULL,
                     p_silent                       VARCHAR2 DEFAULT 'N' -- Y/N
                     ) RETURN NUMBER;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Inserts a new transaction.
-- p_vat_code: only used when vat is undefined and not interfaced in
-- p_ppa_trans_ind: indicates if this is a ppa transaction, and should allow updates from preceding transaction
-- p_li_based_type_filter: a collection of line base types indicating which line item to create.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION InsNewTransaction(
                         p_object_id                        VARCHAR2
                        ,p_daytime                          DATE
                        ,p_document_id                      VARCHAR2
                        ,p_document_type                    VARCHAR2
                        ,p_trans_template_id                VARCHAR2
                        ,p_user                             VARCHAR2
                        ,p_trans_id                         VARCHAR2 DEFAULT NULL
                        ,p_preceding_trans_key              VARCHAR2 DEFAULT NULL
                        ,p_ifac_unique_key_1                VARCHAR2 DEFAULT NULL
                        ,p_ifac_unique_key_2                VARCHAR2 DEFAULT NULL
                        ,p_supply_from_date                 DATE DEFAULT NULL
                        ,p_supply_to_date                   DATE DEFAULT NULL
                        ,p_delivery_point_id                VARCHAR2 DEFAULT NULL
                        ,p_insert_line_items_ind            VARCHAR2 DEFAULT 'Y'
                        ,p_vat_code                         VARCHAR2 DEFAULT NULL
                        ,p_ppa_trans_ind                    VARCHAR2 DEFAULT NULL
                        ,p_ifac_price_object_id             VARCHAR2 DEFAULT NULL
                        ,p_insert_qty_line_items_only       VARCHAR2 DEFAULT 'N'
                        ,p_sales_order                      VARCHAR2 DEFAULT NULL
                     )
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------


FUNCTION ReverseTransaction
(   p_object_id VARCHAR2,
    p_daytime DATE,
    p_document_id VARCHAR2, -- the new document
    p_transaction_id VARCHAR2, -- the transaction to reverse
    p_user VARCHAR2,
    p_name_prefix VARCHAR2 DEFAULT 'Reversal of: ',
    p_force_reversal VARCHAR2 DEFAULT 'N'
) RETURN VARCHAR2; -- returns the transaction_id of the reversal

/*FUNCTION  GetConstrainedConvFactors (
    p_object_id VARCHAR2,
    p_transaction_id VARCHAR2,
    p_daytime DATE
    )
RETURN t_constrained_factor_table;*/

FUNCTION IsAllUOMPresent(
   p_object_id VARCHAR2,
   p_doc_id    VARCHAR2
)
RETURN BOOLEAN;

PROCEDURE ValidateTransactions (
    p_document_key VARCHAR2,
    p_val_msg  OUT VARCHAR2,
    p_val_code OUT VARCHAR2,
    p_silent_ind   VARCHAR2
);

PROCEDURE ValidateDocQtyValue (
    p_object_id VARCHAR2,
    p_document_id VARCHAR2
);

PROCEDURE ValidateNumberOfQtyLI(
          p_trans_tmpl_id VARCHAR2,
          p_daytime DATE
          );

PROCEDURE UpdTransQtyInVO
 (p_object_id VARCHAR2,
  p_doc_id VARCHAR2,
  p_user VARCHAR2,
  p_document_type VARCHAR2,
  p_reverse_factor NUMBER DEFAULT 1, -- multiply qty with this factor
  p_document_status             VARCHAR2 DEFAULT NULL,
  p_is_cascade_scheduled        VARCHAR2 DEFAULT 'N'
  );

PROCEDURE UpdFromTransactionGeneral
 (p_object_id VARCHAR2,
  p_doc_id VARCHAR2,
  p_trans_id VARCHAR2,
  p_daytime DATE,
  p_user VARCHAR2
);

PROCEDURE UpdTransSourceSplitShare
 (p_transaction_key VARCHAR2,
  p_qty NUMBER,
  p_uom VARCHAR2,
  p_daytime DATE
  );

PROCEDURE ValidateUOMs (
    p_object_id             VARCHAR2,
    p_transaction_id        VARCHAR2,
    p_daytime               DATE    -- Point of sale date (transaction_date)
);

FUNCTION DelTransaction(
   p_transaction_key VARCHAR2,
   p_child_only VARCHAR2 DEFAULT 'N'
) RETURN VARCHAR2;

PROCEDURE DelEmptyTransactions (
   p_document_key VARCHAR2);

FUNCTION DelEmptyTransaction (
   p_transaction_key VARCHAR2
   ) RETURN BOOLEAN;

PROCEDURE DelNewTransactions(
   p_document_key VARCHAR2
   );

FUNCTION UpdTransExRate(
   p_transaction_key VARCHAR2,
   p_user VARCHAR2,
   p_pick_ex_rates_from_trans VARCHAR2 DEFAULT 'N'
   )RETURN VARCHAR2;

FUNCTION UpdTransAllExRate(
  p_doc_key VARCHAR2,
  p_user VARCHAR2,
  p_pick_ex_rates_from_trans VARCHAR2 DEFAULT 'N'
  ) RETURN VARCHAR2;

FUNCTION UpdSelectedTransExRate(
  p_transaction_key VARCHAR2,
  p_curr_from_to VARCHAR2,
  p_user VARCHAR2,
  p_pick_ex_rates_from_trans VARCHAR2 DEFAULT 'N'
  ) RETURN VARCHAR2;

FUNCTION CopyTransExRate(
  p_transaction_key VARCHAR2,
  p_user VARCHAR2
  )RETURN VARCHAR2;

FUNCTION CopyRateOtherTrans (
    p_transaction_key VARCHAR2,
    p_curr_from_to VARCHAR2,
    p_user VARCHAR2
    )
   RETURN VARCHAR2;


PROCEDURE UpdFromPrecedingTrans(p_preceding_trans_id VARCHAR2,
                                p_target_trans_id    VARCHAR2,
                                p_user               VARCHAR2);

PROCEDURE UpdFromPrecedingTransFinal(p_preceding_trans_id VARCHAR2,
                                     p_target_trans_id    VARCHAR2,
                                     p_user               VARCHAR2);

-- This procedure is run from button in Transaction Values panel.
/*PROCEDURE UpdDocPrice (
    p_object_id VARCHAR2,
    p_transaction_id VARCHAR2,
    p_daytime DATE,
    p_user VARCHAR2,
    p_line_item_based_type VARCHAR2 default NULL
);

-- This procedure is run from button in Transaction Rec Values panel.
PROCEDURE UpdDocPriceAll (
    p_object_id VARCHAR2,
    p_document_id VARCHAR2,
    p_user VARCHAR2,
    p_line_item_based_type VARCHAR2 default NULL
);
*/

FUNCTION IsTransRateEditable (
    p_object_id VARCHAR2,
    p_document_id VARCHAR2,
    p_transaction_key VARCHAR2,
    p_type VARCHAR2 -- 'BOOKING' or 'MEMO' are valid choices
    )
RETURN VARCHAR2;

FUNCTION IsTransactionEmpty(
             p_transaction_key VARCHAR2
) RETURN BOOLEAN;

PROCEDURE InsNewAllocSplit(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_target_source_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY'
);

FUNCTION InsNewAllocSplit(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_target_source_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY'
)
RETURN VARCHAR2;

PROCEDURE InsTransTemplSplitKey(p_object_id VARCHAR2, -- TT object_id
                                p_daytime DATE,
                                p_user VARCHAR2)
;

PROCEDURE UpdTransTemplSplitKey(p_object_id VARCHAR2, -- TT object_id
                                p_daytime DATE,
                                p_user VARCHAR2)
;


PROCEDURE CopyFieldSplit (
    p_user_id               VARCHAR2,
    p_split_key_object_id   VARCHAR2,
    p_daytime               DATE
);

PROCEDURE PasteFieldSplit (
    p_user_id                 VARCHAR2,
    p_trans_templ_object_id   VARCHAR2,
    p_daytime               DATE
);

PROCEDURE InitSplitKeyVerForAllTTVer(p_user_id VARCHAR2, p_trans_templ_object_id VARCHAR2);

FUNCTION GenTransTemplateCopy
 (p_trans_temp_id           VARCHAR2, -- Copy from
  p_contract_doc_id         VARCHAR2,
  p_contract_id             VARCHAR2,
  p_code                    VARCHAR2,
  p_name                    VARCHAR2,
  p_user                    VARCHAR2,
  p_copy_doc_setup_ind      VARCHAR2,
  p_start_date              DATE default NULL,
  p_end_date                DATE default NULL
  )
RETURN VARCHAR2;


PROCEDURE InsNewCarrier(p_transaction_key VARCHAR2,
                        p_user_id         VARCHAR2,
                        p_daytime         DATE,
                        p_carrier         VARCHAR2);

PROCEDURE InsNewDeliveryPoint(p_transaction_key VARCHAR2,
                              p_user_id         VARCHAR2,
                              p_daytime         DATE,
                              p_delivery_point  VARCHAR2,
                              p_destination_country_id VARCHAR2 DEFAULT NULL,
                              p_origin_country_id VARCHAR2 DEFAULT NULL);

PROCEDURE InsNewPort(p_transaction_key VARCHAR2,
                    p_user_id        VARCHAR2,
                    p_daytime        DATE,
                    p_port           VARCHAR2,
                    p_type           VARCHAR2, -- L for loading, D for discharge
                    p_destination_country_id VARCHAR2 DEFAULT NULL,
                    p_origin_country_id VARCHAR2 DEFAULT NULL);

PROCEDURE InsNewDeliveryPlant(p_transaction_key VARCHAR2,
                              p_user_id         VARCHAR2,
                              p_daytime         DATE,
                              p_delivery_plant  VARCHAR2);

PROCEDURE InsNewEntryPoint(p_transaction_key VARCHAR2,
                              p_user_id         VARCHAR2,
                              p_daytime         DATE,
                              p_entry_point  VARCHAR2);

FUNCTION GetReversalTransaction(p_transaction_key VARCHAR2) RETURN VARCHAR2;
FUNCTION GetDestinationCountryId(p_document_key VARCHAR2) RETURN VARCHAR2;

FUNCTION GetOriginCountryForTrans(
            p_trans_tmpl_obj_id     VARCHAR2,
            p_transaction_key       VARCHAR2,
            p_transaction_scope     VARCHAR2 DEFAULT NULL,
            p_delivery_point_id     VARCHAR2 DEFAULT NULL,
            p_loading_port_id       VARCHAR2 DEFAULT NULL,
            p_daytime               DATE DEFAULT NULL) RETURN VARCHAR2;


FUNCTION GetDestinationCountryForTrans(
            p_trans_tmpl_obj_id     VARCHAR2,
            p_transaction_key       VARCHAR2,
            p_transaction_scope     VARCHAR2 DEFAULT NULL,
            p_delivery_point_id     VARCHAR2 DEFAULT NULL,
            p_discharge_port_id     VARCHAR2 DEFAULT NULL,
            p_daytime               DATE DEFAULT NULL) RETURN VARCHAR2;


PROCEDURE SetOriginCountryForTT(
            p_trans_tmpl_obj_id     VARCHAR2,
            p_transaction_scope     VARCHAR2 DEFAULT NULL,
            p_delivery_point_id     VARCHAR2 DEFAULT NULL,
            p_loading_port_id       VARCHAR2 DEFAULT NULL,
            p_daytime               DATE);

PROCEDURE SetDestinationCountryForTT(
            p_trans_tmpl_obj_id     VARCHAR2,
            p_transaction_scope     VARCHAR2 DEFAULT NULL,
            p_delivery_point_id     VARCHAR2 DEFAULT NULL,
            p_discharge_port_id     VARCHAR2 DEFAULT NULL,
            p_daytime               DATE);


FUNCTION GetCargoList(p_document_key VARCHAR2) RETURN VARCHAR2;

PROCEDURE RefreshDistSplitType(p_split_key_id VARCHAR2, p_old_dist_split_type VARCHAR2, p_new_dist_split_type VARCHAR2);

FUNCTION GetTransactionPeriod(p_document_key VARCHAR2) RETURN VARCHAR2;

FUNCTION GetBLDateList(p_document_key VARCHAR2) RETURN VARCHAR2;

FUNCTION GetSumTransPricingTotal(p_document_key VARCHAR2) RETURN NUMBER;

FUNCTION GetSumTransPricingValue(p_document_key VARCHAR2) RETURN NUMBER;

FUNCTION GetTransLocalVatValue(p_transaction_key VARCHAR2) RETURN NUMBER;

FUNCTION GetTransLocalValue(p_transaction_key VARCHAR2) RETURN NUMBER;

FUNCTION GetTransVatCode(p_transaction_key VARCHAR2, p_trans_template_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

PROCEDURE UpdTransTemplForexSetup(p_contract_doc_id VARCHAR2,
                                  p_daytime DATE,
                                  p_user VARCHAR2,
                                  p_memo_curr_id VARCHAR2,
                                  p_booking_curr_id VARCHAR2);

PROCEDURE triggerIULogic
(p_document_key VARCHAR2,
 p_user VARCHAR2,
 p_status_code VARCHAR2,
 p_transaction_key VARCHAR2 DEFAULT NULL
)
;

PROCEDURE resetLineItemShares(p_transaction_key VARCHAR2);

FUNCTION isTransactionEditable(
        p_transaction_key VARCHAR2,
        p_level VARCHAR2 DEFAULT 'TRANS',   -- Alternatively FIELD or COMPANY
        p_msg_ind VARCHAR2 DEFAULT 'N')     -- When 'Y' => Returns user friendly message instead of 'N' when result is false ('N')
RETURN VARCHAR2;

FUNCTION isTransactionDeletable(
        p_transaction_key VARCHAR2,
        p_level VARCHAR2 DEFAULT 'TRANS',   -- Alternatively FIELD or COMPANY
        p_msg_ind VARCHAR2 DEFAULT 'N')     -- When 'Y' => Returns user friendly message instead of 'N' when result is false ('N')
RETURN VARCHAR2;

PROCEDURE AggregateLineItemValues (
          p_transaction_key VARCHAR2);

PROCEDURE populateOtherTrans (
          p_document_key VARCHAR,
          p_transaction_key VARCHAR2,
          p_user VARCHAR2);

FUNCTION isEmptyTrans(p_transaction_key VARCHAR2)
RETURN VARCHAR2;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- Fills amount and quantities in the specified transaction, including line items in it.
-- This procedure is back-support for existing java code and screen.
--
-- p_daytime: transaction date. This parameter is required because sometimes, the transaction
--   date is not available during the time this procedure is called.
-- p_user: the id of user triggered this action.
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE FillTransaction(
                         p_transaction_key                  VARCHAR2
                        ,p_daytime                          DATE
                        ,p_user                             VARCHAR2
);

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Fills quantities and quantity line item on specified transaction.
-- This procedure should only be called by other FT document related pacakges.
--
-- p_daytime: transaction date. This parameter is required because sometimes, the transaction
--   date is not available during the time this procedure is called.
-- p_user: the id of user triggered this action.
-- p_context: the operation context contains optional data for the procedure.
--
-- Usage: FillDocumentQuantity, fill_transaction
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION fill_qty_line_n_quantity_i(
                         p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
                        ,p_transaction_key                  VARCHAR2
)
RETURN BOOLEAN;
------------------------+-----------------------------------+------------------------------------+---------------------------

PROCEDURE FillTransactionPrice(p_transaction_key VARCHAR2,
                               p_daytime         DATE,
                               p_user            VARCHAR2,
                               p_line_item_based_type VARCHAR2 DEFAULT NULL);

PROCEDURE FillTransactionPriceOli(p_transaction_key      VARCHAR2,
                                  p_daytime              DATE,
                                  p_user                 VARCHAR2,
                                  p_line_item_key        VARCHAR2,
                                  p_line_item_based_type VARCHAR2 DEFAULT NULL,
                                  p_line_item_type       VARCHAR2 DEFAULT NULL,
                                  p_ifac_li_conn_code    VARCHAR2 DEFAULT NULL);


PROCEDURE UpdPercentageLineItem(p_transaction_key VARCHAR2,
                                p_user            VARCHAR2);

FUNCTION IsIfacQtyPrice(p_transaction_key VARCHAR2) RETURN BOOLEAN;

FUNCTION GetIfacQtyPrice(p_transaction_key VARCHAR2) RETURN NUMBER;
FUNCTION GetIfacOliPrice(p_transaction_key      VARCHAR2,
                         p_line_item_based_type VARCHAR2 DEFAULT NULL,
                         p_line_item_type       VARCHAR2 DEFAULT NULL,
                         p_ifac_li_conn_code    VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION isTransSourceSplitShareUpdated(p_transaction_key VARCHAR2)
  RETURN VARCHAR2 ;

PROCEDURE SetPointPortCountry(
   p_object_id VARCHAR2, -- Delivery Point or Discharge Port object
   p_daytime DATE,
   p_class_name VARCHAR2, -- DELIVERY_POINT or PORT
   p_country_id VARCHAR2  -- Country relation to set on the object above
);

PROCEDURE UpdateManualPriceValue(
          p_transaction_key VARCHAR2,
          p_daytime VARCHAR2,
          p_price_value NUMBER);

FUNCTION GetQtyLICount(
         p_transaction_key VARCHAR2
) RETURN NUMBER;

FUNCTION IsReducedConfig(p_contract_id     VARCHAR2 DEFAULT NULL,
                         p_contract_doc_id VARCHAR2 DEFAULT NULL,
                         p_trans_temp_id   VARCHAR2 DEFAULT NULL,
                         p_transaction_key VARCHAR2 DEFAULT NULL,
                         p_daytime         DATE,
                         p_dist_only       BOOLEAN DEFAULT FALSE
) RETURN BOOLEAN;

FUNCTION IsReducedConfig(p_contract_id     VARCHAR2,
                         p_contract_doc_id VARCHAR2,
                         p_trans_temp_id   VARCHAR2,
                         p_daytime         DATE,
                         p_dist_only       BOOLEAN DEFAULT FALSE
) RETURN VARCHAR2;


PROCEDURE UpdPriceObject(p_transaction_key VARCHAR2, p_user_id VARCHAR2)
;

FUNCTION GetNetGrsIndicator(
   p_object_id VARCHAR2,
   p_transaction_id VARCHAR2
)

RETURN VARCHAR2;

FUNCTION isPreceding(p_transaction_key VARCHAR2, p_document_key VARCHAR2 DEFAULT NULL) RETURN BOOLEAN;


FUNCTION getDependentTransaction(p_transaction_key VARCHAR2) RETURN VARCHAR2;


FUNCTION isTransactionInterfaced(p_transaction_key VARCHAR2)
RETURN VARCHAR2;

PROCEDURE ValidateDocVAT (p_document_key VARCHAR2, p_val_msg OUT VARCHAR2, p_val_code OUT VARCHAR2, p_silent_ind VARCHAR2);

FUNCTION GetTransSortOrder(p_transaction CONT_TRANSACTION%ROWTYPE, p_recalculate_sort_order BOOLEAN DEFAULT TRUE)
RETURN NUMBER;

PROCEDURE SetTransSortOrder(p_transaction CONT_TRANSACTION%ROWTYPE, p_recalculate_sort_order BOOLEAN, p_user VARCHAR2);

PROCEDURE SetAllTransSortOrder(p_document_key VARCHAR2);

FUNCTION HasReversedDependentTrans(p_transaction_key VARCHAR2)
RETURN VARCHAR2;

FUNCTION resolveNamePlaceholderValue(
    p_placeholder_name  VARCHAR2,
    p_transaction CONT_TRANSACTION%ROWTYPE
    --p_daytime DATE
) RETURN VARCHAR2;



FUNCTION getTransactionName(
    p_transaction CONT_TRANSACTION%ROWTYPE,
    -- p_daytime DATE,
    p_size_limit NUMBER DEFAULT 240
) RETURN CONT_TRANSACTION.NAME%TYPE;

PROCEDURE SetTransactionName(
    p_transaction CONT_TRANSACTION%ROWTYPE,
    p_user VARCHAR2,
    p_size_limit NUMBER DEFAULT 240);

PROCEDURE InitNewTransactionTmplVersion(
    p_user VARCHAR2,
    p_transaction_tmpl_id VARCHAR2,
    p_daytime DATE);

PROCEDURE DelTranTmplVerSplitKeySetups(p_tt_object_id VARCHAR2, p_daytime VARCHAR2);

PROCEDURE ClearTranTmplVerSourceSplitMtd(p_tt_object_id VARCHAR2, p_daytime VARCHAR2);

PROCEDURE ClearProductDescription(p_tt_object_id VARCHAR2, p_daytime VARCHAR2);


-- Will be used by future JIRAs
/*
PROCEDURE RemoveLITmplFromTTVersion(
    p_user VARCHAR2, p_line_item_id VARCHAR2, p_daytime DATE);

PROCEDURE AlignNewLITmplToTTVersion(
    p_user VARCHAR2, p_line_item_id VARCHAR2, p_applyToAllNewerVersions BOOLEAN DEFAULT FALSE);

*/

PROCEDURE ClearStreamItemInfo(p_transaction_template_id VARCHAR2, p_daytime DATE);
PROCEDURE InsNewReportRef(p_daytime DATE, p_user VARCHAR2 , p_transaction_tmpl_id VARCHAR2,prev_tt_id VARCHAR2, prev_daytime DATE);

FUNCTION GetTransStreamItem(p_transaction_key               VARCHAR2,
                             p_user                         VARCHAR2,
                             p_source_node_id               VARCHAR2 DEFAULT NULL,
                             p_silent_mode_ind              VARCHAR2 DEFAULT 'N',
                             p_message                      IN OUT VARCHAR2,
                             p_trans_tmpl_id                VARCHAR2 DEFAULT NULL,
                             p_daytime                      DATE DEFAULT NULL,
                             p_uom_code                     VARCHAR2 DEFAULT NULL,
                             p_product_id                   VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

PROCEDURE SetTransStreamItem(p_transaction_key VARCHAR2,
                             p_user            VARCHAR2,
                             p_source_node_id  VARCHAR2 DEFAULT NULL,
                             p_uom_code        VARCHAR2 DEFAULT NULL);

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
TYPE T_PARAM_GetDistInfoRC IS RECORD
(
     daytime                          DATE
    ,financial_code                   VARCHAR2(32)
    ,transaction_dist_object_id       VARCHAR2(32)
    ,transaction_dist_type            VARCHAR2(32)
    ,product_id                       VARCHAR2(32)
    ,contract_id                      VARCHAR2(32)
    ,contract_comp                    VARCHAR2(32)
    ,contract_company_code            VARCHAR2(32)
    ,stream_id                        VARCHAR2(32)
    ,split_key_id                     VARCHAR2(32)
    ,uom_code                         VARCHAR2(32)
);
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GenParam_GetDistInfoRC(
                         p_transaction_template_id          VARCHAR2
                        ,p_product_id                       VARCHAR2
                        ,p_stream_id                        VARCHAR2
                        ,p_daytime                          DATE
                        )
RETURN T_PARAM_GetDistInfoRC;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GenParam_GetDistInfoRC(
                         p_cont_transaction                 CONT_TRANSACTION%ROWTYPE
                        ,p_overwrite_uom_code               VARCHAR2
                        )
RETURN T_PARAM_GetDistInfoRC;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetDistInfoRC_ProfitCenter(
                         p_common_param                     T_PARAM_GetDistInfoRC
                        ,p_skip_validation                  BOOLEAN
                        )
RETURN T_TABLE_PC_DIST_INFO;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetDistInfoRC_Company(
                         p_common_param                     T_PARAM_GetDistInfoRC
                        ,p_profit_center_id                 VARCHAR2
                        ,p_skip_validation                  BOOLEAN
                        )
RETURN T_TABLE_COMPANY_DIST_INFO;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetDistObjectID(
                         p_contract_composition             VARCHAR2
                        ,p_dist_object_code                 VARCHAR2
                        ,p_dist_object_type                 VARCHAR2
                        )
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetDistObjectName(p_transaction_key VARCHAR2)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetDistObjectTypeName(
                         p_transaction_key                  VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION FindPrecedingTransKeys(
                         p_document_key                     VARCHAR2
                        ,p_document_concept                 VARCHAR2
                        ,p_stream_item_id                   VARCHAR2
                        ,p_price_concept_code               VARCHAR2
                        ,p_product_id                       VARCHAR2
                        ,p_entry_point_id                   VARCHAR2
                        ,p_transaction_scope                VARCHAR2
                        ,p_transaction_type                 VARCHAR2
                        )
RETURN T_TABLE_MIXED_DATA;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION FindPrecedingTransKeys(
                         p_transaction_key                  VARCHAR2
                        )
RETURN T_TABLE_MIXED_DATA;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

PROCEDURE AutoPopulateDistSplit(p_transaction_template_id VARCHAR2,
                                p_daytime                 DATE);
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE DelTransactionDist(p_transaction_template_id VARCHAR2,
                             p_daytime                 DATE);
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPCInfoRC(    p_dist_code                        VARCHAR2
                        ,p_dist_type                        VARCHAR2
                        ,p_dist_object_type                 VARCHAR2
                        ,p_daytime                          DATE)
RETURN T_TABLE_PROFIT_CENTRE_ID;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPCInfoRC_Vendor(p_contract_id                      VARCHAR2,
                            p_daytime                          DATE         )

RETURN T_TABLE_PC_VENDOR_ID;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
Procedure RoundDistLevel(p_transaction_key VARCHAR2);
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
Procedure DeletePPATransactionTmpl(p_object_id VARCHAR2);
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetLatestnGreatestTran(p_transaction_key                      VARCHAR2)
  RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE updContTransactionConsignee(
          p_document_key VARCHAR2,
          p_user VARCHAR2);

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Fills amount and quantities in the specified transaction, including line items in it.
--
-- p_daytime: transaction date. This parameter is required because sometimes, the transaction
--   date is not available during the time this procedure is called.
-- p_user: the id of user triggered this action.
-- p_context: the operation context contains optional data for the procedure.
------------------------+-----------------------------------+------------------------------------+---------------------------
procedure fill_transaction_i(
                         p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
                        ,p_transaction_key                  VARCHAR2
                        ,p_daytime                          DATE
                        );
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION doc_key_from_trans_templ_id(
         p_trans_temp_id VARCHAR2)
RETURN CONT_TRANSACTION.Document_Key%TYPE;

PROCEDURE updTotPriceNotRounded(p_price_concept_code VARCHAR2,
                                p_contract_id VARCHAR2,
                                p_trans_key VARCHAR2);
FUNCTION TransactionLevelVatCode(p_transaction_key VARCHAR2) RETURN VARCHAR2;


------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------


FUNCTION TransactionLevelVatRate(p_transaction_key VARCHAR2) RETURN NUMBER;


------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetPricingBookingLabel(p_document_key      VARCHAR2,
                                p_daytime           DATE,
                                p_trans_template_id VARCHAR2)
  RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPricingMemoLabel(p_document_key      VARCHAR2,
                             p_daytime           DATE,
                             p_trans_template_id VARCHAR2) RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetBookingLocalLabel(p_document_key VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetBookingGroupLabel(p_document_key VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPricingBookingCode(p_document_key      VARCHAR2,
                               p_daytime           DATE,
                               p_trans_template_id VARCHAR2)
  RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPricingMemoCode(p_document_key      VARCHAR2,
                            p_daytime           DATE,
                            p_trans_template_id VARCHAR2) RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetBookingLocalCode(p_document_key VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetBookingGroupCode(p_document_key VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------

END Ecdp_Transaction;