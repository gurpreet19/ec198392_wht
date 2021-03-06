
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.23 AM


CREATE or REPLACE PACKAGE RPDP_PERFORMANCE_TEST
IS

   FUNCTION COUNTCHILDEVENT(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETESTIMATEDCONDPRODUCTION(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER;
      TYPE REC_GETLASTVALIDWELLRESULT IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         VALID_FROM_DATE  DATE ,
         END_DATE  DATE ,
         RESULT_NO NUMBER ,
         CHECK_UNIQUE VARCHAR2 (1000) ,
         DATA_CLASS_NAME VARCHAR2 (24) ,
         RESULT_NO_COMB NUMBER ,
         PRIMARY_IND VARCHAR2 (1) ,
         FLOWING_IND VARCHAR2 (1) ,
         CHOKE_SIZE NUMBER ,
         DURATION NUMBER ,
         AVG_FLOW_MASS NUMBER ,
         WH_USC_PRESS NUMBER ,
         WH_USC_TEMP NUMBER ,
         WH_DSC_PRESS NUMBER ,
         WH_DSC_TEMP NUMBER ,
         WH_PRESS NUMBER ,
         WH_TEMP NUMBER ,
         BH_PRESS NUMBER ,
         BH_TEMP NUMBER ,
         ANNULUS_PRESS NUMBER ,
         ANNULUS_TEMP NUMBER ,
         SAND_RATE NUMBER ,
         EROSION_RATE NUMBER ,
         NET_OIL_RATE_ADJ NUMBER ,
         GAS_RATE_ADJ NUMBER ,
         NET_COND_RATE_ADJ NUMBER ,
         TOT_WATER_RATE_ADJ NUMBER ,
         NET_OIL_DENSITY_ADJ NUMBER ,
         GAS_DENSITY_ADJ NUMBER ,
         NET_COND_DENSITY_ADJ NUMBER ,
         TOT_WATER_DENSITY_ADJ NUMBER ,
         MPM_OIL_RATE_FLC NUMBER ,
         MPM_OIL_RATE NUMBER ,
         MPM_OIL_DENSITY NUMBER ,
         MPM_GAS_RATE_FLC NUMBER ,
         MPM_GAS_RATE NUMBER ,
         MPM_GAS_DENSITY NUMBER ,
         MPM_WATER_RATE_FLC NUMBER ,
         MPM_WATER_RATE NUMBER ,
         MPM_MIX_DENSITY NUMBER ,
         MPM_PRESS NUMBER ,
         MPM_TEMP NUMBER ,
         MPM_COND_RATE NUMBER ,
         MPM_OIL_MASS_RATE NUMBER ,
         MPM_GAS_MASS_RATE NUMBER ,
         MPM_COND_MASS_RATE NUMBER ,
         MPM_WATER_MASS_RATE NUMBER ,
         MPM_COND_DENSITY NUMBER ,
         MPM_WATER_DENSITY NUMBER ,
         MPM_COND_RATE_FLC NUMBER ,
         MPM_OIL_MASS_RATE_FLC NUMBER ,
         MPM_GAS_MASS_RATE_FLC NUMBER ,
         MPM_COND_MASS_RATE_FLC NUMBER ,
         MPM_WATER_MASS_RATE_FLC NUMBER ,
         MPM_OIL_DENSITY_FLC NUMBER ,
         MPM_GAS_DENSITY_FLC NUMBER ,
         MPM_COND_DENSITY_FLC NUMBER ,
         MPM_WATER_DENSITY_FLC NUMBER ,
         MPM_MIX_DENSITY_FLC NUMBER ,
         MPM_CONDUCT NUMBER ,
         MPM_CONDUCT_TEMP NUMBER ,
         MPM_OIL_RATE_RAW NUMBER ,
         MPM_GAS_RATE_RAW NUMBER ,
         MPM_WATER_RATE_RAW NUMBER ,
         MPM_OIL_MASS_RATE_RAW NUMBER ,
         MPM_GAS_MASS_RATE_RAW NUMBER ,
         MPM_WATER_MASS_RATE_RAW NUMBER ,
         MPM_OIL_DENSITY_RAW NUMBER ,
         MPM_GAS_DENSITY_RAW NUMBER ,
         MPM_WATER_DENSITY_RAW NUMBER ,
         MPM_MIX_DENSITY_RAW NUMBER ,
         PUMP_SPEED NUMBER ,
         PUMP_POWER NUMBER ,
         PUMP_STROKE NUMBER ,
         PUMP_TIMER NUMBER ,
         DRIVE_CURRENT NUMBER ,
         DRIVE_VOLTAGE NUMBER ,
         LIQUID_LEVEL NUMBER ,
         DRIVE_FREQUENCY NUMBER ,
         DILUENT_RATE NUMBER ,
         GL_CHOKE_SIZE NUMBER ,
         GL_PRESS NUMBER ,
         GL_TEMP NUMBER ,
         GL_RATE NUMBER ,
         GL_DENSITY NUMBER ,
         GL_DIFF_PRESS NUMBER ,
         EST_GL_RATE NUMBER ,
         EST_DILUENT_RATE NUMBER ,
         DECLINE_RATE_OIL NUMBER ,
         PUMP_RUNTIME NUMBER ,
         OIL_SHRINKAGE NUMBER ,
         SOLUTION_GAS_FACTOR NUMBER ,
         GAS_SP_GRAV NUMBER ,
         CHLORIDE NUMBER ,
         EMULSION NUMBER ,
         FORMATION_GLR NUMBER ,
         GOR NUMBER ,
         CGR NUMBER ,
         GLR NUMBER ,
         WATERCUT_PCT NUMBER ,
         SAND_CONTENT NUMBER ,
         GAS_OUT_RATE NUMBER ,
         OIL_OUT_RATE NUMBER ,
         TDEV_PRESS NUMBER ,
         TDEV_TEMP NUMBER ,
         GAS_RATE NUMBER ,
         EST_NET_OIL_RATE NUMBER ,
         EST_GAS_RATE NUMBER ,
         EST_NET_COND_RATE NUMBER ,
         EST_WATER_RATE NUMBER ,
         NET_OIL_MASS_RATE_ADJ NUMBER ,
         GAS_MASS_RATE_ADJ NUMBER ,
         NET_COND_MASS_RATE_ADJ NUMBER ,
         TOT_WATER_MASS_RATE_ADJ NUMBER ,
         LIQUID_RATE_ADJ NUMBER ,
         WET_DRY_GAS_RATIO NUMBER ,
         WET_GAS_GRAVITY NUMBER ,
         WGR NUMBER ,
         WOR NUMBER ,
         TREND_ANALYSIS_IND VARCHAR2 (1) ,
         TREND_RESET_IND VARCHAR2 (1) ,
         POWERWATER_RATE NUMBER ,
         EST_POWERWATER_RATE NUMBER ,
         FWS_RATE NUMBER ,
         WELL_METER_FACTOR NUMBER ,
         STATUS VARCHAR2 (32) ,
         TEST_DEVICE VARCHAR2 (32) ,
         WT_MULTISELECT VARCHAR2 (1) ,
         RATE_SOURCE VARCHAR2 (32) ,
         USE_CALC VARCHAR2 (1) ,
         CO2_FRACTION NUMBER ,
         API NUMBER ,
         SALES_PRESS NUMBER ,
         AVG_CHOKE_SIZE_2 NUMBER ,
         AVG_FLOW_LINE_PRESS NUMBER ,
         AVG_INTAKE_PRESS NUMBER ,
         AVG_INTAKE_TEMP NUMBER ,
         CURRENT_UNBALANCE NUMBER ,
         LENGTH NUMBER ,
         MOTOR_TEMP NUMBER ,
         OIL_SG NUMBER ,
         PLUNGER_CYCLE_RATE NUMBER ,
         PUMP_DISCHARGE_PRESS NUMBER ,
         PUMP_PRESSURE NUMBER ,
         PUMP_STROKE_SPEED NUMBER ,
         VIBRATION NUMBER ,
         VOLTAGE_UNBALANCE NUMBER ,
         DRY_WET_GAS_RATIO NUMBER ,
         SI_BHP NUMBER ,
         SI_WHP NUMBER ,
         INTAKE_PRESS NUMBER ,
         INTAKE_TEMP NUMBER ,
         OUTLET_PRESS NUMBER ,
         OUTLET_TEMP NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
         VALUE_10 NUMBER ,
         VALUE_11 NUMBER ,
         VALUE_12 NUMBER ,
         VALUE_13 NUMBER ,
         VALUE_14 NUMBER ,
         VALUE_15 NUMBER ,
         VALUE_16 NUMBER ,
         VALUE_17 NUMBER ,
         VALUE_18 NUMBER ,
         VALUE_19 NUMBER ,
         VALUE_20 NUMBER ,
         VALUE_21 NUMBER ,
         VALUE_22 NUMBER ,
         VALUE_23 NUMBER ,
         VALUE_24 NUMBER ,
         VALUE_25 NUMBER ,
         VALUE_26 NUMBER ,
         VALUE_27 NUMBER ,
         VALUE_28 NUMBER ,
         VALUE_29 NUMBER ,
         VALUE_30 NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240) ,
         TEXT_11 VARCHAR2 (240) ,
         TEXT_12 VARCHAR2 (240) ,
         TEXT_13 VARCHAR2 (240) ,
         TEXT_14 VARCHAR2 (240) ,
         TEXT_15 VARCHAR2 (240) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         MPM_HC_MASS_RATE NUMBER ,
         MPM_TOT_MASS_RATE NUMBER ,
         WELL_TEST_REASON VARCHAR2 (32) ,
         BH_PRESS_2 NUMBER ,
         BH_TEMP_2 NUMBER ,
         DILUENT_PRESS NUMBER ,
         DP_TUBING NUMBER ,
         DP_VENTURI NUMBER ,
         END_DAY  DATE ,
         EROSION_UOM VARCHAR2 (32) ,
         GL_USC_PRESS NUMBER ,
         GL_USC_TEMP NUMBER ,
         METER1_FACTOR_GAS NUMBER ,
         METER1_FACTOR_GL NUMBER ,
         METER1_FACTOR_HC NUMBER ,
         METER1_FACTOR_HCLIQ NUMBER ,
         METER1_FACTOR_HCMASS NUMBER ,
         METER1_FACTOR_WAT NUMBER ,
         METER2_FACTOR_GAS NUMBER ,
         METER2_FACTOR_HCLIQ NUMBER ,
         METER2_FACTOR_WAT NUMBER ,
         MPM2_COND_RATE NUMBER ,
         MPM2_GAS_RATE NUMBER ,
         MPM2_OIL_RATE NUMBER ,
         MPM2_WATER_RATE NUMBER ,
         MPM_DIFF_PRESS NUMBER ,
         PRODUCTION_DAY  DATE ,
         PROD_INDEX NUMBER ,
         RECALC_RATIOS VARCHAR2 (1) ,
         RESERVOIR_PRESS NUMBER ,
         SAND_2_UOM VARCHAR2 (32) ,
         SAND_RATE_2 NUMBER ,
         SAND_UOM VARCHAR2 (32) ,
         TSEP_PRESS NUMBER ,
         TSEP_TEMP NUMBER ,
         UTC_DAYTIME  DATE ,
         UTC_END_DATE  DATE ,
         VALID_FROM_DAY  DATE ,
         VALID_FROM_UTC_DATE  DATE  );
   FUNCTION GETLASTVALIDWELLRESULT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN REC_GETLASTVALIDWELLRESULT;
   FUNCTION SHOWTESTDEVICESWITHRESULT(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FINDWATCONSTANTC2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_METHOD IN VARCHAR2 DEFAULT 'EXP')
      RETURN NUMBER;
   FUNCTION GETCONDRATETARGETWELLRESULT(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETNEXTVALIDWELLRESULTNO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETPRIMARYTARGETWELLID(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETSINGLEDATACLASSNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION SHOWDEFINEDTESTDEVICE(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SHOWPRIMARYWELLS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALCDURATIONOFSTABLEPERIOD(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETESTIMATEDGASPRODUCTION(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETCONDSTDRATEDAY(
      P_RESULT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETESTIMATEDOILPRODUCTION(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETGASRATETARGETWELLRESULT(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETGASSTDRATEDAY(
      P_RESULT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
      TYPE REC_GETNEXTVALIDWELLRESULT IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         VALID_FROM_DATE  DATE ,
         END_DATE  DATE ,
         RESULT_NO NUMBER ,
         CHECK_UNIQUE VARCHAR2 (1000) ,
         DATA_CLASS_NAME VARCHAR2 (24) ,
         RESULT_NO_COMB NUMBER ,
         PRIMARY_IND VARCHAR2 (1) ,
         FLOWING_IND VARCHAR2 (1) ,
         CHOKE_SIZE NUMBER ,
         DURATION NUMBER ,
         AVG_FLOW_MASS NUMBER ,
         WH_USC_PRESS NUMBER ,
         WH_USC_TEMP NUMBER ,
         WH_DSC_PRESS NUMBER ,
         WH_DSC_TEMP NUMBER ,
         WH_PRESS NUMBER ,
         WH_TEMP NUMBER ,
         BH_PRESS NUMBER ,
         BH_TEMP NUMBER ,
         ANNULUS_PRESS NUMBER ,
         ANNULUS_TEMP NUMBER ,
         SAND_RATE NUMBER ,
         EROSION_RATE NUMBER ,
         NET_OIL_RATE_ADJ NUMBER ,
         GAS_RATE_ADJ NUMBER ,
         NET_COND_RATE_ADJ NUMBER ,
         TOT_WATER_RATE_ADJ NUMBER ,
         NET_OIL_DENSITY_ADJ NUMBER ,
         GAS_DENSITY_ADJ NUMBER ,
         NET_COND_DENSITY_ADJ NUMBER ,
         TOT_WATER_DENSITY_ADJ NUMBER ,
         MPM_OIL_RATE_FLC NUMBER ,
         MPM_OIL_RATE NUMBER ,
         MPM_OIL_DENSITY NUMBER ,
         MPM_GAS_RATE_FLC NUMBER ,
         MPM_GAS_RATE NUMBER ,
         MPM_GAS_DENSITY NUMBER ,
         MPM_WATER_RATE_FLC NUMBER ,
         MPM_WATER_RATE NUMBER ,
         MPM_MIX_DENSITY NUMBER ,
         MPM_PRESS NUMBER ,
         MPM_TEMP NUMBER ,
         MPM_COND_RATE NUMBER ,
         MPM_OIL_MASS_RATE NUMBER ,
         MPM_GAS_MASS_RATE NUMBER ,
         MPM_COND_MASS_RATE NUMBER ,
         MPM_WATER_MASS_RATE NUMBER ,
         MPM_COND_DENSITY NUMBER ,
         MPM_WATER_DENSITY NUMBER ,
         MPM_COND_RATE_FLC NUMBER ,
         MPM_OIL_MASS_RATE_FLC NUMBER ,
         MPM_GAS_MASS_RATE_FLC NUMBER ,
         MPM_COND_MASS_RATE_FLC NUMBER ,
         MPM_WATER_MASS_RATE_FLC NUMBER ,
         MPM_OIL_DENSITY_FLC NUMBER ,
         MPM_GAS_DENSITY_FLC NUMBER ,
         MPM_COND_DENSITY_FLC NUMBER ,
         MPM_WATER_DENSITY_FLC NUMBER ,
         MPM_MIX_DENSITY_FLC NUMBER ,
         MPM_CONDUCT NUMBER ,
         MPM_CONDUCT_TEMP NUMBER ,
         MPM_OIL_RATE_RAW NUMBER ,
         MPM_GAS_RATE_RAW NUMBER ,
         MPM_WATER_RATE_RAW NUMBER ,
         MPM_OIL_MASS_RATE_RAW NUMBER ,
         MPM_GAS_MASS_RATE_RAW NUMBER ,
         MPM_WATER_MASS_RATE_RAW NUMBER ,
         MPM_OIL_DENSITY_RAW NUMBER ,
         MPM_GAS_DENSITY_RAW NUMBER ,
         MPM_WATER_DENSITY_RAW NUMBER ,
         MPM_MIX_DENSITY_RAW NUMBER ,
         PUMP_SPEED NUMBER ,
         PUMP_POWER NUMBER ,
         PUMP_STROKE NUMBER ,
         PUMP_TIMER NUMBER ,
         DRIVE_CURRENT NUMBER ,
         DRIVE_VOLTAGE NUMBER ,
         LIQUID_LEVEL NUMBER ,
         DRIVE_FREQUENCY NUMBER ,
         DILUENT_RATE NUMBER ,
         GL_CHOKE_SIZE NUMBER ,
         GL_PRESS NUMBER ,
         GL_TEMP NUMBER ,
         GL_RATE NUMBER ,
         GL_DENSITY NUMBER ,
         GL_DIFF_PRESS NUMBER ,
         EST_GL_RATE NUMBER ,
         EST_DILUENT_RATE NUMBER ,
         DECLINE_RATE_OIL NUMBER ,
         PUMP_RUNTIME NUMBER ,
         OIL_SHRINKAGE NUMBER ,
         SOLUTION_GAS_FACTOR NUMBER ,
         GAS_SP_GRAV NUMBER ,
         CHLORIDE NUMBER ,
         EMULSION NUMBER ,
         FORMATION_GLR NUMBER ,
         GOR NUMBER ,
         CGR NUMBER ,
         GLR NUMBER ,
         WATERCUT_PCT NUMBER ,
         SAND_CONTENT NUMBER ,
         GAS_OUT_RATE NUMBER ,
         OIL_OUT_RATE NUMBER ,
         TDEV_PRESS NUMBER ,
         TDEV_TEMP NUMBER ,
         GAS_RATE NUMBER ,
         EST_NET_OIL_RATE NUMBER ,
         EST_GAS_RATE NUMBER ,
         EST_NET_COND_RATE NUMBER ,
         EST_WATER_RATE NUMBER ,
         NET_OIL_MASS_RATE_ADJ NUMBER ,
         GAS_MASS_RATE_ADJ NUMBER ,
         NET_COND_MASS_RATE_ADJ NUMBER ,
         TOT_WATER_MASS_RATE_ADJ NUMBER ,
         LIQUID_RATE_ADJ NUMBER ,
         WET_DRY_GAS_RATIO NUMBER ,
         WET_GAS_GRAVITY NUMBER ,
         WGR NUMBER ,
         WOR NUMBER ,
         TREND_ANALYSIS_IND VARCHAR2 (1) ,
         TREND_RESET_IND VARCHAR2 (1) ,
         POWERWATER_RATE NUMBER ,
         EST_POWERWATER_RATE NUMBER ,
         FWS_RATE NUMBER ,
         WELL_METER_FACTOR NUMBER ,
         STATUS VARCHAR2 (32) ,
         TEST_DEVICE VARCHAR2 (32) ,
         WT_MULTISELECT VARCHAR2 (1) ,
         RATE_SOURCE VARCHAR2 (32) ,
         USE_CALC VARCHAR2 (1) ,
         CO2_FRACTION NUMBER ,
         API NUMBER ,
         SALES_PRESS NUMBER ,
         AVG_CHOKE_SIZE_2 NUMBER ,
         AVG_FLOW_LINE_PRESS NUMBER ,
         AVG_INTAKE_PRESS NUMBER ,
         AVG_INTAKE_TEMP NUMBER ,
         CURRENT_UNBALANCE NUMBER ,
         LENGTH NUMBER ,
         MOTOR_TEMP NUMBER ,
         OIL_SG NUMBER ,
         PLUNGER_CYCLE_RATE NUMBER ,
         PUMP_DISCHARGE_PRESS NUMBER ,
         PUMP_PRESSURE NUMBER ,
         PUMP_STROKE_SPEED NUMBER ,
         VIBRATION NUMBER ,
         VOLTAGE_UNBALANCE NUMBER ,
         DRY_WET_GAS_RATIO NUMBER ,
         SI_BHP NUMBER ,
         SI_WHP NUMBER ,
         INTAKE_PRESS NUMBER ,
         INTAKE_TEMP NUMBER ,
         OUTLET_PRESS NUMBER ,
         OUTLET_TEMP NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
         VALUE_10 NUMBER ,
         VALUE_11 NUMBER ,
         VALUE_12 NUMBER ,
         VALUE_13 NUMBER ,
         VALUE_14 NUMBER ,
         VALUE_15 NUMBER ,
         VALUE_16 NUMBER ,
         VALUE_17 NUMBER ,
         VALUE_18 NUMBER ,
         VALUE_19 NUMBER ,
         VALUE_20 NUMBER ,
         VALUE_21 NUMBER ,
         VALUE_22 NUMBER ,
         VALUE_23 NUMBER ,
         VALUE_24 NUMBER ,
         VALUE_25 NUMBER ,
         VALUE_26 NUMBER ,
         VALUE_27 NUMBER ,
         VALUE_28 NUMBER ,
         VALUE_29 NUMBER ,
         VALUE_30 NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240) ,
         TEXT_11 VARCHAR2 (240) ,
         TEXT_12 VARCHAR2 (240) ,
         TEXT_13 VARCHAR2 (240) ,
         TEXT_14 VARCHAR2 (240) ,
         TEXT_15 VARCHAR2 (240) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         MPM_HC_MASS_RATE NUMBER ,
         MPM_TOT_MASS_RATE NUMBER ,
         WELL_TEST_REASON VARCHAR2 (32) ,
         BH_PRESS_2 NUMBER ,
         BH_TEMP_2 NUMBER ,
         DILUENT_PRESS NUMBER ,
         DP_TUBING NUMBER ,
         DP_VENTURI NUMBER ,
         END_DAY  DATE ,
         EROSION_UOM VARCHAR2 (32) ,
         GL_USC_PRESS NUMBER ,
         GL_USC_TEMP NUMBER ,
         METER1_FACTOR_GAS NUMBER ,
         METER1_FACTOR_GL NUMBER ,
         METER1_FACTOR_HC NUMBER ,
         METER1_FACTOR_HCLIQ NUMBER ,
         METER1_FACTOR_HCMASS NUMBER ,
         METER1_FACTOR_WAT NUMBER ,
         METER2_FACTOR_GAS NUMBER ,
         METER2_FACTOR_HCLIQ NUMBER ,
         METER2_FACTOR_WAT NUMBER ,
         MPM2_COND_RATE NUMBER ,
         MPM2_GAS_RATE NUMBER ,
         MPM2_OIL_RATE NUMBER ,
         MPM2_WATER_RATE NUMBER ,
         MPM_DIFF_PRESS NUMBER ,
         PRODUCTION_DAY  DATE ,
         PROD_INDEX NUMBER ,
         RECALC_RATIOS VARCHAR2 (1) ,
         RESERVOIR_PRESS NUMBER ,
         SAND_2_UOM VARCHAR2 (32) ,
         SAND_RATE_2 NUMBER ,
         SAND_UOM VARCHAR2 (32) ,
         TSEP_PRESS NUMBER ,
         TSEP_TEMP NUMBER ,
         UTC_DAYTIME  DATE ,
         UTC_END_DATE  DATE ,
         VALID_FROM_DAY  DATE ,
         VALID_FROM_UTC_DATE  DATE  );
   FUNCTION GETNEXTVALIDWELLRESULT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN REC_GETNEXTVALIDWELLRESULT;
   FUNCTION SHOWDEFINEDWELLS(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SHOWFLOWINGWELLS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETATTRIBUTE(
      P_STATIC_PRESENTATION_SYNTAX IN VARCHAR2,
      P_LABEL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETRESULTDATACLASSNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETSUMESTGLRATE(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETTESTDEVICEIDFROMRESULT(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FINDGASCONSTANTC2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_METHOD IN VARCHAR2 DEFAULT 'EXP')
      RETURN NUMBER;
   FUNCTION GETESTIMATEDWATERPRODUCTION(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETOILRATETARGETWELLRESULT(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETOILSTDRATEDAY(
      P_RESULT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETSAMPLEDATACLASSNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION GETSUMESTDILRATE(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETTESTOBJECTNAME(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETTRENDSEGMENTMINDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE;
   FUNCTION GETWATSTDRATEDAY(
      P_RESULT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION SHOWWELLSWITHRESULT(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ACTIVEWBISWELLRESULT(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETDEFAULTTESTDEVICE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2;
   FUNCTION SHOWDEFINEDFLOWLINES(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SHOWFLOWLINESWITHRESULT(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SHOWNONFLOWINGWELLS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FINDCONDCONSTANTC2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_METHOD IN VARCHAR2 DEFAULT 'EXP')
      RETURN NUMBER;
   FUNCTION FINDLIQCONSTANTC2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_METHOD IN VARCHAR2 DEFAULT 'EXP')
      RETURN NUMBER;
   FUNCTION FINDOILCONSTANTC2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_METHOD IN VARCHAR2 DEFAULT 'EXP')
      RETURN NUMBER;
   FUNCTION GETLASTVALIDWELLRESULTNO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETMETERCODE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETPREVWELLTESTRESULT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_N_TESTS IN NUMBER DEFAULT '1',
      P_STATUS IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETTRENDSEGMENTMAXDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE;
   FUNCTION GETWATRATETARGETWELLRESULT(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER;

END RPDP_PERFORMANCE_TEST;

/



CREATE or REPLACE PACKAGE BODY RPDP_PERFORMANCE_TEST
IS

   FUNCTION COUNTCHILDEVENT(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.COUNTCHILDEVENT      (
         P_TEST_NO );
         RETURN ret_value;
   END COUNTCHILDEVENT;
   FUNCTION GETESTIMATEDCONDPRODUCTION(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETESTIMATEDCONDPRODUCTION      (
         P_TARGET_RESULT_NO,
         P_COMB_RESULT_NO );
         RETURN ret_value;
   END GETESTIMATEDCONDPRODUCTION;
   FUNCTION GETLASTVALIDWELLRESULT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN REC_GETLASTVALIDWELLRESULT
   IS
      ret_value    REC_GETLASTVALIDWELLRESULT ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETLASTVALIDWELLRESULT      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETLASTVALIDWELLRESULT;
   FUNCTION SHOWTESTDEVICESWITHRESULT(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.SHOWTESTDEVICESWITHRESULT      (
         P_RESULT_NO );
         RETURN ret_value;
   END SHOWTESTDEVICESWITHRESULT;
   FUNCTION FINDWATCONSTANTC2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_METHOD IN VARCHAR2 DEFAULT 'EXP')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.FINDWATCONSTANTC2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TREND_METHOD );
         RETURN ret_value;
   END FINDWATCONSTANTC2;
   FUNCTION GETCONDRATETARGETWELLRESULT(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETCONDRATETARGETWELLRESULT      (
         P_TARGET_RESULT_NO,
         P_COMB_RESULT_NO );
         RETURN ret_value;
   END GETCONDRATETARGETWELLRESULT;
   FUNCTION GETNEXTVALIDWELLRESULTNO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETNEXTVALIDWELLRESULTNO      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETNEXTVALIDWELLRESULTNO;
   FUNCTION GETPRIMARYTARGETWELLID(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETPRIMARYTARGETWELLID      (
         P_TARGET_RESULT_NO,
         P_COMB_RESULT_NO );
         RETURN ret_value;
   END GETPRIMARYTARGETWELLID;
   FUNCTION GETSINGLEDATACLASSNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETSINGLEDATACLASSNAME      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETSINGLEDATACLASSNAME;
   FUNCTION SHOWDEFINEDTESTDEVICE(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.SHOWDEFINEDTESTDEVICE      (
         P_TEST_NO );
         RETURN ret_value;
   END SHOWDEFINEDTESTDEVICE;
   FUNCTION SHOWPRIMARYWELLS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.SHOWPRIMARYWELLS      (
         P_RESULT_NO );
         RETURN ret_value;
   END SHOWPRIMARYWELLS;
   FUNCTION CALCDURATIONOFSTABLEPERIOD(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.CALCDURATIONOFSTABLEPERIOD      (
         P_RESULT_NO );
         RETURN ret_value;
   END CALCDURATIONOFSTABLEPERIOD;
   FUNCTION GETESTIMATEDGASPRODUCTION(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETESTIMATEDGASPRODUCTION      (
         P_TARGET_RESULT_NO,
         P_COMB_RESULT_NO );
         RETURN ret_value;
   END GETESTIMATEDGASPRODUCTION;
   FUNCTION GETCONDSTDRATEDAY(
      P_RESULT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETCONDSTDRATEDAY      (
         P_RESULT_NO,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETCONDSTDRATEDAY;
   FUNCTION GETESTIMATEDOILPRODUCTION(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETESTIMATEDOILPRODUCTION      (
         P_TARGET_RESULT_NO,
         P_COMB_RESULT_NO );
         RETURN ret_value;
   END GETESTIMATEDOILPRODUCTION;
   FUNCTION GETGASRATETARGETWELLRESULT(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETGASRATETARGETWELLRESULT      (
         P_TARGET_RESULT_NO,
         P_COMB_RESULT_NO );
         RETURN ret_value;
   END GETGASRATETARGETWELLRESULT;
   FUNCTION GETGASSTDRATEDAY(
      P_RESULT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETGASSTDRATEDAY      (
         P_RESULT_NO,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETGASSTDRATEDAY;
   FUNCTION GETNEXTVALIDWELLRESULT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN REC_GETNEXTVALIDWELLRESULT
   IS
      ret_value    REC_GETNEXTVALIDWELLRESULT ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETNEXTVALIDWELLRESULT      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETNEXTVALIDWELLRESULT;
   FUNCTION SHOWDEFINEDWELLS(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.SHOWDEFINEDWELLS      (
         P_TEST_NO );
         RETURN ret_value;
   END SHOWDEFINEDWELLS;
   FUNCTION SHOWFLOWINGWELLS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.SHOWFLOWINGWELLS      (
         P_RESULT_NO );
         RETURN ret_value;
   END SHOWFLOWINGWELLS;
   FUNCTION GETATTRIBUTE(
      P_STATIC_PRESENTATION_SYNTAX IN VARCHAR2,
      P_LABEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETATTRIBUTE      (
         P_STATIC_PRESENTATION_SYNTAX,
         P_LABEL );
         RETURN ret_value;
   END GETATTRIBUTE;
   FUNCTION GETRESULTDATACLASSNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETRESULTDATACLASSNAME      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETRESULTDATACLASSNAME;
   FUNCTION GETSUMESTGLRATE(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETSUMESTGLRATE      (
         P_RESULT_NO );
         RETURN ret_value;
   END GETSUMESTGLRATE;
   FUNCTION GETTESTDEVICEIDFROMRESULT(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETTESTDEVICEIDFROMRESULT      (
         P_RESULT_NO );
         RETURN ret_value;
   END GETTESTDEVICEIDFROMRESULT;
   FUNCTION FINDGASCONSTANTC2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_METHOD IN VARCHAR2 DEFAULT 'EXP')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.FINDGASCONSTANTC2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TREND_METHOD );
         RETURN ret_value;
   END FINDGASCONSTANTC2;
   FUNCTION GETESTIMATEDWATERPRODUCTION(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETESTIMATEDWATERPRODUCTION      (
         P_TARGET_RESULT_NO,
         P_COMB_RESULT_NO );
         RETURN ret_value;
   END GETESTIMATEDWATERPRODUCTION;
   FUNCTION GETOILRATETARGETWELLRESULT(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETOILRATETARGETWELLRESULT      (
         P_TARGET_RESULT_NO,
         P_COMB_RESULT_NO );
         RETURN ret_value;
   END GETOILRATETARGETWELLRESULT;
   FUNCTION GETOILSTDRATEDAY(
      P_RESULT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETOILSTDRATEDAY      (
         P_RESULT_NO,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETOILSTDRATEDAY;
   FUNCTION GETSAMPLEDATACLASSNAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETSAMPLEDATACLASSNAME      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETSAMPLEDATACLASSNAME;
   FUNCTION GETSUMESTDILRATE(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETSUMESTDILRATE      (
         P_RESULT_NO );
         RETURN ret_value;
   END GETSUMESTDILRATE;
   FUNCTION GETTESTOBJECTNAME(
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETTESTOBJECTNAME      (
         P_OBJECT_ID );
         RETURN ret_value;
   END GETTESTOBJECTNAME;
   FUNCTION GETTRENDSEGMENTMINDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETTRENDSEGMENTMINDATE      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETTRENDSEGMENTMINDATE;
   FUNCTION GETWATSTDRATEDAY(
      P_RESULT_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETWATSTDRATEDAY      (
         P_RESULT_NO,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETWATSTDRATEDAY;
   FUNCTION SHOWWELLSWITHRESULT(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.SHOWWELLSWITHRESULT      (
         P_RESULT_NO );
         RETURN ret_value;
   END SHOWWELLSWITHRESULT;
   FUNCTION ACTIVEWBISWELLRESULT(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.ACTIVEWBISWELLRESULT      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END ACTIVEWBISWELLRESULT;
   FUNCTION GETDEFAULTTESTDEVICE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETDEFAULTTESTDEVICE      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETDEFAULTTESTDEVICE;
   FUNCTION SHOWDEFINEDFLOWLINES(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.SHOWDEFINEDFLOWLINES      (
         P_TEST_NO );
         RETURN ret_value;
   END SHOWDEFINEDFLOWLINES;
   FUNCTION SHOWFLOWLINESWITHRESULT(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.SHOWFLOWLINESWITHRESULT      (
         P_RESULT_NO );
         RETURN ret_value;
   END SHOWFLOWLINESWITHRESULT;
   FUNCTION SHOWNONFLOWINGWELLS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.SHOWNONFLOWINGWELLS      (
         P_RESULT_NO );
         RETURN ret_value;
   END SHOWNONFLOWINGWELLS;
   FUNCTION FINDCONDCONSTANTC2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_METHOD IN VARCHAR2 DEFAULT 'EXP')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.FINDCONDCONSTANTC2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TREND_METHOD );
         RETURN ret_value;
   END FINDCONDCONSTANTC2;
   FUNCTION FINDLIQCONSTANTC2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_METHOD IN VARCHAR2 DEFAULT 'EXP')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.FINDLIQCONSTANTC2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TREND_METHOD );
         RETURN ret_value;
   END FINDLIQCONSTANTC2;
   FUNCTION FINDOILCONSTANTC2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_METHOD IN VARCHAR2 DEFAULT 'EXP')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.FINDOILCONSTANTC2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TREND_METHOD );
         RETURN ret_value;
   END FINDOILCONSTANTC2;
   FUNCTION GETLASTVALIDWELLRESULTNO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETLASTVALIDWELLRESULTNO      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETLASTVALIDWELLRESULTNO;
   FUNCTION GETMETERCODE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETMETERCODE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_PHASE );
         RETURN ret_value;
   END GETMETERCODE;
   FUNCTION GETPREVWELLTESTRESULT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_N_TESTS IN NUMBER DEFAULT '1',
      P_STATUS IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETPREVWELLTESTRESULT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_N_TESTS,
         P_STATUS );
         RETURN ret_value;
   END GETPREVWELLTESTRESULT;
   FUNCTION GETTRENDSEGMENTMAXDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETTRENDSEGMENTMAXDATE      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETTRENDSEGMENTMAXDATE;
   FUNCTION GETWATRATETARGETWELLRESULT(
      P_TARGET_RESULT_NO IN NUMBER,
      P_COMB_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_PERFORMANCE_TEST.GETWATRATETARGETWELLRESULT      (
         P_TARGET_RESULT_NO,
         P_COMB_RESULT_NO );
         RETURN ret_value;
   END GETWATRATETARGETWELLRESULT;

END RPDP_PERFORMANCE_TEST;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_PERFORMANCE_TEST TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.32 AM


