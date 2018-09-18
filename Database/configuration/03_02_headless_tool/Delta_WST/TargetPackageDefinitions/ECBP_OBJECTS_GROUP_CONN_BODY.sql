CREATE OR REPLACE PACKAGE BODY EcBp_Objects_Group_Conn IS

/****************************************************************
** Package        :  EcBp_Objects_Group_Conn, body part
**
** $Revision: 1.11 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 25.05.2007  Sarojini Rajaretnam
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
**  24.06.2008  rajarsar ECPD-6880: Updated validateDeleteObjectGrp,verifyObjectGrp, verifyObjectGrpConn and added checkIfEventOverlaps
**  27.06.2008  farhaann ECPD-8939: Updated ORA number for error messages
**  19.05.2009  sharawan ECPD-10212: Added procedure updateChildEndDate
**  23.07.2009  rajarsar ECPD-11890: Added procedure deleteChild
**  24.07.2009  rajarsar ECPD-11890: Generalised error messages
**  05.08.2009  rajarsar ECPD-11890: Added function findParentFacility
**  11.06.2010  leongsei ECPD-14703: Added function verifyObjectGrpBefore and modified function verifyObjectGrp, updateChildEndDate
**  15.06.2010  oonnnng  ECPD-14704: Added checkSwingWellConn() function and modified verifyObjectGrp() function.
****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateDeleteObjectGrp
-- Description    : This procedure checks if there are child records (Object Group Connection records) before deleting. If there are child records, an error message will be prompted.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : OBJECT_GROUP_CONN
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE validateDeleteObjectGrp(p_object_id VARCHAR2, p_daytime DATE, p_group_type VARCHAR2)

IS
  ln_child_record_count NUMBER;

BEGIN

  ln_child_record_count := 0;

  SELECT COUNT(*)
  INTO ln_child_record_count
  FROM object_group_conn
  WHERE  object_id = p_object_id
  AND parent_start_date = p_daytime
  AND parent_group_type = p_group_type;

  IF p_object_id IS NOT NULL and p_daytime IS NOT NULL and ln_child_record_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20216,'It was attempted to delete a row that has child records. In order to delete this row all child records must be deleted first.');
  END IF;

END validateDeleteObjectGrp;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyObjectGrpBefore
-- Description    :  This procedure checks validity of child and parent period.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : OBJECT_GROUP_CONN
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE verifyObjectGrpBefore(p_object_id VARCHAR2,p_parent_start_date DATE, p_parent_group_type VARCHAR2, p_end_date DATE)

IS
  CURSOR c_validate3 IS
    SELECT object_id, group_type, start_date, end_date
      FROM object_group
     WHERE object_id = p_object_id
       AND group_type = p_parent_group_type
       AND (p_parent_start_date BETWEEN start_date AND Nvl(end_date, SYSDATE)
       OR  p_parent_start_date < (select max(g1.start_date)
                                    FROM object_group g1
                                   WHERE g1.object_id = p_object_id
                                     AND g1.group_type = p_parent_group_type))
       AND start_date <> p_parent_start_date;

BEGIN

  IF p_object_id IS NOT NULL THEN
    FOR cur_Validate3 IN c_validate3 LOOP
      Raise_Application_Error(-20121,'Start Date overlaps with another object group period.');
      Exit;
    END LOOP;

  END IF;

END verifyObjectGrpBefore;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyObjectGrp
-- Description    :  This procedure checks validity of child and parent period.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : OBJECT_GROUP_CONN
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE verifyObjectGrp(p_object_id VARCHAR2,p_parent_start_date DATE, p_parent_group_type VARCHAR2, p_end_date DATE)

IS
  CURSOR c_validate1 IS
    SELECT *
    FROM object_group_conn
    WHERE  object_id = p_object_id
    AND parent_start_date = p_parent_start_date
    AND parent_group_type = p_parent_group_type;

  CURSOR c_validate2 IS
    SELECT COUNT(*) rec_count
      FROM object_group
     WHERE object_id = p_object_id
       AND group_type = p_parent_group_type
       AND start_date > p_parent_start_date
       AND end_date IS NULL;

BEGIN

  IF p_object_id IS NOT NULL THEN
    IF p_end_date IS NOT NULL THEN
      FOR cur_Validate1 IN c_validate1 LOOP
        IF cur_Validate1.end_date IS NOT NULL  AND cur_Validate1.end_date > p_end_date THEN
          Raise_Application_Error(-20217,'End Date must be equal to or after End Date of the child records.');
          Exit;
        END IF;
        IF cur_Validate1.start_date IS NOT NULL AND cur_Validate1.start_date >= p_end_date THEN
          Raise_Application_Error(-20220,'End Date must be after Start Date of the child records.');
          Exit;
        END IF;
      END LOOP;
    END IF;

    FOR cur_Validate2 IN c_validate2 LOOP
      IF cur_Validate2.rec_count > 0 THEN
        Raise_Application_Error(-20232,'There are other Object Group period still active for this object.');
        Exit;
      END IF;
    END LOOP;
  END IF;

  IF p_parent_group_type = 'SWING_WELL' THEN
    FOR cur_object_group_conn IN c_validate1 LOOP
        EcBp_Objects_Group_Conn.checkSwingWellConn(p_object_id, p_parent_start_date, p_parent_group_type, cur_object_group_conn.child_obj_id, cur_object_group_conn.start_date, p_end_date);
    END LOOP;
  END IF;

END verifyObjectGrp;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyObjectGrpConn
-- Description    :  This procedure checks validity of child and parent period.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : OBJECT_GROUP_CONN
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE verifyObjectGrpConn(p_object_id VARCHAR2, p_parent_start_date DATE, p_parent_group_type VARCHAR2, p_daytime DATE, p_end_date DATE)

IS

  CURSOR c_validate1 IS
    SELECT start_date, end_date
    FROM object_group
    WHERE object_id  = p_object_id
    AND group_type = p_parent_group_type
    AND start_date = p_parent_start_date;

BEGIN

    -- Check that the event period are within the period for the parent.
  IF p_object_id IS NOT NULL THEN
    FOR cur_Validate1 IN c_validate1 LOOP
       IF p_daytime IS NOT NULL THEN
         -- check for daytime
         IF (cur_Validate1.start_date > p_daytime ) THEN
           Raise_Application_Error(-20218,'Start Date must be equal to or after Start Date of the parent.');
         END IF;
         IF (cur_Validate1.end_date IS NOT NULL and cur_Validate1.end_date < p_daytime ) THEN
           Raise_Application_Error(-20221,'Start Date must be before End Date of the parent.');
         END IF;
       END IF;

       IF p_end_date IS NOT NULL THEN
         --check for end_date
         IF cur_Validate1.end_date IS NOT NULL and  p_end_date > cur_Validate1.end_date THEN
           Raise_Application_Error(-20219,'End Date must be equal to or before End Date of the parent.');
         END IF;
       END IF;
    END LOOP;
  END IF;

END verifyObjectGrpConn;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :checkIfEventOverlaps
-- Description    : Checks if overlapping event exists.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if overlapping event exists.
--
-- Using tables   : object_group_conn
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  checkIfEventOverlaps(p_object_id VARCHAR2, p_parent_start_date DATE, p_parent_group_type VARCHAR2, p_child_object_id VARCHAR2, p_daytime DATE, p_end_date DATE)
--</EC-DOC>
IS
  -- overlapping period
  CURSOR c_obj_group_conn_insert  IS
    SELECT *
    FROM object_group_conn ogn
    WHERE ogn.child_obj_id = p_child_object_id
    AND ogn.object_id = p_object_id
    AND ogn.parent_group_type = p_parent_group_type
    AND ogn.parent_start_date = p_parent_start_date
    AND ogn.start_date <> p_daytime
    AND (ogn.end_date > p_daytime OR ogn.end_date is null)
    AND (ogn.start_date < p_end_date OR p_end_date IS NULL);

  CURSOR c_obj_group_conn_update  IS
    SELECT *
    FROM object_group_conn ogn1
    WHERE ogn1.child_obj_id = p_child_object_id
    AND ogn1.object_id = p_object_id
    AND ogn1.parent_group_type = p_parent_group_type
    AND ogn1.parent_start_date = p_parent_start_date
    AND ogn1.start_date <> p_daytime
    AND ((ogn1.start_date > p_daytime  AND  (p_end_date is null OR p_end_date > ogn1.start_date))
    OR (ogn1.end_date is null  and p_end_date > ogn1.start_date)
    OR (ogn1.start_date < p_daytime  AND  p_end_date < ogn1.end_date));

  lv_message_insert VARCHAR2(4000);
  lv_message_update VARCHAR2(4000);

BEGIN

  lv_message_insert := null;
  lv_message_update := null;

  FOR  cur_obj_group_conn_insert IN  c_obj_group_conn_insert LOOP
    lv_message_insert := lv_message_insert ||  cur_obj_group_conn_insert.child_obj_id|| ' ';
  END LOOP;

  FOR  cur_obj_group_conn_update IN  c_obj_group_conn_update LOOP
    lv_message_update := lv_message_update ||  cur_obj_group_conn_update.child_obj_id|| ' ';
  END LOOP;

  IF INSERTING THEN
    IF lv_message_insert is not null THEN
      RAISE_APPLICATION_ERROR(-20226, 'An event must not overlaps with existing event period.');
    END IF;
  ELSIF UPDATING THEN
    IF lv_message_update is not null THEN
      RAISE_APPLICATION_ERROR(-20226, 'An event must not overlaps with existing event period.');
    END IF;
  END IF;

END checkIfEventOverlaps;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : updateChildEndDate
-- Description    : This procedure updates end_date column for child records (Object Group Connection records) when end_date in parent record is updated (Object Group records).
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : OBJECT_GROUP_CONN
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE updateChildEndDate(p_object_id VARCHAR2, p_group_type VARCHAR2, p_daytime DATE, p_object_end_date DATE)

IS

BEGIN
  IF p_object_id IS NOT NULL AND p_object_end_date IS NOT NULL THEN
    UPDATE object_group_conn w
       SET w.end_date = p_object_end_date
     WHERE object_id = p_object_id
       AND parent_start_date = p_daytime
       AND parent_group_type = p_group_type
       AND (w.end_date IS NULL
        OR  w.end_date > p_object_end_date);

  END IF;

END updateChildEndDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : deleteChild
-- Description    : This procedure removes a child from the parent in the add to group popup of Collection Object Connection screen.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : OBJECT_GROUP_CONN
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE deleteChild(p_object_id VARCHAR2, p_child_object_id VARCHAR2, p_parent_group_type VARCHAR2, p_daytime DATE)

IS

BEGIN

  DELETE FROM object_group_conn w
   WHERE w.object_id = p_object_id
     AND w.child_obj_id = p_child_object_id
     AND w.start_date = p_daytime
     AND w.parent_group_type = p_parent_group_type;

END deleteChild;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : findParentFacility                                                   --
-- Description    : Returns Parent Facility
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : groups
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION findParentFacility(p_child_object_id         VARCHAR2,
                            p_child_class_name        VARCHAR2,
                            p_daytime                  DATE)
RETURN VARCHAR2 IS
--</EC-DOC>

  lv2_parent VARCHAR2(32);

  CURSOR c_groups IS
    SELECT g.PARENT_OBJECT_NAME FROM TV_GROUPS g
    WHERE g.object_id = p_child_object_id
    AND g.GROUP_TYPE = 'operational'
    AND g.CLASS_NAME = p_child_class_name
    AND g.start_date <= p_daytime AND (g.end_date > p_daytime OR g.end_date IS NULL);

BEGIN

  FOR cur_rec IN c_groups LOOP
    lv2_parent := cur_rec.parent_object_name;
  END LOOP;

  RETURN lv2_parent;

END findParentFacility;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :checkSwingWellConn
-- Description    : Checks if swing well connection event exists.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if existing swing well connection event exists.
--
-- Using tables   : object_group_conn, well_swing_connection
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  checkSwingWellConn(p_object_id VARCHAR2, p_parent_start_date DATE, p_parent_group_type VARCHAR2, p_child_object_id VARCHAR2, p_daytime DATE, p_end_date DATE)
--</EC-DOC>
IS

  CURSOR c_obj_group_conn  IS
  SELECT *
  FROM object_group_conn
  WHERE object_id = p_object_id
  AND parent_group_type = p_parent_group_type
  AND parent_start_date = p_parent_start_date
  AND child_obj_id =  p_child_object_id
  AND start_date = p_daytime;

  CURSOR c_swing_well_conn(cp_object_id VARCHAR2, cp_asset_id VARCHAR2, cp_daytime DATE, cp_end_date DATE) IS
  SELECT *
  FROM well_swing_connection
  WHERE object_id = cp_object_id
  AND asset_id = cp_asset_id
  AND daytime >= cp_daytime
  AND (daytime < cp_end_date OR cp_end_date IS NULL);

  CURSOR c_obj_group_conn2  IS
  SELECT *
  FROM object_group_conn
  WHERE object_id = p_object_id
  AND parent_group_type = p_parent_group_type
  AND parent_start_date = p_parent_start_date
  AND child_obj_id =  p_child_object_id
  AND start_date <> p_daytime;

  CURSOR c_swing_well_conn2 IS
  SELECT *
  FROM well_swing_connection
  WHERE object_id = p_object_id
  AND asset_id = p_child_object_id;

  lv_message_delete VARCHAR2(4000);
  lv_message_update VARCHAR2(4000);
  lv_count NUMBER := 0;
  lv_count2 NUMBER := 0;

BEGIN

  lv_message_delete := null;
  lv_message_update := null;

  IF p_parent_group_type = 'SWING_WELL' THEN

    IF DELETING THEN
      FOR cur_ogc IN  c_obj_group_conn LOOP
        FOR cur_swc in c_swing_well_conn(cur_ogc.object_id, cur_ogc.child_obj_id, cur_ogc.start_date, cur_ogc.end_date) LOOP

          lv_message_delete := lv_message_delete ||  cur_swc.asset_id|| ' ';
        END LOOP;
      END LOOP;

      IF lv_message_delete is not null THEN
        RAISE_APPLICATION_ERROR(-20606, 'A record is overlapping with an existing record ['|| ecdp_objects.GetObjName(p_child_object_id, p_daytime) || '].');
      END IF;
    END IF;

    IF UPDATING THEN
      lv_count  := 0;
      lv_count2 := 0;

      -- Find total swing well record with same Asset ID
      FOR cur_swc2 in c_swing_well_conn2 LOOP
        lv_count := lv_count + 1;
      END LOOP;

      -- Find total swing well record with same Asset ID based on Object Group Conn, excludes the modified Object Group Conn record.
      FOR cur_ogc2 IN  c_obj_group_conn2 LOOP
        FOR cur_swc in c_swing_well_conn(cur_ogc2.object_id, cur_ogc2.child_obj_id, cur_ogc2.start_date, cur_ogc2.end_date) LOOP
          lv_count2 := lv_count2 + 1;
        END LOOP;
      END LOOP;

      -- Find  total swing well record with same Asset ID based on the modified Object Group Conn record with new end_date.
      FOR cur_ogc IN  c_obj_group_conn LOOP
        FOR cur_swc in c_swing_well_conn(cur_ogc.object_id, cur_ogc.child_obj_id, cur_ogc.start_date, p_end_date) LOOP
          lv_count2 := lv_count2 + 1;
        END LOOP;
      END LOOP;

      IF lv_count <> lv_count2 THEN
        RAISE_APPLICATION_ERROR(-20606, 'A record is overlapping with an existing record ['|| ecdp_objects.GetObjName(p_child_object_id, p_daytime) || '].');
      END IF;

    END IF;

  END IF;

END checkSwingWellConn;


END EcBp_Objects_Group_Conn;