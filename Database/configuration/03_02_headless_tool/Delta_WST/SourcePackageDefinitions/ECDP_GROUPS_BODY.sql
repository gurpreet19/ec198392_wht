CREATE OR REPLACE PACKAGE BODY EcDp_Groups IS
/**************************************************************
** Package   :  EcDp_Groups
** $Revision: 1.3 $
**
** Purpose   :  Functions related to groups table
**
** General Logic:
**
** Created:      07.09.01  Riku Vilkki
**
**
** Modification history:
**
**
** Date:       Whom: Change description:
** ----------  ----- --------------------------------------------
** 07.09.01    RVI   Initial version
** 18.09.01    RVI   create_group_connection renamed to set_group_connection and update handling
**                   added
** 20.09.01    RVI   stream created for fluid meter too
** 26.09.01    RVI   set_group_connection start_date handling fixed
** 12.11.01    FBa   Fixed bug in set_group_connection. Did not handle Operational changes properly for San Juan.
** 19.11.01    FBa   Fixed bug in set_group_connection. Insert was done instead of update for Operational.
** 27.11.01    FBa   Fixed bug in set_group_connection.
** 03.12.01    FBa   Improved error handling in createMeteredStream. Raise error if phase or purpose is not found.
** 17.01.02    MTa   Error handling in set_group_connection for equipment connection dates prior to equipment start dates.
** 23.01.02    MTa   Modified set_group_connection.  Added code to handle update of end date.
**                   Moved the findGroupItem call closer to where ln_val was actually being referenced.
** 31.01.02    MTA   Changed the criteria for the update/insert IF/ELSE statement to fix multiple connections
**                   from Facitilies (wells) to PJACs.  Operational group only.
** 2002-02-08  FBa   Prepared for adding the allocation network for meters, tanks and facilities.
** 2002-02-15  MTa   Added delete_single_group_connection method
** 2002-02-18  MTa   Fixed bug in set_group_connection which was updating the end_date properties for all group entries.
** 2002-02-28  DN    Added documentation. QA walkthrough before. Removed findgroupitemByCode. Moved to EcBP_US_Config.
** 2002-03-04  DN    Implemented test on dated group model connections. Added function connectionIsDated. Modified call to createMeteredStream.
** 2002-03-07  DN    Included functions from ecg_groups package.
** 2002-04-22  TeJ   deleteSingleGroupConnection sets end_date on last valid connection to NULL
**                   setGroupConnection: Added group type 'Flowline' to the set which uses from_date instead of start_date
** 2002-04-29  TeJ   Changed setGroupConnection to qualify on object_table instead of group_type when deciding whether from_date or start_date is to be used.
** 2002-05-16  HNE   Created findParentObjectId and findParentAttributeText.
** 2002-06-28  TeJ   Added terminal support findParentAttributeText.
**                   Added function findFirstParent.
** 2002-07-11  DN    Removed sysnam from function parameter list in call EcDP_Facility.getFacility.
** 2002-07-24  MTa   Changed object_id references to objects.object_id%TYPE
** 2002-07-29  MTa   Changed setGroupConnection().  Start date will default to 1/1/1900 if not found.
** 2002-08-08  MTa   Changed createGroupItem().  Added quotation marks to calls to ecdp_utilities.executeSinglerowNumber()
** 2002-08-26  MTa   GUID changes, fixed Well cursor
** 2002-09-19  TeJ   Removed p_recurse as parameter in deleteConnections, and added a new overloaded deleteConnections without group_type in parameter list
** 2002-10-28  HNE   Changes findParentAttributeText to use new function 'ecdp_object.getAttributeText' rahter than hardcode.
** 2004-08-10  Toha  Removed sysnam from package. Changed parameter signature as necessary.
** 2004-08-20  Toha  Removed functions getParentCode and getParentName. Code columns are removed, while name holds no value. use findParentObjectId instead.
**                   getObjectCode and getObjectName are removed as well for the same reason above
** 2004-08-27  DN    Removed findParentAttributeText.
** 2004-09-09  SHN   Added procedure UpdateGroupAttribute
** 2005-03-02  AV    Removed obsolete functions
** 2006-02-14  DN    TI3467: Made the function findParentObjectId a wrapper function by calling a similar generated function.
** 2011-11-22  Leongwen ECPD-19252: Modified the function findParentObjectId() to check with collection_point.
**************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findParentObjectId
-- Description    : Returns the parent id of the parent group.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : GROUPS
--
-- Using functions: ecgp_group.findParentObjectId
--
-- Configuration
-- required       :
--
-- Behaviour      : Fallback to old logic when the function call return null.
--
---------------------------------------------------------------------------------------------------
FUNCTION findParentObjectId(p_find_item_type VARCHAR2,
                            p_group_type VARCHAR2,
                            p_item_type VARCHAR2,
                            p_item_id VARCHAR2,
                            p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

   CURSOR c_parents (p_group VARCHAR2,p_item VARCHAR2,p_id VARCHAR2,p_daytime DATE) IS
   SELECT parent_group_type, parent_object_type, parent_object_id
    FROM groups
    WHERE p_daytime BETWEEN NVL(daytime,p_daytime -1) AND NVL(end_date,p_daytime +1)
    START WITH group_type = p_group AND object_type = p_item AND object_id = p_id
    CONNECT BY PRIOR parent_group_type = group_type
     AND PRIOR parent_object_type = object_type
     AND PRIOR parent_object_id = object_id
     AND p_daytime BETWEEN NVL(PRIOR daytime,p_daytime -1) AND NVL(PRIOR end_date,p_daytime +1)
     ORDER BY daytime DESC;

   ln_parent_id VARCHAR2(32);

BEGIN

   ln_parent_id := ecgp_group.findParentObjectId(p_group_type,
                                                 p_find_item_type,
                                                 p_item_type,
                                                 p_item_id,
                                                 p_daytime);

   IF ln_parent_id IS NULL AND p_group_type NOT IN ('geographical','operational','collection_point') THEN
      FOR mycur IN c_parents(p_group_type,p_item_type,p_item_id,p_daytime) LOOP
         IF p_group_type = mycur.parent_group_type AND p_find_item_type = mycur.parent_object_type THEN
            RETURN mycur.parent_object_id;
         END IF;
      END LOOP;
   END IF;

   RETURN ln_parent_id;

END findParentObjectId;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findParentObjectId
-- Description    : Returns the parent id of the parent group.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : GROUPS
--
-- Using functions: ecgp_group.findParentObjectId
--
-- Configuration
-- required       :
--
-- Behaviour      : Fallback to old logic when the function call return null.
--
---------------------------------------------------------------------------------------------------
FUNCTION isChild(p_group_type VARCHAR2,
                 p_class_name VARCHAR2,
                 p_object_id  VARCHAR2,
                 p_daytime    DATE,
                 p_parent_class VARCHAR2,
                 p_parent_object_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_sql         VARCHAR2(4000);
  lv2_table_name  VARCHAR2(50);
  lv2_column      VARCHAR2(50);
  lv2_return      VARCHAR2(1) := 'N';

BEGIN

   lv2_table_name := ecdp_classmeta.getClassDBAttributeTable(p_class_name);

   IF LOWER(p_group_type) = 'operational' THEN

       IF p_parent_class = 'PRODUCTIONUNIT' THEN
         lv2_column := 'OP_PU_ID';
       ELSIF p_parent_class = 'PROD_SUB_UNIT' THEN
         lv2_column := 'OP_SUB_PU_ID';
       ELSIF p_parent_class = 'AREA' THEN
         lv2_column := 'OP_AREA_ID';
       ELSIF p_parent_class = 'SUB_AREA' THEN
         lv2_column := 'OP_SUB_AREA_ID';
       ELSIF p_parent_class = 'FCTY_CLASS_2' THEN
         lv2_column := 'OP_FCTY_CLASS_2_ID';
       ELSIF p_parent_class = 'FCTY_CLASS_1' THEN
         lv2_column := 'OP_FCTY_CLASS_1_ID';
       END IF;

       IF  lv2_table_name IS NOT NULL AND lv2_column IS NOT NULL THEN

         lv2_sql := 'SELECT ''Y'' FROM '||lv2_table_name||' WHERE object_id = '''||p_object_id||''''||
                    'and '||ecdp_dynsql.date_to_string(p_daytime) ||' >= daytime '||
                    'and '||ecdp_dynsql.date_to_string(p_daytime) ||' < nvl(end_date,'||ecdp_dynsql.date_to_string(p_daytime)||'+1) '||
                    'and '||lv2_column||' = '''|| p_parent_object_id||'''';

         lv2_return := Nvl(ecdp_dynsql.execute_singlerow_varchar2(lv2_sql),'N');


       END IF; --table and column found

   END IF; -- operational

   RETURN lv2_return;

END;



END;