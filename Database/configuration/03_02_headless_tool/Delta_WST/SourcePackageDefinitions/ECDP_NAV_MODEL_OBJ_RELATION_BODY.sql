CREATE OR REPLACE PACKAGE BODY EcDp_nav_model_obj_relation IS
/****************************************************************
** Package        :  EcDp_nav_model_obj_relation, header part
**
** $Revision: 1.12 $
**
** Purpose        :  Maintain persisted group model structure in nav_model_obj_relation
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.08.2007  Arild Vervik
**
** Modification history:
**

** Date     Whom   Change description:
** -------- ------ ------ --------------------------------------
**
*****************************************************************/

  TYPE cv_type IS REF CURSOR;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetClassViewPrefix
-- Description    : Returns prefix to put before queries against class view.
--                  Table classes are not supported in this context.
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION GetClassViewPrefix(
         p_class_name VARCHAR2
) RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_class_type VARCHAR2(32);
  lv2_prefix     VARCHAR2(3);
BEGIN

  lv2_class_type := ec_class_cnfg.class_type(p_class_name);

    IF lv2_class_type = 'OBJECT' THEN
      lv2_prefix := 'ov_';
    ELSIF lv2_class_type = 'DATA' THEN
      lv2_prefix := 'dv_';
    ELSIF lv2_class_type = 'INTERFACE' THEN
      lv2_prefix := 'iv_';
    END IF;

    RETURN lv2_prefix;

END GetClassViewPrefix;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : InsertNavModelObjRelation
-- Description    : Insert entries if it don't exist if it exists increase path_count on row
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE InsertNavModelObjRelation(
                        p_model                VARCHAR2,
                        p_object_id            VARCHAR2,
                        p_ancestor_object_id   VARCHAR2,
                        p_daytime              DATE,
                        p_class_name           VARCHAR2,
                        p_ancestor_class_name  VARCHAR2,
                        p_end_date             DATE
                        )
--</EC-DOC>
IS

CURSOR c_NavModelObjRelation IS
SELECT * FROM nav_model_object_relation
WHERE model = p_model
and   class_name = p_class_name
AND   object_id = p_object_id
AND   ancestor_object_id = p_ancestor_object_id
AND   daytime = p_daytime
;


lb_insert BOOLEAN := TRUE;


BEGIN

  FOR curEntry IN c_NavModelObjRelation LOOP

    UPDATE  nav_model_object_relation
    SET path_count = path_count + 1
    WHERE model = curEntry.model
    AND   class_name = p_class_name
    AND   object_id = curEntry.object_id
    AND   ancestor_object_id = curEntry.ancestor_object_id
    AND   daytime = curEntry.daytime;

    lb_insert := FALSE;

  END LOOP;

  IF lb_insert THEN

    INSERT into NAV_MODEL_OBJECT_RELATION(MODEL,ANCESTOR_CLASS_NAME,CLASS_NAME,OBJECT_ID,
                                          DAYTIME ,END_DATE ,ANCESTOR_OBJECT_ID,PATH_COUNT)
    VALUES(p_MODEL,p_ANCESTOR_CLASS_NAME,p_CLASS_NAME,p_OBJECT_ID,
                                          p_DAYTIME ,p_END_DATE ,p_ANCESTOR_OBJECT_ID,1);


  END IF;


END InsertNavModelObjRelation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : DeleteNavModelObjRelation
-- Description    : Delete entries if path_count = 1, else decrease path_count on row
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE DeleteNavModelObjRelation(
                        p_model                VARCHAR2,
                        p_object_id            VARCHAR2,
                        p_ancestor_object_id   VARCHAR2,
                        p_daytime              DATE
                        )
--</EC-DOC>
IS

CURSOR c_NavModelObjRelation IS
SELECT * FROM nav_model_object_relation
WHERE model = p_model
AND   object_id = p_object_id
AND   ancestor_object_id = p_ancestor_object_id
AND   daytime = p_daytime
;

lb_delete BOOLEAN := TRUE;


BEGIN

  FOR curEntry IN c_NavModelObjRelation LOOP

    IF  curEntry.path_count > 1 THEN

      UPDATE  nav_model_object_relation
      SET path_count = path_count - 1
      WHERE model = curEntry.model
      AND   object_id = curEntry.object_id
      AND   ancestor_object_id = curEntry.ancestor_object_id
      AND   daytime = curEntry.daytime;

      lb_delete := FALSE;

    END IF;

  END LOOP;

  IF lb_delete THEN

    DELETE FROM NAV_MODEL_OBJECT_RELATION
    WHERE MODEL = p_model
    AND   OBJECT_ID = p_object_id
    AND   ANCESTOR_OBJECT_ID = p_ANCESTOR_OBJECT_ID
    AND   DAYTIME = p_daytime;

  END IF;


END DeleteNavModelObjRelation;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : InsertParents
-- Description    : Insert entries above to_object, uses reccursion to traverse the tree
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE InsertParents(p_model VARCHAR2,
                        p_start_class_name VARCHAR2,
                        p_parent_class_name VARCHAR2,
                        p_child_class_name VARCHAR2,
                        p_role_name VARCHAR2,
                        p_object_id VARCHAR2,
                        p_current_id VARCHAR2,
                        p_ancestor_object_id VARCHAR2,
                        p_multiplicity VARCHAR2,
                        p_object_start_date  DATE,
                        p_object_end_date    DATE,
                        p_daytime            DATE,
                        p_end_date           DATE,
                        p_level NUMBER
                        )

--</EC-DOC>
IS

CURSOR c_nav_model(cp_model VARCHAR2, cp_parent_class_name VARCHAR2) IS
SELECT * FROM nav_model
WHERE model = cp_model
AND   TO_CLASS_NAME = cp_parent_class_name
AND NVL(disabled_ind, 'N') = 'N';

  cv cv_type;


lv2_sql          VARCHAR2(32000);
lv2_table_name   VARCHAR2(50);
lv2_column_name  VARCHAR2(50);
ld_daytime       DATE;
ld_end_date      DATE;
lv2_parent       VARCHAR2(50);

BEGIN

  -- First insert direct parent links

  InsertNavModelObjRelation(p_model,p_object_id,p_ancestor_object_id, p_daytime,
                            p_start_class_name,p_parent_class_name,p_end_date);

  -- Must loop all grandparents
  FOR curGP IN c_nav_model(p_model,p_parent_class_name) LOOP

     IF curGP.multiplicity IN ('1:N','1:1') THEN

       lv2_table_name :=  ecdp_classmeta.getClassViewName(curGP.to_class_name);
       lv2_column_name := curGP.role_name||'_ID';

     ELSE  -- curnav.multiplicity IN ('N:1')

       lv2_table_name :=  ecdp_classmeta.getClassViewName(curGP.from_class_name);
       lv2_column_name := curGP.role_name||'_ID';

     END IF;


     lv2_SQL := ' SELECT  daytime, end_date, '|| lv2_column_name ||
                    ' FROM '||lv2_table_name ||' a'||
                    ' WHERE '|| lv2_column_name ||' is not null'||
                    ' AND    OBJECT_ID =  '''|| p_ancestor_object_id ||'''';



       BEGIN
         OPEN cv FOR lv2_sql;
         LOOP
           FETCH cv INTO ld_daytime,ld_end_date,lv2_parent;
           EXIT WHEN cv%NOTFOUND;

           IF p_level < 10 THEN  -- safety_valve in case loop in configuration in NAV_MODEL

               InsertParents(
                          curGP.model,
                          p_start_class_name,
                          curGP.from_class_name,
                          curGP.to_class_name,
                          curGP.role_name,
                          p_object_id,
                          p_ancestor_object_id,
                          lv2_parent,
                          curGP.multiplicity,
                          p_object_start_date,
                          p_object_end_date,
                          p_daytime,
                          p_end_date,
                          p_level+1
                          );

           END IF;

         END LOOP;
         CLOSE cv;
       END;


      END LOOP; -- curGP

END InsertParents;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : DeleteParents
-- Description    : Delete entries above to_object, uses reccursion to traverse the tree
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE DeleteParents(p_model VARCHAR2,
                        p_start_class_name VARCHAR2,
                        p_parent_class_name VARCHAR2,
                        p_child_class_name VARCHAR2,
                        p_role_name VARCHAR2,

                        p_object_id VARCHAR2,
                        p_current_id VARCHAR2,
                        p_ancestor_object_id VARCHAR2,
                        p_multiplicity VARCHAR2,
                        p_object_start_date  DATE,
                        p_object_end_date    DATE,
                        p_daytime            DATE,
                        p_end_date           DATE,
                        p_level NUMBER
                        )

--</EC-DOC>
IS

CURSOR c_nav_model(cp_model VARCHAR2, cp_parent_class_name VARCHAR2) IS
SELECT * FROM nav_model
WHERE model = cp_model
AND   TO_CLASS_NAME = cp_parent_class_name
AND NVL(disabled_ind, 'N') = 'N';

  cv cv_type;


lv2_sql          VARCHAR2(32000);
lv2_table_name   VARCHAR2(50);
lv2_column_name  VARCHAR2(50);
lb_continue      BOOLEAN := TRUE;
ld_daytime       DATE;
ld_end_date      DATE;
lv2_parent       VARCHAR2(50);

BEGIN

  -- First Delete direct parent links

  DeleteNavModelObjRelation(p_model,p_object_id,p_ancestor_object_id, p_daytime);

  -- Must loop all grandparents
  FOR curGP IN c_nav_model(p_model,p_parent_class_name) LOOP

     IF curGP.multiplicity IN ('1:N','1:1') THEN

       lv2_table_name :=  ecdp_classmeta.getClassViewName(curGP.to_class_name);
       lv2_column_name := curGP.role_name||'_ID';

     ELSE  -- curnav.multiplicity IN ('N:1')

       lv2_table_name :=  ecdp_classmeta.getClassViewName(curGP.from_class_name);
       lv2_column_name := curGP.role_name||'_ID';

     END IF;


     IF lb_continue THEN


       -- Build SQL to loop all parent objects


         lv2_SQL := ' SELECT  daytime, end_date, '|| lv2_column_name ||
                    ' FROM '||lv2_table_name ||' a'||
                    ' WHERE '|| lv2_column_name ||' is not null'||
                    ' AND    OBJECT_ID =  '''|| p_ancestor_object_id ||'''';


       BEGIN
         OPEN cv FOR lv2_sql;
         LOOP
           FETCH cv INTO ld_daytime,ld_end_date,lv2_parent;
           EXIT WHEN cv%NOTFOUND;

           IF p_level < 10 THEN  -- safety_valve in case loop in configuration in NAV_MODEL

               DeleteParents(
                          curGP.model,
                          p_start_class_name,
                          curGP.from_class_name,
                          curGP.to_class_name,
                          curGP.role_name,
                          p_object_id,
                          p_ancestor_object_id,
                          lv2_parent,
                          curGP.multiplicity,
                          p_object_start_date,
                          p_object_end_date,
                          p_daytime,
                          p_end_date,
                          p_level+1
                          );

           END IF;

         END LOOP;
         CLOSE cv;
       END;

       END IF;   --lb_continue

      END LOOP; -- curGP

END DeleteParents;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : DeleteChildren
-- Description    : Delete entries below to_object, uses reccursion to traverse the tree
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE DeleteChildren(p_model VARCHAR2,
                         p_start_class_name VARCHAR2,
                         p_start_parent_class_name VARCHAR2,
                         p_object_id VARCHAR2,
                         p_ancestor_object_id VARCHAR2,
                         p_child_class_name VARCHAR2,
                         p_class_name VARCHAR2,
                         p_current_id VARCHAR2,
                         p_multiplicity VARCHAR2,
                         p_level NUMBER
                         )

IS

CURSOR c_nav_model(cp_model VARCHAR2, cp_child_class_name VARCHAR2) IS
SELECT model, from_class_name, to_class_name, multiplicity FROM nav_model
WHERE model = cp_model
AND   FROM_CLASS_NAME = cp_child_class_name
AND NVL(disabled_ind, 'N') = 'N'
;

CURSOR c_NavModelObjRelation(cp_model VARCHAR2, cp_parent_class_name VARCHAR2,
                                      cp_class_name VARCHAR2, cp_ancestor_object_id VARCHAR2)
IS
SELECT model, class_name, object_id, daytime, end_date, ancestor_object_id FROM nav_model_object_relation
WHERE model = cp_model
AND ancestor_class_name = cp_parent_class_name
AND class_name = cp_class_name
AND ancestor_object_id = cp_ancestor_object_id
;


BEGIN

  FOR curC IN c_NavModelObjRelation(p_model, p_class_name, p_child_class_name, p_current_id) LOOP

    ---- For each found direct child, delete parents of the child starting with p_start_parent_class_name with p_ancestor_object_id
    ---- which is the updated grandparent of the child object.
    DeleteParents(curC.model,
                  null,
                  p_start_parent_class_name,
                  null,
                  null,
                  curC.object_id,
                  null,
                  p_ancestor_object_id,
                  p_multiplicity,
                  null,
                  null,
                  curC.daytime,
                  curC.end_date,
                  0
                  );

    ---- Delete the relations between object and its children.
    delete from nav_model_object_relation where model = p_model
         and class_name = curC.class_name and ancestor_class_name = p_start_class_name and ancestor_object_id = p_object_id;

    ---- Must loop all grandchildrens
    IF p_level < 10 THEN
       FOR curGC IN c_nav_model(curC.model, curC.class_name) LOOP
           DeleteChildren(curGC.model,
                          p_start_class_name,
                          p_start_parent_class_name,
                          p_object_id,
                          p_ancestor_object_id,
                          curGC.to_class_name,
                          curGC.from_class_name,
                          curC.object_id,
                          curGC.multiplicity,
                          p_level + 1);

       END LOOP;
    END IF;
  END LOOP;

END DeleteChildren;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : InsertChildren
-- Description    : Insert entries below to_object, uses reccursion to traverse the tree
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE InsertChildren(p_model VARCHAR2,
                         p_start_class_name VARCHAR2,
                         p_start_parent_class_name VARCHAR2,
                         p_child_class_name VARCHAR2,
                         p_class_name VARCHAR2,
                         p_role_name VARCHAR2,
                         p_multiplicity VARCHAR2,
                         p_current_id VARCHAR2,
                         p_object_id VARCHAR2,
                         p_ancestor_object_id VARCHAR2,
                         p_level NUMBER
                         )

--</EC-DOC>
IS

CURSOR c_nav_model(cp_model VARCHAR2, cp_child_class_name VARCHAR2) IS
SELECT model, from_class_name, to_class_name, role_name, multiplicity FROM nav_model
WHERE model = cp_model
AND FROM_CLASS_NAME = cp_child_class_name
AND NVL(disabled_ind, 'N') = 'N';

cv cv_type;

lv2_sql          VARCHAR2(32000);
lv2_table_name   VARCHAR2(50);
lv2_column_name  VARCHAR2(50);
ld_daytime       DATE;
ld_end_date      DATE;
lv2_child        VARCHAR2(50);

BEGIN

     IF p_multiplicity IN ('1:N','1:1') THEN

       lv2_table_name :=  ecdp_classmeta.getClassViewName(p_child_class_name);
       lv2_column_name := p_role_name||'_ID';

     ELSE  -- curnav.multiplicity IN ('N:1')

       lv2_table_name :=  ecdp_classmeta.getClassViewName(p_class_name);
       lv2_column_name := p_role_name||'_ID';

     END IF;


     lv2_SQL := ' SELECT  daytime, end_date, object_id '||
                    ' FROM '||lv2_table_name ||
                    ' WHERE '|| lv2_column_name  || '= ' || '''' || p_current_id || '''';

       BEGIN
         OPEN cv FOR lv2_sql;
         LOOP
           FETCH cv INTO ld_daytime,ld_end_date,lv2_child;
           EXIT WHEN cv%NOTFOUND;
               ---- For each found child object A.child of object A, insert object relations between the A.child and A ;
               InsertNavModelObjRelation(p_model,lv2_child, p_object_id, ld_daytime, p_child_class_name, p_start_class_name, ld_end_date);

               ---- For each found child object A.child of object A, insert object relations between the A.child and A.parents ;
               InsertParents(
                          p_model,
                          p_child_class_name,
                          p_start_parent_class_name,
                          p_child_class_name,
                          p_role_name,
                          lv2_child,
                          null,
                          p_ancestor_object_id,
                          p_multiplicity,
                          null,
                          null,
                          ld_daytime,
                          ld_end_date,
                          0
                          );

           IF p_level < 10 THEN
               FOR curGC IN c_nav_model(p_model, p_child_class_name) LOOP
                   InsertChildren(curGC.model,
                                  p_start_class_name,
                                  p_start_parent_class_name,
                                  curGC.to_class_name,
                                  curGC.from_class_name,
                                  curGC.role_name,
                                  curGC.multiplicity,
                                  lv2_child,
                                  p_object_id,
                                  p_ancestor_object_id,
                                  p_level+1
                                  );
               END LOOP; -- curGC
           END IF;

         END LOOP;
         CLOSE cv;
       END;


END InsertChildren;



PROCEDURE Syncronize_all(p_ignore_error VARCHAR2)

IS

  CURSOR c_nav_model IS
  SELECT * FROM nav_model
  WHERE NVL(disabled_ind, 'N') = 'N';

  CURSOR c_del_cand IS
  SELECT *
    FROM nav_model_object_relation;

  cv cv_type;

  lv2_sql          VARCHAR2(32000);
  lv2_table_name   VARCHAR2(50);
  lv2_column_name  VARCHAR2(50);
  lv2_object_id    VARCHAR2(50);
  ld_daytime       DATE;
  ld_end_date      DATE;
  lv2_parent       VARCHAR2(50);


BEGIN

  -- Delete objects that the current user has access to
  FOR cur_row IN c_del_cand LOOP

    lv2_sql := ' DELETE FROM nav_model_object_relation r ' ||
               '  WHERE EXISTS (SELECT 1 ' ||
               '                  FROM ' || GetClassViewPrefix(cur_row.class_name) || cur_row.class_name || ' o ' ||
               '                 WHERE o.object_id = ''' || cur_row.object_id || '''' ||
               '                   AND o.object_id = r.object_id)';

    EXECUTE IMMEDIATE lv2_sql;

  END LOOP;



  FOR curGP IN c_nav_model LOOP

  -- Populate all parent levels

     IF curGP.multiplicity IN ('1:N','1:1') THEN

       lv2_table_name :=  ecdp_classmeta.getClassViewName(curGP.to_class_name);
       lv2_column_name := curGP.role_name||'_ID';

     ELSE  -- curnav.multiplicity IN ('N:1')

       lv2_table_name :=  ecdp_classmeta.getClassViewName(curGP.from_class_name);
       lv2_column_name := curGP.role_name||'_ID';

     END IF;

     IF lv2_table_name IS NOT NULL AND lv2_column_name IS NOT NULL THEN

     lv2_SQL := ' SELECT  object_id, daytime, end_date, '|| lv2_column_name ||
                ' FROM '||lv2_table_name ||' a'||
                ' WHERE '|| lv2_column_name ||' is not null';


       BEGIN
         OPEN cv FOR lv2_sql;
         LOOP
           FETCH cv INTO lv2_object_id, ld_daytime,ld_end_date,lv2_parent;
           EXIT WHEN cv%NOTFOUND;



           IF curGP.multiplicity IN ('1:N','1:1') THEN

                   InsertParents(
                              curGP.model,
                              curGP.to_class_name,
                              curGP.from_class_name,
                              curGP.to_class_name,
                              curGP.role_name,
                              lv2_object_id,
                              lv2_object_id,
                              lv2_parent,
                              curGP.multiplicity,
                              ld_daytime,
                              ld_end_date,
                              ld_daytime,
                              ld_end_date,
                              0
                              );

           ELSE

                   InsertParents(
                              curGP.model,
                              curGP.to_class_name,
                              curGP.from_class_name,
                              curGP.to_class_name,
                              curGP.role_name,
                              lv2_parent,
                              lv2_parent,
                              lv2_object_id,
                              curGP.multiplicity,
                              ld_daytime,
                              ld_end_date,
                              ld_daytime,
                              ld_end_date,
                              0
                              );


           END IF;



         END LOOP;
         CLOSE cv;

         EXCEPTION
            WHEN OTHERS THEN

             IF Nvl(p_ignore_error,'N') = 'N' THEN

                Raise_Application_Error(-20100,'Refresh failed configuration for '||curGP.from_class_name||'/'||curGP.to_class_name||' '||SQLERRM);

             END IF;




       END;

      ELSE -- Missing configuration

        IF Nvl(p_ignore_error,'N') = 'N' THEN

          Raise_Application_Error(-20100,'Missing navigator configuration for '||curGP.from_class_name||'/'||curGP.to_class_name);

        ELSE
          NULL;  -- Just ignore the error

        END IF;

      END IF;

      END LOOP; -- curGP

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function         : Syncronize_model
-- Description    : Same functionality as synchronize_all except this one allows the user to run for one model only. Less time consuming
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour     :
--
---------------------------------------------------------------------------------------------------
PROCEDURE Syncronize_model(p_model VARCHAR2)

IS
--</EC-DOC>
CURSOR c_nav_model IS
SELECT *
  FROM nav_model
 WHERE model = p_model
 AND NVL(disabled_ind, 'N') = 'N';

CURSOR c_del_cand IS
SELECT *
  FROM nav_model_object_relation
 WHERE model = p_model;

  cv cv_type;

lv2_sql          VARCHAR2(32000);
lv2_table_name   VARCHAR2(50);
lv2_column_name  VARCHAR2(50);
lv2_object_id    VARCHAR2(50);
lb_continue      BOOLEAN := TRUE;
ld_daytime       DATE;
ld_end_date      DATE;
lv2_parent       VARCHAR2(50);


BEGIN

  -- Delete objects that the current user has access to
  FOR cur_row IN c_del_cand LOOP

    lv2_sql := ' DELETE FROM nav_model_object_relation r' ||
               '  WHERE r.model = ''' || p_model || '''' ||
               '    AND EXISTS (SELECT 1 ' ||
               '                  FROM ' || GetClassViewPrefix(cur_row.class_name) || cur_row.class_name || ' o ' ||
               '                 WHERE o.object_id = ''' || cur_row.object_id || '''' ||
               '                   AND o.object_id = r.object_id)';

    EXECUTE IMMEDIATE lv2_sql;

  END LOOP;



  FOR curGP IN c_nav_model LOOP

  -- Populate all parent levels

     IF curGP.multiplicity IN ('1:N','1:1') THEN

       -- Try to find the mapping type and column, because of the N:1 case there is no foreign key
       -- constraint against class_relation, but within this IF clause, it is an error if there is no
       -- entry in class_relation, but do not want to raise an error on this just ignore the wrong config in this case.


       lv2_table_name :=  ecdp_classmeta.getClassViewName(curGP.to_class_name);
       lv2_column_name := curGP.role_name||'_ID';

     ELSE  -- curnav.multiplicity IN ('N:1')

      lv2_table_name :=  ecdp_classmeta.getClassViewName(curGP.from_class_name);
      lv2_column_name := curGP.role_name||'_ID';

     END IF;


     IF lb_continue THEN

         lv2_SQL := ' SELECT  object_id, daytime, end_date, '|| lv2_column_name ||
                    ' FROM '||lv2_table_name ||' a'||
                    ' WHERE '|| lv2_column_name ||' is not null';


       BEGIN
         OPEN cv FOR lv2_sql;
         LOOP
           FETCH cv INTO lv2_object_id, ld_daytime,ld_end_date,lv2_parent;
           EXIT WHEN cv%NOTFOUND;



           IF curGP.multiplicity IN ('1:N','1:1') THEN

                   InsertParents(
                              curGP.model,
                              curGP.to_class_name,
                              curGP.from_class_name,
                              curGP.to_class_name,
                              curGP.role_name,
                              lv2_object_id,
                              lv2_object_id,
                              lv2_parent,
                              curGP.multiplicity,
                              ld_daytime,
                              ld_end_date,
                              ld_daytime,
                              ld_end_date,
                              0
                              );

           ELSE

                   InsertParents(
                              curGP.model,
                              curGP.to_class_name,
                              curGP.from_class_name,
                              curGP.to_class_name,
                              curGP.role_name,
                              lv2_parent,
                              lv2_parent,
                              lv2_object_id,
                              curGP.multiplicity,
                              ld_daytime,
                              ld_end_date,
                              ld_daytime,
                              ld_end_date,
                              0
                              );


           END IF;



         END LOOP;
         CLOSE cv;
       END;

       END IF;   --lb_continue

      END LOOP; -- curGP

END; -- Synchronize_model




PROCEDURE Syncronize(p_operation          VARCHAR2 DEFAULT NULL,
                     p_from_class_name    VARCHAR2 DEFAULT NULL,
                     p_to_class_name      VARCHAR2 DEFAULT NULL,
                     p_role_name          VARCHAR2 DEFAULT NULL,
                     p_new_ref_object_id  VARCHAR2 DEFAULT NULL,
                     p_old_ref_object_id  VARCHAR2 DEFAULT NULL,
                     p_object_id          VARCHAR2 DEFAULT NULL,
                     p_object_start_date  DATE DEFAULT NULL,
                     p_object_end_date    DATE DEFAULT NULL,
                     p_daytime            DATE DEFAULT NULL,
                     p_end_date           DATE DEFAULT NULL,
                     p_ignore_error       VARCHAR2 DEFAULT 'N'
                     )

IS

CURSOR c_nav_model IS
SELECT * FROM nav_model
WHERE from_class_name = Nvl(p_from_class_name, from_class_name)
AND   TO_CLASS_NAME = Nvl(p_to_class_name, to_class_name)
AND   role_name = Nvl(p_role_name,role_name)
AND   NVL(disabled_ind, 'N') = 'N'
union
SELECT n.* FROM nav_model n,class_dependency_cnfg cd
WHERE n.to_class_name = cd.parent_class
and   from_class_name = Nvl(p_from_class_name, from_class_name)
AND   cd.child_class = Nvl(p_to_class_name, to_class_name)
AND   role_name = Nvl(p_role_name,role_name)
AND   NVL(n.disabled_ind, 'N') = 'N'
;

CURSOR c_nav_model_child IS
SELECT model, from_class_name, to_class_name, role_name, multiplicity FROM nav_model
WHERE FROM_CLASS_NAME = Nvl(p_to_class_name, from_class_name)
AND NVL(disabled_ind, 'N') = 'N'
;


lv2_old_ref_object_id varchar2(32);
BEGIN

  -- First check if we have to delete anything
  -- Note this can be a bit tricky because there can be several paths, so an entry can only be deletet
  -- if this path is the only cause of the entry, to keep control of that have a helping column that
  -- counts number of entries.

  IF  p_operation IS NULL THEN -- FULL syncronisation delete everything

      Syncronize_all(p_ignore_error);

  ELSE

      IF p_old_ref_object_id IS NULL THEN
        lv2_old_ref_object_id := p_new_ref_object_id;
      else
        lv2_old_ref_object_id := p_old_ref_object_id;
      end if;

      FOR curC IN c_nav_model_child LOOP

          DeleteChildren(curC.model,
                         p_to_class_name,
                         p_from_class_name,
                         p_object_id,
                         lv2_old_ref_object_id,
                         curC.to_class_name,
                         curC.from_class_name,
                         p_object_id,
                         curC.multiplicity,
                         0
                        );

      END LOOP;

      FOR curDel IN c_nav_model LOOP

         IF curDel.multiplicity IN ('1:N','1:1') THEN

           DeleteParents(curDel.model,
                         curDel.to_class_name,
                         curDel.from_class_name,
                         curDel.to_class_name,
                         curDel.role_name,
                         p_object_id,
                         p_object_id,
                         lv2_old_ref_object_id,
                         curDel.multiplicity,
                         p_object_start_date,
                         p_object_end_date,
                         p_daytime,
                         p_end_date,
                         0);

         ELSE

           DeleteParents(curDel.model,
                         curDel.to_class_name,
                         curDel.from_class_name,
                         curDel.to_class_name,
                         curDel.role_name,
                         lv2_old_ref_object_id,
                         lv2_old_ref_object_id,
                         p_object_id,
                         curDel.multiplicity,
                         p_object_start_date,
                         p_object_end_date,
                         p_daytime,
                         p_end_date,
                         0);

         END IF;

      END LOOP;

    IF p_operation <> 'DELETING' THEN
    FOR curTop IN c_nav_model LOOP

    -- Populate all parent levels

       IF curTop.multiplicity IN ('1:N','1:1') AND p_new_ref_object_id IS NOT NULL THEN

         InsertParents(curTop.model,
                       curTop.to_class_name,
                       curTop.from_class_name,
                       curTop.to_class_name,
                       curTop.role_name,
                       p_object_id,
                       p_object_id,
                       p_new_ref_object_id,
                       curTop.multiplicity,
                       p_object_start_date,
                       p_object_end_date,
                       p_daytime,
                       p_end_date,
                       0);


       ELSIF p_new_ref_object_id IS NOT NULL THEN

         InsertParents(curTop.model,
                       curTop.to_class_name,
                       curTop.from_class_name,
                       curTop.to_class_name,
                       curTop.role_name,
                       p_new_ref_object_id,
                       p_new_ref_object_id,
                       p_object_id,
                       curTop.multiplicity,
                       p_object_start_date,
                       p_object_end_date,
                       p_daytime,
                       p_end_date,
                       0);

       END IF;

    END LOOP;

    IF p_new_ref_object_id IS NOT NULL THEN
       FOR curC IN c_nav_model_child LOOP

       InsertChildren(curC.model,
                   p_to_class_name ,
                   p_from_class_name,
                   curC.to_class_name,
                   curC.from_class_name,
                   curC.role_name,
                   curC.multiplicity,
                   p_object_id,
                   p_object_id,
                   p_new_ref_object_id,
                   0
                   );
       END LOOP;
    END IF;

  END IF;
  END IF;

END;

END;