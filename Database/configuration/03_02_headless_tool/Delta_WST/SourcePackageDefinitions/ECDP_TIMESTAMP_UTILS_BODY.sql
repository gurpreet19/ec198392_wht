CREATE OR REPLACE PACKAGE BODY EcDp_Timestamp_Utils IS

PROCEDURE syncUtcDate(p_class_name VARCHAR2
                     ,p_object_id VARCHAR2
                     ,p_utc_daytime IN OUT NOCOPY DATE
                     ,p_time_zone IN OUT NOCOPY VARCHAR2
                     ,p_daytime IN OUT NOCOPY DATE
                     ,p_summertime IN OUT NOCOPY VARCHAR2)
IS
  lv_pday_object_id VARCHAR2(32);
  ld_param_date DATE;
BEGIN
  ld_param_date := Nvl(p_utc_daytime, p_daytime);
  lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(p_class_name, p_object_id, ld_param_date);

  IF p_summertime IS NULL THEN
     p_summertime := EcDp_Date_Time.summertime_flag(ld_param_date, NULL, lv_pday_object_id);
  END IF;

  -- TODO exception when both p_utc_daytime and p_daytime are null
  IF p_daytime IS NULL THEN
    -- utc_daytime must not null
    p_daytime := Ecdp_Timestamp.utc2local(p_class_name, p_object_id, p_utc_daytime);
  END IF;

  IF p_utc_daytime IS NULL THEN
    p_utc_daytime := Ecdp_Date_Time.local2utc(p_daytime, p_summertime, lv_pday_object_id);
  END IF;
  IF p_time_zone IS NULL THEN
    p_time_zone := Ecdp_Timestamp.getTimeZone(p_class_name, p_object_id, p_utc_daytime);
  END IF;

END syncUtcDate;

PROCEDURE updateUtcDate(p_class_name VARCHAR2
                     ,p_object_id VARCHAR2
                     ,p_daytime DATE
                     ,p_summertime VARCHAR2
                     ,p_utc_daytime IN OUT NOCOPY DATE)
IS
BEGIN

  p_utc_daytime := Ecdp_Timestamp.local2utc(p_class_name, p_object_id, p_daytime);

END updateUtcDate;

PROCEDURE updateDaytime(p_class_name VARCHAR2
                     ,p_object_id VARCHAR2
                     ,p_utc_daytime DATE
                     ,p_daytime IN OUT NOCOPY DATE
                     ,p_summertime IN OUT NOCOPY VARCHAR2)
IS
  lv_pday_object_id VARCHAR2(32);

BEGIN
  p_daytime := Ecdp_Timestamp.utc2local(p_class_name, p_object_id, p_utc_daytime);
  lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(p_class_name, p_object_id, p_daytime);
  p_summertime := EcDp_Date_Time.summertime_flag(p_daytime, NULL, lv_pday_object_id);
END updateDaytime;

PROCEDURE setProductionDay(p_class_name VARCHAR2
                          ,p_object_id VARCHAR2
                          ,p_utc_daytime DATE
                          ,p_production_day IN OUT NOCOPY DATE
                          ,p_update BOOLEAN DEFAULT FALSE)
IS
BEGIN
  IF p_update = FALSE AND p_production_day IS NULL THEN
     p_production_day := Ecdp_Timestamp.getProductionDay(p_class_name, p_object_id, p_utc_daytime);
  ELSIF p_update THEN
     p_production_day := Ecdp_Timestamp.getProductionDay(p_class_name, p_object_id, p_utc_daytime);
  END IF;

END setProductionDay;

PROCEDURE updateProductionDay(p_class_name VARCHAR2
                          ,p_object_id VARCHAR2
                          ,p_utc_daytime DATE
                          ,p_production_day IN OUT NOCOPY DATE)
IS
BEGIN
  setProductionDay(p_class_name, p_object_id, p_utc_daytime, p_production_day, TRUE);
END updateProductionDay;

FUNCTION getDSTTime(p_time_zone VARCHAR2, p_day DATE) RETURN DATE
IS
  ld_result     DATE;
  ld_utc        DATE;
  ld_utc_end    DATE;
  ld_current    DATE;
  ld_next       DATE;
BEGIN
  -- use direct call
  ld_utc        := CAST(FROM_TZ(CAST(p_day - 1/24 AS TIMESTAMP), p_time_zone) AT TIME ZONE 'UTC' AS DATE);
  ld_utc_end    := CAST(FROM_TZ(CAST(p_day + 1 AS TIMESTAMP), p_time_zone) AT TIME ZONE 'UTC' AS DATE);

  WHILE ld_utc < ld_utc_end LOOP
    ld_current := CAST(FROM_TZ(CAST(ld_utc AS TIMESTAMP), 'UTC') AT TIME ZONE p_time_zone AS DATE);
    ld_next    := CAST(FROM_TZ(CAST(ld_utc + 1/24 AS TIMESTAMP), 'UTC') AT TIME ZONE p_time_zone AS DATE);

    IF ld_current = ld_next THEN
      -- Duplicated date
      ld_result := ld_utc + 1/24;
      EXIT;
    END IF;

    IF ld_current + 2/24 = ld_next THEN
      ld_result := ld_utc + 1/24;
      EXIT;
    END IF;

    ld_utc := ld_utc + 1/24;
  END LOOP;

  RETURN ld_result;

END getDSTTime;
END EcDp_Timestamp_Utils;