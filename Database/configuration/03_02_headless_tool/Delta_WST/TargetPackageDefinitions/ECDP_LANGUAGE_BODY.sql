CREATE OR REPLACE PACKAGE BODY EcDp_Language IS
/****************************************************************
** Package        :  Language, body part
**
** $Revision: 1.4 $
**
** Purpose        : Translate strings to different laguages.
**
**
**
** Documentation  :
**
** Created        :  04.05.2004  Egil Ølberg
**
** Modification history:
**
** Version  Date         Whom               Change description:
** -------  ----------   ------------------ --------------------------------------
** 1.4      2011-02-22   Dagfinn Rosnes     Added translateByPropLang to support user language lookup directly.
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : translate                                                                    --
-- Description    : Returns the translated string.                                               --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : T_BASIS_LANGUAGE, T_BASIS_LANGUAGE_SOURCE, T_BASIS_LANGUAGE_TARGET           --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Returns translated string if translation is found.                           --
--                  Otherwise, the original string is returned                                   --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION translate(p_source_string VARCHAR2, p_language VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_language IS
SELECT	t.target_text
FROM	t_basis_language l,
	t_basis_language_source s,
	t_basis_language_target t
WHERE 	s.source_text = p_source_string
AND	s.source_id = t.source_id
AND	t.language_id = l.language_id
AND	l.language = p_language
UNION
SELECT	'*'||t.target_text
FROM	t_basis_language l,
	t_basis_language_source s,
	t_basis_language_target t
WHERE 	'*'||s.source_text = p_source_string
AND	s.source_id = t.source_id
AND	t.language_id = l.language_id
AND	l.language = p_language;

lv2_retval VARCHAR2(2000);

BEGIN

	lv2_retval := p_source_string;

	FOR cur_language IN c_language LOOP
		lv2_retval := cur_language.target_text;
	END LOOP;

	RETURN lv2_retval;

END translate;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION translateByPropLang(p_source_string VARCHAR2,
                             p_user_id VARCHAR2 DEFAULT NULL,
                             p_prop_key VARCHAR2 DEFAULT '/com/ec/eccore/locale/language')
RETURN VARCHAR2
IS
BEGIN

  RETURN translate(p_source_string, ecdp_ctrl_property.getUserProperty(p_prop_key, p_user_id));

END translateByPropLang;

END EcDp_Language;