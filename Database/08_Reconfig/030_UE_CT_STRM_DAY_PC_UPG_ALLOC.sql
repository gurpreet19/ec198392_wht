create or replace PACKAGE UE_CT_STRM_DAY_PC_UPG_ALLOC
IS
-------------------------------------------------------------------------
--
-- Package Name: UE_CT_STRM_DAY_PC_UPG_ALLOC
-- Author: ULSE
-- Purpose: Functions for unconventional UPG allocation input
--
-- Date           Whom  Change Description
-- -----------    ----  ------------------------------------------
-- 12-apr-2018    gedv  Item 127642: ISWR02420: added CalcPartliftVol60F for conversion purposes
-- 15-MAY-2018    eseq  Item_127690: Modified the function GetPartialLiftedMassByDay,GetPartialLiftedEnergyByDay,GetPartialLiftedVolumeByDay
-- 24-May-2018    wvic  Item 127718: Added calculateVCF
-------------------------------------------------------------------------

FUNCTION UPGRatio(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING) RETURN NUMBER;

FUNCTION LNGRefProdEnergy(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING) RETURN NUMBER;

FUNCTION LNGRefProdVol(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING) RETURN NUMBER;

FUNCTION LNGExcessProdEnergy(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING) RETURN NUMBER;

FUNCTION LNGExcessProdVol(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING) RETURN NUMBER;

FUNCTION LNGRegasEnergy(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING) RETURN NUMBER;

FUNCTION LNGRegasVol(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING) RETURN NUMBER;

FUNCTION CompanyRatio(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING) RETURN NUMBER;

FUNCTION LiftingMass(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING) RETURN NUMBER;

FUNCTION GetPartialLiftedMassByCargo(p_cargo_no NUMBER, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING) RETURN NUMBER;

--Item 127690 Begin
--ESEQ: Commented below declaration to revised it as below: Changes has been done to allow to fetch split per liftings, instead on Per Company basis
--FUNCTION GetPartialLiftedMassByDay(p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING) RETURN NUMBER;
FUNCTION GetPartialLiftedMassByDay(p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING, p_reference_lifting_no STRING DEFAULT NULL) RETURN NUMBER;
--Item 127690 End

FUNCTION LiftingEnergy(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING) RETURN NUMBER;

FUNCTION GetPartialLiftedEnergyByCargo(p_cargo_no NUMBER, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING) RETURN NUMBER;

--Item 127690 Begin
--ESEQ: Commented below declaration to revised it as below: Changes has been done to allow to fetch split per liftings, instead on Per Company basis
--FUNCTION GetPartialLiftedEnergyByDay(p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING) RETURN NUMBER;
FUNCTION GetPartialLiftedEnergyByDay(p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING, p_reference_lifting_no STRING DEFAULT NULL) RETURN NUMBER;
--Item 127690 End

FUNCTION LiftingVol(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING) RETURN NUMBER;

FUNCTION GetPartialLiftedVolumeByCargo(p_cargo_no NUMBER, p_profit_centre_id STRING, p_company_id STRING) RETURN NUMBER;

--Item 127690 Begin
--ESEQ: Commented below declaration to revised it as below: Changes has been done to allow to fetch split per liftings, instead on Per Company basis
--FUNCTION GetPartialLiftedVolumeByDay(p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING) RETURN NUMBER;
FUNCTION GetPartialLiftedVolumeByDay(p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING, p_reference_lifting_no STRING DEFAULT NULL) RETURN NUMBER;
--Item 127690 End

FUNCTION LiftingPurgeCoolEnergy(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING) RETURN NUMBER;

FUNCTION NormalFlow(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING) RETURN STRING;

FUNCTION CalculateLiftVol60F(p_parcel_no NUMBER, p_cargo_no NUMBER) RETURN NUMBER;

FUNCTION LiftingVol60F(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING) RETURN NUMBER;

FUNCTION LiftingVolSTP(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING) RETURN NUMBER;

-- Item 127642 Begin
FUNCTION CalcPartliftVol60F(p_daytime DATE, p_profit_centre_id STRING, p_lifting_acct_id STRING, p_object_id STRING, p_parcel_no NUMBER, p_cargo NUMBER) RETURN NUMBER;
-- Item 127642 End

-- Item 127718 Begin
FUNCTION calculateVCF(p_cargo_no NUMBER) RETURN NUMBER;
-- Item 127718 End

END UE_CT_STRM_DAY_PC_UPG_ALLOC;
/

create or replace PACKAGE BODY UE_CT_STRM_DAY_PC_UPG_ALLOC
IS
-------------------------------------------------------------------------
--
-- Package Name: UE_CT_STRM_DAY_PC_UPG_ALLOC
-- Author: ULSE
-- Purpose: Functions for unconventional UPG allocation input
--
--
-- Date           Whom  Change Description
-- -----------    ----  ------------------------------------------
-- 21-NOV-2017    wvic  Item_125147: Incorporated change from LTI to handle NO_DATA_FOUND exceptions
-- 12-apr-2018    gedv  Item 127642: ISWR02420: added CalcPartliftVol60F for conversion purposes
-- 15-MAY-2018    eseq  Item_127690: Modified the code to handle when we have mulitple parcels for same campany for a Cargo,hence
-- 15-MAY-2018    eseq  Item_127690: Modified the function GetPartialLiftedMassByDay,GetPartialLiftedEnergyByDay,GetPartialLiftedVolumeByDay
-- 24-May-2018    wvic  Item 127718: Added calculateVCF
-------------------------------------------------------------------------

FUNCTION UPGRatio(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING)
RETURN NUMBER
IS

	CURSOR c_partial_cargos(cp_code VARCHAR2)
	IS
	  SELECT object_id, cargo_no
	  FROM   DV_STOR_DAY_EXPORT_STATUS
	  WHERE  daytime BETWEEN (p_daytime-1) AND (p_daytime)
	  AND object_code = cp_code
	  GROUP BY object_id, cargo_no
	  ORDER BY cargo_no ASC;

	-- Item 125147: Begin
	CURSOR c_ticket_no
    IS
      SELECT ticket_no FROM DV_STRM_OIL_BATCH_EVENT
      WHERE OBJECT_CODE = 'SW_GP_LNG_CARGO' AND PRODUCTION_DAY = p_daytime;
	-- Item 125147: End

 lv2_compressor_mode VARCHAR2(32);
 lv2_stream_code VARCHAR2(32);
 lv2_profit_centre_code VARCHAR2(32);
 lv2_fuel_flare_type VARCHAR(32);
 ln_ratio NUMBER;
 ln_t1_cp_throu NUMBER;
 ln_t2_cp_throu NUMBER;
 ln_t3_cp_throu NUMBER;
 ln_wi_mus_cp_throu NUMBER;
 ln_jb_mus_cp_throu NUMBER;
 ln_t1_cp_bypass NUMBER;
 ln_t2_cp_bypass NUMBER;
 ln_t3_cp_bypass NUMBER;
 ln_wi_mus_cp_bypass NUMBER;
 ln_jb_mus_cp_bypass NUMBER;
 ln_t1_cp_alloc NUMBER;
 ln_t2_cp_alloc NUMBER;
 ln_t3_cp_alloc NUMBER;
 ln_wi_mus_cp_alloc NUMBER;
 ln_jb_mus_cp_alloc NUMBER;

 ln_ticket_no NUMBER;
 ln_cargo_no NUMBER;
 ln_lifted_mass_total NUMBER;
 ln_lifted_split_upg NUMBER;
 ln_lifted_split_total NUMBER;
 ln_pc_mass_total NUMBER;
 ln_pc_mass_upg NUMBER;
 ln_bog_flare_mass NUMBER;
 ln_bog_flare_mass_upg NUMBER;
 ln_bog_flare_mass_adj NUMBER;

BEGIN
    --INITIALIZE VARIABLES
    lv2_profit_centre_code := ecdp_objects.getobjcode(p_profit_centre_id);
    lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    lv2_compressor_mode := ec_strm_reference_value.text_29(ecdp_objects.getobjidfromcode('STREAM','SW_PL_GCP_TOTAL_FUEL_GAS'), p_daytime, '<=');
    lv2_fuel_flare_type := ec_strm_reference_value.text_30(p_object_id, p_daytime, '<=');

    IF lv2_stream_code = 'SW_PL_T1_SEP_GAS' THEN
        ln_t1_cp_throu := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T1_CP_THROU'), p_daytime);
        ln_t1_cp_bypass := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T1_CP_BYPASS'), p_daytime);
        ln_t1_cp_alloc := ec_strm_day_alloc.net_mass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T1_SEP_GAS'),p_daytime);
        IF ln_t1_cp_throu + ln_t1_cp_bypass <> 0 THEN
            ln_t1_cp_throu := ln_t1_cp_alloc * ln_t1_cp_throu / (ln_t1_cp_throu + ln_t1_cp_bypass);
        ELSE
            ln_t1_cp_throu := 0;
        END IF;
        IF ln_t1_cp_alloc <> 0 THEN
            ln_ratio := ln_t1_cp_throu / ln_t1_cp_alloc;
            RETURN ln_ratio;
        ELSE
            RETURN 0;
        END IF;
    ELSIF lv2_stream_code = 'SW_PL_T2_SEP_GAS' THEN
        ln_t2_cp_throu := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T2_CP_THROU'), p_daytime);
        ln_t2_cp_bypass := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T2_CP_BYPASS'), p_daytime);
        ln_t2_cp_alloc := ec_strm_day_alloc.net_mass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T2_SEP_GAS'),p_daytime);
        IF ln_t2_cp_throu + ln_t2_cp_bypass <> 0 THEN
            ln_t2_cp_throu := ln_t2_cp_alloc * ln_t2_cp_throu / (ln_t2_cp_throu + ln_t2_cp_bypass);
        ELSE
            ln_t2_cp_throu := 0;
        END IF;
        IF ln_t2_cp_alloc <> 0 THEN
            ln_ratio := ln_t2_cp_throu / ln_t2_cp_alloc;
            RETURN ln_ratio;
        ELSE
            RETURN 0;
        END IF;
    ELSIF lv2_stream_code = 'SW_PL_T3_SEP_GAS' THEN
        ln_t3_cp_throu := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T3_CP_THROU'), p_daytime);
        ln_t3_cp_bypass := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T3_CP_BYPASS'), p_daytime);
        ln_t3_cp_alloc := ec_strm_day_alloc.net_mass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T3_SEP_GAS'),p_daytime);
        IF ln_t3_cp_throu + ln_t3_cp_bypass <> 0 THEN
            ln_t3_cp_throu := ln_t3_cp_alloc * ln_t3_cp_throu / (ln_t3_cp_throu + ln_t3_cp_bypass);
        ELSE
            ln_t3_cp_throu := 0;
        END IF;
        IF ln_t3_cp_alloc <> 0 THEN
            ln_ratio := ln_t3_cp_throu / ln_t3_cp_alloc;
            RETURN ln_ratio;
        ELSE
            RETURN 0;
        END IF;
    ELSIF lv2_stream_code = 'SW_PL_WST_MSEP_GAS' THEN
        ln_wi_mus_cp_throu := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WST_MU_CP_THROU'), p_daytime);
        ln_wi_mus_cp_bypass := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WST_MU_CP_BYPASS'), p_daytime);
        ln_wi_mus_cp_alloc := ec_strm_day_alloc.net_mass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WST_MSEP_GAS'),p_daytime);
        IF ln_wi_mus_cp_throu + ln_wi_mus_cp_bypass <> 0 THEN
            ln_wi_mus_cp_throu := ln_wi_mus_cp_alloc * ln_wi_mus_cp_throu / (ln_wi_mus_cp_throu + ln_wi_mus_cp_bypass);
        ELSE
            ln_wi_mus_cp_throu := 0;
        END IF;
        IF ln_wi_mus_cp_alloc <> 0 THEN
            ln_ratio := ln_wi_mus_cp_throu / ln_wi_mus_cp_alloc;
            RETURN ln_ratio;
        ELSE
            RETURN 0;
        END IF;
    ELSIF lv2_stream_code = 'SW_PL_WA356P_MSEP_GAS' THEN
        ln_jb_mus_cp_throu := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WA356P_MU_CP_THROU'), p_daytime);
        ln_jb_mus_cp_bypass := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WA356P_MU_CP_BYPASS'), p_daytime);
        ln_jb_mus_cp_alloc := ec_strm_day_alloc.net_mass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WA356P_MSEP_GAS'),p_daytime);
        IF ln_jb_mus_cp_throu + ln_jb_mus_cp_bypass <> 0 THEN
            ln_jb_mus_cp_throu := ln_jb_mus_cp_alloc * ln_jb_mus_cp_throu / (ln_jb_mus_cp_throu + ln_jb_mus_cp_bypass);
        ELSE
            ln_jb_mus_cp_throu := 0;
        END IF;
        IF ln_jb_mus_cp_alloc <> 0 THEN
            ln_ratio := ln_jb_mus_cp_throu / ln_jb_mus_cp_alloc;
            RETURN ln_ratio;
        ELSE
            RETURN 0;
        END IF;
    ELSIF lv2_stream_code = 'SW_PL_GCP1_FUEL_GAS' OR lv2_stream_code = 'SW_PL_GCP2_FUEL_GAS' OR lv2_stream_code = 'SW_PL_GCP1_ELEC' OR lv2_stream_code = 'SW_PL_GCP2_ELEC' THEN
        ln_t1_cp_throu := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T1_CP_THROU'), p_daytime);
        ln_t2_cp_throu := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T2_CP_THROU'), p_daytime);
        ln_t3_cp_throu := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T3_CP_THROU'), p_daytime);
        ln_wi_mus_cp_throu := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WST_MU_CP_THROU'), p_daytime);
        ln_jb_mus_cp_throu := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WA356P_MU_CP_THROU'), p_daytime);

        ln_t1_cp_bypass := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T1_CP_BYPASS'), p_daytime);
        ln_t2_cp_bypass := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T2_CP_BYPASS'), p_daytime);
        ln_t3_cp_bypass := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T3_CP_BYPASS'), p_daytime);
        ln_wi_mus_cp_bypass := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WST_MU_CP_BYPASS'), p_daytime);
        ln_jb_mus_cp_bypass := EcBp_Stream_Fluid.findNetStdMass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WA356P_MU_CP_BYPASS'), p_daytime);

        ln_t1_cp_alloc := ec_strm_day_alloc.net_mass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T1_SEP_GAS'),p_daytime);
        ln_t2_cp_alloc := ec_strm_day_alloc.net_mass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T2_SEP_GAS'),p_daytime);
        ln_t3_cp_alloc := ec_strm_day_alloc.net_mass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_T3_SEP_GAS'),p_daytime);
        ln_wi_mus_cp_alloc := ec_strm_day_alloc.net_mass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WST_MSEP_GAS'),p_daytime);
        ln_jb_mus_cp_alloc := ec_strm_day_alloc.net_mass(ecdp_objects.getobjidfromcode('STREAM','SW_PL_WA356P_MSEP_GAS'),p_daytime);

        --RECONCILE THROUGHPUT
        IF ln_t1_cp_throu + ln_t1_cp_bypass <> 0 THEN
            ln_t1_cp_throu := ln_t1_cp_alloc * ln_t1_cp_throu / (ln_t1_cp_throu + ln_t1_cp_bypass);
        ELSE
            ln_t1_cp_throu := 0;
        END IF;

        IF ln_t2_cp_throu + ln_t2_cp_bypass <> 0 THEN
            ln_t2_cp_throu := ln_t2_cp_alloc * ln_t2_cp_throu / (ln_t2_cp_throu + ln_t2_cp_bypass);
        ELSE
            ln_t2_cp_throu := 0;
        END IF;

        IF ln_t3_cp_throu + ln_t3_cp_bypass <> 0 THEN
            ln_t3_cp_throu := ln_t3_cp_alloc * ln_t3_cp_throu / (ln_t3_cp_throu + ln_t3_cp_bypass);
        ELSE
            ln_t3_cp_throu := 0;
        END IF;

        IF ln_wi_mus_cp_throu + ln_wi_mus_cp_bypass <> 0 THEN
            ln_wi_mus_cp_throu := ln_wi_mus_cp_alloc * ln_wi_mus_cp_throu / (ln_wi_mus_cp_throu + ln_wi_mus_cp_bypass);
        ELSE
            ln_wi_mus_cp_throu := 0;
        END IF;

        IF ln_jb_mus_cp_throu + ln_jb_mus_cp_bypass <> 0 THEN
            ln_jb_mus_cp_throu := ln_jb_mus_cp_alloc * ln_jb_mus_cp_throu / (ln_jb_mus_cp_throu + ln_jb_mus_cp_bypass);
        ELSE
            ln_jb_mus_cp_throu := 0;
        END IF;

        --CALCULATE RATIO
        IF lv2_compressor_mode = 'COMMON' THEN
            IF lv2_profit_centre_code = 'F_WST_IAGO' THEN
                IF ln_t1_cp_throu + ln_t2_cp_throu + ln_wi_mus_cp_throu + ln_t3_cp_throu + ln_jb_mus_cp_throu <> 0 THEN
                    ln_ratio := (ln_t1_cp_throu + ln_t2_cp_throu + ln_wi_mus_cp_throu) / (ln_t1_cp_throu + ln_t2_cp_throu + ln_wi_mus_cp_throu + ln_t3_cp_throu + ln_jb_mus_cp_throu);
                    RETURN ln_ratio;
                ELSE
                    RETURN 0;
                END IF;
            ELSIF lv2_profit_centre_code = 'F_JUL_BRU' THEN
                IF ln_t1_cp_throu + ln_t2_cp_throu + ln_wi_mus_cp_throu + ln_t3_cp_throu + ln_jb_mus_cp_throu <> 0 THEN
                    ln_ratio := (ln_t3_cp_throu + ln_jb_mus_cp_throu) / (ln_t1_cp_throu + ln_t2_cp_throu + ln_wi_mus_cp_throu + ln_t3_cp_throu + ln_jb_mus_cp_throu);
                    RETURN ln_ratio;
                ELSE
                    RETURN 0;
                END IF;
            ELSE
                RETURN 0;
            END IF;
        ELSIF lv2_compressor_mode = 'INDEPENDENT' THEN
            IF lv2_stream_code = 'SW_PL_GCP1_FUEL_GAS' OR lv2_stream_code = 'SW_PL_GCP1_ELEC' THEN
                IF lv2_profit_centre_code = 'F_WST_IAGO' THEN
                    IF ln_t1_cp_throu + ln_wi_mus_cp_throu + ln_jb_mus_cp_throu <> 0 THEN
                        ln_ratio := (ln_t1_cp_throu + ln_wi_mus_cp_throu) / (ln_t1_cp_throu + ln_wi_mus_cp_throu + ln_jb_mus_cp_throu);
                        RETURN ln_ratio;
                    ELSE
                        RETURN 0;
                    END IF;
                ELSIF lv2_profit_centre_code = 'F_JUL_BRU' THEN
                    IF ln_t1_cp_throu + ln_wi_mus_cp_throu + ln_jb_mus_cp_throu <> 0 THEN
                        ln_ratio := ln_jb_mus_cp_throu / (ln_t1_cp_throu + ln_wi_mus_cp_throu + ln_jb_mus_cp_throu);
                        RETURN ln_ratio;
                    ELSE
                        RETURN 0;
                    END IF;
                ELSE
                    RETURN 0;
                END IF;
            ELSIF lv2_stream_code = 'SW_PL_GCP2_FUEL_GAS'  OR lv2_stream_code = 'SW_PL_GCP2_ELEC' THEN
                IF lv2_profit_centre_code = 'F_WST_IAGO' THEN
                    IF ln_t2_cp_throu + ln_t3_cp_throu <> 0 THEN
                        ln_ratio := ln_t2_cp_throu / (ln_t2_cp_throu + ln_t3_cp_throu);
                        RETURN ln_ratio;
                    ELSE
                        RETURN 0;
                    END IF;
                ELSIF lv2_profit_centre_code = 'F_JUL_BRU' THEN
                    IF ln_t2_cp_throu + ln_t3_cp_throu <> 0 THEN
                        ln_ratio := ln_t3_cp_throu / (ln_t2_cp_throu + ln_t3_cp_throu);
                        RETURN ln_ratio;
                    ELSE
                        RETURN 0;
                    END IF;
                ELSE
                    RETURN 0;
                END IF;
            ELSE
                RETURN 0;
            END IF;

        ELSE
            RETURN 0;
        END IF;
    ELSIF lv2_fuel_flare_type = 'FIXED_LIFTING' AND lv2_stream_code <> 'SW_GP_BOG_FLR' THEN

		SELECT ec_strm_day_alloc.net_mass(p_object_id,p_daytime) into ln_lifted_mass_total from dual;

		IF ln_lifted_mass_total <> 0 THEN

		    -- Item 125147: Begin
			--SELECT TICKET_NO INTO ln_ticket_no FROM DV_STRM_OIL_BATCH_EVENT WHERE OBJECT_CODE = 'SW_GP_LNG_CARGO' AND PRODUCTION_DAY = p_daytime;
            FOR ticket IN c_ticket_no LOOP
                ln_ticket_no := ticket.ticket_no;
                ln_cargo_no := ln_ticket_no;
            END LOOP;
		    -- Item 125147: End

			IF ln_ticket_no IS NULL THEN

				FOR cargo IN c_partial_cargos('STW_LNG') LOOP

					ln_cargo_no := cargo.cargo_no;

				END LOOP;

			ELSE

				ln_cargo_no := ln_ticket_no;

			END IF;

			IF ln_cargo_no IS NULL THEN

				ln_ratio := 0;

			ELSE


				SELECT SUM(SPLIT_PCT/100) INTO ln_lifted_split_upg FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = ln_cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(CARGO_NO)) <> 'D';
				SELECT SUM(SPLIT_PCT/100) INTO ln_lifted_split_total FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = ln_cargo_no AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(CARGO_NO)) <> 'D';
				IF ln_lifted_split_total IS NULL OR ln_lifted_split_total = 0 THEN
					ln_ratio := null;
				ELSIF ln_lifted_split_upg IS NULL THEN
					ln_ratio := 0;
				ELSE
					ln_ratio := ln_lifted_split_upg / ln_lifted_split_total;
				END IF;

			END IF;
		ELSE

			RETURN null;

		END IF;

		RETURN ln_ratio;

    ELSIF lv2_fuel_flare_type = 'FIXED_LIFTING' AND lv2_stream_code = 'SW_GP_BOG_FLR' THEN

		SELECT ec_strm_day_alloc.net_mass(p_object_id,p_daytime) into ln_lifted_mass_total from dual;

		IF ln_lifted_mass_total <> 0 THEN

		    -- Item 125147: Begin
			--SELECT TICKET_NO INTO ln_ticket_no FROM DV_STRM_OIL_BATCH_EVENT WHERE OBJECT_CODE = 'SW_GP_LNG_CARGO' AND PRODUCTION_DAY = p_daytime;
            FOR ticket IN c_ticket_no LOOP
                ln_ticket_no := ticket.ticket_no;
                ln_cargo_no := ln_ticket_no;
            END LOOP;
		    -- Item 125147: End

			IF ln_ticket_no IS NULL THEN

				FOR cargo IN c_partial_cargos('STW_LNG') LOOP

					ln_cargo_no := cargo.cargo_no;


				END LOOP;


			END IF;

			IF ln_cargo_no IS NOT NULL THEN

				SELECT SUM(SPLIT_PCT/100) INTO ln_lifted_split_upg FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = ln_cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(CARGO_NO)) <> 'D';
				SELECT SUM(SPLIT_PCT/100) INTO ln_lifted_split_total FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = ln_cargo_no AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(CARGO_NO)) <> 'D';
				IF ln_lifted_split_total IS NULL OR ln_lifted_split_total = 0 THEN
					ln_ratio := null;
				ELSIF ln_lifted_split_upg IS NULL THEN
					ln_ratio := 0;
				ELSE
					ln_ratio := ln_lifted_split_upg / ln_lifted_split_total;
				END IF;

				SELECT SUM(QTY) into ln_pc_mass_total FROM DV_SCTR_ACC_DAY_EVENT WHERE ACCOUNT_CODE = 'IN_LNG_PURGE_COOL' AND EVENT_TYPE = 'ADJUSTMENT' AND ACCEPTED = 'Y' AND DAYTIME = p_daytime;

				IF ln_pc_mass_total IS NOT NULL THEN

					SELECT ec_strm_day_alloc.net_mass(p_object_id,p_daytime) into ln_bog_flare_mass from dual;

					IF ln_bog_flare_mass IS NOT NULL THEN

						ln_bog_flare_mass_adj := ln_bog_flare_mass - ln_pc_mass_total;

						ln_bog_flare_mass_upg := ln_bog_flare_mass_adj * ln_ratio;

						SELECT SUM(QTY) into ln_pc_mass_upg FROM DV_SCTR_ACC_DAY_EVENT WHERE ACCOUNT_CODE = 'IN_LNG_PURGE_COOL' AND EVENT_TYPE = 'ADJUSTMENT' AND ACCEPTED = 'Y' AND OBJECT_ID IN (
						SELECT OBJECT_ID FROM CONTRACT_VERSION WHERE PARENT_CONTRACT_ID = (SELECT OBJECT_ID FROM DV_CNTR_PROFIT_CENTRE WHERE PROFIT_CENTRE_ID = p_profit_centre_id AND OBJECT_CODE LIKE 'C_ALLOC%')) AND DAYTIME = p_daytime;

						IF ln_pc_mass_upg IS NOT NULL THEN

							ln_bog_flare_mass_upg := ln_bog_flare_mass_upg + ln_pc_mass_upg;

							ln_ratio := ln_bog_flare_mass_upg / ln_bog_flare_mass;

						ELSE

							ln_ratio := ln_bog_flare_mass_upg / ln_bog_flare_mass;

						END IF;

					END IF;

				END IF;

			END IF;

		ELSE

			RETURN null;

		END IF;

		RETURN ln_ratio;

	ELSE
        return null;
    END IF;

END UPGRatio;


FUNCTION LNGRefProdEnergy(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 ln_lng_ref_prod NUMBER;
 ln_lng_hhv NUMBER;
 lv_forecast_object_id VARCHAR2(32);

BEGIN
    lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SW_GP_LNG_FORECAST' THEN
        SELECT object_id INTO lv_forecast_object_id FROM OV_CT_PROD_FORECAST WHERE FORECAST_TYPE = 'ADP_PLAN' AND SCENARIO = 'REF_PROD' AND RECORD_STATUS = 'A' AND LAST_UPD_DATE = (SELECT MAX(LAST_UPD_DATE) FROM OV_CT_PROD_FORECAST WHERE FORECAST_TYPE = 'ADP_PLAN' AND SCENARIO = 'REF_PROD' AND RECORD_STATUS = 'A' AND OBJECT_START_DATE <= p_daytime AND OBJECT_END_DATE - 1 >= p_daytime);
        IF lv_forecast_object_id IS NOT NULL THEN
            SELECT LNG_VOL_RATE INTO ln_lng_ref_prod FROM DV_CT_PROD_STRM_PC_FORECAST WHERE OBJECT_CODE = 'SW_GP_LNG_FORECAST' AND FORECAST_TYPE = 'ADP_PLAN' AND SCENARIO = 'REF_PROD' AND RECORD_STATUS = 'A' AND PROFIT_CENTRE_ID = p_profit_centre_id AND DAYTIME = p_daytime AND FORECAST_OBJECT_ID = lv_forecast_object_id;
            SELECT LNG_HHV INTO ln_lng_hhv FROM DV_CT_PROD_STRM_PC_FORECAST WHERE OBJECT_CODE = 'SW_GP_LNG_FORECAST' AND FORECAST_TYPE = 'ADP_PLAN' AND SCENARIO = 'REF_PROD' AND RECORD_STATUS = 'A' AND PROFIT_CENTRE_ID = p_profit_centre_id AND DAYTIME = p_daytime AND FORECAST_OBJECT_ID = lv_forecast_object_id;
            ln_lng_ref_prod := ln_lng_ref_prod * ln_lng_hhv;
        ELSE
            ln_lng_ref_prod := 0;
        END IF;
    END IF;
    return ln_lng_ref_prod;

END LNGRefProdEnergy;


FUNCTION LNGRefProdVol(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 ln_lng_ref_prod NUMBER;
 lv_forecast_object_id VARCHAR2(32);

BEGIN
    lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SW_GP_LNG_FORECAST' THEN
        SELECT object_id INTO lv_forecast_object_id FROM OV_CT_PROD_FORECAST WHERE FORECAST_TYPE = 'ADP_PLAN' AND SCENARIO = 'REF_PROD' AND RECORD_STATUS = 'A' AND LAST_UPD_DATE = (SELECT MAX(LAST_UPD_DATE) FROM OV_CT_PROD_FORECAST WHERE FORECAST_TYPE = 'ADP_PLAN' AND SCENARIO = 'REF_PROD' AND RECORD_STATUS = 'A' AND OBJECT_START_DATE <= p_daytime AND OBJECT_END_DATE - 1 >= p_daytime);
        IF lv_forecast_object_id IS NOT NULL THEN
            SELECT LNG_VOL_RATE INTO ln_lng_ref_prod FROM DV_CT_PROD_STRM_PC_FORECAST WHERE OBJECT_CODE = 'SW_GP_LNG_FORECAST' AND FORECAST_TYPE = 'ADP_PLAN' AND SCENARIO = 'REF_PROD' AND RECORD_STATUS = 'A' AND PROFIT_CENTRE_ID = p_profit_centre_id AND DAYTIME = p_daytime AND FORECAST_OBJECT_ID = lv_forecast_object_id;
        ELSE
            ln_lng_ref_prod := 0;
        END IF;
    END IF;
    return ln_lng_ref_prod;

END LNGRefProdVol;


FUNCTION LNGExcessProdEnergy(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 ln_lng_excess_prod NUMBER;
 ln_lng_hhv NUMBER;

BEGIN
    lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SW_GP_LNG_FORECAST' THEN
        SELECT CONFIRMED_EXCESS_QTY INTO ln_lng_excess_prod FROM DV_CT_PROD_STRM_PC_FORECAST WHERE OBJECT_CODE = 'SW_GP_LNG_FORECAST' AND FORECAST_TYPE = 'SDS_PLAN' AND SCENARIO = 'MED_CONF' AND PROFIT_CENTRE_ID = p_profit_centre_id AND DAYTIME = p_daytime;
        IF ln_lng_excess_prod IS NULL THEN
            ln_lng_excess_prod := 0;
        END IF;
    END IF;
    return ln_lng_excess_prod;

END LNGExcessProdEnergy;


FUNCTION LNGExcessProdVol(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 ln_lng_excess_prod NUMBER;

BEGIN
    lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SW_GP_LNG_FORECAST' THEN
        SELECT LNG_EXCESS_PROD INTO ln_lng_excess_prod FROM DV_CT_PROD_STRM_PC_FORECAST WHERE OBJECT_CODE = 'SW_GP_LNG_FORECAST' AND FORECAST_TYPE = 'SDS_PLAN' AND SCENARIO = 'MED_CONF' AND PROFIT_CENTRE_ID = p_profit_centre_id AND DAYTIME = p_daytime;
        IF ln_lng_excess_prod IS NULL THEN
            ln_lng_excess_prod := 0;
        END IF;
    END IF;
    return ln_lng_excess_prod;

END LNGExcessProdVol;


FUNCTION LNGRegasEnergy(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 ln_lng_regas NUMBER;
 ln_lng_hhv NUMBER;

BEGIN
    lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SW_GP_LNG_FORECAST' THEN
        SELECT LNG_REGAS_REQ_LNG INTO ln_lng_regas FROM DV_CT_PROD_STRM_PC_FORECAST WHERE OBJECT_CODE = 'SW_GP_LNG_FORECAST' AND FORECAST_TYPE = 'SDS_PLAN' AND SCENARIO = 'MED_CONF' AND PROFIT_CENTRE_ID = p_profit_centre_id AND DAYTIME = p_daytime;
        SELECT LNG_HHV INTO ln_lng_hhv FROM DV_CT_PROD_STRM_PC_FORECAST WHERE OBJECT_CODE = 'SW_GP_LNG_FORECAST' AND FORECAST_TYPE = 'SDS_PLAN' AND SCENARIO = 'MED_CONF' AND PROFIT_CENTRE_ID = p_profit_centre_id AND DAYTIME = p_daytime;
        IF ln_lng_regas IS NOT NULL AND ln_lng_hhv IS NOT NULL THEN
            ln_lng_regas := ln_lng_regas * ln_lng_hhv;
        ELSE
            ln_lng_regas := 0;
        END IF;
    END IF;
    return ln_lng_regas;

END LNGRegasEnergy;


FUNCTION LNGRegasVol(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 ln_lng_regas NUMBER;

BEGIN
    lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SW_GP_LNG_FORECAST' THEN
        SELECT LNG_REGAS_REQ_LNG INTO ln_lng_regas FROM DV_CT_PROD_STRM_PC_FORECAST WHERE OBJECT_CODE = 'SW_GP_LNG_FORECAST' AND FORECAST_TYPE = 'SDS_PLAN' AND SCENARIO = 'MED_CONF' AND PROFIT_CENTRE_ID = p_profit_centre_id AND DAYTIME = p_daytime;
        IF ln_lng_regas IS NULL THEN
            ln_lng_regas := 0;
        END IF;
    END IF;
    return ln_lng_regas;

END LNGRegasVol;


FUNCTION CompanyRatio(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING)
RETURN NUMBER
IS


	CURSOR c_partial_cargos(cp_code VARCHAR2)
	IS
	  SELECT object_id, cargo_no
	  FROM   DV_STOR_DAY_EXPORT_STATUS
	  WHERE  daytime BETWEEN (p_daytime-1) AND (p_daytime)
	  AND object_code = cp_code
	  GROUP BY object_id, cargo_no
	  ORDER BY cargo_no ASC;

	-- Item 125147: Begin
    CURSOR c_ticket_no
    IS
      SELECT ticket_no FROM DV_STRM_OIL_BATCH_EVENT
      WHERE OBJECT_CODE = 'SW_GP_LNG_CARGO' AND PRODUCTION_DAY = p_daytime;
	-- Item 125147: End

	lv2_stream_code VARCHAR2(32);
	lv2_profit_centre_code VARCHAR2(32);
	lv2_fuel_flare_type VARCHAR(32);
	ln_ratio NUMBER;

	ln_ticket_no NUMBER;
	ln_cargo_no NUMBER;
	ln_lifted_mass_total NUMBER;
	ln_lifted_split_cpny NUMBER;
	ln_lifted_split_upg NUMBER;
	ln_pc_mass_total NUMBER;
	ln_pc_mass_upg NUMBER;
	ln_pc_mass_cpny NUMBER;
	ln_bog_flare_mass NUMBER;
	ln_bog_flare_mass_cpny NUMBER;
	ln_bog_flare_mass_upg NUMBER;
	ln_bog_flare_mass_adj NUMBER;
	ln_count NUMBER;


BEGIN
    --INITIALIZE VARIABLES
    lv2_profit_centre_code := ecdp_objects.getobjcode(p_profit_centre_id);
    lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    lv2_fuel_flare_type := ec_strm_reference_value.text_30(p_object_id, p_daytime, '<=');

    IF lv2_fuel_flare_type = 'FIXED_LIFTING' AND lv2_stream_code = 'SW_GP_BOG_FLR' THEN

		SELECT ec_strm_day_alloc.net_mass(p_object_id,p_daytime) into ln_lifted_mass_total from dual;

		IF ln_lifted_mass_total <> 0 THEN

		    -- Item 125147: Begin
			--SELECT TICKET_NO INTO ln_ticket_no FROM DV_STRM_OIL_BATCH_EVENT WHERE OBJECT_CODE = 'SW_GP_LNG_CARGO' AND PRODUCTION_DAY = p_daytime;
            FOR ticket IN c_ticket_no LOOP
                ln_ticket_no := ticket.ticket_no;
                ln_cargo_no := ln_ticket_no;
             END LOOP;
		    -- Item 125147: End

			IF ln_ticket_no IS NULL THEN

				FOR cargo IN c_partial_cargos('STW_LNG') LOOP

					ln_cargo_no := cargo.cargo_no;

				END LOOP;

			-- Item 125147 Begin
			--ELSE

			--	ln_cargo_no := ln_ticket_no;
			-- Item 125147 End

			END IF;

			-- Item 125147 Begin
			--IF ln_cargo_no IS NULL THEN

			--	ln_ratio := 0;

			--ELSE
			IF ln_cargo_no IS NOT NULL THEN
			-- Item 125147 End

				SELECT SUM(SPLIT_PCT/100) INTO ln_lifted_split_cpny FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = ln_cargo_no AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(CARGO_NO)) <> 'D';
				SELECT SUM(SPLIT_PCT/100) INTO ln_lifted_split_upg FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = ln_cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(CARGO_NO)) <> 'D';

				IF ln_lifted_split_upg IS NULL OR ln_lifted_split_upg = 0 THEN
					ln_ratio := null;
				ELSIF ln_lifted_split_cpny IS NULL THEN
					ln_ratio := 0;
				ELSE
					ln_ratio := ln_lifted_split_cpny / ln_lifted_split_upg;
				END IF;

				SELECT SUM(QTY) into ln_pc_mass_total FROM DV_SCTR_ACC_DAY_EVENT WHERE ACCOUNT_CODE = 'IN_LNG_PURGE_COOL' AND EVENT_TYPE = 'ADJUSTMENT' AND ACCEPTED = 'Y' AND DAYTIME = p_daytime;

                IF ln_pc_mass_total IS NOT NULL THEN

					SELECT ec_strm_day_alloc.net_mass(p_object_id,p_daytime) into ln_bog_flare_mass from dual;

					IF ln_bog_flare_mass IS NOT NULL THEN

						ln_bog_flare_mass_upg := ln_bog_flare_mass * UPGRatio(p_object_id,p_daytime,p_profit_centre_id);

						    SELECT count(*), sum(QTY) into ln_count, ln_pc_mass_upg FROM DV_SCTR_ACC_DAY_EVENT WHERE ACCOUNT_CODE = 'IN_LNG_PURGE_COOL' AND EVENT_TYPE = 'ADJUSTMENT' AND ACCEPTED = 'Y' AND OBJECT_ID IN (
						       SELECT OBJECT_ID FROM CONTRACT_VERSION WHERE PARENT_CONTRACT_ID = (SELECT OBJECT_ID FROM DV_CNTR_PROFIT_CENTRE WHERE PROFIT_CENTRE_ID = p_profit_centre_id AND OBJECT_CODE LIKE 'C_ALLOC%')) AND DAYTIME = p_daytime;

						    IF ln_count > 0 THEN

							    IF ln_pc_mass_upg IS NOT NULL THEN

								    ln_bog_flare_mass_adj := ln_bog_flare_mass_upg - ln_pc_mass_upg;

								    ln_bog_flare_mass_cpny := ln_bog_flare_mass_adj * ln_ratio;

								    ln_ratio := ln_bog_flare_mass_cpny / ln_bog_flare_mass_upg;

								    SELECT count(*), sum(QTY) into ln_count, ln_pc_mass_cpny FROM DV_SCTR_ACC_DAY_EVENT WHERE ACCOUNT_CODE = 'IN_LNG_PURGE_COOL' AND EVENT_TYPE = 'ADJUSTMENT' AND ACCEPTED = 'Y' AND OBJECT_ID = (
								        SELECT OBJECT_ID FROM CONTRACT_VERSION WHERE PARENT_CONTRACT_ID = (SELECT OBJECT_ID FROM DV_CNTR_PROFIT_CENTRE WHERE PROFIT_CENTRE_ID = p_profit_centre_id AND OBJECT_CODE LIKE 'C_ALLOC%') AND COMPANY_ID = p_company_id) AND DAYTIME = p_daytime;

								    IF ln_count > 0 THEN

									    IF ln_pc_mass_cpny IS NOT NULL THEN

										    ln_bog_flare_mass_cpny := ln_bog_flare_mass_cpny + ln_pc_mass_cpny;

										    ln_ratio := ln_bog_flare_mass_cpny / ln_bog_flare_mass_upg;

									    END IF;

								    END IF;

							    END IF;

						    END IF;

						END IF;

					END IF;

				END IF;

		ELSE

			RETURN null;

		END IF;

		RETURN ln_ratio;

    ELSIF lv2_fuel_flare_type = 'FIXED_LIFTING' AND lv2_stream_code = 'SW_GP_BOG_INERT_IMPORT' THEN

		SELECT ec_strm_day_alloc.net_mass(p_object_id,p_daytime) into ln_lifted_mass_total from dual;

		IF ln_lifted_mass_total <> 0 THEN

		    -- Item 125147: Begin
			--SELECT TICKET_NO INTO ln_ticket_no FROM DV_STRM_OIL_BATCH_EVENT WHERE OBJECT_CODE = 'SW_GP_LNG_CARGO' AND PRODUCTION_DAY = p_daytime;
            FOR ticket IN c_ticket_no LOOP
                ln_ticket_no := ticket.ticket_no;
                ln_cargo_no := ln_ticket_no;
             END LOOP;
		    -- Item 125147: End

			IF ln_ticket_no IS NULL THEN

				FOR cargo IN c_partial_cargos('STW_LNG') LOOP

					ln_cargo_no := cargo.cargo_no;

				END LOOP;

			ELSE

				ln_cargo_no := ln_ticket_no;

			END IF;

			IF ln_cargo_no IS NULL THEN

				ln_ratio := 0;

			ELSE

				SELECT SUM(SPLIT_PCT/100) INTO ln_lifted_split_cpny FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = ln_cargo_no AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(CARGO_NO)) <> 'D';
				SELECT SUM(SPLIT_PCT/100) INTO ln_lifted_split_upg FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = ln_cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(CARGO_NO)) <> 'D';

				IF ln_lifted_split_upg IS NULL OR ln_lifted_split_upg = 0 THEN
					ln_ratio := null;
				ELSIF ln_lifted_split_cpny IS NULL THEN
					ln_ratio := 0;
				ELSE
					ln_ratio := ln_lifted_split_cpny / ln_lifted_split_upg;
				END IF;

			END IF;

		ELSE

			RETURN null;

		END IF;

		RETURN ln_ratio;

	ELSE
        return null;
    END IF;


END CompanyRatio;


FUNCTION LiftingMass(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 ln_blmr_mass_lifter NUMBER;
 ln_denl_mass_lifter NUMBER;
 ln_denl_vol_lifter NUMBER;
 ln_lifted_mass_lifter NUMBER;
 ln_lifted_mass_total NUMBER;
 ln_lifter_split NUMBER;

 ln_denl_vol_curr NUMBER;
 ln_denl_vol_prev NUMBER;
 ln_denl_vol NUMBER;

 ln_lifted_mass NUMBER;

 lofa_sample_row object_fluid_analysis%ROWTYPE;
 lv2_analysis_unit VARCHAR2(32);
 lv2_target_unit VARCHAR2(32);
 ln_count NUMBER := 0;


CURSOR c_final_cargos(cp_stream_code VARCHAR2)
IS
  SELECT production_day, ticket_no
  FROM   DV_STRM_OIL_BATCH_EVENT
  WHERE  production_day = p_daytime
  AND object_code = cp_stream_code;

CURSOR c_partial_cargos(cp_code VARCHAR2)
IS
  SELECT object_id, cargo_no
  FROM   DV_STOR_DAY_EXPORT_STATUS
  WHERE  daytime BETWEEN (p_daytime-1) AND (p_daytime)
  AND object_code = cp_code
  GROUP BY object_id, cargo_no
  ORDER BY cargo_no ASC;



BEGIN

	lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SW_GP_LNG_LOAD' THEN
		-- Check if any LNG quantity has been loaded
		SELECT ec_strm_day_alloc.net_mass(p_object_id,p_daytime) into ln_lifted_mass_total from dual;
		IF ln_lifted_mass_total <> 0 THEN
			-- Final quantities
			FOR cargo IN c_final_cargos('SW_GP_LNG_CARGO') LOOP
				SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_LNG' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
				IF ln_count > 0 THEN
					SELECT SUM(LIFTED_MASS_PAA) INTO ln_blmr_mass_lifter FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_LNG' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
					ln_denl_mass_lifter := GetPartialLiftedMassByCargo(cargo.ticket_no, p_profit_centre_id, p_company_id, 'STW_LNG');
					ln_lifted_mass_lifter := ln_blmr_mass_lifter - round(nvl(ln_denl_mass_lifter,0),2);
				END IF;
			END LOOP;

			-- Partial quantities
			IF ln_lifted_mass_lifter IS NULL THEN

				FOR cargo IN c_partial_cargos('STW_LNG') LOOP

					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime) INTO ln_denl_vol_curr FROM dual;
					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime-1) INTO ln_denl_vol_prev FROM dual;

					IF NVL(ln_denl_vol_curr,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_curr;
					END IF;

					IF NVL(ln_denl_vol_prev,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_prev * -1 + nvl(ln_denl_vol, 0);
					END IF;

					SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';

					IF ln_count > 0 THEN
                        --Item 127690 Begin
						--Below piece of code would throw when we have mulitple parcels for same campany for a Cargo,hence commenting and re-writing the same, using SUM
						--SELECT split_pct/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
						SELECT SUM(SPLIT_PCT/100) INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
                        --Item 127690 End

						IF (ln_lifter_split IS NOT NULL AND ln_denl_vol IS NOT NULL) THEN

							ln_denl_vol_lifter := round(ln_denl_vol * ln_lifter_split,2);

							lv2_analysis_unit := EcDp_Unit.GetUnitFromLogical(EcDp_ClassMeta_cnfg.getUomCode('STRM_LNG_ANALYSIS', 'DENSITY'));
							lv2_target_unit := EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_PAA_MASS') || 'PER' || EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_M3');

							lofa_sample_row := Ecdp_Fluid_Analysis.getLastAnalysisSample(ec_stream.object_id_by_uk('SW_GP_LNG_CARGO'), 'STRM_LNG_COMP', NULL, p_daytime, 'LNG');
							ln_denl_mass_lifter := ln_denl_vol_lifter * EcDp_Unit.ConvertValue(lofa_sample_row.density, lv2_analysis_unit, lv2_target_unit);

						END IF;
					END IF;

				END LOOP;

				ln_lifted_mass_lifter := ln_denl_mass_lifter;

			ELSE
				ln_denl_mass_lifter := GetPartialLiftedMassByDay(p_daytime, p_profit_centre_id, p_company_id, 'STW_LNG');
				IF ln_denl_mass_lifter IS NOT NULL THEN
					ln_lifted_mass_lifter := ln_lifted_mass_lifter + round(ln_denl_mass_lifter,2);
				END IF;
			END IF;
		END IF;
    END IF;

    IF lv2_stream_code = 'SW_GP_COND_LOAD' THEN
		-- Check if any COND quantity has been loaded
		SELECT ec_strm_day_alloc.net_mass(p_object_id,p_daytime) into ln_lifted_mass_total from dual;
		IF ln_lifted_mass_total <> 0 THEN
			-- Final quantities
			FOR cargo IN c_final_cargos('SW_GP_COND_CARGO') LOOP
				SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_COND' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
				IF ln_count > 0 THEN
					SELECT SUM(LIFTED_MASS) INTO ln_blmr_mass_lifter FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_COND' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
					ln_denl_mass_lifter := GetPartialLiftedMassByCargo(cargo.ticket_no, p_profit_centre_id, p_company_id, 'STW_COND');
					ln_lifted_mass_lifter := ln_blmr_mass_lifter - round(nvl(ln_denl_mass_lifter,0),2);
				END IF;
			END LOOP;

			-- Partial quantities
			IF ln_lifted_mass_lifter IS NULL THEN

				FOR cargo IN c_partial_cargos('STW_COND') LOOP

					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime) INTO ln_denl_vol_curr FROM dual;
					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime-1) INTO ln_denl_vol_prev FROM dual;

					IF NVL(ln_denl_vol_curr,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_curr;
					END IF;

					IF NVL(ln_denl_vol_prev,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_prev * -1 + nvl(ln_denl_vol, 0);
					END IF;

					SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';

					IF ln_count > 0 THEN
                        --Item 127690 Begin
                        --Below piece of code would throw when we have mulitple parcels for same campany for a Cargo,hence commenting and re-writing the same, using SUM
						--SELECT split_pct/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
						SELECT SUM(SPLIT_PCT/100) INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
                        --Item 127690 End

						IF (ln_lifter_split IS NOT NULL AND ln_denl_vol IS NOT NULL) THEN

							ln_denl_vol_lifter := round(ln_denl_vol * ln_lifter_split,2);

							lv2_analysis_unit := EcDp_Unit.GetUnitFromLogical(EcDp_ClassMeta_cnfg.getUomCode('STRM_OIL_ANALYSIS', 'DENSITY'));
							lv2_target_unit := EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_COND_MASS_NET') || 'PER' || EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_COND_VOL_NET');

							lofa_sample_row := Ecdp_Fluid_Analysis.getLastAnalysisSample(ec_stream.object_id_by_uk('SW_GP_COND_CARGO'), 'STRM_OIL_COMP', NULL, p_daytime, 'COND');
							ln_denl_mass_lifter := ln_denl_vol_lifter * EcDp_Unit.ConvertValue(lofa_sample_row.density, lv2_analysis_unit, lv2_target_unit);

						END IF;

					END IF;
				END LOOP;

				ln_lifted_mass_lifter := ln_denl_mass_lifter;

			ELSE
				ln_denl_mass_lifter := GetPartialLiftedMassByDay(p_daytime, p_profit_centre_id, p_company_id, 'STW_COND');
				IF ln_denl_mass_lifter IS NOT NULL THEN
					ln_lifted_mass_lifter := ln_lifted_mass_lifter + round(ln_denl_mass_lifter,2);
				END IF;
			END IF;
		END IF;
    END IF;

	return nvl(ln_lifted_mass_lifter,0);

END LiftingMass;

FUNCTION GetPartialLiftedMassByCargo(p_cargo_no NUMBER, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING)
RETURN NUMBER
IS

 ln_denl_vol_lifter NUMBER := GetPartialLiftedVolumeByCargo(p_cargo_no, p_profit_centre_id, p_company_id);
 ln_denl_mass_lifter NUMBER;
 ld_daytime DATE;
 lofa_sample_row object_fluid_analysis%ROWTYPE;
 lv2_analysis_unit VARCHAR2(32);
 lv2_target_unit VARCHAR2(32);

 CURSOR c_dates
 IS
  SELECT daytime
  FROM DV_STOR_DAY_EXPORT_STATUS
  WHERE cargo_no = p_cargo_no
  ORDER BY daytime ASC;

BEGIN

    FOR item IN c_dates LOOP
		ld_daytime := item.daytime;
    END LOOP;

	IF (ln_denl_vol_lifter IS NOT NULL) THEN

		IF p_storage_code = 'STW_LNG' THEN

			lv2_analysis_unit := EcDp_Unit.GetUnitFromLogical(EcDp_ClassMeta_cnfg.getUomCode('STRM_LNG_ANALYSIS', 'DENSITY'));
			lv2_target_unit := EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_PAA_MASS') || 'PER' || EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_M3');
			lofa_sample_row := Ecdp_Fluid_Analysis.getLastAnalysisSample(ec_stream.object_id_by_uk('SW_GP_LNG_CARGO'), 'STRM_LNG_COMP', NULL, ld_daytime, 'LNG');

		END IF;
		IF p_storage_code = 'STW_COND' THEN

			lv2_analysis_unit := EcDp_Unit.GetUnitFromLogical(EcDp_ClassMeta_cnfg.getUomCode('STRM_OIL_ANALYSIS', 'DENSITY'));
			lv2_target_unit := EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_COND_MASS_NET') || 'PER' || EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_COND_VOL_NET');
			lofa_sample_row := Ecdp_Fluid_Analysis.getLastAnalysisSample(ec_stream.object_id_by_uk('SW_GP_COND_CARGO'), 'STRM_OIL_COMP', NULL, ld_daytime, 'COND');

		END IF;

		ln_denl_mass_lifter := ln_denl_vol_lifter * EcDp_Unit.ConvertValue(lofa_sample_row.density, lv2_analysis_unit, lv2_target_unit);

	END IF;

	return ln_denl_mass_lifter;

END GetPartialLiftedMassByCargo;

--Item_127690: Adding p_reference_lifting_no in the function paramter:
FUNCTION GetPartialLiftedMassByDay(p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING, p_reference_lifting_no STRING)
RETURN NUMBER
IS

--Item_127690: Passing p_reference_lifting_no in the call.
 ln_denl_vol_lifter NUMBER := GetPartialLiftedVolumeByDay(p_daytime, p_profit_centre_id, p_company_id, p_storage_code, p_reference_lifting_no);
 ln_denl_mass_lifter NUMBER;

 lofa_sample_row object_fluid_analysis%ROWTYPE;
 lv2_analysis_unit VARCHAR2(32);
 lv2_target_unit VARCHAR2(32);

 BEGIN

	IF (ln_denl_vol_lifter IS NOT NULL) THEN

		IF p_storage_code = 'STW_LNG' THEN

			lv2_analysis_unit := EcDp_Unit.GetUnitFromLogical(EcDp_ClassMeta_cnfg.getUomCode('STRM_LNG_ANALYSIS', 'DENSITY'));
			lv2_target_unit := EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_PAA_MASS') || 'PER' || EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_M3');
			lofa_sample_row := Ecdp_Fluid_Analysis.getLastAnalysisSample(ec_stream.object_id_by_uk('SW_GP_LNG_CARGO'), 'STRM_LNG_COMP', NULL, p_daytime, 'LNG');

		END IF;

		IF p_storage_code = 'STW_COND' THEN

			lv2_analysis_unit := EcDp_Unit.GetUnitFromLogical(EcDp_ClassMeta_cnfg.getUomCode('STRM_OIL_ANALYSIS', 'DENSITY'));
			lv2_target_unit := EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_COND_MASS_NET') || 'PER' || EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_COND_VOL_NET');
			lofa_sample_row := Ecdp_Fluid_Analysis.getLastAnalysisSample(ec_stream.object_id_by_uk('SW_GP_COND_CARGO'), 'STRM_OIL_COMP', NULL, p_daytime, 'COND');

		END IF;

		ln_denl_mass_lifter := ln_denl_vol_lifter * EcDp_Unit.ConvertValue(lofa_sample_row.density, lv2_analysis_unit, lv2_target_unit);

	END IF;

	return round(ln_denl_mass_lifter,2);

END GetPartialLiftedMassByDay;

FUNCTION LiftingEnergy(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 ln_blmr_energy_lifter NUMBER;
 ln_denl_energy_lifter NUMBER;
 ln_denl_vol_lifter NUMBER;
 ln_denl_mass_lifter NUMBER;
 ln_lifted_energy_lifter NUMBER;
 ln_lifted_energy_total NUMBER;
 ln_lifter_split NUMBER;

 ln_denl_vol_curr NUMBER;
 ln_denl_vol_prev NUMBER;
 ln_denl_vol NUMBER;

 lofa_sample_row object_fluid_analysis%ROWTYPE;
 lv2_analysis_unit VARCHAR2(32);
 lv2_target_unit VARCHAR2(32);
 ln_count NUMBER := 0;


CURSOR c_final_cargos(cp_stream_code VARCHAR2)
IS
  SELECT production_day, ticket_no
  FROM   DV_STRM_OIL_BATCH_EVENT
  WHERE  production_day = p_daytime
  AND object_code = cp_stream_code;

CURSOR c_partial_cargos(cp_code VARCHAR2)
IS
  SELECT object_id, cargo_no
  FROM   DV_STOR_DAY_EXPORT_STATUS
  WHERE  daytime BETWEEN (p_daytime-1) AND (p_daytime)
  AND object_code = cp_code
  GROUP BY object_id, cargo_no
  ORDER BY cargo_no ASC;

BEGIN

	lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SW_GP_LNG_LOAD' THEN
		-- Check if any LNG quantity has been loaded
		SELECT ec_strm_day_alloc.alloc_energy(p_object_id,p_daytime) into ln_lifted_energy_total from dual;
		IF ln_lifted_energy_total <> 0 THEN
			-- Final quantities
			FOR cargo IN c_final_cargos('SW_GP_LNG_CARGO') LOOP
				SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_LNG' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
				IF ln_count > 0 THEN
					SELECT SUM(LIFTED_ENERGY_PAA) INTO ln_blmr_energy_lifter FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_LNG' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
					ln_denl_energy_lifter := GetPartialLiftedEnergyByCargo(cargo.ticket_no, p_profit_centre_id, p_company_id, 'STW_LNG');
					ln_lifted_energy_lifter := ln_blmr_energy_lifter - round(nvl(ln_denl_energy_lifter,0),2);
				END IF;
			END LOOP;

			-- Partial quantities
			IF ln_lifted_energy_lifter IS NULL THEN

				FOR cargo IN c_partial_cargos('STW_LNG') LOOP

					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime) INTO ln_denl_vol_curr FROM dual;
					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime-1) INTO ln_denl_vol_prev FROM dual;

					IF NVL(ln_denl_vol_curr,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_curr;
					END IF;

					IF NVL(ln_denl_vol_prev,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_prev * -1 + nvl(ln_denl_vol, 0);
					END IF;

					SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';

					IF ln_count > 0 THEN
                        --Item 127690 Begin
						--SELECT split_pct/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
						SELECT SUM(SPLIT_PCT/100) INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
                        --Item 127690 End

						IF (ln_lifter_split IS NOT NULL AND ln_denl_vol IS NOT NULL) THEN

							ln_denl_vol_lifter := round(ln_denl_vol * ln_lifter_split,2);

							lofa_sample_row := Ecdp_Fluid_Analysis.getLastAnalysisSample(ec_stream.object_id_by_uk('SW_GP_LNG_CARGO'), 'STRM_LNG_COMP', NULL, p_daytime, 'LNG');

							lv2_analysis_unit := EcDp_Unit.GetUnitFromLogical(EcDp_ClassMeta_cnfg.getUomCode('STRM_LNG_ANALYSIS', 'DENSITY'));
							lv2_target_unit := EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_PAA_MASS') || 'PER' || EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_M3');

							ln_denl_mass_lifter := ln_denl_vol_lifter * EcDp_Unit.ConvertValue(lofa_sample_row.density, lv2_analysis_unit, lv2_target_unit);

							lv2_analysis_unit := EcDp_Unit.GetUnitFromLogical(EcDp_ClassMeta_cnfg.getUomCode('STRM_LNG_ANALYSIS', 'GCV_LNG'));
							lv2_target_unit := EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_PAA_MMBTU') || 'PER' || EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_PAA_MASS');

							ln_denl_energy_lifter := ln_denl_mass_lifter * EcDp_Unit.ConvertValue(lofa_sample_row.VALUE_46, lv2_analysis_unit, lv2_target_unit);

						END IF;

					END IF;
				END LOOP;

				ln_lifted_energy_lifter := round(ln_denl_energy_lifter,2);

			ELSE
				ln_denl_energy_lifter := GetPartialLiftedEnergyByDay(p_daytime, p_profit_centre_id, p_company_id, 'STW_LNG');
				IF ln_denl_energy_lifter IS NOT NULL THEN
					ln_lifted_energy_lifter := ln_lifted_energy_lifter + round(ln_denl_energy_lifter,2);
				END IF;
			END IF;
		END IF;
    END IF;

    IF lv2_stream_code = 'SW_GP_COND_LOAD' THEN

		ln_lifted_energy_lifter := 0;

	END IF;

    return nvl(ln_lifted_energy_lifter,0);

END LiftingEnergy;

FUNCTION GetPartialLiftedEnergyByCargo(p_cargo_no NUMBER, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING)
RETURN NUMBER
IS

 ln_denl_mass_lifter NUMBER := GetPartialLiftedMassByCargo(p_cargo_no, p_profit_centre_id, p_company_id, p_storage_code);
 ln_denl_energy_lifter NUMBER;
 ld_daytime DATE;
 lofa_sample_row object_fluid_analysis%ROWTYPE;
 lv2_analysis_unit VARCHAR2(32);
 lv2_target_unit VARCHAR2(32);

 CURSOR c_dates
 IS
  SELECT daytime
  FROM DV_STOR_DAY_EXPORT_STATUS
  WHERE cargo_no = p_cargo_no
  ORDER BY daytime ASC;

BEGIN

	FOR item IN c_dates LOOP
		ld_daytime := item.daytime;
    END LOOP;

	IF (ln_denl_mass_lifter IS NOT NULL) THEN

		IF p_storage_code = 'STW_LNG' THEN

			lv2_analysis_unit := EcDp_Unit.GetUnitFromLogical(EcDp_ClassMeta_cnfg.getUomCode('STRM_LNG_ANALYSIS', 'GCV_LNG'));
			lv2_target_unit := EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_PAA_MMBTU') || 'PER' || EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_PAA_MASS');
			lofa_sample_row := Ecdp_Fluid_Analysis.getLastAnalysisSample(ec_stream.object_id_by_uk('SW_GP_LNG_CARGO'), 'STRM_LNG_COMP', NULL, ld_daytime, 'LNG');

		END IF;

		ln_denl_energy_lifter := ln_denl_mass_lifter * EcDp_Unit.ConvertValue(lofa_sample_row.VALUE_46, lv2_analysis_unit, lv2_target_unit);

	END IF;

	return ln_denl_energy_lifter;

END GetPartialLiftedEnergyByCargo;

--Adding: p_reference_lifting_no in the function parameter
FUNCTION GetPartialLiftedEnergyByDay(p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING, p_reference_lifting_no STRING)
RETURN NUMBER
IS
 --Passing p_reference_lifting_no in the call
 ln_denl_mass_lifter NUMBER := GetPartialLiftedMassByDay(p_daytime, p_profit_centre_id, p_company_id, p_storage_code, p_reference_lifting_no);
 ln_denl_energy_lifter NUMBER;

 lofa_sample_row object_fluid_analysis%ROWTYPE;
 lv2_analysis_unit VARCHAR2(32);
 lv2_target_unit VARCHAR2(32);

 BEGIN

	IF (ln_denl_mass_lifter IS NOT NULL) THEN

		IF p_storage_code = 'STW_LNG' THEN

			lv2_analysis_unit := EcDp_Unit.GetUnitFromLogical(EcDp_ClassMeta_cnfg.getUomCode('STRM_LNG_ANALYSIS', 'GCV_LNG'));
			lv2_target_unit := EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_PAA_MMBTU') || 'PER' || EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_PAA_MASS');
			lofa_sample_row := Ecdp_Fluid_Analysis.getLastAnalysisSample(ec_stream.object_id_by_uk('SW_GP_LNG_CARGO'), 'STRM_LNG_COMP', NULL, p_daytime, 'LNG');

		END IF;

		ln_denl_energy_lifter := ln_denl_mass_lifter * EcDp_Unit.ConvertValue(lofa_sample_row.VALUE_46, lv2_analysis_unit, lv2_target_unit);

	END IF;

	return round(ln_denl_energy_lifter,2);

END GetPartialLiftedEnergyByDay;

FUNCTION LiftingVol(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 ln_blmr_vol_lifter NUMBER;
 ln_denl_vol_lifter NUMBER;
 ln_lifted_vol_lifter NUMBER;
 ln_lifted_vol_total NUMBER;
 ln_lifter_split NUMBER;

 ln_denl_vol_curr NUMBER;
 ln_denl_vol_prev NUMBER;
 ln_denl_vol NUMBER;
 ln_count NUMBER := 0;

CURSOR c_final_cargos(cp_stream_code VARCHAR2)
IS
  SELECT production_day, ticket_no
  FROM   DV_STRM_OIL_BATCH_EVENT
  WHERE  production_day = p_daytime
  AND object_code = cp_stream_code;

CURSOR c_partial_cargos(cp_code VARCHAR2)
IS
  SELECT object_id, cargo_no
  FROM   DV_STOR_DAY_EXPORT_STATUS
  WHERE  daytime BETWEEN (p_daytime-1) AND (p_daytime)
  AND object_code = cp_code
  GROUP BY object_id, cargo_no
  ORDER BY cargo_no ASC;

 BEGIN

	lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SW_GP_LNG_LOAD' THEN
		-- Check if any LNG quantity has been loaded
		SELECT ec_strm_day_alloc.net_vol(p_object_id,p_daytime) into ln_lifted_vol_total from dual;
		IF ln_lifted_vol_total <> 0 THEN
			-- Final quantities
			FOR cargo IN c_final_cargos('SW_GP_LNG_CARGO') LOOP
				SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_LNG' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
				IF ln_count > 0 THEN
					SELECT SUM(LIFTED_VOLUME) INTO ln_blmr_vol_lifter FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_LNG' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
					ln_denl_vol_lifter := GetPartialLiftedVolumeByCargo(cargo.ticket_no, p_profit_centre_id, p_company_id);
					ln_lifted_vol_lifter := ln_blmr_vol_lifter - round(nvl(ln_denl_vol_lifter,0),3);
				END IF;
			END LOOP;
			-- Partial quantities
			IF ln_lifted_vol_lifter IS NULL THEN

				FOR cargo IN c_partial_cargos('STW_LNG') LOOP
					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime) INTO ln_denl_vol_curr FROM dual;
					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime-1) INTO ln_denl_vol_prev FROM dual;

                    IF NVL(ln_denl_vol_curr,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_curr;
                    END IF;

					IF NVL(ln_denl_vol_prev,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_prev * -1 + nvl(ln_denl_vol, 0);
                    END IF;

					SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';

					IF ln_count > 0 THEN
                        --Item 127690 Begin
                        --Below piece of code would throw when we have mulitple parcels for same campany for a Cargo,hence commenting and re-writing the same, using SUM
						--SELECT split_pct/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
						SELECT SUM(SPLIT_PCT/100) INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
                        --Item 127690 End

						IF (ln_lifter_split IS NOT NULL AND ln_denl_vol IS NOT NULL) THEN
							ln_denl_vol_lifter := round(ln_denl_vol * ln_lifter_split,3);
						END IF;
					END IF;

				END LOOP;
				ln_lifted_vol_lifter := ln_denl_vol_lifter;
			ELSE
				ln_denl_vol_lifter := GetPartialLiftedVolumeByDay(p_daytime, p_profit_centre_id, p_company_id, 'STW_LNG');
				IF ln_denl_vol_lifter IS NOT NULL THEN
					ln_lifted_vol_lifter := ln_lifted_vol_lifter + round(ln_denl_vol_lifter,3);
				END IF;
			END IF;
		END IF;
    END IF;

    IF lv2_stream_code = 'SW_GP_COND_LOAD' THEN
		-- Check if any COND quantity has been loaded
		SELECT ec_strm_day_alloc.net_vol(p_object_id,p_daytime) into ln_lifted_vol_total from dual;
		IF ln_lifted_vol_total <> 0 THEN
			-- Final quantities
			FOR cargo IN c_final_cargos('SW_GP_COND_CARGO') LOOP
				SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_COND' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
				IF ln_count > 0 THEN
					SELECT SUM(LIFTED_VOLUME) INTO ln_blmr_vol_lifter FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_COND' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
					ln_denl_vol_lifter := GetPartialLiftedVolumeByCargo(cargo.ticket_no, p_profit_centre_id, p_company_id);
					ln_lifted_vol_lifter := ln_blmr_vol_lifter - round(nvl(ln_denl_vol_lifter,0),2);
				END IF;
			END LOOP;

			-- Partial quantities
			IF ln_lifted_vol_lifter IS NULL THEN

				FOR cargo IN c_partial_cargos('STW_COND') LOOP
					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime) INTO ln_denl_vol_curr FROM dual;
					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime-1) INTO ln_denl_vol_prev FROM dual;

                    IF NVL(ln_denl_vol_curr,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_curr;
                    END IF;

					IF NVL(ln_denl_vol_prev,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_prev * -1 + nvl(ln_denl_vol, 0);
                    END IF;

					SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';

					IF ln_count > 0 THEN
                        --Below piece of code would throw when we have mulitple parcels for same campany for a Cargo,hence commenting and re-writing the same, using SUM
						--SELECT split_pct/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
						SELECT SUM(SPLIT_PCT/100) INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
                        --Item 127690 End

						IF (ln_lifter_split IS NOT NULL AND ln_denl_vol IS NOT NULL) THEN
							ln_denl_vol_lifter := round(ln_denl_vol * ln_lifter_split,2);
						END IF;
					END IF;
				END LOOP;
				ln_lifted_vol_lifter := ln_denl_vol_lifter;
			ELSE
				ln_denl_vol_lifter := GetPartialLiftedVolumeByDay(p_daytime, p_profit_centre_id, p_company_id, 'STW_COND');
				IF ln_denl_vol_lifter IS NOT NULL THEN
					ln_lifted_vol_lifter := ln_lifted_vol_lifter + round(ln_denl_vol_lifter,2);
				END IF;
			END IF;
		END IF;
    END IF;

	return nvl(ln_lifted_vol_lifter,0);

END LiftingVol;

FUNCTION GetPartialLiftedVolumeByCargo(p_cargo_no NUMBER, p_profit_centre_id STRING, p_company_id STRING)
RETURN NUMBER
IS

 ln_lifter_split NUMBER;
 ln_denl_vol_total NUMBER;
 ln_denl_vol_lifter NUMBER;

 CURSOR c_partial_cargos
 IS
  SELECT exported_qty
  FROM DV_STOR_DAY_EXPORT_STATUS
  WHERE cargo_no = p_cargo_no
  ORDER BY daytime ASC;

BEGIN
    --Item 127690 Begin
    --Below piece of code would throw when we have mulitple parcels for same campany for a Cargo,hence commenting and re-writing the same, using SUM
    --SELECT split_pct/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = p_cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(p_cargo_no)) <> 'D';
    SELECT SUM(SPLIT_PCT/100) INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = p_cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(p_cargo_no)) <> 'D';
    --Item 127690 End

	FOR cargo IN c_partial_cargos() LOOP
		ln_denl_vol_total := cargo.exported_qty;
	END LOOP;

	IF (ln_lifter_split IS NOT NULL AND ln_denl_vol_total IS NOT NULL) THEN
		ln_denl_vol_lifter := ln_denl_vol_total * ln_lifter_split;
	END IF;

	return ln_denl_vol_lifter;

END GetPartialLiftedVolumeByCargo;

--Item_127690: Adding p_reference_lifting_no in the below function parameter
FUNCTION GetPartialLiftedVolumeByDay(p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING, p_storage_code STRING, p_reference_lifting_no STRING)
RETURN NUMBER
IS

 ln_lifter_split NUMBER;
 ln_denl_vol_total NUMBER;
 ln_denl_vol_lifter NUMBER;
 ln_count NUMBER := 0;

 CURSOR c_partial_cargos
 IS
  SELECT exported_qty, cargo_no
  FROM DV_STOR_DAY_EXPORT_STATUS
  WHERE daytime = p_daytime
  AND object_code = p_storage_code;

 BEGIN
	FOR cargo IN c_partial_cargos() LOOP
		ln_denl_vol_total := cargo.exported_qty;
		--Item 127690 Begin
		SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D' AND reference_lifting_no = NVL(p_reference_lifting_no,reference_lifting_no);
        --Item 127690 End
		IF ln_count > 0 THEN
		    --Item 127690 Begin
            --Below piece of code would throw when we have mulitple parcels for same campany for a Cargo,hence commenting and re-writing the same, using SUM
			--SELECT split_pct/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
			SELECT SUM(split_pct)/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D' AND reference_lifting_no = NVL(p_reference_lifting_no,reference_lifting_no);
            --Item 127690 Begin

			IF (ln_lifter_split IS NOT NULL AND ln_denl_vol_total IS NOT NULL) THEN
				IF p_storage_code = 'STW_LNG' THEN
					ln_denl_vol_lifter := round(ln_denl_vol_total * ln_lifter_split,3);
				END IF;
				IF p_storage_code = 'STW_COND' THEN
					ln_denl_vol_lifter := round(ln_denl_vol_total * ln_lifter_split,2);
				END IF;
			END IF;
		END IF;
	END LOOP;

	return ln_denl_vol_lifter;

END GetPartialLiftedVolumeByDay;

FUNCTION LiftingPurgeCoolEnergy(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING)
RETURN NUMBER
IS

	CURSOR c_purge_cool_app_adj(cp_object_id VARCHAR2)
	IS

		SELECT qty
		FROM DV_SCTR_ACC_DAY_EVENT
		WHERE
			account_code = 'IN_LNG_PURGE_COOL' AND
			event_type = 'ADJUSTMENT' AND
			accepted = 'Y' AND
			daytime = p_daytime AND
			object_id = cp_object_id;

	CURSOR c_contract_company_id
	IS

		SELECT object_id
		FROM CONTRACT_VERSION
		WHERE
			company_id = p_company_id AND
			contract_area_id = ecdp_objects.getobjidfromcode('CONTRACT_AREA','CA_ALLOC_JVP') AND
			daytime =
			(SELECT max(daytime)
			FROM CONTRACT_VERSION
			WHERE
				company_id = p_company_id AND
				contract_area_id = ecdp_objects.getobjidfromcode('CONTRACT_AREA','CA_ALLOC_JVP') AND
				daytime <= p_daytime);


	lv2_stream_code VARCHAR2(32);
	lv2_contract_id VARCHAR2(32);
	ln_purge_cool_adj_qty NUMBER;
	ln_lifted_vol_total NUMBER;

BEGIN
    lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SW_GP_LNG_CARGO' THEN
		-- Check if any LNG quantity has been loaded
		SELECT ec_strm_day_alloc.net_vol(ecdp_objects.getobjidfromcode('STREAM','SW_GP_LNG_LOAD'),p_daytime) into ln_lifted_vol_total from dual;
		IF ln_lifted_vol_total <> 0 THEN

			ln_purge_cool_adj_qty := 0;

			FOR contract IN c_contract_company_id LOOP
				lv2_contract_id := contract.object_id;
			END LOOP;

			IF lv2_contract_id IS NOT NULL THEN

				FOR pc_adj IN c_purge_cool_app_adj(lv2_contract_id) LOOP

					ln_purge_cool_adj_qty := pc_adj.qty;

				END LOOP;

			END IF;
		END IF;
	END IF;

	return nvl(ln_purge_cool_adj_qty,0);

END LiftingPurgeCoolEnergy;


FUNCTION NormalFlow(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING)
RETURN STRING
IS

 lv2_stream_code VARCHAR2(32);
 lv2_normal_flow_ind VARCHAR2(32);

BEGIN
    lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SWR_GP_LNG_TRAIN_FEED' THEN
        SELECT NORMAL_FLOW_IND INTO lv2_normal_flow_ind FROM DV_STRM_DAY_PC_STATUS_GAS lift WHERE daytime = p_daytime AND object_id = p_object_id AND profit_centre_id= p_profit_centre_id;
    END IF;
    return lv2_normal_flow_ind;

END NormalFlow;

FUNCTION CalculateLiftVol60F(p_parcel_no NUMBER, p_cargo_no NUMBER)

RETURN NUMBER
IS

	CURSOR c_cargo_analysis
	IS
	  SELECT analysis_no
	  FROM   DV_CARGO_ANALYSIS
	  WHERE  cargo_no = p_cargo_no
	  AND official_ind = 'Y'
	  AND product_code = 'COND'
	  AND lifting_event = 'LOAD';

	ln_density NUMBER;
	ln_lift_vol_15C NUMBER;
	ln_lift_vol_60F NUMBER := NULL;
	ln_vcf NUMBER;
	ln_analysis_no NUMBER := NULL;
	ln_product_meas_no NUMBER := NULL;


BEGIN

	SELECT PRODUCT_MEAS_NO into ln_product_meas_no FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND MEAS_ITEM = 'LIFT_COND_VOL_NET';

	ln_lift_vol_15C := EC_STORAGE_LIFTING.LOAD_VALUE(p_parcel_no,ln_product_meas_no);

	FOR analysis IN c_cargo_analysis LOOP

		ln_analysis_no := analysis.analysis_no;

		IF ln_analysis_no IS NOT NULL THEN

			ln_density := EC_CARGO_ANALYSIS_ITEM.analysis_value(ln_analysis_no,'DENSITY');

			IF ln_density IS NOT NULL THEN

				ln_vcf := ecbp_vcf.calcVCFstdDensity_SI(ln_density, 15, 15.556);

				IF ln_vcf IS NOT NULL AND ln_vcf <> 0 THEN

					ln_lift_vol_60F := ln_lift_vol_15C * ln_vcf;

				END IF;

			END IF;

		END IF;

	END LOOP;

	return ln_lift_vol_60F;

END CalculateLiftVol60F;

FUNCTION LiftingVol60F(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 ln_blmr_vol_lifter NUMBER;
 ln_denl_vol_lifter NUMBER;
 ln_lifted_vol_lifter_60F NUMBER;
 ln_lifted_vol_lifter NUMBER;
 ln_lifted_vol_total NUMBER;
 ln_lifter_split NUMBER;

 ln_denl_vol_curr NUMBER;
 ln_denl_vol_prev NUMBER;
 ln_denl_vol NUMBER;
 ln_density_15C NUMBER;
 ln_count NUMBER := 0;

CURSOR c_final_cargos(cp_stream_code VARCHAR2)
IS
  SELECT production_day, ticket_no
  FROM   DV_STRM_OIL_BATCH_EVENT
  WHERE  production_day = p_daytime
  AND object_code = cp_stream_code;

CURSOR c_partial_cargos(cp_code VARCHAR2)
IS
  SELECT object_id, cargo_no
  FROM   DV_STOR_DAY_EXPORT_STATUS
  WHERE  daytime BETWEEN (p_daytime-1) AND (p_daytime)
  AND object_code = cp_code
  GROUP BY object_id, cargo_no
  ORDER BY cargo_no ASC;

 BEGIN

	lv2_stream_code := ecdp_objects.getobjcode(p_object_id);

    IF lv2_stream_code = 'SW_GP_COND_LOAD' THEN
		-- Check if any COND quantity has been loaded
		SELECT ec_strm_day_alloc.net_vol(p_object_id,p_daytime) into ln_lifted_vol_total from dual;
		IF ln_lifted_vol_total <> 0 THEN
			-- Final quantities
			FOR cargo IN c_final_cargos('SW_GP_COND_CARGO') LOOP
				SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_COND' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
				IF ln_count > 0 THEN
					SELECT SUM(LIFTED_VOLUME) INTO ln_blmr_vol_lifter FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_COND' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
					ln_denl_vol_lifter := GetPartialLiftedVolumeByCargo(cargo.ticket_no, p_profit_centre_id, p_company_id);
					ln_lifted_vol_lifter := ln_blmr_vol_lifter - round(nvl(ln_denl_vol_lifter,0),2);
				END IF;
			END LOOP;

			-- Partial quantities
			IF ln_lifted_vol_lifter IS NULL THEN

				FOR cargo IN c_partial_cargos('STW_COND') LOOP
					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime) INTO ln_denl_vol_curr FROM dual;
					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime-1) INTO ln_denl_vol_prev FROM dual;

                    IF NVL(ln_denl_vol_curr,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_curr;
                    END IF;

					IF NVL(ln_denl_vol_prev,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_prev * -1 + nvl(ln_denl_vol, 0);
                    END IF;

					SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';

					IF ln_count > 0 THEN
					    --Item 127690 Begin
                        --Below piece of code would throw when we have mulitple parcels for same campany for a Cargo,hence commenting and re-writing the same, using SUM
						--SELECT split_pct/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
                        SELECT SUM(split_pct)/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
						--Item 127690 End

						IF (ln_lifter_split IS NOT NULL AND ln_denl_vol IS NOT NULL) THEN
							ln_denl_vol_lifter := round(ln_denl_vol * ln_lifter_split,2);
						END IF;
					END IF;
				END LOOP;
				ln_lifted_vol_lifter := ln_denl_vol_lifter;
			ELSE
				ln_denl_vol_lifter := GetPartialLiftedVolumeByDay(p_daytime, p_profit_centre_id, p_company_id, 'STW_COND');
				IF ln_denl_vol_lifter IS NOT NULL THEN
					ln_lifted_vol_lifter := ln_lifted_vol_lifter + round(ln_denl_vol_lifter,2);
				END IF;
			END IF;

			ln_density_15C := ecdp_fluid_analysis.getLastAnalysisSample(ecdp_objects.GetObjIDFromCode('STREAM','SW_GP_COND_CARGO'),'STRM_OIL_COMP','SPOT',p_daytime,'COND').density;

			IF ln_density_15C IS NOT NULL THEN
				ln_lifted_vol_lifter_60F := nvl(ln_lifted_vol_lifter * ecbp_vcf.calcVCFstdDensity_SI(ln_density_15C, 15, 15.556),0);
			END IF;

		END IF;
    END IF;


	return ln_lifted_vol_lifter_60F;

END LiftingVol60F;

FUNCTION LiftingVolSTP(p_object_id STRING, p_daytime DATE, p_profit_centre_id STRING, p_company_id STRING)
RETURN NUMBER
IS

 lv2_stream_code VARCHAR2(32);
 ln_blmr_mass_lifter NUMBER;
 ln_denl_mass_lifter NUMBER;
 ln_denl_vol_lifter NUMBER;
 ln_lifted_mass_lifter NUMBER;
 ln_lifted_mass_total NUMBER;
 ln_lifter_split NUMBER;

 ln_denl_vol_curr NUMBER;
 ln_denl_vol_prev NUMBER;
 ln_denl_vol NUMBER;

 ln_lifted_mass NUMBER;

 lofa_sample_row object_fluid_analysis%ROWTYPE;
 lv2_analysis_unit VARCHAR2(32);
 lv2_target_unit VARCHAR2(32);
 ln_count NUMBER := 0;


CURSOR c_final_cargos(cp_stream_code VARCHAR2)
IS
  SELECT production_day, ticket_no
  FROM   DV_STRM_OIL_BATCH_EVENT
  WHERE  production_day = p_daytime
  AND object_code = cp_stream_code;

CURSOR c_partial_cargos(cp_code VARCHAR2)
IS
  SELECT object_id, cargo_no
  FROM   DV_STOR_DAY_EXPORT_STATUS
  WHERE  daytime BETWEEN (p_daytime-1) AND (p_daytime)
  AND object_code = cp_code
  GROUP BY object_id, cargo_no
  ORDER BY cargo_no ASC;

BEGIN

	lv2_stream_code := ecdp_objects.getobjcode(p_object_id);
    IF lv2_stream_code = 'SW_GP_LNG_LOAD' THEN
		-- Check if any LNG quantity has been loaded
		SELECT ec_strm_day_alloc.net_mass(p_object_id,p_daytime) into ln_lifted_mass_total from dual;
		IF ln_lifted_mass_total <> 0 THEN
			-- Final quantities
			FOR cargo IN c_final_cargos('SW_GP_LNG_CARGO') LOOP
				SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_LNG' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
				IF ln_count > 0 THEN
					SELECT SUM(LIFTED_MASS_PAA) INTO ln_blmr_mass_lifter FROM DV_STORAGE_LIFT_NOM_BLMR lift WHERE BL_DATE = cargo.production_day AND CARGO_NO = cargo.ticket_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND (SELECT CODE FROM OBJECTS st WHERE st.OBJECT_ID = lift.OBJECT_ID) = 'STW_LNG' AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.ticket_no)) <> 'D';
					ln_denl_mass_lifter := GetPartialLiftedMassByCargo(cargo.ticket_no, p_profit_centre_id, p_company_id, 'STW_LNG');
					ln_lifted_mass_lifter := ln_blmr_mass_lifter - round(nvl(ln_denl_mass_lifter,0),2);
				END IF;
			END LOOP;

			-- Partial quantities
			IF ln_lifted_mass_lifter IS NULL THEN

				FOR cargo IN c_partial_cargos('STW_LNG') LOOP

					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime) INTO ln_denl_vol_curr FROM dual;
					SELECT ec_stor_period_export_status.export_qty(cargo.object_id,cargo.cargo_no,p_daytime-1) INTO ln_denl_vol_prev FROM dual;

					IF NVL(ln_denl_vol_curr,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_curr;
					END IF;

					IF NVL(ln_denl_vol_prev,0) <> 0 THEN
						ln_denl_vol := ln_denl_vol_prev * -1 + nvl(ln_denl_vol, 0);
					END IF;

					SELECT count(*) INTO ln_count FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';

					IF ln_count > 0 THEN
                        --Item 127690 Begin
                        --Below piece of code would throw when we have mulitple parcels for same campany for a Cargo,hence commenting and re-writing the same, using SUM
						--SELECT split_pct/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
						SELECT SUM(split_pct)/100 INTO ln_lifter_split FROM DV_STORAGE_LIFT_NOM_BLMR WHERE CARGO_NO = cargo.cargo_no AND ec_lifting_account.profit_centre_id(LIFTING_ACCOUNT_ID) = p_profit_centre_id AND ec_lifting_account.company_id(LIFTING_ACCOUNT_ID) = p_company_id AND ecbp_cargo_status.getEcCargoStatus(ec_cargo_transport.cargo_status(cargo.cargo_no)) <> 'D';
                        --Item 127690 End

						IF (ln_lifter_split IS NOT NULL AND ln_denl_vol IS NOT NULL) THEN

							ln_denl_vol_lifter := round(ln_denl_vol * ln_lifter_split,2);

							lv2_analysis_unit := EcDp_Unit.GetUnitFromLogical(EcDp_ClassMeta_cnfg.getUomCode('STRM_LNG_ANALYSIS', 'DENSITY'));
							lv2_target_unit := EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_PAA_MASS') || 'PER' || EC_LIFTING_MEASUREMENT_ITEM.UNIT('LIFT_NET_M3');

							lofa_sample_row := Ecdp_Fluid_Analysis.getLastAnalysisSample(ec_stream.object_id_by_uk('SW_GP_LNG_CARGO'), 'STRM_LNG_COMP', NULL, p_daytime, 'LNG');
							ln_denl_mass_lifter := ln_denl_vol_lifter * EcDp_Unit.ConvertValue(lofa_sample_row.density, lv2_analysis_unit, lv2_target_unit);

						END IF;
					END IF;

				END LOOP;

				ln_lifted_mass_lifter := ln_denl_mass_lifter;

			ELSE
				ln_denl_mass_lifter := GetPartialLiftedMassByDay(p_daytime, p_profit_centre_id, p_company_id, 'STW_LNG');
				IF ln_denl_mass_lifter IS NOT NULL THEN
					ln_lifted_mass_lifter := ln_lifted_mass_lifter + round(ln_denl_mass_lifter,2);
				END IF;
			END IF;

			ln_lifted_mass_lifter := nvl(ue_ct_report_calcs.CalcVolFromLNGMass(p_object_id, p_daytime, ln_lifted_mass_lifter, ec_stream.object_id_by_uk('SW_GP_LNG_LOAD'),'Y'),0);

		END IF;
    END IF;

	return ln_lifted_mass_lifter;

END LiftingVolSTP;

-- Item 127642 Begin
-------------------------------------------------------------------------
--
-- FUNCTION CalcPartliftVol60F
--
-- Date           Whom  Change Description
-- -----------    ----  ------------------------------------------
-- 12/04/2018     GEDV  Initial version
-------------------------------------------------------------------------
FUNCTION CalcPartliftVol60F(p_daytime DATE, p_profit_centre_id STRING, p_lifting_acct_id STRING, p_object_id STRING, p_parcel_no NUMBER, p_cargo NUMBER)
RETURN NUMBER
IS

    CURSOR c_cargo_analysis
    IS
      SELECT analysis_no
      FROM   DV_CARGO_ANALYSIS
      WHERE  cargo_no = p_cargo
      AND official_ind = 'Y'
      AND product_code = 'COND'
      AND lifting_event = 'LOAD';

 v_partLift60 number;
 v_partLift number;
 ln_density NUMBER;
 ln_vcf NUMBER;
 ln_analysis_no NUMBER:=NULL;


BEGIN
    v_partLift:=UE_CT_STRM_DAY_PC_UPG_ALLOC.GetPartialLiftedVolumeByDay(p_daytime, p_profit_centre_id, ec_lifting_account.company_id(p_lifting_acct_id), ECDP_OBJECTS.GETOBJCODE(p_object_id), EC_CT_LIFTING_NUMBERS.LIFTING_NUMBER(p_parcel_no));

    FOR analysis IN c_cargo_analysis LOOP

        ln_analysis_no := analysis.analysis_no;

     IF ln_analysis_no IS NOT NULL THEN

            ln_density := EC_CARGO_ANALYSIS_ITEM.analysis_value(ln_analysis_no,'DENSITY');

            IF ln_density IS NOT NULL THEN

                ln_vcf := ecbp_vcf.calcVCFstdDensity_SI(ln_density, 15, 15.556);

                IF ln_vcf IS NOT NULL AND ln_vcf <> 0 THEN

                    v_partLift60:= v_partLift * ln_vcf;

                END IF;

            END IF;

        END IF;

    END LOOP;

    RETURN v_partLift60;

END CalcPartliftVol60F;
-- Item 127642 End

-- Item 127718 Begin
FUNCTION calculateVCF (p_cargo_no NUMBER)
   RETURN NUMBER
IS
   CURSOR c_cargo_analysis
   IS
      SELECT analysis_no
        FROM DV_CARGO_ANALYSIS
       WHERE     cargo_no = p_cargo_no
             AND official_ind = 'Y'
             AND product_code = 'COND'
             AND lifting_event = 'LOAD';

   ln_density       NUMBER;
   ln_vcf           NUMBER;
   ln_analysis_no   NUMBER := NULL;
BEGIN
   FOR analysis IN c_cargo_analysis
   LOOP
      ln_analysis_no := analysis.analysis_no;

      IF ln_analysis_no IS NOT NULL
      THEN
         ln_density := EC_CARGO_ANALYSIS_ITEM.analysis_value (ln_analysis_no, 'DENSITY');

         IF ln_density IS NOT NULL
         THEN
            ln_vcf := ecbp_vcf.calcVCFstdDensity_SI (ln_density, 15, 15.556);
         END IF;
      END IF;
   END LOOP;

   RETURN ln_vcf;
END calculateVCF;
-- Item 127718 End

END UE_CT_STRM_DAY_PC_UPG_ALLOC;
/