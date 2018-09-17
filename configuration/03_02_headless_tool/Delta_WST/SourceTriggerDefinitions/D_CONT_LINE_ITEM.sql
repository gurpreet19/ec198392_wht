CREATE OR REPLACE EDITIONABLE TRIGGER "D_CONT_LINE_ITEM" 
BEFORE DELETE ON CONT_LINE_ITEM
FOR EACH ROW

DECLARE

conv_factors Ecdp_Transaction.t_constrained_factor_table;

lv2_where VARCHAR2(240);

ln_precision NUMBER := 2;
ln_no_of_clif_recs NUMBER;
ln_conv_factor_size NUMBER;
ln_realloc_no NUMBER;

lb_update BOOLEAN;

lv2_document_type cont_document.document_type%TYPE := ec_cont_document.document_type(:New.document_key);

BEGIN

       lv2_document_type := Nvl(lv2_document_type,ec_cont_document.document_type(:Old.document_key));

       IF (lv2_document_type NOT LIKE '%MASTER%') THEN

           DELETE FROM cont_line_item_dist
            WHERE line_item_key = :Old.line_item_key;

           -- perform transaction total updates
           IF :Old.UOM1_CODE IS NOT NULL THEN -- qty based liv


                UPDATE cont_transaction
                   SET qty_pricing_value = Nvl(qty_pricing_value,0) - Nvl(:Old.pricing_value,0)
                      ,qty_pricing_vat   = Nvl(qty_pricing_vat,0)   - Nvl(:Old.pricing_vat_value,0)
                      ,qty_memo_value    = Nvl(qty_memo_value,0)    - Nvl(:Old.memo_value,0)
                      ,qty_memo_vat      = Nvl(qty_memo_vat,0)      - Nvl(:Old.memo_vat_value,0)
                      ,qty_booking_value = Nvl(qty_booking_value,0) - Nvl(:Old.booking_value,0)
                      ,qty_booking_vat   = Nvl(qty_booking_vat,0)   - Nvl(:Old.booking_vat_value,0)
                      ,last_updated_by   = NVL(:Old.last_updated_by, :Old.created_by)
                 WHERE transaction_key = :Old.transaction_key;

           ELSE -- other type

                UPDATE cont_transaction
                   SET other_pricing_value = Nvl(other_pricing_value,0) - Nvl(:Old.pricing_value,0)
                      ,other_pricing_vat   = Nvl(other_pricing_vat,0)   - Nvl(:Old.pricing_vat_value,0)
                      ,other_memo_value    = Nvl(other_memo_value,0)    - Nvl(:Old.memo_value,0)
                      ,other_memo_vat      = Nvl(other_memo_vat,0)      - Nvl(:Old.memo_vat_value,0)
                      ,other_booking_value = Nvl(other_booking_value,0) - Nvl(:Old.booking_value,0)
                      ,other_booking_vat   = Nvl(other_booking_vat,0)   - Nvl(:Old.booking_vat_value,0)
                      ,last_updated_by     = NVL(:Old.last_updated_by, :Old.created_by)
                 WHERE transaction_key = :Old.transaction_key;

           END IF;

           -- perform transaction total updates
           UPDATE cont_transaction ct
              SET ct.trans_pricing_value = nvl(ct.qty_pricing_value,0) + nvl(ct.other_pricing_value,0)
                 ,ct.trans_pricing_vat   = Nvl(ct.qty_pricing_vat,0)   + Nvl(ct.other_pricing_vat,0)
                 ,ct.trans_memo_value    = nvl(ct.qty_memo_value,0)    + nvl(ct.other_memo_value,0)
                 ,ct.trans_memo_vat      = Nvl(ct.qty_memo_vat,0)      + Nvl(ct.other_memo_vat,0)
                 ,ct.trans_booking_value = nvl(ct.qty_booking_value,0) + nvl(ct.other_booking_value,0)
                 ,ct.trans_booking_vat   = Nvl(ct.qty_booking_vat,0)   + Nvl(ct.other_booking_vat,0)
                 ,ct.trans_local_value   = nvl(ct.trans_local_value,0) - NVL(:Old.local_value,0) -- Deducting local and group value from the deleted line item
                 ,ct.trans_local_vat     = Nvl(ct.trans_local_vat,0)   - Nvl(:Old.local_vat_value,0)
                 ,ct.trans_group_value   = nvl(ct.trans_group_value,0) - NVL(:Old.group_value,0)
                 ,ct.trans_group_vat     = Nvl(ct.trans_group_vat,0)   - Nvl(:Old.group_vat_value,0)
                 ,ct.last_updated_by     = NVL(:Old.last_updated_by, :Old.created_by)
            WHERE transaction_key = :Old.transaction_key;

         END IF;
END;
