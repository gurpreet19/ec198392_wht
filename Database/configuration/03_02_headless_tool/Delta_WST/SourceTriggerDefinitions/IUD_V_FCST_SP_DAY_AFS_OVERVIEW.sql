CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_FCST_SP_DAY_AFS_OVERVIEW" 
INSTEAD OF INSERT OR UPDATE OR DELETE ON V_FCST_SP_DAY_AFS_OVERVIEW
FOR EACH ROW

-- $Revision: 1.1.2.2 $
-- Common

DECLARE
    -- Variables for storing temporary values
    lv_object_id        VARCHAR2(32);
    lv_forecast_id      VARCHAR2(32);
    lv_daytime          DATE;
    lv_company_id       VARCHAR2(32);
    lv_transaction_type VARCHAR2(32);

BEGIN
    IF UPDATING THEN
        lv_object_id       := :NEW.OBJECT_ID;
        lv_forecast_id     := :NEW.FORECAST_ID;
        lv_daytime         := :NEW.DAYTIME;
        lv_company_id      := :NEW.COMPANY_ID;
        lv_transaction_type:= :NEW.TRANSACTION_TYPE;

        UPDATE FCST_SP_DAY_AFS SET
          VALUE_1           =  :new.VALUE_1,
          VALUE_2           =  :new.VALUE_2,
          VALUE_3           =  :new.VALUE_3,
          VALUE_4           =  :new.VALUE_4,
          VALUE_5           =  :new.VALUE_5,
          VALUE_6           =  :new.VALUE_6,
          VALUE_7           =  :new.VALUE_7,
          VALUE_8           =  :new.VALUE_8,
          VALUE_9           =  :new.VALUE_9,
          VALUE_10          =  :new.VALUE_10,
          VALUE_11          =  :new.VALUE_11,
          VALUE_12          =  :new.VALUE_12,
          VALUE_13          =  :new.VALUE_13,
          VALUE_14          =  :new.VALUE_14,
          VALUE_15          =  :new.VALUE_15,
          VALUE_16          =  :new.VALUE_16,
          VALUE_17          =  :new.VALUE_17,
          VALUE_18          =  :new.VALUE_18,
          VALUE_19          =  :new.VALUE_19,
          VALUE_20          =  :new.VALUE_20,
          VALUE_21          =  :new.VALUE_21,
          VALUE_22          =  :new.VALUE_22,
          VALUE_23          =  :new.VALUE_23,
          VALUE_24          =  :new.VALUE_24,
          VALUE_25          =  :new.VALUE_25,
          VALUE_26          =  :new.VALUE_26,
          VALUE_27          =  :new.VALUE_27,
          VALUE_28          =  :new.VALUE_28,
          VALUE_29          =  :new.VALUE_29,
          VALUE_30          =  :new.VALUE_30,
          TEXT_1            =  :new.TEXT_1,
          TEXT_2            =  :new.TEXT_2,
          TEXT_3            =  :new.TEXT_3,
          TEXT_4            =  :new.TEXT_4,
          TEXT_5            =  :new.TEXT_5,
          TEXT_6            =  :new.TEXT_6,
          TEXT_7            =  :new.TEXT_7,
          TEXT_8            =  :new.TEXT_8,
          TEXT_9            =  :new.TEXT_9,
          TEXT_10           =  :new.TEXT_10,
          TEXT_11           =  :new.TEXT_11,
          TEXT_12           =  :new.TEXT_12,
          TEXT_13           =  :new.TEXT_13,
          TEXT_14           =  :new.TEXT_14,
          TEXT_15           =  :new.TEXT_15,
          DATE_1            =  :new.DATE_1,
          DATE_2            =  :new.DATE_2,
          DATE_3            =  :new.DATE_3,
          DATE_4            =  :new.DATE_4,
          DATE_5            =  :new.DATE_5,
          LAST_UPDATED_BY   =  :NEW.last_updated_by,
          REV_NO	        =  :NEW.rev_no,
          REV_TEXT          =  :NEW.rev_text,
          LAST_UPDATED_DATE =  :NEW.last_updated_date,
          RECORD_STATUS     =  :NEW.record_status
        WHERE object_id        = lv_object_id
          AND forecast_id      = lv_forecast_id
          AND daytime          = lv_daytime
          AND transaction_type = lv_transaction_type;

        -- Check if ACTUAL_QTY is updated.
        IF Nvl(:OLD.ACTUAL_QTY, 0) <> Nvl(:NEW.ACTUAL_QTY, 0) THEN
          UPDATE FCST_SP_DAY_AFS SET
            ACTUAL_QTY        = :NEW.ACTUAL_QTY,
            LAST_UPDATED_BY   = :NEW.last_updated_by,
            REV_NO	          = :NEW.rev_no,
            REV_TEXT          = :NEW.rev_text,
            LAST_UPDATED_DATE = :NEW.last_updated_date,
            RECORD_STATUS     = :NEW.record_status
          WHERE object_id        = lv_object_id
            AND forecast_id      = lv_forecast_id
            AND daytime          = lv_daytime
            AND transaction_type = lv_transaction_type;
        END IF;

		-- Check if AVAIL_GRS_QTY is updated.
        IF Nvl(:OLD.AVAIL_GRS_QTY, 0) <> Nvl(:NEW.AVAIL_GRS_QTY, 0) THEN
          UPDATE FCST_SP_DAY_AFS SET
            AVAIL_GRS_QTY     = :NEW.AVAIL_GRS_QTY,
            LAST_UPDATED_BY   = :NEW.last_updated_by,
            REV_NO	          = :NEW.rev_no,
            REV_TEXT          = :NEW.rev_text,
            LAST_UPDATED_DATE = :NEW.last_updated_date,
            RECORD_STATUS     = :NEW.record_status
          WHERE object_id        = lv_object_id
            AND forecast_id      = lv_forecast_id
            AND daytime          = lv_daytime
            AND transaction_type = lv_transaction_type;
        END IF;

        -- Check if AVAIL_ADJ_QTY is updated.
        IF Nvl(:OLD.AVAIL_ADJ_QTY, 0) <> Nvl(:NEW.AVAIL_ADJ_QTY, 0) THEN
          UPDATE FCST_SP_DAY_AFS SET
            AVAIL_ADJ_QTY     = :NEW.AVAIL_ADJ_QTY,
            LAST_UPDATED_BY   = :NEW.last_updated_by,
            REV_NO	          = :NEW.rev_no,
            REV_TEXT          = :NEW.rev_text,
            LAST_UPDATED_DATE = :NEW.last_updated_date,
            RECORD_STATUS     = :NEW.record_status
          WHERE object_id        = lv_object_id
            AND forecast_id      = lv_forecast_id
            AND daytime          = lv_daytime
            AND transaction_type = lv_transaction_type;
        END IF;

		-- Check if AVAIL_NET_QTY is updated.
        IF Nvl(:OLD.AVAIL_NET_QTY, 0) <> Nvl(:NEW.AVAIL_NET_QTY, 0) THEN
          UPDATE FCST_SP_DAY_AFS SET
            AVAIL_NET_QTY     = :NEW.AVAIL_NET_QTY,
            LAST_UPDATED_BY   = :NEW.last_updated_by,
            REV_NO	          = :NEW.rev_no,
            REV_TEXT          = :NEW.rev_text,
            LAST_UPDATED_DATE = :NEW.last_updated_date,
            RECORD_STATUS     = :NEW.record_status
          WHERE object_id        = lv_object_id
            AND forecast_id      = lv_forecast_id
            AND daytime          = lv_daytime
            AND transaction_type = lv_transaction_type;
        END IF;

        -- Check if COMPANY_VALUE is updated.
        IF (Nvl(:OLD.COMPANY_VALUE, 0) <> Nvl(:NEW.COMPANY_VALUE, 0)) THEN
          UPDATE FCST_SP_DAY_CPY_AFS SET
            AVAIL_NET_QTY     = :NEW.COMPANY_VALUE,
            LAST_UPDATED_BY   = :NEW.last_updated_by,
            REV_NO	          = :NEW.rev_no,
            REV_TEXT          = :NEW.rev_text,
            LAST_UPDATED_DATE = :NEW.last_updated_date,
            RECORD_STATUS     = :NEW.record_status
          WHERE object_id        = lv_object_id
            AND forecast_id      = lv_forecast_id
            AND daytime          = lv_daytime
            AND company_id       = lv_company_id
            AND transaction_type = lv_transaction_type;
        END IF;
    END IF;

    IF INSERTING THEN
        RAISE_APPLICATION_ERROR(-20560, 'Insert not supported on V_FCST_SP_DAY_AFS_OVERVIEW.');
        NULL;
    END IF;

    IF DELETING THEN
        RAISE_APPLICATION_ERROR(-20561, 'Delete not supported on V_FCST_SP_DAY_AFS_OVERVIEW.');
    END IF;
END;
