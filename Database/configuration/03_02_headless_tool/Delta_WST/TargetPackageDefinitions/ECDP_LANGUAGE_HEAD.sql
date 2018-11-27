CREATE OR REPLACE PACKAGE EcDp_Language IS
/****************************************************************
** Package        :  Language, body part
**
** $Revision: 1.2 $
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
** 1.2      2011-02-22   Dagfinn Rosnes     Added translateByPropLang to support user language lookup directly.
*****************************************************************/

FUNCTION translate (p_source_string VARCHAR2, p_language VARCHAR2)
RETURN VARCHAR2;

FUNCTION translateByPropLang(p_source_string VARCHAR2,
                             p_user_id VARCHAR2 DEFAULT NULL,
                             p_prop_key VARCHAR2 DEFAULT '/com/ec/eccore/locale/language')
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (translate, WNDS, WNPS, RNPS);

END EcDp_Language;