CREATE OR REPLACE PACKAGE BODY ecdp_4ea_utility IS
/******************************************************************************
** Package        :  Ecap_type, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Support functions for validation of approved data
**
** Documentation  :  www.energy-components.com
**
** Created        :  23.12.2007
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- ------------------------------------------------------------------------------
** 28.08.2008  KEB   Calling WriteDebugText instead of WriteTempText
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddUnapprovedData
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddUnapprovedData(
          p_class_name  IN  VARCHAR2
,         p_rec_id      IN  VARCHAR2
,         p_class_name_list IN OUT t_class_name_list
,         p_rec_id_list  IN OUT t_rec_id_list
)
--</EC-DOC>
IS

BEGIN

      IF p_class_name_list IS NULL THEN

         p_class_name_list := t_class_name_list();
         p_rec_id_list := t_rec_id_list();

      END IF;


      p_class_name_list.EXTEND;
      p_rec_id_list.EXTEND;

      p_class_name_list(p_class_name_list.LAST) := p_class_name;
      p_rec_id_list(p_rec_id_list.LAST):= p_rec_id;




END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddVisitedNode
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddVisitedNode(
          p_node_name   IN  VARCHAR2,
          p_level       IN  NUMBER
)
--</EC-DOC>

IS

BEGIN

      IF l_node_list IS NULL THEN

         l_node_list := t_node_list();
         l_level_list := t_level_list();


      END IF;

      l_node_list.EXTEND;
      l_level_list.EXTEND;
      l_node_list(l_node_list.LAST) := SUBSTR(p_node_name,1,2000);
      l_level_list(l_level_list.LAST) := p_level;

      IF lb_debug THEN
        ecdp_dynsql.WriteDebugText('VISITEDNODE',TO_CHAR(p_level,'999')||' Visited Classes: '||p_node_name, 'DEBUG' );
      END IF;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ClearVisitedNode
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE ClearVisitedNode
--</EC-DOC>

IS

BEGIN

   IF l_node_list IS NOT NULL THEN
     l_node_list.DELETE;
   END IF;

   IF l_level_list IS NOT NULL THEN
     l_level_list.DELETE;
   END IF;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : isVisitedNode
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isVisitedNode(
          p_node_name   IN  VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>

IS
  lv2_result VARCHAR2(1) := 'N';

BEGIN

  IF l_node_list IS NOT NULL THEN

    FOR i IN 1..l_node_list.count LOOP

       IF l_node_list(i) = p_node_name THEN
         lv2_result := 'Y';
         EXIT;
       END IF;

    END LOOP;

  END IF;

  RETURN lv2_result;


END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : isVisitedObject
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isVisitedObject(
          p_rec_id   IN  VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>

IS
  lv2_result VARCHAR2(1) := 'N';

BEGIN

  IF p_rec_id IS NOT NULL AND l_visited_object IS NOT NULL THEN


    FOR i IN 1..l_visited_object.count LOOP

       IF l_visited_object(i) = p_rec_id THEN
         lv2_result := 'Y';
         EXIT;
       END IF;

    END LOOP;

  END IF;

  RETURN lv2_result;


END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddVisitedObject
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddVisitedObject(
          p_class_name  IN  VARCHAR2,
          p_rec_id      IN  VARCHAR2,
          p_level       IN  NUMBER DEFAULT NULL
)
--</EC-DOC>

IS

BEGIN

      IF l_visited_object IS NULL THEN

         l_visited_object := t_rec_id_list();

      END IF;

      l_visited_object.EXTEND;
      l_visited_object(l_visited_object.LAST) := SUBSTR(p_rec_id,32);

      IF lb_debug THEN
        ecdp_dynsql.WriteDebugText('VISITEDOBJECT',TO_CHAR(Nvl(p_level,0),'999')||' Visited Class: ' ||p_class_name || ' Object: '||EcDp_task_detail.RecIDDetailDescription(p_class_name,p_rec_id), 'DEBUG' );
      END IF;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ClearVisitedObject
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE ClearVisitedObject
--</EC-DOC>

IS

BEGIN

   IF l_visited_object IS NOT NULL THEN
     l_visited_object.DELETE;
   END IF;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : hasapproval
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION hasapproval(p_class_name VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>

IS
  CURSOR lc_class IS
  SELECT approval_ind
  from class c
  where c.class_name = p_class_name;

  lv2_result VARCHAR2(1) := NULL;

BEGIN

  FOR curClass IN lc_class LOOP

    lv2_result := Nvl(curClass.approval_ind,'N');

  END LOOP;


  RETURN lv2_result;


END hasapproval;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : isOnApprovalPath
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isOnApprovalPath(p_class_name VARCHAR2,p_level NUMBER DEFAULT 0)
RETURN VARCHAR2
--</EC-DOC>

IS
  CURSOR lc_classdependencylinks(cp_class_name VARCHAR2) IS
  SELECT to_class_name child_class, role_name, 1 AS node_level
  from class_relation cr
  where cr.from_class_name = cp_class_name
  UNION ALL
  SELECT from_class_name child_class, role_name, -1 AS node_level
  from class_relation cr
  where cr.to_class_name = cp_class_name
  AND  reverse_approval_ind = 'Y'
  UNION ALL
  SELECT class_name child_class, 'OWNERCLASS', 1 AS node_level
  from class cr
  where owner_class_name = cp_class_name;


  lv2_result VARCHAR2(1) := 'N';
  ln_level  NUMBER;

BEGIN

  IF l_node_list IS NULL THEN

    l_node_list := t_node_list();
    l_level_list := t_level_list();

  END IF;


  ln_level := Nvl(p_level,0);

  IF isvisitednode(p_class_name) = 'N' THEN

    AddVisitedNode(p_class_name,ln_level);

    IF ec_class.approval_ind(p_class_name) = 'Y' THEN

      lv2_result := 'Y';

    ELSE  -- Only check children classes if the class it self do not have approval


       FOR curChild IN lc_classdependencylinks(p_class_name) LOOP

         IF curChild.child_class <> p_class_name THEN
           lv2_result := isOnApprovalPath(curChild.child_class,ln_level+curChild.node_level);
         END IF;

         IF lv2_result = 'Y' THEN
           EXIT;
         END IF;

       END LOOP;


    END IF;

  END IF;


  RETURN lv2_result;


END isOnApprovalPath;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : isunapprovedData
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isunapprovedData RETURN VARCHAR2
--</EC-DOC>

IS
  CURSOR c_unapproved IS
  SELECT * FROM task_detail
  WHERE task_no = 1
  AND status <> 'A';

  lv2_result VARCHAR2(1) := 'N';

BEGIN

  FOR curRec IN c_unapproved LOOP

    lv2_result := 'Y';
    EXIT;

  END  LOOP;

  RETURN lv2_result;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : isusing4ea
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isusing4ea RETURN VARCHAR2
--</EC-DOC>

IS
  CURSOR c_approve IS
  SELECT * FROM class
  WHERE approval_ind = 'Y';

  lv2_result VARCHAR2(1) := 'N';

BEGIN

  FOR curRec IN c_approve LOOP

    lv2_result := 'Y';
    EXIT;

  END  LOOP;

  RETURN lv2_result;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddCPTask
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION AddCPTask(p_severity varchar2,
                    p_description varchar2
                    )
RETURN NUMBER
--</EC-DOC>



IS
  PRAGMA  AUTONOMOUS_TRANSACTION;

  l_class_name_list ecdp_4ea_utility.t_class_name_list;
  l_rec_id_list ecdp_4ea_utility.t_rec_id_list;
  lts_start  TIMESTAMP;
  lts_end    TIMESTAMP;
  lv2_task_process_id VARCHAR2(32);
  lv2_result VARCHAR2(1) := 'N';
  ln_usedsec NUMBER;
  ln_task_no NUMBER;

BEGIN

  lv2_task_process_id := ecdp_objects.getobjidfromcode('TASK_PROCESS','CP_'||upper(p_severity));

  IF lv2_task_process_id IS NOT NULL THEN

    BEGIN
      INSERT INTO TASK(TASK_TYPE,TASK_PROCESS_ID,TASK_DESCRIPTION,TASK_STATUS)
      VALUES('CP_'||UPPER(p_severity),lv2_task_process_id,p_description,'OPEN')
      RETURNING task_no INTO ln_task_no;

    EXCEPTION
          WHEN OTHERS THEN
              select task_no into ln_task_no
              from task
              where task_type = 'CP_'||UPPER(p_severity)
              AND TASK_DESCRIPTION = p_description
              and task_process_id = lv2_task_process_id
              and task_status = 'OPEN';

    END;


  END IF;

  COMMIT;

  RETURN ln_task_no;

END AddCPTask;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddCPTaskDetail
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddCPTaskDetail(p_task_no INTEGER,
                          p_class_name_list ecdp_4ea_utility.t_class_name_list,
                          p_rec_id_list ecdp_4ea_utility.t_rec_id_list
                          )
--</EC-DOC>

IS

  PRAGMA  AUTONOMOUS_TRANSACTION;

  ln_usedsec NUMBER;
  ln_task_no NUMBER;

BEGIN

    FOR i in 1..p_class_name_list.count LOOP

      IF p_rec_id_list(i) is not null THEN

        BEGIN

          INSERT INTO TASK_DETAIL(TASK_NO,RECORD_REF_ID,CLASS_NAME)
          VALUES(p_task_no,p_rec_id_list(i),p_class_name_list(i));

        EXCEPTION
          WHEN OTHERS THEN
            NULL;

        END;

      END IF;

    END LOOP;

    COMMIT;

END;


END ecdp_4ea_utility;