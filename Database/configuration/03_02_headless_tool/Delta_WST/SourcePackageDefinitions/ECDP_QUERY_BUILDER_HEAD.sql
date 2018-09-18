CREATE OR REPLACE PACKAGE EcDp_Query_Builder IS

/****************************************************************
** Package        :  EcDp_Query_Builder, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Query Builder data manipulation.
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.04.2009  Hafizan Embong
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------

*****************************************************************/
FUNCTION getAttrDBUnit(p_object_id VARCHAR2, p_class_alias VARCHAR2, p_attr_name VARCHAR2) RETURN VARCHAR2;

PROCEDURE updateFromToAttributes(p_object_id VARCHAR2, p_relation_id VARCHAR2, p_type VARCHAR2, p_from_class VARCHAR2, p_to_class VARCHAR2);

PROCEDURE addRelations(p_class_alias VARCHAR2, p_object_id VARCHAR2);

PROCEDURE removeRelations(p_class_alias VARCHAR2, p_object_id VARCHAR2);

PROCEDURE addColumns(p_class_alias VARCHAR2, p_object_id VARCHAR2);

PROCEDURE removeColumns(p_class_alias VARCHAR2, p_object_id VARCHAR2);

PROCEDURE addDateRelation(p_class_alias VARCHAR2, p_object_id VARCHAR2);

PROCEDURE removeDateRelation(p_class_alias VARCHAR2, p_object_id VARCHAR2);

FUNCTION hasDependency(p_object_id VARCHAR2, p_class_alias VARCHAR2) RETURN VARCHAR2;

END EcDp_Query_Builder;