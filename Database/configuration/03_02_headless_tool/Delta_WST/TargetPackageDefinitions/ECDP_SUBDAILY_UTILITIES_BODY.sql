CREATE OR REPLACE PACKAGE BODY EcDp_SubDaily_Utilities IS
/**************************************************************
** Package:    EcDp_SubDaily_Utilities
**
** $Revision: 1.5.12.4 $
**
** Filename:   EcDp_SubDaily_Utilities.sql
**
** Part of :   EC Kernel
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:     30.07.2008  Toha Taipur
**
**
** Modification history:
**
**
** Date:      Whom:      Change description:
** --------   -----      --------------------------------------------
** 27-07-09   Toha       ECPD-11578 - Adds support for new signature in ecdp_date_time
** 08-02-11   oonnnng    ECPD-16614 - Updated the c_updateable_columns cursor in the generateMissingRecords() function.
** 03-12-12   kumarsur   ECPD-22712 - Generate missing rows in subdaily injection screen is to slow. Modified populate() function.
** 11-12-12   musthram   ECPD-22832 - Added checkRecordStatus and checkAccessLevel
** 04-07-13   musthram   ECPD-24737 - Modified checkRecordStatus
** 26-07-13   musthram   ECPD-24737 - Modified checkRecordStatus and checkAccessLevel
**************************************************************/

TYPE ec_point_array IS TABLE OF EcBp_MathLib.Ec_point INDEX BY PLS_INTEGER;

FUNCTION joinList(p_list DBMS_SQL.Varchar2_Table) RETURN VARCHAR2
IS
lv2_sql VARCHAR2(4000);
BEGIN
  FOR one IN 1..p_list.count LOOP
    IF lv2_sql IS NULL THEN
      lv2_sql := LOWER(p_list(one));
    ELSE
      lv2_sql := lv2_sql || ', ' || LOWER(p_list(one));
    END IF;
  END LOOP;
  RETURN lv2_sql;
END joinList;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : lookupValue
-- Description    : A local procedure.
--                  Given the data coordinate (row, column) of the cell to be examined, find
--                  the previous not-null value and next not-null value for the column.
--                  For method 'PREV', the only p_value_before will ever be set. for POST,
--                  only p_value_after will ever be set. BOTH will set both out parameter.
--
-- Preconditions  : p_2d_data already populated for each cells for the given production_day.
--                  all input variables are not-null. p_prev and p_post included, although
--                  the fields can be null
--
-- Postconditions : p_value_before and/or p_value_after will be set according to:
--                  x=row number which the previous/after not-null value is found.
--                  y= the value for the row.
--                  if no row contains not-null value, p_prev/p_post will be used instead.
--
-- Using tables   : None
--
-- Using functions: None
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE lookupValue(
    p_lookup_method      VARCHAR2, -- PREV/POST/BOTH
    p_2d_data        IN  EcDp_SubDaily_Utilities.t_number_array,
    p_row                NUMBER, -- row ref
    p_col                NUMBER, -- col ref
    p_prev               EcBp_Mathlib.Ec_point, -- default previous-day value
    p_post               EcBp_Mathlib.Ec_point, -- default following-day value
    p_value_before   OUT EcBp_Mathlib.Ec_point,
    p_value_after    OUT EcBp_Mathlib.Ec_point
)
--</EC-DOC>
IS
BEGIN
  -- reset value
  p_value_before.x := NULL;
  p_value_before.y := NULL;
  p_value_after.x := NULL;
  p_value_after.y := NULL;

  IF p_lookup_method IN ('PREV', 'BOTH') THEN
    FOR one IN REVERSE 1..p_row-1 LOOP
      IF p_2d_data(one)(p_col) IS NOT NULL THEN
        p_value_before.x := one;
        p_value_before.y := p_2d_data(one)(p_col);
        EXIT;
      END IF;
    END LOOP;
    IF p_value_before.y IS NULL THEN
      p_value_before.x := p_prev.x;
      p_value_before.y := p_prev.y;
    END IF;
  END IF;
  IF p_lookup_method IN ('POST', 'BOTH') THEN
    FOR one IN p_row+1..p_2d_data.count LOOP
      IF p_2d_data(one)(p_col) IS NOT NULL THEN
        p_value_after.x := one;
        p_value_after.y := p_2d_data(one)(p_col);
        EXIT;
      END IF;
    END LOOP;
    IF p_value_after.y IS NULL THEN
      p_value_after.x := p_post.x;
      p_value_after.y := p_post.y;
    END IF;
  END IF;
END lookupValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : interpolate
-- Description    : A local procedure.
--                  Given 2 coordinates and one variable, performs linear interpolation
--
-- Preconditions  : all variables are not null. Fields for both coordinate can be null.
--                  If given coordinates are of same coordinate, expect 0 division to happen
--
-- Postconditions : Returns interpolated y-variable
--
-- Using tables   : None
--
-- Using functions: EcBp_Mathlib.interpolateLinear
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION interpolate(
    p_row                NUMBER,
    ln_prev              EcBp_Mathlib.Ec_point,
    ln_after             EcBp_Mathlib.Ec_point
)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN EcBp_Mathlib.interpolateLinear(p_row, ln_prev.x, ln_after.x, ln_prev.y, ln_after.y);
END interpolate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : populate
-- Description    : For an object, populate these out variables:
--                  p_2d_data: a two dimensional array containing each cells
--                  for the given production_day from database. If the row not exists,
--                  the cells still be created with null values.
--                  p_prev: an array of ec_point for both row number(field x) and
--                      value (field y) for previous production_day for each column:
--                      Each ec_point in the array gives the latest not-null value from
--                      previous production day. If not exists field values are null.
--                  p_post: an array of ec_point for both row number(field x) and
--                      value (field y) for next production_day for each column:
--                      Each ec_point in the array gives the first not-null value from
--                      the next production day. If not exists field values are null.
--                  p_status: an array of varchar2 giving the status of each row.
--                      If the row already exists, the status will be UNCHANGED.
--                      If the row is not exists, the status will be INSERT.
--
--                  Retrieve operation for the daytime is using UTC date
--
-- Preconditions  : Valid p_object_id and p_day. The given view name (p_source_name must contains
--                  columns: OBJECT_ID, PRODUCTION_DAY, SUMMER_TIME, DAYTIME.
--                  If given coordinates are of same coordinate, expect 0 division to happen
--
-- Postconditions : populated out variables.
--                  KNOWN ISSUE: if generate missing record is done in one day and production_day_start
--                  has changed after that for prev/current/next production_day,
--                  error can be be expected.
--
-- Using tables   : view given with variable p_source_name
--
-- Using functions: EcDp_Date_Time, EcDp_Productionday
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------

PROCEDURE populate (
    p_object_id          VARCHAR2,
    p_day                DATE,
    p_offset             NUMBER, -- production_day offset
    p_next_offset        NUMBER, -- next day production_day offset
    p_period_hrs         NUMBER, -- sub day periods of this day
    p_source_name        VARCHAR2,
    p_pkeys              EcDp_SubDaily_Utilities.t_pkey_list,
    p_colnames           DBMS_SQL.Varchar2_Table, -- list of editable number columns in the class
    p_2d_data        OUT EcDp_SubDaily_Utilities.t_number_array,
    p_prev           OUT ec_point_array,
    p_post           OUT ec_point_array,
    p_status         OUT DBMS_SQL.Varchar2_Table,
    p_pdd_id             production_day.object_id%TYPE
)
--</EC-DOC>
IS
  lv2_sql VARCHAR2(4000);
  lc NUMBER;
  indx PLS_INTEGER := 1;
  ln_count NUMBER;
  ld_prod_day_start DATE; -- utc day start
  ld_day_start_next DATE; -- utc day start for tomorrow
  ld_daytime DATE;        -- utc daytime placeholder
  ll_temp DBMS_SQL.Number_Table;
  ll_daytime_temp DBMS_SQL.Date_Table;
  ll_prod_day_temp DBMS_SQL.Date_Table;
  ln_rowcount PLS_INTEGER := 1;

BEGIN
  ld_prod_day_start := EcDp_Date_Time.local2utc(p_day+p_offset/24, NULL, p_pdd_id);
  ld_day_start_next := EcDp_Date_Time.local2utc(p_day+1+p_next_offset/24, NULL, p_pdd_id);

  -- to get records with correct period_hrs, this method is used: mod((daytime - production_day_start), period)
  -- but the date interval assumed the correct precision for datatype: date with nearest second
  -- period is stored in minutes, so this caused "non-integer" value when interval is returned.
  -- simple round facility should be able to fix this problem, or maybe by converting both values in seconds.
  lv2_sql := 'SELECT ' || joinList(p_colnames) || ', EcDp_Date_Time.local2utc(daytime, summer_time, :pdd_id) as daytime, production_day '
     || 'FROM ' || p_source_name || ' WHERE object_id = :p_object_id AND production_day between :p_production_day -1 and :p_production_day +1 ';

  FOR one IN 1..p_pkeys.count LOOP
    lv2_sql := lv2_sql || 'AND ' || p_pkeys(one).name || ' = :P_' || p_pkeys(one).name;
  END LOOP;

  lv2_sql := lv2_sql || ' ORDER BY daytime, summer_time'; -- summertime start with N followed by Y

  --ecdp_dynsql.writeTempText('SUBDAY_GEN_SELECT', 'object_id: ' || p_object_id || ', p_day: ' || TO_CHAR(p_day, 'yyyy-mm-dd hh24:mi:ss') ||
  --  ', p_offset: ' || p_offset || ', p_next_offset: ' || p_offset || ', p_period_hrs: ' || p_period_hrs || ', p_pdd_id: ' || p_pdd_id);
  --ecdp_dynsql.writeTempText('SUBDAY_GEN_SELECT', lv2_sql);

  -- dbms_sql operation: open cursor, parse statement, bind variables, define returned values, retrieve, close cursor..
  lc := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(lc, lv2_sql, DBMS_SQL.native);
  DBMS_SQL.bind_variable(lc, ':p_object_id', p_object_id);
  DBMS_SQL.bind_variable(lc, ':p_production_day', p_day);
  DBMS_SQL.bind_variable(lc, ':pdd_id', p_pdd_id);

  FOR one IN 1..p_pkeys.count LOOP
    DBMS_SQL.bind_variable(lc, ':P_' || p_pkeys(one).name, p_pkeys(one).value);
  END LOOP;

  FOR one IN 1..p_colnames.count LOOP
    -- define each
    DBMS_SQL.define_array(lc, one, ll_temp, 10, indx);
  END LOOP;
  DBMS_SQL.define_array(lc, p_colnames.count+1, ll_daytime_temp, 10, indx);
  DBMS_SQL.define_array(lc, p_colnames.count+2, ll_prod_day_temp, 10, indx);

  ln_count := DBMS_SQL.execute(lc);

  LOOP
    ln_count := DBMS_SQL.fetch_rows(lc);

    DBMS_SQL.column_value(lc, p_colnames.count+1, ll_daytime_temp);
    DBMS_SQL.column_value(lc, p_colnames.count+2, ll_prod_day_temp);

    FOR one IN 1..p_colnames.count LOOP
      -- ll_temp is reused for all columns, so for each loop, the values are updated
      DBMS_SQL.column_value(lc, one, ll_temp);

      FOR two IN ln_rowcount..ll_temp.count LOOP
        IF mod(ROUND((ll_daytime_temp(two) - ld_prod_day_start)*1440, 5), p_period_hrs) != 0 THEN
           NULL;
        ELSIF ll_prod_day_temp(two) = p_day - 1 THEN
          -- prev list for copy forward/interpolate
          -- get the latest valid value for yesterday
          IF ll_temp(two) IS NOT NULL THEN
            -- the calculation below will give the record number relative to ld_prod_day_start. used 3 times separately for each different production_day
            p_prev(one).x := ROUND((ll_daytime_temp(two)-ld_prod_day_start)*1440/p_period_hrs+1, 10);
            p_prev(one).y := ll_temp(two);
          END IF;
        ELSIF ll_prod_day_temp(two) = p_day + 1 THEN
          -- post list for copy backward/interpolate
          -- get first non-null value of tomorrow
          IF (NOT p_post.exists(one) OR p_post(one).y IS NULL) AND ll_temp(two) IS NOT NULL THEN
            p_post(one).x := ROUND((ll_daytime_temp(two)-ld_prod_day_start)*1440/p_period_hrs+1, 10);
            p_post(one).y := ll_temp(two);
          END IF;
        ELSIF ll_prod_day_temp(two) = p_day THEN
          p_2d_data(ROUND((ll_daytime_temp(two)-ld_prod_day_start)*1440/p_period_hrs+1, 10))(one) := ll_temp(two);
        END IF;
      END LOOP;
    END LOOP;
    ln_rowcount := ln_rowcount+ln_count;
    EXIT WHEN ln_count <> 10;
  END LOOP;

  DBMS_SQL.close_cursor(lc);

  -- settting row status
  ld_daytime := ld_prod_day_start;
  ln_rowcount := 1; -- me too lazy. reusing existing var
  WHILE ld_daytime < ld_day_start_next LOOP
    IF NOT p_2d_data.exists(ln_rowcount) THEN
      FOR one IN 1..p_colnames.count LOOP
        p_2d_data(ln_rowcount)(one) := NULL;
      END LOOP;
      p_status(ln_rowcount) := 'INSERT';
    ELSE
      p_status(ln_rowcount) := 'UNCHANGED';
    END IF;
    ln_rowcount := ln_rowcount + 1;
    ld_daytime := ld_daytime + p_period_hrs/1440;
  END LOOP;

  -- initialize pre/post data
  FOR one IN 1..p_colnames.count LOOP
    IF NOT p_prev.exists(one) THEN
      p_prev(one).x := NULL;
      p_prev(one).y := NULL;
    END IF;
    IF NOT p_post.exists(one) THEN
      p_post(one).x := NULL;
      p_post(one).y := NULL;
    END IF;
  END LOOP;
EXCEPTION WHEN OTHERS THEN
  IF DBMS_SQL.is_open(lc) THEN
    DBMS_SQL.close_cursor(lc);
  END IF;
  RAISE;
END populate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : writeContent
-- Description    : For internal testing, if not using debugging
--
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE writeContent (
    p_object_id          VARCHAR2,
    p_day                DATE,
    p_period_hrs         NUMBER,
    p_offset             NUMBER,
    p_pkeys              EcDp_SubDaily_Utilities.t_pkey_list,
    p_colnames           DBMS_SQL.Varchar2_Table,
    p_2d_data            EcDp_SubDaily_Utilities.t_number_array,
    p_status             DBMS_SQL.Varchar2_Table,
    p_pdd_id             production_day.object_id%TYPE
)
--</EC-DOC>
IS
  lv2_text varchar2(4000);
  ln_value number;
  ln_row number:=0;
  ld_start DATE;
  ld_end DATE;

BEGIN
  ld_start := EcDp_Date_Time.local2utc(p_day + p_offset/24, NULL, p_pdd_id);
  ld_end := EcDp_Date_Time.local2utc(p_day + 1 + p_offset/24, NULL, p_pdd_id);
  lv2_text := 'PK List: oid [' || p_object_id || '], pday [' || TO_CHAR(p_day, 'yyyy-mm-dd hh24:mi:ss') || ']';
  FOR i IN 1..p_pkeys.count LOOP
    lv2_text := lv2_text || ', ' || p_pkeys(i).name || ' [' || p_pkeys(i).value || ']';
  END LOOP;
  ecdp_dynsql.writeTemptext('PKEYS COLS', lv2_text);

  lv2_text := 'Col lists: ';
  FOR i IN 1..p_colnames.count LOOP
    lv2_text:=lv2_text || LOWER(p_colnames(i)) || ', ';
  END LOOP;
  ecdp_dynsql.writeTemptext('SUBDAILY COLS', lv2_text);

  WHILE ld_start < ld_end LOOP
    ln_row := ln_row + 1;
    lv2_text := 'row ' || to_char(ln_row) || ' with daytime - ' || to_char(ld_start, 'yyyy-mm-dd hh24:mi:ss') || ': ';
    for one in 1..p_colnames.count loop

      IF p_2d_data.exists(ln_row) AND p_2d_data(ln_row).exists(one) THEN
      ln_value := p_2d_data(ln_row)(one);
      else
      ln_value := NULL;
      end if;
      lv2_text := lv2_text || ln_value || ', ';
    end loop;
    ecdp_dynsql.writeTemptext('SUBDAILY', lv2_text);
    ld_start := ld_start + p_period_hrs/1440;
  end loop;

  lv2_text := 'status: ';
  FOR one IN 1..p_status.count LOOP
    lv2_text:= lv2_text || ', ' || p_status(one);
  END LOOP;
    ecdp_dynsql.writeTemptext('STATUS', lv2_text);
END writeContent;

/*
PROCEDURE extraWrite(
  p_name       VARCHAR2,
  p_points     ec_point_array
)
IS
  lv2_text VARCHAR2(4000);
BEGIN
  lv2_text := 'POINTS: ';
  FOR one IN 1..p_points.count LOOP
    lv2_text := lv2_text || '[' || p_points(one).x || '][' || p_points(one).y || '], ';
  END LOOP;
  ecdp_dynsql.writeTempText(p_name, lv2_text);
END extraWrite;
*/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findNewList
-- Description    : Calls populate() to populate variables: p_2d_data, p_status, ll_prev, ll_post.
--                  Then for each not-null p_2d_data cells, attempt to fill in with the given method.
--
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE findNewList (
    p_object_id          VARCHAR2,
    p_day                DATE,
    p_period_hrs         NUMBER,
    p_offset             NUMBER,
    p_next_offset        NUMBER,
    p_source_name        VARCHAR2,
    p_method             VARCHAR2,
    p_pkeys              EcDp_SubDaily_Utilities.t_pkey_list,
    p_colnames           DBMS_SQL.Varchar2_Table,
    p_2d_data     IN OUT EcDp_SubDaily_Utilities.t_number_array,
    p_status      IN OUT DBMS_SQL.Varchar2_Table, -- INSERT/UPDATE/UNCHANGED
    p_pdd_id             production_day.object_id%TYPE
)
--</EC-DOC>
IS
  -- previous-day latest not-null values for each updatable columns
  ll_prev ec_point_array;
  -- next-day latest not-null values for each updatable columns
  ll_post ec_point_array;
  -- placeholder for first-found, previous not-null value. Set by lookupValue
  ln_before EcBp_Mathlib.Ec_point;
  -- placeholder for first-found, next not-null value. Set by lookupValue
  ln_after EcBp_Mathlib.Ec_point;
BEGIN
  populate(p_object_id,
           p_day,
           p_offset,
           p_next_offset,
           p_period_hrs,
           p_source_name,
           p_pkeys,
           p_colnames,
           p_2d_data,
           ll_prev,
           ll_post,
           p_status,
           p_pdd_id);
--  extraWrite('PREV', ll_prev);
--  extraWrite('POST', ll_post);
--  writeContent(p_object_id, p_day, p_period_hrs, p_offset, p_pkeys, p_colnames, p_2d_data, p_status);

  IF p_method = 'INTERPOLATE' THEN
    FOR c_col IN 1..p_colnames.count LOOP
      FOR c_row IN 1..p_2d_data.count LOOP
        IF p_2d_data(c_row)(c_col) IS NULL THEN
          lookupValue('BOTH', p_2d_data, c_row, c_col, ll_prev(c_col), ll_post(c_col), ln_before, ln_after);
          IF ln_before.y IS NULL AND ln_after.y IS NULL THEN
            -- do nothing for this column since both previous and next value is null
            EXIT;
          ELSIF ln_after.y IS NULL THEN
            -- after is null, fallback to copy_forward method
            p_2d_data(c_row)(c_col) := ln_before.y;
            -- tell that this row has changed
            IF p_status(c_row) = 'UNCHANGED' THEN
              p_status(c_row) := 'UPDATE';
            END IF;
          ELSIF ln_before.y IS NULL THEN
            -- no prev value. do nothing
            NULL;
          ELSE
            p_2d_data(c_row)(c_col) := interpolate(c_row, ln_before, ln_after);
            IF p_status(c_row) = 'UNCHANGED' THEN
              p_status(c_row) := 'UPDATE';
            END IF;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  ELSIF p_method = 'COPY_FORWARD' THEN
    FOR c_col IN 1..p_colnames.count LOOP
      FOR c_row IN REVERSE 1..p_2d_data.count LOOP
        IF p_2d_data(c_row)(c_col) IS NULL THEN
          lookupValue('PREV', p_2d_data, c_row, c_col, ll_prev(c_col), ll_post(c_col), ln_before, ln_after);
          IF ln_before.y IS NULL THEN
            -- do nothing for this column. we know it reach latest daytime so subsequent rows are empty for this col!
            EXIT;
          ELSE
            p_2d_data(c_row)(c_col) := ln_before.y;
            IF p_status(c_row) = 'UNCHANGED' THEN
              p_status(c_row) := 'UPDATE';
            END IF;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  ELSIF p_method = 'COPY_BACKWARD' THEN
    FOR c_col IN 1..p_colnames.count LOOP
      FOR c_row IN 1..p_2d_data.count LOOP
        IF p_2d_data(c_row)(c_col) IS NULL THEN
          lookupValue('POST', p_2d_data, c_row, c_col, ll_prev(c_col), ll_post(c_col), ln_before, ln_after);
          IF ln_after.y IS NULL THEN
            -- do nothing for this column. we know it reach bottom first so subsequent rows are empty for this col!
            EXIT;
          ELSE
            p_2d_data(c_row)(c_col) := ln_after.y;
            IF p_status(c_row) = 'UNCHANGED' THEN
              p_status(c_row) := 'UPDATE';
            END IF;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  END IF;

  ll_prev.delete;
  ll_post.delete;
END findNewList;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : buildInsertOrUpdate
-- Description    : Build insert and update statement, if necessary
--
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE buildInsertOrUpdate(
    p_source_name        VARCHAR2,
    p_pkeys              EcDp_SubDaily_Utilities.t_pkey_list,
    p_colnames           DBMS_SQL.Varchar2_Table,
    p_status             DBMS_SQL.Varchar2_Table,
    p_insert         OUT VARCHAR2,
    p_update         OUT VARCHAR2
)
IS
  lv2_temp VARCHAR2(2000);
BEGIN
  -- Reset p_insert and p_update (is it necessary?)
  p_insert:=NULL;
  p_update:=NULL;

  -- build dynamic sql for both insert and update
  FOR one IN 1..p_status.count LOOP
    IF p_status(one) = 'INSERT' AND p_insert IS NULL THEN
      p_insert := 'INSERT INTO ' || p_source_name || ' (object_id, daytime, summer_time, ';
      lv2_temp := NULL;
      FOR two IN 1..p_pkeys.count LOOP
        p_insert := p_insert || LOWER(p_pkeys(two).name) || ', ';
        lv2_temp := lv2_temp || ':p_' || LOWER(p_pkeys(two).name) || ', ';
      END LOOP;
      p_insert := p_insert || joinList(p_colnames)
              || ', rev_text, created_by) VALUES (:p_object_id, :p_daytime, :p_summer_time, '|| lv2_temp;
      FOR two IN 1..p_colnames.count LOOP
        p_insert := p_insert || ':p_' || LOWER(p_colnames(two)) || ', ';
      END LOOP;
      p_insert := p_insert || 'CONCAT(''auto-generated row at '', to_char(:p_current_date, ''yyyy-mm-dd hh24:mi:ss'')), :p_user_id)';

      -- quit if p_update already set!
      IF p_update IS NOT NULL THEN
        EXIT;
      END IF;
    ELSIF p_status(one) = 'UPDATE' AND p_update IS NULL THEN
      p_update := 'UPDATE ' || p_source_name || ' SET ';
      lv2_temp := NULL;
      FOR two IN 1..p_colnames.count LOOP
        p_update := p_update || LOWER(p_colnames(two)) || ' = :p_' || LOWER(p_colnames(two)) || ', ';
      END LOOP;
      p_update := p_update || ' rev_text=CONCAT(''auto-updated row at '', to_char(:p_current_date, ''yyyy-mm-dd hh24:mi:ss'')), '
              || 'last_updated_by = :p_user_id where object_id = :p_object_id '
              || 'AND daytime = :p_daytime AND summer_time = :p_summer_time';
      FOR two IN 1..p_pkeys.count LOOP
        p_update := p_update || ' AND ' || LOWER(p_pkeys(two).name) || ' = :p_' || LOWER(p_pkeys(two).name);
      END LOOP;

      -- quit if p_insert already set!
      IF p_insert IS NOT NULL THEN
        EXIT;
      END IF;
    END IF;
  END LOOP;

END buildInsertOrUpdate;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : insertOrUpdate
-- Description    : Perform insert or update to subdaily tables
--
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertOrUpdate(
    p_object_id          VARCHAR2,
    p_day                DATE,
    p_period_hrs         NUMBER,
    p_offset             NUMBER,
    p_source_name        VARCHAR2,
    p_pkeys              EcDp_SubDaily_Utilities.t_pkey_list,
    p_colnames           DBMS_SQL.Varchar2_Table,
    p_2d_data            EcDp_SubDaily_Utilities.t_number_array,
    p_status             DBMS_SQL.Varchar2_Table,
    p_user_id            VARCHAR2,
    p_pdd_id             production_day.object_id%TYPE
)
--</EC-DOC>
IS
  c_insert PLS_INTEGER; -- insert cursor
  c_update PLS_INTEGER; -- update cursor
  c_ref PLS_INTEGER; -- cursor referencing either insert or update cursor
  lv2_insert VARCHAR2(4000); -- insert statement
  lv2_update VARCHAR2(4000); -- update statement
  ln_ignore PLS_INTEGER; -- used for dbms_sql.execute
  ld_current_date DATE; -- for rev_text differentiation
  ld_daytime DATE; -- placeholder for current utc date for summertime and local date conversion

  ld_day_start DATE; -- p_day is local. convert to utc, since it being used to get ld_daytime

BEGIN
  buildInsertOrUpdate(
    p_source_name,
    p_pkeys,
    p_colnames,
    p_status,
    lv2_insert,
    lv2_update);

  IF lv2_insert IS NULL AND lv2_update IS NULL THEN
    -- nothing to do!
    RETURN;
  END IF;

  --ecdp_dynsql.writeTempText('SUBDAILY_INST', lv2_insert);
  --ecdp_dynsql.writeTempText('SUBDAILY_UPD', lv2_update);

  ld_day_start := EcDp_Date_Time.local2utc(p_day+p_offset/24, NULL, p_pdd_id);

  IF lv2_insert IS NOT NULL THEN

    ld_current_date := ecdp_date_time.getCurrentSysdate;

    c_insert := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(c_insert, lv2_insert, DBMS_SQL.native);
    -- default binds
    DBMS_SQL.bind_variable(c_insert, ':p_object_id', p_object_id);
    DBMS_SQL.bind_variable(c_insert, ':p_user_id', p_user_id);
    DBMS_SQL.bind_variable(c_insert, ':p_current_date', ld_current_date);
    FOR one IN 1..p_pkeys.count LOOP
      DBMS_SQL.bind_variable(c_insert, ':p_' || LOWER(p_pkeys(one).name), p_pkeys(one).value);
    END LOOP;
  END IF;

  IF lv2_update IS NOT NULL THEN
    IF ld_current_date IS NULL THEN
      ld_current_date := ecdp_date_time.getCurrentSysdate;
    END IF;
    c_update := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(c_update, lv2_update, DBMS_SQL.native);
    -- default binds
    DBMS_SQL.bind_variable(c_update, ':p_object_id', p_object_id);
    DBMS_SQL.bind_variable(c_update, ':p_user_id', p_user_id);
    DBMS_SQL.bind_variable(c_update, ':p_current_date', ld_current_date);
    FOR one IN 1..p_pkeys.count LOOP
      DBMS_SQL.bind_variable(c_update, ':p_' || LOWER(p_pkeys(one).name), p_pkeys(one).value);
    END LOOP;
  END IF;

  FOR one IN 1..p_status.count LOOP
    c_ref := NULL;
    IF p_status(one) = 'INSERT' THEN
      c_ref := c_insert;
    ELSIF p_status(one) = 'UPDATE' THEN
      c_ref := c_update;
    END IF;

    IF c_ref IS NOT NULL THEN
      ld_daytime := ld_day_start + (p_period_hrs*(one-1))/1440;
      DBMS_SQL.bind_variable(c_ref, ':p_daytime', EcDp_Date_Time.utc2local(ld_daytime, p_pdd_id));
      DBMS_SQL.bind_variable(c_ref, ':p_summer_time', EcDp_Date_Time.summertime_flag(ld_daytime, NULL, p_pdd_id));

      FOR two IN 1..p_colnames.count LOOP
        DBMS_SQL.bind_variable(c_ref, ':p_' || LOWER(p_colnames(two)), p_2d_data(one)(two));
      END LOOP;
      ln_ignore := DBMS_SQL.execute(c_ref);
    END IF;
  END LOOP;

  -- end
  IF c_insert IS NOT NULL AND DBMS_SQL.is_open(c_insert) THEN
    DBMS_SQL.close_cursor(c_insert);
  END IF;
  IF c_update IS NOT NULL AND DBMS_SQL.is_open(c_update) THEN
    DBMS_SQL.close_cursor(c_update);
  END IF;
EXCEPTION WHEN OTHERS THEN
  -- end
  IF c_insert IS NOT NULL AND DBMS_SQL.is_open(c_insert) THEN
    DBMS_SQL.close_cursor(c_insert);
  END IF;
  IF c_update IS NOT NULL AND DBMS_SQL.is_open(c_update) THEN
    DBMS_SQL.close_cursor(c_update);
  END IF;
  RAISE;
END insertOrUpdate;

PROCEDURE unsetArrays(
    p_pkeys       IN OUT EcDp_SubDaily_Utilities.t_pkey_list,
    p_colnames    IN OUT DBMS_SQL.Varchar2_Table,
    p_2d_data     IN OUT EcDp_SubDaily_Utilities.t_number_array,
    p_status      IN OUT DBMS_SQL.Varchar2_Table
)
IS
BEGIN
  p_status.delete;
  p_colnames.delete;
  p_pkeys.delete;
  FOR i IN REVERSE 1..p_2d_data.count LOOP
    p_2d_data(i).delete;
  END LOOP;
  p_2d_data.delete;
END unsetArrays;

FUNCTION getPeriodHrs(
  p_object_id         VARCHAR2,
  p_daytime           DATE
)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;
  ln_period           VARCHAR2(32);

BEGIN
  IF p_daytime >= EcDp_System.getSystemStartDate THEN
    ln_period := ec_prosty_codes.alt_code(EcDp_ProductionDay.findSubDailyFreq(NULL, p_object_id, p_daytime),'METER_FREQ');

    ln_retval := TO_NUMBER(ln_period);

  END IF;

  RETURN ln_retval;
END;

PROCEDURE generateMissingRecords (
    p_object_id          VARCHAR2,
    p_day                DATE,
    p_subday_class       VARCHAR2,
    p_method             VARCHAR2,
    p_pkeys       IN OUT EcDp_SubDaily_Utilities.t_pkey_list,
    p_user_id            VARCHAR2,
    p_prod_day_ref       VARCHAR2 DEFAULT NULL -- needed for e.g. wbi which use well's productionday instead of its own
)
IS
  CURSOR c_updateable_columns (p_class_name IN VARCHAR2) IS
    SELECT source_name, property_name
      FROM dao_meta
      WHERE class_name = p_class_name
        AND lower(attributes) NOT LIKE '%viewhidden=true%'
        AND lower(attributes) NOT LIKE '%vieweditable=false%'
        AND data_type = 'NUMBER'
        AND NVL(is_report_only,'N') = 'N'
      ORDER BY sort_order;

  ll_colnames  DBMS_SQL.Varchar2_Table;
  ll_2d_data   EcDp_SubDaily_Utilities.t_number_array;
  ll_status    DBMS_SQL.Varchar2_Table;
  ln_offset    NUMBER;
  ln_next_offset NUMBER;
  lv_view_name VARCHAR2(50);
  ln_count     PLS_INTEGER := 1;
  ln_period_hrs NUMBER;
  lv_pdd_id    production_day.object_id%TYPE;

BEGIN
  ln_offset := EcDp_ProductionDay.getProductionDayOffset(NULL, Nvl(p_prod_day_ref, p_object_id), p_day);
  ln_next_offset := EcDp_ProductionDay.getProductionDayOffset(NULL, Nvl(p_prod_day_ref, p_object_id), p_day+1);
  lv_pdd_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, Nvl(p_prod_day_ref, p_object_id), p_day);

  ln_period_hrs := getPeriodHrs(p_object_id, p_day);

  FOR one IN c_updateable_columns( p_subday_class) LOOP
    IF lv_view_name IS NULL THEN
      lv_view_name := one.source_name;
    END IF;
    ll_colnames(ln_count) := one.property_name;
    ln_count := ln_count + 1;
  END LOOP;

  findNewList(
      p_object_id,
      p_day,
      Nvl(ln_period_hrs,1440),
      ln_offset,
      ln_next_offset,
      lv_view_name,
      p_method,
      p_pkeys,
      ll_colnames,
      ll_2d_data,
      ll_status,
      lv_pdd_id);

  --writeContent(p_object_id, p_day, ln_period_hrs, ln_offset, p_pkeys, ll_colnames, ll_2d_data, ll_status, lv_pdd_id);

  insertOrUpdate(
      p_object_id,
      p_day,
      Nvl(ln_period_hrs,1440),
      ln_offset,
      lv_view_name,
      p_pkeys,
      ll_colnames,
      ll_2d_data,
      ll_status,
      p_user_id,
      lv_pdd_id);
  unsetArrays(
      p_pkeys,
      ll_colnames,
      ll_2d_data,
      ll_status);

END generateMissingRecords;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : checkRecordStatus
-- Description    : Check Record Status for Daily Screens before performing aggregation on Sub-Daily screens
--
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------

FUNCTION checkRecordStatus(
  p_daytime            DATE,
  p_object_id          VARCHAR2,
  p_daily_class        VARCHAR2) RETURN VARCHAR2
IS

  lv_record_status VARCHAR2(10) := NULL;
  lv2_sql           VARCHAR2(4000) := NULL ;

BEGIN

   lv2_sql := 'SELECT record_status FROM ' || EcDp_ClassMeta.getClassViewName(p_daily_class) || ' WHERE object_id=''' || p_object_id || ''' AND daytime=to_date(''' || to_char(p_daytime,'yyyy-mm-dd') || ''',''yyyy-mm-dd'') ';
   lv_record_status := EcDp_Utilities.executeSingleRowString(lv2_sql);

   IF lv_record_status IS NOT NULL THEN
     return lv_record_status;
   ELSE
     lv_record_status := 'P';
     return lv_record_status;
   END IF;

END checkRecordStatus;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : checkAccessLevel
-- Description    : Checks Access Level for Logged in User on aggregate button before performing aggregation on Sub-Daily screens
--
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------

FUNCTION checkAccessLevel(
  p_objecturl          VARCHAR2,
  p_subdaily_class     VARCHAR2 DEFAULT NULL,
  p_daily_class        VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS

  lv_access  NUMBER := 0;
  lv_main_objecturl    VARCHAR2(1000);
  lv_button            VARCHAR2(100);

BEGIN

    IF p_subdaily_class IN ('PWEL_SUB_DAY_STATUS','PWEL_SUB_DAY_STATUS_2') THEN
      lv_main_objecturl := SubStr(p_objecturl,0,InStr(p_objecturl,'/',1,3)-1);
      lv_button  :=  SubStr(p_objecturl,InStr(p_objecturl,'/',1,3));
      lv_main_objecturl := lv_main_objecturl || '/CLASS_NAME/' || p_subdaily_class || '/DAILY_CLASS_NAME/' || p_daily_class || lv_button;
    END IF;

    SELECT MAX(tba.level_id) into lv_access
    FROM T_BASIS_ACCESS tba, T_BASIS_OBJECT tbo
    WHERE tba.OBJECT_ID = tbo.OBJECT_ID
    and tbo.object_name = NVL(lv_main_objecturl,p_objecturl)
    and role_id in (select role_id from t_basis_userrole
    where user_id = ecdp_context.getAppUser());

    IF lv_access > 0 THEN
      RETURN lv_access;
    ELSE
      RAISE_APPLICATION_ERROR(-20641,'You do not have access to perform this operation');
    END IF;

END checkAccessLevel;

END EcDp_SubDaily_Utilities;