CREATE OR REPLACE PACKAGE BODY EcDp_ContractDay IS
/****************************************************************
** Package        :  EcDp_ProductionDay, header part
**
** $Revision: 1.11 $
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
** 21-07-2009 leongwen ECPD-11578 support multiple timezones
**																to add production object id to pass into the function ecdp_date_time.summertime_flag()
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
--</EC-DOC>
IS
  lv2_freq_code         VARCHAR2(32);
  lv2_default_freq_code VARCHAR2(32);

BEGIN
  --should for now be hard-coded to return '1H'
  lv2_default_freq_code := '1H';

  RETURN lv2_default_freq_code;

END findSubDailyFreq;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findContractDayDefinition
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
FUNCTION findContractDayDefinition(p_class_name VARCHAR2, p_object_id  VARCHAR2, p_daytime  DATE)

RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_pd_object_id  VARCHAR2(32);
  lv2_class_name    VARCHAR2(32);

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
    WHEN 'CONTRACT' THEN
      lv2_pd_object_id := Nvl(ec_contract_version.production_day_id(p_object_id,p_daytime,'<='),Ecdp_Date_Time.getDefaultProdDayDefinition(p_daytime));

    WHEN 'TRAN_CONTRACT' THEN
      lv2_pd_object_id := Nvl(ec_contract_version.production_day_id(p_object_id,p_daytime,'<='),Ecdp_Date_Time.getDefaultProdDayDefinition(p_daytime));

    ELSE
      lv2_pd_object_id := Ecdp_Date_Time.getDefaultProdDayDefinition(p_daytime);

  END CASE;

  RETURN lv2_pd_object_id;

END findContractDayDefinition;

FUNCTION findProductionDayDefinition(p_class_name VARCHAR2, p_object_id  VARCHAR2, p_daytime  DATE)
RETURN VARCHAR2
IS

BEGIN
  RETURN findContractDayDefinition(p_class_name, p_object_id, p_daytime);
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

BEGIN
  lv2_pdd_object_id := findContractDayDefinition(p_class_name,p_object_id,p_daytime);

  IF p_summertime_flag IS NULL THEN
    lv2_summertime_flag := Ecdp_Date_Time.summertime_flag(p_daytime, NULL, lv2_pdd_object_id);
  ELSE
    lv2_summertime_flag := p_summertime_flag;
  END IF;

  ld_production_day := Ecdp_Date_Time.getProductionDay(lv2_pdd_object_id,p_daytime,lv2_summertime_flag);

  RETURN TRUNC(ld_production_day);

END getProductionDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayStartTime
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
FUNCTION getProductionDayStartTime(p_class_name VARCHAR2,
                                   p_object_id  VARCHAR2,
                                   p_day        DATE
                                   )
RETURN Ecdp_Date_Time.Ec_Unique_Daytime
--</EC-DOC>

IS
  lv2_pdd_object_id VARCHAR2(32);

BEGIN
  lv2_pdd_object_id := findContractDayDefinition(p_class_name,p_object_id,p_day);

  RETURN Ecdp_Date_Time.getProductionDayStartTime(lv2_pdd_object_id,p_day);

END getProductionDayStartTime;


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

  lv2_pdd_object_id := findContractDayDefinition(p_class_name,p_object_id,p_day);
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

  lv2_pdd_object_id := findContractDayDefinition(p_class_name,p_object_id,p_day);
  lv2_freq_code := findSubDailyFreq(p_class_name,p_object_id,p_day);

  RETURN Ecdp_Date_Time.getProductionDayDaytimes(lv2_pdd_object_id,lv2_freq_code,p_day);

END getProductionDayDaytimes;


FUNCTION getProductionDayStart(p_class_name VARCHAR2, p_object_id  VARCHAR2, p_day  DATE)
RETURN DATE

IS

  ld  EcDp_Date_Time.EC_unique_daytime;

BEGIN

  ld := getProductionDayStartTime(p_class_name, p_object_id, p_day);
  RETURN ld.daytime;

END;



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
FUNCTION getProductionDayOffset(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
  lv2_pdd_object_id  VARCHAR2(32);
  lv2_pdd_offset     VARCHAR2(32);
  ln_day_offset      NUMBER;

BEGIN
  lv2_pdd_object_id := findContractDayDefinition(p_class_name,p_object_id,p_daytime);
  lv2_pdd_offset := ec_production_day_version.offset(lv2_pdd_object_id,p_daytime,'<=');

  IF lv2_pdd_offset IS NULL THEN
    ln_day_offset := 0;
  ELSE

    IF(SUBSTR(lv2_pdd_offset,1,1)= '-') THEN

     lv2_pdd_offset := TO_CHAR(TO_DATE(SUBSTR(lv2_pdd_offset,2,5),'HH24:MI'),'HH24:MI'); -- parse it
     ln_day_offset := (TO_NUMBER(SUBSTR(lv2_pdd_offset,1,2)) + TO_NUMBER(SUBSTR(lv2_pdd_offset,4,2))/60)* -1;

    ELSE
     lv2_pdd_offset := TO_CHAR(TO_DATE(lv2_pdd_offset,'HH24:MI'),'HH24:MI'); -- parse it
     ln_day_offset := TO_NUMBER(SUBSTR(lv2_pdd_offset,1,2)) + TO_NUMBER(SUBSTR(lv2_pdd_offset,4,2))/60;

    END IF;

  END IF;

  RETURN ln_day_offset;

END;


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
  lv2_pdd_object_id := findContractDayDefinition(p_class_name,p_object_id,p_daytime);
  lv2_freq_code := findSubDailyFreq(p_class_name,p_object_id,p_daytime);

  IF p_summertime_flag IS NULL THEN
    lv2_summertime_flag := Ecdp_Date_Time.summertime_flag(p_daytime, NULL, lv2_pdd_object_id);
  ELSE
    lv2_summertime_flag := p_summertime_flag;
  END IF;

  Ecdp_Date_Time.validateDaytimeVsFreq(lv2_pdd_object_id,lv2_freq_code,p_daytime,lv2_summertime_flag);

END validateDaytimeVsFreq;

END;