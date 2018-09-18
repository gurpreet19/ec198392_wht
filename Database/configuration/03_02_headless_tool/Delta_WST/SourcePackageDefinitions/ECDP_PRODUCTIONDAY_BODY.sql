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
**																to add production object id to pass into the function ecdp_date_time.summertime_flag()
** 03-11-2010  farhaann ECPD-15652 Modified findSubDailyFreq: Added condition for WEBO_INTERVAL_VERSION
** 05-08-2012  makkkkam	ECDP-19593 Modified findProductionDayDefinition: Added user exit possibility in package logic
** 27-06-2014  abdulmaw	ECDP-26928 Modified findProductionDayDefinition: Update EQPM to support merging all equipment into one class
** 30-07-2014  leongwen	ECDP-28063 Modified findProductionDayDefinition: Added check on classname for TEST_DEVICE, and return the production_day_id from ec_test_device_version instead.
*****************************************************************/

TYPE Ec_Prod_Day_buffer IS RECORD (from_daytime   DATE,
                                   to_daytime     DATE,
                                   class_name     VARCHAR2(32),
                                   object_id      VARCHAR2(32),
                                   pday_object_id VARCHAR2(32)
                                   );

lr_Ec_Prod_Day_buffer Ec_Prod_Day_buffer;

CURSOR c_productionday(cpdd_object_id VARCHAR2, cp_daytime DATE) IS
  SELECT offset
    FROM  production_day_version pv
    WHERE   nvl(cp_daytime,pv.daytime) >= pv.daytime
    AND     nvl(cp_daytime,pv.daytime) < Nvl(pv.end_date,cp_daytime+1)
    AND   (object_id = cpdd_object_id OR ( cpdd_object_id IS NULL AND pv.default_ind = 'Y'))
    ORDER BY pv.object_id ;

CURSOR c_default_productionday(cp_daytime DATE) IS
  SELECT  pv.object_id
  FROM    production_day_version pv
  WHERE   nvl(cp_daytime,pv.daytime) >= pv.daytime
  AND     nvl(cp_daytime,pv.daytime) < Nvl(pv.end_date,cp_daytime+1)
  AND     pv.default_ind = 'Y'
  ORDER BY pv.object_id ;

PROCEDURE dumpProdDayBuffer IS

BEGIN
  ECDP_DYNSQL.WRITETEMPTEXT('DUMPPRODDAY', 'from_daytime: ' || to_char(lr_Ec_Prod_Day_buffer.from_daytime, 'yyyy-mm-dd hh24:mi:ss'));
  ECDP_DYNSQL.WRITETEMPTEXT('DUMPPRODDAY', 'to_daytime: ' || to_char(lr_Ec_Prod_Day_buffer.to_daytime, 'yyyy-mm-dd hh24:mi:ss'));
  ECDP_DYNSQL.WRITETEMPTEXT('DUMPPRODDAY', 'class_name: ' || lr_Ec_Prod_Day_buffer.class_name);
  ECDP_DYNSQL.WRITETEMPTEXT('DUMPPRODDAY', 'object_id: ' || lr_Ec_Prod_Day_buffer.object_id);
  ECDP_DYNSQL.WRITETEMPTEXT('DUMPPRODDAY', 'actual class_name: ' || ecdp_objects.getObjClassName(lr_Ec_Prod_Day_buffer.object_id));
  ECDP_DYNSQL.WRITETEMPTEXT('DUMPPRODDAY', 'pday_object_id: ' || lr_Ec_Prod_Day_buffer.pday_object_id);

END dumpProdDayBuffer;

PROCEDURE flush_buffer IS

BEGIN
  lr_Ec_Prod_Day_buffer.from_daytime := NULL;
  lr_Ec_Prod_Day_buffer.to_daytime := NULL;
  lr_Ec_Prod_Day_buffer.class_name := NULL;
  lr_Ec_Prod_Day_buffer.object_id  := NULL;
  lr_Ec_Prod_Day_buffer.pday_object_id := NULL;

END flush_buffer;

/*
* The original logic for findProductionDayDefinition getting the pday_object_id depending on class_name and object_id on the given date.
* The cache keep the existing version's row based on the given class_name.
* Object_id can be NULL. In this case, default production day is returned. This cache only handles non-NULL object_id.

*/
PROCEDURE loadProdDayBuffer (p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) IS

CURSOR c_default_production_day (cp_daytime DATE) IS
  SELECT pv.object_id, daytime, end_date
    FROM production_day_version pv
   WHERE cp_daytime >= pv.daytime
     AND cp_daytime < Nvl(pv.end_date, cp_daytime + 1)
     AND pv.default_ind = 'Y'
   ORDER BY pv.object_id; -- To make it deterministic in case of error in config (more than 1 default)

lv_facility_id VARCHAR2(32);
lv_class_name  VARCHAR2(100);

lb_use_default BOOLEAN := FALSE;

lr_fcty_version         fcty_version%ROWTYPE;
lr_flwl_version         flwl_version%ROWTYPE;
lr_pipe_version         pipe_version%ROWTYPE;
lr_sepa_version         sepa_version%ROWTYPE;
lr_strm_version         strm_version%ROWTYPE;
lr_eqpm_version         eqpm_version%ROWTYPE;
lr_well_version         well_version%ROWTYPE;
lr_stor_version         stor_version%ROWTYPE;
lr_tank_version         tank_version%ROWTYPE;
lr_chem_tank_version    chem_tank_version%ROWTYPE;
lr_well_hookup_version  well_hookup_version%ROWTYPE;
lr_test_device_version  test_device_version%ROWTYPE;

lr_contract_version     contract_version%ROWTYPE;
lr_meter_version        meter_version%ROWTYPE;

BEGIN
  flush_buffer;

  lv_class_name := Ecdp_objects.getObjClassName(p_object_id);

  -- list of classes that uses parent facility from ecdp_facility. The versions are guaranteed to be the same or less than parent facility
  CASE lv_class_name
    WHEN 'WELL' THEN
       --lv_facility_id := Nvl(ec_well_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_well_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
       lr_well_version := ec_well_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
       lv_facility_id := Nvl(lr_well_version.op_fcty_class_1_id, lr_well_version.op_fcty_class_2_id);

    WHEN 'STORAGE' THEN
      -- lv_facility_id := Nvl(ec_stor_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_stor_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
      lr_stor_version := ec_stor_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
      lv_facility_id := Nvl(lr_stor_version.op_fcty_class_1_id, lr_stor_version.op_fcty_class_2_id);

    WHEN 'TANK' THEN
      -- lv_facility_id := Nvl(ec_tank_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_tank_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
      lr_tank_version := ec_tank_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
      lv_facility_id := Nvl(lr_tank_version.op_fcty_class_1_id, lr_tank_version.op_fcty_class_2_id);

    WHEN 'WELL_HOOKUP' THEN
      -- lv_facility_id := Nvl(ec_well_hookup_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_well_hookup_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
      lr_well_hookup_version := ec_well_hookup_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
      lv_facility_id := Nvl(lr_well_hookup_version.op_fcty_class_1_id, lr_well_hookup_version.op_fcty_class_2_id);

    WHEN 'CHEM_TANK' THEN
      -- lv_facility_id := Nvl(ec_chem_tank_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_chem_tank_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
      lr_chem_tank_version := ec_chem_tank_version.row_by_rel_operator(p_object_id,p_daytime, '<=');
      lv_facility_id := Nvl(lr_chem_tank_version.op_fcty_class_1_id, lr_chem_tank_version.op_fcty_class_2_id);
    ELSE
      NULL;
  END CASE;

  IF lv_facility_id IS NOT NULL
      OR lv_class_name IN ('FACILITY', 'FCTY_CLASS_1', 'FCTY_CLASS_2') THEN

    lr_fcty_version := ec_fcty_version.row_by_rel_operator(Nvl(lv_facility_id, p_object_id), p_daytime, '<=');
    lr_Ec_Prod_Day_buffer.from_daytime    := lr_fcty_version.daytime;
    lr_Ec_Prod_Day_buffer.to_daytime      := Nvl(lr_fcty_version.end_date, EcDp_System_Constants.FUTURE_DATE);
    lr_Ec_Prod_Day_buffer.class_name      := lv_class_name;
    lr_Ec_Prod_Day_buffer.object_id       := p_object_id;

    IF lr_fcty_version.production_day_id IS NULL THEN
      lb_use_default := TRUE;
    ELSE
      lr_Ec_Prod_Day_buffer.pday_object_id  := lr_fcty_version.production_day_id;
    END IF;
  END IF;

  CASE
    WHEN lv_facility_id IS NOT NULL THEN
      -- already covered
      NULL;
    WHEN lv_class_name IN ('FACILITY', 'FCTY_CLASS_1', 'FCTY_CLASS_2') THEN
      -- already covered
      NULL;
    WHEN lv_class_name = 'FLOWLINE' THEN
      lr_flwl_version := ec_flwl_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
      lr_Ec_Prod_Day_buffer.from_daytime    := lr_flwl_version.daytime;
      lr_Ec_Prod_Day_buffer.to_daytime      := Nvl(lr_flwl_version.end_date, EcDp_System_Constants.FUTURE_DATE);
      lr_Ec_Prod_Day_buffer.class_name      := lv_class_name;
      lr_Ec_Prod_Day_buffer.object_id       := p_object_id;

      IF lr_flwl_version.production_day_id IS NULL THEN
        lb_use_default := TRUE;
      ELSE
        lr_Ec_Prod_Day_buffer.pday_object_id  := lr_flwl_version.production_day_id;

      END IF;
    WHEN lv_class_name = 'PIPELINE' THEN
      lr_pipe_version := ec_pipe_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
      lr_Ec_Prod_Day_buffer.from_daytime    := lr_pipe_version.daytime;
      lr_Ec_Prod_Day_buffer.to_daytime      := Nvl(lr_pipe_version.end_date, EcDp_System_Constants.FUTURE_DATE);
      lr_Ec_Prod_Day_buffer.class_name      := lv_class_name;
      lr_Ec_Prod_Day_buffer.object_id       := p_object_id;

      IF lr_pipe_version.production_day_id IS NULL THEN
        lb_use_default := TRUE;
      ELSE
        lr_Ec_Prod_Day_buffer.pday_object_id  := lr_pipe_version.production_day_id;

      END IF;
    WHEN lv_class_name IN ('PRODSEPARATOR', 'TESTSEPARATOR', 'SEPARATOR') THEN
      lr_sepa_version := ec_sepa_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
      lr_Ec_Prod_Day_buffer.from_daytime    := lr_sepa_version.daytime;
      lr_Ec_Prod_Day_buffer.to_daytime      := Nvl(lr_sepa_version.end_date, EcDp_System_Constants.FUTURE_DATE);
      lr_Ec_Prod_Day_buffer.class_name      := lv_class_name;
      lr_Ec_Prod_Day_buffer.object_id       := p_object_id;

      IF lr_sepa_version.production_day_id IS NULL THEN
        lb_use_default := TRUE;
      ELSE
        lr_Ec_Prod_Day_buffer.pday_object_id  := lr_sepa_version.production_day_id;

      END IF;
    WHEN lv_class_name = 'STREAM' THEN
      lr_strm_version := ec_strm_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
      lr_Ec_Prod_Day_buffer.from_daytime    := lr_strm_version.daytime;
      lr_Ec_Prod_Day_buffer.to_daytime      := Nvl(lr_strm_version.end_date, EcDp_System_Constants.FUTURE_DATE);
      lr_Ec_Prod_Day_buffer.class_name      := lv_class_name;
      lr_Ec_Prod_Day_buffer.object_id       := p_object_id;

      IF lr_strm_version.production_day_id IS NULL THEN
        lb_use_default := TRUE;
      ELSE
        lr_Ec_Prod_Day_buffer.pday_object_id  := lr_strm_version.production_day_id;
      END IF;
    WHEN lv_class_name = 'EQPM' THEN
      lr_eqpm_version := ec_eqpm_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
      lr_Ec_Prod_Day_buffer.from_daytime    := lr_eqpm_version.daytime;
      lr_Ec_Prod_Day_buffer.to_daytime      := Nvl(lr_eqpm_version.end_date, EcDp_System_Constants.FUTURE_DATE);
      lr_Ec_Prod_Day_buffer.class_name      := lv_class_name;
      lr_Ec_Prod_Day_buffer.object_id       := p_object_id;

      IF lr_eqpm_version.production_day_id IS NULL THEN
        lb_use_default := TRUE;
      ELSE
        lr_Ec_Prod_Day_buffer.pday_object_id  := lr_eqpm_version.production_day_id;
      END IF;
    WHEN lv_class_name = 'TEST_DEVICE' THEN
      lr_test_device_version := ec_test_device_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
      lr_Ec_Prod_Day_buffer.from_daytime    := lr_test_device_version.daytime;
      lr_Ec_Prod_Day_buffer.to_daytime      := Nvl(lr_test_device_version.end_date, EcDp_System_Constants.FUTURE_DATE);
      lr_Ec_Prod_Day_buffer.class_name      := lv_class_name;
      lr_Ec_Prod_Day_buffer.object_id       := p_object_id;

      IF lr_test_device_version.production_day_id IS NULL THEN
        lb_use_default := TRUE;
      ELSE
        lr_Ec_Prod_Day_buffer.pday_object_id  := lr_test_device_version.production_day_id;
      END IF;

    WHEN lv_class_name IN ('CONTRACT', 'TRAN_CONTRACT') THEN
      lr_contract_version := ec_contract_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
      lr_Ec_Prod_Day_buffer.from_daytime    := lr_contract_version.daytime;
      lr_Ec_Prod_Day_buffer.to_daytime      := Nvl(lr_contract_version.end_date, EcDp_System_Constants.FUTURE_DATE);
      lr_Ec_Prod_Day_buffer.class_name      := lv_class_name;
      lr_Ec_Prod_Day_buffer.object_id       := p_object_id;

      IF lr_contract_version.production_day_id IS NULL THEN
        lb_use_default := TRUE;
      ELSE
        lr_Ec_Prod_Day_buffer.pday_object_id := lr_contract_version.production_day_id;
      END IF;
    WHEN lv_class_name = 'METER' THEN
      lr_meter_version := ec_meter_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
      lr_Ec_Prod_Day_buffer.from_daytime    := lr_meter_version.daytime;
      lr_Ec_Prod_Day_buffer.to_daytime      := Nvl(lr_meter_version.end_date, EcDp_System_Constants.FUTURE_DATE);
      lr_Ec_Prod_Day_buffer.class_name      := lv_class_name;
      lr_Ec_Prod_Day_buffer.object_id       := p_object_id;

      IF lr_meter_version.production_day_id IS NULL THEN
        lb_use_default := TRUE;
      ELSE
        lr_Ec_Prod_Day_buffer.pday_object_id := lr_meter_version.production_day_id;
      END IF;
    WHEN lv_class_name IN ('CONTRACT_CAPACITY', 'DELIVERY_POINT', 'NOMINATION_POINT') THEN
      lb_use_default := TRUE;
    ELSE
      lb_use_default := TRUE;
  END CASE;

  IF lb_use_default THEN
    -- There are reasons why we get here: requires parent facility's object_id,
    -- fallback behavior
    CASE lv_class_name
      WHEN 'FLOWLINE' THEN
        -- lv_facility_id := Nvl(ec_flwl_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_flwl_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
        lr_flwl_version := ec_flwl_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
        lv_facility_id := Nvl(lr_flwl_version.op_fcty_class_1_id, lr_flwl_version.op_fcty_class_2_id);

      WHEN 'STREAM' THEN
        -- lv_facility_id := Nvl(ec_strm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_strm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
        lr_strm_version := ec_strm_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
        lv_facility_id := Nvl(lr_strm_version.op_fcty_class_1_id, lr_strm_version.op_fcty_class_2_id);

      WHEN 'EQPM' THEN
        -- lv_facility_id := Nvl(ec_eqpm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_eqpm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
        lr_eqpm_version := ec_eqpm_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
        lv_facility_id := Nvl(lr_eqpm_version.op_fcty_class_1_id, lr_eqpm_version.op_fcty_class_2_id);

      WHEN 'TEST_DEVICE' THEN
        -- lv_facility_id := Nvl(ec_test_device_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_test_device_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
        lr_test_device_version := ec_test_device_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
        lv_facility_id := Nvl(lr_test_device_version.op_fcty_class_1_id, lr_test_device_version.op_fcty_class_2_id);

      WHEN 'TESTSEPARATOR' THEN
        -- lv_facility_id := Nvl(ec_sepa_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_sepa_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
        lr_sepa_version := ec_sepa_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
        lv_facility_id := Nvl(lr_sepa_version.op_fcty_class_1_id, lr_sepa_version.op_fcty_class_2_id);

      WHEN 'PRODSEPARATOR' THEN
        -- lv_facility_id := Nvl(ec_sepa_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_sepa_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
        lr_sepa_version := ec_sepa_version.row_by_rel_operator(p_object_id, p_daytime, '<=');
        lv_facility_id := Nvl(lr_sepa_version.op_fcty_class_1_id, lr_sepa_version.op_fcty_class_2_id);
      ELSE
        -- control case
        lv_facility_id := NULL;
    END CASE;

    IF lv_facility_id IS NOT NULL THEN
        lr_fcty_version := ec_fcty_version.row_by_rel_operator(lv_facility_id, p_daytime, '<=');
        IF lr_fcty_version.production_day_id IS NOT NULL THEN
          lr_Ec_Prod_Day_buffer.pday_object_id := lr_fcty_version.production_day_id;
        END IF;
    END IF;

    -- or production_day_id is not set in the row,
    -- or class_name is not in the list
    IF lr_Ec_Prod_Day_buffer.pday_object_id IS NULL THEN
      FOR one IN c_default_production_day(p_daytime) LOOP
        lr_Ec_Prod_Day_buffer.pday_object_id := one.object_id;

        IF lr_Ec_Prod_Day_buffer.from_daytime IS NULL THEN
          lr_Ec_Prod_Day_buffer.from_daytime := one.daytime;
          lr_Ec_Prod_Day_buffer.to_daytime := Nvl(one.end_date, EcDp_System_Constants.FUTURE_DATE);
          -- copy class_name and object_id as is, even if class name is NULL
          lr_Ec_Prod_Day_buffer.class_name := p_class_name;
          lr_Ec_Prod_Day_buffer.object_id  := p_object_id;

        END IF;

    END LOOP;
    END IF;

  END IF;

END loadProdDayBuffer;

FUNCTION getTZoffsetInDays(p_time_zone_offset VARCHAR2) RETURN NUMBER
IS
lv_prefix VARCHAR2(1);
ln_hour NUMBER;
ln_min NUMBER;
ln_result NUMBER;

BEGIN

   lv_prefix := substr(p_time_zone_offset,1,1);
   IF  lv_prefix = '-' THEN -- Negative number
      ln_hour := to_number(substr(p_time_zone_offset,2,2));
      ln_min := to_number(substr(p_time_zone_offset,5,2))/60;
      ln_result := (ln_hour + ln_min) * (-1);
   ELSIF lv_prefix = '+' THEN -- Positive number
      ln_hour := to_number(substr(p_time_zone_offset,2,2));
      ln_min := to_number(substr(p_time_zone_offset,5,2))/60;
      ln_result := (ln_hour + ln_min);
   ELSE -- Positive number without prefix
      ln_hour := to_number(substr(p_time_zone_offset,1,2));
      ln_min := to_number(substr(p_time_zone_offset,4,2))/60;
      ln_result := (ln_hour + ln_min);
   END IF;

   RETURN ln_result/24;

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

  IF p_class_name = 'PRODUCTION_DAY' AND p_object_id IS NOT NULL THEN
    RETURN p_object_id;
  END IF;

  IF p_object_id IS NULL THEN
    FOR curPD IN c_default_productionday(p_daytime) LOOP
      lv2_pd_object_id := curPD.object_id;
    END LOOP;
  ELSE
    -- compare only object_id
    IF lr_Ec_Prod_Day_buffer.object_id = p_object_id
        AND lr_Ec_Prod_Day_buffer.from_daytime <= p_daytime
        AND lr_Ec_Prod_Day_buffer.to_daytime > p_daytime THEN
      NULL;
    ELSE
      loadProdDayBuffer(p_class_name, p_object_id, p_daytime);
    END IF;
    lv2_pd_object_id := lr_Ec_Prod_Day_buffer.pday_object_id;
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
  ld_utc_date DATE;
BEGIN
  ld_utc_date := Ecdp_Timestamp.local2utc(p_class_name, p_object_id, p_daytime);
  IF ld_utc_date IS NULL THEN
    -- The inserted date is invalid date. Not supposed to get here but make it works anyway.
    ld_utc_date := Ecdp_Timestamp.local2utc(p_class_name, p_object_id, p_daytime + 1/24);
  END IF;
  RETURN Ecdp_Timestamp.getProductionDay(p_class_name, p_object_id, ld_utc_date);

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

  lv2_pdd_object_id production_day_version.object_id%TYPE;
  lv2_offset        production_day_version.OFFSET%TYPE;

BEGIN
  lv2_pdd_object_id := findProductionDayDefinition(p_class_name,p_object_id,p_day);

  FOR one IN c_productionday(lv2_pdd_object_id, p_day) LOOP
    lv2_offset := one.offset;
  END LOOP;

  RETURN TRUNC(p_day) + getTZoffsetInDays(lv2_offset);

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
  ld_day_start_utc := Ecdp_Timestamp.local2utc(p_class_name, p_object_id, getProductionDayStart(p_class_name, p_object_id, p_day));
  ld_day_end_utc   := Ecdp_Timestamp.local2utc(p_class_name, p_object_id, getProductionDayStart(p_class_name, p_object_id, p_day + 1));

  IF p_from_daytime IS NULL THEN
    ld_from_utc := ld_day_start_utc;
  ELSE
    ld_from_utc := Ecdp_Timestamp.local2utc(p_class_name, p_object_id, p_from_daytime);
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
    ld_to_utc := Ecdp_Timestamp.local2utc(p_class_name, p_object_id, p_to_daytime);
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

  ld_utc:= Ecdp_Timestamp.local2utc(p_class_name, p_object_id, getProductionDayStart(p_class_name, p_object_id, p_day));
  ld_end_utc:= Ecdp_Timestamp.local2utc(p_class_name, p_object_id, getProductionDayStart(p_class_name, p_object_id, p_day+1));
  lv2_freq_code := findSubDailyFreq(p_class_name,p_object_id,p_day);

  FOR cur_code IN c_prosty_alt_codes(UPPER(lv2_freq_code),'METER_FREQ') LOOP
    -- assuming 60 minutes is the default
    ln_freq_hrs := TO_NUMBER(Nvl(cur_code.col,60))/60;  -- convert to hour
  END LOOP;

  WHILE ld_utc < ld_end_utc LOOP
    li_index:=lua_times.COUNT+1;
    lua_times(li_index).daytime := Ecdp_Timestamp.utc2local(p_class_name, p_object_id, ld_utc);
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
  lv2_pdd_object_id production_day_version.object_id%TYPE;
  lv2_offset        production_day_version.OFFSET%TYPE;

BEGIN
  lv2_pdd_object_id := findProductionDayDefinition(p_class_name,p_object_id,p_daytime);

  FOR one IN c_productionday(lv2_pdd_object_id, p_daytime) LOOP
    lv2_offset := one.offset;
  END LOOP;

  RETURN getTZoffsetInDays(lv2_offset) * 24;


END getProductionDayOffset;

END;