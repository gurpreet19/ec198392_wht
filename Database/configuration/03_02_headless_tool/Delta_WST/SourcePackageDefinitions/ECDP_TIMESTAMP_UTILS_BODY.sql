CREATE OR REPLACE PACKAGE BODY EcDp_Timestamp_Utils IS

TYPE t_dst_switch IS RECORD (time_zone  VARCHAR2(65),
                             dst_year   DATE,
                             summer     DATE,  -- switch to summer
                             winter     DATE); -- switch to winter

lc_dst_switch t_dst_switch;

------------------- Support for internal summertime flag -----------
PROCEDURE resetDstCache(p_time_zone VARCHAR2, p_date DATE)
IS
  CURSOR c_cte(cp_timezone VARCHAR2, cp_daytime DATE) IS
    WITH date_cte AS
     (     SELECT TRUNC(cp_daytime, 'YY') + rownum -1 daytime
         FROM ctrl_db_version WHERE db_version = 1
         CONNECT BY rownum <= ADD_MONTHS(TRUNC(cp_daytime, 'yy'), 12) - TRUNC(cp_daytime, 'yy')),
    dst_sub AS
     (SELECT daytime,
             TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime AS TIMESTAMP), cp_timezone),
                               'TZH')) +
             TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime AS TIMESTAMP), cp_timezone),
                               'TZM')) / 60 offset,
             TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime + 1 AS TIMESTAMP),
                                       cp_timezone),
                               'TZH')) +
             TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime + 1 AS TIMESTAMP),
                                       cp_timezone),
                               'TZM')) / 60 next_offset
        FROM date_cte)
    SELECT daytime, Ecdp_Timestamp_Utils.getDSTTime(cp_timezone, daytime) dst_switch, offset, next_offset
      FROM dst_sub
     WHERE offset <> next_offset
     ORDER BY daytime;

  cp_year   DATE := TRUNC(p_date, 'YY');
BEGIN
  lc_dst_switch.time_zone := p_time_zone;
  lc_dst_switch.dst_year  := cp_year;

  FOR one IN c_cte(p_time_zone, p_date) LOOP
    IF one.offset > one.next_offset THEN
      lc_dst_switch.winter := one.dst_switch;
    ELSE
      lc_dst_switch.summer := one.dst_switch;
    END IF;
  END LOOP;
END resetDstCache;

FUNCTION getDSTCache(p_time_zone VARCHAR2, p_date DATE) RETURN t_dst_switch
IS
BEGIN

  IF lc_dst_switch.dst_year IS NULL OR lc_dst_switch.time_zone <> p_time_zone OR lc_dst_switch.dst_year <> TRUNC(p_date, 'YY') THEN
    resetDstCache(p_time_zone, p_date);
  END IF;
  RETURN lc_dst_switch;
END getDSTCache;

FUNCTION internal_summertime_flag(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS

  lv_timezone       VARCHAR2(50);
  ln_from_offset    NUMBER;
  ln_to_offset      NUMBER;
  ld_from           DATE;
  ld_to             DATE;
  lv_result         VARCHAR2(5) := 'N';
  lr_dst_switch     t_dst_switch;
BEGIN

  lv_timezone := Ecdp_Timestamp.getTimeZone(p_object_id, p_daytime);
  lr_dst_switch := getDSTCache(lv_timezone, p_daytime);

  IF lc_dst_switch.summer IS NULL THEN
    -- DST not observed
    lv_result := 'N';
  ELSIF p_daytime >= lc_dst_switch.summer AND p_daytime < lc_dst_switch.winter THEN
    lv_result := 'Y';
  ELSE
    lv_result := 'N';
  END IF;

  RETURN lv_result;

END internal_summertime_flag;

FUNCTION internal_local2utc(p_object_id VARCHAR2, p_daytime DATE,p_summertime_flag VARCHAR2 DEFAULT 'N') RETURN DATE IS

  ld_return         DATE;
  lv_timezone       VARCHAR2(65);
  lr_dst_switch     t_dst_switch;

BEGIN
  ld_return := Ecdp_Timestamp.local2utc(p_object_id, p_daytime);
  lv_timezone := Ecdp_Timestamp.getTimeZone(p_object_id, p_daytime);
  lr_dst_switch := getDSTCache(lv_timezone, p_daytime);

  IF lr_dst_switch.winter = ld_return THEN
    IF p_summertime_flag = 'Y' THEN
      ld_return := ld_return - 1/24;
    END IF;
  END IF;

  RETURN ld_return;
END internal_local2utc;

------------------- Support for internal summertime flag -----------

PROCEDURE syncUtcDate(p_object_id VARCHAR2
                     ,p_utc_daytime IN OUT NOCOPY DATE
                     ,p_daytime IN OUT NOCOPY DATE
                     ,p_summertime IN OUT NOCOPY VARCHAR2)
IS
  ld_param_date DATE;
BEGIN
   ld_param_date := Nvl(p_utc_daytime, p_daytime);
   -- Do nothing if non of the date are set
   IF ld_param_date IS NOT NULL THEN

      IF p_summertime IS NULL THEN
         p_summertime := internal_summertime_flag(p_object_id, ld_param_date);
      END IF;

      -- TODO exception when both p_utc_daytime and p_daytime are null
      IF p_daytime IS NULL THEN
         -- utc_daytime must not null
         p_daytime := Ecdp_Timestamp.utc2local(p_object_id, p_utc_daytime);
      END IF;

      IF p_utc_daytime IS NULL THEN
         p_utc_daytime := internal_local2utc(p_object_id, p_daytime, p_summertime);
      END IF;
   END IF;
END syncUtcDate;

PROCEDURE syncUtcDate(p_object_id VARCHAR2
                     ,p_utc_daytime IN OUT NOCOPY DATE
                     ,p_daytime IN OUT NOCOPY DATE)
IS
  ld_param_date DATE;
BEGIN
   ld_param_date := Nvl(p_utc_daytime, p_daytime);
   -- Do nothing if non of the date are set
   IF ld_param_date IS NOT NULL THEN

      -- TODO exception when both p_utc_daytime and p_daytime are null
      IF p_daytime IS NULL THEN
         -- utc_daytime must not null
         p_daytime := Ecdp_Timestamp.utc2local(p_object_id, p_utc_daytime);
      END IF;

      IF p_utc_daytime IS NULL THEN
         p_utc_daytime := Ecdp_Timestamp.local2utc(p_object_id, p_daytime);
      END IF;
   END IF;
END syncUtcDate;

PROCEDURE updateUtcAndDaytime(p_object_id VARCHAR2
                     ,p_old_utc_daytime DATE
                     ,p_new_utc_daytime IN OUT NOCOPY DATE
                     ,p_old_daytime DATE
                     ,p_new_daytime IN OUT NOCOPY DATE
                     ,p_old_summertime VARCHAR2
                     ,p_new_summertime IN OUT NOCOPY VARCHAR2)
IS

BEGIN
   -- updating daytime only
   IF p_new_daytime IS NOT NULL AND Nvl(p_old_daytime, p_new_daytime - 1) <> p_new_daytime
         AND Nvl(p_old_utc_daytime, Ecdp_System_Constants.EARLIEST_DATE) = Nvl(p_new_utc_daytime, Ecdp_System_Constants.EARLIEST_DATE) THEN

      p_new_summertime := internal_summertime_flag(p_object_id, p_new_daytime);
      p_new_utc_daytime := internal_local2utc(p_object_id, p_new_daytime, p_new_summertime);

   -- updating daytime only to NULL
   ELSIF p_new_daytime IS NULL AND p_old_daytime IS NOT NULL
         AND Nvl(p_old_utc_daytime, Ecdp_System_Constants.EARLIEST_DATE) = Nvl(p_new_utc_daytime, Ecdp_System_Constants.EARLIEST_DATE) THEN

      p_new_utc_daytime := NULL;
      p_new_summertime := NULL;

   -- updating utc_daytime only
   ELSIF p_new_utc_daytime IS NOT NULL
         AND Nvl(p_old_daytime, Ecdp_System_Constants.EARLIEST_DATE) = Nvl(p_new_daytime, Ecdp_System_Constants.EARLIEST_DATE)
         AND Nvl(p_old_utc_daytime, p_new_utc_daytime - 1) <> p_new_utc_daytime THEN

      p_new_daytime := Ecdp_Timestamp.utc2local(p_object_id, p_new_utc_daytime);
      p_new_summertime := internal_summertime_flag(p_object_id, p_new_daytime);

   -- updating utc_daytime only to NULL
   ELSIF p_new_utc_daytime IS NULL AND p_old_utc_daytime IS NOT NULL
         AND Nvl(p_old_daytime, Ecdp_System_Constants.EARLIEST_DATE) = Nvl(p_new_daytime, Ecdp_System_Constants.EARLIEST_DATE)
         THEN
      p_new_daytime := NULL;
      p_new_summertime := NULL;

   -- other unhandled cases, e.g. setting to original value or all values are set correctly
   END IF;

END updateUtcAndDaytime;

PROCEDURE updateUtcAndDaytime(p_object_id VARCHAR2
                     ,p_old_utc_daytime DATE
                     ,p_new_utc_daytime IN OUT NOCOPY DATE
                     ,p_old_daytime DATE
                     ,p_new_daytime IN OUT NOCOPY DATE)
IS
BEGIN

   -- updating daytime only
   IF p_new_daytime IS NOT NULL AND Nvl(p_old_daytime, p_new_daytime - 1) <> p_new_daytime
         AND Nvl(p_old_utc_daytime, Ecdp_System_Constants.EARLIEST_DATE) = Nvl(p_new_utc_daytime, Ecdp_System_Constants.EARLIEST_DATE) THEN
      p_new_utc_daytime := Ecdp_Timestamp.local2utc(p_object_id, p_new_daytime);

   -- updating daytime only to NULL
   ELSIF p_new_daytime IS NULL AND p_old_daytime IS NOT NULL
         AND Nvl(p_old_utc_daytime, Ecdp_System_Constants.EARLIEST_DATE) = Nvl(p_new_utc_daytime, Ecdp_System_Constants.EARLIEST_DATE) THEN
      p_new_utc_daytime := NULL;

   -- updating utc_daytime only
   ELSIF p_new_utc_daytime IS NOT NULL
         AND Nvl(p_old_daytime, Ecdp_System_Constants.EARLIEST_DATE) = Nvl(p_new_daytime, Ecdp_System_Constants.EARLIEST_DATE)
         AND Nvl(p_old_utc_daytime, p_new_utc_daytime - 1) <> p_new_utc_daytime THEN
      p_new_daytime := Ecdp_Timestamp.utc2local(p_object_id, p_new_utc_daytime);

   -- updating utc_daytime only to NULL
   ELSIF p_new_utc_daytime IS NULL AND p_old_utc_daytime IS NOT NULL
         AND Nvl(p_old_daytime, Ecdp_System_Constants.EARLIEST_DATE) = Nvl(p_new_daytime, Ecdp_System_Constants.EARLIEST_DATE)
         THEN
      p_new_daytime := NULL;
   END IF;

END updateUtcAndDaytime;

PROCEDURE setProductionDay(p_object_id VARCHAR2
                          ,p_utc_daytime DATE
                          ,p_production_day IN OUT NOCOPY DATE)
IS
BEGIN
   IF p_utc_daytime IS NOT NULL THEN
      IF p_production_day IS NULL THEN
         p_production_day := Ecdp_Timestamp.getProductionDay(p_object_id, Ecdp_Timestamp.utc2local(p_object_id, p_utc_daytime));
      END IF;
   END IF;

END setProductionDay;

PROCEDURE updateProductionDay(p_object_id VARCHAR2
                          ,p_old_utc_daytime DATE
                          ,p_new_utc_daytime DATE
                          ,p_old_production_day DATE
                          ,p_new_production_day IN OUT NOCOPY DATE)
IS
BEGIN
   IF Nvl(p_old_utc_daytime, Ecdp_System_Constants.FUTURE_DATE) <> Nvl(p_new_utc_daytime, Ecdp_System_Constants.FUTURE_DATE) THEN
      IF p_new_utc_daytime IS NOT NULL THEN
         p_new_production_day := Ecdp_Timestamp.getProductionDay(p_object_id, p_new_utc_daytime);
      ELSE
         p_new_production_day := NULL;
      END IF;
   END IF;

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
  ld_utc        := CAST(FROM_TZ(CAST(p_day - 2/24 AS TIMESTAMP), p_time_zone) AT TIME ZONE 'UTC' AS DATE);
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

FUNCTION timeOffsetToHrs(p_time_offset VARCHAR2, p_strict VARCHAR2 DEFAULT 'Y')
RETURN NUMBER
RESULT_CACHE
IS
  lb_match BOOLEAN := CASE WHEN regexp_substr(p_time_offset, '^[+-]?\d\d:\d\d$') IS NOT NULL THEN TRUE ELSE FALSE END;
  ln_hrs NUMBER := to_number(regexp_substr(p_time_offset, '\d\d', 1, 1));
  ln_mins NUMBER := to_number(regexp_substr(p_time_offset, '\d\d', 1, 2));
  ln_sign NUMBER := CASE WHEN nvl(regexp_substr(p_time_offset, '^[-]'), '+') = '-' THEN -1 ELSE 1 END;
BEGIN
  RETURN CASE WHEN lb_match AND (p_strict = 'N' OR (ln_hrs < 24 AND ln_mins < 60)) THEN ln_sign*(ln_hrs*60 + ln_mins)/60 ELSE NULL END;
END timeOffsetToHrs;

END EcDp_Timestamp_Utils;