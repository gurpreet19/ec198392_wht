CREATE OR REPLACE PACKAGE EcDp_Calculation IS
/****************************************************************
** Package        :  EcDp_Calculation, header part
**
** $Revision: 1.15 $
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
*****************************************************************/


TYPE PARAM_MAP IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(2000);

PROCEDURE createCalculation(p_object_id VARCHAR2, p_code VARCHAR2, p_name VARCHAR2, p_start_date DATE, p_end_date DATE, p_calc_context_id VARCHAR2, p_calc_period VARCHAR2, p_calc_type VARCHAR2, p_calc_scope VARCHAR2, p_create_default_impl VARCHAR2);

--

PROCEDURE createCalculationAsCopy(p_copy_of_object_id VARCHAR2, p_copy_of_daytime DATE, p_new_code VARCHAR2, p_new_name VARCHAR2, p_new_start_date DATE, p_new_end_date DATE);

--

PROCEDURE addCalculationVersion(p_object_id VARCHAR2, p_new_daytime DATE);

--

PROCEDURE implementProcessElement(p_label VARCHAR2, p_start_date DATE, p_end_date DATE, p_calculation_id VARCHAR2, p_new_calc_id VARCHAR2, p_new_calc_type VARCHAR2, p_copy_of_calc_id VARCHAR2, p_copy_of_calc_daytime DATE);

--

PROCEDURE createDefaultImplOnInsert(p_operation VARCHAR2, p_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_calc_type VARCHAR2);

--

PROCEDURE syncNameAndComments(p_impl_calc_id VARCHAR2, p_daytime DATE, p_new_name VARCHAR2, p_new_comments VARCHAR2);

--

FUNCTION getEmptyCalculationID RETURN CALCULATION.OBJECT_ID%TYPE;

--

FUNCTION getEmptyCalculationType RETURN CALCULATION.CALC_TYPE%TYPE;

--

FUNCTION getEmptyCalculationDaytime RETURN CALCULATION_VERSION.DAYTIME%TYPE;

--

PROCEDURE deleteCalcSet(p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2);

--

PROCEDURE deleteCalcSetImpl(p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2);

--

PROCEDURE deleteCalcProcElement(p_object_id VARCHAR2);

--

PROCEDURE deleteCalcProcTransition(p_object_id VARCHAR2);

--

PROCEDURE deleteCalculation(p_object_id VARCHAR2);

--

PROCEDURE renameLocalVariable(p_object_id VARCHAR2, p_daytime DATE, p_calc_var_signature VARCHAR2, p_new_name VARCHAR2);

--

PROCEDURE copyLocalVariable(p_object_id VARCHAR2, p_daytime DATE, p_calc_var_signature VARCHAR2, p_new_object_id VARCHAR2, p_new_daytime DATE, p_new_name VARCHAR2);

--

PROCEDURE copySetDefinition(p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2, p_new_object_id VARCHAR2, p_new_daytime DATE, p_new_name VARCHAR2);

--

FUNCTION getSetDefinitionCopyName(p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2, p_new_object_id VARCHAR2, p_new_daytime DATE) RETURN CALC_SET.CALC_SET_NAME%TYPE;

--

FUNCTION getCalculationPath(p_object_id VARCHAR2, p_daytime DATE, p_separator VARCHAR2 DEFAULT '/') RETURN VARCHAR2;

--

PROCEDURE createDefaultSetImpl(p_operation VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2);

--

FUNCTION getLogProfileName(p_run_no NUMBER) RETURN VARCHAR2;

--
------------------------calcObjAttrFilter---------------------------------------------------------------------------
-- Function       : calcObjAttrFilter
-- Description    : Returns true if should be included
---------------------------------------------------------------------------------------------------
FUNCTION calcObjAttrFilter(
	p_startdate	DATE,                               /* Value of 'startdate' calc engine parameter */
	p_enddate	DATE,                               /* Value of 'enddate' calc engine parameter */
	p_object_type	VARCHAR2,                           /* Value of className */
	p_attr_name	VARCHAR2,                           /* Value of attribute name (sqlSyntax) */
	p_attr_value	VARCHAR2,                       /* Value of attribute */
	p_engineparams	VARCHAR2,                       /* Value of calc engine parameter names semicolon separated */
	p_engineparamvalues    VARCHAR2					/* Value of calc engine parameter values semicolon separated */
	)	RETURN VARCHAR2;							/* return 'Y' for true */

END EcDp_Calculation;