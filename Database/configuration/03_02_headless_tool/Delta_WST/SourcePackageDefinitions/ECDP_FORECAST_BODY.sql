CREATE OR REPLACE PACKAGE BODY EcDp_Forecast IS
/**************************************************************************************************
** Package  :  EcDp_Forecast
**
** $Revision: 1.16 $
**
** Purpose  :  Data package for Forecasting
**
**
**
** General Logic:
**
** Created:     20.04.2006 Atle Weibell
**
** Modification history:
**
** Date:       Whom:    Rev.  Change description:
** ----------  -------- ----  ------------------------------------------------------------------------
** 09.05.2006  awe      1.1   Added function validatePeriodTypes
**                            Added procedures generateComp, deleteComp
**                            Added procedures copyForecast, copyForecastInput, copyForecastAnalysis
**                            Added support function getLastLine and support procedure deblog
** 10.05.2006  awe      1.2   Added procedure copyForecastResult
** 04.07.2006  idrussab 1.3   Update procedure copyForecastAnalysis, copyForecastInput and copyForecastResult to include the VALUE or TEXT columns
**                            Update procedure copyForecastAnalysis for assignNextNumber to use tablename = 'FCST_ANALYSIS'
** 24.08.2006  Toha           TI4255: daytime should follow new period during copy. Change the copy to safer way
** 16.10.2006  Rahmanaz       TI4537: Update procedure copyForecast. Add NULL condition on checking p_copy_type.
** 30.07.2012  leongsei       ECPD-10325: Replaced dbms_output by EcDp_DynSql.WriteDebugText
** 30.12.2013  genasdev       ECPD_7040: Need FCST_CNTR_DAY_DP_CP_AL table/class in forecasting
** 03.03.2015  thotesan       ECPD-29635: Updated procedure: copyForecastResult for Daily AFS
** 11.03.2015  sharawan       ECPD-29636: Update copyForecastResult to include new tables (Daily Nomination Point AFS) while copy function trigger
** 03.07.2017  asareswi       ECPD-45818: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
**************************************************************************************************/

pv_line_number NUMBER;
pv_error_diff_period_type VARCHAR2(80) NOT NULL DEFAULT 'FROM and TO Forecast must be of same TYPE! (e.g. Short, Medium or Long)';
pv_error_same_period VARCHAR2(80) NOT NULL DEFAULT 'Cannot copy FROM and TO the same Forecast!';



--creating new object_id for the new forecast
PROCEDURE createForecast(p_from_forecast_id VARCHAR2, p_copy_type VARCHAR2, p_period_type VARCHAR2, p_forecast_type VARCHAR2, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2,
                         p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE)
IS
    lv_validation INTEGER;
	p_new_forecast_id VARCHAR2(32) := NULL;

BEGIN

    IF (p_from_forecast_id IS NULL) THEN
		Raise_Application_Error(-20000,'Missing copy from forecast id');
	END IF;

	--generating forecast_id
	p_new_forecast_id:= EcDp_objects.GetInsertedObjectID(p_new_forecast_id);

	INSERT INTO FORECAST(object_id,CLASS_NAME,PERIOD_TYPE,FORECAST_TYPE,OBJECT_CODE,START_DATE,END_DATE,created_by)
    VALUES(p_new_forecast_id,'FORECAST_TRAN_FC',p_period_type,p_forecast_type,p_new_forecast_code,p_start_date,p_end_date,ecdp_context.getAppUser);

    INSERT INTO FORECAST_VERSION(object_id,daytime,end_date, NAME, created_by)
    VALUES(p_new_forecast_id, p_start_date, p_end_date, p_new_forecast_code, ecdp_context.getAppUser);

	-- check that forecast_id exist and that forecast_type is the same for from and to
	 lv_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (lv_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (lv_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period );
	END IF;

	copyForecast(p_from_forecast_id, p_new_forecast_id, p_copy_type, p_comment, p_user);

END createForecast;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function			: getLastLine
-- Description    : returns max(line_number) from t_temptext for given id
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :	t_temptext
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastLine(p_id VARCHAR2)
--</EC-DOC>
RETURN NUMBER
IS

CURSOR c_temp (cp_id VARCHAR2) IS
	SELECT nvl(max(line_number),10) AS lastline
	FROM t_temptext
	WHERE id = cp_id;

lv_max_number NUMBER;

BEGIN
	FOR curTemp IN c_temp(p_id) LOOP
		lv_max_number := curTemp.lastline;
	END LOOP;
	RETURN lv_max_number;
END getLastLine;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function			: deblog
-- Description    : logs debug information to console and/or to t_temptext
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : t_temptext
-- Using functions: getLastLine
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deblog(p_text VARCHAR2, p_id VARCHAR2 DEFAULT 'FCST')
--</EC-DOC>
IS

BEGIN
	IF(pv_line_number IS NULL) THEN
		pv_line_number := getLastLine(p_id) + 1;
	ELSE
		pv_line_number := pv_line_number + 1;
	END IF;

  INSERT INTO t_temptext (id, line_number, text)
	VALUES (p_id, pv_line_number, p_text);

END deblog;


--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : generateComp
-- Description    : Function generates components for given analysis record in fcst_analysis
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : fcst_analysis_component / fcst_analysis / comp_list
--
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
PROCEDURE generateComp( p_object_id			VARCHAR2,
								p_daytime				DATE,
								p_forecast_id			VARCHAR2,
								p_series					VARCHAR2)

 IS

  CURSOR c_component IS
    SELECT component_no
      FROM comp_set_list
     WHERE component_set = 'TRAN_FCST_COMP';

  CURSOR c_analysis IS
    SELECT analysis_no, created_by
      FROM fcst_analysis
     WHERE object_id = p_object_id
       AND forecast_id = p_forecast_id
       AND series = p_series
       AND daytime = p_daytime;

  ln_analysis c_analysis%ROWTYPE;

BEGIN

  IF NOT c_analysis%ISOPEN THEN
    OPEN c_analysis;
  END IF;

  FETCH c_analysis
    INTO ln_analysis;

  IF ln_analysis.analysis_no IS NOT NULL THEN
    FOR curComponent IN c_component LOOP
      IF curComponent.component_no IS NOT NULL THEN

        INSERT INTO fcst_analysis_component
          (ANALYSIS_NO,
           COMPONENT_NO,
           RECORD_STATUS,
           CREATED_BY,
           CREATED_DATE,
           MOL_PCT,
           WT_PCT)
        VALUES
          (ln_analysis.analysis_no,
           curComponent.component_no,
           'P',
           ln_analysis.created_by,
           Ecdp_Timestamp.getCurrentSysdate,
           NULL,
           NULL);

      END IF;

    END LOOP;

  END IF;

END generateComp;


--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : deleteComp
-- Description    : Function deletes components for given analysis record in fcst_analysis
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : fcst_analysis_component / fcst_analysis
--
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
PROCEDURE deleteComp(p_analysis_no NUMBER)
 IS

  CURSOR c_analysis_component (cp_analysis_no NUMBER) IS
    SELECT component_no
      FROM fcst_analysis_component
     WHERE analysis_no = cp_analysis_no;

BEGIN

	FOR curAnCom IN c_analysis_component (p_analysis_no) LOOP
    DELETE FROM fcst_analysis_component
     WHERE component_no = curAnCom.component_no
       AND analysis_no = p_analysis_no;
	END LOOP;

END deleteComp;


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


lv_from_period_type VARCHAR2(32);
lv_to_period_type VARCHAR2(32);

BEGIN

	FOR curPeriods IN c_get_period_type(p_from_forecast_id, p_new_forecast_id) LOOP
		EcDp_DynSql.WriteDebugText('validatePeriodTypes', 'forecast_id: ' || curPeriods.object_id, 'DEBUG' );
		IF (curPeriods.object_id = p_from_forecast_id)
			THEN lv_from_period_type := curPeriods.period_type;
		END IF;
		IF (curPeriods.object_id = p_new_forecast_id)
			THEN lv_to_period_type := curPeriods.period_type;
		END IF;
	END LOOP;

  EcDp_DynSql.WriteDebugText('validatePeriodTypes', 'lv_from_period_type: ' || lv_from_period_type, 'DEBUG' );
  EcDp_DynSql.WriteDebugText('validatePeriodTypes', 'lv_to_period_type: ' || lv_to_period_type, 'DEBUG' );

	IF (lv_from_period_type IS NULL OR lv_to_period_type IS NULL)
		THEN RETURN -1;
	ELSIF (lv_to_period_type != lv_from_period_type)
		THEN RETURN -1;
	ELSIF (p_from_forecast_id = p_new_forecast_id)
		THEN RETURN -2;
	ELSE RETURN 0;
	END IF;

END validatePeriodTypes;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyForecastAnalysis
-- Description    : Copy Analysis data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : fcst_analysis / fcst_analysis_component
-- Using functions: validatePeriodTypes
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyForecastAnalysis(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_copy_type VARCHAR2, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

TYPE t_fcst_analysis IS TABLE OF fcst_analysis%ROWTYPE;
l_fcst_analysis t_fcst_analysis;

TYPE t_fcst_analysis_component IS TABLE OF fcst_analysis_component%ROWTYPE;
l_fcst_analysis_component t_fcst_analysis_component;

ln_time_difference NUMBER;
ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

-- from-data
CURSOR c_analysis (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_analysis
	WHERE forecast_id = cp_from_forecast_id;

CURSOR c_component (cp_analysis_no VARCHAR2)
IS
	SELECT *
	FROM fcst_analysis_component
	WHERE analysis_no = cp_analysis_no;

	lv_analysis_no NUMBER;
	lv_validation INTEGER;

BEGIN

	lv_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (lv_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (lv_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;

	-- delete any existing data on to_forecast_id from analysis component table
 DELETE FROM fcst_analysis_component WHERE analysis_no IN (
        SELECT analysis_no FROM fcst_analysis WHERE forecast_id = p_new_forecast_id);

	-- delete any existing data on to_forecast_id from analysis table
	DELETE FROM fcst_analysis WHERE forecast_id = p_new_forecast_id;

  select daytime - (select daytime from ov_forecast_tran_fc where object_id = p_from_forecast_id) INTO ln_time_difference
    from ov_forecast_tran_fc
    where object_id = p_new_forecast_id;

  OPEN c_analysis (p_from_forecast_id);
    LOOP
    FETCH c_analysis BULK COLLECT INTO l_fcst_analysis LIMIT 2000;

    FOR i IN 1..l_fcst_analysis.COUNT LOOP
      lv_analysis_no := l_fcst_analysis(i).analysis_no;
      EcDp_System_Key.assignNextNumber('FCST_ANALYSIS',l_fcst_analysis(i).analysis_no);
      l_fcst_analysis(i).forecast_id := p_new_forecast_id;
      l_fcst_analysis(i).daytime := l_fcst_analysis(i).daytime + ln_time_difference;
      l_fcst_analysis(i).created_by := p_user;
      l_fcst_analysis(i).created_date := ld_now;
      l_fcst_analysis(i).last_updated_by := NULL;
      l_fcst_analysis(i).last_updated_date := NULL;
      l_fcst_analysis(i).rev_text := p_comment;
      INSERT INTO fcst_analysis VALUES l_fcst_analysis(i);

        OPEN c_component (lv_analysis_no);
            LOOP
            FETCH c_component BULK COLLECT INTO l_fcst_analysis_component LIMIT 2000;

            FOR j IN 1..l_fcst_analysis_component.COUNT LOOP
                l_fcst_analysis_component(j).analysis_no := l_fcst_analysis(i).analysis_no;
                l_fcst_analysis_component(j).created_by := p_user;
                l_fcst_analysis_component(j).created_date := ld_now;
                l_fcst_analysis_component(j).last_updated_by := NULL;
                l_fcst_analysis_component(j).last_updated_date := NULL;
                l_fcst_analysis_component(j).rev_text := p_comment;
             END LOOP;

             FORALL j IN 1..l_fcst_analysis_component.COUNT
                INSERT INTO fcst_analysis_component VALUES l_fcst_analysis_component(j);

             EXIT WHEN c_component%NOTFOUND;

             END LOOP;
          CLOSE c_component;

     END LOOP;

    EXIT WHEN c_analysis%NOTFOUND;

  END LOOP;
  CLOSE c_analysis;
END copyForecastAnalysis;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyForecastInput
-- Description    : Copy Input data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : fcst_cntr_day_status / fcst_dp_day_status / fcst_nompnt_day_status
-- Using functions: validatePeriodTypes
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyForecastInput(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_copy_type VARCHAR2, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)


--</EC-DOC>
IS

TYPE t_fcst_cntr_day_status IS TABLE OF fcst_cntr_day_status%ROWTYPE;
l_fcst_cntr_day_status t_fcst_cntr_day_status;

TYPE t_fcst_dp_day_status IS TABLE OF fcst_dp_day_status%ROWTYPE;
l_fcst_dp_day_status t_fcst_dp_day_status;

TYPE t_fcst_nompnt_day_status IS TABLE OF fcst_nompnt_day_status%ROWTYPE;
l_fcst_nompnt_day_status t_fcst_nompnt_day_status;

ln_time_difference NUMBER;
ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

-- from-data
CURSOR c_cntr_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_cntr_day_status
	WHERE forecast_id = cp_from_forecast_id;

CURSOR c_dp_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_dp_day_status
	WHERE forecast_id = cp_from_forecast_id;

CURSOR c_cntr_dp_status_from (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_nompnt_day_status
	WHERE forecast_id = cp_from_forecast_id;

	lv_validation INTEGER;

BEGIN

	lv_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (lv_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (lv_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period);
	END IF;


	-- delete any existing data on to_forecast_id from input tables
	DELETE FROM fcst_cntr_day_status WHERE forecast_id = p_new_forecast_id;
	DELETE FROM fcst_dp_day_status WHERE forecast_id = p_new_forecast_id;
	DELETE FROM fcst_nompnt_day_status WHERE forecast_id = p_new_forecast_id;

  select daytime - (select daytime from ov_forecast_tran_fc where object_id = p_from_forecast_id) INTO ln_time_difference
    from ov_forecast_tran_fc
    where object_id = p_new_forecast_id;

  OPEN c_cntr_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_status_from BULK COLLECT INTO l_fcst_cntr_day_status LIMIT 2000;

    FOR i IN 1..l_fcst_cntr_day_status.COUNT LOOP
      l_fcst_cntr_day_status(i).forecast_id := p_new_forecast_id;
      l_fcst_cntr_day_status(i).daytime := l_fcst_cntr_day_status(i).daytime + ln_time_difference;
      l_fcst_cntr_day_status(i).created_by := p_user;
      l_fcst_cntr_day_status(i).created_date := ld_now;
      l_fcst_cntr_day_status(i).last_updated_by := NULL;
      l_fcst_cntr_day_status(i).last_updated_date := NULL;
      l_fcst_cntr_day_status(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_cntr_day_status.COUNT
      INSERT INTO fcst_cntr_day_status VALUES l_fcst_cntr_day_status(i);

    EXIT WHEN c_cntr_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_status_from;

  OPEN c_dp_status_from (p_from_forecast_id);
    LOOP
    FETCH c_dp_status_from BULK COLLECT INTO l_fcst_dp_day_status LIMIT 2000;

    FOR i IN 1..l_fcst_dp_day_status.COUNT LOOP
      l_fcst_dp_day_status(i).forecast_id := p_new_forecast_id;
      l_fcst_dp_day_status(i).daytime := l_fcst_dp_day_status(i).daytime + ln_time_difference;
      l_fcst_dp_day_status(i).created_by := p_user;
      l_fcst_dp_day_status(i).created_date := ld_now;
      l_fcst_dp_day_status(i).last_updated_by := NULL;
      l_fcst_dp_day_status(i).last_updated_date := NULL;
      l_fcst_dp_day_status(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_dp_day_status.COUNT
      INSERT INTO fcst_dp_day_status VALUES l_fcst_dp_day_status(i);

    EXIT WHEN c_dp_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_dp_status_from;

  OPEN c_cntr_dp_status_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_dp_status_from BULK COLLECT INTO l_fcst_nompnt_day_status LIMIT 2000;

    FOR i IN 1..l_fcst_nompnt_day_status.COUNT LOOP
      l_fcst_nompnt_day_status(i).forecast_id := p_new_forecast_id;
      l_fcst_nompnt_day_status(i).daytime := l_fcst_nompnt_day_status(i).daytime + ln_time_difference;
      l_fcst_nompnt_day_status(i).created_by := p_user;
      l_fcst_nompnt_day_status(i).created_date := ld_now;
      l_fcst_nompnt_day_status(i).last_updated_by := NULL;
      l_fcst_nompnt_day_status(i).last_updated_date := NULL;
      l_fcst_nompnt_day_status(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_nompnt_day_status.COUNT
      INSERT INTO fcst_nompnt_day_status VALUES l_fcst_nompnt_day_status(i);

    EXIT WHEN c_cntr_dp_status_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_dp_status_from;

END copyForecastInput;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyForecastResult
-- Description    : Copy Result data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : fcst_cntr_day_alloc / fcst_dp_day_alloc / fcst_nompnt_day_alloc
-- Using functions: validatePeriodTypes
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyForecastResult(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_copy_type VARCHAR2, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)

--</EC-DOC>
IS

TYPE t_fcst_cntr_day_alloc IS TABLE OF fcst_cntr_day_alloc%ROWTYPE;
l_fcst_cntr_day_alloc t_fcst_cntr_day_alloc;

TYPE t_fcst_dp_day_alloc IS TABLE OF fcst_dp_day_alloc%ROWTYPE;
l_fcst_dp_day_alloc t_fcst_dp_day_alloc;

TYPE t_fcst_nompnt_day_alloc IS TABLE OF fcst_nompnt_day_alloc%ROWTYPE;
l_fcst_nompnt_day_alloc t_fcst_nompnt_day_alloc;

TYPE t_fcst_cntr_day_dp_cp_al IS TABLE OF fcst_cntr_day_dp_cp_al%ROWTYPE;
l_fcst_cntr_day_dp_cp_al t_fcst_cntr_day_dp_cp_al;

TYPE t_fcst_sp_day_afs IS TABLE OF fcst_sp_day_afs%ROWTYPE;
l_t_fcst_sp_day_afs t_fcst_sp_day_afs;

TYPE t_fcst_sp_day_cpy_afs IS TABLE OF fcst_sp_day_cpy_afs%ROWTYPE;
l_fcst_sp_day_cpy_afs t_fcst_sp_day_cpy_afs;

TYPE t_fcst_nompnt_day_afs IS TABLE OF fcst_nompnt_day_afs%ROWTYPE;
l_fcst_nompnt_day_afs t_fcst_nompnt_day_afs;

TYPE t_fcst_nompnt_day_cpy_afs IS TABLE OF fcst_nompnt_day_cpy_afs%ROWTYPE;
l_fcst_nompnt_day_cpy_afs t_fcst_nompnt_day_cpy_afs;

ln_time_difference NUMBER;
ld_now DATE := Ecdp_Timestamp.getCurrentSysdate;

-- from-data
CURSOR c_cntr_alloc_from (cp_from_forecast_id VARCHAR2)
IS
  SELECT *
  FROM fcst_cntr_day_alloc
  WHERE forecast_id = cp_from_forecast_id;

CURSOR c_dp_alloc_from (cp_from_forecast_id VARCHAR2)
IS
  SELECT *
  FROM fcst_dp_day_alloc
  WHERE forecast_id = cp_from_forecast_id;

CURSOR c_cntr_dp_alloc_from (cp_from_forecast_id VARCHAR2)
IS
  SELECT *
  FROM fcst_nompnt_day_alloc
  WHERE forecast_id = cp_from_forecast_id;

CURSOR c_cntr_dp_cp_al_from (cp_from_forecast_id VARCHAR2)
IS
  SELECT *
  FROM fcst_cntr_day_dp_cp_al
  WHERE forecast_id = cp_from_forecast_id;

CURSOR c_fcst_sp_day_afs_from (cp_from_forecast_id VARCHAR2)
IS
  SELECT *
  FROM fcst_sp_day_afs
  WHERE forecast_id = cp_from_forecast_id;

CURSOR c_fcst_sp_day_cpy_afs_from (cp_from_forecast_id VARCHAR2)
IS
  SELECT *
  FROM fcst_sp_day_cpy_afs
  WHERE forecast_id = cp_from_forecast_id;

CURSOR c_fcst_nompnt_day_afs (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_nompnt_day_afs
	WHERE forecast_id = cp_from_forecast_id;

CURSOR c_fcst_nompnt_day_cpy_afs (cp_from_forecast_id VARCHAR2)
IS
	SELECT *
	FROM fcst_nompnt_day_cpy_afs
	WHERE forecast_id = cp_from_forecast_id;

  lv_validation INTEGER;

BEGIN

  lv_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
  IF (lv_validation = -1)
    THEN raise_application_error(-20000, pv_error_diff_period_type);
  ELSIF (lv_validation = -2)
    THEN raise_application_error(-20000, pv_error_same_period);
  END IF;


  -- delete any existing data on to_forecast_id from input tables
  DELETE FROM fcst_cntr_day_alloc WHERE forecast_id = p_new_forecast_id;
  DELETE FROM fcst_dp_day_alloc WHERE forecast_id = p_new_forecast_id;
  DELETE FROM fcst_nompnt_day_alloc WHERE forecast_id = p_new_forecast_id;
  DELETE FROM fcst_cntr_day_dp_cp_al WHERE forecast_id = p_new_forecast_id;
  DELETE FROM fcst_sp_day_afs WHERE forecast_id = p_new_forecast_id;
  DELETE FROM fcst_sp_day_cpy_afs WHERE forecast_id = p_new_forecast_id;
	DELETE FROM fcst_nompnt_day_afs WHERE forecast_id = p_new_forecast_id;
	DELETE FROM fcst_nompnt_day_cpy_afs WHERE forecast_id = p_new_forecast_id;

  select daytime - (select daytime from ov_forecast_tran_fc where object_id = p_from_forecast_id) INTO ln_time_difference
    from ov_forecast_tran_fc
    where object_id = p_new_forecast_id;

  OPEN c_cntr_alloc_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_alloc_from BULK COLLECT INTO l_fcst_cntr_day_alloc LIMIT 2000;

    FOR i IN 1..l_fcst_cntr_day_alloc.COUNT LOOP
      l_fcst_cntr_day_alloc(i).forecast_id := p_new_forecast_id;
      l_fcst_cntr_day_alloc(i).daytime := l_fcst_cntr_day_alloc(i).daytime + ln_time_difference;
      l_fcst_cntr_day_alloc(i).created_by := p_user;
      l_fcst_cntr_day_alloc(i).created_date := ld_now;
      l_fcst_cntr_day_alloc(i).last_updated_by := NULL;
      l_fcst_cntr_day_alloc(i).last_updated_date := NULL;
      l_fcst_cntr_day_alloc(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_cntr_day_alloc.COUNT
      INSERT INTO fcst_cntr_day_alloc VALUES l_fcst_cntr_day_alloc(i);

    EXIT WHEN c_cntr_alloc_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_alloc_from;

  OPEN c_dp_alloc_from (p_from_forecast_id);
    LOOP
    FETCH c_dp_alloc_from BULK COLLECT INTO l_fcst_dp_day_alloc LIMIT 2000;

    FOR i IN 1..l_fcst_dp_day_alloc.COUNT LOOP
      l_fcst_dp_day_alloc(i).forecast_id := p_new_forecast_id;
      l_fcst_dp_day_alloc(i).daytime := l_fcst_dp_day_alloc(i).daytime + ln_time_difference;
      l_fcst_dp_day_alloc(i).created_by := p_user;
      l_fcst_dp_day_alloc(i).created_date := ld_now;
      l_fcst_dp_day_alloc(i).last_updated_by := NULL;
      l_fcst_dp_day_alloc(i).last_updated_date := NULL;
      l_fcst_dp_day_alloc(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_dp_day_alloc.COUNT
      INSERT INTO fcst_dp_day_alloc VALUES l_fcst_dp_day_alloc(i);

    EXIT WHEN c_dp_alloc_from%NOTFOUND;

  END LOOP;
  CLOSE c_dp_alloc_from;

  OPEN c_cntr_dp_alloc_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_dp_alloc_from BULK COLLECT INTO l_fcst_nompnt_day_alloc LIMIT 2000;

    FOR i IN 1..l_fcst_nompnt_day_alloc.COUNT LOOP
      l_fcst_nompnt_day_alloc(i).forecast_id := p_new_forecast_id;
      l_fcst_nompnt_day_alloc(i).daytime := l_fcst_nompnt_day_alloc(i).daytime + ln_time_difference;
      l_fcst_nompnt_day_alloc(i).created_by := p_user;
      l_fcst_nompnt_day_alloc(i).created_date := ld_now;
      l_fcst_nompnt_day_alloc(i).last_updated_by := NULL;
      l_fcst_nompnt_day_alloc(i).last_updated_date := NULL;
      l_fcst_nompnt_day_alloc(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_nompnt_day_alloc.COUNT
      INSERT INTO fcst_nompnt_day_alloc VALUES l_fcst_nompnt_day_alloc(i);

    EXIT WHEN c_cntr_dp_alloc_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_dp_alloc_from;

  OPEN c_cntr_dp_cp_al_from (p_from_forecast_id);
    LOOP
    FETCH c_cntr_dp_cp_al_from BULK COLLECT INTO l_fcst_cntr_day_dp_cp_al LIMIT 2000;

    FOR i IN 1..l_fcst_cntr_day_dp_cp_al.COUNT LOOP
      l_fcst_cntr_day_dp_cp_al(i).forecast_id := p_new_forecast_id;
      l_fcst_cntr_day_dp_cp_al(i).daytime := l_fcst_cntr_day_dp_cp_al(i).daytime + ln_time_difference;
      l_fcst_cntr_day_dp_cp_al(i).created_by := p_user;
      l_fcst_cntr_day_dp_cp_al(i).created_date := ld_now;
      l_fcst_cntr_day_dp_cp_al(i).last_updated_by := NULL;
      l_fcst_cntr_day_dp_cp_al(i).last_updated_date := NULL;
      l_fcst_cntr_day_dp_cp_al(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_cntr_day_dp_cp_al.COUNT
      INSERT INTO fcst_cntr_day_dp_cp_al VALUES l_fcst_cntr_day_dp_cp_al(i);

    EXIT WHEN c_cntr_dp_cp_al_from%NOTFOUND;

  END LOOP;
  CLOSE c_cntr_dp_cp_al_from;

  OPEN c_fcst_sp_day_afs_from (p_from_forecast_id);
    LOOP
    FETCH c_fcst_sp_day_afs_from BULK COLLECT INTO l_t_fcst_sp_day_afs LIMIT 2000;

    FOR i IN 1..l_t_fcst_sp_day_afs.COUNT LOOP
      l_t_fcst_sp_day_afs(i).forecast_id := p_new_forecast_id;
      l_t_fcst_sp_day_afs(i).daytime := l_t_fcst_sp_day_afs(i).daytime + ln_time_difference;
      l_t_fcst_sp_day_afs(i).created_by := p_user;
      l_t_fcst_sp_day_afs(i).created_date := ld_now;
      l_t_fcst_sp_day_afs(i).last_updated_by := NULL;
      l_t_fcst_sp_day_afs(i).last_updated_date := NULL;
      l_t_fcst_sp_day_afs(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_t_fcst_sp_day_afs.COUNT
      INSERT INTO fcst_sp_day_afs VALUES l_t_fcst_sp_day_afs(i);

    EXIT WHEN c_fcst_sp_day_afs_from%NOTFOUND;

  END LOOP;
  CLOSE c_fcst_sp_day_afs_from;

  OPEN c_fcst_sp_day_cpy_afs_from (p_from_forecast_id);
    LOOP
    FETCH c_fcst_sp_day_cpy_afs_from BULK COLLECT INTO l_fcst_sp_day_cpy_afs LIMIT 2000;

    FOR i IN 1..l_fcst_sp_day_cpy_afs.COUNT LOOP
      l_fcst_sp_day_cpy_afs(i).forecast_id := p_new_forecast_id;
      l_fcst_sp_day_cpy_afs(i).daytime := l_fcst_sp_day_cpy_afs(i).daytime + ln_time_difference;
      l_fcst_sp_day_cpy_afs(i).created_by := p_user;
      l_fcst_sp_day_cpy_afs(i).created_date := ld_now;
      l_fcst_sp_day_cpy_afs(i).last_updated_by := NULL;
      l_fcst_sp_day_cpy_afs(i).last_updated_date := NULL;
      l_fcst_sp_day_cpy_afs(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_sp_day_cpy_afs.COUNT
      INSERT INTO fcst_sp_day_cpy_afs VALUES l_fcst_sp_day_cpy_afs(i);

    EXIT WHEN c_fcst_sp_day_cpy_afs_from%NOTFOUND;

  END LOOP;
  CLOSE c_fcst_sp_day_cpy_afs_from;

  OPEN c_fcst_nompnt_day_afs (p_from_forecast_id);
    LOOP
    FETCH c_fcst_nompnt_day_afs BULK COLLECT INTO l_fcst_nompnt_day_afs LIMIT 2000;

    FOR i IN 1..l_fcst_nompnt_day_afs.COUNT LOOP
      l_fcst_nompnt_day_afs(i).forecast_id := p_new_forecast_id;
      l_fcst_nompnt_day_afs(i).daytime := l_fcst_nompnt_day_afs(i).daytime + ln_time_difference;
      l_fcst_nompnt_day_afs(i).created_by := p_user;
      l_fcst_nompnt_day_afs(i).created_date := ld_now;
      l_fcst_nompnt_day_afs(i).last_updated_by := NULL;
      l_fcst_nompnt_day_afs(i).last_updated_date := NULL;
      l_fcst_nompnt_day_afs(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_nompnt_day_afs.COUNT
      INSERT INTO fcst_nompnt_day_afs VALUES l_fcst_nompnt_day_afs(i);

    EXIT WHEN c_fcst_nompnt_day_afs%NOTFOUND;

  END LOOP;

  CLOSE c_fcst_nompnt_day_afs;

  OPEN c_fcst_nompnt_day_cpy_afs (p_from_forecast_id);
    LOOP
    FETCH c_fcst_nompnt_day_cpy_afs BULK COLLECT INTO l_fcst_nompnt_day_cpy_afs LIMIT 2000;

    FOR i IN 1..l_fcst_nompnt_day_cpy_afs.COUNT LOOP
      l_fcst_nompnt_day_cpy_afs(i).forecast_id := p_new_forecast_id;
      l_fcst_nompnt_day_cpy_afs(i).daytime := l_fcst_nompnt_day_cpy_afs(i).daytime + ln_time_difference;
      l_fcst_nompnt_day_cpy_afs(i).created_by := p_user;
      l_fcst_nompnt_day_cpy_afs(i).created_date := ld_now;
      l_fcst_nompnt_day_cpy_afs(i).last_updated_by := NULL;
      l_fcst_nompnt_day_cpy_afs(i).last_updated_date := NULL;
      l_fcst_nompnt_day_cpy_afs(i).rev_text := p_comment;
    END LOOP;

    FORALL i IN 1..l_fcst_nompnt_day_cpy_afs.COUNT
      INSERT INTO fcst_nompnt_day_cpy_afs VALUES l_fcst_nompnt_day_cpy_afs(i);

    EXIT WHEN c_fcst_nompnt_day_cpy_afs%NOTFOUND;

  END LOOP;

  CLOSE c_fcst_nompnt_day_cpy_afs;

END copyForecastResult;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyForecast
-- Description    : Copy data from one forecast period to another
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: validatePeriodTypes / copyForecastInput / copyforecastAnalysis
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyForecast(p_from_forecast_id VARCHAR2, p_new_forecast_id VARCHAR2, p_copy_type VARCHAR2, p_comment VARCHAR2 DEFAULT NULL, p_user VARCHAR2)
--</EC-DOC>
IS

	lv_validation INTEGER;

BEGIN

	-- check that forecast_id exist and that forecast_type is the same for from and to
 /* 	lv_validation := validatePeriodTypes(p_from_forecast_id, p_new_forecast_id);
	IF (lv_validation = -1)
		THEN raise_application_error(-20000, pv_error_diff_period_type);
	ELSIF (lv_validation = -2)
		THEN raise_application_error(-20000, pv_error_same_period );
	END IF; */

	CASE p_copy_type
		WHEN 'ALL' THEN
			copyForecastInput(p_from_forecast_id, p_new_forecast_id, p_copy_type, p_comment, p_user);

			copyForecastResult(p_from_forecast_id, p_new_forecast_id, p_copy_type, p_comment, p_user);
			copyForecastAnalysis(p_from_forecast_id, p_new_forecast_id, p_copy_type, p_comment, p_user);
		WHEN 'ALL_EXCL_OUTPUT' THEN
			copyForecastInput(p_from_forecast_id, p_new_forecast_id, p_copy_type, p_comment, p_user);
			copyForecastAnalysis(p_from_forecast_id, p_new_forecast_id, p_copy_type, p_comment, p_user);
		WHEN 'INPUT' THEN
			copyForecastInput(p_from_forecast_id, p_new_forecast_id, p_copy_type, p_comment, p_user);
		WHEN 'RESULT' THEN
			copyForecastResult(p_from_forecast_id, p_new_forecast_id, p_copy_type, p_comment, p_user);
		WHEN 'COMPOSITION' THEN
			copyForecastAnalysis(p_from_forecast_id, p_new_forecast_id, p_copy_type, p_comment, p_user);
	        ELSE
	                NULL;
	END CASE;
	--ue_forecast.copyFromForecast(p_from_forecast_id, p_new_forecast_id, p_copy_type, p_comment, p_user);

END copyForecast;


END EcDp_Forecast;