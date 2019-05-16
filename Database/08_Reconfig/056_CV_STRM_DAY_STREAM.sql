CREATE OR REPLACE VIEW "CV_STRM_DAY_STREAM" ("DAYTIME", "OBJECT_ID", "ON_STREAM_HRS", "BS_W", "GRS_LNG_MASS","GRS_LNG_MASS_MTD", "GRS_LNG_MASS_QTD", "GRS_LNG_MASS_YTD","GRS_LNG_VOL", "GRS_LNG_VOL_MTD", "GRS_LNG_VOL_QTD", "GRS_LNG_VOL_YTD","NET_LNG_MASS", "NET_LNG_MASS_MTD", "NET_LNG_MASS_QTD", "NET_LNG_MASS_YTD","NET_LNG_VOL","NET_LNG_VOL_MTD","NET_LNG_VOL_QTD","NET_LNG_VOL_YTD","GRS_CO2_VOL", "GRS_CO2_VOL_MTD", "GRS_CO2_VOL_QTD", "GRS_CO2_VOL_YTD", "NET_CO2_VOL", "NET_CO2_VOL_MTD", "NET_CO2_VOL_QTD", "NET_CO2_VOL_YTD", "GRS_CO2_MASS", "GRS_CO2_MASS_MTD", "GRS_CO2_MASS_QTD", "GRS_CO2_MASS_YTD", "NET_CO2_MASS", "NET_CO2_MASS_MTD", "NET_CO2_MASS_QTD", "NET_CO2_MASS_YTD", "CALC_CO2_DENS", "GRS_OIL_VOL", "GRS_OIL_VOL_MTD", "GRS_OIL_VOL_QTD", "GRS_OIL_VOL_YTD", "NET_OIL_VOL", "NET_OIL_VOL_MTD", "NET_OIL_VOL_QTD", "NET_OIL_VOL_YTD", "GRS_OIL_MASS", "GRS_OIL_MASS_MTD", "GRS_OIL_MASS_QTD", "GRS_OIL_MASS_YTD", "NET_OIL_MASS", "NET_OIL_MASS_MTD", "NET_OIL_MASS_QTD", "NET_OIL_MASS_YTD", "CALC_OIL_DENS", "GRS_GAS_VOL", "GRS_GAS_VOL_MTD", "GRS_GAS_VOL_QTD", "GRS_GAS_VOL_YTD", "NET_GAS_VOL", "NET_GAS_VOL_MTD", "NET_GAS_VOL_QTD", "NET_GAS_VOL_YTD", "GRS_GAS_MASS", "GRS_GAS_MASS_MTD", "GRS_GAS_MASS_QTD", "GRS_GAS_MASS_YTD", "NET_GAS_MASS", "NET_GAS_MASS_MTD", "NET_GAS_MASS_QTD", "NET_GAS_MASS_YTD", "CALC_GAS_DENS", "GRS_WATER_VOL", "GRS_WATER_VOL_MTD", "GRS_WATER_VOL_QTD", "GRS_WATER_VOL_YTD", "NET_WATER_VOL", "NET_WATER_VOL_MTD", "NET_WATER_VOL_QTD", "NET_WATER_VOL_YTD", "GRS_WATER_MASS", "GRS_WATER_MASS_MTD", "GRS_WATER_MASS_QTD", "GRS_WATER_MASS_YTD", "NET_WATER_MASS", "NET_WATER_MASS_MTD", "NET_WATER_MASS_QTD", "NET_WATER_MASS_YTD", "CALC_WATER_DENS", "GRS_COND_VOL", "GRS_COND_VOL_MTD", "GRS_COND_VOL_QTD", "GRS_COND_VOL_YTD", "NET_COND_VOL", "NET_COND_VOL_MTD", "NET_COND_VOL_QTD", "NET_COND_VOL_YTD", "GRS_COND_MASS", "GRS_COND_MASS_MTD", "GRS_COND_MASS_QTD", "GRS_COND_MASS_YTD", "NET_COND_MASS", "NET_COND_MASS_MTD", "NET_COND_MASS_QTD", "NET_COND_MASS_YTD", "CALC_COND_DENS", "GRS_NGL_VOL", "GRS_NGL_VOL_MTD", "GRS_NGL_VOL_QTD", "GRS_NGL_VOL_YTD", "NET_NGL_VOL", "NET_NGL_VOL_MTD", "NET_NGL_VOL_QTD", "NET_NGL_VOL_YTD", "GRS_NGL_MASS", "GRS_NGL_MASS_MTD", "GRS_NGL_MASS_QTD", "GRS_NGL_MASS_YTD", "NET_NGL_MASS", "NET_NGL_MASS_MTD", "NET_NGL_MASS_QTD", "NET_NGL_MASS_YTD", "CALC_NGL_DENS", "CALC_ENERGY", "CALC_ENERGY_MTD", "CALC_ENERGY_QTD", "CALC_ENERGY_YTD", "GRS_STEAM_VOL", "GRS_STEAM_VOL_MTD", "GRS_STEAM_VOL_QTD", "GRS_STEAM_VOL_YTD", "NET_STEAM_VOL", "NET_STEAM_VOL_MTD", "NET_STEAM_VOL_QTD", "NET_STEAM_VOL_YTD", "GRS_ELEC_VOL", "GRS_ELEC_VOL_MTD", "GRS_ELEC_VOL_QTD", "GRS_ELEC_VOL_YTD", "NET_ELEC_VOL", "NET_ELEC_VOL_MTD", "NET_ELEC_VOL_QTD", "NET_ELEC_VOL_YTD", "AVG_TEMP", "AVG_PRESS", "MIN_PRESS", "AVG_PL_PRESS", "DENSITY", "DENSITY_KGM3", "AVG_DIFF_PRESS", "RUN_SIZE", "ENERGY", "ENERGY_2", "ENERGY_CONTENT", "BS_W_WT", "WATER_WT", "H2S", "H2S_2", "CO2", "SALT", "SALT_MASS", "RVP", "TVP", "WDP", "TOTALIZER", "SP_GRAV", "BOTTOM_STRIP_TEMP", "K_FACTOR", "ORIFICE_SIZE", "AVG_RATE_HR", "EGM_IND", "TOTALIZER_RESET_IND", "METER_PROVED_IND", "COMMENTS", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT sd.DAYTIME,
          s.OBJECT_ID,
          EC_STRM_DAY_STREAM.ON_STREAM_HRS (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.BS_W (s.OBJECT_ID, sd.DAYTIME),
		  DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    FINDGRSSTDMASS (s.OBJECT_ID, sd.DAYTIME, sd.DAYTIME),
             NULL),
		  DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    CALCCUMGRSSTDMASSMTHTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    findGrsSTDMASS (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    CALCCUMGRSSTDMASSYEARTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
		  DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    FINDGRSSTDVOL (s.OBJECT_ID, sd.DAYTIME, sd.DAYTIME),
             NULL),
		  DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    CALCCUMGRSSTDVOLMTHTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    findGrsStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    CALCCUMGRSSTDVOLYEARTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
		  DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    FINDNETSTDMASS (s.OBJECT_ID, sd.DAYTIME, sd.DAYTIME),
             NULL),
		  DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    CALCCUMNETSTDMASSMTHTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    findNetSTDMASS (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    CALCCUMNETSTDMASSYEARTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
		  DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    FINDNETSTDVOL (s.OBJECT_ID, sd.DAYTIME, sd.DAYTIME),
             NULL),
		  DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    CALCCUMNETSTDVOLMTHTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    findNetStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
		  DECODE (
             sv.stream_phase,
             'LNG', ECBP_STREAM_FLUID.
                    CALCCUMNETSTDVOLYEARTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
		  --CO2
		  DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    FINDGRSSTDVOL (s.OBJECT_ID, sd.DAYTIME, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    CALCCUMGRSSTDVOLMTHTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    findGrsStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    CALCCUMGRSSTDVOLYEARTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    FINDNETSTDVOL (s.OBJECT_ID, sd.DAYTIME, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    CALCCUMNETSTDVOLMTHTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    findNetStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    CALCCUMNETSTDVOLYEARTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    FINDGRSSTDMASS (s.OBJECT_ID, sd.DAYTIME, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    CALCCUMGRSSTDMASSMTHTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    findGrsSTDMASS (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    CALCCUMGRSSTDMASSYEARTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    FINDNETSTDMASS (s.OBJECT_ID, sd.DAYTIME, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    CALCCUMNETSTDMASSMTHTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    findNetSTDMASS (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.
                    CALCCUMNETSTDMASSYEARTODAY (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'CO2', ECBP_STREAM_FLUID.FINDSTDDENS (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          -- OIL
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.FINDGRSSTDVOL (s.OBJECT_ID,
                                                     sd.DAYTIME,
                                                     sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLMTHTODAY (s.OBJECT_ID,
                                                                sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.findGrsStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLYEARTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.FINDNETSTDVOL (s.OBJECT_ID,
                                                     sd.DAYTIME,
                                                     sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLMTHTODAY (s.OBJECT_ID,
                                                                sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.findNetStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLYEARTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.FINDGRSSTDMASS (s.OBJECT_ID,
                                                      sd.DAYTIME,
                                                      sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.CALCCUMGRSSTDMASSMTHTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.findGrsStdMass (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.CALCCUMGRSSTDMASSYEARTODAY (
                       s.OBJECT_ID,
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.FINDNETSTDMASS (s.OBJECT_ID,
                                                      sd.DAYTIME,
                                                      sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.CALCCUMNETSTDMASSMTHTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.findNetStdMass (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.CALCCUMNETSTDMASSYEARTODAY (
                       s.OBJECT_ID,
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'OIL', ECBP_STREAM_FLUID.FINDSTDDENS (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          -- GAS
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.FINDGRSSTDVOL (s.OBJECT_ID,
                                                     sd.DAYTIME,
                                                     sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLMTHTODAY (s.OBJECT_ID,
                                                                sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.findGrsStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLYEARTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.FINDNETSTDVOL (s.OBJECT_ID,
                                                     sd.DAYTIME,
                                                     sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLMTHTODAY (s.OBJECT_ID,
                                                                sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.findNetStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLYEARTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.FINDGRSSTDMASS (s.OBJECT_ID,
                                                      sd.DAYTIME,
                                                      sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.CALCCUMGRSSTDMASSMTHTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.findGrsSTDMASS (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.CALCCUMGRSSTDMASSYEARTODAY (
                       s.OBJECT_ID,
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.FINDNETSTDMASS (s.OBJECT_ID,
                                                      sd.DAYTIME,
                                                      sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.CALCCUMNETSTDMASSMTHTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.findNetSTDMASS (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.CALCCUMNETSTDMASSYEARTODAY (
                       s.OBJECT_ID,
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'GAS', ECBP_STREAM_FLUID.FINDSTDDENS (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          -- WATER
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.FINDGRSSTDVOL (s.OBJECT_ID,
                                                     sd.DAYTIME,
                                                     sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLMTHTODAY (s.OBJECT_ID,
                                                                sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.findGrsStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLYEARTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.FINDNETSTDVOL (s.OBJECT_ID,
                                                     sd.DAYTIME,
                                                     sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLMTHTODAY (s.OBJECT_ID,
                                                                sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.findNetStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLYEARTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.FINDGRSSTDMASS (s.OBJECT_ID,
                                                      sd.DAYTIME,
                                                      sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.CALCCUMGRSSTDMASSMTHTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.findGrsSTDMASS (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.CALCCUMGRSSTDMASSYEARTODAY (
                       s.OBJECT_ID,
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.FINDNETSTDMASS (s.OBJECT_ID,
                                                      sd.DAYTIME,
                                                      sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.CALCCUMNETSTDMASSMTHTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.findNetSTDMASS (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.CALCCUMNETSTDMASSYEARTODAY (
                       s.OBJECT_ID,
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'WAT', ECBP_STREAM_FLUID.FINDWATDENS (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          -- CONDENSATE
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.FINDGRSSTDVOL (s.OBJECT_ID,
                                                      sd.DAYTIME,
                                                      sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLMTHTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.findGrsStdVol (
                        s.OBJECT_ID,
                        GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                  TRUNC (sd.DAYTIME, 'Q')),
                        sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLYEARTODAY (
                        s.OBJECT_ID,
                        sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.FINDNETSTDVOL (s.OBJECT_ID,
                                                      sd.DAYTIME,
                                                      sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLMTHTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.findNetStdVol (
                        s.OBJECT_ID,
                        GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                  TRUNC (sd.DAYTIME, 'Q')),
                        sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLYEARTODAY (
                        s.OBJECT_ID,
                        sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.FINDGRSSTDMASS (s.OBJECT_ID,
                                                       sd.DAYTIME,
                                                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.CALCCUMGRSSTDMASSMTHTODAY (
                        s.OBJECT_ID,
                        sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.findGrsSTDMASS (
                        s.OBJECT_ID,
                        GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                  TRUNC (sd.DAYTIME, 'Q')),
                        sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.CALCCUMGRSSTDMASSYEARTODAY (
                        s.OBJECT_ID,
                        sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.FINDNETSTDMASS (s.OBJECT_ID,
                                                       sd.DAYTIME,
                                                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.CALCCUMNETSTDMASSMTHTODAY (
                        s.OBJECT_ID,
                        sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.findNetSTDMASS (
                        s.OBJECT_ID,
                        GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                  TRUNC (sd.DAYTIME, 'Q')),
                        sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.CALCCUMNETSTDMASSYEARTODAY (
                        s.OBJECT_ID,
                        sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'COND', ECBP_STREAM_FLUID.FINDSTDDENS (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          -- LPG
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.FINDGRSSTDVOL (s.OBJECT_ID,
                                                     sd.DAYTIME,
                                                     sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLMTHTODAY (s.OBJECT_ID,
                                                                sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.findGrsStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLYEARTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.FINDNETSTDVOL (s.OBJECT_ID,
                                                     sd.DAYTIME,
                                                     sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLMTHTODAY (s.OBJECT_ID,
                                                                sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.findNetStdVol (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLYEARTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.FINDGRSSTDMASS (s.OBJECT_ID,
                                                      sd.DAYTIME,
                                                      sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.CALCCUMGRSSTDMASSMTHTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.findGrsSTDMASS (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.CALCCUMGRSSTDMASSYEARTODAY (
                       s.OBJECT_ID,
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.FINDNETSTDMASS (s.OBJECT_ID,
                                                      sd.DAYTIME,
                                                      sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.CALCCUMNETSTDMASSMTHTODAY (s.OBJECT_ID,
                                                                 sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.findNetSTDMASS (
                       s.OBJECT_ID,
                       GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.CALCCUMNETSTDMASSYEARTODAY (
                       s.OBJECT_ID,
                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'NGL', ECBP_STREAM_FLUID.FINDSTDDENS (s.OBJECT_ID, sd.DAYTIME),
             NULL),
          ECBP_STREAM_FLUID.FINDENERGY (s.OBJECT_ID, sd.DAYTIME),
          ECBP_STREAM_FLUID.FINDENERGY (
             s.OBJECT_ID,
             GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                       TRUNC (sd.DAYTIME, 'MM')),
             sd.DAYTIME),
          ECBP_STREAM_FLUID.FINDENERGY (
             s.OBJECT_ID,
             GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                       TRUNC (sd.DAYTIME, 'Q')),
             sd.DAYTIME),
          ECBP_STREAM_FLUID.FINDENERGY (
             s.OBJECT_ID,
             GREATEST (EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                       TRUNC (sd.DAYTIME, 'Y')),
             sd.DAYTIME),                                                   --
          -- STEAM
          DECODE (
             sv.stream_phase,
             'STEAM', ECBP_STREAM_FLUID.FINDGRSSTDVOL (s.OBJECT_ID,
                                                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'STEAM', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLMTHTODAY (
                         s.OBJECT_ID,
                         sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'STEAM', ECBP_STREAM_FLUID.FINDGRSSTDVOL (
                         s.OBJECT_ID,
                         GREATEST (
                            EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                            TRUNC (sd.DAYTIME, 'Q')),
                         sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'STEAM', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLYEARTODAY (
                         s.OBJECT_ID,
                         sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'STEAM', ECBP_STREAM_FLUID.FINDNETSTDVOL (s.OBJECT_ID,
                                                       sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'STEAM', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLMTHTODAY (
                         s.OBJECT_ID,
                         sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'STEAM', ECBP_STREAM_FLUID.FINDNETSTDVOL (
                         s.OBJECT_ID,
                         GREATEST (
                            EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                            TRUNC (sd.DAYTIME, 'Q')),
                         sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'STEAM', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLYEARTODAY (
                         s.OBJECT_ID,
                         sd.DAYTIME),
             NULL),
          -- ELECTRICAL
          DECODE (
             sv.stream_phase,
             'ELECTRICAL', ECBP_STREAM_FLUID.FINDGRSSTDVOL (s.OBJECT_ID,
                                                            sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'ELECTRICAL', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLMTHTODAY (
                              s.OBJECT_ID,
                              sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'ELECTRICAL', ECBP_STREAM_FLUID.FINDGRSSTDVOL (
                              s.OBJECT_ID,
                              GREATEST (
                                 EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                              sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'ELECTRICAL', ECBP_STREAM_FLUID.CALCCUMGRSSTDVOLYEARTODAY (
                              s.OBJECT_ID,
                              sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'ELECTRICAL', ECBP_STREAM_FLUID.FINDNETSTDVOL (s.OBJECT_ID,
                                                            sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'ELECTRICAL', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLMTHTODAY (
                              s.OBJECT_ID,
                              sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'ELECTRICAL', ECBP_STREAM_FLUID.FINDNETSTDVOL (
                              s.OBJECT_ID,
                              GREATEST (
                                 EcDp_Objects.GetObjStartDate (s.OBJECT_ID),
                                 TRUNC (sd.DAYTIME, 'Q')),
                              sd.DAYTIME),
             NULL),
          DECODE (
             sv.stream_phase,
             'ELECTRICAL', ECBP_STREAM_FLUID.CALCCUMNETSTDVOLYEARTODAY (
                              s.OBJECT_ID,
                              sd.DAYTIME),
             NULL),
          EC_STRM_DAY_STREAM.AVG_TEMP (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.AVG_PRESS (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.MIN_PRESS (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.AVG_PL_PRESS (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.DENSITY (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.DENSITY (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.DENSITY_KGM3 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.AVG_DIFF_PRESS (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.RUN_SIZE (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.ENERGY (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.ENERGY_CONTENT (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.BS_W_WT (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.WATER_WT (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.H2S (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.H2S_2 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.CO2 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.SALT (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.SALT_MASS (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.RVP (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.TVP (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.WDP (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.TOTALIZER (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.SP_GRAV (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.BOTTOM_STRIP_TEMP (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.K_FACTOR (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.ORIFICE_SIZE (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.AVG_RATE_HR (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.EGM_IND (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.TOTALIZER_RESET_IND (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.METER_PROVED_IND (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.COMMENTS (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.VALUE_1 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.VALUE_2 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.VALUE_3 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.VALUE_4 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.VALUE_5 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.VALUE_6 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.VALUE_7 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.VALUE_8 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.VALUE_9 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.VALUE_10 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.TEXT_1 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.TEXT_2 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.TEXT_3 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.TEXT_4 (s.OBJECT_ID, sd.DAYTIME),
          EC_STRM_DAY_STREAM.RECORD_STATUS (s.OBJECT_ID, sd.DAYTIME),
          sv.CREATED_BY,
          sv.CREATED_DATE,
          sv.LAST_UPDATED_BY,
          sv.LAST_UPDATED_DATE,
          sv.REV_NO,
          sv.REV_TEXT
     FROM STREAM s, STRM_VERSION sv, SYSTEM_DAYS sd
    WHERE     s.object_id = sv.object_id
          AND sd.DAYTIME >= sv.daytime
          AND sd.daytime < NVL (sv.end_date, sd.daytime + 1)
          AND sv.stream_phase IN ('OIL',
                                  'GAS',
                                  'WAT',
                                  'COND',
                                  'NGL',
                                  'ELECTRICAL',
                                  'STEAM');
