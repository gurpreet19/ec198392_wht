CREATE OR REPLACE PACKAGE BODY EcBp_Well_Status IS
/****************************************************************
** Package        :  EcBp_Well_Status, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Provides business functions related to well status.
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.01.2006  Dagfinn Nj�
**
** Modification history:
**
** Date         Whom     Change description:
** ------       -----    --------------------------------------
** 13.04.2007   LAU      ECPD-5253: Add INJ_TYPE for IWEL_PERIOD_STATUS
** 22.11.2008   oonnnng  ECPD-6067: Added local month lock checking in checkWellStatusLock function.
** 17.02.2009   oonnnng  ECPD-6067: Add new parameter p_object_id to validatePeriodForLockOverlap() and checkUpdateOfLDOForLock()
**                       in checkWellStatusLock() function.
** 23.08.2016   dhavaalo ECPD-38127-38126- getVolumeUOM and getVolumeUOM function added.
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkWellStatusLock
-- Description    : Checks whether a last dated well status record affects a locked month.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Well.getFacility,
--                  EcDp_Facility.getProductionDayOffset,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      : Supports the tables PWEL_PERIOD_STATUS and IWEL_PERIOD_STATUS
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkWellStatusLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;

lv2_id VARCHAR2(2000);
ln_prod_day_offset NUMBER; -- offset in decimal days
lv2_facility production_facility.object_id%TYPE;
lv2_table_name VARCHAR2(30);
lv2_columns_updated VARCHAR2(1);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);


BEGIN

   -- Get production day offset to use in date test.

   IF p_operation = 'DELETING' THEN

      lv2_facility := EcDp_Well.getFacility(p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2, p_old_lock_columns('DAYTIME').column_data.AccessDate);
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,p_old_lock_columns('DAYTIME').column_data.AccessDate) / 24;
      lv2_table_name := p_old_lock_columns('TABLE_NAME').column_name;
      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

   ELSE

      lv2_facility := EcDp_Well.getFacility(p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2, p_new_lock_columns('DAYTIME').column_data.AccessDate);
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,p_new_lock_columns('DAYTIME').column_data.AccessDate) / 24;
      lv2_table_name := p_new_lock_columns('TABLE_NAME').column_name;
      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

   END IF;

   ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

      IF lv2_table_name = 'PWEL_PERIOD_STATUS' THEN

         ld_new_next_valid := ec_pwel_period_status.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      ELSIF lv2_table_name = 'IWEL_PERIOD_STATUS' THEN

         ld_new_next_valid := ec_iwel_period_status.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           p_new_lock_columns('INJ_TYPE').column_data.AccessVarchar2,
                           p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      END IF;

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid - ln_prod_day_offset, ld_new_next_valid - ln_prod_day_offset, lv2_id, lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      -- get the next valid daytime

      IF lv2_table_name = 'PWEL_PERIOD_STATUS' THEN

         ld_new_next_valid := ec_pwel_period_status.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

         ld_old_next_valid := ec_pwel_period_status.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           p_old_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

         IF ld_new_next_valid = ld_old_current_valid THEN
            ld_new_next_valid := ld_old_next_valid;
         END IF;

          -- Get previous record
          ld_old_prev_valid := ec_pwel_period_status.prev_daytime(
                                      p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                      ld_old_current_valid,
                                      p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      ELSIF lv2_table_name = 'IWEL_PERIOD_STATUS' THEN

         ld_new_next_valid := ec_iwel_period_status.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           p_new_lock_columns('INJ_TYPE').column_data.AccessVarchar2,
                           p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

         ld_old_next_valid := ec_iwel_period_status.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           p_new_lock_columns('INJ_TYPE').column_data.AccessVarchar2,
                           p_old_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

         IF ld_new_next_valid = ld_old_current_valid THEN
            ld_new_next_valid := ld_old_next_valid;
         END IF;

         ld_old_prev_valid := ec_iwel_period_status.prev_daytime(
                                      p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                                      ld_old_current_valid,
                                      p_new_lock_columns('INJ_TYPE').column_data.AccessVarchar2,
                                      p_new_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      END IF;

      ld_new_current_valid := ld_new_current_valid - ln_prod_day_offset;
      ld_old_current_valid := ld_old_current_valid - ln_prod_day_offset;
      ld_new_next_valid := ld_new_next_valid - ln_prod_day_offset;
      ld_old_next_valid := ld_old_next_valid - ln_prod_day_offset;
      ld_old_prev_valid := ld_old_prev_valid - ln_prod_day_offset;

      p_old_lock_columns('DAYTIME').is_checked := 'Y';
      p_old_lock_columns('PRODUCTION_DAY').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                             ld_old_current_valid,
                                             ld_new_next_valid,
                                             ld_old_next_valid,
                                             ld_old_prev_valid,
                                             lv2_columns_updated,
                                             lv2_id,
                                             lv2_n_obj_id);

   ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

      IF lv2_table_name = 'PWEL_PERIOD_STATUS' THEN

         ld_old_next_valid := ec_pwel_period_status.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           p_old_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      ELSIF lv2_table_name = 'IWEL_PERIOD_STATUS' THEN

         ld_old_next_valid := ec_iwel_period_status.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           p_new_lock_columns('INJ_TYPE').column_data.AccessVarchar2,
                           p_old_lock_columns('TIME_SPAN').column_data.AccessVarchar2);

      END IF;

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid - ln_prod_day_offset, ld_old_next_valid - ln_prod_day_offset, lv2_id, lv2_o_obj_id);

   END IF;

END checkWellStatusLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getVolumeUOM                                                          		 --
-- Description    : Get UOM for Volume from Injection type from respective class.                --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
-- Using tables   :  			                                                                 --
-- Using functions: ECDP_UNIT.GetUnitLabel  ,ec_class_attr_presentation.uom_code				 --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Return UOM based on injection type of well.									 --
---------------------------------------------------------------------------------------------------
FUNCTION getVolumeUOM(
    p_inj_type     VARCHAR2)

RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR cur_view_unit(c_uom_meas_type VARCHAR2) IS
SELECT unit
FROM ctrl_uom_setup cus
WHERE cus.measurement_type = c_uom_meas_type
AND cus.view_unit_ind = 'Y';

lv2_uom    VARCHAR2(32);

BEGIN

   IF p_inj_type='GI' THEN
    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'IWEL_DAY_STATUS_GAS', p_attribute_name =>'ALLOC_INJ_VOL' );
   ELSIF p_inj_type = 'WI' THEN
    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'IWEL_DAY_STATUS_WATER', p_attribute_name =>'ALLOC_INJ_VOL' );
   ELSIF p_inj_type = 'SI' THEN
    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'IWEL_DAY_STATUS_STEAM', p_attribute_name =>'ALLOC_INJ_VOL' );
   ELSIF p_inj_type = 'AI' THEN
    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'IWEL_DAY_STATUS_AIR', p_attribute_name =>'INJ_VOL' );
   ELSIF p_inj_type = 'CI' THEN
    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'IWEL_DAY_STATUS_CO2', p_attribute_name =>'ALLOC_INJ_VOL' );
   END IF;

   FOR c_view_unit IN cur_view_unit(lv2_uom) LOOP
       lv2_uom := c_view_unit.unit;
   END LOOP;

   lv2_uom:= ECDP_UNIT.GetUnitLabel(lv2_uom);

RETURN lv2_uom;

END getVolumeUOM;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getConvertVolume                                                      		 --
-- Description    : Convert DB volume to screen unit 							                 --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
-- Using tables   :  			                                                                 --
-- Using functions: ECDP_UNIT.GetUnitLabel  ,ec_class_attr_presentation.uom_code				 --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Convert DB volume to screen unit											 --
---------------------------------------------------------------------------------------------------
FUNCTION getConvertVolume(
   p_inj_vol  NUMBER,
   p_inj_type VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
lv2_uom         VARCHAR2(32);
lv2_uom_screen  VARCHAR2(32);
lv2_uom_db      VARCHAR2(32);
ln_inj_vol		NUMBER;

CURSOR cur_view_unit(c_uom_meas_type VARCHAR2) IS
SELECT unit
FROM ctrl_uom_setup cus
WHERE cus.measurement_type = c_uom_meas_type
AND cus.view_unit_ind = 'Y';

CURSOR cur_db_unit(c_uom_meas_type VARCHAR2) IS
SELECT unit
FROM ctrl_uom_setup cus
WHERE cus.measurement_type = c_uom_meas_type
AND cus.db_unit_ind = 'Y';

BEGIN

   IF p_inj_type='GI' THEN
    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'IWEL_DAY_STATUS_GAS', p_attribute_name =>'ALLOC_INJ_VOL' );
   ELSIF p_inj_type = 'WI' THEN
    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'IWEL_DAY_STATUS_WATER', p_attribute_name =>'ALLOC_INJ_VOL' );
   ELSIF p_inj_type = 'SI' THEN
    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'IWEL_DAY_STATUS_STEAM', p_attribute_name =>'ALLOC_INJ_VOL' );
   ELSIF p_inj_type = 'AI' THEN
    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'IWEL_DAY_STATUS_AIR', p_attribute_name =>'INJ_VOL' );
   ELSIF p_inj_type = 'CI' THEN
    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'IWEL_DAY_STATUS_CO2', p_attribute_name =>'ALLOC_INJ_VOL' );
   END IF;

   FOR c_view_unit IN cur_view_unit(lv2_uom) LOOP
       lv2_uom_screen := c_view_unit.unit;
   END LOOP;

   FOR c_view_unit IN cur_db_unit(lv2_uom) LOOP
       lv2_uom_db := c_view_unit.unit;
   END LOOP;

  IF(lv2_uom_screen=lv2_uom_db) THEN
     ln_inj_vol:=p_inj_vol;
  ELSE
     ln_inj_vol:=ecdp_unit.convertValue(p_inj_vol,lv2_uom_db,lv2_uom_screen,'',2);
  END IF;

RETURN ln_inj_vol;

END getConvertVolume;

END EcBp_Well_Status;