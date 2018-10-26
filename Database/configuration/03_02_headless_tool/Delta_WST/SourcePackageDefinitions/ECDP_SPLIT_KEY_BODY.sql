CREATE OR REPLACE PACKAGE BODY EcDp_Split_Key IS
/****************************************************************
** Package        :  EcDp_Split_Key, header part
**
** $Revision: 1.23 $
**
** Purpose        :  Provide special functions on Split_key. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.07.2002  Henning Stokke
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
**          09.04.2003  TRA   Changes in GetSplitShareMth. EcDp_Objects.GetObjIDToRel is now used to determine target_source.
** B1.15     31.07.2003  JE    Added p_user as new parameter to procedure. Included p_user in update and insert statements,
**                            and package calls in the following procedures and functions: PROCEDURE UpdateShare, PROCEDURE
**                            DelSplitShare and PROCEDURE DelSplit
** B1.16     12.08.2003  TRA   Bugfix in insNewSourceSplit. Missing end_date param in ecdp_objects.insNewObjRel function calls.
** B1.18     15.10.2003  JE    Added parameters p_role_name and p_attribute_type with default values to function GetSplitValueMth
**                            Inserted these two parameters into the code.
** 1.3       31.09.2006  SRA  Initial version for EC Release 9.1
** 1.6       29.09.2006  DR   Added function setObjCode for setting prefix and code number on split keys.
*****************************************************************/



FUNCTION setObjCode(
   p_object_id VARCHAR2 -- the split key
)
RETURN VARCHAR2
IS
BEGIN
     -- TODO:
     -- Logic for determining which Split_Type this Split Key is, and returning PR, FI, etc.
     -- followed by the next free number for this split type.
     RETURN 'PREL001'; -- Preliminary
END setObjCode;

FUNCTION GetSplitShareDay(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_daytime   DATE
)

RETURN NUMBER

IS

BEGIN

    RETURN ec_split_key_setup.split_share_day(p_object_id, p_target_id, p_daytime, '<=');

END GetSplitShareDay;


FUNCTION GetSplitShareMth(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_daytime   DATE,
   p_source_split_uom_code VARCHAR2 DEFAULT NULL,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY'
)

RETURN NUMBER

IS
/*
CURSOR c_split(pc_class_name VARCHAR2, pc_role_name VARCHAR2, pc_object_id VARCHAR2, pc_target_id VARCHAR2) IS
SELECT to_object_id id
FROM objects_relation
WHERE from_object_id = pc_object_id
  AND to_class_name = pc_class_name
  AND role_name = pc_role_name
  AND to_object_id != pc_target_id -- exclude the target object to save one loop entry
  AND p_daytime >= Nvl(start_date,p_daytime-1)
  AND p_daytime < Nvl(end_date,p_daytime+1)
  ;

ln_return_val NUMBER;
ln_target_val NUMBER;

lv2_target_uom VARCHAR2(32);

lv2_target_source objects.object_id%TYPE;

ln_sum_others NUMBER := 0;

lv2_class_name VARCHAR2(32);

lv2_split_key_object_id VARCHAR2(32);
*/
    lv2_sk_code VARCHAR2(32);
    lv2_target_code VARCHAR2(32);
    ln_share NUMBER;

BEGIN
    lv2_sk_code := ec_split_key.object_code(p_object_id);
    lv2_target_code := ec_stream_item.object_code(p_target_id);
    ln_share := ec_split_key_setup.split_share_mth(p_object_id, p_target_id, p_daytime, '<=');

    RETURN ln_share;

/*     IF (p_object_id IS NULL) THEN
        lv2_split_key_object_id :=  EcDp_Objects.GetObjIDFromRel(EcDp_Objects.GetObjIDFromRel(p_target_id, 'SPLIT_STREAM_ITEM', p_daytime), 'SPLIT_KEY', p_daytime);
     ELSE
        lv2_split_key_object_id := p_object_id;
     END IF;


     IF (p_role_name = 'SP_SPLIT_KEY') THEN -- always take percentage when SP call

               ln_return_val :=  EcDp_Objects.GetObjRelAttrValue(lv2_split_key_object_id,p_target_id,'SP_SPLIT_KEY',p_daytime,'SP_SPLIT_SHARE_MTH');
/ *
     ELSIF Nvl(EcDp_Objects.GetObjAttrText(lv2_split_key_object_id, p_daytime, 'SPLIT_KEY_METHOD'),'XXX') = 'SOURCE_SPLIT' THEN

          lv2_class_name := EcDp_Objects.GetObjClassName(p_target_id);

          -- need to call objects that support this method from their specific pck
          IF lv2_class_name = 'STREAM_ITEM' THEN

             lv2_target_source := EcDp_Objects.GetObjIDFromRel(p_target_id, 'SPLIT_STREAM_ITEM', p_daytime);

             -- determine which figure to use
             ln_target_val := EcDp_stream_item.GetSubGroupValue(ec_stim_mth_value.row_by_pk(lv2_target_source, Trunc(p_daytime,'MM') ),
                                                                EcDp_UOM.GetUOMGroup(p_source_split_uom_code, p_daytime),
                                                                EcDp_UOM.GetUOMSubGroup(p_source_split_uom_code, p_daytime)
                                                                );

             -- determine total sum for all stream items
             FOR SplitCur IN c_split(lv2_class_name, p_role_name, lv2_split_key_object_id, lv2_target_source) LOOP

                lv2_target_source := EcDp_Objects.GetObjIDFromRel(SplitCur.id, 'SPLIT_STREAM_ITEM', p_daytime);

                ln_sum_others := ln_sum_others + EcDp_stream_item.GetSubGroupValue(ec_stim_mth_value.row_by_pk(SplitCur.id, Trunc(p_daytime,'MM') ),
                                                                EcDp_UOM.GetUOMGroup(p_source_split_uom_code, p_daytime),
                                                                EcDp_UOM.GetUOMSubGroup(p_source_split_uom_code, p_daytime)
                                                                );

             END LOOP;

             BEGIN
                  ln_return_val := ln_target_val / (ln_sum_others + ln_target_val);
             EXCEPTION
                  WHEN ZERO_DIVIDE THEN
                       ln_return_val := 0;
             END;

          END IF;
* /
     ELSE -- normal split_key return

               ln_return_val :=  EcDp_Objects.GetObjRelAttrValue(lv2_split_key_object_id,p_target_id,'SPLIT_KEY',p_daytime,'SPLIT_SHARE_MTH');

     END IF;

     RETURN ln_return_val;
*/
END GetSplitShareMth;

FUNCTION GetTotShareMth(
   p_object_id VARCHAR2, -- the split key
   p_daytime   DATE,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY'
)

RETURN NUMBER

IS

CURSOR c_split_members IS
SELECT split_member_id id
FROM split_key_setup
WHERE object_id = p_object_id
  AND p_daytime >= daytime;
--  AND p_daytime < Nvl(end_date, p_daytime+1);


ln_tot_share NUMBER := 0;

BEGIN

     FOR SplitCur IN c_split_members LOOP

         ln_tot_share := ln_tot_share + GetSplitShareMth(p_object_id, SplitCur.id, p_daytime, NULL, p_role_name);

     END LOOP;

     RETURN ln_tot_share;

END GetTotShareMth;


FUNCTION GetSplitValueMth(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_daytime   DATE,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY',
   p_attribute_type VARCHAR2 DEFAULT 'SPLIT_VALUE_MTH'
)

RETURN NUMBER

IS
/*
CURSOR c_split(pc_class_name VARCHAR2) IS
SELECT to_object_id id
FROM objects_relation
WHERE from_object_id = p_object_id
  AND to_class_name = pc_class_name
  AND role_name = 'SPLIT_KEY'
  AND to_object_id != p_target_id -- exclude the target object to save one loop entry
  AND p_daytime >= Nvl(start_date,p_daytime-1)
  AND p_daytime < Nvl(end_date,p_daytime+1)
  ;

ln_return_val NUMBER;
lv2_target_source objects.object_id%TYPE;
lv2_class_name VARCHAR2(32);
*/
BEGIN
    RETURN ec_split_key_setup.split_value_mth(p_object_id, p_target_id, p_daytime, '<=');

/*
/ *
     IF Nvl(EcDp_Objects.GetObjAttrText(p_object_id, p_daytime, 'SPLIT_KEY_METHOD'),'XXX') = 'SOURCE_SPLIT' THEN

          lv2_class_name := EcDp_Objects.GetObjClassName(p_target_id);

          -- need to call objects that support this method from their specific pck
          IF lv2_class_name = 'STREAM_ITEM' THEN

             lv2_target_source := EcDp_Objects.GetObjIDToRel(p_target_id, 'SPLIT_STREAM_ITEM', p_daytime);

             -- determine which figure to use
             ln_return_val := EcDp_stream_item.GetMthMasterQty(lv2_target_source, p_daytime);

          END IF;

     ELSE
* /
          ln_return_val :=  EcDp_Objects.GetObjRelAttrValue(p_object_id,p_target_id,p_role_name,p_daytime,p_attribute_type);

--     END IF;

     RETURN ln_return_val;
*/
END GetSplitValueMth;

PROCEDURE InsSplit(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_share_name VARCHAR2,
   p_value_name VARCHAR2,
   p_daytime   DATE,
   p_end_date  DATE DEFAULT NULL,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY',
   p_user      VARCHAR2 DEFAULT NULL
)

IS
/*
lv2_rel_id objects_relation.object_id%TYPE;
ln_sum_val NUMBER := 0;
*/
BEGIN

    INSERT INTO split_key_setup (object_id,
                                 split_member_id,
                                 class_name,
                                 daytime,
                                 split_share_mth,
                                 split_value_mth,
                                 comments_mth,
                                 split_share_day,
                                 split_value_day,
                                 comments_day) VALUES (
                                 p_object_id,
                                 p_target_id,
                                 EcDp_Objects.GetObjClassName(p_target_id),
                                 p_daytime,
                                 0,
                                 0,
                                 NULL,
                                 0,
                                 0,
                                 NULL);

/*
     SELECT Sum(attribute_value)
     INTO ln_sum_val
      FROM objects_rel_attribute
      WHERE object_id In
         (SELECT object_id
          FROM objects_relation
          WHERE from_object_id =  p_object_id)
      AND attribute_type = p_value_name
      AND daytime = p_daytime;

     -- Try to insert relation
     BEGIN
        lv2_rel_id := ECDP_OBJECTS.InsObjRel(p_object_id, p_target_id, p_role_name, p_daytime, p_end_date, p_user, p_user);
     EXCEPTION
        -- if relation already exists, just set end_date to end_date of the split_key object
        WHEN DUP_VAL_ON_INDEX THEN

            SELECT object_id
            INTO lv2_rel_id
            FROM objects_relation
            WHERE from_object_id = p_object_id
            AND to_object_id = p_target_id
            AND role_name = p_role_name
            AND start_date = p_daytime;

            EcDp_Objects.SetObjRelEndDate(lv2_rel_id,EcDp_Objects.GetObjEndDate(p_object_id),p_daytime,p_user);
     END;

     ECDP_OBJECTS.SetObjRelAttrValue(lv2_rel_id, p_daytime, p_share_name, 0, 'FALSE', p_user, p_user);
     IF ln_sum_val > 0 THEN
          ECDP_OBJECTS.SetObjRelAttrValue(lv2_rel_id, p_daytime, p_value_name, 0, 'FALSE', p_user, p_user);
     END IF;

    RETURN lv2_rel_id;
*/
END InsSplit;

PROCEDURE DelSplit(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_share_name VARCHAR2,
   p_value_name VARCHAR2,
   p_daytime   DATE,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY',
   p_user      VARCHAR2 DEFAULT NULL,
   p_reset_shares VARCHAR2 DEFAULT 'TRUE',
   p_validate_on_presave   VARCHAR2 DEFAULT 'FALSE'

)

IS

ln_split_share NUMBER;

share_exists EXCEPTION;
/*
p_rel_obj_id objects_relation.object_id%TYPE;

*/
BEGIN
    ln_split_share := GetSplitShareMth(p_object_id, p_target_id, p_daytime, NULL,p_role_name);
    IF nvl(ln_split_share,0) <> 0 THEN

        RAISE share_exists;

    END IF;

    DELETE FROM split_key_setup
    WHERE
        object_id = p_object_id
        AND split_member_id = p_target_id;

     IF p_reset_shares = 'TRUE' THEN

         DelSplitShare(p_object_id, p_share_name, p_daytime, p_user);

     END IF;

--  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*     SELECT object_id
     INTO p_rel_obj_id
     FROM objects_relation
     WHERE from_object_id = p_object_id
     AND to_object_id = p_target_id
     AND start_date = p_daytime;

     -- works only for monthly split shares
     IF p_validate_on_presave = 'TRUE' THEN

        ln_split_share := GetSplitShareMth(p_object_id,p_target_id,p_daytime,NULL,p_role_name);

        IF nvl(ln_split_share,0) <> 0 THEN

            RAISE share_exists;

        END IF;

     END IF;


     ECDP_OBJECTS.DelObjRelByDate(p_object_id, p_target_id, p_role_name, p_daytime);

     UpdateShare(p_object_id, p_share_name, p_value_name, p_daytime, p_user);
*/
EXCEPTION

    WHEN share_exists THEN

             Raise_Application_Error(-20000,'Share must be zero in order to remove ' || EcDp_Objects.GetObjName(p_target_id,p_daytime) || ' from split.');

END DelSplit;

PROCEDURE InsNewSourceSplit(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_target_source_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY'
)

IS
/*
lv2_rel_id objects_relation.object_id%TYPE;
ld_end_date DATE := Ecdp_Objects.GetObjEndDate(p_object_id);
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
    -- insert source link
    BEGIN
        lv2_rel_id := EcDp_Objects.InsNewObjRel(p_target_id, p_target_source_id, 'SPLIT_STREAM_ITEM', p_daytime, ld_end_date, p_user, p_user);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- relation already exists, don't do anything
    END;

    -- insert link
     BEGIN
        lv2_rel_id := EcDp_Objects.InsNewObjRel(p_object_id, p_target_id, p_role_name, p_daytime, ld_end_date, p_user, p_user);
     EXCEPTION
        -- if relation already exists, just set end_date to end_date of the split_key object
        WHEN DUP_VAL_ON_INDEX THEN

            SELECT object_id
            INTO lv2_rel_id
            FROM objects_relation
            WHERE from_object_id = p_object_id
            AND to_object_id = p_target_id
            AND role_name = p_role_name
            AND start_date = p_daytime;

            EcDp_Objects.SetObjRelEndDate(lv2_rel_id,EcDp_Objects.GetObjEndDate(p_object_id),p_daytime,p_user);
     END;


    RETURN lv2_rel_id;
*/
END InsNewSourceSplit;



FUNCTION InsNewSplitKey(
   p_object_id VARCHAR2,
   p_object_code VARCHAR2,
   p_start_date   DATE,
   p_end_date  DATE,
   p_user      VARCHAR2,
   p_object_name VARCHAR2 DEFAULT NULL,
   p_split_type varchar2
) RETURN VARCHAR2
IS
  lv2_purpose VARCHAR2(2) := NULL;
  lv2_object_id VARCHAR2(32);
  -- ** 4-eyes approval stuff ** --
  lv2_4e_recid VARCHAR2(32);
  -- ** END 4-eyes approval stuff ** --
  lv2_object_name VARCHAR2(240);
BEGIN

     IF instr(p_object_code,'CSK:') = 1 THEN
        lv2_purpose := 'SP';
     END IF;

     IF p_object_name IS NULL THEN
       lv2_object_name := p_object_code;
     ELSE
       lv2_object_name := p_object_name;
     END IF;

     IF (p_object_id IS NOT NULL) THEN
         INSERT INTO split_key
           (object_id, object_code, start_date, end_date, created_by)
         VALUES
           (p_object_id, p_object_code, p_start_date, p_end_date, p_user);

         INSERT INTO split_key_version
           (object_id, name, daytime, end_date, created_by, purpose, split_type)
         VALUES
           (p_object_id, lv2_object_name, p_start_date, p_end_date, p_user, lv2_purpose, p_split_type);
         lv2_object_id := p_object_id;
     ELSE
         INSERT INTO split_key
           (object_code, start_date, end_date, created_by)
         VALUES
           (p_object_code, p_start_date, p_end_date, p_user)
         RETURNING object_id INTO lv2_object_id;

         INSERT INTO split_key_version
           (object_id, name, daytime, end_date, created_by, purpose, split_type)
         VALUES
           (lv2_object_id, lv2_object_name, p_start_date, p_end_date, p_user, lv2_purpose, p_split_type);
     END IF;

    -- ** 4-eyes approval logic ** --
    IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('SPLIT_KEY'),'N') = 'Y' THEN

      -- Generate rec_id for the new record
      lv2_4e_recid := SYS_GUID();

      -- Set approval info on new record.
      UPDATE split_key_version
      SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
          last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
          approval_state = 'N',
          rec_id = lv2_4e_recid,
          rev_no = (nvl(rev_no,0) + 1)
      WHERE object_id = (CASE WHEN p_object_id IS NOT NULL THEN p_object_id ELSE lv2_object_id END)
      AND daytime = p_start_date;

      -- Register new record for approval
      Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                        'SPLIT_KEY',
                                        Nvl(EcDp_Context.getAppUser,User));
    END IF;
    -- ** END 4-eyes approval ** --

     IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('SPLIT_KEY'),'N') = 'Y') THEN
				EcDp_Acl.RefreshObject(lv2_object_id, 'SPLIT_KEY', 'INSERTING');
		 END IF;

     RETURN lv2_object_id;
END InsNewSplitKey;


FUNCTION InsNewSplitKeyCopy(
   p_object_id VARCHAR2,
   p_object_code VARCHAR2,
   p_start_date   DATE,
   p_end_date    DATE DEFAULT NULL, -- WYH: Should be able to accept the new end date if available
   p_user      VARCHAR2,
   p_copy_first_version_only BOOLEAN DEFAULT FALSE
) RETURN VARCHAR2
--</EC-DOC>
IS
lv2_object_id VARCHAR2(32) := NULL;
lv2_purpose VARCHAR2(2) := NULL;

CURSOR c_split_key IS
SELECT * FROM split_key
WHERE object_id = p_object_id
AND start_date <= p_start_date;

CURSOR c_split_key_version IS
SELECT * FROM split_key_version
WHERE object_id = p_object_id
AND daytime <= p_start_date;

BEGIN

     IF instr(p_object_code,'CSK:') = 1 THEN
        lv2_purpose := 'SP';
     END IF;

     IF (p_object_id IS NOT NULL) THEN

         FOR SplitKey IN c_split_key LOOP
             INSERT INTO split_key (OBJECT_CODE,
                                    START_DATE,
                                    END_DATE,
                                    DESCRIPTION)
             VALUES (p_object_code
                     ,NVL(p_start_date, SplitKey.Start_Date) --WYH - should use start date that is passed in rather than the copied from start_date
                     ,decode(SplitKey.end_date, NULL, NULL, p_end_date)  --WYH - should use new end date if available
                     ,SplitKey.Description)
             RETURNING object_id INTO lv2_object_id;
         END LOOP;

         FOR SplitKeyVersion IN c_split_key_version LOOP
             INSERT INTO split_key_version (OBJECT_ID,
                                            DAYTIME,
                                            END_DATE,
                                            NAME,
                                            SPLIT_TYPE,
                                            SPLIT_KEY_METHOD,
                                            SOURCE_CODE,
                                            PURPOSE,
                                            COMMENTS)
             VALUES (lv2_object_id
                     ,NVL(p_start_date, SplitKeyVersion.Daytime) --WYH - should use start date that is passed in rather than the copied from start_date
                     ,decode(SplitKeyVersion.end_date, NULL, NULL, p_end_date)  --WYH - should use new end date if available
                     ,SplitKeyVersion.Name
                     ,SplitKeyVersion.Split_Type
                     ,SplitKeyVersion.Split_Key_Method
                     ,SplitKeyVersion.Source_Code
                     ,lv2_purpose
                     ,SplitKeyVersion.Comments);

             IF p_copy_first_version_only THEN
                 EXIT;
             END IF;
         END LOOP;

     END IF;

		 IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('SPLIT_KEY'),'N') = 'Y') THEN
				EcDp_Acl.RefreshObject(lv2_object_id, 'SPLIT_KEY', 'INSERTING');
		 END IF;

     RETURN lv2_object_id;

END InsNewSplitKeyCopy;

PROCEDURE CopySplitKeyMembers(
   p_old_object_id VARCHAR2,
   p_new_object_id VARCHAR2,
   p_start_date   DATE,
   p_user      VARCHAR2,
   p_source_date DATE DEFAULT NULL
)
IS

lv2_object_id VARCHAR2(32) := NULL;

CURSOR c_split_key_members IS
SELECT * FROM split_key_setup sks
WHERE sks.object_id = p_old_object_id
AND ( ( p_source_date IS NULL AND sks.daytime = (SELECT max(daytime) FROM split_key_setup WHERE object_id = sks.object_id AND daytime <= p_start_date) )
OR (p_source_date IS NOT NULL AND  sks.daytime = (SELECT max(daytime) FROM split_key_setup WHERE object_id = sks.object_id AND daytime <= p_source_date) )
)
;

-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

BEGIN

       FOR SplitKeyMembers IN c_split_key_members LOOP
             INSERT INTO split_key_setup (OBJECT_ID,
                                          SPLIT_MEMBER_ID,
                                          CLASS_NAME,
                                          DAYTIME,
                                          SPLIT_SHARE_MTH,
                                          SPLIT_VALUE_MTH,
                                          COMMENTS_MTH,
                                          SPLIT_SHARE_DAY,
                                          SPLIT_VALUE_DAY,
                                          PROFIT_CENTRE_ID,
                                          COMMENTS_DAY,
                                          COMMENTS,
                                          SOURCE_MEMBER_ID,
                                          CHILD_SPLIT_KEY_METHOD,
                                          CREATED_BY)
             VALUES (p_new_object_id
                     ,SplitKeyMembers.Split_Member_Id
                     ,SplitKeyMembers.Class_Name
                     ,p_start_date  --WYH p_start_date should be used
                     ,SplitKeyMembers.Split_Share_Mth
                     ,SplitKeyMembers.Split_Value_Mth
                     ,SplitKeyMembers.Comments_Mth
                     ,SplitKeyMembers.Split_Share_Day
                     ,SplitKeyMembers.Split_Value_Day
                     ,SplitKeyMembers.profit_centre_id
                     ,SplitKeyMembers.Comments_Day
                     ,SplitKeyMembers.Comments
                     ,SplitKeyMembers.Source_Member_Id
                     ,SplitKeyMembers.Child_Split_Key_Method
                     ,p_user);

              -- ** 4-eyes approval logic ** --
              IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('SPLIT_KEY_SETUP'),'N') = 'Y' THEN

                -- Generate rec_id for the latest version record
                lv2_4e_recid := SYS_GUID();

                -- Set approval info on latest version record.
                UPDATE split_key_setup
                SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                    last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                    approval_state = 'N',
                    rec_id = lv2_4e_recid,
                    rev_no = (nvl(rev_no,0) + 1)
                WHERE object_id = p_new_object_id
                AND daytime = SplitKeyMembers.Daytime
                AND split_member_id = SplitKeyMembers.Split_Member_Id;

                -- Register version record for approval
                Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                                  SplitKeyMembers.Class_Name, --use class-name of insert into SPLIT_KEY_SETUP table
                                                  Nvl(EcDp_Context.getAppUser,User));
              END IF;
              -- ** END 4-eyes approval ** --

         END LOOP;

END CopySplitKeyMembers;

PROCEDURE InsNewSplitKeyVersion(
   p_object_id VARCHAR2,
   p_start_date   DATE,
   p_end_date  DATE,
   p_user      VARCHAR2,
   p_use_same_child_split_key BOOLEAN DEFAULT FALSE
)
IS

CURSOR c_sk_version IS
SELECT * FROM split_key_version skv
WHERE skv.object_id = p_object_id
AND skv.daytime = (SELECT max(daytime) FROM split_key_version skv2 WHERE object_id = p_object_id AND daytime < p_start_date);

CURSOR c_sk_setup IS
SELECT *
  FROM split_key_setup sks
 WHERE sks.object_id = p_object_id
   AND sks.daytime = (SELECT MAX(daytime)
                        FROM split_key_setup sks2
                       WHERE object_id = p_object_id
                         AND daytime < p_start_date)
   --This to exclude split_key_setup records have been added by trigger
   --IUR_SPLIT_KEY_VERSION which calls EcDp_Split_Key.CopySplitKeySetupForNewVersion()
   --which also inserts into split_key_setup.
   AND NOT EXISTS (SELECT DAYTIME FROM
        split_key_setup sks2
                       WHERE object_id = p_object_id
                         AND daytime = p_start_date);


BEGIN
    -- Set End Date on previous version to current start date
    UPDATE split_key_version skv SET end_date = p_start_date
    WHERE skv.object_id = p_object_id
    AND skv.daytime = (SELECT max(daytime) FROM split_key_version skv2 WHERE object_id = p_object_id AND daytime < p_start_date);

    -- Insert new version of the existing split key
    FOR SplitCur IN c_sk_version LOOP
             INSERT INTO split_key_version (OBJECT_ID,
                                            DAYTIME,
                                            END_DATE,
                                            NAME,
                                            SPLIT_TYPE,
                                            SPLIT_KEY_METHOD,
                                            SOURCE_CODE,
                                            PURPOSE,
                                            COMMENTS,
                                            CREATED_BY)
             VALUES (SplitCur.Object_Id
                     ,p_start_date
                     ,p_end_date
                     ,SplitCur.Name
                     ,SplitCur.Split_Type
                     ,SplitCur.Split_Key_Method
                     ,SplitCur.Source_Code
                     ,SplitCur.Purpose
                     ,SplitCur.Comments
                     ,p_user);
    END LOOP;

    -- Insert new version of the existing split key members
    FOR SplitCurSetup IN c_sk_setup LOOP
        IF p_use_same_child_split_key THEN
             INSERT INTO split_key_setup (OBJECT_ID,
                                          SPLIT_MEMBER_ID,
                                          CLASS_NAME,
                                          DAYTIME,
                                          SPLIT_SHARE_MTH,
                                          SPLIT_VALUE_MTH,
                                          COMMENTS_MTH,
                                          SPLIT_SHARE_DAY,
                                          SPLIT_VALUE_DAY,
                                          PROFIT_CENTRE_ID,
                                          COMMENTS_DAY,
                                          COMMENTS,
                                          SOURCE_MEMBER_ID,
                                          CREATED_BY,
                                          CHILD_SPLIT_KEY_ID,
                                          CHILD_SPLIT_KEY_METHOD)
             VALUES (SplitCurSetup.Object_Id
                     ,SplitCurSetup.Split_Member_Id
                     ,SplitCurSetup.Class_Name
                     ,p_start_date
                     ,SplitCurSetup.Split_Share_Mth
                     ,SplitCurSetup.Split_Value_Mth
                     ,SplitCurSetup.Comments_Mth
                     ,SplitCurSetup.Split_Share_Day
                     ,SplitCurSetup.Split_Value_Day
                     ,SplitCurSetup.Profit_Centre_Id
                     ,SplitCurSetup.Comments_Day
                     ,SplitCurSetup.Comments
                     ,SplitCurSetup.Source_Member_Id
                     ,p_user
                     ,SplitCurSetup.Child_Split_Key_Id
                     ,SplitCurSetup.CHILD_SPLIT_KEY_METHOD);
        ELSE
             INSERT INTO split_key_setup (OBJECT_ID,
                                          SPLIT_MEMBER_ID,
                                          CLASS_NAME,
                                          DAYTIME,
                                          SPLIT_SHARE_MTH,
                                          SPLIT_VALUE_MTH,
                                          COMMENTS_MTH,
                                          SPLIT_SHARE_DAY,
                                          SPLIT_VALUE_DAY,
                                          PROFIT_CENTRE_ID,
                                          COMMENTS_DAY,
                                          COMMENTS,
                                          SOURCE_MEMBER_ID,
                                          CREATED_BY,
                                          CHILD_SPLIT_KEY_ID,
                                          CHILD_SPLIT_KEY_METHOD)
             VALUES (SplitCurSetup.Object_Id
                     ,SplitCurSetup.Split_Member_Id
                     ,SplitCurSetup.Class_Name
                     ,p_start_date
                     ,SplitCurSetup.Split_Share_Mth
                     ,SplitCurSetup.Split_Value_Mth
                     ,SplitCurSetup.Comments_Mth
                     ,SplitCurSetup.Split_Share_Day
                     ,SplitCurSetup.Split_Value_Day
                     ,SplitCurSetup.Profit_Centre_Id
                     ,SplitCurSetup.Comments_Day
                     ,SplitCurSetup.Comments
                     ,SplitCurSetup.Source_Member_Id
                     ,p_user
                     ,SplitCurSetup.Child_Split_Key_Id
                     ,SplitCurSetup.CHILD_SPLIT_KEY_METHOD);
        END IF;
    END LOOP;

END;



PROCEDURE DelSourceSplit(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_target_source_id VARCHAR2,
   p_daytime   DATE,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY'
)

IS

BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
    -- insert source link
    EcDp_Objects.DelObjRel(p_target_id, p_target_source_id, 'SPLIT_STREAM_ITEM', p_daytime);

    -- insert link
    EcDp_Objects.DelObjRel(p_object_id, p_target_id, p_role_name, p_daytime);
*/
END DelSourceSplit;

PROCEDURE UpdateShare(
   p_rel_to_obj_id VARCHAR2,
   p_share_name VARCHAR2,
   p_value_name VARCHAR2,
   p_daytime DATE,
   p_user    VARCHAR2 DEFAULT NULL
)

IS
/*
  CURSOR c_rel_attr IS
  SELECT *
  FROM objects_rel_attribute
  WHERE object_id In
     (SELECT object_id
      FROM objects_relation
      WHERE from_object_id =  p_rel_to_obj_id)
  AND attribute_type = p_value_name
 AND daytime = p_daytime;

  ln_max_share NUMBER := 0;
  ln_max_share_11 NUMBER(12,11) := 0; -- (12,11) since share may be 1.00000000000
  ln_share NUMBER;
  ln_share_11 NUMBER(12,11);
  ln_sum_share NUMBER := 0;
  ln_sum_share_11 NUMBER(12,11) := 0;
  ln_delta_share NUMBER;
  ln_sum_val NUMBER := 0;
  ln_max_share_obj_id objects_rel_attribute.object_id%TYPE;
  ln_terminate BOOLEAN := false;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
     -- If value is NULL then break

     SELECT Sum(attribute_value)
     INTO ln_sum_val
      FROM objects_rel_attribute
      WHERE object_id In
         (SELECT object_id
          FROM objects_relation
          WHERE from_object_id =  p_rel_to_obj_id)
      AND attribute_type = p_value_name
      AND daytime = p_daytime;

     FOR RelAttrCur IN c_rel_attr LOOP
         IF RelAttrCur.attribute_value is NULL THEN
            ln_terminate := true;
            EXIT;
         END IF;

         IF ln_sum_val = 0 THEN
           ln_share := 0;
         ELSE
           ln_share := RelAttrCur.attribute_value / ln_sum_val;
         END IF;
         ln_share_11 := ln_share;
         ln_sum_share_11 := ln_sum_share_11+ln_share_11;
         ln_sum_share := ln_sum_share+ln_share;
         IF ln_share > ln_max_share THEN
            ln_max_share := ln_share;
            ln_max_share_obj_id := RelAttrCur.object_id;
         END IF;

         UPDATE objects_rel_attribute
         SET attribute_value = ln_share_11
             ,last_updated_by = p_user
         WHERE object_id = RelAttrCur.object_id
          AND attribute_type = p_share_name
          AND daytime = p_daytime;

     END LOOP;

     IF ln_terminate = false THEN
       --ln_sum_share_11 := ln_sum_share;
       ln_delta_share := ln_sum_share - ln_sum_share_11;
       ln_max_share_11 := ln_max_share + ln_delta_share;

       UPDATE objects_rel_attribute
       SET attribute_value = ln_max_share_11
             ,last_updated_by = p_user
       WHERE object_id = ln_max_share_obj_id
        AND attribute_type = p_share_name
        AND daytime = p_daytime;
     END IF;
*/
END UpdateShare;

PROCEDURE DelSplitShare(
     p_object_id VARCHAR2,
     p_share_name VARCHAR2,
     P_daytime DATE,
     p_user    VARCHAR2 DEFAULT NULL
)

IS
/*
  CURSOR c_split_share IS
  SELECT *
  FROM objects_rel_attribute
  WHERE object_id In
     (SELECT object_id
      FROM objects_relation
      WHERE from_object_id =  p_object_id)
  AND attribute_type = p_share_name
  AND daytime = p_daytime;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
     FOR SplitCur IN c_split_share LOOP
         UPDATE objects_rel_attribute
         SET attribute_value = 0,
             daytime = SplitCur.daytime,
             end_date = SplitCur.end_date,
             last_updated_by = p_user
         WHERE object_id = SplitCur.object_id
          AND attribute_type = p_share_name
          AND daytime = p_daytime;
     END LOOP;
*/
END DelSplitShare;

FUNCTION checkSplitUoms(
   p_object_id VARCHAR2,
   p_type VARCHAR2, -- MTH or DAY
   p_daytime   DATE
)
RETURN NUMBER
IS
/*
CURSOR c_mth_split_items IS
SELECT count(distinct(EcDp_Stream_Item.GetMthMasterUom(to_object_id, p_daytime))) counter
FROM
   objects_relation
WHERE
   from_object_id =  p_object_id
   AND to_class_name = 'STREAM_ITEM'
   AND start_date <= p_daytime
   AND NVL(end_date, p_daytime - 1)  < p_daytime;

CURSOR c_day_split_items IS
SELECT count(distinct(EcDp_Stream_Item.GetDayMasterUom(to_object_id, p_daytime))) counter
FROM
   objects_relation
WHERE
   from_object_id =  p_object_id
   AND to_class_name = 'STREAM_ITEM'
   AND start_date <= p_daytime
   AND NVL(end_date, p_daytime - 1)  < p_daytime;

ln_counter NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
   ln_counter := 0;

   IF (p_type = 'MTH') THEN
      FOR SplitCur IN c_mth_split_items LOOP
         ln_counter := ln_counter + SplitCur.counter;
      END LOOP;
   ELSIF (p_type = 'DAY') THEN
      FOR SplitCur IN c_day_split_items LOOP
         ln_counter := ln_counter + SplitCur.counter;
      END LOOP;
   ELSE
      ln_counter := null;
   END IF;

   IF (ln_counter IS NOT NULL AND ln_counter <> 1) THEN
      ln_counter := null;
   END IF;

   RETURN ln_counter;
*/
END checkSplitUoms;
















/**
 * "OLD" company_split_key
 */















PROCEDURE InsNewCustVendRevision(
   p_contract_obj_id VARCHAR2,
   p_vendor_sk_to_obj_id VARCHAR2,
   p_customer_sk_to_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_user VARCHAR2
)


IS
/*
CURSOR c_bank_rel IS
SELECT *
FROM objects_relation,
  (SELECT Max(start_date) max_start_date
  FROM objects_relation
  WHERE from_object_id = p_contract_obj_id
    AND role_name IN ('VENDOR_BANK_ACCT','CUSTOMER_BANK_ACCT')
    AND to_class_name = 'BANK_ACCOUNT'
    AND start_date < p_rel_attr_daytime) last_revision
WHERE start_date = last_revision.max_start_date
    AND from_object_id = p_contract_obj_id
    AND role_name IN ('VENDOR_BANK_ACCT','CUSTOMER_BANK_ACCT')
    AND to_class_name = 'BANK_ACCOUNT';

CURSOR c_vendor_rel IS
SELECT *
FROM objects_relation,
  (SELECT Max(start_date) max_start_date
  FROM objects_relation
  WHERE from_object_id = p_vendor_sk_to_obj_id
    AND role_name = 'SPLIT_KEY'
    AND to_class_name = 'VENDOR'
    AND start_date < p_rel_attr_daytime) last_revision
WHERE start_date = last_revision.max_start_date
    AND from_object_id = p_vendor_sk_to_obj_id
    AND role_name = 'SPLIT_KEY'
    AND to_class_name = 'VENDOR';

CURSOR c_customer_rel IS
SELECT *
FROM objects_relation,
  (SELECT Max(start_date) max_start_date
  FROM objects_relation
  WHERE from_object_id = p_customer_sk_to_obj_id
    AND role_name = 'SPLIT_KEY'
    AND to_class_name = 'CUSTOMER'
    AND start_date < p_rel_attr_daytime) last_revision
WHERE start_date = last_revision.max_start_date
    AND from_object_id = p_customer_sk_to_obj_id
    AND role_name = 'SPLIT_KEY'
    AND to_class_name = 'CUSTOMER';

CURSOR c_vendor_sk_rel IS
SELECT *
FROM objects_relation,
  (SELECT Max(start_date) max_start_date
  FROM objects_relation
  WHERE from_object_id = p_contract_obj_id
    AND role_name = 'VENDOR_SPLIT_KEY'
    AND to_class_name = 'SPLIT_KEY'
    AND start_date < p_rel_attr_daytime) last_revision
WHERE start_date = last_revision.max_start_date
    AND from_object_id = p_contract_obj_id
    AND role_name = 'VENDOR_SPLIT_KEY'
    AND to_class_name = 'SPLIT_KEY';

CURSOR c_customer_sk_rel IS
SELECT *
FROM objects_relation,
  (SELECT Max(start_date) max_start_date
  FROM objects_relation
  WHERE from_object_id = p_contract_obj_id
    AND role_name = 'CUSTOMER_SPLIT_KEY'
    AND to_class_name = 'SPLIT_KEY'
    AND start_date < p_rel_attr_daytime) last_revision
WHERE start_date = last_revision.max_start_date
    AND from_object_id = p_contract_obj_id
    AND role_name = 'CUSTOMER_SPLIT_KEY'
    AND to_class_name = 'SPLIT_KEY';

lv2_rel_id objects_relation.object_id%TYPE;
lv2_min_start_date DATE;
lv2_max_end_date DATE;
lv2_max_start_date DATE;
p_contract_end_date DATE;

illegal_revision_date EXCEPTION;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
    p_contract_end_date := EcDp_Objects.GetObjEndDate(p_contract_obj_id);

    IF p_rel_attr_daytime >= p_contract_end_date THEN
    		RAISE illegal_revision_date;
    END IF;

     SELECT Max(Nvl(end_date,To_date('9999','YYYY')))
     INTO lv2_max_end_date
     FROM objects_relation
     WHERE from_object_id = p_contract_obj_id
      AND role_name = 'VENDOR_SPLIT_KEY'
      AND to_class_name = 'SPLIT_KEY'
      AND start_date < p_rel_attr_daytime;

      IF lv2_max_end_date = To_date('9999','YYYY') THEN
         lv2_max_end_date := NULL;
      END IF;

     SELECT Min(start_date)
     INTO lv2_min_start_date
     FROM objects_relation
     WHERE from_object_id = p_contract_obj_id
      AND role_name = 'VENDOR_SPLIT_KEY'
      AND to_class_name = 'SPLIT_KEY'
      AND start_date > p_rel_attr_daytime;

     FOR VSKRelCur IN c_vendor_sk_rel LOOP

         INSERT INTO objects_relation
         (from_object_id, from_class_name, to_object_id, to_class_name, role_name, start_date, end_date, created_by, last_updated_by)
         VALUES
         (p_contract_obj_id, 'CONTRACT', VSKRelCur.to_object_id, 'SPLIT_KEY', 'VENDOR_SPLIT_KEY', p_rel_attr_daytime, Nvl(lv2_min_start_date,lv2_max_end_date), p_user, p_user)
         RETURNING object_id INTO lv2_rel_id;
         ECDP_OBJECTS.SetObjRelEndDate(lv2_rel_id, Nvl(lv2_min_start_date,lv2_max_end_date), null,p_user);
         ECDP_OBJECTS.SetObjRelEndDate(VSKRelCur.object_id, p_rel_attr_daytime, VSKRelCur.end_date,p_user);

     END LOOP;

     SELECT Max(Nvl(end_date,To_date('9999','YYYY')))
     INTO lv2_max_end_date
     FROM objects_relation
     WHERE from_object_id = p_contract_obj_id
      AND role_name = 'CUSTOMER_SPLIT_KEY'
      AND to_class_name = 'SPLIT_KEY'
      AND start_date < p_rel_attr_daytime;

      IF lv2_max_end_date = To_date('9999','YYYY') THEN
         lv2_max_end_date := NULL;
      END IF;

     SELECT Min(start_date)
     INTO lv2_min_start_date
     FROM objects_relation
     WHERE from_object_id = p_contract_obj_id
      AND role_name = 'CUSTOMER_SPLIT_KEY'
      AND to_class_name = 'SPLIT_KEY'
      AND start_date > p_rel_attr_daytime;

     FOR CSKRelCur IN c_customer_sk_rel LOOP

         INSERT INTO objects_relation
         (from_object_id, from_class_name, to_object_id, to_class_name, role_name, start_date, end_date, created_by, last_updated_by)
         VALUES
         (p_contract_obj_id, 'CONTRACT', CSKRelCur.to_object_id, 'SPLIT_KEY', 'CUSTOMER_SPLIT_KEY', p_rel_attr_daytime, Nvl(lv2_min_start_date,lv2_max_end_date), p_user, p_user)
         RETURNING object_id INTO lv2_rel_id;
         ECDP_OBJECTS.SetObjRelEndDate(lv2_rel_id, Nvl(lv2_min_start_date,lv2_max_end_date), null,p_user);
         ECDP_OBJECTS.SetObjRelEndDate(CSKRelCur.object_id, p_rel_attr_daytime, CSKRelCur.end_date,p_user);

     END LOOP;

     SELECT Max(Nvl(end_date,To_date('9999','YYYY')))
     INTO lv2_max_end_date
     FROM objects_relation
     WHERE from_object_id = p_vendor_sk_to_obj_id
      AND role_name = 'SPLIT_KEY'
      AND to_class_name = 'VENDOR'
      AND start_date < p_rel_attr_daytime;

      IF lv2_max_end_date = To_date('9999','YYYY') THEN
         lv2_max_end_date := NULL;
      END IF;

     SELECT Min(start_date)
     INTO lv2_min_start_date
     FROM objects_relation
     WHERE from_object_id = p_vendor_sk_to_obj_id
      AND role_name = 'SPLIT_KEY'
      AND to_class_name = 'VENDOR'
      AND start_date > p_rel_attr_daytime;

     FOR VRelCur IN c_vendor_rel LOOP

         INSERT INTO objects_relation
         (from_object_id, from_class_name, to_object_id, to_class_name, role_name, start_date, end_date, created_by, last_updated_by)
         VALUES
         (VRelCur.from_object_id, VRelCur.from_class_name, VRelCur.to_object_id, VRelCur.to_class_name, VRelCur.role_name, p_rel_attr_daytime, Nvl(lv2_min_start_date,lv2_max_end_date), p_user, p_user)
         RETURNING object_id INTO lv2_rel_id;

         ECDP_OBJECTS.InsObjRelAttrAllCopy(VRelCur.object_id, lv2_rel_id, p_rel_attr_daytime, lv2_min_start_date);
         ECDP_OBJECTS.SetObjRelEndDate(lv2_rel_id, Nvl(lv2_min_start_date,lv2_max_end_date), null,p_user);
         ECDP_OBJECTS.SetObjRelEndDate(VRelCur.object_id, p_rel_attr_daytime, VRelCur.end_date, p_user);

     END LOOP;

     SELECT Max(Nvl(end_date,To_date('9999','YYYY')))
     INTO lv2_max_end_date
     FROM objects_relation
     WHERE from_object_id = p_customer_sk_to_obj_id
      AND role_name = 'SPLIT_KEY'
      AND to_class_name = 'CUSTOMER'
      AND start_date < p_rel_attr_daytime;

      IF lv2_max_end_date = To_date('9999','YYYY') THEN
         lv2_max_end_date := NULL;
      END IF;

     SELECT Min(start_date)
     INTO lv2_min_start_date
     FROM objects_relation
     WHERE from_object_id = p_customer_sk_to_obj_id
      AND role_name = 'SPLIT_KEY'
      AND to_class_name = 'CUSTOMER'
      AND start_date > p_rel_attr_daytime;

     FOR CRelCur IN c_customer_rel LOOP

         INSERT INTO objects_relation
         (from_object_id, from_class_name, to_object_id, to_class_name, role_name, start_date, end_date, created_by, last_updated_by)
         VALUES
         (CRelCur.from_object_id, CRelCur.from_class_name, CRelCur.to_object_id, CRelCur.to_class_name, CRelCur.role_name, p_rel_attr_daytime, Nvl(lv2_min_start_date,lv2_max_end_date), p_user, p_user)
         RETURNING object_id INTO lv2_rel_id;

         ECDP_OBJECTS.InsObjRelAttrAllCopy(CRelCur.object_id, lv2_rel_id, p_rel_attr_daytime, lv2_min_start_date);
         ECDP_OBJECTS.SetObjRelEndDate(lv2_rel_id, Nvl(lv2_min_start_date,lv2_max_end_date), null,p_user);
         ECDP_OBJECTS.SetObjRelEndDate(CRelCur.object_id, p_rel_attr_daytime, CRelCur.end_date,p_user);

     END LOOP;

    -- copy relation from contract to bank account and update end_date on old relation.
     FOR RelCur IN c_bank_rel LOOP

         lv2_rel_id := ECDP_OBJECTS.insnewobjrel(p_contract_obj_id, RelCur.to_object_id, RelCur.role_name, p_rel_attr_daytime, null, p_user, p_user);
         ECDP_OBJECTS.SetObjRelEndDate(RelCur.object_id, p_rel_attr_daytime,null,p_user);

     END LOOP;
     ECDP_OBJECTS.InsObjAttrSet(p_contract_obj_id, p_rel_attr_daytime, 'BANK_DETAILS_LEVEL_CODE');
     ECDP_OBJECTS.InsObjAttrSet(p_contract_obj_id, p_rel_attr_daytime, 'DOCUMENT_HANDLING_CODE');

         SELECT Max(daytime)
         INTO lv2_max_start_date
         FROM objects_attribute
         WHERE object_id = p_contract_obj_id
          AND class_name = 'CONTRACT'
          AND daytime < p_rel_attr_daytime
          AND attribute_type = 'BANK_DETAILS_LEVEL_CODE';
          -- Should be the same for both attributes.

          ECDP_OBJECTS.SetObjAttrText(p_contract_obj_id, p_rel_attr_daytime, 'BANK_DETAILS_LEVEL_CODE',ECDP_OBJECTS.GetObjAttrText(p_contract_obj_id,lv2_max_start_date,'BANK_DETAILS_LEVEL_CODE'),null,p_user,p_user);
          ECDP_OBJECTS.SetObjAttrText(p_contract_obj_id, p_rel_attr_daytime, 'DOCUMENT_HANDLING_CODE',ECDP_OBJECTS.GetObjAttrText(p_contract_obj_id,lv2_max_start_date,'DOCUMENT_HANDLING_CODE'),null,p_user,p_user);

      EXCEPTION

           WHEN illegal_revision_date THEN

                    Raise_Application_Error(-20000,'Revision date must be before contract end date. A possibility is to extend the contract end date.');
*/
END InsNewCustVendRevision;

PROCEDURE InsNewVendor(
   p_contract_obj_id VARCHAR2,
   p_vendor_sk_to_obj_id VARCHAR2,
   p_vendor_object_id VARCHAR2,
   p_bank_account_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_rel_attr_end_date DATE,
   p_user VARCHAR2
)


IS
/*
no_bank_account EXCEPTION;
lv2_rel_id objects_relation.object_id%TYPE;
ln_sum_val NUMBER := 0;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*

     SELECT Sum(attribute_value)
     INTO ln_sum_val
      FROM objects_rel_attribute
      WHERE object_id In
         (SELECT object_id
          FROM objects_relation
          WHERE from_object_id =  p_vendor_sk_to_obj_id)
      AND attribute_type = 'SPLIT_VALUE_MTH'
      AND daytime = p_rel_attr_daytime;

     IF p_bank_account_obj_id is null THEN
       RAISE no_bank_account;
     END IF;
     lv2_rel_id := ECDP_OBJECTS.InsNewObjRel(p_vendor_sk_to_obj_id, p_vendor_object_id, 'SPLIT_KEY', p_rel_attr_daytime, p_rel_attr_end_date, p_user, p_user);
     ECDP_OBJECTS.SetObjRelAttrValue(lv2_rel_id, p_rel_attr_daytime, 'SPLIT_SHARE_MTH', 0, 'FALSE', p_user, p_user);
     IF ln_sum_val > 0 THEN
          ECDP_OBJECTS.SetObjRelAttrValue(lv2_rel_id, p_rel_attr_daytime, 'SPLIT_VALUE_MTH', 0, 'FALSE', p_user, p_user);
     END IF;
     lv2_rel_id := ECDP_OBJECTS.InsNewObjRel(p_contract_obj_id, p_bank_account_obj_id, 'VENDOR_BANK_ACCT', p_rel_attr_daytime, p_rel_attr_end_date, p_user, p_user);
     EcDp_Contract.ValidateContrCustVend(p_contract_obj_id, p_rel_attr_daytime,p_user);

EXCEPTION

         WHEN no_bank_account THEN

              Raise_Application_Error(-20000,'A bank account must be selected for the given vendor.');
*/
END InsNewVendor;


PROCEDURE DelVendor(
   p_contract_obj_id VARCHAR2,
   p_vendor_sk_to_obj_id VARCHAR2,
   p_vendor_object_id VARCHAR2,
   p_bank_account_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_user             VARCHAR2
)


IS
/*
p_vendor_rel_obj_id objects_relation.object_id%TYPE;
p_object_id VARCHAR2(2000);
p_end_date DATE;
p_bank_rel_object_id VARCHAR2(2000);
p_bank_rel_end_date DATE;
i NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
     SELECT object_id
     INTO p_vendor_rel_obj_id
     FROM objects_relation
     WHERE from_object_id = p_vendor_sk_to_obj_id
     AND to_object_id = p_vendor_object_id
     AND start_date = p_rel_attr_daytime;

    SELECT Count(*)
    INTO i
    FROM objects_relation
    WHERE from_object_id = p_vendor_sk_to_obj_id
    AND to_object_id = p_vendor_object_id
    AND role_name = 'SPLIT_KEY'
    AND end_date = p_rel_attr_daytime;

    IF i>0 THEN

        SELECT object_id, end_date
        INTO p_object_id, p_end_date
        FROM objects_relation
        WHERE from_object_id = p_vendor_sk_to_obj_id
        AND to_object_id = p_vendor_object_id
        AND role_name = 'SPLIT_KEY'
        AND end_date = p_rel_attr_daytime;

        SELECT object_id, end_date
        INTO p_bank_rel_object_id, p_bank_rel_end_date
        FROM objects_relation
        WHERE from_object_id = p_contract_obj_id
        AND to_object_id = p_bank_account_obj_id
        AND role_name = 'VENDOR_BANK_ACCT'
        AND end_date = p_rel_attr_daytime;
    END IF;

     DelSplitShare(p_vendor_rel_obj_id, p_rel_attr_daytime,p_user);
     ECDP_OBJECTS.DelObjRelByDate(p_contract_obj_id, p_bank_account_obj_id, 'VENDOR_BANK_ACCT', p_rel_attr_daytime);
     ECDP_OBJECTS.DelObjRelByDate(p_vendor_sk_to_obj_id, p_vendor_object_id, 'SPLIT_KEY', p_rel_attr_daytime);
     EcDp_Contract.ValidateContrCustVend(p_contract_obj_id, p_rel_attr_daytime,p_user);
     UpdateShareMth(p_vendor_sk_to_obj_id, p_rel_attr_daytime,p_user);

     IF i>0 THEN

         ECDP_OBJECTS.SetObjRelEndDate(p_object_id, p_end_date,null,p_user);
         ECDP_OBJECTS.SetObjRelEndDate(p_bank_rel_object_id, p_bank_rel_end_date,null,p_user);

     END IF;
*/
END DelVendor;

PROCEDURE InsNewCustomer(
   p_contract_obj_id VARCHAR2,
   p_customer_sk_to_obj_id VARCHAR2,
   p_customer_object_id VARCHAR2,
   p_bank_account_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_rel_attr_end_date DATE,
   p_user VARCHAR2
)


IS
/*
no_bank_account EXCEPTION;
lv2_rel_id objects_relation.object_id%TYPE;
ln_sum_val NUMBER := 0;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*

     SELECT Sum(attribute_value)
     INTO ln_sum_val
      FROM objects_rel_attribute
      WHERE object_id In
         (SELECT object_id
          FROM objects_relation
          WHERE from_object_id =  p_customer_sk_to_obj_id)
      AND attribute_type = 'SPLIT_VALUE_MTH'
      AND daytime = p_rel_attr_daytime;

     IF p_bank_account_obj_id is null THEN
       RAISE no_bank_account;
     END IF;
     lv2_rel_id := ECDP_OBJECTS.InsNewObjRel(p_customer_sk_to_obj_id, p_customer_object_id, 'SPLIT_KEY', p_rel_attr_daytime, p_rel_attr_end_date, p_user, p_user);
     ECDP_OBJECTS.SetObjRelAttrValue(lv2_rel_id, p_rel_attr_daytime, 'SPLIT_SHARE_MTH', 0, 'FALSE', p_user, p_user);
     IF ln_sum_val > 0 THEN
          ECDP_OBJECTS.SetObjRelAttrValue(lv2_rel_id, p_rel_attr_daytime, 'SPLIT_VALUE_MTH', 0, 'FALSE', p_user, p_user);
     END IF;
     lv2_rel_id := ECDP_OBJECTS.InsNewObjRel(p_contract_obj_id, p_bank_account_obj_id, 'CUSTOMER_BANK_ACCT', p_rel_attr_daytime, p_rel_attr_end_date, p_user, p_user);
     EcDp_Contract.ValidateContrCustVend(p_contract_obj_id, p_rel_attr_daytime,p_user);

EXCEPTION

         WHEN no_bank_account THEN

              Raise_Application_Error(-20000,'A bank account must be selected for the given customer.');
*/
END InsNewCustomer;


PROCEDURE DelCustomer(
   p_contract_obj_id VARCHAR2,
   p_customer_sk_to_obj_id VARCHAR2,
   p_customer_object_id VARCHAR2,
   p_bank_account_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_user VARCHAR2 DEFAULT NULL
)


IS
/*
p_customer_rel_obj_id objects_relation.object_id%TYPE;
p_object_id VARCHAR2(2000);
p_end_date DATE;
p_bank_rel_object_id VARCHAR2(2000);
p_bank_rel_end_date DATE;
i NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');

/*
     SELECT object_id
     INTO p_customer_rel_obj_id
     FROM objects_relation
     WHERE from_object_id = p_customer_sk_to_obj_id
     AND to_object_id = p_customer_object_id
     AND start_date = p_rel_attr_daytime;

    SELECT Count(*)
    INTO i
    FROM objects_relation
    WHERE from_object_id = p_customer_sk_to_obj_id
    AND to_object_id = p_customer_object_id
    AND role_name = 'SPLIT_KEY'
    AND end_date = p_rel_attr_daytime;

    IF i>0 THEN

      SELECT object_id, end_date
      INTO p_object_id, p_end_date
      FROM objects_relation
      WHERE from_object_id = p_customer_sk_to_obj_id
      AND to_object_id = p_customer_object_id
      AND role_name = 'SPLIT_KEY'
      AND end_date = p_rel_attr_daytime;

      SELECT object_id, end_date
      INTO p_bank_rel_object_id, p_bank_rel_end_date
      FROM objects_relation
      WHERE from_object_id = p_contract_obj_id
      AND to_object_id = p_bank_account_obj_id
      AND role_name = 'VENDOR_BANK_ACCT'
      AND end_date = p_rel_attr_daytime;
    END IF;


     DelSplitShare(p_customer_rel_obj_id, p_rel_attr_daytime,p_user);
     ECDP_OBJECTS.DelObjRelByDate(p_contract_obj_id, p_bank_account_obj_id, 'CUSTOMER_BANK_ACCT', p_rel_attr_daytime);
     ECDP_OBJECTS.DelObjRelByDate(p_customer_sk_to_obj_id, p_customer_object_id, 'SPLIT_KEY', p_rel_attr_daytime);
     EcDp_Contract.ValidateContrCustVend(p_contract_obj_id, p_rel_attr_daytime,p_user);
     UpdateShareMth(p_customer_sk_to_obj_id, p_rel_attr_daytime,p_user);

     IF i>0 THEN

        ECDP_OBJECTS.SetObjRelEndDate(p_object_id, p_end_date,null,p_user);
        ECDP_OBJECTS.SetObjRelEndDate(p_bank_rel_object_id, p_bank_rel_end_date,null,p_user);

     END IF;
*/
END DelCustomer;

PROCEDURE DelCustVendSplitShare(
   p_rel_from_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_user VARCHAR2 DEFAULT NULL
)

IS
/*
  CURSOR c_split_share IS
  SELECT *
  FROM objects_rel_attribute
  WHERE object_id In
  (SELECT object_id
  FROM objects_relation
  WHERE from_object_id In
  (SELECT from_object_id
    FROM objects_relation
    WHERE object_id = p_rel_from_obj_id))
  AND attribute_type = 'SPLIT_SHARE_MTH'
  AND daytime = p_rel_attr_daytime;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');

/*
     FOR SplitCur IN c_split_share LOOP
         UPDATE objects_rel_attribute
         SET attribute_value = 0,
             daytime = SplitCur.daytime,
             end_date = SplitCur.end_date,
             last_updated_by = nvl(p_user,User)
         WHERE object_id = SplitCur.object_id
          AND attribute_type = 'SPLIT_SHARE_MTH'
          AND daytime = p_rel_attr_daytime;
     END LOOP;
*/
END DelCustVendSplitShare;

PROCEDURE UpdateCustVendShareMth(
   p_rel_to_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_user VARCHAR2 DEFAULT NULL
)

IS
/*
  CURSOR c_rel_attr IS
  SELECT *
  FROM objects_rel_attribute
  WHERE object_id In
     (SELECT object_id
      FROM objects_relation
      WHERE from_object_id =  p_rel_to_obj_id)
  AND attribute_type = 'SPLIT_VALUE_MTH'
  AND daytime = p_rel_attr_daytime;

  ln_max_share NUMBER := 0;
  ln_max_share_11 NUMBER(12,11) := 0; -- (12,11) since share may be 1.00000000000
  ln_share NUMBER;
  ln_share_11 NUMBER(12,11);
  ln_sum_share NUMBER := 0;
  ln_sum_share_11 NUMBER(12,11) := 0;
  ln_delta_share NUMBER;
  ln_sum_val NUMBER := 0;
  ln_max_share_obj_id objects_rel_attribute.object_id%TYPE;
  ln_terminate BOOLEAN := false;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');

/*
     -- If value is NULL then break

     SELECT Sum(attribute_value)
     INTO ln_sum_val
      FROM objects_rel_attribute
      WHERE object_id In
         (SELECT object_id
          FROM objects_relation
          WHERE from_object_id =  p_rel_to_obj_id)
      AND attribute_type = 'SPLIT_VALUE_MTH'
      AND daytime = p_rel_attr_daytime;

     FOR RelAttrCur IN c_rel_attr LOOP
         IF RelAttrCur.attribute_value is NULL THEN
            ln_terminate := true;
            EXIT;
         END IF;

         ln_share := RelAttrCur.attribute_value / ln_sum_val;
         ln_share_11 := ln_share;
         ln_sum_share_11 := ln_sum_share_11+ln_share_11;
         ln_sum_share := ln_sum_share+ln_share;
         IF ln_share > ln_max_share THEN
            ln_max_share := ln_share;
            ln_max_share_obj_id := RelAttrCur.object_id;
         END IF;

         UPDATE objects_rel_attribute
         SET attribute_value = ln_share_11,
             last_updated_by = nvl(p_user,User)
         WHERE object_id = RelAttrCur.object_id
          AND attribute_type = 'SPLIT_SHARE_MTH'
          AND daytime = p_rel_attr_daytime;

     END LOOP;

     IF ln_terminate = false THEN
       --ln_sum_share_11 := ln_sum_share;
       ln_delta_share := ln_sum_share - ln_sum_share_11;
       ln_max_share_11 := ln_max_share + ln_delta_share;

       UPDATE objects_rel_attribute
       SET attribute_value = ln_max_share_11,
           last_updated_by = nvl(p_user,User)
       WHERE object_id = ln_max_share_obj_id
        AND attribute_type = 'SPLIT_SHARE_MTH'
        AND daytime = p_rel_attr_daytime;
     END IF;
*/
END UpdateCustVendShareMth;

PROCEDURE InsNewChildSplitKey (
          p_parent_split_key_id VARCHAR2,
          p_parent_split_member_id VARCHAR2,
          p_child_split_type VARCHAR2, -- ex: COMPANY, FIELD, STREAM_ITEM
          p_child_split_key_method VARCHAR2, -- ex: PERCENTAGE, SOURCE_SPLIT
          p_daytime DATE
          )
IS

  CURSOR c_SK IS
    SELECT sk.*
    FROM split_key sk, split_key_version skv
    WHERE sk.object_id = skv.object_id
    AND skv.daytime = (SELECT MAX(daytime) FROM split_key_version WHERE object_id = sk.object_id AND daytime <= p_daytime)
    AND sk.object_id = p_parent_split_key_id;

  lv2_object_id VARCHAR2(32);
  lv2_child_object_code VARCHAR2(32);
  ld_start_date DATE;
  ld_end_date DATE;
  lv2_user VARCHAR2(64) := Nvl(EcDp_Context.getAppUser,User);

BEGIN

  IF ec_split_key_setup.child_split_key_id(p_parent_split_key_id, p_parent_split_member_id, p_daytime) IS NULL THEN

    -- generate child split key object code
    lv2_child_object_code := 'CSK:' || Ecdp_System_Key.assignNextKeyValue('SPLIT_KEY_CHILD');

    -- Get start and end date from parent record's split key.
    FOR rsSK IN c_SK LOOP
      ld_start_date := rsSK.start_date;
      ld_end_date := rsSK.End_Date;
    END LOOP;

    -- insert new split key
    INSERT INTO split_key (object_code, start_date, end_date, created_by)
    VALUES (lv2_child_object_code, ld_start_date, ld_end_date, lv2_user)
    RETURNING object_id INTO lv2_object_id;

    INSERT INTO split_key_version (object_id, daytime, end_date, name, split_type, split_key_method, purpose, created_by)
    VALUES (lv2_object_id, ld_start_date, ld_end_date, lv2_child_object_code, p_child_split_type, p_child_split_key_method, 'SP', lv2_user);

    -- add reference to parent split key setup record
    UPDATE split_key_setup sks SET
      sks.child_split_key_id = lv2_object_id,
      sks.child_split_key_method = p_child_split_key_method
    WHERE sks.object_id = p_parent_split_key_id
    AND sks.split_member_id = p_parent_split_member_id
    AND sks.daytime = p_daytime;

  END IF;

  IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('SPLIT_KEY'),'N') = 'Y') THEN
				EcDp_Acl.RefreshObject(lv2_object_id, 'SPLIT_KEY', 'INSERTING');
  END IF;

END InsNewChildSplitKey;


PROCEDURE ValidateSpSetupSplitKey (
    p_split_key_id VARCHAR2,
    p_daytime DATE
)
IS

n_split_sum NUMBER;

BEGIN

     select nvl(sum(ss.split_share_mth),0)  into n_split_sum from split_key_setup ss where object_id = p_split_key_id and daytime = p_daytime;

     IF n_split_sum = 0 or n_split_sum = 1 THEN
        NULL;
     ELSE
             Raise_Application_Error(-20000,'Sum of shares must be either 0 or 100%');
     END IF;


END ValidateSpSetupSplitKey;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : DelNewerSplitKeyVersions
-- Description    : Deletes split key versions that is newer than the given date (
--                  p_lastest_version_to_keep).
---------------------------------------------------------------------------------------------------
PROCEDURE DelNewerSplitKeyVersions(p_split_key_id VARCHAR2, p_latest_version_to_keep DATE)
--</EC-DOC>
IS
BEGIN
    DELETE FROM split_key_setup
    WHERE split_key_setup.object_id = p_split_key_id
        AND split_key_setup.daytime > p_latest_version_to_keep;

    DELETE FROM split_key_version
    WHERE split_key_version.object_id = p_split_key_id
        AND split_key_version.daytime > p_latest_version_to_keep;
END DelNewerSplitKeyVersions;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsNewSplitKeyVersionWithChild
-- Description    : Creates a new split key version. This procedure also creates new versions
--                  for child split keys and copy split key setups to the new version.
---------------------------------------------------------------------------------------------------
PROCEDURE InsNewSplitKeyVersionWithChild(p_split_key_id VARCHAR2,
                                        p_new_version_daytime DATE,
                                        p_source_version_daytime DATE DEFAULT NULL,
                                        p_new_version_enddate DATE,
                                        p_user VARCHAR2) IS
    -- This cursor fetches all child split keys for a given split key, only
    -- Split key setup has the given daytime is searched.
    CURSOR c_child_split_keys(cp_split_key_id VARCHAR2, cp_daytime DATE) IS
        SELECT DISTINCT split_key_setup.child_split_key_id child_split_key_id
        FROM split_key_setup
        WHERE split_key_setup.object_id = cp_split_key_id
            AND split_key_setup.daytime = cp_daytime
            AND split_key_setup.child_split_key_id IS NOT NULL;

    TYPE SPLIT_KEY_OBJECT_ID_LIST IS TABLE OF split_key.object_id%TYPE;

    lt_split_key_ids SPLIT_KEY_OBJECT_ID_LIST := SPLIT_KEY_OBJECT_ID_LIST(); -- List storing all unsolved split key IDs.
    lv_sp_id split_key.object_id%TYPE;
    lv_sp_index NUMBER;
    ld_prev_version_daytime DATE;
    -- ** 4-eyes approval stuff ** �
    lv2_4e_recid VARCHAR2(32);
    -- ** END 4-eyes approval stuff ** �
BEGIN
    -- Get the previous version, will use the p_source_version_daytime
    -- if given, or previous split key version as default
    IF p_source_version_daytime IS NULL THEN
        ld_prev_version_daytime := ec_split_key_version.prev_daytime(p_split_key_id, p_new_version_daytime, 1);
    ELSE
        ld_prev_version_daytime := p_source_version_daytime;
    END IF;

    -- Create new versions for all related split keys (and their sub-split-keys)
    lt_split_key_ids.EXTEND(1);
    lt_split_key_ids(1) := p_split_key_id;

    WHILE lt_split_key_ids.COUNT > 0 LOOP
        -- Get current split key
        lv_sp_id := lt_split_key_ids(lt_split_key_ids.LAST);

        -- Initiate the new version of split key
        InsNewSplitKeyVersion(lv_sp_id, p_new_version_daytime, p_new_version_enddate, p_user, TRUE);

        -- Remove current split key
        lt_split_key_ids.TRIM(1);

        -- Add unsolved child split keys to list
        -- Get the index of the last element in list
        lv_sp_index := lt_split_key_ids.COUNT;
        -- Get all child split keys that connected to the previous template version
        FOR sk IN c_child_split_keys(lv_sp_id, ld_prev_version_daytime) LOOP
            lv_sp_index := lv_sp_index + 1;
            lt_split_key_ids.EXTEND(1);
            lt_split_key_ids(lv_sp_index) := sk.child_split_key_id;
        END LOOP;
    END LOOP;

    -- ** 4-eyes approval stuff ** �
    IF NVL(Ec_Class.approval_ind('SPLIT_KEY'),'N') = 'Y' THEN

        -- Generate rec_id for the new record
         lv2_4e_recid := SYS_GUID();

        -- Set approval info on new record.
         UPDATE split_key_version
         SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
             last_updated_date = ecdp_date_time.getCurrentSysdate,
         approval_state = 'N',
         rec_id = lv2_4e_recid,
         rev_no = (nvl(rev_no,0) + 1)
         WHERE object_id = lv_sp_id
         AND daytime = p_new_version_daytime;

        -- Register new record for approval
         Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
         'SPLIT_KEY',
         Nvl(EcDp_Context.getAppUser,User));
         END IF;
   -- ** END 4-eyes approval ** �

END InsNewSplitKeyVersionWithChild;

--<EC-DOC>
------------------------------------------------------------------------------------
-- Procedure      : InsNewSplitKeyItem
-- Description    : Creates a new split key item. This procedure also creates new versions
--                  for split key item.
------------------------------------------------------------------------------------

FUNCTION InsNewSplitKeyItem(
   p_object_code VARCHAR2,
   p_object_name VARCHAR2,
   p_start_date   DATE,
   p_end_date  DATE,
   p_user      VARCHAR2
) RETURN VARCHAR2
--<EC-DOC>
IS
  lv2_object_id VARCHAR2(32);
BEGIN

     INSERT INTO split_item_other
       (object_code, start_date, end_date, created_by)
     VALUES
       (p_object_code, p_start_date, p_end_date, p_user)
     RETURNING object_id INTO lv2_object_id;

     INSERT INTO split_item_other_version
       (object_id, name, daytime, end_date, created_by)
     VALUES
       (lv2_object_id, p_object_name, p_start_date, p_end_date, p_user);

     RETURN lv2_object_id;
END InsNewSplitKeyItem;
---------------------------------------------------------------------------------------------------
-- Procedure      : CopySplitKeySetupForNewVersion
-- Description    : When New Split Key Version is created,by default latest share table will be copies for it.
--                : Is called from IUR_SPLIT_KEY_VERSION.
-- Using tables   : SPLIT_KEY_SETUP.
-- Behaviour      : Called when New split key version created.
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE CopySplitKeySetupForNewVersion(
   p_object_id VARCHAR2,
   p_start_date   DATE,
   p_user      VARCHAR2
  )
IS
CURSOR c_sk_setup IS
SELECT * FROM split_key_setup sks
WHERE sks.object_id = p_object_id
AND sks.daytime = (SELECT max(daytime) FROM split_key_setup sks2 WHERE object_id = p_object_id AND daytime < p_start_date);

BEGIN
     -- Insert new version of the existing split key members
    FOR SplitCurSetup IN c_sk_setup LOOP
        INSERT INTO split_key_setup (OBJECT_ID,
                                          SPLIT_MEMBER_ID,
                                          CLASS_NAME,
                                          DAYTIME,
                                          SPLIT_SHARE_MTH,
                                          SPLIT_VALUE_MTH,
                                          COMMENTS_MTH,
                                          SPLIT_SHARE_DAY,
                                          SPLIT_VALUE_DAY,
                                          PROFIT_CENTRE_ID,
                                          COMMENTS_DAY,
                                          COMMENTS,
                                          SOURCE_MEMBER_ID,
                                          CREATED_BY,
                                          CHILD_SPLIT_KEY_ID,
                                          CHILD_SPLIT_KEY_METHOD)
             VALUES (SplitCurSetup.Object_Id
                     ,SplitCurSetup.Split_Member_Id
                     ,SplitCurSetup.Class_Name
                     ,p_start_date
                     ,SplitCurSetup.Split_Share_Mth
                     ,SplitCurSetup.Split_Value_Mth
                     ,SplitCurSetup.Comments_Mth
                     ,SplitCurSetup.Split_Share_Day
                     ,SplitCurSetup.Split_Value_Day
                     ,SplitCurSetup.Profit_Centre_Id
                     ,SplitCurSetup.Comments_Day
                     ,SplitCurSetup.Comments
                     ,SplitCurSetup.Source_Member_Id
                     ,p_user
                     ,SplitCurSetup.Child_Split_Key_Id
                     ,SplitCurSetup.CHILD_SPLIT_KEY_METHOD);
    END LOOP;

END;

END EcDp_Split_Key;