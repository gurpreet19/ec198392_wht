CREATE OR REPLACE PACKAGE BODY EcBp_calc_rule IS
/****************************************************************
** Package        :  EcBp_node_type
**
** $Revision: 1.1 $
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
**
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateCodePrefix
-- Description    : Used to validate prefix on calculation codes
--
-- Preconditions  : p_code
-- Postconditions : Possible unhandled application exceptions
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateCodePrefix(p_code VARCHAR2, p_is_system_code VARCHAR2)
--</EC-DOC>
IS

BEGIN
  if substr(p_code, 1, 3) = 'EC_' and (p_is_system_code is null or p_is_system_code = '' or p_is_system_code = 'N') then
    RAISE_APPLICATION_ERROR(-20268, 'Codes prefixed with EC_ are only allowed for system default');
  end if;
END validateCodePrefix;

END EcBp_calc_rule;