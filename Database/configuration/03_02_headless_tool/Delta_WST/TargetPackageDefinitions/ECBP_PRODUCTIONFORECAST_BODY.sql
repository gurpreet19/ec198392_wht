CREATE OR REPLACE PACKAGE BODY EcBp_ProductionForecast IS
/****************************************************************
** Package        :  EcBp_ProductionForecast, body part
**
** $Revision: 1.11.24.1 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 19.04.2007 Arief Zaki
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------
** 19.04.2007  zakiiari ECPD-3905: Initial version
** 21.08.2008  rajarsar ECPD-9477: Added dynCursorGetFcstScenNo and updated getRecentProdForecastNo
** 10.04.2009  oonnnng  ECPD-6067: Modified function validateMonthLock,
**                                                   copyToScenarioForCurrent, copyToScenarioForParent,
**                                                   copyFromForecastForCurrent, copyFromForecastForParent
**                                     for local lock checking
** 11.05.2015  kumarsur ECPD-27887: Modified dynCursorGetFcstScenNo.
**
*****************************************************************/

CURSOR c_exist_prod_fcst(cp_effective_daytime DATE, cp_fcst_type VARCHAR2, cp_fcst_scenario VARCHAR2) IS
  SELECT *
  FROM prod_forecast pf
  WHERE pf.daytime = cp_effective_daytime AND
        pf.forecast_type = cp_fcst_type AND
        pf.scenario = cp_fcst_scenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateMonthLock (LOCAL)
-- Description    : return error if the target effective date is within month locked
---------------------------------------------------------------------------------------------------
PROCEDURE validateMonthLock(p_tgt_effective_date DATE, p_procedure VARCHAR2, p_object_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
BEGIN
  IF EcDp_Month_lock.withinLockedMonth(p_tgt_effective_date) IS NOT NULL THEN
    EcDp_Month_lock.raiseValidationError('INSERTING/UPDATING', p_tgt_effective_date, p_tgt_effective_date, trunc(p_tgt_effective_date,'MONTH'), p_procedure || ': Cannot copy into a forecast effective date''s locked month');
  END IF;

  EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_object_id,
                                 p_tgt_effective_date, p_tgt_effective_date,
                                 'INSERTING/UPDATING', p_procedure || ': Cannot copy into a forecast effective date''s local locked month');
END validateMonthLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFcstTable (LOCAL)
-- Description    : return physical forecast table name based on given object class
---------------------------------------------------------------------------------------------------
FUNCTION getFcstTable(p_class_name VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv_fcst_data_tab      VARCHAR2(40);

BEGIN

  IF p_class_name = 'FCTY_CLASS_1' OR p_class_name = 'FCTY_CLASS_2' THEN
    lv_fcst_data_tab := 'PROD_FCTY_FORECAST';

  ELSIF p_class_name = 'WELL' THEN
    lv_fcst_data_tab := 'PROD_WELL_FORECAST';

  ELSIF p_class_name = 'STREAM' THEN
    lv_fcst_data_tab := 'PROD_STRM_FORECAST';

  ELSIF p_class_name = 'AREA' THEN
    lv_fcst_data_tab := 'PROD_AREA_FORECAST';

  ELSIF p_class_name = 'SUB_AREA' THEN
    lv_fcst_data_tab := 'PROD_SUB_AREA_FORECAST';

  ELSIF p_class_name = 'FIELD' THEN
    lv_fcst_data_tab := 'PROD_FIELD_FORECAST';

  ELSIF p_class_name = 'SUB_FIELD' THEN
    lv_fcst_data_tab := 'PROD_SUB_FIELD_FORECAST';

  ELSIF p_class_name = 'PRODUCTIONUNIT' THEN
    lv_fcst_data_tab := 'PROD_PRODUNIT_FORECAST';

  ELSIF p_class_name = 'PROD_SUB_UNIT' THEN
    lv_fcst_data_tab := 'PROD_SUB_PRODUNIT_FORECAST';

  ELSIF p_class_name = 'STORAGE' THEN
    lv_fcst_data_tab := 'PROD_STORAGE_FORECAST';

  END IF;

  RETURN lv_fcst_data_tab;

END getFcstTable;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFcstChildVersionTable (LOCAL)
-- Description    : return physical version table based on given object class
---------------------------------------------------------------------------------------------------
FUNCTION getFcstChildVersionTable(p_child_class VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN ec_class_db_mapping.db_object_attribute(p_child_class);

END getFcstChildVersionTable;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFcstParentCol (LOCAL)
-- Description    : return physical parent column based on given object class (excluding prefix: op_ and geo_ )
---------------------------------------------------------------------------------------------------
FUNCTION getFcstParentCol(p_parent_class VARCHAR2, p_group_type VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv_obj_parent_col VARCHAR2(40);
BEGIN

  -- parent column
  IF p_parent_class = 'FCTY_CLASS_1' THEN
    lv_obj_parent_col := 'fcty_class_1_id';

  ELSIF p_parent_class = 'FCTY_CLASS_2' THEN
    lv_obj_parent_col := 'fcty_class_2_id';

  ELSIF p_parent_class = 'SUB_AREA' THEN
    lv_obj_parent_col := 'sub_area_id';

  ELSIF p_parent_class = 'AREA' THEN
    lv_obj_parent_col := 'area_id';

  ELSIF p_parent_class = 'FIELD' THEN
    lv_obj_parent_col := 'field_id';

  ELSIF p_parent_class = 'SUB_FIELD' THEN
    lv_obj_parent_col := 'sub_field_id';

  ELSIF p_parent_class = 'PRODUCTIONUNIT' THEN
    lv_obj_parent_col := 'pu_id';

  ELSIF p_parent_class = 'PROD_SUB_UNIT' THEN
    lv_obj_parent_col := 'sub_pu_id';

  ELSIF p_parent_class = 'WELL_HOOKUP' THEN
    lv_obj_parent_col := 'well_hookup_id';

  END IF;

  -- group type
  IF lower(p_group_type) = 'operational' THEN
    lv_obj_parent_col := 'op_' || lv_obj_parent_col;
  ELSE
    lv_obj_parent_col := 'geo_' || lv_obj_parent_col;
  END IF;

  RETURN lv_obj_parent_col;

END getFcstParentCol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateTargetDataCTS (LOCAL)
-- Description    : return error if the target data contains non-Provisional records
---------------------------------------------------------------------------------------------------
PROCEDURE validateTargetDataCTS(p_tgt_fcst_scen_no    NUMBER,
                                p_object_id           VARCHAR2)
--</EC-DOC>
IS
  lv_sql               VARCHAR2(2000);
  lv_fcst_data_tab     VARCHAR2(100);
  lv_class             VARCHAR2(100) := ecdp_objects.GetObjClassName(p_object_id);
  ln_count             NUMBER;

BEGIN
  -- forecast data table
  lv_fcst_data_tab := getFcstTable(lv_class);

  -- Generating the following cursor's body
  -- select count(*) from prod_well_forecast pwf
  -- where pwf.FCST_SCEN_NO=2
  --       and pwf.RECORD_STATUS <> 'P'
  --       and pwf.OBJECT_ID='45404508EF804E4D9C81A1AA5B10271E'

  lv_sql := 'SELECT count(*) FROM ' || lv_fcst_data_tab || ' f';
  lv_sql := lv_sql || ' WHERE f.object_id=''' || p_object_id || ''' AND f.fcst_scen_no=' || p_tgt_fcst_scen_no || ' AND';
  lv_sql := lv_sql || ' f.record_status <> ''P''';

  ln_count := ecdp_dynsql.execute_singlerow_number(lv_sql);

  IF ln_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20603, 'Copy functionality cannot be performed on the set of forecast data that has been approved or verified.');
  END IF;

END validateTargetDataCTS;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateTargetDataCFF (LOCAL)
-- Description    : return error if the target data contains non-Provisional records
---------------------------------------------------------------------------------------------------
PROCEDURE validateTargetDataCFF(p_tgt_fcst_scen_no    NUMBER,
                                p_tgt_effective_date  DATE,
                                p_object_id           VARCHAR2)
--</EC-DOC>
IS
  lv_sql               VARCHAR2(2000);
  lv_fcst_data_tab     VARCHAR2(100);
  lv_class             VARCHAR2(100) := ecdp_objects.GetObjClassName(p_object_id);
  lv_effective_date    VARCHAR2(40);
  ln_count             NUMBER;

BEGIN
  lv_effective_date := to_char(p_tgt_effective_date,'YYYY-MM-DD"T"HH24:MI:SS');

  -- forecast data table
  lv_fcst_data_tab := getFcstTable(lv_class);

  -- Generating the following cursor's body
  -- select count(*) from prod_well_forecast pwf
  -- where pwf.FCST_SCEN_NO=2
  --       and pwf.RECORD_STATUS <> 'P'
  --       and pwf.OBJECT_ID='45404508EF804E4D9C81A1AA5B10271E'
  --       and pwf.DAYTIME >= tgt_date

  lv_sql := 'SELECT count(*) FROM ' || lv_fcst_data_tab || ' f';
  lv_sql := lv_sql || ' WHERE f.object_id=''' || p_object_id || ''' AND f.fcst_scen_no=' || p_tgt_fcst_scen_no || ' AND';
  lv_sql := lv_sql || ' f.daytime>=to_date(''' || lv_effective_date || ''',''YYYY-MM-DD"T"HH24:MI:SS'') AND ';
  lv_sql := lv_sql || ' f.record_status <> ''P''';

  ln_count := ecdp_dynsql.execute_singlerow_number(lv_sql);

  IF ln_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20603, 'Copy functionality cannot be performed on the set of forecast data that have been approved or verified.');
  END IF;

END validateTargetDataCFF;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : dynCursorGetChild (LOCAL)
-- Description    : return cursor that has the childs of the given object
---------------------------------------------------------------------------------------------------
PROCEDURE dynCursorGetChild(p_crs                 IN OUT rc_fcst_data,
                            p_src_fcst_scen_no    NUMBER,
                            p_parent_object_id    VARCHAR2,
                            p_child_class         VARCHAR2,
                            p_fromdate            DATE,
                            p_todate              DATE,
                            p_group_type          VARCHAR2)
--</EC-DOC>
IS
  lv_sql               VARCHAR2(2000);
  lv_sql_more          VARCHAR2(2000);
  lv_fcst_data_tab     VARCHAR2(100);
  lv_child_ver_tab     VARCHAR2(100);
  lv_obj_parent_col    VARCHAR2(100);
  lv_parent_class      VARCHAR2(100) := ecdp_objects.GetObjClassName(p_parent_object_id);
  lv_fromdate          VARCHAR2(50) := to_char(p_fromdate, 'YYYY-MM-DD"T"HH24:MI:SS');
  lv_todate            VARCHAR2(50) := to_char(p_todate, 'YYYY-MM-DD"T"HH24:MI:SS');

BEGIN
  -- forecast data table and object's version table
  lv_fcst_data_tab := getFcstTable(p_child_class);
  lv_child_ver_tab := getFcstChildVersionTable(p_child_class);
  lv_obj_parent_col := getFcstParentCol(lv_parent_class,p_group_type);

  IF p_child_class = 'FCTY_CLASS_1' THEN
    lv_sql_more := lv_sql_more || ' AND f.class_name=''PROD_FCTY1_FORECAST''';
  ELSIF p_child_class = 'FCTY_CLASS_2' THEN
    lv_sql_more := lv_sql_more || ' AND f.class_name=''PROD_FCTY2_FORECAST''';
  END IF;


  -- Generating the following cursor's body
  -- CURSOR c_well_obj(cp_src_fcst_scen_no NUMBER) IS
  --  SELECT distinct pwf.object_id
  --  FROM prod_well_forecast pwf, well_version wv
  --  WHERE pwf.object_id = wv.object_id
  --        AND pwf.fcst_scen_no = cp_src_fcst_scen_no
  --        AND wv.op_fcty_class_1_id = p_parent_object_id
  --        AND p_todate >= wv.daytime
  --        AND p_fromdate < nvl(wv.end_date, p_fromdate+1);

  lv_sql := 'SELECT distinct f.object_id FROM ' || lv_fcst_data_tab || ' f,' || lv_child_ver_tab || ' v';
  lv_sql := lv_sql || ' WHERE f.object_id=v.object_id AND f.fcst_scen_no=' || p_src_fcst_scen_no;
  lv_sql := lv_sql || ' AND v.' || lv_obj_parent_col || '=''' || p_parent_object_id || '''';
  lv_sql := lv_sql || ' AND to_date(''' || lv_todate || ''', ''YYYY-MM-DD"T"HH24:MI:SS'') >= v.daytime';
  lv_sql := lv_sql || ' AND to_date(''' || lv_fromdate || ''', ''YYYY-MM-DD"T"HH24:MI:SS'') < nvl(v.end_date, to_date(''' || lv_fromdate || ''', ''YYYY-MM-DD"T"HH24:MI:SS'')+1)';

  -- special case
  IF lv_sql_more IS NOT NULL THEN
    lv_sql := lv_sql || lv_sql_more;
  END IF;

  OPEN p_crs FOR lv_sql;

END dynCursorGetChild;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : dynCursorGetObject (LOCAL)
-- Description    : return cursor that has all objects of the given class
---------------------------------------------------------------------------------------------------
PROCEDURE dynCursorGetObject(p_crs               IN OUT rc_fcst_data,
                             p_src_fcst_scen_no  NUMBER,
                             p_obj_class         VARCHAR2)
--</EC-DOC>
IS
  lv_sql               VARCHAR2(2000);
  lv_sql_more          VARCHAR2(2000);
  lv_fcst_data_tab     VARCHAR2(100);

BEGIN
  -- forecast data table
  lv_fcst_data_tab := getFcstTable(p_obj_class);

  IF p_obj_class = 'FCTY_CLASS_1' THEN
    lv_sql_more := lv_sql_more || ' AND f.class_name=''PROD_FCTY1_FORECAST''';
  ELSIF p_obj_class = 'FCTY_CLASS_2' THEN
    lv_sql_more := lv_sql_more || ' AND f.class_name=''PROD_FCTY2_FORECAST''';
  END IF;

  -- Generating the following cursor's body
  -- CURSOR c_well_obj(cp_src_fcst_scen_no NUMBER) IS
  --  SELECT distinct pwf.object_id
  --  FROM prod_well_forecast pwf
  --  WHERE pwf.fcst_scen_no = cp_src_fcst_scen_no;

  lv_sql := 'SELECT distinct f.object_id FROM ' || lv_fcst_data_tab || ' f ';
  lv_sql := lv_sql || 'WHERE f.fcst_scen_no=' || p_src_fcst_scen_no;

  -- special case
  IF lv_sql_more IS NOT NULL THEN
    lv_sql := lv_sql || lv_sql_more;
  END IF;

  OPEN p_crs FOR lv_sql;

END dynCursorGetObject;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : dynCursorUpdObject (LOCAL)
-- Description    : return cursor that has rows which will be updated in the target table
---------------------------------------------------------------------------------------------------
PROCEDURE dynCursorUpdObjectCTS(p_crs                 IN OUT rc_fcst_data,
                             p_src_fcst_scen_no    NUMBER,
                             p_tgt_fcst_scen_no    NUMBER,
                             p_object_id           VARCHAR2)
--</EC-DOC>
IS
  lv_sql               VARCHAR2(2000);
  lv_fcst_data_tab     VARCHAR2(100);
  lv_class             VARCHAR2(100) := ecdp_objects.GetObjClassName(p_object_id);

BEGIN
  -- forecast data table
  lv_fcst_data_tab := getFcstTable(lv_class);

  -- Generating the following cursor's body
  -- Update Cursor: WELL
  --  CURSOR c_well_fcst_upd_data(cp_src_fcst_scen_no NUMBER, cp_object_id VARCHAR2) IS
  --    SELECT *
  --    FROM prod_well_forecast pwf
  --    WHERE pwf.fcst_scen_no = cp_src_fcst_scen_no
  --          AND pwf.object_id = cp_object_id
  --          AND EXISTS (
  --                     SELECT 1 FROM prod_well_forecast pwf2 WHERE pwf2.fcst_scen_no = p_tgt_fcst_scen_no
  --                                                           AND pwf2.object_id = pwf.object_id
  --                                                           AND pwf2.daytime = pwf.daytime
  --                                                           AND pwf2.record_status = 'P'
  --                     );

  lv_sql := 'SELECT * FROM ' || lv_fcst_data_tab || ' f';
  lv_sql := lv_sql || ' WHERE f.object_id=''' || p_object_id || ''' AND f.fcst_scen_no=' || p_src_fcst_scen_no || ' AND';
  lv_sql := lv_sql || ' EXISTS (SELECT 1 FROM ' || lv_fcst_data_tab || ' f2 WHERE f2.fcst_scen_no=' || p_tgt_fcst_scen_no;
  lv_sql := lv_sql || ' AND f2.object_id=f.object_id AND f2.daytime=f.daytime AND f2.record_status=''P''';
  lv_sql := lv_sql || ')';

  OPEN p_crs FOR lv_sql;

END dynCursorUpdObjectCTS;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : dynCursorInsObject (LOCAL)
-- Description    : return cursor that has rows which will be inserted in the target table
---------------------------------------------------------------------------------------------------
PROCEDURE dynCursorInsObjectCTS(p_crs                 IN OUT rc_fcst_data,
                             p_src_fcst_scen_no    NUMBER,
                             p_tgt_fcst_scen_no    NUMBER,
                             p_object_id           VARCHAR2)
--</EC-DOC>
IS
  lv_sql               VARCHAR2(2000);
  lv_fcst_data_tab     VARCHAR2(100);
  lv_class             VARCHAR2(100) := ecdp_objects.GetObjClassName(p_object_id);

BEGIN
  -- forecast data table
  lv_fcst_data_tab := getFcstTable(lv_class);

  -- Generating the following cursor's body
  -- Insert Cursor: WELL
  --  CURSOR c_well_fcst_ins_data(cp_src_fcst_scen_no NUMBER, cp_object_id VARCHAR2) IS
  --    SELECT *
  --    FROM prod_well_forecast pwf
  --    WHERE pwf.fcst_scen_no = cp_src_fcst_scen_no
  --          AND pwf.object_id = cp_object_id
  --          AND NOT EXISTS (
  --                     SELECT 1 FROM prod_well_forecast pwf2 WHERE pwf2.fcst_scen_no = p_tgt_fcst_scen_no
  --                                                           AND pwf2.object_id = pwf.object_id
  --                                                           AND pwf2.daytime = pwf.daytime
  --                     );

  lv_sql := 'SELECT * FROM ' || lv_fcst_data_tab || ' f';
  lv_sql := lv_sql || ' WHERE f.object_id=''' || p_object_id || ''' AND f.fcst_scen_no=' || p_src_fcst_scen_no || ' AND';
  lv_sql := lv_sql || ' NOT EXISTS (SELECT 1 FROM ' || lv_fcst_data_tab || ' f2 WHERE f2.fcst_scen_no=' || p_tgt_fcst_scen_no;
  lv_sql := lv_sql || ' AND f2.object_id=f.object_id AND f2.daytime=f.daytime';
  lv_sql := lv_sql || ')';

  OPEN p_crs FOR lv_sql;

END dynCursorInsObjectCTS;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : dynCursorUpdObject (LOCAL)
-- Description    : return cursor that has rows which will be updated in the target table
---------------------------------------------------------------------------------------------------
PROCEDURE dynCursorUpdObjectCFF(p_crs                 IN OUT rc_fcst_data,
                                p_src_fcst_scen_no    NUMBER,
                                p_tgt_fcst_scen_no    NUMBER,
                                p_tgt_effective_date  DATE,
                                p_object_id           VARCHAR2)
--</EC-DOC>
IS
  lv_sql               VARCHAR2(2000);
  lv_fcst_data_tab     VARCHAR2(100);
  lv_class             VARCHAR2(100) := ecdp_objects.GetObjClassName(p_object_id);
  lv_effective_date    VARCHAR2(40);

BEGIN
  lv_effective_date := to_char(p_tgt_effective_date,'YYYY-MM-DD"T"HH24:MI:SS');

  -- forecast data table
  lv_fcst_data_tab := getFcstTable(lv_class);

  -- Generating the following cursor's body
  -- Update Cursor: WELL
  --  CURSOR c_well_fcst_upd_data(cp_src_fcst_scen_no NUMBER, cp_object_id VARCHAR2) IS
  --    SELECT *
  --    FROM prod_well_forecast pwf
  --    WHERE pwf.fcst_scen_no = cp_src_fcst_scen_no
  --          AND pwf.object_id = cp_object_id
  --          AND pwf.daytime >= cp_effective_date
  --          AND EXISTS (
  --                     SELECT 1 FROM prod_well_forecast pwf2 WHERE pwf2.fcst_scen_no = p_tgt_fcst_scen_no
  --                                                           AND pwf2.object_id = pwf.object_id
  --                                                           AND pwf2.daytime = pwf.daytime
  --                                                           AND pwf2.record_status = 'P'
  --                     );

  lv_sql := 'SELECT * FROM ' || lv_fcst_data_tab || ' f';
  lv_sql := lv_sql || ' WHERE f.object_id=''' || p_object_id || ''' AND f.fcst_scen_no=' || p_src_fcst_scen_no || ' AND f.daytime>=to_date(''' || lv_effective_date || ''',''YYYY-MM-DD"T"HH24:MI:SS'') AND ';
  lv_sql := lv_sql || ' EXISTS (SELECT 1 FROM ' || lv_fcst_data_tab || ' f2 WHERE f2.fcst_scen_no=' || p_tgt_fcst_scen_no;
  lv_sql := lv_sql || ' AND f2.object_id=f.object_id AND f2.daytime=f.daytime AND f2.record_status=''P''';
  lv_sql := lv_sql || ')';

  OPEN p_crs FOR lv_sql;

END dynCursorUpdObjectCFF;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : dynCursorInsObject (LOCAL)
-- Description    : return cursor that has rows which will be inserted in the target table
---------------------------------------------------------------------------------------------------
PROCEDURE dynCursorInsObjectCFF(p_crs                 IN OUT rc_fcst_data,
                                p_src_fcst_scen_no    NUMBER,
                                p_tgt_fcst_scen_no    NUMBER,
                                p_tgt_effective_date  DATE,
                                p_object_id           VARCHAR2)
--</EC-DOC>
IS
  lv_sql               VARCHAR2(2000);
  lv_fcst_data_tab     VARCHAR2(100);
  lv_class             VARCHAR2(100) := ecdp_objects.GetObjClassName(p_object_id);
  lv_effective_date    VARCHAR2(40);

BEGIN
  lv_effective_date := to_char(p_tgt_effective_date,'YYYY-MM-DD"T"HH24:MI:SS');

  -- forecast data table
  lv_fcst_data_tab := getFcstTable(lv_class);

  -- Generating the following cursor's body
  -- Insert Cursor: WELL
  --  CURSOR c_well_fcst_ins_data(cp_src_fcst_scen_no NUMBER, cp_object_id VARCHAR2) IS
  --    SELECT *
  --    FROM prod_well_forecast pwf
  --    WHERE pwf.fcst_scen_no = cp_src_fcst_scen_no
  --          AND pwf.object_id = cp_object_id
  --          AND NOT EXISTS (
  --                     SELECT 1 FROM prod_well_forecast pwf2 WHERE pwf2.fcst_scen_no = p_tgt_fcst_scen_no
  --                                                           AND pwf2.object_id = pwf.object_id
  --                                                           AND pwf2.daytime = pwf.daytime
  --                     );

  lv_sql := 'SELECT * FROM ' || lv_fcst_data_tab || ' f';
  lv_sql := lv_sql || ' WHERE f.object_id=''' || p_object_id || ''' AND f.fcst_scen_no=' || p_src_fcst_scen_no || ' AND f.daytime>=to_date(''' || lv_effective_date || ''',''YYYY-MM-DD"T"HH24:MI:SS'') AND ';
  lv_sql := lv_sql || ' NOT EXISTS (SELECT 1 FROM ' || lv_fcst_data_tab || ' f2 WHERE f2.fcst_scen_no=' || p_tgt_fcst_scen_no;
  lv_sql := lv_sql || ' AND f2.object_id=f.object_id AND f2.daytime=f.daytime';
  lv_sql := lv_sql || ')';

  OPEN p_crs FOR lv_sql;

END dynCursorInsObjectCFF;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : prodFcstCopyToScenario
-- Description    : Create a new Prod_Forecast if not exist, else return the existing one.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : prod_forecast
--
-- Using functions: EcDp_System_Key.assignNextNumber
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE prodFcstCopyToScenario(p_tgt_scenario  VARCHAR2,
                                 p_src_scenario  VARCHAR2,
                                 p_src_fcst_type VARCHAR2,
                                 p_src_date      DATE,
                                 p_user          VARCHAR2,
                                 po_tgt_fcst_scen_no OUT NUMBER)
--</EC-DOC>
IS
  ln_tgt_prod_scen_no    PROD_FORECAST.FCST_SCEN_NO%TYPE;
  ld_now                 DATE := ecdp_date_time.getCurrentSysdate;

  TYPE t_prod_fcst       IS TABLE OF prod_forecast%ROWTYPE;
  l_prod_fcst            t_prod_fcst;

BEGIN


  -- check prod_forecast, whether forecast that match <effective_date:fcst_type:fcst-scenario> exist
  FOR cur_rec IN c_exist_prod_fcst(p_src_date,p_src_fcst_type,p_tgt_scenario) LOOP
    ln_tgt_prod_scen_no := cur_rec.fcst_scen_no;
  END LOOP;

  IF ln_tgt_prod_scen_no IS NULL THEN
    -- no prod-forecast yet
    OPEN c_exist_prod_fcst(p_src_date,p_src_fcst_type,p_src_scenario);
      LOOP
      FETCH c_exist_prod_fcst BULK COLLECT INTO l_prod_fcst LIMIT 2;
        FOR i IN 1..l_prod_fcst.COUNT LOOP
          EcDp_System_Key.assignNextNumber('PROD_FORECAST',l_prod_fcst(i).fcst_scen_no);
          ln_tgt_prod_scen_no := l_prod_fcst(i).fcst_scen_no;
          l_prod_fcst(i).forecast_type := p_src_fcst_type;
          l_prod_fcst(i).scenario := p_tgt_scenario;
          l_prod_fcst(i).daytime := p_src_date;
          l_prod_fcst(i).created_by := p_user;
          l_prod_fcst(i).created_date := ld_now;
          l_prod_fcst(i).last_updated_by := NULL;
          l_prod_fcst(i).last_updated_date := NULL;
          l_prod_fcst(i).rev_text := NULL;
          -- so, create new prod-forecast
          INSERT INTO prod_forecast VALUES l_prod_fcst(i);

        END LOOP;

        EXIT WHEN c_exist_prod_fcst%NOTFOUND;
      END LOOP;
    CLOSE c_exist_prod_fcst;
  END IF;

  po_tgt_fcst_scen_no := ln_tgt_prod_scen_no;

END prodFcstCopyToScenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : objFcstCopyToScenario
-- Description    : Copy records of the given object from the source scenario to the given target scenario
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : prod_<object_class>_forecast
--
-- Using functions: ecdp_date_time.getCurrentSysdate
--                  ecdp_objects.GetObjClassName
--                  validateTargetDataCTS
--                  dynCursorUpdObjectCTS
--                  dynCursorInsObjectCTS
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE objFcstCopyToScenario(p_object_id          VARCHAR2,
                                p_src_fcst_scen_no   NUMBER,
                                p_tgt_fcst_scen_no   NUMBER,
                                p_tgt_fcst_scenario  VARCHAR2,
                                p_user               VARCHAR2)
--</EC-DOC>
IS
  lv_object_class        VARCHAR2(32) := ecdp_objects.GetObjClassName(p_object_id);
  ld_now                 DATE := ecdp_date_time.getCurrentSysdate;
  lc_fcst_data           rc_fcst_data;

  -- to utilize FORALL (in UPDATE), have to create separate collection to hold these keys
  TYPE t_object_id       IS TABLE OF VARCHAR2(32);
  TYPE t_fcst_scen_no    IS TABLE OF NUMBER;
  TYPE t_daytime         IS TABLE OF DATE;
  lt_object_id           t_object_id := t_object_id();
  lt_fcst_scen_no        t_fcst_scen_no := t_fcst_scen_no();
  lt_daytime             t_daytime := t_daytime();

  -- declare type for each object here
  TYPE t_prod_well_fcst      IS TABLE OF prod_well_forecast%ROWTYPE;
  TYPE t_prod_strm_fcst      IS TABLE OF prod_strm_forecast%ROWTYPE;
  TYPE t_prod_fcty_fcst      IS TABLE OF prod_fcty_forecast%ROWTYPE;
  TYPE t_prod_area_fcst      IS TABLE OF prod_area_forecast%ROWTYPE;
  TYPE t_prod_sub_area_fcst  IS TABLE OF prod_sub_area_forecast%ROWTYPE;
  TYPE t_prod_field_fcst     IS TABLE OF prod_field_forecast%ROWTYPE;
  TYPE t_prod_sub_field_fcst IS TABLE OF prod_sub_field_forecast%ROWTYPE;
  TYPE t_prod_pu_fcst        IS TABLE OF prod_produnit_forecast%ROWTYPE;
  TYPE t_prod_sub_pu_fcst    IS TABLE OF prod_sub_produnit_forecast%ROWTYPE;
  TYPE t_prod_storage_fcst   IS TABLE OF prod_storage_forecast%ROWTYPE;

  -- declare variable for above type for each object here
  l_prod_well_fcst       t_prod_well_fcst;
  l_prod_strm_fcst       t_prod_strm_fcst;
  l_prod_fcty_fcst       t_prod_fcty_fcst;
  l_prod_area_fcst       t_prod_area_fcst;
  l_prod_sub_area_fcst   t_prod_sub_area_fcst;
  l_prod_field_fcst      t_prod_field_fcst;
  l_prod_sub_field_fcst  t_prod_sub_field_fcst;
  l_prod_pu_fcst         t_prod_pu_fcst;
  l_prod_sub_pu_fcst     t_prod_sub_pu_fcst;
  l_prod_storage_fcst    t_prod_storage_fcst;

BEGIN

  validateTargetDataCTS(p_tgt_fcst_scen_no,p_object_id);

  IF lv_object_class = 'WELL' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_well_fcst LIMIT 1000;
        FOR i IN 1..l_prod_well_fcst.COUNT LOOP
        l_prod_well_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_well_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_well_fcst(i).last_updated_by := p_user;
        l_prod_well_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_well_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_well_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_well_fcst(i).daytime;
      END LOOP;
      IF l_prod_well_fcst.COUNT >0 THEN
        FORALL i IN l_prod_well_fcst.FIRST .. l_prod_well_fcst.LAST
          UPDATE prod_well_forecast SET ROW = l_prod_well_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_well_fcst := t_prod_well_fcst(); --clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_well_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_well_fcst LIMIT 1000;
      FOR i IN 1..l_prod_well_fcst.COUNT LOOP
        l_prod_well_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_well_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_well_fcst(i).created_by := p_user;
        l_prod_well_fcst(i).created_date := ld_now;
        l_prod_well_fcst(i).last_updated_by := NULL;
        l_prod_well_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_well_fcst.COUNT >0 THEN
        FORALL i IN l_prod_well_fcst.FIRST .. l_prod_well_fcst.LAST
          INSERT INTO prod_well_forecast VALUES l_prod_well_fcst(i);
      END IF;
      l_prod_well_fcst := t_prod_well_fcst(); --clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'STREAM' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_strm_fcst LIMIT 1000;
      FOR i IN 1..l_prod_strm_fcst.COUNT LOOP
        l_prod_strm_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_strm_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_strm_fcst(i).last_updated_by := p_user;
        l_prod_strm_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_strm_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_strm_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_strm_fcst(i).daytime;
      END LOOP;
      IF l_prod_strm_fcst.COUNT >0 THEN
        FORALL i IN l_prod_strm_fcst.FIRST .. l_prod_strm_fcst.LAST
          UPDATE prod_strm_forecast SET ROW = l_prod_strm_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_strm_fcst := t_prod_strm_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_strm_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_strm_fcst LIMIT 1000;
      FOR i IN 1..l_prod_strm_fcst.COUNT LOOP
        l_prod_strm_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_strm_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_strm_fcst(i).created_by := p_user;
        l_prod_strm_fcst(i).created_date := ld_now;
        l_prod_strm_fcst(i).last_updated_by := NULL;
        l_prod_strm_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_strm_fcst.COUNT >0 THEN
        FORALL i IN l_prod_strm_fcst.FIRST .. l_prod_strm_fcst.LAST
          INSERT INTO prod_strm_forecast VALUES l_prod_strm_fcst(i);
      END IF;
      l_prod_strm_fcst := t_prod_strm_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'FCTY_CLASS_1' OR lv_object_class = 'FCTY_CLASS_2' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_fcty_fcst LIMIT 1000;
      FOR i IN 1..l_prod_fcty_fcst.COUNT LOOP
        l_prod_fcty_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_fcty_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_fcty_fcst(i).last_updated_by := p_user;
        l_prod_fcty_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_fcty_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_fcty_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_fcty_fcst(i).daytime;
      END LOOP;
      IF l_prod_fcty_fcst.COUNT >0 THEN
        FORALL i IN l_prod_fcty_fcst.FIRST .. l_prod_fcty_fcst.LAST
          UPDATE prod_fcty_forecast SET ROW = l_prod_fcty_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_fcty_fcst := t_prod_fcty_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_fcty_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_fcty_fcst LIMIT 1000;
      FOR i IN 1..l_prod_fcty_fcst.COUNT LOOP
        l_prod_fcty_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_fcty_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_fcty_fcst(i).created_by := p_user;
        l_prod_fcty_fcst(i).created_date := ld_now;
        l_prod_fcty_fcst(i).last_updated_by := NULL;
        l_prod_fcty_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_fcty_fcst.COUNT >0 THEN
        FORALL i IN l_prod_fcty_fcst.FIRST .. l_prod_fcty_fcst.LAST
          INSERT INTO prod_fcty_forecast VALUES l_prod_fcty_fcst(i);
      END IF;
      l_prod_fcty_fcst := t_prod_fcty_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'AREA' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_area_fcst LIMIT 1000;
      FOR i IN 1..l_prod_area_fcst.COUNT LOOP
        l_prod_area_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_area_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_area_fcst(i).last_updated_by := p_user;
        l_prod_area_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_area_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_area_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_area_fcst(i).daytime;
      END LOOP;
      IF l_prod_area_fcst.COUNT >0 THEN
        FORALL i IN l_prod_area_fcst.FIRST .. l_prod_area_fcst.LAST
          UPDATE prod_area_forecast SET ROW = l_prod_area_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_area_fcst := t_prod_area_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_area_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_area_fcst LIMIT 1000;
      FOR i IN 1..l_prod_area_fcst.COUNT LOOP
        l_prod_area_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_area_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_area_fcst(i).created_by := p_user;
        l_prod_area_fcst(i).created_date := ld_now;
        l_prod_area_fcst(i).last_updated_by := NULL;
        l_prod_area_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_area_fcst.COUNT >0 THEN
        FORALL i IN l_prod_area_fcst.FIRST .. l_prod_area_fcst.LAST
          INSERT INTO prod_area_forecast VALUES l_prod_area_fcst(i);
      END IF;
      l_prod_area_fcst := t_prod_area_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;
  ELSIF lv_object_class = 'SUB_AREA' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_area_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_area_fcst.COUNT LOOP
        l_prod_sub_area_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_sub_area_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_sub_area_fcst(i).last_updated_by := p_user;
        l_prod_sub_area_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_sub_area_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_sub_area_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_sub_area_fcst(i).daytime;
      END LOOP;
      IF l_prod_sub_area_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_area_fcst.FIRST .. l_prod_sub_area_fcst.LAST
          UPDATE prod_sub_area_forecast SET ROW = l_prod_sub_area_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_sub_area_fcst := t_prod_sub_area_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_sub_area_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_area_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_area_fcst.COUNT LOOP
        l_prod_sub_area_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_sub_area_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_sub_area_fcst(i).created_by := p_user;
        l_prod_sub_area_fcst(i).created_date := ld_now;
        l_prod_sub_area_fcst(i).last_updated_by := NULL;
        l_prod_sub_area_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_sub_area_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_area_fcst.FIRST .. l_prod_sub_area_fcst.LAST
          INSERT INTO prod_sub_area_forecast VALUES l_prod_sub_area_fcst(i);
      END IF;
      l_prod_sub_area_fcst := t_prod_sub_area_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'FIELD' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_field_fcst LIMIT 1000;
      FOR i IN 1..l_prod_field_fcst.COUNT LOOP
        l_prod_field_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_field_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_field_fcst(i).last_updated_by := p_user;
        l_prod_field_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_field_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_field_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_field_fcst(i).daytime;
      END LOOP;
      IF l_prod_field_fcst.COUNT >0 THEN
        FORALL i IN l_prod_field_fcst.FIRST .. l_prod_field_fcst.LAST
          UPDATE prod_field_forecast SET ROW = l_prod_field_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_field_fcst := t_prod_field_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_field_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_field_fcst LIMIT 1000;
      FOR i IN 1..l_prod_field_fcst.COUNT LOOP
        l_prod_field_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_field_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_field_fcst(i).created_by := p_user;
        l_prod_field_fcst(i).created_date := ld_now;
        l_prod_field_fcst(i).last_updated_by := NULL;
        l_prod_field_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_field_fcst.COUNT >0 THEN
        FORALL i IN l_prod_field_fcst.FIRST .. l_prod_field_fcst.LAST
          INSERT INTO prod_field_forecast VALUES l_prod_field_fcst(i);
      END IF;
      l_prod_field_fcst := t_prod_field_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'SUB_FIELD' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_field_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_field_fcst.COUNT LOOP
        l_prod_sub_field_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_sub_field_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_sub_field_fcst(i).last_updated_by := p_user;
        l_prod_sub_field_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_sub_field_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_sub_field_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_sub_field_fcst(i).daytime;
      END LOOP;
      IF l_prod_sub_field_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_field_fcst.FIRST .. l_prod_sub_field_fcst.LAST
          UPDATE prod_sub_field_forecast SET ROW = l_prod_sub_field_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_sub_field_fcst := t_prod_sub_field_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_sub_field_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_field_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_field_fcst.COUNT LOOP
        l_prod_sub_field_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_sub_field_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_sub_field_fcst(i).created_by := p_user;
        l_prod_sub_field_fcst(i).created_date := ld_now;
        l_prod_sub_field_fcst(i).last_updated_by := NULL;
        l_prod_sub_field_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_sub_field_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_field_fcst.FIRST .. l_prod_sub_field_fcst.LAST
          INSERT INTO prod_sub_field_forecast VALUES l_prod_sub_field_fcst(i);
      END IF;
      l_prod_sub_field_fcst := t_prod_sub_field_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'PRODUCTIONUNIT' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_pu_fcst LIMIT 1000;
      FOR i IN 1..l_prod_pu_fcst.COUNT LOOP
        l_prod_pu_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_pu_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_pu_fcst(i).last_updated_by := p_user;
        l_prod_pu_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_pu_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_pu_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_pu_fcst(i).daytime;
      END LOOP;
      IF l_prod_pu_fcst.COUNT >0 THEN
        FORALL i IN l_prod_pu_fcst.FIRST .. l_prod_pu_fcst.LAST
          UPDATE prod_produnit_forecast SET ROW = l_prod_pu_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_pu_fcst := t_prod_pu_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_pu_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_pu_fcst LIMIT 1000;
      FOR i IN 1..l_prod_pu_fcst.COUNT LOOP
        l_prod_pu_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_pu_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_pu_fcst(i).created_by := p_user;
        l_prod_pu_fcst(i).created_date := ld_now;
        l_prod_pu_fcst(i).last_updated_by := NULL;
        l_prod_pu_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_pu_fcst.COUNT >0 THEN
        FORALL i IN l_prod_pu_fcst.FIRST .. l_prod_pu_fcst.LAST
          INSERT INTO prod_produnit_forecast VALUES l_prod_pu_fcst(i);
      END IF;
      l_prod_pu_fcst := t_prod_pu_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'PROD_SUB_UNIT' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_pu_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_pu_fcst.COUNT LOOP
        l_prod_sub_pu_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_sub_pu_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_sub_pu_fcst(i).last_updated_by := p_user;
        l_prod_sub_pu_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_sub_pu_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_sub_pu_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_sub_pu_fcst(i).daytime;
      END LOOP;
      IF l_prod_sub_pu_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_pu_fcst.FIRST .. l_prod_sub_pu_fcst.LAST
          UPDATE prod_sub_produnit_forecast SET ROW = l_prod_sub_pu_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_sub_pu_fcst := t_prod_sub_pu_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_sub_pu_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_pu_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_pu_fcst.COUNT LOOP
        l_prod_sub_pu_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_sub_pu_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_sub_pu_fcst(i).created_by := p_user;
        l_prod_sub_pu_fcst(i).created_date := ld_now;
        l_prod_sub_pu_fcst(i).last_updated_by := NULL;
        l_prod_sub_pu_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_sub_pu_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_pu_fcst.FIRST .. l_prod_sub_pu_fcst.LAST
          INSERT INTO prod_sub_produnit_forecast VALUES l_prod_sub_pu_fcst(i);
      END IF;
      l_prod_sub_pu_fcst := t_prod_sub_pu_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'STORAGE' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_storage_fcst LIMIT 1000;
      FOR i IN 1..l_prod_storage_fcst.COUNT LOOP
        l_prod_storage_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_storage_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_storage_fcst(i).last_updated_by := p_user;
        l_prod_storage_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_storage_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_storage_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_storage_fcst(i).daytime;
      END LOOP;
      IF l_prod_storage_fcst.COUNT >0 THEN
        FORALL i IN l_prod_storage_fcst.FIRST .. l_prod_storage_fcst.LAST
          UPDATE prod_storage_forecast SET ROW = l_prod_storage_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_storage_fcst := t_prod_storage_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_storage_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCTS(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_storage_fcst LIMIT 1000;
      FOR i IN 1..l_prod_storage_fcst.COUNT LOOP
        l_prod_storage_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyToScenario: fcst_scen_no is changed
        l_prod_storage_fcst(i).scenario := p_tgt_fcst_scenario;     --upon copyToScenario: new scenario is assigned

        l_prod_storage_fcst(i).created_by := p_user;
        l_prod_storage_fcst(i).created_date := ld_now;
        l_prod_storage_fcst(i).last_updated_by := NULL;
        l_prod_storage_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_storage_fcst.COUNT >0 THEN
        FORALL i IN l_prod_storage_fcst.FIRST .. l_prod_storage_fcst.LAST
          INSERT INTO prod_storage_forecast VALUES l_prod_storage_fcst(i);
      END IF;
      l_prod_storage_fcst := t_prod_storage_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  END IF;
END objFcstCopyToScenario;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : allObjFcstCopyToScenario
-- Description    : Copy records of the given object from the source scenario to the given target scenario
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: dynCursorGetObject
--                  objFcstCopyToScenario
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE allObjFcstCopyToScenario(p_object_class        VARCHAR2,
                                   p_src_fcst_scen_no    NUMBER,
                                   p_tgt_fcst_scen_no    NUMBER,
                                   p_tgt_fcst_scen_type  VARCHAR2,
                                   p_user                VARCHAR2)
--</EC-DOC>
IS
  lc_fcst_data                  rc_fcst_data;
  lv_fcst_object_id             VARCHAR2(32);

BEGIN
  dynCursorGetObject(lc_fcst_data,p_src_fcst_scen_no,p_object_class);
  LOOP
    FETCH lc_fcst_data INTO lv_fcst_object_id;
    EXIT WHEN lc_fcst_data%NOTFOUND;
    objFcstCopyToScenario(lv_fcst_object_id,
                          p_src_fcst_scen_no,
                          p_tgt_fcst_scen_no,
                          p_tgt_fcst_scen_type,
                          p_user);
  END LOOP;
  CLOSE lc_fcst_data;
END allObjFcstCopyToScenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : objFcstCopyFromForecast
-- Description    : Copy records of the given object from the source forecast to the given target forecast
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : prod_<object_class>_forecast
--
-- Using functions: ecdp_objects.GetObjClassName
--                  ecdp_date_time.getCurrentSysdate
--                  validateTargetDataCFF
--                  dynCursorInsObjectCFF
--                  dynCursorUpdObjectCFF
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE objFcstCopyFromForecast(p_object_id          VARCHAR2,
                                  p_src_fcst_scen_no   NUMBER,
                                  p_tgt_fcst_scen_no   NUMBER,
                                  p_tgt_effective_date DATE,
                                  p_user               VARCHAR2)
--</EC-DOC>
IS
  lv_object_class        VARCHAR2(32) := ecdp_objects.GetObjClassName(p_object_id);
  ld_now                 DATE := ecdp_date_time.getCurrentSysdate;
  lc_fcst_data           rc_fcst_data;

  -- to utilize FORALL (in UPDATE), have to create separate collection to hold these keys
  TYPE t_object_id       IS TABLE OF VARCHAR2(32);
  TYPE t_fcst_scen_no    IS TABLE OF NUMBER;
  TYPE t_daytime         IS TABLE OF DATE;
  lt_object_id           t_object_id := t_object_id();
  lt_fcst_scen_no        t_fcst_scen_no := t_fcst_scen_no();
  lt_daytime             t_daytime := t_daytime();

  -- declare type for each object here
  TYPE t_prod_well_fcst      IS TABLE OF prod_well_forecast%ROWTYPE;
  TYPE t_prod_strm_fcst      IS TABLE OF prod_strm_forecast%ROWTYPE;
  TYPE t_prod_fcty_fcst      IS TABLE OF prod_fcty_forecast%ROWTYPE;
  TYPE t_prod_area_fcst      IS TABLE OF prod_area_forecast%ROWTYPE;
  TYPE t_prod_sub_area_fcst  IS TABLE OF prod_sub_area_forecast%ROWTYPE;
  TYPE t_prod_field_fcst     IS TABLE OF prod_field_forecast%ROWTYPE;
  TYPE t_prod_sub_field_fcst IS TABLE OF prod_sub_field_forecast%ROWTYPE;
  TYPE t_prod_pu_fcst        IS TABLE OF prod_produnit_forecast%ROWTYPE;
  TYPE t_prod_sub_pu_fcst    IS TABLE OF prod_sub_produnit_forecast%ROWTYPE;
  TYPE t_prod_storage_fcst   IS TABLE OF prod_storage_forecast%ROWTYPE;


  -- declare variable for above type for each object here
  l_prod_well_fcst       t_prod_well_fcst;
  l_prod_strm_fcst       t_prod_strm_fcst;
  l_prod_fcty_fcst       t_prod_fcty_fcst;
  l_prod_area_fcst       t_prod_area_fcst;
  l_prod_sub_area_fcst   t_prod_sub_area_fcst;
  l_prod_field_fcst      t_prod_field_fcst;
  l_prod_sub_field_fcst  t_prod_sub_field_fcst;
  l_prod_pu_fcst         t_prod_pu_fcst;
  l_prod_sub_pu_fcst     t_prod_sub_pu_fcst;
  l_prod_storage_fcst    t_prod_storage_fcst;


BEGIN

  validateTargetDataCFF(p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);

  IF lv_object_class = 'WELL' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_well_fcst LIMIT 1000;
      FOR i IN 1..l_prod_well_fcst.COUNT LOOP
        l_prod_well_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_well_fcst(i).last_updated_by := p_user;
        l_prod_well_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_well_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_well_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_well_fcst(i).daytime;
      END LOOP;
      IF l_prod_well_fcst.COUNT >0 THEN
        FORALL i IN l_prod_well_fcst.FIRST .. l_prod_well_fcst.LAST
          UPDATE prod_well_forecast SET ROW = l_prod_well_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_well_fcst := t_prod_well_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_well_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_well_fcst LIMIT 1000;
      FOR i IN 1..l_prod_well_fcst.COUNT LOOP
        l_prod_well_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_well_fcst(i).effective_daytime := p_tgt_effective_date;
        l_prod_well_fcst(i).created_by := p_user;
        l_prod_well_fcst(i).created_date := ld_now;
        l_prod_well_fcst(i).last_updated_by := NULL;
        l_prod_well_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_well_fcst.COUNT >0 THEN
        FORALL i IN l_prod_well_fcst.FIRST .. l_prod_well_fcst.LAST
          INSERT INTO prod_well_forecast VALUES l_prod_well_fcst(i);
      END IF;
      l_prod_well_fcst := t_prod_well_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'STREAM' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_strm_fcst LIMIT 1000;
      FOR i IN 1..l_prod_strm_fcst.COUNT LOOP
        l_prod_strm_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_strm_fcst(i).last_updated_by := p_user;
        l_prod_strm_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_strm_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_strm_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_strm_fcst(i).daytime;
      END LOOP;
      IF l_prod_strm_fcst.COUNT >0 THEN
        FORALL i IN l_prod_strm_fcst.FIRST .. l_prod_strm_fcst.LAST
          UPDATE prod_strm_forecast SET ROW = l_prod_strm_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_strm_fcst := t_prod_strm_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_strm_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_strm_fcst LIMIT 1000;
      FOR i IN 1..l_prod_strm_fcst.COUNT LOOP
        l_prod_strm_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_strm_fcst(i).effective_daytime := p_tgt_effective_date;
        l_prod_strm_fcst(i).created_by := p_user;
        l_prod_strm_fcst(i).created_date := ld_now;
        l_prod_strm_fcst(i).last_updated_by := NULL;
        l_prod_strm_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_strm_fcst.COUNT >0 THEN
        FORALL i IN l_prod_strm_fcst.FIRST .. l_prod_strm_fcst.LAST
          INSERT INTO prod_strm_forecast VALUES l_prod_strm_fcst(i);
      END IF;
      l_prod_strm_fcst := t_prod_strm_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'FCTY_CLASS_1' OR lv_object_class = 'FCTY_CLASS_2' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_fcty_fcst LIMIT 1000;
      FOR i IN 1..l_prod_fcty_fcst.COUNT LOOP
        l_prod_fcty_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_fcty_fcst(i).last_updated_by := p_user;
        l_prod_fcty_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_fcty_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_fcty_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_fcty_fcst(i).daytime;
      END LOOP;
      IF l_prod_fcty_fcst.COUNT >0 THEN
        FORALL i IN l_prod_fcty_fcst.FIRST .. l_prod_fcty_fcst.LAST
          UPDATE prod_fcty_forecast SET ROW = l_prod_fcty_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_fcty_fcst := t_prod_fcty_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_fcty_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_fcty_fcst LIMIT 1000;
      FOR i IN 1..l_prod_fcty_fcst.COUNT LOOP
        l_prod_fcty_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_fcty_fcst(i).effective_daytime := p_tgt_effective_date;
        l_prod_fcty_fcst(i).created_by := p_user;
        l_prod_fcty_fcst(i).created_date := ld_now;
        l_prod_fcty_fcst(i).last_updated_by := NULL;
        l_prod_fcty_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_fcty_fcst.COUNT >0 THEN
        FORALL i IN l_prod_fcty_fcst.FIRST .. l_prod_fcty_fcst.LAST
          INSERT INTO prod_fcty_forecast VALUES l_prod_fcty_fcst(i);
      END IF;
      l_prod_fcty_fcst := t_prod_fcty_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'AREA' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_area_fcst LIMIT 1000;
      FOR i IN 1..l_prod_area_fcst.COUNT LOOP
        l_prod_area_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_area_fcst(i).last_updated_by := p_user;
        l_prod_area_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_area_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_area_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_area_fcst(i).daytime;
      END LOOP;
      IF l_prod_area_fcst.COUNT >0 THEN
        FORALL i IN l_prod_area_fcst.FIRST .. l_prod_area_fcst.LAST
          UPDATE prod_area_forecast SET ROW = l_prod_area_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_area_fcst := t_prod_area_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_area_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_area_fcst LIMIT 1000;
      FOR i IN 1..l_prod_area_fcst.COUNT LOOP
        l_prod_area_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_area_fcst(i).effective_daytime := p_tgt_effective_date;
        l_prod_area_fcst(i).created_by := p_user;
        l_prod_area_fcst(i).created_date := ld_now;
        l_prod_area_fcst(i).last_updated_by := NULL;
        l_prod_area_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_area_fcst.COUNT >0 THEN
        FORALL i IN l_prod_area_fcst.FIRST .. l_prod_area_fcst.LAST
          INSERT INTO prod_area_forecast VALUES l_prod_area_fcst(i);
      END IF;
      l_prod_area_fcst := t_prod_area_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'SUB_AREA' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_area_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_area_fcst.COUNT LOOP
        l_prod_sub_area_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_sub_area_fcst(i).last_updated_by := p_user;
        l_prod_sub_area_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_sub_area_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_sub_area_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_sub_area_fcst(i).daytime;
      END LOOP;
      IF l_prod_sub_area_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_area_fcst.FIRST .. l_prod_sub_area_fcst.LAST
          UPDATE prod_sub_area_forecast SET ROW = l_prod_sub_area_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_sub_area_fcst := t_prod_sub_area_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_sub_area_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_area_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_area_fcst.COUNT LOOP
        l_prod_sub_area_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_sub_area_fcst(i).effective_daytime := p_tgt_effective_date;
        l_prod_sub_area_fcst(i).created_by := p_user;
        l_prod_sub_area_fcst(i).created_date := ld_now;
        l_prod_sub_area_fcst(i).last_updated_by := NULL;
        l_prod_sub_area_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_sub_area_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_area_fcst.FIRST .. l_prod_sub_area_fcst.LAST
          INSERT INTO prod_sub_area_forecast VALUES l_prod_sub_area_fcst(i);
      END IF;
      l_prod_sub_area_fcst := t_prod_sub_area_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'FIELD' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_field_fcst LIMIT 1000;
      FOR i IN 1..l_prod_field_fcst.COUNT LOOP
        l_prod_field_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_field_fcst(i).last_updated_by := p_user;
        l_prod_field_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_field_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_field_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_field_fcst(i).daytime;
      END LOOP;
      IF l_prod_field_fcst.COUNT >0 THEN
        FORALL i IN l_prod_field_fcst.FIRST .. l_prod_field_fcst.LAST
          UPDATE prod_field_forecast SET ROW = l_prod_field_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_field_fcst := t_prod_field_fcst(); --clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_field_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_field_fcst LIMIT 1000;
      FOR i IN 1..l_prod_field_fcst.COUNT LOOP
        l_prod_field_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_field_fcst(i).effective_daytime := p_tgt_effective_date;
        l_prod_field_fcst(i).created_by := p_user;
        l_prod_field_fcst(i).created_date := ld_now;
        l_prod_field_fcst(i).last_updated_by := NULL;
        l_prod_field_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_field_fcst.COUNT >0 THEN
        FORALL i IN l_prod_field_fcst.FIRST .. l_prod_field_fcst.LAST
          INSERT INTO prod_field_forecast VALUES l_prod_field_fcst(i);
      END IF;
      l_prod_field_fcst := t_prod_field_fcst(); --clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'SUB_FIELD' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_field_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_field_fcst.COUNT LOOP
        l_prod_sub_field_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_sub_field_fcst(i).last_updated_by := p_user;
        l_prod_sub_field_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_sub_field_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_sub_field_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_sub_field_fcst(i).daytime;
      END LOOP;
      IF l_prod_sub_field_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_field_fcst.FIRST .. l_prod_sub_field_fcst.LAST
          UPDATE prod_sub_field_forecast SET ROW = l_prod_sub_field_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_sub_field_fcst := t_prod_sub_field_fcst(); --clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_sub_field_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_field_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_field_fcst.COUNT LOOP
        l_prod_sub_field_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_sub_field_fcst(i).effective_daytime := p_tgt_effective_date;
        l_prod_sub_field_fcst(i).created_by := p_user;
        l_prod_sub_field_fcst(i).created_date := ld_now;
        l_prod_sub_field_fcst(i).last_updated_by := NULL;
        l_prod_sub_field_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_sub_field_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_field_fcst.FIRST .. l_prod_sub_field_fcst.LAST
          INSERT INTO prod_sub_field_forecast VALUES l_prod_sub_field_fcst(i);
      END IF;
      l_prod_sub_field_fcst := t_prod_sub_field_fcst(); --clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'PRODUCTIONUNIT' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_pu_fcst LIMIT 1000;
      FOR i IN 1..l_prod_pu_fcst.COUNT LOOP
        l_prod_pu_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_pu_fcst(i).last_updated_by := p_user;
        l_prod_pu_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_pu_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_pu_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_pu_fcst(i).daytime;
      END LOOP;
      IF l_prod_pu_fcst.COUNT >0 THEN
        FORALL i IN l_prod_pu_fcst.FIRST .. l_prod_pu_fcst.LAST
          UPDATE prod_produnit_forecast SET ROW = l_prod_pu_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_pu_fcst := t_prod_pu_fcst(); --clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_pu_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_pu_fcst LIMIT 1000;
      FOR i IN 1..l_prod_pu_fcst.COUNT LOOP
        l_prod_pu_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_pu_fcst(i).effective_daytime := p_tgt_effective_date;
        l_prod_pu_fcst(i).created_by := p_user;
        l_prod_pu_fcst(i).created_date := ld_now;
        l_prod_pu_fcst(i).last_updated_by := NULL;
        l_prod_pu_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_pu_fcst.COUNT >0 THEN
        FORALL i IN l_prod_pu_fcst.FIRST .. l_prod_pu_fcst.LAST
          INSERT INTO prod_produnit_forecast VALUES l_prod_pu_fcst(i);
      END IF;
      l_prod_pu_fcst := t_prod_pu_fcst(); --clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'PROD_SUB_UNIT' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_pu_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_pu_fcst.COUNT LOOP
        l_prod_sub_pu_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_sub_pu_fcst(i).last_updated_by := p_user;
        l_prod_sub_pu_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_sub_pu_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_sub_pu_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_sub_pu_fcst(i).daytime;
      END LOOP;
      IF l_prod_sub_pu_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_pu_fcst.FIRST .. l_prod_sub_pu_fcst.LAST
          UPDATE prod_sub_produnit_forecast SET ROW = l_prod_sub_pu_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_sub_pu_fcst := t_prod_sub_pu_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_sub_pu_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_sub_pu_fcst LIMIT 1000;
      FOR i IN 1..l_prod_sub_pu_fcst.COUNT LOOP
        l_prod_sub_pu_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_sub_pu_fcst(i).effective_daytime := p_tgt_effective_date;
        l_prod_sub_pu_fcst(i).created_by := p_user;
        l_prod_sub_pu_fcst(i).created_date := ld_now;
        l_prod_sub_pu_fcst(i).last_updated_by := NULL;
        l_prod_sub_pu_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_sub_pu_fcst.COUNT >0 THEN
        FORALL i IN l_prod_sub_pu_fcst.FIRST .. l_prod_sub_pu_fcst.LAST
          INSERT INTO prod_sub_produnit_forecast VALUES l_prod_sub_pu_fcst(i);
      END IF;
      l_prod_sub_pu_fcst := t_prod_sub_pu_fcst(); -- clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  ELSIF lv_object_class = 'STORAGE' THEN
    -- handle UPDATE (only Provisional)
    dynCursorUpdObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_storage_fcst LIMIT 1000;
      FOR i IN 1..l_prod_storage_fcst.COUNT LOOP
        l_prod_storage_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_storage_fcst(i).last_updated_by := p_user;
        l_prod_storage_fcst(i).last_updated_date := ld_now;

        -- storing keys in separate collection
        lt_object_id.extend;
        lt_object_id(lt_object_id.LAST) := l_prod_storage_fcst(i).object_id;
        lt_fcst_scen_no.extend;
        lt_fcst_scen_no(lt_fcst_scen_no.LAST) := l_prod_storage_fcst(i).fcst_scen_no;
        lt_daytime.extend;
        lt_daytime(lt_daytime.lAST) := l_prod_storage_fcst(i).daytime;
      END LOOP;
      IF l_prod_storage_fcst.COUNT >0 THEN
        FORALL i IN l_prod_storage_fcst.FIRST .. l_prod_storage_fcst.LAST
          UPDATE prod_storage_forecast SET ROW = l_prod_storage_fcst(i)
                 WHERE object_id = lt_object_id(i) AND
                       fcst_scen_no = lt_fcst_scen_no(i) AND
                       daytime = lt_daytime(i);
      END IF;
      l_prod_storage_fcst := t_prod_storage_fcst(); --clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

    l_prod_storage_fcst := NULL;
    -- handle INSERT
    dynCursorInsObjectCFF(lc_fcst_data,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_object_id);
    LOOP
      FETCH lc_fcst_data BULK COLLECT INTO l_prod_storage_fcst LIMIT 1000;
      FOR i IN 1..l_prod_storage_fcst.COUNT LOOP
        l_prod_storage_fcst(i).fcst_scen_no := p_tgt_fcst_scen_no;  --upon copyFromForecast: fcst_scen_no is the current/target
        l_prod_storage_fcst(i).effective_daytime := p_tgt_effective_date;
        l_prod_storage_fcst(i).created_by := p_user;
        l_prod_storage_fcst(i).created_date := ld_now;
        l_prod_storage_fcst(i).last_updated_by := NULL;
        l_prod_storage_fcst(i).last_updated_date := NULL;
      END LOOP;
      IF l_prod_storage_fcst.COUNT >0 THEN
        FORALL i IN l_prod_storage_fcst.FIRST .. l_prod_storage_fcst.LAST
          INSERT INTO prod_storage_forecast VALUES l_prod_storage_fcst(i);
      END IF;
      l_prod_storage_fcst := t_prod_storage_fcst(); --clean up

      EXIT WHEN lc_fcst_data%NOTFOUND;
    END LOOP;
    CLOSE lc_fcst_data;

  END IF;
END objFcstCopyFromForecast;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : allObjFcstCopyFromForecast
-- Description    : Copy records of the given object from the source forecast to the given target forecast
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: dynCursorGetObject
--                  objFcstCopyFromForecast
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE allObjFcstCopyFromForecast(p_object_class        VARCHAR2,
                                     p_src_fcst_scen_no    NUMBER,
                                     p_tgt_fcst_scen_no    NUMBER,
                                     p_tgt_effective_date  DATE,
                                     p_user                VARCHAR2)
--</EC-DOC>
IS
  lc_fcst_data                  rc_fcst_data;
  lv_fcst_object_id             VARCHAR2(32);

BEGIN
  dynCursorGetObject(lc_fcst_data,p_src_fcst_scen_no,p_object_class);
  LOOP
    FETCH lc_fcst_data INTO lv_fcst_object_id;
    EXIT WHEN lc_fcst_data%NOTFOUND;
    objFcstCopyFromForecast(lv_fcst_object_id,
                            p_src_fcst_scen_no,
                            p_tgt_fcst_scen_no,
                            p_tgt_effective_date,
                            p_user);
  END LOOP;
  CLOSE lc_fcst_data;
END allObjFcstCopyFromForecast;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyToScenarioForCurrent
-- Description    : execute objFcstCopyToScenario for current object only
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: validateMonthLock, prodFcstCopyToScenario, objFcstCopyToScenario
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyToScenarioForCurrent(p_object_id     VARCHAR2,
                                   p_tgt_fcst_scen_type  VARCHAR2,
                                   p_src_fcst_scen_type  VARCHAR2,
                                   p_src_fcst_type       VARCHAR2,
                                   p_src_effective_date  DATE,
                                   p_src_fcst_scen_no    NUMBER,
                                   p_user                VARCHAR2)
--</EC-DOC>
IS
  ln_tgt_scen_no                NUMBER;

BEGIN

  validateMonthLock(p_src_effective_date,'EcBp_ProductionForecast.copyToScenarioForCurrent', p_object_id);

  prodFcstCopyToScenario(p_tgt_fcst_scen_type,
                         p_src_fcst_scen_type,
                         p_src_fcst_type,
                         p_src_effective_date,
                         p_user,
                         ln_tgt_scen_no);

  objFcstCopyToScenario(p_object_id,
                        p_src_fcst_scen_no,
                        ln_tgt_scen_no,
                        p_tgt_fcst_scen_type,
                        p_user);

END copyToScenarioForCurrent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyToScenarioForParent
-- Description    : execute objFcstCopyToScenario for all object that belongs to the given parent
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: validateMonthLock, prodFcstCopyToScenario, dynCursorGetChild, objFcstCopyToScenario
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyToScenarioForParent(p_parent_object_id    VARCHAR2,
                                  p_child_class         VARCHAR2,
                                  p_tgt_fcst_scen_type  VARCHAR2,
                                  p_src_fcst_scen_type  VARCHAR2,
                                  p_src_fcst_type       VARCHAR2,
                                  p_src_effective_date  DATE,
                                  p_src_fcst_scen_no    NUMBER,
                                  p_user                VARCHAR2,
                                  p_fromdate            DATE,
                                  p_todate              DATE,
                                  p_group_type          VARCHAR2,
                                  p_object_id           VARCHAR2)
--</EC-DOC>
IS
  ln_tgt_scen_no                NUMBER;
  lc_fcst_data                  rc_fcst_data;
  lv_fcst_object_id             VARCHAR2(32);

BEGIN
  validateMonthLock(p_src_effective_date,'EcBp_ProductionForecast.copyToScenarioForParent', p_object_id);

  prodFcstCopyToScenario(p_tgt_fcst_scen_type,
                         p_src_fcst_scen_type,
                         p_src_fcst_type,
                         p_src_effective_date,
                         p_user,
                         ln_tgt_scen_no);

  dynCursorGetChild(lc_fcst_data,p_src_fcst_scen_no,p_parent_object_id,p_child_class,p_fromdate,p_todate,p_group_type);
  LOOP
    FETCH lc_fcst_data INTO lv_fcst_object_id;
    EXIT WHEN lc_fcst_data%NOTFOUND;
    objFcstCopyToScenario(lv_fcst_object_id,
                          p_src_fcst_scen_no,
                          ln_tgt_scen_no,
                          p_tgt_fcst_scen_type,
                          p_user);
  END LOOP;
  CLOSE lc_fcst_data;

END copyToScenarioForParent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyToScenarioForAll
-- Description    : execute objFcstCopyToScenario for all object class
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: validateMonthLock, prodFcstCopyToScenario, allObjFcstCopyToScenario
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyToScenarioForAll(p_tgt_fcst_scen_type  VARCHAR2,
                               p_src_fcst_scen_type  VARCHAR2,
                               p_src_fcst_type       VARCHAR2,
                               p_src_effective_date  DATE,
                               p_src_fcst_scen_no    NUMBER,
                               p_user                VARCHAR2)
--</EC-DOC>
IS
  ln_tgt_scen_no                NUMBER;

BEGIN
  validateMonthLock(p_src_effective_date,'EcBp_ProductionForecast.copyToScenarioForAll');

  prodFcstCopyToScenario(p_tgt_fcst_scen_type,
                         p_src_fcst_scen_type,
                         p_src_fcst_type,
                         p_src_effective_date,
                         p_user,
                         ln_tgt_scen_no);

  -- call each procedure handling each objects
  allObjFcstCopyToScenario('WELL',p_src_fcst_scen_no,ln_tgt_scen_no,p_tgt_fcst_scen_type,p_user);
  allObjFcstCopyToScenario('STREAM',p_src_fcst_scen_no,ln_tgt_scen_no,p_tgt_fcst_scen_type,p_user);
  allObjFcstCopyToScenario('FCTY_CLASS_1',p_src_fcst_scen_no,ln_tgt_scen_no,p_tgt_fcst_scen_type,p_user);
  allObjFcstCopyToScenario('FCTY_CLASS_2',p_src_fcst_scen_no,ln_tgt_scen_no,p_tgt_fcst_scen_type,p_user);
  allObjFcstCopyToScenario('FIELD',p_src_fcst_scen_no,ln_tgt_scen_no,p_tgt_fcst_scen_type,p_user);
  allObjFcstCopyToScenario('SUB_FIELD',p_src_fcst_scen_no,ln_tgt_scen_no,p_tgt_fcst_scen_type,p_user);
  allObjFcstCopyToScenario('AREA',p_src_fcst_scen_no,ln_tgt_scen_no,p_tgt_fcst_scen_type,p_user);
  allObjFcstCopyToScenario('SUB_AREA',p_src_fcst_scen_no,ln_tgt_scen_no,p_tgt_fcst_scen_type,p_user);
  allObjFcstCopyToScenario('PRODUCTIONUNIT',p_src_fcst_scen_no,ln_tgt_scen_no,p_tgt_fcst_scen_type,p_user);
  allObjFcstCopyToScenario('PROD_SUB_UNIT',p_src_fcst_scen_no,ln_tgt_scen_no,p_tgt_fcst_scen_type,p_user);
  allObjFcstCopyToScenario('STORAGE',p_src_fcst_scen_no,ln_tgt_scen_no,p_tgt_fcst_scen_type,p_user);

END copyToScenarioForAll;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyFromForecastForCurrent
-- Description    : execute objFcstCopyFromForecast for current object only
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: validateMonthLock, objFcstCopyFromForecast
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFromForecastForCurrent(p_object_id           VARCHAR2,
                                     p_src_fcst_scen_no    NUMBER,
                                     p_tgt_fcst_scen_no    NUMBER,
                                     p_tgt_effective_date  DATE,
                                     p_user                VARCHAR2)
--</EC-DOC>
IS
BEGIN
  validateMonthLock(p_tgt_effective_date,'EcBp_ProductionForecast.copyFromForecastForCurrent', p_object_id);
  objFcstCopyFromForecast(p_object_id,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
END copyFromForecastForCurrent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyFromForecastForParent
-- Description    : execute objFcstCopyFromForecast for all objects that belongs to the given parent
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: validateMonthLock, dynCursorGetChild, objFcstCopyFromForecast
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFromForecastForParent(p_parent_object_id     VARCHAR2,
                                    p_child_class          VARCHAR2,
                                    p_src_fcst_scen_no     NUMBER,
                                    p_tgt_fcst_scen_no     NUMBER,
                                    p_tgt_effective_date   DATE,
                                    p_user                 VARCHAR2,
                                    p_fromdate             DATE,
                                    p_todate               DATE,
                                    p_group_type           VARCHAR2,
                                    p_object_id            VARCHAR2)
--</EC-DOC>
IS
  lc_fcst_data                  rc_fcst_data;
  lv_fcst_object_id             VARCHAR2(32);

BEGIN
  validateMonthLock(p_tgt_effective_date,'EcBp_ProductionForecast.copyFromForecastForParent', p_object_id);

  dynCursorGetChild(lc_fcst_data,p_src_fcst_scen_no,p_parent_object_id,p_child_class,p_fromdate,p_todate,p_group_type);
  LOOP
    FETCH lc_fcst_data INTO lv_fcst_object_id;
    EXIT WHEN lc_fcst_data%NOTFOUND;
    objFcstCopyFromForecast(lv_fcst_object_id,p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
  END LOOP;
  CLOSE lc_fcst_data;

END copyFromForecastForParent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyFromForecastForAll
-- Description    : execute objFcstCopyFromForecast for all objects class
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: validateMonthLock, allObjFcstCopyFromForecast
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFromForecastForAll(p_src_fcst_scen_no    NUMBER,
                                 p_tgt_fcst_scen_no    NUMBER,
                                 p_tgt_effective_date  DATE,
                                 p_user                VARCHAR2)
--</EC-DOC>
IS
BEGIN
  validateMonthLock(p_tgt_effective_date,'EcBp_ProductionForecast.copyFromForecastForAll');

  -- call each procedure handling each objects
  allObjFcstCopyFromForecast('WELL',p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
  allObjFcstCopyFromForecast('STREAM',p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
  allObjFcstCopyFromForecast('FCTY_CLASS_1',p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
  allObjFcstCopyFromForecast('FCTY_CLASS_2',p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
  allObjFcstCopyFromForecast('FIELD',p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
  allObjFcstCopyFromForecast('SUB_FIELD',p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
  allObjFcstCopyFromForecast('AREA',p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
  allObjFcstCopyFromForecast('SUB_AREA',p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
  allObjFcstCopyFromForecast('PRODUCTIONUNIT',p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
  allObjFcstCopyFromForecast('PROD_SUB_UNIT',p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);
  allObjFcstCopyFromForecast('STORAGE',p_src_fcst_scen_no,p_tgt_fcst_scen_no,p_tgt_effective_date,p_user);

END copyFromForecastForAll;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyCurrent
-- Description    : verify records for current object only
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getFcstTable, ecdp_dynsql.execute_statement
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE verifyCurrent( p_object_class  VARCHAR2,
                         p_object_id     VARCHAR2,
                         p_fcst_scen_no  NUMBER)
--</EC-DOC>
IS

lv_sql               VARCHAR2(2000);
lv_sql_more          VARCHAR2(2000);
lv_fcst_data_tab     VARCHAR2(100);

BEGIN
  -- forecast table
  lv_fcst_data_tab := getFcstTable(p_object_class);

  IF p_object_class = 'FCTY_CLASS_1' THEN
    lv_sql_more := lv_sql_more || ' AND f.class_name=''PROD_FCTY1_FORECAST''';
  ELSIF p_object_class = 'FCTY_CLASS_2' THEN
    lv_sql_more := lv_sql_more || ' AND f.class_name=''PROD_FCTY2_FORECAST''';
  END IF;

  -- update statement to set record status to Verified
  lv_sql := 'UPDATE '||lv_fcst_data_tab||' f SET f.record_status=''V'' WHERE f.object_id = '''|| p_object_id ||''' AND f.fcst_scen_no = '|| p_fcst_scen_no ||' AND f.record_status = ''P''';

  IF lv_sql_more IS NOT NULL THEN
    lv_sql := lv_sql || lv_sql_more;
  END IF;

  ecdp_dynsql.execute_statement(lv_sql);

END verifyCurrent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyAllObject
-- Description    : verify records for all objects that belong the given parent
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getFcstTable,
--                  getFcstChildVersionTable,
--                  getFcstParentCol,
--                  ecdp_dynsql.execute_statement, ecdp_objects.GetObjClassName
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE verifyAllObject(p_parent_object_id     VARCHAR2,
                          p_child_class          VARCHAR2,
                          p_fcst_scen_no         NUMBER,
                          p_fromdate             DATE,
                          p_todate               DATE,
                          p_group_type           VARCHAR2)
--</EC-DOC>
IS

  lv_sql               VARCHAR2(2000);
  lv_sql_more          VARCHAR2(2000);
  lv_tab               VARCHAR2(100);
  lv_child_tab         VARCHAR2(100);
  lv_obj_parent_col    VARCHAR2(100);
  lv_parent_class      VARCHAR2(100) := ecdp_objects.GetObjClassName(p_parent_object_id);
  lv_fromdate          VARCHAR2(50) := to_char(p_fromdate, 'YYYY-MM-DD"T"HH24:MI:SS');
  lv_todate            VARCHAR2(50) := to_char(p_todate, 'YYYY-MM-DD"T"HH24:MI:SS');

BEGIN

  -- forecast table, version table, parent column
  lv_tab := getFcstTable(p_child_class);
  lv_child_tab := getFcstChildVersionTable(p_child_class);
  lv_obj_parent_col := getFcstParentCol(lv_parent_class,p_group_type);

  IF p_child_class = 'FCTY_CLASS_1' THEN
    lv_sql_more := lv_sql_more || ' AND f.class_name=''PROD_FCTY1_FORECAST''';
  ELSIF p_child_class = 'FCTY_CLASS_2' THEN
    lv_sql_more := lv_sql_more || ' AND f.class_name=''PROD_FCTY2_FORECAST''';
  END IF;

  -- Generating the following SQL
  --UPDATE prod_well_forecast f SET f.record_status='V'
  --WHERE f.object_id in (SELECT distinct f2.object_id FROM prod_well_forecast f2, well_version wv
  --                             WHERE f2.object_id = wv.object_id
  --                             AND wv.op_fcty_class_1_id = 'aa'
  --                             AND f2.fcst_scen_no = 1
  --                             AND to_date('2004-05-07T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') >= wv.daytime
  --                             AND to_date('2004-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') < nvl(wv.end_date, to_date('2007-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')+1)
  --                     )
  --AND f.fcst_scen_no = 1
  --AND f.record_status = 'P';

  lv_sql := 'UPDATE ' || lv_tab || ' f SET f.record_status=''V''';
  lv_sql := lv_sql || ' WHERE f.object_id in ';
  lv_sql := lv_sql || ' (';
  lv_sql := lv_sql || ' SELECT DISTINCT f2.object_id FROM ' || lv_tab || ' f2, ' || lv_child_tab || ' v';
  lv_sql := lv_sql || ' WHERE f2.object_id = v.object_id AND v.' || lv_obj_parent_col || ' = ''' || p_parent_object_id || ''' AND f2.fcst_scen_no=' || p_fcst_scen_no;
  lv_sql := lv_sql || ' AND to_date(''' || lv_todate || ''', ''YYYY-MM-DD"T"HH24:MI:SS'') >= v.daytime';
  lv_sql := lv_sql || ' AND to_date(''' || lv_fromdate || ''', ''YYYY-MM-DD"T"HH24:MI:SS'') < nvl(v.end_date, to_date(''' || lv_fromdate || ''', ''YYYY-MM-DD"T"HH24:MI:SS'')+1)';
  lv_sql := lv_sql || ' ) AND f.fcst_scen_no=' || p_fcst_scen_no || ' AND f.record_status=''P''';

  -- special case
  IF lv_sql_more IS NOT NULL THEN
    lv_sql := lv_sql || lv_sql_more;
  END IF;

  ecdp_dynsql.execute_statement(lv_sql);

END verifyAllObject;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : approveCurrent
-- Description    : approve records for current object only
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getFcstTable,
--                  ecdp_dynsql.execute_statement, ecdp_objects.GetObjClassName
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveCurrent(p_obj_class              VARCHAR2,
                         p_object_id              VARCHAR2,
                         p_fcst_scen_no           NUMBER)
--</EC-DOC>
IS

lv_tab VARCHAR2(100);
lv_sql VARCHAR2(2000);
lv_sql2 VARCHAR2(2000);

BEGIN

  -- forecast table
  lv_tab := getFcstTable(p_obj_class);

  IF p_obj_class = 'FCTY_CLASS_1' THEN
    lv_sql2 := lv_sql2 || ' AND f.class_name=''PROD_FCTY1_FORECAST''';
  ELSIF p_obj_class = 'FCTY_CLASS_2' THEN
    lv_sql2 := lv_sql2 || ' AND f.class_name=''PROD_FCTY2_FORECAST''';
  END IF;

  lv_sql := 'UPDATE ' || lv_tab || ' f SET f.record_status=''A''';
  lv_sql := lv_sql || ' WHERE f.object_id= ''' || p_object_id ||''' AND f.fcst_scen_no=' || p_fcst_scen_no;

  -- special case
  IF lv_sql2 IS NOT NULL THEN
    lv_sql := lv_sql || lv_sql2;
  END IF;

  ecdp_dynsql.execute_statement(lv_sql);

END approveCurrent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : approveAllObject
-- Description    : approve records for all objects that belong to the given parent
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getFcstTable,
--                  getFcstChildVersionTable,
--                  getFcstParentCol,
--                  ecdp_dynsql.execute_statement, ecdp_objects.GetObjClassName
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveAllObject(p_parent_object_id     VARCHAR2,
                           p_child_class          VARCHAR2,
                           p_fcst_scen_no         NUMBER,
                           p_fromdate             DATE,
                           p_todate               DATE,
                           p_group_type           VARCHAR2)
--</EC-DOC>
IS

  lv_sql               VARCHAR2(2000);
  lv_sql_more          VARCHAR2(2000);
  lv_tab               VARCHAR2(100);
  lv_child_tab         VARCHAR2(100);
  lv_obj_parent_col    VARCHAR2(100);
  lv_parent_class      VARCHAR2(100) := ecdp_objects.GetObjClassName(p_parent_object_id);
  lv_fromdate          VARCHAR2(50) := to_char(p_fromdate, 'YYYY-MM-DD"T"HH24:MI:SS');
  lv_todate            VARCHAR2(50) := to_char(p_todate, 'YYYY-MM-DD"T"HH24:MI:SS');

BEGIN

  -- forecast table, version table, parent column
  lv_tab := getFcstTable(p_child_class);
  lv_child_tab := getFcstChildVersionTable(p_child_class);
  lv_obj_parent_col := getFcstParentCol(lv_parent_class,p_group_type);

  IF p_child_class = 'FCTY_CLASS_1' THEN
    lv_sql_more := lv_sql_more || ' AND f.class_name=''PROD_FCTY1_FORECAST''';
  ELSIF p_child_class = 'FCTY_CLASS_2' THEN
    lv_sql_more := lv_sql_more || ' AND f.class_name=''PROD_FCTY2_FORECAST''';
  END IF;

  --Generating the following SQL
  --UPDATE prod_well_forecast f SET f.record_status='A'
  --WHERE f.object_id in (SELECT distinct f2.object_id FROM prod_well_forecast f2, well_version wv
  --                             WHERE f2.object_id = wv.object_id
  --                             AND wv.op_fcty_class_1_id = 'aa'
  --                             AND f2.fcst_scen_no = 1
  --                             AND to_date('2004-05-07T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') >= wv.daytime
  --                             AND to_date('2004-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') < nvl(wv.end_date, to_date('2007-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')+1)
  --                     )
  --AND f.fcst_scen_no = 1;

  lv_sql := 'UPDATE ' || lv_tab || ' f SET f.record_status=''A''';
  lv_sql := lv_sql || ' WHERE f.object_id in ';
  lv_sql := lv_sql || ' (';
  lv_sql := lv_sql || ' SELECT DISTINCT f2.object_id FROM ' || lv_tab || ' f2, ' || lv_child_tab || ' v';
  lv_sql := lv_sql || ' WHERE f2.object_id = v.object_id AND v.' || lv_obj_parent_col || ' = ''' || p_parent_object_id || ''' AND f2.fcst_scen_no=' || p_fcst_scen_no;
  lv_sql := lv_sql || ' AND to_date(''' || lv_todate || ''', ''YYYY-MM-DD"T"HH24:MI:SS'') >= v.daytime';
  lv_sql := lv_sql || ' AND to_date(''' || lv_fromdate || ''', ''YYYY-MM-DD"T"HH24:MI:SS'') < nvl(v.end_date, to_date(''' || lv_fromdate || ''', ''YYYY-MM-DD"T"HH24:MI:SS'')+1)';
  lv_sql := lv_sql || ' ) AND f.fcst_scen_no=' || p_fcst_scen_no;

  -- special case
  IF lv_sql_more IS NOT NULL THEN
    lv_sql := lv_sql || lv_sql_more;
  END IF;

  ecdp_dynsql.execute_statement(lv_sql);

END approveAllObject;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRecentProdForecastNo
-- Description    : retrieve recent production forecast no based on given object_id and daytime
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : prod_forecast
--
-- Using functions: ec_well_version.forecast_type, ec_well_version.forecast_scenario,
--                  getFcstTable,
--                  getFcstChildVersionTable,
--                  getFcstParentCol,
--                  ecdp_objects.GetObjClassName
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getRecentProdForecastNo(p_object_id        VARCHAR2,
                                 p_daytime          DATE)
RETURN NUMBER
--</EC-DOC>
IS
  lc_fcst_data         rc_fcst_data;
  ln_fcst_scen_no      NUMBER;


BEGIN

   -- get the forecast no
  dynCursorGetFcstScenNo(lc_fcst_data,p_object_id,p_daytime);
  LOOP
    FETCH lc_fcst_data INTO ln_fcst_scen_no;
    EXIT WHEN lc_fcst_data%NOTFOUND;

  END LOOP;
  CLOSE lc_fcst_data;

  RETURN ln_fcst_scen_no;
END getRecentProdForecastNo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : dynCursorGetFcstScenNo
-- Description    : return cursor that has the childs of the given object
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : prod_forecast
--
-- Using functions: ec_well_version.forecast_type, ec_well_version.forecast_scenario,
--                  getFcstTable,
--                  ecdp_objects.GetObjClassName
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE dynCursorGetFcstScenNo(p_crs     IN OUT rc_fcst_data,
                            p_object_id    VARCHAR2,
                            p_daytime      DATE
                            )
--</EC-DOC>
IS
  lv_sql               VARCHAR2(2000);
  lv_fcst_data_tab     VARCHAR2(100);
  lv_object_class_name VARCHAR2(100) := ecdp_objects.GetObjClassName(p_object_id);
  lv_daytime           VARCHAR2(50)  := to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS');
  lv_prod_fcst_type    VARCHAR2(50);
  lv_prod_fcst_scen    VARCHAR2(50);

BEGIN
  -- forecast data table and object's version table
  lv_fcst_data_tab := getFcstTable(lv_object_class_name);

  IF lv_object_class_name = 'WELL' THEN
    lv_prod_fcst_type := nvl(ec_well_version.forecast_type(p_object_id,p_daytime,'<='),
                                   ecdp_system.getAttributeText(p_daytime,'PROD_FCST_TYPE'));

    lv_prod_fcst_scen := nvl(ec_well_version.forecast_scenario(p_object_id,p_daytime,'<='),
                                   ecdp_system.getAttributeText(p_daytime,'PROD_FCST_SCENARIO'));

  ELSE
    -- the rest will be using system default
    lv_prod_fcst_type := ecdp_system.getAttributeText(p_daytime,'PROD_FCST_TYPE');
    lv_prod_fcst_scen := ecdp_system.getAttributeText(p_daytime,'PROD_FCST_SCENARIO');
  END IF;


  -- Generating the following cursor's body
  -- CURSOR c_prod_fcst(cp_daytime DATE, cp_fcst_type VARCHAR2, cp_fcst_scenario VARCHAR2) IS
  --  SELECT *
  --  FROM prod_forecast pf
  --  WHERE pf.daytime = (SELECT MAX(pf2.daytime)
  --                      FROM prod_forecast pf2, prod_well_forecast v
  --                     WHERE pf2.daytime <= cp_daytime
  --                      AND pf2.forecast_type=cp_fcst_type
  --                      AND pf2.scenario=cp_fcst_scenario
  --                      AND pf2.fcst_scen_no = v.fcst_scen_no)
  --        AND pf.forecast_type = cp_fcst_type
  --       AND pf.scenario = cp_fcst_scenario;

  lv_sql := 'SELECT pf.fcst_scen_no FROM prod_forecast pf ';
  lv_sql := lv_sql || ' WHERE pf.daytime = (SELECT MAX(pf2.daytime) FROM prod_forecast pf2,' || lv_fcst_data_tab || ' v';
  lv_sql := lv_sql || ' WHERE pf2.daytime <= to_date(''' || lv_daytime || ''', ''YYYY-MM-DD"T"HH24:MI:SS'')';
  lv_sql := lv_sql || ' AND pf2.forecast_type = ''' || lv_prod_fcst_type || '''';
  lv_sql := lv_sql || ' AND pf2.scenario =  ''' || lv_prod_fcst_scen || '''';
  lv_sql := lv_sql || ' AND pf2.fcst_scen_no = v.fcst_scen_no AND v.object_id =''' || p_object_id ||''')' ;
  lv_sql := lv_sql || ' AND pf.forecast_type = ''' || lv_prod_fcst_type || '''';
  lv_sql := lv_sql || ' AND pf.scenario =  ''' || lv_prod_fcst_scen || '''';


  IF lv_prod_fcst_type IS NOT NULL AND lv_prod_fcst_scen IS NOT NULL THEN
     OPEN p_crs FOR lv_sql;
  END IF;
END dynCursorGetFcstScenNo;

END EcBp_ProductionForecast;