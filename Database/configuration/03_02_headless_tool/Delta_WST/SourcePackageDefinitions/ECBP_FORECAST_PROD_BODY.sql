CREATE OR REPLACE PACKAGE BODY EcBp_Forecast_Prod IS
/**************************************************************************************************
** Package  :  EcBp_Forecast_Prod
**
** $Revision: 1.16 $
**
** Purpose  :
**
** General Logic:
**
** Created        :  23-09-2015 Suresh Kumar
**
** Modification history:
**
** Date        Whom  Change description:
** 23-09-15		kumarsur	ECPD-31862: Added getProdForecastId, dynCursorGetForecastId.
** 03-05-16   leongwen  ECPD-34297: Added getShortfallOverride and getShortfallFactor functions.
** 20-06-16   leongwen  ECPD-34297: Modified the getShortfallOverride and getShortfallFactor functions for parameter from p_forecast_id to p_scenario_id
** 26-06-16   kashisag  ECPD-36236 : Added getMaxConstraintValue to get maximum value for each phase as per scenario and daytime.
** 06.07.2016 jainnraj  ECPD-36978: Modified dynCursorGetForecastId to change official column to official_ind
** 12-07-16   kumarsur  ECPD-36900: Modified scenario_id to object_id.
** 24-08-16   kashisag  ECPD-37330: Added getPhaseUOM, getPhaseUOMLabel and getConvertedVolume functions to get Phase UOM and volume as per selected phase
** 23-09-16   kashisag  ECPD-37500: Added new function to calculate the unconstrained potential value
** 13-10-16   khatrnit  ECPD-39279: Added getQuota to get quota as per scenario, daytime and phase
** 20-10-16   leongwen  ECPD-40220: Modified getUnconstrainedPotential to RETURN NULL only if all fetched columns are NULL. Also, check on Prod or Inj tablename use.
** 24-10-16   kashisag  ECPD-34301: Added new function to find parent for Comparison Code
** 04-11-16   leongwen  ECPD-40220: Modified getUnconstrainedPotential to add the dynamic check with inj_type parameter
** 16-12-16 kashisag,jainnraj ECPD-41773 Added new functions setFcstCompVariables,getGrpFcstVarDataGroup,getGrpFcstVarDataMonth,getGrpFcstVarDataDay,
**                            getGrpFcstPhaseDataGroup,getGrpFcstPhaseDataMonth,getGrpFcstPhaseDataDay,getGrpFcstEventDataGroup,getGrpFcstEventDataMonth,getGrpFcstEventDataDay
**                            for BF Forecast Compare Scenario - Direct (PP.0053)
** 17-01-03   leongwen  ECPD-42319: Modified the dynCursorGetForecastId to correct the scenario id for condition check and removed the invalid forecast_type and period_type which are not available in forecast table.
** 10-02-2017 jainnraj  ECPD-41473: Modified getUnconstrainedPotential to add suport for CO2 Inj and update function headers.
** 27-02-2017 jainnraj  ECPD-40350: Added new functions setFcstAnalysisVariables for BF Forecast Scenarios Analysis (PP.0061).
** 12-05-2017 jainnraj  ECPD-42563: Renamed getProdForecastId and dynCursorGetForecastId to getProdScenarioId and dynCursorGetScenarioId respectively.
** 08-12-2017 kashisag  ECPD-40487: Corrected local variables naming convention.
** 26.07.2018 kashisag  ECPD-56795: Changed objectid to scenario id
** 17.10.2018 abdulmaw  ECPD-58328: updated getGrpFcstVarDataGroup,getGrpFcstVarDataMonth,getGrpFcstVarDataDay,getGrpFcstPhaseDataGroup,getGrpFcstPhaseDataMonth,getGrpFcstPhaseDataDay,
                                    getGrpFcstEventDataGroup,getGrpFcstEventDataMonth,getGrpFcstEventDataDay to solve pipelined implicit type problem
** 17.12.2018 abdulmaw  ECPD-62507: fix naming convention
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFcstTable (LOCAL)
-- Description    : RETURN physical forecast table name based on given object class
---------------------------------------------------------------------------------------------------
FUNCTION getFcstTable(p_class_name VARCHAR2,
						p_object_id	VARCHAR2,
                        p_daytime	DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_fcst_data_tab      VARCHAR2(40);

BEGIN

  IF p_class_name = 'FCTY_CLASS_1' OR p_class_name = 'FCTY_CLASS_2' THEN
    lv2_fcst_data_tab := 'FCST_FCTY_DAY';

  ELSIF p_class_name = 'WELL' THEN
	IF EcDp_Well.isWellInjector(p_object_id, p_daytime)='Y' THEN
		lv2_fcst_data_tab := 'FCST_IWEL_DAY';
	ELSE
		lv2_fcst_data_tab := 'FCST_PWEL_DAY';
	END IF;

  END IF;

  RETURN lv2_fcst_data_tab;

END getFcstTable;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProdScenarioId
-- Description    : Retrieve recent production scenario id based on given object_id and daytime
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
FUNCTION getProdScenarioId(p_object_id        VARCHAR2,
                           p_daytime          DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
  lc_fcst_data         rc_fcst_data;
  lv2_scenario_id      VARCHAR2(32);


BEGIN

   -- get the scenario id
  dynCursorGetScenarioId(lc_fcst_data,p_object_id,p_daytime);
  LOOP
    FETCH lc_fcst_data INTO lv2_scenario_id;
    EXIT WHEN lc_fcst_data%NOTFOUND;

  END LOOP;
  CLOSE lc_fcst_data;

  RETURN lv2_scenario_id;
END getProdScenarioId;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : dynCursorGetScenarioId
-- Description    : RETURN cursor that has the childs of the given object
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration :
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE dynCursorGetScenarioId(p_crs     IN OUT rc_fcst_data,
                                 p_object_id    VARCHAR2,
                                 p_daytime      DATE
                                 )
--</EC-DOC>
IS
  lv2_sql               VARCHAR2(2000);
  lv2_fcst_data_tab     VARCHAR2(100);
  lv2_object_class_name VARCHAR2(100) := ecdp_objects.GetObjClassName(p_object_id);
  lv2_daytime           VARCHAR2(50)  := to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS');
  lv2_prod_fcst_type    VARCHAR2(50);
  lv2_prod_fcst_scen    VARCHAR2(50);

BEGIN
  -- forecast data table and object's version table
   lv2_fcst_data_tab := getFcstTable(lv2_object_class_name,p_object_id, p_daytime);

   --  system default
   lv2_prod_fcst_scen := ecdp_system.getAttributeText(p_daytime,'PROD_FCST_SCENARIO');
   lv2_prod_fcst_type := ecdp_system.getAttributeText(p_daytime,'PROD_FCST_TYPE');

	lv2_sql := 'SELECT OBJECT_ID FROM ( ';
	lv2_sql := lv2_sql || ' SELECT F.OBJECT_ID, I.DAYTIME FROM ';
	lv2_sql := lv2_sql || ' FORECAST F, FORECAST_VERSION FV, ' || lv2_fcst_data_tab || ' I ';
	lv2_sql := lv2_sql || ' WHERE F.OBJECT_ID = FV.OBJECT_ID AND F.OBJECT_ID = I.SCENARIO_ID ';
	lv2_sql := lv2_sql || ' AND I.DAYTIME <= TO_DATE(''' || lv2_daytime || ''',''YYYY-MM-DD"T"HH24:MI:SS'')';
	lv2_sql := lv2_sql || ' AND I.OBJECT_ID = ''' || p_object_id ||'''';
	lv2_sql := lv2_sql || ' AND FV.OFFICIAL_IND = ''Y'' ';
	lv2_sql := lv2_sql || ' ORDER BY I.DAYTIME) ';

  IF lv2_prod_fcst_type IS NOT NULL AND lv2_prod_fcst_scen IS NOT NULL THEN
     OPEN p_crs FOR lv2_sql;
  END IF;
END dynCursorGetScenarioId;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getShortfallOverride
-- Description    : Retrieve shortfall override factor based on the given forecast id, well object_id, daytime and factor
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       : The constants below are used for p_factor.
--                  OIL_S1P, OIL_S1U, OIL_S2, GAS_S1P, GAS_S1U, GAS_S2, COND_S1P, COND_S1U, COND_S2, GL_S1P, GL_S1U, GL_S2, DL_S1P, DL_S1U, DL_S2
--                  WI_S1P, WI_S1U, WI_S2, GI_S1P, GI_S1U, GI_S2, SI_S1P, SI_S1U, SI_S2, CI_S1P, CI_S1U, CI_S2
--
--                  Production Phase: OIL = Oil, GAS = Gas,  COND = Condensate, GL = Gas Lift, DL = Diluent, WI = Water Injection, GI = Gas Injection, SI = Steam Injection and CI = CO2 Injection
--                  S1P = Planned shortfalls, S1U = Unplanned shortfalls, S2 = Non-operational shortfalls
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getShortfallOverride(p_scenario_id   VARCHAR2,
                              p_object_id     VARCHAR2,
                              p_daytime       DATE,
                              p_factor        VARCHAR2
                              )
RETURN NUMBER
--</EC-DOC>
IS
  lv2_tmpSQL            VARCHAR2(1000);
  ln_returnval          NUMBER;
BEGIN

  lv2_tmpSQL := 'SELECT a.' || p_factor || '_FACTOR ' ||
                'FROM FCST_SHORTFALL_OVERRIDES a ' ||
                'WHERE a.OBJECT_ID = :p_object_id ' ||
                'AND a.DAYTIME = (SELECT MAX(b.DAYTIME) FROM FCST_SHORTFALL_OVERRIDES b ' ||
                                 'WHERE b.OBJECT_ID = :p_object_id ' ||
                                 'AND :p_daytime BETWEEN b.DAYTIME and b.VALID_TO) ' ||
                'AND a.SCENARIO_ID = :p_scenario_id';

  IF lv2_tmpSQL IS NOT NULL THEN
    EXECUTE IMMEDIATE lv2_tmpSQL INTO ln_returnval USING p_object_id, p_object_id, p_daytime, p_scenario_id;
  END IF;

  RETURN ln_returnval;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END getShortfallOverride;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getShortfallFactor
-- Description    : Retrieve shortfall factor based on the given well scenario id, object_id, daytime, factor and group_type (default as 'operational')
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       : The constants below are used for p_factor.
--                  OIL_S1P, OIL_S1U, OIL_S2, GAS_S1P, GAS_S1U, GAS_S2, COND_S1P, COND_S1U, COND_S2, GL_S1P, GL_S1U, GL_S2, DL_S1P, DL_S1U, DL_S2
--                  WI_S1P, WI_S1U, WI_S2, GI_S1P, GI_S1U, GI_S2, SI_S1P, SI_S1U, SI_S2, CI_S1P, CI_S1U, CI_S2
--
--                  Production Phase: OIL = Oil, GAS = Gas,  COND = Condensate, GL = Gas Lift, DL = Diluent, WI = Water Injection, GI = Gas Injection, SI = Steam Injection and CI = CO2 Injection
--                  S1P = Planned shortfalls, S1U = Unplanned shortfalls, S2 = Non-operational shortfalls
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getShortfallFactor(p_scenario_id              VARCHAR2,
                            p_object_id                VARCHAR2,
                            p_daytime                  DATE,
                            p_factor                   VARCHAR2,
                            p_group_type               VARCHAR2 DEFAULT 'operational')
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_ImmediateParentID (cp_group_type VARCHAR2, cp_well_object_id VARCHAR2) IS
  SELECT LEVEL, a.parent_object_id
  FROM groups a
  WHERE a.group_type = cp_group_type
  START WITH a.object_id = cp_well_object_id CONNECT BY PRIOR a.parent_object_id = a.object_id
  ORDER BY LEVEL ASC;

  TYPE shortfallFactorTyp       IS REF CURSOR;
  lrc_factor                    shortfallFactorTyp;
  typ_object_id                 t_object_id          := t_object_id();
  typ_factor                    t_factor             := t_factor();
  lv2_object_id                 VARCHAR2(32);
  ln_factor                     NUMBER;
  ln_counter                    NUMBER;
  ln_shortfallOverride          NUMBER;
  ln_shortfallFactor            NUMBER;
  lv2_sql                       VARCHAR2(1000);

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL OR p_scenario_id IS NULL OR p_factor IS NULL OR p_group_type IS NULL THEN
    RETURN NULL;
  END IF;

  ln_counter := 0;
  ln_shortfallOverride := ecbp_forecast_prod.getShortfallOverride(p_scenario_id, p_object_id, p_daytime, p_factor);

  IF ln_shortfallOverride IS NOT NULL THEN
    ln_shortfallFactor := ln_shortfallOverride;
  ELSE
    lv2_sql := 'SELECT a.factor_id, a.' || p_factor || '_FACTOR ' ||
                   'FROM FCST_SHORTFALL_FACTORS a ' ||
                   'WHERE a.DAYTIME = (SELECT MAX(b.daytime) FROM FCST_SHORTFALL_FACTORS b ' ||
                                      'WHERE b.daytime <= to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS')||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')) ' ||
                   'AND a.scenario_id = ''' || p_scenario_id || '''';
    OPEN lrc_factor FOR lv2_sql;
    LOOP
      FETCH lrc_factor INTO lv2_object_id, ln_factor;
      EXIT WHEN lrc_factor%NOTFOUND;
      IF lrc_factor%ROWCOUNT >= 1 THEN
        ln_counter := ln_counter + 1;
        typ_object_id.EXTEND;
        typ_factor.EXTEND;
        typ_object_id(ln_counter) := lv2_object_id;
        typ_factor(ln_counter) := ln_factor;
      END IF;
    END LOOP;
    CLOSE lrc_factor;
  END IF;

  IF typ_object_id.COUNT > 0 THEN
    -- OPEN c_ImmediateParentID and fetch the immediate parent object id of the well object in hierarchical query
    FOR cur_item IN c_ImmediateParentID(p_group_type, p_object_id) LOOP
      FOR i IN typ_object_id.FIRST .. typ_object_id.LAST LOOP
        -- check the well object relation with the forecast group object
        IF cur_item.parent_object_id = typ_object_id(i) THEN
          ln_shortfallFactor := typ_factor(i);
          GOTO exit_loop;
        END IF;
      END LOOP;
    END LOOP;
  END IF;

  <<exit_loop>>
  RETURN ln_shortfallFactor;

END getShortfallFactor;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function		  : getMaxConstraintValue
-- Description    : To get maximum value for each phase as per objects.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_CONSTRAINTS
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getMaxConstraintValue(
                p_object_id VARCHAR2,
				p_daytime DATE,
				p_phase VARCHAR2 )
RETURN NUMBER
IS

ln_max_value    	NUMBER;
ln_check_value    	NUMBER;
lv2_sql             VARCHAR2(4000);

BEGIN

     lv2_sql := ' SELECT GREATEST(NVL('||p_phase||'_RESERVOIR_CONS,0)
	                             ,NVL('||p_phase||'_WELL_CONS,0)
								 ,NVL('||p_phase||'_GATHERING_CONS,0)
								 ,NVL('||p_phase||'_PLANT_CONS,0)
								 ,NVL('||p_phase||'_EXPORT_CONS,0)
								 ,NVL('||p_phase||'_COMMERCIAL_CONS,0)) as max_value,
						 COALESCE('||p_phase||'_RESERVOIR_CONS
	                             ,'||p_phase||'_WELL_CONS
								 ,'||p_phase||'_GATHERING_CONS
								 ,'||p_phase||'_PLANT_CONS
								 ,'||p_phase||'_EXPORT_CONS
								 ,'||p_phase||'_COMMERCIAL_CONS)	as check_value
				  FROM FCST_CONSTRAINTS
				  WHERE SCENARIO_ID = '''||p_object_id||'''
				  AND   DAYTIME = '''||p_daytime||'''  ';

	EXECUTE IMMEDIATE lv2_sql into ln_max_value, ln_check_value;

	IF ln_check_value IS NULL THEN
       RETURN 	ln_check_value ;
	ELSE
       RETURN 	ln_max_value;
	END IF ;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END getMaxConstraintValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function		  : getPhaseUOM
-- Description    : Get UOM for Phase
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : EcDp_ClassMeta_Cnfg.getUomCode
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :RETURN UOM based on phase
--
---------------------------------------------------------------------------------------------------
FUNCTION getPhaseUOM( p_phase VARCHAR2
                       )
RETURN VARCHAR2
IS

lv2_uom       VARCHAR2(32);

BEGIN

   IF p_phase='OIL' THEN

    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'FCST_WELL_EVENT', p_attribute_name =>'OIL_EVENT_LOSS' );

   ELSIF p_phase = 'GAS' THEN

    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'FCST_WELL_EVENT', p_attribute_name =>'GAS_EVENT_LOSS' );

   ELSIF p_phase = 'WAT' THEN

    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'FCST_WELL_EVENT', p_attribute_name =>'WATER_EVENT_LOSS' );

   ELSIF p_phase = 'COND' THEN

    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'FCST_WELL_EVENT', p_attribute_name =>'COND_EVENT_LOSS' );

   ELSIF p_phase = 'GL' THEN

    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'FCST_WELL_EVENT', p_attribute_name =>'GAS_LIFT_EVENT_LOSS' );

   ELSIF p_phase = 'DL' THEN

    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'FCST_WELL_EVENT', p_attribute_name =>'DILUENT_EVENT_LOSS' );

   ELSIF p_phase = 'GI' THEN

    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'FCST_WELL_EVENT', p_attribute_name =>'GAS_INJ_EVENT_LOSS' );

   ELSIF p_phase = 'WI' THEN

    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'FCST_WELL_EVENT', p_attribute_name =>'WATER_INJ_EVENT_LOSS' );

   ELSIF p_phase = 'SI' THEN

    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'FCST_WELL_EVENT', p_attribute_name =>'STEAM_INJ_EVENT_LOSS' );

   ELSIF p_phase = 'CI' THEN

    lv2_uom:= EcDp_ClassMeta_Cnfg.getUomCode(p_class_name => 'FCST_WELL_EVENT', p_attribute_name =>'GAS_INJ_EVENT_LOSS' );

   END IF;

   RETURN lv2_uom;

EXCEPTION
   WHEN OTHERS
   THEN
       RETURN  NULL;

END getPhaseUOM;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function		  : getPhaseUOMLabel
-- Description    : Get UOM Label for selected phase
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : ECDP_UNIT.GetUnitLabel
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :RETURN UOM Label based on phase
--
---------------------------------------------------------------------------------------------------
FUNCTION getPhaseUOMLabel( p_phase VARCHAR2 )
RETURN VARCHAR2
IS

lv2_uom_label    ctrl_unit.label%TYPE;
lv2_uom          VARCHAR2(32);

CURSOR cur_view_unit(cp_uom_meas_type VARCHAR2)
IS
SELECT unit
FROM   ctrl_uom_setup cus
WHERE  cus.measurement_type = cp_uom_meas_type
AND    cus.view_unit_ind = 'Y';

BEGIN

   lv2_uom := EcBp_Forecast_Prod.getPhaseUOM(p_phase);

   FOR c_view_unit IN cur_view_unit(lv2_uom) LOOP
       lv2_uom := c_view_unit.unit;
   END LOOP;

   lv2_uom_label:= ECDP_UNIT.GetUnitLabel(lv2_uom);

   RETURN lv2_uom_label;

EXCEPTION
   WHEN OTHERS
   THEN
       RETURN  NULL;

END getPhaseUOMLabel;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function		  : getConvertVolume
-- Description    : Get converted volumn for selected phase and input volume
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : ECDP_UNIT.ConvertValue
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :RETURN Converted value for volume based on phase and input value
--
---------------------------------------------------------------------------------------------------

FUNCTION getConvertedVolume( p_phase      VARCHAR2,
						   p_phase_vol  NUMBER  )
RETURN NUMBER
IS

lv2_uom          VARCHAR2(32);
lv2_unit_screen  ctrl_uom_setup.unit%TYPE;
lv2_unit_db      ctrl_uom_setup.unit%TYPE;
ln_phase_vol     NUMBER;

CURSOR cur_screen_unit(cp_uom_meas_type VARCHAR2) IS
SELECT unit
FROM   ctrl_uom_setup cus
WHERE  cus.measurement_type = cp_uom_meas_type
AND    cus.view_unit_ind = 'Y';

CURSOR cur_db_unit(cp_uom_meas_type VARCHAR2) IS
SELECT unit
FROM   ctrl_uom_setup cus
WHERE  cus.measurement_type = cp_uom_meas_type
AND    cus.db_unit_ind = 'Y';

BEGIN

   -- get phase uom
   lv2_uom:= EcBp_Forecast_Prod.getPhaseUOM(p_phase) ;

   FOR c_screen_unit IN cur_screen_unit(lv2_uom) LOOP
       lv2_unit_screen := c_screen_unit.unit;
   END LOOP;

   FOR c_db_unit IN cur_db_unit(lv2_uom) LOOP
       lv2_unit_db := c_db_unit.unit;
   END LOOP;

   IF(lv2_unit_screen = lv2_unit_db) THEN
      ln_phase_vol := p_phase_vol;
   ELSE
      ln_phase_vol := ecdp_unit.convertValue(p_phase_vol,lv2_unit_db,lv2_unit_screen,'',2);
   END IF;

RETURN ln_phase_vol;

END getConvertedVolume;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function		  : getUnconstrainedPotential
-- Description    : To get maximum value for each phase as per objects.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_IWEL_POTENTIAL
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getUnconstrainedPotential(
                p_object_id VARCHAR2,
                p_scenario_id VARCHAR2,
                p_daytime DATE,
                p_phase VARCHAR2 )
RETURN NUMBER
IS

ln_sum_value    NUMBER;
lv2_sql         VARCHAR2(4000);
lv2_null_check  VARCHAR2(10);
lv2_filename    VARCHAR2(32) := 'FCST_WELL_POTENTIAL';
lv2_inj_type_chk VARCHAR2(32);

BEGIN
  IF p_phase IN ('GI', 'WI', 'SI','CI') THEN
    lv2_filename := 'FCST_IWEL_POTENTIAL';
    lv2_inj_type_chk := 'AND INJ_TYPE = ' || '''' || p_phase || '''';
  END IF;

  lv2_sql := ' SELECT (NVL('||p_phase||'_BASE,0) +
                      NVL('||p_phase||'_INTERVENTIONS,0) +
                      NVL('||p_phase||'_NEW_WELLS,0) +
                      NVL('||p_phase||'_NEW_PROJECTS,0)) as sum_value,
              (CASE
                WHEN '||p_phase||'_BASE IS NULL AND
                     '||p_phase||'_INTERVENTIONS IS NULL AND
                     '||p_phase||'_NEW_WELLS IS NULL AND
                     '||p_phase||'_NEW_PROJECTS IS NULL THEN
                     '|| ' ' || '''NULL''' || '
                END
              ) as null_check
              FROM '||lv2_filename||'
              WHERE OBJECT_ID = '''||p_object_id||'''
              AND SCENARIO_ID = '''||p_scenario_id||'''
              AND DAYTIME = '''||p_daytime||'''  ' || lv2_inj_type_chk;

  EXECUTE IMMEDIATE lv2_sql into ln_sum_value, lv2_null_check;

  IF lv2_null_check = 'NULL' THEN
    RETURN NULL;
  ELSE
    RETURN  ln_sum_value;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      RETURN NULL;
END getUnconstrainedPotential;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getQuota
-- Description    : Retrieve quota based on the given scenario_id, daytime and phase
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_QUOTA_NOM
--
-- Using functions:
--
-- required       : The constants below are used for p_phase.
--                  OIL, GAS, COND
--                  Production Phase: OIL = Oil, GAS = Gas,  COND = Condensate
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getQuota(p_scenario_id              VARCHAR2,
                  p_daytime                  DATE,
                  p_phase                   VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

  lv2_sql                       VARCHAR2(1000);
  ln_quota                      NUMBER;

BEGIN
  IF p_scenario_id IS NULL OR p_daytime IS NULL OR p_phase IS NULL THEN
    RETURN NULL;
  END IF;

  lv2_sql := 'SELECT a.' || p_phase || '_QUOTA ' ||
             'FROM FCST_QUOTA_NOM a ' ||
             'WHERE a.DAYTIME = (SELECT MAX(b.daytime) FROM FCST_QUOTA_NOM b ' ||
             'WHERE b.daytime <= to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS')||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')) ' ||
             'AND a.scenario_id = ''' || p_scenario_id || '''';

  IF lv2_sql IS NOT NULL THEN
    EXECUTE IMMEDIATE lv2_sql INTO ln_quota;
  END IF;

  RETURN  ln_quota;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END getQuota;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getComparisonParentID
-- Description    : Retrieve parent id for comparison
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : GROUPS
--
-- Using functions:
--
-- required       :
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getComparisonParentID( p_comparison_id varchar2,
                                p_group_type   varchar2,
                                p_object_type  varchar2,
                                p_daytime date )
RETURN VARCHAR2
IS
    lv2_parent_id  varchar2(32);

BEGIN
    SELECT MAX(PARENT_OBJECT_ID) INTO lv2_parent_id
    FROM GROUPS
    WHERE GROUP_TYPE = p_group_type
    AND OBJECT_TYPE  = p_object_type
    AND OBJECT_ID    = p_comparison_id
    AND DAYTIME     <= p_daytime
    AND NVL(end_date, p_daytime+1) > p_daytime;

    RETURN lv2_parent_id;

END getComparisonParentID;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : setFcstCompVariables
-- Description    : This function is used to set the global variables from the values sent from query xml of BF Forecast Compare Scenario - Direct (PP.0053)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       :
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION setFcstCompVariables(p_forecast_id_1 VARCHAR2,p_forecast_id_2 VARCHAR2,p_scenario_id_1 VARCHAR2,p_scenario_id_2 VARCHAR2,p_from_date DATE,p_to_date DATE,p_offset_2 NUMBER) RETURN VARCHAR2
IS
BEGIN
  gd_forecast_id_1 := p_forecast_id_1;
  gd_forecast_id_2 := p_forecast_id_2;
  gd_scenario_id_1 := p_scenario_id_1;
  gd_scenario_id_2 := p_scenario_id_2;
  gd_start_date_1:=  NVL(p_from_date ,ec_forecast.start_date(p_scenario_id_1)) ;
  gd_start_date_2:= GREATEST(ec_forecast.start_date(p_scenario_id_1), ADD_MONTHS(ec_forecast.start_date(p_scenario_id_2),NVL(-(p_offset_2),0)), NVL(p_from_date,ec_forecast.start_date(p_scenario_id_1)));
  gd_end_date_1:=  NVL(p_to_date ,ec_forecast.end_date(p_scenario_id_1)) ;
  gd_end_date_2:= LEAST(ec_forecast.end_date(p_scenario_id_1), ADD_MONTHS(ec_forecast.end_date(p_scenario_id_2),NVL(-(p_offset_2),0)), NVL(p_to_date ,ec_forecast.end_date(p_scenario_id_1)));
  gd_offset_2 := p_offset_2;

  RETURN 1;
END setFcstCompVariables;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrpFcstVarDataGroup
-- Description    : This function will be called from View v_fcst_summ_var_cpr which will be used in first data section of
--                  Details per variable tab in BF Forecast Compare Scenario - Direct (PP.0053)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       :
-- Behaviour      :Production Phase: OIL = Oil, GAS = Gas,  COND = Condensate, GL = Gas Lift, DL = Diluent, WI = Water Injection, GI = Gas Injection, SI = Steam Injection and CI = CO2 Injection
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrpFcstVarDataGroup(p_scenario VARCHAR2)
RETURN t_prodfcst_var_tab PIPELINED
IS

CURSOR c_GrpFcstVarData_1 (cp_forecast_id_1 VARCHAR2, cp_scenario_id_1 VARCHAR2, cp_start_date_1 DATE, cp_end_date_1 DATE) IS
  SELECT FORECAST_ID, SCENARIO_ID, FROM_MONTH, TO_MONTH, VARIABLE_CODE, VARIABLE_NAME, SORT_ORDER, OIL, GAS, WAT, COND, GL, DL, WI, GI, SI, CI
  FROM V_FCST_SUMM_VAR
  WHERE FORECAST_ID = cp_forecast_id_1
  AND SCENARIO_ID = cp_scenario_id_1
  AND FROM_MONTH = cp_start_date_1
  AND TO_MONTH = cp_end_date_1;

CURSOR c_GrpFcstVarData_2 (cp_forecast_id_2 VARCHAR2, cp_scenario_id_2 VARCHAR2, cp_start_date_2 DATE, cp_end_date_2 DATE, cp_offset_2 NUMBER) IS
  SELECT FORECAST_ID, SCENARIO_ID, FROM_MONTH, TO_MONTH, VARIABLE_CODE, VARIABLE_NAME, SORT_ORDER, OIL, GAS, WAT, COND, GL, DL, WI, GI, SI, CI
  FROM V_FCST_SUMM_VAR
  WHERE FORECAST_ID = cp_forecast_id_2
  AND SCENARIO_ID = cp_scenario_id_2
  AND FROM_MONTH = ADD_MONTHS(cp_start_date_2, NVL(cp_offset_2,0))
  AND TO_MONTH = ADD_MONTHS(cp_end_date_2, NVL(cp_offset_2,0));

  out_rec            t_prodfcst_var_rec;
  in_rec             c_GrpFcstVarData_1%ROWTYPE;
  lv2_forecast_id_1  VARCHAR2(32) := NULL;
  lv2_scenario_id_1  VARCHAR2(32) := NULL;
  ld_start_date_1    DATE := NULL;
  ld_end_date_1      DATE := NULL;
  lv2_forecast_id_2  VARCHAR2(32) := NULL;
  lv2_scenario_id_2  VARCHAR2(32) := NULL;
  ld_start_date_2    DATE := NULL;
  ld_end_date_2      DATE := NULL;
  ln_offset_2        NUMBER := NULL;

BEGIN

  lv2_forecast_id_1 :=  gd_forecast_id_1;
  lv2_scenario_id_1 :=  gd_scenario_id_1;
  ld_start_date_1   :=  gd_start_date_1;
  ld_end_date_1     :=  gd_end_date_1;
  lv2_forecast_id_2 :=  gd_forecast_id_2;
  lv2_scenario_id_2 :=  gd_scenario_id_2;
  ld_start_date_2   :=  gd_start_date_2;
  ld_end_date_2     :=  gd_end_date_2;
  ln_offset_2       :=  gd_offset_2;

  IF p_scenario='SCENARIO_1' THEN
  OPEN c_GrpFcstVarData_1(lv2_forecast_id_1, lv2_scenario_id_1, ld_start_date_1, ld_end_date_1);
  LOOP
    FETCH c_GrpFcstVarData_1 INTO in_rec;
    EXIT WHEN c_GrpFcstVarData_1%NOTFOUND;
    out_rec := t_prodfcst_var_rec(in_rec.forecast_id, in_rec.scenario_id, in_rec.from_month, in_rec.to_month, in_rec.variable_code, in_rec.variable_name,
                                  in_rec.sort_order, in_rec.oil, in_rec.gas, in_rec.wat, in_rec.cond, in_rec.gl, in_rec.dl, in_rec.wi, in_rec.gi,
                                  in_rec.si, in_rec.ci);
    PIPE ROW(out_rec);
  END LOOP;
  CLOSE c_GrpFcstVarData_1;
  ELSE
  OPEN c_GrpFcstVarData_2(lv2_forecast_id_2, lv2_scenario_id_2, ld_start_date_2, ld_end_date_2, ln_offset_2);
  LOOP
    FETCH c_GrpFcstVarData_2 INTO in_rec;
    EXIT WHEN c_GrpFcstVarData_2%NOTFOUND;
    out_rec := t_prodfcst_var_rec(in_rec.forecast_id, in_rec.scenario_id, in_rec.from_month, in_rec.to_month, in_rec.variable_code, in_rec.variable_name,
                                  in_rec.sort_order, in_rec.oil, in_rec.gas, in_rec.wat, in_rec.cond, in_rec.gl, in_rec.dl , in_rec.wi, in_rec.gi,
                                  in_rec.si, in_rec.ci);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstVarData_2;
  END IF;
  RETURN;
END getGrpFcstVarDataGroup;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrpFcstVarDataMonth
-- Description    : This function will be called from View v_fcst_summ_var_cpr which will be used in second data section of
--                  Details per variable tab in BF Forecast Compare Scenario - Direct (PP.0053)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       :
-- Behaviour      :Production Phase: OIL = Oil, GAS = Gas,  COND = Condensate, GL = Gas Lift, DL = Diluent, WI = Water Injection, GI = Gas Injection, SI = Steam Injection and CI = CO2 Injection
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrpFcstVarDataMonth(p_scenario VARCHAR2)
RETURN t_prodfcst_var_tab_mth PIPELINED
IS

CURSOR c_GrpFcstVarData_1 (cp_forecast_id_1 VARCHAR2, cp_scenario_id_1 VARCHAR2, cp_start_month_1 DATE, cp_end_month_1 DATE) IS
  SELECT FORECAST_ID, SCENARIO_ID, MONTH, VARIABLE_CODE, VARIABLE_NAME, SORT_ORDER, OIL, GAS, WAT, COND, GL, DL, WI, GI, SI, CI
  FROM V_FCST_SUMM_VAR_MTH
  WHERE FORECAST_ID = cp_forecast_id_1
  AND SCENARIO_ID = cp_scenario_id_1
  AND MONTH BETWEEN TRUNC(cp_start_month_1, 'MONTH') AND TRUNC(cp_end_month_1, 'MONTH');

CURSOR c_GrpFcstVarData_2 (cp_forecast_id_2 VARCHAR2, cp_scenario_id_2 VARCHAR2, cp_start_month_2 DATE, cp_end_month_2 DATE, cp_offset_2 NUMBER) IS
  SELECT FORECAST_ID, SCENARIO_ID, ADD_MONTHS(MONTH, NVL(-cp_offset_2,0)) MONTH, VARIABLE_CODE, VARIABLE_NAME, SORT_ORDER, OIL, GAS, WAT, COND, GL, DL, WI, GI, SI, CI
  FROM V_FCST_SUMM_VAR_MTH
  WHERE FORECAST_ID = cp_forecast_id_2
  AND SCENARIO_ID = cp_scenario_id_2
  AND MONTH BETWEEN (ADD_MONTHS(TRUNC(cp_start_month_2, 'MONTH'), NVL(cp_offset_2,0))) AND (ADD_MONTHS(TRUNC(cp_end_month_2, 'MONTH'), NVL(cp_offset_2,0)));

  out_rec             t_prodfcst_var_rec_mth;
  in_rec              c_GrpFcstVarData_1%ROWTYPE;
  lv2_forecast_id_1   VARCHAR2(32) := NULL;
  lv2_scenario_id_1   VARCHAR2(32) := NULL;
  ld_start_month_1    DATE := NULL;
  ld_end_month_1      DATE := NULL;
  lv2_forecast_id_2   VARCHAR2(32) := NULL;
  lv2_scenario_id_2   VARCHAR2(32) := NULL;
  ld_start_month_2    DATE := NULL;
  ld_end_month_2      DATE := NULL;
  ln_offset_2         NUMBER := NULL;

BEGIN

  lv2_forecast_id_1 :=  gd_forecast_id_1;
  lv2_scenario_id_1 :=  gd_scenario_id_1;
  ld_start_month_1  :=  gd_start_date_1;
  ld_end_month_1    :=  gd_end_date_1;
  lv2_forecast_id_2 :=  gd_forecast_id_2;
  lv2_scenario_id_2 :=  gd_scenario_id_2;
  ld_start_month_2  :=  gd_start_date_2;
  ld_end_month_2    :=  gd_end_date_2;
  ln_offset_2       :=  gd_offset_2;

  IF p_scenario='SCENARIO_1' THEN
  OPEN c_GrpFcstVarData_1(lv2_forecast_id_1, lv2_scenario_id_1, ld_start_month_1, ld_end_month_1);
  LOOP
    FETCH c_GrpFcstVarData_1 INTO in_rec;
    EXIT WHEN c_GrpFcstVarData_1%NOTFOUND;
    out_rec := t_prodfcst_var_rec_mth(in_rec.forecast_id, in_rec.scenario_id, in_rec.month, in_rec.variable_code, in_rec.variable_name, in_rec.sort_order,
                                      in_rec.oil, in_rec.gas, in_rec.wat, in_rec.cond, in_rec.gl, in_rec.dl, in_rec.wi, in_rec.gi , in_rec.si, in_rec.ci);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstVarData_1;
  ELSE
  OPEN c_GrpFcstVarData_2(lv2_forecast_id_2, lv2_scenario_id_2, ld_start_month_2, ld_end_month_2, ln_offset_2);
  LOOP
    FETCH c_GrpFcstVarData_2 INTO in_rec;
    EXIT WHEN c_GrpFcstVarData_2%NOTFOUND;
    out_rec := t_prodfcst_var_rec_mth(in_rec.forecast_id, in_rec.scenario_id, in_rec.month, in_rec.variable_code, in_rec.variable_name, in_rec.sort_order,
                                      in_rec.oil, in_rec.gas, in_rec.wat, in_rec.cond, in_rec.gl, in_rec.dl, in_rec.wi, in_rec.gi, in_rec.si, in_rec.ci);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstVarData_2;
  END IF;
  RETURN;
END getGrpFcstVarDataMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrpFcstVarDataDay
-- Description    : This function will be called from View v_fcst_summ_var_cpr which will be used in third data section of
--                  Details per variable tab in BF Forecast Compare Scenario - Direct (PP.0053)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       :
-- Behaviour      :Production Phase: OIL = Oil, GAS = Gas,  COND = Condensate, GL = Gas Lift, DL = Diluent, WI = Water Injection, GI = Gas Injection, SI = Steam Injection and CI = CO2 Injection
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrpFcstVarDataDay(p_scenario VARCHAR2)
RETURN t_prodfcst_var_tab_mth PIPELINED
IS

CURSOR c_GrpFcstVarData_1 (cp_forecast_id_1 VARCHAR2, cp_scenario_id_1 VARCHAR2, cp_start_month_1 DATE, cp_end_month_1 DATE) IS
  SELECT FORECAST_ID, SCENARIO_ID, DAYTIME, VARIABLE_CODE, VARIABLE_NAME, SORT_ORDER, OIL, GAS, WAT, COND, GL, DL, WI, GI, SI, CI
  FROM V_FCST_SUMM_VAR_DAY
  WHERE FORECAST_ID = cp_forecast_id_1
  AND SCENARIO_ID = cp_scenario_id_1
  AND DAYTIME BETWEEN cp_start_month_1 AND LAST_DAY(cp_end_month_1);

CURSOR c_GrpFcstVarData_2 (cp_forecast_id_2 VARCHAR2, cp_scenario_id_2 VARCHAR2, cp_start_month_2 DATE, cp_end_month_2 DATE, cp_offset_2 NUMBER) IS
  SELECT FORECAST_ID, SCENARIO_ID,
  CASE WHEN EXTRACT(DAY FROM daytime)>EXTRACT(DAY FROM ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)))
       THEN ''
       WHEN EXTRACT(DAY FROM DAYTIME)<EXTRACT(DAY FROM ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)))
       THEN EXTRACT(DAY FROM DAYTIME)||'-'||TO_CHAR(ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)),'MON-YYYY')
       WHEN EXTRACT(DAY FROM DAYTIME)= EXTRACT(DAY FROM ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)))
       THEN TO_CHAR(ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)),'DD-MON-YYYY')
  END DAYTIME,
  VARIABLE_CODE, VARIABLE_NAME, SORT_ORDER, OIL, GAS, WAT, COND, GL, DL, WI, GI, SI, CI
  FROM V_FCST_SUMM_VAR_DAY
  WHERE FORECAST_ID = cp_forecast_id_2
  AND SCENARIO_ID = cp_scenario_id_2
  AND DAYTIME BETWEEN (ADD_MONTHS(cp_start_month_2, NVL(cp_offset_2,0))) AND (ADD_MONTHS(LAST_DAY(cp_end_month_2), NVL(cp_offset_2,0)));

  out_rec           t_prodfcst_var_rec_mth;
  in_rec            c_GrpFcstVarData_1%ROWTYPE;
  lv2_forecast_id_1 VARCHAR2(32) := NULL;
  lv2_scenario_id_1 VARCHAR2(32) := NULL;
  ld_start_month_1  DATE := NULL;
  ld_end_month_1    DATE := NULL;
  lv2_forecast_id_2 VARCHAR2(32) := NULL;
  lv2_scenario_id_2 VARCHAR2(32) := NULL;
  ld_start_month_2  DATE := NULL;
  ld_end_month_2    DATE := NULL;
  ln_offset_2       NUMBER := NULL;

BEGIN

  lv2_forecast_id_1  :=  gd_forecast_id_1;
  lv2_scenario_id_1  :=  gd_scenario_id_1;
  ld_start_month_1   :=  gd_start_date_1;
  ld_end_month_1     :=  gd_end_date_1;
  lv2_forecast_id_2  :=  gd_forecast_id_2;
  lv2_scenario_id_2  :=  gd_scenario_id_2;
  ld_start_month_2   :=  gd_start_date_2;
  ld_end_month_2     :=  gd_end_date_2;
  ln_offset_2        :=  gd_offset_2;

  IF p_scenario='SCENARIO_1' THEN
  OPEN c_GrpFcstVarData_1(lv2_forecast_id_1, lv2_scenario_id_1, ld_start_month_1, ld_end_month_1);
  LOOP
    FETCH c_GrpFcstVarData_1 INTO in_rec;
    EXIT WHEN c_GrpFcstVarData_1%NOTFOUND;
    out_rec := t_prodfcst_var_rec_mth(in_rec.forecast_id, in_rec.scenario_id, in_rec.daytime, in_rec.variable_code, in_rec.variable_name, in_rec.sort_order,
                                      in_rec.oil, in_rec.gas, in_rec.wat, in_rec.cond, in_rec.gl, in_rec.dl, in_rec.wi, in_rec.gi, in_rec.si, in_rec.ci);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstVarData_1;
  ELSE
  OPEN c_GrpFcstVarData_2(lv2_forecast_id_2, lv2_scenario_id_2, ld_start_month_2, ld_end_month_2, ln_offset_2);
  LOOP
    FETCH c_GrpFcstVarData_2 INTO in_rec;
    EXIT WHEN c_GrpFcstVarData_2%NOTFOUND;
    out_rec := t_prodfcst_var_rec_mth(in_rec.forecast_id, in_rec.scenario_id, in_rec.daytime, in_rec.variable_code, in_rec.variable_name, in_rec.sort_order,
                                      in_rec.oil, in_rec.gas, in_rec.wat, in_rec.cond, in_rec.gl, in_rec.dl, in_rec.wi, in_rec.gi, in_rec.si, in_rec.ci);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstVarData_2;
  END IF;
  RETURN;
END getGrpFcstVarDataDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrpFcstPhaseDataGroup
-- Description    : This function will be called from View v_fcst_summ_var_cpr which will be used in first data section of
--                  Details per Phase tab in BF Forecast Compare Scenario - Direct (PP.0053)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       :
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrpFcstPhaseDataGroup(p_scenario VARCHAR2 )
RETURN t_prodfcst_phase_tab PIPELINED
IS

CURSOR c_GrpFcstPhaseData_1 (cp_forecast_id_1 VARCHAR2, cp_scenario_id_1 VARCHAR2, cp_start_date_1 DATE, cp_end_date_1 DATE) IS
  SELECT FORECAST_ID, SCENARIO_ID, FROM_MONTH, TO_MONTH, PHASE_CODE, PHASE_NAME, SORT_ORDER, POT_UNCONSTR , CONSTR  ,POT_CONSTR , S1P_SHORTFALL, S1U_SHORTFALL, S2_SHORTFALL ,INT_CONSUMPT ,LOSSES ,COMPENSATION ,AVAIL_EXPORT ,INJ
  FROM V_FCST_SUMM_PHASE
  WHERE FORECAST_ID = cp_forecast_id_1
  AND SCENARIO_ID = cp_scenario_id_1
  AND FROM_MONTH = cp_start_date_1
  AND TO_MONTH = cp_end_date_1;

CURSOR c_GrpFcstPhaseData_2 (cp_forecast_id_2 VARCHAR2, cp_scenario_id_2 VARCHAR2, cp_start_date_2 DATE, cp_end_date_2 DATE, cp_offset_2 NUMBER) IS
  SELECT FORECAST_ID, SCENARIO_ID, FROM_MONTH, TO_MONTH, PHASE_CODE, PHASE_NAME, SORT_ORDER, POT_UNCONSTR , CONSTR  ,POT_CONSTR , S1P_SHORTFALL, S1U_SHORTFALL, S2_SHORTFALL ,INT_CONSUMPT ,LOSSES ,COMPENSATION ,AVAIL_EXPORT ,INJ
  FROM V_FCST_SUMM_PHASE
  WHERE FORECAST_ID = cp_forecast_id_2
  AND SCENARIO_ID = cp_scenario_id_2
  AND FROM_MONTH = ADD_MONTHS(cp_start_date_2, NVL(cp_offset_2,0))
  AND TO_MONTH = ADD_MONTHS(cp_end_date_2, NVL(cp_offset_2,0));

  out_rec           t_prodfcst_phase_rec;
  in_rec            c_GrpFcstPhaseData_1%ROWTYPE;
  lv2_forecast_id_1 VARCHAR2(32) := NULL;
  lv2_scenario_id_1 VARCHAR2(32) := NULL;
  ld_start_date_1   DATE := NULL;
  ld_end_date_1     DATE := NULL;
  lv2_forecast_id_2 VARCHAR2(32) := NULL;
  lv2_scenario_id_2 VARCHAR2(32) := NULL;
  ld_start_date_2   DATE := NULL;
  ld_end_date_2     DATE := NULL;
  ln_offset_2       NUMBER := NULL;

BEGIN

  lv2_forecast_id_1 :=  gd_forecast_id_1;
  lv2_scenario_id_1 :=  gd_scenario_id_1;
  ld_start_date_1   :=  gd_start_date_1;
  ld_end_date_1     :=  gd_end_date_1;
  lv2_forecast_id_2 :=  gd_forecast_id_2;
  lv2_scenario_id_2 :=  gd_scenario_id_2;
  ld_start_date_2   :=  gd_start_date_2;
  ld_end_date_2     :=  gd_end_date_2;
  ln_offset_2       :=  gd_offset_2;

  IF p_scenario='SCENARIO_1' THEN

  OPEN c_GrpFcstPhaseData_1(lv2_forecast_id_1, lv2_scenario_id_1, ld_start_date_1, ld_end_date_1);
  LOOP
    FETCH c_GrpFcstPhaseData_1 INTO in_rec;
    EXIT WHEN c_GrpFcstPhaseData_1%NOTFOUND;
    out_rec := t_prodfcst_phase_rec(in_rec.forecast_id, in_rec.scenario_id, in_rec.from_month, in_rec.to_month, in_rec.phase_code, in_rec.phase_name,
                                    in_rec.sort_order, in_rec.POT_UNCONSTR, in_rec.CONSTR, in_rec.POT_CONSTR, in_rec.S1P_SHORTFALL, in_rec.S1U_SHORTFALL,
                                    in_rec.S2_SHORTFALL, in_rec.INT_CONSUMPT, in_rec.LOSSES, in_rec.COMPENSATION, in_rec.AVAIL_EXPORT, in_rec.INJ);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstPhaseData_1;
     ELSE
  OPEN c_GrpFcstPhaseData_2(lv2_forecast_id_2, lv2_scenario_id_2, ld_start_date_2, ld_end_date_2, ln_offset_2);
  LOOP
    FETCH c_GrpFcstPhaseData_2 INTO in_rec;
    EXIT WHEN c_GrpFcstPhaseData_2%NOTFOUND;
    out_rec := t_prodfcst_phase_rec(in_rec.forecast_id, in_rec.scenario_id, in_rec.from_month,in_rec.to_month, in_rec.phase_code, in_rec.phase_name,
                                    in_rec.sort_order, in_rec.POT_UNCONSTR, in_rec.CONSTR, in_rec.POT_CONSTR, in_rec.S1P_SHORTFALL, in_rec.S1U_SHORTFALL,
                                    in_rec.S2_SHORTFALL, in_rec.INT_CONSUMPT, in_rec.LOSSES, in_rec.COMPENSATION, in_rec.AVAIL_EXPORT, in_rec.INJ);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstPhaseData_2;
  END IF;
  RETURN;
END getGrpFcstPhaseDataGroup;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrpFcstPhaseDataMonth
-- Description    : This function will be called from View v_fcst_summ_var_cpr which will be used in second data section of
--                  Details per Phase tab in BF Forecast Compare Scenario - Direct (PP.0053)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       :
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrpFcstPhaseDataMonth(p_scenario VARCHAR2 )
RETURN t_prodfcst_phase_tab_mth PIPELINED
IS

CURSOR c_GrpFcstPhaseData_1 (cp_forecast_id_1 VARCHAR2, cp_scenario_id_1 VARCHAR2, cp_start_month_1 DATE, cp_end_month_1 DATE) IS
  SELECT FORECAST_ID, SCENARIO_ID, MONTH,PHASE_CODE, PHASE_NAME, SORT_ORDER, POT_UNCONSTR , CONSTR  ,POT_CONSTR , S1P_SHORTFALL, S1U_SHORTFALL, S2_SHORTFALL ,INT_CONSUMPT ,LOSSES ,COMPENSATION ,AVAIL_EXPORT ,INJ
  FROM V_FCST_SUMM_PHASE_MTH
  WHERE FORECAST_ID = cp_forecast_id_1
  AND SCENARIO_ID = cp_scenario_id_1
  AND MONTH BETWEEN TRUNC(cp_start_month_1, 'MONTH') AND TRUNC(cp_end_month_1, 'MONTH');


CURSOR c_GrpFcstPhaseData_2 (cp_forecast_id_2 VARCHAR2, cp_scenario_id_2 VARCHAR2, cp_start_month_2 DATE, cp_end_month_2 DATE, cp_offset_2 NUMBER) IS
  SELECT FORECAST_ID, SCENARIO_ID, ADD_MONTHS(MONTH, NVL(-cp_offset_2,0)) MONTH, PHASE_CODE, PHASE_NAME, SORT_ORDER, POT_UNCONSTR , CONSTR  ,POT_CONSTR , S1P_SHORTFALL, S1U_SHORTFALL, S2_SHORTFALL ,INT_CONSUMPT ,LOSSES ,COMPENSATION ,AVAIL_EXPORT ,INJ
  FROM V_FCST_SUMM_PHASE_MTH
  WHERE FORECAST_ID = cp_forecast_id_2
  AND SCENARIO_ID = cp_scenario_id_2
  AND MONTH BETWEEN (ADD_MONTHS(TRUNC(cp_start_month_2, 'MONTH'), NVL(cp_offset_2,0))) AND (ADD_MONTHS(TRUNC(cp_end_month_2, 'MONTH'), NVL(cp_offset_2,0)));


  out_rec           t_prodfcst_phase_rec_mth;
  in_rec            c_GrpFcstPhaseData_1%ROWTYPE;
  lv2_forecast_id_1 VARCHAR2(32) := NULL;
  lv2_scenario_id_1 VARCHAR2(32) := NULL;
  ld_start_month_1  DATE := NULL;
  ld_end_month_1    DATE := NULL;
  lv2_forecast_id_2 VARCHAR2(32) := NULL;
  lv2_scenario_id_2 VARCHAR2(32) := NULL;
  ld_start_month_2  DATE := NULL;
  ld_end_month_2    DATE := NULL;
  ln_offset_2       NUMBER := NULL;

BEGIN

  lv2_forecast_id_1 :=  gd_forecast_id_1;
  lv2_scenario_id_1 :=  gd_scenario_id_1;
  ld_start_month_1  :=  gd_start_date_1;
  ld_end_month_1    :=  gd_end_date_1;
  lv2_forecast_id_2 :=  gd_forecast_id_2;
  lv2_scenario_id_2 :=  gd_scenario_id_2;
  ld_start_month_2  :=  gd_start_date_2;
  ld_end_month_2    :=  gd_end_date_2;
  ln_offset_2       :=  gd_offset_2;

  IF p_scenario='SCENARIO_1' THEN

  OPEN c_GrpFcstPhaseData_1(lv2_forecast_id_1, lv2_scenario_id_1, ld_start_month_1, ld_end_month_1);
  LOOP
    FETCH c_GrpFcstPhaseData_1 INTO in_rec;
    EXIT WHEN c_GrpFcstPhaseData_1%NOTFOUND;
    out_rec := t_prodfcst_phase_rec_mth(in_rec.forecast_id, in_rec.scenario_id, in_rec.month, in_rec.phase_code, in_rec.phase_name, in_rec.sort_order,
                                        in_rec.POT_UNCONSTR, in_rec.CONSTR, in_rec.POT_CONSTR, in_rec.S1P_SHORTFALL, in_rec.S1U_SHORTFALL, in_rec.S2_SHORTFALL,
                                        in_rec.INT_CONSUMPT, in_rec.LOSSES, in_rec.COMPENSATION, in_rec.AVAIL_EXPORT, in_rec.INJ);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstPhaseData_1;
     ELSE
   OPEN c_GrpFcstPhaseData_2(lv2_forecast_id_2, lv2_scenario_id_2, ld_start_month_2, ld_end_month_2, ln_offset_2);
  LOOP
    FETCH c_GrpFcstPhaseData_2 INTO in_rec;
    EXIT WHEN c_GrpFcstPhaseData_2%NOTFOUND;
    out_rec := t_prodfcst_phase_rec_mth(in_rec.forecast_id, in_rec.scenario_id, in_rec.month, in_rec.phase_code, in_rec.phase_name, in_rec.sort_order,
                                        in_rec.POT_UNCONSTR, in_rec.CONSTR, in_rec.POT_CONSTR, in_rec.S1P_SHORTFALL, in_rec.S1U_SHORTFALL, in_rec.S2_SHORTFALL,
                                        in_rec.INT_CONSUMPT, in_rec.LOSSES, in_rec.COMPENSATION, in_rec.AVAIL_EXPORT, in_rec.INJ);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstPhaseData_2;
  END IF;
  RETURN;
END getGrpFcstPhaseDataMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrpFcstPhaseDataDay
-- Description    : This function will be called from View v_fcst_summ_var_cpr which will be used in third data section of
--                  Details per Phase tab in BF Forecast Compare Scenario - Direct (PP.0053)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       :
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrpFcstPhaseDataDay(p_scenario VARCHAR2 )
RETURN t_prodfcst_phase_tab_mth PIPELINED
IS

CURSOR c_GrpFcstPhaseData_1 (cp_forecast_id_1 VARCHAR2, cp_scenario_id_1 VARCHAR2, cp_start_month_1 DATE, cp_end_month_1 DATE) IS
  SELECT FORECAST_ID, SCENARIO_ID,DAYTIME,PHASE_CODE, PHASE_NAME, SORT_ORDER, POT_UNCONSTR , CONSTR  ,POT_CONSTR , S1P_SHORTFALL, S1U_SHORTFALL, S2_SHORTFALL ,INT_CONSUMPT ,LOSSES ,COMPENSATION ,AVAIL_EXPORT ,INJ
  FROM V_FCST_SUMM_PHASE_DAY
  WHERE FORECAST_ID = cp_forecast_id_1
  AND SCENARIO_ID = cp_scenario_id_1
  AND DAYTIME BETWEEN cp_start_month_1 AND LAST_DAY(cp_end_month_1);


CURSOR c_GrpFcstPhaseData_2 (cp_forecast_id_2 VARCHAR2, cp_scenario_id_2 VARCHAR2, cp_start_month_2 DATE, cp_end_month_2 DATE, cp_offset_2 NUMBER) IS
  SELECT FORECAST_ID, SCENARIO_ID,
  CASE WHEN EXTRACT(DAY FROM DAYTIME)>EXTRACT(DAY FROM ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)))
       THEN ''
       WHEN EXTRACT(DAY FROM DAYTIME)<EXTRACT(DAY FROM ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)))
       THEN EXTRACT(DAY FROM DAYTIME)||'-'||TO_CHAR(ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)),'MON-YYYY')
       WHEN EXTRACT(DAY FROM DAYTIME)= EXTRACT(DAY FROM ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)))
       THEN TO_CHAR(ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)),'DD-MON-YYYY')
  END DAYTIME, PHASE_CODE, PHASE_NAME, SORT_ORDER, POT_UNCONSTR , CONSTR  ,POT_CONSTR , S1P_SHORTFALL, S1U_SHORTFALL, S2_SHORTFALL ,INT_CONSUMPT ,LOSSES , COMPENSATION ,AVAIL_EXPORT ,INJ
  FROM V_FCST_SUMM_PHASE_DAY
  WHERE FORECAST_ID = cp_forecast_id_2
  AND SCENARIO_ID = cp_scenario_id_2
  AND DAYTIME BETWEEN (ADD_MONTHS(cp_start_month_2, NVL(cp_offset_2,0))) AND (ADD_MONTHS(LAST_DAY(cp_end_month_2), NVL(cp_offset_2,0)));

  out_rec           t_prodfcst_phase_rec_mth;
  in_rec            c_GrpFcstPhaseData_1%ROWTYPE;
  lv2_forecast_id_1 VARCHAR2(32) := NULL;
  lv2_scenario_id_1 VARCHAR2(32) := NULL;
  ld_start_month_1  DATE := NULL;
  ld_end_month_1    DATE := NULL;
  lv2_forecast_id_2 VARCHAR2(32) := NULL;
  lv2_scenario_id_2 VARCHAR2(32) := NULL;
  ld_start_month_2  DATE := NULL;
  ld_end_month_2    DATE := NULL;
  ln_offset_2       NUMBER := NULL;

BEGIN

  lv2_forecast_id_1 :=  gd_forecast_id_1;
  lv2_scenario_id_1 :=  gd_scenario_id_1;
  ld_start_month_1  :=  gd_start_date_1;
  ld_end_month_1    :=  gd_end_date_1;
  lv2_forecast_id_2 :=  gd_forecast_id_2;
  lv2_scenario_id_2 :=  gd_scenario_id_2;
  ld_start_month_2  :=  gd_start_date_2;
  ld_end_month_2    :=  gd_end_date_2;
  ln_offset_2       :=  gd_offset_2;

  IF p_scenario='SCENARIO_1' THEN

  OPEN c_GrpFcstPhaseData_1(lv2_forecast_id_1, lv2_scenario_id_1, ld_start_month_1, ld_end_month_1);
  LOOP
    FETCH c_GrpFcstPhaseData_1 INTO in_rec;
    EXIT WHEN c_GrpFcstPhaseData_1%NOTFOUND;
    out_rec := t_prodfcst_phase_rec_mth(in_rec.forecast_id, in_rec.scenario_id, in_rec.daytime, in_rec.phase_code, in_rec.phase_name, in_rec.sort_order,
                                        in_rec.POT_UNCONSTR, in_rec.CONSTR , in_rec.POT_CONSTR, in_rec.S1P_SHORTFALL, in_rec.S1U_SHORTFALL, in_rec.S2_SHORTFALL,
                                        in_rec.INT_CONSUMPT, in_rec.LOSSES, in_rec.COMPENSATION, in_rec.AVAIL_EXPORT, in_rec.INJ);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstPhaseData_1;
     ELSE
OPEN c_GrpFcstPhaseData_2(lv2_forecast_id_2, lv2_scenario_id_2, ld_start_month_2, ld_end_month_2, ln_offset_2);
  LOOP
    FETCH c_GrpFcstPhaseData_2 INTO in_rec;
    EXIT WHEN c_GrpFcstPhaseData_2%NOTFOUND;
    out_rec := t_prodfcst_phase_rec_mth(in_rec.forecast_id, in_rec.scenario_id, in_rec.daytime, in_rec.phase_code, in_rec.phase_name, in_rec.sort_order,
                                        in_rec.POT_UNCONSTR, in_rec.CONSTR, in_rec.POT_CONSTR, in_rec.S1P_SHORTFALL, in_rec.S1U_SHORTFALL, in_rec.S2_SHORTFALL,
                                        in_rec.INT_CONSUMPT, in_rec.LOSSES, in_rec.COMPENSATION, in_rec.AVAIL_EXPORT, in_rec.INJ);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstPhaseData_2;
  END IF;
  RETURN;
END getGrpFcstPhaseDataDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrpFcstEventDataGroup
-- Description    : This function will be called from View v_fcst_summ_reason_cpr which will be used in first data section of
--                  Events Per category tab in BF Forecast Compare Scenario - Direct (PP.0053)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       :
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrpFcstEventDataGroup(p_scenario VARCHAR2)
RETURN t_prodfcst_event_tab PIPELINED
IS

CURSOR c_GrpFcstEventData_1 (cp_forecast_id_1 VARCHAR2, cp_scenario_id_1 VARCHAR2, cp_start_date_1 DATE, cp_end_date_1 DATE) IS
  SELECT FORECAST_ID , SCENARIO_ID , FROM_MONTH, TO_MONTH , REASON_CODE_1 ,OIL_LOSS_VOLUME  ,GAS_LOSS_VOLUME  ,COND_LOSS_VOLUME  ,WATER_LOSS_VOLUME  ,WATER_INJ_LOSS_VOLUME  ,STEAM_INJ_LOSS_VOLUME  ,GAS_INJ_LOSS_VOLUME  ,DILUENT_LOSS_VOLUME  ,GAS_LIFT_LOSS_VOLUME  ,CO2_INJ_LOSS_VOLUME
  FROM V_FCST_SUMM_REASON
  WHERE FORECAST_ID = cp_forecast_id_1
  AND SCENARIO_ID = cp_scenario_id_1
  AND FROM_MONTH = cp_start_date_1
  AND TO_MONTH = cp_end_date_1;

  CURSOR c_GrpFcstEventData_2 (cp_forecast_id_2 VARCHAR2, cp_scenario_id_2 VARCHAR2, cp_start_date_2 DATE, cp_end_date_2 DATE, cp_offset_2 NUMBER) IS
  SELECT FORECAST_ID , SCENARIO_ID , FROM_MONTH, TO_MONTH , REASON_CODE_1 ,OIL_LOSS_VOLUME  ,GAS_LOSS_VOLUME  ,COND_LOSS_VOLUME  ,WATER_LOSS_VOLUME  ,WATER_INJ_LOSS_VOLUME  ,STEAM_INJ_LOSS_VOLUME  ,GAS_INJ_LOSS_VOLUME  ,DILUENT_LOSS_VOLUME  ,GAS_LIFT_LOSS_VOLUME  ,CO2_INJ_LOSS_VOLUME
  FROM V_FCST_SUMM_REASON
  WHERE FORECAST_ID = cp_forecast_id_2
  AND SCENARIO_ID = cp_scenario_id_2
  AND FROM_MONTH = ADD_MONTHS(cp_start_date_2, NVL(cp_offset_2,0))
  AND TO_MONTH = ADD_MONTHS(cp_end_date_2, NVL(cp_offset_2,0));

  out_rec           t_prodfcst_event_rec;
  in_rec            c_GrpFcstEventData_1%ROWTYPE;
  lv2_forecast_id_1 VARCHAR2(32) := NULL;
  lv2_scenario_id_1 VARCHAR2(32) := NULL;
  ld_start_date_1   DATE := NULL;
  ld_end_date_1     DATE := NULL;
  lv2_forecast_id_2 VARCHAR2(32) := NULL;
  lv2_scenario_id_2 VARCHAR2(32) := NULL;
  ld_start_date_2   DATE := NULL;
  ld_end_date_2     DATE := NULL;
  ln_offset_2       NUMBER := NULL;

BEGIN

  lv2_forecast_id_1   :=  gd_forecast_id_1;
  lv2_scenario_id_1   :=  gd_scenario_id_1;
  ld_start_date_1     :=  gd_start_date_1;
  ld_end_date_1       :=  gd_end_date_1;
  lv2_forecast_id_2   :=  gd_forecast_id_2;
  lv2_scenario_id_2   :=  gd_scenario_id_2;
  ld_start_date_2     :=  gd_start_date_2;
  ld_end_date_2       :=  gd_end_date_2;
  ln_offset_2         :=  gd_offset_2;

  IF p_scenario='SCENARIO_1' THEN
  OPEN c_GrpFcstEventData_1(lv2_forecast_id_1, lv2_scenario_id_1, ld_start_date_1, ld_end_date_1);
  LOOP
    FETCH c_GrpFcstEventData_1 INTO in_rec;
    EXIT WHEN c_GrpFcstEventData_1%NOTFOUND;
    out_rec := t_prodfcst_event_rec(in_rec.FORECAST_ID, in_rec.SCENARIO_ID, in_rec.FROM_MONTH, in_rec.TO_MONTH, in_rec.REASON_CODE_1, in_rec.OIL_LOSS_VOLUME,
                                    in_rec.GAS_LOSS_VOLUME, in_rec.COND_LOSS_VOLUME, in_rec.WATER_LOSS_VOLUME, in_rec.WATER_INJ_LOSS_VOLUME, in_rec.STEAM_INJ_LOSS_VOLUME,
                                    in_rec.GAS_INJ_LOSS_VOLUME, in_rec.DILUENT_LOSS_VOLUME, in_rec.GAS_LIFT_LOSS_VOLUME, in_rec.CO2_INJ_LOSS_VOLUME);

    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstEventData_1;
  ELSE
  OPEN c_GrpFcstEventData_2(lv2_forecast_id_2, lv2_scenario_id_2, ld_start_date_2, ld_end_date_2, ln_offset_2);
  LOOP
    FETCH c_GrpFcstEventData_2 INTO in_rec;
    EXIT WHEN c_GrpFcstEventData_2%NOTFOUND;
    out_rec := t_prodfcst_event_rec(in_rec.FORECAST_ID, in_rec.SCENARIO_ID, in_rec.FROM_MONTH, in_rec.TO_MONTH, in_rec.REASON_CODE_1, in_rec.OIL_LOSS_VOLUME,
                                    in_rec.GAS_LOSS_VOLUME, in_rec.COND_LOSS_VOLUME, in_rec.WATER_LOSS_VOLUME, in_rec.WATER_INJ_LOSS_VOLUME, in_rec.STEAM_INJ_LOSS_VOLUME,
                                    in_rec.GAS_INJ_LOSS_VOLUME, in_rec.DILUENT_LOSS_VOLUME, in_rec.GAS_LIFT_LOSS_VOLUME, in_rec.CO2_INJ_LOSS_VOLUME);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstEventData_2;
  END IF;
  RETURN;
END getGrpFcstEventDataGroup;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrpFcstEventDataMonth
-- Description    : This function will be called from View v_fcst_summ_reason_mth_cpr which will be used in second data section of
--                  Events Per category tab in BF Forecast Compare Scenario - Direct (PP.0053)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       :
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrpFcstEventDataMonth(p_scenario VARCHAR2)
RETURN t_prodfcst_event_tab_mth PIPELINED
IS

CURSOR c_GrpFcstEventData_1 (cp_forecast_id_1 VARCHAR2, cp_scenario_id_1 VARCHAR2, cp_start_month_1 DATE, cp_end_month_1 DATE) IS
  SELECT FORECAST_ID , SCENARIO_ID , MONTH , REASON_CODE_1 ,OIL_LOSS_VOLUME  ,GAS_LOSS_VOLUME  ,COND_LOSS_VOLUME  ,WATER_LOSS_VOLUME  ,WATER_INJ_LOSS_VOLUME  ,STEAM_INJ_LOSS_VOLUME  ,GAS_INJ_LOSS_VOLUME  ,DILUENT_LOSS_VOLUME  ,GAS_LIFT_LOSS_VOLUME  ,CO2_INJ_LOSS_VOLUME
  FROM V_FCST_SUMM_REASON_MTH
  WHERE FORECAST_ID = cp_forecast_id_1
  AND SCENARIO_ID = cp_scenario_id_1
  AND MONTH BETWEEN TRUNC(cp_start_month_1, 'MONTH') AND TRUNC(cp_end_month_1, 'MONTH');

CURSOR c_GrpFcstEventData_2 (cp_forecast_id_2 VARCHAR2, cp_scenario_id_2 VARCHAR2, cp_start_month_2 DATE, cp_end_month_2 DATE, cp_offset_2 NUMBER) IS
  SELECT FORECAST_ID , SCENARIO_ID , ADD_MONTHS(MONTH, NVL(-cp_offset_2,0)) MONTH, REASON_CODE_1 ,OIL_LOSS_VOLUME  ,GAS_LOSS_VOLUME  ,COND_LOSS_VOLUME  ,WATER_LOSS_VOLUME  ,WATER_INJ_LOSS_VOLUME  ,STEAM_INJ_LOSS_VOLUME  ,GAS_INJ_LOSS_VOLUME  ,DILUENT_LOSS_VOLUME  ,GAS_LIFT_LOSS_VOLUME  ,CO2_INJ_LOSS_VOLUME
  FROM V_FCST_SUMM_REASON_MTH
  WHERE FORECAST_ID = cp_forecast_id_2
  AND SCENARIO_ID = cp_scenario_id_2
  AND MONTH BETWEEN (ADD_MONTHS(TRUNC(cp_start_month_2, 'MONTH'), NVL(cp_offset_2,0))) AND (ADD_MONTHS(TRUNC(cp_end_month_2, 'MONTH'), NVL(cp_offset_2,0)));


  out_rec           t_prodfcst_event_rec_mth;
  in_rec            c_GrpFcstEventData_1%ROWTYPE;
  lv2_forecast_id_1 VARCHAR2(32) := NULL;
  lv2_scenario_id_1 VARCHAR2(32) := NULL;
  ld_start_month_1  DATE := NULL;
  ld_end_month_1    DATE := NULL;
  lv2_forecast_id_2 VARCHAR2(32) := NULL;
  lv2_scenario_id_2 VARCHAR2(32) := NULL;
  ld_start_month_2  DATE := NULL;
  ld_end_month_2    DATE := NULL;
  ln_offset_2       NUMBER := NULL;

BEGIN

  lv2_forecast_id_1  :=  gd_forecast_id_1;
  lv2_scenario_id_1  :=  gd_scenario_id_1;
  ld_start_month_1   :=  gd_start_date_1;
  ld_end_month_1     :=  gd_end_date_1;
  lv2_forecast_id_2  :=  gd_forecast_id_2;
  lv2_scenario_id_2  :=  gd_scenario_id_2;
  ld_start_month_2   :=  gd_start_date_2;
  ld_end_month_2     :=  gd_end_date_2;
  ln_offset_2        :=  gd_offset_2;

  IF p_scenario='SCENARIO_1' THEN
  OPEN c_GrpFcstEventData_1(lv2_forecast_id_1, lv2_scenario_id_1, ld_start_month_1, ld_end_month_1);
  LOOP
    FETCH c_GrpFcstEventData_1 INTO in_rec;
    EXIT WHEN c_GrpFcstEventData_1%NOTFOUND;
    out_rec := t_prodfcst_event_rec_mth(in_rec.FORECAST_ID, in_rec.SCENARIO_ID, in_rec.MONTH, in_rec.REASON_CODE_1, in_rec.OIL_LOSS_VOLUME, in_rec.GAS_LOSS_VOLUME,
                                        in_rec.COND_LOSS_VOLUME, in_rec.WATER_LOSS_VOLUME, in_rec.WATER_INJ_LOSS_VOLUME,in_rec.STEAM_INJ_LOSS_VOLUME,
                                        in_rec.GAS_INJ_LOSS_VOLUME, in_rec.DILUENT_LOSS_VOLUME, in_rec.GAS_LIFT_LOSS_VOLUME, in_rec.CO2_INJ_LOSS_VOLUME);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstEventData_1;
  ELSE
   OPEN c_GrpFcstEventData_2(lv2_forecast_id_2, lv2_scenario_id_2, ld_start_month_2, ld_end_month_2, ln_offset_2);
  LOOP
    FETCH c_GrpFcstEventData_2 INTO in_rec;
    EXIT WHEN c_GrpFcstEventData_2%NOTFOUND;
    out_rec := t_prodfcst_event_rec_mth(in_rec.FORECAST_ID, in_rec.SCENARIO_ID, in_rec.MONTH, in_rec.REASON_CODE_1, in_rec.OIL_LOSS_VOLUME, in_rec.GAS_LOSS_VOLUME,
                                        in_rec.COND_LOSS_VOLUME, in_rec.WATER_LOSS_VOLUME, in_rec.WATER_INJ_LOSS_VOLUME, in_rec.STEAM_INJ_LOSS_VOLUME,
                                        in_rec.GAS_INJ_LOSS_VOLUME, in_rec.DILUENT_LOSS_VOLUME, in_rec.GAS_LIFT_LOSS_VOLUME, in_rec.CO2_INJ_LOSS_VOLUME );
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstEventData_2;
  END IF;
  RETURN;
END getGrpFcstEventDataMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrpFcstEventDataDay
-- Description    : This function will be called from View v_fcst_summ_reason_day_cpr which will be used in third data section of
--                  Events Per category tab in BF Forecast Compare Scenario - Direct (PP.0053)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       :
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGrpFcstEventDataDay(p_scenario VARCHAR2)
RETURN t_prodfcst_event_tab_mth PIPELINED
IS

CURSOR c_GrpFcstEventData_1 (cp_forecast_id_1 VARCHAR2, cp_scenario_id_1 VARCHAR2, cp_start_month_1 DATE, cp_end_month_1 DATE) IS
  SELECT FORECAST_ID , SCENARIO_ID , DAYTIME , REASON_CODE_1 ,OIL_LOSS_VOLUME  ,GAS_LOSS_VOLUME  ,COND_LOSS_VOLUME  ,WATER_LOSS_VOLUME  ,WATER_INJ_LOSS_VOLUME  ,STEAM_INJ_LOSS_VOLUME  ,GAS_INJ_LOSS_VOLUME  ,DILUENT_LOSS_VOLUME  ,GAS_LIFT_LOSS_VOLUME  ,CO2_INJ_LOSS_VOLUME
  FROM V_FCST_SUMM_REASON_DAY
  WHERE FORECAST_ID = cp_forecast_id_1
  AND SCENARIO_ID = cp_scenario_id_1
  AND DAYTIME BETWEEN cp_start_month_1 AND LAST_DAY(cp_end_month_1);

CURSOR c_GrpFcstEventData_2 (cp_forecast_id_2 VARCHAR2, cp_scenario_id_2 VARCHAR2, cp_start_month_2 DATE, cp_end_month_2 DATE, cp_offset_2 NUMBER) IS
 SELECT FORECAST_ID , SCENARIO_ID
 ,CASE WHEN EXTRACT(DAY FROM daytime)>EXTRACT(DAY FROM ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)))
       THEN ''
       WHEN EXTRACT(DAY FROM daytime)<EXTRACT(DAY FROM ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)))
       THEN EXTRACT(DAY FROM daytime)||'-'||TO_CHAR(ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)),'MON-YYYY')
       WHEN EXTRACT(DAY FROM daytime)= EXTRACT(DAY FROM ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)))
       THEN TO_CHAR(ADD_MONTHS(DAYTIME,NVL(-cp_offset_2,0)),'DD-MON-YYYY')
  END DAYTIME,
 REASON_CODE_1 ,OIL_LOSS_VOLUME  ,GAS_LOSS_VOLUME  ,COND_LOSS_VOLUME  ,WATER_LOSS_VOLUME  ,WATER_INJ_LOSS_VOLUME  ,STEAM_INJ_LOSS_VOLUME  ,GAS_INJ_LOSS_VOLUME  ,DILUENT_LOSS_VOLUME  ,GAS_LIFT_LOSS_VOLUME  ,CO2_INJ_LOSS_VOLUME
  FROM V_FCST_SUMM_REASON_DAY
  WHERE FORECAST_ID = cp_forecast_id_2
  AND SCENARIO_ID = cp_scenario_id_2
  AND DAYTIME BETWEEN (ADD_MONTHS(cp_start_month_2, NVL(cp_offset_2,0))) AND (ADD_MONTHS(LAST_DAY(cp_end_month_2), NVL(cp_offset_2,0)));

  out_rec         t_prodfcst_event_rec_mth;
  in_rec          c_GrpFcstEventData_1%ROWTYPE;
  lv2_forecast_id_1 VARCHAR2(32) := NULL;
  lv2_scenario_id_1 VARCHAR2(32) := NULL;
  ld_start_month_1  DATE := NULL;
  ld_end_month_1    DATE := NULL;
  lv2_forecast_id_2 VARCHAR2(32) := NULL;
  lv2_scenario_id_2 VARCHAR2(32) := NULL;
  ld_start_month_2  DATE := NULL;
  ld_end_month_2    DATE := NULL;
  ln_offset_2       NUMBER := NULL;

BEGIN

  lv2_forecast_id_1 :=  gd_forecast_id_1;
  lv2_scenario_id_1 :=  gd_scenario_id_1;
  ld_start_month_1  :=  gd_start_date_1;
  ld_end_month_1    :=  gd_end_date_1;
  lv2_forecast_id_2 :=  gd_forecast_id_2;
  lv2_scenario_id_2 :=  gd_scenario_id_2;
  ld_start_month_2  :=  gd_start_date_2;
  ld_end_month_2    :=  gd_end_date_2;
  ln_offset_2       :=  gd_offset_2;

  IF p_scenario='SCENARIO_1' THEN
   OPEN c_GrpFcstEventData_1(lv2_forecast_id_1, lv2_scenario_id_1, ld_start_month_1, ld_end_month_1);
  LOOP
    FETCH c_GrpFcstEventData_1 INTO in_rec;
    EXIT WHEN c_GrpFcstEventData_1%NOTFOUND;
    out_rec := t_prodfcst_event_rec_mth(in_rec.FORECAST_ID, in_rec.SCENARIO_ID, in_rec.DAYTIME, in_rec.REASON_CODE_1, in_rec.OIL_LOSS_VOLUME, in_rec.GAS_LOSS_VOLUME,
                                    in_rec.COND_LOSS_VOLUME, in_rec.WATER_LOSS_VOLUME, in_rec.WATER_INJ_LOSS_VOLUME, in_rec.STEAM_INJ_LOSS_VOLUME,
                                    in_rec.GAS_INJ_LOSS_VOLUME, in_rec.DILUENT_LOSS_VOLUME, in_rec.GAS_LIFT_LOSS_VOLUME, in_rec.CO2_INJ_LOSS_VOLUME);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstEventData_1;
  ELSE
  OPEN c_GrpFcstEventData_2(lv2_forecast_id_2, lv2_scenario_id_2, ld_start_month_2, ld_end_month_2, ln_offset_2);
  LOOP
    FETCH c_GrpFcstEventData_2 INTO in_rec;
    EXIT WHEN c_GrpFcstEventData_2%NOTFOUND;
    out_rec := t_prodfcst_event_rec_mth(in_rec.FORECAST_ID, in_rec.SCENARIO_ID, in_rec.DAYTIME, in_rec.REASON_CODE_1, in_rec.OIL_LOSS_VOLUME, in_rec.GAS_LOSS_VOLUME,
                                    in_rec.COND_LOSS_VOLUME, in_rec.WATER_LOSS_VOLUME, in_rec.WATER_INJ_LOSS_VOLUME, in_rec.STEAM_INJ_LOSS_VOLUME,
                                    in_rec.GAS_INJ_LOSS_VOLUME, in_rec.DILUENT_LOSS_VOLUME, in_rec.GAS_LIFT_LOSS_VOLUME, in_rec.CO2_INJ_LOSS_VOLUME);
    PIPE ROW(out_rec);

  END LOOP;
  CLOSE c_GrpFcstEventData_2;
  END IF;
  RETURN;
END getGrpFcstEventDataDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : setFcstAnalysisVariables
-- Description    : This function is used to set the global variables from the values sent from query xml of BF Forecast Scenarios Analysis (PP.0061)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- required       :
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION setFcstAnalysisVariables(p_comparison_code VARCHAR2) RETURN VARCHAR2
IS
  lv2_forecast_id_1 VARCHAR2(32);
  lv2_forecast_id_2 VARCHAR2(32);
  lv2_scenario_id_1 VARCHAR2(32);
  lv2_scenario_id_2 VARCHAR2(32);
  ld_from_date DATE;
  ld_to_date DATE;
  ln_offset_2 NUMBER;
BEGIN
   SELECT FORECAST1_ID,FORECAST2_ID,SCENARIO1_ID,SCENARIO2_ID,FROM_MONTH,TO_MONTH,SCENARIO2_OFFSET
   INTO lv2_forecast_id_1,lv2_forecast_id_2,lv2_scenario_id_1,lv2_scenario_id_2,ld_from_date,ld_to_date,ln_offset_2
   FROM FCST_COMPARISON_VERSION
   WHERE  OBJECT_ID = p_comparison_code;

  gd_forecast_id_1 := lv2_forecast_id_1;
  gd_forecast_id_2 := lv2_forecast_id_2;
  gd_scenario_id_1 := lv2_scenario_id_1;
  gd_scenario_id_2 := lv2_scenario_id_2;
  gd_start_date_1:=  NVL(ld_from_date ,ec_forecast.start_date(lv2_scenario_id_1)) ;
  gd_start_date_2:= GREATEST(ec_forecast.start_date(lv2_scenario_id_1), ADD_MONTHS(ec_forecast.start_date(lv2_scenario_id_2),NVL(-(ln_offset_2),0)), NVL(ld_from_date,ec_forecast.start_date(lv2_scenario_id_1)));
  gd_end_date_1:=  NVL(ld_to_date ,ec_forecast.end_date(lv2_scenario_id_1)) ;
  gd_end_date_2:= LEAST(ec_forecast.end_date(lv2_scenario_id_1), ADD_MONTHS(ec_forecast.end_date(lv2_scenario_id_2),NVL(-(ln_offset_2),0)), NVL(ld_to_date ,ec_forecast.end_date(lv2_scenario_id_1)));
  gd_offset_2 := ln_offset_2;

  RETURN 1;
END setFcstAnalysisVariables;

END EcBp_Forecast_Prod;