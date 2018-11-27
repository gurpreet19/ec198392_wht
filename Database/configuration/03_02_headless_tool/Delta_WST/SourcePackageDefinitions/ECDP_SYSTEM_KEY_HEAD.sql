CREATE OR REPLACE PACKAGE EcDp_System_key IS
/****************************************************************
** Package        :  EcDp_System_key, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Provide system key numbers
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.04.2000  Dagfinn Nj�
**
** Modification history:
**
** Date       Whom  Change description:
** --------   ----- --------------------------------------
** 20040219   DN    Added assignNextNumber. Moved from EcDp_System.
*****************************************************************/

PROCEDURE assignNextNumber(p_table_name VARCHAR2, po_next_number OUT NUMBER, p_auto_commit BOOLEAN DEFAULT TRUE);

FUNCTION assignNextNumber(p_table_name VARCHAR2) RETURN NUMBER;

FUNCTION assignNextNumberNonAutonomous(p_table_name VARCHAR2) RETURN NUMBER;

FUNCTION assignNextKeyValue(p_table_name VARCHAR2) RETURN NUMBER;


FUNCTION showLatestKeyValue RETURN NUMBER;


FUNCTION showNextKeyValue RETURN NUMBER;

--

PROCEDURE resetNextNumber(p_table_name VARCHAR2, p_next_number NUMBER);

FUNCTION AssignNextUniqueNumber (p_table_name VARCHAR2,  p_column_name VARCHAR2 ,p_code VARCHAR2 ) RETURN NUMBER;

END EcDp_System_key;