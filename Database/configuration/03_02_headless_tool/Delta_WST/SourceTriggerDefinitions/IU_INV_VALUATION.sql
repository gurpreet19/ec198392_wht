CREATE OR REPLACE EDITIONABLE TRIGGER "IU_INV_VALUATION" 
BEFORE INSERT OR UPDATE ON INV_VALUATION
FOR EACH ROW

DECLARE

locked_record EXCEPTION;
invalid_level_change EXCEPTION;
invalid_pay_date EXCEPTION;
invalid_exchange_rate EXCEPTION;
missing_uom EXCEPTION;
no_pay_date EXCEPTION;
no_fin_booking EXCEPTION;
invalid_booking_period EXCEPTION;

lv2_fin_booking VARCHAR(32);
lv2_user VARCHAR2(32);
lv2_4eye_validation_ind VARCHAR2(1);
ln_offset NUMBER;

ld_booking_period DATE;

TYPE t_status_list IS TABLE OF VARCHAR2(32);
ltab_status_list t_status_list;

BEGIN

   lv2_4eye_validation_ind := ec_ctrl_system_attribute.attribute_text(:new.daytime,'INV_4EYE_VALIDATION', '<=');

   -- to check whether to have 5-level / 2-user validation or not
   IF lv2_4eye_validation_ind = 'Y' THEN
       ltab_status_list := t_status_list('OPEN','VALID1','VALID2','TRANSFER','BOOKED');
       ln_offset := 1;
   ELSE
       ltab_status_list := t_status_list('OPEN','VALID1','TRANSFER','BOOKED');
       ln_offset := 0;
   END IF;

   IF Inserting THEN

      IF Inserting THEN
        :new.record_status := 'P';
        IF :new.created_by IS NULL THEN
           :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
        END IF;
        :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
        :new.rev_no := 0;

       END IF;

    ELSIF Updating THEN

        IF :New.last_updated_by = 'SYSTEM' THEN
           lv2_user := :Old.last_updated_by; -- set to old
        ELSE
           lv2_user := :New.last_updated_by; -- set to new
        END IF;

        -- to allow updating column from ecdp_sap_interface
        IF(NOT Updating('TRANSFER_DATE')) THEN


              IF NOT UPDATING('UL_AVG_RATE_STATUS') AND UPDATING('UL_AVG_RATE') AND :New.UL_AVG_RATE IS NOT NULL THEN
              --The rate has been updated from a screen

                :New.UL_AVG_RATE_STATUS := 'OW';

              END IF;

              IF NOT UPDATING('OL_AVG_PRICE_STATUS') AND UPDATING('OL_AVG_RATE') AND :New.OL_AVG_RATE IS NOT NULL THEN
              --The rate has been updated from a screen

                :New.OL_AVG_PRICE_STATUS := 'OW';

              END IF;

              IF NOT UPDATING('PS_AVG_RATE_STATUS') AND UPDATING('PS_AVG_RATE') AND :New.PS_AVG_RATE IS NOT NULL THEN
              --The physical stock rate has been updated from a screen

                :New.PS_AVG_RATE_STATUS := 'OW';

              END IF;


              IF Updating('SET_TO_NEXT_IND') AND :New.SET_TO_NEXT_IND = 'Y' AND Updating('SET_TO_PREV_IND') AND :New.SET_TO_PREV_IND = 'Y'THEN


                   RAISE invalid_level_change;



              ELSIF Updating('SET_TO_PREV_IND') AND :New.SET_TO_PREV_IND = 'Y' THEN

                  FOR ln_cnt IN 1..(ltab_status_list.COUNT) LOOP

                      IF ltab_status_list(ln_cnt) = :Old.document_level_code THEN

                          IF ln_cnt = 4 + ln_offset THEN -- special case for BOOKED

                              -- From BOOKED to OPEN
                              :New.document_level_code := ltab_status_list(1);

                              -- Reset processing data
                              :New.booked_user_id     := NULL;
							                :New.transfer_user_id   := NULL;
                              :New.valid1_user_id     := NULL;

                              IF lv2_4eye_validation_ind = 'Y' THEN
                                 :New.valid2_user_id := NULL;
                              END IF;

                              :New.set_to_booked_date := NULL;
							                -- :New.booking_date       := NULL; keep booking date as is, needed in reversal booking
							                :New.transfer_date      := NULL;

                              -- reverse booking
                              IF (ec_inventory_version.fin_booking_ind(:New.object_id,:New.daytime,'<=') = 'Y') OR (ec_ctrl_system_attribute.attribute_text(:New.daytime,'ALWAYS_GEN_POSTING','<=') = 'Y') THEN
                              		EcDp_Inventory.GenMthReversalBookingData(:New.object_id, :New.daytime, :New.last_updated_by);
							                END IF;

                           ELSIF ln_cnt = 3 + ln_offset THEN -- special case for TRANSFER

                              -- From TRANSFER to OPEN
                              :New.document_level_code := ltab_status_list(1);

                              -- Reset processing data
                              :New.booked_user_id     := NULL;
							                :New.transfer_user_id   := NULL;
                              :New.valid1_user_id     := NULL;

                              IF lv2_4eye_validation_ind = 'Y' THEN
                                 :New.valid2_user_id := NULL;
                              END IF;

                              :New.set_to_booked_date := NULL;
							                :New.booking_date       := NULL;
							                :New.transfer_date      := NULL;

                           ELSIF ln_cnt = 3 AND lv2_4eye_validation_ind = 'Y' THEN

                              -- From VALID2 to OPEN
                              :New.document_level_code := ltab_status_list(1);

							                -- Reset processing data
                              :New.booked_user_id     := NULL;
							                :New.transfer_user_id   := NULL;
							                :New.valid2_user_id     := NULL;
                              :New.valid1_user_id     := NULL;

                              :New.set_to_booked_date := NULL;
							                :New.booking_date       := NULL;
							                :New.transfer_date      := NULL;

                           ELSIF ln_cnt = 2 THEN

                              -- From VALID1 to OPEN
                              :New.document_level_code := ltab_status_list(1);

							                -- Reset processing data
                              :New.booked_user_id     := NULL;
                              :New.transfer_user_id   := NULL;
                              :New.valid2_user_id     := NULL;
                              :New.valid1_user_id     := NULL;

                              :New.set_to_booked_date := NULL;
                              :New.booking_date       := NULL;
                              :New.transfer_date      := NULL;

                           END IF;

                      END IF;

                  END LOOP;

                  -- reset, no need to store
                  :New.SET_TO_PREV_IND := NULL;

              ELSIF Updating('SET_TO_NEXT_IND') AND :New.SET_TO_NEXT_IND = 'Y' THEN

                  FOR ln_cnt IN 1..(ltab_status_list.COUNT) LOOP

                      IF ltab_status_list(ln_cnt) = :Old.document_level_code THEN

                         IF ln_cnt < ltab_status_list.COUNT THEN

                            :New.document_level_code := ltab_status_list(ln_cnt + 1);

                         END IF;

                      END IF;

                  END LOOP;

                  -- reset, no need to store
                  :New.SET_TO_NEXT_IND := NULL;

               END IF;



               -- correct level change ?
               IF Nvl(:Old.DOCUMENT_LEVEL_CODE,'XXX') <> Nvl(:New.DOCUMENT_LEVEL_CODE,'XXX') THEN

                      FOR ln_cnt IN 1..(ltab_status_list.COUNT) LOOP

                          IF ltab_status_list(ln_cnt) = :Old.document_level_code THEN

                             IF ln_cnt = 1 THEN

                                IF NOT ltab_status_list(ln_cnt + 1) = :New.document_level_code THEN

                                  RAISE invalid_level_change;

                                END IF;

                             ELSIF ln_cnt < ltab_status_list.COUNT THEN

                                IF  ( ltab_status_list(ln_cnt + 1) = :New.document_level_code )
                                    OR ( ltab_status_list(ln_cnt - 1) = :New.document_level_code )
                                    OR (ln_cnt <= 3 + ln_offset AND :New.document_level_code = ltab_status_list(1) ) THEN

                                    NULL; -- valid change

                                ELSE

                                   IF lv2_fin_booking = 'N' THEN

                                    NULL; -- valid

                                   ELSE
                                      RAISE invalid_level_change;

                                  END IF;

                                END IF;

                             ELSE

                                IF ln_cnt = 4 + ln_offset THEN

                                   NULL; --Correct for inventory

                                ELSE

                                    RAISE invalid_level_change; -- cannot change from highest

                                END IF;
                             END IF;

                          END IF;

                      END LOOP;

                     IF :New.DOCUMENT_LEVEL_CODE IN ('TRANSFER') THEN


                        -- Don't overwrite if booking_date already set.
                        IF :New.BOOKING_DATE IS NULL THEN

                            -- determine booking period
                               -- take current open period
                            ld_booking_period := EcDp_Fin_Period.GetCurrOpenPeriodByObject(:New.object_id, :New.daytime, 'INVENTORY');
                            --ec_company_version.country_id(ec_inventory_version.company_id(:New.object_id, :New.daytime, '<='), :New.daytime, '<='),
                            --ec_inventory_version.company_id(:New.object_id, :New.daytime, '<='),
                            --'INVENTORY'); -- object id should not matter here


                            -- set transfer to last date in open period if older
                            IF Trunc(Ecdp_Timestamp.getCurrentSysdate,'MM') >  ld_booking_period THEN

                                :New.BOOKING_DATE := Last_Day(ld_booking_period);

                            ELSIF (Trunc(Ecdp_Timestamp.getCurrentSysdate,'MM') <  ld_booking_period) THEN

                                :New.BOOKING_DATE := Trunc(ld_booking_period, 'MM');

                            ELSE

                                :New.BOOKING_DATE := Trunc(Ecdp_Timestamp.getCurrentSysdate);

                            END IF;

                        ELSIF :New.BOOKING_DATE < EcDp_Fin_Period.GetCurrOpenPeriodByObject(:New.object_id, :New.daytime, 'INVENTORY') THEN

                            RAISE invalid_booking_period;

                        END IF;


                       :New.transfer_user_id := lv2_user;
                       lv2_fin_booking := ec_inventory_version.fin_booking_ind(:new.object_id,:new.daytime,'<=');


                        IF lv2_fin_booking = 'N' THEN

                           -- move inv. directly to booked
                           :New.booked_user_id := lv2_user;
                           :New.document_level_code := 'BOOKED';

                        END IF;


                           -- perform booking from application rather (results in mutating trigger)
                           --EcDp_Inventory.GenMthBookingData(:New.object_id, :New.daytime, :New.last_updated_by);

                     ELSIF :New.DOCUMENT_LEVEL_CODE IN ('BOOKED') THEN

                            :New.booked_user_id := lv2_user;

                            :New.set_to_booked_date := Ecdp_Timestamp.getCurrentSysdate;

                     ELSIF :New.DOCUMENT_LEVEL_CODE IN ('VALID2') THEN

                            :New.valid2_user_id := lv2_user;

                     ELSIF :New.DOCUMENT_LEVEL_CODE IN ('VALID1') THEN

                           IF ec_ctrl_system_attribute.attribute_text(:New.daytime,'SELECT_BOOKING_PERIOD','<=') = 'Y' THEN
                              :New.booking_date := EcDp_Fin_Period.GetCurrOpenPeriodByObject(:New.object_id, :New.daytime, 'INVENTORY');
                           END IF;

                     END IF;



               END IF; -- level change

        END IF; -- ecdp_sap_interface

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

	-- Updating column for valid1_user_id
	IF  :New.DOCUMENT_LEVEL_CODE = 'VALID1' AND nvl(:Old.DOCUMENT_LEVEL_CODE ,'x') <> 'VALID1' THEN
		:New.valid1_user_id := :New.last_updated_by;
	END IF;


    ELSIF deleting THEN

         IF :New.DOCUMENT_LEVEL_CODE <> ltab_status_list(1) THEN

            RAISE locked_record;

         END IF;


     END IF;


EXCEPTION

    WHEN missing_uom THEN

    		RAISE_APPLICATION_ERROR(-20000,'Cannot complete operation due to missing UOM for: ' || Nvl( ec_inventory.object_code(:New.object_id), ' ') || '    ' || Nvl( ec_inventory_version.name(:New.object_id,:New.Daytime,'<='), ' ') ) ;

    WHEN invalid_exchange_rate THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Invalid exchange rate, cannot be negative for: ' || Nvl( ec_inventory.object_code(:New.object_id), ' ') || '    ' || Nvl( ec_inventory_version.name(:New.object_id,:New.Daytime,'<='), ' ') ) ;

     WHEN invalid_pay_date THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Invalid payment date, must be after document date for: ' || Nvl( ec_inventory.object_code(:New.object_id), ' ') || '    ' || Nvl( ec_inventory_version.name(:New.object_id,:New.Daytime,'<='), ' ') ) ;

     WHEN invalid_level_change THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Not a valid change of document levels for: ' || Nvl( ec_inventory.object_code(:New.object_id), ' ') || '    ' || Nvl( ec_inventory_version.name(:New.object_id,:New.Daytime,'<='), ' ') ) ;

	   WHEN locked_record THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Cannot change a document unless OPEN for: ' || Nvl( ec_inventory.object_code(:New.object_id), ' ') || '    ' || Nvl( ec_inventory_version.name(:New.object_id,:New.Daytime,'<='), ' ') ) ;

     WHEN no_fin_booking THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'The inventory: ' || Nvl( ec_inventory.object_code(:New.object_id), ' ') || '    ' || Nvl( ec_inventory_version.name(:New.object_id,:New.Daytime,'<='), ' ')||' is markt as non-bookable and have been moved to status "BOOKED" without transfer!' ) ;

     WHEN no_pay_date THEN

    		RAISE_APPLICATION_ERROR(-20000,'Cannot complete operation due to missing payment date for: ' || Nvl( ec_inventory.object_code(:New.object_id), ' ') || '    ' || Nvl( ec_inventory_version.name(:New.object_id,:New.Daytime,'<='), ' ') ) ;

     WHEN invalid_booking_period THEN

        RAISE_APPLICATION_ERROR(-20000,'Invalid booking period, the booking period in this inventory is closed for : ' || Nvl( ec_inventory.object_code(:New.object_id), ' ') || '    ' || Nvl( ec_inventory_version.name(:New.object_id,:New.Daytime,'<='), ' ') ) ;

END;
