CREATE OR REPLACE EDITIONABLE TRIGGER "D_CONT_TRANSACTION" 
-- $Revision: 1.7 $
BEFORE DELETE ON CONT_TRANSACTION
FOR EACH ROW

DECLARE

BEGIN

        -- perform document total updates
        UPDATE cont_document SET
             doc_memo_value        = Nvl(doc_memo_value,0)        - Nvl(:Old.trans_memo_value,0)
            ,doc_memo_vat          = Nvl(doc_memo_vat,0)          - Nvl(:Old.trans_memo_vat,0)
            ,doc_memo_total        = Nvl(doc_memo_total,0)        - Nvl(:Old.trans_memo_total,0)
            ,doc_booking_value     = Nvl(doc_booking_value,0)     - Nvl(:Old.trans_booking_value,0)
            ,doc_booking_vat       = Nvl(doc_booking_vat,0)       - Nvl(:Old.trans_booking_vat,0)
            ,doc_booking_total     = Nvl(doc_booking_total,0)     - Nvl(:Old.trans_booking_total,0)
            ,doc_local_value       = Nvl(doc_local_value,0)       - Nvl(:Old.trans_local_value,0)
            ,doc_local_vat         = Nvl(doc_local_vat,0)         - Nvl(:Old.trans_local_vat,0)
            ,doc_local_total       = Nvl(doc_local_total,0)       - Nvl(:Old.trans_local_total,0)
            ,doc_group_value       = Nvl(doc_group_value,0)       - Nvl(:Old.trans_group_value,0)
            ,doc_group_vat         = Nvl(doc_group_vat,0)         - Nvl(:Old.trans_group_vat,0)
            ,doc_group_total       = Nvl(doc_group_total,0)       - Nvl(:Old.trans_group_total,0)
            ,last_updated_by = NVL(:Old.last_updated_by, :Old.created_by)
        WHERE document_key = :Old.document_key;

        EcDp_VOQty.ReStoreVOQty(:Old.object_id,:Old.transaction_key,:Old.stream_item_id,:Old.transaction_date,nvl(:Old.last_updated_by,:Old.created_by));

        -- Delete from stim_mth_value if transaction to be deleted
        UPDATE stim_mth_value
           SET transaction_key = NULL
         WHERE object_id = :Old.stream_item_id
           AND transaction_key = :Old.transaction_key;

END;
