CREATE OR REPLACE PACKAGE BODY EcBp_Aggregate IS
/**************************************************************
** Package:    EcBp_Aggregate
**
** $Revision: 1.48 $
**
** Filename:   EcBp_Aggregate.sql
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
** Created:     11.05.2004  Frode Barstad
**
**
** Modification history:
**
**
** Date:        Whom:               Change description:
** --------     -----               --------------------------------------------
** 2004-05-28   FBa                 Changed reference from EcDp_System.getStartTimeOfProductionDay
** 2005-04-21   Roar Vika           #2188:Modified method aggregateSubDaily to average over all availabe records when UOM_CODE
**                                  contains text string %RATE%
** 2005-05-25   Roar Vika           Added integer/number check within aggregateSubDaily as it gives no sense to aggregate non-number attributes
** 2005-09-14   DN                  TI#2629 Aggregation did not average values for shut-in wells.
** 2006-03-24   Jerome              TI#3260 Aggregation modified to not take records with on_stream_hrs = "0" in to consideration
** 2006-03-27   Zakiiari            TI#3381 Modified aggregation to support class that don't have on_stream_hrs attribute, i.e. Well Bore Interval (WBI_SUB_DAY_STATUS, WBI_DAY_STATUS)
**                                  Changed instantiateDay procedure to use 'select count(*)...' instead of 'select count(rowid)...'
** 2006-04-03   Jerome              TI#2351 Added function aggregateAllSubDaily
** 2006-05-16   Jerome              TD#5870 Increased variable lv2_sql and lv2_subselect in aggregateSubDaily to 8000
** 2006-05-18   Stian Skj?tad    TD#6059  Modified function aggregateAllSubDaily, added "distinct" keyword to query in for-loop.
** 2006-05-25   Jerome              TD#6075 Modified procedure instantiateDay to check from actual table instead of view.
** 2006-06-27   Jerome              TI#3887 Modified aggregateAllSubDaily (use facility)
** 2006-07-20   Zakiiari            TI#4194 Modified both aggregate* functions to support generation of aggregation's rev_text
** 2006-08-23   rahmanaz            TI#4426 Modified aggregateAllSubDaily - Added condition to check wbi.OBJECT_ID
** 2006-11-15   kaurrjes            TI#4759 Added FRAC and PCT UOM Code in the function aggregateSubDaily
** 2006-11-29   kaurrnar            TI#4826 Modified aggregateAllSubDaily - Added 'AND' command and checking for production separator in the ELSE statement
** 2007-04-13   LAU                 ECPD-5253: Modified aggregateAllSubDaily,aggregateSubDaily and instantiateDay
** 2007-09-06   embonhaf            ECPD-5968: Modified aggregateAllSubDaily - added daytime check for WELL_VERSION
** 2007-12-27   Mariadav            ECPD-6064: Support User Exit aggregation of sub daily data
** 2008-10-28   oonnnng             ECPD-9741: Amend "EcDp_System.getDependentCode('ACTIVE_WELL_STATUS','WELL_STATUS',ec_pwel_period_status.well_status(p_object_id, p_daytime, 'EVENT', '<='));"
                                    to "ec_pwel_period_status.active_well_status(p_object_id, p_daytime, 'EVENT', '<=');".
** 2008-11-20   oonnnng             ECPD-6067: Added local month lock checking in aggregateSubDaily function.
** 2009-02-17   leongsei            ECPD-6067: Modified function aggregateSubDaily for new parameter p_local_lock
** 2009-04-10   oonnnng             ECPD-6067: Update local lock checking function in aggregateSubDaily() function with the new design.
** 2009-07-15   oonnnng             ECPD-9672: Update the portion when UOM is equals to %RATE%, %FRAC%, %PCT% in aggregateSubDaily() function.
** 2009-12-28   oonnnng             ECPD-13427: Update the portion to process %VOL%, %MASS% and %ENERGY% in aggregateSubDaily() function.
** 2010-05-18   madondin            ECPD-14324: Modified in function aggregateAllSubDaily, added well type GP2
** 2010-08-18   rajarsar            ECPD-15429: Modified function aggregateSubDaily to remove check for mandatory rev text and if journaling.
** 2010-08-30   oonnnng             ECPD-14888: Updates lv2_sql and lv2_subselect variables to VARCHAR2(32000) in aggregateSubDaily() function.
** 2010-11-30   rajarsar            ECPD-15790: Added support for POWER uom at aggregateSubDaily
** 2012-04-12   rajarsar            ECPD-20305: Modified function aggregateAllSubDaily to include check on aggegation flag and end date
** 2013-04-05   limmmchu            ECPD-23164: Modified aggregateAllSubDaily
** 2013-07-23   musthram            ECPD-23999: Modified aggregateAllSubDaily
** 2013-08-15   rajarsar            ECPD-23266: Updated the portion when UOM is equals to %RATE%, %FRAC%, %PCT% in aggregateSubDaily() function to ensure null rates are not assumed as 0.
** 2015-08-20   abdulmaw            ECPD-30950: Updated aggregateAllSubDaily to support aggregate facility for OPSI.
** 31.08.2016   dhavaalo            ECPD-38607: Remove usage of EcDp_Utilities.executestatement and EcDp_Utilities.executeSinglerowNumber.
** 2017-01-30   singishi            ECPD-40988: Updated aggregateAllSubDaily to support aggregate well bore interval when well bore is closed.
** 2018-03-23   bintjnor            ECPD-53918: Updated aggregateAllSubDaily to support WP and WS well types in the aggregation functionality.
**************************************************************/

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
-- Function       : executeSinglerowNumber                                                       --
-- Description    : Executes a dynamic SQL SELECT which returns 1 row of type NUMBER.            --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeSinglerowNumber(p_statement VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

li_cursor      INTEGER;
li_returverdi   INTEGER;
ln_return_value NUMBER;

BEGIN

   li_cursor := DBMS_SQL.Open_Cursor;

   DBMS_SQL.Parse(li_cursor,p_statement,DBMS_SQL.v7);
   DBMS_SQL.Define_Column(li_cursor,1,ln_return_value);

   li_returverdi := DBMS_SQL.Execute(li_cursor);

   IF DBMS_SQL.Fetch_Rows(li_cursor) = 0 THEN

     ln_return_value := NULL;

   ELSE

      DBMS_SQL.Column_Value(li_cursor,1, ln_return_value);

   END IF;

   DBMS_SQL.Close_Cursor(li_cursor);

   RETURN ln_return_value;

EXCEPTION

  WHEN OTHERS THEN

      IF  DBMS_SQL.is_open(li_cursor) THEN
         DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

   RETURN NULL;

END executeSinglerowNumber;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instantiateDay
-- Description    : creates a blank row for the given day
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE instantiateDay(
  p_class_name         VARCHAR2,
  p_object_id          VARCHAR2,
  p_daytime            DATE,
  p_inj_type           VARCHAR2
)
--</EC-DOC>
IS
  lv2_sql         VARCHAR2(9000);
  lv2_table_name  VARCHAR2(100);
  lv2_view_name   VARCHAR2(100);
  ln_numrows      NUMBER;
  lv2_result      VARCHAR2(4000);

BEGIN
  lv2_table_name := EcDp_ClassMeta.getClassDBTable(p_class_name);
  lv2_view_name := EcDp_ClassMeta.getClassViewName(p_class_name);
  lv2_sql := 'SELECT count(*) FROM ' || lv2_table_name || ' WHERE object_id=''' || p_object_id || ''' AND daytime=to_date(''' || to_char(p_daytime,'yyyy-mm-dd') || ''',''yyyy-mm-dd'') ';
  IF p_class_name IN ('IWEL_DAY_STATUS_WATER','IWEL_DAY_STATUS_GAS','IWEL_DAY_STATUS_STEAM') THEN
    lv2_sql := lv2_sql || ' AND inj_type = '''|| p_inj_type ||'''';
  END IF;
  ln_numrows := executeSingleRowNumber(lv2_sql);
  IF ln_numrows < 1 THEN
    lv2_sql := 'INSERT INTO ' || lv2_view_name || '(object_id, daytime) VALUES (''' || p_object_id || ''', to_date(''' || to_char(p_daytime,'yyyy-mm-dd') || ''',''yyyy-mm-dd'') ) ';
    lv2_result := executeStatement(lv2_sql);
    IF lv2_result IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Failed to instantiate row. Error message: ' || chr(10) || lv2_result);
    END IF;
  END IF;
END instantiateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : aggregateSubDaily
-- Description    :
--
-- Preconditions  : Object_id and daytime must uniquely identify the target (daily) row.
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION aggregateSubDaily(
  p_from_class_name    VARCHAR2,
  p_to_class_name      VARCHAR2,
  p_object_id          VARCHAR2,
  p_daytime            DATE,
  p_period_hrs         NUMBER,
  p_aggr_method        VARCHAR2 DEFAULT 'ON_STREAM',
  p_aggr_datetime      VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2
--</EC-DOC>
IS

  lb_rows_updated  BOOLEAN:=FALSE;
  lv2_sql         VARCHAR2(32000);
  lv2_set         VARCHAR2(4000);
  lv2_subselect   VARCHAR2(32000);
  lv2_where       VARCHAR2(4000);
  lv2_uom         VARCHAR2(100);
  lv2_col         VARCHAR2(4000);
  lv2_result      VARCHAR2(4000);
  lv2_datatype    VARCHAR2(100);
  lb_first        BOOLEAN;
  lb_onstrm_exist_from_class   BOOLEAN;
  lv2_aggr_datetime            VARCHAR2(32);
  lv2_inj_type   VARCHAR2(2);

BEGIN

  -- lock check, only allowed if not in a locked month
      -- Lock check
    IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

      EcDp_Month_lock.raiseValidationError('INSERTING', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'ecBp_aggregate.aggregateSubDaily: Can not aggregate in a locked month');

    END IF;


    EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_object_id,
                                   p_daytime, p_daytime,
                                   'INSERTING', 'ecBp_aggregate.aggregateSubDaily: Can not aggregate in a local locked month');

    -- getting ue_aggregate
    lv2_result := UE_AGGREGATE.aggregateSubDaily(p_from_class_name,p_to_class_name,p_object_id,p_daytime,p_period_hrs,p_aggr_method,p_aggr_datetime,lb_rows_updated);

    IF lv2_result IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20000,'User Exit Aggregation job failed to execute. Error message: '||chr(10)||lv2_result);
    END IF;

    -- If user exit package returned true for the rows updated flag then exit funtion
    IF(lb_rows_updated) THEN
       RETURN NULL;
    END IF;

  -- checking on_stream_hrs existence in table
  lb_onstrm_exist_from_class := Ecdp_Classmeta.HasTableColumn(Ecdp_Classmeta.getClassDBTable(p_from_class_name),'on_stream_hrs');

  lb_first := TRUE;

  -- No use in aggregating date of different objects
  IF EcDp_ClassMeta.OwnerClassName(p_to_class_name) <> EcDp_ClassMeta.OwnerClassName(p_from_class_name) THEN
     RAISE_APPLICATION_ERROR(-20000,'Owner class differs, makes no sense to aggregate data.');
  END IF;

  -- No use in period length 0
  IF p_period_hrs <= 0 THEN
    RAISE_APPLICATION_ERROR(-20000,'Period length is <= 0, cannot aggregate!');
  END IF;

  -- Initial part of SQL statement
  lv2_sql := 'UPDATE ' || EcDp_ClassMeta.getClassViewName(p_to_class_name) || ' d SET ';
  lv2_set := '(';
  lv2_subselect := '(SELECT ';

  -------------------------------------
  -- Populate columns in SET clause
  -------------------------------------
  OPEN EcDp_ClassMeta.c_intersect_columns(p_from_class_name, p_to_class_name, 'N');
  FETCH EcDp_ClassMeta.c_intersect_columns INTO lv2_col;

  IF EcDp_ClassMeta.c_intersect_columns%NOTFOUND THEN
    CLOSE EcDp_ClassMeta.c_intersect_columns;
    RAISE_APPLICATION_ERROR(-20000,'No common data columns found for given classes.');
  END IF;

  LOOP

    lv2_datatype := EcDp_ClassMeta.getClassAttributeDataType(p_to_class_name,lv2_col);

    IF lv2_datatype IN ('INTEGER','NUMBER') THEN

        lv2_uom := EcDp_ClassMeta.getUomCode(p_to_class_name,lv2_col);

        IF lb_first THEN
          lv2_set := lv2_set || lv2_col;
        ELSE
          lv2_set := lv2_set || ',' || lv2_col;
          lv2_subselect := lv2_subselect || ',';
        END IF;

        -- Special handling of UOM code like %RATE%. All records should be input to the average function
        -- regardless of on_stream_hrs because rate averages has already been compensated for on time hours
        IF lv2_uom LIKE '%RATE%' or lv2_uom LIKE '%FRAC%' or lv2_uom LIKE '%PCT%' THEN
          IF lb_onstrm_exist_from_class THEN
            lv2_subselect := lv2_subselect || 'Sum(Decode(on_stream_hrs, NULL,1, 0,0, 1) * ' || lv2_col || ')' ||
                                            '/(Sum(Decode(on_stream_hrs, NULL,1, 0, 1,1) * Decode( ' || lv2_col || ',NULL,0,1)))';
          ELSE
            lv2_subselect := lv2_subselect || 'Avg(' || lv2_col || ')';
          END IF;

        ELSIF lv2_uom LIKE '%DURATION%' THEN
          IF p_aggr_method = 'FIRST_ROW' THEN
            lv2_subselect := lv2_subselect || to_char(24/p_period_hrs) || '*' || lv2_col;
          ELSE
            lv2_subselect := lv2_subselect || 'Sum(' || lv2_col || ')';
          END IF;
        ELSIF lv2_uom LIKE '%VOL%' OR lv2_uom LIKE '%MASS%' OR lv2_uom LIKE '%ENERGY%' OR lv2_uom LIKE '%POWER%' THEN
          IF p_aggr_method = 'FIRST_ROW' THEN
            lv2_subselect := lv2_subselect || to_char(24/p_period_hrs) || '*' || lv2_col;
          ELSE
            IF lb_onstrm_exist_from_class THEN
               lv2_subselect := lv2_subselect || 'Sum(Decode(on_stream_hrs, NULL,1 ,0,0, 1) * ' || lv2_col || ')';
            ELSE
               lv2_subselect := lv2_subselect || 'Sum(' || lv2_col || ')';
            END IF;
          END IF;

       ELSE
         IF p_aggr_method = 'FIRST_ROW' THEN
           lv2_subselect := lv2_subselect || lv2_col;
         ELSIF p_aggr_method = 'ON_STREAM' THEN
           IF lb_onstrm_exist_from_class THEN
             lv2_subselect := lv2_subselect ||  'Decode(Sum(on_stream_hrs * Decode( ' || lv2_col || ',NULL,0,1) ), 0,Round(Avg('|| lv2_col ||' ),5), '||
             '  Sum(' || lv2_col || ' * on_stream_hrs)/Sum(on_stream_hrs * Decode( ' || lv2_col || ',NULL,0,1) ))';
           ELSE
             lv2_subselect := lv2_subselect || 'Avg(' || lv2_col || ')';
           END IF;
         ELSIF p_aggr_method = 'NOT_DOWN' THEN
           lv2_subselect := lv2_subselect || 'Avg(Decode(Sign(on_stream_hrs-'|| p_period_hrs ||'),0,' || lv2_col || ',NULL))';
         ELSE
           lv2_subselect := lv2_subselect || 'Avg(' || lv2_col || ')';
         END IF;
       END IF;

       IF lb_first THEN
         lb_first := FALSE;
       END IF;

    END IF;

    FETCH EcDp_ClassMeta.c_intersect_columns INTO lv2_col;
    IF EcDp_ClassMeta.c_intersect_columns%NOTFOUND THEN
      IF p_aggr_datetime IS NULL THEN
        -- single aggregate, thus create its own aggr. datetime
        lv2_aggr_datetime := to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy-mm-dd"T"hh24:mi:ss');
      ELSE
        -- aggregate all, thus share the given aggr. datetime
        lv2_aggr_datetime := p_aggr_datetime;
      END IF;
      lv2_set := lv2_set || ', REV_TEXT';
      lv2_subselect := lv2_subselect || ', ''Updated by aggregation routine at '' || ''' || lv2_aggr_datetime || '''';
      lv2_set := lv2_set || ') = ';
      EXIT;
    END IF;

  END LOOP;

  CLOSE EcDp_ClassMeta.c_intersect_columns;


  -----------------------------------
  -- Build sub-select statement
  -----------------------------------
  lv2_subselect:= lv2_subselect || ' FROM ' || EcDp_ClassMeta.getClassViewName(p_from_class_name) || ' WHERE ';
  FOR lc_keyCol IN EcDp_ClassMeta.c_intersect_columns(p_from_class_name, p_to_class_name, 'Y') LOOP
    IF UPPER(lc_keyCol.attribute_name) <> 'DAYTIME' THEN
      lv2_subselect := lv2_subselect || lc_keyCol.attribute_name || '=d.' || lc_keyCol.attribute_name || ' AND ';
    END IF;
  END LOOP;
  IF p_aggr_method = 'FIRST_ROW' THEN
  lv2_subselect := lv2_subselect || ' daytime IN (SELECT Min(daytime) FROM ' || EcDp_ClassMeta.getClassViewName(p_from_class_name) || ' WHERE object_id=d.object_id AND production_day=d.daytime) AND ';
  END IF;
  lv2_subselect := lv2_subselect || 'production_day=d.daytime )';

  -- Populate WHERE clause
  lv2_where := ' WHERE object_id=''' || p_object_id || ''' AND daytime=to_date('''||to_char(p_daytime,'yyyy-mm-dd')||''',''yyyy-mm-dd'')';

  IF p_from_class_name = 'IWEL_SUB_DAY_STATUS_GAS' THEN
      lv2_inj_type :='GI';
  ELSIF p_from_class_name = 'IWEL_SUB_DAY_STATUS_WAT' THEN
      lv2_inj_type :='WI';
  ELSIF p_from_class_name = 'IWEL_SUB_DAY_STATUS_STM' THEN
      lv2_inj_type :='SI';
  ELSE
      lv2_inj_type := NULL;
  END IF;

  instantiateDay(p_to_class_name, p_object_id, p_daytime,lv2_inj_type);

  -- Execute procedure
  lv2_sql := lv2_sql || lv2_set || lv2_subselect || lv2_where;
  lv2_result := executeStatement(lv2_sql);
  IF lv2_result IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000,'Aggregation job failed to execute. Error message: ' || chr(10) || lv2_result);
  END IF;

  RETURN lv2_result;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : aggregateAllSubDaily
-- Description    :
--
-- Preconditions  : Object_id and daytime must uniquely identify the target (daily) row.
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: aggregateSubDaily
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION aggregateAllSubDaily(
  p_from_class_name    VARCHAR2,
  p_to_class_name      VARCHAR2,
  p_object_id          VARCHAR2,
  p_facility_id        VARCHAR2,
  p_daytime            DATE,
  p_period_hrs         NUMBER,
  p_aggr_method        VARCHAR2 DEFAULT 'ON_STREAM',
  p_access_level       NUMBER,
  p_strm_set           VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_result          VARCHAR2(4000);
  TYPE cur_typ        IS REF CURSOR;
  cur cur_typ;
  lv2_object_id       VARCHAR2(32);
  lv2_obj_ver_tab     VARCHAR2(32);
  lv2_instrument_type VARCHAR2(32);
  lv2_stream_phase    VARCHAR2(32);
  lv2_flowline_type   VARCHAR2(32);
  lv2_well_type       VARCHAR2(100);
  p_daytime_tomorrow  DATE;
  cur_sql             VARCHAR2(4000);
  lv2_aggr_datetime   VARCHAR2(32) := to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy-mm-dd"T"hh24:mi:ss');
  lv2_inj_type        VARCHAR2(2);
  ld_end_date         DATE;
  lv_record_status    VARCHAR2(2);

BEGIN

   lv2_obj_ver_tab := ec_class_cnfg.db_object_attribute(EcDp_ClassMeta.OwnerClassName(p_from_class_name));
   ld_end_date := p_daytime + 1;

   IF lv2_obj_ver_tab = 'WEBO_INTERVAL_VERSION' THEN

      cur_sql := 'SELECT wbi.OBJECT_ID '||
                 'FROM WEBO_INTERVAL wbi, WEBO_INTERVAL_VERSION wbiv, WEBO_BORE wb, well_version wellver, WEBO_VERSION wbv '||
                       'WHERE wbi.WELL_BORE_ID = wb.OBJECT_ID AND '||
                             'wb.WELL_ID = wellver.OBJECT_ID AND '||
                             'wb.object_ID = wbv.OBJECT_ID AND '||
                             'wellver.ISNOTOTHER = ''Y'' AND '|| --well_class in ('P','I','PI')
                             'wbi.OBJECT_ID = wbiv.OBJECT_ID AND '||
                             'wbiv.INTERVAL_TYPE = ''DIACS'' AND '|| -- DIACS type only
                             'wellver.OP_FCTY_CLASS_1_ID = '''||p_facility_id||
                             ''' AND (NVL(wbiv.END_DATE, '''||ld_end_date||''') > '''||p_daytime||''')'||
                             ' and (wellver.END_DATE is null or wellver.END_DATE > ''' || p_daytime || ''')' ||
                             ' and (wbv.END_DATE is null or wbv.END_DATE > ''' || p_daytime || ''')' ||
                             ' AND wbiv.DAYTIME = (SELECT MAX(DAYTIME) FROM WEBO_INTERVAL_VERSION'|| -- get the correct daytime
                                                    ' WHERE OBJECT_ID = wbiv.OBJECT_ID'||
                                                    ' AND DAYTIME <= '''||p_daytime||''')';

   ELSIF lv2_obj_ver_tab = 'WELL_VERSION' THEN

      lv2_instrument_type := ec_well_version.instrumentation_type(p_object_id, p_daytime, '<=');
      p_daytime_tomorrow  := p_daytime + 1;

      CASE p_from_class_name
         WHEN 'PWEL_SUB_DAY_STATUS' THEN
            lv2_well_type := '(''OP'', ''GP'', ''CP'', ''WP'', ''WS'', ''OPGI'', ''GPI'', ''OPSI'',''GP2'')';

         WHEN 'PWEL_SUB_DAY_STATUS_2' THEN
            lv2_well_type := '(''OP'', ''GP'', ''CP'', ''WP'', ''WS'', ''OPGI'', ''GPI'', ''OPSI'',''GP2'')';

         WHEN 'IWEL_SUB_DAY_STATUS_GAS' THEN
            lv2_well_type := '(''GI'',''WG'',''OPGI'',''GPI'',''SWG'')';
            lv2_inj_type := 'GI';

         WHEN 'IWEL_SUB_DAY_STATUS_WAT' THEN
            lv2_well_type := '(''WI'',''WG'',''WSI'',''SWG'')';
            lv2_inj_type := 'WI';

         WHEN 'IWEL_SUB_DAY_STATUS_STM' THEN
            lv2_well_type := '(''SI'',''OPSI'',''WSI'')';
            lv2_inj_type := 'SI';

      END CASE;

      cur_sql := 'SELECT OBJECT_ID FROM '||lv2_obj_ver_tab||
                 ' wv WHERE OP_FCTY_CLASS_1_ID = '''||p_facility_id||
                 ''' AND WELL_TYPE IN '||lv2_well_type|| -- same well type (same class) and not abandoned well
                 ' AND (NVL(END_DATE, '''||ld_end_date||''') > '''||p_daytime||''')'||
                 ' AND wv.DAYTIME <= '''||p_daytime||'''' ||
				         ' AND ((wv.isinjector = ''Y''' ||
							           ' AND NVL(ec_iwel_period_status.active_well_status(wv.object_id, '''||p_daytime_tomorrow||''', '''||lv2_inj_type||''', ''EVENT'', ''<''),''OPEN'') <> ''CLOSED_LT'') '||
							         ' OR (wv.isproducer = ''Y''' ||
							           ' AND NVL(ec_pwel_period_status.active_well_status(wv.object_id, '''||p_daytime_tomorrow||''', ''EVENT'', ''<''),''OPEN'') <> ''CLOSED_LT'')) ';

      IF p_from_class_name = 'PWEL_SUB_DAY_STATUS' THEN
         cur_sql := cur_sql || ' AND INSTRUMENTATION_TYPE = '''||lv2_instrument_type||'''';
      ELSIF p_from_class_name = 'PWEL_SUB_DAY_STATUS_2' THEN
         cur_sql := cur_sql || ' AND INSTRUMENTATION_TYPE = '''||lv2_instrument_type||'''';
      END IF;

   ELSIF lv2_obj_ver_tab = 'STRM_VERSION' THEN -- stream
	IF p_strm_set is NULL THEN
      lv2_stream_phase := ec_strm_version.stream_phase(p_object_id ,p_daytime , '<=');

      cur_sql := 'SELECT OBJECT_ID FROM '||lv2_obj_ver_tab||
                 ' sv WHERE OP_FCTY_CLASS_1_ID = '''||p_facility_id||
                 ''' AND STREAM_TYPE = ''M'''|| --only measured stream
                 ' AND AGGREGATE_FLAG = ''Y'''|| -- aggregate flag must be set to Yes
                 ' AND STREAM_PHASE = '''||lv2_stream_phase|| --same phase (same class)
                 ''' AND (NVL(END_DATE, '''||ld_end_date||''') > '''||p_daytime||''')'||
                 ' AND DAYTIME = (SELECT MAX(DAYTIME) FROM '||lv2_obj_ver_tab||
                                   ' WHERE OP_FCTY_CLASS_1_ID = '''||p_facility_id||
                                   ''' AND OBJECT_ID = sv.OBJECT_ID'||
                                   ' AND DAYTIME <= '''||p_daytime||''')';

	ELSE
	  cur_sql := 'SELECT OBJECT_ID FROM '||lv2_obj_ver_tab||
                 ' sv WHERE OP_FCTY_CLASS_1_ID = '''||p_facility_id||
                 ''' AND STREAM_TYPE = ''M'''|| --only measured stream
                 ' AND AGGREGATE_FLAG = ''Y'''|| -- aggregate flag must be set to Yes
                 ' AND EXISTS (SELECT 1 FROM STRM_SET_LIST b WHERE b.OBJECT_ID = sv.OBJECT_ID AND b.STREAM_SET = '''||p_strm_set||
                 ''' AND '''||p_daytime||''' >= FROM_DATE and '''||p_daytime||''' < NVL(END_DATE,('''||ld_end_date||''')))'||
                 ' AND (NVL(END_DATE, '''||ld_end_date||''') > '''||p_daytime||''')'||
                 ' AND DAYTIME = (SELECT MAX(DAYTIME) FROM '||lv2_obj_ver_tab||
                                   ' WHERE OP_FCTY_CLASS_1_ID = '''||p_facility_id||
                                   ''' AND OBJECT_ID = sv.OBJECT_ID'||
                                   ' AND DAYTIME <= '''||p_daytime||''')';
    END IF;

   ELSIF lv2_obj_ver_tab = 'FLWL_VERSION' THEN -- flowline

      lv2_flowline_type := ec_flwl_version.flowline_type(p_object_id, p_daytime, '<=');

      cur_sql := 'SELECT OBJECT_ID FROM '||lv2_obj_ver_tab||
                 ' fv WHERE OP_FCTY_CLASS_1_ID = '''||p_facility_id||
                 ''' AND FLOWLINE_TYPE = '''||lv2_flowline_type|| --same flowline type (same class)
                 ''' AND AGGREGATE_FLAG = ''Y'''|| -- aggregate flag must be set to Yes
                 ' AND (NVL(END_DATE, '''||ld_end_date||''') > '''||p_daytime||''')'||
                 ' AND DAYTIME = (SELECT MAX(DAYTIME) FROM '||lv2_obj_ver_tab||
                                   ' WHERE OP_FCTY_CLASS_1_ID = '''||p_facility_id||
                                   ''' AND OBJECT_ID = fv.OBJECT_ID'||
                                   ' AND DAYTIME <= '''||p_daytime||''')';

   ELSE -- production separator

      cur_sql := 'SELECT OBJECT_ID FROM '||lv2_obj_ver_tab||
                 ' psv WHERE OP_FCTY_CLASS_1_ID = '''||p_facility_id||
                 ''' AND EC_SEPARATOR.CLASS_NAME(OBJECT_ID)=''PRODSEPARATOR' ||
                 ''' AND AGGREGATE_FLAG = ''Y'''|| -- aggregate flag must be set to Yes
                 ' AND (NVL(END_DATE, '''||ld_end_date||''') > '''||p_daytime||''')'||
                 ' AND DAYTIME = (SELECT MAX(DAYTIME) FROM '||lv2_obj_ver_tab||
                                   ' WHERE OP_FCTY_CLASS_1_ID = '''||p_facility_id||
                                   ''' AND OBJECT_ID = psv.OBJECT_ID'||
                                   ' AND DAYTIME <= '''||p_daytime||''')';

   END IF;

   OPEN cur FOR

     cur_sql;

   LOOP
      FETCH cur INTO lv2_object_id;
      EXIT WHEN cur%NOTFOUND;

	  lv_record_status := EcDp_Subdaily_Utilities.checkRecordStatus(p_daytime,lv2_object_id,p_to_class_name);

	  IF (p_access_level >= 60) THEN

        lv2_result := ecbp_aggregate.aggregateSubDaily(p_from_class_name, p_to_class_name, lv2_object_id, p_daytime, p_period_hrs, p_aggr_method, lv2_aggr_datetime);

        IF lv2_result IS NOT NULL THEN
          RAISE_APPLICATION_ERROR(-20000,'Aggregation job failed to execute. Error message: ' || chr(10) || lv2_result);
          EXIT; -- exit loop if error is encountered
        END IF;

      ELSIF (p_access_level >= 50) AND lv_record_status IN ('V', 'P') THEN
        lv2_result := ecbp_aggregate.aggregateSubDaily(p_from_class_name, p_to_class_name, lv2_object_id, p_daytime, p_period_hrs, p_aggr_method, lv2_aggr_datetime);

        IF lv2_result IS NOT NULL THEN
          RAISE_APPLICATION_ERROR(-20000,'Aggregation job failed to execute. Error message: ' || chr(10) || lv2_result);
          EXIT; -- exit loop if error is encountered
        END IF;

      ELSIF (p_access_level = 40) AND (lv_record_status = 'P') THEN

        lv2_result := ecbp_aggregate.aggregateSubDaily(p_from_class_name, p_to_class_name, lv2_object_id, p_daytime, p_period_hrs, p_aggr_method, lv2_aggr_datetime);

        IF lv2_result IS NOT NULL THEN
          RAISE_APPLICATION_ERROR(-20000,'Aggregation job failed to execute. Error message: ' || chr(10) || lv2_result);
          EXIT; -- exit loop if error is encountered
        END IF;

	  END IF;

   END LOOP;
   CLOSE cur;

   IF lv2_result IS NOT NULL THEN
     RAISE_APPLICATION_ERROR(-20000,'Aggregation job failed to execute. Error message: ' || chr(10) || lv2_result);
   END IF;

   RETURN lv2_result;

END;

END EcBp_Aggregate;