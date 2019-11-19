CREATE OR REPLACE PACKAGE UE_CT_CARGO_INFO
/****************************************************************
** Package        :  UE_CT_CARGO_INFO
**
** $Revision: 1.0 $
**
** Purpose        : Contains helper logic for cargo information classes
**
** Documentation  :
**
** Created  : 01.04.2013  rygx
**
** Modification history:
**
** Date          Whom             Change description:
** ------        --------         --------------------------------------
** 01-apr-2013   rygx             Initial version
** 12-aug-2013   swgn             Added ETD calc
** 26-aug-2013   swgn             Added tank dip measurements
** 29-aug-2013   swgn             Added cargo analysis transfer
** 11-Nov-2013   tlxt              Added getProdMeasNo to get the Meas No from the actual lifting
** 08-Jun-2018   gedv             Item 128043: INC000016970606 - Added Function to calculate split_pct
** 31-Aug-2018   gedv             Item 129174: ISWR02739: Function getInvoiceAmount added to calculated invoice amount handling remainder.
** 08-Feb-2019   rjfv             Item 131306: ISWR02716: Added new Function getJDEBatchNo to update JDE Batch No format
** 23-jul-2019   wvic			  Item 132473: ISWR03114: Added a function getLiftActStartDate to be called within transferCargoAnalysis and BoL calc
*****************************************************************/
IS
  /*FUNCTION DeterminePrimaryParcelNo(p_object_id VARCHAR2, p_cargo_no NUMBER)
    RETURN NUMBER;*/
  /*EQYP 20/JAN/2015 WI 92526 CP - Business Function - Cargo Information (Official). Comment out as we are not using.
  FUNCTION DetermineLifterCargoName(p_object_id VARCHAR2, p_cargo_no NUMBER)
    RETURN VARCHAR2; */

  FUNCTION DetermineTotalNominated(p_object_id VARCHAR2, p_cargo_no NUMBER)
    RETURN NUMBER;

  FUNCTION getStorages(p_cargo_no NUMBER)
    RETURN VARCHAR2;

  FUNCTION getPRAT(p_cargo_no NUMBER, p_forecast_id VARCHAR2 DEFAULT NULL)
    RETURN DATE;

  FUNCTION getETD(p_cargo_no NUMBER, p_forecast_id VARCHAR2 DEFAULT NULL)
    RETURN DATE;

  FUNCTION measurementValidation(p_measurement_value NUMBER, p_item VARCHAR2, p_type VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION cargoWarnings(p_cargo_no NUMBER, p_attribute VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION getCargoTankDipQty(p_parcel_no NUMBER, p_measurement VARCHAR2, p_forecast_id VARCHAR2 DEFAULT NULL)
    RETURN NUMBER;

  FUNCTION getProdMeasNo(p_object_id VARCHAR2,p_meas_item VARCHAR2, p_lifting_event VARCHAR2)
    RETURN NUMBER;

  FUNCTION getCargoAnalysisValue(p_PARCEL_NO NUMBER, p_ANALYSIS_ITEM_CODE VARCHAR2 )
    RETURN NUMBER;

  FUNCTION getCargoDocumentStatus(p_REPORT_NO NUMBER, p_PARCEL_NO VARCHAR2 DEFAULT NULL, p_DOC_CODE VARCHAR2 DEFAULT NULL, p_ORIGINAL VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;

  PROCEDURE prepareCargoDocMessage(p_parcel_no NUMBER);

  FUNCTION convertUnitInner(p_value NUMBER, p_item_code VARCHAR2, p_class_name VARCHAR2, p_target_attribute VARCHAR2) RETURN NUMBER;

  PROCEDURE transferCargoAnalysis(p_parcel_no NUMBER, p_response_code OUT NUMBER, p_response_text OUT VARCHAR2);

  PROCEDURE transferCargoLoaded(p_parcel_no NUMBER, p_response_code OUT NUMBER, p_response_text OUT VARCHAR2);

  PROCEDURE synchronizeBLDate(p_parcel_no NUMBER, p_cargo_no NUMBER, p_lifting_account_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_lifting_activity_code VARCHAR2 DEFAULT NULL);

  FUNCTION getTotal_Nom_Qty(p_cargo_no NUMBER) RETURN NUMBER;

  FUNCTION getTotal_Nom_Unit(p_cargo_no NUMBER) RETURN VARCHAR2;

  FUNCTION getTotal_Load_Qty(p_cargo_no NUMBER) RETURN NUMBER;

  FUNCTION getTotal_Load_Unit(p_cargo_no NUMBER) RETURN VARCHAR2;

   FUNCTION getBerth_Name(p_cargo_no NUMBER) RETURN VARCHAR2;

   PROCEDURE UpdateSplitPCT(p_cargo_no NUMBER);

  -- Item_128043 Begin
  FUNCTION getSplitPct(split_vol number, p_cargo_no NUMBER) RETURN NUMBER;
  -- Item_128043 End

  --Begin Item 129174 gedv/fitq
  FUNCTION getInvoiceAmount(p_total_amount number, p_cargo_no NUMBER, p_parcel_no NUMBER) RETURN NUMBER;
  --End Item 129174 gedv/fitq

  --Item 131306 Begin
  FUNCTION getJDEBatchNo(p_cargo_no NUMBER, p_batch_no VARCHAR2) RETURN VARCHAR2;
  --Item 131306 End
  
  -- Item 132473: new function to retrieve the Lifting Activity start date for a given parcel.
  FUNCTION getLiftActStartDate (p_parcel_no NUMBER) RETURN DATE;
  -- End Item 132473
  
  END UE_CT_CARGO_INFO;
  /
create or replace PACKAGE BODY UE_CT_CARGO_INFO
/****************************************************************
** Package        :  UE_CT_CARGO_INFO
**
** $Revision: 1.0 $
**
** Purpose        : Contains helper logic for cargo information classes
**
** Documentation  :
**
** Created  : 01.04.2013  rygx
**
** Modification history:
**
** Date          Whom             Change description:
** ------        --------         --------------------------------------
** 01-apr-2013   rygx             Initial version
** 12-aug-2013   swgn             Added ETD calc
** 26-aug-2013   swgn             Added tank dip measurements
** 29-aug-2013   swgn             Added cargo analysis transfer
** 11-Nov-2013   tlxt			  Added getProdMeasNo to get the Meas No from the actual lifting
** 27-feb-2014   swgn             Added functions to synchronize BL dates and determine cargo doc status
** 13-apr-2014   swgn             A number of bug fixes across the package
** 14-nov-2016   cvmk             112304 - Modified getETD()
** 22-DEC-2017   tlxt             Item 125742: updated CargoWarning to include validation for Fix_ind etc ISWR02148
** 15-may-2018   eseq             Item 127686: ISWR02347-WHS PA - Purge Quantity For Allocation
** 08-Jun-2018   gedv             Item 128043: INC000016970606 - Added Function to calculate spilt_pct
** 25-Jul-2018   kawf             Item 128651: cargoWarnings() - Added warning condition
** 31-Aug-2018   gedv/fitq        Item 129174: ISWR02739: Function getInvoiceAmount added to calculated invoice amount handling remainder.
** 08-Feb-2019   rjfv             Item 131306: ISWR02716: Added new Function getJDEBatchNo to update JDE Batch No format
** 20-jun-2019	 hqep			  Item 132473: ISWR03114: Added logic in procedure transferCargoAnalysis to get valid_from_date from Cargo Activity Timesheet
** 23-jul-2019   wvic			  Item 132473: ISWR03114: Added a function getLiftActStartDate to be called within transferCargoAnalysis and BoL calc
** 17-Sep-2019   hygf             Item 132473: ISWR03114: If we have two different analysis on same date (VALID_FROM date) then we need to consider latest analysis (DAYTIME) record. So the previous analysis record should be REJECTED and latest record should get inserted.            
*****************************************************************/
IS
-- Item 132374 Begin: new global variables
	gv_lift_act_code_lng VARCHAR2(32) := 'LNG_RAMP_UP_COMPLETE';
	gv_lift_act_code_cond VARCHAR2(32) := 'COND_RAMP_UP';
-- Item 132374 End

  -------------------------------------------------------------------------------------------------------------
  --
  -- Returns the parcel number of the primary parcel
  --
  -------------------------------------------------------------------------------------------------------------
  /* LBFK - This may not be needed for WST */
  /*FUNCTION DeterminePrimaryParcelNo(p_object_id VARCHAR2, p_cargo_no NUMBER)
    RETURN NUMBER
  IS
    CURSOR primary_cargoes
    IS
      SELECT *
      FROM   dv_storage_lift_nomination
      WHERE  object_id = nvl(p_object_id, object_id) --storage object id
      AND    cargo_no = p_cargo_no --cargo number of the storage lift nomination
      AND    primary_ind = 'Y';

    v_lifter_cargo_name NUMBER;
  BEGIN

    FOR p_c IN primary_cargoes LOOP
      v_lifter_cargo_name := p_c.parcel_no;
      RETURN v_lifter_cargo_name;
    END LOOP;

  END DeterminePrimaryParcelNo;*/

  -------------------------------------------------------------------------------------------------------------
  --
  -- Returns the total qty nominated for the given cargo against the given storage
  --
  -------------------------------------------------------------------------------------------------------------
  FUNCTION DetermineTotalNominated(p_object_id VARCHAR2, p_cargo_no NUMBER)
    RETURN NUMBER
  IS
    v_return_value NUMBER := 0;
  BEGIN

    SELECT sum(NOM_GRS_VOL) INTO v_return_value
    FROM dv_storage_lift_nomination
    WHERE cargo_no = p_cargo_no
    AND object_id = p_object_id;

    RETURN v_return_value;
  END DetermineTotalNominated;
 -------------------------------------------------------------------------------------------------------------
  --
  -- Determines the "Lifter Cargo Name" for a given cargo, based on the primary parcel
  --
  -------------------------------------------------------------------------------------------------------------
 /*
 EQYP 20/JAN/2015 WI 92526 CP - Business Function - Cargo Information (Official). Comment out as we are not using.
 FUNCTION DetermineLifterCargoName(p_object_id VARCHAR2, p_cargo_no NUMBER)
    RETURN VARCHAR2
  IS
    CURSOR primary_cargoes
    IS
      SELECT *
      FROM   dv_storage_lift_nomination
      WHERE  object_id = p_object_id --storage object id
      AND    cargo_no = p_cargo_no; --cargo number of the storage lift nomination
      --AND    primary_ind = 'Y';

    v_lifter_cargo_name VARCHAR2(240);
  BEGIN

    FOR p_c IN primary_cargoes LOOP
      v_lifter_cargo_name := p_c.lifter_cargo_name;
      RETURN v_lifter_cargo_name;
    END LOOP;

  END DetermineLifterCargoName; */
  -------------------------------------------------------------------------------------------------------------
  --
  -- Gets a user-readable list of storages for a specific cargo
  --
  -------------------------------------------------------------------------------------------------------------
  FUNCTION getStorages(p_cargo_no NUMBER)
    RETURN VARCHAR2
  IS
    CURSOR c_storage(p_cargo_no NUMBER)
    IS
      SELECT DISTINCT object_id
      FROM   storage_lift_nomination pa
      WHERE  pa.cargo_no = p_cargo_no;

    ls_stor_string VARCHAR2(255);
    ln_count NUMBER := 1;
  BEGIN

    FOR StorageCur IN c_storage(p_cargo_no) LOOP

      IF ln_count = 1 THEN
        ls_stor_string := StorageCur.object_id;
      ELSE
        ls_stor_string := ls_stor_string || ' \ ' || StorageCur.object_id;
      END IF;

      ln_count := ln_count + 1;
    END LOOP;

    RETURN ls_stor_string;

  END getStorages;

  -------------------------------------------------------------------------------------------------------------
  --
  -- Gets the preliminary required arrival time for a given cargo
  --
  -------------------------------------------------------------------------------------------------------------
  FUNCTION getPRAT(p_cargo_no NUMBER, p_forecast_id VARCHAR2 DEFAULT NULL)
    RETURN DATE
  IS
    CURSOR c_liftings(cp_cargo_no NUMBER)
    IS
      SELECT parcel_no, START_LIFTING_DATE, object_id
      FROM   storage_lift_nomination
      WHERE  cargo_no = cp_cargo_no
      AND    START_LIFTING_DATE = (SELECT MIN(x.START_LIFTING_DATE)
                                   FROM   storage_lift_nomination x
                                   WHERE  x.cargo_no = cp_cargo_no);

    CURSOR c_fcst_liftings(cp_cargo_no NUMBER, cp_forecast_id VARCHAR2)
    IS
      SELECT parcel_no, START_LIFTING_DATE, object_id
      FROM   stor_fcst_lift_nom
      WHERE  cargo_no = cp_cargo_no
      AND    forecast_id = cp_forecast_id
      AND    START_LIFTING_DATE = (SELECT MIN(x.START_LIFTING_DATE)
                                   FROM   stor_fcst_lift_nom x
                                   WHERE  x.cargo_no = cp_cargo_no
                                   AND    x.forecast_id = cp_forecast_id);

    v_first_lifting NUMBER;
    v_nom_date_time DATE;
    v_storage_id VARCHAR2(32);
  BEGIN

    IF p_forecast_id IS NULL THEN
        FOR item IN c_liftings(p_cargo_no) LOOP
          v_first_lifting := item.parcel_no;
          v_nom_date_time := item.START_LIFTING_DATE;
          v_storage_id := item.object_id;
        END LOOP;
    ELSE
        FOR item IN c_fcst_liftings(p_cargo_no, p_forecast_id) LOOP
          v_first_lifting := item.parcel_no;
          v_nom_date_time := item.START_LIFTING_DATE;
          v_storage_id := item.object_id;
        END LOOP;
    END IF;

    IF (v_nom_date_time IS NOT NULL) THEN
      IF p_forecast_id IS NULL THEN
        RETURN v_nom_date_time - NVL(ue_ct_leadtime.calc_eta_lt(v_storage_id, v_first_lifting, NULL, 'STOR'), 0);
      ELSE
        RETURN v_nom_date_time - NVL(ue_ct_leadtime.calc_eta_lt(v_storage_id, v_first_lifting, p_forecast_id, 'FCST'), 0);
      END IF;
    END IF;

    RETURN TO_DATE('01-JAN-2000', 'DD-MON-YYYY');

  END getPRAT;

  -------------------------------------------------------------------------------------------------------------
  --
  -- Gets the estimated time of departure for a given cargo
  --
  -------------------------------------------------------------------------------------------------------------
  FUNCTION getETD(p_cargo_no NUMBER, p_forecast_id VARCHAR2 DEFAULT NULL)
    RETURN DATE
  IS
    CURSOR c_liftings(cp_cargo_no NUMBER)
    IS
      SELECT parcel_no, START_LIFTING_DATE, object_id
      FROM   storage_lift_nomination
      WHERE  cargo_no = cp_cargo_no
      AND    START_LIFTING_DATE = (SELECT MIN(x.START_LIFTING_DATE)
                                   FROM   storage_lift_nomination x
                                   WHERE  x.cargo_no = cp_cargo_no);

    CURSOR c_fcst_liftings(cp_cargo_no NUMBER, cp_forecast_id VARCHAR2)
    IS
      SELECT parcel_no, START_LIFTING_DATE, object_id
      FROM   stor_fcst_lift_nom
      WHERE  cargo_no = cp_cargo_no
      AND    forecast_id = cp_forecast_id
      AND    START_LIFTING_DATE = (SELECT MIN(x.START_LIFTING_DATE)
                                   FROM   stor_fcst_lift_nom x
                                   WHERE  x.cargo_no = cp_cargo_no
                                   AND    x.forecast_id = cp_forecast_id);

    v_first_lifting NUMBER;
    v_nom_date_time DATE;
    v_storage_id VARCHAR2(32);

    --Item 112304: Begin
    v_return_value DATE;
    --Item 112304: End

  BEGIN

    IF p_forecast_id IS NULL THEN
    --Item 112304: Begin
        /*
        RETURN ue_ct_leadtime.convert_cargo_timeline(p_cargo_no, 'ETD');
        */
        v_return_value := ue_ct_leadtime.convert_cargo_timeline(p_cargo_no, 'ETD');

        RETURN TRUNC(v_return_value) + CEIL((v_return_value - TRUNC(v_return_value)) * (24))/24;

    -- Item 112304: End
    ELSE
        FOR item IN c_fcst_liftings(p_cargo_no, p_forecast_id) LOOP
          v_first_lifting := item.parcel_no;
          v_nom_date_time := item.START_LIFTING_DATE;
          v_storage_id := item.object_id;
        END LOOP;

    -- Item 112304: Begin
        /*
        RETURN ue_Ct_leadtime.calc_combine_etd_lt(v_storage_id, v_first_lifting, p_forecast_id, 'FCST');
        */
        v_return_value := ue_Ct_leadtime.calc_combine_etd_lt(v_storage_id, v_first_lifting, p_forecast_id, 'FCST');

        RETURN TRUNC(v_return_value) + CEIL((v_return_value - TRUNC(v_return_value)) * (24))/24;
    -- Item 112304: End

    END IF;

    --RETURN ec_cargo_transport.est_arrival(p_cargo_no); dv_storage_lift_nomination
    RETURN TO_DATE('01-JAN-2000', 'DD-MON-YYYY');

  END getETD;

  -------------------------------------------------------------------------------------------------------------
  --
  -- Gets a virtual split percentage between two parcels on the same cargo
  --
  -------------------------------------------------------------------------------------------------------------
  FUNCTION getParcelSplitPercentage(p_cargo_no NUMBER, p_parcel_no NUMBER)
    RETURN NUMBER
  IS

    CURSOR stream_events
    IS
      SELECT *
      FROM   dv_tank_oil_batch_exp
      WHERE  TICKET_NO = p_cargo_no;

    v_actual_volume NUMBER := 0;
    v_fixed_nominated NUMBER := 0;
    v_non_fixed_nominated NUMBER := 0;
    v_sum NUMBER := 0;

  BEGIN

    FOR item IN stream_events LOOP
        v_actual_volume := v_actual_volume + item.std_net_oil_vol;
    END LOOP;

    SELECT nvl(sum(grs_vol_nominated), 0) INTO v_non_fixed_nominated
    FROM storage_lift_nomination
    WHERE cargo_no = p_cargo_no
    AND nvl(fixed_ind, 'N') = 'N';

    SELECT nvl(sum(grs_vol_nominated), 0) INTO v_fixed_nominated
    FROM storage_lift_nomination
    WHERE cargo_no = p_cargo_no
    AND nvl(fixed_ind, 'N') = 'Y';

    IF v_actual_volume = 0 THEN
        RETURN 0;
    END IF;

    IF NVL(ec_storage_lift_nomination.fixed_ind(p_parcel_no), 'N') = 'Y' THEN
        RETURN ec_storage_lift_nomination.grs_vol_nominated(p_parcel_no) / v_actual_volume;
    ELSE
        IF v_non_fixed_nominated = 0 THEN
            RETURN 0;
        ELSE
            RETURN (v_actual_volume - v_fixed_nominated) * (ec_storage_lift_nomination.grs_vol_nominated(p_parcel_no) / v_non_fixed_nominated) / v_actual_volume;
        END IF;
    END IF;

  END getParcelSplitPercentage;

  -------------------------------------------------------------------------------------------------------------
  --
  -- Returns summations of dual-tank-dip quantities for a cargo
  --
  -------------------------------------------------------------------------------------------------------------
  FUNCTION getCargoTankDipQty(p_parcel_no NUMBER, p_measurement VARCHAR2, p_forecast_id VARCHAR2 DEFAULT NULL)
    RETURN NUMBER
  IS
    v_cargo_no NUMBER := ec_storage_lift_nomination.cargo_no(p_parcel_no);

    CURSOR stor_fcst_graph(cp_open_close VARCHAR2) IS
    SELECT *
    FROM table(ue_stor_fcst_balance.calcStorageLevelTable(ec_stor_fcst_lift_nom.object_id(p_parcel_no, p_forecast_id),
                                                               p_forecast_id,
                                                               NULL,
                                                               NULL,
                                                               p_parcel_no,
                                                               cp_open_close));

    CURSOR storage_graph(cp_open_close VARCHAR2) IS -- 101203: Get baseline values
    SELECT *
    FROM table(ue_trans_storage_balance.calcStorageLevelTable(ec_storage_lift_nomination.object_id(p_parcel_no),
                                                               NULL,
                                                               NULL,
                                                               p_parcel_no,
                                                               cp_open_close));

    CURSOR stream_events
    IS
      SELECT *
      FROM   dv_tank_oil_batch_exp
      WHERE  TICKET_NO = v_cargo_no;

    v_return_value NUMBER := 0;
    v_total_volume NUMBER := 0;
    v_split NUMBER := 0;
    v_wat_mass_unit VARCHAR2(32);
    v_wat_vol_unit VARCHAR2(32);
    v_start_volume NUMBER := 0;
  BEGIN

    SELECT NVL(SUBSTR(max(unit), 0, INSTR(max(unit), 'PER') - 1), max(unit)),
           NVL(SUBSTR(max(unit), INSTR(max(unit), 'PER') + 3), max(unit))
           INTO v_wat_mass_unit, v_wat_vol_unit
    FROM ctrl_uom_setup
    WHERE measurement_type='WATER_DENS'
    AND db_unit_ind = 'Y';

    -- If asking for opening volume
    IF p_measurement = 'OPENING_VOL' THEN

      IF p_forecast_id IS NOT NULL THEN -- Asking to calculate forecast value

        FOR item IN stor_fcst_graph('OPEN') LOOP
            v_return_value := item.storage_level;
        END LOOP;

        RETURN v_return_value;

      ELSIF p_forecast_id IS NULL THEN -- 94425: Get baseline values

        FOR item IN storage_graph('OPEN') LOOP
            v_return_value := item.storage_level;
        END LOOP;

        RETURN v_return_value;

      END IF;
    END IF;

    -- If asking for closing volume
    IF p_measurement = 'CLOSING_VOL' THEN

      IF p_forecast_id IS NOT NULL THEN -- Asking to calculate forecast value UE_CT_CARGO_INFO

        FOR item IN stor_fcst_graph('CLOSE') LOOP
            v_return_value := item.storage_level;
        END LOOP;

        RETURN v_return_value;

      ELSIF p_forecast_id IS NULL THEN

        FOR item IN storage_graph('CLOSE') LOOP
            v_return_value := item.storage_level;
        END LOOP;

        RETURN v_return_value;

      END IF;

    END IF;

    -- If asking for dual tank dip totals
    IF p_measurement IN ('NET_VOL', 'GRS_VOL', 'NET_MASS', 'GRS_MASS','NET_MASS_AIR', 'GRS_MASS_AIR', 'NET_OIL_VOL_BBL', 'GRS_OIL_VOL_BBL') THEN

        -- Get the total amount loaded
        FOR item IN stream_events LOOP

          IF p_measurement = 'NET_VOL' THEN
            v_return_value := v_return_value + item.std_net_oil_vol;
          ELSIF p_measurement = 'GRS_VOL' THEN -- Include the net change in free water in the gross volume
            v_return_value := v_return_value + item.std_grs_oil_vol + EcBp_Tank.FindFreeWaterVol(item.export_tank, 'DUAL_DIP_OPENING', item.daytime) - EcBp_Tank.FindFreeWaterVol(item.export_tank, 'DUAL_DIP_CLOSING', item.daytime);
          ELSIF p_measurement = 'NET_MASS' THEN
            v_return_value := v_return_value + item.std_net_liq_mass;
          ELSIF p_measurement = 'NET_MASS_AIR' THEN
            v_return_value := v_return_value + item.net_mass_oil_air;
          ELSIF p_measurement = 'GRS_MASS' THEN -- Include the net change in free water in the gross mass. Use unit conversions to ensure that the water density is used correctly.
            v_return_value := v_return_value + item.std_grs_liq_mass + EcDp_Unit.convertvalue(EcDp_Unit.convertValue((EcBp_Tank.FindFreeWaterVol(item.export_tank, 'DUAL_DIP_OPENING', item.daytime)
                                                                                               - EcBp_Tank.FindFreeWaterVol(item.export_tank, 'DUAL_DIP_CLOSING', item.daytime)), EcDp_Unit.getunitfromlogical(ec_class_attr_property_cnfg.property_value('TANK_OIL_BATCH_EXP_DET','FREE_WAT_VOL','UOM_CODE','VIEWLAYER',2500,'/')), v_wat_vol_unit)
                                                                                               * EcDp_System.getWaterDensity,
                                                                                              v_wat_mass_unit, EcDp_Unit.getunitfromlogical(ec_class_attr_property_cnfg.property_value('TANK_OIL_BATCH_EXP','STD_GRS_LIQ_MASS','UOM_CODE','VIEWLAYER',2500,'/')));
		  ELSIF p_measurement = 'GRS_MASS_AIR' THEN
		    v_return_value := v_return_value + item.grs_mass_oil_air;
		  ELSIF p_measurement = 'NET_OIL_VOL_BBL' THEN
		    v_return_value := v_return_value + item.std_net_oil_vol_bbl;
		  ELSIF p_measurement = 'GRS_OIL_VOL_BBL' THEN
		    v_return_value := v_return_value + item.std_grs_oil_vol_bbl;

          END IF;

        END LOOP;

        --tlxt: 98520 the split will be done in Calculation based on the actual BLMR input
		--v_split := getParcelSplitPercentage(v_cargo_no, p_parcel_no);
		v_split := 1;
		--end edit


        RETURN v_split * (v_return_value);

     END IF;

  END getCargoTankDipQty;

  -------------------------------------------------------------------------------------------------------------
  --
  -- Returns measurement validation warning
  --
  -------------------------------------------------------------------------------------------------------------
  FUNCTION measurementValidation(p_measurement_value NUMBER, p_item VARCHAR2, p_type VARCHAR2)
    RETURN VARCHAR2
  IS
    v_min NUMBER;
    v_max NUMBER;
    v_unit VARCHAR2(32);
  BEGIN

    IF p_type = 'MEASUREMENT' THEN

        v_unit := ec_lifting_measurement_item.unit(p_item);
        v_min := ec_lifting_measurement_item.value_10(p_item);
        v_max := ec_lifting_measurement_item.value_9(p_item);

        -- This is by no means an exhaustive list! Not even close!
        IF v_unit IN ('PCT','M3','SM3','HRS','TONNES','MT','KG') AND v_min IS NULL THEN
            v_min := 0;
        END IF;

        IF v_unit = 'PCT' and v_max IS NULL THEN
            v_max := 100;
        END IF;

    ELSIF p_type = 'ANALYSIS' THEN


        v_min := ec_analysis_item.value_10(p_item);
        v_max := ec_analysis_item.value_9(p_item);

        IF ec_analysis_item.component_no(p_item) IS NOT NULL THEN
            IF v_min = NULL THEN
                v_min := 0;
            END IF;
            IF v_max = NULL THEN
                v_max := 100;
            END IF;
        END IF;

    END IF;

    IF v_min IS NOT NULL AND p_measurement_value < v_min THEN
        RETURN 'verificationStatus=error;verificationText=Value below minimum spec: ' || v_min;
    END IF;

    IF v_max IS NOT NULL AND p_measurement_value > v_max THEN
        RETURN 'verificationStatus=error;verificationText=Value above maximum spec ' || v_max;
    END IF;

    RETURN '';

  END measurementValidation;

  -------------------------------------------------------------------------------------------------------------
  --
  -- Returns cargo level validation warnings
  --
  -------------------------------------------------------------------------------------------------------------
FUNCTION cargoWarnings(p_cargo_no NUMBER, p_attribute VARCHAR2)
    RETURN VARCHAR2
  IS
    v_cargo_row DV_CARGO_INFO%ROWTYPE;

	v_PARCEL_row DV_STORAGE_LIFT_NOMINATION%ROWTYPE;

	v_MSG_Cargo_row DV_CT_MSG_CARGO%ROWTYPE;

	CURSOR liftings_in_cargo IS
    SELECT object_code
    FROM dv_storage_lift_nomination
    WHERE cargo_no = p_cargo_no;

    CURSOR port_resources IS
    SELECT warning_syntax
    FROM tv_ct_port_res_usage
    WHERE cargo_no = p_cargo_no
    AND port_resource_type = 'BERTH';

    CURSOR Cargo_msg IS
    SELECT BL_NUMBER, ARRIVAL_DATE, DEPARTURE_DATE
    FROM DV_CT_MSG_CARGO
    WHERE cargo_no = p_cargo_no;


    v_return_value VARCHAR2(2500);
    v_port_res_warning_syntax VARCHAR2(2500);
    v_count NUMBER;
    v_sum NUMBER;
    v_ALL_count NUMBER;
    v_tot_vol NUMBER;
    v_ETA DATE;
    v_ETD DATE;

  BEGIN

    SELECT * INTO v_cargo_row
    FROM dv_cargo_info
    WHERE cargo_no = p_cargo_no;

	--tlxt: 109646: 02-jun-2016: MA - Cargo_Info - Validation when change of Cargo Status from "R" to "C"
	--this is to ensure the requried elements in in the system before generating the xml
/*
	SELECT * INTO v_MSG_Cargo_row
	FROM DV_CT_MSG_CARGO
	WHERE cargo_no = p_cargo_no;
*/
	v_return_value := 'OK';
	FOR MSG_CUR IN Cargo_msg LOOP
		IF v_return_value = 'OK'  THEN
			IF (p_attribute = 'CT_MSG_CARGO_BL') THEN
				IF MSG_CUR.BL_NUMBER IS NULL THEN
					v_return_value := 'Missing BL Number in Bill of Lading screen';
				END IF;
			END IF;
			IF (p_attribute = 'CT_MSG_CARGO_AD') THEN
				IF MSG_CUR.ARRIVAL_DATE IS NULL THEN
					v_return_value := 'Missing Vessel Arrival in Cargo Activity Timesheet';
				END IF;
			END IF;
			IF (p_attribute = 'CT_MSG_CARGO_DD') THEN
				IF MSG_CUR.DEPARTURE_DATE IS NULL THEN
					v_return_value := 'Missing Ship Departs in Cargo Activity Timesheet';
				END IF;
			END IF;
		ELSE
			EXIT;
		END IF;
	END LOOP;

	--END EDIT

	--TLXT: 98519: 03-JUN-2015
    IF (p_attribute = 'DOC_TEMPLATE') THEN
		v_return_value := 'OK';
		SELECT COUNT(*) INTO v_count FROM DV_STOR_LIFT_NOM_DOC_RECV WHERE CARGO_NO = p_cargo_no AND TEMPLATE_CODE IS NULL;
		IF v_count > 0 THEN
			v_return_value := 'Missing Document Template in Doc Instruction';
		END IF;
    END IF;
	--END EDIT

	-- Item 125742: Begin
/*
    --TLXT: 106878
    IF (p_attribute = 'CARGO_SPLIT_STATUS') THEN
		v_return_value := 'OK';
		SELECT COUNT(SPLIT_PCT),COUNT(*),SUM(SPLIT_PCT) INTO v_count,v_ALL_count,v_sum FROM DV_STORAGE_LIFT_NOM_INFO WHERE CARGO_NO = p_cargo_no ;
		IF (v_count <> v_ALL_count) AND v_ALL_count <>  1 THEN
			v_return_value := 'Missing entries in Cargo Split';
		END IF;
		IF (v_count = v_ALL_count) and v_sum <> 100 THEN
			v_return_value := 'Sum of Cargo Split Must be 100';
		END IF;
    END IF;
    IF (p_attribute = 'CARGO_SPLIT_NOM_INFO') THEN
		v_return_value := 'OK';
		SELECT COUNT(SPLIT_PCT),COUNT(*),SUM(SPLIT_PCT) INTO v_count,v_ALL_count,v_sum FROM DV_STORAGE_LIFT_NOM_INFO WHERE CARGO_NO = p_cargo_no ;
		IF (v_count = v_ALL_count) and v_sum <> 100 THEN
			v_return_value := 'Sum of Cargo Split Must be 100';
		END IF;
    END IF;
--END TLXT
*/
    IF (p_attribute = 'CARGO_SPLIT_VAL_1') THEN
		v_return_value := '';
		SELECT COUNT(FIX_IND)
		INTO v_count
		FROM DV_STORAGE_LIFT_NOM_INFO WHERE CARGO_NO = p_cargo_no and NVL(FIX_IND,'N') = 'Y';

		SELECT COUNT(*)
		INTO v_ALL_count
		FROM DV_STORAGE_LIFT_NOM_INFO WHERE CARGO_NO = p_cargo_no ;

		IF (v_count = v_ALL_count)THEN
			v_return_value := 'verificationStatus=error;verificationText=There must be at least 1 balance parcel for each cargo';
		END IF;

		SELECT SUM(SPLIT_VOL), SUM(NOM_GRS_VOL)
		INTO v_sum , v_ALL_count
		FROM DV_STORAGE_LIFT_NOM_INFO WHERE CARGO_NO = p_cargo_no ;

		IF (v_sum <> v_ALL_count)THEN
		   -- Item 128651: Begin
		   SELECT NVL(MAX(NVL(l.LOAD_VALUE, 0)),0) -- This is to make sure that the error message shows up in Cargo Info - LC, Cargo Info - Marine, Bill of Lading screens
		     INTO v_tot_vol
			 FROM DV_STORAGE_LIFT_NOM_INFO i
			 INNER JOIN dv_storage_lifting l ON l.parcel_no = i.parcel_no
			 INNER JOIN dv_prod_meas_setup s ON s.product_meas_no = l.product_meas_no
			                                AND s.meas_item IN ( 'LIFT_TOT_COND_VOL_GRS', 'LIFT_TOT_LNG_VOL_NET')
			WHERE i.cargo_no = p_cargo_no;

		   -- Item 128651: added another condition condition
		   IF (v_sum <> v_tot_vol) THEN
		   -- Item 128651: End
            IF LENGTH(v_return_value) > 0  THEN
                 v_return_value := v_return_value || CHR(10)|| 'The sum of volume splits for a cargo must equal the sum of SLV or the actual loaded volume for the cargo;';
			ELSE
                 v_return_value := 'verificationStatus=error;verificationText=The sum of volume splits for a cargo must equal the sum of SLV or the actual loaded volume for the cargo;';
			END IF;
		   -- Item 128651: Begin
		   END IF;
		   -- Item 128651: End
		END IF;

		END IF;
/*
     IF (p_attribute = 'CARGO_SPLIT_VAL_2') THEN
		v_return_value := '';
		SELECT SUM(SPLIT_VOL), SUM(NOM_GRS_VOL)
		INTO v_sum , v_ALL_count
		FROM DV_STORAGE_LIFT_NOM_INFO WHERE CARGO_NO = p_cargo_no ;


		IF (v_sum <> v_ALL_count)THEN
			v_return_value := 'verificationStatus=error;verificationText=The sum of volume splits for a cargo must equal the sum of SLV for the cargo';
		END IF;
    END IF;
*/
	-- Item 125742: End

    IF (p_attribute = 'ANY' OR p_attribute = 'DAYS_NOTICE_7') AND nvl(v_cargo_row.days_notice_7, 'N') = 'N' AND v_cargo_row.prat - ecdp_date_time.getCurrentSysDate <= 7 THEN
        v_return_value := 'verificationStatus=error;verificationText=Missing seven-day notice';
    END IF;

    IF (p_attribute = 'ANY' OR p_attribute = 'DAYS_NOTICE_5') AND nvl(v_cargo_row.days_notice_5, 'N') = 'N' AND v_cargo_row.prat - ecdp_date_time.getCurrentSysDate <= 5 THEN
        v_return_value := 'verificationStatus=error;verificationText=Missing five-day notice';
    END IF;

    IF (p_attribute = 'ANY' OR p_attribute = 'DAYS_NOTICE_3') AND nvl(v_cargo_row.days_notice_3, 'N') = 'N' AND v_cargo_row.prat - ecdp_date_time.getCurrentSysDate <= 3 THEN
        v_return_value := 'verificationStatus=error;verificationText=Missing three-day notice';
    END IF;

    IF (p_attribute = 'ANY' OR p_attribute = 'DAYS_NOTICE_2') AND nvl(v_cargo_row.days_notice_2, 'N') = 'N' AND v_cargo_row.prat - ecdp_date_time.getCurrentSysDate <= 2 THEN
        v_return_value := 'verificationStatus=error;verificationText=Missing two-day notice';
    END IF;

    IF (p_attribute = 'ANY' OR p_attribute = 'DAYS_NOTICE_1') AND nvl(v_cargo_row.days_notice_1, 'N') = 'N' AND v_cargo_row.prat - ecdp_date_time.getCurrentSysDate <= 1 THEN
        v_return_value := 'verificationStatus=error;verificationText=Missing one-day notice';
    END IF;

--Commented out by EQYP on 17/Aug/2015. Work Item 100943
--    IF (p_attribute = 'ANY' OR p_attribute = 'CARRIER') AND NVL(ec_carrier_version.date_10(v_cargo_row.carrier_id, sysdate, '<='), to_date('01-JAN-1900', 'DD-MON-YYYY')) < v_cargo_row.prat THEN
--        v_return_value := 'verificationStatus=error;verificationText=Vessel clearance expires before it is due in port.';
--    END IF;

--tlxt: on 01-May-2015: WorkItem: 97384
    IF (p_attribute = 'ANY' OR p_attribute = 'CARRIER') AND v_cargo_row.carrier_id IS NOT NULL AND NVL(ec_carrier_version.CAPACITY_VOL(v_cargo_row.carrier_id, v_cargo_row.LOADING_START_TIME, '<='), 0) < v_cargo_row.TOTAL_NOM_QTY THEN
        v_return_value := 'verificationStatus=error;verificationText=Total Nominated Qty has exceeded Vessel Capacity. '|| 'Vessel Capacity = ' || NVL(ec_carrier_version.CAPACITY_VOL(v_cargo_row.carrier_id, v_cargo_row.LOADING_START_TIME, '<='), 0) || ', Total Nominated Qty = '||(v_cargo_row.TOTAL_NOM_QTY);
    END IF;

    IF (p_attribute = 'ANY' OR p_attribute = 'CARRIER') AND NVL(EC_CARRIER_VERSION.UNAVAILABLE_IND(v_cargo_row.carrier_id, v_cargo_row.LOADING_START_TIME, '<='), 'N') = 'Y' THEN
        v_return_value := 'verificationStatus=error;verificationText=Vessel has been set to Unavailable with the reason "' || NVL(EC_CARRIER_VERSION.UNAVAILABLE_REASON(v_cargo_row.carrier_id, v_cargo_row.LOADING_START_TIME, '<='),' ' )|| '".';
    END IF;
--end edit tlxt: on 01-May-2015: WorkItem: 97384

    IF (p_attribute = 'ANY' OR p_attribute = 'CARRIER') AND v_cargo_row.carrier_id IS NULL THEN
        FOR item IN liftings_in_cargo LOOP
            IF (item.object_code = 'STW_LNG') THEN
                IF v_cargo_row.prat - ecdp_date_time.getCurrentSysDate <= 45 THEN
                    v_return_value := 'verificationStatus=error;verificationText=Missing vessel notification';
                END IF;
                EXIT;
            ELSE
                IF v_cargo_row.prat - ecdp_date_time.getCurrentSysDate <= 10 THEN
                    v_return_value := 'verificationStatus=error;verificationText=Missing vessel notification';
                END IF;
                EXIT;
            END IF;
        END LOOP;
    END IF;
/*
    IF ((p_attribute = 'ANY' AND v_return_value IS NULL) OR p_attribute = 'BERTH') AND v_cargo_row.berth_id IS NOT NULL THEN
        FOR item IN port_resources LOOP
            IF length(nvl(item.warning_syntax, 'XXX')) > 1 THEN
                v_port_res_warning_syntax := item.warning_syntax;
            END IF;
            IF length(v_port_res_warning_syntax) > 1 THEN
                v_return_value := 'verificationStatus=error;verificationText=This berth is either not available or has a usage conflict.';
            END IF;
        END LOOP;
    END IF;
*/
	IF ((p_attribute = 'ANY' AND v_return_value IS NULL) OR p_attribute = 'BERTH') AND NVL(EC_BERTH_VERSION.OUT_OF_SERVICE(EC_CARGO_TRANSPORT.BERTH_ID(p_cargo_no), v_cargo_row.LOADING_START_TIME, '<='),'N') = 'Y' THEN
		v_return_value := 'verificationStatus=error;verificationText=This berth is out of service.';
    END IF;

    IF p_attribute = 'ANY' AND v_return_value IS NOT NULL THEN
        v_return_value := 'verificationStatus=error;verificationText=One or more required fields for this cargo are missing or invalid. Check Cargo Information for more details.';
    END IF;

    RETURN v_return_value;

  END cargoWarnings;

  -------------------------------------------------------------------------------------------------------------
  --
  -- For a given product, measurement item, and lifting event, returns the meas_no related to that combination
  --
  -------------------------------------------------------------------------------------------------------------
  FUNCTION getProdMeasNo(p_object_id VARCHAR2,p_meas_item VARCHAR2, p_lifting_event VARCHAR2)
    RETURN NUMBER
  IS

    CURSOR C_MEAS_NO
    IS
    SELECT PRODUCT_MEAS_NO
    FROM DV_PROD_MEAS_SETUP
    WHERE OBJECT_ID = p_object_id
    AND MEAS_ITEM =p_meas_item
    AND LIFTING_EVENT = p_lifting_event;

    v_return_value NUMBER := 0;

    BEGIN
    -- Get Prod Meas Item
    FOR item IN C_MEAS_NO LOOP
        v_return_value := item.PRODUCT_MEAS_NO;
    END LOOP;

    RETURN v_return_value;

  END getProdMeasNo;

--Purpose: this function is used to get the Cargo Analysis by parcel_no.
--by : tlxt@ 11-Nov-2013
  FUNCTION getCargoAnalysisValue(p_PARCEL_NO NUMBER, p_ANALYSIS_ITEM_CODE VARCHAR2 )
    RETURN NUMBER
  IS
    v_cargo_no cargo_analysis.cargo_no%TYPE := ec_storage_lift_nomination.cargo_no(p_parcel_no);
    v_analysis_no cargo_analysis.analysis_no%TYPE;

    CURSOR analysis
    IS
      SELECT *
      FROM   cargo_analysis
      WHERE  cargo_no = v_cargo_no
      AND    NVL(official_ind, 'N') = 'Y'
      AND    lifting_event = 'LOAD';

    CURSOR component_item(cp_analysis_no NUMBER)
    IS
      SELECT analysis_value
      FROM   DV_CARGO_ANALYSIS_BASIC
      WHERE  analysis_no = cp_analysis_no
      AND ANALYSIS_ITEM_CODE = p_ANALYSIS_ITEM_CODE;

    v_return_value NUMBER := 0;

    BEGIN
    -- Get analysis number
    FOR item IN analysis LOOP
      v_analysis_no := item.analysis_no;
    END LOOP;

    IF v_analysis_no IS NULL THEN
        v_return_value := NULL;
    ELSE
        FOR comp_item IN component_item(v_analysis_no) LOOP
          v_return_value := comp_item.analysis_value;
        END LOOP;
    END IF;

    RETURN v_return_value;

  END getCargoAnalysisValue;

  -------------------------------------------------------------------------------------------------------------
  --
  -- Returns 'BAD' 'GOOD' or 'OLD' depending upon the status of the cargo document (error, good, or good but outdated)
  --
  -------------------------------------------------------------------------------------------------------------
  FUNCTION getCargoDocumentStatus(p_REPORT_NO NUMBER, p_PARCEL_NO VARCHAR2 DEFAULT NULL, p_DOC_CODE VARCHAR2 DEFAULT NULL, p_ORIGINAL VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
  IS
    v_parcel_no VARCHAR2(3200) := NVL(p_parcel_no, ec_report_param.parameter_value(p_report_no, 'PARCEL_NO'));
    v_original VARCHAR2(3200) := COALESCE(p_original, ec_report_param.parameter_value(p_report_no, 'ORIGINAL'), 'N');
    v_doc_code VARCHAR2(3200) := NVL(p_doc_code, ec_report_runable.rep_group_code(ec_report.report_runable_no(p_report_no)));
    v_doc_code_name VARCHAR2(3200) := ec_prosty_codes.code_text(v_doc_code, 'CARGO_DOCUMENT');

    -- The product uses the name, not object id, in TV_CARGO_DOCUMENT, so we need the name and id as variables
    v_receiver_id VARCHAR2(3200) := ec_report_param.parameter_value(p_REPORT_NO, 'RECEIVER_ID');
    v_receiver_name VARCHAR2(2000) := ecdp_objects.GetObjName(v_receiver_id, ec_report.run_date(p_report_no));

    v_other_instance_count NUMBER;
    v_expected_count NUMBER;

  BEGIN

    -- Easy check - errored reports have a bad status
    IF ec_report.status(p_report_no) = 'ERROR' THEN
        RETURN 'BAD';
    END IF;

    -- Find out how many instances of this particular document type were created for this parcel with a higher run date and the same original status
    -- We don't query TV_CARGO_DOCUMENT because that view is incredibly inefficient when queried for its entire contents
    SELECT nvl(count(r.report_no), 0) INTO v_other_instance_count
    FROM report r
    INNER JOIN report_param parcel
    ON r.report_no = parcel.report_no
    AND parcel.parameter_name = 'PARCEL_NO'
    INNER JOIN report_param original
    ON r.report_no = original.report_no
    AND original.parameter_name = 'ORIGINAL'
    INNER JOIN report_param receiver
    ON r.report_no = receiver.report_no
    AND receiver.parameter_name = 'RECEIVER_ID'
    INNER JOIN report_runable a
    ON r.report_runable_no = a.report_runable_no
    WHERE parcel.parameter_value = v_parcel_no
    AND nvl(original.parameter_value, 'N') = v_original
    AND receiver.parameter_value = v_receiver_id
    AND a.rep_group_code = v_doc_code
    AND r.run_date > ec_report.run_date(p_report_no);

    -- If this is one of the original documents, there should not be any more recent instances of the document:
    IF v_ORIGINAL IS NOT NULL AND v_ORIGINAL <> 'N' THEN
        IF v_other_instance_count > 0 THEN
            RETURN 'OLD';
        END IF;

    ELSE -- This is a copy. We need to know how many copies can exist that are newer than this copy

        v_expected_count := NVL(ec_lift_doc_instruction.copies(v_parcel_no, v_receiver_id, v_doc_code), 0);

        -- There can be at most N - 1 other instances of this document out there
        IF v_other_instance_count >= v_expected_count THEN
            RETURN 'OLD';
        END IF;
    END IF;

    RETURN 'GOOD';

  END getCargoDocumentStatus;

  -------------------------------------------------------------------------------------------------------------
  --
  -- Fires when the user generates cargo documentation and sets up the messaging metadata for cargo documentation
  --
  -------------------------------------------------------------------------------------------------------------
  PROCEDURE prepareCargoDocMessage(p_parcel_no NUMBER)
  IS

    v_message_distribution_no NUMBER;
    --tlxt(19-may-2015)work Item: 96524: extended desciprtion(dv_message_distr_conn) for cargo generation to be pickup
    v_cargo_no VARCHAR2(32) := ec_storage_lift_nomination.cargo_no(p_parcel_no);
	v_lc_no VARCHAR2(32) := EC_CT_LIFTING_NUMBERS.LIFTING_NUMBER (p_parcel_no);
    --end edit
    v_lifting_account_id VARCHAR2(32) := ec_storage_lift_nomination.lifting_account_id(p_parcel_no);
    v_company_id VARCHAR2(32) := ec_lifting_account.company_id(v_lifting_account_id);
    v_company_code VARCHAR2(32) := ec_company.object_code(v_company_id);
    v_distribution_set_code VARCHAR2(50) := 'DS_' || v_company_code || '_CARGO_DOCS';

    CURSOR get_message_distribution (cv_parcel_no VARCHAR2) IS
    SELECT message_distribution_no, parameter_name, parameter_value, parameter_type, parameter_sub_type
    FROM tv_message_distr_param
    WHERE parameter_name = 'Cargo Generation'
    AND parameter_value = cv_parcel_no;

  BEGIN

  --tlxt: changed  to use v_lc_no instead of p_parcel_no
    FOR item IN get_message_distribution(v_lc_no) LOOP
        v_message_distribution_no := item.message_distribution_no;
    END LOOP;

    IF v_message_distribution_no IS NOT NULL THEN
        DELETE FROM dv_message_distr_conn WHERE message_distribution_no = v_message_distribution_no;
        DELETE FROM tv_message_distr_param WHERE message_distribution_no = v_message_distribution_no;
        DELETE FROM dv_message_distribution WHERE message_distribution_no = v_message_distribution_no;
    END IF;

    v_message_distribution_no := EcDp_System_Key.assignNextNumber('MESSAGE_DISTRIBUTION');

    INSERT INTO message_distribution (OBJECT_ID, FORMAT_CODE, MESSAGE_DISTRIBUTION_NO, DISTRIBUTION_SET_CODE)
    VALUES (ec_message_definition.object_id_by_uk('MSG_CARGO_DOCS'), 'XML', v_message_distribution_no, v_distribution_set_code);

	--tlxt: changed  to use v_lc_no instead of p_parcel_no
    INSERT INTO tv_message_distr_param (MESSAGE_DISTRIBUTION_NO, PARAMETER_NAME, PARAMETER_VALUE, PARAMETER_TYPE, PARAMETER_SUB_TYPE)
    VALUES (v_message_distribution_no, 'Cargo Generation', v_lc_no, 'BASIC_TYPE', 'NUMBER');

    INSERT INTO dv_message_distr_conn (MESSAGE_DISTRIBUTION_NO, DISTR_SET_CODE,DESCRIPTION)
    VALUES (v_message_distribution_no, v_distribution_set_code,('CARGO_NO: '||v_cargo_no) || ' Parcel No: '||p_parcel_no);

  END prepareCargoDocMessage;

  -------------------------------------------------------------------------------------------------------------
  --
  -- Helper method for doing unit conversions in transferCargoAnalysis and transferCargoLoaded
  --
  -------------------------------------------------------------------------------------------------------------
  FUNCTION convertUnitInner(p_value NUMBER, p_item_code VARCHAR2, p_class_name VARCHAR2, p_target_attribute VARCHAR2) RETURN NUMBER
  IS
    v_return_value NUMBER := 0;
    v_source_unit VARCHAR2(32) := ec_analysis_item.text_1(p_item_code);
    v_target_unit VARCHAR2(32) := EcDp_Unit.GetUnitFromLogical(ec_class_attr_property_cnfg.property_value(p_class_name,p_target_attribute,'UOM_CODE','VIEWLAYER',2500,'/'));
  BEGIN
    RETURN EcDp_Unit.ConvertValue(p_value, v_source_unit, v_target_unit, sysdate);
  END convertUnitInner;

  -------------------------------------------------------------------------------------------------------------
  --
  -- Transfers cargo analysis information from the marine module into the PA module
  --
  -------------------------------------------------------------------------------------------------------------
  PROCEDURE transferCargoAnalysis(p_parcel_no NUMBER, p_response_code OUT NUMBER, p_response_text OUT VARCHAR2)
  IS
    v_cargo_no cargo_analysis.cargo_no%TYPE := ec_storage_lift_nomination.cargo_no(p_parcel_no);
    v_cargo_daytime DATE := ec_storage_lift_nomination.bl_date(p_parcel_no);

    v_storage_id storage_lift_nomination.object_id%TYPE;
    v_product_code product.object_code%TYPE;
    v_analysis_no cargo_analysis.analysis_no%TYPE;
    v_strm_analysis_no object_fluid_analysis.analysis_no%TYPE;

    v_stream_id stream.object_id%TYPE;
    v_analysis_type object_fluid_analysis.analysis_type%TYPE;
    v_class_name class_cnfg.class_name%TYPE;
    v_component_set object_fluid_analysis.component_set%TYPE;

    v_existing_no_by_cargo NUMBER;
    v_existing_no_by_date NUMBER;

    v_count NUMBER;
    v_COND_analysis_no VARCHAR2(32);
	-- hqep - Item 132473: ISWR03114 : added a variable for adding a logic in procedure transferCargoAnalysis to get valid_from_date from Cargo Activity Timesheet
	v_activity_start_date date;
	--  end - Item 132473: ISWR03114

    CURSOR analysis
    IS
      SELECT *
      FROM   cargo_analysis
      WHERE  cargo_no = v_cargo_no
      AND    NVL(official_ind, 'N') = 'Y'
      AND    lifting_event = 'LOAD';

    CURSOR component_item(cp_analysis_no NUMBER)
    IS
      SELECT ec_analysis_item.COMPONENT_NO(ANALYSIS_ITEM_CODE) AS component_no, analysis_value
      FROM   dv_cargo_analysis_component
      WHERE  analysis_no = cp_analysis_no;

    CURSOR existing_analysis_by_cargo_no(cp_stream_id VARCHAR2, cp_cargo_no VARCHAR2)
    IS
      SELECT  analysis_no
      FROM    object_fluid_analysis
      WHERE   text_42 = cp_cargo_no
      AND     object_id = cp_stream_id;

    CURSOR existing_analysis_by_vfd(cp_stream_id VARCHAR2, cp_valid_from_date DATE, cp_cargo_no VARCHAR2)
    IS
      SELECT  analysis_no
      FROM    object_fluid_analysis
      WHERE   valid_from_date = trunc(cp_valid_from_date)
      AND     object_id = cp_stream_id
      AND     NVL(text_42,'XXX') <> cp_cargo_no;
--TLXT 11-OCT-2016:
    CURSOR analysis_rows(cp_stage_sample_number VARCHAR2) IS
    SELECT *
    FROM DV_CT_STAGE_COMP_ANALY_TXT
    WHERE stage_comp_analysis_no = cp_stage_sample_number;

  BEGIN

    -- Get analysis number
    FOR item IN analysis LOOP
      v_analysis_no := item.analysis_no;
    END LOOP;

    IF v_analysis_no IS NULL THEN
      p_response_code := 2;
      p_response_text := 'No approved analysis was found for cargo ' || v_cargo_no;
    END IF;

    -- Determine storage from parcel
    v_storage_id := ec_storage_lift_nomination.object_id(p_parcel_no);

    -- Determine product from storage
    v_product_code := ec_product.object_code(ec_stor_version.product_id(v_storage_id, v_cargo_daytime, '<='));

    -- Determine stream from product
    IF v_product_code = 'LNG' THEN
      v_stream_id := ec_stream.object_id_by_uk('SW_GP_LNG_CARGO');
      v_analysis_type := 'STRM_LNG_COMP';
      v_class_name := 'STRM_LNG_ANALYSIS';
    ELSE
      v_stream_id := ec_stream.object_id_by_uk('SW_GP_COND_CARGO');
      v_analysis_type := 'STRM_OIL_COMP';
      v_class_name := 'STRM_OIL_ANALYSIS';
    END IF;

    -- Item 132473: ISWR03114 -- get valid_from_date from cargo activity timesheet
    v_activity_start_date := getLiftActStartDate(p_parcel_no);

    IF v_activity_start_date IS NULL THEN
        p_response_code := 2;
        p_response_text := 'Missing ' || (CASE v_product_code WHEN 'LNG' THEN ec_lifting_activity_code.activity_name(gv_lift_act_code_lng,'LOAD')
                                                              WHEN 'COND' THEN ec_lifting_activity_code.activity_name(gv_lift_act_code_cond,'LOAD')
                                          END) || ' activity for cargo no ' || v_cargo_no;
    END IF;
    -- end--  Item 132473: ISWR03114 -- get valid_from_date from cargo activity timesheet

	-- Item 132473: ISWR03114 : Use activity start date for comparison
    --FOR item IN existing_analysis_by_vfd(v_stream_id, trunc(ec_storage_lift_nomination.bl_date_time(p_parcel_no)), v_cargo_no) LOOP
    FOR item IN existing_analysis_by_vfd(v_stream_id, trunc(v_activity_start_date), v_cargo_no) LOOP
    --Item 132473: ISWR03114 End
        v_existing_no_by_date := item.analysis_no;
    END LOOP;

    -- Do we have an analysis for this stream on this valid_from_date for a different cargo?
    IF v_existing_no_by_date IS NOT NULL THEN
        -- Compare this date to the daytime of that record
        IF ec_object_fluid_analysis.daytime(v_existing_no_by_date) < ec_storage_lift_nomination.date_9(p_parcel_no) THEN

            -- If this record is newer than the existing record, we delete it
            DELETE FROM fluid_analysis_component WHERE analysis_no = v_existing_no_by_date;
            DELETE FROM object_fluid_analysis WHERE analysis_no = v_existing_no_by_date;

	    -- Item 132473: ISWR03114 : Compare equality
        ELSIF ec_object_fluid_analysis.daytime(v_existing_no_by_date) = ec_storage_lift_nomination.DATE_9(p_parcel_no) THEN

            -- If this record is equal, then it must be the same cargo, update the cargo no
            UPDATE object_fluid_analysis set text_42 = v_cargo_no where analysis_no = v_existing_no_by_date;
	    -- Item 132473: ISWR03114
			
        ELSE
            -- If this record is older than the existing record, we do _nothing_
            RETURN;
        END IF;
    END IF;

    -- Get existing records
    FOR item IN existing_analysis_by_cargo_no(v_stream_id, v_cargo_no) LOOP
        v_existing_no_by_cargo := item.analysis_no;
    END LOOP;
       
    -- Do we have an analysis for this cargo already?
    IF v_existing_no_by_cargo IS NOT NULL THEN

        UPDATE object_fluid_analysis
        SET daytime = ec_storage_lift_nomination.DATE_9(p_parcel_no),
            -- hqep - Item 132473: ISWR03114 -- get valid_from_date from cargo activity timesheet
            -- valid_from_date = trunc(ec_storage_lift_nomination.bl_date_time(p_parcel_no)),
            valid_from_date = trunc(v_activity_start_date),
            -- end - Item 132473: ISWR03114 -- get valid_from_date from cargo activity timesheet
            gcv = convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, 'VOLUME_GHV'), 'VOLUME_GHV', v_class_name, 'GCV'),
            density = convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, DECODE(v_product_code, 'LNG', 'LNG_DENSITY_PAA', 'DENSITY')), DECODE(v_product_code, 'LNG', 'LNG_DENSITY_PAA', 'DENSITY'), v_class_name, 'DENSITY'),
            salt = convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, 'SALT'), 'SALT', v_class_name, 'SALT'),
            bs_w = convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, 'BS_W'), 'BS_W', v_class_name, 'BS_W'),
            rvp = convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, 'RVP'), 'RVP', v_class_name, 'RVP'),
            api = convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, 'API'), 'API', v_class_name, 'API'),
            value_46 = EcDp_Unit.ConvertValue(ec_storage_lifting.load_value(p_parcel_no, getProdMeasNo(ec_product.object_id_by_uk(v_product_code), 'LIFT_GHV_MASS_PAA', 'LOAD')), ec_lifting_measurement_item.unit('LIFT_GHV_MASS_PAA'), EcDp_Unit.GetUnitFromLogical('CALORIFIC_VALUE_MASS'), sysdate)
        WHERE analysis_no = v_existing_no_by_cargo;

        v_strm_analysis_no := v_existing_no_by_cargo;

    ELSE
        -- Insert latest record
        INSERT INTO object_fluid_analysis (OBJECT_ID, 
                                           DAYTIME, 
                                           ANALYSIS_TYPE, 
                                           SAMPLING_METHOD, 
                                           PHASE, 
                                           COMPONENT_SET,
                                           ANALYSIS_STATUS, 
                                           DENSITY, 
                                           SALT,
                                           BS_W, 
                                           GCV, 
                                           RVP, 
                                           API, 
                                           VALUE_46, 
                                           VALID_FROM_DATE, 
                                           TEXT_42, 
                                           RECORD_STATUS)
        VALUES (v_stream_id,
                ec_storage_lift_nomination.DATE_9(p_parcel_no),
               v_analysis_type,
               'SPOT',
               DECODE(v_product_code, 'LNG', 'LNG', 'COND'),
			   DECODE(v_product_code, 'LNG', 'STRM_LNG_COMP', 'STRM_OIL_COMP'),
               'APPROVED',
               convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, DECODE(v_product_code, 'LNG', 'LNG_DENSITY_PAA', 'DENSITY')), DECODE(v_product_code, 'LNG', 'LNG_DENSITY_PAA', 'DENSITY'), v_class_name, 'DENSITY'),
               convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, 'SALT'), 'SALT', v_class_name, 'SALT'),
               convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, 'BS_W'), 'BS_W', v_class_name, 'BS_W'),
               convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, 'VOLUME_GHV'), 'VOLUME_GHV', v_class_name, 'GCV'),
               convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, 'RVP'), 'RVP', v_class_name, 'RVP'),
               convertUnitInner(ec_cargo_analysis_item.analysis_value(v_analysis_no, 'API'), 'API', v_class_name, 'API'),
               EcDp_Unit.ConvertValue(ec_storage_lifting.load_value(p_parcel_no, getProdMeasNo(ec_product.object_id_by_uk(v_product_code), 'LIFT_GHV_MASS_PAA', 'LOAD')), ec_lifting_measurement_item.unit('LIFT_GHV_MASS_PAA'), EcDp_Unit.GetUnitFromLogical('CALORIFIC_VALUE_MASS'), sysdate),
                -- hqep - Item 132473: ISWR03114 -- changed valid_from_date to get start time from cargo activity timesheet
                -- trunc(ec_storage_lift_nomination.DATE_9(p_parcel_no)),
                trunc(v_activity_start_date),
                -- end - Item 132473: ISWR03114 --
               v_cargo_no,
               'A');

        -- Get stream analysis_no
        SELECT analysis_no, COMPONENT_SET
        INTO   v_strm_analysis_no, v_component_set
        FROM   OBJECT_FLUID_ANALYSIS
        WHERE  object_id = v_stream_id
        AND    text_42 = v_cargo_no
        AND    analysis_type = v_analysis_type;
--tlxt 11-OCT-2016: added component set
        EcDp_Fluid_Analysis.CreateCompSetForAnalysis(v_component_set, v_strm_analysis_no, ec_storage_lift_nomination.date_9(p_parcel_no));

    END IF;

    -- Insert/update component rows
    MERGE INTO fluid_analysis_component strm_an
    USING  (SELECT ec_analysis_item.component_no(analysis_item_code) component_no, analysis_value
            FROM   DV_CARGO_ANALYSIS_COMPONENT
            WHERE  ANALYSIS_NO = v_analysis_no
            AND    ec_analysis_item.component_no(analysis_item_code) IN (SELECT cs.component_no FROM tv_component_set_list cs WHERE cs.code = v_analysis_type)) car_an
    ON     (strm_an.analysis_no = v_strm_analysis_no
    AND     strm_an.component_no = car_an.component_no)
    WHEN MATCHED THEN
      UPDATE SET strm_an.mol_pct = NVL(car_an.analysis_value, 0), strm_an.record_status = 'A'
    WHEN NOT MATCHED THEN
      INSERT (ANALYSIS_NO, COMPONENT_NO, MOL_PCT, RECORD_STATUS)
      VALUES (v_strm_analysis_no, car_an.component_no, car_an.analysis_value, 'A');

    IF v_product_code = 'LNG' THEN
        UPDATE fluid_analysis_component
        SET mol_pct = 0
        WHERE mol_pct IS NULL
        AND analysis_no = v_strm_analysis_no;

        UPDATE fluid_analysis_component
        SET wt_pct = 0
        WHERE wt_pct IS NULL
        AND analysis_no = v_strm_analysis_no;
        ecdp_fluid_analysis.convCompBetweenMolWt(v_stream_id,
                                                 v_analysis_type,
                                                 'SPOT',
                                                 ec_object_fluid_analysis.daytime(v_strm_analysis_no),
                                                 NULL,
                                                 'MOL_TO_WT');
        ecdp_fluid_analysis.normalizecompto100(v_stream_id,
                                               v_analysis_type,
                                               'SPOT',
                                               ec_object_fluid_analysis.daytime(v_strm_analysis_no));
    END IF;
	--TLXT: 11-OCT-2016:If composition is not available, copy properties (Density, etc.) from Cargo to PA and carry forward the composition from the previous cargo, and make the status 'Information'
	--v_COND_analysis_no (COND:123)passed in from UE_CT_TRIGGER_ACTION  as to indicate this is condensate analysis data from staging
	ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_CARGO_INFO','v_product_code='||v_product_code);
	ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_CARGO_INFO','v_strm_analysis_no='||v_strm_analysis_no);
	IF v_product_code = 'COND' THEN
		UPDATE object_fluid_analysis
		SET ANALYSIS_STATUS = 'INFO',
		RECORD_STATUS = 'P'
		WHERE analysis_no = v_strm_analysis_no;
		v_COND_analysis_no:=UE_CT_TRIGGER_ACTION.getAnalysis_no;
		IF SUBSTR(v_COND_analysis_no,1,4) = 'COND' THEN
			FOR item IN analysis_rows(SUBSTR(v_COND_analysis_no,6,LENGTH(v_COND_analysis_no))) LOOP
				--v_existing_no_by_cargo := item.analysis_no;
				UPDATE fluid_analysis_component SET record_status = 'A' WHERE analysis_no = v_strm_analysis_no;
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.C1_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'C1';
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.C2_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'C2';
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.C3_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'C3';
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.C9_PLUS_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'C9+';
				--UPDATE fluid_analysis_component SET mol_pct = 0 WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'CO2';
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.IC4_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'IC4';
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.IC5_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'IC5';
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.N2_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'N2';
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.NC4_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'NC4';
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.NC5_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'NC5';
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.NC6_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'NC6';
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.NC7_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'NC7';
				UPDATE fluid_analysis_component SET mol_pct = NVL(round(to_number(item.NC8_MOL_NORM), 3), 0) WHERE mol_pct IS NULL AND analysis_no = v_strm_analysis_no AND COMPONENT_NO = 'NC8';
			END LOOP;


			UPDATE fluid_analysis_component
			SET mol_pct = 0
			WHERE mol_pct IS NULL
			AND analysis_no = v_strm_analysis_no;

			UPDATE fluid_analysis_component
			SET wt_pct = 0
			WHERE wt_pct IS NULL
			AND analysis_no = v_strm_analysis_no;

			ecdp_fluid_analysis.convCompBetweenMolWt(v_stream_id,
															 v_analysis_type,
															 'SPOT',
															 ec_object_fluid_analysis.daytime(v_strm_analysis_no),
															 NULL,
															 'MOL_TO_WT');

			ecdp_fluid_analysis.normalizecompto100(v_stream_id,
														   v_analysis_type,
														   'SPOT',
														   ec_object_fluid_analysis.daytime(v_strm_analysis_no));

			UPDATE object_fluid_analysis
			SET ANALYSIS_STATUS = 'APPROVED',
			RECORD_STATUS = 'A'
			WHERE analysis_no = v_strm_analysis_no
			AND ANALYSIS_STATUS = 'INFO';

		END IF;



	END IF;

  END transferCargoAnalysis;

  -------------------------------------------------------------------------------------------------------------
  --
  -- Transfers cargo loaded information from the marine module into the PA module
  --
  -------------------------------------------------------------------------------------------------------------
  PROCEDURE transferCargoLoaded(p_parcel_no NUMBER, p_response_code OUT NUMBER, p_response_text OUT VARCHAR2)
  IS
    v_cargo_no cargo_analysis.cargo_no%TYPE := ec_storage_lift_nomination.cargo_no(p_parcel_no);
    v_cargo_daytime DATE := NVL(ec_storage_lift_nomination.date_9(p_parcel_no), ec_storage_lift_nomination.bl_date(p_parcel_no));
    v_stream_id stream.object_id%TYPE;
    v_bog_stream_id stream.object_id%TYPE;
    v_purge_stream_id stream.object_id%TYPE;--Item 127686: ESEQ: Added this stream to report purge volume in LACT Screen:
    v_purge_ind VARCHAR2(32);
    v_mass_unit VARCHAR2(32);
    v_target_mass_unit VARCHAR2(32);
    v_vol_unit VARCHAR2(32);
    v_target_vol_unit VARCHAR2(32);
    v_energy_unit VARCHAR2(32);
    v_target_energy_unit VARCHAR2(32);

    v_storage_id storage_lift_nomination.object_id%TYPE;
    v_product_code product.object_code%TYPE;

    v_purging_qty NUMBER;
    v_net_mass NUMBER;
    v_net_vol NUMBER;
    v_energy NUMBER;
    v_return_bog NUMBER;

    v_dummy NUMBER;
  BEGIN
    -- Determine storage from parcel
    v_storage_id := ec_storage_lift_nomination.object_id(p_parcel_no);

    -- Determine product from storage
    v_product_code := ec_product.object_code(ec_stor_version.product_id(v_storage_id, v_cargo_daytime, '<='));

    -- Determine stream from product
    IF v_product_code = 'LNG' THEN
      v_stream_id := ec_stream.object_id_by_uk('SW_GP_LNG_CARGO');
      v_bog_stream_id := ec_stream.object_id_by_uk('SW_GP_BOG_IMPORT');
      v_purge_stream_id := ec_stream.object_id_by_uk('SW_GP_LNG_PURGE');--Item 127686: ESEQ: Added this stream to report purge volume in LACT Screen.
      v_mass_unit := ec_lifting_measurement_item.unit('LIFT_NET_PAA_MASS');
      v_target_mass_unit := EcDp_Unit.GetUnitFromLogical('LNG_MASS');
      v_vol_unit := ec_lifting_measurement_item.unit('LIFT_NET_M3');
      v_target_vol_unit := EcDp_Unit.GetUnitFromLogical('STD_LNG_VOL');
      v_energy_unit := ec_lifting_measurement_item.unit('LIFT_NET_PAA_MMBTU');
      v_target_energy_unit := ecdp_unit.GetUnitFromLogical('ENERGY');
    ELSE
      v_stream_id := ec_stream.object_id_by_uk('SW_GP_COND_CARGO');
      v_mass_unit := ec_lifting_measurement_item.unit('LIFT_COND_MASS_NET');
      v_vol_unit := ec_lifting_measurement_item.unit('LIFT_COND_VOL_NET');
      v_target_mass_unit := EcDp_Unit.GetUnitFromLogical('OIL_MASS');
      v_target_vol_unit := EcDp_Unit.GetUnitFromLogical('STD_OIL_VOL');
    END IF;

    -- Purging?
/*
    SELECT count(*) INTO v_dummy
    FROM storage_lift_nomination
    WHERE cargo_no = v_cargo_no
    AND nvl(TEXT_8, 'N') = 'Y';
	--AND nvl(purge_ind, 'N') = 'Y'; WST USING TEXT_8 WHILE GORGON USING PRODUCT'S COLUMN PURGE_IND
*/
	-- Get Purging (of there is any pruging qty, it must have return BOG purge ind checked in STRM_OIL_BATCH_EVENT as INERT)
    --Item 127686: ESEQ: Assign the Pruge Volume to :v_purging_qty
    SELECT NVL(MAX(load_value),0)
    INTO   v_purging_qty
    FROM   storage_lifting
    WHERE  parcel_no IN (SELECT x.parcel_no
                         FROM   storage_lift_nomination x
                         WHERE  x.cargo_no = v_cargo_no)
    AND    product_meas_no = (SELECT y.product_meas_no
                              FROM   dv_prod_meas_setup y
                              WHERE  y.lifting_event = 'LOAD'
                              AND    y.object_code = v_product_code
                              AND    y.meas_item IN ('PURGE_VOL'));
    --Item 127686: ESEQ:Purge Ind has got no significance as per the business hence commenting:
    /*IF v_dummy > 0 THEN
        v_purge_ind := 'Y';
    ELSE
        v_purge_ind := 'N';
    END IF;*/

    -- Get total net mass
    SELECT EcDp_Unit.ConvertValue(sum(load_value), v_mass_unit, v_target_mass_unit, sysdate)
    INTO   v_net_mass
    FROM   storage_lifting
    WHERE  parcel_no IN (SELECT x.parcel_no
                         FROM   storage_lift_nomination x
                         WHERE  x.cargo_no = v_cargo_no)
    AND    product_meas_no = (SELECT y.product_meas_no
                              FROM   dv_prod_meas_setup y
                              WHERE  y.lifting_event = 'LOAD'
                              AND    y.object_code = v_product_code
                              --TLXT: 100670: transfering PAA Mass to Cargo
                              AND    y.meas_item IN ('LIFT_NET_PAA_MASS','LIFT_COND_MASS_NET'));
							  --AND    y.meas_item IN ('LIFT_NET_MASS','LIFT_COND_MASS_NET'));

    -- Get total net volume
    SELECT EcDp_Unit.ConvertValue(sum(load_value), v_vol_unit, v_target_vol_unit, sysdate)
    INTO   v_net_vol
    FROM   storage_lifting
    WHERE  parcel_no IN (SELECT x.parcel_no
                         FROM   storage_lift_nomination x
                         WHERE  x.cargo_no = v_cargo_no)
    AND    product_meas_no = (SELECT y.product_meas_no
                              FROM   dv_prod_meas_setup y
                              WHERE  y.lifting_event = 'LOAD'
                              AND    y.object_code = v_product_code
                              AND    y.meas_item IN ('LIFT_NET_M3','LIFT_COND_VOL_NET'));

    -- Get total energy
    SELECT EcDp_Unit.ConvertValue(sum(load_value), v_energy_unit, v_target_energy_unit, sysdate)
    INTO   v_energy
    FROM   storage_lifting
    WHERE  parcel_no IN (SELECT x.parcel_no
                         FROM   storage_lift_nomination x
                         WHERE  x.cargo_no = v_cargo_no)
    AND    product_meas_no = (SELECT y.product_meas_no
                              FROM   dv_prod_meas_setup y
                              WHERE  y.lifting_event = 'LOAD'
                              AND    y.object_code = v_product_code
                              --TLXT: 100670: transfering PAA Energy to Cargo
                              AND    y.meas_item IN ('LIFT_NET_PAA_MMBTU'));
                              --AND    y.meas_item IN ('LIFT_NET_MMBTU'));

    -- Get return bog
    SELECT EcDp_Unit.ConvertValue(max(load_value), ec_lifting_measurement_item.unit('LIFT_RETURN_BOG'), EcDp_Unit.GetUnitFromLogical('STD_GAS_VOL'), sysdate)
    INTO   v_return_bog
    FROM   storage_lifting
    WHERE  parcel_no IN (SELECT x.parcel_no
                         FROM   storage_lift_nomination x
                         WHERE  x.cargo_no = v_cargo_no)
    AND    product_meas_no = (SELECT y.product_meas_no
                              FROM   dv_prod_meas_setup y
                              WHERE  y.lifting_event = 'LOAD'
                              AND    y.object_code = v_product_code
                              AND    y.meas_item = 'LIFT_RETURN_BOG');

    -- Net volume and mass
    SELECT COUNT(*)
    INTO   v_dummy
    FROM   dv_strm_oil_batch_event
    WHERE  ticket_no = v_cargo_no
    AND    object_id = v_stream_id;

    IF v_dummy > 0 THEN

      UPDATE dv_strm_oil_batch_event
      SET    net_vol = v_net_vol, ticket_vol = v_net_vol, net_mass = v_net_mass, daytime = v_cargo_daytime, end_date = v_cargo_daytime, energy = v_energy
	  , PRODUCTION_DAY = EcDp_ProductionDay.getProductionDay('STRM_OIL_BATCH_EVENT',v_stream_id,v_cargo_daytime)
      WHERE  object_id = v_stream_id
      AND    ticket_no = v_cargo_no;

    ELSE

      INSERT INTO dv_strm_oil_batch_event(object_id,
                                          event_type,
                                          daytime,
                                          end_date,
										  PRODUCTION_DAY,
                                          ticket_no,
                                          net_vol,
                                          net_mass,
                                          energy,
                                          ticket_vol)
      VALUES (v_stream_id,
              'STRM_OIL_BATCH_EVENT',
              v_cargo_daytime,
              v_cargo_daytime,
			  EcDp_ProductionDay.getProductionDay('STRM_OIL_BATCH_EVENT',v_stream_id,v_cargo_daytime),
              v_cargo_no,
              v_net_vol,
              v_net_mass,
              v_energy,
              v_net_vol);

    END IF;

    -- BOG
    IF v_product_code = 'LNG' THEN

      SELECT COUNT(*)
      INTO   v_dummy
      FROM   dv_strm_oil_batch_event
      WHERE  ticket_no = v_cargo_no
      AND    object_id = v_bog_stream_id;

      IF v_dummy > 0 THEN

        UPDATE dv_strm_oil_batch_event
        SET    net_vol = v_return_bog, ticket_vol = v_return_bog, daytime = v_cargo_daytime, end_date = v_cargo_daytime
		, PRODUCTION_DAY = EcDp_ProductionDay.getProductionDay('STRM_OIL_BATCH_EVENT',v_stream_id,v_cargo_daytime)
        WHERE  object_id = v_bog_stream_id
        AND    ticket_no = v_cargo_no;

      ELSE

        INSERT INTO dv_strm_oil_batch_event(object_id,
                                            event_type,
                                            daytime,
                                            end_date,
											PRODUCTION_DAY,
                                            ticket_no,
                                           -- purge_ind,
                                            net_vol,
                                            ticket_vol)
        VALUES (v_bog_stream_id,
                'STRM_OIL_BATCH_EVENT',
                v_cargo_daytime,
                v_cargo_daytime,
				EcDp_ProductionDay.getProductionDay('STRM_OIL_BATCH_EVENT',v_stream_id,v_cargo_daytime),
                v_cargo_no,
               -- v_purge_ind,
                v_return_bog,
                v_return_bog);

      END IF;
    --Item 127686: ESEQ: Including Purge Volume in the LACT screen for business to see if the purging happened.
      SELECT COUNT (*)
         INTO v_dummy
      FROM dv_strm_oil_batch_event
      WHERE ticket_no = v_cargo_no
      AND   object_id = v_purge_stream_id;


       IF v_dummy > 0 THEN
          UPDATE dv_strm_oil_batch_event
          SET net_vol    = v_purging_qty,
              ticket_vol = v_purging_qty,
              net_mass   = v_purging_qty * (NVL (ec_object_fluid_analysis.density (ecdp_fluid_analysis.getlastanalysisnumber (v_stream_id, 'STRM_LNG_COMP', NULL, v_cargo_daytime, 'LNG')), 1) / 1000),
              daytime    = v_cargo_daytime,
              end_date   = v_cargo_daytime
          WHERE  object_id  = v_purge_stream_id
          AND    ticket_no  = v_cargo_no;

       ELSE
          INSERT INTO dv_strm_oil_batch_event
               (object_id,
                event_type,
                daytime,
                end_date,
                ticket_no,
                net_vol,
                ticket_vol,
                net_mass)
          VALUES
               (v_purge_stream_id,
               'STRM_OIL_BATCH_EVENT',
               v_cargo_daytime,
               v_cargo_daytime,
               v_cargo_no,
               v_purging_qty,
               v_purging_qty,
               v_purging_qty * (NVL (ec_object_fluid_analysis.density (ecdp_fluid_analysis.getlastanalysisnumber (v_stream_id, 'STRM_LNG_COMP', NULL, v_cargo_daytime, 'LNG')), 1) / 1000));

       END IF;

  END IF;

  END transferCargoLoaded;

  -------------------------------------------------------------------------------------------------------------
  --
  -- When the user changes the cargo activity timesheet, this procedure ensure the bill of lading dates gets updated
  --
  -------------------------------------------------------------------------------------------------------------
  PROCEDURE synchronizeBLDate(p_parcel_no NUMBER, p_cargo_no NUMBER, p_lifting_account_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_lifting_activity_code VARCHAR2 DEFAULT NULL)
  IS

    CURSOR parcels_to_update IS
    SELECT n.parcel_no, n.cargo_no, n.lifting_account_id, ec_lift_account_version.text_9(n.lifting_account_id, n.nom_firm_date, '<=') AS bl_lifting_activity
    FROM storage_lift_nomination n
    WHERE nvl(p_parcel_no, n.parcel_no) = n.parcel_no
    AND nvl(p_cargo_no, n.cargo_no) = n.cargo_no
    AND nvl(p_lifting_account_id, n.lifting_account_id) = n.lifting_account_id
    AND nvl(p_start_date, n.nom_firm_date) <= n.nom_firm_date
    AND nvl(p_end_date, n.nom_firm_date) >= n.nom_firm_date;

    CURSOR activities(cp_cargo_no NUMBER, cp_activity_code VARCHAR2) IS
    SELECT nvl(activity_end, activity_start) AS activity_time, run_no
    FROM dv_prod_lifting_activity
    WHERE cargo_no = nvl(cp_cargo_no, -1)
    AND activity_code = cp_activity_code
    AND activity_code = nvl(p_lifting_activity_code, activity_code)
    UNION ALL
    SELECT nvl(activity_end, activity_start) AS activity_time, run_no
    FROM dv_lifting_activity
    WHERE cargo_no = nvl(cp_cargo_no, -1)
    AND activity_code = cp_activity_code
    AND activity_code = nvl(p_lifting_activity_code, activity_code)
    ORDER BY run_no ASC;

    v_timestamp DATE;

  BEGIN
    FOR item IN parcels_to_update LOOP

        v_timestamp := null;

        FOR time_item IN activities(item.cargo_no, item.bl_lifting_activity) LOOP

            IF time_item.activity_time IS NOT NULL THEN
                v_timestamp := time_item.activity_time;
            END IF;

        END LOOP;

        IF v_timestamp IS NOT NULL THEN
            UPDATE storage_lift_nomination
            SET bl_date = trunc(v_timestamp), date_9 = v_timestamp
            WHERE parcel_no = item.parcel_no;
        END IF;

    END LOOP;

  END synchronizeBLDate;

FUNCTION getTotal_Nom_Qty(p_cargo_no NUMBER) RETURN NUMBER
IS

 n_nom_qty NUMBER := 0;

BEGIN

SELECT SUM(nom_grs_vol) INTO n_nom_qty
  FROM dv_storage_lift_nom_info
 WHERE cargo_no = p_cargo_no;

RETURN n_nom_qty;

END getTotal_Nom_Qty;


FUNCTION getTotal_Nom_Unit(p_cargo_no NUMBER) RETURN VARCHAR2
IS

 v_unit VARCHAR2(32);

BEGIN

SELECT unit INTO v_unit
  FROM dv_storage_lift_nom_info
 WHERE cargo_no = p_cargo_no;

RETURN v_unit;

END getTotal_Nom_Unit;

FUNCTION getTotal_Load_Qty(p_cargo_no NUMBER) RETURN NUMBER
IS

 n_load_qty NUMBER := 0;

BEGIN

    SELECT SUM(sl.load_value) INTO n_load_qty
      FROM dv_storage_lift_nom_info slni
INNER JOIN dv_storage_lifting sl  ON sl.parcel_no = slni.parcel_no
     WHERE slni.cargo_no = p_cargo_no
       AND ec_product_meas_setup.item_code(product_meas_no) IN ('LIFT_COND_VOL_GRS','LIFT_NET_M3');

    RETURN n_load_qty;

END getTotal_Load_Qty;

FUNCTION getTotal_Load_Unit(p_cargo_no NUMBER) RETURN VARCHAR2
IS

 v_unit VARCHAR2(32);

BEGIN

    SELECT sl.unit INTO v_unit
      FROM dv_storage_lift_nom_info slni
INNER JOIN dv_storage_lifting sl  ON sl.parcel_no = slni.parcel_no
     WHERE slni.cargo_no = p_cargo_no
       AND ec_product_meas_setup.item_code(product_meas_no) IN ('LIFT_COND_VOL_GRS','LIFT_NET_M3');

    RETURN v_unit;

END getTotal_Load_Unit;

FUNCTION getBerth_Name(p_cargo_no NUMBER) RETURN VARCHAR2
IS

 v_berthID VARCHAR2(32);

BEGIN

    SELECT ci.Berth_ID INTO v_BerthID
      FROM dv_cargo_info ci
      WHERE ci.cargo_no = p_cargo_no;

    RETURN EC_BERTH_VERSION.NAME(v_BerthID, sysdate, '<=');

END getBerth_Name;

PROCEDURE UpdateSplitPCT(p_cargo_no NUMBER)
IS

ln_split NUMBER;
ln_count NUMBER;
lv_lifting_account_id VARCHAR2(32);
lv_object_id VARCHAR2(32);

CURSOR LA_SPLIT(p_object_id VARCHAR2) IS
	SELECT SPLIT_PCT, LIFTING_ACCOUNT_ID ,CARGO_NO
	  FROM DV_STORAGE_LIFT_NOM_INFO
	 WHERE OBJECT_ID = p_object_id AND CARGO_NO IN
			  (SELECT CARGO_NO
				 FROM (  SELECT CARGO_NO, DAYTIME, COUNT (*)
						   FROM DV_STORAGE_LIFT_NOM_BLMR
						  WHERE OBJECT_ID = p_object_id AND CARGO_NO IN
								   (SELECT CARGO_NO
									  FROM DV_STORAGE_LIFT_NOM_BLMR
									 WHERE     LIFTING_ACCOUNT_ID IN
												  (SELECT LIFTING_ACCOUNT_ID
													 FROM DV_STORAGE_LIFT_NOM_BLMR
													WHERE     OBJECT_ID = p_object_id
														  AND CARGO_NO = p_cargo_no)
										   AND CARGO_NO <> p_cargo_no
										   AND SPLIT_PCT IS NOT NULL
										   AND OBJECT_ID = p_object_id
										   AND DAYTIME <
												  (SELECT MAX (DAYTIME)
													 FROM DV_STORAGE_LIFT_NOM_BLMR
													WHERE     OBJECT_ID = p_object_id
														  AND CARGO_NO = p_cargo_no))
					   GROUP BY CARGO_NO, DAYTIME
						 HAVING COUNT (*) =
								   (SELECT COUNT (*)
									  FROM DV_STORAGE_LIFT_NOM_BLMR
									 WHERE     OBJECT_ID = p_object_id
										   AND CARGO_NO = p_cargo_no)
					   ORDER BY DAYTIME DESC)
				WHERE ROWNUM = 1);


BEGIN

ln_split := 0;
lv_lifting_account_id:= NULL;
ln_count := 0;

SELECT MAX(OBJECT_ID) INTO lv_object_id FROM DV_STORAGE_LIFT_NOM_INFO WHERE CARGO_NO = p_cargo_no;

SELECT COUNT(*) INTO ln_count
FROM DV_STORAGE_LIFT_NOM_INFO
WHERE OBJECT_ID = lv_object_id
AND CARGO_NO = p_cargo_no
AND SPLIT_PCT IS NULL;

-- DO NOT MODIFY THE SPLIT PCT IF THERE IS ALREADY VALUE FOR SPLIT PCT
IF ln_count > 0 THEN
	FOR CUR_LA_SPLIT IN LA_SPLIT(lv_object_id) LOOP
		UPDATE DV_STORAGE_LIFT_NOM_INFO
		SET SPLIT_PCT = CUR_LA_SPLIT.SPLIT_PCT
		WHERE CARGO_NO = p_cargo_no
		AND LIFTING_ACCOUNT_ID = CUR_LA_SPLIT.LIFTING_ACCOUNT_ID
		AND OBJECT_ID = lv_object_id;
	END LOOP;
END IF;

END  UpdateSplitPCT;

-- gedv : Item_128043: INC000016970606 Starts
FUNCTION getSplitPct(split_vol number, p_cargo_no NUMBER) RETURN number
IS
    v_total NUMBER:=null;
    v_splitPct Number:=null;

BEGIN
    SELECT nvl(SUM(NVL(VALUE_12,GRS_VOL_NOMINATED)),0) INTO v_total from STORAGE_LIFT_NOMINATION WHERE CARGO_NO=p_cargo_no;

    IF v_total>0 THEN
        v_splitPct:=(split_vol/v_total)*100;
    END IF;

    return v_splitPct;

END getSplitPct;
-- gedv : Item_128043: INC000016970606 Ends

--begin Item_129174 GEDV
FUNCTION getInvoiceAmount(p_total_amount number, p_cargo_no NUMBER, p_parcel_no NUMBER) RETURN NUMBER
IS
    v_max_parcel NUMBER:=NULL;
    v_invoiceAmount NUMBER:=NULL;
    v_otherTotal number:=null;
	
CURSOR c_splitPct IS
    SELECT PARCEL_NO FROM STORAGE_LIFT_NOMINATION WHERE CARGO_NO=p_cargo_no AND PARCEL_NO<>p_parcel_no;

BEGIN

    --begin Item_129174 FR ensure query return one row in case split_pct is equal among parcels
    /**
    SELECT DISTINCT PARCEL_NO INTO v_max_parcel FROM STORAGE_LIFT_NOMINATION WHERE CARGO_NO=p_cargo_no
    AND VALUE_11= (SELECT MAX(VALUE_11) FROM STORAGE_LIFT_NOMINATION WHERE CARGO_NO=p_cargo_no);
    **/
    SELECT MAX(PARCEL_NO)INTO v_max_parcel FROM STORAGE_LIFT_NOMINATION WHERE CARGO_NO=p_cargo_no
    AND VALUE_11= (SELECT MAX(VALUE_11) FROM STORAGE_LIFT_NOMINATION WHERE CARGO_NO=p_cargo_no);
    --end Item_129174 FR

    IF v_max_parcel<>p_parcel_no THEN
        v_invoiceAmount:=ROUND(p_total_amount * NVL(EC_STORAGE_LIFT_NOMINATION.VALUE_11(p_parcel_no), 100)/ 100,2);
    ELSE
        v_otherTotal:=0;
        FOR cur_SplitPct in c_splitPct LOOP
            v_otherTotal:=v_otherTotal+(ROUND(p_total_amount*NVL (EC_STORAGE_LIFT_NOMINATION.VALUE_11(cur_SplitPct.PARCEL_NO), 100)/ 100,2));
        END LOOP;
        v_invoiceAmount:=p_total_amount - v_otherTotal;
    END IF;

    RETURN v_invoiceAmount;

END getInvoiceAmount;
--end Item_129174 GEDV

--Item 131306 Begin
/* Update JDE Batch No format to [EW][YYMMDD][XXXXX]
1. First 2 characters will be 'EW'
2. Next 6 characters will be Year Month Day in YYMMDD format. Example 180924 for 24-SEP-2018
3. Last 5 characters will be cargo number. Example 00658 for Cargo number 658*/

FUNCTION getJDEBatchNo(p_cargo_no NUMBER, p_batch_no VARCHAR2) RETURN VARCHAR2
IS
    v_jde_batch_no  VARCHAR2(32);
BEGIN

    IF p_batch_no is not null THEN
        v_jde_batch_no := 'EW' || SUBSTR(p_batch_no, 5, 6) || LPAD(p_cargo_no,5,'0');
    ELSE
        v_jde_batch_no := NULL;
    END IF;
    RETURN v_jde_batch_no;

END getJDEBatchNo;
-- Item 131306 End

-- Item 132473: ISWR03114 : new function to retrieve the Lifting Activity start date for a given parcel.
--                          This will be used in both the transferCargoAnalysis and BLMR class for use within the BoL calc
FUNCTION getLiftActStartDate (p_parcel_no NUMBER)
   RETURN DATE
IS
   CURSOR cLiftActStartDate (
      cp_cargo_no         NUMBER,
      cp_activity_code    VARCHAR2)
   IS
      SELECT a.from_daytime
        FROM LIFTING_ACTIVITY a
       WHERE     a.cargo_no = cp_cargo_no
             AND a.activity_code = cp_activity_code
             AND a.run_no =
                    (SELECT MIN (b.run_no)
                       FROM LIFTING_ACTIVITY b
                      WHERE     b.cargo_no = cp_cargo_no
                            AND b.activity_code = cp_activity_code);

   lv_cargo_no        NUMBER := ec_storage_lift_nomination.cargo_no (p_parcel_no);
   lv_cargo_daytime   DATE := ec_storage_lift_nomination.nom_firm_date (p_parcel_no);

   lv_storage_id      storage_lift_nomination.object_id%TYPE;
   lv_product_code    product.object_code%TYPE;
   lv_activity_code   VARCHAR2 (32);
   ld_return_val      DATE := NULL;
BEGIN
   -- Determine storage from parcel
   lv_storage_id := ec_storage_lift_nomination.object_id (p_parcel_no);

   -- Determine product from storage
   lv_product_code := ec_product.object_code (ec_stor_version.product_id (lv_storage_id, lv_cargo_daytime, '<='));

   lv_activity_code :=
      CASE lv_product_code
         WHEN 'LNG' THEN gv_lift_act_code_lng
         WHEN 'COND' THEN gv_lift_act_code_cond
         ELSE NULL
      END;

   FOR rec IN cLiftActStartDate (lv_cargo_no, lv_activity_code)
   LOOP
      ld_return_val := rec.from_daytime;
   END LOOP;

   RETURN ld_return_val;
END getLiftActStartDate;-- end Item 132473: ISWR03114

END UE_CT_CARGO_INFO;
/