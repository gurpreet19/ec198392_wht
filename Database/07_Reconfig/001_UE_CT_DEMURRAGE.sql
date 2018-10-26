create or replace PACKAGE UE_CT_DEMURRAGE
/****************************************************************
** Package        :  UE_CT_DEMURRAGE
**
** $Revision: 1.0 $
**
** Purpose        : Contains logic for demurrage calculations
**
** Documentation  :
**
** Created  : 04.09.2013  swgn
**
** Modification history:
**
** Date          Whom             Change description:
** ------        --------         --------------------------------------
** 04-sep-2013   swgn             Initial version
*****************************************************************/
IS

FUNCTION GetDemurrageActivityCode(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_start_end VARCHAR2) RETURN VARCHAR2;

FUNCTION GetDemurrageAllowance(p_cargo_no NUMBER, p_demurrage_type VARCHAR2) RETURN NUMBER;

FUNCTION GetDemurrageExtension(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_actual VARCHAR2 DEFAULT 'N', p_extension_number NUMBER DEFAULT 1) RETURN NUMBER;

FUNCTION GetDemurrage(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN NUMBER;

FUNCTION GetDemurrageRate(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN NUMBER;

FUNCTION GetCurrencyUnit(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN VARCHAR2;

FUNCTION GetJDEAccountCode(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN VARCHAR2;

PROCEDURE auCargoTransport(p_cargo_no NUMBER, p_old_cargo_status VARCHAR2, p_new_cargo_status VARCHAR2, p_updated_by VARCHAR2);

FUNCTION getWorksheetLayout(p_demurrage_type VARCHAR2) RETURN CLOB;

FUNCTION getWarningStatus(p_cargo_no NUMBER, p_demurrage_type VARCHAR2) RETURN VARCHAR2;

FUNCTION cargoHasDemurrage(p_cargo_no NUMBER) RETURN VARCHAR2;

END UE_CT_DEMURRAGE;
/

create or replace PACKAGE BODY UE_CT_DEMURRAGE
/****************************************************************
** Package        :  UE_CT_DEMURRAGE
**
** $Revision: 1.0 $
**
** Purpose        : Contains logic for demurrage calculations
**
** Documentation  :
**
** Created  : 04.09.2013  swgn
**
** Modification history:
**
** Date          Whom             Change description:
** ------        --------         --------------------------------------
** 04-sep-2013   swgn             Initial version
*****************************************************************/
IS

FUNCTION GetDemurrageActivityCode(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_start_end VARCHAR2) RETURN VARCHAR2
IS

    CURSOR timeline_items IS
    SELECT activity_code
    FROM tv_prod_lift_activity_code
    WHERE start_date <= ue_ct_leadtime.getfirstnomdatetime(p_cargo_no)
    AND nvl(end_date, to_date('01-JAN-2100', 'DD-MON-YYYY')) > ue_ct_leadtime.getfirstnomdatetime(p_cargo_no)
    AND product_id = ec_product.object_id_by_uk(DECODE(p_demurrage_type, 'EBO', 'LNG', 'DEMURRAGE', 'LNG', 'COND_EBO', 'COND', 'COND_DEMURRAGE', 'COND', 'LNG_CARGO_TIME','LNG', 'COND_CARGO_TIME','COND','LNG'))
    AND (
            (p_demurrage_type LIKE '%EBO%' AND ebc_boundary = p_start_end)
         OR (p_demurrage_type LIKE '%DEMURRAGE%' AND demurrage_boundary = p_start_end)
		 OR (p_demurrage_type LIKE '%CARGO_TIME%' AND DUES_boundary = p_start_end)
    );

    v_return_value VARCHAR2(32);

BEGIN

    FOR item IN timeline_items LOOP
        v_return_value := item.activity_code;
    END LOOP;

    RETURN v_return_value;

END GetDemurrageActivityCode;

FUNCTION GetDemurrageAllowance(p_cargo_no NUMBER, p_demurrage_type VARCHAR2) RETURN NUMBER
IS
BEGIN

    IF p_demurrage_type = 'DEMURRAGE' THEN
        RETURN 24 / 24;
    ELSIF p_demurrage_type = 'EBO' THEN
        RETURN 24 / 24;
    ELSIF p_demurrage_type = 'COND_DEMURRAGE' THEN
        RETURN 36 / 24;
    ELSIF p_demurrage_type = 'COND_EBO' THEN
        RETURN 2 / 24;
    ELSE
        RETURN 0 / 24;
    END IF;

END GetDemurrageAllowance;

FUNCTION GetCoolPurgeExtension(p_cargo_no NUMBER, p_demurrage_type VARCHAR2) RETURN NUMBER
IS
    v_cool_purge_time NUMBER := 0;
BEGIN

    -- Any cooling/purging time?
    SELECT SUM(NVL(LOAD_VALUE, 0)) INTO v_cool_purge_time
    FROM dv_storage_lifting
    WHERE parcel_no IN
    (
        SELECT x.parcel_no
        FROM storage_lift_nomination x
        WHERE x.cargo_no = p_cargo_no
    )
    AND product_meas_no IN
    (
        SELECT y.product_meas_no
        FROM dv_prod_meas_setup y
        WHERE y.object_code = 'LNG'
        AND y.meas_item IN ('PURGE_HRS','COOL_HRS','COOL_VOL_HRS_NC')
        AND y.lifting_event = 'LOAD'
    );

    RETURN ROUND(v_cool_purge_time, 2) / 24;
END GetCoolPurgeExtension;

FUNCTION GetOverTimeExtension(p_cargo_no NUMBER, p_demurrage_type VARCHAR2) RETURN NUMBER
IS
    v_volume NUMBER;
    v_over_time NUMBER := 0;
BEGIN

    -- Capoacity over?
    SELECT SUM(NVL(LOAD_VALUE, 0)) INTO v_volume
    FROM dv_storage_lifting
    WHERE parcel_no IN
    (
        SELECT x.parcel_no
        FROM storage_lift_nomination x
        WHERE x.cargo_no = p_cargo_no
    )
    AND product_meas_no IN
    (
        SELECT y.product_meas_no
        FROM dv_prod_meas_setup y
        WHERE y.object_code = 'LNG'
        AND y.meas_item IN ('LIFT_NET_M3')
        AND y.lifting_event = 'LOAD'
    );

    IF v_volume > 146000 THEN
        v_over_time := (v_volume - 146000) / 12000;
    END IF;

    RETURN ROUND(v_over_time, 2) / 24;

END GetOverTimeExtension;

FUNCTION GetLowRateExtension(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_product_code VARCHAR2) RETURN NUMBER
IS

    CURSOR run_nos IS
    SELECT DISTINCT run_no, lifting_event
    FROM lifting_activity
    WHERE cargo_no = p_cargo_no;

    v_loading_start_code VARCHAR2(32);
    v_loading_end_code VARCHAR2(32);

    v_loading_time NUMBER := 0;
    v_loading_volume NUMBER := 0;
    v_arm_count NUMBER := 1;
    v_return_value NUMBER := 0;
BEGIN

    SELECT activity_code INTO v_loading_start_code FROM LIFTING_ACTIVITY_CODE WHERE text_4 = 'LOAD_START' AND product_id = ec_product.object_id_by_uk(p_product_code);
    SELECT activity_code INTO v_loading_end_code FROM LIFTING_ACTIVITY_CODE WHERE text_4 = 'LOAD_END' AND product_id = ec_product.object_id_by_uk(p_product_code);

    FOR runs IN run_nos LOOP
        v_loading_time := v_loading_time + NVL(EC_Lifting_Activity.to_daytime(p_cargo_no, v_loading_end_code, runs.run_no, runs.lifting_event),
                                               EC_Lifting_Activity.from_daytime(p_cargo_no, v_loading_end_code, runs.run_no,runs.lifting_event))
                                         - EC_Lifting_Activity.from_daytime(p_cargo_no, v_loading_start_code, runs.run_no,runs.lifting_event);
    END LOOP;

    SELECT SUM(NVL(LOAD_VALUE, 0)) INTO v_loading_volume
    FROM dv_storage_lifting
    WHERE parcel_no IN
    (
        SELECT x.parcel_no
        FROM storage_lift_nomination x
        WHERE x.cargo_no = p_cargo_no
    )
    AND product_meas_no IN
    (
        SELECT y.product_meas_no
        FROM dv_prod_meas_setup y
        WHERE y.object_code = 'COND'
        AND y.meas_item IN ('LIFT_COND_VOL_GRS')
        AND y.lifting_event = 'LOAD'
    );

    v_arm_count := NVL(ec_cargo_transport.value_2(p_cargo_no), 1);

    --tlxt: 15-JUL-2015: 99904: this equation is in the context of DAY, hence hourly calculation needs to be divided by "24"
	--v_return_value := v_loading_time - (v_loading_volume / (2500 * v_arm_count));
	v_return_value := v_loading_time - (v_loading_volume / (2500 * v_arm_count))/24;

    IF v_return_value > 0 THEN
        RETURN v_return_value;
    ELSE
        RETURN 0;
    END IF;
END GetLowRateExtension;

FUNCTION GetDelays(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_delay_type VARCHAR2 DEFAULT 'LAYTIME') RETURN NUMBER
IS

    CURSOR delays IS
    SELECT to_daytime - from_daytime as elapsed_time, lifting_event
    FROM dv_cargo_lifting_delay
    WHERE ((p_demurrage_type LIKE '%EBO%' AND reason_code = 'SHORE') OR (p_demurrage_type LIKE '%DEMURRAGE%' AND reason_code = 'SHIP'))
    AND from_daytime >= ec_lifting_activity.from_daytime(p_cargo_no, GetDemurrageActivityCode(p_cargo_no, p_demurrage_type, 'START'), 1, lifting_event)
    AND to_daytime <= ec_lifting_activity.from_daytime(p_cargo_no, GetDemurrageActivityCode(p_cargo_no, p_demurrage_type, 'END'), 1, lifting_event);

    CURSOR delays_to_berth IS
    SELECT to_daytime - from_daytime as elapsed_time
    FROM dv_cargo_lifting_delay
    WHERE ((p_demurrage_type LIKE '%EBO%' AND reason_code = 'SHIP') OR (p_demurrage_type LIKE '%DEMURRAGE%' AND reason_code = 'SHORE'))
    AND from_daytime >= CASE WHEN ec_lifting_activity.from_daytime(p_cargo_no, 'LNG_NOR_EFFECTIVE', 1,lifting_event) > nvl(ec_cargo_transport.DATE_1(p_cargo_no), ue_ct_cargo_info.getprat(p_cargo_no))
                             THEN ec_lifting_activity.from_daytime(p_cargo_no, 'LNG_NOR_EFFECTIVE', 1, lifting_event)
                             ELSE nvl(ec_cargo_transport.DATE_1(p_cargo_no), ue_ct_cargo_info.getprat(p_cargo_no)) END
    AND to_daytime <= ec_lifting_activity.from_daytime(p_cargo_no, 'LNG_FIRST_LINE', 1,lifting_event);

    v_return_value NUMBER := 0;
BEGIN

    IF p_delay_type = 'LAYTIME' THEN -- Delays between start and end of laytime
        FOR item IN delays LOOP
            v_return_value := v_return_value + item.elapsed_time;
        END LOOP;
    END IF;

    IF p_delay_type = 'TO_BERTH' THEN -- Delays between NOR/RAT and first line
        FOR item IN delays_to_berth LOOP
            v_return_value := v_return_value + item.elapsed_time;
        END LOOP;
    END IF;

    RETURN v_return_value;
END GetDelays;

FUNCTION GetDemurrageExtension(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_actual VARCHAR2 DEFAULT 'N', p_extension_number NUMBER DEFAULT 1) RETURN NUMBER
IS
BEGIN

    IF p_demurrage_type IN ('EBO','DEMURRAGE') THEN

        IF p_actual = 'N' THEN
            IF p_extension_number = 1 THEN
                RETURN GetOverTimeExtension(p_cargo_no, p_demurrage_type);
            ELSIF p_extension_number = 2 THEN
                RETURN GetCoolPurgeExtension(p_cargo_no, p_demurrage_type);
            ELSE
                RETURN GetDelays(p_cargo_no, p_demurrage_type);
            END IF;
        ELSE
            IF p_extension_number = 1 THEN
                RETURN GetDelays(p_cargo_no, p_demurrage_type, 'TO_BERTH');
            ELSE
                RETURN 0;
            END IF;
        END IF;

    ELSIF p_demurrage_type IN ('COND_DEMURRAGE','COND_EBO') THEN

        IF p_demurrage_type = 'COND_EBO' THEN
			IF p_actual = 'N' THEN
				--TLXT 15-JUL-2015: 99904: to handle COND_EBO with extension 3: Excess Berth is Shore delay
				IF p_extension_number = 3 THEN
					--RETURN 0;
					RETURN GetDelays(p_cargo_no, p_demurrage_type);
					--end edit
				END IF;
			ELSE
				RETURN 0;
			END IF;
        ELSE
            IF p_actual = 'N' THEN
                IF p_extension_number = 1 THEN
                    RETURN GetLowRateExtension(p_cargo_no, p_demurrage_type, 'COND');
                ELSIF p_extension_number = 2 THEN
                    RETURN 0;
                ELSE
                    RETURN GetDelays(p_cargo_no, p_demurrage_type);
                END IF;
            ELSE
                RETURN 0;
            END IF;
        END IF;

    END IF;

    RETURN 0;

END GetDemurrageExtension;

FUNCTION GetDemurrageExtensionReasons(p_cargo_no NUMBER, p_demurrage_type VARCHAR2) RETURN VARCHAR2
IS
    v_cool_purge_time NUMBER := GetCoolPurgeExtension(p_cargo_no, p_demurrage_type);
    v_over_time NUMBER := GetOverTimeExtension(p_cargo_no, p_demurrage_type);
    v_response VARCHAR2(20000) := '';
    v_comma VARCHAR2(1) := 'N';
BEGIN
    IF v_cool_purge_time > 0 THEN
        IF v_comma = 'Y' THEN
            v_response := v_response || ', ';
        ELSE
            v_comma := 'Y';
        END IF;
        v_response := v_response || 'Purging/Cooling';
    END IF;

    IF v_over_time > 0 THEN
        IF v_comma = 'Y' THEN
            v_response := v_response || ', ';
        ELSE
            v_comma := 'Y';
        END IF;
        v_response := v_response || 'Capacity Overtime';
    END IF;

    RETURN v_response;
END GetDemurrageExtensionReasons;

FUNCTION GetDemurrage(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN NUMBER
IS
    CURSOR demurrage_row IS
    SELECT accepted_laytime, allot_extension_1, allot_extension_2, allot_extension_3, minus_laytime, manual_adjustment
    FROM dv_demurrage
    WHERE cargo_no = p_cargo_no
    AND demurrage_type = p_demurrage_type
    AND lifting_event = p_lifting_event;

    v_result NUMBER := 0;
BEGIN
    -- SELECT * FROM DV_DEMURRAGE
    FOR item IN demurrage_row LOOP
        v_result := item.minus_laytime - NVL(item.allot_extension_1, 0) - NVL(item.allot_extension_2, 0) - NVL(item.allot_extension_3, 0) - item.accepted_laytime - NVL(item.manual_adjustment, 0);
    END LOOP;

    IF v_result < 0 THEN
        v_result := 0;
    END IF;

    RETURN v_result;

END GetDemurrage;

FUNCTION GetDemurrageRate(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN NUMBER
IS
    CURSOR harbour_due_units(cp_start_date DATE) IS
    SELECT unit_cost
    FROM tv_harbour_dues
    WHERE start_date <= cp_start_date
    AND nvl(end_date, cp_start_date + 1) > cp_start_date
    AND demurrage_type = p_demurrage_type;

    p_return_value NUMBER;
BEGIN

    FOR item IN harbour_due_units(ue_ct_leadtime.getFirstNomDateTime(p_cargo_no)) LOOP
        p_return_value := item.unit_cost;
    END LOOP;

    RETURN p_return_value;

END GetDemurrageRate;

FUNCTION GetCurrencyUnit(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN VARCHAR2
IS
BEGIN

    IF p_demurrage_type IN ('EBO','DEMURRAGE') THEN
        RETURN ec_harbour_dues.text_7('LNG_EBC');
    ELSIF p_demurrage_type IN ('COND_EBO','COND_DEMURRAGE') THEN
        RETURN ec_harbour_dues.text_7('COND_EBC');
    END IF;

    RETURN NULL;

END GetCurrencyUnit;

FUNCTION GetJDEAccountCode(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN VARCHAR2
IS
BEGIN

    IF p_demurrage_type IN ('EBO','DEMURRAGE') THEN
        RETURN ec_harbour_dues.text_8('LNG_EBC');
    ELSIF p_demurrage_type IN ('COND_EBO','COND_DEMURRAGE') THEN
        RETURN ec_harbour_dues.text_8('COND_EBC');
    END IF;

END GetJDEAccountCode;

PROCEDURE auCargoTransport(p_cargo_no NUMBER, p_old_cargo_status VARCHAR2, p_new_cargo_status VARCHAR2, p_updated_by VARCHAR2)
IS
    v_product_code VARCHAR2(32);

    CURSOR parcels_in_cargo IS
    SELECT *
    FROM dv_storage_lift_nomination
    WHERE cargo_no = p_cargo_no;

    v_old_cargo_status VARCHAR2(32) := ECBP_CARGO_STATUS.GetEcCargoStatus(p_old_cargo_status);
    v_new_cargo_status VARCHAR2(32) := ECBP_CARGO_STATUS.GetEcCargoStatus(p_new_cargo_status);
BEGIN

    FOR item IN parcels_in_cargo LOOP
        v_product_code := ec_product.object_code(ec_stor_version.product_id(item.object_id, sysdate, '<='));
    END LOOP;

    IF (Nvl(v_old_cargo_status,'XXX') <> Nvl(v_new_cargo_status,'XXX')) AND v_new_cargo_status = 'O' THEN

        DELETE FROM dv_demurrage WHERE cargo_no = p_cargo_no;

        IF v_product_code = 'LNG' THEN -- Create LNG entries

            INSERT INTO dv_demurrage (cargo_no, demurrage_type, lifting_event) VALUES (p_cargo_no, 'DEMURRAGE', 'LOAD');
            INSERT INTO dv_demurrage (cargo_no, demurrage_type, lifting_event) VALUES (p_cargo_no, 'EBO', 'LOAD');

        ELSE -- Create Condensate entries

            INSERT INTO dv_demurrage (cargo_no, demurrage_type, lifting_event) VALUES (p_cargo_no, 'COND_DEMURRAGE', 'LOAD');
            INSERT INTO dv_demurrage (cargo_no, demurrage_type, lifting_event) VALUES (p_cargo_no, 'COND_EBO', 'LOAD');

        END IF;

    END IF;

END auCargoTransport;

PROCEDURE WriteLobLine(p_lob IN OUT NOCOPY CLOB CHARACTER SET ANY_CS, p_line IN VARCHAR2)
IS
BEGIN
    dbms_lob.writeappend(p_lob, length(p_line) + 1, p_line || CHR(10));
END WriteLobLine;

FUNCTION getWorksheetLayout(p_demurrage_type VARCHAR2) RETURN CLOB
IS

    v_return_value CLOB;

BEGIN

    dbms_lob.createtemporary(v_return_value, true, dbms_lob.session); -- ue_Ct_msg_interface
    --SELECT empty_clob() INTO v_return_value FROM dual;

    dbms_lob.open(v_return_value, dbms_lob.lob_readwrite);

    WriteLobLine(v_return_value, '<data>');
    WriteLobLine(v_return_value, '  <class name="DEMURRAGE">');

    IF p_demurrage_type = 'DEMURRAGE' THEN

        WriteLobLine(v_return_value, '    <label name="Loading Time" viewgroup="1" viewrow="1" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="Excess Charges" viewgroup="1" viewrow="1" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="LAYTIME_START_ACTIVITY_POPUP" viewgroup="1" viewrow="2" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="LAYTIME_START_ACTIVITY_POPUP" viewgroup="1" viewrow="2" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="Actual Loading Time" viewgroup="1" viewrow="2" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="MINUS_LAYTIME" viewgroup="1" viewrow="2" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="COMMENCE_LAYTIME" viewgroup="1" viewrow="3" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="COMMENCE_LAYTIME" viewgroup="1" viewrow="3" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Base Allowance" viewgroup="1" viewrow="3" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ACCEPTED_LAYTIME" viewgroup="1" viewrow="3" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="LAYTIME_END_ACTIVITY_POPUP" viewgroup="1" viewrow="4" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="LAYTIME_END_ACTIVITY_POPUP" viewgroup="1" viewrow="4" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Extension (Over Capacity)" viewgroup="1" viewrow="4" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ALLOT_EXTENSION_1" viewgroup="1" viewrow="4" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="COMPLETED_LAYTIME" viewgroup="1" viewrow="5" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="COMPLETED_LAYTIME" viewgroup="1" viewrow="5" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Extension (Purge/Cool Time)" viewgroup="1" viewrow="5" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ALLOT_EXTENSION_2" viewgroup="1" viewrow="5" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="= Result" viewgroup="1" viewrow="6" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="INTERMEDIATE_LAYTIME" viewgroup="1" viewrow="6" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Extension (Ship Delays)" viewgroup="1" viewrow="6" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ALLOT_EXTENSION_3" viewgroup="1" viewrow="6" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="+ Unable to Berth Time" viewgroup="1" viewrow="7" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="ACTUAL_EXTENSION_1" viewgroup="1" viewrow="7" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Manual Adjustment" viewgroup="1" viewrow="7" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="MANUAL_ADJUSTMENT" viewgroup="1" viewrow="7" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="For:" viewgroup="1" viewrow="7" viewcol="5" />');
        WriteLobLine(v_return_value, '    <property name="ADJUSTMENT_REASON" viewgroup="1" viewrow="7" viewcol="6" />');
        WriteLobLine(v_return_value, '    <label name="= Actual Loading Time" viewgroup="1" viewrow="8" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="EQ_LAYTIME" viewgroup="1" viewrow="8" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="= Excess Port Time" viewgroup="1" viewrow="8" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="DEMURRAGE" viewgroup="1" viewrow="8" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="Rate (USD/Day)" viewgroup="1" viewrow="9" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="DEMURRAGE_RATE" viewgroup="1" viewrow="9" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="= Calculated Result" viewgroup="1" viewrow="10" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="CALCULATED_CLAIM" viewgroup="1" viewrow="10" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="CLAIM" viewgroup="1" viewrow="12" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="CLAIM" viewgroup="1" viewrow="12" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="STATUS_DATE" viewgroup="1" viewrow="12" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="STATUS_DATE" viewgroup="1" viewrow="12" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="STATUS" viewgroup="1" viewrow="13" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="STATUS_POPUP" viewgroup="1" viewrow="13" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="COMMENTS" viewgroup="1" viewrow="13" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="COMMENTS" viewgroup="1" viewrow="13" viewcol="4" />');

    ELSIF p_demurrage_type = 'EBO' THEN

        WriteLobLine(v_return_value, '    <label name="Loading Time" viewgroup="1" viewrow="1" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="Excess Charges" viewgroup="1" viewrow="1" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="LAYTIME_START_ACTIVITY_POPUP" viewgroup="1" viewrow="2" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="LAYTIME_START_ACTIVITY_POPUP" viewgroup="1" viewrow="2" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="Actual Loading Time" viewgroup="1" viewrow="2" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="MINUS_LAYTIME" viewgroup="1" viewrow="2" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="COMMENCE_LAYTIME" viewgroup="1" viewrow="3" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="COMMENCE_LAYTIME" viewgroup="1" viewrow="3" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Base Allowance" viewgroup="1" viewrow="3" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ACCEPTED_LAYTIME" viewgroup="1" viewrow="3" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="LAYTIME_END_ACTIVITY_POPUP" viewgroup="1" viewrow="4" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="LAYTIME_END_ACTIVITY_POPUP" viewgroup="1" viewrow="4" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Extension (Over Capacity)" viewgroup="1" viewrow="4" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ALLOT_EXTENSION_1" viewgroup="1" viewrow="4" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="COMPLETED_LAYTIME" viewgroup="1" viewrow="5" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="COMPLETED_LAYTIME" viewgroup="1" viewrow="5" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Extension (Purge/Cool Time)" viewgroup="1" viewrow="5" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ALLOT_EXTENSION_2" viewgroup="1" viewrow="5" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="= Result" viewgroup="1" viewrow="6" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="INTERMEDIATE_LAYTIME" viewgroup="1" viewrow="6" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Extension (Shore Delays)" viewgroup="1" viewrow="6" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ALLOT_EXTENSION_3" viewgroup="1" viewrow="6" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="+ Unable to Berth Time" viewgroup="1" viewrow="7" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="ACTUAL_EXTENSION_1" viewgroup="1" viewrow="7" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Manual Adjustment" viewgroup="1" viewrow="7" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="MANUAL_ADJUSTMENT" viewgroup="1" viewrow="7" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="For:" viewgroup="1" viewrow="7" viewcol="5" />');
        WriteLobLine(v_return_value, '    <property name="ADJUSTMENT_REASON" viewgroup="1" viewrow="7" viewcol="6" />');
        WriteLobLine(v_return_value, '    <label name="= Actual Loading Time" viewgroup="1" viewrow="8" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="EQ_LAYTIME" viewgroup="1" viewrow="8" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="= Excess Berth Time" viewgroup="1" viewrow="8" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="DEMURRAGE" viewgroup="1" viewrow="8" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="Rate (USD/Day)" viewgroup="1" viewrow="9" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="DEMURRAGE_RATE" viewgroup="1" viewrow="9" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="= Calculated Result" viewgroup="1" viewrow="10" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="CALCULATED_CLAIM" viewgroup="1" viewrow="10" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="STATUS_DATE" viewgroup="1" viewrow="12" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="STATUS_DATE" viewgroup="1" viewrow="12" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="STATUS" viewgroup="1" viewrow="13" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="STATUS_POPUP" viewgroup="1" viewrow="13" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="COMMENTS" viewgroup="1" viewrow="13" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="COMMENTS" viewgroup="1" viewrow="13" viewcol="4" />');

    ELSIF p_demurrage_type = 'COND_DEMURRAGE' THEN

        WriteLobLine(v_return_value, '    <label name="Laytime" viewgroup="1" viewrow="1" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="Excess Charges" viewgroup="1" viewrow="1" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="LAYTIME_START_ACTIVITY_POPUP" viewgroup="1" viewrow="2" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="LAYTIME_START_ACTIVITY_POPUP" viewgroup="1" viewrow="2" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="Actual Laytime" viewgroup="1" viewrow="2" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="MINUS_LAYTIME" viewgroup="1" viewrow="2" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="COMMENCE_LAYTIME" viewgroup="1" viewrow="3" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="COMMENCE_LAYTIME" viewgroup="1" viewrow="3" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Base Allowance" viewgroup="1" viewrow="3" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ACCEPTED_LAYTIME" viewgroup="1" viewrow="3" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="LAYTIME_END_ACTIVITY_POPUP" viewgroup="1" viewrow="4" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="LAYTIME_END_ACTIVITY_POPUP" viewgroup="1" viewrow="4" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Extension (Low Loading Rate)" viewgroup="1" viewrow="4" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ALLOT_EXTENSION_1" viewgroup="1" viewrow="4" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="COMPLETED_LAYTIME" viewgroup="1" viewrow="5" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="COMPLETED_LAYTIME" viewgroup="1" viewrow="5" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Extension (Ship Delays)" viewgroup="1" viewrow="5" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ALLOT_EXTENSION_3" viewgroup="1" viewrow="5" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="- Manual Adjustment" viewgroup="1" viewrow="6" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="MANUAL_ADJUSTMENT" viewgroup="1" viewrow="6" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="For:" viewgroup="1" viewrow="6" viewcol="5" />');
        WriteLobLine(v_return_value, '    <property name="ADJUSTMENT_REASON" viewgroup="1" viewrow="6" viewcol="6" />');
        WriteLobLine(v_return_value, '    <label name="= Actual Laytime" viewgroup="1" viewrow="6" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="EQ_LAYTIME" viewgroup="1" viewrow="6" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="= Demurrage" viewgroup="1" viewrow="7" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="DEMURRAGE" viewgroup="1" viewrow="7" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="Demurrage Rate (USD/Day)" viewgroup="1" viewrow="8" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="DEMURRAGE_RATE" viewgroup="1" viewrow="8" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="= Calculated Result" viewgroup="1" viewrow="9" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="CALCULATED_CLAIM" viewgroup="1" viewrow="9" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="CLAIM" viewgroup="1" viewrow="11" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="CLAIM" viewgroup="1" viewrow="11" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="STATUS_DATE" viewgroup="1" viewrow="11" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="STATUS_DATE" viewgroup="1" viewrow="11" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="STATUS" viewgroup="1" viewrow="12" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="STATUS_POPUP" viewgroup="1" viewrow="12" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="COMMENTS" viewgroup="1" viewrow="12" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="COMMENTS" viewgroup="1" viewrow="12" viewcol="4" />');

    ELSIF p_demurrage_type = 'COND_EBO' THEN

        WriteLobLine(v_return_value, '    <label name="Departure Period" viewgroup="1" viewrow="1" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="Excess Charges" viewgroup="1" viewrow="1" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="LAYTIME_START_ACTIVITY_POPUP" viewgroup="1" viewrow="2" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="LAYTIME_START_ACTIVITY_POPUP" viewgroup="1" viewrow="2" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="Actual Departure Period" viewgroup="1" viewrow="2" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="MINUS_LAYTIME" viewgroup="1" viewrow="2" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="COMMENCE_LAYTIME" viewgroup="1" viewrow="3" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="COMMENCE_LAYTIME" viewgroup="1" viewrow="3" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Base Allowance" viewgroup="1" viewrow="3" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ACCEPTED_LAYTIME" viewgroup="1" viewrow="3" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="LAYTIME_END_ACTIVITY_POPUP" viewgroup="1" viewrow="4" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="LAYTIME_END_ACTIVITY_POPUP" viewgroup="1" viewrow="4" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="- Extension (Shore Delays)" viewgroup="1" viewrow="4" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="ALLOT_EXTENSION_3" viewgroup="1" viewrow="4" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="- Manual Adjustment" viewgroup="1" viewrow="5" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="MANUAL_ADJUSTMENT" viewgroup="1" viewrow="5" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="For:" viewgroup="1" viewrow="5" viewcol="5" />');
        WriteLobLine(v_return_value, '    <property name="ADJUSTMENT_REASON" viewgroup="1" viewrow="5" viewcol="6" />');
        WriteLobLine(v_return_value, '    <label name="COMPLETED_LAYTIME" viewgroup="1" viewrow="5" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="COMPLETED_LAYTIME" viewgroup="1" viewrow="5" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="= Excess Berth Time" viewgroup="1" viewrow="6" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="DEMURRAGE" viewgroup="1" viewrow="6" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="= Actual Departure Period" viewgroup="1" viewrow="6" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="EQ_LAYTIME" viewgroup="1" viewrow="6" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="Rate (USD/Day)" viewgroup="1" viewrow="7" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="DEMURRAGE_RATE" viewgroup="1" viewrow="7" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="= Calculated Result" viewgroup="1" viewrow="8" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="CALCULATED_CLAIM" viewgroup="1" viewrow="8" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="STATUS_DATE" viewgroup="1" viewrow="10" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="STATUS_DATE" viewgroup="1" viewrow="10" viewcol="4" />');
        WriteLobLine(v_return_value, '    <label name="STATUS" viewgroup="1" viewrow="11" viewcol="1" />');
        WriteLobLine(v_return_value, '    <property name="STATUS_POPUP" viewgroup="1" viewrow="11" viewcol="2" />');
        WriteLobLine(v_return_value, '    <label name="COMMENTS" viewgroup="1" viewrow="11" viewcol="3" />');
        WriteLobLine(v_return_value, '    <property name="COMMENTS" viewgroup="1" viewrow="11" viewcol="4" />');

    END IF;

    WriteLobLine(v_return_value, '  </class>');
    WriteLobLine(v_return_value, '</data>');

    dbms_lob.close(v_return_value);
    RETURN v_return_value;

END getWorksheetLayout;

FUNCTION getWarningStatus(p_cargo_no NUMBER, p_demurrage_type VARCHAR2) RETURN VARCHAR2
IS
    v_demurrage_value NUMBER;
BEGIN

    SELECT calculated_claim
    INTO v_demurrage_value
    FROM dv_demurrage
    WHERE cargo_no = p_cargo_no
    AND demurrage_type = p_demurrage_type;

    IF v_demurrage_value < 1500 THEN
        RETURN 'verificationStatus=warning;verificationText=Claim is less than $1500';
    END IF;

    RETURN NULL;

END getWarningStatus;

FUNCTION cargoHasDemurrage(p_cargo_no NUMBER) RETURN VARCHAR2
IS
    CURSOR demurrage_rows IS
    SELECT cargo_no, demurrage_type, lifting_event
    FROM cargo_demurrage
    WHERE cargo_no = p_cargo_no;
BEGIN

    FOR item IN demurrage_rows LOOP
        IF GetDemurrage(p_cargo_no, item.demurrage_type, item.lifting_event) * GetDemurrageRate(p_cargo_no, item.demurrage_type, item.lifting_event) >= 1500 THEN
            RETURN 'Y';
        END IF;
    END LOOP;

    RETURN 'N';

END cargoHasDemurrage;

END UE_CT_DEMURRAGE;
/