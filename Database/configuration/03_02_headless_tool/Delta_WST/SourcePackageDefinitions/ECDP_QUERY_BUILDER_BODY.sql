CREATE OR REPLACE PACKAGE BODY EcDp_Query_Builder IS
/****************************************************************
** Package        :  EcDp_Query_Builder, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Query Builder data manipulation.
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.04.2009  Hafizan Embong
**
** Modification history:
**
** Date       Whom    Change description:
** --------   -----   --------------------------------------

*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAttrDBUnit
-- Description    : Get the attribute DB unit.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAttrDBUnit(p_object_id VARCHAR2,
                       p_class_alias VARCHAR2,
                       p_attr_name VARCHAR2
) RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_class_name IS
      SELECT rep_class_name
      FROM qb_class
      WHERE object_id=p_object_id and class_alias=p_class_alias;

lv2_class_name VARCHAR2(100);
lv2_db_unit VARCHAR2(16);

BEGIN

	 FOR cur_class_name IN c_class_name LOOP
			lv2_class_name := cur_class_name.rep_class_name;
	 END LOOP;

   lv2_db_unit := ecdp_unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv2_class_name,p_attr_name));

	 return lv2_db_unit;

END getAttrDBUnit;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : updateFromToAttributes
-- Description  :
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: QB_OBJ_RELATION
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateFromToAttributes(
	p_object_id     VARCHAR2,
 	p_relation_id	VARCHAR2,
	p_type	VARCHAR2,
	p_from_class	VARCHAR2,
	p_to_class	VARCHAR2)

IS

BEGIN

	IF p_type = 'CLASS_RELATION' THEN

		UPDATE qb_obj_relation SET from_attr = 'OBJECT_ID', to_attr = p_relation_id||'_ID' WHERE object_id = p_object_id AND relation_id = p_relation_id AND from_class_alias = p_from_class AND to_class_alias = p_to_class;

	ELSIF p_type = 'OWNER' THEN

		UPDATE qb_obj_relation SET from_attr = 'OBJECT_ID', to_attr = 'OBJECT_ID' WHERE object_id = p_object_id AND from_class_alias = p_from_class AND to_class_alias = p_to_class;

	END IF;

END updateFromToAttributes;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : addRelations
-- Description  :	Adds owner or class releastions for newly added class
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: QB_OBJ_RELATION
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE addRelations(p_class_alias VARCHAR2, p_object_id VARCHAR2)

IS
	-- is owner
	CURSOR c_isowner (cp_class_name VARCHAR2, cp_object_id VARCHAR2) IS
		select qc.rep_class_name, qc.class_alias
		  from qb_class qc, class_cnfg c
		 where qc.object_id = cp_object_id
		   and qc.rep_class_name != cp_class_name
		   and class_name = qc.rep_class_name
		   and c.owner_class_name = cp_class_name
		   and qc.class_alias not in (select r.to_class_alias
										from qb_obj_relation r, qb_class qb
									   where r.from_class_alias = qb.class_alias
										 and qb.rep_class_name = cp_class_name
										 and r.type = 'OWNER');
	-- has owner
	CURSOR c_hasowner (cp_class_name VARCHAR2, cp_object_id VARCHAR2) IS
		select qc.rep_class_name, qc.class_alias
		  from qb_class qc, class_cnfg c
		 where qc.object_id = cp_object_id
		   and qc.rep_class_name != cp_class_name
		   and c.owner_class_name = qc.rep_class_name
		   and c.class_name = cp_class_name
		   and qc.class_alias not in (select r.from_class_alias
										from qb_obj_relation r, qb_class qb
									   where r.to_class_alias = qb.class_alias
										 and qb.rep_class_name = cp_class_name
										 and r.type = 'OWNER');

	-- has class relation
	CURSOR c_has_from_rel (cp_class_name VARCHAR2, cp_object_id VARCHAR2) IS
		select qc.rep_class_name, qc.class_alias, r.role_name, r.db_sql_syntax
		  from qb_class qc, class_relation_cnfg r
		 where qc.object_id = cp_object_id
		   and qc.rep_class_name != cp_class_name
		   and r.from_class_name = qc.rep_class_name
		   and r.to_class_name = cp_class_name
		   and EcDp_ClassMeta_Cnfg.isDisabled(r.from_class_name, r.to_class_name, r.role_name) != 'Y'
		   and qc.class_alias not in (select r.from_class_alias
										from qb_obj_relation r, qb_class qb
									   where r.to_class_alias = qb.class_alias
										 and qb.rep_class_name = cp_class_name
										 and r.type = 'CLASS_RELATION');

	-- has class relation
	CURSOR c_has_to_rel (cp_class_name VARCHAR2, cp_object_id VARCHAR2) IS
		select qc.rep_class_name, qc.class_alias, r.role_name, r.db_sql_syntax
		  from qb_class qc, class_relation_cnfg r
		 where qc.object_id = cp_object_id
		   and qc.rep_class_name != cp_class_name
		   and r.to_class_name = qc.rep_class_name
		   and r.from_class_name = cp_class_name
		   and EcDp_ClassMeta_Cnfg.isDisabled(r.from_class_name, r.to_class_name, r.role_name) != 'Y'
		   and qc.class_alias not in (select r.to_class_alias
										from qb_obj_relation r, qb_class qb
									   where r.from_class_alias = qb.class_alias
										 and qb.rep_class_name = cp_class_name
										 and r.type = 'CLASS_RELATION');

	lv_class_name	VARCHAR2(32);

BEGIN
	lv_class_name := ec_qb_class.rep_class_name(p_object_id, p_class_alias);

	-- Test if new class is owner to existing classes
	FOR cur_Owner IN c_isowner(lv_class_name, p_object_id) LOOP
		INSERT INTO QB_OBJ_RELATION (OBJECT_ID, FROM_CLASS_ALIAS, TO_CLASS_ALIAS, TYPE, FROM_ATTR, TO_ATTR)
		VALUES (p_object_id, p_class_alias, cur_Owner.class_alias, 'OWNER', 'OBJECT_ID', 'OBJECT_ID');
	END LOOP;

	-- Test if new class has any of the existing classes as owner
	FOR cur_Owner IN c_hasowner(lv_class_name, p_object_id) LOOP
		INSERT INTO QB_OBJ_RELATION (OBJECT_ID, FROM_CLASS_ALIAS, TO_CLASS_ALIAS, TYPE, FROM_ATTR, TO_ATTR)
		VALUES (p_object_id, cur_Owner.class_alias, p_class_alias, 'OWNER', 'OBJECT_ID', 'OBJECT_ID');
	END LOOP;

	-- Test if new class has any of the existing classes as from relation
	FOR cur_rel IN c_has_from_rel(lv_class_name, p_object_id) LOOP
		INSERT INTO QB_OBJ_RELATION (OBJECT_ID, FROM_CLASS_ALIAS, TO_CLASS_ALIAS, TYPE, RELATION_ID, FROM_ATTR, TO_ATTR)
		VALUES (p_object_id, cur_rel.class_alias, p_class_alias, 'CLASS_RELATION', cur_rel.role_name, 'OBJECT_ID', cur_rel.db_sql_syntax);
	END LOOP;

	-- Test if new class has any of the existing classes as to relation
	FOR cur_rel IN c_has_to_rel(lv_class_name, p_object_id) LOOP
		INSERT INTO QB_OBJ_RELATION (OBJECT_ID, FROM_CLASS_ALIAS, TO_CLASS_ALIAS, TYPE, RELATION_ID, FROM_ATTR, TO_ATTR)
		VALUES (p_object_id, p_class_alias, cur_rel.class_alias, 'CLASS_RELATION', cur_rel.role_name, 'OBJECT_ID', cur_rel.db_sql_syntax);
	END LOOP;

END addRelations;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : removeRelations
-- Description  : Remove relations that is no longer needed when class is deleted
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables	: QB_OBJ_RELATION
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE removeRelations(p_class_alias VARCHAR2, p_object_id VARCHAR2)

IS

BEGIN

	-- delete owner/class relations
	delete QB_OBJ_RELATION r
	where (r.from_class_alias = p_class_alias or r.to_class_alias = p_class_alias)
	and	r.object_id = p_object_id
	and r.type IN ('OWNER', 'CLASS_RELATION');


END removeRelations;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : addColumns
-- Description  :	Adds columns for newly added class
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: QB_COLUMN
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE addColumns(p_class_alias VARCHAR2, p_object_id VARCHAR2)

IS
	CURSOR c_attr (cp_class_name VARCHAR2) IS
		select a.attribute_name from class_attribute_cnfg a
		where a.class_name = cp_class_name
		and EcDp_ClassMeta_Cnfg.isDisabled(a.class_name, a.attribute_name) = 'N';


	lv_class_name	VARCHAR2(32);

BEGIN
	lv_class_name := ec_qb_class.rep_class_name(p_object_id, p_class_alias);

	FOR cur_attr IN c_attr(lv_class_name) LOOP
		INSERT INTO QB_COLUMN (OBJECT_ID, CLASS_ALIAS, ATTRIBUTE_NAME)
		VALUES (p_object_id, p_class_alias, cur_attr.attribute_name);
	END LOOP;

END addColumns;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : removeColumns
-- Description  : Remove columns that is no longer needed when class is deleted
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables	: QB_COLUMN
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE removeColumns(p_class_alias VARCHAR2, p_object_id VARCHAR2)

IS

BEGIN

	DELETE QB_COLUMN
	WHERE OBJECT_ID = p_object_id AND CLASS_ALIAS = p_class_alias;


END removeColumns;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : addDateRelation
-- Description  : Add default date relations for inserted class
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: qb_date_relation
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE addDateRelation(p_class_alias VARCHAR2, p_object_id VARCHAR2)

IS
	lv_class_name	VARCHAR2(32);
	lv_date_handling VARCHAR2(64);

BEGIN
	lv_class_name := ec_qb_class.rep_class_name(p_object_id, p_class_alias);

	SELECT date_handeling INTO lv_date_handling from v_dao_meta where class_name = lv_class_name and rownum = 1;

	IF lv_date_handling = 'OBJECT' THEN
		INSERT INTO qb_date_relation
			(CLASS_ALIAS, DATE_HANDLING_TYPE, FROM_FIELD, TO_FIELD, OBJECT_ID)
		VALUES
			(p_class_alias, 'OBJECT', 'DAYTIME', 'END_DATE', p_object_id);
	ELSIF lv_date_handling = 'DAYTIME_ONLY' THEN
		INSERT INTO qb_date_relation
			(CLASS_ALIAS, DATE_HANDLING_TYPE, FROM_FIELD, OBJECT_ID)
		VALUES
			(p_class_alias, 'EXACT_MATCH', 'DAYTIME', p_object_id);
	ELSIF lv_date_handling = 'DAYTIME_PERIOD' THEN
		INSERT INTO qb_date_relation
			(CLASS_ALIAS, DATE_HANDLING_TYPE, FROM_FIELD, TO_FIELD, OBJECT_ID)
		VALUES
			(p_class_alias, 'EXACT_MATCH', 'DAYTIME', 'END_DATE', p_object_id);
	END IF;


END addDateRelation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : removeDateRelation
-- Description  : delete date relations for deleted class
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables	: qb_date_relation
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE removeDateRelation(p_class_alias VARCHAR2, p_object_id VARCHAR2)

IS

BEGIN

	DELETE qb_date_relation
	WHERE OBJECT_ID = p_object_id AND CLASS_ALIAS = p_class_alias;


END removeDateRelation;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : hasDependency
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION hasDependency(p_object_id VARCHAR2,
                       p_class_alias VARCHAR2
) RETURN VARCHAR2
--</EC-DOC>
IS

	CURSOR c_rel (cp_class_name VARCHAR2, cp_object_id VARCHAR2) IS
		select r.from_class_alias, r.to_class_alias
		from qb_obj_relation r
		where object_id = cp_object_id
		and (r.from_class_alias = cp_class_name or r.to_class_alias = cp_class_name);


	CURSOR c_col (cp_class_name VARCHAR2, cp_object_id VARCHAR2) IS
		select r.attribute_name
		from qb_column r
		where object_id = cp_object_id
		and r.class_alias = cp_class_name;

	CURSOR c_date (cp_class_name VARCHAR2, cp_object_id VARCHAR2) IS
		select d.driving_class_alias
		from qb_date_handling d
		where d.object_id = cp_object_id
		and d.driving_class_alias = cp_class_name;

	lv_hasDependency	VARCHAR2(1)	:=	'N';

BEGIN
	FOR cur_rel IN c_rel(p_class_alias, p_object_id) LOOP
		lv_hasDependency := 'Y';
	END LOOP;

	FOR cur_col IN c_col(p_class_alias, p_object_id) LOOP
		lv_hasDependency := 'Y';
	END LOOP;

	FOR cur_date IN c_date(p_class_alias, p_object_id) LOOP
		lv_hasDependency := 'Y';
	END LOOP;

	 return lv_hasDependency;

END hasDependency;

END EcDp_Query_Builder;