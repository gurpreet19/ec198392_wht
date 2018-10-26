CREATE OR REPLACE PACKAGE EcDp_System_key IS
/****************************************************************
** Package        :  EcDp_System_key, header part
**
** $Revision: 1.4.32.1 $
**
** Purpose        :  Provide system key numbers
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.04.2000  Dagfinn Njå
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

PRAGMA RESTRICT_REFERENCES(assignNextKeyValue, WNDS, WNPS, RNPS);


FUNCTION showLatestKeyValue RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(showLatestKeyValue, WNDS, WNPS, RNPS);


FUNCTION showNextKeyValue RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(showNextKeyValue, WNDS, WNPS, RNPS);

--

PROCEDURE resetNextNumber(p_table_name VARCHAR2, p_next_number NUMBER);

FUNCTION AssignNextUniqueNumber (p_table_name VARCHAR2,  p_column_name VARCHAR2 ,p_code VARCHAR2 ) RETURN NUMBER;

END EcDp_System_key;