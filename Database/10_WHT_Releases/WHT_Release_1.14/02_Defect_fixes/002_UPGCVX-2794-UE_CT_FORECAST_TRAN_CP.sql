create or replace PACKAGE UE_CT_FORECAST_TRAN_CP
IS
-------------------------------------------------------------------------
--
-- Package Name: UE_CT_FORECAST_TRAN_CP
-- Author: SWGN
-- Purpose: Administration of cargo planning scenarios (forecasts)
-- 06-mar-2017 koij 113799 Add UpdateETAETD_Locked() Cargo ETA and ETD Verfification.Persist values when scenario is verified or approved
--
-------------------------------------------------------------------------

PROCEDURE ValidateAffectedCargoes(p_forecast_id VARCHAR2);

PROCEDURE SynchronizeMessageDistribution(p_forecast_id VARCHAR2, p_approval_status VARCHAR2, p_message_context VARCHAR2 DEFAULT 'LIFTING_PROGRAM');

PROCEDURE UpdateChildApprovalStatus(p_forecast_id VARCHAR2, p_old_status VARCHAR2, p_new_status VARCHAR2, p_user_id VARCHAR2);

PROCEDURE UpdateETAETD_Locked(p_forecast_id VARCHAR2, p_old_status VARCHAR2, p_new_status VARCHAR2, p_user_id VARCHAR2);
PROCEDURE LockProductionForecast(p_forecast_id VARCHAR2);

PROCEDURE UnlockProductionForecast(p_forecast_id VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE UpdateStatusFromWorkFlow(p_forecast_id VARCHAR2,p_new_status VARCHAR2,p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE UpdateTableStatus(p_forecast_id VARCHAR2, p_old_status VARCHAR2, p_new_status VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE UpdateREStatusFrWorkFlow(p_forecast_id VARCHAR2,p_new_status VARCHAR2,p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE UpdateRefEntStatus(p_forecast_object_id VARCHAR2, p_old_status VARCHAR2, p_new_status VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE UpdateReCalcRefEnt(p_forecast_object_id VARCHAR2, p_old_status VARCHAR2, p_new_status VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL,p_company_id VARCHAR2 DEFAULT NULL);

END UE_CT_FORECAST_TRAN_CP;
/
create or replace PACKAGE BODY UE_CT_FORECAST_TRAN_CP
IS
/****************************************************************
** Package        :  UE_CT_FORECAST_TRAN_CP, body part
**
** Purpose        :  Handles trigger actions related to transport forecasts
**                   Initially intended to only handle cargo plannng (CP) forecasts
**                   Later extended to include Domgas (FC) forecasts, but package name left intact
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
** 26-FEB-2013    tlxt  Changed the object ID of the screen used to manage cargo planning
** 01-JAN-2014(?) lbfk  Forked from Gorgon
** 30-OCT-2014    tlxt  Update all reference entitlement-related classed when a user changes the record status in the Lifting Program Calculation
** 10-NOV-2014    tlxt  Prevented scenario promotion from P to A when scenario nominations are not validated
** 25-NOV-2014    tlxt  Added ability to create cargo planning forecasts prior to sytem date using the ENABLE_CP_SCEN_DATE_VAL flag
** 03-MAR-2015    tlxt  Removed the automatic generation of cargo numbers
** 11-MAR-2015    tlxt  Modified behavior of cargo planning forecast status changes
** 14-APR-2015    tlxt  Write PLP scenario data when verified to CPP
** 02-JUL-2015    tlxt  Check monthly adjustment class for setting to approve trading data upon ADP approval
** 04-NOV-2015    swgn  [102457] Enhanced to include Domgas (FC) forecasts within the SynchronizeMessageDistribution procedure
**                      Also added this changelog header and recreated changelog based on inline comments (not all dates in changelog prior to this are necessarily accurate)
** 14-NOV-2016    cvmk  [112302]: Modified UpdateChildApprovalStatus()
** 02-FEB-2017    koij  Added logic to exclude nominations marked in orange color from verification process and enable scenario publishing
** 06-mar-2017    koij  113799 Add UpdateETAETD_Locked() Cargo ETA and ETD Verfification.Persist values when scenario is verified or approved
** 03-aug-2018    WVIC  128753 Modified ValidateAffectedCargoes to remove comparison Documentary Instruction data that is not copied from the forecast
** 23-NOV-2018    kawf  Item_129600: Modified ValidateAffectedCargoes to filter only 'A','C' in cursor "parcels", excl all cargo status up to ReadyToHarbor
*****************************************************************/

--GLOBAL TYPE
TYPE noms_type IS TABLE OF DV_FCST_STOR_LIFT_NOM%ROWTYPE;
PROCEDURE ValidateAffectedCargoes(p_forecast_id VARCHAR2)
IS

    CURSOR parcels IS
    SELECT 'A'
    FROM stor_fcst_lift_nom fcst
    INNER JOIN storage_lift_nomination base
    ON fcst.parcel_no = base.parcel_no
    WHERE fcst.forecast_id = p_forecast_id
    -- Item 128753 Begin
    --AND NVL(ec_cargo_transport.cargo_status(base.cargo_no), 'NULL') NOT IN ('NULL','D','O','T','K','S','X','Y','Z')
	--AND NVL(ecbp_cargo_status.geteccargostatus(ec_cargo_transport.cargo_status(base.cargo_no)), 'T') NOT IN ('D','T') --129600: remove
	-- Item 128753 End
    AND NVL(ec_cargo_transport.cargo_status(base.cargo_no), 'NULL') IN ('C','A') --129600: added 'A','C'
    AND
    (
        NVL(fcst.DATE_3,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.DATE_3,to_date('01-JAN-1900','DD-MON-YYYY'))
        OR NVL(fcst.DATE_4,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.DATE_4,to_date('01-JAN-1900','DD-MON-YYYY'))
        OR NVL(fcst.DATE_5,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.DATE_5,to_date('01-JAN-1900','DD-MON-YYYY'))
        OR NVL(fcst.DATE_6,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.DATE_6,to_date('01-JAN-1900','DD-MON-YYYY'))
        OR NVL(fcst.DATE_7,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.DATE_7,to_date('01-JAN-1900','DD-MON-YYYY'))
        OR NVL(fcst.REF_OBJECT_ID_1,'XYXX') <> NVL(base.REF_OBJECT_ID_1,'XYXX')
        OR NVL(fcst.REF_OBJECT_ID_2,'XYXX') <> NVL(base.REF_OBJECT_ID_2,'XYXX')
        OR NVL(fcst.REF_OBJECT_ID_3,'XYXX') <> NVL(base.REF_OBJECT_ID_3,'XYXX')
        OR NVL(fcst.REF_OBJECT_ID_4,'XYXX') <> NVL(base.REF_OBJECT_ID_4,'XYXX')
        OR NVL(fcst.REF_OBJECT_ID_5,'XYXX') <> NVL(base.REF_OBJECT_ID_5,'XYXX')
        OR NVL(fcst.COOLDOWN_IND,'XYXX') <> NVL(base.COOLDOWN_IND,'XYXX')
        OR NVL(fcst.COOLDOWN_QTY,-9871233) <> NVL(base.COOLDOWN_QTY,-9871233)
        OR NVL(fcst.PURGE_IND,'XYXX') <> NVL(base.PURGE_IND,'XYXX')
        OR NVL(fcst.PURGE_QTY,-9871233) <> NVL(base.PURGE_QTY,-9871233)
        OR NVL(fcst.PARCEL_NO,-9871233) <> NVL(base.PARCEL_NO,-9871233)
        OR NVL(fcst.OBJECT_ID,'XYXX') <> NVL(base.OBJECT_ID,'XYXX')
        OR NVL(fcst.CARGO_NO,-9871233) <> NVL(base.CARGO_NO,-9871233)
        OR NVL(fcst.LIFTING_ACCOUNT_ID,'XYXX') <> NVL(base.LIFTING_ACCOUNT_ID,'XYXX')
        OR NVL(fcst.CARRIER_ID,'XYXX') <> NVL(base.CARRIER_ID,'XYXX')
		-- Item 128753 Begin
        --OR NVL(fcst.CONSIGNOR_ID,'XYXX') <> NVL(base.CONSIGNOR_ID,'XYXX')
		-- Item 128753 End
        OR NVL(fcst.CONSIGNEE_ID,'XYXX') <> NVL(base.CONSIGNEE_ID,'XYXX')
        OR NVL(fcst.REQUESTED_DATE,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.REQUESTED_DATE,to_date('01-JAN-1900','DD-MON-YYYY'))
        OR NVL(fcst.REQUESTED_DATE_RANGE,'XYXX') <> NVL(base.REQUESTED_DATE_RANGE,'XYXX')
        OR NVL(fcst.REQUESTED_TOLERANCE_TYPE,'XYXX') <> NVL(base.REQUESTED_TOLERANCE_TYPE,'XYXX')
        OR NVL(fcst.NOM_FIRM_DATE,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.NOM_FIRM_DATE,to_date('01-JAN-1900','DD-MON-YYYY'))
        OR NVL(fcst.NOM_FIRM_DATE_RANGE,'XYXX') <> NVL(base.NOM_FIRM_DATE_RANGE,'XYXX')
        OR NVL(fcst.NOM_SEQUENCE,-9871233) <> NVL(base.NOM_SEQUENCE,-9871233)
        OR NVL(fcst.LIFTING_SPLIT_PCT,-9871233) <> NVL(base.LIFTING_SPLIT_PCT,-9871233)
        OR NVL(fcst.LIFTING_SPLIT_VOL,-9871233) <> NVL(base.LIFTING_SPLIT_VOL,-9871233)
        OR NVL(fcst.LIFTING_CODE,'XYXX') <> NVL(base.LIFTING_CODE,'XYXX')
        OR NVL(fcst.INCOTERM,'XYXX') <> NVL(base.INCOTERM,'XYXX')
        OR NVL(fcst.CONTRACT_ID,'XYXX') <> NVL(base.CONTRACT_ID,'XYXX')
        OR NVL(fcst.TELEX_REF,'XYXX') <> NVL(base.TELEX_REF,'XYXX')
        OR NVL(fcst.GRAPH_VALUE,-9871233) <> NVL(base.GRAPH_VALUE,-9871233)
        OR NVL(fcst.BALANCE_IND,'XYXX') <> NVL(base.BALANCE_IND,'XYXX')
        OR NVL(fcst.GRS_VOL_NOMINATED,-9871233) <> NVL(base.GRS_VOL_NOMINATED,-9871233)
        OR NVL(fcst.GRS_VOL_REQUESTED,-9871233) <> NVL(base.GRS_VOL_REQUESTED,-9871233)
        OR NVL(fcst.GRS_VOL_SCHEDULE,-9871233) <> NVL(base.GRS_VOL_SCHEDULE,-9871233)
        OR NVL(fcst.GRS_VOL_NOMINATED2,-9871233) <> NVL(base.GRS_VOL_NOMINATED2,-9871233)
        OR NVL(fcst.GRS_VOL_REQUESTED2,-9871233) <> NVL(base.GRS_VOL_REQUESTED2,-9871233)
        OR NVL(fcst.GRS_VOL_SCHEDULED2,-9871233) <> NVL(base.GRS_VOL_SCHEDULED2,-9871233)
        OR NVL(fcst.GRS_VOL_NOMINATED3,-9871233) <> NVL(base.GRS_VOL_NOMINATED3,-9871233)
        OR NVL(fcst.GRS_VOL_REQUESTED3,-9871233) <> NVL(base.GRS_VOL_REQUESTED3,-9871233)
        OR NVL(fcst.GRS_VOL_SCHEDULED3,-9871233) <> NVL(base.GRS_VOL_SCHEDULED3,-9871233)
        OR NVL(fcst.SCHEDULE_TOLERANCE_TYPE,'XYXX') <> NVL(base.SCHEDULE_TOLERANCE_TYPE,'XYXX')
		-- Item 128753 Begin
        --OR NVL(fcst.BL_NUMBER,'XYXX') <> NVL(base.BL_NUMBER,'XYXX')
        --OR NVL(fcst.BL_DATE,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.BL_DATE,to_date('01-JAN-1900','DD-MON-YYYY'))
		-- Item 128753 Begin
        OR NVL(fcst.UNLOAD_DATE,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.UNLOAD_DATE,to_date('01-JAN-1900','DD-MON-YYYY'))
        OR NVL(fcst.PORT_ID,'XYXX') <> NVL(base.PORT_ID,'XYXX')
        OR NVL(fcst.DOC_INSTR_RECEIVED_IND,'XYXX') <> NVL(base.DOC_INSTR_RECEIVED_IND,'XYXX')
        OR NVL(fcst.FIXED_IND,'XYXX') <> NVL(base.FIXED_IND,'XYXX')
        OR NVL(fcst.BOL_COMMENTS,'XYXX') <> NVL(base.BOL_COMMENTS,'XYXX')
        OR NVL(fcst.CHARTER_PARTY,'XYXX') <> NVL(base.CHARTER_PARTY,'XYXX')
		-- Item 128753 Begin
        --OR NVL(fcst.BL_DATE_TIME,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.BL_DATE_TIME,to_date('01-JAN-1900','DD-MON-YYYY'))
		-- Item 128753 End
        OR NVL(fcst.START_LIFTING_DATE,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.START_LIFTING_DATE,to_date('01-JAN-1900','DD-MON-YYYY'))
		-- Item 128753 Begin
        --OR NVL(fcst.COMMENTS,'XYXX') <> NVL(base.COMMENTS,'XYXX')
		-- Item 128753 End
        OR NVL(fcst.VALUE_1,-9871233) <> NVL(base.VALUE_1,-9871233)
        OR NVL(fcst.VALUE_2,-9871233) <> NVL(base.VALUE_2,-9871233)
        OR NVL(fcst.VALUE_3,-9871233) <> NVL(base.VALUE_3,-9871233)
        OR NVL(fcst.VALUE_4,-9871233) <> NVL(base.VALUE_4,-9871233)
        OR NVL(fcst.VALUE_5,-9871233) <> NVL(base.VALUE_5,-9871233)
        OR NVL(fcst.VALUE_6,-9871233) <> NVL(base.VALUE_6,-9871233)
        OR NVL(fcst.VALUE_7,-9871233) <> NVL(base.VALUE_7,-9871233)
        OR NVL(fcst.VALUE_8,-9871233) <> NVL(base.VALUE_8,-9871233)
        OR NVL(fcst.VALUE_9,-9871233) <> NVL(base.VALUE_9,-9871233)
        OR NVL(fcst.TEXT_1,'XYXX') <> NVL(base.TEXT_1,'XYXX')
        OR NVL(fcst.TEXT_2,'XYXX') <> NVL(base.TEXT_2,'XYXX')
		-- Item 128753 Begin
        --OR NVL(fcst.TEXT_3,'XYXX') <> NVL(base.TEXT_3,'XYXX')
		-- Item 128753 End
        OR NVL(fcst.TEXT_4,'XYXX') <> NVL(base.TEXT_4,'XYXX')
        OR NVL(fcst.TEXT_5,'XYXX') <> NVL(base.TEXT_5,'XYXX')
        OR NVL(fcst.TEXT_6,'XYXX') <> NVL(base.TEXT_6,'XYXX')
        OR NVL(fcst.TEXT_7,'XYXX') <> NVL(base.TEXT_7,'XYXX')
        OR NVL(fcst.TEXT_8,'XYXX') <> NVL(base.TEXT_8,'XYXX')
        OR NVL(fcst.TEXT_9,'XYXX') <> NVL(base.TEXT_9,'XYXX')
        OR NVL(fcst.TEXT_10,'XYXX') <> NVL(base.TEXT_10,'XYXX')
        OR NVL(fcst.TEXT_11,'XYXX') <> NVL(base.TEXT_11,'XYXX')
        OR NVL(fcst.TEXT_12,'XYXX') <> NVL(base.TEXT_12,'XYXX')
        OR NVL(fcst.TEXT_13,'XYXX') <> NVL(base.TEXT_13,'XYXX')
        OR NVL(fcst.TEXT_14,'XYXX') <> NVL(base.TEXT_14,'XYXX')
        OR NVL(fcst.TEXT_15,'XYXX') <> NVL(base.TEXT_15,'XYXX')
        OR NVL(fcst.DATE_1,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.DATE_1,to_date('01-JAN-1900','DD-MON-YYYY'))
        OR NVL(fcst.DATE_2,to_date('01-JAN-1900','DD-MON-YYYY')) <> NVL(base.DATE_2,to_date('01-JAN-1900','DD-MON-YYYY'))
    );

BEGIN
    FOR item IN parcels LOOP
        RAISE_APPLICATION_ERROR(-20854, 'This scenario is attempting to make changes to one or more cargoes that are under Marine operational control and cannot be published');
    END LOOP;
END ValidateAffectedCargoes;

PROCEDURE SynchronizeMessageDistribution(p_forecast_id VARCHAR2, p_approval_status VARCHAR2, p_message_context VARCHAR2 DEFAULT 'LIFTING_PROGRAM')
IS
    v_message_distribution_no NUMBER;
    v_forecast_type VARCHAR2(32);
    v_fc_class_name VARCHAR2(32) := ecdp_objects.getObjClassName(p_forecast_id);

    CURSOR get_message_distribution (cv_forecast_id VARCHAR2) IS
    SELECT message_distribution_no, parameter_name, parameter_value, parameter_type, parameter_sub_type
    FROM tv_message_distr_param
    WHERE (    (p_message_context = 'LIFTING_PROGRAM' AND (parameter_name = 'Lifting Program' OR parameter_name = 'Domgas Delivery Plan'))
            OR (p_message_context <> 'LIFTING_PROGRAM' AND (parameter_name = 'Reference Entitlements' OR parameter_name = 'Domgas Entitlements'))
          ) -- SWGN [102457]: Added Domgas Delivery Plan/Entitlements
    AND parameter_value = p_forecast_id;

BEGIN

    IF (p_message_context = 'LIFTING_PROGRAM') THEN
        v_forecast_type := ec_forecast_version.text_6(p_forecast_id, ec_forecast.start_date(p_forecast_id), '<=');
    END IF;

    -- Remove all references to it in message distribution:
    FOR item IN get_message_distribution(p_forecast_id) LOOP
        v_message_distribution_no := item.message_distribution_no;
    END LOOP;

    IF v_message_distribution_no IS NOT NULL THEN
        DELETE FROM dv_message_distr_conn WHERE message_distribution_no = v_message_distribution_no;
        DELETE FROM tv_message_distr_param WHERE message_distribution_no = v_message_distribution_no;
        DELETE FROM dv_message_distribution WHERE message_distribution_no = v_message_distribution_no;
    END IF;

    -- If the message is approved, set up the message distribution
    IF (p_approval_status = 'V') THEN

        v_message_distribution_no := EcDp_System_Key.assignNextNumber('MESSAGE_DISTRIBUTION');

        IF (p_message_context = 'LIFTING_PROGRAM') THEN

            IF (v_forecast_type = 'CARGO_REQS' AND v_fc_class_name = 'FORECAST_TRAN_CP') THEN

                INSERT INTO dv_message_distribution (OBJECT_CODE, FORMAT_CODE, MESSAGE_DISTRIBUTION_NO)
                VALUES ('MSG_CARGO_REQS', 'XML', v_message_distribution_no);

                INSERT INTO tv_message_distr_param (MESSAGE_DISTRIBUTION_NO, PARAMETER_NAME, PARAMETER_VALUE, PARAMETER_TYPE, PARAMETER_SUB_TYPE)
                VALUES (v_message_distribution_no, 'Lifting Program', p_forecast_id, 'EC_OBJECT_TYPE', 'FORECAST_TRAN_CP');

                INSERT INTO dv_message_distr_conn (MESSAGE_DISTRIBUTION_NO, DISTR_SET_CODE)
                VALUES (v_message_distribution_no, 'DS_CARGO_REQS');

            ELSIF ((v_forecast_type = 'PADP' OR v_forecast_type = 'R_ADP' OR v_forecast_type = 'ADP' OR v_forecast_type = 'SDS' )  AND v_fc_class_name = 'FORECAST_TRAN_CP') THEN --TLXT: ITEM: 95825: Add new Scenario type R_ADP

                INSERT INTO dv_message_distribution (OBJECT_CODE, FORMAT_CODE, MESSAGE_DISTRIBUTION_NO)
                VALUES (DECODE(v_forecast_type, 'PADP', 'MSG_PADP','R_ADP', 'MSG_RADP', 'ADP', 'MSG_ADP', 'MSG_SDS'), 'XML', v_message_distribution_no);

                INSERT INTO tv_message_distr_param (MESSAGE_DISTRIBUTION_NO, PARAMETER_NAME, PARAMETER_VALUE, PARAMETER_TYPE, PARAMETER_SUB_TYPE)
                VALUES (v_message_distribution_no, 'Lifting Program', p_forecast_id, 'EC_OBJECT_TYPE', 'FORECAST_TRAN_CP');

                INSERT INTO dv_message_distr_conn (MESSAGE_DISTRIBUTION_NO, DISTR_SET_CODE)
                VALUES (v_message_distribution_no, 'DS_LIFTING_PROGRAM');

            ELSIF ((v_forecast_type = 'DGAF' OR v_forecast_type = 'PDGAF' OR v_forecast_type = 'DG_EST' OR v_forecast_type = 'R_DGAF') AND v_fc_class_name = 'FORECAST_TRAN_FC') THEN --SWGN: ITEM: 102457: Add new Scenario type DGAF/PDGAF

                INSERT INTO dv_message_distribution (OBJECT_CODE, FORMAT_CODE, MESSAGE_DISTRIBUTION_NO)
                VALUES ('MSG_DG_PLAN', 'XML', v_message_distribution_no);

                INSERT INTO tv_message_distr_param (MESSAGE_DISTRIBUTION_NO, PARAMETER_NAME, PARAMETER_VALUE, PARAMETER_TYPE, PARAMETER_SUB_TYPE)
                VALUES (v_message_distribution_no, 'Domgas Delivery Plan', p_forecast_id, 'EC_OBJECT_TYPE', 'FORECAST_TRAN_FC');

                INSERT INTO dv_message_distr_conn (MESSAGE_DISTRIBUTION_NO, DISTR_SET_CODE)
                VALUES (v_message_distribution_no, 'DS_DOMGAS_PLAN');

            END IF;

        ELSIF (p_message_context = 'REF_ENTS') THEN

            INSERT INTO dv_message_distribution (OBJECT_CODE, FORMAT_CODE, MESSAGE_DISTRIBUTION_NO)
            VALUES ('MSG_REF_ENTS', 'XML', v_message_distribution_no);

            INSERT INTO tv_message_distr_param (MESSAGE_DISTRIBUTION_NO, PARAMETER_NAME, PARAMETER_VALUE, PARAMETER_TYPE, PARAMETER_SUB_TYPE)
            VALUES (v_message_distribution_no, 'Reference Entitlements', p_forecast_id, CASE WHEN v_fc_class_name IS NOT NULL THEN 'EC_OBJECT_TYPE' ELSE 'BASIC_TYPE' END, NVL(v_fc_class_name, 'Reference Entitlements'));

            INSERT INTO dv_message_distr_conn (MESSAGE_DISTRIBUTION_NO, DISTR_SET_CODE)
            VALUES (v_message_distribution_no, 'DS_REF_ENTS');

        ELSIF (p_message_context = 'DG_REF_ENTS') THEN

            INSERT INTO dv_message_distribution (OBJECT_CODE, FORMAT_CODE, MESSAGE_DISTRIBUTION_NO)
            VALUES ('MSG_DG_REF_ENTS', 'XML', v_message_distribution_no);

            INSERT INTO tv_message_distr_param (MESSAGE_DISTRIBUTION_NO, PARAMETER_NAME, PARAMETER_VALUE, PARAMETER_TYPE, PARAMETER_SUB_TYPE)
            VALUES (v_message_distribution_no, 'Domgas Entitlements', p_forecast_id, CASE WHEN v_fc_class_name IS NOT NULL THEN 'EC_OBJECT_TYPE' ELSE 'BASIC_TYPE' END, NVL(v_fc_class_name, 'Domgas Entitlements'));

            INSERT INTO dv_message_distr_conn (MESSAGE_DISTRIBUTION_NO, DISTR_SET_CODE)
            VALUES (v_message_distribution_no, 'DS_DOMGAS_PLAN');

        END IF;
    END IF;

    RETURN;
END SynchronizeMessageDistribution;

PROCEDURE UpdateChildApprovalStatus(p_forecast_id VARCHAR2, p_old_status VARCHAR2, p_new_status VARCHAR2, p_user_id VARCHAR2)
IS
    ln_access_level     NUMBER;
    v_dummy_count       NUMBER;
    v_records           noms_type;
    l_invalidNom_count  NUMBER;
    v_object_id         VARCHAR2(30);
    l_error_message     VARCHAR2(200);
    l_error_exists      BOOLEAN;
    l_invalidNom_list   VARCHAR2(8000); --Used to hold a lift of nomination reference lifting number that are invalid. Reference Lifting Number is 10 digitis, so this will give us 400 noms.
    lv_obj_start_date DATE;

    lv_berth VARCHAR2(32);
    lv_count NUMBER;

    CURSOR c_getLCNumWithoutCargoNumber (p_ForecastID VARCHAR2) IS
      SELECT reference_lifting_no FROM dv_fcst_stor_lift_nom WHERE forecast_id = p_ForecastID AND cargo_no IS NULL;

    CURSOR c_getLCNumNotValidated (p_ForecastID VARCHAR2) IS
      SELECT reference_lifting_no FROM dv_fcst_stor_lift_nom  a WHERE forecast_id = p_ForecastID AND (NOM_VALID IS NULL OR NOM_VALID = 'N')
and instr(UE_CT_TRAN_CP_PRES_SYNTAX.GETNOMVALIDATIONRESULTS(a.reference_lifting_no, a.LIFTING_ACCOUNT_ID, a.FORECAST_ID),'showstopper') >0; /*--KOIJ*/

      CURSOR C_EXCESS_CARGOES (p_ForecastID VARCHAR2) IS
      SELECT OBJECT_ID, NOM_DATE,CARGO_NO, SUM(NOM_GRS_VOL) AS TOT_GRS_VOL
      FROM dv_fcst_stor_lift_nom
      WHERE forecast_id = p_ForecastID AND EXCESS_LIFTING_IND = 'Y' AND NVL(EXCESS_LIFTING_APP_IND,'N') = 'N'
      group by OBJECT_ID, NOM_DATE,CARGO_NO;


BEGIN

    l_error_exists := FALSE;
    lv_obj_start_date := EC_FORECAST.START_DATE(p_forecast_id);

    -- Changed from <= to <; this allows for the emergency de-berth procedure to be properly handled
--TLXT: 25-NOV-2015:
--A flag to facilitate creation of scenarios prior to system date for testing purposes. there u go
    IF NVL(EC_CTRL_SYSTEM_ATTRIBUTE.attribute_text(ec_forecast.start_date(p_forecast_id),'ENABLE_CP_SCEN_DATE_VAL','<='),'Y') = 'Y' THEN
        IF (ec_forecast.start_date(p_forecast_id) < trunc(ecdp_date_time.getcurrentsysdate, 'DD')) THEN
            RAISE_APPLICATION_ERROR(-20767, 'Scenarios cannot be created or published if their start date is before the current system date.');
        END IF;
    END IF;
  --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_FORECAST_TRAN_CP', 'UpdateChildApprovalStatus ' ||p_forecast_id);
--TLXT: 03-MAR-2015: Item:95635. To commented off the generate cargo no
    --TLXT: DEFECT ID 95.
        --defect id 95
        --need to generate the cargo when verifiying
--        SELECT * BULK COLLECT INTO v_records
--        FROM DV_FCST_STOR_LIFT_NOM A
--        WHERE forecast_id = p_forecast_id
--        AND cargo_no IS NULL
--        AND ec_forecast_version.text_6(p_forecast_id, A.NOM_DATE, '<=') IN ('ADP','SDS','EX_SDS','PADP')
--        ORDER BY NOM_DATE_TIME;


--        FOR cur_gen IN 1 ..  v_records.count LOOP
--             UE_CARGO_FCST_TRANSPORT.CONNECTNOMTOCARGO(v_records(cur_gen).cargo_no,'(' || v_records(cur_gen).parcel_no || ')',v_records(cur_gen).forecast_id);
              --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_FORECAST_TRAN_CP', 'cargo_no ' ||v_records(cur_gen).cargo_no || ' PARCEL_NO=' || v_records(cur_gen).parcel_no || ' FORECAST_ID='||v_records(cur_gen).forecast_id );
--        END LOOP;
    --END EDIT
--END EDIT TLXT: 03-MAR-2015
--TEXT_6 = SCENARIO_TYPE: R_ADP, PADP, ADP, CARGO_REQS, AD_HOC, PLP, SDS
    SELECT COUNT(*) INTO v_dummy_count
    FROM dv_fcst_stor_lift_nom
    WHERE forecast_id = p_forecast_id
    AND cargo_no IS NULL
    AND ec_forecast_version.text_6(p_forecast_id, lv_obj_start_date, '<=') IN ('ADP','SDS','R_ADP','PLP');

    IF (v_dummy_count > 0) THEN
        RAISE_APPLICATION_ERROR(-20766, 'Cannot verify scenario unless all nominations have been assigned to cargoes.');
    END IF;

--this will be trigger if update is on this View.
--the Workflow should always update directly into the based table
--IF p_user_id = 'tlxt' THEN
    -- Get the current user's level of permission to the cargo planning forecast screen
    SELECT max(AC.LEVEL_ID) INTO ln_access_level
    FROM T_BASIS_USERROLE UR
    INNER JOIN T_BASIS_ACCESS AC
    ON UR.ROLE_ID = AC.ROLE_ID
    AND UR.APP_ID = AC.APP_ID
    WHERE UR.USER_ID = p_user_id
--tlxt: implemented a new project screen :22002 to replace the existing Cargo Planning screen on 26-Feb-2013
--    AND AC.OBJECT_ID = 10112;
    AND AC.OBJECT_ID = 22002;

    --there should be no accees for any user to update the record status from V to A. This should be done thru the Workflow system
    IF (p_new_status = 'A' and ln_access_level < 60) OR
        (p_new_status = 'V' and ln_access_level < 50) OR
        (p_new_status = 'P' and ln_access_level < 40) THEN
        raise_application_error(-20752, 'Your access level is not high enough to move this scenario to that approval status.');
        RETURN; -- Sanity
    END IF;

    IF (p_old_status = 'V' and ln_access_level < 50) OR --only level 60 is allow to change the status from V to A
        (p_old_status = 'P' and ln_access_level < 40) THEN
        raise_application_error(-20753, 'Your access level is not high enough to alter the approval status of this scenario.');
        RETURN; -- Sanity
    END IF;

    IF p_old_status = 'P' and p_new_status = 'A' THEN
        raise_application_error(-20754, 'The scenario must be verified before it can be approved.');
    END IF;

    --TLXT 11-MAR-2015 TFS ITEM: 95826
    --to handle From (V or A)  to P. Null is not a valid scenario
    IF p_old_status <> 'P' and p_new_status = 'P' AND ec_forecast_version.text_6(p_forecast_id, lv_obj_start_date, '<=') <> 'PLP' THEN
        raise_application_error(-20755, 'A non-provisional scenario cannot be set to provisional status.');
    END IF;

    IF p_old_status = 'A' and p_new_status <> 'A' THEN
        raise_application_error(-20756, 'An approved scenario cannot be unapproved.');
    END IF;

    --TLXT 11-MAR-2015 TFS ITEM: 95826
    --Status from V to A or from V to P is only applicable thru workflow
    IF p_old_status = 'V' and p_new_status = 'P' AND ec_forecast_version.text_6(p_forecast_id, lv_obj_start_date, '<=') <> 'PLP' THEN
        raise_application_error(-20757, 'A verified scenario cannot be unverified through screen.');
    END IF;

    --TLXT 11-MAR-2015 TFS ITEM: 95826
    IF p_old_status = 'V' and p_new_status = 'A' AND ec_forecast_version.text_6(p_forecast_id, lv_obj_start_date, '<=') <> 'PLP' THEN
        raise_application_error(-20758, 'A verified scenario cannot be approved through screen.');
    END IF;
    --END EDIT TLXT 11-MAR-2015 TFS ITEM: 95826

   --EQYP 10/NOV/2014 TFS Item 90536
   --Prevent scenario promotoion from P to A when scenario nominations are not validated.
   -- Check if we have invlaid nominations, if so generate a list of the invalid lifting numbers and display to lifter
    IF p_old_status = 'P' and p_new_status = 'V' THEN
      l_invalidNom_count := 0;
      l_invalidNom_list := NULL;

    --Check if all the nomination have an associated cargo number
      SELECT NVL(COUNT(reference_lifting_no),0) INTO l_invalidNom_count FROM dv_fcst_stor_lift_nom WHERE forecast_id = p_forecast_id AND cargo_no IS NULL;

      IF(l_invalidNom_count > 0) THEN

          l_error_exists := TRUE;
          l_error_message :='The following nominations have no cargo number:' || chr(10);

          ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_FORECAST_TRAN_CP',  l_error_message);

          FOR item IN c_getLCNumWithoutCargoNumber(p_forecast_id) LOOP
             l_invalidNom_list :=  item.reference_lifting_no || ',' || l_invalidNom_list;
          END LOOP;

      END IF;

     l_invalidNom_count := 0;
    --Check if all the nominations have been verified.
      SELECT NVL(COUNT(reference_lifting_no),0) INTO l_invalidNom_count FROM dv_fcst_stor_lift_nom a WHERE forecast_id = p_forecast_id AND (NOM_VALID IS NULL OR NOM_VALID = 'N')
and instr(UE_CT_TRAN_CP_PRES_SYNTAX.GETNOMVALIDATIONRESULTS(a.reference_lifting_no, a.LIFTING_ACCOUNT_ID, a.FORECAST_ID),'showstopper') >0; /*--KOIJ*/

      IF(l_invalidNom_count > 0) THEN

          l_error_exists := TRUE;

          FOR item IN c_getLCNumNotValidated(p_forecast_id) LOOP
             l_invalidNom_list := item.reference_lifting_no || ',' || l_invalidNom_list;
          END LOOP;

          l_error_message := l_error_message || 'The following nominations are invalid:';
            ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_FORECAST_TRAN_CP',  l_error_message);

        END IF;
    END IF;

    IF( l_error_exists = TRUE ) THEN

      l_error_message :=  'Can not promote scenario, ' || ECDP_OBJECTS.GETOBJNAME(p_forecast_id, lv_obj_start_date) || chr(10) || l_error_message || CHR(10);
      raise_application_error(-20760, l_error_message  || l_invalidNom_list || chr(10));

      RETURN;
        END IF;
        --End TFS 90536

    --TLXT 14-APR-2015 TFS ITEM: 96540: CP - interface - PLP Scenario type write data when verified to CPP
    IF (NVL(ec_forecast_version.text_6(p_forecast_id, lv_obj_start_date, '<='),'OH MIAN') = 'PLP') THEN
        IF p_old_status = 'P' and p_new_status = 'V' THEN
            FOR EXCESS_CARGOES IN C_EXCESS_CARGOES(p_forecast_id) LOOP
                ue_ct_cpp_eqm.createNewExcessQtyNoms(p_forecast_id, EXCESS_CARGOES.NOM_DATE, EXCESS_CARGOES.CARGO_NO, EXCESS_CARGOES.TOT_GRS_VOL , ecdp_context.getAppUser);
            END LOOP;
        END IF;
        IF p_old_status = 'V' and p_new_status = 'P' THEN
            UPDATE ov_forecast_tran_cp
            SET fcst_stor_fcast_src = 'PROD_PLAN_FCAST', --tlxt: 99491
                   last_updated_by = ecdp_context.getAppUser, last_updated_date = lv_obj_start_date
            WHERE object_id = p_forecast_id;
        END IF;

    END IF; --END TFS: 96540

    IF     (NVL(ec_forecast_version.text_6(p_forecast_id, lv_obj_start_date, '<='),'OH MIAN') = 'ADP') OR
        (NVL(ec_forecast_version.text_6(p_forecast_id, lv_obj_start_date, '<='),'OH MIAN') = 'SDS') OR
        (NVL(ec_forecast_version.text_6(p_forecast_id, lv_obj_start_date, '<='),'OH MIAN') = 'R_ADP') THEN

        IF p_old_status = 'P' and p_new_status = 'V' THEN

            lv_count := 0 ;

            SELECT COUNT(DISTINCT(OBJECT_ID)) INTO lv_count FROM OV_BERTH  ;

            IF lv_count = 1 THEN
                SELECT DISTINCT(OBJECT_ID) INTO lv_berth FROM OV_BERTH  ;
            ELSE
                lv_berth := NULL;
            END IF;

            UPDATE cargo_fcst_transport
            SET BERTH_ID = lv_berth
            WHERE forecast_id = p_forecast_id AND
            BERTH_ID IS NULL;

        --Item 112302: Begin
            UPDATE cargo_fcst_transport
            SET cargo_status = 'O'
            WHERE forecast_id = p_forecast_id AND
            cargo_status = 'T';
        --Item 112302: End

        END IF;

    END IF;

    IF p_old_status = p_new_status THEN
        RETURN;
    END IF;


--run update all other related table
   UpdateTableStatus(p_forecast_id , p_old_status , p_new_status , p_user_id );

    IF p_new_status <> 'P' THEN
        LockProductionForecast(p_forecast_id);
    END IF;

--END IF;
 --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_FORECAST_TRAN_CP', 'end by ' ||p_user_id);

END UpdateChildApprovalStatus;
PROCEDURE UpdateETAETD_Locked(p_forecast_id VARCHAR2, p_old_status VARCHAR2, p_new_status VARCHAR2, p_user_id VARCHAR2)
IS


    lv_obj_start_date DATE;




    CURSOR c_getETAETD (p_ForecastID VARCHAR2) IS
      SELECT eta, etd, object_id, reference_lifting_no, parcel_no FROM dv_fcst_stor_lift_nom WHERE forecast_id = p_ForecastID  and ec_forecast_version.text_6(p_forecast_id, EC_FORECAST.START_DATE(p_forecast_id), '<=') IN ('ADP','SDS','R_ADP','PADP') ;

BEGIN

    /*********************************Task 113799 - Cargo ETA and ETD Verfification.Persist values when scenario is verified or approved*****************/
     IF (p_old_status = 'P' and p_new_status = 'V')   THEN


            FOR item_eta_etd IN c_getETAETD(p_forecast_id)
            LOOP


            UPDATE STOR_FCST_LIFT_NOM
            SET DATE_5 = item_eta_etd.eta,
                DATE_6 = item_eta_etd.etd
            WHERE forecast_id = p_forecast_id
             and object_id = item_eta_etd.object_id
             and parcel_no =item_eta_etd.parcel_no;


          END LOOP;


    END IF;
    /*******************************************************/

    IF p_old_status = p_new_status THEN
        RETURN;
    END IF;


END UpdateETAETD_Locked;

PROCEDURE LockProductionForecast(p_forecast_id VARCHAR2)
IS
    ld_start_date DATE;
    ld_end_date DATE;
    ln_status VARCHAR2(1);
    ln_fcst_stor_fcast_src FORECAST_VERSION.TEXT_10%TYPE;
    lv2_forecast_type VARCHAR2(32);
    lv2_scenario VARCHAR2(32);
BEGIN

  --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_FORECAST_TRAN_CP', 'LockProductionForecast 1 ');

    SELECT object_start_date, object_end_date, scen_approval_status, fcst_stor_fcast_src INTO ld_start_date, ld_end_date, ln_status, ln_fcst_stor_fcast_src
    FROM ov_forecast_tran_cp
    WHERE object_id = p_forecast_id
    AND daytime =
    (
            SELECT max(daytime)
            FROM ov_forecast_tran_cp
            WHERE object_id = p_forecast_id
    );

    IF ln_fcst_stor_fcast_src = 'PROD_PLAN_FCAST' THEN

        --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_FORECAST_TRAN_CP', 'LockProductionForecast 2 ' );

        MERGE INTO stor_day_fcst_fcast dest
        USING
        (
            SELECT gr.object_id AS storage_id,
                        gr.daytime,
                        UE_Stor_Fcst_Balance.calcDailyStorageProduction(gr.object_id, gr.forecast_id, gr.daytime) prod_qty
            FROM cv_fcst_storage_graph gr
            WHERE gr.forecast_id = p_forecast_id
        ) src
        ON
        (
            dest.object_id = src.storage_id
            AND dest.forecast_id = p_forecast_id
            AND dest.daytime = src.daytime
        )
        WHEN MATCHED THEN
            UPDATE SET dest.forecast_qty = src.prod_qty, last_updated_by = ecdp_context.getAppUser, last_updated_date = sysdate , record_status = ln_status
        WHEN NOT MATCHED THEN
            INSERT (dest.object_id, dest.daytime, dest.forecast_id, dest.forecast_qty, created_by, created_date, record_status)
            VALUES (src.storage_id, src.daytime, p_forecast_id, src.prod_qty, ecdp_context.getAppUser, sysdate, ln_status);


        UPDATE ov_forecast_tran_cp
        SET fcst_stor_fcast_src = 'TRAN_PCTR_FCAST', --tlxt: 99491: commented off prod_fcst_type = NULL, prod_fcst_scenario = NULL,
               last_updated_by = ecdp_context.getAppUser, last_updated_date = sysdate
        WHERE object_id = p_forecast_id;
    END IF;


END LockProductionForecast;

PROCEDURE UnlockProductionForecast(p_forecast_id VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL)
IS
BEGIN
--update all other related table status from V to P
--change the Daily Storage Forecase Status from V to P
    UpdateTableStatus(p_forecast_id , 'V' , 'P' , p_user_id );

--update the ov_forecast_tran_cp-->fcst_stor_fcast_src from TRAN_PCTR_FCAST to PROD_PLAN_FCAST--
    UPDATE FORECAST_VERSION
    SET TEXT_10 = decode(TEXT_10,'TRAN_PCTR_FCAST','PROD_PLAN_FCAST',NVL(TEXT_10,'PROD_PLAN_FCAST')),  --tlxt: 99491: commented off  TEXT_9 = NULL, TEXT_8 = NULL, REF_OBJECT_ID_1 = NULL, TEXT_5='P',
           last_updated_by = p_user_id, last_updated_date = sysdate
    WHERE object_id = p_forecast_id;


END UnlockProductionForecast;

PROCEDURE UpdateStatusFromWorkFlow(p_forecast_id VARCHAR2,p_new_status VARCHAR2,p_user_id VARCHAR2 DEFAULT NULL)
IS
BEGIN
    IF p_new_status = 'UNLOCK' THEN
        UnlockProductionForecast(p_forecast_id, p_user_id);
    END IF;

END UpdateStatusFromWorkFlow;

PROCEDURE UpdateTableStatus(p_forecast_id VARCHAR2, p_old_status VARCHAR2, p_new_status VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL)
IS
BEGIN
    -- Run the update

    -- STOR_DAY_FCST_FCAST
    UPDATE stor_day_fcst_fcast
    SET record_status = p_new_status, last_updated_by = p_user_id, last_updated_date = sysdate
    WHERE forecast_id = p_forecast_id;

    -- STOR_SUB_DAY_FCST_FCAST
    UPDATE stor_sub_day_fcst_fcast
    SET record_status = p_new_status, last_updated_by = p_user_id, last_updated_date = sysdate
    WHERE forecast_id = p_forecast_id;

    -- STOR_MTH_FCST_PC_FCAST
    UPDATE stor_mth_fcst_pc_fcast
    SET record_status = p_new_status, last_updated_by = p_user_id, last_updated_date = sysdate
    WHERE forecast_id = p_forecast_id;

    -- LIFT_ACC_DAY_FCST_FCAST
    UPDATE lift_acc_day_fcst_fcast
    SET record_status = p_new_status, last_updated_by = p_user_id, last_updated_date = sysdate
    WHERE forecast_id = p_forecast_id;

    -- LIFT_ACC_SUB_DAY_FCST_FC
    UPDATE lift_acc_sub_day_fcst_fc
    SET record_status = p_new_status, last_updated_by = p_user_id, last_updated_date = sysdate
    WHERE forecast_id = p_forecast_id;

    -- CARGO_FCST_TRANSPORT
    UPDATE cargo_fcst_transport
    SET record_status = p_new_status, last_updated_by = p_user_id, last_updated_date = sysdate
    WHERE forecast_id = p_forecast_id;

    -- STOR_FCST_LIFT_NOM
    UPDATE stor_fcst_lift_nom
    SET record_status = p_new_status, last_updated_by = p_user_id, last_updated_date = sysdate
    WHERE forecast_id = p_forecast_id;

    --TLXT: 99708: 02-JUL-2015: check monthly adjustment class for setting to approve trading data upon adp approval
    UPDATE DV_LIFT_ACCOUNT_ADJUSTMENT
    SET RECORD_STATUS = p_new_status, LAST_UPDATED_BY =EcDp_Context.getAppUser, LAST_UPDATED_DATE = SYSDATE
    WHERE DAYTIME BETWEEN EC_FORECAST.START_DATE(p_forecast_id) AND EC_FORECAST.END_DATE(p_forecast_id)
    AND EC_FORECAST_VERSION.TEXT_6(p_forecast_id,SYSDATE,'<=') = 'ADP';


END UpdateTableStatus;

PROCEDURE UpdateREStatusFrWorkFlow(p_forecast_id VARCHAR2,p_new_status VARCHAR2,p_user_id VARCHAR2 DEFAULT NULL)
IS
BEGIN
    IF p_new_status = 'REJECT' THEN
        UpdateRefEntStatus(p_forecast_id, 'V','P',p_user_id);
    END IF;

END UpdateREStatusFrWorkFlow;

PROCEDURE UpdateRefEntStatus(p_forecast_object_id VARCHAR2, p_old_status VARCHAR2, p_new_status VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL)
IS
    v_dummy_count NUMBER;

BEGIN
--added by tlxt on 30-oct-2014
-- to update all Reference entitlement related classes when user change the record status in the Customized "Official" Lifting Program Calculation
-- this procedure will be called by a class trigger action in TV_CALC_TRAN_CP_FCST_LOG

--all validation should be done in the Class trigger action instead of in this package, hence we can update the classes directly
--validation ruiredi nhte class trigger action are as below:
--only allwos status changed from "P" to "V", "V" to "A", "A" to "V" "A" to "P"
--Not allow status change form ""P" to "A"
--Not allow to have more than ONE same Reference Entitlement to be promoted to "V" and above

    SELECT COUNT(*) INTO v_dummy_count
    FROM TV_CALC_TRAN_CP_FCST_LOG
    WHERE RECORD_STATUS <> 'P'
    AND ECDP_OBJECTS.GETOBJCODE(JOB_ID) = 'CT_WST_ADJ_REF_ENTITLEMENT'
    AND FORECAST_ID = p_forecast_object_id;

    IF (p_old_status = 'P' AND p_new_status = 'V' AND v_dummy_count > 0) THEN
        RAISE_APPLICATION_ERROR(-20779, 'Cannot re-verify a record which was already verified');
    END IF;
--tlxt: work item: 110100
    IF (p_old_status = 'P' AND p_new_status = 'A') THEN
        RAISE_APPLICATION_ERROR(-20754, 'Cannot Promote a record from Provisional to Approved');
    END IF;



    --DEMOTE
    IF (p_old_status = 'V' AND p_new_status = 'P') OR (p_old_status = 'A' AND p_new_status = 'V') OR (p_old_status = 'A' AND p_new_status = 'P') THEN
        UPDATE ALLOC_JOB_LOG
        SET RECORD_STATUS = p_new_status, ACCEPT_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
        WHERE CLASS_NAME = 'CALC_TRAN_CP_FCST_LOG'
        AND CALC_REF_OBJECT_ID_2 = p_forecast_object_id
        AND RECORD_STATUS <> 'P'
        AND ECDP_OBJECTS.GETOBJCODE(JOB_ID) = 'CT_WST_ADJ_REF_ENTITLEMENT';
    END IF;

    --PROMOTE
    IF (p_old_status = 'V' AND p_new_status = 'A') THEN
        UPDATE ALLOC_JOB_LOG
        SET RECORD_STATUS = p_new_status, ACCEPT_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
        WHERE CLASS_NAME = 'CALC_TRAN_CP_FCST_LOG'
        AND CALC_REF_OBJECT_ID_2 = p_forecast_object_id
        AND RECORD_STATUS = 'V'
        AND ECDP_OBJECTS.GETOBJCODE(JOB_ID) = 'CT_WST_ADJ_REF_ENTITLEMENT';
    END IF;



    -- Run the update
    UPDATE DV_CT_LA_MTH_PC_REF_ENT
    SET RECORD_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
    WHERE FORECAST_OBJECT_ID = p_forecast_object_id
    AND RECORD_STATUS <> p_new_status;

    UPDATE DV_CT_LA_YR_PC_REF_ENT
    SET RECORD_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
    WHERE FORECAST_OBJECT_ID = p_forecast_object_id
    AND RECORD_STATUS <> p_new_status;

    UPDATE DV_CT_PROD_STRM_PC_FORECAST
    SET RECORD_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
    WHERE FORECAST_OBJECT_ID = p_forecast_object_id
    AND RECORD_STATUS <> p_new_status;

    UPDATE DV_CT_PROD_STRM_FORECAST
    SET RECORD_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
    WHERE FORECAST_OBJECT_ID = p_forecast_object_id
    AND RECORD_STATUS <> p_new_status;

    UPDATE OV_CT_PROD_FORECAST
    SET RECORD_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
    WHERE OBJECT_ID = p_forecast_object_id
    AND RECORD_STATUS <> p_new_status;
END UpdateRefEntStatus;

PROCEDURE UpdateReCalcRefEnt(p_forecast_object_id VARCHAR2, p_old_status VARCHAR2, p_new_status VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL,p_company_id VARCHAR2 DEFAULT NULL)
IS
    v_dummy_count NUMBER;
    v_lifting_account VARCHAR2(32);

BEGIN
--added by tlxt on 17-Nov-2014
-- to update all Re-calculate Reference entitlement related classes when user change the record status in the Customized "Official" Lifting Program Calculation
-- this procedure will be called by a class trigger action in TV_CALC_TRAN_CP_FCST_LOG

--all validation should be done in the Class trigger action instead of in this package, hence we can update the classes directly
--validation ruiredi nhte class trigger action are as below:
--only allwos status changed from "P" to "V", "V" to "A", "A" to "V".
--Not allow status change form "A" to "P" or "P" to "A"
--Not allow to have more than ONE same Reference Entitlement to be promoted to "V" and above

--TLXT: 101282: allow to verify for more than a record

    SELECT COUNT(*) INTO v_dummy_count
    FROM TV_CALC_TRAN_CP_FCST_LOG
    WHERE RECORD_STATUS <> 'P'
    AND ECDP_OBJECTS.GETOBJCODE(JOB_ID) = 'CT_WST_RC_REF_ENTITLEMENT'
    AND FORECAST_ID = p_forecast_object_id;
    --AND (p_company_id IS NULL OR COMPANY_ID = p_company_id);

    IF (p_old_status = 'P' AND p_new_status = 'V' AND v_dummy_count > 0) THEN
        RAISE_APPLICATION_ERROR(-20779, 'Cannot re-verify a record which was already verified');
    END IF;
--tlxt: work item: 110100
    IF (p_old_status = 'P' AND p_new_status = 'A') THEN
        RAISE_APPLICATION_ERROR(-20754, 'Cannot Promote a record from Provisional to Approved');
    END IF;

    --DEMOTE
    IF (p_old_status = 'V' AND p_new_status = 'P') OR (p_old_status = 'A' AND p_new_status = 'V') OR (p_old_status = 'A' AND p_new_status = 'P') THEN
        UPDATE ALLOC_JOB_LOG
        SET RECORD_STATUS = p_new_status, ACCEPT_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
        WHERE CLASS_NAME = 'CT_WST_RC_REF_ENTITLEMENT'
        AND CALC_REF_OBJECT_ID_2 = p_forecast_object_id
        AND (p_company_id IS NULL OR CALC_REF_OBJECT_ID_3 = NVL(p_company_id,'N'))
        AND RECORD_STATUS <> 'P'
        AND ECDP_OBJECTS.GETOBJCODE(JOB_ID) = 'CT_WST_RC_REF_ENTITLEMENT';
    END IF;

    --PROMOTE
    IF (p_old_status = 'V' AND p_new_status = 'A') THEN
        UPDATE ALLOC_JOB_LOG
        SET RECORD_STATUS = p_new_status, ACCEPT_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
        WHERE CLASS_NAME = 'CALC_TRAN_CP_FCST_LOG'
        AND CALC_REF_OBJECT_ID_2 = p_forecast_object_id
        AND RECORD_STATUS = 'V'
        AND ECDP_OBJECTS.GETOBJCODE(JOB_ID) = 'CT_WST_RC_REF_ENTITLEMENT';
    END IF;

    IF p_company_id IS NULL THEN
        v_lifting_account := NULL;
    ELSE
        SELECT OBJECT_ID INTO v_lifting_account FROM OV_LIFTING_ACCOUNT WHERE COMPANY_ID = p_company_id AND CONTRACT_CODE = 'C_WST_LNG'
        AND NVL(END_DATE, DAYTIME + 1) > DAYTIME;
    END IF;

    -- Run the update
    UPDATE DV_CT_LA_MTH_PC_REF_ENT
    SET RECORD_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
    WHERE FORECAST_OBJECT_ID = p_forecast_object_id
    AND (v_lifting_account IS NULL OR v_lifting_account = OBJECT_ID )
    AND RECORD_STATUS <> p_new_status;

    UPDATE DV_CT_LA_YR_PC_REF_ENT
    SET RECORD_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
    WHERE FORECAST_OBJECT_ID = p_forecast_object_id
    AND (v_lifting_account IS NULL OR v_lifting_account = OBJECT_ID )
    AND RECORD_STATUS <> p_new_status;

    UPDATE DV_CT_PROD_STRM_PC_FORECAST
    SET RECORD_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
    WHERE FORECAST_OBJECT_ID = p_forecast_object_id
    AND RECORD_STATUS <> p_new_status;

    UPDATE DV_CT_PROD_STRM_FORECAST
    SET RECORD_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
    WHERE FORECAST_OBJECT_ID = p_forecast_object_id
    AND RECORD_STATUS <> p_new_status;

    UPDATE OV_CT_PROD_FORECAST
    SET RECORD_STATUS = p_new_status, LAST_UPDATED_BY =p_user_id, LAST_UPDATED_DATE = SYSDATE
    WHERE OBJECT_ID = p_forecast_object_id
    AND RECORD_STATUS <> p_new_status;


END UpdateReCalcRefEnt;


END UE_CT_FORECAST_TRAN_CP;
/