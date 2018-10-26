CREATE OR REPLACE EDITIONABLE TRIGGER "D_CONT_LINE_ITEM_DIST" 
BEFORE DELETE ON CONT_LINE_ITEM_DIST
FOR EACH ROW
DECLARE

BEGIN
       ecdp_line_item.DelLineItemChildRecords(:old.line_item_key,:old.dist_id);
       EcDp_VOQty.ReStoreVOQty(ec_contract_doc.contract_id( EC_CONT_DOCUMENT.contract_doc_id(ec_cont_transaction.document_key(:Old.transaction_key)) ),:Old.transaction_key,:Old.stream_item_id,EC_CONT_TRANSACTION.transaction_date(:Old.transaction_key),nvl(:Old.last_updated_by,:Old.created_by));



       -- Cleanup quantities
       -- A similar routine is done at transaction level on d_cont_transaction trigger
       UPDATE stim_mth_value smv
          SET smv.transaction_key = NULL
        WHERE smv.object_id = :Old.stream_item_id
          AND transaction_key = :Old.transaction_key;

END;
