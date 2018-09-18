CREATE OR REPLACE PACKAGE EcDp_Utilities IS
/***********************************************************************************
** Package   :  EcDp_utilities
** $Revision: 1.2 $
**
** Purpose   :  Convenience methods
**
** General Logic:
**
** Created:      06.03.02  Dagfinn Njå
**
**
** Modification history:
**
**
** Date:			Whom:	Change description:
** ----------	-----	----------------------------------------------------------------
** 06.03.2002  DN    Initial version based upon rev. 1.3 of EcDp_Us_Utilities package.
** 17.07.2002  TeJ   Added function executeSinglerowString
** 16.10.2006  SRA   Added generix rounding and compare functions
**************************************************************************************/

FUNCTION isNumber(p_string_repr VARCHAR2) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (isNumber, WNDS, WNPS, RNPS);

FUNCTION executeSinglerowNumber(p_statement varchar2) RETURN NUMBER;
FUNCTION executeSinglerowString(p_statement varchar2) RETURN VARCHAR2;
FUNCTION executeSinglerowDate(p_statement varchar2) RETURN DATE;
FUNCTION executeStatement(p_statement varchar2) RETURN VARCHAR2;

FUNCTION getTagToken(
   p_tagged_string IN OUT VARCHAR2,
   p_find_tag VARCHAR2,
   p_field_sep VARCHAR2,
   p_tag_sep VARCHAR2
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getTagToken, WNDS, WNPS, RNPS);

FUNCTION getNextToken(p_token_string IN OUT VARCHAR2, p_separator VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getNextToken, WNDS, WNPS, RNPS);

FUNCTION getValue(p_in_string VARCHAR2,p_tag_separator VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getValue, WNDS, WNPS, RNPS);

FUNCTION getTag(p_in_string VARCHAR2,p_tag_separator VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getTag, WNDS, WNPS, RNPS);

PROCEDURE GenericRounding(
      p_table_name VARCHAR2,
      p_column_name VARCHAR2,
      p_total_val  NUMBER,
      p_where VARCHAR2
);

FUNCTION isVarcharUpdated(
      p_old VARCHAR2,
      p_new VARCHAR2
) RETURN BOOLEAN;

FUNCTION isDateUpdated(
      p_old DATE,
      p_new DATE
) RETURN BOOLEAN;

FUNCTION isNumberUpdated(
      p_old NUMBER,
      p_new NUMBER
) RETURN BOOLEAN;

END EcDp_Utilities;