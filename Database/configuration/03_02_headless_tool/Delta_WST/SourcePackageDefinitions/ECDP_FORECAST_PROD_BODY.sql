CREATE OR REPLACE PACKAGE BODY EcDp_Forecast_Prod IS
/**************************************************************************************************
** Package  :  EcDp_Forecast_Prod
**
** $Revision: 1.16 $
**
** Purpose  :  Data package for Forecasting
**
** General Logic:ec_class.lock_ind
**
** Created        :  13-07-2015 Suresh Kumar
**
** Modification history:
**
** Date        Whom  Change description:
** 29-07-15		kumarsur	ECPD-31234: Forecast
** 02-09-15		kumarsur	ECPD-31234: Added copyFcstFctyDay, copyFcstFctyMth and copyFcstObjectFluid.
** 07-09-15		kumarsur	ECPD-31234: Only copy records until one day before end date of the forecast.
** 30-09-15		kumarsur	ECPD-31234: Modified setOfficialForecast.
** 28-03-16   kashisag  ECPD-33739: Added procedure to update end date for child objects of Forecast group
** 11-04-16   abdulmaw  ECPD-34357: Added procedure copyScenarioToNewScenario to copy new scenario from an existing scenario
** 15-04-16   kumarsur  ECPD-33820: Added procedure copyActualsToScenario.
** 21-04-16   leongwen  ECPD-34357: Added procedure copyScenarioToScenario.
** 06-05-16   kumarsur  ECPD-33834: Added navForecastGroupFilter.
** 16-05-16   jainnraj  ECPD-35071: Added deleteForecast to delete forecast and all its dependent data.
** 20-05-16   jainnraj  ECPD-35072: Added deleteScenario to delete scenario and all its dependent data.
** 03-06-16   jainnraj  ECPD-34651: Added getForecastParentObjectId and setOfficialScenario and removed setOfficialForecast
** 13-06-16   kashisag  ECPD-34299: Added commands to delete records from FCST_OBJ_CONSTRAINTS
** 13-06-16   abdulmaw  ECPD-33887: Updated deleteScenario to include FCST_WELL_EVENT
** 06-07-16   jainnraj  ECPD-36978: Modified createForecast,deleteForecast,deleteScenario,setOfficialScenario to use column official_ind instead of official and modified setDefaultOfficial to add support for demote button on forecast screen
** 12-07-16   kumarsur  ECPD-36900: Modified scenario_id to object_id in deleteScenario
** 15-07-16   kashisag  ECPD-36200: Added placeholder procedure runPlsqlCalculation for Forecast PLSQL calculation
** 20-07-16   jainnraj  ECPD-35571: Modified deleteScenario and deleteForecast to add support for FCST_COMPENSATION_EVENTS
** 19-09-16   kashisag  ECPD-39344: Remove usage of EcDp_Utilities.executestatement.
** 12-10-16   kashisag  ECPD-34301: Added placeholder procedure for calculating analysis i.e. calculateanalysis
** 14-10-16   kashisag  ECPD-34301: Added procedure deleteComparison to delete Forecast defined Scenario Comparison records
** 26-10-16   kashisag  ECPD-34301: Added procedure to update end_date for comparison code
** 26-10-16   kashisag  ECPD-34301: Added procedure to update daytime for comparison code
** 22-11-17   jainnraj  ECPD-50630: Modified procedure deleteForecast and deleteScenario to delete data from table FCST_FCTY_DAY upon deleting a forecast or scenario.
** 01-12-17   jainnraj  ECPD-50649: Modified procedure deleteForecast and deleteScenario to delete data from table FCST_FCTY_MTH upon deleting a forecast or scenario.
** 08-12-17   kashisag  ECPD-40487: Corrected local variables naming convention.
** 19-02-18   jainnraj  ECPD-52691: Modified procedure deleteForecast and deleteScenario to delete data from table FCST_AREA_DAY upon deleting a forecast or scenario.
** 20-02-18   jainnraj  ECPD-52692: Modified procedure deleteForecast and deleteScenario to delete data from table FCST_AREA_MTH upon deleting a forecast or scenario.
** 08-03-18   jainnraj  ECPD-52689,ECPD-52690,ECPD-52694,ECPD-52693: Modified procedure deleteForecast and deleteScenario to delete data from table FCST_SUB_PRODUNIT_DAY,FCST_SUB_PRODUNIT_MTH,FCST_SUB_AREA_DAY,FCST_SUB_AREA_MTH upon deleting a forecast or scenario.
** 23-03-18   jainnraj  ECPD-52687,ECPD-52688: Modified procedure deleteForecast and deleteScenario to delete data from table FCST_PRODUNIT_DAY,FCST_PRODUNIT_MTH upon deleting a forecast or scenario.
**************************************************************************************************/

pv_error_diff_period_type VARCHAR2(80) NOT NULL DEFAULT 'FROM and TO Forecast must be of same TYPE! (e.g. Short, Medium or Long)';
pv_error_same_period VARCHAR2(80) NOT NULL DEFAULT 'Cannot copy FROM and TO the same Forecast!';

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

--creating new object_id for the new forecast
PROCEDURE createForecast(p_from_forecast_id VARCHAR2, p_period_type VARCHAR2, p_forecast_type VARCHAR2, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2,
                         p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE)
IS
    li_validation INTEGER;
	lv2_forecast_id VARCHAR2(32) := NULL;

BEGIN

    IF (p_from_forecast_id IS NULL) THEN
		Raise_Application_Error(-20000,'Missing copy from forecast id');
	END IF;

	--generating forecast_id
	lv2_forecast_id:= EcDp_objects.GetInsertedObjectID(lv2_forecast_id);

	INSERT INTO FORECAST(object_id,CLASS_NAME,PERIOD_TYPE,FORECAST_TYPE,OBJECT_CODE,START_DATE,END_DATE,created_by)
    VALUES(lv2_forecast_id,'FORECAST_PROD',p_period_type,p_forecast_type,p_new_forecast_code,p_start_date,p_end_date,ecdp_context.getAppUser);

    INSERT INTO FORECAST_VERSION(object_id,daytime,end_date, NAME, created_by, OFFICIAL_IND)
    VALUES(lv2_forecast_id, p_start_date, p_end_date, p_new_forecast_code, ecdp_context.getAppUser,'N');

	-- check that forecast_id exist and that forecast_type is the same for from and to
	 li_validation := validatePeriodTypes(p_from_forecast_id, lv2_forecast_id);
	IF (li_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (li_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period );
	END IF;

	copyFcstStreamDay(p_from_forecast_id, lv2_forecast_id, p_start_date, p_end_date-1, p_comment, p_user); --Daily Stream Forecast
	copyFcstStreamMth(p_from_forecast_id, lv2_forecast_id, p_start_date, p_end_date-1, p_comment, p_user); --Monthly Stream Forecast
	copyFcstPwelDay(p_from_forecast_id, lv2_forecast_id, p_start_date, p_end_date-1, p_comment, p_user);   --Daily Production Well Forecast
	copyFcstPwelMth(p_from_forecast_id, lv2_forecast_id, p_start_date, p_end_date-1, p_comment, p_user);   --Monthly Production Well Forecast
	copyFcstIwelDay(p_from_forecast_id, lv2_forecast_id, p_start_date, p_end_date-1, p_comment, p_user);   --Daily Injection Well Forecast
	copyFcstIwelMth(p_from_forecast_id, lv2_forecast_id, p_start_date, p_end_date-1, p_comment, p_user);   --Monthly Injection Well Forecast
	copyFcstStorageMth(p_from_forecast_id, lv2_forecast_id, p_start_date, p_end_date-1, p_comment, p_user);--Monthly Storage Forecast
	copyFcstStorageDay(p_from_forecast_id, lv2_forecast_id, p_start_date, p_end_date-1, p_comment, p_user);--Daily Storage Forecast
	copyFcstFctyDay(p_from_forecast_id, lv2_forecast_id, p_start_date, p_end_date-1, p_comment, p_user);--Daily Facility Class 1 Forecast
	copyFcstFctyMth(p_from_forecast_id, lv2_forecast_id, p_start_date, p_end_date-1, p_comment, p_user);--Monthly Facility Class 1 Forecast
	copyFcstObjectFluid(p_from_forecast_id, lv2_forecast_id, p_start_date, p_end_date-1, p_comment, p_user);--Component Forecast

END createForecast;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function			: validatePeriodTypes
-- Description    : returns FALSE if period types differ, or if one forecast_id does not exist
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : forecast
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION validatePeriodTypes(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2)
--</EC-DOC>
RETURN INTEGER
IS

CURSOR c_get_period_type (cp_from_forecast_id VARCHAR2, cp_new_forecast_id VARCHAR2)
IS
	SELECT object_id, period_type
	FROM forecast
	WHERE object_id = cp_from_forecast_id
	OR object_id = cp_new_forecast_id;


lv2_from_period_type VARCHAR2(32);
lv2_to_period_type VARCHAR2(32);

BEGIN

	FOR curPeriods IN c_get_period_type(p_from_forecast_id, p_new_forecast_id) LOOP
		EcDp_DynSql.WriteDebugText('validatePeriodTypes', 'forecast_id: ' || curPeriods.object_id, 'DEBUG' );
		IF (curPeriods.object_id = p_from_forecast_id)
			THEN lv2_from_period_type := curPeriods.period_type;
		END IF;
		IF (curPeriods.object_id = p_new_forecast_id)
			THEN lv2_to_period_type := curPeriods.period_type;
		END IF;
	END LOOP;

  EcDp_DynSql.WriteDebugText('validatePeriodTypes', 'lv2_from_period_type: ' || lv2_from_period_type, 'DEBUG' );
  EcDp_DynSql.WriteDebugText('validatePeriodTypes', 'lv2_to_period_type: ' || lv2_to_period_type, 'DEBUG' );

	IF (lv2_from_period_type IS NULL OR lv2_to_period_type IS NULL)
		THEN RETURN -1;
	ELSIF (lv2_to_period_type != lv2_from_period_type)
		THEN RETURN -1;
	ELSIF (p_from_forecast_id = p_new_forecast_id)
		THEN RETURN -2;
	ELSE RETURN 0;
	END IF;

END validatePeriodTypes;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getForecastParentObjectid
-- Description    : Get parent object id of a forecast
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION  getForecastParentObjectId(p_forecast_id VARCHAR2,p_group_type VARCHAR2,p_class_name VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
lv2_object_id VARCHAR2(32);
BEGIN
  SELECT parent_object_id INTO lv2_object_id
  FROM tv_groups
  WHERE class_name=p_class_name
  AND   group_type=p_group_type
  AND object_id=p_forecast_id;

  RETURN lv2_object_id;

END getForecastParentObjectId;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : demoteToUnofficial
-- Description    : To demote an scenario to unofficial
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE demoteToUnofficial(
   p_scenario_id VARCHAR2)
--</EC-DOC>
IS
   lv2_code_exist   VARCHAR2(32);
BEGIN

    Ue_Forecast_Prod.demoteToUnofficial(p_scenario_id,lv2_code_exist);
       IF lv2_code_exist <> 'Y' THEN
          UPDATE FORECAST_VERSION
          SET OFFICIAL_IND = 'N'
          WHERE OBJECT_ID = p_scenario_id;
       END IF;

END demoteToUnofficial;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure	  : setOfficialScenario
-- Description    : To set a scenario official
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FORECAST, FORECAST_VERSION, FORECAST_GROUP
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setOfficialScenario(p_group_type VARCHAR2,p_forecast_id VARCHAR2,p_scenario_id VARCHAR2,p_start_date DATE,p_end_date DATE)
--</EC-DOC>
IS

lv2_code_exist   VARCHAR2(32);

CURSOR c_forecast IS
   SELECT F.OBJECT_ID
   FROM FORECAST F, FORECAST_VERSION FV,FORECAST_GROUP FG
   WHERE F.OBJECT_ID = FV.OBJECT_ID
   AND FV.FORECAST_GROUP_ID = FG.OBJECT_ID
   AND FV.OFFICIAL_IND = 'Y'
   AND F.START_DATE <= p_end_date
   AND F.END_DATE >= p_start_date
   AND FG.FORECAST_TYPE = (SELECT forecast_type
                           FROM   forecast_group
                           WHERE  OBJECT_ID =p_forecast_id
                          )
   AND getForecastParentObjectId
       (FG.object_id ,
        p_group_type ,
       'FORECAST_GROUP')=  getForecastParentObjectId
                           (p_forecast_id ,
                            p_group_type ,
                            'FORECAST_GROUP') ;
BEGIN

  Ue_Forecast_Prod.setOfficialScenario(p_group_type,p_forecast_id,p_scenario_id,p_start_date,p_end_date,lv2_code_exist);

  IF lv2_code_exist <> 'Y' THEN

      FOR forecastCur IN c_forecast LOOP

        UPDATE FORECAST_VERSION
        SET OFFICIAL_IND = 'N'
        WHERE OBJECT_ID = forecastCur.object_id;
      END LOOP;

      UPDATE FORECAST_VERSION
      SET OFFICIAL_IND = 'Y'
      WHERE OBJECT_ID = p_scenario_id;
  END IF;

END setOfficialScenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFcstStreamDay
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_STREAM_DAY
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFcstStreamDay(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_stream_day IS TABLE OF fcst_stream_day%ROWTYPE;
l_fcst_stream_day t_fcst_stream_day;

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_stream_day
	WHERE forecast_id = cp_from_forecast_id AND daytime BETWEEN p_start_date AND p_end_date;

	lv_validation INTEGER;

BEGIN

	lv_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (lv_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (lv_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_stream_day WHERE forecast_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_stream_day LIMIT 2000;

    FOR i IN 1..l_fcst_stream_day.COUNT LOOP
	  l_fcst_stream_day(i).object_id := l_fcst_stream_day(i).object_id;
      l_fcst_stream_day(i).forecast_id := p_new_forecast_id;
      l_fcst_stream_day(i).daytime := l_fcst_stream_day(i).daytime;
      l_fcst_stream_day(i).created_by := p_user;
      l_fcst_stream_day(i).created_date := ld_now;
      l_fcst_stream_day(i).last_updated_by := NULL;
      l_fcst_stream_day(i).last_updated_date := NULL;
      l_fcst_stream_day(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_stream_day.COUNT
      INSERT INTO fcst_stream_day VALUES l_fcst_stream_day(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

END copyFcstStreamDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFcstStreamMth
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_STREAM_MTH
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFcstStreamMth(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_stream_mth IS TABLE OF fcst_stream_mth%ROWTYPE;
l_fcst_stream_mth t_fcst_stream_mth;

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_stream_mth
	WHERE forecast_id = cp_from_forecast_id AND daytime BETWEEN p_start_date AND p_end_date;

	lv_validation INTEGER;

BEGIN

	lv_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (lv_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (lv_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_stream_mth WHERE forecast_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_stream_mth LIMIT 2000;

    FOR i IN 1..l_fcst_stream_mth.COUNT LOOP
	  l_fcst_stream_mth(i).object_id := l_fcst_stream_mth(i).object_id;
      l_fcst_stream_mth(i).forecast_id := p_new_forecast_id;
      l_fcst_stream_mth(i).daytime := l_fcst_stream_mth(i).daytime;
      l_fcst_stream_mth(i).created_by := p_user;
      l_fcst_stream_mth(i).created_date := ld_now;
      l_fcst_stream_mth(i).last_updated_by := NULL;
      l_fcst_stream_mth(i).last_updated_date := NULL;
      l_fcst_stream_mth(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_stream_mth.COUNT
      INSERT INTO fcst_stream_mth VALUES l_fcst_stream_mth(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

END copyFcstStreamMth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFcstPwelDay
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_PWEL_DAY
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFcstPwelDay(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_pwel_day IS TABLE OF fcst_pwel_day%ROWTYPE;
l_fcst_pwel_day t_fcst_pwel_day;

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_pwel_day
	WHERE forecast_id = cp_from_forecast_id AND daytime BETWEEN p_start_date AND p_end_date;

	li_validation INTEGER;

BEGIN

	li_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (li_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (li_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_pwel_day WHERE forecast_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_pwel_day LIMIT 2000;

    FOR i IN 1..l_fcst_pwel_day.COUNT LOOP
	  l_fcst_pwel_day(i).object_id := l_fcst_pwel_day(i).object_id;
      l_fcst_pwel_day(i).forecast_id := p_new_forecast_id;
      l_fcst_pwel_day(i).daytime := l_fcst_pwel_day(i).daytime;
      l_fcst_pwel_day(i).created_by := p_user;
      l_fcst_pwel_day(i).created_date := ld_now;
      l_fcst_pwel_day(i).last_updated_by := NULL;
      l_fcst_pwel_day(i).last_updated_date := NULL;
      l_fcst_pwel_day(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_pwel_day.COUNT
      INSERT INTO fcst_pwel_day VALUES l_fcst_pwel_day(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

END copyFcstPwelDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFcstPwelMth
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_PWEL_MTH
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFcstPwelMth(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_pwel_mth IS TABLE OF fcst_pwel_mth%ROWTYPE;
l_fcst_pwel_mth t_fcst_pwel_mth;

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_pwel_mth
	WHERE forecast_id = cp_from_forecast_id AND daytime BETWEEN p_start_date AND p_end_date;

	li_validation INTEGER;

BEGIN

	li_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (li_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (li_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_pwel_mth WHERE forecast_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_pwel_mth LIMIT 2000;

    FOR i IN 1..l_fcst_pwel_mth.COUNT LOOP
	  l_fcst_pwel_mth(i).object_id := l_fcst_pwel_mth(i).object_id;
      l_fcst_pwel_mth(i).forecast_id := p_new_forecast_id;
      l_fcst_pwel_mth(i).daytime := l_fcst_pwel_mth(i).daytime;
      l_fcst_pwel_mth(i).created_by := p_user;
      l_fcst_pwel_mth(i).created_date := ld_now;
      l_fcst_pwel_mth(i).last_updated_by := NULL;
      l_fcst_pwel_mth(i).last_updated_date := NULL;
      l_fcst_pwel_mth(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_pwel_mth.COUNT
      INSERT INTO fcst_pwel_mth VALUES l_fcst_pwel_mth(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

END copyFcstPwelMth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFcstIwelDay
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_IWEL_DAY
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFcstIwelDay(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_iwel_day IS TABLE OF fcst_iwel_day%ROWTYPE;
l_fcst_iwel_day t_fcst_iwel_day;

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_iwel_day
	WHERE forecast_id = cp_from_forecast_id AND daytime BETWEEN p_start_date AND p_end_date;

	li_validation INTEGER;

BEGIN

	li_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (li_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (li_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_iwel_day WHERE forecast_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_iwel_day LIMIT 2000;

    FOR i IN 1..l_fcst_iwel_day.COUNT LOOP
	  l_fcst_iwel_day(i).object_id := l_fcst_iwel_day(i).object_id;
      l_fcst_iwel_day(i).forecast_id := p_new_forecast_id;
      l_fcst_iwel_day(i).daytime := l_fcst_iwel_day(i).daytime;
      l_fcst_iwel_day(i).created_by := p_user;
      l_fcst_iwel_day(i).created_date := ld_now;
      l_fcst_iwel_day(i).last_updated_by := NULL;
      l_fcst_iwel_day(i).last_updated_date := NULL;
      l_fcst_iwel_day(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_iwel_day.COUNT
      INSERT INTO fcst_iwel_day VALUES l_fcst_iwel_day(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

END copyFcstIwelDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFcstIwelMth
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_IWEL_MTH
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFcstIwelMth(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_iwel_mth IS TABLE OF fcst_iwel_mth%ROWTYPE;
l_fcst_iwel_mth t_fcst_iwel_mth;

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_iwel_mth
	WHERE forecast_id = cp_from_forecast_id AND daytime BETWEEN p_start_date AND p_end_date;

	li_validation INTEGER;

BEGIN

	li_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (li_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (li_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_iwel_mth WHERE forecast_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_iwel_mth LIMIT 2000;

    FOR i IN 1..l_fcst_iwel_mth.COUNT LOOP
	  l_fcst_iwel_mth(i).object_id := l_fcst_iwel_mth(i).object_id;
      l_fcst_iwel_mth(i).forecast_id := p_new_forecast_id;
      l_fcst_iwel_mth(i).daytime := l_fcst_iwel_mth(i).daytime;
      l_fcst_iwel_mth(i).created_by := p_user;
      l_fcst_iwel_mth(i).created_date := ld_now;
      l_fcst_iwel_mth(i).last_updated_by := NULL;
      l_fcst_iwel_mth(i).last_updated_date := NULL;
      l_fcst_iwel_mth(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_iwel_mth.COUNT
      INSERT INTO fcst_iwel_mth VALUES l_fcst_iwel_mth(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

END copyFcstIwelMth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFcstStorageDay
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_STORAGE_DAY
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFcstStorageDay(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_storage_day IS TABLE OF fcst_storage_day%ROWTYPE;
l_fcst_storage_day t_fcst_storage_day;

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_storage_day
	WHERE forecast_id = cp_from_forecast_id AND daytime BETWEEN p_start_date AND p_end_date;

	li_validation INTEGER;

BEGIN

	li_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (li_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (li_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_storage_day WHERE forecast_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_storage_day LIMIT 2000;

    FOR i IN 1..l_fcst_storage_day.COUNT LOOP
	  l_fcst_storage_day(i).object_id := l_fcst_storage_day(i).object_id;
      l_fcst_storage_day(i).forecast_id := p_new_forecast_id;
      l_fcst_storage_day(i).daytime := l_fcst_storage_day(i).daytime;
      l_fcst_storage_day(i).created_by := p_user;
      l_fcst_storage_day(i).created_date := ld_now;
      l_fcst_storage_day(i).last_updated_by := NULL;
      l_fcst_storage_day(i).last_updated_date := NULL;
      l_fcst_storage_day(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_storage_day.COUNT
      INSERT INTO fcst_storage_day VALUES l_fcst_storage_day(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

END copyFcstStorageDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFcstStorageMth
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_STORAGE_MTH
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFcstStorageMth(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_storage_mth IS TABLE OF fcst_storage_mth%ROWTYPE;
l_fcst_storage_mth t_fcst_storage_mth;

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_storage_mth
	WHERE forecast_id = cp_from_forecast_id AND daytime BETWEEN p_start_date AND p_end_date;

	li_validation INTEGER;

BEGIN

	li_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (li_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (li_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_storage_mth WHERE forecast_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_storage_mth LIMIT 2000;

    FOR i IN 1..l_fcst_storage_mth.COUNT LOOP
	  l_fcst_storage_mth(i).object_id := l_fcst_storage_mth(i).object_id;
      l_fcst_storage_mth(i).forecast_id := p_new_forecast_id;
      l_fcst_storage_mth(i).daytime := l_fcst_storage_mth(i).daytime;
      l_fcst_storage_mth(i).created_by := p_user;
      l_fcst_storage_mth(i).created_date := ld_now;
      l_fcst_storage_mth(i).last_updated_by := NULL;
      l_fcst_storage_mth(i).last_updated_date := NULL;
      l_fcst_storage_mth(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_storage_mth.COUNT
      INSERT INTO fcst_storage_mth VALUES l_fcst_storage_mth(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

END copyFcstStorageMth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFcstFctyDay
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_FCTY_DAY
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFcstFctyDay(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_fcty_day IS TABLE OF fcst_fcty_day%ROWTYPE;
l_fcst_fcty_day t_fcst_fcty_day;

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_fcty_day
	WHERE forecast_id = cp_from_forecast_id AND daytime BETWEEN p_start_date AND p_end_date;

	li_validation INTEGER;

BEGIN

	li_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (li_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (li_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_fcty_day WHERE forecast_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_fcty_day LIMIT 2000;

    FOR i IN 1..l_fcst_fcty_day.COUNT LOOP
	  l_fcst_fcty_day(i).object_id := l_fcst_fcty_day(i).object_id;
      l_fcst_fcty_day(i).forecast_id := p_new_forecast_id;
      l_fcst_fcty_day(i).daytime := l_fcst_fcty_day(i).daytime;
      l_fcst_fcty_day(i).created_by := p_user;
      l_fcst_fcty_day(i).created_date := ld_now;
      l_fcst_fcty_day(i).last_updated_by := NULL;
      l_fcst_fcty_day(i).last_updated_date := NULL;
      l_fcst_fcty_day(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_fcty_day.COUNT
      INSERT INTO fcst_fcty_day VALUES l_fcst_fcty_day(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

END copyFcstFctyDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFcstFctyMth
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_FCTY_MTH
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFcstFctyMth(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_fcty_mth IS TABLE OF fcst_fcty_mth%ROWTYPE;
l_fcst_fcty_mth t_fcst_fcty_mth;

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_fcty_mth
	WHERE forecast_id = cp_from_forecast_id AND daytime BETWEEN p_start_date AND p_end_date;

	li_validation INTEGER;

BEGIN

	li_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (li_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (li_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_fcty_mth WHERE forecast_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_fcty_mth LIMIT 2000;

    FOR i IN 1..l_fcst_fcty_mth.COUNT LOOP
	  l_fcst_fcty_mth(i).object_id := l_fcst_fcty_mth(i).object_id;
      l_fcst_fcty_mth(i).forecast_id := p_new_forecast_id;
      l_fcst_fcty_mth(i).daytime := l_fcst_fcty_mth(i).daytime;
      l_fcst_fcty_mth(i).created_by := p_user;
      l_fcst_fcty_mth(i).created_date := ld_now;
      l_fcst_fcty_mth(i).last_updated_by := NULL;
      l_fcst_fcty_mth(i).last_updated_date := NULL;
      l_fcst_fcty_mth(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_fcty_mth.COUNT
      INSERT INTO fcst_fcty_mth VALUES l_fcst_fcty_mth(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

END copyFcstFctyMth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyFcstObjectFluid
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_OBJECT_FLUID
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFcstObjectFluid(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_object_fluid IS TABLE OF fcst_object_fluid%ROWTYPE;
l_fcst_object_fluid t_fcst_object_fluid;

ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_object_fluid
	WHERE forecast_id = cp_from_forecast_id AND daytime BETWEEN p_start_date AND p_end_date;

	li_validation INTEGER;

BEGIN

	li_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (li_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (li_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_object_fluid WHERE forecast_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_object_fluid LIMIT 2000;

    FOR i IN 1..l_fcst_object_fluid.COUNT LOOP
	  l_fcst_object_fluid(i).object_id := l_fcst_object_fluid(i).object_id;
      l_fcst_object_fluid(i).forecast_id := p_new_forecast_id;
      l_fcst_object_fluid(i).daytime := l_fcst_object_fluid(i).daytime;
      l_fcst_object_fluid(i).created_by := p_user;
      l_fcst_object_fluid(i).created_date := ld_now;
      l_fcst_object_fluid(i).last_updated_by := NULL;
      l_fcst_object_fluid(i).last_updated_date := NULL;
      l_fcst_object_fluid(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_object_fluid.COUNT
      INSERT INTO fcst_object_fluid VALUES l_fcst_object_fluid(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

END copyFcstObjectFluid;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateEndDateOnChildObjects
-- Description    : UPDATE end date for child forecast objects once forecast group has end date.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FORECAST,FORECAST_VERSION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE  updateEndDateOnChildObjects(p_object_end_date DATE, p_object_id VARCHAR2) IS

BEGIN


     -- Update main table on FORECAST
     UPDATE forecast f
	 SET f.end_date = p_object_end_date
     WHERE EXISTS ( SELECT 1 FROM FORECAST_VERSION fv WHERE f.OBJECT_ID = fv.OBJECT_ID AND fv.forecast_group_id = p_object_id );


     -- Update  table FORECAST_VERSION
     UPDATE forecast_version
	 SET  end_date = p_object_end_date
     WHERE forecast_group_id = p_object_id;


END updateEndDateOnChildObjects;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyScenarioToNewScenario
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FORECAST,FORECAST_VERSION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE copyScenarioToNewScenario (
  p_class_name      VARCHAR2,
  p_src_scenario_id       VARCHAR2,
  p_daytime         DATE,
  p_opt_start_date  DATE,
  p_opt_end_date    DATE,
  p_new_code        VARCHAR2,
  p_new_name        VARCHAR2
)
IS

  CURSOR c_col_name IS
     SELECT property_name
     FROM v_dao_meta
     WHERE class_name = p_class_name
     AND is_popup = 'N'
     AND NOT (is_relation_code = 'Y' AND group_type IS NULL) -- ignore relation code
     AND Nvl(is_report_only,'N') = 'N'
     AND db_mapping_type in ('COLUMN', 'ATTRIBUTE')
     AND property_name not in ('OBJECT_ID','CODE','NAME');

  lv2_sql                 VARCHAR2(32000);
  lv2_col                 VARCHAR2(32000);
  lv2_value               VARCHAR2(32000);
  lv2_result              VARCHAR2(4000);
  lv2_oriCode             VARCHAR2(1000);

BEGIN

  IF (p_src_scenario_id IS NULL) THEN
     RAISE_APPLICATION_ERROR (-20999, 'No row is being selected.');
  END IF;

  IF EcDp_ClassMeta_Cnfg.getLockInd(p_class_name) = 'Y' THEN
     EcDp_Month_lock.validatePeriodForLockOverlap('INSERTING',p_opt_start_date,NULL,'OBJECT_CODE:'||p_new_code, p_src_scenario_id);
  END IF;

  lv2_oriCode := ecdp_objects.GetObjCode(p_src_scenario_id);

  lv2_sql := 'INSERT INTO OV_'|| p_class_name ||'(OBJECT_ID,CODE,NAME,REV_TEXT';
  lv2_value := '(SELECT null,'''|| p_new_code ||''','''|| p_new_name ||''','''|| p_class_name ||' created as a copy of '|| lv2_oriCode ||'''';

  OPEN c_col_name;
  FETCH c_col_name INTO lv2_col;

  IF c_col_name%NOTFOUND THEN
     CLOSE c_col_name;
     RAISE_APPLICATION_ERROR(-20000,'No common data columns found for given classes.');
  END IF;

  LOOP

     lv2_sql := lv2_sql || ',' || lv2_col;

     IF ((lv2_col = 'OBJECT_START_DATE') OR (lv2_col = 'DAYTIME')) AND (p_opt_start_date IS NOT NULL) THEN
        lv2_value := lv2_value || ',to_date('''||to_char(p_opt_start_date,'yyyy-mm-dd')||''',''yyyy-mm-dd'')';
     ELSIF ((lv2_col = 'OBJECT_END_DATE') OR (lv2_col = 'END_DATE')) AND (p_opt_end_date IS NOT NULL) THEN
        lv2_value := lv2_value || ',to_date('''||to_char(p_opt_end_date,'yyyy-mm-dd')||''',''yyyy-mm-dd'')';
     ELSE
        lv2_value := lv2_value || ',' || lv2_col;
     END IF;

     FETCH c_col_name INTO lv2_col;
     IF c_col_name%NOTFOUND THEN
        lv2_sql := lv2_sql || ')';
        EXIT;
     END IF;
  END LOOP;
  CLOSE c_col_name;


  lv2_value := lv2_value || ' FROM OV_'|| p_class_name ||' WHERE OBJECT_ID='''|| p_src_scenario_id ||''' AND DAYTIME=to_date('''||to_char(p_daytime,'yyyy-mm-dd')||''',''yyyy-mm-dd''))';

  lv2_sql := lv2_sql || lv2_value;

  lv2_result := executeStatement(lv2_sql);

  IF lv2_result IS NOT NULL THEN
     RAISE_APPLICATION_ERROR(-20000,'Fail to copy new ' || p_class_name );
  ELSE

     Ue_Forecast_Prod.copyScenarioToNewScenario(p_src_scenario_id, p_opt_start_date, p_opt_end_date, p_new_code, p_new_name);

  END IF;

END copyScenarioToNewScenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyActualsToScenario
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE copyActualsToScenario (
   p_dest_scenario_id 		VARCHAR2,
   p_opt_start_date      DATE,
   p_opt_end_date        DATE
)
IS

BEGIN

  IF (p_dest_scenario_id IS NULL) THEN
     RAISE_APPLICATION_ERROR (-20999, 'No row is being selected.');
  END IF;

  Ue_Forecast_Prod.copyActualsToScenario(p_dest_scenario_id, p_opt_start_date, p_opt_end_date);

END copyActualsToScenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyScenarioToScenario
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE copyScenarioToScenario (
   p_src_scenario_id    VARCHAR2,
   p_dest_scenario_id   VARCHAR2,
   p_opt_start_date     DATE,
   p_opt_end_date       DATE
)
IS

BEGIN

  IF (p_src_scenario_id IS NULL) THEN
    RAISE_APPLICATION_ERROR (-20000, 'No scenario is being selected at the second navigator.');
  END IF;

  IF (p_dest_scenario_id IS NULL) THEN
    RAISE_APPLICATION_ERROR (-20000, 'No scenario is being selected at the [SCENARIOS] data-section.');
  END IF;

  IF p_src_scenario_id = p_dest_scenario_id THEN
    RAISE_APPLICATION_ERROR (-20000, 'Both source and target scenarios are the same.');
  END IF;

  Ue_Forecast_Prod.copyScenarioToScenario(p_src_scenario_id, p_dest_scenario_id, p_opt_start_date, p_opt_end_date);

END copyScenarioToScenario;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function		  : navForecastGroupFilter
-- Description    : To filter forecast that belongs to the group model.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FORECAST_GROUP_VERSION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION navForecastGroupFilter(p_group_type VARCHAR2,
								object_id_1 VARCHAR2,
								object_id_2 VARCHAR2 DEFAULT NULL,
								object_id_3 VARCHAR2 DEFAULT NULL,
								object_id_4 VARCHAR2 DEFAULT NULL,
								object_id_5 VARCHAR2 DEFAULT NULL,
								object_id_6 VARCHAR2 DEFAULT NULL)
RETURN t_forecast_id PIPELINED
IS

CURSOR c_nav_class (cp_group_type VARCHAR2) IS
	SELECT r.from_class_name, r.db_sql_syntax
	FROM class_relation_cnfg r
	WHERE r.to_class_name = 'FORECAST_GROUP'
	AND EcDp_ClassMeta_Cnfg.isDisabled(r.from_class_name, r.to_class_name, r.role_name) = 'N'
	AND r.group_type = cp_group_type
	ORDER BY EcDp_ClassMeta_Cnfg.getDbSortOrder(r.from_class_name, r.to_class_name, r.role_name);

TYPE cv_type IS REF CURSOR;
TYPE lv_object_id_array IS VARRAY(6) OF VARCHAR2(32);

cv cv_type;
ln_count    	NUMBER;
lv2_object_id   VARCHAR2(32);
lv2_sql			VARCHAR2(32000);
la_object_id    lv_object_id_array;

BEGIN

	lv2_sql := 'SELECT OBJECT_ID FROM FORECAST_GROUP_VERSION WHERE';
	ln_count := 1;
	la_object_id := lv_object_id_array(object_id_1,object_id_2,object_id_3,object_id_4,object_id_5,object_id_6);

	FOR curNavClass IN c_nav_class(p_group_type) LOOP
		IF ln_count = 1 THEN
			lv2_sql := lv2_sql||' '||curNavClass.db_sql_syntax||' = '''||la_object_id(ln_count)||'''';
		ELSE
			lv2_sql := lv2_sql||' AND nvl('||curNavClass.db_sql_syntax||',''EMPTY'') in ('''||la_object_id(ln_count)||''',''EMPTY'')';
		END IF;
		ln_count := ln_count + 1;
	END LOOP;

  OPEN cv FOR lv2_sql;
	LOOP
    FETCH cv INTO lv2_object_id;
		EXIT WHEN cv%NOTFOUND;
       PIPE ROW(lv2_object_id);
	END LOOP;
	CLOSE cv;

END navForecastGroupFilter;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteForecast
-- Description    : Delete all forecast and its depedent data including all scenarios,shortfalls and assumptions.
--
-- Preconditions  : The scenarios associated with forecast should not be official.
-- Postconditions :
--
-- Using tables   : FORECAST_GROUP,FORECAST_GROUP_VERSION,FORECAST,FORECAST_VERSION,FORECAST_ASSUMPTIONS,
--                  FORECAST_DOCUMENTS,FCST_SHORTFALL_FACTORS,FCST_SHORTFALL_OVERRIDES,FCST_OBJ_CONSTRAINTS
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  deleteForecast(p_forecast_id VARCHAR2) IS

    ln_official_cnt NUMBER;
    TYPE typ_forecast_object is table of forecast_group.object_id%TYPE;
    t_forecast_object typ_forecast_object :=typ_forecast_object();
    lv2_code_exist   VARCHAR2(32);

    BEGIN

     IF (p_forecast_id IS NULL) THEN
		    RAISE_APPLICATION_ERROR (-20342, 'No Forecast is selected.');
     END IF;

     Ue_Forecast_Prod.deleteForecast(p_forecast_id,lv2_code_exist);

     IF lv2_code_exist <> 'Y' THEN

        select count(*) into ln_official_cnt from forecast_version
        where official_ind='Y'
        and forecast_group_id=p_forecast_id;

        IF ln_official_cnt > 0 then
          RAISE_APPLICATION_ERROR (-20343, 'Forecast cannot be deleted as it has an official scenario');
        ELSE

          DELETE FROM FCST_PRODUNIT_DAY WHERE forecast_id = p_forecast_id;

          DELETE FROM FCST_PRODUNIT_MTH WHERE forecast_id = p_forecast_id;

          DELETE FROM FCST_SUB_PRODUNIT_DAY WHERE forecast_id = p_forecast_id;

          DELETE FROM FCST_SUB_PRODUNIT_MTH WHERE forecast_id = p_forecast_id;

          DELETE FROM FCST_SUB_AREA_DAY WHERE forecast_id = p_forecast_id;

          DELETE FROM FCST_SUB_AREA_MTH WHERE forecast_id = p_forecast_id;

          DELETE FROM FCST_AREA_MTH WHERE forecast_id = p_forecast_id;

          DELETE FROM FCST_AREA_DAY WHERE forecast_id = p_forecast_id;

          DELETE FROM FCST_FCTY_DAY WHERE forecast_id = p_forecast_id;

          DELETE FROM FCST_FCTY_MTH WHERE forecast_id = p_forecast_id;

          DELETE FROM fcst_compensation_events WHERE forecast_id = p_forecast_id;

          DELETE FROM fcst_well_event WHERE forecast_id = p_forecast_id;

          DELETE FROM fcst_obj_constraints  WHERE forecast_id = p_forecast_id;

          DELETE FROM fcst_shortfall_overrides WHERE forecast_id = p_forecast_id;

          DELETE FROM fcst_shortfall_factors WHERE forecast_id = p_forecast_id;

          DELETE FROM forecast_documents WHERE forecast_id = p_forecast_id;

          DELETE FROM forecast_assumptions WHERE forecast_id = p_forecast_id;

          DELETE FROM forecast_version WHERE forecast_group_id = p_forecast_id RETURNING object_id BULK COLLECT INTO t_forecast_object;

          FORALL i IN t_forecast_object.first .. t_forecast_object.last
          DELETE FROM fcst_fcty_day WHERE forecast_id = t_forecast_object(i);

          FORALL i IN t_forecast_object.first .. t_forecast_object.last
          DELETE FROM forecast WHERE class_name='FORECAST_PROD' AND object_id in t_forecast_object(i);

          DELETE FROM forecast_group_version WHERE object_id = p_forecast_id;

          DELETE FROM forecast_group WHERE object_id = p_forecast_id;
        END IF;
    END IF;

END deleteForecast;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteScenario
-- Description    : Delete all scenario data including shortfalls and assumptions.
--
-- Preconditions  : The scenario should not be official.
-- Postconditions :
--
-- Using tables   : FORECAST,FORECAST_VERSION,FORECAST_ASSUMPTIONS,
--                  FORECAST_DOCUMENTS,FCST_SHORTFALL_FACTORS,FCST_SHORTFALL_OVERRIDES,FCST_OBJ_CONSTRAINTS
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  deleteScenario(p_scenario_id VARCHAR2) IS

    ln_official_cnt  NUMBER;
    lv2_code_exist   VARCHAR2(32);

    BEGIN

     IF (p_scenario_id IS NULL) THEN
      RAISE_APPLICATION_ERROR (-20344, 'No Scenario is selected.');
     END IF;

     Ue_Forecast_Prod.deleteScenario(p_scenario_id,lv2_code_exist);

     IF lv2_code_exist <> 'Y' THEN

        select count(*) into ln_official_cnt from forecast_version
        where official_ind='Y'
        and object_id=p_scenario_id;

        IF ln_official_cnt > 0 then
          RAISE_APPLICATION_ERROR (-20345, 'Scenario cannot be deleted as it is official');
        ELSE


          DELETE FROM FCST_PRODUNIT_DAY WHERE scenario_id = p_scenario_id;

          DELETE FROM FCST_PRODUNIT_MTH WHERE scenario_id = p_scenario_id;

          DELETE FROM FCST_SUB_PRODUNIT_DAY WHERE scenario_id = p_scenario_id;

          DELETE FROM FCST_SUB_PRODUNIT_MTH WHERE scenario_id = p_scenario_id;

          DELETE FROM FCST_SUB_AREA_DAY WHERE scenario_id = p_scenario_id;

          DELETE FROM FCST_SUB_AREA_MTH WHERE scenario_id = p_scenario_id;

          DELETE FROM FCST_AREA_MTH WHERE scenario_id = p_scenario_id;

          DELETE FROM FCST_AREA_DAY WHERE scenario_id = p_scenario_id;

          DELETE FROM fcst_compensation_events WHERE object_id = p_scenario_id;

          DELETE FROM fcst_well_event WHERE object_id = p_scenario_id;

          DELETE FROM fcst_obj_constraints  WHERE object_id = p_scenario_id;

          DELETE FROM fcst_shortfall_overrides WHERE object_id = p_scenario_id;

          DELETE FROM fcst_shortfall_factors WHERE object_id = p_scenario_id;

          DELETE FROM forecast_documents WHERE document_type='SCENARIO' AND scenario_id = p_scenario_id;

          DELETE FROM forecast_assumptions WHERE assumption_type='SCENARIO' AND object_id = p_scenario_id;

          DELETE FROM forecast_version WHERE object_id = p_scenario_id;

          DELETE FROM fcst_fcty_day WHERE scenario_id = p_scenario_id;

          DELETE FROM FCST_FCTY_MTH WHERE scenario_id = p_scenario_id;

          DELETE FROM forecast WHERE class_name='FORECAST_PROD' AND object_id = p_scenario_id;

        END IF;
    END IF;

END deleteScenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure  : runScenarioCalc
-- Description    : To set a scenario official
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FORECAST, FORECAST_VERSION, FORECAST_GROUP
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE runScenarioCalc(p_forecast_id  VARCHAR2, p_scenario_id VARCHAR2, p_calculation_code VARCHAR2, p_start_date DATE,p_end_date DATE ,p_user_id VARCHAR2 )
--</EC-DOC>
IS

lv2_code_exist     VARCHAR(32);
ld_execution_start DATE;
ld_execution_end   DATE;
ln_runno           NUMBER;

BEGIN

   -- get unique key value for FCST_JOB_LOG table to assign it to next row
  EcDp_System_Key.assignNextNumber('FCST_JOB_LOG' , ln_runno );
  -- to capture procedure execution start time
  ld_execution_start  := Ecdp_Timestamp.getCurrentSysdate;
  -- user exit package call, execute the user exit code if exists
  Ue_Forecast_Prod.runScenarioCalc(p_forecast_id,p_scenario_id,p_calculation_code,p_start_date,p_end_date,lv2_code_exist);
  -- execute package code if user exist doesn't exists
  IF lv2_code_exist <> 'Y'
  THEN
    IF p_calculation_code = 'CALC_SCENARIO'
    THEN
           -- PLACE code here which need to be executed from PLSQL procedure
            NULL;
    END IF;
  END IF;
  -- to capture procedure execution start time
  ld_execution_end  := Ecdp_Timestamp.getCurrentSysdate;

   -- add entry to log table
  INSERT INTO FCST_JOB_LOG
    ( RUN_NO,
     CALC_NAME,
     FORECAST_ID,
     SCENARIO_ID,
     FROM_PERIOD,
     TO_PERIOD,
     EXIT_STATUS,
     DAYTIME,
     END_DATE ,
     CREATED_BY)
  VALUES
    ( ln_runno,
     p_calculation_code,
     p_forecast_id,
     p_scenario_id,
     p_start_date,
     p_end_date,
     'Success',
     ld_execution_start,
     ld_execution_end,
     NVL(p_user_id, USER));

EXCEPTION

  WHEN OTHERS THEN
-- add entry to log table when exception occurs
  INSERT INTO FCST_JOB_LOG
    ( RUN_NO,
     CALC_NAME,
     FORECAST_ID,
     SCENARIO_ID,
     FROM_PERIOD,
     TO_PERIOD,
     EXIT_STATUS,
     DAYTIME,
     END_DATE ,
     CREATED_BY)
  VALUES
    ( ln_runno,
     p_calculation_code,
     p_forecast_id,
     p_scenario_id,
     p_start_date,
     p_end_date,
     'Error',
     ld_execution_start,
     ld_execution_end,
     NVL(p_user_id, USER));

END runScenarioCalc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure  : calculateAnalysis
-- Description    : To calculate analysis for comparison
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_DEFINE_COMPARE_SCN
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE calculateAnalysis( p_comparison_id VARCHAR2 )
--</EC-DOC>
IS

lv2_code_exist   VARCHAR(32);

BEGIN

  -- user exit package call, execute the user exit code if exists
  Ue_Forecast_Prod.calculateAnalysis(p_comparison_id, lv2_code_exist);

  -- execute package code if user exist doesn't exists
  IF lv2_code_exist <> 'Y'
  THEN
           -- PLACE code here which need to be executed for analysis calculation
            NULL;
  END IF;


EXCEPTION

  WHEN OTHERS THEN
              NULL;

END calculateAnalysis;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure  : deleteComparison
-- Description    : To  delete comparison
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_COMPARISON_VERSION, FORECAST_DOCUMENTS
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  deleteComparison(p_object_id VARCHAR2 )
--</EC-DOC>
IS

lv2_code_exist   VARCHAR(32);

BEGIN

  -- user exit package call, execute the user exit code if exists
  Ue_Forecast_Prod.deleteComparison(p_object_id, lv2_code_exist);

  -- execute package code if user exist doesn't exists
  IF lv2_code_exist <> 'Y'
  THEN

        --  delete related documents
        DELETE FROM FORECAST_DOCUMENTS
        WHERE  DOCUMENT_TYPE   = 'COMPARISON'
        AND    COMPARISON_ID =  p_object_id ;

        DELETE FROM FCST_COMPARISON_VERSION
        WHERE  OBJECT_ID    = p_object_id ;

        --  delete comparison
        DELETE FROM FCST_COMPARISON
        WHERE  OBJECT_ID    = p_object_id ;

  END IF;


EXCEPTION

  WHEN OTHERS THEN
              NULL;

END deleteComparison;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure  : deleteComparison
-- Description    : To  update end date comparison
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_COMPARISON_VERSION, FCST_COMPARISON
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  updateEndDateComparison( p_object_end_date DATE,
                                    p_object_id VARCHAR2)
IS

BEGIN


   UPDATE FCST_COMPARISON_VERSION
   SET END_DATE = p_object_end_date
   WHERE OBJECT_ID = p_object_id;


   UPDATE FCST_COMPARISON
   SET END_DATE = p_object_end_date
   WHERE OBJECT_ID = p_object_id;


END updateEndDateComparison;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure  : deleteComparison
-- Description    : To  update end date comparison
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_COMPARISON_VERSION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  updateDaytimeComparison( p_object_start_date DATE,
                                    p_object_id VARCHAR2)
IS

BEGIN


   UPDATE FCST_COMPARISON_VERSION
   SET DAYTIME = p_object_start_date
   WHERE OBJECT_ID = p_object_id;


END updateDaytimeComparison;


END EcDp_Forecast_Prod;