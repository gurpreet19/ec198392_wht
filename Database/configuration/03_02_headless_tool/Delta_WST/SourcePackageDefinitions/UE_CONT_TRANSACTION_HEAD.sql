CREATE OR REPLACE PACKAGE ue_Cont_Transaction IS
/****************************************************************
** Package        :  ue_Cont_Transaction, header part
**
** $Revision:
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.12.2009 Kheng
**
** Modification history:
**
** Version  Date         Whom   Change description:
** -------  ------       -----  --------------------------------------
******************************************************************/

isValidateTransactionUEE VARCHAR2(32) := 'FALSE';
isGetTransSortOrderUEE VARCHAR2(32) := 'FALSE';
isGetTransSortOrderPreUEE VARCHAR2(32) := 'FALSE';
isGetTransSortOrderPostUEE VARCHAR2(32) := 'FALSE';
isSetTransSortOrderUEE VARCHAR2(32) := 'FALSE';
isSetTransSortOrderPreUEE VARCHAR2(32) := 'FALSE';
isSetTransSortOrderPostUEE VARCHAR2(32) := 'FALSE';
isSetAllTransSortOrderUEE VARCHAR2(32) := 'FALSE';
isGetTransNameUEE VARCHAR2(32) := 'FALSE';
isGetTransNamePreUEE VARCHAR2(32) := 'FALSE';
isGetTransNamePostUEE VARCHAR2(32) := 'FALSE';
isResolveTransNamePHUEE VARCHAR(32) := 'FALSE';
isFillTransUEEnabled VARCHAR2(32) := 'FALSE';
isFillTransQtyUEEnabled VARCHAR2(32) := 'FALSE';
isFillTransLIUEEnabled VARCHAR2(32) := 'FALSE';
isFillTransPriceUEEnabled VARCHAR2(32) := 'FALSE';
isFillTransPostUEEnabled VARCHAR2(32) := 'FALSE';
isFillTransQtyPostUEEnabled VARCHAR2(32) := 'FALSE';
isFillTransLIPostUEEnabled VARCHAR2(32) := 'FALSE';
isFillTransPricePostUEEnabled VARCHAR2(32) := 'FALSE';
isisTransactionEditableUEE VARCHAR2(32) := 'FALSE';
isisTransactionEditablePreUEE VARCHAR2(32) := 'FALSE';
isisTransactionEditablePostUEE VARCHAR2(32) := 'FALSE';
isValidateDocVATUEE VARCHAR2(32) := 'FALSE';
isValidateDocVATPreUEE VARCHAR2(32) := 'FALSE';
isValidateDocVATPostUEE VARCHAR2(32) := 'FALSE';
isGetOrigCountryForTransUEE VARCHAR2(32) := 'FALSE';
isGetDestCountryForTransUEE VARCHAR2(32) := 'FALSE';

PROCEDURE FillTransactionLines(p_transaction_key VARCHAR2,
                                  p_user            VARCHAR2);

PROCEDURE FillTransaction(p_transaction_key VARCHAR2,
                          p_daytime         DATE,
                          p_user            VARCHAR2);

PROCEDURE FillTransactionQuantity(p_transaction_key VARCHAR2,
                                  p_user            VARCHAR2);

PROCEDURE FillTransactionPrice(p_transaction_key VARCHAR2,
                               p_daytime         DATE,
                               p_user            VARCHAR2,
                               p_line_item_based_type VARCHAR2 DEFAULT NULL);

PROCEDURE FillTransPost(p_transaction_key VARCHAR2,
                        p_daytime         DATE,
                        p_user            VARCHAR2);

PROCEDURE FillTransQtyPost(p_transaction_key VARCHAR2,
                           p_user            VARCHAR2);

PROCEDURE FillTransLIPost(p_transaction_key VARCHAR2,
                           p_user            VARCHAR2);

PROCEDURE FillTransPricePost(p_transaction_key VARCHAR2,
                             p_daytime         DATE,
                             p_user            VARCHAR2,
                             p_line_item_based_type VARCHAR2 DEFAULT NULL);

PROCEDURE ValidateTransactions(
    p_rec_doc  cont_document%ROWTYPE,
    p_val_msg  OUT VARCHAR2,
    p_val_code OUT VARCHAR2,
    p_silent_ind   VARCHAR2);

FUNCTION GetTransactionName(
    p_transaction cont_transaction%ROWTYPE,
    p_limit_size NUMBER DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION GetTransactionNamePre(
    p_transaction cont_transaction%ROWTYPE,
    p_limit_size NUMBER DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION GetTransactionNamePost(
    p_transaction cont_transaction%ROWTYPE,
    p_transaction_name VARCHAR2,
    p_limit_size NUMBER DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION ResolveTransNamePH(
    p_placeholder_name  VARCHAR2,
    p_transaction CONT_TRANSACTION%ROWTYPE)
RETURN VARCHAR2;

FUNCTION isTransactionEditable(
         p_transaction_key VARCHAR2,
         p_level VARCHAR2 DEFAULT 'TRANS')
RETURN VARCHAR2;

FUNCTION isTransactionEditablePre(
         p_transaction_key VARCHAR2,
         p_level VARCHAR2 DEFAULT 'TRANS')
RETURN VARCHAR2;

FUNCTION isTransactionEditablePost(
         p_transaction_key VARCHAR2,
         p_level VARCHAR2 DEFAULT 'TRANS')
RETURN VARCHAR2;


PROCEDURE SetAllTransSortOrder(p_document_key VARCHAR2);

FUNCTION GetTransSortOrder(p_transaction CONT_TRANSACTION%ROWTYPE) RETURN NUMBER;

FUNCTION GetTransSortOrderPre(p_transaction CONT_TRANSACTION%ROWTYPE) RETURN NUMBER;

FUNCTION GetTransSortOrderPost(p_transaction CONT_TRANSACTION%ROWTYPE, p_sort_order_number NUMBER) RETURN NUMBER;

PROCEDURE SetTransSortOrder(p_transaction CONT_TRANSACTION%ROWTYPE, p_recalculate_sort_order BOOLEAN, p_user VARCHAR2);

PROCEDURE SetTransSortOrderPre(p_transaction CONT_TRANSACTION%ROWTYPE, p_recalculate_sort_order BOOLEAN, p_user VARCHAR2);

PROCEDURE SetTransSortOrderPost(p_transaction CONT_TRANSACTION%ROWTYPE, p_recalculate_sort_order BOOLEAN, p_user VARCHAR2, updated_trans_sort_order NUMBER);

PROCEDURE ValidateDocVAT (
          p_document_key VARCHAR2);

PROCEDURE ValidateDocVATPre (
          p_document_key VARCHAR2);

PROCEDURE ValidateDocVATPost (
          p_document_key VARCHAR2);

FUNCTION GetOriginCountryForTrans(p_trans_tmpl_obj_id   VARCHAR2,
                                  p_transaction_key     VARCHAR2,
                                  p_transaction_scope   VARCHAR2,
                                  p_delivery_point_id   VARCHAR2,
                                  p_loading_port_id     VARCHAR2,
                                  p_daytime             DATE) RETURN VARCHAR2;

FUNCTION GetDestinationCountryForTrans(p_trans_tmpl_obj_id VARCHAR2,
                                       p_transaction_key   VARCHAR2,
                                       p_transaction_scope VARCHAR2,
                                       p_delivery_point_id VARCHAR2,
                                       p_discharge_port_id VARCHAR2,
                                       p_daytime           DATE) RETURN VARCHAR2;

PROCEDURE FillTransactionOLI(p_transaction_key VARCHAR2,
                             p_user            VARCHAR2);

END ue_Cont_Transaction;