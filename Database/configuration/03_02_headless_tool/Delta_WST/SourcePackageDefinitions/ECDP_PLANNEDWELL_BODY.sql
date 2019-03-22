CREATE OR REPLACE PACKAGE BODY EcDp_PlannedWell IS
/****************************************************************
** Package        :  EcDp_PlannedWell, body part
**
** $Revision: 1.0 $
**
** Purpose        :  perform operation for planned well.
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.09.2018  Harikrushna Solia
**
** Modification history:
**
**
** Modification history:
**
** Date       Whom     Change description:
** --------   -------- --------------------------------------
** 11.09.2018 solibhar ECPD-58838: Initial version
*****************************************************************/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeStatement                                                          --
-- Description    : Used to run Dyanamic sql statements.
--                                                                                               --
-- Preconditions  :                --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                --
--                                                                                               --
-- Using functions:                                                 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeStatement(
p_statement varchar2)

RETURN VARCHAR2
--</EC-DOC>
IS

    li_cursor  integer;
    li_ret_val  integer;
    lv2_err_string VARCHAR2(32000);

BEGIN

    li_cursor := DBMS_SQL.open_cursor;

    DBMS_SQL.parse(li_cursor,p_statement,DBMS_SQL.v7);
    li_ret_val := DBMS_SQL.execute(li_cursor);
    DBMS_SQL.Close_Cursor(li_cursor);

  RETURN NULL;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
       DBMS_SQL.Close_Cursor(li_cursor);

      -- record not inserted, already there...
      lv2_err_string := 'Failed to execute (record exists): ' || chr(10) || p_statement || chr(10);
      return lv2_err_string;
    WHEN INVALID_CURSOR THEN
      lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
      return lv2_err_string;

    WHEN OTHERS THEN
      IF DBMS_SQL.is_open(li_cursor) THEN
        DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

      lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
      return lv2_err_string;

END executeStatement;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :  insertWellStatus
-- Description    :  This procedure insert well status record in pwel_period_status or iwel_period_status based well type
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CTRL_CODE_DEPENDENCY
-- Using functions: EcDp_Well.isWellProducer
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  insertWellStatus(p_object_id VARCHAR2,p_daytime DATE, p_user VARCHAR2) IS

    lv2_isProducer         VARCHAR2(1);
    lv2_isInjector         VARCHAR2(1);
    lv2_well_type          VARCHAR2(32);
    lv2_class_name         VARCHAR2(32);
    ld_daytime             DATE;

    CURSOR c_inj_type(cp_well_type VARCHAR2) is
    select cd.code2 from ctrl_code_dependency cd
    where cd.code_type2 = 'INJ_TYPE'
    and cd.code_type1 = 'WELL_TYPE'
    and cd.code1 = cp_well_type;

BEGIN

    lv2_isProducer :=ecdp_well.isWellProducer(p_object_id,p_daytime);
    lv2_isInjector :=ecdp_well.isWellInjector(p_object_id,p_daytime);
    lv2_well_type :=ecdp_well.getWellType(p_object_id,p_daytime);
    lv2_class_name := ec_well.class_name(p_object_id);
    ld_daytime := EcDp_ProductionDay.getProductionDayStart(lv2_class_name,p_object_id,p_daytime);

    IF lv2_isProducer = 'Y' THEN
      INSERT INTO pwel_period_status (OBJECT_ID, DAYTIME, WELL_STATUS, TIME_SPAN, SUMMER_TIME) VALUES (p_object_id, ld_daytime, 'PLANNED', 'EVENT', 'N');
    END IF;

    IF lv2_isInjector = 'Y' THEN
      FOR c IN c_inj_type (lv2_well_type) LOOP
        INSERT INTO iwel_period_status (OBJECT_ID, DAYTIME, WELL_STATUS, INJ_TYPE,TIME_SPAN, SUMMER_TIME) VALUES (p_object_id, ld_daytime, 'PLANNED', c.code2,'EVENT', 'N');
      END LOOP;
    END IF;


END insertWellStatus;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :  deleteWellStatus
-- Description    :  This procedure delete well status record in pwel_period_status or iwel_period_status based well type, if object_start_date and object_end_date is same.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PWEL_PERIOD_STATUS,IWEL_PERIOD_STATUS
-- Using functions: EcDp_Well.isWellProducer,EcDp_Well.isWellInjector,EcDp_Well.getWellType, EcDp_Well.IsPlannedWell
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  deleteWellStatus(p_object_id VARCHAR2,p_daytime DATE) IS

    ln_cnt_pwel         NUMBER := 0;
    ln_cnt_iwel         NUMBER := 0;


BEGIN


    --check existing status record and delete it if any on the same date
    SELECT count(*) INTO ln_cnt_pwel
    FROM pwel_period_status
    WHERE object_id = p_object_id
    AND well_status ='PLANNED';

    SELECT count(*) INTO ln_cnt_iwel
    FROM iwel_period_status
    WHERE object_id = p_object_id
    AND well_status ='PLANNED';



    IF ln_cnt_pwel > 0 THEN
      DELETE FROM pwel_period_status  WHERE object_id = p_object_id AND well_status ='PLANNED' ;
    END IF;

    IF ln_cnt_iwel > 0 THEN
      DELETE FROM iwel_period_status  WHERE object_id = p_object_id AND well_status ='PLANNED' ;
    END IF;


END deleteWellStatus;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :  changeStatusForPlannedWell
-- Description    :  This procedure update CLASS_NAME of WELL table from PLANNED_WELL to WELL
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  changeStatusForPlannedWell(p_object_id VARCHAR2,p_old_well_status VARCHAR2,p_new_well_status VARCHAR2, p_action VARCHAR2) IS
    ln_cnt_pwel         NUMBER := 0;
    ln_cnt_iwel         NUMBER := 0;
    lv2_new_active_status    VARCHAR2(32);
    lv2_old_active_status    VARCHAR2(32);
    lv2_well_class           VARCHAR2(32);

BEGIN

    lv2_new_active_status := EcDp_System.getDependentCode('ACTIVE_WELL_STATUS', 'WELL_STATUS', p_new_well_status);
    lv2_old_active_status := EcDp_System.getDependentCode('ACTIVE_WELL_STATUS', 'WELL_STATUS', p_old_well_status);
    lv2_well_class := ECDP_OBJECTS.GetObjClassName(p_object_id);


    IF p_action = 'INSERT' THEN

        IF lv2_new_active_status = 'OPEN' THEN
            --updating well class_name from PLANNED_WELL to WELL
            UPDATE WELL SET CLASS_NAME='WELL' where object_id=p_object_id;

            --Synchronise GROUPS and OBJECTS_TABLE for WELL
            DELETE FROM OBJECTS_TABLE WHERE object_id = p_object_id;
            DELETE FROM groups WHERE object_id = p_object_id;
            ecdp_synchronise.Synchronise('WELL',p_object_id);

        ELSE
            RAISE_APPLICATION_ERROR(-20485, 'Only status change from Planned to Open Normal or Chocked back is allowed.');
        END IF;

    ELSIF p_action = 'UPDATE' THEN

        IF lv2_old_active_status = 'PLANNED' AND lv2_new_active_status = 'OPEN' THEN
            --updating well class_name from PLANNED_WELL to WELL
            UPDATE WELL SET CLASS_NAME='WELL' where object_id=p_object_id;

            --Synchronise GROUPS and OBJECTS_TABLE for WELL
            DELETE FROM OBJECTS_TABLE WHERE object_id = p_object_id;
            DELETE FROM groups WHERE object_id = p_object_id;
            ecdp_synchronise.Synchronise('WELL',p_object_id);

        ELSE
            RAISE_APPLICATION_ERROR(-20485, 'Only status change from Planned to Open Normal or Chocked back is allowed.');
        END IF;

    END IF;

END changeStatusForPlannedWell;


END EcDp_PlannedWell;