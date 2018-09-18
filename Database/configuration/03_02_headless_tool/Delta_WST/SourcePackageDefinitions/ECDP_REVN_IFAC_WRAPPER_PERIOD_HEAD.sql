CREATE OR REPLACE PACKAGE EcDp_REVN_IFAC_WRAPPER_PERIOD IS

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION WrapInterfaceRecord(
                         p_ifac                             IFAC_SALES_QTY%ROWTYPE
                        )
RETURN T_IFAC_SALES_QTY;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Gets unprocessed period interface records for a transaction that match the given values
/*
FUNCTION GetIfacForLineItem(
                         p_contract_id                      objects.object_id%TYPE
                        ,p_price_concept_code               price_concept.price_concept_code%TYPE
                        ,p_price_object_id                  objects.object_id%TYPE
                        ,p_product_id                       objects.object_id%TYPE
                        ,p_delivery_point_id                objects.object_id%TYPE
                        ,p_customer_id                      objects.object_id%TYPE
                        ,p_qty_status                       Transaction_Tmpl_Version.Req_Qty_Type%TYPE
                        ,p_doc_status_code                  cont_document.status_code%TYPE
                        ,p_period_start_date                DATE
                        ,p_period_end_date                  DATE
                        ,p_uom1_code                        VARCHAR2
                        ,p_ct_uk1                           VARCHAR2
                        ,p_ct_uk2                           VARCHAR2
                        ,p_if_tt_conn_code                  VARCHAR2
                        ,p_processing_period                DATE
                        ,p_transaction_template_id          VARCHAR2
                        ,p_line_item_based_type             VARCHAR2 DEFAULT 'QTY'
                        ,p_line_item_type                   VARCHAR2 DEFAULT NULL
                        ,p_line_item_code                   VARCHAR2 DEFAULT NULL
                        ,p_ifac_qty_rec                     T_TABLE_IFAC_SALES_QTY DEFAULT NULL
                        ,p_qty_pc_share                     T_TABLE_REVN_DIST_INFO DEFAULT NULL
                        )
RETURN T_TABLE_IFAC_SALES_QTY;
*/
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Gets unprocessed period interface records for a document that match the given values
FUNCTION GetIfacForDocument(
               p_contract_id                         objects.object_id%TYPE
              ,p_document_setup_id                   objects.object_id%TYPE
              ,p_processing_period                   DATE
              ,p_customer_id                         objects.object_id%TYPE
              ,p_document_status                     VARCHAR2
              )
RETURN T_TABLE_IFAC_SALES_QTY;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
/*
PROCEDURE CompleteIfac(
                         p_records                          IN OUT NOCOPY T_TABLE_IFAC_SALES_QTY
                        );
*/
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetIfacRelatesTo(
                         p_source_entry_no                  NUMBER
                        ,p_scope                            VARCHAR2
                        )
RETURN T_TABLE_IFAC_SALES_QTY;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Gets the transaction level ifac records from the given record collection
FUNCTION GetTransactionLevelIfacRecords(
                         p_records                          IN T_TABLE_IFAC_SALES_QTY
                        )
RETURN T_TABLE_IFAC_SALES_QTY;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Gets the profit center level ifac records from the given record collection
FUNCTION GetPCLevelIfacRecords(
                         p_records                          T_TABLE_IFAC_SALES_QTY
                        ,p_transaction_level_record         T_IFAC_SALES_QTY
                        ,p_profit_center_id                 VARCHAR2 DEFAULT NULL
                        )
RETURN T_TABLE_IFAC_SALES_QTY;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Gets the vendor level ifac records from the given record collection
FUNCTION GetVendorLevelIfacRecords(
                         p_records                          T_TABLE_IFAC_SALES_QTY
                        ,p_pc_level_record                  T_IFAC_SALES_QTY
                        ,p_vendor_id                        VARCHAR2 DEFAULT NULL
                        )
RETURN T_TABLE_IFAC_SALES_QTY;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION IfacRecordHasVendorPC(
                         p_source_entry_no                  NUMBER
                        ,p_vendor_id                        varchar2 default 'XX'
                        ,p_profit_centre                    varchar2 default 'XX'
                        )
RETURN varchar2;
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Sorts given ifac collection.
--
-- p_by: the column to sort by
-- p_decodes: decode cases for the sory by column.
--
-- Example:
--     Sorts a collection by DOC_STATUS with order 'FINAL', 'ACCRUAL':
--         sort(ifac_collection, 'DOC_STATUS', '''FINAL'', 1, ''ACCRUAL'', 2, 3')
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION sort(
                         p_collection                       IN OUT NOCOPY T_TABLE_IFAC_SALES_QTY
                        ,p_by                               VARCHAR2 DEFAULT NULL
                        ,p_decodes                          VARCHAR2 DEFAULT NULL
                        )
RETURN T_TABLE_IFAC_SALES_QTY;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Finds the index of interface records with given attributes.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION find(
                         p_ifac                             in out nocopy t_table_ifac_sales_qty
                        ,p_range                            t_table_number DEFAULT NULL
                        ,p_level                            VARCHAR2 default null
                        ,p_trans_id                         number default null
                        ,p_li_id                            number default null
                        ,p_transaction_key                  varchar2 default null
                        ,p_line_item_key                    varchar2 default NULL
                        ,p_profit_center_id                 VARCHAR2 DEFAULT NULL
                        ,p_vendor_id                        VARCHAR2 DEFAULT NULL
)
return T_TABLE_NUMBER;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Finds the first index of interface records with given attributes.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION find_one(
                         p_ifac                             in out nocopy t_table_ifac_sales_qty
                        ,p_range                            t_table_number DEFAULT NULL
                        ,p_level                            VARCHAR2 default null
                        ,p_trans_id                         number default null
                        ,p_li_id                            number default null
                        ,p_transaction_key                  varchar2 default null
                        ,p_line_item_key                    varchar2 default NULL
                        ,p_profit_center_id                 VARCHAR2 DEFAULT NULL
                        ,p_vendor_id                        VARCHAR2 DEFAULT NULL
)
return NUMBER;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Filters the interface records with given SQL where condition.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION filter(
                         p_collection                       IN OUT NOCOPY T_TABLE_IFAC_SALES_QTY
                        ,p_condition                        VARCHAR2
                        )
RETURN T_TABLE_IFAC_SALES_QTY;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Filters the interface records with given attributes.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION filter(
                         p_collection                       in out nocopy t_table_ifac_sales_qty
                        ,p_level                            VARCHAR2
                        ,p_trans_id                         NUMBER
                        ,p_li_id                            NUMBER
                        ,p_transaction_key                  VARCHAR2
)
RETURN T_TABLE_IFAC_SALES_QTY;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Gets distinct values of given attribute on collection.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION Aggregate(
                         p_collection                       IN OUT NOCOPY T_TABLE_IFAC_SALES_QTY
                        ,p_by                               VARCHAR2
                        )
RETURN t_table_varchar2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------


END EcDp_REVN_IFAC_WRAPPER_PERIOD;