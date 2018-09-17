CREATE OR REPLACE PACKAGE BODY EcDp_Well_Ref_Values IS
/****************************************************************
** Package        :  EcDp_Well_Ref_Values
**
** $Revision: 1.7 $
**
** Purpose        :  This package is responsible for well constant information
**                   from well_reference_values
**
** Documentation  :  www.energy-components.com
**
** Created  : 08.02.2007 Arief Zaki
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ------      -----     -----------------------------------
** 9.2      08.02.2007  zakiiari  First version
** 9.3      29.08.2007  kaurrnar  ECPD6294: Added execute immediate statement to getAttributeValue function
**          15.07.2008  rajarsar  ECPD-8151: Updated getAttributeValue function
** 10.0     21.11.2008  oonnnng   ECPD-6067: Added local month lock checking in copyToNewDaytime function.
**          17.02.2009  leongsei  ECPD-6067: Modified function copyToNewDaytime for new parameter p_local_lock
**          02.02.2010  oonnnng   ECPD-13599: Modify copyToNewDaytime() function to assign correct value to CREATED_BY column.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyToNewDaytime                                                             --
-- Description    : Copy values from previous record into new record                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : WELL_REFERENCE_VALUE                                                         --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE copyToNewDaytime (
   p_object_id      well.object_id%TYPE,
   p_daytime        DATE     DEFAULT NULL)

--<EC-DOC>
IS

CURSOR c_prev_daytime_rec IS
    select *
    from well_reference_value
    where object_id = p_object_id
    and daytime = (
      select max(daytime)
      from well_reference_value
      where object_id = p_object_id
      and daytime < p_daytime
    );

CURSOR c_next_daytime_rec IS
    select *
    from well_reference_value
    where object_id = p_object_id
    and daytime = (
      select MIN(daytime)
      from well_reference_value
      where object_id = p_object_id
      and daytime > p_daytime
    );

ln_count NUMBER;
ld_next_daytime DATE := NULL;

BEGIN

   ln_count :=0;

   FOR mycur IN c_prev_daytime_rec LOOP

      ln_count := ln_count + 1;

      mycur.daytime := p_daytime;

      -- Lock philosophy, since this is copying all values from the previous, allow it for unlocked months, without checking if next is in locked month
      IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

        EcDp_Month_lock.raiseValidationError('PROCEDURE', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'EcDp_Well_Ref_Values.copyToNewDaytime: Can not do this in a locked month');

      END IF;

      EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_object_id,
                                     p_daytime, p_daytime,
                                     'PROCEDURE', 'EcDp_Well_Ref_Values.copyToNewDaytime: Can not do this in a locked month');

      mycur.created_by := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);

      insert into well_reference_value values mycur;

   END LOOP;

   IF (ln_count = 0)  THEN

     FOR curnext IN c_next_daytime_rec LOOP

       ld_next_daytime := curnext.Daytime;

     END LOOP;

     EcDp_Month_Lock.validatePeriodForLockOverlap('PROCEDURE',p_daytime,ld_next_daytime, 'EcDp_Well_Ref_Values.copyToNewDaytime: Can not do this when there are locked months in the lifespan of these values', p_object_id);

     insert into well_reference_value (OBJECT_ID, DAYTIME, CREATED_BY) values (p_object_id, p_daytime, Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User));

   END IF;

END copyToNewDaytime;


--LOCAL Function
FUNCTION getAttributeValue(
   p_object_id      well.object_id%TYPE,
   p_column_name    VARCHAR2,
   p_table_name     VARCHAR2,
   p_daytime        DATE DEFAULT NULL)
RETURN NUMBER
IS
  lv2_sql           VARCHAR2(4000);
  ln_returnVal      NUMBER;
  lv2_count_row     VARCHAR2(4000);
  ln_rows           NUMBER;


BEGIN

  lv2_count_row := 'SELECT  COUNT(*) FROM '|| p_table_name || ' WHERE ' || 'object_id=''' || p_object_id || '''';
  IF p_daytime IS NULL THEN
    lv2_count_row := lv2_count_row || ' AND daytime = (SELECT MAX(daytime) FROM '|| p_table_name ||' WHERE object_id=''' || p_object_id || ''')';
  ELSE
    lv2_count_row := lv2_count_row || ' AND daytime = (SELECT MAX(daytime) FROM '|| p_table_name ||' WHERE object_id=''' || p_object_id || ''' AND daytime <= to_date(''' || to_char(p_daytime,'yyyy-mm-dd hh24:mi:ss') || ''',''yyyy-mm-dd hh24:mi:ss''))';
  END IF;


  --Construct SQL statement
  lv2_sql := 'SELECT '|| p_column_name ||' FROM '|| p_table_name || ' WHERE ' || 'object_id=''' || p_object_id || '''';
  IF p_daytime IS NULL THEN
    lv2_sql := lv2_sql || ' AND daytime = (SELECT MAX(daytime) FROM '|| p_table_name ||' WHERE object_id=''' || p_object_id || ''')';
  ELSE
    lv2_sql := lv2_sql || ' AND daytime = (SELECT MAX(daytime) FROM '|| p_table_name ||' WHERE object_id=''' || p_object_id || ''' AND daytime <= to_date(''' || to_char(p_daytime,'yyyy-mm-dd hh24:mi:ss') || ''',''yyyy-mm-dd hh24:mi:ss''))';
  END IF;

  execute immediate lv2_count_row  into ln_rows;
  --check number of rows
  IF (ln_rows > 0) then
    execute immediate lv2_sql into ln_returnVal;
  ELSE
    ln_returnVal := NULL;
  END IF;


  RETURN ln_returnVal;

END getAttributeValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getAttribute
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_db_mapping, class_attr_db_mapping
--
-- Using functions: ec_well_version.well_reference_obj_id
--
-- Configuration
-- required       :
--
-- Behaviour      : Return own's [attribute] value. If null, fetch from referrence object's [attribute] value
--
---------------------------------------------------------------------------------------------------
FUNCTION getAttribute(
   p_object_id      well.object_id%TYPE,
   p_attribute      VARCHAR2,
   p_daytime        DATE)
RETURN NUMBER
IS
--</EC-DOC>
  lv2_table         VARCHAR2(100);
  lv2_column        VARCHAR2(100);
  ln_returnVal      NUMBER;
  lv2_ref_object_id VARCHAR2(32);
  lv2_class_name    VARCHAR2(100);

  CURSOR c_class(cp_class_name IN VARCHAR2) IS
    SELECT c.db_object_name FROM class_db_mapping c
     WHERE c.class_name=cp_class_name;

  CURSOR c_db_map(cp_class_name IN VARCHAR2) IS
    SELECT m.attribute_name,m.db_sql_syntax
     FROM class_attr_db_mapping m
     WHERE m.class_name=cp_class_name;

BEGIN
  lv2_class_name := 'WELL_REFERENCE_VALUE';

  --Find the class's table
  FOR cur_class IN c_class(lv2_class_name) LOOP
    lv2_table := cur_class.db_object_name;
  END LOOP;

  --Find the attribute's physical column
  FOR cur_attr IN c_db_map(lv2_class_name) LOOP
    IF UPPER(p_attribute) = UPPER(cur_attr.attribute_name) THEN
       lv2_column := cur_attr.db_sql_syntax;
       EXIT;
    END IF;
  END LOOP;

  IF lv2_column IS NULL THEN
     RAISE_APPLICATION_ERROR(-20000,'The given attribute does not exist.');
  END IF;

  --Look at owns reference values
  ln_returnVal := getAttributeValue(p_object_id,lv2_column,lv2_table,p_daytime);

  IF ln_returnVal IS NULL THEN
    --If NULL, look at referred object
    lv2_ref_object_id := ec_well_version.well_reference_obj_id(p_object_id,p_daytime,'<=');
    IF lv2_ref_object_id IS NULL THEN
      ln_returnVal := NULL;
    ELSE
      ln_returnVal := getAttributeValue(lv2_ref_object_id,lv2_column,lv2_table,p_daytime);
    END IF;
  END IF;

  RETURN ln_returnVal;

END getAttribute;

END EcDp_Well_Ref_Values;