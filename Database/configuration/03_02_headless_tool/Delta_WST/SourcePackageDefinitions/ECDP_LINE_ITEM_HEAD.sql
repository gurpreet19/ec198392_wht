CREATE OR REPLACE PACKAGE EcDp_Line_Item IS
/****************************************************************
** Package        :  EcDp_Line_Item, header part
**
** $Revision: 1.147 $
**
** Purpose        :  Provide functionality connected to Line Items.
**
** Documentation  :  www.energy-components.com
**
** Created  : 28.04.2006
**
** Modification history:
**
** Version  Date     Whom  Change description:
**
**
*****************************************************************/

    TYPE t_table_li_pc_dist IS TABLE OF cont_line_item_dist%ROWTYPE;
    TYPE t_table_li_company_dist IS TABLE OF cont_li_dist_company%ROWTYPE;
    con_based_type_qty CONSTANT cont_line_item.line_item_based_type%TYPE := 'QTY';

    -----------------------------------------------------------------------
    -- Cursor that returns componding (child) interest line items of a
    -- given interest line item (excluding the main line item).
    ----+----------------------------------+-------------------------------
    CURSOR c_get_componding_interest_li(
        p_interest_group                   VARCHAR2
       ,p_parent_line_item_key             VARCHAR2
    ) IS
        SELECT line_item_key, interest_line_item_key, LEVEL
        FROM cont_line_item
        START WITH interest_line_item_key = p_parent_line_item_key
        CONNECT BY PRIOR line_item_key = interest_line_item_key
        ORDER BY LEVEL DESC;

    -----------------------------------------------------------------------
    -- Gets meta of line items under given transaction.
    ----+----------------------------------+-------------------------------
    CURSOR c_get_li_meta(
        p_transaction_key             cont_transaction.transaction_key%TYPE
    )
    IS
        SELECT li.line_item_key
              ,li.daytime
              ,li.creation_method
              ,li.dist_method
              ,li.line_item_based_type
              ,li.object_id
        FROM cont_line_item li
        WHERE transaction_key = p_transaction_key;

    -----------------------------------------------------------------------
    -- Cursor that queries keys of line items with given distribution
    -- method.
    ----+----------------------------------+-------------------------------
    CURSOR c_keys_of_dist_method(
        p_transaction_key                  cont_line_item.transaction_key%TYPE
       ,p_dist_method                      cont_line_item.dist_method%TYPE
        ) IS
        SELECT line_item_key
        FROM cont_line_item
        WHERE transaction_key = p_transaction_key
            AND dist_method = p_dist_method;

    -----------------------------------------------------------------------
    -- Returns profit center level distribution info on given line item
    ----+----------------------------------+-------------------------------
    CURSOR c_pc_dists(
        cp_transaction_key             cont_transaction.transaction_key%TYPE
       ,cp_line_item_key               cont_line_item.line_item_key%TYPE
       ) IS
        SELECT *
        FROM cont_line_item_dist clid
        WHERE clid.transaction_key = cp_transaction_key
            AND clid.line_item_key = cp_line_item_key;

    -----------------------------------------------------------------------
    -- Returns company level distribution info under a profit center dist
    -- on given line item
    ----+----------------------------------+-------------------------------
    CURSOR c_company_dists(
        cp_transaction_key                VARCHAR2
       ,cp_line_item_key                  VARCHAR2
       ,cp_dist_id                        VARCHAR2
       ) IS
        SELECT *
        FROM cont_li_dist_company clidc
        WHERE clidc.transaction_key = cp_transaction_key
            AND clidc.line_item_key = cp_line_item_key
            AND clidc.dist_id = cp_dist_id;

    -----------------------------------------------------------------------
    -- Returns all quantity line items under given transaction.
    ----+----------------------------------+-------------------------------
    CURSOR c_qty_line_keys(
        p_transaction_key                 VARCHAR2
        ) IS
        SELECT line_item_key
        FROM cont_line_item
        WHERE transaction_key = p_transaction_key
            AND line_item_based_type = con_based_type_qty;

    -----------------------------------------------------------------------
    -- Returns all quantity line items under given transaction.
    ----+----------------------------------+-------------------------------
    CURSOR c_qty_lines(
        p_transaction_key                 VARCHAR2
        ) IS
        SELECT *
        FROM cont_line_item
        WHERE transaction_key = p_transaction_key
            AND line_item_based_type = con_based_type_qty;

    -----------------------------------------------------------------------
    -- Deletes the specified profit center distribution from a line item.
    ----+----------------------------------+-------------------------------
    PROCEDURE del_dist_by_pc_i(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
       ,p_profit_center_id                 cont_line_item_dist.dist_id%TYPE
       );

    -----------------------------------------------------------------------
    -- Deletes distribution from a line item.
    ----+----------------------------------+-------------------------------
    PROCEDURE del_dist_i(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
        );

    -----------------------------------------------------------------------
    -- Updates creation methods on specified line items.
    ----+----------------------------------+-------------------------------
    PROCEDURE upd_creation_method(
        p_line_item_keys                   t_table_varchar2
       ,p_creation_method                  ecdp_revn_ft_constants.T_IFAC_CTYPE
       );

    -----------------------------------------------------------------------
    -- Returns company level distribution info on given line item
    ----+----------------------------------+-------------------------------
    PROCEDURE get_company_dists(
        p_result_collection               IN OUT NOCOPY t_table_li_company_dist
       ,p_transaction_key                 VARCHAR2
       ,p_line_item_key                   VARCHAR2
       ,p_dist_id                         VARCHAR2
       );

    -----------------------------------------------------------------------
    -- Returns profit center level distribution info on given line item
    ----+----------------------------------+-------------------------------
    PROCEDURE get_pc_dists(
        p_result_collection               IN OUT NOCOPY t_table_li_pc_dist
       ,p_transaction_key                 VARCHAR2
       ,p_line_item_key                   VARCHAR2
       );

    -----------------------------------------------------------------------
    -- Sync distribution shares with the quantity line item on the same
    -- transaction.
    ----+----------------------------------+-------------------------------
    PROCEDURE sync_dist_from_qty_i(
        p_transaction_key                  cont_transaction.transaction_key%TYPE
        );

    -----------------------------------------------------------------------
    -- Gets quantity line item key in given transaction.
    --
    -- Note:
    --     Only one quantity line item is allowed per transaction.
    --
    -- Paramters:
    --     p_transaction_key: transaction key.
    ----+----------------------------------+-------------------------------
    FUNCTION get_first_qty_li_key(
        p_transaction_key                  cont_transaction.transaction_key%TYPE
        )
    RETURN cont_line_item.line_item_key%TYPE;

    -----------------------------------------------------------------------
    -- Fill line item values and distributions.
    --
    -- Assumption: correct line_item_key and transaction_key are sat on ifac
    --     before calling this function.
    --
    -- Parameters:
    --
    -- Parameters to modify:
    ----+----------------------------------+-------------------------------
    FUNCTION fill_by_ifac_i(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_line_item_key                    cont_line_item.line_item_key%TYPE
       )
    RETURN BOOLEAN;

    -----------------------------------------------------------------------
    -- Generates values for percentage line item.
    ----+----------------------------------+-------------------------------
    PROCEDURE fill_li_val_perc(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_user                             VARCHAR2
        );


-- Global cursor for line items fields on document
CURSOR gc_transaction_qty_line_item(cp_transaction_key VARCHAR2) IS
SELECT *
      FROM cont_line_item_dist fd
     WHERE fd.line_item_based_type = 'QTY'
       AND fd.transaction_key = cp_transaction_key;

-- Global cursor for line items field/companies on document
CURSOR gc_transaction_qty_li_dist(cp_transaction_key VARCHAR2) IS
SELECT *
      FROM cont_li_dist_company fd
     WHERE fd.line_item_based_type = 'QTY'
       AND fd.transaction_key = cp_transaction_key;

-- Global cursor in use by genDist and by staging preprocess
CURSOR gc_split_key_setup(cp_split_key_id objects.object_id%TYPE,cp_daytime DATE) IS
SELECT split_member_id id, source_member_id, comments_mth
      FROM split_key_setup
     WHERE object_id = cp_split_key_id
       AND cp_daytime >= Nvl(daytime, cp_daytime)
       AND cp_daytime < Nvl(ec_split_key_version.next_daytime(object_id, daytime, 1), cp_daytime + 1);

-- Global cursor in use by genDist and by staging preprocess
CURSOR gc_split_key_setup_company(cp_split_key_id VARCHAR2, cp_contract_id VARCHAR2, cp_customer_id VARCHAR2, cp_fin_code VARCHAR2, cp_daytime DATE) IS
SELECT sks.split_member_id,
           vendor.company_id vendor_id,
           nvl(cp_customer_id, customer.company_id) customer_id,
           nvl(sks.split_share_mth, vendor.party_share / 100) vendor_share,
           customer.party_share / 100 customer_share,
           sks.comments_mth
  FROM split_key_setup sks, contract_party_share vendor, contract_party_share customer
     WHERE sks.object_id = cp_split_key_id
       AND cp_daytime >= sks.daytime
   AND cp_daytime < Nvl(ec_split_key_version.next_daytime(sks.object_id, sks.daytime, 1), cp_daytime + 1)
       AND vendor.object_id = cp_contract_id
       AND customer.object_id = cp_contract_id
       AND ec_company.company_id(vendor.company_id) =
       (ec_stream_item_version.company_id(sks.split_member_id, cp_daytime, '<='))
       AND cp_fin_code IN ('SALE', 'TA_INCOME', 'JOU_ENT')
       AND vendor.party_role = 'VENDOR'
       AND customer.party_role = 'CUSTOMER'
       AND customer.daytime <= cp_daytime
       AND nvl(customer.end_date, cp_daytime + 1) > cp_daytime
       AND vendor.daytime <= cp_daytime
       AND nvl(vendor.end_date, cp_daytime + 1) > cp_daytime
UNION
-- If using costomer only want to use vendor company share as split key share is 100%
SELECT sks.split_member_id,
           vendor.company_id vendor_id,
           nvl(cp_customer_id, customer.company_id) customer_id,
           vendor.party_share / 100 vendor_share,
           customer.party_share / 100 customer_share,
           sks.comments_mth
  FROM split_key_setup sks, contract_party_share vendor, contract_party_share customer
     WHERE sks.object_id = cp_split_key_id
       AND cp_daytime >= sks.daytime
   AND cp_daytime < Nvl(ec_split_key_version.next_daytime(sks.object_id, sks.daytime, 1), cp_daytime + 1)
       AND vendor.object_id = cp_contract_id
       AND customer.object_id = cp_contract_id
       AND
           (ec_company.company_id(customer.company_id) =
           (ec_stream_item_version.company_id(sks.split_member_id,
                                                cp_daytime,
                                                '<=')))
       AND cp_fin_code IN ('PURCHASE', 'TA_COST')
       AND vendor.party_role = 'VENDOR'
       AND customer.party_role = 'CUSTOMER'
       AND customer.daytime <= cp_daytime
       AND nvl(customer.end_date, cp_daytime + 1) > cp_daytime
       AND vendor.daytime <= cp_daytime
       AND nvl(vendor.end_date, cp_daytime + 1) > cp_daytime

UNION
-- If using vendor split want to first try the split key share if not use the company split
SELECT sks.split_member_id,
           vendor.company_id vendor_id,
           nvl(cp_customer_id, customer.company_id) customer_id,
           nvl(sks.split_share_mth, vendor.party_share / 100) vendor_share,
           customer.party_share / 100 customer_share,
           sks.comments_mth
  FROM split_key_setup sks, contract_party_share vendor, contract_party_share customer
     WHERE sks.object_id = cp_split_key_id
       AND cp_daytime >= sks.daytime
   AND cp_daytime < Nvl(ec_split_key_version.next_daytime(sks.object_id, sks.daytime, 1), cp_daytime + 1)
       AND vendor.object_id = cp_contract_id
       AND customer.object_id = cp_contract_id
       AND (ec_company.company_id(vendor.company_id) =
           (ec_stream_item_version.company_id(sks.split_member_id,
                                               cp_daytime,
                                               '<=')) )
       AND cp_fin_code IN ('PURCHASE', 'TA_COST')
       AND vendor.party_role = 'VENDOR'
       AND customer.party_role = 'CUSTOMER'
       AND customer.daytime <= cp_daytime
       AND nvl(customer.end_date, cp_daytime + 1) > cp_daytime
       AND vendor.daytime <= cp_daytime
       AND nvl(vendor.end_date, cp_daytime + 1) > cp_daytime
UNION
SELECT sks.split_member_id,
           vendor.company_id vendor_id,
          nvl(cp_customer_id, customer.company_id) customer_id,
           nvl(sks.split_share_mth, vendor.party_share / 100) vendor_share,
           customer.party_share / 100 customer_share,
           sks.comments_mth
  FROM split_key_setup sks, contract_party_share vendor, contract_party_share customer
  WHERE sks.object_id =cp_split_key_id
       AND cp_daytime >= sks.daytime
       AND cp_daytime < Nvl(ec_split_key_version.next_daytime(sks.object_id, sks.daytime, 1), cp_daytime + 1)
       AND vendor.object_id =cp_contract_id
       AND customer.object_id =cp_contract_id
       AND cp_fin_code IN ('SALE', 'TA_INCOME', 'JOU_ENT')
       AND vendor.party_role = 'VENDOR'
       AND customer.party_role = 'CUSTOMER'
       AND vendor.company_id=sks.split_member_id
       AND customer.daytime <= cp_daytime
       AND nvl(customer.end_date, cp_daytime + 1) > cp_daytime
       AND vendor.daytime <= cp_daytime
       AND nvl(vendor.end_date, cp_daytime + 1) > cp_daytime
UNION
SELECT sks.split_member_id,
           vendor.company_id vendor_id,
           nvl(cp_customer_id, customer.company_id) customer_id,
           nvl(sks.split_share_mth, vendor.party_share/ 100)  vendor_share,
           customer.party_share / 100 customer_share,
           sks.comments_mth
  FROM split_key_setup sks, contract_party_share vendor, contract_party_share customer
  WHERE sks.object_id = cp_split_key_id
       AND cp_daytime >= sks.daytime
       AND cp_daytime < Nvl(ec_split_key_version.next_daytime(sks.object_id, sks.daytime, 1), cp_daytime + 1)
       AND vendor.object_id = cp_contract_id
       AND customer.object_id = cp_contract_id
       AND cp_fin_code IN ('PURCHASE', 'TA_COST')
       AND vendor.party_role = 'VENDOR'
       AND customer.party_role = 'CUSTOMER'
       AND vendor.company_id=sks.split_member_id
       AND customer.daytime <= cp_daytime
       AND nvl(customer.end_date, cp_daytime + 1) > cp_daytime
       AND vendor.daytime <= cp_daytime
       AND nvl(vendor.end_date, cp_daytime + 1) > cp_daytime
       ;


CURSOR gc_li_by_doc_setup (cp_contract_doc_id VARCHAR2, cp_line_item_based_type VARCHAR2, cp_line_item_type VARCHAR2, cp_daytime DATE) IS
SELECT l.object_id
      FROM line_item_template l, line_item_tmpl_version lv
     WHERE l.transaction_template_id IN
       (SELECT t.object_id FROM transaction_template t WHERE t.contract_doc_id = cp_contract_doc_id)
       AND lv.line_item_based_type = cp_line_item_based_type
   AND lv.line_item_type = nvl(cp_line_item_type,lv.line_item_type)
       AND l.object_id = lv.object_id
       AND lv.daytime <= cp_daytime
       AND nvl(lv.end_date, cp_daytime + 1) > cp_daytime;

CURSOR gc_li_by_tt (cp_trans_templ_id VARCHAR2, cp_line_item_based_type VARCHAR2, cp_line_item_type VARCHAR2, cp_daytime DATE) IS
SELECT l.object_id
        FROM line_item_template l, line_item_tmpl_version lv
       WHERE l.transaction_template_id = cp_trans_templ_id
         AND lv.line_item_based_type = cp_line_item_based_type
   AND lv.line_item_type = nvl(cp_line_item_type,lv.line_item_type)
         AND l.object_id = lv.object_id
         AND lv.daytime <= cp_daytime
         AND nvl(lv.end_date, cp_daytime + 1) > cp_daytime;

FUNCTION CopyLineItem
(  p_object_id VARCHAR2,
   p_line_item_id VARCHAR2,
   p_daytime DATE,
   p_target_transaction_id VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE DelLineItem(
        p_object_id VARCHAR2,
        p_line_item_id VARCHAR2
);

FUNCTION InsNewLineItem(p_object_id             VARCHAR2,
                        p_daytime               DATE,
                        p_document_id           VARCHAR2,
                        p_transaction_key       VARCHAR2,
                        p_li_template_id        VARCHAR2,
                        p_user                  VARCHAR2,
                        p_line_item_id          VARCHAR2 DEFAULT NULL,
                        p_line_item_type        VARCHAR2 DEFAULT NULL,
                        p_line_item_based_type  VARCHAR2 DEFAULT NULL,
                        p_pct_base_amount       NUMBER DEFAULT NULL,
                        p_percentage_value      NUMBER DEFAULT NULL,
                        p_unit_price            NUMBER DEFAULT NULL,
                        p_unit_price_unit       VARCHAR2 DEFAULT NULL,
                        p_free_unit_qty         NUMBER DEFAULT NULL,
                        p_pricing_value         NUMBER DEFAULT NULL,
                        p_description           VARCHAR2 DEFAULT NULL,
                        p_price_object_id       VARCHAR2 DEFAULT NULL,
                        p_price_element_code    VARCHAR2 DEFAULT NULL,
                        p_customer_id           VARCHAR2 DEFAULT NULL,
                        p_insert_dist_ind       VARCHAR2 DEFAULT 'Y',
                        p_sort_order            NUMBER DEFAULT NULL,
                        p_creation_method       ecdp_revn_ft_constants.t_c_mtd DEFAULT ecdp_revn_ft_constants.c_mtd_manual,
                        p_ifac_li_conn_code     cont_line_item.ifac_li_conn_code%TYPE DEFAULT NULL,
                        p_li_unique_key_1       VARCHAR2 DEFAULT NULL,
                        p_li_unique_key_2       VARCHAR2 DEFAULT NULL
                        )
RETURN VARCHAR2;

FUNCTION InsNewLineItemFromApp(p_object_id            VARCHAR2,
                               p_daytime              DATE,
                               p_document_id          VARCHAR2,
                               p_transaction_id       VARCHAR2,
                               p_li_template_id       VARCHAR2,
                               p_user                 VARCHAR2,
                               p_line_item_id         VARCHAR2 DEFAULT NULL, -- this is to load existing data
                               p_line_item_type       VARCHAR2 DEFAULT NULL,
                               p_line_item_based_type VARCHAR2 DEFAULT NULL,
                               p_pct_base_amount      NUMBER DEFAULT NULL,
                               p_percentage_value     NUMBER DEFAULT NULL,
                               p_unit_price           NUMBER DEFAULT NULL,
                               p_unit_price_unit      VARCHAR2 DEFAULT NULL,
                               p_free_unit_qty        NUMBER DEFAULT NULL,
                               p_pricing_value        NUMBER DEFAULT NULL,
                               p_description          VARCHAR2 DEFAULT NULL,
                               p_price_object_id      VARCHAR2 DEFAULT NULL,
                               p_sort_order           NUMBER DEFAULT NULL)
  RETURN VARCHAR2;

/*PROCEDURE GenLIForTransaction(p_contract_id VARCHAR2,
                              p_transaction_key  VARCHAR2,
                              p_document_status  VARCHAR2,
                              p_user  VARCHAR2) ;*/

    FUNCTION GenInterestLineItemSet_I (
        p_object_id                        VARCHAR2,
        p_transaction_key                  VARCHAR2,
        p_line_item_key      VARCHAR2,
        p_interest_from_date DATE,
        p_interest_to_date   DATE,
        p_base_amt           NUMBER, -- in pricing currency
        p_base_rate          NUMBER,
        p_interest_type      VARCHAR2,
        p_name               VARCHAR2,
        p_rate_offset        NUMBER,
        p_compounding_period NUMBER,
        p_interest_group     VARCHAR2,
        p_number_of_days     NUMBER,
        p_user               VARCHAR2,
        p_line_item_type     VARCHAR2 DEFAULT NULL,
        p_comment            VARCHAR2 DEFAULT NULL,
        p_sort_order         NUMBER DEFAULT NULL,
        p_creation_method    ecdp_revn_ft_constants.t_c_mtd DEFAULT ecdp_revn_ft_constants.c_mtd_manual
    )
    RETURN cont_line_item.interest_group%TYPE;


    PROCEDURE GenInterestLineItemSetFromApp (
        p_object_id          VARCHAR2,
        p_transaction_key    VARCHAR2,
        p_line_item_key      VARCHAR2,
        p_interest_from_date DATE,
        p_interest_to_date   DATE,
        p_base_amt           NUMBER, -- in pricing currency
        p_base_rate          NUMBER,
        p_interest_type      VARCHAR2,
        p_name               VARCHAR2,
        p_rate_offset        NUMBER,
        p_compounding_period NUMBER,
        p_interest_group     VARCHAR2,
        p_number_of_days     NUMBER,
        p_user               VARCHAR2,
        p_line_item_type     VARCHAR2 DEFAULT NULL,
        p_comment            VARCHAR2 DEFAULT NULL,
        p_sort_order         NUMBER DEFAULT NULL
    );

PROCEDURE UpdIntBaseAmount (
    p_object_id VARCHAR2,
    p_document_id VARCHAR2,
    p_first_preceeding_doc VARCHAR2,
    p_base_rate NUMBER DEFAULT NULL
    );

PROCEDURE DelAllLineItemTemplates(
   p_trans_object_id VARCHAR2 -- TransactionTemplate Object_id
   );

PROCEDURE DelLineItemTemplate(
   p_line_item_id    VARCHAR2 -- Line Item Object ID
   );



PROCEDURE GenLItemplateFromTransTempl(p_object_id         VARCHAR2,
                                      p_line_item_code    VARCHAR2,
                                      p_sort_order        VARCHAR2,
                                      p_trans_templ_id    VARCHAR2,
                                      p_stim_val_cat_code VARCHAR2,
                                      p_vat_code          VARCHAR2,
                                      p_daytime           DATE,
                                      p_user              VARCHAR2 DEFAULT NULL);

PROCEDURE updLITName
( p_object_id         VARCHAR2,
  p_daytime           DATE,
  p_user              VARCHAR2 DEFAULT NULL
);


PROCEDURE InsNewLITemplateFromApp
( p_trans_templ_id VARCHAR2,
  p_line_item_code VARCHAR2,
  p_sort_order     NUMBER,
  p_li_based_type  VARCHAR2,
  p_li_type        VARCHAR2,
  p_name           VARCHAR2,
  p_pct_value      NUMBER,
  p_li_value       NUMBER,
  p_unit_prc       NUMBER,
  p_unit_prc_unit  VARCHAR2,
  p_vat_code       VARCHAR2,
  p_daytime        DATE,   -- Versioning will be aligned with the transaction template
  p_user           VARCHAR2 DEFAULT NULL,
  p_calculation_id VARCHAR2 DEFAULT NULL,
  p_price_object_id VARCHAR2 DEFAULT NULL,
  p_ifac_li_conn_code VARCHAR2 DEFAULT NULL
);



PROCEDURE UpdLineItemTemplateFromApp(p_li_templ_id             VARCHAR2,
                              p_sort_order              NUMBER,
                              p_li_based_type           VARCHAR2,
                              p_li_type                 VARCHAR2,
                              p_name                    VARCHAR2,
                              p_pct_value               NUMBER,
                              p_li_value                NUMBER,
                              p_unit_prc                NUMBER,
                              p_unit_prc_unit           VARCHAR2,
                              p_vat_code                VARCHAR2,
                              p_daytime                 DATE,
                              p_user                    VARCHAR2 DEFAULT NULL,
                              p_calculation_id          VARCHAR2 DEFAULT NULL,
                              p_price_object_id         VARCHAR2 DEFAULT NULL,
                              p_line_item_template_code VARCHAR2 DEFAULT NULL,
                              p_ifac_li_conn_code       VARCHAR2 DEFAULT NULL);

FUNCTION GenLITemplateCopy
( p_LI_id                   VARCHAR2, -- Copy from
  p_trans_templ_id          VARCHAR2,
  p_code                    VARCHAR2,
  p_name                    VARCHAR2,
  p_user                    VARCHAR2,
  p_start_date            DATE default NULL,
  P_end_date              DATE default NULL,
  p_skip_cont_setup       VARCHAR2 DEFAULT 'N'
)
RETURN VARCHAR2;

PROCEDURE InsNewLITemplateForTT(
                               p_trans_templ_id VARCHAR2,
                               p_line_item_id   VARCHAR2,
                               p_prev_daytime   DATE,
                               p_daytime        DATE,   -- Versioning will be aligned with the transaction template
                               p_end_date       DATE,
                               p_name           VARCHAR2,
                               p_user           VARCHAR2
);


FUNCTION GetLatestCompound(p_line_item_key VARCHAR2)
RETURN NUMBER;

FUNCTION GetLineItemLocalValue(p_line_item_key VARCHAR2)
RETURN NUMBER;


PROCEDURE DelLineItemChildRecords(p_line_item_id VARCHAR2,
                                  p_dist_id      VARCHAR2);

PROCEDURE ValidateCalcQtyValueLI(p_transaction_template_id VARCHAR2,
                                 p_li_based_type           VARCHAR2,
                                 p_daytime                 DATE);

FUNCTION ValidateLineItemTemplate(p_transaction_template_id VARCHAR2,
                                  p_daytime                 DATE,
                                  p_type                    VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetInterestBaseRate (
         p_daytime DATE,
         p_frequency VARCHAR2,
         p_unit VARCHAR2,
         p_rate_type_code VARCHAR2
         )
RETURN NUMBER;

PROCEDURE UpdateLineItemShares
(  p_transaction_key VARCHAR2,
   p_preceeding_transaction_key VARCHAR2
);

FUNCTION getFieldQty2Share(p_line_item_key VARCHAR2,
                           p_stream_item VARCHAR2,
                           p_dist_id VARCHAR2)
RETURN NUMBER;

FUNCTION getFieldQty3Share(p_line_item_key VARCHAR2,
                           p_stream_item VARCHAR2,
                           p_dist_id VARCHAR2)
RETURN NUMBER;

FUNCTION getFieldQty4Share(p_line_item_key VARCHAR2,
                           p_stream_item VARCHAR2,
                           p_dist_id VARCHAR2)
RETURN NUMBER;

FUNCTION getFieldCompanyQty2Share(p_line_item_key VARCHAR2,
                                  p_stream_item   VARCHAR2,
                                  p_dist_id       VARCHAR2,
                                  p_vendor_id     VARCHAR2,
                                  p_customer_id   VARCHAR2) RETURN NUMBER;

FUNCTION getFieldCompanyQty3Share(p_line_item_key VARCHAR2,
                                  p_stream_item   VARCHAR2,
                                  p_dist_id       VARCHAR2,
                                  p_vendor_id     VARCHAR2,
                                  p_customer_id   VARCHAR2) RETURN NUMBER;

FUNCTION getFieldCompanyQty4Share(p_line_item_key VARCHAR2,
                                  p_stream_item   VARCHAR2,
                                  p_dist_id       VARCHAR2,
                                  p_vendor_id     VARCHAR2,
                                  p_customer_id   VARCHAR2) RETURN NUMBER;

PROCEDURE DelEmptyLineItems(
        p_transaction_key VARCHAR2);


FUNCTION IsLineItemEmpty(
               p_line_item_key VARCHAR2
)
RETURN BOOLEAN;

PROCEDURE gen_dist_party_f_conf_field(p_line_item_key VARCHAR2,
                               p_customer_id   VARCHAR2,
                               p_user          VARCHAR2,
                               p_uom_code      VARCHAR2 DEFAULT NULL);

PROCEDURE gen_dist_party_f_conf_pc(p_line_item_key VARCHAR2,
                               p_customer_id   VARCHAR2,
                               p_user          VARCHAR2,
                               p_uom_code      VARCHAR2 DEFAULT NULL);

PROCEDURE gen_dist_party_f_given(p_line_item_key VARCHAR2,
                               p_customer_id       VARCHAR2,
                               p_user              VARCHAR2,
                               p_uom_code          VARCHAR2 DEFAULT NULL,
                               p_profit_centre_id  VARCHAR2,
                               p_daytime           DATE);

PROCEDURE InsPPATransIntLineItem(p_document_key varchar2,
                                 p_user VARCHAR2,
                                 p_transaction_key VARCHAR2 DEFAULT NULL);

FUNCTION getPPAIntBaseAmount(lrec_trans cont_transaction%ROWTYPE,
                           p_from_date       IN OUT DATE) RETURN NUMBER;


FUNCTION split_share_rebalance(p_qty_no         NUMBER,
                               p_line_item_key  VARCHAR2,
                               p_dist_id        VARCHAR2,
                               p_share_value    NUMBER,
                               p_vendor_id      VARCHAR2 DEFAULT NULL,
                               p_stream_item_id VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

PROCEDURE RoundDistLevel(
               p_line_item_key              VARCHAR2
               ,p_qty1                      NUMBER
               ,p_qty2                      NUMBER
               ,p_qty3                      NUMBER
               ,p_qty4                      NUMBER
               ,p_NON_ADJUSTED_VALUE        NUMBER
               ,p_PRICING_VALUE             NUMBER
               ,p_PRICING_VAT_VALUE         NUMBER
               ,p_MEMO_VALUE                NUMBER
               ,p_MEMO_VAT_VALUE            NUMBER
               ,p_BOOKING_VALUE             NUMBER
               ,p_BOOKING_VAT_VALUE         NUMBER
               ,p_LOCAL_VALUE               NUMBER
               ,p_LOCAL_VAT_VALUE           NUMBER
               ,p_GROUP_VALUE               NUMBER
               ,p_GROUP_VAT_VALUE           NUMBER
               ,p_precision                 NUMBER
               ,p_vat_precision             NUMBER
);

PROCEDURE RoundDistLevel(p_line_item_key              VARCHAR2 );

FUNCTION HasNonQtyLineItemTmpl
   (
       p_tt_object_id VARCHAR2,
       p_daytime date
   )
   return ecdp_revn_common.T_BOOLEAN_STR;

PROCEDURE InsNewLITemplate
( p_trans_templ_id VARCHAR2,
  p_line_item_code VARCHAR2,
  p_sort_order     NUMBER,
  p_li_based_type  VARCHAR2,
  p_li_type        VARCHAR2,
  p_name           VARCHAR2,
  p_pct_value      NUMBER,
  p_li_value       NUMBER,
  p_unit_prc       NUMBER,
  p_unit_prc_unit  VARCHAR2,
  p_vat_code       VARCHAR2,
  p_daytime        DATE,
  p_user           VARCHAR2 DEFAULT NULL,
  p_calculation_id VARCHAR2 DEFAULT NULL,
  p_price_object_id VARCHAR2 DEFAULT NULL
);



PROCEDURE UpdLineItemTemplate(p_li_templ_id             VARCHAR2,
                              p_sort_order              NUMBER,
                              p_li_based_type           VARCHAR2,
                              p_li_type                 VARCHAR2,
                              p_name                    VARCHAR2,
                              p_pct_value               NUMBER,
                              p_li_value                NUMBER,
                              p_unit_prc                NUMBER,
                              p_unit_prc_unit           VARCHAR2,
                              p_vat_code                VARCHAR2,
                              p_daytime                 DATE,
                              p_user                    VARCHAR2 DEFAULT NULL,
                              p_calculation_id          VARCHAR2 DEFAULT NULL,
                              p_price_object_id VARCHAR2 DEFAULT NULL,
                              p_line_item_template_code VARCHAR2 DEFAULT NULL);
PROCEDURE DelEmptyLineItemsFromTemp(p_document_key VARCHAR2);

END EcDp_Line_Item;