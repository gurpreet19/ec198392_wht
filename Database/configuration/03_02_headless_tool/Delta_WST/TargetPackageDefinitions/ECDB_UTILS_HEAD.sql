CREATE OR REPLACE PACKAGE EcDB_Utils AS
/**************************************************************
** Package   :  ecdp_utils
** $Revision: 1.5 $
**
** Purpose   :
**
** General Logic:
**
** Created:
**
**
** Modification history:
**
**
** Date:       Whom: Change description:
** ----------  ----- --------------------------------------------
** 2002-0?-??  FBa   Initial version
** 2002-02-15  WBi   Added columnLength function.
** 2002-04-22  DN    Added countKeyColumnConstraints function
** 2002-09-19  TeJ   Added getDataType function.
** 2004-10-06  Av    Added FUNCTION  ConditionNvl (3 version with datatype overloading)
** 2005-03-08  SHN   Added FUNCTION  TruncText
** 2008-06-19  HUS   Added FUNCTION toEcDataType
**************************************************************/

FUNCTION countKeyColumnConstraints(
--   p_owner VARCHAR2,
   p_table_name VARCHAR2,
   p_column_name VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(countKeyColumnConstraints, WNDS, WNPS, RNPS);

FUNCTION existsTableColumn(
   p_table_name   IN VARCHAR2,
   p_column_name  IN VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(existsTableColumn, WNDS, WNPS, RNPS);

FUNCTION columnLength(
   p_table_name   IN VARCHAR2,
   p_column_name  IN VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(columnLength, WNDS, WNPS, RNPS);

FUNCTION getDataType(
   p_object_name   IN VARCHAR2,
   p_column_name  IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getDataType, WNDS, WNPS, RNPS);


FUNCTION  ConditionNvl(p_condition BOOLEAN,p1 VARCHAR2, p2 VARCHAR2)
RETURN VARCHAR2;

FUNCTION  ConditionNvl(p_condition BOOLEAN,p1 DATE, p2 DATE)
RETURN DATE;

FUNCTION  ConditionNvl(p_condition BOOLEAN,p1 NUMBER, p2 NUMBER)
RETURN NUMBER;

FUNCTION TruncText(p_text	VARCHAR2,p_max_length	NUMBER)
RETURN VARCHAR2;

FUNCTION toEcDataType(p_ora_data_type IN VARCHAR2)
RETURN VARCHAR2;

END;