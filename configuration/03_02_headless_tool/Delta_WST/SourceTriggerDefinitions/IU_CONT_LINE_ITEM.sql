CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CONT_LINE_ITEM" 
BEFORE INSERT OR UPDATE ON CONT_LINE_ITEM
FOR EACH ROW

DECLARE

/*
CURSOR c_livf IS
  SELECT dist_id
  FROM cont_line_item_dist
  WHERE object_id = :New.object_id
  AND line_item_key = :New.line_item_key
  ;

conv_factors Ecdp_Transaction.t_constrained_factor_table;
*/
no_uom EXCEPTION;
same_uom EXCEPTION;
no_monetary_upd EXCEPTION;

lv2_where VARCHAR2(240);

ln_precision NUMBER := NVL(ec_ctrl_system_attribute.attribute_value(:NEW.DAYTIME, 'EX_VAT_PRECISION', '<='),2);
lvat_precision NUMBER:=NVL(ec_ctrl_system_attribute.attribute_value(:NEW.DAYTIME, 'VAT_PRECISION', '<='), ln_precision); --This is used to round VAT calculated values
ln_no_of_clif_recs NUMBER;
ln_conv_factor_size NUMBER;
lv2_tot_price_not_rounded NUMBER;

lb_is_accrual BOOLEAN;

lb_update BOOLEAN;

lv2_document_type cont_document.document_type%TYPE := ec_cont_document.document_type(:New.document_key);
lv2_org_price NUMBER := ec_product_price_value.adj_price_value(nvl(:New.PRICE_OBJECT_ID, ec_cont_transaction.price_object_id(:New.transaction_key)), :New.PRICE_CONCEPT_CODE, :New.PRICE_ELEMENT_CODE, :NEW.DAYTIME, 'CONTRACT');
lv2_price_rounding_rule Varchar2(32) := ec_product_price_version.price_rounding_rule(nvl(:New.PRICE_OBJECT_ID, ec_cont_transaction.price_object_id(:New.transaction_key)),:NEW.DAYTIME,'<=');

BEGIN

   IF Inserting THEN

        :new.record_status := 'P';
        IF :new.created_by IS NULL THEN
           :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
        END IF;
        :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
        :new.rev_no := 0;

        IF :new.line_item_key IS NULL THEN
        	EcDp_System_Key.assignNextNumber('CONT_LINE_ITEM',:new.line_item_key);
        END IF;

       ---------------------------------------------------------------------------------------
       ecdp_transaction.updTotPriceNotRounded(:New.PRICE_CONCEPT_CODE, ec_cont_transaction.object_id(:New.transaction_key), :New.transaction_key);
       lv2_tot_price_not_rounded := ec_cont_transaction.tot_price_not_rounded(:New.transaction_key);

       -- Updating original price
       :New.UNIT_PRICE_NOT_ROUNDED := lv2_org_price;
       -- Updating UNIT_PRICE_OVERRIDE
       IF lv2_price_rounding_rule = 'SUM_OF_PRICE_ELEMENTS' THEN
         :New.UNIT_PRICE_OVERRIDE := (:New.UNIT_PRICE_NOT_ROUNDED / lv2_tot_price_not_rounded) * ROUND(lv2_tot_price_not_rounded,3);
       ELSE
         :New.UNIT_PRICE_OVERRIDE := NULL;
       END IF;
       --Updating Pricing Value
       IF :New.UNIT_PRICE_OVERRIDE IS NOT NULL THEN
            :New.PRICING_VALUE := :New.QTY1 * :New.UNIT_PRICE_OVERRIDE;
       END IF;

       -- perform transaction total updates
       IF :New.UOM1_CODE IS NOT NULL THEN -- qty based liv
            UPDATE cont_transaction
               SET qty_pricing_value = Nvl(qty_pricing_value,0) + Nvl(:New.pricing_value,0)
                  ,qty_pricing_vat   = Nvl(qty_pricing_vat,0)   + Nvl(:New.pricing_vat_value,0)
                  ,qty_memo_value    = Nvl(qty_memo_value,0)    + Nvl(:New.memo_value,0)
                  ,qty_memo_vat      = Nvl(qty_memo_vat,0)      + Nvl(:New.memo_vat_value,0)
                  ,qty_booking_value = Nvl(qty_booking_value,0) + Nvl(:New.booking_value,0)
                  ,qty_booking_vat   = Nvl(qty_booking_vat,0)   + Nvl(:New.booking_vat_value,0)
                  ,last_updated_by = 'SYSTEM' -- part of insert operation
             WHERE object_id = :New.object_id
               AND transaction_key = :New.transaction_key;

       ELSE -- other type
            UPDATE cont_transaction
               SET other_pricing_value = Nvl(other_pricing_value,0) + Nvl(:New.pricing_value,0)
                  ,other_pricing_vat   = Nvl(other_pricing_vat,0)   + Nvl(:New.pricing_vat_value,0)
                  ,other_memo_value    = Nvl(other_memo_value,0)    + Nvl(:New.memo_value,0)
                  ,other_memo_vat      = Nvl(other_memo_vat,0)      + Nvl(:New.memo_vat_value,0)
                  ,other_booking_value = Nvl(other_booking_value,0) + Nvl(:New.booking_value,0)
                  ,other_booking_vat   = Nvl(other_booking_vat,0)   + Nvl(:New.booking_vat_value,0)
                  ,last_updated_by = 'SYSTEM' -- part of insert operation
             WHERE object_id = :New.object_id
               AND transaction_key = :New.transaction_key;
       END IF;

       -- do this for all
       UPDATE cont_transaction
          SET trans_pricing_value = Nvl(trans_pricing_value,0) + Nvl(:New.pricing_value,0)
             ,trans_pricing_vat   = Nvl(trans_pricing_vat,0)   + Nvl(:New.pricing_vat_value,0)
             ,trans_memo_value    = Nvl(trans_memo_value,0)    + Nvl(:New.memo_value,0)
             ,trans_memo_vat      = Nvl(trans_memo_vat,0)      + Nvl(:New.memo_vat_value,0)
             ,trans_booking_value = Nvl(trans_booking_value,0) + Nvl(:New.booking_value,0)
             ,trans_booking_vat   = Nvl(trans_booking_vat,0)   + Nvl(:New.booking_vat_value,0)
             ,trans_local_value   = Nvl(trans_local_value,0)   + Nvl(:New.local_value,0)
             ,trans_local_vat     = Nvl(trans_local_vat,0)     + Nvl(:New.local_vat_value,0)
             ,trans_group_value   = Nvl(trans_group_value,0)   + Nvl(:New.group_value,0)
             ,trans_group_vat     = Nvl(trans_group_vat,0)     + Nvl(:New.group_vat_value,0)
             ,last_updated_by = 'SYSTEM' -- part of insert operation
       WHERE object_id = :New.object_id
          AND transaction_key = :New.transaction_key;

    ELSIF Updating THEN

  		   lb_update := FALSE;
		     ln_no_of_clif_recs := 0;

    	   -- perform basic check on consistency between qty and UOM
         IF :New.QTY1 IS NOT NULL AND :New.UOM1_CODE IS NULL THEN RAISE no_uom; END IF;
         IF :New.QTY2 IS NOT NULL AND :New.UOM2_CODE IS NULL THEN RAISE no_uom; END IF;
         IF :New.QTY3 IS NOT NULL AND :New.UOM3_CODE IS NULL THEN RAISE no_uom; END IF;
         IF :New.QTY4 IS NOT NULL AND :New.UOM4_CODE IS NULL THEN RAISE no_uom; END IF;

    	   -- perform check on different UOM
         IF :New.UOM1_CODE = :New.UOM2_CODE OR :New.UOM1_CODE = :New.UOM3_CODE OR :New.UOM1_CODE = :New.UOM4_CODE THEN RAISE same_uom; END IF;
         IF :New.UOM2_CODE = :New.UOM3_CODE OR :New.UOM2_CODE = :New.UOM4_CODE THEN RAISE same_uom; END IF;
         IF :New.UOM3_CODE = :New.UOM4_CODE THEN RAISE same_uom; END IF;

         -- perform line item monetary calcs
         IF Nvl(ec_cont_document.document_type(:New.document_key),'XXX') = 'MASTER' THEN --calculate monetary values
            -- prevent updating monetary data
            IF Updating('PRICING_VALUE') OR Updating('NON_ADJUSTED_VALUE') OR Updating('UNIT_PRICE') OR Updating('VALUE_ADJUSTMENT') THEN
               RAISE no_monetary_upd;
            END IF;
         ELSE

         ecdp_transaction.updTotPriceNotRounded(:New.PRICE_CONCEPT_CODE, ec_cont_transaction.object_id(:New.transaction_key), :New.transaction_key);
         lv2_tot_price_not_rounded := ec_cont_transaction.tot_price_not_rounded(:New.transaction_key);

         -- Updating original price
         :New.UNIT_PRICE_NOT_ROUNDED := lv2_org_price;
         -- Updating UNIT_PRICE_OVERRIDE
         IF lv2_price_rounding_rule = 'SUM_OF_PRICE_ELEMENTS' THEN
            :New.UNIT_PRICE_OVERRIDE := (:New.UNIT_PRICE_NOT_ROUNDED / lv2_tot_price_not_rounded) * ROUND(lv2_tot_price_not_rounded,3);
         ELSE
           :New.UNIT_PRICE_OVERRIDE := NULL;
         END IF;

         --Updating Pricing Value
         IF :New.UNIT_PRICE_OVERRIDE IS NOT NULL THEN
            :New.PRICING_VALUE := :New.QTY1 * :New.UNIT_PRICE_OVERRIDE;
         END IF;

         ------------------------------------------------------------------------------------------
         -- perform dependent LIV calculations
         -- only for qty based line_itemd
         IF :New.line_item_based_type='QTY' AND
            Updating('OBJECT_ID')           AND -- Update is done from dao which updates all columns without necessary new values
           (
            (Updating('QTY1') AND nvl(:Old.qty1,-1) <> nvl(:New.qty1,-1)) OR
            (Updating('UNIT_PRICE') AND nvl(:Old.unit_price,-1) <> nvl(:New.unit_price,-1)) OR
            (Updating('VALUE_ADJUSTMENT') AND nvl(:Old.value_adjustment,-1) <> nvl(:New.value_adjustment,-1))
            ) THEN

             :New.non_adjusted_value := Round( :New.qty1 * :New.unit_price, ln_precision);
             IF :New.UNIT_PRICE_OVERRIDE IS NULL THEN
             	  :New.pricing_value := Round( :New.non_adjusted_value * Nvl(:New.value_adjustment,1), ln_precision);
             END IF;
          -- Update is done directly on table
         ELSIF NOT Updating('OBJECT_ID') AND :New.line_item_based_type='QTY' AND (Updating('QTY1') OR Updating('UNIT_PRICE') OR Updating('VALUE_ADJUSTMENT')) THEN
             :New.non_adjusted_value := Round( :New.qty1 * :New.unit_price, ln_precision);
             IF :New.UNIT_PRICE_OVERRIDE IS NULL THEN
             	  :New.pricing_value := Round( :New.non_adjusted_value * Nvl(:New.value_adjustment,1), ln_precision);
             END IF;
         ELSIF :New.line_item_based_type='FREE_UNIT' AND (Updating('FREE_UNIT_QTY') OR Updating('UNIT_PRICE')) THEN

             IF :New.UNIT_PRICE_OVERRIDE IS NULL THEN
             	  :New.pricing_value := Round(:New.unit_price * :New.free_unit_qty, ln_precision);
             END IF;
         ELSIF Updating('PRICING_VALUE') THEN
             IF :New.UNIT_PRICE_OVERRIDE IS NULL THEN
             	  :New.pricing_value := Round( :New.pricing_value,ln_precision); -- Make sure proper rounding is done
             END IF;
         ELSIF Updating('NON_ADJUSTED_VALUE') THEN
             IF :New.UNIT_PRICE_OVERRIDE IS NULL THEN
             	  :New.pricing_value := :New.non_adjusted_value * Nvl(:New.value_adjustment,1);
             END IF;
         END IF;

		     -- For updating Price Object free unit Qty or Unit Price
         IF :New.line_item_based_type='FREE_UNIT_PRICE_OBJECT' THEN--AND (Updating('FREE_UNIT_QTY') OR Updating('UNIT_PRICE')) THEN
             IF :New.UNIT_PRICE_OVERRIDE IS NULL THEN
             	  :New.pricing_value := Round(:New.unit_price * :New.free_unit_qty, ln_precision);
             END IF;
         END IF;

          -- perform vat and tax calc
           -- Get new VAT_RATE if new VAT_CODE
          IF  (nvl(:New.vat_code, 'xxx') <> nvl(:Old.vat_code, 'xxx')) THEN
              :New.vat_rate := ec_vat_code_version.rate(ec_vat_code.object_id_by_uk(:New.vat_code), :New.daytime, '<=');
          END IF;

          lb_is_accrual := FALSE;
          IF ec_ctrl_system_attribute.attribute_text(:New.DAYTIME,'VAT_ON_ACCRUALS','<=') = 'N' AND ec_cont_document.status_code(:New.Document_Key)='ACCRUAL' THEN
           		:New.vat_code := NULL;
           		:New.vat_rate := 0;
              lb_is_accrual := TRUE;
          END IF;

          -- Retrieve VAT_CODE and VAT_RATE for quantity line items (typical after accrual)
          IF :New.vat_code IS NULL AND :New.line_item_based_type = 'QTY' AND NOT lb_is_accrual  THEN
              -- Copy from line item template.
              :New.vat_code := ec_line_item_tmpl_version.vat_code_1(:New.line_item_template_id, :New.daytime, '<=');
           		:New.vat_rate := ec_vat_code_version.rate(ec_vat_code.object_id_by_uk(:New.vat_code), :New.daytime, '<=');
              -- If still no vat code, copy from transaction.
              IF :New.vat_code IS NULL THEN
              :New.vat_code := ec_cont_transaction.vat_code(:New.transaction_key);
           		:New.vat_rate := ec_cont_transaction.vat_rate(:New.transaction_key);
			END IF;

          END IF;

          -- Retrieve VAT_CODE and VAT_RATE for other line items (typical after accrual)
          IF :New.vat_code IS NULL AND (:New.line_item_based_type <> 'QTY' OR :New.line_item_based_type IS NULL) AND NOT lb_is_accrual THEN

              -- Copy from line item template.
              :New.vat_code := ec_line_item_tmpl_version.vat_code_1(:New.line_item_template_id, :New.daytime, '<=');
           		:New.vat_rate := ec_vat_code_version.rate(ec_vat_code.object_id_by_uk(:New.vat_code), :New.daytime, '<=');
              -- If still no vat code, copy from transaction.
              IF :New.vat_code IS NULL THEN
                 :New.vat_code := ec_cont_transaction.vat_code(:New.transaction_key);
           		   :New.vat_rate := ec_cont_transaction.vat_rate(:New.transaction_key);
              END IF;
          END IF;

          :New.pricing_vat_value  := Round( :New.pricing_value * :New.vat_rate ,lvat_precision);

          :New.memo_value := Round( :New.pricing_value * ec_cont_transaction.ex_pricing_memo(:New.transaction_key), ln_precision);

          :New.memo_vat_value  := Round( :New.memo_value * :New.vat_rate, lvat_precision);

          IF (:New.line_item_based_type = 'BOOKED_FIXED_VALUE' AND NVL(:New.booking_value,0) <> 0 AND NOT Updating('PRICING_VALUE')) THEN
             IF :New.UNIT_PRICE_OVERRIDE IS NULL THEN
             	  :New.pricing_value := Round( :New.booking_value * ec_cont_transaction.ex_inv_pricing_booking(:New.transaction_key) , ln_precision);
             END IF;
              :New.pricing_vat_value  := Round( :New.pricing_value * :New.vat_rate , lvat_precision);
          ELSE
              :New.booking_value := Round( :New.pricing_value * ec_cont_transaction.ex_pricing_booking(:New.transaction_key) , ln_precision);

              :New.booking_vat_value  := Round( :New.booking_value * :New.vat_rate , lvat_precision);
          END IF;

          :New.local_value := Round( :New.booking_value * ec_cont_transaction.ex_booking_local(:New.transaction_key), ln_precision);

          :New.local_vat_value  := Round( :New.local_value * :New.vat_rate, lvat_precision);

          :New.group_value := Round( :New.booking_value * ec_cont_transaction.ex_booking_group(:New.transaction_key), ln_precision);

          :New.group_vat_value  := Round( :New.group_value * :New.vat_rate, lvat_precision);

          :new.PRICING_TOTAL := Round((:new.PRICING_VALUE + :new.PRICING_VAT_VALUE),ln_precision);

          :new.BOOKING_TOTAL := Round((:new.BOOKING_VALUE + :new.BOOKING_VAT_VALUE),ln_precision);

          :new.MEMO_TOTAL := Round((:new.MEMO_VALUE + :new.MEMO_VAT_VALUE),ln_precision);

          :new.LOCAL_TOTAL := Round((:new.LOCAL_VALUE + :new.LOCAL_VAT_VALUE),ln_precision);

          :new.GROUP_TOTAL := Round((:new.GROUP_VALUE + :new.GROUP_VAT_VALUE),ln_precision);

          ---------------------------------------------------------------------------------------
          -- perform line item dist monetary updates,

          UPDATE cont_line_item_dist
             SET
                vat_code = :New.vat_code
                ,vat_rate = :New.vat_rate
                ,NAME = :New.NAME
                ,LINE_ITEM_TYPE = :New.LINE_ITEM_TYPE
                ,DESCRIPTION = :New.DESCRIPTION
                ,last_updated_by = NVL(:New.last_updated_by,:New.created_by)
                ,last_updated_date = Ecdp_Timestamp.getCurrentSysdate
          WHERE object_id = :New.object_id
            AND line_item_key = :New.line_item_key;

          IF NVL(:New.NO_ROUNDING_IND,'N') != 'Y' THEN
              ecdp_line_item.RoundDistLevel(:new.line_item_key
                                           ,:new.qty1
                                           ,:new.qty2
                                           ,:new.qty3
                                           ,:new.qty4
                                           ,:new.NON_ADJUSTED_VALUE
                                           ,:new.PRICING_VALUE
                                           ,:new.PRICING_VAT_VALUE
                                           ,:new.MEMO_VALUE
                                           ,:new.MEMO_VAT_VALUE
                                           ,:new.BOOKING_VALUE
                                           ,:new.BOOKING_VAT_VALUE
                                           ,:new.LOCAL_VALUE
                                           ,:new.LOCAL_VAT_VALUE
                                           ,:new.GROUP_VALUE
                                           ,:new.GROUP_VAT_VALUE
                                           ,ln_precision
                                           ,lvat_precision);
          END IF;

          IF (lv2_document_type NOT LIKE '%MASTER%') THEN
            ---------------------------------------------------------------------------------------
            IF ( Nvl(:New.pricing_value,0)     - Nvl(:Old.pricing_value,0) ) != 0 OR
               ( Nvl(:New.pricing_vat_value,0) - Nvl(:Old.pricing_vat_value,0) ) != 0 OR
               ( Nvl(:New.memo_value,0)        - Nvl(:Old.memo_value,0) ) != 0 OR
               ( Nvl(:New.memo_vat_value,0)    - Nvl(:Old.memo_vat_value,0) ) != 0 OR
               ( Nvl(:New.booking_value,0)     - Nvl(:Old.booking_value,0) ) != 0 OR
               ( Nvl(:New.booking_vat_value,0) - Nvl(:Old.booking_vat_value,0) ) != 0 THEN

              -- perform transaction total updates
              IF :New.UOM1_CODE IS NOT NULL THEN -- qty based liv

                UPDATE cont_transaction
                 SET qty_pricing_value = Nvl(qty_pricing_value,0) + ( Nvl(:New.pricing_value,0)     - Nvl(:Old.pricing_value,0) )
                    ,qty_pricing_vat   = Nvl(qty_pricing_vat,0)   + ( Nvl(:New.pricing_vat_value,0) - Nvl(:Old.pricing_vat_value,0) )
                    ,qty_memo_value    = Nvl(qty_memo_value,0)    + ( Nvl(:New.memo_value,0)        - Nvl(:Old.memo_value,0) )
                    ,qty_memo_vat      = Nvl(qty_memo_vat,0)      + ( Nvl(:New.memo_vat_value,0)    - Nvl(:Old.memo_vat_value,0) )
                    ,qty_booking_value = Nvl(qty_booking_value,0) + ( Nvl(:New.booking_value,0)     - Nvl(:Old.booking_value,0) )
                    ,qty_booking_vat   = Nvl(qty_booking_vat,0)   + ( Nvl(:New.booking_vat_value,0) - Nvl(:Old.booking_vat_value,0) )
                    ,last_updated_by = NVL(:New.last_updated_by,:New.created_by)
                 WHERE object_id = :New.object_id
                   AND transaction_key = :New.transaction_key;

              ELSE -- other type

                UPDATE cont_transaction
                   SET other_pricing_value = Nvl(other_pricing_value,0) + ( Nvl(:New.pricing_value,0)     - Nvl(:Old.pricing_value,0) )
                      ,other_pricing_vat   = Nvl(other_pricing_vat,0)   + ( Nvl(:New.pricing_vat_value,0) - Nvl(:Old.pricing_vat_value,0) )
                      ,other_memo_value    = Nvl(other_memo_value,0)    + ( Nvl(:New.memo_value,0)        - Nvl(:Old.memo_value,0) )
                      ,other_memo_vat      = Nvl(other_memo_vat,0)      + ( Nvl(:New.memo_vat_value,0)    - Nvl(:Old.memo_vat_value,0) )
                      ,other_booking_value = Nvl(other_booking_value,0) + ( Nvl(:New.booking_value,0)     - Nvl(:Old.booking_value,0) )
                      ,other_booking_vat   = Nvl(other_booking_vat,0)   + ( Nvl(:New.booking_vat_value,0) - Nvl(:Old.booking_vat_value,0) )
                      ,last_updated_by = NVL(:New.last_updated_by,:New.created_by)
                 WHERE object_id = :New.object_id
                   AND transaction_key = :New.transaction_key;

              END IF;
            END IF;

            IF ( Nvl(:New.pricing_value,0)     - Nvl(:Old.pricing_value,0) ) != 0 OR
               ( Nvl(:New.pricing_vat_value,0) - Nvl(:Old.pricing_vat_value,0) ) != 0 OR
               ( Nvl(:New.memo_value,0)        - Nvl(:Old.memo_value,0) ) != 0 OR
               ( Nvl(:New.memo_vat_value,0)    - Nvl(:Old.memo_vat_value,0) ) != 0 OR
               ( Nvl(:New.booking_value,0)     - Nvl(:Old.booking_value,0) ) != 0 OR
               ( Nvl(:New.booking_vat_value,0) - Nvl(:Old.booking_vat_value,0) ) != 0 OR
               ( Nvl(:New.local_value,0)       - Nvl(:Old.local_value,0) ) != 0 OR
               ( Nvl(:New.local_vat_value,0)   - Nvl(:Old.local_vat_value,0) ) != 0 OR
               ( Nvl(:New.group_value,0)       - Nvl(:Old.group_value,0) ) != 0 OR
               ( Nvl(:New.group_value,0)       - Nvl(:Old.group_value,0) ) != 0 THEN

              -- do this for all
              UPDATE cont_transaction
                 SET trans_pricing_value = Nvl(trans_pricing_value,0) + ( Nvl(:New.pricing_value,0)     - Nvl(:Old.pricing_value,0) )
                    ,trans_pricing_vat   = Nvl(trans_pricing_vat,0)   + ( Nvl(:New.pricing_vat_value,0) - Nvl(:Old.pricing_vat_value,0) )
                    ,trans_memo_value    = Nvl(trans_memo_value,0)    + ( Nvl(:New.memo_value,0)        - Nvl(:Old.memo_value,0) )
                    ,trans_memo_vat      = Nvl(trans_memo_vat,0)      + ( Nvl(:New.memo_vat_value,0)    - Nvl(:Old.memo_vat_value,0) )
                    ,trans_booking_value = Nvl(trans_booking_value,0) + ( Nvl(:New.booking_value,0)     - Nvl(:Old.booking_value,0) )
                    ,trans_booking_vat   = Nvl(trans_booking_vat,0)   + ( Nvl(:New.booking_vat_value,0) - Nvl(:Old.booking_vat_value,0) )
                    ,trans_local_value   = Nvl(trans_local_value,0)   + ( Nvl(:New.local_value,0)       - Nvl(:Old.local_value,0) )
                    ,trans_local_vat     = Nvl(trans_local_vat,0)     + ( Nvl(:New.local_vat_value,0)   - Nvl(:Old.local_vat_value,0) )
                    ,trans_group_value   = Nvl(trans_group_value,0)   + ( Nvl(:New.group_value,0)       - Nvl(:Old.group_value,0) )
                    ,trans_group_vat     = Nvl(trans_group_vat,0)     + ( Nvl(:New.group_vat_value,0)   - Nvl(:Old.group_vat_value,0) )
                    ,last_updated_by = 'SYSTEM'
              WHERE object_id = :New.object_id
                AND transaction_key = :New.transaction_key;

            END IF; -- monetary handling
          END IF;
      END IF;

      IF NOT UPDATING('LAST_UPDATED_BY') THEN
          :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      -- avoid increment during loading ???
      IF :New.last_updated_by = 'SYSTEM' THEN
         -- do not create new revision
         :New.last_updated_by := :Old.last_updated_by; -- set to old, assuming that this update is part of a sequence of updates
      ELSE
         :new.rev_no := :old.rev_no + 1;
      END IF;

      :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;

    END IF;  -- UPDATE section

EXCEPTION

		 WHEN no_uom THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'The quantity has no UOM for line item: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ') || '  ' || Nvl(:New.line_item_key,' ') ) ;

		 WHEN same_uom THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Same UOM found for one or more fields: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ') || '  ' || Nvl(:New.line_item_key,' ') ) ;

     WHEN no_monetary_upd THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Not able to update monetary value for master document: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.line_item_key,' ') ) ;

END;
