CREATE OR REPLACE PACKAGE ecdp_4ea_utility IS
/******************************************************************************
** Package        :  ecdp_4ea_utility, body part
**
** Purpose        :  Automatically generated for 4-eyes approval check
**
** Documentation  :  www.energy-components.com
**
********************************************************************/

TYPE t_class_name_list IS TABLE OF VARCHAR2(2000);
TYPE t_rec_id_list IS TABLE OF VARCHAR2(32);
TYPE t_node_list IS TABLE OF VARCHAR2(2000);
TYPE t_level_list IS TABLE OF NUMBER;


l_node_list t_node_list;
l_level_list t_level_list;
lb_debug BOOLEAN := FALSE;
l_visited_object  t_rec_id_list;

CURSOR c_classdependencylinks(cp_class_name VARCHAR2) IS
SELECT cr.to_class_name child_class, cr.role_name, db_sql_syntax, cdb.db_mapping_type, 1 rel_direction
from class_relation cr, class_rel_db_mapping cdb
where cr.from_class_name = cp_class_name
and  cr.from_class_name = cdb.from_class_name
and  cr.to_class_name = cdb.to_class_name
and  cr.role_name = cdb.role_name
AND  approval_ind = 'Y'
AND db_mapping_type IN ('ATTRIBUTE','COLUMN')
and nvl(cr.disabled_ind,'N') = 'N'
UNION ALL
SELECT cr.from_class_name child_class, cr.role_name, db_sql_syntax,  cdb.db_mapping_type, 2 rel_direction
from class_relation cr, class_rel_db_mapping cdb
where cr.from_class_name = cdb.from_class_name
and   cr.to_class_name = cdb.to_class_name
and   cr.role_name = cdb.role_name
and   cr.to_class_name = cp_class_name
AND  reverse_approval_ind = 'Y'
AND db_mapping_type IN ('ATTRIBUTE','COLUMN')
and nvl(cr.disabled_ind,'N') = 'N'
UNION ALL
SELECT class_name child_class, 'OWNERCLASS', 'OBJECT_ID', 'DATACLASS' , 3 rel_direction
from class cr
where owner_class_name = cp_class_name
;

PROCEDURE AddUnapprovedData(
          p_class_name  IN  VARCHAR2
,         p_rec_id      IN  VARCHAR2
,         p_class_name_list IN OUT t_class_name_list
,         p_rec_id_list IN OUT t_rec_id_list
);

PROCEDURE AddVisitedNode(
          p_node_name   IN  VARCHAR2,
          p_level       IN  NUMBER
);

PROCEDURE ClearVisitedNode;


FUNCTION isVisitedNode(
          p_node_name   IN  VARCHAR2
) RETURN VARCHAR2;

PROCEDURE ClearVisitedObject;

PROCEDURE AddVisitedObject(
          p_class_name  IN  VARCHAR2,
          p_rec_id      IN  VARCHAR2,
          p_level       IN  NUMBER DEFAULT NULL
);

FUNCTION isVisitedObject(
          p_rec_id   IN  VARCHAR2
)RETURN VARCHAR2;


FUNCTION hasapproval(p_class_name VARCHAR2) RETURN VARCHAR2;

FUNCTION isOnApprovalPath(p_class_name VARCHAR2,p_level NUMBER DEFAULT 0) RETURN VARCHAR2;

FUNCTION isunapprovedData RETURN VARCHAR2;

FUNCTION isusing4ea RETURN VARCHAR2;


FUNCTION AddCPTask(p_severity varchar2,
                    p_description varchar2
                    )
RETURN NUMBER;

PROCEDURE AddCPTaskDetail(p_task_no INTEGER,
                          p_class_name_list ecdp_4ea_utility.t_class_name_list,
                          p_rec_id_list ecdp_4ea_utility.t_rec_id_list
                          );




END ecdp_4ea_utility;