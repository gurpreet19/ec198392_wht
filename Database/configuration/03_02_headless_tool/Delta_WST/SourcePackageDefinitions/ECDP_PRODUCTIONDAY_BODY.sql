CREATE OR REPLACE PACKAGE BODY EcDp_ProductionDay IS
/****************************************************************
** Package        :  EcDp_ProductionDay, body part
**
** $Revision: 1.20 $
**
** Purpose        :  DUMMY version will be replaced after code freeze
**
** Documentation  :  www.energy-components.com
**
** Created  : 28.04.2006  Arild Vervik
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------
** 28.04.2006  AV     Initial version
** 06.06.2006  Zakiiari TI 4000: extend findProductionDayDefinition to support SEPARATOR,EQUIPMENT class
**                               update findSubDailyFreq to find correct class name if given NULL class name or INTERFACE class type
** 07.08.2006  leechkhe TI 4226  enhance the EcDp_ProductionDay.getProductionDay function to accept NULL as first parameter
** 21-07-2009 leongwen ECPD-11578 support multiple timezones
**                                to add production object id to pass into the function ecdp_date_time.summertime_flag()
** 03-11-2010  farhaann ECPD-15652 Modified findSubDailyFreq: Added condition for WEBO_INTERVAL_VERSION
** 05-08-2012  makkkkam ECDP-19593 Modified findProductionDayDefinition: Added user exit possibility in package logic
** 27-06-2014  abdulmaw ECDP-26928 Modified findProductionDayDefinition: Update EQPM to support merging all equipment into one class
** 30-07-2014  leongwen ECDP-28063 Modified findProductionDayDefinition: Added check on classname for TEST_DEVICE, and return the production_day_id from ec_test_device_version instead.
*****************************************************************/

CURSOR c_productionday(cpdd_object_id VARCHAR2, cp_daytime DATE) IS
  SELECT offset
    FROM  production_day_version pv
    WHERE   nvl(cp_daytime,pv.daytime) >= pv.daytime
    AND     nvl(cp_daytime,pv.daytime) < Nvl(pv.end_date,cp_daytime+1)
    AND   (object_id = cpdd_object_id OR ( cpdd_object_id IS NULL AND pv.default_ind = 'Y'))
    ORDER BY pv.object_id ;


FUNCTION getTZoffsetInDays(p_time_zone_offset VARCHAR2) RETURN NUMBER
IS
BEGIN
  RETURN EcDp_Timestamp_Utils.timeOffsetToHrs(p_time_zone_offset, p_strict => 'N')/24;
END getTZoffsetInDays;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findSubDailyFreq
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findSubDailyFreq(p_class_name  VARCHAR2,
                          p_object_id   VARCHAR2,
                          p_daytime     DATE
                         )
RETURN VARCHAR2
--<EC-DOC>
IS
  lv2_attr_table_name   VARCHAR2(32);
  lv2_freq_code         VARCHAR2(32);
  lv2_default_freq_code VARCHAR2(32);
  lv2_class_name        VARCHAR2(32);
  lv2_column_name       VARCHAR2(32);
BEGIN
  lv2_default_freq_code := '1H';

  IF p_class_name IS NULL OR ec_class_cnfg.class_type(p_class_name)='INTERFACE' THEN
    lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);
  ELSE
    lv2_class_name := p_class_name;
  END IF;

  lv2_attr_table_name := ec_class_cnfg.db_object_attribute(lv2_class_name);

  IF lv2_attr_table_name IS NOT NULL THEN
    lv2_column_name :=
  CASE lv2_attr_table_name
      WHEN 'STRM_VERSION' THEN 'STRM_METER_FREQ'
      WHEN 'WELL_VERSION' THEN 'WELL_METER_FREQ'
      WHEN 'WEBO_INTERVAL_VERSION' THEN 'WBI_METER_FREQ'
      WHEN 'SEPA_VERSION' THEN 'SEPA_METER_FREQ'
      WHEN 'CHEM_TANK_VERSION' THEN 'TANK_METER_FREQ'
      WHEN 'TANK_VERSION' THEN 'TANK_METER_FREQ'
      WHEN 'FLWL_VERSION' THEN 'FLWL_METER_FREQ'
      WHEN 'PIPE_VERSION' THEN 'PIPE_METER_FREQ'
      WHEN 'EQPM_VERSION' THEN 'EQPM_METER_FREQ'
    END;

  IF lv2_column_name IS NOT NULL THEN
    BEGIN
      EXECUTE IMMEDIATE 'SELECT '||lv2_column_name||' FROM '||lv2_attr_table_name||' WHERE object_id = :1 AND daytime <= :2 AND :3 < nvl(end_date, :4 + 1)'
      INTO lv2_freq_code
      USING p_object_id, p_daytime, p_daytime, p_daytime;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL;
    END;
  END IF;

  END IF;

  RETURN nvl(lv2_freq_code, lv2_default_freq_code);

END findSubDailyFreq;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findProductionDayDefinition
-- Description    : take any object_id (including NULL) as input, and should return the object id for the Production Day object
--                  that is active for the input object.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getDefaultProductionDayDefinition, ecdp_dynsql.execute_singlerow_varchar2, ec_class_db_mapping.db_object_attribute,
--                  ecdp_facility.GetParentFacility, ec_production_facility.class_name
--
-- Configuration
-- required       :
--
-- Behaviour      : This should resolve not only a production day defined directly on the object but also any potentially
--                  defined at a higher level as follows:
--                  - If the object_id is NULL then return the default Production Day object.
--                  - Find the class for the object id.
--                  - If the class is one of the "known" classes (i.e. WELL, STREAM, FCTY_CLASS_1 etc):
--                    - Look at the production day relation (in the corresponding attribute table).
--                    - If this is not NULL then return that value
--                    - If it is NULL, then look up the FCTY_CLASS_1 relation (if applicable) and call this function recursively for the facility id
--                  If none of the above works then return the default Production Day object
--
---------------------------------------------------------------------------------------------------
FUNCTION findProductionDayDefinition(p_class_name VARCHAR2, p_object_id  VARCHAR2, p_daytime  DATE)

RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN ecdp_timestamp.getProductionDayVersion(p_object_id, p_daytime).object_id;

END findProductionDayDefinition;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDay
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDay(p_class_name VARCHAR2, p_object_id  VARCHAR2, p_daytime  DATE, p_summertime_flag VARCHAR2 DEFAULT NULL)
RETURN DATE
--</EC-DOC>
IS
BEGIN
   RETURN Ecdp_Timestamp.getProductionDay(p_object_id, p_daytime);

END getProductionDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateDaytimeVsFreq
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateDaytimeVsFreq(p_class_name VARCHAR2,
                                p_object_id  VARCHAR2,
                                p_daytime  DATE,
                                p_summertime_flag VARCHAR2
                                )
--</EC-DOC>
IS
  lv2_pdd_object_id   VARCHAR2(32);
  lv2_freq_code       VARCHAR2(32);
  lv2_summertime_flag VARCHAR2(1);

BEGIN
  lv2_pdd_object_id := findProductionDayDefinition(p_class_name,p_object_id,p_daytime);
  lv2_freq_code := findSubDailyFreq(p_class_name,p_object_id,p_daytime);

  IF p_summertime_flag IS NULL THEN
    lv2_summertime_flag := Ecdp_Date_Time.summertime_flag(p_daytime, NULL, lv2_pdd_object_id);
  ELSE
    lv2_summertime_flag := p_summertime_flag;
  END IF;

  Ecdp_Date_Time.validateDaytimeVsFreq(lv2_pdd_object_id,lv2_freq_code,p_daytime,lv2_summertime_flag);

END validateDaytimeVsFreq;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayStartTime
-- Description    : take a class_name,object_id and a production day as inputs, and
--                  return the sub-daily daytime (in local time) when this production day starts.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--This function should use getProductionDayStartTimeUTC to do the actual job and then convert the result back to local time.
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDayStartTime(p_class_name VARCHAR2,
                                   p_object_id  VARCHAR2,
                                   p_day        DATE
                                   )
RETURN Ecdp_Date_Time.Ec_Unique_Daytime
--</EC-DOC>

IS
  lv2_pdd_object_id     production_day_version.object_id%TYPE;
  ld_pd_start           DATE;
  l_ec_unique_daytime   Ecdp_Date_Time.Ec_Unique_Daytime;

BEGIN
  lv2_pdd_object_id := findProductionDayDefinition(p_class_name,p_object_id,p_day);

  ld_pd_start := getProductionDayStart(p_class_name, p_object_id, p_day);
  l_ec_unique_daytime.daytime := ld_pd_start;
  l_ec_unique_daytime.summertime_flag := EcDp_Date_Time.summertime_flag(ld_pd_start,NULL,lv2_pdd_object_id);
  RETURN l_ec_unique_daytime;

END getProductionDayStartTime;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayStart
-- Description    : take a class_name,object_id and a production day as inputs, and
--                  return the sub-daily daytime (in local time) when this production day starts.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--This function should use getProductionDayStartTimeUTC to do the actual job and then convert the result back to local time.
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDayStart(p_class_name VARCHAR2,
                                   p_object_id  VARCHAR2,
                                   p_day        DATE
                                   )
RETURN DATE
--</EC-DOC>

IS

BEGIN
  RETURN TRUNC(p_day) + getProductionDayOffset(p_class_name, p_object_id, p_day)/24;

END getProductionDayStart;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayFraction
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDayFraction(p_class_name        VARCHAR2,
                                  p_object_id         VARCHAR2,
                                  p_day               DATE,
                                  p_from_daytime      DATE,
                                  p_from_summer_time  VARCHAR2,
                                  p_to_daytime        DATE,
                                  p_to_summer_time    VARCHAR2
                                  )
RETURN NUMBER
--</EC-DOC>

IS
  ld_day_start_utc  DATE;
  ld_day_end_utc    DATE;
  ld_from_utc       DATE;
  ld_to_utc         DATE;

BEGIN
  -- copied from original ecdp_date_time with modifications
    -- Validate p_day
  IF p_day IS NULL OR p_day <> TRUNC(p_day) THEN
    RAISE_APPLICATION_ERROR(-20000,'getProductionDayFraction requires p_day to be a non-NULL day value.');
  END IF;

  -- utc start time
  ld_day_start_utc := Ecdp_Timestamp.local2utc(p_object_id, getProductionDayStart(p_class_name, p_object_id, p_day));
  ld_day_end_utc   := Ecdp_Timestamp.local2utc(p_object_id, getProductionDayStart(p_class_name, p_object_id, p_day + 1));

  IF p_from_daytime IS NULL THEN
    ld_from_utc := ld_day_start_utc;
  ELSE
    ld_from_utc := Ecdp_Timestamp.local2utc(p_object_id, p_from_daytime);
    IF ld_from_utc IS NULL THEN
       RAISE_APPLICATION_ERROR(-20504,to_char(p_from_daytime,'yyyy-mm-dd hh24:mi')||' is not a valid time due to daylight savings time.');
    END IF;
    IF ld_from_utc < ld_day_start_utc THEN
       ld_from_utc := ld_day_start_utc;
    END IF;
  END IF;
  IF p_to_daytime IS NULL THEN
    ld_to_utc := ld_day_end_utc;
  ELSE
    ld_to_utc := Ecdp_Timestamp.local2utc(p_object_id, p_to_daytime);
    IF ld_to_utc IS NULL THEN
       RAISE_APPLICATION_ERROR(-20504,to_char(p_to_daytime,'yyyy-mm-dd hh24:mi')||' is not a valid time due to daylight savings time.');
    END IF;
    IF ld_to_utc > ld_day_end_utc THEN
       ld_to_utc := ld_day_end_utc;
    END IF;
  END IF;

  IF ld_from_utc >= ld_to_utc THEN
    RETURN 0;
  ELSE
    RETURN (ld_to_utc - ld_from_utc) / (ld_day_end_utc - ld_day_start_utc);
  END IF;

END getProductionDayFraction;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayDaytimes
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDayDaytimes(p_class_name  VARCHAR2,
                                  p_object_id   VARCHAR2,
                                  p_day         DATE)
RETURN Ecdp_Date_Time.Ec_Unique_Daytimes

--</EC-DOC>

IS
  CURSOR c_prosty_alt_codes(cp_code VARCHAR2, cp_code_type VARCHAR2) IS
    SELECT alt_code col
      FROM PROSTY_CODES
    WHERE code = cp_code
      AND code_type = cp_code_type;

  lv2_pdd_object_id VARCHAR2(32);
  lv2_freq_code     VARCHAR2(32);
  li_index          BINARY_INTEGER;
  ld_utc            DATE;
  ld_end_utc        DATE;
  lua_times         Ecdp_Date_Time.Ec_Unique_Daytimes;
  ln_freq_hrs       NUMBER;

BEGIN

  lv2_pdd_object_id := findProductionDayDefinition(p_class_name,p_object_id,p_day);

  ld_utc:= Ecdp_Timestamp.local2utc(p_object_id, getProductionDayStart(p_class_name, p_object_id, p_day));
  ld_end_utc:= Ecdp_Timestamp.local2utc(p_object_id, getProductionDayStart(p_class_name, p_object_id, p_day+1));
  lv2_freq_code := findSubDailyFreq(p_class_name,p_object_id,p_day);

  FOR cur_code IN c_prosty_alt_codes(UPPER(lv2_freq_code),'METER_FREQ') LOOP
    -- assuming 60 minutes is the default
    ln_freq_hrs := TO_NUMBER(Nvl(cur_code.col,60))/60;  -- convert to hour
  END LOOP;

  WHILE ld_utc < ld_end_utc LOOP
    li_index:=lua_times.COUNT+1;
    lua_times(li_index).daytime := Ecdp_Timestamp.utc2local(p_object_id, ld_utc);
    lua_times(li_index).summertime_flag := Ecdp_Date_Time.summertime_flag(ld_utc, NULL, lv2_pdd_object_id);
    ld_utc:=ld_utc + ln_freq_hrs/24;  -- There is always 24 hours in a UTC day
  END LOOP;

  RETURN lua_times;

END getProductionDayDaytimes;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayOffset
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDayOffset(p_class_name VARCHAR2,
                                p_object_id VARCHAR2,
                                p_daytime DATE,
                                p_summer_time VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN ecdp_timestamp.getProductionDayVersion(p_object_id, p_daytime).production_day_offset_hrs;
END getProductionDayOffset;

END;