CREATE OR REPLACE TRIGGER "IUD_V_METER_COMPOSITION" 
INSTEAD OF INSERT OR UPDATE OR DELETE ON V_METER_COMPOSITION
FOR EACH ROW

    -- $Revision: 1.3.4.2 $
	-- $Author: Kari Sandvik

DECLARE
    -- Variables for storing temporary values
    ln_analysis_no  NUMBER;
    lv_component_no VARCHAR2(16);

BEGIN
    IF UPDATING THEN
        ln_analysis_no  := :NEW.ANALYSIS_NO;
        lv_component_no := :NEW.COMPONENT_NO;

        IF (Nvl(:OLD.ANALYSIS_STATUS, 'XXX') <> Nvl(:NEW.ANALYSIS_STATUS, 'XXX')) THEN
            UPDATE object_fluid_analysis SET ANALYSIS_STATUS = :NEW.ANALYSIS_STATUS, last_updated_by = :NEW.last_updated_by WHERE analysis_no = ln_analysis_no;
        END IF;

        UPDATE object_fluid_analysis
        SET
            VALUE_1 =   :new.VALUE_1,
            VALUE_2 =   :new.VALUE_2,
            VALUE_3 =   :new.VALUE_3,
            VALUE_4 =   :new.VALUE_4,
            VALUE_5 =   :new.VALUE_5,
            VALUE_6 =   :new.VALUE_6,
            VALUE_7 =   :new.VALUE_7,
            VALUE_8 =   :new.VALUE_8,
            VALUE_9 =   :new.VALUE_9,
            VALUE_10 =  :new.VALUE_10,
            VALUE_11 =  :new.VALUE_11,
            VALUE_12 =  :new.VALUE_12,
            VALUE_13 =  :new.VALUE_13,
            VALUE_14 =  :new.VALUE_14,
            VALUE_15 =  :new.VALUE_15,
            VALUE_16 =  :new.VALUE_16,
            VALUE_17 =  :new.VALUE_17,
            VALUE_18 =  :new.VALUE_18,
            VALUE_19 =  :new.VALUE_19,
            VALUE_20 =  :new.VALUE_20,
            VALUE_21 =  :new.VALUE_21,
            VALUE_22 =  :new.VALUE_22,
            VALUE_23 =  :new.VALUE_23,
            VALUE_24 =  :new.VALUE_24,
            VALUE_25 =  :new.VALUE_25,
            VALUE_26 =  :new.VALUE_26,
            VALUE_27 =  :new.VALUE_27,
            VALUE_28 =  :new.VALUE_28,
            VALUE_29 =  :new.VALUE_29,
            VALUE_30 =  :new.VALUE_30,
            VALUE_31 =  :new.VALUE_31,
            VALUE_32 =  :new.VALUE_32,
            VALUE_33 =  :new.VALUE_33,
            VALUE_34 =  :new.VALUE_34,
            VALUE_35 =  :new.VALUE_35,
            VALUE_36 =  :new.VALUE_36,
            VALUE_37 =  :new.VALUE_37,
            VALUE_38 =  :new.VALUE_38,
            VALUE_39 =  :new.VALUE_39,
            VALUE_40 =  :new.VALUE_40,
            VALUE_41 =  :new.VALUE_41,
            VALUE_42 =  :new.VALUE_42,
            VALUE_43 =  :new.VALUE_43,
            VALUE_44 =  :new.VALUE_44,
            VALUE_45 =  :new.VALUE_45,
            VALUE_46 =  :new.VALUE_46,
            VALUE_47 =  :new.VALUE_47,
            TEXT_1 =    :new.TEXT_1,
            TEXT_2 =    :new.TEXT_2,
            TEXT_3 =    :new.TEXT_3,
            TEXT_4 =    :new.TEXT_4,
            TEXT_5 =    :new.TEXT_5,
            TEXT_6 =    :new.TEXT_6,
            TEXT_7 =    :new.TEXT_7,
            TEXT_8 =    :new.TEXT_8,
            TEXT_9 =    :new.TEXT_9,
            TEXT_10 =   :new.TEXT_10,
            TEXT_11 =   :new.TEXT_11,
            TEXT_12 =   :new.TEXT_12,
            TEXT_13 =   :new.TEXT_13,
            TEXT_14 =   :new.TEXT_14,
            TEXT_15 =   :new.TEXT_15,
            TEXT_16 =   :new.TEXT_16,
            TEXT_17 =   :new.TEXT_17,
            TEXT_18 =   :new.TEXT_18,
            TEXT_19 =   :new.TEXT_19,
            TEXT_20 =   :new.TEXT_20,
            TEXT_21 =   :new.TEXT_21,
            TEXT_22 =   :new.TEXT_22,
            TEXT_23 =   :new.TEXT_23,
            TEXT_24 =   :new.TEXT_24,
            TEXT_25 =   :new.TEXT_25,
            TEXT_26 =   :new.TEXT_26,
            TEXT_27 =   :new.TEXT_27,
            TEXT_28 =   :new.TEXT_28,
            TEXT_29 =   :new.TEXT_29,
            TEXT_30 =   :new.TEXT_30,
            TEXT_31 =   :new.TEXT_31,
            TEXT_32 =   :new.TEXT_32,
            TEXT_33 =   :new.TEXT_33,
            TEXT_34 =   :new.TEXT_34,
            TEXT_35 =   :new.TEXT_35,
            TEXT_36 =   :new.TEXT_36,
            TEXT_37 =   :new.TEXT_37,
            TEXT_38 =   :new.TEXT_38,
            TEXT_39 =   :new.TEXT_39,
            TEXT_40 =   :new.TEXT_40,
            TEXT_41 =   :new.TEXT_41,
            TEXT_42 =   :new.TEXT_42,
            DATE_1 =    :new.DATE_1,
            DATE_2 =    :new.DATE_2,
            DATE_3 =    :new.DATE_3,
            DATE_4 =    :new.DATE_4,
            DATE_5 =    :new.DATE_5,
            DATE_6 =    :new.DATE_6,
            DATE_7 =    :new.DATE_7,
            DATE_8 =    :new.DATE_8,
            DATE_9 =    :new.DATE_9,
            DATE_10 =   :new.DATE_10,
            DATE_11 =   :new.DATE_11,
            last_updated_by       = :NEW.last_updated_by,
            rev_no				  = :NEW.rev_no,
            rev_text              = :NEW.rev_text,
            last_updated_date     = :NEW.last_updated_date,
            record_status         = :NEW.record_status
        WHERE analysis_no = ln_analysis_no;

        -- Checking whether component record are updated
        IF (Nvl(:OLD.WT_PCT, 0) <> Nvl(:NEW.WT_PCT, 0)) THEN
            UPDATE fluid_analysis_component
               SET WT_PCT                = :NEW.WT_PCT,
                   MOL_PCT               = :NEW.MOL_PCT,
                   MOL_WT                = :NEW.MOL_WT,
                   VOL_PCT               = :NEW.VOL_PCT,
                   DENSITY               = :NEW.DENSITY,
                   MEAS_MOL_WT           = :NEW.MEAS_MOL_WT,
                   MEAS_SPECIFIC_GRAVITY = :NEW.MEAS_SPECIFIC_GRAVITY,
                   last_updated_by       = :NEW.last_updated_by,
                   rev_no				 = :NEW.rev_no,
                   rev_text              = :NEW.rev_text,
                   last_updated_date     = :NEW.last_updated_date,
                   record_status         = :NEW.record_status
             WHERE analysis_no = ln_analysis_no
               and component_no = lv_component_no;
         END IF;
    END IF;

    IF INSERTING THEN
        RAISE_APPLICATION_ERROR(-20560, 'Inserting not supported. Use instantiation or Meter Composition BF or class METER_COMP_ANALYSIS');
        NULL;
    END IF;

    IF DELETING THEN
        RAISE_APPLICATION_ERROR(-20561, 'Deleting not supported. Use Meter Composition BF or class METER_COMP_ANALYSIS');
    END IF;
END;

