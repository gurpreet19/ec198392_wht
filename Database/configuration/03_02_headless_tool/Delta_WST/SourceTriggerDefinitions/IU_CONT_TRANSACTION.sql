CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CONT_TRANSACTION" 
-- $Revision: 1.46 $
BEFORE INSERT OR UPDATE ON CONT_TRANSACTION
FOR EACH ROW


DECLARE

invalid_transaction_date EXCEPTION;
locked_record EXCEPTION;
invalid_price_date_range EXCEPTION;
missing_price_date EXCEPTION;
invalid_exchange_rate EXCEPTION;
invalid_trans_date_change EXCEPTION;
missing_transaction_date EXCEPTION;
missing_pc_date EXCEPTION;
missing_pr_date EXCEPTION;
missing_fx_date EXCEPTION;
invalid_supply_dates EXCEPTION;
invalid_pos_date EXCEPTION;

lv2_trans_date_method VARCHAR2(32);
lv2_found_cargo VARCHAR2(32) := NULL;
lv2_vat_code objects.code%TYPE;
lv2_vat_id objects.object_id%TYPE;

lv2_document_type VARCHAR2(200);
lv2_trans_date_type VARCHAR2(200);
ln_precision NUMBER := NVL(ec_ctrl_system_attribute.attribute_value(:NEW.DAYTIME, 'EX_VAT_PRECISION', '<='), 2);
lvat_precision NUMBER:=NVL(ec_ctrl_system_attribute.attribute_value(:NEW.DAYTIME, 'VAT_PRECISION', '<='), ln_precision); --This is used to round VAT calculated values

ld_pc_date DATE;
ld_contract_end_date DATE;

lv2_forex_date_ind VARCHAR2(10);
lv2_curr_source   VARCHAR2(32);
lv2_curr_duration VARCHAR2(10);
lv2_skip_ex_inv_pr_booking VARCHAR2(1) := 'N';
lv2_skip_ex_inv_pr_memo VARCHAR2(1) := 'N';
lv2_skip_ex_inv_bk_local VARCHAR2(1) := 'N';
lv2_skip_ex_inv_bk_group VARCHAR2(1) := 'N';

lrec_updating_row CONT_TRANSACTION%ROWTYPE;

TYPE t_ex_rec IS RECORD (
 ex_id         VARCHAR2(32), --forex id
 ex_code       VARCHAR2(32), --forex code
 ex_ts         VARCHAR2(32), --time scope
 ex_new_dbc    VARCHAR2(32), --new forex date base code
 ex_old_dbc    VARCHAR2(32), --old forex date base code
 ex_date       DATE,         --forex date
 ex_value      NUMBER,       --forex value
 ex_inv_value  NUMBER,       --forex inverted value
 from_curr_code VARCHAR2(32),--from currency code
 to_curr_code VARCHAR2(32),   --to currency code
 ex_ind        VARCHAR2(32) --insert/update indicator
);

TYPE t_ex IS TABLE OF t_ex_rec;

ltab_ex t_ex := t_ex();

lv2_booking_to_group_equal VARCHAR2(1) :=  NULL;

BEGIN

    IF Inserting OR Updating ('TRANSACTION_DATE') THEN

        IF :new.transaction_date < ec_contract.start_date(:new.object_id) THEN

            raise invalid_transaction_date;

        END IF;

    END IF;

    IF Inserting THEN

        :new.record_status := 'P';
        IF :new.created_by IS NULL THEN
            :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
        END IF;
        :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
        :new.rev_no := 0;

    ELSIF Updating THEN

        lv2_document_type := ec_cont_document.document_type(:New.document_key);

        ------------------------------------------------------------------------------------------
        -- perform inverse currency logic
        IF NVL(:Old.ex_pricing_booking,0) <> NVL(:New.ex_pricing_booking,0) THEN

            IF :New.ex_pricing_booking = 0 THEN

                RAISE invalid_exchange_rate;

            ELSE

                :New.ex_inv_pricing_booking := 1/:New.ex_pricing_booking;
                lv2_skip_ex_inv_pr_booking := 'Y';

            END IF;

        END IF;

        IF NVL(:Old.ex_pricing_memo,0) <> NVL(:New.ex_pricing_memo,0) THEN

            IF :New.ex_pricing_memo <= 0 THEN

                RAISE invalid_exchange_rate;

            ELSE

                :New.ex_inv_pricing_memo := 1/:New.ex_pricing_memo;
                lv2_skip_ex_inv_pr_memo := 'Y';

            END IF;

        END IF;

        IF NVL(:Old.ex_inv_pricing_booking,0) <> NVL(:New.ex_inv_pricing_booking,0)
        AND lv2_skip_ex_inv_pr_booking = 'N' THEN

            IF :New.ex_inv_pricing_booking <= 0 THEN

                RAISE invalid_exchange_rate;

            ELSE

                :New.ex_pricing_booking := 1/:New.ex_inv_pricing_booking;

            END IF;

        END IF;

        IF NVL(:Old.ex_inv_pricing_memo,0) <> NVL(:New.ex_inv_pricing_memo,0)
        AND lv2_skip_ex_inv_pr_memo = 'N' THEN

            IF :New.ex_inv_pricing_memo <= 0 THEN

                RAISE invalid_exchange_rate;

            ELSE

                :New.ex_pricing_memo := 1/:New.ex_inv_pricing_memo;

            END IF;

        END IF;

        IF NVL(:Old.ex_booking_local,0) <> NVL(:New.ex_booking_local,0) THEN

            IF :New.ex_booking_local <= 0 THEN

                RAISE invalid_exchange_rate;

            ELSE

                :New.ex_inv_booking_local := 1/:New.ex_booking_local;
                lv2_skip_ex_inv_bk_local := 'Y';

            END IF;

        END IF;

        IF NVL(:Old.ex_booking_group,0) <> NVL(:New.ex_booking_group,0) THEN

            IF :New.ex_booking_group <= 0 THEN

                RAISE invalid_exchange_rate;

            ELSE

                :New.ex_inv_booking_group := 1/:New.ex_booking_group;
                lv2_skip_ex_inv_bk_group := 'Y';

            END IF;

        END IF;

        IF NVL(:Old.ex_inv_booking_local,0) <> NVL(:New.ex_inv_booking_local,0)
          AND lv2_skip_ex_inv_bk_local = 'N' THEN

            IF :New.ex_inv_booking_local = 0 THEN

                RAISE invalid_exchange_rate;

            ELSE

                :New.ex_booking_local := 1/:New.ex_inv_booking_local;

            END IF;


        END IF;

        IF NVL(:Old.ex_inv_booking_group,0) <> NVL(:New.ex_inv_booking_group,0)
          AND lv2_skip_ex_inv_bk_group = 'N' THEN

            IF :New.ex_inv_booking_group <= 0 THEN

                RAISE invalid_exchange_rate;

            ELSE

                :New.ex_booking_group := 1/:New.ex_inv_booking_group;

            END IF;


        END IF;
        -- Skip date rules if reallocation, which gets all dates from preceding document.
        IF ec_cont_document.document_concept(:New.Document_Key) != 'REALLOCATION' THEN

            -- BL date logic
            IF :New.BL_DATE IS NULL THEN

                -- using the BL date base code to determine BL date
               IF :New.BL_DATE_BASE_CODE = 'LOADING_COMMENCED_DATE' THEN
                    :New.BL_DATE := :New.LOADING_DATE_COMMENCED;
                ELSIF :New.BL_DATE_BASE_CODE = 'LOADING_COMPLETED_DATE' THEN
                    :New.BL_DATE := :New.LOADING_DATE_COMPLETED;
                END IF;
            ELSE

                 -- using the BL date base code to determine to actual date
                IF :Old.BL_DATE_BASE_CODE = 'LOADING_COMMENCED_DATE' THEN
                  IF :New.LOADING_DATE_COMMENCED <> :Old.LOADING_DATE_COMMENCED OR :New.LOADING_DATE_COMMENCED IS NULL THEN
                     :New.BL_DATE := :New.LOADING_DATE_COMMENCED;
                  END IF;
                ELSIF :Old.BL_DATE_BASE_CODE = 'LOADING_COMPLETED_DATE' THEN
                  IF :New.LOADING_DATE_COMPLETED <> :Old.LOADING_DATE_COMPLETED OR :New.LOADING_DATE_COMPLETED IS NULL THEN
                     :New.BL_DATE := :New.LOADING_DATE_COMPLETED;
                  END IF;
                END IF;
            END IF;

            -- If this transaction is dependent to a preceding, do not use rules to set POS-Date, keep the date set in UpdFromPrecedingTrans
            IF :New.preceding_trans_key IS NULL THEN

                -- transaction date logic
                IF :New.TRANSACTION_DATE IS NULL THEN
                    lv2_trans_date_type := 'Point of Sale';

                    --by using the posd base code to determine to actual date
                    IF :New.POSD_BASE_CODE = 'SUPPLY_PERIOD_FROM_DATE' THEN
                        :New.TRANSACTION_DATE := :New.SUPPLY_FROM_DATE;
                        lv2_trans_date_type := 'Supply From';
                    ELSIF :New.POSD_BASE_CODE = 'SUPPLY_PERIOD_TO_DATE' THEN
                        :New.TRANSACTION_DATE := :New.SUPPLY_TO_DATE;
                        lv2_trans_date_type := 'Supply To';
                    ELSIF :New.POSD_BASE_CODE = 'LOADING_COMMENCED_DATE' THEN
                        :New.TRANSACTION_DATE := :New.LOADING_DATE_COMMENCED;
                        lv2_trans_date_type := 'Loading Commenced';
                    ELSIF :New.POSD_BASE_CODE = 'LOADING_COMPLETED_DATE' THEN
                        :New.TRANSACTION_DATE := :New.LOADING_DATE_COMPLETED;
                        lv2_trans_date_type := 'Loading Completed';
                    ELSIF :New.POSD_BASE_CODE = 'DELIVERY_COMMENCED_DATE' THEN
                        :New.TRANSACTION_DATE := :New.DELIVERY_DATE_COMMENCED;
                        lv2_trans_date_type := 'Delivery Commenced';
                    ELSIF :New.POSD_BASE_CODE = 'DELIVERY_COMPLETED_DATE' THEN
                        :New.TRANSACTION_DATE := :New.DELIVERY_DATE_COMPLETED;
                        lv2_trans_date_type := 'Delivery Completed';
                    ELSIF :New.POSD_BASE_CODE = 'BL_DATE' THEN
                        :New.TRANSACTION_DATE := :New.BL_DATE;
                        lv2_trans_date_type := 'Bill of Lading';
                    END IF;


                ELSE
                    ld_pc_date := NULL;

                     --by using the posd base code to determine to actual date
                    IF :Old.POSD_BASE_CODE = 'SUPPLY_PERIOD_FROM_DATE' THEN
                      lv2_trans_date_type := 'Supply From';
                      IF :New.SUPPLY_FROM_DATE <> :Old.SUPPLY_FROM_DATE OR :New.SUPPLY_FROM_DATE IS NULL THEN
                         :New.TRANSACTION_DATE := :New.SUPPLY_FROM_DATE;
                      END IF;
                    ELSIF :Old.POSD_BASE_CODE = 'SUPPLY_PERIOD_TO_DATE' THEN
                      lv2_trans_date_type := 'Supply To';
                      IF :New.SUPPLY_TO_DATE <> :Old.SUPPLY_TO_DATE OR :New.SUPPLY_TO_DATE IS NULL THEN
                         :New.TRANSACTION_DATE := :New.SUPPLY_TO_DATE;
                      END IF;
                    ELSIF :Old.POSD_BASE_CODE = 'LOADING_COMMENCED_DATE' THEN
                      lv2_trans_date_type := 'Loading Commenced';
                      IF :New.LOADING_DATE_COMMENCED <> :Old.LOADING_DATE_COMMENCED OR :New.LOADING_DATE_COMMENCED IS NULL THEN
                         :New.TRANSACTION_DATE := :New.LOADING_DATE_COMMENCED;
                      END IF;
                    ELSIF :Old.POSD_BASE_CODE = 'LOADING_COMPLETED_DATE' THEN
                      lv2_trans_date_type := 'Loading Completed';
                      IF :New.LOADING_DATE_COMPLETED <> :Old.LOADING_DATE_COMPLETED OR :New.LOADING_DATE_COMPLETED IS NULL THEN
                         :New.TRANSACTION_DATE := :New.LOADING_DATE_COMPLETED;
                      END IF;
                    ELSIF :Old.POSD_BASE_CODE = 'DELIVERY_COMMENCED_DATE' THEN
                      lv2_trans_date_type := 'Delivery Commenced';
                      IF :New.DELIVERY_DATE_COMMENCED <> :Old.DELIVERY_DATE_COMMENCED OR :New.DELIVERY_DATE_COMMENCED IS NULL THEN
                         :New.TRANSACTION_DATE := :New.DELIVERY_DATE_COMMENCED;
                      END IF;
                    ELSIF :Old.POSD_BASE_CODE = 'DELIVERY_COMPLETED_DATE' THEN
                      lv2_trans_date_type := 'Delivery Completed';
                      IF :New.DELIVERY_DATE_COMPLETED <> :Old.DELIVERY_DATE_COMPLETED OR :New.DELIVERY_DATE_COMPLETED IS NULL THEN
                         :New.TRANSACTION_DATE := :New.DELIVERY_DATE_COMPLETED;
                      END IF;
                    ELSIF :Old.POSD_BASE_CODE = 'BL_DATE' THEN
                      lv2_trans_date_type := 'Bill of Lading';
                      IF :New.BL_DATE <> :Old.BL_DATE OR :New.BL_DATE IS NULL THEN
                         :New.TRANSACTION_DATE := :New.BL_DATE;
                      END IF;
                    END IF;

                    IF :New.TRANSACTION_DATE IS NULL THEN
                       RAISE missing_pc_date;
                    END IF;

                    IF :New.TRANSACTION_DATE IS NOT NULL THEN

                        -- Determine VAT
                        if nvl(:new.vat_code,'xx') <> nvl(:old.vat_code,'xx') then
                          if :new.vat_code is null then
                             lv2_vat_code := ec_transaction_tmpl_version.vat_code_1(:new.trans_template_id, :new.transaction_date, '<=');
                          else
                             lv2_vat_code := :new.vat_code;
                          end if;
                          if NVL(lv2_vat_code,'xx') like 'UNDEFINED'  then
                            lv2_vat_code := null;
                          end if;

                          IF (lv2_vat_code IS NOT NULL) THEN
                             lv2_vat_id := ec_vat_code.object_id_by_uk(lv2_vat_code);
                          END IF;

                          :new.vat_code        := ec_vat_code.object_code(lv2_vat_id);
                          :new.vat_rate        := ec_vat_code_version.rate(lv2_vat_id,:new.transaction_date,'<=');
                          :new.vat_description := ec_vat_code_version.comments(lv2_vat_id,:new.transaction_date,'<=');
                          :new.vat_legal_text  := ec_vat_code_version.legal_text(lv2_vat_id,:new.transaction_date,'<=');
                        end if;

                  END IF;

                END IF;
            END IF; -- Preceding trans set?




             -- price date logic
            IF :New.PRICE_DATE IS NULL THEN
                lv2_trans_date_type := 'Price';

                --by using the posd base code to determine to actual date
                IF :New.PRICE_DATE_BASE_CODE = 'SUPPLY_PERIOD_FROM_DATE' THEN
                    :New.PRICE_DATE := :New.SUPPLY_FROM_DATE;
                    lv2_trans_date_type := 'Supply From';
                ELSIF :New.PRICE_DATE_BASE_CODE = 'SUPPLY_PERIOD_TO_DATE' THEN
                    :New.PRICE_DATE := :New.SUPPLY_TO_DATE;
                    lv2_trans_date_type := 'Supply To';
                ELSIF :New.PRICE_DATE_BASE_CODE = 'LOADING_COMMENCED_DATE' THEN
                    :New.PRICE_DATE := :New.LOADING_DATE_COMMENCED;
                    lv2_trans_date_type := 'Loading Commenced';
                ELSIF :New.PRICE_DATE_BASE_CODE = 'LOADING_COMPLETED_DATE' THEN
                    :New.PRICE_DATE := :New.LOADING_DATE_COMPLETED;
                    lv2_trans_date_type := 'Loading Completed';
                ELSIF :New.PRICE_DATE_BASE_CODE = 'DELIVERY_COMMENCED_DATE' THEN
                    :New.PRICE_DATE := :New.DELIVERY_DATE_COMMENCED;
                    lv2_trans_date_type := 'Delivery Commenced';
                ELSIF :New.PRICE_DATE_BASE_CODE = 'DELIVERY_COMPLETED_DATE' THEN
                    :New.PRICE_DATE := :New.DELIVERY_DATE_COMPLETED;
                    lv2_trans_date_type := 'Delivery Completed';
                ELSIF :New.PRICE_DATE_BASE_CODE = 'POINT_OF_SALE_DATE' THEN
                    :New.PRICE_DATE := :New.TRANSACTION_DATE;
                    lv2_trans_date_type := 'Point of Sale';
                ELSIF :New.PRICE_DATE_BASE_CODE = 'BL_DATE' THEN
                    :New.PRICE_DATE := :New.BL_DATE;
                    lv2_trans_date_type := 'Bill of Lading';
                END IF;
            ELSE
                ld_pc_date := NULL;

                 --by using the posd base code to determine to actual date
                IF :Old.PRICE_DATE_BASE_CODE = 'SUPPLY_PERIOD_FROM_DATE' THEN
                  lv2_trans_date_type := 'Supply From';
                  IF :New.SUPPLY_FROM_DATE <> :Old.SUPPLY_FROM_DATE OR :New.SUPPLY_FROM_DATE IS NULL THEN
                     :New.PRICE_DATE := :New.SUPPLY_FROM_DATE;
                  END IF;
                ELSIF :Old.PRICE_DATE_BASE_CODE = 'SUPPLY_PERIOD_TO_DATE' THEN
                  lv2_trans_date_type := 'Supply To';
                  IF :New.SUPPLY_TO_DATE <> :Old.SUPPLY_TO_DATE OR :New.SUPPLY_TO_DATE IS NULL THEN
                     :New.PRICE_DATE := :New.SUPPLY_TO_DATE;
                  END IF;
                ELSIF :Old.PRICE_DATE_BASE_CODE = 'LOADING_COMMENCED_DATE' THEN
                  lv2_trans_date_type := 'Loading Commenced';
                  IF :New.LOADING_DATE_COMMENCED <> :Old.LOADING_DATE_COMMENCED OR :New.LOADING_DATE_COMMENCED IS NULL THEN
                     :New.PRICE_DATE := :New.LOADING_DATE_COMMENCED;
                  END IF;
                ELSIF :Old.PRICE_DATE_BASE_CODE = 'LOADING_COMPLETED_DATE' THEN
                  lv2_trans_date_type := 'Loading Completed';
                  IF :New.LOADING_DATE_COMPLETED <> :Old.LOADING_DATE_COMPLETED OR :New.LOADING_DATE_COMPLETED IS NULL THEN
                     :New.PRICE_DATE := :New.LOADING_DATE_COMPLETED;
                  END IF;
                ELSIF :Old.PRICE_DATE_BASE_CODE = 'DELIVERY_COMMENCED_DATE' THEN
                  lv2_trans_date_type := 'Delivery Commenced';
                  IF :New.DELIVERY_DATE_COMMENCED <> :Old.DELIVERY_DATE_COMMENCED OR :New.DELIVERY_DATE_COMMENCED IS NULL THEN
                     :New.PRICE_DATE := :New.DELIVERY_DATE_COMMENCED;
                  END IF;
                ELSIF :Old.PRICE_DATE_BASE_CODE = 'DELIVERY_COMPLETED_DATE' THEN
                  lv2_trans_date_type := 'Delivery Completed';
                  IF :New.DELIVERY_DATE_COMPLETED <> :Old.DELIVERY_DATE_COMPLETED OR :New.DELIVERY_DATE_COMPLETED IS NULL THEN
                     :New.PRICE_DATE := :New.DELIVERY_DATE_COMPLETED;
                  END IF;
                ELSIF :Old.PRICE_DATE_BASE_CODE = 'POINT_OF_SALE_DATE' THEN
                  lv2_trans_date_type := 'Point of Sale';
                  IF :New.TRANSACTION_DATE <> :Old.TRANSACTION_DATE OR :New.TRANSACTION_DATE IS NULL THEN
                     :New.PRICE_DATE := :New.TRANSACTION_DATE;
                  END IF;
                ELSIF :Old.PRICE_DATE_BASE_CODE = 'BL_DATE' THEN
                  lv2_trans_date_type := 'Bill of Lading';
                  IF :New.BL_DATE <> :Old.BL_DATE OR :New.BL_DATE IS NULL THEN
                     :New.PRICE_DATE := :New.BL_DATE;
                  END IF;
                END IF;

                IF :New.PRICE_DATE IS NULL AND :New.PRICE_SRC_TYPE != 'PRICING_VALUE' THEN
                   RAISE missing_pr_date;
                END IF;
            END IF;


            -- transaction level forex date logic
            --pricing booking
            ltab_ex.extend;
            ltab_ex(ltab_ex.last).ex_id    := :New.EX_PRICING_BOOKING_ID;
            ltab_ex(ltab_ex.last).ex_code  := ec_forex_source.object_code(:New.EX_PRICING_BOOKING_ID);
            ltab_ex(ltab_ex.last).ex_ts    := :New.EX_PRICING_BOOKING_TS;
            ltab_ex(ltab_ex.last).ex_new_dbc   := :New.EX_PRICING_BOOKING_DBC;
            ltab_ex(ltab_ex.last).ex_old_dbc   := :Old.EX_PRICING_BOOKING_DBC;
            ltab_ex(ltab_ex.last).ex_date  := :Old.EX_PRICING_BOOKING_DATE;
            ltab_ex(ltab_ex.last).ex_value := null;
            ltab_ex(ltab_ex.last).from_curr_code := :New.PRICING_CURRENCY_CODE;
            ltab_ex(ltab_ex.last).to_curr_code := ec_cont_document.booking_currency_code(:NEW.DOCUMENT_KEY);

            --pricing memo
            ltab_ex.extend;
            ltab_ex(ltab_ex.last).ex_id    := :New.EX_PRICING_MEMO_ID;
            ltab_ex(ltab_ex.last).ex_code  := ec_forex_source.object_code(:New.EX_PRICING_MEMO_ID);
            ltab_ex(ltab_ex.last).ex_ts    := :New.EX_PRICING_MEMO_TS;
            ltab_ex(ltab_ex.last).ex_new_dbc   := :New.EX_PRICING_MEMO_DBC;
            ltab_ex(ltab_ex.last).ex_old_dbc   := :Old.EX_PRICING_MEMO_DBC;
            ltab_ex(ltab_ex.last).ex_date  := :Old.EX_PRICING_MEMO_DATE;
            ltab_ex(ltab_ex.last).ex_value := null;
            ltab_ex(ltab_ex.last).from_curr_code := :New.PRICING_CURRENCY_CODE;
            ltab_ex(ltab_ex.last).to_curr_code :=  ec_cont_document.memo_currency_code(:NEW.DOCUMENT_KEY);

            --booking local
            ltab_ex.extend;
            ltab_ex(ltab_ex.last).ex_id    := :New.EX_BOOKING_LOCAL_ID;
            ltab_ex(ltab_ex.last).ex_code  := ec_forex_source.object_code(:New.EX_BOOKING_LOCAL_ID);
            ltab_ex(ltab_ex.last).ex_ts    := :New.EX_BOOKING_LOCAL_TS;
            ltab_ex(ltab_ex.last).ex_new_dbc   := :New.EX_BOOKING_LOCAL_DBC;
            ltab_ex(ltab_ex.last).ex_old_dbc   := :Old.EX_BOOKING_LOCAL_DBC;
            ltab_ex(ltab_ex.last).ex_date  := :Old.EX_BOOKING_LOCAL_DATE;
            ltab_ex(ltab_ex.last).ex_value := null;
            ltab_ex(ltab_ex.last).from_curr_code := ec_cont_document.booking_currency_code(:New.DOCUMENT_KEY);
            ltab_ex(ltab_ex.last).to_curr_code := EcDp_Contract_Setup.GetLocalCurrencyCode(:NEW.OBJECT_ID, :New.DAYTIME);

            --booking group
            -- Checking if booking and group currencies are the same
            IF ec_cont_document.booking_currency_code(:New.DOCUMENT_KEY) = ec_ctrl_system_attribute.attribute_text(:NEW.daytime, 'GROUP_CURRENCY_CODE', '<=') THEN
               lv2_booking_to_group_equal := 'Y';
            END IF;

            ltab_ex.extend;
            ltab_ex(ltab_ex.last).ex_id    := :New.EX_BOOKING_GROUP_ID;
            ltab_ex(ltab_ex.last).ex_code  := ec_forex_source.object_code(:New.EX_BOOKING_GROUP_ID);
            ltab_ex(ltab_ex.last).ex_ts    := :New.EX_BOOKING_GROUP_TS;
            ltab_ex(ltab_ex.last).ex_new_dbc   := :New.EX_BOOKING_GROUP_DBC;
            ltab_ex(ltab_ex.last).ex_old_dbc   := :Old.EX_BOOKING_GROUP_DBC;
            ltab_ex(ltab_ex.last).ex_date  := :Old.EX_BOOKING_GROUP_DATE;
            ltab_ex(ltab_ex.last).ex_value := null;
            ltab_ex(ltab_ex.last).from_curr_code := ec_cont_document.booking_currency_code(:New.DOCUMENT_KEY);
            ltab_ex(ltab_ex.last).to_curr_code := ec_ctrl_system_attribute.attribute_text(:New.DAYTIME, 'GROUP_CURRENCY_CODE', '<=');

            FOR i IN 1..ltab_ex.count LOOP

            IF ltab_ex(i).EX_DATE IS NULL THEN

                lv2_trans_date_type := 'Point of Sale';

                --by using the posd base code to determine to actual date
                IF ltab_ex(i).EX_NEW_DBC = 'SUPPLY_PERIOD_FROM_DATE' THEN
                    ltab_ex(i).EX_DATE := :New.SUPPLY_FROM_DATE;
                    lv2_trans_date_type := 'Supply From';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'SUPPLY_PERIOD_TO_DATE' THEN
                    ltab_ex(i).EX_DATE := :New.SUPPLY_TO_DATE;
                    lv2_trans_date_type := 'Supply To';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'LOADING_COMMENCED_DATE' THEN
                    ltab_ex(i).EX_DATE := :New.LOADING_DATE_COMMENCED;
                    lv2_trans_date_type := 'Loading Commenced';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'LOADING_COMPLETED_DATE' THEN
                    ltab_ex(i).EX_DATE := :New.LOADING_DATE_COMPLETED;
                    lv2_trans_date_type := 'Loading Completed';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'DELIVERY_COMMENCED_DATE' THEN
                     ltab_ex(i).EX_DATE := :New.DELIVERY_DATE_COMMENCED;
                    lv2_trans_date_type := 'Delivery Commenced';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'DELIVERY_COMPLETED_DATE' THEN
                    ltab_ex(i).EX_DATE := :New.DELIVERY_DATE_COMPLETED;
                    lv2_trans_date_type := 'Delivery Completed';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'POINT_OF_SALE_DATE' THEN
                    ltab_ex(i).EX_DATE := :New.TRANSACTION_DATE;
                    lv2_trans_date_type := 'Point of Sale';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'BL_DATE' THEN
                    ltab_ex(i).EX_DATE := :New.BL_DATE;
                    lv2_trans_date_type := 'Bill of Lading';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'PRICE_DATE' THEN
                    ltab_ex(i).EX_DATE := :New.PRICE_DATE;
                    lv2_trans_date_type := 'Price Date';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'DOCUMENT_DATE' THEN
                    ltab_ex(i).EX_DATE := ec_cont_document.document_date(:New.DOCUMENT_KEY);
                    lv2_trans_date_type := 'Document Date';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'BOOKING_PERIOD_FIRST' THEN
                    ltab_ex(i).EX_DATE := ecdp_fin_period.getCurrOpenPeriodByObject(:New.OBJECT_ID, :NEW.DAYTIME, NULL, 'BOOKING');
                    lv2_trans_date_type := 'First Date of current Booking Period as Forex Date';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'BOOKING_PERIOD_LAST' THEN
                    ltab_ex(i).EX_DATE := Last_Day(ecdp_fin_period.getCurrOpenPeriodByObject(:New.OBJECT_ID, :NEW.DAYTIME, NULL, 'BOOKING'));
                    lv2_trans_date_type := 'Last Date of current Booking Period as Forex Date';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'POSD_PLUS_1MTH' THEN
                    ltab_ex(i).EX_DATE := add_months(:New.TRANSACTION_DATE,1);
                    lv2_trans_date_type := 'Point of Sale plus 1 mth';
                    ltab_ex(i).EX_IND := 'INSERT';
                ELSIF ltab_ex(i).EX_NEW_DBC = 'POSD_MINUS_1MTH' THEN
                    ltab_ex(i).EX_DATE := add_months(:New.TRANSACTION_DATE,-1);
                    lv2_trans_date_type := 'Point of Sale minus 1 mth';
                    ltab_ex(i).EX_IND := 'INSERT';
                END IF;

            ELSE
                ld_pc_date := NULL;

                 --by using the posd base code to determine to actual date
                IF ltab_ex(i).EX_OLD_DBC = 'SUPPLY_PERIOD_FROM_DATE' THEN
                  lv2_trans_date_type := 'Supply From';
                  IF :New.SUPPLY_FROM_DATE <> :Old.SUPPLY_FROM_DATE OR :New.SUPPLY_FROM_DATE IS NULL THEN
                     ltab_ex(i).EX_DATE := :New.SUPPLY_FROM_DATE;
                     ltab_ex(i).EX_IND := 'UPDATE';
                  END IF;
                ELSIF ltab_ex(i).EX_OLD_DBC = 'SUPPLY_PERIOD_TO_DATE' THEN
                  lv2_trans_date_type := 'Supply To';
                  IF :New.SUPPLY_TO_DATE <> :Old.SUPPLY_TO_DATE OR :New.SUPPLY_TO_DATE IS NULL THEN
                     ltab_ex(i).EX_DATE := :New.SUPPLY_TO_DATE;
                     ltab_ex(i).EX_IND := 'UPDATE';
                  END IF;
                ELSIF ltab_ex(i).EX_OLD_DBC = 'LOADING_COMMENCED_DATE' THEN
                  lv2_trans_date_type := 'Loading Commenced';
                  IF :New.LOADING_DATE_COMMENCED <> :Old.LOADING_DATE_COMMENCED OR :New.LOADING_DATE_COMMENCED IS NULL THEN
                     ltab_ex(i).EX_DATE := :New.LOADING_DATE_COMMENCED;
                     ltab_ex(i).EX_IND := 'UPDATE';
                  END IF;
                ELSIF ltab_ex(i).EX_OLD_DBC = 'LOADING_COMPLETED_DATE' THEN
                  lv2_trans_date_type := 'Loading Completed';
                  IF :New.LOADING_DATE_COMPLETED <> :Old.LOADING_DATE_COMPLETED OR :New.LOADING_DATE_COMPLETED IS NULL THEN
                     ltab_ex(i).EX_DATE := :New.LOADING_DATE_COMPLETED;
                     ltab_ex(i).EX_IND := 'UPDATE';
                  END IF;
                ELSIF ltab_ex(i).EX_OLD_DBC = 'DELIVERY_COMMENCED_DATE' THEN
                  lv2_trans_date_type := 'Delivery Commenced';
                  IF :New.DELIVERY_DATE_COMMENCED <> :Old.DELIVERY_DATE_COMMENCED OR :New.DELIVERY_DATE_COMMENCED IS NULL THEN
                     ltab_ex(i).EX_DATE := :New.DELIVERY_DATE_COMMENCED;
                     ltab_ex(i).EX_IND := 'UPDATE';
                  END IF;
                ELSIF ltab_ex(i).EX_OLD_DBC = 'DELIVERY_COMPLETED_DATE' THEN
                  lv2_trans_date_type := 'Delivery Completed';
                  IF :New.DELIVERY_DATE_COMPLETED <> :Old.DELIVERY_DATE_COMPLETED OR :New.DELIVERY_DATE_COMPLETED IS NULL THEN
                     ltab_ex(i).EX_DATE := :New.DELIVERY_DATE_COMPLETED;
                     ltab_ex(i).EX_IND := 'UPDATE';
                  END IF;
                ELSIF ltab_ex(i).EX_OLD_DBC = 'POINT_OF_SALE_DATE' THEN
                  lv2_trans_date_type := 'Point of Sale';
                  IF :New.TRANSACTION_DATE <> :Old.TRANSACTION_DATE OR :New.TRANSACTION_DATE IS NULL THEN
                     ltab_ex(i).EX_DATE := :New.TRANSACTION_DATE;
                     ltab_ex(i).EX_IND := 'UPDATE';
                  END IF;
                ELSIF ltab_ex(i).EX_OLD_DBC = 'BL_DATE' THEN
                  lv2_trans_date_type := 'Bill of Lading';
                  IF :New.BL_DATE <> :Old.BL_DATE OR :New.BL_DATE IS NULL THEN
                     ltab_ex(i).EX_DATE := :New.BL_DATE;
                     ltab_ex(i).EX_IND := 'UPDATE';
                  END IF;
                ELSIF ltab_ex(i).EX_OLD_DBC = 'PRICE_DATE' THEN
                  lv2_trans_date_type := 'Price Date';
                  IF :New.PRICE_DATE <> :Old.PRICE_DATE OR :New.PRICE_DATE IS NULL THEN
                     ltab_ex(i).EX_DATE := :New.PRICE_DATE;
                     ltab_ex(i).EX_IND := 'UPDATE';
                  END IF;
                ELSIF ltab_ex(i).EX_OLD_DBC = 'POSD_PLUS_1MTH' THEN
                  lv2_trans_date_type := 'Point of Sale plus 1 mth';
                  IF :New.PRICE_DATE <> :Old.PRICE_DATE OR :New.PRICE_DATE IS NULL THEN
                     ltab_ex(i).EX_DATE := add_months(:New.TRANSACTION_DATE,1);
                     ltab_ex(i).EX_IND := 'UPDATE';
                  END IF;
                  ELSIF ltab_ex(i).EX_OLD_DBC = 'POSD_MINUS_1MTH' THEN
                  lv2_trans_date_type := 'Point of Sale minus 1 mth';
                  IF :New.PRICE_DATE <> :Old.PRICE_DATE OR :New.PRICE_DATE IS NULL THEN
                     ltab_ex(i).EX_DATE := add_months(:New.TRANSACTION_DATE,-1);
                     ltab_ex(i).EX_IND := 'UPDATE';
                  END IF;
                END IF;

            END IF;

                --if forex date is updated from dependent date, update the ex rates
            IF ltab_ex(i).EX_IND = 'INSERT' THEN

               lv2_curr_source   := ltab_ex(i).EX_ID;
               lv2_curr_duration := ltab_ex(i).EX_TS;  --no longer defaults to 'DAY' since we have forex time scope

               ltab_ex(i).EX_DATE := ecdp_currency.GetforexdateViaCurrency(
               :New.pricing_currency_code, -- pricing currency
               ec_cont_document.booking_currency_code(:NEW.DOCUMENT_KEY), -- booking currency
               ec_cont_document.memo_currency_code(:NEW.DOCUMENT_KEY), -- memo currency
               ltab_ex(i).EX_DATE,
               lv2_curr_source,
               lv2_curr_duration);

               ltab_ex(i).EX_VALUE         := ecdp_currency.GetExRateViaCurrency(ltab_ex(i).FROM_CURR_CODE,ltab_ex(i).TO_CURR_CODE,null,ltab_ex(i).EX_DATE,lv2_curr_source,lv2_curr_duration);
               ltab_ex(i).EX_INV_VALUE     := ecdp_currency.GetExRateViaCurrency(ltab_ex(i).TO_CURR_CODE,ltab_ex(i).FROM_CURR_CODE,null,ltab_ex(i).EX_DATE,lv2_curr_source,lv2_curr_duration);

            ELSIF ltab_ex(i).EX_IND = 'UPDATE' THEN

               lv2_curr_source   := ltab_ex(i).EX_ID;
               lv2_curr_duration := ltab_ex(i).EX_TS;  --no longer defaults to 'DAY' since we have forex time scope

               ltab_ex(i).EX_DATE := ecdp_currency.GetforexdateViaCurrency(
               :New.pricing_currency_code, -- pricing currency
               ec_cont_document.booking_currency_code(:NEW.DOCUMENT_KEY), -- booking currency
               ec_cont_document.memo_currency_code(:NEW.DOCUMENT_KEY), -- memo currency
               ltab_ex(i).EX_DATE,
               lv2_curr_source,
               lv2_curr_duration);

               ltab_ex(i).EX_VALUE         := ecdp_currency.GetExRateViaCurrency(ltab_ex(i).FROM_CURR_CODE,ltab_ex(i).TO_CURR_CODE,null,ltab_ex(i).EX_DATE,lv2_curr_source,lv2_curr_duration);
               ltab_ex(i).EX_INV_VALUE     := ecdp_currency.GetExRateViaCurrency(ltab_ex(i).TO_CURR_CODE,ltab_ex(i).FROM_CURR_CODE,null,ltab_ex(i).EX_DATE,lv2_curr_source,lv2_curr_duration);

            END IF;

         END LOOP;


        IF ltab_ex(1).EX_IND IS NOT NULL THEN
            :New.EX_PRICING_BOOKING_DATE := nvl(ltab_ex(1).EX_DATE,:New.EX_PRICING_BOOKING_DATE);
            :New.EX_PRICING_BOOKING := nvl(ltab_ex(1).EX_VALUE,:New.EX_PRICING_BOOKING);
            :New.EX_INV_PRICING_BOOKING := nvl(ltab_ex(1).EX_INV_VALUE,:New.EX_INV_PRICING_BOOKING);
        ELSIF (ltab_ex(1).FROM_CURR_CODE = ltab_ex(1).TO_CURR_CODE) AND (:Old.EX_PRICING_BOOKING is null AND :Old.EX_INV_PRICING_BOOKING is null) THEN
            :New.EX_PRICING_BOOKING     := 1;
            :New.EX_INV_PRICING_BOOKING := 1;
        END IF;

        IF ltab_ex(2).EX_IND IS NOT NULL THEN
            :New.EX_PRICING_MEMO_DATE := nvl(ltab_ex(2).EX_DATE,:New.EX_PRICING_MEMO_DATE);
            :New.EX_PRICING_MEMO := nvl(ltab_ex(2).EX_VALUE,:New.EX_PRICING_MEMO);
            :New.EX_INV_PRICING_MEMO := nvl(ltab_ex(2).EX_INV_VALUE,:New.EX_INV_PRICING_MEMO);
        ELSIF ltab_ex(2).FROM_CURR_CODE = ltab_ex(2).TO_CURR_CODE AND (:Old.EX_PRICING_MEMO is null AND :Old.EX_INV_PRICING_MEMO is null) THEN
            :New.EX_PRICING_MEMO     := 1;
            :New.EX_INV_PRICING_MEMO := 1;
        END IF;

        IF ltab_ex(3).EX_IND IS NOT NULL THEN
            :New.EX_BOOKING_LOCAL_DATE := nvl(ltab_ex(3).EX_DATE,:New.EX_BOOKING_LOCAL_DATE);
            :New.EX_BOOKING_LOCAL := nvl(ltab_ex(3).EX_VALUE,:New.EX_BOOKING_LOCAL);
            :New.EX_INV_BOOKING_LOCAL := nvl(ltab_ex(3).EX_INV_VALUE,:New.EX_INV_BOOKING_LOCAL);
        ELSIF ltab_ex(3).FROM_CURR_CODE = ltab_ex(3).TO_CURR_CODE AND (:Old.EX_BOOKING_LOCAL is null AND :Old.EX_INV_BOOKING_LOCAL is null) THEN
            :New.EX_BOOKING_LOCAL     := 1;
            :New.EX_INV_BOOKING_LOCAL := 1;
        END IF;

        IF ltab_ex(4).EX_IND IS NOT NULL THEN
            :New.EX_BOOKING_GROUP_DATE := nvl(ltab_ex(4).EX_DATE,:New.EX_BOOKING_GROUP_DATE);
            :New.EX_BOOKING_GROUP := nvl(ltab_ex(4).EX_VALUE,:New.EX_BOOKING_GROUP);
            :New.EX_INV_BOOKING_GROUP := nvl(ltab_ex(4).EX_INV_VALUE,:New.EX_INV_BOOKING_GROUP);
        ELSIF ltab_ex(4).FROM_CURR_CODE = ltab_ex(4).TO_CURR_CODE AND (:Old.EX_BOOKING_GROUP is null AND :Old.EX_INV_BOOKING_GROUP is null) THEN
            :New.EX_BOOKING_GROUP     := 1;
            :New.EX_INV_BOOKING_GROUP := 1;
        END IF;

        END IF; -- Not a reallocation document


        -- check that any change of transaction_date is within same month
        IF :Old.transaction_date IS NOT NULL AND

            Trunc(:Old.transaction_date, 'MM') <> Trunc(:New.transaction_date, 'MM') THEN

            RAISE invalid_trans_date_change;

        END IF;


        IF :New.PRICING_PERIOD_FROM_DATE IS NOT NULL THEN

            IF :New.PRICING_PERIOD_TO_DATE IS NULL THEN

                RAISE missing_price_date;

            END IF;

        ELSIF :New.PRICING_PERIOD_TO_DATE IS NOT NULL THEN

            IF :New.PRICING_PERIOD_FROM_DATE IS NULL THEN

                RAISE missing_price_date;

            END IF;

        ELSIF :New.PRICING_PERIOD_FROM_DATE IS NOT NULL AND :New.PRICING_PERIOD_TO_DATE IS NOT NULL THEN

            IF :New.PRICING_PERIOD_FROM_DATE > :New.PRICING_PERIOD_TO_DATE THEN

                RAISE invalid_price_date_range;

            END IF;

        END IF;
        ------------------------------------------------------------------------------------------
        -- perform dependent Trans calculations
        IF ec_ctrl_system_attribute.attribute_text(:New.DAYTIME,'VAT_ON_ACCRUALS','<=') = 'N' AND ec_cont_document.status_code(:New.Document_Key)='ACCRUAL' THEN
           :New.vat_code := NULL;
           :New.vat_rate := 0;
        END IF;

        -- Retrieve VAT_CODE and VAT_RATE (typical after accrual)
        IF ec_cont_document.status_code(:New.Document_Key)='FINAL' AND :New.vat_code IS NULL THEN
           :New.vat_code := EcDp_Transaction.GetTransVatCode(:New.transaction_key, :New.trans_template_id, :New.daytime);
           :New.vat_rate := ec_vat_code_version.rate(ecdp_objects.GetObjIDFromCode('VAT_CODE', :New.vat_code), :New.daytime, '<=');
        END IF;

        IF Updating('QTY_PRICING_VALUE') OR Updating('QTY_OTHER_VALUE') OR Updating('QTY_BOOKING_VALUE') THEN

            -- perform dependent LIV calculations
            IF (lv2_document_type NOT LIKE '%MASTER%') THEN

                :New.qty_pricing_vat   := Round(:New.qty_pricing_vat,lvat_precision);
                :New.qty_memo_vat      := Round(:New.qty_memo_vat,lvat_precision);
                :New.qty_booking_vat   := Round(:New.qty_booking_vat,lvat_precision);

                :New.qty_pricing_total := Round((:New.qty_pricing_value + Nvl(:New.qty_pricing_vat,0)),ln_precision);
                :New.qty_memo_total    := Round((:New.qty_memo_value + Nvl(:New.qty_memo_vat,0)),ln_precision);
                :New.qty_booking_total := Round((:New.qty_booking_value + Nvl(:New.qty_booking_vat,0)),ln_precision);
            END IF;

        END IF;

        IF Updating('OTHER_PRICING_VALUE') OR Updating('OTHER_OTHER_VALUE') OR Updating('OTHER_BOOKING_VALUE') THEN

            -- perform dependent LIV calculations
            IF (lv2_document_type NOT LIKE '%MASTER%') THEN
                :New.other_pricing_vat   := Round(:New.other_pricing_vat,lvat_precision);
                :New.other_memo_vat      := Round(:New.other_memo_vat,lvat_precision);
                :New.other_booking_vat   := Round(:New.other_booking_vat,lvat_precision);

                :New.other_pricing_total := Round((:New.other_pricing_value + Nvl(:New.other_pricing_vat,0)),ln_precision);
                :New.other_memo_total    := Round((:New.other_memo_value + Nvl(:New.other_memo_vat,0)),ln_precision);
                :New.other_booking_total := Round((:New.other_booking_value + Nvl(:New.other_booking_vat,0)),ln_precision);
            END IF;

        END IF;

        IF Updating('TRANS_PRICING_VALUE') OR Updating('TRANS_OTHER_VALUE') OR Updating('TRANS_BOOKING_VALUE') THEN

            -- perform dependent LIV calculations
            IF (lv2_document_type NOT LIKE '%MASTER%') THEN

                :New.trans_pricing_vat   := Round(:New.trans_pricing_vat,lvat_precision);
                :New.trans_memo_vat      := Round(:New.trans_memo_vat,lvat_precision);
                :New.trans_booking_vat   := Round(:New.trans_booking_vat,lvat_precision);
                :New.trans_local_vat     := Round(:New.trans_local_vat,lvat_precision);
                :New.trans_group_vat     := Round(:New.trans_group_vat,lvat_precision);


                :New.trans_pricing_total := Round((:New.trans_pricing_value + Nvl(:New.trans_pricing_vat,0)),ln_precision);
                :New.trans_memo_total    := Round((:New.trans_memo_value + Nvl(:New.trans_memo_vat,0)),ln_precision);
                :New.trans_booking_total := Round((:New.trans_booking_value + Nvl(:New.trans_booking_vat,0)),ln_precision);
                :New.trans_local_total   := Round((:New.trans_local_value + Nvl(:New.trans_local_vat,0)),ln_precision);
                :New.trans_group_total   := Round((:New.trans_group_value + Nvl(:New.trans_group_vat,0)),ln_precision);
            END IF;

            -- perform document total updates
            UPDATE cont_document SET
                 doc_memo_value        = Nvl(doc_memo_value,0)        + ( Nvl(:New.trans_memo_value,0) - Nvl(:Old.trans_memo_value,0) )
                ,doc_memo_vat          = Nvl(doc_memo_vat,0)          + ( Nvl(:New.trans_memo_vat,0) - Nvl(:Old.trans_memo_vat,0) )
                ,doc_memo_total        = Nvl(doc_memo_total,0)        + ( Nvl(:New.trans_memo_total,0) - Nvl(:Old.trans_memo_total,0) )
                ,doc_booking_value     = Nvl(doc_booking_value,0)     + ( Nvl(:New.trans_booking_value,0) - Nvl(:Old.trans_booking_value,0) )
                ,doc_booking_vat       = Nvl(doc_booking_vat,0)       + ( Nvl(:New.trans_booking_vat,0) - Nvl(:Old.trans_booking_vat,0) )
                ,doc_booking_total     = Nvl(doc_booking_total,0)     + ( Nvl(:New.trans_booking_total,0) - Nvl(:Old.trans_booking_total,0) )
                ,doc_local_value       = Nvl(doc_local_value,0)       + ( Nvl(:New.trans_local_value,0) - Nvl(:Old.trans_local_value,0) )
                ,doc_local_vat         = Nvl(doc_local_vat,0)         + ( Nvl(:New.trans_local_vat,0) - Nvl(:Old.trans_local_vat,0) )
                ,doc_local_total       = Nvl(doc_local_total,0)       + ( Nvl(:New.trans_local_total,0) - Nvl(:Old.trans_local_total,0) )
                ,doc_group_value       = Nvl(doc_group_value,0)       + ( Nvl(:New.trans_group_value,0) - Nvl(:Old.trans_group_value,0) )
                ,doc_group_vat         = Nvl(doc_group_vat,0)         + ( Nvl(:New.trans_group_vat,0) - Nvl(:Old.trans_group_vat,0) )
                ,doc_group_total       = Nvl(doc_group_total,0)       + ( Nvl(:New.trans_group_total,0) - Nvl(:Old.trans_group_total,0) )
                ,last_updated_by = :New.last_updated_by
            WHERE object_id = :New.object_id
            AND document_key = :New.document_key;

        ELSIF Updating('TRANS_PRICING_VAT')  THEN

            -- perform dependent LIV calculations
            IF (lv2_document_type NOT LIKE '%MASTER%' AND  NOT Updating('TRANS_PRICING_TOTAL')) THEN

                :New.trans_pricing_vat   := Round(:New.trans_pricing_vat,lvat_precision);
                :New.trans_memo_vat      := Round(:New.trans_memo_vat,lvat_precision);
                :New.trans_booking_vat   := Round(:New.trans_booking_vat,lvat_precision);
                :New.trans_local_vat     := Round(:New.trans_local_vat,lvat_precision);
                :New.trans_group_vat     := Round(:New.trans_group_vat,lvat_precision);


                :New.trans_pricing_total := Round((:New.trans_pricing_value + Nvl(:New.trans_pricing_vat,0)),ln_precision);

                :New.trans_memo_total    := Round((:New.trans_memo_value + Nvl(:New.trans_memo_vat,0)),ln_precision);
                :New.trans_booking_total := Round((:New.trans_booking_value + Nvl(:New.trans_booking_vat,0)),ln_precision);
                :New.trans_local_total   := Round((:New.trans_local_value + Nvl(:New.trans_local_vat,0)),ln_precision);
                :New.trans_group_total   := Round((:New.trans_group_value + Nvl(:New.trans_group_vat,0)),ln_precision);
            END IF;

            -- perform document total updates
            UPDATE cont_document SET
                 doc_memo_value        = Nvl(doc_memo_value,0)        + ( Nvl(:New.trans_memo_value,0) - Nvl(:Old.trans_memo_value,0) )
                ,doc_memo_vat          = Nvl(doc_memo_vat,0)          + ( Nvl(:New.trans_memo_vat,0) - Nvl(:Old.trans_memo_vat,0) )
                ,doc_memo_total        = Nvl(doc_memo_total,0)        + ( Nvl(:New.trans_memo_total,0) - Nvl(:Old.trans_memo_total,0) )
                ,doc_booking_value     = Nvl(doc_booking_value,0)     + ( Nvl(:New.trans_booking_value,0) - Nvl(:Old.trans_booking_value,0) )
                ,doc_booking_vat       = Nvl(doc_booking_vat,0)       + ( Nvl(:New.trans_booking_vat,0) - Nvl(:Old.trans_booking_vat,0) )
                ,doc_booking_total     = Nvl(doc_booking_total,0)     + ( Nvl(:New.trans_booking_total,0) - Nvl(:Old.trans_booking_total,0) )
                ,doc_local_value       = Nvl(doc_local_value,0)       + ( Nvl(:New.trans_local_value,0) - Nvl(:Old.trans_local_value,0) )
                ,doc_local_vat         = Nvl(doc_local_vat,0)         + ( Nvl(:New.trans_local_vat,0) - Nvl(:Old.trans_local_vat,0) )
                ,doc_local_total       = Nvl(doc_local_total,0)       + ( Nvl(:New.trans_local_total,0) - Nvl(:Old.trans_local_total,0) )
                ,doc_group_value       = Nvl(doc_group_value,0)       + ( Nvl(:New.trans_group_value,0) - Nvl(:Old.trans_group_value,0) )
                ,doc_group_vat         = Nvl(doc_group_vat,0)         + ( Nvl(:New.trans_group_vat,0) - Nvl(:Old.trans_group_vat,0) )
                ,doc_group_total       = Nvl(doc_group_total,0)       + ( Nvl(:New.trans_group_total,0) - Nvl(:Old.trans_group_total,0) )
                ,last_updated_by = :New.last_updated_by
            WHERE object_id = :New.object_id
            AND document_key = :New.document_key;

        END IF;

        IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
        END IF;

        -- avoid increment
        IF :New.last_updated_by = 'SYSTEM' THEN
            -- do not create new revision
            :New.last_updated_by := :Old.last_updated_by; -- set to old, assuming that this update is part of a sequence of updates
        ELSE
            :new.rev_no := :old.rev_no + 1;
        END IF;

        :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;

  END IF;


  -- Validate Supply Dates vs. contract end date if this is a Period Contract
  ld_contract_end_date := NVL(ec_contract.end_date(:New.object_id), to_date('2100-01-01','YYYY-MM-DD'));
  IF :New.transaction_scope = 'PERIOD_BASED' THEN

    IF :New.Supply_from_date IS NOT NULL AND :New.Supply_to_date IS NOT NULL THEN

      IF ld_contract_end_date < :New.Supply_from_date OR
         ld_contract_end_date < :New.Supply_to_date THEN

        RAISE invalid_supply_dates;

      END IF;
    END IF;
  END IF;

  -- Validate POS Date vs. contract end date
  IF :New.Transaction_Date IS NOT NULL THEN
    IF ld_contract_end_date < :New.Transaction_Date THEN

      RAISE invalid_pos_date;

    END IF;
  END IF;


  /*
     Some class-relations for class cont_transaction uses columns that persists both id and code in the table.
     this makes sure the code column us populated in addition to the id column
  */

  IF Inserting OR Updating ('DELIVERY_POINT_ID') THEN

        IF :new.delivery_point_id IS NULL THEN
           :new.delivery_point_code := NULL;

           ELSIF :new.delivery_point_id IS NOT NULL THEN
                 :new.delivery_point_code := ec_delivery_point.object_code(:new.delivery_point_id);
        END IF;
   END IF;

   IF Inserting OR Updating ('ENTRY_POINT_ID') THEN

        IF :new.entry_point_id IS NULL THEN
           :new.entry_point_code := NULL;

           ELSIF :new.entry_point_id IS NOT NULL THEN
                 :new.entry_point_code := ec_delivery_point.object_code(:new.entry_point_id);
        END IF;
   END IF;

   IF Inserting OR Updating ('LOADING_PORT_ID') THEN

        IF :new.loading_port_id IS NULL THEN
           :new.loading_port_code := NULL;

           ELSIF :new.loading_port_id IS NOT NULL THEN
                 :new.loading_port_code := ec_port.object_code(:new.loading_port_id);
        END IF;
   END IF;

   IF Inserting OR Updating ('DISCHARGE_PORT_ID') THEN

        IF :new.discharge_port_id IS NULL THEN
           :new.discharge_port_code := NULL;

           ELSIF :new.discharge_port_id IS NOT NULL THEN
                 :new.discharge_port_code := ec_port.object_code(:new.discharge_port_id);
        END IF;
   END IF;

   IF Inserting OR Updating ('DELIVERY_PLANT_ID') THEN

        IF :new.delivery_plant_id IS NULL THEN
           :new.delivery_plant_code := NULL;

           ELSIF :new.delivery_plant_id IS NOT NULL THEN
                 :new.delivery_plant_code := ec_delivery_point.object_code(:new.delivery_plant_id);
        END IF;
   END IF;

   IF Inserting OR Updating ('CARRIER_ID') THEN

        IF :new.carrier_id IS NULL THEN
           :new.carrier_code := NULL;

           ELSIF :new.carrier_id IS NOT NULL THEN
                 :new.carrier_code := ec_carrier.object_code(:new.carrier_id);
        END IF;
   END IF;

   IF Inserting OR Updating ('DESTINATION_COUNTRY_ID') THEN

        IF :new.DESTINATION_COUNTRY_ID IS NULL THEN
           :new.DESTINATION_COUNTRY_CODE := NULL;

           ELSIF :new.DESTINATION_COUNTRY_ID IS NOT NULL THEN
                 :new.DESTINATION_COUNTRY_CODE := ec_geographical_area.object_code(:new.DESTINATION_COUNTRY_ID);
        END IF;
   END IF;

   IF Inserting OR Updating ('ORIGIN_COUNTRY_ID') THEN

        IF :new.origin_country_id IS NULL THEN
           :new.origin_country_code := NULL;

           ELSIF :new.origin_country_id IS NOT NULL THEN
                 :new.origin_country_code := ec_geographical_area.object_code(:new.origin_country_id);
        END IF;
   END IF;


   /*
     Handling cargo and parcel which might come from an external source.
     TODO: Should tbl cargo_transport be used for foreign key on cargo_no?
           In that case, should the cargo_no be totally independent of cargo_name (cargo_transport vs. ifac_cargo_value?
  */
  IF Inserting OR Updating ('CARGO_NAME') THEN

        IF :new.cargo_name IS NULL THEN
           :new.cargo_no := NULL;

           UPDATE ifac_cargo_value
              SET transaction_key   = NULL,
                  trans_key_set_ind = 'N',
                  last_updated_by   = 'SYSTEM'
            WHERE transaction_key = nvl(:new.transaction_key, 'XXX');

        ELSIF :new.cargo_name IS NOT NULL THEN

                IF (:new.cargo_no IS NOT NULL AND ec_cargo_transport.row_by_pk(:new.cargo_no).cargo_no IS NULL) THEN
                   :new.cargo_no := NULL;

                   UPDATE ifac_cargo_value
                      SET transaction_key   = NULL,
                          trans_key_set_ind = 'N',
                          last_updated_by   = 'SYSTEM'
                    WHERE transaction_key = nvl(:new.transaction_key, 'XXX');

                END IF;
        END IF;
   END IF;






   IF Inserting OR Updating ('PARCEL_NAME') THEN

        IF :new.parcel_name IS NULL THEN
           :new.parcel_no := NULL;

        END IF;
   END IF;


   IF :new.reversal_ind = 'N' THEN
      IF Inserting OR Updating ('PRICE_OBJECT_ID')
        OR Updating('PRODUCT_ID') OR Updating('price_concept_code')
        OR Updating('DELIVERY_POINT_ID') OR Updating('DAYTIME')
        OR Updating('QTY_TYPE')  OR Updating('DISCHARGE_PORT_ID') THEN
         -- construct a template row record containing
         -- new values of the updating row
         -- not all values are copied, add them when needed
         lrec_updating_row.OBJECT_ID := :NEW.OBJECT_ID;
         lrec_updating_row.DAYTIME := :NEW.DAYTIME;
         lrec_updating_row.TRANSACTION_KEY := :NEW.TRANSACTION_KEY;
         lrec_updating_row.DOCUMENT_KEY := :NEW.DOCUMENT_KEY;
         lrec_updating_row.TRANS_TEMPLATE_ID := :NEW.TRANS_TEMPLATE_ID;
         lrec_updating_row.PRODUCT_ID := :NEW.PRODUCT_ID;
         lrec_updating_row.PRICE_OBJECT_ID := :NEW.PRICE_OBJECT_ID;
         lrec_updating_row.PRICE_CONCEPT_CODE := :NEW.PRICE_CONCEPT_CODE;
         lrec_updating_row.DELIVERY_POINT_ID := :NEW.DELIVERY_POINT_ID;
         lrec_updating_row.QTY_TYPE := :NEW.QTY_TYPE;
         lrec_updating_row.DISCHARGE_PORT_ID := :NEW.DISCHARGE_PORT_ID;
         -- Use the old transaction name here
         lrec_updating_row.NAME := :OLD.NAME;


      END IF;
   END IF;
EXCEPTION

     WHEN invalid_transaction_date THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Point of Sale Date entered is before the Contract Valid From Date: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.transaction_key,' ') ) ;

     WHEN missing_price_date THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Both pricing period from date and to date must be set for contract: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.transaction_key,' ') ) ;

     WHEN invalid_price_date_range THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Pricing period from date must come before to date for contract: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.transaction_key,' ') ) ;

	   WHEN locked_record THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Cannot update transaction when document is locked for contract: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.transaction_key,' ') ) ;

     WHEN invalid_exchange_rate THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Cannot update transaction with invalid exchange rate for contract: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.transaction_key,' ') ) ;

     WHEN invalid_trans_date_change THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Cannot change point of sales date to a date in another month. Only possibility to change to another month is to delete document and recreate. Contract: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.transaction_key,' ') ) ;

     WHEN missing_transaction_date THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Please enter ' || lv2_trans_date_type || ' Date to get correct Point of Sale Date. Contract: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.transaction_key,' ') ) ;

     WHEN missing_pc_date THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Point of Sale Date is NULL. Please enter ' || lv2_trans_date_type || ' Date. Contract: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.transaction_key,' ') ) ;

     WHEN missing_pr_date THEN

        RAISE_APPLICATION_ERROR(-20000,'Price Date is NULL. Please enter ' || lv2_trans_date_type || ' Date. Contract: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.transaction_key,' ') ) ;

     WHEN missing_fx_date THEN

        RAISE_APPLICATION_ERROR(-20000,'Forex Date is NULL. Please enter ' || lv2_trans_date_type || ' Date. Contract: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.transaction_key,' ') ) ;

     WHEN invalid_supply_dates THEN

        RAISE_APPLICATION_ERROR(-20000, 'Supply From and To Dates can not be after contract end date (' || ld_contract_end_date || ')');

     WHEN invalid_pos_date THEN

        RAISE_APPLICATION_ERROR(-20000, 'Point Of Sale Date can not be after Contract End Date (' || ld_contract_end_date || ') ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.transaction_key,' '));
END;
