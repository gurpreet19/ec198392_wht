CREATE OR REPLACE PACKAGE BODY EcDp_Deferment_Log IS

/****************************************************************
** Package        :  EcDp_Deferment_Log, body part
**
** $Revision: 1.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Deferment.Logs
** Documentation  :  www.energy-components.com
**
** Created  : 04.10.2018  mehtajig
**
** Modification history:
**
** Version  Date       Whom     Change description:
** -------  ----------  -------- ----------------
****************************************************************************************/

PROCEDURE getStartEndDate(p_object_id VARCHAR2 DEFAULT NULL,p_nav_group_type VARCHAR2 DEFAULT NULL,p_nav_parent_class_name VARCHAR2 DEFAULT NULL,p_deferment_version VARCHAR2 DEFAULT NULL, p_from_date OUT DATE, p_to_date OUT DATE) IS
  -- Query the TEMP_WELL_DEFERMEMT_ALLOC table for all admendments on deferment_event table for all IUD actions
  CURSOR c_temp_alloc_recs IS
  SELECT min(LEAST(a.new_daytime, NVL(a.old_daytime, a.new_daytime))) daytime,
         max(GREATEST(a.new_end_date, NVL(a.old_end_date, a.new_end_date))) end_date
  FROM TEMP_WELL_DEFERMENT_ALLOC a;

  -- exclude the deferments belonged to fcty_class_2 when fcty_class_1 being used to calculate deferments
  -- exclude the deferments belonged to operator_route when collection_point being used to calculate deferments
  CURSOR c1_temp_alloc_recs_object_id (cp_nav_group_type VARCHAR2, cp_parent_classname VARCHAR2, cp_grandparent_classname VARCHAR2 ) IS
  SELECT min(LEAST(a.new_daytime, NVL(a.old_daytime, a.new_daytime))) daytime,
         max(GREATEST(a.new_end_date, NVL(a.old_end_date, a.new_end_date))) end_date
  FROM TEMP_WELL_DEFERMENT_ALLOC a
  WHERE a.event_no IN
    (SELECT b.event_no
     FROM deferment_event  b
     WHERE ((b.object_id=p_object_id AND b.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD'))
     OR b.parent_object_id=p_object_id
     OR p_object_id=ecgp_group.findParentObjectId(cp_nav_group_type,
                                                  cp_parent_classname,
                                                  'WELL',
                                                  b.OBJECT_ID,
                                                  b.DAYTIME)
     OR (b.parent_object_id IN (SELECT o.OBJECT_ID
                                FROM EQPM_VERSION oa
                                INNER JOIN EQUIPMENT o ON o.object_id = oa.object_id
                                AND (oa.OP_FCTY_CLASS_1_ID = p_object_id OR
                                     oa.CP_COL_POINT_ID = p_object_id)
                                AND oa.DAYTIME  <= b.DAYTIME
                                AND NVL(oa.END_DATE, NVL(b.END_DATE,b.daytime)+1) >= NVL(b.END_DATE, b.DAYTIME+1)
                                )
        ))
	AND event_no in (select event_no from TEMP_WELL_DEFERMENT_ALLOC)
    )
     AND a.event_no NOT IN
    (SELECT c.event_no
     FROM deferment_event  c
     WHERE (ecdp_objects.GetObjClassName(c.parent_object_id) = cp_grandparent_classname
     AND ecdp_objects.GetObjClassName(p_object_id) = cp_parent_classname
     AND p_object_id=ecgp_group.findParentObjectId(cp_nav_group_type,
                                                   cp_parent_classname,
                                                   'WELL',
                                                   c.OBJECT_ID,
                                                   c.DAYTIME)
     AND c.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD'))
	AND event_no in (select event_no from TEMP_WELL_DEFERMENT_ALLOC)
    );

  CURSOR c2_temp_alloc_recs_object_id (cp_nav_group_type VARCHAR2, cp_parent_classname VARCHAR2 ) IS
  SELECT min(LEAST(a.new_daytime, NVL(a.old_daytime, a.new_daytime))) daytime,
         max(GREATEST(a.new_end_date, NVL(a.old_end_date, a.new_end_date))) end_date
  FROM TEMP_WELL_DEFERMENT_ALLOC a
  WHERE a.event_no IN
    (SELECT b.event_no
     FROM deferment_event  b
     WHERE ((b.object_id=p_object_id AND b.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD'))
     OR b.parent_object_id=p_object_id
     OR p_object_id=ecgp_group.findParentObjectId(cp_nav_group_type,
                                                  cp_parent_classname,
                                                  'WELL',
                                                  b.OBJECT_ID,
                                                  b.DAYTIME)
     OR (b.parent_object_id IN (SELECT o.OBJECT_ID
                                FROM EQPM_VERSION oa
                                INNER JOIN EQUIPMENT o ON o.object_id = oa.object_id
                                AND (oa.OP_FCTY_CLASS_1_ID = p_object_id OR
                                     oa.CP_COL_POINT_ID = p_object_id)
                                AND oa.DAYTIME  <= b.DAYTIME
                                AND NVL(oa.END_DATE, NVL(b.END_DATE,b.daytime)+1) >= NVL(b.END_DATE, b.DAYTIME+1)
                                )
        ))
	AND event_no in (select event_no from TEMP_WELL_DEFERMENT_ALLOC)
    );

  lv2_nav_classname    VARCHAR2(32);
  lv2_grandparent_classname VARCHAR2(32);
BEGIN
  IF (p_object_id IS NOT NULL) THEN
    --p_object_id is the last navigator object_id selected at the well deferment screen.
    IF ecdp_objects.GetObjClassName(p_object_id) = 'WELL' THEN
      lv2_nav_classname := p_nav_parent_class_name;
    ELSE -- 'WELL_HOOKUP, FCTY_CLASS_1 or even higher parent level of FCTY_CLASS_2, AREA or PRODUCTIONUNIT'
      lv2_nav_classname := ecdp_objects.GetObjClassName(p_object_id);
    END IF;
    IF lv2_nav_classname IN ('FCTY_CLASS_1', 'COLLECTION_POINT') THEN
      lv2_grandparent_classname :=
        CASE
          WHEN lv2_nav_classname = 'FCTY_CLASS_1' THEN 'FCTY_CLASS_2'
          WHEN lv2_nav_classname = 'COLLECTION_POINT' THEN 'OPERATOR_ROUTE'
        END;
      FOR mycur IN c1_temp_alloc_recs_object_id(p_nav_group_type, lv2_nav_classname, lv2_grandparent_classname ) LOOP
        p_from_date := mycur.daytime;
        p_to_date := mycur.end_date;
      END LOOP;
    ELSE -- (when classname rank is higher than immediate parent object FCTY_CLASS_1)
      FOR mycur IN c2_temp_alloc_recs_object_id(p_nav_group_type, lv2_nav_classname ) LOOP
        p_from_date := mycur.daytime;
        p_to_date := mycur.end_date;
      END LOOP;
    END IF;
  ELSE
    FOR mycur IN c_temp_alloc_recs LOOP
        p_from_date := mycur.daytime;
        p_to_date := mycur.end_date;
    END LOOP;
  END IF;
  IF p_from_date is null THEN
     p_from_date:='01-Jan-1900';
  END IF;
  EXCEPTION WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20000,'An error was encountered calculating the deferment event loss - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
END getStartEndDate;

PROCEDURE insertStatusLog (p_run_no NUMBER, p_from_date DATE, p_to_date DATE) IS
     PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
--Need to change daytime to rundate
 INSERT INTO TV_CALC_DEF_LOG_STATUS
    (run_no, from_date, to_date, RUN_DATE, exit_status)
  VALUES
    (p_run_no, p_from_date, p_to_date, EcDp_Timestamp.getCurrentSysdate(),'SUCCESS_SIMULATE');
	commit;
end insertStatusLog;

PROCEDURE updateStatusLog(p_run_no NUMBER, p_exit_status VARCHAR2) IS
     PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  UPDATE TV_CALC_DEF_LOG_STATUS
  SET run_end_date = EcDp_Timestamp.getCurrentSysdate(), exit_status = p_exit_status
  WHERE run_no = p_run_no;
  commit;
end updateStatusLog;

End EcDp_Deferment_Log;