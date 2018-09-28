CREATE OR REPLACE PACKAGE BODY UE_CT_WELL_TEST_SRV IS

  /****************************************************************
  ** Package        :  UE_CT_WELL_TEST_SRV, header part
  **
  ** $Revision      : 1.0 $
  **
  ** Purpose        :  Interface between IFM and EC for well test validation
  **
  ** Documentation  :
  **
  ** Created  : 29.11.2007  Mark Berkstresser
  **
  ** Modification history:
  **
  ** Version  Date        Whom  		Change description:
  ** -------  ------      ----- 		--------------------------------------
  ** 1.0      29.11.2007  MWB    		Initial Version
  ** 1.1      23-Jan-08   MWB    		Converted to 9.3
  ** 1.2      11-Nov-08   MWB    		Added ability to pass in 10 generic columns for update
  ** 1.3       15-SEP-10 CGOV    		Added FC ID to the duplicate WT being inserted, ptst_result insert
  ** 1.4	  13-JAN-2011 LBFK,CGOV  	Modified package to include use_calc flag in CVX template.
  **									Mimics the the Accept, Use Alloc/Accept, No Alloc Well Test
  **									Business Function button behaviors with p_use_in_alloc param.
  **									Class PROD_TEST_RESULT's APP_UPDATE_FLAG column is now required
  **									in order to store p_source system value.
  **									NOTE : This package deprecates the result_type variable which
  **									was used to determine if a well test is used for allocs in sites
  **									like AGB.
  **  1.5   28-MAR-2011 CGOV        Handle Monthly Locking in updatewelltest function, return error code and 
  **                                                description, do not show raise_application_error msg in underlying functions
  *****************************************************************/

  ------------------------------------------------------------------
  -- Procedure   : CreateDupWellTest
  -- Description : Prorate the period vol to daily injection vol
  --  This can only be called internally for security reasons
  ------------------------------------------------------------------
  PROCEDURE CreateDupWellTest(p_result_no NUMBER,
                p_requested_by VARCHAR2,
                              p_new_result_no OUT NUMBER,
                              p_comments         VARCHAR2 DEFAULT NULL,
							  p_source_system	 VARCHAR2,
							  p_use_in_alloc	 VARCHAR2,
                              p_new_oil_rate     NUMBER   DEFAULT NULL,
                              p_new_water_rate   NUMBER   DEFAULT NULL,
                              p_new_gas_rate     NUMBER   DEFAULT NULL,
                              p_new_gor          NUMBER   DEFAULT NULL,
                              p_new_watercut_pct NUMBER   DEFAULT NULL,
                              p_update_col_1     VARCHAR2 DEFAULT NULL,
                              p_update_value_1   NUMBER   DEFAULT NULL,
                              p_update_col_2     VARCHAR2 DEFAULT NULL,
                              p_update_value_2   NUMBER   DEFAULT NULL,
                              p_update_col_3     VARCHAR2 DEFAULT NULL,
                              p_update_value_3   NUMBER   DEFAULT NULL,
                              p_update_col_4     VARCHAR2 DEFAULT NULL,
                              p_update_value_4   NUMBER   DEFAULT NULL,
                              p_update_col_5     VARCHAR2 DEFAULT NULL,
                              p_update_value_5   NUMBER   DEFAULT NULL,
                              p_update_col_6     VARCHAR2 DEFAULT NULL,
                              p_update_value_6   NUMBER   DEFAULT NULL,
                              p_update_col_7     VARCHAR2 DEFAULT NULL,
                              p_update_value_7   NUMBER   DEFAULT NULL,
                              p_update_col_8     VARCHAR2 DEFAULT NULL,
                              p_update_value_8   NUMBER   DEFAULT NULL,
                              p_update_col_9     VARCHAR2 DEFAULT NULL,
                              p_update_value_9   NUMBER   DEFAULT NULL,
                              p_update_col_10    VARCHAR2 DEFAULT NULL,
                              p_update_value_10  NUMBER   DEFAULT NULL)

   IS

    lr_ptst_result ptst_result%ROWTYPE;
    v_comments   VARCHAR2(2000);
    lv2_SQL      VARCHAR2(2000);
    v_use_calc    VARCHAR2 (1)          DEFAULT NULL;


CURSOR cPwelResult(p_result_no varchar2) IS
      SELECT *
        FROM pwel_result
  where result_no = p_result_no;

CURSOR cTDevResult(p_result_no varchar2) IS
      SELECT *
        FROM TEST_DEVICE_RESULT
  where result_no = p_result_no;

BEGIN


   lr_ptst_result := ec_ptst_result.row_by_pk(p_result_no);

  --  Change status of original well test the REJECTED
  --
  --  Need to add update to comment field
  --
  UPDATE TV_PROD_TEST_RESULT set status = 'REJECTED', last_updated_by = p_requested_by where result_no = p_result_no;

  --  Get the next well test result number
  EcDp_System_Key.assignNextNumber('PTST_RESULT', p_new_result_no);

  -- Create replacement PROD_TEST_RESULT record
  -- Use table and not view because triggers fired when original record as added.
  insert into ptst_result (result_no, daytime, end_date, duration, production_day, test_type,
  estimate_type, test_no, summarised_ind, valid_from_date, status, comments, facility_id,
  value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10,
  text_1, text_2, text_3, text_4, class_name, created_by)
  values
  (p_new_result_no,lr_ptst_result.daytime, lr_ptst_result.end_date, lr_ptst_result.duration,
  lr_ptst_result.production_day, lr_ptst_result.test_type,
  lr_ptst_result.estimate_type, lr_ptst_result.test_no, lr_ptst_result.summarised_ind,
  lr_ptst_result.valid_from_date, lr_ptst_result.status, lr_ptst_result.comments, lr_ptst_result.facility_id,
  lr_ptst_result.value_1, lr_ptst_result.value_2, lr_ptst_result.value_3, lr_ptst_result.value_4,
  lr_ptst_result.value_5, lr_ptst_result.value_6, lr_ptst_result.value_7, lr_ptst_result.value_8,
  lr_ptst_result.value_9, lr_ptst_result.value_10,
  lr_ptst_result.text_1, lr_ptst_result.text_2, lr_ptst_result.text_3, lr_ptst_result.text_4,
  'PROD_TEST_RESULT', p_requested_by);

  --  Duplicate all PWEL_RESULT records
  FOR pwel_cursor IN cPwelResult(p_result_no) LOOP
  INSERT INTO pwel_result ( RESULT_NO, OBJECT_ID, DATA_CLASS_NAME, RESULT_NO_COMB,
     PRIMARY_IND, FLOWING_IND, CHOKE_SIZE, WH_USC_PRESS,
   WH_USC_TEMP, WH_DSC_PRESS, WH_DSC_TEMP, WH_PRESS,
   WH_TEMP, BH_PRESS, BH_TEMP, ANNULUS_PRESS, ANNULUS_TEMP,
   SAND_RATE, EROSION_RATE, NET_OIL_RATE_ADJ, GAS_RATE_ADJ,
   NET_COND_RATE_ADJ, TOT_WATER_RATE_ADJ, NET_OIL_DENSITY_ADJ,
   GAS_DENSITY_ADJ, NET_COND_DENSITY_ADJ, TOT_WATER_DENSITY_ADJ,
   MPM_OIL_RATE_FLC, MPM_OIL_RATE, MPM_OIL_DENSITY, MPM_GAS_RATE_FLC,
   MPM_GAS_RATE, MPM_GAS_DENSITY, MPM_WATER_RATE_FLC, MPM_WATER_RATE,
   MPM_MIX_DENSITY, MPM_PRESS, MPM_TEMP, MPM_COND_RATE, MPM_OIL_MASS_RATE,
   MPM_GAS_MASS_RATE, MPM_COND_MASS_RATE, MPM_WATER_MASS_RATE,
   MPM_COND_DENSITY, MPM_WATER_DENSITY, MPM_COND_RATE_FLC, MPM_OIL_MASS_RATE_FLC,
   MPM_GAS_MASS_RATE_FLC, MPM_COND_MASS_RATE_FLC, MPM_WATER_MASS_RATE_FLC,
   MPM_OIL_DENSITY_FLC, MPM_GAS_DENSITY_FLC, MPM_COND_DENSITY_FLC, MPM_WATER_DENSITY_FLC,
   MPM_MIX_DENSITY_FLC, MPM_CONDUCT, MPM_CONDUCT_TEMP, MPM_OIL_RATE_RAW,
   MPM_GAS_RATE_RAW, MPM_WATER_RATE_RAW, PUMP_SPEED, PUMP_POWER,
   PUMP_STROKE, PUMP_TIMER, DRIVE_CURRENT, DRIVE_VOLTAGE, LIQUID_LEVEL,
   DRIVE_FREQUENCY, DILUENT_RATE, GL_CHOKE_SIZE, GL_PRESS, GL_TEMP,
   GL_RATE, GL_DENSITY, EST_GL_RATE, EST_DILUENT_RATE, DECLINE_RATE_OIL,
   PUMP_RUNTIME, OIL_SHRINKAGE, SOLUTION_GAS_FACTOR, GAS_SP_GRAV,
   CHLORIDE, EMULSION, FORMATION_GLR, GOR, CGR, GLR, WATERCUT_PCT,
   SAND_CONTENT, GAS_OUT_RATE, OIL_OUT_RATE, TDEV_PRESS, TDEV_TEMP,
   GAS_RATE, EST_NET_OIL_RATE, EST_GAS_RATE, EST_NET_COND_RATE, EST_WATER_RATE,
   NET_OIL_MASS_RATE_ADJ, GAS_MASS_RATE_ADJ, NET_COND_MASS_RATE_ADJ, TOT_WATER_MASS_RATE_ADJ,
   WET_DRY_GAS_RATIO, WGR,   COMMENTS,
   VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8,
   VALUE_9, VALUE_10, VALUE_11, VALUE_12, VALUE_13, VALUE_14, VALUE_15, VALUE_16,
   VALUE_17, VALUE_18, VALUE_19, VALUE_20, VALUE_21, VALUE_22, VALUE_23,
   VALUE_24, VALUE_25, VALUE_26, VALUE_27, VALUE_28, VALUE_29,VALUE_30,
   TEXT_1, TEXT_2, TEXT_3, TEXT_4, TEXT_5, TEXT_6, TEXT_7, TEXT_8,
   TEXT_9, TEXT_10, TEXT_11, TEXT_12, TEXT_13, TEXT_14, TEXT_15,
   RECORD_STATUS, CREATED_BY, CREATED_DATE,
   VALID_FROM_DATE, DAYTIME, STATUS, TEST_DEVICE, END_DATE, DURATION)
VALUES (p_new_result_no,
    pwel_cursor.OBJECT_ID, pwel_cursor.DATA_CLASS_NAME, pwel_cursor.RESULT_NO_COMB,
    pwel_cursor.PRIMARY_IND, pwel_cursor.FLOWING_IND, pwel_cursor.CHOKE_SIZE, pwel_cursor.WH_USC_PRESS,
    pwel_cursor.WH_USC_TEMP, pwel_cursor.WH_DSC_PRESS, pwel_cursor.WH_DSC_TEMP, pwel_cursor.WH_PRESS,
    pwel_cursor.BH_TEMP, pwel_cursor.BH_PRESS, pwel_cursor.BH_TEMP, pwel_cursor.ANNULUS_PRESS, pwel_cursor.ANNULUS_TEMP,
    pwel_cursor.SAND_RATE, pwel_cursor.EROSION_RATE, pwel_cursor.NET_OIL_RATE_ADJ, pwel_cursor.GAS_RATE_ADJ,
    pwel_cursor.NET_COND_RATE_ADJ, pwel_cursor.TOT_WATER_RATE_ADJ, pwel_cursor.NET_OIL_DENSITY_ADJ,
    pwel_cursor.GAS_DENSITY_ADJ, pwel_cursor.NET_COND_DENSITY_ADJ, pwel_cursor.TOT_WATER_DENSITY_ADJ,
    pwel_cursor.MPM_OIL_RATE_FLC, pwel_cursor.MPM_OIL_RATE, pwel_cursor.MPM_OIL_DENSITY, pwel_cursor.MPM_GAS_RATE_FLC,
    pwel_cursor.MPM_GAS_RATE, pwel_cursor.MPM_GAS_DENSITY, pwel_cursor.MPM_WATER_RATE_FLC, pwel_cursor.MPM_WATER_RATE,
    pwel_cursor.MPM_MIX_DENSITY, pwel_cursor.MPM_PRESS, pwel_cursor.MPM_TEMP, pwel_cursor.MPM_COND_RATE, pwel_cursor.MPM_OIL_MASS_RATE,
    pwel_cursor.MPM_GAS_MASS_RATE, pwel_cursor.MPM_COND_MASS_RATE, pwel_cursor.MPM_WATER_MASS_RATE,
    pwel_cursor.MPM_COND_DENSITY, pwel_cursor.MPM_WATER_DENSITY, pwel_cursor.MPM_COND_RATE_FLC, pwel_cursor.MPM_OIL_MASS_RATE_FLC,
    pwel_cursor.MPM_GAS_MASS_RATE_FLC, pwel_cursor.MPM_COND_MASS_RATE_FLC, pwel_cursor.MPM_WATER_MASS_RATE_FLC,
    pwel_cursor.MPM_OIL_DENSITY_FLC, pwel_cursor.MPM_GAS_DENSITY_FLC, pwel_cursor.MPM_COND_DENSITY_FLC, pwel_cursor.MPM_WATER_DENSITY_FLC,
    pwel_cursor.MPM_MIX_DENSITY_FLC, pwel_cursor.MPM_CONDUCT, pwel_cursor.MPM_CONDUCT_TEMP, pwel_cursor.MPM_OIL_RATE_RAW,
    pwel_cursor.MPM_GAS_RATE_RAW, pwel_cursor.MPM_WATER_RATE_RAW, pwel_cursor.PUMP_SPEED, pwel_cursor.PUMP_POWER,
    pwel_cursor.PUMP_STROKE, pwel_cursor.PUMP_TIMER, pwel_cursor.DRIVE_CURRENT, pwel_cursor.DRIVE_VOLTAGE, pwel_cursor.LIQUID_LEVEL,
    pwel_cursor.DRIVE_FREQUENCY, pwel_cursor.DILUENT_RATE, pwel_cursor.GL_CHOKE_SIZE, pwel_cursor.GL_PRESS, pwel_cursor.GL_TEMP,
    pwel_cursor.GL_RATE, pwel_cursor.GL_DENSITY, pwel_cursor.EST_GL_RATE, pwel_cursor.EST_DILUENT_RATE, pwel_cursor.DECLINE_RATE_OIL,
    pwel_cursor.PUMP_RUNTIME, pwel_cursor.OIL_SHRINKAGE, pwel_cursor.SOLUTION_GAS_FACTOR, pwel_cursor.GAS_SP_GRAV,
    pwel_cursor.CHLORIDE, pwel_cursor.EMULSION, pwel_cursor.FORMATION_GLR, pwel_cursor.GOR, pwel_cursor.CGR, pwel_cursor.GLR, pwel_cursor.WATERCUT_PCT,
    pwel_cursor.SAND_CONTENT, pwel_cursor.GAS_OUT_RATE, pwel_cursor.OIL_OUT_RATE, pwel_cursor.TDEV_PRESS, pwel_cursor.TDEV_TEMP,
    pwel_cursor.GAS_RATE, pwel_cursor.EST_NET_OIL_RATE, pwel_cursor.EST_GAS_RATE, pwel_cursor.EST_NET_COND_RATE, pwel_cursor.EST_WATER_RATE,
    pwel_cursor.NET_OIL_MASS_RATE_ADJ, pwel_cursor.GAS_MASS_RATE_ADJ, pwel_cursor.NET_COND_MASS_RATE_ADJ, pwel_cursor.TOT_WATER_MASS_RATE_ADJ,
    pwel_cursor.WET_DRY_GAS_RATIO, pwel_cursor.WGR, pwel_cursor.COMMENTS,
    pwel_cursor.VALUE_1, pwel_cursor.VALUE_2, pwel_cursor.VALUE_3, pwel_cursor.VALUE_4, pwel_cursor.VALUE_5, pwel_cursor.VALUE_6, pwel_cursor.VALUE_7, pwel_cursor.VALUE_8,
    pwel_cursor.VALUE_9, pwel_cursor.VALUE_10, pwel_cursor.VALUE_11, pwel_cursor.VALUE_12, pwel_cursor.VALUE_13, pwel_cursor.VALUE_14, pwel_cursor.VALUE_15, pwel_cursor.VALUE_16,
    pwel_cursor.VALUE_17, pwel_cursor.VALUE_18, pwel_cursor.VALUE_19, pwel_cursor.VALUE_20, pwel_cursor.VALUE_21, pwel_cursor.VALUE_22, pwel_cursor.VALUE_23,
    pwel_cursor.VALUE_24, pwel_cursor.VALUE_25, pwel_cursor.VALUE_26, pwel_cursor.VALUE_27, pwel_cursor.VALUE_28, pwel_cursor.VALUE_29, pwel_cursor.VALUE_30,
    pwel_cursor.TEXT_1, pwel_cursor.TEXT_2, pwel_cursor.TEXT_3, pwel_cursor.TEXT_4, pwel_cursor.TEXT_5, pwel_cursor.TEXT_6, pwel_cursor.TEXT_7, pwel_cursor.TEXT_8,
    pwel_cursor.TEXT_9, pwel_cursor.TEXT_10, pwel_cursor.TEXT_11, pwel_cursor.TEXT_12, pwel_cursor.TEXT_13, pwel_cursor.TEXT_14, pwel_cursor.TEXT_15,
    pwel_cursor.RECORD_STATUS, p_requested_by, sysdate,
    pwel_cursor.VALID_FROM_DATE, pwel_cursor.DAYTIME, pwel_cursor.STATUS, pwel_cursor.TEST_DEVICE, pwel_cursor.END_DATE, pwel_cursor.DURATION);
  END LOOP;

    --  Duplicate all TDEV_RESULT records
	-- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
  FOR tdev_cursor IN cTdevResult(p_result_no) LOOP
  INSERT INTO TEST_DEVICE_RESULT ( RESULT_NO, OBJECT_ID, DATA_CLASS_NAME, TDEV_PRESS, TDEV_TEMP,
       INLET_PRESS, INLET_TEMP, OIL_OUTLET_PRESS, OIL_OUTLET_TEMP, GAS_OUTLET_PRESS,
       GAS_OUTLET_TEMP, WATER_LEVEL, LIQUID_LEVEL,SAND_RATE, EROSION_RATE,
       ORIFICE_SIZE, ORIFICE_TRANSMITTER, GAS_DIFF_PRESS_1, GAS_DIFF_PRESS_2,
       WATER_IN_OIL_OUT, OIL_IN_WATER_OUT, NET_OIL_DENSITY_ADJ, GAS_DENSITY_ADJ,
       NET_COND_DENSITY_ADJ, TOT_WATER_DENSITY_ADJ, NET_OIL_RATE_ADJ, GAS_RATE_ADJ,
       NET_COND_RATE_ADJ, TOT_WATER_RATE_ADJ, NET_OIL_RATE, GAS_RATE, TOT_WATER_RATE,
       NET_OIL_DENSITY, GAS_DENSITY, TOT_WATER_DENSITY, NET_OIL_DENSITY_FLC, GAS_DENSITY_FLC,
       TOT_WATER_DENSITY_FLC, OIL_OUT_DENSITY, GAS_OUT_DENSITY, WATER_OUT_DENSITY,
       OIL_OUT_DENSITY_FLC, GAS_OUT_DENSITY_FLC, WATER_OUT_DENSITY_FLC, NET_OIL_RATE_FLC,
       GAS_RATE_FLC, TOT_WATER_RATE_FLC, OIL_OUT_RATE, GAS_OUT_RATE, WATER_OUT_RATE,
       OIL_OUT_RATE_FLC, GAS_OUT_RATE_FLC, WATER_OUT_RATE_FLC, NET_COND_RATE_FLC,
       NET_OIL_MASS_RATE_FLC, GAS_MASS_RATE_FLC, NET_COND_MASS_RATE_FLC,
       TOT_WATER_MASS_RATE_FLC, NET_COND_DENSITY_FLC, NET_OIL_MASS_RATE_ADJ, GAS_MASS_RATE_ADJ,
       NET_COND_MASS_RATE_ADJ, TOT_WATER_MASS_RATE_ADJ, NET_COND_RATE, NET_OIL_MASS_RATE,
       GAS_MASS_RATE, NET_COND_MASS_RATE, TOT_WATER_MASS_RATE, NET_COND_DENSITY,
       NET_OIL_VOL, GAS_VOL, NET_COND_VOL, TOT_WATER_VOL, OIL_OUT_RATE_RAW, GAS_OUT_RATE_RAW,
       WATER_OUT_RATE_RAW, OIL_OUT_VOL_RAW, GAS_OUT_VOL_RAW, WATER_OUT_VOL_RAW,
       OIL_OUT_RATE_1_RAW, OIL_OUT_RATE_2_RAW, OIL_OUT_RATE_3_RAW, GAS_OUT_RATE_1_RAW,
       GAS_OUT_RATE_2_RAW, GAS_OUT_RATE_3_RAW, WATER_OUT_RATE_1_RAW, WATER_OUT_RATE_2_RAW,
       WATER_OUT_RATE_3_RAW, MPM_GAS_DENSITY, MPM_MIX_DENSITY, MPM_OIL_DENSITY,
       MPM_WATER_DENSITY, MPM_GAS_DENSITY_FLC, MPM_OIL_DENSITY_FLC, MPM_GAS_RATE,
       MPM_OIL_RATE, MPM_WATER_RATE, MPM_GAS_RATE_FLC, MPM_OIL_RATE_FLC, MPM_WATER_RATE_FLC,
       MPM_GAS_RATE_RAW, MPM_OIL_RATE_RAW, MPM_WATER_RATE_RAW, MPM_CONDUCT,
       MPM_CONDUCT_TEMP, MPM_PRESS, MPM_TEMP, MPM_COND_RATE, MPM_OIL_MASS_RATE,
       MPM_GAS_MASS_RATE, MPM_COND_MASS_RATE, MPM_WATER_MASS_RATE, MPM_COND_DENSITY,
       MPM_COND_RATE_FLC, MPM_OIL_MASS_RATE_FLC, MPM_GAS_MASS_RATE_FLC, MPM_COND_MASS_RATE_FLC, MPM_WATER_MASS_RATE_FLC, MPM_COND_DENSITY_FLC,
       MPM_WATER_DENSITY_FLC, MPM_MIX_DENSITY_FLC, EVENT_OIL_OUT_BSW, EVENT_OIL_OUT_DENSITY,
       EVENT_GAS_OUT_DENSITY, EST_DILUENT_RATE_FLC, EST_GL_RATE_FLC, GL_RATE, GL_PRESS,
       GAS_SP_GRAV, CHLORIDE, EMULSION, SAND_CONTENT, COMMENTS, VALUE_1,
       VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, VALUE_10,
       TEXT_1, TEXT_2, TEXT_3, TEXT_4,
       RECORD_STATUS, CREATED_BY, CREATED_DATE)
VALUES (p_new_result_no,
      tdev_cursor.OBJECT_ID, tdev_cursor.DATA_CLASS_NAME, tdev_cursor.TDEV_PRESS, tdev_cursor.TDEV_TEMP,
         tdev_cursor.INLET_PRESS, tdev_cursor.INLET_TEMP, tdev_cursor.OIL_OUTLET_PRESS, tdev_cursor.OIL_OUTLET_TEMP, tdev_cursor.GAS_OUTLET_PRESS,
         tdev_cursor.GAS_OUTLET_TEMP, tdev_cursor.WATER_LEVEL, tdev_cursor.LIQUID_LEVEL, tdev_cursor.SAND_RATE, tdev_cursor.EROSION_RATE,
         tdev_cursor.ORIFICE_SIZE, tdev_cursor.ORIFICE_TRANSMITTER, tdev_cursor.GAS_DIFF_PRESS_1, tdev_cursor.GAS_DIFF_PRESS_2,
         tdev_cursor.WATER_IN_OIL_OUT, tdev_cursor.OIL_IN_WATER_OUT, tdev_cursor.NET_OIL_DENSITY_ADJ, tdev_cursor.GAS_DENSITY_ADJ,
         tdev_cursor.NET_COND_DENSITY_ADJ, tdev_cursor.TOT_WATER_DENSITY_ADJ, tdev_cursor.NET_OIL_RATE_ADJ, tdev_cursor.GAS_RATE_ADJ,
         tdev_cursor.NET_COND_RATE_ADJ, tdev_cursor.TOT_WATER_RATE_ADJ, tdev_cursor.NET_OIL_RATE, tdev_cursor.GAS_RATE, tdev_cursor.TOT_WATER_RATE,
         tdev_cursor.NET_OIL_DENSITY, tdev_cursor.GAS_DENSITY, tdev_cursor.TOT_WATER_DENSITY, tdev_cursor.NET_OIL_DENSITY_FLC, tdev_cursor.GAS_DENSITY_FLC,
         tdev_cursor.TOT_WATER_DENSITY_FLC, tdev_cursor.OIL_OUT_DENSITY, tdev_cursor.GAS_OUT_DENSITY, tdev_cursor.WATER_OUT_DENSITY,
         tdev_cursor.OIL_OUT_DENSITY_FLC, tdev_cursor.GAS_OUT_DENSITY_FLC, tdev_cursor.WATER_OUT_DENSITY_FLC, tdev_cursor.NET_OIL_RATE_FLC,
         tdev_cursor.GAS_RATE_FLC, tdev_cursor.TOT_WATER_RATE_FLC, tdev_cursor.OIL_OUT_RATE, tdev_cursor.GAS_OUT_RATE, tdev_cursor.WATER_OUT_RATE,
         tdev_cursor.OIL_OUT_RATE_FLC, tdev_cursor.GAS_OUT_RATE_FLC, tdev_cursor.WATER_OUT_RATE_FLC, tdev_cursor.NET_COND_RATE_FLC,
         tdev_cursor.NET_OIL_MASS_RATE_FLC, tdev_cursor.GAS_MASS_RATE_FLC, tdev_cursor.NET_COND_MASS_RATE_FLC,
         tdev_cursor.TOT_WATER_MASS_RATE_FLC, tdev_cursor.NET_COND_DENSITY_FLC, tdev_cursor.NET_OIL_MASS_RATE_ADJ, tdev_cursor.GAS_MASS_RATE_ADJ,
         tdev_cursor.NET_COND_MASS_RATE_ADJ, tdev_cursor.TOT_WATER_MASS_RATE_ADJ, tdev_cursor.NET_COND_RATE, tdev_cursor.NET_OIL_MASS_RATE,
         tdev_cursor.GAS_MASS_RATE, tdev_cursor.NET_COND_MASS_RATE, tdev_cursor.TOT_WATER_MASS_RATE, tdev_cursor.NET_COND_DENSITY,
         tdev_cursor.NET_OIL_VOL, tdev_cursor.GAS_VOL, tdev_cursor.NET_COND_VOL, tdev_cursor.TOT_WATER_VOL, tdev_cursor.OIL_OUT_RATE_RAW, tdev_cursor.GAS_OUT_RATE_RAW,
         tdev_cursor.WATER_OUT_RATE_RAW, tdev_cursor.OIL_OUT_VOL_RAW, tdev_cursor.GAS_OUT_VOL_RAW, tdev_cursor.WATER_OUT_VOL_RAW,
         tdev_cursor.OIL_OUT_RATE_1_RAW, tdev_cursor.OIL_OUT_RATE_2_RAW, tdev_cursor.OIL_OUT_RATE_3_RAW, tdev_cursor.GAS_OUT_RATE_1_RAW,
         tdev_cursor.GAS_OUT_RATE_2_RAW, tdev_cursor.GAS_OUT_RATE_3_RAW, tdev_cursor.WATER_OUT_RATE_1_RAW, tdev_cursor.WATER_OUT_RATE_2_RAW,
         tdev_cursor.WATER_OUT_RATE_3_RAW, tdev_cursor.MPM_GAS_DENSITY, tdev_cursor.MPM_MIX_DENSITY, tdev_cursor.MPM_OIL_DENSITY,
         tdev_cursor.MPM_WATER_DENSITY, tdev_cursor.MPM_GAS_DENSITY_FLC, tdev_cursor.MPM_OIL_DENSITY_FLC, tdev_cursor.MPM_GAS_RATE,
         tdev_cursor.MPM_OIL_RATE, tdev_cursor.MPM_WATER_RATE, tdev_cursor.MPM_GAS_RATE_FLC, tdev_cursor.MPM_OIL_RATE_FLC, tdev_cursor.MPM_WATER_RATE_FLC,
         tdev_cursor.MPM_GAS_RATE_RAW, tdev_cursor.MPM_OIL_RATE_RAW, tdev_cursor.MPM_WATER_RATE_RAW, tdev_cursor.MPM_CONDUCT,
         tdev_cursor.MPM_CONDUCT_TEMP, tdev_cursor.MPM_PRESS, tdev_cursor.MPM_TEMP, tdev_cursor.MPM_COND_RATE, tdev_cursor.MPM_OIL_MASS_RATE,
         tdev_cursor.MPM_GAS_MASS_RATE, tdev_cursor.MPM_COND_MASS_RATE, tdev_cursor.MPM_WATER_MASS_RATE, tdev_cursor.MPM_COND_DENSITY,
         tdev_cursor.MPM_COND_RATE_FLC, tdev_cursor.MPM_OIL_MASS_RATE_FLC, tdev_cursor.MPM_GAS_MASS_RATE_FLC, tdev_cursor.MPM_COND_MASS_RATE_FLC, tdev_cursor.MPM_WATER_MASS_RATE_FLC, tdev_cursor.MPM_COND_DENSITY_FLC,
         tdev_cursor.MPM_WATER_DENSITY_FLC, tdev_cursor.MPM_MIX_DENSITY_FLC, tdev_cursor.EVENT_OIL_OUT_BSW, tdev_cursor.EVENT_OIL_OUT_DENSITY,
         tdev_cursor.EVENT_GAS_OUT_DENSITY, tdev_cursor.EST_DILUENT_RATE_FLC, tdev_cursor.EST_GL_RATE_FLC, tdev_cursor.GL_RATE, tdev_cursor.GL_PRESS,
         tdev_cursor.GAS_SP_GRAV, tdev_cursor.CHLORIDE, tdev_cursor.EMULSION, tdev_cursor.SAND_CONTENT, tdev_cursor.COMMENTS, tdev_cursor.VALUE_1,
         tdev_cursor.VALUE_2, tdev_cursor.VALUE_3, tdev_cursor.VALUE_4, tdev_cursor.VALUE_5, tdev_cursor.VALUE_6, tdev_cursor.VALUE_7, tdev_cursor.VALUE_8, tdev_cursor.VALUE_9, tdev_cursor.VALUE_10,
         tdev_cursor.TEXT_1, tdev_cursor.TEXT_2, tdev_cursor.TEXT_3, tdev_cursor.TEXT_4,
         tdev_cursor.RECORD_STATUS, p_requested_by, sysdate);
  END LOOP;

  --  Change values passed in with the corrected well test

  IF p_new_oil_rate IS NOT NULL THEN
     UPDATE pwel_result set NET_OIL_RATE_ADJ = p_new_oil_rate, last_updated_by = p_requested_by
    where result_no = p_new_result_no;
  END IF;

  IF p_new_water_rate IS NOT NULL THEN
     UPDATE pwel_result set TOT_WATER_RATE_ADJ = p_new_water_rate, last_updated_by = p_requested_by
    where result_no = p_new_result_no;
  END IF;

  IF p_new_gas_rate IS NOT NULL THEN
     UPDATE pwel_result set GAS_RATE_ADJ = p_new_gas_rate, last_updated_by = p_requested_by
    where result_no = p_new_result_no;
  END IF;

  IF p_new_gor IS NOT NULL THEN
     UPDATE pwel_result set GOR = p_new_gor, last_updated_by = p_requested_by
    where result_no = p_new_result_no;
  END IF;


  IF p_new_watercut_pct IS NOT NULL THEN
     UPDATE pwel_result set WATERCUT_PCT = p_new_watercut_pct, last_updated_by = p_requested_by
    where result_no = p_new_result_no;
  END IF;

  IF p_comments IS NOT NULL THEN
    v_comments := lr_ptst_result.comments || ' ' || p_comments || ' -- Corrected copy of ' || to_char(p_result_no);
  ELSE
    v_comments := 'Corrected copy of ' || to_char(p_result_no);
  END IF;

  IF p_use_in_alloc = 'Y' THEN
	v_use_calc := 'Y';
  ELSE
	v_use_calc := 'N';
  END IF;


		UPDATE tv_prod_test_result
         SET comments = v_comments,
             status = 'ACCEPTED',
             use_calc = v_use_calc,
             app_update_flag = p_source_system,
             last_updated_by = p_requested_by
       WHERE result_no = p_new_result_no;

--  Now update any generic columns that were passed in
--  Loop until the first null column is found
  IF p_update_col_1 IS NOT NULL THEN
    lv2_sql := 'UPDATE PWEL_RESULT set ' || p_update_col_1 || ' = ' || p_update_value_1;
     IF p_update_col_2 IS NOT NULL THEN
       lv2_sql := lv2_sql || ', ' || p_update_col_2 || ' = ' || p_update_value_2;
       END IF;

     IF p_update_col_3 IS NOT NULL THEN
       lv2_sql := lv2_sql || ', ' || p_update_col_3 || ' = ' || p_update_value_3;
       END IF;

     IF p_update_col_4 IS NOT NULL THEN
        lv2_sql := lv2_sql || ', ' || p_update_col_4 || ' = ' || p_update_value_4;
        END IF;

     IF p_update_col_5 IS NOT NULL THEN
        lv2_sql := lv2_sql || ', ' || p_update_col_5 || ' = ' || p_update_value_5;
        END IF;

     IF p_update_col_6 IS NOT NULL THEN
        lv2_sql := lv2_sql || ', ' || p_update_col_6 || ' = ' || p_update_value_6;
        END IF;

     IF p_update_col_7 IS NOT NULL THEN
       lv2_sql := lv2_sql || ', ' || p_update_col_7 || ' = ' || p_update_value_7;
       END IF;

     IF p_update_col_8 IS NOT NULL THEN
        lv2_sql := lv2_sql || ', ' || p_update_col_8 || ' = ' || p_update_value_8;
        END IF;

     IF p_update_col_9 IS NOT NULL THEN
        lv2_sql := lv2_sql || ', ' || p_update_col_9 || ' = ' || p_update_value_9;
        END IF;

     IF p_update_col_10 IS NOT NULL THEN
        lv2_sql := lv2_sql || ', ' || p_update_col_10 || ' = ' || p_update_value_10;
        END IF;

    lv2_sql := lv2_sql || ', last_updated_by = '' ' || p_requested_by || ' '' where result_no = ' || p_new_result_no;
  ELSE
    RETURN;
  END IF;

   EXECUTE IMMEDIATE lv2_sql;
-- Next line is for testing
EcDp_DynSql.WriteTempText('WELL_TEST ' || p_new_result_no ,lv2_sql);

  END CreateDupWellTest;

    ------------------------------------------------------------------
  -- Procedure   : UpdateWellTestStatus
  -- Description : Change status of well test based on transaction from external system (e.g. IFM)
  --  This can only be called internally for security reasons
  ------------------------------------------------------------------
  PROCEDURE UpdateWellTestStatus(
		p_result_no NUMBER,
        p_requested_by VARCHAR2,
        p_operation VARCHAR2,
        p_comments VARCHAR2,
		p_source_system VARCHAR2,
		p_use_in_alloc VARCHAR2)

   IS
	lr_ptst_result ptst_result%ROWTYPE;
	v_comments   VARCHAR2(2000);
	v_status     VARCHAR2(32);
    v_use_calc       VARCHAR2 (1);


BEGIN

	IF p_operation = 'ACCEPT' THEN
		v_status := 'ACCEPTED';
		IF p_use_in_alloc = 'Y' THEN
			v_use_calc := 'Y';
		ELSE
			v_use_calc := 'N';
		END IF;
	ELSIF p_operation = 'REJECT' THEN
		v_status := 'REJECTED';
		v_use_calc := 'N';
	END IF;

     lr_ptst_result := ec_ptst_result.row_by_pk(p_result_no);

  --  Change status of well test
  --
       UPDATE tv_prod_test_result
         SET status = v_status,
             use_calc = v_use_calc,
             app_update_flag = p_source_system,
             last_updated_by = p_requested_by
       WHERE result_no = p_result_no;

  -- Add new comments to string
  IF p_comments IS NOT NULL THEN
    v_comments := lr_ptst_result.comments || ' ' || p_comments || ' ' || '- updated by external process';
  UPDATE TV_PROD_TEST_RESULT set comments = v_comments, last_updated_by = p_requested_by where result_no = p_result_no;
  END IF;

  END UpdateWellTestStatus;

  ------------------------------------------------------------------
  -- Procedure   : UpdateWellTest
  -- Description : Change status of well test based on transaction from IFM
  ------------------------------------------------------------------

PROCEDURE UpdateWellTest   (p_result_no        NUMBER,
                            p_requested_by     VARCHAR2,
                            p_record_date      DATE,
                            p_operation        VARCHAR2,
      						p_source_system    VARCHAR2,
                            p_new_result_no OUT NUMBER,
                            p_return_code   OUT NUMBER,
                            p_return_desc   OUT VARCHAR2,
                            p_comments         VARCHAR2 DEFAULT NULL,
                            p_new_oil_rate     NUMBER   DEFAULT NULL,
                            p_new_water_rate   NUMBER   DEFAULT NULL,
                            p_new_gas_rate     NUMBER   DEFAULT NULL,
                            p_new_gor          NUMBER   DEFAULT NULL,
                            p_new_watercut_pct NUMBER   DEFAULT NULL,
                            p_update_col_1     VARCHAR2 DEFAULT NULL,
                            p_update_value_1   NUMBER   DEFAULT NULL,
                            p_update_col_2     VARCHAR2 DEFAULT NULL,
                            p_update_value_2   NUMBER   DEFAULT NULL,
                            p_update_col_3     VARCHAR2 DEFAULT NULL,
                            p_update_value_3   NUMBER   DEFAULT NULL,
                            p_update_col_4     VARCHAR2 DEFAULT NULL,
                            p_update_value_4   NUMBER   DEFAULT NULL,
                            p_update_col_5     VARCHAR2 DEFAULT NULL,
                            p_update_value_5   NUMBER   DEFAULT NULL,
                            p_update_col_6     VARCHAR2 DEFAULT NULL,
                            p_update_value_6   NUMBER   DEFAULT NULL,
                            p_update_col_7     VARCHAR2 DEFAULT NULL,
                            p_update_value_7   NUMBER   DEFAULT NULL,
                            p_update_col_8     VARCHAR2 DEFAULT NULL,
                            p_update_value_8   NUMBER   DEFAULT NULL,
                            p_update_col_9     VARCHAR2 DEFAULT NULL,
                            p_update_value_9   NUMBER   DEFAULT NULL,
                            p_update_col_10    VARCHAR2 DEFAULT NULL,
                            p_update_value_10  NUMBER   DEFAULT NULL,
							p_use_in_alloc VARCHAR2 DEFAULT 'Y')
  IS
      lr_ptst_result    ptst_result%ROWTYPE;
      n_lock_columns    EcDp_Month_lock.column_list;
      v_last_updated_date DATE;

 CURSOR c_last_updated_date IS
   SELECT last_updated_date last_updated_date
   FROM PTST_RESULT
WHERE result_no = p_result_no;

BEGIN

   lr_ptst_result := ec_ptst_result.row_by_pk(p_result_no);

    /* 28-MAR-2011, CGOV commented out, pasted by Mark Berkstresser 
     -- Lock test
   EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','PROD_TEST_RESULT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','PTST_RESULT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'RESULT_NO','RESULT_NO','NUMBER','Y','N',anydata.ConvertNumber(lr_ptst_result.RESULT_NO));
   EcDp_month_lock.AddParameterToList(n_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',anydata.Convertdate(lr_ptst_result.VALID_FROM_DATE));
   EcDp_month_lock.AddParameterToList(n_lock_columns,'STATUS','STATUS','STRING','N','N',anydata.ConvertVarChar2(lr_ptst_result.STATUS));

  EcDp_Performance_lock.CheckLockProductionTest('UPDATING',n_lock_columns,n_lock_columns);
    */

  /*  Return Codes from procedure
  0   - Success
  100 - Not a valid well test number
  105 - User ID is not allowed to update this record
  110 - Not a valid new status
  115 - Record can only be cloned once
  120 - Record has already been approved
  125 - Record is in a locked month
  130 - Can not update record that was updated
  150 - Update failed

  */

  --  Check for valid Result_no
  IF ec_ptst_result.duration(p_result_no) IS NULL THEN
     p_return_code := 100;
     p_return_desc := p_result_no || ' - is not a valid well test number';
     RETURN;
     END IF;

  -- Check to see if updating ID has permission
  IF ue_ct_authenicate.RequestValid(p_requested_by,'PROD_TEST_RESULT','UPDATE') > 0 THEN
     p_return_code := 105;
     p_return_desc := 'User ID ' || p_requested_by || ' is not allowed to update record - ' || p_result_no;
     RETURN;
     END IF;

  --  Check for valid values in p_status
  IF p_operation NOT IN ('ACCEPT','REJECT','ACCEPT_WITH_CHANGES') THEN
     p_return_code := 110;
     p_return_desc := p_operation || '- is not a valid new status for record - ' || p_result_no;
     RETURN;
     END IF;

  IF ec_ptst_result.status(p_result_no) = 'REJECTED' THEN
     p_return_code := 115;
     p_return_desc := 'Record ' || p_result_no || ' can only be cloned once or has already been rejected';
     RETURN;
     END IF;

  IF ec_ptst_result.status(p_result_no) = 'ACCEPTED' THEN
     p_return_code := 120;
     p_return_desc := 'Record ' || p_result_no || ' has already been approved';
     RETURN;
     END IF;

 --  Check for valid values in p_status
 --28-MAR-2011, CGOV Changed to make sure valid_from_date does not encounter a locked month
 IF ecdp_month_lock.lockedmonthaffected(lr_ptst_result.VALID_FROM_DATE, lr_ptst_result.VALID_FROM_DATE) IS NOT NULL THEN 
     p_return_code := 125;
     p_return_desc := 'Record ' || p_result_no || ' is in locked month - ' || substr(ecdp_month_lock.lockedmonthaffected(lr_ptst_result.VALID_FROM_DATE, lr_ptst_result.VALID_FROM_DATE),4);
     RETURN;
     END IF;

  --  Check to see if the record was updated in EC after it was retrieved by the external process
  --  This assumes PTST_RESULT, TEST_DEVICE_RESULT and PWEL_RESULT all share the same last_updated_date

   FOR cur_row IN c_last_updated_date LOOP
      v_last_updated_date := cur_row.last_updated_date;
   END LOOP;

  IF v_last_updated_date >  p_record_date THEN
     p_return_code := 130;
     p_return_desc := 'Record ' || p_result_no || ' can not be updated because it was updated in the source system';
     RETURN;
     END IF;


-- Condition tests all passed
--  Start with record updates

  IF p_operation IN('ACCEPT','REJECT') THEN
     UpdateWellTestStatus(p_result_no, p_requested_by, p_operation, p_comments, p_source_system, p_use_in_alloc);
     END IF;

  IF p_operation = 'ACCEPT_WITH_CHANGES' THEN
     CreateDupWellTest(p_result_no, p_requested_by, p_new_result_no, p_comments, p_source_system, p_use_in_alloc,
                       p_new_oil_rate, p_new_water_rate, p_new_gas_rate, p_new_gor, p_new_watercut_pct,
                       p_update_col_1, p_update_value_1, p_update_col_2, p_update_value_2, p_update_col_3, p_update_value_3,
                       p_update_col_4, p_update_value_4, p_update_col_5, p_update_value_5, p_update_col_6, p_update_value_6,
                       p_update_col_7, p_update_value_7, p_update_col_8, p_update_value_8, p_update_col_9, p_update_value_9,
                       p_update_col_10, p_update_value_10);
     END IF;

    p_return_code := 0;
    p_return_desc := 'Success';

  END UpdateWellTest;

  ------------------------------------------------------------------
  -- Procedure   : InsertWellTest
  -- Description : Insert a new well test from external source
  ------------------------------------------------------------------

PROCEDURE InsertWellTest   (p_requested_by VARCHAR2, p_operation VARCHAR2, p_comments VARCHAR2 DEFAULT NULL,
       p_source_system VARCHAR2, p_new_oil_rate NUMBER DEFAULT NULL, p_new_water_rate NUMBER DEFAULT NULL,
       p_new_gas_rate NUMBER DEFAULT NULL,
       p_new_gor NUMBER DEFAULT NULL, p_new_watercut_pct NUMBER DEFAULT NULL,
       p_new_result_no OUT NUMBER, p_return_code OUT NUMBER, p_return_desc OUT VARCHAR2, p_use_in_alloc VARCHAR2 DEFAULT 'Y')

IS

--  All code still needs to be written
BEGIN

  /*  Return Codes from procedure
  0   - Success
  100 - Not a valid well test number
  105 - User ID is not allowed to update this record
  110 - Not a valid new status
  115 - Record can only be cloned once
  120 - Record has already been approved
  125 - Record is in a locked month
  130 - Can not update record that was updated
  150 - Update failed

  */

  -- Check to see if updating ID has permission
  IF p_requested_by = 'XXXX' THEN
     p_return_code := 105;
     p_return_desc := 'User ID is not allowed to update this record';
     RETURN;
     END IF;

END InsertWellTest;

END UE_CT_WELL_TEST_SRV;
/
