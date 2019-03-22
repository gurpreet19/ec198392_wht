CREATE OR REPLACE PACKAGE BODY EcDp_Inj_Performance_Test IS
/****************************************************************
** Package        :  EcDp_Inj_Performance_Test, body part
**
** $Revision: 0.0 $
**
** Purpose        :  Provide data service layer for Injection well, flowline and well bore Performace Test
**
** Documentation  :  www.energy-components.com
**
** Created  : 26/09/2018 Gaurav Chaudhary
**
** Modification history:
**
** Date        Whom      Change description:
** ------      ----- 	 ---------------------------------------------------------------------
** 26/09/2018  chaudgau  Initial
** 24.10.2018  bagdeswa  ECPD-60616: 8 New functions and 8 new procedures added
                                     - [activeWBIsWellResult] added to indentify active WBI in well result
                                     - [showInjFlowlinesWithResult] added to show injection flowlines with result
                                     - [showInjWellsWithResult] added to show injection wells with result
                                     - [showFlowingInjWells] added to show injection flowing wells
                                     - [showNonFlowingInjWells] added to show injection non-flowing wells
                                     - [showPrimaryInjWells] added to show primary injection wells
                                     - [showInjTestDevicesWithResult] added to show injection test devices
                                     - [getInjTestDeviceIDFromResult] added to get ID of injection test device
                                     - [validateTestDate] added to validate the test date
                                     - [acceptTestResult] added to accept test result
                                     - [SetRecordStatusByStatus] added to set record status as per status
                                     - [rejectTestResult] added to reject test result
                                     - [addWellToInjectionTestResult] added to add wells to injection test result
                                     - [removeWbiTestResult] added to remove Well Bore Test result
                                     - [setWbiTestResult] added to set Well Bore Test Result
                                     - [aiSyncIwelResultFromIwel] added for sync up class trigger action
** 02.11.2018 mehtajig  ECPD-60615:  1 procedure and 3 functions added
                                     - [summarizeStablePeriod] added to summarize stable period for injection testing
                                     - [getResultDataClassName] added to get result data class name
                                     - [getSampleDataClassName] added to get sample data class name
                                     - [getTestObjectName] added to get test object name
** 06-12-2018 bagdeswa  ECPD-61757:  Added  proper description for PROCEDURE summarizeStablePeriod, FUNCTION summarizeEvent and FUNCTION getResultDataClassName.
**                                   Modified PROCEDURE setWbiTestDefine with NVL(p_created_by,USER).
**                                   Modified revision history, removed the commented statements and corrected indentation for better readability.
** 12-17-2018 rainanid  ECPD-61483 : Modified Procedure summarizeStablePeriod , removed RAISE_APPLICATION_ERROR condition for records having ACCEPTED status.
****************************************************************/

CURSOR c_defined_objects(cp_test_no VARCHAR2, cp_class_name VARCHAR2) IS
SELECT object_id
FROM itst_object
WHERE test_no = cp_test_no
AND class_name = cp_class_name;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeStatement                                                             --
-- Description    : Used to run Dyanamic sql statements.
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
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
-- Procedure      : deleteChildEvent
-- Description    : Delete child events. Child table is ITST_OBJECT, parent table is ITST_DEFINITION.
--
--
-- Preconditions  : All Child records related to the Test No will be deleted first.
-- Postconditions : Parent Test Record will be deleted finally.
--
-- Using tables   : itst_object, itst_result, itst_graph_definition, itst_event, test_device_inj_result, iwel_result and iflw_result
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteChildEvent(p_test_no NUMBER)
--</EC-DOC>
IS
  CURSOR c_itst_result IS
  SELECT result_no
  FROM itst_result
  WHERE test_no=p_test_no;

  lv_sql VARCHAR2(2000);
  lv_result VARCHAR2(2000);
  lv_result_no NUMBER;
BEGIN
  DELETE FROM itst_event where test_no = p_test_no;
  DELETE FROM itst_graph_define WHERE test_no = p_test_no;
  FOR cur_itst_result IN c_itst_result LOOP
    lv_result_no := cur_itst_result.result_no;
    lv_sql := 'DELETE FROM test_device_inj_result where result_no = '||lv_result_no||'';
    lv_result := executeStatement(lv_sql);
    lv_sql := 'DELETE FROM iwel_result where result_no = '||lv_result_no||'';
    lv_result := executeStatement(lv_sql);
    lv_sql := 'DELETE FROM iflw_result where result_no = '||lv_result_no||'';
    lv_result := executeStatement(lv_sql);
  END LOOP;
  DELETE FROM itst_result WHERE test_no = p_test_no;
  DELETE FROM itst_object WHERE test_no = p_test_no;
END deleteChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : activeWBIsWellResult
-- Description    : Provides a comma separated-list of names of the active well bore intervals (WBI) in a test
--                  WBI's are concidered to be active when sleeve position is gtreater than 0.
--
-- Preconditions  : Configured WBI-name <> NULL
--
-- Postconditions :
-- Using tables   : wbi_inj_result
--
-- Using functions: ec_webo_interval_version, ec_itst_result, ec_webo_bore, ec_webo_interval
--
-- Configuration
-- required       :
--
-- Behaviour      : Uses the actual wbi - webo - well connection
--
---------------------------------------------------------------------------------------------------
FUNCTION activeWBIsWellResult(p_object_id VARCHAR2, p_result_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

 lv2_return_val VARCHAR2(2000) := NULL;

CURSOR c_ActiveWellWBIs IS
   SELECT object_id, ec_webo_interval_version.name(object_id,ec_itst_result.daytime(p_result_no),'<=') wbi_name, sleeve_pos
   FROM   wbi_inj_result
   WHERE sleeve_pos > 0
   AND ec_webo_bore.well_id(ec_webo_interval.well_bore_id(object_id)) = p_object_id
   AND result_no = p_result_no
   ORDER BY wbi_name;
BEGIN
  FOR v_WBI IN c_ActiveWellWBIs LOOP
    IF lv2_return_val IS NULL THEN
      lv2_return_val := v_WBI.wbi_Name;
    ELSE
      lv2_return_val := lv2_return_val ||', '|| v_WBI.wbi_Name;
    END IF;
  END LOOP;
  RETURN lv2_return_val;
END activeWBIsWellResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showDefinedFlowlines
-- Description    : Returns a concatenated string of names for flowline objects defined in a performance test.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: ec_itst_definition.daytime, ec_flwl_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showDefinedFlowlines(p_test_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_result_string VARCHAR2(2000);
  ld_test_date DATE;
  lv2_name flwl_version.name%TYPE;
BEGIN
  ld_test_date := ec_itst_definition.daytime(p_test_no);
  IF ld_test_date IS NOT NULL THEN
    FOR cur_rec IN c_defined_objects(p_test_no, 'FLOWLINE') LOOP
      lv2_name := ec_flwl_version.name(cur_rec.object_id, ld_test_date,'<=');
      IF c_defined_objects%ROWCOUNT = 1 THEN
         lv2_result_string := lv2_name;
      ELSE
         lv2_result_string := lv2_result_string || ', ' || lv2_name;
      END IF;
    END LOOP;
  END IF;
  RETURN lv2_result_string;
END showDefinedFlowlines;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showDefinedWells
-- Description    : Returns a concatenated string of names for well objects defined in a performance test.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: ec_itst_definition.daytime, ec_well_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showDefinedWells(p_test_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_result_string VARCHAR2(1000);
  ld_test_date DATE;
  lv2_name well_version.name%TYPE;
BEGIN
  ld_test_date := ec_itst_definition.daytime(p_test_no);
  IF ld_test_date IS NOT NULL THEN
    FOR cur_rec IN c_defined_objects(p_test_no, 'WELL') LOOP
      lv2_name := ec_well_version.name(cur_rec.object_id, ld_test_date,'<=');
      IF c_defined_objects%ROWCOUNT = 1 THEN
         lv2_result_string := lv2_name;
      ELSE
         lv2_result_string := lv2_result_string || ', ' || lv2_name;
      END IF;
    END LOOP;
  END IF;
  RETURN lv2_result_string;
END showDefinedWells;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showDefinedTestDevice
-- Description    : Returns the test device object defined in a performance test.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: ec_itst_definition.daytime
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showDefinedTestDevice(p_test_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_result_string VARCHAR2(1000);
  ld_test_date DATE;
BEGIN
   ld_test_date := ec_itst_definition.daytime(p_test_no);
   IF ld_test_date IS NOT NULL THEN
      FOR cur_rec IN c_defined_objects(p_test_no, 'TEST_DEVICE') LOOP
         lv2_result_string := cur_rec.object_id;
      END LOOP;
   END IF;
   RETURN lv2_result_string;
END showDefinedTestDevice;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : countChildEvent
-- Description    : Count child events exist for the parent test. Child table is ITST_OBJECT, parent table is ITST_DEFINITION.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : itst_object
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION countChildEvent(p_test_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_child_event  IS
    SELECT count(object_id) totalrecord
    FROM itst_object
    WHERE test_no = p_test_no;

 ln_child_record NUMBER;
BEGIN
  ln_child_record := 0;
  FOR cur_child_event IN c_child_event LOOP
    ln_child_record := cur_child_event.totalrecord ;
  END LOOP;
  RETURN ln_child_record;
END countChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : processTestDeviceSampleRates
-- Description    : Processes rate figures on every sample record for a given test device and period.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TEST_DEVICE_INJ_SAMPLE, ITST_OBJECT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : p_from_daytime = p_to_daytime >> process a single record
--                  p_to_daytime IS NULL >> process from daytime up to date.
--
---------------------------------------------------------------------------------------------------
PROCEDURE processTestDeviceSampleRates(p_object_id VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
  ld_NextTestStart DATE;
BEGIN
  -- lock check, if samples are in locked period update is not allowed
  EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', p_from_daytime, p_to_daytime,' Running processTestDeviceSampleRates, direct lock detected', p_object_id);

  IF p_to_daytime IS NOT NULL THEN
    ld_NextTestStart := p_to_daytime;
  ELSE
    select (min(pd.daytime) - 1/288) into ld_NextTestStart from itst_definition pd, itst_object po where po.test_no = pd.test_no and po.object_id = p_object_id and pd.daytime > p_from_daytime;
  END IF;

  UPDATE TEST_DEVICE_INJ_SAMPLE
  SET LAST_UPDATED_BY = Nvl(p_user,USER), LAST_UPDATED_DATE = Ecdp_Timestamp.getCurrentSysdate
  WHERE OBJECT_ID = p_object_id
  AND DAYTIME >= p_from_daytime
  AND DAYTIME <= nvl(ld_NextTestStart, sysdate);

END processTestDeviceSampleRates;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setWbiTestDefine
-- Description    : instantiate well bore interval test define for the given well
--
-- Preconditions  :
-- Postconditions : itst_object will have empty rows for given well's well bore interval
--
-- Using tables   : ITST_OBJECT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setWbiTestDefine (p_object_id     VARCHAR2, -- WELL OBJECT ID
                            p_daytime       DATE,     -- PERFORMANCE TEST START DATE
                            p_test_no       NUMBER,
                            p_interval_type VARCHAR2 DEFAULT 'DIACS',
                            p_created_by    VARCHAR2 DEFAULT NULL)
IS

  ln_count_wbi      NUMBER;
  lv_wbi_class_name VARCHAR2(32);

  -- Find well bore interval which active at performance test start date
  CURSOR c_wbi(cp_object_id VARCHAR2, cp_daytime DATE, cp_interval_type VARCHAR2) IS
  SELECT wbi.object_id AS object_id
  FROM webo_interval_version wbiv, webo_interval wbi, webo_bore wb, well_version wv, well w
  WHERE wbiv.object_id = wbi.object_id
  AND   wbi.well_bore_id = wb.object_id
  AND   wb.well_id = w.object_id
  AND   w.object_id = cp_object_id
  AND   wv.object_id = cp_object_id
  AND   wbiv.interval_type = cp_interval_type
  AND   wbiv.daytime <= cp_daytime
  AND   Nvl(wbiv.end_date, cp_daytime+1) > cp_daytime
  AND   wv.daytime <= cp_daytime
  AND   Nvl(wv.end_date, cp_daytime+1) > cp_daytime;

BEGIN
  lv_wbi_class_name := 'WELL_BORE_INTERVAL';
  -- check existence of wbi of same test number and of a well
  SELECT count(*) INTO ln_count_wbi
  FROM itst_object po
  WHERE po.class_name = lv_wbi_class_name
  AND po.test_no = p_test_no
  AND po.object_id IN
    (
      SELECT wbi.object_id AS object_id
      FROM webo_interval wbi, webo_bore wb, well w
      WHERE wbi.well_bore_id = wb.object_id
      AND   wb.well_id = w.object_id
      AND   w.object_id = p_object_id
    );

  IF ln_count_wbi = 0 THEN
    FOR curWbi IN c_wbi(p_object_id, p_daytime, p_interval_type) LOOP
      INSERT INTO itst_object (object_id, test_no, class_name, created_by, created_date)
      VALUES (curWbi.object_id, p_test_no, lv_wbi_class_name, NVL(p_created_by,USER), Ecdp_Timestamp.getCurrentSysdate);
    END LOOP;
  END IF;
END setWbiTestDefine;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : removeWbiTestDefine
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : ITST_OBJECT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE removeWbiTestDefine (p_object_id     VARCHAR2, -- WELL OBJECT ID
                               p_test_no       NUMBER)
IS

-- Find well bore interval which connected to the well
CURSOR c_wbi(cp_object_id VARCHAR2, cp_test_no NUMBER) IS
  SELECT wbi.object_id AS object_id
  FROM webo_interval wbi, webo_bore wb, well w
  WHERE wbi.well_bore_id = wb.object_id
  AND   wb.well_id = w.object_id
  AND   w.object_id = cp_object_id
  AND   wbi.object_id IN (SELECT po.object_id FROM itst_object po WHERE po.test_no = cp_test_no);

BEGIN
  FOR curWbi IN c_wbi(p_object_id, p_test_no) LOOP
    DELETE FROM itst_graph_define pt_gd
      WHERE pt_gd.object_id = curWbi.object_id
      AND pt_gd.test_no     = p_test_no;
    DELETE FROM itst_object po
      WHERE po.class_name = 'WELL_BORE_INTERVAL'
      AND po.object_id    = curWbi.object_id
      AND po.test_no      = p_test_no;
  END LOOP;
END removeWbiTestDefine;

---------------------------------------------------------------------------------------------------
-- Function       : showInjFlowlinesWithResult
-- Description    : Returns a concatenated string of names for injection flowline objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : iflw_result
--
--
--
-- Using functions: ec_itst_result.daytime, ec_flwl_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showInjFlowlinesWithResult(p_result_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_flwl_result(cp_result_no NUMBER) IS
SELECT object_id
FROM iflw_result
WHERE result_no = cp_result_no;

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name flwl_version.name%TYPE;

BEGIN
  ld_test_date := ec_itst_result.daytime(p_result_no);
  IF ld_test_date IS NOT NULL THEN
    FOR cur_rec IN c_flwl_result(p_result_no) LOOP
      lv2_name := ec_flwl_version.name(cur_rec.object_id, ld_test_date,'<=');
      IF c_flwl_result%ROWCOUNT = 1 THEN
         lv2_result_string := lv2_name;
      ELSE
         lv2_result_string := lv2_result_string || ', ' || lv2_name;
      END IF;
    END LOOP;
  END IF;
  RETURN lv2_result_string;
END showInjFlowlinesWithResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showInjWellsWithResult
-- Description    : Returns a concatenated string of names for injection well objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : iwel_result
--
--
--
-- Using functions: ec_itst_result.daytime, ec_well_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showInjWellsWithResult(p_result_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_well_result(cp_result_no NUMBER) IS
SELECT object_id
FROM iwel_result
WHERE result_no = cp_result_no;

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name well_version.name%TYPE;

BEGIN
  ld_test_date := ec_itst_result.daytime(p_result_no);
  IF ld_test_date IS NOT NULL THEN
    FOR cur_rec IN c_well_result(p_result_no) LOOP
      lv2_name := ec_well_version.name(cur_rec.object_id, ld_test_date,'<=');
      IF c_well_result%ROWCOUNT = 1 THEN
         lv2_result_string := lv2_name;
      ELSE
         lv2_result_string := lv2_result_string || ', ' || lv2_name;
      END IF;
    END LOOP;
  END IF;
  RETURN lv2_result_string;
END showInjWellsWithResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showFlowingInjWells
-- Description    : Returns a concatenated string of names for flowing injeciton well objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : iwel_result
--
--
--
-- Using functions: ec_itst_result.daytime, ec_well_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showFlowingInjWells(p_result_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_well_result IS
SELECT object_id
FROM iwel_result
WHERE result_no = p_result_no
AND Nvl(flowing_ind,'N') = 'Y';

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name well_version.name%TYPE;

BEGIN
  ld_test_date := ec_itst_result.daytime(p_result_no);
  IF ld_test_date IS NOT NULL THEN
    FOR cur_rec IN c_well_result LOOP
      lv2_name := ec_well_version.name(cur_rec.object_id, ld_test_date,'<=');
      IF c_well_result%ROWCOUNT = 1 THEN
         lv2_result_string := lv2_name;
      ELSE
         lv2_result_string := lv2_result_string || ', ' || lv2_name;
      END IF;
    END LOOP;
  END IF;
  RETURN lv2_result_string;
END showFlowingInjWells;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showNonFlowingInjWells
-- Description    : Returns a concatenated string of names non flowing injection well objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : iwel_result
--
--
--
-- Using functions: ec_itst_result.daytime, ec_well_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showNonFlowingInjWells(p_result_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_well_result IS
SELECT object_id
FROM iwel_result
WHERE result_no = p_result_no
AND Nvl(flowing_ind,'N') = 'N';

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name well_version.name%TYPE;

BEGIN
  ld_test_date := ec_itst_result.daytime(p_result_no);
  IF ld_test_date IS NOT NULL THEN
    FOR cur_rec IN c_well_result LOOP
      lv2_name := ec_well_version.name(cur_rec.object_id, ld_test_date,'<=');
        IF c_well_result%ROWCOUNT = 1 THEN
          lv2_result_string := lv2_name;
        ELSE
          lv2_result_string := lv2_result_string || ', ' || lv2_name;
        END IF;
    END LOOP;
  END IF;
  RETURN lv2_result_string;
END showNonFlowingInjWells;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showPrimaryInjWells
-- Description    : Returns a concatenated string of names of primary injection well objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : iwel_result
--
--
--
-- Using functions: ec_itst_result.daytime, ec_well_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showPrimaryInjWells(p_result_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_well_result IS
SELECT object_id
FROM iwel_result
WHERE result_no = p_result_no
AND Nvl(primary_ind,'N') = 'Y';

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name well_version.name%TYPE;

BEGIN
  ld_test_date := ec_itst_result.daytime(p_result_no);
  IF ld_test_date IS NOT NULL THEN
    FOR cur_rec IN c_well_result LOOP
      lv2_name := ec_well_version.name(cur_rec.object_id, ld_test_date,'<=');
      IF c_well_result%ROWCOUNT = 1 THEN
         lv2_result_string := lv2_name;
      ELSE
         lv2_result_string := lv2_result_string || ', ' || lv2_name;
      END IF;
    END LOOP;
  END IF;
  RETURN lv2_result_string;
END showPrimaryInjWells;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showInjTestDevicesWithResult
-- Description    : Returns a concatenated string of names for injection test device objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : test_device_inj_result
--
--
--
-- Using functions: ec_itst_result.daytime, ec_TEST_DEVICE_VERSION.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showInjTestDevicesWithResult(p_result_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_td_result(cp_result_no NUMBER) IS
SELECT object_id
FROM test_device_inj_result
WHERE result_no = cp_result_no;

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name test_device_version.name%TYPE;

BEGIN
  ld_test_date := ec_itst_result.daytime(p_result_no);
  IF ld_test_date IS NOT NULL THEN
    FOR cur_rec IN c_td_result(p_result_no) LOOP
      lv2_name := ec_test_device_version.name(cur_rec.object_id, ld_test_date,'<=');
      IF c_td_result%ROWCOUNT = 1 THEN
         lv2_result_string := lv2_name;
      ELSE
         lv2_result_string := lv2_result_string || ', ' || lv2_name;
      END IF;
    END LOOP;
  END IF;
  RETURN lv2_result_string;
END showInjTestDevicesWithResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjTestDeviceIDFromResult
-- Description    : Returns the injeciton test device object_id for the given result.
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : test_device_inj_result
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Only one test device for each test are allowed, returns null if it exists several test devices.
--
---------------------------------------------------------------------------------------------------
FUNCTION getInjTestDeviceIDFromResult(
               p_result_no    NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS
  CURSOR c_td_result IS
  SELECT object_id
  FROM test_device_inj_result
  WHERE result_no = p_result_no;

  lv2_td_id       test_device_inj_result.object_id%TYPE;
BEGIN
  FOR curTestDevice IN c_td_result LOOP
    lv2_td_id := curTestDevice.object_id;
    IF c_td_result%ROWCOUNT > 1 THEN
      lv2_td_id := NULL;
    END IF;
  END LOOP;
  RETURN lv2_td_id;
END getInjTestDeviceIDFromResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateTestDate
-- Description    : Raise exception if future date is entered
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateTestDate(
            p_daytime        DATE
            ) IS
--</EC-DOC>
BEGIN
  IF p_daytime >= trunc(Ecdp_Timestamp.getCurrentSysdate(),'DD') + 1 THEN
    RAISE_APPLICATION_ERROR(-20109,'Future date is not allowed');
  END IF;
END validateTestDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : acceptTestResult
-- Description    : Raise exception if future date is entered
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : iwel_result , itst_result , test_device_inj_result
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE acceptTestResult (p_result_no NUMBER
                           ,p_user VARCHAR2 DEFAULT NULL)
IS
  lv2_alt_code            VARCHAR2(240);
  lv_record_status        VARCHAR2(10);
  ln_access_level         NUMBER;
  ld_iwel_valid_from_date DATE;
  ld_itst_valid_from_date DATE;
  lv2_object_id           VARCHAR2(32);
  ld_iwel_valid_to_date   DATE;
  ld_itst_valid_to_date   DATE;
	lv2_addon_rev_text      VARCHAR2(100);

  CURSOR c_iwel_result(cp_result_no NUMBER) IS
  SELECT object_id, valid_from_date, end_date FROM iwel_result WHERE result_no=cp_result_no;
BEGIN
  ld_itst_valid_from_date := ec_itst_result.valid_from_date(p_result_no);
  ld_itst_valid_to_date := ec_itst_result.end_date(p_result_no);
	lv2_addon_rev_text := ' performed at PT.0023.';

  FOR curiwel_result IN c_iwel_result(p_result_no) LOOP
    lv2_object_id := curiwel_result.object_id;
    ld_iwel_valid_from_date := curiwel_result.valid_from_date;
    ld_iwel_valid_to_date := curiwel_result.end_date;
  END LOOP;

  lv2_alt_code := ec_prosty_codes.alt_code('ACCEPTED','WELL_TEST_STATUS');

  SELECT record_status
  into lv_record_status
  FROM itst_result
  WHERE result_no = p_result_no;

  SELECT MAX(tba.level_id)
  INTO ln_access_level
  FROM T_BASIS_ACCESS tba, T_BASIS_OBJECT tbo
  WHERE tba.OBJECT_ID = tbo.OBJECT_ID
  AND tbo.object_name =
      '/com.ec.prod.pt.screens/inj_test_result/accept_button'
  AND role_id in (select role_id from t_basis_userrole where user_id = p_user);

  -- current record_status='A'
  IF lv_record_status = 'A' THEN
    -- must have access to modify 'A'
    IF ln_access_level >= 60 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE itst_result
        SET status          = 'ACCEPTED',
            last_updated_by = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE iwel_result
        SET status          = 'ACCEPTED',
            last_updated_by = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        UPDATE itst_result
        SET status          = 'ACCEPTED',
            record_status   = lv2_alt_code,
            last_updated_by = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE iwel_result
        SET status          = 'ACCEPTED',
            record_status   = lv2_alt_code,
            last_updated_by = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE test_device_inj_result
        SET record_status = lv2_alt_code,
            last_updated_by = Nvl(p_user,USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
      END IF;
    ELSE
      RAISE_APPLICATION_ERROR(-20228,
                              'You do not have enough access to update well test.');
    END IF;
  -- current record_status='V'
  ELSIF lv_record_status = 'V' THEN
    -- must have access to modify 'V' or higher
    IF ln_access_level >= 50 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE itst_result
        SET status          = 'ACCEPTED',
            last_updated_by = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE iwel_result
        SET status          = 'ACCEPTED',
            last_updated_by = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;

      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
           (lv2_alt_code = 'A' and ln_access_level = 60) THEN
          UPDATE itst_result
          SET status = 'ACCEPTED',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
          WHERE result_no = p_result_no;
          UPDATE iwel_result
          SET status = 'ACCEPTED',
                 record_status   = lv2_alt_code,
                 last_updated_by = Nvl(p_user, USER),
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 rev_no = rev_no + 1,
                 rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
          WHERE result_no = p_result_no;
          UPDATE test_device_inj_result
          SET record_status = lv2_alt_code,
                 last_updated_by = Nvl(p_user,USER),
                 last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                 rev_no = rev_no + 1,
                 rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
          WHERE result_no = p_result_no;
        ELSE
          RAISE_APPLICATION_ERROR(-20228,
                                  'You do not have enough access to update well test.');
        END IF;
      END IF;
    ELSE
      RAISE_APPLICATION_ERROR(-20228,
                              'You do not have enough access to update well test.');
    END IF;
  -- current record_status='P'
  ELSIF lv_record_status = 'P' THEN
    -- This is when status is determined by status processes
    IF lv2_alt_code IS NULL THEN
      -- current record_status is 'P', must run status process first to Verify record
      RAISE_APPLICATION_ERROR(-20632,
                               'Well Test must be Verified first');
      -- This is when status is determined by prosty_code.alt_code
    ELSIF lv2_alt_code IS NOT NULL THEN
      IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
         (lv2_alt_code = 'A' and ln_access_level = 60) OR
         (lv2_alt_code = 'P' and ln_access_level >= 20) THEN
        UPDATE itst_result
        SET status            = 'ACCEPTED',
            record_status     = lv2_alt_code,
            last_updated_by   = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE iwel_result
        SET status            = 'ACCEPTED',
            record_status     = lv2_alt_code,
            last_updated_by   = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE test_device_inj_result
        SET record_status     = lv2_alt_code,
            last_updated_by   = Nvl(p_user,USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Accepted at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
      ELSE
        RAISE_APPLICATION_ERROR(-20228,
                                'You do not have enough access to update well test.');
      END IF;
    END IF;
  END IF;
  setRecordStatusByStatus(p_result_no, p_user);
END acceptTestResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SetRecordStatusByStatus
-- Description    : Updates record status on IT-tables for all records related to a certain injection
--                  test result when changing the status on ITST_RESULT.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : itst_result, iwel_result, iflw_result, test_device_inj_result, itst_definition, itst_object, itst_event
--                  iwel_sample, iflw_sample, TEST_DEVICE_INJ_SAMPLE
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetRecordStatusByStatus(p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL)
IS
  lv_record_status VARCHAR2(16);
  lr_result itst_result%ROWTYPE;
BEGIN
  lr_result := ec_itst_result.row_by_pk(p_result_no);
  lv_record_status := ec_prosty_codes.alt_code(lr_result.status, 'WELL_TEST_STATUS');
  IF lv_record_status IS NOT NULL THEN
    UPDATE itst_result
    SET record_status = lv_record_status,
        last_updated_by = Nvl(p_user,USER),
        last_updated_date = Ecdp_Timestamp.getCurrentSysdate
    WHERE result_no = p_result_no;
    UPDATE iwel_result
    SET record_status = lv_record_status,
        last_updated_by = Nvl(p_user,USER),
        last_updated_date = Ecdp_Timestamp.getCurrentSysdate
    WHERE result_no = p_result_no;
    UPDATE iflw_result
    SET record_status = lv_record_status,
        last_updated_by = Nvl(p_user,USER),
        last_updated_date = Ecdp_Timestamp.getCurrentSysdate
    WHERE result_no = p_result_no;
    UPDATE test_device_inj_result
    SET record_status = lv_record_status,
        last_updated_by = Nvl(p_user,USER),
        last_updated_date = Ecdp_Timestamp.getCurrentSysdate
    WHERE result_no = p_result_no;
    UPDATE wbi_inj_result
    SET record_status = lv_record_status,
        last_updated_by = Nvl(p_user,USER),
        last_updated_date = Ecdp_Timestamp.getCurrentSysdate
    WHERE result_no = p_result_no;
    IF lr_result.summarised_ind = 'Y' THEN
      FOR cur_iwel_rec IN c_defined_objects(lr_result.test_no, 'WELL') LOOP
        UPDATE iwel_sample
        SET record_status = lv_record_status,
            last_updated_by = Nvl(p_user,USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate
        WHERE object_id = cur_iwel_rec.object_id
        AND daytime BETWEEN lr_result.daytime AND lr_result.end_date;
      END LOOP;
      FOR cur_pflw_rec IN c_defined_objects(lr_result.test_no, 'FLOWLINE') LOOP
        UPDATE iflw_sample
        SET record_status = lv_record_status,
            last_updated_by = Nvl(p_user,USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate
        WHERE object_id = cur_pflw_rec.object_id
        AND daytime BETWEEN lr_result.daytime AND lr_result.end_date;
      END LOOP;
      FOR cur_eqpm_rec IN c_defined_objects(lr_result.test_no, 'TEST_DEVICE') LOOP
        UPDATE test_device_inj_sample
        SET record_status = lv_record_status,
            last_updated_by = Nvl(p_user,USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate
        WHERE object_id = cur_eqpm_rec.object_id
        AND daytime BETWEEN lr_result.daytime AND lr_result.end_date;
      END LOOP;
      FOR cur_wbi_rec IN c_defined_objects(lr_result.test_no, 'WELL_BORE_INTERVAL') LOOP
        UPDATE wbi_inj_sample
        SET record_status = lv_record_status,
            last_updated_by = Nvl(p_user,USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate
        WHERE object_id = cur_wbi_rec.object_id
        AND daytime BETWEEN lr_result.daytime AND lr_result.end_date;
      END LOOP;
    END IF;
  END IF;
END SetRecordStatusByStatus;

---------------------------------------------------------------------------------------------------
-- Procedure      : rejectTestResult
-- Description    : This procedure updates status on test result to be REJECTED
--                  alt_code from prosty_codes, and last_updated_by
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : ITST_RESULT, IWEL_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE rejectTestResult (p_result_no NUMBER
                           ,p_user VARCHAR2 DEFAULT NULL)
IS
  lv2_alt_code            VARCHAR2(240);
  lv_record_status        VARCHAR2(10);
  ln_access_level         NUMBER;
  ld_iwel_valid_from_date DATE;
  ld_itst_valid_from_date DATE;
  lv2_object_id           VARCHAR2(32);
  ld_iwel_valid_to_date   DATE;
  ld_itst_valid_to_date   DATE;
  lv2_addon_rev_text      VARCHAR2(100);

  CURSOR c_iwel_result(cp_result_no NUMBER) IS
  SELECT object_id, valid_from_date, end_date FROM iwel_result WHERE result_no=cp_result_no;

BEGIN
  ld_itst_valid_from_date := ec_itst_result.valid_from_date(p_result_no);
  ld_itst_valid_to_date := ec_itst_result.end_date(p_result_no);
  lv2_addon_rev_text := ' performed at PT.0023.';

  FOR curiwel_result IN c_iwel_result(p_result_no) LOOP
    lv2_object_id := curiwel_result.object_id;
    ld_iwel_valid_from_date := curiwel_result.valid_from_date;
    ld_iwel_valid_to_date := curiwel_result.end_date;
  END LOOP;

  lv2_alt_code := ec_prosty_codes.alt_code('REJECTED','WELL_TEST_STATUS');

  SELECT record_status
  INTO lv_record_status
  FROM itst_result
  WHERE result_no = p_result_no;

  SELECT MAX(tba.level_id)
  INTO ln_access_level
  FROM T_BASIS_ACCESS tba, T_BASIS_OBJECT tbo
  WHERE tba.OBJECT_ID = tbo.OBJECT_ID
  AND tbo.object_name =
      '/com.ec.prod.pt.screens/inj_test_result/reject_button'
  AND role_id in (select role_id from t_basis_userrole where user_id = p_user);

  -- current record_status='A'
  IF lv_record_status = 'A' THEN
    -- must have access to modify 'A'
    IF ln_access_level >= 60 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE itst_result
        SET status            = 'REJECTED',
            last_updated_by   = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE iwel_result
        SET status            = 'REJECTED',
            last_updated_by   = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        UPDATE itst_result
        SET status            = 'REJECTED',
            record_status     = lv2_alt_code,
            last_updated_by   = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE iwel_result
        SET status            = 'REJECTED',
            record_status     = lv2_alt_code,
            last_updated_by   = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE test_device_inj_result
        SET record_status = lv2_alt_code,
            last_updated_by = Nvl(p_user,USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
      END IF;
    ELSE
      RAISE_APPLICATION_ERROR(-20227,
                              'You do not have enough access to reject the well test.');
    END IF;
  -- current record_status='V'
  ELSIF lv_record_status = 'V' THEN
    -- must have access to modify 'V' or higher
    IF ln_access_level >= 50 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE itst_result
        SET status            = 'REJECTED',
            last_updated_by   = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE iwel_result
        SET status            = 'REJECTED',
            last_updated_by   = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
           (lv2_alt_code = 'A' and ln_access_level = 60) THEN
          UPDATE itst_result
          SET status            = 'REJECTED',
              record_status     = lv2_alt_code,
              last_updated_by   = Nvl(p_user, USER),
              last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
              rev_no = rev_no + 1,
              rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
          WHERE result_no = p_result_no;
          UPDATE iwel_result
          SET status            = 'REJECTED',
              record_status     = lv2_alt_code,
              last_updated_by   = Nvl(p_user, USER),
              last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
              rev_no = rev_no + 1,
              rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
          WHERE result_no = p_result_no;
          UPDATE test_device_inj_result
          SET record_status     = lv2_alt_code,
              last_updated_by   = Nvl(p_user,USER),
              last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
              rev_no = rev_no + 1,
              rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
          WHERE result_no = p_result_no;
        ELSE
          RAISE_APPLICATION_ERROR(-20227,
                                  'You do not have enough access to reject the well test.');
        END IF;
      END IF;
    ELSE
      RAISE_APPLICATION_ERROR(-20227,
                              'You do not have enough access to reject the well test.');
    END IF;
  -- current record_status='P'
  ELSIF lv_record_status = 'P' THEN
    -- This is when status is determined by status processes
    IF lv2_alt_code IS NULL THEN
      -- current record_status is 'P', must run status process first to Verify record
      RAISE_APPLICATION_ERROR(-20632,
                              'Well Test must be Verified first');
    -- This is when status is determined by prosty_code.alt_code
    ELSIF lv2_alt_code IS NOT NULL THEN
      IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
         (lv2_alt_code = 'A' and ln_access_level = 60) OR
         (lv2_alt_code = 'P' and ln_access_level >= 20) THEN
        UPDATE itst_result
        SET status            = 'REJECTED',
            record_status     = lv2_alt_code,
            last_updated_by   = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE iwel_result
        SET status            = 'REJECTED',
            record_status     = lv2_alt_code,
            last_updated_by   = Nvl(p_user, USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
        UPDATE test_device_inj_result
        SET record_status     = lv2_alt_code,
            last_updated_by   = Nvl(p_user,USER),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            rev_no = rev_no + 1,
            rev_text = 'Rejected, at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
        WHERE result_no = p_result_no;
      ELSE
        RAISE_APPLICATION_ERROR(-20227,
                                'You do not have enough access to reject the well test.');
      END IF;
    END IF;
  END IF;
  setRecordStatusByStatus(p_result_no, p_user);
END rejectTestResult;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Procedure      : addWellToInjectionTestResult
-- Description    : Procedure used to add well while inserting injection test result
--
-- Using tables   : TV_ACTIVE_INJ_RESULT_WELL
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE addWellToInjectionTestResult(p_object_type VARCHAR2,
                                       p_object_id VARCHAR2,
                                       p_result_no NUMBER,
                                       p_daytime DATE,
                                       p_user_id VARCHAR2)
--<EC-DOC>
IS
  data_class_name VARCHAR2(32) := 'IWEL_RESULT_1';
  lv2_data_class VARCHAR2(32);
  ln_result NUMBER;
BEGIN
  SELECT COUNT(*) into ln_result
  FROM tv_active_inj_result_well arw
  WHERE arw.RESULT_NO = p_result_no;
  IF p_object_type = 'WELL' THEN
    IF ln_result = 0 THEN
      INSERT INTO tv_active_inj_result_well (result_no, object_id, data_class_name, created_by) values (p_result_no, p_object_id, lv2_data_class, p_user_id);
    END IF;
  END IF;
END addWellToInjectionTestResult;

---------------------------------------------------------------------------------------------------
-- Procedure      : removeWbiTestResult
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WBI_INJ_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE removeWbiTestResult (p_object_id     VARCHAR2, -- WELL OBJECT ID
                               p_result_no     NUMBER)
IS

-- Find well bore interval which connected to the well
CURSOR c_wbi(cp_object_id VARCHAR2, cp_result_no NUMBER) IS
  SELECT wbi.object_id AS object_id
  FROM webo_interval wbi, webo_bore wb, well w
  WHERE wbi.well_bore_id = wb.object_id
  AND   wb.well_id = w.object_id
  AND   w.object_id = cp_object_id
  AND   wbi.object_id IN (SELECT wr.object_id FROM wbi_inj_result wr WHERE wr.result_no = cp_result_no);

BEGIN
  FOR curWbi IN c_wbi(p_object_id, p_result_no) LOOP
    DELETE FROM wbi_inj_result wbi
    WHERE wbi.result_no = p_result_no
    AND   wbi.object_id = curWbi.object_id;
  END LOOP;
END removeWbiTestResult;

---------------------------------------------------------------------------------------------------
-- Procedure      : setWbiTestResult
-- Description    : instantiate well bore interval test result for the given well
--
-- Preconditions  :
-- Postconditions : wbi_inj_result will have empty rows for given well's well bore interval
--
-- Using tables   : WBI_INJ_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setWbiTestResult (p_object_id     VARCHAR2, -- WELL OBJECT ID
                            p_daytime       DATE,     -- STABLE PERIOD START DATE
                            p_result_no     NUMBER,
                            p_interval_type VARCHAR2 DEFAULT 'DIACS',
                            p_created_by    VARCHAR2 DEFAULT NULL)
IS

  lv_created_by     VARCHAR2(32);
  ln_count_wbi      NUMBER;

-- Find well bore interval which active at stable period start date
CURSOR c_wbi(cp_object_id VARCHAR2, cp_daytime DATE, cp_interval_type VARCHAR2) IS
  SELECT wbi.object_id AS object_id
  FROM webo_interval_version wbiv, webo_interval wbi, webo_bore wb, well_version wv, well w
  WHERE wbiv.object_id = wbi.object_id
  AND   wbi.well_bore_id = wb.object_id
  AND   wb.well_id = w.object_id
  AND   w.object_id = cp_object_id
  AND   wv.object_id = cp_object_id
  AND   wbiv.interval_type = cp_interval_type
  AND   wbiv.daytime <= cp_daytime
  AND   Nvl(wbiv.end_date, cp_daytime+1) > cp_daytime
  AND   wv.daytime <= cp_daytime
  AND   Nvl(wv.end_date, cp_daytime+1) > cp_daytime;

BEGIN
  IF p_created_by IS NULL THEN
    lv_created_by := User;
  ELSE
    lv_created_by := p_created_by;
  END IF;
  -- check existence of wbi of same result number and of a well
  SELECT count(*) INTO ln_count_wbi
  FROM wbi_inj_result wr
  WHERE wr.result_no = p_result_no
  AND wr.object_id IN
    (
      SELECT wbi.object_id AS object_id
      FROM webo_interval wbi, webo_bore wb, well w
      WHERE wbi.well_bore_id = wb.object_id
      AND   wb.well_id = w.object_id
      AND   w.object_id = p_object_id
    );
  IF ln_count_wbi = 0 THEN
    FOR curWbi IN c_wbi(p_object_id, p_daytime, p_interval_type) LOOP
      INSERT INTO wbi_inj_result (object_id, result_no, created_by, created_date)
      VALUES (curWbi.object_id, p_result_no, NVL(p_created_by,USER), Ecdp_Timestamp.getCurrentSysdate);
    END LOOP;
  END IF;
END setWbiTestResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : summarizeEvent
-- Description    : Returns the summerised event sample value
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION summarizeEvent(p_test_no NUMBER,
                        p_object_id VARCHAR2,
                        p_start_date DATE,
                        p_end_date DATE,
                        p_event_type VARCHAR2,
                        p_target_column VARCHAR2,
                        p_result_data_class VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_tdev_out_bsw (cp_test_no NUMBER, cp_object_id VARCHAR2, cp_start_date DATE, cp_end_date DATE, cp_event_type VARCHAR2) IS
  SELECT quantity, unit
  FROM itst_event
  WHERE test_no = cp_test_no
  AND object_id = cp_object_id
  AND use_in_result = 'Y'
  AND event_type = cp_event_type
  AND daytime >= cp_start_date
  AND daytime < cp_end_date;

  ln_count        NUMBER  :=  0;
  ln_event_total 	NUMBER  :=  0;
  ln_return_val   NUMBER  :=  NULL;
  ln_conv_val     NUMBER  :=  0;
  lv2_target_UOM  VARCHAR2(32);
  lv2_attribute   VARCHAR2(32);
  ld_TestStart    DATE;

BEGIN
  DELETE FROM t_temptext WHERE id = 'summarizeEvent';
  SELECT attribute_name INTO lv2_attribute FROM class_attribute_cnfg a WHERE a.class_name = p_result_data_class AND a.db_sql_syntax = p_target_column;
  lv2_target_uom := ecdp_classmeta.getUomCode(p_result_data_class,lv2_attribute);
  --if lv2_target_uom was a measurement type
  lv2_target_uom := ecdp_unit.getunitfromlogical(lv2_target_uom);
  --ecdp_dynsql.writetemptext('summarizeEvent','Have found the following data unit ' || lv2_target_uom || ' for column ' || p_target_column || ' in TEST_DEVICE_INJ_SAMPLE and object ' || p_object_id);
  FOR c_event IN c_tdev_out_bsw (p_test_no, p_object_id, p_start_date, p_end_date, p_event_type) LOOP
    --ecdp_dynsql.writetemptext('summarizeEvent','Value in unit ' || c_event.unit || ' : ' || c_event.quantity);
    ln_conv_val := ecdp_unit.convertValue(c_event.quantity,c_event.unit, lv2_target_uom);
    --ecdp_dynsql.writetemptext('summarizeEvent','Value converted to unit ' || lv2_target_uom || ' : ' || ln_conv_val);
    ln_event_total := ln_event_total + ln_conv_val;
    ln_count := ln_count + 1;
  END LOOP;
  IF ln_count > 0 THEN
    ln_return_val := ln_event_total /  ln_count;
  ELSE
    ld_TestStart := ec_itst_definition.daytime(p_test_no);
    FOR c_event IN c_tdev_out_bsw (p_test_no, p_object_id, ld_TestStart, ld_TestStart + (5/1440), p_event_type) LOOP
      ln_conv_val := ecdp_unit.convertValue(c_event.quantity,c_event.unit, lv2_target_uom);
      ln_event_total := ln_event_total + ln_conv_val;
      ln_count := ln_count + 1;
    END LOOP;
    IF ln_count > 0 THEN
      ln_return_val := ln_event_total /  ln_count;
    END IF;
  END IF;
  --ecdp_dynsql.writetemptext('summarizeEvent','Returning value ' || ln_return_val);
  RETURN ln_return_val;
END summarizeEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSampleDataClassName
-- Description    : Retrieves the associated sample data class name for a given object
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSampleDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_inst_type   VARCHAR2(32);
  lv2_return_value  VARCHAR2(32);
  lv2_class_name  VARCHAR2(32) := ecdp_objects.GetObjClassName(p_object_id);

BEGIN
  IF lv2_class_name = 'TEST_DEVICE' THEN
    lv2_return_value := 'TDEV_INJ_SAMPLE';
  END IF;
  IF lv2_class_name = 'FLOWLINE' THEN
    lv2_return_value := 'IFLW_SAMPLE_1';
  END IF;
  IF lv2_class_name = 'WELL' THEN
    lv2_return_value := 'IWEL_SAMPLE_1';
  END IF;
  IF lv2_class_name = 'WELL_BORE_INTERVAL' THEN
    lv2_return_value := 'WBI_INJ_SAMPLE';
  END IF;
  RETURN lv2_return_value;
END getSampleDataClassName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getResultDataClassName
-- Description    : Retrieves the associated sample data class name
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getResultDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_inst_type     VARCHAR2(32);
  lv2_return_value  VARCHAR2(32);
  lv2_class_name    VARCHAR2(32) := ecdp_objects.GetObjClassName(p_object_id);
BEGIN
  IF lv2_class_name = 'TEST_DEVICE' THEN
    lv2_return_value := 'TDEV_INJ_RESULT_1';
  END IF;
  IF lv2_class_name = 'FLOWLINE' THEN
    lv2_return_value := 'IFLW_RESULT_1';
  END IF;
  IF lv2_class_name = 'WELL' THEN
    lv2_return_value := 'IWEL_RESULT_1';
  END IF;
  IF lv2_class_name = 'WELL_BORE_INTERVAL' THEN
    lv2_return_value := 'WBI_INJ_RESULT';
  END IF;
  RETURN lv2_return_value;
END getResultDataClassName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SummarizeStablePeriod
-- Description    : Traverses each equal data column in <object>_sample and corresponding
--                  <object>_result table, and aggregates an average value of the sample data
--                  and updates the result table column
--
-- Preconditions  : Valid record in itst_result with both daytime and end_date
-- Postconditions : Record in result table created for result number taken as in parameter and
--                  all objects related to that result number
--
-- Using tables   : ITST_RESULT
--                  ITST_OBJECT
--                  TEST_DEVICE_INJ_SAMPLE
--                  TEST_DEVICE_INJ_RESULT
--                  IFLW_SAMPLE
--                  IFLW_RESULT
--                  IWEL_SAMPLE
--                  IWEL_RESULT
--
-- Using functions: executeStatement
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE summarizeStablePeriod(p_result_no NUMBER, p_last_updated_by    VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
  ln_test_no                  NUMBER;
  ln_well_count               NUMBER := 0;
  ln_fromcolcount             NUMBER;
  ln_colcount                 NUMBER;
  ln_event_value1             NUMBER;
  ln_event_value2             NUMBER;
  ln_event_value3             NUMBER;
  ln_event_value4             NUMBER;

  lv2_sample_table            VARCHAR2(32);
  lv2_result_table            VARCHAR2(32);
  lv2_result_data_class       VARCHAR2(32);
  lv2_single_well_id          VARCHAR2(32);
  lv2_test_type               VARCHAR2(32);
  lv2_updatesql               VARCHAR2(32000);
  lv2_setsql                  VARCHAR2(32000);
  lv2_result                  VARCHAR2(32000);

  ld_startdate                DATE;
  ld_enddate                  DATE;
  ld_valid_from_date          DATE;
  lv2_status                  ITST_RESULT.STATUS%TYPE;
  n_lock_columns              EcDp_Month_lock.column_list;
  lb_is_webo_interval_obj     BOOLEAN;
  lr_test_device_inj_result   test_device_inj_result%ROWTYPE;

  CURSOR c_itst_object (cp_test_no NUMBER) IS	SELECT class_name, object_id FROM itst_object WHERE test_no = cp_test_no;

  CURSOR c_column (st_table VARCHAR2, rt_table VARCHAR2) IS SELECT column_name FROM cols WHERE table_name = st_table AND data_type = 'NUMBER' AND column_name NOT IN ('REV_NO','RESULT_NO') INTERSECT SELECT column_name FROM cols WHERE table_name = rt_table AND data_type = 'NUMBER' AND column_name NOT IN ('REV_NO','RESULT_NO');

  CURSOR c_result IS SELECT test_no, daytime, end_date, valid_from_date, status, duration, result_no FROM itst_result WHERE result_no = p_result_no;

BEGIN
  --DELETE FROM t_temptext WHERE id = 'summarizeStablePeriod';
  FOR result IN c_result LOOP
    ln_test_no := result.test_no;
    ld_startdate := result.daytime;
    ld_enddate := result.end_date;
    ld_valid_from_date := result.valid_from_date;
    lv2_status := result.status;
    IF result.daytime IS NOT NULL AND result.end_date IS NOT NULL THEN
      result.duration := (result.end_date - result.daytime)*24;
    END IF;
    UPDATE itst_result
    SET
    end_date               = result.end_date
    ,duration              = trunc(result.duration, 2)   -- trunc the duration to 2 decimals
    ,LAST_UPDATED_BY       = Nvl(p_LAST_UPDATED_BY,USER)
    ,LAST_UPDATED_DATE     = Nvl(lr_test_device_inj_result.LAST_UPDATED_DATE, Ecdp_Timestamp.getCurrentSysdate)
    WHERE result_no = result.result_no
    AND   daytime = result.daytime;
  END LOOP;
  lv2_test_type := ec_itst_definition.test_type(ln_test_no);
  IF ld_enddate IS NULL THEN
    RAISE_APPLICATION_ERROR(-20512,'Cannot perform calculation on result with no end date');
  END IF;
  --ecdp_dynsql.writetemptext('summarizeStablePeriod','Test no ' || ln_test_no || ' From Date ' || ld_startdate || ' to date ' || ld_enddate);
  DELETE FROM test_device_inj_result WHERE result_no = p_result_no;
  DELETE FROM iflw_result WHERE result_no = p_result_no;
  DELETE FROM iwel_result WHERE result_no = p_result_no;
  DELETE FROM wbi_inj_result WHERE result_no = p_result_no;

  FOR row IN c_itst_object(ln_test_no) LOOP
    --ecdp_dynsql.writetemptext('summarizeStablePeriod','Object with id: ' || row.object_id || ' is a ' || row.class_name || ' object');
    lv2_result_data_class := getResultDataClassName(row.object_id, ld_startdate);
    IF row.class_name = 'TEST_DEVICE' THEN
      lv2_sample_table := 'TEST_DEVICE_INJ_SAMPLE';
      lv2_result_table := 'TEST_DEVICE_INJ_RESULT';
      INSERT INTO test_device_inj_result (object_id, result_no, daytime, data_class_name) VALUES (row.object_id, p_result_no, ld_startdate, lv2_result_data_class);
    END IF;
    IF row.class_name = 'FLOWLINE' THEN
      lv2_sample_table := 'IFLW_SAMPLE';
      lv2_result_table := 'IFLW_RESULT';
      INSERT INTO iflw_result (object_id, result_no, data_class_name) VALUES (row.object_id, p_result_no, lv2_result_data_class);
    END IF;
    IF row.class_name = 'WELL' THEN
      lv2_sample_table := 'IWEL_SAMPLE';
      lv2_result_table := 'IWEL_RESULT';
      INSERT INTO IWEL_RESULT (object_id, result_no, data_class_name, daytime, end_date, valid_from_date, status) VALUES (row.object_id, p_result_no, lv2_result_data_class, ld_startdate, ld_enddate, ld_valid_from_date, lv2_status);

      ln_well_count := ln_well_count + 1;
      IF ln_well_count = 1 THEN
        lv2_single_well_id := row.object_id;
      END IF;
    END IF;
    IF row.class_name = 'WELL_BORE_INTERVAL' THEN
      lv2_sample_table := 'WBI_INJ_SAMPLE';
      lv2_result_table := 'WBI_INJ_RESULT';
      lb_is_webo_interval_obj := TRUE;
      INSERT INTO WBI_INJ_RESULT (object_id, result_no) VALUES (row.object_id, p_result_no);
    ELSE
      lb_is_webo_interval_obj := FALSE;
    END IF;

    lv2_setsql := 'SET ';
    ln_colcount := 0;
    FOR c IN c_column(lv2_sample_table, lv2_result_table) LOOP
      --Have to split updates in order to be able to execute them.
      IF MOD(ln_colcount,5) = 0 THEN
        lv2_setsql := lv2_setsql || ' rt.' || c.column_name || ' = (SELECT AVG(st.' || c.column_name || ') FROM ' || lv2_sample_table || ' st WHERE st.OBJECT_ID = ''' || row.object_id || ''' AND st.daytime >= to_date('''||to_char(ld_startDate,'yyyy-mm-dd HH24:MI:SS')||''',''yyyy-mm-dd HH24:MI:SS'') AND st.daytime < to_date('''||to_char(ld_endDate,'yyyy-mm-dd HH24:MI:SS')||''',''yyyy-mm-dd HH24:MI:SS'')) ';
      ELSE
        lv2_setsql := lv2_setsql || ', rt.' || c.column_name || ' = (SELECT AVG(st.' || c.column_name || ') FROM ' || lv2_sample_table || ' st WHERE st.OBJECT_ID = ''' || row.object_id || ''' AND st.daytime >= to_date('''||to_char(ld_startDate,'yyyy-mm-dd HH24:MI:SS')||''',''yyyy-mm-dd HH24:MI:SS'') AND st.daytime < to_date('''||to_char(ld_endDate,'yyyy-mm-dd HH24:MI:SS')||''',''yyyy-mm-dd HH24:MI:SS'')) ';
      END IF;
      IF MOD(ln_colcount,5) = 4 THEN
        ln_fromcolcount := ln_colcount - 4;
        IF lb_is_webo_interval_obj THEN
          lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt ' || lv2_setsql || ' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.result_no = ' || p_result_no;
        ELSE
          lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt ' || lv2_setsql || ' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.data_class_name = ''' || lv2_result_data_class || ''' AND rt.result_no = ' || p_result_no;
        END IF;
        --ecdp_dynsql.writetemptext('summarizeStablePeriod','Update on ' || lv2_result_table || ' from column ' || ln_fromcolcount || ' to columns ' || ln_colcount);
        --ecdp_dynsql.writetemptext('summarizeStablePeriod',lv2_updatesql);
        lv2_result := executeStatement(lv2_updatesql);
        IF INSTR(lv2_result,'Failed to execute') > 0 THEN
          RAISE_APPLICATION_ERROR(-20108,lv2_result);
        END IF;
        lv2_setsql := 'SET ';
      END IF;
      ln_colcount := ln_colcount + 1;
    END LOOP;

    --ecdp_dynsql.writetemptext('summarizeStablePeriod','Numner of columns: ' || ln_colcount);
    IF MOD(ln_colcount,5) > 0 THEN
      ln_fromcolcount := ln_colcount - MOD(ln_colcount,5);
      IF lb_is_webo_interval_obj THEN
        lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt ' || lv2_setsql || ' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.result_no = ' || p_result_no;
      ELSE
        lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt ' || lv2_setsql || ' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.data_class_name = ''' || lv2_result_data_class || ''' AND rt.result_no = ' || p_result_no;
      END IF;

      --ecdp_dynsql.writetemptext('summarizeStablePeriod','Update on ' || lv2_result_table || ' from column ' || ln_fromcolcount || ' to columns ' || ln_colcount);
      --ecdp_dynsql.writetemptext('summarizeStablePeriod',lv2_updatesql);
      lv2_result := executeStatement(lv2_updatesql);
      IF INSTR(lv2_result,'Failed to execute') > 0 THEN
        RAISE_APPLICATION_ERROR(-20108,lv2_result);
      END IF;
    END IF;

    --Adding event samples
    IF row.class_name = 'TEST_DEVICE' THEN
      UPDATE test_device_inj_result SET
      last_updated_by = Nvl(p_LAST_UPDATED_BY,USER), last_updated_date = Ecdp_Timestamp.getCurrentSysdate
      WHERE object_id = row.object_id  AND data_class_name =  lv2_result_data_class AND result_no = p_result_no;
    END IF;
    IF lb_is_webo_interval_obj THEN
        lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt set rt.last_updated_by = ''' || Nvl(p_LAST_UPDATED_BY,USER) || ''', rt.last_updated_date = ''' || 'to_date(to_char(Ecdp_Timestamp.getCurrentSysdate, ' || 'YYYY-MM-DD HH24:MI:SS' || '), ' ||  'YYYY-MM-DD HH24:MI:SS' || ')' || ''' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.result_no = ' || p_result_no;
    ELSE
      lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt set rt.last_updated_by = ''' || Nvl(p_LAST_UPDATED_BY,USER) || ''', rt.last_updated_date = ''' || 'to_date(to_char(Ecdp_Timestamp.getCurrentSysdate, ' || 'YYYY-MM-DD HH24:MI:SS' || '), ' ||  'YYYY-MM-DD HH24:MI:SS' || ')' || ''' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.data_class_name = ''' || lv2_result_data_class || ''' AND rt.result_no = ' || p_result_no;
    END IF;

    lv2_result := executeStatement(lv2_updatesql);
  END LOOP;

  --ecdp_dynsql.writetemptext('summarizeStablePeriod','Number of wells in result is ' || ln_well_count);
  IF ln_well_count = 1 THEN
    UPDATE iwel_result SET primary_ind = 'Y', flowing_ind = 'Y' where object_id = lv2_single_well_id AND result_no = p_result_no;
  END IF;

  UPDATE itst_result SET summarised_ind = 'Y', test_type = lv2_test_type, class_name = 'INJ_TEST_RESULT', last_updated_by = Nvl(p_LAST_UPDATED_BY,USER), production_day = EcDp_ProductionDay.getProductionDay('WELL',lv2_single_well_id, ld_startdate) WHERE result_no = p_result_no AND daytime = ld_startdate;

END summarizeStablePeriod;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTestObjectName
-- Description    : Returns test object name. For WELL BORE INTERVAL object, it will return as
--                  <well name> - <well bore name> - <well bore interval name>
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: - ecdp_objects.getobjclassname, ecdp_objects.GetObjName, ecdp_objects.GetObjStartDate
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTestObjectName(p_object_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_object_classname      VARCHAR2(32);
  lv2_webo_id               VARCHAR2(32);
  lv2_well_id               VARCHAR2(32);
  lv2_ret_test_object_name  VARCHAR2(200);
BEGIN
  lv2_object_classname := ecdp_objects.getobjclassname(p_object_id);
  IF lv2_object_classname = 'WELL_BORE_INTERVAL' THEN
    lv2_webo_id := ec_webo_interval.well_bore_id(p_object_id);
    lv2_well_id := ec_webo_bore.well_id(lv2_webo_id);
    lv2_ret_test_object_name := ecdp_objects.GetObjName(lv2_well_id, ecdp_objects.GetObjStartDate(lv2_well_id)) || ' - ' ||
                                ecdp_objects.GetObjName(lv2_webo_id, ecdp_objects.GetObjStartDate(lv2_webo_id)) || ' - ' ||
                                ecdp_objects.GetObjName(p_object_id, ecdp_objects.GetObjStartDate(p_object_id));
  ELSE
    lv2_ret_test_object_name := ecdp_objects.GetObjName(p_object_id, ecdp_objects.GetObjStartDate(p_object_id));
  END IF;
  RETURN lv2_ret_test_object_name;
END getTestObjectName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aiSyncIwelResultFromIwel
-- Description    : if there is any inserted Well Test in Injection Test Result, need to sync to IWEL_RESULT.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : IWEL_RESULT, ITST_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aiSyncIwelResultFromIwel ( p_result_no  NUMBER, p_well_id VARCHAR2, p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
  CURSOR c_itst_result(cp_result_no NUMBER) IS
  SELECT result_no, daytime, valid_from_date, status, end_date
  FROM itst_result
  WHERE result_no = cp_result_no;

  CURSOR c_test_device_inj_result(cp_result_no NUMBER) IS
  SELECT object_id
  FROM test_device_inj_result
  WHERE result_no = cp_result_no;

  ln_result           NUMBER;
  lv2_test_device_id  VARCHAR2(1000);
BEGIN
  SELECT COUNT(*) into ln_result
  FROM IWEL_RESULT ir
  WHERE ir.RESULT_NO = p_result_no and ir.OBJECT_ID = p_well_id;
  FOR curr_rec in c_test_device_inj_result(p_result_no) LOOP
    lv2_test_device_id := curr_rec.object_id;
  END LOOP;
  IF ln_result = 0 THEN
    FOR curr_rec in c_itst_result(p_result_no) LOOP
      INSERT INTO IWEL_RESULT
        (RESULT_NO, OBJECT_ID, DAYTIME, VALID_FROM_DATE, STATUS, TEST_DEVICE, END_DATE, CREATED_BY)
      VALUES
        (curr_rec.result_no, p_well_id, curr_rec.daytime, curr_rec.valid_from_date, curr_rec.status, lv2_test_device_id, curr_rec.end_date, Nvl(p_user,USER));
    END LOOP;
  ELSE
    FOR curr_rec in c_itst_result(p_result_no) LOOP
      UPDATE IWEL_RESULT
      SET DAYTIME=curr_rec.daytime,
          VALID_FROM_DATE=curr_rec.valid_from_date,
          STATUS=curr_rec.status,
          END_DATE=curr_rec.end_date,
          TEST_DEVICE=lv2_test_device_id,
          LAST_UPDATED_BY = Nvl(p_user,USER),
          LAST_UPDATED_DATE = Ecdp_Timestamp.getCurrentSysdate
      WHERE RESULT_NO = p_result_no and OBJECT_ID = p_well_id;
    END LOOP;
  END IF;
END aiSyncIwelResultFromIwel;

END EcDp_Inj_Performance_Test;