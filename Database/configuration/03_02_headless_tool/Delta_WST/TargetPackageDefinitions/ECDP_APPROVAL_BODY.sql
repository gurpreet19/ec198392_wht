CREATE OR REPLACE PACKAGE BODY EcDp_Approval IS

/****************************************************************
** Package        :  EcDp_Approval, body part
**
** $Revision: 1.25 $
**
** Purpose        : Approval handling.
**
** Documentation  :  www.energy-components.com
**
** Created  : 19-Jun-2007
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
** 19.06.07 HUS    Initial version of package
** 04.10.07 HUS    Raise exceptions in Accept and Reject
** 21.04.09 leeeewei Modified BuildApprovalRecordView to generate V_APPROVALRECORDS and V_APPROVALRECORDSALL for four eye approval using new procedure BuildApprovalRecordViewType
**
*****************************************************************/

lb_accept_flag BOOLEAN:=FALSE;
lb_reject_flag BOOLEAN:=FALSE;
ln_approval_task_no NUMBER:=NULL;

CURSOR c_task_detail(p_rec_id VARCHAR2,p_task_no NUMBER) IS
  SELECT *
  FROM   task_detail
  WHERE  record_ref_id=p_rec_id
  AND    task_no=p_task_no;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getApprovalTaskNo
-- Description    : Returns the task_no for the APPROVAL task_type.
--
-- Preconditions  :
--
-- Postcondition  :
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
FUNCTION getApprovalTaskNo
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_task IS
     SELECT task_no
     FROM   task
     WHERE  task_type='APPROVAL';
BEGIN
  IF ln_approval_task_no IS NULL THEN
     FOR curTask in c_task LOOP
        ln_approval_task_no:=curTask.task_no;
        EXIT;
     END LOOP;
  END IF;
  RETURN ln_approval_task_no;
END getApprovalTaskNo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsAccepting
-- Description    : Returns TRUE if we are in the EcDp_Approval.Accept function. Used by IUD triggers
--                  to distinguish between operations that originate from an Accept and those that are
--                  triggered by "manual" INSERT, UPDATE and/or DELETE.
--
-- Preconditions  :
--
-- Postcondition  :
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
FUNCTION IsAccepting
RETURN BOOLEAN
--</EC-DOC>
IS
BEGIN
  RETURN lb_accept_flag;
END IsAccepting;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsRejecting
-- Description    : Returns TRUE if we are in the EcDp_Approval.Reject function. Used by IUD triggers
--                  to distinguish between operations that originate from a Reject and those that are
--                  triggered by "manual" INSERT, UPDATE and/or DELETE.
--
-- Preconditions  :
--
-- Postcondition  :
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
FUNCTION IsRejecting
RETURN BOOLEAN
--</EC-DOC>
IS
BEGIN
  RETURN lb_reject_flag;
END IsRejecting;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : InApprovalMode
-- Description    : Returns TRUE if we are in the EcDp_Approval.Accept/Reject functions. Used by IUD
--                  triggers to distinguish between operations that originate from an Accept/Reject
--                  and those that are triggered by "manual" INSERT, UPDATE and/or DELETE.
--
-- Preconditions  :
--
-- Postcondition  :
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
FUNCTION InApprovalMode
RETURN BOOLEAN
--</EC-DOC>
IS
BEGIN
  RETURN IsAccepting OR IsRejecting;
END InApprovalMode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : Accept
-- Description    : Accept the given approval_log entry.
--
-- Preconditions  :
--
-- Postcondition  :
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
PROCEDURE Accept(
    p_rec_id      IN VARCHAR2,
    p_comments    IN VARCHAR2)
--</EC-DOC>
IS
  lv2_appuser   VARCHAR2(30):=Nvl(EcDp_Context.getAppUser,User);
  lv2_statement VARCHAR2(1000);
  ln_rowcount   NUMBER;
  lv2_class_name varchar2(30);
  lv2_created_by varchar2(50);
  lv2_last_updated_by varchar2(50);
  lv2_delete_callback varchar2(2000);
  ln_task_no  number;
  lb_emergency_mode BOOLEAN := FALSE;
  lv2_object_id   VARCHAR2(100);
  lv2_table_name  VARCHAR2(30);

BEGIN
  lb_accept_flag := TRUE;
  ln_rowcount := 0;
  FOR cur IN c_task_detail(p_rec_id,getApprovalTaskNo) LOOP
    lv2_class_name := cur.class_name;
    ln_task_no := cur.task_no;
    lv2_delete_callback := cur.delete_callback;
    lv2_created_by := cur.created_by;
    lv2_last_updated_by := cur.last_updated_by;
    EXIT;
  END LOOP;

  IF lv2_class_name IS NULL THEN

    lb_emergency_mode := TRUE;

    -- Find class name, created_by and last_updated_by
    findMissingTaskDetailEntry(p_rec_id,lv2_class_name, lv2_created_by, lv2_last_updated_by);

    -- Find approval task no
    ln_task_no := getApprovalTaskNo;
    lv2_delete_callback := NULL; -- can not solve this in emergency exit modus

    -- No task detail exists, we need to create one
    INSERT INTO task_detail (
         task_no,
         record_ref_id,
         class_name,
         status,
         delete_callback,
         created_by)
       VALUES (
         ln_task_no,
         p_rec_id,
         lv2_class_name,
         'O',
         null,
         Nvl(lv2_last_updated_by, lv2_created_by));

  END IF;

  UPDATE task_detail
  SET    last_updated_by=lv2_appuser
  ,      status='A'
  ,      comments=p_comments
  ,      rev_no=Nvl(rev_no,0)+1
  WHERE  record_ref_id=p_rec_id
  AND    task_no=ln_task_no
  AND    status='O'
  AND    Nvl(last_updated_by, created_by)!=lv2_appuser;

  ln_rowcount := SQL%ROWCOUNT;
  IF ln_rowcount=0 THEN
     IF Nvl(lv2_last_updated_by, lv2_created_by)=lv2_appuser THEN
        lb_accept_flag := FALSE;
        Raise_Application_Error(-20115,'Cannot accept your own modification.');
     ELSE
       lb_accept_flag := FALSE;
       Raise_Application_Error(-20116,'Open approval task not found.');
     END IF;
  END IF;

  -- Smart journaling version bypassing view layer and update on underlying table/view
  -- since we don't want a journal entry for this, and don't want any changes to rev_text, last updated by etc.

  IF Ecdp_classmeta.getClassType(lv2_class_name) = 'OBJECT' THEN
    lv2_table_name := ec_class_db_mapping.DB_OBJECT_ATTRIBUTE(lv2_class_name);
  ELSE
    lv2_table_name := ec_class_db_mapping.DB_OBJECT_NAME(lv2_class_name);
  END IF;


  lv2_statement :=
  'UPDATE '||lv2_table_name||CHR(10)||
  'SET    approval_state=''O'''||CHR(10)||
  ',      approval_by=:1'||CHR(10)||
  ',      approval_date=:2'||CHR(10)||
  ',      last_updated_by = last_updated_by'||CHR(10)||
  ',      last_updated_date = last_updated_date'||CHR(10)||
  'WHERE  rec_id=:3'||CHR(10)||
  'AND    approval_state in (''N'',''U'')'||CHR(10)||
  'AND    Nvl(last_updated_by,created_by)!=:4';



  EXECUTE IMMEDIATE lv2_statement USING lv2_appuser, EcDp_Date_Time.getCurrentSysdate, p_rec_id, lv2_appuser;

  ln_rowcount := SQL%ROWCOUNT;
  IF ln_rowcount=0 THEN
    -- Got no hits, so the change must have a "mark for deletion".
    IF lv2_delete_callback IS NOT NULL THEN
      -- Trigger delete callback if registered!
      BEGIN
        EXECUTE IMMEDIATE lv2_delete_callback;
        EXCEPTION
          WHEN OTHERS THEN
            lb_accept_flag := FALSE;
            Raise_Application_Error(-20117, 'Cannot complete accept operation. Failed to execute delete callback, '||lv2_delete_callback||': '||SQLERRM);
      END;
      ln_rowcount := 1;
    ELSIF lb_emergency_mode THEN

      -- Undo "mark for deletion!.
      lv2_statement :=
      'UPDATE '||lv2_table_name||CHR(10)||
      'SET    approval_state=''U'''||CHR(10)||
      ',      rev_text=rev_text'||CHR(10)||
      ',      last_updated_by=:1'||CHR(10)||
      'WHERE  rec_id=:2'||CHR(10)||
      'AND    approval_state=''D'''||CHR(10)||
      'AND    Nvl(last_updated_by,created_by)!=:3';
      EXECUTE IMMEDIATE lv2_statement USING lv2_appuser, p_rec_id, lv2_appuser;
      Raise_Application_Error(-20123, 'Unable to find delete callback, setting status back to updated' || ': '||SQLERRM);

    ELSIF ecdp_classmeta.getClassType(lv2_class_name)!='OBJECT' THEN

      lv2_statement :=
      'UPDATE '||lv2_table_name||CHR(10)||
      'SET   approval_by = :1 '||CHR(10)||
      ',     approval_date = :2  '||CHR(10)||
      'WHERE  rec_id=:3'||CHR(10)||
      'AND    approval_state = ''D''' ||CHR(10)||
      'AND    Nvl(last_updated_by,created_by)!=:4';

      EXECUTE IMMEDIATE lv2_statement USING lv2_appuser, EcDp_Date_Time.getCurrentSysdate, p_rec_id, lv2_appuser;


      -- Delete non-object records via class view!
      lv2_statement :=
      'DELETE FROM '||lv2_table_name||CHR(10)||
      'WHERE  rec_id=:1'||CHR(10)||
      'AND    approval_state = ''D''' ||CHR(10)||
      'AND    Nvl(last_updated_by,created_by)!=:2';
      EXECUTE IMMEDIATE lv2_statement USING p_rec_id, lv2_appuser;
      ln_rowcount := SQL%ROWCOUNT;

    ELSE  -- CLASS_TYPE = OBJECT

      -- Since approval_state and rec_id is only set on version table, need to find object_id before we delete from version table

      lv2_statement :=
        'SELECT object_id FROM '||ec_class_db_mapping.db_object_attribute(lv2_class_name)||CHR(10)||
        'WHERE  rec_id=:1';

      EXECUTE IMMEDIATE lv2_statement INTO lv2_object_id USING p_rec_id ;

      -- Set approval colums before delete to get it stamped correct in journal entry

      EcDp_User_Session.SetUserSessionParameter('JN_NOTES','COMMON');

      lv2_statement :=
        'UPDATE '||ec_class_db_mapping.db_object_attribute(lv2_class_name)||CHR(10)||
        'SET   approval_by = :1 '||CHR(10)||
        ',     approval_date = :2  '||CHR(10)||
        ',     last_updated_by = last_updated_by  '||CHR(10)||
        ',     last_updated_date = last_updated_date  '||CHR(10)||
        'WHERE  rec_id=:3'||CHR(10)||
        'AND    approval_state = ''D''' ||CHR(10)||
        'AND    Nvl(last_updated_by,created_by)!=:4';

      EXECUTE IMMEDIATE lv2_statement USING lv2_appuser, EcDp_Date_Time.getCurrentSysdate, p_rec_id, lv2_appuser;



      -- Delete objects directly from tables.
      lv2_statement :=
        'DELETE FROM '||ec_class_db_mapping.db_object_attribute(lv2_class_name)||CHR(10)||
        'WHERE  rec_id=:1'||CHR(10)||
        'AND    approval_state = ''D''' ||CHR(10)||
        'AND    Nvl(last_updated_by,created_by)!=:2';
      EXECUTE IMMEDIATE lv2_statement USING p_rec_id, lv2_appuser;


      IF SQL%ROWCOUNT>0 THEN
        lv2_statement :=
          'DELETE FROM '||ec_class_db_mapping.db_object_name(lv2_class_name)||' v'||CHR(10)||
          'WHERE  NOT EXISTS (SELECT 1 FROM '||ec_class_db_mapping.db_object_attribute(lv2_class_name)||' WHERE object_id=v.object_id) '||CHR(10)||
          'AND    object_id =:1';
        EXECUTE IMMEDIATE lv2_statement USING lv2_object_id;
       END IF;
       ln_rowcount := SQL%ROWCOUNT;

    END IF;

  END IF;

  IF ln_rowcount=0 THEN
     lb_accept_flag := FALSE;
     Raise_Application_Error(-20117,'Accept operation failed to update the source record.');
  END IF;

  lb_accept_flag := FALSE;
END Accept;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : Reject
-- Description    : Reject the given approval_log entry.
--
-- Preconditions  :
--
-- Postcondition  :
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
PROCEDURE Reject(
    p_rec_id      IN VARCHAR2,
    p_comments    IN VARCHAR2)
IS
  lv2_appuser   VARCHAR2(30):=Nvl(EcDp_Context.getAppUser,User);
  lv2_statement VARCHAR2(1000);
  ln_rowcount   NUMBER;
  lv2_class_name varchar2(30);
  lv2_created_by varchar2(50);
  lv2_last_updated_by varchar2(50);
  lv2_delete_callback varchar2(2000);
  ln_task_no  number;
BEGIN
  lb_reject_flag := TRUE;
  ln_rowcount := 0;
  FOR cur IN c_task_detail(p_rec_id,getApprovalTaskNo) LOOP
    lv2_class_name := cur.class_name;
    ln_task_no := cur.task_no;
    lv2_delete_callback := cur.delete_callback;
    lv2_created_by := cur.created_by;
    lv2_last_updated_by := cur.last_updated_by;
    EXIT;
  END LOOP;

  IF lv2_class_name IS NULL THEN

    -- Find class name, created_by and last_updated_by
    findMissingTaskDetailEntry(p_rec_id,lv2_class_name, lv2_created_by, lv2_last_updated_by);

    -- Find approval task no
    ln_task_no := getApprovalTaskNo;
    lv2_delete_callback := NULL; -- can not solve this in emergency exit modus

    -- No task detail exists, we need to create one
    INSERT INTO task_detail (
         task_no,
         record_ref_id,
         class_name,
         status,
         delete_callback,
         created_by)
       VALUES (
         ln_task_no,
         p_rec_id,
         lv2_class_name,
         'O',
         null,
         Nvl(lv2_last_updated_by, lv2_created_by));

  END IF;

  UPDATE task_detail
  SET    last_updated_by=lv2_appuser
  ,      status='O'
  ,      comments=p_comments
  ,      rev_no=Nvl(rev_no,0)+1
  WHERE  record_ref_id=p_rec_id
  AND    task_no=ln_task_no
  AND    Nvl(last_updated_by, created_by)!=lv2_appuser;

  ln_rowcount := SQL%ROWCOUNT;

  IF ln_rowcount=0 THEN
     lb_reject_flag := FALSE;
     Raise_Application_Error(-20118,'Cannot reject your own modification.');
  END IF;

  IF ln_rowcount>0 THEN
    -- Undo "mark for deletion!.
    lv2_statement :=
    'UPDATE '||ecdp_classmeta.getClassViewName(lv2_class_name)||CHR(10)||
    'SET    approval_state=''U'''||CHR(10)||
    ',      rev_text=rev_text'||CHR(10)||
    ',      last_updated_by=:1'||CHR(10)||
    'WHERE  rec_id=:2'||CHR(10)||
    'AND    approval_state=''D'''||CHR(10)||
    'AND    Nvl(last_updated_by,created_by)!=:3';

    EXECUTE IMMEDIATE lv2_statement USING lv2_appuser, p_rec_id, lv2_appuser;

    ln_rowcount := SQL%ROWCOUNT;

    IF ln_rowcount=0 THEN
      lb_reject_flag := FALSE;
      Raise_Application_Error(-20119,'Reject operation failed to update the source record.');
    END IF;
  END IF;
  lb_reject_flag := FALSE;
END Reject;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : registerTaskDetail
-- Description    :
--
-- Preconditions  :
--
-- Postcondition  :
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
PROCEDURE registerTaskDetail(
    p_rec_id       IN VARCHAR2,
    p_class_name   IN VARCHAR2,
    p_user         IN VARCHAR2,
    p_del_callback IN VARCHAR2 DEFAULT NULL)
IS
  ln_task_no NUMBER:=getApprovalTaskNo;
BEGIN
  IF InApprovalMode=FALSE THEN
    UPDATE task_detail
    SET    status='O'
    ,      rev_no=(rev_no+1)
    ,      last_updated_by=p_user
    ,      class_name=p_class_name
    ,      comments=null
    ,      delete_callback=nvl(p_del_callback,delete_callback)
    WHERE  task_no=ln_task_no
    AND    record_ref_id=p_rec_id;

    IF SQL%ROWCOUNT=0 THEN
       INSERT INTO task_detail (
         task_no,
         record_ref_id,
         class_name,
         status,
         delete_callback,
         created_by)
       VALUES (
         ln_task_no,
         p_rec_id,
         p_class_name,
         'O',
         p_del_callback,
         p_user);
    END IF;
  END IF;
END registerTaskDetail;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : deleteTaskDetail
-- Description    :
--
-- Preconditions  :
--
-- Postcondition  :
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
PROCEDURE deleteTaskDetail(
    p_rec_id      IN VARCHAR2)
--</EC-DOC>
IS
  ln_task_no NUMBER:=getApprovalTaskNo;
BEGIN
  IF InApprovalMode=FALSE THEN
    DELETE FROM task_detail
    WHERE  task_no=ln_task_no
    AND    record_ref_id=p_rec_id;
  END IF;
END deleteTaskDetail;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GeneratedCodeMsg
-- Description    : Returns a string giving the package revision and daytime for generation
--
-- Preconditions  :
-- Postcondition  :
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
FUNCTION GeneratedCodeMsg RETURN VARCHAR2
--</EC-DOC>

IS


lv2_prog_statement   VARCHAR2(4000) := '-- Generated by EcDp_Approval '||CHR(10);

BEGIN

    RETURN lv2_prog_statement;

END GeneratedCodeMsg;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : BuildApprovalRecordView
-- Description    : Build a view that list all record that is up for approval (updated or New)
--                  Using the approval indicator in class to make unions for all classes with
--                  approval turned on. Select is against view layer to enforce ringfencing
--
-- Preconditions  :
--
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: BuildApprovalRecordViewType
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE BuildApprovalRecordView
--</EC-DOC>
IS

BEGIN

BuildApprovalRecordViewType('N');
BuildApprovalRecordViewType('Y');

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : hasRowAccess
-- Description    : Check if the current user have access to a given row in a class
--
-- Preconditions  :
--
-- Postcondition  :
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
FUNCTION hasRowAccess(p_class_name IN VARCHAR2,
                     p_rec_id     IN VARCHAR2)
        RETURN VARCHAR2
--</EC-DOC>

IS

  lv2_sql    VARCHAR2(2000);
  ln_result  NUMBER;
  lv2_result VARCHAR2(1);
  lv2_tablename VARCHAR2(2000);

BEGIN

  lv2_tablename := ecdp_classmeta.getClassViewName(p_class_name);

  IF lv2_tablename IS NOT NULL AND p_rec_id IS NOT NULL THEN

    lv2_sql := ' SELECT count(*) FROM '||lv2_tablename||' WHERE nvl(rec_id,''NULL'') = '''||Nvl(p_rec_id,'NULL')||''''  ;

    EXECUTE IMMEDIATE lv2_sql INTO ln_result;

    IF ln_result = 1 THEN
      lv2_result := 'Y';
    ELSE
      lv2_result := 'N';
    END IF;

  ELSE -- If the row has no class and row reference don't enforce ringfencing on it

      lv2_result := 'Y';

  END IF;

  RETURN lv2_result;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : findMissingTaskDetailEntry
-- Description    : Find class_name, created_by and last_updated_by for given rec id
--
-- Preconditions  :
--
-- Postcondition  :
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
PROCEDURE findMissingTaskDetailEntry(p_rec_id IN VARCHAR2,
                                    p_class_name IN OUT VARCHAR2,
                                    p_created_by IN OUT VARCHAR2,
                                    p_last_updated_by IN OUT VARCHAR2)
--</EC-DOC>

IS

  CURSOR c_approval_classes IS
  SELECT c.class_name, c.class_type, cdb.db_object_name , cdb.db_object_attribute, cdb.db_where_condition
  FROM class c, class_db_mapping cdb
  WHERE c.class_name = cdb.class_name
  AND   Nvl(c.approval_ind,'N') = 'Y'
  ORDER BY c.class_name
  ;

  lv2_sql    VARCHAR2(2000);

BEGIN

  FOR curClass IN c_approval_classes LOOP

      lv2_sql := 'SELECT created_by, last_updated_by FROM ' || curClass.Db_Object_Name || ' WHERE rec_id = ''' || p_rec_id || '''';

      BEGIN
        EXECUTE IMMEDIATE lv2_sql INTO p_created_by, p_last_updated_by;
          EXCEPTION
            WHEN OTHERS THEN p_created_by := NULL;
      END;

      IF p_created_by IS NOT NULL THEN
         p_class_name := curClass.Class_Name;
         EXIT;
      END IF;

  END LOOP;

END;


FUNCTION ChangedClassColumns(p_class_name IN VARCHAR2,
                             p_rec_id     IN VARCHAR2)
        RETURN VARCHAR2
IS

  lv2_sql    VARCHAR2(4000);
  lv2_result VARCHAR2(4000);

BEGIN

  lv2_sql := 'SELECT ec4e_'||p_class_name||'.changedColumns('''|| p_rec_id ||''') from t_preferanse where rownum = 1';

  lv2_result := ecdp_dynsql.execute_singlerow_varchar2(lv2_sql);

  RETURN lv2_result;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : BuildAllApprovalRecordViewType
-- Description    : Build view V_APPROVALRECORDS and V_APPROVALRECORDSALL that list all records that is up for approval (updated or New)
--					where status = open or accepted
--                  Select is against view layer to enforce ringfencing
--
-- Preconditions  :
--
-- Postcondition  :
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
PROCEDURE BuildApprovalRecordViewType(p_include_all VARCHAR2 DEFAULT 'N')
--</EC-DOC>
IS
  CURSOR c_approval_classes IS
  SELECT c.class_name, c.class_type, cdb.db_object_name , cdb.db_object_attribute, cdb.db_where_condition
  FROM class c, class_db_mapping cdb
  WHERE c.class_name = cdb.class_name
  AND   Nvl(c.approval_ind,'N') = 'Y'
  ORDER BY c.class_name
  ;

  body_lines                   DBMS_SQL.varchar2a;
  lv2_view_name                VARCHAR2(30);
  lb_firsttime                 BOOLEAN := TRUE;
  lb_include_all               BOOLEAN;

BEGIN

  lb_include_all := (Nvl(p_include_all,'N') = 'Y' );

  -- lb_include_all = 'N': generate the view V_APPROVALRECORDS

  IF NOT lb_include_all THEN

  Ecdp_Dynsql.AddSqlLine(body_lines, 'CREATE OR REPLACE VIEW V_APPROVALRECORDS(' || chr(10))  ;

  ELSE -- lb_include_all='Y': generate the view V_APPROVALRECORDSALL

  Ecdp_Dynsql.AddSqlLine(body_lines, 'CREATE OR REPLACE VIEW V_APPROVALRECORDSALL(' || chr(10))  ;

  END IF;

  Ecdp_Dynsql.AddSqlLine(body_lines, 'CLASS_NAME,REC_ID, APPROVAL_STATE, APPROVAL_BY, APPROVAL_DATE' || chr(10))  ;
  Ecdp_Dynsql.AddSqlLine(body_lines, ', RECORD_STATUS, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE' || chr(10))  ;
  Ecdp_Dynsql.AddSqlLine(body_lines, ', REV_NO, REV_TEXT) AS' || chr(10))  ;


  FOR curClass IN  c_approval_classes LOOP

    IF curClass.class_type = 'OBJECT' THEN
      lv2_view_name := 'OV_'||curClass.class_name;
    ELSIF  curClass.class_type = 'DATA' THEN
      lv2_view_name := 'DV_'||curClass.class_name;
    ELSIF curClass.class_type = 'INTERFACE' THEN
      lv2_view_name := 'IV_'||curClass.class_name;
    ELSE
      lv2_view_name := 'TV_'||curClass.class_name;
    END IF;

    IF NOT lb_firsttime THEN

      Ecdp_Dynsql.AddSqlLine(body_lines, 'UNION ALL'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'SELECT '''||curClass.class_name||''', v.rec_id, v.approval_state, v.approval_by , v.approval_date'||CHR(10));


    ELSE

      lb_firsttime := FALSE;
      Ecdp_Dynsql.AddSqlLine(body_lines,'SELECT '||GeneratedCodeMsg||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,''''||curClass.class_name||''', v.rec_id, v.approval_state, v.approval_by, v.approval_date'||CHR(10));

    END IF;

      Ecdp_Dynsql.AddSqlLine(body_lines,'       , v.RECORD_STATUS, v.CREATED_BY, v.CREATED_DATE, v.LAST_UPDATED_BY, v.LAST_UPDATED_DATE'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'       , to_char(v.REV_NO), v.REV_TEXT'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'FROM '||lv2_view_name||' v , TASK_DETAIL TD , TASK T'|| CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'WHERE v.rec_id = td.record_ref_id'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'AND   td.task_no =  t.task_no'||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'AND   t.task_type =  ''APPROVAL'''||CHR(10));
      Ecdp_Dynsql.AddSqlLine(body_lines,'AND   td.class_name = '''||curClass.class_name||''''||CHR(10));

      IF NOT lb_include_all THEN
         EcDp_Dynsql.AddSqlLine(body_lines, 'AND nvl(v.approval_state,''O'') IN (''N'',''U'',''D'')'||CHR(10));
      END IF;

  END LOOP;

  IF lb_firsttime THEN  -- create dummy version

    Ecdp_Dynsql.AddSqlLine(body_lines,'SELECT --'||GeneratedCodeMsg);
    Ecdp_Dynsql.AddSqlLine(body_lines,'''dummy'',''dummy'', ''O'', ''dummy'',to_date(null) '||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,',''P'', ''dummy'', sysdate, ''dummy'', sysdate'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,', 0, ''dummy'''||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'FROM ctrl_db_version'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'WHERE 1 = 0'||CHR(10));


  END IF;

  IF NOT lb_include_all THEN
         Ecdp_Dynsql.SafeBuild('V_APPROVALRECORDS','VIEW',body_lines,'CREATE');
         ELSE
         Ecdp_Dynsql.SafeBuild('V_APPROVALRECORDSALL','VIEW',body_lines,'CREATE');
   END IF;

   Ecdp_dynsql.RecompileInvalid;

END;

END EcDp_Approval;