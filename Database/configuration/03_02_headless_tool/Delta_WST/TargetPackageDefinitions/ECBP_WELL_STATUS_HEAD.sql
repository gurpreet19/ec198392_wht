CREATE OR REPLACE PACKAGE EcBp_Well_Status IS
/****************************************************************
** Package        :  EcBp_Well_Status, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Provides business functions related to well status.
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.01.2006  Dagfinn Njå
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- --------------------------------------
**
*****************************************************************/

--

PROCEDURE checkWellStatusLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

END EcBp_Well_Status;