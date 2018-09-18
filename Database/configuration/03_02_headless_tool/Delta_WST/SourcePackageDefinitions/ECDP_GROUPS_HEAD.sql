CREATE OR REPLACE PACKAGE EcDp_Groups IS
/**************************************************************
** Package   :  EcDp_Groups, head.
** $Revision :  1.2 $
**
** Purpose   :  Functions related to groups table
**
** General Logic:
**
** Created:      07.09.01  Riku Vilkki
**

** Modification history:
**
**
** Date:      Whom: Change description:
** ---------- ----- --------------------------------------------
** 2001.09.07 RVI   Initial version
** 2002.02.15 MTa   Added delete_single_group_connection method
** 2002.02.28 DN    Removed findgroupitemByCode. Moved to EcBP_US_Config.
** 2002.03.01 DN    Added function connectionIsDated.
** 2002.03.07 DN    Added functions from ecg_groups.
** 2002.05.16 HNE   Created findParentObjectId and findParentAttributeText.
** 2002.06.28 TeJ   Added function findFirstParent
** 2002-07-24 MTa   Changed object_id references to objects.object_id%TYPE
** 2002-09-19 TeJ   Removed p_recurse as parameter in deleteConnections, and added a new overloaded deleteConnections without group_type in parameter list.
** 2004-03-31 DN    Added findNextGroupConnectionDate.
** 2004-08-10 Toha  Remove sysnam from function/procedure's signature
** 2004-08-20 Toha  Removed functions getParentCode and getParentName. Code columns are removed, while name holds no value. use findParentObjectId instead.
**                  getObjectCode and getObjectName are removed as well for the same reason above
** 2004-08-27 DN    Removed findParentAttributeText.
** 2005-03-02 AV    Removed obsolete functions
**************************************************************/



FUNCTION findParentObjectId(p_find_item_type VARCHAR2,
                            p_group_type VARCHAR2,
                            p_item_type VARCHAR2,
                            p_item_id VARCHAR2,
                            p_daytime DATE)
RETURN VARCHAR2;

FUNCTION isChild(p_group_type VARCHAR2,
                 p_class_name VARCHAR2,
                 p_object_id  VARCHAR2,
                 p_daytime    DATE,
                 p_parent_class VARCHAR2,
                 p_parent_object_id VARCHAR2)
RETURN VARCHAR2;




END;