CREATE OR REPLACE PACKAGE EcDp_Calculation IS
/****************************************************************
** Package        :  EcDp_Calculation, header part
**
** $Revision: 1.14 $
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

PRAGMA RESTRICT_REFERENCES(getEmptyCalculationID, WNDS, WNPS, RNPS);

--

FUNCTION getEmptyCalculationType RETURN CALCULATION.CALC_TYPE%TYPE;

PRAGMA RESTRICT_REFERENCES(getEmptyCalculationType, WNDS, WNPS, RNPS);

--

FUNCTION getEmptyCalculationDaytime RETURN CALCULATION_VERSION.DAYTIME%TYPE;

PRAGMA RESTRICT_REFERENCES(getEmptyCalculationDaytime, WNDS, WNPS, RNPS);

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

PRAGMA RESTRICT_REFERENCES(getSetDefinitionCopyName, WNDS, WNPS, RNPS);

--

FUNCTION getCalculationPath(p_object_id VARCHAR2, p_daytime DATE, p_separator VARCHAR2 DEFAULT '/') RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getCalculationPath, WNDS, WNPS, RNPS);

--

PROCEDURE createDefaultSetImpl(p_operation VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_calc_set_name VARCHAR2);

--

FUNCTION getLogProfileName(p_run_no NUMBER) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getLogProfileName, WNDS, WNPS, RNPS);

--

END EcDp_Calculation;