CREATE OR REPLACE package body EcDp_Class_Validation is
/****************************************************************
** Package        :  EcDp_Class_Validation, body part
**
** $Revision: 1.13 $
**
** Purpose        :  Provide special procedures to create new version of classes/objects and delete the existing version of classes/objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.03.2006  SeongKok
**
** Modification history:
**
** Date       Whom  Change description:
** ---------- ----- --------------------------------------
** 23.03.07     Seongkok    Added two new methods newVersionObject and deleteVersionObject
** 11.09.07     embonhaf   ECPD-6481 added nvl check for is_mandatory value
** 03.05.2010   oonnnng    ECPD-14276: Added getClassAttributeViewLabelHead() function.
** 18.05.2010   oonnnng    ECPD-14541: Added addMissingAttrClass() and addMissingAttrObject() function.
*****************************************************************/
CURSOR c_updateable_cols (p_class_name IN VARCHAR2) IS
SELECT dm.class_name, dm.property_name
  FROM dao_meta dm
 WHERE dm.class_name = p_class_name
   AND NVL(upper(dm.is_key),'N') != 'Y'
   AND upper(NVL(dm.is_mandatory, 'N')) != 'Y'
   AND upper(dm.db_mapping_type) != 'FUNCTION'
   AND lower(dm.attributes) NOT LIKE '%viewhidden=true%'
   AND dm.property_name not in (SELECT cr.role_name FROM class_relation cr where cr.to_class_name=dm.class_name)
 ORDER BY sort_order;

CURSOR c_updateable_numeric_cols (p_class_name IN VARCHAR2) IS
SELECT dm.class_name, dm.property_name
  FROM dao_meta dm
 WHERE dm.class_name = p_class_name
   AND NVL(upper(dm.is_key),'N') != 'Y'
   AND upper(dm.db_mapping_type) != 'FUNCTION'
   AND lower(dm.attributes) NOT LIKE '%viewhidden=true%'
   AND dm.property_name not in (SELECT cr.role_name FROM class_relation cr where cr.to_class_name=dm.class_name)
   AND ( upper(dm.data_type) = 'NUMBER' OR upper(dm.data_type) = 'INTEGER')
 ORDER BY sort_order;

CURSOR c_isExistClassAttrEditable(p_class_name VARCHAR2) IS
  SELECT COUNT(*) cnt
  FROM class_attribute ca, class_attr_editable cae
  WHERE ca.class_name = p_class_name
  AND ca.class_name = cae.class_name;

CURSOR c_isExistClassAttrValidation(p_class_name VARCHAR2) IS
  SELECT COUNT(*) cnt
  FROM class_attribute ca, class_attr_validation cav
  WHERE ca.class_name = p_class_name
  AND ca.class_name = cav.class_name;

CURSOR c_isExistObjectAttrEditable(p_class_name VARCHAR2, p_object_id VARCHAR2) IS
  SELECT COUNT(*) cnt
  FROM class_attribute ca, object_attr_editable oae
  WHERE ca.class_name = p_class_name
  AND ca.class_name = oae.class_name
  AND oae.object_id = p_object_id;

CURSOR c_isExistObjectAttrValidation(p_class_name VARCHAR2, p_object_id VARCHAR2) IS
  SELECT COUNT(*) cnt
  FROM class_attribute ca, object_attr_validation oav
  WHERE ca.class_name = p_class_name
  AND ca.class_name = oav.class_name
  AND oav.object_id = p_object_id;

CURSOR c_prevClassAttrEditable(p_class_name VARCHAR2, p_daytime DATE) IS
  SELECT cae.*
  FROM class_attribute ca, class_attr_editable cae
  WHERE ca.class_name = p_class_name
  AND ca.class_name = cae.class_name
  AND ca.attribute_name = cae.attribute_name
  AND cae.daytime = (SELECT MAX(cae2.daytime)
                        FROM class_attr_editable cae2
                        WHERE cae2.daytime <= p_daytime
                        AND cae2.class_name = ca.class_name
                        AND cae2.attribute_name = ca.attribute_name);

CURSOR c_nextClassAttrEditable(p_class_name VARCHAR2, p_daytime DATE) IS
  SELECT cae.*
  FROM class_attribute ca, class_attr_editable cae
  WHERE ca.class_name = p_class_name
  AND ca.class_name = cae.class_name
  AND ca.attribute_name = cae.attribute_name
  AND cae.daytime = (SELECT MIN(cae2.daytime)
                        FROM class_attr_editable cae2
                        WHERE cae2.daytime > p_daytime
                        AND cae2.class_name = ca.class_name
                        AND cae2.attribute_name = ca.attribute_name);

CURSOR c_prevObjectAttrEditable(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) IS
  SELECT oae.*
  FROM class_attribute ca, object_attr_editable oae
  WHERE ca.class_name = p_class_name
  AND ca.class_name = oae.class_name
  AND oae.object_id = p_object_id
  AND ca.attribute_name = oae.attribute_name
  AND oae.daytime = (SELECT MAX(oae2.daytime)
                        FROM object_attr_editable oae2
                        WHERE oae2.daytime <= p_daytime
                        AND oae2.class_name = ca.class_name
                        AND oae2.object_id = p_object_id
                        AND oae2.attribute_name = ca.attribute_name);

CURSOR c_nextObjectAttrEditable(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) IS
  SELECT oae.*
  FROM class_attribute ca, object_attr_editable oae
  WHERE ca.class_name = p_class_name
  AND ca.class_name = oae.class_name
  AND oae.object_id = p_object_id
  AND ca.attribute_name = oae.attribute_name
  AND oae.daytime = (SELECT MIN(oae2.daytime)
                        FROM object_attr_editable oae2
                        WHERE oae2.daytime > p_daytime
                        AND oae2.class_name = ca.class_name
                        AND oae2.object_id = p_object_id
                        AND oae2.attribute_name = ca.attribute_name);

CURSOR c_prevClassAttrValidation(p_class_name VARCHAR2, p_daytime DATE) IS
  SELECT cav.*
  FROM class_attribute ca, class_attr_validation cav
  WHERE ca.class_name = p_class_name
  AND ca.class_name = cav.class_name
  AND ca.attribute_name = cav.attribute_name
  AND cav.daytime = (SELECT MAX(cav2.daytime)
                        FROM class_attr_validation cav2
                        WHERE cav2.daytime <= p_daytime
                        AND cav2.class_name = ca.class_name
                        AND cav2.attribute_name = ca.attribute_name);

CURSOR c_nextClassAttrValidation(p_class_name VARCHAR2, p_daytime DATE) IS
  SELECT cav.*
  FROM class_attribute ca, class_attr_validation cav
  WHERE ca.class_name = p_class_name
  AND ca.class_name = cav.class_name
  AND ca.attribute_name = cav.attribute_name
  AND cav.daytime = (SELECT MIN(cav2.daytime)
                        FROM class_attr_validation cav2
                        WHERE cav2.daytime > p_daytime
                        AND cav2.class_name = ca.class_name
                        AND cav2.attribute_name = ca.attribute_name);

CURSOR c_prevObjectAttrValidation(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) IS
  SELECT oav.*
  FROM class_attribute ca, object_attr_validation oav
  WHERE ca.class_name = p_class_name
  AND ca.class_name = oav.class_name
  AND oav.object_id = p_object_id
  AND ca.attribute_name = oav.attribute_name
  AND oav.daytime = (SELECT MAX(oav2.daytime)
                        FROM object_attr_validation oav2
                        WHERE oav2.daytime <= p_daytime
                        AND oav2.class_name = ca.class_name
                        AND oav2.object_id = p_object_id
                        AND oav2.attribute_name = ca.attribute_name);

CURSOR c_nextObjectAttrValidation(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) IS
  SELECT oav.*
  FROM class_attribute ca, object_attr_validation oav
  WHERE ca.class_name = p_class_name
  AND ca.class_name = oav.class_name
  AND oav.object_id = p_object_id
  AND ca.attribute_name = oav.attribute_name
  AND oav.daytime = (SELECT MIN(oav2.daytime)
                        FROM object_attr_validation oav2
                        WHERE oav2.daytime > p_daytime
                        AND oav2.class_name = ca.class_name
                        AND oav2.object_id = p_object_id
                        AND oav2.attribute_name = ca.attribute_name);


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : newVersionClass
-- Description    : Creates new version of classes
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS, CLASS_ATTR_EDITABLE, CLASS_ATTR_VALIDATOIN
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
   PROCEDURE newVersionClass (
     p_class_name VARCHAR2,
     p_daytime DATE,
     p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
   IS
    ld_end_date DATE;
    ln_count INTEGER := 0;

    BEGIN
        FOR c_exist_edit IN c_isExistClassAttrEditable(p_class_name) LOOP
            IF c_exist_edit.cnt=0 THEN
               FOR c_Col in c_updateable_cols(p_class_name) LOOP
                   INSERT INTO class_attr_editable (class_name,attribute_name,daytime,last_updated_by)
                   VALUES (c_Col.class_name, c_Col.property_name, p_daytime, p_user);
               END LOOP;
            ELSE
              ln_count := 0;
              FOR cEditable IN c_prevClassAttrEditable(p_class_name, p_daytime) LOOP

                  INSERT INTO class_attr_editable (class_name,attribute_name,daytime,not_editable_ind,last_updated_by)
                  VALUES (cEditable.class_name, cEditable.attribute_name, p_daytime, cEditable.not_editable_ind, p_user);
                  -- Set end_date on previous record
                  UPDATE class_attr_editable SET end_date = p_daytime
                  WHERE class_name = cEditable.class_name
                  AND attribute_name = cEditable.attribute_name
                  AND daytime = cEditable.daytime;

                  FOR ncEditable IN c_nextClassAttrEditable(p_class_name, p_daytime) LOOP
                      UPDATE class_attr_editable SET end_date = ncEditable.daytime
                      WHERE class_name = p_class_name
                      AND attribute_name = ncEditable.attribute_name
                      AND daytime = p_daytime;
                  END LOOP;
                  ln_count := ln_count + 1;
              END LOOP;

              IF ln_count=0 THEN
                  -- New version is before first version
                  FOR ncEditable IN c_nextClassAttrEditable(p_class_name, p_daytime) LOOP
                      INSERT INTO class_attr_editable (class_name,attribute_name,daytime,end_date,last_updated_by)
                      VALUES (ncEditable.class_name, ncEditable.attribute_name, p_daytime, ncEditable.daytime, p_user);
                  END LOOP;
              END IF;

            END IF;
        END LOOP;

        FOR c_exist_valid in c_isExistClassAttrValidation(p_class_name) LOOP
            IF c_exist_valid.cnt=0 THEN
               FOR c_Col_num in c_updateable_numeric_cols(p_class_name) LOOP
                   INSERT INTO class_attr_validation (class_name, attribute_name, daytime, last_updated_by)
                   VALUES (c_Col_num.class_name, c_Col_num.property_name, p_daytime, p_user);
               END LOOP;
            ELSE
                ln_count := 0;
                FOR cValidation IN c_prevClassAttrValidation(p_class_name, p_daytime) LOOP
                    -- EcDp_DynSql.WriteTemptext('3','before insert into validation');
                    INSERT INTO class_attr_validation (class_name, attribute_name, daytime, warn_min, warn_max, warn_pct, err_min, err_max, err_mandatory_ind, last_updated_by)
                    VALUES (cValidation.class_name, cValidation.attribute_name, p_daytime, cValidation.warn_min, cValidation.warn_max, cValidation.warn_pct, cValidation.err_min, cValidation.err_max, cValidation.err_mandatory_ind, p_user);
                    -- EcDp_DynSql.WriteTemptext('4','after insert into validation');
                    -- Set end_date on previous record
                    UPDATE class_attr_validation SET end_date = p_daytime
                    WHERE class_name = cValidation.class_name
                    AND attribute_name = cValidation.attribute_name
                    AND daytime = cValidation.daytime;

                    FOR ncValidation IN c_nextClassAttrValidation(p_class_name, p_daytime) LOOP
                        UPDATE class_attr_validation SET end_date = ncValidation.daytime
                        WHERE class_name = p_class_name
                        AND attribute_name = ncValidation.attribute_name
                        AND daytime = p_daytime;
                    END LOOP;
                    ln_count := ln_count + 1;
                END LOOP;

                IF ln_count=0 THEN
                    -- New version is before first version
                    FOR ncValidation IN c_nextClassAttrValidation(p_class_name, p_daytime) LOOP
                        INSERT INTO class_attr_validation (class_name, attribute_name, daytime, end_date, last_updated_by)
                        VALUES (ncValidation.class_name, ncValidation.attribute_name, p_daytime, ncValidation.daytime, p_user);
                    END LOOP;
                END IF;

            END IF;
         END LOOP;

    END newVersionClass;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : deleteVersionClass
-- Description    : Deletes selected version of classes
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS, CLASS_ATTR_EDITABLE, CLASS_ATTR_VALIDATOIN
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
  PROCEDURE deleteVersionClass (
   p_class_name VARCHAR2,
   p_daytime DATE)
--</EC-DOC>
   IS

    ld_next_end_date DATE;

    BEGIN

        DELETE FROM class_attr_editable WHERE class_name=p_class_name and daytime=p_daytime;

        ld_next_end_date := NULL;
        FOR ncEditable IN c_nextClassAttrEditable(p_class_name, p_daytime) LOOP
             ld_next_end_date := ncEditable.daytime;
             EXIT;
        END LOOP;

        FOR pcEditable IN c_prevClassAttrEditable(p_class_name, p_daytime) LOOP
            UPDATE class_attr_editable SET end_date = ld_next_end_date
            WHERE class_name = pcEditable.class_name
            AND attribute_name = pcEditable.attribute_name
            AND daytime = pcEditable.daytime;
        END LOOP;


        DELETE FROM class_attr_validation WHERE class_name=p_class_name and daytime=p_daytime;

        ld_next_end_date := NULL;
        FOR ncValidation IN c_nextClassAttrValidation(p_class_name, p_daytime) LOOP
            ld_next_end_date := ncValidation.daytime;
            EXIT;
        END LOOP;

        FOR pcValidation IN c_prevClassAttrValidation(p_class_name, p_daytime) LOOP
            UPDATE class_attr_validation SET end_date = ld_next_end_date
            WHERE class_name = pcValidation.class_name
            AND attribute_name = pcValidation.attribute_name
            AND daytime = pcValidation.daytime;
        END LOOP;

    END deleteVersionClass;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : newVersionObject
-- Description    : Creates new version of objects
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS, OBJECT_ATTR_EDITABLE, OBJECT_ATTR_VALIDATOIN
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
   PROCEDURE newVersionObject (
     p_class_name VARCHAR2,
     p_object_id  VARCHAR2,
     p_daytime DATE,
     p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
   IS
    ld_end_date DATE;
    ln_count INTEGER := 0;

    BEGIN
      --IF Ecdp_Objects.IsValidObjStartDate(p_object_id, p_daytime)='Y' AND Ecdp_Objects.IsValidObjEndDate(p_object_id, p_daytime)='Y' THEN
          FOR c_exist_edit IN c_isExistObjectAttrEditable(p_class_name, p_object_id) LOOP
              IF c_exist_edit.cnt=0 THEN
                 FOR c_Col in c_updateable_cols(p_class_name) LOOP
                     INSERT INTO object_attr_editable (class_name,object_id,attribute_name,daytime,last_updated_by)
                     VALUES (c_Col.class_name, p_object_id, c_Col.property_name, p_daytime, p_user);
                 END LOOP;
              ELSE
                ln_count := 0;
                FOR cEditable IN c_prevObjectAttrEditable(p_class_name, p_object_id, p_daytime) LOOP

                    INSERT INTO object_attr_editable (class_name,object_id,attribute_name,daytime,not_editable_ind,last_updated_by)
                    VALUES (cEditable.class_name, p_object_id, cEditable.attribute_name, p_daytime, cEditable.not_editable_ind, p_user);
                    -- Set end_date on previous record
                    UPDATE object_attr_editable SET end_date = p_daytime
                    WHERE class_name = cEditable.class_name
                    AND object_id = cEditable.object_id
                    AND attribute_name = cEditable.attribute_name
                    AND daytime = cEditable.daytime;

                    FOR ncEditable IN c_nextObjectAttrEditable(p_class_name, p_object_id, p_daytime) LOOP
                        UPDATE object_attr_editable SET end_date = ncEditable.daytime
                        WHERE class_name = p_class_name
                        AND object_id = p_object_id
                        AND attribute_name = ncEditable.attribute_name
                        AND daytime = p_daytime;
                    END LOOP;
                    ln_count := ln_count + 1;
                END LOOP;

                IF ln_count=0 THEN
                    -- New version is before first version
                    FOR ncEditable IN c_nextObjectAttrEditable(p_class_name, p_object_id, p_daytime) LOOP
                        INSERT INTO object_attr_editable (class_name,object_id,attribute_name,daytime,end_date,last_updated_by)
                        VALUES (ncEditable.class_name, p_object_id, ncEditable.attribute_name, p_daytime, ncEditable.daytime,p_user);
                    END LOOP;
                END IF;

              END IF;
          END LOOP;

          FOR c_exist_valid in c_isExistObjectAttrValidation(p_class_name, p_object_id) LOOP
              IF c_exist_valid.cnt=0 THEN
                 FOR c_Col_num in c_updateable_numeric_cols(p_class_name) LOOP
                     INSERT INTO object_attr_validation (class_name, object_id, attribute_name, daytime, last_updated_by)
                     VALUES (c_Col_num.class_name, p_object_id, c_Col_num.property_name, p_daytime, p_user);
                 END LOOP;
              ELSE
                  ln_count := 0;
                  FOR cValidation IN c_prevObjectAttrValidation(p_class_name, p_object_id, p_daytime) LOOP
                      -- EcDp_DynSql.WriteTemptext('3','before insert into validation');
                      INSERT INTO object_attr_validation (class_name, object_id, attribute_name, daytime, warn_min, warn_max, warn_pct, err_min, err_max, err_mandatory_ind, last_updated_by)
                      VALUES (cValidation.class_name, p_object_id, cValidation.attribute_name, p_daytime, cValidation.warn_min, cValidation.warn_max, cValidation.warn_pct, cValidation.err_min, cValidation.err_max, cValidation.err_mandatory_ind, p_user);
                      -- EcDp_DynSql.WriteTemptext('4','after insert into validation');
                      -- Set end_date on previous record
                      UPDATE object_attr_validation SET end_date = p_daytime
                      WHERE class_name = cValidation.class_name
                      AND object_id = cValidation.object_id
                      AND attribute_name = cValidation.attribute_name
                      AND daytime = cValidation.daytime;

                      FOR ncValidation IN c_nextObjectAttrValidation(p_class_name, p_object_id, p_daytime) LOOP
                          UPDATE object_attr_validation SET end_date = ncValidation.daytime
                          WHERE class_name = p_class_name
                          AND object_id = p_object_id
                          AND attribute_name = ncValidation.attribute_name
                          AND daytime = p_daytime;
                      END LOOP;
                      ln_count := ln_count + 1;
                  END LOOP;

                  IF ln_count=0 THEN
                      -- New version is before first version
                      FOR ncValidation IN c_nextObjectAttrValidation(p_class_name, p_object_id, p_daytime) LOOP
                          INSERT INTO object_attr_validation (class_name, object_id, attribute_name, daytime, end_date, last_updated_by)
                          VALUES (ncValidation.class_name, p_object_id, ncValidation.attribute_name, p_daytime, ncValidation.daytime, p_user);
                      END LOOP;
                  END IF;

              END IF;
           END LOOP;
        --END IF;

    END newVersionObject;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : deleteVersionObject
-- Description    : Deletes selected version of objects
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS, OBJECT_ATTR_EDITABLE, OBJECT_ATTR_VALIDATOIN
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
  PROCEDURE deleteVersionObject (
   p_class_name VARCHAR2,
   p_object_id VARCHAR2,
   p_daytime DATE)
--</EC-DOC>
   IS

    ld_next_end_date DATE;

    BEGIN

        DELETE FROM object_attr_editable WHERE class_name=p_class_name and object_id=p_object_id and daytime=p_daytime;

        ld_next_end_date := NULL;
        FOR ncEditable IN c_nextObjectAttrEditable(p_class_name, p_object_id, p_daytime) LOOP
             ld_next_end_date := ncEditable.daytime;
             EXIT;
        END LOOP;

        FOR pcEditable IN c_prevObjectAttrEditable(p_class_name, p_object_id, p_daytime) LOOP
            UPDATE object_attr_editable SET end_date = ld_next_end_date
            WHERE class_name = pcEditable.class_name
            AND object_id = pcEditable.object_id
            AND attribute_name = pcEditable.attribute_name
            AND daytime = pcEditable.daytime;
        END LOOP;


        DELETE FROM object_attr_validation WHERE class_name=p_class_name and object_id=p_object_id and daytime=p_daytime;

        ld_next_end_date := NULL;
        FOR ncValidation IN c_nextObjectAttrValidation(p_class_name, p_object_id, p_daytime) LOOP
            ld_next_end_date := ncValidation.daytime;
            EXIT;
        END LOOP;

        FOR pcValidation IN c_prevObjectAttrValidation(p_class_name, p_object_id, p_daytime) LOOP
            UPDATE object_attr_validation SET end_date = ld_next_end_date
            WHERE class_name = pcValidation.class_name
            AND object_id = pcValidation.object_id
            AND attribute_name = pcValidation.attribute_name
            AND daytime = pcValidation.daytime;
        END LOOP;
    END deleteVersionObject;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyValidation
-- Description    : Copy object validation
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJECT_ATTR_EDITABLE, OBJECT_ATTR_VALIDATION
--
-- Using functions:
--
-- Configuration
-- required       : p_copy_from <-- copy from which object_id
--                  p_copy_to <-- copy to which object_id
--                  p_from_daytime <-- copy from which version of the copy from
--                  p_to_daytime <-- new version in which the object_id created with
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
   procedure copyValidation(
   p_copy_from varchar2,
   p_copy_to   varchar2,
   p_from_daytime   date,
   p_to_daytime date)
--</EC-DOC>
   IS
    TYPE t_attr_editable IS TABLE OF object_attr_editable%ROWTYPE;
    l_editable t_attr_editable;

    TYPE t_attr_validation IS TABLE OF object_attr_validation%ROWTYPE;
    l_validation t_attr_validation;

   CURSOR c_attr_editable IS
     SELECT * FROM object_attr_editable
       WHERE object_id = p_copy_from
       AND daytime = p_from_daytime;

   CURSOR c_attr_validation IS
     SELECT * FROM object_attr_validation
       WHERE object_id = p_copy_from
       AND daytime = p_from_daytime;

   BEGIN
    -- do not allow copy to self
    IF p_copy_from = p_copy_to AND p_from_daytime = p_to_daytime THEN
      RETURN;
    END IF;

    -- delete validations for currecnt version if any
    delete object_attr_editable where object_id=p_copy_to and daytime=p_to_daytime;
    delete object_attr_validation where object_id=p_copy_to and daytime=p_to_daytime;

    -- handle object_attr_editable
    OPEN c_attr_editable;
    LOOP
    FETCH c_attr_editable BULK COLLECT INTO l_editable LIMIT 400;

      FOR i IN 1..l_editable.COUNT LOOP
        l_editable(i).object_id := p_copy_to;
        l_editable(i).daytime := p_to_daytime;
        l_editable(i).record_status := null;
        l_editable(i).created_by := null;
        l_editable(i).created_date := null;
        l_editable(i).last_updated_by := null;
        l_editable(i).last_updated_date := null;
        l_editable(i).rev_no := null;
        l_editable(i).rev_text := 'Created by Copy Validation at '||to_char(sysdate,'yyyy.mm.dd hh24:mi:ss');
        l_editable(i).approval_by := null;
        l_editable(i).approval_date := null;
        l_editable(i).approval_state := null;
        l_editable(i).rec_id := null;
      END LOOP;

      FORALL i IN 1..l_editable.COUNT
      INSERT INTO object_attr_editable VALUES l_editable(i);

      EXIT WHEN c_attr_editable%NOTFOUND;
    END LOOP;
    CLOSE c_attr_editable;

    -- handle object_attr_validation
    OPEN c_attr_validation;
    LOOP
    FETCH c_attr_validation BULK COLLECT INTO l_validation LIMIT 400;

      FOR i IN 1..l_validation.COUNT LOOP
        l_validation(i).object_id := p_copy_to;
        l_validation(i).daytime := p_to_daytime;
        l_validation(i).record_status := null;
        l_validation(i).created_by := null;
        l_validation(i).created_date := null;
        l_validation(i).last_updated_by := null;
        l_validation(i).last_updated_date := null;
        l_validation(i).rev_no := null;
        l_validation(i).rev_text := 'Created by Copy Validation at '||to_char(sysdate,'yyyy.mm.dd hh24:mi:ss');
        l_validation(i).approval_by := null;
        l_validation(i).approval_date := null;
        l_validation(i).approval_state := null;
        l_validation(i).rec_id := null;
      END LOOP;

      FORALL i IN 1..l_validation.COUNT
      INSERT INTO object_attr_validation VALUES l_validation(i);

      EXIT WHEN c_attr_validation%NOTFOUND;
    END LOOP;
    CLOSE c_attr_validation;

   END copyValidation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getClassAttributeViewLabelHead
-- Description    : Used for retrieve the viewlabelhead value
--
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
FUNCTION getClassAttributeViewLabelHead(
         p_class_name class_attr_presentation.class_name%TYPE,
         p_attribute_name class_attr_presentation.attribute_name%TYPE)
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_viewlabelhead VARCHAR2(200) := NULL;
  lv2_result VARCHAR2(200) := NULL;

  -- Cursor used for retrieve the viewlabelhead
  CURSOR cur_viewlabelhead (cp_class_name VARCHAR2, cp_attribute_name VARCHAR2) IS
  SELECT t.static_presentation_syntax,
  -- find viewlabel head
  instr(static_presentation_syntax, 'viewlabelhead') start_pos1,
  -- create sub string from start of view label head
  substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')) sub,

  -- find first = sign
  instr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')), '=') start_pos2,
  -- create sub string after =
  substr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')),instr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')), '=')+1) sub2,

  -- find end by finding ;, if 0 end of line
  instr(substr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')),instr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')), '=')+1), ';') end1,
  -- find end by finding ;, if 0 end of line
  decode(instr(substr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')),instr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')), '=')+1), ';'), 0, length(t.static_presentation_syntax), instr(substr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')),instr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')), '=')+1), ';')-1)  end2,

  -- final sql
  substr(t.static_presentation_syntax,
         instr(static_presentation_syntax, 'viewlabelhead') + instr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')), '='),
         decode(instr(substr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')),instr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')), '=')+1), ';'), 0, length(t.static_presentation_syntax), instr(substr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')),instr(substr(static_presentation_syntax, instr(static_presentation_syntax, 'viewlabelhead')), '=')+1), ';')-1)) final_sql

  FROM class_attr_presentation t
  WHERE t.static_presentation_syntax like '%viewlabelhead%'
  AND t.class_name = cp_class_name
  AND t.attribute_name = cp_attribute_name;

BEGIN

   FOR c IN cur_viewlabelhead (p_class_name, p_attribute_name) LOOP
     lv2_viewlabelhead := TRIM(c.final_sql);
   END LOOP;

   lv2_result := CASE
                 WHEN lv2_viewlabelhead IS NOT NULL THEN lv2_viewlabelhead || ' '
                 ELSE ''
                 END;

   RETURN lv2_result;

END getClassAttributeViewLabelHead;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : addMissingAttrClass
-- Description    : Add missing attributes of classes
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_ATTR_EDITABLE, CLASS_ATTR_VALIDATION, DAO_META
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
   PROCEDURE addMissingAttrClass (
     p_class_name VARCHAR2,
     p_daytime DATE,
     p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
   IS
    ld_end_date DATE;

    CURSOR c_missingClassAttrEdit (cp_class_name IN VARCHAR2, cp_daytime DATE) IS
    SELECT dm.class_name, dm.property_name
    FROM dao_meta dm
    WHERE dm.class_name = cp_class_name
    AND NVL(upper(dm.is_key),'N') != 'Y'
    AND upper(NVL(dm.is_mandatory, 'N')) != 'Y'
    AND lower(dm.attributes) NOT LIKE '%viewhidden=true%'
    AND dm.property_name not in (SELECT cr.role_name FROM class_relation cr where cr.to_class_name=dm.class_name)
    MINUS
    SELECT cae.class_name, cae.attribute_name
    FROM class_attr_editable cae
    WHERE cae.class_name = cp_class_name
    AND daytime = cp_daytime;

    CURSOR c_isExistClassAttrEdit(cp_class_name VARCHAR2, cp_daytime DATE) IS
    SELECT COUNT(*) cnt
    FROM class_attribute ca, class_attr_editable cae
    WHERE ca.class_name = cp_class_name
    AND ca.class_name = cae.class_name
    AND cae.daytime = cp_daytime;

    CURSOR c_classAttrEditEndDate(cp_class_name VARCHAR2, cp_daytime DATE) IS
    SELECT UNIQUE end_date
    FROM class_attribute ca, class_attr_editable cae
    WHERE ca.class_name = cp_class_name
    AND ca.class_name = cae.class_name
    AND cae.daytime = cp_daytime;

    CURSOR c_missingClassAttrValid (cp_class_name IN VARCHAR2, cp_daytime DATE) IS
    SELECT dm.class_name, dm.property_name
    FROM dao_meta dm
    WHERE dm.class_name = cp_class_name
    AND NVL(upper(dm.is_key),'N') != 'Y'
    AND lower(dm.attributes) NOT LIKE '%viewhidden=true%'
    AND dm.property_name not in (SELECT cr.role_name FROM class_relation cr where cr.to_class_name=dm.class_name)
    AND ( upper(dm.data_type) = 'NUMBER' OR upper(dm.data_type) = 'INTEGER')
    MINUS
    SELECT cav.class_name, cav.attribute_name
    FROM class_attr_validation cav
    WHERE cav.class_name = cp_class_name
    AND daytime = cp_daytime;

    CURSOR c_isExistClassAttrValid(cp_class_name VARCHAR2, cp_daytime DATE) IS
    SELECT COUNT(*) cnt
    FROM class_attribute ca, class_attr_validation cav
    WHERE ca.class_name = cp_class_name
    AND ca.class_name = cav.class_name
    AND cav.daytime = cp_daytime;

    CURSOR c_classAttrValidEndDate(cp_class_name VARCHAR2, cp_daytime DATE) IS
    SELECT UNIQUE end_date
    FROM class_attribute ca, class_attr_validation cav
    WHERE ca.class_name = cp_class_name
    AND ca.class_name = cav.class_name
    AND cav.daytime = cp_daytime;

    BEGIN
        FOR c_exist_edit IN c_isExistClassAttrEdit(p_class_name, p_daytime) LOOP
            IF c_exist_edit.cnt > 0 THEN
               FOR c_daytime in c_classAttrEditEndDate(p_class_name, p_daytime) LOOP
                   ld_end_date := c_daytime.end_date;
               END LOOP;

               FOR c_Col in c_missingClassAttrEdit(p_class_name, p_daytime) LOOP
                   INSERT INTO class_attr_editable (class_name,attribute_name,daytime, end_date, last_updated_by)
                   VALUES (c_Col.class_name, c_Col.property_name, p_daytime, ld_end_date, p_user);
               END LOOP;
            END IF;
        END LOOP;

        FOR c_exist_edit IN c_isExistClassAttrValid(p_class_name, p_daytime) LOOP
            IF c_exist_edit.cnt > 0 THEN
               FOR c_daytime in c_classAttrValidEndDate(p_class_name, p_daytime) LOOP
                   ld_end_date := c_daytime.end_date;
               END LOOP;

               FOR c_Col in c_missingClassAttrValid(p_class_name, p_daytime) LOOP
                   INSERT INTO class_attr_validation (class_name,attribute_name,daytime, end_date, last_updated_by)
                   VALUES (c_Col.class_name, c_Col.property_name, p_daytime, ld_end_date, p_user);
               END LOOP;
            END IF;
        END LOOP;

    END addMissingAttrClass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : addMissingAttrObject
-- Description    : Add missing attributes of classes
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : OBJECT_ATTR_EDITABLE, OBJECT_ATTR_VALIDATION, DAO_META
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
   PROCEDURE addMissingAttrObject (
     p_class_name VARCHAR2,
     p_object_id  VARCHAR2,
     p_daytime DATE,
     p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
   IS
    ld_end_date DATE;

    CURSOR c_missingObjectAttrEdit (cp_class_name IN VARCHAR2, cp_daytime DATE, cp_object_id VARCHAR2) IS
    SELECT dm.class_name, dm.property_name
    FROM dao_meta dm
    WHERE dm.class_name = cp_class_name
    AND NVL(upper(dm.is_key),'N') != 'Y'
    AND upper(NVL(dm.is_mandatory, 'N')) != 'Y'
    AND lower(dm.attributes) NOT LIKE '%viewhidden=true%'
    AND dm.property_name not in (SELECT cr.role_name FROM class_relation cr where cr.to_class_name=dm.class_name)
    MINUS
    SELECT oae.class_name, oae.attribute_name
    FROM object_attr_editable oae
    WHERE oae.class_name = cp_class_name
    AND daytime = cp_daytime
    AND object_id = cp_object_id;

    CURSOR c_isExistObjectAttrEdit(cp_class_name VARCHAR2, cp_daytime DATE, cp_object_id VARCHAR2) IS
    SELECT COUNT(*) cnt
    FROM class_attribute ca, object_attr_editable oae
    WHERE ca.class_name = cp_class_name
    AND ca.class_name = oae.class_name
    AND oae.daytime = cp_daytime
    AND object_id = cp_object_id;

    CURSOR c_objectAttrEditEndDate(cp_class_name VARCHAR2, cp_daytime DATE, cp_object_id VARCHAR2) IS
    SELECT UNIQUE end_date
    FROM class_attribute ca, object_attr_editable oae
    WHERE ca.class_name = cp_class_name
    AND ca.class_name = oae.class_name
    AND oae.daytime = cp_daytime
    AND object_id = cp_object_id;

    CURSOR c_missingObjectAttrValid (cp_class_name IN VARCHAR2, cp_daytime DATE, cp_object_id VARCHAR2) IS
    SELECT dm.class_name, dm.property_name
    FROM dao_meta dm
    WHERE dm.class_name = cp_class_name
    AND NVL(upper(dm.is_key),'N') != 'Y'
    AND upper(NVL(dm.is_mandatory, 'N')) != 'Y'
    AND lower(dm.attributes) NOT LIKE '%viewhidden=true%'
    AND dm.property_name not in (SELECT cr.role_name FROM class_relation cr where cr.to_class_name=dm.class_name)
    AND ( upper(dm.data_type) = 'NUMBER' OR upper(dm.data_type) = 'INTEGER')
    MINUS
    SELECT oav.class_name, oav.attribute_name
    FROM object_attr_validation oav
    WHERE oav.class_name = cp_class_name
    AND daytime = cp_daytime
    AND object_id = cp_object_id;

    CURSOR c_isExistObjectAttrValid(cp_class_name VARCHAR2, cp_daytime DATE, cp_object_id VARCHAR2) IS
    SELECT COUNT(*) cnt
    FROM class_attribute ca, object_attr_validation oav
    WHERE ca.class_name = cp_class_name
    AND ca.class_name = oav.class_name
    AND oav.daytime = cp_daytime
    AND object_id = cp_object_id;

    CURSOR c_objectAttrValidEndDate(cp_class_name VARCHAR2, cp_daytime DATE, cp_object_id VARCHAR2) IS
    SELECT UNIQUE end_date
    FROM class_attribute ca, object_attr_validation oav
    WHERE ca.class_name = cp_class_name
    AND ca.class_name = oav.class_name
    AND oav.daytime = cp_daytime
    AND object_id = cp_object_id;

    BEGIN
        FOR c_exist_edit IN c_isExistObjectAttrEdit(p_class_name, p_daytime, p_object_id) LOOP
            IF c_exist_edit.cnt > 0 THEN
               FOR c_daytime in c_objectAttrEditEndDate(p_class_name, p_daytime, p_object_id) LOOP
                   ld_end_date := c_daytime.end_date;
               END LOOP;

               FOR c_Col in c_missingObjectAttrEdit(p_class_name, p_daytime, p_object_id) LOOP
                   INSERT INTO object_attr_editable (class_name, object_id, attribute_name,daytime, end_date, last_updated_by)
                   VALUES (c_Col.class_name, p_object_id, c_Col.property_name, p_daytime, ld_end_date, p_user);
               END LOOP;
            END IF;
        END LOOP;

        FOR c_exist_edit IN c_isExistObjectAttrValid(p_class_name, p_daytime, p_object_id) LOOP
            IF c_exist_edit.cnt > 0 THEN
               FOR c_daytime in c_objectAttrValidEndDate(p_class_name, p_daytime, p_object_id) LOOP
                   ld_end_date := c_daytime.end_date;
               END LOOP;

               FOR c_Col in c_missingObjectAttrValid(p_class_name, p_daytime, p_object_id) LOOP
                   INSERT INTO object_attr_validation (class_name, object_id, attribute_name, daytime, end_date, last_updated_by)
                   VALUES (c_Col.class_name, p_object_id, c_Col.property_name, p_daytime, ld_end_date, p_user);
               END LOOP;
            END IF;
        END LOOP;

    END addMissingAttrObject;

end EcDp_Class_Validation;