CREATE OR REPLACE PACKAGE EcBp_calc_rule IS
/****************************************************************
** Package        :  EcBp_calc_rule
**
** $Revision: 1.2 $
**
** Purpose        :  Provide a means to pass data between triggers to avoid mutating table state
**
** Created  : 01.09.2002  Henning Stokke
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.1.1.2  11.05.2005  Linda Bærheim Copied EcTrgPck_objects_attribute_row and use for node_type table. Only specified columns.
** 1.1.1.3  03.11.2005  Jarle Berge Added prosedure for validation of prefix on calculation codes
** 1.1.1.4  06.12.2005	Jarle Berge renamed package EcTrgPck_node_type to EcBp_node_type
** 1.1.1.5  15.06.2007  Olav Nærland Renamed package to EcBp_calc_rule
*****************************************************************/
TYPE calc_rule_key IS RECORD (calc_id calc_rule.OBJECT_ID%TYPE,daytime calc_rule_version.DAYTIME%TYPE,end_date calc_rule_version.END_DATE%TYPE,calc_context_id calc_rule_version.CALC_CONTEXT_ID%TYPE);
TYPE calc_rule_key_table IS TABLE OF calc_rule_key;
ptab calc_rule_key_table;


PROCEDURE validateCodePrefix(p_code VARCHAR2, p_is_system_code VARCHAR2);

END;