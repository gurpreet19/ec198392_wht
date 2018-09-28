CREATE OR REPLACE FORCE VIEW CV_TANK_DAY_ALL
AS 
SELECT 
'CV_TANK_DAY_ALL' AS CLASS_NAME,
TANK_MEASUREMENT.OBJECT_ID AS OBJECT_ID,
o.OBJECT_CODE OBJECT_CODE,
TU.OBJECT_ID STORAGE_ID,
EC_STORAGE.object_code(TU.OBJECT_ID) AS STORAGE_CODE,
TANK_MEASUREMENT.DAYTIME AS DAYTIME,
oa.TANK_METER_FREQ AS TANK_METER_FREQ,
TANK_MEASUREMENT.GRS_DIP_LEVEL AS LIQUID_DIP_LEVEL,
TANK_MEASUREMENT.WAT_DIP_LEVEL AS WAT_DIP_LEVEL,
oa.STRAP_LEVEL_UOM AS DIP_UOM,
TANK_MEASUREMENT.BSW_VOL AS BSW_VOL,
TANK_MEASUREMENT.TEMP AS AVG_TEMP,
TANK_MEASUREMENT.LINE_TEMP AS LINE_TEMP,
TANK_MEASUREMENT.API AS API,
TANK_MEASUREMENT.CORR_API AS CORR_API,
TANK_MEASUREMENT.VCF AS VCF,
ecbp_tank.findGrsVol(TANK_MEASUREMENT.OBJECT_ID,'DAY_CLOSING',TANK_MEASUREMENT.DAYTIME) AS LIQUID_VOL,
ecbp_tank.findFreeWaterVol(TANK_MEASUREMENT.OBJECT_ID,'DAY_CLOSING',TANK_MEASUREMENT.DAYTIME) AS FREE_WAT_VOL,
ecbp_tank.findGrsOilVol(TANK_MEASUREMENT.OBJECT_ID,'DAY_CLOSING',TANK_MEASUREMENT.DAYTIME) AS GRS_VOL_OIL,
ecbp_tank.findGrsStdOilVol(TANK_MEASUREMENT.OBJECT_ID,'DAY_CLOSING',TANK_MEASUREMENT.DAYTIME) AS STD_GRS_VOL_OIL,
ecbp_tank.findNetStdOilVol(TANK_MEASUREMENT.OBJECT_ID,'DAY_CLOSING',TANK_MEASUREMENT.DAYTIME) AS STD_NET_VOL_OIL,
ecbp_tank.findWaterVol(TANK_MEASUREMENT.OBJECT_ID,'DAY_CLOSING',TANK_MEASUREMENT.DAYTIME) AS GRS_VOL_WAT,
oa.VCF_METHOD AS VCF_METHOD,
TANK_MEASUREMENT.DENSITY AS MEAS_STD_DENSITY,
TANK_MEASUREMENT.CLOSING_ENERGY AS CLOSING_ENERGY,
TANK_MEASUREMENT.OBS_DENSITY AS OBS_DENSITY,
TANK_MEASUREMENT.CORR_DENSITY AS CORR_DENSITY,
TANK_MEASUREMENT.RUN_TEMP AS RUN_TEMP,
TANK_MEASUREMENT.RECORD_STATUS AS RECORD_STATUS,
TANK_MEASUREMENT.CREATED_BY AS CREATED_BY,
TANK_MEASUREMENT.CREATED_DATE AS CREATED_DATE,
TANK_MEASUREMENT.LAST_UPDATED_BY AS LAST_UPDATED_BY,
TANK_MEASUREMENT.LAST_UPDATED_DATE AS LAST_UPDATED_DATE,
TANK_MEASUREMENT.REV_NO AS REV_NO,
TANK_MEASUREMENT.REV_TEXT AS REV_TEXT
FROM TANK_MEASUREMENT, TANK_VERSION oa, TANK o, TANK_USAGE tu
WHERE TANK_MEASUREMENT.object_id = oa.object_id
AND oa.object_id = o.object_id
AND TANK_MEASUREMENT.daytime >= oa.daytime
AND TANK_MEASUREMENT.daytime < nvl(oa.end_date,TANK_MEASUREMENT.daytime + 1)
AND MEASUREMENT_EVENT_TYPE = 'DAY_CLOSING'
and oa.object_id  = tu.tank_id (+)
AND TANK_MEASUREMENT.daytime >= tu.daytime (+)
AND TANK_MEASUREMENT.daytime < nvl(tu.end_date,TANK_MEASUREMENT.daytime + 1);
