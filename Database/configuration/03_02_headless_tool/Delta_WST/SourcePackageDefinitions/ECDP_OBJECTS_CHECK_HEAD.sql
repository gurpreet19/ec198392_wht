CREATE OR REPLACE PACKAGE EcDp_Objects_Check IS
/****************************************************************
** Package        :  EcDp_Objects_Check, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Generate code for checks in ECTP packages, used by EcDp_genclasscode.
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.03.2007  Arild Vervik
**
** Modification history:
**

** Date     Whom   Change description:
** -------- ------ ------ --------------------------------------
**
*****************************************************************/
FUNCTION getOwnerJoinStartDateColumn(p_data_class_name VARCHAR2)
RETURN VARCHAR2;

FUNCTION getOwnerJoinEndDateColumn(p_data_class_name VARCHAR2)
RETURN VARCHAR2;

PROCEDURE AddChildEndDateCursor(p_body_lines in out DBMS_SQL.varchar2a,
                                p_class_name VARCHAR2,
                                p_union_count in out NUMBER,
                                p_recursive_level IN NUMBER,
                                p_count IN OUT NUMBER
                                );

PROCEDURE AddChildEndDateCheck (p_body_lines in out DBMS_SQL.varchar2a,
                                p_union_count in NUMBER);
END;