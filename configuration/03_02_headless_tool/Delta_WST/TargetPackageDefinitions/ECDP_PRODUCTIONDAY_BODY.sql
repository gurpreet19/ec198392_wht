CREATE OR REPLACE PACKAGE BODY EcDp_ProductionDay IS
/****************************************************************
** Package        :  EcDp_ProductionDay, body part
**
** $Revision: 1.18.12.1 $
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
**																to add production object id to pass into the function ecdp_date_time.summertime_flag()
** 03-11-2010  farhaann ECPD-15652 Modified findSubDailyFreq: Added condition for WEBO_INTERVAL_VERSION
** 05-08-2012  makkkkam	ECDP-21910 Modified findProductionDayDefinition: Added user exit possibility in package logic
*****************************************************************/

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

BEGIN
  lv2_default_freq_code := '1H';

  IF p_class_name IS NULL OR ec_class.class_type(p_class_name)='INTERFACE' THEN
    lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);
  ELSE
    lv2_class_name := p_class_name;
  END IF;

  lv2_attr_table_name := ec_class_db_mapping.db_object_attribute(lv2_class_name); -- attribute table lookup

  IF lv2_attr_table_name IS NOT NULL THEN
    CASE lv2_attr_table_name
      WHEN 'STRM_VERSION' THEN
        lv2_freq_code := Nvl(ec_strm_version.strm_meter_freq(p_object_id,p_daytime,'<='),lv2_default_freq_code);

      WHEN 'WELL_VERSION' THEN
        lv2_freq_code := Nvl(ec_well_version.well_meter_freq(p_object_id,p_daytime,'<='),lv2_default_freq_code);

	  WHEN 'WEBO_INTERVAL_VERSION' THEN
        lv2_freq_code := Nvl(ec_webo_interval_version.wbi_meter_freq(p_object_id,p_daytime,'<='),lv2_default_freq_code);

      WHEN 'SEPA_VERSION' THEN
        lv2_freq_code := Nvl(ec_sepa_version.sepa_meter_freq(p_object_id,p_daytime,'<='),lv2_default_freq_code);

      WHEN 'CHEM_TANK_VERSION' THEN
        lv2_freq_code := Nvl(ec_chem_tank_version.tank_meter_freq(p_object_id,p_daytime,'<='),lv2_default_freq_code);

      WHEN 'TANK_VERSION' THEN
        lv2_freq_code := Nvl(ec_tank_version.tank_meter_freq(p_object_id,p_daytime,'<='),lv2_default_freq_code);

      WHEN 'FLWL_VERSION' THEN
        lv2_freq_code := Nvl(ec_flwl_version.flwl_meter_freq(p_object_id,p_daytime,'<='),lv2_default_freq_code);

      WHEN 'PIPE_VERSION' THEN
        lv2_freq_code := Nvl(ec_pipe_version.pipe_meter_freq(p_object_id,p_daytime,'<='),lv2_default_freq_code);

      WHEN 'EQPM_VERSION' THEN
        lv2_freq_code := Nvl(ec_eqpm_version.eqpm_meter_freq(p_object_id,p_daytime,'<='),lv2_default_freq_code);

      ELSE
        lv2_freq_code := lv2_default_freq_code;

    END CASE;

  ELSE
    lv2_freq_code := lv2_default_freq_code;
  END IF;

  RETURN lv2_freq_code;
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
  lv2_pd_object_id    VARCHAR2(32) NULL;
  lv2_class_name      VARCHAR2(32) NULL;
  lv2_fcty_class_id   VARCHAR2(32) NULL;
  lv2_fcty_class_name VARCHAR2(32) NULL;

BEGIN

  IF p_object_id IS NULL THEN
    lv2_pd_object_id := Ecdp_Date_Time.getDefaultProdDayDefinition(p_daytime);
  END IF;

  IF p_class_name IS NULL THEN
    lv2_class_name := Ecdp_Objects.GetObjClassName(p_object_id);
  ELSE
    lv2_class_name := p_class_name;
  END IF;

  CASE UPPER(lv2_class_name)
    WHEN 'FACILITY' THEN
      lv2_pd_object_id := ec_fcty_version.production_day_id(p_object_id,p_daytime,'<=');

    WHEN 'FCTY_CLASS_1' THEN
      lv2_pd_object_id := ec_fcty_version.production_day_id(p_object_id,p_daytime,'<=');

    WHEN 'FCTY_CLASS_2' THEN
      lv2_pd_object_id := ec_fcty_version.production_day_id(p_object_id,p_daytime,'<=');

    WHEN 'FLOWLINE' THEN
      lv2_pd_object_id := ec_flwl_version.production_day_id(p_object_id,p_daytime,'<=');

    WHEN 'PIPELINE' THEN
      lv2_pd_object_id := ec_pipe_version.production_day_id(p_object_id,p_daytime,'<=');

    WHEN 'PRODSEPARATOR' THEN
      lv2_pd_object_id := ec_sepa_version.production_day_id(p_object_id,p_daytime,'<=');

    WHEN 'TESTSEPARATOR' THEN
      lv2_pd_object_id := ec_sepa_version.production_day_id(p_object_id,p_daytime,'<=');

    WHEN 'SEPARATOR' THEN
      lv2_pd_object_id := ec_sepa_version.production_day_id(p_object_id,p_daytime,'<=');

    WHEN 'STREAM' THEN
      lv2_pd_object_id := ec_strm_version.production_day_id(p_object_id,p_daytime,'<=');

    WHEN 'EQUIPMENT' THEN
      lv2_pd_object_id := ec_eqpm_version.production_day_id(p_object_id,p_daytime,'<=');

	ELSE
	  lv2_pd_object_id := ue_ProductionDay.findProductionDayDefinition(p_class_name, p_object_id, p_daytime);

  END CASE;

  IF lv2_pd_object_id IS NULL THEN
    -- lookup at the object's fcty_class
    lv2_fcty_class_id := ecdp_facility.GetParentFacility(p_object_id,p_daytime,lv2_class_name);
    IF lv2_fcty_class_id IS NULL THEN
      lv2_pd_object_id := Ecdp_Date_Time.getDefaultProdDayDefinition(p_daytime);
    ELSE
      -- need to know which fcty_class are we having now
      lv2_fcty_class_name := ec_production_facility.class_name(lv2_fcty_class_id);

      -- found fcty_class_id and name, pass back(recursively) to this function
      lv2_pd_object_id := findProductionDayDefinition(lv2_fcty_class_name,lv2_fcty_class_id,p_daytime);

      -- last option
      IF lv2_pd_object_id IS NULL THEN
        lv2_pd_object_id := Ecdp_Date_Time.getDefaultProdDayDefinition(p_daytime);
      END IF;

    END IF;

  END IF;

  RETURN lv2_pd_object_id;

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
  lv2_pdd_object_id   VARCHAR2(32);
  lv2_summertime_flag VARCHAR2(1);
  ld_production_day   DATE;
  lv2_class_name class.class_name%TYPE;

BEGIN
  IF p_class_name IS NULL THEN
       lv2_class_name := EcDp_Objects.GetObjClassName(p_object_id);
  ELSE
    lv2_class_name := p_class_name;
  END IF;

  lv2_pdd_object_id := findProductionDayDefinition(lv2_class_name,p_object_id,p_daytime);

  IF p_summertime_flag IS NULL THEN
    lv2_summertime_flag := Ecdp_Date_Time.summertime_flag(p_daytime, NULL, lv2_pdd_object_id);
  ELSE
    lv2_summertime_flag := p_summertime_flag;
  END IF;

  ld_production_day := ecdp_date_time.getProductionDay(lv2_pdd_object_id,p_daytime,lv2_summertime_flag);

  RETURN TRUNC(ld_production_day);

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
  lv2_pdd_object_id VARCHAR2(32);

BEGIN
  lv2_pdd_object_id := findProductionDayDefinition(p_class_name,p_object_id,p_day);

  RETURN Ecdp_Date_Time.getProductionDayStartTime(lv2_pdd_object_id,p_day);

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
  lv2_pdd_object_id VARCHAR2(32);
  lecd  Ecdp_Date_Time.Ec_Unique_Daytime;

BEGIN
   lecd := getProductionDayStartTime(p_class_name,p_object_id,p_day);

  RETURN lecd.daytime;

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
  lv2_pdd_object_id VARCHAR2(32);

BEGIN

  lv2_pdd_object_id := findProductionDayDefinition(p_class_name,p_object_id,p_day);
  RETURN Ecdp_Date_Time.getProductionDayFraction(lv2_pdd_object_id,p_day,p_from_daytime,p_from_summer_time,p_to_daytime,p_to_summer_time);

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
  lv2_pdd_object_id VARCHAR2(32);
  lv2_freq_code     VARCHAR2(32);

BEGIN

  lv2_pdd_object_id := findProductionDayDefinition(p_class_name,p_object_id,p_day);
  lv2_freq_code := findSubDailyFreq(p_class_name,p_object_id,p_day);

  RETURN Ecdp_Date_Time.getProductionDayDaytimes(lv2_pdd_object_id,lv2_freq_code,p_day);

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
  lv2_pdd_object_id  VARCHAR2(32);
  lv2_pdd_offset     VARCHAR2(32);
  ln_day_offset      NUMBER;

BEGIN

  lv2_pdd_object_id := findProductionDayDefinition(p_class_name,p_object_id,p_daytime);

  RETURN ecdp_date_time.getProductionDayOffset(lv2_pdd_object_id,p_daytime,p_summer_time);


END getProductionDayOffset;

END;