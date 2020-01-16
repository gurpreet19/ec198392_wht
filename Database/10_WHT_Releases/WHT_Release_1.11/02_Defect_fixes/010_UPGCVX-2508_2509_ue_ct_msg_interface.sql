CREATE OR REPLACE PACKAGE BODY UE_CT_MSG_INTERFACE IS
/****************************************************************
** Package        :  UE_CT_MSG_INTERFACE, body part
**
** Purpose        :  Handles external interfaces into the EC Messaging System
**
** Documentation  :
**
** Created  : 01-FEB-2013  Samuel Webb
**
** Modification history:
**
** Date           Whom  Change Description
** -----------    ----  ------------------------------------------
** 01-FEB-2013    swgn  Initial version
** 18-JUL-2013    swgn  Added procedures for "data ready" messages
** 30-JUL-2014    swgn  UPDATE 08A: Defect fixes for division by zero errors
** 16-OCT-2015      tlxt  Added LoadCapForecasts and LoadOthProdForecasts
** 15-NOV-2016    cvmk  112302: Modified InformMessageStatus()
** 21-nOV-2016    tlxt  112453: adde new constraint key
** 06-mar-2017    koij  113799 Cargo ETA and ETD Verfification.Revert to Dynamic values when scenario is rejected or set to provisional
*****************************************************************/

-----------------------------------------------------------------------------------------------------
-- Processes the callback from the IPAWF interface whenever an outgoing message is approved or rejected
-----------------------------------------------------------------------------------------------------
PROCEDURE InformMessageStatus(p_message_id NUMBER, p_status VARCHAR2)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    v_status VARCHAR2(32):= upper(p_status);
    v_message_type_code VARCHAR2(32);
    v_message_id NUMBER;
    v_lifting_program_id VARCHAR2(32);
    v_parcel_no VARCHAR2(32);
    v_count NUMBER;
    v_message_distribution_no NUMBER;
    v_start_date DATE;
    v_end_date DATE;

    CURSOR get_parcel_message_distr (cv_parcel_no VARCHAR2) IS
    SELECT message_distribution_no, parameter_name, parameter_value, parameter_type, parameter_sub_type
    FROM tv_message_distr_param
    WHERE parameter_name = 'Cargo Generation'
    AND parameter_value = cv_parcel_no;

    CURSOR ALL_CARGOES(cp_start DATE, cp_end DATE)IS
    SELECT DISTINCT(A.CARGO_NO) ,A.DAYTIME FROM  DV_STORAGE_LIFT_NOM_INFO A, DV_CARGO_INFO B
    WHERE A.CARGO_NO = B.CARGO_NO
    AND B.STATUS IN ('T','O')
    AND A.DAYTIME >= cp_start
    AND A.DAYTIME <= cp_end
    ORDER BY A.DAYTIME;


BEGIN

    SELECT ec_message_definition.object_code(ec_message_out.object_id(external_ref)), external_ref INTO v_message_type_code, v_message_id
    FROM mhm_msg
    WHERE message_id = p_message_id;

    IF (v_status != 'APPROVED' AND v_status != 'REJECTED') THEN
        RAISE_APPLICATION_ERROR(-20999, 'Message status must be "APPROVED" or "REJECTED"');
    END IF;

    IF (v_message_type_code IS NULL) THEN
        RAISE_APPLICATION_ERROR(-20999, 'Message number not recognized');
    END IF;

    IF (v_message_type_code IN ('MSG_PADP','MSG_ADP','MSG_RADP','MSG_SDS')) THEN -- Get the lifting program id from message metadata
        SELECT CASE WHEN TEXT_1 = 'Lifting Program' THEN TEXT_2
                             WHEN TEXT_3 = 'Lifting Program' THEN TEXT_4
                             WHEN TEXT_5 = 'Lifting Program' THEN TEXT_6
                             WHEN TEXT_7 = 'Lifting Program' THEN TEXT_8
                             WHEN TEXT_9 = 'Lifting Program' THEN TEXT_10
                             ELSE NULL END INTO v_lifting_program_id
        FROM message_out
        WHERE message_no = v_message_id; -- select * from message_out

        IF (v_lifting_program_id IS NULL OR ec_forecast.object_code(v_lifting_program_id) IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20999, 'Message number not recognized');
        END IF;

        IF (v_status = 'REJECTED') THEN
            --TEXT_6 = SCENARIO_TYPE: R_ADP, PADP, ADP, CARGO_REQS, AD_HOC, PLP, SDS
            --TEXT_8 = PROD_FCST_SCENARIO: REF_PROD, HIGH_CONF, MED_CONF, LOW_CONF
            --TEXT_9 = PROD_FCST_TYPE: ADP_PLAN, SDS_PLAN
            --TEXT_10 = FCST_STOR_FCAST_SRC: PROD_PLAN_FCAST, TRAN_PCTR_FCAST

            --tlxt: item 96402 01-Apr-2015 happy april fool
            -- Not allow for the system to Reject an approved scenario
            IF NVL(EC_FORECAST_VERSION.TEXT_5(v_lifting_program_id,SYSDATE,'<='),'V') = 'V' THEN
                UPDATE forecast_version SET text_5 = 'P',
                --tlxt: item 97613 06-may-2015: set production profile to NULL
                --tlxt: ITEM: 99491 25-jun-2015, no need to reset the forecast_object_id as we decided not to touch all these columns during the promotion from P to V
                --REF_OBJECT_ID_1 = '',
                --tlxt: item 97613 06-may-2015
                text_10 = 'PROD_PLAN_FCAST'
                --TLXT: 99491: 25-JUN-2015: DO NOT RESTORE TEXT_8 AND TEXT_9 FOR sds as the value will be persisted in UE_CT_FORECAST_TRAN_CP during the promotion to Verify
                --text_8 = DECODE(text_6,'SDS','HIGH_CONF', 'PLP','HIGH_CONF','R_ADP','HIGH_CONF','REF_PROD'),
                --text_9 = decode(text_6,'SDS', 'SDS_PLAN', 'PLP','SDS_PLAN','R_ADP','SDS_PLAN','ADP_PLAN')
                WHERE object_id = v_lifting_program_id; -- Rejected messages go back to provisional

            --Item 112302: Begin
                IF (v_message_type_code IN ('MSG_ADP','MSG_RADP','MSG_SDS')) THEN
                 UPDATE cargo_fcst_transport
                    SET cargo_status = 'T'
                  WHERE forecast_id = v_lifting_program_id
                    AND cargo_status = 'O';
                END IF;
            --Item 112302: End


              /*********************************Task 113799 - Cargo ETA and ETD Verfification.Revert to Dynamic values when scenario is rejected or set to provisional*****************/
                IF (v_message_type_code IN ('MSG_ADP','MSG_RADP','MSG_PADP','MSG_SDS')) THEN
                 UPDATE STOR_FCST_LIFT_NOM
                    SET DATE_5 = null,DATE_6=null
                 WHERE forecast_id = v_lifting_program_id;
                END IF;
            /*****Task 113799 End*************/

                UE_CT_FORECAST_TRAN_CP.SynchronizeMessageDistribution(v_lifting_program_id, 'P');
                UE_CT_FORECAST_TRAN_CP.UpdateTableStatus(v_lifting_program_id, 'V', 'P', EcDp_Context.getAppUser);
                --TLXT: 99708: 02-JUL-2015: check monthly adjustment class for setting to approve trading data upon adp approval
                UPDATE DV_LIFT_ACCOUNT_ADJUSTMENT
                SET RECORD_STATUS = 'P', LAST_UPDATED_BY =EcDp_Context.getAppUser, LAST_UPDATED_DATE = SYSDATE
                WHERE DAYTIME BETWEEN EC_FORECAST.START_DATE(v_lifting_program_id) AND EC_FORECAST.END_DATE(v_lifting_program_id)
                AND EC_FORECAST_VERSION.TEXT_6(v_lifting_program_id,SYSDATE,'<=') = 'ADP'
                AND RECORD_STATUS = 'V';

            ELSE
                RAISE_APPLICATION_ERROR(-20999, 'Cannot reject a NON verified scenario');
            END IF;
        ELSIF (v_status = 'APPROVED') THEN

            UPDATE forecast_version SET text_5 = 'A', DATE_5 = trunc(sysdate, 'DD') WHERE object_id = v_lifting_program_id; -- Approved messages go to A, and approval date gets set
                                                                                                                                                                                    -- Imperative that the approval date is not sub daily otherwise calc rule breaks
            UE_CT_FORECAST_TRAN_CP.SynchronizeMessageDistribution(v_lifting_program_id, 'A');
            UE_CT_FORECAST_TRAN_CP.UpdateTableStatus(v_lifting_program_id, 'V', 'A', EcDp_Context.getAppUser);
            --TLXT: 99708: 02-JUL-2015: check monthly adjustment class for setting to approve trading data upon adp approval
            UPDATE DV_LIFT_ACCOUNT_ADJUSTMENT
            SET RECORD_STATUS = 'A', LAST_UPDATED_BY =EcDp_Context.getAppUser, LAST_UPDATED_DATE = SYSDATE
            WHERE DAYTIME BETWEEN EC_FORECAST.START_DATE(v_lifting_program_id) AND EC_FORECAST.END_DATE(v_lifting_program_id)
            AND EC_FORECAST_VERSION.TEXT_6(v_lifting_program_id,SYSDATE,'<=') = 'ADP'
            AND RECORD_STATUS = 'V';

            IF (v_message_type_code IN ('MSG_ADP','MSG_SDS','MSG_RADP')) THEN
                UE_FORECAST_CARGO_PLANNING.CopyToOriginal(v_lifting_program_id, 'NO');
                --TLXT: 99178 : 22-JUN-2015
                --Default split factor from last available Cargo Info
                COMMIT;
                v_start_date := EC_FORECAST.START_DATE(v_lifting_program_id);
                v_end_date := EC_FORECAST.END_DATE(v_lifting_program_id);
                IF v_start_date IS NOT NULL AND v_end_date IS NOT NULL THEN
                    FOR A_CARGOES IN ALL_CARGOES(v_start_date, v_end_date) LOOP
                        UE_CT_CARGO_INFO.UpdateSplitPCT(A_CARGOES.CARGO_NO);
                    END  LOOP;
                ELSE
                    ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE','Couldnt find either Start or End date to Default the split PCT. forecast_id='||v_lifting_program_id);
                END IF;
                --END EDIT
            END IF;

        END IF;
    END IF;

    IF v_message_type_Code = 'MSG_CARGO_DOCS' AND v_status = 'APPROVED' THEN

        SELECT CASE WHEN TEXT_1 = 'Cargo Generation' THEN TEXT_2
                             WHEN TEXT_3 = 'Cargo Generation' THEN TEXT_4
                             WHEN TEXT_5 = 'Cargo Generation' THEN TEXT_6
                             WHEN TEXT_7 = 'Cargo Generation' THEN TEXT_8
                             WHEN TEXT_9 = 'Cargo Generation' THEN TEXT_10
                             ELSE NULL END INTO v_parcel_no
        FROM message_out
        WHERE message_no = v_message_id; -- select * from message_out

        FOR item IN get_parcel_message_distr(v_parcel_no) LOOP
            v_message_distribution_no := item.message_distribution_no;
        END LOOP;

        IF v_message_distribution_no IS NOT NULL THEN
            DELETE FROM dv_message_distr_conn WHERE message_distribution_no = v_message_distribution_no;
            DELETE FROM tv_message_distr_param WHERE message_distribution_no = v_message_distribution_no;
            DELETE FROM dv_message_distribution WHERE message_distribution_no = v_message_distribution_no;
        END IF;
    END IF;

    --tlxt 31-oct-2014
    --to cater Reference Entitlement
    IF v_message_type_Code = 'MSG_REF_ENTS' THEN

        SELECT CASE WHEN TEXT_1 = 'Reference Entitlements' THEN TEXT_2
                             WHEN TEXT_3 = 'Reference Entitlements' THEN TEXT_4
                             WHEN TEXT_5 = 'Reference Entitlements' THEN TEXT_6
                             WHEN TEXT_7 = 'Reference Entitlements' THEN TEXT_8
                             WHEN TEXT_9 = 'Reference Entitlements' THEN TEXT_10
                             ELSE NULL END INTO v_lifting_program_id
        FROM message_out
        WHERE message_no = v_message_id; -- select * from message_out
        IF v_status = 'APPROVED' THEN
            UE_CT_FORECAST_TRAN_CP.UpdateRefEntStatus(v_lifting_program_id, 'V', 'A', EcDp_Context.getAppUser);
            UE_CT_FORECAST_TRAN_CP.SynchronizeMessageDistribution(v_lifting_program_id, 'A');
        END IF;
        IF v_status = 'REJECTED' THEN
            --tlxt: item 96402 01-Apr-2015 happy april fool
            -- Not allow for the system to Reject an approved scenario
            IF NVL(EC_CT_PROD_FCST_VERSION.RECORD_STATUS(v_lifting_program_id,SYSDATE,'<='),'V') = 'V' THEN
                UE_CT_FORECAST_TRAN_CP.UpdateRefEntStatus(v_lifting_program_id, 'V', 'P', EcDp_Context.getAppUser);
                UE_CT_FORECAST_TRAN_CP.SynchronizeMessageDistribution(v_lifting_program_id, 'P');
            ELSE
                RAISE_APPLICATION_ERROR(-20999, 'Cannot reject a NON verified scenario');
            END IF;
        END IF;


    END IF;

    IF (v_message_type_code IN ('MSG_DG_REF_ENTS')) THEN -- Get the lifting program id from message metadata
        SELECT CASE     WHEN TEXT_1 = 'Domgas Entitlements' THEN TEXT_2
                        ELSE NULL END INTO v_lifting_program_id
        FROM message_out
        WHERE message_no = v_message_id; -- select * from message_out

        IF (v_lifting_program_id IS NULL OR ec_forecast.object_code(v_lifting_program_id) IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20999, 'Message number not recognized');
        END IF;

        IF (v_status = 'REJECTED') THEN

            UPDATE forecast_version SET text_5 = 'P', RECORD_STATUS = 'P'
            WHERE object_id = v_lifting_program_id
            AND text_5 = 'V'; -- Rejected messages go back to provisional

            UE_CT_FORECAST_TRAN_CP.SynchronizeMessageDistribution(v_lifting_program_id, 'P','DG_REF_ENTS');

            --UE_CT_FORECAST_TRAN_CP.UpdateTableStatus(v_lifting_program_id, 'V', 'P', EcDp_Context.getAppUser);
          /*
            UPDATE ALLOC_JOB_LOG
            SET RECORD_STATUS = 'P', ACCEPT_STATUS = 'P', LAST_UPDATED_BY =EcDp_Context.getAppUser, LAST_UPDATED_DATE = SYSDATE
            WHERE CLASS_NAME = 'CALC_FCST_LOG'
            AND RECORD_STATUS = 'V'
            AND ECDP_OBJECTS.GETOBJCODE(JOB_ID) = V_DG_REF_ENT_JOB_ID;
          */
            UPDATE DV_CT_DG_ACC_DAY_REF_ENT
            SET RECORD_STATUS = 'P'
            WHERE FORECAST_OBJECT_ID = v_lifting_program_id
            AND RECORD_STATUS = 'V';


        ELSIF (v_status = 'APPROVED') THEN

            UPDATE forecast_version SET text_5 = 'A',  RECORD_STATUS = 'A', DATE_5 = trunc(sysdate, 'DD')
            WHERE object_id = v_lifting_program_id
            AND text_5 = 'V'; -- Approved messages go to A, and approval date gets set
                                                                                                                                                                                    -- Imperative that the approval date is not sub daily otherwise calc rule breaks
            UE_CT_FORECAST_TRAN_CP.SynchronizeMessageDistribution(v_lifting_program_id, 'A','DG_REF_ENTS');
/*
            UPDATE ALLOC_JOB_LOG
            SET RECORD_STATUS = 'A', ACCEPT_STATUS = 'A', LAST_UPDATED_BY =EcDp_Context.getAppUser, LAST_UPDATED_DATE = SYSDATE
            WHERE CLASS_NAME = 'CALC_FCST_LOG'
            AND RECORD_STATUS = 'V'
            AND ECDP_OBJECTS.GETOBJCODE(JOB_ID) = V_DG_REF_ENT_JOB_ID;
*/
            UPDATE DV_CT_DG_ACC_DAY_REF_ENT
            SET RECORD_STATUS = 'A'
            WHERE FORECAST_OBJECT_ID = v_lifting_program_id
            AND RECORD_STATUS = 'V';

        END IF;
    END IF;

    IF (v_message_type_code IN ('MSG_DG_PLAN')) THEN -- Get the lifting program id from message metadata
        SELECT CASE     WHEN TEXT_1 = 'Domgas Delivery Plan' THEN TEXT_2
                        ELSE NULL END INTO v_lifting_program_id
        FROM message_out
        WHERE message_no = v_message_id; -- select * from message_out

        IF (v_lifting_program_id IS NULL OR ec_forecast.object_code(v_lifting_program_id) IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20999, 'Message number not recognized');
        END IF;

        IF (v_status = 'REJECTED') THEN

            UPDATE forecast_version SET text_5 = 'P' , RECORD_STATUS = 'P'
            WHERE object_id = v_lifting_program_id
            AND text_5 = 'V' ; -- Rejected messages go back to provisional

            UE_CT_FORECAST_TRAN_CP.SynchronizeMessageDistribution(v_lifting_program_id, 'P');

            UPDATE DV_FCST_CNTR_DAY_STATUS
            SET RECORD_STATUS = 'P'
            WHERE FORECAST_ID = v_lifting_program_id
            AND  RECORD_STATUS = 'V';


        ELSIF (v_status = 'APPROVED') THEN

            UPDATE forecast_version SET text_5 = 'A', RECORD_STATUS = 'A', DATE_5 = sysdate
            WHERE object_id = v_lifting_program_id
            AND text_5 = 'V'; -- Approved messages go to A, and approval date gets set
                                                                                                                                                                                    -- Imperative that the approval date is not sub daily otherwise calc rule breaks
            UE_CT_FORECAST_TRAN_CP.SynchronizeMessageDistribution(v_lifting_program_id, 'A');
/*
            UPDATE ALLOC_JOB_LOG
            SET RECORD_STATUS = 'A', ACCEPT_STATUS = 'A', LAST_UPDATED_BY =EcDp_Context.getAppUser, LAST_UPDATED_DATE = SYSDATE
            WHERE CLASS_NAME = 'CALC_FCST_LOG'
            AND RECORD_STATUS = 'V'
            AND ECDP_OBJECTS.GETOBJCODE(JOB_ID) = V_DG_REF_ENT_JOB_ID;
*/
            UPDATE DV_FCST_CNTR_DAY_STATUS
            SET RECORD_STATUS = 'A'
            WHERE FORECAST_ID = v_lifting_program_id
            AND RECORD_STATUS = 'V';

        END IF;
    END IF;


END InformMessageStatus;

-----------------------------------------------------------------------------------------------------
-- Handles what happens when an incoming Data Ready message is processed
-----------------------------------------------------------------------------------------------------
PROCEDURE RouteDataReady(p_datatype_code VARCHAR2, p_from_date DATE, p_to_date DATE, p_row_count NUMBER, p_param_names VARCHAR2, p_param_values VARCHAR2)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    v_name_count binary_integer;
    v_value_count binary_integer;
    v_name_array dbms_utility.lname_array;
    v_value_array dbms_utility.lname_array;
    v_count NUMBER := 0;
BEGIN

    v_name_count := length(p_param_names) - length(replace(p_param_names, ',')) + 1;
    v_value_count := v_name_count;

    IF length(p_param_names) > 0 THEN
        -- Build the parameter list
        dbms_utility.comma_to_table (
            list => '"' || regexp_replace(p_param_names, '(,)+','"\1"') || '"',
            tablen => v_name_count,
            tab => v_name_array
        );

        dbms_utility.comma_to_table (
            list => '"' || regexp_replace(p_param_values, '(,)+','"\1"') || '"',
            tablen => v_value_count,
            tab => v_value_array
        );

    END IF;
    IF p_datatype_code = 'PROD_FORECAST' THEN
        FOR i IN 1 .. v_name_count LOOP
            IF v_name_array(i) = '"DATA_STAGE_CODE"' THEN
                v_count := 0 ;
                SELECT COUNT(DISTINCT(FCST_CPP_ID)) INTO v_count FROM DV_CT_PROD_STRM_FORECAST WHERE FCST_CPP_ID = replace(v_value_array(i), '"') ;
                IF v_count = 0 THEN
                    --Load EC Production Plan Type with ADP/SDS from CT_STAGE_PROD_PC_FCST
                    LoadProductionForecasts(replace(v_value_array(i), '"'));
                    COMMIT;
                    --Load EC Production Plan type other than ADP/SDS from CT_STAGE_PROD_PC_FCST
                    LoadOthProdForecasts(replace(v_value_array(i), '"'));
                    COMMIT;
                    --Load Capacity Forecast from CT_STAGE_AVAIL_CAP_FCST
                    LoadCapForecasts(replace(v_value_array(i), '"'));
                    COMMIT;
                END IF;
                LoadProdFcastRestrictions(replace(v_value_array(i), '"'), p_from_date, p_to_date);
            END IF;
        END LOOP;
    ELSE
        raise_application_error(-20101, 'Data loading for datatype code [' || p_datatype_code || '] has not been defined. See UE_CT_MSG_INTERFACE.RouteDataReady');
    END IF;
END RouteDataReady;

-----------------------------------------------------------------------------------------------------
-- Helper procedure to write a line for a clob
-----------------------------------------------------------------------------------------------------
PROCEDURE WriteLobLine(p_lob IN OUT NOCOPY CLOB CHARACTER SET ANY_CS, p_line IN VARCHAR2)
IS
BEGIN
    dbms_lob.writeappend(p_lob, length(p_line), p_line);
END WriteLobLine;

-----------------------------------------------------------------------------------------------------
-- Helper procedure to create a Data Ready message. Can simulate an incoming message or generate an outgoing message
-----------------------------------------------------------------------------------------------------
PROCEDURE SendReadyMessage(p_receiver_code VARCHAR2, p_datatype_code VARCHAR2, p_from_date DATE, p_to_date DATE, p_row_count NUMBER, p_param_names VARCHAR2, p_param_values VARCHAR2, p_in_out VARCHAR2 DEFAULT 'OUT', p_sender_code VARCHAR2 DEFAULT 'CC_WHEATSTONE')
IS
    v_message_no NUMBER;
    v_internal_ref NUMBER;
    v_message_lob CLOB;
    v_receiver_row OV_MESSAGE_CONTACT%ROWTYPE;
    v_sender_row OV_MESSAGE_CONTACT%ROWTYPE;

    CURSOR message_contacts(cp_object_code VARCHAR2, cp_date DATE) IS
    SELECT * FROM ov_message_contact
    WHERE code = cp_object_code
    AND daytime <= cp_date
    ORDER BY daytime ASC;

    v_name_count binary_integer;
    v_value_count binary_integer;
    v_name_array dbms_utility.lname_array;
    v_value_array dbms_utility.lname_array;

BEGIN

    FOR item IN message_contacts(p_receiver_code, sysdate) LOOP
        v_receiver_row := item;
    END LOOP;

    IF v_receiver_row.object_id IS NULL THEN
        raise_application_error(-20100, 'Could not find receiver with code ' || p_receiver_code);
    END IF;

    FOR item IN message_contacts(p_sender_code, sysdate) LOOP
        v_sender_row := item;
    END LOOP;

    IF v_sender_row.object_id IS NULL THEN
        raise_application_error(-20100, 'Could not find sender with code ' || p_sender_code);
    END IF;

    -- Get the next message number
    ecdp_system_key.assignNextNumber('MESSAGE_OUT', v_message_no);

    SELECT nvl(max(message_id), 0) + 1 INTO v_internal_ref
    FROM mhm_msg;

    -- Insert the message, but with a blank XML:
    IF p_in_out = 'OUT' THEN

        INSERT INTO message_out (OBJECT_ID, MESSAGE_NO, COMPANY_CONTACT_ID, FORMAT_CODE, SUBJECT, MESSAGE_DRAFT, MESSAGE, VALID_FROM_DATE, VALID_TO_DATE,
                ACKNOWLEDGE_IND, TRANSMIT_STATUS, EDI_ADDRESS_CODE, REVISION)
        VALUES (ec_message_definition.object_id_by_uk('MSG_DATA_READY'), v_message_no, ec_company_contact.object_id_by_uk('CC_WHEATSTONE', 'MESSAGE_CONTACT'), 'XML', p_datatype_code,
                empty_clob(), empty_clob(), nvl(p_from_date, p_to_date), p_to_date, 'Y', 'READY', 'IPAWF', 0);

        -- Build up the XML:
        dbms_lob.createtemporary(v_message_lob,true,dbms_lob.session);
        UPDATE message_out SET message_draft = v_message_lob WHERE message_no = v_message_no;
        SELECT message_draft INTO v_message_lob FROM message_out WHERE message_no = v_message_no;

    ELSE

        INSERT INTO mhm_msg (DIRECTION, EC_SYSTEM_REF, MESSAGE_ID, EXTERNAL_REF, PRIORITY, STATUS, RECEIVED_DATE, MSG_TYPE, SUBJECT, SENDER, RECIPIENT, VALID_FROM,
                VALID_TO, REVISION, ACKNOWLEDGED, MESSAGE_ORIGINAL, MESSAGE_CONVERTED, LOG)
        VALUES ('I', 'EC', v_internal_ref, NULL, 0, 'ACCEPTED', sysdate, 'MSG_DATA_READY', p_datatype_code, v_receiver_row.company_code, p_receiver_code,
                nvl(p_from_date, p_to_date), p_to_date, 0, 'N', empty_clob(), empty_clob(), empty_clob());

        -- Build up the XML:
        dbms_lob.createtemporary(v_message_lob,true,dbms_lob.session);
        UPDATE mhm_msg SET message_original = v_message_lob WHERE message_id = v_internal_ref;
        SELECT message_original INTO v_message_lob FROM mhm_msg WHERE message_id = v_internal_ref;

    END IF;

    dbms_lob.open(v_message_lob, dbms_lob.lob_readwrite);

    WriteLobLine(v_message_lob, '<?xml version="1.0" encoding="iso-8859-1"?><MsgList><Msg Type="MSG_DATA_READY" System="EC" Revision="3" Priority="0" TestFlag="N"><Header>');
    WriteLobLine(v_message_lob, '<RecipientList TO="' || v_receiver_row.name || '" CC="" />');
    WriteLobLine(v_message_lob, '<Sender CompanyNumber="' || v_sender_row.company_code || '" CompanyName="' || ec_company_version.name(v_sender_row.company_id, sysdate, '<=') || '" ContactCode="' || v_sender_row.code
                                || '" ContactName="' || v_sender_row.name || '" Ident="' || v_sender_row.delivery_address || '" SubIdent="' || v_sender_row.delivery_address_2 || '" />');
    WriteLobLine(v_message_lob, '<Receiver CompanyNumber="' || v_receiver_row.company_code || '" CompanyName="' || ec_company_version.name(v_receiver_row.company_id, sysdate, '<=') || '" ContactCode="' || v_receiver_row.code
                                || '" ContactName="' || v_receiver_row.name || '" Ident="' || v_receiver_row.delivery_address || '" SubIdent="' || v_receiver_row.delivery_address_2
                                || '" DeliveryFormat="XML"/>');
    WriteLobLine(v_message_lob, '<Generated Date="' || to_char(sysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || '" GeneratedBy="' || ecdp_context.GetAppUser || '" />');
    WriteLobLine(v_message_lob, '<Subject>' || p_datatype_code || '</Subject>');
    WriteLobLine(v_message_lob, '<Period FromDate="' || to_char(nvl(p_from_date, p_to_date), 'YYYY-MM-DD"T"HH24:MI:SS') || '" ToDate="' || to_char(p_to_date, 'YYYY-MM-DD"T"HH24:MI:SS') || '" />');
    WriteLobLine(v_message_lob, '</Header><Body><DataAvailableMessage>');
    WriteLobLine(v_message_lob, '<DataTypeCode>' || p_datatype_code || '</DataTypeCode>');
    WriteLobLine(v_message_lob, '<FromDate>' || to_char(nvl(p_from_date, p_to_date), 'YYYY-MM-DD"T"HH24:MI:SS') || replace(tz_offset(dbtimezone), chr(0)) || '</FromDate>');
    WriteLobLine(v_message_lob, '<ToDate>' || to_char(p_to_date, 'YYYY-MM-DD"T"HH24:MI:SS') || replace(tz_offset(dbtimezone), chr(0)) || '</ToDate>');
/*
    IF (p_row_count>=0) THEN
        WriteLobLine(v_message_lob, '<RowCount>' || p_row_count || '</RowCount>');
    END IF;
*/
    -- Get the number of parameters
    v_name_count := length(p_param_names) - length(replace(p_param_names, ',')) + 1;
    v_value_count := v_name_count;

    IF length(p_param_names) > 0 THEN
        -- Build the parameter list
        dbms_utility.comma_to_table (
            list => '"' || regexp_replace(p_param_names, '(,)+','"\1"') || '"',
            tablen => v_name_count,
            tab => v_name_array
        );

        dbms_utility.comma_to_table (
            list => '"' || regexp_replace(p_param_values, '(,)+','"\1"') || '"',
            tablen => v_value_count,
            tab => v_value_array
        );

        FOR i IN 1 .. v_name_count LOOP
            WriteLobLine(v_message_lob, '<Parameter>');
            WriteLobLine(v_message_lob, '<ParameterName>' || replace(v_name_array(i), '"') || '</ParameterName>');
            WriteLobLine(v_message_lob, '<ParameterValue>' || replace(v_value_array(i), '"') || '</ParameterValue>');
            WriteLobLine(v_message_lob, '</Parameter>');
        END LOOP;

    END IF;

    WriteLobLine(v_message_lob, '</DataAvailableMessage></Body></Msg></MsgList>');
    dbms_lob.close(v_message_lob);

    IF p_in_out = 'OUT' THEN

        INSERT INTO mhm_msg (DIRECTION, EC_SYSTEM_REF, MESSAGE_ID, EXTERNAL_REF, PRIORITY, STATUS, RECEIVED_DATE, MSG_TYPE, SUBJECT, SENDER, RECIPIENT, VALID_FROM,
                VALID_TO, REVISION, ACKNOWLEDGED, MESSAGE_ORIGINAL, MESSAGE_CONVERTED, LOG)
        VALUES ('O', 'EC', v_internal_ref, v_message_no, 0, 'PREPARED', sysdate, 'MSG_DATA_READY', p_datatype_code, v_receiver_row.company_code, p_receiver_code,
                nvl(p_from_date, p_to_date), p_to_date, 0, 'N', empty_clob(), empty_clob(), empty_clob());

        UPDATE mhm_msg SET message_original =
            (
                SELECT message_draft FROM message_out WHERE message_no = v_message_no
            )
        WHERE message_id = v_internal_ref;

        INSERT INTO mhm_msg_dm (MESSAGE_ID, PRIORITY, METHOD, ADDRESS)
        VALUES (v_internal_ref, 1, v_receiver_row.delivery_method, v_receiver_row.delivery_address);

    ELSE

        UPDATE mhm_msg SET message_converted = message_original WHERE message_id = v_internal_ref;

    END IF;

END SendReadyMessage;

-----------------------------------------------------------------------------------------------------
-- Load Forecast Header For Other than ADP/SDS plan
-----------------------------------------------------------------------------------------------------
PROCEDURE LoadOthProdForecasts(p_datastage_code VARCHAR2)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    CURSOR prod_forecast_stage(cp_forecast_type VARCHAR2, cp_probability_type VARCHAR2, cp_start_date DATE, cp_end_date DATE, cp_UPG VARCHAR2) IS
    SELECT daytime, forecast_type, probability_type, UPG AS PROFIT_CENTRE_CODE,
           EcDp_Unit.ConvertValue(LNG_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_DENSITY')), DAYTIME) as LNG_DENSITY,
           EcDp_Unit.ConvertValue(COND_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_DENSITY')), DAYTIME) as COND_DENSITY,
           EcDp_Unit.ConvertValue(LNG_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_VOL_RATE')), DAYTIME) as LNG_VOL_RATE,
           EcDp_Unit.ConvertValue(LNG_EXCESS_PROD, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD')), DAYTIME) as LNG_EXCESS_PROD,
           EcDp_Unit.ConvertValue(LNG_REGAS_REQ_LNG, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_LNG')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_LNG')), DAYTIME) as LNG_REGAS_REQ_LNG,
           EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_QTY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_QTY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_QTY')), DAYTIME) as CONFIRMED_EXCESS_QTY,
           EcDp_Unit.ConvertValue(LNG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV')), DAYTIME) as LNG_HHV,
           EcDp_Unit.ConvertValue(LNG_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_RATE')), DAYTIME) as LNG_MASS_RATE,
           EcDp_Unit.ConvertValue(LNG_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_SMPP')), DAYTIME) as LNG_MASS_SMPP,
           EcDp_Unit.ConvertValue(COND_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_VOL_RATE')), DAYTIME) as COND_VOL_RATE,
           EcDp_Unit.ConvertValue(COND_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_RATE')), DAYTIME) as COND_MASS_RATE,
           EcDp_Unit.ConvertValue(COND_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_SMPP')), DAYTIME) as COND_MASS_SMPP,
           EcDp_Unit.ConvertValue(DOMGAS_MASS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MASS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MASS_RATE')), DAYTIME) as DOMGAS_MASS_RATE,
           EcDp_Unit.ConvertValue(DOMGAS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_ENERGY')), DAYTIME) as DOMGAS_ENERGY,
           EcDp_Unit.ConvertValue(DOMGAS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_SMPP')), DAYTIME) as DOMGAS_SMPP,
            --Added Nomination attributes
            EcDp_Unit.ConvertValue(PLATFORM_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','PLATFORM_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','PLATFORM_MASS_SMPP')), DAYTIME) as PLATFORM_MASS_SMPP,
            EcDp_Unit.ConvertValue(DOMGAS_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_HHV')), DAYTIME) as DOMGAS_HHV,
            EcDp_Unit.ConvertValue(DOMGAS_MIN_RATE_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MIN_RATE_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MIN_RATE_ENERGY')), DAYTIME) as DOMGAS_MIN_RATE_ENERGY,
            EcDp_Unit.ConvertValue(DOMGAS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL_RATE')), DAYTIME) as DOMGAS_VOL_RATE,
            EcDp_Unit.ConvertValue(LNG_HHV_GJSM3, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV_GJSM3')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV_STD')), DAYTIME) as LNG_HHV_STD,
            EcDp_Unit.ConvertValue(LNG_BL_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_BL_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_BL_VOLUME')), DAYTIME) as LNG_BL_VOLUME,
            EcDp_Unit.ConvertValue(LNG_BL_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_BL_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_BL_ENERGY')), DAYTIME) as LNG_BL_ENERGY,
            EcDp_Unit.ConvertValue(LNG_EXCESS_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD_VOLUME')), DAYTIME) as LNG_EXCESS_PROD_VOLUME,
            EcDp_Unit.ConvertValue(LNG_EXCESS_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD_ENERGY')), DAYTIME) as LNG_EXCESS_PROD_ENERGY,
            EcDp_Unit.ConvertValue(ADP_LNG_REQ_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','ADP_LNG_REQ_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','ADP_LNG_REQ_VOLUME')), DAYTIME) as ADP_LNG_REQ_VOLUME,
            EcDp_Unit.ConvertValue(ADP_LNG_REQ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','ADP_LNG_REQ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','ADP_LNG_REQ_ENERGY')), DAYTIME) as ADP_LNG_REQ_ENERGY,
            EcDp_Unit.ConvertValue(LNG_REGAS_REQ_GAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_GAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_GAS')), DAYTIME) as LNG_REGAS_REQ_GAS,
            EcDp_Unit.ConvertValue(LNG_NET_RUNDOWN_CAP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_NET_RUNDOWN_CAP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_NET_RUNDOWN_CAP')), DAYTIME) as LNG_NET_RUNDOWN_CAP,
            EcDp_Unit.ConvertValue(LNG_REGAS_REQ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_ENERGY')), DAYTIME) as LNG_REGAS_REQ_ENERGY,
            WPT_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_VOLUME')), DAYTIME) as WPT_GU_FACTOR_VOLUME,
            WPT_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_ENERGY')), DAYTIME) as WPT_GU_FACTOR_ENERGY,
            DOMGAS_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_VOLUME')), DAYTIME) as DOMGAS_GU_FACTOR_VOLUME,
            DOMGAS_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_ENERGY')), DAYTIME) as DOMGAS_GU_FACTOR_ENERGY,
            TRAIN_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(TRAIN_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_GU_FACTOR_VOLUME')), DAYTIME) as TRAIN_GU_FACTOR_VOLUME,
            TRAIN_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(TRAIN_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_GU_FACTOR_ENERGY')), DAYTIME) as TRAIN_GU_FACTOR_ENERGY,
            EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_VOLUME')), DAYTIME) as CONFIRMED_EXCESS_VOLUME,
            EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_ENERGY')), DAYTIME) as CONFIRMED_EXCESS_ENERGY,
            EcDp_Unit.ConvertValue(REF_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_VOLUME')), DAYTIME) as REF_PROD_VOLUME,
            EcDp_Unit.ConvertValue(REF_PROD_STD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_STD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_STD_VOLUME')), DAYTIME) as REF_PROD_STD_VOLUME,
            EcDp_Unit.ConvertValue(REF_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_ENERGY')), DAYTIME) as REF_PROD_ENERGY,
            EcDp_Unit.ConvertValue(FORECAST_FEED_N2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_N2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_N2')), DAYTIME) as FORECAST_FEED_N2,
            EcDp_Unit.ConvertValue(FORECAST_FEED_CO2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_CO2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_CO2')), DAYTIME) as FORECAST_FEED_CO2,
            EcDp_Unit.ConvertValue(AGRD_CAP_LNG_EXPORT, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','AGRD_CAP_LNG_EXPORT')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','AGRD_CAP_LNG_EXPORT')), DAYTIME) as AGRD_CAP_LNG_EXPORT,
            EcDp_Unit.ConvertValue(WPT_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_NG_HHV')), DAYTIME) as WPT_NG_HHV,
            EcDp_Unit.ConvertValue(TRAIN_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_NG_HHV')), DAYTIME) as TRAIN_NG_HHV,
            EcDp_Unit.ConvertValue(DG_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DG_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DG_NG_HHV')), DAYTIME) as DG_NG_HHV,
            EcDp_Unit.ConvertValue(DOMGAS_REGAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_REGAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_REGAS')), DAYTIME) as DOMGAS_REGAS,
            EcDp_Unit.ConvertValue(IMBALANCE_ADJ_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_VOLUME')), DAYTIME) as IMBALANCE_ADJ_VOLUME,
            EcDp_Unit.ConvertValue(IMBALANCE_ADJ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_ENERGY')), DAYTIME) as IMBALANCE_ADJ_ENERGY,
            EcDp_Unit.ConvertValue(UNMET_AMOUNT_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_VOLUME')), DAYTIME) as UNMET_AMOUNT_VOLUME,
            EcDp_Unit.ConvertValue(UNMET_AMOUNT_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_ENERGY')), DAYTIME) as UNMET_AMOUNT_ENERGY
    FROM TV_CT_STAGE_PROD_PC_FCST
    WHERE data_stage_code = p_datastage_code
    AND UPPER(forecast_type) = UPPER(cp_forecast_type)
    AND probability_type = cp_probability_type
    AND daytime >= cp_start_date
    AND daytime < cp_end_date
    AND UPG = cp_UPG
    ORDER BY daytime DESC;

    --TLXT: 101266: getting the second last available if not the last available record
    CURSOR get_forecast (cp_forecast_type VARCHAR2, cp_probability_type VARCHAR2, cp_eff_date DATE, cp_record_status VARCHAR2 DEFAULT 'A') IS
    SELECT *
    FROM OV_CT_PROD_FORECAST
    WHERE daytime = cp_eff_date
    AND UPPER(forecast_type) = UPPER(cp_forecast_type)
    AND scenario = cp_probability_type
    AND RECORD_STATUS = cp_record_status
    AND CREATED_DATE =  (
          select
             min(CREATED_DATE)
          from (
               select
                  distinct(A.CREATED_DATE)
               from
                  OV_CT_PROD_FORECAST  A
    WHERE A.daytime = cp_eff_date
    AND UPPER(A.forecast_type) = UPPER(cp_forecast_type)
    AND A.scenario = cp_probability_type
    AND A.RECORD_STATUS = cp_record_status
               order by
                  CREATED_DATE desc)
               where
                  rownum<=2);

    CURSOR get_forecast_dsid (cp_forecast_type VARCHAR2, cp_eff_date DATE) IS
    SELECT *
    FROM OV_CT_PROD_FORECAST
    WHERE daytime = cp_eff_date
    AND UPPER(forecast_type) = UPPER(cp_forecast_type);

    CURSOR prod_forecast_types IS
    SELECT DISTINCT upper(forecast_type) forecast_type, upper(probability_type) probability_type, UPPER(UPG) PROFIT_CENTRE_CODE, DATA_STAGE_CODE
    FROM
    (
        SELECT data_stage_code, forecast_type, probability_type ,UPG
        FROM TV_CT_STAGE_PROD_PC_FCST
        WHERE forecast_type NOT IN('ADP_PLAN','SDS_PLAN','ERR')
    )
    WHERE data_stage_code = p_datastage_code;

    CURSOR month_starts(cp_year_type VARCHAR2, cp_datastage_code VARCHAR2, cp_forecast_type VARCHAR2, cp_probability_type VARCHAR2) IS
    SELECT DISTINCT daytime
    FROM
    (
        SELECT trunc(daytime, 'MONTH') daytime
        FROM TV_CT_STAGE_PROD_PC_FCST
        WHERE data_stage_code = cp_datastage_code
        AND UPPER(forecast_type) = UPPER(cp_forecast_type)
        AND probability_type = cp_probability_type
    );

    CURSOR year_starts(cp_year_type VARCHAR2, cp_datastage_code VARCHAR2, cp_forecast_type VARCHAR2, cp_probability_type VARCHAR2) IS
    SELECT MIN(DAYTIME) AS DAYTIME, MAX(DAYTIME) AS END_DATE FROM
    (
    SELECT DISTINCT daytime
    FROM
    (
        SELECT trunc(daytime, 'YEAR') daytime
        FROM TV_CT_STAGE_PROD_PC_FCST
        WHERE data_stage_code = cp_datastage_code
        AND UPPER(forecast_type) = UPPER(cp_forecast_type)
        AND probability_type = cp_probability_type
    )
    WHERE cp_year_type = 'CALENDAR'
    UNION ALL
    SELECT DISTINCT add_months(daytime, 3)
    FROM
    (
        SELECT trunc(add_months(daytime, -3), 'YEAR') daytime
        FROM TV_CT_STAGE_PROD_PC_FCST
        WHERE data_stage_code = cp_datastage_code
        AND UPPER(forecast_type) = UPPER(cp_forecast_type)
        AND probability_type = cp_probability_type
    )
    WHERE cp_year_type = 'LIFTING') ORDER BY DAYTIME;

    CURSOR scenarios(cp_forecast_type VARCHAR2, cp_scenario VARCHAR2, cp_daytime DATE) IS
    SELECT fcst_scen_no
    FROM OV_CT_PROD_FORECAST
    WHERE UPPER(forecast_type) = UPPER(cp_forecast_type)
    AND scenario = cp_scenario
    AND daytime = cp_daytime
    ORDER BY daytime ASC;

    CURSOR months_in_plan(cp_forecast_type VARCHAR2, cp_probability_type VARCHAR2) IS
    SELECT DISTINCT trunc(daytime, 'MON') AS daytime
    FROM TV_CT_STAGE_PROD_PC_FCST
    WHERE data_stage_code = p_datastage_code
    AND UPPER(forecast_type) = UPPER(cp_forecast_type)
    AND probability_type = cp_probability_type
    ORDER BY trunc(daytime, 'MON') DESC;

    CURSOR sds_scenarios(cp_scenario VARCHAR2) IS
    SELECT OBJECT_ID,CODE,fcst_scen_no
    FROM OV_CT_PROD_FORECAST
    WHERE UPPER(forecast_type) = 'NOMINATIONS_PLAN'
    AND scenario = cp_scenario
    ORDER BY daytime ASC;

    CURSOR DG_MORNING_DATA(cp_FORECAST_OBJECT_CODE VARCHAR2, cp_PROFIT_CENTRE_CODE VARCHAR2) IS
    SELECT FORECAST_OBJECT_CODE, PROFIT_CENTRE_CODE,DAYTIME,DOMGAS_ENERGY, DOMGAS_VOL_RATE,
    NVL((ROUND((LEAD(DOMGAS_ENERGY,1) OVER (ORDER BY DAYTIME)/3) ,6)+(DOMGAS_ENERGY-ROUND((DOMGAS_ENERGY/3),6))),DOMGAS_ENERGY) AS CALC_GAS_DAY_ENERGY,
    NVL((ROUND((LEAD(DOMGAS_VOL_RATE,1) OVER (ORDER BY DAYTIME)/3) ,6)+(DOMGAS_VOL_RATE-ROUND((DOMGAS_VOL_RATE/3),6))),DOMGAS_VOL_RATE) AS CALC_GAS_DAY_VOL_RATE
    FROM
    (
    SELECT
    FORECAST_OBJECT_CODE, PROFIT_CENTRE_CODE,DAYTIME,DOMGAS_ENERGY, DOMGAS_VOL_RATE
    FROM DV_CT_PROD_STRM_PC_FORECAST
    WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
    AND PROFIT_CENTRE_CODE = cp_PROFIT_CENTRE_CODE -- 'F_JUL_BRU'
    AND FORECAST_OBJECT_CODE = cp_FORECAST_OBJECT_CODE
    ORDER BY FORECAST_OBJECT_CODE,DAYTIME
    )CONV;

    CURSOR DG_MORNING_DATA_TOTAL(cp_FORECAST_OBJECT_CODE VARCHAR2) IS
    SELECT FORECAST_OBJECT_CODE,  DAYTIME,
    NVL((ROUND((LEAD(DOMGAS_REGAS,1) OVER (ORDER BY DAYTIME)/3) ,6)+(DOMGAS_REGAS-ROUND((DOMGAS_REGAS/3),6))),DOMGAS_REGAS) AS CALC_GAS_DOMGAS_REGAS
    FROM
    (
    SELECT
    FORECAST_OBJECT_CODE,DAYTIME, DOMGAS_REGAS
    FROM DV_CT_PROD_STRM_FORECAST
    WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
    AND FORECAST_OBJECT_CODE = cp_FORECAST_OBJECT_CODE
    ORDER BY FORECAST_OBJECT_CODE,DAYTIME
    )CONV;

    v_fcst_scen_no NUMBER;
    v_effective_daytime DATE;
    v_END_daytime DATE;
    v_plan_type VARCHAR2(256);
    v_scenario VARCHAR2(256);
    v_temp_scenario VARCHAR2(256);
    v_UPG VARCHAR2(256);
    v_UPG_id VARCHAR2(256);
    v_ds_id VARCHAR2(256);
    v_sds_id VARCHAR2(256);
    v_ds_name VARCHAR2(256);
    v_Record_status VARCHAR2(256);
    v_seq NUMBER;
    v_seq_str VARCHAR2(256);
    v_count NUMBER;
    v_count_2 NUMBER;
    v_count_ALL NUMBER;
    v_count_UPG NUMBER;
    v_avg_gcv NUMBER;
    v_avg_dens NUMBER;
    v_avg_gcv_num NUMBER;
    v_avg_gcv_den NUMBER;
    v_avg_dens_num NUMBER;
    v_avg_dens_den NUMBER;
    v_avg_gcv_pc NUMBER;
    v_avg_dens_pc NUMBER;
    v_avg_gcv_num_pc NUMBER;
    v_avg_gcv_den_pc NUMBER;
    v_avg_dens_num_pc NUMBER;
    v_avg_dens_den_pc NUMBER;
    v_sum_cond NUMBER;
    v_avg_cond_dens NUMBER;
    v_sum_cond_pc NUMBER;
    v_avg_cond_dens_pc NUMBER;
    v_avg_dens_cond_num NUMBER;
    v_avg_dens_cond_den NUMBER;
    v_avg_dens_cond_num_pc NUMBER;
    v_forecast_id_guid VARCHAR2(32);
    v_forecast_id_guid_ADP VARCHAR2(32);
    v_prev_forecast_id_guid VARCHAR2(32);
    v_DATA_STAGE_CODE VARCHAR2(32);
    v_sum_dg NUMBER;
    v_sum_dg_pc NUMBER;
    v_sum_dg_vol NUMBER;
    v_sum_dg_vol_pc NUMBER;
    v_avg_dg NUMBER;
    v_forecast_type VARCHAR2(32);

BEGIN

    -- Loop through all production forecast types in this data staging.
    FOR type_item IN prod_forecast_types LOOP
        -- Get the scenario type
        SELECT DECODE(TRIM(type_item.probability_type), 'H', 'HIGH_CONF', 'M', 'MED_CONF', 'L','LOW_CONF','R','REF_PROD','UNKNOWN') INTO v_scenario FROM DUAL;
        IF (v_scenario = 'UNKNOWN') THEN
            RAISE_APPLICATION_ERROR(-20999, 'Message probability type must be "H" or "M" or "L" or "R"  ');
        END IF;

        IF UPPER(type_item.forecast_type) = 'BUSINESS_PLAN' THEN
            v_forecast_type := 'BUSINESS_PLAN';
            FOR year_item IN year_starts('CALENDAR', p_datastage_code, type_item.forecast_type, type_item.probability_type) LOOP
                v_effective_daytime := year_item.daytime;
                v_END_daytime := ADD_MONTHS(year_item.END_DATE,12);
                v_Record_status := 'N';
                v_count_2 := 0;
                --every production profile sent by CPP has to be captured and assigned a new forecast code regardless we using it or not.
                --each preoduction profile consist of 2 UPGs and 1 Total, BUt only 1 production profile needs to be created.
                IF type_item.DATA_STAGE_CODE <> NVL(v_DATA_STAGE_CODE,'N') THEN
                    v_count := 0;
                    v_DATA_STAGE_CODE := type_item.DATA_STAGE_CODE;
                ELSE
                    v_count := 1;
                END IF;

                IF v_count = 0 THEN
                    SELECT count(*) INTO v_count_2
                    FROM OV_CT_PROD_FORECAST
                    WHERE forecast_type = v_forecast_type
                    AND scenario = v_scenario
                    AND OBJECT_START_DATE = v_effective_daytime;
                    --AND RECORD_STATUS <> 'P';
                    --INSERT INTO ASSIGN_ID(TABLENAME, MAX_ID) VALUES ('DATASETID',0);
                    --EcDp_System_Key.assignNextNumber('DATASETID', v_seq);
                    v_seq := v_count_2 + 1 ;
                    --v_ds_id:= 'ADP_'|| v_scenario || '_' || TO_CHAR(v_seq)|| '_' || to_char(TRUNC(v_effective_daytime,'YEAR'),'YYYY')  ;
                    --assign FCST_DS_ID:  [ADP/SDS]_[RP,HC,MC,LC]_[DS Code]_[YYYY]_[VERSION]
                    SELECT DECODE(TRIM(v_scenario), 'HIGH_CONF', 'HC', 'MED_CONF', 'MC', 'LOW_CONF','LC','REF_PROD','RP') INTO v_temp_scenario FROM DUAL;
                    v_ds_id:= 'BUS_'|| v_temp_scenario || '_' || p_datastage_code || '_' || to_char(TRUNC(v_effective_daytime,'YEAR'),'YYYY') || '_' || TRIM(TO_CHAR(v_seq,'009'))   ;
                    SELECT DECODE(TRIM(v_scenario), 'HIGH_CONF', 'High Conf', 'MED_CONF', 'Med Conf', 'LOW_CONF','Low Conf','REF_PROD','Ref Prod') INTO v_temp_scenario FROM DUAL;
                    v_ds_name:= 'BUS '|| v_temp_scenario || ' ' || p_datastage_code || ' ' || to_char(TRUNC(v_effective_daytime,'YEAR'),'YYYY') || '_' || TRIM(TO_CHAR(v_seq,'009'))   ;
                ELSE
                    SELECT OBJECT_ID, CODE, fcst_scen_no INTO v_forecast_id_guid, v_ds_id, v_fcst_scen_no
                    FROM OV_CT_PROD_FORECAST
                    WHERE forecast_type = v_forecast_type
                    AND scenario = v_scenario
                    AND OBJECT_START_DATE = v_effective_daytime
                    AND RECORD_STATUS = 'P'
                    and CODE = v_ds_id;
                END IF;
                --This branching is used to create a new Forecast header then copy the last available child records into this new profile.
                IF v_count = 0 THEN
                    EcDp_System_Key.assignNextNumber('CT_PROD_FORECAST', v_fcst_scen_no);
                    INSERT INTO OV_CT_PROD_FORECAST (CODE, NAME, fcst_scen_no, forecast_type, scenario, DAYTIME, OBJECT_END_DATE,FCST_CPP_ID)
                    VALUES (v_ds_id,v_ds_name,v_fcst_scen_no, v_forecast_type, v_scenario, v_effective_daytime, v_END_daytime, p_datastage_code);
                    UPDATE OV_CT_PROD_FORECAST
                    SET OBJECT_END_DATE = v_END_daytime
                    WHERE CODE = v_ds_id;

                    v_forecast_id_guid := ECDP_OBJECTS.GETOBJIDFROMCODE('CT_PROD_FORECAST',v_ds_id);
                    --intiliazed the new forecast with the previous forecast values
                    IF v_count_2 > 0 THEN
                        FOR latest_forecast in get_forecast(v_forecast_type , v_scenario , v_effective_daytime , 'P') LOOP
                            v_prev_forecast_id_guid := latest_forecast.OBJECT_ID;
                        END LOOP;
                        FOR latest_forecast in get_forecast(v_forecast_type , v_scenario , v_effective_daytime , 'V') LOOP
                            v_prev_forecast_id_guid := latest_forecast.OBJECT_ID;
                        END LOOP;
                        FOR latest_forecast in get_forecast(v_forecast_type , v_scenario , v_effective_daytime , 'A') LOOP
                            v_prev_forecast_id_guid := latest_forecast.OBJECT_ID;
                        END LOOP;

                        INSERT INTO DV_CT_PROD_STRM_FORECAST
                        (
                        FORECAST_OBJECT_ID, FCST_CPP_ID,                 object_id, daytime, forecast_type, scenario, effective_daytime,
                        COND_MASS_RATE,COND_VOL_RATE,COND_VOL_RATE_MTH,COND_DENSITY,COND_DENSITY_MTH,COND_MASS_SMPP,
                        DOMGAS_MASS_RATE,DOMGAS_VOL_RATE,DOMGAS_VOL_MTH_RATE,DOMGAS_ENERGY,DOMGAS_ENERGY_MTH,DOMGAS_HHV,DOMGAS_SMPP,DOMGAS_REGAS,DOMGAS_MIN_RATE_ENERGY,
                        LNG_HHV_STD,LNG_MASS_RATE,LNG_VOL_RATE,LNG_VOL_RATE_MTH,LNG_DENSITY,LNG_DENSITY_MTH,LNG_HHV,LNG_HHV_MTH,LNG_HHV_VOL_MTH,LNG_MASS_SMPP,LNG_REGAS_REQ_ENERGY,LNG_REGAS_REQ_GAS,LNG_REGAS_REQ_LNG,LNG_EXCESS_PROD,LNG_EXCESS_PROD_ENERGY,LNG_EXCESS_PROD_VOLUME,
                        ADP_LNG_REQ_ENERGY,ADP_LNG_REQ_VOLUME,AGRD_CAP_LNG_EXPORT,CONFIRMED_EXCESS_ENERGY,CONFIRMED_EXCESS_QTY,CONFIRMED_EXCESS_VOLUME,LNG_BL_ENERGY,LNG_BL_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,DOMGAS_GU_FACTOR_VOLUME,DG_NG_HHV,TRAIN_GU_FACTOR_ENERGY,TRAIN_GU_FACTOR_VOLUME,TRAIN_NG_HHV,WPT_GU_FACTOR_ENERGY,WPT_GU_FACTOR_VOLUME,
                        WPT_NG_HHV,FORECAST_FEED_CO2,FORECAST_FEED_N2,REF_PROD_ENERGY,REF_PROD_STD_VOLUME,REF_PROD_VOLUME,LNG_NET_RUNDOWN_CAP,PLATFORM_MASS_SMPP,
                        IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY
                        )
                        SELECT     v_forecast_id_guid, p_datastage_code,     object_id, daytime, forecast_type, scenario, effective_daytime,
                        COND_MASS_RATE,COND_VOL_RATE,COND_VOL_RATE_MTH,COND_DENSITY,COND_DENSITY_MTH,COND_MASS_SMPP,
                        DOMGAS_MASS_RATE,DOMGAS_VOL_RATE,DOMGAS_VOL_MTH_RATE,DOMGAS_ENERGY,DOMGAS_ENERGY_MTH,DOMGAS_HHV,DOMGAS_SMPP,DOMGAS_REGAS,DOMGAS_MIN_RATE_ENERGY,
                        LNG_HHV_STD,LNG_MASS_RATE,LNG_VOL_RATE,LNG_VOL_RATE_MTH,LNG_DENSITY,LNG_DENSITY_MTH,LNG_HHV,LNG_HHV_MTH,LNG_HHV_VOL_MTH,LNG_MASS_SMPP,LNG_REGAS_REQ_ENERGY,LNG_REGAS_REQ_GAS,LNG_REGAS_REQ_LNG,LNG_EXCESS_PROD,LNG_EXCESS_PROD_ENERGY,LNG_EXCESS_PROD_VOLUME,
                        ADP_LNG_REQ_ENERGY,ADP_LNG_REQ_VOLUME,AGRD_CAP_LNG_EXPORT,CONFIRMED_EXCESS_ENERGY,CONFIRMED_EXCESS_QTY,CONFIRMED_EXCESS_VOLUME,LNG_BL_ENERGY,LNG_BL_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,DOMGAS_GU_FACTOR_VOLUME,DG_NG_HHV,TRAIN_GU_FACTOR_ENERGY,TRAIN_GU_FACTOR_VOLUME,TRAIN_NG_HHV,WPT_GU_FACTOR_ENERGY,WPT_GU_FACTOR_VOLUME,
                        WPT_NG_HHV,FORECAST_FEED_CO2,FORECAST_FEED_N2,REF_PROD_ENERGY,REF_PROD_STD_VOLUME,REF_PROD_VOLUME,LNG_NET_RUNDOWN_CAP,PLATFORM_MASS_SMPP,
                        IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY
                        FROM DV_CT_PROD_STRM_FORECAST
                        WHERE FORECAST_OBJECT_ID = v_prev_forecast_id_guid
                        AND forecast_type = v_forecast_type
                        AND scenario = v_scenario
                        AND effective_daytime = v_effective_daytime;

                        INSERT INTO DV_CT_PROD_STRM_PC_FORECAST
                        (        PROFIT_CENTRE_ID,FORECAST_OBJECT_ID, FCST_CPP_ID,         object_id, daytime, forecast_type, scenario, effective_daytime,
                        COND_MASS_RATE,COND_VOL_RATE,COND_VOL_RATE_MTH,COND_DENSITY,COND_DENSITY_MTH,COND_MASS_SMPP,
                        DOMGAS_MASS_RATE,DOMGAS_VOL_RATE,DOMGAS_VOL_MTH_RATE,DOMGAS_ENERGY,DOMGAS_ENERGY_MTH,DOMGAS_HHV,DOMGAS_SMPP,DOMGAS_REGAS,DOMGAS_MIN_RATE_ENERGY,
                        LNG_HHV_STD,LNG_MASS_RATE,LNG_VOL_RATE,LNG_VOL_RATE_MTH,LNG_DENSITY,LNG_DENSITY_MTH,LNG_HHV,LNG_HHV_MTH,LNG_HHV_VOL_MTH,LNG_MASS_SMPP,LNG_REGAS_REQ_ENERGY,LNG_REGAS_REQ_GAS,LNG_REGAS_REQ_LNG,LNG_EXCESS_PROD,LNG_EXCESS_PROD_ENERGY,LNG_EXCESS_PROD_VOLUME,
                        ADP_LNG_REQ_ENERGY,ADP_LNG_REQ_VOLUME,AGRD_CAP_LNG_EXPORT,CONFIRMED_EXCESS_ENERGY,CONFIRMED_EXCESS_QTY,CONFIRMED_EXCESS_VOLUME,LNG_BL_ENERGY,LNG_BL_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,DOMGAS_GU_FACTOR_VOLUME,DG_NG_HHV,TRAIN_GU_FACTOR_ENERGY,TRAIN_GU_FACTOR_VOLUME,TRAIN_NG_HHV,WPT_GU_FACTOR_ENERGY,WPT_GU_FACTOR_VOLUME,
                        WPT_NG_HHV,FORECAST_FEED_CO2,FORECAST_FEED_N2,REF_PROD_ENERGY,REF_PROD_STD_VOLUME,REF_PROD_VOLUME,LNG_NET_RUNDOWN_CAP,PLATFORM_MASS_SMPP,
                        IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY
                        )
                        SELECT     PROFIT_CENTRE_ID,v_forecast_id_guid, p_datastage_code,     object_id, daytime, forecast_type, scenario, effective_daytime,
                        COND_MASS_RATE,COND_VOL_RATE,COND_VOL_RATE_MTH,COND_DENSITY,COND_DENSITY_MTH,COND_MASS_SMPP,
                        DOMGAS_MASS_RATE,DOMGAS_VOL_RATE,DOMGAS_VOL_MTH_RATE,DOMGAS_ENERGY,DOMGAS_ENERGY_MTH,DOMGAS_HHV,DOMGAS_SMPP,DOMGAS_REGAS,DOMGAS_MIN_RATE_ENERGY,
                        LNG_HHV_STD,LNG_MASS_RATE,LNG_VOL_RATE,LNG_VOL_RATE_MTH,LNG_DENSITY,LNG_DENSITY_MTH,LNG_HHV,LNG_HHV_MTH,LNG_HHV_VOL_MTH,LNG_MASS_SMPP,LNG_REGAS_REQ_ENERGY,LNG_REGAS_REQ_GAS,LNG_REGAS_REQ_LNG,LNG_EXCESS_PROD,LNG_EXCESS_PROD_ENERGY,LNG_EXCESS_PROD_VOLUME,
                        ADP_LNG_REQ_ENERGY,ADP_LNG_REQ_VOLUME,AGRD_CAP_LNG_EXPORT,CONFIRMED_EXCESS_ENERGY,CONFIRMED_EXCESS_QTY,CONFIRMED_EXCESS_VOLUME,LNG_BL_ENERGY,LNG_BL_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,DOMGAS_GU_FACTOR_VOLUME,DG_NG_HHV,TRAIN_GU_FACTOR_ENERGY,TRAIN_GU_FACTOR_VOLUME,TRAIN_NG_HHV,WPT_GU_FACTOR_ENERGY,WPT_GU_FACTOR_VOLUME,
                        WPT_NG_HHV,FORECAST_FEED_CO2,FORECAST_FEED_N2,REF_PROD_ENERGY,REF_PROD_STD_VOLUME,REF_PROD_VOLUME,LNG_NET_RUNDOWN_CAP,PLATFORM_MASS_SMPP,
                        IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY
                        FROM DV_CT_PROD_STRM_PC_FORECAST
                        WHERE FORECAST_OBJECT_ID = v_prev_forecast_id_guid
                        AND forecast_type = v_forecast_type
                        AND scenario = v_scenario
                        AND effective_daytime = v_effective_daytime;
                    END IF;

                END IF;
                -- Loop through the values in the staging and update the records in the new profile
                FOR value_item IN prod_forecast_stage(type_item.forecast_type, type_item.probability_type, v_effective_daytime, v_END_daytime, type_item.PROFIT_CENTRE_CODE) LOOP
                    -- Get the PROFIT_CENTRE_CODE
                    SELECT DECODE(TRIM(value_item.PROFIT_CENTRE_CODE), 'F_WST_IAGO', 'F_WST_IAGO', 'F_JUL_BRU', 'F_JUL_BRU','ALL','ALL','UNKNOWN') INTO v_UPG FROM DUAL;
                    IF (v_UPG = 'UNKNOWN') THEN
                        RAISE_APPLICATION_ERROR(-20998, 'Message UPG Code type must be "F_WST_IAGO" or "F_JUL_BRU" or "ALL" ');
                    END IF;
                    v_UPG_id := ECDP_OBJECTS.GETOBJIDFROMCODE('FIELD',v_UPG);
                    SELECT count(*) INTO v_count_ALL
                    FROM DV_CT_PROD_STRM_FORECAST
                    WHERE FORECAST_OBJECT_CODE = v_ds_id
                    AND forecast_type = v_forecast_type
                    AND scenario = v_scenario
                    AND effective_daytime = v_effective_daytime
                    AND daytime = value_item.daytime;

                    SELECT count(*) INTO v_count_UPG
                    FROM DV_CT_PROD_STRM_PC_FORECAST
                    WHERE FORECAST_OBJECT_CODE = v_ds_id
                    AND forecast_type = v_forecast_type
                    AND scenario = v_scenario
                    AND effective_daytime = v_effective_daytime
                    AND daytime = value_item.daytime
                    AND PROFIT_CENTRE_ID = v_UPG_id;

                    IF v_UPG = 'ALL' THEN
                        IF v_count_ALL = 0 THEN
                            -- LNG Rate
                            INSERT INTO DV_CT_PROD_STRM_FORECAST(FORECAST_OBJECT_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                            ,LNG_VOL_RATE,LNG_MASS_RATE,LNG_MASS_SMPP,LNG_HHV,LNG_EXCESS_PROD,LNG_DENSITY,CONFIRMED_EXCESS_QTY, LNG_HHV_STD
                            ,LNG_BL_VOLUME,LNG_BL_ENERGY,LNG_EXCESS_PROD_VOLUME,LNG_EXCESS_PROD_ENERGY,ADP_LNG_REQ_VOLUME,ADP_LNG_REQ_ENERGY,LNG_REGAS_REQ_GAS,LNG_REGAS_REQ_LNG,LNG_REGAS_REQ_ENERGY
                            ,TRAIN_GU_FACTOR_VOLUME,TRAIN_GU_FACTOR_ENERGY,CONFIRMED_EXCESS_VOLUME,CONFIRMED_EXCESS_ENERGY,AGRD_CAP_LNG_EXPORT,TRAIN_NG_HHV
                            ,IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY
                            )
                            VALUES (v_forecast_id_guid, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                            ,value_item.LNG_VOL_RATE,value_item.LNG_MASS_RATE,value_item.LNG_MASS_SMPP,value_item.LNG_HHV,value_item.LNG_EXCESS_PROD,value_item.LNG_DENSITY,value_item.CONFIRMED_EXCESS_QTY,value_item.LNG_HHV_STD
                            ,value_item.LNG_BL_VOLUME,value_item.LNG_BL_ENERGY,value_item.LNG_EXCESS_PROD_VOLUME,value_item.LNG_EXCESS_PROD_ENERGY,value_item.ADP_LNG_REQ_VOLUME,value_item.ADP_LNG_REQ_ENERGY,value_item.LNG_REGAS_REQ_GAS,value_item.LNG_REGAS_REQ_LNG,value_item.LNG_REGAS_REQ_ENERGY
                            ,value_item.TRAIN_GU_FACTOR_VOLUME,value_item.TRAIN_GU_FACTOR_ENERGY,value_item.CONFIRMED_EXCESS_VOLUME,value_item.CONFIRMED_EXCESS_ENERGY,value_item.AGRD_CAP_LNG_EXPORT,value_item.TRAIN_NG_HHV
                            ,value_item.IMBALANCE_ADJ_VOLUME,value_item.IMBALANCE_ADJ_ENERGY,value_item.UNMET_AMOUNT_VOLUME,value_item.UNMET_AMOUNT_ENERGY
                            );
                            -- Cond Rate
                            INSERT INTO DV_CT_PROD_STRM_FORECAST(FORECAST_OBJECT_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                            , COND_VOL_RATE, cond_mass_rate,COND_DENSITY, COND_MASS_SMPP
                            )
                            VALUES (v_forecast_id_guid, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_COND_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                            , value_item.COND_VOL_RATE, value_item.cond_mass_rate,value_item.COND_DENSITY, value_item.COND_MASS_SMPP);
                            -- DOMGAS Rate
                            INSERT INTO DV_CT_PROD_STRM_FORECAST(FORECAST_OBJECT_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                            ,DOMGAS_MIN_RATE_ENERGY, DOMGAS_SMPP,DOMGAS_MASS_RATE,DOMGAS_ENERGY,DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_GU_FACTOR_VOLUME,DOMGAS_GU_FACTOR_ENERGY,REF_PROD_VOLUME,REF_PROD_STD_VOLUME,REF_PROD_ENERGY,DG_NG_HHV,DOMGAS_REGAS
                            )
                            VALUES (v_forecast_id_guid, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                            ,value_item.DOMGAS_MIN_RATE_ENERGY, value_item.DOMGAS_SMPP,value_item.DOMGAS_MASS_RATE,value_item.DOMGAS_ENERGY,value_item.DOMGAS_HHV,value_item.DOMGAS_VOL_RATE,value_item.DOMGAS_GU_FACTOR_VOLUME,value_item.DOMGAS_GU_FACTOR_ENERGY,value_item.REF_PROD_VOLUME,value_item.REF_PROD_STD_VOLUME,value_item.REF_PROD_ENERGY,value_item.DG_NG_HHV, value_item.DOMGAS_REGAS
                            );
                            -- NG Rate
                            INSERT INTO DV_CT_PROD_STRM_FORECAST(FORECAST_OBJECT_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                            ,PLATFORM_MASS_SMPP,WPT_GU_FACTOR_VOLUME,WPT_GU_FACTOR_ENERGY,FORECAST_FEED_N2,FORECAST_FEED_CO2,WPT_NG_HHV
                            )
                            VALUES (v_forecast_id_guid, p_datastage_code,  ec_stream.object_id_by_uk('SW_PL_NG_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                            ,value_item.PLATFORM_MASS_SMPP,value_item.WPT_GU_FACTOR_VOLUME,value_item.WPT_GU_FACTOR_ENERGY,value_item.FORECAST_FEED_N2,value_item.FORECAST_FEED_CO2,value_item.WPT_NG_HHV
                            );
                        ELSE
                            -- LNG Rate
                            UPDATE DV_CT_PROD_STRM_FORECAST
                            SET FCST_CPP_ID = p_datastage_code,
                                LNG_VOL_RATE=value_item.LNG_VOL_RATE,
                                LNG_MASS_RATE=value_item.LNG_MASS_RATE,
                                LNG_MASS_SMPP=value_item.LNG_MASS_SMPP,
                                LNG_HHV=value_item.LNG_HHV,
                                LNG_EXCESS_PROD=value_item.LNG_EXCESS_PROD,
                                LNG_DENSITY=value_item.LNG_DENSITY,
                                CONFIRMED_EXCESS_QTY=value_item.CONFIRMED_EXCESS_QTY,
                                LNG_HHV_STD=value_item.LNG_HHV_STD,
                                LNG_BL_VOLUME=value_item.LNG_BL_VOLUME,
                                LNG_BL_ENERGY=value_item.LNG_BL_ENERGY,
                                LNG_EXCESS_PROD_VOLUME=value_item.LNG_EXCESS_PROD_VOLUME,
                                LNG_EXCESS_PROD_ENERGY=value_item.LNG_EXCESS_PROD_ENERGY,
                                ADP_LNG_REQ_VOLUME=value_item.ADP_LNG_REQ_VOLUME,
                                ADP_LNG_REQ_ENERGY=value_item.ADP_LNG_REQ_ENERGY,
                                LNG_REGAS_REQ_GAS=value_item.LNG_REGAS_REQ_GAS,
                                LNG_REGAS_REQ_LNG=value_item.LNG_REGAS_REQ_LNG,
                                LNG_REGAS_REQ_ENERGY=value_item.LNG_REGAS_REQ_ENERGY,
                                TRAIN_GU_FACTOR_VOLUME=value_item.TRAIN_GU_FACTOR_VOLUME,
                                TRAIN_GU_FACTOR_ENERGY=value_item.TRAIN_GU_FACTOR_ENERGY,
                                CONFIRMED_EXCESS_VOLUME=value_item.CONFIRMED_EXCESS_VOLUME,
                                CONFIRMED_EXCESS_ENERGY=value_item.CONFIRMED_EXCESS_ENERGY,
                                AGRD_CAP_LNG_EXPORT=value_item.AGRD_CAP_LNG_EXPORT,
                                TRAIN_NG_HHV=value_item.TRAIN_NG_HHV,
                                IMBALANCE_ADJ_VOLUME = value_item.IMBALANCE_ADJ_VOLUME,
                                IMBALANCE_ADJ_ENERGY = value_item.IMBALANCE_ADJ_ENERGY,
                                UNMET_AMOUNT_VOLUME = value_item.UNMET_AMOUNT_VOLUME,
                                UNMET_AMOUNT_ENERGY = value_item.UNMET_AMOUNT_ENERGY
                            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = value_item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');
                            -- Cond Rate
                            UPDATE DV_CT_PROD_STRM_FORECAST
                            SET FCST_CPP_ID = p_datastage_code,
                                COND_VOL_RATE=value_item.COND_VOL_RATE,
                                cond_mass_rate=value_item.cond_mass_rate,
                                COND_DENSITY=value_item.COND_DENSITY,
                                COND_MASS_SMPP=value_item.COND_MASS_SMPP
                            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = value_item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');

                            --SPECIAL CONDITION AS CP ALREADY WENT LIVE WITHOUT DOMGAS
                            -- DOMGAS Rate
                            SELECT count(*) INTO v_count_ALL
                            FROM DV_CT_PROD_STRM_FORECAST
                            WHERE FORECAST_OBJECT_CODE = v_ds_id
                            AND forecast_type = v_forecast_type
                            AND scenario = v_scenario
                            AND effective_daytime = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                            AND daytime = value_item.daytime;
                            IF v_count_ALL = 0 THEN
                                -- DOMGAS Rate
                                INSERT INTO DV_CT_PROD_STRM_FORECAST(FORECAST_OBJECT_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                                ,DOMGAS_MIN_RATE_ENERGY,DOMGAS_SMPP, DOMGAS_MASS_RATE,DOMGAS_ENERGY,DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_GU_FACTOR_VOLUME,DOMGAS_GU_FACTOR_ENERGY,REF_PROD_VOLUME,REF_PROD_STD_VOLUME,REF_PROD_ENERGY,DG_NG_HHV,DOMGAS_REGAS
                                )
                                VALUES (v_forecast_id_guid, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                                ,value_item.DOMGAS_MIN_RATE_ENERGY,value_item.DOMGAS_SMPP, value_item.DOMGAS_MASS_RATE,value_item.DOMGAS_ENERGY,value_item.DOMGAS_HHV,value_item.DOMGAS_VOL_RATE,value_item.DOMGAS_GU_FACTOR_VOLUME,value_item.DOMGAS_GU_FACTOR_ENERGY,value_item.REF_PROD_VOLUME,value_item.REF_PROD_STD_VOLUME,value_item.REF_PROD_ENERGY,value_item.DG_NG_HHV,value_item.DOMGAS_REGAS
                                );
                            ELSE
                                UPDATE DV_CT_PROD_STRM_FORECAST
                                SET FCST_CPP_ID = p_datastage_code,
                                    DOMGAS_MIN_RATE_ENERGY = value_item.DOMGAS_MIN_RATE_ENERGY,
                                    DOMGAS_SMPP = value_item.DOMGAS_SMPP,
                                    DOMGAS_MASS_RATE=value_item.DOMGAS_MASS_RATE,
                                    DOMGAS_ENERGY=value_item.DOMGAS_ENERGY,
                                    DOMGAS_HHV=value_item.DOMGAS_HHV,
                                    DOMGAS_VOL_RATE=value_item.DOMGAS_VOL_RATE,
                                    DOMGAS_GU_FACTOR_VOLUME=value_item.DOMGAS_GU_FACTOR_VOLUME,
                                    DOMGAS_GU_FACTOR_ENERGY=value_item.DOMGAS_GU_FACTOR_ENERGY,
                                    REF_PROD_VOLUME=value_item.REF_PROD_VOLUME,
                                    REF_PROD_STD_VOLUME=value_item.REF_PROD_STD_VOLUME,
                                    REF_PROD_ENERGY=value_item.REF_PROD_ENERGY,
                                    DG_NG_HHV=value_item.DG_NG_HHV,
                                    DOMGAS_REGAS=value_item.DOMGAS_REGAS
                                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = value_item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                                AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');
                            END IF;
                            --SPECIAL CONDITION AS CP ALREADY WENT LIVE WITHOUT NG
                            -- NG Rate
                            SELECT count(*) INTO v_count_ALL
                            FROM DV_CT_PROD_STRM_FORECAST
                            WHERE FORECAST_OBJECT_CODE = v_ds_id
                            AND forecast_type = v_forecast_type
                            AND scenario = v_scenario
                            AND effective_daytime = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_PL_NG_FORECAST')
                            AND daytime = value_item.daytime;
                            IF v_count_ALL = 0 THEN
                                -- NG Rate
                                INSERT INTO DV_CT_PROD_STRM_FORECAST(FORECAST_OBJECT_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                                ,PLATFORM_MASS_SMPP,WPT_GU_FACTOR_VOLUME,WPT_GU_FACTOR_ENERGY,FORECAST_FEED_N2,FORECAST_FEED_CO2,WPT_NG_HHV
                                )
                                VALUES (v_forecast_id_guid, p_datastage_code,  ec_stream.object_id_by_uk('SW_PL_NG_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                                ,value_item.PLATFORM_MASS_SMPP,value_item.WPT_GU_FACTOR_VOLUME,value_item.WPT_GU_FACTOR_ENERGY,value_item.FORECAST_FEED_N2,value_item.FORECAST_FEED_CO2,value_item.WPT_NG_HHV
                                );
                            ELSE
                                UPDATE DV_CT_PROD_STRM_FORECAST
                                SET FCST_CPP_ID = p_datastage_code,
                                    PLATFORM_MASS_SMPP=value_item.PLATFORM_MASS_SMPP,
                                    WPT_GU_FACTOR_VOLUME=value_item.WPT_GU_FACTOR_VOLUME,
                                    WPT_GU_FACTOR_ENERGY=value_item.WPT_GU_FACTOR_ENERGY,
                                    FORECAST_FEED_N2=value_item.FORECAST_FEED_N2,
                                    FORECAST_FEED_CO2=value_item.FORECAST_FEED_CO2,
                                    WPT_NG_HHV=value_item.WPT_NG_HHV
                                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = value_item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                                AND object_id = ec_stream.object_id_by_uk('SW_PL_NG_FORECAST');
                            END IF;
                        END IF;
                    ELSE
                        IF v_count_UPG = 0 THEN
                            --Specific UPG
                            -- insert to UPG CT class:CT_PROD_STRM_PC_FORECAST
                            -- LNG Rate
                            -- LNG Rate
                            INSERT INTO DV_CT_PROD_STRM_PC_FORECAST(FORECAST_OBJECT_ID,PROFIT_CENTRE_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                            ,LNG_VOL_RATE,LNG_MASS_RATE,LNG_MASS_SMPP,LNG_HHV,LNG_EXCESS_PROD,LNG_DENSITY,CONFIRMED_EXCESS_QTY,LNG_HHV_STD
                            ,LNG_BL_VOLUME ,LNG_BL_ENERGY,LNG_EXCESS_PROD_VOLUME,LNG_EXCESS_PROD_ENERGY, ADP_LNG_REQ_VOLUME,ADP_LNG_REQ_ENERGY,LNG_REGAS_REQ_GAS,LNG_REGAS_REQ_LNG,LNG_REGAS_REQ_ENERGY
                            ,TRAIN_GU_FACTOR_VOLUME,TRAIN_GU_FACTOR_ENERGY,CONFIRMED_EXCESS_VOLUME,CONFIRMED_EXCESS_ENERGY,AGRD_CAP_LNG_EXPORT,TRAIN_NG_HHV
                            ,IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY
                            )
                            VALUES (v_forecast_id_guid,v_UPG_id, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                            ,value_item.LNG_VOL_RATE,value_item.LNG_MASS_RATE,value_item.LNG_MASS_SMPP,value_item.LNG_HHV,value_item.LNG_EXCESS_PROD,value_item.LNG_DENSITY,value_item.CONFIRMED_EXCESS_QTY,value_item.LNG_HHV_STD
                            ,value_item.LNG_BL_VOLUME,value_item.LNG_BL_ENERGY,value_item.LNG_EXCESS_PROD_VOLUME,value_item.LNG_EXCESS_PROD_ENERGY, value_item.ADP_LNG_REQ_VOLUME,value_item.ADP_LNG_REQ_ENERGY,value_item.LNG_REGAS_REQ_GAS,value_item.LNG_REGAS_REQ_LNG,value_item.LNG_REGAS_REQ_ENERGY
                            ,value_item.TRAIN_GU_FACTOR_VOLUME,value_item.TRAIN_GU_FACTOR_ENERGY,value_item.CONFIRMED_EXCESS_VOLUME,value_item.CONFIRMED_EXCESS_ENERGY,value_item.AGRD_CAP_LNG_EXPORT,value_item.TRAIN_NG_HHV
                            ,value_item.IMBALANCE_ADJ_VOLUME,value_item.IMBALANCE_ADJ_ENERGY,value_item.UNMET_AMOUNT_VOLUME,value_item.UNMET_AMOUNT_ENERGY
                            );
                            -- Cond Rate
                            INSERT INTO DV_CT_PROD_STRM_PC_FORECAST(FORECAST_OBJECT_ID,PROFIT_CENTRE_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                            , COND_VOL_RATE, cond_mass_rate,COND_DENSITY, COND_MASS_SMPP
                            )
                            VALUES (v_forecast_id_guid,v_UPG_id, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_COND_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                            , value_item.COND_VOL_RATE, value_item.cond_mass_rate,value_item.COND_DENSITY, value_item.COND_MASS_SMPP);
                            -- DOMGAS Rate
                            INSERT INTO DV_CT_PROD_STRM_PC_FORECAST(FORECAST_OBJECT_ID,PROFIT_CENTRE_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                            ,DOMGAS_SMPP ,DOMGAS_MASS_RATE,DOMGAS_ENERGY,DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_GU_FACTOR_VOLUME,DOMGAS_GU_FACTOR_ENERGY,REF_PROD_VOLUME,REF_PROD_STD_VOLUME,REF_PROD_ENERGY,DG_NG_HHV,DOMGAS_REGAS
                            )
                            VALUES (v_forecast_id_guid,v_UPG_id, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                            ,value_item.DOMGAS_SMPP,value_item.DOMGAS_MASS_RATE,value_item.DOMGAS_ENERGY,value_item.DOMGAS_HHV,value_item.DOMGAS_VOL_RATE,value_item.DOMGAS_GU_FACTOR_VOLUME,value_item.DOMGAS_GU_FACTOR_ENERGY,value_item.REF_PROD_VOLUME,value_item.REF_PROD_STD_VOLUME,value_item.REF_PROD_ENERGY,value_item.DG_NG_HHV, value_item.DOMGAS_REGAS
                            );
                            -- NG Rate
                            INSERT INTO DV_CT_PROD_STRM_PC_FORECAST(FORECAST_OBJECT_ID, PROFIT_CENTRE_ID,FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                            ,PLATFORM_MASS_SMPP,WPT_GU_FACTOR_VOLUME,WPT_GU_FACTOR_ENERGY,FORECAST_FEED_N2,FORECAST_FEED_CO2,WPT_NG_HHV
                            )
                            VALUES (v_forecast_id_guid,v_UPG_id, p_datastage_code,  ec_stream.object_id_by_uk('SW_PL_NG_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                            ,value_item.PLATFORM_MASS_SMPP,value_item.WPT_GU_FACTOR_VOLUME,value_item.WPT_GU_FACTOR_ENERGY,value_item.FORECAST_FEED_N2,value_item.FORECAST_FEED_CO2,value_item.WPT_NG_HHV
                            );
                        ELSE
                            -- LNG Rate
                            UPDATE DV_CT_PROD_STRM_PC_FORECAST
                            SET FCST_CPP_ID = p_datastage_code,
                                LNG_VOL_RATE=value_item.LNG_VOL_RATE,
                                LNG_MASS_RATE=value_item.LNG_MASS_RATE,
                                LNG_MASS_SMPP=value_item.LNG_MASS_SMPP,
                                LNG_HHV=value_item.LNG_HHV,
                                LNG_EXCESS_PROD=value_item.LNG_EXCESS_PROD,
                                LNG_DENSITY=value_item.LNG_DENSITY,
                                CONFIRMED_EXCESS_QTY=value_item.CONFIRMED_EXCESS_QTY,
                                LNG_HHV_STD=value_item.LNG_HHV_STD,
                                LNG_BL_VOLUME=value_item.LNG_BL_VOLUME,
                                LNG_BL_ENERGY=value_item.LNG_BL_ENERGY,
                                LNG_EXCESS_PROD_VOLUME=value_item.LNG_EXCESS_PROD_VOLUME,
                                LNG_EXCESS_PROD_ENERGY=value_item.LNG_EXCESS_PROD_ENERGY,
                                ADP_LNG_REQ_VOLUME=value_item.ADP_LNG_REQ_VOLUME,
                                ADP_LNG_REQ_ENERGY=value_item.ADP_LNG_REQ_ENERGY,
                                LNG_REGAS_REQ_GAS=value_item.LNG_REGAS_REQ_GAS,
                                LNG_REGAS_REQ_LNG=value_item.LNG_REGAS_REQ_LNG,
                                LNG_REGAS_REQ_ENERGY=value_item.LNG_REGAS_REQ_ENERGY,
                                TRAIN_GU_FACTOR_VOLUME=value_item.TRAIN_GU_FACTOR_VOLUME,
                                TRAIN_GU_FACTOR_ENERGY=value_item.TRAIN_GU_FACTOR_ENERGY,
                                CONFIRMED_EXCESS_VOLUME=value_item.CONFIRMED_EXCESS_VOLUME,
                                CONFIRMED_EXCESS_ENERGY=value_item.CONFIRMED_EXCESS_ENERGY,
                                AGRD_CAP_LNG_EXPORT=value_item.AGRD_CAP_LNG_EXPORT,
                                TRAIN_NG_HHV=value_item.TRAIN_NG_HHV,
                                IMBALANCE_ADJ_VOLUME = value_item.IMBALANCE_ADJ_VOLUME,
                                IMBALANCE_ADJ_ENERGY = value_item.IMBALANCE_ADJ_ENERGY,
                                UNMET_AMOUNT_VOLUME = value_item.UNMET_AMOUNT_VOLUME,
                                UNMET_AMOUNT_ENERGY = value_item.UNMET_AMOUNT_ENERGY
                            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = value_item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');
                            -- Cond Rate
                            UPDATE DV_CT_PROD_STRM_PC_FORECAST
                            SET FCST_CPP_ID = p_datastage_code,
                                COND_VOL_RATE=value_item.COND_VOL_RATE,
                                cond_mass_rate=value_item.cond_mass_rate,
                                COND_DENSITY=value_item.COND_DENSITY,
                                COND_MASS_SMPP=value_item.COND_MASS_SMPP
                            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = value_item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');

                            --SPECIAL CONDITION AS CP ALREADY WENT LIVE WITHOUT DOMGAS
                            -- DOMGAS Rate
                            SELECT count(*) INTO v_count_ALL
                            FROM DV_CT_PROD_STRM_PC_FORECAST
                            WHERE FORECAST_OBJECT_CODE = v_ds_id
                            AND PROFIT_CENTRE_ID = v_UPG_id
                            AND forecast_type = v_forecast_type
                            AND scenario = v_scenario
                            AND effective_daytime = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                            AND daytime = value_item.daytime;
                            IF v_count_ALL = 0 THEN
                                -- DOMGAS Rate
                                INSERT INTO DV_CT_PROD_STRM_PC_FORECAST(FORECAST_OBJECT_ID,PROFIT_CENTRE_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                                ,DOMGAS_SMPP ,DOMGAS_MASS_RATE,DOMGAS_ENERGY,DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_GU_FACTOR_VOLUME,DOMGAS_GU_FACTOR_ENERGY,REF_PROD_VOLUME,REF_PROD_STD_VOLUME,REF_PROD_ENERGY,DG_NG_HHV,DOMGAS_REGAS
                                )
                                VALUES (v_forecast_id_guid,v_UPG_id, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                                ,value_item.DOMGAS_SMPP,value_item.DOMGAS_MASS_RATE,value_item.DOMGAS_ENERGY,value_item.DOMGAS_HHV,value_item.DOMGAS_VOL_RATE,value_item.DOMGAS_GU_FACTOR_VOLUME,value_item.DOMGAS_GU_FACTOR_ENERGY,value_item.REF_PROD_VOLUME,value_item.REF_PROD_STD_VOLUME,value_item.REF_PROD_ENERGY,value_item.DG_NG_HHV, value_item.DOMGAS_REGAS
                                );
                            ELSE
                                UPDATE DV_CT_PROD_STRM_PC_FORECAST
                                SET FCST_CPP_ID = p_datastage_code,
                                    DOMGAS_SMPP = value_item.DOMGAS_SMPP,
                                    DOMGAS_MASS_RATE=value_item.DOMGAS_MASS_RATE,
                                    DOMGAS_ENERGY=value_item.DOMGAS_ENERGY,
                                    DOMGAS_HHV=value_item.DOMGAS_HHV,
                                    DOMGAS_VOL_RATE=value_item.DOMGAS_VOL_RATE,
                                    DOMGAS_GU_FACTOR_VOLUME=value_item.DOMGAS_GU_FACTOR_VOLUME,
                                    DOMGAS_GU_FACTOR_ENERGY=value_item.DOMGAS_GU_FACTOR_ENERGY,
                                    REF_PROD_VOLUME=value_item.REF_PROD_VOLUME,
                                    REF_PROD_STD_VOLUME=value_item.REF_PROD_STD_VOLUME,
                                    REF_PROD_ENERGY=value_item.REF_PROD_ENERGY,
                                    DG_NG_HHV=value_item.DG_NG_HHV,
                                    DOMGAS_REGAS=value_item.DOMGAS_REGAS
                                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = value_item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                                AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');
                            END IF;
                            --SPECIAL CONDITION AS CP ALREADY WENT LIVE WITHOUT NG
                            -- NG Rate
                            SELECT count(*) INTO v_count_ALL
                            FROM DV_CT_PROD_STRM_PC_FORECAST
                            WHERE FORECAST_OBJECT_CODE = v_ds_id
                            AND PROFIT_CENTRE_ID = v_UPG_id
                            AND forecast_type = v_forecast_type
                            AND scenario = v_scenario
                            AND effective_daytime = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_PL_NG_FORECAST')
                            AND daytime = value_item.daytime;
                            IF v_count_ALL = 0 THEN
                                -- NG Rate
                                INSERT INTO DV_CT_PROD_STRM_PC_FORECAST(FORECAST_OBJECT_ID,PROFIT_CENTRE_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                                ,PLATFORM_MASS_SMPP,WPT_GU_FACTOR_VOLUME,WPT_GU_FACTOR_ENERGY,FORECAST_FEED_N2,FORECAST_FEED_CO2,WPT_NG_HHV
                                )
                                VALUES (v_forecast_id_guid,v_UPG_id, p_datastage_code,  ec_stream.object_id_by_uk('SW_PL_NG_FORECAST'), value_item.daytime, v_forecast_type, v_scenario, v_effective_daytime
                                ,value_item.PLATFORM_MASS_SMPP,value_item.WPT_GU_FACTOR_VOLUME,value_item.WPT_GU_FACTOR_ENERGY,value_item.FORECAST_FEED_N2,value_item.FORECAST_FEED_CO2,value_item.WPT_NG_HHV
                                );
                            ELSE
                                UPDATE DV_CT_PROD_STRM_PC_FORECAST
                                SET FCST_CPP_ID = p_datastage_code,
                                    PLATFORM_MASS_SMPP=value_item.PLATFORM_MASS_SMPP,
                                    WPT_GU_FACTOR_VOLUME=value_item.WPT_GU_FACTOR_VOLUME,
                                    WPT_GU_FACTOR_ENERGY=value_item.WPT_GU_FACTOR_ENERGY,
                                    FORECAST_FEED_N2=value_item.FORECAST_FEED_N2,
                                    FORECAST_FEED_CO2=value_item.FORECAST_FEED_CO2,
                                    WPT_NG_HHV=value_item.WPT_NG_HHV
                                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = value_item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                                AND object_id = ec_stream.object_id_by_uk('SW_PL_NG_FORECAST');
                            END IF;

                        END IF;
                    END IF;
                END LOOP;
            END LOOP;
            -- Update monthly values
            FOR item IN months_in_plan(type_item.forecast_type, type_item.probability_type) LOOP

                --ALL or Total FOR DOMGAS
                SELECT sum(DOMGAS_ENERGY), sum(DOMGAS_VOL_RATE) into v_sum_dg, v_sum_dg_vol
                FROM DV_CT_PROD_STRM_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_FORECAST x
                    WHERE x.forecast_type = v_forecast_type
                    AND x.scenario = v_scenario
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = v_forecast_type
                AND scenario = v_scenario
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                --ALL or Total FOR LNG
                --sumOfMthFor(MMBTU/M3 * M3 )/sumOfMthFor(M3) --> Monthly LNG_HHV in MMBTU/M3
                SELECT sum(LNG_HHV * LNG_VOL_RATE), sum(LNG_VOL_RATE), sum(LNG_MASS_RATE) * 1000, sum(LNG_VOL_RATE) into v_avg_gcv_num, v_avg_gcv_den, v_avg_dens_num, v_avg_dens_den
                FROM DV_CT_PROD_STRM_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_FORECAST x
                    WHERE x.forecast_type = v_forecast_type
                    AND x.scenario = v_scenario
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = v_forecast_type
                AND scenario = v_scenario
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                --ALL or Total FOR COND
                SELECT sum(COND_VOL_RATE), sum(COND_MASS_RATE) * 1000 into v_sum_cond, v_avg_dens_cond_num
                FROM DV_CT_PROD_STRM_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_FORECAST x
                    WHERE x.forecast_type = v_forecast_type
                    AND x.scenario = v_scenario
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = v_forecast_type
                AND scenario = v_scenario
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                IF v_avg_gcv_den <> 0 THEN
                    v_avg_gcv := v_avg_gcv_num / v_avg_gcv_den;
                ELSE
                    v_avg_gcv := 0;
                END IF;

                IF v_avg_dens_den <> 0 THEN
                    v_avg_dens := v_avg_dens_num / v_avg_dens_den;
                ELSE
                    v_avg_dens := 0;
                END IF;

                IF v_sum_cond <> 0 THEN
                    v_avg_cond_dens := v_avg_dens_cond_num / v_sum_cond;
                ELSE
                    v_avg_cond_dens := 0;
                END IF;

                --UPG for DOMGAS
                SELECT sum(DOMGAS_ENERGY),sum(DOMGAS_VOL_RATE)  into v_sum_dg_pc, v_sum_dg_vol_pc
                FROM DV_CT_PROD_STRM_PC_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_PC_FORECAST x
                    WHERE x.forecast_type = v_forecast_type
                    AND x.scenario = v_scenario
                    AND x.PROFIT_CENTRE_ID = v_UPG_id
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = v_forecast_type
                AND scenario = v_scenario
                AND PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                --UPG for LNG
                SELECT sum(LNG_HHV * LNG_VOL_RATE), sum(LNG_VOL_RATE), sum(LNG_MASS_RATE) * 1000, sum(LNG_VOL_RATE) into v_avg_gcv_num_pc, v_avg_gcv_den_pc, v_avg_dens_num_pc, v_avg_dens_den_pc
                FROM DV_CT_PROD_STRM_PC_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_PC_FORECAST x
                    WHERE x.forecast_type = v_forecast_type
                    AND x.scenario = v_scenario
                    AND x.PROFIT_CENTRE_ID = v_UPG_id
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = v_forecast_type
                AND scenario = v_scenario
                AND PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                --UPG for COND
                SELECT sum(COND_VOL_RATE), sum(COND_MASS_RATE) * 1000 into v_sum_cond_pc, v_avg_dens_cond_num_pc
                FROM DV_CT_PROD_STRM_PC_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_PC_FORECAST x
                    WHERE x.forecast_type = v_forecast_type
                    AND x.scenario = v_scenario
                    AND x.PROFIT_CENTRE_ID = v_UPG_id
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = v_forecast_type
                AND scenario = v_scenario
                AND PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                IF v_avg_gcv_den_pc <> 0 THEN
                    v_avg_gcv_pc := v_avg_gcv_num_pc / v_avg_gcv_den_pc;
                ELSE
                    v_avg_gcv_pc := 0;
                END IF;

                IF v_avg_dens_den_pc <> 0 THEN
                    v_avg_dens_pc := v_avg_dens_num_pc / v_avg_dens_den_pc;
                ELSE
                    v_avg_dens_pc := 0;
                END IF;

                IF v_sum_cond_pc <> 0 THEN
                    v_avg_cond_dens_pc := v_avg_dens_cond_num_pc / v_sum_cond_pc;
                ELSE
                    v_avg_cond_dens_pc := 0;
                END IF;

                UPDATE DV_CT_PROD_STRM_FORECAST
                SET LNG_DENSITY_MTH = ROUND(v_avg_dens,3), LNG_VOL_RATE_MTH = v_avg_dens_den, LNG_HHV_MTH = ROUND(v_avg_gcv,3)
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');

                UPDATE DV_CT_PROD_STRM_FORECAST
                SET COND_VOL_RATE_MTH = v_sum_cond, COND_DENSITY_MTH = ROUND(v_avg_cond_dens,3)
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');

                UPDATE DV_CT_PROD_STRM_FORECAST
                SET DOMGAS_ENERGY_MTH = v_sum_dg , DOMGAS_VOL_MTH_RATE = v_sum_dg_vol
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');

                UPDATE DV_CT_PROD_STRM_PC_FORECAST
                SET LNG_DENSITY_MTH = ROUND(v_avg_dens_pc,3), LNG_VOL_RATE_MTH = v_avg_dens_den_pc, LNG_HHV_MTH = ROUND(v_avg_gcv_pc,3)
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');

                UPDATE DV_CT_PROD_STRM_PC_FORECAST
                SET COND_VOL_RATE_MTH = v_sum_cond_pc, COND_DENSITY_MTH = ROUND(v_avg_cond_dens_pc,3)
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');

                UPDATE DV_CT_PROD_STRM_PC_FORECAST
                SET DOMGAS_ENERGY_MTH = v_sum_dg_pc, DOMGAS_VOL_MTH_RATE = v_sum_dg_vol_pc
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');

            END LOOP;
        END IF;


        IF UPPER(type_item.forecast_type) = 'NOMINATIONS_PLAN' THEN
            v_forecast_type := 'NOMINATIONS_PLAN';
            FOR year_item IN year_starts('LIFTING', p_datastage_code, type_item.forecast_type, type_item.probability_type) LOOP
                v_effective_daytime := year_item.daytime;
            END LOOP;
            v_fcst_scen_no := -1;
            v_forecast_id_guid := NULL;
            FOR item IN sds_scenarios(v_scenario) LOOP
                v_fcst_scen_no := item.fcst_scen_no;
                v_forecast_id_guid := item.object_id;
            END LOOP;
            IF v_fcst_scen_no = -1 THEN
                v_seq :=  1 ;
                --v_sds_id:= 'SDS_'|| v_scenario || '_' || TO_CHAR(v_seq)|| '_' || to_char(TRUNC(v_effective_daytime,'YEAR'),'YYYY')  ;
                --assign FCST_DS_ID:  [ADP/SDS]_[RP,HC,MC,LC]_[DS Code]_[YYYY]_[VERSION]
                SELECT DECODE(TRIM(v_scenario), 'HIGH_CONF', 'HC', 'MED_CONF', 'MC', 'LOW_CONF','LC','REF_PROD','RP') INTO v_temp_scenario FROM DUAL;
                v_sds_id:= 'NOM_'|| v_temp_scenario || '_' || 'BASED'    ;
                SELECT DECODE(TRIM(v_scenario), 'HIGH_CONF', 'High Conf', 'MED_CONF', 'Med Conf', 'LOW_CONF','Low Conf','REF_PROD','Ref Prod') INTO v_temp_scenario FROM DUAL;
                v_ds_name:= 'NOM '|| v_temp_scenario || ' ' || 'BASED'   ;

                EcDp_System_Key.assignNextNumber('CT_PROD_FORECAST', v_fcst_scen_no);

                INSERT INTO OV_CT_PROD_FORECAST (CODE, NAME, fcst_scen_no, forecast_type, scenario, DAYTIME, FCST_CPP_ID)
                VALUES (v_sds_id,v_ds_name,v_fcst_scen_no, v_forecast_type, v_scenario, v_effective_daytime, p_datastage_code);

                v_forecast_id_guid := ECDP_OBJECTS.GETOBJIDFROMCODE('CT_PROD_FORECAST',v_sds_id);

            END IF;

            v_effective_daytime := ec_CT_prod_forecast.START_DATE(v_forecast_id_guid);

            --TLXT: 08-JUL-2015: CP - Interface - CPP data load - New column to keep the DATA_STAGE_CODE
            UPDATE OV_CT_PROD_FORECAST SET FCST_CPP_ID = p_datastage_code, LAST_UPDATED_DATE = SYSDATE WHERE  OBJECT_ID = v_forecast_id_guid;
            --END EDIT

            -- Get the PROFIT_CENTRE_CODE
            SELECT DECODE(TRIM(type_item.PROFIT_CENTRE_CODE), 'F_WST_IAGO', 'F_WST_IAGO', 'F_JUL_BRU', 'F_JUL_BRU','ALL','ALL','UNKNOWN') INTO v_UPG FROM DUAL;
            IF (v_UPG = 'UNKNOWN') THEN
                RAISE_APPLICATION_ERROR(-20998, 'Message UPG Code type must be "F_WST_IAGO" or "F_JUL_BRU" or "ALL" ');
            END IF;
            v_UPG_id := ECDP_OBJECTS.GETOBJIDFROMCODE('FIELD',v_UPG);
                IF v_UPG = 'ALL' THEN
                    -- Merge LNG data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(LNG_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_VOL_RATE')), DAYTIME) as LNG_RATE,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD')), DAYTIME) as LNG_EXCESS_PROD,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_LNG, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_LNG')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_LNG')), DAYTIME) as LNG_REGAS_REQ_LNG,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_QTY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_QTY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_QTY')), DAYTIME) as CONFIRMED_EXCESS_QTY,
                        EcDp_Unit.ConvertValue(LNG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV')), DAYTIME) as LNG_HHV,
                        EcDp_Unit.ConvertValue(LNG_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_RATE')), DAYTIME) as LNG_MASS_RATE,
                        EcDp_Unit.ConvertValue(LNG_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_DENSITY')), DAYTIME) as LNG_DENSITY,
                        --Added Nomination attributes
                        EcDp_Unit.ConvertValue(LNG_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_SMPP')), DAYTIME) as LNG_MASS_SMPP,
                        EcDp_Unit.ConvertValue(COND_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_DENSITY')), DAYTIME) as COND_DENSITY,
                        EcDp_Unit.ConvertValue(COND_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_RATE')), DAYTIME) as COND_RATE,
                        EcDp_Unit.ConvertValue(COND_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_RATE')), DAYTIME) as COND_MASS_RATE,
                        EcDp_Unit.ConvertValue(PLATFORM_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','PLATFORM_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','PLATFORM_MASS_SMPP')), DAYTIME) as PLATFORM_MASS_SMPP,
                        EcDp_Unit.ConvertValue(COND_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_SMPP')), DAYTIME) as COND_MASS_SMPP,
                        EcDp_Unit.ConvertValue(DOMGAS_MASS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MASS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MASS_RATE')), DAYTIME) as DOMGAS_MASS,
                        EcDp_Unit.ConvertValue(DOMGAS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_ENERGY')), DAYTIME) as DOMGAS_ENERGY,
                        EcDp_Unit.ConvertValue(DOMGAS_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_HHV')), DAYTIME) as DOMGAS_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_SMPP')), DAYTIME) as DOMGAS_SMPP,
                        EcDp_Unit.ConvertValue(DOMGAS_MIN_RATE_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MIN_RATE_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MIN_RATE_ENERGY')), DAYTIME) as DOMGAS_MIN_RATE_ENERGY,
                        --EcDp_Unit.ConvertValue(DOMGAS_VOL, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOL')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL')), DAYTIME) as DOMGAS_VOL,
                        EcDp_Unit.ConvertValue(LNG_HHV_GJSM3, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV_GJSM3')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV_STD')), DAYTIME) as LNG_HHV_GJSM3,
                        EcDp_Unit.ConvertValue(DOMGAS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL_RATE')), DAYTIME) as DOMGAS_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_BL_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_BL_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_BL_VOLUME')), DAYTIME) as LNG_BL_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_BL_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_BL_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_BL_ENERGY')), DAYTIME) as LNG_BL_ENERGY,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD_VOLUME')), DAYTIME) as LNG_EXCESS_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD_ENERGY')), DAYTIME) as LNG_EXCESS_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(ADP_LNG_REQ_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','ADP_LNG_REQ_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','ADP_LNG_REQ_VOLUME')), DAYTIME) as ADP_LNG_REQ_VOLUME,
                        EcDp_Unit.ConvertValue(ADP_LNG_REQ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','ADP_LNG_REQ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','ADP_LNG_REQ_ENERGY')), DAYTIME) as ADP_LNG_REQ_ENERGY,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_GAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_GAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_GAS')), DAYTIME) as LNG_REGAS_REQ_GAS,
                        EcDp_Unit.ConvertValue(LNG_NET_RUNDOWN_CAP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_NET_RUNDOWN_CAP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_NET_RUNDOWN_CAP')), DAYTIME) as LNG_NET_RUNDOWN_CAP,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_ENERGY')), DAYTIME) as LNG_REGAS_REQ_ENERGY,
                        WPT_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_VOLUME')), DAYTIME) as WPT_GU_FACTOR_VOLUME,
                        WPT_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_ENERGY')), DAYTIME) as WPT_GU_FACTOR_ENERGY,
                        DOMGAS_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_VOLUME')), DAYTIME) as DOMGAS_GU_FACTOR_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_ENERGY')), DAYTIME) as DOMGAS_GU_FACTOR_ENERGY,
                        TRAIN_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(TRAIN_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_GU_FACTOR_VOLUME')), DAYTIME) as TRAIN_GU_FACTOR_VOLUME,
                        TRAIN_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(TRAIN_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_GU_FACTOR_ENERGY')), DAYTIME) as TRAIN_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_VOLUME')), DAYTIME) as CONFIRMED_EXCESS_VOLUME,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_ENERGY')), DAYTIME) as CONFIRMED_EXCESS_ENERGY,
                        EcDp_Unit.ConvertValue(REF_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_VOLUME')), DAYTIME) as REF_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_STD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_STD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_STD_VOLUME')), DAYTIME) as REF_PROD_STD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_ENERGY')), DAYTIME) as REF_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_N2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_N2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_N2')), DAYTIME) as FORECAST_FEED_N2,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_CO2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_CO2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_CO2')), DAYTIME) as FORECAST_FEED_CO2,
                        EcDp_Unit.ConvertValue(AGRD_CAP_LNG_EXPORT, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','AGRD_CAP_LNG_EXPORT')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','AGRD_CAP_LNG_EXPORT')), DAYTIME) as AGRD_CAP_LNG_EXPORT,
                        EcDp_Unit.ConvertValue(WPT_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_NG_HHV')), DAYTIME) as WPT_NG_HHV,
                        EcDp_Unit.ConvertValue(TRAIN_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_NG_HHV')), DAYTIME) as TRAIN_NG_HHV,
                        EcDp_Unit.ConvertValue(DG_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DG_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DG_NG_HHV')), DAYTIME) as DG_NG_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_REGAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_REGAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_REGAS')), DAYTIME) as DOMGAS_REGAS,
                        EcDp_Unit.ConvertValue(IMBALANCE_ADJ_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_VOLUME')), DAYTIME) as IMBALANCE_ADJ_VOLUME,
                        EcDp_Unit.ConvertValue(IMBALANCE_ADJ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_ENERGY')), DAYTIME) as IMBALANCE_ADJ_ENERGY,
                        EcDp_Unit.ConvertValue(UNMET_AMOUNT_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_VOLUME')), DAYTIME) as UNMET_AMOUNT_VOLUME,
                        EcDp_Unit.ConvertValue(UNMET_AMOUNT_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_ENERGY')), DAYTIME) as UNMET_AMOUNT_ENERGY
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code= p_datastage_code
                        AND forecast_type    = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG              = 'ALL'
                        AND (LNG_RATE IS NOT NULL OR LNG_HHV IS NOT NULL OR LNG_HHV_GJSM3 IS NOT NULL OR LNG_MASS_RATE IS NOT NULL OR LNG_EXCESS_PROD IS NOT NULL OR LNG_REGAS_REQ_LNG IS NOT NULL OR CONFIRMED_EXCESS_QTY IS NOT NULL
                        OR LNG_BL_VOLUME IS NOT NULL OR LNG_BL_ENERGY IS NOT NULL OR LNG_EXCESS_PROD_VOLUME IS NOT NULL OR LNG_EXCESS_PROD_ENERGY IS NOT NULL
                        OR ADP_LNG_REQ_VOLUME IS NOT NULL OR ADP_LNG_REQ_ENERGY IS NOT NULL OR LNG_REGAS_REQ_GAS IS NOT NULL OR LNG_REGAS_REQ_ENERGY IS NOT NULL
                        OR TRAIN_GU_FACTOR_VOLUME IS NOT NULL OR TRAIN_GU_FACTOR_ENERGY IS NOT NULL OR CONFIRMED_EXCESS_VOLUME IS NOT NULL OR CONFIRMED_EXCESS_ENERGY IS NOT NULL
                        OR AGRD_CAP_LNG_EXPORT IS NOT NULL OR TRAIN_NG_HHV IS NOT NULL
                        )
                    ) stage
                    ON
                    (
                        fcast.object_id          = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                        AND fcast.FORECAST_TYPE  = v_forecast_type
                        AND fcast.SCENARIO       = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime        = stage.daytime
                        --TLXT: 06-May-2016: added Data_Stage_code Id for Nominations_PLAN as requested by CPP process. Not requried in SDS PLAN
                        --AND fcast.TEXT_10        = 'BASED'
                        --end edit TLXT: 06-May-2016:
                        AND fcast.REF_OBJECT_ID_1= v_forecast_id_guid
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.value_43         = stage.LNG_RATE,
                                fcast.LNG_EXCESS_PROD     = stage.LNG_EXCESS_PROD,
                                fcast.LNG_REGAS_REQ       = stage.LNG_REGAS_REQ_LNG,
                                fcast.CONFIRMED_EXCESS_QTY= stage.CONFIRMED_EXCESS_QTY,
                                fcast.value_42            = stage.lng_hhv,
                                fcast.value_46            = stage.LNG_HHV_GJSM3,
                                fcast.value_41            = stage.lng_mass_rate,
                                fcast.value_36            = stage.LNG_DENSITY,
                                --Added Nomination attributes
                                --fcast.VALUE_38                = stage.LNG_HHV_VOL_MTH,
                                --TLXT: 06-May-2016: added Data_Stage_code Id for Nominations_PLAN as requested by CPP process. Not requried in SDS PLAN
                                fcast.TEXT_10             = stage.DATA_STAGE_CODE,
                                --end edit TLXT: 06-May-2016:
                                fcast.LNG_BL_VOLUME            = stage.LNG_BL_VOLUME,
                                fcast.LNG_BL_ENERGY            = stage.LNG_BL_ENERGY,
                                fcast.LNG_EXCESS_PROD_VOLUME= stage.LNG_EXCESS_PROD_VOLUME,
                                fcast.LNG_EXCESS_PROD_ENERGY= stage.LNG_EXCESS_PROD_ENERGY,
                                fcast.ADP_LNG_REQ_VOLUME    = stage.ADP_LNG_REQ_VOLUME,
                                fcast.ADP_LNG_REQ_ENERGY    = stage.ADP_LNG_REQ_ENERGY,
                                fcast.LNG_REGAS_REQ_GAS        = stage.LNG_REGAS_REQ_GAS,
                                fcast.LNG_REGAS_REQ_ENERGY    = stage.LNG_REGAS_REQ_ENERGY,
                                fcast.TRAIN_GU_FACTOR_VOLUME    = stage.TRAIN_GU_FACTOR_VOLUME,
                                fcast.TRAIN_GU_FACTOR_ENERGY    = stage.TRAIN_GU_FACTOR_ENERGY,
                                fcast.CONFIRMED_EXCESS_VOLUME    = stage.CONFIRMED_EXCESS_VOLUME,
                                fcast.CONFIRMED_EXCESS_ENERGY    = stage.CONFIRMED_EXCESS_ENERGY,
                                fcast.AGRD_CAP_LNG_EXPORT    = stage.AGRD_CAP_LNG_EXPORT,
                                fcast.TRAIN_NG_HHV    = stage.TRAIN_NG_HHV,
                                fcast.LNG_NGI_ADJUST_VOL         = stage.IMBALANCE_ADJ_VOLUME,
                                fcast.LNG_NGI_ADJUST_ENERGY     = stage.IMBALANCE_ADJ_ENERGY,
                                fcast.LNG_UNMET_AMT_VOL         = stage.UNMET_AMOUNT_VOLUME,
                                fcast.LNG_UNMET_AMT_ENERGY         = stage.UNMET_AMOUNT_ENERGY
                    WHEN NOT MATCHED THEN
                        -- LNG Rate
                        INSERT (REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime, VALUE_43,LNG_EXCESS_PROD, LNG_REGAS_REQ, CONFIRMED_EXCESS_QTY, VALUE_42,VALUE_41, VALUE_36
                        ,value_46
                        ,LNG_BL_VOLUME, LNG_BL_ENERGY,LNG_EXCESS_PROD_VOLUME,LNG_EXCESS_PROD_ENERGY,ADP_LNG_REQ_VOLUME,ADP_LNG_REQ_ENERGY,LNG_REGAS_REQ_GAS,LNG_REGAS_REQ_ENERGY
                        ,TRAIN_GU_FACTOR_VOLUME,TRAIN_GU_FACTOR_ENERGY,CONFIRMED_EXCESS_VOLUME,CONFIRMED_EXCESS_ENERGY
                        ,AGRD_CAP_LNG_EXPORT,TRAIN_NG_HHV
                        ,LNG_NGI_ADJUST_VOL,LNG_NGI_ADJUST_ENERGY,LNG_UNMET_AMT_VOL,LNG_UNMET_AMT_ENERGY
                        )
                        VALUES (v_forecast_id_guid, stage.DATA_STAGE_CODE,  ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST'), stage.daytime, v_forecast_type, v_scenario, v_effective_daytime, stage.LNG_RATE,stage.LNG_EXCESS_PROD, stage.LNG_REGAS_REQ_LNG, stage.CONFIRMED_EXCESS_QTY, stage.lng_hhv,stage.lng_mass_rate,stage.LNG_DENSITY
                        ,stage.LNG_HHV_GJSM3
                        ,stage.LNG_BL_VOLUME, stage.LNG_BL_ENERGY,stage.LNG_EXCESS_PROD_VOLUME,stage.LNG_EXCESS_PROD_ENERGY,stage.ADP_LNG_REQ_VOLUME,stage.ADP_LNG_REQ_ENERGY,stage.LNG_REGAS_REQ_GAS,stage.LNG_REGAS_REQ_ENERGY
                        ,stage.TRAIN_GU_FACTOR_VOLUME,stage.TRAIN_GU_FACTOR_ENERGY,stage.CONFIRMED_EXCESS_VOLUME,stage.CONFIRMED_EXCESS_ENERGY
                        ,stage.AGRD_CAP_LNG_EXPORT,stage.TRAIN_NG_HHV
                        ,stage.IMBALANCE_ADJ_VOLUME,stage.IMBALANCE_ADJ_ENERGY,stage.UNMET_AMOUNT_VOLUME,stage.UNMET_AMOUNT_ENERGY
                        );

                    -- Merge COND data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(COND_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_VOL_RATE')), DAYTIME) as COND_RATE,
                        EcDp_Unit.ConvertValue(COND_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_DENSITY')), DAYTIME) as COND_DENSITY,
                        EcDp_Unit.ConvertValue(COND_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_RATE')), DAYTIME) as COND_MASS_RATE,
                        --Added Nomination attributes
                        EcDp_Unit.ConvertValue(LNG_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_SMPP')), DAYTIME) as LNG_MASS_SMPP,
                        EcDp_Unit.ConvertValue(PLATFORM_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','PLATFORM_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','PLATFORM_MASS_SMPP')), DAYTIME) as PLATFORM_MASS_SMPP,
                        EcDp_Unit.ConvertValue(COND_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_SMPP')), DAYTIME) as COND_MASS_SMPP,
                        EcDp_Unit.ConvertValue(DOMGAS_MASS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MASS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MASS_RATE')), DAYTIME) as DOMGAS_MASS,
                        EcDp_Unit.ConvertValue(DOMGAS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_ENERGY')), DAYTIME) as DOMGAS_ENERGY,
                        EcDp_Unit.ConvertValue(DOMGAS_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_HHV')), DAYTIME) as DOMGAS_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_SMPP')), DAYTIME) as DOMGAS_SMPP,
                        EcDp_Unit.ConvertValue(DOMGAS_MIN_RATE_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MIN_RATE_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MIN_RATE_ENERGY')), DAYTIME) as DOMGAS_MIN_RATE_ENERGY,
                        --EcDp_Unit.ConvertValue(DOMGAS_VOL, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOL')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL')), DAYTIME) as DOMGAS_VOL,
                        EcDp_Unit.ConvertValue(LNG_HHV_GJSM3, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV_GJSM3')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV_VOL_MTH')), DAYTIME) as LNG_HHV_VOL_MTH,
                        EcDp_Unit.ConvertValue(DOMGAS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL_RATE')), DAYTIME) as DOMGAS_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_BL_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_BL_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_BL_VOLUME')), DAYTIME) as LNG_BL_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_BL_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_BL_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_BL_ENERGY')), DAYTIME) as LNG_BL_ENERGY,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD_VOLUME')), DAYTIME) as LNG_EXCESS_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD_ENERGY')), DAYTIME) as LNG_EXCESS_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(ADP_LNG_REQ_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','ADP_LNG_REQ_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','ADP_LNG_REQ_VOLUME')), DAYTIME) as ADP_LNG_REQ_VOLUME,
                        EcDp_Unit.ConvertValue(ADP_LNG_REQ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','ADP_LNG_REQ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','ADP_LNG_REQ_ENERGY')), DAYTIME) as ADP_LNG_REQ_ENERGY,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_GAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_GAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_GAS')), DAYTIME) as LNG_REGAS_REQ_GAS,
                        EcDp_Unit.ConvertValue(LNG_NET_RUNDOWN_CAP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_NET_RUNDOWN_CAP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_NET_RUNDOWN_CAP')), DAYTIME) as LNG_NET_RUNDOWN_CAP,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_ENERGY')), DAYTIME) as LNG_REGAS_REQ_ENERGY,
                        WPT_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_VOLUME')), DAYTIME) as WPT_GU_FACTOR_VOLUME,
                        WPT_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_ENERGY')), DAYTIME) as WPT_GU_FACTOR_ENERGY,
                        DOMGAS_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_VOLUME')), DAYTIME) as DOMGAS_GU_FACTOR_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_ENERGY')), DAYTIME) as DOMGAS_GU_FACTOR_ENERGY,
                        TRAIN_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(TRAIN_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_GU_FACTOR_VOLUME')), DAYTIME) as TRAIN_GU_FACTOR_VOLUME,
                        TRAIN_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(TRAIN_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_GU_FACTOR_ENERGY')), DAYTIME) as TRAIN_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_VOLUME')), DAYTIME) as CONFIRMED_EXCESS_VOLUME,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_ENERGY')), DAYTIME) as CONFIRMED_EXCESS_ENERGY,
                        EcDp_Unit.ConvertValue(REF_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_VOLUME')), DAYTIME) as REF_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_STD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_STD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_STD_VOLUME')), DAYTIME) as REF_PROD_STD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_ENERGY')), DAYTIME) as REF_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_N2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_N2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_N2')), DAYTIME) as FORECAST_FEED_N2,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_CO2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_CO2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_CO2')), DAYTIME) as FORECAST_FEED_CO2,
                        EcDp_Unit.ConvertValue(AGRD_CAP_LNG_EXPORT, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','AGRD_CAP_LNG_EXPORT')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','AGRD_CAP_LNG_EXPORT')), DAYTIME) as AGRD_CAP_LNG_EXPORT,
                        EcDp_Unit.ConvertValue(WPT_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_NG_HHV')), DAYTIME) as WPT_NG_HHV,
                        EcDp_Unit.ConvertValue(TRAIN_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_NG_HHV')), DAYTIME) as TRAIN_NG_HHV,
                        EcDp_Unit.ConvertValue(DG_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DG_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DG_NG_HHV')), DAYTIME) as DG_NG_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_REGAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_REGAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_REGAS')), DAYTIME) as DOMGAS_REGAS
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = 'ALL'
                        AND (COND_RATE IS NOT NULL OR COND_DENSITY IS NOT NULL OR COND_MASS_RATE IS NOT NULL OR COND_MASS_SMPP IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                        AND fcast.FORECAST_TYPE = v_forecast_type
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        --TLXT: 06-May-2016: added Data_Stage_code Id for Nominations_PLAN as requested by CPP process. Not requried in SDS PLAN
                        --AND fcast.TEXT_10        = 'BASED'
                        --end edit TLXT: 06-May-2016:
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.COND_RATE = stage.COND_RATE,
                                    --TLXT: 06-May-2016: added Data_Stage_code Id for Nominations_PLAN as requested by CPP process. Not requried in SDS PLAN
                                    fcast.TEXT_10             = stage.DATA_STAGE_CODE,
                                    --end edit TLXT: 06-May-2016:
                                   fcast.COND_MASS_RATE = stage.COND_MASS_RATE,
                                   fcast.VALUE_30 = stage.COND_DENSITY,
                                   fcast.COND_MASS_SMPP = stage.COND_MASS_SMPP
                    WHEN NOT MATCHED THEN
                        -- COND Rate
                        INSERT (REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime, COND_RATE, COND_MASS_RATE,VALUE_30,COND_MASS_SMPP)
                        VALUES (v_forecast_id_guid, stage.DATA_STAGE_CODE,  ec_stream.object_id_by_uk('SW_GP_COND_FORECAST'), stage.daytime, v_forecast_type, v_scenario, v_effective_daytime, stage.COND_RATE, stage.COND_MASS_RATE,stage.COND_DENSITY,stage.COND_MASS_SMPP);

                    -- Merge DOMGAS data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        DOMGAS_MIN_RATE_ENERGY,
                        EcDp_Unit.ConvertValue(DOMGAS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_SMPP')), DAYTIME) as DOMGAS_SMPP,
                        EcDp_Unit.ConvertValue(DOMGAS_MASS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MASS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MASS_RATE')), DAYTIME) as DOMGAS_MASS,
                        EcDp_Unit.ConvertValue(DOMGAS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_ENERGY')), DAYTIME) as DOMGAS_ENERGY,
                        EcDp_Unit.ConvertValue(DOMGAS_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_HHV')), DAYTIME) as DOMGAS_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL_RATE')), DAYTIME) as DOMGAS_VOL_RATE,
                        DOMGAS_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_VOLUME')), DAYTIME) as DOMGAS_GU_FACTOR_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_ENERGY')), DAYTIME) as DOMGAS_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(REF_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_VOLUME')), DAYTIME) as REF_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_STD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_STD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_STD_VOLUME')), DAYTIME) as REF_PROD_STD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_ENERGY')), DAYTIME) as REF_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(DG_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DG_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DG_NG_HHV')), DAYTIME) as DG_NG_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_REGAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_REGAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_REGAS')), DAYTIME) as DOMGAS_REGAS
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = 'ALL'
                        AND (DOMGAS_MASS IS NOT NULL OR DOMGAS_ENERGY IS NOT NULL OR DOMGAS_HHV IS NOT NULL OR DOMGAS_VOLUME IS NOT NULL
                        OR DOMGAS_GU_FACTOR_VOLUME IS NOT NULL OR DOMGAS_GU_FACTOR_ENERGY IS NOT NULL
                        OR REF_PROD_VOLUME IS NOT NULL OR REF_PROD_STD_VOLUME IS NOT NULL OR REF_PROD_ENERGY IS NOT NULL OR DG_NG_HHV IS NOT NULL OR DOMGAS_REGAS IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                        AND fcast.FORECAST_TYPE = v_forecast_type
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        --TLXT: 06-May-2016: added Data_Stage_code Id for Nominations_PLAN as requested by CPP process. Not requried in SDS PLAN
                        --AND fcast.TEXT_10        = 'BASED'
                        --end edit TLXT: 06-May-2016:
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.DOMGAS_MIN_RATE_ENERGY = stage.DOMGAS_MIN_RATE_ENERGY,
                                    fcast.DOMGAS_SMPP = stage.DOMGAS_SMPP,
                                    fcast.VALUE_39 = stage.DOMGAS_MASS,
                                    fcast.VALUE_44 = stage.DOMGAS_ENERGY,
                                    fcast.DOMGAS_HHV = stage.DOMGAS_HHV,
                                    fcast.DOMGAS_VOL_RATE = stage.DOMGAS_VOL_RATE,
                                    fcast.DOMGAS_GU_FACTOR_VOLUME = stage.DOMGAS_GU_FACTOR_VOLUME,
                                    fcast.DOMGAS_GU_FACTOR_ENERGY = stage.DOMGAS_GU_FACTOR_ENERGY,
                                    fcast.REF_PROD_VOLUME = stage.REF_PROD_VOLUME,
                                    fcast.REF_PROD_STD_VOLUME = stage.REF_PROD_STD_VOLUME,
                                    fcast.REF_PROD_ENERGY = stage.REF_PROD_ENERGY,
                                    fcast.DG_NG_HHV = stage.DG_NG_HHV,
                                    --TLXT: 06-May-2016: added Data_Stage_code Id for Nominations_PLAN as requested by CPP process. Not requried in SDS PLAN
                                    fcast.TEXT_10             = stage.DATA_STAGE_CODE,
                                    --end edit TLXT: 06-May-2016:
                                    fcast.DOMGAS_REGAS = stage.DOMGAS_REGAS
                    WHEN NOT MATCHED THEN
                        -- DOMGAS Rate
                        INSERT (REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime
                        , VALUE_39, VALUE_44
                        ,DOMGAS_MIN_RATE_ENERGY,DOMGAS_SMPP, DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_GU_FACTOR_VOLUME,DOMGAS_GU_FACTOR_ENERGY,REF_PROD_VOLUME,REF_PROD_STD_VOLUME,REF_PROD_ENERGY,DG_NG_HHV,DOMGAS_REGAS)
                        VALUES (v_forecast_id_guid, stage.DATA_STAGE_CODE,  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), stage.daytime, v_forecast_type, v_scenario, v_effective_daytime
                        ,stage.DOMGAS_MASS, stage.DOMGAS_ENERGY
                        ,stage.DOMGAS_MIN_RATE_ENERGY,stage.DOMGAS_SMPP, stage.DOMGAS_HHV,stage.DOMGAS_VOL_RATE,stage.DOMGAS_GU_FACTOR_VOLUME,stage.DOMGAS_GU_FACTOR_ENERGY,stage.REF_PROD_VOLUME,stage.REF_PROD_STD_VOLUME,stage.REF_PROD_ENERGY,stage.DG_NG_HHV,stage.DOMGAS_REGAS
                        );

                    -- Merge platform data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(PLATFORM_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','PLATFORM_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','PLATFORM_MASS_SMPP')), DAYTIME) as PLATFORM_MASS_SMPP,
                        WPT_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_VOLUME')), DAYTIME) as WPT_GU_FACTOR_VOLUME,
                        WPT_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_ENERGY')), DAYTIME) as WPT_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_N2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_N2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_N2')), DAYTIME) as FORECAST_FEED_N2,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_CO2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_CO2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_CO2')), DAYTIME) as FORECAST_FEED_CO2,
                        EcDp_Unit.ConvertValue(WPT_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_NG_HHV')), DAYTIME) as WPT_NG_HHV
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = 'ALL'
                        AND (PLATFORM_MASS_SMPP IS NOT NULL OR WPT_GU_FACTOR_VOLUME IS NOT NULL OR WPT_GU_FACTOR_ENERGY IS NOT NULL OR FORECAST_FEED_N2 IS NOT NULL OR FORECAST_FEED_CO2 IS NOT NULL OR WPT_NG_HHV IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_PL_NG_FORECAST')
                        AND fcast.FORECAST_TYPE = v_forecast_type
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        --AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.PLATFORM_MASS_SMPP = stage.PLATFORM_MASS_SMPP,
                                    fcast.WPT_GU_FACTOR_VOLUME = stage.WPT_GU_FACTOR_VOLUME,
                                    fcast.WPT_GU_FACTOR_ENERGY = stage.WPT_GU_FACTOR_ENERGY,
                                    fcast.FORECAST_FEED_N2 = stage.FORECAST_FEED_N2,
                                    fcast.FORECAST_FEED_CO2 = stage.FORECAST_FEED_CO2,
                                    --TLXT: 06-May-2016: added Data_Stage_code Id for Nominations_PLAN as requested by CPP process. Not requried in SDS PLAN
                                    fcast.TEXT_10             = stage.DATA_STAGE_CODE,
                                    --end edit TLXT: 06-May-2016:
                                    fcast.WPT_NG_HHV = stage.WPT_NG_HHV
                    WHEN NOT MATCHED THEN
                        -- NG Rate
                        INSERT (REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime
                        , PLATFORM_MASS_SMPP, WPT_GU_FACTOR_VOLUME,WPT_GU_FACTOR_ENERGY
                        ,FORECAST_FEED_N2,FORECAST_FEED_CO2,WPT_NG_HHV)
                        VALUES (v_forecast_id_guid, stage.DATA_STAGE_CODE,  ec_stream.object_id_by_uk('SW_PL_NG_FORECAST'), stage.daytime, v_forecast_type, v_scenario, v_effective_daytime
                        ,stage.PLATFORM_MASS_SMPP, stage.WPT_GU_FACTOR_VOLUME, stage.WPT_GU_FACTOR_ENERGY
                        ,stage.FORECAST_FEED_N2,stage.FORECAST_FEED_CO2,stage.WPT_NG_HHV
                        );

                ELSE
                --OTHER UPG
                -- Merge LNG data into stream forecast BASE TABLE BY PC:
                    MERGE INTO CT_PROD_STRM_PC_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(LNG_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_VOL_RATE')), DAYTIME) as LNG_RATE,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD')), DAYTIME) as LNG_EXCESS_PROD,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_LNG, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_LNG')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_LNG')), DAYTIME) as LNG_REGAS_REQ_LNG,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_QTY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_QTY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_QTY')), DAYTIME) as CONFIRMED_EXCESS_QTY,
                        EcDp_Unit.ConvertValue(LNG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV')), DAYTIME) as LNG_HHV,
                        EcDp_Unit.ConvertValue(LNG_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_RATE')), DAYTIME) as LNG_MASS_RATE,
                        EcDp_Unit.ConvertValue(LNG_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_DENSITY')), DAYTIME) as LNG_DENSITY,
                        --Added Nomination attributes
                        EcDp_Unit.ConvertValue(LNG_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_SMPP')), DAYTIME) as LNG_MASS_SMPP,
                        EcDp_Unit.ConvertValue(COND_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_DENSITY')), DAYTIME) as COND_DENSITY,
                        EcDp_Unit.ConvertValue(COND_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_RATE')), DAYTIME) as COND_RATE,
                        EcDp_Unit.ConvertValue(COND_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_RATE')), DAYTIME) as COND_MASS_RATE,
                        EcDp_Unit.ConvertValue(PLATFORM_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','PLATFORM_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','PLATFORM_MASS_SMPP')), DAYTIME) as PLATFORM_MASS_SMPP,
                        EcDp_Unit.ConvertValue(COND_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_SMPP')), DAYTIME) as COND_MASS_SMPP,
                        EcDp_Unit.ConvertValue(DOMGAS_MASS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MASS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MASS_RATE')), DAYTIME) as DOMGAS_MASS,
                        EcDp_Unit.ConvertValue(DOMGAS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_ENERGY')), DAYTIME) as DOMGAS_ENERGY,
                        EcDp_Unit.ConvertValue(DOMGAS_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_HHV')), DAYTIME) as DOMGAS_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_SMPP')), DAYTIME) as DOMGAS_SMPP,
                        EcDp_Unit.ConvertValue(DOMGAS_MIN_RATE_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MIN_RATE_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MIN_RATE_ENERGY')), DAYTIME) as DOMGAS_MIN_RATE_ENERGY,
                        --EcDp_Unit.ConvertValue(DOMGAS_VOL, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOL')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL')), DAYTIME) as DOMGAS_VOL,
                        EcDp_Unit.ConvertValue(LNG_HHV_GJSM3, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV_GJSM3')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV_STD')), DAYTIME) as LNG_HHV_GJSM3,
                        EcDp_Unit.ConvertValue(DOMGAS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL_RATE')), DAYTIME) as DOMGAS_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_BL_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_BL_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_BL_VOLUME')), DAYTIME) as LNG_BL_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_BL_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_BL_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_BL_ENERGY')), DAYTIME) as LNG_BL_ENERGY,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD_VOLUME')), DAYTIME) as LNG_EXCESS_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD_ENERGY')), DAYTIME) as LNG_EXCESS_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(ADP_LNG_REQ_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','ADP_LNG_REQ_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','ADP_LNG_REQ_VOLUME')), DAYTIME) as ADP_LNG_REQ_VOLUME,
                        EcDp_Unit.ConvertValue(ADP_LNG_REQ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','ADP_LNG_REQ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','ADP_LNG_REQ_ENERGY')), DAYTIME) as ADP_LNG_REQ_ENERGY,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_GAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_GAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_GAS')), DAYTIME) as LNG_REGAS_REQ_GAS,
                        EcDp_Unit.ConvertValue(LNG_NET_RUNDOWN_CAP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_NET_RUNDOWN_CAP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_NET_RUNDOWN_CAP')), DAYTIME) as LNG_NET_RUNDOWN_CAP,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_ENERGY')), DAYTIME) as LNG_REGAS_REQ_ENERGY,
                        WPT_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_VOLUME')), DAYTIME) as WPT_GU_FACTOR_VOLUME,
                        WPT_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_ENERGY')), DAYTIME) as WPT_GU_FACTOR_ENERGY,
                        DOMGAS_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_VOLUME')), DAYTIME) as DOMGAS_GU_FACTOR_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_ENERGY')), DAYTIME) as DOMGAS_GU_FACTOR_ENERGY,
                        TRAIN_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(TRAIN_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_GU_FACTOR_VOLUME')), DAYTIME) as TRAIN_GU_FACTOR_VOLUME,
                        TRAIN_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(TRAIN_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_GU_FACTOR_ENERGY')), DAYTIME) as TRAIN_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_VOLUME')), DAYTIME) as CONFIRMED_EXCESS_VOLUME,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_ENERGY')), DAYTIME) as CONFIRMED_EXCESS_ENERGY,
                        EcDp_Unit.ConvertValue(REF_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_VOLUME')), DAYTIME) as REF_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_STD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_STD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_STD_VOLUME')), DAYTIME) as REF_PROD_STD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_ENERGY')), DAYTIME) as REF_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_N2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_N2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_N2')), DAYTIME) as FORECAST_FEED_N2,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_CO2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_CO2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_CO2')), DAYTIME) as FORECAST_FEED_CO2,
                        EcDp_Unit.ConvertValue(AGRD_CAP_LNG_EXPORT, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','AGRD_CAP_LNG_EXPORT')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','AGRD_CAP_LNG_EXPORT')), DAYTIME) as AGRD_CAP_LNG_EXPORT,
                        EcDp_Unit.ConvertValue(WPT_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_NG_HHV')), DAYTIME) as WPT_NG_HHV,
                        EcDp_Unit.ConvertValue(TRAIN_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_NG_HHV')), DAYTIME) as TRAIN_NG_HHV,
                        EcDp_Unit.ConvertValue(DG_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DG_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DG_NG_HHV')), DAYTIME) as DG_NG_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_REGAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_REGAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_REGAS')), DAYTIME) as DOMGAS_REGAS,
                        EcDp_Unit.ConvertValue(IMBALANCE_ADJ_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_VOLUME')), DAYTIME) as IMBALANCE_ADJ_VOLUME,
                        EcDp_Unit.ConvertValue(IMBALANCE_ADJ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_ENERGY')), DAYTIME) as IMBALANCE_ADJ_ENERGY,
                        EcDp_Unit.ConvertValue(UNMET_AMOUNT_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_VOLUME')), DAYTIME) as UNMET_AMOUNT_VOLUME,
                        EcDp_Unit.ConvertValue(UNMET_AMOUNT_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_ENERGY')), DAYTIME) as UNMET_AMOUNT_ENERGY
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = type_item.PROFIT_CENTRE_CODE
                        AND (LNG_RATE IS NOT NULL OR LNG_HHV IS NOT NULL OR LNG_HHV_GJSM3 IS NOT NULL OR LNG_MASS_RATE IS NOT NULL OR LNG_EXCESS_PROD IS NOT NULL OR LNG_REGAS_REQ_LNG IS NOT NULL OR CONFIRMED_EXCESS_QTY IS NOT NULL
                        OR LNG_BL_VOLUME IS NOT NULL OR LNG_BL_ENERGY IS NOT NULL OR LNG_EXCESS_PROD_VOLUME IS NOT NULL OR LNG_EXCESS_PROD_ENERGY IS NOT NULL
                        OR ADP_LNG_REQ_VOLUME IS NOT NULL OR ADP_LNG_REQ_ENERGY IS NOT NULL OR LNG_REGAS_REQ_GAS IS NOT NULL OR LNG_REGAS_REQ_ENERGY IS NOT NULL
                        OR TRAIN_GU_FACTOR_VOLUME IS NOT NULL OR TRAIN_GU_FACTOR_ENERGY IS NOT NULL OR CONFIRMED_EXCESS_VOLUME IS NOT NULL OR CONFIRMED_EXCESS_ENERGY IS NOT NULL
                        OR AGRD_CAP_LNG_EXPORT IS NOT NULL OR TRAIN_NG_HHV IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                        AND fcast.FORECAST_TYPE = v_forecast_type
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        --AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                        AND fcast.PROFIT_CENTRE_ID = v_UPG_id
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.value_43 = stage.LNG_RATE,
                                   fcast.LNG_EXCESS_PROD = stage.LNG_EXCESS_PROD,
                                   fcast.LNG_REGAS_REQ       = stage.LNG_REGAS_REQ_LNG,
                                   fcast.CONFIRMED_EXCESS_QTY= stage.CONFIRMED_EXCESS_QTY,
                                   fcast.value_42 = stage.lng_hhv,
                                   fcast.value_41 = stage.lng_mass_rate,
                                   fcast.value_36 = stage.LNG_DENSITY,
                                    --TLXT: 06-May-2016: added Data_Stage_code Id for Nominations_PLAN as requested by CPP process. Not requried in SDS PLAN
                                    fcast.TEXT_10             = stage.DATA_STAGE_CODE,
                                    --end edit TLXT: 06-May-2016:
                                --Added Nomination attributes
                                fcast.VALUE_46                = stage.LNG_HHV_GJSM3,
                                fcast.LNG_BL_VOLUME            = stage.LNG_BL_VOLUME,
                                fcast.LNG_BL_ENERGY            = stage.LNG_BL_ENERGY,
                                fcast.LNG_EXCESS_PROD_VOLUME= stage.LNG_EXCESS_PROD_VOLUME,
                                fcast.LNG_EXCESS_PROD_ENERGY= stage.LNG_EXCESS_PROD_ENERGY,
                                fcast.ADP_LNG_REQ_VOLUME    = stage.ADP_LNG_REQ_VOLUME,
                                fcast.ADP_LNG_REQ_ENERGY    = stage.ADP_LNG_REQ_ENERGY,
                                fcast.LNG_REGAS_REQ_GAS        = stage.LNG_REGAS_REQ_GAS,
                                fcast.LNG_REGAS_REQ_ENERGY    = stage.LNG_REGAS_REQ_ENERGY,
                                fcast.TRAIN_GU_FACTOR_VOLUME    = stage.TRAIN_GU_FACTOR_VOLUME,
                                fcast.TRAIN_GU_FACTOR_ENERGY    = stage.TRAIN_GU_FACTOR_ENERGY,
                                fcast.CONFIRMED_EXCESS_VOLUME    = stage.CONFIRMED_EXCESS_VOLUME,
                                fcast.CONFIRMED_EXCESS_ENERGY    = stage.CONFIRMED_EXCESS_ENERGY,
                                fcast.AGRD_CAP_LNG_EXPORT    = stage.AGRD_CAP_LNG_EXPORT,
                                fcast.TRAIN_NG_HHV    = stage.TRAIN_NG_HHV,
                                fcast.LNG_NGI_ADJUST_VOL         = stage.IMBALANCE_ADJ_VOLUME,
                                fcast.LNG_NGI_ADJUST_ENERGY     = stage.IMBALANCE_ADJ_ENERGY,
                                fcast.LNG_UNMET_AMT_VOL         = stage.UNMET_AMOUNT_VOLUME,
                                fcast.LNG_UNMET_AMT_ENERGY         = stage.UNMET_AMOUNT_ENERGY
                    WHEN NOT MATCHED THEN
                        -- LNG Rate
                        INSERT (PROFIT_CENTRE_ID,REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime, VALUE_43,LNG_EXCESS_PROD, LNG_REGAS_REQ, CONFIRMED_EXCESS_QTY, VALUE_42,VALUE_41, VALUE_36
                        ,VALUE_46
                        ,LNG_BL_VOLUME, LNG_BL_ENERGY,LNG_EXCESS_PROD_VOLUME,LNG_EXCESS_PROD_ENERGY,ADP_LNG_REQ_VOLUME,ADP_LNG_REQ_ENERGY,LNG_REGAS_REQ_GAS,LNG_REGAS_REQ_ENERGY
                        ,TRAIN_GU_FACTOR_VOLUME,TRAIN_GU_FACTOR_ENERGY,CONFIRMED_EXCESS_VOLUME,CONFIRMED_EXCESS_ENERGY
                        ,AGRD_CAP_LNG_EXPORT,TRAIN_NG_HHV
                        ,LNG_NGI_ADJUST_VOL,LNG_NGI_ADJUST_ENERGY,LNG_UNMET_AMT_VOL,LNG_UNMET_AMT_ENERGY
                        )
                        VALUES (v_UPG_id,v_forecast_id_guid, stage.DATA_STAGE_CODE,  ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST'), stage.daytime, v_forecast_type, v_scenario, v_effective_daytime, stage.LNG_RATE,stage.LNG_EXCESS_PROD, stage.LNG_REGAS_REQ_LNG, stage.CONFIRMED_EXCESS_QTY, stage.lng_hhv,stage.lng_mass_rate,stage.LNG_DENSITY
                        ,stage.LNG_HHV_GJSM3
                        ,stage.LNG_BL_VOLUME, stage.LNG_BL_ENERGY,stage.LNG_EXCESS_PROD_VOLUME,stage.LNG_EXCESS_PROD_ENERGY,stage.ADP_LNG_REQ_VOLUME,stage.ADP_LNG_REQ_ENERGY,stage.LNG_REGAS_REQ_GAS,stage.LNG_REGAS_REQ_ENERGY
                        ,stage.TRAIN_GU_FACTOR_VOLUME,stage.TRAIN_GU_FACTOR_ENERGY,stage.CONFIRMED_EXCESS_VOLUME,stage.CONFIRMED_EXCESS_ENERGY
                        ,stage.AGRD_CAP_LNG_EXPORT,stage.TRAIN_NG_HHV
                        ,stage.IMBALANCE_ADJ_VOLUME,stage.IMBALANCE_ADJ_ENERGY,stage.UNMET_AMOUNT_VOLUME,stage.UNMET_AMOUNT_ENERGY
                        );

                    -- Merge COND data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_PC_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(COND_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_VOL_RATE')), DAYTIME) as COND_RATE,
                        EcDp_Unit.ConvertValue(COND_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_DENSITY')), DAYTIME) as COND_DENSITY,
                        EcDp_Unit.ConvertValue(COND_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_RATE')), DAYTIME) as COND_MASS_RATE,
                        --Added Nomination attributes
                        EcDp_Unit.ConvertValue(LNG_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_SMPP')), DAYTIME) as LNG_MASS_SMPP,
                        --EcDp_Unit.ConvertValue(COND_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_DENSITY')), DAYTIME) as COND_DENSITY,
                        --EcDp_Unit.ConvertValue(COND_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_RATE')), DAYTIME) as COND_RATE,
                        --EcDp_Unit.ConvertValue(COND_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_RATE')), DAYTIME) as COND_MASS_RATE,
                        EcDp_Unit.ConvertValue(PLATFORM_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','PLATFORM_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','PLATFORM_MASS_SMPP')), DAYTIME) as PLATFORM_MASS_SMPP,
                        EcDp_Unit.ConvertValue(COND_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_SMPP')), DAYTIME) as COND_MASS_SMPP,
                        EcDp_Unit.ConvertValue(DOMGAS_MASS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MASS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MASS_RATE')), DAYTIME) as DOMGAS_MASS,
                        EcDp_Unit.ConvertValue(DOMGAS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_ENERGY')), DAYTIME) as DOMGAS_ENERGY,
                        EcDp_Unit.ConvertValue(DOMGAS_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_HHV')), DAYTIME) as DOMGAS_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_SMPP')), DAYTIME) as DOMGAS_SMPP,
                        EcDp_Unit.ConvertValue(DOMGAS_MIN_RATE_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MIN_RATE_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MIN_RATE_ENERGY')), DAYTIME) as DOMGAS_MIN_RATE_ENERGY,
                        --EcDp_Unit.ConvertValue(DOMGAS_VOL, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOL')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL')), DAYTIME) as DOMGAS_VOL,
                        EcDp_Unit.ConvertValue(LNG_HHV_GJSM3, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV_GJSM3')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV_VOL_MTH')), DAYTIME) as LNG_HHV_VOL_MTH,
                        EcDp_Unit.ConvertValue(DOMGAS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL_RATE')), DAYTIME) as DOMGAS_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_BL_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_BL_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_BL_VOLUME')), DAYTIME) as LNG_BL_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_BL_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_BL_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_BL_ENERGY')), DAYTIME) as LNG_BL_ENERGY,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD_VOLUME')), DAYTIME) as LNG_EXCESS_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD_ENERGY')), DAYTIME) as LNG_EXCESS_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(ADP_LNG_REQ_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','ADP_LNG_REQ_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','ADP_LNG_REQ_VOLUME')), DAYTIME) as ADP_LNG_REQ_VOLUME,
                        EcDp_Unit.ConvertValue(ADP_LNG_REQ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','ADP_LNG_REQ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','ADP_LNG_REQ_ENERGY')), DAYTIME) as ADP_LNG_REQ_ENERGY,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_GAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_GAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_GAS')), DAYTIME) as LNG_REGAS_REQ_GAS,
                        EcDp_Unit.ConvertValue(LNG_NET_RUNDOWN_CAP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_NET_RUNDOWN_CAP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_NET_RUNDOWN_CAP')), DAYTIME) as LNG_NET_RUNDOWN_CAP,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_ENERGY')), DAYTIME) as LNG_REGAS_REQ_ENERGY,
                        WPT_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_VOLUME')), DAYTIME) as WPT_GU_FACTOR_VOLUME,
                        WPT_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_ENERGY')), DAYTIME) as WPT_GU_FACTOR_ENERGY,
                        DOMGAS_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_VOLUME')), DAYTIME) as DOMGAS_GU_FACTOR_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_ENERGY')), DAYTIME) as DOMGAS_GU_FACTOR_ENERGY,
                        TRAIN_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(TRAIN_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_GU_FACTOR_VOLUME')), DAYTIME) as TRAIN_GU_FACTOR_VOLUME,
                        TRAIN_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(TRAIN_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_GU_FACTOR_ENERGY')), DAYTIME) as TRAIN_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_VOLUME')), DAYTIME) as CONFIRMED_EXCESS_VOLUME,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_ENERGY')), DAYTIME) as CONFIRMED_EXCESS_ENERGY,
                        EcDp_Unit.ConvertValue(REF_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_VOLUME')), DAYTIME) as REF_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_STD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_STD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_STD_VOLUME')), DAYTIME) as REF_PROD_STD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_ENERGY')), DAYTIME) as REF_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_N2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_N2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_N2')), DAYTIME) as FORECAST_FEED_N2,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_CO2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_CO2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_CO2')), DAYTIME) as FORECAST_FEED_CO2,
                        EcDp_Unit.ConvertValue(AGRD_CAP_LNG_EXPORT, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','AGRD_CAP_LNG_EXPORT')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','AGRD_CAP_LNG_EXPORT')), DAYTIME) as AGRD_CAP_LNG_EXPORT,
                        EcDp_Unit.ConvertValue(WPT_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_NG_HHV')), DAYTIME) as WPT_NG_HHV,
                        EcDp_Unit.ConvertValue(TRAIN_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','TRAIN_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','TRAIN_NG_HHV')), DAYTIME) as TRAIN_NG_HHV,
                        EcDp_Unit.ConvertValue(DG_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DG_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DG_NG_HHV')), DAYTIME) as DG_NG_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_REGAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_REGAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_REGAS')), DAYTIME) as DOMGAS_REGAS
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = type_item.PROFIT_CENTRE_CODE
                        AND (COND_RATE IS NOT NULL OR COND_DENSITY IS NOT NULL OR COND_MASS_RATE IS NOT NULL OR COND_MASS_SMPP IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                        AND fcast.FORECAST_TYPE = v_forecast_type
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        --AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                        AND fcast.PROFIT_CENTRE_ID = v_UPG_id
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.COND_RATE = stage.COND_RATE,
                                   fcast.COND_MASS_RATE = stage.COND_MASS_RATE,
                                   fcast.VALUE_30 = stage.COND_DENSITY,
                                    --TLXT: 06-May-2016: added Data_Stage_code Id for Nominations_PLAN as requested by CPP process. Not requried in SDS PLAN
                                    fcast.TEXT_10             = stage.DATA_STAGE_CODE,
                                    --end edit TLXT: 06-May-2016:
                                   fcast.COND_MASS_SMPP = stage.COND_MASS_SMPP
                    WHEN NOT MATCHED THEN
                        -- COND Rate
                        INSERT (PROFIT_CENTRE_ID,REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime, COND_RATE, COND_MASS_RATE,VALUE_30,COND_MASS_SMPP)
                        VALUES (v_UPG_id,v_forecast_id_guid, stage.DATA_STAGE_CODE,  ec_stream.object_id_by_uk('SW_GP_COND_FORECAST'), stage.daytime, v_forecast_type, v_scenario, v_effective_daytime, stage.COND_RATE, stage.COND_MASS_RATE,stage.COND_DENSITY, stage.COND_MASS_SMPP);

                    -- Merge DOMGAS data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_PC_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(DOMGAS_MASS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MASS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MASS_RATE')), DAYTIME) as DOMGAS_MASS,
                        EcDp_Unit.ConvertValue(DOMGAS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_ENERGY')), DAYTIME) as DOMGAS_ENERGY,
                        EcDp_Unit.ConvertValue(DOMGAS_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_HHV')), DAYTIME) as DOMGAS_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL_RATE')), DAYTIME) as DOMGAS_VOL_RATE,
                        DOMGAS_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_VOLUME')), DAYTIME) as DOMGAS_GU_FACTOR_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_ENERGY')), DAYTIME) as DOMGAS_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(REF_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_VOLUME')), DAYTIME) as REF_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_STD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_STD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_STD_VOLUME')), DAYTIME) as REF_PROD_STD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_ENERGY')), DAYTIME) as REF_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(DG_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DG_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DG_NG_HHV')), DAYTIME) as DG_NG_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_REGAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_REGAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_REGAS')), DAYTIME) as DOMGAS_REGAS
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = type_item.PROFIT_CENTRE_CODE
                        AND (DOMGAS_MASS IS NOT NULL OR DOMGAS_ENERGY IS NOT NULL OR DOMGAS_HHV IS NOT NULL OR DOMGAS_VOLUME IS NOT NULL
                        OR DOMGAS_GU_FACTOR_VOLUME IS NOT NULL OR DOMGAS_GU_FACTOR_ENERGY IS NOT NULL
                        OR REF_PROD_VOLUME IS NOT NULL OR REF_PROD_STD_VOLUME IS NOT NULL OR REF_PROD_ENERGY IS NOT NULL OR DG_NG_HHV IS NOT NULL OR DOMGAS_REGAS IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                        AND fcast.FORECAST_TYPE = v_forecast_type
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        --AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                        AND fcast.PROFIT_CENTRE_ID = v_UPG_id
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.VALUE_39 = stage.DOMGAS_MASS,
                                    fcast.VALUE_44 = stage.DOMGAS_ENERGY,
                                    fcast.DOMGAS_HHV = stage.DOMGAS_HHV,
                                    fcast.DOMGAS_VOL_RATE = stage.DOMGAS_VOL_RATE,
                                    fcast.DOMGAS_GU_FACTOR_VOLUME = stage.DOMGAS_GU_FACTOR_VOLUME,
                                    fcast.DOMGAS_GU_FACTOR_ENERGY = stage.DOMGAS_GU_FACTOR_ENERGY,
                                    fcast.REF_PROD_VOLUME = stage.REF_PROD_VOLUME,
                                    fcast.REF_PROD_STD_VOLUME = stage.REF_PROD_STD_VOLUME,
                                    fcast.REF_PROD_ENERGY = stage.REF_PROD_ENERGY,
                                    fcast.DG_NG_HHV = stage.DG_NG_HHV,
                                    --TLXT: 06-May-2016: added Data_Stage_code Id for Nominations_PLAN as requested by CPP process. Not requried in SDS PLAN
                                    fcast.TEXT_10             = stage.DATA_STAGE_CODE,
                                    --end edit TLXT: 06-May-2016:
                                    fcast.DOMGAS_REGAS = stage.DOMGAS_REGAS
                    WHEN NOT MATCHED THEN
                        -- DOMGAS Rate
                        INSERT (PROFIT_CENTRE_ID,REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime
                        , VALUE_39, VALUE_44
                        , DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_GU_FACTOR_VOLUME,DOMGAS_GU_FACTOR_ENERGY,REF_PROD_VOLUME,REF_PROD_STD_VOLUME,REF_PROD_ENERGY,DG_NG_HHV,DOMGAS_REGAS)
                        VALUES (v_UPG_id,v_forecast_id_guid, stage.DATA_STAGE_CODE,  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), stage.daytime, v_forecast_type, v_scenario, v_effective_daytime
                        ,stage.DOMGAS_MASS, stage.DOMGAS_ENERGY
                        ,stage.DOMGAS_HHV,stage.DOMGAS_VOL_RATE,stage.DOMGAS_GU_FACTOR_VOLUME,stage.DOMGAS_GU_FACTOR_ENERGY,stage.REF_PROD_VOLUME,stage.REF_PROD_STD_VOLUME,stage.REF_PROD_ENERGY,stage.DG_NG_HHV,stage.DOMGAS_REGAS
                        );

                    -- Merge platform data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_PC_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(PLATFORM_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','PLATFORM_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','PLATFORM_MASS_SMPP')), DAYTIME) as PLATFORM_MASS_SMPP,
                        WPT_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_VOLUME')), DAYTIME) as WPT_GU_FACTOR_VOLUME,
                        WPT_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_ENERGY')), DAYTIME) as WPT_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_N2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_N2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_N2')), DAYTIME) as FORECAST_FEED_N2,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_CO2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_CO2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_CO2')), DAYTIME) as FORECAST_FEED_CO2,
                        EcDp_Unit.ConvertValue(WPT_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_NG_HHV')), DAYTIME) as WPT_NG_HHV
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = type_item.PROFIT_CENTRE_CODE
                        AND (PLATFORM_MASS_SMPP IS NOT NULL OR WPT_GU_FACTOR_VOLUME IS NOT NULL OR WPT_GU_FACTOR_ENERGY IS NOT NULL OR FORECAST_FEED_N2 IS NOT NULL OR FORECAST_FEED_CO2 IS NOT NULL OR WPT_NG_HHV IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_PL_NG_FORECAST')
                        AND fcast.FORECAST_TYPE = v_forecast_type
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        --AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                        AND fcast.PROFIT_CENTRE_ID = v_UPG_id
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.PLATFORM_MASS_SMPP = stage.PLATFORM_MASS_SMPP,
                                    fcast.WPT_GU_FACTOR_VOLUME = stage.WPT_GU_FACTOR_VOLUME,
                                    fcast.WPT_GU_FACTOR_ENERGY = stage.WPT_GU_FACTOR_ENERGY,
                                    fcast.FORECAST_FEED_N2 = stage.FORECAST_FEED_N2,
                                    fcast.FORECAST_FEED_CO2 = stage.FORECAST_FEED_CO2,
                                    --TLXT: 06-May-2016: added Data_Stage_code Id for Nominations_PLAN as requested by CPP process. Not requried in SDS PLAN
                                    fcast.TEXT_10             = stage.DATA_STAGE_CODE,
                                    --end edit TLXT: 06-May-2016:
                                    fcast.WPT_NG_HHV = stage.WPT_NG_HHV
                    WHEN NOT MATCHED THEN
                        -- NG Rate
                        INSERT (PROFIT_CENTRE_ID,REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime
                        , PLATFORM_MASS_SMPP, WPT_GU_FACTOR_VOLUME,WPT_GU_FACTOR_ENERGY
                        ,FORECAST_FEED_N2,FORECAST_FEED_CO2,WPT_NG_HHV)
                        VALUES (v_UPG_id, v_forecast_id_guid, stage.DATA_STAGE_CODE,  ec_stream.object_id_by_uk('SW_PL_NG_FORECAST'), stage.daytime, v_forecast_type, v_scenario, v_effective_daytime
                        ,stage.PLATFORM_MASS_SMPP, stage.WPT_GU_FACTOR_VOLUME, stage.WPT_GU_FACTOR_ENERGY
                        ,stage.FORECAST_FEED_N2,stage.FORECAST_FEED_CO2,stage.WPT_NG_HHV
                        );
                END IF;
        COMMIT;
        -- Update monthly values
        FOR item IN months_in_plan(type_item.forecast_type, type_item.probability_type) LOOP
            --ALL or Total FOR DOMGAS
            SELECT sum(DOMGAS_ENERGY), sum(DOMGAS_VOL_RATE) into v_sum_dg,   v_sum_dg_vol
            FROM DV_CT_PROD_STRM_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_FORECAST x
                WHERE x.forecast_type = v_forecast_type
                AND x.scenario = v_scenario
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = v_forecast_type
            AND scenario = v_scenario
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;

            --ALL or Total FOR LNG
            --sumOfMthFor(MMBTU/M3 * M3 )/sumOfMthFor(M3) --> Monthly LNG_HHV in MMBTU/M3
            SELECT sum(LNG_HHV * LNG_VOL_RATE), sum(LNG_VOL_RATE), sum(LNG_MASS_RATE) * 1000, sum(LNG_VOL_RATE) into v_avg_gcv_num, v_avg_gcv_den, v_avg_dens_num, v_avg_dens_den
            FROM DV_CT_PROD_STRM_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_FORECAST x
                WHERE x.forecast_type = v_forecast_type
                AND x.scenario = v_scenario
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = v_forecast_type
            AND scenario = v_scenario
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;

            --ALL or Total FOR COND
            SELECT sum(COND_VOL_RATE), sum(COND_MASS_RATE) * 1000 into v_sum_cond, v_avg_dens_cond_num
            FROM DV_CT_PROD_STRM_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_FORECAST x
                WHERE x.forecast_type = v_forecast_type
                AND x.scenario = v_scenario
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = v_forecast_type
            AND scenario = v_scenario
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;

            IF v_avg_gcv_den <> 0 THEN
                v_avg_gcv := v_avg_gcv_num / v_avg_gcv_den;
            ELSE
                v_avg_gcv := 0;
            END IF;

            IF v_avg_dens_den <> 0 THEN
                v_avg_dens := v_avg_dens_num / v_avg_dens_den;
            ELSE
                v_avg_dens := 0;
            END IF;

            IF v_sum_cond <> 0 THEN
                v_avg_cond_dens := v_avg_dens_cond_num / v_sum_cond;
            ELSE
                v_avg_cond_dens := 0;
            END IF;

            --UPG for DOMGAS
            SELECT sum(DOMGAS_ENERGY),sum(DOMGAS_VOL_RATE) into v_sum_dg_pc,  v_sum_dg_vol_pc
            FROM DV_CT_PROD_STRM_PC_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_PC_FORECAST x
                WHERE x.forecast_type = v_forecast_type
                AND x.scenario = v_scenario
                AND x.PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = v_forecast_type
            AND scenario = v_scenario
            AND PROFIT_CENTRE_ID = v_UPG_id
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;


            --UPG for LNG
            SELECT sum(LNG_HHV * LNG_VOL_RATE), sum(LNG_VOL_RATE), sum(LNG_MASS_RATE) * 1000, sum(LNG_VOL_RATE) into v_avg_gcv_num_pc, v_avg_gcv_den_pc, v_avg_dens_num_pc, v_avg_dens_den_pc
            FROM DV_CT_PROD_STRM_PC_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_PC_FORECAST x
                WHERE x.forecast_type = v_forecast_type
                AND x.scenario = v_scenario
                AND x.PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = v_forecast_type
            AND scenario = v_scenario
            AND PROFIT_CENTRE_ID = v_UPG_id
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;

            --UPG for COND
            SELECT sum(COND_VOL_RATE), sum(COND_MASS_RATE) * 1000 into v_sum_cond_pc, v_avg_dens_cond_num_pc
            FROM DV_CT_PROD_STRM_PC_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_PC_FORECAST x
                WHERE x.forecast_type = v_forecast_type
                AND x.scenario = v_scenario
                AND x.PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = v_forecast_type
            AND scenario = v_scenario
            AND PROFIT_CENTRE_ID = v_UPG_id
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;

            IF v_avg_gcv_den_pc <> 0 THEN
                v_avg_gcv_pc := v_avg_gcv_num_pc / v_avg_gcv_den_pc;
            ELSE
                v_avg_gcv_pc := 0;
            END IF;

            IF v_avg_dens_den_pc <> 0 THEN
                v_avg_dens_pc := v_avg_dens_num_pc / v_avg_dens_den_pc;
            ELSE
                v_avg_dens_pc := 0;
            END IF;

            IF v_sum_cond_pc <> 0 THEN
                v_avg_cond_dens_pc := v_avg_dens_cond_num_pc / v_sum_cond_pc;
            ELSE
                v_avg_cond_dens_pc := 0;
            END IF;

            UPDATE DV_CT_PROD_STRM_FORECAST
            SET LNG_DENSITY_MTH = ROUND(v_avg_dens,3), LNG_VOL_RATE_MTH = v_avg_dens_den, LNG_HHV_MTH = ROUND(v_avg_gcv,3)
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');

            UPDATE DV_CT_PROD_STRM_FORECAST
            SET COND_VOL_RATE_MTH = v_sum_cond, COND_DENSITY_MTH = ROUND(v_avg_cond_dens,3)
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');

            UPDATE DV_CT_PROD_STRM_FORECAST
            SET DOMGAS_ENERGY_MTH = v_sum_dg ,DOMGAS_VOL_MTH_RATE = v_sum_dg_vol
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');


            UPDATE DV_CT_PROD_STRM_PC_FORECAST
            SET LNG_DENSITY_MTH = ROUND(v_avg_dens_pc,3), LNG_VOL_RATE_MTH = v_avg_dens_den_pc, LNG_HHV_MTH = ROUND(v_avg_gcv_pc,3)
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');

            UPDATE DV_CT_PROD_STRM_PC_FORECAST
            SET COND_VOL_RATE_MTH = v_sum_cond_pc, COND_DENSITY_MTH = ROUND(v_avg_cond_dens_pc,3)
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');

            UPDATE DV_CT_PROD_STRM_PC_FORECAST
            SET DOMGAS_ENERGY_MTH = v_sum_dg_pc, DOMGAS_VOL_MTH_RATE = v_sum_dg_vol_pc
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = v_forecast_type AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');
        END LOOP;
        END IF;
   END LOOP;


    --update DG Energy from midnight to 8am basis
--BUSNINESS_PLAN

    FOR DG_LOOP in DG_MORNING_DATA_TOTAL(ecdp_objects.getobjcode(v_forecast_id_guid_ADP)) loop
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE','F_JUL_BRU, GAS_DAY_ENERGY='||DG_LOOP.CALC_GAS_DAY_ENERGY || ' , GAS_DAY_VOL_RATE='|| DG_LOOP.CALC_GAS_DAY_VOL_RATE);
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE','F_JUL_BRU, v_forecast_id_guid_ADP='||v_forecast_id_guid_ADP || ' ' || ecdp_objects.getobjcode(v_forecast_id_guid_ADP) || ' DAYTIME='|| DG_LOOP.DAYTIME);
        UPDATE DV_CT_PROD_STRM_FORECAST
        SET GAS_DAY_DOMGAS_REGAS = DG_LOOP.CALC_GAS_DOMGAS_REGAS
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid_ADP
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;

    FOR DG_LOOP in DG_MORNING_DATA(ecdp_objects.getobjcode(v_forecast_id_guid_ADP),'F_JUL_BRU') loop
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE','F_JUL_BRU, GAS_DAY_ENERGY='||DG_LOOP.CALC_GAS_DAY_ENERGY || ' , GAS_DAY_VOL_RATE='|| DG_LOOP.CALC_GAS_DAY_VOL_RATE);
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE','F_JUL_BRU, v_forecast_id_guid_ADP='||v_forecast_id_guid_ADP || ' ' || ecdp_objects.getobjcode(v_forecast_id_guid_ADP) || ' DAYTIME='|| DG_LOOP.DAYTIME);
        UPDATE DV_CT_PROD_STRM_PC_FORECAST
        SET GAS_DAY_ENERGY = DG_LOOP.CALC_GAS_DAY_ENERGY, GAS_DAY_VOL_RATE = DG_LOOP.CALC_GAS_DAY_VOL_RATE
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND PROFIT_CENTRE_CODE LIKE 'F_JUL_BRU'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid_ADP
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;
    FOR DG_LOOP in DG_MORNING_DATA(ecdp_objects.getobjcode(v_forecast_id_guid_ADP),'F_WST_IAGO') loop
        UPDATE DV_CT_PROD_STRM_PC_FORECAST
        SET GAS_DAY_ENERGY = DG_LOOP.CALC_GAS_DAY_ENERGY, GAS_DAY_VOL_RATE = DG_LOOP.CALC_GAS_DAY_VOL_RATE
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND PROFIT_CENTRE_CODE LIKE 'F_WST_IAGO'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid_ADP
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;


--NOMINATION_PLAN

    FOR DG_LOOP in DG_MORNING_DATA_TOTAL(ecdp_objects.getobjcode(v_forecast_id_guid)) loop
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE','F_JUL_BRU, GAS_DAY_ENERGY='||DG_LOOP.CALC_GAS_DAY_ENERGY || ' , GAS_DAY_VOL_RATE='|| DG_LOOP.CALC_GAS_DAY_VOL_RATE);
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE','F_JUL_BRU, v_forecast_id_guid_ADP='||v_forecast_id_guid_ADP || ' ' || ecdp_objects.getobjcode(v_forecast_id_guid_ADP) || ' DAYTIME='|| DG_LOOP.DAYTIME);
        UPDATE DV_CT_PROD_STRM_FORECAST
        SET GAS_DAY_DOMGAS_REGAS = DG_LOOP.CALC_GAS_DOMGAS_REGAS
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;

    FOR DG_LOOP in DG_MORNING_DATA(ecdp_objects.getobjcode(v_forecast_id_guid),'F_JUL_BRU') loop
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE','F_JUL_BRU, GAS_DAY_ENERGY='||DG_LOOP.CALC_GAS_DAY_ENERGY || ' , GAS_DAY_VOL_RATE='|| DG_LOOP.CALC_GAS_DAY_VOL_RATE);
        --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE','F_JUL_BRU, v_forecast_id_guid='||v_forecast_id_guid || ' ' || ecdp_objects.getobjcode(v_forecast_id_guid) || ' DAYTIME='|| DG_LOOP.DAYTIME);
        UPDATE DV_CT_PROD_STRM_PC_FORECAST
        SET GAS_DAY_ENERGY = DG_LOOP.CALC_GAS_DAY_ENERGY, GAS_DAY_VOL_RATE = DG_LOOP.CALC_GAS_DAY_VOL_RATE
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND PROFIT_CENTRE_CODE LIKE 'F_JUL_BRU'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;
    FOR DG_LOOP in DG_MORNING_DATA(ecdp_objects.getobjcode(v_forecast_id_guid),'F_WST_IAGO') loop
        UPDATE DV_CT_PROD_STRM_PC_FORECAST
        SET GAS_DAY_ENERGY = DG_LOOP.CALC_GAS_DAY_ENERGY, GAS_DAY_VOL_RATE = DG_LOOP.CALC_GAS_DAY_VOL_RATE
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND PROFIT_CENTRE_CODE LIKE 'F_WST_IAGO'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;
--


END LoadOthProdForecasts;
-----------------------------------------------------------------------------------------------------
-- Load Capacity forecast data from the staging tables (see the data mapping document for details)
--Assumption for this CPP data as of 17-Sep-2014:
-----------------------------------------------------------------------------------------------------
PROCEDURE LoadCapForecasts(p_datastage_code VARCHAR2)
IS
    CURSOR GET_PROD_FORECAST(cp_data_stage_code VARCHAR2, cp_forecast_type VARCHAR2, cp_eff_date DATE) IS
    SELECT *
    FROM OV_CT_PROD_FORECAST
    WHERE (cp_data_stage_code IS NULL OR cp_data_stage_code = FCST_CPP_ID)
    AND (cp_eff_date IS NULL OR daytime = cp_eff_date)
    AND (cp_forecast_type IS NULL OR forecast_type = cp_forecast_type);

    CURSOR GET_CAP_FORECAST(cp_data_stage_code VARCHAR2) IS
    SELECT * FROM TV_CT_STAGE_AVAIL_CAP_FCST
    WHERE (cp_data_stage_code = DATA_STAGE_CODE)
    AND  EXISTS(SELECT 'TRUE' FROM TV_CT_STAGE_PROD_PC_FCST WHERE DATA_STAGE_CODE = cp_data_stage_code AND FORECAST_TYPE = 'NOMINATIONS_PLAN' )
    ORDER BY DAYTIME,UPG_ID,PARTY_ID;

    lv_total NUMBER;
    lv_fcst_cpp_id  VARCHAR2(256);
    lv_forecast_object_id  VARCHAR2(256);
    lv_forecast_object_code  VARCHAR2(256);
    lv_UPG_CODE  VARCHAR2(256);
    lv_PARTY_CODE  VARCHAR2(256);
    lv_ERR  VARCHAR2(256);

BEGIN
-- first get the v_forecast_id_guid(OV_CT_PROD_FORECAST)
-- Assumption: The Data Stage Code is the same across for each time Quintic producing a plan, the Reporting DB will then split into different dataand IDV insert them into EC staging with the same Data Stage Code
-- This simply means the Data Stage Code from the Production Forecast is the same as the Data Stage Code in Capacity Forecast.
-- We have had loaded the Production Forecast before calling this package, hence the OV_CT_PROD_FORECAST has been already created.
-- But if NOT, then it means the Profile Plan Type is NOT "ADP_PLAN" nor "SDS_PLAN"
-- This means we need to create an Entry in OV_CT_PROD_FORECAST before loading the data from the staging.

    lv_fcst_cpp_id := NULL;
    lv_ERR := 'N';

    FOR CHK_FORECAST IN GET_PROD_FORECAST(p_datastage_code, NULL,NULL) LOOP
        lv_fcst_cpp_id := CHK_FORECAST.FCST_CPP_ID;
        lv_forecast_object_id := CHK_FORECAST.OBJECT_ID;
    END LOOP;

    IF lv_fcst_cpp_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'No Forecast found in EC' );
    END IF;

    FOR UPD_FORECAST IN GET_CAP_FORECAST(p_datastage_code) LOOP
        IF NVL(UPD_FORECAST.DELIVERY_POINT_CODE,'N') = 'N' THEN
            lv_ERR:= 'Y';
            ECDP_DYNSQL.WRITETEMPTEXT('TV_CT_STAGE_AVAIL_CAP_FCST (' || p_datastage_code || ')' ,'Cannot Decode DETERMIN_POINT_ID ' || UPD_FORECAST.CONTRACT_CODE || ' and delivery point ' || UPD_FORECAST.DETERMIN_POINT_ID);
        END IF;
    END LOOP;
    IF (lv_ERR = 'Y') THEN
        RAISE_APPLICATION_ERROR(-20000, 'Cannot Decode DETERMIN_POINT_ID, please check T_temptext for detail error.' );
    END IF;

    --if there isn't any cross reference found in the CPP Util package, it shall return error and the whole insert will be failed.
    --this is to ensure the data didn't get loaded partially into the system
    SELECT count(UE_CT_CPP_UTIL.GETNOMPNTFROMCNTRDELPNT(
    EC_CONTRACT.OBJECT_ID_BY_UK(CONTRACT_CODE), --EXPECTING DECODED CONTRACT CODE
    EC_DELIVERY_POINT.OBJECT_ID_BY_UK(DELIVERY_POINT_CODE) -- EXPECTING DELIVERY_POINT_CODE
    )) AS TOTAL INTO lv_total
    FROM TV_CT_STAGE_AVAIL_CAP_FCST
    WHERE DATA_STAGE_CODE = p_datastage_code;

    MERGE INTO CT_TRNP_AVAIL_CAP_FCST FCAST
         USING(SELECT
                  UE_CT_CPP_UTIL.GETNOMPNTFROMCNTRDELPNT(
                    EC_CONTRACT.OBJECT_ID_BY_UK(TV.CONTRACT_CODE), --EXPECTING DECODED CONTRACT CODE
                    EC_DELIVERY_POINT.OBJECT_ID_BY_UK(TV.DELIVERY_POINT_CODE) -- EXPECTING DELIVERY_POINT_CODE
                    ) AS NOMPNT_ID
                , 'CT_TRNP_AVAIL_CAP_FCST'                      AS CLASS_NAME
                , TV.DAYTIME                                    AS DAYTIME
                , EC_CT_PROD_FORECAST.START_DATE(lv_forecast_object_id)    AS EFFECTIVE_DAYTIME
                , EC_CT_PROD_FORECAST.FCST_CPP_ID(lv_forecast_object_id)   AS FCST_CPP_ID
                , EC_CT_PROD_FORECAST.FCST_SCEN_NO(lv_forecast_object_id)  AS FCST_SCEN_NO
                , EC_CT_PROD_FORECAST.FORECAST_TYPE(lv_forecast_object_id) AS FORECAST_TYPE
                , EC_CT_PROD_FORECAST.SCENARIO(lv_forecast_object_id)  AS SCENARIO
                , TV.DETERMIN_POINT_UOM                         AS UOM
                , TV.AVAIL_CAPACITY                             AS AVAIL_CAP_QTY
                , TV.ADJ_AVAIL_CAPACITY                         AS ADJ_AVAIL_CAP_QTY
                , TV.FORECAST_FLOW                              AS FORECAST_FLOW_QTY
                , TV.FORECAST_FLOW_ENERGY                       AS FORECAST_FLOW_QTY_GJ
                , lv_forecast_object_id                           AS FORECAST_ID
              FROM  TV_CT_STAGE_AVAIL_CAP_FCST TV
              WHERE TV.DATA_STAGE_CODE = p_datastage_code) STAGE
         ON (STAGE.NOMPNT_ID = FCAST.OBJECT_ID
         AND STAGE.DAYTIME = FCAST.DAYTIME
         AND STAGE.FORECAST_ID = FCAST.REF_OBJECT_ID_1
         AND STAGE.CLASS_NAME = FCAST.CLASS_NAME)
        WHEN MATCHED THEN
        UPDATE SET
              FCAST.EFFECTIVE_DAYTIME = STAGE.EFFECTIVE_DAYTIME
            , FCAST.FCST_CPP_ID = STAGE.FCST_CPP_ID
            , FCAST.FCST_SCEN_NO = STAGE.FCST_SCEN_NO
            , FCAST.FORECAST_TYPE = STAGE.FORECAST_TYPE
            , FCAST.SCENARIO = STAGE.SCENARIO
            , FCAST.UOM = STAGE.UOM
            , FCAST.AVAIL_CAP_QTY = STAGE.AVAIL_CAP_QTY
            , FCAST.ADJ_AVAIL_CAP_QTY = STAGE.ADJ_AVAIL_CAP_QTY
            , FCAST.FORECAST_FLOW_QTY = STAGE.FORECAST_FLOW_QTY
            , FCAST.FORECAST_FLOW_QTY_GJ = STAGE.FORECAST_FLOW_QTY_GJ
            , FCAST.REV_NO =   NVL(FCAST.REV_NO, 0) + 1
            , FCAST.REV_TEXT = 'EXISTING FCST DATA WITH ID ' || FCAST.FCST_CPP_ID || ' UPDATED WITH ID ' || STAGE.FCST_CPP_ID
            , FCAST.LAST_UPDATED_BY = NVL(ECDP_USER_SESSION.GETUSERSESSIONPARAMETER('USERNAME'), 'CPP INTERFACE')
        WHEN NOT MATCHED THEN
        INSERT (  FCAST.OBJECT_ID
                , FCAST.CLASS_NAME
                , FCAST.DAYTIME
                , FCAST.EFFECTIVE_DAYTIME
                , FCAST.FCST_CPP_ID --FCST_CPP_ID
                , FCAST.FCST_SCEN_NO
                , FCAST.FORECAST_TYPE
                , FCAST.SCENARIO
                , FCAST.UOM
                , FCAST.AVAIL_CAP_QTY
                , FCAST.ADJ_AVAIL_CAP_QTY
                , FCAST.FORECAST_FLOW_QTY
                , FCAST.FORECAST_FLOW_QTY_GJ
                , FCAST.REF_OBJECT_ID_1 --FORECAST_OBJECT_ID
                , FCAST.REV_TEXT
                , FCAST.LAST_UPDATED_BY)
        VALUES  ( STAGE.NOMPNT_ID
                , STAGE.CLASS_NAME
                , STAGE.DAYTIME
                , STAGE.EFFECTIVE_DAYTIME
                , STAGE.FCST_CPP_ID
                , STAGE.FCST_SCEN_NO
                , STAGE.FORECAST_TYPE
                , STAGE.SCENARIO
                , STAGE.UOM
                , STAGE.AVAIL_CAP_QTY
                , STAGE.ADJ_AVAIL_CAP_QTY
                , STAGE.FORECAST_FLOW_QTY
                , STAGE.FORECAST_FLOW_QTY_GJ
                , STAGE.FORECAST_ID
                , 'NEW FCST DATA WITH ID ' || STAGE.FCST_CPP_ID || ' LOADED'
                , NVL(ECDP_USER_SESSION.GETUSERSESSIONPARAMETER('USERNAME'), 'CPP INTERFACE'));

    --NULL;

END LoadCapForecasts;

-----------------------------------------------------------------------------------------------------
-- Helper procedure to delete out old production forecast data
-----------------------------------------------------------------------------------------------------
PROCEDURE ClearProductionForecast(p_effective_daytime DATE, p_forecast_type VARCHAR2, p_scenario_type VARCHAR2)
IS
    CURSOR get_forecast IS
    SELECT object_id
    FROM ov_forecast_prod
    WHERE daytime = p_effective_daytime
    AND ec_forecast_group.forecast_type(forecast_group_id) = p_forecast_type
    AND code = p_scenario_type;

BEGIN

    FOR item IN get_forecast LOOP
        DELETE FROM dv_FCST_STREAM_DAY_STATUS WHERE object_id = item.object_id;
        DELETE FROM DV_CT_PROD_STRM_PC_FORECAST WHERE object_id = item.object_id;
    END LOOP;

    DELETE FROM ov_forecast_prod
    WHERE daytime = p_effective_daytime
    AND ec_forecast_group.forecast_type(forecast_group_id) = p_forecast_type
    AND code = p_scenario_type;

END ClearProductionForecast;

-----------------------------------------------------------------------------------------------------
-- Load production forecast data from the staging tables (see the data mapping document for details)
-- Loaded Production Forecast is ONLY the Subset of the data sent by Quintiq for ADP/SDS plan.
--Assumption for this CPP data as of 17-Sep-2014:
--HHV in MMBTU/m3 (as of 04-Nov-2014)
--LNG_DENSITY in kg/m3 (directly from CPP as of 06-Nov-2014)
--LNG_REGAS_REQ_LNG in m3 (directly from CPP as of 12-JUN-2015)
--CONFIRMED_EXCESS_QTY in MMBTU (directly from CPP as of 12-JUN-2015)
--COND_DENSITY in kg/m3 (directly from CPP as of 06-Nov-2014)
--Mass rate in Tonnes
--Vol Rate in m3
--Expected output from this package:
--LNG monthly HHV in MMBTU/m3
--monthly density(both LNG and COND) in kg/m3 calculated by taking the sumOfdaily(Mass)/SumOfdaily(Vol)
--for DOMGAS: we need only DOMGAS_ENERGY AND DOMGAS_ENERGY_MTH (GJPERDAY)
-----------------------------------------------------------------------------------------------------
PROCEDURE LoadProductionForecasts(p_datastage_code VARCHAR2)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    CURSOR prod_forecast_stage(cp_forecast_type VARCHAR2, cp_probability_type VARCHAR2, cp_start_date DATE, cp_end_date DATE, cp_UPG VARCHAR2) IS
    SELECT daytime, forecast_type, probability_type, UPG AS PROFIT_CENTRE_CODE,
        EcDp_Unit.ConvertValue(PLATFORM_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','PLATFORM_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','PLATFORM_MASS_SMPP')), DAYTIME) as PLATFORM_MASS_SMPP,
        EcDp_Unit.ConvertValue(LNG_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_DENSITY')), DAYTIME) as LNG_DENSITY,
        EcDp_Unit.ConvertValue(COND_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_DENSITY')), DAYTIME) as COND_DENSITY,
        EcDp_Unit.ConvertValue(LNG_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_VOL_RATE')), DAYTIME) as LNG_VOL_RATE,
        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD')), DAYTIME) as LNG_EXCESS_PROD,
        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_LNG, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_LNG')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_LNG')), DAYTIME) as LNG_REGAS_REQ_LNG,
        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_QTY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_QTY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_QTY')), DAYTIME) as CONFIRMED_EXCESS_QTY,
        EcDp_Unit.ConvertValue(LNG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV')), DAYTIME) as LNG_HHV,
        EcDp_Unit.ConvertValue(LNG_HHV_GJSM3, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV_GJSM3')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV_STD')), DAYTIME) as LNG_HHV_STD,
        EcDp_Unit.ConvertValue(LNG_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_RATE')), DAYTIME) as LNG_MASS_RATE,
        EcDp_Unit.ConvertValue(LNG_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_SMPP')), DAYTIME) as LNG_MASS_SMPP,
        EcDp_Unit.ConvertValue(COND_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_VOL_RATE')), DAYTIME) as COND_VOL_RATE,
        EcDp_Unit.ConvertValue(COND_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_RATE')), DAYTIME) as COND_MASS_RATE,
        EcDp_Unit.ConvertValue(COND_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_SMPP')), DAYTIME) as COND_MASS_SMPP,
        EcDp_Unit.ConvertValue(DOMGAS_MASS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MASS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MASS_RATE')), DAYTIME) as DOMGAS_MASS_RATE,
        EcDp_Unit.ConvertValue(DOMGAS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_ENERGY')), DAYTIME) as DOMGAS_ENERGY,
        EcDp_Unit.ConvertValue(DOMGAS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_SMPP')), DAYTIME) as DOMGAS_SMPP,
        EcDp_Unit.ConvertValue(DOMGAS_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_HHV')), DAYTIME) as DOMGAS_HHV,
        EcDp_Unit.ConvertValue(DOMGAS_MIN_RATE_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MIN_RATE_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MIN_RATE_ENERGY')), DAYTIME) as DOMGAS_MIN_RATE_ENERGY,
        EcDp_Unit.ConvertValue(DOMGAS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL_RATE')), DAYTIME) as DOMGAS_VOL_RATE,
        EcDp_Unit.ConvertValue(DOMGAS_REGAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_REGAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_REGAS')), DAYTIME) as DOMGAS_REGAS,
        EcDp_Unit.ConvertValue(IMBALANCE_ADJ_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_VOLUME')), DAYTIME) as IMBALANCE_ADJ_VOLUME,
        EcDp_Unit.ConvertValue(IMBALANCE_ADJ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_ENERGY')), DAYTIME) as IMBALANCE_ADJ_ENERGY,
        EcDp_Unit.ConvertValue(UNMET_AMOUNT_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_VOLUME')), DAYTIME) as UNMET_AMOUNT_VOLUME,
        EcDp_Unit.ConvertValue(UNMET_AMOUNT_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_ENERGY')), DAYTIME) as UNMET_AMOUNT_ENERGY
    FROM TV_CT_STAGE_PROD_PC_FCST
    WHERE data_stage_code = p_datastage_code
    AND forecast_type = cp_forecast_type
    AND probability_type = cp_probability_type
    AND daytime >= cp_start_date
    AND daytime < cp_end_date
    AND UPG = cp_UPG
    ORDER BY daytime DESC;

    --TLXT: 101266: getting the second last available if not the last available record
    CURSOR get_forecast (cp_forecast_type VARCHAR2, cp_probability_type VARCHAR2, cp_eff_date DATE, cp_record_status VARCHAR2 DEFAULT 'A') IS
    SELECT *
    FROM OV_CT_PROD_FORECAST
    WHERE daytime = cp_eff_date
    AND forecast_type = cp_forecast_type
    AND scenario = cp_probability_type
    AND RECORD_STATUS = cp_record_status
    AND CREATED_DATE =  (
          select
             min(CREATED_DATE)
          from (
               select
                  distinct(A.CREATED_DATE)
               from
                  OV_CT_PROD_FORECAST  A
    WHERE A.daytime = cp_eff_date
    AND A.forecast_type = cp_forecast_type
    AND A.scenario = cp_probability_type
    AND A.RECORD_STATUS = cp_record_status
               order by
                  CREATED_DATE desc)
               where
                  rownum<=2);

    CURSOR get_forecast_dsid (cp_forecast_type VARCHAR2, cp_eff_date DATE) IS
    SELECT *
    FROM OV_CT_PROD_FORECAST
    WHERE daytime = cp_eff_date
    AND forecast_type = cp_forecast_type;

    CURSOR prod_forecast_types IS
    SELECT DISTINCT upper(forecast_type) forecast_type, upper(probability_type) probability_type, UPPER(UPG) PROFIT_CENTRE_CODE, DATA_STAGE_CODE
    FROM
    (
        SELECT data_stage_code, forecast_type, probability_type ,UPG
        FROM TV_CT_STAGE_PROD_PC_FCST
    )
    WHERE data_stage_code = p_datastage_code;

    CURSOR month_starts(cp_year_type VARCHAR2, cp_datastage_code VARCHAR2, cp_forecast_type VARCHAR2, cp_probability_type VARCHAR2) IS
    SELECT DISTINCT daytime
    FROM
    (
        SELECT trunc(daytime, 'MONTH') daytime
        FROM TV_CT_STAGE_PROD_PC_FCST
        WHERE data_stage_code = cp_datastage_code
        AND forecast_type = cp_forecast_type
        AND probability_type = cp_probability_type
    );

    CURSOR year_starts(cp_year_type VARCHAR2, cp_datastage_code VARCHAR2, cp_forecast_type VARCHAR2, cp_probability_type VARCHAR2) IS
    SELECT DISTINCT daytime
    FROM
    (
        SELECT trunc(daytime, 'YEAR') daytime
        FROM TV_CT_STAGE_PROD_PC_FCST
        WHERE data_stage_code = cp_datastage_code
        AND forecast_type = cp_forecast_type
        AND probability_type = cp_probability_type
    )
    WHERE cp_year_type = 'CALENDAR'
    UNION ALL
    SELECT DISTINCT add_months(daytime, 3)
    FROM
    (
        SELECT trunc(add_months(daytime, -3), 'YEAR') daytime
        FROM TV_CT_STAGE_PROD_PC_FCST
        WHERE data_stage_code = cp_datastage_code
        AND forecast_type = cp_forecast_type
        AND probability_type = cp_probability_type
    )
    WHERE cp_year_type = 'LIFTING';

    CURSOR sds_scenarios(cp_scenario VARCHAR2) IS
    SELECT OBJECT_ID,CODE,fcst_scen_no
    FROM OV_CT_PROD_FORECAST
    WHERE forecast_type = 'SDS_PLAN'
    AND scenario = cp_scenario
    ORDER BY daytime ASC;

    CURSOR scenarios(cp_forecast_type VARCHAR2, cp_scenario VARCHAR2, cp_daytime DATE) IS
    SELECT fcst_scen_no
    FROM OV_CT_PROD_FORECAST
    WHERE forecast_type = cp_forecast_type
    AND scenario = cp_scenario
    AND daytime = cp_daytime
    ORDER BY daytime ASC;

    CURSOR months_in_plan(cp_forecast_type VARCHAR2, cp_probability_type VARCHAR2) IS
    SELECT DISTINCT trunc(daytime, 'MON') AS daytime
    FROM TV_CT_STAGE_PROD_PC_FCST
    WHERE data_stage_code = p_datastage_code
    AND forecast_type = cp_forecast_type
    AND probability_type = cp_probability_type
    ORDER BY trunc(daytime, 'MON') DESC;

    CURSOR DG_MORNING_DATA(cp_FORECAST_OBJECT_CODE VARCHAR2, cp_PROFIT_CENTRE_CODE VARCHAR2) IS
    SELECT FORECAST_OBJECT_CODE, PROFIT_CENTRE_CODE,DAYTIME,DOMGAS_ENERGY, DOMGAS_VOL_RATE,
    NVL((ROUND((LEAD(DOMGAS_ENERGY,1) OVER (ORDER BY DAYTIME)/3) ,6)+(DOMGAS_ENERGY-ROUND((DOMGAS_ENERGY/3),6))),DOMGAS_ENERGY) AS CALC_GAS_DAY_ENERGY,
    NVL((ROUND((LEAD(DOMGAS_VOL_RATE,1) OVER (ORDER BY DAYTIME)/3) ,6)+(DOMGAS_VOL_RATE-ROUND((DOMGAS_VOL_RATE/3),6))),DOMGAS_VOL_RATE) AS CALC_GAS_DAY_VOL_RATE
    FROM
    (
    SELECT
    FORECAST_OBJECT_CODE, PROFIT_CENTRE_CODE,DAYTIME,DOMGAS_ENERGY, DOMGAS_VOL_RATE
    FROM DV_CT_PROD_STRM_PC_FORECAST
    WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
    AND PROFIT_CENTRE_CODE = cp_PROFIT_CENTRE_CODE -- 'F_JUL_BRU'
    AND FORECAST_OBJECT_CODE = cp_FORECAST_OBJECT_CODE
    ORDER BY FORECAST_OBJECT_CODE,DAYTIME
    )CONV;

    CURSOR DG_MORNING_DATA_TOTAL(cp_FORECAST_OBJECT_CODE VARCHAR2) IS
    SELECT FORECAST_OBJECT_CODE,  DAYTIME,
    NVL((ROUND((LEAD(DOMGAS_REGAS,1) OVER (ORDER BY DAYTIME)/3) ,6)+(DOMGAS_REGAS-ROUND((DOMGAS_REGAS/3),6))),DOMGAS_REGAS) AS CALC_GAS_DOMGAS_REGAS
    FROM
    (
    SELECT
    FORECAST_OBJECT_CODE,DAYTIME, DOMGAS_REGAS
    FROM DV_CT_PROD_STRM_FORECAST
    WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
    AND FORECAST_OBJECT_CODE = cp_FORECAST_OBJECT_CODE
    ORDER BY FORECAST_OBJECT_CODE,DAYTIME
    )CONV;

    v_fcst_scen_no NUMBER;
    v_effective_daytime DATE;
    v_plan_type VARCHAR2(256);
    v_scenario VARCHAR2(256);
    v_temp_scenario VARCHAR2(256);
    v_UPG VARCHAR2(256);
    v_UPG_id VARCHAR2(256);
    v_ds_id VARCHAR2(256);
    v_sds_id VARCHAR2(256);
    v_ds_name VARCHAR2(256);
    v_Record_status VARCHAR2(256);
    v_seq NUMBER;
    v_seq_str VARCHAR2(256);
    v_count NUMBER;
    v_count_2 NUMBER;
    v_count_ALL NUMBER;
    v_count_UPG NUMBER;
    v_avg_gcv NUMBER;
    v_avg_dens NUMBER;
    v_avg_gcv_num NUMBER;
    v_avg_gcv_den NUMBER;
    v_avg_dens_num NUMBER;
    v_avg_dens_den NUMBER;
    v_avg_gcv_pc NUMBER;
    v_avg_dens_pc NUMBER;
    v_avg_gcv_num_pc NUMBER;
    v_avg_gcv_den_pc NUMBER;
    v_avg_dens_num_pc NUMBER;
    v_avg_dens_den_pc NUMBER;
    v_sum_cond NUMBER;
    v_avg_cond_dens NUMBER;
    v_sum_cond_pc NUMBER;
    v_avg_cond_dens_pc NUMBER;
    v_avg_dens_cond_num NUMBER;
    v_avg_dens_cond_den NUMBER;
    v_avg_dens_cond_num_pc NUMBER;
    v_forecast_id_guid VARCHAR2(32);
    v_forecast_id_guid_ADP VARCHAR2(32);
    v_prev_forecast_id_guid VARCHAR2(32);
    v_DATA_STAGE_CODE VARCHAR2(32);
    v_sum_dg NUMBER;
    v_sum_dg_pc NUMBER;
    v_sum_dg_vol NUMBER;
    v_sum_dg_vol_pc NUMBER;
    v_avg_dg NUMBER;

BEGIN

    -- Loop through all production forecast types in this data staging.
    FOR type_item IN prod_forecast_types LOOP
        -- Get the scenario type
        SELECT DECODE(TRIM(type_item.probability_type), 'H', 'HIGH_CONF', 'M', 'MED_CONF', 'L','LOW_CONF','R','REF_PROD','UNKNOWN') INTO v_scenario FROM DUAL;
        IF (v_scenario = 'UNKNOWN') THEN
            RAISE_APPLICATION_ERROR(-20999, 'Message probability type must be "H" or "M" or "L" or "R"  ');
        END IF;
        -- Is this an ADP/PADP forecast?
        IF type_item.forecast_type = 'ADP_PLAN' THEN
            FOR year_item IN year_starts('LIFTING', p_datastage_code, type_item.forecast_type, type_item.probability_type) LOOP
                v_effective_daytime := year_item.daytime;
                v_Record_status := 'N';
                v_count_2 := 0;
                --every production profile sent by CPP has to be captured and assigned a new forecast code regardless we using it or not.
                --each preoduction profile consist of 2 UPGs and 1 Total, BUt only 1 production profile needs to be created.
                IF type_item.DATA_STAGE_CODE <> NVL(v_DATA_STAGE_CODE,'N') THEN
                    v_count := 0;
                    v_DATA_STAGE_CODE := type_item.DATA_STAGE_CODE;
                ELSE
                    v_count := 1;
                END IF;
                IF v_count = 0 THEN
                    SELECT count(*) INTO v_count_2
                    FROM OV_CT_PROD_FORECAST
                    WHERE forecast_type = 'ADP_PLAN'
                    AND scenario = v_scenario
                    AND OBJECT_START_DATE = v_effective_daytime;
                    --AND RECORD_STATUS <> 'P';
                    v_seq := v_count_2 + 1 ;
                    --v_ds_id:= 'ADP_'|| v_scenario || '_' || TO_CHAR(v_seq)|| '_' || to_char(TRUNC(v_effective_daytime,'YEAR'),'YYYY')  ;
                    --assign FCST_DS_ID:  [ADP/SDS]_[RP,HC,MC,LC]_[DS Code]_[YYYY]_[VERSION]
                    SELECT DECODE(TRIM(v_scenario), 'HIGH_CONF', 'HC', 'MED_CONF', 'MC', 'LOW_CONF','LC','REF_PROD','RP') INTO v_temp_scenario FROM DUAL;
                    v_ds_id:= 'ADP_'|| v_temp_scenario || '_' || p_datastage_code || '_' || to_char(TRUNC(v_effective_daytime,'YEAR'),'YYYY') || '_' || TRIM(TO_CHAR(v_seq,'009'))   ;
                    SELECT DECODE(TRIM(v_scenario), 'HIGH_CONF', 'High Conf', 'MED_CONF', 'Med Conf', 'LOW_CONF','Low Conf','REF_PROD','Ref Prod') INTO v_temp_scenario FROM DUAL;
                    v_ds_name:= 'ADP '|| v_temp_scenario || ' ' || p_datastage_code || ' ' || to_char(TRUNC(v_effective_daytime,'YEAR'),'YYYY') || '_' || TRIM(TO_CHAR(v_seq,'009'))   ;
                ELSE
                    SELECT OBJECT_ID, CODE, fcst_scen_no INTO v_forecast_id_guid, v_ds_id, v_fcst_scen_no
                    FROM OV_CT_PROD_FORECAST
                    WHERE forecast_type = 'ADP_PLAN'
                    AND scenario = v_scenario
                    AND OBJECT_START_DATE = v_effective_daytime
                    AND RECORD_STATUS = 'P'
                    and CODE = v_ds_id;
                END IF;

                IF v_count = 0 THEN
                    EcDp_System_Key.assignNextNumber('CT_PROD_FORECAST', v_fcst_scen_no);
                    INSERT INTO OV_CT_PROD_FORECAST (CODE, NAME, fcst_scen_no, forecast_type, scenario, DAYTIME, OBJECT_END_DATE,FCST_CPP_ID)
                    VALUES (v_ds_id,v_ds_name,v_fcst_scen_no, 'ADP_PLAN', v_scenario, v_effective_daytime, ADD_MONTHS(v_effective_daytime,12), p_datastage_code);
                    UPDATE OV_CT_PROD_FORECAST
                    SET OBJECT_END_DATE = ADD_MONTHS(OBJECT_START_DATE,12)
                    WHERE CODE = v_ds_id;

                    v_forecast_id_guid := ECDP_OBJECTS.GETOBJIDFROMCODE('CT_PROD_FORECAST',v_ds_id);
                    --intiliazed the new forecast with the previous forecast values
                    IF v_count_2 > 0 THEN
                        FOR latest_forecast in get_forecast('ADP_PLAN' , v_scenario , v_effective_daytime , 'P') LOOP
                            v_prev_forecast_id_guid := latest_forecast.OBJECT_ID;
                        END LOOP;
                        FOR latest_forecast in get_forecast('ADP_PLAN' , v_scenario , v_effective_daytime , 'V') LOOP
                            v_prev_forecast_id_guid := latest_forecast.OBJECT_ID;
                        END LOOP;
                        FOR latest_forecast in get_forecast('ADP_PLAN' , v_scenario , v_effective_daytime , 'A') LOOP
                            v_prev_forecast_id_guid := latest_forecast.OBJECT_ID;
                        END LOOP;

                        INSERT INTO DV_CT_PROD_STRM_FORECAST
                        (        FORECAST_OBJECT_ID, FCST_CPP_ID,         object_id, daytime, forecast_type, scenario, effective_daytime
                        , LNG_HHV_STD, LNG_VOL_RATE,LNG_EXCESS_PROD, LNG_REGAS_REQ_LNG, CONFIRMED_EXCESS_QTY, LNG_HHV, LNG_MASS_RATE, LNG_DENSITY,LNG_DENSITY_MTH, LNG_VOL_RATE_MTH, LNG_HHV_MTH, COND_VOL_RATE_MTH, COND_VOL_RATE, cond_mass_rate,COND_DENSITY
                        , DOMGAS_MASS_RATE,DOMGAS_VOL_RATE,DOMGAS_VOL_MTH_RATE,DOMGAS_ENERGY,DOMGAS_ENERGY_MTH,DOMGAS_HHV,DOMGAS_SMPP,DOMGAS_REGAS,DOMGAS_MIN_RATE_ENERGY
                        ,IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY
                        )
                        SELECT     v_forecast_id_guid, p_datastage_code,     object_id, daytime, forecast_type, scenario, effective_daytime
                        ,LNG_HHV_STD, LNG_VOL_RATE,LNG_EXCESS_PROD, LNG_REGAS_REQ_LNG, CONFIRMED_EXCESS_QTY, LNG_HHV, LNG_MASS_RATE, LNG_DENSITY,LNG_DENSITY_MTH, LNG_VOL_RATE_MTH, LNG_HHV_MTH, COND_VOL_RATE_MTH,COND_VOL_RATE, cond_mass_rate,COND_DENSITY
                        , DOMGAS_MASS_RATE,DOMGAS_VOL_RATE,DOMGAS_VOL_MTH_RATE,DOMGAS_ENERGY,DOMGAS_ENERGY_MTH,DOMGAS_HHV,DOMGAS_SMPP,DOMGAS_REGAS,DOMGAS_MIN_RATE_ENERGY
                        ,IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY
                        FROM DV_CT_PROD_STRM_FORECAST
                        WHERE FORECAST_OBJECT_ID = v_prev_forecast_id_guid
                        AND forecast_type = 'ADP_PLAN'
                        AND scenario = v_scenario
                        AND effective_daytime = v_effective_daytime;

                        INSERT INTO DV_CT_PROD_STRM_PC_FORECAST
                        (        PROFIT_CENTRE_ID,FORECAST_OBJECT_ID, FCST_CPP_ID,         object_id, daytime, forecast_type, scenario, effective_daytime
                        ,LNG_HHV_STD, LNG_VOL_RATE,LNG_EXCESS_PROD, LNG_REGAS_REQ_LNG, CONFIRMED_EXCESS_QTY, LNG_HHV, LNG_MASS_RATE, LNG_DENSITY,LNG_DENSITY_MTH, LNG_VOL_RATE_MTH, LNG_HHV_MTH, COND_VOL_RATE_MTH,COND_VOL_RATE, cond_mass_rate,COND_DENSITY
                        , DOMGAS_MASS_RATE,DOMGAS_VOL_RATE,DOMGAS_VOL_MTH_RATE,DOMGAS_ENERGY,DOMGAS_ENERGY_MTH,DOMGAS_HHV,DOMGAS_SMPP,DOMGAS_REGAS,DOMGAS_MIN_RATE_ENERGY
                        ,IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY
                        )
                        SELECT     PROFIT_CENTRE_ID,v_forecast_id_guid, p_datastage_code,     object_id, daytime, forecast_type, scenario, effective_daytime
                        ,LNG_HHV_STD, LNG_VOL_RATE,LNG_EXCESS_PROD, LNG_REGAS_REQ_LNG, CONFIRMED_EXCESS_QTY, LNG_HHV, LNG_MASS_RATE, LNG_DENSITY,LNG_DENSITY_MTH, LNG_VOL_RATE_MTH, LNG_HHV_MTH, COND_VOL_RATE_MTH,COND_VOL_RATE, cond_mass_rate,COND_DENSITY
                        , DOMGAS_MASS_RATE,DOMGAS_VOL_RATE,DOMGAS_VOL_MTH_RATE,DOMGAS_ENERGY,DOMGAS_ENERGY_MTH,DOMGAS_HHV,DOMGAS_SMPP,DOMGAS_REGAS,DOMGAS_MIN_RATE_ENERGY
                        ,IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY
                        FROM DV_CT_PROD_STRM_PC_FORECAST
                        WHERE FORECAST_OBJECT_ID = v_prev_forecast_id_guid
                        AND forecast_type = 'ADP_PLAN'
                        AND scenario = v_scenario
                        AND effective_daytime = v_effective_daytime;
                    END IF;

                END IF;
                -- Loop through the values
                FOR value_item IN prod_forecast_stage(type_item.forecast_type, type_item.probability_type, v_effective_daytime, add_months(v_effective_daytime, 12), type_item.PROFIT_CENTRE_CODE) LOOP
                    -- Get the PROFIT_CENTRE_CODE
                    SELECT DECODE(TRIM(value_item.PROFIT_CENTRE_CODE), 'F_WST_IAGO', 'F_WST_IAGO', 'F_JUL_BRU', 'F_JUL_BRU','ALL','ALL','UNKNOWN') INTO v_UPG FROM DUAL;
                    IF (v_UPG = 'UNKNOWN') THEN
                        RAISE_APPLICATION_ERROR(-20998, 'Message UPG Code type must be "F_WST_IAGO" or "F_JUL_BRU" or "ALL" ');
                    END IF;
                    v_UPG_id := ECDP_OBJECTS.GETOBJIDFROMCODE('FIELD',v_UPG);
                    SELECT count(*) INTO v_count_ALL
                    FROM DV_CT_PROD_STRM_FORECAST
                    WHERE FORECAST_OBJECT_CODE = v_ds_id
                    AND forecast_type = 'ADP_PLAN'
                    AND scenario = v_scenario
                    AND effective_daytime = v_effective_daytime
                    AND daytime = value_item.daytime;

                    SELECT count(*) INTO v_count_UPG
                    FROM DV_CT_PROD_STRM_PC_FORECAST
                    WHERE FORECAST_OBJECT_CODE = v_ds_id
                    AND forecast_type = 'ADP_PLAN'
                    AND scenario = v_scenario
                    AND effective_daytime = v_effective_daytime
                    AND daytime = value_item.daytime
                    AND PROFIT_CENTRE_ID = v_UPG_id;

                    IF v_UPG = 'ALL' THEN
                        IF v_count_ALL = 0 THEN
                            -- LNG Rate
                            INSERT INTO DV_CT_PROD_STRM_FORECAST(FORECAST_OBJECT_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime, LNG_HHV_STD, LNG_VOL_RATE, LNG_EXCESS_PROD, LNG_REGAS_REQ_LNG, CONFIRMED_EXCESS_QTY, LNG_HHV, LNG_MASS_RATE, LNG_DENSITY,IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY)
                            VALUES (v_forecast_id_guid, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST'), value_item.daytime, 'ADP_PLAN', v_scenario, v_effective_daytime, value_item.LNG_HHV_STD, value_item.LNG_VOL_RATE, value_item.LNG_EXCESS_PROD, value_item.LNG_REGAS_REQ_LNG, value_item.CONFIRMED_EXCESS_QTY, value_item.lng_hhv, value_item.lng_mass_Rate, value_item.LNG_DENSITY,value_item.IMBALANCE_ADJ_VOLUME,value_item.IMBALANCE_ADJ_ENERGY,value_item.UNMET_AMOUNT_VOLUME,value_item.UNMET_AMOUNT_ENERGY);
                            -- Cond Rate
                            INSERT INTO DV_CT_PROD_STRM_FORECAST(FORECAST_OBJECT_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime, COND_VOL_RATE, cond_mass_rate,COND_DENSITY)
                            VALUES (v_forecast_id_guid, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_COND_FORECAST'), value_item.daytime, 'ADP_PLAN', v_scenario, v_effective_daytime, value_item.COND_VOL_RATE, value_item.cond_mass_rate,value_item.COND_DENSITY);
                            -- DOMGAS Rate
                            INSERT INTO DV_CT_PROD_STRM_FORECAST(FORECAST_OBJECT_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime
                            ,DOMGAS_MIN_RATE_ENERGY,DOMGAS_MASS_RATE,DOMGAS_ENERGY,DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_SMPP,DOMGAS_REGAS)
                            VALUES (v_forecast_id_guid, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), value_item.daytime, 'ADP_PLAN', v_scenario, v_effective_daytime
                            ,value_item.DOMGAS_MIN_RATE_ENERGY,value_item.DOMGAS_MASS_RATE,value_item.DOMGAS_ENERGY,value_item.DOMGAS_HHV,value_item.DOMGAS_VOL_RATE,value_item.DOMGAS_SMPP,value_item.DOMGAS_REGAS
                            );
                        ELSE
                            -- LNG Rate
                            UPDATE DV_CT_PROD_STRM_FORECAST
                            SET LNG_HHV_STD = value_item.LNG_HHV_STD ,LNG_VOL_RATE = value_item.LNG_VOL_RATE, LNG_EXCESS_PROD = value_item.LNG_EXCESS_PROD, LNG_REGAS_REQ_LNG = value_item.LNG_REGAS_REQ_LNG, CONFIRMED_EXCESS_QTY = value_item.CONFIRMED_EXCESS_QTY, LNG_HHV = value_item.lng_hhv, LNG_MASS_RATE = value_item.lng_mass_Rate, FCST_CPP_ID = p_datastage_code, LNG_DENSITY = value_item.LNG_DENSITY
                            ,IMBALANCE_ADJ_VOLUME = value_item.IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY = value_item.IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME = value_item.UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY = value_item.UNMET_AMOUNT_ENERGY
                            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = value_item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');
                            -- Cond Rate
                            UPDATE DV_CT_PROD_STRM_FORECAST
                            SET COND_VOL_RATE = value_item.COND_VOL_RATE, cond_mass_rate = value_item.cond_mass_rate, FCST_CPP_ID = p_datastage_code, COND_DENSITY = value_item.COND_DENSITY
                            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = value_item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');
                            --SPECIAL CONDITION AS CP ALREADY WENT LIVE WITHOUT DOMGAS
                            -- DOMGAS Rate
                            SELECT count(*) INTO v_count_ALL
                            FROM DV_CT_PROD_STRM_FORECAST
                            WHERE FORECAST_OBJECT_CODE = v_ds_id
                            AND forecast_type = 'ADP_PLAN'
                            AND scenario = v_scenario
                            AND effective_daytime = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                            AND daytime = value_item.daytime;
                            IF v_count_ALL = 0 THEN
                                -- DOMGAS Rate
                                INSERT INTO DV_CT_PROD_STRM_FORECAST(FORECAST_OBJECT_ID, FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime, DOMGAS_MIN_RATE_ENERGY, DOMGAS_MASS_RATE,DOMGAS_ENERGY,DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_REGAS)
                                VALUES (v_forecast_id_guid, p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), value_item.daytime, 'ADP_PLAN', v_scenario, v_effective_daytime, value_item.DOMGAS_MIN_RATE_ENERGY, value_item.DOMGAS_MASS_RATE,value_item.DOMGAS_ENERGY,value_item.DOMGAS_HHV,value_item.DOMGAS_VOL_RATE,value_item.DOMGAS_REGAS);
                            ELSE
                                UPDATE DV_CT_PROD_STRM_FORECAST
                                SET FCST_CPP_ID = p_datastage_code,
                                DOMGAS_MIN_RATE_ENERGY = value_item.DOMGAS_MIN_RATE_ENERGY,
                                DOMGAS_MASS_RATE = value_item.DOMGAS_MASS_RATE,
                                DOMGAS_ENERGY = value_item.DOMGAS_ENERGY,
                                DOMGAS_HHV = value_item.DOMGAS_HHV,
                                DOMGAS_VOL_RATE = value_item.DOMGAS_VOL_RATE,
                                DOMGAS_SMPP = value_item.DOMGAS_SMPP,
                                DOMGAS_REGAS = value_item.DOMGAS_REGAS
                                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = value_item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                                AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');
                            END IF;

                        END IF;
                    ELSE
                        IF v_count_UPG = 0 THEN
                            --Specific UPG
                            -- insert to UPG CT class:CT_PROD_STRM_PC_FORECAST
                            -- LNG Rate
                            INSERT INTO DV_CT_PROD_STRM_PC_FORECAST(FORECAST_OBJECT_ID,PROFIT_CENTRE_ID,FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime, LNG_HHV_STD, LNG_VOL_RATE, LNG_EXCESS_PROD, LNG_REGAS_REQ_LNG, CONFIRMED_EXCESS_QTY, LNG_HHV, LNG_MASS_RATE, LNG_DENSITY, IMBALANCE_ADJ_VOLUME,IMBALANCE_ADJ_ENERGY,UNMET_AMOUNT_VOLUME,UNMET_AMOUNT_ENERGY)
                            VALUES (v_forecast_id_guid,v_UPG_id,p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST'), value_item.daytime, 'ADP_PLAN', v_scenario, v_effective_daytime, value_item.LNG_HHV_STD, value_item.LNG_VOL_RATE, value_item.LNG_EXCESS_PROD, value_item.LNG_REGAS_REQ_LNG, value_item.CONFIRMED_EXCESS_QTY, value_item.lng_hhv, value_item.lng_mass_Rate, value_item.LNG_DENSITY, value_item.IMBALANCE_ADJ_VOLUME, value_item.IMBALANCE_ADJ_ENERGY, value_item.UNMET_AMOUNT_VOLUME, value_item.UNMET_AMOUNT_ENERGY);
                            -- Cond Rate
                            INSERT INTO DV_CT_PROD_STRM_PC_FORECAST(FORECAST_OBJECT_ID,PROFIT_CENTRE_ID,FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime, COND_VOL_RATE, cond_mass_rate, COND_DENSITY)
                            VALUES (v_forecast_id_guid,v_UPG_id,p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_COND_FORECAST'), value_item.daytime, 'ADP_PLAN', v_scenario, v_effective_daytime, value_item.COND_VOL_RATE, value_item.cond_mass_rate, value_item.COND_DENSITY);
                            -- DOMGAS Rate
                            INSERT INTO DV_CT_PROD_STRM_PC_FORECAST(FORECAST_OBJECT_ID,PROFIT_CENTRE_ID,FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime, DOMGAS_MASS_RATE,DOMGAS_ENERGY,DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_REGAS)
                            VALUES (v_forecast_id_guid,v_UPG_id,p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), value_item.daytime, 'ADP_PLAN', v_scenario, v_effective_daytime, value_item.DOMGAS_MASS_RATE,value_item.DOMGAS_ENERGY,value_item.DOMGAS_HHV,value_item.DOMGAS_VOL_RATE,value_item.DOMGAS_REGAS);
                        ELSE
                            UPDATE DV_CT_PROD_STRM_PC_FORECAST
                            SET LNG_HHV_STD = value_item.LNG_HHV_STD, LNG_VOL_RATE = value_item.LNG_VOL_RATE, LNG_EXCESS_PROD = value_item.LNG_EXCESS_PROD, LNG_REGAS_REQ_LNG = value_item.LNG_REGAS_REQ_LNG, CONFIRMED_EXCESS_QTY = value_item.CONFIRMED_EXCESS_QTY, LNG_HHV = value_item.lng_hhv, LNG_MASS_RATE = value_item.lng_mass_Rate, FCST_CPP_ID = p_datastage_code, LNG_DENSITY = value_item.LNG_DENSITY
                            , IMBALANCE_ADJ_VOLUME = value_item.IMBALANCE_ADJ_VOLUME, IMBALANCE_ADJ_ENERGY = value_item.IMBALANCE_ADJ_ENERGY, UNMET_AMOUNT_VOLUME = value_item.UNMET_AMOUNT_VOLUME, UNMET_AMOUNT_ENERGY = value_item.UNMET_AMOUNT_ENERGY
                            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = value_item.daytime
                            AND EFFECTIVE_DAYTIME = v_effective_daytime AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');

                            UPDATE DV_CT_PROD_STRM_PC_FORECAST
                            SET COND_VOL_RATE = value_item.COND_VOL_RATE, cond_mass_rate = value_item.cond_mass_rate, FCST_CPP_ID = p_datastage_code, COND_DENSITY = value_item.COND_DENSITY
                            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = value_item.daytime
                            AND EFFECTIVE_DAYTIME =  v_effective_daytime AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');

                            --SPECIAL CONDITION AS CP ALREADY WENT LIVE WITHOUT DOMGAS
                            -- DOMGAS Rate
                            SELECT count(*) INTO v_count_ALL
                            FROM DV_CT_PROD_STRM_FORECAST
                            WHERE FORECAST_OBJECT_CODE = v_ds_id
                            AND forecast_type = 'ADP_PLAN'
                            AND scenario = v_scenario
                            AND effective_daytime = v_effective_daytime
                            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                            AND daytime = value_item.daytime;
                            IF v_count_ALL = 0 THEN
                                -- DOMGAS Rate
                                INSERT INTO DV_CT_PROD_STRM_PC_FORECAST(FORECAST_OBJECT_ID,PROFIT_CENTRE_ID,FCST_CPP_ID, object_id, daytime, forecast_type, scenario, effective_daytime, DOMGAS_MASS_RATE,DOMGAS_ENERGY,DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_REGAS)
                                VALUES (v_forecast_id_guid,v_UPG_id,p_datastage_code,  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), value_item.daytime, 'ADP_PLAN', v_scenario, v_effective_daytime, value_item.DOMGAS_MASS_RATE,value_item.DOMGAS_ENERGY,value_item.DOMGAS_HHV,value_item.DOMGAS_VOL_RATE,value_item.DOMGAS_REGAS);
                            ELSE
                                UPDATE DV_CT_PROD_STRM_PC_FORECAST
                                SET FCST_CPP_ID = p_datastage_code,
                                DOMGAS_MASS_RATE = value_item.DOMGAS_MASS_RATE,
                                DOMGAS_ENERGY = value_item.DOMGAS_ENERGY,
                                DOMGAS_HHV = value_item.DOMGAS_HHV,
                                DOMGAS_VOL_RATE = value_item.DOMGAS_VOL_RATE,
                                DOMGAS_REGAS = value_item.DOMGAS_REGAS
                                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = value_item.daytime
                                AND EFFECTIVE_DAYTIME =  v_effective_daytime AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');
                            END IF;

                        END IF;
                    END IF;
                END LOOP;
            END LOOP;
            -- Update monthly values
            FOR item IN months_in_plan(type_item.forecast_type, type_item.probability_type) LOOP
                --ALL or Total FOR DOMGAS
                SELECT sum(DOMGAS_ENERGY),sum(DOMGAS_VOL_RATE) into v_sum_dg, v_sum_dg_vol
                FROM DV_CT_PROD_STRM_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_FORECAST x
                    WHERE x.forecast_type = 'ADP_PLAN'
                    AND x.scenario = v_scenario
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = 'ADP_PLAN'
                AND scenario = v_scenario
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                --ALL or Total FOR LNG
                --sumOfMthFor(MMBTU/M3 * M3 )/sumOfMthFor(M3) --> Monthly LNG_HHV in MMBTU/M3
                SELECT sum(LNG_HHV * LNG_VOL_RATE), sum(LNG_VOL_RATE), sum(LNG_MASS_RATE) * 1000, sum(LNG_VOL_RATE) into v_avg_gcv_num, v_avg_gcv_den, v_avg_dens_num, v_avg_dens_den
                FROM DV_CT_PROD_STRM_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_FORECAST x
                    WHERE x.forecast_type = 'ADP_PLAN'
                    AND x.scenario = v_scenario
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = 'ADP_PLAN'
                AND scenario = v_scenario
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                --ALL or Total FOR COND
                SELECT sum(COND_VOL_RATE), sum(COND_MASS_RATE) * 1000 into v_sum_cond, v_avg_dens_cond_num
                FROM DV_CT_PROD_STRM_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_FORECAST x
                    WHERE x.forecast_type = 'ADP_PLAN'
                    AND x.scenario = v_scenario
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = 'ADP_PLAN'
                AND scenario = v_scenario
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                IF v_avg_gcv_den <> 0 THEN
                    v_avg_gcv := v_avg_gcv_num / v_avg_gcv_den;
                ELSE
                    v_avg_gcv := 0;
                END IF;

                IF v_avg_dens_den <> 0 THEN
                    v_avg_dens := v_avg_dens_num / v_avg_dens_den;
                ELSE
                    v_avg_dens := 0;
                END IF;

                IF v_sum_cond <> 0 THEN
                    v_avg_cond_dens := v_avg_dens_cond_num / v_sum_cond;
                ELSE
                    v_avg_cond_dens := 0;
                END IF;

                --UPG for DOMGAS
                SELECT sum(DOMGAS_ENERGY) ,sum(DOMGAS_VOL_RATE) into v_sum_dg_pc, v_sum_dg_vol_pc
                FROM DV_CT_PROD_STRM_PC_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_PC_FORECAST x
                    WHERE x.forecast_type = 'ADP_PLAN'
                    AND x.scenario = v_scenario
                    AND x.PROFIT_CENTRE_ID = v_UPG_id
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = 'ADP_PLAN'
                AND scenario = v_scenario
                AND PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                --UPG for LNG
                SELECT sum(LNG_HHV * LNG_VOL_RATE), sum(LNG_VOL_RATE), sum(LNG_MASS_RATE) * 1000, sum(LNG_VOL_RATE) into v_avg_gcv_num_pc, v_avg_gcv_den_pc, v_avg_dens_num_pc, v_avg_dens_den_pc
                FROM DV_CT_PROD_STRM_PC_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_PC_FORECAST x
                    WHERE x.forecast_type = 'ADP_PLAN'
                    AND x.scenario = v_scenario
                    AND x.PROFIT_CENTRE_ID = v_UPG_id
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = 'ADP_PLAN'
                AND scenario = v_scenario
                AND PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                --UPG for COND
                SELECT sum(COND_VOL_RATE), sum(COND_MASS_RATE) * 1000 into v_sum_cond_pc, v_avg_dens_cond_num_pc
                FROM DV_CT_PROD_STRM_PC_FORECAST
                WHERE effective_daytime =
                (
                    SELECT max(x.effective_daytime)
                    FROM DV_CT_PROD_STRM_PC_FORECAST x
                    WHERE x.forecast_type = 'ADP_PLAN'
                    AND x.scenario = v_scenario
                    AND x.PROFIT_CENTRE_ID = v_UPG_id
                    AND trunc(x.daytime, 'MON') = item.daytime
                    AND x.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                    AND x.effective_daytime <= item.daytime
                    AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
                )
                AND forecast_type = 'ADP_PLAN'
                AND scenario = v_scenario
                AND PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(daytime, 'MON') = item.daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                AND FORECAST_OBJECT_ID = v_forecast_id_guid;

                IF v_avg_gcv_den_pc <> 0 THEN
                    v_avg_gcv_pc := v_avg_gcv_num_pc / v_avg_gcv_den_pc;
                ELSE
                    v_avg_gcv_pc := 0;
                END IF;

                IF v_avg_dens_den_pc <> 0 THEN
                    v_avg_dens_pc := v_avg_dens_num_pc / v_avg_dens_den_pc;
                ELSE
                    v_avg_dens_pc := 0;
                END IF;

                IF v_sum_cond_pc <> 0 THEN
                    v_avg_cond_dens_pc := v_avg_dens_cond_num_pc / v_sum_cond_pc;
                ELSE
                    v_avg_cond_dens_pc := 0;
                END IF;

                UPDATE DV_CT_PROD_STRM_FORECAST
                SET LNG_DENSITY_MTH = ROUND(v_avg_dens,3), LNG_VOL_RATE_MTH = v_avg_dens_den, LNG_HHV_MTH = ROUND(v_avg_gcv,3)
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');

                UPDATE DV_CT_PROD_STRM_FORECAST
                SET COND_VOL_RATE_MTH = v_sum_cond, COND_DENSITY_MTH = ROUND(v_avg_cond_dens,3)
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');

                UPDATE DV_CT_PROD_STRM_FORECAST
                SET DOMGAS_ENERGY_MTH = v_sum_dg , DOMGAS_VOL_MTH_RATE = v_sum_dg_vol
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');

                UPDATE DV_CT_PROD_STRM_PC_FORECAST
                SET LNG_DENSITY_MTH = ROUND(v_avg_dens_pc,3), LNG_VOL_RATE_MTH = v_avg_dens_den_pc, LNG_HHV_MTH = ROUND(v_avg_gcv_pc,3)
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');

                UPDATE DV_CT_PROD_STRM_PC_FORECAST
                SET COND_VOL_RATE_MTH = v_sum_cond_pc, COND_DENSITY_MTH = ROUND(v_avg_cond_dens_pc,3)
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');

                UPDATE DV_CT_PROD_STRM_PC_FORECAST
                SET DOMGAS_ENERGY_MTH = v_sum_dg_pc , DOMGAS_VOL_MTH_RATE = v_sum_dg_vol_pc
                WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = 'ADP_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
                AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');

            END LOOP;
        END IF;

        v_forecast_id_guid_ADP := v_forecast_id_guid;

        IF type_item.forecast_type = 'SDS_PLAN' or type_item.forecast_type = 'ADP_PLAN' THEN

            FOR year_item IN year_starts('LIFTING', p_datastage_code, type_item.forecast_type, type_item.probability_type) LOOP
                v_effective_daytime := year_item.daytime;
            END LOOP;
            v_fcst_scen_no := -1;
            v_forecast_id_guid := NULL;
            FOR item IN sds_scenarios(v_scenario) LOOP
                v_fcst_scen_no := item.fcst_scen_no;
                v_forecast_id_guid := item.object_id;
            END LOOP;
            IF v_fcst_scen_no = -1 THEN
                v_seq :=  1 ;
                --v_sds_id:= 'SDS_'|| v_scenario || '_' || TO_CHAR(v_seq)|| '_' || to_char(TRUNC(v_effective_daytime,'YEAR'),'YYYY')  ;
                --assign FCST_DS_ID:  [ADP/SDS]_[RP,HC,MC,LC]_[DS Code]_[YYYY]_[VERSION]
                SELECT DECODE(TRIM(v_scenario), 'HIGH_CONF', 'HC', 'MED_CONF', 'MC', 'LOW_CONF','LC','REF_PROD','RP') INTO v_temp_scenario FROM DUAL;
                v_sds_id:= 'SDS_'|| v_temp_scenario || '_' || 'BASED'    ;
                SELECT DECODE(TRIM(v_scenario), 'HIGH_CONF', 'High Conf', 'MED_CONF', 'Med Conf', 'LOW_CONF','Low Conf','REF_PROD','Ref Prod') INTO v_temp_scenario FROM DUAL;
                v_ds_name:= 'SDS '|| v_temp_scenario || ' ' || 'BASED'   ;

                EcDp_System_Key.assignNextNumber('CT_PROD_FORECAST', v_fcst_scen_no);

                INSERT INTO OV_CT_PROD_FORECAST (CODE, NAME, fcst_scen_no, forecast_type, scenario, DAYTIME, FCST_CPP_ID)
                VALUES (v_sds_id,v_ds_name,v_fcst_scen_no, 'SDS_PLAN', v_scenario, v_effective_daytime, p_datastage_code);

                v_forecast_id_guid := ECDP_OBJECTS.GETOBJIDFROMCODE('CT_PROD_FORECAST',v_sds_id);

            END IF;

            v_effective_daytime := ec_CT_prod_forecast.START_DATE(v_forecast_id_guid);

            --TLXT: 08-JUL-2015: CP - Interface - CPP data load - New column to keep the DATA_STAGE_CODE
            UPDATE OV_CT_PROD_FORECAST SET FCST_CPP_ID = p_datastage_code, LAST_UPDATED_DATE = SYSDATE WHERE  OBJECT_ID = v_forecast_id_guid;
            --END EDIT

            -- Get the PROFIT_CENTRE_CODE
            SELECT DECODE(TRIM(type_item.PROFIT_CENTRE_CODE), 'F_WST_IAGO', 'F_WST_IAGO', 'F_JUL_BRU', 'F_JUL_BRU','ALL','ALL','UNKNOWN') INTO v_UPG FROM DUAL;
            IF (v_UPG = 'UNKNOWN') THEN
                RAISE_APPLICATION_ERROR(-20998, 'Message UPG Code type must be "F_WST_IAGO" or "F_JUL_BRU" or "ALL" ');
            END IF;
            v_UPG_id := ECDP_OBJECTS.GETOBJIDFROMCODE('FIELD',v_UPG);
                IF v_UPG = 'ALL' THEN
                    -- Merge LNG data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(LNG_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_FORECAST','LNG_MASS_SMPP')), DAYTIME) as LNG_MASS_SMPP,
                        EcDp_Unit.ConvertValue(LNG_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_VOL_RATE')), DAYTIME) as LNG_VOL_RATE,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD')), DAYTIME) as LNG_EXCESS_PROD,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_LNG, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_LNG')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_LNG')), DAYTIME) as LNG_REGAS_REQ_LNG,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_QTY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_QTY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_QTY')), DAYTIME) as CONFIRMED_EXCESS_QTY,
                        EcDp_Unit.ConvertValue(LNG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV')), DAYTIME) as LNG_HHV,
                        EcDp_Unit.ConvertValue(LNG_HHV_GJSM3, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV_GJSM3')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV_STD')), DAYTIME) as LNG_HHV_STD,
                        EcDp_Unit.ConvertValue(LNG_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_RATE')), DAYTIME) as LNG_MASS_RATE,
                        EcDp_Unit.ConvertValue(LNG_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_DENSITY')), DAYTIME) as LNG_DENSITY,
                        EcDp_Unit.ConvertValue(IMBALANCE_ADJ_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_VOLUME')), DAYTIME) as IMBALANCE_ADJ_VOLUME,
                        EcDp_Unit.ConvertValue(IMBALANCE_ADJ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_ENERGY')), DAYTIME) as IMBALANCE_ADJ_ENERGY,
                        EcDp_Unit.ConvertValue(UNMET_AMOUNT_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_VOLUME')), DAYTIME) as UNMET_AMOUNT_VOLUME,
                        EcDp_Unit.ConvertValue(UNMET_AMOUNT_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_ENERGY')), DAYTIME) as UNMET_AMOUNT_ENERGY
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code= p_datastage_code
                        AND forecast_type    = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG              = 'ALL'
                        AND (LNG_MASS_SMPP IS NOT NULL OR LNG_RATE IS NOT NULL OR LNG_HHV IS NOT NULL OR LNG_MASS_RATE IS NOT NULL OR LNG_EXCESS_PROD IS NOT NULL OR LNG_REGAS_REQ_LNG IS NOT NULL OR CONFIRMED_EXCESS_QTY IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id          = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                        AND fcast.FORECAST_TYPE  = 'SDS_PLAN'
                        AND fcast.SCENARIO       = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime        = stage.daytime
                        AND fcast.TEXT_10        = 'BASED'
                        AND fcast.REF_OBJECT_ID_1= v_forecast_id_guid
                    )
                    WHEN MATCHED THEN
                        UPDATE SET
                                fcast.LNG_MASS_SMPP       = stage.LNG_MASS_SMPP,
                                fcast.value_43               = stage.LNG_VOL_RATE,
                                fcast.LNG_EXCESS_PROD     = stage.LNG_EXCESS_PROD,
                                fcast.LNG_REGAS_REQ       = stage.LNG_REGAS_REQ_LNG,
                                fcast.CONFIRMED_EXCESS_QTY= stage.CONFIRMED_EXCESS_QTY,
                                fcast.value_42            = stage.lng_hhv,
                                fcast.value_46            = stage.LNG_HHV_STD,
                                fcast.value_41            = stage.lng_mass_rate,
                                fcast.value_36            = stage.LNG_DENSITY,
                                fcast.LNG_NGI_ADJUST_VOL      = stage.IMBALANCE_ADJ_VOLUME,
                                fcast.LNG_NGI_ADJUST_ENERGY = stage.IMBALANCE_ADJ_ENERGY,
                                fcast.LNG_UNMET_AMT_VOL     = stage.UNMET_AMOUNT_VOLUME,
                                fcast.LNG_UNMET_AMT_ENERGY  = stage.UNMET_AMOUNT_ENERGY
                    WHEN NOT MATCHED THEN
                        -- LNG Rate
                        INSERT (REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime, LNG_MASS_SMPP, VALUE_43,LNG_EXCESS_PROD, LNG_REGAS_REQ, CONFIRMED_EXCESS_QTY, VALUE_42,value_46,VALUE_41, VALUE_36, LNG_NGI_ADJUST_VOL, LNG_NGI_ADJUST_ENERGY, LNG_UNMET_AMT_VOL, LNG_UNMET_AMT_ENERGY)
                        VALUES (v_forecast_id_guid, 'BASED',  ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST'), stage.daytime, 'SDS_PLAN', v_scenario, v_effective_daytime, stage.LNG_MASS_SMPP, stage.LNG_VOL_RATE,stage.LNG_EXCESS_PROD, stage.LNG_REGAS_REQ_LNG, stage.CONFIRMED_EXCESS_QTY, stage.lng_hhv,stage.LNG_HHV_STD,stage.lng_mass_rate,stage.LNG_DENSITY, stage.IMBALANCE_ADJ_VOLUME, stage.IMBALANCE_ADJ_ENERGY, stage.UNMET_AMOUNT_VOLUME, stage.UNMET_AMOUNT_ENERGY);

                    -- Merge COND data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(COND_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_FORECAST','COND_MASS_SMPP')), DAYTIME) as COND_MASS_SMPP,
                        EcDp_Unit.ConvertValue(COND_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_VOL_RATE')), DAYTIME) as COND_VOL_RATE,
                        EcDp_Unit.ConvertValue(COND_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_DENSITY')), DAYTIME) as COND_DENSITY,
                        EcDp_Unit.ConvertValue(COND_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_RATE')), DAYTIME) as COND_MASS_RATE
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = 'ALL'
                        AND (COND_MASS_SMPP IS NOT NULL OR COND_RATE IS NOT NULL OR COND_DENSITY IS NOT NULL OR COND_MASS_RATE IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                        AND fcast.FORECAST_TYPE = 'SDS_PLAN'
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.COND_MASS_SMPP = stage.COND_MASS_SMPP,
                                   fcast.COND_RATE = stage.COND_VOL_RATE,
                                   fcast.COND_MASS_RATE = stage.COND_MASS_RATE,
                                   fcast.VALUE_30 = stage.COND_DENSITY
                    WHEN NOT MATCHED THEN
                        -- COND Rate
                        INSERT (REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime, COND_MASS_SMPP, COND_RATE, COND_MASS_RATE,VALUE_30)
                        VALUES (v_forecast_id_guid, 'BASED',  ec_stream.object_id_by_uk('SW_GP_COND_FORECAST'), stage.daytime, 'SDS_PLAN', v_scenario, v_effective_daytime, stage.COND_MASS_SMPP, stage.COND_VOL_RATE, stage.COND_MASS_RATE,stage.COND_DENSITY);

                    -- Merge DOMGAS data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        DOMGAS_MIN_RATE_ENERGY,
                        EcDp_Unit.ConvertValue(DOMGAS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_FORECAST','DOMGAS_SMPP')), DAYTIME) as DOMGAS_SMPP,
                        EcDp_Unit.ConvertValue(DOMGAS_MASS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MASS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MASS_RATE')), DAYTIME) as DOMGAS_MASS,
                        EcDp_Unit.ConvertValue(DOMGAS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_ENERGY')), DAYTIME) as DOMGAS_ENERGY,
                        EcDp_Unit.ConvertValue(DOMGAS_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_HHV')), DAYTIME) as DOMGAS_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL_RATE')), DAYTIME) as DOMGAS_VOL_RATE,
                        DOMGAS_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_VOLUME')), DAYTIME) as DOMGAS_GU_FACTOR_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_ENERGY')), DAYTIME) as DOMGAS_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(REF_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_VOLUME')), DAYTIME) as REF_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_STD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_STD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_STD_VOLUME')), DAYTIME) as REF_PROD_STD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_ENERGY')), DAYTIME) as REF_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(DG_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DG_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DG_NG_HHV')), DAYTIME) as DG_NG_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_REGAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_REGAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_REGAS')), DAYTIME) as DOMGAS_REGAS
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = 'ALL'
                        AND (DOMGAS_SMPP IS NOT NULL OR DOMGAS_MASS IS NOT NULL OR DOMGAS_ENERGY IS NOT NULL OR DOMGAS_HHV IS NOT NULL OR DOMGAS_VOLUME IS NOT NULL OR DOMGAS_REGAS IS NOT NULL )
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                        AND fcast.FORECAST_TYPE = 'SDS_PLAN'
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                    )
                    WHEN MATCHED THEN
                        UPDATE SET  fcast.DOMGAS_MIN_RATE_ENERGY = stage.DOMGAS_MIN_RATE_ENERGY,
                                    fcast.DOMGAS_SMPP = stage.DOMGAS_SMPP,
                                    fcast.VALUE_39 = stage.DOMGAS_MASS,
                                    fcast.VALUE_44 = stage.DOMGAS_ENERGY,
                                    fcast.DOMGAS_HHV = stage.DOMGAS_HHV,
                                    fcast.DOMGAS_VOL_RATE = stage.DOMGAS_VOL_RATE,
                                    fcast.DOMGAS_REGAS = stage.DOMGAS_REGAS
                    WHEN NOT MATCHED THEN
                        -- DOMGAS Rate
                        INSERT (REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime
                        , VALUE_39, VALUE_44,DOMGAS_SMPP
                        ,DOMGAS_MIN_RATE_ENERGY, DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_REGAS)
                        VALUES (v_forecast_id_guid, 'BASED',  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), stage.daytime, 'SDS_PLAN', v_scenario, v_effective_daytime
                        ,stage.DOMGAS_MASS, stage.DOMGAS_ENERGY,stage.DOMGAS_SMPP
                        ,stage.DOMGAS_MIN_RATE_ENERGY,stage.DOMGAS_HHV,stage.DOMGAS_VOL_RATE,stage.DOMGAS_REGAS
                        );

                    -- Merge platform data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(PLATFORM_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','PLATFORM_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','PLATFORM_MASS_SMPP')), DAYTIME) as PLATFORM_MASS_SMPP,
                        WPT_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_VOLUME')), DAYTIME) as WPT_GU_FACTOR_VOLUME,
                        WPT_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_ENERGY')), DAYTIME) as WPT_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_N2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_N2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_N2')), DAYTIME) as FORECAST_FEED_N2,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_CO2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_CO2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_CO2')), DAYTIME) as FORECAST_FEED_CO2,
                        EcDp_Unit.ConvertValue(WPT_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_NG_HHV')), DAYTIME) as WPT_NG_HHV
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = 'ALL'
                        AND (PLATFORM_MASS_SMPP IS NOT NULL OR WPT_GU_FACTOR_VOLUME IS NOT NULL OR WPT_GU_FACTOR_ENERGY IS NOT NULL OR FORECAST_FEED_N2 IS NOT NULL OR FORECAST_FEED_CO2 IS NOT NULL OR WPT_NG_HHV IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_PL_NG_FORECAST')
                        AND fcast.FORECAST_TYPE = 'SDS_PLAN'
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.PLATFORM_MASS_SMPP = stage.PLATFORM_MASS_SMPP,
                                    fcast.WPT_GU_FACTOR_VOLUME = stage.WPT_GU_FACTOR_VOLUME,
                                    fcast.WPT_GU_FACTOR_ENERGY = stage.WPT_GU_FACTOR_ENERGY,
                                    fcast.FORECAST_FEED_N2 = stage.FORECAST_FEED_N2,
                                    fcast.FORECAST_FEED_CO2 = stage.FORECAST_FEED_CO2,
                                    fcast.WPT_NG_HHV = stage.WPT_NG_HHV
                    WHEN NOT MATCHED THEN
                        -- NG Rate
                        INSERT (REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime
                        , PLATFORM_MASS_SMPP, WPT_GU_FACTOR_VOLUME,WPT_GU_FACTOR_ENERGY
                        ,FORECAST_FEED_N2,FORECAST_FEED_CO2,WPT_NG_HHV)
                        VALUES (v_forecast_id_guid, 'BASED',  ec_stream.object_id_by_uk('SW_PL_NG_FORECAST'), stage.daytime, 'SDS_PLAN', v_scenario, v_effective_daytime
                        ,stage.PLATFORM_MASS_SMPP, stage.WPT_GU_FACTOR_VOLUME, stage.WPT_GU_FACTOR_ENERGY
                        ,stage.FORECAST_FEED_N2,stage.FORECAST_FEED_CO2,stage.WPT_NG_HHV
                        );

                ELSE
                --OTHER UPG
                -- Merge LNG data into stream forecast BASE TABLE BY PC:
                    MERGE INTO CT_PROD_STRM_PC_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(LNG_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_SMPP')), DAYTIME) as LNG_MASS_SMPP,
                        EcDp_Unit.ConvertValue(LNG_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_VOL_RATE')), DAYTIME) as LNG_VOL_RATE,
                        EcDp_Unit.ConvertValue(LNG_EXCESS_PROD, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_EXCESS_PROD')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_EXCESS_PROD')), DAYTIME) as LNG_EXCESS_PROD,
                        EcDp_Unit.ConvertValue(LNG_REGAS_REQ_LNG, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_REGAS_REQ_LNG')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_REGAS_REQ_LNG')), DAYTIME) as LNG_REGAS_REQ_LNG,
                        EcDp_Unit.ConvertValue(CONFIRMED_EXCESS_QTY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','CONFIRMED_EXCESS_QTY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','CONFIRMED_EXCESS_QTY')), DAYTIME) as CONFIRMED_EXCESS_QTY,
                        EcDp_Unit.ConvertValue(LNG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV')), DAYTIME) as LNG_HHV,
                        EcDp_Unit.ConvertValue(LNG_HHV_GJSM3, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_HHV_GJSM3')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_HHV_STD')), DAYTIME) as LNG_HHV_STD,
                        EcDp_Unit.ConvertValue(LNG_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_MASS_RATE')), DAYTIME) as LNG_MASS_RATE,
                        EcDp_Unit.ConvertValue(LNG_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','LNG_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','LNG_DENSITY')), DAYTIME) as LNG_DENSITY,
                        EcDp_Unit.ConvertValue(IMBALANCE_ADJ_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_VOLUME')), DAYTIME) as IMBALANCE_ADJ_VOLUME,
                        EcDp_Unit.ConvertValue(IMBALANCE_ADJ_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','IMBALANCE_ADJ_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','IMBALANCE_ADJ_ENERGY')), DAYTIME) as IMBALANCE_ADJ_ENERGY,
                        EcDp_Unit.ConvertValue(UNMET_AMOUNT_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_VOLUME')), DAYTIME) as UNMET_AMOUNT_VOLUME,
                        EcDp_Unit.ConvertValue(UNMET_AMOUNT_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','UNMET_AMOUNT_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','UNMET_AMOUNT_ENERGY')), DAYTIME) as UNMET_AMOUNT_ENERGY
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = type_item.PROFIT_CENTRE_CODE
                        AND (LNG_MASS_SMPP IS NOT NULL OR LNG_RATE IS NOT NULL OR LNG_HHV IS NOT NULL OR LNG_MASS_RATE IS NOT NULL OR LNG_EXCESS_PROD IS NOT NULL OR LNG_REGAS_REQ_LNG IS NOT NULL OR CONFIRMED_EXCESS_QTY IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                        AND fcast.FORECAST_TYPE = 'SDS_PLAN'
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                        AND fcast.PROFIT_CENTRE_ID = v_UPG_id
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.LNG_MASS_SMPP = stage.LNG_MASS_SMPP,
                                   fcast.value_43 = stage.LNG_VOL_RATE,
                                   fcast.LNG_EXCESS_PROD = stage.LNG_EXCESS_PROD,
                                   fcast.LNG_REGAS_REQ       = stage.LNG_REGAS_REQ_LNG,
                                   fcast.CONFIRMED_EXCESS_QTY= stage.CONFIRMED_EXCESS_QTY,
                                   fcast.value_42 = stage.lng_hhv,
                                   fcast.value_46 = stage.LNG_HHV_STD,
                                   fcast.value_41 = stage.lng_mass_rate,
                                   fcast.value_36 = stage.LNG_DENSITY,
                                    fcast.LNG_NGI_ADJUST_VOL      = stage.IMBALANCE_ADJ_VOLUME,
                                    fcast.LNG_NGI_ADJUST_ENERGY = stage.IMBALANCE_ADJ_ENERGY,
                                    fcast.LNG_UNMET_AMT_VOL     = stage.UNMET_AMOUNT_VOLUME,
                                    fcast.LNG_UNMET_AMT_ENERGY  = stage.UNMET_AMOUNT_ENERGY
                    WHEN NOT MATCHED THEN
                        -- LNG Rate
                        INSERT (PROFIT_CENTRE_ID,REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime,LNG_MASS_SMPP,  VALUE_43,LNG_EXCESS_PROD, LNG_REGAS_REQ, CONFIRMED_EXCESS_QTY, VALUE_42,value_46,VALUE_41, VALUE_36, LNG_NGI_ADJUST_VOL,LNG_NGI_ADJUST_ENERGY,LNG_UNMET_AMT_VOL,LNG_UNMET_AMT_ENERGY)
                        VALUES (v_UPG_id,v_forecast_id_guid, 'BASED',  ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST'), stage.daytime, 'SDS_PLAN', v_scenario, v_effective_daytime, stage.LNG_MASS_SMPP, stage.LNG_VOL_RATE,stage.LNG_EXCESS_PROD, stage.LNG_REGAS_REQ_LNG, stage.CONFIRMED_EXCESS_QTY, stage.lng_hhv,stage.LNG_HHV_STD,stage.lng_mass_rate,stage.LNG_DENSITY, stage.IMBALANCE_ADJ_VOLUME, stage.IMBALANCE_ADJ_ENERGY, stage.UNMET_AMOUNT_VOLUME, stage.UNMET_AMOUNT_ENERGY);

                    -- Merge COND data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_PC_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(COND_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_SMPP')), DAYTIME) as COND_MASS_SMPP,
                        EcDp_Unit.ConvertValue(COND_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_VOL_RATE')), DAYTIME) as COND_VOL_RATE,
                        EcDp_Unit.ConvertValue(COND_DENSITY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_DENSITY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_DENSITY')), DAYTIME) as COND_DENSITY,
                        EcDp_Unit.ConvertValue(COND_MASS_RATE, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','COND_MASS_RATE')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','COND_MASS_RATE')), DAYTIME) as COND_MASS_RATE
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = type_item.PROFIT_CENTRE_CODE
                        AND (COND_MASS_SMPP IS NOT NULL OR COND_RATE IS NOT NULL OR COND_DENSITY IS NOT NULL OR COND_MASS_RATE IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                        AND fcast.FORECAST_TYPE = 'SDS_PLAN'
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                        AND fcast.PROFIT_CENTRE_ID = v_UPG_id
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.COND_MASS_SMPP = stage.COND_MASS_SMPP,
                                   fcast.COND_RATE = stage.COND_VOL_RATE,
                                   fcast.COND_MASS_RATE = stage.COND_MASS_RATE,
                                   fcast.VALUE_30 = stage.COND_DENSITY
                    WHEN NOT MATCHED THEN
                        -- COND Rate
                        INSERT (PROFIT_CENTRE_ID,REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime,COND_MASS_SMPP, COND_RATE, COND_MASS_RATE,VALUE_30)
                        VALUES (v_UPG_id,v_forecast_id_guid, 'BASED',  ec_stream.object_id_by_uk('SW_GP_COND_FORECAST'), stage.daytime, 'SDS_PLAN', v_scenario, v_effective_daytime, stage.COND_MASS_SMPP, stage.COND_VOL_RATE, stage.COND_MASS_RATE,stage.COND_DENSITY);

                    -- Merge DOMGAS data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_PC_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(DOMGAS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_SMPP')), DAYTIME) as DOMGAS_SMPP,
                        EcDp_Unit.ConvertValue(DOMGAS_MASS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_MASS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_MASS_RATE')), DAYTIME) as DOMGAS_MASS,
                        EcDp_Unit.ConvertValue(DOMGAS_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_ENERGY')), DAYTIME) as DOMGAS_ENERGY,
                        EcDp_Unit.ConvertValue(DOMGAS_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_HHV')), DAYTIME) as DOMGAS_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_VOL_RATE')), DAYTIME) as DOMGAS_VOL_RATE,
                        DOMGAS_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_VOLUME')), DAYTIME) as DOMGAS_GU_FACTOR_VOLUME,
                        DOMGAS_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(DOMGAS_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_GU_FACTOR_ENERGY')), DAYTIME) as DOMGAS_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(REF_PROD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_VOLUME')), DAYTIME) as REF_PROD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_STD_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_STD_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_STD_VOLUME')), DAYTIME) as REF_PROD_STD_VOLUME,
                        EcDp_Unit.ConvertValue(REF_PROD_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','REF_PROD_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','REF_PROD_ENERGY')), DAYTIME) as REF_PROD_ENERGY,
                        EcDp_Unit.ConvertValue(DG_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DG_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DG_NG_HHV')), DAYTIME) as DG_NG_HHV,
                        EcDp_Unit.ConvertValue(DOMGAS_REGAS, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','DOMGAS_REGAS')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','DOMGAS_REGAS')), DAYTIME) as DOMGAS_REGAS
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = type_item.PROFIT_CENTRE_CODE
                        AND (DOMGAS_ENERGY IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                        AND fcast.FORECAST_TYPE = 'SDS_PLAN'
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                        AND fcast.PROFIT_CENTRE_ID = v_UPG_id
                    )
                    WHEN MATCHED THEN
                        UPDATE SET     fcast.DOMGAS_SMPP = stage.DOMGAS_SMPP,
                                    fcast.VALUE_39 = stage.DOMGAS_MASS,
                                    fcast.VALUE_44 = stage.DOMGAS_ENERGY,
                                    fcast.DOMGAS_HHV = stage.DOMGAS_HHV,
                                    fcast.DOMGAS_VOL_RATE = stage.DOMGAS_VOL_RATE,
                                    fcast.DOMGAS_REGAS = stage.DOMGAS_REGAS
                    WHEN NOT MATCHED THEN
                        -- DOMGAS Rate
                        INSERT (PROFIT_CENTRE_ID, REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime
                        , VALUE_39, VALUE_44, DOMGAS_SMPP
                        , DOMGAS_HHV,DOMGAS_VOL_RATE,DOMGAS_REGAS)
                        VALUES (v_UPG_id,v_forecast_id_guid, 'BASED',  ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST'), stage.daytime, 'SDS_PLAN', v_scenario, v_effective_daytime
                        ,stage.DOMGAS_MASS, stage.DOMGAS_ENERGY, stage.DOMGAS_SMPP
                        ,stage.DOMGAS_HHV,stage.DOMGAS_VOL_RATE,stage.DOMGAS_REGAS
                        );

                    -- Merge platform data into stream forecast BASE TABLE:
                    MERGE INTO CT_PROD_STRM_PC_FORECAST fcast
                    USING
                    (
                        SELECT daytime, forecast_type, probability_type,UPG,DATA_STAGE_CODE,
                        EcDp_Unit.ConvertValue(PLATFORM_MASS_SMPP, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','PLATFORM_MASS_SMPP')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','PLATFORM_MASS_SMPP')), DAYTIME) as PLATFORM_MASS_SMPP,
                        WPT_GU_FACTOR_VOLUME,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_VOLUME, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_VOLUME')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_VOLUME')), DAYTIME) as WPT_GU_FACTOR_VOLUME,
                        WPT_GU_FACTOR_ENERGY,--EcDp_Unit.ConvertValue(WPT_GU_FACTOR_ENERGY, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_GU_FACTOR_ENERGY')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_GU_FACTOR_ENERGY')), DAYTIME) as WPT_GU_FACTOR_ENERGY,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_N2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_N2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_N2')), DAYTIME) as FORECAST_FEED_N2,
                        EcDp_Unit.ConvertValue(FORECAST_FEED_CO2, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','FORECAST_FEED_CO2')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','FORECAST_FEED_CO2')), DAYTIME) as FORECAST_FEED_CO2,
                        EcDp_Unit.ConvertValue(WPT_NG_HHV, EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_STAGE_PROD_PC_FCST','WPT_NG_HHV')), EcDp_Unit.GetUnitFromLogical(ecdp_classmeta_cnfg.getUomCode('CT_PROD_STRM_PC_FORECAST','WPT_NG_HHV')), DAYTIME) as WPT_NG_HHV
                        FROM TV_CT_STAGE_PROD_PC_FCST
                        WHERE data_stage_code = p_datastage_code
                        AND forecast_type = type_item.forecast_type
                        AND probability_type = type_item.probability_type
                        AND UPG = type_item.PROFIT_CENTRE_CODE
                        AND (PLATFORM_MASS_SMPP IS NOT NULL OR WPT_GU_FACTOR_VOLUME IS NOT NULL OR WPT_GU_FACTOR_ENERGY IS NOT NULL OR FORECAST_FEED_N2 IS NOT NULL OR FORECAST_FEED_CO2 IS NOT NULL OR WPT_NG_HHV IS NOT NULL)
                    ) stage
                    ON
                    (
                        fcast.object_id = ec_stream.object_id_by_uk('SW_PL_NG_FORECAST')
                        AND fcast.FORECAST_TYPE = 'SDS_PLAN'
                        AND fcast.SCENARIO = DECODE(stage.probability_type,'R','REF_PROD','H','HIGH_CONF','M','MED_CONF','L','LOW_CONF')
                        AND fcast.daytime = stage.daytime
                        AND fcast.TEXT_10 = 'BASED'
                        AND fcast.REF_OBJECT_ID_1 = v_forecast_id_guid
                        AND fcast.PROFIT_CENTRE_ID = v_UPG_id
                    )
                    WHEN MATCHED THEN
                        UPDATE SET fcast.PLATFORM_MASS_SMPP = stage.PLATFORM_MASS_SMPP,
                                    fcast.WPT_GU_FACTOR_VOLUME = stage.WPT_GU_FACTOR_VOLUME,
                                    fcast.WPT_GU_FACTOR_ENERGY = stage.WPT_GU_FACTOR_ENERGY,
                                    fcast.FORECAST_FEED_N2 = stage.FORECAST_FEED_N2,
                                    fcast.FORECAST_FEED_CO2 = stage.FORECAST_FEED_CO2,
                                    fcast.WPT_NG_HHV = stage.WPT_NG_HHV
                    WHEN NOT MATCHED THEN
                        -- NG Rate
                        INSERT (PROFIT_CENTRE_ID,REF_OBJECT_ID_1, TEXT_10, object_id, daytime, forecast_type, scenario, effective_daytime
                        , PLATFORM_MASS_SMPP, WPT_GU_FACTOR_VOLUME,WPT_GU_FACTOR_ENERGY
                        ,FORECAST_FEED_N2,FORECAST_FEED_CO2,WPT_NG_HHV)
                        VALUES (v_UPG_id, v_forecast_id_guid, 'BASED',  ec_stream.object_id_by_uk('SW_PL_NG_FORECAST'), stage.daytime, 'SDS_PLAN', v_scenario, v_effective_daytime
                        ,stage.PLATFORM_MASS_SMPP, stage.WPT_GU_FACTOR_VOLUME, stage.WPT_GU_FACTOR_ENERGY
                        ,stage.FORECAST_FEED_N2,stage.FORECAST_FEED_CO2,stage.WPT_NG_HHV
                        );
                END IF;
        COMMIT;
        -- Update monthly values
        FOR item IN months_in_plan(type_item.forecast_type, type_item.probability_type) LOOP
--ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE','item.daytime='||item.daytime);
            --ALL or Total FOR DOMGAS
            SELECT sum(DOMGAS_ENERGY) ,sum(DOMGAS_VOL_RATE)into v_sum_dg,  v_sum_dg_vol
            FROM DV_CT_PROD_STRM_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_FORECAST x
                WHERE x.forecast_type = 'SDS_PLAN'
                AND x.scenario = v_scenario
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = 'SDS_PLAN'
            AND scenario = v_scenario
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;

            --ALL or Total FOR LNG
            --sumOfMthFor(MMBTU/M3 * M3 )/sumOfMthFor(M3) --> Monthly LNG_HHV in MMBTU/M3
            SELECT sum(LNG_HHV * LNG_VOL_RATE), sum(LNG_VOL_RATE), sum(LNG_MASS_RATE) * 1000, sum(LNG_VOL_RATE) into v_avg_gcv_num, v_avg_gcv_den, v_avg_dens_num, v_avg_dens_den
            FROM DV_CT_PROD_STRM_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_FORECAST x
                WHERE x.forecast_type = 'SDS_PLAN'
                AND x.scenario = v_scenario
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = 'SDS_PLAN'
            AND scenario = v_scenario
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;

            --ALL or Total FOR COND
            SELECT sum(COND_VOL_RATE), sum(COND_MASS_RATE) * 1000 into v_sum_cond, v_avg_dens_cond_num
            FROM DV_CT_PROD_STRM_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_FORECAST x
                WHERE x.forecast_type = 'SDS_PLAN'
                AND x.scenario = v_scenario
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = 'SDS_PLAN'
            AND scenario = v_scenario
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;

            IF v_avg_gcv_den <> 0 THEN
                v_avg_gcv := v_avg_gcv_num / v_avg_gcv_den;
            ELSE
                v_avg_gcv := 0;
            END IF;

            IF v_avg_dens_den <> 0 THEN
                v_avg_dens := v_avg_dens_num / v_avg_dens_den;
            ELSE
                v_avg_dens := 0;
            END IF;

            IF v_sum_cond <> 0 THEN
                v_avg_cond_dens := v_avg_dens_cond_num / v_sum_cond;
            ELSE
                v_avg_cond_dens := 0;
            END IF;

            --UPG for DOMGAS
            SELECT sum(DOMGAS_ENERGY),sum(DOMGAS_VOL_RATE) into v_sum_dg_pc, v_sum_dg_vol_pc
            FROM DV_CT_PROD_STRM_PC_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_PC_FORECAST x
                WHERE x.forecast_type = 'SDS_PLAN'
                AND x.scenario = v_scenario
                AND x.PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = 'SDS_PLAN'
            AND scenario = v_scenario
            AND PROFIT_CENTRE_ID = v_UPG_id
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;

            --UPG for LNG
            SELECT sum(LNG_HHV * LNG_VOL_RATE), sum(LNG_VOL_RATE), sum(LNG_MASS_RATE) * 1000, sum(LNG_VOL_RATE) into v_avg_gcv_num_pc, v_avg_gcv_den_pc, v_avg_dens_num_pc, v_avg_dens_den_pc
            FROM DV_CT_PROD_STRM_PC_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_PC_FORECAST x
                WHERE x.forecast_type = 'SDS_PLAN'
                AND x.scenario = v_scenario
                AND x.PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = 'SDS_PLAN'
            AND scenario = v_scenario
            AND PROFIT_CENTRE_ID = v_UPG_id
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;

            --UPG for COND
            SELECT sum(COND_VOL_RATE), sum(COND_MASS_RATE) * 1000 into v_sum_cond_pc, v_avg_dens_cond_num_pc
            FROM DV_CT_PROD_STRM_PC_FORECAST
            WHERE effective_daytime =
            (
                SELECT max(x.effective_daytime)
                FROM DV_CT_PROD_STRM_PC_FORECAST x
                WHERE x.forecast_type = 'SDS_PLAN'
                AND x.scenario = v_scenario
                AND x.PROFIT_CENTRE_ID = v_UPG_id
                AND trunc(x.daytime, 'MON') = item.daytime
                AND x.object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
                AND x.effective_daytime <= item.daytime
                AND x.FORECAST_OBJECT_ID = v_forecast_id_guid
            )
            AND forecast_type = 'SDS_PLAN'
            AND scenario = v_scenario
            AND PROFIT_CENTRE_ID = v_UPG_id
            AND trunc(daytime, 'MON') = item.daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST')
            AND FORECAST_OBJECT_ID = v_forecast_id_guid;

            IF v_avg_gcv_den_pc <> 0 THEN
                v_avg_gcv_pc := v_avg_gcv_num_pc / v_avg_gcv_den_pc;
            ELSE
                v_avg_gcv_pc := 0;
            END IF;

            IF v_avg_dens_den_pc <> 0 THEN
                v_avg_dens_pc := v_avg_dens_num_pc / v_avg_dens_den_pc;
            ELSE
                v_avg_dens_pc := 0;
            END IF;

            IF v_sum_cond_pc <> 0 THEN
                v_avg_cond_dens_pc := v_avg_dens_cond_num_pc / v_sum_cond_pc;
            ELSE
                v_avg_cond_dens_pc := 0;
            END IF;

            UPDATE DV_CT_PROD_STRM_FORECAST
            SET LNG_DENSITY_MTH = ROUND(v_avg_dens,3), LNG_VOL_RATE_MTH = v_avg_dens_den, LNG_HHV_MTH = ROUND(v_avg_gcv,3)
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = 'SDS_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');

            UPDATE DV_CT_PROD_STRM_FORECAST
            SET COND_VOL_RATE_MTH = v_sum_cond, COND_DENSITY_MTH = ROUND(v_avg_cond_dens,3)
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = 'SDS_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');

            UPDATE DV_CT_PROD_STRM_FORECAST
            SET DOMGAS_ENERGY_MTH = v_sum_dg , DOMGAS_VOL_MTH_RATE = v_sum_dg_vol
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND forecast_type = 'SDS_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');

            UPDATE DV_CT_PROD_STRM_PC_FORECAST
            SET LNG_DENSITY_MTH = ROUND(v_avg_dens_pc,3), LNG_VOL_RATE_MTH = v_avg_dens_den_pc, LNG_HHV_MTH = ROUND(v_avg_gcv_pc,3)
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = 'SDS_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_LNG_FORECAST');

            UPDATE DV_CT_PROD_STRM_PC_FORECAST
            SET COND_VOL_RATE_MTH = v_sum_cond_pc, COND_DENSITY_MTH = ROUND(v_avg_cond_dens_pc,3)
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = 'SDS_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_COND_FORECAST');

            UPDATE DV_CT_PROD_STRM_PC_FORECAST
            SET DOMGAS_ENERGY_MTH = v_sum_dg_pc, DOMGAS_VOL_MTH_RATE = v_sum_dg_vol_pc
            WHERE FORECAST_OBJECT_ID = v_forecast_id_guid AND  PROFIT_CENTRE_ID = v_UPG_id AND forecast_type = 'SDS_PLAN' AND scenario = v_scenario AND daytime = item.daytime AND EFFECTIVE_DAYTIME = v_effective_daytime
            AND object_id = ec_stream.object_id_by_uk('SW_GP_DOMGAS_FORECAST');

        END LOOP;

        END IF;
    END LOOP;

    --update DG Energy from midnight to 8am basis
--ADP

    FOR DG_LOOP in DG_MORNING_DATA_TOTAL(ecdp_objects.getobjcode(v_forecast_id_guid_ADP)) loop
        UPDATE DV_CT_PROD_STRM_FORECAST
        SET GAS_DAY_DOMGAS_REGAS = DG_LOOP.CALC_GAS_DOMGAS_REGAS
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid_ADP
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;

    FOR DG_LOOP in DG_MORNING_DATA(ecdp_objects.getobjcode(v_forecast_id_guid_ADP),'F_JUL_BRU') loop
        UPDATE DV_CT_PROD_STRM_PC_FORECAST
        SET GAS_DAY_ENERGY = DG_LOOP.CALC_GAS_DAY_ENERGY, GAS_DAY_VOL_RATE = DG_LOOP.CALC_GAS_DAY_VOL_RATE
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND PROFIT_CENTRE_CODE LIKE 'F_JUL_BRU'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid_ADP
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;
    FOR DG_LOOP in DG_MORNING_DATA(ecdp_objects.getobjcode(v_forecast_id_guid_ADP),'F_WST_IAGO') loop
        UPDATE DV_CT_PROD_STRM_PC_FORECAST
        SET GAS_DAY_ENERGY = DG_LOOP.CALC_GAS_DAY_ENERGY, GAS_DAY_VOL_RATE = DG_LOOP.CALC_GAS_DAY_VOL_RATE
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND PROFIT_CENTRE_CODE LIKE 'F_WST_IAGO'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid_ADP
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;


--SDS

    FOR DG_LOOP in DG_MORNING_DATA_TOTAL(ecdp_objects.getobjcode(v_forecast_id_guid)) loop
        UPDATE DV_CT_PROD_STRM_FORECAST
        SET GAS_DAY_DOMGAS_REGAS = DG_LOOP.CALC_GAS_DOMGAS_REGAS
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;

    FOR DG_LOOP in DG_MORNING_DATA(ecdp_objects.getobjcode(v_forecast_id_guid),'F_JUL_BRU') loop
        UPDATE DV_CT_PROD_STRM_PC_FORECAST
        SET GAS_DAY_ENERGY = DG_LOOP.CALC_GAS_DAY_ENERGY, GAS_DAY_VOL_RATE = DG_LOOP.CALC_GAS_DAY_VOL_RATE
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND PROFIT_CENTRE_CODE LIKE 'F_JUL_BRU'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;
    FOR DG_LOOP in DG_MORNING_DATA(ecdp_objects.getobjcode(v_forecast_id_guid),'F_WST_IAGO') loop
        UPDATE DV_CT_PROD_STRM_PC_FORECAST
        SET GAS_DAY_ENERGY = DG_LOOP.CALC_GAS_DAY_ENERGY, GAS_DAY_VOL_RATE = DG_LOOP.CALC_GAS_DAY_VOL_RATE
        WHERE OBJECT_CODE LIKE 'SW_GP_DOMGAS_FORECAST'
        AND PROFIT_CENTRE_CODE LIKE 'F_WST_IAGO'
        AND FORECAST_OBJECT_ID = v_forecast_id_guid
        AND DAYTIME = DG_LOOP.DAYTIME;
    END LOOP;
    COMMIT;
--

END;

-----------------------------------------------------------------------------------------------------
-- Load production forecast restrictions from the staging tables
-----------------------------------------------------------------------------------------------------
PROCEDURE LoadProdFcastRestrictions(p_datastage_code VARCHAR2, p_start_date DATE, p_end_date DATE)
IS
--commented off forecast type and scenario in the restriction as we do not keep any version/type of restriction. the latest one always overwrite the old one
--Production Impact wasn't implemented by Quintiq, hence we took it out from the insert statement

    CURSOR get_scenario_type IS
    SELECT DECODE(UPPER(TRIM(forecast_type)), 'ADP_PLAN', 'ADP_PLAN',NULL) AS FORECAST_TYPE,
           DECODE(UPPER(TRIM(probability_type)), 'H', 'HIGH_CONF', 'M', 'MED_CONF', 'L',';LOW_CONF','R','REF_PROD', NULL) AS SCENARIO_TYPE
    FROM
    (
        SELECT data_stage_code, forecast_type, probability_type
        FROM TV_CT_STAGE_PROD_PC_FCST
    )
    WHERE data_stage_code = p_datastage_code;

    CURSOR forecasts(cp_start_date DATE) IS
    SELECT object_id
    FROM ov_forecast_tran_fc
    WHERE object_start_date = cp_start_date
    AND object_end_date = add_months(cp_start_date, 12)
    AND SCENARIO_TYPE = 'OPS_RESTRICTION';

    CURSOR domgas_restrictions IS
    SELECT unit_id, unit_name, upper(constraint_type) as constraint_type, daytime, end_date, duration_r, duration_h, duration_m, comments,LOCATION
    FROM tv_ct_stage_constraints
    WHERE data_stage_code = p_datastage_code
    AND daytime >= p_start_date
    AND daytime < p_end_date
    AND upper(constraint_type) = 'DOMGAS';

    CURSOR lifting_restrictions(cp_lifting_year DATE) IS
    SELECT unit_id, unit_name, upper(constraint_type) as constraint_type, cp_lifting_year as lifting_year, daytime,
           case when end_date >= add_months(cp_lifting_year, 12) then add_months(cp_lifting_year, 12) else end_date end as end_date,
           duration_r, duration_h, duration_m, comments,LOCATION
    FROM tv_ct_stage_constraints
    WHERE data_stage_code = p_datastage_code
    AND daytime >= p_start_date
    AND daytime < p_end_date
    AND upper(constraint_type) <> 'DOMGAS'
    AND add_months(trunc(add_months(daytime, -3), 'YEAR'), 3) = cp_lifting_year
    UNION
    SELECT unit_id, unit_name, upper(constraint_type) as constraint_type, cp_lifting_year as lifting_year, cp_lifting_year as daytime, end_date, duration_r, duration_h, duration_m, comments,LOCATION
    FROM tv_ct_stage_constraints
    WHERE data_stage_code = p_datastage_code
    AND daytime >= p_start_date
    AND daytime < p_end_date
    AND daytime < cp_lifting_year
    AND end_date > cp_lifting_year
    AND upper(constraint_type) <> 'DOMGAS'
    ORDER BY daytime;

    CURSOR distinct_lifting_years IS
    SELECT DISTINCT add_months(trunc(add_months(daytime, -3), 'YEAR'), 3) lifting_year
    FROM tv_ct_stage_constraints
    WHERE data_stage_code = p_datastage_code
    AND daytime >= p_start_date
    AND daytime < p_end_date
    UNION
    SELECT DISTINCT add_months(trunc(add_months(end_date, -3), 'YEAR'), 3) lifting_year
    FROM tv_ct_stage_constraints
    WHERE data_stage_code = p_datastage_code
    AND end_date >= p_start_date
    AND end_date < p_end_date
    ORDER BY lifting_year;

    v_fcst_type_code VARCHAR2(32);
    v_scenario_code VARCHAR2(32);
    v_forecast_id VARCHAR2(32);
    v_prod_fcty_id VARCHAR2(32);
    V_TEMP VARCHAR2(20000);
    v_Ori_Date DATE;
    v_Upd_Date DATE;
    v_temp_Date DATE;

BEGIN
    --ECDP_DYNSQL.WriteTempText('LoadProdFcastRestrictions','BY PASS');
    --ECDP_DYNSQL.WriteTempText('LoadProdFcastRestrictions','p_start_date='||p_start_date);
    --ECDP_DYNSQL.WriteTempText('LoadProdFcastRestrictions','p_end_date='||p_end_date);
/*     FOR item IN get_scenario_type LOOP
        v_fcst_type_code := item.forecast_type;
        v_scenario_code := item.scenario_type;
    END LOOP; */

    -- Do the LNG restrictions first
    FOR ly_item IN distinct_lifting_years LOOP
        --ECDP_DYNSQL.WriteTempText('LoadProdFcastRestrictions','LIFTING_YEAR='||ly_item.lifting_year);
        v_forecast_id := NULL;

        -- Does a forecast already exist for this period?
        FOR item IN forecasts(ly_item.lifting_year) LOOP
            v_forecast_id := item.object_id;
        END LOOP;
        --ECDP_DYNSQL.WriteTempText('LoadProdFcastRestrictions','v_forecast_id='||v_forecast_id);

        IF v_forecast_id IS NULL THEN
            --INSERT INTO ov_forecast_tran_fc (code, name, object_start_date, object_end_date, daytime, description, forecast_type, period_type, prod_fcst_type, prod_fcst_scenario)
            INSERT INTO ov_forecast_tran_fc (code, name, object_start_date, object_end_date, daytime, description, forecast_type, period_type,SCENARIO_TYPE  )
            VALUES ('FC_OPR_RES_' || to_char(ly_item.lifting_year, 'YYYY') ,
                    'Operational Restrictions: ' || to_char(ly_item.lifting_year, 'YYYY') ,
                    ly_item.lifting_year,
                    add_months(ly_item.lifting_year, 12),
                    ly_item.lifting_year,
                    'Contains operational restrictions for the lifting year ',
                    'OFFICIAL',
                    'LTF',
                    'OPS_RESTRICTION');
            FOR item IN forecasts(ly_item.lifting_year) LOOP
                v_forecast_id := item.object_id; -- select * from ov_forecast_tran_fc
            END LOOP;
--ECDP_DYNSQL.WriteTempText('LoadProdFcastRestrictions','INSERTED INTO OV WITH FORECAST ID='||v_forecast_id);

        END IF;

        -- Delete all operational restrictions from the forecast between the start and end date
        DELETE FROM FCST_OPLOC_DAY_RESTRICT
        WHERE forecast_id = v_forecast_id
        AND daytime >= p_start_date
        AND daytime <=
        (
            SELECT MAX(x.end_date)
            FROM dv_fcst_opres_period_restr x
            WHERE x.forecast_id = v_forecast_id
            AND x.daytime >= p_start_date
            AND x.daytime < p_end_date
        );

        DELETE FROM dv_fcst_opres_period_restr
        WHERE forecast_id = v_forecast_id
        AND daytime >= p_start_date
        AND daytime < p_end_date;

        DELETE FROM FCST_OPLOC_DAY_RESTRICT
        WHERE forecast_id = v_forecast_id
        AND daytime >= p_start_date
        AND daytime <=
        (
            SELECT MAX(x.end_date)
            FROM dv_fcst_opres_period_restr x
            WHERE x.forecast_id = v_forecast_id
            AND x.end_date >= p_start_date
            AND x.end_date < p_end_date
        );

        DELETE FROM dv_fcst_opres_period_restr
        WHERE forecast_id = v_forecast_id
        AND end_date >= p_start_date
        AND end_date < p_end_date;


        v_Ori_Date := NULL;
        -- Loop through the restrictions in the staging tables and insert them one by one
        FOR item IN lifting_restrictions(ly_item.lifting_year) LOOP
            IF v_Ori_Date IS NULL THEN
                v_Ori_Date:=item.daytime;
                v_Upd_Date:=item.daytime;
            ELSE
                IF item.DAYTIME = v_Ori_Date THEN
                    v_Upd_Date := v_Upd_Date + (1/24/60); -- PLUS 1 MINUTE
                ELSE
                    v_Ori_Date:=item.daytime;
                    v_Upd_Date:=item.daytime;
                END IF;
            END IF;

            INSERT INTO dv_fcst_opres_period_restr (object_id, daytime, forecast_id, end_date, LOCATION, comments)
            VALUES (ec_production_facility.object_id_by_uk('FC2_WS1_LN0', 'FCTY_CLASS_2'), v_Upd_Date, v_forecast_id, item.end_date, ITEM.LOCATION, item.comments || ' (' || nvl(item.unit_name, item.unit_id) || ')' );
        END LOOP;
        v_Ori_Date := NULL;
        /*tlct on 07-jan-2016: included the Domgas together with the LNG restriction*/
        FOR item IN domgas_restrictions LOOP
            -- FC2_WS1_DG0 - DOMGAS Production Common
            IF v_Ori_Date IS NULL THEN
                v_Ori_Date:=item.daytime;
                v_Upd_Date:=item.daytime;
            ELSE
                IF item.DAYTIME = v_Ori_Date THEN
                    v_Upd_Date := v_Upd_Date + (1/24/60); -- PLUS 1 MINUTE
                ELSE
                    v_Ori_Date:=item.daytime;
                    v_Upd_Date:=item.daytime;
                END IF;
            END IF;
            INSERT INTO dv_fcst_opres_period_restr (object_id, daytime, forecast_id, end_date,LOCATION, comments)
            VALUES (ec_production_facility.object_id_by_uk('FC2_WS1_DG0', 'FCTY_CLASS_2'), v_Upd_Date, v_forecast_id, item.end_date, ITEM.LOCATION, item.comments || ' (' || nvl(item.unit_name, item.unit_id) || ')' );
        END LOOP;
    END LOOP;
/*--commented off b ytlxt on 07-Jan-2016
    -- Now do the DOMGAS restrictions
    DELETE FROM dv_opres_period_restriction
    WHERE daytime >= p_start_date
    AND daytime <= p_end_date;

    FOR item IN domgas_restrictions LOOP
        -- FC2_WS1_DG0 - DOMGAS Production Common
        INSERT INTO dv_opres_period_restriction (object_id, daytime, end_date, comments)
        VALUES (ec_production_facility.object_id_by_uk('FC2_WS1_DG0', 'FCTY_CLASS_2'), item.daytime, item.end_date, item.comments || ' (' || nvl(item.unit_name, item.unit_id) || ')');
    END LOOP;
*/
END LoadProdFcastRestrictions;

PROCEDURE LoadDataFromCPP(
  p_date    VARCHAR2,--format as DD/MM/YYYY
  p_forecast_type    VARCHAR2, -- ADP/SDS
  p_probability_type    VARCHAR2, --H,M,L,R
  p_upg        VARCHAR2, -- WI,JB OR BLANK
  p_LNG_RATE NUMBER,
  p_LNG_MASS_RATE NUMBER,
  p_LNG_DENSITY NUMBER,
  p_LNG_HHV NUMBER,
  p_LNG_EXCESS_PROD NUMBER,
  p_LNG_REGAS_REQ NUMBER, -- tlxt: 98647
  p_CONFIRMED_EXCESS_QTY NUMBER, -- tlxt: 98647
  p_COND_RATE NUMBER,
  p_COND_MASS_RATE NUMBER,
  p_COND_DENSITY NUMBER,
  p_LNG_MASS_SMPP NUMBER,
  p_COND_MASS_SMPP NUMBER,
  p_DOMGAS_MASS NUMBER,
  p_DOMGAS_ENERGY NUMBER,
  p_DOMGAS_HHV NUMBER,
  p_DOMGAS_SMPP NUMBER,
  p_DOMGAS_VOLUME NUMBER,
  p_DOMGAS_MIN_RATE_ENERGY NUMBER,
  p_DOMGAS_REGAS NUMBER,
  p_PLATFORM_MASS_SMPP NUMBER,
  p_DATA_STAGE_CODE VARCHAR2,
  p_RECORD_COUNT NUMBER,
  p_FORECAST_ID    VARCHAR2,
  p_END_DATE    VARCHAR2--format as DD/MM/YYYY
  )

--</EC-DOC>
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    v_count NUMBER;
    v_upg VARCHAR2(32);
    v_date DATE;
    v_DATA_STAGE_CODE VARCHAR2(32);
    v_forecast_type VARCHAR2(32);
      v_LNG_RATE NUMBER;
      v_LNG_MASS_RATE NUMBER;
      v_LNG_DENSITY NUMBER;
      v_LNG_HHV NUMBER;
      v_LNG_EXCESS_PROD NUMBER;
      v_LNG_REGAS_REQ NUMBER;
      v_CONFIRMED_EXCESS_QTY NUMBER;
      v_COND_RATE NUMBER;
      v_COND_MASS_RATE NUMBER;
      v_COND_DENSITY NUMBER;
      v_LNG_MASS_SMPP NUMBER;
      v_COND_MASS_SMPP NUMBER;
      v_DOMGAS_MASS NUMBER;
      v_DOMGAS_ENERGY NUMBER;
      v_DOMGAS_HHV NUMBER;
      v_DOMGAS_SMPP NUMBER;
      --added by tlxt:
      v_DOMGAS_VOLUME NUMBER;
      v_DOMGAS_MIN_RATE_ENERGY NUMBER;
      v_DOMGAS_REGAS NUMBER;
      v_PLATFORM_MASS_SMPP NUMBER;
      v_RECORD_COUNT NUMBER;
      v_FORECAST_ID    VARCHAR2(32);
      v_END_DATE    DATE;

BEGIN
/*
    v_LNG_RATE:=ROUND(TO_NUMBER(p_LNG_RATE),20);
    v_LNG_MASS_RATE:= ROUND(TO_NUMBER(p_LNG_MASS_RATE),20);
    v_LNG_DENSITY:= ROUND(TO_NUMBER(p_LNG_DENSITY),20);
    v_LNG_HHV:=ROUND(TO_NUMBER(p_LNG_HHV),20);
    v_LNG_EXCESS_PROD:= ROUND(TO_NUMBER(p_LNG_EXCESS_PROD),20) ;
    v_COND_RATE:= ROUND(TO_NUMBER(p_COND_RATE),20);
    v_COND_MASS_RATE:= ROUND(TO_NUMBER(p_COND_MASS_RATE),20);
    v_COND_DENSITY:=ROUND(TO_NUMBER(p_COND_DENSITY),20);
    v_LNG_MASS_SMPP:=ROUND(TO_NUMBER(p_LNG_MASS_SMPP),20);
    v_COND_MASS_SMPP:=ROUND(TO_NUMBER(p_COND_MASS_SMPP),20);
    v_DOMGAS_MASS:=ROUND(TO_NUMBER(p_DOMGAS_MASS),20);
    v_DOMGAS_ENERGY:=ROUND(TO_NUMBER(p_DOMGAS_ENERGY),20);
    v_DOMGAS_HHV:=ROUND(TO_NUMBER(p_DOMGAS_HHV),20);
    v_DOMGAS_SMPP:=ROUND(TO_NUMBER(p_DOMGAS_SMPP),20);
    v_RECORD_COUNT:=ROUND(TO_NUMBER(p_RECORD_COUNT),20);
*/
    v_LNG_RATE:=TRUNC(p_LNG_RATE,3);
    v_LNG_MASS_RATE:= TRUNC(p_LNG_MASS_RATE,3);
    v_LNG_DENSITY:= TRUNC(p_LNG_DENSITY,3);
    v_LNG_HHV:=TRUNC(p_LNG_HHV,3);
    v_LNG_EXCESS_PROD:= TRUNC(p_LNG_EXCESS_PROD,3) ;
    v_LNG_REGAS_REQ:= TRUNC(p_LNG_REGAS_REQ,3) ;
    v_CONFIRMED_EXCESS_QTY:= TRUNC(p_CONFIRMED_EXCESS_QTY,3) ;
    v_COND_RATE:= TRUNC(p_COND_RATE,3);
    v_COND_MASS_RATE:= TRUNC(p_COND_MASS_RATE,3);
    v_COND_DENSITY:=TRUNC(p_COND_DENSITY,3);
    v_LNG_MASS_SMPP:=TRUNC(p_LNG_MASS_SMPP,3);
    v_COND_MASS_SMPP:=TRUNC(p_COND_MASS_SMPP,3);
    v_DOMGAS_MASS:=TRUNC(p_DOMGAS_MASS,3);
    v_DOMGAS_ENERGY:=TRUNC(p_DOMGAS_ENERGY,3);
    v_DOMGAS_HHV:=TRUNC(p_DOMGAS_HHV,3);
    v_DOMGAS_SMPP:=TRUNC(p_DOMGAS_SMPP,3);
    v_RECORD_COUNT:=TRUNC(p_RECORD_COUNT,3);
--added by tlxt:
    v_DOMGAS_VOLUME := TRUNC(p_DOMGAS_VOLUME,3);
    v_DOMGAS_MIN_RATE_ENERGY := TRUNC(p_DOMGAS_MIN_RATE_ENERGY,3);
    v_DOMGAS_REGAS := TRUNC(p_DOMGAS_REGAS,3);
    v_PLATFORM_MASS_SMPP := TRUNC(p_PLATFORM_MASS_SMPP,3);
    v_FORECAST_ID    := NVL(v_FORECAST_ID,'NA');
    v_END_DATE    := to_date(NVL(p_END_DATE,'31-DEC-2099'),'YYYY-MM-DD"T"HH24:MI:SS');
--added by tlxt:

    --ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','p_date='||p_date);
    IF (TRUNC(to_date(NVL(p_date,'31-DEC-2099'),'YYYY-MM-DD"T"HH24:MI:SS')) <> '31-DEC-2099') THEN
        --ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','entering IF');
        SELECT to_date(p_date,'YYYY-MM-DD"T"HH24:MI:SS') INTO v_date FROM DUAL;

        SELECT COUNT(*) INTO v_count FROM TV_CT_STAGE_PROD_PC_FCST WHERE DATA_STAGE_CODE = p_DATA_STAGE_CODE AND TRUNC(CREATED_DATE) <> TRUNC(SYSDATE);
        IF v_count > 0 THEN
            ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE:CPP','DATA_STAGE_CODE already exists['|| p_DATA_STAGE_CODE || '] '||p_date);
            RAISE_APPLICATION_ERROR(-20999,'Comon, dont be smart trying to use an existing DATA_STAGE_CODE');
        END IF;
        SELECT DECODE(NVL(p_upg,'ALL'),'WI','F_WST_IAGO','JB','F_JUL_BRU','ALL','ALL','UNKWNON') INTO v_upg FROM DUAL;
        SELECT DECODE(NVL(p_forecast_type,'UNKNOWN'),'ADP','ADP_PLAN','SDS','SDS_PLAN','NOMINATIONS_PLAN','NOMINATIONS_PLAN','BUSINESS_PLAN','BUSINESS_PLAN','UNKWNON') INTO v_forecast_type FROM DUAL;
        INSERT INTO TV_CT_STAGE_PROD_PC_FCST(CREATED_DATE,CREATED_BY,DATA_STAGE_CODE,DAYTIME,FORECAST_TYPE,PROBABILITY_TYPE,UPG,
        LNG_RATE, LNG_MASS_RATE,LNG_HHV,LNG_EXCESS_PROD,LNG_REGAS_REQ_LNG,CONFIRMED_EXCESS_QTY,
        COND_RATE,COND_MASS_RATE,LNG_DENSITY,COND_DENSITY,
        LNG_MASS_SMPP,COND_MASS_SMPP,DOMGAS_MASS,DOMGAS_ENERGY,DOMGAS_HHV,DOMGAS_SMPP,
        DOMGAS_VOLUME,DOMGAS_MIN_RATE_ENERGY,DOMGAS_REGAS,PLATFORM_MASS_SMPP,FORECAST_ID)
        VALUES(SYSDATE,ECDP_CONTEXT.GETAPPUSER(),p_DATA_STAGE_CODE,to_date(p_date,'YYYY-MM-DD"T"HH24:MI:SS'),v_forecast_type,p_probability_type,v_upg,
        v_LNG_RATE,v_LNG_MASS_RATE,v_LNG_HHV,v_LNG_EXCESS_PROD,v_LNG_REGAS_REQ,v_CONFIRMED_EXCESS_QTY,
        v_COND_RATE,v_COND_MASS_RATE,v_LNG_DENSITY,v_COND_DENSITY,
        v_LNG_MASS_SMPP,v_COND_MASS_SMPP,v_DOMGAS_MASS,v_DOMGAS_ENERGY,v_DOMGAS_HHV,v_DOMGAS_SMPP,
        v_DOMGAS_VOLUME,v_DOMGAS_MIN_RATE_ENERGY,v_DOMGAS_REGAS,v_PLATFORM_MASS_SMPP,v_FORECAST_ID);
    ELSE
    --ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','entering else');
        v_DATA_STAGE_CODE := p_DATA_STAGE_CODE||',0,0';
        SELECT COUNT(*) INTO v_count
        FROM TV_CT_STAGE_PROD_PC_FCST
        WHERE DATA_STAGE_CODE = p_DATA_STAGE_CODE
        AND FORECAST_TYPE <> 'ERR'
        AND TRUNC(CREATED_DATE) = TRUNC(SYSDATE);
        IF v_count = v_RECORD_COUNT THEN
        --ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','sending msg');
            SendReadyMessage('CC_WHEATSTONE', 'PROD_FORECAST',TRUNC(SYSDATE),TRUNC(SYSDATE),v_count,'DATA_STAGE_CODE,DOMGAS_CONSTRAINT_SIZE,LNG_CONSTRAINT_SIZE',v_DATA_STAGE_CODE,'IN','CC_QUINTIQ');
        --ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','msg sent');
        ELSE
            ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','Record count not match, v_count='||v_count || ',v_RECORD_COUNT='||v_RECORD_COUNT || ', for p_DATA_STAGE_CODE=' ||p_DATA_STAGE_CODE );
        END IF;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
        ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','Unexpected error');
        INSERT INTO TV_CT_STAGE_PROD_PC_FCST(CREATED_DATE,CREATED_BY,DATA_STAGE_CODE,DAYTIME,FORECAST_TYPE,PROBABILITY_TYPE,UPG)
        VALUES(SYSDATE,ECDP_CONTEXT.GETAPPUSER(),p_DATA_STAGE_CODE,to_date(p_date,'YYYY-MM-DD"T"HH24:MI:SS'),'ERR','ERR','ERR');
COMMIT;
    RAISE;
END LoadDataFromCPP;

PROCEDURE LoadRstDataFromCPP(
  p_date    VARCHAR2,--format as DD/MM/YYYY
  p_end_date    VARCHAR2,--format as DD/MM/YYYY
  --p_DURATION VARCHAR2,
  p_UNIT_ID VARCHAR2,
  p_UNIT_NAME VARCHAR2,
  p_LOCATION VARCHAR2, --taking in any value from IDV
  p_CONSTRAINTS_TYPE VARCHAR2, --format as (DOMGAS OR OTHERS)
  p_COMMENT VARCHAR2,
  p_DATA_STAGE_CODE VARCHAR2,
  p_RECORD_COUNT VARCHAR2 -- EC_X
  )

--</EC-DOC>
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    v_count NUMBER;
    v_DURATION NUMBER;
    v_upg VARCHAR2(32);
    v_date DATE;
    v_DATA_STAGE_CODE VARCHAR2(32);
    v_forecast_type VARCHAR2(32);
      v_RECORD_COUNT VARCHAR2(32);
      v_from_date DATE;
      v_to_date DATE;
BEGIN

    --v_DURATION:=ROUND(TO_NUMBER(p_DURATION),20);
    v_RECORD_COUNT:=ROUND(TO_NUMBER(p_RECORD_COUNT),1);
    --ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','p_date='|| p_date ||',v_RECORD_COUNT='||v_RECORD_COUNT);
    IF (TRUNC(to_date(NVL(p_date,'31-DEC-2099'),'YYYY-MM-DD"T"HH24:MI:SS')) <> '31-DEC-2099') THEN
        --ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','IF BLOCK');
        SELECT to_date(p_date,'YYYY-MM-DD"T"HH24:MI:SS') INTO v_date FROM DUAL;
        SELECT COUNT(*) INTO v_count FROM TV_CT_STAGE_CONSTRAINTS WHERE DATA_STAGE_CODE = p_DATA_STAGE_CODE AND TRUNC(CREATED_DATE) <> TRUNC(SYSDATE);
        IF v_count > 0 THEN
            ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_MSG_INTERFACE:CPP','DATA_STAGE_CODE already exists['|| p_DATA_STAGE_CODE || '] '||p_date);
            RAISE_APPLICATION_ERROR(-20999,'Comon, dont be smart trying to use an existing DATA_STAGE_CODE');
        END IF;
        --SELECT DECODE(NVL(p_upg,'ALL'),'WI','F_WST_IAGO','JB','F_JUL_BRU','ALL','ALL','UNKWNON') INTO v_upg FROM DUAL;
        --SELECT DECODE(NVL(p_forecast_type,'UNKNOWN'),'ADP','ADP_PLAN','SDS','SDS_PLAN','UNKWNON') INTO v_forecast_type FROM DUAL;
        INSERT INTO TV_CT_STAGE_CONSTRAINTS(CREATED_DATE,CREATED_BY,DATA_STAGE_CODE,DAYTIME,END_DATE,
        UNIT_ID,UNIT_NAME,CONSTRAINT_TYPE,LOCATION,ASSUMPTION_ID,
        COMMENTS)
        VALUES(SYSDATE,ECDP_CONTEXT.GETAPPUSER(),p_DATA_STAGE_CODE,to_date(p_date,'YYYY-MM-DD"T"HH24:MI:SS'),to_date(p_end_date,'YYYY-MM-DD"T"HH24:MI:SS'),
        p_UNIT_ID,p_UNIT_NAME,p_CONSTRAINTS_TYPE,p_LOCATION,SYS_GUID(),
        p_COMMENT);
    ELSE
        --ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','ELSE BLOCK');
        v_DATA_STAGE_CODE := p_DATA_STAGE_CODE||',0,0';
        --insert into t_temptext(ID,TEXT)VALUES('UE_CT_MSG_INTERFACE:CPP',);
        SELECT COUNT(*) INTO v_count
        FROM TV_CT_STAGE_CONSTRAINTS
        WHERE DATA_STAGE_CODE = p_DATA_STAGE_CODE
        AND UNIT_ID <> 'ERR'
        AND TRUNC(CREATED_DATE) = TRUNC(SYSDATE);
        --ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','v_count='||v_count||',v_RECORD_COUNT='||v_RECORD_COUNT);
        IF v_count = v_RECORD_COUNT THEN
            --Get the from date and todate
            SELECT MIN(DAYTIME),MAX(END_DATE) INTO v_from_date, v_to_date FROM TV_CT_STAGE_CONSTRAINTS WHERE DATA_STAGE_CODE = p_DATA_STAGE_CODE;
            SendReadyMessage('CC_WHEATSTONE', 'PROD_FORECAST',v_from_date,v_to_date,v_count,'DATA_STAGE_CODE,DOMGAS_CONSTRAINT_SIZE,LNG_CONSTRAINT_SIZE',v_DATA_STAGE_CODE,'IN','CC_QUINTIQ');
        ELSE
            ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','Record count not match, v_count='||v_count || ',v_RECORD_COUNT='||v_RECORD_COUNT || ', for p_DATA_STAGE_CODE=' ||p_DATA_STAGE_CODE );
        END IF;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
        ECDP_DYNSQL.WRITETEMPTEXT ('UE_CT_MSG_INTERFACE:CPP','Unexpected error');
        INSERT INTO TV_CT_STAGE_CONSTRAINTS(CREATED_DATE,CREATED_BY,DATA_STAGE_CODE,DAYTIME,END_DATE,UNIT_ID)
        VALUES(SYSDATE,ECDP_CONTEXT.GETAPPUSER(),p_DATA_STAGE_CODE,to_date(p_date,'YYYY-MM-DD"T"HH24:MI:SS'),to_date(p_end_date,'YYYY-MM-DD"T"HH24:MI:SS'),'ERR');
COMMIT;
    RAISE;
END LoadRstDataFromCPP;

END UE_CT_MSG_INTERFACE;
/
