CREATE OR REPLACE EDITIONABLE TRIGGER "D_CONT_LI_DIST_COMPANY" 
BEFORE DELETE ON CONT_LI_DIST_COMPANY
FOR EACH ROW
DECLARE

BEGIN
       EcDp_VOQty.ReStoreVOQty(ec_contract_doc.contract_id(ec_cont_document.contract_doc_id(ec_cont_transaction.document_key(:OLD.transaction_key))),
                               :OLD.transaction_key,
                               :OLD.Company_Stream_Item_Id,
                               ec_cont_transaction.transaction_date(:OLD.transaction_key),
                               nvl(:OLD.last_updated_by, :OLD.created_by));
END;
