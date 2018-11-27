CREATE OR REPLACE PACKAGE BODY EcDp_Calculation IS
/****************************************************************
** Package        :  EcDp_Calculation, body part
**
** $Revision: 1.23.4.2 $
**
** Purpose        :  Support functions for the calculation editor and framework.
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.11.2008  Bent Ivar Helland
**
** Modification history:
**
** Date        Who  Change description:
** ----------  ---- --------------------------------------
** 2008-11-21  BIH  Initial version
** 2010-04-27  ON   Added update end date for old version in copyCalcVersionCascading
** 2012-11-11  genasdev  Modify gelLogProfileName function to support calculation with 2 or more version
*****************************************************************/

-- Declaration of Private functions and procedures

PROCEDURE createDefaultFlowchart(p_calculation_id VARCHAR2, p_start_date DATE, p_end_date DATE);
PROCEDURE copyCalcVersionCascading(p_object_id VARCHAR2, p_daytime DATE, p_new_start_date DATE, p_new_end_date DATE, p_new_object_id VARCHAR2, p_calc_context_id_ovrd VARCHAR2, p_code_ovrd VARCHAR2, p_name_ovrd VARCHAR2, p_update_flag VARCHAR2);



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : implementProcessElement
-- Description    : Creates a new CALCULATION as a child calculation to an existing calculation process element.
--
-- Preconditions  :
-- Postconditions : The new calculation ID must be assigned as the child calculation for the
--                  process element after this procedure has finished.
--
-- Using tables   : calculation
-- Using functions: createCalculation, copyCalcVersionCascading
--
-- Configuration
-- required       :
--
-- Behaviour      : Creates a new CALCULATION as a child calculation to an existing calculation process element.
--                  The new calculation will have the same start/end dates as the element,
--                  and the same context and scope as the parent calculation.
--                  If p_copy_of_calc_id is not null then the new calculation will be a copy of that calculation.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE implementProcessElement(p_label VARCHAR2, p_start_date DATE, p_end_date DATE, p_calculation_id VARCHAR2, p_new_calc_id VARCHAR2, p_new_calc_type VARCHAR2, p_copy_of_calc_id VARCHAR2, p_copy_of_calc_daytime DATE)
--</EC-DOC>
IS
   lv_calc_context_id VARCHAR2(32);
   lv_calc_period VARCHAR2(32);
BEGIN
   -- Look up context and period from the parent calculation
   select calc_context_id, calc_period
   into lv_calc_context_id, lv_calc_period
   from calculation
   where object_id = p_calculation_id;

   -- Create the new calculation
   IF p_copy_of_calc_id IS NULL THEN
      createCalculation(p_new_calc_id, p_new_calc_id, p_label, p_start_date, p_end_date, lv_calc_context_id, lv_calc_period, p_new_calc_type, 'PRIVATE_SUB', 'Y');
   ELSE
      -- NOTYET: Only create an actual copy if it is PRIVATE_SUB, otherwise we just link to the existing instead!
      copyCalcVersionCascading(p_copy_of_calc_id, p_copy_of_calc_daytime, p_start_date, p_end_date, p_new_calc_id, lv_calc_context_id, NULL, p_label, NULL);
   END IF;
END implementProcessElement;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : createCalculation
-- Description    : Creates a new CALCULATION object.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calculation, calculation_version
-- Using functions: createDefaultFlowchart
--
-- Configuration
-- required       :
--
-- Behaviour      : Creates a new CALCULATION object.
--                  If the 'create_default_impl' flag is set to Y then a default
--                  implementation is created. This varies with the type of calculation:
--                  * PROCESS calculations get a default flow chart with a start element,
--                    a stop element and one step element.
--                  * WORKBOOK calculations get a default workbook from LOB_TEMPLATE
--                  * EQUATIONS calculations don't get a default implementation
--
-----------------------------------------------------------------------------------------------------
PROCEDURE createCalculation(p_object_id VARCHAR2, p_code VARCHAR2, p_name VARCHAR2, p_start_date DATE, p_end_date DATE, p_calc_context_id VARCHAR2, p_calc_period VARCHAR2, p_calc_type VARCHAR2, p_calc_scope VARCHAR2, p_create_default_impl VARCHAR2)
IS
   lv2_user_id VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
BEGIN
   insert into calculation(object_id, object_code, start_date, end_date, calc_context_id, calc_period, calc_type, calc_scope, created_by)
   values(p_object_id, p_code, p_start_date, p_end_date, p_calc_context_id, p_calc_period, p_calc_type, p_calc_scope, lv2_user_id);
   insert into calculation_version(object_id, name, daytime, end_date, created_by)
   values(p_object_id, p_name, p_start_date, p_end_date, lv2_user_id);

   IF p_create_default_impl = 'Y' THEN
     IF p_calc_type = 'PROCESS' THEN
        createDefaultFlowchart(p_object_id, p_start_date, p_end_date);
     END IF;
     IF p_calc_type = 'WORKBOOK' THEN
        -- Workbooks always get their default implementation (set by table IU trigger)
        NULL;
     END IF;
   END IF;
END createCalculation;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : createCalculationAsCopy
-- Description    : Creates a new CALCULATION object as a copy of an existing object version.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: copyCalcVersionCascading
--
-- Configuration
-- required       :
--
-- Behaviour      : Creates a new CALCULATION object as a copy of a single version of
--                  another CALCULATION object.
--                  Performs a "deep" copy, so that the entire calculation is copied including
--                  equations, flowcharts, sets and variables.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE createCalculationAsCopy(p_copy_of_object_id VARCHAR2, p_copy_of_daytime DATE, p_new_code VARCHAR2, p_new_name VARCHAR2, p_new_start_date DATE, p_new_end_date DATE)
--</EC-DOC>
IS
BEGIN
   copyCalcVersionCascading(p_copy_of_object_id, p_copy_of_daytime, p_new_start_date, p_new_end_date, NULL, NULL, p_new_code, p_new_name,NULL);
END createCalculationAsCopy;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : addCalculationVersion
-- Description    : Creates a new version on an existing CALCULATION object.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: copyCalcVersionCascading
--
-- Configuration
-- required       :
--
-- Behaviour      : The new version will be a copy of the latest version prior to the valid from
--                  date of the new version.
--                  Performs a "deep" copy, so that the entire calculation is copied including
--                  equations, flowcharts, sets and variables.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE addCalculationVersion(p_object_id VARCHAR2, p_new_daytime DATE)
--</EC-DOC>
IS
   ld_prev_version_daytime   DATE;
   ld_next_version_daytime   DATE;
   ld_end_date               DATE;
BEGIN
   ld_prev_version_daytime := ec_calculation_version.prev_daytime(p_object_id, p_new_daytime);
   ld_next_version_daytime := ec_calculation_version.next_daytime(p_object_id, p_new_daytime);
   ld_end_date := NVL(ld_next_version_daytime, ec_calculation_version.end_date(p_object_id, ld_prev_version_daytime));
   copyCalcVersionCascading(p_object_id, ld_prev_version_daytime, p_new_daytime, ld_end_date, p_object_id, NULL, NULL, NULL,'Y');
END addCalculationVersion;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : createDefaultImplOnInsert
-- Description    : Creates a default implementation for a given CALCULATION object on insert.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: Ecdp_Objects.GetObjIDFromCode, createDefaultFlowchart
--
-- Configuration
-- required       :
--
-- Behaviour      : A default implementation is created only if p_operation = 'create' (used to detect inserts).
--                  The default implementation varies with the type of calculation:
--                  * PROCESS calculations get a default flow chart with a start element,
--                    a stop element and one step element.
--                  * WORKBOOK calculations get a default workbook from LOB_TEMPLATE
--                  * EQUATIONS calculations don't get a default implementation
--
-----------------------------------------------------------------------------------------------------
PROCEDURE createDefaultImplOnInsert(p_operation VARCHAR2, p_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_calc_type VARCHAR2)
--</EC-DOC>
IS
BEGIN
  IF NVL(p_operation,'unchanged')<>'create' THEN
     -- Not insert - so don't do anything!
     RETURN;
  END IF;
  IF p_calc_type = 'PROCESS' THEN
     createDefaultFlowchart(Ecdp_Objects.GetObjIDFromCode('CALCULATION',p_code), p_start_date, p_end_date);
  ELSIF p_calc_type = 'WORKBOOK' THEN
     -- Workbooks always get their default implementation (set by table IU trigger)
     NULL;
  ELSIF p_calc_type = 'EQUATIONS' THEN
     -- Equations don't have a default implementation
     NULL;
  END IF;
END createDefaultImplOnInsert;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : createDefaultFlowchart (private)
-- Description    : Creates a default flowchart for a calculation.
-- Preconditions  : The calculation object must already exist.
-- Postconditions :
--
-- Using tables   : calc_process_element, calc_process_elm_version,
--                  calc_process_transition, calc_proc_tran_version
-- Using functions: SYS_GUID
--
-- Configuration
-- required       :
--
-- Behaviour      : Creates a default flowchart for a calculation.
--                  A default flowchart consists of a start element, an end element and one step element.
--                  In addition it creates transitions between these elements.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE createDefaultFlowchart(p_calculation_id VARCHAR2, p_start_date DATE, p_end_date DATE)
--</EC-DOC>
IS
   lv_start_elm_id    VARCHAR2(32);
   lv_step_elm_id     VARCHAR2(32);
   lv_stop_elm_id     VARCHAR2(32);
   lv_start_step_id   VARCHAR2(32);
   lv_step_stop_id    VARCHAR2(32);
   lv2_user_id        VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
BEGIN
   -- Create START element
   lv_start_elm_id := SYS_GUID();
   insert into calc_process_element(object_id,object_code,start_date,end_date,calculation_id,created_by)
   values(lv_start_elm_id, lv_start_elm_id, p_start_date, p_end_date, p_calculation_id, lv2_user_id);
   insert into calc_process_elm_version(object_id,name,daytime,end_date,calc_proc_elm_type,diagram_layout_info,created_by)
   values(lv_start_elm_id, 'Start', p_start_date, p_end_date, 'START', 'bounds={x=0;y=20;w=100;h=60;}|', lv2_user_id);

   -- Create STEP element
   lv_step_elm_id := SYS_GUID();
   insert into calc_process_element(object_id,object_code,start_date,end_date,calculation_id,created_by)
   values(lv_step_elm_id, lv_step_elm_id, p_start_date, p_end_date, p_calculation_id, lv2_user_id);
   insert into calc_process_elm_version(object_id,name,daytime,end_date,calc_proc_elm_type,diagram_layout_info,created_by)
   values(lv_step_elm_id, 'Step 1', p_start_date, p_end_date, 'STEP', 'bounds={x=160;y=0;w=100;h=100;}|', lv2_user_id);

   -- Create STOP element
   lv_stop_elm_id := SYS_GUID();
   insert into calc_process_element(object_id,object_code,start_date,end_date,calculation_id,created_by)
   values(lv_stop_elm_id, lv_stop_elm_id, p_start_date, p_end_date, p_calculation_id, lv2_user_id);
   insert into calc_process_elm_version(object_id,name,daytime,end_date,calc_proc_elm_type,diagram_layout_info,created_by)
   values(lv_stop_elm_id, 'Stop', p_start_date, p_end_date, 'STOP', 'bounds={x=320;y=20;w=100;h=60;}|', lv2_user_id);

   -- Create transition from START to STEP
   lv_start_step_id := SYS_GUID();
   insert into calc_process_transition(object_id,object_code,start_date,end_date,calculation_id,created_by)
   values(lv_start_step_id, lv_start_step_id, p_start_date, p_end_date, p_calculation_id, lv2_user_id);
   insert into calc_proc_tran_version(object_id,name,daytime,end_date,from_element_id,to_element_id,diagram_layout_info,created_by)
   values(lv_start_step_id, lv_start_step_id, p_start_date, p_end_date, lv_start_elm_id, lv_step_elm_id, '|fp=R;tp=L;', lv2_user_id);

   -- Create transition from STEP to STOP
   lv_step_stop_id := SYS_GUID();
   insert into calc_process_transition(object_id,object_code,start_date,end_date,calculation_id,created_by)
   values(lv_step_stop_id, lv_step_stop_id, p_start_date, p_end_date, p_calculation_id, lv2_user_id);
   insert into calc_proc_tran_version(object_id,name,daytime,end_date,from_element_id,to_element_id,diagram_layout_info,created_by)
   values(lv_step_stop_id, lv_step_stop_id, p_start_date, p_end_date, lv_step_elm_id, lv_stop_elm_id, '|fp=R;tp=L;', lv2_user_id);
END createDefaultFlowchart;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : syncNameAndComments
-- Description    : Syncronizes the name and comments of a sub-calculation with the parent process element.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OV_CALCULATION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Called by a trigger on calc_process_element to keep the names and comments in sync.
--                  Performs and EXECUTE IMMEDIATE on the object view to make sure that
--                  JN rules etc are triggered correctly.
--                  Only triggers syncronization if the calculation is of type PRIVATE_SUB.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE syncNameAndComments(p_impl_calc_id VARCHAR2, p_daytime DATE, p_new_name VARCHAR2, p_new_comments VARCHAR2)
--</EC-DOC>
IS
   lv2_sql     VARCHAR2(400);
   lv2_user_id VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
BEGIN
   lv2_sql := 'UPDATE OV_CALCULATION ' ||
              'SET name=:p_new_name, comments=:p_new_comments, last_updated_by=:lv2_user_id ' ||
              'WHERE object_id=:p_impl_calc_id ' ||
              'AND daytime=:p_daytime ' ||
              'AND (name<>:p_new_name OR NVL(comments,''--XDUMMYX--'')<>NVL(:p_new_comments,''--XDUMMYX--'')) ' ||
              'AND CALC_SCOPE = ''PRIVATE_SUB''';
  EXECUTE IMMEDIATE lv2_sql USING p_new_name, p_new_comments, lv2_user_id, p_impl_calc_id, p_daytime, p_new_name, p_new_comments;
END syncNameAndComments;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEmptyCalculationID
-- Description    : Returns a NULL calculation ID for use in function type class attributes.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns a NULL value with the same data type as a calculation object_id.
--
-----------------------------------------------------------------------------------------------------
FUNCTION getEmptyCalculationID RETURN CALCULATION.OBJECT_ID%TYPE
--</EC-DOC>
IS
BEGIN
   RETURN NULL;
END getEmptyCalculationID;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEmptyCalculationType
-- Description    : Returns a NULL calculation type for use in function type class attributes.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns a NULL value with the same data type as a calculation type.
--
-----------------------------------------------------------------------------------------------------
FUNCTION getEmptyCalculationType RETURN CALCULATION.CALC_TYPE%TYPE
--</EC-DOC>
IS
BEGIN
   RETURN NULL;
END getEmptyCalculationType;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEmptyCalculationDaytime
-- Description    : Returns a NULL calculation daytime for use in function type class attributes.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns a NULL value with the same data type as a calculation daytime.
--
-----------------------------------------------------------------------------------------------------
FUNCTION getEmptyCalculationDaytime RETURN CALCULATION_VERSION.DAYTIME%TYPE
--</EC-DOC>
IS
BEGIN
   RETURN NULL;
END getEmptyCalculationDaytime;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteCalcSet
-- Description    : Deletes a set and all dependent data.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_set
-- Using functions: deleteCalcSetImpl
--
-- Configuration
-- required       :
--
-- Behaviour      : Deletes a set and all conditions, combinations and equations for a the set.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteCalcSet(p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2)
--</EC-DOC>
IS
BEGIN
   deleteCalcSetImpl(p_object_id, p_daytime, p_calc_set_name);
   delete calc_set where object_id = p_object_id and daytime = p_daytime and calc_set_name = p_calc_set_name;
END deleteCalcSet;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteCalcSetImpl
-- Description    : Deletes the implementation of a set (i.e. all dependent data) but not the set itself.
--                  Used to implement cascading delete for set definitions.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_set_condition, calc_set_combination, calc_set_equation
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Deletes all conditions, combinations and equations for a given set.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteCalcSetImpl(p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2)
--</EC-DOC>
IS
BEGIN
   delete calc_set_condition where object_id = p_object_id and daytime = p_daytime and calc_set_name = p_calc_set_name;
   delete calc_set_combination where object_id = p_object_id and daytime = p_daytime and calc_set_name = p_calc_set_name;
   delete calc_set_equation where object_id = p_object_id and daytime = p_daytime and calc_set_name = p_calc_set_name;
END deleteCalcSetImpl;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteCalcProcElement
-- Description    : Delete a Calculation Process Element and all related configuration.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calculation, calc_process_element, calc_process_elm_version,
--                  calc_proc_tran_version, calc_proc_elm_iteration
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Deletes the element itself and also:
--                  * Deletes any iterations on the element
--                  * Clears any references from Transitions
--                  * Cascadingly deletes the child calculations of type PRIVATE_SUB
--                    Note that this could cause recursion if the child calculations also contains process elements.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteCalcProcElement(p_object_id VARCHAR2)
--</EC-DOC>
IS
   lv2_user_id VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);

   TYPE calc_id_table IS TABLE OF calculation.object_id%TYPE INDEX BY BINARY_INTEGER;
   child_calculations   calc_id_table;
   num_child_calcs      INTEGER := 0;

   CURSOR c_child_calcs IS
     select distinct c.object_id
     from calculation c, calc_process_elm_version ev
     where ev.object_id = p_object_id
     and c.object_id = ev.implementing_calc_id
     and c.calc_scope = 'PRIVATE_SUB';
BEGIN
   -- Delete iterations
   delete calc_proc_elm_iteration i
   where i.object_id = p_object_id;

   -- Remove any references from transitions
   update calc_proc_tran_version
   set from_element_id = NULL, last_updated_by = lv2_user_id
   where from_element_id = p_object_id;
   update calc_proc_tran_version
   set to_element_id = NULL, last_updated_by = lv2_user_id
   where to_element_id = p_object_id;

   -- Find the child CALCULATION(s) of type PRIVATE_SUB
   FOR cur_calc IN c_child_calcs LOOP
      num_child_calcs := num_child_calcs + 1;
      child_calculations(num_child_calcs) := cur_calc.object_id;
   END LOOP;

   -- Delete the process element
   delete calc_process_elm_version
   where object_id = p_object_id;

   delete calc_process_element
   where object_id = p_object_id;

   -- Delete the child calculation(s)
   FOR rec_no IN 1..num_child_calcs LOOP
      deleteCalculation(child_calculations(rec_no));
   END LOOP;

END deleteCalcProcElement;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteCalcProcTransition
-- Description    : Deletes a Calculation Process Transition
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_process_transition, calc_proc_tran_version
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteCalcProcTransition(p_object_id VARCHAR2)
--</EC-DOC>
IS
BEGIN
   delete calc_proc_tran_version
   where object_id = p_object_id;

   delete calc_process_transition
   where object_id = p_object_id;
END deleteCalcProcTransition;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : deleteCalculation
-- Description    : Deletes a calculation (all versions) and all related configuration.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calculation, calculation_version, calc_variable_local,
--                  calc_equation, calc_process_transition, calc_proc_tran_version, calc_process_element,
--                  calc_set, calc_set_equation, calc_set_combination, calc_set_condition
-- Using functions: deleteCalcProcElement, deleteCalcProcTransition
--
-- Configuration
-- required       :
--
-- Behaviour      : Deletes the calculation itself and also:
--                  * Deletes all local variables
--                  * Deletes all sets and related configuration
--                  * Deletes any process transitions
--                  * Deletes all process elements and related configuration
--                    Note that this could cause recursion if the process elements have child calculations
--
-----------------------------------------------------------------------------------------------------
PROCEDURE deleteCalculation(p_object_id VARCHAR2)
--</EC-DOC>
IS
   CURSOR c_transitions IS
      select t.object_id
      from calc_process_transition t
      where t.calculation_id = p_object_id;

   CURSOR c_elements IS
      select e.object_id
      from calc_process_element e
      where e.calculation_id = p_object_id;

BEGIN
   -- Delete all transistions
   FOR cur_tran IN c_transitions LOOP
      deleteCalcProcTransition(cur_tran.object_id);
   END LOOP;

   -- Recursively delete all sub-elements and calculations
   FOR cur_elm IN c_elements LOOP
      deleteCalcProcElement(cur_elm.object_id);
   END LOOP;

   -- Delete all equations
   delete calc_equation
   where object_id = p_object_id;

   -- Delete all local variables
   delete calc_variable_local
   where object_id = p_object_id;

   -- Delete all local variables
   delete calc_parameter
   where object_id = p_object_id;

   -- Delete all local sets
   delete calc_set_equation
   where object_id = p_object_id;

   delete calc_set_combination
   where object_id = p_object_id;

   delete calc_set_condition
   where object_id = p_object_id;

   delete calc_set
   where object_id = p_object_id;

   -- Delete the calculation
   delete calculation_version
   where object_id = p_object_id;

   delete calculation
   where object_id = p_object_id;
END deleteCalculation;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : copyCalcVersionCascading (private)
-- Description    : Copies a calculation version and all related configuration.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : (to many to list)
-- Using functions: (to many to list)
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
PROCEDURE copyCalcVersionCascading(p_object_id VARCHAR2, p_daytime DATE, p_new_start_date DATE, p_new_end_date DATE, p_new_object_id VARCHAR2, p_calc_context_id_ovrd VARCHAR2, p_code_ovrd VARCHAR2, p_name_ovrd VARCHAR2,p_update_flag VARCHAR2)
--</EC-DOC>
IS
   CURSOR c_local_vars IS
      SELECT * FROM calc_variable_local v
      WHERE v.object_id = p_object_id
      AND v.daytime = p_daytime;

   CURSOR c_local_params IS
      SELECT * FROM calc_parameter v
      WHERE v.object_id = p_object_id;

   CURSOR c_local_sets IS
      SELECT * FROM calc_set s
      WHERE s.object_id = p_object_id
      AND s.daytime = p_daytime;

   CURSOR c_set_conditions IS
      SELECT * FROM calc_set_condition c
      WHERE c.object_id = p_object_id
      AND c.daytime = p_daytime;

   CURSOR c_set_combinations IS
      SELECT * FROM calc_set_combination c
      WHERE c.object_id = p_object_id
      AND c.daytime = p_daytime;

   CURSOR c_set_equations IS
      SELECT * FROM calc_set_equation e
      WHERE e.object_id = p_object_id
      AND e.daytime = p_daytime;

   CURSOR c_equations IS
      SELECT * FROM calc_equation e
      WHERE e.object_id = p_object_id
      AND e.daytime = p_daytime;

   CURSOR c_transitions IS
      SELECT t.* FROM calc_process_transition t, calc_proc_tran_version tv
      WHERE tv.object_id = t.object_id
      AND t.calculation_id = p_object_id
      AND tv.daytime = p_daytime;

   CURSOR c_elements IS
      SELECT e.* FROM calc_process_element e, calc_process_elm_version ev
      WHERE ev.object_id = e.object_id
      AND e.calculation_id = p_object_id
      AND ev.daytime = p_daytime;

   CURSOR c_elm_iterations(cp_element_id VARCHAR2) IS
      SELECT i.* FROM calc_proc_elm_iteration i
      WHERE i.object_id = cp_element_id
      AND i.calculation_id = p_object_id
      AND i.daytime = p_daytime;

   mt                        calculation%ROWTYPE;
   vt                        calculation_version%ROWTYPE;
   tv                        calc_proc_tran_version%ROWTYPE;
   ev                        calc_process_elm_version%ROWTYPE;
   lv_new_object_id          VARCHAR2(32);
   lv_tmp_object_id          VARCHAR2(32);
   lv_tmp_object_id2         VARCHAR2(32);
   ln_obj_exists_cnt         NUMBER;
   ld_prev_version_daytime   DATE;
   ld_next_version_daytime   DATE;
   lv_user                   VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
   ld_sysdate                DATE := EcDp_Date_Time.getCurrentSysdate;
   update_flag               VARCHAR2(1) :=Nvl(p_update_flag,'N');

BEGIN
   lv_new_object_id := NVL(p_new_object_id, SYS_GUID());
   SELECT count(*) INTO ln_obj_exists_cnt FROM calculation WHERE object_id = p_new_object_id;


   --
   -- Copy the main table (unless object already exists -> new version only)
   --
   mt := ec_calculation.row_by_pk(p_object_id);
   IF ln_obj_exists_cnt = 0 THEN
      mt.object_id := lv_new_object_id;
      mt.start_date := p_new_start_date;
      mt.end_date := p_new_end_date;
      mt.calc_context_id := NVL(p_calc_context_id_ovrd, mt.calc_context_id);
      mt.object_code := NVL(p_code_ovrd, mt.object_id);
      mt.created_by:=lv_user; mt.created_date:=ld_sysdate; mt.last_updated_by:=NULL; mt.last_updated_date:=NULL; mt.rev_no:=0; mt.rev_text:=NULL; mt.record_status:='P'; mt.approval_by:=NULL; mt.approval_date:=NULL; mt.approval_state:=NULL; mt.rec_id:=SYS_GUID();
      INSERT INTO calculation VALUES mt;

		--
		-- Copy all static parameters only if new object
		--
		FOR var IN c_local_params LOOP
		  var.object_id := lv_new_object_id;
		  var.created_by:=lv_user; var.created_date:=ld_sysdate; var.last_updated_by:=NULL; var.last_updated_date:=NULL; var.rev_no:=0; var.rev_text:=NULL; var.record_status:='P'; var.approval_by:=NULL; var.approval_date:=NULL; var.approval_state:=NULL; var.rec_id:=SYS_GUID();
		  INSERT INTO calc_parameter VALUES var;
		END LOOP;

   ELSE
      -- Object exists, validate start and end dates
      IF p_new_start_date < mt.start_date OR p_new_start_date >= mt.end_date OR (p_new_end_date IS NULL AND mt.end_date IS NOT NULL) OR p_new_end_date>mt.end_date THEN
         RAISE_APPLICATION_ERROR(-20000, 'New version must have start and end dates within the object''s start and end dates.');
      END IF;
   END IF;

   --
   -- Create the version
   --
   vt := ec_calculation_version.row_by_pk(p_object_id, p_daytime, '=');
   vt.object_id := lv_new_object_id;
   vt.daytime := p_new_start_date;
   vt.end_date := p_new_end_date;
   vt.name := NVL(p_name_ovrd, vt.name);
   vt.created_by:=lv_user; vt.created_date:=ld_sysdate; vt.last_updated_by:=NULL; vt.last_updated_date:=NULL; vt.rev_no:=0; vt.rev_text:=NULL; vt.record_status:='P'; vt.approval_by:=NULL; vt.approval_date:=NULL; vt.approval_state:=NULL; vt.rec_id:=SYS_GUID();
   IF ln_obj_exists_cnt > 0 THEN
      ld_prev_version_daytime := ec_calculation_version.prev_daytime(p_new_object_id, p_new_start_date);
      ld_next_version_daytime := ec_calculation_version.next_daytime(p_new_object_id, p_new_start_date);
      IF ld_prev_version_daytime IS NOT NULL THEN
         -- There is a version prior to the new one - update end_date on it
         UPDATE calculation_version SET end_date = p_new_start_date, last_updated_by = lv_user WHERE object_id = p_new_object_id AND daytime = ld_prev_version_daytime;
      END IF;
      IF ld_next_version_daytime IS NOT NULL THEN
         -- There is a version after the new one - adjust new end_date accordingly
         vt.end_date := ld_next_version_daytime;
      END IF;
   END IF;
   INSERT INTO calculation_version VALUES vt;

   --
   -- Copy all local variables
   --
   FOR var IN c_local_vars LOOP
      var.object_id := lv_new_object_id;
      var.daytime := p_new_start_date;
      var.calc_context_id := NVL(p_calc_context_id_ovrd, var.calc_context_id);
      var.created_by:=lv_user; var.created_date:=ld_sysdate; var.last_updated_by:=NULL; var.last_updated_date:=NULL; var.rev_no:=0; var.rev_text:=NULL; var.record_status:='P'; var.approval_by:=NULL; var.approval_date:=NULL; var.approval_state:=NULL; var.rec_id:=SYS_GUID();
      INSERT INTO calc_variable_local VALUES var;
   END LOOP;


   --
   -- Copy all local sets
   --
   -- First insert with base set = NULL to avoid issues with internal references
   FOR s IN c_local_sets LOOP
      s.object_id := lv_new_object_id;
      s.daytime := p_new_start_date;
      s.calc_context_id := NVL(p_calc_context_id_ovrd, s.calc_context_id);
      s.base_calc_set_name := NULL;
      s.created_by:=lv_user; s.created_date:=ld_sysdate; s.last_updated_by:=NULL; s.last_updated_date:=NULL; s.rev_no:=0; s.rev_text:=NULL; s.record_status:='P'; s.approval_by:=NULL; s.approval_date:=NULL; s.approval_state:=NULL; s.rec_id:=SYS_GUID();
      INSERT INTO calc_set VALUES s;
   END LOOP;
   -- Then update base set
   FOR s IN c_local_sets LOOP
      UPDATE calc_set SET base_calc_set_name = s.base_calc_set_name, last_updated_by = lv_user
      WHERE object_id = lv_new_object_id AND daytime = p_new_start_date AND calc_set_name = s.calc_set_name;
   END LOOP;
   -- Copy conditions
   FOR c IN c_set_conditions LOOP
      c.object_id := lv_new_object_id;
      c.daytime := p_new_start_date;
      c.created_by:=lv_user; c.created_date:=ld_sysdate; c.last_updated_by:=NULL; c.last_updated_date:=NULL; c.rev_no:=0; c.rev_text:=NULL; c.record_status:='P'; c.approval_by:=NULL; c.approval_date:=NULL; c.approval_state:=NULL; c.rec_id:=SYS_GUID();
      INSERT INTO calc_set_condition VALUES c;
   END LOOP;
   -- Copy combinations
   FOR c IN c_set_combinations LOOP
      c.object_id := lv_new_object_id;
      c.daytime := p_new_start_date;
      c.created_by:=lv_user; c.created_date:=ld_sysdate; c.last_updated_by:=NULL; c.last_updated_date:=NULL; c.rev_no:=0; c.rev_text:=NULL; c.record_status:='P'; c.approval_by:=NULL; c.approval_date:=NULL; c.approval_state:=NULL; c.rec_id:=SYS_GUID();
      INSERT INTO calc_set_combination VALUES c;
   END LOOP;
   -- Copy set equations
   FOR e IN c_set_equations LOOP
      e.object_id := lv_new_object_id;
      e.daytime := p_new_start_date;
      e.created_by:=lv_user; e.created_date:=ld_sysdate; e.last_updated_by:=NULL; e.last_updated_date:=NULL; e.rev_no:=0; e.rev_text:=NULL; e.record_status:='P'; e.approval_by:=NULL; e.approval_date:=NULL; e.approval_state:=NULL; e.rec_id:=SYS_GUID();
      INSERT INTO calc_set_equation VALUES e;
   END LOOP;

   --
   -- Copy all equations
   --
   FOR e IN c_equations LOOP
      e.object_id := lv_new_object_id;
      e.daytime := p_new_start_date;
      e.created_by:=lv_user; e.created_date:=ld_sysdate; e.last_updated_by:=NULL; e.last_updated_date:=NULL; e.rev_no:=0; e.rev_text:=NULL; e.record_status:='P'; e.approval_by:=NULL; e.approval_date:=NULL; e.approval_state:=NULL; e.rec_id:=SYS_GUID();
      INSERT INTO calc_equation VALUES e;
   END LOOP;

   --
   -- Copy all transitions, temporarily using old from and to element IDs
   -- since we don't know the new IDs yet
   --
   FOR tm IN c_transitions LOOP
      lv_tmp_object_id := tm.object_id;
      tm.object_id := SYS_GUID();
      -- Copy main table
      tm.object_code := tm.object_id;
      tm.start_date := p_new_start_date;
      tm.end_date := p_new_end_date;
      tm.calculation_id := lv_new_object_id;
      tm.created_by:=lv_user; tm.created_date:=ld_sysdate; tm.last_updated_by:=NULL; tm.last_updated_date:=NULL; tm.rev_no:=0; tm.rev_text:=NULL; tm.record_status:='P'; tm.approval_by:=NULL; tm.approval_date:=NULL; tm.approval_state:=NULL; tm.rec_id:=SYS_GUID();
      INSERT INTO calc_process_transition VALUES tm;
      -- Copy version table
      tv := ec_calc_proc_tran_version.row_by_pk(lv_tmp_object_id, p_daytime);
      tv.object_id := tm.object_id;
      tv.daytime := p_new_start_date;
      tv.end_date := p_new_end_date;
      tv.created_by:=lv_user; tv.created_date:=ld_sysdate; tv.last_updated_by:=NULL; tv.last_updated_date:=NULL; tv.rev_no:=0; tv.rev_text:=NULL; tv.record_status:='P'; tv.approval_by:=NULL; tv.approval_date:=NULL; tv.approval_state:=NULL; tv.rec_id:=SYS_GUID();
      INSERT INTO calc_proc_tran_version VALUES tv;
      IF update_flag='Y' THEN
         update calc_proc_tran_version set end_date = p_new_start_date where object_id = lv_tmp_object_id and daytime = p_daytime;
      END IF;
   END LOOP;

   --
   -- Copy all process elements (cascading) and update transition IDs
   --
   FOR em IN c_elements LOOP
      lv_tmp_object_id := em.object_id;
      em.object_id := SYS_GUID();
      -- Copy main table
      em.object_code := em.object_id;
      em.start_date := p_new_start_date;
      em.end_date := p_new_end_date;
      em.calculation_id := lv_new_object_id;
      em.created_by:=lv_user; em.created_date:=ld_sysdate; em.last_updated_by:=NULL; em.last_updated_date:=NULL; em.rev_no:=0; em.rev_text:=NULL; em.record_status:='P'; em.approval_by:=NULL; em.approval_date:=NULL; em.approval_state:=NULL; em.rec_id:=SYS_GUID();
      INSERT INTO calc_process_element VALUES em;
      -- Copy version table
      ev := ec_calc_process_elm_version.row_by_pk(lv_tmp_object_id, p_daytime);
      ev.object_id := em.object_id;
      ev.daytime := p_new_start_date;
      ev.end_date := p_new_end_date;
      IF ev.implementing_calc_id IS NOT NULL THEN
         -- Cascadingly copy sub calculation. NOTYET: Only copy if private_sub
         lv_tmp_object_id2 := SYS_GUID();
         copyCalcVersionCascading(ev.implementing_calc_id, p_daytime, p_new_start_date, p_new_end_date, lv_tmp_object_id2, p_calc_context_id_ovrd, lv_tmp_object_id2, NULL,update_flag);
         ev.implementing_calc_id := lv_tmp_object_id2;
      END IF;
      ev.created_by:=lv_user; ev.created_date:=ld_sysdate; ev.last_updated_by:=NULL; ev.last_updated_date:=NULL; ev.rev_no:=0; ev.rev_text:=NULL; ev.record_status:='P'; ev.approval_by:=NULL; ev.approval_date:=NULL; ev.approval_state:=NULL; ev.rec_id:=SYS_GUID();
      INSERT INTO calc_process_elm_version VALUES ev;
      IF update_flag='Y' THEN
         update calc_process_elm_version set end_date = p_new_start_date where object_id = lv_tmp_object_id and daytime = p_daytime;
      END IF;
      -- Copy iterations
      FOR it IN c_elm_iterations(lv_tmp_object_id) LOOP
         it.object_id := em.object_id;
         it.daytime := p_new_start_date;
         it.calculation_id := lv_new_object_id;
         it.created_by:=lv_user; it.created_date:=ld_sysdate; it.last_updated_by:=NULL; it.last_updated_date:=NULL; it.rev_no:=0; it.rev_text:=NULL; it.record_status:='P'; it.approval_by:=NULL; it.approval_date:=NULL; it.approval_state:=NULL; it.rec_id:=SYS_GUID();
         INSERT INTO calc_proc_elm_iteration VALUES it;
      END LOOP;
      -- Update transitions with new from and to element ID
      UPDATE calc_proc_tran_version tv SET tv.from_element_id = em.object_id, last_updated_by = lv_user
      WHERE tv.from_element_id = lv_tmp_object_id AND tv.daytime = p_new_start_date AND tv.object_id IN (SELECT t.object_id FROM calc_process_transition t WHERE t.calculation_id = lv_new_object_id);
      UPDATE calc_proc_tran_version tv SET tv.to_element_id = em.object_id, last_updated_by = lv_user
      WHERE tv.to_element_id = lv_tmp_object_id AND tv.daytime = p_new_start_date AND tv.object_id IN (SELECT t.object_id FROM calc_process_transition t WHERE t.calculation_id = lv_new_object_id);
   END LOOP;

   IF ec_class.access_control_ind('CALCULATION')='Y' THEN
      EcDp_Acl.RefreshObject(lv_new_object_id, 'CALCULATION', 'INSERTING');
   END IF;
END copyCalcVersionCascading;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       :
-- Description    :
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
-----------------------------------------------------------------------------------------------------
FUNCTION getCalculationPath(p_object_id VARCHAR2, p_daytime DATE, p_separator VARCHAR2 DEFAULT '/') RETURN VARCHAR2
IS
   CURSOR c_calculation IS
     SELECT cpe.calculation_id, cpev.name
     FROM   calc_process_elm_version cpev, calc_process_element cpe, calculation c
     WHERE  cpev.object_id=cpe.object_id AND c.object_id=cpev.implementing_calc_id AND c.calc_scope='PRIVATE_SUB'
     CONNECT BY cpev.implementing_calc_id=PRIOR cpe.calculation_id
     START WITH cpev.implementing_calc_id=p_object_id;

   lt_calculation CALCULATION%ROWTYPE := ec_calculation.row_by_pk(p_object_id);
   lv2_path VARCHAR2(4000);
   lv2_parent_id VARCHAR2(32);
   lv2_separator VARCHAR2(200) := Nvl(p_separator, '/');
BEGIN
   IF lt_calculation.calc_scope='MAIN' THEN
     RETURN lv2_separator||ec_calculation_version.name(p_object_id, p_daytime, '<=');
   END IF;
   lv2_path := '';
   FOR cur in c_calculation LOOP
      lv2_path := lv2_separator || cur.name || lv2_path;
      lv2_parent_id := cur.calculation_id;
   END LOOP;
   RETURN lv2_separator || ec_calculation_version.name(lv2_parent_id, p_daytime, '<=') || lv2_path;
END getCalculationPath;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : renameLocalVariable
-- Description    : Renames a local calculation variable.
-- Preconditions  : The new variable name must not already be in use in the same calculation
--                  and with the same dimensions.
-- Postconditions :
--
-- Using tables   : calc_variable_local
-- Using functions: EcDp_Calc_Mapping.getVariableSignature, ec_calc_variable_local.row_by_pk,
--                  EcDp_User_Session.getUserSessionParameter, EcDp_Date_Time.getCurrentSysdate
--
-- Configuration
-- required       :
--
-- Behaviour      : Renames the variable by changing the name but keeping the dimensions.
--
-----------------------------------------------------------------------------------------------------
PROCEDURE renameLocalVariable(p_object_id VARCHAR2, p_daytime DATE, p_calc_var_signature VARCHAR2, p_new_name VARCHAR2)
--</EC-DOC>
IS
   l_cur_rec                 calc_variable_local%ROWTYPE;
   lv_new_signature          calc_variable_local.calc_var_signature%TYPE;
   lv_user                   VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
   ld_sysdate                DATE := EcDp_Date_Time.getCurrentSysdate;
BEGIN
   l_cur_rec := ec_calc_variable_local.row_by_pk(p_object_id, p_daytime, p_calc_var_signature);
   lv_new_signature := EcDp_Calc_Mapping.getVariableSignature(p_new_name, l_cur_rec.dim1_object_type_code, l_cur_rec.dim2_object_type_code, l_cur_rec.dim3_object_type_code, l_cur_rec.dim4_object_type_code, l_cur_rec.dim5_object_type_code);
   UPDATE calc_variable_local
   SET calc_var_signature = lv_new_signature, name = p_new_name, last_updated_date = ld_sysdate, last_updated_by = lv_user
   WHERE object_id = p_object_id
   AND daytime = p_daytime
   AND calc_var_signature = p_calc_var_signature;
END renameLocalVariable;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : copyLocalVariable
-- Description    : Copies a local variable.
-- Preconditions  : If variable set is copied to another calculation, then any referenced object types
--                  must exist in the scope of that calculation.
-- Postconditions :
--
-- Using tables   : calc_variable_local
-- Using functions: ec_calc_variable_local.row_by_pk, ec_calculation.calc_context_id, EcDp_Calc_Mapping.getVariableSignature,
--                  EcDp_User_Session.getUserSessionParameter, EcDp_Date_Time.getCurrentSysdate
--
-- Configuration
-- required       :
--
-- Behaviour      : Copies the local variable.
--                  The new object id and daytime are optional, if these are set to NULL then
--                  the copy get the same values as the original.
--                  If no new name is given, the prodedure will assign the fisrt "available" name based on the following rules:
--                  1) The same name as the original variable
--                  2) "Copy of " + the original name of the variable
--                  3) Copy (2) of " + the original name of the variable etc (2, 3, 4, .. until a unique name is found)
--
-----------------------------------------------------------------------------------------------------
PROCEDURE copyLocalVariable(p_object_id VARCHAR2, p_daytime DATE, p_calc_var_signature VARCHAR2, p_new_object_id VARCHAR2, p_new_daytime DATE, p_new_name VARCHAR2)
--</EC-DOC>
IS
   l_var                     calc_variable_local%ROWTYPE;
   lv2_new_name              calc_variable_local.name%TYPE := NULL;
   lv2_tmp_new_name          calc_variable_local.name%TYPE;
   lv2_tmp_new_signature     calc_variable_local.calc_var_signature%TYPE;
   ln_copy_no                INTEGER := 0;
   ln_tmp_count              INTEGER;
   lv_user                   VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
   ld_sysdate                DATE := EcDp_Date_Time.getCurrentSysdate;
BEGIN
   l_var := ec_calc_variable_local.row_by_pk(p_object_id, p_daytime, p_calc_var_signature);
   IF l_var.object_id IS NULL THEN
      -- Source record not found...
      RAISE_APPLICATION_ERROR(-20000,'Source record not found!');
   END IF;
   l_var.object_id := NVL(p_new_object_id, p_object_id);
   l_var.daytime := NVL(p_new_daytime, p_daytime);
   l_var.calc_context_id := ec_calculation.calc_context_id(l_var.object_id);
   IF p_new_name IS NOT NULL THEN
      l_var.name := p_new_name;
   ELSE
      -- Automatically establish the new name based on the old name (e.g. Copy of xxxx)
      WHILE lv2_new_name IS NULL LOOP
         IF ln_copy_no=0 THEN
            lv2_tmp_new_name := l_var.name;
         ELSIF ln_copy_no=1 THEN
            lv2_tmp_new_name := 'Copy of '||l_var.name;
         ELSE
            lv2_tmp_new_name := 'Copy ('||to_char(ln_copy_no)||') of '||l_var.name;
         END IF;
         lv2_tmp_new_signature := EcDp_Calc_Mapping.getVariableSignature(lv2_tmp_new_name, l_var.dim1_object_type_code, l_var.dim2_object_type_code, l_var.dim3_object_type_code, l_var.dim4_object_type_code, l_var.dim5_object_type_code);
         SELECT COUNT(*) INTO ln_tmp_count FROM calc_variable_local WHERE object_id = l_var.object_id and daytime = l_var.daytime and calc_var_signature = lv2_tmp_new_signature;
         IF ln_tmp_count=0 THEN
            lv2_new_name := lv2_tmp_new_name;
         END IF;
         ln_copy_no := ln_copy_no + 1;
      END LOOP;
      l_var.name := lv2_new_name;
   END IF;
   l_var.calc_var_signature := EcDp_Calc_Mapping.getVariableSignature(l_var.name, l_var.dim1_object_type_code, l_var.dim2_object_type_code, l_var.dim3_object_type_code, l_var.dim4_object_type_code, l_var.dim5_object_type_code);
   l_var.created_by:=lv_user; l_var.created_date:=ld_sysdate; l_var.last_updated_by:=NULL; l_var.last_updated_date:=NULL; l_var.rev_no:=0; l_var.rev_text:=NULL; l_var.record_status:='P'; l_var.approval_by:=NULL; l_var.approval_date:=NULL; l_var.approval_state:=NULL; l_var.rec_id:=SYS_GUID();
   INSERT INTO calc_variable_local VALUES l_var;
END copyLocalVariable;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getSetDefinitionCopyName
-- Description    : Determines the new name a set will get after it is copied to a given calculation.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_set
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : The new object id and daytime are optional, if these are set to NULL then
--                  the copy is assumed to use the same values as the original.
--                  The function determines the first "available" name based on the following rules:
--                  1) The same name as the original set
--                  2) "Copy of " + the original name of the set
--                  3) Copy (2) of " + the original name of the set etc (2, 3, 4, .. until a unique name is found)
--
-----------------------------------------------------------------------------------------------------
FUNCTION getSetDefinitionCopyName(p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2, p_new_object_id VARCHAR2, p_new_daytime DATE)
RETURN CALC_SET.CALC_SET_NAME%TYPE
--</EC-DOC>
IS
   l_set                     calc_set%ROWTYPE;
   lv2_new_name              calc_set.calc_set_name%TYPE := NULL;
   lv2_tmp_new_name          calc_set.calc_set_name%TYPE;
   ln_copy_no                INTEGER := 0;
   ln_tmp_count              INTEGER;
BEGIN
    -- Automatically establish the new name based on the old name (e.g. Copy of xxxx)
    WHILE lv2_new_name IS NULL LOOP
       IF ln_copy_no=0 THEN
          lv2_tmp_new_name := p_calc_set_name;
       ELSIF ln_copy_no=1 THEN
          lv2_tmp_new_name := 'Copy of '||p_calc_set_name;
       ELSE
          lv2_tmp_new_name := 'Copy ('||to_char(ln_copy_no)||') of '||p_calc_set_name;
       END IF;
       SELECT COUNT(*) INTO ln_tmp_count FROM calc_set WHERE object_id = NVL(p_new_object_id, p_object_id) and daytime = NVL(p_new_daytime, p_daytime) and calc_set_name = lv2_tmp_new_name;
       IF ln_tmp_count=0 THEN
          lv2_new_name := lv2_tmp_new_name;
       END IF;
       ln_copy_no := ln_copy_no + 1;
    END LOOP;
    RETURN lv2_new_name;
END getSetDefinitionCopyName;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : copySetDefinition
-- Description    : Copies a set definition including conditions, combinations and equations.
-- Preconditions  : If the set is copied to another calculation, then any referenced object types,
--                  base sets etc must exist in the scope of that calculation.
-- Postconditions :
--
-- Using tables   : calc_set, calc_set_condition, calc_set_combination, calc_set_equation
-- Using functions: ec_calc_set.row_by_pk, ec_calculation.calc_context_id,
--                  EcDp_User_Session.getUserSessionParameter, EcDp_Date_Time.getCurrentSysdate
--
-- Configuration
-- required       :
--
-- Behaviour      : Copies the set definition and all conditions, combinations and equations.
--                  The new object id and daytime are optional, if these are set to NULL then
--                  the copy get the same values as the original.
--                  If no new name is given, the prodedure will assign the first "available" name based on the following rules:
--                  1) The same name as the original set
--                  2) "Copy of " + the original name of the set
--                  3) Copy (2) of " + the original name of the set etc (2, 3, 4, .. until a unique name is found)
--
-----------------------------------------------------------------------------------------------------
PROCEDURE copySetDefinition(p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2, p_new_object_id VARCHAR2, p_new_daytime DATE, p_new_name VARCHAR2)
--</EC-DOC>
IS
   CURSOR c_set_conditions IS
      SELECT * FROM calc_set_condition c
      WHERE c.object_id = p_object_id
      AND c.daytime = p_daytime
      AND c.calc_set_name = p_calc_set_name;

   CURSOR c_set_combinations IS
      SELECT * FROM calc_set_combination c
      WHERE c.object_id = p_object_id
      AND c.daytime = p_daytime
      AND c.calc_set_name = p_calc_set_name;

   CURSOR c_set_equations IS
      SELECT * FROM calc_set_equation e
      WHERE e.object_id = p_object_id
      AND e.daytime = p_daytime
      AND e.calc_set_name = p_calc_set_name;

   l_set                     calc_set%ROWTYPE;
   lv2_new_name              calc_set.calc_set_name%TYPE := NULL;
   lv2_tmp_new_name          calc_set.calc_set_name%TYPE;
   ln_copy_no                INTEGER := 0;
   ln_tmp_count              INTEGER;
   lv_user                   VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
   ld_sysdate                DATE := EcDp_Date_Time.getCurrentSysdate;
BEGIN
   l_set := ec_calc_set.row_by_pk(p_object_id, p_daytime, p_calc_set_name);
   IF l_set.object_id IS NULL THEN
      -- Source record not found...
      RAISE_APPLICATION_ERROR(-20000,'Source record not found!');
   END IF;
   l_set.object_id := NVL(p_new_object_id, p_object_id);
   l_set.daytime := NVL(p_new_daytime, p_daytime);
   l_set.calc_context_id := ec_calculation.calc_context_id(l_set.object_id);
   IF p_new_name IS NOT NULL THEN
      l_set.calc_set_name := p_new_name;
   ELSE
      l_set.calc_set_name := getSetDefinitionCopyName(p_object_id, p_daytime, p_calc_set_name, p_new_object_id, p_new_daytime);
   END IF;
   l_set.created_by:=lv_user; l_set.created_date:=ld_sysdate; l_set.last_updated_by:=NULL; l_set.last_updated_date:=NULL; l_set.rev_no:=0; l_set.rev_text:=NULL; l_set.record_status:='P'; l_set.approval_by:=NULL; l_set.approval_date:=NULL; l_set.approval_state:=NULL; l_set.rec_id:=SYS_GUID();
   INSERT INTO calc_set VALUES l_set;

   -- Copy conditions
   FOR c IN c_set_conditions LOOP
      c.object_id := l_set.object_id;
      c.daytime := l_set.daytime;
      c.calc_set_name := l_set.calc_set_name;
      c.created_by:=lv_user; c.created_date:=ld_sysdate; c.last_updated_by:=NULL; c.last_updated_date:=NULL; c.rev_no:=0; c.rev_text:=NULL; c.record_status:='P'; c.approval_by:=NULL; c.approval_date:=NULL; c.approval_state:=NULL; c.rec_id:=SYS_GUID();
      INSERT INTO calc_set_condition VALUES c;
   END LOOP;
   -- Copy combinations
   FOR c IN c_set_combinations LOOP
      c.object_id := l_set.object_id;
      c.daytime := l_set.daytime;
      c.calc_set_name := l_set.calc_set_name;
      c.created_by:=lv_user; c.created_date:=ld_sysdate; c.last_updated_by:=NULL; c.last_updated_date:=NULL; c.rev_no:=0; c.rev_text:=NULL; c.record_status:='P'; c.approval_by:=NULL; c.approval_date:=NULL; c.approval_state:=NULL; c.rec_id:=SYS_GUID();
      INSERT INTO calc_set_combination VALUES c;
   END LOOP;
   -- Copy set equations
   FOR e IN c_set_equations LOOP
      e.object_id := l_set.object_id;
      e.daytime := l_set.daytime;
      e.calc_set_name := l_set.calc_set_name;
      e.created_by:=lv_user; e.created_date:=ld_sysdate; e.last_updated_by:=NULL; e.last_updated_date:=NULL; e.rev_no:=0; e.rev_text:=NULL; e.record_status:='P'; e.approval_by:=NULL; e.approval_date:=NULL; e.approval_state:=NULL; e.rec_id:=SYS_GUID();
      INSERT INTO calc_set_equation VALUES e;
   END LOOP;
END copySetDefinition;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : createDefaultSetImpl
-- Description    : Creates a default implementation for a new set created through an EC screen.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : calc_set_equation
-- Using functions: ec_calc_set.calc_set_type, dbms_lob.createtemporary,
--                  EcDp_User_Session.getUserSessionParameter, EcDp_Date_Time.getCurrentSysdate
--
-- Configuration
-- required       :
--
-- Behaviour      : Used as a post-save task in configuration screens.
--                  The procedure checks that the save operation is an insert, and creates a
--                  default implementation:
--                  - Equation based sets gets a set equation "setname = ?"
--
-----------------------------------------------------------------------------------------------------
PROCEDURE createDefaultSetImpl(p_operation VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2)
--</EC-DOC>
IS
   lc_empty_clob             CLOB;
   lv2_calc_set_type         calc_set.calc_set_type%TYPE;
   lv2_eqn                   VARCHAR2(1000);
   lv_user                   VARCHAR2(30) := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
   ld_sysdate                DATE := EcDp_Date_Time.getCurrentSysdate;
BEGIN
   IF NVL(p_operation,'unchanged')<>'create' THEN
     -- Not insert - so don't do anything!
     RETURN;
   END IF;
   lv2_calc_set_type := ec_calc_set.calc_set_type(p_object_id, p_daytime, p_calc_set_name, '=');
   IF NVL(lv2_calc_set_type,'unknown')='EQUATIONS' THEN
      dbms_lob.createtemporary(lc_empty_clob, true, dbms_lob.session);
      lv2_eqn := '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq /><m:ci type="set">'||p_calc_set_name||'</m:ci><m:ci type="empty">?</m:ci></m:apply></m:math>';
      INSERT INTO calc_set_equation(object_id, daytime, calc_set_name, exec_order, description, iterations, condition, equation, created_by, created_date)
      VALUES(p_object_id, p_daytime, p_calc_set_name, 1, lc_empty_clob, lc_empty_clob, lc_empty_clob, lv2_eqn, lv_user, ld_sysdate);
   END IF;
END createDefaultSetImpl;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getLogProfileName
-- Description    : Return log profile name for the given calculation run, identified by p_run_no.
--                  Note that p_run_no is assumed to come from the run_no column in the alloc_job_log
--                  table.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: ec_calc_log_profile_ovrd, ec_calc_log_profile
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-----------------------------------------------------------------------------------------------------
FUNCTION getLogProfileName(p_run_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS
  lr_log_record alloc_job_log%ROWTYPE := Ec_Alloc_Job_Log.row_by_pk(p_run_no);
  mainJobId ov_Calculation.MAIN_CALCULATION_ID%TYPE;
  calcType ov_Calculation.Calc_Type%TYPE;
BEGIN
  IF lr_log_record.run_no IS NULL THEN
    RETURN NULL;
  END IF;
  IF lr_log_record.job_id IS NOT NULL THEN
    select calc_type into calcType from calculation where object_id=lr_log_record.job_id;
    IF calcType IS NOT NULL AND calcType = 'PROXY' THEN
        select main_calculation_id into mainJobId from ov_calculation where object_id=lr_log_record.job_id and daytime <= lr_log_record.daytime and lr_log_record.daytime  < nvl(end_date, lr_log_record.daytime + 1);
        IF ( INSTR(lr_log_record.log_level,'$') = 0) THEN
           RETURN Nvl(ec_calc_log_profile.name(lr_log_record.log_level), lr_log_record.log_level);
        ELSE
           RETURN ec_calc_log_profile_ovrd.name(mainJobId,lr_log_record.daytime,substr(lr_log_record.log_level,34),'<=');
        END IF;
    END IF;

  END IF;

  IF lr_log_record.job_id IS NULL OR lr_log_record.job_id||'$'!=substr(lr_log_record.log_level,1,33) THEN
    RETURN Nvl(ec_calc_log_profile.name(lr_log_record.log_level), lr_log_record.log_level);
  END IF;
  RETURN ec_calc_log_profile_ovrd.name(lr_log_record.job_id,lr_log_record.daytime,substr(lr_log_record.log_level,34),'<=');
END getLogProfileName;

END EcDp_Calculation;